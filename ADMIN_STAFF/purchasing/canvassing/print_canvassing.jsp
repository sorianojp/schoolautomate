<%@ page language="java" import="utility.*,purchasing.Canvassing,purchasing.Requisition,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function OpenSearch(){
	document.form_.print_pg.value = "";
	var pgLoc = "../requisition/requisition_view_search.jsp?opner_info=form_.req_no&is_supply=form_.is_supply";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageLoad(){
 	document.form_.req_no.focus();
}
function ProceedClicked(){
	document.form_.print_pg.value = "";
	document.form_.proceedClicked.value = 1;
	this.SubmitOnce('form_');
}
function PrintPg(){
	document.form_.print_pg.value = 1;
	this.SubmitOnce('form_');
}
function SaveClicked(){
	document.form_.print_pg.value = "";
	document.form_.save_clicked.value = 1;
	this.SubmitOnce('form_');
}
function CancelClicked(){
	location = "./print_canvassing.jsp";
}
</script>
<%
	if(WI.fillTextValue("print_pg").equals("1")){%>
		<jsp:forward page="../requisition/req_item_print.jsp"/>
	<%}

	DBOperation dbOP = null;
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-CANVASSING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-CANVASSING-Print Canvassing","print_canvassing.jsp");
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
	
	Requisition REQ = new Requisition();
	Canvassing CAN = new Canvassing();	
	Vector vReqInfo = null;
	Vector vReqItems = null;	
	Vector vReqCanvass = null;
	boolean bolIsInCanvass = false;
	String strErrMsg = null;
	String strTemp = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String strSchCode = dbOP.getSchoolIndex();
	String strInfoIndex = WI.fillTextValue("info_index");
	String strCanvassNo = WI.fillTextValue("canvass_no");
	String strCanvassDate = WI.fillTextValue("canvass_date");
	int iDefault = 0;	
	if (WI.fillTextValue("proceedClicked").equals("1")){
		vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);
		if(vReqInfo == null)
			strErrMsg = REQ.getErrMsg();
		else{
			strInfoIndex = (String)vReqInfo.elementAt(0);
			if(WI.fillTextValue("save_clicked").length() > 0){
				vReqItems = CAN.saveCanvass(dbOP,request,strInfoIndex);
				if(vReqItems == null)
					strErrMsg = CAN.getErrMsg();
				else
					strErrMsg = "Operation Successful.";
			}
			vReqCanvass = CAN.getCanvassInfo(dbOP,strInfoIndex);
			if(vReqCanvass == null)
				strErrMsg = CAN.getErrMsg();
			else if(vReqCanvass.size() > 0){
				bolIsInCanvass = true;
				strCanvassNo = (String)vReqCanvass.elementAt(0);
				strCanvassDate = (String)vReqCanvass.elementAt(1);
			}
				
				
			vReqItems = REQ.operateOnReqItems(dbOP,request,5);
			if(vReqItems == null)
				strErrMsg = REQ.getErrMsg();
		}
	}
%>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<form name="form_" method="post" action="./print_canvassing.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          CANVASSING - PRINT REQUISITION FOR CANVASSING PAGE ::::</strong></font></div></td>
    </tr>	
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>	
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="28%">Requisition No. :</td>
      <td width="25%"> 
	  <%if(WI.fillTextValue("req_no").length() > 0){
	  		strTemp = WI.fillTextValue("req_no");
	  }else{
	  		strTemp = "";
      }%> <input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td width="44%">
	   <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a><font size="1">click to search requisition no.</font></td>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">
	  <%if(bolIsInCanvass){%>
	  <a href="../quotation/quotation_encode.jsp?proceedClicked=1&req_no=<%=strCanvassNo%>">Click here to encode Quotation</a>
	  <%}%>&nbsp;	  
	  </td>
      <td height="25" colspan="2"><a href="javascript:ProceedClicked();"> <img src="../../../images/form_proceed.gif" border="0"></a><a href="javascript:OpenSearchPO();"> </a></td>
    </tr>
    <%if(bolIsInCanvass){%>
    <tr> 
      <td height="25"> 
      <td>Canvassing No.: <strong><%=strCanvassNo%></strong></td>
      <td colspan="2">Canvassing Date : <strong><%=strCanvassDate%></strong>      </td>
    </tr>    
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>
	<%}%>
  </table>
  <%if(vReqInfo != null && vReqInfo.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS </strong></div></td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="28%"><strong><%=(String)vReqInfo.elementAt(12)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"> <strong><%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(1))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vReqInfo.elementAt(5)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(10))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(7)%></strong></td>
    </tr>
	<%if(((String)vReqInfo.elementAt(3)).equals("0")){%> 
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Non-Acad. Office/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></strong></td>
    </tr>
	<%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)+"/"+WI.getStrValue((String)vReqInfo.elementAt(9),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></strong></td>
    </tr>
	<%}%>	
  </table>
    <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25"><%if(bolIsInCanvass){%>
        <a href="print_canvassing2.jsp?proceedClicked=1&req_no=<%=WI.fillTextValue("req_no")%>">Click here for suppliers format</a>
        <%}%></td>
    </tr>
  </table>
  <%if(bolIsInCanvass){%>
  <%}if(vReqItems != null && vReqItems.size() > 3){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <%if(bolIsInCanvass){%>
    <%}else if(WI.fillTextValue("is_supply").equals("0") && !bolIsInCanvass){%>
    <tr> 
      <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF REQUESTED ITEMS</strong></font></div></td>
    </tr>
    <%}else{%>
    <tr> 
      <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF REQUESTED SUPPLIES</strong></font></div></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td height="25" colspan="9" class="thinborder">Requested by : <strong><%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <tr align="center" style="font-weight:bold">
      <td width="4%" class="thinborder">PRINT</td> 
      <td width="5%" height="25" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong>QUANTITY</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>ITEM</strong></div></td>
      <td width="23%" class="thinborder"><div align="center"><strong>PARTICULARS/ITEM DESCRIPTION </strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>SUPPLIER</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
    </tr>
    <%
	int iCount = 0;
	for(int iLoop = 2;iLoop < vReqItems.size();iLoop+=9){%>
	<tr>
	  <td class="thinborder" align="center"><input type="checkbox" name="_item<%=iCount++%>" value="<%=(String)vReqItems.elementAt(iLoop)%>"></td> 
      <td height="25" class="thinborder"><div align="center"><%=iCount%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vReqItems.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+3)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+4)%></div></td>	  
	  <td class="thinborder"><div align="left"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+5),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+6),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right">
	  	<%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
	 		&nbsp;
		<%}else{%>
			<%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%>
		<%}%></div></td>
    </tr>
	<%}%>
	<input type="hidden" name="max_disp" value="<%=iCount%>">
    <tr> 
      <td class="thinborder" height="25" colspan="6">
	  <div align="left"><strong>TOTAL ITEM(S) : <%=vReqItems.elementAt(0)%></strong></div></td>
      <td class="thinborder" height="25" colspan="2"><div align="right"><strong>TOTAL AMOUNT : </strong></div></td>
      <td class="thinborder" height="25"><div align="right"><strong><%=vReqItems.elementAt(1)%></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" style="font-size:9px; font-weight:bold; color:#0000FF">Note: Select Print Check box to print only selected Items in canvass form</td>
    </tr>
  </table>
  <%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <%if(!bolIsInCanvass && vReqItems != null && vReqItems.size() > 3){%>
	<tr>
      <td height="25"><div align="center"> <a href="javascript:SaveClicked();"><img src="../../../images/save.gif" border="0"> 
          </a> <font size="1">click to SAVE Requisition for Canvassing </font> 
          <a href="javascript:CancelClicked();"> <img src="../../../images/cancel.gif" border="0"> 
          </a> <font size="1">click to cancel</font></div></td>
    </tr>
    <%}else if(bolIsInCanvass && vReqItems != null && vReqItems.size() > 3){%>
	<tr> 
      <td height="25"><div align="center">          
	     <%if (!strSchCode.startsWith("UI")){%>
          <font size="1">Items per page</font> 
          <select name="num_rows">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rows"),"15"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <%}else{%>
          <input type="hidden" name="num_rows" value="15">
          <%}%>
		  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to PRINT Requisition for Canvassing</font></div></td>
    </tr>
	<%}%>
  </table>
  <%}%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="is_supply" value="<%=WI.fillTextValue("is_supply")%>">
  <input type="hidden" name="page_action" value="<%=WI.fillTextValue("pageAction")%>">
  <input type="hidden" name="info_index" value="<%=strInfoIndex%>">
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="save_clicked" value="">  
  <input type="hidden" name="print_pg" value="">
  <input type="hidden" name="is_canvass" value="1">
  <input type="hidden" name="canvass_no" value="<%=strCanvassNo%>">
  <input type="hidden" name="canvass_date" value="<%=strCanvassDate%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
