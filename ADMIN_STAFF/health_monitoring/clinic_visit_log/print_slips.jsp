<%@ page language="java" import="utility.* ,java.util.Vector " %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">

<script language="javascript" src="../../../jscript/common.js" ></script>
<script language="javascript">
	
	function PrintReferralSlip(){
		document.form_.print_referral.value = "1";
		document.form_.submit();
	}
	
	function PrintAdmissionSlip(strType){
		document.form_.print_admission.value = strType;
		document.form_.submit();
	}
	
	function PrintDiagnosticSlip(){
		document.form_.print_diagnostic.value = "1";
		document.form_.submit();
	}
	
</script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
a{
	text-decoration:none;
}
</style>
</head>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	
	String strVisitLogIndex = WI.fillTextValue("visit_log_index");
	if(strVisitLogIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Clinic vist reference not found.</p>
		<%return;
	}

	if (WI.fillTextValue("print_referral").length() > 0){%>
		<jsp:forward page="./print_slip_referral.jsp" />
	<% 
		return;}
		
	if (WI.fillTextValue("print_admission").length() > 0){%>
		<jsp:forward page="./print_slip_admission.jsp" />
	<% 
		return;}
		
	if (WI.fillTextValue("print_diagnostic").length() > 0){%>
		<jsp:forward page="./print_slip_diagnostic.jsp" />
	<% 
		return;}
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","print_slips.jsp");
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
															"Health Monitoring","Clinic Visit Log",request.getRemoteAddr(),
															"print_slips.jsp");
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
%>
<body bgcolor="#8C9AAA" class="bgDynamic">
<form action="print_slips.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	  <td width="100%" height="28" align="center" bgcolor="#697A8F" class="footerDynamic">
		<font color="#FFFFFF"><strong>:::: CLINIC VISIT LOG - PRINT SLIPS ::::</strong></font></td>
	</tr>
  </table>

	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
		<tr>
			<td colspan="3" height="25">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" width="30%">&nbsp;</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%">&nbsp;</td>
		</tr>
	<%if(WI.fillTextValue("ref_index").length() > 0){%>	
		<tr>
		    <td height="25" colspan="2" align="right">&nbsp;</td>
		    <td><a href="javascript:PrintReferralSlip();">Print Referral Slip</a></td>
		</tr>
	<%}%>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td height="25"><a href="javascript:PrintAdmissionSlip('0');">Print Authorization for Admission Slip (Medical only) </a></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td height="25"><a href="javascript:PrintAdmissionSlip('1');">Print Authorization for Admission Slip (Both Medical or Surgical) </a></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td height="25"><a href="javascript:PrintDiagnosticSlip();">Print Authorization for Diagnostic Request Work-Ups Slip </a></td>
		</tr>
		<tr>
			<td colspan="3" height="25">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="visit_log_index" value="<%=strVisitLogIndex%>">
	<input type="hidden" name="ref_index" value="<%=WI.fillTextValue("ref_index")%>">
	<input type="hidden" name="print_referral">
	<input type="hidden" name="print_admission">
	<input type="hidden" name="print_diagnostic">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>

