<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>


<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
	if(strUserIndex == null) {%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
			You are already logged out. Please login again.</font></p>
		<%
		return;
	}
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
//add security here.

try	{
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
	
	//check if elem student.
	String strSQLQuery = "select course_index from stud_curriculum_hist "+
		"join semester_sequence on (semester_sequence.semester_val = semester) "+
		"where is_valid = 1 and user_index = "+strUserIndex+" order by sy_from desc, sem_order desc";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery,0);
	if(strSQLQuery.equals("0")) {//basic
		dbOP.cleanUP();
		
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">Not Available for Grade School Student</font></p>
		<%
		return;
	}
	
	
	
enrollment.AttendanceMonitoringCDD attendanceCDD = new enrollment.AttendanceMonitoringCDD();
Vector vRetResult = attendanceCDD.operateOnAttendanceMonitoringCDD(dbOP, request, 4);
if(vRetResult == null)
	strErrMsg = attendanceCDD.getErrMsg();
%>

<body>
<form name="cm_op" method="post" action="./class_attendance_CDD.jsp" onSubmit="SubmitOnceButton(this);">  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr style="font-weight:bold;">
		<Td class="thinborder" align="center" height="25">Date of Absence</Td>
		<Td class="thinborder" align="center">No of Hour(s)</Td>
	</tr>
	<%
	for(int i = 0; i < vRetResult.size(); i += 8){
	%>
	<tr>
		<td class="thinborder" height="25"><%=vRetResult.elementAt(i+5)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i+7)%></td>
	</tr>
	<%}%>
</table>
<%}%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>