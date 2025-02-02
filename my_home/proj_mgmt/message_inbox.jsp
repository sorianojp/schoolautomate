<%@ page language="java" import="utility.*, projMgmt.GTIProjectMessages, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userIndex") == null){%>
		<p style="font-size:16px; color:#FF0000;">You are logged out.</p>
		<%return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Message Inbox</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">

	function PostReply(){
		document.form_.post_reply.value = "1";
		document.form_.submit();
	}
	
	function ReadMessage(strMsgIndex){
		document.form_.msg_index.value = strMsgIndex;
		document.form_.post_reply.value = "";
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.msg_index.value = "";
		document.form_.post_reply.value = "";
		document.form_.submit();
	}
	
	function GoBack(){
		location = "./messages.jsp";
	}
	
</script>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Project Management-Message Inbox","message_inbox.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	
	GTIProjectMessages msg = new GTIProjectMessages();
	
	int iSearchResult = 0;
	Vector vRetResult = null;
	Vector vMessage = null;	
	
	if(WI.fillTextValue("post_reply").length() > 0){
		if(msg.getMessageDetails(dbOP, request, 1) == null)
			strErrMsg = msg.getErrMsg();
		else
			strErrMsg = "Reply posted successfully.";
	}
		
	if(WI.fillTextValue("msg_index").length() > 0){	
		vMessage = msg.getMessageDetails(dbOP, request, 4);
		if(vMessage == null)
			strErrMsg = msg.getErrMsg();
	}
	else{
		vRetResult = msg.getMessages(dbOP, request);
		if(vRetResult == null)
			strErrMsg = msg.getErrMsg();
		else
			iSearchResult = msg.getSearchCount();
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="message_inbox.jsp">
<br />
<jsp:include page="./tabs.jsp?pgIndex=7"></jsp:include>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="87%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
			<td width="10%" align="right"><a href="javascript:GoBack();"><img src="../../images/go_back.gif" border="0"></a></td>
		</tr>
	</table>
	
<%if(WI.fillTextValue("msg_index").length() == 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%">
				<%				
					strErrMsg = WI.fillTextValue("view_type");
					if(strErrMsg.equals("1") || strErrMsg.length() == 0)
						strTemp = "checked";
					else
						strTemp = "";
					
				%>					
				<input name="view_type" type="radio" value="1" <%=strTemp%> onClick="ReloadPage();">View All 
				
				<%	
					if(strErrMsg.equals("2"))
						strTemp = "checked";
					else
						strTemp = "";
				%>	
				<input name="view_type" type="radio" value="2" <%=strTemp%> onClick="ReloadPage();">View Inbox
				
				<%				
					if(strErrMsg.equals("3"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input name="view_type" type="radio" value="3" <%=strTemp%> onClick="ReloadPage();">View Sentbox</td>
		</tr>
	</table>
<%}

if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
		<tr>
			<td height="20" colspan="5" bgcolor="#B9B292" class="thinborder"><div align="center">
				<strong>::: INBOX ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="3">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(msg.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td height="25" class="thinborderBOTTOM" colspan="2">&nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/msg.defSearchSize;		
				if(iSearchResult % msg.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+msg.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="ReloadPage();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i =1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
		  		<%}%></td>
		</tr>
		<tr>
			<td height="25" width="20%" align="center" class="thinborder"><strong>Priority</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>From</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>To</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Date Created </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Replies</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 12){%>
		<tr onClick="ReadMessage('<%=(String)vRetResult.elementAt(i)%>');">
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+10)%></td>
			<td class="thinborder"><%=WebInterface.formatName((String)vRetResult.elementAt(i+7), (String)vRetResult.elementAt(i+8), (String)vRetResult.elementAt(i+9), 4)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+11), "0")%></td>
		</tr>
	<%}%>
	</table>
<%}

if(vMessage != null && vMessage.size() > 0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25"><a href="javascript:ReloadPage();">
				<strong><font color="#0000FF">&lt;&lt;BACK TO MESSAGES </font></strong></a></td>
		</tr>
	</table>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<%for(int i = 0; i < vMessage.size(); i += 5){
		if((String)vMessage.elementAt(i+2) != null){%>
		<tr>
			<td height="25" colspan="3" class="thinborder"><strong><%=(String)vMessage.elementAt(i+2)%></strong></td>
		</tr>
		<%}%>
		<tr>
			<td height="25" colspan="2" class="thinborderLEFT">
				<%=(String)vMessage.elementAt(i)%>&nbsp;&nbsp;<font size="1">(<%=(String)vMessage.elementAt(i+1)%>)</font></td>
		    <td width="5%" align="center" class="thinborderNONE">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" width="5%" class="thinborderBOTTOMLEFT">&nbsp;</td>
			<td colspan="2" class="thinborderBOTTOM"><%=(String)vMessage.elementAt(i+3)%></td>
		</tr>
	<%}%>
	</table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" width="5%">&nbsp;</td>
			<td width="95%">
				<textarea name="reply" style="font-size:12px" cols="80" 
					rows="4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("reply")%></textarea></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td><a href="javascript:PostReply();"><img src="../../images/send_email.gif" border="0"></a>
				<font size="1">Click to post reply</font></td>
		</tr>
	</table>
<%}%>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="msg_index" value="<%=WI.fillTextValue("msg_index")%>">
	<input type="hidden" name="post_reply">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>