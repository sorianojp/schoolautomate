<%
String strUserID = (String)request.getSession(false).getAttribute("userId");
if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}%>

<%@ page language="java" import="utility.*,sms.SystemSetup,,java.util.Vector" %>
<%	
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function AjaxUpdateOthers(strIndexName, strIndex, strTableName, strFieldName, strIsString, objCOA){		
		//var objCOA=eval('document.form_.'+strFieldName);
		this.InitXmlHttpObject(objCOA, 1);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20401&table_name="+strTableName+"&field_name="+strFieldName+"&table_index="+strIndex+"&is_string="+strIsString+"&field_value="+objCOA.value+"&"+strFieldName+"="+objCOA.value+"&index_name="+strIndexName;
		this.processRequest(strURL);
	}
	
</script>
<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	try {
		dbOP = new DBOperation(strUserID,"SMS-Setting","sms_alerts_allowed.jsp");
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
	Vector vRetResult = systemSetup.getSMSAlertsAllowed(dbOP, request);
	if(vRetResult == null)
		strErrMsg = systemSetup.getErrMsg();
%>
<form name="form_" method="post" action="./sms_alerts_allowed.jsp">
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="4" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: SMS ALERTS ALLOWED ::::</strong></font></div></td>
		</tr>
	</table>
			
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td width="3%" height="25">&nbsp;</td>
			<td width="97%"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
	</table>
  
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
		<tr> 
			<td height="20" colspan="2" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>
				<font color="#FFFFFF">LIST OF SMS ALERTS </font></strong></div></td>
		</tr>
		<tr>
			<td width="80%" height="25" align="center" class="thinborder"><strong>Alert Name </strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Allowed?</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 3, iCount++){%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+2);
			%>
			<td class="thinborder" align="center">
				<select name="is_allowed_<%=iCount%>"  onChange="javascript:AjaxUpdateOthers('alert_index', '<%=(String)vRetResult.elementAt(i)%>', 'SMS_ALERTS_ALLOWED', 'is_allowed', '0', document.form_.is_allowed_<%=iCount%>);">
				<%if(strTemp.equals("1")){%>
					<option value="1" selected>YES</option>
				<%}else{%>
					<option value="1">YES</option>
					
				<%}if(strTemp.equals("0")){%>
					<option value="0" selected>NO</option>
				<%}else{%>
					<option value="0">NO</option>
				<%}%>
				</select></td>
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