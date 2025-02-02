<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function AddRecord()
{
	document.offlineRegd.addRecord.value = "1";
}

function ReloadPage()
{
	document.offlineRegd.addRecord.value = "";
	document.offlineRegd.submit();
}
function OpenSearch(strIDInfo) {
	var pgLoc = "../../search/srch_emp.jsp?prevent_reload=1&opner_info=offlineRegd.";
	if(strIDInfo == '0')
		pgLoc +="prev_id";
	else	
		pgLoc += "new_id";
		
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,student.ChangeCriticalInfo,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;

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
														"System Administration",
														"USER MANAGEMENT",request.getRemoteAddr(), 
														"update_employee_id.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

ChangeCriticalInfo changeInfo = new ChangeCriticalInfo();

if(WI.fillTextValue("addRecord").compareTo("1") ==0)
{
	if(!changeInfo.changeStudID(dbOP,WI.fillTextValue("prev_id"),WI.fillTextValue("new_id"),
								(String)request.getSession(false).getAttribute("login_log_index")) )
		strErrMsg = changeInfo.getErrMsg();
	else
		strErrMsg = "ID"+WI.fillTextValue("prev_id")+" is changed to new ID : "+WI.fillTextValue("new_id");
}
%>
<form action="./update_employee_id.jsp" method="post" name="offlineRegd">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          Employee ID Update Page ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%"></td>
	  <td width="98%" height="25">
	<strong><%=WI.getStrValue(strErrMsg)%></strong>
	  </td>
    </tr>
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="13%" height="25">Employee ID :</td>
      <td width="23%" height="25"><input type="text" name="prev_id" size="16" maxlength="32" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="62%" height="25"><a href="javascript:OpenSearch('0')">Search ID</a></td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="13%" height="25">New ID :</td>
      <td width="23%" height="25"><input type="text" name="new_id" size="16" maxlength="32" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="62%" height="25"><a href="javascript:OpenSearch('1')">Search ID</a>
	  <%
	  if(iAccessLevel > 1){%>
	  <input name="image" type="image" onClick="AddRecord();" src="../../images/save.gif">
        <font size="1" >click to change  ID</font>
		<%}else{%>
		Not authorized to modify student's ID
		<%}%>
	  </td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%" height="25">&nbsp;</td>
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="79%" height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="addRecord" value="0">
 </form>
</body>
</html>
<%
dbOP.cleanUP();
%>
