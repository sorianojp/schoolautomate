<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>ASSESSMENT</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
/*function ReloadPage()
{
	document.assessment.reloadPage.value = 1;
	document.assessment.submit();
}*/
function ProceedToPayment()
{
	var strStudId = document.assessment.stud_id.value;
	location = "../payment/fee_assess_pay_payment_assessedfees.jsp?stud_id="+escape(strStudId);
}
function PrintPage()
{
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
	{
		var pgLoc = "./fee_assess_pay_assessment_print.jsp?stud_id="+escape(document.assessment.stud_id.value)+"&semester="+
		document.assessment.semester.value+"&sy_from="+
		document.assessment.sy_from.value+"&sy_to="+document.assessment.sy_to.value;
		var win=window.open(pgLoc,"PrintWindow",'width=800,height=500,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=assessment.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.FAAssessment,enrollment.FAFeeOperation,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;

	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strUserIndex = null;
	String strDispTempUser = "";
	boolean bolIsTempUser = false;
	String strYrLevel = null;
	String strSubSecIndex = null;
	Vector vLabSched      = null;

	String strDegreeType = null;


	String[] astrSchYrInfo = null;
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-ASSESSMENT-assessment ","fee_assess_pay_assessment.jsp");
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
boolean bolIsOnlineAdvising = false;

CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","ASSESSMENT",request.getRemoteAddr(),
														"fee_assess_pay_assessment.jsp");
//switch off security if called from online advisign page of student... this page can't be refreshed.
if(WI.fillTextValue("online_advising").compareTo("1") ==0) {
	iAccessLevel = 2;
	bolIsOnlineAdvising = true;
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

astrSchYrInfo = dbOP.getCurSchYr();
if(astrSchYrInfo == null)//db error
{
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=dbOP.getErrMsg()%></font></p>
	<%
	dbOP.cleanUP();
	return;
}

//end of security code.
Vector vStudInfo = new Vector();
Vector vSubjectDtls = new Vector();
Vector vSubSecDtls = new Vector();

String strStudID = WI.fillTextValue("stud_id");
if(bolIsOnlineAdvising)
	strStudID = (String)request.getSession(false).getAttribute("userId");
	

SubjectSection SS = new SubjectSection();
FAAssessment FA = new FAAssessment();
Advising advising = new Advising();//to get student information.
vStudInfo = advising.getStudInfo(dbOP,strStudID,WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsFatima = strSchCode.startsWith("FATIMA");
double dFatimaInstallmentFee = 0d;
String strPlanInfo = null;

String strIsTempStud = "0";

if(vStudInfo == null || vStudInfo.size() == 0)
	strErrMsg = advising.getErrMsg();
else
{
	strUserIndex = (String)vStudInfo.elementAt(0);
	if( ((String)vStudInfo.elementAt(10)).compareTo("1") == 0)
	{
		strDispTempUser = "(temp student)";
		bolIsTempUser = true;
		strIsTempStud = "1";
	}
	strYrLevel = (String)vStudInfo.elementAt(6);
	
	if(bolIsFatima) {
		String strSQLQuery = "select PLAN_NAME, installment_fee from FA_STUD_MIN_REQ_DP_PER_STUD "+
								"join FA_STUD_PLAN_FATIMA on (FA_STUD_PLAN_FATIMA.plan_ref = FA_STUD_MIN_REQ_DP_PER_STUD.plan_ref) "+
								" where is_temp_stud = "+strIsTempStud+" and stud_index = "+strUserIndex+
								" and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester");
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			strPlanInfo = rs.getString(1);
			dFatimaInstallmentFee = rs.getDouble(2);
		}		
		rs.close();		
	}
}



%>
<form name="assessment" action="./fee_assess_pay_assessment.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="8" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          ASSESSMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
  </table>
<%
if(WI.fillTextValue("dispOnly").compareTo("1") != 0 && !bolIsOnlineAdvising)//this is called to display only.
{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="17%" height="25">Enter Student ID</td>
      <td width="16%" height="25"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="6%" height="25"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
      </td>
      <td width="59%"><input name="image" type="image" src="../../../images/form_proceed.gif" width="81" height="21" border="0"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">School Year/Term</td>
      <td height="25" colspan="3">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("assessment","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp;&nbsp;&nbsp; <select name="semester">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = astrSchYrInfo[2];
if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
      <td colspan="2" height="25"><hr size="1"></td>
    </tr>
  </table>
<%} //only if dispOnly = 1
if(strErrMsg == null)//if student information is found.
{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="43%" height="25">Student name :<strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
      <td width="55%">Course :<strong><%=(String)vStudInfo.elementAt(7)%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td>Enrolling yr level :<strong><%=WI.getStrValue(strYrLevel,"N/A")%></strong> </td>
      <td>
	  <%if(vStudInfo.elementAt(8) != null){%>
	  Major:<strong><%=(String)vStudInfo.elementAt(8)%></strong>
	  <%}%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="9"><div align="center">STUDENT
          LOAD AND ASSESSMENT</div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="15%" height="34"><div align="center"><font size="1"><strong>SUBJECT CODE </strong></font></div></td>
      <td width="24%"><div align="center"><font size="1"><strong>SUBJECT TITLE</strong></font></div></td>
      <td width="21%"><div align="center"><font size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="8%"><div align="center"><font size="1"><strong>SECTION &amp; ROOM #</strong></font></div></td>
      <td width="5%"><div align="center"><font size="1"><strong>LEC/LAB UNITS</strong></font></div></td>
      <td width="5%"><div align="center"><font size="1"><strong>TOTAL UNITS</strong></font></div></td>
      <td width="5%"><div align="center"><font size="1"><strong> UNITS TAKEN</strong></font></div></td>
      <td width="6%"><div align="center"><font size="1"><strong>RATE PER UNIT</strong></font></div></td>
      <td width="11%"><div align="center"><font size="1"><strong>TOTAL SUBJECT FEE </strong></font></div></td>
    </tr>
<%
strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",(String)vStudInfo.elementAt(2), "degree_type"," and is_valid=1 and is_del=0");

vSubjectDtls = FA.getAssessedSubDetail(dbOP,strUserIndex,bolIsTempUser,request.getParameter("sy_from"),request.getParameter("sy_to"),strYrLevel,
										request.getParameter("semester"),strDegreeType);
if(vSubjectDtls == null || vSubjectDtls.size() ==0)
{
	strErrMsg = FA.getErrMsg();
}
else
{//System.out.println(vSubjectDtls);
//get here fee calculations.
FAFeeOperation FO = new FAFeeOperation();
int iIndex = 0;
float fOutStandingFee = 0;
float fTutionFee = 0;
float fMiscFee = 0;
float fCompLabFee = 0;
fTutionFee 		= FO.calTutionFee(dbOP, strUserIndex,bolIsTempUser,request.getParameter("sy_from"),request.getParameter("sy_to"),
										strYrLevel, request.getParameter("semester"));
fCompLabFee 	= FO.calHandsOn(dbOP, strUserIndex,bolIsTempUser,request.getParameter("sy_from"),request.getParameter("sy_to"),
										strYrLevel, request.getParameter("semester"));
fMiscFee 		= FO.calMiscFee(dbOP, strUserIndex,bolIsTempUser,request.getParameter("sy_from"),request.getParameter("sy_to"),
										strYrLevel, request.getParameter("semester"));
FO.checkIsEnrolling(dbOP,strUserIndex,request.getParameter("sy_from"),
			request.getParameter("sy_to"),request.getParameter("semester"));

fOutStandingFee = FO.calOutStandingOfPrevYearSemEnrolling(dbOP, (String)vStudInfo.elementAt(0));//System.out.println(fOutStandingFee);
//System.out.println(fTutionFee);
//System.out.println(fCompLabFee);
//System.out.println(fMiscFee);
if(FO.getErrMsg() != null)
	strErrMsg = FO.getErrMsg();



	float fTotalLoad = 0;float fUnitsTaken = 0f;
//	float fTotalSubFee = 0;
	float fTotalUnit = 0;
	float fSubTotalRate = 0 ; //unit * rate per unit.
	String strRatePerUnit = null;
	String strSubTotalRate = null;
	String strFeeTypeCatg = null; //0=>per unit,1= per lec/lab, 2=per subject,3=total tuition fee.

	String strOfferingDur = null;//this is for caregiver and other times schedule with offering_dur;-)


//	float fNSTPUNIT  = 1.5f;

String strSchedule = null;
String strRoomAndSection = null;//System.out.println(FO.vTuitionFeeDtls);

	for(int i = 0; i< vSubjectDtls.size() ; ++i)
	{
		if(strFeeTypeCatg == null)	strFeeTypeCatg = (String)vSubjectDtls.elementAt(8);

		fTotalUnit = Float.parseFloat((String)vSubjectDtls.elementAt(i+3))+Float.parseFloat((String)vSubjectDtls.elementAt(i+4));
		fUnitsTaken += Float.parseFloat((String)vSubjectDtls.elementAt(i+9));
		fTotalLoad += fTotalUnit;
		strSubSecIndex = (String)vSubjectDtls.elementAt(i);
		//if( Float.parseFloat((String)vSubjectDtls.elementAt(i+6)) == 0 && Float.parseFloat((String)vSubjectDtls.elementAt(i+7)) == 0)
/********************************************************************************************************************************
***************************************************** OLD WAY OF COMPUTATION ****************************************************
*********************************************************************************************************************************

		if(strFeeTypeCatg.compareTo("0") ==0)//per unit
		{
			strRatePerUnit = (String)vSubjectDtls.elementAt(i+5);
			if(((String)vSubjectDtls.elementAt(i+1)).indexOf("NSTP") != -1)
				fSubTotalRate = fNSTPUNIT * Float.parseFloat(strRatePerUnit);//units taken
			else
				fSubTotalRate = Float.parseFloat((String)vSubjectDtls.elementAt(i+9)) * Float.parseFloat(strRatePerUnit);//units taken
		}
		//else
		else if(strFeeTypeCatg.compareTo("1") ==0)//per lec-lab unit
		{
			strRatePerUnit = (String)vSubjectDtls.elementAt(i+6) +"/lec "+(String)vSubjectDtls.elementAt(i+7)+"/lab";
			if(((String)vSubjectDtls.elementAt(i+1)).indexOf("NSTP") != -1)
				fSubTotalRate = fNSTPUNIT * Float.parseFloat(strRatePerUnit);//units taken
			else
				fSubTotalRate  = Float.parseFloat((String)vSubjectDtls.elementAt(i+3)) * Float.parseFloat((String)vSubjectDtls.elementAt(i+3))
							+Float.parseFloat((String)vSubjectDtls.elementAt(i+6)) * Float.parseFloat((String)vSubjectDtls.elementAt(i+7));
		}
		else if(strFeeTypeCatg.compareTo("2") ==0)//per subject
		{
			strRatePerUnit = (String)vSubjectDtls.elementAt(i+5)+"/subject";
			fSubTotalRate = Float.parseFloat((String)vSubjectDtls.elementAt(i+5));
		}
		else if(strFeeTypeCatg.compareTo("3") == 0)
		{
			strRatePerUnit = "&nbsp;";
			fSubTotalRate = 0;
		}
		//force fSubTotalRate to 0 if subject is exampted.
		if(fSubTotalRate > 0f)
		{
			if(dbOP.mapOneToOther("FA_SUB_NOFEE join e_sub_section on (e_sub_section.sub_index = FA_SUB_NOFEE.sub_index) ","sub_sec_index",
				(String)vSubjectDtls.elementAt(i),"SUB_NOFEE_INDEX"," and FA_SUB_NOFEE.is_del=0 ") !=null)
				fSubTotalRate = 0f;
		}
********************************************************************************************************************************
***************************************************** END OF OLD WAY OF COMPUTATION ********************************************
********************************************************************************************************************************/
		//GET THE INFORMATION FROM TUITION FEE FAFeeOperation.vTuitionFeeDtls;
		strTemp = (String)vSubjectDtls.elementAt(i+1);
		if(strTemp.indexOf("NSTP") != -1){
          iIndex = strTemp.indexOf("(");
          if(iIndex != -1){
            strTemp = strTemp.substring(0,iIndex);
            strTemp = strTemp.trim();
		  }
		}
		if( (iIndex = FO.vTuitionFeeDtls.indexOf(strTemp)) != -1) {
			strRatePerUnit = (String)FO.vTuitionFeeDtls.elementAt(iIndex+1);
			strSubTotalRate  = (String)FO.vTuitionFeeDtls.elementAt(iIndex+2);
		}
		else {
			strRatePerUnit = "0.00";
			strSubTotalRate  = "0.00";
		}


		//get schedule here.
		vSubSecDtls    = SS.getRoomScheduleDetailInMWF(dbOP, strSubSecIndex);//System.out.println(vSubSecDtls);
		vLabSched      = SS.getLabSched(dbOP,strSubSecIndex);
		strOfferingDur = WI.getStrValue(dbOP.mapOneToOther("E_SUB_SECTION","SUB_SEC_INDEX",strSubSecIndex,"offering_dur",null));
		if(strOfferingDur.length()> 0)
			strOfferingDur += "<br>";

		if(vSubSecDtls == null || vSubSecDtls.size() ==0)
		{
			strErrMsg = SS.getErrMsg();
			break;
		}
		for(int b=0; b<vSubSecDtls.size(); ++b)
		{
			if(strRoomAndSection == null)
			{
				strRoomAndSection = (String)vSubSecDtls.elementAt(b)+"/"+(String)vSubSecDtls.elementAt(b+1);
				strSchedule = (String)vSubSecDtls.elementAt(b+2);
			}
			else
			{
				strRoomAndSection += "<br>"+(String)vSubSecDtls.elementAt(b+1);
				strSchedule += "<br>"+(String)vSubSecDtls.elementAt(b+2);
			}
			b = b+2;
		}
		if(vLabSched != null)
		{
		  for (int p = 0; p < vLabSched.size(); ++p)
		  {
		    strSchedule += "<br>"+(String)vLabSched.elementAt(p+2) + "(lab)";
			strRoomAndSection += "<br>" + (String) vLabSched.elementAt(p + 1) + "(lab)";
			p = p+ 2;
		  }
		}
		%>
	    <tr>
      <td height="25"><%=(String)vSubjectDtls.elementAt(i+1)%></td>
      <td><%=(String)vSubjectDtls.elementAt(i+2)%></td>
      <td><%=strOfferingDur+strSchedule%></td>
      <td><%=strRoomAndSection%></td>
      <td><%=(String)vSubjectDtls.elementAt(i+3)%>/<%=(String)vSubjectDtls.elementAt(i+4)%></td>
      <td><%=fTotalUnit%></td>
      <td><%=(String)vSubjectDtls.elementAt(i+9)%></td>
      <td><%=strRatePerUnit%></td>
      <td><%=strSubTotalRate%></td>
    </tr>
<% i = i+9;
strRoomAndSection = null;
strSchedule = null;
}%>
    <tr bgcolor="#FFFFFF">
      <td colspan="9" height="25"><div align="center">TOTAL LOAD UNITS/UNITS TAKEN:
          <strong><%=fTotalLoad%>/<%=fUnitsTaken%></strong></div></td>
    </tr>
  </table>
<%

if(strErrMsg == null) {
%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td width="48%">
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
					<tr>
					  <td width="5%" height="25">&nbsp;</td>
					  <td width="44%"><strong><font size="1">TUITION FEE :
					  <%=WI.getStrValue(FO.getRebateCon())%>
					  </font></strong></td>
					  <td width="51%"><strong><font size="1">Php <%=CommonUtil.formatFloat(fTutionFee,true)%>
						</font></strong></td>
				    </tr>
					<tr>
					  <td height="25">&nbsp;</td>
					  <td><strong><font size="1">MISCELLANEOUS
						FEES :</font></strong></td>
					  <td><strong><font size="1"><strong>Php<font size="1"> <%=CommonUtil.formatFloat(fMiscFee,true)%></font></strong></font></strong></td>
				    </tr>
					<tr>
					  <td height="25">&nbsp;</td>
					  <td><strong><font size="1">COMPUTER
						LAB. FEE : </font></strong></td>
					  <td><strong><font size="1">Php <%=CommonUtil.formatFloat(fCompLabFee,true)%></font></strong></td>
				    </tr>
					<%if(dFatimaInstallmentFee > 0d) {%>
						<tr style="font-weight:bold">
						  <td height="25">&nbsp;</td>
						  <td style="font-size:9px;">INSTALLMENT FEE  </td>
						  <td style="font-size:9px;">Php <%=CommonUtil.formatFloat(dFatimaInstallmentFee, true)%></td>
						</tr>
					<%}%>
					<tr>
					  <td height="25">&nbsp;</td>
					  <td><strong><font size="1">TOTAL
						TUITION FEE : </font></strong></td>
					  <td><strong><font size="1">Php <%=CommonUtil.formatFloat((fTutionFee+fMiscFee+fCompLabFee + dFatimaInstallmentFee),true)%></font></strong></td>
				    </tr>
				  </table>	
			</td>
			<td width="2%">&nbsp;</td>
			<td width="50%">
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25"  colspan="2"><strong>OUTSTANDING BALANCE : </strong></td>
    </tr>
    <tr>
      <td width="28%" height="25"><strong>Php </font><%=CommonUtil.formatFloat(fOutStandingFee,true)%></strong></td>
      <td width="31%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><strong><u>TOTAL
        AMOUNT DUE:</u></font></strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr style="font-weight:bold">
      <td height="25">Php <%=CommonUtil.formatFloat((fOutStandingFee+fTutionFee+fMiscFee+fCompLabFee + dFatimaInstallmentFee),true)%></td>
      <td>&nbsp;</td>
    </tr>

    <tr>
      <td height="25" colspan="2">
	  <%
	  if(strPlanInfo != null){%>
		<font size="2" style="font-weight:bold"><u>Plan Subscribed: <%=strPlanInfo.toUpperCase()%></u></font>
	  <%}%>
	  
	  </td>
      </tr>
  </table>
			</td>
		</tr>
	</table>

  

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9"><hr size="1"></td>
    </tr>
<%
if(WI.fillTextValue("dispOnly").compareTo("1") != 0 && !bolIsOnlineAdvising){%>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25"><div align="center"><a href="javascript:PrintPage();" target="_self"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>
          <font size="1">click to
          print student load and assessment</font></div></td>
      <td colspan="3" height="25"></td>
      <td  height="25">&nbsp;</td>
    </tr>
<%}%>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<% }//end of showing outstaniding/misc/comp lab fee.
  }//end of displaying the detail of the subject taken.
}//end of display if student information exists

//print if there is any error.
if(strErrMsg != null)
{%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
	<td  width="2%" height="25">&nbsp;</td>
	<td  width="98%" height="25"><%=strErrMsg%></td>
	</tr>
</table>
<%}%>


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
