<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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

.bodystyle {
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
</head>
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector" %>
<%
	DBOperation dbOP = (DBOperation)request.getSession(false).getAttribute("dbOP_");
	boolean bolIsDBInSession = false;
	
	String strTemp = null;
	String strErrMsg = null;
	WebInterface WI = new WebInterface(request);

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
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-TEACHING LOAD"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-SUMMARY LOAD"),"0"));
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
		if(dbOP == null) {
			dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
									"Admin/staff-Enrollment-Faculty-Faculty Load Print","teaching_load_slip_print.jsp");
		}
		else {
			bolIsDBInSession = true;
			//System.out.println(bolIsDBInSession);
		}
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
														"teaching_load_slip_print.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
**/

Vector vRetResult = null;

FacultyManagement FM = new FacultyManagement();
Vector vUserDetail = null;
String strEmployeeIndex = dbOP.mapOneToOther("user_table","id_number","'"+WI.fillTextValue("emp_id")+"'",
							"user_index"," and (auth_type_index is null or (auth_type_index <>4 and auth_type_index<>6))");
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");


if(strEmployeeIndex != null) {
	vUserDetail = FM.viewFacultyDetail(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"));
	if(vUserDetail == null){
		strErrMsg = FM.getErrMsg();
	}else {
		vRetResult = FM.viewFacultyLoadSummary(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"));
		if(vRetResult == null)
			strErrMsg = FM.getErrMsg();
		
	}
}else if (WI.fillTextValue("emp_id").length() > 0) {
	strErrMsg = " Invalid employee ID.";
}

String[] astrSemester={"Summer", "First Semester", "Second Semester","Third Semester"};

//end of authenticaion code.
%>
  
<table width="100%" border="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="100%" colspan="2"><div align="center"><font size="2"><strong>
			<%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong> </font><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font><br>
<br>

		 <%="Academic Year : " + WI.fillTextValue("sy_from")  +" - " + WI.fillTextValue("sy_to")%>
		 <% if (WI.fillTextValue("semester").length() > 0) 
		 		strTemp = astrSemester[Integer.parseInt(WI.fillTextValue("semester"))];
			else strTemp = "";
		 %><%=WI.getStrValue(strTemp," , ","","")%></div>
      <br></td>
  </tr>
  <% if(strErrMsg != null){%>
  <tr> 
    <td height="25" colspan="2">&nbsp;&nbsp; <%=strErrMsg%></td>
  </tr>
  <%}%>
</table>
<%   if(vUserDetail != null && vUserDetail.size() > 0){%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr > 
    <td width="2%" height="30">&nbsp;</td>
    <td width="15%">Employee Name</td>
    <td width="29%"><strong><%=(String)vUserDetail.elementAt(1)%></strong></td>
    <td width="19%">Employment Status</td>
    <td width="35%"><strong><%=(String)vUserDetail.elementAt(2)%></strong></td>
  </tr>
  <tr > 
    <td height="25">&nbsp;</td>
    <td>College :: Dept </td>
	
	<% strTemp = (String)vUserDetail.elementAt(4);
	   if (strTemp == null) strTemp = (String)vUserDetail.elementAt(5);
	   else strTemp += WI.getStrValue((String)vUserDetail.elementAt(5),"::","","");%>	
	   
    <td><strong> <%=strTemp%></strong></td>
    <td>Employment Type</td>
    <td><strong><%=(String)vUserDetail.elementAt(7)%></strong></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="33%" height="25"><font size="1">TOTAL NO. OF SECTION : <strong><%=(String)vUserDetail.elementAt(8)%></strong></font></td>
  </tr>
</table>
<%}//end of vUserDetail. 

if(vRetResult != null && vRetResult.size() > 0){%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr> 
    <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>SUBJECT 
        CODE</strong></font></div></td>
    <td width="26%" class="thinborder"><div align="center"><font size="1"><strong>COLLEGE 
        OFFERING </strong></font></div></td>
    <td width="7%" class="thinborder"><div align="center"><strong><font size="1">FACULTY 
        LOAD</font></strong></div></td>
    <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>SECTION 
        </strong></font></div></td>
    <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>SCHEDULE</strong></font></div></td>
    <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>ROOM 
        #</strong></font></div></td>
    <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>NO. 
        OF STUD.</strong></font></div></td>
  </tr>
  <%  for(int i = 0 ; i < vRetResult.size() ; i +=9){%>
  <tr> 
    <td height="20" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
    <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i + 8)%></div></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5),"Not Set")%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%></td>
  </tr>
  <%}%>
</table>

<% }//if vRetResult != null  %>

</body>
</html>
<%
if(!bolIsDBInSession)
	dbOP.cleanUP();
%>