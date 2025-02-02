<%
String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
if(strUserIndex == null) {%>
	<font style="font-size:14px; color:#FF0000; font-weight:bold"><div align="center">.........Please login to use SB Chat.........</div></font>
<%return;}
String strUserID = (String)request.getSession(false).getAttribute("userId");

String strUserIndexTo = (String)request.getParameter("user_id_to");
String strUserInfoTo  = null;
utility.WebInterface WI = new utility.WebInterface(request);

if(strUserIndexTo != null) {
	if(strUserIndexTo.length() == 0)
		strUserIndexTo = null;
	else {
		utility.DBOperation dbOP = new utility.DBOperation();
		String strSQLQuery = "select id_number, fname, mname, lname, user_index from user_Table where id_number = '"+strUserIndexTo+
								"' and is_valid = 1";
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			strUserInfoTo = rs.getString(1) +" :: "+WI.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 4);
			strUserIndexTo = rs.getString(5);
		}
		else
			strUserIndexTo = null;
		rs.close();
		dbOP.cleanUP();
	}
}
if(strUserIndexTo == null) {%>
	<font style="font-size:14px; color:#FF0000; font-weight:bold"><div align="center">.........User not found in Database. Please select another ID.........</div></font>
<script>
alert("User not found. This window will close now");
self.close();
</script>

<%return;}

////here is code for managing chat windows.. if chat window is more than 1, i must set is_active_ field of user table to 1 else 0
//i am keeping user id person is talking to..
java.util.Vector vChatUser = (java.util.Vector)request.getSession(false).getAttribute("vChatUser");
if(vChatUser == null || vChatUser.size() == 0 || vChatUser.indexOf(strUserIndexTo) == -1) {
	if(vChatUser == null)
		vChatUser = new java.util.Vector();
	vChatUser.addElement(strUserIndexTo);
}
//System.out.println(vChatUser);
request.getSession(false).setAttribute("vChatUser",vChatUser);

%>
<html>
<head>
<title>Chat with <%=(String)request.getParameter("user_id_to")%></title>
<style>
.messageBox {
	height: 250px; width:550px; overflow: auto; border: inset black 1px;
}
/**
.messageBox div label {
display: block;
width: 4em; background: #eee; color: black; margin-bottom: 0.1em; }
**/
</style>

<!--
<link rel="stylesheet" href="./dhtmlwindow.css" type="text/css" />
-->
</head>
<!-- pop small notification if window is not in focus.. -->
<!--
<script language="javascript" src="./dhtmlwindow.js"></script>
-->
<script language="javascript">
var bolFirstTime = true;

var objMsg       = null;
var objMsgInput  = null;
var objDivBox    = null;

var strFocusStat = "";//if on focus = 1, blur = 0

function UpdateMsg() {
	if(document.form_.input_msg.value.length == 0)
		return;

	if(bolFirstTime)
		objMsg.innerHTML = "<font style='font-weight:bold; color=\"#aaaaaa\"'><%=strUserID%>: </font>"+objMsgInput.value;
	else
		objMsg.innerHTML = objMsg.innerHTML +
			"<br><font style='font-weight:bold; color=\"#aaaaaa\"'><%=strUserID%>: </font>"+objMsgInput.value;

	objDivBox.scrollTop = objDivBox.scrollHeight;
}
///at this time, just move up the information.
var ctrlPressed = false;//true if ctrl is pressed..
var characterCode; //literal character code will be stored in this variable
function getKeyPressed(e) {
	if(e && e.which){ //if which property of event object is supported (NN4)
		e = e;
		characterCode = e.which; //character code is contained in NN4's which property
		if(characterCode == 116)//disable Pressing F5
			return false;
	}
	else{
		e = event;
		characterCode = e.keyCode; //character code is contained in IE's keyCode property
		if(characterCode == 116) {//disable Pressing F5
			event.returnValue = false;
			e.keyCode = 0;
		}
	}
}
//ctrlPress = true if CTRL key is pressed.
function checkCTRLKeyPress(e) {
/**
	this.getKeyPressed(e);
	if(characterCode == 17) {
		ctrlPressed = true;
		//alert("Here")
	}
**/
}

function checkEnterKeyKeyUp(e){ //e is event object passed from function invocation
	this.getKeyPressed(e);

	if(characterCode == 13){ //if generated character code is equal to ascii 13 (if enter key)
	//alert(ctrlPressed);
		//if(ctrlPressed) {
		//	document.form_.input_msg.value = document.form_.input_msg.value+"\r\n";
		//	return;
		//}

		//must apply trim
		/**
		if(objMsgInput.value.indexOf("\r\n") != -1) {//IE
			if(objMsgInput.value.length < 3) {
				objMsgInput.value = "";
				return;
			}
		}
		else if(objMsgInput.value.indexOf("\n") != -1) {//Netscape
			if(objMsgInput.value.length < 2) {
				objMsgInput.value = "";
				return;
			}
		}**/
		//alternate code..
		if(objMsgInput.value == "\r\n" || objMsgInput.value == "\n") {
			objMsgInput.value = "";
			return;
		}
		this.UpdateMsg();
		bolFirstTime = false;
		this.sendMessageToServer();

		document.form_.input_msg.value = "";
		document.form_.input_msg.focus();

	}
	//else
	//	ctrlPressed = false;

}

//I have to send message. -- Call Ajax here.
var xmlHttp = null;
function InitXmlHttpObject() {
	//if(xmlHttp != null)
	//	return;

	try {// Firefox, Opera 8.0+, Safari
		xmlHttp=new XMLHttpRequest();
  	}
	catch (e){// Internet Explorer
		try {
			xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
		}
		catch (e) {
			xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
		}
	}
}
function processRequest(strCompleteURL) {
	this.InitXmlHttpObject();
	if(xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	xmlHttp.onreadystatechange=stateChanged;
	xmlHttp.open("GET",strCompleteURL,true);
	xmlHttp.send(null);
}
function stateChanged() {
	if (xmlHttp.readyState==4) {
          if (!xmlHttp.status == 200) {//bad request.
            alert("Connection to server is lost");
            return;
          }
        	var retObj = xmlHttp.responseText;
		if(retObj.indexOf("Error Msg :") == 0) {
			alert(retObj);
			return;
		}
		if(retObj == "\r\n") {
			document.getElementById("msg_not_accessed").innerHTML = "<br><font color=red size=1>Message not delivered : 0</font>";
			return;
		}
		else if(retObj.indexOf("#@-") == 0) {
			var iIndexOf = retObj.indexOf("-@#");
			document.getElementById("msg_not_accessed").innerHTML = "<br><font color=red size=1>Message not delivered : "+retObj.substring(3,iIndexOf)+"</font>";
			return;
		}
		document.getElementById("msg_not_accessed").innerHTML = "<br><font color=red size=1>Message not delivered : 0</font>";

		objMsg.innerHTML = objMsg.innerHTML + "<br>"+retObj;
		objDivBox.scrollTop = objDivBox.scrollHeight;
		bolFirstTime = false;
		//alert("I am here.");
		//window.focus();
		//window.blur();
		///I have to check if this is on focus..
		//window.onfocus = alert("I am here.");//PopMsg(retObj);
		//window.onblur = alert("I am here.Blur");//PopMsg(retObj);
		if(strFocusStat == '0')
			PopMsg(retObj);
			//alert("Ajax : I am blur");

	}
	else {
		///show message that Processing..
	}
}
function sendMessageToServer() {
	var strMsgToSend = objMsgInput.value;
	//remove \r and \n.
	strMsgToSend = strMsgToSend.substring(0, strMsgToSend.length - 1);///netscape only appends \n
	if(strMsgToSend.indexOf("\r") != -1)//added for IE
		strMsgToSend = strMsgToSend.substring(0, strMsgToSend.length - 1);

	var strURL = "../../Ajax/AjaxInterface.jsp?userIndex=<%=strUserIndexTo%>&methodRef=105&msg="+escape(strMsgToSend);
	//alert(strURL);
	this.processRequest(strURL);
}

/////get and update message here.
function getMessageFromServer() {
	var strURL = "../../Ajax/AjaxInterface.jsp?userIndex=<%=strUserIndexTo%>&methodRef=105";
	this.processRequest(strURL);
/////run here timer..
	window.setTimeout("getMessageFromServer()", 10000);//10 secs.
//end of timer..
}
function DestroyChatWnd() {
	var strURL = "../../Ajax/AjaxInterface.jsp?userIndex=<%=strUserIndexTo%>&methodRef=109";
	this.processRequest(strURL);
}



function initJavascriptVariable() {
	objMsg      = document.getElementById('msg');
	objMsgInput = document.form_.input_msg;

	objDivBox   = document.getElementById('div_msgBox');
}

document.onkeydown=getKeyPressed;//Disable F5
//document.oncontextmenu=context;//Disable Right click

/*** added code to disable right click **/
function context(){//This function takes care of Net 6 and IE.
	alert("Right click disabled")
	return false;
}
/*** added code to disable right click **/

/**
Feature to add
1. Conference and integrate invitation.
2. Indicate if user goes offline/close window.
**/

function focuseMsgInput() {
	if(objMsgInput)
		objMsgInput.focus();
}

/** this is called to pop message in lower right buttom incase window is not on focus..**/
function PopMsg(strMessage) {
	//var inlinewin=dhtmlwindow.open("chatMsg", "inline", strMessage,
	//	"<%=strUserInfoTo%> says", "width=300px,height=120px,left=150px,top=10px,resize=0,scrolling=0", "xyz")
	//inlinewin.focus();

	var newwindow=window.open("./pop_msg.jsp?sent="+escape("<%=strUserInfoTo%>")+"&message="+escape(strMessage),"<%=strUserIndexTo%>1",
		'width=300,height=100,top=500,left=650,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	if(window.focus)
		newwindow.focus();

}

function WindowBlur() {
	strFocusStat = '0';
}
function WindowFocus() {
	strFocusStat = '1';
}
function CheckFocus() {
	window.onblur=WindowBlur;
	window.onfocus=WindowFocus;
}
//setTimeout('CheckFocus()',5000);
</script>


<body onLoad="initJavascriptVariable();getMessageFromServer();focuseMsgInput();"
	style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:11px;" bgcolor="#D3D3D3" onUnload="DestroyChatWnd()">
	<!-- make GTI software as back ground -->
<form name="form_"><font style="color:#990000; font-weight:bold; font-size:10px;">


Chating with : <%=strUserInfoTo%> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Started at : <%=WI.getTodaysDateTime()%></font>
<label id="msg_not_accessed"></label>
<div class="messageBox" id="div_msgBox">
<label id="msg" style="font-size:11px; font-family:Verdana, Arial, Helvetica, sans-serif"></label>
</div>
<br>
<!--
<div align="right" style="width:550px">
<input type="button" onClick="UpdateMsg();" value="Send"
	style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; height:30px; width:70px; solid #FF0000;">
</div>
-->
<table><tr><td style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:11px;">
Note : Please press ENTER to send message. to check message archive, go to your <br>
chat message information page. If user is not online, msg will be shown as offline
</td>
</tr>
<tr><td>
<textarea id="input_msg_id" name="input_msg" rows="5"; cols="87"  onKeyUp="checkEnterKeyKeyUp(event);" onKeyDown="checkCTRLKeyPress(event);"
style="display: none; font-family:Verdana, Arial, Helvetica, sans-serif; font-size:11px; border:solid #0000FF 1px; overflow:auto"
onBlur="WindowBlur();document.bgColor='lightgrey'" onFocus="WindowFocus();document.bgColor='antiquewhite'"></textarea>
</td></tr></table>

<div id="noJSMessage" style="display:compact; font-weight:bold; font-size:14px; color:#FF0000">Please enable Javascript and relaunch chat window.</div>

</form>
<script>
document.getElementById('noJSMessage').style.display='none';
document.getElementById('input_msg_id').style.display='block';
//objMsgInput.focus();
</script>

</body>
</html>
