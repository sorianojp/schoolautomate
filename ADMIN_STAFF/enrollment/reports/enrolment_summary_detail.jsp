<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	var sT = "./enrolment_summary_print.jsp?sy_from="+document.enrl_report.sy_from.value+"&sy_to="+
		document.enrl_report.sy_to.value+"&offering_sem="+
		document.enrl_report.offering_sem[document.enrl_report.offering_sem.selectedIndex].value;

	if(document.enrl_report.show_date.checked)
		sT +="&specific_date="+document.enrl_report.specific_date.value;
	//print here
	var win=window.open(sT,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
function ReloadPage()
{
	document.enrl_report.reloadPage.value = "1";
	document.enrl_report.submit();
}
</script>
<body bgcolor="#D2AE72">
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
								"Admin/staff-Enrollment-REPORT-enrollment summary","enrolment_summary.jsp");
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
														"enrolment_summary.jsp");
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
ReportEnrollment reportEnrollment = new ReportEnrollment();
Vector vRetResult = null;
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 &&
				WI.fillTextValue("reloadPage").compareTo("1") !=0)
{
	vRetResult = reportEnrollment.getEnrollmentSummary(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportEnrollment.getErrMsg();
}
dbOP.cleanUP();
%>
<form action="./enrolment_summary.jsp" method="post" name="enrl_report">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          SUMMARY REPORT ON ENROLMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%" height="25">School year </td>
      <td width="22%" height="25"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("enrl_report","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> </td>
      <td width="5%">Term</td>
      <td width="22%" height="25"><select name="offering_sem">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("offering_sem");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td width="38%"><input type="image" src="../../../images/form_proceed.gif"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="35" colspan="5"> <%
if(WI.fillTextValue("show_date").compareTo("1") ==0)
	strTemp = " checked";
else
    strTemp = "";
%> <input type="checkbox" name="show_date" value="1"<%=strTemp%> onClick="ReloadPage();">
        Include Enrollment Summary for a specific date &nbsp;&nbsp;&nbsp;<font size="1"> 
        <%
if(strTemp.length() > 0){%>
        <input name="specific_date" type="text" size="10" value="<%=WI.fillTextValue("specific_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
        <a href="javascript:show_calendar('enrl_report.specific_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        </font> <%}%> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="5"> <%
if(WI.fillTextValue("show_foreign_stud").compareTo("1") ==0)
	strTemp = " checked";
else
    strTemp = "";
%> <input type="checkbox" name="show_foreign_stud" value="1"<%=strTemp%>>
        Show only Foreign Student.</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null){//System.out.println(vRetResult);
	// I have to keep track of course programs, course, and major.
	String strCourseProgram = null;
	String strCourseName    = null;
	String strMajorName     = null;

	//displays the coruse name and major name only if major and course names are different :-)
	String strCourseNameToDisp = null;
	String strMajorNameToDisp  = null;

	String str1stYrM = null;
	String str1stYrF = null;
	String str2ndYrM = null;
	String str2ndYrF = null;
	String str3rdYrM = null;
	String str3rdYrF = null;
	String str4thYrM = null;
	String str4thYrF = null;
	String str5thYrM = null;
	String str5thYrF = null;
	String str6thYrM = null;
	String str6thYrF = null;

	int iSubGrandTotal = 0;

	for(int i = 1 ; i< vRetResult.size() ;){//outer loop for each course program.
	strCourseProgram = (String)vRetResult.elementAt(i);
	strCourseName = null;
	iSubGrandTotal = 0;
	%>

  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td height="20" colspan="15" bgcolor="#DBD8C8"><strong>COURSE PROGRAM : <%=strCourseProgram%></strong></td>
    </tr>
    <tr>
      <td width="35%" rowspan="2"><div align="center"><strong><font size="1">COURSE</font></strong></div></td>
      <td width="22%" rowspan="2" align="center"><strong><font size="1">MAJOR</font></strong></td>
      <td height="24" colspan="2"><div align="center"><font size="1"></font></div>
        <div align="center"><strong><font size="1">1ST YEAR</font></strong></div></td>
      <td colspan="2"><div align="center"><font size="1"></font></div>
        <div align="center"><strong><font size="1">2ND YEAR</font></strong></div></td>
      <td colspan="2"><div align="center"><font size="1"></font></div>
        <div align="center"><strong><font size="1">3RD YEAR</font></strong></div></td>
      <td colspan="2"><div align="center"><font size="1"></font></div>
        <div align="center"><strong><font size="1">4TH YEAR</font></strong></div></td>
      <td colspan="2"><div align="center"><font size="1"></font></div>
        <div align="center"><strong><font size="1">5TH YEAR</font></strong></div></td>
      <td colspan="2"><div align="center"><font size="1"></font></div>
        <div align="center"><strong><font size="1">6TH YEAR</font></strong></div></td>
      <td width="7%" rowspan="2"><div align="center"><strong><font size="1">TOTAL</font></strong></div></td>
    </tr>
    <tr>
      <td width="3%" height="24"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>F</strong></font></div></td>
    </tr>
	<%
	for(int j = i; j< vRetResult.size();){//Inner loop for course/major for a course program.
	if(strCourseProgram.compareTo((String)vRetResult.elementAt(j)) != 0)
		break; //go back to main loop.
//System.out.println(strCourseName);
//System.out.println(strMajorName);

	if(strCourseName == null || strCourseName.compareTo((String)vRetResult.elementAt(j+1)) !=0)
	{
		strCourseName = (String)vRetResult.elementAt(j+1);
		strCourseNameToDisp = strCourseName;
		strMajorName = WI.getStrValue(vRetResult.elementAt(j+2));
		strMajorNameToDisp = strMajorName;
	}
	else if(strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0)//course name is same.
	{
		strCourseNameToDisp = "&nbsp;";
		if(strMajorName == null || strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2)) ) !=0)
		{
			strMajorName = WI.getStrValue(vRetResult.elementAt(j+2));
			strMajorNameToDisp = strMajorName;
		}
		else if(strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2)) ) ==0)
			strMajorNameToDisp = "&nbsp;";
	}
	str1stYrM = null;str1stYrF = null;
	str2ndYrM = null;str2ndYrF = null;str3rdYrM = null;str3rdYrF = null;str4thYrM = null;str4thYrF = null;
	str5thYrM = null;str5thYrF = null;str6thYrM = null;str6thYrF = null;
	iSubTotal = 0;
	//collect information for each year level for a course/major.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("1") ==0 &&
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str1stYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str1stYrM);
		j += 6;
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("1") ==0 &&
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str1stYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str1stYrF);
		j += 6;
	}
	//2nd year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("2") ==0 &&
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str2ndYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str2ndYrM);
		j += 6;
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("2") ==0 &&
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str2ndYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str2ndYrF);
		j += 6;
	}
	//3rd year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("3") ==0 &&
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str3rdYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str3rdYrM);
		j += 6;
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("3") ==0 &&
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str3rdYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str3rdYrF);
		j += 6;
	}
	//4th year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("4") ==0 &&
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str4thYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str4thYrM);
		j += 6;
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("4") ==0 &&
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str4thYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str4thYrF);
		j += 6;
	}
	//5th year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("5") ==0 &&
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str5thYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str5thYrM);
		j += 6;
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("5") ==0 &&
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str5thYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str5thYrF);
		j += 6;
	}
	//6th year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("6") ==0 &&
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str6thYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str6thYrM);
		j += 6;
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("6") ==0 &&
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str6thYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str6thYrF);
		j += 6;
	}
	//yr level not found.. 
	if(iSubTotal == 0) {
		System.out.println("------ Wrong Yr Level in Enrollment Summary ----------");
		System.out.println(" Course Name : "+vRetResult.elementAt(j+1));
		System.out.println(" strMajorName : "+vRetResult.elementAt(j+2));
		System.out.println(" Year Level : "+vRetResult.elementAt(j+3));
		System.out.println(" Gender : "+vRetResult.elementAt(j+4));
		
		j += 6;
	}
	iSubGrandTotal += iSubTotal;
i = j;


	%>
    <tr>
      <td height="24"><font size="1"><%=strCourseNameToDisp%></font></td>
      <td height="24"><%=WI.getStrValue(strMajorNameToDisp,"&nbsp;")%></td>
      <td><font size="1"><%=WI.getStrValue(str1stYrM,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str1stYrF,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str2ndYrM,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str2ndYrF,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str3rdYrM,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str3rdYrF,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str4thYrM,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str4thYrF,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str5thYrM,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str5thYrF,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str6thYrM,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str6thYrF,"&nbsp;")%></font></td>
      <td><font size="1"><%=iSubTotal%></font></td>
    </tr>
<%}%>
  </table>
    <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="93%" align="right"><strong><font size="1">SUB</font><font size="1">
        TOTAL :&nbsp;&nbsp;&nbsp;</font></strong></td>
      <td width="7%" height="24"><strong><font size="1"><%=iSubGrandTotal%></font></strong></td>
    </tr>
  </table>

 <%}//outer most loop%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="93%" align="right"><strong><font size="1">GRAND TOTAL :&nbsp;&nbsp;&nbsp;</font></strong></td>
      <td width="7%" height="24"><strong><font size="1"><%=(String)vRetResult.elementAt(0)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="12%" height="25">&nbsp;</td>
      <td><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
        <font size="1">click to print enrollment summary</font></td>
    </tr>
  </table>
<%}//only if vRetResult is not null
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="reloadPage">
</form>
</body>
</html>
