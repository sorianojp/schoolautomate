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
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          COURSE OUTLINE MAINTENANCE PAGE::::</strong></font></div></td>
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
      <td width="151" height="25"><strong>&nbsp;&nbsp;Units : </strong>3 (lec)</td>
      <td width="343" height="25"><strong>Hours/Week :</strong> 3 Lecture, 0 Laboratory</td>
      <td width="292" height="25"><strong>Prerequisites :</strong> $prereq_sub</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="5" cellspacing="0">
    <tr>
      <td><strong>CHAPTER TITLE</strong></td>
      <td><select name="select">
          <option>Select Chapter</option>
          <option>Introduction</option>
          <option>Project Planning</option>
        </select> &nbsp; <input type="checkbox" name="checkbox" value="checkbox">
        <font size="1"> tick to add new chapter</font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Chapter Title
        <input type="text" name="textfield"> &nbsp;&nbsp;Tentantive hours
        <input name="textfield2" type="text" size="4" maxlength="3"> </td>
    </tr>
    <tr>
      <td><strong>TOPIC</strong></td>
      <td><input type="text" name="textfield3">
        Tentantive hours
        <input name="textfield22" type="text" size="4" maxlength="3"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="checkbox" name="checkbox2" value="checkbox"> <font size="1">tick
        if topic has subtopics </font></td>
    </tr>
    <tr>
      <td width="17%">&nbsp;</td>
      <td width="83%"><p>
          <textarea name="textarea" cols="64" rows="5"></textarea>
        </p></td>
    </tr>
    <tr>
      <td colspan="2"> <div align="center">
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
      <td colspan="2"><hr size="1" noshade></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#BDD5DF">
      <td height="30" colspan="4"><p align="center"><strong>COURSE OUTLINE</strong></p></td>
    </tr>
    <tr>
      <td width="13%">&nbsp;</td>
      <td width="41%"><font size="2" face="Arial, Helvetica, sans-serif"><strong>Introduction</strong></font></td>
      <td width="20%"><font size="2" face="Arial, Helvetica, sans-serif">( 9 hours)</font></td>
      <td width="26%"> <% if (iAccessLevel > 1){ %> <input name="image2" type="image"
					onClick='PrepareToEdit()' src="../../../images/edit.gif" width="40" height="26">
        <% if (iAccessLevel == 2){ %> <a href='javascript:DeleteRecord()'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
        <%}}%> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><font size="2" face="Arial, Helvetica, sans-serif">&nbsp;&nbsp;&nbsp;
        &nbsp;Definition of Software Engineering</font></td>
      <td><font size="2" face="Arial, Helvetica, sans-serif">( 3 hours)</font></td>
      <td> <% if (iAccessLevel > 1){ %> <input name="image22" type="image"
					onClick='PrepareToEdit()' src="../../../images/edit.gif" width="40" height="26">
        <% if (iAccessLevel == 2){ %> <a href='javascript:DeleteRecord()'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
        <%}}%> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><font size="2" face="Arial, Helvetica, sans-serif"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System
        Approach</font></td>
      <td><font size="2" face="Arial, Helvetica, sans-serif"> ( 6 hours)</font></td>
      <td> <% if (iAccessLevel > 1){ %> <input name="image222" type="image"
					onClick='PrepareToEdit()' src="../../../images/edit.gif" width="40" height="26">
        <% if (iAccessLevel == 2){ %> <a href='javascript:DeleteRecord()'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
        <%}}%> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><font size="2" face="Arial, Helvetica, sans-serif"><strong>Implementation,
        Tests, and Maintenance</strong></font></td>
      <td><font size="2" face="Arial, Helvetica, sans-serif">( 4 hours)</font></td>
      <td> <% if (iAccessLevel > 1){ %> <input name="image2222" type="image"
					onClick='PrepareToEdit()' src="../../../images/edit.gif" width="40" height="26">
        <% if (iAccessLevel == 2){ %> <a href='javascript:DeleteRecord()'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
        <%}}%> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><font size="2" face="Arial, Helvetica, sans-serif">&nbsp;&nbsp; &nbsp;Program
        Testing </font></td>
      <td><font size="2" face="Arial, Helvetica, sans-serif">( 2 hours)</font></td>
      <td> <% if (iAccessLevel > 1){ %> <input name="image22222" type="image"
					onClick='PrepareToEdit()' src="../../../images/edit.gif" width="40" height="26">
        <% if (iAccessLevel == 2){ %> <a href='javascript:DeleteRecord()'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
        <%}}%> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><font size="2" face="Arial, Helvetica, sans-serif"> &nbsp;&nbsp; &nbsp;System
        Testing </font></td>
      <td><font size="2" face="Arial, Helvetica, sans-serif"> ( 2 hours)</font></td>
      <td> <% if (iAccessLevel > 1){ %> <input name="image22223" type="image"
					onClick='PrepareToEdit()' src="../../../images/edit.gif" width="40" height="26">
        <% if (iAccessLevel == 2){ %> <a href='javascript:DeleteRecord()'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
        <%}}%> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><font size="2" face="Arial, Helvetica, sans-serif">&nbsp;&nbsp;&nbsp;&nbsp;Function
        and Performance<br>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Test Documentation<br>
        </font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="30" colspan="4"><div align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>PREFINAL</strong></font></div></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><font size="2" face="Arial, Helvetica, sans-serif"><strong>Requirement
        Analysis</strong></font></td>
      <td><font size="2" face="Arial, Helvetica, sans-serif">( 6 hours)</font></td>
      <td> <% if (iAccessLevel > 1){ %> <input name="image222232" type="image"
					onClick='PrepareToEdit()' src="../../../images/edit.gif" width="40" height="26">
        <% if (iAccessLevel == 2){ %> <a href='javascript:DeleteRecord()'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
        <%}}%> </td>
    </tr>
    <tr>
      <td height="30" colspan="4"><div align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>MIDTERM
          EXAM</strong></font></div></td>
    </tr>
    <tr>
      <td colspan="4"><div align="center">....</div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
  <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#6A99A2">
    <td height="25">&nbsp;</td>
  </tr>
</table></form>
</body>
</html>

