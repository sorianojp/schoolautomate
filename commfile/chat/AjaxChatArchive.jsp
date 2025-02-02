<%
String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
if(strUserIndex == null) {%>
	<font style="font-size:14px; color:#FF0000; font-weight:bold"><div align="center">.........Please login to use SB Chat.........</div></font>
<%return;}
String strUserID = (String)request.getSession(false).getAttribute("userId");
%>
<html>
<head>
<title>Message Archive for <%=(String)request.getSession(false).getAttribute("first_name")%> (<%=strUserID%>)</title>
<style>
.messageBoxSummary {
	height: 180px; width:350px; overflow: auto; border: inset black 1px;
}
.messageBoxDate {
	height: 180px; width:330px; overflow: auto; border: inset black 1px;
}
.messageBoxMessage {
	height: 290px; width:700px; overflow: auto; border: inset black 1px;
}
/**
.messageBox div label {
display: block;
width: 4em; background: #eee; color: black; margin-bottom: 0.1em; }
**/
</style>
</head>
<script language="javascript">

var objDivSummary = null;
var objDivDate    = null;
var objDivMessage = null;

var iMethodRef = "";

//I have to load two divs dynamically - div date and div message detail.
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
		if(retObj == "\r\n")
			return;
		if(iMethodRef == "106") {
			objDivDate.innerHTML = retObj;
			objDivMessage.innerHTML = "";
		}
		else
			objDivMessage.innerHTML = retObj;
		///I have to now get here information and update corresponding div.
	}
	else {
		///show message that Processing .. for the DIV that is to be updated..
		if(iMethodRef == "106") {
			objDivDate.innerHTML = "Processing request....";
			objDivMessage.innerHTML = "";
		}
		else
			objDivMessage.innerHTML = "Processing request....";
	}
}
function UpdateDivDate(strContactIndex) {

	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=106&contact_index="+strContactIndex;
	iMethodRef = "106";
	//alert(strURL);
	this.processRequest(strURL);
}
function UpdateDivMessage(strMsgDate, strContactIndex) {
	var strURL = "../../Ajax/AjaxInterface.jsp?contact_index="+strContactIndex+"&methodRef=107&msg_date="+strMsgDate;
	iMethodRef = "107";
	//alert(strURL);
	this.processRequest(strURL);
}

function initJavascriptVariable() {
	objDivSummary = document.getElementById('messageBoxSummary');
	objDivDate    = document.getElementById('messageBoxDate');
	objDivMessage = document.getElementById('messageBoxMessage');
}

//document.oncontextmenu=context;//Disable Right click

/*** added code to disable right click **/
function context(){//This function takes care of Net 6 and IE.
	alert("Right click disabled")
	return false;
}
/*** added code to disable right click **/

</script>

<%
	utility.DBOperation dbOP = new utility.DBOperation();
	java.util.Vector vRetResult = new java.util.Vector();
	utility.MessageSystem msgSystem = new utility.MessageSystem();
	String strErrMsg = null;

	vRetResult = msgSystem.chatMessageArchive(dbOP, request, 3);
	if(vRetResult == null || vRetResult.size() == 0) {
		strErrMsg = "<font size=3 color='red'><b>"+msgSystem.getErrMsg()+"</b></font>";
		if(strErrMsg == null || strErrMsg.length() == 0)
			strErrMsg = "<font size=3 color='red'><b>No Chat archive found.</b></font>";
	}

dbOP.cleanUP();
%>
<body onLoad="initJavascriptVariable();" style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:11px;" topmargin="0">
<form name="form_">
<a href="./chat_main.jsp"><img src="../../images/go_back.gif" border="0"></a> Go back to Chat Main window.
<table cellpadding="0" cellspacing="0">
<tr>
<td>
	<div class="messageBoxSummary">
	<label id="messageBoxSummary" style="font-size:11px; font-family:Verdana, Arial, Helvetica, sans-serif">
	<!-- I must get here information from java -->
	<%if(vRetResult != null && vRetResult.size() > 0) {
		for(int i = 0; i < vRetResult.size(); i += 2) {%>
			<a href="javascript:UpdateDivDate('<%=vRetResult.elementAt(i + 1)%>')" style="text-decoration:none;"><%=vRetResult.elementAt(i)%></a><br>
		<%}
	}else{%><%=strErrMsg%><%}%>
	</label>
	</div>
</td>
<td width="2%">&nbsp;</td>
<td>
	<div class="messageBoxDate">
	<label id="messageBoxDate" style="font-size:11px; font-family:Verdana, Arial, Helvetica, sans-serif">To show message dates, click on chat archive for user at left side</label>
	</div>
</td>
</tr>
<tr><td colspan="3">&nbsp;</td></tr>
<tr>
<td colspan="3">
	<div class="messageBoxMessage">
	<label id="messageBoxMessage" style="font-size:11px; font-family:Verdana, Arial, Helvetica, sans-serif">To display message archive for a date, click on chat date on top-right box.</label>
	</div>
</td>
</tr>
</table>
</form>
</body>
</html>
