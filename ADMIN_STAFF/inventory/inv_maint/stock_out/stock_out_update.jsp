<%@ page language="java" import="utility.*,inventory.InventoryMaintenance,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language='JavaScript'>
function ProceedClicked(){
	document.form_.print_page.value = "";
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function SaveStatus(){
	document.form_.saveClicked.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function PageLoad(){
	document.form_.req_no.focus();
}
function PrintPage(){
	document.form_.saveClicked.value = "";
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}
function OpenSearch(){
	document.form_.print_page.value = "";
	var pgLoc = "stock_out_view_search.jsp?opner_info=form_.req_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%
//add security here.
	if(WI.fillTextValue("print_page").equals("1")){%>
		<jsp:forward page="stock_out_item_print.jsp"/>
	<%return;}
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-LOG"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	DBOperation dbOP = null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-REQUISITION STATUS UPDATE-Requisition Update","stock_out_update.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
	InventoryMaintenance InvMaint = new InventoryMaintenance();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending"};	
	String[] astrReqType = {"Donate","Dispose / discard item(s)", "Consume / use supply"};
	String strErrMsg = null;
	String strTemp = null;
	String strReqIndex = WI.fillTextValue("req_index");
	boolean bolIsInPO = false;
	
	if(WI.fillTextValue("proceedClicked").length() > 0){
		if(WI.fillTextValue("saveClicked").equals("1")){
			if(InvMaint.updateTransferReqStatus(dbOP,request,true))
				strErrMsg = "Status saved.";
			else
				strErrMsg = InvMaint.getErrMsg();
		}
		
		if(WI.fillTextValue("req_no").length() > 0){
			 vReqInfo = InvMaint.operateOnStockOutInfo(dbOP,request,3);
			 if(vReqInfo == null && WI.fillTextValue("req_no").length() > 0
								&& WI.fillTextValue("pageAction").length() < 1)
				  strErrMsg = InvMaint.getErrMsg();
			 else
				  strReqIndex = (String)vReqInfo.elementAt(0);			
			
			 vReqItems = InvMaint.operateOnItemStockOut(dbOP,request,4);		
			 if(vReqItems == null)
					strErrMsg = "No item(s) for this Requisition.";
	   }else{
		   strErrMsg = "Please input requisition No.";			
	   }	 
	}
%>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<form name="form_" method="post" action="stock_out_update.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A"> 
			<td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
						REQUISITION : UPDATE SUPPLIES REQUISITION STATUS PAGE ::::</strong></font></div></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25"><font size="1"><a href="request_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="40">&nbsp;</td>
      <td width="21%">Requisition No.</td>
      <td valign="middle"><strong>
	  <%if(WI.fillTextValue("req_no").length() > 0)
	  		strTemp = WI.fillTextValue("req_no");
	  	else
			strTemp = "";%>
      <input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong>&nbsp;
		<a href="javascript:OpenSearch();">
		<img src="../../../../images/search.gif" border="0"></a>
		&nbsp;		 
		<a href="javascript:ProceedClicked();"> 
		<img src="../../../../images/form_proceed.gif" border="0">
      </a></td>
    </tr>
  </table>
  <%if(vReqInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D">
      <td width="3%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS </strong></div></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(1)).equals("0")){%>
    <%}else{%>
    <%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Request Type</td>
      <td colspan="3"><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(3))]%></strong></td>
    </tr>
    <tr>
      <td height="25" width="3%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="25%"><strong><%=WI.fillTextValue("req_no")%></strong></td>
      <td width="21%">Requested By :</td>
      <td width="29%"><strong><%=(String)vReqInfo.elementAt(4)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(10))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(5)).equals("0")){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Non-Acad. Office/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%}else{%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>College/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(7)+"/"+WI.getStrValue((String)vReqInfo.elementAt(8),"All")%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Remarks</td>
      <td colspan="3"><strong><%=WI.getStrValue((String)vReqInfo.elementAt(9))%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <%if(vReqItems != null){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">    
	  <tr>
	  	  <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF REQUESTED SUPPLIES</strong></font></div></td>
	  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr>
      <td height="25" colspan="4" class="thinborder">Requested by :<strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
    </tr>
    <tr>
      <td width="17%" height="25" align="center" class="thinborder"><strong>ITEM CODE </strong></td>
      <td width="15%" align="center" class="thinborder"><strong>QUANTITY</strong></td>
      <td width="14%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="54%" align="center" class="thinborder"><strong>ITEM</strong></td>
    </tr>
    <% int iCountItem = 0;
	for(int i = 0;i < vReqItems.size();i+=11,iCountItem++){%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vReqItems.elementAt(i+10),"&nbsp;")%></td>
      <td align="right" class="thinborder"><%=vReqItems.elementAt(i+2)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=vReqItems.elementAt(i+3)%></td>
      <td class="thinborder">&nbsp;<%=vReqItems.elementAt(i+4)%></td>
    </tr>
    <%} // end for loop%>
    <input type="hidden" name="item_count" value="<%=iCountItem%>">
    <tr>
      <td class="thinborder" height="25" colspan="4"><div align="left"><strong>TOTAL ITEM(S) : <%=iCountItem%></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="10%" height="25"><div align="center"></div></td>
      <td colspan="2">Status : 
			<%
			if(vReqInfo != null && vReqInfo.size() > 0)
					strTemp = (String)vReqInfo.elementAt(10);
				else
					strTemp = "";		
			%>
        <select name="status">
          <option value="1">Approved</option>
          <%if(strTemp.equals("2")){%>
          <option value="2" selected>Pending</option>
          <option value="0">Disapproved</option>
          <%}else if(strTemp.equals("0")){%>
          <option value="2">Pending</option>
          <option value="0" selected>Disapproved</option>
          <%}else{%>
          <option value="2">Pending</option>
          <option value="0">Disapproved</option>
          <%}%>
        </select>
		 <a href="javascript:PrintPage();"> <img src="../../../../images/print.gif" border="0"></a> 
         <font size="1">click to print Requisition Form</font> 
		 </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="38%">Date Updated : 
      <%if(vReqInfo != null && (((String)vReqInfo.elementAt(11)) != null))
					strTemp = (String)vReqInfo.elementAt(11);		
			 else if(WI.fillTextValue("date_updated").length() > 0)
	  			strTemp = WI.fillTextValue("date_updated");
			 else
					strTemp = WI.getTodaysDate(1);
	  %>
        <input name="date_updated" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_updated');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
      <td width="52%">
	  <a href="javascript:SaveStatus();">
	  <img src="../../../../images/save.gif" border="0"></a>
      <font size="1">click to save update</font></td>
    </tr>
  </table>
  <%}}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="is_supply" value="<%=WI.fillTextValue("is_supply")%>">
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="saveClicked" value="">
  <input type="hidden" name="req_index" value="<%=strReqIndex%>">
  <input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>