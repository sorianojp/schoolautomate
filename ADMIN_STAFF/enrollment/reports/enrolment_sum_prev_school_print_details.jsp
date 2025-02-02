<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";


if(strSchCode.startsWith("UB")){%>
	<jsp:forward page="./enrolment_sum_prev_school_print_details_ub.jsp"></jsp:forward>
<%return;}%>
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.

	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-enrollment summary from prev School","enrolment_sum_prev_school.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"enrolment_sum_prev_school.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
ReportEnrollment reportEnrollment = new ReportEnrollment();
Vector vRetResult = null;
Vector vSchoolInfo = null;
String[] astrSemester = {"Summer", "1st Semester", "2nd Semester", 	"3rd Semester"};

if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0)
{
	vRetResult = reportEnrollment.getEnrolSumFromPrevSchoolDetail(dbOP, request);
	strTemp = "window.print();";
	if(vRetResult == null){
		strErrMsg = reportEnrollment.getErrMsg();
		strTemp ="";
	}
} 

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.reloadPage.value = "1";
	document.form_.submit();
}
</script>
<body onLoad="<%=strTemp%>">

<%
if (strErrMsg != null) {
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<%} else if(vRetResult != null){  %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td width="100%" height="25"  align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>SUMMARY REPORT OF ENROLLEE FROM PREVIOUS SCHOOL <br>
      (SY : 
	   <%=request.getParameter("sy_from") + " - " +  request.getParameter("sy_to") + " &nbsp;" +
	   astrSemester[Integer.parseInt(WI.getStrValue(request.getParameter("semester"),"1"))]  
	   %>)
			</strong></font><br /><br /><br /></td>
    </tr>
  </table>


  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
<% for (int i = 0; i < vRetResult.size(); i+= 5) {
	
	if (vRetResult.elementAt(i) != null) {
%>
  <tr>
    <td height="20" colspan="2" class="thinborder">
		<font color="#0000FF"> <strong>
	  &nbsp;<%=(String)vRetResult.elementAt(i) + " :: "+ (String)vRetResult.elementAt(i+1)%>	
	    </strong></font>	  </td>
  </tr>
<% } %> 
  <tr>
    <td width="40%" height="20" class="thinborder">&nbsp;&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
    <td width="60%" class="thinborder">&nbsp;
	  <%=(String)vRetResult.elementAt(i+3) + 
				WI.getStrValue((String)vRetResult.elementAt(i+4),"(",")","")%></td>
    </tr>
<%}%> 
</table>  	

<%}//only if vRetResult is not null%>
</body>
</html>
<%
dbOP.cleanUP();
%>