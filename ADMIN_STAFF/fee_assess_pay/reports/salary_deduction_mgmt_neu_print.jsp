<%@ page language="java" import="utility.*,java.util.Vector" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }
-->
</style>

<body>
<%
DBOperation dbOP = null;
WebInterface WI = new WebInterface(request);
String strErrMsg = null;
String strTemp   = null;

try{
	dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
							"Admin/staff-Fee Assessment & Payments - Admission slip","salary_deduction_mgmt_neu.jsp");
	
}catch(Exception exp){
	exp.printStackTrace();%>
	<p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
	<%return;
}

CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"salary_deduction_mgmt_neu.jsp");														


if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
enrollment.FAStudentLedger faStudLedg = new enrollment.FAStudentLedger();
Vector vRetResult = null;
Vector vEditInfo  = null;

String strSYFrom = WI.fillTextValue("sy_from");
if(strSYFrom.length() == 0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strSemester = WI.fillTextValue("semester");
if(strSemester.length() == 0)
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");

enrollment.FAEmpSalaryDeduction faEmpSal = new enrollment.FAEmpSalaryDeduction();

int iSearchResult = 0;
int iElemCount = 0;

	

	vRetResult = faEmpSal.getStudListInformationForPrinting(dbOP, request);
	if(vRetResult == null){
		if(strErrMsg == null || strErrMsg.length() == 0)
		strErrMsg = faEmpSal.getErrMsg();
	}
	else{
		iElemCount = faEmpSal.getElemCount();
		iSearchResult = faEmpSal.getSearchCount();
	}

	

if(vRetResult != null && vRetResult.size() > 0){

String strSchName = SchoolInformation.getSchoolName(dbOP, true, false);
String strSchAddr = SchoolInformation.getAddressLine1(dbOP, false, false);
String[] astrConvertSem = {"Summer", "1st Sem", "2nd Sem", "3rd Sem", "4th Sem"};


float fTutionFee 	= 0f;
float fCompLabFee	= 0f;
float fMiscFee		= 0f;
float fDiscount    = 0f;
Vector vDiscountAddlDetail = null;
String strCurrLevelName = null;
String strPrevLevelName = "";
int iRowCount = 0;
int iMaxRowCount = 30;
if(WI.fillTextValue("rows_per_pg").length() > 0)
	iMaxRowCount = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
boolean bolPageBreak = false;
int iPageNo = 0;
String strCurrCCode = null;
String strPrevCCode = "";
String strCurrClassification = null;
String strPrevClassification = "";
for(int i = 0; i < vRetResult.size();){
strCurrClassification = (String)vRetResult.elementAt(i+12);
iRowCount = 0;
if(bolPageBreak){
	bolPageBreak = false;
%><div style="page-break-after:always;">&nbsp;</div>
<%}%>

<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr><td colspan="2" align="center">
	<font style="font-size:14px; font-weight:bold;"><%=strSchName%></font><br>
	<%=strSchAddr%><br>
	MGA PINAGTIBAY NA MAKAPAG-SD PARA SA <strong><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> 
	<%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%></strong><br>
	SPONSORSHIP CLASSIFICATION : <%=strCurrClassification%>
</td></tr>
<tr>
    <td height="18" colspan="2">&nbsp;</td>
</tr>
<tr><td width="48%">Date /Time Generated: <%=WI.formatDateTime(Long.parseLong(WI.getTodaysDate(28)),5)%></td>
    <td width="52%" align="right">Page No. <%=++iPageNo%></td>
</tr>
</table>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
	<tr>
		<td width="5%" height="25" valign="top" class="thinborder"><strong>SD #</strong></td>
		<td width="10%" valign="top" class="thinborder"><strong>SPONSOR NAME</strong></td>
		<td width="11%" valign="top" class="thinborder"><strong>DISTRICT/ DEPT.</strong></td>
		<td width="15%" valign="top" class="thinborder"><strong>STUDENT NAME</strong></td>
		<td width="7%" valign="top" class="thinborder"><strong>COLLEGE/ DEPT.</strong></td>
		<td width="12%" valign="top" class="thinborder"><strong>COURSE/ YEAR LEVEL</strong></td>
	    <td width="8%" valign="top" align="center" class="thinborder"><strong>TUITION FEE</strong></td>
	    <td width="8%" valign="top" align="center" class="thinborder"><strong>TOTAL ASSESSMENT</strong></td>
	    <td width="8%" valign="top" align="center" class="thinborder"><strong>DISCOUNT</strong></td>
	    <td width="8%" valign="top" align="center" class="thinborder"><strong>ACCOUNT RECEIVABLES</strong></td>
	    <td width="8%" valign="top" align="center" class="thinborder"><strong>INSTALLMENT DUE</strong></td>
	</tr>
	<%
	for(; i < vRetResult.size() ; i+=iElemCount){
	
	strCurrClassification = (String)vRetResult.elementAt(i+12);
	if(!strPrevClassification.equals(strCurrClassification)){
		strPrevClassification = strCurrClassification;
		if(i > 0){
			iPageNo = 0;
			bolPageBreak = true;
			break;
		}
	}
	
	strCurrCCode = (String)vRetResult.elementAt(i+13);
	if(!strPrevCCode.equals(strCurrCCode)){
		strPrevCCode = strCurrCCode;
		if(i > 0){
			iPageNo = 0;
			bolPageBreak = true;
			break;
		}
	}
	if(++iRowCount > iMaxRowCount){
		bolPageBreak = true;
		break;
	}
	%>
	<tr>
		<td class="thinborder" height="22"><%=vRetResult.elementAt(i+1)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i+8)%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+10),"NA")%></td>
		<%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),(String)vRetResult.elementAt(i+5),4);
		%>
		<td class="thinborder"><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"(",")","")%></td>
		<td class="thinborder"><%=WI.getStrValue(strCurrCCode,"NA")%></td>
		<%
		strTemp = (String)vRetResult.elementAt(i+15);
		if(WI.getStrValue(vRetResult.elementAt(i+18)).equals("1"))
			strTemp = "";
		%>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+14),"&nbsp;")%>
			<%=WI.getStrValue(strTemp," - ","","")%></td>
		<%
		fOperation.resetFees();
		fTutionFee = fOperation.calTutionFee(dbOP, (String)vRetResult.elementAt(i+19),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vRetResult.elementAt(i+15),WI.fillTextValue("semester"));
		
		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vRetResult.elementAt(i+19),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vRetResult.elementAt(i+15),WI.fillTextValue("semester"));
		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vRetResult.elementAt(i+19),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vRetResult.elementAt(i+15),WI.fillTextValue("semester"));
		vDiscountAddlDetail = faStudLedg.getAdjustmentAndAllowance(new Vector(), dbOP, (String)vRetResult.elementAt(i+19), WI.fillTextValue("sy_from"), 
			WI.fillTextValue("sy_to"),(String)vRetResult.elementAt(i+15),WI.fillTextValue("semester"));
		fDiscount = 0f;
		if(vDiscountAddlDetail != null && vDiscountAddlDetail.size() > 0){
			vDiscountAddlDetail.remove(0);
			for(int j = 0; j < vDiscountAddlDetail.size(); j+=7)
				fDiscount +=  Float.parseFloat((String)vDiscountAddlDetail.elementAt(j+1));			
		}
		if(fDiscount > 0f)
			strTemp = CommonUtil.formatFloat(fDiscount,true);
		else
			strTemp = "&nbsp;";
		%>
	    <td class="thinborder" align="right"><%=CommonUtil.formatFloat(fTutionFee,true)%></td>
	    <td class="thinborder" align="right"><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%></td>
	    <td class="thinborder" align="right"><%=strTemp%></td>
	    <td class="thinborder" align="right"><%=CommonUtil.formatFloat( (fTutionFee+fCompLabFee+fMiscFee)-fDiscount,true)%></td>
	    <td class="thinborder">&nbsp;</td>
	</tr>
	<%}%>
</table>
<%}%>
<script>window.print();</script>
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>
