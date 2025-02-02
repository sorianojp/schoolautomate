<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function AddRecord(addRecNo)
{
	document.rscheduling.addRecord.value = "1";
	document.rscheduling.deleteRecord.value = "0";
	document.rscheduling.addRecordNo.value = addRecNo;
	document.rscheduling.section_name.value = document.rscheduling.section[document.rscheduling.section.selectedIndex].text;
	
	eval('document.rscheduling.hide_save'+addRecNo+'.src = \"../../../images/blank.gif\"');
	document.rscheduling.submit();
}
function DeleteRecord(strInfoIndex)
{
	document.rscheduling.deleteRecord.value = "1";
	document.rscheduling.info_index.value = strInfoIndex;

	if(document.rscheduling.section.selectedIndex >0)
	document.rscheduling.section_name.value = document.rscheduling.section[document.rscheduling.section.selectedIndex].text;

	ReloadPage();
}

function ReloadCourseIndex()
{
	var strDegreeType = document.rscheduling.degreeType.value;
	document.rscheduling.showsubject.value = 0;
	//course index is changed -- so reset all dynamic fields.
	if(document.rscheduling.sy_from.selectedIndex > -1)
		document.rscheduling.sy_from[document.rscheduling.sy_from.selectedIndex].value = "";
	if(document.rscheduling.major_index.selectedIndex > -1)
		document.rscheduling.major_index[document.rscheduling.major_index.selectedIndex].value = "";
if(strDegreeType.length > 0 && strDegreeType != "1" && strDegreeType != "4")
{
	if(document.rscheduling.year.selectedIndex > -1)
		document.rscheduling.year[document.rscheduling.year.selectedIndex].value = "";
	if(document.rscheduling.semester.selectedIndex > -1)
		document.rscheduling.semester[document.rscheduling.semester.selectedIndex].value = "";
}

	ReloadPage();
}
function ShowSubject()
{
	document.rscheduling.showsubject.value = 1;
	ReloadPage();
}
function changeResOfferingType()
{
	document.rscheduling.showsubject.value = "";
	document.rscheduling.offer.value="";

	ReloadPage();
}

function ReloadPage()
{
	document.rscheduling.addRecord.value = 0;
	document.rscheduling.submit();
}

function ReloadTimeSchedule()
{
	document.rscheduling.reloadTimeSchedule.value="1";
	document.rscheduling.section_name.value = document.rscheduling.section[document.rscheduling.section.selectedIndex].text;
	ReloadPage();
}

function SubjectOffered()
{
	var i = document.rscheduling.subject_offered.selectedIndex; //alert(i);
	if( i < 1)//reset values.
	{
		document.rscheduling.subject_category.value= "";
		document.rscheduling.cur_index.value= "";
	}
	else
	{
		document.rscheduling.subject_category.value= eval('document.rscheduling.subject_category'+(i-1)+'.value');
		document.rscheduling.cur_index.value= eval('document.rscheduling.cur_index'+(i-1)+'.value');
	}
}
//call this to reload the page if necessary
function ReloadIfNecessary()
{
	if(document.rscheduling.showsubject.value == 1)
	{
		ReloadPage();
	}
}

function ShowWeeklySchedule()
{
	document.rscheduling.showweeklyschedule.value = 1;
	ReloadPage();
}
function ChangeSubCode()
{
	document.rscheduling.changeSubCode.value = "1";
	ReloadPage();
}
function Offer()
{
	document.rscheduling.offer.value="1";
	document.rscheduling.addRecord.value = 0;
}


</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.SubjectSection,enrollment.EnrollmentRoomMonitor,java.util.Vector, java.util.Date" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	Vector vTemp = null;
	int i = -1;
	int j=0;
	String strSYTo = null; // this is used in
	String strCurIndex = "0";
	String strSubType = "";
	String strSubCatg = "";
	String strLECLAB = "";
	String[] strConvertLECLAB={"LEC","LAB",""};

	//this is necessary for different types of subject offering.
	//degree_type=0->UG,1->Doctoral,2->medicine,3->with prep proper, 4-> care giver.
	//for care giver,doctoral, do not show year level, for prep_prop, show prep/prop status.
	String strDegreeType = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-ROOMS MONITORING-room scheduling","room_scheduling.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","ROOMS MONITORING",request.getRemoteAddr(),
														"room_scheduling.jsp");
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

//end of authenticaion code.

strErrMsg = null; //if there is any message set -- show at the bottom of the page.
SubjectSection SS = new SubjectSection();
EnrollmentRoomMonitor ERM = new EnrollmentRoomMonitor();

strTemp = WI.fillTextValue("addRecord");
if(strTemp.compareTo("1") == 0)
{
	//add record here.
	if(ERM.addRoomAssignment(dbOP,request))
		strErrMsg = "Room assigned successfully.";
	else
		strErrMsg = "Room could not be assigned. Error description : "+ERM.getErrMsg();
}
else if(WI.fillTextValue("deleteRecord").compareTo("1") ==0)
{
	if(ERM.delRoomAssignment(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
	{
		strErrMsg = "Room assignment removed successfully.";
	}
	else
	{
		strErrMsg = "Room assignment could not be removed. Error description : "+ERM.getErrMsg();
	}
}
else if(WI.fillTextValue("offer").compareTo("1") ==0)//This will hardly happen because for common subject offering I am offering the room to all child offeerings.
{
/**	if(ERM.copyCommonSecRoom(dbOP,request))
		strErrMsg = "Room assigned successfully.";
	else
		strErrMsg = "Room could not be assigned. Error description : "+ERM.getErrMsg();
**/
strErrMsg = "Error in offering the room. Room should be offered by the college/department offered this subject.";
}

if(WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("course_index").compareTo("selany") != 0)
	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",WI.fillTextValue("course_index"),"DEGREE_TYPE", " and is_valid=1 and is_del=0");
if(WI.fillTextValue("res_offering").compareTo("1") ==0)
	strDegreeType = "100";

if(strErrMsg == null) strErrMsg = "";
%>

<form name="rscheduling" action="./room_scheduling.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          ROOM ASSIGNMENT/SCHEDULING PAGE ::::</strong></font></div></td>
    </tr>
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"> <font size="3" color="green"><b><%=strErrMsg%></b>
      </td>
    </tr>
    <tr>
      <td height="4">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom" >Check if the subject is having
        Reserve/Additional subject offering &nbsp;&nbsp;
		<%if(WI.fillTextValue("res_offering").compareTo("1") ==0)
			strTemp = "checked";
		else
			strTemp = "";
		%>
		<input type="checkbox" name="res_offering" <%=strTemp%> value="1" onClick="changeResOfferingType();"></td>
      <td valign="bottom">&nbsp;</td>
    </tr>
<%
if(WI.fillTextValue("res_offering").compareTo("1") !=0){%>
    <tr>
      <td width="1%" height="0">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom" >Course offered</td>
      <td width="34%" valign="bottom">Curriculum Year </td>
    </tr>
    <tr>
      <td width="1%" height="0">&nbsp;</td>
      <td colspan="2"><select name="course_index" onChange="ReloadCourseIndex();">
          <option value="0">Select Any</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND IS_VALID=1 and is_offered = 1 order by course_name asc", request.getParameter("course_index"), false)%>
        </select></td>
      <td><select name="sy_from" onChange="ReloadPage();">
          <%
//get here school year
vTemp = SS.getSchYear(dbOP, request);
strTemp = request.getParameter("sy_from");//System.out.println(strTemp);
if(strTemp == null) strTemp = "";

for(i = 0, j=0 ; i< vTemp.size();)
{
	if(	((String)vTemp.elementAt(i)).compareTo(strTemp) == 0)
	{%>
          <option value="<%=(String)vTemp.elementAt(i)%>" selected><%=(String)vTemp.elementAt(i)%></option>
          <%	j = i;
	}
	else{
	%>
          <option value="<%=(String)vTemp.elementAt(i)%>"><%=(String)vTemp.elementAt(i)%></option>
          <%	}
	i = i+2;

}
if(vTemp.size() > 0)
	strSYTo = (String)vTemp.elementAt(j+1);
else
	strSYTo = "";

%>
        </select>
        to <b><%=strSYTo%></b> <input type="hidden" name="sy_to" value="<%=strSYTo%>"></td>
    </tr>
    <tr>
      <td width="1%" height="0">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom">Major</td>
      <td valign="bottom">
        <%if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0){%>
        Year and Term
        <%}%>
      </td>
    </tr>
    <tr>
      <td width="1%" height="0">&nbsp;</td>
      <td colspan="2"> <select name="major_index" onChange="ReloadPage();">
          <option></option>
          <%
strTemp = request.getParameter("course_index");
if(strTemp != null && strTemp.compareTo("0") != 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp+" order by major_name asc" ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%>
          <%}%>
        </select> </td>
      <td width="34%">
        <%if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0){%>
        <select name="year" onChange="ReloadIfNecessary();">
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
        </select> <select name="semester" onChange="ReloadIfNecessary();">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("semester");
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
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select>
        <%}//only if degree type is not care giver type.%>
      </td>
    </tr>
<%}//do not show if res_offering type is checked %>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="2" height="25">School Offering Year/Term:
        <%
strTemp = WI.fillTextValue("offering_yr_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="offering_yr_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("rscheduling","offering_yr_from","offering_yr_to")'>
        to
        <%
strTemp = WI.fillTextValue("offering_yr_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="offering_yr_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp;&nbsp;&nbsp; <select name="offering_sem">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("offering_sem");
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
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
      <td>&nbsp;</td>
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
        </select> </td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <%}//only if strDegree type is 3
%>
  </table>
<%
//if it is having school year - display resulet - else do not display anything below this
if(WI.fillTextValue("res_offering").compareTo("1") == 0 || vTemp.size() > 0)
{%>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

		  <tr>
		  <td width="2%">&nbsp;</td>
		  <td width="98%">&nbsp;</td>
		  </tr>
		  <tr>
		  <td width="2%">&nbsp;</td>
			  <td><input type="submit" name="showsub" value="Show Subjects" onClick="ShowSubject();">
        <input type="text" name="scroll_sub" class="textbox"
	     onKeyUp="AutoScrollListSubject('scroll_sub','subject_offered',true,'rscheduling');">
        <font size="1">(enter subject code to scroll subject)</font> </td>
		  </tr>
		  <tr>
		  <td colspan="2"><hr size="1"></td>
		  </tr>
		  </table>
<%
//show error message if show subject is clicked without entering school offering year.
if(request.getParameter("showsubject") != null && request.getParameter("showsubject").compareTo("1") ==0 &&
   (request.getParameter("offering_yr_from") == null || request.getParameter("offering_yr_from").trim().length() ==0 ||
    request.getParameter("offering_yr_to") == null || request.getParameter("offering_yr_to").trim().length() ==0 ||
	request.getParameter("offering_sem") == null || request.getParameter("offering_sem").trim().length() ==0) )
{%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

		  <tr>
		  <td width="2%">&nbsp;</td>

      <td width="98%"><strong>Please enter School offering year/sem</strong></td>
		  </tr>
</table>

<%}else

//System.out.println(request.getParameter("showsubject"));
if(request.getParameter("showsubject") != null && request.getParameter("showsubject").compareTo("1") ==0)
{
	//here get detail of the subject offered , and the course index.
	vTemp = SS.getSubjectOffered(dbOP,request,strSYTo);
	if(vTemp.size() == 0)
	{
		if(SS.getErrMsg() == null)
			strTemp = "No curriculum found. Please create curriculum before assiging section.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<b><%=strTemp%></b></font></p>
		<%
	}
	else
	{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%" height="25" rowspan="2">&nbsp;</td>
      <td colspan="2">Subject(code) Offered </td>
      <td width="18%">Section</td>
      <td width="15%">Subj Offering</td>
      <td width="12%" align="center">LEC/LAB</td>
      <td width="27%">Subj Category</td>
    </tr>
    <tr>
      <td colspan="2"><select name="subject_offered" onChange="ChangeSubCode();">
          <option value="0">Select Any</option>
          <%
		strTemp = request.getParameter("subject_offered");
		if(strTemp == null || strTemp.compareTo("0") == 0)
			strTemp = "";
		int iIndex = 0;
		for(i = 0; i< vTemp.size(); )
		{
			dbOP.constructAutoScrollHiddenField((String)vTemp.elementAt(i+2), iIndex++);
			if( ((String)vTemp.elementAt(i+1)).compareTo(strTemp) == 0)
			{
			strCurIndex = (String)vTemp.elementAt(i);
			strSubCatg = (String)vTemp.elementAt(i+3);
			%>
          <option value="<%=(String)vTemp.elementAt(i+1)%>" selected><%=(String)vTemp.elementAt(i+2)%></option>
          <%
			}else{%>
          <option value="<%=(String)vTemp.elementAt(i+1)%>"><%=(String)vTemp.elementAt(i+2)%></option>
          <%	}
		i = i+5;
		}dbOP.constructAutoScrollHiddenField(null, iIndex);%>
        </select></td>
      <td width="18%"><select name="section" onChange="ReloadTimeSchedule();">
          <option value="0">Select Any</option>
<%
if(WI.fillTextValue("subject_offered").length() > 0 && WI.fillTextValue("subject_offered").compareTo("0") != 0){
String strMajorIndex = WI.fillTextValue("major_index");
if(strMajorIndex.length() > 0)
	strMajorIndex = " and major_index="+strMajorIndex;
else
	strMajorIndex = "";
if(strDegreeType.compareTo("100") ==0)//reserve type.
{
	strTemp = " from E_SUB_SECTION where IS_DEL=0 AND IS_VALID=1 and OFFERING_SY_FROM="+request.getParameter("offering_yr_from")+
			" and OFFERING_SY_TO="+request.getParameter("offering_yr_to")+" and offering_sem="+request.getParameter("offering_sem")+
			" and CUR_INDEX=0 and sub_index="+request.getParameter("subject_offered")+" and degree_type=100 order by section asc ";
}
else if(strDegreeType.compareTo("1") ==0)
{
	strTemp = " from E_SUB_SECTION where IS_DEL=0 AND IS_VALID=1 and OFFERING_SY_FROM="+request.getParameter("offering_yr_from")+
			" and OFFERING_SY_TO="+request.getParameter("offering_yr_to")+" and offering_sem="+request.getParameter("offering_sem")+
			" and CUR_INDEX=0 and degree_type=1 and sub_index="+request.getParameter("subject_offered")+" order by section asc ";
}
else if(strDegreeType.compareTo("2") ==0)//medicine.
{
	strTemp = 	" from E_SUB_SECTION join cculum_medicine on (E_SUB_SECTION.cur_index=cculum_medicine.cur_index) "+
				" join course_offered on (cculum_medicine.course_index=course_offered.course_index) "+
				"where cculum_medicine.course_index="+request.getParameter("course_index")+strMajorIndex+" and E_SUB_SECTION.IS_DEL=0 AND E_SUB_SECTION.IS_VALID=1 and OFFERING_SY_FROM="+
				request.getParameter("offering_yr_from")+
				" and OFFERING_SY_TO="+request.getParameter("offering_yr_to")+" and offering_sem="+request.getParameter("offering_sem")+
				//" and CUR_INDEX="+strCurIndex+ //-I have to make the subjects available to all the curriculum year.
				" AND E_SUB_SECTION.SUB_INDEX="+request.getParameter("subject_offered")+" order by section asc ";
}
else
{
	strTemp = 	" from E_SUB_SECTION join curriculum on (E_SUB_SECTION.cur_index=curriculum.cur_index) "+
				" join course_offered on (curriculum.course_index=course_offered.course_index) "+
				"where curriculum.course_index="+request.getParameter("course_index")+strMajorIndex+" and E_SUB_SECTION.IS_DEL=0 AND E_SUB_SECTION.IS_VALID=1 and OFFERING_SY_FROM="+
				request.getParameter("offering_yr_from")+
				" and OFFERING_SY_TO="+request.getParameter("offering_yr_to")+" and offering_sem="+request.getParameter("offering_sem")+
				//" and CUR_INDEX="+strCurIndex+ //-I have to make the subjects available to all the curriculum year.
				" AND E_SUB_SECTION.SUB_INDEX="+request.getParameter("subject_offered")+" order by section asc ";
}
%>
          <%=dbOP.loadCombo("SUB_SEC_INDEX","SECTION",strTemp, request.getParameter("section"), false)%>
<%}%>        </select></td>
      <%
	strTemp = request.getParameter("section");
	if(request.getParameter("changeSubCode") != null && request.getParameter("changeSubCode").compareTo("1") ==0) //reset when sub is changed
		strTemp = "0";

	if( strTemp == null || strTemp.compareTo("0") == 0)
	{	strTemp = "";strLECLAB="";}
	else if(WI.fillTextValue("res_offering").compareTo("1") != 0 && (strCurIndex == null || strCurIndex.compareTo("0") ==0) )
	{	strTemp = "";strLECLAB="";}
	else
	{
		strLECLAB = dbOP.mapOneToOther("E_SUB_SECTION", "SUB_SEC_INDEX", strTemp, "IS_LEC",null );
		strTemp = dbOP.mapOneToOther("E_SUB_SECTION", "SUB_SEC_INDEX", strTemp, "SUB_OFFER_TYPE",null );
	}
	if(strLECLAB == null || strLECLAB.length() ==0)
		strLECLAB="2";
%>
      <td width="15%"><b><%=strTemp%></b></td>
      <td width="12%" align="center"><strong><%=strConvertLECLAB[Integer.parseInt(strLECLAB)]%></strong></td>
      <td width="27%"><b><%=strSubCatg%></b></td>
    </tr>
  </table>
  <%
  strErrMsg = null;
//check if the user logging in allowed to assign or delete the room assignment.
if(WI.fillTextValue("section").length() > 0 && WI.fillTextValue("section").compareTo("0") != 0)
	if(!ERM.checkIfUserAllowedForRoomAssignment(dbOP,request.getParameter("section"),null,(String)request.getSession(false).getAttribute("login_log_index"),null,null))
		strErrMsg = ERM.getErrMsg();


Vector vIsCommonSection = SS.checkIfCommonSection(dbOP,request.getParameter("subject_offered"),request.getParameter("section_name"),
	        request.getParameter("offering_yr_from"),request.getParameter("offering_yr_to"),request.getParameter("offering_sem"),
			strLECLAB);
Vector vAssignedRoomSch = ERM.getAssignedRoomForSub(dbOP,request,request.getParameter("section"));

//if it is having a room rumber then display, -- It will never happen. I am forcing it to false.
if(false && vIsCommonSection != null && vIsCommonSection.size() > 0 && vIsCommonSection.elementAt(2) != null &&
	((String)vIsCommonSection.elementAt(2)).trim().length() > 0 && (vAssignedRoomSch == null || vAssignedRoomSch.size() ==0)){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2"><font size="1"><b>TIME SCHEDULE</b></font></td>
      <td width="22%"><font size="1"><strong>ROOM NUMBER</strong></font></td>
      <td width="42%"><font size="1"><strong>OFFER</strong></font></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2"><strong><%=(String)vIsCommonSection.elementAt(0)%></strong>
      </td>
      <td width="22%"><strong><%=WI.getStrValue(vIsCommonSection.elementAt(2),"Not assigned")%></strong>
        <input type="hidden" name="copyFromSection" value="<%=(String)vIsCommonSection.elementAt(1)%>" ></td>
      <td width="42%">
        <% if(iAccessLevel > 1){%>
        <input type="image" onClick="Offer();" src="../../../images/offer.gif">
        click to offer
        <%}else{%>
        Not authorized
        <%}%>
      </td>
    </tr>
  </table>
<%}
	//load this only if the section is selected. it will give detail of the time schedule and the room can be alloacted.
	else if(strErrMsg == null && request.getParameter("reloadTimeSchedule") != null && request.getParameter("reloadTimeSchedule").compareTo("1") ==0
		&& request.getParameter("section") != null && request.getParameter("section").compareTo("0") != 0
		&& (request.getParameter("changeSubCode") == null || request.getParameter("changeSubCode").compareTo("1") !=0) )//if sub code change, remove the previous displayed schedule
		{
			//System.out.println(SS.getErrMsg());System.out.println(request.getParameter("subject_offered"));	System.out.println(request.getParameter("section_name"));
			vTemp = ERM.getSubSch2AssignRoom(dbOP,request,request.getParameter("section"));
			Vector vRoomAlloted = ERM.getRoomList2Assign(dbOP,request, strSubCatg);
			//this keeps filtered room ifnormation only if "show_only_available is 1"
			Vector vAllowedRoomAlloted = vRoomAlloted;
			if(vTemp == null || vRoomAlloted == null )
			{%>
			<b>Error description: <%=ERM.getErrMsg()%></b>
			<%}else{
			String[] strConvertYear = {"1st","2nd","3rd","4th","5th","6th","7th","8th","9th"};
			String[] strConvertWeek = {"Sun","Mon","Tue","Wed","Thurs","Fri","Sat"};
			String[] strConvertAMPM = {"AM","PM"};
			%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="3" align="center" ><strong>SUBJECT SCHEDULE</strong><br>
        <font size="1"> Note: room shown depends on the subject category and room 
        ownership (if set.), if you do not see a room , please go to room maintenance 
        to add this subject category</font></td>
    </tr>
    <tr> 
      <td height="25" align="center">
<%
strTemp = WI.fillTextValue("show_only_available");
if(strTemp.compareTo("1") ==0)
	strTemp = "checked";
else	
	strTemp = "";
%>	  <input type="checkbox" name="show_only_available" value="1" <%=strTemp%>>
	  
        Show only available Room </td>
      <td colspan="2"><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a> 
        <font size="1">Click to refresh the page.</font></td>
    </tr>
    <tr> 
      <td width="50%" height="25" align="center"><font size="1"><b>TIME SCHEDULE</b></font></td>
      <td width="30%" align="center"><font size="1"><b>ASSIGN ROOM</b></font></td>
      <td width="20%"><font size="1"><strong>SAVE</strong></font></td>
    </tr>
    <%
			for(int p = 0,q=0 ; p< vTemp.size(); ++p,++q)
			{%>
    <tr> 
      <td width="50%" height="25" align="center"> <%
	  //only if care giver, check the time schedule.
	  strTemp = null;
	  if(strDegreeType.compareTo("4") ==0)
	  {
	  		strTemp = WI.getStrValue(dbOP.mapOneToOther("E_SUB_SECTION", "SUB_SEC_INDEX", request.getParameter("section"),"offering_dur",null) );
	  }
	  %> <%=WI.getStrValue(strTemp)%> <%=strConvertWeek[Integer.parseInt((String)vTemp.elementAt(p+1))]%> - <%=(String)vTemp.elementAt(p+2)%>:<%=(String)vTemp.elementAt(p+3)%> <%=strConvertAMPM[Integer.parseInt((String)vTemp.elementAt(p+4))]%> to <%=(String)vTemp.elementAt(p+5)%>:<%=(String)vTemp.elementAt(p+6)%> <%=strConvertAMPM[Integer.parseInt((String)vTemp.elementAt(p+7))]%> <input type="hidden" name="room_assign<%=q%>" value="<%=(String)vTemp.elementAt(p)%>"> 
      </td>
      <td width="30%" align="center"> 
	  <%
	  if(WI.fillTextValue("show_only_available").compareTo("1") ==0)
		  	vAllowedRoomAlloted = ERM.showAvailableRoom(dbOP, vRoomAlloted,
                                  (String)vTemp.elementAt(p),
                                  WI.fillTextValue("offering_yr_from"),
                                  WI.fillTextValue("offering_yr_to"),
                                  WI.fillTextValue("offering_sem"),strDegreeType);
	  if(vAllowedRoomAlloted.size() == 0){%>
	  <%=ERM.getErrMsg()%>
	  <%}%>						  
		  <select name="room_i<%=q%>">
          <%
		  //filter room if show_only_available is checked. 		  
				strTemp = request.getParameter("room_i"+q);
				if(strTemp == null) strTemp = "";
				for(int r = 0; r< vAllowedRoomAlloted.size(); ++r)
				{
				if(strTemp.compareTo( (String)vAllowedRoomAlloted.elementAt(r)) ==0 )
				{%>
          <option value="<%=vAllowedRoomAlloted.elementAt(r++)%>" selected><%=vAllowedRoomAlloted.elementAt(r)%></option>
          <%}else{%>
          <option value="<%=vAllowedRoomAlloted.elementAt(r++)%>"><%=vAllowedRoomAlloted.elementAt(r)%></option>
          <%}}%>
        </select>
        <input type="text" name="scroll_room<%=q%>" class="textbox" size="6" style="font-size:9px"
	     onKeyUp = "AutoScrollList('rscheduling.scroll_room<%=q%>','rscheduling.room_i<%=q%>',true);"> 
      </td>
      <td width="20%"> <% if(iAccessLevel > 1){%> 
	  <a href='javascript:AddRecord("<%=q%>");'><img src="../../../images/assign.gif" border="0" name="hide_save<%=q%>"></a> 
        <%}else{%>
        Not authorized 
        <%}%> </td>
    </tr>
    <%
			p = p+7;}%>
  </table>

			<%
			//show here the room assigned
			if(vAssignedRoomSch != null && vAssignedRoomSch.size() >0)
			{%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td align="center" height="25" colspan="3"><strong>- LIST OF ROOMS ALLOTED
        TO THIS SUBJECT -</strong></td>
    </tr>
    <tr>
      <td width="50%" height="25" align="center"><font size="1"><b>TIME SCHEDULE</b></font></td>
      <td width="30%" align="center"><font size="1"><b>ASSIGNED ROOM</b></font></td>
      <td width="20%"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <%
				for(int x = 0 ; x< vAssignedRoomSch.size(); ++x)
				{%>
    <tr>
      <td height="25" align="center"> <%=strConvertWeek[Integer.parseInt((String)vAssignedRoomSch.elementAt(x+1))]%>
        - <%=(String)vAssignedRoomSch.elementAt(x+2)%>:<%=(String)vAssignedRoomSch.elementAt(x+3)%>
        <%=strConvertAMPM[Integer.parseInt((String)vAssignedRoomSch.elementAt(x+4))]%>
        to <%=(String)vAssignedRoomSch.elementAt(x+5)%>:<%=(String)vAssignedRoomSch.elementAt(x+6)%>
        <%=strConvertAMPM[Integer.parseInt((String)vAssignedRoomSch.elementAt(x+7))]%>
      </td>
      <td align="center"><%=(String)vAssignedRoomSch.elementAt(x+9)%></td>
      <td>
        <% if(iAccessLevel ==2 ){%>
        <a href='javascript:DeleteRecord("<%=(String)vAssignedRoomSch.elementAt(x)%>");'><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
        Not authorized
        <%}%>
      </td>
    </tr>
    <%
				x = x+9;}%>
  </table>

<%				}//end of displaying the assigned room schedule.


			}//else just on top of it
		}//this shows the timetable and room schedule -- addition goes here.
	}//shows the subject details or error mesage - after calling getSubjectOffered(..);
  } //End of show subject -- content below the Show Subjects button.
}//END OF SHOWING THE OPTIONS IF THERE IS SCHOOL YEAR
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9"><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
	<tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>

 <input type="hidden" name="addRecord" value="0">
 <input type="hidden" name="addRecordNo" value="-1">

<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="info_index" value="0">

<input type="hidden" name="reloadTimeSchedule" value="<%=request.getParameter("reloadTimeSchedule")%>">
<input type="hidden" name="showsubject" value="<%=request.getParameter("showsubject")%>">
<%
if(strCurIndex == null)
{
	strTemp = request.getParameter("cur_index");
	if(strTemp == null) strTemp = "";
}
else
	strTemp = strCurIndex;
%>
<input type="hidden" name="cur_index" value="<%=strTemp%>">
<input type="hidden" name="showweeklyschedule" value="<%=request.getParameter("showweeklyschedule")%>">
<input type="hidden" name="changeSubCode" value="0">
<input type="hidden" name="section_name">
<input type="hidden" name="offer">
<input type="hidden" name="degreeType" value="<%=WI.getStrValue(strDegreeType)%>">

<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>