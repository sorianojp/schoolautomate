<%@ page language="java" import="utility.*,Accounting.PaymentReports,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>OR Prooflist</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">

TABLE.smallFont {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.smallFont {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.smallFontTopBottom {
	border-top: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

</style>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body onLoad="window.print();">
<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;

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
								"ACCOUNTING-BUDGET","OR_prooflist.jsp");
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
	
	Vector vRetResult = null;
	Vector vCurrencies = null;
	PaymentReports pr = new PaymentReports();
	int iWidth = 0;
	
	vRetResult = pr.generateORProoflist(dbOP, request);
	if(vRetResult == null)
		strErrMsg = pr.getErrMsg();
	else{		
		vCurrencies = pr.getCurrenciesForReport(dbOP, request);
		if(vCurrencies == null){
			strErrMsg = pr.getErrMsg();
			vRetResult = null;
		}
	}
	
	if(vRetResult != null && vRetResult.size() > 0){
		iWidth = 30/(vCurrencies.size()/4);
		double[] dSum = new double[vCurrencies.size()/4];
%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25" colspan="4" align="center"><strong>:::: OR PROOFLIST::::</strong></font></td>
		</tr>
	</table>


	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="smallFont">
		<tr>
			<td height="25" width="7%" align="center" class="smallFont"><strong>OR NO. </strong></td>
			<td width="12%" align="center" class="smallFont"><strong>DATE OF ISSUANCE </strong></td>
			<td width="23%" align="center" class="smallFont"><strong>NAME</strong></td>
		<%for(int i = 0; i < vCurrencies.size(); i += 4){%>
			<td width="<%=iWidth%>%" align="center" class="smallFont">
				<strong>AMOUNT-<%=(String)vCurrencies.elementAt(i+2)%></strong></td>
		<%}%>
			<td width="27%" align="center" class="smallFont"><strong>PARTICULARS </strong></td>
		</tr>
	<%	boolean bolIsValid = true;
		for(int i = 0; i < vRetResult.size(); i += 8){
			bolIsValid = ((String)vRetResult.elementAt(i+7)).equals("1");
	%>
		<tr>
			<td height="25" class="smallFont" align="center"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="smallFont"><%=(String)vRetResult.elementAt(i+2)%></td>
			<%
				if(bolIsValid)
					strTemp = (String)vRetResult.elementAt(i+3);
				else
					strTemp = "-CANCELLED-";
			%>
			<td class="smallFont"><%=strTemp%></td>
		<%	strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+4), true);			
			strErrMsg = (String)vRetResult.elementAt(i+5);
			int iCount = 0;
			for(int j = 0; j < vCurrencies.size(); j += 4, iCount++){
				if(strErrMsg.equals((String)vCurrencies.elementAt(j)) && bolIsValid){
					strTemp2 = strTemp;
					dSum[iCount] += Double.parseDouble(ConversionTable.replaceString(strTemp2, ",", ""));
				}
				else
					strTemp2 = "-&nbsp;&nbsp;";
		%>
			<td class="smallFont" align="right"><%=strTemp2%></td>
		<%}
			if(bolIsValid)
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6));
			else
				strTemp = "-CANCELLED-";
		%>
			<td class="smallFont"><%=strTemp%></td>
		</tr>
	<%}%>
		<tr>
			<td height="15" colspan="<%=4+vCurrencies.size()/4%>"></td>
		</tr>
		<tr>
			<td height="20" colspan="2" class="smallFontTopBottom" align="center"><strong>SUBTOTAL</strong></td>
			<td>&nbsp;</td>
		<%for(int i = 0; i < dSum.length; i ++){
			if(dSum[i] == 0)
				strTemp = "-";
			else
				strTemp = CommonUtil.formatFloat(dSum[i], true);
			
			strErrMsg = "";			
			if(!strTemp.equals("-")){
				if(((String)vCurrencies.elementAt((i*4)+3)).equals("1"))
					strErrMsg = "";
				else
					strErrMsg = (String)vCurrencies.elementAt((i*4)+2);
			}
			else
				strTemp += "&nbsp;&nbsp;";
		%>
			<td class="smallFontTopBottom" align="right"><strong><%=strErrMsg%><%=strTemp%></strong></td>
		<%}%>
		</tr>
	</table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
