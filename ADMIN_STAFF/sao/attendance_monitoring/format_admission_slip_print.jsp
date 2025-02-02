<%@ page language="java" import="utility.*, enrollment.AttendanceMonitoringCDD, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
body{
	font-family:Verdana, Geneva, sans-serif;
	font-size:12pt;
	margin:0in 1.5in 0in 1.5in;
}



</style>
</head>
<body>
<%
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("STUDENT AFFAIRS-STUDENT TRACKER"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("STUDENT AFFAIRS"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"STUDENT AFFAIRS-STUDENT TRACKER","attendance_monitoring.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	


AttendanceMonitoringCDD attendanceCDD = new AttendanceMonitoringCDD();
String strAttendanceIndex = WI.fillTextValue("attendance_index");

Vector vRetResult = attendanceCDD.getInfoForAdmissionSlip(dbOP, strAttendanceIndex);

if(strErrMsg != null){
%>
<div><font color="#FF0000"><strong><%=strErrMsg%></strong></font></div>


<%}if(vRetResult != null && vRetResult.size() > 0){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="25" colspan="3" align="center"><strong>PERMIT TO ENTER CLASS</strong></td></tr>
	<tr>
	    <td width="25%" height="25" valign="bottom">Date</td>
        <td width="2%" valign="bottom">:</td>
        <td width="73%" class="thinborderBOTTOM" valign="bottom"><%=vRetResult.elementAt(0)%></td>
	</tr>
	<tr>
	    <td valign="bottom" height="25">Name</td>
	    <td valign="bottom">:</td>
		<%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(2), (String)vRetResult.elementAt(3), (String)vRetResult.elementAt(4), 4);
		%>
	    <td class="thinborderBOTTOM" valign="bottom"><%=strTemp%></td>
    </tr>
	<tr>
	    <td valign="bottom" height="25">ID Number</td>
	    <td valign="bottom">:</td>
	    <td class="thinborderBOTTOM" valign="bottom"><%=(String)vRetResult.elementAt(1)%></td>
    </tr>
	<tr>
	    <td valign="bottom" height="25">Course/Yr</td>
	    <td valign="bottom">:</td>
		<%
		strTemp = (String)vRetResult.elementAt(5) + WI.getStrValue((String)vRetResult.elementAt(6)," - ","","")+ WI.getStrValue((String)vRetResult.elementAt(7)," / ","","");

		%>
	    <td class="thinborderBOTTOM" valign="bottom"><%=strTemp%></td>
    </tr>
	<tr>
	    <td valign="bottom" height="25">Subject</td>
	    <td valign="bottom">:</td>
	    <td class="thinborderBOTTOM" valign="bottom"><%=(String)vRetResult.elementAt(9)%></td>
    </tr>
	<tr>
	    <td valign="bottom" height="25">Total # of Hour(s)</td>
	    <td valign="bottom">:</td>
	    <td class="thinborderBOTTOM" valign="bottom"><%=(String)vRetResult.elementAt(15)%></td>
    </tr>
	<tr>
	    <td valign="bottom" height="25">Instructor</td>
	    <td valign="bottom">:</td>
		<%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(11), (String)vRetResult.elementAt(12), (String)vRetResult.elementAt(13), 4);
		%>
	    <td class="thinborderBOTTOM" valign="bottom"><%=strTemp%></td>
    </tr>
	<tr>
	    <td height="25" colspan="3"></td>
    </tr>
	<tr>
	    <td height="25" colspan="3" valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; width:60%"></div></td>
    </tr>
	<tr>
	    <td valign="top" colspan="3" align="center">Signature</td>
    </tr>
</table>
<script>window.print();window.close();</script>
<%}%>

  

</body>
</html>
<%
dbOP.cleanUP();
%>
