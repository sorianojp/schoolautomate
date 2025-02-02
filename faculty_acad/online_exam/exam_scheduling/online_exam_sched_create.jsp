<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadIfNecessary()
{
	if(document.question.section.selectedIndex >=0)
		ReloadPage();
}
function AddRecord()
{
	document.question.addRecord.value =1;
}
function ReloadPage() {
	document.question.addRecord.value =0;
	document.question.reloadPage.value =1;
	document.question.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,OLExam.OLECommonUtil,OLExam.OLESchedule,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strQuestionType = null; // this is true/false etc..
	String strSubName = null;
	String strTemp2 = "";
	Vector vTemp = null;
	String strTempId = null;//this will be called when schedule is created successfully.
	boolean bolScheduleCreateSuccess = false;


	float iTFPoints = 0;float iMCPoints = 0; float iMTPoints = 0; float iOBJPoints = 0; float iEssayPoints = 0;

//add security here.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		//exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}


//end of security code.

//check for add - edit or delete rd
OLECommonUtil comUtil = new OLECommonUtil();
OLESchedule qS = new OLESchedule();
strTemp = WI.fillTextValue("addRecord");
if(strTemp.compareTo("1") == 0)
{
	strTempId = qS.createExamSchedule(dbOP,request);
	if(strTempId == null)
		strErrMsg = qS.getErrMsg();
	else
	{
		bolScheduleCreateSuccess = true;
		strErrMsg = "Exam schedule successfully created.";
	}
}

Vector vTeacherList = new Vector();
Vector vSubList = new Vector();

vTeacherList = comUtil.getTeacherListAll(dbOP,request);
if(vTeacherList == null)
{
	if(strErrMsg != null)
		strErrMsg += comUtil.getErrMsg();
	else
		strErrMsg = comUtil.getErrMsg();
}
vSubList = comUtil.getSubjectList(dbOP,request.getParameter("college"));
if(vSubList == null)
{
	if(strErrMsg != null)
		strErrMsg += comUtil.getErrMsg();
	else
		strErrMsg = comUtil.getErrMsg();
}

Vector vQNList = new Vector();
if(strErrMsg == null) strErrMsg = "&nbsp;";
%>
<form name="question" method="post" action="./online_exam_sched_create.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73">
      <td width="88%" height="25" colspan="8"><div align="center"><strong><font color="#FFFFFF">::::
          EXAM SCHEDULING PAGE - ADD/CREATE ::::</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="2"><strong><%=strErrMsg%></strong>
<%
if(bolScheduleCreateSuccess){%>
<font color="red">Exam ID : <%=strTempId%></font>
<%}%>
</td>
    </tr>
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="97%">College
        <select name="college" onChange="ReloadPage();">
          <option value="0"> Select a College offering subject</option>
          <%=dbOP.loadCombo("C_INDEX","C_NAME"," from COLLEGE where IS_DEL=0 order by C_NAME asc", request.getParameter("college"), false)%>
        </select>
      </td>
    </tr>
    <tr>
      <td colspan="2"><hr></td>
    </tr>
  </table>

<%
if(vSubList != null){%>

  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="21%">Subject <strong> </strong></td>
      <td colspan="2"><select name="subject" onChange="ReloadPage();">
          <option value="0">Select a subject</option>
          <%
strTemp =WI.fillTextValue("subject");

for(int i = 0; i< vSubList.size(); ++i)
{
	if(strTemp.compareTo((String)vSubList.elementAt(i)) ==0)
	{%>
          <option value="<%=(String)vSubList.elementAt(i++)%>" selected><%=(String)vSubList.elementAt(i)%></option>
          <%}else{%>
          <option value="<%=(String)vSubList.elementAt(i++)%>"><%=(String)vSubList.elementAt(i)%></option>
          <%}
}%>
        </select>
        <%
//get the subject name here.
strSubName = dbOP.mapOneToOther("subject","sub_index",request.getParameter("subject"),"sub_name",null);
if(strSubName == null)
	strSubName = "";
%>
        Subject Title : <strong><%=strSubName%></strong> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Examination Period</td>
      <td width="15%"><select name="exam_period" onChange="ReloadPage();">
          <%=dbOP.loadCombo("EPERIOD_INDEX","NAME"," from OLE_EPERIOD where IS_VALID=1 order by name asc", request.getParameter("exam_period"), false)%>
        </select></td>
      <td width="61%">Offering School Year/Term &nbsp;&nbsp; <input type="text" name="sy_from" maxlength="4" size="4" value="<%=WI.fillTextValue("sy_from")%>">
        to
        <input type="text" name="sy_to" maxlength="4" size="4" value="<%=WI.fillTextValue("sy_to")%>">
        &nbsp; <select name="semester" onChange="ReloadIfNecessary();">
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
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><input name="image" type="image" onClick="ReloadPage();" src="../../../images/form_proceed.gif"></td>
    </tr>
  </table>
<%
//get questionnair list.
vQNList = comUtil.getQuestionnairList(dbOP, request.getParameter("subject"),request.getParameter("exam_period"));
if(vQNList != null && vQNList.size() > 0)
{%>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td  colspan="3" height="25"><hr></td>
    </tr>
    <tr>
      <td width="3%" height="20">&nbsp;</td>
      <td width="21%">Questionnaire</td>
      <td width="76%"><select name="qn" onChange="ReloadPage();">
          <option value="0">Select a Questionnair</option>
          <%
strTemp =WI.fillTextValue("qn");
int iTemp = 0;
for(int i = 0; i< vQNList.size(); ++i)
{
	if(strTemp.compareTo((String)vQNList.elementAt(i)) ==0)
	{
	  	   iTemp = new Integer((String)vQNList.elementAt(i+2)).intValue();
		   strTemp2 = iTemp/60+ " hours "+ iTemp%60+ " mins";
	%>
          <option value="<%=(String)vQNList.elementAt(i++)%>" selected><%=(String)vQNList.elementAt(i)%></option>
          <%}else{%>
          <option value="<%=(String)vQNList.elementAt(i++)%>"><%=(String)vQNList.elementAt(i)%></option>
          <%}
++i;
}
%>
        </select>
        Batch
        <select name="batch">
          <option value="0">N/A</option>
          <%
strTemp = WI.fillTextValue("batch");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Batch 1</option>
          <%}else{%>
          <option value="1">Batch 1</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Batch 2</option>
          <%}else{%>
          <option value="2">Batch 2</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>Batch 3</option>
          <%}else{%>
          <option value="3">Batch 3</option>
          <%}%>
        </select> <font size="1">(same section is having different questionnaire)</font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Duration of exam</td>
      <td><%=strTemp2%> <input type="hidden" name="dur_in_min" value="<%=iTemp%>"></td>
    </tr>
    <tr>
      <td  colspan="3" height="20"><hr></td>
    </tr>
  </table>
 <%
 //show only questionnair is selected -
 if(request.getParameter("qn") != null && request.getParameter("qn").compareTo("0") != 0)
 {

	 //get section list here.
	 vTemp = comUtil.getSectionOfferedByTheSubject(dbOP, request.getParameter("subject"), request.getParameter("sy_from"),
	 														request.getParameter("sy_to"),request.getParameter("semester"));
	 if(vTemp == null || vTemp.size() ==0)
	 {%>
   <table width="100%" border="0" bgcolor="#FFFFFF">
	<tr>
	<td width="3%">&nbsp;</td>
	<td><%=comUtil.getErrMsg()%></td>
	</tr>
<%}else{%>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="20">&nbsp;</td>
      <td width="21%">Section</td>
      <td width="76%"> <select name="section">
          <%
strTemp =WI.fillTextValue("section");
for(int i = 0; i< vTemp.size(); ++i)
{
	if(strTemp.compareTo((String)vTemp.elementAt(i)) ==0)
	{%>
          <option value="<%=(String)vTemp.elementAt(i++)%>" selected><%=(String)vTemp.elementAt(i)%></option>
          <%}else{%>
          <option value="<%=(String)vTemp.elementAt(i++)%>"><%=(String)vTemp.elementAt(i)%></option>
          <%}
}
%>
        </select> </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Examiner name</td>
      <td> <select name="teacher">
          <%
if(vTeacherList != null)
{
	strTemp = WI.fillTextValue("teacher");

	for(int i = 0; i< vTeacherList.size(); ++i)
	{
		if(strTemp.compareTo((String)vTeacherList.elementAt(i)) ==0)
		{%>
          <option value="<%=(String)vTeacherList.elementAt(i++)%>" selected><%=(String)vTeacherList.elementAt(i)%></option>
          <%}else{%>
          <option value="<%=(String)vTeacherList.elementAt(i++)%>"><%=(String)vTeacherList.elementAt(i)%></option>
          <%}
	}
}%>
        </select> </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Date of exam</td>
      <td><input name="exam_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("exam_date")%>" class="textbox">
        <a href="javascript:show_calendar('question.exam_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        (mm/dd/yyyy) </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Exam start time</td>
      <td> <select name="hr">
          <%
	  strTemp = WI.fillTextValue("hr");
	  if(strTemp.length() ==0) strTemp ="0";
	  for(int i=1; i< 13; ++i)
	  {
	  	if(strTemp.compareTo(Integer.toString(i)) == 0)
	  {%>
          <option value="<%=i%>" selected><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}
	 }%>
        </select>
        :
        <select name="min">
          <%
	  strTemp = WI.fillTextValue("min");
	  if(strTemp.length() ==0) strTemp ="0";
	  for(int i=0; i< 61; i+=5)
	  {
	  	if(strTemp.compareTo(Integer.toString(i)) == 0)
	  {%>
          <option value="<%=i%>" selected><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}
	 }%>
        </select> <select name="AMPM">
          <option value="0">AM</option>
          <% strTemp = WI.fillTextValue("AMPM");
	if(strTemp.compareTo("1") ==0)
	{%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select> </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Exam room number</td>
      <td><input name="room_no" type="text" size="16" value="<%=WI.fillTextValue("room_no")%>"></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Room location</td>
      <td><input name="room_loc" type="text" size="16" value="<%=WI.fillTextValue("room_loc")%>"></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td width="127">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td><div align="right"></div></td>
      <td width="850"><input type="image" src="../../../images/save.gif" onClick="AddRecord();"><font size="1">click
        to save entries</font></td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<%			}//vSubject list is not null and not empty.
		}//vQNList not null
	}//getSectionOfferedByTheSubject returns subject section list
}//if questionnair is selected.
%>
  <table width="100%" border="0" bgcolor="#B5AB73">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>
 <input type="hidden" name="addRecord" value="0">
<input type="hidden" name="reloadPage" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
