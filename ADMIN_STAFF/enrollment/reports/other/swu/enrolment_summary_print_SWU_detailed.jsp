<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print page</title>
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
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
<script language="JavaScript">
function submitForm() {
	document.form_.reloadPage.value='1';	
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";	
	document.forms[0].style.visibility = "hidden";
	document.forms[0].submit();
}

function PrintPg()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myID1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
		
	var obj1 = document.getElementById('myID2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);	
		
	
	document.getElementById('myID3').deleteRow(0);	
	
	//alert("Click OK to print this page");
	window.print();//called to remove rows, make bg white and call print.	
}


</script>
</head>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.
	String strErrMsg = null;
	int iTemp = 0;
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
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String strSchCode = dbOP.getSchoolIndex();
if(strSchCode == null)
	strSchCode = "";//for UI, the detrails are different from others. UI adds elementary details.

//I have to get if this is per college or per course program.
boolean bolIsGroupByCollege = WI.getStrValue(WI.fillTextValue("g_by"), "1").equals("2");


ReportEnrollment reportEnrollment = new ReportEnrollment();
Vector vRetResult = null;
Vector vRetResultBasic = null;

if(WI.fillTextValue("reloadPage").length() > 0){
	vRetResult = reportEnrollment.getEnrollmentSummary(dbOP, request, true);
	if(vRetResult == null)
		strErrMsg = reportEnrollment.getErrMsg();
}


String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};

	
String strCourseMajorName = null;

	
Vector vCollegeList = new Vector();
strTemp = "select c_code, c_name from college where is_del =0 order by c_code";	
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
while(rs.next()){
	vCollegeList.addElement(rs.getString(1));
	vCollegeList.addElement(rs.getString(2));
}
rs.close();

%>
<form action="./enrolment_summary_print_SWU_detailed.jsp" method="post" name="form_">
<%
if(strErrMsg != null){%>
<table>
	<tr>
		<td>
			<font size="3"> <strong><%=strErrMsg%></strong></font>
		</td>
	</tr>
</table>
<%
dbOP.cleanUP();
return;
}%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myID1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          SUMMARY REPORT ON ENROLMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID2">
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
      <td width="38%">
	  <input type="button" name="Login" value="Generate Report" onClick="submitForm();">	  </td>
    </tr>

    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>











<% 	
int iDefRowPerPg = 35;
int iCurRow = 0;
if(vRetResult != null){//System.out.println(vRetResult);
	// I have to keep track of course programs, course, and major.
	String strCourseProgram = null;
	String strCourseName    = null;
	String strMajorName     = null;
	
	//displays the coruse name and major name only if major and course names are different :-)
	String strCourseNameToDisp = null;
	String strMajorNameToDisp  = null;
	String[] astrConvertSem = {"Summer", "First Semester", "Second Semester", "Third Semester"};
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
	
	
	int iIndexOf = 0; String strTotNew = null; String strTotOld = null;

	int iSubGrandTotal = 0;
	
	boolean bolReset = false;
	boolean bolShowTotal = false;
	int[] ariMFperYear = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	
	for(int i = 1; i< vRetResult.size() ;){//outer loop for each course program.
	
	if(bolShowTotal)	
		ariMFperYear = new int[12];
	bolShowTotal = false;
	strCourseProgram = (String)vRetResult.elementAt(i);
	strCourseName = null;	
	
	if(bolReset || i == 1) {
		if(bolReset){
			bolReset = false;
	%>
			<DIV style="page-break-after:always">&nbsp;</DIV>	  
	<%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myID3">	
	<tr><td colspan="4" align="right"><a href="javascript:PrintPg();"><img src="../../../../../images/print.gif"  border="0"></a>
		<font size="1">Click to print report</font>
	</td></tr>
	<tr>
		<td width="14%" valign="top"> <img src="../../../../../images/logo/<%=strSchCode%>.gif" width="90" height="90" border="0"></td>
		<td width="86%" valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
				<tr><td colspan="2"><strong><font size="+2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong></td></tr>
				<tr>
					<td height="20" width="54%" style="font-size:15px; font-weight:bold;">Electronic Data Processing</td>
					<%if(strSchCode.startsWith("SWU")){%>
					<td width="46%" rowspan="2" valign="top">		
						<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
							<tr><td width="18%"><i><font size="1">Phone: </font></i></td>
							<td width="82%"><i><font size="1">415-5555 loc. 134</font></i></td>
							</tr>
							<tr><td><i><font size="1">Website: </font></i></td><td><i><font size="1" color="#0000FF"><u>swu.edu.ph</u></font></i></td></tr>
							<tr><td><i><font size="1">E-mail: </font></i></td><td><i><font size="1">edp@swu.edu.ph</font></i></td></tr>
						</table>
					
					</td>
					<%}%>
				</tr>
				<%
				strTemp = WI.getStrValue(SchoolInformation.getAddressLine1(dbOP,false,false));
				strTemp += WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false), ", ","","");
				%>
				<tr><td height="20" style="font-size:12px;"><%=strTemp%></td></tr>
			</table>
	  </td>
	</tr>	
	<tr><td colspan="2" align="center" valign="bottom" height="30">
		<font size="3"><strong>ENROLLMENT DATA</strong></font>
	</td></tr>
	<tr><td colspan="2" align="center" height="20"><strong>
		<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%></strong></td></tr>	
	<tr><td colspan="2" height="10"></td></tr>
</table>
	<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  	<%++iCurRow;%>
    <tr> 
      <td height="20" colspan="24"><strong><%=((String)vCollegeList.elementAt(vCollegeList.indexOf(strCourseProgram) + 1)).toUpperCase()%></strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">

<%++iCurRow;%>
    <tr align="center" style="font-weight:bold; background-color:#999999;"> 
      <td class="thinborder"><font size="1">YEAR</font></td>
      <td height="24" colspan="3" class="thinborder"><font size="1">1ST YEAR</font></td>
      <td colspan="3" class="thinborder"><font size="1">2ND YEAR</font></td>
      <td colspan="3" class="thinborder"><font size="1">3RD YEAR</font></td>
      <td colspan="3" class="thinborder"><font size="1">4TH YEAR</font></td>
      <td colspan="3" class="thinborder"><font size="1">5TH YEAR</font></td>
      <td colspan="3" class="thinborder"><font size="1">TOTAL</font></td>     
    </tr>
<%++iCurRow;%>
    <tr align="center" style="font-weight:bold; background-color:#999999;"> 
		<td class="thinborder"><font size="1">COURSE</font></td>
      <td width="4%" height="24" class="thinborder"><font size="1">M</font></td>
      <td width="4%" class="thinborder"><font size="1">F</font></td>
	  <td width="4%" class="thinborder"><font size="1">T</font></td>
      <td width="4%" class="thinborder"><font size="1">M</font></td>
      <td width="4%" class="thinborder"><font size="1">F</font></td>
	  <td width="4%" class="thinborder"><font size="1">T</font></td>
      <td width="4%" class="thinborder"><font size="1">M</font></td>
      <td width="4%" class="thinborder"><font size="1">F</font></td>
	  <td width="4%" class="thinborder"><font size="1">T</font></td>
      <td width="4%" class="thinborder"><font size="1">M</font></td>
      <td width="4%" class="thinborder"><font size="1">F</font></td>
	  <td width="4%" class="thinborder"><font size="1">T</font></td>
      <td width="4%" class="thinborder"><font size="1">M</font></td>
      <td width="4%" class="thinborder"><font size="1">F</font></td>
	  <td width="4%" class="thinborder"><font size="1">T</font></td>
      <td width="4%" class="thinborder"><font size="1">M</font></td>
      <td width="4%" class="thinborder"><font size="1">F</font></td>
	  <td width="4%" class="thinborder"><font size="1">T</font></td>
    </tr>
	<%
	
	for(int j = i; j< vRetResult.size();){//Inner loop for course/major for a course program.
	if(strCourseProgram.compareTo((String)vRetResult.elementAt(j)) != 0){
		bolShowTotal = true;
		break; //go back to main loop.
	}

	strCourseMajorName = ((String)vRetResult.elementAt(j+1) + WI.getStrValue((String)vRetResult.elementAt(j+2), "-","","")).toUpperCase();

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
		ariMFperYear[0] += Integer.parseInt(str1stYrM);
		j += 6;	
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("1") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str1stYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str1stYrF);
		ariMFperYear[1] += Integer.parseInt(str1stYrF);
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
		ariMFperYear[2] += Integer.parseInt(str2ndYrM);
		j += 6;	
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("2") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str2ndYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str2ndYrF);
		ariMFperYear[3] += Integer.parseInt(str2ndYrF);
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
		ariMFperYear[4] += Integer.parseInt(str3rdYrM);
		j += 6;	
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("3") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str3rdYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str3rdYrF);
		ariMFperYear[5] += Integer.parseInt(str3rdYrF);
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
		ariMFperYear[6] += Integer.parseInt(str4thYrM);
		j += 6;	
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("4") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str4thYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str4thYrF);
		ariMFperYear[7] += Integer.parseInt(str4thYrF);
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
		ariMFperYear[8] += Integer.parseInt(str5thYrM);
		j += 6;	
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("5") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str5thYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str5thYrF);
		ariMFperYear[9] += Integer.parseInt(str5thYrF);
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
		ariMFperYear[10] += Integer.parseInt(str6thYrM);
		j += 6;	
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("6") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str6thYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str6thYrF);
		ariMFperYear[11] += Integer.parseInt(str6thYrF);
		j += 6;	
	}
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
      <td height="24" class="thinborder"><%=strCourseMajorName%></td>
      <td class="thinborder" align="right"><font size="1"><%=WI.getStrValue(str1stYrM,"&nbsp;")%></font></td>
      <td class="thinborder" align="right"><font size="1"><%=WI.getStrValue(str1stYrF,"&nbsp;")%></font></td>
	  <%
	  iTemp = Integer.parseInt(WI.getStrValue(str1stYrF,"0")) + Integer.parseInt(WI.getStrValue(str1stYrM,"0"));
	  strTemp = Integer.toString(iTemp);
	  if(iTemp == 0)
	  	strTemp = "&nbsp;";
	  %>
	  <td class="thinborder" align="right"><font size="1"><%=strTemp%></font></td>
      <td class="thinborder" align="right"><font size="1"><%=WI.getStrValue(str2ndYrM,"&nbsp;")%></font></td>
      <td class="thinborder" align="right"><font size="1"><%=WI.getStrValue(str2ndYrF,"&nbsp;")%></font></td>
	  <%
	  iTemp = Integer.parseInt(WI.getStrValue(str2ndYrF,"0")) + Integer.parseInt(WI.getStrValue(str2ndYrM,"0"));
	  strTemp = Integer.toString(iTemp);
	  if(iTemp == 0)
	  	strTemp = "&nbsp;";
	  %>
	  <td class="thinborder" align="right"><font size="1"><%=strTemp%></font></td>
      <td class="thinborder" align="right"><font size="1"><%=WI.getStrValue(str3rdYrM,"&nbsp;")%></font></td>
      <td class="thinborder" align="right"><font size="1"><%=WI.getStrValue(str3rdYrF,"&nbsp;")%></font></td>
	  <%
	  iTemp = Integer.parseInt(WI.getStrValue(str3rdYrF,"0")) + Integer.parseInt(WI.getStrValue(str3rdYrM,"0"));
	  strTemp = Integer.toString(iTemp);
	  if(iTemp == 0)
	  	strTemp = "&nbsp;";
	  %>
	  <td class="thinborder" align="right"><font size="1"><%=strTemp%></font></td>
      <td class="thinborder" align="right"><font size="1"><%=WI.getStrValue(str4thYrM,"&nbsp;")%></font></td>
      <td class="thinborder" align="right"><font size="1"><%=WI.getStrValue(str4thYrF,"&nbsp;")%></font></td>
	  <%
	  iTemp = Integer.parseInt(WI.getStrValue(str4thYrF,"0")) + Integer.parseInt(WI.getStrValue(str4thYrM,"0"));
	  strTemp = Integer.toString(iTemp);
	  if(iTemp == 0)
	  	strTemp = "&nbsp;";
	  %>
	  <td class="thinborder" align="right"><font size="1"><%=strTemp%></font></td>
      <td class="thinborder" align="right"><font size="1"><%=WI.getStrValue(str5thYrM,"&nbsp;")%></font></td>
      <td class="thinborder" align="right"><font size="1"><%=WI.getStrValue(str5thYrF,"&nbsp;")%></font></td>
	  <%
	  iTemp = Integer.parseInt(WI.getStrValue(str5thYrF,"0")) + Integer.parseInt(WI.getStrValue(str5thYrM,"0"));
	  strTemp = Integer.toString(iTemp);
	  if(iTemp == 0)
	  	strTemp = "&nbsp;";
	  %>
	  <td class="thinborder" align="right"><font size="1"><%=strTemp%></font></td>
      
    <td class="thinborder" align="right"><font size="1">
      
      <%=Integer.parseInt(WI.getStrValue(str1stYrM,"0"))+Integer.parseInt(WI.getStrValue(str2ndYrM,"0"))+Integer.parseInt(WI.getStrValue(str3rdYrM,"0"))+
	  Integer.parseInt(WI.getStrValue(str4thYrM,"0"))+Integer.parseInt(WI.getStrValue(str5thYrM,"0"))%> 
      
      </font></td>
      
    <td class="thinborder" align="right"><font size="1"> 
      
      <%=Integer.parseInt(WI.getStrValue(str1stYrF,"0"))+Integer.parseInt(WI.getStrValue(str2ndYrF,"0"))+Integer.parseInt(WI.getStrValue(str3rdYrF,"0"))+
	  Integer.parseInt(WI.getStrValue(str4thYrF,"0"))+Integer.parseInt(WI.getStrValue(str5thYrF,"0"))%> 
     
      </font></td>

      <td class="thinborder" align="right"><font size="1"><%=iSubTotal%></font></td>
    </tr>
<%
	++iCurRow;
	if(iCurRow >= iDefRowPerPg) {
		bolReset = true;
		iCurRow = 0;
		break;
	}

} 

if(bolShowTotal || i >= vRetResult.size()){
%>
	<tr>
		<td height="24" class="thinborder" align="center"><font size="1"><strong>TOTAL</strong></font></td>
		
		<td class="thinborder" align="right"><font size="1"><strong><%=ariMFperYear[0]%></strong></font></td>
		<td class="thinborder" align="right"><font size="1"><strong><%=ariMFperYear[1]%></strong></font></td>
		<td class="thinborder" align="right"><font size="1"><strong><%=ariMFperYear[0] + ariMFperYear[1]%></strong></font></td>
		
		<td class="thinborder" align="right"><font size="1"><strong><%=ariMFperYear[2]%></strong></font></td>
		<td class="thinborder" align="right"><font size="1"><strong><%=ariMFperYear[3]%></strong></font></td>
		<td class="thinborder" align="right"><font size="1"><strong><%=ariMFperYear[2] + ariMFperYear[3]%></strong></font></td>
		
		<td class="thinborder" align="right"><font size="1"><strong><%=ariMFperYear[4]%></strong></font></td>
		<td class="thinborder" align="right"><font size="1"><strong><%=ariMFperYear[5]%></strong></font></td>
		<td class="thinborder" align="right"><font size="1"><strong><%=ariMFperYear[5] + ariMFperYear[4]%></strong></font></td>
		
		<td class="thinborder" align="right"><font size="1"><strong><%=ariMFperYear[6]%></strong></font></td>
		<td class="thinborder" align="right"><font size="1"><strong><%=ariMFperYear[7]%></strong></font></td>
		<td class="thinborder" align="right"><font size="1"><strong><%=ariMFperYear[6] + ariMFperYear[7]%></strong></font></td>
		
		<td class="thinborder" align="right"><font size="1"><strong><%=ariMFperYear[8]%></strong></font></td>
		<td class="thinborder" align="right"><font size="1"><strong><%=ariMFperYear[9]%></strong></font></td>
		<td class="thinborder" align="right"><font size="1"><strong><%=ariMFperYear[8] + ariMFperYear[9]%></strong></font></td>
		<%
		iTemp = ariMFperYear[0] + ariMFperYear[2] + ariMFperYear[4] + ariMFperYear[6] + ariMFperYear[8]; 
		%>
      	<td class="thinborder" align="right"><font size="1"><strong><%=iTemp%></strong></font></td>
		<%
		iTemp = ariMFperYear[1] + ariMFperYear[3] + ariMFperYear[5] + ariMFperYear[7] + ariMFperYear[9]; 
		%>
      	<td class="thinborder" align="right"><font size="1"><strong><%=iTemp%></strong></font></td>
		<%
		iTemp = ariMFperYear[1] + ariMFperYear[3] + ariMFperYear[5] + ariMFperYear[7] + ariMFperYear[9] + 
			ariMFperYear[0] + ariMFperYear[2] + ariMFperYear[4] + ariMFperYear[6] + ariMFperYear[8];
		%>
      	<td class="thinborder" align="right"><font size="1"><strong><%=iTemp%></strong></font></td>
    </tr>
<%}%>
  </table>
<%}//end outer loop


}//only if vRetResult is not null%>
<input type="hidden" name="summary_of_roe" value="<%=WI.fillTextValue("summary_of_roe")%>">
<input type="hidden" name="reloadPage">
</form>


<!--- Processing Div --->

<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div>
</body>
</html>
<%
dbOP.cleanUP();
%>