<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
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
								"Admin/staff-Enrollment-Other report-Comparative Enrollment","enrollment_per_subject_offering.jsp");
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
														"all_failed_count.jsp");
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
Vector vRetResult = null;
ReportEnrollment reportE = new ReportEnrollment();
if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = reportE.getStudCountWithAllFailure(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportE.getErrMsg();
}

String strPassFailCon = null;
%>
<form action="./all_failed_count.jsp" method="post" name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr>
      <td height="25" colspan="4" align="center" bgcolor="#A49A6A" style="font-weight:bold; color:#FFFFFF">:::: ALL PASS/FAIL STATUS ::::</td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="5%" height="25"></td>
      <td width="36%">SY/Term From </td>
      <td width="59%">
<%
strTemp = WI.fillTextValue("show_con");
if(strTemp.length() == 0 || strTemp.equals("0")) {
	strErrMsg = " checked";
	strPassFailCon = " ALL FAILED";
}
else	
	strErrMsg = "";
%>
		<input type="radio" name="show_con" value="0" <%=strErrMsg%>> Show ALL FAILED 
<%
if(strTemp.equals("1")) {
	strErrMsg = " checked";
	strPassFailCon = " ALL PASSED";
}
else	
	strErrMsg = "";
%>
		<input type="radio" name="show_con" value="1" <%=strErrMsg%>> Show ALL PASSED 
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
	  <a href="javascript:PrintPg();"><img src="../../../../../images/print.gif" border="0"></a>Print page
	  &nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>
<%
String[] astrConvertTerm = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};

if(vRetResult != null && vRetResult.size() > 0) {%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td align="center"><b><%=SchoolInformation.getSchoolName(dbOP,true,false)%></b><br>
		<font size="1"><%=WI.getStrValue(SchoolInformation.getAddressLine1(dbOP,false,false),"","<br>","")%></font>
		<font  style="font-size:9px;">
		<%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>, SY 
		<%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></font>
		<br><br>
		<strong>STUDENT COUNT FOR : <%=strPassFailCon%> </strong>
		<br>		&nbsp;
	  </td>
	</tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr style="font-weight:bold">
		<td width="85%" height="18" class="thinborderBOTTOM">College Name </td>
		<td width="15%" class="thinborderBOTTOM">Count</td>
	</tr>
	<%
	int iTotal = 0;
	for(int i =0; i < vRetResult.size(); i += 2) {
		iTotal += Integer.parseInt((String)vRetResult.elementAt(i + 1));%>
		<tr>
			<td height="18" class="thinborderNONE">&nbsp;<%=vRetResult.elementAt(i)%></td>
			<td class="thinborderNONE"><%=vRetResult.elementAt(i + 1)%></td>
		</tr>
	<%}%>
		<tr style="font-weight:bold">
		  <td height="18" class="thinborderNONE" align="right">Total: &nbsp; </td>
		  <td class="thinborderNONE"><%=iTotal%></td>
    </tr>
</table>  
<%}%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
  