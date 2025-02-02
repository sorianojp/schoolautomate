<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript">
var iIncr = -1;
function ShowTime(Min)
{
	if(iIncr ==-1)
	{
		--Min;
		iIncr = 60;
	}

	var t = new Date();

	var s = t.getSeconds();
	--iIncr

	window.status="Time Left -> "+ Min + ":"+(iIncr) +" Mins";

	if(Min == 58 && iIncr == 0)
		return;

	if(iIncr == 0)
	{
		iIncr = -1;
	}

	window.setTimeout("ShowTime("+Min+")", 900);
}
</script>
</head>

<body bgcolor="#9FBFD0" onLoad='ShowTime("<%=request.getParameter("exam_min")%>");'>
<%@ page language="java" import="utility.*,OLExam.OLETakeExam, java.util.Vector" %>
<%
 	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strExamSchIndex = null;
	String strStudName = null;
	String strEndTime = null;
	Vector vQuestionPoints = new Vector();
	int iTotalQues = 0;//total no of question for each question type.
	int iQuesCount = 1;
	Vector vQuestion = null;
	Vector vMC = null;
	String strTemp = null;
	
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
	
OLETakeExam oleTakeExam = new OLETakeExam();	
Vector vExamDetail = oleTakeExam.getOpenExamSchedule(dbOP,request.getParameter("exam_id"),request.getParameter("or_number"));
if(vExamDetail == null || vExamDetail.size() ==0)
	strErrMsg = oleTakeExam.getErrMsg();
else
	strExamSchIndex = (String)vExamDetail.elementAt(0);
if(strErrMsg == null)
{
	// if student does not exist , return error
	strStudName = new CommonUtil().getName(dbOP,request.getParameter("stud_id"),false);	    
	if(strStudName == null)
		strErrMsg = "Student Does not exist.";	      
}	

//get question here. [0] = t/f, [1]=m/c, [2]=m/t,[3]=obj [4]=essay.
Vector[] vQuestionList = oleTakeExam.generateQuestion( dbOP,  strExamSchIndex,request.getParameter("stud_id"));
if(vQuestionList==null)
	strErrMsg = oleTakeExam.getErrMsg();
else
	vQuestionPoints = oleTakeExam.getNoOfQuestion( dbOP, strExamSchIndex);


String[] astrConvertAMPM={"AM","PM"};
%>

<form action="./online_exam_result.jsp" method="post" name="ole_page3">
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#47768F"> 
      <td height="25" colspan="5" ><div align="center"><strong><font color="#FFFFFF">:: 
          ONLINE EXAMINATION - TAKE EXAM - PAGE 3 ::</font></strong></div></td>
    </tr>
    
  </table>
<%
if(strErrMsg != null){%>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td><%=strErrMsg%></td>
    </tr>
  </table>
 <%dbOP.cleanUP();return;}%> 
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="1%">&nbsp;</td>
      <td width="13%">Student ID</td>
      <td width="31%"> <strong><%=request.getParameter("stud_id")%></strong></td>
      <td width="13%">Name</td>
      <td width="42%"><strong><%=request.getParameter("stud_name")%></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Or Number</td>
      <td><strong><%=request.getParameter("or_number")%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="5"><hr></td>
    </tr>
    <tr> 
      <td colspan="5"><div align="center"><strong><%=(String)vExamDetail.elementAt(1)%>  Examination</strong></div></td>
    </tr>
    <tr> 
      <td colspan="5"><div align="center"><strong><%=(String)vExamDetail.elementAt(2)%> 
          - <%=(String)vExamDetail.elementAt(3)%></strong></div></td>
    </tr>
    <tr> 
      <td colspan="5"><div align="center"><strong>Section <%=(String)vExamDetail.elementAt(4)%> 
          : Room # <%=(String)vExamDetail.elementAt(5)%></strong></div></td>
    </tr>
    <tr> 
<%
strEndTime = CommonUtil.addTime(Integer.parseInt((String)vExamDetail.elementAt(8)),Integer.parseInt((String)vExamDetail.elementAt(9)), 
Integer.parseInt((String)vExamDetail.elementAt(10)),Integer.parseInt((String)vExamDetail.elementAt(11)));
strTemp = (String)vExamDetail.elementAt(7)+"  "+(String)vExamDetail.elementAt(8)+":"+
			CommonUtil.formatMinute((String)vExamDetail.elementAt(9))+ " "+
          	astrConvertAMPM[Integer.parseInt((String)vExamDetail.elementAt(10))];
%>      <td colspan="5"><div align="center"><strong><%=strTemp%> - <%=strEndTime%> (<%=(String)vExamDetail.elementAt(11)%> mins)
		</strong></div></td>

<!--all realated to exam detail goes here in hidden field.-->
<input type="hidden" name="e_type" value="<%=(String)vExamDetail.elementAt(1)%>">
<input type="hidden" name="sub_code" value="<%=(String)vExamDetail.elementAt(2)%>">
<input type="hidden" name="sub_name" value="<%=(String)vExamDetail.elementAt(3)%>">
<input type="hidden" name="section" value="<%=(String)vExamDetail.elementAt(4)%>">
<input type="hidden" name="room_no" value="<%=(String)vExamDetail.elementAt(5)%>">
<input type="hidden" name="start_time" value="<%=strTemp%>">
<input type="hidden" name="end_time" value="<%=strEndTime%>">
<input type="hidden" name="mins" value="<%=(String)vExamDetail.elementAt(11)%>">

    </tr>
    <tr> 
      <td colspan="5"><hr></td>
    </tr>
  </table>
<%
iTotalQues = Integer.parseInt((String)vQuestionPoints.elementAt(0));
if(vQuestionList[0].size() > 0 && iTotalQues > 0)
{
//vQuestionPoints is having no of questions and points . 

%>	
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="3%" height="25"><strong>I.</strong></td>
      <td colspan="3"><strong>TRUE OR FALSE.</strong> Tick the button for TRUE 
        if the statement is true, and FALSE if the statement is false.</tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3">Points per question : <strong><%=(String)vQuestionPoints.elementAt(5)%></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2">&nbsp;</td>
    </tr>
<%
strErrMsg = null;
for(int i = 0; i< vQuestionList[0].size(); ++i){
vQuestion = oleTakeExam.getQuestion(dbOP, (String)vQuestionList[0].elementAt(i),"1");
if(vQuestion == null)
	strErrMsg = oleTakeExam.getErrMsg();
else{
%>
     <tr> 
      <td width="3%">&nbsp;</td>
      <td width="4%"><%=iQuesCount++%>.</td>
      <td  colspan="2"><%=(String)vQuestion.elementAt(0)%>
	  <input type="hidden" name="1_ques_<%=i%>" value="<%=(String)vQuestionList[0].elementAt(i)%>"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2"><input type="radio" name="1_ans_<%=i%>" value="1">
        True 
        <input type="radio" name="1_ans_<%=i%>" value="0">
        False</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2">&nbsp;</td>
    </tr>
<%}if(strErrMsg != null){%>
<tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2"><%=strErrMsg%></td>
    </tr>
<%dbOP.cleanUP();return;	}	
}%>   
    <tr> 
      <td colspan="4"><hr></td>
    </tr>
  </table>
<%}//end of T/F
%>
<input type="hidden" name="1_qs" value="<%=(--iQuesCount)%>">
<%
iTotalQues = Integer.parseInt((String)vQuestionPoints.elementAt(1));
if(vQuestionList[1].size() > 0 && iTotalQues > 0)
{
//vQuestionPoints is having no of questions and points . 

%>	

  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="3%"><strong>II. </strong></td>
      <td height="25" colspan="3"><strong>MULTIPLE CHOICE.</strong> Select from 
        among the choices given by ticking the button of the correct answer.</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="4">Points per question : <strong><%=(String)vQuestionPoints.elementAt(6)%></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2">&nbsp;</td>
    </tr>
<%iQuesCount = 1;
strErrMsg = null;//System.out.println(vQuestionList[1]);
for(int i = 0; i< vQuestionList[1].size(); ++i){
vQuestion = oleTakeExam.getQuestion(dbOP, (String)vQuestionList[1].elementAt(i),"2");//System.out.println(vQuestion);
if(vQuestion == null)
	strErrMsg = oleTakeExam.getErrMsg();
else{
%>    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="4%"><%=iQuesCount++%>.</td>
      <td  colspan="2"><%=(String)vQuestion.elementAt(0)%> 
        <input type="hidden" name="2_ques_<%=i%>" value="<%=(String)vQuestionList[1].elementAt(i)%>">	
      </td>
    </tr>
<%
for(int j=1 ; j< vQuestion.size(); ++j){%>
	    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><input type="radio" name="2_ans_<%=i%>" value="<%=(String)vQuestion.elementAt(j++)%>">
        <%=(String)vQuestion.elementAt(j)%>
		</td>
    </tr>
<%}%>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2">&nbsp;</td>
    </tr>
    <%}if(strErrMsg != null){%>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2"><%=strErrMsg%></td>
    </tr>
    <%dbOP.cleanUP();return;	}	
}%>
    <tr> 
      <td colspan="4"><hr></td>
    </tr>
  </table>
<%}//end of MC
%>
<input type="hidden" name="2_qs" value="<%=(--iQuesCount)%>">

<%iQuesCount = 0;int iTemp= 0;int iTotalNoOfQues =0; 
iTotalQues = Integer.parseInt((String)vQuestionPoints.elementAt(2));//System.out.println("JSP : "+vQuestionList[2]);
Vector[] vMT = oleTakeExam.arrangeMatchingType(dbOP,vQuestionList[2], vQuestionList[2].size(),iTotalQues,10);

if(vMT == null) strErrMsg = oleTakeExam.getErrMsg();
if(vQuestionList[2].size() > 0 && iTotalQues > 0 && vMT != null)
{
//vQuestionPoints is having no of questions and points . 

%>	
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="3%"><strong>III</strong>. </td>
      <td height="25" colspan="5"><strong>MATCHING TYPE.</strong> Match column 
        A with column B by selecting only the number of your answer. </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="5">Points per question : <strong><%=(String)vQuestionPoints.elementAt(7)%></strong></td>
    </tr>
    <tr> 
      <td colspan="2">&nbsp;</td>
      <td width="3%">&nbsp;</td>
      <td width="41%">&nbsp;</td>
      <td width="3%">&nbsp;</td>
      <td width="44%">&nbsp;</td>
    </tr>
<%
for(int i=0 ; i< vMT.length; ++i){
//shuffle here the answer. 
//System.out.println(vMT[i+1].size());
//vMT[i+1] = oleTakeExam.generateRand(vMT[i+1]);
%>
   <tr> 
      <td>&nbsp;</td>
      <td><strong>SET <%=i/2+1%>.</strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="6%"><div align="left"></div></td>
      <td>&nbsp;</td>
      <td><u>COLUMN A</u></td>
      <td>&nbsp;</td>
      <td><u>COLUMN B</u></td>
    </tr>
<%
for(int j=0; j< vMT[i].size(); ++j){
strTemp = (String)vMT[i].elementAt(j);
++iQuesCount;
++iTotalNoOfQues;
%>
    <tr> 
      <td>&nbsp;</td>
      <td width="6%">
	  <%if(strTemp.length()> 0){%>
	   <select name="3_ans_<%=iTemp%>">
          <%for(int p=0; p< vMT[i+1].size(); ++p)
		  {%>
		  <option value="<%=(String)(String)vMT[i+1].elementAt(p)%>"><%=p+1%></option>
		  <%}%>
        </select>
		<%}%> </td>
      <td> 
        <%
	  if(strTemp.length() > 0){%>
        <%=iQuesCount%>
        <%}%>
      </td>
      <td><%=strTemp%>
	 <%
	 if(strTemp.length() > 0)
	 {%>
	 <input name="3_ques_<%=iTemp++%>" type="hidden" value="<%=(String)vQuestionList[2].elementAt(iTotalNoOfQues-1)%>">
	 <%}%>
	 </td>
      <td><%=iQuesCount%></td>
      <td><%=(String)vMT[i+1].elementAt(j)%></td>
    </tr>
	<tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
	
    <%}//end of priting the options. 
iQuesCount = 0;//reset to 0;
i = i+1;}//outer loop to print options.for(int i=0 ; i< vMT.size(); ++i)

	if(strErrMsg != null){%>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3"><%=strErrMsg%></td>
    </tr>
    <%dbOP.cleanUP();return;		
}%>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%}//end of MC
%>
<input type="hidden" name="3_qs" value="<%=iTemp%>">

    
  <%
iTotalQues = Integer.parseInt((String)vQuestionPoints.elementAt(3));
if(vQuestionList[3].size() > 0 && iTotalQues > 0)
{
//vQuestionPoints is having no of questions and points . 

%>	
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="3%" height="25"><strong>IV.</strong></td>
      <td colspan="3"><strong>OBJECTIVES. </strong></tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3">Points per question : <strong><%=(String)vQuestionPoints.elementAt(8)%></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2">&nbsp;</td>
    </tr>
<%
iQuesCount = 1;
for(int i = 0; i< vQuestionList[3].size(); ++i){
vQuestion = oleTakeExam.getQuestion(dbOP, (String)vQuestionList[3].elementAt(i),"4");
if(vQuestion == null)
	strErrMsg = oleTakeExam.getErrMsg();
else{
%>
     <tr> 
      <td width="3%">&nbsp;</td>
      <td width="4%"><%=iQuesCount++%>.</td>
      <td  colspan="2"><%=(String)vQuestion.elementAt(0)%>
	  <input type="hidden" name="4_ques_<%=i%>" value="<%=(String)vQuestionList[3].elementAt(i)%>"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2">Answer : &nbsp;
        <input name="4_ans_<%=i%>" type="text" size="64"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2">&nbsp;</td>
    </tr>
<%}if(strErrMsg != null){%>
<tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2"><%=strErrMsg%></td>
    </tr>
<%dbOP.cleanUP();return;	}	
}%>   
    <tr> 
      <td colspan="4"><hr></td>
    </tr>
  </table>
<%}//end of OBJ
%>
<input type="hidden" name="4_qs" value="<%=(--iQuesCount)%>">

    <%
iTotalQues = Integer.parseInt((String)vQuestionPoints.elementAt(4));
if(vQuestionList[4].size() > 0 && iTotalQues > 0)
{
//vQuestionPoints is having no of questions and points . 

%>	
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="3%" height="25"><strong>V.</strong></td>
      <td colspan="3"><strong>ESSAY.</strong></tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3">Points per question : <strong><%=(String)vQuestionPoints.elementAt(9)%></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2">&nbsp;</td>
    </tr>
<%
iQuesCount = 1;
for(int i = 0; i< vQuestionList[4].size(); ++i){
vQuestion = oleTakeExam.getQuestion(dbOP, (String)vQuestionList[4].elementAt(i),"5");
if(vQuestion == null)
	strErrMsg = oleTakeExam.getErrMsg();
else{
%>
     <tr> 
      <td width="3%">&nbsp;</td>
      <td width="4%"><%=iQuesCount++%>.</td>
      <td  colspan="2"><%=(String)vQuestion.elementAt(4)%>
	  <input type="hidden" name="5_ques_<%=i%>" value="<%=(String)vQuestionList[4].elementAt(i)%>"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
	  <td valign="top">Answer : </td>
      <td valign="top"><textarea name="5_ans_<%=i%>" cols="64" rows="5"></textarea> 
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2">&nbsp;</td>
    </tr>
<%}if(strErrMsg != null){%>
<tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2"><%=strErrMsg%></td>
    </tr>
<%dbOP.cleanUP();return;	}	
}%>   
    <tr> 
      <td colspan="4"><hr></td>
    </tr>
  </table>
<%}//end of OBJ
%>
<input type="hidden" name="5_qs" value="<%=(--iQuesCount)%>">

  <table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2"><div align="center">
          <input type="submit" name="Submit" value="Finish Exam">
        </div></td>
    </tr>
    <tr> 
      <td colspan="2"><div align="center"> </div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>


<input type="hidden" name="or_number" value="<%=WI.fillTextValue("or_number")%>">
<input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">
<input type="hidden" name="exam_id" value="<%=WI.fillTextValue("exam_id")%>">
<input type="hidden" name="exam_sch_index" value="<%=strExamSchIndex%>">
<input type="hidden" name="stud_name" value="<%=strStudName%>">
<input type="hidden" name="exam_start_time" value="<%=WI.getTodaysDateTime()%>">
<!--<input type="hidden" name="tf_qs" value="">
<input type="hidden" name="mc_qs" value="">
<input type="hidden" name="mt_qs" value="">
<input type="hidden" name="obj_qs" value="">
<input type="hidden" name="ess_qs" value="">
-->

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>