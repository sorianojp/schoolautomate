<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED Enrollment and billing statement</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">

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

TD.thinborderBOTTOM {   
border-bottom: solid 1px #000000;
font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
font-size: 11px;
}


</style>
</head>
<body onLoad="window.print()">
<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAAssessment,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strPesoSign = "P";
	
	boolean bolAssessmentOnly = (WI.fillTextValue("print_assessment_only").length() > 0);

	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","cert_enrol_billing_ched_print.jsp");
	}catch(Exception exp){
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
	Vector vStudInfo1     = null;
	Vector vMiscFeeInfo  = null;
	Vector vTemp         = null;
	Vector vSubList      = null;
	Vector vPayment 	 = null;
	Vector vLedgerInfo   = null;
	Vector vAdjustment   = null;
	Vector vTimeSch		 = null;
	
	String strDegreeType  = null;
	String strSQLQuery = null;
	java.sql.ResultSet rs = null;
	
	Vector vAssessedSubDetail = null;
	
	double dUnitsTaken = 0d;
	
	double dHoursCharged   = 0d;
	double dUnitsExcluded  = 0d; 
	double dUnitsSubNoFee = 0d;
	double dLateFineSPC     = 0d;
	
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
	enrollment.FAStudentLedger faStudLedg = new enrollment.FAStudentLedger();
	
	enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
	String strGender = null;
	String strHisHer = null;
	String strHimHer = null;
	if(WI.fillTextValue("stud_id").length() > 0) {
		vStudInfo1 = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
		if(vStudInfo1 == null || vStudInfo1.size() ==0)
			strErrMsg = offlineAdm.getErrMsg();
	}
	
	vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
						WI.fillTextValue("stud_id"),WI.fillTextValue("sy_from"),
						WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
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
						WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
						(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		if(fTutionFee > 0)
		{
			fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),false,
						WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
						(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
			fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),false,
						WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
						(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
			
			fOutstanding= fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vStudInfo.elementAt(0));
	
			fMiscOtherFee = fOperation.getMiscOtherFee();
	
			fTotalDiscount = fOperation.calAdjustmentRebate(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
									WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"),null);
			fDownpayment   = fOperation.calAmoutPaidDurEnrollment(dbOP,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
									WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
			fTotalAmtPaid  = fOperation.calTotalAmoutPaidPerFee(dbOP, 0,(String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),
									WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
			
						
			//System.out.println((String)vStudInfo.elementAt(0) +" "+(String)vStudInfo.elementAt(4));
			//System.out.println("fCompLabFee "+fCompLabFee);
	
		}
		else
			strErrMsg = fOperation.getErrMsg();
	}
	//if no error, get the misc fee details having hands on without computer subjects.
	if(strErrMsg == null)
	{
			if(fMiscFee > 0.1f) {
		vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
						WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
						(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		if(vTemp == null)
			strErrMsg = paymentUtil.getErrMsg();
		else
			vMiscFeeInfo.addAll(vTemp);
			}
			
			if(fOperation.vMultipleOCMapInfo != null && fOperation.vMultipleOCMapInfo.size() > 0) 
			vMiscFeeInfo.addAll(fOperation.vMultipleOCMapInfo);
	
		if(fOperation.getLabDepositAmt() > 0f)
		{
			vMiscFeeInfo.addElement("Laboratory Deposit");
			vMiscFeeInfo.addElement(Float.toString(fOperation.getLabDepositAmt()));
			vMiscFeeInfo.addElement("1");
		}
		
		strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",(String)vStudInfo.elementAt(5),"degree_type"," and is_valid=1 and is_del=0");
		vAssessedSubDetail = FA.getAssessSubDetailAfterOrBeforeEnrl(dbOP,(String)vStudInfo.elementAt(0),
			            paymentUtil.isTempStud(),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
						(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"),"1",strDegreeType);
		if(vAssessedSubDetail == null || vAssessedSubDetail.size() ==0)
			strErrMsg = FA.getErrMsg();
				
		strSQLQuery = "select fa_stud_payable.amount from fa_stud_payable join fa_oth_sch_fee on (othsch_fee_index = reference_index) "+
			" where user_index = "+WI.fillTextValue("stud_id") +" and sy_from = "+WI.fillTextValue("sy_from")+
			" and semester = "+WI.fillTextValue("semester")+" and fa_stud_payable.is_valid = 1 and fee_name = 'FINES - LATE ENROLMENT'";
		//fee name is Installment Fee and sy_index = 0;
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strSQLQuery != null)
				dLateFineSPC = Double.parseDouble(strSQLQuery);
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
	
	if(strErrMsg == null) {//collect fee details here.
		vLedgerInfo = faStudLedg.viewLedgerTuition(dbOP, (String)vStudInfo.elementAt(0),request.getParameter("sy_from"),
		request.getParameter("sy_to"),null,request.getParameter("semester"), false);//bolShowOnlyDroppedSub=false
		if(vLedgerInfo == null)
			strErrMsg = faStudLedg.getErrMsg();
		else
		{
			vTimeSch 			= (Vector)vLedgerInfo.elementAt(0);
			//vTuitionFeeDetail	= (Vector)vLedgerInfo.elementAt(1);
			vAdjustment			= (Vector)vLedgerInfo.elementAt(2);
			//vRefund				= (Vector)vLedgerInfo.elementAt(3);
			//vDorm 				= (Vector)vLedgerInfo.elementAt(4);
			//vOthSchFine			= (Vector)vLedgerInfo.elementAt(5);
			vPayment			= (Vector)vLedgerInfo.elementAt(6);
			if(vTimeSch == null || vTimeSch.size() ==0)
				strErrMsg = faStudLedg.getErrMsg();
		}
	}
	
	boolean bolIsInternal = false;//only in case of UDMC
	if(WI.fillTextValue("is_internal").equals("1"))
		bolIsInternal = true;
	String[] astrConvertYrLevel = {"","1","2","3","4","5","6","7"};
	String[] astrConvertSem     = {"Summer","First Semester","Second Semester","Third Semester","Fourth Semester"};
	if(strErrMsg == null) strErrMsg = "";
	
	
		

%> 
<body>
<%	

Vector vSubjectPerHour = new Vector();
Vector vSubExcluded = new Vector();

Vector vORTuitionPmt = new Vector();

if(vStudInfo != null && vStudInfo.size() > 0){


strSQLQuery = 	
	" select or_number from FA_STUD_PAYMENT where USER_INDEX = "+(String)vStudInfo.elementAt(0)+
	" and IS_VALID= 1 "+
	" and SY_FROM = "+WI.fillTextValue("sy_from")+
	" and SEMESTER = "+WI.fillTextValue("semester")+
	" and PMT_SCH_INDEX >= 0 "+
	" order by DATE_PAID ";
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()){
	vORTuitionPmt.addElement(rs.getString(1));
}rs.close();



strSQLQuery = "select sub_code, max_hour from fa_tution_fee "+
	"join fa_schyr on (fa_schyr.sy_index = fa_tution_fee.sy_index) "+
	"join subject on (subject.sub_index = fa_tution_fee.sub_index) "+
	" join ( "+
 	"       select max(hour_lec + hour_lab) as max_hour, sub_index as si from curriculum "+
	"       where is_valid = 1 group by sub_index) as dt_cur on dt_cur.si = fa_tution_fee.sub_index "+
	" where compute_per_hour = 1 and (semester is null or semester = "+WI.fillTextValue("semester")+
	") and sy_from = "+WI.fillTextValue("sy_from")+" and fa_tution_fee.is_Valid = 1 and (sub_index_course = 0 or sub_index_course= "+
	(String)vStudInfo.elementAt(5)+")";
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vSubjectPerHour.addElement(rs.getString(1));
		vSubjectPerHour.addElement(new Double(rs.getDouble(2)));
	}
	rs.close();
	
strSQLQuery = "select sub_code from subject join FA_SUB_NOFEE on (FA_SUB_NOFEE.SUB_INDEX = subject.SUB_INDEX) "+
					"where FA_SUB_NOFEE.IS_DEL = 0 and SY_FROM = "+WI.fillTextValue("sy_from")+" and SEMESTER = "+WI.fillTextValue("semester");
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vSubExcluded.addElement(rs.getString(1));
	}
	rs.close();

int iIndexOf = 0;
for(int i = 0; i<vAssessedSubDetail.size(); i+=10) {
	dUnitsTaken += Double.parseDouble((String)vAssessedSubDetail.elementAt(i+9));
	strTemp = (String)vAssessedSubDetail.elementAt(i+1);
	
	iIndexOf = vSubjectPerHour.indexOf(strTemp);
	if(iIndexOf > -1) {//compute per hour
		dUnitsExcluded += Double.parseDouble((String)vAssessedSubDetail.elementAt(i + 9));
		dHoursCharged  += ((Double)vSubjectPerHour.elementAt(iIndexOf + 1)).doubleValue();
	}
	
	if(vSubExcluded.indexOf(strTemp) > -1) {
		dUnitsSubNoFee += Double.parseDouble((String)vAssessedSubDetail.elementAt(i + 9));
	}
}

dUnitsTaken = dUnitsTaken - dUnitsSubNoFee;

%>


   <table  width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr bgcolor="#FFFFFF">
      <td width="5%">&nbsp;</td>
      <td height="25" valign="top">
		 <p ALIGN="CENTER">
	 	 &nbsp;<br>
	 	 &nbsp;<br>
		 <br>
	 	 </p><br />
     	 <p  ALIGN="CENTER"><div align="center"><font size="4"><strong>C  E R T I F I C A T I O N</strong></font></div></p>
    	 <p> <span style="text-align:justify">
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  This is to certify that the breakdown of schedule of fees for 
		  <%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> 
	 	 S.Y <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%> 
		  is true and correct 
		  (<%=((String)vStudInfo1.elementAt(24)).toUpperCase()%>-
		   <%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue((String)vStudInfo.elementAt(4),"0"))]%> Program).
	   </span></p><br />
	   
<table width="100%" border="0"  cellpadding="0" cellspacing="0">
<%if(dHoursCharged == 0d) {%>
				<tr>				 
				  <td width="39%" height="18">Tuition Fee</td>
				  <%
				  	if(dUnitsTaken == 0d)
				  		strTemp = "0.00";
					else
						strTemp  =CommonUtil.formatFloat(((double)fTutionFee / dUnitsTaken) ,true);
				  %>
				  <td width="34%">(<%=dUnitsTaken%> units x P <%=strTemp%>/unit) </td>
			
				  <%
				  	if(dUnitsTaken == 0d)
				  		strTemp = "0.00";
					else
						strTemp  =CommonUtil.formatFloat(fTutionFee ,true);
				  %>
				  <td width="13%" align="right"><%=strTemp%></td>				 
				  <td width="14%" align="right">&nbsp;</td>
				</tr>
<%}else{
double dUnitsCharged = dUnitsTaken - dUnitsExcluded;
double dUnitRate = fTutionFee / (dUnitsCharged + dHoursCharged) ;
if(dUnitsCharged > 0d) {
%>
				<tr>				 
				  <td height="18">Tuition Fee</td>
				  <td> (<%=dUnitsCharged%> units x P <%=CommonUtil.formatFloat(dUnitRate ,true)%>/unit)</td>				  
				  <td align="right"><%=CommonUtil.formatFloat(dUnitRate * dUnitsCharged ,true)%></td>				 
				  <td align="right">&nbsp;</td>
				</tr>
<%}%>
				<tr>				 
				  <td height="18">Tuition Fee w/ Lab Subjects - <%=dUnitsExcluded%> units</td>
				  <td>(<%=dHoursCharged%> cont. hrs. x P <%=CommonUtil.formatFloat(dUnitRate ,true)%>)</td>
				   <td align="right"><%=CommonUtil.formatFloat(dUnitRate * dHoursCharged ,true)%></td>				 
				   <td align="right">&nbsp;</td>
				</tr>
<%}%>
</table>
		
		<br>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
				<td height="18" colspan="2">Add: Other Fees</td>				  
				<td width="6%">&nbsp;</td>
				<td>&nbsp;</td>
				<td width="4%">&nbsp;</td>
				<td width="13%"  align="right">&nbsp;</td>
				<td width="14%">&nbsp;</td>
				</tr>
				<%
				
				for(int i = 0; i < vPayment.size(); i += 6){
					if(vPayment.elementAt(i + 1) == null){						
						if(vMiscFeeInfo == null)
							vMiscFeeInfo = new Vector();
						vMiscFeeInfo.addElement(vPayment.elementAt(i+3));
						vMiscFeeInfo.addElement(Math.abs(Float.parseFloat((String)vPayment.elementAt(i)))+"");
						vMiscFeeInfo.addElement(null);					
					}
				}
				
				if(bolAssessmentOnly){
					vPayment = new Vector();
					vAdjustment = new Vector();
				}
				
				
				fMiscFee = 0f;
				strPesoSign="P";
				for(int i = 0; i< vMiscFeeInfo.size(); i +=3){											
						fMiscFee += Float.parseFloat((String)vMiscFeeInfo.elementAt(i+1));
						if(i > 1)
							strPesoSign = "&nbsp;";
				%>
				<tr>		
				<td width="9%">&nbsp;</td>		
				  <td><%=(String)vMiscFeeInfo.elementAt(i)%></td>				   		
				  <td align="right"><%=strPesoSign%></td>
				  <td width="8%" align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
				  <td>&nbsp;</td>
				  <td align="right" class="thinborderBOTTOM">
				   <%if (i+3>=vMiscFeeInfo.size()){%>
					  <%=CommonUtil.formatFloat(fMiscFee ,true)%>
				  <%}else{%><%}%></td>
				  <td>&nbsp;</td>
				</tr>
				<%}%>
									
				<tr>
				<td height="18" colspan="2">TOTAL&nbsp; . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</td>
					<td>&nbsp;</td>
					<td class="thinborderTOP">&nbsp;</td>
					<td>&nbsp;</td>
					<td align="right">P <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee+dLateFineSPC,true)%></td>
						<td>&nbsp;</td>
				</tr>
		
				
	<%	
			strTemp =(String) CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee+dLateFineSPC,true);
			double dDebit = 0d;
			double dTotPayment = 0d;
			
			if(vPayment != null && vPayment.size() > 0){%>
			
			<tr>
				<td colspan="2">Less: Payments - </td>
				<td align="center">&nbsp;</td>
				<td align="right">&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			</tr>
			
			<%
			 boolean bolSkipChecking = false;
			for(int i = 0; i < vPayment.size(); i += 6){
				if(vPayment.elementAt(i + 1) == null){
					strErrMsg = (String)vPayment.elementAt(i + 3);
					
				}else
					strErrMsg = (String)vPayment.elementAt(i + 1);		
				
							
				if(vORTuitionPmt.indexOf(strErrMsg) == -1)
					continue;
					
				if(WI.getStrValue(vPayment.elementAt(i + 4)).equals("-1"))
					continue;
			
				dDebit = Double.parseDouble((String)vPayment.elementAt(i));
				dTotPayment += dDebit;
				
				 
				if(i>1)
					strPesoSign = "&nbsp;";
	%>
			<tr>  
				<td>&nbsp;</td>
				<td style="padding-left:60px;">
					<%=strErrMsg%>
					&nbsp;&nbsp;
					<%=ConversionTable.convertMMDDYYYY((java.util.Date)vPayment.elementAt(i + 2))%>			
				</td>					
				<td colspan="2" align="right">&nbsp;</td>
				<td align="right"><%=strPesoSign%></td>
				<td align="right"><%=WI.getStrValue(CommonUtil.formatFloat((float)dDebit,true),"")%></td>
				<td>&nbsp;</td>
			</tr>
           
		<%}
		}//if(vPayment != null && vPayment.size() > 0)
		
		

		
		if(vAdjustment != null && vAdjustment.size() > 1){
				for(int i = 1; i < vAdjustment.size(); i += 7) {			
					dDebit = Double.parseDouble((String)vAdjustment.elementAt(i + 1));
					//dBalance -= dDebit;
		%>
					  <tr>
					  <td>&nbsp;</td>
						<td width="46%"><%=(String)vAdjustment.elementAt(i)%></td>						
						<td align="right">&nbsp;</td>
						<td align="right" class="thinborderBOTTOM" valign="bottom">&nbsp;<%=CommonUtil.formatFloat((float)dDebit,true)%></td>
						<td>&nbsp;</td>
						<td align="right" style="padding-left:10px;" class="thinborderBOTTOM" valign="bottom"><%=strTemp%></td>
						<td>&nbsp;</td>
					  </tr>
			<%}//end of for loop			
			} // end of vAdjustment !=null && vAdjustment.size()>1
			
			if( (vPayment != null && vPayment.size() > 0) || (vAdjustment !=null && vAdjustment.size()>1)){
			%>	
				
			<tr>
				<td colspan="4">Balance&nbsp; . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</td>
				<td align="right">&nbsp;</td>
				<td align="right" class="thinborderBOTTOM">
				<%=CommonUtil.formatFloat((fTutionFee+fCompLabFee+fMiscFee)-(float)dTotPayment,true)%></td>
				<td>&nbsp;</td>
			</tr>
			<%}%>
	
	
			</table>
		<%	
			if (((String)vStudInfo.elementAt(13)).toLowerCase().equals("female")) {
			        strGender="MISS";
					strHisHer = "Her";
					strHimHer = "Her";
			} else {
			        strGender ="MR";
					strHisHer = "His";
					strHimHer = "Him";
			}%>
          <p  style="text-align:justify"> 
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  This certification is being issued upon request of <%=strGender%> <%=(String)vStudInfo.elementAt(1)%> 
		  this <%=WI.getTodaysDate(6)%>
		  at Davao City, Philippines for whatever legal purpose it may serve <%=strHimHer.toLowerCase()%>.<br>
          <br><br>
        <table width="100%" border="0"  cellpadding="0" cellspacing="0">
          <tr><td></td>
		  <td></td>
		  <td align="left">CERTIFIED CORRECT:</td></tr>
	<tr>
		<td width="22%" height="54" align="center"><font size="1">not valid w/o<br>school seal</font></td>
		<td width="39%" >&nbsp;</td>
		<td width="39%" align="center"> <%=WI.getStrValue(WI.fillTextValue("comptroller_name")).toUpperCase()%><br>Comptroller</td>
	</tr>
        </table>
        
      </td>
      <td width="5%">&nbsp;</td>
    </tr>
   </table>
<%}//end of vStudInfo != null && vStudInfo.size()>0%>
</body>
</html>
<%
dbOP.cleanUP();
%>