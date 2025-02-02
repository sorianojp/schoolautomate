<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function focusID() {
	document.form_.FS_CODE.focus();
}
</script>
<body topmargin="10">

<%@ page language="java" import="utility.*,lms.MgmtCatalog,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"lms-Administration-CATALOGING","fs_profile.jsp");
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
														"LIB_Administration","CATALOGING",request.getRemoteAddr(),
														"fs_profile.jsp");
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
	MgmtCatalog mgmtFS = new MgmtCatalog();
	Vector vEditInfo  = null;Vector vRetResult = null;
	vRetResult = mgmtFS.operateOnFSProfile(dbOP, request,4);
	if(vRetResult == null || vRetResult.size() == 0) 
		strErrMsg = mgmtFS.getErrMsg();	

if(strErrMsg != null) {%>
<table width="100%" cellspacing="0" cellpadding="0" class="thinborder">
  <tr> 
    <td height="26"><font color="#FF0000" size="3"><%=strErrMsg%></font></td>
  </tr>
</table>
<%}%>

  <%if(vRetResult != null && vRetResult.size() > 0) {%>
  
<table width="100%" cellspacing="0" cellpadding="0" class="thinborder">
  <tr> 
    <td height="26" colspan="6" bgcolor="#DDDDEE" class="thinborder"><div align="center">LIST 
        OF EXISTING FUNDING SOURCE</div></td>
  </tr>
  <tr> 
    <td width="12%" height="25" class="thinborder"><div align="center"><font size="1"><strong> 
        CODE NO.</strong></font></div></td>
    <td width="26%" class="thinborder"><div align="center"><font size="1"><strong>NAME</strong></font></div></td>
    <td width="7%" class="thinborder"><div align="center"><font size="1"><strong><font size="1">STATUS</font></strong></font></div></td>
    <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>CONTACT 
        PERSON</strong></font></div></td>
    <td width="12%" class="thinborder"><div align="center"><font size="1"><strong><font size="1"><strong>CONTACT 
        NOS. </strong></font></strong></font></div></td>
    <td width="14%" class="thinborder"><div align="center"><strong><font size="1"><strong><strong>REMARKS</strong></strong></font></strong></div></td>
  </tr>
  <%
	String[] astrFSStat = {"In-active","Active"};
	for(int i = 0; i < vRetResult.size(); i += 8){%>
  <tr> 
    <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
    <td class="thinborder">&nbsp;<%=astrFSStat[Integer.parseInt((String)vRetResult.elementAt(i + 3))]%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 4))%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 5))%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 6))%></td>
  </tr>
  <%}%>
</table>
<script language="javascript">
window.print();

</script>
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>