<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
	String strTemp = null;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";	
	strSchCode = "SPC";
	DBOperation dbOP = null;

	String strErrMsg = null;
	String strTemp2 = null;
	String strTemp3 = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Releasing print","grade_releasing_print.jsp");
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
GradeSystem GS = new GradeSystem();
FAPaymentUtil pmtUtil = new FAPaymentUtil();

//get student information first before getting grade details.
Vector vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"),
						request.getParameter("sy_from"),request.getParameter("sy_to"),request.getParameter("semester"));


Vector vGradeDetail = null;
Vector vAdditionalInfo = null;
Vector[] vEditInfo = null;
boolean bolIncludeSchedule = false;
//System.out.println(strSchCode);

if (strSchCode.startsWith("CPU")){
	bolIncludeSchedule = true;
}



if(vStudInfo == null)
	strErrMsg = pmtUtil.getErrMsg();
else
{
	//get grade sheet release information.

	boolean bolIncludeEnrolledSubject = true;
	if(strSchCode.startsWith("WNU")){
		String strExcludeList = "#08-95138#,#08-94456#,#06-90163#,#95-02645#,#05-00356#,#08-94070#,#08-94472#,#07-90687#,#08-93114#,#07-91444#,#08-93878#,#07-92340#,#07-91577#,#07-92744#,#08-93053#,#06-90168#,#07-92697#,#07-91191#,#08-94889#,#08-94477#,#08-94853##05-03733#,#07-92704#,#07-92510#,#07-92297#,#06-02003#,#08-94071#,#07-92588#,#06-90221#,#84-02549#,#07-92008#,#08-94287#,#07-91517#,#09-1348-245#,#08-94156#,#07-92587#,#08-93021#,#07-91246#,#08-94747#,#06-90026#,#07-91855#";
		if(strExcludeList.indexOf("#"+request.getParameter("stud_id")+"#") > -1)
			bolIncludeEnrolledSubject = false;
	}
	vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),request.getParameter("grade_for"),
											request.getParameter("sy_from"),request.getParameter("sy_to"),
											request.getParameter("semester"),true,bolIncludeEnrolledSubject,true,bolIncludeSchedule);
	if(vGradeDetail == null)
		strErrMsg = GS.getErrMsg();

	student.StudentInfo studInfo = new student.StudentInfo();
	vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(0));

//	System.out.println(vAdditionalInfo);
//	System.out.println(vStudInfo);

	enrollment.PersonalInfoManagement pif = new  enrollment.PersonalInfoManagement();
	vEditInfo = pif.viewPermStudPersonalInfo(dbOP,request.getParameter("stud_id"));
}


if(strSchCode == null)
	strSchCode = "";
//strSchCode = "AUF";

if(strErrMsg == null) strErrMsg = "";

double dGWA = 0d;

//if(WI.fillTextValue("show_gwa").equals("1")) {
	student.GWA gwa = new student.GWA();
	dGWA = gwa.getGWAForAStud(dbOP,(String)vStudInfo.elementAt(0),
			request.getParameter("sy_from"),request.getParameter("sy_to"),
			request.getParameter("semester"), (String)vStudInfo.elementAt(6),
			(String)vStudInfo.elementAt(7),null);	
//}




boolean bolIsCGH = false;
if(strSchCode.startsWith("CGH"))
	bolIsCGH = true;
boolean bolIsDBTC = strSchCode.startsWith("DBTC");
boolean bolIsCollegeOnly = false;
if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("CLDH") || strSchCode.startsWith("CSA") || strSchCode.startsWith("EAC"))
	bolIsCollegeOnly = true;

/////i have to put parenthesis for math and english enrichment.
Vector vMathEnglEnrichment = null;
boolean bolPutParanthesis = false;
if(vGradeDetail != null) {
	vMathEnglEnrichment = GS.getMathEngEnrichmentInfo(dbOP, request);
}
//System.out.println(strErrMsg);
if(strSchCode.startsWith("UDMC") && (strErrMsg == null || strErrMsg.length() == 0) ) {
	enrollment.ReportRegistrar RR = new enrollment.ReportRegistrar();
	RR.operateOnGradeReleasePrint(dbOP, request, 1);	
}


boolean bolIsFinal = WI.fillTextValue("grade_name").toLowerCase().startsWith("final");
//System.out.println("bolIsFinal : "+bolIsFinal+"  grade_name : "+ WI.fillTextValue("grade_name"));


String strGradeCGH = null;
java.sql.PreparedStatement pstmtGetPercentGrade = dbOP.getPreparedStatement("select grade_cgh from g_sheet_final where gs_index = ?");
boolean bolIsCLDH  = strSchCode.startsWith("CLDH");
if(!bolIsFinal)
	bolIsCLDH = false;
if(strSchCode.startsWith("UL")) {
	bolIsCLDH = true;
}


Vector vGradeNameList = new Vector();
strTemp = "select distinct grade_name,exam_period_order from grade_sheet "+
	" join fa_pmt_schedule on (fa_pmt_schedule.pmt_sch_index = grade_sheet.pmt_sch_index) "+
	" where FA_PMT_SCHEDULE.IS_VALID = 1 "+
	" order by exam_period_order ";
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
while(rs.next())
	vGradeNameList.addElement(rs.getString(1));
rs.close();


Vector vGradeDetailPreMid = new Vector();
strTemp = " select  sub_code, GRADE_SHEET.grade, GRADE_NAME, Remark_abbr from GRADE_SHEET "+
	" join STUD_CURRICULUM_HIST on (STUD_CURRICULUM_HIST.CUR_HIST_INDEX = GRADE_SHEET.CUR_HIST_INDEX) "+
	" join SUBJECT on (subject.SUB_INDEX = GRADE_SHEET.s_index) "+
	" join REMARK_STATUS on (REMARK_STATUS.remark_index = GRADE_SHEET.remark_index) "+
	" where user_index_ = "+(String)vStudInfo.elementAt(0)+" and SY_FROM ="+WI.fillTextValue("sy_from")+" and SEMESTER = "+WI.fillTextValue("semester")+
	" and GRADE_SHEET.IS_VALID = 1 ";
rs = dbOP.executeQuery(strTemp);
while(rs.next()){
	vGradeDetailPreMid.addElement(rs.getString(1)+"-"+rs.getString(3));//sub_code-midterm
	if(rs.getString(2) == null)
		vGradeDetailPreMid.addElement(rs.getString(4));//grade
	else
		vGradeDetailPreMid.addElement(rs.getString(2));//grade
}rs.close();



Vector vGradeDetailFinal = new Vector();
strTemp = "select  sub_code, GRADE2, GRADE_CGH, GRADE, Remark_abbr from G_SHEET_FINAL "+
	" join STUD_CURRICULUM_HIST on (STUD_CURRICULUM_HIST.CUR_HIST_INDEX = G_SHEET_FINAL.CUR_HIST_INDEX) "+
	" join SUBJECT on (subject.SUB_INDEX = G_SHEET_FINAL.s_index) "+
	" join REMARK_STATUS on (REMARK_STATUS.remark_index = G_SHEET_FINAL.remark_index) "+
	" where user_index_ = "+(String)vStudInfo.elementAt(0)+" and SY_FROM ="+WI.fillTextValue("sy_from")+" and SEMESTER = "+WI.fillTextValue("semester")+
	" and G_SHEET_FINAL.IS_VALID = 1 ";
rs = dbOP.executeQuery(strTemp);
while(rs.next()){
	vGradeDetailFinal.addElement(rs.getString(1));//sub_code-midterm
	vGradeDetailFinal.addElement(rs.getString(2));//GRADE2
	vGradeDetailFinal.addElement(rs.getString(3));//GRADE_CGH
	if(rs.getString(4) == null)
		vGradeDetailFinal.addElement(rs.getString(5));//GRADE
	else
		vGradeDetailFinal.addElement(rs.getString(4));//GRADE
}rs.close();

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
	font-size: 11px;
}

<% if (!strSchCode.startsWith("CPU")) {%>
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
<%}else{%>
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

<%}%>
th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
<% if (!strSchCode.startsWith("CPU")) {%>
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 0px #000000;
<%}%>
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborder {
<% if (!strSchCode.startsWith("CPU")) {%>
    border-left: solid 0px #000000;
    border-bottom: solid 0px #000000;
<%}%>
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
<% if (!strSchCode.startsWith("CPU")) {%>
	font-size: 11px;
<%}else{%>
	font-size: 10px;
<%}%>
    }
	
	TD.dottedborderBOTTOMTOP{
		border-bottom: dotted 1px #000000;
		border-top: dotted 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	<% if (!strSchCode.startsWith("CPU")) {%>
		font-size: 11px;
	<%}else{%>
		font-size: 10px;
	<%}%>
	}
	
	TD.dottedborderTOP{
		border-top: dotted 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	<% if (!strSchCode.startsWith("CPU")) {%>
		font-size: 11px;
	<%}else{%>
		font-size: 10px;
	<%}%>
	}


-->
</style>

</head>

<body topmargin="1" bottommargin="0" <%if(!strSchCode.startsWith("DBTC") && WI.getStrValue(strErrMsg).length() ==0){%> onLoad="window.print()"<%}%>>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="20" align="center"><%=strErrMsg%></td>
    </tr>
</table>

<%
if(vStudInfo != null && vStudInfo.size() > 0 && vGradeDetail != null && vGradeDetail.size() > 0){
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="20" colspan="6"><div align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
<%
if(!strSchCode.startsWith("CLDH")){
	if (!strSchCode.startsWith("UDMC") && !bolIsCGH){%>
			  <font size="2"><strong>
			  <%if (strSchCode.startsWith("AUF")){%> 
			  <%=new enrollment.CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(6))%>
			  <%}else {if(bolIsCollegeOnly && !strSchCode.startsWith("CSA") ){%>
			  <%}else{%><br/>
			  REPORT CARD
			  	<%if(!strSchCode.startsWith("DBTC") && !strSchCode.startsWith("CSA")){%>
			  	<%}%>
			  <%}%>
			  <%}%> 
			  </strong></font>
			  <br>
			  <br>
	<%}else{%>
			  <br><font size="2"><strong>
				<%if(bolIsCGH){%>
				
				<%}else{%><%}%></strong></font><br>
<%	}
}//do not show for CLDH%>
        <strong>
		<%if(strSchCode.startsWith("CSA")){
		strTemp = request.getParameter("grade_for").toUpperCase()+" GRADE";
		if(strTemp.startsWith("F"))
			strTemp = "FINAL RATINGS";
		
		%>
			<strong><%=request.getParameter("sem_name").toUpperCase()%>, SY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></strong>
		<%}else{%>
			<%if(!strSchCode.startsWith("CLDH") && false){%><%=request.getParameter("grade_for").toUpperCase()%><%}%></strong><strong><%=request.getParameter("sem_name").toUpperCase()%></strong>
			<strong>, SY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></strong>
		<%}%>
        <br>
         </div><br></td>
    </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  
  <tr>
    <td width="8%" height="19" >Name: </td>
    <td width="19%" height="19" ><%=request.getParameter("stud_id")%></td>
    <td width="44%" ><strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
    
    <td width="29%"  colspan="2" >Course: <%=(String)vStudInfo.elementAt(2)%> <%=WI.getStrValue(vStudInfo.elementAt(4))%> <%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%>
      <%//if(WI.fillTextValue("show_gwa").equals("1") && dGWA > 0f
		//&& !strSchCode.startsWith("UDMC")){%>

<%//}%>
    </td>
  </tr>

<% if (!strSchCode.startsWith("UDMC")){ %>
<%}%>
</table>

<%%>
<table  width="100%" height="132" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="15%" align="left" class="dottedborderBOTTOMTOP">Subjects</td>
    <td width="45%" height="20" align="left" class="dottedborderBOTTOMTOP">Description</td>
    <%
	for(int j = 0; j < vGradeNameList.size(); j++){
	%>
    <td width="5%" align="center" class="dottedborderBOTTOMTOP"><%=vGradeNameList.elementAt(j)%></td>
    <%}%>
    <td width="5%" align="center" class="dottedborderBOTTOMTOP">Final</td>
    <td align="center" width="5%" class="dottedborderBOTTOMTOP">Units</td>
    <% if (!strSchCode.startsWith("CPU") && !bolIsCGH) {%>
    <td width="11%" align="center" class="dottedborderBOTTOMTOP">REMARKS</td>
    <% }%>
  </tr>
  <%
   int iSubjCount = 0;
   int iRowSize = 8;
   int k = 0;

   if (bolIncludeSchedule)
   		iRowSize =9;
   Vector vScheduleDetails = null;
int iIndexOf = 0;
String strColSpan = "";
boolean bolGradeNotVerified = false;
String strGradeValue = null;
String strSubCode    = null; //System.out.println(vMathEnglEnrichment);
double dTotalUnit = 0d;
for(int i=0; i< vGradeDetail.size(); i +=iRowSize){
	++iSubjCount;
	strSubCode = (String)vGradeDetail.elementAt(i + 1);
/**	if(vMathEnglEnrichment != null &&
		WI.getStrValue(vGradeDetail.elementAt(i+6)).toLowerCase().startsWith("p") &&
			vMathEnglEnrichment.indexOf(strSubCode) != -1)
		bolPutParanthesis = true;
	else
		 bolPutParanthesis = false;
**/
	if(vMathEnglEnrichment != null && vMathEnglEnrichment.indexOf(strSubCode) != -1) {
		bolPutParanthesis = true;
		try {
			double dGrade = Double.parseDouble((String)vGradeDetail.elementAt(i + 5));

			bolPutParanthesis = true; //System.out.println(bolPutParanthesis);
			if(dGrade < 5d)
				vGradeDetail.setElementAt("(3.0)",i + 3);
			else 
				vGradeDetail.setElementAt("(0.0)",i + 3);
			
		}
		catch(Exception e){vGradeDetail.setElementAt("(0.0)",i + 3);}
	}
	else	
		bolPutParanthesis = false;	



if(vGradeDetail.elementAt(i) == null) {
	if(bolIsCGH)
		strTemp = " colspan=2";
	else if (strSchCode.startsWith("CPU"))
		strTemp = " colspan=2";
	else
		strTemp = " colspan=3";
}
else
	strTemp = "";


if(bolIsCLDH && vGradeDetail.elementAt(i) != null) {
	pstmtGetPercentGrade.setInt(1, Integer.parseInt((String)vGradeDetail.elementAt(i)));
	rs = pstmtGetPercentGrade.executeQuery();
	if(rs.next())
		strGradeCGH = rs.getString(1);
	else	
		strGradeCGH = "&nbsp;";
	rs.close();
}
else	
	strGradeCGH = "&nbsp;";

%>
  <tr>
    <td valign="top" class="thinborder"><%=(String)vGradeDetail.elementAt(i + 1)%></td>
    <% if (!strSchCode.startsWith("CPU")){%>
    <td valign="top" class="thinborder"><%=(String)vGradeDetail.elementAt(i+2)%></td>
    <%}%>
    <%if(!bolIsCGH){%>
    <%}

//added to show grade not verified instead of grade and remark.
//System.out.println("I am here. :"+vGradeDetail.elementAt(i + 7));
//if(false)//to invalidate the checking if the final grade is not verified 
strColSpan = "";
//System.out.println(vGradeDetail.elementAt(i + 7));
bolGradeNotVerified = false;
if(vGradeDetail.elementAt(i + 7) != null && ((String)vGradeDetail.elementAt(i + 7)).compareTo("0") == 0) {

	if(bolIsCGH)
		strColSpan = " colspan=2";
	else if (strSchCode.startsWith("CPU"))
		strColSpan = " colspan=2";
	else
		strColSpan = " colspan=6";	
	bolGradeNotVerified = true;
	vGradeDetail.setElementAt(null,i);
	vGradeDetail.setElementAt("Grade not available", i + 5);
}
bolGradeNotVerified = false;
if(bolGradeNotVerified){ //not used%>
    <!--<td valign="top" class="thinborder" align="center" <%=strColSpan + vGradeNameList.size()%>><%=((String)vGradeDetail.elementAt(i+5)).toUpperCase()%></td>-->
<%}else{
for(int j = 0; j < vGradeNameList.size(); j++){
 	iIndexOf = vGradeDetailPreMid.indexOf((String)vGradeDetail.elementAt(i + 1)+"-"+(String)vGradeNameList.elementAt(j));
	if(iIndexOf > -1)
		strTemp = (String)vGradeDetailPreMid.elementAt(iIndexOf + 1);
	else
		strTemp = "&nbsp;";
%>
    <td valign="top" class="thinborder"><div align="center"><%=WI.getStrValue(strTemp)%></div></td>
<%}

strTemp = "&nbsp;";
iIndexOf = vGradeDetailFinal.indexOf((String)vGradeDetail.elementAt(i + 1));
if(iIndexOf > -1)
	strTemp = (String)vGradeDetailFinal.elementAt(iIndexOf + 3);

%>
    <td valign="top" class="thinborder"><div align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></div></td>
    <%
/*strTemp = "&nbsp;";
iIndexOf = vGradeDetailFinal.indexOf((String)vGradeDetail.elementAt(i + 1));
if(iIndexOf > -1)
	strTemp = (String)vGradeDetailFinal.elementAt(iIndexOf + 2);

strTemp = "&nbsp;";
iIndexOf = vGradeDetailFinal.indexOf((String)vGradeDetail.elementAt(i + 1));
if(iIndexOf > -1)
	strTemp = (String)vGradeDetailFinal.elementAt(iIndexOf + 3);*/


/*strGradeValue = (String)vGradeDetail.elementAt(i+5);
if(bolIsCGH && strGradeValue != null && (strGradeValue.endsWith(".0") 
	|| strGradeValue.length() == 3) && strGradeValue.indexOf(".") > -1)
	strGradeValue = strGradeValue+"0";
	if(bolPutParanthesis && !strGradeValue.startsWith("Grade"))
		strGradeValue = "("+strGradeValue+")";*/

 



//if(vGradeDetail.elementAt(i) != null) {%>
    <td valign="top" class="thinborder"><div align="center"><%=(String)vGradeDetail.elementAt(i+3)%></div></td>
    <%
		dTotalUnit = dTotalUnit + Double.parseDouble(WI.getStrValue((String)vGradeDetail.elementAt(i+3),"0"));		
		
	 %>
    <td width="3%" valign="top" class="thinborder" align="center"><%=WI.getStrValue((String)vGradeDetail.elementAt(i+6),"&nbsp;")%></td>
    <% 
 //}
}//end bolIsVerified
%>
  </tr>
  <%
  // end cpu descriptive title
} // end for loop%>
  <tr>
    <td class="dottedborderTOP" colspan="2" align="right">&nbsp;</td>
    <%for(int j = 0; j < vGradeNameList.size(); j++){
		if(j + 1 >= vGradeNameList.size())
			strTemp = "W.P.A:";
		else
			strTemp = "&nbsp;";
	%>
	<td class="dottedborderTOP" align="center"><%=strTemp%></td>
	<%}%>
    <td class="dottedborderTOP" align="center"><%=CommonUtil.formatFloat(dGWA,2)%></td>
    <td width="13%" class="dottedborderTOP" align="center"><%=dTotalUnit%></td>
	<td class="dottedborderTOP">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">

</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0"> 
  <tr>
    <td height="25" colspan="4" >&nbsp;    </td>
  </tr>
  <tr>
    <td width="2%"  height="20" >&nbsp;</td>
    <td width="11%" height="20" align="right" valign="top" >IMPORTANT:</td>
    <td width="55%" align="left">Only computer-printed entries in this document are deemed valid and official. 
	Alteration of entries, in any form, will not be honored.</td>
    <td width="32%" height="20" align="center">&nbsp;</td>
  </tr>
  
  
  <tr>
    <td  height="20" colspan="3" >&nbsp;</td>
    <td height="20" align="center">

	<strong><%=CommonUtil.getNameForAMemberType(dbOP,"University Registrar",7)%></strong><br><br>
	Registrar
	<strong></td>
  </tr>
</table>

<%
if(false)
if (bolIsCGH){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="9" height="10" >&nbsp;</td>
  </tr>
  <tr>
    <td colspan="9" height="10" >&nbsp;</td>
  </tr>
  <tr>
    <td width="2%" height="25" >&nbsp;</td>
    <td width="47%" valign="top" align="center">
	<strong><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1).toUpperCase()%></strong><br>
	Prepared/Checked by</td>
    <td width="51%" valign="top" align="center"><strong><%=CommonUtil.getNameForAMemberType(dbOP,"University Registrar",7).toUpperCase()%></strong><br>
Registrar</td>
  </tr>
</table>
<%} else if (!strSchCode.startsWith("UDMC")) {%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="10" height="10" >&nbsp;</td>
  </tr>
  <tr>
    <td width="2%" height="33" >&nbsp;</td>
    <td width="47%" height="33" valign="top">
<%if(strSchCode.startsWith("LNU")){%>
      Prepared by : <u>&nbsp;
	  <%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%>
      &nbsp;</u>
<%}else if(!strSchCode.startsWith("DBTC")){%>
	NOTE:
<%}%></td>
<%if(strSchCode.startsWith("AUF")){%>
    <td width="25%" valign="top" align="center">&nbsp;</td>
<%}%>
    <td width="<%if(strSchCode.startsWith("AUF")){%>25<%}else{%>51<%}%>%" valign="top" align="center">CERTIFIED CORRECT:</td>
  </tr>
  <tr>
    <td  height="20" >&nbsp;</td>
    <td height="20" valign="top" >
<%if(strSchCode.startsWith("LNU")){%>
      NOTE : A student is given 100 days to complete incomplete grades counted
      from the date of final examination.
<%}else if(!strSchCode.startsWith("DBTC")){
	if(strSchCode.startsWith("VMU")){%>
	Incomplete grades must be completed within a month,
	<%}else{%>
	Inc grades must be completed within a year,
	<%}%><br>otherwise they become <%if(strSchCode.startsWith("CSA")){%>No Credit<%}else{%>failure<%}%>
<%}%>    </td>
<%if(strSchCode.startsWith("AUF")){%>
    <td align="center">&nbsp;</td>
<%}%>
    <td height="20" align="center">
<%if (!strSchCode.startsWith("AUF")) {%> 
	<strong><%=CommonUtil.getNameForAMemberType(dbOP,"University Registrar",1)%></strong><br>
	<%if(!strSchCode.startsWith("DBTC") && !bolIsCollegeOnly){%>University <%}%>Registrar
<%}else{%> 	
	<strong><%=WI.getStrValue(vStudInfo.elementAt(15)).toUpperCase()%></strong><br>Dean
<%}%> 
	</td>
  </tr>
</table>
<%}else{
	// UDMC .. in  a world of their own

%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="10" >&nbsp;</td>
    <td height="10" colspan="4" ><font size="1">Grading System</font></td>
    <td >&nbsp;</td>
    <td >&nbsp;</td>
    <td >&nbsp;</td>
    <td height="10" >&nbsp;</td>
  </tr>
  <tr>
    <td width="1%"  height="20" >&nbsp;</td>
    <td width="5%" height="20" valign="top" ><font size="1">1.0<br>
      1.25<br>
      1.5<br>
      1.75<br>
      2.0<br>
      </font></td>
    <td width="6%" valign="top" ><font size="1">99-100<br>
      96-98<br>
      93-95<br>
      90-92<br>
      87-89<br>
      </font></td>
    <td width="5%" valign="top" ><font size="1">2.25<br>
      2.5<br>
      2.75<br>
      3.0<br>
      5.0<br>
      </font></td>
    <td width="8%" valign="top" ><font size="1">84-86<br>
      81-83<br>
      78-80<br>
      75-77<br>
      70<br>
      </font></td>
    <td width="4%" valign="top" ><font size="1">Inc. <br>
      AW <br>
      UW <br>
      DRP </font></td>
    <td width="20%" valign="top" ><font size="1">Incomplete <br>
      Authorized Withdrawal<br>
      Un authorized Withdrawal<br>
      Dropped </font></td>
    <td width="25%" valign="top" ><font size="1">&nbsp;Total No. of Units:__<u><strong><%=dTotalUnit%></strong></u>__<br>
      &nbsp;Weighted Average:__<u>
      <%if(WI.fillTextValue("show_gwa").equals("1") && dGWA > 0f
		&& strSchCode.startsWith("UDMC")){%>
      <strong><%=CommonUtil.formatFloat(dGWA,true)%></strong>
      <%}%>
      </u>__ </font></td>
    <td width="25%" height="20" valign="bottom"><div align="center">
	<img src="./gnilo_signature.gif"><br>
	<!--<font size="1"><strong><%=CommonUtil.getNameForAMemberType(dbOP,"University Registrar",1).toUpperCase()%></strong><br>
        Registrar</font>--></div></td>
  </tr>
  <tr>
    <td  height="20" >&nbsp;</td>
    <td height="20" colspan="8" style="font-size:11px;">NOTE : INC. grades must be completed within a year otherwise it will be a FAILED grade. </td>
  </tr>
</table>

<%} //end of UDMC's world%>


<%}//only if vStudInfo and vGradeDetail are not null
dbOP.cleanUP();
%>
</body>
</html>
