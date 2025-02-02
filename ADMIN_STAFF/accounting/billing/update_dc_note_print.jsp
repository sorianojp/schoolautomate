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
<title>DC Note</title>
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
	
	double dTotal = 0d;
	Vector vDCInfo = null;
	Vector vRetResult = null;
	TsuneishiDC tsuDC = new TsuneishiDC();
	
	int iLineCount = 0;
	int iMaxLines = 5;
	
	vDCInfo = tsuDC.getDCInformation(dbOP, request);
	if(vDCInfo != null)
		vRetResult = tsuDC.operateOnDCNoteDetails(dbOP, request, 4, (String)vDCInfo.elementAt(0));
	
	if(vRetResult != null && vRetResult.size() > 0){
		dTotal = Double.parseDouble((String)vDCInfo.elementAt(12));
	%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="115" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" width="12%" align="center">
				<%if(((String)vDCInfo.elementAt(14)).equals("0")){%>
					DEBIT
				<%}else{%>
					CREDIT
				<%}%></td>
			<td width="55%">&nbsp;</td>
			<td width="21%"><%=WI.formatDate((String)vDCInfo.elementAt(1), 9)%></td>
			<td width="12%">
				<%
					strTemp = WI.formatDate((String)vDCInfo.elementAt(1), 12);
					strTemp = strTemp.substring(2,strTemp.length());
				%>&nbsp;&nbsp;<%=strTemp%></td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td colspan="3"><%=(String)vDCInfo.elementAt(4)%></td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td colspan="3"><%=(String)vDCInfo.elementAt(7)%></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="35" width="6%">&nbsp;</td>
			<td width="25%" align="center">
				<%if(((String)vDCInfo.elementAt(14)).equals("0")){%>
					DEBITED
				<%}else{%>
					CREDITED
				<%}%></td>
			<td width="16%">&nbsp;</td>
			<td width="18%"><%=(String)vDCInfo.elementAt(10)%><%=CommonUtil.formatFloat(dTotal, true)%></td>
			<td width="35%">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="23" width="75%" align="center">&nbsp;</td>
			<td width="25%" align="center">&nbsp;</td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 7, iLineCount++){%>
		<tr>
			<td height="23">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td align="right">
			<%if(i == 0){//if first time, show currency symbol%>
				<%=(String)vDCInfo.elementAt(10)%>
			<%}%><%=(String)vRetResult.elementAt(i+2)%>&nbsp;</td>
		</tr>
	<%}
	
	if(iLineCount < iMaxLines){
		for(int i = iLineCount; i < iMaxLines; i++){%>
		<tr>
			<td height="23" colspan="2">&nbsp;</td>
		</tr>
		<%}
	}%>
		<tr>
			<td height="23">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<%
					//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
					strTemp = new ConversionTable().convertAmoutToFigure(dTotal, "", "");
					if(dTotal%1 == 0)
						strTemp = strTemp.substring(0, strTemp.length()-10);
					strTemp += ((String)vDCInfo.elementAt(9)).toUpperCase();					
					if(!((String)vDCInfo.elementAt(9)).toUpperCase().equals("YEN"))
						strTemp += "S";						
					strTemp += " ONLY";
					
					//strTemp.toUpperCase()
				%>
				<%=strTemp.toUpperCase()%></td>
	  	  <td align="right"><%=(String)vDCInfo.elementAt(10)%><%=CommonUtil.formatFloat(dTotal, true)%>&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="60" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="23" width="35%">&nbsp;&nbsp;Maritsuo Fuse</td>
		    <td width="35%">&nbsp;&nbsp;Rachel Nufable</td>
		    <td width="30%">&nbsp;&nbsp;Segismundo Exaltacion Jr.</td>
		</tr>
	</table>
	<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>