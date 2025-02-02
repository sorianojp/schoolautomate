<%@ page language="java" import="utility.*, Accounting.TsuneishiDC, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>DC Note Attachment</title>
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<body onload="window.print();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BILLING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ACCOUNTING-BILLING","update_invoice.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> <%=strErrMsg%></font></p>
	<%
		return;
	}	
	
	double dTemp = 0d;
	Vector vDCInfo = null;
	Vector vRetResult = null;
	TsuneishiDC tsuDC = new TsuneishiDC();
	
	vDCInfo = tsuDC.getDCInformation(dbOP, request);
	if(vDCInfo != null)
		vRetResult = tsuDC.operateOnDCNoteDetails(dbOP, request, 4, (String)vDCInfo.elementAt(0));
	
	if(vRetResult != null && vRetResult.size() > 0 && ((String)vDCInfo.elementAt(5)).equals("THI")){
		for(int i = 0; i < vRetResult.size(); i += 7){%>
		<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
			<tr>
				<td height="30" valign="top"><strong><font size="2">TSUNEISHI TECHNICAL SERVICES (PHILS.), INC.</font></strong></td>
			</tr>
			<tr>
				<td height="45">&nbsp;</td>
			</tr>
			<tr>
				<td height="30">West Cebu Industrial Park, Buanoy Balamban 6041, Cebu Philippines</td>
			</tr>
			<tr>
			<td height="30">Tel No. (32)230-84-75&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Fax No. (32)333-25-13</tr>
			<tr>
				<td height="30">&nbsp;</td>
			</tr>
			<tr>
				<td height="30"><%=WI.formatDate((String)vDCInfo.elementAt(1), 6)%></td>
			</tr>
			<tr>
				<td height="30">&nbsp;</td>
			</tr>
			<tr>
				<td height="30"><strong><%=((String)vDCInfo.elementAt(4)).toUpperCase()%></strong></td>
			</tr>
			<tr>
				<td height="30"><%=(String)vDCInfo.elementAt(7)%></td>
			</tr>
			<tr>
				<td height="30">&nbsp;</td>
			</tr>
		</table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
			<tr>
				<td height="25" width="10%">ATTENTION: </td>
				<td width="90%"><strong><%=WI.getStrValue((String)vRetResult.elementAt(i+4))%></strong></td>
			</tr>
			<tr>
				<td height="25">&nbsp;</td>
				<td><%=WI.getStrValue((String)vRetResult.elementAt(i+5))%></td>
			</tr>
			<tr>
				<td height="25">&nbsp;</td>
				<td><%=WI.getStrValue((String)vRetResult.elementAt(i+6))%></td>
			</tr>
			<tr>
				<td height="40" colspan="2">&nbsp;</td>
			</tr>
			<tr>
				<td height="25" colspan="2">Dear Sir, </td>
			</tr>
			<tr>
				<td height="40" colspan="2">&nbsp;</td>
			</tr>
			<%
				strTemp = (String)vRetResult.elementAt(i+2);//value
				strTemp = ConversionTable.replaceString(strTemp, ",", "");//removing the commas
				dTemp = Double.parseDouble(strTemp);
				strTemp = new ConversionTable().convertAmoutToFigure(dTemp, "", "");
				if(dTemp%1 == 0)
					strTemp = strTemp.substring(0, strTemp.length() - 10);
				strTemp += ((String)vDCInfo.elementAt(9)).toUpperCase();					
				if(!((String)vDCInfo.elementAt(9)).toUpperCase().equals("YEN"))
					strTemp += "S";						
				strTemp += " ONLY";
			%>
			<tr>
				<td height="45" colspan="2" valign="top"><div align="justify">This is to bill you 
					<u><strong><%=strTemp.toUpperCase()%> (<%=(String)vDCInfo.elementAt(10)%><%=(String)vRetResult.elementAt(i+2)%>)
					</strong></u> as payment for <strong><%=(String)vRetResult.elementAt(i+1)%></strong>.</div>
					<!--
					for the month of <%=WI.formatDate((String)vDCInfo.elementAt(1), 11)%>.</div>
					--></td>
			</tr>
			<tr>
				<td height="30" colspan="2">&nbsp;</td>
			</tr>
			<tr>
				<td height="25" colspan="2">As per attached reproduction control record and 
					<%if(((String)vDCInfo.elementAt(14)).equals("0")){%>
						Debit
					<%}else{%>
						Credit
					<%}%> Note no. <u><strong><%=(String)vDCInfo.elementAt(2)%>.</strong></u></td>
			</tr>
			<tr>
				<td height="30" colspan="2">&nbsp;</td>
			</tr>
			<tr>
				<td height="25" colspan="2">Thank you.</td>
			</tr>
			<tr>
				<td height="30" colspan="2">&nbsp;</td>
			</tr>
			<tr>
				<td height="25" colspan="2">by: </td>
			</tr>
			<tr>
				<td height="30" colspan="2"><strong>MARITSUO C. FUSE</strong></td>
			</tr>
			<tr>
				<td height="25" colspan="2">Asst. Mgt. Staff</td>
			</tr>
			<tr>
				<td height="30" colspan="2">&nbsp;</td>
			</tr>
		</table>
		<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
			<tr>
				<td height="30" width="45%">Noted: </td>
				<td width="55%">Approved: </td>
			</tr>
			<tr>
				<td height="30" colspan="2">&nbsp;</td>
			</tr>
			<tr>
				<td height="30"><strong>RACHEL O. NUFABLE</strong>
				<td><strong>SEGISMUNDO F. EXALTACION JR.</strong></td>
			</tr>
			<tr>
				<td height="25">Asst. Supervisor</td>
				<td>General Manager</td>
			</tr>
			<tr>
				<td height="25" colspan="2">Accounting Team</td>
			</tr>
		</table>
		<%if(i+7 < vRetResult.size()){%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
		<%}
		}
	}%>
</body>
</html>
<%
dbOP.cleanUP();
%>