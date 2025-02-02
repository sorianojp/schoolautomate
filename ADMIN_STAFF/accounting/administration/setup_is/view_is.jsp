<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<body>
<%@ page language="java" import="utility.*,Accounting.IncomeStatement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation();
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
														"Accounting","Administration",request.getRemoteAddr(), 
														"view_is.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
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
IncomeStatement IS = new IncomeStatement();
Vector vRetResult  = IS.getIncomeStatementStructure(dbOP, WI.fillTextValue("title_index"));
if(vRetResult == null)
	strErrMsg = IS.getErrMsg();
%>
	
<%if(vRetResult == null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" style="font-size:14px; color:#FF0000; font-weight:bold"><%=strErrMsg%></td>
    </tr>
  </table>
<%
dbOP.cleanUP();
return;}

String strISTitle = "select title from AC_SET_IS_TITLE where is_title_index = "+WI.fillTextValue("title_index");
strISTitle = dbOP.getResultOfAQuery(strISTitle, 0);
if(strISTitle == null){%>
<p style="font-size:22px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold">Please select Income Statment title</p>
<%dbOP.cleanUP();
return;}
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" align="center">
      	<font size="2">
      	<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>      </td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><strong><u><%=strISTitle%></u></strong></div></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" bgcolor="#FFFFFF">
<%
Vector vSubGroup = null;
String strGroupTitle = null;

for(int i = 0; i < vRetResult.size(); i += 9) {
vSubGroup = (Vector)vRetResult.elementAt(i + 8);
%>
    <tr>
      <td width="3%">&nbsp;</td>
      <td colspan="2"><b><%=vRetResult.elementAt(i + 1)%> <%if(vRetResult.elementAt(i + 5).equals("0")){%>(Add)<%}else{%>(Subtract)<%}%></b></td>
    </tr>
<%if(vSubGroup != null)
	for(int a = 0; a < vSubGroup.size(); a += 3){%>
    <tr>
      <td>&nbsp;</td>
      <td width="5%">&nbsp;</td>
      <td width="92%"><%=vSubGroup.elementAt(a)%></td>
    </tr>
<%}if(vRetResult.elementAt(i + 3).equals("0")){%>
    <tr style="font-weight:bold">
      <td>&nbsp;</td>
      <td colspan="2"><%=vRetResult.elementAt(i + 4)%></td>
    </tr>
<%}%>
    <tr>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
<%}%>	
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="3" align="right">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3" align="right">&nbsp;</td>
    </tr>
  </table>
</body>
</html>
<% 
dbOP.cleanUP();
%>