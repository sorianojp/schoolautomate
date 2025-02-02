<%@ page language="java" import="utility.*,java.util.Vector, enrollment.PersonalInfoManagement"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../search/srch_stud.jsp?opner_info=offlineRegd.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.form_.stud_id.focus();
}</script>

<%
	
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-OSA - Organization","disc_agreement_p2.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
								
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs",
														"ORGANIZATIONS",request.getRemoteAddr(),
														"action_plan_org_update.jsp");
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


Vector vRetResult = null;
Vector vCompliedList = null;
PersonalInfoManagement pInfo = new PersonalInfoManagement();

String strIndex = null;



vRetResult = pInfo.getStudentDisciplinaryAgreementInfo(dbOP, request);
	if (vRetResult != null)
		vCompliedList = (Vector)vRetResult.elementAt(10);
	else
		strErrMsg = pInfo.getErrMsg();

%>

<body bgcolor="#FFFFFF">
<%if (vRetResult != null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="200" align="left" height="15"><font size="1">UI-SDO-FORM 018</font></td>
		<td>&nbsp;</td>
		<td width="200" align="right"><font size="1">Rev. No. 002 Date: 13 June 2006</td>
	</tr>
	<tr>
		<td align="left" valign="top">
		 <%strTemp = WI.fillTextValue("stud_id");
      strTemp = "<img src=\"../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=125 height=125 align=\"center\" border=\"1\">";%>
              <%=WI.getStrValue(strTemp)%>
		</td>
		<td align="center">
		<br><font size="3">UNIVERSITY OF ILOILO<br>
		<strong>STUDENT DEVELOMENT OFFICE<br><br><br><br><u>A G R E E M E N T</u></strong></font><br><br>
		</td>
		<td>&nbsp;</td>
	</tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="5%">&nbsp;</td>
		<td width="45%">&nbsp;</td>
		<td width="50%">
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		Date:<u><%=WI.getTodaysDate()%></u></td>
	</tr>
	<tr>
		<td colspan="3" height="20">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="3" align="left"><font size="3"><strong>TO WHOM IT MAY CONCERN:</strong></font></td>
	</tr>
		<tr>
		<td colspan="3" height="20">&nbsp;</td>
	</tr>
		<tr>
		<td colspan="3"><font size="2">
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		I, <u><%=WI.formatName((String)vRetResult.elementAt(0),(String)vRetResult.elementAt(1),(String)vRetResult.elementAt(2),7)%> , <%=(String)vRetResult.elementAt(3)%> 
		- <%=(String)vRetResult.elementAt(4)%></u>  a resident of &nbsp;
		<u><%=WI.getStrValue((String)vRetResult.elementAt(5),
		"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+
		"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")%></u>
		&nbsp;
		for and in consideration of my enrollment at the University of Iloilo for the Academic Year <u><%=WI.fillTextValue("sy_from")%></u> 
		to <u><%=WI.fillTextValue("sy_to")%></u>, do hereby agree with the following terms and conditions:</font></td>
	</tr>

	<tr>
		<td height="30" align="right" valign="top"><font size="2"><strong><br>1. </strong></font></td>
		<td colspan="2" height="30"><font size="2"><strong><br>That I shall abide by the existing Rules and Regulations of this University 
		as <br><br>indicated and embodied in the 2004 Revised Student Handbook of those which <br><br>the University may 
		henceforth issue;</strong></font></td>
	</tr>
	<tr>
		<td height="30" align="right" valign="top"><font size="2"><strong><br>2. </strong></font></td>
		<td colspan="2"><font size="2"><strong><br>That, I shall neither seek membership in nor recruit membership in any<br><br>
		organization whose principles and objectives are not officually aproved by the <br><br>University, 
		specifically those whose activities are deemed subversive and/or <br><br>illegal;</strong></font></td>
	</tr>
	<tr>
		<td height="30" align="right" valign="top"><font size="2"><strong><br>3. </strong></font></td>
		<td colspan="2"><font size="2"><strong><br>That, I shall wear the prescribed school uniform and University<br><br>
		Identifucation Card (UI-ID), at all times while inside the University's premises;</strong></font></td>
	</tr>
	<tr>
		<td height="30" align="right" valign="top"><font size="2"><strong><br>4. </strong></font></td>
		<td colspan="2"><font size="2"><strong><br>That, I shall conduct myself in a proper and irreproachable manner 
		befitting the <br><br>personality of a student with good moral character in my dealings with the<br><br>
		school authorities and fellow students.<br></strong></font></td>
	</tr>

	<tr>
		<td colspan="3"><br><font size="2">
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		That I have fully understood and agreed with the terms and conditions as set forth
		above, and should I fail to observe and comply with any of them, the University reserves the
		right to impose on my person the applicable provisions of the Student Handbook (warning, 
		susension, and/or expulsion).</font>
		</td>
	</tr>
	<tr>
		<td colspan="3" height="60">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="2" align="center"><u><%=WI.getStrValue((String)vRetResult.elementAt(6),"Name/signature of Parent/guardian")%></u></td>
		<td align="center"><u><%=WI.formatName((String)vRetResult.elementAt(0),(String)vRetResult.elementAt(1),(String)vRetResult.elementAt(2),7)%></u></td>	
	</tr>
	<tr>
		<td colspan="3" height="40">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="2" align="left"><strong>Interviewed by:</strong></td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td colspan="3" align="left"><strong>Documents Submitted:</strong>
		<font size="1">
		<%if (vCompliedList!= null && vCompliedList.size()>0){
		for (int a = 0; a< vCompliedList.size(); a+=3){
		if (a==0) {%><%=(String)vCompliedList.elementAt(a+1)%><%} else {%>
		<%=WI.getStrValue((String)vCompliedList.elementAt(a+1),",","","")%>
		<%}}%>
		<%} else {%>None submitted<%}%>
		</font></td>
	</tr>
  </table>
  <%} else {%>
  <script>
	var msg = "Student%20enrollment%20information%20not%20found";
  	location = "./disc_agreement_p1.jsp?stud_id=<%=WI.fillTextValue("stud_id")%>&sy_from=<%=WI.fillTextValue("sy_from")%>&sy_to=<%=WI.fillTextValue("sy_to")%>&semester=<%=WI.fillTextValue("semester")%>&passed_message="+msg;
  </script>
  <%}%>
  <input name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" type="hidden">
  <input name="sy_from" value="<%=WI.fillTextValue("sy_from")%>" type="hidden">
  <input name="sy_to" value="<%=WI.fillTextValue("sy_to")%>" type="hidden">
  <input name="semester" value="<%=WI.fillTextValue("semester")%>" type="hidden">
</body>
</html>
<%	
dbOP.cleanUP();
%>