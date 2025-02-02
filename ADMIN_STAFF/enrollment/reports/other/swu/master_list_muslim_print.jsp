<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector,java.util.Calendar,java.text.*,java.util.Date " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<body>
<%
	String strTemp = null;	
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORTS","student_master_list_swu.jsp");
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
														"student_master_list_swu.jsp");
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

Vector vRetResult  = null;
ReportEnrollment reportEnrl = new ReportEnrollment();

vRetResult = reportEnrl.getMasterListSWU(dbOP, request);
if(vRetResult == null)
	strErrMsg = reportEnrl.getErrMsg();	

if(strErrMsg != null){
%>

<div align="center"><%=WI.getStrValue(strErrMsg)%></div>
<%
dbOP.cleanUP();
return;}


String[] strConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
String[] astrConvertYear = {"","First Year","Second Year","Third Year","Fourth Year", "Fifth Year","Sixth Year"};
String strSearchType = WI.fillTextValue("search_type");


if(vRetResult != null && vRetResult.size() > 0){

String strCollegeName = null;
String strCCode = null;
java.sql.ResultSet rs = null;
if(WI.fillTextValue("c_index").length() > 0){
	strTemp = "select c_code, c_name from college where c_index = "+WI.fillTextValue("c_index");
	rs = dbOP.executeQuery(strTemp);
	if(rs.next()){
		strCCode = rs.getString(1);
		strCollegeName = rs.getString(2);
	}rs.close();
}

		 
%>



<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4"><div align="center"><font style="font-size:13px; font-weight:bold;"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
		 Student Master List ( Muslims/Islams )<br>
			<%=strConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> <%=WI.fillTextValue("sy_from")+"-"+(Integer.parseInt(WI.fillTextValue("sy_from"))+1)%><br>
		  Printed Date and Time : <%=WI.getTodaysDateTime()%><br><br><br>&nbsp;
	  </div></td>
    </tr>
	
</table>

<%
int iRowCount = 1;
int iNoOfStudPerPage = 45;

if(WI.fillTextValue("rows_per_pg").length() > 0)
	iNoOfStudPerPage = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
	
	
int iStudCount = 1;
int iPageCount = 1;
int iTotalStud = (vRetResult.size()/18);
int iTotalPageCount = iTotalStud/iNoOfStudPerPage;
if(iTotalStud % iNoOfStudPerPage > 0)
	++iTotalPageCount;
boolean bolPageBreak = false;
for(int i = 0; i < vRetResult.size(); ){
	iRowCount = 1;
	if(bolPageBreak){
		bolPageBreak = false;
		%>
		<div style="page-break-after:always;">&nbsp;</div>
	<%}
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="12%"> College Code</td>
		<td width="85%"> : <%=strCCode%></td>
	</tr>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="12%"> College Name</td>
		<td> : <%=strCollegeName%></td>
	</tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="6%" height="22" align="center" class="thinborderTOPBOTTOM">Seq #</td>
		<td width="11%" class="thinborderTOPBOTTOM">Student No</td>
		<td width="31%" align="center" class="thinborderTOPBOTTOM">Name</td>		
		<td width="8%" class="thinborderTOPBOTTOM">Course</td>
		<td width="4%" align="center" class="thinborderTOPBOTTOM">Year</td>
		<td width="40%" align="center" class="thinborderTOPBOTTOM">Mailing Address/Contact Number</td>		

	</tr>
	
	<%
	for( ; i < vRetResult.size(); i+=18){
	
	%>
	<tr>
		<td align="center"><%=iStudCount++%>.</td>
		<td><%=(String)vRetResult.elementAt(i+1)%></td>
		<%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4);
		%>
		<td><%=strTemp%></td>		
		<td><%=(String)vRetResult.elementAt(i+6)%><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"-","","")%></td>
		<td align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+8))%></td>
		<td>&nbsp; 
		<%=WI.getStrValue((String)vRetResult.elementAt(i+13))%> 
		<%=WI.getStrValue((String)vRetResult.elementAt(i+14))%> 
		<%=WI.getStrValue((String)vRetResult.elementAt(i+15))%>	
		<%=WI.getStrValue((String)vRetResult.elementAt(i+17),", &nbsp; &nbsp;","","")%>
		</td>
	   
	</tr>
	<%
		if(iRowCount++ >= iNoOfStudPerPage){		
			i+=18;
			bolPageBreak = true;
			break;
		}
	}//end of loop
	
	
	
	if(iNoOfStudPerPage > iRowCount){	
		for(int x = iNoOfStudPerPage; x >= iRowCount; x--){%>
	<tr><td colspan="10" height="22">&nbsp;</td></tr>
	<%}
	}%>
	
	<tr><td align="right" colspan="10" height="22">Page <%=iPageCount++%> of <%=iTotalPageCount%></td></tr>
</table>
		
	



<%}%>
	
<script>
		window.print();
	</script>
<%}//end vRetResult%>
	
	



</body>
</html>
<%
dbOP.cleanUP();
%>