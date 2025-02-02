<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css"></head>
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete this record.'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation();
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
														"Registrar Management","xxxx",request.getRemoteAddr(),null);

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
GradeSystemExtn gsExtn = new GradeSystemExtn();
if(WI.fillTextValue("sy_from").length() > 0) {
	gsExtn.fixGradeEncodingJonelta(dbOP, request);
	strErrMsg = gsExtn.getErrMsg();
}
%>
<form name="form_" action="./grade_sheet_fix_grade_encoded_jonelta.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: FIX 
          GRADE ENCODED ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="5" style="font-size:14px;">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" width="5%">Term: </td>
      <td height="25" width="92%">
	  
	  <input name="sy_from" type="text" size="5" maxlength="4" value="2012" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" readonly>
	  
	  <select name="semester">
	  	<option value="1">1st sem</option>
<!--
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="2"<%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="0"<%=strErrMsg%>>Summer</option>
-->
	  </select>	  </td>
    </tr>
    <tr>
      <td height="40">&nbsp;</td>
      <td>&nbsp;</td>
      <td  valign="bottom"><input type="button" name="1" value="<<< Fix Grade Encoded >>>" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('1','');"></td>
    </tr>
  </table>

 </table>
  <table width="100%"  cellpadding="0" cellspacing="0">
    <tr>
      <td bgcolor="#FFFFFF"><font color="#FFFFFF">&nbsp;</font></td>
    </tr>
    
    <tr bgcolor="#A49A6A">
      <td>&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="info_index">
<input type="hidden" name="page_action">

</form>
</body>
</html>


<%
dbOP.cleanUP();
%>
