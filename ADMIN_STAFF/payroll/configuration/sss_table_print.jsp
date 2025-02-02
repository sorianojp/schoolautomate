<%@ page language="java" import="utility.*,payroll.PayrollConfig,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>SSS table Printing</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll - SSS Table Configuration","sss_table.jsp");
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
														"Payroll","CONFIGURATION-SSS",request.getRemoteAddr(),
														"sss_table.jsp");
if(iAccessLevel == 0){
iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"sss_table.jsp");
}
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

	PayrollConfig prConfig = new PayrollConfig();
	Vector vRetResult = null;
	vRetResult  = prConfig.operateOnSSSTable(dbOP, request,4);
%>
<body onLoad="javscript:window.print();">
<form name="form_">
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="6" class="thinborder"><div align="center"><strong>SSS 
          SCHEDULE OF CONTRIBUTIONS FOR EMPLOYED MEMBERS EFFECTIVE <%=(String)vRetResult.elementAt(9)%></strong></div></td>
    </tr>
    <tr> 
      <td height="28" rowspan="3" class="thinborder"><div align="center"><font size="1"><strong>RANGE 
          OF COMPENSATION</strong></font></div></td>
      <td rowspan="3" class="thinborder"><div align="center"><font size="1"><strong>MONTHLY 
          SALARY CREDIT </strong></font></div></td>
      <td height="28" colspan="4" class="thinborder"><div align="center"><strong><font size="1">MONTHLY 
          CONTRIBUTION</font></strong></div></td>
    </tr>
    <tr> 
      <td height="28" colspan="2" class="thinborder"><div align="center"><font size="1"><strong>EMPLOYER</strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE</strong></font></div></td>
      <td rowspan="2" class="thinborder"><div align="center"><strong><font size="1">TOTAL(ER+EC+EE)</font></strong></div></td>
    </tr>
    <tr> 
      <td height="28" class="thinborder"><div align="center"><font size="1"><strong>ER</strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>EC</strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>EE</strong></font></div></td>
    </tr>
    <% for(int i =1; i < vRetResult.size(); i += 10){%>
    <tr> 
      <td width="23%" height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i + 9)%></font></div></td>
      <td width="24%" class="thinborder"><div align="center"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 3),true)%></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 4),true)%></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 5),true)%></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 6),true)%></font></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 7),true)%></font></div></td>
    </tr>
    <%}%>
  </table>
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
