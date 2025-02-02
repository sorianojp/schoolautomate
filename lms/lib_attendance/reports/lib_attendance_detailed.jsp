<%@ page language="java" import="utility.*,lms.LibraryAttendance,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"lms-Library Attendance-REPORTS","lib_attendance_summary.jsp");
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
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function ShowReport(){
	document.form_.attendance_for_name.value = document.form_.attendance_for[document.form_.attendance_for.selectedIndex].text;
	document.form_.show_report.value = "1";
	document.form_.submit();
}

function ReloadPage(){
	document.form_.attendance_for_name.value = document.form_.attendance_for[document.form_.attendance_for.selectedIndex].text;
	document.form_.submit();
}

function PrintPage(){
	
	document.bgColor = "#FFFFFF";

	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	

	
	document.getElementById("myADTable2").deleteRow(0);
	

	window.print();

}

</script>
<body bgcolor="#98A7B8">
<%
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"LIB_Library Attendance","REPORTS",request.getRemoteAddr(),
														"lib_attendance_summary.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
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
LibraryAttendance libAtt = new LibraryAttendance();
Vector vRetResult = null;

/*
0 basic
1 college
2 faculty
*/
String strReportFor = WI.getStrValue(WI.fillTextValue("attendance_for"),"1");

String[] astrConvertSem = {"Summer","First Semester","Second Semester", "Third Semester"};
if(strReportFor.equals("0"))
	astrConvertSem[1] = "Regular";

int iElemCount= 0;

if(WI.fillTextValue("show_report").length() > 0){
	vRetResult = libAtt.getLibAttendanceDetailed(dbOP, request);
	if(vRetResult == null)
		strErrMsg = libAtt.getErrMsg();
	else
		iElemCount = libAtt.getElemCount();
}

%>
<form action="./lib_attendance_detailed.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#424255"> 
      <td height="25" colspan="4" class="thinborderTOPLEFTRIGHT" align="center"><font color="#FFFFFF" ><strong>:::: 
        LIBRARY ATTENDANCE DETAILED REPORT ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="24" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    
    <tr>
        <td height="25">Attendance For</td>
        <td>
		<select name="attendance_for" onChange="ReloadPage();">
			<%
			strTemp = WI.fillTextValue("attendance_for");
			if(strTemp.equals("0"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%>
			<option value="0" <%=strErrMsg%>>Basic Education</option>
			<%			
			if(strTemp.equals("1") || strTemp.length() == 0)
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%>
			<option value="1" <%=strErrMsg%>>College</option>
			<%			
			if(strTemp.equals("2"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%>
			<option value="2" <%=strErrMsg%>>Faculty</option>
		</select>
		</td>
        <td >&nbsp;</td>
        <td >&nbsp;</td>
    </tr>
    <tr> 
      <td width="13%" height="25">SY/Term</td>
      <td width="28%"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
      <td width="10%" >Date Range</td>
      <td width="49%" > 
<%
strTemp = WI.fillTextValue("date_fr");

%> <input name="date_fr" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=strTemp%>"> 
   <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
   	onMouseOver="window.status='Select date';return true;" 
	onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>

<%
strTemp = WI.fillTextValue("date_to");

%> <input name="date_to" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=strTemp%>"> 
   <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
   	onMouseOver="window.status='Select date';return true;" 
	onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>	
	&nbsp;
	<%
	strTemp = WI.fillTextValue("until_current_date");
	if(strTemp.equals("1"))
		strErrMsg = "checked";
	else
		strErrMsg = "";
	%>
	<input type="checkbox" name="until_current_date" value="1" <%=strErrMsg%>>Until current date	</td>
    </tr>
    <tr>
        <td height="25">&nbsp;</td>
        <td>
			<a href="javascript:ShowReport();"><img src="../../images/form_proceed.gif" border="0"></a>		</td>
        <td >&nbsp;</td>
        <td >&nbsp;</td>
    </tr>
	
	
<!--    <tr> 
      <td height="25"> Location</td>
      <td><select name="loc_index" 
			style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 13;">
			<option value="">ALL</option>
          <%=dbOP.loadCombo("LOC_INDEX","LOC_NAME"," from LMS_LIBRARY_LOC order by LOC_NAME", WI.fillTextValue("loc_index"),false)%> </select></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>-->
    
    <tr> 
      <td height="19" colspan="4"><hr size="1" color="#FFCC33"></td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0){
int iCount = 0;
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
	<tr><td align="right">
		<a href="javascript:PrintPage();"><img src="../../images/print.gif" border="0"></a></td></tr>
	<tr>
		<%
		strTemp = astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))];
		strErrMsg = "";
		if(WI.fillTextValue("date_fr").length() > 0)
			strErrMsg = "Date from "+WI.fillTextValue("date_fr");
		if(WI.fillTextValue("date_to").length() > 0)
			strErrMsg += " to "+WI.fillTextValue("date_to");
		else if(WI.fillTextValue("until_current_date").length() > 0)
			strErrMsg += " to "+WI.getTodaysDate(1);
		%>
		<td align="center" height="20">LIBRARY ATTENDANCE FOR <strong><%=WI.fillTextValue("attendance_for_name").toUpperCase()%></strong>
			<br><%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")+", "+strTemp%>
			<br><%=strErrMsg%>
		</td>
	</tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td width="4%" height="22" align="center" class="thinborder"><font size="1"><strong>COUNT</strong></font></td>
	    <td width="14%" align="center" class="thinborder"><font size="1"><strong>ID NUMBER</strong></font></td>
		<%
		strTemp = "STUDENT NAME";
		if(strReportFor.equals("2"))
			strTemp = "EMPLOYEE NAME";
		%>
	    <td width="21%" align="center" class="thinborder"><font size="1"><strong><%=strTemp%></strong></font></td>
	    <td width="21%" align="center" class="thinborder"><font size="1"><strong>DATE-TIME</strong></font></td>
		<%
		strTemp = "COLLEGE";
		if(strReportFor.equals("0"))
			strTemp = "EDUCATION LEVEL";
		%>
	    <td width="21%" align="center" class="thinborder"><font size="1"><strong><%=strTemp%></strong></font></td>
		<%
		strTemp = "COURSE-YEAR";
		if(strReportFor.equals("0"))
			strTemp = "GRADE LEVEL";
		if(strReportFor.equals("2"))
			strTemp = "DEPARTMENT";
		%>
	    <td width="19%" align="center" class="thinborder"><font size="1"><strong><%=strTemp%></strong></font></td>
	</tr>
	<%
	iCount = 0;
	for(int i = 0; i < vRetResult.size() ; i+=iElemCount){
	%>
	<tr>
	    <td height="22" align="right" class="thinborder"><%=++iCount%>&nbsp;</td>
	    <td class="thinborder" style="padding-left:10px;"><%=vRetResult.elementAt(i+1)%></td>
		<%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4);
		%>
	    <td class="thinborder"><%=strTemp%></td>
	    <td class="thinborder"><%=vRetResult.elementAt(i+5)%></td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+8),"&nbsp;")%></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+9));
		if(strTemp.length() > 0 && WI.getStrValue(vRetResult.elementAt(i+6)).length() > 0)
			strTemp += "-";
		strTemp  += WI.getStrValue(vRetResult.elementAt(i+6));
		if(strReportFor.equals("0"))
			strTemp = WI.getStrValue(vRetResult.elementAt(i+9));
		%>
	    <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	    </tr>
	<%}%>
</table>



<%}%>
<input type="hidden" name="show_report">
<input type="hidden" name="attendance_for_name" value="<%=WI.fillTextValue("attendance_for_name")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>