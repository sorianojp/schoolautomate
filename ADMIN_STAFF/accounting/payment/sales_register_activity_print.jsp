<%@ page language="java" import="utility.*,Accounting.PaymentReports,Accounting.billing.BillingTsuneishi,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Sales Register Per Activity</title>
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
								"ACCOUNTING-BUDGET","sales_register_activity_print.jsp");
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
	int iWidth = 0;
	Vector vExchangeRates = null;
	Vector vCategories = null;
	Vector vRetResult = null;
	PaymentReports pr = new PaymentReports();
	BillingTsuneishi billTsu = new BillingTsuneishi();	

	vRetResult = pr.generateSalesRegisterActivity(dbOP, request);
	if(vRetResult == null)
		strErrMsg = pr.getErrMsg();
	else{
		vExchangeRates = pr.getExchangeRatesForDate(dbOP, request);
		vCategories = billTsu.operateOnInvoiceCatg(dbOP, request, 4);
		if(vCategories == null){
			vRetResult = null;
			strErrMsg = billTsu.getErrMsg();
		}
		else
			iWidth = 36/(vCategories.size()/3);
	}
	
	if(vRetResult != null && vRetResult.size() > 0){
		double[] dSumCategory = new double[vCategories.size()/3];
		double dSumOverall = 0d;
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
			<td width="10%" align="center" class="elevenPix"><strong>DATE</strong></td>
			<td width="28%" align="center" class="elevenPix"><strong>CUSTOMER</strong></td>
			<td width="10%" align="center" class="elevenPix"><strong>INV #</strong></td>
			<td width="16%" align="center" class="elevenPix"><strong>PESO EQUIVALENT </strong></td>
		<%for(int i = 0; i < vCategories.size(); i += 3){%>
			<td width="<%=iWidth%>%" align="center" class="elevenPix"><strong><%=(String)vCategories.elementAt(i+2)%></strong></td>
		<%}%>
		</tr>
	<%	for(int i = 0; i < vRetResult.size(); i += 6){
			dSumOverall += Double.parseDouble((String)vRetResult.elementAt(i+3));
	%>
		<tr>
			<%
				strTemp = (String)vRetResult.elementAt(i+1);
				strTemp = strTemp.substring(0, strTemp.length()-6);
			%>
			<td align="right" class="elevenPix"><%=strTemp%>&nbsp;</td>
			<td class="elevenPix"><%=(String)vRetResult.elementAt(i+5)%></td>
			<td class="elevenPix" align="right"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="elevenPix" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+3), true)%></td>
		<%	int iCount = 0;
			strErrMsg = (String)vRetResult.elementAt(i+4);
			for(int j = 0; j < vCategories.size(); j += 3, iCount++){				
				strTemp = (String)vCategories.elementAt(j);				
				if(strTemp.equals(strErrMsg)){
					dSumCategory[iCount] += Double.parseDouble((String)vRetResult.elementAt(i+3));
					strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+3), true);
				}
				else
					strTemp = "-&nbsp;&nbsp;&nbsp;";
		%>
			<td class="elevenPix" align="right"><%=strTemp%></td>
		<%}%>
		</tr>
	<%}%>
		<tr>
			<td colspan="3"><strong>TOTAL</strong></td>
			<td class="elevenPix" align="right"><strong><%=CommonUtil.formatFloat(dSumOverall, true)%></strong></td>
		<%for(int i = 0; i < dSumCategory.length; i++){
			if(dSumCategory[i] == 0)
				strTemp = "-&nbsp;&nbsp;&nbsp;";
			else
				strTemp = CommonUtil.formatFloat(dSumCategory[i], true);
		%>
			<td class="elevenPixTopBot" align="right"><strong><%=strTemp%></strong></td>
		<%}%>
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
				Php<%=(String)vExchangeRates.elementAt(i+1)%></td>
		</tr>
	<%}%>
	</table>
<%}%>
	
</body>
</html>
<%
dbOP.cleanUP();
%>