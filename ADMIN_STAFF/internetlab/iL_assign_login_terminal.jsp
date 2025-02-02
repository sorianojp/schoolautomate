<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.info_index.value = "";
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,iCafe.ICafeSetting,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Internet Cafe Management-INTERNET LAB OPERATION",
								"iL_assign_login_terminal.jsp");
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
														"Internet Cafe Management",
														"INTERNET LAB OPERATION",request.getRemoteAddr(),
														"iL_assign_login_terminal.jsp");
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
ICafeSetting ICS = new ICafeSetting();
Vector vRetResult = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(ICS.operateOnLoginTerminal(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = ICS.getErrMsg();
	else	
		strErrMsg = "Operation Successful.";
}
//I have to get here information.
vRetResult = ICS.operateOnLoginTerminal(dbOP, request,4);
%>
<form action="./iL_assign_login_terminal.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INTERNET LAB OPERATION - ASSIGN PC FOR USERS LOGIN ::::</strong></font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="2%" height="25">&nbsp; </td>
      <td height="25"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="5" cellspacing="5" bgcolor="#FFFFFF">
    <tr> 
      <td width="17%">&nbsp;</td>
      <td width="20%"><strong><font size="1" >IP ADDRESS : </font></strong></td>
      <td width="63%"><font size="1" >
        <input name="ip_addr" type="text" maxlength="15" value="<%=WI.fillTextValue("ip_addr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        </font></td>
    </tr>
    <tr>
		<td>&nbsp;</td>
		<td><font size="1" ><strong>LOCATION :</strong></font></td>
		<td>
<%
strTemp = WI.fillTextValue("loc_index");
%>
        <select name="loc_index">
          <%=dbOP.loadCombo("location_index","location"," from IC_COMP_LOC order by location",strTemp,false)%>
        </select>
      </td>
    </tr>
    <%
if(iAccessLevel > 1){%>
    <tr> 
      <td height="40" colspan="3"><div align="center"> <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0"></a><font size="1" >click 
          to save entries/changes <a href="./iL_assign_login_terminal.jsp"><img src="../../images/cancel.gif" border="0"></a>click 
          to clear or cancel entries</font></div></td>
    </tr>
    <%}%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="5" cellspacing="5" bgcolor="#FFFFFF">
    <tr> 
      <td width="62%" height="25">&nbsp;</td>
      <td width="31%" height="25">&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFF9F" > 
      <td height="25" colspan="3"><div align="center"><font color="#000000"><strong>LIST 
          OF ASSIGNED PC FOR USERS LOGIN</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="3"><strong></strong></td>
    </tr>
    <tr > 
      <td width="29%" height="25"><div align="center"><strong><font size="1" >IP 
          ADDRESS</font></strong></div></td>
      <td width="52%"><div align="center"><font size="1" ><strong>LOCATION</strong></font></div></td>
      <td width="19%">&nbsp;</td>
    </tr>
    <%
for(int i = 0; i < vRetResult.size(); i += 3){%>
    <tr > 
      <td height="25"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td height="25"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td height="25"> <%if(iAccessLevel == 2){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'> 
        <img src="../../images/delete.gif" border="0"></a> <%}%> </td>
    </tr>
    <%}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="44" colspan="7"><div align="center"></div></td>
    </tr>
  </table>
<%}//if vRetResult not null
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="7" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>