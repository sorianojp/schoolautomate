<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
body {
	font-family: Geneva, Arial, Helvetica, sans-serif;
	font-size:16px;
	text-align:justify
}
    td {
		font-family: Geneva, Arial, Helvetica, sans-serif;
		font-size:16px;
		text-align:justify
    }

    th {
		font-family: Geneva, Arial, Helvetica, sans-serif;
		font-size:16px;
		text-align:justify
    }
</style>
<script language="javascript">
function updateLable(strLabelID) {
	var labelID = document.getElementById(strLabelID);
	if(!labelID)
		return;
	strNewVal = prompt("Please enter new value",labelID.innerHTML);
	if(strNewVal == null || strNewVal.length == 0) 
		return;
	labelID.innerHTML = strNewVal;
}
</script>
</head>
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


boolean bolIsOffense  = false; boolean bolIsMinorOffense = false;
if(WI.fillTextValue("offense_stat").equals("1"))
	bolIsOffense = true;
if(WI.fillTextValue("offense_stat").equals("2")) {
	bolIsMinorOffense = true;
	bolIsOffense = true;
}

String strPrintCon    = WI.fillTextValue("print_con");

if(strStudID.length() > 0) {
	strSQLQuery = "select course_offered.course_code,major_name,sy_from,semester,course_name,year_level from stud_curriculum_hist "+
		"join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
		"left join major on (major.major_index = stud_curriculum_hist.major_index) "+
		"join semester_sequence on (semester_val = semester)"+
		" where stud_curriculum_hist.is_valid = 1 and stud_curriculum_hist.user_index = "+strStudIndex+
		" order by sy_from desc, sem_order desc";
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

String strTodaysDate = WI.getTodaysDate(14);
int iIndexOf = strTodaysDate.indexOf("of");
strTodaysDate = strTodaysDate.substring(0,iIndexOf - 1) + " day "+strTodaysDate.substring(iIndexOf);
%>
<body onLoad="window.print();" leftmargin="40" rightmargin="40">
<form name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="44" colspan="4" valign="bottom"><div align="center"><font color="#000000" size="2" face="Verdana, Arial, Helvetica, sans-serif">
          <font style="font-size:19px">C E R T I F I C A T I O N</font><br>
          </font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="4"><%=WI.fillTextValue("date_")%></td>
    </tr>
    <tr>
      <td height="40" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="4">To Whom It May Concern :</td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4">This is to certify that <%if(strGender.equals("m")){%>Mr.<%}else{%>Ms.<%}%>
        <strong><u><i><%=CommonUtil.getName(dbOP,strStudID,1).toUpperCase()%></i></u></strong>, is a graduate of Chinese General Hospital Colleges <label id="_1" onClick="updateLable('_1')">Batch 
        <%//=strLastSYFrom%><%=Integer.parseInt(strLastSYFrom) + 1%></label>, with the
        degree of <%=strCourseName%>.</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">
	  <%if(strGender.equals("m")){%>He<%}else{%>She<%}%> ranks <u><%=WI.fillTextValue("rank_")%></u>
	  among the <u><%=WI.fillTextValue("graduate")%></u> graduates. <%if(strGender.equals("m")){%>His<%}else{%>Her<%}%> general weighted average is 
	  <u><%=WI.fillTextValue("gwa_rank")%></u>.	  </td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">This certification is being issued upon the request of <%if(strGender.equals("m")){%>Mr.<%}else{%>Ms.<%}%> 
	  <%=CommonUtil.getName(dbOP,strStudID,10).toUpperCase()%> for <label id="_ref" onClick="updateLable('_ref')">reference</label> purposes only.</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">
	  	<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<tr style="font-weight:bold">
				<td style="font-size:9px;" width="12%">Percentage</td>
				<td style="font-size:9px;" width="12%">Quality Point</td>
				<td style="font-size:9px;" width="12%">Description</td>
				<td style="font-size:9px;" width="12%">Percentage</td>
				<td style="font-size:9px;" width="12%">Quality Point</td>
				<td style="font-size:9px;" width="12%">Description</td>
				<td></td>
			</tr>
			<tr>
			  <td style="font-size:9px;">98-100</td>
			  <td style="font-size:9px;">1.00</td>
			  <td style="font-size:9px;">Excellent</td>
			  <td style="font-size:9px;">83-85</td>
			  <td style="font-size:9px;">2.25</td>
			  <td style="font-size:9px;">Good</td>
			  <td style="font-size:9px;">INC – Incomplete</td>
		  </tr>
			<tr>
			  <td style="font-size:9px;">95-97</td>
			  <td style="font-size:9px;">1.25</td>
			  <td style="font-size:9px;">Outstanding</td>
			  <td style="font-size:9px;">80-82</td>
			  <td style="font-size:9px;">2.50</td>
			  <td style="font-size:9px;">Satisfactory</td>
			  <td style="font-size:9px;">AW – Authorized Withdrawal</td>
		  </tr>
			<tr>
			  <td style="font-size:9px;">92-94</td>
			  <td style="font-size:9px;">1.50</td>
			  <td style="font-size:9px;">Very Good</td>
			  <td style="font-size:9px;">77-79</td>
			  <td style="font-size:9px;">2.75</td>
			  <td style="font-size:9px;">Satisfactory</td>
			  <td style="font-size:9px;">FA  – Failure due to Absences</td>
		  </tr>
			<tr>
			  <td style="font-size:9px;">89-91</td>
			  <td style="font-size:9px;">1.75</td>
			  <td style="font-size:9px;">Very Good</td>
			  <td style="font-size:9px;">75-76</td>
			  <td style="font-size:9px;">3.00</td>
			  <td style="font-size:9px;">Passed</td>
			  <td style="font-size:9px;"></td>
		  </tr>
			<tr>
			  <td style="font-size:9px;">86-88</td>
			  <td style="font-size:9px;">2.00</td>
			  <td style="font-size:9px;">Good</td>
			  <td style="font-size:9px;">0-74</td>
			  <td style="font-size:9px;">5.00</td>
			  <td style="font-size:9px;">Failed</td>
			  <td style="font-size:9px;"></td>
		  </tr>
		</table> 
	  
	  
	  </td>
    </tr>
    <tr>
      <td height="30" colspan="4">&nbsp;</td>
    </tr>
	</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="30" colspan="4" valign="top">
	  <label id="_10" onClick="updateLable('_10')"><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)).toUpperCase()%></label><br>
<label id="_11" onClick="updateLable('_11')">College Registrar</label>
</td>
    </tr>
  </table>
</form>  
</body>
</html>
<%
dbOP.cleanUP();
%>
