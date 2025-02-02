<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Offline Exam Question Paper.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>
</head>

<body>
<%@ page language="java" import="utility.*,OLExam.OLETakeExam,OLExam.OLECommonUtil,java.util.Vector" %>
<%
 	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strExamSchIndex = null;
	Vector vQuestionPoints = new Vector();
	int iTotalQues = 0;//total no of question for each question type.
	int iQuesCount = 1;
	Vector vQuestion = null;
	Vector vMC = null;
	String strTemp = null;
	Vector vTeacherList = null;
	
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
//get question here. [0] = t/f, [1]=m/c, [2]=m/t,[3]=obj [4]=essay.
Vector[] vQuestionList = oleTakeExam.generateQuestionOffline( dbOP,request.getParameter("qn_index"));
if(vQuestionList==null)
	strErrMsg = oleTakeExam.getErrMsg();
else
	vQuestionPoints = oleTakeExam.getNoOfQuestionOffline( dbOP,request.getParameter("qn_index"));

//System.out.println(vQuestionList[0]);System.out.println(vQuestionList[1]);System.out.println(vQuestionList[2]);
//System.out.println(vQuestionList[3]);System.out.println(vQuestionList[4]);
//System.out.println(vQuestionPoints);

String[] astrQuestionList = {"I","II","III","IV","V","VI"};
int iQuestionList = 0;

iTotalQues = Integer.parseInt((String)vQuestionPoints.elementAt(0));
if(vQuestionList[0].size() > 0 && iTotalQues > 0)
{
//vQuestionPoints is having no of questions and points . 

%>
  <table width="100%" border="0" >
    <tr> 
      <td><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=SchoolInformation.getInfo1(dbOP,false,false)%>
		</div></td>
    </tr>
    <tr>
      <td height="10"><div align="center"><strong><%=request.getParameter("c_name")%></strong></div></td>
    </tr>
    <tr> 
      <td width="3%"><div align="center"><strong><u><%=request.getParameter("e_period")%> - 
	  <%=request.getParameter("month")%>, <%=request.getParameter("year")%></u></strong></div></td>
    </tr>
  </table>
	
  <table width="100%" border="0" >
<!--
    <tr> 
      <td height="20" width="34%"><strong>INSTRUCTOR(S):</strong></td>
      <td>&nbsp;</td>
    </tr>
<%
OLECommonUtil comUtil = new OLECommonUtil();
vTeacherList = comUtil.getTeacherList(dbOP,request.getParameter("subject"));
if(vTeacherList == null)
{%>
	<tr> 
      <td colspan="2"><%=comUtil.getErrMsg()%></td>
    </tr>
<%}else{
for(int i=0; i< vTeacherList.size(); ++i){%>
    <tr> 
      <td width="34%" height="20"><%=(String)vTeacherList.elementAt(i+1)%></td>
      <td width="66%">
	  <%
	  i=i+2;
	  if(i<vTeacherList.size()){%>
	  <%=(String)vTeacherList.elementAt(i+1)%>
	  <%}%></td>
    </tr>
 <%++i;
 }
}%>-->
  </table>
  <table width="100%" border="0">
    <tr> 
      <td width="79%" style="font-size:9px; font-weight:bold">Subject : <%=request.getParameter("sub_code")%> - <%=request.getParameter("sub_name")%></td>
      <td width="21%" align="right">Duration : <u><strong><%=request.getParameter("duration")%></strong></u></td>
    </tr>
</table>	
  <table width="100%" border="0"  cellpadding="0" cellspacing="0">
    <tr> 
      <td width="3%" height="25"><strong><%=astrQuestionList[iQuestionList++]%>.</strong></td>
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
      <td  colspan="2"><input type="checkbox" name="1_ans_<%=i%>" value="1">
        True 
        <input type="checkbox" name="1_ans_<%=i%>" value="0">
        False</td>
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
      <td colspan="4"><hr size="1"></td>
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

  <table width="100%" border="0"  cellpadding="0" cellspacing="0">
    <tr> 
      <td width="3%"><strong><%=astrQuestionList[iQuestionList++]%>. </strong></td>
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
      <td colspan="2"><input type="checkbox" name="2_ans_<%=i%>" value="<%=(String)vQuestion.elementAt(j++)%>">
        <%=(String)vQuestion.elementAt(j)%>
		</td>
    </tr>
<%}%>
    <%}if(strErrMsg != null){%>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2"><%=strErrMsg%></td>
    </tr>
    <%dbOP.cleanUP();return;	}	
}%>
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%}//end of MC

iQuesCount = 0;int iTemp= 0;int iTotalNoOfQues =0; 
iTotalQues = Integer.parseInt((String)vQuestionPoints.elementAt(2));//System.out.println("JSP : "+vQuestionList[2]);
Vector[] vMT = null;
if(vQuestionList[2].size() > 0) {
	vMT = oleTakeExam.arrangeMatchingType(dbOP,vQuestionList[2], vQuestionList[2].size(),iTotalQues,10);
	if(vMT == null) 
		strErrMsg = oleTakeExam.getErrMsg();
}

if(vQuestionList[2].size() > 0 && iTotalQues > 0 && vMT != null)
{
//vQuestionPoints is having no of questions and points . 

%>	
  <table width="100%" border="0"  cellpadding="0" cellspacing="0">
    <tr> 
      <td width="3%"><strong><%=astrQuestionList[iQuestionList++]%></strong>. </td>
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
      
    <td width="6%">&nbsp; </td>
      <td> 
        <%
	  if(strTemp.length() > 0){%>
        <%=iQuesCount%>
        <%}%>
      </td>
      <td><%=strTemp%></td>
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
  </table>
  <%}//end of MC

iTotalQues = Integer.parseInt((String)vQuestionPoints.elementAt(3));
if(vQuestionList[3].size() > 0 && iTotalQues > 0)
{
//vQuestionPoints is having no of questions and points . 

%>	
  <table width="100%" border="0"  cellpadding="0" cellspacing="0">
    <tr> 
      <td width="3%" height="25"><strong><%=astrQuestionList[iQuestionList++]%>.</strong></td>
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
//System.out.println(vQuestion);
if(vQuestion == null)
	strErrMsg = oleTakeExam.getErrMsg();
else{
%>
     <tr> 
      <td width="3%">&nbsp;</td>
      <td width="4%"><%=iQuesCount++%>.</td>
      <td  colspan="2"><%=(String)vQuestion.elementAt(0)%>
	  </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      
    <td  colspan="2" height="22">Answer : &nbsp; </td>
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
      <td colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%}//end of OBJ

iTotalQues = Integer.parseInt((String)vQuestionPoints.elementAt(4));
if(vQuestionList[4].size() > 0 && iTotalQues > 0)
{
//vQuestionPoints is having no of questions and points . 

%>	
  <table width="100%" border="0"  cellpadding="0" cellspacing="0">
    <tr> 
      <td width="3%" height="25"><strong><%=astrQuestionList[iQuestionList++]%>.</strong></td>
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
	  </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
	  <td valign="top">Answer : </td> 
	</tr>
<%}
dbOP.cleanUP();
if(strErrMsg != null){%>
<tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2"><%=strErrMsg%></td>
    </tr>
<%return;	}	
}%>   
  </table>
<%}//end of OBJ
%>
<script language="JavaScript">
window.print();
</script>

</body></html>
<%
dbOP.cleanUP();
%>