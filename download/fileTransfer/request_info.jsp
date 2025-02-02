<%@ page language="java" import="utility.*,purchasing.Requisition,inventory.InventoryMaintenance,java.util.Vector" %>
<%  
    WebInterface WI = new WebInterface(request);
	///added code for school/companies.
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
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.pageAction.value = "";
	document.form_.forwardTo.value = "";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{		
    document.form_.forwardTo.value = "";
	document.form_.printPage.value = "";
	document.form_.pageReloaded.value = "1";
	document.form_.pageAction.value = "1";	
	this.SubmitOnce('form_');
}
function PageAction(strAction,strIndex){
	document.form_.pageAction.value = "";
	document.form_.forwardTo.value = "";
	document.form_.printPage.value = "";
	if(strAction == 0){
		var vProceed = confirm('Delete this requisition?');
		if(vProceed){
			document.form_.pageAction.value = strAction;
			document.form_.strIndex.value = strIndex;
			this.SubmitOnce('form_');
		}
	}
	else{
		document.form_.pageAction.value = strAction;
		document.form_.strIndex.value = strIndex;
		this.SubmitOnce('form_');	
	}
} 
function ForwardTo(){
	document.form_.forwardTo.value = "1";
	document.form_.pageAction.value = "";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
    document.form_.forwardTo.value = "";
	document.form_.pageAction.value = "";
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
function OpenSearch(){
	document.form_.printPage.value = "";
	var pgLoc = "request_view_search.jsp?opner_info=form_.req_no"+
							"&my_home="+document.form_.my_home.value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageLoad(){
 	document.form_.req_no.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<%	
	String strTemp = null;
	boolean bolMyHome = false;	
	
	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;
	 if(WI.fillTextValue("forwardTo").equals("1")){%>
			<jsp:forward page="request_item.jsp"/>
	<%return;}
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null) 
		strSchCode = "";
		
   if(WI.fillTextValue("printPage").equals("1")){
		if(strSchCode.startsWith("AUF")){%>
			<jsp:forward page="req_item_print_auf.jsp"/>
		<%}else{%>
			<jsp:forward page="request_item_print.jsp"/>
	<%return;} }

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-REQUISITION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}

strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){//for my home, request items... i doubt someone will look at this anyway... hehehe
			iAccessLevel  = 2;	
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
DBOperation dbOP = null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-REQUISITION-Requisition Info","central_req_info.jsp");
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
	InventoryMaintenance InvMaint = new InventoryMaintenance();
	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vRetResult = null;
	Vector vEmpDetails = null;
	String strErrMsg = null;	
	String strTemp2 = null;
	String strCIndex = null;
	String strDIndex = null;
	String strReqName = null;
	int iDefault = 0;
	String strEmpDIndex = null;
	
	if(WI.fillTextValue("proceedClicked").equals("1")){	
		if(WI.fillTextValue("pageAction").length() > 0 && !(WI.fillTextValue("pageReloaded").equals("1"))){
			vRetResult = InvMaint.operateOnTransferReqInfo(dbOP,request,Integer.parseInt(WI.fillTextValue("pageAction")));	
			if(vRetResult == null)
				strErrMsg = InvMaint.getErrMsg();
			else
				strErrMsg = "Operation successful";								
		}		
		if(vRetResult != null && vRetResult.size() > 0)
			vReqInfo = InvMaint.operateOnTransferReqInfo(dbOP,request,3,(String)vRetResult.elementAt(0));
		else
			vReqInfo = InvMaint.operateOnTransferReqInfo(dbOP,request,3);
		if(vReqInfo == null && WI.fillTextValue("req_no").length() > 0
							&& WI.fillTextValue("pageAction").length() < 1)
			strErrMsg = InvMaint.getErrMsg();
			
		vReqItems = InvMaint.operateOnTransferReqItems(dbOP,request,4);		
		
		if(bolMyHome){
			vEmpDetails = REQ.getEmployeeDetail(dbOP,request);
			if(vEmpDetails != null && vEmpDetails.size() > 0){
			  strCIndex = (String)vEmpDetails.elementAt(4);	
			  strEmpDIndex = (String)vEmpDetails.elementAt(5);
			  strReqName = WI.formatName((String)vEmpDetails.elementAt(1),(String)vEmpDetails.elementAt(2),
			  							(String)vEmpDetails.elementAt(3),4);
			}
		}
	}		
%>
<form name="form_" method="post" action="request_info.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">    
	  <tr bgcolor="#A49A6A">	  
	  <td height="25" colspan="3" align="center" bgcolor="#A49A6A"><font color="#FFFFFF"><strong>:::: 
      ITEM TRANSFER REQUEST PAGE ::::</strong></font></td>
	  </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="69%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%>        
        </font></strong></td>
      <td width="31%">
        <div align="center">
          <%if((vReqInfo != null && vReqInfo.size() > 0) || (vRetResult != null && vRetResult.size() > 0)){%>
          <a href="javascript:ForwardTo();"><font size="2">Click to add requisition 
            items</font></a> 
          <%}%>
        </div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="21%">Requisition No.</td>
      <td><strong>
	  <%if(WI.fillTextValue("pageAction").equals("1") && vRetResult != null)
	  		strTemp = (String)vRetResult.elementAt(0);
	    else if(WI.fillTextValue("req_no").length() > 0)
	  		strTemp = WI.fillTextValue("req_no");
	  	else
			strTemp = "";
	  %>
        <input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong>&nbsp; 
		<a href="javascript:OpenSearch();">
		<img src="../../../images/search.gif" border="0"></a>
		<a href="javascript:ProceedClicked();"> <img src="../../../images/form_proceed.gif" border="0"> 
        </a></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">
			NOTE: <br>
        1. To create new requisition, click proceed. New requisition number will 
        be given after clicking SAVE.<br>
        2. To edit requisition information, enter old requisition number and click 
        proceed. </td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%if(WI.fillTextValue("proceedClicked").equals("1")){
  //if(!bolMyHome){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
    <tr bgcolor="#C78D8D">
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2"><strong><font color="#FFFFFF">ITEM SOURCE LOCATION </font></strong></td>
    </tr>
		<!--
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="21%">College</td>
			<%
		//	if(vReqInfo != null && vReqInfo.size() > 1 && !(WI.fillTextValue("pageReloaded").equals("1")))
		//		strCIndex = (String)vReqInfo.elementAt(1);
		//	else if(WI.fillTextValue("c_index_fr").length() > 0)
		//		strCIndex = WI.fillTextValue("c_index_fr");
		//	else
		//		strCIndex = "0";			
			%>
      <td width="76%">
			<select name="c_index_fr" onChange="ReloadPage();">
        <option value="0">N/A</option>
        <%//=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strCIndex, false)%>
      </select></td>
    </tr>
		-->
		<input type="hidden" name="c_index_fr" value="0">
    <tr> 
      <td height="29">&nbsp;</td>
      <td width="21%">Department</td>
			<%			
			if(vReqInfo != null && vReqInfo.size() > 0 && !(WI.fillTextValue("pageReloaded").equals("1")))
				strDIndex = (String)vReqInfo.elementAt(2);
			else
				strDIndex = WI.fillTextValue("d_index_fr");			
			%>			
      <td width="76%" height="29">
        <select name="d_index_fr">
				<option value="0">Select Office</option>
        <%=dbOP.loadCombo("d_index","d_NAME"," from department where (c_index = 0 or c_index is null)" +
													" and is_del = 0 and is_central_office = 1 order by d_name asc",strDIndex, false)%>
      </select></td>
    </tr>
	  <tr>
	    <td height="17" colspan="3"><hr size="1"></td>
    </tr>
  </table>
	<%//}// end my home%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
	<%if(!bolMyHome){%>
	  <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="21%">Requested By </td>
      <td colspan="3"> 
			<% if(vReqInfo != null && vReqInfo.size() > 1 && !(WI.fillTextValue("pageReloaded").equals("1")))
	   	  	strTemp = (String)vReqInfo.elementAt(9);
		  	else if(WI.fillTextValue("requested_by").length() > 0)
					strTemp = WI.fillTextValue("requested_by");
				else
					strTemp = "";		
		%> <input name="requested_by" type="text" size="50" class="textbox" value="<%=strTemp%>"
	     onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
			<%
			if(vReqInfo != null && vReqInfo.size() > 1 && !(WI.fillTextValue("pageReloaded").equals("1")))
				strCIndex = (String)vReqInfo.elementAt(5);
			else if(WI.fillTextValue("c_index").length() > 0)
				strCIndex = WI.fillTextValue("c_index");
			else
				strCIndex = "0";			
				
			%>			
      <td colspan="3"><select name="c_index" onChange="ReloadPage();">
        <option value="0">N/A</option>
        <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strCIndex, false)%>
      </select></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td>Department</td>
			<%			
			if(vReqInfo != null && vReqInfo.size() > 0 && !(WI.fillTextValue("pageReloaded").equals("1")))
				strDIndex = (String)vReqInfo.elementAt(6);
			else
				strDIndex = WI.fillTextValue("d_index");			
			%>			
      <td height="29"><select name="d_index">
        <% if(strCIndex != null && strCIndex.compareTo("0") != 0){%>
        <option value="">All</option>
        <%}else{%>
        <option value="0">Select Office</option>
        <%}%>
        <%if (strCIndex == null || strCIndex.length() == 0 || strCIndex.compareTo("0") == 0) 
						strCIndex = " and (c_index = 0 or c_index is null) ";
					else strCIndex = " and c_index = " +  strCIndex;
				%>
        <%=dbOP.loadCombo("d_index","d_NAME"," from department where is_del = 0 " + strCIndex + 
													" order by d_name asc",strDIndex, false)%>
      </select></td>
    </tr>
	<%}// end of my home calling
	else{%>
		<input type="hidden" name="c_index" value="<%=strCIndex%>">
		<input type="hidden" name="d_index" value="<%=WI.getStrValue(strEmpDIndex)%>">
		<input type="hidden" name="requested_by" value="<%=strReqName%>">
	<%}%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td valign="top">Purpose/Job</td>
      <td colspan="3"> <%if(vReqInfo != null && vReqInfo.size() > 1 && !(WI.fillTextValue("pageReloaded").equals("1")))
	  		strTemp = (String)vReqInfo.elementAt(10);
	    else if(WI.fillTextValue("purpose").length() > 0)
	  		strTemp = WI.fillTextValue("purpose");
		else
			strTemp = "";
	  	%> <textarea name="purpose" cols="40" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Date Needed</td>
      <td colspan="3"> <%if(vReqInfo != null && vReqInfo.size() > 1 && !(WI.fillTextValue("pageReloaded").equals("1")))  	
			strTemp = WI.getStrValue((String)vReqInfo.elementAt(11));
	  	 else if(WI.fillTextValue("date_needed").length() > 0)
	  		strTemp = WI.fillTextValue("date_needed");
		 else
			strTemp = "";
	  %> <input name="date_needed" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_needed');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>	
    <%if(vReqInfo == null){%>
    <tr> 
      <td height="30" colspan="4"><div align="center"><a href="javascript:PageAction(1,0);"><img src="../../../images/save.gif" border="0"></a> 
          <font size="1" >click to save entry</font></div></td>
    </tr>
    <%}else{%>
    <tr> 
      <td width="3%" height="30">&nbsp;</td>
      <td width="12%">&nbsp;</td>
      <td width="85%" colspan="2"> <a href="javascript:PageAction(2,<%=(String)vReqInfo.elementAt(0)%>)"> 
        <img src="../../../images/edit.gif" border="0"></a> <font size="1">click 
        to save changes</font> <a href="javascript:ProceedClicked();"> <img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1">click to cancel edit</font> <a href="javascript:PageAction(0,<%=(String)vReqInfo.elementAt(0)%>)"> 
        <img src="../../../images/delete.gif" border="0"></a> <font size="1">click 
        to delete this requisition</font> </td>
    </tr>
    <%}%>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2"><div align="right"> 
          <%
		  if(vReqItems != null && (vReqInfo != null && vReqInfo.size() > 0)){%>
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
          <a href="javascript:PrintPage();"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print Requisition Form</font> 
          <%}// end if vReqItems != null%>
        </div></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <%if(vReqItems != null && vReqInfo != null){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST OF REQUESTED SUPPLIES</strong></font></div></td>
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
      <td class="thinborder" height="25" colspan="4"><strong>TOTAL ITEM(S) : <%=iCountItem%></strong></td>
    </tr>
  </table>
<%}
}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>    
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="pageAction" value="<%=WI.fillTextValue("pageAction")%>">
  <input type="hidden" name="strIndex" value="<%=WI.fillTextValue("strIndex")%>">
  <input type="hidden" name="forwardTo" value="">
  <input type="hidden" name="pageReloaded" value="">
  <input type="hidden" name="printPage" value="">
  <input type="hidden" name="request_stage" value="1">
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
