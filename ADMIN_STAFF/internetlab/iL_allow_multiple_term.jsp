<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}

</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,iCafe.ICafeSetting,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem","5th Sem"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Internet Cafe Management-INTERNET LAB OPERATION-Addl Term",
								"iL_allow_multiple_term.jsp");
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
														"USAGE DETAILS",request.getRemoteAddr(),
														"iL_allow_multiple_term.jsp");
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


strTemp =WI.fillTextValue("page_action");
ICafeSetting cafeSetting = new ICafeSetting();
Vector vRetResult = null;

if(strTemp.length() > 0) {
	if(cafeSetting.operateOnAddlTerm(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = cafeSetting.getErrMsg();
	else {	
		if(strTemp.compareTo("1") == 0 )
			strErrMsg = "Additional Term added successfully.";
		else	
			strErrMsg = "Additional term information removed successfully.";		
	}
}

//view all. 
vRetResult = cafeSetting.operateOnAddlTerm(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = "Internet Cafe login follows strict SY-Term checking";
%>

<form name="form_" method="post" action="./iL_allow_multiple_term.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73">
      <td width="131%" height="27" colspan="8"><div align="center"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">:::: 
          ALLOW MULTIPLE TERM ::::</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="31" colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
	  <font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><strong>CURRENT SY-TERM : <%=(String)request.getSession(false).getAttribute("cur_sch_yr_from")%> - 
	  <%=(String)request.getSession(false).getAttribute("cur_sch_yr_to")%>, 
	  <%if(request.getSession(false).getAttribute("cur_sem") != null){%>
	  <%=astrConvertSem[Integer.parseInt((String)request.getSession(false).getAttribute("cur_sem"))]%></strong></td>
    <%}%>
	</tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Allow School Year/Term - Validity</td>
    </tr>
    <tr> 
      <td width="18%" height="25">&nbsp;</td>
      <td width="82%"> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp; <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("semester");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select>
        - 
        <input name="valid_date" type="text" size="12" readonly="true" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("valid_date")%>"> 
        <a href="javascript:show_calendar('form_.valid_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%
if(iAccessLevel > 1){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><a href='javascript:PageAction("1","");'><img src="../../images/save.gif" border="0" name="hide_save"></a> 
        Click to save Usage.</td>
    </tr>
    <%}%>
    <tr> 
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>

 <%
 if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#000000">
    <tr bgcolor="#FFFF9F"> 
      <td height="24" colspan="3"><div align="center"><font color="#0000FF"><strong>ALLOWED 
          SY-TERM </strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="34%" height="25" align="center"><font size="1"><strong>SY-TERM</strong></font></td>
      <td width="32%" align="center"><font size="1"><strong>VALID UNTIL</strong></font></td>
      <td width="34%" align="center"><strong><font size="1">DELETE</font></strong></td>
    </tr>
    <%
for(int i = 0; i < vRetResult.size(); i += 5 ){%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i + 1)%> - <%=(String)vRetResult.elementAt(i + 2)%>, 
	  <%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i + 3))]%></td>
      <td>&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i + 4)%></td>
      <td align="center"><a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'> 
        <img src="../../images/delete.gif" border="0"></a></td>
    </tr>
    <%}%>
  </table>
 <%}//end of displaying if vRetResult <> null%>
 
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
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