<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
//Creates group name.. 

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
function ReloadPage(){
	document.form_.page_action.value = '';
	document.form_.info_index.value  = '';
	document.form_.submit();
}
function FocusID() {
	document.form_.group_name.focus();	
}
function PageAction (strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm("Are you sure you want to remove this group name."))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value  = strInfoIndex;
	document.form_.submit();
}
function Edit(strInfoIndex) {
	var strGroupName = prompt('Please enter new group name.','');
	if(strGroupName == null || strGroupName.length == 0) 
		return;
	document.form_.group_name.value = strGroupName;
	
	document.form_.page_action.value = '2';
	document.form_.info_index.value  = strInfoIndex;
	document.form_.submit();
}
function SendSMS(strInfoIndex) {
	var strPgLoc = "./send_msg_group.jsp?group="+strInfoIndex;
	var win=window.open(strPgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddUser(strInfoIndex) {
	var strPgLoc = "./add_member_to_group.jsp?group_ref="+strInfoIndex;
	var win=window.open(strPgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body bgcolor="#D2AE72" onLoad="FocusID();">
<%
	try {
		dbOP = new DBOperation(strUserID,"SMS-Broadcast","create_group.jsp");
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
Vector vRetResult = null;
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(bCast.operateOnBuddyGroupName(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = bCast.getErrMsg();
	else	
		strErrMsg = "Operation Successful.";
}

vRetResult = bCast.operateOnBuddyGroupName(dbOP, request, 4);
if(vRetResult == null)
	strErrMsg = bCast.getErrMsg();
%>
<form action="./create_group.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: Create Group Name::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="14%">Group Name </td>
      <td width="83%"><input type="text" name="group_name" maxlength="64" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';" size="32" value="<%=WI.fillTextValue("group_name")%>" /></td>
    </tr>
  </table>
  <table  bgcolor="#ffffff" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" align="center">
	  <input type="button" name="1" value="&nbsp;&nbsp;Create Group Name&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('1','')"></td>
  </tr>
  </table>
<%if(vRetResult != null) {%>
  <table  bgcolor="#ffffff" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr>
    <td height="25" colspan="5" align="center" bgcolor="#A49A6A" class="thinborder" style="font-size:11px; font-weight:bold">Existing Group Name</td>
  </tr>
  <tr style="font-weight:bold">
    <td height="25" class="thinborder" width="60%">Group Name </td>
    <td class="thinborder" width="10%">Send SMS</td>
    <td class="thinborder" width="15%">No Of Users in group</td>
    <td class="thinborder" width="7%">Edit</td>
    <td class="thinborder" width="8%">Delete</td>
  </tr>
<%for(int i = 0; i < vRetResult.size(); i += 3) {%>
  <tr>
    <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
    <td class="thinborder">&nbsp;<%if(vRetResult.elementAt(i + 2) != null) {%>
		<a href="javascript:SendSMS('<%=vRetResult.elementAt(i)%>');"><img src="../images/send_sms.png" border="0" height="50" width="50"></a>
	    <%}%>
	</td>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 2),"0")%> <br />
	<a href="javascript:AddUser('<%=vRetResult.elementAt(i)%>')">Add User</a></td>
    <td class="thinborder"><a href="javascript:Edit('<%=vRetResult.elementAt(i)%>');"><img src="../../../images/edit.gif" border="0"></a></td>
    <td class="thinborder"><a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a></td>
  </tr>
<%}%>
</table>
<%}%>
  <table  bgcolor="#ffffff" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
<input type="hidden" name="send_msg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>