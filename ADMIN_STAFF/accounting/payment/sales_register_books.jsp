<%@ page language="java" import="utility.*,Accounting.PaymentReports,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Sales Register</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
	
	function GoBack(){
		location = "./sales_reports_main.jsp";
	}
	
	function GenerateReport(){		
		document.form_.generate_report.value = "1";
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function PrintPg(){
		document.form_.generate_report.value = "";
		document.form_.print_page.value = "1";
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./sales_register_books_print.jsp" />
	<% 
		return;}

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
								"ACCOUNTING-BUDGET","sales_register_books.jsp");
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
	
	int iWidth = 0;
    int iForexCount = 0;
	
	Vector vValues = null;
	Vector vSumReport = null;
	Vector vRetResult = null;
	Vector vCurrencies = null;
	Vector vForex = new Vector();
	PaymentReports pr = new PaymentReports();
	
	if(WI.fillTextValue("generate_report").length() > 0){
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
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="sales_register_books.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="4" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: BOOKS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
			<td width="10%" align="right">
				<a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0"></a>&nbsp;</td> 
		</tr>
	<!--
		<tr>
			<td height="25">&nbsp;</td>
		    <td width="17%">Payment Date: </td>
		    <td colspan="2">
				<input name="date" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
	-->
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="17%">Month</td>
		    <td colspan="2">
				<select name="month">
              		<%=dbOP.loadComboMonth(WI.fillTextValue("month"))%>
            	</select>
		      	&nbsp;
				<select name="year" size="1" id="year">
					<%=dbOP.loadComboYear(WI.fillTextValue("year"), 1, 1)%>
		  		</select>
			</td>
		</tr>
		<tr>
			<td height="40" colspan="2">&nbsp;</td>
			<td colspan="2" valign="middle"><a href="javascript:GenerateReport();">
				<img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to generate sales register report.</font></td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){
	iWidth = 36/(vCurrencies.size()/4);
	double[] dCurSum = new double[vCurrencies.size()/4];
	double dPesoTotal = 0d;
%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right"><a href="javascript:PrintPg();">
				<img src="../../../images/print.gif" border="0"></a></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td width="10%" rowspan="2" align="center" class="thinborder"><strong>DATE</strong></td>
			<td width="28%" rowspan="2" align="center" class="thinborder"><strong>CUSTOMER</strong></td>
			<td width="10%" rowspan="2" align="center" class="thinborder"><strong>INV#</strong></td>
			<td height="13" colspan="<%=vCurrencies.size()/4%>" align="center" class="thinborder"><strong>SALES</strong></td>
			<td width="16%" rowspan="2" align="center" class="thinborder"><strong>PESO EQUIVALENT </strong></td>
		</tr>
		<tr>
		<%for(int i = 0; i < vCurrencies.size(); i += 4){%>
		  	<td height="12" width="<%=iWidth%>%" align="center" class="thinborder">
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
			<td height="25" class="thinborder" align="right"><%=strTemp%>&nbsp;</td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder" align="right"><%=(String)vRetResult.elementAt(i+2)%></td>
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
			<td class="thinborder" align="right"><%=strTemp%></td>
		<%}%>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+5), true)%></td>
		</tr>
	<%}%>
		<tr>
			<td height="25" colspan="3" class="thinborder">&nbsp;<strong>TOTAL</strong></td>
		<%	int iCount = 0;
			for(int j = 0; j < vCurrencies.size(); j += 4, iCount++){
				if(dCurSum[iCount] == 0)
					strTemp = "-";
				else
					strTemp = CommonUtil.formatFloat(dCurSum[iCount], true);
		%>
		    <td class="thinborder" align="right"><strong><%=strTemp%></strong></td>
		<%}%>
		    <td class="thinborder" align="right"><strong><%=CommonUtil.formatFloat(dPesoTotal, true)%></strong></td>
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
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td class="thinborderBOTTOMLEFT">&nbsp;</td>
		    <td class="thinborderBOTTOM">Summary</td>
	    <%if(iForexCount > 0){%>
			<td height="13" colspan="<%=iForexCount%>" align="center" class="thinborder">Export Sales</td>
		<%}%>
			<td align="center" class="thinborder">Local Sales</td>
			<td align="center" class="thinborder">Peso Equivalent</td>
		</tr>
		<tr>
			<td height="25" class="thinborderBOTTOMLEFT" width="38%">&nbsp;</td>
			<td class="thinborderBOTTOM" width="10%">&nbsp;</td>
		<%for(int i = 0; i < vForex.size(); i += 4){%>
		  	<td height="12" width="<%=iWidth%>%" align="center" class="thinborderBOTTOM"><%=((String)vForex.elementAt(i+1)).toUpperCase()%></td>
		<%}%>
			<td width="<%=iWidth%>%" class="thinborderBOTTOM">&nbsp;</td>
			<td width="16%" class="thinborderBOTTOM">&nbsp;</td>
	  	</tr>
	<%	for(int i = 0; i < vSumReport.size(); i += 5){
			vValues = (Vector)vSumReport.elementAt(i+2);
	%>
		<tr>
			<td height="25" class="thinborderBOTTOMLEFT" width="38%">&nbsp;</td>
			<td class="thinborderBOTTOM" width="10%"><%=(String)vSumReport.elementAt(i+1)%></td>
		<%for(int j = 0; j < vValues.size(); j++){
			strTemp = (String)vValues.elementAt(j);
			if(strTemp == null)
				strTemp = "&nbsp;";
			else{
				dSum[j] += Double.parseDouble(strTemp);
				strTemp = CommonUtil.formatFloat(strTemp, true);
			}
		%>
		  	<td height="12" width="<%=iWidth%>%" align="right" class="thinborderBOTTOM"><%=strTemp%></td>
		<%}
			
			strTemp = (String)vSumReport.elementAt(i+3);
			if(strTemp == null)
				strTemp = "&nbsp;";
			else{
				dSumLocal += Double.parseDouble(strTemp);
				strTemp = CommonUtil.formatFloat(strTemp, true);
			}
		%>
			<td width="<%=iWidth%>%" class="thinborderBOTTOM" align="right"><%=strTemp%></td>
		<%
			strTemp = (String)vSumReport.elementAt(i+4);
			if(strTemp == null)
				strTemp = "&nbsp;";
			else{
				dSumOverall += Double.parseDouble(strTemp);
				strTemp = CommonUtil.formatFloat(strTemp, true);
			}
		%>
			<td width="16%" class="thinborderBOTTOM" align="right"><%=strTemp%></td>
	  	</tr>
	<%}%>
		<tr>
			<td height="25" class="thinborderBOTTOMLEFT">&nbsp;</td>
			<td class="thinborderBOTTOM">TOTAL</td>
			<%if(iForexCount > 0){
				for(int i = 0; i < iForexCount; i++){
					if(dSum[i] == 0)
						strTemp = "-";
					else
						strTemp = CommonUtil.formatFloat(dSum[i], true);
				%>
					<td class="thinborderBOTTOM" align="right"><%=strTemp%></td>
			<%}}
			
				if(dSumLocal == 0)
					strTemp = "-";
				else
					strTemp = CommonUtil.formatFloat(dSumLocal, true);
			%>
			<td class="thinborderBOTTOM" align="right"><%=strTemp%></td>
			<%
				if(dSumOverall == 0)
					strTemp = "-";
				else
					strTemp = CommonUtil.formatFloat(dSumOverall, true);
			%>
			<td class="thinborderBOTTOM" align="right"><%=strTemp%></td>
		</tr>
	</table>
<%}%>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="print_page">
	<input type="hidden" name="generate_report">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>