<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInsuranceTracking" %>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Health Insurance Application</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script src="../../../jscript/common.js"></script>

<script language="javascript">
function CopyAllInsurance() {
	document.form_.copy.value = "1";
	document.form_.submit();
}
</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
		
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-HEALTH INSURANCE MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{		
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Health Insurance Management-Health Insurance Copy","health_insurance_copy.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}

	HRInsuranceTracking hriTracker  = new HRInsuranceTracking();
	strTemp = WI.fillTextValue("copy");
	
	if(strTemp.length() > 0) {
		if(!hriTracker.operateOnInsuranceCopy(dbOP, request))
			strErrMsg = hriTracker.getErrMsg();
		else 
			strErrMsg = hriTracker.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="health_insurance_copy.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: COPY INSURANCE RECORDS ::::</strong></font>			</td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td width="3%">&nbsp;</td>
			<td><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
			<td width="10%"><a href="health_insurance_tracking.jsp" ><img src="../../../images/go_back.gif" border="0" align="right"></a></td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
	</table>
	<table bgcolor="FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="12%">Copy From:</td>
			<%
				strTemp =  " from hr_health_insurance where is_valid = 1 order by hr_health_insurance.year";
				strErrMsg = WI.fillTextValue("year_from");
			%>	
		    <td width="9%">
				<select name="year_from" size="1" id="year_from">
					<%=dbOP.loadCombo("distinct year","year",strTemp,strErrMsg,false)%>
				</select>			</td>
		    <td width="10%" align="right">Copy To: </td>
		    <td width="66%">
				<select name="year_to" size="1" id="year_to">
					<%=dbOP.loadComboYear(WI.fillTextValue("year_to"), 1, 1)%>
				</select>			</td>
		</tr>
		<tr>
			<td colspan="5">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="3">
				<a href="javascript:CopyAllInsurance();"><img src="../../../images/copy.gif" border="0"></a> 
				<font size="1">click to copy insurance.</font></td>
		</tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="copy">
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>