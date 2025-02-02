<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.ReportRegistrar, enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

	String strGraduationDate = WI.fillTextValue("grad_date");
	if(strGraduationDate.length() == 0) {%>
		<p align="center" style="font-weight:bold; font-size:14px; color:#FF0000">Please enter graduation Date</p>
		
	<%return;}
	strGraduationDate = WI.formatDate(strGraduationDate, 6);
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
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderSP {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

    TD.thinborderSP {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
-->
</style>


</head>

<body onLoad="window.print()">

<%
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Certification","grade_certificate.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Releasing",request.getRemoteAddr(),
									null);

}

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


String strGender  = null;

GradeSystem GS = new GradeSystem();
enrollment.EnrlAddDropSubject enrlAddDrop = new enrollment.EnrlAddDropSubject();
Vector vRetResult  = null;

String[] astrConvertSem={"SUMMER", "FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER"};
String strYrLevel      = null;

String strCollegeName  = null;
String strDeanName     = null;

Vector vStudInfo    =  enrlAddDrop.getEnrolledStudInfo(dbOP, null, WI.fillTextValue("stud_id"), WI.fillTextValue("sy_from"), 
						WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
if(vStudInfo == null)
	strErrMsg = enrlAddDrop.getErrMsg();
else 
	strGender = (String)vStudInfo.elementAt(13);
if(strGender == null)
	strGender = "";

Vector vGradeDetail = null;
Vector vLocked      = new Vector();

if(vStudInfo != null) {
	vGradeDetail =  GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),
						"final", WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"), 
						WI.fillTextValue("semester"), false, true, true, false);//show enrolled subject. and get faculty.
	//integrate Locked Info..
	
	
	String strSQLQuery = "select c_name, dean_name from college "+
		"join course_offered on (course_offered.c_index = college.c_index) where course_index = "+
		(String)vStudInfo.elementAt(5);
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		strCollegeName = rs.getString(1);
		strDeanName    = rs.getString(2);
	}
	rs.close();
}
//get all sub_sec_index Locked.. 

Vector vSubSecIndexLocked = new enrollment.GradeSystemExtn().getSubSecIndexLocked(dbOP, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"), "3");
if(vSubSecIndexLocked == null)
	vSubSecIndexLocked = new Vector();

//System.out.println(vGradeDetail);
//System.out.println(vSubSecIndexLocked);

if(strErrMsg != null) {%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="45%" height="18" style="font-size:16px; color:#FF0000"><%=strErrMsg%></td>
  </tr>
<%dbOP.cleanUP();
return;}%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="45%" height="18" align="center" ><strong><font size="4">CEBU INSTITUTE OF TECHNOLOGY - UNIVERSITY </font> <br>
		</strong>
		<font size="2">N. Bacalso Ave., Cebu City, 6000, Philippines</font><br>
		<strong><font size="2">OFFICE OF THE REGISTRAR</font></strong>
		<br><br>&nbsp;<br><br>&nbsp;
	<div align="right"><%=WI.getTodaysDate(4)%></div><br><br>&nbsp;</td>
  </tr>
  <tr>
    <td height="20" valign="bottom" style="font-size:14px; font-weight:bold">TO WHO IT MAY CONCERN: <br>&nbsp;</td>
  </tr>
<tr>
    <td height="50" valign="bottom" style="line-height:20px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This is to certify that 
	<b><u><!--<%if(strGender.equals("m")){%>Mr.<%}else{%>Ms.<%}%> --><%=((String)vStudInfo.elementAt(1)).toUpperCase()%>, a <%=vStudInfo.elementAt(16)%><%=WI.getStrValue((String)vStudInfo.elementAt(22), " - ","","")%></u></b>
	of this school during <u><strong><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>, <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></u>
	obtained the following advance grades on their corresponding subjects as indicated below: 
	</td>
  </tr>
<tr>
  <td height="10" valign="bottom" >&nbsp;</td>
</tr>
</table>
<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr valign="top">
    <td width="15%" height="25"><strong><font size="1">Subject Number </font></strong></td>
    <td width="50%"><font size="1"><strong>Description Of Subjects Enrolled </strong></font></td>
    <td width="5%"><font size="1"><strong>Final Grades </strong></font></td>
    <% if (!strSchCode.startsWith("CPU") &&  !strSchCode.startsWith("UDMC")){%>
    <td width="30%" style="font-size:9px; font-weight:bold">Authorized Representative<br>
	(Dean, Dept. Heads, Registrar) with their signature above their name
	</td>
    <%}%>
  </tr>
<%
int iMaxRow = 14;
for(int i = 0; i < vGradeDetail.size(); i += 8){
--iMaxRow;
strTemp = (String)vGradeDetail.elementAt(i + 2);
if(strTemp != null && strTemp.length() > 32)
	strTemp = strTemp.substring(0,32);
strErrMsg = (String)vGradeDetail.elementAt(i + 5);

if(strErrMsg != null && strErrMsg.startsWith("Grade"))
	strErrMsg = "GNA";
	
	
if(GS.vGSIndexLocked.indexOf(vGradeDetail.elementAt(i)) == -1) {
	//if(vGradeDetail.elementAt(i + 7) != null && ((String)vGradeDetail.elementAt(i + 7)).compareTo("0") == 0)
		//strErrMsg = " GNA";
	if(vSubSecIndexLocked.indexOf(vGradeDetail.elementAt(i + 4)) == -1) {
		//strCE = "0.0";
		strErrMsg = "GNA";
	}

}
%>
  <tr>
    <td height="25"><%=vGradeDetail.elementAt(i + 1)%></td>
    <td><%=strTemp%></td>
    <td><%=strErrMsg%></td>
    <td>__________________________________</td>
  </tr>
<%}
for(int i = 0; i < iMaxRow; ++i){%>
  <tr>
    <td height="25" colspan="4">&nbsp;</td>
  </tr>
<%}%>
</table>
<Br><br>
<table width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="2">
		This certification is issued upon request of the above student concerned to facilitate the compliance of their graduation clearance necessary to be able to join the commencement exercises scheduled on 
		
		<b><u><%=WI.getStrValue(strGraduationDate)%>.</u></b>
		</td>
	</tr>
	<tr>
		<td height="75" colspan="2">&nbsp;</td>
	</tr>
	<tr style="font-weight:bold">
		<td width="50%"><u><%=strDeanName%></u></td>
		<td width="50%"><u>GRETCHEN LIZARES-TORMIS, MBA</u></td>
	</tr>
	<tr>
		<td>Dean, <%=strCollegeName%></td>
		<td>Registrar</td>
	</tr>
	<tr>
		<td colspan="2"><br><br><br><br><b><u><%=CommonUtil.getName(dbOP, (String)request.getSession(false).getAttribute("userId"), 7)%></u></b><br>Records In-Charge</td>
	</tr>
</table>


</body>
</html>
<%dbOP.cleanUP();%>
