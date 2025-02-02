<%@ page language="java" import="utility.*,Accounting.PaymentReports,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Sales Register - Books</title>
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
								"ACCOUNTING-BUDGET","sales_register_books_print.jsp");
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
    int iForexCount = 0;
	
	Vector vValues = null;
	Vector vSumReport = null;
	Vector vRetResult = null;
	Vector vCurrencies = null;
	Vector vForex = new Vector();
	Vector vExchangeRates = new Vector();
	PaymentReports pr = new PaymentReports();
	
	vRetResult = pr.generateSalesRegisterReport(dbOP, request);
	if(vRetResult == null)
		strErrMsg = pr.getErrMsg();
	else{
		vCurrencies = pr.getCurrenciesForReport(dbOP, request);
		if(vCurrencies == null){
			strErrMsg = pr.getErrMsg();
			vRetResult = null;
		}
		else{
			vExchangeRates = pr.getExchangeRatesForDate(dbOP, request);
			vSumReport = (Vector)vRetResult.remove(0);
			
			strTemp = " select count(*) from currency where is_valid = 1 and is_local = 0 ";
			iForexCount = Integer.parseInt(dbOP.getResultOfAQuery(strTemp, 0));
			
			for(int i = 0; i < vCurrencies.size(); i += 4){
				if(((String)vCurrencies.elementAt(i+3)).equals("1"))
					continue;
				
				vForex.addElement((String)vCurrencies.elementAt(i));
				vForex.addElement((String)vCurrencies.elementAt(i+1));
				vForex.addElement((String)vCurrencies.elementAt(i+2));
				vForex.addElement((String)vCurrencies.elementAt(i+3));
			}
		}
	}

	if(vRetResult != null && vRetResult.size() > 0){
		iWidth = 36/(vCurrencies.size()/4);
		double[] dCurSum = new double[vCurrencies.size()/4];
		double dPesoTotal = 0d;
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
			<td width="10%" rowspan="2" align="center" class="elevenPix"><strong>DATE</strong></td>
			<td width="28%" rowspan="2" align="center" class="elevenPix"><strong>CUSTOMER</strong></td>
			<td width="10%" rowspan="2" align="center" class="elevenPix"><strong>INV#</strong></td>
			<td colspan="<%=vCurrencies.size()/4%>" align="center" class="thinborderBOTTOM"><strong>SALES</strong></td>
			<td width="16%" rowspan="2" align="center" class="elevenPix"><strong>PESO EQUIVALENT </strong></td>
		</tr>
		<tr>
		<%for(int i = 0; i < vCurrencies.size(); i += 4){%>
		  	<td width="<%=iWidth%>%" align="center" class="elevenPix">
				<strong><%=((String)vCurrencies.elementAt(i+1)).toUpperCase()%></strong></td>
		<%}%>
	  	</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 6){%>
		<tr>
			<%
				dPesoTotal += Double.parseDouble((String)vRetResult.elementAt(i+5));
				strTemp = (String)vRetResult.elementAt(i);
				strTemp = strTemp.substring(0, strTemp.length()-6);
			%>
			<td class="elevenPix" align="right"><%=strTemp%>&nbsp;</td>
			<td class="elevenPix"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="elevenPix" align="right"><%=(String)vRetResult.elementAt(i+2)%></td>
		<%	int iCount = 0;
			strErrMsg = (String)vRetResult.elementAt(i+4);
			for(int j = 0; j < vCurrencies.size(); j += 4, iCount++){
				strTemp = (String)vCurrencies.elementAt(j);				
				if(strTemp.equals(strErrMsg)){
					dCurSum[iCount] += Double.parseDouble((String)vRetResult.elementAt(i+3));
					strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+3), true);
				}
				else
					strTemp = "&nbsp;";
		%>
			<td class="elevenPix" align="right"><%=strTemp%></td>
		<%}%>
			<td class="elevenPix" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+5), true)%></td>
		</tr>
	<%}%>
		<tr>
			<td colspan="3" class="elevenPix">&nbsp;<strong>TOTAL</strong></td>
		<%	int iCount = 0;
			for(int j = 0; j < vCurrencies.size(); j += 4, iCount++){
				if(dCurSum[iCount] == 0)
					strTemp = "-";
				else
					strTemp = CommonUtil.formatFloat(dCurSum[iCount], true);
		%>
		    <td class="elevenPixTopBot" align="right"><strong><%=strTemp%></strong></td>
		<%}%>
		    <td class="elevenPixTopBot" align="right"><strong><%=CommonUtil.formatFloat(dPesoTotal, true)%></strong></td>
		</tr>
	</table>
<%}

//iForexCount
if(vSumReport != null && vSumReport.size() > 0){
	double[] dSum = null;
	double dSumLocal = 0d;
	double dSumOverall = 0d;
	if(iForexCount > 0)
		dSum = new double[iForexCount];
%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="elevenPix">
		<tr>
			<td width="38%" rowspan="<%=3+(vSumReport.size()/5)%>" class="elevenPix" valign="top">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="elevenPix">
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
			</td>
		    <td class="elevenPix">Summary</td>
	    <%if(iForexCount > 0){%>
			<td height="13" colspan="<%=iForexCount%>" align="center" class="elevenPix">Export Sales</td>
		<%}%>
			<td align="center" class="elevenPix">Local Sales</td>
			<td align="center" class="elevenPix">Peso Equivalent</td>
		</tr>
		<tr>
			<td class="elevenPix" width="10%">&nbsp;</td>
		<%for(int i = 0; i < vForex.size(); i += 4){%>
		  	<td height="12" width="<%=iWidth%>%" align="center" class="elevenPix"><%=((String)vForex.elementAt(i+1)).toUpperCase()%></td>
		<%}%>
			<td width="<%=iWidth%>%" class="elevenPix">&nbsp;</td>
			<td width="16%" class="elevenPix">&nbsp;</td>
	  	</tr>
	<%	for(int i = 0; i < vSumReport.size(); i += 5){
			vValues = (Vector)vSumReport.elementAt(i+2);
	%>
		<tr>
			<td class="elevenPix" width="10%"><%=(String)vSumReport.elementAt(i+1)%></td>
		<%for(int j = 0; j < vValues.size(); j++){
			strTemp = (String)vValues.elementAt(j);
			if(strTemp == null)
				strTemp = "&nbsp;";
			else{
				dSum[j] += Double.parseDouble(strTemp);
				strTemp = CommonUtil.formatFloat(strTemp, true);
			}
		%>
		  	<td height="12" width="<%=iWidth%>%" align="right" class="elevenPix"><%=strTemp%></td>
		<%}
			
			strTemp = (String)vSumReport.elementAt(i+3);
			if(strTemp == null)
				strTemp = "&nbsp;";
			else{
				dSumLocal += Double.parseDouble(strTemp);
				strTemp = CommonUtil.formatFloat(strTemp, true);
			}
		%>
			<td width="<%=iWidth%>%" class="elevenPix" align="right"><%=strTemp%></td>
		<%
			strTemp = (String)vSumReport.elementAt(i+4);
			if(strTemp == null)
				strTemp = "&nbsp;";
			else{
				dSumOverall += Double.parseDouble(strTemp);
				strTemp = CommonUtil.formatFloat(strTemp, true);
			}
		%>
			<td width="16%" class="elevenPix" align="right"><%=strTemp%></td>
	  	</tr>
	<%}%>
		<tr>
			<td class="elevenPix">TOTAL</td>
			<%if(iForexCount > 0){
				for(int i = 0; i < iForexCount; i++){
					if(dSum[i] == 0)
						strTemp = "-";
					else
						strTemp = CommonUtil.formatFloat(dSum[i], true);
				%>
					<td class="elevenPixTopBot" align="right"><%=strTemp%></td>
			<%}}
			
				if(dSumLocal == 0)
					strTemp = "-";
				else
					strTemp = CommonUtil.formatFloat(dSumLocal, true);
			%>
			<td class="elevenPixTopBot" align="right"><%=strTemp%></td>
			<%
				if(dSumOverall == 0)
					strTemp = "-";
				else
					strTemp = CommonUtil.formatFloat(dSumOverall, true);
			%>
			<td class="elevenPixTopBot" align="right"><%=strTemp%></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="elevenPix">
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td width="28%" class="elevenPix">Prepared by:</td>
			<td width="22%" class="elevenPix">Noted by:</td>
			<td width="50%" class="elevenPix">Approved by:</td>
		</tr>
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td class="elevenPix">R.V. Caballero </td>
		    <td class="elevenPix">Rachel O. Nufable </td>
		    <td class="elevenPix">Segismundo Exaltaction Jr. </td>
		</tr>
		<tr>
		  	<td class="elevenPix">Asst. Mgt. Staff </td>
		  	<td class="elevenPix">Assistant Supervisor </td>
		  	<td class="elevenPix">General Manager </td>
	  </tr>
	</table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>