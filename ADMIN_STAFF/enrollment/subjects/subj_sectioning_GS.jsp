<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function CheckValidHour() {
	var vTime =document.form_.time_from_hr.value;
	if(eval(vTime) > 12 || eval(vTime) == 0) {
		alert("Time should be >0 and <= 12");
		document.form_.time_from_hr.value = "12";
	}
	vTime =document.form_.time_from_hr.value;
	if(eval(vTime) == 12 || eval(vTime) < 6)
		document.form_.time_from_AMPM.selectedIndex = 1;
	else if(eval(vTime) > 8)
		document.form_.time_from_AMPM.selectedIndex = 0;
	
	vTime =document.form_.time_to_hr.value;
	if(eval(vTime) > 12 || eval(vTime) == 0) {
		alert("Time should be >0 and <= 12");
		document.form_.time_to_hr.value = "12";
	}
		
	vTime =document.form_.time_to_hr.value;
	if(eval(vTime) == 12 || eval(vTime) < 6)
		document.form_.time_to_AMPM.selectedIndex = 1;
	else if(eval(vTime) > 8)
		document.form_.time_to_AMPM.selectedIndex = 0;
	//if it is 12, chnage it to pm.
	
	
}
function CheckValidMin() {
	if(eval(document.form_.time_from_min.value) > 59) {
		alert("Time can't be > 59");
		document.form_.time_from_min.value = "00";
	}
	if(eval(document.form_.time_to_min.value) > 59) {
		alert("Time can't be > 59");
		document.form_.time_to_min.value = "00";
	}
}
function ChangeEduLevel() {
	document.form.showdetail.value = 0;
	document.form_.submit();
	
}
</script>
<%@ page language="java" import="utility.*,enrollment.SubjectSection,java.util.Vector, java.util.Date" buffer="16kb"%>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strDegreeType = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-subject sectioning","subj_sectioning.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		strTemp = "<form name=form_><input type=hidden name=showsubject></form>";
		%><%=strTemp%><%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														"subj_sectioning.jsp");
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
%>
<body bgcolor="#D2AE72">
<form action="./sub_sectioning_GS.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        CLASS PROGRAMS PAGE ::::</strong></font></div></td>
    </tr>
	</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25" colspan="2">&lt;display error msg&gt;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">Offering SY : 
      <%
	strTemp = WI.fillTextValue("sy_from");
%> <input type="text" name="sy_from" value="<%=strTemp%>" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
      - 
      <%
	strTemp = WI.fillTextValue("sy_to");
%> <input type="text" name="sy_to" value="<%=strTemp%>" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes"></td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td width="40%" height="25">Education Level</td>
    <td width="56%">Curriculum Year (Always use current curriculum year)</td>
  </tr>
  <tr> 
    <td width="4%" height="25">&nbsp;</td>
    <td>
	<select name="g_level" onChange="ChangeEduLevel();">
		<option value="0">Select Grade Leevl</option>
 <%=dbOP.loadCombo("G_LEVEL","EDU_LEVEL_NAME +' - '+ LEVEL_NAME"," from BED_LEVEL_INFO order by G_LEVEL",strTemp,false)%> 
    </select> </td>
    <td>&lt;show cur year &gt;</td>
  </tr>
  <tr> 
    <td width="4%" height="25">&nbsp;</td>
    <td><a href="javascript:CreateNew();"><img src="../../../images/schedule.gif" border="0"></a>Create 
      new Offering</td>
    <td><a href="javascript:View();"><img src="../../../images/view.gif" border="0"></a>View/ 
      Edit offering</td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <input type="hidden" name="cy_from" value="">
  <input type="hidden" name="cy_from" value="">
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="7" bgcolor="#B9B292" align="center"><font size="1"><strong>CREATE 
        SCHEDULE</strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td align="center"><strong><font size="1">SELECT/CREATE SECTION</font></strong></td>
      <td colspan="3"> 
	  <select name="select_section" onChange="SelectSection();">
          <option value="">Select/enter new</option>
          <%=dbOP.loadComboDISTINCT("section","section",
		  " from e_sub_section where is_valid = 1 and degree_type = 5", 
		  WI.fillTextValue("section"), false)%> </select>
        <input type="text" name="section" size="20" value="<%=WI.fillTextValue("section")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeypress="if(event.keyCode==39 || event.keyCode==34) event.returnValue=false;"></td>
      <td align="center">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" width="4%"><font size="1">&nbsp;</font></td>
      <td width="25%" align="center"><font size="1"><strong>SUBJECT TITLE</strong></font></td>
      <td width="20%" align="center"><font size="1"><strong>EXISTING SCHEDULE</strong></font></td>
      <td width="20%" align="center"><font size="1"><strong>M-T-W-TH-F-SAT-S</strong></font></td>
      <td width="15%" align="center"><font size="1"><strong>TIME FROM</strong></font></td>
      <td width="16%" align="center"><font size="1"><strong>TIME TO</strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp; </td>
      <td><input type="text" name="week_day" size="16" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("week_day")%>"
	  onKeyPress=" if(event.keyCode>47 && event.keyCode < 58) event.returnValue=false;" onKeyUp="javascript:this.value=this.value.toUpperCase();"></td>
      <td><input type="text" name="time_from_hr" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_from_hr")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidHour();">
        : 
        <input type="text" name="time_from_min" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_from_min")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidMin();">
        : 
        <select name="time_from_AMPM">
          <option selected value="0">AM</option>
          <%
strTemp = WI.fillTextValue("time_from_AMPM");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
      <td><input type="text" name="time_to_hr" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_to_hr")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidHour();">
        : 
        <input type="text" name="time_to_min"  size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_to_min")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidMin();">
        : 
        <select name="time_to_AMPM">
          <option selected value="0">AM</option>
          <option value="1">PM</option>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3"><a href="javascript:AddSchedule();"><img src="../../../images/add.gif" border="0"></a>Click 
        here to ADD the class program</td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25" width="1%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#A49A6A"> 
    <td width="1%" height="25">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="showdetail" value="<%=WI.fillTextValue("showdetail")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>