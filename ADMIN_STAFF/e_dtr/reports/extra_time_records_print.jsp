<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>
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
								"emp_late_timein_records.jsp");
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
														"emp_late_timein_records.jsp");	
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
String[] astrWeekday = {"","S","M","T","W","TH","F","SAT"};
vRetResult = RE.searchExtraTime(dbOP);


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
<table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFE6E6"> 
      <% strTemp = WI.fillTextValue("from_date") + " - " + WI.fillTextValue("to_date"); %>
      <td height="25"  colspan="6" align="center" class="thinborder"><strong>LIST OF EMPLOYEE 
      WITH EXTRA TIME (<%=strTemp%>)</strong></td>
    </tr>
    <tr align="center"> 
      <td width="13%" height="25" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">EMPLOYEE 
        ID</font></strong></td>
      <td width="26%" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">EMPLOYEE NAME</font></strong></td>
      <td width="13%" height="25" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>DATE</strong></font></td>
      <td width="17%" height="25" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>EXPECTED 
        TIME 
        <%if(WI.fillTextValue("logSelect").startsWith("time_in")){%>
        IN 
        <%}else{%>
        OUT 
        <%}%>
        </strong></font></td>
      <td width="17%" height="25" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">ACTUAL 
        TIME 
        <%if(WI.fillTextValue("logSelect").startsWith("time_in")){%>
        IN 
        <%}else{%>
        OUT 
        <%}%>
        </font></strong></td>
      <td width="14%" height="25" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">EXTRA 
        MINUTES</font></strong></td>
    </tr>
    <%  strTemp2 = "";strTemp3 = "";
	for ( int i = 0 ; i< vRetResult.size(); i+=6){ 
	
	strTemp = (String)vRetResult.elementAt(i);
	if (strTemp2.compareTo(strTemp) == 0){
		strTemp = "";
	}else{
		strTemp2 = strTemp;
	}
%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	 <% if (strTemp.length() == 0) strTemp = "&nbsp;";
	    else strTemp = (String)vRetResult.elementAt(i+5);%> 
      <td class="thinborder">&nbsp;<%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+1);
			%>
      <td class="thinborder">&nbsp;<%=strTemp%><%if(WI.fillTextValue("show_weekday").length() > 0){%>
					<%=astrWeekday[eDTR.eDTRUtil.getWeekDay(strTemp)]%>
				<%}%></td></td>
      <td class="thinborder">&nbsp;<%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+2)),2)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+3)),2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%>&nbsp;</td>
    </tr>
    <%} // end for loop%>
  </table>
<%}%>
</body>
</html>
<% dbOP.cleanUP(); %>