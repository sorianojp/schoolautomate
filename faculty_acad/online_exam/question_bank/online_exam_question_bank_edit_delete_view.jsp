<%
	if(request.getParameter("printPage") != null && request.getParameter("printPage").compareTo("1") ==0)
	{%>
		<jsp:forward page="./online_exam_question_bank_edv_print.jsp" />
		//response.sendRedirect(response.encodeRedirectURL("./online_exam_question_bank_edv_print.jsp"));
	<%	return;
	}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/maintenancelinkscss.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function EditRecord(strIndex,strQtypeIndex)
{
	document.question.info_index.value = strIndex;
	document.question.info_qtype.value = strQtypeIndex;
	
	var pgLoc= "./online_exam_question_bank_edit.jsp?info_index="+strIndex+"&info_qtype="+strQtypeIndex+"&teacher="+
	document.question.teacher[document.question.teacher.selectedIndex].value+"&subject="+
	document.question.subject[document.question.subject.selectedIndex].value;
	
	window.open(pgLoc);
	
}
function ViewRecord(strIndex,strQtypeIndex)
{
	document.question.info_index.value = strIndex;
	document.question.info_qtype.value = strQtypeIndex;
	
	location= "./online_exam_question_bank_view.jsp?info_index="+strIndex+"&info_qtype="+strQtypeIndex;
}

function DeleteRecord(strIndex,strQtypeIndex)
{
	document.question.info_index.value = strIndex;
	document.question.info_qtype.value = strQtypeIndex;
	
	document.question.deleteRecord.value = "1";
	RealoadPage();
}
function ReloadPage()
{
	document.question.submit();
}
function SearchPage()
{
	document.question.searchPage.value = "1";
	ReloadPage();
}
function PrintPage()
{
	document.question.printPage.value="1";
	document.question.teacherName.value=document.question.teacher[document.question.teacher.selectedIndex].text;
	document.question.questionType.value=document.question.q_type[document.question.q_type.selectedIndex].text;
	document.question.dolName.value=document.question.dol[document.question.dol.selectedIndex].text;
	document.question.subjectName.value=document.question.subject[document.question.subject.selectedIndex].text;
	document.question.examPeriod.value=document.question.exam_period[document.question.exam_period.selectedIndex].text;
	
	//alert(document.question.collegeName.value);
	//alert(document.question.teacherName.value);
	//alert(document.question.questionType.value);
	//alert(document.question.dolName.value);
	//alert(document.question.subjectName.value);
	//alert(document.question.examPeriod.value);
	
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,OLExam.OLECommonUtil,OLExam.OLEQuestionBank,java.util.Vector " %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strQuestionType = null; // this is true/false etc..
	String strSubName = null;
	Vector vTemp = null;
	boolean	bolIsSubtopic = false;
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

int iSearchResult = 0; 
Vector vSearchResult = new Vector();
if(request.getParameter("searchPage") != null && request.getParameter("searchPage").compareTo("1") ==0)
{
	vSearchResult = comUtil.searchQuestion(dbOP,request);
	iSearchResult = comUtil.iSearchResult;
}
%>
<form name="question" method="post" action="./online_exam_question_bank_edit_delete_view.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td width="88%" height="25" colspan="8"><div align="center"><strong><font color="#FFFFFF">:::: 
          QUESTION BANK PAGE - EDIT/DELETE/VIEW ::::</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <%
if(strErrMsg == null) strErrMsg = "";
%>
      <td colspan="4"> <font size="2"><strong><%=strErrMsg%></strong></font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="3">Question prepared by(fname,last name)
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
      <td width="2%">&nbsp;</td>
      <td width="53%">Subject (faculty can teach) </td>
      <td>Exam Period</td>
      <td><select name="exam_period">
        <option value="0">All</option>
        <%=dbOP.loadCombo("EPERIOD_INDEX","NAME"," from OLE_EPERIOD where IS_VALID=1 order by name asc", request.getParameter("exam_period"), false)%>
      </select></td>
    </tr>
<%if(vSubList != null){%>    
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2" ><select name="subject" style="font-size:10px;">
        <option value="">Select a subject</option>
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
      </select></td>
      <td >&nbsp;</td>
    </tr>
<%
//show thisonly if there is a subject listing.
if(vSubList != null && vSubList.size() > 0)//show only if subject is selected.
{%>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2">Domain of learning </font></td>
      <td width="30%">Question 
          Type</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td> <select name="dol">
	  		<option value="0">ALL</option>
          <%=dbOP.loadCombo("DOL_INDEX","NAME"," from OLE_DOL", request.getParameter("dol"), false)%> 
        </select> </td>
      <td width="15%">&nbsp;</td>
      <td><select name="q_type">
          <!--<option value="0">All</option>-->
          <%=dbOP.loadCombo("QTYPE_INDEX","NAME"," from OLE_QTYPE", request.getParameter("q_type"), false)%> 
        </select></td>
    </tr>
</table>

<%
if(strSubName != null && strSubName.length() > 0)
{%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="1">
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="17%">Chapter </td>
      <td width="81%"><select name="chapter" onChange="ReloadPage();">
          <option value="0">All</option>
<%
String strTemp2 = "";
strTemp =WI.fillTextValue("chapter");
if(strTemp.compareTo("0") ==0)
	strTemp =WI.fillTextValue("other_chapter");
vTemp = comUtil.getChapterList(dbOP, request.getParameter("subject"));
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
		</select>
      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Topic </td>
      <td><input name="chapter_name" type="text" size="64" value="<%=strTemp2%>" readonly=""></td>
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
          <option value="0">All</option>
<%
strTemp2 = "";
strTemp =WI.fillTextValue("sub_topic");
if(strTemp.compareTo("0") ==0)
	strTemp =WI.fillTextValue("oth_sub_topic");//System.out.println(request.getParameter("chapter"));
vTemp = comUtil.getSubChapterList(dbOP, request.getParameter("chapter"),request.getParameter("chapter_name"),request.getParameter("subject"));
if(vTemp == null) vTemp = new Vector();//System.out.println(vTemp.size());
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
        
		</select>
      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25">Sub-topic </td>
      <td height="25"><input name="sub_topic_name" type="text" size="64" value="<%=strTemp2%>" readonly=""></td>
    </tr>
<%}%> 
    <tr>
      <td colspan="3"><hr></td>
    </tr>
  </table>
 <%}//end of displaying if there is a subject selected.%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="1">
    <tr> 
      <td height="23" colspan="5"><div align="center">
	  	<input type="image" src="../../../images/form_proceed.gif" onClick="document.question.searchPage.value='1';document.question.printPage.value=''" ></div></td>
    </tr>
  </table>
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6" bgcolor="#B9B292"><div align="center">LIST OF 
          QUESTIONS </div></td>
    </tr>
  </table>
<%
if(request.getParameter("searchPage") != null && request.getParameter("searchPage").compareTo("1") ==0)
{
//display search result or error.

	if(vSearchResult != null && vSearchResult.size() > 0){%>
	  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
		  <td width="42%" height="25"><input type="image" src="../../../images/print.gif" border="0" onClick="PrintPage();"></a> 
			<font size="1">click to print questions </font></td>
		
		  <td width="58%">&nbsp;</td>
		</tr>
		<tr> 
		  <td colspan="2">
		  Question Type : T/F = True or Flase, MC - Multiple Choice, MT- Maching type, OBJ - Objective type</td>
		</tr>
	</table>
	  <table width="100%" bgcolor="#FFFFFF">
		<tr> 
		  <td width="66%"><b> Total Questions: <%=iSearchResult%> - Showing(<%=comUtil.strDispRange%>)</b></td>
		  <td width="34%">
		  <%
		  //if more than one page , constuct page count list here.  - 20 default display per page)
			int iPageCount = iSearchResult/comUtil.defSearchSize;
			if(iSearchResult % comUtil.defSearchSize > 0) ++iPageCount;
			
			if(iPageCount > 1)
			{%>
			<div align="right">Jump To page:  
			  <select name="jumpto" onChange="SearchPage();">
		  
			<%
				strTemp = request.getParameter("jumpto");
				if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
				
				for( int i =1; i<= iPageCount; ++i )
				{
					if(i == Integer.parseInt(strTemp) ){%>
						<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
					<%}else{%>
						<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%
						}
				}
				%>
			  </select>
			
			<%}%>
			 
			</div></td>
		</tr>
	  </table>
	
	  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
		<tr> 
		  <td width="5%" height="22"><div align="center"><font size="1">EXAM PERIOD</font></div></td>
		  <td width="5%" height="22"><div align="center"><font size="1">QUES. TYPE</font></div></td>
		  <td width="40%" height="22"><div align="center"><font size="1">QUESTION</font></div></td>
		  <td width="30%"><font size="1">ANSWER/CHOICES(for multiple choice)</font></td>
		  <td width="5%"><div align="center"><font size="1">POINTS</font></div></td>
		  <td width="5%">&nbsp;</td>
		  <td width="5%">&nbsp;</td>
<%if(false){%>		  <td width="5%"></td><%}%>
		</tr>
<%
int iChoice = 1;
String[] astrConvertTOABC = {"","a","b","c","d","e","f","g","h"};
for(int i = 0,j=0;i< vSearchResult.size(); ++i)//j is the incremator for multiple choice type.
{
strQuestionType = (String)vSearchResult.elementAt(i+1);
if(strQuestionType.compareTo("1") ==0)  strTemp = "T/F";
else if(strQuestionType.compareTo("2") ==0)  strTemp = "MC";
else if(strQuestionType.compareTo("3") ==0)  strTemp = "MT";
else if(strQuestionType.compareTo("4") ==0)  strTemp = "OBJ";
else if(strQuestionType.compareTo("5") ==0)  strTemp = "Essay";

%>		<tr> 
		  <td height="25"><font size="1"><%=(String)vSearchResult.elementAt(i+2)%></font></td>
		  <td><font size="1"><%=strTemp%></font></td>
		  <td><font size="1"><%=(String)vSearchResult.elementAt(i+3)%></font></td>
		  <td><font size="1">
<%if(strQuestionType.compareTo("1") ==0)
{
	strTemp = (String)vSearchResult.elementAt(i+5);
	if(strTemp.compareTo("1") ==0) strTemp = "True";
	else strTemp = "False";
}
else if(strQuestionType.compareTo("2") ==0)
{//System.out.println(vSearchResult.size());
	strTemp = astrConvertTOABC[iChoice++]+". "+(String)vSearchResult.elementAt(i+5);
	if( ((String)vSearchResult.elementAt(i+6)).compareTo("1") ==0) strTemp = "<img src=../../../images/tick.gif>"+strTemp;
	else 	strTemp = "&nbsp;&nbsp; "+strTemp;
	//colelct here all additional multiple choices.
	while(true)//break only if
	{	if( (i+7+j)>= vSearchResult.size()) break;
		++j;
		if( ((String)vSearchResult.elementAt(i+6+j)).length() > 0)
		{ 
			--j;break;
		}
		j = j+5;
		if( ((String)vSearchResult.elementAt(i+6+j+1)).compareTo("1") ==0) 
			strTemp += "<br>"+"<img src=../../../images/tick.gif>"+astrConvertTOABC[iChoice++]+". "+(String)vSearchResult.elementAt(i+6+j);
		else
			strTemp += "<br>"+"&nbsp;&nbsp; "+astrConvertTOABC[iChoice++]+". "+(String)vSearchResult.elementAt(i+6+j);
		j=j+1;//System.out.println(j);
	}
}
else if(strQuestionType.compareTo("3") ==0 || strQuestionType.compareTo("4") ==0)
	strTemp = (String)vSearchResult.elementAt(i+5);
else if(strQuestionType.compareTo("5") ==0) strTemp = " - - ";

%>

		  <%=strTemp%>
		  </font></td>
		  <td><font size="1"><%=(String)vSearchResult.elementAt(i+4)%></font></td>
		  <td><a href='javascript:EditRecord("<%=(String)vSearchResult.elementAt(i)%>","<%=(String)vSearchResult.elementAt(i+1)%>")'><img src="../../../images/edit.gif" border="0"></a></td>
		  <td><a href='javascript:DeleteRecord("<%=(String)vSearchResult.elementAt(i)%>","<%=(String)vSearchResult.elementAt(i+1)%>")' target="_self"><img src="../../../images/delete.gif" border="0"></a></td>
<%if(false){%>		  <td><a href='javascript:ViewRecord("<%=(String)vSearchResult.elementAt(i)%>","<%=(String)vSearchResult.elementAt(i+1)%>")' target="_self"><img src="../../../images/view.gif" border="0"></a></td><%}%>
		</tr>
<%
if(strQuestionType.compareTo("2") ==0)
	i = i+6+j;
else
	i = i + 5 ;
j = 0;///System.out.println(i);
iChoice=1;
}%>
	  </table>
	
	 <%
	}//end of showing search result. 
	else //show error message if vRetResulSearchResult == null
	{//System.out.println("I should not be here. ");
		strErrMsg = comUtil.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = "No Question Found.";
		
%>
	<table width="100%" border="0" bgcolor="#FFFFFF">
	<tr>
	<td><%=strErrMsg%></td></tr>

	</table>
<% }//end of showing error message if there is any.
 } //end of display if searchPage =1 

}//end of showing Proceed - if no subject is selected.  vSubList != null && vSubList.size() > 0 && strSubName.length() > 0)
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
<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="info_index" value="0">
<input type="hidden" name="info_qtype" value="0"><!--for question type-->
<input type="hidden" name="searchPage" value="<%=WI.fillTextValue("searchPage")%>">
<!-- for print -->
<input type="hidden" name="printPage" value="0">
<input type="hidden" name="collegeName">
<input type="hidden" name="teacherName">
<input type="hidden" name="questionType">
<input type="hidden" name="dolName">
<input type="hidden" name="subjectName">
<input type="hidden" name="examPeriod">



</form>
</body>
</html>
<%
dbOP.cleanUP();
%>