<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript">
function GoToParentWnd() {
	if(document.form_.reload_page.value == '1')
		return;
	
	
	window.opener.childWnd = null;
	window.opener.document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	document.form_.reload_page.value = '1';
	document.form_.submit();
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMSyllabus" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FACULTY/ACAD. ADMIN-CLASS MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FACULTY/ACAD. ADMIN"),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../faculty_acad/faculty_acad_bottom_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out.Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	//end of authenticaion code.

	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"><%=strErrMsg%></p>
		<%
		return;
	}

CMSyllabus cms = new CMSyllabus();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(cms.operateOnReference(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = cms.getErrMsg();
	else
		strErrMsg = "Operation successful.";
}

vRetResult = cms.operateOnReference(dbOP, request, 4);
if(vRetResult == null) 
	strErrMsg = cms.getErrMsg();

%>
<body bgcolor="#93B5BB" onUnload="GoToParentWnd();">
<form name="form_" method="post" action="./syl_reference.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#6A99A2">
      <td width="786" height="25"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          COURSE REFERENCE MAINTENANCE PAGE::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="2" cellspacing="0">
    <tr>
      <td width="13%">&nbsp;</td>
      <td width="16%">Media Type</td>
      <td width="71%">
          <select name="media_type">
<%=dbOP.loadCombo("MEDIA_TYPE_INDEX","MEDIA_NAME "," from CM_SYL_PRELOAD_REFMEDIA order by MEDIA_NAME",WI.fillTextValue("EVAL_METHOD_INDEX"), false)%>
          </select>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Title </td>
      <td><input name="ref_title" type="text" size="67" maxlength="256" class="textbox" value="<%=WI.fillTextValue("ref_title")%>"
	   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td valign="top">Details</td>
      <td><textarea name="ref_detail" cols="65" rows="5" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" class="textbox" style="font-size:11px;"><%=WI.fillTextValue("ref_detail")%></textarea>
        <br>
        Example: Yr Published, Author etc.</td>
    </tr>
    <tr>
      <td colspan="3"> <div align="center">
<%if (iAccessLevel > 1){%>
          <a href="javascript:PageAction(1, '');"><img src="../../../images/add.gif" border="0"></a>
          <font size="1">click to add record</font>
<%}%>
	    </div></td>
    </tr>
    <tr>
      <td colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="2" cellspacing="0">
    <tr bgcolor="#BDD5DF">
      <td height="25" colspan="4"><div align="center"><strong>LIST OF COURSE
          REFERENCES</strong></div></td>
    </tr>
<%for(int i = 0;i < vRetResult.size();){%>
    <tr>
      <td width="4%">&nbsp;</td>
      <td colspan="3"><strong><%=(String)vRetResult.elementAt(i + 1)%></strong></td>
    </tr>
<%vRetResult.setElementAt(null, i + 1);
for(; i < vRetResult.size(); i += 5) {
	if(vRetResult.elementAt( i + 1) != null)
		break;
	%>
    <tr>
      <td>&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td width="76%"><%=vRetResult.elementAt( i + 3)%>
	  <font color="#0000FF">
	  	<%=WI.getStrValue(ConversionTable.replaceString((String)vRetResult.elementAt( i + 4),"\n\r","<br>&nbsp;"), "<br>&nbsp;", "", "")%></font></td>
      <td width="18%">
	  <%if (iAccessLevel == 2){ %> 
	  	<a href='javascript:PageAction(0, "<%=(String)vRetResult.elementAt(i + 2)%>")'><img src="../../../images/delete.gif" border="0"></a>
      <%}%> </td>
    </tr>
<%}//end of for loop - I
}//end of main for loop.%>	
    <tr>
      <td colspan="4"><hr size="1" noshade></td>
    </tr>
  </table>
<%}%>

<table width="100%" border="0" cellpadding="2" cellspacing="0">
  <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#6A99A2">
    <td height="25">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="info_index">
<input type="hidden" name="reload_page">
<input type="hidden" name="page_action">
<input type="hidden" name="sub_index" value="<%=WI.fillTextValue("sub_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>

