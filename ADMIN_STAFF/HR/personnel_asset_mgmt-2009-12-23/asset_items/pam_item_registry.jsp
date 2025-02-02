<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Item Registry</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
a:link {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:visited {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:active {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:hover {
	color:#f00;
	font-weight:700;
	}
.tabFont {
	color:#444444;
	font-weight:700;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
}
</style>
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script src="../../../../jscript/common.js"></script>
<script src="../../../../jscript/date-picker.js"></script>
<script language="javascript">

function AjaxMapAsset() {
	var strAssetCode = document.form_.asset_code.value;
	var objCOAInput = document.getElementById("coa_info");
	if(strAssetCode.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=400&asset_code="+escape(strAssetCode);
 	this.processRequest(strURL);
}
function updateAssetCode(strItemMasterItem, strAssetCode){
	document.form_.item_master_index.value = strItemMasterItem;
	document.form_.asset_code.value = strAssetCode;
	document.getElementById("coa_info").innerHTML = "";
	document.form_.submit();
}

function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length > 0)
		return;

	if(document.form_.close_wnd_called.value == "0" && !document.form_.asset_code)
		window.opener.ReloadPage();
	else
		return;
}

function PrepareToEdit(index){
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = index;
	document.form_.submit();
}

function ReloadPage(){
	document.form_.reloadPage.value="1";
	document.form_.submit();
}

function UpdateSupplier(){
	var sT = "../../../purchasing/supplier/suppliers.jsp";
	var win=window.open(sT,"UpdateSupplier",'dependent=yes,width=700,height=200,top=200,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, 
					strExtraTableCond,strExtraCond,strFormField){
	document.form_.donot_call_close_wnd.value = "1";
	var loadPg = "../../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + 
		"&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
		"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond) + 
		"&extra_cond="+escape(strExtraCond) +
		"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"viewList",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PageAction(strAction, strInfoIndex) {
	document.form_.donot_call_close_wnd.value = "1";
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete this category?'))
			return;
	}
	document.form_.page_action.value = strAction;
	if(strAction == '1') 
		document.form_.prepareToEdit.value='';
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

function CancelRecord(){
	document.form_.donot_call_close_wnd.value = "1";
	location ="./pam_item_registry.jsp?item_master_index="+document.form_.item_master_index.value+"&forwarded="+document.form_.forwarded.value;
}

function FieldFocus(){
	if(document.form_.asset_code)
		document.form_.asset_code.focus();
	else
		document.form_.property_number.focus();
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector, hr.PersonnelAssetManagement" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null; 
	String strInfoIndex = WI.fillTextValue("info_index");
	
	String strItemMasterIndex = WI.fillTextValue("item_master_index");
	
	//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(request.getSession(false).getAttribute("userIndex") == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth != null && svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else if (svhAuth != null)
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR".toUpperCase()),"0"));

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../../../../index.jsp");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
		response.sendRedirect("../../../../commfile/fatal_error.jsp");

	//end of authenticaion code.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR-Personnel Asset Management-Asset Items-Item Registry","pam_item_registry.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	Vector vDetails = null;
	String strPrepareToEdit =  WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	PersonnelAssetManagement pam = new PersonnelAssetManagement();

	String strPageAction = WI.fillTextValue("page_action");
	if(strPageAction.length() > 0){
		if(pam.operateOnRegistryItem(dbOP, request, Integer.parseInt(strPageAction)) == null){
			strErrMsg = pam.getErrMsg();
		} else {
			if(strPageAction.equals("0"))
				strErrMsg = " Registry item removed successfully";
			if(strPageAction.equals("1"))
				strErrMsg = " Registry item recorded successfully";
			if(strPageAction.equals("2"))
				strErrMsg = " Registry item updated successfully";
				
			strPrepareToEdit = "0";
		}
	}
	vRetResult = pam.operateOnRegistryItem(dbOP, request, 4);
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = pam.operateOnRegistryItem(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = pam.getErrMsg();
	}
	
	vDetails = pam.getItemDetails(dbOP, request);
	if(vDetails == null)
		strErrMsg  = pam.getErrMsg();
	
%>
<body bgcolor="#D2AE72" onLoad="FieldFocus();" onUnload="ReloadParentWnd();">
<form action="./pam_item_registry.jsp" method="post" name="form_">
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center">
				<font color="#FFFFFF" ><strong>:::: PERSONNEL ASSET MANAGEMENT : ITEM REGISTRY PAGE ::::</strong></font>			</td>
		</tr>
		<tr>
			<td height="10">&nbsp;</td>
		</tr>
		<%if(WI.fillTextValue("forwarded").length() == 0){%>
		<tr> 
			<td><a href="../pam_main.jsp" ><img src="../../../../images/go_back.gif" border="0" align="right"></a></td>
		</tr>
		<%}%>
	</table>

    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="FFFFFF">
      <tr>
        <td width="15%">&nbsp;</td>
        <td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
      </tr>
      <tr>
        <td colspan="4">&nbsp;</td>
      </tr>
	  <%if(WI.fillTextValue("forwarded").length() == 0){%>
	  <tr>
        <td>Asset Code: </td>
        <td width="34%">
			<input name="asset_code" type="text" size="30" value="<%=WI.fillTextValue("asset_code")%>" class="textbox"
				onKeyUp="AjaxMapAsset();" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="16"></td>
        <td colspan="2"><label id="coa_info"></label></td>
      </tr>
	  <%}%>
	  <tr>
        <td colspan="4">&nbsp;</td>
      </tr>
<%if(vDetails!=null && vDetails.size() > 0){%>
      <tr>
        <td height="25">Category:</td>
        <td><%=(String)vDetails.elementAt(0)%></td>
        <td width="15%">Description/Name:</td>
        <td width="36%"><%=(String)vDetails.elementAt(3)%></td>
      </tr>
      <tr>
        <td height="25">Classification:</td>
        <td><%=(String)vDetails.elementAt(1)%></td>
        <td>Asset Unit: </td>
        <td><%=(String)vDetails.elementAt(4)%></td>
      </tr>
      <tr>
        <td height="25">Brand:</td>
        <td><%=(String)vDetails.elementAt(2)%></td>
        <td colspan="2">&nbsp;</td>
      </tr>
<%}%>
	  <tr>
        <td colspan="4">&nbsp;</td>
      </tr>
      <tr>
        <td height="25">Property No. </td>
		<% 	
			if (vEditInfo != null) 
				strTemp = (String)vEditInfo.elementAt(1);
			else
				strTemp = WI.fillTextValue("property_number"); 
		%>
        <td>
			<input name="property_number" type="text" size="30" value="<%=strTemp%>" class="textbox"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="16">		</td>
        <td>Warranty Until*</td>
		<%
			//place here the index of vEditInfo that would serve as reference to the seminar date
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = WI.getStrValue((String)vEditInfo.elementAt(4), "");
			else
				strTemp = WI.fillTextValue("date_fr");
			strTemp = WI.getStrValue(strTemp,"");
		%>
        <td><input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp; <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../../images/calendar_new.gif" border="0"></a></td>
      </tr>
      <tr>
        <td height="25">Serial No.*</td>
		<% 	
			if (vEditInfo != null) 
				strTemp = WI.getStrValue((String)vEditInfo.elementAt(2), "");
			else
				strTemp = WI.fillTextValue("serial_number"); 
		%>
        <td>
			<input name="serial_number" type="text" size="30" value="<%=strTemp%>" class="textbox"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="24">		</td>
        <td>Log Date </td>
		<%
			//place here the index of vEditInfo that would serve as reference to the seminar date
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(10);
			else{
				strTemp = WI.fillTextValue("log_date");
				if(strTemp.length() == 0) 
					strTemp = WI.getTodaysDate(1);
			}
		%>
        <td><input name="log_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp; <a href="javascript:show_calendar('form_.log_date');" title="Click to select date" 
			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../../images/calendar_new.gif" border="0"></a></td>
      </tr>
	  <tr>
        <td height="25">Product No.*</td>
		<% 	
			if (vEditInfo != null) 
				strTemp = WI.getStrValue((String)vEditInfo.elementAt(3), "");
			else
				strTemp = WI.fillTextValue("product_number"); 
		%>
        <td>
			<input name="product_number" type="text" size="30" value="<%=strTemp%>" class="textbox"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="24">		</td>
        <td>Supplier*</td>
		<% 	
			if (vEditInfo != null) 
				strTemp = (String)vEditInfo.elementAt(5);
			else
				strTemp = WI.fillTextValue("supplier"); 
		%>
        <td>
		<select name="supplier">
          <option value="">Select Supplier</option>
          <%=dbOP.loadCombo("profile_index","supplier_name"," from pur_supplier_profile where is_del = 0 order by supplier_name",strTemp,false)%>
        </select>
          <a href="javascript:UpdateSupplier();"><img src="../../../../images/update.gif" border="0"></a></td>
	  </tr>
	  <tr>
        <td height="25">Price</td>
		<% 	
			if (vEditInfo != null) 
				strTemp = (String)vEditInfo.elementAt(9);
			else
				strTemp = WI.fillTextValue("price"); 
		%>
        <td><input name="price" type="text" size="30" value="<%=strTemp%>" class="textbox"
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','price');style.backgroundColor='white'" maxlength="24"></td>
        <td>Status</td>
		<% 	
			if (vEditInfo != null) 
				strTemp = (String)vEditInfo.elementAt(7);
			else
				strTemp = WI.fillTextValue("price"); 
		%>
        <td><select name="status">
          <option value="">Select Status</option>
          <%=dbOP.loadCombo("inv_stat_index","inv_status"," from inv_preload_status order by inv_status",strTemp,false)%>
        </select>
          <a href='javascript:viewList("inv_preload_status","inv_stat_index","inv_status","STATUS","hr_pam_item_registry",
		  	"item_registry_index", " and hr_pam_item_registry.is_valid = 1","","status")'> <img src="../../../../images/update.gif" border="0"></a></td>
	  </tr>
	  <tr>
        <td height="25" colspan="4">&nbsp;</td>
      </tr>
      <tr>
        <td height="25">&nbsp;</td>
        <td>
        <% if (iAccessLevel > 1){
			if (vEditInfo  == null){%>        
        		<a href="javascript:PageAction('1','');"><img src="../../../../images/save.gif" border="0" name="hide_save"></a> 
				<a href='javascript:CancelRecord()'><img src="../../../../images/refresh.gif" border="0"></a>
        	<%}else{ %>        
				<a href="javascript:PageAction('2','<%=(String)vEditInfo.elementAt(0)%>');"><img src="../../../../images/edit.gif" border="0"></a>
				<a href='javascript:CancelRecord()'><img src="../../../../images/cancel.gif" border="0"></a>
				<%} // end else vEdit Info == null
		  } // end iAccessLevel  > 1%>		</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr> 
      <tr>
        <td colspan="4">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="4">&nbsp;</td>
      </tr>
    </table>
 <%if(vRetResult != null && vRetResult.size() > 0) {%>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  		<tr bgcolor="#B9B292">
    		<td height="28" colspan="9" align="center" class="thinborder"><b>:: REGISTRY ITEMS LIST:: </b></td>
    	</tr>
  		<tr>
    		<td width="11%" height="25" align="center" class="thinborder"><strong>PROPERTY NO. </strong></td>
    		<td width="11%" align="center" class="thinborder"><strong>SERIAL NO. </strong></td>
			<td width="11%" align="center" class="thinborder"><strong>PRODUCT NO. </strong></td>
    		<td width="10%" align="center" class="thinborder"><strong>WARRANTY UNTIL </strong></td>
			<td width="11%" align="center" class="thinborder"><strong>SUPPLIER </strong></td>
    		<td width="11%" align="center" class="thinborder"><strong>STATUS </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>PRICE </strong></td>
    		<td width="10%" align="center" class="thinborder"><strong>LOG DATE</strong></td>
    		<td width="15%" align="center" class="thinborder"><strong>OPTIONS</strong></td>
  		</tr>
	<%for(int i =0; i < vRetResult.size(); i += 11){%>
  	<tr>
    <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%>&nbsp;</td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 2),"")%>&nbsp;</td>
	<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"")%>&nbsp;</td>
	<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 4),"")%>&nbsp;</td>
	<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%>&nbsp;</td>
	<td class="thinborder"><%=(String)vRetResult.elementAt(i + 8)%></td>
	<td class="thinborder"><%=(String)vRetResult.elementAt(i + 9)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 10)%></td>
    <td align="center" class="thinborder">
		<%  if (iAccessLevel > 1){%>
		  <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../../images/edit.gif" width="40" height="26" border="0"></a>
		<%}    
		if ( iAccessLevel == 2) {%> 
		<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../../images/delete.gif"  border="0"></a> 
        <%}%> </td>
    </td>
  </tr>
<%}%>
</table>
<%}//if vRetResult is not null%>

<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="1" height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#0D3371">
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>">  	
<input type="hidden" name="close_wnd_called" value="0">
<input type="hidden" name="donot_call_close_wnd">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="item_master_index" value="<%=strItemMasterIndex%>">
<input type="hidden" name="forwarded" value="<%=WI.fillTextValue("forwarded")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
