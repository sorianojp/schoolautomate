<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<style type="text/css">
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
		border-top: solid 1px #000;
		border-right: solid 1px #000;
		font-family:Verdana, Arial, Helvetica, sans-serif;	
		font-size: 11px;
	}
	
	TD.thinborder{
		border-left: solid 1px #000;
		border-bottom: solid 1px #000;
		font-family:Verdana, Arial, Helvetica, sans-serif;	
		font-size: 11px;
	}
	
	TD.thinborderBOTTOM{
		border-bottom: solid 1px #000;
		font-family:Verdana, Arial, Helvetica, sans-serif;	
		font-size: 11px;
	}
</style>
<body>
<%@ page language="java" import="utility.*,enrollment.FacultyManagementExtn,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
//add security here.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-REPORTS"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation();
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

//end of authenticaion code.
FacultyManagementExtn facultyMgmt = new FacultyManagementExtn();

Vector vRetResult = null;



vRetResult = facultyMgmt.getRoomAssignmentForFacultyAttendance(dbOP, request);
if(vRetResult == null)
	strErrMsg = facultyMgmt.getErrMsg();



String[] astrTime12     = {"4","5","6","7","8","9","10","11","12","1","2","3","4","5","6","7",
								"8","9","10","11"};				

String[] astrDay = {"SUNDAY","MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY"};
String[] astrMinDisplay = {":00", ":30"};
String[] astrAMPM = {"AM", "PM", "NN"};


if(vRetResult != null && vRetResult.size() > 0 && strErrMsg == null){
	Vector vTime = (Vector)vRetResult.remove(0);
	
String strTimeFrom = null;
String strTimeTo = null;

String strTimeFrom24 = null;
String strTimeTo24 = null;	
String strSection = null;


Vector vTemp = new Vector();

for(int i = 0; i < vTime.size(); i += 2){
	
	strTimeFrom = (String)vTime.elementAt(i);
	strTimeTo = (String)vTime.elementAt(i+1);
	
	for(int x = 0; x < vRetResult.size(); x += 21){			
			if( !((String)vRetResult.elementAt(x + 16)).equals(strTimeFrom) && !((String)vRetResult.elementAt(x + 17)).equals(strTimeTo)  )
				continue;
			
		 vTemp.addElement((String)vRetResult.elementAt(x));//[0]sub_sec_index
		 vTemp.addElement((String)vRetResult.elementAt(x + 1));//[1]room_index
		 vTemp.addElement((String)vRetResult.elementAt(x + 2));//[2]room_number
		 vTemp.addElement((String)vRetResult.elementAt(x + 3));//[3]room_type
		 vTemp.addElement((String)vRetResult.elementAt(x + 4));//[4]floor
		 vTemp.addElement((String)vRetResult.elementAt(x + 5));//[5]description
		 vTemp.addElement((String)vRetResult.elementAt(x + 6));//[6]status_remark
		 vTemp.addElement((String)vRetResult.elementAt(x + 7));//[7]total_cap
		 vTemp.addElement((String)vRetResult.elementAt(x + 8));//[8]location
		 vTemp.addElement((String)vRetResult.elementAt(x + 9));//[9]is_lec
		 vTemp.addElement((String)vRetResult.elementAt(x + 10));//[10]hour_from_24
		 vTemp.addElement((String)vRetResult.elementAt(x + 11));//[11]hour_to_24
		 vTemp.addElement((String)vRetResult.elementAt(x + 12));//[12]fname
		 vTemp.addElement((String)vRetResult.elementAt(x + 13));//[13]mname
		 vTemp.addElement((String)vRetResult.elementAt(x + 14));//[14]lname
		 vTemp.addElement((String)vRetResult.elementAt(x + 15));//[15]section
		 vTemp.addElement(strTimeFrom);//[16]
		 vTemp.addElement(strTimeTo);//[17]
		 vTemp.addElement(null);
		 vTemp.addElement(null);
		 vTemp.addElement(null);
	}
}

boolean bolPageBreak = false;
	
	
int iRowCount = 0;
int iMaxRowCount = 25;
	
int x = 0;
for(int i = 0; i < vTime.size(); i += 2){
	strTimeFrom = (String)vTime.elementAt(i);
	strTimeTo = (String)vTime.elementAt(i+1);
	
	
	if(bolPageBreak){
		bolPageBreak = false;
	%>
   <div style="page-break-after:always;">&nbsp;</div>
   <%}%>
   
<%
while(vTemp.size() > 0){
	
	
		if( !((String)vTemp.elementAt(x + 16)).equals(strTimeFrom) && !((String)vTemp.elementAt(x + 17)).equals(strTimeTo)  ){
			iRowCount = 0;
			bolPageBreak = true;			
			break;
		}
	if(bolPageBreak){
		bolPageBreak = false;
	%>
   <div style="page-break-after:always;">&nbsp;</div>
   <%}
		
%>
   
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   
   <tr><td colspan="13" align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
   	<strong>ATTENDANCE REPORT</strong></font>
   </td></tr>
   	
   <tr>
   <%
	strTemp = strTimeFrom.substring(strTimeFrom.indexOf(".") + 1);
	if(!strTemp.equals("0"))
		strTemp = "1";
		
	strTemp = astrTime12[Integer.parseInt(strTimeFrom.substring(0,strTimeFrom.indexOf("."))) - 4] + astrMinDisplay[Integer.parseInt(strTemp)];	
	
	strErrMsg = strTimeTo.substring(strTimeTo.indexOf(".") + 1);
	if(!strErrMsg.equals("0"))
		strErrMsg = "1";
	
	strErrMsg = astrTime12[Integer.parseInt(strTimeTo.substring(0,strTimeTo.indexOf("."))) - 4] + astrMinDisplay[Integer.parseInt(strErrMsg)];
	
	if(Integer.parseInt(strTimeTo.substring(0,strTimeTo.indexOf("."))) < 12)
		strErrMsg += " " + astrAMPM[0];
	else if(Integer.parseInt(strTimeTo.substring(0,strTimeTo.indexOf("."))) == 12)
		strErrMsg += " " + astrAMPM[2];
	else if(Integer.parseInt(strTimeTo.substring(0,strTimeTo.indexOf("."))) > 12)
		strErrMsg += " " + astrAMPM[1];
	
	%>
   	<td colspan="13" height="30" valign="bottom" align="center">
      	<font size="2"><strong><%=astrDay[Integer.parseInt(WI.fillTextValue("date"))]%> <%=strTemp + " - " + strErrMsg%></strong></font>
      	&nbsp; &nbsp; &nbsp; &nbsp; Date : ______________________
         &nbsp; &nbsp; &nbsp; &nbsp; Checker : ______________________
      </td>
   </tr>
   
   <tr>
   	<td width="5%" height="18">&nbsp;<strong>ROOM</strong></td>
      <td width="19%" align="center"><strong>TEACHER</strong></td>
      <td width="4%" align="center">PRESENT</td>
      <td width="8%" align="center">TARDY</td>
      <td width="8%" align="center">TIME VERIFIED</td>
      <td width="4%" align="center">ABSENT</td>
      <td width="2%">&nbsp;</td>
      <td width="5%" height="18">&nbsp;<strong>ROOM</strong></td>
      <td width="19%" align="center"><strong>TEACHER</strong></td>
      <td width="4%" align="center">PRESENT</td>
      <td width="8%" align="center">TARDY</td>
      <td width="8%" align="center">TIME VERIFIED</td>
      <td width="4%" align="center">ABSENT</td>
   </tr>
   
   
   <%
	
		while(vTemp.size() > 0){
			if( !((String)vTemp.elementAt(x + 16)).equals(strTimeFrom) && !((String)vTemp.elementAt(x + 17)).equals(strTimeTo)  ){
				iRowCount = 0;
				bolPageBreak = true;			
				break;
			}
		iRowCount++;
		
		%>
   <tr>
   	<%
		vTemp.remove(x);//sub_sec_index
		vTemp.remove(x);//room_index
		%>
   	<td><%=(String)vTemp.remove(x)%></td>
      <%
		
		vTemp.remove(x);//room_type
		vTemp.remove(x);//floor
		vTemp.remove(x);//description
		vTemp.remove(x);//status_remakr
		vTemp.remove(x);//total_cap
		vTemp.remove(x);//location
		vTemp.remove(x);//is_lec
		
		strTimeFrom24 = (String)vTemp.remove(x);
		strTimeTo24 = (String)vTemp.remove(x);
		
		
		strTemp = strTimeFrom24.substring(strTimeFrom24.indexOf(".") + 1);
		if(!strTemp.equals("0"))
			strTemp = "1";
			
		strTemp = astrTime12[Integer.parseInt(strTimeFrom24.substring(0,strTimeFrom24.indexOf("."))) - 4] + astrMinDisplay[Integer.parseInt(strTemp)];	
		
		strErrMsg = strTimeTo24.substring(strTimeTo24.indexOf(".") + 1);
		if(!strErrMsg.equals("0"))
			strErrMsg = "1";
		
		strErrMsg = astrTime12[Integer.parseInt(strTimeTo24.substring(0,strTimeTo24.indexOf("."))) - 4] + astrMinDisplay[Integer.parseInt(strErrMsg)];
		
		strTemp = " ("+strTemp+"-"+strErrMsg+") ";
		
		//fname , mname, lname
		strTemp = WebInterface.formatName((String)vTemp.remove(x), (String)vTemp.remove(x), (String)vTemp.remove(x), 4) + strTemp;
		
		strSection = (String)vTemp.remove(x);//section		
		
		strTemp = strTemp + strSection;
		
		vTemp.remove(x);//time from in vector
		vTemp.remove(x);//time to in vector
		vTemp.remove(x);//
		vTemp.remove(x);//
		vTemp.remove(x);//
		
		%>
      <td><%=strTemp%></td>
      <td align="center">( &nbsp; &nbsp; &nbsp; )</td>
      <td align="center" valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%;">&nbsp;</div></td>
      <td align="center" valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%;">&nbsp;</div></td>
      <td align="center">( &nbsp; &nbsp; &nbsp; )</td>
      
      
      <%if(vTemp.size() > 0){
		
		vTemp.remove(x);//sub_sec_index
		vTemp.remove(x);//room_index
		%>
      <td>&nbsp;</td>
   	<td><%=(String)vTemp.remove(x)%></td>
      <%
		
		vTemp.remove(x);//room_type
		vTemp.remove(x);//floor
		vTemp.remove(x);//description
		vTemp.remove(x);//status_remakr
		vTemp.remove(x);//total_cap
		vTemp.remove(x);//location
		vTemp.remove(x);//is_lec
		
		strTimeFrom24 = (String)vTemp.remove(x);
		strTimeTo24 = (String)vTemp.remove(x);
		
		
		strTemp = strTimeFrom24.substring(strTimeFrom24.indexOf(".") + 1);
		if(!strTemp.equals("0"))
			strTemp = "1";
			
		strTemp = astrTime12[Integer.parseInt(strTimeFrom24.substring(0,strTimeFrom24.indexOf("."))) - 4] + astrMinDisplay[Integer.parseInt(strTemp)];	
		
		strErrMsg = strTimeTo24.substring(strTimeTo24.indexOf(".") + 1);
		if(!strErrMsg.equals("0"))
			strErrMsg = "1";
		
		strErrMsg = astrTime12[Integer.parseInt(strTimeTo24.substring(0,strTimeTo24.indexOf("."))) - 4] + astrMinDisplay[Integer.parseInt(strErrMsg)];
		
		strTemp = " ("+strTemp+"-"+strErrMsg+") ";
		
		//fname , mname, lname
		strTemp = WebInterface.formatName((String)vTemp.remove(x), (String)vTemp.remove(x), (String)vTemp.remove(x), 4) + strTemp;
		
		strSection = (String)vTemp.remove(x);//section		
		
		strTemp = strTemp + strSection;
		
		vTemp.remove(x);//time from in vector
		vTemp.remove(x);//time to in vector
		vTemp.remove(x);//
		vTemp.remove(x);//
		vTemp.remove(x);//
		
		%>
      <td><%=strTemp%></td>
      <td align="center">( &nbsp; &nbsp; &nbsp; )</td>
      <td align="center" valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%;">&nbsp;</div></td>
      <td align="center" valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%;">&nbsp;</div></td>
      <td align="center">( &nbsp; &nbsp; &nbsp; )</td>
      
      
      <%}%>
      
   </tr>
   
   <%
	if(iRowCount >= iMaxRowCount){
		iRowCount = 0;
		bolPageBreak = true;
		break;	
	}
	}%>
</table>
<%}
}%>   
<script>window.print();</script>

<%}else{%>
	<div align="center"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></div>
<%}%>




</body>
</html>
<%dbOP.cleanUP();%>
