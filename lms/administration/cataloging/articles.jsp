<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
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
function viewList(table,indexname,colname,labelname){
	var loadPg = "../../../ADMIN_STAFF/HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+
	labelname+"&opner_form_name=form_";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

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
								"lms-Administration-CATALOGING","articles.jsp");
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
														"articles.jsp");
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
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

	MgmtCatalog mgmtArticle = new MgmtCatalog();
	Vector vEditInfo  = null;Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(mgmtArticle.operateOnArticle(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = mgmtArticle.getErrMsg();
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Article information successfully removed.";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Article information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Article information successfully edited.";

			strPrepareToEdit = "0";
		}
	}

	vRetResult = mgmtArticle.operateOnArticle(dbOP, request,4);	
	
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = mgmtArticle.operateOnArticle(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = mgmtArticle.getErrMsg();
	}
%>

<body bgcolor="#DEC9CC">
<form action="./articles.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING MANAGEMENT -ARTICLES PAGE ::::</strong></font></div></td>
    </tr>
	</table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr > 
      <td width="2%" height="25"></td>
      <td width="16%">Recognize Article Group</td>
      <td width="22%"> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("ARTICLE_GR_INDEX");
%> <select name="ARTICLE_GR_INDEX">
          <%=dbOP.loadCombo("ARTICLE_GR_INDEX","ARTICLE_GROUP"," from LMS_CLOG_ARTICLE_GR order by ARTICLE_GROUP asc",strTemp, false)%> </select> </select> </td>
      <td colspan="2"><font size="1"><a href='javascript:viewList("LMS_CLOG_ARTICLE_GR","ARTICLE_GR_INDEX","ARTICLE_GROUP","ARTICLE-GROUP");'><img src="../../images/update.gif" border="0"></a>click 
        to update list</font></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td>Article <br> Max Characters : <input type="text" name="count_" class="textbox_noborder" readonly="yes" tabindex="-1" size="3" style="background-color:#DEC9CC; border:0px;"></td>
      <td height="25" colspan="3"><font size="1"> 
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("ARTICLE");
%>
        <textarea name="ARTICLE"
		onBlur="CharTicker('form_','256','ARTICLE','count_');style.backgroundColor='white'" rows="3" cols="80" class="textbox"
		onfocus="CharTicker('form_','256','ARTICLE','count_');style.backgroundColor='#D3EBFF'"
		onkeyup="CharTicker('form_','256','ARTICLE','count_');"><%=strTemp%></textarea>
      </font
        ></td>
    </tr>
<%
if(iAccessLevel > 1) {%>
    <tr > 
      <td height="56">&nbsp;</td>
      <td height="56" colspan="3"><font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="./articles.jsp"><img src="../../images/cancel.gif" border="0"></a> 
        Click to clear entries</font></td>
      <td width="32%" valign="bottom"></td>
    </tr>
<%}%>	
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="3" bgcolor="#DDDDEE" class="thinborder"><div align="center">LIST 
          OF RECOGNIZED ARTICLES</div></td>
    </tr>
    <tr> 
      <td width="24%" height="25" class="thinborder"><div align="center"><font size="1"><strong>RECOGNIZED 
          ARTICLE GROUP </strong></font></div></td>
      <td width="50%" class="thinborder"><div align="center"><font size="1"><strong>ARTICLE</strong></font></div></td>
      <td width="26%" class="thinborder"><div align="center"><font size="1"><strong>OPTIONS</strong></font></div></td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 4){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder" align="center">
        <%
if(iAccessLevel > 1){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/edit.gif" border="0"></a> 
        <%}if(iAccessLevel == 2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/delete.gif" border="0"></a> 
        <%}%>
      </td>
    </tr>
<%}%>
	
  </table>
<%}%>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  </form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>