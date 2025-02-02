<html>
<head>
<title>File Upload page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>

<script language="JavaScript">
var imgWnd;
function ShowUploadingImg()
{
	//check if the image is having correct extension for uploading the image and also image name is entered to upload.
	var imgURL = document.myForm.myfile.value;
	var myNewString = new String(imgURL);
	
	if(myNewString.length ==0)
	{
		alert("Please enter  a file name with extension ."+document.myForm.img_ext.value+" to upload");
		return false;
	}
	myNewString = myNewString.toLowerCase();
	if(myNewString.indexOf("."+document.myForm.img_ext.value) == -1)
	{
		alert("Please enter  a file name with extension ."+document.myForm.img_ext.value+" to upload");
		return false;
	}
	
	
	var sT = "./uploading_image.htm";
	imgWnd=window.open(sT,"showGif",'dependent=yes,resizable=no,width=400,height=160,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
	imgWnd.focus();
	return true;
}
function CloseUploadingImg()
{
	if (imgWnd && imgWnd.open && !imgWnd.closed) imgWnd.close();
}

function CloseWindow()
{
	//var strImageSrc = "../../../../upload_img/"+window.opener.document.form_.stud_id.value+"."+window.opener.document.form_.img_ext.value;
	//window.opener.document.stud_image.src=strImageSrc;
	window.opener.document.form_.submit();
	window.close();
}
</script>
<body onUnload="CloseUploadingImg();">
<%@ page language="java" import="utility.*,enrollment.UploadFile" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strImgFileExt = WI.fillTextValue("img_ext"); // this makes sure i am using same file extension as i am using in property files. 
	String strErrMsg = null;
	boolean bolIsUploadSuccess = false;
	String strUID    = WI.fillTextValue("stud_id");//check if id entered exists in DB.
	boolean bolFatalErr = false;
	
	boolean bolIsTempStud = true;
	
	if(strUID.length() == 0 && WI.fillTextValue("temp_id").length() > 0)
		bolIsTempStud  = true;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Student Info Mgmt","upload_id_step2.jsp");
		if(!bolIsTempStud) {
			strUID = dbOP.mapUIDToUIndex(strUID);
			if(strUID == null) {
				strErrMsg = "User does not exist.Please check user ID.";		
				bolFatalErr = true;
			}	
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_req_add.jsp","While Opening DB Con");
		strErrMsg = "Error in opening connection.";
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 0;
if(strErrMsg == null)
{
	///check if user is valid user. 
	if((String)request.getSession(false).getAttribute("userId") == null ) {
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	///if student or parent, give un-authorized access
	String strAuthIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	if(strAuthIndex != null && (strAuthIndex.equals("4") || strAuthIndex.equals("6")) ) {
		dbOP.cleanUP();
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
/**
	iAccessLevel =  comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Admission","Student Info Mgmt",request.getRemoteAddr(), 
															"upload_id_step2.jsp");	
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
**/
}

//end of authenticaion code.

if(strImgFileExt.length() >0)//first time called.
{
	request.getSession(false).removeAttribute("stud_id");
	request.getSession(false).setAttribute("stud_id",WI.fillTextValue("stud_id"));
	request.getSession(false).setAttribute("hr_emp",WI.fillTextValue("hr_emp"));

	request.getSession(false).removeAttribute("temp_stud");
	request.getSession(false).setAttribute("temp_stud",WI.fillTextValue("temp_id"));
}	
else
{
//upload the file here.
	UploadFile upload = new UploadFile();
	request.setAttribute("hr_emp", "/otr");
	if(upload.uploadIDcardImage(dbOP, request))
	{
		strErrMsg ="Upload Successful.";
		bolIsUploadSuccess = true;
		bolFatalErr = false;
	}
	else
	{
		//System.out.println(upload.getErrMsg());
		strErrMsg = "Upload failed : Reason - "+upload.getErrMsg();			
	}
}	

dbOP.cleanUP();

%>	

<font size="3" face="Verdana, Arial, Helvetica, sans-serif"><%=WI.getStrValue(strErrMsg)%></font>
<%if(bolFatalErr){//I have to abort%>
<font face="Verdana, Arial, Helvetica, sans-serif" size="1">
Click to close window </font><a href="javascript:window.close();"><img src="../../../../images/close_window.gif" border="0"></a>
<%}else if(strErrMsg != null && bolIsUploadSuccess)//upload is success
{%>
<br>
Click close window to go back to parent window and view the image uploaded.
<a href="javascript:CloseWindow();"><img src="../../../../images/close_window.gif" border="0"></a>
<%}else if(strErrMsg != null && !bolIsUploadSuccess){%>
<br>Click to go back to try again uploading the image.
<a href="javascript:history.back();"><img src="../../../../images/go_back.gif" border="0"></a>
<%}else{%>


<form action="./upload_id_step2.jsp" method="post" enctype="multipart/form-data" name="myForm" onSubmit="return ShowUploadingImg();">

<input type="file" name="myfile" size="80" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
  <br><br>
<input type="submit" name="s" value="Upload File >>">

<input type="hidden" name="img_ext" value="<%=request.getParameter("img_ext")%>">
<input type="hidden" name="hr_emp" value="<%=request.getParameter("hr_emp")%>">

</form>
<%}%>

</body></html>