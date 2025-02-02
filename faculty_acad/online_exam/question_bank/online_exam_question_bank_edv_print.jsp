<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Question List</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/maintenancelinkscss.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<%@ page language="java" import="utility.*,OLExam.OLECommonUtil,java.util.Vector " %>
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
		<p align="center"> <font  size="3">
		Error in opening connection</font></p>
		<%
		return;
	}


//end of security code. 

//check for add - edit or delete 
OLECommonUtil comUtil = new OLECommonUtil();

Vector vSearchResult = new Vector();
vSearchResult = comUtil.searchAllQuesPerDOLQType(dbOP,request);//display all , instead of displaying in batch.
int iSearchResult = comUtil.iSearchResult;//total questions found.
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="22" colspan="2" align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=SchoolInformation.getInfo1(dbOP,false,false)%></div></td>
    </tr>
    <tr > 
      <td height="22" colspan="2" align="center"><u><strong><%=request.getParameter("subjectName")%></strong></u></td>
    </tr>
    <tr > 
      <td height="22">EXAM PERIOD : <strong><%=request.getParameter("examPeriod")%></strong></td>
      <td height="22" align="right">QUESTION TYPE : <strong><%=request.getParameter("questionType")%></strong></td>
    </tr>
    <tr > 
      <td width="58%" height="22" >Questions prepared 
      by : <strong><%=request.getParameter("teacherName")%></strong></td>
      <td width="42%" align="right">Date (yyyy-mm-dd): <strong><%=WI.getTodaysDate()%></strong></td>
    </tr>
  </table>
<%if(strErrMsg != null){%>
  <table width="100%" border="0" >
    <tr> 
      <td width="100%"> <font size="2"><strong><%=strErrMsg%></strong></font></td>
    </tr>
  </table>
<%}%>  
  <table   width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="22" bgcolor="#E8E7E3"><div align="center"><strong>LIST OF QUESTIONS</strong></div></td>
    </tr>
</table>
<%
if(vSearchResult != null && vSearchResult.size() > 0){%>

<table width="100%" >
  <tr> 
    <td height="25">TOTAL NO. OF QUESTIONS :<b><%=iSearchResult%></b></td>
  </tr>
</table>
	
	  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
		<tr> 
		  <td width="5%"  height="22" class="thinborder"><div align="center">EXAM PERIOD</div></td>
		  <td width="5%"  class="thinborder"><div align="center">CHAPTER</div></td>
		  <td width="5%"  class="thinborder"><div align="center">SUB TOPIC</div></td>
		  <td width="45%" class="thinborder"><div align="center">QUESTION</div></td>
		  <td width="35%" class="thinborder">ANSWER/CHOICES(for multiple choice)</td>
		  <td width="5%"  class="thinborder"><div align="center">POINTS</div></td>
		</tr>
<%
int iChoice = 1;
String[] astrConvertTOABC = {"","a","b","c","d","e","f","g","h"};
String strPrevChapter = "";//if chpater is different - display - else do not display.
String strPrevSubTopic = "";
String strChapter = null;String strDispChapter = null; //chapter code, chapter name,
String strSubTopic = null;String strDispSubTopic = null; //subtopic code and subtopic name.
for(int i = 0,j=0;i< vSearchResult.size(); ++i)//j is the incremator for multiple choice type.
{
strQuestionType = (String)vSearchResult.elementAt(i);
strChapter = (String)vSearchResult.elementAt(i+4);
strSubTopic = (String)vSearchResult.elementAt(i+6);
if(strChapter == null) strChapter = "";
if(strPrevChapter.compareTo(strChapter) ==0) //if same , do not display. 
	strChapter = "";
else
{
	strPrevChapter = strChapter; 
	strPrevSubTopic = "";
}	
if(strSubTopic == null) strSubTopic = "";
else
	if(strPrevSubTopic.compareTo(strSubTopic) ==0) strSubTopic = "";
	else strPrevSubTopic = strSubTopic;

if(strChapter.length() > 0) //add chapter code. 
	strDispChapter = strChapter+". "+(String)vSearchResult.elementAt(i+3);
else	strDispChapter = "&nbsp;"; 
if(strSubTopic.length() > 0) strDispSubTopic = strSubTopic+". "+(String)vSearchResult.elementAt(i+5);
else strDispSubTopic = "&nbsp;";
%>		<tr> 
		  <td height="25" class="thinborder"><%=WI.getStrValue(vSearchResult.elementAt(i+7),"&nbsp;")%></td>
		  <td class="thinborder"><%=strDispChapter%></td>
		  <td class="thinborder"><%=strDispSubTopic%></td>
		  <td class="thinborder"><%=(String)vSearchResult.elementAt(i+8)%></td>
		  <td class="thinborder">
<%if(strQuestionType.compareTo("1") ==0)
{
	strTemp = (String)vSearchResult.elementAt(i+10);
	if(strTemp.compareTo("1") ==0) strTemp = "True";
	else strTemp = "False";
}
else if(strQuestionType.compareTo("2") ==0)
{//System.out.println(vSearchResult.size());
	strTemp = astrConvertTOABC[iChoice++]+". "+(String)vSearchResult.elementAt(i+10);
	if( ((String)vSearchResult.elementAt(i+11)).compareTo("1") ==0) strTemp = "<img src=../../../images/tick.gif>"+strTemp;
	//colelct here all additional multiple choices.
	while(true)//break only if
	{	if( (i+12+j)>= vSearchResult.size()) break;
		++j;
		if( ((String)vSearchResult.elementAt(i+11+j)).length() > 0)
		{ 
			--j;break;
		}
		j = j+10;
		if( ((String)vSearchResult.elementAt(i+11+j+1)).compareTo("1") ==0) 
			strTemp += "<br>"+"<img src=../../../images/tick.gif>"+astrConvertTOABC[iChoice++]+". "+(String)vSearchResult.elementAt(i+11+j);
		else
			strTemp += "<br>"+astrConvertTOABC[iChoice++]+". "+(String)vSearchResult.elementAt(i+11+j);
		++j;//System.out.println(j);
	}
}
else if(strQuestionType.compareTo("3") ==0 || strQuestionType.compareTo("4") ==0)
	strTemp = (String)vSearchResult.elementAt(i+10);
else if(strQuestionType.compareTo("5") ==0) strTemp = " - - ";

%>

		  <%=strTemp%>
		  </td>
		  <td class="thinborder"><%=(String)vSearchResult.elementAt(i+9)%></td>
		</tr>
<%
if(strQuestionType.compareTo("2") ==0)
	i = i+11+j;
else
	i = i + 10 ;
j = 0;///System.out.println(i);
iChoice=1;
}%>
	  </table>
	
	 <%
	}//end of showing search result. vSearchResult.size()>0
	else //show error message if vRetResulSearchResult == null
	{//System.out.println("I should not be here. ");
		strErrMsg = comUtil.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = "No Question Found.";
		
%>
	<table width="100%" border="0" >
	<tr>
	<td><%=strErrMsg%></td></tr>

	</table>
<% }//end of showing error message if there is any.

%>
  <table width="100%" border="0">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>
<script language="JavaScript">//window.print();
window.print();
//history.back();
//window.setInterval("javascript:history.back();",0);
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>
