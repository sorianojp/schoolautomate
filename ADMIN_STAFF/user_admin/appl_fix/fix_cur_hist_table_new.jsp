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
								"fix_cur_hist_table.jsp");

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
														"fix_cur_hist_table.jsp");
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
vRetResult = progFix.operateOnStudCurHistNew(dbOP, request);
if(vRetResult == null) 
	strErrMsg = progFix.getErrMsg();

//get errors still there. 
vRetResult = progFix.operateOnStudCurHist(dbOP, 4);
if(vRetResult == null && strErrMsg == null) 
	strErrMsg = progFix.getErrMsg();
%>


<form name="form_" action="./room_info_not_found.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          DUPLICATE CURRICULUM STANDING ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td colspan="3"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td width="12%" height="27">&nbsp;</td>
      <td width="86%" colspan="2">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="2" align="center" bgcolor="#3366FF" class="thinborder"><font color="#FFFFFF"><b> 
        ::: LIST OF STUDENT WITH DUPLICATE CURRICULUM STANDING ::: </b></font></td>
    </tr>
    <tr> 
      <td width="73%" height="25" bgcolor="#FFFFAF" class="thinborder"><div align="center"><font size="1"><strong>STUDENT</strong></font></div></td>
      <td width="27%" bgcolor="#FFFFAF" class="thinborder"><div align="center"><font size="1"><strong>SY 
          INFORMATION</strong> </font></div></td>
    </tr>
    <%
for(int i = 0; i < vRetResult.size(); i += 5) {%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%> :::: <%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%> - 
	  <%=Integer.parseInt((String)vRetResult.elementAt(i + 3)) + 1%> (<%=dbOP.getHETerm(Integer.parseInt((String)vRetResult.elementAt(i + 4)))%>)</td>
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
