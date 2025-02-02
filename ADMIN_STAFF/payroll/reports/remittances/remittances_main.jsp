<%@ page language="java" import="utility.*" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Remittances Main</title>
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
	String strErrMsg = null;
	String strImgFileExt = null;
	boolean bolIsGovernment = false;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PAYROLL-REPORTS-sss_monthlyLoanRemit","remittances_main.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		bolIsGovernment = (readPropFile.getImageFileExtn("IS_GOVERNMENT")).equals("1");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
  if(strSchCode == null)
		strSchCode = "";
		
	boolean bolShowAll = false;
	String strCount = dbOP.getResultOfAQuery("select count(*) from pr_employer_profile where is_default = 1",0);

	if (Integer.parseInt(strCount) > 0)
		bolShowAll = true;	
%>
<body bgcolor="#D2AE72" class="bgDynamic">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
      PAYROLL :  REMITTANCES MAIN PAGE ::::</strong></font></td>
    </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td align="right">Operation : </td>
    <td align="center">&nbsp;</td>
    <td><a href="./employer_profile.jsp">EMPLOYER PROFILE</a></td>
  </tr>
  <%if(bolShowAll || strSchCode.startsWith("SWU") ){%>
  <%if(strSchCode.startsWith("TSUN")){%>
	<tr>
    <td height="25">&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./new_contribution_stat.jsp">New employee contribution</a></td>
  </tr>
	<%}%>  
  
  
  <%if(strSchCode.startsWith("WUP")){//here's the all in one page. cant be used for other clients too if enabled%>
  	<tr> 
		<td width="12%" height="25">&nbsp;</td>
		<td width="15%" align="right">&nbsp;</td>
		<td width="2%" align="center">&nbsp;</td>
		<td width="71%"><a href="./remittance_monthly_grouped.jsp">Monthly Premium Report</a></td>
 	</tr>
	<tr> 
		<td width="12%" height="25">&nbsp;</td>
		<td width="15%" align="right">&nbsp;</td>
		<td width="2%" align="center">&nbsp;</td>	
		<td width="71%"><a href="./sss_monthly_remittance_wup.jsp">SSS PREMIUM</a></td>	
 	</tr>
	<tr> 
		<td width="12%" height="25">&nbsp;</td>
		<td width="15%" align="right">&nbsp;</td>
		<td width="2%" align="center">&nbsp;</td>	
		<td width="71%"><a href="./pagibig_monthly_remittance_wup.jsp">PAG-IBIG PREMIUM</a></td>	
 	</tr>
	
  <%}else{%>
  	<tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" align="right">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>	 
	<td width="71%"><a href="./sss_monthly.jsp">SSS PREMIUM</a></td>	
  </tr>
  <%}%>
   <tr> 
    <td height="26">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./sss_monthly_loan.jsp">SSS Monthly Loan</a></td>
  </tr>
  <%if(!strSchCode.startsWith("WUP")){ //WUP has customized report. all contributions in 1 page%>	
  <tr> 
    <td height="26">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./philhealth_main.jsp">Philhealth Premium </a></td>
  </tr>
  <%}else{%>
  	<tr> 
    <td height="26">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./phic_quarterly.jsp">Philhealth Quarterly Report</a></td>
  </tr>  	   
  <%}%>
  <tr>
    <td height="26">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="premium_monthly_summary.jsp">Premium Summary (SSS/Philhealth)</a></td>
  </tr>  
  <tr>
    <td height="26">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="prem_monthly_per_office.jsp">Premium per Office(SSS/Philhealth Count)</a></td>
  </tr>    
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="monthly_total_per_office.jsp">Premium per Office(SSS/Philhealth)</a></td>
  </tr>  
  <%if(bolIsSchool){%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./peraa_remittance.jsp">PERAA</a></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./peraa_loans_remittance.jsp">PERAA loans</a></td>
  </tr>
  <%}%>
  <%if(!strSchCode.startsWith("WUP")){ //WUP has customized report. all contributions in 1 page%>	
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./hdmf_monthly.jsp">Pag-ibig Premium </a></td>
  </tr>
  <%}%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./hdmf_loans_remittance.jsp">Pag-ibig loans</a></td>
  </tr>
  <%if(bolIsGovernment){%>
	<tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./gsis_monthly.jsp">GSIS</a></td>
  </tr>
	<%}%>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./regular_loans_remittance.jsp">Institutional Loans</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./regular_loans_summary.jsp">Loans Remittances Summary</a></td>
  </tr>	
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./tax_compensation.jsp">Withholding Tax </a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./tax_compensation2.jsp">Withholding Tax II</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./tax_compensation_dept.jsp">Withholding Tax By Department</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./tax_compensation_monthly.jsp">Withholding Tax (Monthly)</a></td>
  </tr>
 <%if(strSchCode.startsWith("EAC")){%> 
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="../certifications/encode_contribution_new.jsp">Encode Payment for Contribution per Employee</a></td>
  </tr>
  
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="../certifications/encode_contribution_batch_per_month.jsp">Encode Payment for Contribution Batch</a></td>
  </tr>
  
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="../certifications/contribution_certificate.jsp">Generate Certificate of Contribution </a></td>
  </tr> 
 <%}%>
<%}// bol show all%>
  <!--
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center"><div align="left"><a href="./payroll_slip_main.jsp">Regular Payroll 
        </a></div></td>
  </tr>
  -->
  
  <tr> 
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
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
    <td height="25" colspan="3" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
</body>
</html>
<%
dbOP.cleanUP();
%>