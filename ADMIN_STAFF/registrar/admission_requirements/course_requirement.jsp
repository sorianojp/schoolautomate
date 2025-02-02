<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrepareToEdit(strInfoIndex)
{
	document.course_requirement.info_index.value = strInfoIndex;
	document.course_requirement.prepareToEdit.value = "1";
	this.SubmitOnce("course_requirement");
}
function PageAction(strAction,strInfoIndex)
{
	document.course_requirement.page_action.value=strAction;
	if(strInfoIndex.length > 0)
		document.course_requirement.info_index.value = strInfoIndex;
	this.SubmitOnce("course_requirement");
}
function ReloadPage()
{
	document.course_requirement.reloadPage.value="1";
	this.SubmitOnce("course_requirement");
}
function CancelRecord() 
{
	document.course_requirement.info_index.value = "";
	document.course_requirement.prepareToEdit.value = "0";
	this.SubmitOnce("course_requirement");
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CourseRequirement,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit=WI.fillTextValue("prepareToEdit");
	if(strPrepareToEdit.length() == 0 ) strPrepareToEdit="0";

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar-admission requirement","course_requirement.jsp");
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
														"Registrar Management","ADMISSION REQUIREMENTS",request.getRemoteAddr(),
														"course_requirement.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

CourseRequirement cRequirement = new CourseRequirement();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)
{
	if(cRequirement.operateOnRequirement(dbOP,request,Integer.parseInt(strTemp)) != null) {
		strErrMsg = "Operation successful";
		strPrepareToEdit = "0";
	}
	else	
		strErrMsg = cRequirement.getErrMsg();
}

//get all levels created.
Vector vRetResult = null;
Vector vEditInfo = null;
boolean bolShowEditInfo = false; // only if get the values from edit info. 

if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = cRequirement.operateOnRequirement(dbOP,request,3);
	if(vEditInfo == null)
		strErrMsg = cRequirement.getErrMsg();
}
vRetResult = cRequirement.operateOnRequirement(dbOP,request,4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = cRequirement.getErrMsg();

if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || 
    request.getParameter("reloadPage").compareTo("0") == 0))
	bolShowEditInfo = true;

%>
<form name="course_requirement" action="./course_requirement.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          COURSE REQUIREMENT MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%">School year </td>
      <td width="30%"> 
<% 
if(bolShowEditInfo)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("course_requirement","sy_from","sy_to")'>
        to 
        <%
if(bolShowEditInfo)
	strTemp = (String)vEditInfo.elementAt(5);
else
	strTemp = request.getParameter("sy_to");
if(strTemp == null || strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"> 
      </td>
      <td width="25%">Year level 
        <%
if(bolShowEditInfo)
	strTemp = (String)vEditInfo.elementAt(6);
else
	strTemp = WI.fillTextValue("year_level");
	%>
        <select name="year_level">
          <%if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>All</option>
          <%}else{%>
          <option value="0">All</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}if(strTemp.compareTo("7") ==0){%>
          <option value="7" selected>7th</option>
          <%}else{%>
          <option value="7">7th</option>
          <%}%>
        </select> </td>
      <td width="26%"><a href='javascript:ReloadPage();'><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td colspan="3"> 
        <%
if(bolShowEditInfo)
	strTemp = WI.getStrValue(vEditInfo.elementAt(1));
else
	strTemp = WI.fillTextValue("c_index");
	%>
        <select name="c_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name"," from College where IS_DEL=0 order by c_name asc", strTemp, false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course </td>
      <td colspan="3"> 
 <%strTemp = null;
if(WI.fillTextValue("c_index").length() > 0){
	if(bolShowEditInfo)
		strTemp = WI.getStrValue(vEditInfo.elementAt(2));
	else
		strTemp = WI.fillTextValue("course_index");
	%>
        <select name="course_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 and c_index="+
		  WI.fillTextValue("c_index") + "  order by course_name asc", strTemp, false)%> 
        </select> 
  <%}//if college is selected%>
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Major </td>
      <td colspan="3"><select name="major_index">
          <option ></option>
          <%
if(strTemp != null && strTemp.length() > 0)
{
	String strTemp2 = null;
	if(bolShowEditInfo)
		strTemp2 = WI.getStrValue(vEditInfo.elementAt(3));
	else
		strTemp2 = WI.fillTextValue("major_index");

strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, strTemp2, false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Student Status</td>
      <td> 
        <%
	if(bolShowEditInfo)
		strTemp = WI.getStrValue(vEditInfo.elementAt(7));
	else
		strTemp = WI.fillTextValue("status_index");
%>
        <select name="status_index">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where is_for_student = 1 order by status asc", 
					strTemp, false)%> </select> </td>
      <td colspan="2"> 
        <%
	if(bolShowEditInfo)
		strTemp = WI.getStrValue(vEditInfo.elementAt(8));
	else
		strTemp = WI.fillTextValue("is_only_for_alien");
	if(strTemp.compareTo("1") ==0)
		strTemp = "checked";
	else	
		strTemp = "";
%>
        <input type="checkbox" name="is_only_for_alien" value="1" <%=strTemp%>>
        Check if requirement is only for FOREIGN Student</td>
    </tr>
    <tr> 
      <td colspan="5" height="25"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="21%">Requirement Detail</td>
      <td width="75%"> <%
	if(bolShowEditInfo)
		strTemp = (String)vEditInfo.elementAt(9);
	else
		strTemp = request.getParameter("requirement");
	if(strTemp == null) strTemp = "";
	%> <textarea name="requirement" cols="45" rows="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea> 
      </td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">
<%
	if(bolShowEditInfo)
		strTemp = WI.getStrValue((String)vEditInfo.elementAt(14));
	else
		strTemp = WI.fillTextValue("show_in_tor");
	
	if (strTemp.compareTo("1")== 0) strTemp = "checked";
	else strTemp = "";
%>
	  <input name="show_in_tor" type="checkbox" value="1" <%=strTemp%>>
        tick if requirement should be listed in TOR</td>
    </tr>
    <tr> 
      <td height="19">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"> <%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%> <a href='javascript:PageAction("1","");'><img src="../../../images/add.gif" border="0"></a><font size="1">click 
        to add</font> <%}else{%> <a href='javascript:PageAction("2","");'><img src="../../../images/edit.gif" border="0"></a><font size="1">click 
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1">click to cancel or go previous</font> <%}%> </td>
    </tr>
    <%}//if access level > 1%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>

  <table width="100%" border="1" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="9"><div align="center">LIST OF ADMISSION REQUIREMENTS</div></td>
    </tr>
    <tr> 
      <td width="15%"><div align="center"><font size="1"><strong>COLLEGE</strong></font></div></td>
      <td width="25%" align="center"><font size="1"><strong>COURSE/MAJOR</strong></font></td>
      <td width="19%"><font size="1"><strong>REQUIREMENT</strong></font></td>
      <td width="5%" height="25"><div align="center"><font size="1"><strong>SHOW 
          IN TOR</strong></font></div></td>
      <td width="5%" align="center"><strong><font size="1">STUD STATUS</font></strong></td>
      <td width="5%" align="center"><font size="1"><strong>YEAR LEVEL</strong></font></td>
      <td width="7%" align="center"><strong><font size="1">ONLY FOR FOREIGN STUD</font></strong></td>
      <td width="9%" align="center"><font size="1"><strong>EDIT</strong></font></td>
      <td width="10%" align="center"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <%
for(int i = 0; i<vRetResult.size(); i +=15){%>
    <tr> 
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 10),"ALL")%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 11),"ALL")%> <%
	  if(vRetResult.elementAt(i + 12) != null) {%>
        /<%=(String)vRetResult.elementAt(i + 12)%> <%}%> </td>
      <td align="center"><%=(String)vRetResult.elementAt(i + 9)%></td>
      <td height="25" align="center"><%
	  if( ((String)vRetResult.elementAt(i + 14)).compareTo("1") == 0){%> <img src="../../../images/tick.gif"> <%}else{%> &nbsp; <%}%> </td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 13),"ALL")%></td>
      <td align="center"> <%
	  if( ((String)vRetResult.elementAt(i + 6)).compareTo("0") == 0){%>
        ALL 
        <%}else{%> <%=(String)vRetResult.elementAt(i + 6)%> <%}%> </td>
      <td align="center"> <%
	  if( ((String)vRetResult.elementAt(i + 8)).compareTo("1") == 0){%> <img src="../../../images/tick.gif"> <%}else{%> &nbsp; <%}%> </td>
      <td align="center"> <%if(iAccessLevel > 1){%> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        Not authorized 
        <%}%> </td>
      <td align="center"> <%if(iAccessLevel ==2 ){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif"  border="0"></a> 
        <%}else{%>
        Not authorized 
        <%}%> </td>
    </tr>
    <%}%>
  </table>
 <%}%>
 
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="reloadPage" value="0">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
