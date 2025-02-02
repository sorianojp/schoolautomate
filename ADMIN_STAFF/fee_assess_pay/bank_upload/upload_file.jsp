<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Upload Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<%@ page language="java" import="utility.*,utility.BankUpload" %>
<%
	WebInterface WI  = new WebInterface(request);
%>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
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
	
	if(stopReload == '1' || !document.form_ || document.form_.donot_call_close_wnd.value == '1'){
		return;
	}
	
	this.CloseWindow();
}

function CloseWindow()
{
	stopReload = '1';
	window.opener.ReloadPage();
	window.close();
}

</script>
<body onUnload="CloseUploadingImg();">
<%
	DBOperation dbOP = null;
	String strFirstLoad = WI.fillTextValue("first_load");
	
	String strErrMsg = null;
	String strTemp   = null;
	boolean bolIsUploadSuccess = false;

	//add security here.
	try{
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	
	if(strFirstLoad.length() > 0)//first time called.
	{
		request.getSession(false).removeAttribute("first_load");
		request.getSession(false).removeAttribute("sy_from");
		request.getSession(false).removeAttribute("semester");	
		request.getSession(false).removeAttribute("bank_code");
		request.getSession(false).removeAttribute("file_ext");
		request.getSession(false).removeAttribute("bank_index");
		request.getSession(false).removeAttribute("pmt_sch_index");
		request.getSession(false).removeAttribute("date_receipt");
		request.getSession(false).setAttribute("first_load",WI.fillTextValue("first_load"));	
		request.getSession(false).setAttribute("sy_from",WI.fillTextValue("sy_from"));		
		request.getSession(false).setAttribute("semester",WI.fillTextValue("semester"));
		request.getSession(false).setAttribute("bank_code",WI.fillTextValue("bank_code"));		
		request.getSession(false).setAttribute("file_ext",WI.fillTextValue("file_ext"));
		request.getSession(false).setAttribute("bank_index",WI.fillTextValue("bank_index"));
		request.getSession(false).setAttribute("pmt_sch_index",WI.fillTextValue("pmt_sch_index"));
		request.getSession(false).setAttribute("date_receipt",WI.fillTextValue("date_receipt"));
	}	
	else
	{
		BankUpload bum = new BankUpload();
		if(bum.uploadFileToParse(dbOP, request)){
			strErrMsg = "Upload Successful.";
			//strErrMsg = bum.getErrMsg();
			bolIsUploadSuccess = true;
		}
		else
			strErrMsg = "Upload failed : Reason - "+bum.getErrMsg();
			
		//System.out.println(strErrMsg);
		//System.out.println(bolIsUploadSuccess);
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
	<form action="./upload_file.jsp" method="post" enctype="multipart/form-data" name="form_" onSubmit="return ShowUploadingDoc();">
	<%if (strErrMsg != null){%>
		<%=strErrMsg%>
	<%}%>
	
	<input type="file" name="myfile" size="80" class="textbox" value="C:\\Borland\\JBuilder2005"
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
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
				<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> 
					Processing Request. Please wait ...... </p>
				<img src="../../../Ajax/ajax-loader_big_black.gif"></td>
		</tr>
	</table>
</div>
		
</body>
</html>
<%
	dbOP.cleanUP();
%>