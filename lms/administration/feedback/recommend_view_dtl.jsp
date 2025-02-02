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
<body>
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
								"lms-Administration-feedback-Comment view all.","recommend_view_all.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"LIB_Administration","FEEDBACK",request.getRemoteAddr(),
														"recommend_view_all.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
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
MgmtComment mgmtComment = new MgmtComment();
Vector vRetResult = null;
vRetResult = mgmtComment.operateOnRecommendation(dbOP, request, 3);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = mgmtComment.getErrMsg();

%>
<form name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          VIEW DETAILS RECOMMENDATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr valign="middle"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <%if(strErrMsg != null) {%>
    <tr> 
      <td height="25" colspan="3"><font size="3"><%=strErrMsg%></font></td>
    </tr>
    <%return;}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Date Recommended</td>
      <td height="25"><strong><%=(String)vRetResult.elementAt(13)%></strong></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="25%">Person Recommended</td>
      <td width="71%"><strong><%=(String)vRetResult.elementAt(1)%></strong></td>
    </tr>
<%
if(vRetResult.elementAt(2) != null){%>   <tr> 
      <td height="25">&nbsp;</td>
      <td>Occupation</td>
      <td><strong><%=WI.getStrValue(vRetResult.elementAt(2),"&nbsp;")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Company/Institution Name</td>
      <td height="25"><strong><%=WI.getStrValue(vRetResult.elementAt(3),"&nbsp;")%></strong></td>
    </tr>
<%}%>	
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Material type </td>
      <td><strong><%=(String)vRetResult.elementAt(6)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Title</td>
      <td><strong><%=(String)vRetResult.elementAt(7)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Author</td>
      <td><strong><%=(String)vRetResult.elementAt(8)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Publisher</td>
      <td><strong><%=(String)vRetResult.elementAt(9)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Edition/Version</td>
      <td><strong><%=(String)vRetResult.elementAt(10)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Reason</td>
      <td><strong><%=(String)vRetResult.elementAt(11)%> </strong></td>
    </tr>
    <tr> 
      <td height="35">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" name="hide_print"></a> 
        <input type="text" name="show_print" value="click to print the comment details" 
	  style="font-size:9px; font-family:Verdana, Arial, Helvetica, sans-serif; border: 0;"
	   size="60"></td>
    </tr>
  </table>
</form>
</body>
</html>
