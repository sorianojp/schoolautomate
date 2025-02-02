<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
body {
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size:12px;
	text-align:justify
}
    td {
		font-family: Verdana, Arial, Helvetica, sans-serif;
		font-size:12px;
		text-align:justify
    }

    th {
		font-family: Verdana, Arial, Helvetica, sans-serif;
		font-size:12px;
		text-align:justify
    }
</style>
</head>
<script language="javascript">
function UpdateName() {
	var strName = document.getElementById("multiple_name").innerHTML;
	strName = prompt('Please enter name with <br> for next line',strName);
	if(strName == null || strName.length == 0)
		return;
	document.getElementById("multiple_name").innerHTML = strName;
}
function UpdateTickAndSpace(strLabelID) {
	var labelID = document.getElementById(strLabelID);
	if(!labelID)
		return;
	strLabelVal = labelID.innerHTML;
	if(strLabelVal == '&nbsp;&nbsp;')
		strLabelVal = '&radic;';
	else	
		strLabelVal = '&nbsp;&nbsp;';
		
	labelID.innerHTML = strLabelVal;

}
function GetOthersInfo() {
	var labelID = document.getElementById('_5');
	if(!labelID)
		return;
	strNewVal = prompt("Please enter other certification.");
	if(strNewVal == null || strNewVal.length == 0) 
		return;
	labelID.innerHTML = strNewVal;
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



String strPrintCon    = WI.fillTextValue("print_option");

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
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="44" colspan="4" valign="bottom"><div align="center"><font color="#000000" size="2" face="Verdana, Arial, Helvetica, sans-serif"><br>
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
</table>
	<!-- this is for one semester only -->
<%if(strPrintCon.equals("0")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25">
	  	<pre style="font-family:Verdana, Arial, Helvetica, sans-serif"><b>THE REGISTRAR</b><BR><%=WI.fillTextValue("address_1")%><br><br><br>&nbsp;</pre>
	  </td>
    </tr>
    <tr>
      <td height="30"><p>Dear Sir/Madam:<br>
        <br>
	  This is to respectfully request the following checked item/s </p>
        
		<table width="100%">
		<tr>
			<td width="45%">[<label id="_1" onClick="UpdateTickAndSpace('_1');">&nbsp;&nbsp;</label>] Form 137</td>
			<td width="55%">[<label id="_2" onClick="UpdateTickAndSpace('_2');">&nbsp;&nbsp;</label>] Certificate of Good Moral Character</td>
		<tr>
		<tr>
			<td width="45%">[<label id="_3" onClick="UpdateTickAndSpace('_3');">&nbsp;&nbsp;</label>] Official Transcript of Records</td>
			<td width="55%">[<label id="_4" onClick="UpdateTickAndSpace('_4');">&nbsp;&nbsp;</label>] Others: <u><label id="_5" onClick="GetOthersInfo();">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</label></u></td>
		<tr>
		</table>
        <p>for  the following student/s: 
      </p></td>
    </tr>
    <tr>
      <td height="30"><label id="multiple_name" onClick="UpdateName()"><br><%=CommonUtil.getName(dbOP,strStudID,1)%><br><br><br></label></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
    </tr>
    <tr>
      <td height="30">
	  <pre style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:12px;">Requested document/s will be needed to process application for entry to this institution. 


Your prompt attention to this request will be highly appreciated. Thank you very much.




Respectfully yours,




<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)).toUpperCase()%>
College Registrar

</pre>
	  </td>
    </tr>
	</table>

<table>
<tr><td>Remarks : <br><br>
<%
String strVar1 = "&nbsp;&nbsp;";String strVar2 = "&nbsp;&nbsp;";String strVar3 = "&nbsp;&nbsp;";String strVar4 = "&nbsp;&nbsp;";String strVar5 = "&nbsp;&nbsp;";
String strVar6 = "&nbsp;&nbsp;";
if(WI.fillTextValue("_1").length() > 0) 
	strVar1 = "&radic;";
if(WI.fillTextValue("_2").length() > 0) 
	strVar2 = "&radic;";
if(WI.fillTextValue("_3").length() > 0) 
	strVar3 = "&radic;";
if(WI.fillTextValue("_4").length() > 0) 
	strVar4 = "&radic;";
if(WI.fillTextValue("_5").length() > 0) 
	strVar5 = "&radic;";
if(WI.fillTextValue("_6").length() > 0) 
	strVar6 = "&radic;";
%>
[<%=strVar4%>] First Request<br>
[<%=strVar5%>] Second Request<br>
[<%=strVar6%>] Third Request<br>
<br>

[<%=strVar1%>] Kindly send through mail<br>
[<%=strVar2%>] Please entrust to bearer<br>
[<%=strVar3%>] Kindly indicate copy for: Chinese General Hospital Colleges <br>
</td></tr>
</table>
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>
