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
	var pgLoc = "./comment_view_dtl.jsp?info_index="+strInfoIndex;
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
								"lms-Administration-feedback-Comment view all.","comment_view_all.jsp");
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
MgmtComment mgmtComment = new MgmtComment();
Vector vRetResult = null;
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(mgmtComment.operateOnComment(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = mgmtComment.getErrMsg();
	else	
		strErrMsg = "Comment removed successfully.";
}
int iAction = 4;
if(WI.fillTextValue("view_self").length() > 0)
	iAction = 5;

vRetResult = mgmtComment.operateOnComment(dbOP, request, iAction);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = mgmtComment.getErrMsg();

%>
<form action="./comment_view_all.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          VIEW ALL COMMENT PAGE ::::</strong></font></div></td>
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
      <td height="30">TOTAL NO. OF COMMENTS : <strong><%=vRetResult.size()/ 11%></strong></td>
    </tr>
  </table>
	  
  <table width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="10%" height="25"> <div align="center"><strong><font size="1">DATE</font></strong></div></td>
      <td width="20%"><div align="center"><font size="1"><strong>TOPIC</strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>NAME OF PERSON</strong></font></div></td>
      <td width="20%"><div align="center"><font size="1"><strong>OCCUPATION/COURSE</strong></font></div></td>
      <td width="25%"><div align="center"><font size="1"><strong>COMMENTS</strong></font></div></td>
<!--      <td width="5%"><font size="1"><strong>APPROVE</strong></font></td>-->
      <td colspan="2"><div align="center"><font size="1"></font></div>
        <div align="center"><font size="1"><strong>OPTION</strong></font></div></td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 11) {%>
    <tr> 
      <td height="25"><%=(String)vRetResult.elementAt(i + 10)%></td>
      <td><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i + 3),"&nbsp;")%></td>
      <td><a href="javascript:viewDetail(<%=(String)vRetResult.elementAt(i)%>);"><%=(String)vRetResult.elementAt(i + 8)%></a></td>
<!--      <td>&nbsp;</td>-->
      <td width="5%"><a href="javascript:viewDetail(<%=(String)vRetResult.elementAt(i)%>);"><img src="../../images/view.gif" border="0"></a></td>
      <td width="5%"><a href="javascript:PageAction(0,<%=(String)vRetResult.elementAt(i)%>);"><img src="../../images/delete.gif" border="0"></a></td>
    </tr>
<%}%>	
  </table>
 <%}//end of vRetResult printing.
 %>
<input type="hidden" name="page_action">
<input type="hidden" name="view_self" value="<%=WI.fillTextValue("view_self")%>">
  </form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>