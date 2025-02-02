<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<%@ page language="java" import="utility.*,java.util.Vector,eDTR.TimeInTimeOut" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Edit Time-in Time-out","edit_dtr.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(),
														"edit_dtr.jsp");
iAccessLevel = 2;
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	String strPrepareToEdit = null;
%>
<body bgcolor="#93B5BB">
<form name="cm_op" method="post" action="">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#6A99A2">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          TOPIC AND CONTENT MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4"><a href='cm_lessonplan.jsp'><img src="../../../images/go_back.gif" width="51" height="26" border="0"></a></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4"> &nbsp;&nbsp;<strong>DATE :</strong> DECEMBER
        16, 2003</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4"> <p><strong>&nbsp;&nbsp;TEACHER NAME : </strong>ROGER
          , AMELIA S.</p></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="15%" height="25"><strong> &nbsp; LEVEL : </strong>GRADE 5</td>
      <td width="35%" height="25"> &nbsp;&nbsp;<strong>SUBJECT CODE :</strong></td>
      <td width="50%" height="25" colspan="2"><strong>SUBJECT TITLE : </strong>Philippines
        Then and Now</td>
    </tr>
    <tr valign="top" bgcolor="#FFFFFF">
      <td colspan="4"><hr size="1" noshade></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="2" cellspacing="0">
    <tr>
      <td width="19%"><strong>TOPIC</strong></td>
      <td width="81%"><p>
          <textarea name="textarea" cols="64" rows="5" wrap="VIRTUAL">Who are we before the Spanish arrived? Americans Left? Japanese Struggled?</textarea>
        </p></td>
    </tr>
    <tr>
      <td><strong>CONTENTS</strong></td>
      <td><p>
          <textarea name="textarea" cols="64" rows="5" wrap="VIRTUAL">Mestizos, Yankees, and Sakangss</textarea>
        </p></td>
    </tr>
    <tr>
      <td colspan="2"><div align="center">
          <%
 	strTemp = strPrepareToEdit;
    if(WI.getStrValue(strTemp,"0").compareTo("0") == 0) {
		if (iAccessLevel > 1){
%>
          <input type="image" src="../../../images/add.gif" width="42" height="32"
		  onClick="AddRecord()">
          <font size="1">click to add record</font>
          <%     }
  }else{ %>
          <input type="image" onClick='EditRecord()' src="../../../images/edit.gif" width="40" height="26" border="0"></a>
          <font size="1">click to save changes </font><a href='javascript:CancelEdit();'><img src="../../../images/cancel.gif" width="51" height="26" border="0"></a>
          <font size="1">click to cancel or go previous</font>
          <%}%>
          &nbsp;</div></td>
    </tr>
  </table>

<table width="100%" border="0" cellpadding="2" cellspacing="0">
  <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#6A99A2">
    <td height="25">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="info_index">
</form>
</body>
</html>

