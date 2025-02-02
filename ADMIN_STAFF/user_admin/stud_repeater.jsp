<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	document.form_.submit();
}
function PageAction(strInfoIndex, strPageAction) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strPageAction;
	if(strPageAction == 1)
		document.form_.hide_save.value = "../../../images/blank.gif";
	document.form_.submit();
}
function Toggle(strClickI) {
 	if(strClickI == '1')//grade level selected.
		document.form_.sub_index.selectedIndex = 0;
	else {
		if(document.form_.g_level)
			document.form_.g_level.selectedIndex = 0;
	}
 }

</script>

<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus();">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	String[] astrConvertSem ={"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Override Parameters","stud_repeater.jsp");

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
														"System Administration","Override Parameters",request.getRemoteAddr(),
														"stud_repeater.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
boolean bolIsBasic = false;
String strStudName = null;
String strStudIndex = null;
String strCourse    = null;
String strEnrolledSY = null;
String strEnrolledTerm = null;

String strStudID = WI.fillTextValue("stud_id");
Vector vRetResult = null;
enrollment.AdvisingExtn advE = new enrollment.AdvisingExtn();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(advE.operateOnRepeater(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = advE.getErrMsg();
	else	
		strErrMsg = "Operation Successful.";
}


if(strStudID.length() > 0) {
	String strSQLQuery = "select user_index, fname, mname, lname from user_table where id_number = '"+strStudID+"' and auth_type_index = 4";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		strStudIndex = rs.getString(1);
		strStudName  = WebInterface.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 4);
	}
	rs.close();
	strSQLQuery = "select course_code, year_level, sy_from, sy_to, semester from stud_curriculum_hist "+
				"left join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
				"join semester_sequence on (semester_val = semester) "+
				" where user_index = "+strStudIndex+" and stud_curriculum_hist.is_valid = 1 order by sy_from desc, sem_order desc";
	rs = dbOP.executeQuery(strSQLQuery); 
	if(rs.next()) {
		strCourse = rs.getString(1);
		if(strCourse == null) {
			bolIsBasic = true; 
			strCourse = dbOP.getBasicEducationLevel(rs.getInt(2));
		}
		else
			strCourse = strCourse + WI.getStrValue (rs.getString(2), " - ", "","");
		strEnrolledSY   = rs.getString(3) + " - "+rs.getString(4);
		strEnrolledTerm = astrConvertSem[rs.getInt(5)];
	}
	rs.close();

	
	vRetResult = advE.operateOnRepeater(dbOP, request, 4);
}
%>


<form name="form_" action="./stud_repeater.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          REPEATER INFORMATION ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="28" width="2%">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Enrolling SY-Term: </td>
      <td colspan="3"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
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
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
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
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="13%">Student ID</td>
      <td width="24%"> <input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="7%"><a href="javascript:OpenSearch();"><img src="../../images/search.gif" border="0"></a></td>
      <td width="54%"> <a href="javascript:ReloadPage();"><img src="../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    
    
    <tr >
      <td  colspan="5" ><hr size="1"></td>
    </tr>
  </table>

 <%if(strStudName != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr >
      <td height="25">&nbsp;</td>
      <td colspan="2">Student name : <strong><%=strStudName%></strong></td>
    </tr>
<%if(bolIsBasic){
if(!strEnrolledTerm.startsWith("S"))
	strEnrolledTerm = "Regular";
%>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2">Grade Level :<strong> <%=strCourse%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td width="48%" height="25">Last Enrolled SY-Term : <%=strEnrolledTerm%>, <%=strEnrolledSY%></strong> </td>
      <td width="50%">&nbsp;</td>
    </tr>
<%}else{%>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2">Course :<strong> <%=strCourse%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td width="48%" height="25">Last Enrolled SY-Term : <%=strEnrolledTerm%>, <%=strEnrolledSY%></strong> </td>
      <td width="50%">&nbsp;</td>
    </tr>
<%}%>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>

<%
}//only if vStud info is not null
if(strStudName != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td  colspan="3"><hr size="1"></td>
    </tr>
<%if(bolIsBasic){%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="8%" >Grade Level </td>
      <td width="90%">
	  		<select name="g_level" onChange="Toggle(1);">
				<option></option>
          		<%=dbOP.loadCombo("g_level","level_name"," from bed_level_info  order by g_level asc", WI.fillTextValue("g_level"), false)%> 
		  	</select>
	  </td>
    </tr>
<%
strTemp = " from subject where IS_DEL=2 order by sub_code asc";
}
else	
	strTemp = " from subject where IS_DEL=0 order by sub_code asc";
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Subject</td>
      <td><select name="sub_index" style="width:700;" onChange="Toggle(2);">
        <option value=""></option>
          <%=dbOP.loadCombo("sub_index","sub_code, sub_name ",strTemp, WI.fillTextValue("sub_index"), false)%> 
      </select></td>
    </tr>
    
    <tr>
      <td height="45">&nbsp;</td>
      <td colspan="2" valign="bottom"><a href='javascript:PageAction("","1");'> <img src="../../images/save.gif" border="0" name="hide_save"></a>
        <font size="1">click to save </font></td>
    </tr>
  </table>
<%}if(vRetResult != null && vRetResult.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6"><div align="center"><strong>REPEAT LIST </strong></div></td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="21%" div align="center"><font size="1"><strong>GRADE LEVEL</strong></font></td>
      <td width="21%" height="25" div align="center"><font size="1"><strong>SUBJECT CODE</strong></font></td>
      <td width="44%" div align="center"><font size="1"><strong>SUBJECT DESCRIPTION</strong></font></td>
      <td width="9%" div align="center"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <%
	for(int i = 0 ; i < vRetResult.size(); i += 4){%>
    <tr>
      <td><%=WI.getStrValue((String)vRetResult.elementAt(i + 3), "&nbsp;")%></td>
      <td height="25"><%=WI.getStrValue((String)vRetResult.elementAt(i + 1), "&nbsp;")%> </td>
      <td height="25"><%=WI.getStrValue((String)vRetResult.elementAt(i + 2), "&nbsp;")%></td>
      <td height="25"> <%if(iAccessLevel == 2){%> <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'>
        <img src="../../images/delete.gif" border="0"></a> <%}%></td>
    </tr>
    <%}%>
  </table>
<%}//end of display if vRetResult > 0%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
