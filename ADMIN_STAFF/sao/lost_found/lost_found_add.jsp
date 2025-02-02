<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function AddRecord(){
	document.form_.page_action.value="1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}

function EditRecord(){

	document.form_.page_action.value="2";
	document.form_.submit();
}

function DeleteRecord(){
	document.form_.page_action.value="0";

}

function viewList(table,indexname,colname,labelname){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname +
	"&colname=" + colname+"&label="+labelname+"&opner_form_name=form_";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function CancelRecord(strEmpID){
	location = "./lost_found_viewall.jsp";
}

function FocusID() {
	document.form_.reference_no.focus();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
function OpenSearch(strField) {
	var pgLoc = "./lost_found_viewall.jsp?opner_info=form_."+strField;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>

<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.LostFound"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-Lost & Found","lost_found_add.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs","Lost & Found",request.getRemoteAddr(),
														"lost_found_add.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
Vector vRetResult = new Vector();//It has all information.
String strCaseType = WI.getStrValue(WI.fillTextValue("case_type"), "1");
String strInfoIndex = request.getParameter("info_index");
boolean bolNoRecord = false;//if it has record, i have to show edit information.

LostFound LF = new LostFound();

strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(LF.operateOnLostFoundClaimItem(Integer.parseInt(strCaseType),dbOP,
			request,Integer.parseInt(strTemp), null) == null)
			strErrMsg = LF.getErrMsg();
		else
			strErrMsg = "OPeration Successful.";
	}
	//get here vRetResult information.
	vRetResult = LF.operateOnLostFoundClaimItem(Integer.parseInt(strCaseType),dbOP, request,3, null);
	if(vRetResult == null)
		strErrMsg = LF.getErrMsg();

if (vRetResult == null || vRetResult.size() < 1){
	bolNoRecord = true;
}
%>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<form action="./lost_found_add.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>::::
          LOST &amp; FOUND - ADD/CREATE PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="30">&nbsp;</td>
      <td height="30" valign="bottom">Case type </td>
      <td height="30" valign="bottom"><select name="case_type" onChange="ReloadPage();">
          <%
strTemp = WI.fillTextValue("case_type");
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Lost</option>
          <%}else{%>
          <option value="1">Lost</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Found</option>
          <%}else{%>
          <option value="2">Found</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>Claimed</option>
          <%}else{%>
          <option value="3">Claimed</option>
          <%}%>
        </select></td>
      <td height="30" valign="bottom">
	  <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
	  </td>
    </tr>
    <tr>
      <td height="15">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<%
if(strCaseType.compareTo("3") != 0){//show if this is not for Claimed ITEM.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3" bgcolor="#cac3a3" align="center"><strong>DETAIL
        OF LOST/FOUND ITEM</strong></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td height="30">Reference #</td>
      <td>
<%
if(LF.strRefNo != null)
	strTemp = LF.strRefNo;
else	
	strTemp = WI.fillTextValue("reference_no");
%>
	  <input name="reference_no" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=strTemp%>">&nbsp;<a href="javascript:OpenSearch('reference_no');"><img src="../../../images/search.gif" border="0"></a></td>
    </tr>
    <tr>
      <td width="3%" height="30">&nbsp;</td>
      <td width="19%" height="30" valign="bottom">Item Category </td>
      <td width="78%" valign="bottom">
<%
if(!bolNoRecord)
	strTemp = (String)vRetResult.elementAt(10);
else
	strTemp = WI.fillTextValue("item_index");
%>
 <select name="item_index">
          <%=dbOP.loadCombo("ITEM_INDEX","ITEM_NAME"," FROM OSA_PRELOAD_LF_ITEM ",strTemp,false)%> </select> <strong> <a href='javascript:viewList("OSA_PRELOAD_LF_ITEM","ITEM_INDEX","ITEM_NAME","LOST-FOUND ITEM")'><img src="../../../images/update.gif" border="0"></a>
        </strong><font size="1">&nbsp;</font><font size="1">click to update list
        of Item Category</font></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td height="30">Item Description</td>
      <td>
<%
if(!bolNoRecord)
	strTemp = (String)vRetResult.elementAt(3);
else
	strTemp = WI.fillTextValue("item_desc");
%>
	  <textarea name="item_desc" cols="30" rows="2" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea>
      </td>
    </tr>
    <tr>
      <td height="25" colspan="3"><div align="left">
          <hr size="1">
        </div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom">Date Reported : <font size="1">
<%
if(!bolNoRecord)
	strTemp = (String)vRetResult.elementAt(4);
else
	strTemp = WI.fillTextValue("date_reported");
%>
        <input name="date_reported" type="text" value="<%=strTemp%>" size="15" readonly="true" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
        <a href="javascript:show_calendar('form_.date_reported');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom">Reported by (ID or NAME)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">
<%
strErrMsg = null;
if(!bolNoRecord) {
	strTemp = (String)vRetResult.elementAt(5);
	if(strTemp != null)
		strErrMsg = "checked";
	else {
		strErrMsg = "";
		strTemp = (String)vRetResult.elementAt(6);
	}
}
else
	strTemp = WI.fillTextValue("reported_by");

if(strErrMsg == null) {
	if(WI.fillTextValue("is_id").compareTo("1") ==0 )
		strErrMsg = " checked";
	else
		strErrMsg = "";
}
%>
 <input name="reported_by" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="32">

         <input type="checkbox" name="is_id" value="1" <%=strErrMsg%>>
        Check if this is ID(if does not belong to the school enter Name)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom">Contact Number (or Email) of person reporting
        :
<%
if(!bolNoRecord)
	strTemp = (String)vRetResult.elementAt(8);
else
	strTemp = WI.fillTextValue("contact_no");
%> <input name="contact_no" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="32"></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="19%" valign="bottom">Location </td>
      <td width="78%" valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">
<%
if(!bolNoRecord)
	strTemp = (String)vRetResult.elementAt(7);
else
	strTemp = WI.fillTextValue("location");
%>	   <textarea name="location" cols="50" rows="2" id="textarea" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" class="textbox"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;
<%if(!bolNoRecord){%>
	<input type="hidden" name="info_index" value="<%=(String)vRetResult.elementAt(0)%>">
<%}%>
	  </td>
    </tr>
  </table>
 <%}//end of case type 1 or 2
 else{
 Vector vLostItemInfo = null;
 Vector vFoundItemInfo = null;
 if(WI.fillTextValue("reference_no").length() > 0 && WI.fillTextValue("case_type").compareTo("3") ==0) {
 	vLostItemInfo = LF.operateOnLostFoundClaimItem(1,dbOP, request,3, WI.fillTextValue("reference_no"));//Lost Item.
	if(vLostItemInfo == null)
		strErrMsg = LF.getErrMsg();
 }
 if(WI.fillTextValue("reference_no2").length() > 0) {
 	vFoundItemInfo = LF.operateOnLostFoundClaimItem(2,dbOP, request,3, WI.fillTextValue("reference_no2"));//Lost Item.
	if(vFoundItemInfo == null)
		strErrMsg = LF.getErrMsg();
 }
 %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3" bgcolor="#cac3a3" align="center"><strong>DETAIL
        OF CLAIM ITEM</strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="bottom">LOST ITEM REFERENCE #</td>
      <td valign="bottom">FOUND ITEM REFERENCE #</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="bottom">
	  <input name="reference_no" type="text" class="textbox"
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			value="<%=WI.fillTextValue("reference_no")%>">&nbsp;<a href="javascript:OpenSearch('reference_no');"><img src="../../../images/search.gif" border="0"></a></td>
      <td valign="bottom"><input name="reference_no2" type="text" class="textbox" id="reference_no6"
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			value="<%=WI.fillTextValue("reference_no2")%>">&nbsp;<a href="javascript:OpenSearch('reference_no2');"><img src="../../../images/search.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="bottom">
<%if(vLostItemInfo != null && vLostItemInfo.size() > 0){%>
	  <table width="100%" cellpadding="1" cellspacing="0" border="1" bordercolor="black">
          <tr>
            <td colspan="2" align="center">
<input type="hidden" name="lost_index" value="<%=(String)vLostItemInfo.elementAt(0)%>">
			LOST ITEM INFORMATION</td>
          </tr>
          <tr>
            <td width="38%"><font size="1">Reported By : </font></td>
            <td width="62%"> <%
strTemp = (String)vLostItemInfo.elementAt(6)+
	WI.getStrValue((String)vLostItemInfo.elementAt(5), " (",")", "&nbsp;");
%> 				<font size="1"><%=strTemp%></font> </td>
          </tr>
          <tr>
            <td><font size="1">Reported Date:</font></td>
            <td><font size="1"><%=WI.getStrValue(vLostItemInfo.elementAt(4))%></font></td>
          </tr>
          <tr>
            <td><font size="1">Item:</font></td>
            <td><font size="1"><%=WI.getStrValue(vLostItemInfo.elementAt(1))%></font></td>
          </tr>
          <tr>
            <td><font size="1">Item Desc:</font></td>
            <td><font size="1"><%=WI.getStrValue(vLostItemInfo.elementAt(3))%></font></td>
          </tr>
        </table>
<%}//only vLostItemInfo is not null.%>		</td>
      <td valign="bottom">
<%if(vFoundItemInfo != null && vFoundItemInfo.size() > 0){%>
	  <table width="100%" cellpadding="1" cellspacing="0" border="1" bordercolor="black">
          <tr>
            <td colspan="2" align="center">
<input type="hidden" name="found_index" value="<%=(String)vFoundItemInfo.elementAt(0)%>">
			FOUND ITEM INFORMATION</td>
          </tr>
          <tr>
            <td width="38%"><font size="1">Reported By : </font></td>
            <td width="62%"> <%
strTemp = (String)vFoundItemInfo.elementAt(6)+
	WI.getStrValue((String)vFoundItemInfo.elementAt(5), " (",")","&nbsp;");
%> 			<font size="1"><%=strTemp%></font></td>
          </tr>
          <tr>
            <td><font size="1">Reported Date:</font></td>
            <td><font size="1"><%=WI.getStrValue(vFoundItemInfo.elementAt(4))%></font></td>
          </tr>
          <tr>
            <td><font size="1">Item:</font></td>
            <td><font size="1"><%=WI.getStrValue(vFoundItemInfo.elementAt(1))%></font></td>
          </tr>
          <tr>
            <td><font size="1">Item Desc:</font></td>
            <td><font size="1"><%=WI.getStrValue(vFoundItemInfo.elementAt(3))%></font></td>
          </tr>
        </table>
<%}//only vFoundItemInfo is not null.%>	  </td>
    </tr>
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
 <%
 if(vFoundItemInfo != null || vLostItemInfo != null){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom">Date Claimed :
<%
if(!bolNoRecord)
	strTemp = (String)vRetResult.elementAt(5);
else
	strTemp = WI.fillTextValue("claim_date");
%>
         <font size="1">
        <input name="claim_date" type="text" value="<%=strTemp%>" size="15" readonly="true" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
        <a href="javascript:show_calendar('form_.claim_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom">Claimed by (ID or NAME)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">
<%
strErrMsg = null;
if(!bolNoRecord) {
	strTemp = (String)vRetResult.elementAt(6);
	if(strTemp != null)
		strErrMsg = "checked";
	else {
		strErrMsg = "";
		strTemp = (String)vRetResult.elementAt(7);
	}
}
else
	strTemp = WI.fillTextValue("claimed_by");
if(strErrMsg == null) {
	if(WI.fillTextValue("is_id").compareTo("1") ==0 )
		strErrMsg = " checked";
	else
		strErrMsg = "";
}
%>
	  <input name="claimed_by" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="32">
        <input type="checkbox" name="is_id" value="1" <%=strErrMsg%>>
        Check if this is ID(if does not belong to the school enter Name)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom">Contact Number (or Email) of person reporting
        :
<%
if(!bolNoRecord)
	strTemp = (String)vRetResult.elementAt(8);
else
	strTemp = WI.fillTextValue("contact_no");
%>        <input name="contact_no" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="32"></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2" valign="bottom">Supporting document(s)presented upon claiming
        the item</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">
<%
if(!bolNoRecord)
	strTemp = (String)vRetResult.elementAt(9);
else
	strTemp = WI.fillTextValue("claim_proof");
%>	  <textarea name="claim_proof" cols="50" rows="2"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" class="textbox"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="43%">&nbsp;</td>
      <td width="54%">&nbsp;
<%
if(!bolNoRecord){%>
	<input type="hidden" name="info_index" value="<%=(String)vRetResult.elementAt(0)%>">
<%}%>
	  </td>
    </tr>
<%}//show only if vFoundItemInfo or vLostItemInfo is not null
%>
  </table>
  <%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9"><div align="center">
          <div align="center">
            <% if (iAccessLevel > 1){
	if(bolNoRecord) {%>
            <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
            <font size="1">click to save entries&nbsp;
            <%}else{%>
            <a href='javascript:CancelRecord();'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
            to cancel and clear entries</font></font> <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a>
            <font size="1">click to save changes</font>
            <%}
		}//iAccessLevel > 1%>
          </div>
        </div></td>
    </tr>
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" value="">
<%
if(!bolNoRecord)
	strTemp = (String)vRetResult.elementAt(2);
else
	strTemp = WI.fillTextValue("reference_no");
%>
<input type="hidden" name="old_reference_no" value="<%=strTemp%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
