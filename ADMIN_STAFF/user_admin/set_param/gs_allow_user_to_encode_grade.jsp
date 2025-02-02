<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.messageBox {
	height: 100px; width:170px; overflow: auto; border: inset black 1px; background-color:#DDDDDD
}
</style>
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PageAction(strAction, strIndex)
{
	document.set_param.info_index.value = strIndex;
	document.set_param.page_action.value = strAction;
//	alert(document.set_param.info_index.value);
}

function ReloadPage()
{
	document.set_param.page_action.value = "";
	document.set_param.submit();
}
function ShowHideEmpID()
{
	if(document.set_param.is_for_one_faculty.checked)
		showLayer("emp_id_");
	else {
		document.set_param.emp_id.value = "";
		hideLayer("emp_id_");
	}


}
//all about ajax - to display student list with same name.
var objCOAInput;
var strIndex;
function AjaxMapName(strIn) {
		var strCompleteName = document.set_param.emp_id.value;

		strIndex = strIn;

		if(strIndex == '1')
			objCOAInput = document.getElementById("coa_info");
		else {
			objCOAInput = document.getElementById("coa_info2");
			strCompleteName = document.set_param.allow_user.value;
		}

		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	if(strIndex == '1')
		document.set_param.emp_id.value = strID;
	else
		document.set_param.allow_user.value = strID;

	objCOAInput.innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	//document.set_param.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.set_param.c_index[document.set_param.c_index.selectedIndex].value;

		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index&all=1";
		//alert(strURL);
		this.processRequest(strURL);
}
function ManageAllowedSubject() {
	var strEmpID = document.set_param.allow_user.value;
	if(strEmpID.length == 0) {
		alert("Please enter Allowed User ID.");
		return;
	}
	var pgLoc = "./gs_allow_user_to_encode_grade_subject.jsp?allow_user="+strEmpID;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.SetParameter,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Set Parameter","set_param_gs.jsp");

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
														"System Administration","Set Parameters",request.getRemoteAddr(),
														"set_param_gs.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Override Parameters","Grade sheet encoding",request.getRemoteAddr(),
															"set_param_gs.jsp");
}

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

Vector vRetResult = new Vector();
SetParameter paramGS = new SetParameter();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)//add/ delete.
{
	if(paramGS.operateOnAllowOtherUserToEncodeGrade(dbOP,request,Integer.parseInt(strTemp)) != null)
		strErrMsg = "Operation Successful.";
	else
		strErrMsg = paramGS.getErrMsg();
}
vRetResult = paramGS.operateOnAllowOtherUserToEncodeGrade(dbOP,request,4);
if(vRetResult == null)
{
	if(strErrMsg == null)
		strErrMsg = paramGS.getErrMsg();
}
%>
<form name="set_param" action="./gs_allow_user_to_encode_grade.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          SET PARAMETERS - GRADE SHEET ENCODING/SUBMISSION PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;&nbsp;<a href="./grade_setting_main.jsp"><img src="../../../images/go_back.gif" border="0"></a><font size="1">go
        to main</font>&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font>      </td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">Allow User </td>
      <td width="51%"><input name="allow_user" type="text" size="32" value="<%=WI.fillTextValue("allow_user")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(2);">&nbsp;
	  <a href="javascript:ReloadPage()"><img src="../../../images/refresh.gif" border="0"></a>
	  <label id="coa_info2"></label></td>
      <td width="29%" valign="bottom" style="font-weight:bold; font-size:11px; color:#0000FF">
	  <a href="javascript:ManageAllowedSubject();">Manage Allowed Subject</a>
	  </td>
    </tr>
    <!--    <tr>
      <td height="25">&nbsp;</td>
      <td width="15%"><div align="right">From&nbsp;</div></td>
      <td width="78%"><input name="from_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("from_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('set_param.from_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
      </td>
    </tr>
-->
    <tr>
      <td height="25">&nbsp;</td>
      <td>Specific College </td>
      <td>
	  <select name="c_index" onChange="loadDept();">
	  <option value="">All</option>
	  <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", WI.fillTextValue("c_index"), false)%>
	  </select>	  </td>
      <td rowspan="4" valign="top">
		<div class="messageBox" id="div_msgBox">
	  
	  	</div>
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Specific Department </td>
      <td style="font-size:9px;">

<label id="load_dept">
<%if(WI.fillTextValue("c_index").length() > 0) {%>
	  <select name="d_index">
          <option value="">All</option>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index = "+WI.fillTextValue("c_index")+" order by d_name asc",WI.fillTextValue("d_index"), false)%>
        </select>
<%}%>
</label>	  </td>
    </tr>
    <%
if( iAccessLevel >1){%>
    <tr valign="top">
      <td height="25">&nbsp;</td>
      <td>Specific Faculty</td>
      <td><input name="emp_id" type="text" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
	  <label id="coa_info"></label>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><input type="image" src="../../../images/save.gif" onClick='PageAction(1,"");'>
        <font size="1">click to save new grade sheet submission time</font></td>
    </tr>
    <%}%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr bgcolor="#B9B292">
      <td height="25" div align="center" style="font-weight:bold; color:#FFFFFF">LIST OF AUTHORIZED USERS TO ENCODE OTHER FACULTIES GRADE</div></td>
    </tr>
</table>


  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold" align="center">
      <td width="20%" height="25" class="thinborder"><font size="1">Authorized Employee</font></td>
      <td width="23%" class="thinborder"><font size="1"> College</font> </td>
      <td width="27%" class="thinborder"><font size="1">Department</font></td>
      <td width="27%" class="thinborder"><font size="1">Specific Employee</font></td>
      <td width="28%" class="thinborder"><font size="1">Delete</font></td>
    </tr>
    <%
String strCollege = null;
String strDept    = null;
String strFaculty = null;

for(int i =0;i< vRetResult.size(); i +=7){
strCollege = (String)vRetResult.elementAt(i + 3);
strDept    = (String)vRetResult.elementAt(i + 4);
strFaculty = (String)vRetResult.elementAt(i + 5);
//System.out.println("who is faculty : "+strFaculty);
if(strCollege == null && strDept == null && strFaculty == null) {
	strCollege = "- ALL - ";
	strDept    = "- ALL - ";
	strFaculty = "- ALL - ";
}
else if(strFaculty != null) {
	strFaculty = (String)vRetResult.elementAt(i + 6)+" ("+strFaculty+")";
	strCollege = "&nbsp;";
	strDept    = "&nbsp;";
}
else {
	if(strDept == null)
		strDept = " ALL ";
	if(strCollege == null)
		strCollege = "&nbsp;";
	strFaculty = "&nbsp;";
}

%>
    <tr>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%>(<%=(String)vRetResult.elementAt(i+1)%>)</td>
      <td class="thinborder"><%=strCollege%></td>
      <td class="thinborder"><%=strDept%></td>
      <td class="thinborder"><%=strFaculty%></td>
      <td class="thinborder" align="center">
        <%
	if( iAccessLevel >1){%>
        <input type="image" onClick='PageAction(0,<%=(String)vRetResult.elementAt(i)%>);' src="../../../images/delete.gif">
        <%}else{%>
        Not Allowed to delete
        <%}%>      </td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
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
