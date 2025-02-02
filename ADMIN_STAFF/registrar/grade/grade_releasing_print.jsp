<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
	String strTemp = null;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strInfo5 = (String)request.getSession(false).getAttribute("info5");
	if(strSchCode == null) {%>
		<p style="font-size:16px; color:#FF0000">You are already logged out. Please login to print</p>
	<%return;	
	}

	//System.out.println(strSchCode);
	
	boolean bolIsVMA = strSchCode.startsWith("VMA");
	boolean bolIsNEU = strSchCode.startsWith("NEU");

	if(strSchCode.startsWith("UPH") && strInfo5 == null) {%>
		<jsp:forward page="./grade_releasing_print_uphd.jsp"/>
	<%}if(strSchCode.startsWith("UPH") && strInfo5 != null) {%>
		<jsp:forward page="./grade_releasing_print_jonelta.jsp"/>
	<%}if(strSchCode.startsWith("SPC")) {%>
		<jsp:forward page="./grade_releasing_print_spc.jsp"/>
	<%}if(strSchCode.startsWith("CDD")) {%>
		<jsp:forward page="./grade_releasing_print_cdd.jsp"/>
	<%}if(strSchCode.startsWith("UC")) {%>
		<jsp:forward page="./grade_releasing_print_uc.jsp"/>
	<%}
	if(strSchCode.startsWith("EAC")) {%>
		<jsp:forward page="./grade_releasing_print_eac.jsp"/>
	<%}
	if(strSchCode.startsWith("PHILCST")) {%>
		<jsp:forward page="./grade_releasing_print_philcst.jsp"/>
	<%}
	if(strSchCode.startsWith("FATIMA")) {%>
		<jsp:forward page="./grade_releasing_print_fatima.jsp"/>
	<%}
	if(strSchCode.startsWith("WUP")) {%>
		<jsp:forward page="./grade_releasing_print_WUP.jsp"/>
	<%}
	if(strSchCode.startsWith("SWU")) {%>
		<jsp:forward page="./grade_releasing_print_swu.jsp"/>
	<%}
	if(strSchCode.startsWith("CIT")) {
		strTemp = WI.fillTextValue("print_grade_option");
		if(strTemp.equals("2")){%>
			<jsp:forward page="./grade_certificate_advance_grade_cit_print.jsp"/>
	<%}else if(strTemp.equals("0")){%>
			<jsp:forward page="./grade_releasing_print_cit.jsp"/>
	<%}else if(strTemp.equals("1")){%>

	<%}
	}


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

//System.out.println(vStudInfo);
int iIndexOf = 0;
double dTotUnitEnrolled = 0d;//for AUF only
double dUnitEnrolled    = 0d;
Vector vSubEnrlInfo     = new Vector();//[0] sub_index, [1] sub_code - sub_name [2] units enrolled.
double dPassed = 0d; double dFailed = 0d; double dDropped = 0d; double dINC = 0d; double dGNY = 0d; double dOther = 0d;
String strRemark = null;
/// end of AUF.

Vector vGradeDetail = null;
Vector vAdditionalInfo = null;
Vector[] vEditInfo = null;
boolean bolIncludeSchedule = false;
//System.out.println(strSchCode);

if (strSchCode.startsWith("CPU")){
	bolIncludeSchedule = true;
}
boolean bolShowGWA = WI.fillTextValue("show_gwa").equals("1");


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
	else{
		strTemp = " select cur_hist_index from STUD_CURRICULUM_HIST where IS_VALID = 1 and USER_INDEX = "+(String)vStudInfo.elementAt(0)+
			" and SY_FROM = "+request.getParameter("sy_from")+" and SEMESTER = "+request.getParameter("semester");
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp != null && strTemp.length() > 0){
			 String strGradeTableName = "GRADE_SHEET";
			 String strGradeNameCon = null;			 
			 if (request.getParameter("grade_for").toLowerCase().startsWith("final")) {
				  strGradeTableName = "G_SHEET_FINAL";
				  strGradeNameCon = " and COPIED_FR_TF_GS = 0 and user_index_=" + (String)vStudInfo.elementAt(0);
			}
			else 
			  strGradeNameCon = " and grade_name='" + ConversionTable.replaceString(request.getParameter("grade_for"), "'", "''") + "'";
			
			/**
			check if there is failure
			*/
			strTemp = " select gs_index from " + strGradeTableName + 
				" where "+strGradeTableName+".is_valid = 1 and remark_index <> 1 and cur_hist_index = "+strTemp + strGradeNameCon;			
			if(dbOP.getResultOfAQuery(strTemp, 0) != null && strSchCode.startsWith("UB"))
				bolShowGWA = false;
		}
	}
	

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

if(bolShowGWA) {
	student.GWA gwa = new student.GWA();
	dGWA = gwa.getGWAForAStud(dbOP,(String)vStudInfo.elementAt(0),
			request.getParameter("sy_from"),request.getParameter("sy_to"),
			request.getParameter("semester"), (String)vStudInfo.elementAt(6),
			(String)vStudInfo.elementAt(7),null);
	//System.out.println(gwa.getErrMsg());

}

double dTotalUnits = 0d;


boolean bolIsCGH = false;
if(strSchCode.startsWith("CGH"))
	bolIsCGH = true;
boolean bolIsDBTC = strSchCode.startsWith("DBTC");
boolean bolIsAUF = strSchCode.startsWith("AUF");

boolean bolIsCollegeOnly = false;
if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("CLDH") || strSchCode.startsWith("CSA") || 
strSchCode.startsWith("EAC") || strSchCode.startsWith("MARINER"))
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

if(bolIsAUF && vStudInfo != null && vStudInfo.size() > 0) {
	String strDegreeType = null;
	String strSQLQuery = "select degree_type from STUD_CURRICULUM_HIST "+
							"join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
							"where user_index = "+(String)vStudInfo.elementAt(0)+
							" and STUD_CURRICULUM_HIST.is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from")+
							" and semester = "+WI.fillTextValue("semester");
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next())
		strDegreeType = rs.getString(1);
	rs.close();
 	String strTableName = null;
	//collect here enrolled subject.
	strSQLQuery = "select subject.sub_index, sub_code, sub_name, unit_enrolled from enrl_final_cur_list ";
	if(strDegreeType.equals("1")) {
		strSQLQuery += "join CCULUM_MASTERS on (CCULUM_MASTERS.cur_index = enrl_final_cur_list.cur_index) "+
					" join subject on (subject.sub_index = CCULUM_MASTERS.sub_index) ";
	}
	else if(strDegreeType.equals("2")) {
		strSQLQuery += "join cculum_medicine on (cculum_medicine.cur_index = enrl_final_cur_list.cur_index) "+
					" join subject on (subject.sub_index = cculum_medicine.sub_index) ";
	}
	else {
		strSQLQuery += "join curriculum on (curriculum.cur_index = enrl_final_cur_list.cur_index) "+
					" join subject on (subject.sub_index = curriculum.sub_index) ";
	}
	strSQLQuery += " where user_index = "+(String)vStudInfo.elementAt(0)+ 
				"and enrl_final_cur_list.is_valid = 1 and enrl_final_cur_list.sy_from = "+WI.fillTextValue("sy_from")+ 
				"and current_semester = "+WI.fillTextValue("semester")+" and IS_TEMP_STUD = 0";
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vSubEnrlInfo.addElement(rs.getString(1));//[0] sub_index
		vSubEnrlInfo.addElement(rs.getString(2)+" - "+rs.getString(3));//[1] sub_code - sub_name
		vSubEnrlInfo.addElement(rs.getString(4));//[2] unit_enrolled
		
		dTotUnitEnrolled += rs.getDouble(4);
	}
	rs.close();
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
    border-right: solid 1px #000000;
<%}%>
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborder {
<% if (!strSchCode.startsWith("CPU")) {%>
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
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

 // a world of their own for CPUvStudInfo
  if(!strSchCode.startsWith("CPU")) {
%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
 <%if(strSchCode.startsWith("UI")){%>
    <tr >

    <td height="20" colspan="6" align="right"><font style="font-size:9px"> UI-REG-0016
      Revision Date: Feb, 2004 </font></td>
    </tr>
 <%}
 if(strSchCode.startsWith("UB")){ 
 %>
 <tr >
 	
      <td height="20">
	  <div style="float:left; position:absolute; left:100px;"><img src="../../../images/logo/<%=strSchCode%>.gif" border="0" height="80"></div>
	  <div align="center"><font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
          		<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
			  <font size="2"><strong>OFFICE OF THE UNIVERSITY REGISTRAR</strong></font><br><br>
        <strong>		
			<%
			strTemp = request.getParameter("grade_for").toUpperCase();
			if(WI.fillTextValue("is_gpa").equals("1"))
				strTemp = "GPA";
			%><%=strTemp%></strong> GRADES FOR <strong><%=request.getParameter("sem_name").toUpperCase()%></strong>
			<strong>, AY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></strong>
		
        <br>
         </div></td>
      
 </tr>
 <%}else{%>
    <tr >
      <td height="20" colspan="6"><div align="center"><font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
<%
if(!strSchCode.startsWith("CLDH")){
	if (!strSchCode.startsWith("UDMC") && !bolIsCGH){%>
			  <font size="2"><strong>
			  <%if (bolIsAUF){%>
			  <%=new enrollment.CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(6))%>
			  <%}else {if(bolIsCollegeOnly && !strSchCode.startsWith("CSA") ){%>COLLEGE OF<%}else{%>OFFICE OF THE
			  	<%if(!strSchCode.startsWith("DBTC") && !strSchCode.startsWith("CSA")){%>UNIVERSITY<%}%>
			  <%}%> REGISTRAR <%}%>
			  </strong></font>
			  <br>
			  <br>
	<%}else{%>
			  <br><font size="2"><strong>
				<%if(bolIsCGH){%>
				GRADES SLIP
				<%}else{%>REPORT OF GRADES<%}%></strong></font><br>
<%	}
}//do not show for CLDH%>
        <strong>
		<%if(strSchCode.startsWith("CSA")){
		strTemp = request.getParameter("grade_for").toUpperCase()+" GRADE";
		if(strTemp.startsWith("F"))
			strTemp = "FINAL RATINGS";

		%>
			<strong><%=strTemp%> FOR <%=request.getParameter("sem_name").toUpperCase()%>, AY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></strong>
		<%}else{%>
			<%if(!strSchCode.startsWith("CLDH")){
			strTemp = request.getParameter("grade_for").toUpperCase();
			if(WI.fillTextValue("is_gpa").equals("1"))
				strTemp = "GPA";
			%><%=strTemp%><%}%></strong> GRADES FOR <strong><%=request.getParameter("sem_name").toUpperCase()%></strong>
			<strong>, AY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></strong>
		<%}%>
        <br>
         </div></td>
    </tr>
	<%}%>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="18" colspan="6" align="right"><font size="1"> Date Printed : <%=WI.getTodaysDate(6)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>
  </tr>
  <tr>
    <td width="3%" height="19" >&nbsp;</td>
    <td width="10%" height="19" >Student ID </td>
    <td width="34%" ><strong><%=request.getParameter("stud_id")%></strong></td>
    <td width="13%" >Course/Major</td>
    <td  colspan="2" ><strong><%=(String)vStudInfo.elementAt(2)%> <%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%></strong></td>
  </tr>
  <tr>
    <td height="18" >&nbsp;</td>
    <td height="18" > Name</td>
    <td height="18" ><strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
    <td height="18" >Year</td>
    <td width="12%" height="18" ><strong><%=WI.getStrValue(vStudInfo.elementAt(4))%></strong></td>
    <td width="28%" height="18" >
	<%if(WI.fillTextValue("show_gwa").equals("1") && dGWA > 0d
		&& !strSchCode.startsWith("UDMC")){%>
		GWA : <strong><%=CommonUtil.formatFloat(dGWA,2)%></strong>
	<%}%></td>
  </tr>

<% if (!strSchCode.startsWith("UDMC")){ %>
  <tr>
    <td height="20" >&nbsp;</td>
    <td height="20" >Address</td>
    <td height="20" colspan="4" > <%if(vAdditionalInfo != null && vAdditionalInfo.size() > 0){%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),", ","","")%> <%}%> </td>
  </tr>
<%}%>
</table>

<%}else{ // begin of CPU's own world %>

<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td width="70%">&nbsp;<%=SchoolInformation.getSchoolName(dbOP,true,false)%> - Collegiate Grade Record</td>
    <td width="30%"><div align="right"><%=request.getParameter("sem_name").toUpperCase()%> , <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%> </div></td>
</tr>
</table>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
  <tr valign="bottom">
    <td width="7%" height="25">Name: </td>
    <td width="27%" class="thinborderBottom">&nbsp;<%=(String)vStudInfo.elementAt(1)%></td>
    <td width="11%"> <div align="right">Stud. No.:</div></td>
    <td width="20%" class="thinborderBottom">&nbsp;<%=request.getParameter("stud_id")%></td>
    <td width="11%"><div align="right">Course/Year : </div></td>

    <td width="12%" class="thinborderBottom"><strong>&nbsp; </strong><%=WI.getStrValue((String)vStudInfo.elementAt(11))%> <%=WI.getStrValue((String)vStudInfo.elementAt(12),"(", ")", "")%> <%=WI.getStrValue((String)vStudInfo.elementAt(4))%></td>
    <td width="5%"><div align="right">Sex:</div></td>
	<%
		if (vEditInfo != null)
			strTemp = WI.getStrValue(vEditInfo[0].elementAt(15));
		else
			strTemp = "";
	%>
    <td width="5%" class="thinborderBottom">&nbsp;<%=strTemp%></td>
  </tr>
</table>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <td width="7%"> College: </td>
    <td width="24%" class="thinborderBottom">&nbsp; <%=WI.getStrValue((String)vStudInfo.elementAt(13))%> </td>
    <td width="11%"> <div align="right">Civil Status: </div></td>
<%
	if (vEditInfo != null)
		strTemp = WI.getStrValue(vEditInfo[0].elementAt(20));
	else
		strTemp = "";
%>
    <td width="10%" class="thinborderBottom">&nbsp;<%=strTemp%></td>
    <td width="13%"><div align="right">Citizenship: </div></td>
<%
	if (vEditInfo != null)
		strTemp = WI.getStrValue(vEditInfo[0].elementAt(17));
	else
		strTemp = "";
%>
    <td width="15%" class="thinborderBottom">&nbsp;<%=strTemp%></td>
    <td width="13%"><div align="right">Classification:</div></td>
    <td width="7%" class="thinborderBottom">&nbsp;</td>
  </tr>
</table>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <td width="11%"> LandLady: </td>
<%
	if (vEditInfo != null)
		strTemp = WI.getStrValue(vEditInfo[0].elementAt(43));
	else
		strTemp = "";
%>
    <td width="23%" class="thinborderBottom">&nbsp;<%=strTemp%></td>

    <td width="10%"> <div align="right">Address: </div></td>
<%
	if (vEditInfo != null)
		strTemp = WI.getStrValue((String)vEditInfo[0].elementAt(45))  +
				WI.getStrValue((String)vEditInfo[0].elementAt(46), ", " , "","") +
				WI.getStrValue((String)vEditInfo[0].elementAt(47), ", " , "","") +
				WI.getStrValue((String)vEditInfo[0].elementAt(48), ", " , "","") +
				WI.getStrValue((String)vEditInfo[0].elementAt(49), " ","","" );
	else
		strTemp = "";
%>

    <td width="56%" class="thinborderBottom">&nbsp;<%=strTemp%></td>
  </tr>
</table>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <td width="9%"> Parent: </td>
<%
	if (vEditInfo != null){
		strTemp = WI.getStrValue(vEditInfo[0].elementAt(68));
		if (strTemp.length() == 0)
			strTemp = WI.getStrValue(vEditInfo[0].elementAt(74));
	}else
		strTemp = "";
%>
    <td width="26%" class="thinborderBottom">&nbsp;<%=strTemp%></td>
    <td width="10%"> <div align="right">Address: </div></td>
<%
	if (vEditInfo != null)
		strTemp = WI.getStrValue((String)vEditInfo[0].elementAt(37))  +
				WI.getStrValue((String)vEditInfo[0].elementAt(38), ", " , "","") +
				WI.getStrValue((String)vEditInfo[0].elementAt(39), ", " , "","") +
				WI.getStrValue((String)vEditInfo[0].elementAt(40), ", " , "","") +
				WI.getStrValue((String)vEditInfo[0].elementAt(41), " ","","" );
	else
		strTemp = "";
%>
    <td width="55%" class="thinborderBottom">&nbsp;<%=strTemp%></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<%}%>
<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr>
    <% if (strSchCode.startsWith("CPU")) {%>
    <td width="3%" align="center" class="thinborder"><font size="1"><strong>NO.</strong></font></td>
    <%
		strTemp = "SUBJECT";
	}else
		strTemp ="SUBJECT CODE";
	if(bolIsDBTC)
		strTemp = "COURSE CODE";
	%>
    <td width="15%" height="20" align="center" class="thinborder"><font size="1"><strong> <%=strTemp%></strong></font></td>
    <% if (!strSchCode.startsWith("CPU")) {%>
    <td width="30%" align="center" class="thinborder"><font size="1"><strong>
      <%if(bolIsCGH || bolIsDBTC){%>
      DESCRIPTIVE TITLE
      <%}else{%>
      SUBJECT NAME/DESCRIPTION
      <%}%>
    </strong></font></td>
    <%} //  end remove td
 if (strSchCode.startsWith("CPU")) {
	 		strTemp = "TEACHER";  %>
    <td width="14%" align="center" class="thinborder"><font size="1"><strong> DAY / TIME </strong></font></td>
    <td width="9%" align="center" class="thinborder"><font size="1"><strong> ROOM </strong></font></td>
    <%}else {
			strTemp = "INSTRUCTOR";
}%>
    <%if(!bolIsCGH){%>
    <td width="16%" align="center" class="thinborder"><font size="1"><strong><%=strTemp%></strong></font></td>
    <%}%>
    <td width="6%" align="center" class="thinborder"><font size="1"><strong>
      <%if(!bolIsCGH){%>
      GRADE
      <%}else{%>
      GENERAL AVERAGE
      <%}%>
    </strong></font></td>
    <%if(bolIsCLDH){%>
    <td width="6%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">%ge Grade </td>
    <%} if (!strSchCode.startsWith("CPU") && !strSchCode.startsWith("UDMC") && !bolIsDBTC && !strSchCode.startsWith("UL")) {%>
    <td width="7%" align="center" class="thinborder"><font size="1"><strong>
      <%if(bolIsCGH){%>
      COMPLETION GRADE
      <%}else{%>
      RE-EXAM
      <%}%>
    </strong></font></td>
    <%}%>
    <td width="6%" align="center" class="thinborder"><font size="1"><strong>
      <%if(bolIsCGH){%>
      CREDIT UNITS
      <%}else if(bolIsAUF){%>
      UNITS EARNED
      <%}else{%>
      CREDITS
      <%}%>
    </strong></font></td>
    <%if(bolIsAUF) {%>
    <td width="9%" align="center" class="thinborder"><font size="1"><strong>UNITS TAKEN</strong></font></td>
    <%}if (!strSchCode.startsWith("CPU") && !bolIsCGH) {%>
    <td width="9%" align="center" class="thinborder"><font size="1"><strong>REMARKS</strong></font></td>
    <%}%>
  </tr>
  <%
  String strFontColor = null;
  
   int iSubjCount = 0;
   int iRowSize = 8;
   int k = 0;

   if (bolIncludeSchedule)
   		iRowSize =9;
   Vector vScheduleDetails = null;///System.out.println(vSubEnrlInfo);
java.sql.ResultSet rs = null;
String strGradeValue = null;
String strSubCode    = null; //System.out.println(vGradeDetail);
for(int i=0; i< vGradeDetail.size(); i +=iRowSize){
	++iSubjCount;
	strSubCode = (String)vGradeDetail.elementAt(i + 1);
	//System.out.println(strSubCode + " - "+(String)vGradeDetail.elementAt(i + 2));
	//units enrolled -- for AUF.
	iIndexOf = vSubEnrlInfo.indexOf(strSubCode + " - "+(String)vGradeDetail.elementAt(i + 2));
	if(iIndexOf > -1) {
		dUnitEnrolled = Double.parseDouble((String)vSubEnrlInfo.elementAt(iIndexOf + 1));
	}
	else
		dUnitEnrolled = 0d; 
	
	if(bolIsAUF) {	
		//added code to set font color to red if failed.. 
		if(WI.getStrValue((String)vGradeDetail.elementAt(i+6), "&nbsp;").equals("Passed") ||
			WI.getStrValue((String)vGradeDetail.elementAt(i+6), "&nbsp;").equals("Completed"))
				strFontColor = "";
		else
			strFontColor = " style='color:#FF0000'";
			
		//determine here all the units type.
		strRemark = WI.getStrValue((String)vGradeDetail.elementAt(i+6), "").toLowerCase();
		if(vGradeDetail.elementAt(i + 7) != null && ((String)vGradeDetail.elementAt(i + 7)).compareTo("0") == 0 && bolIsFinal)
			strRemark = "";
		
		if(strRemark.length() == 0) 
			dGNY += dUnitEnrolled;
		else if(strRemark.startsWith("pass") || strRemark.startsWith("cont"))
			dPassed += dUnitEnrolled;
		else if(strRemark.startsWith("fail"))
			dFailed += dUnitEnrolled;
		else if(strRemark.startsWith("dropped") || strRemark.startsWith("wp"))
			dDropped += dUnitEnrolled;
		else if(strRemark.startsWith("incomplete"))
			dINC += dUnitEnrolled;
		else 
			dOther += dUnitEnrolled;
	}
	//System.out.println("dGNY: "+dGNY+" ,,dPassed = "+dPassed +" ,,dFailed = "+dFailed+" ,,dDropped = "+dDropped+" ,,dINC = "+dINC+" ,,dOther = "+dOther);
	
/**	if(vMathEnglEnrichment != null &&
		WI.getStrValue(vGradeDetail.elementAt(i+6)).toLowerCase().startsWith("p") &&
			vMathEnglEnrichment.indexOf(strSubCode) != -1)
		bolPutParanthesis = true;
	else
		 bolPutParanthesis = false;
**/
	bolPutParanthesis = false;
	if(strSchCode.startsWith("CGH")) {
		if(vMathEnglEnrichment != null && vMathEnglEnrichment.indexOf(strSubCode) != -1) {
			bolPutParanthesis = true;
			try {
				double dGrade = Double.parseDouble((String)vGradeDetail.elementAt(i + 5));
				//System.out.println(dGrade);
				bolPutParanthesis = true; //System.out.println(bolPutParanthesis);
				if(dGrade < 5d)
					vGradeDetail.setElementAt("(3.0)",i + 3);
				else
					vGradeDetail.setElementAt("(0.0)",i + 3);
	
			}
			catch(Exception e){vGradeDetail.setElementAt("(0.0)",i + 3);}
		}
	}else if(vMathEnglEnrichment != null){
		iIndexOf = vMathEnglEnrichment.indexOf(strSubCode);
		if(iIndexOf != -1 && WI.getStrValue(vGradeDetail.elementAt(i+6)).toLowerCase().startsWith("p")) {
			bolPutParanthesis = true;
			try {
				double dGrade = Double.parseDouble((String)vMathEnglEnrichment.elementAt(iIndexOf + 1)) +
				Double.parseDouble((String)vMathEnglEnrichment.elementAt(iIndexOf + 2));
				//System.out.println(dGrade);
				vGradeDetail.setElementAt("("+dGrade+")",i + 3);
			}
			catch(Exception e){vGradeDetail.setElementAt("(0.0)",i + 3);}
		}
	}



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
//added to show grade not verified instead of grade and remark.
//System.out.println("I am here. :"+vGradeDetail.elementAt(i + 7));
if(vGradeDetail.elementAt(i + 7) != null && ((String)vGradeDetail.elementAt(i + 7)).compareTo("0") == 0 && bolIsFinal) {
	if(bolIsCGH)
		strTemp = " colspan=2";
	else if (strSchCode.startsWith("CPU"))
		strTemp = " colspan=2";
	else
		strTemp = " colspan=3";
	vGradeDetail.setElementAt(null,i);
	vGradeDetail.setElementAt("Grade not verified", i + 5);
}

if((bolIsCLDH || bolIsVMA) && vGradeDetail.elementAt(i) != null) {
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
  <tr<%=strFontColor%>>
    <%if (strSchCode.startsWith("CPU")) {%>
    <td valign="top" class="thinborder"><%=iSubjCount%></td>
    <%}%>
    <td valign="top" class="thinborder"><%=(String)vGradeDetail.elementAt(i + 1)%></td>
    <% if (!strSchCode.startsWith("CPU")){%>
    <td valign="top" class="thinborder"><%=(String)vGradeDetail.elementAt(i+2)%></td>
    <%}else{
		vScheduleDetails = (Vector)vGradeDetail.elementAt(i+8);
		strTemp2 = "";
		strTemp3 = "";
		if ( vScheduleDetails != null && vScheduleDetails.size() > 0)
		for (k=0; k < vScheduleDetails.size(); k+=3){
			if (k ==0){
				strTemp2 = (String)vScheduleDetails.elementAt(k);
				strTemp3 = (String)vScheduleDetails.elementAt(k+2);
			}else{
				strTemp2 += "<br> " +  (String)vScheduleDetails.elementAt(k);
				strTemp3 += "<br> " +  (String)vScheduleDetails.elementAt(k+2);
			}
		}
	%>
    <td valign="top" class="thinborder"><%=WI.getStrValue(strTemp3,"&nbsp;")%></td>
    <td valign="top" class="thinborder"><div align="center"><%=WI.getStrValue(strTemp2,"&nbsp;")%></div></td>
    <%}%>
    <%if(!bolIsCGH){%>
    <td valign="top" class="thinborder">&nbsp;<%=WI.getStrValue((String)vGradeDetail.elementAt(i+4),"n/f")%></td>
    <%}
strGradeValue = (String)vGradeDetail.elementAt(i+5);

try{//get only those numeric value of gradeCGH for VMA if exam_name=GPA
	if( Double.parseDouble(strGradeValue) >= 0 &&
		bolIsFinal && WI.fillTextValue("is_gpa").equals("0") && bolIsVMA)
		strGradeValue = strGradeCGH;	
}catch(Exception e)	{
	
}


if((bolIsCGH || bolIsNEU) && strGradeValue != null && (strGradeValue.endsWith(".0") || strGradeValue.length() == 3) && strGradeValue.indexOf(".") > -1)
	strGradeValue = strGradeValue+"0";
	if(bolPutParanthesis && !strGradeValue.startsWith("Grade"))
		strGradeValue = "("+strGradeValue+")";
%>
    <td valign="top" class="thinborder"<%=strTemp%>><div align="center"><%=strGradeValue%></div></td>
    <%if(bolIsCLDH){%>
    <td valign="top" class="thinborder"<%=strTemp%> align="center"><%=WI.getStrValue(strGradeCGH, "&nbsp;")%></td>
    <%}if (strSchCode.startsWith("AUF") && vGradeDetail.elementAt(i) == null) {//units taken%>
    <td valign="top" class="thinborder" align="center"><%=dUnitEnrolled%></td>
    <%} if (!strSchCode.startsWith("CPU") &&  !strSchCode.startsWith("UDMC") && !bolIsDBTC && !strSchCode.startsWith("UL")){%>
    <td valign="top" class="thinborder"><div align="center">
      <%
	//it is re-exam if student has INC and cleared in same semester,
	strTemp = null;
	if(vGradeDetail.size() > (i + 5 + 8) && vGradeDetail.elementAt(i + 5) != null && ((String)vGradeDetail.elementAt(i + 5)).toLowerCase().indexOf("inc") != -1 &&
		((String)vGradeDetail.elementAt(i + 1)).compareTo((String)vGradeDetail.elementAt(i + 1 + 8)) == 0 ){ //sub code,
			strTemp = (String)vGradeDetail.elementAt(i + 3 + 8);
			
			
			///for auf, i have to determine the units as per remarks.
			if(bolIsAUF){
				dINC -= dUnitEnrolled;//subject is no longer INC.
					
				strRemark = WI.getStrValue((String)vGradeDetail.elementAt(i+6), "").toLowerCase();
				if(strRemark.startsWith("pass") || strRemark.startsWith("cont"))
					dPassed += dUnitEnrolled;
				else if(strRemark.startsWith("fail"))
					dFailed += dUnitEnrolled;
				else if(strRemark.startsWith("dropped") || strRemark.startsWith("wp"))
					dDropped += dUnitEnrolled;
				else if(strRemark.startsWith("incomplete"))
					dINC += dUnitEnrolled;
				else 
					dOther += dUnitEnrolled;
			}

			
			
			
			
		%>
      <%=CommonUtil.formatFloat((String)vGradeDetail.elementAt(i + 5 + 8),true)%>
      <%i += 8;}%>
      &nbsp; </div></td>
    <% } // remove for cpu

// force strTemp = null  for CPU, UDMC or CGH -- it must be set to null for the schools want to remove re-exam.
if (strSchCode.startsWith("CPU") || strSchCode.startsWith("UDMC") || bolIsCGH || bolIsDBTC || strSchCode.startsWith("UL"))
	strTemp= null;

if(vGradeDetail.elementAt(i) != null) {%>
    <td valign="top" class="thinborder"><div align="center">
      <%if(strTemp != null) {%>
      <%=strTemp%>
      <%}else{
			try {
				dTotalUnits += Double.parseDouble(WI.getStrValue((String)vGradeDetail.elementAt(i + 3),"0"));
			}catch(Exception e){}

strGradeValue = WI.getStrValue((String)vGradeDetail.elementAt(i + 3),"0");
//if(bolIsCGH && strGradeValue != null && strGradeValue.endsWith(".0"))
//	strGradeValue = strGradeValue.substring(0, strGradeValue.length() - 2);

//if(bolPutParanthesis)
//	strGradeValue = "(3.0)";
		%>
      <%=strGradeValue%>
      <%}%>
    </div></td>
    <%if(bolIsAUF) {%>
    <td valign="top" class="thinborder" align="center"><%=dUnitEnrolled%></td>
    <%} if (!strSchCode.startsWith("CPU") && !bolIsCGH) {%>
    <td valign="top" class="thinborder"><div align="center"><%=WI.getStrValue((String)vGradeDetail.elementAt(i+6), "&nbsp;")%></div></td>
    <% } // remove remarks for cpu
 }
%>
  </tr>
  <% if (strSchCode.startsWith("CPU")) {%>
  <tr>
    <td class="thinborder">&nbsp;</td>
    <td colspan="9" class="thinborder"><%=(String)vGradeDetail.elementAt(i+2)%></td>
  </tr>
  <%
  } // end cpu descriptive title
} // end for loop

if(bolIsDBTC){
%>
  <tr>
    <td class="thinborder" colspan="4" align="right">Total Units Earned &nbsp;</td>
    <td class="thinborder" align="center"><%=dTotalUnits%></td>
    <td class="thinborder">&nbsp;</td>
  </tr>
  <%}
if(strSchCode.startsWith("UDMC")) {%>
  <tr>
    <td height="20" colspan="6" align="center" class="thinborder"> Note: Issued
      for re-enrollment purposes only </td>
  </tr>
  <%}else if(bolIsCGH){%>
  <tr>
    <td height="20" colspan="5" align="center" class="thinborder"> ************** NOTHING FOLLOWS **************</td>
  </tr>
  <%}%>
</table>
<%if (bolIsCGH){%>
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
	<%if (strSchCode.startsWith("AUF") && dTotUnitEnrolled > 0d) {%>
	  <tr>
		<td colspan="10" height="10" >
		Passed: <%=CommonUtil.formatFloat(dPassed * 100d/dTotUnitEnrolled, false)%>% &nbsp;&nbsp;
		Failed: <%=CommonUtil.formatFloat(dFailed * 100d/dTotUnitEnrolled, false)%>% &nbsp;&nbsp;
		Dropped: <%=CommonUtil.formatFloat(dDropped * 100d/dTotUnitEnrolled, false)%>% &nbsp;&nbsp;
		Incomplete: <%=CommonUtil.formatFloat(dINC * 100d/dTotUnitEnrolled, false)%>% &nbsp;&nbsp;
		<%if(dGNY > 0d) {%>
			GNY: <%=CommonUtil.formatFloat(dGNY * 100d/dTotUnitEnrolled, false)%>% &nbsp;&nbsp;
		<%}if(dOther > 0d) {%>
			Others: <%=CommonUtil.formatFloat(dOther * 100d/dTotUnitEnrolled, false)%>% &nbsp;&nbsp;
		<%}%>
		
		
		</td>
	  </tr>
	<%}%>
  <tr>
    <td width="2%" height="33" >&nbsp;</td>
    <td width="47%" height="33" valign="top">
<%if(strSchCode.startsWith("LNU")){%>
      Prepared by : <u>&nbsp;
	  <%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%>
      &nbsp;</u>
<%}else if(!strSchCode.startsWith("DBTC") && !strSchCode.startsWith("UB")){%>
	NOTE:
<%}%></td>
<%if(bolIsAUF){%>
    <td width="25%" valign="top" align="center">&nbsp;</td>
<%}%>
    <td width="<%if(bolIsAUF){%>25<%}else{%>51<%}%>%" valign="top" align="center">CERTIFIED CORRECT:</td>
  </tr>
  <tr>
    <td  height="20" >&nbsp;</td>
    <td height="20" valign="top" >
<%if(strSchCode.startsWith("LNU")){%>
      NOTE : A student is given 100 days to complete incomplete grades counted
      from the date of final examination.
<%}else if(!strSchCode.startsWith("DBTC") && !strSchCode.startsWith("UB")){
	if(strSchCode.startsWith("VMU")){%>
	Incomplete grades must be completed within a month,
	<%}else{%>
	Inc grades must be completed within a year,
	<%}%><br>otherwise they become <%if(strSchCode.startsWith("CSA")){%>No Credit<%}else{%>failure<%}%>
<%}%>    </td>
<%if(bolIsAUF){%>
    <td align="center">iiooiio</td>
    <%}%>
    <td height="20" align="center">
<%if (!bolIsAUF) {%>
	<strong><%=CommonUtil.getNameForAMemberType(dbOP,"University Registrar",1)%></strong><br>
	<%=WI.getStrValue(CommonUtil.getRegistrarLabel(dbOP))%>
	<%if(false){%>University Registrar<%}%>

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
    <td width="25%" valign="top" ><font size="1">&nbsp;Total No. of Units:__<u><strong><%=dTotalUnits%></strong></u>__<br>
      &nbsp;Weighted Average:__<u>
      <%if(WI.fillTextValue("show_gwa").equals("1") && dGWA > 0d
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


if(strSchCode.startsWith("DBTC")){%>
<script src="../../../jscript/common.js"></script>
<script language="JavaScript">
//get this from common.js
this.autoPrint();

this.closeWnd = 1;
</script>
<%}%>
</body>
</html>
