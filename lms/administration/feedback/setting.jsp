<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
</script>
<body bgcolor="#F2DFD2">
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
								"lms-Administration-feedback-setting","setting.jsp");
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
														"setting.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0 )//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
MgmtComment mgmtComment = new MgmtComment();
Vector vRetResult = null;
strTemp = WI.fillTextValue("page_action");
int iAction = Integer.parseInt(WI.getStrValue(strTemp,"4"));

vRetResult = mgmtComment.saveSetting(dbOP, request, iAction);
if(vRetResult == null)
	strErrMsg = mgmtComment.getErrMsg();
else {
	if(iAction == 1) 
		strErrMsg = "Setting saved successfully.";
}
%>
<form action="./setting.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
    <tr> 
      <td height="25" colspan="3" bgcolor="#0080C0"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          COMMENTS/ RECOMMENDATION SETTING PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="9%" height="25">&nbsp;</td>
      <td width="87%" height="25"><div align="center"><strong>::: COMMENTS :::</strong></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">
<%
if(vRetResult != null && vRetResult.size() > 0) 
	strTemp = (String)vRetResult.elementAt(1);
else
	strTemp = "0";
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else
	strTemp = "";
%>
		  <input type="checkbox" name="com_user_only" value="1"<%=strTemp%>>
        Login required to create comment(if not checked anyone can create comment)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Comment visibility status : </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">
<%
if(vRetResult != null && vRetResult.size() > 0) 
	strTemp = (String)vRetResult.elementAt(2);
else
	strTemp = "0";
if(strTemp.compareTo("0") == 0)
	strErrMsg = " checked";
else
	strErrMsg = "";
%>	  <input type="radio" name="VISIBILITY_STAT" value="0"<%=strErrMsg%>>
        Not visible to others 
<%
if(strTemp.compareTo("1") == 0)
	strErrMsg = " checked";
else
	strErrMsg = "";
%>        <input type="radio" name="VISIBILITY_STAT" value="1"<%=strErrMsg%>>
        Visible always 
<%
if(strTemp.compareTo("2") == 0)
	strErrMsg = " checked";
else
	strErrMsg = "";
%>        <!--<input type="radio" name="VISIBILITY_STAT" value="2"<%=strErrMsg%>>
        Visible only if approved--></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">
<%
if(vRetResult != null && vRetResult.size() > 0) 
	strTemp = (String)vRetResult.elementAt(3);
else
	strTemp = "1";
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else
	strTemp = "";
%>	  <input type="checkbox" name="dont_allow" value="1"<%=strTemp%>>
        Do not allow forbidden words in comment</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><div align="center"><strong>::: RECOMMENDATION :::</strong></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">
<%
if(vRetResult != null && vRetResult.size() > 0) 
	strTemp = (String)vRetResult.elementAt(0);
else
	strTemp = "0";
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else
	strTemp = "";
%>	  <input type="checkbox" name="rec_user_only" value="1"<%=strTemp%>>
        Login required to create Recommendation(if not checked anyone can create 
        comment)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td><font size="2"><strong>Default Setting :</strong> <strong>1. Anyone 
        can create 2. Not visible to all 3. Forbidden words not allowed in comments</strong></font></td>
    </tr>
    <tr> 
      <td height="58">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td><a href="javascript:PageAction(1)"><img src="../../images/save_recommend.gif" border="0"></a>
        <font size="1">click to save entries </font></td>
    </tr>
    <tr> 
      <td height="58">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>