<%@ page language="java" import="utility.*,purchasing.PO,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function ShowData(){	
    document.form_.show_data.value = "1";	
	document.form_.page_action.value = "";
 	document.form_.submit();
}
function checkAllSaveItems() {
	var maxDisp = document.form_.max_count.value;
	var bolIsSelAll = document.form_.selAllSaveItems.checked;
	var obj;
	for(var i =0; i< maxDisp; ++i) {
		eval('obj = document.form_.save_'+i);
		obj.checked = bolIsSelAll;
	}
}
function ViewItem(strPONumber){
	var pgLoc = "purchase_request_view.jsp?req_no="+escape(strPONumber)+"+&isForPO=1";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PageAction(strAction){
	document.form_.page_action.value = strAction;
	document.form_.show_data.value = "1";	
	document.form_.submit();
}
function UpdateCheckBox(objSelect, objCheckbox) {
	if(objSelect.selectedIndex > 0) 
		objCheckbox.checked = true;
	else	
		objCheckbox.checked = false;
}
</script>
<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-UPDATE PO STATUS-Update PO Status Batch","purchase_request_update_status_batch.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.

	int iAccessLevel = 0;//-1 = logged out., 0 = not authorized, 1 = authorized.
	String strSQLQuery = null;
	if(request.getSession(false).getAttribute("userIndex") != null) {
		String strMainIndex = "select module_index from module where module_name = 'purchasing'";
		strMainIndex = dbOP.getResultOfAQuery(strMainIndex, 0);
		strSQLQuery = "select sub_mod_index from sub_module where module_index = "+strMainIndex+
						" and sub_mod_name = 'Final Approval of PO'";
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery != null) {
			strSQLQuery = "select auth_list_index from user_auth_list where is_valid = 1 and sub_mod_index = "+
							strSQLQuery+" and user_index = "+(String)request.getSession(false).getAttribute("userIndex");
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strSQLQuery != null)
				iAccessLevel = 1;
		}
	}
	else
		iAccessLevel = -1;
	//iAccessLevel = 1;
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are not authorized to view this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	

PO po = new PO();
Vector vRetResult = null;


if(WI.fillTextValue("page_action").length() > 0) {
	po.operateOnReqStatusPOBatch(dbOP, request, 1);
	strErrMsg = po.getErrMsg();
}
///get still pending. 
vRetResult = po.operateOnReqStatusPOBatch(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null) {
	strErrMsg = po.getErrMsg();
}	

%>
<form name="form_" method="post" action="./purchase_request_update_status_batch.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          REQUISITION : UPDATE  REQUISITION STATUS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="19%">PO No. : </td>
      <td width="78%"><input type="text" name="po_number" class="textbox" value="<%=WI.fillTextValue("po_number")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>PO Prepared Date:</td>
      <td>From:&nbsp; <input name="po_date_fr" type="text" value="<%=WI.fillTextValue("po_date_fr")%>" size="12" readonly="yes"  class="textbox"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.po_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        To:&nbsp; <input name="po_date_to" value="<%=WI.fillTextValue("po_date_to")%>" type="text" class="textbox" size="12" readonly="yes"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.po_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    
    <tr>
        <td height="25">&nbsp;</td>
        <td>&nbsp;</td>
        <td><a href="javascript:ShowData();"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
  </table>
	
  
<%if(vRetResult != null && vRetResult.size() > 0){
String[] astrReqStatus = {"Disapproved","Approved"};	
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
	  <td width="5%" align="center" class="thinborder"><strong style="font-size:10px;">COUNT</strong></td>
		<td width="10%" height="25" align="center" class="thinborder"><strong style="font-size:10px;">PO # </strong></td>
		<td width="10%" align="center" class="thinborder"><strong style="font-size:10px;">PO Prepared Date </strong></td>
		<td width="8%" align="center" class="thinborder"><strong style="font-size:10px;">Requested College/Dept </strong></td>
		<td width="10%" align="center" class="thinborder"><strong style="font-size:10px;">Requested By </strong></td>
		<td width="10%" align="center" class="thinborder"><strong style="font-size:10px;">Purpose</strong></td>
		<td width="10%" align="center" class="thinborder"><strong style="font-size:10px;">First Level Approved Date</strong></td>
		<td width="10%" align="center" class="thinborder"><strong style="font-size:10px;">First Level Approved By</strong></td>
		<td width="8%" align="center" class="thinborder"><strong style="font-size:10px;">Update Status </strong></td>
		<td width="10%" align="center" class="thinborder"><strong style="font-size:10px;">Date Updated </strong></td>
		<td width="5%" align="center" class="thinborder"><strong style="font-size:10px;">View PO Detail </strong></td>
		<td width="5%" align="center" class="thinborder"><strong style="font-size:10px;">Select<br />All<br /></strong>
			<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();"></td>
	</tr>
	<%
	int iCount = 0;
	for(int i = 0 ; i < vRetResult.size() ; i+=10, ++iCount){
		strTemp = WI.getStrValue(vRetResult.elementAt(i+3));
		if(vRetResult.elementAt(i+4) != null) {
			if(strTemp.length() > 0) 
				strTemp += "/ ";
			strTemp += vRetResult.elementAt(i+4);
		}
	%>
	 <tr>
	   <td class="thinborder"><%=iCount + 1%></td>
	 	<td class="thinborder" height="20"><%=vRetResult.elementAt(i+1)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i+2)%></td>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+6),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+5),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+7),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+8),"&nbsp;")%></td>
		<td class="thinborder">
		<select name="status_<%=iCount%>" onChange="UpdateCheckBox(document.form_.status_<%=iCount%>, document.form_.save_<%=iCount%>);">
		<option value=""></option>
		<%
		for(int x = 0;x < astrReqStatus.length; x++){
		%>
          <option value="<%=x%>"><%=astrReqStatus[x]%></option>		
		<%}%>
        </select>		</td>
		<td class="thinborder" align="center">
<%
strTemp = WI.fillTextValue("date_updated_"+iCount);
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
		 <input name="date_updated_<%=iCount%>" type="text" size="10" maxlength="10" readonly="yes"  class="textbox" value="<%=strTemp%>"
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_updated_<%=iCount%>');" title="Click to select date" 
			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>		</td>
		<td class="thinborder" align="center">
		<a href="javascript:ViewItem('<%=vRetResult.elementAt(i+1)%>')"><img src="../../../images/view.gif" border="0"></a>		</td>
		<td class="thinborder" align="center">
		<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1">		</td>
	 </tr>
	<%}%>
	<input type="hidden" name="max_count" value="<%=iCount%>">
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td align="center">
	<a href="javascript:PageAction('1');"><img src="../../../images/save.gif" border="0"></a>
	<font size="1">Click to finalize requisition status.</font>
	</td></tr>
</table>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr><td width="4%" height="25" colspan="8">&nbsp;</td></tr>
<tr bgcolor="#B8CDD1"><td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
  <input type="hidden" name="show_data">
  <input type="hidden"  name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>