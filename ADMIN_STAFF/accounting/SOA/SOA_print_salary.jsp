<%@ page language="java" import="utility.*,Accounting.SOAManagement,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Statement of Account</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body leftmargin="50px" topmargin="0px" onLoad="window.print();">
<script language="javascript" src="../../../jscript/common.js"></script>
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BUDGET"),"0"));
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
								"ACCOUNTING-BUDGET","SOA_print_salary.jsp");
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
	
	double dTemp = 0d;
	String strSANum = WI.fillTextValue("sa_num");
	
	if(strSANum.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">SOA reference is missing. 
		Please close this window and click the link again from main window.</p>
		<%return;
	}
	
	SOAManagement soa = new SOAManagement();
	Vector vSOAInfo = soa.getSOAInformation(dbOP, request);
	Vector vSOADetails = soa.getSOADetails(dbOP, request);
	if(vSOAInfo != null){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" align="center"><font size="+1">TSUNEISHI TECHNICAL SERVICES (PHILS.) INC.</font></td>
		</tr>
		<tr>
			<td height="20" align="center">West Cebu Industrial Park Special Economic Zone</td>
		</tr>
		<tr>
			<td height="20" align="center">Buanoy Balamban 6041, Cebu Philippines</td>
		</tr>
		<tr>
			<td height="25" align="center">Tel. No. (32)230-847&nbsp;&nbsp;&nbsp;Fax No. (32)333-2513</td>
		</tr>
		<tr>
			<td height="20" align="center">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" align="center" valign="bottom"><font size="2"><strong><u>STATEMENT OF ACCOUNT</u></strong></font></td>
		</tr>
		<tr>
			<td height="20" align="center">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" width="4%">TO: </td>
			<td width="45%">TSUNEISHI HOLDINGS CORPORATION</td>
			<td width="31%">&nbsp;</td>
			<td width="20%"><%=WI.formatDate((String)vSOAInfo.elementAt(2), 6)%></td>			
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td><%=(String)vSOAInfo.elementAt(13)%></td>
			<td>&nbsp;</td>
			<td>S/A no. <%=(String)vSOAInfo.elementAt(1)%></td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td rowspan="3" valign="top"><div><%=(String)vSOAInfo.elementAt(14)%></div></td>
		    <td colspan="2" rowspan="3">&nbsp;</td>
	    </tr>
		<tr>
			<td height="20">&nbsp;</td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" width="10%">ATTENTION: </td>
			<td width="90%"><%=(String)vSOAInfo.elementAt(8)%></td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td><%=(String)vSOAInfo.elementAt(9)%></td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td><%=WI.getStrValue((String)vSOAInfo.elementAt(30))%></td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" colspan="2">Dear Sir, </td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<%
			strTemp = (String)vSOAInfo.elementAt(16);//amount
			dTemp = Double.parseDouble(strTemp);
			strErrMsg = new ConversionTable().convertAmoutToFigure(dTemp, "", "");
			if(dTemp%1 == 0)
				strErrMsg = strErrMsg.substring(0, strErrMsg.length() - 10);
			strErrMsg += ((String)vSOAInfo.elementAt(26)).toUpperCase();	
			if(!((String)vSOAInfo.elementAt(26)).toUpperCase().equals("YEN"))
				strErrMsg += "S";
			strErrMsg += " ONLY";
		%>
		<tr>
			<td colspan="2"><p>
			Kindly deduct <b><u><%=strErrMsg.toUpperCase()%> (<%=(String)vSOAInfo.elementAt(18)%><%=CommonUtil.formatFloat(strTemp, false)%>)</u></b> 
			from the monthly salary in Japan (<u>for the month of <%=WI.formatDate((String)vSOAInfo.elementAt(2), 11)%></u>) 
			of the following employees who are currently on an intra-company transfer.
			</p></td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
	</table>
	
<%if(vSOADetails != null && vSOADetails.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<%	int iCount = 1;
		for(int i = 0; i < vSOADetails.size(); i += 7, iCount++){%>
		<tr>
			<td height="20" width="50%"><%=iCount%>. <%=(String)vSOADetails.elementAt(i+2)%></td>
			<td width="50%"><%=(String)vSOADetails.elementAt(i+6)%><%=CommonUtil.formatFloat((String)vSOADetails.elementAt(i+3), false)%></td>
		</tr>
	<%}%>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" align="center"><strong>Total</strong></td>
			<td><strong><%=(String)vSOAInfo.elementAt(18)%><%=CommonUtil.formatFloat(strTemp, false)%></strong></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		</tr>
	</table>
<%}%>

	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<%			
				strTemp = (String)vSOAInfo.elementAt(16);//amount
				dTemp = Double.parseDouble(strTemp);
				strErrMsg = new ConversionTable().convertAmoutToFigure(dTemp, "", "");
				if(dTemp%1 == 0)
					strErrMsg = strErrMsg.substring(0, strErrMsg.length() - 10);				
				strErrMsg += ((String)vSOAInfo.elementAt(26)).toUpperCase();	
				if(!((String)vSOAInfo.elementAt(26)).toUpperCase().equals("YEN"))
					strErrMsg += "S";
				strErrMsg += " ONLY";
			%>
			<td colspan="3"><p>The amount (off-set) deducted shall be used to defray the above employees local salary 
				in the Philippines. Please remit total amount <u><strong><%=strErrMsg.toUpperCase()%></strong></u> 
				to our yen account:</p></td>
		</tr>
		<tr>
			<td height="20" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" width="15%">&nbsp;</td>
		    <td width="20%">ACCOUNT NAME:</td>
		    <td width="65%"><%=(String)vSOAInfo.elementAt(11)%></td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
		    <td>ACCOUNT NO.: </td>
		    <td><%=(String)vSOAInfo.elementAt(12)%></td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
		    <td>BANK:</td>
		    <td><%=(String)vSOAInfo.elementAt(27)%> - <%=(String)vSOAInfo.elementAt(28)%></td>
		</tr>
		<tr>
			<td height="20" colspan="2">&nbsp;</td>
		    <td><%=(String)vSOAInfo.elementAt(29)%></td>
		</tr>
		<tr>
			<td height="20" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" colspan="2">Prepared by: </td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" colspan="2">Rebellita V. Caballero </td>
		</tr>
		<tr>
			<td height="20" colspan="2">Asst. Mgt. Staff</td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" width="55%">Noted by: </td>
		    <td width="45%">Approved by: </td>
		</tr>
		<tr>
		 	<td height="15">&nbsp;</td>
		  	<td>&nbsp;</td>
	  	</tr>
		<tr>
		  	<td height="20">Rachel O. Nufable </td>
		  	<td>Segismundo F. Exaltacion Jr. </td>
	 	 </tr>
		<tr>
		  <td height="20">Assistant Supervisor </td>
		  <td>General Manager </td>
	  </tr>
	</table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>