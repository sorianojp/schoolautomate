<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Student Report Print</title>
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
<%@ page language="java" import="utility.*,enrollment.OverideParameter,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try{
		dbOP = new DBOperation();
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> Error in opening connection</font></p>
		<%return;
	}	
	
//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","Override Parameters",request.getRemoteAddr(),
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
	int iCount = 0;	
	OverideParameter OP = new OverideParameter();
	
	Vector vRetResult = null;
	vRetResult = OP.getStudentWithOverloadReport(dbOP,request);
		if(vRetResult == null)
			strErrMsg = OP.getErrMsg();
	
	int iRowsPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_pg"),"40"));	
	String[] astrSemester = {"Summer","1st Semester","2nd Semester","3rd Semester"};
	
	boolean bolPageBreak = false;
    if(vRetResult != null && vRetResult.size() > 0)	
		for(int i = 0; i< vRetResult.size();) { 
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td height="25" colspan="2">
			<div align="center"><strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
			<%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
			<br>
			STUDENT OVERLOAD REPORT
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
		<td width="51%" height="18">Total Students :<b> <%=vRetResult.size()/9%></b></td>
		<td width="49%" height="18" align="right">Date &amp; Time Printed : <%=WI.getTodaysDateTime()%> &nbsp;&nbsp;</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr>
		<td height="25" width="4%" class="thinborder" align="center"><strong><font size="1">SL #</font></strong></td>
		<td width="25%" class="thinborder" align="center"><strong><font size="1">NAME OF STUDENT</font></strong></td>
		<td width="12%" class="thinborder" align="center"><strong><font size="1">COURSE/YEAR</font></strong></td>
		<td width="11%" class="thinborder" align="center"><strong><font size="1">MAX. UNITS ALLOWED</font></strong></td>
		<td width="11%" class="thinborder" align="center"><strong><font size="1">OVERLAOD UNITS</font></strong></td>
		<td width="11%" class="thinborder" align="center"><strong><font size="1">NEW TOTAL MAX UNITS ALLOWED</font></strong></td>
		<td width="16%" class="thinborder" align="center"><strong><font size="1">APPROVED BY</font></strong></td>	
				<td width="10%" class="thinborder" align="center"><strong><font size="1">APPROVED DATE</font></strong></td>		
	</tr>	
	<%for(;i<vRetResult.size() ; i+=9){%>
	<tr>
	  <td class="thinborder"><font size="1"><%=++iCount%>)</font></td>
      <td height="25"  class="thinborder"><font size="1">
	  <%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td  class="thinborder">
	  <font size="1"><%=(String)vRetResult.elementAt(i+2)%> - <%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),""," units","")%> </font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),""," units","")%> </font></td>
	  <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),""," units","")%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+7))%></font></td>
      <td class="thinborder" width="10%"><font size="1"><%=(String)vRetResult.elementAt(i+8)%></font> </td>
	</tr>	
	<%   if(i/9 > 10 && ((i+9)/9)%iRowsPerPage == 0) {
			i += 9;
			bolPageBreak = true;
			break;
		 } 
	}//end of inner vRetResult loop%>  
</table>
	<%if(bolPageBreak){%>
		<DIV style="page-break-before:always">&nbsp;</DIV>
	<%}//break only if it is not last page.%>
<%}//end of outer vRetResult loop.%>
</body>
</html>
<% dbOP.cleanUP();%>
