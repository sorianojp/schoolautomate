<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	alert("Click OK to print this page");
	window.print();
}
</script>
<body>
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.

	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Other report-Comparative Enrollment","enrollment_summary_percollege.jsp");
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
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"enrollment_summary_percollege.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
ReportEnrollment reportE = new ReportEnrollment();
if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = reportE.getPerSubjectEnrollmentCount(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportE.getErrMsg();
}

Vector vStudPassed = new Vector();
if(WI.fillTextValue("show_passed").length() > 0 && vRetResult != null && vRetResult.size() > 0) {
	String strSQLQuery = "select s_index, count(*) from g_sheet_final "+
						 "join stud_curriculum_hist on (stud_curriculum_hist.cur_hist_index = g_sheet_final.cur_hist_index) "+
						 "where g_sheet_final.is_valid = 1 and remark_index = 1 and sy_from = "+WI.fillTextValue("sy_from")+
						 " and semester = "+WI.fillTextValue("semester")+" group by s_index";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vStudPassed.addElement(new Integer(rs.getInt(1)));
		vStudPassed.addElement(rs.getString(2));
	}
	rs.close();
}
Integer iObj = null;
int iIndexOf = 0;
%>
<form action="./enrollment_per_subject.jsp" method="post" name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr>
      <td height="25" colspan="4" align="center" bgcolor="#A49A6A" style="font-weight:bold; color:#FFFFFF">:::: ENROLLMENT PER SUBJECT ::::</td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="5%" height="25"></td>
      <td width="36%">SY/Term From (Current) </td>
      <td width="59%">
	  <select name="lines_per_pg">
	  	<%
		int iRowsPerPg = Integer.parseInt(WI.getStrValue(WI.fillTextValue("lines_per_pg"), "55"));
		for(int i = 45; i < 65; ++i) {
			if(i == iRowsPerPg)
				strTemp = "selected";
			else	
				strTemp = "";
		%><option value="<%=i%>" <%=strTemp%>><%=i%></option>
		<%}%>
	  </select> 
	  - Rows Per page	  
	  
	  <!--<input type="checkbox" name="show_passed" value="checked" <%=WI.fillTextValue("show_passed")%>> Show Student Passed.-->
	  
	  </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress="AllowOnlyInteger('form_','sy_from')"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'> 
        -     
<%
if(strTemp.length() > 0) 
	strTemp = Integer.toString(Integer.parseInt(strTemp) + 1);
%>
		<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        <select name="semester">
          <option value="1">1st Sem</option>
          <%
strErrMsg =WI.fillTextValue("semester");
if(strErrMsg.length() ==0) 
	strErrMsg = (String)request.getSession(false).getAttribute("cur_sem");
if(strErrMsg.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}if(strErrMsg.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
<%}else{%>
          <option value="3">3rd Sem</option>
<%}if(strErrMsg.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
<%}else{%>
          <option value="4">4th Sem</option>
<%}if(strErrMsg.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
        </select>     </td>     
      <td><input name="submit" type="submit" value="Generate Report"></td>
    </tr>
    
    <tr>
      <td height="10"></td>
      <td align="right">&nbsp;</td>
      <td align="right">
	  <a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>Print page
	  &nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>
<%
String[] astrConvertTerm = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};

boolean bolPageBreak = true;

int iCurrentRow = 0; int iPageCount = 0;

int iRowCount = 0;
String strTimeNow = WI.getTodaysDateTime();

boolean bolShowPassed = false;
if(WI.fillTextValue("show_passed").length() > 0) 
	bolShowPassed = true;

if(vRetResult != null)
while(vRetResult.size() > 0) {
iCurrentRow = 0;%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td align="center"><b><%=SchoolInformation.getSchoolName(dbOP,true,false)%></b><br>
		<font size="1"><%=WI.getStrValue(SchoolInformation.getAddressLine1(dbOP,false,false),"","<br>","")%></font>
		<font  style="font-size:9px;">
		<%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>, SY 
		<%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></font>
		<br><br>
		<strong>STUDENT ENROLLED PER SUBJECT </strong>
		<br>		&nbsp;
	  </td>
	</tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr style="font-weight:bold">
		<td width="5%" class="thinborderBOTTOM" height="18">Count</td>
		<td width="15%" class="thinborderBOTTOM">Subject Code </td>
		<td width="50%" class="thinborderBOTTOM">Subject Name </td>
		<td width="15%" class="thinborderBOTTOM">Students Enrolled </td>
<%if(bolShowPassed) {%>
	    <td width="15%" class="thinborderBOTTOM">Students Passed </td>
<%}%>
	</tr>
	<%while(vRetResult.size() > 0) {
		++iCurrentRow;
	%>	
		<tr>
			<td class="thinborderNONE" height="18"><%=++iRowCount%></td>
			<td class="thinborderNONE">&nbsp;<%=vRetResult.elementAt(1)%></td>
			<td class="thinborderNONE"><%=vRetResult.elementAt(2)%></td>
			<td class="thinborderNONE"><%=vRetResult.elementAt(3)%></td>
<%if(bolShowPassed) {
iObj = (Integer)vRetResult.elementAt(0);
iIndexOf = vStudPassed.indexOf(iObj);
if(iIndexOf > -1) {
	strTemp = (String)vStudPassed.elementAt(iIndexOf + 1);
	vStudPassed.remove(iIndexOf);
	vStudPassed.remove(iIndexOf);
}
else	
	strTemp = "0";
%>
		    <td class="thinborderNONE"><%=strTemp%></td>
<%}%>
		</tr>
	<%
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
	//}	
	/////////////// end of printing total .. 
		if(iRowsPerPg <= iCurrentRow || vRetResult.size() == 0) {
			iCurrentRow = 0;
			++iPageCount;
			if(vRetResult.size() == 0) 
				bolPageBreak = false;
			break;
		}
	}
	%>
	<!-- Footer.. -->
			<tr style="font-weight:bold">
				<td colspan="5" height="45">
				<table width="100%" cellpadding="0" cellspacing="0" border="0">
					<tr>
						<td width="40%" class="thinborderTOP">Printed By : <%=request.getSession(false).getAttribute("first_name")%></td>
						<td width="20%" class="thinborderTOP" align="center">Page <%=iPageCount%> of <label id="_<%=iPageCount%>"></label></td>
						<td width="40%" align="right" class="thinborderTOP">Date and Time Printed : <%=strTimeNow%></td>
					</tr>
				</table>				</td>
			</tr>
</table>  
<%if(bolPageBreak){%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}%>

<%}//end of while%>  


<%if(iPageCount > 0) {//print here the total page count.. %>
	<script language="javascript">
		<%for(int i =1; i <= iPageCount; ++i) {%>
			if(document.getElementById("_<%=i%>"))
				document.getElementById("_<%=i%>").innerHTML = "<%=iPageCount%>";
		<%}%>
	</script>
<%}%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
  