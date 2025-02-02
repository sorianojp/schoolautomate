<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/maintenancelinkscss.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function EditRecord()
{
	document.question.editRecord.value =1;
	document.question.reload_parent.value = '0';
}
function ChangeQPrepBy()
{
	document.question.teacher.value = document.question.quest_prepby[document.question.quest_prepby.selectedIndex].value;
	document.question.reload_parent.value = '0';
}
function ChangeSubject()
{
	docuemnt.question.subject.value=documetn.question.subject_index[documetn.question.subject_index.selectedIndex].value;
	ReloadPage();
}
function ReloadPage()
{
	document.question.reloadPage.value =1;
	document.question.reload_parent.value = '0';
	document.question.submit();
}
function IsSelectionValid(strChoice,strIndex)
{
	var choice = eval('document.question.'+strChoice+'.value');
	if(choice.length < 1)
	{
		alert("Can't select a blank answer. Selecting default <1> choice.");
		eval('document.question.correct_choice['+strIndex+'].checked = false');
		document.question.correct_choice[0].checked = true;
	}
}
function ReloadParent() {
	if(document.question.reload_parent.value == '0')
		return;
	window.opener.document.question.submit();
}
</script>
<body bgcolor="D2AE72" onUnload="ReloadParent();">
<%@ page language="java" import="utility.*,OLExam.OLECommonUtil,OLExam.OLEQuestionBank,java.util.Vector " %>
<%
 
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strQuestionType = null; // this is true/false etc..
	boolean bolShowQuestion = false;
	boolean bolIsSubtopic = false;
	String strSubName = null;
	Vector vTemp = null;
	boolean bolGetEditInfo = false; //use  edit info if vEditInfo != null and Reload page is nto called, if reload page is called, use values filled up.
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

//check for add - edit or delete 
OLECommonUtil comUtil = new OLECommonUtil();
OLEQuestionBank qBank = new OLEQuestionBank();
strTemp = WI.fillTextValue("editRecord");
if(strTemp.compareTo("1") == 0)
{
	if(!qBank.editQuestion(dbOP,request))
		strErrMsg = qBank.getErrMsg();
	else
		strErrMsg = "Question edited successfully.";
}

Vector vTeacherList = new Vector();
Vector vSubList = new Vector();

vTeacherList = comUtil.getTeacherList(dbOP,request);
if(vTeacherList == null)
{
	if(strErrMsg != null)
		strErrMsg += comUtil.getErrMsg();
	else
		strErrMsg = comUtil.getErrMsg();
}
else {
	strTemp = WI.fillTextValue("teacher");
	if(vTeacherList.indexOf(strTemp) == -1)
		strTemp = (String)vTeacherList.elementAt(0);
	
	request.setAttribute("fac_index",strTemp);

	vSubList = comUtil.getSubjectList(dbOP,request);
	if(vSubList == null)
	{
		if(strErrMsg != null)
			strErrMsg += comUtil.getErrMsg();
		else
			strErrMsg = comUtil.getErrMsg();
	}
}

String strFatalError = null; // stop execution if edit info is null;

Vector vEditInfo = qBank.viewEditInfo(dbOP, request.getParameter("info_index"),request.getParameter("info_qtype"));
if(vEditInfo == null || vEditInfo.size() ==0) 
	strFatalError = qBank.getErrMsg();

if(strErrMsg == null) strErrMsg = "";

if(vEditInfo != null && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("1") !=0) )
	bolGetEditInfo = true;
	
%>
<form name="question" method="post" action="./online_exam_question_bank_edit.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td width="88%" height="25"><div align="center"><strong><font color="#FFFFFF">:::: 
          QUESTION BANK PAGE - EDIT ::::</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
		<td width="1%">&nbsp;</td>
      	<td colspan="4"> <strong><%=strErrMsg%></strong></td>
    </tr>
<%if(strFatalError != null)
{%>
<tr> 
		<td width="1%">&nbsp;</td>
      	<td colspan="4"> <strong><%=strFatalError%></strong></td>
    </tr>
<% dbOP.cleanUP();
return;
}%>
    
<%
if(vTeacherList != null){%>
    <tr> 
      <td width="1%">&nbsp;</td>
      <td colspan="4">Question prepared by(fname,last name) 
        <select name="ques_prepby" onChange="ChangeQPrepBy();">
		<option value="0">Select a Teacher</option>
<%
if(bolGetEditInfo)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("teacher");

for(int i = 0; i< vTeacherList.size(); ++i)
{
	if(strTemp.compareTo((String)vTeacherList.elementAt(i)) ==0)
	{%><option value="<%=(String)vTeacherList.elementAt(i++)%>" selected><%=(String)vTeacherList.elementAt(i)%></option>
<%}else{%>
	<option value="<%=(String)vTeacherList.elementAt(i++)%>"><%=(String)vTeacherList.elementAt(i)%></option>
<%}
}%>
        </select>        </td>
    </tr>
<%
if(vSubList != null){%>    <tr> 
      <td>&nbsp;</td>
      <td width="10%" valign="bottom" >Subject</td>
      <td width="46%">&nbsp; </td>
      <td width="14%">Exam Period</td>
      <td><select name="exam_period">
        <option value="0">Other</option>
        <%
if(bolGetEditInfo)
	strTemp = (String)vEditInfo.elementAt(6);
else
	strTemp =WI.fillTextValue("exam_period");
%>
        <%=dbOP.loadCombo("EPERIOD_INDEX","NAME"," from OLE_EPERIOD where IS_VALID=1 order by name asc", strTemp, false)%>
      </select>
        <input name="oth_exam_period" type="text" size="16">
        <em></em></td>
    </tr>

    <tr> 
      <td>&nbsp;</td>
      <td colspan="4">
	  <select name="subject_index" onChange="ChangeSubject();">
	  <option value="0">Select a subject</option>
<%
if(bolGetEditInfo)
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp =WI.fillTextValue("subject");

for(int i = 0; i< vSubList.size(); ++i)
{
	if(strTemp.compareTo((String)vSubList.elementAt(i)) ==0)
	{%><option value="<%=(String)vSubList.elementAt(i++)%>" selected><%=(String)vSubList.elementAt(i)%></option>
<%}else{%>
	<option value="<%=(String)vSubList.elementAt(i++)%>"><%=(String)vSubList.elementAt(i)%></option>
<%}
}%>
        </select> 
<%
//get the subject name here. 
strSubName = dbOP.mapOneToOther("subject","sub_index",strTemp,"sub_name",null);
if(strSubName == null)
	strSubName = "";
%>
Subject Title : <strong><%=strSubName%></strong>      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3">Domain of learning</td>
      <td>Question Type</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3">
        <select name="dol">
		<option value="0">ALL</option>
<%
if(bolGetEditInfo)
	strTemp = (String)vEditInfo.elementAt(7);
else
	strTemp =WI.fillTextValue("dol");
%>
		
<%=dbOP.loadCombo("DOL_INDEX","NAME"," from OLE_DOL", strTemp, false)%> 
        </select>        </td>
      <td width="29%">
<%
strQuestionType = (String)vEditInfo.elementAt(0);
if(strQuestionType.compareTo("1") ==0) strTemp = "True/False";
else if(strQuestionType.compareTo("2") ==0) strTemp = "Multiple Choice";
else if(strQuestionType.compareTo("3") ==0) strTemp = "Matching Type";
else if(strQuestionType.compareTo("4") ==0) strTemp = "Objective";
else if(strQuestionType.compareTo("5") ==0) strTemp = "Essay";
%>

          <strong><%=strTemp%></strong>
<input type="hidden" name="q_type" value="<%=strQuestionType%>">        </td>
    </tr>
    <tr> 
      <td colspan="5"><hr></td>
    </tr>
  </table>
<%
if(strSubName != null && strSubName.length() > 0)
{%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="1">
    <tr> 
      <td width="4%">&nbsp;</td>
      <td width="15%">Chapter </td>
      <td width="81%"><select name="chapter" onChange="ReloadPage();">
          <option value="0">Others</option>
<%
String strTemp2 = "";
if(bolGetEditInfo)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp =WI.fillTextValue("chapter");
	
if(strTemp.compareTo("0") ==0)
	strTemp =WI.fillTextValue("other_chapter");

//get subject index. 
if(bolGetEditInfo)
	strTemp2 = (String)vEditInfo.elementAt(3);
else
	strTemp2 =WI.fillTextValue("subject");

vTemp = comUtil.getChapterList(dbOP,strTemp2);strTemp2 = "";

if(vTemp == null) vTemp = new Vector();
for(int i = 0; i< vTemp.size(); ++i)
{
	if(strTemp.compareTo((String)vTemp.elementAt(i+1)) ==0)
	{
		strTemp2 = (String)vTemp.elementAt(i+2);
		%><option value="<%=(String)vTemp.elementAt(++i)%>" selected><%=(String)vTemp.elementAt(i++)%></option>
<%}else{%>
	<option value="<%=(String)vTemp.elementAt(++i)%>"><%=(String)vTemp.elementAt(i++)%></option>
<%}
}%>        
		</select> <input name="other_chapter" type="text" size="4"> <em><font size="1">Specify</font></em></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Topic </td>
      <td><input name="chapter_name" type="text" size="64" value="<%=strTemp2%>"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2">Subtopic ? 
<%
strTemp = WI.fillTextValue("rb_subtopic");

if(strTemp.compareTo("1") ==0)
{
bolIsSubtopic = true;
%>	  
        <input type="radio" name="rb_subtopic" value="1" checked onClick="ReloadPage();"> Yes 
        <input type="radio" name="rb_subtopic" value="0" onClick="ReloadPage();">
<%}else{%>	  
        <input type="radio" name="rb_subtopic" value="1" onClick="ReloadPage();"> Yes
        <input type="radio" name="rb_subtopic" value="0" checked onClick="ReloadPage();">
<%}%>
        No</td>
    </tr>
<%
if(bolIsSubtopic){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Subtopic order </td>
      <td><select name="sub_topic" onChange="ReloadPage();">
          <option value="0">Others</option>
<%
strTemp2 = "";
if(bolGetEditInfo)
	strTemp = (String)vEditInfo.elementAt(5);
else
	strTemp =WI.fillTextValue("sub_topic");
	
if(strTemp.compareTo("0") ==0)
	strTemp =WI.fillTextValue("oth_sub_topic");
vTemp = comUtil.getSubChapterList(dbOP, request.getParameter("chapter"),request.getParameter("chapter_name"),request.getParameter("subject"));
if(vTemp == null) vTemp = new Vector();
for(int i = 0; i< vTemp.size(); ++i)
{
	if(strTemp.compareTo((String)vTemp.elementAt(i+1)) ==0)
	{
		strTemp2 = (String)vTemp.elementAt(i+2);
		%><option value="<%=(String)vTemp.elementAt(++i)%>" selected><%=(String)vTemp.elementAt(i++)%></option>
<%}else{%>
	<option value="<%=(String)vTemp.elementAt(++i)%>"><%=(String)vTemp.elementAt(i++)%></option>
<%}
}%>        
        
		</select> <input name="oth_sub_topic" type="text" size="3"> <em><font size="1">Specify</font></em></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25">Sub-topic </td>
      <td height="25"><input name="sub_topic_name" type="text" size="64" value="<%=strTemp2%>"></td>
    </tr>
<%}%> 
    <tr>
      <td colspan="3"><hr></td>
    </tr>
  </table>


<%
if(strQuestionType != null && strQuestionType.compareTo("0") != 0)
{//display input for answer and question depending on the question type.
%>
  <table width="100%" bgcolor="#DDD9BF">
    <%
	//refer database for the values.
	if(strQuestionType.compareTo("4") ==0)//Objective type     
	{%>
    <tr> 
      <td colspan="6"><strong>OBJECTIVES.</strong>Write 
        the correct answer.</td>
    </tr>
    <%}else if(strQuestionType.compareTo("2") ==0)//Multiple Choice
	{%>
    <tr> 
      <td colspan="6"><strong>MULTIPLE 
        CHOICE.</strong>Select from among the choices given by ticking the button 
        of the correct answer.</td>
    </tr>
    <%}else if(strQuestionType.compareTo("1") ==0)//True/Flase
	{%>
    <tr> 
      <td colspan="6"><strong>TRUE 
        OR FALSE.</strong>Tick the button for TRUE if the statement is true, and 
        FALSE if the statement is false.</td>
    </tr>
    <%}else if(strQuestionType.compareTo("3") ==0)//Matching type
	{%>
	<tr> 
      <td colspan="6"><strong>MATCHING 
        TYPE.</strong>Match column A with column B by writing only the letter 
        of your answer. </td>
    </tr>
    <%}else if(strQuestionType.compareTo("5") ==0)//Comprehensive/Essay
	{%>
    <tr> 
      <td colspan="6"><strong>ESSAY. </strong></td>
    </tr>
    <%}%>
  </table>
	
<%
//if(bolShowQuestion)
{%>
   
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="1">
    <tr> 
      <td width="4%">&nbsp;</td>
      <td><strong>Points 
        per question : 
<%
if(bolGetEditInfo)
	strTemp = (String)vEditInfo.elementAt(9);
else
	strTemp =WI.fillTextValue("points");
%>
        <input name="points" type="text" size="3" value="<%=strTemp%>">
        </strong> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
</table>
<%
//show the question / answer option depending on the question type.
if(strQuestionType.compareTo("3") != 0 ) //not matching type.
{
%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="1">
    <tr> 
      <td width="4%">&nbsp; </td>
      <td width="10%">Question</td>
<%
if(bolGetEditInfo)
	strTemp = (String)vEditInfo.elementAt(8);
else
	strTemp =WI.fillTextValue("question");
%>
      <td ><input name="question" type="text" size="90" value="<%=strTemp%>">
      </td>
    </tr>
 <%
 	if(strQuestionType.compareTo("4") == 0 ) //object type.
	{%>
    <tr> 
      <td>&nbsp; </td>
      <td>Answer</td>
      <td>
<%if(bolGetEditInfo)
	strTemp = (String)vEditInfo.elementAt(10);
else
	strTemp =WI.fillTextValue("correct_ans");
%>
	  <input name="correct_ans" type="text" size="90" value="<%=strTemp%>"></td>
    </tr>
    <%}else if(strQuestionType.compareTo("2") ==0)//Multiple Choice
	{%> <tr> 
      <td width="4%">&nbsp;</td>
      <td width="10%">Choices (Please select the correct answer)</td>
      <td>
<%//System.out.println("Size : "+vEditInfo.size());
if(bolGetEditInfo)//get all options , if option is correct, set strTemp2=checked, else strTemp2="";
{
	strTemp = (String)vEditInfo.elementAt(10);
	strTemp2=(String)vEditInfo.elementAt(11);
	if(strTemp2.compareTo("1") == 0) strTemp2 = " checked";
	else strTemp2 = "";
}else
{
	strTemp =WI.fillTextValue("choice0");
	strTemp2=WI.fillTextValue("correct_choice");
	if(strTemp2.compareTo("0") ==0) strTemp2 = " checked";
	else	strTemp2 = "";
}%>

	   <input type="radio" name="correct_choice" value="0"<%=strTemp2%>> <input name="choice0" type="text" size="64" value="<%=strTemp%>"> 
        <br> 
<%if(bolGetEditInfo && vEditInfo.size() > 23)
{
	strTemp = (String)vEditInfo.elementAt(22);
	strTemp2=(String)vEditInfo.elementAt(23);
	if(strTemp2.compareTo("1") == 0) strTemp2 = " checked";
	else strTemp2 = "";
}else
{
	strTemp =WI.fillTextValue("choice1");
	strTemp2=WI.fillTextValue("correct_choice");
	if(strTemp2.compareTo("1") ==0) strTemp2 = " checked";
	else	strTemp2 = "";
}%>		<input type="radio" name="correct_choice" value="1"<%=strTemp2%>> <input name="choice1" type="text" size="64" value="<%=strTemp%>">
        <br> 
<%if(bolGetEditInfo && vEditInfo.size() > 35)
{
	strTemp = (String)vEditInfo.elementAt(34);
	strTemp2=(String)vEditInfo.elementAt(35);
	if(strTemp2.compareTo("1") == 0) strTemp2 = " checked";
	else strTemp2 = "";
}else
{
	strTemp =WI.fillTextValue("choice2");
	strTemp2=WI.fillTextValue("correct_choice");
	if(strTemp2.compareTo("2") ==0) strTemp2 = " checked";
	else	strTemp2 = "";
}%>		<input type="radio" name="correct_choice" value="2"<%=strTemp2%> onClick='IsSelectionValid("choice2","2");'> <input name="choice2" type="text" size="64" value="<%=strTemp%>"> 
        <br> 
<%if(bolGetEditInfo && vEditInfo.size() > 47)
{
	strTemp = (String)vEditInfo.elementAt(46);
	strTemp2=(String)vEditInfo.elementAt(47);
	if(strTemp2.compareTo("1") == 0) strTemp2 = " checked";
	else strTemp2 = "";
}else
{
	strTemp =WI.fillTextValue("choice3");
	strTemp2=WI.fillTextValue("correct_choice");
	if(strTemp2.compareTo("3") ==0) strTemp2 = " checked";
	else	strTemp2 = "";
}%>		<input type="radio" name="correct_choice" value="3"<%=strTemp2%> onClick='IsSelectionValid("choice3","3");'> <input name="choice3" type="text" size="64" value="<%=strTemp%>"> 
        <br> 
<%if(bolGetEditInfo && vEditInfo.size() > 59)
{
	strTemp = (String)vEditInfo.elementAt(58);
	strTemp2=(String)vEditInfo.elementAt(59);
	if(strTemp2.compareTo("1") == 0) strTemp2 = " checked";
	else strTemp2 = "";
}else
{
	strTemp =WI.fillTextValue("choice4");
	strTemp2=WI.fillTextValue("correct_choice");
	if(strTemp2.compareTo("4") ==0) strTemp2 = " checked";
	else	strTemp2 = "";
}%>		<input type="radio" name="correct_choice" value="4"<%=strTemp2%> onClick='IsSelectionValid("choice4","4");'> <input name="choice4" type="text" size="64" value="<%=strTemp%>"> 
        <br> 
<%if(bolGetEditInfo && vEditInfo.size() > 71)
{
	strTemp = (String)vEditInfo.elementAt(70);
	strTemp2=(String)vEditInfo.elementAt(71);
	if(strTemp2.compareTo("1") == 0) strTemp2 = " checked";
	else strTemp2 = "";
}else
{
	strTemp =WI.fillTextValue("choice5");
	strTemp2=WI.fillTextValue("correct_choice");
	if(strTemp2.compareTo("5") ==0) strTemp2 = " checked";
	else	strTemp2 = "";
}%>		<input type="radio" name="correct_choice" value="5"<%=strTemp2%> onClick='IsSelectionValid("choice5","5");'> <input name="choice5" type="text" size="64" value="<%=strTemp%>"> 
      </td>
      
    </tr>
	 <%}else if(strQuestionType.compareTo("1") ==0)//True/false
	{%>
     <tr> 
      <td>&nbsp; </td>
      <td>Answer</td>
      <td >
<%if(bolGetEditInfo)
	strTemp = (String)vEditInfo.elementAt(10);
else
	strTemp =WI.fillTextValue("correct_ans");
if(strTemp.compareTo("1") ==0)//false
{%>
	  <input type="radio" name="correct_ans" value="1" checked> 
        True&nbsp;&nbsp;&nbsp; 
        <input type="radio" name="correct_ans" value="0">
		False
<%}else{%>
	  <input type="radio" name="correct_ans" value="1"> 
        True&nbsp;&nbsp;&nbsp; 
        <input type="radio" name="correct_ans" value="0" checked>
		False
<%}%>
		
		
	   </td>
    </tr>
    <tr> 
      <td >&nbsp; </td>
      <td>&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
  </table>
 <%}
}else //Maching type
	{%>  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="1" cellpadding="1">
    <tr> 
      <td width="4%">&nbsp;</td>
      <td width="37%"><strong>COLUMN A </strong>(QUESTION)</td>
      <td width="59%"><strong>COLUMN B</strong> (ANSWERS)</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>
<%if(bolGetEditInfo)
	strTemp = (String)vEditInfo.elementAt(8);
else
	strTemp =WI.fillTextValue("question");
%>
	  <input name="question" type="text" size="45" value="<%=strTemp%>"></td>
      <td>
<%if(bolGetEditInfo)
	strTemp = (String)vEditInfo.elementAt(10);
else
	strTemp =WI.fillTextValue("correct_ans");
%>
	  <input name="correct_ans" type="text" size="45" value="<%=strTemp%>"></td>
    </tr>
  </table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%">
    <tr> 
      <td width="10%">&nbsp;</td>
      <td width="31%"><input type="image" src="../../../images/edit.gif" onClick="EditRecord();">
        <font size="1">click to Edit entries</font></td>
      <td width="59%">&nbsp;</td>
    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
 <%		}//show if SubName is not null;
 	}//if bolShowQuestion is true.
 }//end of showing question and answer options. 
 %>
  <table width="100%" border="0" bgcolor="#B5AB73">
  <tr>
    <td>&nbsp;</td>
  </tr>
<%} //if vTeacherList == null
}//if vSubList == null
%>
</table>
<!-- all hidden fields go here -->
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="info_qtype" value="<%=WI.fillTextValue("info_qtype")%>">
<input type="hidden" name="college" value="<%=WI.fillTextValue("college")%>">
<input type="hidden" name="collegeName" value="<%=WI.fillTextValue("collegeName")%>">
<input type="hidden" name="teacher" value="<%=WI.fillTextValue("teacher")%>">
<input type="hidden" name="subject" value="<%=WI.fillTextValue("subject")%>">

<!-- when window is closed, reload the parent window. -->
<input type="hidden" name="reload_parent">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>