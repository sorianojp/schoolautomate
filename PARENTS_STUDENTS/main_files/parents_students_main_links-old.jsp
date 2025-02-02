<%
//show the links only if the student is logged in.";
String strAuthIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
String strUserId = (String)request.getSession(false).getAttribute("userId");
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
if(bolIsStudent) {
	utility.DBOperation dbOP = new utility.DBOperation();
	String strSQLQuery = "select prop_val from read_property_file where prop_name = 'ONLINE_GS_PMT'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery != null && strSQLQuery.equals("1"))
		bolIsOnlinePmt = true;
	dbOP.cleanUP();
}
%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<link href="../../css/admissionmainmenu.css" rel="stylesheet" type="text/css">
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
function LoadAdmission()
{
	//load two pages in both frames ;-)
	parent.leftFrame.location="../ADMISSION MODULE PAGES/single file items/ADMISSION FOR NEW_TRANSFERRE STUDENTS/adm_new_transferee_links.jsp";
	parent.rightFrame.location="../ADMISSION MODULE PAGES/single file items/registration_page.jsp";
	//location="../ADMISSION MODULE PAGES/single file items/ADMISSION FOR NEW_TRANSFERRE STUDENTS/index_newstud.htm";

}
//-->
</script>
</head>

<body bgcolor="#578EAC" onLoad="MM_preloadImages('../../images/home_small_rollover.gif','../../images/help_small_rollover.gif','../../images/logout_rollover.gif')" >
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <form action="../../commfile/logout.jsp" method="post" target="_parent">
    <tr>
      <td height="18" width="10">&nbsp;</td>
      <td colspan="2" class="admissionmainmenu"><a href="../main_files/login_success.htm" target="_parent" onMouseOver="window.status='Go back to home page'; MM_swapImage('Image1','','../../images/home_small_rollover.gif',1); return true" onMouseOut="MM_swapImgRestore()"><img src="../../images/home_small.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image2','','../../images/help_small_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_rollover.gif',1)" onMouseOut="MM_swapImgRestore()">
        <input type="image" src="../../images/logout.gif" name="Image3" width="65" height="22" border="0" id="Image3">
        </a></td>
    </tr>
    <input type="hidden" name="logout_url" value="../PARENTS_STUDENTS/main_files/parents_students_bottom_content.htm">
    <input type="hidden" name="body_color" value="#C39E60">
  </form>
  <!--  <tr>
    <td height="18"><img src="../../images/small_white_box.gif" name="Image4" width="4" height="6" id="Image4"></td>
    <td colspan="2" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="javascript:LoadAdmission();">Registration</a></font></strong></td>
  </tr> -->
<%if(!bolIsStudent) {//this link is for the temp students only.%>
  <tr>
    <td height="18"><div align="left"><img src="../../images/small_white_box.gif" name="Image4" width="4" height="6" id="Image4"></div></td>
    <td colspan="2" class="admissionmainmenu"><div align="left"><strong><font color="#FFFFFF" size="5" face="Geneva, Arial, Helvetica, sans-serif"><a href="javascript:LoadAdmission();">Admission</a></font>
        </strong></div></td>
  </tr>
<%}if(bolIsStudent){%>
  <tr>
    <td height="18"><div align="left"><img src="../../images/small_white_box.gif" name="Image4" width="4" height="6" id="Image4"></div></td>
    <td colspan="2" class="admissionmainmenu"><div align="left"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../enrollment/enrollment_links.jsp" target="_self">Enrollment</a></font></strong></div></td>
  </tr>
  <tr>
    <td height="18"><div align="left"><img src="../../images/small_white_box.gif" name="Image4" width="4" height="6" id="Image4"></div></td>
    <td colspan="2" class="admissionmainmenu"><div align="left"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../accounts/student_ledger.jsp" target="rightFrame">Accounts</a></font></strong></div></td>
  </tr>
  <tr>
    <td height="18"><div align="left"><img src="../../images/small_white_box.gif" name="Image4" width="4" height="6" id="Image4"></div></td>
    <td colspan="2"><div align="left"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../acad_performance/acad_performance_links.jsp" target="_self">Academic Performance</a></font></strong></div></td>
  </tr>
  <tr>
    <td height="18"><div align="left"><img src="../../images/small_white_box.gif" name="Image4" width="4" height="6" id="Image4"></div></td>
    <td colspan="2"><div align="left"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../non_acad_performance/non_acad_performance_links.jsp" target="_self">Non-Academic Performance</a></font></strong></div></td>
  </tr>
  <tr>
    <td height="18"><div align="left"><img src="../../images/small_white_box.gif" name="Image4" width="4" height="6" id="Image4"></div></td>
    <td colspan="2"><div align="left"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../../ADMIN_STAFF/sao/vio_conflict/vio_conflict.jsp?is_student=1&show_all_sem=1" target="rightFrame">Student's Discipline Monitoring</a></font></strong></div></td>
  </tr>
  <tr>
    <td height="18"><div align="left"><img src="../../images/small_white_box.gif" name="Image4" width="4" height="6" id="Image4"></div></td>
    <td colspan="2"><div align="left"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> Personal Info</font></strong></div></td>
  </tr>
<%
if(!bolIsParent) {
	if(strSchCode.startsWith("AUF") || strSchCode.startsWith("WNU") || strSchCode.startsWith("CSA") || 
	strSchCode.startsWith("WUP") || strSchCode.startsWith("UPH") || strSchCode.startsWith("UC")){%>
	  <tr>
		<td height="18">&nbsp;</td>
		<td width="6%">&nbsp;<img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td width="89%"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../../ADMIN_STAFF/admission/stud_personal_info_page2.jsp?my_home=1" target="rightFrame">Edit Personal Info</a></font></td>
	  </tr>
<%}
}%>
  <tr>
    <td height="18">&nbsp;</td>
    <td width="6%">&nbsp;<img src="../../images/small_white_box.gif" width="4" height="6"></td>
    <td width="89%"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../../my_home/stud_personal_info_page.jsp" target="rightFrame">View Personal Info</a></font></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td width="6%">&nbsp;<img src="../../images/small_white_box.gif" name="Image4" width="4" height="6" id="Image4"></td>
    <td width="89%"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../../my_home/stud_personal_info_page.jsp?print=1" target="rightFrame">Print Personal Info</a></font></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td>&nbsp;<img src="../../images/small_white_box.gif" width="4" height="6"></td>
    <td>
<%if(bolIsParent) {%>
		<font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../../ADMIN_STAFF/parent_registration/change_password.jsp?bgcol=9FBFD0&headercol=47768F" target="rightFrame">Change Password</a></font>
<%}else{%>
		<font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../../my_home/change_password.jsp?bgcol=9FBFD0&headercol=47768F" target="rightFrame">Change Password</a></font>
<%}%>	
	</td>
  </tr>
<!--
  <tr>
    <td height="18"><img src="../../images/small_white_box.gif" name="Image4" width="4" height="6" id="Image4"></td>
    <td colspan="2"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../../faculty_acad/classman/cm_course_ref.jsp?is_student=1" target="rightFrame">Course/Subject
      Reference</a></font></strong></td>
  </tr>
  <tr>
    <td height="18"><img src="../../images/small_white_box.gif" name="Image4" width="4" height="6" id="Image4"></td>
    <td colspan="2" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Online
      Exam</font></strong></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td width="5%">&nbsp;<img src="../../images/small_white_box.gif" name="Image4" width="4" height="6" id="Image4"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="application_status.htm" target="rightFrame">
      </a></font></td>
    <td width="90%"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../online_exam_students/online_exam_page1.jsp" target="rightFrame">Take
      Exam </a></font></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td>&nbsp;<font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="application_status.htm" target="rightFrame"><img src="../../images/small_white_box.gif" name="Image4" width="4" height="6" border="0" id="Image4">
      </a></font></td>
    <td><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../online_exam_students/online_exam_check_result_page1.jsp" target="rightFrame">Check
      Result </a></font></td>
  </tr>
-->
<%if(!bolIsParent){%>
	<%
	if(strSchCode.startsWith("AUF") || true){%>
	  <tr>
		<td height="18"><img src="../../images/small_white_box.gif" name="Image4" width="4" height="6" id="Image4"></td>
		<td colspan="2" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="javascript:alert('This feature is currently disabled');" target="_parent" onMouseOver="window.status='';return true">Organizer</a></font></strong></td>
	  </tr>
	<%}else{%>
	  <tr>
		<td height="18"><img src="../../images/small_white_box.gif" name="Image4" width="4" height="6" id="Image4"></td>
		<td colspan="2" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../../ADMIN_STAFF/organizer/organizer_index.jsp?is_parent=1" target="_parent" onMouseOver="window.status='';return true">Organizer</a></font></strong></td>
	  </tr>
	<%}%>
	  <tr>
		<td height="18"><img src="../../images/small_white_box.gif" name="Image4" width="4" height="6" id="Image4"></td>
		<td colspan="2" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../../lms/" target="_top">Library</a></font></strong></td>
	  </tr>
	<%
	if(strSchCode.startsWith("AUF")){%>
	  <tr>
		<td height="18"><img src="../../images/arrow_blue.gif"></td>
		<td colspan="2" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="http://search.ebscohost.com/login.aspx?authtype=uid" target="_blank">Go to EBSCO research Database</a></font></strong></td>
	  </tr>
	<%}
	
	if(strSchCode.startsWith("CIT") || strSchCode.startsWith("SWU")){%>
	  <tr>
		<td height="18"><img src="../../images/arrow_blue.gif"></td>
		<td colspan="2" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../faculty_eval/eval_main.jsp" target="rightFrame">Go to Faculty Evaluation</a></font></strong></td>
	  </tr>
	<%}
	
if(bolIsOnlinePmt){%>
  <tr>
    <td height="18"><div align="left"><img src="../../images/small_white_box.gif" name="Image4" width="4" height="6" id="Image4"></div></td>
    <td colspan="2" class="admissionmainmenu"><div align="left"><strong><font color="#FFFFFF" size="5" face="Geneva, Arial, Helvetica, sans-serif"><a href="../onlinepayment/user_summary.jsp" target="rightFrame">Online Payment</a></font>
        </strong></div></td>
  </tr>

<%}//d onto show if parent.. 


	}
}%>
<!--
  <tr>
    <td height="18"><img src="../../images/small_white_box.gif" name="Image4" width="4" height="6" id="Image4"></td>
    <td colspan="2" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Email</font></strong></td>
  </tr>
-->
</table>
</body>
</html>
