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
<title>Receive Document</title></head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">

	function FocusField(){
		document.form_.barcode_id.focus();
	}
	
	function SearchBarcode(strKeyCode){
		if(strKeyCode == '13'){
			document.form_.page_action.value = "";
			document.form_.submit();	
		}
	}
	
	function receiveTransaction(strConfirmation){
		if(!confirm("Are you sure you want to open this document and return to last depatment processed this document?"))
			return;
			
		document.form_.page_action.value = "1";
		document.form_.submit();
	}
	
</script>
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

	//add security here..
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"DOCUMENT TRACKING","open_completed_doc.jsp");
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
	Vector vRetResult = null;
	DocReceiveRelease drr = new DocReceiveRelease();
	if(WI.fillTextValue("barcode_id").length() > 0) {
	
		if(WI.fillTextValue("page_action").length() > 0) {
			if(drr.operateOnOpenCompletedDoc(dbOP, request, 1) == null)
				strErrMsg = drr.getErrMsg();
			else	
				strErrMsg = "Document opened and returned to corresponding dept.";
		}
		
		vRetResult = drr.operateOnOpenCompletedDoc(dbOP, request, 4);
		if(vRetResult == null && strErrMsg == null) { 
			strErrMsg = drr.getErrMsg();
		}
	}
	

%>
<body bgcolor="#D2AE72" onload="FocusField();">
<form name="form_" action="open_completed_doc.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: RE-OPEN A CLOSED DOCUMENT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td colspan="2" style="font-size:9px; font-weight:bold; color:#0000FF">Note: Only Completed Documents are accessible. If document is released, it can't be re-opened. After document is re-opened, last office/dept will have to receive it again. </td>
	  </tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Barcode ID: </td>
			<td width="80%">
				<input type="text" name="barcode_id" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="32" maxlength="32" value="<%=WI.fillTextValue("barcode_id")%>"
					onkeyup="javascript:SearchBarcode(event.keyCode);"/></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<a href="javascript:SearchBarcode('13');"><img src="../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click here to search barcode.</font>				</td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="15" colspan="3"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Return to Department: </td>
			<td width="80%"><%=(String)vRetResult.elementAt(0)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Reason for Re-Open </td>
		  	<td>
				<textarea name="reason" style="font-size:12px" cols="60" rows="2" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("reason")%></textarea></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;</td>
			<td><a href="javascript:receiveTransaction('1');"><img src="../../images/save.gif" border="0" /></a>
				<font size="1">Click to acknowledge receiving of this document.</font></td>
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
	
	<input type="hidden" name="page_action" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>