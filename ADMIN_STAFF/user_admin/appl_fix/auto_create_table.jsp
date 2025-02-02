<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Application Fix","auto_create_table.jsp");

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
														"auto_create_table.jsp");
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
String strTablesChanged = null;

utility.CreateTable CT = new utility.CreateTable();
if(CT.createPurchasingTable(dbOP))
	strTablesChanged = "Purchasing tables.";
	
if(CT.addFieldCheckPayment(dbOP)) {
	if(strTablesChanged == null)
		strTablesChanged = "Purchasing tables.";
	else
		strTablesChanged += "<br> Payment tables updated with addl. fields.";	
}
if(CT.createOrganizerTable(dbOP)) {
	if(strTablesChanged == null)
		strTablesChanged = "Organizer tables.";
	else
		strTablesChanged += "<br> Organizer tables are created.";	
}		
if(CT.addLCFields(dbOP)) {
	if(strTablesChanged == null)
		strTablesChanged = "LMS/LC tables added.";
	else
		strTablesChanged += "<br> LMC/LC tables are added.";	
}		
if(CT.addFAdjustmentFields(dbOP)) {
	if(strTablesChanged == null)
		strTablesChanged = "Fee Adjustment fields modified.";
	else
		strTablesChanged += "<br> Fee Adjustment fields modified.";	
}		
//other go here.
//dbOP.executeUpdateWithTrans("update sys_info set line3='Tel. No. 7110075',"+
//								"info2='Institutional Identifier: 13004'",null,null,false);
dbOP.cleanUP();
%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          AUTO CREATE TABLE LIST ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="97%"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFAF"> 
      <td height="26" colspan="3" class="thinborder"><div align="center"><strong>LIST 
        OF CHANGES</strong></div></td>
    </tr>
    <tr> 
      <td width="3%" height="27" class="thinborder">&nbsp;</td>
      <td width="92%" class="thinborder"><%=WI.getStrValue(strTablesChanged,"<font size=3><b>Nothing to update.</b></font>")%></td>
      <td width="5%" class="thinborder">&nbsp;</td>
    </tr>
    <tr bgcolor="#77ccFF"> 
      <td height="25" colspan="3"  class="thinborder">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr><td width="25">&nbsp;</td></tr>
  </table>
  
    
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25"bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</body>
</html>
