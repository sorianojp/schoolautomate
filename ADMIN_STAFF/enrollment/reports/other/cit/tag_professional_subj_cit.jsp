<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
<script language="JavaScript" src="../../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
	function navRollOver(obj, state) {
  		document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
	}
	
	function Search(){
		document.form_.search_.value = "1";
		document.form_.submit();
	}
	
	function PageAction(strAction, strInfoIndex){
		if(strAction == '0'){
			if(!confirm("Do you want to delete this entry?"))
				return;
		}
		
		document.form_.page_action.value = strAction;
		
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
			
		document.form_.search_.value = "1";
		document.form_.submit();
	}	
	
	function ReloadPage(){
		document.form_.page_action.value = "";		
		document.form_.info_index.value = "";		
		document.form_.c_index.selectedIndex = "";
		document.form_.course_index.selectedIndex = "";
		document.form_.sub_index.selectedIndex = "";
		document.form_.semester.selectedIndex = "";
		document.form_.submit();
	}
	
	function copyCurYr(strCYFrom, strCYTo) {
		document.form_.cur_from.value = strCYFrom;
		document.form_.cur_to.value   = strCYTo;	
		document.form_.submit();		
	}
	
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS","tag_professional_subj_cit.jsp");
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
														"tag_professional_subj_cit.jsp");
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

ReportEnrollment reportEnrl = new ReportEnrollment();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(reportEnrl.operateOnProfessionalSubjectCIT(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = reportEnrl.getErrMsg();
	else{
		if(strTemp.equals("1"))
			strErrMsg = "Subject Successfully saved.";
		if(strTemp.equals("0"))
			strErrMsg = "Subject Successfully deleted.";	
	}
}


if(WI.fillTextValue("search_").length() > 0){
vRetResult = reportEnrl.operateOnProfessionalSubjectCIT(dbOP, request, 4);
if(vRetResult == null)
	strErrMsg = reportEnrl.getErrMsg();

}

String strSYFrom = WI.fillTextValue("sy_from");
String strSemester = WI.fillTextValue("semester");

String strDegreeType = "";
if(WI.fillTextValue("course_index").length() > 0){
	strTemp = " select degree_type from course_offered where course_index = "+WI.fillTextValue("course_index");
	strDegreeType = dbOP.getResultOfAQuery(strTemp, 0);
}

if(strDegreeType == null)
	strDegreeType = "";


%>


<form name="form_" method="post" action="./tag_professional_subj_cit.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr bgcolor="#A49A6A">
	<td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
		PROFESSIONAL SUBJECTS MAINTENANCE PAGE ::::</strong></font></div></td>
</tr>   
<tr><td height="25">&nbsp; &nbsp; &nbsp; &nbsp; <font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>    
</table>
  
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	
	<!--<tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" width="17%">SY/Term</td>
      <td colspan="2"> 
<%
	strSYFrom = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
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
	strSemester = strTemp;
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
        </select>	</td>      
    </tr>-->
	
	
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">College</td>
		<%
		String strCollegeIndex = WI.fillTextValue("c_index");		
		%>
		<td>
			<select name="c_index" onChange="document.form_.submit();" style="width:400px;">
				<option value=""></option>
				<%=dbOP.loadCombo("c_index", "c_name", " from college where is_del = 0 order by c_name", strCollegeIndex,false)%>
			</select>		</td>
		<td>Curriculum year</td>
	</tr>
	
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">Course</td>
		<%		
		if(strCollegeIndex.length() > 0)
			strTemp = " from course_offered where c_index = "+strCollegeIndex+" and is_valid = 1 and is_del = 0 and is_offered = 1 order by course_code";
		else
			strTemp = " from course_offered where is_valid = 1 and is_del = 0 and is_offered = 1 order by course_code";		
		

		strErrMsg = WI.fillTextValue("course_index");		
		%>
		<td>
			<select name="course_index" style="width:400px;" onChange="document.form_.submit();">
				<option value=""></option>
				<%=dbOP.loadCombo("course_index", "course_code, course_name ", strTemp, strErrMsg,false)%>
			</select>		</td>
	    <td>
			<input name="cur_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("cur_from")%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','cur_from');style.backgroundColor='white'"
		  onKeyUP="AllowOnlyInteger('form_','cur_from')">
			to
			<input name="cur_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("cur_to")%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','cur_to');style.backgroundColor='white'"
		  onKeyUP="AllowOnlyInteger('form_','cur_to')">
      </td>
	</tr>
	
	    <tr>
      <td height="25">&nbsp;</td>     
      <td width="17%">Major</td>
		<%				
		strErrMsg = WI.fillTextValue("major_index");
		//if(vEditInfo != null && vEditInfo.size() > 0)
		//	strErrMsg = (String)vEditInfo.elementAt(12);
		%>
		<td width="53%">
			<select name="major_index" onChange="document.form_.submit();">
          <option></option>
<%
if(WI.fillTextValue("course_index").length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+WI.fillTextValue("course_index") ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, strErrMsg, false)%>
<%}%>
        </select>		</td>
      <td width="27%">
        <%
Vector vCurYearInfo = null;
strTemp = null;
if(WI.fillTextValue("course_index").length() == 0 || WI.fillTextValue("course_index").compareTo("selany") == 0) 
	strTemp = null;
else	
	strTemp = WI.fillTextValue("major_index");

vCurYearInfo = new enrollment.SubjectSection().getSchYear(dbOP, request.getParameter("course_index"),strTemp);
if(vCurYearInfo != null) {
%>
        <strong><font color="#0000FF" size="1">Existing Cur Year:</font> </strong><br> 
        <%
		for(int i = 0; i < vCurYearInfo.size(); i += 2) {%>
        <a href="javascript:copyCurYr(<%=(String)vCurYearInfo.elementAt(i)%>,<%=(String)vCurYearInfo.elementAt(i + 1)%>);"> 
        <font size="1" color="#000099">(<%=(String)vCurYearInfo.elementAt(i) + " - " +(String)vCurYearInfo.elementAt(i + 1)%>)</font></a> 
        <%i = i + 2;
		if(i < vCurYearInfo.size()){%>
        <a href="javascript:copyCurYr(<%=(String)vCurYearInfo.elementAt(i)%>,<%=(String)vCurYearInfo.elementAt(i + 1)%>);"> 
        <font size="1" color="#000099">(<%=(String)vCurYearInfo.elementAt(i) + " - " +(String)vCurYearInfo.elementAt(i + 1)%>)</font></a> 
        <%}//show two in one line.%>
        <br> 
        <%}%>
        <%}//only if cur info is not null;
%>      </td>
    </tr>
	
	<tr><td colspan="2">&nbsp;</td><td colspan="2">
		<a href="javascript:Search();"><img src="../../../../../images/form_proceed.gif" border="0" align="absmiddle"></a></td></tr>
	<tr><td colspan="5" height="10"></td></tr>
	<%if(WI.fillTextValue("search_").length() > 0){%>
	<tr><td colspan="5"><hr size="1"></td></tr>
	<tr> 
      <td>&nbsp;</td>
      <td colspan="4" valign="bottom">Subject Code : <font size="1"> 
        <input type="text" name="scroll_sub" size="16" style="font-size:9px" 
	  onKeyUp="AutoScrollListSubject('scroll_sub','sub_index',true,'form_');">
        (enter subject code to scroll the list)</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="4" valign="bottom">
	  <%
		  	strTemp = " from subject where is_del=0 ";
		  		//" and exists (select * from e_sub_section where sub_index = subject.sub_index and e_sub_section.is_valid = 1 and "+
				//" offering_sy_from = "+strSYFrom+" and offering_sem = "+strSemester+") ";
			if(WI.fillTextValue("course_index").length() > 0){
				strErrMsg = "curriculum";
				if(strDegreeType.equals("1"))
					strErrMsg = "CCULUM_MASTERS";
				
				strTemp += " and exists ( select * from "+strErrMsg+" where sub_index = subject.sub_index "+
					" and is_valid = 1 and course_index = "+WI.fillTextValue("course_index");
				if(WI.fillTextValue("major_index").length() > 0)	
						strTemp += " and major_index = "+WI.fillTextValue("major_index");
				
				strErrMsg = "sy_from";
				strTemp2 = "sy_to";
				if(strDegreeType.equals("1")){
					strErrMsg = "CY_FROM";
					strTemp2 = "CY_TO";
				}				
				
				if(WI.fillTextValue("cur_from").length() > 0 && WI.fillTextValue("cur_to").length() > 0)	
						strTemp += " and "+strErrMsg+" = "+WI.fillTextValue("cur_from") +
							" and "+strTemp2+" = "+WI.fillTextValue("cur_to");
				
				strTemp += " ) and not exists(select * from cit_professional_subject where course_index = "+WI.fillTextValue("course_index") +
					" and sub_index = subject.sub_index) ";
			}
			strTemp += " order by sub_code";
			
			
	  %>
	  
	  <select name="sub_index" title="SELECT A  SUBJECT"
	  	style="font-size:11px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; width:400px;">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("sub_index","sub_code +'&nbsp;&nbsp;&nbsp;('+sub_name+')' as s_code", strTemp ,WI.fillTextValue("sub_index"), false)%> </select></td>
    </tr>
	
	<tr><td height="10" colspan="3"></td></tr>
	<tr>
		<td colspan="2">&nbsp;</td>
		<td>
		
			<a href="javascript:PageAction('1','');"><img src="../../../../../images/save.gif" border="0"></a>
			<font size="1">Click to save entry</font>		</td>		
	</tr>
	<%}%>
</table>  
  
 
<%
if(vRetResult != null && vRetResult.size() > 0){
%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	
	<tr>
		<td class="thinborder" height="23" width="20%" align="center"><strong>COLLEGE/COURSE</strong></td>
		<td class="thinborder" align="center"><strong>SUBJECT</strong></td>		
		<td class="thinborder" width="20%" align="center"><strong>OPTION</strong></td>
	</tr>
	

	<%
	String strCurrCollege = null;
	String strPrevCollege = "";
	
	for(int i = 0; i < vRetResult.size(); i+=6){
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
		<td class="thinborder" align="right" style="padding-right:20px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+2))%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%><%=WI.getStrValue((String)vRetResult.elementAt(i+5), " - ", "", "")%></td>
		
		
		<td class="thinborder" align="center">
			
			<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../../../images/delete.gif" border="0" align="absmiddle"></a>
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
	<input type="hidden" name="search_" value="">
	<input type="hidden" name="page_action" >
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" />
	<%=dbOP.constructAutoScrollHiddenField()%>	
</form>
</body>
</html>
