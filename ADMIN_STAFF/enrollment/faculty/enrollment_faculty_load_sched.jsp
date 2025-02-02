<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function DelFacLoad(strIndex)
{
	document.faculty_page.delFacLoad.value="1";
	document.faculty_page.info_index.value=strIndex;
	ReloadPage();
}
function AddFacultyLoad()
{
	document.faculty_page.addFacultyLoad.value = "1";
}
function ReloadPage()
{
	if(document.faculty_page.showList.value == 1)
	{
		document.faculty_page.college_name.value=document.faculty_page.c_index[document.faculty_page.c_index.selectedIndex].text;
		document.faculty_page.course_name.value=document.faculty_page.course_index[document.faculty_page.course_index.selectedIndex].text;
		document.faculty_page.subject_name.value=document.faculty_page.subject[document.faculty_page.subject.selectedIndex].text;
	}
	document.faculty_page.submit();
}
function ReloadSubject() {
	ReloadPage();
}
function RemoveShowList()
{
	document.faculty_page.showList.value="";
	document.faculty_page.completeRefresh.value = "1";
	ReloadPage();
}
function ShowList()
{
	document.faculty_page.showList.value="1";
	document.faculty_page.college_name.value=document.faculty_page.c_index[document.faculty_page.c_index.selectedIndex].text;
	document.faculty_page.course_name.value=document.faculty_page.course_index[document.faculty_page.course_index.selectedIndex].text;
	document.faculty_page.subject_name.value=document.faculty_page.subject[document.faculty_page.subject.selectedIndex].text;

}
function AssignFaculty(strSubSecIndex, strSchedule,strRoomNo, strLECLAB,strTotalUnit,
			strReference,strMultipleAssign)
{
	//open new widow.
	var loadPg = "./faculty_sched.jsp?form_name=faculty_page&sec_index="+strSubSecIndex+"&schedule="+escape(strSchedule)+
				"&room_no="+escape(strRoomNo)+"&LECLAB="+strLECLAB+"&total_unit="+strTotalUnit+"&subject="+
				escape(document.faculty_page.subject[document.faculty_page.subject.selectedIndex].text)+"&c_index="+
				document.faculty_page.c_c_index[document.faculty_page.c_c_index.selectedIndex].value+"&sub_off_yrf="+
				document.faculty_page.school_year_fr.value+"&sub_off_yrt="+document.faculty_page.school_year_to.value+
				"&offering_sem="+document.faculty_page.semester[document.faculty_page.semester.selectedIndex].value+
				"&opner_fac_index=user_index"+strReference+"&opner_fac_name=name"+strReference+"&college_name="+
				escape(document.faculty_page.c_c_index[document.faculty_page.c_c_index.selectedIndex].text)+
				"&multiple_assign="+strMultipleAssign+"&sub_index="+document.faculty_page.subject[document.faculty_page.subject.selectedIndex].value+
				"&d_index="+document.faculty_page.d_index[document.faculty_page.d_index.selectedIndex].value;
	//var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=yes,location=yes,directories=yes,status=no,menubar=yes');
	var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ChangeDepartment(){
	document.faculty_page.c_c_index.text = "ALL";
	document.faculty_page.c_c_index.value = "0";
}

function ChangeCollege(){
	document.faculty_page.d_index.text = "ALL";
	document.faculty_page.d_index.value = "0";

}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector, java.util.Date" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strCourseIndex = request.getParameter("course_index");
	String strMajorIndex  = request.getParameter("major_index");

	Vector vFacultyInfo    = null;
	String strFacultyName  = null;
	String strCommonSubMsg = null;

	//this is necessary for different types of subject offering.
	//degree_type=0->UG,1->Doctoral,2->medicine,3->with prep proper, 4-> care giver.
	//for care giver,doctoral, do not show year level, for prep_prop, show prep/prop status.
	String strDegreeType = null;

	Vector vTemp = null;

	int j = -1 ;

	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-LOADING"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-load schedule","enrollment_faculty_load_sched.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
/**
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","FACULTY",request.getRemoteAddr(),
														"enrollment_faculty_load_sched.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
**/

//end of authenticaion code.
if(WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("course_index").compareTo("selany") != 0)
	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",WI.fillTextValue("course_index"),"DEGREE_TYPE", " and is_valid=1 and is_del=0");


strErrMsg = null; //if there is any message set -- show at the bottom of the page.
FacultyManagement FM = new FacultyManagement();
if(request.getParameter("addFacultyLoad") != null && request.getParameter("addFacultyLoad").compareTo("1") ==0)
{
	if(!FM.saveFacultyLoad(dbOP,request))
		strErrMsg = FM.getErrMsg();
	else
	 	strErrMsg = "Faculty load added successfully.";
}
else if(WI.fillTextValue("delFacLoad").compareTo("1") ==0)
{
	//delete the load here.
	if(!FM.delFacLoad(dbOP,(String)request.getSession(false).getAttribute("login_log_index"),request.getParameter("info_index")))
		strErrMsg = FM.getErrMsg();
	else
	 	strErrMsg = "Faculty load deleted successfully.";
}

if(strErrMsg == null) strErrMsg = "";

double[] aDouble = {0d, 0d, 0d};

String strUCLoadHour = null;
if(WI.fillTextValue("subject").length() > 0) {
	aDouble = FM.getSubLoadHour(dbOP, WI.fillTextValue("subject"), true);
	//get uc load hour.. 
	strUCLoadHour = "select faculty_load_hr from subject where sub_index = "+WI.fillTextValue("subject");
	strUCLoadHour = dbOP.getResultOfAQuery(strUCLoadHour, 0);	
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>

<form name="faculty_page" action="./enrollment_faculty_load_sched.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          FACULTY PAGE - LOADING/SCHEDULING ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
		<td>&nbsp;</td>
      <td colspan="2"><strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td valign="bottom">College
        <select name="c_index" onChange="RemoveShowList();">
          <option value="-1">Select a college</option>
          <%
/*if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(5);
else
*/
	strErrMsg = null;
	strTemp = WI.fillTextValue("c_index");
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%>
        </select></td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="47%" valign="bottom">Course
<select name="course_index" onChange="RemoveShowList();">
          <option value="0">Select Any</option>
          <%
strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and c_index ="+request.getParameter("c_index");
%>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, strCourseIndex, false)%>
        </select></td>
      <td width="51%" valign="bottom">Major
        <select name="major_index" onChange="RemoveShowList();">
          <option></option>
          <%
if(strCourseIndex != null && strCourseIndex.compareTo("0") != 0)
{
strTemp = " from major where is_del=0 and course_index="+strCourseIndex+" order by major_name asc" ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, strMajorIndex, false)%>
          <%}%>
        </select></td>
    </tr>

    <tr>
      <td  colspan="3" height="15"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom">Subject offerings for school year :
<%
strTemp = WI.fillTextValue("school_year_fr");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
       <input name="school_year_fr" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("faculty_page","school_year_fr","school_year_to")'>
        to
<%
strTemp = WI.fillTextValue("school_year_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>        <input name="school_year_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
		&nbsp;&nbsp;&nbsp;		&nbsp;&nbsp;&nbsp;		&nbsp;&nbsp;&nbsp; <input type="image" src="../../../images/refresh.gif">
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="bottom">
        <%if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0){%>
        Subject offerings for year level :
        <%}%>
      </td>
      <td valign="bottom">Subject offerings for term &nbsp; </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">
        <%if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0){%>
        <select name="year" onChange="ReloadPage();">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("year");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("2") ==0)
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
          <%}%>
        </select>
        <%}//only if degree type is not care giver type.%>
      </td>
      <td height="25"> 
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
%>
	  <select name="semester" onChange="ReloadPage();">
		<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select>
      </td>
    </tr>
<%
if(strDegreeType != null && strDegreeType.compareTo("3") ==0){%>
	<tr>
      <td height="6">&nbsp;</td>
      <td height="25" colspan="2" >Select Preparatory/Proper :
<select name="prep_prop_stat" onChange="ReloadPage();">
<option value="1">Preparatory</option>
<%
strTemp = WI.fillTextValue("prep_prop_stat");
if(strTemp.compareTo("2") ==0){%>
	<option value="2" selected>Proper</option>
<%}else{%>
	<option value="2">Proper</option>
<%}%>
</select>

	</td>
      <td valign="bottom">&nbsp;</td>
    </tr>
<%}//only if strDegree type is 3
%>
    <tr>
      <td colspan="3" height="25"><hr size="1"></td>
    </tr>
</table>
<%
//get subject list.
strErrMsg = null;

vTemp = FM.getSubList(dbOP, request);//System.out.println(vTemp);
if(vTemp == null)
{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;&nbsp; <%=FM.getErrMsg()%></td>
	</tr>
 </table>
<%}
else if(vTemp != null && WI.fillTextValue("completeRefresh").length() == 0){//display subject list here.
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><strong>List of subjects offered :</strong><font size="1">
        (subjects shown are the subjects offered by/belong to the college of the
        person logged in)</font>
<%if(strSchCode.startsWith("DBTC")) {%>		
		<input type="text" name="scroll_course" size="16" style="font-size:12px"
		  onKeyUp="AutoScrollList('faculty_page.scroll_course','faculty_page.subject',true);"
		   onBlur="ReloadSubject(1)" class="textbox">
<%}%>
		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"> <select name="subject" onChange="ReloadPage();">
          <option value="0">Select a subject</option>
          <%
strTemp = WI.fillTextValue("subject");
for(int i = 0; i< vTemp.size(); ++i){
	if(strTemp.compareTo((String)vTemp.elementAt(i)) ==0){
	%>
          <option value="<%=(String)vTemp.elementAt(i)%>" selected><%=(String)vTemp.elementAt(i+2)%> ::: <%=(String)vTemp.elementAt(i+1)%></option>
          <%}else{%>
          <option value="<%=(String)vTemp.elementAt(i)%>"><%=(String)vTemp.elementAt(i+2)%> ::: <%=(String)vTemp.elementAt(i+1)%></option>
          <%}
i = i+2;
}%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><strong>Select college/office name if assigning load to
        faculty from another office:</strong> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"> <strong>COLLEGE :</strong>
        <select name="c_c_index" onChange="ChangeCollege();">
	<option value="0">ALL</option>
<% 	if (request.getParameter("c_index")== null)
		strTemp = request.getParameter("c_index");
	else
		strTemp = request.getParameter("c_c_index");
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%>
        </select>
        <strong>OFFICE : </strong> <select name="d_index" onChange="ChangeDepartment();">
          <option value="0">ALL</option>
          <% 	strTemp = request.getParameter("d_index"); %>
          <%=dbOP.loadCombo("D_INDEX","D_NAME"," from DEPARTMENT where is_del = 0 and (c_index=0 or c_index is null) order by d_name asc", strTemp,false)%> </select>
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><div align="center">
          <input type="image" src="../../../images/show_list.gif" onClick="ShowList();">
          <font size="1">click to show list of subjects offered with the specifications</font></div></td>
    </tr>
  </table>
<%}//end of display if subject list exist.
Vector vGSSecurity = null;int iAccessLevelPrev = iAccessLevel;
strErrMsg = null;
if(request.getParameter("showList") != null && request.getParameter("showList").compareTo("1") ==0)
{
	vTemp = FM.getSubjectSectionList(dbOP,request);//System.out.println(FM.getErrMsg());
	if(vTemp == null)
		strErrMsg = FM.getErrMsg();
	if(vTemp != null && vTemp.size() > 0)
	{
%>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="9"><div align="center">LIST OF SECTIONS FOR SUBJECT
          <strong><%=request.getParameter("subject_name")%> </strong>OFFERED BY <strong><%=request.getParameter("college_name")%></strong>
          FOR <strong><%=request.getParameter("course_name")%></strong></div></td>
    </tr>
    <tr>
      <td width="14%" height="25"><div align="center"><font size="1">SECTION</font></div></td>
      <td width="20%"><div align="center"><font size="1">SCHEDULE (Days/Time)</font></div></td>
      <td width="8%"><div align="center"><font size="1">ROOM #</font></div></td>
      <td width="8%"><div align="center"><font size="1">(LEC/LAB)</font></div></td>
      <td width="9%"><div align="center"><font size="1">TOTAL UNITS</font></div></td>
      <td width="9%" align="center" style="font-size:9px;">LOAD HOUR </td>
      <td width="22%"><div align="center"><font size="1">INSTRUCTOR</font></div></td>
      <td width="11%" height="25"><div align="center"><font size="1">ASSIGN INSTR.</font></div></td>
	  <td width="8%">&nbsp;</td>
    </tr>
 <%
j=0;

 for(int i = 0; i< vTemp.size(); ++i,++j){
 //This is time I get faculty loading information and common subject informatin. If it is a common subject with child offering, do not allow to offer if it is not offered.
 //if it is offered, then show the faculty name.
 vFacultyInfo = FM.checkIfCommonSubjectAndOffered( dbOP,(String)vTemp.elementAt(i),1);//System.out.println(vFacultyInfo);
 //vFacultyInfo.setElementAt("0",0);
 if(vFacultyInfo != null)
 {
 	if(((String)vFacultyInfo.elementAt(0)).compareTo("0") ==0)//not common subject and open for schedule,
	{
		strFacultyName  = "";
		strCommonSubMsg = "";
	}
	else if(((String)vFacultyInfo.elementAt(0)).compareTo("1") ==0)//not common subject and having schedule
	{
		strFacultyName  = (String)vFacultyInfo.elementAt(1);
		strCommonSubMsg = "";
	}
	else if(((String)vFacultyInfo.elementAt(0)).compareTo("2") ==0)//Common subject and not having schedule,
	{
		strFacultyName  = "";
		strCommonSubMsg = "Not authorized to load faculty(common offering).";
	}
	else if(((String)vFacultyInfo.elementAt(0)).compareTo("3") ==0)//common subject and having schedule
	{
		strFacultyName  = (String)vFacultyInfo.elementAt(1);
		strCommonSubMsg = "Not authorized to delete load(common offering).";
	}//System.out.println(strCommonSubMsg);
 }
 else
 {%>
	 <tr>
	 <td colspan="9"><%=FM.getErrMsg()%></td>
	 </tr>
 <%
 break;
 }

//I have to find gs security here, if subject is having final grade, do not allow to assign anymore.
vGSSecurity = FM.getGSSecurity(dbOP, (String)vTemp.elementAt(i), (String)request.getSession(false).getAttribute("userId"));
if(vGSSecurity != null)
	iAccessLevel = 0;
else
	iAccessLevel = iAccessLevelPrev;

 %>

    <tr>
      <td height="33"><%=(String)vTemp.elementAt(i+1)%></td>
      <td height="33"><%=WI.getStrValue((String)vTemp.elementAt(i+3),"&nbsp;")%></td>
      <td height="33"><%=WI.getStrValue(vTemp.elementAt(i+2),"&nbsp;")%></td>
      <td height="33"><%=WI.getStrValue(vTemp.elementAt(i+4),"&nbsp;")%></td>
      <td><%=(String)vTemp.elementAt(i+5)+"("+(String)vTemp.elementAt(i+7)+")"%></td>
<%
if(vFacultyInfo.size() == 3) {
	strTemp = (String)vFacultyInfo.elementAt(2);
	//System.out.println(" Faculty load from Fac load table.. "+strTemp);
}
else {
	//I have to get here load hour .. I have to findout if it is lec/lab subject.
	if(aDouble[2] == 0d)//lec
		strTemp = Double.toString(aDouble[0]);
	else if(aDouble[2] == 1d) //Lab only.
		strTemp = Double.toString(aDouble[1]);
	else {//either lec or lab)
		if(WI.getStrValue(vTemp.elementAt(i+4),"&nbsp;").equals("LAB"))
			strTemp = Double.toString(aDouble[1]);
		else
			strTemp = Double.toString(aDouble[0]);//LEC.
	}
	if(strSchCode.startsWith("EAC") && vTemp.elementAt(i + 8) != null) {
		strTemp = (String)vTemp.elementAt(i + 8);
	}
	if(strUCLoadHour != null)
		strTemp = strUCLoadHour;
}

if(strTemp == null)
	strTemp = "";
%>
      <td><input type="text" value="<%=strTemp%>" name="load_hour_<%=j%>" size="5"></td>
      <td height="33">
	  <%if(WI.getStrValue(strFacultyName).length() > 0){%>
	  <%=WI.getStrValue(strFacultyName)%>
	  <input type="hidden" name="name<%=j%>" value="<%=WI.getStrValue(strFacultyName)%>">
	  <%}else{%>
	  <input name="name<%=j%>" type="text" size="23" readonly="yes" value="<%=WI.getStrValue(strFacultyName)%>" class="textbox_noborder"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  style="font-size:10px">
	  <%}%>
	  <input type="hidden" name="user_index<%=j%>">
	  <input name="s_s_index<%=j%>" value="<%=(String)vTemp.elementAt(i)%>" type="hidden">
	  <input name="unit<%=j%>" value="<%=(String)vTemp.elementAt(i+5)%>" type="hidden">
	  <input type="hidden" name="unit_type<%=j%>" value="<%=(String)vTemp.elementAt(i+7)%>">	  </td>
      <td height="33"><div align="center">&nbsp;
	  <%
	  if( WI.getStrValue(vTemp.elementAt(i+6)).length() == 0 || ((String)vTemp.elementAt(i+6)).compareTo("0") ==0){
	  	if(iAccessLevel > 1){%>
			<%=strCommonSubMsg%>
			<%if(strFacultyName.length() == 0 && strCommonSubMsg.length() ==0){%>
	  			<a href='javascript:AssignFaculty("<%=(String)vTemp.elementAt(i)%>","<%=(String)vTemp.elementAt(i+3)%>","<%=WI.getStrValue((String)vTemp.elementAt(i+2))%>",
						"<%=(String)vTemp.elementAt(i+4)%>","<%=(String)vTemp.elementAt(i+5)+"("+(String)vTemp.elementAt(i+7)+")"%>","<%=j%>","0");'><img src="../../../images/assign.gif" width="41" height="18" border="0"></a>
	  	<%}//checking for common subject message and if faculty is not assigned in the common subject offering.
		}else{%> Not authorized
	  <%}
	  }else if(iAccessLevel > 1){%>
          <a href='javascript:AssignFaculty("<%=(String)vTemp.elementAt(i)%>","<%=(String)vTemp.elementAt(i+3)%>","<%=WI.getStrValue((String)vTemp.elementAt(i+2))%>",
						"<%=(String)vTemp.elementAt(i+4)%>","<%=(String)vTemp.elementAt(i+5)+"("+(String)vTemp.elementAt(i+7)+")"%>","<%=j%>","1");'><img src="../../../images/multiple_assign.gif" width="41" height="18" border="0"></a>
          <%}%>
	  </div></td>
	  <td valign="middle">
	  <%
	  if(WI.getStrValue(vTemp.elementAt(i+6)).length()>0 && WI.getStrValue(vTemp.elementAt(i+6)).compareTo("0") != 0){
	  	if(iAccessLevel ==2){%>
		<%=strCommonSubMsg%>
		 <%if(strFacultyName.length() > 0 && strCommonSubMsg.length() ==0){%>
	  		<a href='javascript:DelFacLoad("<%=(String)vTemp.elementAt(i+6)%>");'%><img src="../../../images/delete.gif" border="0"></a>
	  <%}//only if the subject is not offered as child offering.
	  }else{%>Not authorized<%}%></td>
    <%}else{%>
	&nbsp;
	<%}%>
	</tr>
<%i = i+8;}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr >
      <td height="25"><div align="center"><input type="image" src="../../../images/save.gif" onClick="AddFacultyLoad();"><font size="1">click
          to save entries</font></div></td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
	}//if getSubjectSectionList(DBOperation dbOP,HttpServletRequest req) is having section list.

} // only if show list is shown.
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="2">&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" >&nbsp;</td>
    </tr>
  </table>

<input name="showList" type="hidden" value="<%=WI.fillTextValue("showList")%>">
<input name="completeRefresh" type="hidden">
<input name="college_name" value="<%=WI.fillTextValue("college_name")%>" type="hidden">
<input name="course_name" value="<%=WI.fillTextValue("course_name")%>" type="hidden">
<input name="subject_name" value="<%=WI.fillTextValue("subject_name")%>" type="hidden">
<input type="hidden" name="total_section" value="<%=j%>">
<input type="hidden" name="addFacultyLoad" value="0">
<input type="hidden" name="delFacLoad">
<input type="hidden" name="info_index">
<input type="hidden" name="degreeType" value="<%=WI.getStrValue(strDegreeType)%>">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
