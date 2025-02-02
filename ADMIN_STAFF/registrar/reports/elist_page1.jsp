<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.elist.action="./elist_page1.jsp";
	document.elist.submit();
}
function VerifyPage()
{
	if(document.elist.c_index.selectedIndex < 1)
	{
		alert("Please select a college.");
		return;
	}
	document.elist.college_name.value=document.elist.c_index[document.elist.c_index.selectedIndex].text;
	document.elist.action = "../../enrollment/reports/elist.jsp";
}
function ShowHideSubmit()
{
	if(document.elist.c_index.selectedIndex ==0)
		hideLayer('submit_');
	else
		showLayer('submit_');
}

function ShowEList(strIsBasic) {
	
	var strSYFrom   = document.elist.sy_from.value;
	var strSYTo     = document.elist.sy_to.value;
	var strSemester = document.elist.semester.value;
	
	if(strSYFrom.length == 0 || strSYTo.length == 0) {
		alert("Please enter sy/term info.");
		return;
	}
	<%if(strSchCode.startsWith("FATIMA")){%>	
		location = "../../enrollment/reports/elist_print_new_FATIMA.jsp?sy_from="+strSYFrom+
					"&sy_to="+strSYTo+"&semester="+strSemester;
		return;
	<%}%>
	<%if(strSchCode.startsWith("CSA")){%>	
		location = "../../enrollment/reports/elist_print_CSA.jsp?sy_from="+strSYFrom+
					"&sy_to="+strSYTo+"&semester="+strSemester;
		return;
	<%}%>
	if(strIsBasic == '1') {
	
		location = "../../enrollment/reports/elist_print_new_WNU_basic.jsp?sy_from="+strSYFrom+
					"&sy_to="+strSYTo+"&semester="+strSemester;
		return;
	}
	location = "../../enrollment/reports/elist_print_new_WNU.jsp?sy_from="+strSYFrom+
				"&sy_to="+strSYTo+"&semester="+strSemester;
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*" %>
<%
 
	DBOperation dbOP = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-Enrollment list","elist_page1.jsp");
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
														"elist_page1.jsp");	
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
<form action="" method="post" name="elist">  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          <%if(WI.fillTextValue("form_19").length() > 0) {%>
		  FORM - 19 <%}else{%>ENROLLMENT LIST  <%}%>PAGE::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="12%" height="25">&nbsp;</td>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
<%if(!strSchCode.startsWith("WNU") && !strSchCode.startsWith("CSA") && !strSchCode.startsWith("FATIMA")){%>    
	<tr > 
      <td height="29">&nbsp;</td>
      <td>Course Program</td>
      <td colspan="3"><select name="cc_index" onChange="ReloadPage();">
          <option value="0">Select a Program</option>
          <%=dbOP.loadCombo("cc_index","cc_name"," from CCLASSIFICATION where IS_DEL=0 order by cc_name asc", request.getParameter("cc_index"), false)%> 
        </select></td>
    </tr>
    <tr > 
      <td width="12%" height="25">&nbsp;</td>
      <td width="20%">College</td>
      <td colspan="3"><select name="c_index" onChange="ShowHideSubmit();">
          <option value="0">Select a College</option>
<%
if(WI.fillTextValue("cc_index").length() > 0 && WI.fillTextValue("cc_index").compareTo("0") != 0){
strTemp = " from college join course_offered on (college.c_index=course_offered.c_index) "+
	"join cclassification on (cclassification.cc_index=course_offered.cc_index) where college.is_del=0 and course_offered.is_del=0 and "+
	"course_offered.is_valid=1 and cclassification.cc_index="+request.getParameter("cc_index")+" order by c_name asc";
%>
          <%=dbOP.loadCombo("distinct college.c_index","c_name",strTemp, request.getParameter("c_index"), false)%> 
<%}%>
        </select></td>
    </tr>
<%}else{%>    
	<tr >
      <td height="25">&nbsp;</td>
      <td>SY-Term</td>
      <td colspan="3">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");	  
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="DisplaySYTo('elist','sy_from','sy_to');">
        to 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");	  
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
- <select name="semester">
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
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select>
	  
	  </td>

    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Report for </td>
      <td colspan="3"><a href="javascript:ShowEList(0);">College (Print all course)</a></td>
    </tr>
<%if(strSchCode.startsWith("WNU")){%>    
    <tr >
      <td height="25">&nbsp;</td>
      <td></td>
      <td colspan="3"><a href="javascript:ShowEList(1);">Basic Education</a></td>
    </tr>
<%}%>

<%}%>	
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td width="27%" height="25">&nbsp;</td>
      <td width="6%" height="25">&nbsp;</td>
      <td width="35%" height="25">&nbsp;</td>
    </tr>
    <tr > 
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td height="24"><div align="center"><input type="image" src="../../../images/form_proceed.gif" id="submit_" onClick="VerifyPage();"> 
        </div></td>
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
    </tr>
<%
if(WI.fillTextValue("c_index") == null || WI.fillTextValue("c_index").length() ==0 || WI.fillTextValue("c_index").compareTo("0") == 0){%>
<script language="JavaScript">
hideLayer('submit_');
</script>	
<%}%>
    <tr > 
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
<input type="hidden" name="college_name">
<input type="hidden" name="names_only" value="<%=WI.fillTextValue("names_only")%>">
<input type="hidden" name="format_2" value="<%=WI.fillTextValue("format_2")%>">

<input type="hidden" name="form_19" value="<%=WI.fillTextValue("form_19")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>