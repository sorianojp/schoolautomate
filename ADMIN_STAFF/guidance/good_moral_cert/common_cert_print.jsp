<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode.startsWith("UB")){%>
	<jsp:forward page="./ub_certificate_print.jsp" />

<%}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
String strYrLevel  = null;


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

		strYrLevel    = rs.getString(6);

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
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="2" align="center">
	  	
		<table width="100%" cellpadding="0" cellspacing="0">
	  		<tr>
				<td width="10%"><img src="../../../images/logo/PIT_LEYTE.gif" width="75" height="75"></td>
				<td width="90%" align="center" valign="top">
					  <p>
						<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>			  
						  <br>
						  <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
					  </p>
			  </td>
			</tr>
		</table>
		
        </td>
    </tr>
    <tr>
      <td height="24" colspan="2"><div align="center"></div>
        <div align="left"></div></td>
    </tr>
    <tr>
      <td height="25" colspan="2"><div align="right"><%=WI.fillTextValue("date_requested")%></div></td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2" style="font-size:22px;"><div align="center"><strong>C E R T I F I C A T I O N</strong></div></td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2" style="font-size:13px;">To Whom This May Concern:</td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="59" colspan="2" align="justify" style="font-size:13px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        This
        is to certify that
          <%if(strGender.equals("m")){%>
          Mr.
          <%}else{%>
          Ms.
          <%}%>
          <%=CommonUtil.getName(dbOP,strStudID,1).toUpperCase()%> is a
		  <%=strCourseCode%><%=WI.getStrValue(strYrLevel, " - ", "","")%>
        student of <%=SchoolInformation.getSchoolName(dbOP,true,false)%>, SY <%=strLastSYFrom%> - <%=Integer.parseInt(strLastSYFrom) + 1%>. <%if(strGender.equals("m")){%>He<%}else{%>She<%}%> has abided by the
        rules and regulations of the school. Furthermore, <%if(strGender.equals("m")){%>he<%}else{%>she<%}%> has not been involved
        in any conduct unbecoming of <%if(strGender.equals("m")){%>his<%}else{%>her<%}%> stay in the University.</td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2" style="font-size:13px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This
        is issued upon the request of the above-mentioned name for whatever purpose
        it may best serve
        <%if(strGender.equals("m")){%>him<%}else{%>her<%}%>.</td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td width="70%" height="25"><div align="right"></div></td>
      <td width="30%" align="center" class="thinborderBOTTOM" valign="bottom" style="font-size:13px;"><%=WI.fillTextValue("signatory")%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td align="center" valign="top" style="font-size:13px;"><%=WI.fillTextValue("position")%></td>
    </tr>
  </table>

</body>
</html>
<%
dbOP.cleanUP();
%>
