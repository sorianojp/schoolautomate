<%
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";
if(strSchoolCode.startsWith("WNU"))
	strSchoolCode = "UI";
	//strSchoolCode = "VMA";

if(strSchoolCode.startsWith("UB")) {
	response.sendRedirect("./payment_prior_enrolment_ub.jsp?fee_type=0");
	return;
}
if(strSchoolCode.startsWith("UC")) {
	response.sendRedirect("./assessedfees.jsp");
	return;
}

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PrintAssessment()
{
	location = "./assessedfees.jsp?view_status=1";
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.DBOperation,utility.CommonUtil" %>
<%
	DBOperation dbOP = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-assessedfees(enrollment)","assessedfees.jsp");
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
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"assessedfees.jsp");

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


boolean bolIsCavite = false;
String strSQLQuery = "select info5 from sys_info";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null && strSQLQuery.equals("Cavite"))
	bolIsCavite = true;

if(bolIsCavite)
	strSchoolCode = "GENERIC";	
//end of authenticaion code.


dbOP.cleanUP();
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        ENROLLMENT PAYMENT MAIN PAGE ::::</strong></font></div></td>
    </tr>
	</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25" width="12%">&nbsp;</td>
    <td height="25" width="15%">&nbsp;</td>
    <td height="25" width="2%">&nbsp;</td>
    <td height="25" width="71%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25" align="right">Operation :</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <%
	if(	strSchoolCode.startsWith("LNU"))	{%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./payment_prior_enrolment.jsp?fee_type=0">Downpayment/Registration 
      Fee (Student is not advised)</a></div></td>
  </tr>
  <%}else if(!strSchoolCode.startsWith("UI")){
  if(!strSchoolCode.startsWith("UL") && !strSchoolCode.startsWith("FATIMA") && !strSchoolCode.startsWith("CDD") && !strSchoolCode.startsWith("UB") 
  && !strSchoolCode.startsWith("VMA") && !strSchoolCode.startsWith("PWC") && !strSchoolCode.startsWith("ICAAC") && !strSchoolCode.startsWith("SWU")
   && !strSchoolCode.startsWith("HTC")){//&& !strSchoolCode.startsWith("VMA")){
  	String strTemp = null;
  	  if(strSchoolCode.startsWith("CIT"))
		strTemp = "?payment_mode=1";
	  else
		strTemp = "";
  %>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./assessedfees.jsp<%=strTemp%>">Downpayment (Student is advised)</a></td></td>
  </tr>
  <%}if(strSchoolCode.startsWith("DBTC") || strSchoolCode.startsWith("CSAB") || strSchoolCode.startsWith("UL") || 
  strSchoolCode.startsWith("FATIMA") || strSchoolCode.startsWith("CDD") || strSchoolCode.startsWith("UB") || strSchoolCode.startsWith("VMA") || strSchoolCode.startsWith("PWC")
   || strSchoolCode.startsWith("ICAAC") || strSchoolCode.startsWith("SWU") || strSchoolCode.startsWith("HTC")){// || strSchoolCode.startsWith("VMA") ){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./payment_prior_enrolment.jsp?fee_type=0">Downpayment/Registration 
      Fee (Student is not advised)</a></div></td>
  </tr>
  <%}if(!strSchoolCode.startsWith("UB")) {%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./payment_prior_enrolment.jsp?fee_type=1">Application/Registration/Reservation Fee </a></td>
  </tr>
  <%}
  
  }%>
</table>
<%
if(((String)request.getSession(false).getAttribute("userId")).compareTo("1770") ==0 ||
	strSchoolCode.startsWith("UI")){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./payment_prior_enrolment.jsp?fee_type=0">Downpayment/Registration 
      Fee (Student is not advised)</a></div></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./assessedfees.jsp">Downpayment (Student is advised)</a></td></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./payment_prior_enrolment.jsp?fee_type=1">Application Fee (For 
      new students only)</a></td>
  </tr>
</table>
  <%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="71%"></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="71%">
	<%if( !strSchoolCode.startsWith("UDMC")){
		if(strSchoolCode.startsWith("DBTC")){%>
			<a href="./manage_reqd_dp_per_stud.jsp">Search/View/Manage downpayment information (old students only)</a>
		<%}else{%>
			<a href="javascript:PrintAssessment();">Print Student Assessment</a>
		<%}%>
	<%}%></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" width="1%">&nbsp;</td>
    <td width="49%">&nbsp;</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></tr>
  <tr bgcolor="#A49A6A">
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>

</body>
</html>
