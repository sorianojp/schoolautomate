<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function viewDetail(strInfoIndex) {
	var pgLoc = "./recommend_view_dtl.jsp?info_index="+strInfoIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
</script>
<body bgcolor="#DEC9CC">
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
if(iAccessLevel == 0) {//may be called from circulation.
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"LIB_Circulation","RECOMMENDATIONS",request.getRemoteAddr(),
														"recommend_view_all.jsp");
}
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
	if(mgmtComment.operateOnRecommendation(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = mgmtComment.getErrMsg();
	else	
		strErrMsg = "Recommendation removed successfully.";
}
vRetResult = mgmtComment.operateOnRecommendation(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = mgmtComment.getErrMsg();

%>
<form action="./recommend_view_all.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          VIEW ALL RECOMMENDATION PAGE ::::</strong></font></div></td>
    </tr>
<%
if(strErrMsg != null){%>
    <tr >
      <td height="30" ><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
<%}%>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="30">TOTAL NO. OF RECOMMENDATIONS : <strong><%=vRetResult.size()/ 14%></strong></td>
    </tr>
  </table>
  <table width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="10%" height="25"> <div align="center"><strong><font size="1">DATE</font></strong></div></td>
      <td width="18%" height="25"> <div align="center"><strong><font size="1">RECOMMENDED 
          BY</font></strong></div></td>
      <td width="12%"><div align="center"><font size="1"><strong>OCCUPATION</strong></font></div></td>
      <td width="18%"><div align="center"><font size="1"><strong>MATERIAL TYPE 
          RECOMMENDED</strong></font></div></td>
      <td><div align="center"><font size="1"><strong>TITLE</strong></font></div></td>
      <td width="20%"><div align="center"><font size="1"><strong>REASON</strong></font></div></td>
      <td colspan="2"><div align="center"><font size="1"></font></div>
        <div align="center"><font size="1"><strong>OPTION</strong></font></div></td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 14) {%>
    <tr> 
      <td height="25"><%=(String)vRetResult.elementAt(i + 13)%></td>
      <td><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i + 2),"&nbsp;")%></td>
      <td><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td><%=(String)vRetResult.elementAt(i + 7)%></td>
      <td><a href="javascript:viewDetail(<%=(String)vRetResult.elementAt(i)%>);"><%=(String)vRetResult.elementAt(i + 11)%></a></td>
      <td width="6%"><div align="center"><a href="javascript:viewDetail(<%=(String)vRetResult.elementAt(i)%>);"><img src="../../images/view.gif" border="0"></a></div></td>
      <td width="6%"><div align="center"><a href="javascript:PageAction(0,<%=(String)vRetResult.elementAt(i)%>);"><img src="../../images/delete.gif" border="0"></a></div></td>
    </tr>
<%}%>	
  </table>
 <%}//end of vRetResult printing.
 %>

<input type="hidden" name="page_action">
  </form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>