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
<body>
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

Vector vAdditionalInfo = null;

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


	student.StudentInfo studInfo = new student.StudentInfo();
	vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(0));
	if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
		strErrMsg = studInfo.getErrMsg();
}

String[] astrConvertYrLevel = {"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
String[] astrConvertSem     = {"SUMMER","FIRST","SECOND","THIRD","FOURTH"};
if(strErrMsg == null) strErrMsg = "";
%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td height="25"><div align="center"><strong><font size="3"><%=WI.getStrValue(WI.fillTextValue("name_grant"))%> </font><br>
        </strong> 
        <hr size="2" noshade>
        <strong> </strong></div></td>
  </tr>
  <tr> 
    <td height="25"><div align="center"> 
        <p><font size="2"><strong>CERTIFICATE OF ENROLMENT AND BILLING<br>
          </strong> 
          <%//=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]+", "+WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%>
          </font></p>
        <p>&nbsp;___<u><%=SchoolInformation.getSchoolName(dbOP,true,false)%></u>___<br>
          Name of Private College/University<br>
          <br>
          <br>
          &nbsp;___<u><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></u>___<br>
          Address </p>
      </div></td>
  </tr>
  <tr> 
    <td height="25"></td>
  </tr>
</table>


<%
if(vStudInfo != null && vStudInfo.size() > 0)
{%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="2%" height="20">&nbsp;</td>
    <td width="22%" height="20">1. Grant/Award Number : </td>
    <td height="20" colspan="3"><strong><%=WI.getStrValue(WI.fillTextValue("grant_award_no"))%></strong></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td height="20">2. Student's Name : </td>
    <td height="20" colspan="3"><strong><%=((String)vStudInfo.elementAt(12)).toUpperCase()%>, <%=(String)vStudInfo.elementAt(10)%> 
      <%
	  if(vStudInfo.elementAt(11) != null){%>
      <%=((String)vStudInfo.elementAt(11)).charAt(0)%>. 
      <%}%>
      </strong></td>
  </tr>
  <tr> 
    <td height="19">&nbsp;</td>
    <td height="19">3. Sex : <strong></strong></td>
    <td height="19" colspan="3"><strong><%=(String)vStudInfo.elementAt(13)%></strong></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td height="20">4. Permanent Address : <strong></strong></td>
    <td height="20" colspan="3"> <strong> 
      <%if(vAdditionalInfo != null && vAdditionalInfo.size() > 0){%>
      <%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),",","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),",","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),",","","")%> 
      <%}%>
      </strong></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td height="20">5. Date of Birth: <strong></strong></td>
    <td height="20" colspan="3"> <strong> 
      <%if(vAdditionalInfo != null && vAdditionalInfo.size() > 0){%>
      <%=WI.getStrValue(vAdditionalInfo.elementAt(1))%> 
      <%}%>
      </strong></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td height="20">6. Course / Major : </td>
    <td height="20"><strong><%=(String)vStudInfo.elementAt(2)%> 
      <%
	  if(vStudInfo.elementAt(3) != null){%>
      /<%=(String)vStudInfo.elementAt(3)%> 
      <%}%>
      </strong></td>
    <td height="20">Year Level : <u></u></td>
    <td height="20"><strong><%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0"))]%></strong></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td height="20">7. School Year : </td>
    <td width="22%" height="20"><strong><%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></td>
    <td width="12%">Semester : </td>
    <td width="42%"><strong><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%></strong></td>
  </tr>
  <tr> 
    <td height="10">&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="3">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="2%" height="20">&nbsp;</td>
    <td width="38%"> Subjects Enrolled</td>
    <td>Units</td>
    <td width="49%">&nbsp;</td>
  </tr>
  <tr> 
    <td width="2%" style="font-size: 16px;">&nbsp;</td>
    <td colspan="2" valign="top"> <%
			if(vSubList != null && vSubList.size() > 0){%> 
      <table width="100%" border="0" cellpadding="0" bgcolor="#FFFFFF">
        <%
				for(int i=1; i<vSubList.size();++i)
				{%>
        <tr> 
          <td width="4%">&nbsp; </td>
          <td width="74%" style="font-size: 11px;"><%=(String)vSubList.elementAt(i+3)%>(<%=(String)vSubList.elementAt(i+4)%>)</td>
          <td width="15%" style="font-size: 11px;"><%=(String)vSubList.elementAt(i+13)%></td>
          <td width="7%" style="font-size: 11px;">&nbsp;</td>
        </tr>
        <%
			   i = i+13;
			   }%>
        <tr> 
          <td colspan="3"><hr size="1" noshade></td>
          <td align="right" style="font-size: 11px;">&nbsp;</td>
        </tr>
        <tr> 
          <td width="4%">&nbsp; </td>
          <td width="74%" align="right" style="font-size: 11px;"><strong>Total 
            Unit(s)</strong> &nbsp;&nbsp;&nbsp;</td>
          <td width="15%" style="font-size: 11px;"><strong><%=(String)vSubList.elementAt(0)%></strong></td>
          <td width="7%" style="font-size: 11px;">&nbsp;</td>
        </tr>
      </table>
      <%}//only if vSubList is not null%> </td>
    <td width="49%" valign="top"> <table width="100%" border="0" cellpadding="0" bgcolor="#FFFFFF">
        <tr> 
          <td width="1%">&nbsp;</td>
          <td width="60%" style="font-size: 11px;"><strong>Tuition fee</strong></td>
          <td width="19%" align="right" style="font-size: 11px;"><strong><%=CommonUtil.formatFloat(fTutionFee,true)%></strong></td>
          <td width="20%" style="font-size: 11px;">&nbsp;</td>
        </tr>
        <tr> 
          <td width="1%">&nbsp;</td>
          <td width="60%" style="font-size: 11px;"><strong>Computer Lab fee</strong></td>
          <td width="19%" align="right" style="font-size: 11px;"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></td>
          <td width="20%" style="font-size: 11px;">&nbsp;</td>
        </tr>
        <tr> 
          <td width="1%">&nbsp;</td>
          <td width="60%" style="font-size: 11px;"><strong>Miscellaneous fee(TOTAL)</strong></td>
          <td width="19%" align="right" style="font-size: 11px;"><strong><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></strong></td>
          <td width="20%" style="font-size: 11px;">&nbsp;</td>
        </tr>
        <%
for(int i=0; i<vMiscFeeInfo.size(); i += 3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") !=0) {
		continue;
	}%>
        <tr> 
          <td width="1%">&nbsp;</td>
          <td width="60%" style="font-size: 11px;">&nbsp;&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
          <td width="19%" align="right" style="font-size: 11px;"> <%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
          <td width="20%" style="font-size: 11px;">&nbsp;</td>
        </tr>
        <%}
if(fMiscOtherFee > 0f) {%>
        <tr> 
          <td width="1%">&nbsp;</td>
          <td width="60%" style="font-size: 11px;"><strong>Other fee(TOTAL)</strong></td>
          <td width="19%" align="right" style="font-size: 11px;"><strong><%=CommonUtil.formatFloat(fMiscOtherFee,true)%></strong></td>
          <td width="20%" style="font-size: 11px;">&nbsp;</td>
        </tr>
        <%
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0) {
		continue;
	}%>
        <tr> 
          <td width="1%">&nbsp;</td>
          <td width="60%" style="font-size: 11px;">&nbsp;&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
          <td width="19%" align="right" style="font-size: 11px;"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
          <td width="20%" style="font-size: 11px;">&nbsp;</td>
        </tr>
        <%}//end of for loop
}//end of fMiscOtherFee if it is > 0f%>
      </table></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="4%" height="20">&nbsp;</td>
    <td colspan="2" valign="bottom"><div align="center"> _______________________________________</div></td>
    <td width="4%" height="20">&nbsp;</td>
    <td width="5%" height="20">&nbsp;</td>
    <td height="20" colspan="2"><hr size="1" width="80%" align="left"></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td colspan="2" valign="top"><div align="center"><font size="1">(Signature 
        of Student/Grantee)</font> </div></td>
    <td height="20">&nbsp;</td>
    <td height="20">&nbsp;</td>
    <td width="32%" height="20"><strong>Gross Total</strong></td>
    <td width="17%" height="20"><strong><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%></strong></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td colspan="2" valign="top"><div align="center"></div></td>
    <td height="20">&nbsp;</td>
    <td height="20">&nbsp;</td>
    <td height="20">&nbsp;</td>
    <td height="20">&nbsp;</td>
  </tr>
</table>
  
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="4%" height="25">&nbsp;</td>
    <td height="25" valign="bottom">Prepared by: </td>
    <td height="25" colspan="2">&nbsp;</td>
  </tr>
  <tr> 
    <td height="20" align="center">&nbsp;</td>
    <td height="30">&nbsp;</td>
    <td height="20" colspan="2">&nbsp;</td>
  </tr>
  <tr> 
    <td height="20" align="center">&nbsp;</td>
    <td height="20"> <div align="center"><u><font size="2">___<%=CommonUtil.getNameForAMemberType(dbOP,"Scholarship Coordinator",1)%></font></u><font size="2">___</font></div></td>
    <td height="20" colspan="2">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25"><div align="center"></div></td>
    <td width="39%" valign="top"><div align="center"><font size="1">Scholarship 
        Coordinator </font></div></td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr> 
    <td height="15">&nbsp;</td>
    <td>Certified Correct :</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr> 
    <td height="30">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td><div align="center"><u><font size="2">___<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"head accountant",1))%></font></u><font size="2">___</font></div>
      <div align="center"></div></td>
    <td width="39%"><div align="center"><u></u></div></td>
    <td width="18%">&nbsp;</td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td valign="top"><div align="center"><font size="1">Accountant</font></div></td>
    <td valign="top"><div align="center"></div></td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td height="35">&nbsp;</td>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td valign="top"><div align="center"><u><font size="2">___<%=CommonUtil.getNameForAMemberType(dbOP,"university registrar",1)%>___</font></u></div></td>
    <td valign="top">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td valign="top"><div align="center"><font size="1">University Registrar </font></div></td>
    <td valign="top">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<script language="JavaScript">
window.print();
</script>

<%}//only if vCHEDScholar is not null
%>
</body>
</html>
<%
dbOP.cleanUP();
%>
