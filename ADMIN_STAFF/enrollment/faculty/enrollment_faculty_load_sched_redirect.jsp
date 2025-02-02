<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsSWU = strSchCode.startsWith("SWU");
%>
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
	document.faculty_page.close_window.value = "1";
	document.faculty_page.delFacLoad.value="1";
	document.faculty_page.info_index.value=strIndex;
	document.faculty_page.submit();
}
function AddFacultyLoad()
{
	document.faculty_page.close_window.value = "1";
	document.faculty_page.addFacultyLoad.value = "1";
}
function ShowList()
{
	document.faculty_page.close_window.value = "1";
	document.faculty_page.showList.value="1";
}

function AssignFaculty(strSubSecIndex, strSchedule,strRoomNo, strLECLAB,strTotalUnit,
			strReference,strMultipleAssign)
{
	//open new widow.
	var loadPg = "./faculty_sched.jsp?form_name=faculty_page&sec_index="+strSubSecIndex+
				"&schedule="+escape(strSchedule)+
				"&room_no="+escape(strRoomNo)+
				"&LECLAB="+strLECLAB+
				"&total_unit="+strTotalUnit+
				"&subject="+escape(document.faculty_page.subject_name.value)+
				"&c_index="+document.faculty_page.c_c_index.value+
				"&sub_off_yrf="+document.faculty_page.school_year_fr.value+
				"&sub_off_yrt="+document.faculty_page.school_year_to.value+
				"&offering_sem="+document.faculty_page.semester.value+
				"&opner_fac_index=user_index"+strReference+
				"&opner_fac_name=name"+strReference+
				"&college_name="+document.faculty_page.college_name.value+
				"&multiple_assign="+strMultipleAssign+
				"&sub_index="+document.faculty_page.subject.value+
				"&d_index="+document.faculty_page.d_index.value;
	//var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=yes,location=yes,directories=yes,status=no,menubar=yes');
	var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadParentWindow(){
	if(document.faculty_page.close_window.value.length > 0)
		return;
		
	var strValue = document.faculty_page.faculty_name.value;
	if(strValue.length > 32)
		strValue = strValue.substring(0, 32);
	
	if(strValue.length == 0){
		<%if(!bolIsSWU){%>
		strValue = "______________";
		<%}else{%>strValue = "TBA";<%}%>
	}
	
	window.opener.LoadFacultyName(document.faculty_page.faculty_lbl_id.value, strValue); 
	
}

</script>
<body bgcolor="#D2AE72" onUnload="ReloadParentWindow();">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector, java.util.Date" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);



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


%>

<form name="faculty_page" action="./enrollment_faculty_load_sched_redirect.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          FACULTY PAGE - LOADING/SCHEDULING ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
		<td width="4%" height="25">&nbsp;</td>
      <td width="60%"><strong><%=strErrMsg%></strong></td>
      <td width="36%" rowspan="2"><input type="image" src="../../../images/refresh.gif" onClick="ShowList();"><font size="1">Click to refresh page</font></td>
    </tr>  
	
	<tr>
		<td width="4%" height="25">&nbsp;</td>
      <td width="60%">SUBJECT : <strong><%=WI.fillTextValue("subject_name")%></strong></td>
    </tr>  
</table>
<%

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

 for(int i = 0; i< vTemp.size(); i+=9,++j){
 	if(WI.fillTextValue("sub_sec_index").length() > 0){
		if(!((String)vTemp.elementAt(i)).equals(WI.fillTextValue("sub_sec_index")))
			continue;	
	}

 //System.out.println("vFacultyInfo "+(String)vTemp.elementAt(i));
 //This is time I get faculty loading information and common subject informatin. If it is a common subject with child offering, do not allow to offer if it is not offered.
 //if it is offered, then show the faculty name.
 vFacultyInfo = FM.checkIfCommonSubjectAndOffered( dbOP,(String)vTemp.elementAt(i),1);
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
<%}%>
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
<!--<input name="college_name" value="<%=WI.fillTextValue("college_name")%>" type="hidden">
<input name="course_name" value="<%=WI.fillTextValue("course_name")%>" type="hidden">
<input name="subject_name" value="<%=WI.fillTextValue("subject_name")%>" type="hidden">-->
<input type="hidden" name="total_section" value="<%=j%>">
<input type="hidden" name="addFacultyLoad">
<input type="hidden" name="delFacLoad">
<input type="hidden" name="info_index">
<input type="hidden" name="degreeType" value="<%=WI.getStrValue(strDegreeType)%>">



<input type="hidden" name="sub_sec_index" value="<%=WI.fillTextValue("sub_sec_index")%>" >
<input type="hidden" name="subject_name" value="<%=WI.fillTextValue("subject_name")%>" > <!---this is the sub code and sub_name-->
<input type="hidden" name="subject" value="<%=WI.fillTextValue("subject")%>" > <!-- this is the subject index -->

<input type="hidden" name="school_year_fr" value="<%=WI.fillTextValue("school_year_fr")%>" > <!-- this is the school_year_fr -->
<input type="hidden" name="school_year_to" value="<%=WI.fillTextValue("school_year_to")%>" > <!-- this is the school_year_to -->
<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>" > <!-- this is the semester -->

<input type="hidden" name="year" value="<%=WI.fillTextValue("year")%>" > <!-- this is theyear -->
<input type="hidden" name="course_index" value="<%=WI.fillTextValue("course_index")%>" > <!-- this is the course_index -->
<input type="hidden" name="major_index" value="" > <!-- this is the course_index -->
<input type="hidden" name="c_index" value="<%=WI.fillTextValue("c_c_index")%>" >

<input type="hidden" name="c_c_index" value="<%=WI.fillTextValue("c_c_index")%>" >
<input type="hidden" name="d_index" value="<%=WI.fillTextValue("d_index")%>" >
<input type="hidden" name="college_name" value="<%=WI.fillTextValue("college_name")%>" >

<input type="hidden" name="close_window" value="">
<input type="hidden" name="faculty_name" value="<%=strFacultyName%>" >
<input type="hidden" name="faculty_lbl_id" value="<%=WI.fillTextValue("faculty_lbl_id")%>" >
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
