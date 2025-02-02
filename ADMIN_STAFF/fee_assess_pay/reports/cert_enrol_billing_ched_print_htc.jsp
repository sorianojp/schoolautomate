<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsCLDH = strSchCode.startsWith("CLDH");
boolean bolIsAUF = strSchCode.startsWith("AUF");
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED Enrollment and billing statement</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	<%if(bolIsCLDH || bolIsAUF){%>font-size: 11px;<%}else{%>font-size: 9px;<%}%>
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	<%if(bolIsCLDH || bolIsAUF){%>font-size: 11px;<%}else{%>font-size: 9px;<%}%>
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	<%if(bolIsCLDH || bolIsAUF){%>font-size: 11px;<%}else{%>font-size: 9px;<%}%>
 }


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	<%if(bolIsCLDH || bolIsAUF){%>font-size: 11px;<%}else{%>font-size: 9px;<%}%>
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	<%if(bolIsCLDH || bolIsAUF){%>font-size: 11px;<%}else{%>font-size: 9px;<%}%>
    }

-->
</style>
</head>
<body onLoad="window.print()">
<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAAssessment,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","cert_enrol_billing_ched_print.jsp");
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
														"cert_enrol_billing_ched_print.jsp");
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","REPORTS",request.getRemoteAddr(),null);


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

//end of authenticaion code.
Vector vStudInfo     = null;
Vector vMiscFeeInfo  = null;
Vector vTemp         = null;
Vector vSubList      = null;


float fTutionFee     = 0f;
float fCompLabFee    = 0f;
float fMiscFee       = 0f;
float fOutstanding   = 0f;
float fMiscOtherFee = 0f;//This is the misc fee other charges,

float fTotalDiscount = 0f;
float fDownpayment   = 0f;
float fTotalAmtPaid  = 0f;

SubjectSection SS = new SubjectSection();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FAFeeOperation fOperation = new FAFeeOperation();
FAAssessment FA = new FAAssessment();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();

String strMrMs = null;

vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
					WI.fillTextValue("stud_id"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
if(vStudInfo == null) strErrMsg = enrlStudInfo.getErrMsg();
/*else
{
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
        (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4),
        WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
}*/
if(false /*strErrMsg == null*/) //collect fee details here.
{
	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	if(fTutionFee > 0)
	{
		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),false,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		fOutstanding= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0));

		fMiscOtherFee = fOperation.getMiscOtherFee();

		fTotalDiscount = fOperation.calAdjustmentRebate(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"),null);
		fDownpayment   = fOperation.calAmoutPaidDurEnrollment(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		fTotalAmtPaid  = fOperation.calTotalAmoutPaidPerFee(dbOP, 0,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
        						WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));

	}
	else
		strErrMsg = fOperation.getErrMsg();
}
//if no error, get the misc fee details having hands on without computer subjects.
if(false /*strErrMsg == null*/)
{
	vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	if(vTemp == null)
		strErrMsg = paymentUtil.getErrMsg();
	else
		vMiscFeeInfo.addAll(vTemp);

	if(fOperation.getLabDepositAmt() > 0f)
	{
		vMiscFeeInfo.addElement("Laboratory Deposit");
		vMiscFeeInfo.addElement(Float.toString(fOperation.getLabDepositAmt()));
		vMiscFeeInfo.addElement("1");
	}
}
if(strErrMsg == null)
{
	vSubList = enrlStudInfo.getEnrolledList(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(9),
                                WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vSubList == null || vSubList.size() ==0)
	{
		strErrMsg = enrlStudInfo.getErrMsg();
	}
}

boolean bolIsInternal = false;//only in case of UDMC
if(WI.fillTextValue("is_internal").equals("1"))
	bolIsInternal = true;
String[] astrConvertYrLevel = {"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
String[] astrConvertSem     = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};


if(strErrMsg != null){dbOP.cleanUP();
%> 
<div style="color:#FF0000; font-weight:bold; text-align:center; font-size:13px;"><%=strErrMsg%></div>

<%return;}
if(vStudInfo != null && vStudInfo.size() > 0)
{
strTemp = (String)vStudInfo.elementAt(13);
if(strTemp.toLowerCase().startsWith("m"))
	strMrMs = "Mr.";
else
	strMrMs = "Ms.";
%>



<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td colspan="2" height="150">&nbsp;</td></tr>
	<tr><td colspan="2" align="center"><strong style="font-size:16px;">CERTIFICATION OF ENROLMENT</strong></td></tr>
	<tr><td height="25" colspan="2">&nbsp;</td></tr>
	<tr><td height="25" colspan="2">To Whom It May Concern:</td></tr>
	<tr><td height="25" colspan="2">&nbsp;</td></tr>
	<tr><td height="25" colspan="2" style="text-indent:60px; text-align:justify">
	This is to certify on the basis of the records on file in this office,
the student indicated below is officially enrolled in this institution
this term with total corresponding number of units:
	</td></tr>
	<tr>
	    <td height="25" colspan="2" style="text-indent:60px;">&nbsp;</td>
    </tr>
	<tr>
	    <td width="20%" height="25" align="right">Name</td>
        <td width="80%" style="text-indent:60px;"><u><strong><%=strMrMs%> <%=(String)vStudInfo.elementAt(1)%></strong></u></td>
	</tr>
	<tr>
	    <td height="25" align="right">Course</td>
        <td height="25" style="text-indent:60px;"><u><strong><%=(String)vStudInfo.elementAt(2)%><%=WI.getStrValue((String)vStudInfo.elementAt(3)," / ","","")%></strong></u></td>
	</tr>
</table>

<%if(vSubList != null && vSubList.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr style="font-weight:bold;">
		<td width="24%" height="22">Subject/s</td>
		<td width="56%">Descriptive Title</td>
		<td width="20%">Unit/s</td>
	</tr>
	<tr>
	    <td height="22" colspan="3">
		<u><strong><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>, <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%></strong></u></td>
    </tr>
<%
for(int i=1; i<vSubList.size();++i){
%>
	<tr>
	    <td height="22"><%=(String)vSubList.elementAt(i+3)%></td>
	    <td><%=(String)vSubList.elementAt(i+4)%></td>
	    <td><%=(String)vSubList.elementAt(i+13)%></td>
    </tr>
<%i = i+13;
}%>
	<tr>
	    <td height="22">-x-x-x-x-</td>
	    <td>-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-</td>
	    <td>-x-x-x-</td>
    </tr>
</table>
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td style="text-indent:60px; text-align:justify">
	This certification is issued upon request of  <u><strong><%=strMrMs%> <%=(String)vStudInfo.elementAt(1)%></strong></u>
	for whatever legal purpose it may serve him best.
	</td></tr>
	<tr>
	    <td style="text-indent:60px; text-align:justify">Done this <%=WI.getTodaysDate(14)%>  in the City of General Santos.</td>
    </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td height="40" colspan="6">&nbsp;</td>
	</tr>
	<tr>
		<td height="25" valign="bottom" width="13%">Prepared by</td>
		<%
		strTemp = (String)request.getSession(false).getAttribute("first_name");
		%>
		<td width="24%" align="" valign="bottom"><div style="border-bottom: solid 1px #000000; width:95%"><%=WI.getStrValue(strTemp)%></div></td>
		<td width="12%" valign="bottom">Checked by</td>
		<td width="25%"valign="bottom"><div style="border-bottom: solid 1px #000000; width:80%"><%=WI.fillTextValue("checked_by")%></div></td>
		<td width="26%" align="center" valign="bottom"><div style="border-bottom: solid 1px #000000; width:92%"><%=WI.fillTextValue("college_registrar")%></div></td>
	</tr>
	<tr>
	    <td height="25" valign="bottom">&nbsp;</td>
	    <td align="" valign="bottom">&nbsp;</td>
	    <td valign="bottom">&nbsp;</td>
	    <td valign="bottom">&nbsp;</td>
	    <td align="center" valign="top">College Registrar</td>
    </tr>
</table>  

  


<%}//only if vCHEDScholar is not null
%>
</body>
</html>
<%
dbOP.cleanUP();
%>
