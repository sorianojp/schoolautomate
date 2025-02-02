<%
String strUserID = (String)request.getSession(false).getAttribute("userId");
if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}%>

<%@ page language="java" import="utility.*,sms.SystemSetup,sms.utility.CommonInterface, java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Keyword Listing</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	
	try {
		dbOP = new DBOperation(strUserID,"SMS-Setting","keyword_listing.jsp");
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

	SystemSetup systemSetup = new SystemSetup();
	Vector vRetResult = systemSetup.getKeywordListing(dbOP, request);
	if(vRetResult == null) 
		strErrMsg = systemSetup.getErrMsg();
%>
<form action="./keyword_listing.jsp" method="post" name="form_">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="2" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: SMS KEYWORD LISTING ::::</strong></font></div></td>
		</tr>
		<tr> 
			<td width="3%" height="25">&nbsp;</td>
			<td width="97%"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">    
		<tr> 
			<td width="100%" height="25" colspan="4" bgcolor="#B9B292"><div align="center">
				<strong><font color="#FFFFFF">COMPORT SIM DETAIL </font></strong></div></td>
		</tr>
		<tr> 
			<td width="20%" height="25" align="center" class="thinborder"><strong>Keyword</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Keycode</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Auto<br>Response</strong></td>
			<td width="50%" align="center" class="thinborder"><strong>Help Information</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 4){%>
		<tr> 
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">
				<%
					strTemp = (String)vRetResult.elementAt(i+2);
					if(strTemp.equals("1")){%>
						<img src="../../../images/tick.gif" border="0">
					<%}else{%>
						<img src="../../../images/x.gif" border="0">
					<%}
				%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
		</tr>
	<%}%>
  	</table>
<%}//vRetResult is not null%>

	<table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>