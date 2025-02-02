<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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

double dGWA = Double.parseDouble(WI.getStrValue(WI.fillTextValue("gwa"), "0"));

int iRowNumber = 0;
if(dGWA == 1d)
	iRowNumber = 1;
else if(dGWA > 1d && dGWA <= 1.25d)
	iRowNumber = 2;
else if(dGWA > 1.25d && dGWA <= 1.5d)
	iRowNumber = 3;
else if(dGWA > 1.5d && dGWA <= 1.75d)
	iRowNumber = 4;
else if(dGWA > 1.75d && dGWA <= 2d)
	iRowNumber = 5;
else if(dGWA > 2d && dGWA <= 2.25d)
	iRowNumber = 6;
else if(dGWA > 2.25d && dGWA <= 2.5d)
	iRowNumber = 7;
else if(dGWA > 2.5d && dGWA <= 2.75d)
	iRowNumber = 8;
else if(dGWA > 2.75d)
	iRowNumber = 9;

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
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="4">To Whom it May Concern :</td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4">
	  This is to certify that 
	    <%if(strGender.equals("m")){%>Mr.<%}else{%>Ms.<%}%> <%=CommonUtil.getName(dbOP,strStudID,1).toUpperCase()%> is a graduate of 
	  <%=strCourseName%> program, <label id="_1" onClick="updateLable('_1')">Class <%=Integer.parseInt(strLastSYFrom) + 1%></label>. <%if(strGender.equals("m")){%>His<%}else{%>Her<%}%> scholastic performance was

	  
	 </td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">
		  <table width="100%" cellpadding="0" cellspacing="0">
		  	<tr>
				<td><center>Description</center></td>
				<td><center>
				  Numerical Grade Range	
				</center></td>
				<td><center>
				  General Weighted Average
				</center></td>
			</tr>
		  	<tr>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			</tr>
		  	<tr>
		  	  <td height="25" <%if(iRowNumber == 1){%>class="thinborderTOPLEFTBOTTOM" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"<%}%>><center>Excellent</center></td>
		  	  <td <%if(iRowNumber == 1){%>class="thinborderTOPBOTTOM" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"<%}%>><center>1.00</center></td>
		  	  <td <%if(iRowNumber == 1){%>class="thinborderTOPBOTTOMRIGHT" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"><center><%=CommonUtil.formatFloat(dGWA,true)%></center><%}%></td>
	  	    </tr>
		  	<tr>
		  	  <td height="25" <%if(iRowNumber == 2){%>class="thinborderTOPLEFTBOTTOM" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"<%}%>><center>Outstanding</center></td>
		  	  <td <%if(iRowNumber == 2){%>class="thinborderTOPBOTTOM" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"<%}%>><center>
		  	    1.01 - 1.25
		  	  </center></td>
		  	  <td <%if(iRowNumber == 2){%>class="thinborderTOPBOTTOMRIGHT" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"><center><%=CommonUtil.formatFloat(dGWA,true)%></center><%}%></td>
	  	    </tr>
		  	<tr>
		  	  <td height="25" <%if(iRowNumber == 3){%>class="thinborderTOPLEFTBOTTOM" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"<%}%>><center>Outstanding</center></td>
		  	  <td <%if(iRowNumber == 3){%>class="thinborderTOPBOTTOM" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"<%}%>><center>
		  	    1.26 - 1.50
		  	  </center></td>
		  	  <td <%if(iRowNumber == 3){%>class="thinborderTOPBOTTOMRIGHT" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"><center><%=CommonUtil.formatFloat(dGWA,true)%></center><%}%></td>
	  	    </tr>
		  	<tr>
		  	  <td height="25" <%if(iRowNumber == 4){%>class="thinborderTOPLEFTBOTTOM" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"<%}%>><center>Very Good</center></td>
		  	  <td <%if(iRowNumber == 4){%>class="thinborderTOPBOTTOM" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"<%}%>><center>
		  	    1.51 - 1.75
		  	  </center></td>
		  	  <td <%if(iRowNumber == 4){%>class="thinborderTOPBOTTOMRIGHT" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"><center><%=CommonUtil.formatFloat(dGWA,true)%></center><%}%></td>
	  	    </tr>
		  	<tr>
		  	  <td height="25" <%if(iRowNumber == 5){%>class="thinborderTOPLEFTBOTTOM" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"<%}%>><center>Very Good</center></td>
		  	  <td <%if(iRowNumber == 5){%>class="thinborderTOPBOTTOM" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"<%}%>><center>
		  	    1.76 - 2.00
		  	  </center></td>
		  	  <td <%if(iRowNumber == 5){%>class="thinborderTOPBOTTOMRIGHT" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"><center><%=CommonUtil.formatFloat(dGWA,true)%></center><%}%></td>
	  	    </tr>
		  	<tr>
		  	  <td height="25" <%if(iRowNumber == 6){%>class="thinborderTOPLEFTBOTTOM" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"<%}%>><center>Good</center></td>
		  	  <td <%if(iRowNumber == 6){%>class="thinborderTOPBOTTOM" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"<%}%>><center>
		  	    2.01 - 2.25
		  	  </center></td>
		  	  <td <%if(iRowNumber == 6){%>class="thinborderTOPBOTTOMRIGHT" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"><center><%=CommonUtil.formatFloat(dGWA,true)%></center><%}%></td>
	  	    </tr>
		  	<tr>
		  	  <td height="25" <%if(iRowNumber == 7){%>class="thinborderTOPLEFTBOTTOM" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"<%}%>><center>Good</center></td>
		  	  <td <%if(iRowNumber == 7){%>class="thinborderTOPBOTTOM" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"<%}%>><center>
		  	    2.26 - 2.50
		  	  </center></td>
		  	  <td <%if(iRowNumber == 7){%>class="thinborderTOPBOTTOMRIGHT" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"><center><%=CommonUtil.formatFloat(dGWA,true)%></center><%}%></td>
	  	    </tr>
		  	<tr>
		  	  <td height="25" <%if(iRowNumber == 8){%>class="thinborderTOPLEFTBOTTOM" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"<%}%>><center>Adequate</center></td>
		  	  <td <%if(iRowNumber == 8){%>class="thinborderTOPBOTTOM" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"<%}%>><center>
		  	    2.51 - 2.75
		  	  </center></td>
		  	  <td <%if(iRowNumber == 8){%>class="thinborderTOPBOTTOMRIGHT" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"><center><%=CommonUtil.formatFloat(dGWA,true)%></center><%}%></td>
	  	    </tr>
		  	<tr>
		  	  <td height="25" <%if(iRowNumber == 9){%>class="thinborderTOPLEFTBOTTOM" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"<%}%>><center>Adequate</center></td>
		  	  <td <%if(iRowNumber == 9){%>class="thinborderTOPBOTTOM" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"<%}%>><center>
		  	    2.76 - 3.00
		  	  </center></td>
		  	  <td <%if(iRowNumber == 9){%>class="thinborderTOPBOTTOMRIGHT" style="font-size:16px;font-family: Geneva, Arial, Helvetica, sans-serif;"><center><%=CommonUtil.formatFloat(dGWA,true)%></center><%}%></td>
	  	    </tr>
	  	  </table>
	  </td>
    </tr>
    <tr>
      <td height="30" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">
	  With the foundation that <%if(strGender.equals("m")){%>he<%}else{%>she<%}%> developed through our nursing program, we believe that 
	    <%if(strGender.equals("m")){%>Mr.<%}else{%>Ms.<%}%> <%=CommonUtil.getName(dbOP,strStudID,1).toUpperCase()%> 
	  can be an asset to your institution.  We are confident that <%if(strGender.equals("m")){%>his<%}else{%>her<%}%> potentials can be realized to the fullest 
	  in your good institution.
</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4" align="right" valign="top">Yours truly,&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br><br><br>&nbsp;</td>
    </tr>
	</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="30" colspan="4">
	  <%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)).toUpperCase()%>
	  <br>
	  College Registrar
	</td>
    </tr>
  </table>
</form>  
</body>
</html>
<%
dbOP.cleanUP();
%>
