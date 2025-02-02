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
function checkAll()
{
	var maxDisp = document.form_.max_disp.value;
	//this is the time I will check all.
	for(var i =0; i< maxDisp; ++i) {
		if(document.form_.selAll.checked)
			eval('document.form_.user_'+i+'.checked = true');
		else
			eval('document.form_.user_'+i+'.checked = false');
	}

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
								"Admin/staff-System Administrator-Program fix-Update employee ID to new format",
								"update_employee_id.jsp");

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
														null);

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


int iMaxDisp = 0; 
enrollment.Authentication auth = new enrollment.Authentication();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	auth.updateIDToSystemID(dbOP, request, 2);
	strErrMsg = auth.getErrMsg();
}
Vector vRetResult = auth.updateIDToSystemID(dbOP, request, 1);
if(vRetResult == null)
	strErrMsg = auth.getErrMsg();
%>


<form name="form_" action="./update_employee_id.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          UPDATE EMPLOYEE ID TO NEW FORMAT ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td colspan="3"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr bgcolor="#CCCCCC" align="center" style="font-weight:bold">
    <td class="thinborder" width="5%">Count </td>
  	<td class="thinborder" height="22" width="20%">Employee ID </td>
  	<td class="thinborder" width="35%">Employee Name </td>
  	<td class="thinborder" width="15%">Date of Employement </td>
  	<td class="thinborder" width="10%">Select<br><input type="checkbox" name="selAll" onClick="checkAll()">	</td>
  </tr>
  <%for(int i = 0; i < vRetResult.size(); i += 4, ++iMaxDisp) {%>
	  <tr>
	    <td class="thinborder"><%=iMaxDisp + 1%>.</td>
		<td class="thinborder" height="22"><%=vRetResult.elementAt(i + 1)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
		<td class="thinborder" align="center"><input type="checkbox" name="user_<%=iMaxDisp%>" value="<%=vRetResult.elementAt(i)%>">
		<input type="hidden" name="doe_<%=iMaxDisp%>" value="<%=vRetResult.elementAt(i + 3)%>"></td>
	  </tr>
  <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td align="center"><input type="submit" name="_" value="Update Employee ID" onClick="document.form_.page_action.value = '1'"></td>
    </tr>
    <tr> 
      <td style="font-weight:bold; font-size:11px;">Note: Upon saving Employee IDs will be replaced with IDs in System format.</td>
    </tr>
  </table>
<%}%>

<table width="100%" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
</table>
<input type="hidden" name="max_disp" value="<%=iMaxDisp%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
