<%@ page language="java" import="utility.*, docTracking.deped.DocumentTracking, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
<title>Document Tracking Details</title></head>
<script language="javascript" src="../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	
	String strRRIndex = WI.fillTextValue("rr_index");
	String strTransactionIndex = WI.fillTextValue("transaction_index");
	
	if(strRRIndex.length() == 0 || strTransactionIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Transaction reference not found.
		Please close this window and click the link again from document tracking window.</p>
		<%return;
	}
	
	//add security here..
	try{
		dbOP = new DBOperation();
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	DocumentTracking dt = new DocumentTracking();
	Vector vRetResult = dt.trackDocument(dbOP, request, strTransactionIndex, strRRIndex);
	if(vRetResult == null)
		strErrMsg = dt.getErrMsg();
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="view_step_details.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="2" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: DOCUMENT TRACKING DETAILS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Office/Dept:</td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(1));
				strErrMsg = WI.getStrValue((String)vRetResult.elementAt(2));
				
				if(strTemp.length() > 0 && strErrMsg.length() > 0)
					strTemp += "/ ";
				strTemp += strErrMsg;
			%>
			<td width="80%"><%=strTemp%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Received by: </td>
			<td><%=(String)vRetResult.elementAt(3)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Received Date/Time: </td>
			<td><%=(String)vRetResult.elementAt(5)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Receive Remarks: </td>
			<td><%=WI.getStrValue((String)vRetResult.elementAt(6))%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Released by: </td>
			<td><%=(String)vRetResult.elementAt(7)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Released Date/Time: </td>
			<td><%=(String)vRetResult.elementAt(9)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Relase Remarks: </td>
			<td><%=WI.getStrValue((String)vRetResult.elementAt(10))%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Status:</td>
			<%
				strTemp = (String)vRetResult.elementAt(12);
				if(strTemp.equals("1"))
					strTemp = "Received";
				else if(strTemp.equals("2"))
					strTemp = "Released";
				else
					strTemp = "Returned";
			%>
			<td><%=strTemp%></td>
		</tr>
		<%
			strTemp = (String)vRetResult.elementAt(13);
			if(strTemp == null)
				strTemp = "-In Process-";
			else if(strTemp.equals("1")){//forwarded
				strTemp = WI.getStrValue((String)vRetResult.elementAt(14));
				strErrMsg = WI.getStrValue((String)vRetResult.elementAt(15));
				
				if(strTemp.length() > 0 && strErrMsg.length() > 0)
					strTemp += "/ ";
				strTemp += strErrMsg;
				strTemp = "FWD to "+strTemp+". (Resposible Personnel: "+(String)vRetResult.elementAt(11)+")";
			}
			else if(strTemp.equals("2"))//closed
				strTemp = "Completed";
		%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Action:</td>
			<td><%=strTemp%></td>
		</tr>
	</table>
<%}%>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="rr_index" value="<%=strRRIndex%>" />
	<input type="hidden" name="transaction_index" value="<%=strTransactionIndex%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>