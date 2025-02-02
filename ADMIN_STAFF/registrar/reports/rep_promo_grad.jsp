<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg()
{
	document.rep_registrar.target="_blank";
	if(document.rep_registrar.course_index.selectedIndex > 0)
		document.rep_registrar.course_name.value =document.rep_registrar.course_index[document.rep_registrar.course_index.selectedIndex].text 
	else
	 	document.rep_registrar.course_name.value = "";
	document.rep_registrar.major_name.value =document.rep_registrar.major_index[document.rep_registrar.major_index.selectedIndex].text 
	document.rep_registrar.action ="./rep_promo_grad_print.jsp";
}
function ReloadPage()
{
	document.rep_registrar.target="_self";
	document.rep_registrar.action ="./rep_promo_grad.jsp";
	document.rep_registrar.submit();
}
function DisplaySYTo() {
	var strSYFrom = document.rep_registrar.sy_from.value;
	if(strSYFrom.length == 4)
		document.rep_registrar.sy_to.value = eval(strSYFrom) + 1;
	if(strSYFrom.length < 4)
		document.rep_registrar.sy_to.value = "";
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector, java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	String strErrMsg = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-Promotion for Graduation","rep_promo_grad.jsp");
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
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														"rep_promo_grad.jsp");
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
//get degree type to show prep/prop status.
String strDegreeType = null;
if(strDegreeType == null && WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("course_index").compareTo("selany") != 0 && WI.fillTextValue("course_index").compareTo("0") != 0)
	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",WI.fillTextValue("course_index"),"DEGREE_TYPE", " and is_valid=1 and is_del=0");

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";
	

boolean bolSPC = strSchCode.startsWith("SPC");
%>
<form action="" method="post" name="rep_registrar">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
<%if(strSchCode.startsWith("UDMC")){%>SUMMARY OF RATINGS<%}else{%>REPORT ON PROMOTION FOR GRADUATION<%}%> PAGE ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td height="25" colspan="4"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>School Year</td>
      <td width="41%"> 
	  <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");	  
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="DisplaySYTo();">
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");	  
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"></td>
      <td width="6%">Term </td>
      <td width="34%"><select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	
if(strTemp == null) 
	strTemp = "";
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
    </tr>
    <tr> 
      <td  colspan="5" height="25"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td>Course Program</td>
      <td colspan="3"><select name="cc_index" onChange="ReloadPage();">
          <option value="0">Select a Program</option>
          <%=dbOP.loadCombo("cc_index","cc_name"," from CCLASSIFICATION where IS_DEL=0 order by cc_name asc", request.getParameter("cc_index"), false)%> 
        </select></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%">Course </td>
      <td colspan="3"><font size="1">
        <input type="text" name="scroll_course" size="16" style="font-size:9px" class="textbox" 
	  onKeyUp="AutoScrollList('rep_registrar.scroll_course','rep_registrar.course_index',true);"
	   onBlur="ReloadPage()">
        (enter course code to scroll course list)</font> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4"><select name="course_index" onChange="ReloadPage();" style="font-size:11px;background:#DFDBD2;">
          <option value="">&lt;Select a course&gt;</option>
          <%
if(WI.fillTextValue("cc_index").length()>0){%>
          <%=dbOP.loadCombo("course_index","course_code+' ::: '+course_name as cname"," from course_offered where IS_DEL=0 and is_valid=1 and cc_index="+
 						request.getParameter("cc_index")+" order by cname asc", request.getParameter("course_index"), false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Major</td>
      <td height="25"><select name="major_index">
          <option value=""></option>
          <%
if(WI.fillTextValue("course_index").length()>0 && WI.fillTextValue("changeProgram").compareTo("1") != 0){
strTemp = " from major where IS_DEL=0 and course_index="+request.getParameter("course_index")+" order by major_name asc";
%>
          <%=dbOP.loadCombo("major_index","major_name"," from major where IS_DEL=0 and course_index="+
 							request.getParameter("course_index")+" order by major_name asc", request.getParameter("major_index"), false)%> 
          <%}%>
        </select></td>
      <td height="25">&nbsp;</td>
      <td height="25"> <%
//show only if degree type is not masteral.	  
if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0){%>
        Year 
        <select name="year">
			<option value=""></option>
<%
strTemp = request.getParameter("year");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("1") ==0) {%>
          <option value="1" selected>1st</option>
<%}else{%>
          <option value="1">1st</option>
<%}if(strTemp.compareTo("2") ==0) {%>
          <option value="2" selected>2nd</option>
<%}else{%>
          <option value="2">2nd</option>
<%}if(strTemp.compareTo("3") ==0){%>
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
        </select> <%}//do not show year for graduate course.
%> </td>
    </tr>
<%if(strSchCode.startsWith("UDMC")) {%>    
	<tr>
      <td height="25">&nbsp;</td>
      <td height="25">Gender</td>
      <td height="25"><select name="gender_x">
        <option value="">N/A</option>
        <%
if(WI.fillTextValue("gender").compareTo("F") == 0){%>
        <option value="F" selected>Female</option>
        <%}else{%>
        <option value="F">Female</option>
        <%}if(WI.fillTextValue("gender").compareTo("M") ==0){%>
        <option value="M" selected>Male</option>
        <%}else{%>
        <option value="M">Male</option>
        <%}%>
      </select></td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
<%}

if(strDegreeType != null && strDegreeType.compareTo("3") ==0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Select Prep/Proper</td>
      <td height="25"><select name="prep_prop_stat">
          <option value="1">Preparatory</option>
          <%
strTemp = WI.fillTextValue("prep_prop_stat");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Proper</option>
          <%}else{%>
          <option value="2">Proper</option>
          <%}%>
        </select></td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <%}%>
<%if(strSchCode.startsWith("UL") || strSchCode.startsWith("PHILCST")) {%>
    <tr >
      <td height="26">&nbsp;</td>
      <td height="26" colspan="4">Print Foreign Student Condition: 
	    <select name="print_foreign_stud">
	      <option value=""></option>
  <%
strTemp = WI.fillTextValue("print_foreign_stud");
if(strTemp.equals("0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	      <option value="0"<%=strErrMsg%>>Print Local student Only</option>
  <%
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	      <option value="1"<%=strErrMsg%>>Print Foreign student Only</option>
        </select>	  </td>
      <td height="26">&nbsp;</td>
    </tr>
    <tr >
      <td height="26">&nbsp;</td>
      <td height="26" colspan="4">Printed BY: 
        <input name="printed_by" type="text" size="32" maxlength="64" value="<%=WI.fillTextValue("printed_by")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      Designation: 
      <input name="printed_by_designation" type="text" size="32" maxlength="64" value="<%=WI.fillTextValue("printed_by_designation")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
<%}%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td height="24" colspan="4">Number of students to be printed per page : 
        <select name="stud_per_pg">
  <%
int iDefVal = 12;
strTemp = WI.fillTextValue("stud_per_pg");
if(strTemp.length() > 0) 
	iDefVal = Integer.parseInt(strTemp);
for(int i = 10; i < 51; ++i) {
if(iDefVal == i)
	strTemp = " selected";
else	
	strTemp = "";
%>
          <option value="<%=i%>" <%=strTemp%>><%=i%></option>
  <%}%>	
      </select> </td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td height="24" colspan="4">Font Size  : 
        <select name="font_size">
  <%
iDefVal = 11;
strTemp = WI.fillTextValue("font_size");
if(strTemp.length() > 0) 
	iDefVal = Integer.parseInt(strTemp);
for(int i = 10; i < 15; ++i) {
if(iDefVal == i)
	strTemp = " selected";
else	
	strTemp = "";
%>
          <option value="<%=i%>" <%=strTemp%>><%=i%> px</option>
  <%}%>	
      </select> </td>
    </tr>
<%if(bolSPC){%>
    <tr>
        <td height="24">&nbsp;</td>
        <td height="24" colspan="2">
			<input type="checkbox" name="report_format" value="1" <%=strErrMsg%>>Click to print Graduation Format.
		</td>
        <td height="24">&nbsp;</td>
        <td height="24">&nbsp;</td>
    </tr>
<%}%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td height="24"><div align="center"> 
          <input type="image" src="../../../images/print.gif" onClick="PrintPg();">
          <font size="1">click to print list</font></div></td>
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>

<table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="course_name">
<input type="hidden" name="major_name">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
