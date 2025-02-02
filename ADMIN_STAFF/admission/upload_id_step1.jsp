<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript">
function OpenSearch(strIsEmp) {
	var pgLoc = "";
	if(strIsEmp == 1)
		pgLoc = "../../search/srch_emp.jsp?opner_info=upload_file.stud_id";
	else if(strIsEmp == 2)
	 	pgLoc = "../HR/applicants/applicant_search_name.jsp?opner_info=upload_file.stud_id";
	else
		pgLoc = "../../search/srch_stud.jsp?opner_info=upload_file.stud_id";
		
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.upload_file.stud_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.upload_file.stud_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>

<body bgcolor="#D2AE72" onLoad="document.upload_file.stud_id.focus()">
<%@ page language="java" import="utility.*,java.io.File" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strImgFileExt = null; // this makes sure i am using same file extension as i am using in property files.
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Student Info Mgmt","upload_id_step1.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Imange file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
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
int iAccessLevel = 2;
if(strErrMsg == null)
{
	///check if user is valid user. 
	if((String)request.getSession(false).getAttribute("userId") == null ) {
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	///if student or parent, give un-authorized access
	String strAuthIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	if(strAuthIndex != null && (strAuthIndex.equals("4") || strAuthIndex.equals("6")) ) {
		dbOP.cleanUP();
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	
/**
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Admission","Student Info Mgmt",request.getRemoteAddr(),
															"upload_id_step1.jsp");
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

dbOP.cleanUP();


if(strErrMsg != null)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
<%
return;
}

if(request.getParameter("deleteFile") != null && request.getParameter("deleteFile").compareTo("1") ==0)
{
	//authenticate the user here.
	String strStudId = request.getParameter("stud_id");
	if(strStudId == null || strStudId.trim().length() ==0)
		strErrMsg = "ID can't be empty.";
	else
	{
		File file = new File("../../upload_img/"+strStudId+"."+strImgFileExt);
		
 		if(file.exists())
		{
			file.delete();
			strErrMsg = "File removed successfully.";
		}
		else
			strErrMsg = "ID does not have any image.";
	}

}

if(strErrMsg == null) strErrMsg = "";
%>
<form method="post" name="upload_file" action="./upload_id_step1.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF" ><strong>::::
          IMAGE UPLOAD PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" width="1%"></td>
      <td height="25" colspan="5"><strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td height="22" width="1%"></td>
      <td width="10%" height="22" align="right"><div align="left">Enter ID</div></td>
      <td width="15%"><input type="text" name="stud_id" size="16" maxlength="32" value="<%=WI.fillTextValue("stud_id").toUpperCase()%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  OnKeyUP="javascript:this.value=this.value.toUpperCase();AjaxMapName(1);">      </td>
      <td width="7%">&nbsp;&nbsp;<a href="javascript:OpenSearch(<%=WI.getStrValue(WI.fillTextValue("hr_emp"),"0")%>);"><img src="../../images/search.gif" border="0"></a></td>
      <td width="46%"><font size="1"><a href="javascript:UploadFile(<%=WI.getStrValue(WI.fillTextValue("hr_emp"),"0")%>);"><img src="../../images/form_proceed.gif" border="0"></a>
        Click to upload file or change image</font></td>
      <td width="21%" rowspan="3" valign="top"><img src="../../images/blank.gif"name="stud_image" width="100" height="100"></td>
    </tr>
    <tr>
      <td height="25" rowspan="2"></td>
      <td height="6" align="right" valign="top">&nbsp;</td>
      <td colspan="3" valign="top">&nbsp; <a href="javascript:ViewImage(<%=WI.getStrValue(WI.fillTextValue("hr_emp"),"0")%>);"><img src="../../images/view.gif" border="0"></a>
        <font size="1">Click to view image</font>
        <%
		if (false) {
		if(iAccessLevel ==2){%>
        <input name="image" type="image" onClick="DeleteFile();" src="../../images/delete.gif" border="0">
        <font size="1">Click to delete file</font>&nbsp;&nbsp;
        <%}else{%>
        No delete privilege
        <%}
		}%>      </td>
    </tr>
    <tr>
      <td height="12" align="right" valign="top">&nbsp;</td>
      <td colspan="3" valign="top"><label id="coa_info"></label></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="7"><div align="center"></div></td>
      <td width="24%" height="25">&nbsp;</td>
      <td width="62%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="deleteFile" value="0">
  <input type="hidden" name="img_ext" value="<%=strImgFileExt%>">
  <!-- 2 = applicant's directory -->
  <input type="hidden" name="hr_emp" value="<%=WI.fillTextValue("hr_emp")%>">
</form>
<script language="JavaScript">
function ReloadPage()
{
	document.upload_file.submit();
}
function UploadFile(strIsEmp)
{
	if(document.upload_file.stud_id.value.length ==0){
		if (strIsEmp == 1) 
			alert("please enter employee id to view image.");
		else if(strIsEmp == 2) 
			alert("please enter student id to view image.");		
		else
			alert("please enter applicant id to view image.");		
	} else
	{
		var sT = "./upload_id_step2.jsp?stud_id="+escape(document.upload_file.stud_id.value)+"&img_ext=<%=strImgFileExt%>"+
		"&hr_emp="+strIsEmp;
		var win=window.open(sT,"UploadFile",'dependent=yes,width=700,height=200,top=200,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
function ViewImage(strIsEmp)
{
	if(document.upload_file.stud_id.value.length ==0){
		if (strIsEmp == 1) 
			alert("please enter employee id to view image.");
		else if (strIsEmp == 2) 
			alert("please enter applicant id to view image.");		
		else
			alert("please enter student id to view image.");		
	} else	{
		document.stud_image.src="../../images/blank.gif";
		if(strIsEmp == 2)
			eval('document.stud_image.src = \"../../faculty_img/'+document.upload_file.stud_id.value+'.<%=strImgFileExt%>\"');
		else
			eval('document.stud_image.src = \"../../upload_img/'+document.upload_file.stud_id.value+'.<%=strImgFileExt%>\"');
	}
}
function DeleteFile()
{
	document.upload_file.deleteFile.value = "1";
}
</script>


</body>
</html>
