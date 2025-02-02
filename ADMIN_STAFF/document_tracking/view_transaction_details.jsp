<%@ page language="java" import="utility.*, docTracking.deped.DocReceiveRelease, java.util.Vector"%>
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
	
	String strBarcodeID = WI.fillTextValue("barcode_id");
	
	if(strBarcodeID.length() == 0){%>
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
	
	DocReceiveRelease drr = new DocReceiveRelease();
	Vector vRetResult = drr.getTransactionInformation(dbOP, request);
	if(vRetResult == null)
		strErrMsg = drr.getErrMsg();
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="view_slip_details.jsp" method="post">

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
			<td width="20%">Origin/Owner:</td>
			<td width="77%"><%=(String)vRetResult.elementAt(1)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Transaction Date: </td>
			<td><%=(String)vRetResult.elementAt(17)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Category:</td>
			<td><%=(String)vRetResult.elementAt(2)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Document Name: </td>
			<td rowspan="2" valign="top"><%=(String)vRetResult.elementAt(4)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<%
			strTemp = (String)vRetResult.elementAt(14);
			if(strTemp.equals("1"))
				strErrMsg = "Complete/";
			else
				strErrMsg = "In Process";
				
			if(strTemp.equals("1")){
				if(((String)vRetResult.elementAt(15)).equals("1"))
					strErrMsg += "Released";
				else
					strErrMsg += "Unreleased";
			}
		%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Status: </td>
			<td><%=strErrMsg%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Responsible Person: </td>
			<td><%=(String)vRetResult.elementAt(13)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Created By: </td>
			<td><%=(String)vRetResult.elementAt(18)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Created by (Offce/Dept): </td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(6));
				strErrMsg = WI.getStrValue((String)vRetResult.elementAt(8));
				
				if(strTemp.length() > 0 && strErrMsg.length() > 0)
					strTemp += "/ ";
				strTemp += strErrMsg;
			%>
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
	
	<input type="hidden" name="barcode_id" value="<%=strBarcodeID%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>