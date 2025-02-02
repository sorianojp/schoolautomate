<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>SUBJECT SECTION MAINTENANCE</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.nav {     
	 font-weight:normal;
}
.nav-highlight {    
     background-color:#BCDEDB;
}

</style>
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript">
	function navRollOver(obj, state) {
  		document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
	}
	
	function PageAction(strAction, strInfoIndex){
		if(strAction == '0'){
			if(!confirm("Do you want to delete this entry?"))
				return;
		}
		
		document.form_.page_action.value = strAction;
		
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
			
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex){
		document.form_.prepareToEdit.value = '1';
		document.form_.page_action.value = "";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "0";
		document.form_.info_index.value = "";
		document.form_.section.value = "";
		document.form_.c_index.selectedIndex = "";
		document.form_.course_index.selectedIndex = "";
		document.form_.major_index.selectedIndex = "";
		document.form_.offering_sem.selectedIndex = "";
		document.form_.submit();
	}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS","edit_department_section.jsp");
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
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														"edit_department_section.jsp");
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
Vector vEditInfo = null;

enrollment.ReportEnrollment reportEnrl = new enrollment.ReportEnrollment();
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(reportEnrl.operateOnDeptSectionCIT(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = reportEnrl.getErrMsg();
	else{
		if(strTemp.equals("1"))
			strErrMsg = "Section Successfully saved.";
		if(strTemp.equals("0"))
			strErrMsg = "Section Successfully deleted.";
		if(strTemp.equals("2"))
			strErrMsg = "Section Successfully updated.";
			
		strPrepareToEdit = "0";
	}
}


vRetResult = reportEnrl.operateOnDeptSectionCIT(dbOP, request, 4);
if(vRetResult == null)
	strErrMsg = reportEnrl.getErrMsg();

if(strPrepareToEdit.equals("1")){
	vEditInfo = reportEnrl.operateOnDeptSectionCIT(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = reportEnrl.getErrMsg();
}

%>


<form name="form_" method="post" action="edit_department_section.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr bgcolor="#A49A6A">
	<td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
		DEPARTMENT SECTION MAINTENANCE PAGE ::::</strong></font></div></td>
</tr>   
<tr><td height="25">&nbsp; &nbsp; &nbsp; &nbsp; <font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>    
</table>
  
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	
	<tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" width="17%">SY/Term</td>
      <td colspan="2"> 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
        to 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>        
	&nbsp;
	<select name="semester">
<%
	strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));

if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st Sem</option>
<%}else{%>
          <option value="1">1st</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd</option>
<%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
<%}else{%>
          <option value="3">3rd</option>
<%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
        </select> 
		&nbsp; &nbsp;
		<a href="javascript:document.form_.submit();"><img src="../../../../../images/form_proceed.gif" border="0" align="absmiddle"></a>	</td>      
    </tr>
	<%if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length() > 0){%>
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">College</td>
		<%
		String strCollegeIndex = WI.fillTextValue("c_index");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strCollegeIndex = (String)vEditInfo.elementAt(1);
		%>
		<td colspan="2">
			<select name="c_index" onChange="document.form_.submit();">
				<option value=""></option>
				<%=dbOP.loadCombo("c_index", "c_name", " from college where is_del = 0 order by c_name", strCollegeIndex,false)%>
			</select>		</td>
	</tr>
	
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">Course</td>
		<%	
		
		String strCourseIndex = "";
			
		if(strCollegeIndex.length() > 0)
			strTemp = " from course_offered where c_index = "+strCollegeIndex+" and is_valid = 1 and is_del = 0 and is_offered = 1 order by course_code";
		else
			strTemp = " from course_offered where is_valid = 1 and is_del = 0 and is_offered = 1 order by course_code";		
		
		strCourseIndex = WI.fillTextValue("course_index");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strCourseIndex = (String)vEditInfo.elementAt(4);
		%>
		<td colspan="2">
			<select name="course_index" onChange="document.form_.submit();">
				<option value=""></option>
				<%=dbOP.loadCombo("course_index", "course_code, course_name ", strTemp, strCourseIndex,false)%>
			</select>		</td>
	</tr>
	
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">Major</td>
		<%				
		strErrMsg = WI.fillTextValue("major_index");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strErrMsg = (String)vEditInfo.elementAt(12);
		%>
		<td colspan="2">
			<select name="major_index">
          <option></option>
<%
if(strCourseIndex.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strCourseIndex ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, strErrMsg, false)%>
<%}%>
        </select>		</td>
	</tr>
	
	
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">Section</td>		
		<%
			strTemp = WI.fillTextValue("section");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(7);
		%>
		<td width="27%">
			<input type="text" name="section" value="<%=strTemp%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="127" size="10" >		</td>
	   <td width="53%" rowspan="2" valign="middle">
		<%if(vRetResult != null && vRetResult.size() > 0){%>
			Copy Department Section to : 
			<%
	strTemp = WI.getStrValue(WI.fillTextValue("copy_sy_from"));
%> <input name="copy_sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','copy_sy_from','copy_sy_to');">
        to 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("copy_sy_to"));
%> <input name="copy_sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>        
	&nbsp;
	<select name="copy_semester">
<%
	strTemp = WI.getStrValue(WI.fillTextValue("copy_semester"));

if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st Sem</option>
<%}else{%>
          <option value="1">1st</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd</option>
<%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
<%}else{%>
          <option value="3">3rd</option>
<%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
        </select> 
			<a href="javascript:PageAction('10','');"><img src="../../../../../images/copy.gif" border="0"></a>
		<%}else{%>
		&nbsp;
		<%}%>
		</td>
	</tr>
	
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">Semester Offered</td>		
		<td>
			<select name="offering_sem">
				<option value=""></option>
				<%		
				strTemp = WI.fillTextValue("offering_sem");
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(11);
				
				if(strTemp.equals("1") || strTemp.length() == 0)
					strErrMsg = "selected";
				else
					strErrMsg = "";
				%><option value="1" <%=strErrMsg%>>Regular Semester</option>
				<%
				if(strTemp.equals("0"))
					strErrMsg = "selected";
				else
					strErrMsg = "";					
				%><option value="0" <%=strErrMsg%>>Off Semester</option>
			</select>		</td>
	</tr>
	
	<tr><td height="10" colspan="4"></td></tr>
	<tr>
		<td colspan="2">&nbsp;</td>
		<td colspan="2">
		<%
			if(strPrepareToEdit.equals("0")){%>
			<a href="javascript:PageAction('1','');"><img src="../../../../../images/save.gif" border="0"></a>
			<font size="1">Click to save department section</font>
			<%}else{%>
			<a href="javascript:PageAction('2','');"><img src="../../../../../images/edit.gif" border="0"></a>
			<font size="1">Click to edit department section</font>
			<%}%>
			<a href="javascript:ReloadPage();"><img src="../../../../../images/refresh.gif" border="0"></a>
			<font size="1">Click to reload page</font>		</td>		
	</tr>
	<%}%>
</table>  
  
 
<%
if(vRetResult != null && vRetResult.size() > 0){
%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	
	<tr>
		<td class="thinborder" height="23" width="20%" align="center"><strong>COLLEGE/COURSE</strong></td>
		<td class="thinborder" align="center"><strong>SECTION</strong></td>
		<td class="thinborder" width="20%" align="center"><strong>OFFERED SEMESTER</strong></td>
		<td class="thinborder" width="20%" align="center"><strong>OPTION</strong></td>
	</tr>
	

	<%
	String strCurrCollege = null;
	String strPrevCollege = "";
	
	for(int i = 0; i < vRetResult.size(); i+=14){
		strCurrCollege = (String)vRetResult.elementAt(i+3);
		
		
	%>
	
	<%
	if(!strPrevCollege.equals(strCurrCollege)){
		strPrevCollege = strCurrCollege;
	%>
	<tr>
		<td height="23" class="thinborder" colspan="4" style="padding-left:40px;"><%=WI.getStrValue(strCurrCollege)%></td>		
	</tr>
	<%}%>
	
	<tr class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')">
		<td class="thinborder" align="right" style="padding-right:20px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+5))%>
		<%=WI.getStrValue((String)vRetResult.elementAt(i+13),"- ","","")%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+7)%></td>
		<%
		strTemp = (String)vRetResult.elementAt(i+11);
		if(strTemp == null)
			strTemp = "";
		if(strTemp.equals("1"))
			strTemp = "REGULAR SEMESTER";
		else
			strTemp = "OFF-SEMESTER";
		%>
		<td class="thinborder"><%=strTemp%></td>
		<td class="thinborder" align="center">
			<!--<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border="0" height="23" width="40" align="absmiddle"></a>-->
			<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../../../images/delete.gif" border="0" height="23" width="40" align="absmiddle"></a>
		</td>
	</tr>
	<%}%>
</table>
  
  
<%}%>
  


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr><td height="25" colspan="8">&nbsp;</td></tr>
<tr bgcolor="#B8CDD1"><td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
<!-- all hidden fields go here -->
	<input type="hidden" name="page_action" >
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" />
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>" />
	<input type="hidden" name="copy_dept_section" value="" >
</form>
</body>
</html>
