<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.page_action.value="";
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex)
{
	document.form_.page_action.value=strAction;
	if(strAction == "1")
		document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAReenrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-Re-enrollment","fm_reenrollment.jsp");
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
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"fm_reenrollment.jsp");
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

FAReenrollment reEnrolment = new FAReenrollment();
strTemp = WI.fillTextValue("page_action");

Vector vRetResult = null;
if(strTemp.length() > 0) {
	if(reEnrolment.operateOnFee(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = reEnrolment.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}
//I have to get the list of subjet re-enrolled. 
if(WI.fillTextValue("sy_to").length() > 0) {
	vRetResult = reEnrolment.operateOnFee(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = reEnrolment.getErrMsg();
}


%>

<form name="form_" action="./fm_reenrollment.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          RE-ENROLLMENT SUBJECT FEE MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%">SY/TERM</td>
      <td width="81%"> 
<%
	strTemp = WI.fillTextValue("sy_from");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
		
	if(strTemp == null) strTemp = "";
	%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
	strTemp = WI.fillTextValue("sy_to");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
		
	if(strTemp == null) strTemp = "";
	%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
<%
	strTemp = WI.fillTextValue("semester");
	if(strTemp == null) strTemp = "";
%>
        <select name="semester">
          <option value="">ALL</option>
          <%
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
        </select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>COURSE</td>
      <td><select name="course_index">
          <option value="">All Course</option>
<%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc", WI.fillTextValue("course_index"), false)%> 
        </select></td>
    </tr>
<!--    <tr> 
      <td height="25">&nbsp;</td>
      <td>MAJOR</td>
      <td><select name="major_index">
          <option></option>
          <%
//if(WI.fillTextValue("course_index").length() > 0)
//{
//strTemp = " from major where is_del=0 and course_index="+WI.fillTextValue("course_index") ;
//%>
          <%//dbOP.loadCombo("major_index","major_name",strTemp, WI.fillTextValue("major_index"), false)%> 
<%//}%>
        </select></td>
    </tr>-->
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Fee rate(per subject)</td>
      <td> 
	  <input name="amount" type="text" size="16" value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp; </td>
      <td> <%
if(iAccessLevel > 1){%> <a href='javascript:PageAction("1","");'><img src="../../../images/add.gif" border="0" name="hide_save"></a>Click 
        to add fee <%}%> </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
<%
if(vRetResult != null && vRetResult.size() > 0)
{%>
    <tr bgcolor="#B9B292">
      <td width="100%" height="25" colspan="5" bgcolor="#B9B292"><div align="center">RE-ENROLLED 
          SUBJECT FEE</div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="49%" height="25"><div align="center"><strong><font size="1">COURSE</font></strong></div></td>
      <td width="20%"><div align="center"><strong><font size="1">FEE AMOUNT</font></strong></div></td>
      <td width="15%" align="center"><strong><font size="1">SEMESTER</font></strong></td>
      <td width="16%" align="center"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size() ; i += 7) 
{%>
    <tr> 
      <td height="25" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i + 4),"ALL")%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"ALL")%></td>
      <td align="center"> <%if(iAccessLevel == 2 ){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'> 
        <img src="../../../images/delete.gif" border="0"></a> <%}%> </td>
    </tr>
    <% 
	}//end of displaying levels
}//end of displaying existing question level
%>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
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