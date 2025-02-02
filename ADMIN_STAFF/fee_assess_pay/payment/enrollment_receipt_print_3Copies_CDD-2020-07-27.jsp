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
	String strFontSize = WI.getStrValue(WI.fillTextValue("font_size"),"11")+"px";
	
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css" media="print">
body{
	font-family: Verdana, Geneva, sans-serif;
	font-size:10pt;
	margin:0px 0px 0px 0px;
}

td{
	font-size:9pt;
}
</style>
</head>
<script language="javascript">
function LoadPage() {
	//alert("Please click OK to print page");
	document.getElementById("accountant_copy").innerHTML = document.getElementById("registrar_copy").innerHTML;
	document.getElementById("student_copy").innerHTML    = document.getElementById("registrar_copy").innerHTML;

	document.getElementById("assessment_student").innerHTML    = document.getElementById("assessment_accounting").innerHTML;
}
</script>
<body onLoad="LoadPage();window.print();">
<%
	DBOperation dbOP = null;

	String strErrMsg = null;
	String strTemp = null;
	String strSubSecIndex = null;
	Vector vLabSched      = null;
	String strORNumber    = WI.fillTextValue("or_number");
	String strDegreeType  = null;

	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};
	String[] astrConvertYr  = {"N/A","FIRST YEAR","SECOND YEAR","THIRD YEAR","FOURTH YEAR","FIFTH YEAR","SIXTH YEAR"};
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
int iCount = 0; float fUnitsTaken = 0f; String strSQLQuery = null; Vector vPmtDtls = new Vector();

SubjectSection SS   = new SubjectSection();
FAPayment faPayment = new FAPayment();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAAssessment FA     = new FAAssessment();
FAFeeOperation fOperation = new FAFeeOperation();
Advising advising   = new Advising();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();

Vector vAssessedSubDetail = null;
java.sql.ResultSet rs = null;

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
		}/****/

		
		
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



	///get payment detail.. 
	strSQLQuery = "select date_paid, or_number, amount from fa_stud_payment where is_valid =1  and user_index = "+(String)vStudInfo.elementAt(0)+
					" and sy_from = "+(String)vORInfo.elementAt(23)+" and semester = "+(String)vORInfo.elementAt(22);
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vPmtDtls.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(1)));
		vPmtDtls.addElement(rs.getString(2));
		vPmtDtls.addElement(CommonUtil.formatFloat(rs.getDouble(3), true));
	}
	rs.close();
}
if(fMiscFee <=0.1f) {
	vMiscFeeInfo = new Vector();
	vMiscFeeInfo.addElement("");vMiscFeeInfo.addElement("");vMiscFeeInfo.addElement("");
}

float fAmtPaidDurEnrl = 0f;
if(vMiscFeeInfo != null && vMiscFeeInfo.size() > 0 && fTutionFee > 0)
{
	//get here payment detail payment method detail.
	Vector[] vRetResult = faPayment.viewTutionFeePaymentDetail(dbOP,(String)vStudInfo.elementAt(0),(String)vORInfo.elementAt(23),
							(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),(String)vORInfo.elementAt(22),paymentUtil.isTempStudInStr(), "0");

	if(vRetResult == null) 
		strErrMsg = faPayment.getErrMsg();
	else {
	 	fAmtPaidDurEnrl = Float.parseFloat((String)vRetResult[1].elementAt(5));
	}
}

String strDateEnrolled = null;
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
<!--<label id="student_copy">-->
<%int iNoOfSubPrinted = 0;
//if(true){%>
<div style="height: 4.60in;" id="registrar_copy">

<%  
//strSQLQuery = "select time_enrolled from stud_curriculum_hist where user_index = "+ vStudInfo.elementAt(0) +
//	"and sy_from = " + astrSchYrInfo[0]+ " and semester = "+astrSchYrInfo[2]+" and is_valid = 1";
	
//rs = dbOP.executeQuery(strSQLQuery);
//if(rs.next())
	//strDateEnrolled = WI.formatDateTime(rs.getLong(1), 5);

//rs.close();

strDateEnrolled = WI.getTodaysDate(10) + " "+WI.getTodaysDate(15);
%>	
<!--- student details -->
<div style="padding:0in 0in 0in 1.40in;">
 <div style="height:0.30in">&nbsp;</div>
<div ><%=(String)vORInfo.elementAt(25)%></div>
<div><%=(String)vStudInfo.elementAt(1)%></div>
<div ><%=(String)vStudInfo.elementAt(16)%>
      <%if(vStudInfo.elementAt(6) != null){%>
/ <%=WI.getStrValue(vStudInfo.elementAt(3))%>
<%}%>
</div>
<div ><%=astrConvertYr[Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(4),"0"))]%></div>
</div>


<!--- subject block -->
 <div style="width:100%; padding:0in 0in 0in 0in; height:2.90in;">
<br><br>
        <% 
			if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0){
				float fTotalLoad = 0;
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
						
						//added code to swap MWF to end. -- xx
						strTemp = (String)vSubSecDtls.elementAt(b+2);
						iIndexof = strTemp.indexOf(" ");
						strTemp = strTemp.substring(iIndexof + 1) + "&nbsp;&nbsp;"+strTemp.substring(0, iIndexof);

						if(strRoomAndSection == null)
						{
							strRoomAndSection = (String)vSubSecDtls.elementAt(b+1) + "/ "+(String)vSubSecDtls.elementAt(b);				
							strSchedule = strTemp;
						}
						else
						{
							strRoomAndSection += "<br>"+(String)vSubSecDtls.elementAt(b+1);
							strSchedule += "<br>"+strTemp;
						}
						b = b+2;
					}
					if(vLabSched != null)
					{
					  for (int p = 0; p < vLabSched.size(); ++p)
					  {
						  if(strLecLabStat != null && strLecLabStat.compareTo("2") == 0)//lec only.
							continue;
						//added code to swap MWF to end. -- xx
						strTemp = (String)vLabSched.elementAt(p+2);
						iIndexof = strTemp.indexOf(" ");
						strTemp = strTemp.substring(iIndexof + 1) + "&nbsp;&nbsp;"+strTemp.substring(0, iIndexof);

						strSchedule += "<br>"+strTemp+ "(lab)";
						strRoomAndSection += "<br>" + (String) vLabSched.elementAt(p + 1) + "(lab)";
						p = p+ 2;
					  }
					}
			%>
      <div style="margin:0in 0in 0in 0.50in">    
      <div style="width:12%; float:left;"><%=(String)vAssessedSubDetail.elementAt(i+1)%></div><!-- subj code -->
      <div style="width:38%; float:left; overflow:hidden;"><div style="white-space: nowrap;"><%=(String)vAssessedSubDetail.elementAt(i+2)%></div></div><!-- subj title -->
      <div style="width:4%; float:left;"><%=(String)vAssessedSubDetail.elementAt(i+9)%></div><!-- subj units -->
      <div style="width:24%; float:left;"><%=WI.getStrValue(strSchedule,"N/A")%></div><!-- time -->
      <div style="width:22%; float:left; text-align:left; overflow:hidden;"><div style="white-space: nowrap;"><%=WI.getStrValue(strRoomAndSection,"N/A")%></div></div>
 	  <div style="clear:both; padding:0px; margin:0px;`"></div>	
      </div>
      <% i = i+9;
			strRoomAndSection = null;
			strSchedule = null;
			}%>
  </div>
    
    

  
  
<div style="width:50%; float:left; ">
<div style="padding:0in 0in 0in 1.50in;">
<%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>, <%=astrSchYrInfo[0]+" - "+astrSchYrInfo[1]%>
</div>
</div>

<div style="width:20%; float:left; text-align:center;"><strong> <%=fUnitsTaken%></strong></div>

<div style="width:30%; float:left;  ">
<div style="padding:0px 0px 0px 0px; text-align:center;"><%=WI.getStrValue(strDateEnrolled, "&nbsp;")%>&nbsp;</div>
</div>

<div style="clear:both; padding:0px; margin:0px">&nbsp;</div>
  
<%}//if vAssessedSubDetail no null%>
<!-- added footer -->
<div style="padding:0px; margin:0px;">&nbsp;</div>
</div>

<!-- Accountant Copy-->
<div id="accountant_copy" style="height:4.60in;">&nbsp;</div>

<!-- Student Copy-->
<div id="student_copy" style="height:4.60in;">&nbsp;</div>



<!--<DIV style="page-break-after:always;" >&nbsp;</DIV>

<DIV style="page-break-after:always" >&nbsp;</DIV>-->
<div style="height:4.60in">&nbsp;</div>

<!------------------ Assessment - Accounting copy --->

<div style="height:4.60in;">
	<div style="float:left; width:65%;">
			<%if(vPmtDtls != null) {%>
				<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td width="16%">&nbsp;</td>
							<td width="16%">&nbsp;</td>
							<td>&nbsp;</td>
						</tr>
					<%for(int i = 0; i < vPmtDtls.size(); i += 3) {%>
						<tr>
							<td><%=vPmtDtls.elementAt(i)%></td>
							<td><%=vPmtDtls.elementAt(i + 1)%></td>
							<td><%=vPmtDtls.elementAt(i + 2)%></td>
						</tr>
					<%}%>
				</table>
			
			<%}%>
	</div>
	<div style="float:right; width:35%">
    	<div id="assessment_accounting" align="left">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" >
				<!--<tr>
					<td colspan="3" height="10"></td>
				</tr>-->
				<tr>
				  <td  colspan="2"><strong>Total Units</strong></td>
				  <td width="29%"  align="right"><strong><%=fUnitsTaken%></strong></td>
				</tr>
				<tr>
				  <td colspan="2"><strong>Tuition Fee<%=WI.getStrValue(fOperation.getRebateCon())%></strong></td>
				  <td  align="right"><%=CommonUtil.formatFloat(fTutionFee,true)%></td>
				</tr>
				<tr>
				  <td colspan="2"><strong>Miscellaneous Fee</strong></td>
				  <td  align="right"><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></td>
				</tr>
				<%
					for(int i = 0; i> vMiscFeeInfo.size(); i +=3){
						if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("1") ==0)
							continue;
					%>
					<tr>
					  <td  colspan="2">&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
					  <td ><div align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></div></td>
					</tr>
					<%}%>
					<tr> 
					  <td colspan="2"><strong>Other Charges</strong></td>
					  <td ><div align="right"><strong><%=CommonUtil.formatFloat(fMiscOtherFee,true)%></strong></div></td>
					</tr>
					 <%
					for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
						if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0)
							continue;
					%>
					<tr>
					  <td  colspan="2">&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
					  <td ><div align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></div></td>
					</tr>
					<%}%>
				<tr>
				  <td  colspan="2"><strong>Old Accounts</strong></td>
				  <td  align="right"><strong><%=CommonUtil.formatFloat(fOutstanding,true)%></strong></td>
				</tr>
				<tr>
				  <td  colspan="3" align="center">--oOo--</td>
			  </tr>
				<tr>
				  <td  colspan="2"><strong>TOTAL FEE</strong></td>
				  <td  align="right"><strong><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding,true)%></strong></td>
				</tr>
				<tr>
				  <td  colspan="2">Downpayment</td>
				  <td  align="right"><%=CommonUtil.formatFloat(fAmtPaidDurEnrl,true)%></td>
			  </tr>
<%if(dTotalDiscount > 0d) {%>
				<tr>
				  <td  colspan="2"><%=strDiscountName%></td>
				  <td  align="right"><%=CommonUtil.formatFloat(dTotalDiscount, true)%></td>
			   </tr>
<%}%>
<%if(fEnrollmentDiscount > 0d) {%>
				<tr>
				  <td  colspan="3"><%=strEnrolmentDiscDetail%></td>
			   </tr>
<%}%>
				<tr>
				  <td  colspan="2"><strong>TOTAL BAL DUE</strong></td>
				  <td  align="right" style="font-weight:bold">
				  <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding - dTotalDiscount - fAmtPaidDurEnrl - fEnrollmentDiscount,true)%></td>
			   </tr>
				<tr>
				  <td  colspan="2"><%=((String)vInstallmentDtls.elementAt(5)).toUpperCase()%></td>
				  <td  align="right" style="font-weight:bold">
				  <%=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(7)),true)%></td>
			  </tr>
<%if(vInstallmentDtls != null && vInstallmentDtls.size() > 5 + 3*1){ //prelim %>
				<tr>
				  <td  colspan="2"><%=((String)vInstallmentDtls.elementAt(5+3*1)).toUpperCase()%></td>
				  <td  align="right" style="font-weight:bold">
		<%=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(5+3*1 +2)),true)%>        </td>
			  </tr>
<%}if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*2) {//midterm%>
        <tr>
          <td colspan="2"><%=((String)vInstallmentDtls.elementAt(5+ 3*2)).toUpperCase()%></td>
		  <td  align="right" style="font-weight:bold">
		<%=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(5+3*2 +2)),true)%>          </td>
        </tr>
<%} if(vInstallmentDtls != null && vInstallmentDtls.size() > 5+ 3*3) {//prelim%>
        <tr>
          <td colspan="2">
		  <%=((String)vInstallmentDtls.elementAt(5+ 3*3)).toUpperCase()%></td>
 		  <td  align="right" style="font-weight:bold">
		 <%=CommonUtil.formatFloat(Double.parseDouble((String)vInstallmentDtls.elementAt(5+3*3 +2)),true)%>          </td>
       </tr>
<%}%>
			</table>	

<!-- Notes-->
<% if((Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(4),"0"))==2) || (Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(4),"0"))==3)){ %>
<p style="font-size:8pt;">
	To: <strong>Tulong Dunong Beneficiary</strong><br>
The tuition fee indicated does not yet include discount from Tupad Pangarap. This will be granted upon CdD's receipt of CHED's Tulong Dunong fund. Failure to turn-over the said fund would result to forfeiture of TP discount.
</p>
<% } %>

	  </div>
		</div>
 
<div style="clear:both; padding:0px; margin:0px"></div>
  </div>
<!------------------ Assessment - Student copy --->
	<div style="float:left; width:65%;">
			<%if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0){
			if(vInstallmentDtls == null)
				vInstallmentDtls = new Vector();
			%>
            <br>
			<table width="100%" cellpadding="0" cellspacing="0" border="0">
					  <tr>
						<td width="10%" height="10">&nbsp;</td>
						<%for(int i = 5; i < vInstallmentDtls.size(); i+=3){%>
							<td width="15%" height="10"><%=vInstallmentDtls.elementAt(i + 1)%></td>
						<%}%> 
					  </tr>
					<%for(int i = 0; i< vAssessedSubDetail.size() ; i += 10){%>
					  <tr>
						<td width="10%" height="10"><%=(String)vAssessedSubDetail.elementAt(i+1)%></td>
						<%for(int p = 5; p < vInstallmentDtls.size(); p+=3){%>
							<td width="15%" height="10">__________</td>
						<%}%> 
					  </tr>
				  <%}%>
				</table>
			<%}//end of showing subjects.. %>
		</div>
		<div style="float:right; width:35%;">
			<div id="assessment_student" align="left">&nbsp;</div>	
	</div>

<div style="clear:both; padding:0px; margin:0px"></div>

<%}//only if student info is not null%>
</body>
</html>
<%
dbOP.cleanUP();
%>