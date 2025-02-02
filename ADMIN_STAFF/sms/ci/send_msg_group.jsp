<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
///this is a web-interface SMS. This can send sms to any mobile, even not registered to system. This is available to system admin only. useful for the person 
//collecting money from drop box for only the new students/old who do not have mobile registered.

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";

String strUserID = (String)request.getSession(false).getAttribute("userId");
if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}
String strAuthTypeIndex = WI.getStrValue((String)request.getSession(false).getAttribute("authTypeIndex"), "4");
if(strAuthTypeIndex.equals("4")){%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are not authorized to view this page.</p>
<%return;}

	String strErrMsg = null;
	String strTemp   = null;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function FocusID() {
	document.form_.message.select();
	document.form_.message.focus();	
}
function SendMsg() {
	var strVar = document.form_.message.value;
	if(strVar.length == 0) {
		alert("Please enter a message");
		return;
	}

	document.form_.send_msg.value = '1';
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72" onLoad="FocusID();">
<%
	try {
		dbOP = new DBOperation(strUserID,"SMS-Broadcast","send_msg_group.jsp");
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
sms.BroadCast bCast = new sms.BroadCast();
String strGroupIndex = WI.fillTextValue("group");

Vector vRetResult = bCast.getMobileOfBuddyList(dbOP, strGroupIndex, request);

if(WI.fillTextValue("send_msg").equals("1")) {
	if(bCast.sendSMSToBuddyList(dbOP, request))
		strErrMsg = "SMS sent to Que. It will be sent soon.";
	else	
		strErrMsg = bCast.getErrMsg();		
}
%>
<form action="./send_msg_group.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: Send SMS Web-Interface ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:9px; font-weight:bold; color:#0000FF">Note : SMS Information is saved to database under the logged in ID and can be traced in future. </td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="14%" valign="top"><br>
      Message to Send 
	  <br>
	  <font style="font-size:9px; font-weight:bold">Char Remaining : </font>
	  <input type="text" name="count_" class="textbox_noborder" readonly="yes" tabindex="-1" style="font-size:9px;" size="6">	  </td>
      <td width="83%">
<textarea name="message" rows="5" cols="75" class="textbox"
		onfocus="CharTicker('form_','160','message','count_');style.backgroundColor='#D3EBFF'" 
	  	onBlur ="CharTicker('form_','160','message','count_');style.backgroundColor='white'" 
	  	onkeyup="CharTicker('form_','160','message','count_');"><%=WI.fillTextValue("message")%></textarea></td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<table  bgcolor="#ffffff" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	  <tr>
	    <td height="25" colspan="5" align="center" bgcolor="#999999" class="thinborder" style="font-weight:bold;">List of members in Group</td>
      </tr>
	  <tr align="center" style="font-weight:bold" bgcolor="#FF9933">
		<td height="25" class="thinborder" width="40%">Name</td>
	    <td class="thinborder" width="20%">Main Mobile Number </td>
	    <td class="thinborder" width="10%">Send </td>
	    <td class="thinborder" width="20%">Parent Mobile </td>
	    <td class="thinborder" width="10%">Send </td>
	  </tr>
<%
int iCount = 0;
for(int i = 0; i < vRetResult.size(); i += 5) {
strTemp = (String)vRetResult.elementAt(i + 3);
if(request.getParameter("send_msg") == null || WI.fillTextValue("mobile_"+iCount).length() > 0) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <tr>
	    <td height="25" class="thinborder">&nbsp;<%=vRetResult.elementAt(i)%></td>
	    <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 1)%></td>
	    <td class="thinborder" align="center"><input type="checkbox" name="mobile_<%=iCount%>" value="<%=vRetResult.elementAt(i + 1)%>" <%=strErrMsg%>>
		<input type="hidden" name="provider_<%=iCount%>" value="<%=vRetResult.elementAt(i + 2)%>">
		</td>
	    <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp, "Not Set")%></td>
<%
if(request.getParameter("send_msg") == null || WI.fillTextValue("mobile_"+(iCount + 1)).length() > 0) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
if(strTemp == null)
	strErrMsg = "";
%>
	    <td class="thinborder" align="center">&nbsp;
		<%if(strTemp != null) {%>
			<input type="checkbox" name="mobile_<%=++iCount%>" value="<%=vRetResult.elementAt(i + 3)%>" <%=strErrMsg%>>
			<input type="hidden" name="provider_<%=iCount%>" value="<%=vRetResult.elementAt(i + 4)%>">
		<%}%>
		</td>
      </tr>
<%++iCount;}%>
<input type="hidden" name="max_disp" value="<%=iCount%>">
	</table>

  <table  bgcolor="#ffffff" width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td height="25" align="center"><br>
		  <input type="button" name="1" value="&nbsp;&nbsp;Send SMS&nbsp;&nbsp;" style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="SendMsg();"></td>
	  </tr>
  </table>
 <%}//show only if vRetResult is not null)%>
  <table  bgcolor="#ffffff" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="send_msg">
<input type="hidden" name="group" value="<%=WI.fillTextValue("group")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>