<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
	String strTemp = null;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strInfo5 = (String)request.getSession(false).getAttribute("info5");
	if(strSchCode == null)
		strSchCode = "";
	//System.out.println(strSchCode);


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

if(WI.fillTextValue("show_gwa").equals("1")) {
	student.GWA gwa = new student.GWA();
	dGWA = gwa.getGWAForAStud(dbOP,(String)vStudInfo.elementAt(0),
			request.getParameter("sy_from"),request.getParameter("sy_to"),
			request.getParameter("semester"), (String)vStudInfo.elementAt(6),
			(String)vStudInfo.elementAt(7),null);
	//System.out.println(gwa.getErrMsg());

}

double dTotalUnits = 0d;


boolean bolIsCGH = false;
boolean bolIsDBTC = strSchCode.startsWith("DBTC");

boolean bolIsCollegeOnly = false;

/////i have to put parenthesis for math and english enrichment.
Vector vMathEnglEnrichment = null;
boolean bolPutParanthesis = false;
if(vGradeDetail != null) {
	vMathEnglEnrichment = GS.getMathEngEnrichmentInfo(dbOP, request);
}


boolean bolIsFinal = WI.fillTextValue("grade_name").toLowerCase().startsWith("final");
//System.out.println("bolIsFinal : "+bolIsFinal+"  grade_name : "+ WI.fillTextValue("grade_name"));


String strGradeCGH = null;
java.sql.PreparedStatement pstmtGetPercentGrade = dbOP.getPreparedStatement("select grade_cgh from g_sheet_final where gs_index = ?");

boolean bolIsCLDH  = false;
if(!bolIsFinal)
	bolIsCLDH = false;
else
	bolIsCLDH = true;

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

<body onLoad="window.print()" leftmargin="0" rightmargin="0" topmargin="0" bottommargin="0">
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
    <tr >
      <td height="20" colspan="6"><div align="center"><font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
<%
if(!strSchCode.startsWith("CLDH")){
	if (!strSchCode.startsWith("UDMC") && !bolIsCGH){%>
			  <font size="2"><strong>
			  <%if (strSchCode.startsWith("AUF")){%>
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
			<%if(!strSchCode.startsWith("CLDH")){%><%=request.getParameter("grade_for").toUpperCase()%><%}%></strong> GRADES FOR <strong><%=request.getParameter("sem_name").toUpperCase()%></strong>
			<strong>, AY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></strong>
		<%}%>
        <br>
         </div></td>
    </tr>
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
    <td width="15%" height="20" align="center" class="thinborder"><font size="1"><strong>
		<%=strTemp%></strong></font></td>
    <% if (!strSchCode.startsWith("CPU")) {%>
    <td width="30%" align="center" class="thinborder"><font size="1"><strong>
	<%if(bolIsCGH || bolIsDBTC){%>DESCRIPTIVE TITLE <%}else{%>SUBJECT NAME/DESCRIPTION<%}%></strong></font></td>
    <%} //  end remove td
 if (strSchCode.startsWith("CPU")) {
	 		strTemp = "TEACHER";  %>
    <td width="14%" align="center" class="thinborder"><font size="1"><strong>
      DAY / TIME </strong></font></td>
    <td width="9%" align="center" class="thinborder"><font size="1"><strong>
      ROOM </strong></font></td>
<%}else {
			strTemp = "INSTRUCTOR";
}%>

<%if(!bolIsCGH){%>
    <td width="16%" align="center" class="thinborder"><font size="1"><strong><%=strTemp%></strong></font></td>
<%}%>
    <td width="6%" align="center" class="thinborder"><font size="1"><strong>GRADE
    </strong></font></td>
    <%if(bolIsCLDH){%>
    <td width="6%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">AVERAGE GRADE  </td>
    <%} if (!strSchCode.startsWith("CPU") && !strSchCode.startsWith("UDMC") && !bolIsDBTC && !strSchCode.startsWith("UL")) {%>
    <td width="7%" align="center" class="thinborder"><font size="1"><strong>
    RE-EXAM</strong></font></td>
    <%}%>
    <td width="6%" align="center" class="thinborder"><font size="1"><strong><%if(bolIsCGH){%>CREDIT UNITS<%}else{%>CREDITS<%}%></strong></font></td>
    <% if (!strSchCode.startsWith("CPU") && !bolIsCGH) {%>
    <td width="9%" align="center" class="thinborder"><font size="1"><strong>REMARKS</strong></font></td>
    <% }%>
  </tr>
  <%
   int iSubjCount = 0;
   int iRowSize = 8;
   int k = 0;

   if (bolIncludeSchedule)
   		iRowSize =9;
   Vector vScheduleDetails = null;

String strGradeValue = null;
String strSubCode    = null; //System.out.println(vGradeDetail);
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
			//System.out.println(dGrade);
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

if(vGradeDetail.elementAt(i) != null) {
	pstmtGetPercentGrade.setInt(1, Integer.parseInt((String)vGradeDetail.elementAt(i)));
	java.sql.ResultSet rs = pstmtGetPercentGrade.executeQuery();
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
    <%if (strSchCode.startsWith("CPU")) {%>
    <td valign="top" class="thinborder"> <%=iSubjCount%></td>
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
if(bolIsCGH && strGradeValue != null && (strGradeValue.endsWith(".0") || strGradeValue.length() == 3) && strGradeValue.indexOf(".") > -1)
	strGradeValue = strGradeValue+"0";
	if(bolPutParanthesis && !strGradeValue.startsWith("Grade"))
		strGradeValue = "("+strGradeValue+")";
%>
    <td valign="top" class="thinborder"<%=strTemp%>><div align="center"><%=strGradeValue%></div></td>
    <td valign="top" class="thinborder" align="center"><%=WI.getStrValue(strGradeCGH, "&nbsp;")%></td>
<% if (!strSchCode.startsWith("CPU") &&  !strSchCode.startsWith("UDMC") && !bolIsDBTC && !strSchCode.startsWith("UL")){%>
    <td valign="top" class="thinborder"><div align="center">
      <%
	//it is re-exam if student has INC and cleared in same semester,
	strTemp = null;
	if(vGradeDetail.size() > (i + 5 + 8) && vGradeDetail.elementAt(i + 5) != null && ((String)vGradeDetail.elementAt(i + 5)).toLowerCase().indexOf("inc") != -1 &&
		((String)vGradeDetail.elementAt(i + 1)).compareTo((String)vGradeDetail.elementAt(i + 1 + 8)) == 0 ){ //sub code,
			strTemp = (String)vGradeDetail.elementAt(i + 3 + 8);
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
    <% if (!strSchCode.startsWith("CPU") && !bolIsCGH) {%>
    <td valign="top" class="thinborder"><div align="center"><%=(String)vGradeDetail.elementAt(i+6)%></div></td>
    <% } // remove remarks for cpu
 }
%>
  </tr>
  <%
} // end for loop
%>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="50%" height="42" valign="bottom">NOTE: </td>
    <td width="8%" height="42" valign="top">&nbsp;</td>
    <td width="42%" valign="bottom">Certified Correct: </td>
  </tr>
  <tr>
    <td  height="20" valign="top">Inc grades must be completed within a year, <br>otherwise they become failure</td>
    <td height="20" valign="top" >&nbsp;</td>
    <td width="42%" height="20" align="center">
	<strong><%=CommonUtil.getNameForAMemberType(dbOP,"University Registrar",1)%></strong><br>
			<%=WI.getStrValue(CommonUtil.getRegistrarLabel(dbOP))%>
	</td>
  </tr>
</table>

<%}//only if vStudInfo and vGradeDetail are not null
dbOP.cleanUP();
%>
</body>
</html>
