<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
	String strTemp = null;
	String strErrMsg = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Set Additional Month Pay Parameters","addtl_mth_pay_main.jsp");
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

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"addtl_mth_pay_main.jsp");
if(iAccessLevel == 0){
iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION-SETADDLMNTH",request.getRemoteAddr(), null);
}
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
%>
<body bgcolor="#D2AE72" class="bgDynamic">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL : ADDITIONAL MONTH PAY PARAMETERS PAGE ::::</strong></font></td>
    </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td width="6%" height="25">&nbsp;</td>
    <td width="14%" height="25" align="right">Operation : </td>
    <td width="1%" align="center">&nbsp;</td>
    <td width="79%"><a href="additional_pay_mgmt.jsp"> Additional Pay / Bonus 
      Management</a>&nbsp;</td>
  </tr>
  <!--
  <%if(false){%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="set_items_included_comp_adtl_pay.jsp">Schedule Additional Month Pay</a>&nbsp;</td>
  </tr>
  <%}%>
  -->
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="set_max_non_tax_amt.jsp">Set Non-Taxable Maximum Amount for Additional 
      Month Pay</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="copy_additional_pay.jsp">Copy Additional pay </a></td>
  </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  
  <tr> 
    <td height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A" class="footerDynamic"> 
    <td width="50%" height="25">&nbsp;</td>
  </tr>
</table>

</body>
</html>
<%
	dbOP.cleanUP();
%>