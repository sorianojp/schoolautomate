<%@ page language="java" import="utility.*,java.util.Vector,payroll.AutoCreate" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Auto Config</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>

<body bgcolor="#D2AE72" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Create Entries","auto_config.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	AutoCreate ac = new AutoCreate();
	ac.autoCreate(dbOP, Integer.parseInt(strTemp));
	strErrMsg = ac.getErrMsg();
}
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        AUTO CONFIGURATION PAGE ::::</strong></font></div></td>
    </tr>
	</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25" colspan="3"><font size="3" color="#0000FF"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></font></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
	<!--
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" align="right">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./auto_config.jsp?page_action=4">Create Tax table (as of January 1, 2003) </a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td width="15%" align="right">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./auto_config.jsp?page_action=1">Create Tax table (for  July 6, 2008 - December 31, 2008) </a></td>
  </tr>
	-->
  <tr>
    <td height="25">&nbsp;</td>
    <td width="15%" align="right">Operation : </td>
    <td align="center">&nbsp;</td>
    <td><a href="./auto_config.jsp?page_action=5">Create Tax table (starting January 1, 2009) </a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" align="right">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./auto_config.jsp?page_action=2">Create SSS Contribution 
      Table</a> </div></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td width="15%" align="right">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./auto_config.jsp?page_action=3">Create Philhealth Contribution 
      Table</a> </td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td width="49%">&nbsp;</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25" width="1%">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></tr>
  <tr bgcolor="#A49A6A" class="footerDynamic"> 
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>

</body>
</html>
<%
dbOP.cleanUP();
%>