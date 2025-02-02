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

double dTotalAssessment = 0d; double dCurAssessment = 0d;
double dTotalPayment    = 0d; double dAdjustment = 0d;

double dOSBalance = 0d; double dTotalDiscount = 0d; double dDownPayment = 0d;

FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();
enrollment.FAStudentLedger faStudLedg = new enrollment.FAStudentLedger();

vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
					WI.fillTextValue("stud_id"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
if(vStudInfo == null)
	strErrMsg = enrlStudInfo.getErrMsg();

if(strErrMsg == null)
{
	dBalance = fOperation.calOutStandingOfPrevYearSem(dbOP,(String)vStudInfo.elementAt(0), true, true, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("semester"), null);
	//fOperation.calOutStandingCurYr(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
    //    						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	//System.out.println("Balance : "+dBalance);
	vScheduledPmt = FA.getInstallmentSchedulePerStudent(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	if(vScheduledPmt == null)
		strErrMsg = FA.getErrMsg();
	else {
		dDownPayment = ((Float)vScheduledPmt.elementAt(2)).doubleValue();
		if(((String)vStudInfo.elementAt(5)).equals("0") ) {
			bolIsBasic = true;
			FA.setIsBasic(true);
		}
		//System.out.println("Final output : "+FA.getInstallmentPayablePerStudent(dbOP, (String)vStudInfo.elementAt(0),
		//	WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester")));
		//System.out.println("Final output : "+FA.getInstallmentSchedulePerStudPerExamSch(dbOP, "1", (String)vStudInfo.elementAt(0),
		//	WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester")));
		////System.out.println("Final output2 : "+FA.getInstallmentSchedulePerStudPerExamSch(dbOP, "2", (String)vStudInfo.elementAt(0),
		//	WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester")));
		//System.out.println("Final output3 : "+FA.getInstallmentSchedulePerStudPerExamSch(dbOP, "4", (String)vStudInfo.elementAt(0),
		//	WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester")));


		dCurAssessment = fOperation.calTotalPayableFee(dbOP,(String)vStudInfo.elementAt(0), false,WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));

		dTotalAssessment =  dCurAssessment + fOperation.calTotalOtherPayable(dbOP,(String)vStudInfo.elementAt(0),
							WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));//System.out.println("Total Assessment : "+dTotalAssessment);

		strTemp = "select sum(amount) from fa_stud_payment where user_index = "+(String)vStudInfo.elementAt(0)+
					  " and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester")+
					  " and or_number is null and is_valid = 1";
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp != null)
			dAdjustment = Double.parseDouble(strTemp);




		Vector vLedgerInfo = faStudLedg.viewLedgerTuition(dbOP, (String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), null,
						WI.fillTextValue("semester"), false);
		if(vLedgerInfo != null) {
			Vector vTimeSch 			= (Vector)vLedgerInfo.elementAt(0);
			Vector vTuitionFeeDetail	= (Vector)vLedgerInfo.elementAt(1);
			Vector vAdjustment			= (Vector)vLedgerInfo.elementAt(2);
			Vector vRefund				= (Vector)vLedgerInfo.elementAt(3);
			Vector vDorm 				= (Vector)vLedgerInfo.elementAt(4);
			Vector vOthSchFine			= (Vector)vLedgerInfo.elementAt(5);//System.out.println(vOthSchFine);
			Vector vPayment			= (Vector)vLedgerInfo.elementAt(6);
			if(vTimeSch == null || vTimeSch.size() ==0)
				strErrMsg = faStudLedg.getErrMsg();
			else {
				if(vAdjustment != null) {
					for(int i = 1; i < vAdjustment.size(); i += 7){
						dTotalDiscount += Double.parseDouble((String)vAdjustment.elementAt(i + 1));
					}
				}
			}
			dOSBalance = ((Double)vTuitionFeeDetail.elementAt(0)).doubleValue();
			dTotalAssessment += dOSBalance;
			//System.out.println("vScheduledPmt : "+vScheduledPmt);


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

//System.out.println(FA.getInstallmentSchedulePerStudAllInOne(dbOP, (String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester")) );
//EnrlReport.FeeExtraction fEx = new EnrlReport.FeeExtraction();
//fEx.getProjectedCollection(dbOP, request);

if(strErrMsg != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=strErrMsg%></strong></font></td>
    </tr>
  </table>
<%}%>
<% if(vStudInfo != null && vStudInfo.size() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr><td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" >
	  <tr>
		<td align="center" style="font-size:13px;">
		<font style="font-size:16px;">WEST NEGROS UNIVERSITY</font><br>
		<font size="1">Bacolod City, Philippines</font><br>
		<font style="font-size:14px;">STATEMENT OF ACCOUNT</font><br>
		<%if(!bolIsBasic){%><%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>,<%}%> <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%>
		- <%=strPmtScheduleName%></td>
	  </tr>
	</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" >

	  <tr>
		<td width="2%" height="18">&nbsp;</td>
		<td colspan="3">&nbsp;&nbsp;Student #. <u><%=WI.fillTextValue("stud_id").toUpperCase()%></u></td>
	  </tr>
	  <tr>
		<td height="18">&nbsp;</td>
		<td colspan="3" style="font-size:13px;">&nbsp;&nbsp;Name. <u><b><%=WebInterface.formatName((String)vStudInfo.elementAt(10),(String)vStudInfo.elementAt(11),
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
		  <td height="18" colspan="3">&nbsp;&nbsp;Gr./Yr & Section: <u><%=dbOP.getBasicEducationLevel(Integer.parseInt((String)vStudInfo.elementAt(4)), false)%> - <%=strTemp%></u></td>
		</tr>
	<%}else{%>
	  <tr>
		<td height="18">&nbsp;</td>
		<td colspan="3">&nbsp;&nbsp;Course. <u><%=(String)vStudInfo.elementAt(16)%>
			<%if(vStudInfo.elementAt(3) != null){%>/<%=(String)vStudInfo.elementAt(3)%><%}%>
	<strong><%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0"))]%></strong></u></td>
	  </tr>
	<%}//do not show if basic..

	//compute here amt due for the exam period and total payable.
	double dAmtDue = 0d;//System.out.println(vScheduledPmt);
	double dDueForThisPeriod = 0d;
	double dTotalInstalAmtPaid = 0d;//this is the total installment amt paid.
	String strExamPeriodName = null;///i have to get the exam period from vScheduledPmt

	  //////////// Posting pmt schedule.
	   Vector vInstallPmtSchedule = null;
	   vInstallPmtSchedule = FA.getOtherChargePayable(dbOP, WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
			WI.fillTextValue("semester"), (String)vStudInfo.elementAt(0) );
		if(vInstallPmtSchedule != null) {
			//I have to add the debit/credit to aseessment.
			dTotalAssessment = dTotalAssessment - dAdjustment;
			dAdjustment = 0d;
			//System.out.println("JSP : Other schoool fee Info : "+vInstallPmtSchedule);
			//System.out.println("JSP : vScheduledPmt : "+vScheduledPmt);

			strTemp = (String)vInstallPmtSchedule.remove(0);
			if(strTemp != null) {
				dAdjustment -= Double.parseDouble(strTemp);
				dTotalAssessment = dTotalAssessment - Double.parseDouble(strTemp);
			}
		}
		double dInstallmentPayable = 0d;double dCumInstallmentPayable = 0d;
		//this determines how the posting fees paid.
	if(vScheduledPmt != null && vScheduledPmt.size() > 0) {
		//System.out.println("Balance : "+dBalance);
		for(int i = 5; i < vScheduledPmt.size(); i +=3) {
			dAmtDue = ( (Float)vScheduledPmt.elementAt(3)).doubleValue() -
					 ((Float)vScheduledPmt.elementAt(i + 2)).doubleValue() + dAmtDue;

			if(vInstallPmtSchedule != null) {
			  for(;vInstallPmtSchedule.size() > 0;) {
				//if matching, get value and break. else continue;
				if( ((String)vInstallPmtSchedule.elementAt(1)).compareTo((String)vScheduledPmt.elementAt(i)) == 0) {
				  dAmtDue += Double.parseDouble((String)vInstallPmtSchedule.elementAt(2));
				  vInstallPmtSchedule.removeElementAt(0);
				  vInstallPmtSchedule.removeElementAt(0);
				  vInstallPmtSchedule.removeElementAt(0);
				  break;
				}
				///keep adding to payable.
				dAmtDue += Double.parseDouble((String)vInstallPmtSchedule.elementAt(2));
				vInstallPmtSchedule.removeElementAt(0);
				vInstallPmtSchedule.removeElementAt(0);
				vInstallPmtSchedule.removeElementAt(0);
			  }
			}
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
	  <tr>
		<td height="18">&nbsp;</td>
		<td colspan="2">&nbsp;</td>
		<td width="23%" valign="top">&nbsp;</td>
	  </tr>
	<%
	int iRowSpan = 5;
	if(dAdjustment == 0d)
		--iRowSpan;
	if(dTotalDiscount == 0d)
		--iRowSpan;
	%>
	  <tr>
		<td height="20">&nbsp;</td>
		<td>TOTAL ASSESSMENT </td>
		<%if(iRowSpan < 5){strTemp = "<td rowspan='"+iRowSpan+"'>";%><%=strTemp%><%}else{%>
		<td rowspan="5"><%}%>
		<%if(dDueForThisPeriod <=200d){%>
			<table width="50%" class="thinborderALL">
			<tr><td style="font-size:14px;">OK FOR <%=strPmtScheduleName.toUpperCase()%>
			</td></tr></table>

		<%}%>	</td>
		<td width="23%" align="right" class="thinborderNONE">P <%=CommonUtil.formatFloat(dCurAssessment + dOSBalance + dTotalDiscount, true)%></td>
	  </tr>
	<%
	if(dAdjustment != 0d){%>
	  <tr>
		<td height="20">&nbsp;</td>
		<td>TOTAL ADJUSTMENT </td>
		<td align="right" class="thinborderNONE">
		<%if(dAdjustment < 0d){%><%=CommonUtil.formatFloat(dAdjustment*-1, true)%><%}else{%>(<%=CommonUtil.formatFloat(dAdjustment, true)%>)<%}%>	</td>
	  </tr>
	<%}//System.out.println("dTotalAssessment : "+dTotalAssessment+" ;dBalance; "+dBalance +" ;dAdjustment; "+dAdjustment);
	dTotalAssessment = dTotalAssessment - dBalance - dAdjustment;
	if(dTotalDiscount > 0d){%>
	  <tr>
		<td height="20">&nbsp;</td>
		<td>TOTAL TUITION DISCOUNTS/SCHOLARSHIPS</td>
		<td align="right" class="thinborderNONE">P (<%=CommonUtil.formatFloat(dTotalDiscount, true)%>) </td>
	  </tr>
	<%}%>
	  <tr>
		<td height="20">&nbsp;</td>
		<td>TOTAL PAYMENT(D/P: <%=CommonUtil.formatFloat(dDownPayment, true)%>) </td>
		<td width="23%" align="right" class="thinborderNONE">P
			<%if(dTotalAssessment < 0d){%>(<%}%><%=CommonUtil.formatFloat(dTotalAssessment,true)%><%if(dTotalAssessment < 0d){%>)<%}%>	</td>
	  </tr>
	  <tr>
		<td height="20">&nbsp;</td>
		<td>TOTAL UNPAID ACCOUNTS TO DATE</td>
		<td align="right" class="thinborderNONE">P
			<%if(dBalance < 0d){%>(<%}%><%=CommonUtil.formatFloat(dBalance,true)%><%if(dBalance < 0d){%>)<%}%>	</td>
	  </tr>
	  <tr>
		<td height="20">&nbsp;</td>
		<td colspan="2">&nbsp;</td>
		<td width="23%" valign="top">&nbsp;</td>
	  </tr>

	  <tr style="font-weight:bold">
		<td height="20">&nbsp;</td>
		<td colspan="2">AMOUNT DUE FOR <%=strPmtScheduleName.toUpperCase()%></td>
		<td align="right" class="thinborderTOPBOTTOM">P <%=CommonUtil.formatFloat(dDueForThisPeriod,true)%></td>
	  </tr>
	  <tr>
		<td height="20">&nbsp;</td>
		<td width="48%" valign="bottom">Printed By. <%=request.getSession(false).getAttribute("first_name")%></td>
		<td colspan="2" align="right" valign="bottom">Print Date  : <%=WI.getTodaysDate(1)%></td>
	  </tr>
	</table>
</td>
<%if(strPmtScheduleName.toLowerCase().startsWith("final")){%>
<td width="2%">&nbsp;</td>
<td width="30%" valign="top">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" >
	  <tr>
		<td align="center" style="font-size:13px;">
		<font style="font-size:16px;">WEST NEGROS UNIVERSITY</font><br>
		STUDENT CLEARANCE</td>
	  </tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td width="20%">Name</td>
			<td><%=WebInterface.formatName((String)vStudInfo.elementAt(10),(String)vStudInfo.elementAt(11),
			(String)vStudInfo.elementAt(12),4)%></td>
		</tr>
		<tr>
		  <td>Student No </td>
		  <td><%=WI.fillTextValue("stud_id").toUpperCase()%></td>
	    </tr>
	<%if(bolIsBasic){%>
		<tr>
		  <td>Grade</td>
		  <td><%=dbOP.getBasicEducationLevel(Integer.parseInt((String)vStudInfo.elementAt(4)), false)%> </td>
	    </tr>
	<%}else{%>
		<tr>
		  <td>Course/Yr</td>
		  <td><%=(String)vStudInfo.elementAt(16)%>
			<%if(vStudInfo.elementAt(3) != null){%>/<%=(String)vStudInfo.elementAt(3)%><%}%>
	        <%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0"))]%></td>
	    </tr>
		<tr>
		  <td>SY/Term</td>
		  <td><%if(!bolIsBasic){%><%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>,<%}%> <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%></td>
	    </tr>
		<tr>
		  <td colspan="2"><hr size="1"></td>
	    </tr>
		<tr>
		  <td>Dean</td>
	      <td class="thinborderBOTTOM">&nbsp;</td>
		</tr>
		<tr>
		  <td>Librarian</td>
		  <td class="thinborderBOTTOM">&nbsp;</td>
	    </tr>
		<tr>
		  <td>Registrar</td>
		  <td class="thinborderBOTTOM">&nbsp;</td>
	    </tr>
		<tr>
		  <td>Assessment</td>
		  <td class="thinborderBOTTOM">&nbsp;</td>
	    </tr>
		<tr>
		  <td>Treasurer's Office </td>
		  <td class="thinborderBOTTOM">&nbsp;</td>
	    </tr>
		<tr>
		  <td>Cashier</td>
		  <td>&nbsp;</td>
	    </tr>
		<tr>
		  <td colspan="2"><hr size="1"></td>
	    </tr>
		<tr>
		  <td colspan="2"><strong>Important</strong> : Fill up the needed information in a clear and Legible manner.</td>
	    </tr>
	<%}//do not show if basic.. %>
	</table>
</td>
<%}%>
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
