<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/treelinkcss.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex){
	if(strAction == "0"){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value =strInfoIndex;
	
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Term Management","manage_term_ess_htc.jsp");
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
														"manage_block_section.jsp");
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
String strSYFrom   = WI.fillTextValue("sy_from");
if(strSYFrom.length() ==0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strSYTo     = WI.fillTextValue("sy_to");
if(strSYTo.length() ==0)
	strSYTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
String strSemester = WI.fillTextValue("semester");
if(strSemester.length() ==0)
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");

enrollment.SubjectSection SS = new enrollment.SubjectSection();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(SS.operateOnBlockSectionSetting(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = SS.getErrMsg();
	else	
		strErrMsg = "Operation Successful.";
}
Vector vRetResult = SS.operateOnBlockSectionSetting(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = SS.getErrMsg();


String strLoggedUserCollege = WI.getStrValue((String)request.getSession(false).getAttribute("info_faculty_basic.c_index"), "0");
boolean bolViewALL = false;
if(WI.fillTextValue("show_all").length() > 0)
	bolViewALL = true;
%>

<form name="form_" action="./manage_block_section.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: 
          TERM MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td colspan="4" height="25"><strong><font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4" >School year : 
       <input name="sy_from" type="text" class="textbox" id="sy_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' value="<%=strSYFrom%>" size="4" maxlength="4">
        to 
 <input name="sy_to" type="text" class="textbox" id="sy_to"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strSYTo%>" size="4" maxlength="4"
	  readonly="yes">
 &nbsp;&nbsp;&nbsp; &nbsp;Term :
	 <select name="semester">
 		<%=CommonUtil.constructTermList(dbOP, request, strSemester)%>
      </select> 
	  
	  <input type="image" src="../../../images/refresh.gif" border="0">	  
	  
	  <input type="checkbox" name="show_all" value="checked" <%=WI.fillTextValue("show_all")%> onClick="document.form_.page_action.value='';document.form_.info_index.value='';document.form_.submit();"> View All
	  
	  </td>
    </tr>
    <tr>
        <td height="25">&nbsp;</td>
        <td width="15%" >Section To Block </td>
        <td width="66%" >
		<select name="section_name">
			<%=dbOP.loadCombo("distinct e_sub_section.section","e_sub_section.section", " from e_sub_section where is_valid = 1 and offering_sy_from = "+strSYFrom+
			" and offering_sem = "+strSemester+
			" and IS_CHILD_OFFERING = 0 and is_lec = 0 and offered_by_college = "+strLoggedUserCollege+" and not exists "+
			"(select block_index from E_SUB_SECTION_BLOCK where section_name = section and sy_from = offering_sy_from and semester = offering_sem and E_SUB_SECTION_BLOCK.is_valid =1)  order by e_sub_section.section", 
			WI.fillTextValue("section_name"),false)%> 
		</select>
		</td>
        <td width="8%" >&nbsp;</td>
        <td width="8%" >&nbsp;</td>
    </tr>
    <tr>
        <td height="25">&nbsp;</td>
        <td >&nbsp;</td>
        <td >
		<a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0"></a>
		<font size="1">Click to save information</font></td>
        <td >&nbsp;</td>
        <td >&nbsp;</td>
    </tr>
  </table>

<%

if(vRetResult != null && vRetResult.size() > 0){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
	<tr>
	  <td align="center" height="25"><strong>LIST OF BLOCKED SECTION </strong></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
	<tr bgcolor="#CCCCCC">
		<td width="41%" height="22" align="center" class="thinborder"><strong>Section Blocked </strong></td>
		<!--
			<Td width="38%" align="center" class="thinborder"><strong>Number of Subjects Offered </strong></Td>
		-->
		<Td width="21%" align="center" class="thinborder"><strong>UnBlock</strong></Td>
	</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 3){%>
	<tr>
	    <td height="22" class="thinborder"><%=vRetResult.elementAt(i+1)%></td>
		<!--
	    	<Td class="thinborder"><%=vRetResult.elementAt(i+2)%></Td>
	    -->
		<Td align="center" class="thinborder">
		<%if(bolViewALL) {%>N/A<%}else{%>
		<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"></a>
		<%}%>
		</Td>
    </tr>
	<%}%>
</table>
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
<tr><td height="25">&nbsp;</td></tr>
<tr bgcolor="#A49A6A"><td height="25" >&nbsp;</td></tr>
</table>


<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
