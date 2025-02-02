<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
	font-size: 9px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderbottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

-->
</style>
</head>
<body>
<%@ page language="java" import="utility.*,iCafe.ComputerUsage,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Internet Cafe Management-USAGE DETAILS -user usage detail",
								"iL_usage_users_dtls.jsp");
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
														"Internet Cafe Management",
														"USAGE DETAILS",request.getRemoteAddr(),
														"iL_usage_users_dtls.jsp");
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
ComputerUsage compUsage = new ComputerUsage();
iCafe.TimeInTimeOut tinTout = new iCafe.TimeInTimeOut();
enrollment.EnrlAddDropSubject addDropSub = new enrollment.EnrlAddDropSubject();

Vector vRetResult = null;
Vector vStudInfo = null;
long lBalanceUsage = 0l;
boolean bolShowAttendant = false;

boolean bolIsStaff = false;
	 
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("semester").length() > 0 &&
	WI.fillTextValue("stud_id").length() > 0) {
	
	vStudInfo = addDropSub.getEnrolledStudInfo(dbOP,null, WI.fillTextValue("stud_id"), WI.fillTextValue("sy_from"), 
					 WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
	if(vStudInfo == null || vStudInfo.size() == 0) {
		//may be faculty.
		request.setAttribute("emp_id",WI.fillTextValue("stud_id"));
		vStudInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
		if(vStudInfo != null)
			bolIsStaff = true; 
	}
	if(vStudInfo == null || vStudInfo.size() == 0)
		strErrMsg = addDropSub.getErrMsg();
}
if (WI.fillTextValue("show_attendant").length() != 0){
	bolShowAttendant = true;
	strTemp = " colspan = 6";
}else{
	strTemp = " colspan = 5";
}
if(vStudInfo != null && vStudInfo.size() > 0) {
	vRetResult = compUsage.getComputerUsageDetailPerUser(dbOP, WI.fillTextValue("stud_id"),
		WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("semester"),
		WI.fillTextValue("date_from"), WI.fillTextValue("date_to"));
	if(vRetResult == null || vRetResult.size() == 0)
		strErrMsg = compUsage.getErrMsg();	
}

if(vStudInfo != null && vStudInfo.size() > 0){
	if(bolIsStaff)
		lBalanceUsage = 99999;
	else	
		lBalanceUsage = tinTout.getInternetBalanceUsage(dbOP, (String)vStudInfo.elementAt(0), 
						WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
	
	if(lBalanceUsage == tinTout.lErrorVal) {
		strErrMsg = tinTout.getErrMsg();
		vRetResult = null;
	}
}
 
//end of authenticaion code.
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="66%" height="25">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
      <td width="34%"><strong>
        <div align="right"><font size="1"><strong>Date / Time :</strong> <%=WI.getTodaysDateTime()%></font></div>
        </strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="17%" height="25">Student ID : <strong></strong></td>
      <td><b><%=WI.fillTextValue("stud_id")%></b></td>
    </tr>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Student Name</td>
      <td><%=WebInterface.formatName((String)vStudInfo.elementAt(10),
	  					(String)vStudInfo.elementAt(11),(String)vStudInfo.elementAt(12),4)%></td>
    </tr>
    <tr> 
      <td width="4%">&nbsp;</td>
      <td height="25">Course / Major</td>
      <td><%=(String)vStudInfo.elementAt(2)%><%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Year Level</td>
      <td height="25"><%=WI.getStrValue((String)vStudInfo.elementAt(4),"N/A")%></td>
    </tr>
  </table>
 <%}
 if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="4%" height="15">&nbsp;</td>
      <td height="15" colspan="2">TOTAL HOURS REMAINING : 
	<% if(lBalanceUsage == 99999){%>
        <strong><font color="#0000FF">Unlimited</font></strong> 
	  <%} else if (lBalanceUsage < 0){
	  	lBalanceUsage *= -1l;%>
	  	<strong><font color="#FF0000"><%=ConversionTable.convertMinToHHMM((int)lBalanceUsage)%> excess usage</font></strong>
	<%}else{%>
		<strong><%=ConversionTable.convertMinToHHMM((int)lBalanceUsage)%></strong> 		
	<%}%>		
		</td>
    </tr>
  </table>	  
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr bgcolor="#FFFF9F"> 
    <td height="24" colspan="8" class="thinborder"><div align="center"><font color="#0000FF"><strong>USAGE 
        DETAILS </strong></font></div></td>
  </tr>
  <tr> 
    <td width="9%" height="25" align="center" class="thinborder"><strong>DATE</strong></td>
    <td width="11%" align="center" class="thinborder"><strong>LOGIN TIME</strong></td>
    <td width="11%" align="center" class="thinborder"><strong>LOGOUT TIME</strong></td>
    <td width="17%" align="center" class="thinborder"><strong>COMPUTER NAME</strong></td>
    <td width="17%" align="center" class="thinborder"><strong>LOCATION</strong></td>
<% if (bolShowAttendant){%>
    <td width="19%" align="center" class="thinborder"><strong>ATTENDANT</strong></td>
<%}%>
    <!--      <td width="23%" align="center"><font size="1"><strong>OTHER SERVICES REQUESTED</strong></font></td>
-->
    <td width="16%" align="center" class="thinborder"><strong>TOTAL HOURS USED</strong></td>
  </tr>
  <%
for(int i = 1; i < vRetResult.size(); i += 11 ){%>
  <tr> 
    <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+5),"Not Assigned")%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
<% if (bolShowAttendant){%>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+9)%></td>
<%}%>
    <!--      <td class="thinborder"><font size="1">$sub_type_name - $cost</font></td>-->
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
  </tr>
  <%}%>
  <tr> 
    <td height="25" align="right" class="thinborder" <%=strTemp%>><strong><font size="1">GRAND TOTAL</font></strong> 
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td class="thinborderbottom">&nbsp;<%=(String)vRetResult.elementAt(0)%></td>
  </tr>
</table>
<script language="JavaScript">
window.print();
</script>  
 <%}//end of displaying if vRetResult <> null%>
 
</body>
</html>
<%
dbOP.cleanUP();
%>