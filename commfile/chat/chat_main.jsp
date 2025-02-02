<%if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<font color="#FF0000">You are already logged out. Please login again.</font>
<%return;}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript">
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.user_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strIsFaculty = "";
		if(document.form_.student_.checked && !document.form_.staff_.checked) 
			strIsFaculty = "0";
		else if(document.form_.staff_.checked && !document.form_.student_.checked) 
			strIsFaculty = "1";
		
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=108&is_faculty="+strIsFaculty+
			"&complete_name="+escape(strCompleteName);
		if(document.form_.search_online.checked)
			strURL += "&search_online=1";
		if(document.form_.search_active.checked)
			strURL += "&search_active=1";
		//alert(strURL);
		this.processRequest(strURL);
}
function UpdateID(strID) {
	document.form_.user_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font color=blue size=1>End of processing...</font>";	
}

function PopWin(strIndex) {
	if(strIndex == "0") {
		location = "./AjaxChatArchive.jsp";	
		return;
	}
	var strID = document.form_.user_id.value;
	if(strID.length == 0) {
		alert("Please enter valid ID.");
		return;
	}
	var pgLoc = "./AjaxChat.jsp?user_id_to="+strID;
	var win=window.open(pgLoc,strID,'width=600,height=500,top=10,left=10,scrollbars=no,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<form name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
        CHAT WINDOW ::::</strong></font></div></td>
    </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25" colspan="3" style="font-size:11px;"><font color="#0000FF"><b>Feature of Chat Message : </b></font><br>
	1. Contact immediately if user is logged on to SchoolBliz or currently chatting<br>
	2. Leave offline message. Message appears Once user logs in.<br>
	3. All messages saved in message archive and can be accessed by clicking "View Chat Archive".<br>
	4. While chatting, do not refresh the page by pressing F5 or right click+refresh. Doing so removes all the message in chat window.<br>
	5. Browser javascript must be enabled for Chat service. By default browser javascript is enabled.<br>
	6. Supports Multiple chat windows.<br>
	7. Currently Conference is not supported.<br>
	8. If Chat window is minimized, window blinks on receiving new message.	</td>
    </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td width="11%" height="25">&nbsp;</td>
    <td width="16%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="javascript:PopWin('0');">View Chat Archive</a></td>
  </tr>
  <tr> 
    <td width="11%" height="25">&nbsp;</td>
    <td width="16%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="javascript:PopWin('1');">Invite for Chat</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./broadcast.jsp">Broadcast</a></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" colspan="2" style="font-size:9px; color:#0000FF;">&nbsp;&nbsp;
	<input type="checkbox" name="search_online" value="1" checked="checked"> Show SB online users (idle time less than 15mins) &nbsp;
	<input type="checkbox" value="1" name="search_active" checked="checked">Show currently chatting &nbsp; 
	<input type="checkbox" value="1" name="student_"> Show student &nbsp;	
	<input type="checkbox" value="1" name="staff_" checked="checked"> Show staff	</td>
    </tr>
  <tr> 
    <td width="11%" height="25">&nbsp;</td>
    <td width="89%" style="font-size:11px;">User ID: 
    <input name="user_id" type="text" class="textbox" style="font-size:11px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);" size="24">	  </td>
    </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="8%" height="25">&nbsp;</td>
    <td width="66%"><label id="coa_info"></label></td>
    <td width="26%">&nbsp;</td>
  </tr>
  
  <tr> 
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></td>
  </tr>
  <tr bgcolor="#A49A6A"> 
    <td height="25" colspan="3">&nbsp;</td>
  </tr>
</table>
</form>
</body>
</html>
