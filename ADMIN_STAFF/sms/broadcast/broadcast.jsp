<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
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

String strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
String strSem    = (String)request.getSession(false).getAttribute("cur_sem");

	String strErrMsg = null;
	String strTemp = "&sy_from="+strSYFrom+"&sy_to="+strSYTo+"&semester="+strSem;
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
function ReloadPage(){
	this.RefreshPage();
}
function RefreshPage() {
	document.form_.info_index.value = '';
	document.form_.page_action.value = '';
	document.form_.preparedToEdit.value = '';	
	document.form_.submit();
}
function PageAction(strInfoIndex, strPageAction) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strPageAction;
	document.form_.submit();
}
function PreparedToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.preparedToEdit.value = '1';
	document.form_.submit();
}
function FocusID() {
	document.form_.message.select();
	document.form_.message.focus();	
}

function FinalizeMsg(strBroadcastIndex, strSendAgainStat) {
	document.form_.page_action.value = '';
	document.form_.preparedToEdit.value = '';
	document.form_.info_index.value = '';
	
	document.form_.broadcast_ref.value = strBroadcastIndex;
	document.form_.send_again.value    = strSendAgainStat;
	document.form_.finalize.value      = '1';
	
	document.form_.submit();
}
function AddMoreRecipient(strBroadcastRef, strViewStat) {
	var strPgLoc = "./add_recipient.jsp?broadcast_ref="+strBroadcastRef;
	if(strViewStat == '1')
		strPgLoc = strPgLoc + "&search_=1&show_recipient=checked&search_type=0<%=strTemp%>";
	var win=window.open(strPgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body bgcolor="#D2AE72" onLoad="FocusID();">
<%
	try {
		dbOP = new DBOperation(strUserID,"SMS-Broadcast","broadcast.jsp");
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
Vector vRetResult   = null;
Vector vEditInfo    = null;

String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(bCast.operateOnBroadcastMain(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = bCast.getErrMsg();
	else {
		strErrMsg = "Operation Successful.";
		strPreparedToEdit = "0";
	}	
}
if(WI.fillTextValue("finalize").length() > 0) {//finalize this now.. 
	if(bCast.finalizeBroadcast(dbOP, request) == null)
		strErrMsg = bCast.getErrMsg();
	else {
		if(WI.fillTextValue("send_again").length() > 0)
			strErrMsg = "Message Sent again.";
		else	
			strErrMsg = "Message Finalized and sent to recipient.";
	}
}


vRetResult = bCast.operateOnBroadcastMain(dbOP, request, 4);

if(strPreparedToEdit.equals("1")) {
	vEditInfo = bCast.operateOnBroadcastMain(dbOP, request, 3);
	vEditInfo.remove(0);
}


boolean bolIsFinalizeClicked = false;
if(WI.fillTextValue("show_finalized").length() > 0)
	bolIsFinalizeClicked = true;
%>
<form action="./broadcast.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: Broadcast SMS ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%" valign="top"><br>Message to Broadcast 
	  <br>
	  <font style="font-size:9px; font-weight:bold">Char Remaining : </font>
	  <input type="text" name="count_" class="textbox_noborder" readonly="yes" tabindex="-1" style="font-size:9px;" size="6">
	  </td>
      <td width="80%">
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("message");
%>
<textarea name="message" rows="5" cols="75" class="textbox"
		onfocus="CharTicker('form_','160','message','count_');style.backgroundColor='#D3EBFF'" 
	  	onBlur ="CharTicker('form_','160','message','count_');style.backgroundColor='white'" 
	  	onkeyup="CharTicker('form_','160','message','count_');"><%=strTemp%></textarea></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td width="3%" height="18">&nbsp;</td>
      <td colspan="4" style="font-weight:bold; color:#0000FF; font-size:11px;">
	  <input type="checkbox" name="show_finalized" value="checked" <%=WI.fillTextValue("show_finalized")%> onClick="document.form_.page_action.value='';document.form_.preparedToEdit.value='';document.form_.submit()">
	  Show all messages already finalized (Pls note, once finalized, messages are sent) </td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td colspan="2" align="center">
<%if(strPreparedToEdit.equals("0")){%>
	  	
		<input type="submit" name="1" value="&nbsp;&nbsp;Save&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1';document.form_.preparedToEdit.value='';document.form_.info_index.value='';">
		<!--Save Not Allowed. Pls contact System Admin.-->
<%}else{%>
	  	<input type="submit" name="10" value="&nbsp;&nbsp;Edit&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='2';document.form_.info_index.value='<%=vEditInfo.elementAt(0)%>';">
	  	&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="submit" name="100" value="&nbsp;&nbsp;Cancel&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='';document.form_.preparedToEdit.value='';">
<%}%>	  </td>
      <td width="34%" align="right"><a href="javascript:RefreshPage();">Refresh Page</a>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="136%" height="25" colspan="3" bgcolor="#B9B292"><div align="center"></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr align="center" style="font-weight:bold"> 
      <td width="50%" height="25" style="font-size:9px;" class="thinborder">Message </td>
      <td width="10%" style="font-size:9px;" class="thinborder">Create Date</td>
      <td width="10%" style="font-size:9px;" class="thinborder">Number of Recipient</td>
<%if(!bolIsFinalizeClicked){%>
      <td width="6%" style="font-size:9px;" class="thinborder">Finalize</td>
      <td width="6%" style="font-size:9px;" class="thinborder">Edit</td>
      <td width="8%" style="font-size:9px;" class="thinborder">Delete</td>
<%}else{%>
      <td width="5%" style="font-size:9px;" class="thinborder">BroadCast Again </td>
<%}%>
    </tr>
<%
String strFinalizeStat = null;
vRetResult.remove(0);
for(int i = 0; i < vRetResult.size(); i += 8){
strFinalizeStat = (String)vRetResult.elementAt(i + 7);
strTemp = WI.getStrValue(vRetResult.elementAt(i + 5), "0");
%>
    <tr>
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%><br><br><font style="font-weight:bold">Message Length : <%=((String)vRetResult.elementAt(i + 1)).length()%></font></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder">&nbsp;<%=strTemp%><br>
	  <%if(!bolIsFinalizeClicked){%><a href="javascript:AddMoreRecipient('<%=vRetResult.elementAt(i)%>',0);">Add More/Manage</a><%}else{%>
	  <a href="javascript:AddMoreRecipient('<%=vRetResult.elementAt(i)%>',1);">View Recipient List</a><%}%>
	  </td>
<%if(!bolIsFinalizeClicked){%>
      <td class="thinborder">&nbsp;<%if(!strTemp.equals("0")){%><a href="javascript:FinalizeMsg('<%=vRetResult.elementAt(i)%>','');">Finalize</a><%}%></td>
      <td class="thinborder" align="center"><a href="javascript:PreparedToEdit('<%=vRetResult.elementAt(i)%>');"><img src="../../../images/edit.gif" border="0"></a></td>
      <td class="thinborder" align="center"><a href="javascript:PageAction('<%=(String)vRetResult.elementAt(i)%>','0');"><img src="../../../images/delete.gif" border="0"></a></td>
      <%}else{%>
      <td class="thinborder">&nbsp;<a href="javascript:FinalizeMsg('<%=vRetResult.elementAt(i)%>','1');">Send Again</a></td>
      <%}%>
    </tr>
<%}//end of for loop.. %>
  </table>
<%}//vRetResult is not null%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="broadcast_ref">
<input type="hidden" name="send_again">
<input type="hidden" name="finalize">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>