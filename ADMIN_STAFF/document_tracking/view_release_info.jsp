<%@ page language="java" import="utility.*,docTracking.deped.DocReceiveRelease,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	String strTransactionIndex = WI.fillTextValue("transaction_index");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Performance Evaluation</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>

<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../jscript/td.js"></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if(strTransactionIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Reference index is missing. Please try again.</p>
		<%return;
	}
	
	//add security here..
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"DOCUMENT TRACKING","view_release_info.jsp");
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
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("DOCUMENT TRACKING-REPORTS"),"0"));
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("DOCUMENT TRACKING"),"0"));
		if(iAccessLevel == 0){
			response.sendRedirect("../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	DocReceiveRelease drr = new DocReceiveRelease();
	Vector vRetResult = drr.getDocReleaseInfo(dbOP, request, strTransactionIndex);
	if(vRetResult == null)
		strErrMsg = drr.getErrMsg();
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" action="./view_release_info.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A" class="footerDynamic">
			<td height="25" colspan="3" bgcolor="#A49A6A" align="center" class="footerDynamic">
			<font color="#FFFFFF" ><strong>:::: DOCUMENT RELEASE INFORMATION ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Released by: </td>
			<td width="77%"><%=(String)vRetResult.elementAt(0)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Released to: </td>
		    <td><%=(String)vRetResult.elementAt(1)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Release Date/Time:</td>
		    <td><%=(String)vRetResult.elementAt(3)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Release Notes: </td>
		    <td rowspan="2" valign="top"><%=WI.getStrValue((String)vRetResult.elementAt(4))%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>&nbsp;</td>
	    </tr>
	<%}%>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A" class="footerDynamic"> 
			<td height="25">&nbsp;</td>
		</tr>
	</table>

	<input type="hidden" name="transaction_index" value="<%=strTransactionIndex%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>