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
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../jscript/td.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.page_action.value='';
	document.form_.submit();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORT-Assign Section","assign_section.jsp");
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
														"assign_section.jsp");
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
GradeSystem gs = new GradeSystem();
if(WI.fillTextValue("page_action").length() > 0) {
	String strSubSecIndex = null;
	vRetResult = gs.recomputeFinalGradeCSA(dbOP, request, strSubSecIndex);
	if(vRetResult == null || vRetResult.size() < 3)
		strErrMsg = gs.getErrMsg();
	else {//I hve some message.. 
		strErrMsg = "<br>Total Processed : "+(String)vRetResult.elementAt(0)+
		" <br>Total Unchanged: "+(String)vRetResult.elementAt(2)+
		"<br>Total Failed: "+Integer.toString( (vRetResult.size() - 3) / 2) +"<br>Total Modified: "+(String)vRetResult.elementAt(1);
		
	}
}


%>

<form name="form_" action="./recompute_final_grade.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>:::: RECOMPUTE GRADE PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" >&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td >Course </td>
      <td colspan="2" >
<%
String strCourseIndex = WI.fillTextValue("course_index");
%>	  <select name="course_index" onChange="ReloadPage();">
		<option value=""></option>
          <%=dbOP.loadCombo("course_index","course_name",
		  " from course_offered where IS_DEL=0 and is_valid=1 and degree_type=0 and is_offered=1 order by course_name asc",strCourseIndex, false)%> 
		 </select></td>
    </tr>
    <tr> 
      <td width="2%" height="25" >&nbsp;</td>
      <td width="8%" height="25" >SY/Term </td>
      <td width="41%" >
<%
String strSYFrom = WI.fillTextValue("sy_from");
if(strSYFrom.length() == 0) 
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strSYFrom == null)
	strSYFrom = "";
%>
		  <input name="sy_from" type="text" size="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strTemp == null)
	strTemp = "";
%>        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		readonly="yes">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<select name="semester" onChange="ReloadPage();">
          <option value="1">1st Sem</option>
          <%
String strSemester = WI.fillTextValue("semester");
if(strSemester.length() == 0) 
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");
if(strSemester == null)
	strSemester = "";
if(strSemester.compareTo("2") ==0){%>
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
      </select></td>
      <td width="49%" ><input type="submit" name="13" value="Reload Page" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value=''"></td>
    </tr>
<%if(strSYFrom.length() > 0 && strCourseIndex.length() > 0 && false){%>	
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="2" >
Section Name :
  <select name="section" onChange="ReloadPage();">
	<option value="">All Section</option>
	 <%=dbOP.loadCombo("distinct e_sub_section.section","e_sub_section.section", 
		" from e_sub_section where IS_valid=1 and is_lec = 0 and offering_sy_from=" +
		WI.fillTextValue("sy_from")+" and offering_sem=" + WI.fillTextValue("semester") + 
		" and exists (select * from curriculum where " +
		" sub_index = e_sub_section.sub_index and course_index = " + WI.fillTextValue("course_index") + " and is_valid = 1) order by e_sub_section.section",
		WI.fillTextValue("section"), false)%>
  </select>  </td>
      <td>&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td height="10" align="center">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" align="center">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="4" height="10" align="center">
	  	<input type="submit" name="1" value="Re-Compute Grade" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1'"></td>
	</tr>
    <tr>
      <td colspan="4" height="10" align="center">&nbsp;</td>
    </tr>
  </table>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
