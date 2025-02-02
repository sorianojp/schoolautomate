<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

-->
</style>
</head>
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date,enrollment.NAApplicationForm,enrollment.PersonalInfoManagement" %>
<%
 //only used to load the Course offered, degree, year offered, semester offered and curriculum year (School year)
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	Vector vRecruit = new Vector();
	String strTempID = (String)request.getSession(false).getAttribute("tempId");

	boolean bolLoggedIn = true;
	Vector[] vEditInfo = null;
	String strSchoolName = "select school_name from SYS_INFO";
	String strSem = "";
	String[] astrConvert = {"0th","1st","2nd","3rd","4th","5th","6th","7th","8th","9th","10th","11th"};


	if(strTempID == null || strTempID.trim().length() ==0)
		bolLoggedIn = false;
if(bolLoggedIn)
{
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> Error in opening connection</font></p>
<%
		return;
	}
   
     
	PersonalInfoManagement pInfo = new PersonalInfoManagement();
	NAApplicationForm napplForm = new NAApplicationForm();
	vEditInfo = napplForm.viewTempStudInfo(dbOP, strTempID);
    vRecruit = pInfo.getStudentRecruitDetails(dbOP,strTempID, true);
	 vRetResult = pInfo.getRecruitmentInfo(dbOP, request,4);
	//get student information for editing.
	//dbOP.cleanUP();

	if(vEditInfo == null || vEditInfo[0].size() ==0)
	{
		strErrMsg = napplForm.getErrMsg();
		if(strErrMsg == null || strErrMsg.trim().length() ==0)
			strErrMsg = "Temporary Student information not found.";
	}
	else
	{
		if( (WI.getStrValue(vEditInfo[0].elementAt(4))).compareTo("0") ==0)//semester.
			strSem = "Summer";
		else
			strSem = astrConvert[Integer.parseInt((String)vEditInfo[0].elementAt(4))]+" Sem";

	}
	
	strSchoolName = dbOP.getResultOfAQuery(strSchoolName, 0);

}//if user is not logged in - show error message.




%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <%
if(!bolLoggedIn)
{
%>
  <tr>
    <td><font size="3"><strong>Please Login to print your GSPIS form.</strong></font></td>
  </tr>
  <%
  return;
}
 if(strErrMsg != null)
 {
%>
  <tr>
    <td><font size="3"><strong><%=strErrMsg%></strong></font></td>
  </tr>
<%
 if(bolLoggedIn)
 	dbOP.cleanUP();
 return;
}
%>
  <tr>
    <td><font size="1">Please fill up the 3 copies properly. For old students,
      fill up any changes or new data from your previous information.</font></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="97"><div align="center">
        <p><font size="1"><br>
          <%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,true)%></font><br>
          <br>
          <strong>GENERAL STUDENT PERSONAL INFORMATION SHEET</strong><br>
          (GSPIS)</p>
      </div></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="35%" height="20" colspan="4"><strong>Date(YYYY-mm-dd) :</strong> <%=WI.getTodaysDate()%></td>
    <td width="30%"><strong>Term :</strong> <%=strSem%></td>
    <td width="35%" rowspan="2" valign="bottom">&nbsp;&nbsp; &nbsp; [photo 2x2]</td>
  </tr>
  <tr>
    <td height="20" colspan="4" valign="bottom"><strong>STATUS : </strong><%=(String)vEditInfo[0].elementAt(2)%></td>
    <td width="30%">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="44%" colspan="4"><strong>DEGREE : </strong><%=(String)vEditInfo[0].elementAt(6)%></td>
    <td width="54%">&nbsp;</td>
    <td width="2%">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td height="15" colspan="3"><strong>TEMP. STUDENT ID # : </strong><%=strTempID%> </td>
  </tr>
  <tr>
    <td height="15" colspan="3"><strong>STUDENT ID # : </strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3"><strong>COURSE/YEAR : </strong><%=(String)vEditInfo[0].elementAt(5)%> / <%=(String)vEditInfo[0].elementAt(3)%> Year &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;School
      Year - <%=WI.getStrValue(vEditInfo[1].elementAt(12))%> - <%=WI.getStrValue(vEditInfo[1].elementAt(13))%></td>
  </tr>
  <tr>
    <td height="15" colspan="3"><strong>CURRICULUM YEAR : </strong><%=(String)vEditInfo[0].elementAt(0)%> - <%=(String)vEditInfo[0].elementAt(1)%></td>
  </tr>
  <tr>
    <td height="5" colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td height="20" colspan="3"><strong>I - PERSONAL DATA</strong></td>
  </tr>
  <tr>
    <td width="25%" height="15">Last Name :<strong><%=(String)vEditInfo[0].elementAt(9)%></strong> </td>
    <td width="23%">First Name :<strong><%=(String)vEditInfo[0].elementAt(7)%> </strong></td>
    <td width="52%">Middle Name: <strong><%=WI.getStrValue(vEditInfo[0].elementAt(8))%> </strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Name in Native Language Character :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(10))%></strong></td>
  </tr>
  <tr>
    <td height="15">Gender :
      <%if( (WI.getStrValue(vEditInfo[0].elementAt(11)) ).compareTo("M") == 0){%>
      <strong>Male</strong>
      <%}else{%>
      <strong>Female</strong>
      <%}%>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td height="15">&nbsp;Religion : <strong><%=WI.getStrValue(vEditInfo[0].elementAt(12))%></strong></td>
    <td height="15">Nationality :<strong> <%=WI.getStrValue(vEditInfo[0].elementAt(13))%></strong></td>
  </tr>
  <tr>
    <td  colspan="2" height="15">If Alien/Foreigner, ACR No. : <strong><%=WI.getStrValue(vEditInfo[0].elementAt(22))%></strong></td>
    <td height="15">&nbsp;</td>
  </tr>
  <tr>
    <td height="15">Age : <strong><%=WI.getStrValue(vEditInfo[0].elementAt(21))%></strong> yrs. old &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td height="15">Date of Birth :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(14))%></strong></td>
    <td height="15">Place of Birth : <strong><%=WI.getStrValue(vEditInfo[0].elementAt(15))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Civil Status : <strong><%=WI.getStrValue(vEditInfo[0].elementAt(16))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">If Married:</td>
  </tr>
  <tr>
    <td height="15" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Woman
      : State Maiden's Name : <strong><%=WI.getStrValue(vEditInfo[0].elementAt(17))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Man
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: Name of Spouse &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      : <strong><%=WI.getStrValue(vEditInfo[0].elementAt(18))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;No.
      of children :&nbsp;&nbsp;<strong><%=WI.getStrValue(vEditInfo[0].elementAt(19))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Birth
      Order :<strong>&nbsp;&nbsp;&nbsp;&nbsp;<strong></strong>&nbsp;&nbsp;&nbsp;&nbsp; <%=WI.getStrValue(vEditInfo[1].elementAt(0))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td height="15" colspan="3"><strong>I B - ALIEN STATUS DATA (for alien/foreigner
      student only)</strong></td>
  </tr>
  <tr>
    <td height="15">Visa Status</td>
    <td height="15">Authorized Stay</td>
    <td height="15">&nbsp;</td>
  </tr>
  <tr>
    <td height="15"><strong><%=WI.getStrValue(vEditInfo[1].elementAt(1))%></strong></td>
    <td height="15"><strong><%=WI.getStrValue(vEditInfo[1].elementAt(2))%></strong></td>
    <td height="15">&nbsp;</td>
  </tr>
  <tr>
    <td height="15">Passport number</td>
    <td height="15">Place of Issue</td>
    <td height="15">Expiration Date</td>
  </tr>
  <tr>
    <td height="15"><strong><%=WI.getStrValue(vEditInfo[1].elementAt(3))%></strong></td>
    <td height="15"><strong><%=WI.getStrValue(vEditInfo[1].elementAt(4))%></strong></td>
    <td height="15"><strong><%=WI.getStrValue(vEditInfo[1].elementAt(5))%></strong></td>
  </tr>
  <tr>
    <td height="15">ACR No</td>
    <td height="15">Date of Issue</td>
    <td height="15">Expiration Date</td>
  </tr>
  <tr>
    <td height="15"><strong><%=WI.getStrValue(vEditInfo[1].elementAt(6))%></strong></td>
    <td height="15"><strong><%=WI.getStrValue(vEditInfo[1].elementAt(7))%></strong></td>
    <td height="15"><strong><%=WI.getStrValue(vEditInfo[1].elementAt(8))%></strong></td>
  </tr>
  <tr>
    <td height="15">CRTS No</td>
    <td height="15">Date of Issue</td>
    <td height="15">Expiration Date</td>
  </tr>
  <tr>
    <td height="15"><strong><%=WI.getStrValue(vEditInfo[1].elementAt(9))%></strong></td>
    <td height="15"><strong><%=WI.getStrValue(vEditInfo[1].elementAt(10))%></strong></td>
    <td height="15"><strong><%=WI.getStrValue(vEditInfo[1].elementAt(11))%></strong></td>
  </tr>
  <tr>
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
  </tr>
  <tr>
    <td height="15" colspan="3"><strong>II - RESIDENCE DATA</strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3"><font color="#0000FF"><u>Home Address:</u></font></td>
  </tr>
  <tr>
    <td height="15" colspan="3">House No./Street/Barangay : <strong><%=WI.getStrValue(vEditInfo[0].elementAt(25))%></strong> City/Municipality : <strong><%=WI.getStrValue(vEditInfo[0].elementAt(26))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Province/State : <strong><%=WI.getStrValue(vEditInfo[0].elementAt(27))%></strong> Country
      : <strong><%=WI.getStrValue(vEditInfo[0].elementAt(28))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Zipcode : <strong><%=WI.getStrValue(vEditInfo[0].elementAt(29))%> </strong>Telephone
      Nos.: <strong><%=WI.getStrValue(vEditInfo[0].elementAt(30))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td height="15" colspan="3"><font color="#0000FF"><u>Current Contact Address:</u></font></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Contact Person/Guardian Name : <strong><%=WI.getStrValue(vEditInfo[0].elementAt(31))%></strong> Relation : <strong><%=WI.getStrValue(vEditInfo[0].elementAt(32))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Apartment Name/House No./Street/Barangay : <strong><%=WI.getStrValue(vEditInfo[0].elementAt(33))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">City/Municipality :<strong> <%=WI.getStrValue(vEditInfo[0].elementAt(34))%></strong> Province/State :<strong> <%=WI.getStrValue(vEditInfo[0].elementAt(35))%></strong> Country :<strong> <%=WI.getStrValue(vEditInfo[0].elementAt(36))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Zipcode : <strong><%=WI.getStrValue(vEditInfo[0].elementAt(37))%></strong> Telephone
      Nos.:<strong> <%=WI.getStrValue(vEditInfo[0].elementAt(38))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Email Address : <strong><%=WI.getStrValue(vEditInfo[0].elementAt(39))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td height="15" colspan="3"><font color="#0000FF"><u>Emergency Contact Data:</u> (if not same as above)</font></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Contact Person Name <strong>: <%=WI.getStrValue(vEditInfo[0].elementAt(40))%></strong> Relation :<strong> <%=WI.getStrValue(vEditInfo[0].elementAt(41))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Apartment Name/House No./Street/Barangay <strong><%=WI.getStrValue(vEditInfo[0].elementAt(42))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">City/Municipality :<strong> <%=WI.getStrValue(vEditInfo[0].elementAt(43))%></strong><strong>emergency</strong> Province/State :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(44))%></strong> Country <strong>: <%=WI.getStrValue(vEditInfo[0].elementAt(45))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Zipcode : <strong><%=WI.getStrValue(vEditInfo[0].elementAt(46))%></strong> Telephone Nos.:<strong><%=WI.getStrValue(vEditInfo[0].elementAt(47))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td height="15" colspan="3"><strong>III - PHYSICAL DESCRIPTION</strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Height :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(48))%> </strong> Weight :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(49))%></strong> Built :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(50))%></strong> Eyes :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(51))%></strong> Hair :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(52))%></strong> Complexion :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(53))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Other Distinguishing Features :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(54))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Physical Handicap or Disability (if any) :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(55))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td height="15" colspan="3"><strong>IV - FAMILY DATA</strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3"><font color="#0000FF"><u>Parents:</u></font></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Father&#8217;s Name :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(56))%></strong> Occupation :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(57))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Company Name :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(58))%></strong>Telephone
      Nos.:<strong><%=WI.getStrValue(vEditInfo[0].elementAt(59))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Company Address :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(60))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Father&#8217;s Email Address :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(61))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Mother&#8217;s Name :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(62))%></strong> Occupation :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(63))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Company Name :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(64))%></strong> Telephone Nos. :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(65))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Company Address :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(66))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">Mother&#8217;s Email Address :<strong><%=WI.getStrValue(vEditInfo[0].elementAt(67))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="15" colspan="3"><font color="#0000FF"><u>Brother(s)/Sister(s):</u></font></td>
  </tr>
  <tr>
    <td height="15" width="22%">NAME</td>
    <td width="22%">COURSE/OCCUPATION</td>
    <td width="56%">SCHOOL/COMPANY</td>
  </tr>
  <%
for(int i = 0; i< 8; ++i)
{
	strTemp = WI.getStrValue(vEditInfo[0].elementAt(68+(i*3)));
	if(strTemp.length() ==0)
		continue;
%>
  <tr>
    <td height="15" width="22%"><%=WI.getStrValue(vEditInfo[0].elementAt(68+(i*3)))%></td>
    <td width="22%"><%=WI.getStrValue(vEditInfo[0].elementAt(69+(i*3)))%></td>
    <td width="56%"><%=WI.getStrValue(vEditInfo[0].elementAt(70+(i*3)))%></td>
  </tr>
  <%}%>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="15" width="10%">&nbsp;</td>
    <td width="21%">&nbsp;</td>
    <td width="25%">&nbsp;</td>
    <td width="44%">&nbsp;</td>
  </tr>
  <tr>
    <td height="15" colspan="4">&nbsp;</td>
  </tr>
  <tr>
    <td height="15" colspan="4"><strong>V - EDUCATIONAL BACKGROUND</strong></td>
  </tr>
  <tr>
    <td height="15" colspan="4">&nbsp;</td>
  </tr>
  <tr>
    <td height="15">&nbsp;</td>
    <td>&nbsp;NAME</td>
    <td>&nbsp;COURSE/YEAR GRADUATED</td>
    <td>&nbsp;HONORS/AWARDS</td>
  </tr>
  <tr>
    <td height="15">Elementary</td>
    <td><%=WI.getStrValue(vEditInfo[0].elementAt(92))%></td>
    <td><%=WI.getStrValue(vEditInfo[0].elementAt(93))%>&nbsp;&nbsp;<%=WI.getStrValue(vEditInfo[0].elementAt(94))%></td>
    <td><%=WI.getStrValue(vEditInfo[0].elementAt(95))%></td>
  </tr>
  <tr>
    <td height="15">High School</td>
    <td><%=WI.getStrValue(vEditInfo[0].elementAt(96))%></td>
    <td><%=WI.getStrValue(vEditInfo[0].elementAt(97))%>&nbsp;&nbsp;<%=WI.getStrValue(vEditInfo[0].elementAt(98))%></td>
    <td><%=WI.getStrValue(vEditInfo[0].elementAt(99))%></td>
  </tr>
  <tr>
    <td height="15">College</td>
    <td><%=WI.getStrValue(vEditInfo[0].elementAt(100))%></td>
    <td><%=WI.getStrValue(vEditInfo[0].elementAt(101))%>&nbsp;&nbsp;<%=WI.getStrValue(vEditInfo[0].elementAt(102))%></td>
    <td><%=WI.getStrValue(vEditInfo[0].elementAt(103))%></td>
  </tr>
  <tr>
    <td height="15">Post Graduate</td>
    <td><%=WI.getStrValue(vEditInfo[0].elementAt(104))%></td>
    <td><%=WI.getStrValue(vEditInfo[0].elementAt(105))%>&nbsp;&nbsp;<%=WI.getStrValue(vEditInfo[0].elementAt(106))%></td>
    <td><%=WI.getStrValue(vEditInfo[0].elementAt(107))%></td>
  </tr>
  <tr>
    <td height="15">Vocational</td>
    <td><%=WI.getStrValue(vEditInfo[0].elementAt(108))%></td>
    <td><%=WI.getStrValue(vEditInfo[0].elementAt(109))%>&nbsp;&nbsp;<%=WI.getStrValue(vEditInfo[0].elementAt(110))%></td>
    <td><%=WI.getStrValue(vEditInfo[0].elementAt(111))%></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="15" colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td height="15" colspan="3"><strong>VI &#8211; GENERAL QUALIFICATION</strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td height="15" colspan="3"><font color="#0000FF"><u>Languages:</u> </font><strong><%=WI.getStrValue(vEditInfo[0].elementAt(112))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3"><font color="#0000FF"><u>Hobbies:</u> </font><strong><%=WI.getStrValue(vEditInfo[0].elementAt(113))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3"><font color="#0000FF"><u>Skills :</u></font><strong> <%=WI.getStrValue(vEditInfo[0].elementAt(114))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3"><font color="#0000FF"><u>Talents :</u></font><strong> <%=WI.getStrValue(vEditInfo[0].elementAt(115))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3"><font color="#0000FF"><u>Sports :</u></font> <strong> <%=WI.getStrValue(vEditInfo[0].elementAt(116))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3"><font color="#0000FF"><u>Honors/Awards/Merits:
      (ex. &quot;Model Student, 1990&quot;) :</u></font> <strong><%=WI.getStrValue(vEditInfo[0].elementAt(117))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3"><font color="#0000FF"><u><font color="#0000FF">Extra-Curricular
      Activities : (Organizations, Clubs, etc)</font> :</u></font> <strong><%=WI.getStrValue(vEditInfo[0].elementAt(118))%></strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td height="15" colspan="3"><strong>VII &#8211; REFERENCES</strong></td>
  </tr>
  <tr>
    <td height="15" colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td height="15" colspan="3">Write two or three references who can vouch or 
      guarantee for your total behavior.</td>
  </tr>
  <tr>
    <td height="15"><u>NAME</u></td>
    <td height="15"><u>ADDRESS</u></td>
    <td height="15">&nbsp;</td>
  </tr>
  <%
if(WI.getStrValue(vEditInfo[0].elementAt(119)).length() >0)
{%>
  <tr>
    <td height="15"><strong><%=WI.getStrValue(vEditInfo[0].elementAt(119))%></strong></td>
    <td colspan="2" height="15"><strong><%=WI.getStrValue(vEditInfo[0].elementAt(120))%></strong></td>
  </tr>
  <%}if(WI.getStrValue(vEditInfo[0].elementAt(121)).length() >0)
{%>
  <tr>
    <td height="15"><strong><%=WI.getStrValue(vEditInfo[0].elementAt(121))%></strong></td>
    <td colspan="2" height="15"><strong><%=WI.getStrValue(vEditInfo[0].elementAt(122))%></strong></td>
  </tr>
  <%}if(WI.getStrValue(vEditInfo[0].elementAt(123)).length() >0)
{%>
  <tr>
    <td height="15"><strong><%=WI.getStrValue(vEditInfo[0].elementAt(123))%></strong></td>
    <td colspan="2" height="15"><strong><%=WI.getStrValue(vEditInfo[0].elementAt(124))%></strong></td>
  </tr>
  <%}%>
  <tr>
    <td height="15">&nbsp;</td>
    <td colspan="2" height="15">&nbsp;</td>
  </tr>
  <tr>
    <td height="15">&nbsp;</td>
    <td colspan="2" height="15">&nbsp;</td>
  </tr>
  <tr>
    <td height="15">&nbsp;</td>
    <td colspan="2" height="15">&nbsp;</td>
  </tr>
</table>
<%
  
  if(vRetResult != null && vRetResult.size() > 0)
		{    %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="20" colspan="3"><strong>VIII &#8211; Admission / Registration </strong></td>
      </tr>
    <tr>
      <td height="15" colspan="3">How did you know <%= WI.getStrValue(strSchoolName) %> ? (Please check the box) </td>
      </tr>
		 <%		
		 
	for(int i = 0; i < vRetResult.size(); i += 2)
		{	
		
		
		
      if(vRecruit.indexOf((String)vRetResult.elementAt(i)) >-1)
	   	strErrMsg = "checked";
		else
			strErrMsg = "";
				  
 	
  %>
    <tr>
      <td colspan="2" height="15"><input type="checkbox" name="detail_index_" 
		value="<%=(String)vRetResult.elementAt(i)%>" disabled="disabled" <%=strErrMsg%>/>
        <%=(String)vRetResult.elementAt(i+1)%> </td>
    </tr>
    <%}%>
	   
    <tr>
    <%
	 strTemp = "";
	 if(vRecruit !=null && vRecruit.size()>0)
	 	strTemp = WI.getStrValue((String)vRecruit.elementAt(1));		
	%>
      <td colspan="2" height="15">others : <%=strTemp%>      </td>
    </tr>
    <tr>
      <td height="15" colspan="3"></td>
      </tr>
    <tr>
      <%
		 strTemp = "";
	 if(vRecruit !=null && vRecruit.size()>0)
	 	strTemp = WI.getStrValue((String)vRecruit.elementAt(0));	
	%>
      <td width="27%" height="15">IF through a person, please specify: </td>
      <td width="73%"><%=strTemp%></td>
    </tr>
  </table>
 <%}%> 
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="3">I HEREBY CERTIFY that the foregoing answers are true and correct
      to the best of my knowledge and belief.</td>
  </tr>
  <tr>
    <td colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td width="32%">&nbsp;</td>
    <td width="33%">&nbsp;</td>
    <td width="35%">_________________________________________</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Student&#8217;s
      Signature</td>
  </tr>
</table>
<input type="hidden" name="tempId" value="<%=strTempID%>">
</body>
</html>
