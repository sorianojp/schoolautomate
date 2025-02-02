<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date,enrollment.NAApplCommonUtil" %>
<%
 //only used to load the Course offered, degree, year offered, semester offered and curriculum year (School year)
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String[] astrCurSchYr = null;
	boolean bolFatalErr = false; boolean bolShowData = true;
	
	try
	{
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
String strSQLQuery = null;
java.sql.ResultSet rs = null;

NAApplCommonUtil nacUtil 	= new NAApplCommonUtil();
Vector vCourseOffered 		= nacUtil.getOpenCourse(dbOP);
if(vCourseOffered == null || vCourseOffered.size() ==0) {
	bolFatalErr = true;
	strErrMsg = nacUtil.getErrMsg();
}
else if(WI.fillTextValue("cc_index").length() > 0) {
	Vector vCourseI = new Vector();
	strSQLQuery = "select course_index from course_offered where cc_index = "+WI.fillTextValue("cc_index");
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next())
		vCourseI.addElement(rs.getString(1));
	rs.close();
	for(int i = 0; i < vCourseOffered.size(); i += 2) {
		if(vCourseI.indexOf(vCourseOffered.elementAt(i)) > -1)
		  continue;
		
		vCourseOffered.removeElementAt(i);
		vCourseOffered.removeElementAt(i);
		i = i-2;
	}
}


String[] astrDegAndSY 		= nacUtil.getDegreeAndSY(dbOP, request.getParameter("course_index"),request.getParameter("major_index"));

astrCurSchYr = dbOP.getCurSchYr();

if( strErrMsg == null && astrDegAndSY == null && WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("course_index").compareTo("0") !=0)
{
	//I have to find here if course is having major. if it has i should not return.. 
	if(WI.fillTextValue("major_index").length() == 0) {
		strTemp = "select major_index from major where is_del = 0 and course_index = "+WI.fillTextValue("course_index");
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp == null) {
			bolFatalErr = true;	
			strErrMsg = nacUtil.getErrMsg();
		}
		else {	
			bolShowData = false;
			strErrMsg   = "<font size=3 color='red'>Please select a Major</font>";
		}
	}
}
if(strErrMsg == null && astrCurSchYr == null)
{
	bolFatalErr = true;
	strErrMsg = dbOP.getErrMsg();
}
	String strSchoolCode = dbOP.getSchoolIndex();
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">

</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
//open an new window to display course offered detail.
function CheckCourseOffered()
{
	var Proceed = true;var ErrMsg = "";
	var CourseIndex = document.formstep1.course_index[document.formstep1.course_index.selectedIndex].value;
	if(CourseIndex == "0")
	{
		ErrMsg += "Please select a course .";
		Proceed = false;
	}

	var CourseName = document.formstep1.course_index[document.formstep1.course_index.selectedIndex].text;
	var SYFrom = document.formstep1.sy_from.value;
	var SYTo = document.formstep1.sy_to.value;
	var Year = document.formstep1.year_level[document.formstep1.year_level.selectedIndex].value;
	var Semester = document.formstep1.semester[document.formstep1.semester.selectedIndex].value;
	if(SYFrom.length == 0 || SYTo.length == 0)
	{
		ErrMsg +="Course is not open.";
		Proceed = false;
	}
	if(Year.length == 0 || Semester.length == 0)
	{
		ErrMsg +="Year or Semester can't be blank to check open course.";
		Proceed = false;
	}
	if(Proceed)
	{
		var strLoc = "./opencourse_detail.jsp?ci="+CourseIndex+"&cn="+escape(CourseName)+"&year="+Year+"&sem="+Semester;
		var win=window.open(strLoc,"PrintWindow",'width=700,height=400,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	else
		alert(ErrMsg);
}
function ReloadPage()
{
	document.formstep1.action = "./gspis_page.jsp";
	document.formstep1.submit();
}
function submitonce(theform)
{
//if IE 4+ or NS 6+
	//form is submitted here.
	document.formstep1.action = "./gspis_createlogin.jsp";
	if (document.all||document.getElementById)
	{
	//screen thru every element in the form, and hunt down "submit" and "reset"
		for (i=0;i<theform.length;i++)
		{
			var tempobj=theform.elements[i]
			if(tempobj.type.toLowerCase()=="submit"||tempobj.type.toLowerCase()=="reset")
			//disable em
			tempobj.disabled=true
		}
	}
	document.formstep1.submit();
}
function Convert() {
	var pgLoc = 
	"../../../../commfile/conversion.jsp?called_fr_form=formstep1&cm_field_name=height&lb_field_name=weight";
	
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function CopySchool(strCopyIndex) {
	if(strCopyIndex == '1') {//copy from hs to elem.
		if(document.formstep1._1.checked)
			document.formstep1.HIGH_SCH_NAME.selectedIndex = document.formstep1.ELEM_SCH_NAME.selectedIndex;
	}

}
function CopyAddr(strCopyTo) {
	if(strCopyTo == '1') {//copy Home address to contact address
		document.formstep1.con_house_no.value = document.formstep1.res_house_no.value;
		document.formstep1.con_city.value = document.formstep1.res_city.value;
		document.formstep1.con_provience.value = document.formstep1.res_provience.value;
		document.formstep1.con_country.value = document.formstep1.res_country.value;
		document.formstep1.con_zip.value = document.formstep1.res_zip.value;
		document.formstep1.con_tel.value     = document.formstep1.res_tel.value;		
	}
	else {//copy contact address to emergency address
		document.formstep1.emgn_house_no.value = document.formstep1.con_house_no.value;
		document.formstep1.emgn_city.value = document.formstep1.con_city.value;
		document.formstep1.emgn_provience.value = document.formstep1.con_provience.value;
		document.formstep1.emgn_country.value = document.formstep1.con_country.value;
		document.formstep1.emgn_zip.value = document.formstep1.con_zip.value;
		document.formstep1.emgn_tel.value = document.formstep1.con_tel.value;		
	}
}
</script>

<body bgcolor="#9FBFD0">

<form name="formstep1" action="" method="post" onSubmit="submitonce(this);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#47768F">
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF" ><strong>::::
          GENERAL STUDENT PERSONAL INFORMATION SHEET (GSPIS) :::: </strong></font></div></td>
    </tr>
    <%
if(strErrMsg != null){%>
    <tr>
      <td height="10" colspan="3">&nbsp; <b><%=strErrMsg%></b></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <%}
	if(bolFatalErr)
	{
		dbOP.cleanUP();
		return;
	}
//show only if any course is offered.
if(vCourseOffered != null && vCourseOffered.size() >0)
{%>
    <tr>
      <td height="25" colspan="2">&nbsp; Date(YYYY-mm-dd) : <strong><%=WI.getTodaysDate()%></strong></td>
      <td width="68%" style="font-weight:bold; color:#FF0000">* are mandatory fields and must be filled up</td>
    </tr>
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp; STATUS : <%=request.getParameter("appl_catg")%></td>
      <!-- Student ID will not be stored - it will be stored only for conformees -->
    </tr>
    <tr>
      <td height="10" colspan="3">
	  &nbsp; <font color="#FF0000">PREVIOUS SCHOOL *  </font>
	  <select name="sch_index" style="font-size:11px;">
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL = 0  "+ 
		  //" and sch_name not like  '%elem%' "+ 
		  //" and sch_name not like '%high sch%' "+
		  "order by SCH_NAME",WI.fillTextValue("sch_index"),false)%>
        </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp; COURSE PROGRAM</td>
      <td colspan="2"><select name="cc_index" onChange="ReloadPage();">
          <option value=""></option>
          <%=dbOP.loadCombo("cc_index","cc_name"," from CCLASSIFICATION where IS_DEL=0 order by cc_name asc", request.getParameter("cc_index"), false)%> 
        </select></td>
    </tr>
    <tr>
      <td width="22%" height="25">&nbsp; <font color="#FF0000">COURSE *</font></td>
      <td colspan="2"><select name="course_index" onChange="ReloadPage();">
          <option value="">Select a course</option>
          <%
strTemp = WI.fillTextValue("course_index");
for(int i = 0 ; i< vCourseOffered.size(); ++i)
{
	if(strTemp.compareTo( (String)vCourseOffered.elementAt(i))  == 0)
	{%>
          <option value="<%=vCourseOffered.elementAt(i++)%>" selected><%=vCourseOffered.elementAt(i)%></option>
          <%}else{%>
          <option value="<%=vCourseOffered.elementAt(i++)%>"><%=vCourseOffered.elementAt(i)%></option>
          <%}
}
%>
    </select>    </td></tr>
    
    <tr>
      <td height="25">&nbsp; MAJOR</td>
      <td height="25" colspan="2"><select name="major_index" onChange="ReloadPage();">
          <option></option>
          <%
if(strTemp != null && strTemp.compareTo("0") != 0 && strTemp.length()>0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp+" order by major_name asc" ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, WI.fillTextValue("major_index"), false)%>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <font color="#FF0000">YEAR LEVEL *</font></td>
      <td width="10%" height="25"> <select name="year_level">
          <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0)
{%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0)
{%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0)
{%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}if(strTemp.compareTo("7") ==0)
{%>
          <option value="7" selected>7th</option>
          <%}else{%>
          <option value="7">7th</option>
          <%}if(strTemp.compareTo("8") ==0)
{%>
          <option value="8" selected>8th</option>
          <%}else{%>
          <option value="8">8th</option>
          <%}%>
        </select>
        <!--<input type="text" name="year_level" maxlength="4" size=4 value="<%=WI.fillTextValue("year_level")%>"> -->      </td>
      <td height="25"> <font color="#FF0000">TERM *</font>
        <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = astrCurSchYr[2];
if(strTemp.compareTo("0") ==0)
{%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>
        <!--<input type="text" name="semester" maxlength="1" size=1 value="<%=WI.fillTextValue("semester")%>">-->
        &nbsp;&nbsp;<font color="#FF0000">SCHOOL YEAR *</font>:
        <%
strTemp = WI.fillTextValue("sch_yr_from");
if(strTemp.length() ==0)
	strTemp = astrCurSchYr[0];
%>
        <input type="text" name="sch_yr_from" maxlength="4" size="4" value="<%=strTemp%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
		onKeyUp='DisplaySYTo("formstep1","sch_yr_from","sch_yr_to")'>
        -
        <%
strTemp = WI.fillTextValue("sch_yr_to");
if(strTemp.length() ==0)
	strTemp = astrCurSchYr[1];
%>
        <input type="text" name="sch_yr_to" maxlength="4" size="4" value="<%=strTemp%>" readonly="yes"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <%
//show this only if course is available for enrolling.
if(astrDegAndSY != null){%>
    <tr>
      <td height="25">&nbsp; CURRICULUM YEAR</td>
      <td  colspan="2" height="25"> <%=astrDegAndSY[1]%> - <%=astrDegAndSY[2]%><font size="1">(offered)
        <a href="javascript:CheckCourseOffered();"><img src="../../../../images/view.gif" border="0"></a>
        Click here to view if course is open for admission.</font> <input type="hidden" name="sy_from" value="<%=astrDegAndSY[1]%>">
        <input type="hidden" name="sy_to" value="<%=astrDegAndSY[2]%>"> </td>
    </tr>
    <%}else if(WI.fillTextValue("course_index").length() > 0) {//show error message.
if(strErrMsg == null){%>
    <tr>
      <td height="25" colspan="3">&nbsp; <strong>You can't enroll for this course.
        Please contact school for detail. </strong></td>
    </tr>
    <%}
}%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(WI.fillTextValue("course_index").length() > 0 && bolShowData) {%>
    <tr bgcolor="#BECED3">
      <td height="25" colspan="3"><strong><font color="#FFFFFF" size="2">&nbsp;
        I A &#8211; PERSONAL DATA</font></strong></td>
    </tr>
    <tr>
      <td width="34%" height="20" valign="bottom">&nbsp; <font color="#FF0000">Last Name *</font></td>
      <td width="32%" valign="bottom"><font color="#FF0000">First Name *</font></td>
      <td width="34%" valign="bottom">Middle Name </td>
    </tr>
    <tr>
      <td height="25">&nbsp; <input name="lname" type="text" size="32" maxlength="32" value="<%=WI.fillTextValue("lname")%>" <%if(strSchoolCode.startsWith("AUF")){%>OnKeyUP="javascript:this.value=this.value.toUpperCase();"<%}%>></td>
      <td><input name="fname" type="text" size="32" maxlength="32" value="<%=WI.fillTextValue("fname")%>" <%if(strSchoolCode.startsWith("AUF")){%>OnKeyUP="javascript:this.value=this.value.toUpperCase();"<%}%>></td>
      <td><input name="mname" type="text" size="32" maxlength="32" value="<%=WI.fillTextValue("mname")%>" <%if(strSchoolCode.startsWith("AUF")){%>OnKeyUP="javascript:this.value=this.value.toUpperCase();"<%}%>></td>
    </tr>
    <tr>
      <td colspan="3" height="25"> &nbsp; Name in Native Language Character &nbsp;
        <input name="native_lan" type="text" size="64" maxlength="32" value="<%=WI.fillTextValue("native_lan")%>"></td>
    </tr>
    <tr style="color:#FF0000">
      <td height="20" valign="bottom">&nbsp; Gender *</td>
      <td height="15" valign="bottom">Religion *</td>
      <td height="15" valign="bottom">Nationality *</td>
    </tr>
    <tr>
      <td height="25">&nbsp; <select name="gender">
          <%
strTemp = WI.fillTextValue("gender");
if(strTemp.compareTo("M") ==0)
{%>
          <option value="M" selected>Male</option>
          <%}else{%>
          <option value="M">Male</option>
          <%}if(strTemp.compareTo("F") ==0)
{%>
          <option value="F" selected>Female</option>
          <%}else{%>
          <option value="F">Female</option>
          <%}%>
        </select></td>
      <td height="25">
        <select name="religion">
          <option value=""></option>
 <%
strTemp = WI.fillTextValue("religion");
if(strTemp.length() == 0) 
	strTemp = "Roman Catholic";
%>
          <%=dbOP.loadCombo("RELIGION","RELIGION"," FROM HR_PRELOAD_RELIGION order by religion",strTemp,false)%>
        </select></td>
      <td height="25">
        <select name="nationality">
          <option value=""></option>
<%
strTemp = WI.fillTextValue("nationality");
if(strTemp.length() == 0) 
	strTemp = "Filipino";
%>
          <%=dbOP.loadCombo("NATIONALITY","NATIONALITY"," FROM HR_PRELOAD_NATIONALITY order by nationality",strTemp,false)%>
        </select></td>
    </tr>
    <tr valign="bottom" style="color:#FF0000">
      <td height="20">&nbsp; Date of Birth(mm/dd/yyyy) *</td>
      <td height="20">Place of Birth *</td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp; 
	  <select name="mm">
	  <%
	  strTemp = WI.fillTextValue("mm");
	  String[] strMonth = {"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sept","Oct","Nov","Dec"};
	  for(int i = 1; i < 13; ++i) {
	  	if(strTemp.equals(strMonth[i]))
			strErrMsg = "selected";
		else	
			strErrMsg = "";
		%><option value="<%=i%>" <%=strErrMsg%>><%=strMonth[i]%></option>
	  <%}%>
	  </select>
        /
	  <select name="dd">
	  <%
	  strTemp = WI.fillTextValue("dd");
	  for(int i = 1; i < 32; ++i) {
	  	if(strTemp.equals(Integer.toString(i)))
			strErrMsg = "selected";
		else	
			strErrMsg = "";
		%><option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
	  <%}%>
	  </select>
        /
      <select name="yyyy">
	  <%=dbOP.loadComboYear(WI.fillTextValue("yyyy"),65,-2)%>
	  </select>
      </td>
      <td height="25"><input name="place_of_birth" type="text" size="32" maxlength="32" value="<%=WI.fillTextValue("place_of_birth")%>">
      </td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr valign="bottom">
      <td height="25">&nbsp; <font style="color:#FF0000">Civil Status *</font> (If Married -&gt;) </td>
      <td height="25">Woman : State Maiden's Name</td>
      <td height="25">Man : Name of Spouse </td>
    </tr>
    <tr>
      <td height="25">&nbsp; <select name="civil_stat">
          <%
strTemp = WI.fillTextValue("civil_stat");
if(strTemp.compareToIgnoreCase("single") ==0)
{%>
          <option selected>Single</option>
          <%}else{%>
          <option>Single</option>
          <%}if(strTemp.compareToIgnoreCase("Married") ==0)
{%>
          <option selected>Married</option>
          <%}else{%>
          <option>Married</option>
          <%}if(strTemp.compareToIgnoreCase("Widow/Widower") ==0)
{%>
          <option selected>Widow/Widower</option>
          <%}else{%>
          <option>Widow/Widower</option>
          <%}if(strTemp.compareToIgnoreCase("Divorced") ==0)
{%>
          <option selected>Divorced</option>
          <%}else{%>
          <option>Divorced</option>
          <%}%>
        </select></td>
      <td height="25"><input name="maiden_name" type="text" size="32" maxlength="64" value="<%=WI.fillTextValue("maiden_name")%>"></td>
      <td height="25"><input name="spouse_name" type="text" size="32" maxlength="64" value="<%=WI.fillTextValue("spouse_name")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp; No. of children :
        <input name="no_of_children" type="text" size="2" value="<%=WI.fillTextValue("no_of_children")%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
      </td>
      <td  colspan="2" height="25" <%if(strSchoolCode.startsWith("AUF")){%>style="color:#FF0000"<%}%>>Email Address:
        <input name="email" type="text" size="36" maxlength="64" value="<%=WI.fillTextValue("email")%>">
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp; Birth Order&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:
      <input name="birth_order" type="text" size="2" value="<%=WI.fillTextValue("birth_order")%>" maxlength="2"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td height="25"  colspan="2" valign="top">
	  <!--<font size="1">(Temp. ID &amp;
        Password will be sent to this Email ID)</font>--></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25" colspan="3"><strong><font color="#FFFFFF" size="2">&nbsp;
        I B &#8211; ALIEN STATUS DATA (Mandatory for alien/foreigner student only)</font></strong></td>
    </tr>
    <tr>
      <td width="34%" height="20" valign="bottom">&nbsp; Visa Status</td>
      <td width="32%" valign="bottom">Authorized Stay</td>
      <td width="34%" valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp; <input name="visa_status" type="text" size="32" maxlength="32" value="<%=WI.fillTextValue("visa_status")%>"></td>
      <td><input name="authorized_stay" type="text" size="32" maxlength="32" value="<%=WI.fillTextValue("authorized_stay")%>"></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Passport No.</td>
      <td height="15" valign="bottom">Place of Issue</td>
      <td valign="bottom">Expiration Date <font size="1">(mm/dd/yyyy)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <input name="pp_number" type="text" size="32" maxlength="24" value="<%=WI.fillTextValue("pp_number")%>"></td>
      <td height="25"><input name="place_issued" type="text" size="32" maxlength="24" value="<%=WI.fillTextValue("place_issued")%>"></td>
      <td><input name="mm_poi_expire" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("mm_poi_expire")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="dd_poi_expire" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("dd_poi_expire")%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="yyyy_poi_expire" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("yyyy_poi_expire")%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> </td>
    </tr>
    <tr valign="bottom">
      <td height="20">&nbsp; ACR NO.</td>
      <td height="20">Date of Issue<font size="1">(mm/dd/yyyy)</font></td>
      <td>Expiration Date <font size="1">(mm/dd/yyyy)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <input name="acr_no" type="text" size="32" maxlength="32" value="<%=WI.fillTextValue("acr_no")%>"></td>
      <td height="25"><input name="mm_acr_doi" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("mm_acr_doi")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="dd_acr_doi" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("dd_acr_doi")%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="yyyy_acr_doi" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("yyyy_acr_doi")%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="mm_acr_expire" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("mm_acr_expire")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="dd_acr_expire" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("dd_acr_expire")%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="yyyy_acr_expire" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("yyyy_acr_expire")%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> </td>
    </tr>
    <tr valign="bottom">
      <td height="25">&nbsp; CRTS NO.</td>
      <td height="25">Date of Issue<font size="1">(mm/dd/yyyy)</font></td>
      <td>Expiration Date <font size="1">(mm/dd/yyyy)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <input name="crts_no" type="text" size="32" maxlength="32" value="<%=WI.fillTextValue("crts_no")%>"></td>
      <td height="25"><input name="mm_crts_doi" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("mm_crts_doi")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        / <input name="dd_crts_doi" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("dd_crts_doi")%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="yyyy_crts_doi" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("yyyy_crts_doi")%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="mm_crts_expire" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("mm_crts_expire")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="dd_crts_expire" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("dd_crts_expire")%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="yyyy_crts_expire" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("yyyy_crts_expire")%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> </td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25" colspan="2"><strong><font color="#FFFFFF" >&nbsp;
        II &#8211; RESIDENCE DATA</font></strong></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="bottom">&nbsp;
        <font color="#0000FF"><u>Home Address: </u></font></td>
    </tr>
    <tr style="color:#FF0000">
      <td width="50%" height="20" valign="bottom">&nbsp; Apartment Name/House
        No./Street/Barangay <font color="#FF0000">*</font></td>
      <td width="50%" valign="bottom">City/Municipality <font color="#FF0000">*</font></td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="res_house_no" type="text" size="40" maxlength="64" value="<%=WI.fillTextValue("res_house_no")%>"></td>
      <td valign="bottom"><input name="res_city" type="text" size="40" maxlength="32" value="<%=WI.fillTextValue("res_city")%>"></td>
    </tr>
    <tr style="color:#FF0000">
      <td height="20" valign="bottom" style="color:#FF0000">&nbsp; Province/State <font color="#FF0000">*</font>
      </td>
      <td valign="bottom">Country <font color="#FF0000">*</font></td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="res_provience" type="text" size="40" maxlength="32" value="<%=WI.fillTextValue("res_provience")%>"></td>
      <td valign="bottom">
<%
strTemp = WI.fillTextValue("res_country");
if(strTemp.length() == 0) 
	strTemp = "Philippines";
%>	  <input name="res_country" type="text" size="40" maxlength="32" value="<%=strTemp%>"></td>
    </tr>
    <tr style="color:#FF0000">
      <td height="20" valign="bottom">&nbsp; <font color="#FF0000">Zipcode *</font></td>
      <td valign="bottom">Telephone Nos. * </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="res_zip" type="text" size="40" maxlength="10" value="<%=WI.fillTextValue("res_zip")%>"></td>
      <td valign="bottom"><input name="res_tel" type="text" size="40" maxlength="32" value="<%=WI.fillTextValue("res_tel")%>"></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="bottom">&nbsp;
        <font color="#0000FF"><u>Current Contact Address: </u></font>
		<input type="checkbox" onClick="CopyAddr('1');"> Copy Home Address
	  </td>
    </tr>
    <tr style="color:#FF0000">
      <td height="20" valign="bottom">&nbsp; Contact
        Person/Guardian Name <font color="#FF0000">*</font> </td>
      <td valign="bottom">Relation <font color="#FF0000">*</font></td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="con_per_name" type="text" size="40" maxlength="64" value="<%=WI.fillTextValue("con_per_name")%>"></td>
      <td valign="bottom"><input name="con_per_relation" type="text" size="40" maxlength="24" value="<%=WI.fillTextValue("con_per_relation")%>"></td>
    </tr>
    <tr style="color:#FF0000">
      <td height="20" valign="bottom">&nbsp; Apartment
        Name/House No./Street/Barangay  <font color="#FF0000">*</font></td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2" height="25" valign="bottom">&nbsp;
         <input name="con_house_no" type="text" size="40" maxlength="64" value="<%=WI.fillTextValue("con_house_no")%>"></td>
    </tr>
    <tr style="color:#FF0000">
      <td height="20" valign="bottom">&nbsp; City/Municipality <font color="#FF0000">*</font></td>
      <td valign="bottom">Province/State <font color="#FF0000">*</font> </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="con_city" type="text" size="40" maxlength="32" value="<%=WI.fillTextValue("con_city")%>">
      </td>
      <td valign="bottom"><input name="con_provience" type="text" size="40" maxlength="32" value="<%=WI.fillTextValue("con_provience")%>"></td>
    </tr>
    <tr style="color:#FF0000">
      <td height="20" valign="bottom">&nbsp; Country <font color="#FF0000">*</font>      </td>
      <td valign="bottom">Zipcode  <font color="#FF0000">*</font></td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  
<%
strTemp = WI.fillTextValue("con_country");
if(strTemp.length() == 0) 
	strTemp = "Philippines";
%>
	  <input name="con_country" type="text" size="40" maxlength="32" value="<%=strTemp%>"></td>
      <td valign="bottom"><input name="con_zip" type="text" size="40" maxlength="10" value="<%=WI.fillTextValue("con_zip")%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Telephone
        Nos.</td>
      <td valign="bottom">Email Address </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="con_tel" type="text" size="40" maxlength="32" value="<%=WI.fillTextValue("con_tel")%>"></td>
      <td valign="bottom"><input name="con_email" type="text" size="40" maxlength="64" value="<%=WI.fillTextValue("con_email")%>"></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="bottom">&nbsp; <font color="#0000FF"><u>Emergency
        Contact Address:</u></font>
		<input type="checkbox" onClick="CopyAddr('2');"> Copy Current Contact Address
	  </td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Contact
        Person Name </td>
      <td valign="bottom">Relation</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="emgn_per_name" type="text" size="40" maxlength="64" value="<%=WI.fillTextValue("emgn_per_name")%>"></td>
      <td valign="bottom"><input name="emgn_per_rel" type="text" size="40" maxlength="24" value="<%=WI.fillTextValue("emgn_per_rel")%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Apartment
        Name/House No./Street/Barangay </td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2" height="25" valign="bottom">&nbsp;
         <input name="emgn_house_no" type="text" size="40" maxlength="64" value="<%=WI.fillTextValue("emgn_house_no")%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; City/Municipality</td>
      <td valign="bottom">Province/State </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="emgn_city" type="text" size="40" maxlength="32" value="<%=WI.fillTextValue("emgn_city")%>">
      </td>
      <td valign="bottom"><input name="emgn_provience" type="text" size="40" maxlength="32" value="<%=WI.fillTextValue("emgn_provience")%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Country</td>
      <td valign="bottom">Zipcode</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  
<%
strTemp = WI.fillTextValue("emgn_country");
if(strTemp.length() == 0) 
	strTemp = "Philippines";
%>
	  <input name="emgn_country" type="text" size="40" maxlength="32" value="<%=strTemp%>"></td>
      <td valign="bottom"><input name="emgn_zip" type="text" size="40" maxlength="10" value="<%=WI.fillTextValue("emgn_zip")%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Telephone
        Nos. </td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="emgn_tel" type="text" size="40" maxlength="32" value="<%=WI.fillTextValue("emgn_tel")%>"></td>
      <td valign="bottom">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25" colspan="6"><strong><font color="#FFFFFF" size="2">&nbsp;
        III &#8211; PHYSICAL DESCRIPTION</font></strong>
		<a href="javascript:Convert();">CLICK FOR CONVERSION</a></td>
    </tr>
    <tr valign="bottom">
      <td width="16%" height="20">&nbsp; Height(cms)</td>
      <td width="16%">Weight(lbs)</td>
      <td width="16%">Built</td>
      <td width="16%">Eye color</td>
      <td width="17%">Hair color</td>
      <td width="19%">Complexion</td>
    </tr>
    <tr>
      <td height="25">&nbsp;  <input name="height" type="text" size="3" maxlength="3" value="<%=WI.fillTextValue("height")%>"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="weight" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("weight")%>" 
	  	onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="built" type="text" size="10" maxlength="16" value="<%=WI.fillTextValue("built")%>"></td>
      <td><input name="eye_color" type="text" size="10" maxlength="16" value="<%=WI.fillTextValue("eye_color")%>"></td>
      <td><input name="hair_color" type="text" size="10" maxlength="16" value="<%=WI.fillTextValue("hair_color")%>"></td>
      <td><input name="complexion" type="text" size="10" maxlength="16" value="<%=WI.fillTextValue("complexion")%>"></td>
    </tr>
    <tr>
      <td colspan="3" height="20">&nbsp; Other Distinguishing
        Features </td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="6" height="25">&nbsp;  <input name="oth_prominent_feature" type="text" size="100" maxlength="64" value="<%=WI.fillTextValue("oth_prominent_feature")%>"></td>
    </tr>
    <tr>
      <td colspan="3" height="20">&nbsp; Physical Handicap
        or Disability (if any) </td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="6" height="25">&nbsp;  <input name="physical_disability" type="text" size="100" maxlength="128" value="<%=WI.fillTextValue("physical_disability")%>"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25" colspan="2"><strong><font color="#FFFFFF" size="2" >&nbsp;
        IV&#8211; FAMILY DATA</font></strong></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="bottom">&nbsp;
        <font color="#0000FF"><u>Parents:</u></font></td>
    </tr>
    <tr>
      <td width="48%" height="20" valign="bottom">&nbsp;
        Father&#8217;s Nam<font color="#FF0000">e</font></td>
      <td width="52%" valign="bottom">Occupation</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="f_name" type="text" size="40" maxlength="64" value="<%=WI.fillTextValue("f_name")%>"></td>
      <td valign="bottom"><input name="f_occupation" type="text" size="40" maxlength="32" value="<%=WI.fillTextValue("f_occupation")%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Company Name
      </td>
      <td valign="bottom">Telephone Nos. </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="f_comp_name" type="text" size="40" maxlength="64" value="<%=WI.fillTextValue("f_comp_name")%>"></td>
      <td valign="bottom"><input name="f_tel" type="text" size="40" maxlength="32" value="<%=WI.fillTextValue("f_tel")%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Company
        Address</td>
      <td valign="bottom">Father&#8217;s Email Address </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="f_comp_addr" type="text" size="40" value="<%=WI.fillTextValue("f_comp_addr")%>"></td>
      <td valign="bottom"><input name="f_email" type="text" size="40" maxlength="64" value="<%=WI.fillTextValue("f_email")%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Mother&#8217;s
        Name</td>
      <td valign="bottom">Occupation</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <input name="m_name" type="text" size="40" maxlength="64" value="<%=WI.fillTextValue("m_name")%>"></td>
      <td valign="bottom"><input name="m_occupation" type="text" size="40" maxlength="32" value="<%=WI.fillTextValue("m_occupation")%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Company Name
      </td>
      <td valign="bottom">Telephone Nos. </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <input name="m_comp_name" type="text" size="40" maxlength="64" value="<%=WI.fillTextValue("m_comp_name")%>"></td>
      <td valign="bottom"><input name="m_tel" type="text" size="40" maxlength="32" value="<%=WI.fillTextValue("m_tel")%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Company
        Address</td>
      <td valign="bottom">Mother&#8217;s Email Address </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <input name="m_comp_addr" type="text" size="40" value="<%=WI.fillTextValue("m_comp_addr")%>"></td>
      <td valign="bottom"><input name="m_email" type="text" size="40" maxlength="64" value="<%=WI.fillTextValue("m_email")%>"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="34%" height="20">&nbsp; <font color="#0000FF">Brother(s)/Sister(s):</font></td>
      <td width="33%">&nbsp;</td>
      <td width="33%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp; <u>NAME</u></td>
      <td><u>COURSE/OCCUPATION </u></td>
      <td><u>SCHOOL/COMPANY</u></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <u></u> <input name="bsis1_name" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis1_name")%>"></td>
      <td><input name="bsis1_occupation" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis1_occupation")%>"></td>
      <td><input name="bsis1_company" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis1_company")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <u></u> <input name="bsis2_name" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis2_name")%>"></td>
      <td><input name="bsis2_occupation" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis2_occupation")%>"></td>
      <td><input name="bsis2_company" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis2_company")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <u></u> <input name="bsis3_name" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis3_name")%>"></td>
      <td><input name="bsis3_occupation" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis3_occupation")%>"></td>
      <td><input name="bsis3_company" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis3_company")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <u></u> <input name="bsis4_name" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis4_name")%>"></td>
      <td><input name="bsis4_occupation" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis4_occupation")%>"></td>
      <td><input name="bsis4_company" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis4_company")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <u></u> <input name="bsis5_name" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis5_name")%>"></td>
      <td><input name="bsis5_occupation" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis5_occupation")%>"></td>
      <td><input name="bsis5_company" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis5_company")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <u></u> <input name="bsis6_name" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis6_name")%>"></td>
      <td><input name="bsis6_occupation" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis6_occupation")%>"></td>
      <td><input name="bsis6_company" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis6_company")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <u></u> <input name="bsis7_name" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis7_name")%>"></td>
      <td><input name="bsis7_occupation" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis7_occupation")%>"></td>
      <td><input name="bsis7_company" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis7_company")%>"></td>
    </tr>
	<tr>
      <td height="25">&nbsp; <u></u> <input name="bsis8_name" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis8_name")%>"></td>
      <td><input name="bsis8_occupation" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis8_occupation")%>"></td>
      <td><input name="bsis8_company" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("bsis8_company")%>"></td>
    </tr>

  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25" colspan="4"><strong><font color="#FFFFFF" size="2" >&nbsp;
        V&#8211; EDUCATIONAL BACKGROUND</font></strong></td>
    </tr>
    <tr>
      <td width="13%" height="25">&nbsp;</td>
      <td width="42%"><u>NAME</u></td>
      <td width="21%"><u>COURSE/YEAR GRADUATED</u></td>
      <td width="24%"><u>HONORS/AWARDS</u></td>
    </tr>
    <tr style="color:#FF0000">
      <td height="25">&nbsp; Elementary *</td>
      <td><select name="ELEM_SCH_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_NAME","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",WI.fillTextValue("ELEM_SCH_NAME"),false)%>
        </select></td>
      <td><input name="ELEM_COURSE_TAKEN" type="text" size="16" maxlength="64" value="<%=WI.fillTextValue("ELEM_COURSE_TAKEN")%>">
	  <input name="ELEM_YEAR_GRAD" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("ELEM_YEAR_GRAD")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="ELEM_HONOR_AWARD" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("ELEM_HONOR_AWARD")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp; High School</td>
      <td style="font-size:9px;"><select name="HIGH_SCH_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_NAME","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",WI.fillTextValue("HIGH_SCH_NAME"),false)%>
        </select><input type="checkbox" onClick="CopySchool('1');" name="_1"> Same as Elem</td>
      <td><input name="HIGH_COURSE_TAKEN" type="text" size="16" maxlength="64" value="<%=WI.fillTextValue("HIGH_COURSE_TAKEN")%>">
	  <input name="HIGH_YEAR_GRAD" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("HIGH_YEAR_GRAD")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="HIGH_HONOR_AWARD" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("HIGH_HONOR_AWARD")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp; College</td>
      <td><select name="COLLEGE_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_NAME","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",WI.fillTextValue("COLLEGE_NAME"),false)%>
        </select></td>
      <td><input name="COLLEGE_COURSE_TAKEN" type="text" size="16" maxlength="64" value="<%=WI.fillTextValue("COLLEGE_COURSE_TAKEN")%>">
	  <input name="COLLEGE_YEAR_GRAD" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("COLLEGE_YEAR_GRAD")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="COLLEGE_HONOR_AWARD" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("COLLEGE_HONOR_AWARD")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp; Post Graduate</td>
      <td><select name="PG_SCH_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_NAME","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",WI.fillTextValue("PG_SCH_NAME"),false)%>
        </select></td>
      <td><input name="PG_COURSE_TAKEN" type="text" size="16" maxlength="64" value="<%=WI.fillTextValue("PG_COURSE_TAKEN")%>">
	  <input name="PG_YEAR_GRAD" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("PG_YEAR_GRAD")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="PG_HONOR_AWARD" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("PG_HONOR_AWARD")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp; Vocational</td>
      <td><select name="VOC_SCH_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_NAME","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",WI.fillTextValue("VOC_SCH_NAME"),false)%>
        </select></td>
      <td><input name="VOC_COURSE_TAKEN" type="text" size="16" maxlength="64" value="<%=WI.fillTextValue("VOC_COURSE_TAKEN")%>">
	  <input name="VOC_YEAR_GRAD" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("VOC_YEAR_GRAD")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="VOC_HONOR_AWARD" type="text" size="28" maxlength="64" value="<%=WI.fillTextValue("VOC_HONOR_AWARD")%>"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25"  colspan="2"><strong><font color="#FFFFFF" size="2" >&nbsp; VI&#8211;
        GENERAL QUALIFICATION</font></strong></td>
    </tr>
    <tr>
      <td width="10%">&nbsp;<font color="#0000FF">Languages:</font></td>
      <td height="25"> <input name="LANGUAGE_KNOWN" type="text" size="90" value="<%=WI.fillTextValue("LANGUAGE_KNOWN")%>"></td>
    </tr>
    <tr>
      <td>&nbsp;<font color="#0000FF">Hobbies:</font></td>
      <td height="25">
        <input name="HOBBY" type="text" size="90" value="<%=WI.fillTextValue("HOBBY")%>"> </td>
    </tr>
    <tr>
      <td><font color="#0000FF">&nbsp;Skills:</font></td>
      <td height="25">
        <input name="SKILL" type="text" size="90" value="<%=WI.fillTextValue("SKILL")%>"></td>
    </tr>
    <tr>
      <td><font color="#0000FF">&nbsp;Talents:</font></td>
      <td height="25">
        <input name="TALENT" type="text" size="90" value="<%=WI.fillTextValue("TALENT")%>"></td>
    </tr>
    <tr>
      <td>&nbsp;<font color="#0000FF">Sports:</font></td>
      <td height="25">
        <input name="SPORT" type="text" size="90" value="<%=WI.fillTextValue("SPORT")%>"></td>
    </tr>
    <tr>
      <td colspan="2" valign="bottom"><font color="#0000FF">&nbsp;Honors/Awards/Merits: (ex. &quot;Model
        Student, 1990&quot;)</font> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">
<input name="AWARD" type="text" size="90" value="<%=WI.fillTextValue("AWARD")%>"></td>
    </tr>

    <tr>
      <td colspan="2" valign="bottom">&nbsp;<font color="#0000FF">Extra-Curricular Activities
        : (Organizations, Clubs, etc)</font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">
<input name="EXT_CURRICULAR_ACT" type="text" size="90" value="<%=WI.fillTextValue("EXT_CURRICULAR_ACT")%>"></td>
    </tr>

  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25" colspan="2"><strong><font color="#FFFFFF" size="2">&nbsp;
        VII&#8211; REFERENCES</font></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;&nbsp;&nbsp;Write two or three references 
        who can vouch or guarantee for your total behavior.</td>
    </tr>
    <tr>
      <td width="35%" height="25">&nbsp;&nbsp;&nbsp;<u>NAME</u></td>
      <td width="65%"><u>ADDRESS/TEL. NOS.</u></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp; <input name="REF_NAME1" type="text" size="30" maxlength="64" value="<%=WI.fillTextValue("REF_NAME1")%>"></td>
      <td><input name="REF_ADDR1" type="text" size="50" maxlength="128" value="<%=WI.fillTextValue("REF_ADDR1")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp; <input name="REF_NAME2" type="text" size="30" maxlength="64" value="<%=WI.fillTextValue("REF_NAME2")%>"></td>
      <td><input name="REF_ADDR2" type="text" size="50" maxlength="128" value="<%=WI.fillTextValue("REF_ADDR2")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp; <input name="REF_NAME3" type="text" size="30" maxlength="64" value="<%=WI.fillTextValue("REF_NAME3")%>"></td>
      <td><input name="REF_ADDR3" type="text" size="50" maxlength="128" value="<%=WI.fillTextValue("REF_ADDR3")%>"></td>
    </tr>


  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="30%">&nbsp;</td>
      <td width="55%">&nbsp;</td>
      <td width="15%">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><input type="image" src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></td>
    </tr>
 <%}//only if one course is selected.. 
 
 }//end of showing the information page only if vCourseOffered.size() > 0)
%>    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td bgcolor="#47768F">&nbsp;</td>
      <td bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>


<input name="appl_catg" type="hidden" value="<%=WI.fillTextValue("appl_catg")%>">
<input name="s_course" type="hidden" value="<%=WI.fillTextValue("s_course")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
