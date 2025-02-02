<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
//call this to activate or de-activate internship description - activate only if nothing is selected.
function ChangeCourseIndex() {
	document.cmaintenance.change_course_index.value = 1;
	this.ReloadPage();
}
function copyCurYr(strCYFrom, strCYTo) {
	document.cmaintenance.sy_from.value = strCYFrom;
	document.cmaintenance.sy_to.value   = strCYTo;
	this.ReloadPage();	
}
function ActivateDeactivate()
{
	if(document.cmaintenance.internship_code.selectedIndex ==0)
		document.cmaintenance.internship_name.disabled = false;
	else
	{
		document.cmaintenance.internship_name.disabled = true;
		//document.cmaintenance.internship_name.focus();
	}
}

//call this if course type is changed from regular course to summer course or internship course
function ChangeCourseType()
{
	//if(document.cmaintenance.semester.selectedIndex > 4)
		ReloadPage();
}


//call this to view course curriculum in detail.
function ViewAll()
{
	var strCName = document.cmaintenance.course_index[document.cmaintenance.course_index.selectedIndex].text;
	var strCIndex = document.cmaintenance.course_index[document.cmaintenance.course_index.selectedIndex].value;

	var strMName = document.cmaintenance.major_index[document.cmaintenance.major_index.selectedIndex].text;
	var strMIndex = document.cmaintenance.major_index[document.cmaintenance.major_index.selectedIndex].value;

	var strSYFrom = document.cmaintenance.sy_from.value;
	var strSYTo = document.cmaintenance.sy_to.value;

	if(document.cmaintenance.course_index.selectedIndex <= 0)
	{
		alert("Please select a course.");
		return;
	}
	if(strSYFrom.length <2)
	{
		alert("Please enter <Curriculum year> to view detail course curriculum.");
		return;
	}
	if(strSYTo.length <2)
	{
		alert("Please enter <Curriculum year> to view detail course curriculum.");
		return;
	}

	if(document.cmaintenance.major_index.selectedIndex == 0) //major index is null
	{
		location = "./curriculum_maintenance_proper_viewall.jsp?ci="+strCIndex+"&cname="+escape(strCName)+
			"&syf="+strSYFrom+"&syt="+strSYTo;
	}
	else
	{
		location = "./curriculum_maintenance_proper_viewall.jsp?ci="+strCIndex+"&cname="+escape(strCName)+
			"&syf="+strSYFrom+"&syt="+strSYTo+"&mi="+strMIndex+"&mname="+escape(strMName);
	}
}
function AddRecord()
{
	document.cmaintenance.addRecord.value = 1;
	document.cmaintenance.editRecord.value = 0;
	document.cmaintenance.deleteRecord.value = 0;
	document.cmaintenance.reloadPage.value = 0;
	//document.cmaintenance.changeSubject.value = 0;
}
function DeleteRecord()
{
	document.cmaintenance.addRecord.value = 0;
	document.cmaintenance.editRecord.value = 0;
	document.cmaintenance.deleteRecord.value = 1;
	document.cmaintenance.reloadPage.value = 0;
	//document.cmaintenance.changeSubject.value = 0;
}
function EditRecord()
{
	document.cmaintenance.addRecord.value = 0;
	document.cmaintenance.editRecord.value = 1;
	document.cmaintenance.deleteRecord.value = 0;
	document.cmaintenance.reloadPage.value = 0;
	//document.cmaintenance.changeSubject.value = 0;
}
function ReloadPage()
{
	document.cmaintenance.addRecord.value = 0;
	document.cmaintenance.editRecord.value = 0;
	document.cmaintenance.deleteRecord.value = 0;
	document.cmaintenance.reloadPage.value = 1;

	document.cmaintenance.submit();
}
/*function changeSubject()
{
	document.cmaintenance.addRecord.value = 0;
	document.cmaintenance.changeCourse.value = 0;
	document.cmaintenance.changeSubject.value = 1;

	document.cmaintenance.submit();
}*/
function UpdatePreRequisite(sName,sCatg,sCatgIndex)
{
	//enter subject code, subject name, subject category to update pre-requisite.
	var sCode = document.cmaintenance.sub_index[document.cmaintenance.sub_index.selectedIndex].text;

	if(sCode == "selany")
	{
		alert("Subject code/ subject name can't be blank. Please select a subject code");
		return;
	}

	location="./curriculum_subject_pre.jsp?viewall=1&sub_code="+escape(sCode)+"&sub_name="+escape(sName)+
		"&&catg_name="+escape(sCatg)+"&catg_index="+escape(sCatgIndex)+"&hist=javascript:history.back();";
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumMaintenance,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = new Vector();//this is added to store the subject descirption, category name and category index for Pre-requisite

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Courses curriculum - proper","curriculum_maintenance_proper.jsp");
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
														"Registrar Management","CURRICULUM",request.getRemoteAddr(),
														"curriculum_maintenance_proper.jsp");
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

boolean bolProceed = true;
strErrMsg = null; //if there is any message set -- show at the bottom of the page.
CurriculumMaintenance CM = new CurriculumMaintenance();
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	if(CM.add(dbOP,request))
		strErrMsg = "Curriculum added successfully.";
	else
	{
		bolProceed = false;
		strErrMsg = CM.getErrMsg();
	}
}
else //for edit or delete
{
	strTemp = request.getParameter("editRecord");
	if(strTemp != null && strTemp.compareTo("1") == 0)
	{
		//add it here and give a message.
		if(CM.edit(dbOP,request))
			strErrMsg = "Curriculum edited successfully.";
		else
		{
			bolProceed = false;
			strErrMsg = CM.getErrMsg();
		}
	}
	else //for delete
	{
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			//add it here and give a message.
			if(CM.delete(dbOP,request))
				strErrMsg = "Information removed from curriculum successfully.";
			else
			{
				bolProceed = false;
				strErrMsg = CM.getErrMsg();
			}
		}
	}
}

	boolean bolIsLocked = new enrollment.SetParameter().isCurLocked(dbOP, WI.fillTextValue("course_index"),
		WI.fillTextValue("major_index"), WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"));



if(!bolProceed)
{
	dbOP.cleanUP();
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=CM.getErrMsg()%></font></p>
	<%
	return;
}
if(strErrMsg == null) strErrMsg = "";
%>

<form name="cmaintenance" method="post" action="./curriculum_maintenance_proper.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          COURSES CURRICULUM MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="0%" height="25">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td height="25" colspan="3"><b><%=strErrMsg%></b> </td>
    </tr>
    <tr>
      <td width="0%" height="25">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td width="37%">Course </td>
      <td width="25%">&nbsp;</td>
      <td width="36%">Curriculum year </td>
    </tr></tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><select name="course_index" onChange="ChangeCourseIndex();">
          <option value="selany">Select Any</option>
<%
//for all course listing strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc"
%>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 and degree_type="+
 						request.getParameter("degree_type")+"and cc_index="+request.getParameter("cc_index")+" order by course_name asc", request.getParameter("course_index"), false)%>
        </select></td>

      <td><input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('cmaintenance','sy_from');style.backgroundColor='white'"
	  onKeyUP="AllowOnlyInteger('cmaintenance','sy_from')">
        to
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('cmaintenance','sy_to');style.backgroundColor='white'"
	  onKeyUP="AllowOnlyInteger('cmaintenance','sy_to')">
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">Major&nbsp;&nbsp; <select name="major_index">
          <option></option>
          <%
strTemp = request.getParameter("course_index");
if(strTemp != null && strTemp.compareTo("selany") != 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%>
          <%}%>
        </select> </td>
      <td>
        <%
Vector vCurYearInfo = null;
strTemp = null;
if(WI.fillTextValue("course_index").length() == 0 || WI.fillTextValue("course_index").compareTo("selany") == 0) 
	strTemp = null;
else	
	strTemp = WI.fillTextValue("major_index");

vCurYearInfo = new enrollment.SubjectSection().getSchYear(dbOP, request.getParameter("course_index"),strTemp);
if(vCurYearInfo != null) {
%>
        <strong><font color="#0000FF" size="1">Existing Cur Year:</font> </strong><br> 
        <%
		for(int i = 0; i < vCurYearInfo.size(); i += 2) {%>
        <a href="javascript:copyCurYr(<%=(String)vCurYearInfo.elementAt(i)%>,<%=(String)vCurYearInfo.elementAt(i + 1)%>);"> 
        <font size="1" color="#000099">(<%=(String)vCurYearInfo.elementAt(i) + " - " +(String)vCurYearInfo.elementAt(i + 1)%>)</font></a> 
        <%i = i + 2;
		if(i < vCurYearInfo.size()){%>
        <a href="javascript:copyCurYr(<%=(String)vCurYearInfo.elementAt(i)%>,<%=(String)vCurYearInfo.elementAt(i + 1)%>);"> 
        <font size="1" color="#000099">(<%=(String)vCurYearInfo.elementAt(i) + " - " +(String)vCurYearInfo.elementAt(i + 1)%>)</font></a> 
        <%}//show two in one line.%>
        <br> 
        <%}%>
        <%}//only if cur info is not null;
%>
      </td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><strong>To filter SUBJECT display enter subject code starts 
        with 
        <input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="8" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:15px">
        and click REFRESH</strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="24%">&nbsp;</td>
      <td width="6%"><a href="javascript:ViewAll();" target="_self">
	  <img src="../../../images/view.gif" border="0"></a></td>
      <td width="68%" valign="bottom"><font size="1">click to view complete curriculum 
        OR click to reload page. <a href="javascript:ReloadPage();" target="_self"><img src="../../../images/refresh.gif" border="0"></a></font></td>
    </tr>
    <tr valign="middle">
      <td height="25" colspan="4"><hr size="1"> </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="2%"height="25">&nbsp;</td>
      <td width="6%" height="25">Year</td>
      <td width="23%"> <select name="year">
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
        </select>
        <select name="prep_prop_stat">
          <option value="1">Preparatory</option>
<%
strTemp = WI.fillTextValue("prep_prop_stat");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Proper</option>
<%}else{%><option value="2">Proper</option>
<%}%>
        </select></td>
      <td width="9%" height="25">&nbsp; </td>
      <td width="60%" height="25"><div align="center">&nbsp;</div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Term </td>
      <td height="25"><select name="semester" onChange="ChangeCourseType();">
          <option value="1">1st Sem</option>
          <%
strTemp = request.getParameter("semester");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>Summer</option>
          <%}else{%>
          <option value="5">Summer</option>
          <%}%>
        </select></td>
      <td height="25">
        <%if(request.getParameter("semester") != null && request.getParameter("semester").compareTo("6") == 0){%>
        Semester
          <%}%>
        </div></td>
      <td height="25">
        <%if(request.getParameter("semester") != null && request.getParameter("semester").compareTo("6") == 0){%>
        <select name="semester_internship">
          <option value="null"></option>
          <%
strTemp =WI.fillTextValue("semester_internship");
if(strTemp.compareTo("0") ==0)
{%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}%>
        </select> <font size="1">(Internship Schedule) </font>
        <%}%>
      </td>
    </tr>
    <tr>
      <td height="25"><div align="center"> </div></td>
      <td height="25" colspan="2">&nbsp;</td>
      <td height="25">&nbsp; </td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <%
//show this only if internship is selected.
if(request.getParameter("semester") == null || request.getParameter("semester").compareTo("6") != 0)
{ %>
  <table  bgcolor="#FFFFFF"
width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="8"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="2%" height="25" rowspan="2">&nbsp;</td>
      <td width="24%" rowspan="2"><font size="1"><strong>SUBJECT CODE</strong>
        <input type="text" name="scroll_sub" size="8" style="font-size:9px" 
	  onKeyUp="AutoScrollListSubject('scroll_sub','sub_index',true,'cmaintenance');">
        (scroll)</font></td>
      <td width="44%" rowspan="2"><font size="1"><strong>SUBJECT TITLE </strong></font></td>
      <td colspan="2"><div align="center"><font size="1"><strong>HOURS</strong></font></div></td>
      <td colspan="2"><div align="center"><font size="1"><strong>UNITS</strong></font></div></td>
      <td width="10%" rowspan="2"><div align="center"><font size="1"><strong>VIEW</strong></font></div></td>
    </tr>
    <tr> 
      <td width="5%"><div align="center"><font size="1"><strong>LEC.</strong></font></div></td>
      <td width="5%"><div align="center"><font size="1"><strong>LAB.</strong></font></div></td>
      <td width="5%"><div align="center"><font size="1"><strong>LEC.</strong></font></div></td>
      <td width="5%"><div align="center"><font size="1"><strong>LAB.</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><select name="sub_index" onChange="ReloadPage();">
          <option value="selany">Select Any</option>
          <%=dbOP.loadCombo("sub_index","sub_code"," from subject where IS_DEL=0 "+
WI.getStrValue(WI.fillTextValue("starts_with")," and sub_code like '","%'","")+ " order by sub_code asc", request.getParameter("sub_index"), false)%> 
        </select></td>
      <%
strErrMsg = null;
strTemp = request.getParameter("sub_index");
if(strTemp == null || strTemp.compareTo("selany") ==0)
	strTemp = "";
else
	vRetResult = CM.getSubjectInfo(dbOP,strTemp);
if(vRetResult == null)
	strErrMsg = CM.getErrMsg();

if(vRetResult != null && vRetResult.size() > 0)
{%>
      <td><%=(String)vRetResult.elementAt(0)%></td>
      <td><input name="hour_lec" type="text" size="3" value="<%=WI.fillTextValue("hour_lec")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="hour_lab" type="text" size="3" value="<%=WI.fillTextValue("hour_lab")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="lec_unit" type="text" size="3" value="<%=WI.fillTextValue("lec_unit")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="lab_unit" type="text" size="3" value="<%=WI.fillTextValue("lab_unit")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><div align="right"><a href='javascript:UpdatePreRequisite("<%=(String)vRetResult.elementAt(0)%>","<%=(String)vRetResult.elementAt(1)%>","<%=(String)vRetResult.elementAt(2)%>");'> 
          <img src="../../../images/prerequisite.gif" border="0"></a>&nbsp;</div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="6"><strong><font size="1">SUBJECT GROUP&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></strong> 
        <select name="group_name">
          <%
strTemp = WI.fillTextValue("sub_index");
if(strTemp.length() > 0 && strTemp.compareTo("0") != 0 && strTemp.compareTo("selany") != 0)
	strTemp = dbOP.mapOneToOther("SUBJECT","sub_index",strTemp,"GROUP_INDEX",null);
else	
	strTemp = "";
%>
          <%=dbOP.loadCombo("group_index","group_name"," from subject_group where IS_DEL=0 order by group_name asc", strTemp, false)%> 
        </select> </td>
      <td>&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="7%" height="25" >&nbsp;</td>
      <td width="19%"  height="19" >&nbsp;</td>
      <td width="38%" >&nbsp;</td>
      <td width="6%" colspan="2" >&nbsp;</td>
      <td width="3%" >&nbsp;</td>
      <td width="20%" >&nbsp;</td>
      <td  colspan="2" width="7%" >&nbsp;</td>
    </tr>
<%
if(!bolIsLocked){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  colspan="5" height="19" > <div align="center">
<%if(iAccessLevel > 1){%>
          <input name="image2" type="image" onClick="AddRecord();" src="../../../images/save.gif">
          <font size="1">click to save subject
          <input type="image" onClick="EditRecord();" src="../../../images/edit.gif" border="0">
          click to edit subject
    <%if(iAccessLevel ==2){%>
          <input type="image" onClick="DeleteRecord();" src="../../../images/delete.gif">
          click to delete subject
    <%}else{%>Not authorized to delete<%}%></font>
<%}else{%>Not authorized to add/edit/delete <%}%>
        </div></td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
<%}//show save if bolIsLocked false.
else{%>
    <tr>
      <td width="7%" height="25" >&nbsp;</td>
      <td width="19%"  height="19" >&nbsp;</td>
      <td width="38%" align="center"><font color="#0000FF"><strong>CURRICULUM 
        LOCKED</strong></font></td>
      <td width="6%" colspan="2" >&nbsp;</td>
      <td width="3%" >&nbsp;</td>
      <td width="20%" >&nbsp;</td>
      <td  colspan="2" width="7%" >&nbsp;</td>
    </tr>

<%	}
}else if(strErrMsg != null){%>
    <tr>
      <td>&nbsp;</td>
      <td height="25"  colspan="6"><%=strErrMsg%></td>
    </tr>
    <%}%>
  </table>
  <%}//end of showing the subject if it is not internship.
//show this only if internship is selected.
if(request.getParameter("semester") != null && request.getParameter("semester").compareTo("6") == 0 && !bolIsLocked)
{ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><strong>INTERNSHIP SUBJECT TERM</strong></td>
      <td><select name="internship_term">
	<option value="1">1st</option>
                    <%
strTemp = request.getParameter("internship_term");
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
        </select>
		</td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%"><strong>INTERNSHIP DESCRIPTION </strong></td>
      <td width="80%">
	  <select name="internship_code" onChange="ActivateDeactivate();">
	  <option value="0">Others</option>
<%=dbOP.loadCombo("INT_NAME_INDEX","NAME"," from CURR_INT_NAME order by NAME asc", request.getParameter("internship_code"), false)%>

	  </select> <font size="1">select an internship (OR) below add an internship</font><br>
        <input name="internship_name" type="text" size="64" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><strong>DURATION</strong></td>
      <td>
<%strTemp = request.getParameter("duration");
if(strTemp == null) strTemp = "";
%>
	  <input name="duration" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
	   <select name="duration_unit">
          <option value="0">weeks</option>
<%
strTemp = WI.fillTextValue("duration_unit");
if(strTemp.compareTo("1") ==0)
{%>       <option value="1" selected>hours</option>
<%}else{%><option value="1">hours</option>
<%} if(strTemp.compareTo("2") ==0){%>
	<option value="2" selected>Months</option>
<%}else{%>
		<option value="2">Months</option>
<%}%>

        </select></td>
    </tr>
	<tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><div align="center">
<%if(iAccessLevel > 1){%>
          <input name="image" type="image" onClick="AddRecord();" src="../../../images/save.gif">
          <font size="1">click to save Internship
          <input name="image" type="image" onClick="EditRecord();" src="../../../images/edit.gif" border="0">
          click to edit Internship
    <%if(iAccessLevel ==2){%>
          <input name="image" type="image" onClick="DeleteRecord();" src="../../../images/delete.gif">
          click to delete Internship
    <%}else{%>Not authorized to delete<%}%></font>
<%}else{%>Not authorized to add/edit/delete<%}%>
        </div></td>

    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="changeSubject" value="0">
<input type="hidden" name="hist" value="./curriculum_maintenance_proper.jsp">
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="cc_index" value="<%=WI.fillTextValue("cc_index")%>">
<input type="hidden" name="degree_type" value="<%=WI.fillTextValue("degree_type")%>">

<input type="hidden" name="change_course_index"><!-- only when course index is changed. -->

<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>
  </form>
</body>
</html>
<%dbOP.cleanUP();%>
