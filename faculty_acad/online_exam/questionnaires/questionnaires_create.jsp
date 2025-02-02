<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function TotalPoints(strPoint, strFieldName)
{
	/*alert(document.question.addRecord.value);alert(document.question.1_1.value);
	var fieldValue = eval('document.question.'+strFieldName+'.value');
	document.question.total_points.value = Number(document.question.total_points.value)+Number(fieldValue)*Number(strPoint);
*/
}
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
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,OLExam.OLECommonUtil,OLExam.OLEQuestionnair,java.util.Vector " %>
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
	
	String strChapterCode = null;
	String strSubTopicCode = null;
	
	
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

//check for add - edit or delete 
OLECommonUtil comUtil = new OLECommonUtil();
OLEQuestionnair qN = new OLEQuestionnair();
strTemp = WI.fillTextValue("addRecord");
if(strTemp.compareTo("1") == 0)
{
	if(!qN.createQuestionnair(dbOP,request))
		strErrMsg = qN.getErrMsg();
	else
		strErrMsg = "Questionnaire parameter set successfully.";
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

Vector vNoOfQues = new Vector();
String strSubIndex = null;
if(strErrMsg == null) strErrMsg = "";
%>
<form name="question" method="post" action="./questionnaires_create.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td height="25"><div align="center"><strong><font color="#FFFFFF">:::: 
          QUESTIONNAIRES PAGE - SET PARAMETERS ::::</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="2"><strong><%=strErrMsg%></strong></td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="97%">Questionnaire prepared by(fname,last name)
        <select name="teacher">
          <%
strTemp = WI.fillTextValue("teacher");

for(int i = 0; i< vTeacherList.size(); ++i)
{
	if(strTemp.compareTo((String)vTeacherList.elementAt(i)) ==0)
	{%>
          <option value="<%=(String)vTeacherList.elementAt(i++)%>" selected><%=(String)vTeacherList.elementAt(i)%></option>
          <%}else{%>
          <option value="<%=(String)vTeacherList.elementAt(i++)%>"><%=(String)vTeacherList.elementAt(i)%></option>
          <%}
}%>
        </select></td>
    </tr>
<%
if(vTeacherList != null){%>
    
    <tr>
      <td colspan="2"><hr size="1"></td>
    </tr>
  </table>
	
  <table width="100%" border="0" bgcolor="#FFFFFF">
<%
if(vSubList != null){%>
    <tr> 
      <td width="3%" height="20">&nbsp;</td>
      <td width="25%">Questionnaire Name </td>
      <td width="72%"> 
        <input size="64" type="text" name="qn_name" value="<%=WI.fillTextValue("qn_name")%>" class="textbox">
      </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Duration of exam</td>
      <td><input name="dur_hour" type="text" size="1" maxlength="1" value="<%=WI.fillTextValue("dur_hour")%>" class="textbox">
        Hours 
        <input name="dur_min" type="text" size="3" maxlength="3" value="<%=WI.fillTextValue("dur_min")%>" class="textbox">
        Minutes </td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4"><hr> </td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="13%">Subject 
        <strong> </strong></td>
      <td colspan="2"><select name="subject" style="font-size:10px;">
        <%
strSubIndex = WI.fillTextValue("subject");
if(strSubIndex.length() == 0)
	strSubIndex = (String)vSubList.elementAt(0);

for(int i = 0; i< vSubList.size(); ++i)
{
	if(strTemp.compareTo((String)vSubList.elementAt(i)) ==0)
	{%>
        <option value="<%=(String)vSubList.elementAt(i++)%>" selected><%=(String)vSubList.elementAt(i)%></option>
        <%}else{%>
        <option value="<%=(String)vSubList.elementAt(i++)%>"><%=(String)vSubList.elementAt(i)%></option>
        <%}
}%>
      </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Exam Period</td>
      <td width="57%"><select name="exam_period">
          <%=dbOP.loadCombo("EPERIOD_INDEX","NAME"," from OLE_EPERIOD where IS_VALID=1 order by name asc", request.getParameter("exam_period"), false)%> 
      </select></td>
      <td width="27%">&nbsp;</td>
    </tr>
  </table>
    <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="1" cellpadding="1">
<%
if(vSubList != null && vSubList.size() > 0)
{%>    <tr>
      <td colspan="2" height="23"><hr></td>

    </tr>
    <tr> 
      <td width="3%" height="23">&nbsp;</td>
      <td width="97%">Chapter 
        <select name="chapter" onChange="ReloadPage();">
          <%
String strTemp2 = "";
strTemp =WI.fillTextValue("chapter");
vTemp = comUtil.getChapterList(dbOP, strSubIndex);
if(vTemp == null) vTemp = new Vector();
for(int i = 0; i< vTemp.size(); ++i)
{
	if(strTemp.compareTo((String)vTemp.elementAt(i+1)) ==0)
	{
		strTemp2 = (String)vTemp.elementAt(i+2);
		%>
          <option value="<%=(String)vTemp.elementAt(++i)%>" selected><%=(String)vTemp.elementAt(i++)%></option>
          <%}else{%>
          <option value="<%=(String)vTemp.elementAt(++i)%>"><%=(String)vTemp.elementAt(i++)%></option>
          <%}
}
if(strTemp2.length() ==0 && vTemp.size() > 0)//this is the first time, so take the first chapter in the list
{
	strTemp = (String)vTemp.elementAt(1);//chapter code.;
	strTemp2 = (String)vTemp.elementAt(2);
}
strChapterCode = strTemp;
%>
        </select> &nbsp; Name:<strong> <%=strTemp2%></strong></td>
    </tr>
    <tr> 
      <td height="23">&nbsp;</td>
      <td>Subtopic order 
        <select name="sub_topic" onChange="ReloadPage();">
          <option value="0">Select a Subtopic</option>
          <%
vTemp = comUtil.getSubChapterList(dbOP, strTemp, strTemp2,strSubIndex);
if(vTemp == null) vTemp = new Vector();
strTemp2 = "";
strTemp =WI.fillTextValue("sub_topic");
for(int i = 0; i< vTemp.size(); ++i)
{
	if(strTemp.compareTo((String)vTemp.elementAt(i+1)) ==0)
	{
		strTemp2 = (String)vTemp.elementAt(i+2);
		%>
          <option value="<%=(String)vTemp.elementAt(++i)%>" selected><%=(String)vTemp.elementAt(i++)%></option>
          <%}else{%>
          <option value="<%=(String)vTemp.elementAt(++i)%>"><%=(String)vTemp.elementAt(i++)%></option>
          <%}
}
if(strTemp2.length() ==0 && vTemp.size() > 0)//this is the first time, so take the first chapter in the list
{
	strTemp = (String)vTemp.elementAt(1);//chapter code.;
	strTemp2 = (String)vTemp.elementAt(2);
}
if(strTemp == null || strTemp.trim().length() ==0 || strTemp.compareTo("0") ==0)
	strSubTopicCode = null;
else
	strSubTopicCode = strTemp;

%>
        </select> &nbsp; Name:<strong> <%=strTemp2%></strong></td>
    </tr>
    <tr> 
      <td height="23">&nbsp;</td>
      <td>Total questions available for this chapter : 
        <%
vNoOfQues = comUtil.noOfQuesInChapter(dbOP, strChapterCode, strSubIndex, strSubTopicCode);
if(vNoOfQues == null){%>
        <%=comUtil.getErrMsg()%> 
        <%}else{%>
        T/F=<b><%=(String)vNoOfQues.elementAt(0)%></b>, M/C=<b><%=(String)vNoOfQues.elementAt(1)%></b>, 
        M/T=<b><%=(String)vNoOfQues.elementAt(2)%></b>, OBJ=<b><%=(String)vNoOfQues.elementAt(3)%></b>, 
        ESS=<b><%=(String)vNoOfQues.elementAt(4)%></b> 
        <%}%>
      </td>
    </tr>
  </table>
<%
if(vNoOfQues != null && vNoOfQues.size() > 0)
{%>

  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="7"><hr size="1"></td>
    </tr>
	    <tr> 
      <td>&nbsp;</td>
      <td>Question type</td>
      <td><strong>True/False</strong></td>
      <td><strong>Multiple Choice</strong></td>
      <td><strong>Matching Type</strong></td>
      <td><strong>Objective</strong></td>
      <td width="33%"><strong>Essay</strong></td>
    </tr>

    <tr> 
      <td width="1%">&nbsp;</td>
      <td width="23%">Test 
        Order </td>
      <td width="10%"><strong> 
        <select name="t_or1">
          <option value="1" selected>I</option>
          <option value="2">II</option>
          <option value="3">III</option>
          <option value="4">IV</option>
          <option value="5">V</option>
        </select>
       </strong></td>
      <td width="11%"><strong> 
        <select name="t_or2">
          <option value="1">I</option>
          <option value="2" selected>II</option>
          <option value="3">III</option>
          <option value="4">IV</option>
          <option value="5">V</option>
        </select>
        </strong></td>
      <td width="13%"><strong> 
        <select name="t_or3">
          <option value="1">I</option>
          <option value="2">II</option>
          <option value="3" selected>III</option>
          <option value="4">IV</option>
          <option value="5">V</option>
        </select>
        </strong></td>
      <td width="9%"><strong> 
        <select name="t_or4">
          <option value="1">I</option>
          <option value="2">II</option>
          <option value="3">III</option>
          <option value="4" selected>IV</option>
          <option value="5">V</option>
        </select>
        </strong></td>
      <td><strong> 
        <select name="t_or5">
          <option value="1">I</option>
          <option value="2">II</option>
          <option value="3">III</option>
          <option value="4">IV</option>
          <option value="5" selected>V</option>
        </select>
        </strong></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
  <tr>
  <td>
 <br>
 <%
 vTemp = comUtil.getPointsPerQuesType(dbOP);
 if(vTemp != null){
 iTFPoints = Float.parseFloat((String)vTemp.elementAt(1));
 iMCPoints = Float.parseFloat((String)vTemp.elementAt(2)); 
 iMTPoints = Float.parseFloat((String)vTemp.elementAt(3)); 
 iOBJPoints = Float.parseFloat((String)vTemp.elementAt(4)); 
 iEssayPoints = Float.parseFloat((String)vTemp.elementAt(5));
 
 %>
  NOTE: Points for each T/F=<b><%=iTFPoints%></b>, M/C=<b><%=iMCPoints%></b>, 
        M/T=<b><%=iMTPoints%></b>, OBJ=<b><%=iOBJPoints%></b>, 
        ESS=<b><%=iEssayPoints%></b> 
 <%}%>
  </td></tr>
</table>
<%
vTemp = comUtil.getDOLIndex(dbOP);
%>

<table width="100%" border="0" bgcolor="#FFFFFF">
	<tr> 
      <td colspan="8"><hr size="1"> </td>
    </tr>
	<tr> 
      <td width="3%">&nbsp;</td>
	  <td colspan="7">NOTE : To build questionnaire please set total no of question 
        for in a domain of learning for a Question type.</td>
    </tr>
<tr>
	<td width="3%">&nbsp;</td>
	<td></td>
<%
for(int i = 0; i< vTemp.size(); ++i){%>
	  <td><strong><%=(String)vTemp.elementAt(++i)%></strong></td>
<%}%>
</tr>
<tr>
    <td width="3%">&nbsp;</td>
	<td>True or False</td>
<%
for(int i = 0; i< vTemp.size(); ++i){
strTemp = "1_"+(String)vTemp.elementAt(i++);
%>
	  <td><input type="text" name="<%=strTemp%>" size="2" onKeyUp='TotalPoints("<%=iTFPoints%>","<%=strTemp%>");' value="<%=WI.fillTextValue(strTemp)%>" maxlength="3"></td>
<%}%>
</tr>
<tr>
	<td width="3%">&nbsp;</td>
	<td>Multiple Choice</td>
<%
for(int i = 0; i< vTemp.size(); ++i){
strTemp = "2_"+(String)vTemp.elementAt(i++);
%>
	  <td><input type="text" name="<%=strTemp%>" size="2" value="<%=WI.fillTextValue(strTemp)%>" maxlength="3"></td>
<%}%></tr>
<tr>
	<td width="3%">&nbsp;</td>
	<td>Matching Type</td>
<%
for(int i = 0; i< vTemp.size(); ++i){
strTemp = "3_"+(String)vTemp.elementAt(i++);
%>
	  <td><input type="text" name="<%=strTemp%>" size="2" value="<%=WI.fillTextValue(strTemp)%>" maxlength="3"></td>
<%}%>
</tr>
<tr>
	<td width="3%">&nbsp;</td>
	<td>Objectives</td>
<%
for(int i = 0; i< vTemp.size(); ++i){
strTemp = "4_"+(String)vTemp.elementAt(i++);
%>
	  <td><input type="text" name="<%=strTemp%>" size="2" value="<%=WI.fillTextValue(strTemp)%>" maxlength="3"></td>
<%}%>
</tr>
<tr>
	<td width="3%">&nbsp;</td>
	<td>Essay</td>
<%
for(int i = 0; i< vTemp.size(); ++i){
strTemp = "5_"+(String)vTemp.elementAt(i++);
%>
	  <td><input type="text" name="<%=strTemp%>" size="2" value="<%=WI.fillTextValue(strTemp)%>" maxlength="3"></td>
<%}%>
</tr>
</table>



  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td  colspan="2">Total points for this questionnair: 
        <input name="total_points" type="text" size="4" readonly="yes" value="<%=comUtil.getTotalPointOfQuestionnair(dbOP,request.getParameter("qn_name"))%>" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;"></td>
    </tr>
    <tr> 
      <td colspan="2">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="2"><div align="right"></div></td>
      <td width="81%"><input type="image" src="../../../images/save.gif" onClick="AddRecord()"><font size="1">click 
        to save entries</font></td>
    </tr>
    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#B5AB73">
  <tr>
    <td>&nbsp;</td>
  </tr>
<%			} //if vTeacherList == null
		}//if vSubList == null
	}//end of showing if subject name is not null.
}//if(vNoOfQues != null && vNoOfQues.size() > 0)
%>
</table>
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="reloadPage" value="0">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>