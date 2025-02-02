<%
boolean bolIsChatActive = false;
String strChatActive = (String)request.getSession(false).getAttribute("chat_stat");
if(strChatActive != null && strChatActive.equals("1"))
	bolIsChatActive = true;
//System.out.println(strChatActive);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style>
body {
	margin-top: 0px;
	margin-left: 0px;
	padding-top: 0px;
	padding-left: 0px;
}
<!-- this is style for layer.. -->
#layer1 {
	position: absolute;
	visibility: hidden;
	width: 400px;
	height: 300px;
	left: 20px;
	top: 300px;
	background-color: #ccc;
	border: 1px solid #000;
	padding: 10px;
}

#close {
	float: right;
}
</style>
</head>
<%if(bolIsChatActive){%>
<script language="javascript">
var xmlHttp = null;
function InitXmlHttpObject() {
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
		if (!xmlHttp.status == 200)
			return;
		//alert(xmlHttp.status)
		var retObj = xmlHttp.responseText;		
		if(retObj.indexOf("Error Msg :") == 0) {
			alert(retObj);
			return;
		}
		if(retObj == "\r\n") { 
			//document.getElementById("msg_not_accessed").innerHTML = "<br><font color=red size=1>Message not delivered : 0</font>";
			return;
		}
		if(retObj == 'Reload\r\n') {
			document.form_.submit();
			return;
		}
		if(retObj == 'Reload\r') {
			document.form_.submit();
			return;
		}
		if(retObj == 'Reload') {
			document.form_.submit();
			return;
		}
		PopMsg();
	}
}
/////get chat request.
var newwindow = null;
function getChatRequestAndOfflineMsg() {
	if(newwindow != null) {
		newwindow.close();
		newwindow = null;
	}
	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=110";
	this.processRequest(strURL);
/////run here timer.. 
	window.setTimeout("getChatRequestAndOfflineMsg()", 15000);//15 secs.
//end of timer.. 
}
this.getChatRequestAndOfflineMsg();

/** this is called to pop message in lower right buttom incase window is not on focus..**/
function PopMsg() {
	//use DIV to pop message here, 
	newwindow=window.open("../../commfile/chat/pop_msg.jsp","offlineMsg",
		'width=450,height=200,top=400,left=550,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	if(window.focus)
		newwindow.focus();
}

///////////////// this is used to pop DIV message.. //////////////
/**
function setVisible(obj)
{
	obj = document.getElementById(obj);
	obj.style.visibility = (obj.style.visibility == 'visible') ? 'hidden' : 'visible';
}
	x = 20;
	y = 70;
function placeIt(obj)
{
	
	obj = document.getElementById(obj);
	if (document.documentElement)
	{
		theLeft = document.documentElement.scrollLeft;
		theTop = document.documentElement.scrollTop;
	}
	else if (document.body)
	{
		theLeft = document.body.scrollLeft;
		theTop = document.body.scrollTop;
	}
	theLeft += x;
	theTop += y;
	obj.style.left = theLeft + 'px' ;
	obj.style.top = theTop + 'px' ;
	setTimeout("placeIt('layer1')",500);
}
window.onscroll = setTimeout("placeIt('layer1')",500);
////////////////////////////////////////////////////////////////// end of div pop code. /////////////////
**/
</script>
<%}%>
<body background="../../images/banner_for_all.jpg">
<form name="form_">
</form>
</body>
</body>
</html>
