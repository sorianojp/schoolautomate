<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
</head>

<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
		
	if(strAction == 1) 
		document.form_.hide_save.src = "../../../images/blank.gif";
		
	document.form_.submit();
}

function ViewEntries(strView){
	document.form_.view_entries.value = strView;
	
	document.form_.submit();

}

function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function viewList(table,indexname,colname,labelname){
	var loadPg = "../../ADMIN_STAFF/HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + 
	"&colname=" + colname+"&label="+escape(labelname)+"&opner_form_name=form_";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function updateSupplier(){
	var win2=window.open("../acquisition/supplier.jsp","myfile",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win2.focus();
}
</script>

<%@ page language="java" import="utility.*,lms.CatalogLibCol,java.util.Vector" %>
<%

	DBOperation dbOP     = null;
	WebInterface WI      = new WebInterface(request);
	String strErrMsg     = null;
	String strTemp       = null;
	
	String strInfoIndex  = null;
	String strPageAction = null;
	String strBookIndex  = null;
	String strPrepareToEdit = null;
	Vector vEditInfo  = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-LIBRARY COLLECTION","other_entries.jsp");
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
														"LIB_Cataloging","LIBRARY COLLECTION",request.getRemoteAddr(),
														"other_entries.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
strTemp = WI.fillTextValue("view_entries");
if(strTemp.compareTo("1")== 0){ 
	strBookIndex = WI.fillTextValue("ACCESSION_NO");
	strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	
	CatalogLibCol ctlgLibCol = new CatalogLibCol();
	strBookIndex = dbOP.mapBookIDToBookIndex(strBookIndex);
	if(strBookIndex == null) 
		strErrMsg = dbOP.getErrMsg();

	
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0 && strBookIndex != null) {
		if(ctlgLibCol.operateOnOthEntry(dbOP, strBookIndex, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = ctlgLibCol.getErrMsg();
		else {
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Other entry information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Other entry information successfully edited.";
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Other entry information successfully removed.";
		}
	}

	

	if(strBookIndex != null) {
		vEditInfo  = ctlgLibCol.operateOnOthEntry(dbOP, strBookIndex, request,4);
		if(vEditInfo == null && vEditInfo == null && strErrMsg == null)
			strErrMsg = ctlgLibCol.getErrMsg();
	}
}
%>


<body bgcolor="#FAD3E0">
<form action="./other_entries.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#0D3371"> 
      <td height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          ACQUISITION - OTHER ENTRIES PAGE ::::</strong></font></div></td>
    </tr>
  </table>
   
<jsp:include page="./inc.jsp?pgIndex=6"></jsp:include>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr><td colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg,"Message : ","","")%></td></tr>
    <tr valign="middle">
      <td width="96%" height="25">BOOK ACCESSION NUMBER :
	  <input name="ACCESSION_NO" type="text" size="32" maxlength="32" 
	  	value="<%=WI.fillTextValue("ACCESSION_NO")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">&nbsp;
	  <input type="image" src="../images/form_proceed.gif" onClick="document.form_.view_entries.value='1';">
	  </td>
		
    </tr>
  </table>
  
<%
strTemp = WI.fillTextValue("view_entries");
if(strBookIndex != null && strTemp.compareTo("1")==0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      
      <td width="17%" height="30">Project Name</td>
      <td width="16%"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("project");
%>
        <select name="project">
<%=dbOP.loadCombo("OE_PROJ_INDEX","PROJ_NAME"," from LMS_LC_OE_PROJ order by PROJ_NAME asc", strTemp, false)%> 
        </select></td>
      <td width="63%">
	  <a href='javascript:viewList("LMS_LC_OE_PROJ","OE_PROJ_INDEX","PROJ_NAME","Project Name");'>
	  <img src="../images/update_rec.gif" border="1" align="absmiddle"></a></td>
    </tr>
    <tr> 
      
      <td height="30">Funding Source</td>
      <td colspan="2">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("fs_index");
%>	  <select name="fs_index" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11;">
<%=dbOP.loadCombo("FUNDING_SOURCE_INDEX","FS_CODE + ' ('+FS_NAME+')'",
	" from LMS_FS_PROFILE WHERE is_valid = 1 and is_del = 0 and fs_stat = 1 order by fs_code asc", strTemp, false)%> 
      </select>	  </td>
    </tr>
    <tr> 
      
      <td height="30">Acquired/Turn-over Date</td>
      <td colspan="2">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("date_received");
%>	  <input name="date_received" type="text" size="12" readonly="true" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		value="<%=strTemp%>"> 
		
        <a href="javascript:show_calendar('form_.date_received');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../images/calendar_new.gif" border="0"></a>&nbsp;</td>
		
    </tr>
    <tr> 
      
      <td height="30">Series Control No.</td>
      <td colspan="2">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("control");
%>	  <input type="text" name="control" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="24" maxlength="64"></td>
    </tr>
    <tr> 
      
      <td height="30">Book Amount</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("amount");
%>	  <input name="amount" type="text" size="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">      </td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      
      <td height="30">Supplier</td>
      <td colspan="2">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("supplier");
%>	  <select name="supplier" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11; width:600px">
		<option value=""></option>
<%=dbOP.loadCombo("supplier_index","supplier_code + ' ('+supplier_name+')'",
	" from LMS_ACQ_SUPPLIER WHERE is_active = 1 order by supplier_code asc", strTemp, false)%> 
      </select> &nbsp;<a href='javascript:updateSupplier();'><img src="../images/update_rec.gif" border="1" align="absmiddle"></a></td>
    </tr>
    <tr> 
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
  </table>
    <%
if(iAccessLevel > 1) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="4%" height="51">&nbsp;</td>
      <td width="16%" height="51">&nbsp;</td>
      <td width="80%" valign="bottom"><font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../images/save_recommend.gif" border="1" name="hide_save"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../images/edit_recommend.gif" border="1"></a> 
        Click to edit event 
        <%}%>
        <a href="other_entries.jsp?ACCESSION_NO=
		<%=response.encodeRedirectURL(WI.fillTextValue("ACCESSION_NO"))%>"><img src="../images/cancel_recommend.gif" border="1"></a> 
        Click to clear entries </font
        ></td>
    </tr>
  </table>
<%}//if iAccessLevel > 1)
}//if(strBookIndex != null)%>
  
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="view_entries" value="<%=WI.fillTextValue("view_entries")%>">
<input type="hidden" name="load_page">
</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>