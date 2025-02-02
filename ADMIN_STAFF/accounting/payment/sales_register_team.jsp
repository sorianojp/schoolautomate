<%@ page language="java" import="utility.*,Accounting.PaymentReports,java.util.Vector " %>
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
		<jsp:forward page="./sales_register_team_print.jsp" />
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
								"ACCOUNTING-BUDGET","sales_register_team.jsp");
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
	
	Integer iObjTemp = null;
	int iIndexOf = 0;
	Vector vTeams = null;
	Vector vValues = null;
	Vector vRetResult = null;
	PaymentReports pr = new PaymentReports();
	
	if(WI.fillTextValue("generate_report").length() > 0){
		vRetResult = pr.generateSalesRegisterTeam(dbOP, request);
		if(vRetResult == null)
			strErrMsg = pr.getErrMsg();
		else{
			vTeams = pr.getTeamsForReports(dbOP, request);
			if(vTeams == null){
				vRetResult = null;
				strErrMsg = pr.getErrMsg();
			}
		}
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="sales_register_team.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="4" bgcolor="#A49A6A"><div align="center">

				<font color="#FFFFFF"><strong>:::: PER TEAM ::::</strong></font></div></td>
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
	double dRowSum = 0d;
	double dSumOverall = 0d;
	double[] dSumTeam = new double[vTeams.size()/5];
%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right"><a href="javascript:PrintPg();">
				<img src="../../../images/print.gif" border="0"></a></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" align="center" class="thinborder"><strong>DATE</strong></td>
			<td align="center" class="thinborder"><strong>CUSTOMER</strong></td>
			<td align="center" class="thinborder"><strong>INV #</strong></td>
			<td align="center" class="thinborder"><strong>PESO EQUIVALENT </strong></td>
		<%for(int i = 0; i < vTeams.size(); i += 5){%>
			<td align="center" class="thinborder"><strong><%=(String)vTeams.elementAt(i+1)%></strong></td>
		<%}%>
			<td align="center" class="thinborder"><strong>TOTAL</strong></td>
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
			<td height="25" class="thinborder" align="right"><%=strTemp%>&nbsp;</td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder" align="right"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+4), true)%></td>
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
			<td align="right" class="thinborder"><%=strTemp%></td>
		<%}%>
			<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dRowSum, true)%></td>
		</tr>
	<%}%>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td class="thinborder">TOTAL</td>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat(dSumOverall, true)%></td>
		<%for(int j = 0; j < dSumTeam.length; j++){
			if(dSumTeam[j] == 0)
				strTemp = "&nbsp;";
			else
				strTemp = CommonUtil.formatFloat(dSumTeam[j], true);
		%>
			<td align="right" class="thinborder"><%=strTemp%></td>
		<%}%>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat(dSumOverall, true)%></td>
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