<%@ page language="java" import="utility.*, java.util.Vector " buffer="16kb"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() {
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function updateMsg() {
	strMsg = document.form_.message1.value;
	obj = document.getElementById('msg_view');
	if(obj) {
		obj.innerHTML = strMsg;
	}
	//.innerHTML = "";//strMsg;
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	
	String strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administration-Set Parameters-Broadcast Message","broadcast_msg.jsp");
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
														"System Administration","Set parameters",request.getRemoteAddr(),
														"broadcast_msg.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	MessageSystem msgSys = new MessageSystem();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(msgSys.operateOnBroadcastMsg(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strPrepareToEdit = "0";
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = msgSys.getErrMsg();
	}
	
		
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = msgSys.operateOnBroadcastMsg(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = msgSys.getErrMsg();
	}
	//view all 
	
	vRetResult = msgSys.operateOnBroadcastMsg(dbOP, request, 4);
	if (strErrMsg==null)
		strErrMsg=msgSys.getErrMsg();
	
%>


<body bgcolor="#D2AE72" onLoad="document.form_.message1.focus(); updateMsg();">
<form name="form_" action="./broadcast_msg.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          BROADCAST MESSAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr>
      <td width="2%" height="30">&nbsp;</td>
      <td width="49%">Message</td>
      <td width="49%" height="25" colspan="2" valign="middle">Message Appreance </td>
    </tr>
  	<%if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(1);
	else	
		strTemp = WI.fillTextValue("broadcast_msg");
	%>
    <tr>
      <td>&nbsp;</td>
      <td><textarea name="message1" cols="65" rows="5" class="textbox" style="font-size:11px;" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="updateMsg();"><%=strTemp%></textarea></td>
      <td height="25" colspan="2" class="thinborderALL" valign="top">
	  	<label id="msg_view"></label>	  
	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Valid Date: 
  	<%if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(3);
	else	
		strTemp = WI.fillTextValue("valid_date_fr");
	if(strTemp == null || strTemp.length() == 0) 
		strTemp = WI.getTodaysDate(1);
	%>
	  <input name="valid_date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
    			<a href="javascript:show_calendar('form_.valid_date_fr');" title="Click to select date" 
		  			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
				- to - 
  	<%if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(4);
	else	
		strTemp = WI.fillTextValue("valid_date_to");
	%>
	  <input name="valid_date_to" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.getStrValue(strTemp)%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
    			<a href="javascript:show_calendar('form_.valid_date_to');" title="Click to select date" 
		  			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>	  </td>
      <td height="25" colspan="2" valign="middle">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Valid Until: 
	  <select name="valid_time">
	  <option value="24">Whole Day</option>
<%if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("valid_time");

if(strTemp.equals("9.0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  <option value="9"<%=strErrMsg%>>9AM</option>
<%
if(strTemp.equals("10.0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  <option value="10"<%=strErrMsg%>>10AM</option>
<%
if(strTemp.equals("11.0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  <option value="11"<%=strErrMsg%>>11AM</option>
<%
if(strTemp.equals("12.0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  <option value="12"<%=strErrMsg%>>12PM</option>
<%
if(strTemp.equals("13.0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  <option value="13"<%=strErrMsg%>>1PM</option>
<%
if(strTemp.equals("14.0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  <option value="14"<%=strErrMsg%>>2PM</option>
<%
if(strTemp.equals("15.0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  <option value="15"<%=strErrMsg%>>3PM</option>
<%
if(strTemp.equals("16.0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  <option value="16"<%=strErrMsg%>>4PM</option>
<%
if(strTemp.equals("17.0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  <option value="17"<%=strErrMsg%>>5PM</option>
<%
if(strTemp.equals("18.0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  <option value="18"<%=strErrMsg%>>6PM</option>
<%
if(strTemp.equals("19.0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  <option value="19"<%=strErrMsg%>>7PM</option>
<%
if(strTemp.equals("20.0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  <option value="20"<%=strErrMsg%>>8PM</option>
<%
if(strTemp.equals("21.0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  <option value="21"<%=strErrMsg%>>9PM</option>
<%
if(strTemp.equals("22.0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  <option value="22"<%=strErrMsg%>>10PM</option>
	  </select>	  </td>
      <td height="25" colspan="2" valign="middle">&nbsp;</td>
    </tr>
    <tr> 
      <td height="15" colspan="4"><font size="1">&nbsp; </font><font size="1">&nbsp; 
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../../images/add.gif" border="0" name="hide_save"></a> Click to add entry
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> Click to edit event
        <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> Click to clear entries </font>
        <%}%>        </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" style="font-size:9px; font-weight:bold; color:#0000FF">
<%
strTemp = WI.fillTextValue("show_active");
if(strTemp.length() == 0) 
	strTemp = "2";

if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_active" value="1"<%=strErrMsg%> onClick="document.form_.page_action.value='';document.form_.prepareToEdit.value='';document.form_.submit();"> Show Valid Message of Today 
<%
if(strTemp.equals("2"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_active" value="2"<%=strErrMsg%> onClick="document.form_.page_action.value='';document.form_.prepareToEdit.value='';document.form_.submit();"> Show All Valid (including forth coming) 
<%
if(strTemp.equals("0"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_active" value="0"<%=strErrMsg%> onClick="document.form_.page_action.value='';document.form_.prepareToEdit.value='';document.form_.submit();"> Show all expired </td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
  <% if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="23" colspan="8" class="thinborder"> <div align="center"> <strong><font size="2">BIRTHDAY MESSAGES</font></strong></div></td>
    </tr>
    <tr align="center" style="font-weight:bold"> 
      <td width="5%" height="23" class="thinborder">Count</td>
      <td width="55%" class="thinborder">Message</td>
      <td width="15%" class="thinborder">Valid Date </td>
      <td width="10%" class="thinborder">Valid Time </td>
      <td align="center" class="thinborder" width="7%">Edit</td>
      <td align="center" class="thinborder" width="8%">Delete</td>
    </tr>
    <%
	String[] astrConvertHR = {"","1AM","2AM","3AM","4AM","5AM","6AM","7AM","8AM","9AM",
								"10AM","11AM","12PM","1PM","2PM","3PM","4PM","5PM","6PM","7PM","8PM","9PM","10PM","11PM","Whole Day"};
	int iCount = 0;
    for (int i = 0; i<vRetResult.size(); i+=6) { %>
    <tr> 
      <td class="thinborder" height="25"><%=++iCount%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i+1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i+3)%><%=WI.getStrValue((String)vRetResult.elementAt(i+4), " - ", "","")%></td>
      <td class="thinborder">
	  <%=astrConvertHR[new Double((String)vRetResult.elementAt(i+5)).intValue()]%>
	  </td>
      <td width="6%" class="thinborder"> <font size="1"> 
        <% if(iAccessLevel > 1){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        Not authorized 
        <%}%>
        </font></td>
      <td width="7%" class="thinborder"><font size="1"> 
        <% if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        Not authorized 
        <%}%>
        </font></td>
    </tr>
    <%}%>
  </table>
    <%}%>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    
  </table>
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
