<%@ page language="java" import="utility.*" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payslips</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<%
DBOperation dbOP = null;
CommonUtil comUtil = new CommonUtil();
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strErrMsg = null;
boolean bolShowAll = false;
boolean bolIsGovernment = false;
if(strUserId != null)
{
	//open dbConnection here to check if user is registered already.
	try
	{
		dbOP = new DBOperation();
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolIsGovernment = (readPropFile.getImageFileExtn("IS_GOVERNMENT","0")).equals("1");				
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		strErrMsg = "error in opening connection.";
	}

	if(strErrMsg == null)
	{
		if(strUserId.equals("bricks"))
			bolShowAll = true;
	}
}
else
	strErrMsg = "";
	String strSchCode = dbOP.getSchoolIndex();	
	
%>
<body class="bgDynamic">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
      PAYROLL : EXTERNAL PAYMENTS PAGE ::::</strong></font></td>
    </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="26%" height="25">&nbsp;</td>
    <td width="3%" height="25">&nbsp;</td>
    <td width="71%" height="25">&nbsp;</td>
  </tr>
   
  <tr> 
    <td height="26" align="right">Operation : </td>
    <td>&nbsp;</td>
    <td><a href="./external_payment.jsp">External Payments</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="period_ext_payment.jsp">Payments for period</a></td>
  </tr>
</table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="5%" height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#A49A6A">
    <td height="25" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
</body>
</html>
<%
dbOP.cleanUP();
%>