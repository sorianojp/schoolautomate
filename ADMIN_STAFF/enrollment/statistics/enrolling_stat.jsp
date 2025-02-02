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
function PrintPg()
{
	///print by removing information.. 
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();
}
function CompareStat() {
	if(document.form_.prev_sy_from.value.length == 0) {
		alert("Please enter Previous School Year.");
		return;
	}
	if(document.form_.sy_from.value.length == 0) {
		alert("Please enter Current School Year.");
		return;
	}
	document.form_.reloadPage.value = "1";
}
</script>
<body>
<%@ page language="java" import="utility.*,enrollment.StatEnrollment,java.util.Vector" %>
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
								"Admin/staff-Enrollment-STATISTICS-ENROLLEES","enrolling_stat.jsp");
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
														"Enrollment","STATISTICS",request.getRemoteAddr(),
														"enrolling_stat.jsp");
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
StatEnrollment SE = new StatEnrollment();
Vector vRetResult = null;
int iTotalStudentCount = 0; 

if(WI.fillTextValue("reloadPage").length() > 0)
{
	vRetResult = SE.getEnrollingStat(dbOP, request);
	if(vRetResult == null)
		strErrMsg = SE.getErrMsg();
	else	
		iTotalStudentCount = ((Integer)vRetResult.remove(0)).intValue();
}

%>
<form action="./enrolling_stat.jsp" method="post" name="form_" onSubmit="return SubmitOnceButton(this)">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="20" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          ENROLLING STATISTICS ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
    <tr> 
      <td height="20"></td>
      <td colspan="6"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td height="20" width="2%"></td>
      <td valign="bottom">&nbsp;</td>
      <td valign="bottom"><font size="1"><strong>PREV YEAR</strong></font></td>
      <td valign="bottom"><font size="1"><strong>PREV TERM</strong></font></td>
      <td valign="bottom">&nbsp;</td>
      <td valign="bottom"><font size="1"><strong>CURRENT YEAR</strong></font></td>
      <td valign="bottom"><font size="1"><strong>TERM</strong></font></td>
    </tr>
    <tr> 
      <td height="20"></td>
      <td>&nbsp;</td>
      <td> <%
strTemp = WI.fillTextValue("prev_sy_from");
%> <input name="prev_sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
      <td><select name="prev_semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("prev_semester");
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
        </select> 
      <td> 
      <td> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
      <td><select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("semester");
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
        </select></tr>
    <tr> 
      <td height="22"></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr> 
      <td width="2%" height="20"></td>
      <td width="19%"><strong>Show By :</strong></td>
      <td colspan="2" style="font-size:9px; font-weight:bold; color:#0000FF">&nbsp;
	  <input name="is_summary" type="checkbox" value="checked" <%=WI.fillTextValue("is_summary")%>> Show Summary</td>
    </tr>
    
    <tr> 
      <td ></td>
      <td>Course</td>
      <td colspan="2"><select name="course_index" style="font-size:10px;">
          <option value="">All</option>
<%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 and IS_OFFERED=1 and IS_VISIBLE=1 order by course_name asc",
		  		request.getParameter("course_index"), false)%> 
        </select> </td>
    </tr>
    
    <tr> 
      <td height="20"></td>
      <td>Year Level</td>
      <td width="17%"><select name="year_level">
          <option value="">All</option>
          <%
strTemp =WI.fillTextValue("year_level");
if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0)
{%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0)
{%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0)
{%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select> </td>
      <td width="62%"><input type="submit" name="1" value="Generate Report" style="font-size:10px; height:25px;border: 1px solid #FF0000;"
	   onClick="CompareStat();"> &nbsp;&nbsp;<!--
	   Rows Per page  &nbsp;<select name="rows_per_page">
	   <%
	   int iDef = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_page"), "35"));
	   for(int i = 30; i < 65; ++i) {
	   	if(iDef == i)
			strTemp = " selected";
		else	
			strTemp = "";
		%><option value="<%=i%>"><%=i%></option>
		<%}%>
		</select>-->
      </td>
    </tr>
    <tr> 
      <td height="20"></td>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null){//System.out.println(vRetResult);%>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
    <tr>
      <td width="12%" height="20">&nbsp;</td>
      <td><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">click to print statement of account</font></td>
    </tr>
  </table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		  <tr>
			<td height="83"><div align="center"><font size="2">
			  <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
				<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
				<!--TIN - 004-005-307-000-NON-VAT-->
				<%=SchoolInformation.getInfo1(dbOP,false,false)%>
				<br>
				<%=WI.fillTextValue("prev_sy_from")%>(<%=WI.fillTextValue("prev_semester")%>) --- 
				<%=WI.fillTextValue("sy_from")%>(<%=WI.fillTextValue("semester")%>) 
				</font></div></td>
		  </tr>
		</table>
<%
	// I have to keep track of course programs, course, and major.
	String strCourseName    = null;

	String strPrevSY  = WI.fillTextValue("prev_sy_from");
	String strPrevSem = WI.fillTextValue("prev_semester");
	String strSY      = WI.fillTextValue("sy_from");
	String strSem     = WI.fillTextValue("semester");
	
	int iTotalThisYr  = 0;
	int iTotalNextYr  = 0;
	
	int iGTThisYr     = 0;
	int iGTNextYr     = 0;	

	
	Vector vStudList = null; int iCount = 0; String strFontColor = null;
	
	String[] astrConvertToSem = {"SU","FS","SS","TS"};
if(WI.fillTextValue("is_summary").length() == 0) {
int iRowsPerPage   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_page"), "30"));
int iTotalNoOfPage = iTotalStudentCount/iRowsPerPage;
if(iTotalStudentCount % iRowsPerPage > 0)
	++iTotalNoOfPage;

int iCurPage = 0;
int iCurRow  = 0;
	while(vRetResult.size() > 0){//outer loop for each course 
	if(iCurPage > 0 && false){%>
		<div  style="page-break-after:always">&nbsp;</div>	
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		  <tr>
			<td height="83"><div align="center"><font size="2">
			  <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
				<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
				<!--TIN - 004-005-307-000-NON-VAT-->
				<%=SchoolInformation.getInfo1(dbOP,false,false)%></font></div>
				<div align="right" style="font-size:9px;">Page <%=++iCurPage%> of <%=iTotalNoOfPage%></div></td>
		  </tr>
		</table>
	<%}%>
			
	
	
  <table  bgcolor="#000000" width="100%" cellspacing="1" cellpadding="1">
<%if(vRetResult.elementAt(0) != null) {%>
    <tr> 
      <td height="20" colspan="3" bgcolor="#CBC8C8"><strong>Course : <%=vRetResult.elementAt(0)%></strong></td>
    </tr>
<%}vStudList = (Vector)vRetResult.elementAt(1);
vRetResult.removeElementAt(0); vRetResult.removeElementAt(0);%>
    <tr style="font-size:9px; font-weight:bold;" bgcolor="#EBE8E8">
      <td height="20" colspan="3" style="font-size:9px; font-weight:bold;">Year Level : <%=WI.getStrValue((String)vStudList.elementAt(1), "N/A")%></td>
    </tr>
	<tr bgcolor="#FFFFFF">
	  <td width="4%" style="font-size:9px; font-weight:bold;" align="center">SL # </td> 
	  <td width="30%" height="24" style="font-size:9px; font-weight:bold;">Student ID </td>
	  <td width="66%" style="font-size:9px; font-weight:bold;">Student Name </td>
	</tr>
	<%for(int i = 4; i < vStudList.size(); i += 4) {
		if(vStudList.elementAt(i + 2) == null)
			strFontColor = "color:#FF0000; font-weight:bold; font-size:9px";
		else	
			strFontColor = "";%>    
		<tr bgcolor="#FFFFFF" style="<%=strFontColor%>">
		  <td width="4%">&nbsp;<%=++iCount%>.</td> 
		  <td width="30%" height="24"><%=vStudList.elementAt(i)%></td>
		  <td width="66%"><%=vStudList.elementAt(i + 1)%></td>
		</tr>
	<%}%>
    <tr bgcolor="#FFFFFF"> 
      <td height="24" colspan="3" align="right"><strong>&nbsp;&nbsp;</strong></td>
    </tr>
  </table>
<%}//while vRetResult.size() > 0 is not null
}//end of if.
if(WI.fillTextValue("is_summary").length() > 0)
	while(vRetResult.size() > 0){//outer loop for each course %>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
<%if(vRetResult.elementAt(0) != null) {%>
		<tr>
		  <td height="20" colspan="3" class="thinborder" bgcolor="#CBC8C8" style="font-weight:bold">Course : <%=vRetResult.elementAt(0)%></td>
	    </tr>
<%}vStudList = (Vector)vRetResult.elementAt(1);
vRetResult.removeElementAt(0); vRetResult.removeElementAt(0);%>
		<tr bgcolor="#EBE8E8">
		  <td width="12%" height="20" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Year Level </td>
		  <td width="44%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Total Enrolled in <%=astrConvertToSem[Integer.parseInt(request.getParameter("prev_semester"))]%>, <%=strPrevSY%> </td>
		  <td width="44%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Total Not Enrolled in <%=astrConvertToSem[Integer.parseInt(request.getParameter("semester"))]%>, <%=strSY%> </td>
	    </tr>
	  <tr>
		  <td height="20" class="thinborder" style="font-size:10px;"><%=WI.getStrValue((String)vStudList.elementAt(1), "N/A")%></td>
		  <td class="thinborder" style="font-size:10px;"><%=vStudList.elementAt(2)%></td>
		  <td class="thinborder" style="font-size:10px;"><%=vStudList.elementAt(3)%></td>
	  </tr>
	  <%
	  iTotalThisYr = ((Integer)vStudList.elementAt(2)).intValue();
	  iTotalNextYr = ((Integer)vStudList.elementAt(3)).intValue();
	  
	  iGTThisYr += ((Integer)vStudList.elementAt(2)).intValue();
	  iGTNextYr += ((Integer)vStudList.elementAt(3)).intValue();
	  
	  while(vRetResult.size() > 0 && vRetResult.elementAt(0) == null){
	  vStudList = (Vector)vRetResult.elementAt(1);vRetResult.removeElementAt(0); vRetResult.removeElementAt(0);
	  iTotalThisYr += ((Integer)vStudList.elementAt(2)).intValue();
	  iTotalNextYr += ((Integer)vStudList.elementAt(3)).intValue();
	  
	  iGTThisYr += ((Integer)vStudList.elementAt(2)).intValue();
	  iGTNextYr += ((Integer)vStudList.elementAt(3)).intValue();
	  %>
		  <tr>
			  <td height="20" class="thinborder" style="font-size:10px;"><%=WI.getStrValue((String)vStudList.elementAt(1), "N/A")%></td>
			  <td class="thinborder" style="font-size:10px;"><%=vStudList.elementAt(2)%></td>
			  <td class="thinborder" style="font-size:10px;"><%=vStudList.elementAt(3)%></td>
		  </tr>
	  <%}%>
		<tr>
		  <td height="20" class="thinborder" style="font-size:10px; font-weight:bold" align="right">TOTAL&nbsp;</td>
		  <td class="thinborder" style="font-size:10px; font-weight:bold"><%=iTotalThisYr%></td>
		  <td class="thinborder" style="font-size:10px; font-weight:bold"><%=iTotalNextYr%></td>
	  </tr>
<%if(vRetResult.size() == 0) {%>
		<tr>
		  <td height="20" class="thinborder" style="font-size:10px; font-weight:bold" align="right">GRAND TOTAL&nbsp;</td>
		  <td class="thinborder" style="font-size:10px; font-weight:bold"><%=iGTThisYr%></td>
		  <td class="thinborder" style="font-size:10px; font-weight:bold"><%=iGTNextYr%></td>
	  </tr>
<%}//print grand total before exiting.. %>
  </table>
<%}%>
<%}//show only if vRetResult is not null. %>

<input type="hidden" name="reloadPage">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
