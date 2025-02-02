<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
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
								"Admin/staff-Internet Cafe Management-INTERNET LAB OPERATION-usage detail",
								"iL_set_usage.jsp");
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
														"iL_set_usage.jsp");
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
	if(ICS.operateOnUsageSetting(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = ICS.getErrMsg();
	else	
		strErrMsg = "Operation Successful.";
}

//I have to get here setting information./
if(WI.fillTextValue("sy_to").length() > 0) {
	vRetResult = ICS.operateOnUsageSetting(dbOP, request, 4);
}

%>
<form action="./iL_set_usage.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" >:::: 
          SET USER USAGE DURATION PAGE::::</font></div></td>
    </tr>
    <tr > 
      <td>&nbsp;</td>
	  <td height="25" colspan="3"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>	  
    </tr>
    <tr > 
      <td width="8%" height="30">&nbsp;</td>
      <td width="46%" height="25"> &nbsp;&nbsp; SY/TERM : 
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp;&nbsp;&nbsp; 
	  <select name="semester">
          <option value="">ALL Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(WI.fillTextValue("first_call").length() ==0 )
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
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
<%}if(strTemp.compareTo("0") == 0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select>
	  </td>
      <td width="18%"><a href="javascript:ReloadPage();">
	  	<img src="../../images/form_proceed.gif" border="0"></a></td>
      <td width="28%">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="100%" height="25"><hr size="1" noshade> </td>
    </tr>
  </table>
<% if (WI.fillTextValue("sy_to").length() != 0){%>
  <table width="100%" border="0" cellpadding="2" cellspacing="2" bgcolor="#FFFFFF">
    <tr> 
      <td width="12%">&nbsp;</td>
      <td width="42%"><font size="1"><u><strong>CURRENT SETTING</strong></u> </font></td>
      <td width="46%"><font size="1"><u><strong>NEW SETTING</strong></u> </font></td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td><%if(vRetResult != null && vRetResult.size() > 0){%>
        <font size="1">Minimum usage : <font size="2"><%=(String)vRetResult.elementAt(1)%></font></font> <font size="2">
        <%}%>
        </font> </td>
      <td><font size="1">Minimum usage :&nbsp; 
        <input name="min_usage" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("min_usage")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        minutes </font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><font size="1">
        <%if(vRetResult != null && vRetResult.size() > 0){%>
        Maximum usage : <font size="2"><%=(String)vRetResult.elementAt(2)%> 
        <%}%>
        </font> </font></td>
      <td><font size="1">Maximum usage :  
	  <input name="max_usage" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("max_usage")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
        minutes</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><font size="1">
        <%if(vRetResult != null && vRetResult.size() > 0){%>
        Interval for next login : <font size="2"><%=(String)vRetResult.elementAt(3)%> 
        <%}%>
        </font> </font></td>
      <td><font size="1">Interval for next login :  
        <input name="intv_usage" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("intv_usage")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        minutes </font></td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td><font size="1">
        <%if(vRetResult != null && vRetResult.size() > 0){%>
        Allowance :</font> <font size="2"> <%=(String)vRetResult.elementAt(4)%> 
        <%}%>
        </font></td>
      <td><font size="1">Allowed allowance : 
        <input name="allowance" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("allowance")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        minutes</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2">NOTE : if student exceeds allowance time, system automatically 
        increment by minimum usage time</td>
    </tr>
<%
if(iAccessLevel > 1) {%>
    <tr> 
      <td height="65" colspan="3"><div align="center"><font size="1"> 
	  <%
	  if(vRetResult != null && vRetResult.size() > 0){%>
	  <a href='javascript:PageAction("2","<%=(String)vRetResult.elementAt(0)%>");'>
	  <img src="../../images/edit.gif" border="0"></a>Click to edit information
	  <%}else{%>
	  <a href='javascript:PageAction("1","");'>
	  <img src="../../images/save.gif" border="0"></a>click to save changes 
	  <%}%>
	  <a href="./iL_set_usage.jsp"><img src="../../images/cancel.gif" border="0"></a>click to cancel/clear 
          changes </font></div></td>
    </tr>
<%}%>
  </table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
<input type="hidden" name="first_call" value="0">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>