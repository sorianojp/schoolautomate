<%
if(request.getSession(false).getAttribute("userIndex") == null) {%>
<p style="font-size:14px; color:red">You are already logged out. Please login again.</p>
<%return;}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td.subheader {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}	

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
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
	font-size: 8px;
    }
    TD.thinborderALL {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
    }
    TD.thinborderLRB {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
    }

-->
</style>
<body onLoad="window.print()">
<%@ page language="java" import="utility.*,enrollment.GraduationDataReport,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
//add security here.

	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Graduates","grad_search_print.jsp");
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
														"Registrar Management","GRADUATES",request.getRemoteAddr(),
														"grad_search_print.jsp");
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

Vector vRetResult = null;
GraduationDataReport gdr = new GraduationDataReport(request);
gdr.defSearchSize = 0;
vRetResult = gdr.viewAllGraduates(dbOP);
if(vRetResult == null) 
	strErrMsg = gdr.getErrMsg();


String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","September","October","November","December"};  

String strCollegeName = null;
if(WI.fillTextValue("c_index").length() > 0)
	strCollegeName = dbOP.getResultOfAQuery("select c_name from college where c_index = "+WI.fillTextValue("c_index"),0);
else if(WI.fillTextValue("course_index").length() > 0) {
	strCollegeName = "select c_name from course_offered join college on (college.c_index = course_offered.c_index) where course_index="+
					WI.fillTextValue("course_index");
	strCollegeName = dbOP.getResultOfAQuery(strCollegeName, 0);
}	

strTemp = "";
if(WI.fillTextValue("month_grad").length() > 0) 
	strTemp = "Month of "+astrConvertMonth[Integer.parseInt(WI.fillTextValue("month_grad"))]+", "+WI.fillTextValue("yr_grad");
		 
else if(WI.fillTextValue("yr_grad").length() > 0)
	strTemp = "Year of "+WI.fillTextValue("yr_grad");

if(strTemp.length() > 0 && WI.fillTextValue("semester").length() > 0) 
	strTemp += ", "+astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))];

if(strTemp.length() > 0) 
	strTemp = "Graduate List for "+strTemp;
%>

<%if(vRetResult !=null && vRetResult.size() > 0) {

int iRowsPerPage = Integer.parseInt(WI.fillTextValue("no_of_rows"));
int iRowCount = vRetResult.size()/21; int iCurPage = 0;

boolean bolShowGradDate   = WI.fillTextValue("show_graddate").equals("1");
boolean bolShowSO         = WI.fillTextValue("show_so").equals("1");
boolean bolShowDOB        = WI.fillTextValue("show_birthdate").equals("1");
boolean bolShowBirthPlace = WI.fillTextValue("show_birthplace").equals("1");
boolean bolShowAddress    = WI.fillTextValue("show_address").equals("1");
boolean bolShowSchool     = WI.fillTextValue("show_hs_grad_fr").equals("1");

int iTotalPages = iRowCount/iRowsPerPage;
if(iRowCount % iRowsPerPage > 0)
	++iTotalPages;

Vector vSummary = null; int iCtr = 0;
if(WI.fillTextValue("get_summary").length() > 0)
	vSummary = (Vector)vRetResult.remove(0);//System.out.println(vRetResult);
vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);//removed total male and female info.. 
for(int i = 0; i < vRetResult.size(); ){
	iRowCount = 0;
if(i > 0){%>
  <DIV style="page-break-before:always" >&nbsp;</DIV>
<%}%>
<table width="100%" border="0" cellspacing="0" cellpadding="2" bgcolor="#FFFFFF">
  <tr> 
    <td height="25" colspan="4" align="center"><strong><%=WI.getStrValue(strCollegeName)%><br><br><%=strTemp%></strong>
	<div align="right" style="font-size:9px;">Page <%=++iCurPage%> of <%=iTotalPages%></div>
	
	</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="2" bgcolor="#FFFFFF" class="thinborder">
  <tr> 
    <td width="3%" class="thinborder" style="font-weight:bold; font-size:9px;">Count</td>
    <td width="12%" height="22" class="thinborder" style="font-weight:bold; font-size:9px;">Student Number</td>
    <td width="15%" class="thinborder" style="font-weight:bold; font-size:9px;">Student Name</td>
    <td width="10%" class="thinborder" style="font-weight:bold; font-size:9px;">Gender</td>
<%if(bolShowGradDate){%>
    <td width="10%" class="thinborder" style="font-weight:bold; font-size:9px;">Graduation Date</td>
<%}if(bolShowSO){%>
    <td width="10%" class="thinborder" style="font-weight:bold; font-size:9px;">SO Number </td>
<%}if(bolShowDOB){%>
    <td width="10%" class="thinborder" style="font-weight:bold; font-size:9px;">Date of Birth </td>
<%}if(bolShowBirthPlace){%>
    <td width="10%" class="thinborder" style="font-weight:bold; font-size:9px;">Birth Place </td>
<%}if(bolShowAddress){%>
    <td width="20%" class="thinborder" style="font-weight:bold; font-size:9px;">Address</td>
<%}if(bolShowSchool){%>
    <td width="8%" class="thinborder" style="font-weight:bold; font-size:9px;">Graduated SCH From </td>
<%}%>
  </tr>
<%
for(; i < vRetResult.size(); i += 21){%>
  <tr> 
    <td class="thinborder"><font size="1"><%=++iCtr%>.</font></td>
    <td height="25" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
    <td class="thinborder"><font size="1">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),(String)vRetResult.elementAt(i+5), 4)%></font></td>
    <td class="thinborder"><font size="1"><%if(vRetResult.elementAt(i+16).equals("0")){%>Male<%}else{%>Female<%}%></font></td>
<%if(bolShowGradDate){%>
    <td class="thinborder" style="font-size:9px;"><%=WI.getStrValue(vRetResult.elementAt(i+10),"&nbsp;")%></td>
<%}if(bolShowSO){%>
    <td class="thinborder" style="font-size:9px;"><%=WI.getStrValue(vRetResult.elementAt(i+8),"&nbsp;")%></td>
<%}if(bolShowDOB){%>
    <td class="thinborder" style="font-size:9px;"><%=WI.getStrValue(vRetResult.elementAt(i+17),"&nbsp;")%></td>
<%}if(bolShowBirthPlace){%>
    <td class="thinborder" style="font-size:9px;"><%=WI.getStrValue(vRetResult.elementAt(i+18),"&nbsp;")%></td>
<%}if(bolShowAddress){%>
    <td class="thinborder" style="font-size:9px;"><%=WI.getStrValue(vRetResult.elementAt(i+19),"&nbsp;")%></td>
<%}if(bolShowSchool){%>
    <td class="thinborder" style="font-size:9px;"><%=WI.getStrValue(vRetResult.elementAt(i+20),"&nbsp;")%></td>
<%}%>
  </tr>
<%++iRowCount;
	if(iRowCount >= iRowsPerPage) {
		i += 21;
		break;
	}
}//end for loop%>
</table>
<%}//end of outside for loop.. %>

<%if(vSummary != null && vSummary.size() > 0) {%>
<u><br>Summary : </u><br>
	<%while(vSummary.size() > 0) {%>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=vSummary.remove(0)%> : <%=vSummary.remove(0)%><br>
	<%}//end of while loop to display summary.
}%>
<br>
<table width="100%" cellpadding="0" cellspacing="0">
 <tr>
	<td style="font-size:9px" width="75%">Prepared By: </td>
	<td style="font-size:9px" width="25%">Certified By:</td>
 </tr>
 <tr>
	<td style="font-size:9px" width="75%"><br><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></td>
	<td style="font-size:9px" width="25%"><br>
	<%=CommonUtil.getNameForAMemberType(dbOP,"University Registrar",7).toUpperCase()%>
	<br>College Registrar</td>
 </tr>
</table>
<%}//show if vRetResult is not null %>

</body>
</html>
<%
dbOP.cleanUP();
%>
