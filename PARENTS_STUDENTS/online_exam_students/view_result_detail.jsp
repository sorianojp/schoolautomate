<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.*,OLExam.OLETakeExam, java.util.Vector" %>
<%
 	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strQuesCol = "black";//red if question is not answered. 
	String strAnsCol  = "black"; //red if the answer is wrong.
	int iQuesCount = 0;
	
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
	
String strStudRefIndex = request.getParameter("stud_ref");
if(strStudRefIndex == null || strStudRefIndex.trim().length() ==0)
{
	strErrMsg = "Student reference is missing. Please try again to view answer sheet detail.";
}	
OLETakeExam oleTakeExam = new OLETakeExam();
Vector[] vRetResult	= null;
if(strErrMsg == null)
{
	vRetResult = oleTakeExam.showAnswerDetailSheet(dbOP,strStudRefIndex);
	if(vRetResult == null)
		strErrMsg = oleTakeExam.getErrMsg();
}
//System.out.println(vRetResult[0].size());
//System.out.println(vRetResult[1].size());
//System.out.println(vRetResult[2].size());

dbOP.cleanUP();
	
%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#47768F"> 
      <td height="25" colspan="5" ><div align="center"><strong><font color="#FFFFFF">:: 
        ONLINE EXAMINATION - QUESTION ANSWER DETAIL ::</font></strong></div></td>
    </tr>
    
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
<%
if(strErrMsg != null){%>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td colspan="2"><%=strErrMsg%></td>
    </tr>
 <%
 return;
 }%>	
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2">LEGEND : </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="6%">&nbsp;</td>
      <td width="91%"><font color="#0000FF"><strong>Questions in red</strong></font> 
        - this question is not answered by the student </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><font color="#0000FF"><strong>Answer in red</strong></font> - the answer 
        is wrong</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><font color="#0000FF"><strong>Answer with tick mark</strong></font> 
        - is the correct answer</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult[0].size() > 0) //T-F questions.
{%>	
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="3%" height="25"><strong>I.</strong></td>
      <td colspan="3"><strong>TRUE OR FALSE.</strong> Tick the button for TRUE 
        if the statement is true, and FALSE if the statement is false.</tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3">Points per question : <strong><%=(String)vRetResult[0].elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2">&nbsp;</td>
    </tr>
<%
strErrMsg = null;
iQuesCount = 1;
for(int i = 0; i< vRetResult[0].size(); ++i)
{
//if question is not answered, question is red.
if(vRetResult[0].elementAt(i+3) == null || ((String)vRetResult[0].elementAt(i+3)).trim().length() ==0)
	strQuesCol = "red";
else
{
	strQuesCol = "black";
	//check if answer is correct. 
}
//display the answer. 
if(((String)vRetResult[0].elementAt(i+1)).compareTo("1") == 0) // correct answer is true.
{
	if(vRetResult[0].elementAt(i+3) != null && ((String)vRetResult[0].elementAt(i+3)).compareTo("1") == 0) // student answered true.
		strTemp = "<img src=\"../../images/tick.gif\"> True ";
	else
	{
		if(strQuesCol.compareTo("red") == 0)//question is not answered.
			strTemp = "<img src=\"../../images/tick.gif\"> True";
		else
			strTemp = "<img src=\"../../images/tick.gif\"> True <font color=red> False </font>";
	}			
}
else
{
	if(vRetResult[0].elementAt(i+3) != null && ((String)vRetResult[0].elementAt(i+3)).compareTo("0") == 0) // student answered true.
		strTemp = "<img src=\"../../images/tick.gif\"> False ";
	else
	{
		if(strQuesCol.compareTo("red") == 0)//question is not answered.
			strTemp = "<img src=\"../../images/tick.gif\"> False ";
		else
			strTemp = "<font color=red> True </font> <img src=\"../../images/tick.gif\"> False ";
	}
}	

%>
     <tr> 
      <td width="3%">&nbsp;</td>
      <td width="4%" valign="top"><%=iQuesCount++%>.</td>
      <td  colspan="2"><font color="<%=strQuesCol%>"><%=(String)vRetResult[0].elementAt(i)%></font>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2"><%=strTemp%></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2">&nbsp;</td>
    </tr>
<%i = i + 3; 
}%>   
    <tr> 
      <td colspan="4"><hr></td>
    </tr>
  </table>
<%
}//end of dislaying T/F.

if(vRetResult != null && vRetResult[2].size() > 0) //multiple choice
{%>	

  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="3%"><strong>II. </strong></td>
      <td height="25" colspan="3"><strong>MULTIPLE CHOICE.</strong> Select from 
        among the choices given by ticking the button of the correct answer.</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      
    <td colspan="4">Points per question : <strong><%=(String)vRetResult[2].elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2">&nbsp;</td>
    </tr>
<%iQuesCount = 1;
String strQuesIndex = null;//System.out.println(vRetResult[2].size());
for(int i = 0; i< vRetResult[2].size();)
{//System.out.println(i);
	strQuesIndex = (String)vRetResult[2].elementAt(i); 
	//if question is not answered, question is red.
	if(vRetResult[2].elementAt(i+6) == null || ((String)vRetResult[2].elementAt(i+6)).trim().length() ==0)
		strQuesCol = "red";
	else
	{
		strQuesCol = "black";
		//check if answer is correct. 
	}


%>    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="4%"><%=iQuesCount++%>.</td>
      <td  colspan="2"><font color="<%=strQuesCol%>"><%=(String)vRetResult[2].elementAt(i+1)%> </font>
      </td>
    </tr>
<%strTemp = "";
for(int j=i ; j< vRetResult[2].size();)
{//System.out.println(vRetResult[2].elementAt(j)+" .. "+strQuesIndex);
	if( ((String)vRetResult[2].elementAt(j)).compareTo(strQuesIndex) !=0)
		break;
	
	if(((String)vRetResult[2].elementAt(j+4)).compareTo("1") == 0) // correct answer.
	{
		if(vRetResult[2].elementAt(j+6) != null && ((String)vRetResult[2].elementAt(j+6)).compareTo((String)vRetResult[2].elementAt(j+5)) == 0) // student answered true.
			strTemp += "<img src=\"../../images/tick.gif\"> "+(String)vRetResult[2].elementAt(j+3)+"<br>";
		else
			strTemp += "<img src=\"../../images/tick.gif\"> "+(String)vRetResult[2].elementAt(j+3)+"<br>";
	}
	else //this is wrong answer -- so if student has picked this answer - show in red.
	{
		if(vRetResult[2].elementAt(j+6) != null && ((String)vRetResult[2].elementAt(j+6)).compareTo((String)vRetResult[2].elementAt(j+5)) == 0) // student answered true.
			strTemp += "<font color=red> "+(String)vRetResult[2].elementAt(j+3)+"</font><br>";
		else
			strTemp += (String)vRetResult[2].elementAt(j+3)+"<br>";
	}	
j = j+7;
i = j;
}%>
	    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><%=strTemp%></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2">&nbsp;</td>
    </tr>
<%}%>
    <tr> 
      <td colspan="4"><hr></td>
    </tr>
  </table>
<%}//end of MC

if(vRetResult != null && vRetResult[3].size() > 0) //Matching type.
{

%>	
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr> 
      
    <td width="3%" height="25"><strong>III.</strong></td>
      
    <td colspan="3"><strong>MATCHING TYPE</strong></tr>
    <tr> 
      <td>&nbsp;</td>
      
    <td colspan="3">Points per question : <strong><%=(String)vRetResult[3].elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2">&nbsp;</td>
    </tr>
<%
iQuesCount = 1;
for(int i = 0; i< vRetResult[3].size(); ++i)
{

	//if question is not answered, question is red.
if(vRetResult[3].elementAt(i+3) == null || ((String)vRetResult[3].elementAt(i+3)).trim().length() ==0)
	strQuesCol = "red";
else
{
	strQuesCol = "black";
	//check if answer is correct. 
}
//display the answer. 
	if(vRetResult[3].elementAt(i+3) != null && ((String)vRetResult[3].elementAt(i+3)).compareTo((String)vRetResult[3].elementAt(i+1)) == 0) // student answered true.
		strTemp = "<img src=\"../../images/tick.gif\"> "+(String)vRetResult[3].elementAt(i+3);
	else
	{
		strTemp = "<img src=\"../../images/tick.gif\"> "+(String)vRetResult[3].elementAt(i+1)+"<br> <font color=red>"+
			(String)vRetResult[3].elementAt(i+3)+"</font>";
	}

%>
     <tr> 
      <td width="3%">&nbsp;</td>
      <td width="4%"><%=iQuesCount++%>.</td>
      <td  colspan="2"><font color="<%=strQuesCol%>"><%=(String)vRetResult[3].elementAt(i)%></font>
	  </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      
    <td  colspan="2">Answer : &nbsp; </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2"><%=strTemp%></td>
    </tr>
<%
i = i+3;}//end of for loop for obj
%>
    <tr> 
      <td colspan="4"><hr></td>
    </tr>
  </table>
<%
}//end of Matching type.

if(vRetResult != null && vRetResult[1].size() > 0) //Objective type.
{

%>	
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="3%" height="25"><strong>IV.</strong></td>
      <td colspan="3"><strong>OBJECTIVES. </strong></tr>
    <tr> 
      <td>&nbsp;</td>
      
    <td colspan="3">Points per question : <strong><%=(String)vRetResult[1].elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2">&nbsp;</td>
    </tr>
<%
iQuesCount = 1;
for(int i = 0; i< vRetResult[1].size(); ++i)
{

	//if question is not answered, question is red.
if(vRetResult[1].elementAt(i+3) == null || ((String)vRetResult[1].elementAt(i+3)).trim().length() ==0)
	strQuesCol = "red";
else
{
	strQuesCol = "black";
	//check if answer is correct. 
}
//display the answer. 
	if(vRetResult[1].elementAt(i+3) != null && ((String)vRetResult[1].elementAt(i+3)).compareTo((String)vRetResult[1].elementAt(i+1)) == 0) // student answered true.
		strTemp = "<img src=\"../../images/tick.gif\"> "+(String)vRetResult[1].elementAt(i+3);
	else
	{
		strTemp = "<img src=\"../../images/tick.gif\"> "+(String)vRetResult[1].elementAt(i+1)+"<br> <font color=red>"+
			(String)vRetResult[1].elementAt(i+3)+"</font>";
	}

%>


     <tr> 
      <td width="3%">&nbsp;</td>
      <td width="4%"><%=iQuesCount++%>.</td>
      <td  colspan="2"><font color="<%=strQuesCol%>"><%=(String)vRetResult[1].elementAt(i)%></font>
	  </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      
    <td  colspan="2">Answer : &nbsp; </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2"><%=strTemp%></td>
    </tr>
<%
i = i+3;}//end of for loop for obj
%>
    <tr> 
      <td colspan="4"><hr></td>
    </tr>
  </table>
<%
}//end of obj%>



  <table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="2"><div align="center"> </div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>

</body>
</html>