<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
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
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
var closeWnd ="";
function CloseWnd() {
	if(closeWnd == 1)
		window.setTimeout("javascript:window.close();", 2000);
}
</script>
<body onLoad="CloseWnd();">
<%@ page language="java" import="utility.*,EnrlReport.StatementOfAccount,enrollment.EnrlAddDropSubject,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAAssessment,enrollment.SubjectSection,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	String strSchoolCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	if(strSchoolCode == null)
		strSchoolCode = "";
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","statement_of_account.jsp");
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
														"statement_of_account.jsp");
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

boolean bolIsBasic = false;

//end of authenticaion code.
Vector vStudInfo     = null;
Vector vTemp         = null;
Vector vScheduledPmt = null;

double dBalance = 0d;
double dTemp = 0d;


FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();

vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
					WI.fillTextValue("stud_id"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
if(vStudInfo == null) 
	strErrMsg = enrlStudInfo.getErrMsg();

if(strErrMsg == null)
{
	dBalance = fOperation.calOutStandingOfPrevYearSem(dbOP,(String)vStudInfo.elementAt(0), true, true); 
	//fOperation.calOutStandingCurYr(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
      //  						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
								
	vScheduledPmt = FA.getInstallmentSchedulePerStudent(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	if(vScheduledPmt == null)
		strErrMsg = FA.getErrMsg();
	else {
		if(((String)vStudInfo.elementAt(5)).equals("0") ) {
			bolIsBasic = true;
			FA.setIsBasic(true);
		}
	}

}

String strPmtScheduleName  = null;

if(WI.fillTextValue("pmt_schedule").length() > 0)
	strPmtScheduleName = dbOP.mapOneToOther("FA_PMT_SCHEDULE","pmt_sch_index",WI.fillTextValue("pmt_schedule"),"exam_name",null);

strPmtScheduleName  = WI.getStrValue(strPmtScheduleName);
//System.out.println("strPmtScheduleName : "+strPmtScheduleName);

String[] astrConvertYrLevel = {"",",1st Year",",2nd Year",",3rd Year",",4th Year",",5th Year",",6th Year",",7th Year"};
String[] astrConvertSem     = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
//System.out.println(fOperation.fTotalAssessedHour);
if(strErrMsg != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=strErrMsg%></strong></font></td>
    </tr>
  </table>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td align="center" style="font-size:13px;">
	<font style="font-size:14px; font-weight:bold">STATEMENT OF ACCOUNT</font><br>
	<%if(!bolIsBasic){%><%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>,<%}%> <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%>
	- <%=strPmtScheduleName%></td>
  </tr>
</table>

<% if(vStudInfo != null && vStudInfo.size() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td height="18">&nbsp;</td>
    <td align="right" colspan="2"><br>
      Date  : <%=WI.getTodaysDate(1)%>&nbsp;&nbsp;</td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td colspan="2">&nbsp;&nbsp;Student #. <u><%=WI.fillTextValue("stud_id").toUpperCase()%></u></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td colspan="2" style="font-size:13px;">&nbsp;&nbsp;Name. <u><b><%=WebInterface.formatName((String)vStudInfo.elementAt(10),(String)vStudInfo.elementAt(11),
	  	(String)vStudInfo.elementAt(12),4)%></b></u></td>
  </tr>
<%if(bolIsBasic){
//I have to find section.
strTemp = "select section,count(*) as count_ from e_sub_section  join enrl_final_cur_list on (e_sub_section.sub_sec_index = enrl_final_cur_list.sub_sec_index) "+
		"where enrl_final_cur_list.is_valid = 1 and user_index = "+(String)vStudInfo.elementAt(0)+
  		" and enrl_final_cur_list.sy_from = "+WI.fillTextValue("sy_from")+" and current_semester = 1 group by section order by count_ desc";
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp == null)
	strTemp = "";
%>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">&nbsp;&nbsp;Gr./Yr & Section: <u><%=dbOP.getBasicEducationLevel(Integer.parseInt((String)vStudInfo.elementAt(4)), false)%> - <%=strTemp%></u></td>
    </tr>
<%}else{%>
  <tr>
    <td height="18">&nbsp;</td>
    <td colspan="2">&nbsp;&nbsp;Course. <u><%=(String)vStudInfo.elementAt(16)%>
		<%if(vStudInfo.elementAt(3) != null){%>/<%=(String)vStudInfo.elementAt(3)%><%}%>
<strong><%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0"))]%></strong></u></td>
  </tr>
<%}//do not show if basic.. 

//compute here amt due for the exam period and total payable. 
double dAmtDue = 0d;//System.out.println(vScheduledPmt);
double dDueForThisPeriod = 0d;
double dTotalInstalAmtPaid = 0d;//this is the total installment amt paid.
String strExamPeriodName = null;///i have to get the exam period from vScheduledPmt

//System.out.println(" I am here. :"+vScheduledPmt);
if(vScheduledPmt != null && vScheduledPmt.size() > 0) {
	//System.out.println("Balance : "+dBalance);
	for(int i = 5; i < vScheduledPmt.size(); i +=3) {
        //if(i == 5)
       // 	dAmtDue = ((Double)vScheduledPmt.remove(vScheduledPmt.size() - 1)).doubleValue() -
        //                  	( (Float)vScheduledPmt.elementAt(3)).doubleValue();
			//dAmtDue = 0;
		dAmtDue = ( (Float)vScheduledPmt.elementAt(3)).doubleValue() -
				 ((Float)vScheduledPmt.elementAt(i + 2)).doubleValue()+dAmtDue;

		//System.out.println("dAmtDue2 : "+dAmtDue);
		strExamPeriodName = (String)vScheduledPmt.elementAt(i);//System.out.println(strExamPeriodName);
		if(strExamPeriodName.compareTo(strPmtScheduleName) != 0 && !strExamPeriodName.startsWith("Unit"))
			continue;//do not print if this is not called for this exam period.

		//If already paid, i have to deduct this amount.
		for(int p = i + 3; p < vScheduledPmt.size() - 1; p += 3) {
			dAmtDue = dAmtDue - ((Float)vScheduledPmt.elementAt(p + 2)).doubleValue();
			//System.out.println("dAmtDue1(In the Loop) : "+dAmtDue);
		}
		if(dBalance < dAmtDue)
			dAmtDue = dBalance;	

		if( dAmtDue < 0d)
			dDueForThisPeriod = 0d;
		else
			dDueForThisPeriod = dAmtDue;
		if(dBalance != dDueForThisPeriod && strPmtScheduleName.toLowerCase().startsWith("fin"))
			dDueForThisPeriod = dBalance;

        break;
	}

}//end of if condition
%>
<!--
  <tr>
    <td height="18">&nbsp;</td>
    <td colspan="2">&nbsp;&nbsp;College/Dept. <u><%//=(String)vStudInfo.elementAt(18)%></u></td>
  </tr>
-->
<%
strTemp =  (String)vStudInfo.elementAt(16);//course name.
String strStudIndex = (String)vStudInfo.elementAt(0);
if(strTemp != null)
	strTemp = strTemp.toLowerCase();
else 
	strTemp = "";
if(strTemp.equals("bsn")) {
//find section of student.
strTemp = "select section from enrl_final_cur_list "+
			"join e_sub_section on (e_sub_section.sub_sec_index = enrl_final_cur_list.sub_sec_index) "+
			"where user_index = "+strStudIndex+
			" and enrl_final_cur_list.sy_from = "+WI.fillTextValue("sy_from")+" and current_semester = "+
			WI.fillTextValue("semester")+" and enrl_final_cur_list.is_valid = 1";
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp != null) {%>
  <tr>
    <td height="18">&nbsp;</td>
    <td colspan="2">&nbsp;&nbsp;Section. <u><%=strTemp%></u></td>
  </tr>

<%}//if strTemp is not null;
}//only if nursing.%>

 
  <tr>
    <td height="20">&nbsp;</td>
    <td>&nbsp;</td>
    <td valign="top">&nbsp;</td>
  </tr>
  <tr>
    <td height="20">&nbsp;</td>
    <td valign="top">() CASH BASIS </td>
    <td valign="top">&nbsp;</td>
  </tr>
  <tr>
    <td height="20">&nbsp;</td>
    <td valign="top">() INSTALLMENT </td>
    <td valign="top">&nbsp;</td>
  </tr>
 <%
 if(!strPmtScheduleName.toLowerCase().startsWith("fin")) {
 	double[] adTemp = FA.convertDoubleToNearestInt("AUF",dDueForThisPeriod);
	if(adTemp != null)
		dDueForThisPeriod = adTemp[0]; 
 }
 %> 
  <tr>
    <td height="20">&nbsp;</td>
    <td>AMOUNT DUE FOR THIS PERIOD</td>
    <td align="right">P <%=CommonUtil.formatFloat(dDueForThisPeriod,true)%></td>
  </tr>
  
  <tr>
    <td height="20">&nbsp;</td>
    <td>Add Other Charges </td>
    <td align="right">&nbsp;</td>
  </tr>
  <tr>
    <td height="20">&nbsp;</td>
    <td>TOTAL UNPAID ACCOUNTS TO DATE</td>
    <td align="right" class="thinborderTOPBOTTOM">P <%=CommonUtil.formatFloat(dBalance,true)%>
	</td>
  </tr>
  <tr>
    <td height="20">&nbsp;</td>
    <td>&nbsp;</td>
    <td valign="top" align="right">
	<table cellpadding="2" cellspacing="3" width="100%">
	<tr> <td class="thinborderTOP">&nbsp;
	</td></tr>
	</table>
	</td>
  </tr>
  <tr>
    <td height="20">&nbsp;</td>
    <td colspan="2">Prepared By. <%=request.getSession(false).getAttribute("first_name")%></td>
  </tr>
  <tr>
    <td height="20" width="2%">&nbsp;</td>
    <td width="75%">&nbsp;</td>
    <td valign="top" width="23%">&nbsp;</td>
  </tr>
  <tr>
    <td height="20">&nbsp;</td>
    <td colspan="2"><b><i>Note : </i></b>Please present this statement together with  your official receipt/s for issuance of your exam permit </td>
  </tr>
  <tr>
    <td height="20">&nbsp;</td>
    <td>&nbsp;</td>
    <td valign="top">&nbsp;</td>
  </tr>
  <tr>
    <td height="20">&nbsp;</td>
    <td>AUF-FORM-AFO 15<%if(bolIsBasic){%>.1<%}%></td>
    <td valign="top">&nbsp;</td>
  </tr>
  <tr>
    <td height="20">&nbsp;</td>
    <td><%if(bolIsBasic){%>February 1, 2009- Rev. 01<%}else{%>Nov. 13, 2008-Rev.01<%}%></td>
    <td valign="top">&nbsp;</td>
  </tr>
</table>

<script language="JavaScript">
//get this from common.js
this.autoPrint();

closeWnd = 1;
</script>
<%
	}//only if student information is found.
%>
</body>
</html>
<%
dbOP.cleanUP();
%>