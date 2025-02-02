<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
if(strSchCode.startsWith("FATIMA")) {%>
	<jsp:forward page="./fee_assess_pay_assessment_print_fatima.jsp" />
<%}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>
</head>

<body >
<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.FAAssessment,enrollment.FAFeeOperation,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	String strErrMsg = null;
	String strTemp = null;
	String strUserIndex = null;
	String strDispTempUser = "";
	boolean bolIsTempUser = false;
	String strYrLevel = null;
	String strSubSecIndex = null;
	Vector vLabSched = null;

	WebInterface WI = new WebInterface(request);



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

//end of security code.
Vector vStudInfo = new Vector();
Vector vSubjectDtls = new Vector();
Vector vSubSecDtls = new Vector();

SubjectSection SS = new SubjectSection();
FAAssessment FA = new FAAssessment();
Advising advising = new Advising();//to get student information.
vStudInfo = advising.getStudInfo(dbOP,request.getParameter("stud_id"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));

if(vStudInfo == null || vStudInfo.size() == 0)
	strErrMsg = advising.getErrMsg();
else
{
	strUserIndex = (String)vStudInfo.elementAt(0);
	if( ((String)vStudInfo.elementAt(10)).compareTo("1") == 0)
	{
		strDispTempUser = "(temp student)";
		bolIsTempUser = true;
	}
	strYrLevel = (String)vStudInfo.elementAt(6);
}

String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
if(strErrMsg != null)//if student information is found.
{%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" align="center"><%=strErrMsg%></td>
    </tr>
</table>
<%
dbOP.cleanUP();
return;}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" colspan="4" align="center" valign="top">&nbsp; </td>
    <td width="91%" height="25" align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
      <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br> <br>
      <strong>STUDENT LOAD AND ASSESSMENT</strong><strong><br>
      </strong><%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%> , AY <%=request.getParameter("sy_from")%> to <%=request.getParameter("sy_to")%>
      <br> </td>
  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

  <tr>
    <td  width="2%" height="19">&nbsp;</td>
    <td width="37%" height="19">Student ID :<strong> <%=request.getParameter("stud_id")%></strong></td>
    <td height="19"  colspan="3">Course /Major :<strong> <%=(String)vStudInfo.elementAt(7)%>
      <%if(vStudInfo.elementAt(8) != null){%>
      /<strong><%=(String)vStudInfo.elementAt(8)%></strong>
      <%}%>
      </strong></td>
  </tr>
  <tr>
    <td height="19">&nbsp;</td>
    <td height="19">Student name : <strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
    <td  colspan="3" height="19">Year :<strong> <%=strYrLevel%></strong> </td>
  </tr>
</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
      <td bgcolor="#DEDBCB"><div align="center"></div></td>
  </tr>
</table>


  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="13%" height="18"><div align="center"><strong>SUBJECT
          CODE </strong></div></td>
      <td width="25%" height="19"><div align="center"><strong>SUBJECT
          TITLE</strong></div></td>
      <td width="13%"><div align="center"><strong>SCHEDULE</strong></div></td>
      <td width="10%"><div align="center"><strong>SECTION</strong></div></td>
      <td width="6%"><div align="center"><strong>LEC/LAB UNITS</strong></div></td>
      <td width="6%"><div align="center"><strong>TOTAL UNITS</strong></div></td>
      <td width="6%"><div align="center"><strong>UNITS TAKEN</strong></div></td>
      <td width="7%"><div align="center"><strong>RATE/UNIT</strong></div></td>
      <td width="14%"><div align="center"><strong>TOTAL
          SUBJECT FEE </strong></div></td>
    </tr>
<%
String strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",(String)vStudInfo.elementAt(2), "degree_type"," and is_valid=1 and is_del=0");
vSubjectDtls = FA.getAssessedSubDetail(dbOP,strUserIndex,bolIsTempUser,request.getParameter("sy_from"),request.getParameter("sy_to"),strYrLevel,
										request.getParameter("semester"),strDegreeType);
if(vSubjectDtls == null || vSubjectDtls.size() ==0)
{
	strErrMsg = FA.getErrMsg();
}
else
{
	//get here fee calculations.
	FAFeeOperation FO = new FAFeeOperation();
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
	fOutStandingFee = FO.calOutStandingOfPrevYearSemEnrolling(dbOP, (String)vStudInfo.elementAt(0));

	if(FO.getErrMsg() != null)
		strErrMsg = FO.getErrMsg();



	float fTotalLoad = 0;float fUnitsTaken = 0f;
//	float fTotalSubFee = 0;
	float fTotalUnit = 0;
//	float fSubTotalRate = 0 ; //unit * rate per unit.
	int iIndex = 0;
	String strSubTotalRate = null;
	String strRatePerUnit = null;
	String strFeeTypeCatg = null; //0=>per unit,1= per lec/lab, 2=per subject,3=total tuition fee.

	String strOfferingDur = null;//this is for caregiver and other times schedule with offering_dur;-)

String strSchedule = null;
String strRoomAndSection = null;

	for(int i = 0; i< vSubjectDtls.size() ; ++i)
	{
		if(strFeeTypeCatg == null)	strFeeTypeCatg = (String)vSubjectDtls.elementAt(8);

		fTotalUnit = Float.parseFloat((String)vSubjectDtls.elementAt(i+3))+Float.parseFloat((String)vSubjectDtls.elementAt(i+4));
		fTotalLoad += fTotalUnit;
		fUnitsTaken += Float.parseFloat((String)vSubjectDtls.elementAt(i+9));
		strSubSecIndex = (String)vSubjectDtls.elementAt(i);
		//if( Float.parseFloat((String)vSubjectDtls.elementAt(i+6)) == 0 && Float.parseFloat((String)vSubjectDtls.elementAt(i+7)) == 0)
/********************************************************************************************************************************
***************************************************** OLD WAY OF COMPUTATION ****************************************************
*********************************************************************************************************************************
		if(strFeeTypeCatg.compareTo("0") ==0)//per unit
		{
			strRatePerUnit = (String)vSubjectDtls.elementAt(i+5);
			//fSubTotalRate = fTotalUnit * Float.parseFloat(strRatePerUnit);
			fSubTotalRate = Float.parseFloat((String)vSubjectDtls.elementAt(i+9)) * Float.parseFloat(strRatePerUnit);//units taken
		}
		//else
		else if(strFeeTypeCatg.compareTo("1") ==0)//per unit
		{
			strRatePerUnit = (String)vSubjectDtls.elementAt(i+6) +"/lec "+(String)vSubjectDtls.elementAt(i+7)+"/lab";
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
		vSubSecDtls = SS.getRoomScheduleDetailInMWF(dbOP, strSubSecIndex);
		vLabSched   = SS.getLabSched(dbOP,strSubSecIndex);
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
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>

    <td width="19%"><strong>TUITION FEE :<font size="1"><%=WI.getStrValue(FO.getRebateCon())%>
      </font> </strong></td>
      <td width="20%"><strong>Php <%=CommonUtil.formatFloat(fTutionFee,true)%>
        </strong></td>
      <td  colspan="2"><strong>OUTSTANDING BALANCE : </strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><strong>MISCELLANEOUS
        FEES :</strong></td>

    <td><strong>Php <%=CommonUtil.formatFloat(fMiscFee,true)%></strong></td>
      <td width="28%"><strong>Php <%=CommonUtil.formatFloat(fOutStandingFee,true)%></strong></td>
      <td width="31%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><strong>COMPUTER
        LAB. FEE : </strong></td>

    <td><strong>Php <%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></td>
      <td><strong>TOTAL
        AMOUNT DUE:</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><strong>TOTAL
        TUITION FEE : </strong></td>

    <td><strong>Php <%=CommonUtil.formatFloat((fTutionFee+fMiscFee+fCompLabFee),true)%></strong></td>
      <td><strong>Php <%=CommonUtil.formatFloat((fOutStandingFee+fTutionFee+fMiscFee+fCompLabFee),true)%></strong>
        </td>
      <td>&nbsp;</td>
    </tr>
	<tr>
      <td height="35">&nbsp;</td>
      <td height="19" colspan="2">&nbsp;</td>
      <td height="19" colspan="2" valign="bottom">Printed
        by: _____________________________________________</td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
      <td height="19" colspan="2" valign="top"><div align="center">
          </div></td>
      <td height="19" colspan="2" valign="bottom">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Business
          Office)</td>
    </tr>
  </table>

<% }//end of showing outstaniding/misc/comp lab fee.
  }//end of displaying the detail of the subject taken.

dbOP.cleanUP();
//print if there is any error.
if(strErrMsg != null)
{%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
	<td  width="2%" height="25">&nbsp;</td>
	<td  width="98%" height="25"><%=strErrMsg%></td>
	</tr>
</table>
<%}
else{%>

<script language="JavaScript">
	window.print();
window.setInterval("javascript:window.close();",0);

 </script>
<%}%>
</body>
</html>
