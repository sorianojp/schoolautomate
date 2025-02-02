<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Reference Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

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

-->
</style>

<body>
<%@ page language="java" import="utility.*,enrollment.Authentication,enrollment.FacultyManagement, enrollment.FacultyManagementExtn,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strSyFrom = null;
	String strSyTo = null;
	boolean[] bolConflict = {false}; // this is passed to getSubjectScheduleTime to check if the subject is conflict with the previous

	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-CAN TEACH"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-schedule","faculty_sched.jsp");
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
/**
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","FACULTY",request.getRemoteAddr(),
														"faculty_sched.jsp");
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
**/

//end of authenticaion code.
FacultyManagementExtn fm = new FacultyManagementExtn();
FacultyManagement FM = new FacultyManagement();
Vector vRetResult = new Vector();
Vector vPersonalDetails = new Vector();
String strEmpID = WI.fillTextValue("emp_id");
String strMaxLoad =  fm.getFacMaxLoad(dbOP,request);
String[] astrConvSem = {"Summer", "1st", "2nd", "3rd"};
String strSem = WI.fillTextValue("semester");

if (strEmpID.length() > 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
}
%>
<form name="form_" method="post" action="./faculty_subj_list_load.jsp">
<table width="100%" border="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="100%"><div align="center"><font size="1"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,true,false)%></font></div></td>
  </tr>
  <% if(strErrMsg != null){%>
  <tr> 
    <td height="25">&nbsp;&nbsp; <%=strErrMsg%></td>
  </tr>
  <%}%>
  <tr> 
    <td height="25">&nbsp;</td>
  </tr>
</table>
  <%
if(vPersonalDetails != null && vPersonalDetails.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      <td width="17%">Employee Name</td>
      <td width="27%"> <strong>&nbsp;<%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
      <td width="19%">Employment Status</td>
      <td width="35%">&nbsp;<strong><%=WI.getStrValue((String)vPersonalDetails.elementAt(16),"")%></strong></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td><strong>&nbsp;<%=WI.getStrValue((String)vPersonalDetails.elementAt(13),"")%></strong></td>
      <td>Employment Type</td>
      <td><strong>&nbsp;<%=WI.getStrValue((String)vPersonalDetails.elementAt(15),"")%></strong></td>
    </tr>
    <tr > 
      <td height="24">&nbsp;</td>
      <td>Department</td>
      <td><strong>&nbsp;<%=WI.getStrValue((String)vPersonalDetails.elementAt(14),"N/A")%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr >
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2"><div align="center"><strong><font color="#FF0000">LIST 
          OF SUBJECTS FACULTY CAN TEACH</font></strong></div></td>
    </tr>
  <tr> 
    <td width="1%" height="25" bgcolor="#FFFFFF">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Maximum 
      Load Units : <strong><font color="#FF0000"><%=strMaxLoad%></font></strong></td>
    <td width="1%" height="25" bgcolor="#FFFFFF"><div align="right"></div></td>
  </tr>
</table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder" >
  <tr> 
    <td width="13%" height="25" class="thinborder" ><div align="center"><strong>SUBJECT GROUP</strong></div></td>
    <td width="12%" height="25" class="thinborder"><div align="center"><strong>SUBJECT CODE</strong></div></td>
    <td width="34%" class="thinborder"><div align="center"><strong>SUBJECT TITLE </strong></div></td>
  </tr>
<% 
	vRetResult = fm.operateOnFacCanTeach(dbOP, request, 4);
	if (vRetResult != null && vRetResult.size()>0){
	for (int i = 0; i< vRetResult.size() ; i+=6) {
%>
  <tr> 
    <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp")%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
  </tr>
  <%} // end for loop
}else{ strErrMsg = fm.getErrMsg();  %>
  <tr> 
    <td height="25" colspan="3" class="thinborder">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
  </tr>
<%}
	String strEmpIndex = (String)vPersonalDetails.elementAt(0);
   	vPersonalDetails = FM.viewFacultyDetail(dbOP,strEmpIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"));
%>
</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="18">&nbsp;</td>
      <td height="15" colspan="7">&nbsp;</td>
    </tr>
    <tr> 
      <td height="29" >&nbsp;</td>
      <td height="29" colspan="7"><div align="center"><strong><font color="#FF0000">LIST 
          OF SUBJECTS CURRENTLY HANDLED</font></strong></div></td>
    </tr>
    <tr> 
      <td width="0%" height="29">&nbsp;</td>
      <td height="29">School Year : <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%> </td>
      <td height="29" colspan="4">Term : <strong><%=astrConvSem[Integer.parseInt(strSem)]%></strong></td>
<%
	if (vPersonalDetails!=null){
		strTemp = (String)vPersonalDetails.elementAt(6);
	}else{
		strTemp = "0";
	}
%>
      <td width="44%" height="29"> Current Load : <strong><%=WI.getStrValue(strTemp,"0")%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="15%" height="25" class="thinborder"><div align="center"><font size="1"><strong>SUBJECT 
          CODE</strong></font></div></td>
      <td width="22%" class="thinborder"><div align="center"><font size="1"><strong>SUBJECT TITLE 
          </strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>LEC/LAB UNITS 
          </strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>SECTION </strong></font></div></td>
      <td width="25%" class="thinborder"><div align="center"><font size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>ROOM #</strong></font></div></td>
    </tr>
    <%	
	if(vPersonalDetails == null)
		strErrMsg = FM.getErrMsg();
 

	vRetResult = FM.viewFacultyLoadSummary(dbOP,strEmpIndex, WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
				WI.fillTextValue("semester"));
	
	if (vRetResult !=null && vRetResult.size() > 0){				
	for(int i = 0 ; i < vRetResult.size() ; i +=9){%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5),"Not Set")%></td>
    </tr>
    <%}}%>
  </table>
  <%} // end no detail.. no show%>

  <input type="hidden" name="emp_id">
  <input type="hidden" name="sy_from">
  <input type="hidden" name="sy_to">
  <input type="hidden" name="semester">
  

  </form>
<script>
	window.print();
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>
