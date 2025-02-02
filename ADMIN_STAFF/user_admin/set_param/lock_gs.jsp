<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function PageAction(strAction)
{
	document.form_.page_action.value = strAction;
	this.SubmitOnce("form_");
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.SetParameter,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Set Parameters","lock_gs.jsp");
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
														"System Administration","Set Parameters",request.getRemoteAddr(),
														"lock_gs.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"System Administration","Set Parameters",request.getRemoteAddr(),
															"lock_gs.jsp");}

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

Vector vRetResult = new Vector();
boolean bolIsActiveLock = false;

SetParameter paramGS = new SetParameter();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(paramGS.operateOnLockGrade(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = paramGS.getErrMsg();
}
vRetResult = paramGS.operateOnLockGrade(dbOP,request,4);
if(vRetResult == null) {
	if(strErrMsg == null)
		strErrMsg = paramGS.getErrMsg();
}
%>
<form name="form_" action="./lock_gs.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SET GRADE SHEET LOCKING PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp;<a href="grade_setting_main.jsp"><img src="../../../images/go_back.gif" border="0"></a><font size="1">go 
        to main</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
</table>
<%
if(vRetResult != null && vRetResult.size() > 0 && ((String)vRetResult.elementAt(0)).compareTo("1") == 0)  
	bolIsActiveLock = true;
String strBgColor = " bgcolor=#DDDDDD";
if(bolIsActiveLock)
	strBgColor = " bgcolor=#FFFFFF";
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="46%" class="thinborderALL" bgcolor="#97ABC1">&nbsp;&nbsp;<strong> 
        Lock Status : <%if(bolIsActiveLock){%>ACTIVE <%}else{%>NOT ACTIVE<%}%></strong></td>
      <td width="2%">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td width="46%" class="thinborderALL" bgcolor="#FFFFDF">&nbsp;&nbsp;<strong> 
        New Lock Setting</strong></td>
      <td width="2%" height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="thinborderBOTTOMLEFTRIGHT"<%=strBgColor%>>&nbsp;&nbsp;<strong> 
        Locked By : </strong> <%if(vRetResult != null){%> <%=(String)vRetResult.elementAt(4)+" on "+(String)vRetResult.elementAt(3)%> <%}else{%>
        xxx <%}%></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;&nbsp;<strong> Lock Range : 
        <input name="lock_date_fr" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=WI.fillTextValue("lock_date_fr")%>" size="12" maxlength="12" readonly="yes">
        <a href="javascript:show_calendar('form_.lock_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <input name="lock_date_to" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=WI.fillTextValue("lock_date_to")%>" size="12" maxlength="12" readonly="yes">
        <a href="javascript:show_calendar('form_.lock_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        </strong></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="thinborderBOTTOMLEFTRIGHT"<%=strBgColor%>>&nbsp;&nbsp;<strong> 
        Lock Range : </strong> <%if(vRetResult != null){%> <%=(String)vRetResult.elementAt(1) + " - "+(String)vRetResult.elementAt(2)%> <%}else{%>
        xxx <%}%> </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;&nbsp;<strong> Operation : </strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;
	  <%if(bolIsActiveLock){%>
	  <div align="center"><strong><a href="javascript:PageAction(0);"><img src="../../../images/delete.gif" border="0"></a></strong><font size="1">(Remove lock setting) </font></div>
	  <%}//only if lock is active%>
	  </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td class="thinborderBOTTOMLEFTRIGHT"><div align="center"> <a href="javascript:PageAction(1);"><img src="../../../images/save.gif" border="0"></a><font size="1">(Apply 
          new lock setting) </font></div></td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
