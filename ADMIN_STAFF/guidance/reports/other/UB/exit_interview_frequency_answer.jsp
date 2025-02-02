<%@ page language="java" import="utility.*,java.util.Vector,enrollment.CourseRequirement,osaGuidance.GDExitInterview" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strTemp = null;	
	String strErrMsg = null;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Guidance Exit Interview</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
</head>
<body>
<%
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
				"Admin/staff-Students Affairs-Guidance-Reports-Other(Guidance Services)","exit_interview_frequency_answer.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%return;
	}
	
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
										"Guidance","REPORTS",request.getRemoteAddr(),"exit_interview_frequency_answer.jsp");
	iAccessLevel =2;
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}

	//end of authenticaion code.	
	Vector vRetResult  	= null;
	
	GDExitInterview gdExitInterview = new GDExitInterview();
	vRetResult = gdExitInterview.generateInterviewFrequency(dbOP, request, 100);
	if(vRetResult == null){dbOP.cleanUP();strErrMsg = gdExitInterview.getErrMsg();%>
		<div style="text-align:center; font-size:14px; font-weight:bold;"><%=WI.getStrValue(strErrMsg)%></div>
	<%return;}
	
	String strQuestion = "What are some of the strengths of UB as an educational institution?";
	if(WI.fillTextValue("field_name").equals("field_63"))
		strQuestion = "What are some of the weakness of UB as an educational institution?";
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td align="center" height="25">
	<font style="font-size:14px"><%=SchoolInformation.getSchoolName(dbOP, true, false)%></font><br>
	<font style="font-size:12px"><%=SchoolInformation.getAddressLine1(dbOP, false, false)%></font><br><br>
	<strong>FREQUENCY REPORT ON EXIT INTERVIEW ANSWERS</strong>
	
	<%
	String strCIndex = WI.fillTextValue("c_index_con");
	String strCourseIndex = WI.fillTextValue("course_index");
	strErrMsg = "";
	if(strCourseIndex.length() > 0){
		if(strCIndex.length() == 0){
			strTemp = "select c_index from course_offered where course_index = "+strCourseIndex;
			strCIndex =dbOP.getResultOfAQuery(strTemp, 0);
		}
		strTemp = "select course_name from course_offered where course_index = "+strCourseIndex;
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp != null && strTemp.length() > 0)
			strErrMsg = "<br>"+strTemp.toUpperCase();
	}
	
	if(strCIndex != null && strCIndex.length() > 0){
		strTemp = "select c_name from college where c_index = "+strCIndex;
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp != null && strTemp.length() > 0)
			strErrMsg = "<br>"+strTemp.toUpperCase()+strErrMsg;
	}
	%><%=strErrMsg%><br>School Year <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%>
	
	</td></tr>
</table>	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="25"><strong>QUESTION : <%=strQuestion%></strong></td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
<%
int iCount = 0;
while(vRetResult.size() > 0){
%>
	<tr>
		<td class="thinborder" height="25"><%=++iCount%>. &nbsp; <%=vRetResult.remove(0)%></td>
	</tr>
<%}%>

</table>
<script>window.print();</script>
</body>
</html>
<%
dbOP.cleanUP();
%>