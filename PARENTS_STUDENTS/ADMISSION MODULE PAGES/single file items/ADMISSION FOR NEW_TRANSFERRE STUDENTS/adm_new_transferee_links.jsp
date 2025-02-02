<%
String strTempStudId = (String)request.getSession(false).getAttribute("tempId");//System.out.println(strTempStudId);
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

String strAUFApplStat = null;

if(strSchCode.startsWith("AUF") && strTempStudId != null) {
	utility.DBOperation dbOP = new utility.DBOperation();
	 
	//get here the exam status. 
	String strSQLQuery = "select APPL_STAT_NAME from new_application join NEW_APPLICATION_STAT_PRELOAD on (APPL_STAT = STAT_INDEX) where temp_id= '"+strTempStudId+
		"' and is_valid = 1";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery == null)	
		strAUFApplStat = "Application Status not found.";
	else	
		strAUFApplStat = "Application Status : "+strSQLQuery;
	dbOP.cleanUP();
}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../admissionmainmenu.css" rel="stylesheet" type="text/css">
<script language="JavaScript" type="text/JavaScript">
<!--
function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}

function PrintPg()
{
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
	{
		var win=window.open("./gspis_print.jsp","PrintWindow",'scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
function ViewExamStat(strTempStudId) {
	<%if(strAUFApplStat != null){%>
		alert("<%=strAUFApplStat%>");
		return;
	<%}%>
	parent.rightFrame.location = "./applicant_sched_view.jsp?temp_id="+strTempStudId;
}
//-->
</script>
<link href="../../../../css/admissionmainmenu.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>

<body bgcolor="#578EAC" onLoad="MM_preloadImages('../../../../images/home_small_rollover.gif','../../../../images/help_small_rollover.gif','../../../../images/logout_rollover.gif')" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <form action="../../../../commfile/logout.jsp" method="post" target="_parent">
    <tr>
      <td colspan="2">&nbsp;</td>
      <td colspan="2"><a href="../../../main_files/parents_students_bottom_content.htm" target="bottomFrame" onMouseOver="MM_swapImage('Image1','','../../../../images/home_small_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../../../images/home_small.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a> <a href="javascript:;" onMouseOver="MM_swapImage('Image2','','../../../../images/help_small_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../../../images/help_small.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a onMouseOver="MM_swapImage('Image3','','../../../../images/logout_rollover.gif',1)" onMouseOut="MM_swapImgRestore()">
        <input type="image" src="../../../../images/logout.gif" name="Image3" width="65" height="22" border="0" id="Image3">
        </a></td>
    </tr>
    <input type="hidden" name="logout_url" value="../PARENTS_STUDENTS/ADMISSION%20MODULE%20PAGES/single%20file%20items/ADMISSION%20FOR%20NEW_TRANSFERRE%20STUDENTS/index_newstud.htm">
    <input type="hidden" name="body_color" value="#C39E60">
    <input type="hidden" name="login_type" value="temp_stud">
  </form>
  <tr>
    <td height="25" colspan="4" bgcolor="#86AEC4"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>MAIN
        MENU</strong></font></div></td>
  </tr>
  <%
if(strTempStudId == null || strTempStudId.trim().length() ==0)
{%>
  <tr>
    <td height="19" colspan="2">&nbsp;</td>
    <td width="96%" colspan="2" class="admissionmainmenu"><em><font color="#FFFFFF" size="1" face="Geneva, Arial, Helvetica, sans-serif"><a href="../registration_page.jsp" target="rightFrame"><img src="../../../../images/login_parent.gif" border="0"></a>click
      to login</font></em></td>
  </tr>
  <%}%>
  <tr>
    <td height="25" colspan="2"><img src="../../../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td colspan="2" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../GENERAL%20LINKS/courses_offered.jsp" target="rightFrame">Courses Offered</a></font> </strong></td>
  </tr>
  <tr>
    <td height="25" colspan="2"><img src="../../../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td colspan="2"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../GENERAL LINKS/curriculum_page1.jsp" target="rightFrame">Courses Curriculum</a></font></strong></td>
  </tr>
<!--
  <tr>
    <td height="25" colspan="2"><img src="../../../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td colspan="2"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
	<a href="../GENERAL%20LINKS/courses_fees.jsp" target="rightFrame">Course Fees</a> </font></strong></td>
  </tr>
-->
  <tr>
    <td height="25" colspan="2"><img src="../../../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td colspan="2" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../GENERAL LINKS/admission_courses_requirements.jsp" target="rightFrame">Requirements</a></font></strong></td>
  </tr>
  <tr>
    <td colspan="2"><img src="../../../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td height="25" colspan="2"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><strong><a href="../GENERAL%20LINKS/admission_schedules.jsp" target="rightFrame">Admission Schedules</a></strong></font></td>
  </tr>
  <tr>
    <td colspan="2"><img src="../../../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td height="26" colspan="2"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><strong><a href="../GENERAL LINKS/exam_sched.jsp" target="rightFrame">Entrance Exam Schedules</a></strong></font></td>
  </tr>
  <tr>
    <td colspan="2"><img src="../../../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td height="26" colspan="2"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><strong><a href="../GENERAL%20LINKS/admission_step.htm" target="rightFrame">Steps in Enrollment</a></strong></font></td>
  </tr>
<!--  <tr>
    <td colspan="2"><img src="../../../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td height="26" colspan="2"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../GENERAL%20LINKS/accredited_school.jsp" target="rightFrame"><strong>Accredited
      School List</strong></a></font></td>
  </tr>
-->  <tr>
    <td colspan="2">&nbsp;</td>
    <td height="10" colspan="2">&nbsp;</td>
  </tr>
</table>
<%@ page language="java" import="utility.*,enrollment.NAApplCommonUtil" %>
<%
//check here if the user is logged in or not, if not do not show below. Also please check if the user has filled up the form2. If not,
//FLASH soemthing to indicate - Fill up the next step.
DBOperation dbOP = null;
String strErrMsg = null;
int[] aiStudApplStat = new int[2];

boolean bolIsAllowedOnlineAdvising = false;
String strOnlineAdvisingReason     = null;

boolean bolIsBasic = false;

if(strTempStudId != null) {
	//open dbConnection here to check if user is registered already.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		strErrMsg = "error in opening connection.";
	}

	if(strErrMsg == null)
	{
		//check if user has filled up the form.
		NAApplCommonUtil comUtil = new NAApplCommonUtil();

		if(!comUtil.checkFormFillupStat(dbOP, strTempStudId,aiStudApplStat) )
			strErrMsg = comUtil.getErrMsg();
		else
		{
			if(aiStudApplStat[0] == -1)
				strErrMsg = comUtil.getErrMsg();
			if(aiStudApplStat[0] == -2) //user is not registered yet, -- for general information links.
				strErrMsg = "";
		}
	}
	
	///check if online advising is allowed or not.
	enrollment.NAApplicationForm naApplForm = new enrollment.NAApplicationForm();
	java.util.Vector vOnlineAdv = naApplForm.checkOnlineAdvsingStat(dbOP, (String)request.getSession(false).getAttribute("tempIndex"));
	if(vOnlineAdv != null && ((String)vOnlineAdv.elementAt(0)).equals("2")) { 
		bolIsAllowedOnlineAdvising = true;
		
		//no online advising for grade school. 
		String strSQLQuery = "select course_index from new_application join appl_form_schedule on (new_application.appl_sch_index = appl_form_schedule.appl_sch_index) "+
								" where application_index = "+(String)request.getSession(false).getAttribute("tempIndex");
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery != null && strSQLQuery.equals("0"))
			bolIsAllowedOnlineAdvising = false;//no online advsing for grade school.. 
	}
	
	
	dbOP.cleanUP();
}
else
	strErrMsg = "";
	

//System.out.println("testing : strErrMsg ="+strErrMsg);
if(strErrMsg != null || strTempStudId == null)
{%>
<font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif" size="2"><b><%=strErrMsg%></b></font>
<%//System.out.println("testing");
return;
}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td height="25" colspan="4" bgcolor="#86AEC4"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>PERSONAL 
        MENU</strong></font></div></td>
  </tr>

  <%
//show this link only if it is not filled up yet
if(aiStudApplStat[0] == 0) //the student has not yet filled up form2
{%>
  <!--<tr>
    <td colspan="2"><img src="../../../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td height="25" colspan="2"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="adm_new_transferee_page2.jsp" target="rightFrame">Fill-up
      Application Form 2</a></font></td>
  </tr>-->
  <%}%>
  <tr>
    <td colspan="2"><img src="../../../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td width="96%" height="25" colspan="2"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="javascript:ViewExamStat('<%=strTempStudId%>');">Exam/Interview Status</a></font></td>
  </tr>
 <!--
  <tr>
    <td colspan="2"><img src="../../../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td height="25" colspan="2"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="application_status.htm" target="rightFrame">Check
      Application Status</a></font></td>
  </tr>
 -->
  <tr>
    <td colspan="2"><img src="../../../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td height="25" colspan="2" valign="bottom"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">My
      Personal Info</font></td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td height="20" colspan="2"><img src="../../../../images/small_white_box.gif" width="4" height="6">&nbsp;<font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="./gspis_page_edit_temp.jsp" target="rightFrame">View/Edit Personal Info</a></font></td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td height="20" colspan="2"><img src="../../../../images/small_white_box.gif" width="4" height="6">&nbsp;<font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="./change_password.jsp" target="rightFrame">Change Password </a></font></td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td height="20" colspan="2"><img src="../../../../images/small_white_box.gif" width="4" height="6">&nbsp;<font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="javascript:PrintPg();">Print Personal Info</a></font></td>
  </tr>
  <tr>
    <td colspan="2"><img src="../../../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td height="25" colspan="2" valign="bottom"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Online Advising Access</font></td>
  </tr>
  <%if(bolIsAllowedOnlineAdvising) {%>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td height="20" colspan="2"><img src="../../../../images/small_white_box.gif" width="4" height="6">&nbsp;<font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
	<a href="../../../../ADMIN_STAFF/enrollment/advising/advising_all_in_one_p1.jsp?online_advising=1" target="rightFrame">Advising and Scheduling</a></font></td>
	
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td height="20" colspan="2"><img src="../../../../images/small_white_box.gif" width="4" height="6">&nbsp;<font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
	<a href="../../../../ADMIN_STAFF/enrollment/advising/gen_advised_schedule_print.jsp" target="rightFrame">View Advised Subject & Assessment</a></font></td>
  </tr>
  <%}else{%>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td height="20" colspan="2">&nbsp;<font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
	<strong>Online Advising is not allowed</strong></font></td>
  </tr>
  <%}%>
</table>
</body>
</html>
