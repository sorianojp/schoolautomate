<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage(strInfoIndex, strNewStatus)
{
	document.form_.info_index.value = strInfoIndex;
	document.form_.new_stat.value = strNewStatus;
	document.form_.submit();
}
function OpenSearch(strIDInfo) {
	var pgLoc = "../../search/srch_stud.jsp?opner_info=form_.stud_id";
		
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 3) {
			document.getElementById("coa_info").innerHTML = "";
			return;
		}
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
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

<body bgcolor="#D2AE72" onLoad="javascript:document.form_.stud_id.focus();document.form_.stud_id.select();">
<%@ page language="java" import="utility.*,student.ChangeCriticalInfo,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	Vector vStudInfo = null;
	
	String strTemp = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Student Info Mgmt","change_stud_critical_info_regular.jsp");
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
														"Admission","Student Info Mgmt",request.getRemoteAddr(),
														"change_stud_critical_info_regular.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
ChangeCriticalInfo changeInfo = new ChangeCriticalInfo();

if(WI.fillTextValue("info_index").length() > 0) {//Modify status.
	//execute query.
	String strSQLQuery = "update stud_curriculum_hist set COURSE_REGULARITY_STAT="+
		WI.fillTextValue("new_stat")+" where cur_hist_index = "+WI.fillTextValue("info_index");
	if(dbOP.executeUpdateWithTrans(strSQLQuery,null,null,false) == -1)
		strErrMsg = "Error in updating regularlity status.";	
	else	
		strErrMsg = "Status updated successfully.";
}
vStudInfo = changeInfo.getStudentRegularityInfo(dbOP,WI.fillTextValue("stud_id"));
if(vStudInfo == null)
	strErrMsg  = changeInfo.getErrMsg();

dbOP.cleanUP();
String[] astrConvertToSem={"Summer","1st Sem","2nd Sem","3rd Sem"};
String[] astrConvertToYr = {"","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr"};
%>
<form action="./change_stud_critical_info_regular.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          STUDENT REGULARITY STATUS INFORMATION UPDATE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%"></td>
	  <td width="98%" > <strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="13%" >Student ID :</td>
      <td width="23%" ><input type="text" name="stud_id" size="18" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
      <td width="8%" height="25"><!--<a href="javascript:OpenSearch()">Search ID</a>&nbsp;-->
	  <input type="image" src="../../images/form_proceed.gif"></td>
      <td width="54%"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%" >Name: </td>
      <td colspan="3" ><%=(String)vStudInfo.elementAt(0)%></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td >&nbsp;</td>
      <td width="26%">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td><strong>SY - TERM</strong></td>
      <td width="25%"><strong>REGULARITY STATUS </strong></td>
      <td width="32%"><strong>MODIFY STATUS </strong></td>
    </tr>
<%
for(int i = 1; i< vStudInfo.size() ;i +=6){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td><%=(String)vStudInfo.elementAt(i)%> - <%=(String)vStudInfo.elementAt(i+1)%> - 
	  <%=astrConvertToSem[Integer.parseInt((String)vStudInfo.elementAt(i+2))]%></td>
      <td><%=(String)vStudInfo.elementAt(i+3)%></td>
      <td><a href='javascript:ReloadPage("<%=(String)vStudInfo.elementAt(i + 5)%>", "<%=vStudInfo.elementAt(i + 4)%>");'>
	  <img src="../../images/edit.gif" border="0"></a>
	  </td>
    </tr>
<%}%>
  </table>
<%}//only if student information is not null. %>
 
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="79%" height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="">
<input type="hidden" name="new_stat">
</form>
</body>
</html>
