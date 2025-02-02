<%@ page language="java" import="utility.*, Accounting.SalesPayment, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<title>OR Print</title>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body onload="window.print();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	double dTemp = 0d;
	if(WI.fillTextValue("or_number").length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Payment reference is missing. </p>
		<%return;
	}
	
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
								"ACCOUNTING-BILLING","OR_print.jsp");
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
	
	SalesPayment sp = new SalesPayment();
	Vector vParticulars = null;
	Vector vRetResult = sp.getPaymentInfo(dbOP, request);
	
	if(vRetResult != null){
		vParticulars = (Vector)vRetResult.elementAt(12);
%>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="100" width="77%">&nbsp;</td>
			<!--OR Number-->
			<td width="23%" valign="bottom" align="center"><font size="+1"><%=(String)vRetResult.elementAt(3)%></font></td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" width="12%">&nbsp;</td>
			<td width="66%" align="center"><%=(String)vRetResult.elementAt(1)%></td><!--received from-->
			<td width="22%" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(9), "&nbsp;")%></td><!--tin-->
		</tr>
	</table>
	<%
		strTemp = (String)vRetResult.elementAt(2);//amount
		dTemp = Double.parseDouble(strTemp);
		strErrMsg = new ConversionTable().convertAmoutToFigure(dTemp, "", "");
		if(dTemp%1 == 0)
			strErrMsg = strErrMsg.substring(0, strErrMsg.length() - 10);
	%>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" width="10%">&nbsp;</td>
			<td width="90%"><%=strErrMsg.toUpperCase()%></td><!--amount in words-->
		</tr>
	</table>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" width="10%">&nbsp;</td>
			<%
				strTemp = ((String)vRetResult.elementAt(10)).toUpperCase();
				if(!strTemp.equals("YEN"))
					strTemp += "S";
				strTemp += " ONLY";
			%>
			<td width="65%"><%=strTemp%></td>
			<td width="25%" align="center">
				<%if(((String)vRetResult.elementAt(13)).equals("0")){//if not local, show the currency%>
					<%=(String)vRetResult.elementAt(11)%>
				<%}%>
				<%=CommonUtil.formatFloat((String)vRetResult.elementAt(2), true)%></td>
		</tr>
	</table>
	<%
		strTemp = "";
		if(vParticulars != null){
			for(int i = 0; i < vParticulars.size(); i+=2){
				if(strTemp.length() == 0)
					strTemp = (String)vParticulars.elementAt(i);
				else
					strTemp += ", "+(String)vParticulars.elementAt(i);
			}
		}
		else
			strTemp = (String)vRetResult.elementAt(5);//particular of other payment
	%>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" width="18%">&nbsp;</td>
			<td width="82%" rowspan="2" valign="top"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
	    </tr>
	</table>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="30" width="75%">&nbsp;</td>
			<td width="25%" align="center"><%=WI.formatDate((String)vRetResult.elementAt(4), 6)%></td>
		</tr>
	</table>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>		
			<td height="50" width="65%" valign="top">
			<%if(vParticulars != null){%>
				<div><table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
					<%for(int i = 0; i < vParticulars.size(); i += 2){%>
					<tr>
						<td height="15" width="70%"><%=(String)vParticulars.elementAt(i)%></td>
						<td width="30%" align="right"><%=(String)vRetResult.elementAt(11)%><%=(String)vParticulars.elementAt(i+1)%>&nbsp;</td>
					</tr>
					<%}%>
				</table></div>
			<%}else{%>
				<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td height="15" width="70%"><%=(String)vRetResult.elementAt(5)%></td>
						<td width="30%" align="right"><%=(String)vRetResult.elementAt(11)%><%=(String)vRetResult.elementAt(2)%>&nbsp;</td>
					</tr>
				</table>
			<%}%></td>
			<td width="10%">&nbsp;</td>
			<td width="25%" align="center" valign="top"><br>R.V. CABALLERO</td>
		</tr>
	</table>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" width="13%">CASH IN BANK</td>
			<td width="52%" align="right">
				<%=(String)vRetResult.elementAt(11)%>
				<%=CommonUtil.formatFloat((String)vRetResult.elementAt(2), true)%>&nbsp;</td>
			<td width="35%">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="43">&nbsp;</td>
			<td>&nbsp;</td>
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr>			
			<%
				Vector vTemp = (Vector)vRetResult.elementAt(6);
				strTemp = "";
				for(int i = 0; i < vTemp.size(); i++){
					if(strTemp.length() > 0)
						strTemp += "<br>"+(String)vTemp.elementAt(i);
					else
						strTemp = (String)vTemp.elementAt(i);
				}
			%>
			<td height="50" width="13%" align="center"><%=strTemp%></td>
			<%
				vTemp = (Vector)vRetResult.elementAt(7);
				strTemp = "";
				for(int i = 0; i < vTemp.size(); i++){
					if(strTemp.length() > 0)
						strTemp += "<br>"+(String)vTemp.elementAt(i);
					else
						strTemp = (String)vTemp.elementAt(i);
				}
			%>	
			<td width="13%" align="center"><%=strTemp%></td>
			<%
				vTemp = (Vector)vRetResult.elementAt(8);
				strTemp = "";
				for(int i = 0; i < vTemp.size(); i++){
					if(strTemp.length() > 0)
						strTemp += "<br>"+(String)vTemp.elementAt(i);
					else
						strTemp = (String)vTemp.elementAt(i);
				}
			%>	
			<td width="48%"><%=strTemp%></td>
			<td width="26%"><%=(String)vRetResult.elementAt(11)%><%=CommonUtil.formatFloat((String)vRetResult.elementAt(2), true)%></td>
		</tr>
	</table>
	
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>