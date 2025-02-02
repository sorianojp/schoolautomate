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
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="window.print()">
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

Vector vStudSubGroup = null;

if(WI.fillTextValue("stud_id").length() > 0){
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null)
		strErrMsg = offlineAdm.getErrMsg();
}
if(vStudInfo != null && vStudInfo.size() > 0){
	vRetResult = reportRegistrar.getRecordsOfCanForGrad(dbOP, WI.fillTextValue("stud_id"),WI.fillTextValue("degree_type"));
	if(vRetResult == null || vRetResult.size() > 0)
		strErrMsg = reportRegistrar.getErrMsg();
	if(strErrMsg == null) {
		vStudSubGroup = reportRegistrar.getStudentSubGroupInfo(dbOP, (String)vStudInfo.elementAt(12), request);
		if(vStudSubGroup == null) {
			vStudSubGroup = new Vector();
			strErrMsg = reportRegistrar.getErrMsg();
		}
	}
}	

//System.out.println("vStudSubGroup : "+vStudSubGroup);
//System.out.println("vRetResult : "+vRetResult);

if(strErrMsg != null){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="100%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=strErrMsg%></font></td>
  </tr>
</table>
<%}if(vStudInfo != null && vStudInfo.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="73" align="center">
      <strong><font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=SchoolInformation.getInfo1(dbOP,false,true)%>
        <br><br>
        <font size="2"><strong> RECORDS OF CANDIDATE FOR GRADUATION</strong><br>
        <br>
        <u><%=((String)vStudInfo.elementAt(26)).toUpperCase()%></u></font></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr align="center" style="font-weight:bold"> 
    <td width="6%">&nbsp;</td>
    <td width="30%" height="25" class="thinborderBOTTOM"><font size="2"><%=((String)vStudInfo.elementAt(2)).toUpperCase()%></font></td>
    <td width="2%" >&nbsp;</td>
    <td width="30%" class="thinborderBOTTOM" ><font size="2"><%=((String)vStudInfo.elementAt(0)).toUpperCase()%></font></td>
    <td width="2%" >&nbsp;</td>
    <td width="30%" class="thinborderBOTTOM" ><font size="2"><%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></font></td>
  </tr>
  <tr align="center"> 
    <td>&nbsp;</td>
    <td valign="top"><font size="1">(Family Name)</font></td>
    <td valign="top">&nbsp;</td>
    <td valign="top"><font size="1">(First Name)</font></td>
    <td valign="top">&nbsp;</td>
    <td valign="top"><font size="1">(Middle Name)</font></td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25" colspan="6"><font size="2">CANDIDATE FOR TITLE/DEGREE <strong><u><%=((String)vStudInfo.elementAt(7)).toUpperCase()%></u></strong></font></td>
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
    <td height="25" colspan="2" align="center">SUMMARY OF UNITS EARNED</td>
    <td align="right">TOTAL UNITS</td>
  </tr>
  <%
int iIndexOf = 0; double dTotalUnits = 0d;
vRetResult.remove(0);
for(int i = 0; i< vStudSubGroup.size(); i +=6){
strTemp = (String)vStudSubGroup.elementAt(i + 3);
iIndexOf = vRetResult.indexOf(strTemp);
if(iIndexOf == -1)
	strTemp = "&nbsp;";
else {
	strTemp = (String)vRetResult.elementAt(iIndexOf + 1);
	dTotalUnits += Double.parseDouble(strTemp);
	vRetResult.remove(iIndexOf);vRetResult.remove(iIndexOf);
}
	%>
  <tr> 
    <td width="45%" height="25"><%=(String)vStudSubGroup.elementAt(i + 1)%></td>
    <td width="35%" valign="bottom" align="right"><font size="1">...............................................................................</font></td>
    <td align="right"><%=strTemp%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>
<%}//end of for loop.%>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="10"><hr size="1"></td>
  </tr>
  <tr> 
    <td height="25" align="right"><font size="2">S U M &nbsp;&nbsp;T O T 
    A L&nbsp;&nbsp;&nbsp;&nbsp;=&nbsp;&nbsp;&nbsp;&nbsp;</font><%=dTotalUnits%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="40%" height="25">&nbsp;</td>
    <td width="20%">&nbsp;</td>
    <td width="40%">&nbsp;</td>
  </tr>
  <tr align="center" style="font-weight:bold"> 
    <td height="25" class="thinborderBOTTOM"><%=WI.fillTextValue("dean_name")%></td>
    <td>&nbsp;</td>
    <td align="center" class="thinborderBOTTOM"><%=WI.fillTextValue("registrar_name")%></td>
  </tr>
  <tr align="center" style="font-weight:bold"> 
    <td height="15">Dean</td>
    <td>&nbsp;</td>
    <td>Registrar</td>
  </tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<script language="javascript">
		alert("Following subjects are not mapped.\r\n<%=vRetResult.toString()%>");
	</script>

<%}%>


<%}//show only if vRetResult is not null%>

</body>
</html>
<%
dbOP.cleanUP();
%>