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
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
<title>Pending Documents</title>
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">

	function ReleaseDocument(strBarcodeID){
		location = "document_release.jsp?is_forwarded=1&barcode_id="+strBarcodeID;
	}
	
	function viewTracking(strBarcodeID){
		location = "document_tracking.jsp?is_forwarded=1&barcode_id="+strBarcodeID;
	}

</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here..
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"DOCUMENT TRACKING","pending_documents.jsp");
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
	
	int iUnreleasedDocuments = 0;	
	DocumentTracking dt = new DocumentTracking();
	Vector vRetResult = dt.getUnreleasedDocuments(dbOP, request);
	if(vRetResult == null)
		strErrMsg = dt.getErrMsg();
	else
		iUnreleasedDocuments = vRetResult.size()/20;

	boolean bolIsAuthRestricted = dt.bolIsUserRestricted(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
%>
<body bgcolor="#D2AE72">
<form name="form_" action="pending_documents.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: UNRELEASED DOCUMENT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		  	<td width="47%">Unreleased Documents: <strong><%=iUnreleasedDocuments%></strong></td>
		    <td style="font-size:14px; font-weight:bold; color:#FF0000;">
			<%if(bolIsAuthRestricted) {%>
			    Authentication is Restricted
			<%}%>
			</td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		  	<td colspan="2">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="7" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF UNRELEASED TRANSACTION(S) IN RECORD ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="22%" align="center" class="thinborder"><strong>Origin/Owner</strong></td>
			<td width="16%" align="center" class="thinborder"><strong>Category</strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Barcode ID</strong></td>
			<td width="19%" align="center" class="thinborder"><strong>Responsible Personnel </strong></td>
			<td width="19%" align="center" class="thinborder"><strong>Transaction Date</strong></td>
			<td width="10%" align="center" class="thinborder">&nbsp;</td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 20){%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+13)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+16)%></td>
			<td class="thinborder" align="center">
				<a href="javascript:ReleaseDocument('<%=(String)vRetResult.elementAt(i+5)%>');" style="text-decoration:none">Release</a></td>
		</tr>
	<%}%>
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
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>