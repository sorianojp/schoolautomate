<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date,enrollment.NAApplicationForm,enrollment.PersonalInfoManagement,java.util.StringTokenizer" %>
<%
 //only used to load the Course offered, degree, year offered, semester offered and curriculum year (School year)
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	String strTempID = (String)request.getSession(false).getAttribute("tempId");
	if(strTempID == null && request.getSession(false).getAttribute("userId") != null && 
		request.getParameter("temp_id") != null) {
		strTempID = request.getParameter("temp_id");
		request.getSession(false).setAttribute("tempId", strTempID);	
	}
	
	boolean bolLoggedIn = true;
	Vector vEditInfo[] = null;
	
	Vector vRecruit = null;
	
	Vector vRetResult  = new Vector();
	Vector vCourseApplInfo = null; //note here - basic information of course.
	String strEditMsg = "";
    PersonalInfoManagement pInfo = new PersonalInfoManagement();
    
	String[] astrConvertYr = {"N/A","1st","2nd","3rd","4th","5th","6th"};
	String[] astrConvertSem= {"Summer","1st Term","2nd Term","3rd Term","4th Term","5th Term"};

	if(strTempID == null || strTempID.trim().length() ==0)
		bolLoggedIn = false;
		
	boolean bolIsBasic = false;
	
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
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

	NAApplicationForm napplForm = new NAApplicationForm();
	//edit only if it is submitted.
	if(request.getParameter("editInformation") != null && request.getParameter("editInformation").compareTo("1") ==0) {
		napplForm.editPersonalInfo(dbOP, request);
		strEditMsg = napplForm.getErrMsg();
		
		
	}
	
	vEditInfo = napplForm.viewTempStudInfo(dbOP, strTempID);
	vCourseApplInfo = napplForm.getCourseApplInfo(dbOP, strTempID);
	
	if(vEditInfo == null || vEditInfo[0].size() ==0 || vCourseApplInfo == null || vCourseApplInfo.size() ==0)
		strErrMsg = napplForm.getErrMsg();
	else {
		if(vCourseApplInfo.elementAt(3) == null) {
			bolIsBasic = true;
			astrConvertSem[1] = "Regular";
		}
	}
	
	vRecruit = pInfo.getStudentRecruitDetails(dbOP,strTempID, true);	

}//if user is not logged in - show error message.
if(vRecruit == null)
	vRecruit = new Vector();


String strSchoolCode = dbOP.getSchoolIndex();
String strSchoolName = dbOP.getResultOfAQuery("select school_name from SYS_INFO", 0);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">

</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function CheckCourseOfferedStatic()
{
	var Proceed = true;var ErrMsg = "";
	var CourseIndex = document.formstep1.course_index.value;
	var CourseName = document.formstep1.course_name.value;
	var SYFrom = document.formstep1.sy_from.value;
	var SYTo = document.formstep1.sy_to.value;
	var Year = document.formstep1.year_level.value;
	var Semester = document.formstep1.semester.value;
	if(CourseIndex == "0" || CourseIndex.length ==0 || SYFrom.length == 0 || SYTo.length == 0 || Year.length == 0 || Semester.length == 0)
	{
		ErrMsg +=" Course information missing.";
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
	document.formstep1.submit();
}
function submitonce(theform)
{
//if IE 4+ or NS 6+
	//form is submitted here.
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
}
function EditInformation()
{
	document.formstep1.editInformation.value="1";
} 
function Convert() {
	var pgLoc = 
	"../../../../commfile/conversion.jsp?called_fr_form=formstep1&cm_field_name=height&lb_field_name=weight";
	
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
function CopySchool(strCopyIndex) {
	if(strCopyIndex == '1') {//copy from hs to elem.
		if(document.formstep1._1.checked)
			document.formstep1.HIGH_SCH_NAME.selectedIndex = document.formstep1.ELEM_SCH_NAME.selectedIndex;
	}

}
function RelayPrint()
{
	if (document.formstep1.tempId.value.length > 0) 
		location = "gspis_print.jsp?tempId="+document.formstep1.tempId.value;
	else
		alert (" Please enter student ID");
}
</script>

<body bgcolor="#9FBFD0">

<form name="formstep1" action="./gspis_page_edit_temp.jsp" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#47768F">
      <td height="26" colspan="3"><div align="center"><font color="#FFFFFF" ><strong>::::
          GENERAL STUDENT PERSONAL INFORMATION SHEET (GSPIS) ::::</strong></font></div></td>
    </tr>
    <%
if(strErrMsg != null){dbOP.cleanUP();%>
    <tr>
      <td height="10" colspan="3">&nbsp; <b><%=strErrMsg%></b></td>
    </tr>
    <%return;
}else{%>
    <tr>
      <td height="10" colspan="3">&nbsp; <strong><%=strEditMsg%></strong></td>
    </tr>
    <%}
if(!bolLoggedIn){
if(dbOP != null)
	dbOP.cleanUP();
%>
    <tr>
      <td height="10" colspan="3">&nbsp; <b>You are not logged on to the system.
        Please login to edit / view.</b></td>
    </tr>
    <%return;}%>
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td width="14%" height="25">&nbsp; COURSE </td>
      <td colspan="2"> 
	  <%if(bolIsBasic) {%>
	  	<%=dbOP.getBasicEducationLevel(Integer.parseInt((String)vCourseApplInfo.elementAt(0)))%>
	  <%}else{%>
  	   <%=(String)vCourseApplInfo.elementAt(3)%> : DEGREE - <%=(String)vCourseApplInfo.elementAt(4)%>
	  <%}%>
	  
        <%if(bolIsBasic){%>
			<input type="hidden" name="course_index" value="0">
		<%}else{%>
			<input type="hidden" name="course_index" value="<%=(String)vCourseApplInfo.elementAt(2)%>">
        <%}%>
		<input type="hidden" name="course_name" value="<%=(String)vCourseApplInfo.elementAt(3)%>">
        <font size="1">(to change course, please contact school)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <%if(!bolIsBasic){%>YEAR LEVEL<%}%></td>
      <td width="18%" height="25"><%if(!bolIsBasic){%>
	  	<%=astrConvertYr[Integer.parseInt(WI.getStrValue((String)vCourseApplInfo.elementAt(0), "0"))]%>
	  <%}%>      </td>
      <td width="68%" height="25" style='font-size:22px;'>Enrolling SY-Term: <%=astrConvertSem[Integer.parseInt((String)vCourseApplInfo.elementAt(1))]%>, <%=vEditInfo[1].elementAt(12)%> - <%=vEditInfo[1].elementAt(13)%>
        <input type="hidden" name="year_level" value="<%=(String)vCourseApplInfo.elementAt(0)%>">
        <input type="hidden" name="semester" value="<%=(String)vCourseApplInfo.elementAt(1)%>">
        <input type="hidden" name="sch_yr_from" value="<%=vEditInfo[1].elementAt(12)%>">
        <input type="hidden" name="sch_yr_to" value="<%=vEditInfo[1].elementAt(13)%>">
        
        <!--<input type ="text" class="textbox_noborder" readonly="yes" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'"name="sch_yr_from" maxlength="4" size="4" value="<%=WI.getStrValue(vEditInfo[1].elementAt(12))%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" style='font-size:18px;'>
        -  
        <input type ="text" class="textbox_noborder" readonly="yes" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'"name="sch_yr_to" maxlength="4" size="4" value="<%=WI.getStrValue(vEditInfo[1].elementAt(13))%>"
		onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" style='font-size:18px;'>
		-->
		</td>
    </tr>
    <tr>
      <td height="25">&nbsp; CURR. YEAR</td>
      <td height="25"> <%=(String)vCourseApplInfo.elementAt(5)%> - <%=(String)vCourseApplInfo.elementAt(6)%>      </td>
      <td height="25">
	  <%if(!bolIsBasic){%>
	  	<font size="1"> <a href="javascript:CheckCourseOfferedStatic();"><img src="../../../../images/view.gif" border="0"></a>
        Click here to view if course is open for admission.</font> 
	  <%}%>
		<input type="hidden" name="sy_from" value="<%=(String)vCourseApplInfo.elementAt(5)%>">
        <input type="hidden" name="sy_to" value="<%=(String)vCourseApplInfo.elementAt(6)%>">
		&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="javascript:RelayPrint()"><img src="../../../../images/print.gif" border="0"></a> 		</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25" colspan="3"><strong><font color="#FFFFFF" size="2">&nbsp;
        I A &#8211; PERSONAL DATA</font></strong></td>
    </tr>
    <tr>
      <td width="34%" height="20" valign="bottom">&nbsp; Last Name </td>
      <td width="32%" valign="bottom">First Name </td>
      <td width="34%" valign="bottom">Middle Name </td>
    </tr>
    <tr>
      <td height="25">&nbsp; <input name="lname" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="30" maxlength="32" value="<%=(String)vEditInfo[0].elementAt(9)%>" <%if(strSchoolCode.startsWith("AUF")){%>OnKeyUP="javascript:this.value=this.value.toUpperCase();"<%}%>></td>
      <td><input name="fname" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="30" maxlength="32" value="<%=(String)vEditInfo[0].elementAt(7)%>" <%if(strSchoolCode.startsWith("AUF")){%>OnKeyUP="javascript:this.value=this.value.toUpperCase();"<%}%>></td>
      <td><input name="mname" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="30" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(8))%>" <%if(strSchoolCode.startsWith("AUF")){%>OnKeyUP="javascript:this.value=this.value.toUpperCase();"<%}%>></td>
    </tr>
    <tr>
      <td colspan="3" height="25"> &nbsp; Name in Native Language Character &nbsp;
        <input name="native_lan" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="64" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(10))%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Gender </td>
      <td height="15" valign="bottom">Religion </td>
      <td height="15" valign="bottom">Nationality</td>
    </tr>
    <tr>
      <td height="25">&nbsp; <select name="gender">
          <%
strTemp = WI.getStrValue((String)vEditInfo[0].elementAt(11));
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
      <td height="25"><select name="religion">
          <option value=""></option>
 <%
strTemp = WI.getStrValue((String)vEditInfo[0].elementAt(12));
if(strTemp.length() == 0) 
	strTemp = "Roman Catholic";
%>
          <%=dbOP.loadCombo("RELIGION","RELIGION"," FROM HR_PRELOAD_RELIGION order by religion",strTemp,false)%>
        </select>
	  </td>
      <td height="25"><select name="nationality">
          <option value=""></option>
<%
strTemp = WI.getStrValue((String)vEditInfo[0].elementAt(13));
if(strTemp.length() == 0) 
	strTemp = "Filipino";
%>
          <%=dbOP.loadCombo("NATIONALITY","NATIONALITY"," FROM HR_PRELOAD_NATIONALITY order by nationality",strTemp,false)%>
        </select>
	  </td>
    </tr>
    <tr valign="bottom">
      <td height="20">&nbsp; Date of Birth(mm/dd/yyyy)</td>
      <td height="20">Place of Birth </td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <%
strTemp = WI.getStrValue((String)vEditInfo[0].elementAt(14));
%>
      <td height="25">&nbsp; <input name="dob" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" >
        <a href="javascript:show_calendar('formstep1.dob');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar.gif" border="0"></a></td>
      <td height="25"><input name="place_of_birth" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="30" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(15))%>">
      </td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr valign="bottom">
      <td height="25">&nbsp; Civil Status (If Married -&gt;) </td>
      <td height="25">Female : State Maiden Name</td>
      <td height="25">Male: Name of Spouse </td>
    </tr>
    <tr>
      <td height="25">&nbsp; <select name="civil_stat">
          <%
strTemp = WI.getStrValue((String)vEditInfo[0].elementAt(16));
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
      <td height="25"><input name="maiden_name" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="30" maxlength="64" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(17))%>"></td>
      <td height="25"><input name="spouse_name" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="30" maxlength="64" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(18))%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp; No. of children :
        <input name="no_of_children" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="2" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(19))%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
      </td>
      <td  colspan="2" height="25">Email Address:
        <input name="email" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="32" maxlength="64" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(20))%>">
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp; Birth Order &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:
        <input name="birth_order" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="2"  value="<%=WI.getStrValue(vEditInfo[1].elementAt(0))%>" maxlength="2"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td height="25"  colspan="2" valign="top"><font size="1">(Temp. ID &amp;
        Password will be sent to this Email ID)</font></td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25" colspan="3"><strong><font color="#FFFFFF" size="2">&nbsp;
        I B &#8211; ALIEN STATUS DATA (for alien/foreigner student only)</font></strong></td>
    </tr>
    <tr>
      <td width="34%" height="20" valign="bottom">&nbsp; Visa Status</td>
      <td width="32%" valign="bottom">Authorized Stay</td>
      <td width="34%" valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp; <input name="visa_status" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="30" maxlength="32" value="<%=WI.getStrValue(vEditInfo[1].elementAt(1))%>"></td>
      <td><input name="authorized_stay" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="30" maxlength="32" value="<%=WI.getStrValue(vEditInfo[1].elementAt(2))%>"></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Passport No.</td>
      <td height="15" valign="bottom">Place of Issue</td>
      <td valign="bottom">Expiration Date <font size="1">(mm/dd/yyyy)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <input name="pp_number" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="30" maxlength="24" value="<%=WI.getStrValue(vEditInfo[1].elementAt(3))%>"></td>
      <td height="25"><input name="place_issued" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="30" maxlength="24" value="<%=WI.getStrValue(vEditInfo[1].elementAt(4))%>"></td>
      <td>
<%
String strMM = "";
String strDD = "";String strYYYY = "";
StringTokenizer strToken = new StringTokenizer(WI.getStrValue(vEditInfo[1].elementAt(5)), "/");
if(strToken.hasMoreElements())
{
	strMM = (String)strToken.nextElement();
	strDD = (String)strToken.nextElement();
	strYYYY = (String)strToken.nextElement();
}%>
	  <input name="mm_poi_expire" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="2" maxlength="2" value="<%=strMM%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="dd_poi_expire" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="2" maxlength="2" value="<%=strDD%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="yyyy_poi_expire" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="4" maxlength="4" value="<%=strYYYY%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> </td>
    </tr>
    <tr valign="bottom">
      <td height="20">&nbsp; ACR NO.</td>
      <td height="20">Date of Issue<font size="1">(mm/dd/yyyy)</font></td>
      <td>Expiration Date <font size="1">(mm/dd/yyyy)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <input name="acr_no" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="30" maxlength="32" value="<%=WI.getStrValue(vEditInfo[1].elementAt(6))%>"></td>
      <td height="25">
<%
strToken = new StringTokenizer(WI.getStrValue(vEditInfo[1].elementAt(7)), "/");
if(strToken.hasMoreElements())
{
	strMM = (String)strToken.nextElement();
	strDD = (String)strToken.nextElement();
	strYYYY = (String)strToken.nextElement();
}
else
{strMM = "";strDD="";strYYYY="";}

	%>	  <input name="mm_acr_doi" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="2" maxlength="2" value="<%=strMM%>"
	onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="dd_acr_doi" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="2" maxlength="2" value="<%=strDD%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="yyyy_acr_doi" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="4" maxlength="4" value="<%=strYYYY%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
<%
strToken = new StringTokenizer(WI.getStrValue(vEditInfo[1].elementAt(8)), "/");
if(strToken.hasMoreElements())
{
	strMM = (String)strToken.nextElement();
	strDD = (String)strToken.nextElement();
	strYYYY = (String)strToken.nextElement();
}
else
{strMM = "";strDD="";strYYYY="";}
%>
      <td><input name="mm_acr_expire" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="2" maxlength="2" value="<%=strMM%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="dd_acr_expire" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="2" maxlength="2" value="<%=strDD%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="yyyy_acr_expire" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="4" maxlength="4" value="<%=strYYYY%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> </td>
    </tr>
    <tr valign="bottom">
      <td height="25">&nbsp; CRTS NO.</td>
      <td height="25">Date of Issue<font size="1">(mm/dd/yyyy)</font></td>
      <td>Expiration Date <font size="1">(mm/dd/yyyy)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <input name="crts_no" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="30" maxlength="32" value="<%=WI.getStrValue(vEditInfo[1].elementAt(9))%>"></td>
      <td height="25">
<%
strToken = new StringTokenizer(WI.getStrValue(vEditInfo[1].elementAt(10)), "/");
if(strToken.hasMoreElements())
{
	strMM = (String)strToken.nextElement();
	strDD = (String)strToken.nextElement();
	strYYYY = (String)strToken.nextElement();
}
else
{strMM = "";strDD="";strYYYY="";}
%>
 	  <input name="mm_crts_doi" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="2" maxlength="2" value="<%=strMM%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        / <input name="dd_crts_doi" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="2" maxlength="2" value="<%=strDD%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="yyyy_crts_doi" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="4" maxlength="4" value="<%=strYYYY%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td>
<%
strToken = new StringTokenizer(WI.getStrValue(vEditInfo[1].elementAt(11)), "/");
if(strToken.hasMoreElements())
{
	strMM = (String)strToken.nextElement();
	strDD = (String)strToken.nextElement();
	strYYYY = (String)strToken.nextElement();
}
else
{strMM = "";strDD="";strYYYY="";}
%>
 	  <input name="mm_crts_expire" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="2" maxlength="2" value="<%=strMM%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="dd_crts_expire" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="2" maxlength="2" value="<%=strDD%>"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="yyyy_crts_expire" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="4" maxlength="4" value="<%=strYYYY%>"
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
    <tr>
      <td width="50%" height="20" valign="bottom">&nbsp; Apartment Name/House
        No./Street/Barangay </td>
      <td width="50%" valign="bottom">City/Municipality </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <input name="res_house_no" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="64" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(25))%>"></td>
      <td valign="bottom"><input name="res_city" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(26))%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Province/State
      </td>
      <td valign="bottom">Country</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="res_provience" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(27))%>"></td>
      <td valign="bottom"><input name="res_country" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(28))%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Zipcode</td>
      <td valign="bottom">Telephone Nos. </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="res_zip" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="10" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(29))%>"></td>
      <td valign="bottom"><input name="res_tel" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(30))%>"></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="bottom">&nbsp;
        <font color="#0000FF"><u>Current Contact Address: </u></font> <input type="checkbox" name="copy_cur" onClick="CopyAddr('1');"> 
        Copy Home Address</td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Contact
        Person/Guardian Name </td>
      <td valign="bottom">Relation</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="con_per_name" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="64" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(31))%>"></td>
      <td valign="bottom"><input name="con_per_relation" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="24" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(32))%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Apartment
        Name/House No./Street/Barangay </td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2" height="25" valign="bottom">&nbsp;
         <input name="con_house_no" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="64" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(33))%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; City/Municipality</td>
      <td valign="bottom">Province/State </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="con_city" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(34))%>">
      </td>
      <td valign="bottom"><input name="con_provience" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(35))%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Country
      </td>
      <td valign="bottom">Zipcode </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="con_country" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(36))%>"></td>
      <td valign="bottom"><input name="con_zip" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="10" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(37))%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Telephone
        Nos.</td>
      <td valign="bottom">Email Address </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="con_tel" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(38))%>"></td>
      <td valign="bottom"><input name="con_email" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="64" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(39))%>"></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="bottom">&nbsp; <font color="#0000FF"><u>Emergency
        Contact Address: </u></font> <input type="checkbox" name="copy_cur" onClick="CopyAddr('2');"> Copy Current Contact Address</td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Contact
        Person Name </td>
      <td valign="bottom">Relation</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="emgn_per_name" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="64" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(40))%>"></td>
      <td valign="bottom"><input name="emgn_per_rel" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="24" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(41))%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Apartment
        Name/House No./Street/Barangay </td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2" height="25" valign="bottom">&nbsp;
         <input name="emgn_house_no" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="64" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(42))%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; City/Municipality</td>
      <td valign="bottom">Province/State </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="emgn_city" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(43))%>">
      </td>
      <td valign="bottom"><input name="emgn_provience" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(44))%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Country</td>
      <td valign="bottom">Zipcode</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="emgn_country" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(45))%>"></td>
      <td valign="bottom"><input name="emgn_zip" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="10" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(46))%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Telephone
        Nos. </td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="emgn_tel" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(47))%>"></td>
      <td valign="bottom">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25" colspan="6"><strong><font color="#FFFFFF" size="2">&nbsp;
        III &#8211; PHYSICAL DESCRIPTION</font></strong><a href="javascript:Convert();">CLICK FOR CONVERSION</a></td>
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
      <td height="25">&nbsp;  <input name="height" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="3" maxlength="4" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(48))%>"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="weight" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="3" maxlength="4" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(49))%>"></td>
      <td><input name="built" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="10" maxlength="16" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(50))%>"></td>
      <td><input name="eye_color" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="10" maxlength="16" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(51))%>"></td>
      <td><input name="hair_color" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="10" maxlength="16" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(52))%>"></td>
      <td><input name="complexion" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="10" maxlength="16" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(53))%>"></td>
    </tr>
    <tr>
      <td colspan="3" height="20">&nbsp; Other Distinguishing
        Features </td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="6" height="25">&nbsp;  <input name="oth_prominent_feature" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="100" maxlength="64" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(54))%>"></td>
    </tr>
    <tr>
      <td colspan="3" height="20">&nbsp; Physical Handicap
        or Disability (if any) </td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="6" height="25">&nbsp;  <input name="physical_disability" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="100" maxlength="128" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(55))%>"></td>
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
        Father&#8217;s Name </td>
      <td width="52%" valign="bottom">Occupation</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="f_name" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="64" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(56))%>"></td>
      <td valign="bottom"><input name="f_occupation" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(57))%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Company Name
      </td>
      <td valign="bottom">Telephone Nos. </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="f_comp_name" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="64" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(58))%>"></td>
      <td valign="bottom"><input name="f_tel" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(59))%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Company
        Address</td>
      <td valign="bottom">Father&#8217;s Email Address </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;  <input name="f_comp_addr" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(60))%>"></td>
      <td valign="bottom"><input name="f_email" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(61))%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Mother&#8217;s
        Name </td>
      <td valign="bottom">Occupation</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <input name="m_name" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(62))%>"></td>
      <td valign="bottom"><input name="m_occupation" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(63))%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Company Name
      </td>
      <td valign="bottom">Telephone Nos. </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <input name="m_comp_name" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(64))%>"></td>
      <td valign="bottom"><input name="m_tel" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(65))%>"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Company
        Address</td>
      <td valign="bottom">Mother&#8217;s Email Address </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <input name="m_comp_addr" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" value="<%=WI.getStrValue(vEditInfo[0].elementAt(66))%>"></td>
      <td valign="bottom"><input name="m_email" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="40" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(67))%>"></td>
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
      <td height="25">&nbsp; <u></u> <input name="bsis1_name" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(68))%>"></td>
      <td><input name="bsis1_occupation" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(69))%>"></td>
      <td><input name="bsis1_company" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(70))%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <u></u> <input name="bsis2_name" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(71))%>"></td>
      <td><input name="bsis2_occupation" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(72))%>"></td>
      <td><input name="bsis2_company" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(73))%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <u></u> <input name="bsis3_name" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(74))%>"></td>
      <td><input name="bsis3_occupation" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(75))%>"></td>
      <td><input name="bsis3_company" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(76))%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <u></u> <input name="bsis4_name" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(77))%>"></td>
      <td><input name="bsis4_occupation" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(78))%>"></td>
      <td><input name="bsis4_company" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(79))%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <u></u> <input name="bsis5_name" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(80))%>" ></td>
      <td><input name="bsis5_occupation" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(81))%>" ></td>
      <td><input name="bsis5_company" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(82))%>" ></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <u></u> <input name="bsis6_name" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(83))%>" ></td>
      <td><input name="bsis6_occupation" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(84))%>" ></td>
      <td><input name="bsis6_company" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(85))%>" ></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <u></u> <input name="bsis7_name" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(86))%>" ></td>
      <td><input name="bsis7_occupation" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(87))%>" ></td>
      <td><input name="bsis7_company" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(88))%>" ></td>
    </tr>
	<tr>
      <td height="25">&nbsp; <u></u> <input name="bsis8_name" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(89))%>" ></td>
      <td><input name="bsis8_occupation" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(90))%>" ></td>
      <td><input name="bsis8_company" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="24" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(91))%>" ></td>
    </tr>

  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25" colspan="4"><strong><font color="#FFFFFF" size="2" >&nbsp;
        V&#8211; EDUCATIONAL BACKGROUND</font></strong></td>
    </tr>
    <tr>
      <td width="15%" height="25">&nbsp;</td>
      <td width="41%"><u>NAME</u></td>
      <td width="22%"><u>COURSE/YEAR GRADUATED</u></td>
      <td width="22%"><u>HONORS/AWARDS</u></td>
    </tr>
    <tr>
      <td height="25">&nbsp; Elementary</td>
      <td><select name="ELEM_SCH_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_NAME","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",WI.getStrValue(vEditInfo[0].elementAt(92)),false)%>
        </select></td>
      <td><input name="ELEM_COURSE_TAKEN" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="16" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(93))%>" >
	  <input name="ELEM_YEAR_GRAD" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="4" maxlength="4" value="<%=WI.getStrValue(vEditInfo[0].elementAt(94))%>" 
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="ELEM_HONOR_AWARD" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="22" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(95))%>" ></td>
    </tr>
    <tr>
      <td height="25">&nbsp; High School</td>
      <td style="font-size:9px;"><select name="HIGH_SCH_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_NAME","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",WI.getStrValue(vEditInfo[0].elementAt(96)),false)%>
        </select><input type="checkbox" onClick="CopySchool('1');" name="_1"> Same as Elem</td>
      <td><input name="HIGH_COURSE_TAKEN" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="16" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(97))%>" >
	  <input name="HIGH_YEAR_GRAD" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="4" maxlength="4" value="<%=WI.getStrValue(vEditInfo[0].elementAt(98))%>" 
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="HIGH_HONOR_AWARD" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="22" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(99))%>" ></td>
    </tr>
    <tr>
      <td height="25">&nbsp; College</td>
      <td><select name="COLLEGE_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_NAME","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",WI.getStrValue(vEditInfo[0].elementAt(100)),false)%>
        </select></td>
      <td><input name="COLLEGE_COURSE_TAKEN" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="16" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(101))%>" >
	  <input name="COLLEGE_YEAR_GRAD" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="4" maxlength="4" value="<%=WI.getStrValue(vEditInfo[0].elementAt(102))%>" 
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="COLLEGE_HONOR_AWARD" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="22" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(103))%>" ></td>
    </tr>
    <tr>
      <td height="25">&nbsp; Post Graduate</td>
      <td><select name="PG_SCH_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_NAME","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",WI.getStrValue(vEditInfo[0].elementAt(104)),false)%>
        </select></td>
      <td><input name="PG_COURSE_TAKEN" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="16" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(105))%>"  >
	  <input name="PG_YEAR_GRAD" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="4" maxlength="4" value="<%=WI.getStrValue(vEditInfo[0].elementAt(106))%>" 
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="PG_HONOR_AWARD" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="22" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(107))%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp; Vocational</td>
      <td><select name="VOC_SCH_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_NAME","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",WI.getStrValue(vEditInfo[0].elementAt(108)),false)%>
        </select></td>
      <td><input name="VOC_COURSE_TAKEN" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="16" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(109))%>" >
	  <input name="VOC_YEAR_GRAD" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="4" maxlength="4" value="<%=WI.getStrValue(vEditInfo[0].elementAt(110))%>" 
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="VOC_HONOR_AWARD" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="22" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(111))%>" ></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25"  colspan="2"><strong><font color="#FFFFFF" size="2" >&nbsp; VI&#8211;
        GENERAL QUALIFICATION</font></strong></td>
    </tr>
    <tr>
      <td width="10%">&nbsp;<font color="#0000FF">Languages:</font></td>
      <td height="25"> <input name="LANGUAGE_KNOWN" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="80" value="<%=WI.getStrValue(vEditInfo[0].elementAt(112))%>" ></td>
    </tr>
    <tr>
      <td>&nbsp;<font color="#0000FF">Hobbies:</font></td>
      <td height="25">
        <input name="HOBBY" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="80" value="<%=WI.getStrValue(vEditInfo[0].elementAt(113))%>" > </td>
    </tr>
    <tr>
      <td><font color="#0000FF">&nbsp;Skills:</font></td>
      <td height="25">
        <input name="SKILL" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="80" value="<%=WI.getStrValue(vEditInfo[0].elementAt(114))%>" ></td>
    </tr>
    <tr>
      <td><font color="#0000FF">&nbsp;Talents:</font></td>
      <td height="25">
        <input name="TALENT" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="80" value="<%=WI.getStrValue(vEditInfo[0].elementAt(115))%>" ></td>
    </tr>
    <tr>
      <td>&nbsp;<font color="#0000FF">Sports:</font></td>
      <td height="25">
        <input name="SPORT" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="80" value="<%=WI.getStrValue(vEditInfo[0].elementAt(116))%>" ></td>
    </tr>
    <tr>
      <td colspan="2" valign="bottom"><font color="#0000FF">&nbsp;Honors/Awards/Merits: (ex. &quot;Model
        Student, 1990&quot;)</font> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">
<input name="AWARD" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="80" value="<%=WI.getStrValue(vEditInfo[0].elementAt(117))%>" ></td>
    </tr>

    <tr>
      <td colspan="2" valign="bottom">&nbsp;<font color="#0000FF">Extra-Curricular Activities
        : (Organizations, Clubs, etc)</font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">
<input name="EXT_CURRICULAR_ACT" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="80" value="<%=WI.getStrValue(vEditInfo[0].elementAt(118))%>" ></td>
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
      <td width="41%" height="25">&nbsp;&nbsp;&nbsp;<u>NAME</u></td>
      <td width="59%"><u>ADDRESS/TEL. NOS.</u></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp; <input name="REF_NAME1" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="36" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(119))%>" ></td>
      <td><input name="REF_ADDR1" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="50" maxlength="128" value="<%=WI.getStrValue(vEditInfo[0].elementAt(120))%>" ></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp; <input name="REF_NAME2" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="36" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(121))%>" ></td>
      <td><input name="REF_ADDR2" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="50" maxlength="128" value="<%=WI.getStrValue(vEditInfo[0].elementAt(122))%>" ></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp; <input name="REF_NAME3" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="36" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(123))%>" ></td>
      <td><input name="REF_ADDR3" type ="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'" size="50" maxlength="128" value="<%=WI.getStrValue(vEditInfo[0].elementAt(124))%>" ></td>
    </tr>


  </table>
   <%
  
   vRetResult = pInfo.getRecruitmentInfo(dbOP, request,4);
		if(vRetResult != null && vRetResult.size() > 0)
		{ %>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#BECED3">
      <td height="25" colspan="4"><strong><font color="#FFFFFF" size="2">&nbsp; VIII &#8211; Admission / Registration </font></strong></td>
     </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;How did you know <%=WI.getStrValue(strSchoolName)%>?(Please check the box) </td>
     </tr>    
      
<%		 
		int iCount = 1;
		
	for(int i = 0; i < vRetResult.size(); i += 2, iCount++)
		{	
		
		
		strTemp = WI.fillTextValue("detail_index_"+ iCount); 
            if(strTemp.equals((String)vRetResult.elementAt(i)) || vRecruit.indexOf((String)vRetResult.elementAt(i)) >-1)
	              strErrMsg = "checked";
				  else
				  strErrMsg = "";
				  
 	
  %>
    <tr>
      <td  colspan="2">&nbsp;&nbsp;
        <input type="checkbox" name="detail_index_<%=iCount%>" 
		value="<%=(String)vRetResult.elementAt(i)%>" <%=strErrMsg%>/>
        <%=(String)vRetResult.elementAt(i+1)%> </td>
    </tr>
    <%}%>
	 
 <input type="hidden" name="rec_detail_count" value="<%= iCount%>">
	
    <tr>
	<%
	 if(vRecruit !=null && vRecruit.size()>0)
	 strTemp = WI.getStrValue((String)vRecruit.elementAt(1));
	 
	 else
	 strTemp = WI.fillTextValue("other");
	%>
	
      <td colspan="2">&nbsp;&nbsp; 
        others
        <input type="text" name="other" value="<%= strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" />      </td>
    </tr>
    <tr>
      <td height="25" colspan="3"></td>
     </tr>
    <tr>
	<%
	 if(vRecruit !=null && vRecruit.size()>0)
	 strTemp = WI.getStrValue((String)vRecruit.elementAt(0));
	 
	 else
	 strTemp = WI.fillTextValue("person");
	%>
      <td width="29%" height="25">&nbsp;&nbsp; IF through a person, please specify: </td>
      <td width="71%"><input type="text" name="person" value="<%= strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" /></td>
    </tr>
  </table>
<%}%>  
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="30%">&nbsp;</td>
      <td width="55%">&nbsp;</td>
      <td width="15%">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td align="right"><input type="submit" name="sub" value="Change Information >>" onClick="EditInformation();"></td>
      <td></a></td>
    </tr>
   <tr>
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
<input type="hidden" name="info_index" value="<%=(String)vCourseApplInfo.elementAt(7)%>">
<input type="hidden" name="editInformation" value="0">
<input type="hidden" name="tempId" value="<%=strTempID%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>