<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Trust Fund Collection Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>

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
								"Admin/staff-Fee Assessment & Payments-REPORTS","trust_fund_collection_report_detailed.jsp");
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
														"trust_fund_collection_report_detailed.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","REPORTS-CASHIER REPORT",request.getRemoteAddr(),
														"trust_fund_collection_report_detailed.jsp");
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
Vector vRetResult = null;
Vector vGradeLevel = new Vector();

ReportFeeAssessment othschReport = new ReportFeeAssessment();

	vRetResult = othschReport.operateOnTrustFundReport(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = othschReport.getErrMsg();	
	else {
		String strSQLQuery = "select g_level, level_name from bed_level_info";
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			vGradeLevel.addElement(rs.getString(1));//g_level
			vGradeLevel.addElement(rs.getString(2));//[1] edu_level
		} 
		rs.close();
	}
		

if(strErrMsg != null){
	dbOP.cleanUP();
%>
<div align="center" style="font-size:12px;"><strong><%=strErrMsg%></strong></div>
  
<%
return;}
if(vRetResult != null && vRetResult.size() > 0){

boolean bolPageBreak = false;

String strTotalAmt = (String)vRetResult.remove(0);

String strTellerName = "";
strTemp = "select fname, mname, lname from user_table where id_number = "+WI.getInsertValueForDB(WI.fillTextValue("emp_id"), true, null);
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
if(rs.next())
	strTellerName = WebInterface.formatName(rs.getString(1),rs.getString(2),rs.getString(3),4);
rs.close();

int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
int iNumRec = 0;
int iPageNo = 1;
int iTotalPages = vRetResult.size()/(17*iMaxRecPerPage);	
if(vRetResult.size()%(17*iMaxRecPerPage) > 0)
	iTotalPages++;
	
if(iTotalPages == 0)
	iTotalPages = 1;


	String strDate = "";
	String strPrevDate = "";
	
	
	
	for(int i = 0; i < vRetResult.size();){
		iNumRec = 0;
		bolPageBreak = false;
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
	<tr><td colspan="5" height="16">&nbsp;</td></tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td class="thinborder" width="15%" height="22"><strong>STUDENT ID NO</strong></td>
		<td class="thinborder" width="31%"><strong>NAME</strong></td>
		<td class="thinborder" width="16%"><strong>COURSE/YR LEVEL</strong></td>
		<td class="thinborder" width="29%"><strong>FEE NAME</strong></td>
		<td class="thinborder" width="9%" align="center"><strong>AMOUNT</strong></td>
	</tr>
	
	<%	
	for(; i < vRetResult.size(); i+=17){
		strDate = (String)vRetResult.elementAt(i);
		if(!strPrevDate.equals(strDate)){
			strPrevDate = strDate;
	%>
	<tr>
		<td class="thinborder" height="20" colspan="10"><%=strDate%></td>
	</tr>		
	<%
	iNumRec++;
	}//if(!strPrevDate.equals(strDate))
	iNumRec++;
	%>
	<tr>
		<td height="20" class="thinborder"><%=vRetResult.elementAt(i+1)%></td>
		<%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4);
		%>
		<td class="thinborder"><%=strTemp%></td>
		<%
		if(vRetResult.elementAt(i + 5) == null) 
			strTemp = (String)vGradeLevel.elementAt(vGradeLevel.indexOf((String)vRetResult.elementAt(i+12)) + 1);
		else {
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5), "") + WI.getStrValue((String)vRetResult.elementAt(i+6)," - ","","") ;
			if(strTemp.length() > 0)
				strTemp += WI.getStrValue((String)vRetResult.elementAt(i+12)," / ","","");
		}
		%>
		<td class="thinborder"><%=strTemp%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%></td>
		<td align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+8), true)%></td>
	</tr>
	<%
	if(iNumRec >= iMaxRecPerPage){
		bolPageBreak = true;
		i += 17;
		iPageNo++;
		break;
	}
	
	}
	
	if(i >= vRetResult.size()){
	%>
	<tr>
		<td colspan="4" height="20" align="right" class="thinborder"><strong>TOTAL</strong> &nbsp;</td>
		<td class="thinborder" align="right"><strong><%=CommonUtil.formatFloat(strTotalAmt, true)%></strong></td>
	</tr>
	<%}%>
</table>
<%if(bolPageBreak){%>
	<div style="page-break-after:always;">&nbsp;</div>
<%}
}//outer loop
%>

<script>window.print();</script>
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>
