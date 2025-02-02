<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function refreshAjax(){
	this.loadAjax();	
   	window.setTimeout("refreshAjax()", 3000);//every 3 min.
}
function loadAjax(){
	var objCOAInput = document.getElementById('msg_in_process');
 	
	this.InitXmlHttpObject2(objCOAInput, 2, "<img src='../../../Ajax/ajax-loader_small_black.gif'>");//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=190";
	this.processRequest(strURL);	
}
</script>
<body bgcolor="#D2AE72" onLoad="refreshAjax();">
<%
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strName = (String)request.getSession(false).getAttribute("first_name");
if(strName == null) 
	strName ="<NOT FOUND>";

%><form>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25"  colspan="3"><div align="center"><font color="#FFFFFF"><strong>:::: 
          SMS MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
<%
if(strUserId == null){%>
    <tr > 
      <td height="25" colspan="3" align="center">
	  <font size="3" face="Verdana, Arial, Helvetica, sans-serif">You are already logged out. Please login again.</font></td>
    </tr>
<%}else{%>
    <tr> 
      <td height="25"  colspan="3"><div align="center"><strong><font size="3">WELCOME 
          <%=strName.toUpperCase()%> TO THE SMS MANAGEMENT PAGE!</font></strong></div></td>
    </tr>
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="5%">&nbsp;</td>
      <td width="91%" height="25"> <div align="justify"> 
          Please 
            note that every activity is monitored closely. For any problem in 
            the system, contact System Administrator for details. Click the links 
            under MENU to select operation. It is recommended to logout by clicking 
            the logout button everytime you leave your PC.
          <p>If you 
            do not agree with the conditions or you are not <b><%= strUserId %></b>, Logout now. </p>
          <p><strong><u>Please read below the capability of SMS</u></strong><br>
            1. Broadcast Message<br>
			2. Send Alert message upon payment, enrollment, grade verification<br>
			3. Send SMS from the following page - violation, library outstanding book and fine, o/s balance page<br>
			4. Interface to create buddy list/SMS group<br>
			5. Broadcase to SMS group or selected student or to all enrolled student.<br>
			
			<strong><u>Special Feature</u></strong><br>
			6. Send message to mobile on different mobile network within and outside the school network<br>
				&nbsp;&nbsp;&nbsp;&nbsp;For example (You can send SMS to Smart/Globe from Sun network by sending sms to Sun number of our system)<br>
			7. Receive message from within and outside network<br>
			8. Block any mobile phone from sending/receiving any kind of message.<br>
			9. Query database for account balance, payment schedule, grade.<br>
			<strong><u>Command List</u></strong><br>  
			Note : Following is the list of command for SMS gateway <br>
			1. #balance - to get account balance<br>
			2. #clearance - to know if eligible to get clearance, if not, lists the pending clearance.<br>
			3. #library - lists the currently issues books, and outstanding fine.<br>
			4. #grade - gives the current sy/term final grade status for the subjects already having verified grade<br>
			5. #request - sends request to school.<br>
			6. #forward - forwards the message to the mobile number after keyword #forward. Mobile number should start with 9xx. Please do not add +63 or 0 to the number. the Number must be registered to the system.<br>
			7. #list - gives list of command.<br>
			8. #help - gives description of any command typed after #help. For example #help balance : describes how to use command balance and what it returns.
		  </p>
      </div></td>
      <td width="4%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" align="center"><div style="width:300px; height:100px;">
	  <font style="font-size:11px; font-weight:bold; color:#FF5500">Refresh time: 3mins</font><br>
	  <label id="msg_in_process">
<!-- Sample.. 
Total Message to process : 
Broadcast Msg : 
Alert : 
Query : 
M to M : -->
</label>

	  </td>
    </tr>
<%}%>    
    
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
