<%@ page language="java" import="utility.*,search.SearchStudent,enrollment.Authentication, java.util.Vector" %>
<%
boolean bolIsSchool = false;
if((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body onLoad="window.print();">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
					"System Administration","User Management",request.getRemoteAddr(),
					null);
}
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
					"eSecurity Check","STUDENTS CAMPUS ATTENDANCE QUERY",request.getRemoteAddr(),
					null);
}
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
					"System Administration","ASSIGN RFID",request.getRemoteAddr(),
					null);
}
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}



int iSearchResult = 0;

SearchStudent searchStud = new SearchStudent(request);
	vRetResult = searchStud.searchBarcode(dbOP);
	if(vRetResult == null)
		strErrMsg = searchStud.getErrMsg();
	else	
		iSearchResult = searchStud.getSearchCount();

if(vRetResult != null && vRetResult.size() > 0){
int iIncr = 7;
if(WI.fillTextValue("sy_from").length() > 0) 
	iIncr = 9;
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td height="25" colspan="2">
			<div align="center"><strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
			<%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
			<br>STUDENTS LIST WITH RFID<br></strong></div>
		</td>
	</tr>
	<tr>
		<td height="19" colspan="2"><hr size="1"></td>
	</tr>
	<tr>
		<td width="51%" height="18" style="font-size:9px;">Total Students :<b> <%=vRetResult.size()/iIncr%></b></td>
		<td width="49%" align="right" style="font-size:9px;">Date &amp; Time Printed : <%=WI.getTodaysDateTime()%></td>
	</tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td  width="5%" style="font-size:9px;" class="thinborder">COUNT</td> 
      <td  width="15%" height="25" class="thinborder"><font size="1">ID</font></td>
      <td width="15%" class="thinborder"><font size="1">RF ID NUMBER </font></td>
      <td width="15%" class="thinborder"><font size="1">LASTNAME</font></td>
      <td width="15%" class="thinborder"><font size="1">FIRSTNAME</font></td>
      <td width="15%" class="thinborder"><font size="1">MIDDLE NAME </font></td>
<%if(iIncr == 9) {%>
	      <td width="10%" class="thinborder"><font size="1">COURSE - YR</font></td>
<%}%>
      <td width="10%" class="thinborder"><font size="1">ASSIGNED DATE</font></td>
    </tr>
<%
Vector vGLevelInfo = new Vector();
strTemp = "select g_level, level_name from bed_level_info";
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
while(rs.next()) {
	vGLevelInfo.addElement(rs.getString(1));
	vGLevelInfo.addElement(rs.getString(2));
}	
rs.close();

	
for(int i=0; i<vRetResult.size(); i+=iIncr){%>
    <tr>
      <td class="thinborder">&nbsp;<%=i/iIncr + 1%></td> 
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+2))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"xxxxxx")%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+5))%></td>
<%if(iIncr == 9){
	strTemp = (String)vRetResult.elementAt(i + 6);
	if(strTemp == null) //basic
		strTemp = (String)vGLevelInfo.elementAt(vGLevelInfo.indexOf(vRetResult.elementAt(i + 7)) + 1);
	else	
		strTemp = strTemp + WI.getStrValue((String)vRetResult.elementAt(i + 7),"-","","");
	%>
	      <td class="thinborder"><%=strTemp%></td>
<%}
if(iIncr == 9)
	strTemp = (String)vRetResult.elementAt(i + 8);
else	
	strTemp = (String)vRetResult.elementAt(i + 6);
%>
      <td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
    </tr>
<%}%>
  </table>
  <%}//vRetResult is not null
%>
</body>
</html>
<%
dbOP.cleanUP();
%>