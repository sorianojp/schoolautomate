<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PageAction(strAction, strFBWord) {
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strFBWord;
	document.form_.submit();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
function focusID() {
	document.form_.FB_WORD.focus();
}
</script>
<body bgcolor="#F2DFD2" onLoad="focusID()">
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"LIB_Administration","FEEDBACK",request.getRemoteAddr(),
														"forbidden_words.jsp");
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
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(mgmtComment.operateOnForbiddenWord(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = mgmtComment.getErrMsg();
	else 
		strErrMsg = "Operation successful.";
}
vRetResult = mgmtComment.operateOnForbiddenWord(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = mgmtComment.getErrMsg();
%>
<form action="./forbidden_words.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3" bgcolor="#0080C0"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          FORBIDDEN WORD MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td height="25" colspan="2"><font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="20%" height="25">Block this word:</td>
      <td width="76%" height="25"><input name="FB_WORD" type="text" size="25" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	   value="<%=WI.fillTextValue("FB_WORD")%>" maxlength="24"></td>
    </tr>
    <tr> 
      <td height="58">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td><a href='javascript:PageAction("1","");'> <img src="../../images/save_recommend.gif" border="0"></a> 
        <font size="1">click to save entries <a href="javascript:document.form_.FB_WORD.value='';"> 
        </a><a href='javascript:ReloadPage();'> <img src="../../../images/refresh.gif" border="1" hspace="10"></a> 
        <font size="1">click to refresh page</font
        ></font
        ></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
    <tr> 
      <td height="25" colspan="5"><div align="center"><strong>TOTAL NUMBER OF 
          FORBIDDEN WORDS IN SYSTEM : </strong></div></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="32%" height="25"><font size="1"><strong>WORD</strong></font></td>
      <td width="24%"><font size="1"><strong>REMOVE</strong></font></td>
      <td width="29%"><font size="1"><strong>WORD</strong></font></td>
      <td width="11%"><font size="1"><strong>REMOVE</strong></font></td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 2){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><%=(String)vRetResult.elementAt(i)%></td>
      <td><%if(iAccessLevel== 2) {%>
	  <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'>
	  <img src="../../images/delete_recommend.gif" border="0"></a>
	  <%}%>
	  </td>
      <td><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td><%if(iAccessLevel== 2 && ((String)vRetResult.elementAt(i + 1)).length() > 0 ) {%>
	  <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i + 1)%>");'>
	  <img src="../../images/delete_recommend.gif" border="0"></a>
	  <%}%></td>
    </tr>
<%}%>
  </table>
<%}%>
 <input type="hidden" name="page_action">
 <input type="hidden" name="info_index">
 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>