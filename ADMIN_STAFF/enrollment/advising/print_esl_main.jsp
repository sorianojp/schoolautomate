<%@ page language="java" import="utility.CommonUtil,utility.DBOperation,utility.WebInterface" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	String strReadOnly = "";

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-advising-print_esl_main","print_esl_main.jsp");
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
														"Enrollment","ADVISING & SCHEDULING",request.getRemoteAddr(),
														"print_esl_main.jsp");
dbOP.cleanUP();

//switch off security if called from online advisign page of student... this page can't be refreshed.
if(WI.fillTextValue("online_advising").compareTo("1") ==0)
	iAccessLevel = 2;


if(iAccessLevel == -1)//for fatal error.
{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String strAuthTypeIndex = WI.getStrValue(request.getSession(false).getAttribute("authTypeIndex"),"0");
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function SetFocus()
{
	document.advising.stud_id.focus();
}
function PrintPg(strPrintStat)
{
	if(document.advising.stud_id.value.length ==0)
	{
		alert("Student ID can't be empty.");
		this.SetFocus();
		return;
	}
	pgLoc = "./gen_advised_schedule_print.jsp?stud_id="+escape(document.advising.stud_id.value)+"&print="+strPrintStat;

	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%
if(strAuthTypeIndex.compareTo("4") !=0){//student logged in for online advising %>
<body bgcolor="#D2AE72" onLoad="SetFocus();">
<%}else{%>
<body bgcolor="#9FBFD0">
<%}%>

<form name="advising">

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%
if(strAuthTypeIndex.compareTo("4") ==0){//student logged in for online advising %>
    <tr bgcolor="#47768F">
<%}else{%>
    <tr bgcolor="#A49A6A">
<%}%>      <td height="25" colspan="8" align="center"><strong> <font color="#FFFFFF"> 
        :::: ENROLLMENT STUDENT LOAD PRINT PAGE :::: </font></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="8"></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="24%" height="25">Student ID </td>
<%
if(WI.fillTextValue("online_advising").compareTo("1") ==0) {
	strTemp = "textbox_noborder";
	strReadOnly = "readonly";
}
else
	strTemp = "textbox";
%>

      <td height="25" colspan="2"><input name="stud_id" type="text" size="22" value="<%=WI.fillTextValue("stud_id")%>" class="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" <%=strReadOnly%>> 
      </td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td></td>
      <td width="23%"><a href="javascript:PrintPg(0);"><img src="../../../images/view.gif" border="0"></a> 
        <font size="1">Click to view Student load</font></td>
      <td><a href="javascript:PrintPg(1);"><img src="../../../images/print.gif" border="0"></a> 
        <font size="1">Click to print Student load</font></td>
    </tr>
  </table>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
<%
if(strAuthTypeIndex.compareTo("4") ==0){//student logged in for online advising %>
    <tr bgcolor="#47768F">
<%}else{%>
    <tr bgcolor="#A49A6A">
<%}%>      <td height="25">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="online_advising" value="<%=WI.fillTextValue("online_advising")%>">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
