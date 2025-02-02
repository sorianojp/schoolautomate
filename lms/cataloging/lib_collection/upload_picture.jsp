<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Upload Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<%@ page language="java" import="utility.*,inventory.UploadItemImage" %>
<%
	WebInterface WI  = new WebInterface(request);
	

%>
<script language="javascript" src="../../../jscript/common.js"></script>
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
		document.form_.uploaded_file.value = docURL;
		
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
	String strItemIndex = WI.fillTextValue("image_name");

	String strErrMsg = null;
	String strTemp   = null;
	boolean bolIsUploadSuccess = false;

	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Admin/staff-Seminar","upload_picture.jsp");
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
	//	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	//	return;
	//}
	
	if(strItemIndex.length() > 0)//first time called.
	{
		request.getSession(false).removeAttribute("image_name");
		request.getSession(false).setAttribute("image_name",WI.fillTextValue("image_name"));
		
		request.getSession(false).removeAttribute("info_index_image");
		request.getSession(false).setAttribute("info_index_image",WI.fillTextValue("info_index_image"));		
		
	}	
	else
	{
		 UploadItemImage fileOp = new  UploadItemImage();
		 
		 String strPath = fileOp.uploadGenericFile(request, "lms/images/", true);
		 
		if(strPath != null){
		
			strErrMsg ="Upload Successful.";
			bolIsUploadSuccess = true;
			
			char pathSeparator = '/';
			
		   	int sep = strPath.lastIndexOf(pathSeparator);
		   

			strTemp = "update lms_mat_type set icon_name = '"+strPath.substring(sep + 1)+"' where material_type_index="+
				(String)request.getSession(false).getAttribute("info_index_image");
			dbOP.executeUpdateWithTrans(strTemp, null, null, false);
		}
		else
			strErrMsg = "Upload failed : Reason - "+fileOp.getErrMsg();			
	}

	dbOP.cleanUP();

%>

<form action="./upload_picture.jsp" method="post" enctype="multipart/form-data" name="form_" onSubmit="return ShowUploadingDoc();">

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
	
	<%if (strErrMsg != null){%>
		<%=strErrMsg%>
	<%}%>
	
	<input type="file" name="myfile" size="80" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  <br><br>
	<input type="submit" name="upload_file" value="Upload File >>">
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>">
	<input type="hidden" name="donot_call_close_wnd" value="1">  	
	
<%}%>
<input type="hidden" name="info_index_image" value="<%=WI.fillTextValue("info_index_image")%>" >
<input type="hidden" name="uploaded_file" value="<%=WI.fillTextValue("uploaded_file")%>" >
</form>
<div id="processing" style="width:400px; height:115px;  visibility:hidden;">
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