<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Upload Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<%@ page language="java" import="utility.*, hr.HRDownloadMgmt"%>
<%
	WebInterface WI  = new WebInterface(request);
%>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
var imgWnd;
var stopReload = '0';
function ShowUploadingDoc()
{
	var docURL = document.form_.myfile.value;
	if(docURL.length == 0)
	{
		alert("Please select a file to upload.");
		return false;
	}
	document.all.processing.style.visibility = "visible";

	return true;
}
function CloseUploadingImg()
{
	if (imgWnd && imgWnd.open && !imgWnd.closed)
		imgWnd.close();
	
	if(!document.form_ && stopReload == '0') {
		stopReload = '1';
		return;
	}
	
	if(document.form_ && document.form_.donot_call_close_wnd.value == '1'){
		return;
	}
	
	if(stopReload == '1' || !document.form_){
		return;
	}
	
	this.CloseWindow();
}

function CloseWindow()
{
	stopReload = '1';
	window.opener.CancelRecord();
	window.close();
}

</script>
<body onUnload="CloseUploadingImg();">
<%
	DBOperation dbOP = null;
	String strLinkIndex = WI.fillTextValue("link_index");

	String strErrMsg = null;
	String strTemp   = null;
	boolean bolIsUploadSuccess = false;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-PERSONNEL"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
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
			"Admin/staff-HR Management-Personnel-Link Management","upload_document.jsp");
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
	
	if(strLinkIndex.length() > 0)//first time called.
	{
		request.getSession(false).removeAttribute("link_index");
		request.getSession(false).removeAttribute("file_name");
		request.getSession(false).setAttribute("link_index",WI.fillTextValue("link_index"));
		request.getSession(false).setAttribute("file_name",WI.fillTextValue("file_name"));
	}	
	else
	{
		HRDownloadMgmt fileOp = new HRDownloadMgmt();
		if(fileOp.uploadDocument(dbOP, request)){
			strErrMsg ="Upload Successful.";
			bolIsUploadSuccess = true;
		}
		else
			strErrMsg = "Upload failed : Reason - "+fileOp.getErrMsg();
	}

	dbOP.cleanUP();

%>
<%
if(strErrMsg != null && bolIsUploadSuccess) {//upload is success%>
	<%=strErrMsg%>
	<br>Click close window to go back to parent window.
	<a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" border="0"></a>
<%}else if(strErrMsg != null && !bolIsUploadSuccess){%>
	<%=strErrMsg%>
	<br>Click to go back to try again uploading the file.
	<a href="javascript:history.back();" ><img src="../../../images/go_back.gif" border="0"></a>
<%}else{%>
	<form action="./upload_document.jsp" method="post" enctype="multipart/form-data" name="form_" onSubmit="return ShowUploadingDoc();">
	<%if (strErrMsg != null){%>
		<%=strErrMsg%>
	<%}%>
	
	<input type="file" name="myfile" size="80" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  <br><br>
	<input type="submit" name="upload_file" value="Upload File >>">
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>"> 
	
	<input type="hidden" name="donot_call_close_wnd" value="1">
	</form>
<%}%>

<div id="processing" style="width:400px; height:115px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div>

</body>
</html>
<%
dbOP.cleanUP();
%>