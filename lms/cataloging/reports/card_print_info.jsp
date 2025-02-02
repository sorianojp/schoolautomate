<%@ page language="java" import="utility.*,lms.CatalogReport,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm("Are you sure you want to delete this collection."))
			return;
		document.form_.info_index.value = strInfoIndex;
	}
	
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "../../search/search_simple.jsp?opner_info=form_.accession_no&opner_info2=form_.reload_main&opner_info2_val=1";
	var win=window.open(pgLoc,"PrintWindow",'width=950,height=650,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ShowPreview() {
	if(document.form_.show_preview.checked) {
		document.getElementById('preview_lhs').innerHTML = document.form_.lhs_info.value;
		document.getElementById('preview_rhs').innerHTML = document.form_.rhs_info.value;
		location = "#preview_";
	}
	else {
		document.getElementById('preview_lhs').innerHTML = "";
		document.getElementById('preview_rhs').innerHTML = "";
	}
		
}
function PrintCard() {
	var strAccessionNo = document.form_.accession_no.value;
	if(strAccessionNo.length == 0) {
		alert("Please enter accession number.");
		return null;
	}
	var win=window.open("./card_print_info_print.jsp?accession_no="+strAccessionNo,"PrintWindow",'width=950,height=650,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=yes');
}
function UpdateInfo(strAction) {
	var strAccessionNoNEW = document.form_.accession_no.value;
	var strAccessionNoOLD = document.form_.old_accession_no.value;
	
	if(strAccessionNoOLD.length > 0 && strAccessionNoOLD != strAccessionNoNEW) {
		alert('Accession Number changed and Proceed is not click. Click ok to load the page for this access no.');
		document.form_.page_action.value = '';
		document.form_.submit();
	}
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
</script>

<%
	String strErrMsg = null;
	String strTemp   = null;
	
	String strInfoIndex = null;
	String strPageAction = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-Reports-Card Print Info","card_print_info.jsp");
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
														"LIB_Cataloging","REPORTS",request.getRemoteAddr(),
														"card_print_info.jsp");
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


CatalogReport CR   = new CatalogReport();
Vector vRetResult  = null;
Vector vEditInfo   = null;
Vector vNotCreated = null;

boolean bolKeep = false;



strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(CR.operateOnCatalogReportFormat(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = "Operation Successful.";
	else {
		strErrMsg = CR.getErrMsg();	
		bolKeep   = true; // must keep.. 
	}
}
//iAction 3 is never used.. 
if(WI.fillTextValue("accession_no").length() > 0) {
	request.setAttribute("auto_create", "1");
	
	CR.autoCreateCatalogReportFormat(dbOP, request);
		
	vRetResult = CR.operateOnCatalogReportFormat(dbOP, request, 4);
	if(vRetResult != null)
		vNotCreated = (Vector)vRetResult.remove(0);
	else
		strErrMsg = CR.getErrMsg();

	vEditInfo  = CR.operateOnCatalogReportFormat(dbOP, request, 5);
	if(vEditInfo == null)
		strErrMsg = CR.getErrMsg();
}

%>


<body bgcolor="#F2DFD2" onLoad="document.form_.accession_no.focus();">
<form action="./card_print_info.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING : REPORTS - CARD PRINT INFO ::::</strong></font></div></td>
    </tr>
  </table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="30" colspan="5"><a href="main_page.jsp" target="_self"><img src="../../images/go_back_rec.gif" width="54" height="29" border="0"></a>&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td width="3%" height="41">&nbsp;</td>
      <td width="24%" height="41">Book Accession No/ Barcode</td>
      <td width="21%"> <input type="text" name="accession_no" value="<%=WI.fillTextValue("accession_no")%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="20" maxlength="32"> </td>
      <td width="9%">
	  <a href="javascript:OpenSearch();"><img src="../../images/search_recommend.gif" border="1"></a></td>
      <td width="43%">
	  <input type="image" src="../../images/form_proceed.gif" onClick="document.form_.page_action.value='';"></a></td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td height="27" valign="top">Card Type </td>
      <td colspan="3" valign="top">
	  <select name="report_ref" onChange="document.form_.page_action.value='';document.form_.submit();">
<%=dbOP.loadCombo("REPORT_REF_INDEX","REPORT_TYPE"," from LMS_CATALOG_REPORT_REF order by  DISP_ORDER asc",	WI.fillTextValue("report_ref"), false)%> 
	  </select>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
			<div align="right"><a href="javascript:PrintCard();"><img src="../../images/print_recommend.gif" border="0"></a><font size=1>Print Card</font></div>

<%}%>	  </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4" style="font-weight:bold; font-size:9px;">
	  NOTE : For multiple card of same type, insert @pagebreak tag both in left and right side.
	  for example
	  if one card has 2 title cards :: it can be written like this -&gt; 
	  <br>title card 1 details
	  <br>@pagebreak
	  <br>title card 2 details
	  </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" style="font-weight:bold">Left side </td>
      <td height="10" colspan="3"><b>Right Side </b> &nbsp;&nbsp; <input type="checkbox" name="show_preview" onClick="ShowPreview();"> Show Preview</td>
    </tr>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);
else if(bolKeep)	
	strTemp = WI.fillTextValue("lhs_info");
%>
    <tr>
      <td height="10">&nbsp;</td>
      <td valign="top">
	  <textarea name="lhs_info" class="textbox" style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:11px;" rows="6" cols="30"><%=strTemp%></textarea>
	  <br><br><br>
	  <%if(vEditInfo != null && vEditInfo.size() > 0){%>
	  	<input type="button" name="_" value="Update Info" onClick="UpdateInfo('2');">
	  <%}else{%>
	  	
		<input type="button" name="_" value="Save Info" onClick="UpdateInfo('1');"> <br>Entry does not exist .Click Save to record information.
	  <%}%>
	  <br><br>
	  <%if(vNotCreated != null && vNotCreated.size() > 0) {%>
<font color="#FF0000">	  <u>Cards Not yet Created ::</u> 
	  	<%while(vNotCreated.size() > 0) {%>
	  		<br><%=vNotCreated.remove(0)%><%vNotCreated.remove(0);%>
	  	<%}%>
</font>	  
	  <%}%>	  </td>
      <td colspan="3">
<%



if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);
else if(bolKeep)	
	strTemp = WI.fillTextValue("rhs_info");
%>
	  <textarea name="rhs_info" class="textbox" style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:11px;" rows="25" cols="120"><%=strTemp%></textarea></td>
    </tr>
<%
if(vEditInfo != null && vEditInfo.size() > 0) {%>
<input type="hidden" name="info_index" value="<%=vEditInfo.elementAt(0)%>">
<%}else{%>
<input type="hidden" name="info_index" value="">
<%}%>
    <tr>
      <td height="10">&nbsp;</td>
      <td style="font-weight:bold"><a id="preview_">Preview</a></td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" class="thinborderTOPLEFTBOTTOM">&nbsp;</td>
      <td valign="top" class="thinborderTOPBOTTOM"><pre><label id="preview_lhs">&nbsp;</label></pre></td>
      <td colspan="3" valign="top" class="thinborderTOPRIGHTBOTTOM"><pre><label id="preview_rhs">&nbsp;</label></pre></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="28" colspan="3" align="center" style="font-size:13px; color:#0000FF; font-weight:bold"><u>::: Existing Data :::</u></td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 8){%>
    <tr valign="top"> 
      <td height="22">&nbsp;</td>
      <td style="font-weight:bold"><u><%=vRetResult.elementAt(i + 1)%></u></td>
      <td>&nbsp;
	  <%if(vRetResult.elementAt(i) != null) {%>
	  <a href="javascript:PageAction('0',<%=vRetResult.elementAt(i)%>)">Delete Information</a>
	  <%}%>
	  </td>
    </tr>
    <tr valign="top"> 
      <td height="25">&nbsp;</td>
      <td><pre><%=vRetResult.elementAt(i + 2)%></pre></td>
      <td><pre><%=vRetResult.elementAt(i + 3)%></pre></td>
    </tr>
<%}%>
	<tr>
      <td width="2%">&nbsp;</td>
      <td width="28%">&nbsp;</td>
      <td width="70%">&nbsp;</td>
    </tr>
  </table>
<%}%>
<input type="hidden" name="page_action">
<input type="hidden" name="reload_main" value="1">
<input type="hidden" name="old_accession_no" value="<%=WI.fillTextValue("accession_no")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>