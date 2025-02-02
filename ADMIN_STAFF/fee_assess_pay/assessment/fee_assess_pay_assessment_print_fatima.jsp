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

<body onLoad="window.print();">
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

String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
if(strErrMsg != null)//if student information is found.
{%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="22" align="center"><%=strErrMsg%></td>
    </tr>
</table>
<%
dbOP.cleanUP();
return;}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="22" colspan="4" align="center" valign="top">&nbsp; </td>
    <td width="91%" height="22" align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
      <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br> <br>
      <strong>STUDENT ASSESSMENT</strong><strong><br>
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

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td width="15%" height="19" class="thinborder" style="font-size:9px;">SUBJECT CODE </td>
      <td width="35%" class="thinborder" style="font-size:9px;">SUBJECT TITLE</td>
      <td width="10%" class="thinborder" style="font-size:9px;">LEC/LAB UNITS</td>
      <td width="10%" class="thinborder" style="font-size:9px;">TOTAL UNITS</td>
      <td width="10%" class="thinborder" style="font-size:9px;">UNITS TAKEN</td>
      <td width="10%" class="thinborder" style="font-size:9px;">RATE/UNIT</td>
      <td width="10%" class="thinborder" style="font-size:9px;">TOTAL SUBJECT FEE</td>
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
      <td height="22" class="thinborder"><%=(String)vSubjectDtls.elementAt(i+1)%></td>
      <td class="thinborder"><%=(String)vSubjectDtls.elementAt(i+2)%></td>

    <td class="thinborder"><%=(String)vSubjectDtls.elementAt(i+3)%>/<%=(String)vSubjectDtls.elementAt(i+4)%></td>
    <td class="thinborder"><%=fTotalUnit%></td>
    <td class="thinborder"><%=(String)vSubjectDtls.elementAt(i+9)%></td>
    <td class="thinborder"><%=strRatePerUnit%></td>
    <td class="thinborder"><%=strSubTotalRate%></td>
    </tr>
	<% i = i+9;
strRoomAndSection = null;
strSchedule = null;
	}%>
    <tr bgcolor="#FFFFFF">
      <td colspan="7" height="22" class="thinborder"><div align="center">TOTAL LOAD UNITS/UNITS TAKEN:
        <strong><%=fTotalLoad%>/<%=fUnitsTaken%></strong></div></td>
    </tr>
  </table>
<%
if(strErrMsg == null) {%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td width="48%">
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
					<tr>
					  <td width="5%" height="22">&nbsp;</td>
					  <td width="44%"><strong><font size="1">TUITION FEE :
					  <%=WI.getStrValue(FO.getRebateCon())%>
					  </font></strong></td>
					  <td width="51%"><strong><font size="1">Php <%=CommonUtil.formatFloat(fTutionFee,true)%>
						</font></strong></td>
				    </tr>
					<tr>
					  <td height="22">&nbsp;</td>
					  <td><strong><font size="1">MISCELLANEOUS
						FEES :</font></strong></td>
					  <td><strong><font size="1"><strong>Php<font size="1"> <%=CommonUtil.formatFloat(fMiscFee,true)%></font></strong></font></strong></td>
				    </tr>
					<tr>
					  <td height="22">&nbsp;</td>
					  <td><strong><font size="1">COMPUTER
						LAB. FEE : </font></strong></td>
					  <td><strong><font size="1">Php <%=CommonUtil.formatFloat(fCompLabFee,true)%></font></strong></td>
				    </tr>
					<%if(dFatimaInstallmentFee > 0d) {%>
						<tr style="font-weight:bold">
						  <td height="22">&nbsp;</td>
						  <td style="font-size:9px;">INSTALLMENT FEE  </td>
						  <td style="font-size:9px;">Php <%=CommonUtil.formatFloat(dFatimaInstallmentFee, true)%></td>
						</tr>
					<%}%>
					<tr>
					  <td height="22">&nbsp;</td>
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
      <td height="22"  colspan="2"><strong>OUTSTANDING BALANCE : </strong></td>
    </tr>
    <tr>
      <td width="28%" height="22"><strong>Php </font><%=CommonUtil.formatFloat(fOutStandingFee,true)%></strong></td>
      <td width="31%">&nbsp;</td>
    </tr>
    <tr>
      <td height="22"><strong><u>TOTAL
        AMOUNT DUE:</u></font></strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr style="font-weight:bold">
      <td height="22">Php <%=CommonUtil.formatFloat((fOutStandingFee+fTutionFee+fMiscFee+fCompLabFee + dFatimaInstallmentFee),true)%></td>
      <td>&nbsp;</td>
    </tr>

    <tr>
      <td height="22" colspan="2">
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


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
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
	<td  width="2%" height="22">&nbsp;</td>
	<td  width="98%" height="22"><%=strErrMsg%></td>
	</tr>
</table>
<%}%>
</body>
</html>
