<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED Enrollment and billing statement</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script>
function ReloadPage() {
	document.financial_report.print_pg.value = "";
	document.financial_report.submit();
}
function PrintPg() {
	document.financial_report.print_pg.value = "1";
	document.financial_report.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=financial_report.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAAssessment,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./cert_enrol_billing_ched_print_ui.jsp" />
	<%	return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","cert_enrol_billing_ched.jsp");
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
														"cert_enrol_billing_ched.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														"cert_enrol_billing_ched.jsp");
}
														
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
String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

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
if(strErrMsg == null) strErrMsg = "";
%>
<form name="financial_report" method="post" action="./cert_enrol_billing_ched_ui.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          CERTIFICATE OF ENROLMENT AND BILLING (CHED) PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=strErrMsg%></b></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="12%">School year </td>
      <td height="25" colspan="2">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("financial_report","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes"></td>
      <td width="66%">Term
        <select name="semester">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">Enter Student ID </td>
      <td width="12%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td width="6%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="66%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></td>
    </tr>
    <tr>
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0)
{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="2" bgcolor="#FFFFFF">
    <tr> 
      <td height="20">&nbsp;</td>
      <td height="20">NAME OF SCHOLARSHIP</td>
      <td height="20"><input type="text" name="name_grant" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td width="2%" height="20">&nbsp;</td>
      <td width="25%" height="20">1. Grant/Award Number : </td>
      <td width="73%" height="20"><input type="text" name="grant_award_no" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td height="20">2. Student's Name : </td>
      <td height="20"><strong><%=(String)vStudInfo.elementAt(12)%>, <%=(String)vStudInfo.elementAt(10)%> 
        <%
	  if(vStudInfo.elementAt(11) != null){%>
        <%=((String)vStudInfo.elementAt(11)).charAt(0)%>. 
        <%}%>
        </strong></td>
    </tr>
    <tr> 
      <td height="19">&nbsp;</td>
      <td height="19">3. Sex : <strong></strong></td>
      <td height="19"><strong><%=(String)vStudInfo.elementAt(13)%></strong></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td height="20">4. Permanent Address : <strong></strong></td>
      <td height="20"> <strong> 
        <%if(vAdditionalInfo != null && vAdditionalInfo.size() > 0){%>
        <%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(7)," - ","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),", ","","")%> 
        <%}%>
        </strong></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td height="20">5. Date of Birth: <strong></strong></td>
      <td height="20"> <strong> 
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
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td height="20"> &nbsp;&nbsp;&nbsp;&nbsp;Year Level : <u></u></td>
      <td height="20"><strong><%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0"))]%></strong></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td height="20">7. School Year : </td>
      <td height="20"><strong><%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td height="20">8. Semester : </td>
      <td height="20"><strong><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%></strong></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="20">&nbsp;</td>
      <td width="38%">9. Subjects Enrolled</td>
      <td width="11%">Units</td>
      <td width="49%">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" style="font-size: 16px;">&nbsp;</td>
      <td colspan="2" valign="top"> 
        <%
			if(vSubList != null && vSubList.size() > 0){%>
        <table width="100%" border="0" cellpadding="0" bgcolor="#FFFFFF">
          <%
				for(int i=1; i<vSubList.size();++i)
				{%>
          <tr> 
            <td width="4%">&nbsp; </td>
            <td width="74%" style="font-size: 11px;"><%=(String)vSubList.elementAt(i+3)%>(<%=(String)vSubList.elementAt(i+4)%>)</td>
            <td width="22%" style="font-size: 11px;"><%=(String)vSubList.elementAt(i+13)%></td>
          </tr>
          <%
			   i = i+13;
			   }%>
          <tr> 
            <td width="4%">&nbsp; </td>
            <td width="74%" align="right" style="font-size: 11px;"><strong>Total 
              Unit(s)</strong> &nbsp;&nbsp;&nbsp;</td>
            <td width="22%" style="font-size: 11px;"><strong><%=(String)vSubList.elementAt(0)%></strong></td>
          </tr>
        </table>
        <%}//only if vSubList is not null%>
      </td>
      <td width="49%" valign="top"> <table width="100%" border="0" cellpadding="0" bgcolor="#FFFFFF">
          <tr> 
            <td width="3%">&nbsp;</td>
            <td width="60%" style="font-size: 11px;"><strong>Tuition fee</strong></td>
            <td width="15%" align="right" style="font-size: 11px;"><strong><%=CommonUtil.formatFloat(fTutionFee,true)%></strong></td>
            <td width="22%" style="font-size: 11px;">&nbsp;</td>
          </tr>
          <tr> 
            <td width="3%">&nbsp;</td>
            <td width="60%" style="font-size: 11px;"><strong>Computer Lab fee</strong></td>
            <td width="15%" align="right" style="font-size: 11px;"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></td>
            <td width="22%" style="font-size: 11px;">&nbsp;</td>
          </tr>
          <tr> 
            <td width="3%">&nbsp;</td>
            <td width="60%" style="font-size: 11px;"><strong>Miscellaneous fee(TOTAL)</strong></td>
            <td width="15%" align="right" style="font-size: 11px;"><strong><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></strong></td>
            <td width="22%" style="font-size: 11px;">&nbsp;</td>
          </tr>
          <%
for(int i=0; i<vMiscFeeInfo.size(); i += 3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") !=0) {
		continue;
	}%>
          <tr> 
            <td width="3%">&nbsp;</td>
            <td width="60%" style="font-size: 11px;">&nbsp;&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
            <td width="15%" align="right" style="font-size: 11px;"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
            <td width="22%" style="font-size: 11px;">&nbsp; </td>
          </tr>
          <%}
if(fMiscOtherFee > 0f) {%>
          <tr> 
            <td width="3%">&nbsp;</td>
            <td width="60%" style="font-size: 11px;"><strong>Other fee(TOTAL)</strong></td>
            <td width="15%" align="right" style="font-size: 11px;"><strong><%=CommonUtil.formatFloat(fMiscOtherFee,true)%></strong></td>
            <td width="22%" style="font-size: 11px;">&nbsp;</td>
          </tr>
          <%
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0) {
		continue;
	}%>
          <tr> 
            <td width="3%">&nbsp;</td>
            <td width="60%" style="font-size: 11px;">&nbsp;&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
            <td width="15%" align="right" style="font-size: 11px;"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
            <td width="22%" style="font-size: 11px;">&nbsp;</td>
          </tr>
          <%}//end of for loop
}//end of fMiscOtherFee if it is > 0f%>
        </table></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="20">&nbsp;</td>
      <td colspan="2" valign="bottom"><div align="center"><br>
        </div></td>
      <td width="5%" height="20">&nbsp;</td>
      <td width="5%" height="20">&nbsp;</td>
      <td height="20" colspan="3"><hr size="1" width="80%" align="left"></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td colspan="2" valign="top"><div align="center"> 
          <hr size="1">
        </div></td>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td width="30%" height="20"><strong>Gross Total</strong></td>
      <td width="2%" height="20" align="right"><strong><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee,true)%></strong></td>
      <td width="17%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td colspan="2" valign="top"><div align="center"><font size="1">(Signature 
          of Student/Grantee)</font></div></td>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td height="20"><strong>Amount Payable</strong></td>
      <td height="20" colspan="2"><input type="text" name="amt_payable" class="textbox" size="12"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td height="25" valign="bottom"><font size="1">Prepared by: </font></td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="22" align="center">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="22" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="20" align="center">&nbsp;</td>
      <td height="20"> <div align="center"><u>___<%=CommonUtil.getNameForAMemberType(dbOP,"Scholarship Coordinator",1)%></u>___</div></td>
      <td height="20" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"></div></td>
      <td width="40%" valign="top"><div align="center"><font size="1">Scholarship 
          Coordinator </font></div></td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><font size="1">Certified Correct :</font></td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><div align="center"><u>___<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"head accountant",1)).toUpperCase()%>___</u></div>
        <div align="center"></div></td>
      <td width="22%"><div align="center"></div></td>
      <td width="34%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top"><div align="center"><font size="1">Accountant</font></div></td>
      <td><div align="center"></div></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><div align="center"><u>___<%=CommonUtil.getNameForAMemberType(dbOP,"university registrar",1).toUpperCase()%>___</u></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top"><div align="center"><font size="1">University Registrar </font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="50%" height="25"><div align="center"></div></td>
      <td colspan="4" height="25"><div align="left"><font size="1"><font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click
          to print report after pressing SAVE icon</font></font></font></div></td>
      <td width="2%" height="25" colspan="3">&nbsp;</td>
    </tr>
	</table>



<%}//only if vCHEDScholar is not null
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 	<tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
