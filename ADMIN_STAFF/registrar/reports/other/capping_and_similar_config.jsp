<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/td.js"></script>
<script language="JavaScript">
function AddSubList() {
	var strPgLoc = "./capping_and_similar_config_slist.jsp";
	var win=window.open(strPgLoc,"myfile",'dependent=no,width=700,height=500,top=5,left=5,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
}
function PreparedToEdit(strInfoIndex) {
	document.form_.preparedToEdit.value = "1";
	document.form_.page_action.value = '';
	document.form_.info_index.value = strInfoIndex;
}
function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else
		objBranch.display="block";
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportRegistrarExtn,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Reports-Others","capping_and_similar_config.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"),"0");
ReportRegistrarExtn rR = new ReportRegistrarExtn();
Vector vRetResult  = null;
Vector vEditInfo   = null;

String strPageAction = WI.fillTextValue("page_action");
if(strPageAction.length() > 0) {
	if(rR.operateOnCappingConfig(dbOP, request, Integer.parseInt(strPageAction)) == null) {
		strErrMsg = rR.getErrMsg();
	}
	else {
		strErrMsg = "Operation successful.";
		strPreparedToEdit = "";
	} 
}
if(strPreparedToEdit.equals("1")) {
	vEditInfo = rR.operateOnCappingConfig(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = rR.getErrMsg();
}
vRetResult = rR.operateOnCappingConfig(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = rR.getErrMsg();

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>

<form name="form_" action="./capping_and_similar_config.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>:::: 
        REPORT CONFIGURATION PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" >
	  <a href="./capping_and_similar_report.jsp"><img src="../../../../images/go_back.gif" border="0"></a>
	  &nbsp;&nbsp;
	  <strong style="font-size:14px; color:#FF0000"><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td width="19%" height="25" >Report Name </td>
      <td width="43%" >
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("report_name");
%>	  <input type="text" name="report_name" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" maxlength="64"></td>
      <td width="35%" >Manage subject equivalence 
	  <a href="javascript:AddSubList();"><img src="../../../../images/update.gif" border="0"></a></td>
    </tr>
<%
if(strSchCode.startsWith("CGH")){%>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td colspan="3" >
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("show_gwa");
if(strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>	  	<input type="checkbox" name="show_gwa" value="1"<%=strTemp%>> Show GWA
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("is_passed");
if(strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
if(request.getParameter("info_index") == null)
	strTemp = " checked";
%>        <input type="checkbox" name="is_passed" value="1"<%=strTemp%>> Show Student list Only if passed in all subjects.	  </td>
    </tr>
<%}else{%>
<input type="hidden" name="show_gwa" value="1">
<input type="hidden" name="is_passed" value="1">
<%}%>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td valign="top">List of subject <br>
      (For header only - in comma separated) </td>	  
      <td colspan="2">
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("subject_heading");
%>	  <textarea name="subject_heading" class="textbox" rows="5" cols="55"
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="3" align="center">
<%if(iAccessLevel > 1){
	if(!strPreparedToEdit.equals("1")){%>
        <input type="submit" name="1" value="<<< Save Report Type >>>" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('1', '');">
        &nbsp;&nbsp;
        <input type="submit" name="13" value=" Clear Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="document.form_.report_name.value='';document.form_.show_gwa.checked=false;document.form_.is_passed.checked=true;document.form_.subject_heading.value=''">
        <%}else{%>
        <input type="submit" name="1" value="Edit Information" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('2', '');">
        &nbsp;&nbsp;
		<input type="submit" name="13" value=" Cancel Edit " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="document.form_.report_name.value='';document.form_.show_gwa.checked=false;document.form_.is_passed.checked=true;document.form_.subject_heading.value='';document.form_.preparedToEdit.value=''">
	<%}%>
<%}%>      </td>
    </tr>
<%if(strSchCode.startsWith("CGH")){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="3" valign="top">
		<div class="trigger" onClick="showBranch('branch1');">   
		  <img src="../../../../images/online_help.gif" border="0"></a> Click me to learn how to configure. !!!		</div>		  </td>
    </tr>
    <tr bgcolor="#FFFFFF"><td height="25" >&nbsp;</td><td colspan="3" valign="top">

<span class="branch" id="branch1">
	<table bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
      <tr>
	  	<td height="25" >&nbsp;</td>
      	<td colspan="2" valign="top">
	  	<strong>Report Name :</strong> Enter here report name for example : Capping , Pinning etc.
		<br>
		<strong>List of Subject(For Header only) :</strong> Enter here all the subjects to be displayed in report. <strong>for eaxample</strong> you want to view all the students passed in Math 1, English 1, Physics. 
		<br>
		1. Enter Report name, and check if you want to show GWA and check the option show all student list only if passed in all subjects.<br>
		2. Enter in List of Subjects (Header only) : Math 1, English 1, Physics <br>
		3. Save this report<br>
	  	4. Click add subject to list in the report list - This is where you will add the subjects under each heading. For example, Math 1 subject are Math 1a, Math 1 and Math 1b (this may happen if you have old subject code for a subject), then enter those 3 subjects in comma separated value -> Math 1, Math 1a, Math 1b in add subject to list operation. <br>
	  <strong>NOTE :</strong> Incase system does not find any subject in system, you will remove error message of failure.	  </td>
    </tr></table>
</span> </td>   
	</tr>
<%}%>  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
		<tr style="font-weight:bold">
		  <td width="20%" height="25" class="thinborder">&nbsp;Report Name</td>
		  <td width="40%" class="thinborder">Subject Heading</td>
		  <td width="8%" class="thinborder">Subject Equiv. </td>
		  <td width="8%" class="thinborder">Show GWA</td>
		  <td width="8%" class="thinborder">Show pass only</td>
		  <td width="8%" class="thinborder">Edit</td>
		  <td width="8%" class="thinborder">Delete</td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 8) {%>
		<tr>
		  <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
		  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
		  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%></td>
		  <td class="thinborder">&nbsp;
		  <%if(vRetResult.elementAt(i + 2).equals("1")){%><img src="../../../../images/tick.gif"><%}%>		  </td>
		  <td class="thinborder">&nbsp;
		  <%if(vRetResult.elementAt(i + 3).equals("1")){%><img src="../../../../images/tick.gif"><%}%>		  </td>
		  <td class="thinborder">
<%if(iAccessLevel > 1){%>
		  	<input type="submit" name="12" value=" &nbsp; Edit &nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PreparedToEdit('<%=(String)vRetResult.elementAt(i)%>');">
<%}else{%>&nbsp;<%}%>		  </td>
		  <td class="thinborder">
<%if(iAccessLevel == 2){%>
		  	<input type="submit" name="12" value="Delete" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
<%}else{%>&nbsp;<%}%>		  </td>
    	</tr>
	<%}%>
  </table>
<%}%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
