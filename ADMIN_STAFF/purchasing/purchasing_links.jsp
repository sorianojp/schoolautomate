<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>EDTR links</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/regmainlinkcss.css" rel="stylesheet" type="text/css">
<link href="../../css/treelinkcss.css" rel="stylesheet" type="text/css">


<SCRIPT LANGUAGE="JavaScript" SRC="../../jscript/common.js"></script>

<script language="JavaScript" type="text/JavaScript">
<!--
function CallFullScreDTR()
{
	//expandingWindow("./dtr.jsp");
	fullScreen("./dtr.jsp");
	return;
}
function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}
//-->
</script>
<link href="../../css/regmainlinkcss.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<body bgcolor="#C39E60" onLoad="MM_preloadImages('../../images/home_small_admin_rollover.gif','../../images/help_small_admin_rollover.gif','../../images/logout_admin_rollover.gif')">
<style>

.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
</style>
<script language="JavaScript">
var openImg = new Image();
openImg.src = "../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../images/box_with_plus.gif";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else
		objBranch.display="block";
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('box_with_plus.gif')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
}
</script>
	
<form name="form_" action="../../commfile/logout.jsp" method="post" target="_parent">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="8%" height="19" bgcolor="#E9E0D1">&nbsp;</td>
    <td width="92%" bgcolor="#E9E0D1">
	<a href="../main%20files/admin_staff_home_button_content.htm" target="_parent" onMouseOver="MM_swapImage('Image2','','../../images/home_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><input type="image" src="../../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3"></a></td>
  </tr>
  </table>
<input type="hidden" name="logout_url" value="../ADMIN_STAFF/main%20files/admin_staff_bottom_content.htm">
<input type="hidden" name="body_color" value="#C39E60">
</form>
<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
//check if user is logged in, if logged, check authentication list here and allow the authentic user to access the system.
DBOperation dbOP = null;
CommonUtil comUtil = new CommonUtil();
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strErrMsg = null;
boolean bolGrantAll = false;
boolean isAuthorized = false;
if(strUserId != null)
{
	//open dbConnection here to check if user is registered already.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		strErrMsg = "error in opening connection.";
	}

	if(strErrMsg == null)
	{
		//check here the authentication of the user.
		if(comUtil.IsSuperUser(dbOP,strUserId))
			bolGrantAll = true;	//grant all ;-)
	}
}
else
	strErrMsg = "";

//Another way of checking authorization.. 
Vector vAuthList = null;
if(!bolGrantAll) {
	vAuthList = comUtil.getAuthModSubModNameList(dbOP, strUserId, "PURCHASING");
	if(vAuthList == null)
		vAuthList = new Vector();
	else if( ((String)vAuthList.elementAt(0)).compareTo("#ALL#") == 0)
		bolGrantAll = true;
}
String strSchCode = dbOP.getSchoolIndex();	
boolean bolIsEAC = strSchCode.startsWith("EAC");

boolean bolIs2ndLevelApprovalRequisition = false;
boolean bolIs2ndLevelApprovalPO          = false;

boolean bolShowUpdateRequisitionStatFinalApproval = false;//for the schools having 2nd level approval of requisition
boolean bolShowUpdatePOStatFinalApproval = false;//for the schools having 2nd level approval of requisition

String strSQLQuery = "select prop_val from read_property_file where prop_name = 'ENABLE_2ND_APPROVAL_PO'";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null) {
	if(strSQLQuery.equals("1") || strSQLQuery.equals("3"))
		bolIs2ndLevelApprovalRequisition = true;
	if(strSQLQuery.equals("2") || strSQLQuery.equals("3"))
		bolIs2ndLevelApprovalPO = true;
} 
if(bolIs2ndLevelApprovalRequisition || 	bolIs2ndLevelApprovalPO) {
	//I have to check if user is authenticated to view final approval of po and requisition
	String strMainIndex = "select module_index from module where module_name = 'purchasing'";
	strMainIndex = dbOP.getResultOfAQuery(strMainIndex, 0);
	strSQLQuery = "select sub_mod_index from sub_module where module_index = "+strMainIndex+
					" and sub_mod_name = 'Final Approval of Requisition'";
	if(bolIs2ndLevelApprovalRequisition)
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	else	
		strSQLQuery = null;
		
	if(strSQLQuery != null) {
		strSQLQuery = "select auth_list_index from user_auth_list where is_valid = 1 and sub_mod_index = "+
						strSQLQuery+" and user_index = "+(String)request.getSession(false).getAttribute("userIndex");
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery != null)
			bolShowUpdateRequisitionStatFinalApproval = true;
	}
	
	strSQLQuery = "select sub_mod_index from sub_module where module_index = "+strMainIndex+
					" and sub_mod_name = 'Final Approval of PO'";
	if(bolIs2ndLevelApprovalPO)
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	else	
		strSQLQuery = null;
	if(strSQLQuery != null) {
		strSQLQuery = "select auth_list_index from user_auth_list where is_valid = 1 and sub_mod_index = "+
						strSQLQuery+" and user_index = "+(String)request.getSession(false).getAttribute("userIndex");
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery != null)
			bolShowUpdatePOStatFinalApproval = true;
	}
}

%>
<!--
<img src="../../images/broken_lines.gif"><a href="items/canvassing_view_search.jsp" target="purchasingmainFrame"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif"> Search/View item </font></a>
-->
<%if(bolGrantAll || vAuthList.indexOf("SUPPLIERS") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">SUPPLIERS</font></strong></div>
<span class="branch" id="branch1"> <img src="../../images/broken_lines.gif"><a href="supplier/suppliers.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Profiles</font></a><br>
<img src="../../images/broken_lines.gif"><a href="supplier/suppliers_buying_info.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Buying 
Information </font></a><br>
</span> 

<%}if(bolGrantAll || vAuthList.indexOf("MASTERLIST") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch9');swapFolder('folder9')"> 
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder9"> <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">ITEM MASTER LIST </font></strong></div>
<span class="branch" id="branch9"> 
<img src="../../images/broken_lines.gif"><a href="../inventory/inv_log/inv_registry_his.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> Manage item list</font></a><br>
<img src="../../images/broken_lines.gif"><a href="./requisition/item_reorder_point.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> Items below Reorder point</font></a><br>
<!--
<img src="../../images/broken_lines.gif"><a href="items/canvassing_view_search.jsp" target="purchasingmainFrame"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif"> Search/View item </font></a>
-->
</span>
<%} if(bolGrantAll || vAuthList.indexOf("REQUISITION") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch5');swapFolder('folder5')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder5"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">ITEM  REQUEST</font></strong></div>
<span class="branch" id="branch5"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<img src="../../images/broken_lines.gif"><a href="transfer_req/request_main.jsp?myHome=0" target="purchasingmainFrame"> 
Manage Requisitions</a><br>
<!--
<img src="../../images/broken_lines.gif"><a href="requisition/supply_main.jsp?is_supply=0" target="purchasingmainFrame"> 
Non-Supplies / <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Equipment Requisition</a><br>
<img src="../../images/broken_lines.gif"><a href="requisition/supply_main.jsp?is_supply=1" target="purchasingmainFrame"> 
Supplies Requisition</a><br>
-->
<img src="../../images/broken_lines.gif"><a href="transfer_req/availability.jsp" target="purchasingmainFrame"> 
Item Availability</a><br>
<%if(bolGrantAll || vAuthList.indexOf("REQUISITION STATUS UPDATE") != -1){isAuthorized=true;%>
<img src="../../images/broken_lines.gif"><a href="transfer_req/request_update.jsp" target="purchasingmainFrame"> 
Update Requisition</a><br>
<%}%>
<!--
<img src="../../images/broken_lines.gif"><a href="requisition/transfer_info.jsp" target="purchasingmainFrame"> Transfer Items</a><br>
-->
<img src="../../images/broken_lines.gif"> <a href="transfer_req/transfer_item.jsp" target="purchasingmainFrame">Transfer Items/Issuance</a><br>
<img src="../../images/broken_lines.gif"> <a href="transfer_req/request_view_search.jsp" target="purchasingmainFrame">Search/View 
Requisitions</a><br>
<img src="../../images/broken_lines.gif"> <a href="transfer_req/issuance_view_search.jsp" target="purchasingmainFrame">Search/View 
Issuances</a><br>
</font></span> 
<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder3"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">REQUISITION</font></strong></div>
<span class="branch" id="branch3"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<img src="../../images/broken_lines.gif"><a href="requisition/supply_main.jsp?myHome=0" target="purchasingmainFrame"> Manage Requisitions</a><br>
<!--
<img src="../../images/broken_lines.gif"><a href="requisition/supply_main.jsp?is_supply=0" target="purchasingmainFrame"> 
Non-Supplies / <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Equipment Requisition</a><br>
<img src="../../images/broken_lines.gif"><a href="requisition/supply_main.jsp?is_supply=1" target="purchasingmainFrame"> 
Supplies Requisition</a><br>
-->
<%
	if(bolGrantAll || vAuthList.indexOf("REQUISITION STATUS UPDATE") != -1){isAuthorized=true;
		if(!bolIsEAC && !bolIs2ndLevelApprovalRequisition) {%>
			<img src="../../images/broken_lines.gif"><a href="requisition/requisition_update.jsp?stage=1" target="purchasingmainFrame"> Update Requisition</a><br>
		<%}
		if(bolIs2ndLevelApprovalRequisition) {	
			if(bolShowUpdateRequisitionStatFinalApproval) {%>
				<img src="../../images/broken_lines.gif"><a href="requisition/requisition_update_batch.jsp" target="purchasingmainFrame"> Update Requisition - Final (In Batch)</a><br>
			<%}else{%>
				<img src="../../images/broken_lines.gif"><a href="requisition/requisition_update.jsp" target="purchasingmainFrame"> Update Requisition - First Level</a><br>
		<%}}%>
	<%if(strSchCode.startsWith("UDMC")){%>
		<img src="../../images/broken_lines.gif"><a href="requisition/requisition_update.jsp?stage=2" target="purchasingmainFrame"> Update Requisition(Inv. Dept)</a><br>
		<img src="../../images/broken_lines.gif"><a href="requisition/requisition_update.jsp?stage=3" target="purchasingmainFrame"> Update Requisition(Overall)</a><br>
	<%}%>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="requisition/requisition_view_search.jsp" target="purchasingmainFrame">Search/View 
Requisitions</a><br>
</font></span> 
<%} if(bolGrantAll || vAuthList.indexOf("CANVASSING") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch8');swapFolder('folder8')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder8"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">CANVASSING</font></strong></div>
 <span class="branch" id="branch8"> <img src="../../images/broken_lines.gif"><a href="canvassing/print_canvassing2.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
Print Requisition for<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Canvassing</font></a><br>
<img src="../../images/broken_lines.gif"><a href="canvassing/canvassing_view_search.jsp" target="purchasingmainFrame">
<font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
Search/View Requisition for<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Canvassing</font></a></span>
<%} if(bolGrantAll || vAuthList.indexOf("QUOTATION") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch2');swapFolder('folder2')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder2"> 
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">QUOTATION</font></strong></div>
<span class="branch" id="branch2"> <img src="../../images/broken_lines.gif"><a href="quotation/quotation_encode.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
Encode Quotation</font></a><br>
<img src="../../images/broken_lines.gif"><a href="quotation/request_requotation.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
Print Request for Requotation</font></a><br>
<!--
<img src="../../images/broken_lines.gif"><a href="quotation/quotation_request_update_for_approval.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
Update/Print Requisition<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;for Budget Approval</font></a><br>
-->
<img src="../../images/broken_lines.gif"><a href="quotation/quotation_request_approval.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
Update/Print Requisition<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;for Budget Approval</font></a><br>

<!-- hidden jan 10, 2008
<img src="../../images/broken_lines.gif"><a href="quotation/request_update_entries.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
Update Non PO<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Request Entries</font></a><br>
-->
<img src="../../images/broken_lines.gif"><a href="quotation/quotations_comparison.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
Quotations Comparison</font></a><br>

<img src="../../images/broken_lines.gif"><a href="quotation/quotation_view_search.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
Search/View Quotations </font></a> </span> 
<%} if(bolGrantAll || vAuthList.indexOf("PURCHASE ORDER") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch4');swapFolder('folder4')"> 
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder4"> 
<strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">PURCHASE ORDER </font></strong></div>
<span class="branch" id="branch4"><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<%if(strSchCode.startsWith("CPU")){%>
<img src="../../images/broken_lines.gif"><a href="purchase_order/purchasing_set_po_start.jsp" target="purchasingmainFrame"> 
Starting PO Number</a><br>
<%}%>
<img src="../../images/broken_lines.gif"><a href="purchase_order/purchase_request.jsp" target="purchasingmainFrame"> Create PO</a><br>
<%if(!bolIsEAC){%>
	<img src="../../images/broken_lines.gif"> <a href="purchase_order/purchase_request_update_entries.jsp" target="purchasingmainFrame">Update PO Entries</a><br>
<%}if(!bolIsEAC)
	if(bolGrantAll || vAuthList.indexOf("UPDATE PO STATUS") != -1){
		if(bolIs2ndLevelApprovalPO) {	
			if(bolShowUpdatePOStatFinalApproval) {%>
				<img src="../../images/broken_lines.gif"><a href="purchase_order/purchase_request_update_status_batch.jsp" target="purchasingmainFrame"> Update PO Status - Final (In Batch)</a><br>
			<%}else{%>
				<img src="../../images/broken_lines.gif"><a href="purchase_order/purchase_request_update_status.jsp" target="purchasingmainFrame"> Update PO Status - First Level</a><br>
		<%}}else{//if no second level approval%>
		<img src="../../images/broken_lines.gif"> <a href="purchase_order/purchase_request_update_status.jsp" target="purchasingmainFrame">Update PO Status</a><br>
<%}}%>
<%if(strSchCode.startsWith("UI")){%>
	<img src="../../images/broken_lines.gif"> <a href="purchase_order/purchase_request_finalize_PO.jsp" target="purchasingmainFrame">Print Final PO</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="purchase_order/purchase_request_waive_item.jsp" target="purchasingmainFrame">Waive Item</a><br>
<img src="../../images/broken_lines.gif"><a href="purchase_order/purchase_request_delete.jsp" target="purchasingmainFrame"> Delete PO</a><br>
	<%if(!strSchCode.startsWith("UI")){%>
		<img src="../../images/broken_lines.gif"><a href="purchase_order/purchase_request_cancel.jsp" target="purchasingmainFrame"> Cancel PO</a><br>
		<img src="../../images/broken_lines.gif"><a href="purchase_order/purchase_request_view_search.jsp?is_cancel=1" target="purchasingmainFrame"> Search/View Canceled PO</a><br>
	<%}%>
<img src="../../images/broken_lines.gif"><a href="purchase_order/purchase_approved_requests.jsp" target="purchasingmainFrame"> Summary of Approved PO</a><br>
<img src="../../images/broken_lines.gif"><a href="purchase_order/purchase_logged_PO.jsp" target="purchasingmainFrame"> Search Logged PO</a><br>
<img src="../../images/broken_lines.gif"><a href="purchase_order/purchase_request_view_search.jsp" target="purchasingmainFrame"> Search/View PO</a><br>
<img src="../../images/broken_lines.gif"><a href="purchase_order/search_item_by_suppler.jsp" target="purchasingmainFrame"> Search by Item/Supplier</a><br>
<img src="../../images/broken_lines.gif"><a href="purchase_order/purchase_report.jsp" target="purchasingmainFrame"> Item purchase report</a><br>
</font></span> 
<%}%>
<%if(bolIsEAC) 
	if(bolGrantAll || vAuthList.indexOf("UPDATE PO STATUS") != -1){%>
		<font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
			<img src="../../images/arrow_blue.gif"> <a href="purchase_order/purchase_request_update_status.jsp" target="purchasingmainFrame">Update PO Status</a><br>
		</font>
	<%}%>
<%if(bolIsEAC) 
	if(bolGrantAll || vAuthList.indexOf("UPDATE PO ENTRIES") != -1){%>
		<font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
			<img src="../../images/arrow_blue.gif"> <a href="purchase_order/purchase_request_update_entries.jsp" target="purchasingmainFrame">Update PO Entries</a><br>
		</font>
	<%}%>
<%if(bolIsEAC) 
	if(bolGrantAll || vAuthList.indexOf("UPDATE REQUISITION") != -1){%>
		<font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
			<img src="../../images/arrow_blue.gif"> <a href="requisition/requisition_update.jsp?stage=1" target="purchasingmainFrame"> Update Requisition</a><br>
		</font>
	<%}%>

<% if(bolGrantAll || vAuthList.indexOf("DELIVERY") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch7');swapFolder('folder7')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder7"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">DELIVERY</font></strong></div>
<span class="branch" id="branch7"> 
<img src="../../images/broken_lines.gif"><a href="delivery/delivery_update_status.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> Update PO Receive Status</font></a><br>
<%if(!strSchCode.startsWith("UPH")){%>
	<img src="../../images/broken_lines.gif"><a href="delivery/issuance_main.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> Print Issuance Form</font></a><br>
<%}%>
<!-- hidden may 13, 2008
<img src="../../images/broken_lines.gif"><a href="delivery/delivery_change_item.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> Change Returned Items</font></a><br>
-->
<!-- hidden jan 10, 2008
<img src="../../images/broken_lines.gif"><a href="delivery/delivery_status_non_po.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> Receive Non PO Item</font></a><br>
<img src="../../images/broken_lines.gif"> <a href="delivery/delivery_change_non_po_item.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Change Returned Non PO Item</font></a><br>
-->
<img src="../../images/broken_lines.gif"><a href="delivery/delivery_return_received_items.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> Return Received Items<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;to Supplier</font></a><br>
<img src="../../images/broken_lines.gif"><a href="free/free_item.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> Enter free Item</font></a><br>
<!--hidden may 12, 2008
<img src="../../images/broken_lines.gif"><a href="delivery/delivery_endorsement_return.jsp?is_from_endorsed=1" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> Search/View <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Endorsement Returns</font></a><br>
-->
<img src="../../images/broken_lines.gif"><a href="delivery/delivery_endorsement_return.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> Search/View <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Returns to Supplier</font></a><br>
<img src="../../images/broken_lines.gif"><a href="delivery/delivery_view_search.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> Search/View Deliveries</font></a><br>
<img src="../../images/broken_lines.gif"><a href="delivery/delivery_items_search.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> Search Supplier Deliveries</font></a><br>
<%if(strSchCode.startsWith("VMA")){%>
<img src="../../images/broken_lines.gif"><a href="delivery/memo_receipt.jsp" target="purchasingmainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif"> Print Memo Receipt</font></a>

<%}%>
</span> 

<%} if(bolGrantAll || vAuthList.indexOf("ENDORSEMENT") != -1){isAuthorized=true;%>
<!--
<div class="trigger" onClick="showBranch('branch6');swapFolder('folder6')"> 
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6"> <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">ENDORSEMENT / ISSUANCE</font></strong></div>
<span class="branch" id="branch6"> <font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<img src="../../images/broken_lines.gif"> <a href="endorsement/endorsement_encode_delete_dtls.jsp" target="purchasingmainFrame">Encode/Delete 
Endorsement <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Details</a><br>
<img src="../../images/broken_lines.gif"><a href="endorsement/endorsement_view_search.jsp" target="purchasingmainFrame"> Search/View Endorsement</a><br>
<img src="../../images/broken_lines.gif"><a href="endorsement/endorsement_monthly.jsp" target="purchasingmainFrame"> 
Issuance of Supplies</a><br>
</font></span> 
-->
<!-- hidden jan 10, 2008
<img src="../../images/broken_lines.gif"><a href="endorsement/endorsement_encode_non_po_dtls.jsp" target="purchasingmainFrame"> 
Encode Non-PO Endorsement</a><br>
-->
<!-- hidden may 12, 2008
<img src="../../images/broken_lines.gif"><a href="endorsement/endorsement_return_items.jsp" target="purchasingmainFrame"> Return Item(s) to <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Purchasing/Central Supplies</a><br>
-->

<%}
if(strUserId == null)
	strErrMsg = "Session timeout. Please login again.";
else if(!isAuthorized)
	strErrMsg = "You are not authorized to view any link in this page. Please contact system admin for access permission.";
if(strErrMsg == null)
	strErrMsg = "";
%>
<font size="2" face="Verdana, Arial, Helvetica, sans-serif"><%=strErrMsg%></font> 
</body>
</html>
<%
if(dbOP != null) dbOP.cleanUP();
%>