<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Untitled Document</title>
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<%@ page language="java" import="utility.*, java.util.Vector " buffer="16kb"%>
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
														"System Administration","System Tracking",request.getRemoteAddr(),
														"access_log.jsp");
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

AccessSecurityLog aSL = new AccessSecurityLog();
Vector vRetResult     = null;
if(WI.fillTextValue("date_fr").length() > 0) {
	if(WI.fillTextValue("show_all").length() > 0) 
		aSL.defSearchSize = 1000000;
		
	vRetResult = aSL.viewAccessLog(dbOP, request);
	if(vRetResult == null) 
		strErrMsg = aSL.getErrMsg();
}
%>

<body topmargin="0">
<form name="form_" method="post" action="./access_log.jsp">
<table border="0" cellspacing="0" cellpadding="0" >
  <tr>
    <td width="8" height="24" background=".././../../images/tableft.gif" bgcolor="#A9B9D1">&nbsp;</td>
    <td width="160" bgcolor="#00468C" align="center"  class="tabFont"><a href="access_log_main.jsp">Todays Visit Log Summary</a></td>
    <td width="10" background=".././../../images/tabright.gif" bgcolor="#A9B9D1">&nbsp;</td>
    <td width="8" height="24" background=".././../../images/tableft_selected.gif" bgcolor="#A9B9D1">&nbsp;</td>
    <td width="116" bgcolor="#A9B9D1" align="center" class="tabFont">Visit Log </td>
    <td width="8" background=".././../../images/tabright_selected.gif" bgcolor="#A9B9D1">&nbsp;</td>
<!--
    <td width="8" height="24" background=".././../../images/tableft.gif" bgcolor="#A9B9D1">&nbsp;</td>
    <td width="114" bgcolor="#00468C" align="center" class="tabFont"><a href="ip_block.jsp">Block IP Access</a> </td>
    <td width="8" background=".././../../images/tabright.gif" bgcolor="#A9B9D1">&nbsp;</td>
-->
  </tr>
</table>
<%if(strErrMsg != null) {%>
<table border="0" cellspacing="0" cellpadding="0" >
 <tr>
	<td><font style="font-size:14px; color:#FF0000; font-weight:bold;"><%=strErrMsg%></font></td>
 </tr>
</table>
<%}%>
<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<td width="12%" height="25">Visit log Date </td>
		<td width="38%">
<%
strTemp = WI.fillTextValue("date_fr");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
		<input name="date_fr" type="text" class="textbox"
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="yes">
			<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
	to 
		<input name="date_to" type="text" class="textbox"
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_to")%>" size="12" maxlength="12" readonly="yes">
			<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>	  </td>
	  <td width="12%">ID Number </td>
	  <td><input name="user_id" type="text" size="18" value="<%=WI.fillTextValue("user_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
	  <td height="25">Mod/Sub Mod</td>
	  <td colspan="3">
	  	<select name="mod_submod" style=" width:600px; font-size:11px;">
		<option value="">-- Any -- </option>
<%=dbOP.loadCombo("distinct MODULE_SUBMOD_NAME","MODULE_SUBMOD_NAME"," from SECURITY_ACCESSLOG_MODSUBMOD order by SECURITY_ACCESSLOG_MODSUBMOD.MODULE_SUBMOD_NAME",WI.fillTextValue("mod_submod"), false)%>
		</select>	  </td>
    </tr>
	<tr>
	  <td colspan="2" style="font-weight:bold; color:#0000FF; font-size:9px;">
	  	<input type="checkbox" name="show_ip" value="checked" <%=WI.fillTextValue("show_ip")%>> Show IP Address 
		&nbsp;&nbsp;
	  	<input type="checkbox" name="show_all" value="checked" <%=WI.fillTextValue("show_all")%>> Show All in one page
		
		</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	</tr>
	<tr>
	  <td colspan="4" align="center" height="28" valign="bottom"> <input type="submit" name="-" value="List Access Log" /></td>
    </tr>
</table>



<%if(vRetResult != null) {
boolean bolShowIP = false;
if(WI.fillTextValue("show_ip").length() > 0) 
	bolShowIP = true;
int iSearchResult = aSL.getSearchCount();%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="66%" height="25" style="font-weight:bold; font-size:11px; color:#FF0000">Total Result : <%=iSearchResult%> - Showing(<%=aSL.getDisplayRange()%>)</b></td>
      <td width="34%"> 
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/aSL.defSearchSize;
		if(iSearchResult % aSL.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page: 
          <select name="jumpto" onChange="document.form_.submit();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
          <%}%>
        </div></td>
    </tr>
  </table>
<table border="0" cellspacing="0" cellpadding="0" width="100%" class="thinborder">
 <tr bgcolor="#99CCFF">
	<td height="22" width="8%" style="font-size:11px; font-weight:bold" class="thinborder">User ID</td>
	<td width="15%" style="font-size:11px; font-weight:bold" class="thinborder">Name</td>
	<td width="12%" style="font-size:11px; font-weight:bold" class="thinborder">Access Date Time </td>
<%if(bolShowIP) {%>
		<td width="10%" style="font-size:11px; font-weight:bold" class="thinborder">Client IP </td>
<%}%>
	<td width="15%" style="font-size:11px; font-weight:bold" class="thinborder">Page URL </td>
	<td width="40%" style="font-size:11px; font-weight:bold" class="thinborder">Module-submodule Name </td>
	</tr>
<%
for(int i = 0; i < vRetResult.size(); i += 9){%>
  <tr>
	<td height="22" class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(i + 1)%></td>
	<td class="thinborder" style="font-size:10px;"><%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),(String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>
	<td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(i + 5)%></td>
<%if(bolShowIP) {%>
		<td class="thinborder" style="font-size:10px;"><%=WI.getStrValue((String)vRetResult.elementAt(i + 8), "&nbsp;")%></td>
<%}%>
	<td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(i + 7)%></td>
	<td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(i + 6)%></td>
	</tr>
<%}%>
</table>
<%}%>
</form>
</body>
</html>

<%
dbOP.cleanUP();
%>