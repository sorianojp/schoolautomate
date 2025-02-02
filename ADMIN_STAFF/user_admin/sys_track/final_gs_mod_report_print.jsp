<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Graduation Report Print</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
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
<%@ page language="java" import="utility.*,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-System Tracking","final_gs_mod_report_print.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> Error in opening connection</font></p>
		<%return;
	}	
	
//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","System Tracking",request.getRemoteAddr(),
														null);
	if(iAccessLevel == 0)
		iAccessLevel = iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","Reports",request.getRemoteAddr(),
														null);
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
	
	int iSearchResult = 0;	
	int iCount = 0;	
	
	Vector vRetResult = null;
	SysTrack ST = new SysTrack(request);
	
	vRetResult = ST.getGradeModificationReport(dbOP,request);
	if(vRetResult == null)
		strErrMsg = ST.getErrMsg();	
	else	
		iSearchResult = ST.getSearchCount();

	
	int iRowsPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_pg"),"40"));
	int iNameFormat = Integer.parseInt(WI.getStrValue(WI.fillTextValue("name_format"),"4"));
	
	String[] astrSemester = {"Summer","1st Semester","2nd Semester","3rd Semester"};
	
	String strDateTime = WI.getTodaysDateTime();

if(vRetResult != null && vRetResult.size() > 0)	

	for(int i = 0; i< vRetResult.size();) { 
		if(i > 0) {%>
			<DIV style="page-break-before:always">&nbsp;</DIV>
		<%}%>
		
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td height="25" colspan="2">
			<div align="center"><strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
			<%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
			<br>GRADE(S) MODIFICATION REPORT
			<%if(WI.fillTextValue("sy_from").length() > 0) {%> <br> 
			<%=astrSemester[Integer.parseInt(WI.fillTextValue("semester"))] + ", "+
			WI.fillTextValue("sy_from") +" - "+WI.fillTextValue("sy_to")%>
			<%}%><br></strong></div>
		</td>
	</tr>
	<tr>
		<td height="19" colspan="2"><hr size="1"></td>
	</tr>
	<tr>
		<td width="51%" height="18"></td>
		<td width="49%" height="18" align="right" style="font-size:9px;">Date &amp; Time Printed : <%=strDateTime%></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr style="font-weight:bold;" align="center">
      <td width="5%" class="thinborder"><font size="1">COUNT</font></td>
      <td width="20%" class="thinborder"><font size="1">NAME</font></td>
      <td width="5%" style="font-size:9px;" class="thinborder">SY-TERM</td>
      <td width="5%" class="thinborder"><font size="1">COURSE</font></td>
	  <td width="10%" class="thinborder"><font size="1">SUBJECT</font></td>
	  <td width="20%" class="thinborder"><font size="1">GRADE MODIFICATION DETAIL </font></td>
      <td width="5%" class="thinborder"><font size="1">CREDIT UNITS</font></td>
      <td width="5%" class="thinborder"><font size="1">CURRENT GRADE</font></td>
      <td width="25%" class="thinborder"><font size="1">REASON(S)</font></td>
    </tr>

	<%for(; i < vRetResult.size() ; i+=15) {
	%>
    <tr>
      <td class="thinborder"><font size="1"><%=++iCount%>)</font></td>
      <td class="thinborder"><font size="1"><%=WebInterface.formatName((String)vRetResult.elementAt(i+1),(String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),iNameFormat)%></font></td>
      <td style="font-size:9px;" class="thinborder"><%=(String)vRetResult.elementAt(i+13)%> - <%=(String)vRetResult.elementAt(i+14)%></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+4))%><%=WI.getStrValue((String)vRetResult.elementAt(i+5), " - ", "","")%></font></td>
	  <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+9)%> </font></td>
	  <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+6)%> </font></td>
	  <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+8)%></font></td>
      <td style="font-size:9px;" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+11), (String)vRetResult.elementAt(i+12))%></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+7))%></font></td>
    </tr>
	<%
		if(i > 0 && ((i+15)/15) % iRowsPerPage == 0) {
			i += 15;
			break;
		}

	}//end of inner vRetResult loop%>  
</table>
<%}//end of outer vRetResult loop.%>
</body>
</html>
<% dbOP.cleanUP();%>
