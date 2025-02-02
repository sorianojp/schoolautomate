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
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

-->
</style>
</head>
<body onLoad="javascript:window.print();">
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	String strTemp2 = null;
	String strTemp3 = null;
	String strTemp4 = null;
	int iSearchResult =0;
	int iPageCount = 0;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Employees with Late Time-in Record",
								"undertime_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"undertime_print.jsp");	
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

ReportEDTR RE = new ReportEDTR(request);

vRetResult = RE.searchLateTimeIn(dbOP);


 if (vRetResult !=null && vRetResult.size()>0){
              strTemp = WI.fillTextValue("from_date") + " - " + WI.fillTextValue("to_date"); 
  %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
  <td><br>
	<div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
	  <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br><br>
	</div>
	</td>
  </tr>
 </table>
<table width="100%" border="1" cellpadding="3" cellspacing="0">
  <tr> 
    <% strTemp = WI.fillTextValue("from_date") + " - " + WI.fillTextValue("to_date"); %>
    <td height="25"  colspan="5"><div align="center"><font color="#000000" size="2"><strong>SUMMARY 
        OF EMPLOYEES WITH UNDERTIME (<%=strTemp%>)</strong></font></div></td>
  </tr>
  <tr> 
    <td height="30" colspan="5" bgcolor="#FFFFFF">TOTAL : </td>
  </tr>
  <tr> 
    <td width="11%" height="30" bgcolor="#EBEBEB"><div align="center"><strong><font size="1">EMPLOYEE 
        ID</font></strong></div></td>
    <td width="27%" height="30" bgcolor="#EBEBEB"><div align="center"><font size="1"><strong>EMPLOYEE 
        NAME </strong></font></div></td>
    <td width="31%" height="30" bgcolor="#EBEBEB"><div align="center"><font size="1"><strong>DEPT/OFFICE</strong></font></div></td>
    <td width="15%" bgcolor="#EBEBEB"><div align="center"><strong><font size="1">EMPLOYMENT 
        TYPE </font></strong></div></td>
    <td width="8%" height="30" bgcolor="#EBEBEB"><div align="center"><strong><font size="1">TOTAL 
        MINUTES </font></strong></div></td>
  </tr>
  <%  strTemp2 = "";
	for ( int i = 0 ; i< vRetResult.size(); i+=5){ 
	
	strTemp = (String)vRetResult.elementAt(i);
	if (strTemp2.compareTo(strTemp) == 0){
		strTemp = "&nbsp;";
	}else{
		strTemp2 = strTemp;
	}
%>
  <tr> 
    <td><%=strTemp%>&nbsp;</td>
    <td><%=(String)vRetResult.elementAt(i+1)%>&nbsp;</td>
    <td><%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+2)),2)%>&nbsp;</td>
    <td><%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+3)),2)%>&nbsp;</td>
    <td><%=(String)vRetResult.elementAt(i+4)%> &nbsp;</td>
  </tr>
  <%} // end for loop%>
</table>
<%}%>
</body>
</html>
<% dbOP.cleanUP(); %>