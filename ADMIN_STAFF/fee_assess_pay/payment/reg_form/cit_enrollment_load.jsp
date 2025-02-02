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

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";
if(strSchoolCode.startsWith("CNU"))
	strSchoolCode = "CLDH";
//if(strSchoolCode.startsWith("CSAB"))
//	strSchoolCode = "FATIMA";


	
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

String strMaxAllowedLoad = null;
String strOverLoadDetail = null;
String strIsTempStud = null;

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
	strPrintedBy   = CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1);
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



	enrollment.FAPaymentUtil paymentUtil = new enrollment.FAPaymentUtil();

if(!bolFatalErr && vStudInfo != null) {
	enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
	enrollment.FAFeeOptional fOptional = new enrollment.FAFeeOptional();
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
		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
					astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2]);
		fOperation.checkIsEnrolling(dbOP,(String)vStudInfo.elementAt(0),
							astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
		fOutstanding= fOperation.calOutStandingOfPrevYearSemEnrolling(dbOP, (String)vStudInfo.elementAt(0));

		fMiscOtherFee = fOperation.getMiscOtherFee();
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


//if not ETO.
//boolean bolIsETO = new enrollment.SetParameter().bolIsETO(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
//if(!strSchoolCode.startsWith("CIT") && !bolIsETO) {
	

//}

//I must set is_advised to true, if already advised.
if(!bolFatalErr && vStudInfo != null) {
	strTemp = "update CIT_ALLOW_SECOND_ADVISING set is_used = 1 where sy_from = "+astrSchYrInfo[0]+" and sem = "+astrSchYrInfo[2]+
        " and stud_index = "+strStudIndex+" and is_temp_stud = "+strIsTempStud; 
	dbOP.executeUpdateWithTrans(strTemp, null, null, false);
}	
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

<%if(!strSchoolCode.startsWith("AUF")){%>
    TABLE.thinborder {
   	/**
	border-top: solid 1px #000000;
   	border-right: solid 1px #000000;
	**/
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

    TD.thinborder {
    /**
	border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinBorderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinBorderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

<%}%>
-->
</style>
</head>

<body onLoad="window.print();" leftmargin="55">
<%if(bolFatalErr){%>
  <table width="90%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="18" align="center"><%=strErrMsg%></td>
    </tr>
  </table>
<%
  dbOP.cleanUP();
  return;
}%>
  <table width="90%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="50%">SY/TERM: <strong><%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>, AY <%=astrSchYrInfo[0]%>-<%=astrSchYrInfo[1]%></strong></td>
      <td width="50%" height="18" align="right">Date and time printed:<%=WI.getTodaysDateTime()%>&nbsp; </td>
    </tr>
  </table>
<table width="90%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="18">Student ID : <strong><font size="2"><%=strStudID%></font></strong></td>
    <td width="57%" height="18">Course / Major : <strong><%=(String)vStudInfo.elementAt(22)%>
      <%if(vStudInfo.elementAt(23) != null){%>
      / <%=(String)vStudInfo.elementAt(23)%>
      <%}%>
      
	  <%=WI.getStrValue((String)vStudInfo.elementAt(6),"-","","")%>
	  </strong></td>
  </tr>
  <tr>
    <td height="18" colspan="2">Student name : <strong><font size="2"><%=(String)vStudInfo.elementAt(1)%></font></strong></td>
  </tr>
  <tr>
    <td width="43%" height="18">Student type : <strong><%=(String)vStudInfo.elementAt(11)%>
	<%if(strSchoolCode.startsWith("AUF")){%>
	/<%if(vStudInfo.elementAt(21).equals("0")){%>Regular<%}else{%>Irregular<%}%>
	<%}%>
	</strong></td>
    <td height="18">Curriculum Year : <strong><%=(String)vStudInfo.elementAt(4)%> - <%=(String)vStudInfo.elementAt(5)%></strong></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td height="18">&nbsp;</td>
  </tr>
</table>
<table width="70%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr>
    <td width="21%" height="18" class="thinBorderTOP"><strong>SUBJECT CODE</strong></td>
    <td width="53%" class="thinBorderTOP"><strong>SUBJECT TITLE </strong></td>
    <%if(!strSchoolCode.startsWith("AUF")){%>
	<%}%>
    <td width="6%" class="thinBorderTOP"><strong><font size="1">UNITS</font></strong></td>
    <td width="20%" class="thinBorderTOP"><strong>&nbsp;
	<%if(strSchoolCode.startsWith("CPU")){%>STUB CODE<%}else{%>SECTION<%}%> </strong></td>
  </tr>
  <%
for(int i = 1; i<vAdvisedList.size(); ++i)
{%>
  <tr>
    <td height="20" class="thinborder"><%=(String)vAdvisedList.elementAt(i)%></td>
    <td class="thinborder"><%=(String)vAdvisedList.elementAt(i+1)%></td>
<%if(!strSchoolCode.startsWith("AUF")){%>
    <%}%>
    <td class="thinborder" align="center"><%=(String)vAdvisedList.elementAt(i+9)%></td>
    <td class="thinborder">&nbsp;&nbsp;<%=WI.getStrValue((String)vAdvisedList.elementAt(i+3),"TBA")%></td>
  </tr>
  <%
i = i+10;
}%>
  <tr>
    <td colspan="4" class="thinBorderTOP">
	  <table width="90%" border="0" cellpadding="0" cellspacing="0">
	   <tr>
		 <td width="43%" height="18">Maximum allowable units: <strong><%=strMaxAllowedLoad%></strong></td>
		 <td width="57%">Total units enrolled: <strong><%=(String)vAdvisedList.elementAt(0)%></strong></td>
	   </tr>
     </table>

	</td>
  </tr>
  <tr>
    <td colspan="4">&nbsp;</td>
  </tr>
</table>

<%
if(vMiscFeeInfo == null)
	vMiscFeeInfo = new Vector();
%>
<table width="90%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="41%" valign="top"> 
<%if(false){%>
	
		<table width="90%" border="0" cellspacing="0" cellpadding="0">
        
        <tr>
          <td width="2%">&nbsp;</td>
          <td width="53%">Tuition Fee</td>
          <td width="34%" align="right"><strong><%=CommonUtil.formatFloat(fTutionFee,true)%></strong></td>
          <td width="11%">&nbsp;</td>
        </tr>
     <%if(strSchoolCode.startsWith("AUF")){%>
	    <tr>
          <td>&nbsp;</td>
          <td>Misc. Fee</td>
          <td align="right"><strong><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></strong></td>
          <td>&nbsp;</td>
	    </tr>
     <%}if(fCompLabFee > 0f){%>
	    <tr>
          <td>&nbsp;</td>
          <td>Computer Lab Fee.</td>
          <td align="right"><strong><%=CommonUtil.formatFloat(fCompLabFee,true)%></strong></td>
          <td>&nbsp;</td>
	    </tr>
	<%}%>
		<tr>
          <td>&nbsp;</td>
          <td>MiscFee</td>
          <td align="right"><strong><%=CommonUtil.formatFloat(fMiscFee - fMiscOtherFee,true)%></strong></td>
          <td>&nbsp;</td>
		</tr>
		<tr>
          <td>&nbsp;</td>
          <td>Other Charges </td>
          <td align="right"><strong><%=CommonUtil.formatFloat(fMiscOtherFee,true)%></strong></td>
          <td>&nbsp;</td>
		</tr>
    <%if(strEnrolmentDiscDetail != null){%>
        <tr>
          <td>&nbsp;</td>
          <td colspan="3"><%=strEnrolmentDiscDetail%></td>
        </tr>
    <%}
	if(fOutstanding > 0f && !strSchoolCode.startsWith("AUF")){%>
        <tr>
          <td>&nbsp;</td>
          <td><div align="left">OLD ACCOUNT</div></td>
          <td align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fOutstanding,true)%></strong></font></td>
          <td>&nbsp;</td>
        </tr>
    <%}%>
        <tr>
          <td>&nbsp;</td>
          <td><div align="right">Total Payable&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
          <td align="right"><font size="1"><strong>
		  <%if(strSchoolCode.startsWith("AUF")){%>
			  <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee - fEnrollmentDiscount,true)%>
		  <%}else{%>
			  <%=CommonUtil.formatFloat(fTutionFee+fCompLabFee+fMiscFee + fOutstanding - fEnrollmentDiscount,true)%>
		  <%}%>
		  </strong></font></td>
          <td>&nbsp;</td>
        </tr>
<%if(strSchoolCode.startsWith("AUF")){%>
        <tr>
          <td>&nbsp;</td>
          <td align="right">Old Account&nbsp;&nbsp;&nbsp;&nbsp;</td>
          <td align="right"><font size="1"><strong><%=CommonUtil.formatFloat(fOutstanding,true)%></strong></font></td>
          <td>&nbsp;</td>
        </tr>
<%}%>
    </table>
	
<%}%>
	</td>
    <td width="59%" valign="top"><br>
		<table class="thinborderALL" bgcolor="#DDDDDD"><tr><td>
      Please Pay at the accounting office <br>
	  <strong>WITHIN 3 WORKING DAYS</strong> <br>
	  for your subjects to be officially enrolled 
	  </td></tr></table>
	  </td>
  </tr>
  <tr>
    <td valign="top" colspan="2"><br>FEES CHARGED SUBJECT TO AUDIT AND CHED APPROVAL</td>
  </tr>
</table>
<DIV style="page-break-before:always" >&nbsp;	</DIV>
<!-------------------------------------------------------------------------------------------->
<!-------------------- registrar copy -------------------------------------------------------->
<!-------------------------------------------------------------------------------------------->
<table width="90%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="50%">SY/TERM: <strong><%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>, AY <%=astrSchYrInfo[0]%>-<%=astrSchYrInfo[1]%></strong></td>
      <td width="50%" height="18" align="right">Date and time printed:<%=WI.getTodaysDateTime()%>&nbsp; </td>
    </tr>
</table>
<table width="90%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="18">Student ID : <strong><font size="2"><%=strStudID%></font></strong></td>
    <td width="57%" height="18">Course / Major : <strong><%=(String)vStudInfo.elementAt(22)%>
      <%if(vStudInfo.elementAt(23) != null){%>
      / <%=(String)vStudInfo.elementAt(23)%>
      <%}%>
      
	  <%=WI.getStrValue((String)vStudInfo.elementAt(6),"-","","")%>
	  </strong></td>
  </tr>
  <tr>
    <td height="18" colspan="2">Student name : <strong><font size="2"><%=(String)vStudInfo.elementAt(1)%></font></strong></td>
  </tr>
  <tr>
    <td width="43%" height="18">Student type : <strong><%=(String)vStudInfo.elementAt(11)%>
	<%if(strSchoolCode.startsWith("AUF")){%>
	/<%if(vStudInfo.elementAt(21).equals("0")){%>Regular<%}else{%>Irregular<%}%>
	<%}%>
	</strong></td>
    <td height="18">Curriculum Year : <strong><%=(String)vStudInfo.elementAt(4)%> - <%=(String)vStudInfo.elementAt(5)%></strong></td>
  </tr>
</table>

  <table width="90%" border="0" cellpadding="0" cellspacing="0">
   <tr>
     <td height="18">&nbsp;</td>
     <td>&nbsp;</td>
   </tr>
  </table>

<table width="90%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr>
    <td width="25%" height="18" class="thinBorderTOP"><strong>SUBJECT CODE</strong></td>
    <td width="48%" class="thinBorderTOP"><strong>SUBJECT TITLE </strong></td>
    <%if(!strSchoolCode.startsWith("AUF")){%>
	<%}%>
    <td width="5%" class="thinBorderTOP"><strong><font size="1">UNITS </font></strong></td>
    <td width="20%" class="thinBorderTOP"><strong>&nbsp;
	<%if(strSchoolCode.startsWith("CPU")){%>STUB CODE<%}else{%>SECTION<%}%> </strong></td>
  </tr>
  <%
int iRowCount = 0;
int iMaxRow   = 14;
for(int i = 1; i<vAdvisedList.size(); ++i)
{++iRowCount;%>
  <tr>
    <td height="20" class="thinborder"><%=(String)vAdvisedList.elementAt(i)%></td>
    <td class="thinborder"><%=(String)vAdvisedList.elementAt(i+1)%></td>
<%if(!strSchoolCode.startsWith("AUF")){%>
    <%}%>
    <td class="thinborder" align="center"><%=(String)vAdvisedList.elementAt(i+9)%></td>
    <td class="thinborder">&nbsp;&nbsp;<%=WI.getStrValue((String)vAdvisedList.elementAt(i+3),"TBA")%></td>
  </tr>
  <%
i = i+10;
}%>
  <tr>
    <td colspan="4" class="thinBorderTOP" valign="bottom">
	  <table width="90%" border="0" cellpadding="0" cellspacing="0">
	   <tr>
		 <td width="43%" height="18">Maximum allowable units: <strong><%=strMaxAllowedLoad%></strong></td>
		 <td width="57%">Total units enrolled: <strong><%=(String)vAdvisedList.elementAt(0)%></strong></td>
	   </tr>
  	  </table>
	</td>
  </tr>
  <tr>
    <td colspan="4">&nbsp;</td>
  </tr>
</table>
<%
if(vMiscFeeInfo == null)
	vMiscFeeInfo = new Vector();
%>
<table width="90%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25">FEES CHARGED SUBJECT TO AUDIT AND CHED APPROVAL </td>
  </tr>
</table>
<table>
<%for(; iRowCount < iMaxRow; ++iRowCount) {%>
	<tr>
	  <td style="font-size:9px" height="25">&nbsp;</td>
	</tr>
<%}%>
	<tr>
	  <td style="font-size:9px" height="25">Received Official study Load and Assessment of Fees: _____________________ &nbsp;&nbsp; Date: _______________</td>
	</tr>
</table>
</body>
</html>
<%
dbOP.cleanUP();
%>
