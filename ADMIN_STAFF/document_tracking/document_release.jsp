<%@ page language="java" import="utility.*, docTracking.deped.DocReceiveRelease, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolForwarded = WI.fillTextValue("is_forwarded").equals("1");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Document Releasing</title></head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">

	function FocusField(){
		document.form_.barcode_id.focus();
	}
	
	function SearchBarcode(strKeyCode){
		if(strKeyCode == '13'){
			document.form_.release_document.value = "";
			document.form_.submit();	
		}
	}
	
	function releaseDocument(){
		if(!confirm("Continue with document release?"))
			return;
		document.form_.release_document.value = "1";
		document.form_.submit();
	}
	
	function ViewReleaseInfo(strInfoIndex){
		var sT = "./view_release_info.jsp?transaction_index="+strInfoIndex;
		var win=window.open(sT,"ViewReleaseInfo",'dependent=yes,width=700,height=400,top=200,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function GoBack(){
		location = "./unreleased_documents.jsp";
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here..
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"DOCUMENT TRACKING","document_release.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("DOCUMENT TRACKING-RECEIVE RELEASE"),"0"));
	
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
	
	Vector vInfo = null;
	boolean bolIsComplete = false;
	boolean bolIsReleased = false;
	String strInfoIndex = null;
	DocReceiveRelease drr = new DocReceiveRelease();
	
	if(WI.fillTextValue("barcode_id").length() > 0){
		vInfo = drr.getTransactionInformation(dbOP, request);
		if(vInfo == null)
			strErrMsg = drr.getErrMsg();
		else{
			strInfoIndex = (String)vInfo.elementAt(0);
			bolIsComplete = ((String)vInfo.elementAt(14)).equals("1");
			bolIsReleased = ((String)vInfo.elementAt(15)).equals("1");
			
			if(!bolIsComplete){
				strErrMsg = "Processing of this document is not yet complete.";
				vInfo = null;
			}
		}
	}
	
	if(vInfo != null){
		if(bolIsReleased){
			vInfo = null;
			strErrMsg = "Document already released.";
		}
	}
	
	if(vInfo != null){
		if(WI.fillTextValue("release_document").length() > 0){
			if(!drr.finalizeDocumentReleasing(dbOP, request, (String)vInfo.elementAt(0)))
				strErrMsg = drr.getErrMsg();
			else{
				vInfo = null;
				strErrMsg = "Document successfully released.";//show released button
				bolIsReleased = true;
			}
		}
	}
%>
<body bgcolor="#D2AE72" onload="FocusField();">
<form name="form_" action="document_release.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="4" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: RELEASE DOCUMENT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
			<td width="10%" align="right">
				<%if(bolForwarded){%>
					<a href="javascript:GoBack();"><img src="../../images/go_back.gif" border="0" /></a>
				<%}%></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Barcode ID: </td>
			<td colspan="2">
				<%if(!bolForwarded){%>
					<input type="text" name="barcode_id" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
						onblur="style.backgroundColor='white'" size="32" maxlength="32" value="<%=WI.fillTextValue("barcode_id")%>"
						onkeyup="javascript:SearchBarcode(event.keyCode);"/>
				<%}else{%>
					<input type="hidden" name="barcode_id" value="<%=WI.fillTextValue("barcode_id")%>" />
					<strong><font size="3" color="#FF0000"><%=WI.fillTextValue("barcode_id")%></font></strong>
				<%}%></td>
		</tr>
	<%if(!bolForwarded){%>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="2">
				<a href="javascript:SearchBarcode('13');"><img src="../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click here to search barcode.</font></td>
		</tr>
	<%}if(bolIsReleased){%>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="2"><a href="javascript:ViewReleaseInfo('<%=strInfoIndex%>')"><img src="../../images/view.gif" border="0" /></a>
				<font size="1">Click to view document release information.</font></td>
		</tr>
	<%}%>
	</table>

<%if(vInfo != null && vInfo.size() > 0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="15" colspan="3"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Origin/Owner:</td>
			<td width="80%"><%=(String)vInfo.elementAt(1)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Transaction Date: </td>
			<td><%=(String)vInfo.elementAt(16)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Document Name: </td>
			<td rowspan="2" valign="top"><%=(String)vInfo.elementAt(4)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		
		<tr>
			<td height="15" colspan="3"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Notes:</td>
			<td>
				<textarea name="note" style="font-size:12px" cols="60" rows="2" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("note")%></textarea></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Released To: </td>
			<td>
				<input type="text" name="released_to" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="64" maxlength="128" value="<%=WI.fillTextValue("released_to")%>"/></td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
			<td>
				<a href="javascript:releaseDocument();"><img src="../../images/save.gif" border="0" /></a>
				<font size="1">Click to release this document.</font></td>
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
	
	<input type="hidden" name="release_document" />
	<input type="hidden" name="is_forwarded" value="<%=WI.fillTextValue("is_forwarded")%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>