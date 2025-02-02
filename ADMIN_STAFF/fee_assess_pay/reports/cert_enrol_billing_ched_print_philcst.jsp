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


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<body onLoad="window.print();">
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


vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
					WI.fillTextValue("stud_id"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
if(vStudInfo == null) strErrMsg = enrlStudInfo.getErrMsg();
else
{
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
        (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4),
        WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
}
if(strErrMsg == null) //collect fee details here.
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
if(strErrMsg == null)
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
if(strErrMsg == null) 
	strErrMsg = "";

if(vStudInfo != null && vStudInfo.size() > 0) {%> 
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="10%" align="center"><img src="../../../images/logo/PHILCST_DAGUPAN.gif" width="80" height="80"></td>
    <td width="90%" align="center" valign="top">
        <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong> <br>
          <%=WI.getStrValue(SchoolInformation.getAddressLine1(dbOP,false,false), "", "<br>", "&nbsp;")%>
          <%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false), "", "<br>", "&nbsp;")%>
          <%=WI.getStrValue(SchoolInformation.getAddressLine3(dbOP,false,false), "", "<br>", "&nbsp;")%>      </td>
  </tr>
</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%" height="25" colspan="4"><div align="center"><font size="2"><strong>         
		CERTIFICATE OF ENROLMENT AND BILLING 
		<br>
        </strong>
		<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]+", "+WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%>
		</font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=strErrMsg%></b></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="20">&nbsp;</td>
      <td width="23%" height="20">Scholarship Program: </td>
      <td colspan="3">
	  <strong>
	  	<%=WI.getStrValue(WI.fillTextValue("scholarship_name"),"","","___________________")%>
	  </strong></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">1. Grantee Slot Number : </td>
      
    <td height="20" colspan="3">&nbsp;<%=WI.fillTextValue("stud_id")%></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">2. Student's Name : </td>
      <td width="23%" height="20"><strong><%=(String)vStudInfo.elementAt(12)%></strong></td>
      <td width="22%"><strong><%=(String)vStudInfo.elementAt(10)%></strong></td>
      <td width="30%">
	  <%
	  if(vStudInfo.elementAt(11) != null){%>
	  <strong><%=((String)vStudInfo.elementAt(11)).charAt(0)%>.</strong>
	  <%}%></td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
      <td height="19">&nbsp;</td>
      <td height="19" valign="top"><em>Surname</em></td>
      <td><em>Firstname</em></td>
      <td><em>M.I.</em></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">3. Sex : <strong><u><%=(String)vStudInfo.elementAt(13)%></u></strong></td>
      <td height="20" colspan="3">4. Course : <u><strong><%=(String)vStudInfo.elementAt(2)%>
        <%
	  if(vStudInfo.elementAt(3) != null){%>
        /<%=(String)vStudInfo.elementAt(3)%>
        <%}%>
        </strong></u></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20" colspan="4">5. Year Level : <u><strong><%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0"))]%></strong></u></td>
    </tr>
  </table>
<br>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="20">&nbsp;</td>
      <td width="33%">6. (A) Subjects Enrolled</td>
      <td width="12%">(B) Units</td>
      <td width="53%">7. Semestral Fees</td>
    </tr>
	<tr>
		<td width="2%" style="font-size: 16px;">&nbsp;</td>
		<td colspan="2" width="45%" valign="top">
			<%
			if(vSubList != null && vSubList.size() > 0){%>
			<table width="100%" border="0" cellpadding="0" bgcolor="#FFFFFF">
				<%
				for(int i=1; i<vSubList.size();++i)
				{%>
				<tr>
					<td width="4%">&nbsp; </td>
					<td width="74%"><%=(String)vSubList.elementAt(i+3)%>(<%=(String)vSubList.elementAt(i+4)%>)</td>
					<td width="22%"><%=(String)vSubList.elementAt(i+13)%></td>
			   </tr>
			   <%
			   i = i+13;
			   }%>
			   <tr>
					<td width="4%">&nbsp; </td>

            <td width="74%" align="right"><strong>Total Unit &nbsp;&nbsp;&nbsp;</strong></td>
					<td width="22%"><strong><%=(String)vSubList.elementAt(0)%></strong></td>
			   </tr>
		    </table>
		<%}//only if vSubList is not null%>
		</td>
		<td width="53%" valign="top">
			<table width="100%" border="0" cellpadding="0" bgcolor="#FFFFFF">
			<tr>
				<td width="5%">&nbsp;</td>

            <td width="61%"><strong>Tuition fee</strong></td>

            <td width="34%" align="right"><strong><%=CommonUtil.formatFloat(fTutionFee,true)%></strong></td>
			</tr>
			<tr>
				<td width="5%">&nbsp;</td>

            <td width="61%"><strong>Computer Lab fee</strong></td>

            <td width="34%" align="right"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></td>
			</tr>
			<tr>
				<td width="5%">&nbsp;</td>

            <td width="61%"><strong>Miscellaneous fee(TOTAL)</strong></td>

            <td width="34%" align="right"><strong><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></strong></td>
			</tr>
    <%
for(int i=0; i<vMiscFeeInfo.size(); i += 3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") !=0) {
		continue;
	}%>
			<tr>
				<td width="5%">&nbsp;</td>
				<td width="61%">&nbsp;&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>

            <td width="34%" align="right">
			<%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
			</tr>
<%}
if(fMiscOtherFee > 0f) {%>
			<tr>
				<td width="5%">&nbsp;</td>

            <td width="61%"><strong>Other fee(TOTAL)</strong></td>

            <td width="34%" align="right"><strong><%=CommonUtil.formatFloat(fMiscOtherFee,true)%></strong></td>
			</tr>
<%
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0) {
		continue;
	}%>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="61%">&nbsp;&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
			<td width="34%" align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
		</tr>
	<%}//end of for loop
}//end of fMiscOtherFee if it is > 0f%>

			</table>
		</td>
	</tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="20">&nbsp;</td>
      <td colspan="2" valign="bottom"><div align="center"><br><br><%=(String)vStudInfo.elementAt(1)%></div></td>
      <td width="3%" height="20">&nbsp;</td>
      <td width="3%" height="20">&nbsp;</td>
      <td height="20" colspan="2"><hr size="1" width="100%" align="left"></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td colspan="2" valign="top"><div align="center"><hr size="1"></div></td>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td width="32%" height="20">Gross Total</td>
      <td width="18%" height="20" align="right"><strong><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%></strong></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td colspan="2" valign="top"><div align="center"><%if(!bolIsAUF){%>Student Grantee<%}%></div></td>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td height="20" align="right">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td width="33%">&nbsp;</td>
      <td width="7%">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="18">&nbsp;</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td width="33%" height="18">Prepared by:</td>
      <td width="33%">&nbsp;</td>
      <td width="34%">Noted by:</td>
    </tr>
    <tr align="center">
      <td height="17">Arlene T. David</td>
      <td>&nbsp;</td>
      <td>Aleta A. Ramirez</td>
    </tr>
    <tr align="center">
      <td height="17">&nbsp;&nbsp;&nbsp;Accounting Clerk</td>
      <td>&nbsp;</td>
      <td>Scholarship Coordinator</td>
    </tr>
    <tr>
      <td height="17">&nbsp;</td>
      <td>Approved by: </td>
      <td>&nbsp;</td>
    </tr>
    <tr align="center">
      <td height="17">&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Gina Elena F. Gironella</td>
      <td>&nbsp;</td>
    </tr>
    <tr align="center">
      <td height="17">&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Registrar/ HRDO</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
