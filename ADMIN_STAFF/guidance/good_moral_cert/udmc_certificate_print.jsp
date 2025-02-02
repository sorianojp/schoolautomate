<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript">
function ChangeInfo(strLabelID) {

	var strNewInfo = prompt('Please enter new Value.',document.getElementById(strLabelID).innerHTML);
	if(strNewInfo == null || strNewInfo.legth == 0)
		return;
	document.getElementById(strLabelID).innerHTML = strNewInfo;
}
var strLabelValOrig = null;
function ChangeFontFormat(strMouseStat, strLabelID) {
	var strLabelVal = document.getElementById(strLabelID).innerHTML;
	if(strLabelValOrig == null)
		strLabelValOrig = strLabelVal;
	if(strMouseStat == 1)
		strLabelVal = "<font style='color:blue;'>"+strLabelVal+"</font>";
	else {
		strLabelVal = strLabelValOrig;
		strLabelValOrig = null;
	}
	document.getElementById(strLabelID).innerHTML = strLabelVal;
}
</script>
<%@ page language="java" import="utility.*,osaGuidance.GDStudReferralFollowUp,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try	{
		dbOP = new DBOperation();
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

String strStudID      = WI.fillTextValue("stud_id");
String strStudIndex   = dbOP.mapUIDToUIndex(strStudID);
String strSQLQuery    = null;

java.sql.ResultSet rs = null;

//Student Info..
String strGender      = null;//M = male, F = female.
String strCourseName  = null;//Bachelor of Science in Nursing (BSN) -> format.
String strLastSYFrom  = null;
String strLastSem     = null;

String strEntrySYFrom = null;
String strEntrySem    = null;

String strCourseCode = null;
String strYearLevel  = null;


boolean bolIsOffense  = false;
if(WI.fillTextValue("offense_stat").equals("1"))
	bolIsOffense = true;

String strPrintCon    = WI.fillTextValue("print_con");

if(strStudID.length() > 0) {
	strSQLQuery = "select course_offered.course_code,major_name,sy_from,semester,course_name,year_level from stud_curriculum_hist "+
		"join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
		"left join major on (major.major_index = stud_curriculum_hist.major_index) "+
		"join semester_sequence on (semester_val = semester)"+
		" where stud_curriculum_hist.is_valid = 1 and stud_curriculum_hist.user_index = "+strStudIndex+
		" order by sy_from desc, semester desc";
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		if(rs.getString(2) != null)
			strCourseName = rs.getString(5) +" ("+rs.getString(2)+")";
		else
			strCourseName = rs.getString(5)+" ("+rs.getString(1)+")";
		strCourseCode = rs.getString(1);

		strLastSYFrom = rs.getString(3);
		strLastSem    = rs.getString(4);

		strYearLevel  = rs.getString(6);

		rs.close();
		strSQLQuery = "select gender from info_personal where user_index = "+strStudIndex;
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next())
			strGender = rs.getString(1).toLowerCase();
		rs.close();
	//entry sy/term.
		strSQLQuery = "select sy_from,semester from stud_curriculum_hist "+
			"join semester_sequence on (semester_val = semester)"+
			" where stud_curriculum_hist.is_valid = 1 and stud_curriculum_hist.user_index = "+strStudIndex+
			" order by sy_from asc, sem_order asc";
		rs = dbOP.executeQuery(strSQLQuery);
		rs.next();
		strEntrySYFrom = rs.getString(1);
		strEntrySem    = rs.getString(2);
	}
	rs.close();
}

String[] astrConvertSem = {"Summer","First Semester", "Second Semester", "Third Semester"};
%>
<body onLoad="window.print();">
<form>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
<%if(strPrintCon.equals("0")){%>
    <tr>
      <td height="44" colspan="4" valign="bottom"><div align="center"><font style="font-size:14px;">
          <strong>OFFICE OF THE REGISTRAR</strong><br>
          </font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td height="25" colspan="4" align="right"><%=WI.getTodaysDate(6)%>&nbsp;&nbsp;</td>
    </tr>
<%if(strPrintCon.equals("1")){%>
    <tr>
      <td height="44" colspan="4" valign="bottom"><div align="center"><font style="font-size:18px;">
          <strong><u>C E R T I F I C A T I O N</u></strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td height="25" colspan="4" style="font-size:14px; font-weight:bold">TO WHOM IT MAY CONCERN :</td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
</table>
	<!-- this is for one semester only -->
<%if(strPrintCon.equals("0")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4"><p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This is to certify that based on the record kept on file in this Office
          <strong><u><%if(strGender.equals("m")){%>
        Mr.
        <%}else{%>
        Ms.
        <%}%>
        <%=CommonUtil.getName(dbOP,strStudID,1).toUpperCase()%></u></strong> graduated with degree of <%=strCourseName.toUpperCase()%>
		in
		<label onClick="ChangeInfo('L_1');" id="L_1" >&lt; Click to Change - March, 2007 &gt;</label> as per CHED-NCR as per Special Order No.
		<label onClick="ChangeInfo('L_2');" id="L_2">&lt; Enter here Ched sp. Number - (B) 50-501200-0420 &gt;</label>
		dated
		<label onClick="ChangeInfo('L_3');" id="L_3">&lt; Enter Date of CHED order - April 20, 2007 &gt;</label></p>
        </td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">
	  	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This certifies further that
		<%if(strGender.equals("m")){%>
        Mr.
        <%}else{%>
        Ms.
        <%}%><%=CommonUtil.getName(dbOP,strStudID,1)%>
		 is known to me to be of good moral character during her stay in this Institution from
		 <label onClick="ChangeInfo('L_4');" id="L_4"><%=astrConvertSem[Integer.parseInt(strEntrySem)]%> of SY <%=strEntrySYFrom%> - <%=Integer.parseInt(strEntrySYFrom) + 1%> up to the <%=astrConvertSem[Integer.parseInt(strLastSem)]%> of SY <%=strLastSYFrom%> - <%=Integer.parseInt(strLastSYFrom) + 1%>
		 </label>
	  </td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This certification is issued
        upon the request of
        <%if(strGender.equals("m")){%>
		Mr.
		<%}else{%>
		Ms.
		<%}%>
		<%=CommonUtil.getName(dbOP,strStudID,10)%> for whatever legal purposes it may serve.</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">&nbsp;</td>
    </tr>
</table>
<%}else if(strPrintCon.equals("1")){
student.GWA gwa = new student.GWA();
double dGWA = gwa.computeGWAForResidency(dbOP,WI.fillTextValue("stud_id"));
String strGWA = CommonUtil.formatFloat(dGWA,true);
%>
	<!-- this is for transferee with offense -->
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  This is to certify that on the basis of the record kept on file on this Office
	  	<strong><%if(strGender.equals("m")){%>Mr.<%}else{%>Ms.<%}%>
        	<%=CommonUtil.getName(dbOP,strStudID,1).toUpperCase()%></strong> graduated with degree of
		<%=strCourseName.toUpperCase()%>
		in
		<label onClick="ChangeInfo('L_1');" id="L_1" >&lt; Click to Change - March, 2007 &gt;</label> as per CHED-NCR as per Special Order No.
		<label onClick="ChangeInfo('L_2');" id="L_2">&lt; Enter here Ched sp. Number - (B) 50-501200-0420 &gt;</label>
		dated
		<label onClick="ChangeInfo('L_3');" id="L_3">&lt; Enter Date of CHED order - April 20, 2007 &gt;</label>
		. <%if(strGender.equals("m")){%>He<%}else{%>She<%}%> obtained an academic performance of "<label onClick="ChangeInfo('L_4');" id="L_4"><%=strGWA%></label>" (weighted average).</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
    </tr>
    <tr>
      <td height="30">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This certification is issued
        upon the request of
        <%if(strGender.equals("m")){%>
		Mr.
		<%}else{%>
		Ms.
		<%}%>
		<%=CommonUtil.getName(dbOP,strStudID,10)%> for whatever legal purposes it may serve.	  </td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
    </tr>
	</table>
	<!--this is for transferee without offense
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4">This is to certify that Mr./Ms.
        <strong><u>$student_name</u></strong>, was a student of Chinese General
        Hospital College of Nursing and Liberal Arts from $term of SY $SY to $term
        of SY $SY.</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">This certifies further that
        he/she is a person of good moral character. &nbsp;As a student of this College,
        he/she never committed any offense which would subject him/her to any
        disciplinary measure. </td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">This certification is issued
        upon the request of the student as part of his/her transfer credentials.</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">Issued this $date.</td>
    </tr>
    <tr>
      <td height="30" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">&nbsp;</td>
    </tr>
	</table>-->
		<!-- this is for graduate with offense -->
<%}else if(strPrintCon.equals("2")){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4">This is to certify that <%if(strGender.equals("m")){%>Mr.<%}else{%>Ms.<%}%>
        <strong><u><%=CommonUtil.getName(dbOP,strStudID,1).toUpperCase()%></u></strong>, is a graduate of Chinese General Hospital Colleges batch <%=strLastSYFrom%>, with the
        degree of <%=strCourseName%>.</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">
	  <%if(bolIsOffense){%>
	  	During his/her stay in the
       	College, the above named student did not commit any major offense that
        would necessitate disciplinary sanction.
	  <%}else{%>
		This certifies further that
        he/she is a person of good moral character. &nbsp;During his/her stay in the
        College, the above named student did not commit any offense that would
        necessitate disciplinary sanction.
	  <%}%>	  </td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">This certification is issued
        for whatever purpose it may serve.</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">&nbsp;</td>
    </tr>
	</table>
<!-- this is for graduate w/out offense
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4">This is to certify that Mr./Ms.
        <strong><u>$student_name</u></strong>, is a graduate of Chinese General
        Hospital College of Nursing and Liberal Arts batch $year_grad, with the
        degree of $course ($course_code).</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">This certifies further that
        he/she is a person of good moral character. &nbsp;During his/her stay in the
        College, the above named student did not commit any offense that would
        necessitate disciplinary sanction.</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">This certification is issued
        for whatever purpose it may serve.</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">Issued this $date.</td>
    </tr>
    <tr>
      <td height="30" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">&nbsp;</td>
    </tr>
	</table>-->
<%}//end of print con.. %>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="30">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td width="25%" align="center"><font style="font-size:13px; font-weight:bold">MINDA O. GNILO</font> <br> Registrar</td>
    </tr>
    <tr>
      <td height="30" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4"><strong>NOT VALID WITHOUT COLLEGE SEAL </strong></td>
    </tr>
<%if(strPrintCon.equals("1")){%>
    <tr>
      <td height="30" colspan="4" valign="top" align="center">
	  	<table width="80%" cellpadding="0" cellspacing="0" class="thinborderALL">
			<tr>
				<td colspan="3" align="center" style="font-size:14px; font-weight:bold"> GRADING SYSTEM <br>&nbsp;</td>
			</tr>
			<tr>
				<td width="33%" align="center" style="font-size:12px; font-weight:bold"> DESCRIPTION<br>&nbsp;</td>
				<td width="33%" align="center" style="font-size:12px; font-weight:bold"> PERCENTAGE<br>&nbsp;</td>
				<td align="center" style="font-size:12px; font-weight:bold"> NUMERICAL GRADE<br>&nbsp;</td>
			</tr>
			<tr>
				<td width="33%" align="center"> Excellent </td>
				<td width="33%" align="center">99% - 100%<br>96% - 98%</td>
				<td align="center">1.00<br>1.25</td>
			</tr>
			<tr>
				<td width="33%" align="center"> Very Good </td>
				<td width="33%" align="center">93% - 95%<br>90% - 92%</td>
				<td align="center">1.50<br>1.75</td>
			</tr>
			<tr>
				<td width="33%" align="center"> Good </td>
				<td width="33%" align="center">87% - 89%<br>84% - 86%</td>
				<td align="center">2.00<br>2.25</td>
			</tr>
			<tr>
				<td width="33%" align="center"> Satisfactory </td>
				<td width="33%" align="center">81% - 83%<br>78% - 80%</td>
				<td align="center">2.50<br>2.75</td>
			</tr>
			<tr>
				<td width="33%" align="center"> Passed </td>
				<td width="33%" align="center">75% - 77% </td>
				<td align="center">3.00</td>
			</tr>
		</table>



	  </td>
    </tr>
<%}%>
</table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
