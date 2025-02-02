<%@ page language="java" import="utility.ReadPropertyFile,java.io.File" %>
<%
 
	String strImgFileExt = null; // this makes sure i am using same file extension as i am using in property files. 
	String strErrMsg = null;
//add security here.
	try
	{
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		readPropFile.loadPropertyFile("../../properties/userconf.properties");
		strImgFileExt = readPropFile.getProperty("imgFileUploadExt");
		
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Imange file extension is missing. Please contact school admin.";
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_req_add.jsp","While Opening DB Con");
		strErrMsg = "Error in Reading property file.";
	}
if(strErrMsg != null)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
<%
return;
}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
//function LoadImageInOpenerWnd()
{
	window.opener.document.stud_image.src="../../upload_img/<%=request.getParameter("stud_id")%>.<%=strImgFileExt%>";
	alert("<%=request.getParameter("message")%>");
	window.close();
}

</script>

<body>
<form>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="3"><div align="center"><strong>:::: ADMISSION - 
        UPLOAD RESULT PAGE::::</strong></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" width="16%"></td>
      <td width="84%" height="25" colspan="2">&nbsp;</td>
    </tr>
	<tr bgcolor="#FFFFFF"> 
      <td height="25" width="16%"></td>
      <td width="84%" height="25" colspan="2">&nbsp;</td>
    </tr>
	<tr bgcolor="#FFFFFF"> 
      <td height="25" width="16%"></td>
      
    <td width="84%" height="25" colspan="2">MESSAGE : <%=request.getParameter("message")%></td>
    </tr>
	<tr bgcolor="#FFFFFF"> 
      <td height="25" width="16%"></td>
      <td width="84%" height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>  
</form>
</body>
</html>
