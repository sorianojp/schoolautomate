<%@ page language="java" import="utility.*,java.util.Vector, hr.GovtEvaluation" %>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Values Print Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<body onLoad="window.print();">
<script language="javascript" src="../../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null; 
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Performance Evaluation Management-Create Review Period","values.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-PERFORMANCE EVALUATION MANAGEMENT"),"0"));
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
	
	int iTotal = 0;
	double dAverage = 0d;
	int iSum10 = 0;
	int iSum8 = 0;
	int iSum6 = 0;
	int iSum4 = 0;
	int iSum2 = 0;
	Vector vEmpRec = null;
	Vector vRetResult = null;
	Vector vSupRates = null;
    Vector vSubRates = null;
    Vector vClientRates = null;
    Vector vPeerRates = null;
	GovtEvaluation eval = new GovtEvaluation();
	
	enrollment.Authentication authentication = new enrollment.Authentication();
	vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	
	if (vEmpRec == null || vEmpRec.size() == 0){
		if (strErrMsg == null || strErrMsg.length() == 0)
			strErrMsg = authentication.getErrMsg();
	}
		
	if(vEmpRec != null && vEmpRec.size() > 0){		
		vRetResult = eval.getEmployeeValuesRating(dbOP, request, (String)vEmpRec.elementAt(0));
		if(vRetResult == null)
			strErrMsg = eval.getErrMsg();
		else{
			vSupRates = (Vector)vRetResult.remove(0);
			vSubRates = (Vector)vRetResult.remove(0);
			vClientRates = (Vector)vRetResult.remove(0);
			vPeerRates = (Vector)vRetResult.remove(0);
		}
	}
%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr> 
			<td height="20" width="25%">Name of Ratee: </td>
		    <td width="25%">Name of Ratee: </td>
		    <td width="25%">Name of Ratee: </td>
		    <td width="25%">Name of Ratee: </td>
		</tr>
		<tr>
			<td height="25">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td width="80%" class="thinborderBOTTOM">
							<%=WebInterface.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3), 4)%></td>
						<td width="20%">&nbsp;</td>
					</tr>
				</table>
			</td>
			<td>
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td width="80%" class="thinborderBOTTOM"><%=WebInterface.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3), 4)%></td>
						<td width="20%">&nbsp;</td>
					</tr>
				</table>
			</td>
			<td>
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td width="80%" class="thinborderBOTTOM"><%=WebInterface.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3), 4)%></td>
						<td width="20%">&nbsp;</td>
					</tr>
				</table>
			</td>
			<td>
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td width="80%" class="thinborderBOTTOM"><%=WebInterface.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3), 4)%></td>
						<td width="20%">&nbsp;</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td height="25"><strong>SUPREVISOR'S RATING</strong></td>
		    <td><strong>SUBORDINATE'S RATING</strong></td>
		    <td><strong>CLIENT'S RATING</strong></td>
		    <td><strong>PEER'S RATING</strong></td>
		</tr>
	</table>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="24%">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder">
					<tr>
						<td height="25" align="center" class="thinborder"><strong>Values</strong></td>
						<td align="center" class="thinborder" colspan="5"><strong>Rating</strong></td>
					</tr>
					<tr>
						<td height="25" class="thinborder" width="70%">&nbsp;</td>
						<td width="6%" align="center" class="thinborder"><strong>10</strong></td>
						<td width="6%" align="center" class="thinborder"><strong>8</strong></td>
						<td width="6%" align="center" class="thinborder"><strong>6</strong></td>
						<td width="6%" align="center" class="thinborder"><strong>4</strong></td>
						<td width="6%" align="center" class="thinborder"><strong>2</strong></td>
					</tr>
				<%
				iSum2 = 0; iSum4 = 0; iSum6 = 0; iSum8 = 0; iSum10 = 0;
				for(int i = 0; i < vSupRates.size(); i += 2){
					strTemp = WI.getStrValue((String)vSupRates.elementAt(i+1));
				%>
					<tr>
						<td height="25" class="thinborder">&nbsp;<%=(String)vSupRates.elementAt(i)%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("10")){
								iSum10 += 10;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("8")){
								iSum8 += 8;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("6")){
								iSum6 += 6;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("4")){
								iSum4 += 4;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("2")){
								iSum2 += 2;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
					</tr>
				<%}%>
					<tr>
						<td height="25" align="center" class="thinborder"><strong>TOTAL BY COLUMN</strong></td>
						<td align="center" class="thinborder"><%=iSum10%></td>
						<td align="center" class="thinborder"><%=iSum8%></td>
						<td align="center" class="thinborder"><%=iSum6%></td>
						<td align="center" class="thinborder"><%=iSum4%></td>
						<td align="center" class="thinborder"><%=iSum2%></td>
					</tr>
					<%
							iTotal = iSum2 + iSum4 + iSum6 + iSum8 + iSum10;
							dAverage = (double)iTotal/(double)(vSubRates.size()/2);
						%>
					<tr>
						<td height="25" align="center" class="thinborder"><strong>Grand Total</strong></td>
						<td colspan="5" align="center" class="thinborder"><%=iTotal%></td>
					</tr>
					<tr>
						<td height="25" align="center" class="thinborder">
							<strong>Average Rating</strong><br>
							<font size="1">(Grand Total Divide by <%=vSupRates.size()/2%>)</font></td>
						<td colspan="5" align="center" class="thinborder"><%=CommonUtil.formatFloat(dAverage, false)%></td>
					</tr>
				</table>
				<table width="100%" cellpadding="0" cellspacing="0" border="0">
					<tr>
						<td height="30" colspan="2">&nbsp;</td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(10) O - (Outstanding)</font></td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(8) VS - (Very Satisfactory)</font></td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(6) S - (Satisfactory)</font></td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(4) US - (Unsatisfactory)</font></td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(2) P - (Poor)</font></td>
					</tr>
					<tr>
						<td height="40" colspan="2">&nbsp;</td>
					</tr>
					<tr>
						<td height="25" width="70%" class="thinborderBOTTOM">&nbsp;</td>
						<td width="30%">&nbsp;</td>
					</tr>
					<tr>
						<td height="25" valign="top" align="center">Name and Signature of Rater</td>
						<td>&nbsp;</td>
					</tr>
					<tr>
						<td height="40" width="70%" class="thinborderBOTTOM">&nbsp;</td>
						<td width="30%">&nbsp;</td>
					</tr>
					<tr>
						<td height="25" valign="top" align="center">Date Rated </td>
						<td>&nbsp;</td>
					</tr>
				</table>
			</td>
		    <td width="1%">&nbsp;</td>
			<td width="24%">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder">
					<tr>
						<td height="25" align="center" class="thinborder"><strong>Values</strong></td>
						<td align="center" class="thinborder" colspan="5"><strong>Rating</strong></td>
					</tr>
					<tr>
						<td height="25" class="thinborder" width="70%">&nbsp;</td>
						<td width="6%" align="center" class="thinborder"><strong>10</strong></td>
						<td width="6%" align="center" class="thinborder"><strong>8</strong></td>
						<td width="6%" align="center" class="thinborder"><strong>6</strong></td>
						<td width="6%" align="center" class="thinborder"><strong>4</strong></td>
						<td width="6%" align="center" class="thinborder"><strong>2</strong></td>
					</tr>
				<%
				iSum2 = 0; iSum4 = 0; iSum6 = 0; iSum8 = 0; iSum10 = 0;
				for(int i = 0; i < vSubRates.size(); i += 2){
					strTemp = WI.getStrValue((String)vSubRates.elementAt(i+1));
				%>
					<tr>
						<td height="25" class="thinborder">&nbsp;<%=(String)vSubRates.elementAt(i)%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("10")){
								iSum10 += 10;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("8")){
								iSum8 += 8;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("6")){
								iSum6 += 6;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("4")){
								iSum4 += 4;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("2")){
								iSum2 += 2;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
					</tr>
				<%}%>
					<tr>
					<tr>
						<td height="25" align="center" class="thinborder"><strong>TOTAL BY COLUMN</strong></td>
						<td align="center" class="thinborder"><%=iSum10%></td>
						<td align="center" class="thinborder"><%=iSum8%></td>
						<td align="center" class="thinborder"><%=iSum6%></td>
						<td align="center" class="thinborder"><%=iSum4%></td>
						<td align="center" class="thinborder"><%=iSum2%></td>
					</tr>
					<%
							iTotal = iSum2 + iSum4 + iSum6 + iSum8 + iSum10;
							dAverage = (double)iTotal/(double)(vSubRates.size()/2);
						%>
					<tr>
						<td height="25" align="center" class="thinborder"><strong>Grand Total</strong></td>
						<td colspan="5" align="center" class="thinborder"><%=iTotal%></td>
					</tr>
					<tr>
						<td height="25" align="center" class="thinborder">
							<strong>Average Rating</strong><br>
							<font size="1">(Grand Total Divide by <%=vSubRates.size()/2%>)</font></td>
						<td colspan="5" align="center" class="thinborder"><%=CommonUtil.formatFloat(dAverage, false)%></td>
					</tr>
				</table>
				<table width="100%" cellpadding="0" cellspacing="0" border="0">
					<tr>
						<td height="30" colspan="2">&nbsp;</td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(10) O - (Outstanding)</font></td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(8) VS - (Very Satisfactory)</font></td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(6) S - (Satisfactory)</font></td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(4) US - (Unsatisfactory)</font></td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(2) P - (Poor)</font></td>
					</tr>
					<tr>
						<td height="40" colspan="2">&nbsp;</td>
					</tr>
					<tr>
						<td height="25" width="70%" class="thinborderBOTTOM">&nbsp;</td>
						<td width="30%">&nbsp;</td>
					</tr>
					<tr>
						<td height="25" valign="top" align="center">Name and Signature of Rater</td>
						<td>&nbsp;</td>
					</tr>
					<tr>
						<td height="40" width="70%" class="thinborderBOTTOM">&nbsp;</td>
						<td width="30%">&nbsp;</td>
					</tr>
					<tr>
						<td height="25" valign="top" align="center">Date Rated </td>
						<td>&nbsp;</td>
					</tr>
				</table>
			</td>
		    <td width="1%">&nbsp;</td>
			<td width="24%">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder">
					<tr>
						<td height="25" align="center" class="thinborder"><strong>Values</strong></td>
						<td align="center" class="thinborder" colspan="5"><strong>Rating</strong></td>
					</tr>
					<tr>
						<td height="25" class="thinborder" width="70%">&nbsp;</td>
						<td width="6%" align="center" class="thinborder"><strong>10</strong></td>
						<td width="6%" align="center" class="thinborder"><strong>8</strong></td>
						<td width="6%" align="center" class="thinborder"><strong>6</strong></td>
						<td width="6%" align="center" class="thinborder"><strong>4</strong></td>
						<td width="6%" align="center" class="thinborder"><strong>2</strong></td>
					</tr>
				<%
				iSum2 = 0; iSum4 = 0; iSum6 = 0; iSum8 = 0; iSum10 = 0;
				for(int i = 0; i < vClientRates.size(); i += 2){
					strTemp = WI.getStrValue((String)vClientRates.elementAt(i+1));
				%>
					<tr>
						<td height="25" class="thinborder">&nbsp;<%=(String)vClientRates.elementAt(i)%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("10")){
								iSum10 += 10;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("8")){
								iSum8 += 8;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("6")){
								iSum6 += 6;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("4")){
								iSum4 += 4;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("2")){
								iSum2 += 2;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
					</tr>
				<%}%>
					<tr>
						<td height="25" align="center" class="thinborder"><strong>TOTAL BY COLUMN</strong></td>
						<td align="center" class="thinborder"><%=iSum10%></td>
						<td align="center" class="thinborder"><%=iSum8%></td>
						<td align="center" class="thinborder"><%=iSum6%></td>
						<td align="center" class="thinborder"><%=iSum4%></td>
						<td align="center" class="thinborder"><%=iSum2%></td>
					</tr>
					<%
							iTotal = iSum2 + iSum4 + iSum6 + iSum8 + iSum10;
							dAverage = (double)iTotal/(double)(vSubRates.size()/2);
						%>
					<tr>
						<td height="25" align="center" class="thinborder"><strong>Grand Total</strong></td>
						<td colspan="5" align="center" class="thinborder"><%=iTotal%></td>
					</tr>
					<tr>
						<td height="25" align="center" class="thinborder">
							<strong>Average Rating</strong><br>
							<font size="1">(Grand Total Divide by <%=vClientRates.size()/2%>)</font></td>
						<td colspan="5" align="center" class="thinborder"><%=CommonUtil.formatFloat(dAverage, false)%></td>
					</tr>
				</table>
				<table width="100%" cellpadding="0" cellspacing="0" border="0">
					<tr>
						<td height="30" colspan="2">&nbsp;</td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(10) O - (Outstanding)</font></td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(8) VS - (Very Satisfactory)</font></td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(6) S - (Satisfactory)</font></td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(4) US - (Unsatisfactory)</font></td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(2) P - (Poor)</font></td>
					</tr>
					<tr>
						<td height="40" colspan="2">&nbsp;</td>
					</tr>
					<tr>
						<td height="25" width="70%" class="thinborderBOTTOM">&nbsp;</td>
						<td width="30%">&nbsp;</td>
					</tr>
					<tr>
						<td height="25" valign="top" align="center">Name and Signature of Rater</td>
						<td>&nbsp;</td>
					</tr>
					<tr>
						<td height="40" width="70%" class="thinborderBOTTOM">&nbsp;</td>
						<td width="30%">&nbsp;</td>
					</tr>
					<tr>
						<td height="25" valign="top" align="center">Date Rated </td>
						<td>&nbsp;</td>
					</tr>
				</table>
			</td>
		    <td width="1%">&nbsp;</td>
			<td width="24%">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder">
					<tr>
						<td height="25" align="center" class="thinborder"><strong>Values</strong></td>
						<td align="center" class="thinborder" colspan="5"><strong>Rating</strong></td>
					</tr>
					<tr>
						<td height="25" class="thinborder" width="70%">&nbsp;</td>
						<td width="6%" align="center" class="thinborder"><strong>10</strong></td>
						<td width="6%" align="center" class="thinborder"><strong>8</strong></td>
						<td width="6%" align="center" class="thinborder"><strong>6</strong></td>
						<td width="6%" align="center" class="thinborder"><strong>4</strong></td>
						<td width="6%" align="center" class="thinborder"><strong>2</strong></td>
					</tr>
				<%
				iSum2 = 0; iSum4 = 0; iSum6 = 0; iSum8 = 0; iSum10 = 0;
				for(int i = 0; i < vPeerRates.size(); i += 2){
					strTemp = WI.getStrValue((String)vPeerRates.elementAt(i+1));
				%>
					<tr>
						<td height="25" class="thinborder">&nbsp;<%=(String)vPeerRates.elementAt(i)%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("10")){
								iSum10 += 10;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("8")){
								iSum8 += 8;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("6")){
								iSum6 += 6;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("4")){
								iSum4 += 4;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
						<td align="center" class="thinborder">
							<%if(strTemp.equals("2")){
								iSum2 += 2;
							%>
								<img src="../../../images/tick.gif" border="0">
							<%}else{%>
								&nbsp;
							<%}%></td>
					</tr>
				<%}%>
					<tr>
						<td height="25" align="center" class="thinborder"><strong>TOTAL BY COLUMN</strong></td>
						<td align="center" class="thinborder"><%=iSum10%></td>
						<td align="center" class="thinborder"><%=iSum8%></td>
						<td align="center" class="thinborder"><%=iSum6%></td>
						<td align="center" class="thinborder"><%=iSum4%></td>
						<td align="center" class="thinborder"><%=iSum2%></td>
					</tr>
					<%
							iTotal = iSum2 + iSum4 + iSum6 + iSum8 + iSum10;
							dAverage = (double)iTotal/(double)(vSubRates.size()/2);
						%>
					<tr>
						<td height="25" align="center" class="thinborder"><strong>Grand Total</strong></td>
						<td colspan="5" align="center" class="thinborder"><%=iTotal%></td>
					</tr>
					<tr>
						<td height="25" align="center" class="thinborder">
							<strong>Average Rating</strong><br>
							<font size="1">(Grand Total Divide by <%=vPeerRates.size()/2%>)</font></td>
						<td colspan="5" align="center" class="thinborder"><%=CommonUtil.formatFloat(dAverage, false)%></td>
					</tr>
				</table>
				<table width="100%" cellpadding="0" cellspacing="0" border="0">
					<tr>
						<td height="30" colspan="2">&nbsp;</td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(10) O - (Outstanding)</font></td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(8) VS - (Very Satisfactory)</font></td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(6) S - (Satisfactory)</font></td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(4) US - (Unsatisfactory)</font></td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font size="1">(2) P - (Poor)</font></td>
					</tr>
					<tr>
						<td height="40" colspan="2">&nbsp;</td>
					</tr>
					<tr>
						<td height="25" width="70%" class="thinborderBOTTOM">&nbsp;</td>
						<td width="30%">&nbsp;</td>
					</tr>
					<tr>
						<td height="25" valign="top" align="center">Name and Signature of Rater</td>
						<td>&nbsp;</td>
					</tr>
					<tr>
						<td height="40" width="70%" class="thinborderBOTTOM">&nbsp;</td>
						<td width="30%">&nbsp;</td>
					</tr>
					<tr>
						<td height="25" valign="top" align="center">Date Rated </td>
						<td>&nbsp;</td>
					</tr>
				</table>
			</td>
		    <td width="1%">&nbsp;</td>
		</tr>
	</table>
</body>
</html>
<%
dbOP.cleanUP();
%>