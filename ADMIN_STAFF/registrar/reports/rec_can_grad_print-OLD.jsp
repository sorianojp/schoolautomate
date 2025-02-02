<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

-->
</style>
</head>

<body>
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
								"Admin/staff-Registrar Management-REPORTS-candidate for grad - form 18","rec_can_grad.jsp");
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
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														"rec_can_grad.jsp");
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
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
enrollment.ReportRegistrar reportRegistrar = new enrollment.ReportRegistrar();
Vector vStudInfo = null;
Vector vRetResult = null;

if(WI.fillTextValue("stud_id").length() > 0){
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null)
		strErrMsg = offlineAdm.getErrMsg();
}
if(vStudInfo != null && vStudInfo.size() > 0){
	vRetResult = reportRegistrar.getRecordsOfCanForGrad(dbOP, WI.fillTextValue("stud_id"),WI.fillTextValue("degree_type"));
	if(vRetResult == null || vRetResult.size() > 0)
		strErrMsg = reportRegistrar.getErrMsg();
}	

if(strErrMsg != null){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="100%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=strErrMsg%></font></td>
  </tr>
</table>
<%}if(vStudInfo != null && vStudInfo.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="100%" height="16"><div align="center">
        <p align="right"><strong>
          </strong> Form 18</div></td>
  </tr>
  <tr>
    <td height="73"><div align="center"><div align="center">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=SchoolInformation.getInfo1(dbOP,false,true)%>
        <br>
        <font size="2"><strong> RECORDS OF CANDIDATE FOR GRADUATION</strong><br>
        <strong>COLLEGIATE COURSES</strong><br>
        <br>
        COURSE : <strong><%=((String)vStudInfo.elementAt(7)).toUpperCase()%></strong></font></div></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="7%"><font size="2">NAME : </font></td>
    <td height="25" ><font size="2"><strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%></strong></font></td>
    <td ><font size="2"><strong><%=((String)vStudInfo.elementAt(0)).toUpperCase()%></strong></font></td>
    <td ><font size="2"><strong><%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></font></td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td valign="top"><font size="1">(Last Name)</font></td>
    <td valign="top"><font size="1">(First Name)</font></td>
    <td valign="top"><font size="1">(Middle Name)</font></td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25" colspan="4"><font size="2">CANDIDATE FOR TITLE/DEGREE <strong><%=((String)vStudInfo.elementAt(7)).toUpperCase()%></strong></font></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="49%" height="25"><font size="2">Major : <%=WI.getStrValue(vStudInfo.elementAt(8)," ").toUpperCase()%></font></td>
    <td width="51%"><font size="2">Minor : </font></td>
  </tr>
  <tr> 
    <td height="25"><font size="2">Date of Graduation : <strong><%=WI.fillTextValue("date_mm")+" "+
																		WI.fillTextValue("date_yyyy")%></strong></font></td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td height="10" colspan="2"><hr size="1"></td>
  </tr>
</table>
<%}//show only if vStudInfo is not null. 
if(vRetResult != null && vRetResult.size() > 0){%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="9%" height="25">&nbsp;</td>
    <td colspan="3"><div align="center"><font size="2">SUMMARY (CREDITS BY GROUP)</font></div></td>
    <td width="16%"><div align="center">TOTAL UNITS</div></td>
  </tr>
  <%
for(int i = 1, j=1; i< vRetResult.size(); i +=2, ++j){%>
  <tr> 
    <td height="25">Group <%=j%></td>
    <td width="5%"><hr align="center" width="10" size="1"></td>
    <td width="44%"><%=(String)vRetResult.elementAt(i)%></td>
    <td width="26%" valign="bottom"><div align="right"><font size="1">..........................................................</font></div></td>
    <td><div align="center"><%=(String)vRetResult.elementAt(i + 1)%></div></td>
  </tr>
  <%}//end of for loop.%>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="10" colspan="3"><hr size="1"></td>
  </tr>
  <tr> 
    <td width="58%" height="25"><div align="right"></div></td>
    <td width="28%"><div align="right"><font size="2">S U M &nbsp;&nbsp;T O T 
        A L&nbsp;&nbsp;&nbsp;&nbsp;=&nbsp;&nbsp;&nbsp;&nbsp;</font></div></td>
    <td width="14%"><div align="center"><%=(String)vRetResult.elementAt(0)%></div></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" colspan="3">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25" colspan="3"><%=WI.fillTextValue("dean_name")%></td>
    <td colspan="2"><div align="right"><%=WI.fillTextValue("registrar_name")%></div></td>
  </tr>
  <tr> 
    <td height="15" colspan="3"><em>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Dean</em></td>
    <td colspan="2"><div align="right"><em>Registrar&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</em></div></td>
  </tr>
  <tr> 
    <td height="12" colspan="3">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr> 
    <td height="20" colspan="3">INCLOSURES:</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr> 
    <td width="2%" height="20" rowspan="8">&nbsp;</td>
    <td width="3%" height="20">(&nbsp;&nbsp; )</td>
    <td width="48%" height="20">True Xerox Copy of Certificates of Eligibility 
      for Admission (CEA) </td>
    <td width="4%">(&nbsp;&nbsp; )</td>
    <td width="43%">Tru Xerox Copies</td>
  </tr>
  <tr> 
    <td width="3%" height="20">&nbsp;</td>
    <td height="20">(&nbsp;&nbsp; ) Foreign Students</td>
    <td>&nbsp;</td>
    <td>(&nbsp;&nbsp; ) Special Order</td>
  </tr>
  <tr> 
    <td width="3%" height="20">&nbsp;</td>
    <td height="20">(&nbsp;&nbsp; ) Dentistry</td>
    <td>&nbsp;</td>
    <td>(&nbsp;&nbsp; ) ACR</td>
  </tr>
  <tr> 
    <td width="3%" height="20">&nbsp;</td>
    <td height="20">(&nbsp;&nbsp; ) Medicine</td>
    <td>&nbsp;</td>
    <td>(&nbsp;&nbsp; ) Study Permit</td>
  </tr>
  <tr> 
    <td width="3%" height="20">(&nbsp;&nbsp; )</td>
    <td height="20">Certificate of Tree Planting</td>
    <td>&nbsp;</td>
    <td>(&nbsp;&nbsp; ) Exemption from ROTC</td>
  </tr>
  <tr> 
    <td width="3%" height="20">(&nbsp;&nbsp; )</td>
    <td height="20">Certificate of YCAP</td>
    <td>&nbsp;</td>
    <td>(&nbsp;&nbsp; ) Permit to Cross-Enroll</td>
  </tr>
  <tr> 
    <td width="3%" height="20">(&nbsp;&nbsp; )</td>
    <td height="20">Certificate of Survival</td>
    <td>&nbsp;</td>
    <td>(&nbsp;&nbsp; ) Clinical Experience Record</td>
  </tr>
  <tr> 
    <td width="3%" height="20">(&nbsp;&nbsp; )</td>
    <td height="20">CIVAC Certificate</td>
    <td colspan="2">&nbsp;</td>
  </tr>
</table>
<script language="JavaScript">
window.print();
</script>
<%}//show only if vRetResult is not null%>

</body>
</html>
<%
dbOP.cleanUP();
%>