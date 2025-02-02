<%
String strSentBy = request.getParameter("sent");
if(strSentBy == null)
	strSentBy = "Chat Invitation";
else
	strSentBy = strSentBy + " Says: ";
String strMessage = (String)request.getSession(false).getAttribute("chat_msg");
request.getSession(false).removeAttribute("chat_msg");
if(strMessage == null)
	strMessage = (String)request.getParameter("message");
%>
<html>
<head>
<Title><%=strSentBy%></Title>
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script>
//close after 5 secs.
///fading affect... 
function makearray(n) {
    this.length = n;
    for(var i = 1; i <= n; i++)
        this[i] = 0;
    return this;
}

hexa = new makearray(16);
for(var i = 0; i < 10; i++)
    hexa[i] = i;
hexa[10]="a"; hexa[11]="b"; hexa[12]="c";
hexa[13]="d"; hexa[14]="e"; hexa[15]="f";

function hex(i) {
    if (i < 0)
        return "00";
    else if (i > 255)
        return "ff";
    else
        return "" + hexa[Math.floor(i/16)] + hexa[i%16];
}

function setbgColor(r, g, b) {
    var hr = hex(r); var hg = hex(g); var hb = hex(b);
    eval("document.bgColor = '#"+hr+hg+hb+"'");
	
}

var i = 0;
var globalSR='';
var globalSG;
var globalSB;
var globalER;
var globalEG;
var globalEB;
var globalSTEP;

function fade(sr, sg, sb, er, eg, eb, step) {
	if(globalSR == '') {
		globalSR = sr;
		globalSG = sg;
		globalSB = sb;
		globalER = er;
		globalEG = eg;
		globalEB = eb;
		globalSTEP = step;
	}
    //for(var i = 0; i <= step; ++i) {
		i += 6;
        setbgColor(
        Math.floor(sr * ((step-i)/step) + er * (i/step)),
        Math.floor(sg * ((step-i)/step) + eg * (i/step)),
        Math.floor(sb * ((step-i)/step) + eb * (i/step)));
    //}
	if(i <= step)
		setTimeout('fadeGlobal()', 20);
	else	
		self.close();
}
function fadeGlobal() {
	fade(globalSR,globalSG,globalSG,globalER,globalEG,globalEB,globalSTEP);
}
////////////end of fading affect.. 

function DissolveWnd() {
	fade(255,255,255, 0,0,0, 255);
	//self.close();
}
setTimeout('DissolveWnd()',10000);

/** this opens a chat window.. **/
function OpenChat(strChatReqID) {
	var pgLoc = "../../commfile/chat/AjaxChat.jsp?user_id_to="+strChatReqID;
	var win=window.open(pgLoc,strChatReqID,'width=600,height=500,top=10,left=10,scrollbars=no,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>
<body onLoad="this.focus()">
<font style="font-size:11px; font-family:Verdana, Arial, Helvetica, sans-serif">
	<font style="font-weight:bold; color:#996699"><u><%=strSentBy%></u><br></font>
	<%=strMessage%>
</font>
</body>
</html>
	