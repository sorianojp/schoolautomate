<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Subject Section Scheduling Page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">

function trimString (str) {
  str = this != window? this : str;
  return str.replace(/^\s+/g, '').replace(/\s+$/g, '');
}


function CheckValidHour() {
	var vTime =document.ssection.time_from_hr.value 
	if(eval(vTime) > 12 || eval(vTime) == 0) {
		alert("Time should be >0 and <= 12");
		document.ssection.time_from_hr.value = "";
	}
	vTime =document.ssection.time_to_hr.value 
	if(eval(vTime) > 12 || eval(vTime) == 0) {
		alert("Time should be >0 and <= 12");
		document.ssection.time_to_hr.value = "";
	}
}
function CheckValidMin() {
	if(eval(document.ssection.time_from_min.value) > 59) {
		alert("Time can't be > 59");
		document.ssection.time_from_min.value = "00";
	}
	if(eval(document.ssection.time_to_min.value) > 59) {
		alert("Time can't be > 59");
		document.ssection.time_to_min.value = "00";
	}
}

function AddRecord()
{
	document.ssection.addRecord.value = 1;
	document.ssection.set_focus_status.value ="4";
}

function MixSchedule()
{
	document.ssection.mixSchedule.value ="1";
	document.ssection.addRecord.value = 1;
	document.ssection.submit();
}


function ShowSubject()
{
	document.ssection.showsubject.value = 1;
	document.ssection.set_focus_status.value="1";
	document.ssection.addRecord.value = 0;
}

function ChangeOfferingSem()
{
	document.ssection.offering_sem_name.value = document.ssection.offering_sem[document.ssection.offering_sem.selectedIndex].value;
}
function changeResOfferingType()
{
	document.ssection.showsubject.value = "";
	document.ssection.offer.value="";

	ReloadPage();
}
function ReloadPage()
{
	if(document.ssection.reload_in_progress.value == 1)
		return;
	document.ssection.reload_in_progress.value = "1";
	document.ssection.addRecord.value = 0;
	document.ssection.submit();
}

function SetFocusStatus(strSetFocusValue)
{
	document.ssection.set_focus_status.value =strSetFocusValue;
	if (strSetFocusValue == '3')
		document.ssection.college_index.selectedIndex = 0;
	document.ssection.submit();
}


/*function changeSubject()
{
	document.ssection.addRecord.value = 0;
	document.ssection.changeCourse.value = 0;
	document.ssection.changeSubject.value = 1;

	document.ssection.submit();
}*/

/**
*	Call this function to view sction detail of a course curriculum.
*/
function ViewSection()
{
	location = "./subj_sectioning_view.jsp?degreeType=100&res_offering=1&school_year_fr="+
		document.ssection.school_year_fr.value+
		"&school_year_to="+document.ssection.school_year_to.value + 
		"&offering_sem="+document.ssection.offering_sem[document.ssection.offering_sem.selectedIndex].value;

}

function EditRecord(strInfoIndex){

	var loadPg = "./sched_edit.jsp?stub_code="+strInfoIndex+"&opner_form_name=ssection";
	var win=window.open(loadPg,"newWin",	'dependent=yes,width=700,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}

function AddNewSection(){
	var strCurrentSection = document.ssection.section.value;
	var strCurrentForm = document.ssection;	
	var strCourseCode; // array, [0] code  [1] course name
	var strMajorCode; // array, [0] code  [1] course name
	var strCollegeCode; // array, [0] code  [1] course name
	
	
	if (strCurrentForm.college_index.selectedIndex > 0){	
		if (trimString(strCurrentSection).length> 0) {
			strCurrentSection = trimString(strCurrentSection) + "/"; // add single slash
		}else{
			strCurrentSection ="";
		}
		
		strCollegeCode = strCurrentForm.college_index[strCurrentForm.college_index.selectedIndex].text.split("(");
		strCurrentSection += strCollegeCode[0];   // Ag
		
		strCurrentForm.college_index.selectedIndex = 0;
		document.ssection.section.value = strCurrentSection;

	} else 
		if (strCurrentForm.course_index.selectedIndex > 0){
			if (trimString(strCurrentSection).length> 0) {
				strCurrentSection = trimString(strCurrentSection) + "/"; // add single slash
			}else{
				strCurrentSection ="";
			}
		
			strCourseCode = strCurrentForm.course_index[strCurrentForm.course_index.selectedIndex].text.split(" "); 
			strCurrentSection += strCourseCode[0];   // law 101/law _
		
			if (strCurrentForm.major_index){
				if (strCurrentForm.major_index.selectedIndex > 0){
					strMajorCode = strCurrentForm.major_index[strCurrentForm.major_index.selectedIndex].text.split(" ")
					strCurrentSection +="|"+strMajorCode[0];
				}
			}	
		}
	
	if (strCurrentForm.year_level.value.length > 0){
		if (strCurrentForm.section_number.value.length > 0){
			strCurrentSection += " " + strCurrentForm.year_level.value;
			if (strCurrentForm.section_number.value.length == 1) 
				strCurrentSection += "0" + strCurrentForm.section_number.value;
			else
				strCurrentSection += strCurrentForm.section_number.value;
		}else{
			alert(" Please enter section");
			strCurrentForm.section_number.focus();
			return;
		}
	}
		
	document.ssection.section.value = strCurrentSection;
	
}

function DisableCourseMajor(){
	if (document.ssection.c_index.selectedIndex != 0) {
		document.ssection.course_index.selectedIndex=0;
		if (document.ssection.major_index != null){
			document.ssection.major_index.selectedIndex=0
		}
	}else{
		document.ssection.course_index.disable= false;
		if (document.ssection.major_index != null)
			document.ssection.major_index.disable = true;

	}
}

function checkSubject(){

	if ( document.ssection.subject_offered) { 
		var strDropListText = 
			document.ssection.subject_offered[document.ssection.subject_offered.selectedIndex].text;
		if (document.ssection.scroll_sub) { 
		var strAutoScrollText  = document.ssection.scroll_sub.value;
	
		if(strAutoScrollText.length > 0 && 
				!strAutoScrollText.toUpperCase().equals(strDropListText.toUpperCase())){
			alert("Invalid Subject Code. Please check item in selection.");
			document.ssection.subject_offered.selectedIndex = 0;
			return;
		}
  	  }
	}
}


</script>


<%@ page language="java" import="utility.*,enrollment.SubjectSection, enrollment.SubjectSectionCPU, java.util.Vector, java.util.Date" buffer="16kb"%>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;	
	WebInterface WI = new WebInterface(request);
	Vector vTemp = null;
	int i = -1;
	int j=0;
	String strSYTo = null; // this is used in
	String strCurIndex = null;
	String strCurIndex0 = null;
	Vector vIsCommonSection = null;
	Vector vIsSubOffered  = null;
	Vector vIsSubOfferedInOthCur = null;
	Vector vAuthorizedColInfo = null;
	boolean bolFatalErr = false;
	boolean	bolSelectedCollDept = false;
	String strPrepareToEdit ="";
	boolean bolIsLecLab = false;

	//////////////////////// vector added to show all possible schedule of subject

	

	//this is necessary for different types of subject offering.
	//degree_type=0->UG,1->Doctoral,2->medicine,3->with prep proper, 4-> care giver.
	//for care giver,doctoral, do not show year level, for prep_prop, show prep/prop status.
	String strDegreeType = null;

	String[] astrSchYrInfo = null;
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester",""};


	String strCollegeIndex = null;
	String strCollegeName  = null;
	String strDeptIndex    = null;
	String strDeptName     = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-subject sectioning","subj_sectioning.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		strTemp = "<form name=ssection><input type=hidden name=showsubject></form>";
		%><%=strTemp%><%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														"subj_sectioning.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	if(!response.isCommitted())
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
	else
	%>
		<script language="JavaScript">
		location = "../../../../commfile/fatal_error.jsp";
		</script>
	<%
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	if(!response.isCommitted())
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	else
	%>
		<script language="JavaScript">
		location = "../../../../commfile/unauthorized_page.jsp";
		</script>
	<%
	return;
}

//end of authenticaion code.


//force strDegreeType for CPU.. curriculum not required..  as requested

strDegreeType = "100";

strErrMsg = null; //if there is any message set -- show at the bottom of the page.
SubjectSection SS = new SubjectSection();
SubjectSectionCPU SSCPU= new SubjectSectionCPU();

if (WI.fillTextValue("subject_offered").length() > 0) 
	bolIsLecLab = SSCPU.isSubLecLab(dbOP, WI.fillTextValue("subject_offered"));

strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.equals("1"))
{
	//add it here and give a message.
	if(SSCPU.addSectionCPU(dbOP,request))
	{
		strErrMsg = SSCPU.getErrMsg();
	}
	else
	{
		dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=SSCPU.getErrMsg()%></font></p>
		<%
		strTemp = "<form name=ssection><input type=hidden name=showsubject></form>";
		%><%=strTemp%><%
		return;
	}
}

else
	vIsCommonSection = SS.checkIfCommonSection(dbOP,request.getParameter("subject_offered"),
											request.getParameter("section"),
											request.getParameter("school_year_fr"),
											request.getParameter("school_year_to"),
											request.getParameter("offering_sem"),
											request.getParameter("is_lec"));
//System.out.println(vIsCommonSection);

vAuthorizedColInfo = comUtil.getAuthorizedCollegeInfo(dbOP,(String)request.getSession(false).getAttribute("userId"));
if(vAuthorizedColInfo == null)
{
	strErrMsg = comUtil.getErrMsg();
	bolFatalErr = true;
}

if(!bolFatalErr && WI.fillTextValue("showsubject").equals("1"))
{
	//check if subject is already offered.
	vIsSubOffered = SS.checkIfSectionOffered(dbOP,request.getParameter("cur_index"),
						request.getParameter("section"),request.getParameter("is_lec"),
						request.getParameter("school_year_fr"),
						request.getParameter("school_year_to"),
						request.getParameter("offering_sem"),
						request.getParameter("subject_offered"));

	//get the college/dept offering the course if it is already offered, else = get from vAuthorizedColInfo
	if(vIsSubOffered != null && vIsSubOffered.size() > 0)
	{
		strCollegeIndex = (String)vIsSubOffered.elementAt(2);
		strCollegeName  = (String)vIsSubOffered.elementAt(3);
		strDeptIndex    = (String)vIsSubOffered.elementAt(4);
		strDeptName     = (String)vIsSubOffered.elementAt(5);
	}
	else if(vIsCommonSection != null && vIsCommonSection.size() > 0)
	{//System.out.println(vIsCommonSection);
		//strCollegeIndex = (String)vIsCommonSection.elementAt(3); - i HAVE TO ALLOW THE OFFERING TO BE DELETED BY THE CHILD OFFERING
		strCollegeIndex = (String)vAuthorizedColInfo.elementAt(1);
		strCollegeName  = (String)vIsCommonSection.elementAt(4);
		strDeptIndex    = (String)vIsCommonSection.elementAt(5);
		strDeptName     = (String)vIsCommonSection.elementAt(6);
	}
	else if(vAuthorizedColInfo != null && vAuthorizedColInfo.size() > 0)
	{
		strCollegeIndex = (String)vAuthorizedColInfo.elementAt(1);
		strCollegeName  = (String)vAuthorizedColInfo.elementAt(0);
		strDeptIndex    = (String)vAuthorizedColInfo.elementAt(3);
		strDeptName     = (String)vAuthorizedColInfo.elementAt(2);
	}
}
if(!bolFatalErr)
{
	astrSchYrInfo = dbOP.getCurSchYr();
	if(astrSchYrInfo == null)//db error
	{
		strErrMsg = dbOP.getErrMsg();
		bolFatalErr = true;
	}
}//if !bolFatalErr
if (WI.fillTextValue("showsubject").equals("1")) {

	if (WI.fillTextValue("c_index").length() > 0  ||
		WI.fillTextValue("d_index").length()> 0) {
		bolSelectedCollDept = true;
	}else{
		strErrMsg  = " Please select college or department that will offer subject";
	}
	
	if (bolSelectedCollDept){

		if(WI.fillTextValue("school_year_fr").length() != 4 
			|| WI.fillTextValue("school_year_to").length() != 4){
			bolSelectedCollDept = false;
			strErrMsg  = " Please set school year";
		}		
	}
}

if(strErrMsg == null) strErrMsg = "";
%>
<body bgcolor="#D2AE72"> 
<form name="ssection" action="./subj_sectioning_CPU.jsp" method="post" onSubmit="checkSubject();">

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          CLASS PROGRAMS - NEW CLASS PROGRAMS/SECTIONS PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%" height="25" colspan="3"> <font size="3"><b><%=strErrMsg%></b></font>
      </td>
    </tr>
<% 
	if(bolFatalErr){
		dbOP.cleanUP();//System.out.println(" I am here");
		strTemp = "<input type=hidden name=showsubject></form>";%> 
		
    <%=strTemp%>
    
<%  return; }%>
    
        <input type="hidden" name="res_offering" value="1">
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="2"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td>Offering College: &nbsp; 
	  	<select name="c_index" onChange="ReloadPage();">
		<option value="">Select College</option>
          <%=dbOP.loadCombo("c_index","c_name",
		  " from college where IS_DEL=0 order by c_name asc",WI.fillTextValue("c_index"), false)%> 
	    </select></td>
    </tr>
<% strTemp = WI.fillTextValue("c_index");

	if (strTemp.length() > 0) 
		strTemp = " c_index = " + strTemp;
	else
		strTemp = "((c_index is not null and c_index <> 0)  or d_code ='NSTP')";
		
	strTemp = dbOP.loadCombo("d_index","d_name"," from department where IS_DEL=0 " +
		  			" and " + strTemp + 
					" order by d_name asc", WI.fillTextValue("d_index"), false);
	if (strTemp.length() > 0) {
%>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td>Offering Department: 
		<select name="d_index">
        <option value="">--</option>
          <%=strTemp%> 
	    </select>	  </td>
    </tr>
<%} // end if department should be shown %>
    <tr> 
      <td>&nbsp;</td>
      <td height="25">Class Program for Term / Academic Year : 

	<%
        strTemp = WI.fillTextValue("offering_sem");
		if(strTemp.length() ==0)
			strTemp = astrSchYrInfo[2];
//		if(strTemp.length() ==0 )
//			strTemp = (String)request.getSession(false).getAttribute("cur_sem");%>
        <select name="offering_sem">
          <option value="0">Summer</option>
          <%
		if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}%>
        </select>
      <input type="hidden" name="offering_sem_name" value="<%=astrConvertSem[Integer.parseInt(strTemp)]%>">
	 &nbsp;&nbsp;
    <%
	  strTemp = WI.fillTextValue("school_year_fr");
	  if(strTemp.length() ==0) strTemp = astrSchYrInfo[0];
	%> <input name="school_year_fr" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("ssection","school_year_fr","school_year_to")'> <%
	  strTemp = WI.fillTextValue("school_year_to");
	  if(strTemp.length() ==0) strTemp = astrSchYrInfo[1];
	  %>
        - 
        <input name="school_year_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        &nbsp;&nbsp;&nbsp;&nbsp;
      </td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="97%"><input type="submit" name="showsub" value="Show Subjects" onClick="ShowSubject();"> 
	</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="2"><hr size="1"></td>
    </tr>
  </table>

<%
//System.out.println(request.getParameter("showsubject"));
if(WI.fillTextValue("showsubject").equals("1") && bolSelectedCollDept)
{

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="4" valign="bottom"> 
<%
strTemp = WI.fillTextValue("donot_check_conflict");
if(strTemp.compareTo("1") ==0)
	strTemp = " checked";
else
	strTemp = "";
%> <input type="checkbox" name="donot_check_conflict" value="1"<%=strTemp%>> 
        <font color="#0000FF"><strong>DO NOT CHECK CONFLICT (ex. Off campus subjects.)</strong></font></td>
    </tr>
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="2" valign="bottom">Subject: </td>
      <td width="54%" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td width="1%">&nbsp;</td>
      <td colspan="2"> <input type="text" name="scroll_sub" class="textbox"
	     onKeyUp="AutoScrollListSubject('scroll_sub','subject_offered',true,'ssection');"> 
        <font size="1">(enter subject code to scroll)</font> </td>
      <td colspan="2">&nbsp; 
	  <select name="subject_offered" onChange='SetFocusStatus("2");'>
      <option value="selany">Select Subject code</option>
          <%=dbOP.loadCombo("sub_index","sub_code", " from subject where is_del=0 order by sub_code",
		  	WI.fillTextValue("subject_offered"), false)%> </select></td>
    </tr>
<%
 if(!WI.fillTextValue("subject_offered").equals("selany")
 		&& WI.fillTextValue("subject_offered").length() > 0){%>	
    <tr>
      <td>&nbsp;</td>
      <td colspan="4">&nbsp;Subject Title: <b> <%=dbOP.mapOneToOther("SUBJECT","sub_index",WI.fillTextValue("subject_offered"),"sub_name",null)%></b></td>
    </tr>

    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="5">&nbsp;</td>
    </tr>
<% if (bolIsLecLab) {%>
    <tr> 
      <td height="25" colspan="5" bgcolor="#C2DAFC"><div align="center"><strong>LECTURE  SCHEDULE</strong></div></td>
    </tr>
    <tr> 
      <td height="18" colspan="5" ><font size="1">&nbsp;</font></td>
    </tr>	
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="13%">Capacity:</td>
      <td width="32%" valign="bottom"> 
	  <%
	  	strTemp = WI.fillTextValue("off_cap");
	  	if (strTemp.length() == 0) 
			strTemp = "45"; // hard coded  to 45 
	  %>
	  <input name="off_cap" type="text" class="textbox" value="<%=strTemp%>" size="5" maxlength="5"
	   onKeyUp= 'AllowOnlyInteger("ssection","off_cap")' 
	   onFocus="style.backgroundColor='#D3EBFF';this.select();"
	   onBlur='AllowOnlyInteger("ssection","off_cap");style.backgroundColor="white"'>      </td>
      <td width="14%">&nbsp;</td>
      <td width="38%">&nbsp; </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Status: </td>
      <td> <%
      vTemp = null;
      strTemp = WI.fillTextValue("sub_stat");%> 
	  <select name="sub_stat" >
          <%=dbOP.loadCombo("status_index","status"," from e_sub_status order by status_index asc",strTemp, false)%> </select></td>
      <td> &nbsp;
         Lecture Index:
		</td>
      <td> 
	   <input name="lec_index" type="text" class="textbox" 
	  	value="<%=WI.fillTextValue("lec_index")%>" size="8" maxlength="8"
	    onKeyUp= 'AllowOnlyInteger("ssection","lec_index")' onFocus="style.backgroundColor='#D3EBFF';"
		onBlur='AllowOnlyInteger("ssection","lec_index");style.backgroundColor="white"'> 
	   <font size="1">(stub code only)</font>        </td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp; </td>
      <td>&nbsp;</td>
      <td>&nbsp; </td>
    </tr>
  </table>
    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26" colspan="3" valign="middle">&nbsp;<strong><u>Ownership Details / Section :</u></strong></td>
    </tr>
		
	<tr>
      <td width="3%">&nbsp;</td>
      <td width="11%">&nbsp;College:</td> 
	  <%
	 	strTemp = " from e_college_code join college  " + 
				  " on (e_college_code.c_index = college.c_index) " +
				  " order by e_college_code.c_code ";
	 %>
      <td width="86%">
		<select name="college_index" onChange="DisableCourseMajor()">
          <option value="">Specify College</option>
		 <%=dbOP.loadCombo("e_college_code.c_index",
  					"e_college_code.c_code,college.c_name",
				 	strTemp,WI.fillTextValue("college_index"), false)%>
		</select>
	  </td>
	</tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="11%">&nbsp;Course:</td>
      <td width="86%"> 
        <select name="course_index" onChange="SetFocusStatus('3')">
          <option value="">OPEN TO ALL</option>
<%
  	strTemp = " from e_course_code join course_offered  on ( e_course_code.course_index = course_offered.course_index) " +
		 " order by e_code ";
%>
		  
  <%=dbOP.loadCombo("e_course_code.course_index",
  					" e_course_code.course_code  + ' :: '+ course_offered.course_name as e_code ",
							strTemp,WI.fillTextValue("course_index"), false)%>
		</select>
      </td>
    </tr>
<% if (WI.fillTextValue("course_index").length() > 0) {

  	strTemp = " from e_major_code join major  on (e_major_code.major_index = major.major_index) " +
		" where major.course_index =  " + WI.fillTextValue("course_index") +
	    " order by e_code";
	
	strTemp = dbOP.loadCombo("e_major_code.major_code",
		  					" e_major_code.major_code  + ' :: '+ major.major_name as e_code ",
							strTemp,WI.fillTextValue("major_index"), false);
							
	if (strTemp.length() > 0) {
%>
	
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;Major:</td>
      <td> 
        <select name="major_index">
          <option value="">Any Major</option>
		  <%=strTemp%>
        </select> 
      </td>
    </tr>
<%} // if strTemp.lenght > 0
} // if course is selected
%>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;Year Level</td>
      <td> 
      <input name="year_level" type="text" size="2" maxlength="1" 
	   value="<%=WI.fillTextValue("year_level")%>" class="textbox"
	   onKeyUp="AllowOnlyInteger('ssection','year_level');"
	   onFocus="style.backgroundColor='#D3EBFF';" 
	   onBlur="style.backgroundColor='white'; AllowOnlyInteger('ssection','year_level')"> 
	  </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;Section </td>
      <td>
        <input name="section_number" type="text" size="2" maxlength="2" 
		value="<%=WI.fillTextValue("section_number")%>" class="textbox"
		onKeyUp="AllowOnlyInteger('ssection','section_number');"
	  	onFocus="style.backgroundColor='#D3EBFF';" 
		onBlur="style.backgroundColor='white'; AllowOnlyInteger('ssection','section_number')"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2"><a href="javascript:AddNewSection()"><img border=0 src="../../../../images/add.gif" width="42" height="32"></a> 
        <font size="1">click to add to list of owners</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom"> <strong><font color="#0000FF" size="1">Section Owners:: (Please note that if a college a selected, it will disregard selected course/major) </font></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2"><textarea name="section" cols="80" rows="4" class="textbox"
	     onFocus="style.backgroundColor='#D3EBFF';" 
		 onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("section")%></textarea></td>
    </tr>
  </table>
<%  if(WI.fillTextValue("force_another_time").equals("1") 
		|| vIsSubOffered == null || vIsSubOffered.size() ==0){

	if(vTemp == null && !WI.fillTextValue("subject_offered").equals("selany") && 
			WI.fillTextValue("subject_offered").length() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td width="22%">&nbsp;</td>
      <td width="42%">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td colspan="4" height="25" valign="middle">&nbsp;<strong><u>Schedule Details</u></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="18" valign="bottom">Schedule (M-T-W-TH-F-SAT-S)</td>
      <td valign="bottom">Time From</td>
      <td valign="bottom">Time To </td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td><input type="text" name="week_day" size="20" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF';document.ssection.week_day.select();" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("week_day")%>"
	  onKeypress=" if(event.keyCode>47 && event.keyCode < 58) event.returnValue=false;" OnKeyUP="javascript:this.value=this.value.toUpperCase()"></td>
      <td><input type="text" name="time_from_hr" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('ssection','time_from_hr');CheckValidHour();" value="<%=WI.fillTextValue("time_from_hr")%>"
	  onKeyUp="AllowOnlyInteger('ssection','time_from_hr');CheckValidHour();">
        : 
        <input type="text" name="time_from_min" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('ssection','time_from_min');CheckValidMin();" value="<%=WI.fillTextValue("time_from_min")%>"
	  onKeyUp="AllowOnlyInteger('ssection','time_from_min');CheckValidMin();">
        : 
        <select name="time_from_AMPM">
          <option selected value="0">AM</option>
          <%
strTemp = WI.fillTextValue("time_from_AMPM");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
      <td><input type="text" name="time_to_hr" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('ssection','time_to_hr')" value="<%=WI.fillTextValue("time_to_hr")%>"
	  onKeyUp="AllowOnlyInteger('ssection','time_to_hr');CheckValidHour();">
        : 
        <input type="text" name="time_to_min"  size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('ssection','time_to_min')" value="<%=WI.fillTextValue("time_to_min")%>"
	  onKeyUp="AllowOnlyInteger('ssection','time_to_min');CheckValidMin();">
        : 
        <select name="time_to_AMPM">
          <option selected value="0">AM</option>
          <%
	strTemp = WI.fillTextValue("time_to_AMPM");
	if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td colspan="4" height="25">&nbsp;<u><strong>Room Assignment</strong></u></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3" height="25"><input type="text" name="room_list" size="40" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("room_list")%>">	
      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3" height="50"><font size="1" color="red">For multiple room 
        assignment please enter in this format: <br>
        ROOM1/ROOM2/ROOM3 for a corresponding schedule of M-W-F<br>
      Enter a single room if only one room is used</font></td>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="3" height="25" valign="middle">&nbsp;<strong><u>Load Details</u></strong></td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="13%" height="25">Instructor : </td>
      <td width="85%" height="25"><input type="text" name="scroll_faculty" class="textbox"
	     onKeyUp = "AutoScrollList('ssection.scroll_faculty','ssection.fac_index',true);"> 
        <select name="fac_index" >
          <option value="">Select a teacher</option>
  <%=dbOP.loadCombo("user_table.user_index","lname +' '+fname as fac_name",
	" from user_table where exists (select * from faculty_sub_can_teach where "+
	" faculty_sub_can_teach.user_index = user_table.user_index and sub_index = " + 
	WI.fillTextValue("subject_offered") + 
	" and is_del = 0) order by fac_name",WI.fillTextValue("fac_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2">Load:&nbsp;&nbsp; &nbsp; <input name="credit_load" type="text" class="textbox" value="<%=WI.fillTextValue("credit_load")%>" size="5" maxlength="10"
	   onKeyUp= 'AllowOnlyFloat("ssection","credit_load")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyFloat("ssection","credit_load");style.backgroundColor="white"'> 
        <font size="1">(units)</font> &nbsp;&nbsp;&nbsp;&nbsp; &nbsp; <input name="hour_load" type="text" class="textbox" value="<%=WI.fillTextValue("hour_load")%>" size="5" maxlength="10"
	   onKeyUp= 'AllowOnlyFloat("ssection","hour_load")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyFloat("ssection","hour_load");style.backgroundColor="white"'> 
        <font size="1">(hours)</font></td>
    </tr>
  </table>
  
<% if (bolIsLecLab) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="18" colspan="3"><font size="1">&nbsp;</font></td>
    </tr>  
    <tr>
      <td height="25" colspan="3" bgcolor="#F9C6D5"><div align="center"><strong>LABORATORY SCHEDULE</strong> </div></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="10%">Capacity:</td>	 
	  <%
	   strTemp = WI.fillTextValue("off_cap2");
	  	if (strTemp.length() == 0) 
			strTemp = "45"; // hard coded  to 45 
	  %>
      <td width="88%" valign="bottom">
       <input name="off_cap2" type="text" class="textbox" value="<%=strTemp%>" size="3" maxlength="3"
	   onKeyUp= 'AllowOnlyInteger("ssection","off_cap2")' onFocus="style.backgroundColor='#D3EBFF'"
		onBlur='AllowOnlyInteger("ssection","off_cap2");style.backgroundColor="white"'>      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Status: </td>
      <td valign="bottom">
        <select name="sub_stat2">
          <%=dbOP.loadCombo("status_index","status"," from e_sub_status order by status_index asc",WI.fillTextValue("sub_stat2"), false)%>
        </select></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4" height="25" valign="middle">&nbsp;<strong><u>Schedule Details</u></strong></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="18" valign="bottom">Schedule (M-T-W-TH-F-SAT-S)</td>
      <td valign="bottom">Time From</td>
      <td valign="bottom">Time To </td>
    </tr>
    <tr>
      <td width="2%">&nbsp;</td>
      <td><input type="text" name="week_day2" size="20" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF';document.ssection.week_day2.select();" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("week_day2")%>"
	  onKeypress=" if(event.keyCode>47 && event.keyCode < 58) event.returnValue=false;" OnKeyUP="javascript:this.value=this.value.toUpperCase();"></td>
      <td><input type="text" name="time_from_hr2" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF';" onBlur="style.backgroundColor='white';AllowOnlyInteger('ssection','time_from_hr2');CheckValidHour();" value="<%=WI.fillTextValue("time_from_hr2")%>"
	  onKeyUp="AllowOnlyInteger('ssection','time_from_hr2');CheckValidHour();">
        :
        <input type="text" name="time_from_min2" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('ssection','time_from_min');CheckValidMin();" value="<%=WI.fillTextValue("time_from_min2")%>"
	  onKeyUp="AllowOnlyInteger('ssection','time_from_min');CheckValidMin();">
        :
        <select name="time_from_AMPM2" >
          <option selected value="0">AM</option>
          <%
strTemp = WI.fillTextValue("time_from_AMPM2");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
      <td><input type="text" name="time_to_hr2" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('ssection','time_to_hr2')" value="<%=WI.fillTextValue("time_to_hr2")%>"
	  onKeyUp="AllowOnlyInteger('ssection','time_to_hr2');CheckValidHour();">
        :
          <input type="text" name="time_to_min2"  size="2" maxlength="2" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('ssection','time_to_min2')" value="<%=WI.fillTextValue("time_to_min2")%>"
	  onKeyUp="AllowOnlyInteger('ssection','time_to_min2');CheckValidMin();">
        :
        <select name="time_to_AMPM2">
          <option selected value="0">AM</option>
          <%
	strTemp = WI.fillTextValue("time_to_AMPM2");
	if(strTemp.equals("1")){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td colspan="4" height="25">&nbsp;<u><strong>Room Assignment</strong></u></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="3" height="25"><input type="text" name="room_list2" size="40" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("room_list2")%>">      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="3" height="25"><font size="1" color="red">For multiple room 
        assignment please enter in this format: <br>
        ROOM1/ROOM2/ROOM3 for a corresponding schedule of M-W-F<br>
        Enter a single room if only one room is used</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="3" height="25" valign="middle">&nbsp;<strong><u>Load Details</u></strong></td>
    </tr>
    <tr>
      <td width="2%">&nbsp;</td>
      <td width="13%" height="25">Instructor : </td>
      <td width="85%" height="25"><input type="text" name="scroll_faculty2" class="textbox"
	     onKeyUp = "AutoScrollList('ssection.scroll_faculty2','ssection.fac_index2',true);">
          <select name="fac_index2" >
            <option value="">Select a teacher</option>
            <%=dbOP.loadCombo("user_table.user_index","lname +' '+fname as fac_name",
	" from user_table where exists (select * from faculty_sub_can_teach where "+
	" faculty_sub_can_teach.user_index = user_table.user_index and sub_index = " + 
	WI.fillTextValue("subject_offered") + 
	" and is_del = 0) order by fac_name",WI.fillTextValue("fac_index2"), false)%>
        </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="2">Load:&nbsp;&nbsp; &nbsp;
          <input name="credit_load2" type="text" class="textbox" value="<%=WI.fillTextValue("credit_load2")%>" size="5" maxlength="10"
	   onKeyUp= 'AllowOnlyFloat("ssection","credit_load2")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyFloat("ssection","credit_load2");style.backgroundColor="white"'>
          <font size="1">(units)</font> &nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
          <input name="hour_load2" type="text" class="textbox" value="<%=WI.fillTextValue("hour_load2")%>" size="5" maxlength="10"
	   onKeyUp= 'AllowOnlyFloat("ssection","hour_load2")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyFloat("ssection","hour_load2");style.backgroundColor="white"'>
          <font size="1">(hours)</font></td>
    </tr>
  </table>
<%} // end show block if lec/lab subject %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td width="2%">&nbsp;</td>
      <td colspan="2"><div align="center">
          <%if(iAccessLevel > 1){%>
          <input name="image" type="image" onClick="AddRecord();" src="../../../../images/save.gif" width="48" height="28">
          <font size="1">click to save entries</font>
          <%}%>
      </div></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
  <%
if (WI.fillTextValue("subject_offered").length() > 0) { 

	Vector vAllSubjectSchedule = SSCPU.getOfferingPerCollege(dbOP,request,null, 
															WI.fillTextValue("subject_offered")); 
	
//	System.out.println(vAllSubjectSchedule);
	
if(vAllSubjectSchedule != null && vAllSubjectSchedule.size() > 0)
{

	String[] astrDay = {"S","M","T","W","TH","F","SAT"};
	String[] astrAMPM = {"AM", "PM"};
	String strTempIndex = "";
	float fTemp24HF = 0f;
	float fTemp24HT = 0f;
	int[] iTimeDataFr = null;
	int[] iTimeDataTo = null;
	String strTempDay = "";
	String strTempRoom = "";
	String strTempCol = null;
	String strTempDept = null;
	String strTempSub = null;
	boolean bIsDupe = false;
	boolean bResetSub = true;
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <%
    
    strTempCol = (String)vAllSubjectSchedule.elementAt(0);
	strTempDept = (String)vAllSubjectSchedule.elementAt(2);
	strTempSub = (String)vAllSubjectSchedule.elementAt(4);
	
for(i = 0 ; i< vAllSubjectSchedule.size() ; i+=22) {


	strTempIndex = (String)vAllSubjectSchedule.elementAt(i+6);
	if (i>0 && strTempIndex.equals((String)vAllSubjectSchedule.elementAt(i-15)))
		bIsDupe = true;
	else
		bIsDupe = false;
	
	
	if (i==0 || 
	!(
	((strTempCol == null && vAllSubjectSchedule.elementAt(i)==null) ||
	(strTempCol != null && vAllSubjectSchedule.elementAt(i)!=null && strTempCol.equals((String)vAllSubjectSchedule.elementAt(i)))) &&
	((strTempDept == null && vAllSubjectSchedule.elementAt(i+2)==null) ||
	(strTempDept != null && vAllSubjectSchedule.elementAt(i+2)!=null && strTempDept.equals((String)vAllSubjectSchedule.elementAt(i+2))))
	))
	{%>

	<tr>
		
      <td height="25" colspan="9" class="thinborderLEFT">Offered by : <strong><%=WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+1),"",
		WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+3)," - ","",""),WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+3),"","","&nbsp;"))%></strong></td>
	</tr>
	<%
	    strTempCol = (String)vAllSubjectSchedule.elementAt(i);
		strTempDept = (String)vAllSubjectSchedule.elementAt(i+2);
		bResetSub = true;
 	} // end if i==0 ...
	
	if ( i== 0 || 
		!(strTempSub.equals((String)vAllSubjectSchedule.elementAt(i+4))) || 
		bResetSub){%>
	<tr>
		<td height="25" colspan="9" class="thinborder"><strong><%=(String)vAllSubjectSchedule.elementAt(i+4)%> - <%=(String)vAllSubjectSchedule.elementAt(i+5)%></strong></td>
	</tr>
	<%
		strTempSub = (String)vAllSubjectSchedule.elementAt(i+4);
		bResetSub = false;
	}%>
    <tr>


      <td width="14%" height="20" class="thinborder"><font size="1">
	  	<%	 
			if (((String)vAllSubjectSchedule.elementAt(i+16)).equals("1"))
				strTemp = "(Lab)";
			else
				strTemp ="";
		
			if (!bIsDupe){%>
			<%=(String)vAllSubjectSchedule.elementAt(i+4) + strTemp%>
		<%}else{%>&nbsp;<%}%>
	
		</font>	   </td>
      <td width="22%" class="thinborder">
	  <%if (bIsDupe){%>&nbsp;<%} else {%>
	  <%}%>	  <font size="1"><%=WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+7),"&nbsp;")%></font></td>
	  
      <%
		strTempDay = "";
		strTempRoom = WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+15),"TBA");

	if (vAllSubjectSchedule.elementAt(i+8)!=null && vAllSubjectSchedule.elementAt(i+9) != null)
    {  	

    	strTempDay = astrDay[Integer.parseInt((String)vAllSubjectSchedule.elementAt(i+10))];
    	fTemp24HF = Float.parseFloat((String)vAllSubjectSchedule.elementAt(i+8));
	    fTemp24HT = Float.parseFloat((String)vAllSubjectSchedule.elementAt(i+9));
	    
	    iTimeDataFr = comUtil.convert24HRTo12Hr(fTemp24HF);
	    iTimeDataTo = comUtil.convert24HRTo12Hr(fTemp24HT);
	   
      while (
      (i+22)< vAllSubjectSchedule.size() && 
      strTempIndex.equals((String)vAllSubjectSchedule.elementAt(i+28)) &&
      vAllSubjectSchedule.elementAt(i+8).equals(vAllSubjectSchedule.elementAt(i+30)) &&
      vAllSubjectSchedule.elementAt(i+9).equals(vAllSubjectSchedule.elementAt(i+31)) &&
      ((vAllSubjectSchedule.elementAt(i+14) == null && vAllSubjectSchedule.elementAt(i+36)==null)  
      || (vAllSubjectSchedule.elementAt(i+14) != null && vAllSubjectSchedule.elementAt(i+36)!=null 
      && vAllSubjectSchedule.elementAt(i+14).equals(vAllSubjectSchedule.elementAt(i+36))) ))
      {
      	  strTempDay += astrDay[Integer.parseInt((String)vAllSubjectSchedule.elementAt(i+32))];
      	  i+=22;
      }}%>
      <td width="13%" class="thinborder"><font size="1">
	<%	if (vAllSubjectSchedule.elementAt(i+8)!=null && vAllSubjectSchedule.elementAt(i+9) != null){%>
      <%=iTimeDataFr[0]%>:<%=comUtil.formatMinute(Integer.toString(iTimeDataFr[1])) %><%=astrAMPM[iTimeDataFr[2]]%>-<%=iTimeDataTo[0]%>:<%=comUtil.formatMinute(Integer.toString(iTimeDataTo[1])) %><%=astrAMPM[iTimeDataTo[2]]%><%} else {%>TBA<%}%></font></td>
      <td width="7%" class="thinborder"><font size="1"><%=WI.getStrValue(strTempDay,"TBA")%></font></td>
	  <td width="11%" class="thinborder"><font size="1"><%=strTempRoom%></font></td>
      <td width="18%" class="thinborder"><font size="1">
	  <%if (bIsDupe){%>&nbsp;<%} else {%>
	      <%if (vAllSubjectSchedule.elementAt(i+17)!=null){ %>
	      <%=WI.formatName((String)vAllSubjectSchedule.elementAt(i+18),(String)vAllSubjectSchedule.elementAt(i+19),(String)vAllSubjectSchedule.elementAt(i+20),7)%>
      <%} else {%>c/o<%}%><%}%></font></td>
      <td width="4%" class="thinborder">
<%
	if (!bIsDupe && !((String)vAllSubjectSchedule.elementAt(i+16)).equals("1")) {
		if(((String)vAllSubjectSchedule.elementAt(i+16)).equals("0")){
			strTemp = 	WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+12),"--");
		} else {
			strTemp = WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+13),"--");
		}
	} else strTemp ="";%>

		<font size="1">&nbsp; <%=strTemp%>  </font>	  </td>
      <td width="6%" class="thinborder"><font size="1">&nbsp;
	  <%if (!bIsDupe){%>
		  <a href="javascript:EditRecord(<%=(String)vAllSubjectSchedule.elementAt(i+6)%>)">
		  <%=(String)vAllSubjectSchedule.elementAt(i+6)%>		  </a>
	  <%}%>
	  </font>	 </td>
      <td width="5%" class="thinborder">&nbsp;<font size="1">
        <%if (!bIsDupe){%>
          <font size="1"><%=WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+11),"--")%></font>
      <%}%></font></td>
    </tr>
    <%
}//end of view all loops %>
  </table>

		<%}//end of view subject schedules
     	} //end if (WI.fillTextValue("subject_offered");
	 } 
  }//show the weekly schedule only of Shedule Imange icon is clicked.
} // if request.getParameter("showsubject").equals("1")

%>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>


<!--  where to set the focus  --------->
<input type="hidden" name="set_focus_status" value="<%=WI.fillTextValue("set_focus_status")%>">
<!-------------->

<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="showsubject" value="<%=WI.fillTextValue("showsubject")%>">
<input type="hidden" name="offer">
<input type="hidden" name="degreeType" value="100">
<input type="hidden" name="mixSchedule">
<input type="hidden" name="reload_in_progress">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>"> 
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<%if (bolIsLecLab) strTemp = "1"; else strTemp = "0";%>
<input type="hidden" name="lec_lab_subject" value="<%=strTemp%>">
<script language="JavaScript">
<!--

	if ( document.ssection.set_focus_status.value.length > 0) {
		switch(parseInt(document.ssection.set_focus_status.value)){
			case 1: 
					if (document.ssection.scroll_sub) 
						document.ssection.scroll_sub.focus();
					if (document.ssection.subject_offered && 
							document.ssection.subject_offered.selectedIndex != 0) 
						document.ssection.off_cap.focus();
			break;
			case 2: document.ssection.off_cap.focus(); break;
			case 3: document.ssection.year_level.focus(); break;
			case 4: document.ssection.scroll_sub.focus(); 
		}
	}
	
-->
</script>

<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
