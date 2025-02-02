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
	String strExamSchIndex = null;
	String strStudName = null;
	String strEndTime = null;
	
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
dbOP.cleanUP();
String[] astrConvertAMPM={"AM","PM"};
%>

<form action="./online_exam_page3.jsp" method="post">
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#47768F"> 
      <td height="25" colspan="5" ><div align="center"><strong><font color="#FFFFFF">:: 
          ONLINE EXAMINATION - TAKE EXAM - PAGE 2 ::</font></strong></div></td>
    </tr>
    
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="5"><a href="javascript:history.back();" target="_self"><img src="../../images/go_back.gif" width="50" height="27" border="0"></a></td>
    </tr>
<%
if(strErrMsg != null)
{%>
	<tr> 
      <td>&nbsp;</td>
      <td colspan="6"><%=strErrMsg%></td>
    </tr>
<%return;}%>	
    <tr> 
      <td>&nbsp;</td>
      <td colspan="6">NOTE : If you find any information not matching - please 
        check Exam id you have entered and/or contact the Examiner.</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="6">&nbsp;</td>
    </tr>
    <tr> 
      <td width="5%">&nbsp;</td>
      <td width="19%">Student ID</td>
      <td width="26%"> <strong><%=request.getParameter("stud_id")%></strong></td>
      <td width="13%">Name</td>
      <td><strong><%=strStudName%></strong></td>
    </tr><tr> 
      <td width="5%">&nbsp;</td>
      <td width="19%">OR Number</td>
      <td> <strong><%=request.getParameter("or_number")%></strong></td>
      <td width="13%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="5"><hr></td>
    </tr>
    <tr> 
      <td><div align="center">&nbsp;</div></td>
      <td>Exam Period</td>
      <td colspan="2"><strong><%=(String)vExamDetail.elementAt(1)%></strong></td>
      <td width="37%">&nbsp;</td>
    </tr>
    <tr> 
      <td><div align="center"></div></td>
      <td>Subject code/desc.</td>
      <td colspan="2"><strong><%=(String)vExamDetail.elementAt(2)%> - <%=(String)vExamDetail.elementAt(3)%></strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Section</td>
      <td><strong><%=(String)vExamDetail.elementAt(4)%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Room #</td>
      <td><strong><%=(String)vExamDetail.elementAt(5)%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Date of Exam </td>
      <td><strong><%=(String)vExamDetail.elementAt(7)%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td><div align="center"></div></td>
      <td>Time of Exam </td>
<%
strEndTime = CommonUtil.addTime(Integer.parseInt((String)vExamDetail.elementAt(8)),Integer.parseInt((String)vExamDetail.elementAt(9)), 
Integer.parseInt((String)vExamDetail.elementAt(10)),Integer.parseInt((String)vExamDetail.elementAt(11)));
%>
      <td colspan="2"><strong><%=(String)vExamDetail.elementAt(8)%>:<%=CommonUtil.formatMinute((String)vExamDetail.elementAt(9))%> 
        <%=astrConvertAMPM[Integer.parseInt((String)vExamDetail.elementAt(10))]%> 
        - <%=strEndTime%> (<%=(String)vExamDetail.elementAt(11)%> mins)</strong>
		<input type="hidden" name="exam_min" value="<%=(String)vExamDetail.elementAt(11)%>">
		</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="5"><hr></td>
    </tr>
    <tr> 
      <td colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="5"><div align="center"> 
          <input type="submit" name="Submit" value="Start Exam">
        </div></td>
    </tr>
  </table>

  <table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" colspan="2">&nbsp;</td>
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

</form>
</body>
</html>
