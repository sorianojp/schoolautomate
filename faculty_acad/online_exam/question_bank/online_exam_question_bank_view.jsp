<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/maintenancelinkscss.css" rel="stylesheet" type="text/css">
</head>
<body bgcolor="D2AE72">
<%@ page language="java" import="utility.*,OLExam.OLEQuestionBank,java.util.Vector " %>
<%
 
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
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
OLEQuestionBank qBank = new OLEQuestionBank();

Vector vSearchResult = new Vector();
vSearchResult = qBank.viewOneQuestion(dbOP, request.getParameter("info_index"),request.getParameter("info_qtype"));//display all , instead of displaying in batch.
if(vSearchResult == null)
	strErrMsg = qBank.getErrMsg();
else if(vSearchResult.size() == 0)
	strErrMsg = "No Question found.";

if(strErrMsg == null) strErrMsg = "";

String[] astrConvertQType = {"","True/False","Multiple Choice","Matching TYpe","Objective","Essay"};
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B5AB73"> 
      <td width="88%" height="25"><div align="center"><strong><font color="#FFFFFF">:::: 
          QUESTION BANK PAGE - VIEW ::::</font></strong></div></td>
    </tr>
    <tr> 
      <td> <font size="3"><strong><%=strErrMsg%></strong></font>
	  <a href="javascript:history.back();"><img src="../../../images/go_back.gif" border="0"></a></td>
    </tr>
</table>
<%
//show below only if vSearchResult.size > 0
if(vSearchResult != null && vSearchResult.size() > 0)
{
strQuestionType = (String)vSearchResult.elementAt(0);
%>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="5%">&nbsp;</td>
      <td colspan="4">Question prepared by(fname lname) : 
	  <strong><%=(String)vSearchResult.elementAt(1)%> <%=(String)vSearchResult.elementAt(2)%> </strong></td>
       </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="40%" >Subject</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>Examination Period</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3" > <strong><%=(String)vSearchResult.elementAt(3)%>  : <%=(String)vSearchResult.elementAt(4)%> </strong></td>
      <td ><strong><%=(String)vSearchResult.elementAt(9)%> </strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3">Domain 
        of learning </td>
      <td width="30%"><div align="left">Question 
          Type</div></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><strong><%=(String)vSearchResult.elementAt(10)%> </strong></td>
      <td width="8%">&nbsp;</td>
      <td width="17%">&nbsp;</td>
      <td><strong><%=astrConvertQType[Integer.parseInt((String)vSearchResult.elementAt(0))]%></strong></td>
    </tr>
    <tr> 
      <td height="23" colspan="5"><div align="center">
          <hr>
        </div></td>
    </tr>
  </table>
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4" ><div align="center"></div></td>
      <td width="11%" height="25" >Chapter </td>
      
    <td width="61%" ><strong><%=WI.getStrValue(vSearchResult.elementAt(5))%></strong></td>
      <td width="24%" height="25" >&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="4" >&nbsp;</td>
      <td>Topic </td>
      
    <td><strong><%=WI.getStrValue(vSearchResult.elementAt(6))%></strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="4" >&nbsp;</td>
      <td>Subtopic order </td>
      
    <td><strong><%=WI.getStrValue(vSearchResult.elementAt(7))%></strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="4" >&nbsp;</td>
      <td>Sub-topic </td>
      
    <td><strong><%=WI.getStrValue(vSearchResult.elementAt(8))%></strong></td>
      <td>&nbsp;</td>
    </tr>
	</table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="7" ><hr></td>
    </tr>
  </table>
   
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="1">
    <tr> 
      <td width="4%">&nbsp;</td>
      
    <td><strong>Points per question : <%=(String)vSearchResult.elementAt(12)%></strong> 
    </td>
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
      
    <td ><%=(String)vSearchResult.elementAt(11)%></td>
    </tr>
 <%
 	if(strQuestionType.compareTo("4") == 0 ) //object type.
	{%>
    <tr> 
      <td>&nbsp; </td>
      <td>Answer</td>
      
    <td><%=(String)vSearchResult.elementAt(13)%></td>
    </tr>
    <%}else if(strQuestionType.compareTo("2") ==0)//Multiple Choice
	{
int iChoice = 1;
String[] astrConvertTOABC = {"","a","b","c","d","e","f","g","h"};
strTemp = "";//System.out.println(vSearchResult.size());
for(int i = 0; i< vSearchResult.size(); )
{
	if( ((String)vSearchResult.elementAt(i+14)).compareTo("1") ==0) 
			strTemp = strTemp + "<img src=../../../images/tick.gif>"+astrConvertTOABC[iChoice++]+". "+(String)vSearchResult.elementAt(i+13)+"<br>";
	else
		strTemp = strTemp + "&nbsp;&nbsp;&nbsp;"+astrConvertTOABC[iChoice++]+". "+(String)vSearchResult.elementAt(i+13)+"<br>";
	i = i+15;//System.out.println(i);
}
	%> 
	<tr> 
      <td width="4%">&nbsp;</td>
      <td width="10%" valign="top">Choices </td>
      <td><%=strTemp%></td>
      
    </tr>
	 <%}else if(strQuestionType.compareTo("1") ==0)//True/false
	{%>
     <tr> 
      <td>&nbsp; </td>
      <td>Answer</td>
      
    <td >
	<%
	strTemp = (String)vSearchResult.elementAt(13);
	if(strTemp.compareTo("1") ==0) strTemp = "True";
	else	strTemp = "False";
	%><%=strTemp%>
	
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
      
    <td><%=(String)vSearchResult.elementAt(11)%></td>
      
    <td><%=(String)vSearchResult.elementAt(13)%></td>
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" bgcolor="#B5AB73">
  <tr>
    <td>&nbsp;</td>
  </tr>

</table>
<%}//end of displaying if vSearchResult size > 0
%>

</body>
</html>
<%
dbOP.cleanUP();
%>