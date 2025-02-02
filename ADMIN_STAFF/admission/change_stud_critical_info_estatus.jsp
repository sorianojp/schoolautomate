<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Change Student Entry Status</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript">
function AddRecord()
{
	document.offlineRegd.addRecord.value = "1";
	document.offlineRegd.submit();
}
function OpenSearch(strIDInfo) {
	var pgLoc = "../../search/srch_stud.jsp?opner_info=offlineRegd.stud_id";
		
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.offlineRegd.stud_id.value;
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
	document.offlineRegd.stud_id.value = strID;
	document.offlineRegd.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.offlineRegd.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>

<body bgcolor="#D2AE72" onLoad="document.offlineRegd.stud_id.focus()">
<%@ page language="java" import="utility.*,student.ChangeCriticalInfo,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	Vector vStudInfo = null;
	String strTemp = "";
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Student Info Mgmt","create_old_stud_basicinfo.jsp");
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
														"create_old_stud_basicinfo.jsp");
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
if(strErrMsg == null && WI.fillTextValue("addRecord").compareTo("1") ==0)
{
	if(!changeInfo.changeStudentEntryStatus(dbOP,WI.fillTextValue("stud_index"),WI.fillTextValue("entry_status"),
								(String)request.getSession(false).getAttribute("login_log_index")) )
		strErrMsg = changeInfo.getErrMsg();
	else
		strErrMsg = "Student Status successfully changed.";
}
vStudInfo = changeInfo.getStudentEntryInfo(dbOP,WI.fillTextValue("stud_id"));
if(vStudInfo == null)
	strErrMsg  = changeInfo.getErrMsg();

String[] astrConvertToSem={"Summer","1st Sem","2nd Sem","3rd Sem",""};
String[] astrConvertToYr = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr"};
%>
<form action="./change_stud_critical_info_estatus.jsp" method="post" name="offlineRegd">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          STUDENT ENTRY STATUS UPDATE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%"></td>
	  <td width="98%" height="25">
	<strong><%=WI.getStrValue(strErrMsg)%></strong>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr valign="top"> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="13%" height="25">Student ID :</td>
      <td width="23%" height="25"><input type="text" name="stud_id" size="18" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
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
      <td width="15%" height="25">Name: </td>
      <td width="83%" height="25"><%=(String)vStudInfo.elementAt(1)%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Entry Status:</td>
      <td height="25"><%=(String)vStudInfo.elementAt(10)%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Course/Major: </td>
      <td height="25"><%=(String)vStudInfo.elementAt(2)%> 
	  <%if(vStudInfo.elementAt(3) != null){%>
	  <%=(String)vStudInfo.elementAt(3)%>
	  <%}%>
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">School Year/Term: </td>
      <td height="25"><%=(String)vStudInfo.elementAt(6)%> - <%=(String)vStudInfo.elementAt(7)%> 
        (<%=astrConvertToSem[Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(8),"4"))]%>)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Year Level: </td>
      <td height="25">
<% if (Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(9), "0")) < 8) {%>  	  
	  <%=astrConvertToYr[Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(9),"0"))]%>
<%}%> 	  
	  </td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">New Status: </td>
      <td height="25">
	  <%
		  if (strSchCode.startsWith("CPU")){
			strTemp =" and status <>'balik-aral' and status <>'semi regular'";
		  }else{
		  	strTemp = "";
		  }
	  %>
	  <select name="entry_status">
          <%=dbOP.loadCombo("status_index","status"," from user_status where status <> 'old' and status <> 'Change Course' "+  strTemp +" and is_for_student = 1 order by status asc", 
					WI.fillTextValue("entry_status"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">
        <%
	  if(iAccessLevel > 1){%>
        <a href="javascript:AddRecord();"><img src="../../images/save.gif" border="0"></a>
        <font size="1" >Click to change Student's Entry Status</font> 
        <%}else{%>
        Not authorized to modify student's ID 
        <%}%>
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%}%>
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
<input type="hidden" name="addRecord" value="0">
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>
<input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>">
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
