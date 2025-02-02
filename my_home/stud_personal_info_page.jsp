<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#9FBFD0" onLoad="javascrpt:this.focus();">
<%@ page language="java" import="utility.*,java.util.Vector,enrollment.PersonalInfoManagement" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	Vector[] vEditInfo = null;
	Vector vCourseApplInfo = null; //note here - basic information of course.
	String strEditMsg = "";

	String[] astrConvertYr = {"","1st","2nd","3rd","4th","5th","6th"};
	String[] astrConvertSem= {"Summer","1st Semester","2nd Semester","3rd Semester"};

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"My Home / Student Personal information page","stud_personal_info_page.jsp");
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
boolean bolIsBasic = false;

String strStudID = (String)request.getSession(false).getAttribute("userId");
if(strStudID == null || strStudID.trim().length() ==0)
	strErrMsg = "You are logged out. Please login again.";
else
{
	PersonalInfoManagement pInfo = new PersonalInfoManagement();
	String strSQLQuery = "select course_index from stud_curriculum_hist "+
		"join semester_sequence on (semester_sequence.semester_val = semester) "+
		"where is_valid = 1 and user_index = "+
		request.getSession(false).getAttribute("userIndex")+" order by sy_from desc, sem_order desc";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery,0);
	if(strSQLQuery.equals("0")) {//basic
		pInfo.setBasicEdu(true);
		bolIsBasic = false;
	}
	
	vEditInfo = pInfo.viewPermStudPersonalInfo(dbOP,strStudID);
	if(vEditInfo == null)
		strErrMsg = pInfo.getErrMsg();
}

dbOP.cleanUP();
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#47768F">
      <td height="26" colspan="3"><div align="center"><font color="#FFFFFF" ><strong>::::
          GENERAL STUDENT PERSONAL INFORMATION SHEET (GSPIS) ::::</strong></font></div></td>
    </tr>
    <%
if(strErrMsg != null){%>
    <tr>
      <td height="10" colspan="3">&nbsp; <b><%=strErrMsg%></b></td>
    </tr>
    <%return;
}%>

<%if(bolIsBasic){%>
    
	
    <tr>
      <td height="25"><i>&nbsp; GRADE LEVEL </i></td>
      <td><%=dbOP.getBasicEducationLevel(Integer.parseInt((WI.getStrValue(vEditInfo[0].elementAt(8),"0"))))%></td>
	  <td width="57%"><i>SCHOOL YEAR :</i> 
	  <%=WI.getStrValue(vEditInfo[0].elementAt(6))%> - <%=WI.getStrValue(vEditInfo[0].elementAt(7))%>, 
	  <%=dbOP.getBasicEducationTerm(Integer.parseInt(((String)vEditInfo[0].elementAt(9))))%></td>
    </tr>
<%}else{%>
    <tr>
      <td width="22%" height="23"><i>&nbsp; COURSE </i></td>
      <td colspan="2"><%=WI.getStrValue(vEditInfo[0].elementAt(0))%></td>
    </tr>
	<tr>
      <td width="22%" height="23"><i>&nbsp; MAJOR </i></td>
      <td colspan="2"><%=WI.getStrValue(vEditInfo[0].elementAt(2))%></td>
    </tr>
    <tr>
      <td height="25"><i>&nbsp; CURRICULUM YEAR</i></td>
      <td height="25" colspan="2"><%=WI.getStrValue(vEditInfo[0].elementAt(4))%>
        to <%=WI.getStrValue(vEditInfo[0].elementAt(5))%></td>
    </tr>
    <tr>
      <td height="25"><i>&nbsp; YEAR LEVEL/TERM</i></td>
      <td><%=astrConvertYr[Integer.parseInt((WI.getStrValue(vEditInfo[0].elementAt(8),"0")))]%>/
	  <%=astrConvertSem[Integer.parseInt(((String)vEditInfo[0].elementAt(9)))]%></td>
	  <td width="57%"><i>SCHOOL YEAR :</i> <%=WI.getStrValue(vEditInfo[0].elementAt(6))%>
        to <%=WI.getStrValue(vEditInfo[0].elementAt(7))%></td>
    </tr>
<%}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25" colspan="3"><strong><font color="#FFFFFF" size="2">&nbsp;
        I A &#8211; PERSONAL DATA</font></strong></td>
    </tr>
    <tr>
      <td width="34%" height="20"><i>&nbsp; Last Name </i></td>
      <td width="32%"><i>First Name </i></td>
      <td width="34%"><i>Middle Name </i></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <%=(String)vEditInfo[0].elementAt(13)%></td>
      <td><%=(String)vEditInfo[0].elementAt(11)%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(12))%></td>
    </tr>
    <tr>
      <td colspan="3" height="25"> &nbsp; <i>Name in Native Language Character</i>: &nbsp;
        <%=WI.getStrValue(vEditInfo[0].elementAt(14))%></td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; Gender </i></td>
      <td height="15"><i>Religion </i></td>
      <td height="15"><i>Nationality</i></td>
    </tr>
    <tr>

    <td height="25">&nbsp;<%
strTemp = WI.getStrValue(vEditInfo[0].elementAt(15));
if(strTemp.compareTo("M") ==0)
{%>
      Male
      <%}else{%>
      Female
      <%}%>    </td>
      <td height="25"><%=WI.getStrValue(vEditInfo[0].elementAt(16))%></td>
      <td height="25"><%=WI.getStrValue(vEditInfo[0].elementAt(17))%></td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; Date of Birth<font size="1">(mm/dd/yyyy)</font></i></td>
      <td height="20"><i>Place of Birth </i></td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;<%=WI.getStrValue(vEditInfo[0].elementAt(18))%></td>

    <td height="25"><%=WI.getStrValue(vEditInfo[0].elementAt(19))%></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><i>&nbsp; Civil Status (If Married -&gt;) </i></td>
      <td height="25"><i>Woman : State Maiden's Name</i></td>
      <td height="25"><i>Man : Name of Spouse </i></td>
    </tr>
    <tr>
      <td height="25">&nbsp;<%=WI.getStrValue(vEditInfo[0].elementAt(20))%></td>
      <td height="25"><%=WI.getStrValue(vEditInfo[0].elementAt(21))%></td>
      <td height="25"><%=WI.getStrValue(vEditInfo[0].elementAt(22))%></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <i>No. of children :</i>        <%=WI.getStrValue(vEditInfo[0].elementAt(23))%>      </td>
      <td  colspan="2" height="25"><i>Email Address:</i>       <%=WI.getStrValue(vEditInfo[0].elementAt(24))%>      </td>
    <tr>
      <td height="25">&nbsp; <i>Birth Order &nbsp;&nbsp;&nbsp;&nbsp; :</i>        <%=WI.getStrValue(vEditInfo[0].elementAt(87))%>      </td>
      <td  colspan="2" height="25"><i>Mobile Number:</i> <%=WI.getStrValue(vEditInfo[0].elementAt(95))%> </td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25" colspan="3"><strong><font color="#FFFFFF" size="2">&nbsp;
        I B &#8211; ALIEN STATUS DATA (for alien/foreigner student only)</font></strong></td>
    </tr>
    <tr>
      <td width="34%" height="20"><i>&nbsp; Visa Status</i></td>
      <td width="32%"><i>Authorized Stay</i></td>
      <td width="34%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(26))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(27))%></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; Passport No.</i></td>
      <td height="15"><i>Place of Issue</i></td>
      <td><i>Expiration Date <font size="1">(mm/dd/yyyy)</font></i></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(28))%></td>
      <td height="25"><%=WI.getStrValue(vEditInfo[0].elementAt(29))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(30))%></td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; ACR NO.</i></td>
      <td height="20"><i>Date of Issue<font size="1">(mm/dd/yyyy)</font></i></td>
      <td><i>Expiration Date <font size="1">(mm/dd/yyyy)</font></i></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(31))%></td>
      <td height="25"><%=WI.getStrValue(vEditInfo[0].elementAt(32))%>
	  <td><%=WI.getStrValue(vEditInfo[0].elementAt(33))%></td>
   </tr>
    <tr>
      <td height="25"><i>&nbsp; CRTS NO.</i></td>
      <td height="25"><i>Date of Issue<font size="1">(mm/dd/yyyy)</font></i></td>
      <td><i>Expiration Date <font size="1">(mm/dd/yyyy)</font></i></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(34))%></td>
      <td height="25"><%=WI.getStrValue(vEditInfo[0].elementAt(35))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(36))%></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25" colspan="2"><strong><font color="#FFFFFF" >&nbsp;
        II &#8211; RESIDENCE DATA</font></strong></td>
    </tr>
    <tr>
      <td height="20" colspan="2">&nbsp;
        <font color="#0000FF"><u>Home Address: </u></font></td>
    </tr>
    <tr>
      <td width="60%" height="20"><i>&nbsp; Apartment Name/House
        No./Street/Barangay </i></td>
      <td width="40%"><i>City/Municipality </i></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(37))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(38))%></td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; Province/State </i></td>
      <td><i>Country</i></td>
    </tr>
    <tr>
      <td height="25">&nbsp;  <%=WI.getStrValue(vEditInfo[0].elementAt(39))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(40))%></td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; Zipcode</i></td>
      <td><i>Telephone Nos. </i></td>
    </tr>
    <tr>
      <td height="25">&nbsp;  <%=WI.getStrValue(vEditInfo[0].elementAt(41))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(42))%></td>
    </tr>
    <tr>
      <td height="20" colspan="2">&nbsp;
        <font color="#0000FF"><u>Current Contact Address: </u></font></td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; Contact
        Person/Guardian Name </i></td>
      <td><i>Relation</i></td>
    </tr>
    <tr>
      <td height="25">&nbsp;  <%=WI.getStrValue(vEditInfo[0].elementAt(43))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(44))%></td>
    </tr>
    <tr>
      <td height="20">&nbsp;<i> Apartment
        Name/House No./Street/Barangay </i></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2" height="25">&nbsp;
         <%=WI.getStrValue(vEditInfo[0].elementAt(45))%></td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; City/Municipality</i></td>
      <td><i>Province/State </i></td>
    </tr>
    <tr>
      <td height="25">&nbsp;
        <%=WI.getStrValue(vEditInfo[0].elementAt(46))%>      </td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(47))%></td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; Country </i></td>
      <td><i>Zipcode </i></td>
    </tr>
    <tr>
      <td height="25">&nbsp;  <%=WI.getStrValue(vEditInfo[0].elementAt(48))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(49))%></td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; Telephone
        Nos.</i></td>
      <td><i>Email Address </i></td>
    </tr>
    <tr>
      <td height="25">&nbsp;  <%=WI.getStrValue(vEditInfo[0].elementAt(50))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(51))%></td>
    </tr>
    <tr>
      <td height="20" colspan="2">&nbsp; <font color="#0000FF"><u>Emergency
        Contact Address: (if not same as above)</u></font></td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; Contact
        Person Name </i></td>
      <td><i>Relation</i></td>
    </tr>
    <tr>
      <td height="25">&nbsp;  <%=WI.getStrValue(vEditInfo[0].elementAt(52))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(53))%></td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; Apartment
        Name/House No./Street/Barangay</i> </td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2" height="25">&nbsp;
         <%=WI.getStrValue(vEditInfo[0].elementAt(54))%></td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; City/Municipality</i></td>
      <td><i>Province/State </i></td>
    </tr>
    <tr>
      <td height="25">&nbsp;
        <%=WI.getStrValue(vEditInfo[0].elementAt(55))%>      </td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(56))%></td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; Country</i></td>
      <td><i>Zipcode</i></td>
    </tr>
    <tr>
      <td height="25">&nbsp;  <%=WI.getStrValue(vEditInfo[0].elementAt(57))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(58))%></td>
    </tr>
    <tr>
      <td height="20">&nbsp; Telephone
        Nos. </td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;  <%=WI.getStrValue(vEditInfo[0].elementAt(59))%></td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25" colspan="6"><i><strong><font color="#FFFFFF" size="2">&nbsp;
        III &#8211; PHYSICAL DESCRIPTION</font></strong></i></td>
    </tr>
    <tr>
      <td width="16%" height="20"><i>&nbsp; Height(cms)</i></td>
      <td width="16%"><i>Weight(lbs)</i></td>
      <td width="16%"><i>Built</i></td>
      <td width="16%"><i>Eye color</i></td>
      <td width="17%"><i>Hair color</i></td>
      <td width="19%"><i>Complexion</i></td>
    </tr>
    <tr>
      <td height="25">&nbsp;  <%=WI.getStrValue(vEditInfo[0].elementAt(60))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(61))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(62))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(63))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(64))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(65))%></td>
    </tr>
    <tr>
      <td colspan="3" height="20"><i>&nbsp; Other Distinguishing
        Features </i></td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="6" height="25">&nbsp;  <%=WI.getStrValue(vEditInfo[0].elementAt(66))%></td>
    </tr>
    <tr>
      <td colspan="3" height="20"><i>&nbsp; Physical Handicap
        or Disability (if any) </i></td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="6" height="25">&nbsp;  <%=WI.getStrValue(vEditInfo[0].elementAt(67))%></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25" colspan="2"><strong><font color="#FFFFFF" size="2" >&nbsp;
        IV&#8211; FAMILY DATA</font></strong></td>
    </tr>
    <tr>
      <td height="20" colspan="2">&nbsp;
        <font color="#0000FF"><u>Parents:</u></font></td>
    </tr>
    <tr>
      <td width="60%" height="20"><i>&nbsp;
      Father&#8217;s Name </i></td>
      <td width="40%"><i>Occupation</i></td>
    </tr>
    <tr>
      <td height="25">&nbsp;  <%=WI.getStrValue(vEditInfo[0].elementAt(68))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(69))%></td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; Company Name </i></td>
      <td><i>Telephone Nos. </i></td>
    </tr>
    <tr>
      <td height="25">&nbsp;  <%=WI.getStrValue(vEditInfo[0].elementAt(70))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(71))%></td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; Company
        Address</i></td>
      <td><i>Father&#8217;s Email Address </i></td>
    </tr>
    <tr>
      <td height="25">&nbsp;  <%=WI.getStrValue(vEditInfo[0].elementAt(72))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(73))%></td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; Mother&#8217;s
        Name </i></td>
      <td><i>Occupation</i></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(74))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(75))%></td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; Company Name </i></td>
      <td><i>Telephone Nos. </i></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(76))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(77))%></td>
    </tr>
    <tr>
      <td height="20"><i>&nbsp; Company
        Address</i></td>
      <td><i>Mother&#8217;s Email Address </i></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(78))%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(79))%></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="35%" height="20">&nbsp; <font color="#0000FF">Brother(s)/Sister(s):</font></td>
      <td width="15%">&nbsp;</td>
      <td width="24%">&nbsp;</td>
      <td width="26%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><i>&nbsp; <u>NAME</u></i></td>
      <td><i><u>DATE OF BIRTH </u></i></td>
      <td><i><u>COURSE/OCCUPATION </u></i></td>
      <td><i><u>SCHOOL/COMPANY</u></i></td>
    </tr>
<%
int j=0;
for(int i=0; i<8;){
++i;
if(vEditInfo[1].size() <=j)
	continue;
	
if(vEditInfo[1].size() > j)
	strTemp = WI.getStrValue(vEditInfo[1].elementAt(j++));
else
	strTemp = "";
%>

    <tr>
      <td height="25">&nbsp; <%=strTemp%></td>
<%
if(vEditInfo[1].size() > j)
	strTemp = WI.getStrValue(vEditInfo[1].elementAt(j++));
%>
      <td><%=WI.getStrValue(strTemp,"-")%></td>
<%
if(vEditInfo[1].size() > j)
	strTemp = WI.getStrValue(vEditInfo[1].elementAt(j++));
%>
      <td><%=WI.getStrValue(strTemp,"-")%></td>
<%
if(vEditInfo[1].size() > j)
	strTemp = WI.getStrValue(vEditInfo[1].elementAt(j++));
++j;
%>
      <td><%=WI.getStrValue(strTemp,"-")%></td>
    </tr>
<%}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25" colspan="4"><strong><font color="#FFFFFF" size="2" >&nbsp;
        V&#8211; EDUCATIONAL BACKGROUND</font></strong></td>
    </tr>
    <tr>
      <td width="15%" height="25">&nbsp;</td>
      <td width="29%"><i><u>NAME</u></i></td>
      <td width="26%"><i><u>COURSE/YEAR GRADUATED</u></i></td>
      <td width="30%"><i><u>HONORS/AWARDS</u></i></td>
    </tr>
<%
j =0;
if(vEditInfo[2] != null && vEditInfo[2].size() > j && ((String)vEditInfo[2].elementAt(j)).compareToIgnoreCase("elementary") ==0){++j;%>
    <tr>
      <td height="25"><i>&nbsp; Elementary</i></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++))%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>
	  <%=WI.getStrValue(vEditInfo[2].elementAt(j++))%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++))%></td>
    </tr>
<%}else{%>
	<tr>
      <td height="25"><i>&nbsp; Elementary</i></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
<%}if(vEditInfo[2] != null && vEditInfo[2].size() > j && ((String)vEditInfo[2].elementAt(j)).compareToIgnoreCase("High school") ==0){++j;%>

    <tr>
      <td height="25"><i>&nbsp; High School</i></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++))%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>
	  <%=WI.getStrValue(vEditInfo[2].elementAt(j++))%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++))%></td>
    </tr>
<%}else{%>
	<tr>
      <td height="25"><i>&nbsp; High School</i></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
<%}if(vEditInfo[2] != null && vEditInfo[2].size() > j && ((String)vEditInfo[2].elementAt(j)).compareToIgnoreCase("College") ==0){++j;%>
    <tr>
      <td height="25"><i>&nbsp; College</i></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++))%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>
	  <%=WI.getStrValue(vEditInfo[2].elementAt(j++))%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++))%></td>
    </tr>
<%}else{%>
	<tr>
      <td height="25"><i>&nbsp; College</i></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
<%}if(vEditInfo[2] != null && vEditInfo[2].size() > j && ((String)vEditInfo[2].elementAt(j)).compareToIgnoreCase("PG") ==0){++j;%>
    <tr>
      <td height="25"><i>&nbsp; Post Graduate</i></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++))%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>
	  <%=WI.getStrValue(vEditInfo[2].elementAt(j++))%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++))%></td>
    </tr>
<%}else{%>
<tr>
      <td height="25"><i>&nbsp; Post Graduate</i></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
<%}if(vEditInfo[2] != null && vEditInfo[2].size() > j && ((String)vEditInfo[2].elementAt(j)).compareToIgnoreCase("Vocatinal") ==0){++j;%>
    <tr>
      <td height="25"><i>&nbsp; Vocational</i></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++))%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>
	  <%=WI.getStrValue(vEditInfo[2].elementAt(j++))%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++))%></td>
    </tr>
<%}else{%>
<tr>
      <td height="25"><i>&nbsp; Vocational</i></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
<%}%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25"  colspan="2"><strong><font color="#FFFFFF" size="2" >&nbsp; VI&#8211;
        GENERAL QUALIFICATION</font></strong></td>
    </tr>
    <tr>
      <td width="10%"><i>&nbsp;<font color="#0000FF">Languages:</font></i></td>
      <td height="25"> <%=WI.getStrValue(vEditInfo[0].elementAt(80))%></td>
    </tr>
    <tr>
      <td><i>&nbsp;<font color="#0000FF">Hobbies:</font></i></td>
      <td height="25">
        <%=WI.getStrValue(vEditInfo[0].elementAt(81))%> </td>
    </tr>
    <tr>
      <td><i><font color="#0000FF">&nbsp;Skills:</font></i></td>
      <td height="25">
        <%=WI.getStrValue(vEditInfo[0].elementAt(82))%></td>
    </tr>
    <tr>
      <td><i><font color="#0000FF">&nbsp;Talents:</font></i></td>
      <td height="25">
        <%=WI.getStrValue(vEditInfo[0].elementAt(83))%></td>
    </tr>
    <tr>
      <td><i>&nbsp;<font color="#0000FF">Sports:</font></i></td>
      <td height="25">
        <%=WI.getStrValue(vEditInfo[0].elementAt(84))%></td>
    </tr>
    <tr>
      <td colspan="2"><font color="#0000FF"><i>&nbsp;Honors/Awards/Merits: (ex. &quot;Model
        Student, 1990&quot;)</i></font> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">
<%=WI.getStrValue(vEditInfo[0].elementAt(85))%></td>
    </tr>

    <tr>
      <td colspan="2"><i>&nbsp;<font color="#0000FF">Extra-Curricular Activities
        : (Organizations, Clubs, etc)</font></i></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">
<%=WI.getStrValue(vEditInfo[0].elementAt(86))%></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25" colspan="2"><strong><font color="#FFFFFF" size="2">&nbsp;
        VII&#8211; REFERENCES</font></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="2"><i>&nbsp;&nbsp;&nbsp;Write two or three references
         who can vouch or guarantee for your total
        behavior.</i></td>
    </tr>
    <tr>
      <td width="35%" height="25"><i>&nbsp;&nbsp;&nbsp;<u>NAME</u></i></td>
      <td width="65%"><i><u>ADDRESS/TEL. NOS.</u></i></td>
    </tr>
<%//System.out.println(vEditInfo[3]);
j = 0;
if(vEditInfo[3].size() > j)
	strTemp = WI.getStrValue(vEditInfo[3].elementAt(j++));
else
	strTemp = "";
%>
    <tr>
      <td height="25">&nbsp;&nbsp; <%=strTemp%></td>
<%
if(vEditInfo[3].size() > j)
	strTemp = WI.getStrValue(vEditInfo[3].elementAt(j++));
else
	strTemp = "";
++j;
%>      <td><%=strTemp%></td>
    </tr>
    <tr>
<%if(vEditInfo[3].size() > j)
	strTemp = WI.getStrValue(vEditInfo[3].elementAt(j++));
else
	strTemp = "";
%>      <td height="25">&nbsp;&nbsp; <%=strTemp%></td>
<%if(vEditInfo[3].size() > j)
	strTemp = WI.getStrValue(vEditInfo[3].elementAt(j++));
else
	strTemp = "";
++j;
%>      <td><%=strTemp%></td>
    </tr>
<%if(vEditInfo[3].size() > j)
	strTemp = WI.getStrValue(vEditInfo[3].elementAt(j++));
else
	strTemp = "";
%>    <tr>
      <td height="25">&nbsp;&nbsp; <%=strTemp%></td>
<%if(vEditInfo[3].size() > j)
	strTemp = WI.getStrValue(vEditInfo[3].elementAt(j++));
else
	strTemp = "";
%>      <td><%=strTemp%></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="30%">&nbsp;</td>
      <td width="55%">&nbsp;</td>
    </tr>
    <tr bgcolor="#47768F">
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(WI.fillTextValue("print").compareTo("1") ==0)
{%>
<script language="javascript">
this.focus();
window.print();
</script>
<%}%>
</body>
</html>
