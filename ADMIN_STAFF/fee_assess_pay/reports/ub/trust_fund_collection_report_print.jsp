<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Trust Fund Collection Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body>
<%@ page language="java" import="utility.*,enrollment.ReportFeeAssessment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","trust_fund_collection_report.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"trust_fund_collection_report.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","REPORTS-CASHIER REPORT",request.getRemoteAddr(),
														"trust_fund_collection_report.jsp");
}
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

//end of authenticaion code.
Vector vRetResult = new Vector();
Vector vSummary = new Vector();
Vector vDateListDetails = new Vector();

ReportFeeAssessment othschReport = new ReportFeeAssessment();

	vRetResult = othschReport.operateOnTrustFundReport(dbOP, request, 1);
	if(vRetResult == null)
		strErrMsg = othschReport.getErrMsg();

if(strErrMsg != null){
	dbOP.cleanUP();
%>
<div align="center" style="font-size:12px;"><strong><%=strErrMsg%></strong></div>

<%return;}
if(vRetResult != null && vRetResult.size() > 0){
	vSummary = (Vector)vRetResult.remove(0);
	vDateListDetails = (Vector)vRetResult.remove(0);
	String strTellerName = "";
	strTemp = "select fname, mname, lname from user_table where id_number = "+WI.getInsertValueForDB(WI.fillTextValue("emp_id"), true, null);
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	
	if(rs.next())
		strTellerName = WebInterface.formatName(rs.getString(1),rs.getString(2),rs.getString(3),4);
	rs.close();
	
	String strTotSummary = CommonUtil.formatFloat((String)vSummary.remove(0),true);
	
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
	int iNumRec = 0;
	int iPageNo = 1;
	int iTotalPages = vDateListDetails.size()/(3*iMaxRecPerPage);	
	if(vDateListDetails.size()%(3*iMaxRecPerPage) > 0)
		iTotalPages++;	 
		
	int iTemp = vSummary.size()/(2*iMaxRecPerPage);	
	if(vSummary.size()%(2*iMaxRecPerPage) > 0)
		iTemp++;
		
	iTotalPages = iTotalPages + iTemp;	
	boolean bolPageBreak = false;
	for(int i  = 0; i < vSummary.size();){
		iNumRec = 0;
		bolPageBreak = false;
%>
	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td colspan="5" align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
								<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
								SUMMARY OF TRUST FUND COLLECTION REPORT<br>
								</strong>
								 <%=WI.getStrValue(WI.fillTextValue("date_from"), "From ","","")%><%=WI.getStrValue(WI.fillTextValue("date_to"), " to ","","")%><br><br>
								</td></tr>
	<tr>
		<td class="thinborderBOTTOM" height="20" width="33%">Teller Name: <%=strTellerName%></td>
		<td class="thinborderBOTTOM" width="25%">Teller No : <%=WI.fillTextValue("emp_id")%></td>
	  	<td class="thinborderBOTTOM" width="31%">Print Date : <%=WI.getTodaysDateTime()%></td>
		<td class="thinborderBOTTOM" width="11%">Page <%=iPageNo%> of <%=iTotalPages%></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
	
	
	<tr><td colspan="4" height="90" align="center">
		<%if(iPageNo == 1){%>
			<br><br><strong>********************OVER ALL TOTAL********************</strong>
		<%}else{%>
			&nbsp;
		<%}%>
	</td></tr>
	
	
	<%for(; i < vSummary.size(); i += 2){
	iNumRec++;
	%>
	<tr>
	  	<td width="49%" style="padding-left:150px;"><%=vSummary.elementAt(i)%></td>
		<td width="1%">:</td>
		<td width="29%" align="right" style="padding-right:130px;"><%=vSummary.elementAt(i+1)%></td>
		<td width="21%">&nbsp;</td>
	</tr>
<%
	if(iNumRec >= iMaxRecPerPage){
		bolPageBreak = true;
		i += 2;
		iPageNo++;
		break;
	}

	}//inner loop%>
</table>
<%if(bolPageBreak){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr><td align="center"><i><font size="1">Continue on next page</font></i></td></tr>
	</table>
	<div style="page-break-after:always;">&nbsp;</div>
<%}
}//outer loop%>	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="49%">&nbsp;</td>
		<td width="1%">&nbsp;</td>
		<td width="29%" class="thinborderTOP" align="right" style="padding-right:15px; font-weight:bold;"><%=strTotSummary%></td>
		<td width="21%">&nbsp;</td>
	</tr>
</table>




<%
iPageNo++;
iNumRec = 0;
%>
<div style="page-break-after:always;">&nbsp;</div>


<%
String strDate = "";
String strPrevDate = "";
double dTemp = 0d;

for(int i  = 0; i < vDateListDetails.size();){//outer loop
	
	iNumRec = 0;
	
	if(bolPageBreak || i == 0){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td colspan="5" align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
								<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
								DAILY TRUST FUND COLLECTION REPORT<br>
								</strong>
								 <%=WI.getStrValue(WI.fillTextValue("date_from"), "From ","","")%><%=WI.getStrValue(WI.fillTextValue("date_to"), " to ","","")%><br><br>
								</td></tr>
	<tr>
		<td class="thinborderBOTTOM" height="20" width="33%">Teller Name: <%=strTellerName%></td>
		<td class="thinborderBOTTOM" width="25%">Teller No : <%=WI.fillTextValue("emp_id")%></td>
	  	<td class="thinborderBOTTOM" width="31%">Print Date : <%=WI.getTodaysDateTime()%></td>
		<td class="thinborderBOTTOM" width="11%">Page <%=iPageNo%> of <%=iTotalPages%></td>
	</tr>
</table>
<%}
bolPageBreak = false;
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td colspan="4" height="20">&nbsp;</td></tr>


<%
	
	for(; i < vDateListDetails.size();i+=3){//inner loop
	strDate = (String)vDateListDetails.elementAt(i+2);
	if(!strPrevDate.equals(strDate)){
		strPrevDate = strDate;				
		if(i > 0)	
			break;	
%>
	<tr>
		<td colspan="4"><%=strDate%></td>
	</tr>
<%	
	iNumRec++;
	}//if(!strPrevDate.equals(strDate))
	
	iNumRec++;
dTemp += Double.parseDouble(ConversionTable.replaceString((String)vDateListDetails.elementAt(i+1), ",",""));
%>
	<tr>
	  	<td width="49%" style="padding-left:150px;"><%=vDateListDetails.elementAt(i)%></td>
		<td width="1%">:</td>
		<td width="29%" align="right" style="padding-right:130px;"><%=vDateListDetails.elementAt(i+1)%></td>
		<td width="21%">&nbsp;</td>
	</tr>
<%
	if(iNumRec >= iMaxRecPerPage){
		bolPageBreak = true;
		i += 3;
		iPageNo++;
		break;
	}
	}//inner loop%>
	
	<%if(!bolPageBreak){%>	
	<tr>
		<td width="49%">&nbsp;</td>
		<td width="1%">&nbsp;</td>
		<td width="29%" class="thinborderTOP" align="right" style="padding-right:15px; font-weight:bold;"><%=CommonUtil.formatFloat(dTemp, true)%></td>
		<td width="21%">&nbsp;</td>
	</tr>	
	
	<%
	dTemp = 0d;
	}if(i < vDateListDetails.size() && !bolPageBreak){%>	
	<tr>
		<td colspan="4"><%=strDate%></td>
	</tr>
	<%}%>
</table>


<%if(bolPageBreak){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr><td align="center"><i><font size="1">Continue on next page</font></i></td></tr>
	</table>
	<div style="page-break-after:always;">&nbsp;</div>
<%}



}//outer loop%>

<script>window.print();</script>
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>
