<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function CheckValidHour() {
	var vTime =document.form_.time_from_hr.value
	if(eval(vTime) > 12 || eval(vTime) == 0) {
		alert("Time should be >0 and <= 12");
		document.form_.time_from_hr.value = "12";
	}
	vTime =document.form_.time_to_hr.value
	if(eval(vTime) > 12 || eval(vTime) == 0) {
		alert("Time should be >0 and <= 12");
		document.form_.time_to_hr.value = "12";
	}
}
function CheckValidMin() {
	if(eval(document.form_.time_from_min.value) > 59) {
		alert("Time can't be > 59");
		document.form_.time_from_min.value = "00";
	}
	if(eval(document.form_.time_to_min.value) > 59) {
		alert("Time can't be > 59");
		document.form_.time_to_min.value = "00";
	}
}
//called for add or edit.
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
</script>

<%@ page language="java" import="utility.*,lms.MgmtEvent,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"lms-Administration-EVENTS","event_create.jsp");
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
														"LIB_Administration","EVENTS",request.getRemoteAddr(),
														"event_create.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
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
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

	MgmtEvent mgmtEvent = new MgmtEvent(dbOP);
	Vector vRetResult = null;
	Vector vEditInfo  = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(mgmtEvent.operateOnEvent(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = mgmtEvent.getErrMsg();
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Event successfully removed.";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Event successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Event successfully edited.";

			strPrepareToEdit = "0";
		}
	}
	vRetResult = mgmtEvent.operateOnEvent(dbOP, request,4);

	//get vEditInfoIf it is called.
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = mgmtEvent.operateOnEvent(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = mgmtEvent.getErrMsg();
	}
	int iTotalValidEvent = 0;
	if(vRetResult != null && vRetResult.size() > 0)
		iTotalValidEvent = vRetResult.size() / 13;
%>

<body bgcolor="#DEC9CC">
<form action="./event_create.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5">
      <td height="25" colspan="5" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>::::
          EVENTS - CREATE PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="5" >&nbsp;&nbsp;<font size="3" color="#FF0000"><strong>
        </strong></font>TOTAL VALID EVENTS : <%=iTotalValidEvent%></td>
    </tr>
<%
if(strErrMsg != null) {%>
    <tr >
      <td height="25" colspan="5" >&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong>
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
<%}%>
    <tr >
      <td height="30" colspan="5" >&nbsp;&nbsp;<strong><u>EVENT INFORMATION</u></strong></td>
    </tr>
    <tr >
      <td width="2%" height="30">&nbsp;</td>
      <td width="11%">Begin Date</td>
      <td width="17%"> <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("begin_date");
%> <input name="begin_date" type="text"  class="textbox" id="DayDate" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10" readonly
	  value="<%=strTemp%>"> <a href="javascript:show_calendar('form_.begin_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
      </td>
      <td width="12%">Begin Time</td>
      <td> <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("time_from_hr");
%> <input type="text" name="time_from_hr" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_from_hr")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidHour();">
        :
        <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("time_from_min");
%> <input type="text" name="time_from_min" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_from_min")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidMin();"> <select name="time_from_AMPM">
          <option selected value="0">AM</option>
          <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("time_from_AMPM");

if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
    </tr>
    <tr >
      <td height="30">&nbsp;</td>
      <td>End Date</td>
      <td> <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("end_date");
%> <input name="end_date" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=strTemp%>">
        <a href="javascript:show_calendar('form_.end_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td>End Time</td>
      <td> <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(6);
else
	strTemp = WI.fillTextValue("time_to_hr");
%> <input type="text" name="time_to_hr" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidHour();">
        :
        <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(7);
else
	strTemp = WI.fillTextValue("time_to_min");
%> <input type="text" name="time_to_min"  size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidMin();"> <select name="time_to_AMPM">
          <option selected value="0">AM</option>
          <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(8);
else
	strTemp = WI.fillTextValue("time_to_AMPM");
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="middle" >Event Name</td>
      <td colspan="2" >&nbsp;</td>
    </tr>
    <tr >
      <td height="30">&nbsp;</td>
      <td colspan="4" valign="top" > <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(9);
else
	strTemp = WI.fillTextValue("event_name");
%> <textarea name="event_name" cols="55" rows="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'"
	  onblur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td colspan="5" valign="bottom" height="25">&nbsp;&nbsp;<strong><u>EVENT
        REMARKS/NOTES/DESCRIPTION</u></strong></td>
    </tr>
    <tr >
      <td height="30">&nbsp;</td>
      <td colspan="4" > <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(10);
else
	strTemp = WI.fillTextValue("event_remark");
%> <textarea name="event_remark" cols="55" rows="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'"
	  onblur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
    <tr valign="bottom">
      <td height="30">&nbsp;</td>
      <td colspan="4" > <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(11);
else
	strTemp = WI.fillTextValue("auto_del");
if(strTemp.compareTo("1") == 0)
	strTemp = "checked";
else
	strTemp = "";
%> <input type="checkbox" name="auto_del" value="1" <%=strTemp%>>
        Automatically delete expired events after
        <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(11);
else
	strTemp = WI.fillTextValue("auto_del_day");
%> <input type="text" name="auto_del_day" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        day(s)</td>
    </tr>
    <tr valign="bottom">
      <td height="20" colspan="5" ><hr size="1" color="#0099CC"></td>
    </tr>
    <%
if(iAccessLevel > 1) {%>
    <tr valign="bottom">
      <td height="40">&nbsp;</td>
      <td colspan="4" ><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href="javascript:PageAction(1);"><img src="../../images/save.gif" border="0"></a> 
        Click to save entries 
        <%}else{%>
        <a href="javascript:PageAction(2);"><img src="../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="./event_create.jsp"><img src="../../images/cancel.gif" border="0"></a> 
        Click to clear entries <a href="javascript:ViewEvent();"><img src="../../images/view.gif" border="0"></a> 
        View all events </font></td>
    </tr>
    <%}%>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
