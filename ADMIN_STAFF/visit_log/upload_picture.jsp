<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Upload Picture</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<%@ page language="java" import="utility.*,visitor.FileOperations" %>
<%
	WebInterface WI  = new WebInterface(request);
%>
<script language="javascript" src="../jscript/common.js"></script>
<script language="javascript">
	var imgWnd;
	var stopReload = '0';
	
	function ShowUploadingDoc(){
		var docURL = document.form_.myfile.value;
		if(docURL.length == 0){
			alert("Please select a file to upload.");
			return false;
		}
		document.all.processing.style.visibility = "visible";
	
		return true;
	}
	
	function CloseUploadingImg(){
		if (imgWnd && imgWnd.open && !imgWnd.closed) 
			imgWnd.close();
		
		if(!document.form_ && stopReload == '0') {
			stopReload = '1';
			return;
		}
		
		if(stopReload == '1' || !document.form_ || document.form_.donot_call_close_wnd.value == '1')
			return;
		
		this.CloseWindow();
	}
	
	function CloseWindow(){
		stopReload = '1';
		window.opener.ReloadPage();
		window.close();
	}

</script>
<body onUnload="CloseUploadingImg();">
<%
	DBOperation dbOP = null;
	String strVisitorIndex = WI.fillTextValue("visitor_index");

	String strErrMsg = null;
	String strTemp   = null;
	boolean bolIsUploadSuccess = false;

	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Admin/staff-Visit Log","upload_picture.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	//String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	//if(strAuthTypeIndex.equals("3")){
	//	dbOP.cleanUP();
	//	response.sendRedirect("../commfile/unauthorized_page.jsp");
	//	return;
	//}
	
	if(strVisitorIndex.length() > 0)//first time called.
	{
		request.getSession(false).removeAttribute("visitor_index");
		request.getSession(false).setAttribute("visitor_index",WI.fillTextValue("visitor_index"));
	}	
	else
	{
		FileOperations fileOp = new FileOperations();
		if(fileOp.uploadIDcardImage(dbOP, request)){
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
	<a href="javascript:CloseWindow();"><img src="../../images/close_window.gif" border="0"></a>
<%}else if(strErrMsg != null && !bolIsUploadSuccess){%>
	<%=strErrMsg%>
	<br>Click to go back to try again uploading the file.
	<a href="javascript:history.back();" ><img src="../../images/go_back.gif" border="0"></a>
<%}else{%>
	<form action="./upload_picture.jsp" method="post" enctype="multipart/form-data" name="form_" onSubmit="return ShowUploadingDoc();">
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
			
			<img src="../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div>

</body>
</html>
<%
dbOP.cleanUP();
%>