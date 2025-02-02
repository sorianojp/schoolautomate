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
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	String strPrepareToEdit = null;
%>
<body bgcolor="#93B5BB">
<form name="cm_op" method="post" action="">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#6A99A2">
      <td width="92%" height="25" colspan="4"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          COURSE OBJECTIVE MAINTENANCE PAGE::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="3"> &nbsp;&nbsp;<strong>SUBJECT CODE :</strong>
        $course_code</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="3"> <p><strong>&nbsp;&nbsp;COURSE TITLE :</strong>
          $course_title</p></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><strong>&nbsp;&nbsp;Units : </strong>3 (lec)</td>
      <td height="25"><strong>Hours/Week :</strong> 3 Lecture, 0 Laboratory</td>
      <td height="25"><strong>Prerequisites :</strong> $prereq_sub</td>
    </tr>
    <tr valign="top" bgcolor="#FFFFFF">
      <td colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="2" cellspacing="0">
    <tr>
      <td width="22%"> <strong>COURSE OBJECTIVES</strong></td>
      <td colspan="2"><input name="textfield" type="text" size="54" maxlength="64">
      </td>
    </tr>
    <tr>
      <td colspan="3"> <div align="center">
          <%
 	strTemp = strPrepareToEdit;
    if(WI.getStrValue(strTemp,"0").compareTo("0") == 0) {
		if (iAccessLevel > 1){
%>
          <input name="image" type="image"
		  onClick="AddRecord()" src="../../../images/add.gif" width="42" height="32">
          <font size="1">click to add record</font>
          <%     }
  }else{ %>
          <input name="image" type="image" onClick='EditRecord()' src="../../../images/edit.gif" width="40" height="26" border="0">
          <font size="1">click to save changes </font><a href='javascript:CancelEdit();'><img src="../../../images/cancel.gif" width="51" height="26" border="0"></a>
          <font size="1">click to cancel or go previous</font>
          <%}%>
          &nbsp;</div></td>
    </tr>
    <tr>
      <td height="25" colspan="3"><hr size="1" noshade></td>
    </tr>
    <tr bgcolor="#BDD5DF">
      <td height="25" colspan="3"><div align="center"><font size="2"><strong>LIST
          OF COURSE OBJECTIVES</strong></font></div></td>
    </tr>
    <tr>
      <td colspan="2">- Define and know the importance of software engineering</td>
      <td width="24%"> <% if (iAccessLevel > 1){ %> <input name="image2" type="image"
					onClick='PrepareToEdit()' src="../../../images/edit.gif" width="40" height="26">
        <% if (iAccessLevel == 2){ %> <a href='javascript:DeleteRecord()'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
        <%}}%>
      </td>
    </tr>
    <tr>
      <td colspan="2">- Describe the features of C-Language </td>
      <td> <% if (iAccessLevel > 1){ %> <input name="image3" type="image"
					onClick='PrepareToEdit()' src="../../../images/edit.gif" width="40" height="26">
        <% if (iAccessLevel == 2){ %> <a href='javascript:DeleteRecord()'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
        <%}}%>
      </td>
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

