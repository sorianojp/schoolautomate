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

-->
</style>
</head>
<body>
<%@ page language="java" import="utility.*,enrollment.StatEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-STATISTICS-ROOMS","statistics_rooms.jsp");
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
														"Enrollment","STATISTICS",request.getRemoteAddr(),
														"statistics_rooms.jsp");
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

Vector vRetResult = new Vector();
StatEnrollment SE = new StatEnrollment();
Vector vOccupiedRoom  = null;
Vector vAvailableRoom = null;
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("offering_sem").length() > 0)
{
	vRetResult = SE.getRoomStat(dbOP,request);
	if(vRetResult == null)
		strErrMsg = SE.getErrMsg();
	else	
	{
		vOccupiedRoom  = (Vector)vRetResult.elementAt(0);
		vAvailableRoom = (Vector)vRetResult.elementAt(1);
	}
}
String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
if(strErrMsg != null){dbOP.cleanUP();
%>
<table width="100%" border="0" >
    <tr>
      <td width="100%"><div align="center"><%=strErrMsg%></div></td>
    </tr>
</table>
<%return;
}%>
  <table width="100%" border="0" >
    <tr>
      <td width="100%"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,true)%></div></td>
    </tr>
    <tr>
      <td height="30"><div align="center"><strong><br>
        ROOMS AVAILABILITY STATISTICS FOR DURATION 
        : <%=request.getParameter("range")%><br>
        </strong>SY (<%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>) 
        <%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> 
      </div></td>
    </tr>
   </table>

<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr  >
    <td height="25" colspan="2"><div align="center"> </div></td>
  </tr>
 </table>
<%
if(vRetResult != null && vRetResult.size() > 0){
String strPrevLocation = null;
String strLocationToDisp = null;
if(vOccupiedRoom != null && vOccupiedRoom.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DBD8C8">
      <td height="20" width="3%">&nbsp;</td>
      <td ><font size="1">ROOM STATUS :<strong> OCCUPIED</strong></font></td>
      <td><div align="right"></div></td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      
    <td width="44%" height="27" align="center"><font size="1"><strong>TYPE</strong></font></td>
    <td width="48%" align="center"><font size="1"><strong>LOCATION</strong></font></td>
      <td width="8%" align="center"><font size="1"><strong>TOTAL </strong></font></td>
    </tr>
<%
for(int i = 1; i< vOccupiedRoom.size();i +=3){
if(strPrevLocation == null || strPrevLocation.compareTo((String)vOccupiedRoom.elementAt(i)) !=0)
{
	strLocationToDisp = (String)vOccupiedRoom.elementAt(i);
	strPrevLocation    = (String)vOccupiedRoom.elementAt(i);
}
else	
	strLocationToDisp = "";
	%>

    <tr> 
      <td height="25"><%=strLocationToDisp%></td>
      <td><%=(String)vOccupiedRoom.elementAt(i+1)%></td>
      <td><%=(String)vOccupiedRoom.elementAt(i+2)%></td>
    </tr>
<%}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="89%" align="right"><strong><font size="1">GRAND 
          TOTAL : &nbsp;&nbsp;&nbsp;</font></strong></td>
      <td><strong><%=(String)vOccupiedRoom.elementAt(0)%> </strong></td>
    </tr>
    <tr>
</table>
<%}//if occupied room is having some value. 
if(vAvailableRoom != null && vAvailableRoom.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DBD8C8">
      <td height="20" width="3%">&nbsp;</td>
      <td ><font size="1">ROOM STATUS :<strong> AVAILABLE</strong></font></td>
      <td><div align="right"></div></td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      
    <td width="44%" height="27" align="center"><font size="1"><strong>TYPE</strong></font></td>
    <td width="48%" align="center"><font size="1"><strong>LOCATION</strong></font></td>
      <td width="8%" align="center"><font size="1"><strong>TOTAL </strong></font></td>
    </tr>
<%
for(int i = 1; i< vAvailableRoom.size();i +=3){
if(strPrevLocation == null || strPrevLocation.compareTo((String)vAvailableRoom.elementAt(i)) !=0)
{
	strLocationToDisp = (String)vAvailableRoom.elementAt(i);
	strPrevLocation    = (String)vAvailableRoom.elementAt(i);
}
else	
	strLocationToDisp = "";
%>

    <tr> 
      <td height="25"><%=strLocationToDisp%></td>
      <td><%=(String)vAvailableRoom.elementAt(i+1)%></td>
      <td><%=(String)vAvailableRoom.elementAt(i+2)%></td>
    </tr>
<%}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="89%" align="right"><strong><font size="1">GRAND 
          TOTAL : &nbsp;&nbsp;&nbsp;</font></strong></td>
      <td><strong><%=(String)vAvailableRoom.elementAt(0)%> </strong></td>
    </tr>
    <tr>
</table>

<%
	}//if vAvailable Room is not null. 	
}//only if vRetResult is not null
%>

<script language="JavaScript">
	window.print();
</script>

</body>
</html>
