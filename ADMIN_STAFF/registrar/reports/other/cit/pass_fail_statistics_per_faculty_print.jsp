<%@ page language="java" import="utility.*,java.util.Vector,enrollment.ReportRegistrar" %>
<%
	WebInterface WI = new WebInterface(request);
	String strCIndex = WI.getStrValue((String) request.getSession(false).getAttribute("info_faculty_basic.c_index"));
	String strDIndex = WI.getStrValue((String) request.getSession(false).getAttribute("info_faculty_basic.d_index"));
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Teller</title>
</head>
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head><style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }
-->
</style>

<body>
<%
	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp   = null;
    //add security here.

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Other report","pass_fail_statistics.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();%>
        <p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%return;
	}
	
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admin/staff-Registrar Management","REPORTS",request.getRemoteAddr(),
														"pass_fail_statistics.jsp");

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
	
	
	
String[] astrConvertSem = {"Summer", "First Semester", "Second Semester", "Third Semester"};
String strCollegeName = null;	
if(strCIndex.length() >0){
	strTemp =" select c_name from COLLEGE where C_INDEX ="+strCIndex;
	strCollegeName = dbOP.getResultOfAQuery(strTemp, 0);
}
		
Vector vRetResult = null;
Vector vRetSubject = null;

enrollment.FacultyManagement FM = new enrollment.FacultyManagement();

String[] astrSemester={"Summer", "First Semester", "Second Semester","Third Semester"};

ReportRegistrar RR = new ReportRegistrar();

String strFacultyIndex = WI.fillTextValue("faculty");

		
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="header">
	<tr><td align="center">
		<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
		<%=WI.getStrValue(SchoolInformation.getAddressLine1(dbOP,true,false),"&nbsp;")%>
	</td></tr>
	<tr>
		<td height="25" align="center">PASS-FAIL STATISTICS FOR <%=WI.getStrValue(WI.getStrValue(strCollegeName).toUpperCase(),"&nbsp;")%><br>
			S.Y. <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%> <%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>
		</td>
	</tr>
</table>





<%



Vector vFacultyIndex = new Vector();	
if(strFacultyIndex.length() == 0){
	String strFacultyList = " from INFO_FACULTY_BASIC "
			+ " join USER_TABLE on "
			+ " (USER_TABLE.USER_INDEX = INFO_FACULTY_BASIC.USER_INDEX) " 
			+ " where INFO_FACULTY_BASIC.IS_VALID =1 "
			+ " and INFO_FACULTY_BASIC.IS_DEL= 0  "
			+ " and exists(select * from FACULTY_LOAD "
			+ " where IS_VALID = 1 and USER_INDEX= INFO_FACULTY_BASIC.USER_INDEX) ";
	if(strDIndex.length()>0)
		strFacultyList += " and D_INDEX= " +strDIndex;	  
	else
		strFacultyList += " and D_INDEX= " +request.getParameter("department");
	
	strFacultyList +=" order by lname";
	strTemp = "select INFO_FACULTY_BASIC.USER_INDEX "+strFacultyList;
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next())
		vFacultyIndex.addElement(rs.getString(1));
	rs.close();

}else
	vFacultyIndex.addElement(strFacultyIndex);
	

	
	
		

while(vFacultyIndex.size() > 0){
	strFacultyIndex = (String)vFacultyIndex.remove(0);
	
	
	strTemp = " and user_table.user_index = "+strFacultyIndex;
	
	vRetResult = FM.viewFacBasicWithLoadStat(dbOP, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("semester"),strTemp);
	if(vRetResult == null)
		strErrMsg = RR.getErrMsg();
	
	vRetSubject = RR.getPassFailPerFaculty(dbOP, request, strFacultyIndex);
	if(vRetSubject == null)
		strErrMsg = RR.getErrMsg();



if(vRetResult!= null && vRetResult.size()>0){

double dTemp = 0d;
osaGuidance.GDPsychologicalTestReport gdRpt = new osaGuidance.GDPsychologicalTestReport();
%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="6%" height="25">&nbsp;</td>
		<td width="17%">Name:</td>
		<td width="77%"><%=WI.getStrValue((String)vRetResult.elementAt(2),"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Total Load:</td>
		<td><%=WI.getStrValue((String)vRetResult.elementAt(6),"0")%></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>College/Department:</td>
		<td><%=WI.getStrValue((String)vRetResult.elementAt(5),"0")%></td>
	</tr>
</table>
<%if(vRetSubject != null && vRetSubject.size() > 0){%>

<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
   <tr>
		<td height="25" colspan="8" align="center" style="font-weight:bold; " class="thinborder">
		:::: FACULTY PASS-FAIL STATISTICS ::::</td>
   </tr>  
   <tr>
		<td width="13%" rowspan="2" align="center" class="thinborder"><strong>Subject Code</strong></td>
		<td width="37%" rowspan="2" align="center" class="thinborder"><strong>Subject Title</strong></td>
		<td width="22%" rowspan="2" align="center" class="thinborder"><strong>Section</strong></td>	
		<td width="8%" rowspan="2" align="center" class="thinborder"><strong>Class size</strong></td>
		<td height="25" colspan="2" align="center" class="thinborder"><strong>Pass</strong></td>
		<td colspan="2" align="center" class="thinborder"><strong>Fail</strong></td>
   </tr>
   <tr>
       <td width="5%" height="25" align="center" class="thinborder"><strong>Count</strong></td>
       <td width="5%" align="center" class="thinborder"><strong>%age</strong></td>
       <td width="5%" align="center" class="thinborder"><strong>Count</strong></td>
       <td width="5%" align="center" class="thinborder"><strong>%age</strong></td>
   </tr>
   <%for(int i=0; i<vRetSubject.size(); i+=10){%>
   <tr>
	   <td class="thinborder" height="25"><%=WI.getStrValue((String)vRetSubject.elementAt(i+1),"&nbsp;")%></td>   
	   <td class="thinborder"><%=WI.getStrValue((String)vRetSubject.elementAt(i+2),"&nbsp;")%></td>   
	   <td class="thinborder"><%=WI.getStrValue((String)vRetSubject.elementAt(i+3),"&nbsp;")%></td>   
	   <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetSubject.elementAt(i+4),"0")%></td>
	   <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetSubject.elementAt(i+5),"0")%></td>
	   <%
	   
	   strTemp = WI.getStrValue((String)vRetSubject.elementAt(i+4),"0");
	   strErrMsg =WI.getStrValue((String)vRetSubject.elementAt(i+5),"0");
	   
	   dTemp = gdRpt.getPercentage( Double.parseDouble(strErrMsg),  Double.parseDouble(strTemp), 100);
	   %>
	   <td class="thinborder" align="center"><%=CommonUtil.formatFloat(dTemp, 1)%></td>
	   <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetSubject.elementAt(i+6),"0")%></td>
	   <%
	   
	   strTemp = WI.getStrValue((String)vRetSubject.elementAt(i+4),"0");
	   strErrMsg =WI.getStrValue((String)vRetSubject.elementAt(i+6),"0");
	   
	   dTemp = gdRpt.getPercentage( Double.parseDouble(strErrMsg),  Double.parseDouble(strTemp), 100);
	   %>
       <td class="thinborder" align="center"><%=CommonUtil.formatFloat(dTemp, 1)%></td>
   </tr>
   <%}//end of vRetSubject%>
</table>
<%}
}//end of vRetResult!= null && vRetResult.size()>0 && vRetSubject!=null && vRetSubject.size()>0 

}//end while


%>  


</body>
</html>
<%
dbOP.cleanUP();
%>
