<%
String strAuthID = (String)request.getSession(false).getAttribute("userIndex");
if(strAuthID == null) {%>
	<p style="font-weight:bold; color:#FF0000; font-size:14px;"> You are already logged out. Please login again.</p>
<%return;}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm("Are you sure you want to remove this record."))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value  = strInfoIndex;
	
	document.form_.submit();
}
//all about ajax - to display student list with same name.
var strLinkTo;
function AjaxMapName(strLink) {
		strLinkTo = strLink;
		var strCompleteName;
		
		if(strLink == '1')
			strCompleteName = document.form_.sys_id.value;
		else
			strCompleteName = document.form_.uid_manage.value;
			
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	if(strLinkTo == '1')
		document.form_.sys_id.value = strID;
	else
		document.form_.uid_manage.value = strID;

	
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	this.viewInfo();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>

<body bgcolor="#D2AE72" onLoad="document.form_.sys_id.focus();">
<%@ page language="java" import="utility.*,enrollment.Authentication,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation();
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
    String strSQLQuery = "select MANAGE_USER_INDEX from SYSAD_MANAGE_USER where USER_INDEX_TO_MANAGE is null " +
      " and SYSAD_USER_INDEX = "+strAuthID;
    if(dbOP.getResultOfAQuery(strSQLQuery, 0) == null) {%>
		<p style="font-weight:bold; color:#FF0000; font-size:14px;"> You are not authorized to access this link.</p>
	<%
	dbOP.cleanUP();
	return;
	}
 


//end of authenticaion code.

Authentication auth = new Authentication();
Vector vRetResult = null;
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(auth.operateOnSUModuleRestriction(dbOP,request, Integer.parseInt(strTemp)) != null )
		strErrMsg = "Successful";
	else
		strErrMsg = auth.getErrMsg();
}

vRetResult = auth.operateOnSUModuleRestriction(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null) {
	strErrMsg = auth.getErrMsg();
}


%>
<form name="form_" action="./manage_sys_ad_modules.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          SYSTEM ADMIN MODULE ASSIGNMENT ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="28" width="1%">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=strErrMsg%></b></font> </td>
    </tr>
    <tr valign="top">
      <td height="25" width="1%">&nbsp;</td>
      <td width="15%">SysAd ID </td>
      <td width="22%">
	  <select name="sys_id" onChange="ReloadPage();">
	  	<option value="">Select A System Admin</option>
		<%=dbOP.loadCombo("distinct user_table.id_number","lname, fname"," from SYSAD_MANAGE_USER  join user_table on (user_index = SYSAD_USER_INDEX) where USER_INDEX_TO_MANAGE is not null order by lname, fname", WI.fillTextValue("sys_id"), false)%>
	  </select>
	  
	  </td>
      <td width="8%">&nbsp;</td>
      <td width="54%"></td>
    </tr>
    <tr valign="top">
      <td height="25">&nbsp;</td>
      <td>Module To  Manage </td>
      <td>
<%if(WI.fillTextValue("sys_id").length() > 0) {%>
	  <select name="module">
		<%=dbOP.loadCombo("MODULE_INDEX","MODULE_NAME"," from MODULE where IS_DEL=0 order by MODULE_NAME asc", WI.fillTextValue("module"), false)%>
	  </select>
<%}%>
	  </td>
      <td><input name="image" type="image" onClick="PageAction('1','');" src="../../../images/save.gif"></td>
      <td>&nbsp;</td>
    </tr>
  </table>
 <%if(vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#CCCCCC">
      <td height="25" colspan="4" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">LIST OF MODULES : <font color="#FF0000"><%=WI.fillTextValue("sys_id")%></font> CAN MANAGE</td>
    </tr>
    <tr style="font-weight:bold" align="center" bgcolor="#FFFFCC">
      <td class="thinborder" height="25" style="font-size:9px;" width="25%">Module Name/td>
      <td class="thinborder" style="font-size:9px;" width="15%">DELETE</td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 2){%>
    <tr>
      <td class="thinborder" height="25" style="font-size:9px;">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 1), "ALL")%></td>
      <td class="thinborder" style="font-size:9px;" align="center"><a href="javascript:PageAction('0', <%=vRetResult.elementAt(i)%>)"><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
<%}%>
  </table>	
 <%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" align="center">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="page_action">
 <input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
