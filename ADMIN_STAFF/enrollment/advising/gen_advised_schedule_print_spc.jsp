<%
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

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

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
	
	TD.thinborderALL {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }


    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
	
	TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
	
	TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
	
	TD.dotborderTOP {
    border-top: dotted 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
	
	TD.dotborderTOPBOTTOMLEFT {
    border-top: dotted 1px #000000;
	border-bottom: dotted 1px #000000;
	border-left: dotted 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
	
	TD.dotborderTOPBOTTOM {
    border-top: dotted 1px #000000;
    border-bottom: dotted 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
	
	TD.dotborderBOTTOM {
    border-bottom: dotted 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

</style>
</head>

<body >
<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.CurriculumMaintenance,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strPrintedBy = null;
	String strCollegeName = null;
	String[] astrSchYrInfo = {null,null,null};
	boolean bolFatalErr = false;
	String strErrMsg = null;
	String strTemp = null;
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

//get here the list of advised subjects.
Advising advising = new Advising();
Vector vAdvisedList = new Vector();
Vector vStudInfo    = new Vector();
Vector vTemp = null;

double dLateFineSPC     = 0d;//hard coded to FINES - LATE ENROLMENT

int iIndexOf = 0;

String strMaxAllowedLoad = null;
String strOverLoadDetail = null;
String strIsTempStud = null;

//get it from na_old_stud/new application.. 
String strSectionName = null;


String strStudIndex = null;
String strStudID	= WI.fillTextValue("stud_id");
if(strStudID.length() ==0)
	strStudID = WI.fillTextValue("temp_id");
if(strStudID.length() == 0)
{
	strErrMsg = "Student ID can't be empty.";
	bolFatalErr = true;
}
//get student information first.
if(!bolFatalErr)
{
	vStudInfo = advising.getStudInfo(dbOP,strStudID);
	if(vStudInfo == null)
	{
		strErrMsg = advising.getErrMsg();
		bolFatalErr = true;
	}
}
if(!bolFatalErr)
{
	astrSchYrInfo[0]=(String)vStudInfo.elementAt(16);//take sy from/to/sem from student registration information.
	astrSchYrInfo[1]=(String)vStudInfo.elementAt(17);
	astrSchYrInfo[2]=(String)vStudInfo.elementAt(18);
	strStudIndex = (String)vStudInfo.elementAt(0);
	strIsTempStud = (String)vStudInfo.elementAt(10);
}

//get the student's advised schedule information.
if(!bolFatalErr)
{
	vAdvisedList = advising.getAdvisedList(dbOP, strStudIndex,strIsTempStud,(String)vStudInfo.elementAt(2),
						astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
	if(vAdvisedList == null)
	{
		strErrMsg = advising.getErrMsg();
		bolFatalErr = true;
	}

}


if(!bolFatalErr)
{
	strCollegeName = new CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(2));
	
	strPrintedBy = (String)request.getSession(false).getAttribute("userIndex");
	if(strPrintedBy != null) {
		strPrintedBy = "select fname from user_table where user_index = "+strPrintedBy;
		strPrintedBy = dbOP.getResultOfAQuery(strPrintedBy, 0).toLowerCase();
	}


	Vector vMaxLoadDetail = advising.getMaxAllowedUnit(dbOP,strStudID,(String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),
			astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2],(String)vStudInfo.elementAt(4),
			(String)vStudInfo.elementAt(5));
	if(vMaxLoadDetail == null)
	{
		bolFatalErr = true;
		strErrMsg = advising.getErrMsg();
	}
	else
	{
		strMaxAllowedLoad = (String)vMaxLoadDetail.elementAt(0);
		if(vMaxLoadDetail.size() > 1)
			strOverLoadDetail = "Maximum load in curriculum for this sem "+(String)vMaxLoadDetail.elementAt(1)+
			" overloaded load "+(String)vMaxLoadDetail.elementAt(0)+" (approved on :"+(String)vMaxLoadDetail.elementAt(2)+")";
		if(strMaxAllowedLoad.compareTo("-1") ==0)
			strMaxAllowedLoad = "N/A";
	}
}
//dbOP.cleanUP();

//get details.
Vector vMiscFeeInfo = null;
float fMiscFee   = 0f; float fCompLabFee         = 0f; float fOutstanding = 0f;float fMiscOtherFee = 0f;
float fTutionFee = 0f; float fEnrollmentDiscount = 0f;
String strEnrolmentDiscDetail = null;
	enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
	enrollment.FAFeeOptional fOptional = new enrollment.FAFeeOptional();

double dReqdDP = 0d;/// show for UC> 
double dTotalDiscount = 0d;// scholarship/discounts applied.. 
String strSQLQuery    = null;
java.sql.ResultSet rs = null;

	enrollment.FAPaymentUtil paymentUtil = new enrollment.FAPaymentUtil();

if(!bolFatalErr && vStudInfo != null) {
	request.setAttribute("sy_from",astrSchYrInfo[0]);
	request.setAttribute("sy_to",astrSchYrInfo[1]);
	request.setAttribute("semester",astrSchYrInfo[2]);
	Vector vOthSetting = fOptional.operateOnAddlAssessementSetting(dbOP, request, 7);

	paymentUtil.setTempUser((String)vStudInfo.elementAt(10));
	vMiscFeeInfo = paymentUtil.getMiscFeeDetail(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(2),
		        (String)vStudInfo.elementAt(3),(String)vStudInfo.elementAt(6), astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);

	if(vMiscFeeInfo == null)
		strErrMsg = paymentUtil.getErrMsg();
	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),	astrSchYrInfo[0],astrSchYrInfo[1],
					(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
	if(fTutionFee > 0)
	{
		enrollment.FAStudMinReqDP faMinDP = new enrollment.FAStudMinReqDP(null);
		dReqdDP = faMinDP.getPayableDownPayment(dbOP, request.getParameter("stud_id"), astrSchYrInfo[0], astrSchYrInfo[1],astrSchYrInfo[2], strSchoolCode, 1, 
							(String)vStudInfo.elementAt(0), paymentUtil.isTempStud(), (String)vStudInfo.elementAt(2), 
							(String)vStudInfo.elementAt(3), (String)vStudInfo.elementAt(6));


		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
		fOperation.checkIsEnrolling(dbOP,(String)vStudInfo.elementAt(0),
							astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
		fOutstanding= fOperation.calOutStandingOfPrevYearSemEnrolling(dbOP, (String)vStudInfo.elementAt(0));

		fMiscOtherFee = fOperation.getMiscOtherFee();
		
		//check here if tehre are grants.. 
		strSQLQuery = "select fa_fa_index from FA_STUD_PMT_ADJUSTMENT where user_index = "+(String)vStudInfo.elementAt(0)+" and sy_from = "+astrSchYrInfo[0]+
						" and semester = "+	astrSchYrInfo[2];
		if(paymentUtil.isTempStud())
			strSQLQuery += " and is_valid = 0 and is_del = 0";
		else
			strSQLQuery +=" and is_valid = 1";//System.out.println(strSQLQuery);
			
		rs = dbOP.executeQuery(strSQLQuery);
		Vector vDiscountApplied = new Vector();
		while(rs.next())
			vDiscountApplied.addElement(rs.getString(1));
		rs.close();
		while(vDiscountApplied.size() > 0) {
			dTotalDiscount += fOperation.calAdjustmentRebate(dbOP,(String)vStudInfo.elementAt(0),astrSchYrInfo[0],astrSchYrInfo[1],
		       				(String)vStudInfo.elementAt(6),astrSchYrInfo[2],(String)vDiscountApplied.remove(0), false, paymentUtil.isTempStud(), false);
		}
		if(dTotalDiscount > 0d) 
			dTotalDiscount = Double.parseDouble(ConversionTable.replaceString(CommonUtil.formatFloat(dTotalDiscount, true), ",",""));
		
		enrollment.FAFeeOperationDiscountEnrollment fafeeDisc = new enrollment.FAFeeOperationDiscountEnrollment();
		if(fafeeDisc.isLateFeeApplicable(dbOP,astrSchYrInfo[0],astrSchYrInfo[2],WI.getTodaysDate(1), strSchoolCode)) {
			dLateFineSPC = fafeeDisc.getFineAmtSPC();
		}

		
		vTemp = paymentUtil.getMiscFeeDetailForHandsOnNotComputer(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
				astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
		if(vTemp == null)
			strErrMsg = paymentUtil.getErrMsg();
		else if(vMiscFeeInfo != null) {
			vMiscFeeInfo.addAll(vTemp);
			if(fOperation.vMultipleOCMapInfo != null && fOperation.vMultipleOCMapInfo.size() > 0) 
				vMiscFeeInfo.addAll(fOperation.vMultipleOCMapInfo);
		}
		
		if(vOthSetting != null && ((String)vOthSetting.elementAt(1)).compareTo("0") == 0){//full payment.
			enrollment.FAFeeOperationDiscountEnrollment test =
					new enrollment.FAFeeOperationDiscountEnrollment(paymentUtil.isTempStud(),WI.getTodaysDate(1));
			vTemp = test.calEnrollmentDateDiscount(dbOP, fTutionFee,fTutionFee+fMiscFee+fCompLabFee,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
						astrSchYrInfo[0],astrSchYrInfo[1],
											(String)vStudInfo.elementAt(6),astrSchYrInfo[2],
											fOperation.dReqSubAmt);
			if(vTemp != null && vTemp.size() > 0)
				strEnrolmentDiscDetail = (String)vTemp.elementAt(0);//System.out.println(vTemp);//System.out.println(strEnrolmentDiscDetail);
			if(strEnrolmentDiscDetail != null && vTemp != null && vTemp.size() > 0) {
				fEnrollmentDiscount = ((Float)vTemp.elementAt(1)).floatValue();
			}
		}
	}
}

boolean bolShowFeeDetail = false;
boolean bolShowLabFee    = false;//for PWC only. 

//if(	strSchoolCode.startsWith("AUF") || strSchoolCode.startsWith("CLDH") || strSchoolCode.startsWith("CPU")    || 
//	strSchoolCode.startsWith("UDMC")|| strSchoolCode.startsWith("CGH")  || strSchoolCode.startsWith("CSAB")   || 
//	strSchoolCode.startsWith("WNU") || strSchoolCode.startsWith("UL")   || strSchoolCode.startsWith("PHILCST")|| 
//	strSchoolCode.startsWith("DBTC")|| strSchoolCode.startsWith("PIT")  || strSchoolCode.startsWith("FATIMA") ||
//	strSchoolCode.startsWith("EAC") || strSchoolCode.startsWith("UC")   || strSchoolCode.startsWith("WUP")    || 
//	strSchoolCode.startsWith("UPH") || strSchoolCode.startsWith("PWC")	|| strSchoolCode.startsWith("SPC"))
//		bolShowFeeDetail = true;



/**
System.out.println(fMiscFee);
System.out.println(fMiscOtherFee);
System.out.println(vMiscFeeInfo);
System.out.println(fEnrollmentDiscount);
System.out.println(strEnrolmentDiscDetail);
**/
//I have added this to get the round off value for AUF.. 
double dDiff = 0d;
double dRoundOf = 0d;
double[] dTemp = null;

Vector vSection = new Vector();//sections.
/**
* added to get hours enrolled/per hour computation
*/
double dTotalUnitsCharged = 0d;
Vector vSubjectPerHour = new Vector();
double dHoursCharged   = 0d;
double dUnitsExcluded  = 0d; double dUnitsSubNoFee = 0d;
/********* done *******/

Vector vSubExcluded = new Vector();

if(!bolFatalErr && vStudInfo != null) {

	///get here section name. 
	if(strIsTempStud.equals("1")) {
		strSQLQuery = "select section_name_ from new_application where application_index = "+(String)vStudInfo.elementAt(0);
		strSectionName = dbOP.getResultOfAQuery(strSQLQuery, 0);		
	}
	else{
		strSQLQuery = "select section_name_ from na_old_stud where user_index = "+(String)vStudInfo.elementAt(0)+
		" and sy_from = "+astrSchYrInfo[0]+" and semester = "+astrSchYrInfo[2]+" and is_valid = 1";
		strSectionName = dbOP.getResultOfAQuery(strSQLQuery, 0);		
	}




	String strCourseIndex = null;
	String strMajorIndex  = null;
	String strYearLevel   = null;
	
	strSQLQuery = "select sub_code, max_hour from fa_tution_fee "+
	"join fa_schyr on (fa_schyr.sy_index = fa_tution_fee.sy_index) "+
	"join subject on (subject.sub_index = fa_tution_fee.sub_index) "+
	" join ( "+
 	"       select max(hour_lec + hour_lab) as max_hour, sub_index as si from curriculum "+
	"       where is_valid = 1 group by sub_index) as dt_cur on dt_cur.si = fa_tution_fee.sub_index "+
	" where (compute_per_hour = 1 or fee_type_catg = 4) and (semester is null or semester = "+astrSchYrInfo[2]+
	") and sy_from = "+astrSchYrInfo[0]+" and fa_tution_fee.is_Valid = 1";
	
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vSubjectPerHour.addElement(rs.getString(1));
		vSubjectPerHour.addElement(new Double(rs.getDouble(2)));
	}
	rs.close();
	strSQLQuery = "select sub_code from subject join FA_SUB_NOFEE on (FA_SUB_NOFEE.SUB_INDEX = subject.SUB_INDEX) "+
					"where FA_SUB_NOFEE.IS_DEL = 0 and SY_FROM = "+astrSchYrInfo[0]+" and SEMESTER = "+astrSchYrInfo[2];
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vSubExcluded.addElement(rs.getString(1));
	}
	rs.close();

}

if(bolFatalErr){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" align="center"><%=strErrMsg%></td>
    </tr>
  </table>
<%
  dbOP.cleanUP();
  return;
}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
<%
if(strSchoolCode.startsWith("LNU")){%>
    <tr>
      <td height="7" colspan="7" align="left">L-NU REG # 100</td>
    </tr>
<%}%>
    <tr>
      <td height="25" colspan="7"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
		  OFFICIAL REGISTRATION FORM         
          <br>        
        <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>, AY <%=astrSchYrInfo[0]%>-<%=astrSchYrInfo[1]%></div></td>
    </tr>   
  </table>
  
 <table width="100%" border="0" cellpadding="0" cellspacing="0">
 	<tr>
		<td height="17" width="10%">Student No. </td>
		<td width="65%"><strong>: <%=strStudID%></strong></td>
		<td width="7%">Status</td>
		<td width="18%"><strong>: <%=(String)vStudInfo.elementAt(11)%></strong></td>
	</tr>
	<tr>
		<td height="17">Name </td>
		<td><strong>: <%=(String)vStudInfo.elementAt(1)%></strong></td>
		<td>Section</td>
		<td><strong>: 
		<%if(strSectionName!= null) {%>
			<%=strSectionName%>
		<%}else{%>
			<label id="section_name"></label>
		<%}%>
		</strong></td>
	</tr>
	<tr>
		<td height="17">Course/Yr </td>
		<td><strong>: <%=(String)vStudInfo.elementAt(7)%><%=WI.getStrValue((String)vStudInfo.elementAt(8),"/","","")%>
		<%=WI.getStrValue((String)vStudInfo.elementAt(6)," - ","","N/A")%></strong></td>
		<td>Gender</td>
		<td><strong>: <%=(String)vStudInfo.elementAt(19)%></strong></td>
	</tr>
	<tr><td colspan="4" height="12"></td></tr>
 </table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
		<td width="16%" height="18" class="thinborderTOPBOTTOM">Schedule Code</td>
		<td width="36%" class="thinborderTOPBOTTOM">Description</td>
		<td width="5%" align="center" class="thinborderTOPBOTTOM">Unit</td>
		<td width="15%" align="center" class="thinborderTOPBOTTOM">Time</td>
		<td width="7%" class="thinborderTOPBOTTOM">Day</td>
		<td width="8%" class="thinborderTOPBOTTOM">Room</td>
		<td width="13%" class="thinborderTOPBOTTOM">Section Code</td>
  </tr>
  <%
//double dHoursCharged   = 0d;
//double dUnitsExcluded  = 0d;

for(int i = 1; i<vAdvisedList.size(); ++i){
	iIndexOf = vSubjectPerHour.indexOf(vAdvisedList.elementAt(i));
	if(iIndexOf > -1) {//compute per hour
		dUnitsExcluded += Double.parseDouble((String)vAdvisedList.elementAt(i + 9));
		dHoursCharged  += ((Double)vSubjectPerHour.elementAt(iIndexOf + 1)).doubleValue();
	}
	//System.out.println("dUnitsExcluded :"+dUnitsExcluded);
	//System.out.println("dHoursCharged :"+dHoursCharged);
	strTemp = (String)vAdvisedList.elementAt(i);
	if(strTemp.indexOf("NSTP") != -1){
	  iIndexOf = strTemp.indexOf("(");
	  if(iIndexOf != -1){
		strTemp = strTemp.substring(0,iIndexOf);
		strTemp = strTemp.trim();
	  }
	}
	if(vSubExcluded.indexOf(strTemp) > -1) {
		dUnitsSubNoFee += Double.parseDouble((String)vAdvisedList.elementAt(i + 9));
	}
%>
  <tr>
    <td height="16" class="thinborderBOTTOM"><%=(String)vAdvisedList.elementAt(i)%></td>
    <td class="thinborderBOTTOM"><%=(String)vAdvisedList.elementAt(i+1)%></td>
    <td class="thinborderBOTTOM" align="center"><%=(String)vAdvisedList.elementAt(i+9)%></td>
	
<%
String strTime = null;
String strDay = null;
strErrMsg = (String)vAdvisedList.elementAt(i + 2);
vTemp = new Vector();
if(strErrMsg != null) {
	vTemp = CommonUtil.convertCSVToVector(strErrMsg, "<br>",true);			
	while(vTemp.size() > 0) {
		strTemp = (String)vTemp.remove(0);
		iIndexOf = strTemp.indexOf(" ");
		if(iIndexOf > -1){
			if(strTime == null)
				strTime = strTemp.substring(iIndexOf + 1).toLowerCase();
			else
				strTime += "<br>"+strTemp.substring(iIndexOf + 1).toLowerCase();
			
			if(strDay == null)
				strDay = strTemp.substring(0, iIndexOf);
			else
				strDay += "<br>"+strTemp.substring(0, iIndexOf);
		}				
	}
}



%>	
	
    <td class="thinborderBOTTOM"><%=WI.getStrValue(strTime,"TBA")%></td>
    <td class="thinborderBOTTOM"><%=WI.getStrValue(strDay,"TBA")%></td>
	<td class="thinborderBOTTOM"><%=WI.getStrValue((String)vAdvisedList.elementAt(i+4),"TBA")%></td>
	<td class="thinborderBOTTOM">&nbsp;<%=WI.getStrValue((String)vAdvisedList.elementAt(i+3),"TBA")%></td>
  </tr>
  <%
if(WI.getStrValue((String)vAdvisedList.elementAt(i+3)).length() > 0) {
	iIndexOf = vSection.indexOf(WI.getStrValue((String)vAdvisedList.elementAt(i+3)));
	if(iIndexOf == -1) {
		vSection.addElement(vAdvisedList.elementAt(i+3));
		vSection.addElement("1");
	}
	else {
		vSection.setElementAt(Integer.toString(Integer.parseInt((String)vSection.elementAt(iIndexOf + 1)) + 1), iIndexOf + 1);
	}
}
i = i+10;
}

//set the section name here.
int iCount = 0;
for(int i = 0; i < vSection.size(); i += 2) {
	if(iCount < Integer.parseInt((String)vSection.elementAt(i + 1)))
		iCount = Integer.parseInt((String)vSection.elementAt(i + 1));	
}
iIndexOf = vSection.indexOf(Integer.toString(iCount));
if(iIndexOf > 0) {%>
<script>
	var objSection = document.getElementById('section_name');
	if(objSection)
		objSection.innerHTML = '<%=vSection.elementAt(iIndexOf - 1)%>';
</script>
<%}%>

<tr>
	<td colspan="2" align="right"><strong>Total Unit &nbsp; &nbsp; &nbsp;</strong></td>
	<td class="thinborderBOTTOM" align="center"><strong><%=(String)vAdvisedList.elementAt(0)%></strong></td>
</tr>
<tr><td height="10"></td></tr>
</table>



<%
if(vMiscFeeInfo == null)
	vMiscFeeInfo = new Vector();
%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td height="18" width="70%" align="center" class="dotborderTOPBOTTOM">STUDENT ASSESSMENT</td>
		<td width="30%" align="center" class="dotborderTOPBOTTOMLEFT">PAYMENT SCHEDULE</td>
	</tr>
	<tr>
		<td valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="dotborderBOTTOM" width="48%" height="18" style="padding-left:40px;">School Fee</td>
					<td class="dotborderBOTTOM" width="8%">Units</td>
					<td class="dotborderBOTTOM" width="9%">Hrs</td>
					<td class="dotborderBOTTOM" width="11%" align="right">Rate</td>
					<td class="dotborderBOTTOM" width="20%" align="right">Amount</td>
					<td class="dotborderBOTTOM" width="4%">&nbsp;</td>
				</tr>
				
<%
double dUnitsTaken = Double.parseDouble((String)vAdvisedList.elementAt(0)) - dUnitsSubNoFee;
if(dHoursCharged == 0d) {%>
				<tr>				 
				  <td height="18">Tuition Fee</td>
				  <td><%=dUnitsTaken%></td>
				  <td>&nbsp;</td>
				  <td align="right"><%if(dUnitsTaken == 0d) {%> 0.00<%}else{%><%=CommonUtil.formatFloat(((double)fTutionFee / dUnitsTaken) ,true)%><%}%></td>
				  <td align="right"><strong><%if(dUnitsTaken == 0d) {%> 0.00<%}else{%><%=CommonUtil.formatFloat(fTutionFee,true)%><%}%></strong></td>				 
				</tr>
<%}else{
double dUnitsCharged = dUnitsTaken - dUnitsExcluded;
double dUnitRate = fTutionFee / (dUnitsCharged + dHoursCharged) ;
if(dUnitsCharged > 0d) {
%>
				<tr>				 
				  <td height="18">Tuition Fee</td>
				  <td><%=dUnitsCharged%></td>
				  <td>&nbsp;</td>
				  <td align="right"><%=CommonUtil.formatFloat(dUnitRate ,true)%></td>
				  <td align="right"><strong><%=CommonUtil.formatFloat(dUnitRate *dUnitsCharged ,true)%></strong></td>				 
				</tr>
<%}%>
				<tr>				 
				  <td height="18">Tuition Fee w/Lab</td>
				  <td><%=dUnitsExcluded%></td>
				  <td><%=dHoursCharged%></td>
				  <td align="right"><%=CommonUtil.formatFloat(dUnitRate ,true)%></td>
				  <td align="right"><strong><%=CommonUtil.formatFloat(dUnitRate *dHoursCharged ,true)%></strong></td>				 
				</tr>



<%}if(fCompLabFee > 0f){%>
					<tr>					  
					  <td height="18">Computer Lab Fee.</td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td><td>&nbsp;</td>
					  <td align="right"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></td>
					  
					</tr>
<%}%>
<%
for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
	if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("0") ==0)
		continue;
%>
				<tr>				
				  <td>&nbsp;&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
				  <td align="right">&nbsp;<strong></strong></td>
				  
				</tr>
<%vMiscFeeInfo.remove(i);vMiscFeeInfo.remove(i);vMiscFeeInfo.remove(i); i = i - 3;//I have to remove the OC, 
}%>
				<tr>				  
				  <td height="18" colspan="2">Miscellaneous and Other Fees</td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				</tr>
				<%
				for(int i = 0; i< vMiscFeeInfo.size(); i +=3){
					if( ((String)vMiscFeeInfo.elementAt(i + 2)).compareTo("1") ==0)
						continue;
				%>
				<tr>				
				  <td>&nbsp;&nbsp;&nbsp;<%=(String)vMiscFeeInfo.elementAt(i)%></td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td align="right"><%=CommonUtil.formatFloat((String)vMiscFeeInfo.elementAt(i+1),true)%></td>
				  <%
				  strTemp = "";
				  if(i + 3 >= vMiscFeeInfo.size())
				  	strTemp = CommonUtil.formatFloat(fMiscFee + dLateFineSPC,true);
				  %>
				  <td align="right">&nbsp;<strong><%if(dLateFineSPC == 0d){%><%=strTemp%><%}%></strong></td>
				  
				</tr>
				<%}%>
				<%if(dLateFineSPC > 0d){%>
				<tr>				
				  <td>&nbsp;&nbsp;&nbsp;Late Enrollment Fine</td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td align="right"><%=CommonUtil.formatFloat(dLateFineSPC,true)%></td>
				  <td align="right">&nbsp;<strong><%=strTemp%></strong></td>
				  
				</tr>
				<%}%>
				<tr>
					<td height="18">TOTAL FEES</td>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
					<td style="padding-left:10px;" align="right"><div style="border-top:solid 2px #000000;"><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee+dLateFineSPC,true)%></div></td>
					<td align="right" style="padding-left:10px;"><div style="border-top:solid 2px #000000; border-bottom:solid 2px #000000; font-weight:bold;">
						<%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee+dLateFineSPC,true)%></div></td>
				</tr>
			</table>
		</td>
		
		<td valign="top" align="center" style="border-left:dotted 1px #000000;">
			<table width="90%" border="0" align="center" cellspacing="0" cellpadding="0">				
			<tr>
			<td height="30px" style="font-weight:bold"><%if(dTotalDiscount > 0d){%>Scholarship/Grant: <%}%>
			</td>
				<td align="right" style="font-weight:bold"><%if(dTotalDiscount > 0d){%><%=CommonUtil.formatFloat(dTotalDiscount, true)%><%}%></td>
			</tr>
		<%
		double dTotalPayable = fTutionFee+fCompLabFee+fMiscFee - dTotalDiscount;
		
		dReqdDP = 0d;
		
		//fOutstanding = 100f;//System.out.println("dTotalPayable -- 2: "+dTotalPayable);
		Vector vPmtSchInfo = new enrollment.FAPmtMaintenance().getAllowedPmtSchedue(dbOP, strStudIndex,astrSchYrInfo[0],astrSchYrInfo[2],
							true, paymentUtil.isTempStud());
		enrollment.FAAssessment FA = new enrollment.FAAssessment();
		int iNoOfInstallment = 0;
		if(vPmtSchInfo != null) {
			
			iNoOfInstallment = vPmtSchInfo.size()/ 3 + 1;//System.out.println(vPmtSchInfo);
			
			dTotalPayable    = dTotalPayable/iNoOfInstallment;
			dTemp = FA.convertDoubleToNearestInt("SPC", dTotalPayable);//AUF code will give me the rounded value
			if(dTemp != null) {
				dTotalPayable = dTemp[0];
				dReqdDP = dTemp[0];
				
				dDiff = dTemp[1] * iNoOfInstallment;
			}
			strErrMsg = CommonUtil.formatFloat(dTotalPayable,true);
			
		}//System.out.println("dReqdDP -- 3: "+dReqdDP);System.out.println("dTotalPayable -- 3: "+dTotalPayable);
		if(iNoOfInstallment > 0){
			if(fOutstanding != 0f || dLateFineSPC > 0d) {
				dReqdDP += (double)fOutstanding+dLateFineSPC;//System.out.println("dReqdDP -- 4: "+dReqdDP);
				if(fOutstanding != 0f){%>
				<tr>
				  <td height="16">Old Account</td>
				  <td align="right"><%=CommonUtil.formatFloat(fOutstanding, true)%></td>
			  </tr>
			<%}
			}%>
				<tr>
				  <td width="51%" height="16">Downpayment</td>
				  <td width="49%" align="right"><%=strErrMsg%></td>
				</tr>
		<%for(int i = 0; i < vPmtSchInfo.size(); i += 3){
			//if last then i have to get the total payable + diff.
			if((i + 4) > vPmtSchInfo.size()) {
				strErrMsg = CommonUtil.formatFloat(dTotalPayable + dDiff,true);
				
			}%>
				<tr>
				  <td height="16"><%=((String)vPmtSchInfo.elementAt(i + 1)).toUpperCase()%></td>
				   <td width="49%" height="18" align="right"><%=strErrMsg%></td>
				</tr>
		<%}
		}%>
			<tr>
				<td height="18">TOTAL BALANCE:</td>
				<td align="right" style="border-top:solid 2px #000000;"><strong><%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee+fOutstanding - dTotalDiscount+dLateFineSPC,true)%></strong></td>
			</tr>
		  </table>
			 <%if(fOutstanding != 0f) {
			 	if(dReqdDP < 0d)
					dReqdDP = 0d;
			  %>

					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<tr><td height="30" style="font-size:14px; font-weight:bold">Required Downpayment: <%=CommonUtil.formatFloat(dReqdDP, true)%></td></tr>
					</table>
			 <%}			
				
				strTemp = null;
				strSQLQuery = "select SPECIFIC_DATE, amount, fee_type from FA_FEE_ADJ_ENROLLMENT  where sy_from = "+astrSchYrInfo[0]+
										" and semester = "+astrSchYrInfo[2]+"  and ADJ_PARAMETER = 0 and is_valid = 1 and specific_date is not null and specific_date >='"+
										WI.getTodaysDate()+"'";
				if(dTotalDiscount == 0d) {
					rs = dbOP.executeQuery(strSQLQuery);
					if(rs.next()) {
						double dDisAmt = (double)fTutionFee * rs.getDouble(2)/100d;	
						dTotalPayable = (fTutionFee+fCompLabFee+fMiscFee) - dDisAmt - dTotalDiscount;
	//					dTotalPayable = fTutionFee+fCompLabFee+fMiscFee - dDisAmt;
						
						strTemp = CommonUtil.formatFloat(dTotalPayable,true)+"<br>("+
							rs.getDouble(2)+"% tuition fee discount - "+CommonUtil.formatFloat(dDisAmt, true)+")";
					}
					rs.close();
				}
				if(strTemp != null) {%>
					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<tr><td height="30">&nbsp;</td></tr>
						<tr>
							<td align="center">Full payment upon enrollment &nbsp; &nbsp; &nbsp;<%=strTemp%> </td>
						</tr>
					</table>
				<%}%>
		</td>
	</tr>
	
	<tr>
		<td valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td width="44%" height="18" class="thinborderBOTTOM">&nbsp;</td>
					<td width="8%">&nbsp;</td>
					<td width="48%">&nbsp;</td>
				</tr>				
				<tr>
					<td align="center" height="18">1. Cashier's Signature</td>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
				</tr>
			</table>
		</td>
		<td valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>					
					<td width="10%">&nbsp;</td>
					<td width="" height="18" class="thinborderBOTTOM">&nbsp;</td>
					<td width="10%">&nbsp;</td>
				</tr>
				<tr>					
					<td>&nbsp;</td>
					<td width="" align="center" height="18">Student's Signature</td>
					<td>&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td height="40" colspan="3" class="thinborderBOTTOM">&nbsp;</td>
		<td width="5%"></td>
		<td width="21%" class="thinborderBOTTOM">&nbsp;</td>
		<td width="43%" rowspan="6" class="thinborderALL" style="font-size:10px; padding:10px;">
			NOTE:<br>
				&nbsp; &nbsp;>Please follow order of signature.<br>
				&nbsp; &nbsp;>Keep posted of your schedule of classes at PL 3rd floor lobby.<br>
				&nbsp; &nbsp;>For activation of you Internet Account, kindly proceed to PL-311.<br>
				&nbsp; &nbsp;>Please present this ORF during the first day of class to your instructor<br>				
				&nbsp; &nbsp;>SPC is charging SY 2012-2013 approved rates. <br>
				&nbsp; &nbsp;>Adjustment will be made when decision from CHED on applied increased in Tuition and Other Fees will be received.
				
		</td>
	</tr>
	<tr>
		<td height="17" colspan="3" align="center">2. Registrar's Signature</td>
		<td></td>
		<td align="center">3. OSA's Signature</td>		
	</tr>
	
	<tr>
		<td colspan="5" height="30">&nbsp;</td>
	</tr>
	<tr>
		<td width="15%">Printed by:</td>
		<td width="3%">&nbsp;</td>
	  <td colspan="3"><%=strPrintedBy%></td>
	</tr>
	<tr>
		<td>Print Date:</td>
		<td>&nbsp;</td>
		<td colspan="3"><%=WI.getTodaysDateTime()%></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
</table>








<%
if(WI.fillTextValue("print").compareTo("0") !=0){%>
<script language="javascript">
window.print();
</script>
<%}//incase only view
%>
</body>
</html>
<%
dbOP.cleanUP();
%>
