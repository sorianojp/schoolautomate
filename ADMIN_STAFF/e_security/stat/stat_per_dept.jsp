<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ShowStat() {
	if(document.form_.date_fr.value.length == 0) {
		alert("Please enter date of statistics.");
		return ;
	}
	if(document.form_.loc_index.selectedIndex == 0) 
		document.form_.loc_name.value = " All Location";
	else	
		document.form_.loc_name.value = document.form_.loc_index[document.form_.loc_index.selectedIndex].text;
		
	document.form_.show_stat.value = '1';
	document.form_.submit();
}
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);

	window.print();
}
</script>
<body>
<%@ page language="java" import="utility.*,eSC.CampusQuery,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null; String strTemp = null;
	Vector vRetResult = null;
	String strReportToDisp = null;

//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eSecurity Check-Statistics","stat_per_dept.jsp");
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
														"eSecurity Check","Statistics",request.getRemoteAddr(), 
														"stat_per_dept.jsp");	
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
    Vector vDeptInfo    = new Vector();//dept index, dept code, total count.
    Vector vCollegeInfo = new Vector();//college index, college code, total count.
    Vector vNTP         = new Vector();//dept code, count -- first element is total count.
    Vector vFaculty     = new Vector();//dept code, count -- first element is total count.
    Vector vStudent     = new Vector();//dept code, count -- first element is total count.

if(WI.fillTextValue("show_stat").length() > 0) {
	CampusQuery cQ = new CampusQuery(request);
	vRetResult = cQ.getStatisticsPerDept(dbOP, request);
	if(vRetResult == null)
		strErrMsg = cQ.getErrMsg();
	else {
		vDeptInfo    = (Vector)vRetResult.remove(0);
		vCollegeInfo = (Vector)vRetResult.remove(0);
		vNTP         = (Vector)vRetResult.remove(0);
		vFaculty     = (Vector)vRetResult.remove(0);
		vStudent     = (Vector)vRetResult.remove(0);
	}
}

strReportToDisp = "Statistics of Campus Attendance Per Department for Location : "+WI.fillTextValue("loc_name");
if(WI.fillTextValue("date_fr").length() > 0)
	strReportToDisp += " As of Date: "+WI.fillTextValue("date_fr");
if(WI.fillTextValue("date_to").length() > 0)
	strReportToDisp += " to "+WI.fillTextValue("date_to");
%>	

<form action="./stat_per_dept.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          Statistics Per Department ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%">Date</td>
      <td width="85%"> <input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" border="0"></a> to 
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
	<tr > 
      <td height="25">&nbsp;</td>
      <td>Location</td>
      <td>
	  <select name="loc_index"> 
	  <option value=""> ALL LOCATIONS </option>
	  	<%=dbOP.loadCombo("LOCATION_INDEX","LOC_NAME",
			" from ESC_LOGIN_LOC order by LOC_NAME", WI.fillTextValue("loc_index"),false)%>
 	 </select>	
	 &nbsp;&nbsp;<a href="javascript:ShowStat();">Show Statistics</a>	
	 </td>
    </tr>	
  </table>
<%
if(vRetResult != null && vDeptInfo != null && vDeptInfo.size() > 0){
int iIndexOf    = 0;

String strFacultyCount = null;
String strNTPCount     = null;
String strStudentCount = null;

int iTotFac  = 0;
int iTotNTP  = 0;
int iTotStud = 0;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable3">
    <tr > 
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" ></a><font size="1">click 
          to print listing/report</font></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="4" bgcolor="#B9B292"><div align="center"><strong><%=strReportToDisp%></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td width="32%" height="25" align="center" class="thinborder"><font size="1"><strong>Deptartment/College</strong></font></td>
      <td width="17%" align="center" class="thinborder"><font size="1"><strong>Faculty</strong></font></td>
      <td width="17%" align="center" class="thinborder"><font size="1"><strong>NTP</strong></font></td>
      <td width="17%" align="center" class="thinborder"><font size="1"><strong>Student</strong></font></td>
      <td width="17%" align="center" class="thinborder"><font size="1"><strong>Total</strong></font></td>
    </tr>
<%
for(int i = 0; i< vDeptInfo.size(); i +=3){
strFacultyCount = null;
strNTPCount     = null;
strStudentCount = null;

strTemp = (String)vDeptInfo.elementAt(i + 1);
if(vFaculty.size() > 0 && vFaculty.elementAt(0).equals(strTemp)) {
	strFacultyCount = (String)vFaculty.elementAt(1);
	vFaculty.remove(0);vFaculty.remove(0);
}
if(vNTP.size() > 0 && vNTP.elementAt(0).equals(strTemp)) {
	strNTPCount = (String)vNTP.elementAt(1);
	vNTP.remove(0);vNTP.remove(0);
}
if(vStudent.size() > 0 && vStudent.elementAt(0).equals(strTemp)) {
	strStudentCount = (String)vStudent.elementAt(1);
	vStudent.remove(0);vStudent.remove(0);
}
	

iTotFac  += Integer.parseInt(WI.getStrValue(strFacultyCount,"0"));
iTotNTP  += Integer.parseInt(WI.getStrValue(strNTPCount,"0"));
iTotStud += Integer.parseInt(WI.getStrValue(strStudentCount,"0"));
%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder"><%=WI.getStrValue(strFacultyCount,"0")%></td>
      <td class="thinborder"><%=WI.getStrValue(strNTPCount,"0")%></td>
      <td class="thinborder"><%=WI.getStrValue(strStudentCount,"0")%></td>
      <td class="thinborder"><%=vDeptInfo.elementAt( i + 2)%>
	  </td>
    </tr>
<%}%>
<%///do the same for college now.. 
for(int i = 0; i< vCollegeInfo.size(); i +=3){
strFacultyCount = null;
strNTPCount     = null;
strStudentCount = null;

strTemp = (String)vCollegeInfo.elementAt(i + 1);
if(vFaculty.size() > 0 && vFaculty.elementAt(0).equals(strTemp)) {
	strFacultyCount = (String)vFaculty.elementAt(1);
	vFaculty.remove(0);vFaculty.remove(0);
}
if(vNTP.size() > 0 && vNTP.elementAt(0).equals(strTemp)) {
	strNTPCount = (String)vNTP.elementAt(1);
	vNTP.remove(0);vNTP.remove(0);
}
if(vStudent.size() > 0 && vStudent.elementAt(0).equals(strTemp)) {
	strStudentCount = (String)vStudent.elementAt(1);
	vStudent.remove(0);vStudent.remove(0);
}
	

iTotFac  += Integer.parseInt(WI.getStrValue(strFacultyCount,"0"));
iTotNTP  += Integer.parseInt(WI.getStrValue(strNTPCount,"0"));
iTotStud += Integer.parseInt(WI.getStrValue(strStudentCount,"0"));
%>
    <tr bgcolor="#EEEEEE"> 
      <td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder"><%=WI.getStrValue(strFacultyCount,"0")%></td>
      <td class="thinborder"><%=WI.getStrValue(strNTPCount,"0")%></td>
      <td class="thinborder"><%=WI.getStrValue(strStudentCount,"0")%></td>
      <td class="thinborder"><%=vCollegeInfo.elementAt( i + 2)%>
	  </td>
    </tr>
<%}%>
    <tr> 
      <td height="25" class="thinborder" align="right"><b>Total</b>&nbsp;</td>
      <td class="thinborder">&nbsp;<b><%=iTotFac%></b></td>
      <td class="thinborder">&nbsp;<b><%=iTotNTP%></b></td>
      <td class="thinborder">&nbsp;<b><%=iTotStud%></b></td>
      <td class="thinborder"><b><%=iTotFac + iTotNTP + iTotStud%></b></td>
    </tr>
  </table>
  <%}//only if vRetResult is not null %>
 
<input type="hidden" name="show_stat">
<input type="hidden" name="loc_name">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>