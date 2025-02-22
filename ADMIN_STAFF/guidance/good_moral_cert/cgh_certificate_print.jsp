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
      <td height="25" colspan="4">To Whom It May Concern :</td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
	</table>
	<!-- this is for one semester only -->
<%if(strPrintCon.equals("0")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4">This is to certify that <%if(strGender.equals("m")){%>Mr.<%}else{%>Ms.<%}%>
        <strong><u><i><%=CommonUtil.getName(dbOP,strStudID,1)%></i></u></strong> is a student of  Chinese General Hospital Colleges
		under the program of  <%=strCourseName%>
		 in the <%=astrConvertSem[Integer.parseInt(strEntrySem)]%> of
		AY <%=strEntrySYFrom%> - <%=Integer.parseInt(strEntrySYFrom) + 1%>.</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">
	  	<%if(bolIsOffense){%>
		During <%if(strGender.equals("m")){%>his<%}else{%>her<%}%> stay in the
        College, the above named student did not commit any <%if(bolIsMinorOffense){%>minor<%}else{%>major<%}%> offense that
        would necessitate disciplinary sanction.
		<%}else{%>
		This certifies further that
        <%if(strGender.equals("m")){%>he<%}else{%>she<%}%> is a person of good moral character. &nbsp;As a student of this College,
        <%if(strGender.equals("m")){%>he<%}else{%>she<%}%> never committed any offense which would subject <%if(strGender.equals("m")){%>him<%}else{%>her<%}%> to any
        disciplinary measure.
		<%}%>
	  </td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
<%
String strCertPurpose =  WI.fillTextValue("cert_purpose");
if(WI.fillTextValue("cert_purpose").length() ==  0)  {
	if(strGender.equals("m"))
		strCertPurpose += " his";
	else 
		strCertPurpose += " her";
	strCertPurpose += " transfer credentials";
}
  
%>  
	<tr>
      <td height="30" colspan="4">This certification is issued
        <%=strCertPurpose%>.</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">Issued this <%=strTodaysDate%>.</td>
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
	</table>
<%}else if(strPrintCon.equals("1")){%>
	<!-- this is for transferee with offense -->
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4">This is to certify that <%if(strGender.equals("m")){%>Mr.<%}else{%>Ms.<%}%>
        <strong><u><i><%=CommonUtil.getName(dbOP,strStudID,1)%></i></u></strong> is a student of Chinese General Hospital Colleges under the program of  <%=strCourseName%> 
		<%if(strLastSYFrom.equals(strEntrySYFrom) && strLastSem.equals(strEntrySem)){%>
		in the <%=astrConvertSem[Integer.parseInt(strEntrySem)]%> of AY <%=strEntrySYFrom%> - <%=Integer.parseInt(strEntrySYFrom) + 1%>.
		<%}else{%>
		from
		<%=astrConvertSem[Integer.parseInt(strEntrySem)]%> of AY <%=strEntrySYFrom%> - <%=Integer.parseInt(strEntrySYFrom) + 1%> to
		<%=astrConvertSem[Integer.parseInt(strLastSem)]%> of AY <%=strLastSYFrom%> - <%=Integer.parseInt(strLastSYFrom) + 1%>.
		<%}%>
		
		</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">
	  <%if(bolIsOffense) {%>
	  	As a student of this College,
      	<%if(strGender.equals("m")){%>he<%}else{%>she<%}%> has not commit any <%if(bolIsMinorOffense){%>minor<%}else{%>major<%}%> offense 
		which would subject <%if(strGender.equals("m")){%>him<%}else{%>her<%}%> to any disciplinary measure.
	  <%}else{%>
		This certifies further that
        <%if(strGender.equals("m")){%>he<%}else{%>she<%}%> is a person of good moral character. &nbsp;As a student of this College,
        <%if(strGender.equals("m")){%>he<%}else{%>she<%}%> never committed any offense which would subject <%if(strGender.equals("m")){%>him<%}else{%>her<%}%> to any
        disciplinary measure.
	  <%}%>
	  </td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">This certification is issued
        upon the request of the student as part of <%if(strGender.equals("m")){%>his<%}else{%>her<%}%> transfer credentials.</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">Issued this <%=strTodaysDate%>.</td>
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
	</table>
	<!--this is for transferee without offense
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4">This is to certify that Mr./Ms.
        <strong><u>$student_name</u></strong>, was a student of Chinese General Hospital Colleges from $term of SY $SY to $term
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
        <strong><u><i><%=CommonUtil.getName(dbOP,strStudID,1).toUpperCase()%></i></u></strong> is a graduate of Chinese General Hospital Colleges <label id="_1" onClick="updateLable('_1')">Batch <%//=strLastSYFrom%><%=Integer.parseInt(strLastSYFrom) + 1%></label>, with the degree of <%=strCourseName%>.</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">
	  <%if(bolIsOffense){%>
	  	As a student of this College,
      	<%if(strGender.equals("m")){%>he<%}else{%>she<%}%> has not commit any <%if(bolIsMinorOffense){%>minor<%}else{%>major<%}%> offense 
		which would subject <%if(strGender.equals("m")){%>him<%}else{%>her<%}%> to any disciplinary measure.

	  	<!--
		During <%if(strGender.equals("m")){%>his<%}else{%>her<%}%> stay in the
       	College, the above named student did not commit any <%if(bolIsMinorOffense){%>minor<%}else{%>major<%}%> offense that
        would necessitate disciplinary sanction.
		-->
	  <%}else{%>
		This certifies further that
        <%if(strGender.equals("m")){%>he<%}else{%>she<%}%> is a person of good moral character. &nbsp;During <%if(strGender.equals("m")){%>his<%}else{%>her<%}%> stay in the
        College, the above named student did not commit any offense that would
        necessitate disciplinary sanction.
	  <%}%>
	  </td>
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
      <td height="30" colspan="4">Issued this <%=strTodaysDate%>.</td>
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
	</table>
<%}else if(strPrintCon.equals("3")){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4">This is to certify that <%if(strGender.equals("m")){%>Mr.<%}else{%>Ms.<%}%>
        <strong><u><i><%=CommonUtil.getName(dbOP,strStudID,1).toUpperCase()%></i></u></strong> is a graduate of Chinese General Hospital Colleges <label id="_1" onClick="updateLable('_1')">Batch <%//=strLastSYFrom%><%=Integer.parseInt(strLastSYFrom) + 1%></label>, with the
        degree of <%=strCourseName%>.</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">
		<%if(!bolIsOffense){%>This further certifies that
        <%if(strGender.equals("m")){%>he<%}else{%>she<%}%> is a person of good moral character. &nbsp;<%}%>During <%if(strGender.equals("m")){%>his<%}else{%>her<%}%> stay in the
        College, the above named student did not commit any <%if(bolIsOffense){if(bolIsMinorOffense){%>minor<%}else{%>major<%}}%> offense that would
        necessitate disciplinary sanction.
	  </td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">This certification is issued
        for employment purposes only.</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">Issued this <%=strTodaysDate%>.</td>
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
	</table>
<%}//end of print con.. 

String strSignatoryName = WI.getStrValue(WI.fillTextValue("signatory_name"),"EDGAR S. CHUNG, MSPH");
String strSignatoryPos  =  WI.getStrValue(WI.fillTextValue("signatory_pos"),"Student Affairs Officer");

%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="30" colspan="4" style="font-size:16px;"><strong><%=strSignatoryName%></strong></td>
    </tr>
    <tr>
      <td height="30" colspan="4" valign="top"><%=strSignatoryPos%></td>
    </tr>
  </table>
</form>  
</body>
</html>
<%
dbOP.cleanUP();
%>
