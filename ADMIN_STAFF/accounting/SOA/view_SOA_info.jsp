<%@ page language="java" import="utility.*,Accounting.SOAManagement,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Sales Payment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	
	if(WI.fillTextValue("sa_num").length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">
		SOA reference is missing.. Please close this window and click update view link again from payment window.</p>
		<%return;
	}

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
								"ACCOUNTING-BUDGET","view_SOA_info.jsp");
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
	
	Vector vSOAInfo = null;
	SOAManagement soa = new SOAManagement();

	vSOAInfo = soa.getSOAInformation(dbOP, request);
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./view_SOA_info.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="4" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: SOA INFORMATION ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>

<%if(vSOAInfo != null && vSOAInfo.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td width="17%">S/A Number: </td>
		    <td><%=(String)vSOAInfo.elementAt(1)%></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Type:</td>
		    <td><%=(String)vSOAInfo.elementAt(4)%></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Category: </td>
			<td><%=(String)vSOAInfo.elementAt(25)%> (<%=(String)vSOAInfo.elementAt(24)%>)</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Activity: </td>
			<td><%=(String)vSOAInfo.elementAt(22)%> (<%=(String)vSOAInfo.elementAt(21)%>)</td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Date:</td>
		  	<td><%=(String)vSOAInfo.elementAt(2)%></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Currency:</td>
		  	<td><%=(String)vSOAInfo.elementAt(26)%> (<%=(String)vSOAInfo.elementAt(18)%>)</td>
	 	</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Charge To: </td>
		    <td><%=(String)vSOAInfo.elementAt(13)%></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Address:</td>
		    <td><%=(String)vSOAInfo.elementAt(14)%></td>
        </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Attention:</td>
		    <td><%=(String)vSOAInfo.elementAt(8)%></td>
        </tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Position:</td>
		  	<td><%=(String)vSOAInfo.elementAt(9)%><%=WI.getStrValue((String)vSOAInfo.elementAt(30), " (", ")", "")%></td>
	  	</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Account Name: </td>
		    <td><%=(String)vSOAInfo.elementAt(11)%></td>
        </tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Account No.: </td>
		  	<td><%=(String)vSOAInfo.elementAt(12)%></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Bank: </td>
		  	<td><%=(String)vSOAInfo.elementAt(27)%> - <%=(String)vSOAInfo.elementAt(28)%></td>
	  	</tr>
		<tr>
		  	<td height="25" colspan="2">&nbsp;</td>
		  	<td><%=(String)vSOAInfo.elementAt(29)%></td>
	  	</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Amount:	</td>
		    <td>
				<%
					strTemp = CommonUtil.formatFloat((String)vSOAInfo.elementAt(16), false);
					strErrMsg = ConversionTable.replaceString(strTemp, ",", "");
				%>
				<%=(String)vSOAInfo.elementAt(18)%><%=strTemp%></td>
	    </tr>
	</table>
<%}%>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
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