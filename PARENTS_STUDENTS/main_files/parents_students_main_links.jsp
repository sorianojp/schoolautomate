<%@ page language="java" import="utility.*" %>
<%
//show the links only if the student is logged in.";
String strTempStudIndex = (String)request.getSession(false).getAttribute("tempIndex");
String strTempStudId = (String)request.getSession(false).getAttribute("tempId");
//if(strTempStudIndex != null) {
//	response.sendRedirect("../ADMISSION MODULE PAGES/single file items/ADMISSION FOR NEW_TRANSFERRE STUDENTS/adm_new_transferee_links.jsp");
//	return;
//}
String strTemp = null;
WebInterface WI = new WebInterface(request);

String strAuthIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
String strStudIndex = (String)request.getSession(false).getAttribute("userIndex");
String strUserId    = (String)request.getSession(false).getAttribute("userId");


boolean bolIsStudent = false;
if(strUserId != null && strUserId.trim().length() > 0) {
	if(strAuthIndex.compareTo("4") ==0 || strAuthIndex.compareTo("6") ==0)
		bolIsStudent = true;
}
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "" ;

boolean bolIsParent = false;
if(request.getSession(false).getAttribute("parent_i") != null)
	bolIsParent = true;

boolean bolIsOnlinePmt = false;
utility.DBOperation dbOP = new utility.DBOperation();
if(bolIsStudent) {
	String strSQLQuery = "select prop_val from read_property_file where prop_name = 'ONLINE_GS_PMT'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery != null && strSQLQuery.equals("1"))
		bolIsOnlinePmt = true;
}

String strShowClassProgView = new utility.ReadPropertyFile().getImageFileExtn("STUDENT_VIEW_CLASSPROG","0");

/**** set up enrollment information ***/
boolean bolShouldEnroll = false;
boolean bolIsStudAdvised = false;//only if student is already advised. if stud is advised, i have to give another link to re-advise.
boolean bolAdvisingInProgress = false;//true only if advised by faculty. 

String strSYFromAdvise = new utility.ReadPropertyFile().getImageFileExtn("ONLINE_ADVISE_SYTERM","0");
String strSYToAdvise   = null;
String strTermAdvise   = null;//get from read property file :: ONLINE_ADVISE_SYTERM
String strSYTermAdvise = null;


boolean bolAllowAddDrop = false;
//////////////////// if parent logged in, invalidate enrollment.///////////
if(bolIsParent)
	strSYFromAdvise = null;
//////////////////////////////////////////////////////////////////////////
//Step 1. Check if sy/term (ONLINE_ADVISE_SYTERM) and (ONLINE_ADVISE_PARAM, 0 - do not proceed to online advising.) is set in read_property_file.
//Step 2. Check if Student is enrolled and confirmed for that SY/Term or enrolled ahead of the Sy/Term (if so, do not activate online advise)
//Step 3. Check if Student is advised but not confirmed for that Sy/Term. If advised, check who advised. Activate re-advise only if student self advised.
request.getSession(false).setAttribute("online_advise", "0");//0 = none, 1 = yes.
if(strSYFromAdvise == null || strSYFromAdvise.length() !=6)
	strSYFromAdvise = null;
else {
	strTermAdvise   = String.valueOf(strSYFromAdvise.charAt(5));
	strSYFromAdvise = strSYFromAdvise.substring(0,4);
	strSYTermAdvise = " ("+strSYFromAdvise + " - ";
	if(strTermAdvise.equals("1"))
		strSYTermAdvise += "FS)";
	else if(strTermAdvise.equals("2"))
		strSYTermAdvise += "SS)";
	else if(strTermAdvise.equals("3"))
		strSYTermAdvise += "TS)";
	else
		strSYTermAdvise += "SU)";	
	strSYToAdvise = Integer.toString(Integer.parseInt(strSYFromAdvise) + 1);	
}
//System.out.println("strSYFromAdvise : "+strSYFromAdvise+" : "+strTermAdvise);

if(strSYFromAdvise != null) {
	//I have to make sure, the student enrolling SY/Term is > currently enrolled sy/term.
	String strEnrolledSY   = null;
	String strEnrolledTerm = null;
	
	strTemp = "select sy_from, semester from stud_curriculum_hist join semester_sequence on (semester_val = semester) where user_index = "+
		strStudIndex+" and is_valid = 1 order by sy_from desc, sem_order desc";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	if(rs.next()) {
		strEnrolledSY   = rs.getString(1);
		strEnrolledTerm = rs.getString(2);
	}
	rs.close();
	
	int iCompare = CommonUtil.compareSYTerm(strEnrolledSY, strEnrolledTerm, strSYFromAdvise, strTermAdvise);
	if(iCompare == -1) {//student can enroll now.
		bolShouldEnroll = true;
	} 
//	System.out.println(" should enroll : "+bolShouldEnroll);
	//	if(enrlAddDrop.getEnrolledStudInfo(dbOP,strStudID ,strStudID,strSYFromAdvise, strSYToAdvise, strTermAdvise) == null)
//		bolShouldEnroll = true;
	if(bolShouldEnroll) {
		strTemp = "select ENCODED_BY from enrl_final_cur_list where user_index = "+strStudIndex+" and is_valid = 1 and is_temp_stud = 0 and sy_from = "+
					strSYFromAdvise+" and CURRENT_SEMESTER = "+strTermAdvise+" order by encoded_by desc";//System.out.println(strTemp);
		strTemp = dbOP.getResultOfAQuery(strTemp, 0) ;
		if(strTemp != null) {//student is advised. allow to change only if student is self advised.. 
			if(strTemp.equals(strStudIndex)) //allow re-advuse,
				bolIsStudAdvised = true;
			else
				bolAdvisingInProgress = true;//Already Advised.Enrollment In Progress.. 	
		}
					
	}
}

if(bolShouldEnroll) {
	String strOnlineAdviseParam = new utility.ReadPropertyFile().getImageFileExtn("ONLINE_ADVISE_PARAM","0");
	if(strOnlineAdviseParam == null || strOnlineAdviseParam.equals("0"))
		bolShouldEnroll = false;
}

if(bolShouldEnroll) 
	request.getSession(false).setAttribute("online_advise", "1");//0 = none, 1 = yes.
else {
	if(strSchCode.startsWith("NEU"))
		bolAllowAddDrop = true;
	else {
		String strSQLQuery = "select allow_index from ONLINE_ALLOW_ADD_DROP where stud_index = "+strStudIndex+" and is_valid = 1 and is_used = 0 and allowed_date = '"+
							WI.getTodaysDate()+"'";
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0) ;
		if(strSQLQuery != null)
			bolAllowAddDrop = true;
	}
}



/******************** start of temp student ****************************/
String strAUFApplStat = null;
boolean bolIsAllowedOnlineAdvisingTemp = false;
int[] aiStudApplStat = new int[2];

if(strTempStudIndex != null) {
	if(strSchCode.startsWith("AUF") && strTempStudIndex != null) {
		//get here the exam status. 
		String strSQLQuery = "select APPL_STAT_NAME from new_application join NEW_APPLICATION_STAT_PRELOAD on (APPL_STAT = STAT_INDEX) where application_index= "+strTempStudIndex+
			" and is_valid = 1";
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery == null)	
			strAUFApplStat = "Application Status not found.";
		else	
			strAUFApplStat = "Application Status : "+strSQLQuery;
	}
	enrollment.NAApplCommonUtil comUtil = new enrollment.NAApplCommonUtil();

	/**
	if(!comUtil.checkFormFillupStat(dbOP, strTempStudId,aiStudApplStat) )
		strErrMsg = comUtil.getErrMsg();
	else
	{
		if(aiStudApplStat[0] == -1)
			strErrMsg = comUtil.getErrMsg();
		if(aiStudApplStat[0] == -2) //user is not registered yet, -- for general information links.
			strErrMsg = "";
	}**/
	enrollment.NAApplicationForm naApplForm = new enrollment.NAApplicationForm();
	java.util.Vector vOnlineAdv = naApplForm.checkOnlineAdvsingStat(dbOP, (String)request.getSession(false).getAttribute("tempIndex"));
	if(vOnlineAdv != null && ((String)vOnlineAdv.elementAt(0)).equals("2")) 
		bolIsAllowedOnlineAdvisingTemp = true;
	
}

/******************** end for temp student ****************************/


/********* end of enrollment information ****/
	dbOP.cleanUP();
%>
<!DOCTYPE html>
<html>
<head>

  <meta charset="UTF-8">
  <title>SchoolAutomate - Menu Template</title>
	<link href="main_link.css" rel="stylesheet" type="text/css">

<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<!--Home and logout button-->
  <script style="display: none !important;">
    window.open    = function(){};
    window.print   = function(){};
  </script>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="javascript">
function ajaxRefreshSession() {
	<%if(strSchCode.length() == 0 || strTempStudIndex != null || strSchCode.startsWith("UC") ) {%>
		return;
	<%}%>
	var objCOAInput = document.getElementById("update_session");
	this.InitXmlHttpObject2(objCOAInput, 2, "checking session...");//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=211";
	this.processRequest(strURL);

	window.setTimeout("ajaxRefreshSession()", 60000);
}

function ViewExamStat(strTempStudId) {
	<%if(strAUFApplStat != null){%>
		alert("<%=strAUFApplStat%>");
		return;
	<%}%>
	parent.rightFrame.location = "../ADMISSION%20MODULE%20PAGES/single%20file%20items/ADMISSION%20FOR%20NEW_TRANSFERRE STUDENTS/applicant_sched_view.jsp?temp_id="+strTempStudId;
}
</script>

<body onLoad="ajaxRefreshSession();">
<div class='maincon'>
  <!--<form action="../../commfile/logout.jsp" method="post" target="_parent" name="form_">-->
  	<div class='buttoncontainer'>
  		<a href="../../commfile/logout.jsp?logout_url=../index.htm" target="_top" style="text-decoration:none; color:#FFFFFF"><div class='buttonhome'><p>Home</p></div></a>
  		<%if(bolIsStudent || strTempStudIndex != null){%>
			<a href="../../commfile/logout.jsp?logout_url=../PARENTS_STUDENTS/main_files/parents_students_bottom_content.htm&body_color=#C39E60" target="_parent" style="text-decoration:none; color:#FFFFFF">
			<div class='buttonlogout'><p>Logout</p></div>
			</a>
		<%}else{%>
			<a href="./login_new.jsp" target="rightFrame" style="text-decoration:none; color:#FFFFFF">
			<div class='buttonlogout'><p>Login</p></div>
			</a>
		<%}%>
  	</div>
    <!--
	<input type="hidden" name="logout_url" value="../PARENTS_STUDENTS/main_files/parents_students_bottom_content.htm">
    <input type="hidden" name="body_color" value="#C39E60">
  </form>
	-->
	
	
	
  <div class="container">  
  <ul>
	<%if(strTempStudIndex != null){%>
		<li class="dropdown">
		<%if(strAUFApplStat != null){%>
			<a href="#" data-toggle="dropdown" onClick="alert('<%=strAUFApplStat%>')">
		<%}else{%>
			<a href="../ADMISSION%20MODULE%20PAGES/single%20file%20items/ADMISSION%20FOR%20NEW_TRANSFERRE STUDENTS/applicant_sched_view.jsp?temp_id=<%=strTempStudId%>" data-toggle="dropdown" target="rightFrame">
		<%}%>
		
		<!--<a href="javascript:ViewExamStat('<%=strTempStudId%>');" target="rightFrame" data-toggle="dropdown">-->Exam/Interview Status</a></li>
		<li class="dropdown">
		  <!--<a href="javascript:LoadAdmission();" data-toggle="dropdown">Admission <i class="icon-arrow"></i></a>-->
		  <a href="#" data-toggle="dropdown">Personal Info<i class="icon-arrow"></i></a>
		  <ul class="dropdown-menu">
			<li><a href="../ADMISSION%20MODULE%20PAGES/single%20file%20items/ADMISSION%20FOR%20NEW_TRANSFERRE STUDENTS/gspis_page_edit_temp.jsp" target="rightFrame">View/Edit Personal Info</a></li>
			<li><a href="../ADMISSION%20MODULE%20PAGES/single%20file%20items/ADMISSION%20FOR%20NEW_TRANSFERRE STUDENTS/change_password.jsp" target="rightFrame">Change Password</a></li>
			<li><a href="../ADMISSION%20MODULE%20PAGES/single%20file%20items/ADMISSION%20FOR%20NEW_TRANSFERRE STUDENTS/gspis_print.jsp" target="rightFrame">Print Personal Info</a></li>
		  </ul>
		</li>
		<li class="dropdown">
		  <!--<a href="javascript:LoadAdmission();" data-toggle="dropdown">Admission <i class="icon-arrow"></i></a>-->
		  <a href="#" data-toggle="dropdown">Online Advising Access<i class="icon-arrow"></i></a>
		  <ul class="dropdown-menu">
			<%if(bolIsAllowedOnlineAdvisingTemp) {%>
				<li><a href="../../ADMIN_STAFF/enrollment/advising/advising_all_in_one_p1.jsp?online_advising=1" target="rightFrame">Advising and Scheduling</a></li>
				<li><a href="../../ADMIN_STAFF/enrollment/advising/gen_advised_schedule_print.jsp" target="rightFrame">View Advised Subject & Assessment</a></li>
			<%}else{%>
				<li><a href="#">Online Advising is not allowed</a></li>
			<%}%>
		  </ul>
		</li>
  	<%}else if(!bolIsStudent) {//this link is for the temp students only.%>
		<li class="dropdown">
		  <!--<a href="javascript:LoadAdmission();" data-toggle="dropdown">Admission <i class="icon-arrow"></i></a>-->
		  <a href="#" data-toggle="dropdown">Admission<i class="icon-arrow"></i></a>
		  <ul class="dropdown-menu">
			<li><a href="../ADMISSION%20MODULE%20PAGES/single%20file%20items/registration_page.jsp" target="rightFrame">New Registration/Login</a></li>
			<li><a href="../ADMISSION%20MODULE%20PAGES/single%20file%20items/GENERAL%20LINKS/courses_offered.jsp" target="rightFrame">Courses Offered</a></li>
			<li><a href="../ADMISSION%20MODULE%20PAGES/single%20file%20items/GENERAL%20LINKS/curriculum_page1.jsp" target="rightFrame">Courses Curriculum</a></li>
			<li><a href="../ADMISSION%20MODULE%20PAGES/single%20file%20items/GENERAL%20LINKS/admission_courses_requirements.jsp" target="rightFrame">Admission Requirement</a></li>
			<li><a href="../ADMISSION%20MODULE%20PAGES/single%20file%20items/GENERAL%20LINKS/admission_schedules.jsp" target="rightFrame">Admission Schedule</a></li>
			<li><a href="../ADMISSION%20MODULE%20PAGES/single%20file%20items/GENERAL%20LINKS/exam_sched.jsp" target="rightFrame">Entrance Exam Schedule</a></li>
			<li><a href="../ADMISSION%20MODULE%20PAGES/single%20file%20items/GENERAL%20LINKS/admission_step.htm" target="rightFrame">Steps in Enrollment</a></li>
		  </ul>
		</li>
	<%}else if(bolIsStudent){%>
		<li class="dropdown"><a href="../clearances/status/clearance_main.jsp" target="rightFrame" data-toggle="dropdown">Student Clearance</a></li>
		<li class="dropdown">
		<!--
		  <a href="../enrollment/enrollment_links.jsp" target="_self" data-toggle="dropdown">Enrollment</a>      
		-->
		<a href="#" data-toggle="dropdown">Enrollment<i class="icon-arrow"></i></a>
		<ul class="dropdown-menu">
			<%if(bolShouldEnroll) {
				if(bolAdvisingInProgress){%>
					<li><a href="#">Already Advised.Enrollment In Progress..</a></li>
				<%}else{%>
					<li><a href="../enrollment/admission_registration_stud_online.jsp" target="rightFrame">Online Advising<%if(bolIsStudAdvised){%> (Re-advise) <%}%><%=strSYTermAdvise%></a></li>
					
					<%if(bolIsStudAdvised){%>
					<li><a href="../../ADMIN_STAFF/enrollment/advising/print_esl_main.jsp?online_advising=1&stud_id=<%=strUserId%>" target="rightFrame">Print/View Advised Student Load</a></li>
					<%}				
				}
			}else{%>
				<%if(bolAllowAddDrop) {%>
					<li><a href="../../ADMIN_STAFF/enrollment/change_subjects/change_subject_add.jsp?online_advising=1" target="rightFrame">Add/Drop</a></li>
				<%}%>
				<li><a href="../enrollment/subjects_enrolled.jsp" target="rightFrame">Subjects Enrolled</a></li>
				<li><a href="../enrollment/schedule.jsp" target="rightFrame">Subject Load Schedule</a></li>
				<li><a href="../enrollment/fees_paid_enrollment.jsp" target="rightFrame">Fees Paid During  Enrollment</a></li>
				<li><a href="../enrollment/changed_subjects.jsp" target="rightFrame">Changed Subjects</a></li>
			<%}%>
			
		</ul>
		</li>
		<li class="dropdown">
		  <a href="#" data-toggle="dropdown">Student Account<i class="icon-arrow"></i></a>
		  <ul class="dropdown-menu">
			<li><a href="../accounts/student_ledger.jsp" target="rightFrame">Ledger</a></li>
			<li><a href="../accounts/pmt_schedule.jsp" target="rightFrame">Periodic Dues</a></li>
		  </ul>
		</li>
		<li class="dropdown">
		  <a href="#" data-toggle="dropdown">Academic Performance<i class="icon-arrow"></i></a>
		  <ul class="dropdown-menu">
<%if(!strSchCode.startsWith("UB") && !strSchCode.startsWith("EAC")){%>
				<li><a href="../acad_performance/stud_cur_residency_eval.jsp" target="rightFrame">Check List</a></li>
<%}%>				
			<li><a href="../acad_performance/cm_assignment.jsp" target="rightFrame">Class Assignment</a></li>
			<li><a href="../acad_performance/class_attendance.jsp" target="rightFrame">Class Attendance</a></li>
			<li><a href="../acad_performance/campus_attendance.jsp" target="rightFrame">Campus Attendance</a></li>
			<li><a href="../../faculty_acad/stud/stud_acad.jsp?is_student=1" target="rightFrame">Awards/Achievements</a></li>
			<li><a href="../acad_performance/fieldwork_ojt.jsp" target="rightFrame">Field Work Profile/OJT</a></li>
			<li><a href="../acad_performance/grade_release.jsp" target="rightFrame">Grading Per Exam Period</a></li>
		  </ul>
		</li>
		<li class="dropdown">
		  <a href="#" data-toggle="dropdown">Non-Acad Performance<i class="icon-arrow"></i></a>
		  <ul class="dropdown-menu">
			<li><a href="../non_acad_performance/organizational_membership.jsp" target="rightFrame">Membership</a></li>
			<li><a href="../../faculty_acad/stud/stud_non_acad.jsp?is_student=1" target="rightFrame">Awards/Achievements</a></li>
		  </ul>
		</li>
		<li class="dropdown">
		  <a href="../non_acad_performance/violation.jsp" target="rightFrame" data-toggle="dropdown">Discipline Monitoring</a>      
		</li>
		<li class="dropdown">
		  <a href="#" data-toggle="dropdown">Personal Information<i class="icon-arrow"></i></a>
		  <ul class="dropdown-menu">
<%
if(!bolIsParent) {
	if(strSchCode.startsWith("AUF") || strSchCode.startsWith("WNU") || strSchCode.startsWith("CSA") || 
	strSchCode.startsWith("WUP") || strSchCode.startsWith("UPH") || strSchCode.startsWith("MARINER") || strSchCode.startsWith("_NEU")){//no longer allowed to edit information%>
			<li><a href="../../ADMIN_STAFF/admission/stud_personal_info_page2.jsp?my_home=1" target="rightFrame">Edit Personal Info</a></li>
<%}
}%>
			<li><a href="../../my_home/stud_personal_info_page.jsp" target="rightFrame">View Personal Info</a></li>
			<li><a href="../../my_home/stud_personal_info_page.jsp?print=1" target="rightFrame">Print Personal Info</a></li>
<%if(bolIsParent) {%>
			<li><a href="../../ADMIN_STAFF/parent_registration/change_password.jsp?bgcol=9FBFD0&headercol=47768F" target="rightFrame">Change Password</a></li>
<%}else{%>
			<li><a href="../../my_home/change_password.jsp?bgcol=9FBFD0&headercol=47768F" target="rightFrame">Change Password</a></li>
<%}if(strSchCode.startsWith("UB")){%>
			<li><a href="../guidance/exit_interview/exit_interview.jsp" target="rightFrame">Exit Interview</a></li>
<%}%>	
		  </ul>
		</li>
<%if(!bolIsParent){%>
		<li class="dropdown"><a href="../../lms/" target="_top" data-toggle="dropdown">Library</a></li>
	<%if(strSchCode.startsWith("AUF")){%>
		<li class="dropdown"><a href="http://search.ebscohost.com/login.aspx?authtype=uid" target="_blank" data-toggle="dropdown">Go to EBSCO research Database</a></li>
	<%}if(strSchCode.startsWith("CIT") || strSchCode.startsWith("SWU") || strSchCode.startsWith("NEU")){%>
		<li class="dropdown"><a href="../faculty_eval/eval_main.jsp" target="rightFrame" data-toggle="dropdown">Faculty Evaluation</a></li>
	<%}if(bolIsOnlinePmt){%>
		<li class="dropdown"><a href="../onlinepayment/user_summary.jsp" target="rightFrame" data-toggle="dropdown">Online Payment</a></li>
	<%}%>
<%}//do not show if parent

}//end of display if student logged in 
if(strShowClassProgView.equals("1")) {%>
		<li class="dropdown"><a href="../../class_offered_stat_open.jsp" target="rightFrame" data-toggle="dropdown">View Class Program</a></li>
<%}%>
  </ul>
</div>

</div>

<label id="update_session" style="font-size:0px;"> This is a test.. </label>
  <script>		
    // Dropdown Menu
var dropdown = document.querySelectorAll('.dropdown');
var dropdownArray = Array.prototype.slice.call(dropdown,0);
dropdownArray.forEach(function(el){
	var button = el.querySelector('a[data-toggle="dropdown"]'),
			menu = el.querySelector('.dropdown-menu'),
			arrow = button.querySelector('i.icon-arrow');
	if(!menu)
		return;
		
	button.onclick = function(event) {
		if(!menu.hasClass('show')) {
			menu.classList.add('show');
			menu.classList.remove('hide');
			arrow.classList.add('open');
			arrow.classList.remove('close');
			event.preventDefault();
		}
		else {
			menu.classList.remove('show');
			menu.classList.add('hide');
			arrow.classList.remove('open');
			arrow.classList.add('close');
			event.preventDefault();
		}
	};
})

Element.prototype.hasClass = function(className) {
    return this.className && new RegExp("(^|\\s)" + className + "(\\s|$)").test(this.className);
};

function LoadAdmission()
{
	//load two pages in both frames ;-)
	parent.leftFrame.location="../ADMISSION MODULE PAGES/single file items/ADMISSION FOR NEW_TRANSFERRE STUDENTS/adm_new_transferee_links.jsp";
	parent.rightFrame.location="../ADMISSION MODULE PAGES/single file items/registration_page.jsp";
	//location="../ADMISSION MODULE PAGES/single file items/ADMISSION FOR NEW_TRANSFERRE STUDENTS/index_newstud.htm";

}
  </script>

</body>

</html>