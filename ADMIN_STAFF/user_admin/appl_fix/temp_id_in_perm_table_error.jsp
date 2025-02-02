<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{

	this.SubmitOnce('form_');		
}
function ShowResult() {
	document.form_.show_result.value = "1";
	this.ReloadPage();
}
function selAll() {
	var iMaxDisp = document.form_.max_disp.value;
	var bolIsChecked = document.form_.sel_all.checked;
	var obj;
	for(var i = 0; i < iMaxDisp; ++i) {
		eval('obj=document.form_.pmt_'+i);
		if(!obj)
			continue;
		obj.checked = bolIsChecked;
	}
}


</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Program fix-Fix Missing Oth school Debit Entry",
								"temp_id_in_perm_table_error.jsp");

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
														"System Administration","Application Fix",request.getRemoteAddr(),
														"temp_id_in_perm_table_error.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
AllProgramFix progFix = new AllProgramFix();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(progFix.fixNewStudEnrollment(dbOP, request, 1) == null)
		strErrMsg = progFix.getErrMsg();
}


if(WI.fillTextValue("show_result").length() > 0) {
	vRetResult = progFix.fixNewStudEnrollment(dbOP, request, 3);
	if(vRetResult == null)
		strErrMsg = progFix.getErrMsg();
}	

%>


<form name="form_" action="./temp_id_in_perm_table_error.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          VALID TEMP ID PRESENT IN PERMANENT TABLE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td colspan="3"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="12%">SY/Term</td>
      <td width="42%"> <%
if(request.getParameter("sy_from") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
else
	strTemp = WI.fillTextValue("sy_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
        to 
        <%
if(request.getParameter("sy_to") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
else
	strTemp = WI.fillTextValue("sy_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
		<select name="semester" onChange="ReloadPage();">
          <%
if(request.getParameter("semester") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
else
	strTemp = WI.fillTextValue("semester");

if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st</option>
<%}else{%>
          <option value="1">1st</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
<%}else{%>
          <option value="2">2nd</option>
<%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
<%}else{%>
          <option value="3">3rd</option>
<%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
      <td width="44%">&nbsp;</td>
    </tr>
    
    <tr>
      <td height="25"></td>
      <td>&nbsp;</td>
      <td><a href="javascript:ShowResult();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
		<td align="center" style="font-size:18px; font-weight:bold">
		Total Valid Temp ID in Permanet Table (Having payment): <%=WI.getStrValue((String)vRetResult.elementAt(0), "0")%> <br><br>
		Total Valid Temp ID in Permanet Table (Not having any payment): <%=WI.getStrValue((String)vRetResult.elementAt(1), "0")%> <br>
		</td>
	</tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
		<td align="center"><input type="button" name="_" value="Click to Fix" onClick="document.form_.page_action.value='1';document.form_.show_result.value='1';document.form_.submit();"></td>
	</tr>
  </table>
<%}//only if vRetResult is not null
%>
<table width="100%" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
</table>
<input type="hidden" name="show_result">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
