<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PrintPg() {
	document.form_.show_print.value = "";
	document.form_.hide_print.src = "../../../images/blank.gif";
	window.print();
}
</script>
<%@ page language="java" import="utility.*,lms.MgmtComment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"lms-Administration-feedback-forbidden words","forbidden_words.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.

//end of authenticaion code.
Vector vRetResult = null;
if(request.getSession(false).getAttribute("userId") == null) {
	strErrMsg = "Login to view comment details.";
}
else {
	MgmtComment mgmtComment = new MgmtComment();
	vRetResult = mgmtComment.operateOnComment(dbOP, request, 3);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = mgmtComment.getErrMsg();
	}

dbOP.cleanUP();
%>
<body bgcolor="#FFFFFF">
<form name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="3" class="thinborderBOTTOM"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          VIEW DETAILS COMMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <%if(strErrMsg != null) {%>
    <tr> 
      <td height="25" colspan="3"><font size="3"><%=strErrMsg%></font></td>
    </tr>
    <%return;}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Date Created</td>
      <td height="25"><strong><%=(String)vRetResult.elementAt(10)%></strong></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="22%" height="25">Topic</td>
      <td width="74%" height="25"><strong><%=(String)vRetResult.elementAt(1)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Name of Person</td>
      <td height="25"><strong><%=(String)vRetResult.elementAt(2)%></strong></td>
    </tr>
    <%
if(vRetResult.elementAt(3) != null){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Occupation/Course</td>
      <td height="25"><strong><%=(String)vRetResult.elementAt(3)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Company Name/School</td>
      <td height="25"><strong><%=(String)vRetResult.elementAt(4)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Email Address</td>
      <td height="25"><strong><%=(String)vRetResult.elementAt(5)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Postal Address</td>
      <td height="25"><strong><%=(String)vRetResult.elementAt(6)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Contact Nos.</td>
      <td height="25"><strong><%=(String)vRetResult.elementAt(7)%></strong></td>
    </tr>
    <%}//if user is not logged in.%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >Comments</td>
      <td><strong><%=(String)vRetResult.elementAt(8)%></strong></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:PrintPg();">
	  <img src="../../../images/print.gif" border="0" name="hide_print"></a>
	  <input type="text" name="show_print" value="click to print the comment details" 
	  style="font-size:9px; font-family:Verdana, Arial, Helvetica, sans-serif; border: 0;"
	   size="60"></td>
    </tr>
  </table>
</form>
</body>
</html>
