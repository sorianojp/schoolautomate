<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/maintenancelinkscss.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function AddRecord()
{
	document.question.addRecord.value =1;
}
function ReloadPage()
{
	document.question.addRecord.value =0;
	document.question.reloadPage.value =1;

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



</script>
<body bgcolor="D2AE72">
<%@ page language="java" import="utility.*,OLExam.OLECommonUtil,OLExam.OLEQuestionBank,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strQuestionType = null; // this is true/false etc..
	boolean bolShowQuestion = false;
	boolean bolIsSubtopic = false;
	String strSubName = null;
	Vector vTemp = null;
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
strTemp = WI.fillTextValue("addRecord");
if(strTemp.compareTo("1") == 0)
{
	if(!qBank.addQuestion(dbOP,request))
		strErrMsg = qBank.getErrMsg();
	else
		strErrMsg = "Question added successfully.";
}

Vector vTeacherList = new Vector();
Vector vSubList = new Vector();

vTeacherList = comUtil.getTeacherList(dbOP,request);
if(vTeacherList == null) {
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

String strSubIndex = null;
if(strErrMsg == null) strErrMsg = "";
%>
<form name="question" method="post" action="./online_exam_question_bank_create.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73">
      <td width="88%" height="25"><div align="center"><strong><font color="#FFFFFF">::::
          QUESTION BANK PAGE - ADD/CREATE ::::</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
		<td width="1%">&nbsp;</td>
      	<td colspan="3"> <strong><%=strErrMsg%></strong></td>
    </tr>

<%
if(vTeacherList != null){%>
    <tr>
      <td width="1%">&nbsp;</td>
      <td colspan="3">Question prepared by(fname,last name)
        <select name="teacher">
<%
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
      <td valign="bottom" >Subject (faculty can teach) </td>
      <td width="13%">Exam Period</td>
      <td><select name="exam_period">
        <option value="0">Other</option>
        <%=dbOP.loadCombo("EPERIOD_INDEX","NAME"," from OLE_EPERIOD where IS_VALID=1 order by name asc", request.getParameter("exam_period"), false)%>
      </select>
      <input name="oth_exam_period" type="text" size="16"></td>
    </tr>

    <tr>
      <td>&nbsp;</td>
      <td colspan="3">
	  <select name="subject" style="font-size:10px;">
<%
strSubIndex = WI.fillTextValue("subject");
if(strSubIndex.length() == 0)
	strSubIndex = (String)vSubList.elementAt(0);//System.out.println(strSubIndex);

for(int i = 0; i< vSubList.size(); ++i)
{
	if(strSubIndex.compareTo((String)vSubList.elementAt(i)) ==0)
	{%><option value="<%=(String)vSubList.elementAt(i++)%>" selected><%=(String)vSubList.elementAt(i)%></option>
<%}else{%>
	<option value="<%=(String)vSubList.elementAt(i++)%>"><%=(String)vSubList.elementAt(i)%></option>
<%}
}%>
        </select>		</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="2">Domain of learning</td>
      <td>Question Type</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="2">
        <select name="dol">
<option value="0">All</option>
<%=dbOP.loadCombo("DOL_INDEX","NAME"," from OLE_DOL", request.getParameter("dol"), false)%>
        </select>        </td>
      <td width="29%">
          <select name="q_type" onChange="ReloadPage();">
            <option value="0">Select a type</option>
<%=dbOP.loadCombo("QTYPE_INDEX","NAME"," from OLE_QTYPE", request.getParameter("q_type"), false)%>
          </select>        </td>
    </tr>
    <tr>
      <td colspan="4"><hr></td>
    </tr>
  </table>
<%
if(vSubList != null && vSubList.size() > 0)
{%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="1">
    <tr>
      <td width="4%">&nbsp;</td>
      <td width="15%">Chapter </td>
      <td width="81%"><select name="chapter" onChange="ReloadPage();">
          <option value="0">Others</option>
<%
String strTemp2 = "";
strTemp =WI.fillTextValue("chapter");
if(strTemp.compareTo("0") ==0)
	strTemp =WI.fillTextValue("other_chapter");
vTemp = comUtil.getChapterList(dbOP, strSubIndex);
if(vTemp == null)
	vTemp = new Vector();
else if(vTemp.size() > 0) {
	if(strTemp.length() == 0 && request.getParameter("other_chapter") == null)
		strTemp = (String)vTemp.elementAt(1);
}
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
strQuestionType = request.getParameter("q_type");
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
    <!--<tr>
      <td width="4%">&nbsp;</td>
      <td><strong>Points
        per question :
        <input name="points" type="hidden" size="3" value="<%=WI.fillTextValue("points")%>">
        </strong> </td>
    </tr>-->
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;<input name="points" type="hidden" size="3" value="<%=WI.fillTextValue("points")%>"></td>
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
      <td ><input name="question" type="text" size="90"></td>
    </tr>
 <%
 	if(strQuestionType.compareTo("4") == 0 ) //object type.
	{%>
    <tr>
      <td>&nbsp; </td>
      <td>Answer</td>
      <td><input name="correct_ans" type="text" size="90"></td>
    </tr>
    <%}else if(strQuestionType.compareTo("2") ==0)//Multiple Choice
	{%> <tr>
      <td width="4%">&nbsp;</td>
      <td width="10%" valign="top"><br>Choices (Please select the correct answer)</td>
      <td> <input type="radio" name="correct_choice" value="0" checked> <input name="choice0" type="text" size="64">
        <br> <input type="radio" name="correct_choice" value="1" onClick='IsSelectionValid("choice1","1");'> <input name="choice1" type="text" size="64">
        <br> <input type="radio" name="correct_choice" value="2" onClick='IsSelectionValid("choice2","2");'> <input name="choice2" type="text" size="64">
        <br> <input type="radio" name="correct_choice" value="3" onClick='IsSelectionValid("choice3","3");'> <input name="choice3" type="text" size="64">
        <br> <input type="radio" name="correct_choice" value="4" onClick='IsSelectionValid("choice4","4");'> <input name="choice4" type="text" size="64">
        <br> <input type="radio" name="correct_choice" value="5" onClick='IsSelectionValid("choice5","5");'> <input name="choice5" type="text" size="64">
      </td>

    </tr>
	 <%}else if(strQuestionType.compareTo("1") ==0)//True/false
	{%>
     <tr>
      <td>&nbsp; </td>
      <td>Answer</td>
      <td >
	  <input type="radio" name="correct_ans" value="1">
        True&nbsp;&nbsp;&nbsp;
        <input type="radio" name="correct_ans" value="0">
		False</td>
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
      <td><input name="question" type="text" size="45"></td>
      <td><input name="correct_ans" type="text" size="45"></td>
    </tr>
  </table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%">
    <tr>
      <td width="10%">&nbsp;</td>
      <td width="31%"><input type="image" src="../../../images/save.gif" width="48" height="28" onClick="AddRecord();"><font size="1">click
        to save entries</font></td>
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
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="reloadPage" value="0">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
