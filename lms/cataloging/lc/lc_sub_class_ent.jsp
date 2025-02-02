<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>General Category Create</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>

</head>
<script src="../../../jscript/common.js"></script>
<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce('form_');
}
function ReloadPageGC() {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.SUB_CATG_INDEX.selectedIndex =0;
	this.SubmitOnce('form_');
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function CancelOperation() {
	document.form_.SUB_CATG_ENTRY.value = "";
	document.form_.lc_range1.value = "";
	document.form_.lc_range2.value = "";
	this.ReloadPage();
}
</script>

<%@ page language="java" import="utility.*,lms.CatalogDDC,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-DDC-sub-class","lc_sub_class_ent.jsp");
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
														"LIB_Cataloging","DDC NUMBERS",request.getRemoteAddr(),
														"lc_sub_class_ent.jsp");
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

	CatalogDDC ctlgDDC = new CatalogDDC();
	Vector vEditInfo  = null;Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(ctlgDDC.operateOnSubCatgEntry(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = ctlgDDC.getErrMsg();
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "LC General sub-class entry information successfully removed.";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "LC General sub-class entry information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "LC General sub-class entry information successfully edited.";

			strPrepareToEdit = "0";
		}
	}

	
//get vEditInfoIf it is called.
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = ctlgDDC.operateOnSubCatgEntry(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = ctlgDDC.getErrMsg();
}
//view all. 
if(WI.fillTextValue("GEN_CATG_INDEX").length() > 0 && WI.fillTextValue("SUB_CATG_INDEX").length() > 0) {
	vRetResult = ctlgDDC.operateOnSubCatgEntry(dbOP, request,4);
	if(vRetResult == null && strErrMsg == null) 
		strErrMsg = ctlgDDC.getErrMsg();
}
%>

<body bgcolor="#DEC9CC">
<form action="./lc_sub_class_ent.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#A8A8D5">
    <tr>
      <td height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          LC CREATE : SUB-CLASS ENTRY PAGE :::: </strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="2"> <a href="lc_main.htm"><img src="../../images/go_back.gif" border="0"></a>&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;&nbsp;General Class</td>
      <td><select name="GEN_CATG_INDEX" onChange="ReloadPageGC();">
          <option value="">Select General Class</option>
<%=dbOP.loadCombo("GEN_CATG_INDEX","GEN_CATG +' ::: '+LC_GEN_CODE"," from LMS_DDC_GEN_CATG where is_valid = 1 and is_del = 0 and is_lc = 1 order by RANGE_FR asc",
		  	WI.fillTextValue("GEN_CATG_INDEX"), false)%> </select>
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;Sub-Class</td>
      <td><select name="SUB_CATG_INDEX" onChange="ReloadPage();">
          <option value="">Select sub-class</option>
          <%=dbOP.loadCombo("SUB_CATG_INDEX","SUB_CATG +' ::: '+LC_SUB_CODE"," from LMS_DDC_SUB_CATG WHERE GEN_CATG_INDEX = "+
			  WI.getStrValue(WI.fillTextValue("GEN_CATG_INDEX"),"0")+
			  " and is_valid = 1 and is_del = 0 and is_lc = 1 order by RANGE_FR asc",
		  	WI.fillTextValue("SUB_CATG_INDEX"), false)%> </select>
      </td>
    </tr>
    <tr> 
      <td width="21%" height="25">&nbsp;&nbsp;Sub-Class Entry</td>
      <td width="79%"> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("SUB_CATG_ENTRY");
%> <input type="text" name="SUB_CATG_ENTRY" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="64" maxlength="127"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;&nbsp;Range</td>
      <td>
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("lc_range1");
%>
        <input type="text" name="lc_range1" size="4" maxlength="4" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>">
        to 
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("lc_range2");
%>
        <input type="text" name="lc_range2" size="4" maxlength="4" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>"> 
      </td>
    </tr>
    <%
if(iAccessLevel > 1) {%>
    <tr> 
      <td height="40">&nbsp;</td>
      <td><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0" name="hide_save"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a> 
        Click to edit event <a href="javascript:CancelOperation();"><img src="../../images/cancel.gif" border="0"></a> 
        Click to clear entries 
        <%}%>
        </font></td>
    </tr>
    <%}%>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td height="25" colspan="3" bgcolor="#DDDDEE" class="thinborder"><div align="center"><font color="#FF0000"> 
          <strong>LIST OF EXISTING SUB-CLASS ENTRY</strong></font></div></td>
    </tr>
    <tr> 
      <td width="40%" height="25" class="thinborder"><div align="center"><font size="1"><strong>SUB-CLASS 
          ENTRY NAME</strong></font></div></td>
      <td width="37%" class="thinborder"><div align="center"><font size="1"><strong> 
          RANGE</strong></font></div></td>
      <td class="thinborder" width="23%"><div align="center"><font size="1"><strong>OPTIONS</strong></font></div></td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 5){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" align="center"><%=(String)vRetResult.elementAt(i + 3)%> - <%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"><div align="center"> 
          <%
if(iAccessLevel > 1){%>
          <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/edit.gif" width="53" height="28" border="0"></a> 
          <%}if(iAccessLevel == 2){%>
          <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/delete.gif" width="53" height="26" border="0"></a> 
          <%}%>
          </div></td>
    </tr>
<%}%>
  </table>
<%}//only if vRetResult is not null%>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

<input type="hidden" name="is_lc" value="1">
</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>