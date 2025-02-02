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
								"Admin/staff-Enrollment-Other report-Comparative Enrollment","overall_enrollment.jsp");
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
														"overall_enrollment.jsp");
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
	vRetResult = reportE.overallEnrollmentSummary(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportE.getErrMsg();
}

String strSchoolName = null;
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
if(strSchCode.startsWith("WNU"))
	strSchoolName = "<b>West Negros University </b><br><font size='1'>(Formerly West Negros College)<br>Bacolod City, Philippines</font><br>";
else	
	strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false)+"<BR>";
%>
<form action="./overall_enrollment.jsp" method="post" name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr>
      <td height="25" colspan="4" align="center" bgcolor="#A49A6A" style="font-weight:bold; color:#FFFFFF">:::: OVERALL ENROLLMENT SUMMARY ::::</td>
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
		int iRowsPerPg = Integer.parseInt(WI.getStrValue(WI.fillTextValue("lines_per_pg"), "35"));
		for(int i = 35; i < 60; ++i) {
			if(i == iRowsPerPg)
				strTemp = "selected";
			else	
				strTemp = "";
		%><option value="<%=i%>" <%=strTemp%>><%=i%></option>
		<%}%>
	  </select>
	  
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
        </select>          
      <td><input name="submit" type="submit" value="Generate Report">
    </tr>
    <tr>
      <td height="10"></td>
      <td align="right">&nbsp;</td>
      <td align="right">
	  <a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>Print page
	  &nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>
<%	int iPageCount = 1; int iGT = 0;
	int iRowCount  = 1; boolean bolPreventPrint = false;
	
if(vRetResult != null){//System.out.println(vRetResult);
    Vector vCollege = (Vector)vRetResult.remove(0);
	Vector vSummary = (Vector)vRetResult.remove(0);
	
	Vector vDetail = (Vector)vRetResult.remove(0);
	Vector vCourse = (Vector)vRetResult.remove(0);
	
	String[] astrConvertTerm = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td align="center"><%=strSchoolName%>
		<font  style="font-size:9px;">
		<%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%> SY 
		<%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%><BR>
		Date and Time Generated : <%=WI.getTodaysDateTime()%></font>
		<br><br>
		<strong>OVERALL ENROLLMENT <b>SUMMARY</b></strong>
		<br>		
	  </td>
	</tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	
	<tr style="font-weight:bold" align="center">
	  <td width="25%" rowspan="2" class="thinborder">COLLEGES/ACADEMIC DEPT</td>
	  <td width="8%" colspan="2" class="thinborder">I</td>
      <td width="8%" colspan="2" class="thinborder">II</td>
      <td width="8%" colspan="2" class="thinborder">III</td>
      <td width="8%" colspan="2" class="thinborder">IV</td>
      <td width="8%" colspan="2" class="thinborder">V</td>
      <td width="8%" colspan="2" class="thinborder">VI</td>
      <td width="8%" colspan="2" class="thinborder">VII</td>
      <td width="8%" colspan="2" class="thinborder">TOTAL</td>
      <td class="thinborder" width="8%">&nbsp;</td>
	</tr>
	<tr style="font-weight:bold" align="center">
	  <td class="thinborder" width="4%">M</td>
      <td class="thinborder" width="4%">F</td>
      <td class="thinborder" width="4%">M</td>
      <td class="thinborder" width="4%">F</td>
      <td class="thinborder" width="4%">M</td>
      <td class="thinborder" width="4%">F</td>
      <td class="thinborder" width="4%">M</td>
      <td class="thinborder" width="4%">F</td>
      <td class="thinborder" width="4%">M</td>
      <td class="thinborder" width="4%">F</td>
      <td class="thinborder" width="4%">M</td>
      <td class="thinborder" width="4%">F</td>
      <td class="thinborder" width="4%">M</td>
      <td class="thinborder" width="4%">F</td>
      <td class="thinborder" width="4%">M</td>
      <td class="thinborder" width="4%">F</td>
      <td class="thinborder">TOTAL</td>
	</tr>
<%
Double objDTemp = null;
int iIndexOf = 0;  

int iML1 = 0; int iML1Column = 0;
int iML2 = 0; int iML2Column = 0;
int iML3 = 0; int iML3Column = 0;
int iML4 = 0; int iML4Column = 0;
int iML5 = 0; int iML5Column = 0;
int iML6 = 0; int iML6Column = 0;
int iML7 = 0; int iML7Column = 0;
int iFL1 = 0; int iFL1Column = 0;
int iFL2 = 0; int iFL2Column = 0;
int iFL3 = 0; int iFL3Column = 0;
int iFL4 = 0; int iFL4Column = 0;
int iFL5 = 0; int iFL5Column = 0;
int iFL6 = 0; int iFL6Column = 0;
int iFL7 = 0; int iFL7Column = 0;

int iMT  = 0; int iMTColumn  = 0;
int iFT  = 0; int iFTColumn  = 0;

int iTempYr = 0; String strGender = null; int iTemp = 0;
for(int i =0; i < vCollege.size(); i += 2, ++iRowCount) {
objDTemp = (Double)vCollege.elementAt(i);
//get sy from info
iIndexOf = vSummary.indexOf(objDTemp);
iML1 = 0; iML2 = 0; iML3 = 0; iML4 = 0;iML5 = 0;iML6 = 0;iML7 = 0;iFL1 = 0;iFL2 = 0;iFL3 = 0;iFL4 = 0;iFL5 = 0;iFL6 = 0;iFL7 = 0;
while(iIndexOf > -1) {
	iTemp     = Integer.parseInt(WI.getStrValue((String)vSummary.elementAt(iIndexOf + 3), "1"));
	iTempYr   = Integer.parseInt(WI.getStrValue((String)vSummary.elementAt(iIndexOf + 1), "1"));
	strGender = WI.getStrValue((String)vSummary.elementAt(iIndexOf + 2), "M");
	if(iTempYr == 1 && strGender.equals("M"))
		iML1 += iTemp;
	else if(iTempYr == 1 && strGender.equals("F"))
		iFL1 += iTemp;
	else if(iTempYr == 2 && strGender.equals("M"))
		iML2 = iTemp;
	else if(iTempYr == 2 && strGender.equals("F"))
		iFL2 = iTemp;
	else if(iTempYr == 3 && strGender.equals("M"))
		iML3 = iTemp;
	else if(iTempYr == 3 && strGender.equals("F"))
		iFL3 = iTemp;
	else if(iTempYr == 4 && strGender.equals("M"))
		iML4 = iTemp;
	else if(iTempYr == 4 && strGender.equals("F"))
		iFL4 = iTemp;
	else if(iTempYr == 5 && strGender.equals("M"))
		iML5 = iTemp;
	else if(iTempYr == 5 && strGender.equals("F"))
		iFL5 = iTemp;
	else if(iTempYr == 6 && strGender.equals("M"))
		iML6 = iTemp;
	else if(iTempYr == 6 && strGender.equals("F"))
		iFL6 = iTemp;
	else if(iTempYr == 7 && strGender.equals("M"))
		iML7 = iTemp;
	else if(iTempYr == 7 && strGender.equals("F"))
		iFL7 = iTemp;
	vSummary.remove(iIndexOf);vSummary.remove(iIndexOf);vSummary.remove(iIndexOf);vSummary.remove(iIndexOf);
	if(vSummary.size() > 0) 
		iIndexOf = vSummary.indexOf(objDTemp);	
	else	
		iIndexOf = -1;
}
iML1Column += iML1;  iML2Column += iML2; iML3Column += iML3; iML4Column += iML4; iML5Column += iML5; iML6Column += iML6; iML7Column += iML7;
iFL1Column += iFL1;  iFL2Column += iFL2; iFL3Column += iFL3; iFL4Column += iFL4; iFL5Column += iFL5; iFL6Column += iFL6; iFL7Column += iFL7;
%>
	<tr>
	  <td class="thinborder" height="22"><%=vCollege.elementAt(i + 1)%></td>
	  <td align="center" class="thinborder"><%=iML1%></td>
      <td align="center" class="thinborder"><%=iFL1%></td>
      <td align="center" class="thinborder"><%=iML2%></td>
      <td align="center" class="thinborder"><%=iFL2%></td>
      <td align="center" class="thinborder"><%=iML3%></td>
      <td align="center" class="thinborder"><%=iFL3%></td>
      <td align="center" class="thinborder"><%=iML4%></td>
      <td align="center" class="thinborder"><%=iFL4%></td>
      <td align="center" class="thinborder"><%=iML5%></td>
      <td align="center" class="thinborder"><%=iFL5%></td>
      <td align="center" class="thinborder"><%=iML6%></td>
      <td align="center" class="thinborder"><%=iFL6%></td>
      <td align="center" class="thinborder"><%=iML7%></td>
      <td align="center" class="thinborder"><%=iFL7%></td>
      <td align="center" class="thinborder"><%=iML1 + iML2 + iML3 + iML4 + iML5 + iML6 + iML7%></td>
      <td align="center" class="thinborder"><%=iFL1 + iFL2 + iFL3 + iFL4 + iFL5 + iFL6 + iFL7%></td>
      <td align="center" class="thinborder"><%=iML1 + iML2 + iML3 + iML4 + iML5 + iML6 + iML7 + iFL1 + iFL2 + iFL3 + iFL4 + iFL5 + iFL6 + iFL7%></td>
	</tr>  
<%}
iGT = iML1Column + iML2Column + iML3Column + iML4Column + iML5Column + iML6Column + iML7Column + iFL1Column + iFL2Column + iFL3Column + iFL4Column + iFL5Column + iFL6Column + iFL7Column;%>
	<tr style="font-weight:bold">
	  <td class="thinborder" height="22">TOTALS</td>
	  <td align="center" class="thinborder"><%=iML1Column%></td>
      <td align="center" class="thinborder"><%=iFL1Column%></td>
      <td align="center" class="thinborder"><%=iML2Column%></td>
      <td align="center" class="thinborder"><%=iFL2Column%></td>
      <td align="center" class="thinborder"><%=iML3Column%></td>
      <td align="center" class="thinborder"><%=iFL3Column%></td>
      <td align="center" class="thinborder"><%=iML4Column%></td>
      <td align="center" class="thinborder"><%=iFL4Column%></td>
      <td align="center" class="thinborder"><%=iML5Column%></td>
      <td align="center" class="thinborder"><%=iFL5Column%></td>
      <td align="center" class="thinborder"><%=iML6Column%></td>
      <td align="center" class="thinborder"><%=iFL6Column%></td>
      <td align="center" class="thinborder"><%=iML7Column%></td>
      <td align="center" class="thinborder"><%=iFL7Column%></td>
      <td align="center" class="thinborder"><%=iML1Column + iML2Column + iML3Column + iML4Column + iML5Column + iML6Column + iML7Column%></td>
      <td align="center" class="thinborder"><%=iFL1Column + iFL2Column + iFL3Column + iFL4Column + iFL5Column + iFL6Column + iFL7Column%></td>
      <td align="center" class="thinborder"><%=iGT%></td>
	</tr>  
</table>
<%++iRowCount; 
////I have to print here detail....
String strTempCourse = null;
String strTempMajor  = null;
iML1Column = 0; iML2Column = 0; iML3Column = 0; iML4Column = 0; iML5Column = 0; iML6Column = 0; iML7Column = 0;
iFL1Column = 0; iFL2Column = 0; iFL3Column = 0; iFL4Column = 0; iFL5Column = 0; iFL6Column = 0; iFL7Column = 0;
while(vDetail.size() > 0) {
if( (iRowCount + 2) >= iRowsPerPg) {
iRowCount = 1;
%>
<table width="100%">
<tr>
	<td style="font-size:9px;">Printed By : <%=(String)request.getSession(false).getAttribute("first_name")%></td>
	<td style="font-size:9px;" align="right">Page <%=iPageCount%> of <label id="total_pg<%=iPageCount%>"></label></td>
</tr>
</table>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<table width="100%"><tr><td align="center"><strong>OVERALL ENROLLMENT <b>SUMMARY</b></strong></td></tr></table>
<%	
++iPageCount;
}
	if(vDetail.elementAt(0) != null){
		++iRowCount;%>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr>
				<td height="30"><strong><%=vDetail.elementAt(0)%></strong></td>
			</tr>
		</table>
  <%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
	<tr style="font-weight:bold" align="center">
	  <td width="25%" rowspan="2" class="thinborder">&nbsp;</td>
	  <td width="8%" colspan="2" class="thinborder">I</td>
      <td width="8%" colspan="2" class="thinborder">II</td>
      <td width="8%" colspan="2" class="thinborder">III</td>
      <td width="8%" colspan="2" class="thinborder">IV</td>
      <td width="8%" colspan="2" class="thinborder">V</td>
      <td width="8%" colspan="2" class="thinborder">VI</td>
      <td width="8%" colspan="2" class="thinborder">VII</td>
      <td width="8%" colspan="2" class="thinborder">TOTAL</td>
      <td class="thinborder" width="8%">&nbsp;</td>
	</tr>
	<tr style="font-weight:bold" align="center">
	  <td class="thinborder" width="4%">M</td>
      <td class="thinborder" width="4%">F</td>
      <td class="thinborder" width="4%">M</td>
      <td class="thinborder" width="4%">F</td>
      <td class="thinborder" width="4%">M</td>
      <td class="thinborder" width="4%">F</td>
      <td class="thinborder" width="4%">M</td>
      <td class="thinborder" width="4%">F</td>
      <td class="thinborder" width="4%">M</td>
      <td class="thinborder" width="4%">F</td>
      <td class="thinborder" width="4%">M</td>
      <td class="thinborder" width="4%">F</td>
      <td class="thinborder" width="4%">M</td>
      <td class="thinborder" width="4%">F</td>
      <td class="thinborder" width="4%">M</td>
      <td class="thinborder" width="4%">F</td>
      <td class="thinborder">TOTAL</td>
	</tr>
<%++iRowCount;

while(vDetail.size() > 0) {
iML1 = 0; iML2 = 0; iML3 = 0; iML4 = 0;iML5 = 0;iML6 = 0;iML7 = 0;iFL1 = 0;iFL2 = 0;iFL3 = 0;iFL4 = 0;iFL5 = 0;iFL6 = 0;iFL7 = 0;
strTempCourse = (String)vDetail.elementAt(1);
strTempMajor  = WI.getStrValue((String)vDetail.elementAt(2));
while(vDetail.size() > 0) {
	if(!strTempCourse.equals(vDetail.elementAt(1)) || !strTempMajor.equals(WI.getStrValue((String)vDetail.elementAt(2)))) 
		break;	
	iTemp     = Integer.parseInt(WI.getStrValue((String)vDetail.elementAt(5), "1"));//count
	iTempYr   = Integer.parseInt(WI.getStrValue((String)vDetail.elementAt(3), "1"));
	strGender = WI.getStrValue((String)vDetail.elementAt(4), "M");
	
	if(iTempYr == 1 && strGender.equals("M"))
		iML1 += iTemp;
	else if(iTempYr == 1 && strGender.equals("F"))
		iFL1 += iTemp;
	else if(iTempYr == 2 && strGender.equals("M"))
		iML2 = iTemp;
	else if(iTempYr == 2 && strGender.equals("F"))
		iFL2 = iTemp;
	else if(iTempYr == 3 && strGender.equals("M"))
		iML3 = iTemp;
	else if(iTempYr == 3 && strGender.equals("F"))
		iFL3 = iTemp;
	else if(iTempYr == 4 && strGender.equals("M"))
		iML4 = iTemp;
	else if(iTempYr == 4 && strGender.equals("F"))
		iFL4 = iTemp;
	else if(iTempYr == 5 && strGender.equals("M"))
		iML5 = iTemp;
	else if(iTempYr == 5 && strGender.equals("F"))
		iFL5 = iTemp;
	else if(iTempYr == 6 && strGender.equals("M"))
		iML6 = iTemp;
	else if(iTempYr == 6 && strGender.equals("F"))
		iFL6 = iTemp;
	else if(iTempYr == 7 && strGender.equals("M"))
		iML7 = iTemp;
	else if(iTempYr == 7 && strGender.equals("F"))
		iFL7 = iTemp;
	vDetail.remove(0);vDetail.remove(0);vDetail.remove(0);vDetail.remove(0);vDetail.remove(0);vDetail.remove(0);
}
iML1Column += iML1;  iML2Column += iML2; iML3Column += iML3; iML4Column += iML4; iML5Column += iML5; iML6Column += iML6; iML7Column += iML7;
iFL1Column += iFL1;  iFL2Column += iFL2; iFL3Column += iFL3; iFL4Column += iFL4; iFL5Column += iFL5; iFL6Column += iFL6; iFL7Column += iFL7;

%>
	<tr align="center">
	  <td class="thinborder" align="left" height="22"><%=strTempCourse+WI.getStrValue(strTempMajor, " - ","","")%></td>
	  <td class="thinborder"><%=iML1%></td>
	  <td class="thinborder"><%=iFL1%></td>
	  <td class="thinborder"><%=iML2%></td>
	  <td class="thinborder"><%=iFL2%></td>
	  <td class="thinborder"><%=iML3%></td>
	  <td class="thinborder"><%=iFL3%></td>
	  <td class="thinborder"><%=iML4%></td>
	  <td class="thinborder"><%=iFL4%></td>
	  <td class="thinborder"><%=iML5%></td>
	  <td class="thinborder"><%=iFL5%></td>
	  <td class="thinborder"><%=iML6%></td>
	  <td class="thinborder"><%=iFL6%></td>
	  <td class="thinborder"><%=iML7%></td>
	  <td class="thinborder"><%=iFL7%></td>
	  <td class="thinborder"><%=iML1 + iML2 + iML3 + iML4 + iML5 + iML6 + iML7%></td>
	  <td class="thinborder"><%=iFL1 + iFL2 + iFL3 + iFL4 + iFL5 + iFL6 + iFL7%></td>
	  <td class="thinborder"><%=iML1 + iML2 + iML3 + iML4 + iML5 + iML6 + iML7 + iFL1 + iFL2 + iFL3 + iFL4 + iFL5 + iFL6 + iFL7%></td>
    </tr>
<%
	++iRowCount;
	if( iRowCount >= iRowsPerPg) {
		iRowCount = 1;
 		bolPreventPrint = true;
		break;
	}
	//System.out.println("Printing row count : "+iRowCount+" Page Count : "+iPageCount);
if(vDetail.size() > 0 && vDetail.elementAt(0) != null)
	break;
}
if(!bolPreventPrint){
++iRowCount;%>
	<tr align="center" style="font-weight:bold">
	  <td class="thinborder" align="left" height="22">Sub Total </td>
	  <td class="thinborder"><%=iML1Column%></td>
	  <td class="thinborder"><%=iFL1Column%></td>
	  <td class="thinborder"><%=iML2Column%></td>
	  <td class="thinborder"><%=iFL2Column%></td>
	  <td class="thinborder"><%=iML3Column%></td>
	  <td class="thinborder"><%=iFL3Column%></td>
	  <td class="thinborder"><%=iML4Column%></td>
	  <td class="thinborder"><%=iFL4Column%></td>
	  <td class="thinborder"><%=iML5Column%></td>
	  <td class="thinborder"><%=iFL5Column%></td>
	  <td class="thinborder"><%=iML6Column%></td>
	  <td class="thinborder"><%=iFL6Column%></td>
	  <td class="thinborder"><%=iML7Column%></td>
	  <td class="thinborder"><%=iFL7Column%></td>
	  <td class="thinborder"><%=iML1Column + iML2Column + iML3Column + iML4Column + iML5Column + iML6Column + iML7Column%></td>
	  <td class="thinborder"><%=iFL1Column + iFL2Column + iFL3Column + iFL4Column + iFL5Column + iFL6Column + iFL7Column%></td>
	  <td class="thinborder"><%=iML1Column + iML2Column + iML3Column + iML4Column + iML5Column + iML6Column + iML7Column + iFL1Column + iFL2Column + iFL3Column + iFL4Column + iFL5Column + iFL6Column + iFL7Column%></td>
    </tr>
<%
iML1Column = 0; iML2Column = 0; iML3Column = 0; iML4Column = 0; iML5Column = 0; iML6Column = 0; iML7Column = 0;
iFL1Column = 0; iFL2Column = 0; iFL3Column = 0; iFL4Column = 0; iFL5Column = 0; iFL6Column = 0; iFL7Column = 0;
}
bolPreventPrint = false;
%>
</table>	
<%if(vDetail.size() == 0) {%>

<table width="100%">
<tr>
	<td width="85%" align="right" height="35">Grand Total : </td>
	<td width="15%" align="right"><%=iGT%>&nbsp;&nbsp;<br><img src="../../../fee_assess_pay/reports/doubleline.jpg" width="100"></td>
</tr>
</table>
<table width="100%">
<tr>
	<td style="font-size:9px;" height="75">
	<%if(strSchCode.startsWith("WNU")){%>
	WNU-REG-F39 <br>
	REV 2(04-01-13)
	<%}%>
	</td>
	<td style="font-size:11px;" align="right">
	<u><%=CommonUtil.getNameForAMemberType(dbOP,"University Registrar",7).toUpperCase()%></u><br>
	Registrar&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
</tr>
</table>

<%}%>

  
<%if( iRowCount == 1 || iRowCount >= iRowsPerPg) {
iRowCount = 1;
%>
<table width="100%">
<tr valign="bottom">
	<td style="font-size:9px;">Printed By : <%=(String)request.getSession(false).getAttribute("first_name")%></td>
	<td style="font-size:9px;" align="right">Page <%=iPageCount%> of <label id="total_pg<%=iPageCount%>"></label></td>
</tr>
</table>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%if(vDetail.size() > 0) {%>
<table width="100%"><tr><td align="center"><strong>OVERALL ENROLLMENT <b>SUMMARY</b></strong></td></tr></table>
<%++iPageCount;
}//only if there is any other pages to print.. 

}%>


<%}//outer while loop.. %>

<%if( iRowCount > 1) {%>
<table width="100%">
<tr>
	<td style="font-size:9px;">Printed By : <%=(String)request.getSession(false).getAttribute("first_name")%></td>
	<td style="font-size:9px;" align="right">Page <%=iPageCount%> of <label id="total_pg<%=iPageCount%>"></label></td>
</tr>
</table>
<%}%>

<%}//show only if vRetResult is not null%>

<%if(iPageCount > 0) {//print here the total page count.. %>
	<script language="javascript">
		<%for(int i =1; i <= iPageCount; ++i) {%>
			document.getElementById("total_pg<%=i%>").innerHTML = "<%=iPageCount%>";
		<%}%>
	</script>
<%}%>
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
