<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function focusID() {
	document.form_.LINK_NAME.focus();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.prepareToEdit.value = "1";
	document.form_.page_action.value = "";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function PrintPage() {
	//popup print widnow.
	var loadPg = "../../links/show_links_print.jsp?show_=1&LINK_CATG_INDEX="+
	document.form_.LINK_CATG_INDEX.value;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=750,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function viewList(table,indexname,colname,labelname){
	var loadPg = "../../../ADMIN_STAFF/HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+
	"&label="+labelname+"&opner_form_name=form_";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%@ page language="java" import="utility.*,lms.MgmtLink,java.util.Vector" %>
<%
	String strUserID = (String)request.getSession(false).getAttribute("userId");
	Vector vSetting  = null;
	
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"lms-Administration-LINKS MANAGEMENT","links.jsp");
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
														"LIB_Administration","LINKS MANAGEMENT",request.getRemoteAddr(),
														"links.jsp");
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
		
	MgmtLink mgmtLink = new MgmtLink();
	Vector vRetResult = null;
	Vector vEditInfo  = null;
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(mgmtLink.operateOnLink(dbOP, request, Integer.parseInt(strTemp)) == null) 
			strErrMsg = mgmtLink.getErrMsg();
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Link successfully removed.";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Link successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Link successfully edited.";
				
			strPrepareToEdit = "0";
		}
	}
	vRetResult = mgmtLink.operateOnLink(dbOP, request,4);
	
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = mgmtLink.operateOnLink(dbOP, request,3); 
		if(vEditInfo == null) 
			strErrMsg = mgmtLink.getErrMsg();
	}
%>

<body bgcolor="#DEC9CC" onLoad="focusID();">
<form action="./links.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          LINKS MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td width="3%" height="32">&nbsp;</td>
      <td width="12%">Link Category</td>
      <td width="17%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("LINK_CATG_INDEX") ;
%>
	  <select name="LINK_CATG_INDEX" onChange="ReloadPage();">
	  <option value="">ALL</option>
          <%=dbOP.loadCombo("LINK_CATG_INDEX","CATEGORY"," from LMS_LINK_CATG order by CATEGORY asc",strTemp, false)%> 
	  </select> 
	  </td>
      <td><a href='javascript:viewList("LMS_LINK_CATG","LINK_CATG_INDEX","CATEGORY","CATEGORY");'><img src="../../images/update.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td height="20" colspan="2"><font size="1"><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="1"></a> 
        Click to refresh the page.</font></td>
    </tr>
    <tr> 
      <td height="20" colspan="4"><hr size="1" color="#5353A8"></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Link Name</td>
      <td height="28" colspan="2">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("LINK_NAME") ;
%>	  
	<input name="LINK_NAME" type="text" size="55" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" maxlength="64" value="<%=strTemp%>"> </td>
    </tr>
    <tr> 
      <td height="31">&nbsp;</td>
      <td height="31">URL</td>
      <td height="31" colspan="2">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("LINK_URL") ;
%>
	  <input name="LINK_URL" type="text" size="55" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  maxlength="64" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="41">&nbsp;</td>
      <td height="41" valign="top">Description</td>
      <td height="41" colspan="2">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("DESCRIPTION") ;
%>
	  <textarea name="DESCRIPTION" cols="55" rows="5" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" 
	  onblur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
<%
if(iAccessLevel > 1) {%>
    <tr> 
      <td height="45">&nbsp;</td>
      <td height="45">&nbsp;</td>
      <td height="45" colspan="2"><font size="1">
<%if(strPrepareToEdit.compareTo("0") == 0) {%>
	  <a href='javascript:PageAction("1","");'><img src="../../images/save.gif" border="0"></a> 
        Save entries 
<%}else{%>
	  <a href='javascript:PageAction("2","<%=(String)vEditInfo.elementAt(0)%>");'><img src="../../images/edit.gif" border="0"></a> 
        Edit entries 
<%}%>
		<a href="./links.jsp"><img src="../../../images/clear.gif" border="1"></a> 
        Clear entries</font></td>
    </tr>
<%}%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDDEE"> 
      <td height="24" colspan="5" bgcolor="#DDDDEE"><div align="center"><font color="#FF0000"><strong>LIST 
          OF LINKS UNDER THIS CATEGORY</strong></font></div></td>
    </tr>
    <tr> 
      <td width="22%" height="25"><div align="center"><font size="1"><strong>SUBLINK 
          NAME</strong></font></div></td>
      <td width="29%" valign="middle"><div align="center"><font size="1"><strong>URL</strong></font></div></td>
      <td width="38%" valign="middle"><div align="center"><font size="1"><strong>DESCRIPTION</strong></font></div></td>
      <td colspan="2" valign="middle"><div align="center"><font size="1"><strong>OPTIONS</strong></font></div></td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 6){%>
    <tr> 
      <td height="25"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td height="25" valign="middle"><a href="<%=(String)vRetResult.elementAt(i + 4)%>" target="_blank"><%=(String)vRetResult.elementAt(i + 4)%></a></td>
      <td height="25" valign="middle"><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td width="5%" height="25" valign="middle">
<%if(iAccessLevel > 1) {%>
        <a href='javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>);'><img src="../../images/edit.gif" border="0"></a> 
<%}%>
	  </td>
      <td width="6%" height="25" valign="middle">
<%if(iAccessLevel == 2) {%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/delete.gif" border="0"></a> 
<%}%>
    </tr>
<%}//for loop%>

  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="0%" height="42">&nbsp;</td>
      <td width="13%">&nbsp;</td>
      <td width="87%" height="42" colspan="3" valign="middle">
	  <a href="javascript:PrintPage();">
	  <img src="../../images/print.gif" border="0"></a><font size="1">&nbsp;click 
        to print list</font></td>
    </tr>
  </table>
 <%}//if vRetResult > 0%>
 
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>