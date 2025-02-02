<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script language="javascript" src ="../../../jscript/date-picker.js" ></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.page_action.value = '';
	document.form_.submit();
}
function PageAction(strInfoIndex, strAction) {
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete this entry.'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.page_action.value="";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

</script>

<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus();">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenanceVairable,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	//String[] astrConvertSem ={"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Payments-ASSESSMENT-remove_late_fine","remove_late_fine.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","ASSESSMENT",request.getRemoteAddr(),
														"remove_late_fine.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
boolean bolIsAuthorized = true;
Vector vRetResult = null;
	
FAFeeMaintenanceVairable ffmv = new FAFeeMaintenanceVairable();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(ffmv.operateOnRemoveLateEnrlFine(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = ffmv.getErrMsg();
	else	
		strErrMsg = "Operation is successful.";
}
vRetResult = ffmv.operateOnRemoveLateEnrlFine(dbOP, request, 4);





%>


<form name="form_" action="./remove_late_fine.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: REMOVE LATE FINE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="28" width="2%">&nbsp;</td>
      <td colspan="3"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>School Year : </td>
      <td colspan="2"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>
        <input type="button" name="_" value="Refresh Page" onClick="document.form_.page_action.value='';document.form_.submit();"></td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="13%">Student ID</td>
      <td width="20%"> <input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');"></td>
      <td><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Reason</td>
      <td colspan="2">
	  <input name="reason_" type="text" size="70" value="" autocomplete="off"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" class="textbox">
	  </td>
    </tr>
    
    <tr>
      <td height="25" valign="bottom">&nbsp;</td>
      <td colspan="3" ><a href='javascript:PageAction("","1");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> <font size="1">click to save exception.</font></td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;</td>
      <td >&nbsp;</td>
      <td  colspan="2" >&nbsp;</td>
    </tr>
  </table>

<%if(vRetResult != null && vRetResult.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold" bgcolor="#CCCCCC">
      <td width="3%" class="thinborder"><font size="1">Count</font></td>
      <td width="12%" height="22" class="thinborder"><font size="1">ID Number</font></td>
      <td width="15%" class="thinborder"><font size="1">Student Name</font></td>
      <td width="35%" class="thinborder"><font size="1">Update Reason </font></td>
      <td width="12%" class="thinborder"><font size="1">Created By</font></td>
      <td width="8%" class="thinborder"><font size="1">Remove</font></td>
    </tr>
    <%
	for(int i = 0 ; i < vRetResult.size(); i += 8){	%>
    <tr>
      <td class="thinborder"><%=vRetResult.size()/8%>. </td>
      <td height="22" class="thinborder"><%=vRetResult.elementAt(i + 2)%> </td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"> 
	  <% if(iAccessLevel == 2){%> 
	  		<a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'><img src="../../../images/delete.gif" border="0"></a> 
		<%}%>	  </td>
    </tr>
    <%}%>
  </table>
<%}//end of display if vRetResult > 0%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
