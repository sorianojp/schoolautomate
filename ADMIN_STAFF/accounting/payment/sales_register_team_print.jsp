<%@ page language="java" import="utility.*,Accounting.PaymentReports,Accounting.billing.BillingTsuneishi,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Sales Register Per Team</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.elevenPix {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
.elevenPixTopBot {
	border-top: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
</style>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body onLoad="window.print();">
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BUDGET"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
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
								"ACCOUNTING-BUDGET","sales_register_team_print.jsp");
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
	
	String[] astrMonths = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "Decemeber"};
	Integer iObjTemp = null;
	int iIndexOf = 0;
	Vector vTeams = null;
	Vector vValues = null;
	Vector vRetResult = null;
	Vector vExchangeRates = null;
	PaymentReports pr = new PaymentReports();
	BillingTsuneishi billTsu = new BillingTsuneishi();
	
	vRetResult = pr.generateSalesRegisterTeam(dbOP, request);
	if(vRetResult == null)
		strErrMsg = pr.getErrMsg();
	else{
		vExchangeRates = pr.getExchangeRatesForDate(dbOP, request);
		vTeams = billTsu.operateOnTeams(dbOP, request, 4);
		if(vTeams == null){
			vRetResult = null;
			strErrMsg = billTsu.getErrMsg();
		}
	}
	
	if(vRetResult != null && vRetResult.size() > 0){
		double dRowSum = 0d;
		double dSumOverall = 0d;
		double[] dSumTeam = new double[vTeams.size()/5];
%>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="elevenPix">
		<tr>
			<td class="elevenPix"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></td>
		</tr>
		<tr>
			<td class="elevenPix"><strong>SALES REGISTER</strong></td>
		</tr>
		<tr>
			<td class="elevenPix"><strong>FOR THE MONTH OF <%=astrMonths[Integer.parseInt(WI.fillTextValue("month"))].toUpperCase()%> <%=WI.fillTextValue("year")%></strong></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="elevenPix">
		<tr>
			<td align="center" class="elevenPix"><strong>DATE</strong></td>
			<td align="center" class="elevenPix"><strong>CUSTOMER</strong></td>
			<td align="center" class="elevenPix"><strong>INV #</strong></td>
			<td align="center" class="elevenPix"><strong>PESO EQUIVALENT </strong></td>
		<%for(int i = 0; i < vTeams.size(); i += 5){%>
			<td align="center" class="elevenPix"><strong><%=(String)vTeams.elementAt(i+1)%></strong></td>
		<%}%>
			<td align="center" class="elevenPix"><strong>TOTAL</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 7){
		dRowSum = 0;
		dSumOverall += Double.parseDouble((String)vRetResult.elementAt(i+4));
		vValues = (Vector)vRetResult.elementAt(i+5);
	%>
		<tr>
			<%
				strTemp = (String)vRetResult.elementAt(i+1);
				strTemp = strTemp.substring(0, strTemp.length()-6);
			%>
			<td class="elevenPix" align="right"><%=strTemp%>&nbsp;</td>
			<td class="elevenPix"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="elevenPix" align="right"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="elevenPix" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+4), true)%></td>
		<%	int iTemp = 0;
			for(int j = 0; j < vTeams.size(); j+=5, iTemp++){
				iObjTemp = new Integer((String)vTeams.elementAt(j));
				iIndexOf = vValues.indexOf(iObjTemp);
				
				if(iIndexOf != -1){
					dRowSum += Double.parseDouble((String)vValues.elementAt(iIndexOf+1));
					dSumTeam[iTemp] += Double.parseDouble((String)vValues.elementAt(iIndexOf+1));
					strTemp = CommonUtil.formatFloat((String)vValues.elementAt(iIndexOf+1), true);
				}
				else
					strTemp = "&nbsp;";
		%>
			<td align="right" class="elevenPix"><%=strTemp%></td>
		<%}%>
			<td align="right" class="elevenPix"><%=CommonUtil.formatFloat(dRowSum, true)%></td>
		</tr>
	<%}%>
		<tr>
			<td colspan="3"><strong>TOTAL</strong></td>
			<td class="elevenPixTopBot" align="right"><strong><%=CommonUtil.formatFloat(dSumOverall, true)%></strong></td>
		<%for(int j = 0; j < dSumTeam.length; j++){
			if(dSumTeam[j] == 0)
				strTemp = "&nbsp;";
			else
				strTemp = CommonUtil.formatFloat(dSumTeam[j], true);
		%>
			<td align="right" class="elevenPixTopBot"><strong><%=strTemp%></strong></td>
		<%}%>
			<td class="elevenPixTopBot" align="right"><strong><%=CommonUtil.formatFloat(dSumOverall, true)%></strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="elevenPix">
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td class="elevenPix">Rates:</td>
		</tr>
		<tr>
			<td class="elevenPix">&nbsp;&nbsp;&nbsp;&nbsp;<%=(String)vExchangeRates.remove(0)%></td>
		</tr>
	<%
	for(int i = 0; i < vExchangeRates.size(); i += 2){%>
		<tr>
			<td class="elevenPix">1 <%=(String)vExchangeRates.elementAt(i)%> = 
				Php<%=CommonUtil.formatFloat((String)vExchangeRates.elementAt(i+1), true)%></td>
		</tr>
	<%}%>
	</table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>