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
-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">

</script>
<body>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","employee_discount_application.jsp");
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
														"employee_discount_application.jsp");
if(iAccessLevel == 0)
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_personnel_personal_data.jsp");
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



if(WI.fillTextValue("stud_id_list").length() == 0){dbOP.cleanUP();
strErrMsg = "No student list found.";%>
<div style="text-align:center; color:#FF0000; font-size:14px;"><%=strErrMsg%></div>
<%return;}


java.sql.ResultSet rs = null;
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	


enrollment.Authentication authentication = new enrollment.Authentication();
enrollment.FAEmpDiscountApplication FAEmpDisc = new enrollment.FAEmpDiscountApplication();
enrollment.GradeSystem GS = new enrollment.GradeSystem();
enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
EnrlReport.FeeExtraction feeEx = new EnrlReport.FeeExtraction();

Vector vStudInfo = null;
Vector vEmpRec = null;
Vector vGradeDetail = new Vector();
Vector vTemp = null;
Vector vEmpEval = null;
Vector vTuitionFeeDtls = new Vector();

Vector vStudIDList = CommonUtil.convertCSVToVector(WI.fillTextValue("stud_id_list"));

boolean bolShowData = false;
strTemp = "select remark_index from g_sheet_final where gs_index = ?";
java.sql.PreparedStatement pstmtSelect = dbOP.getPreparedStatement(strTemp);

int iIndexOf = 0;
double dTotalAmt = 0d;

String[] astrConvertSem = {"Summer","1<sup>st</sup> Semester","2<sup>nd</sup> Semester","3<sup>rd</sup> Semester","4<sup>th</sup> Semester"};
String[] astrConvertLevel = {"Summer","1<sup>st</sup>","2<sup>nd</sup>","3<sup>rd</sup>","4<sup>th</sup>","5<sup>th</sup>","6<sup>th</sup>","7<sup>th</sup>"};

String strEmpID = WI.fillTextValue("emp_id");
String strStudID = null;

boolean bolNonSchool = true;


if(strEmpID.length() > 0){
	vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0"); 
	if(vEmpRec == null)
		vEmpRec = FAEmpDisc.operateOnEmpNonSchoolMgmt(dbOP, request, 4);			
	else
		bolNonSchool = false;
	
	if(vEmpRec == null || vEmpRec.size() == 0){
		strErrMsg = "Employee information not found.";
		dbOP.cleanUP();%>
		<div style="text-align:center; color:#FF0000; font-size:14px;"><%=strErrMsg%></div>
	<%return;}		
	
	vEmpEval   = FAEmpDisc.operateOnEmpDiscEvaluation(dbOP,request,4, strEmpID);	
}

int iStudCount = vStudIDList.size();
while(vStudIDList.size() > 0){
strStudID = (String)vStudIDList.remove(0);

strErrMsg = null;

vStudInfo = FAEmpDisc.operateOnEmpDiscApplication(dbOP, request, 4, strStudID);
if(vStudInfo == null){	
	if(iStudCount > 1)
		continue;
	else
		strErrMsg = FAEmpDisc.getErrMsg();
}

vGradeDetail = new Vector();
vTuitionFeeDtls = new Vector();


if(strErrMsg == null){

	strTemp = 
		" select sy_from, sy_to, SEMESTER, year_level from STUD_CURRICULUM_HIST  "+
		" join semester_sequence on (semester = semester_val) "+
		" where IS_VALID =1 and USER_INDEX = "+(String)vStudInfo.elementAt(0)+
		" and SY_FROM <=  "+request.getParameter("sy_from") + //strTemp +
		" order by sy_from, sem_order, year_level ";
	Vector vSYList = new Vector();
	rs = dbOP.executeQuery(strTemp);
	while(rs.next()){
		vSYList.addElement(rs.getString(1));//sy_from
		vSYList.addElement(rs.getString(2));//sy_to
		vSYList.addElement(rs.getString(3));//SEMESTER
		vSYList.addElement(rs.getString(4));//year_level
	}rs.close();
	
	if(vSYList.size() == 0){
		if(iStudCount > 1)
			continue;
		else
			strErrMsg = "Student enrollment history not found. Please try again.";		
	}else{	
	
		for(int k = 0; k < vSYList.size(); k+=4){				
			
			fOperation.resetFees();
			
			fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0), false, (String)vSYList.elementAt(k),
			(String)vSYList.elementAt(k+1), (String)vSYList.elementAt(k+3),	(String)vSYList.elementAt(k+2));	
			
			
			if(fOperation.vTuitionFeeDtls != null && fOperation.vTuitionFeeDtls.size() > 0)
				vTuitionFeeDtls.addAll(fOperation.vTuitionFeeDtls);
			
			vTemp = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),"FINALS",
										(String)vSYList.elementAt(k),(String)vSYList.elementAt(k+1),
										(String)vSYList.elementAt(k+2),true,true,true,false);
			if(vTemp == null || vTemp.size() == 0)
				continue;
				
			vGradeDetail.addAll(vTemp);					
		}		
	}
	

}



if(strErrMsg != null && iStudCount == 1){dbOP.cleanUP();%>
<div style="text-align:center; color:#FF0000; font-size:14px;"><%=strErrMsg%></div>
<%return;}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td align="center"><strong style="font-size:16px"><%=SchoolInformation.getSchoolName(dbOP, true, false)%></strong>
		<br><%=SchoolInformation.getAddressLine1(dbOP, false, false)%>
		<br><br>EMPLOYEE'S SCHOOL DISCOUNT FORM
		
		<br><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> / School Year <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%><br>
		<%
		if(!bolNonSchool)
			strTemp = "School";
		else{
			if(vEmpRec != null && vEmpRec.size() > 0)
				strTemp = (String)vEmpRec.elementAt(7);
			else
				strTemp = "&nbsp;";
		}
		%>
		BUSINESS UNIT : <%=strTemp%>
		</td>
	</tr>
</table>
<br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr><td class="thinborder" height="20" colspan="8" align="center">TO BE ACCOMPLISHED BY THE AVAILING EMPLOYEE</td></tr>
	<tr>
		<td style="font-size:9px;" class="thinborder" height="20" colspan="2" align="center">NAME OF EMPLOYEE(Last Name, First Name, Middle Name)</td>
		<td style="font-size:9px;" class="thinborder" colspan="2" align="center">POSITION TITLE</td>
		<td style="font-size:9px;" class="thinborder" width="15%" align="center">DATE HIRED</td>
		<td style="font-size:9px;" colspan="2" align="center" class="thinborder">YEARS IN SERVICE</td>
	    <td style="font-size:9px;" class="thinborder" align="center">EMPLOYMENT STATUS</td>
	</tr>
	<tr>
		<%
		if(!bolNonSchool)
			strTemp  = WebInterface.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),5);
		else
			strTemp  = WebInterface.formatName((String)vEmpRec.elementAt(2),(String)vEmpRec.elementAt(3), (String)vEmpRec.elementAt(4),5);
		%>
		<td class="thinborder" height="35" align="center" colspan="2"><strong><%=strTemp%></strong></td>
		<%
		if(!bolNonSchool)
			strTemp = (String)vEmpRec.elementAt(15);
		else
			strTemp = (String)vEmpRec.elementAt(5);
		%>
		<td class="thinborder" colspan="2" align="center"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>		
		<td class="thinborder" align="center"><strong><%=WI.formatDate((String)vEmpRec.elementAt(6),10)%></strong>&nbsp;</td>
		
		<td colspan="2" align="center" class="thinborder"><strong style="font-size:10px;">
			<%=ConversionTable.differenceInYearMonthDays(null, ConversionTable.convertMMDDYYYYToDate((String)vEmpRec.elementAt(6)), 2)%></strong></td>
	    <%
		/*if(!bolNonSchool)
			strTemp = "School";
		else
			strTemp = (String)vEmpRec.elementAt(7);
		*/
		if(bolNonSchool)
			strTemp = (String)vEmpRec.elementAt(9);
		else
			strTemp = (String)vEmpRec.elementAt(16);
		
		%>
		<td class="thinborder" align="center"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
	</tr>
	<tr>
		<td style="font-size:9px;" class="thinborder" width="26%" height="20" align="center">NAME OF BENEFICIARY</td>
		<td style="font-size:9px;" class="thinborder" width="12%" align="center">BIRTHDATE</td>
		<td style="font-size:9px;" class="thinborder" width="7%" align="center">AGE</td>
		<td style="font-size:9px;" class="thinborder" align="center" colspan="3">GRADE OR YEAR LEVEL &amp; COURSE APPLIED FOR</td>
		<td style="font-size:9px;" class="thinborder" width="14%" align="center">RELATIONSHIP</td>
	    <td style="font-size:9px;" class="thinborder" width="16%" align="center">DISCOUNT PERCENTAGE</td>
	</tr>
	<tr>
		<%
		strTemp = WebInterface.formatName((String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),(String)vStudInfo.elementAt(4),4);
		%>
		<td align="center" class="thinborder" height="35"><strong><%=strTemp%></strong></td>
		<td align="center" class="thinborder"><strong><%=WI.getStrValue(vStudInfo.elementAt(11),"&nbsp;")%></strong></td>
		<td align="center" class="thinborder"><strong><%=WI.getStrValue(vStudInfo.elementAt(12),"&nbsp;")%></strong></td>
		<%
		strTemp = WI.getStrValue(vStudInfo.elementAt(8))+WI.getStrValue((String)vStudInfo.elementAt(9)," / ","","")+WI.getStrValue((String)vStudInfo.elementAt(10)," - ","","");
		if(WI.getStrValue(vStudInfo.elementAt(13)).equals("1"))
			strTemp = WI.getStrValue(vStudInfo.elementAt(8))+WI.getStrValue((String)vStudInfo.elementAt(9)," - ","","");
		%>
		<td align="center" class="thinborder" colspan="3"><strong><%=strTemp%></strong></td>
		<td align="center" class="thinborder"><strong><%=WI.getStrValue(vStudInfo.elementAt(5),"&nbsp;")%></strong></td>
	    <td align="center" class="thinborder"><strong><%=WI.getStrValue(vStudInfo.elementAt(19),"&nbsp;")%></strong></td>
	</tr>
	<tr>
	    <td height="35" colspan="5" style="padding-left:10px;" class="thinborder">With Disciplinary Action / Sanction for the past 12 months: 		
				&nbsp; &nbsp; &nbsp; 
		<%
		strTemp = "";
		if(vEmpEval != null && vEmpEval.size() > 0)
			strTemp = (String)vEmpEval.elementAt(1);
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "";
		%><%=strErrMsg%>YES         
				&nbsp; &nbsp; &nbsp; 
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "";
		%><%=strErrMsg%>NO</td>
		<%
		strTemp = "";
		if(vEmpEval != null && vEmpEval.size() > 0)
			strTemp = (String)vEmpEval.elementAt(2);
		%>
	    <td height="35" colspan="3" class="thinborder" style="padding-left:10px;">Latest Performance Appraisal Result : <strong><%=strTemp%></strong></td>
    </tr>
	<tr>
	    <td height="35" colspan="5" style="padding-left:10px;" class="thinborder">Beneficiaries to Date:  
		<%
		strTemp = WI.getStrValue(vStudInfo.elementAt(20));
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "";
		%>
			&nbsp; &nbsp; &nbsp; <%=strErrMsg%>Self 
		<%
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "";
		%>
			&nbsp; &nbsp; &nbsp; <%=strErrMsg%>Spouse 
		<%
		if(strTemp.equals("2"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "";
		%>
			&nbsp; &nbsp; &nbsp; <%=strErrMsg%>1<sup>st</sup> Child 
		<%
		if(strTemp.equals("3"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "";
		%>
			&nbsp; &nbsp; &nbsp; <%=strErrMsg%>2<sup>nd</sup> Child              
		<%
		if(strTemp.equals("4"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "";
		%>
			&nbsp; &nbsp; &nbsp; <%=strErrMsg%>3<sup>rd</sup> Child</td>
		<%
		strTemp = " select uphd_discount_avail from user_table where user_index =  "+(String)vStudInfo.elementAt(0);
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		%>
		<td height="35" colspan="3" class="thinborder" style="padding-left:10px;">Number of availment : <strong><%=strTemp%></strong></td>
		
    </tr>
</table>
<br>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="center" colspan="2" height="22"><strong>EMPLOYEE ACKNOWLEDGEMENT AND UNDERTAKING</strong></td></tr>
	<tr>
		<td width="8%" valign="top" align="right">1. &nbsp; &nbsp; </td>
		<td width="92%" style="text-align:justify; padding-right:50px;">It is hereby acknowledged that the employee school 
		discount is granted to qualified employees in good standing of the University of Perpetual
		Help System DALTA on a school year basis for Basic Education or semester to semester basis 
		for Higher Education.</td>
	</tr>
	<tr>
		<td width="8%" valign="top" align="right">2. &nbsp; &nbsp; </td>
		<td width="92%" style="text-align:justify; padding-right:50px;">That the employee school discount is co-terminus with the employment of the employee.</td>
	</tr>
	<tr>
		<td width="8%" valign="top" align="right">3. &nbsp; &nbsp; </td>
		<td width="92%" style="text-align:justify; padding-right:50px;">That notwithstanding approval of this school discount availment, 
		employees are required to pay for the tuition fees of all subjects that were failed or dropped by the beneficiary when re-enrolled.</td>
	</tr>
	<tr>
		<td width="8%" valign="top" align="right">4. &nbsp; &nbsp; </td>
		<td width="92%" style="text-align:justify; padding-right:50px;">That the employee school discount applies 
			to tuition and miscellaneous fees, with exception of those items specifically excluded under existing company policies.</td>
	</tr>
	<tr>
		<td width="8%" valign="top" align="right">5. &nbsp; &nbsp; </td>
		<td width="92%" style="text-align:justify; padding-right:50px;">All Company policies apply.</td>
	</tr>
</table>
<br>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="33%" height="20" valign="top">Requesting Approval:</td>
		<td width="33%" valign="top">Recommending Approval:</td>
		<td valign="top">Endorsing Approval:</td>
	</tr>
	<tr>
		<td valign="bottom" align="center" height="70">
			<div style="border-bottom:solid 1px #000000; width:90%;">
				<%=WebInterface.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),5)%></div>
				Availing Employee<br>PRINTED NAME AND SIGNATURE</td>
		<td valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; width:90%;">&nbsp;</div>Department Head<br>PRINTED NAME AND SIGNATURE</td>
		<td valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; width:90%;">&nbsp;</div>Business / Service Unit Head<br>
			PRINTED NAME AND SIGNATURE</td>
	</tr>
</table>

<%
bolShowData = false;

iIndexOf = 0;
dTotalAmt = 0d;

for(int i=0; i< vGradeDetail.size(); i +=8){
	
	if(vGradeDetail.elementAt(i) == null)
		continue;
	
	strTemp = (String)vGradeDetail.elementAt(i);
	pstmtSelect.setString(1,strTemp);
	rs = pstmtSelect.executeQuery();
	if(rs.next()){
		if(rs.getString(1) != null && rs.getInt(1) != 2){
			rs.close();
			continue;
		}
	}rs.close();
	
	bolShowData = true;
	break;
}

if(bolShowData){
%>
<br><br>
<table border="0" cellpadding="0" cellspacing="0" width="80%" align="center">
	<tr>
		<td height="20" width="63%"><%=WebInterface.formatName((String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),(String)vStudInfo.elementAt(4),4)%></td>
		<%
		//strTemp = WI.getStrValue(vStudInfo.elementAt(8))+WI.getStrValue((String)vStudInfo.elementAt(9)," / ","","")+WI.getStrValue((String)vStudInfo.elementAt(10)," - ","","");
		if(WI.getStrValue(vStudInfo.elementAt(13)).equals("1"))
			strTemp = WI.getStrValue(vStudInfo.elementAt(8))+WI.getStrValue((String)vStudInfo.elementAt(9)," - ","","");
		else{
			
			if(vStudInfo.elementAt(10) == null)
				strTemp = "";
			else
				strTemp = astrConvertLevel[Integer.parseInt((String)vStudInfo.elementAt(10))];	
			
			strTemp += " "+WI.getStrValue(vStudInfo.elementAt(8))+WI.getStrValue((String)vStudInfo.elementAt(9)," / ","","");
		}
		%>
		<td width="37%"><%=strTemp%></td>
	</tr>
	<tr>
	    <td height="20"><%=(String)vStudInfo.elementAt(1)%></td>
	    <td><%=astrConvertSem[Integer.parseInt((String)vStudInfo.elementAt(18))]%> / <%=(String)vStudInfo.elementAt(16)+"-"+(String)vStudInfo.elementAt(17)%></td>
    </tr>
</table>

<br>
<table border="0" cellpadding="0" cellspacing="0" width="75%" align="center">
	<tr>
		<td width="15%" height="20"><strong style="font-size:10px">SCODE</strong></td>
		<td><strong style="font-size:10px">DESCRIPTIVE</strong></td>
		<td width="10%" align="center"><strong style="font-size:10px">GRADE</strong></td>
		<td width="10%" align="center"><strong style="font-size:10px">UNITS</strong></td>
		<td width="15%" align="right"><strong style="font-size:10px">AMOUNT</strong></td>
	</tr>
	<%	
	for(int i=0; i< vGradeDetail.size(); i +=8){
	
		if(vGradeDetail.elementAt(i) == null)
			continue;
		
		strTemp = (String)vGradeDetail.elementAt(i);
		pstmtSelect.setString(1,strTemp);
		rs = pstmtSelect.executeQuery();
		if(rs.next()){
			if(rs.getString(1) != null && rs.getInt(1) != 2){
				rs.close();
				continue;
			}
		}rs.close();
	%>
	<tr>
		<td><%=vGradeDetail.elementAt(i + 1)%></td>
		<td><%=WI.getStrValue((String)vGradeDetail.elementAt(i+2)).toUpperCase()%></td>
		
		<%
		
		strTemp = WI.getStrValue((String)vGradeDetail.elementAt(i + 3),"0");
		strErrMsg = (String)vGradeDetail.elementAt(i+5);
		
		if(vGradeDetail.size() > (i + 5 + 8) && strErrMsg != null && ( (strErrMsg.toLowerCase().indexOf("inc") == -1) ) &&
		((String)vGradeDetail.elementAt(i + 1)).compareTo((String)vGradeDetail.elementAt(i + 1 + 8)) == 0 ){ //sub code,
				strTemp = (String)vGradeDetail.elementAt(i + 3 + 8);		
				strErrMsg = (String)vGradeDetail.elementAt(i + 5 + 8);
				i += 8;
		}
		%>
		
		<td align="center"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
		<td align="center"><%=WI.getStrValue(strTemp,"0")%></td>
		<%
		strTemp = null;
		if( (iIndexOf = vTuitionFeeDtls.indexOf((String)vGradeDetail.elementAt(i + 1))) != -1) {
			strTemp = (String)vTuitionFeeDtls.elementAt(iIndexOf+2);
			try{
			dTotalAmt += Double.parseDouble(WI.getStrValue(ConversionTable.replaceString(strTemp, ",", ""),"0"));
			}catch(Exception e){}
			strTemp = CommonUtil.formatFloat(strTemp, true);
		}
		%>
		<td align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<%}%>
	<tr>
	    <td height="20" colspan="4" class="thinborderTOPBOTTOM" align="right"><strong>AMOUNT &nbsp;</strong></td>
	    <td class="thinborderTOPBOTTOM" align="right"><strong><%=CommonUtil.formatFloat(dTotalAmt, true)%></strong></td>
    </tr>
</table>
<%}%>
<br><br>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="33%" height="20" valign="top">Verified by:</td>
		<td width="33%" valign="top">&nbsp;</td>
		<td valign="top">Recommending Approval:</td>
	</tr>
	<tr>
		<td valign="bottom" height="40"><div style="border-bottom:solid 1px #000000; width:90%;">&nbsp;</div>HR OFFICER</td>
		<td>&nbsp;</td>
		<td valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%;">&nbsp;</div>CHIEF HR OFFICER</td>
	</tr>
	<tr>
		<td width="33%" rowspan="2" valign="top">&nbsp;</td>
		<td width="33%" height="40" align="center" valign="bottom">APPROVED BY:</td>
		<td rowspan="2" valign="top">&nbsp;</td>
	</tr>
	<tr>
		<td valign="bottom" align="center" height="60"><div style="border-bottom:solid 1px #000000; width:90%;">&nbsp;</div>ANTHONY JOSE M. TAMAYO<br>PRESIDENT, UPHSD CAMPUSES</td>
	</tr>
</table>

<%
if(vStudIDList.size() > 0){
%>
<div style="page-break-after:always;">&nbsp;</div>
<%}}
if(iStudCount > 0){%>
<script>window.print();</script>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
