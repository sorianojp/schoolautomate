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
function PrintPg() {
	var win=window.open("./fs_profile_print.jsp","myfile",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

	MgmtCatalog mgmtFS = new MgmtCatalog();
	Vector vEditInfo  = null;Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(mgmtFS.operateOnFSProfile(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = mgmtFS.getErrMsg();
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Funding source information successfully removed.";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Funding source information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Funding source information successfully edited.";

			strPrepareToEdit = "0";
		}
	}

	vRetResult = mgmtFS.operateOnFSProfile(dbOP, request,4);	
	
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = mgmtFS.operateOnFSProfile(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = mgmtFS.getErrMsg();
	}
%>

<body bgcolor="#DEC9CC" onLoad="focusID();">
<form action="./fs_profile.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING MANAGEMENT - FUNDING SOURCE - PROFILES PAGE ::::</strong></font></div></td>
    </tr>
	</table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        </strong></font><font size="1"><a href='fs_main.htm'><img src="../../images/go_back.gif" border="0"></a></font><font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr > 
      <td width="4%" height="25"></td>
      <td width="20%">Funding Source Code</td>
      <td width="76%"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("FS_CODE");
%> <input name="FS_CODE" type="text"  class="textbox" maxlength="16" 
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'" size="16" value="<%=strTemp%>"> 
      </td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">Funding Source Name</td>
      <td height="25"><font size="1"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("FS_NAME");
%>
        <input name="FS_NAME" type="text"  class="textbox" maxlength="48" 
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'" size="48" value="<%=strTemp%>">
        </font
        ></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">Status</td>
      <td height="25"> <select name="FS_STAT">
          <option value="1">Active</option>
          <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("FS_STAT");
if(strTemp.compareTo("0") == 0){%>
          <option value="0" selected>In-active</option>
          <%}else{%>
          <option value="0">In-active</option>
          <%}%>
        </select></td>
    </tr>
    <tr > 
      <td height="15" colspan="3"><hr size="1"></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">Contact Person</td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("CONTACT_NAME");
%>	  <input name="CONTACT_NAME" type="text" class="textbox" maxlength="64" 
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'" size="48" value="<%=WI.getStrValue(strTemp)%>"></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">Contact Nos.</td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("CONTACT_NO");
%>	  <input name="CONTACT_NO" type="text" class="textbox" maxlength="64" 
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'" size="48" value="<%=WI.getStrValue(strTemp)%>"></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25" valign="top">Remarks</td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("REMARK");
%>	  <textarea name="REMARK" cols="48" rows="3" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
    <%
if(iAccessLevel > 1) {%>
    <tr > 
      <td height="40">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="bottom"><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="./fs_profile.jsp"><img src="../../images/cancel.gif" border="0"></a> 
        Click to clear entries</font> </td>
    </tr>
    <%}%>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0) {%>
  <div align="right"></div>
  <table width="100%" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="7" class="thinborder" align="right">
	  <a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0"></a><font size="1">click to print list</font> </td>
    </tr>
    <tr> 
      <td height="25" colspan="7" bgcolor="#DDDDEE" class="thinborder"><div align="center">LIST 
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
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>OPTIONS</strong></font></div></td>
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
      <td class="thinborder"> 
        <%
if(iAccessLevel > 1){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/edit.gif" width="45" height="22" border="0"></a> 
        <%}if(iAccessLevel == 2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'>
		<img src="../../images/delete.gif" width="40" height="25" border="0"></a> 
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