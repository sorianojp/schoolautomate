<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.CurriculumMaintenance,
	enrollment.FAAssessment,enrollment.SubjectSection,enrollment.EnrlAddDropSubject,java.util.Vector,java.sql.ResultSet" %>
<%
	WebInterface WI = new WebInterface(request);
	//I have to get the school code here.
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null) {
		%>
		<font style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:14px; color:#FF0000">
			You are already logged out. Please login again to access this page.
		<%
		return;
	}
	String strFontSize = WI.getStrValue(WI.fillTextValue("font_size"),"10")+"px";
	
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
	font-size: <%=strFontSize%>;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}
<%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("CGH")){%>
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }
<%}%>
-->
</style>
</head>
<script language="javascript">
function LoadPage() {
	//alert("Please click OK to print page");
	//alert(document.getElementById("student_copy").innerHTML);
	//document.getElementById("registrar_copy").innerHTML = document.getElementById("student_copy").innerHTML;
	//document.getElementById("accountant_copy").innerHTML = document.getElementById("student_copy").innerHTML;
}
</script>
<body onLoad="LoadPage();window.print();" topmargin="0" bottommargin="0">
<%
	DBOperation dbOP = null;

	String strErrMsg = null;
	String strTemp = null;
	String strSubSecIndex = null;
	Vector vLabSched      = null;
	String strORNumber    = WI.fillTextValue("or_number");
	String strDegreeType  = null;

	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};
	String[] astrSchYrInfo = {"0","0","0"};

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-assessedfees print(enrollment)","enrollment_receipt_print.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
							//							"assessedfees.jsp");
if(iAccessLevel == -1)//for fatal error.
{

	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
//end of authenticaion code.

if(strORNumber.length() ==0)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		OR Number can't be empty</font></p>
		<%
	dbOP.cleanUP();
	return;
}

String strAddBR = null;

Vector vStudInfo = null;
Vector vTemp = null;
Vector vORInfo = null;
Vector vMiscFeeInfo = null;
Vector vInstallmentDtls = null;

String 	strCollegeName = null;
float fTutionFee        = 0f;
float fMiscFee          = 0f;
float fCompLabFee       = 0f;
float fOutstanding      = 0f;
float fMiscOtherFee		= 0f;//This is the misc fee other charges,

double dTotalDiscount   = 0d;double dDiscPerInstallment = 0d;
String strDiscountName = null;//shown for fatima. name of discount.


String strEnrolmentDiscDetail = null;
float fEnrollmentDiscount = 0f; //this sum of full payment, early enrollment or late enrollment discount/fine implementations.
float fPayableAfterDiscount = 0f;
double dReservationFee = 0d;//only for CGH.
double dDPFineCGH = 0d;
double dInstallment = 0d;
int iCount = 0;

SubjectSection SS   = new SubjectSection();
FAPayment faPayment = new FAPayment();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAAssessment FA     = new FAAssessment();
FAFeeOperation fOperation = new FAFeeOperation();
Advising advising   = new Advising();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();

Vector vAssessedSubDetail = null;

vORInfo = faPayment.viewPmtDetail(dbOP,strORNumber);
if(vORInfo == null || vORInfo.size() ==0)
{%>
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=faPayment.getErrMsg()%></font></p>
  <%
	dbOP.cleanUP();
	return;
}

vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
				(String)vORInfo.elementAt(25),(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vORInfo.elementAt(22));
if(vStudInfo == null) 
	strErrMsg = enrlStudInfo.getErrMsg();
else
{//System.out.println(vStudInfo);
	astrSchYrInfo[0] = (String)vORInfo.elementAt(23);
	astrSchYrInfo[1] = (String)vORInfo.elementAt(24);
	astrSchYrInfo[2] = (String)vORInfo.elementAt(22);

	paymentUtil.setTempUser("0");
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,
        (String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(5),
        (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(4),
        (String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),
        (String)vORInfo.elementAt(22));//System.out.println("Test : "+vMiscFeeInfo);

	strCollegeName = new CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(5));
	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
}
if(strErrMsg == null) //collect fee details here.
{
	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));
	//System.out.println((String)vORInfo.elementAt(4));
	if(fTutionFee > 0f)
	{
		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));
		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));
		fOperation.checkIsEnrolling(dbOP, (String)vStudInfo.elementAt(0),
				(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vORInfo.elementAt(22));
		fOutstanding= fOperation.calOutStandingOfPrevYearSemEnrolling(dbOP, (String)vStudInfo.elementAt(0));
		//I have to remove the ledg_history informations.
		if(!paymentUtil.isTempStud()) {
			double dLedgHistoryExcess = fOperation.calLedgHistoryEntryAfterASYTerm(dbOP, (String)vStudInfo.elementAt(0),
            	                                         (String)vORInfo.elementAt(23), (String)vORInfo.elementAt(22));
			if(dLedgHistoryExcess != fOperation.fDefaultErrorValue)
				fOutstanding -= (float)dLedgHistoryExcess;
		}
		fMiscOtherFee = fOperation.getMiscOtherFee();

		dTotalDiscount = fOperation.calAdjustmentRebate(dbOP,(String)vStudInfo.elementAt(0),(String)vORInfo.elementAt(23),
        						(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22),null);

		if(dTotalDiscount > 0d) {
			strDiscountName = "select MAIN_TYPE_NAME, SUB_TYPE_NAME1,SUB_TYPE_NAME2,SUB_TYPE_NAME3,SUB_TYPE_NAME4,SUB_TYPE_NAME5 from FA_STUD_PMT_ADJUSTMENT  "+
								"join FA_FEE_ADJUSTMENT on (FA_FEE_ADJUSTMENT.fa_fa_index = FA_STUD_PMT_ADJUSTMENT.fa_fa_index) " +
								" where USER_INDEX = "+vStudInfo.elementAt(0)+" and FA_STUD_PMT_ADJUSTMENT.sy_from = "+(String)vORInfo.elementAt(23)+" and FA_STUD_PMT_ADJUSTMENT.semester = "+
								(String)vORInfo.elementAt(22)+" and FA_STUD_PMT_ADJUSTMENT.is_valid = 1";
			java.sql.ResultSet rs = null;
			rs = dbOP.executeQuery(strDiscountName);
			strDiscountName = null;
			while(rs.next()) {
				strTemp = rs.getString(1);
				if(rs.getString(2) != null)
					strTemp = strTemp + ": "+rs.getString(2);
				if(rs.getString(3) != null)
					strTemp = strTemp +": "+rs.getString(3);
				if(rs.getString(4) != null)
					strTemp = strTemp +": "+rs.getString(4);
				if(rs.getString(5) != null)
					strTemp = strTemp +": "+rs.getString(5);
				if(rs.getString(6) != null)
					strTemp = strTemp +": "+rs.getString(6);
					
				if(strDiscountName == null)
					strDiscountName = strTemp;
				else	
					strDiscountName =strDiscountName + ", "+strTemp;
			}
		}

		
		
		enrollment.FAFeeOperationDiscountEnrollment test = new enrollment.FAFeeOperationDiscountEnrollment();
		vTemp = test.calEnrollmentDateDiscount(dbOP, fTutionFee,fTutionFee+fMiscFee+fCompLabFee,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),
                                        (String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22),
                                        fOperation.dReqSubAmt);
		if(vTemp != null && vTemp.size() > 0)
			strEnrolmentDiscDetail = (String)vTemp.elementAt(0);//System.out.println(vTemp);
		if(strEnrolmentDiscDetail != null && vTemp != null && vTemp.size() > 0)
		{
			fEnrollmentDiscount = ((Float)vTemp.elementAt(1)).floatValue();
			fPayableAfterDiscount = fTutionFee+fMiscFee+fCompLabFee+fOutstanding-fEnrollmentDiscount;
			
			//System.out.println(" fEnrollmentDiscount : "+fEnrollmentDiscount);
			//System.out.println(" fPayableAfterDiscount : "+fPayableAfterDiscount);
			//System.out.println(" fMiscFee : "+fMiscFee);
			//System.out.println(" fTutionFee : "+fTutionFee);
			//System.out.println(" fCompLabFee : "+fCompLabFee);
			//System.out.println(" fMiscOtherFee : "+fMiscOtherFee);
			//System.out.println(" fOutstanding : "+fOutstanding);
		}

		strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",(String)vStudInfo.elementAt(5), "degree_type"," and is_valid=1 and is_del=0");
		vAssessedSubDetail = FA.getAssessSubDetailAfterOrBeforeEnrl(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),
					(String)vORInfo.elementAt(22),"1",strDegreeType);
		if(vAssessedSubDetail == null || vAssessedSubDetail.size() ==0)
			strErrMsg = FA.getErrMsg();
		if(strSchoolCode.startsWith("CGH") || strSchoolCode.startsWith("UDMC") || strSchoolCode.startsWith("AUF")) {
			dReservationFee = paymentUtil.getReservationFeeCGH(dbOP, (String)vStudInfo.elementAt(0),astrSchYrInfo[0], astrSchYrInfo[1],
						astrSchYrInfo[2],paymentUtil.isTempStud());
			//I have to find out if there is a d/p late charge.
			if(strSchoolCode.startsWith("CGH")){
				//get late fine for d/p
				strTemp = "select AMOUNT from FA_STUD_PAYABLE where is_valid = 1 and user_index = "+
					(String)vStudInfo.elementAt(0)+" and sy_from ="+(String)vORInfo.elementAt(23)+
					" and semester = "+(String)vORInfo.elementAt(22) +" and note like 'Late payment surcharge(D/P)'";
				strTemp = dbOP.getResultOfAQuery(strTemp,0);
				if(strTemp != null) {
					try {
						dDPFineCGH = Double.parseDouble(strTemp);
					}
					catch(Exception e){}
				}
					
			}
		}

	}
	else
		strErrMsg = fOperation.getErrMsg();
}
//if no error, get the misc fee details having hands on without computer subjects.
if(strErrMsg == null)
{
	if(fMiscFee > 0.1f) {
		vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
						(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22));
		if(vTemp == null)
			strErrMsg = paymentUtil.getErrMsg();
		else
			vMiscFeeInfo.addAll(vTemp);//System.out.println(vMiscFeeInfo);
	}
	if(fOperation.vMultipleOCMapInfo != null && fOperation.vMultipleOCMapInfo.size() > 0) 
		vMiscFeeInfo.addAll(fOperation.vMultipleOCMapInfo);

	//add here the laboratory deposit if there is any.
	if(fOperation.getLabDepositAmt() > 0f)
	{
		vMiscFeeInfo.addElement("Laboratory Deposit");
		vMiscFeeInfo.addElement(Float.toString(fOperation.getLabDepositAmt()));
		vMiscFeeInfo.addElement("1");
	}

	vInstallmentDtls = FA.getInstallmentPayablePerStudent(dbOP,(String)vStudInfo.elementAt(0),
							(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),
							(String)vORInfo.elementAt(22)) ;
	if(vInstallmentDtls == null)
		strErrMsg = FA.getErrMsg();

}
if(fMiscFee <=0.1f) {
	vMiscFeeInfo = new Vector();
	vMiscFeeInfo.addElement("");vMiscFeeInfo.addElement("");vMiscFeeInfo.addElement("");
}


//I have to get here the student information.. 
Vector vStudPersonalInfo = new Vector();
//[0] 0 = gender, 1 = nationality, 2 = dob, 3 = place of birth, 4 = civil stat, 5 = spouse
//6 = res address, 7 = contact address, 8 = guardian, 9 = relation, 10 = emer address
//11 = f name, 12= f occupation, 13= m name, 14 = m occupation.
if(vStudInfo != null) {
	String strSQLQuery = "select gender, nationality, dob, place_of_birth,civil_stat, spouse_name  from info_personal where user_index = "+(String)vStudInfo.elementAt(0);
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	rs.next();
	vStudPersonalInfo.addElement(rs.getString(1));vStudPersonalInfo.addElement(rs.getString(2));
	vStudPersonalInfo.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(3), true));
	vStudPersonalInfo.addElement(rs.getString(4));vStudPersonalInfo.addElement(rs.getString(5));vStudPersonalInfo.addElement(rs.getString(6));
	rs.close();
	strSQLQuery = "select res_house_no, res_city, res_provience, res_country, res_zip, con_house_no, con_city, con_provience, con_country, con_zip, "+
						 "	emgn_per_name, emgn_per_rel, emgn_house_no, emgn_city, emgn_provience, emgn_country, emgn_zip from info_contact where user_index = "+
						 (String)vStudInfo.elementAt(0);
	rs = dbOP.executeQuery(strSQLQuery);
	
	if(rs.next()) {
		///start of residence address.
		strTemp = rs.getString(1);
		if(rs.getString(2) != null) {
			if(strTemp == null)
				strTemp = rs.getString(2);
			else	
				strTemp = strTemp + ","+rs.getString(2);
		}
		if(rs.getString(3) != null) {
			if(strTemp == null)
				strTemp = rs.getString(3);
			else	
				strTemp = strTemp + ","+rs.getString(3);
		}
		if(rs.getString(4) != null) {
			if(strTemp == null)
				strTemp = rs.getString(4);
			else	
				strTemp = strTemp + ","+rs.getString(4);
		}
		if(rs.getString(5) != null) {
			if(strTemp == null)
				strTemp = rs.getString(5);
			else	
				strTemp = strTemp + " - "+rs.getString(5);
		}
		vStudPersonalInfo.addElement(strTemp);
		///end of residence address.
		
		///start of contact address.
		strTemp = rs.getString(6);
		if(rs.getString(7) != null) {
			if(strTemp == null)
				strTemp = rs.getString(7);
			else	
				strTemp = strTemp + ","+rs.getString(7);
		}
		if(rs.getString(8) != null) {
			if(strTemp == null)
				strTemp = rs.getString(8);
			else	
				strTemp = strTemp + ","+rs.getString(8);
		}
		if(rs.getString(9) != null) {
			if(strTemp == null)
				strTemp = rs.getString(9);
			else	
				strTemp = strTemp + ","+rs.getString(9);
		}
		if(rs.getString(10) != null) {
			if(strTemp == null)
				strTemp = rs.getString(10);
			else	
				strTemp = strTemp + " - "+rs.getString(10);
		}
		
		vStudPersonalInfo.addElement(strTemp);
		
		vStudPersonalInfo.addElement(rs.getString(11));
		vStudPersonalInfo.addElement(rs.getString(12));
		
		///end of contact address.
		
		///start of emergency address.
		strTemp = rs.getString(13);
		if(rs.getString(14) != null) {
			if(strTemp == null)
				strTemp = rs.getString(14);
			else	
				strTemp = strTemp + ","+rs.getString(14);
		}
		if(rs.getString(15) != null) {
			if(strTemp == null)
				strTemp = rs.getString(15);
			else	
				strTemp = strTemp + ","+rs.getString(15);
		}
		if(rs.getString(16) != null) {
			if(strTemp == null)
				strTemp = rs.getString(16);
			else	
				strTemp = strTemp + ","+rs.getString(16);
		}
		if(rs.getString(17) != null) {
			if(strTemp == null)
				strTemp = rs.getString(17);
			else	
				strTemp = strTemp + " - "+rs.getString(17);
		}
		
		
		vStudPersonalInfo.addElement(strTemp);
		///end of emergency address.
	}
	else {
		vStudPersonalInfo.addElement(null);vStudPersonalInfo.addElement(null);vStudPersonalInfo.addElement(null);vStudPersonalInfo.addElement(null);vStudPersonalInfo.addElement(null);
	}
	rs.close();
	strSQLQuery = "select f_name,f_occupation, m_name, m_occupation from info_parent where user_index = "+(String)vStudInfo.elementAt(0);
	rs = dbOP.executeQuery(strSQLQuery);
	
	if(rs.next()) {
		vStudPersonalInfo.addElement(rs.getString(1));vStudPersonalInfo.addElement(rs.getString(2));
		vStudPersonalInfo.addElement(rs.getString(3));vStudPersonalInfo.addElement(rs.getString(4));
	}
	else {
		vStudPersonalInfo.addElement(null);vStudPersonalInfo.addElement(null);vStudPersonalInfo.addElement(null);vStudPersonalInfo.addElement(null);
	}
}


%>
<% if(strErrMsg != null){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <th height="30" colspan="7" scope="col">&nbsp;
      <div align="center">
    <strong><%=strErrMsg%></strong></div>
    </th>
  </tr>
</table>
<%
	dbOP.cleanUP();
	return;
}if(vStudInfo != null && vStudInfo.size() > 0){%>  
<label id="student_copy">
<%int iNoOfSubPrinted = 0;
if(true){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" height="435">
  <tr>
    <th height="51" colspan="6" scope="col">&nbsp;</th>
  </tr>
<%  
String strSQLQuery = "select date_enrolled from stud_curriculum_hist where user_index = "+ vStudInfo.elementAt(0) +
	"and sy_from = " + astrSchYrInfo[0]+ " and semester = "+astrSchYrInfo[2]+" and is_valid = 1";
	
ResultSet rs = dbOP.executeQuery(strSQLQuery);
strTemp = null;
if(rs.next()){
	strTemp = WI.formatDate(rs.getDate(1), 10);
}
rs.close();
%>	
  <tr>
    <td width="7%" height="18">&nbsp;</td>
    <td colspan="4">&nbsp;<strong><%=(String)vORInfo.elementAt(25)%></strong><!-- Stud ID --></td>
    <td width="13%"><%=WI.getStrValue(strTemp, "&nbsp;")%><!-- Date of Enrollment--></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td colspan="4">&nbsp;<strong><%=(String)vStudInfo.elementAt(1)%></strong><!-- Stud Name --></td>
    <td><%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%><!-- Term --></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td colspan="4">&nbsp;<strong><%=(String)vStudInfo.elementAt(16)%>
	<%if(vStudInfo.elementAt(6) != null){%>
      / <%=WI.getStrValue(vStudInfo.elementAt(3))%>
    <%}%> - <%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%>&nbsp;
    </strong><!-- Course - Year Lvl --></td>
    <td><%=astrSchYrInfo[0]+" - "+astrSchYrInfo[1]%><!-- Acad Year --></td>
  </tr>
  <tr>
    <td height="22" colspan="6">&nbsp;</td>
  </tr>
<% 
if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0){
	float fTotalLoad = 0;float fUnitsTaken = 0f;
//	float fTotalSubFee = 0;
	float fTotalUnit = 0;
//	float fSubTotalRate = 0 ; //unit * rate per unit.
int iIndexof = 0;
String strSchedDays = null;
String strSchedTime = null;
String strSchedule = null;
String strRoomAndSection = null;
String strLecLabStat = null;//0 = both,1 = lab, 2 = lec.
	Vector vSubSecDtls = new Vector();
	int iIndex = 0;
	
	java.sql.PreparedStatement pstmtGetLecLabStat = null;
	strTemp = "select IS_ONLY_LAB from enrl_final_cur_list where sub_sec_index=? and enrl_final_cur_list.is_valid = 1 and "+
				"user_index = "+(String)vStudInfo.elementAt(0)+" and IS_TEMP_STUD = 0";
	pstmtGetLecLabStat = dbOP.getPreparedStatement(strTemp);

	for(int i = 0; i< vAssessedSubDetail.size() ; ++i,++iNoOfSubPrinted)
	{
		fTotalUnit = Float.parseFloat((String)vAssessedSubDetail.elementAt(i+3))+Float.parseFloat((String)vAssessedSubDetail.elementAt(i+4));
		fTotalLoad += fTotalUnit;
		fUnitsTaken += Float.parseFloat((String)vAssessedSubDetail.elementAt(i+9));
		strSubSecIndex = (String)vAssessedSubDetail.elementAt(i);
		//GET THE INFORMATION FROM TUITION FEE FAFeeOperation.vTuitionFeeDtls;
		strTemp = (String)vAssessedSubDetail.elementAt(i+1);
		if(strTemp.indexOf("NSTP") != -1){
          iIndex = strTemp.indexOf("(");
          if(iIndex != -1){
            strTemp = strTemp.substring(0,iIndex);
            strTemp = strTemp.trim();
		  }
		}

		strLecLabStat = null;
		if(strSubSecIndex != null && strSubSecIndex.length() > 0) {
			pstmtGetLecLabStat.setString(1,strSubSecIndex);
			rs = pstmtGetLecLabStat.executeQuery();
			if(rs.next())
				strLecLabStat = rs.getString(1);
			rs.close();
		}
		
		//get schedule here.
		if(strSubSecIndex != null && strSubSecIndex.compareTo("-1") != 0) {
			vSubSecDtls = SS.getRoomScheduleDetailInMWF(dbOP, strSubSecIndex);
			vLabSched   = SS.getLabSched(dbOP,strSubSecIndex);
		}else {
			vSubSecDtls = null;vLabSched = null;
		}
		if(vSubSecDtls == null || vSubSecDtls.size() ==0)
		{
			if(strSubSecIndex != null && strSubSecIndex.compareTo("-1") == 0) {//re-enrollment.
				vSubSecDtls = new Vector();
			}
			else {
				strErrMsg = SS.getErrMsg();
				break;
			}
		}
		for(int b=0; b<vSubSecDtls.size(); ++b)
		{
			if(strLecLabStat != null && strLecLabStat.compareTo("1") == 0)//lab only.
				continue;
			
			if(strRoomAndSection == null)
			{
				strRoomAndSection = /*(String)vSubSecDtls.elementAt(b)+"/"+*/(String)vSubSecDtls.elementAt(b+1);				
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
			  if(strLecLabStat != null && strLecLabStat.compareTo("2") == 0)//lec only.
				continue;
		    strSchedule += "<br>"+(String)vLabSched.elementAt(p+2) + "(lab)";
			strRoomAndSection += "<br>" + (String) vLabSched.elementAt(p + 1) + "(lab)";
			p = p+ 2;
		  }
		}
%> 
  <tr valign="top">
    <td height="10" align="right"><%=WI.getStrValue(SS.convertSubSecIndexToOfferingCount(dbOP,request,strSubSecIndex ,astrSchYrInfo[0],astrSchYrInfo[2],"PHILCST"), "&nbsp;")%>&nbsp;</td>
    <td width="13%">&nbsp;<%=(String)vAssessedSubDetail.elementAt(i+1)%><!-- subj code --></td>
    <td width="40%">&nbsp;<%=(String)vAssessedSubDetail.elementAt(i+2)%><!-- subj title --></td>
    <td width="5%"><%=(String)vAssessedSubDetail.elementAt(i+9)%><!-- subj units --></td>
    <td>
	<%=WI.getStrValue(strSchedule,"N/A")%><!-- time -->	</td>
    <td><%=WI.getStrValue(strRoomAndSection,"N/A")%></td>
  </tr>
  <% i = i+9;
strRoomAndSection = null;
strSchedule = null;
}%>
  <tr >
    <td>&nbsp;</td>
    <td><%=(String)request.getSession(false).getAttribute("first_name")%></td>
    <td><div align="right">
      <%if(strErrMsg != null){%>
      <%=strErrMsg%>
      <%}else{%>
      TOTAL UNITS TAKEN:<%}%> 
    </div></td>
    <td><strong> <%=fUnitsTaken%></strong></td>
    <td width="21%">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  
<%}//if vAssessedSubDetail no null%>
</table>
<%}//fake condition if true.%>
</label>
<!--<DIV style="page-break-after:always" >&nbsp;</DIV>-->

<%if(iNoOfSubPrinted < 12)
	strAddBR = "<br><br><br><br>";
else if(iNoOfSubPrinted <13)
	strAddBR = "<br><br><br>";
else if(iNoOfSubPrinted < 14)
	strAddBR = "<br><br>";
else if(iNoOfSubPrinted < 15)
	strAddBR = "<br>";
else 
	strAddBR = "";strAddBR = "";
%><%=strAddBR%>

<label id="registrar_copy">
<%if(true){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" height="452">
  <tr>
    <th height="68" colspan="6" scope="col">&nbsp;</th>
  </tr>
<%  
String strSQLQuery = "select date_enrolled from stud_curriculum_hist where user_index = "+ vStudInfo.elementAt(0) +
	"and sy_from = " + astrSchYrInfo[0]+ " and semester = "+astrSchYrInfo[2]+" and is_valid = 1";
	
ResultSet rs = dbOP.executeQuery(strSQLQuery);
strTemp = null;
if(rs.next()){
	strTemp = WI.formatDate(rs.getDate(1), 10);
}
rs.close();
%>	
  <tr>
    <td width="7%" height="18">&nbsp;</td>
    <td colspan="4">&nbsp;<strong><%=(String)vORInfo.elementAt(25)%></strong><!-- Stud ID --></td>
    <td width="13%"><%=WI.getStrValue(strTemp, "&nbsp;")%><!-- Date of Enrollment--></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td colspan="4">&nbsp;<strong><%=(String)vStudInfo.elementAt(1)%></strong><!-- Stud Name --></td>
    <td><%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%><!-- Term --></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td colspan="4">&nbsp;<strong><%=(String)vStudInfo.elementAt(16)%>
	<%if(vStudInfo.elementAt(6) != null){%>
      / <%=WI.getStrValue(vStudInfo.elementAt(3))%>
    <%}%> - <%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%>&nbsp;
    </strong><!-- Course - Year Lvl --></td>
    <td><%=astrSchYrInfo[0]+" - "+astrSchYrInfo[1]%><!-- Acad Year --></td>
  </tr>
  <tr>
    <td height="22" colspan="6">&nbsp;</td>
  </tr>
<%
if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0){
	float fTotalLoad = 0;float fUnitsTaken = 0f;
//	float fTotalSubFee = 0;
	float fTotalUnit = 0;
//	float fSubTotalRate = 0 ; //unit * rate per unit.
int iIndexof = 0;
String strSchedDays = null;
String strSchedTime = null;
String strSchedule = null;
String strRoomAndSection = null;
String strLecLabStat = null;//0 = both,1 = lab, 2 = lec.
	Vector vSubSecDtls = new Vector();
	int iIndex = 0;
	
	java.sql.PreparedStatement pstmtGetLecLabStat = null;
	strTemp = "select IS_ONLY_LAB from enrl_final_cur_list where sub_sec_index=? and enrl_final_cur_list.is_valid = 1 and "+
				"user_index = "+(String)vStudInfo.elementAt(0)+" and IS_TEMP_STUD = 0";
	pstmtGetLecLabStat = dbOP.getPreparedStatement(strTemp);

	for(int i = 0; i< vAssessedSubDetail.size() ; ++i)
	{
		fTotalUnit = Float.parseFloat((String)vAssessedSubDetail.elementAt(i+3))+Float.parseFloat((String)vAssessedSubDetail.elementAt(i+4));
		fTotalLoad += fTotalUnit;
		fUnitsTaken += Float.parseFloat((String)vAssessedSubDetail.elementAt(i+9));
		strSubSecIndex = (String)vAssessedSubDetail.elementAt(i);
		//GET THE INFORMATION FROM TUITION FEE FAFeeOperation.vTuitionFeeDtls;
		strTemp = (String)vAssessedSubDetail.elementAt(i+1);
		if(strTemp.indexOf("NSTP") != -1){
          iIndex = strTemp.indexOf("(");
          if(iIndex != -1){
            strTemp = strTemp.substring(0,iIndex);
            strTemp = strTemp.trim();
		  }
		}

		strLecLabStat = null;
		if(strSubSecIndex != null && strSubSecIndex.length() > 0) {
			pstmtGetLecLabStat.setString(1,strSubSecIndex);
			rs = pstmtGetLecLabStat.executeQuery();
			if(rs.next())
				strLecLabStat = rs.getString(1);
			rs.close();
		}
		
		//get schedule here.
		if(strSubSecIndex != null && strSubSecIndex.compareTo("-1") != 0) {
			vSubSecDtls = SS.getRoomScheduleDetailInMWF(dbOP, strSubSecIndex);
			vLabSched   = SS.getLabSched(dbOP,strSubSecIndex);
		}else {
			vSubSecDtls = null;vLabSched = null;
		}
		if(vSubSecDtls == null || vSubSecDtls.size() ==0)
		{
			if(strSubSecIndex != null && strSubSecIndex.compareTo("-1") == 0) {//re-enrollment.
				vSubSecDtls = new Vector();
			}
			else {
				strErrMsg = SS.getErrMsg();
				break;
			}
		}
		for(int b=0; b<vSubSecDtls.size(); ++b)
		{
			if(strLecLabStat != null && strLecLabStat.compareTo("1") == 0)//lab only.
				continue;
			
			if(strRoomAndSection == null)
			{
				strRoomAndSection = /*(String)vSubSecDtls.elementAt(b)+"/"+*/(String)vSubSecDtls.elementAt(b+1);				
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
			  if(strLecLabStat != null && strLecLabStat.compareTo("2") == 0)//lec only.
				continue;
		    strSchedule += "<br>"+(String)vLabSched.elementAt(p+2) + "(lab)";
			strRoomAndSection += "<br>" + (String) vLabSched.elementAt(p + 1) + "(lab)";
			p = p+ 2;
		  }
		}
%> 
  <tr valign="top">
    <td height="10" align="right"><%=WI.getStrValue(SS.convertSubSecIndexToOfferingCount(dbOP,request,strSubSecIndex ,astrSchYrInfo[0],astrSchYrInfo[2],"PHILCST"), "&nbsp;")%>&nbsp;</td>
    <td width="13%">&nbsp;<%=(String)vAssessedSubDetail.elementAt(i+1)%><!-- subj code --></td>
    <td width="40%">&nbsp;<%=(String)vAssessedSubDetail.elementAt(i+2)%><!-- subj title --></td>
    <td width="5%"><%=(String)vAssessedSubDetail.elementAt(i+9)%><!-- subj units --></td>
    <td>
	<%=WI.getStrValue(strSchedule,"N/A")%><!-- time -->	</td>
    <td><%=WI.getStrValue(strRoomAndSection,"N/A")%></td>
  </tr>
  <% i = i+9;
strRoomAndSection = null;
strSchedule = null;
}%>
  <tr >
    <td>&nbsp;</td>
    <td><%=(String)request.getSession(false).getAttribute("first_name")%></td>
    <td><div align="right">
      <%if(strErrMsg != null){%>
      <%=strErrMsg%>
      <%}else{%>
      TOTAL UNITS TAKEN:<%}%> 
    </div></td>
    <td><strong> <%=fUnitsTaken%></strong></td>
    <td width="21%">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  
<%}//if vAssessedSubDetail no null%>
</table>
<%}//fake condition if true.%>
</label>
<!--<DIV style="page-break-after:always" >&nbsp;</DIV>-->
<%=strAddBR%>

<label id="accountant_copy">
<%if(true){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" height="452">
  <tr>
    <th height="68" colspan="6" scope="col">&nbsp;</th>
  </tr>
<%  
String strSQLQuery = "select date_enrolled from stud_curriculum_hist where user_index = "+ vStudInfo.elementAt(0) +
	"and sy_from = " + astrSchYrInfo[0]+ " and semester = "+astrSchYrInfo[2]+" and is_valid = 1";
	
ResultSet rs = dbOP.executeQuery(strSQLQuery);
strTemp = null;
if(rs.next()){
	strTemp = WI.formatDate(rs.getDate(1), 10);
}
rs.close();
%>	
  <tr>
    <td width="7%" height="18">&nbsp;</td>
    <td colspan="4">&nbsp;<strong><%=(String)vORInfo.elementAt(25)%></strong><!-- Stud ID --></td>
    <td width="13%"><%=WI.getStrValue(strTemp, "&nbsp;")%><!-- Date of Enrollment--></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td colspan="4">&nbsp;<strong><%=(String)vStudInfo.elementAt(1)%></strong><!-- Stud Name --></td>
    <td><%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%><!-- Term --></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td colspan="4">&nbsp;<strong><%=(String)vStudInfo.elementAt(16)%>
	<%if(vStudInfo.elementAt(6) != null){%>
      / <%=WI.getStrValue(vStudInfo.elementAt(3))%>
    <%}%> - <%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%>&nbsp;
    </strong><!-- Course - Year Lvl --></td>
    <td><%=astrSchYrInfo[0]+" - "+astrSchYrInfo[1]%><!-- Acad Year --></td>
  </tr>
  <tr>
    <td height="22" colspan="6">&nbsp;</td>
  </tr>
<%
if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0){
	float fTotalLoad = 0;float fUnitsTaken = 0f;
//	float fTotalSubFee = 0;
	float fTotalUnit = 0;
//	float fSubTotalRate = 0 ; //unit * rate per unit.
int iIndexof = 0;
String strSchedDays = null;
String strSchedTime = null;
String strSchedule = null;
String strRoomAndSection = null;
String strLecLabStat = null;//0 = both,1 = lab, 2 = lec.
	Vector vSubSecDtls = new Vector();
	int iIndex = 0;
	
	java.sql.PreparedStatement pstmtGetLecLabStat = null;
	strTemp = "select IS_ONLY_LAB from enrl_final_cur_list where sub_sec_index=? and enrl_final_cur_list.is_valid = 1 and "+
				"user_index = "+(String)vStudInfo.elementAt(0)+" and IS_TEMP_STUD = 0";
	pstmtGetLecLabStat = dbOP.getPreparedStatement(strTemp);

	for(int i = 0; i< vAssessedSubDetail.size() ; ++i)
	{
		fTotalUnit = Float.parseFloat((String)vAssessedSubDetail.elementAt(i+3))+Float.parseFloat((String)vAssessedSubDetail.elementAt(i+4));
		fTotalLoad += fTotalUnit;
		fUnitsTaken += Float.parseFloat((String)vAssessedSubDetail.elementAt(i+9));
		strSubSecIndex = (String)vAssessedSubDetail.elementAt(i);
		//GET THE INFORMATION FROM TUITION FEE FAFeeOperation.vTuitionFeeDtls;
		strTemp = (String)vAssessedSubDetail.elementAt(i+1);
		if(strTemp.indexOf("NSTP") != -1){
          iIndex = strTemp.indexOf("(");
          if(iIndex != -1){
            strTemp = strTemp.substring(0,iIndex);
            strTemp = strTemp.trim();
		  }
		}

		strLecLabStat = null;
		if(strSubSecIndex != null && strSubSecIndex.length() > 0) {
			pstmtGetLecLabStat.setString(1,strSubSecIndex);
			rs = pstmtGetLecLabStat.executeQuery();
			if(rs.next())
				strLecLabStat = rs.getString(1);
			rs.close();
		}
		
		//get schedule here.
		if(strSubSecIndex != null && strSubSecIndex.compareTo("-1") != 0) {
			vSubSecDtls = SS.getRoomScheduleDetailInMWF(dbOP, strSubSecIndex);
			vLabSched   = SS.getLabSched(dbOP,strSubSecIndex);
		}else {
			vSubSecDtls = null;vLabSched = null;
		}
		if(vSubSecDtls == null || vSubSecDtls.size() ==0)
		{
			if(strSubSecIndex != null && strSubSecIndex.compareTo("-1") == 0) {//re-enrollment.
				vSubSecDtls = new Vector();
			}
			else {
				strErrMsg = SS.getErrMsg();
				break;
			}
		}
		for(int b=0; b<vSubSecDtls.size(); ++b)
		{
			if(strLecLabStat != null && strLecLabStat.compareTo("1") == 0)//lab only.
				continue;
			
			if(strRoomAndSection == null)
			{
				strRoomAndSection = /*(String)vSubSecDtls.elementAt(b)+"/"+*/(String)vSubSecDtls.elementAt(b+1);				
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
			  if(strLecLabStat != null && strLecLabStat.compareTo("2") == 0)//lec only.
				continue;
		    strSchedule += "<br>"+(String)vLabSched.elementAt(p+2) + "(lab)";
			strRoomAndSection += "<br>" + (String) vLabSched.elementAt(p + 1) + "(lab)";
			p = p+ 2;
		  }
		}
%> 
  <tr valign="top">
    <td height="10" align="right"><%=WI.getStrValue(SS.convertSubSecIndexToOfferingCount(dbOP,request,strSubSecIndex ,astrSchYrInfo[0],astrSchYrInfo[2],"PHILCST"), "&nbsp;")%>&nbsp;</td>
    <td width="13%">&nbsp;<%=(String)vAssessedSubDetail.elementAt(i+1)%><!-- subj code --></td>
    <td width="40%">&nbsp;<%=(String)vAssessedSubDetail.elementAt(i+2)%><!-- subj title --></td>
    <td width="5%"><%=(String)vAssessedSubDetail.elementAt(i+9)%><!-- subj units --></td>
    <td>
	<%=WI.getStrValue(strSchedule,"N/A")%><!-- time -->	</td>
    <td><%=WI.getStrValue(strRoomAndSection,"N/A")%></td>
  </tr>
  <% i = i+9;
strRoomAndSection = null;
strSchedule = null;
}%>
  <tr>
    <td>&nbsp;</td>
    <td><%=(String)request.getSession(false).getAttribute("first_name")%></td>
    <td><div align="right">
      <%if(strErrMsg != null){%>
      <%=strErrMsg%>
      <%}else{%>
      TOTAL UNITS TAKEN:<%}%> 
    </div></td>
    <td><strong> <%=fUnitsTaken%></strong></td>
    <td width="21%">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
<%}//if vAssessedSubDetail no null%>
</table>
<%}//fake condition if true.%>
</label>
<DIV style="page-break-after:always" >&nbsp;</DIV>

&nbsp;
<!--<DIV style="page-break-after:always" >&nbsp;</DIV>-->
<table height="420">
<tr>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
</tr>
</table>
<label id="accounting_assesement">
<table width="265" border="0" cellpadding="0" cellspacing="0" >
	<tr>
		<td colspan="3" height="40"></td>
	</tr>
	<tr>
      <td height="14" colspan="2">TUITION FEE<strong><font size="1"><%=WI.getStrValue(fOperation.getRebateCon())%></font></strong></td>
      <td height="14" width="74" align="right"><%=CommonUtil.formatFloat(fTutionFee,true)%></td>
    </tr>
    <!--
	<tr>
      <td height="14">MISCELLANEOUS FEES</td>
      <td height="14" align="right">&nbsp;</td>
    </tr>
	-->
	<%
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("1") ==0)
				continue;
		%>
 		<tr>
          <td height="14" colspan="2">&nbsp;&nbsp;<font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
          <td height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></div></td>
        </tr>
		<%}%>
		<!--
		<tr> 
		  <td height="14"><font size="1">OTHER CHARGES</font></td>
          <td height="14"><div align="right"></div></td>
        </tr>
		-->
         <%
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0)
				continue;
		%>
        <tr>
          <td height="14" colspan="2">&nbsp;&nbsp;<font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
          <td height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></div></td>
        </tr>
		<%}%>
    <tr>
      <td height="14" colspan="2">OLD ACCOUNTS</td>
      <td height="14" align="right"><font size="1"><%=CommonUtil.formatFloat(fOutstanding,true)%></font></td>
    </tr>
	<tr>
	  <td height="14" colspan="3"><hr size="1" color="#000000"></td>
  </tr>
	<tr>
      <td height="14" colspan="2">TOTAL FEE</td>
      <td height="14" align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding,true)%></strong></font></td>
    </tr>
<%if(dTotalDiscount > 0d) {%>
	<tr>
	  <td height="14" colspan="2"><%=strDiscountName%></td>
	  <td height="14" align="right"><%=CommonUtil.formatFloat(dTotalDiscount, true)%></td>
   </tr>
	<tr>
	  <td height="14" colspan="2">TOTAL BAL DUE</td>
	  <td height="14" align="right" style="font-weight:bold"><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding - dTotalDiscount,true)%></td>
   </tr>
<%}%>
	<tr>
	<td align="center" colspan="3" height="60">
	<strong><%=(String)vStudInfo.elementAt(1)%></strong>
	<hr size="1" color="#000000">
	SIGNATURE OVER PRINTED NAME	</td>
	</tr>
	<%
	
		for(int i = 5; i < vInstallmentDtls.size(); i+=3){
			iCount += 1;
		}
		dDiscPerInstallment   = dTotalDiscount/iCount;
		
		double dInstalmentPmt = (fTutionFee+fCompLabFee+fMiscFee)/iCount - dDiscPerInstallment;
		
		for(int i = 5; i < vInstallmentDtls.size(); i+=3){
			if(i == 5)
				dInstalmentPmt = dInstalmentPmt + (double) fOutstanding;
			else if(i < 9)
				dInstalmentPmt = dInstalmentPmt - (double) fOutstanding;
	%>	
	<tr>
		<td height="18"><%=vInstallmentDtls.elementAt(i)%></td>
		<td><%=vInstallmentDtls.elementAt(i+1)%></td>
		<td align="right"><%=CommonUtil.formatFloat(dInstalmentPmt, true)%></td>
	</tr>
	<%
	}
	%>
</table>	
</label>
<!--<DIV style="page-break-after:always" >&nbsp;</DIV>-->
<br><br><br><br><br><br><br><br><br><br>

<label id="student_assessment">
<table width="723" border="0" cellpadding="0" cellspacing="0">
<tr>
	<td width="267">
	<table width="265" border="0" cellpadding="0" cellspacing="0" >
		<tr>
			<td colspan="2" height="40"></td>
		</tr>
		<tr>
		  <td height="14" width="200">TUITION FEE<strong><font size="1"><%=WI.getStrValue(fOperation.getRebateCon())%></font></strong></td>
		  <td height="14" width="65" align="right"><%=CommonUtil.formatFloat(fTutionFee,true)%></td>
		</tr>
		<!--
		<tr>
		  <td height="14">MISCELLANEOUS FEES</td>
		  <td height="14" align="right">&nbsp;</td>
		</tr>
		-->
		 <%
			for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
				if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("1") ==0)
					continue;
			%>
			<tr>
			  <td height="14">&nbsp;&nbsp;<font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
			  <td height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></div></td>
			</tr>
			<%}%>
		<!--
		<tr> 
		  <td height="14"><font size="1">OTHER CHARGES</font></td>
          <td height="14"><div align="right"></div></td>
        </tr>
		-->
         <%
		for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
			if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0)
				continue;
		%>
        <tr>
          <td height="14">&nbsp;&nbsp;<font size="1"><%=(String)vMiscFeeInfo.elementAt(i)%></font></td>
          <td height="14"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></font></div></td>
        </tr>
		<%}%>
		<tr>
		  <td height="14">OLD ACCOUNTS</td>
		  <td height="14" align="right"><font size="1"><%=CommonUtil.formatFloat(fOutstanding,true)%></font></td>
		</tr>
		<tr>
		  <td height="14" colspan="2"><hr size="1" color="#000000"></td>
	    </tr>
		<tr>
		  <td height="14">TOTAL FEE</td>
		  <td height="14" align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding,true)%></strong></font></td>
		</tr>
<%if(dTotalDiscount > 0d) {%>
	<tr>
	  <td height="14"><%=strDiscountName%></td>
	  <td height="14" align="right"><%=CommonUtil.formatFloat(dTotalDiscount, true)%></td>
   </tr>
	<tr>
	  <td height="14">TOTAL BAL DUE</td>
	  <td height="14" align="right" style="font-weight:bold"><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding - dTotalDiscount,true)%></td>
   </tr>
<%}%>
	</table>	</td>
	<td width="35">&nbsp;	</td>
	<td width="421" rowspan="2">
	<br/><br/><br/><br/><br/><br/><br/><br/>
	<table border="0" width="425" cellpadding="0" cellspacing="0" class="thinborder">
	<tr>	
	<%	
		for(int i = 5; i < vInstallmentDtls.size(); i+=3){%>	
		<td height="18" class="thinborder" align="center" width="85"><%=vInstallmentDtls.elementAt(i)%></td>		
	<%}%>
	</tr><tr>
	<%
	for(int i = 5; i < vInstallmentDtls.size(); i+=3){
	%>	
		<td height="89" class="thinborder">&nbsp;</td>		
	<%}%>
	</tr><tr>
	<%
	for(int i = 5; i < vInstallmentDtls.size(); i+=3){
			if(i == 5)
				dInstalmentPmt = dInstalmentPmt + (double) fOutstanding;
			else if(i < 9)
				dInstalmentPmt = dInstalmentPmt - (double) fOutstanding;
	%>	
		<td height="18" class="thinborder" align="center"><%=CommonUtil.formatFloat(dInstalmentPmt, true)%></td>		
	<%}%>
	</tr>
	</table>
</td>
</tr>
<tr>
	<td align="center" height="127">
	<strong><%=(String)vStudInfo.elementAt(1)%></strong>
	<hr size="1" color="#000000">
	SIGNATURE OVER PRINTED NAME	<br><br>
	Student No : <strong><%=(String)vORInfo.elementAt(25)%></strong></td>
	<td>	</td>
  </tr>
</table>
</label>
<%}//only if stud info is not null;%>

</body>
</html>
<%
dbOP.cleanUP();
%>
