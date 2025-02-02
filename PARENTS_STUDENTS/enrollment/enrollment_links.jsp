<%
//show the links only if the student is logged in.";
String strAuthIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
String strUserId = (String)request.getSession(false).getAttribute("userId");
boolean bolIsStudent = false;
if(strUserId != null && strUserId.trim().length() > 0)
{
	if(strAuthIndex.compareTo("4") ==0 || strAuthIndex.compareTo("6") ==0)
		bolIsStudent = true;
}

boolean bolIsParent = false;
if((String)request.getSession(false).getAttribute("parent_i") != null) 
	bolIsParent = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
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

//-->
</script>
<link href="../../css/admissionmainmenu.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>

<body bgcolor="#578EAC" onLoad="MM_preloadImages('../../images/home_small_rollover.gif','../../images/help_small_rollover.gif','../../images/logout_rollover.gif')" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <form action="../../commfile/logout.jsp" method="post" target="_parent">
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="../main_files/login_success.htm" target="_parent" onMouseOver="MM_swapImage('Image1','','../../images/home_small_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/home_small.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image2','','../../images/help_small_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_rollover.gif',1)" onMouseOut="MM_swapImgRestore()">
        <input type="image" src="../../images/logout.gif" name="Image3" width="65" height="22" border="0" id="Image3">
        </a> </td>
    </tr>
    <input type="hidden" name="logout_url" value="../PARENTS_STUDENTS/main_files/parents_students_bottom_content.htm">
    <input type="hidden" name="body_color" value="#C39E60">
  </form>
  <tr>
    <td height="25" colspan="3" bgcolor="#86AEC4"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>MAIN
        MENU</strong></font></div></td>
  </tr>
  <%
if(!bolIsStudent){%>
  <tr>
    <td height="19">&nbsp;</td>
    <td  colspan="2" class="admissionmainmenu"><em><font color="#FFFFFF" size="1" face="Geneva, Arial, Helvetica, sans-serif"><a href="../main_files/parents_student_main_page_rightFrame.jsp" target="rightFrame"><img src="../../images/login_parent.gif" border="0"></a>click
      to login</font></em></td>
  </tr>
  <%}else{%>
  <tr>
    <td height="8">&nbsp;</td>
    <td colspan="2" class="admissionmainmenu">&nbsp;</td>
  </tr>
<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,java.util.Vector" %>
<%
//Show the Online advising only if the student is not enrolled to this current opened sem.
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
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
EnrlAddDropSubject enrlAddDrop = new EnrlAddDropSubject();
String strTemp = null;
String strStudID = (String)request.getSession(false).getAttribute("userId");
String strStudIndex = dbOP.mapUIDToUIndex(strStudID);
boolean bolShouldEnroll = false;
boolean bolIsStudAdvised = false;//only if student is already advised. if stud is advised, i have to give another link to re-advise.
boolean bolAdvisingInProgress = false;//true only if advised by faculty. 

String strSYFromAdvise = new utility.ReadPropertyFile().getImageFileExtn("ONLINE_ADVISE_SYTERM","0");
String strSYToAdvise   = null;
String strTermAdvise   = null;//get from read property file :: ONLINE_ADVISE_SYTERM
String strSYTermAdvise = null;


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

dbOP.cleanUP();//System.out.println(strSYTermAdvise);
if(bolShouldEnroll) {
if(bolAdvisingInProgress){%>
	  <tr>
		<td height="25"><img src="../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
		<td colspan="2" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">Already Advised.Enrollment In Progress..</font></strong></td>
	  </tr>
<%}else{%>
	  <tr>
		<td height="25"><img src="../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
		<td colspan="2" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
		<a href="./admission_registration_stud_online.jsp" target="rightFrame">Online Advising
		<%
		if(bolIsStudAdvised){%> (Re-advise) <%}%><%=strSYTermAdvise%>
		</a></font></strong></td>
	  </tr>
	<%if(bolIsStudAdvised){%>
	  <tr>
		<td height="25"><img src="../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
		<td colspan="2" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
		<a href="../../ADMIN_STAFF/enrollment/advising/print_esl_main.jsp?online_advising=1&stud_id=<%=strStudID%>" target="rightFrame">
			Print/View Advised Student Load</a></font></strong></td>
	  </tr>
	<%}//advised student load
  }//only if bolAdvisingInProgress is false.
}else{%>
  <tr>
    <td height="25"><img src="../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td colspan="2" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
      <a href="./subjects_enrolled.jsp" target="rightFrame">Subjects Enrolled
      </a></font></strong></td>
  </tr>
  <tr>
    <td height="25"><img src="../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td colspan="2"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
      <a href="./schedule.jsp" target="rightFrame">Subject Load Schedule</a></font></strong></td>
  </tr>
  <tr>
    <td height="25"><img src="../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td colspan="2" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
	<a href="./fees_paid_enrollment.jsp" target="rightFrame">Fees Paid During  Enrollment</a></font></strong></td>
  </tr>
<!--
  <tr>
    <td height="25"><img src="../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td colspan="2"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
      <a href="./installment_sched.jsp" target="rightFrame">Payment Schedule</a></font></strong></td>
  </tr>
-->
  <tr>
    <td><img src="../../images/small_white_box.gif" width="4" height="6"></td>
    <td height="10" colspan="2"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="./changed_subjects.jsp" target="rightFrame">Changed
      Subjects </a></font></strong></td>
  </tr>
  <%}//only if student is ready to enroll.
  }%>
</table>
</body>
</html>
