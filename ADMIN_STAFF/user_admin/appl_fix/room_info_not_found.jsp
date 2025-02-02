<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	if(document.form_.semester.selectedIndex == 0) {
		document.form_.sy_from.value = "";
		document.form_.sy_to.value = "";
	}
	this.SubmitOnce('form_');		
}
function UpdateClassProgram(strSubSecIndex)
{
	document.form_.show_result.value = "1";
	document.form_.sub_sec_index.value = strSubSecIndex;
	this.ReloadPage();
}
function ShowResult() {
	document.form_.show_result.value = "1";
	this.ReloadPage();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Program fix-Fix class program",
								"room_info_not_found.jsp");

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
														"System Administration","Application Fix",request.getRemoteAddr(),
														"room_info_not_found.jsp");
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
Vector vRetResult = null;
AllProgramFix progFix = new AllProgramFix();
if(WI.fillTextValue("show_result").length() > 0) {
	vRetResult = progFix.fixErrorInGettingRoomInfo(dbOP, WI.fillTextValue("sy_from"),
					WI.fillTextValue("semester"), WI.fillTextValue("sub_sec_index"));
	strErrMsg = progFix.getErrMsg();
}	

%>


<form name="form_" action="./room_info_not_found.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          FLOATING SECTION FIX ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td colspan="3"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">NOTE: Enter school year information to check 
        if class program is having error in locating room information.</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="12%" height="25">SY/Term</td>
      <td width="42%"> <%
if(request.getParameter("sy_from") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
else
	strTemp = WI.fillTextValue("sy_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
        to 
        <%
if(request.getParameter("sy_to") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
else
	strTemp = WI.fillTextValue("sy_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" readonly> 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
		<select name="semester" onChange="ReloadPage();">
		<option value="">Show for all SY/Term</option>
          <%
if(request.getParameter("semester") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
else
	strTemp = WI.fillTextValue("semester");

if(strTemp.compareTo("1") ==0)
{%>
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
<%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
      <td width="44%"><a href="javascript:ShowResult();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td height="27">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="4" align="center" bgcolor="#3366FF" class="thinborder"><font color="#FFFFFF"><b> 
        ::: LIST OF SECTION HAVING ERROR IN ROOM INFORMATION ::: </b></font></td>
    </tr>
    <tr> 
      <td width="27%" height="25" bgcolor="#FFFFAF" class="thinborder"><div align="center"><font size="1"><strong>SECTION</strong></font></div></td>
      <td width="17%" bgcolor="#FFFFAF" class="thinborder"><div align="center"><font size="1"><strong>SY 
          INFORMATION</strong> </font></div></td>
	  <td width="46%" bgcolor="#FFFFAF" class="thinborder"><div align="center"><font size="1"><strong>SUBJECT 
          CODE (DESCRIPTION)</strong></font></div></td>
      <td width="10%" bgcolor="#FFFFAF" class="thinborder"><div align="center"><font size="1"><strong>CLICK 
          TO FIX</strong></font></div></td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 7) {%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%> - <%=(String)vRetResult.elementAt(i + 2)%> 
	  (<%=dbOP.getHETerm(Integer.parseInt((String)vRetResult.elementAt(i + 3)))%>)</td>
      <td class="thinborder"><div align="center">&nbsp;
	  <%=(String)vRetResult.elementAt(i + 5)%>(<%=(String)vRetResult.elementAt(i + 6)%>)</div></td>
      <td class="thinborder"><div align="center">
	  <a href='javascript:UpdateClassProgram("<%=(String)vRetResult.elementAt(i)%>");'><font size="3" color="#FF0000">FIX</font></a></div></td>
    </tr>
<%}%>
  </table>
<%}//only if vRetResult is not null
%>
<table width="100%" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
</table>
<input type="hidden" name="show_result">
<input type="hidden" name="sub_sec_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
