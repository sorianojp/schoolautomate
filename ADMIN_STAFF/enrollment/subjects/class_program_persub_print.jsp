<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Class program per subject","class_program_persub_print.jsp");
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
														"Enrollment","CLASS PROGRAMS",request.getRemoteAddr(),
														"class_program_persub_print.jsp");
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
Vector vRetResult = null;Vector vAddlInfo = null;


enrollment.SubjectSection SS = new enrollment.SubjectSection();

	vRetResult = SS.operateOnCPPerSub(dbOP, request,4);
	if (vRetResult == null) {
		strErrMsg = SS.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = " No Record Found";
	}
	else		
		vAddlInfo = (Vector)vRetResult.remove(0);

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsPHILCST = strSchCode.startsWith("PHILCST");
boolean bolIsEAC = strSchCode.startsWith("EAC");

	String[] strConvertSem  = {"Summer","1st Term", "2nd Term", "3rd Term", "4th Term", "5th Term"};
	String strSYFrom = WI.fillTextValue("sy_from");
	String strSemester = WI.fillTextValue("semester");
if(strErrMsg != null) {%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%">&nbsp;</td>
      <td colspan="3" height="25"><strong><%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
  </table>
<%} if (vRetResult != null && vRetResult.size() > 0) {%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td><div align="center">
        <p><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <br>
          CLASS PROGRAM<br>
          <strong><%=strConvertSem[Integer.parseInt(strSemester)]%></strong>
          , &nbsp;<strong><%=strSYFrom%> - <%=request.getParameter("sy_to")%>
          </strong><br>
        </p>

        </div></td>
    </tr>
  </table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr align="center" style="font-weight:bold">
<%if(bolIsPHILCST || bolIsEAC){%>
    <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Schedule Code </td> 
<%}%>
    <td width="10%" height="25" class="thinborder"><font size="1">Subject Code </font></td>
    <td width="20%" class="thinborder"><font size="1">Subject Description</font></td>
    <td width="16%" class="thinborder"><font size="1">Section</font></td>
    <td width="30%" class="thinborder"><font size="1">Schedule</font></td>
    <td width="8%" class="thinborder"><font size="1">Room</font></td>
    <td width="8%" class="thinborder"><font size="1">Total Units Enrolled</font></td>
    <td width="8%" class="thinborder"><font size="1">Total Students Enrolled</font></td>
  </tr>
<%
int iIndexOf = 0;
if(vAddlInfo == null)
	vAddlInfo = new Vector();
String strUnitsEnrolled = null;
String strStudentsEnrolled = null;
	
for(int i = 0 ; i < vRetResult.size() ; i+=13){
	iIndexOf = vAddlInfo.indexOf(new Integer((String)vRetResult.elementAt(i + 4)));
	if(iIndexOf == -1) {
		strUnitsEnrolled = null;
		strStudentsEnrolled = null;
	}
	else {
		strUnitsEnrolled = (String)vAddlInfo.elementAt(iIndexOf + 3);
		strStudentsEnrolled = (String)vAddlInfo.elementAt(iIndexOf + 4);
	}
	//updated for lasalle.. Nov 24, 2014... student enrolled = number of student advised.. 
	strStudentsEnrolled = (String)vRetResult.elementAt(i + 10);
%>
	  <tr>
	<%if(bolIsPHILCST || bolIsEAC){%>
		<td class="thinborder"><%=WI.getStrValue(SS.convertSubSecIndexToOfferingCount(dbOP, request, (String)vRetResult.elementAt(i + 4), strSYFrom, strSemester, strSchCode))%></td> 
	<%}%>
		<td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
		<td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
		<td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
		<td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+5)%></font></td>
		<td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></td>
	    <td class="thinborder"><%=WI.getStrValue(strUnitsEnrolled, "&nbsp;")%></td>
	    <td class="thinborder"><%=WI.getStrValue(strStudentsEnrolled, "&nbsp;")%></td>
	  </tr>
<%}//end for loop %>
</table>
<script language="JavaScript">
	window.print();
</script>

<%} // if (vRetResult != null && vRetResult.size() > 0)%>


</body>
</html>
<%
dbOP.cleanUP();
%>
