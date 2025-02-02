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

String strGradDate = null;
String strDeanName = null;

if(strStudID.length() > 0) {
	strSQLQuery = "select course_offered.course_code,major_name,sy_from,semester,course_name,year_level,DEAN_NAME from stud_curriculum_hist "+
		"join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
		"left join major on (major.major_index = stud_curriculum_hist.major_index) "+
		"join semester_sequence on (semester_val = semester)"+
		"join college on (college.c_index = course_offered.c_index)"+
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
		
		strDeanName   = rs.getString(7);

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
		
		rs.close();
		
		strSQLQuery = "select grad_date from graduation_data where stud_index = "+strStudIndex+" and is_valid = 1 order by grad_date desc"; 
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next())
			strGradDate = WI.formatDate(rs.getDate(1), 6);

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
				<td width="10%" valign="top"><img src="../../../images/logo/UB_BOHOL.gif" width="75" height="75"></td>
				<td width="90%" align="center" valign="top">
					  <p>
						<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong>			  
						  <br>
						  Tagbilaran City, Bohol, Philippines <br>
						  Tel. No. (038) 411-2081, Fax No. (038) 411-2081<br><br>
						  
						  <font style="font-weight:bold; font-size:14px;">
						  OFFICE OF THE REGISTRAR						  </font>					  </p>			  </td>
			</tr>
		</table>        </td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2" style="font-size:16px;"><div align="center"><strong>CERTIFICATE OF GOOD MORAL CHARACTER</strong></div></td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2" style="font-size:13px;">TO WHOM IT MAY CONCERN:</td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="59" colspan="2" align="justify" style="font-size:13px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        This
        is to certify that <!--
          <%if(strGender.equals("m")){%>
          Mr.
          <%}else{%>
          Ms.
          <%}%>-->
          <b><%=CommonUtil.getName(dbOP,strStudID,1).toUpperCase()%></b> graduated in this Univeristy with the degree of 
		  <%=strCourseName%> on xyz date. <br>		</td>
    </tr>
    <tr>
      <td height="59" colspan="2" align="justify" style="font-size:13px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      This certifies that 
          <%if(strGender.equals("m")){%>
          he
          <%}else{%>
          she
          <%}%>

	   is a person of good moral character and has not voilated any standing rules and regulations of the school and of the CHED.	  </td>
    </tr>
     <tr>
      <td height="59" colspan="2" align="justify" style="font-size:13px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      Issued this <%=WI.fillTextValue("date_requested")%> for <%=WI.fillTextValue("purpose")%> Purposes.	  </td>
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
     <td height="25" colspan="2">
	 	<table width="100%">
			<tr>
				<td width="70%">&nbsp;</td>
				<td align="center"><strong><%=strDeanName%></strong><br>Dean</td>
			</tr>
		</table>	 
		</td>
   </tr>
   <tr>
     <td height="25" colspan="2">&nbsp;</td>
   </tr>
   <tr>
     <td height="25" colspan="2">&nbsp;</td>
   </tr>
   <tr>
     <td height="25" colspan="2">Attested:<br><br><br>&nbsp;
</td>
   </tr>
   <tr>
     <td height="25" colspan="2">
	 	<table width="100%">
			<tr>
				<td align="center">
				<b>DALIA MELDA T. MAGNO, CPA, MSBA</b><br>
             University Registrar</td>
				<td width="70%">&nbsp;</td>
			</tr>
		</table>	 

	 </td>
   </tr>
  </table>

</body>
</html>
<%
dbOP.cleanUP();
%>
