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
%></head>
</html>
<html>
<head>
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
<form action="../../commfile/logout.jsp" method="post" target="_parent" name="form_">
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
	vAuthList = comUtil.getAuthModSubModNameList(dbOP, strUserId, "INVENTORY");
	if(vAuthList == null)
		vAuthList = new Vector();
	else if( ((String)vAuthList.elementAt(0)).compareTo("#ALL#") == 0)
		bolGrantAll = true;
}
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";	
//if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Clearances","POST DUES")!=0){isAuthorized=true;
if(bolGrantAll || vAuthList.indexOf("LOG") != -1){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch9');swapFolder('folder9')"> <img src="../../images/box_with_plus.gif" name="folder9" width="7" height="7" border="0" id="folder9"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">INVENTORY SETTING</font></strong></div>
<span class="branch" id="branch9"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif">
<!--
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_log/inv_registry.jsp" target="inventorymainFrame">Inventory Registry</a><br> 
-->
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_log/inv_registry_his.jsp" target="inventorymainFrame">Inventory Registry</a><br> 
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="central_supply_setting.jsp" target="inventorymainFrame">Set Department <br>
&nbsp;&nbsp;&nbsp;&nbsp; as Central Supply</a><br> 
</font></span> 
<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">INVENTORY 
  LOG</font></strong></div>
<span class="branch" id="branch1"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_log/inv_entry_log.jsp?inventory_type=0" target="inventorymainFrame">Inventory Entry Log</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/return_logged_items.jsp" target="inventorymainFrame">Return Logged Items</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/search_warranty.jsp" target="inventorymainFrame">View Warranty</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/search_property.jsp" target="inventorymainFrame">Search 
Property</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/search_registry.jsp" target="inventorymainFrame">Search 
Item Code</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/entry_logs.jsp" target="inventorymainFrame">View Item Entry Logs</a><br>
</font></span> 
<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../../images/box_with_plus.gif" name="folder3" width="7" height="7" border="0" id="folder3"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">  SUPPLIES MGMT</font></strong></div>
<span class="branch" id="branch3"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif">
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_log/inv_entry_log.jsp?inventory_type=1" target="inventorymainFrame"> 
Supplies Entry Log</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/stock_out/request_main.jsp" target="inventorymainFrame">Stocks out</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/view_sup_per_office.jsp" target="inventorymainFrame">View Supplies per Office</a><br>
<!--
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/view_csr_inventory.jsp" target="inventorymainFrame">View Supplies</a><br>
-->
</font></span> 
<%}%>
<%//if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Clearances","CLEARANCE STATUS")!=0){isAuthorized=true;
if(bolGrantAll || vAuthList.indexOf("CHEMICALSMGMT") != -1){isAuthorized=true;
%>
<div class="trigger" onClick="showBranch('branch4');swapFolder('folder4')"> <img src="../../images/box_with_plus.gif" name="folder4" width="7" height="7" border="0" id="folder4"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">CHEMICALS 
  MGMT</font></strong></div>
<span class="branch" id="branch4"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<!--
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="cons_maint/cons_req.jsp" target="inventorymainFrame"> 
Chemicals Requisition</a><br>
-->
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_log/inv_entry_log.jsp?inventory_type=2" target="inventorymainFrame">Chemicals Entry Log</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/inv_chem_inventory.jsp" target="inventorymainFrame">View Chemical Inventory</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/search_expired.jsp" target="inventorymainFrame">Search Expired Chemicals </a><br>
</font></span> 
<%}// end CHEMICALSMGMT%>
<div class="trigger" onClick="showBranch('branch8');swapFolder('folder8')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder8"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">ITEM TRANSFER REQUEST</font></strong></div>
<span class="branch" id="branch8"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<img src="../../images/broken_lines.gif"><a href="../purchasing/transfer_req/request_main.jsp?myHome=0" target="inventorymainFrame"> 
Manage Requisitions</a><br>
<!--
<img src="../../images/broken_lines.gif"><a href="requisition/supply_main.jsp?is_supply=0" target="purchasingmainFrame"> 
Non-Supplies / <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Equipment Requisition</a><br>
<img src="../../images/broken_lines.gif"><a href="requisition/supply_main.jsp?is_supply=1" target="purchasingmainFrame"> 
Supplies Requisition</a><br>
-->
<%if(bolGrantAll || vAuthList.indexOf("REQUISITION STATUS UPDATE") != -1){isAuthorized=true;%>
<img src="../../images/broken_lines.gif"><a href="../purchasing/transfer_req/request_update.jsp" target="inventorymainFrame"> 
Update Requisition</a><br>
<%}%>
<img src="../../images/broken_lines.gif"> <a href="../purchasing/transfer_req/transfer_item.jsp" target="inventorymainFrame">Transfer Items</a><br>
<img src="../../images/broken_lines.gif"> <a href="../purchasing/transfer_req/request_view_search.jsp" target="inventorymainFrame">Search/View 
Requisitions</a><br>
<img src="../../images/broken_lines.gif"> <a href="../purchasing/transfer_req/issuance_view_search.jsp" target="inventorymainFrame">Search/View 
Issuances</a><br>
</font></span> 
<%
if(bolGrantAll || vAuthList.indexOf("MAINTENANCE") != -1){isAuthorized=true;
%>
<div class="trigger" onClick="showBranch('branch2');swapFolder('folder2')"> <img src="../../images/box_with_plus.gif" name="folder2" width="7" height="7" border="0" id="folder2"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">INVENTORY MAINTENANCE </font></strong></div>
<span class="branch" id="branch2"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/inv_transfer.jsp" target="inventorymainFrame">Transfer Items</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/inv_transfer_view_list.jsp" target="inventorymainFrame">Transferred Items List</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/inv_borrow.jsp" target="inventorymainFrame">Borrow Item</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/inv_borrow_view_list.jsp" target="inventorymainFrame">Borrowed Items List</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/inv_return.jsp" target="inventorymainFrame">Return borrowed Item</a><br>
<!--
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/inv_repacking.jsp" target="inventorymainFrame">Repacking</a><br>
-->
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/inv_item_status_update.jsp" target="inventorymainFrame">Item Status Update</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/inv_view_per_office.jsp" target="inventorymainFrame">Inventory by office</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/inv_view_inventory.jsp?" target="inventorymainFrame">View Equipment Inventory </a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/control_sheet/control_sheet_main.jsp" target="inventorymainFrame">Inventory Control Sheet</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="inv_maint/gate_pass/gate_pass_mgmt.jsp" target="inventorymainFrame">Gate Pass</a><br>
</font></span> 
<%}// end maintenance%>

<%
if(bolGrantAll || vAuthList.indexOf("FIXED_ASSET") != -1){isAuthorized=true;
%>
<div class="trigger" onClick="showBranch('branch5');swapFolder('folder5')"> <img src="../../images/box_with_plus.gif" name="folder5" width="7" height="7" border="0" id="folder5"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">FIXED 
  ASSET MANAGEMENT</font></strong></div>
<span class="branch" id="branch5"> 
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="fixed_asset_mgmt/encode_fixed_asset.jsp" target="inventorymainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Encode  Asset</font></a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="fixed_asset_mgmt/update_fixed_asset.jsp" target="inventorymainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Update 
Asset Value/Status<br>
 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Land & Buildings Only)</font></a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="fixed_asset_mgmt/fixed_asset_value.jsp" target="inventorymainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">List of Assets</font></a><br> 
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="fixed_asset_mgmt/asset_report/fam_report_main.jsp" target="inventorymainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Asset 
Report</font></a><br>
<!--
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="ast_indx/rpt_switcher.jsp" target="inventorymainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Search Asset</font></a><br>
-->
</span> 
<%}%>
<%//if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Clearances","CLEARANCE STATUS")!=0){isAuthorized=true;
if(bolGrantAll || vAuthList.indexOf("COMP_INV") != -1){isAuthorized=true;
%>
<div class="trigger" onClick="showBranch('branch6');swapFolder('folder6')"> <img src="../../images/box_with_plus.gif" name="folder6" width="7" height="7" border="0" id="folder6"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">COMPUTER COMPONENTS <br>&nbsp;&nbsp;&nbsp;INVENTORY</font></strong></div>
<span class="branch" id="branch6"> <img src="../../images/broken_lines.gif" width="15" height="15"> 
<a href="comp_log/computer_entry_log.jsp" target="inventorymainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Component 
Entry Log</font></a> <br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="comp_maint/cpu_maint.jsp" target="inventorymainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">CPU 
Maintenance</font></a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> 
<a href="comp_maint/comp_reports_property_card.jsp" target="inventorymainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Property Card (CPU)</font></a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> 
<a href="comp_maint/order_number.jsp" target="inventorymainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Inventory Report Setting</font></a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> 
<a href="comp_log/search_component.jsp" target="inventorymainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Search Components</font></a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> 
<a href="comp_maint/computer_parts_search.jsp" target="inventorymainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Search CPU Parts </font></a><br>
<!--
<img src="../../images/broken_lines.gif" width="15" height="15"> 
<a href="comp_maint/comp_reports_main.htm" target="inventorymainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Components Inventory<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Reports</font></a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="comp_maint/computer_req.jsp" target="inventorymainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">CPU/Parts 
Requisition</font></a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> 
<a href="comp_log/search_computer.jsp" target="inventorymainFrame"><font size="2" face="Geneva, Arial, Helvetica, sans-serif">Search Computer</font></a><br>
-->
</span>
<%}// end COMP_INV%>
<%//if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Clearances","CLEARANCE STATUS")!=0){isAuthorized=true;
if(bolGrantAll || vAuthList.indexOf("COMP_MAINTENANCE") != -1){isAuthorized=true;
%>
<div class="trigger" onClick="showBranch('branch7');swapFolder('folder7')"> <img src="../../images/box_with_plus.gif" name="folder7" width="7" height="7" border="0" id="folder7"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">COMPUTER 
  MAINTENANCE </font></strong></div>
<span class="branch" id="branch7"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<!--
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="comp_maint/comp_main_transfer.htm" target="inventorymainFrame">Transfer Transactions</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="comp_maint/comp_main_borrow.htm" target="inventorymainFrame">Borrow Transactions</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="comp_maint/comp_main_return.htm" target="inventorymainFrame">Return Transactions</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="comp_maint/cpu_status_update.jsp" target="inventorymainFrame">Computer Update Status</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="comp_maint/component_stat_update.jsp" target="inventorymainFrame">Component Update Status</a><br>
-->
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="comp_maint/component_transfer.jsp" target="inventorymainFrame">Transfer Transactions</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="comp_maint/component_borrow.jsp" target="inventorymainFrame">Borrow Transactions</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="comp_maint/component_return.jsp" target="inventorymainFrame">Return Transactions</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="comp_maint/component_stat_update.jsp" target="inventorymainFrame">Computer Update Status</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="comp_maint/component_remarks.jsp" target="inventorymainFrame">Remarks for components</a><br>
</font></span> 
<%}// end COMP_MAINTENANCE%>
<%if(strSchCode.startsWith("CIT") && (bolGrantAll || vAuthList.indexOf("PREVENTIVE_MAINTENANCE") != -1)){isAuthorized=true;
%>
<div class="trigger" onClick="showBranch('branch10');swapFolder('folder10')"> 
	<img src="../../images/box_with_plus.gif" name="folder10" width="7" height="7" border="0" id="folder10"> 
  <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">PREVENTIVE MAINTENANCE </font></strong></div>

<span class="branch" id="branch10"> <font size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="preventive_maintenance/setup_asset_maintenance.jsp" target="inventorymainFrame">Setup Assets for Maintenance</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="preventive_maintenance/update_asset_maintenance.jsp" target="inventorymainFrame">Update Assets Maintenance Schedule</a><br>
<img src="../../images/broken_lines.gif" width="15" height="15"> <a href="preventive_maintenance/view_maintenance_status.jsp" target="inventorymainFrame">View Assets Maintenace Status</a><br>
</font></span> 

<%}//end of PREVENTIVE_MAINTENANCE%><%
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