<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Administrator links</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/regmainlinkcss.css" rel="stylesheet" type="text/css">
<link href="../../css/treelinkcss.css" rel="stylesheet" type="text/css">
<script language="JavaScript" type="text/JavaScript">
<!--
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
<%
response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
<style>
body {
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size:13px;
	color:#FFFFFF;
}
</style>
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
<form action="../../commfile/logout.jsp" method="post" target="_parent">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="8%" height="19" bgcolor="#E9E0D1">&nbsp;</td>
      <td width="92%" bgcolor="#E9E0D1"> <a href="../main%20files/admin_staff_home_button_content.htm" target="_parent" onMouseOver="MM_swapImage('Image2','','../../images/home_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()" ><img src="../../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()">
        <input type="image" src="../../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3">
        </a></td>
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
	
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";


if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","BOOK MANAGEMENT")!=0){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../images/box_with_plus.gif" border="0" id="folder1">
  <strong>BOOK MANAGEMENT </strong></div>

<span class="branch" id="branch1">  
	<img src="../../images/broken_lines.gif"><a href="book_management.jsp" target="accountingmainFrame"> Book Management </a><br>
	<img src="../../images/broken_lines.gif"><a href="book_supply_log_main.jsp" target="accountingmainFrame"> Book Supply Log </a><br>
	<img src="../../images/broken_lines.gif"><a href="update_book_quantity.jsp" target="accountingmainFrame"> Set Book Quantity</a><br>
	<img src="../../images/broken_lines.gif"><a href="view_update_book_quantity.jsp" target="accountingmainFrame"> View History of Book Quantity Update</a><br>
	<img src="../../images/broken_lines.gif"><a href="book_search.jsp" target="accountingmainFrame"> Search Book </a><br>	
	<img src="../../images/broken_lines.gif"><a href="./property/accept_return_dist_book.jsp" target="accountingmainFrame"> Accept Return Distribution Inventory</a><br>
</span> 
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","PRICE MANAGEMENT")!=0){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch2');swapFolder('folder2')"> <img src="../../images/box_with_plus.gif" border="0" id="folder2">
  <strong>PRICING MANAGEMENT </strong></div>

<span class="branch" id="branch2">  
	<img src="../../images/broken_lines.gif"><a href="book_pricing.jsp" target="accountingmainFrame"> Set Pricing of Books</a><br>
	<img src="../../images/broken_lines.gif"><a href="discount_management.jsp" target="accountingmainFrame"> Discount Management</a><br>
	<img src="../../images/broken_lines.gif"><a href="installment_management.jsp" target="accountingmainFrame"> Installment Management</a><br>
</span> 
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","PROPERTY")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch5');swapFolder('folder5')"> <img src="../../images/box_with_plus.gif" border="0" id="folder5">
  <strong>PROPERTY MANAGEMENT</strong></div>
	
<span class="branch" id="branch5">  	
	<img src="../../images/broken_lines.gif"><a href="./property/view_requested_books.jsp" target="accountingmainFrame"> View Requested Books</a><br>
	<img src="../../images/broken_lines.gif"><a href="./property/view_approved_books.jsp" target="accountingmainFrame"> View Approved Books</a><br>
	<img src="../../images/broken_lines.gif"><a href="./property/view_delivered_books.jsp" target="accountingmainFrame"> View Delivered Books</a><br>
	<img src="../../images/broken_lines.gif"><a href="./property/history_of_book_delivered.jsp" target="accountingmainFrame"> History of Books Delivered</a><br>
<!--	<img src="../../images/broken_lines.gif"><a href="./property/move_prop_to_dist_inv.jsp" target="accountingmainFrame"> Move Inventory</a><br>-->
	<img src="../../images/broken_lines.gif"><a href="book_magement_settings_main.jsp" target="accountingmainFrame"> Manage Settings</a><br>	
	<img src="../../images/broken_lines.gif"><a href="property/login_terminal.jsp" target="accountingmainFrame"> IP Management</a><br>
	<%if(strUserId.toLowerCase().equals("sa-01") || strUserId.toLowerCase().equals("sa-02")){%>
	<img src="../../images/broken_lines.gif"><a href="fixing_issue.jsp" target="accountingmainFrame"> FIXING PREVIOUS ORDER</a><br>
	<img src="../../images/broken_lines.gif"><a href="fixing_issue_for_post_charge.jsp" target="accountingmainFrame"> FIXING POST CHARGE</a><br>	
	<img src="../../images/broken_lines.gif"><a href="./property/create_rhgp_student_order.jsp" target="accountingmainFrame"> CREATE RHGP ORDER</a><br>	
	<%}%>
	
</span> 

<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","ORDERING")!=0){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> <img src="../../images/box_with_plus.gif" border="0" id="folder3">
  <strong>ORDERING</strong></div>

<span class="branch" id="branch3">  
	<%if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","ORDERING-ORDER ITEMS COLLEGE")!=0){%>
		<img src="../../images/broken_lines.gif"><a href="ordering.jsp" target="accountingmainFrame"> Order Items College</a><br>
	<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","ORDERING-ORDER ITEMS BASIC")!=0){%>
		<img src="../../images/broken_lines.gif"><a href="ordering_basic_edu.jsp" target="accountingmainFrame"> Order Items Basic Edu</a><br>
	<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","ORDERING-RELEASE ITEMS COLLEGE")!=0){%>
		<img src="../../images/broken_lines.gif"><a href="release_items.jsp" target="accountingmainFrame"> Release Order Items - College</a> <br>
	<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","ORDERING-RELEASE ITEMS BASIC")!=0){%>
			<img src="../../images/broken_lines.gif"><a href="release_items_basic.jsp" target="accountingmainFrame"> Release Order Items - Basic</a> <br>
	<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","ORDERING-REQUEST BOOK")!=0){%>
			<img src="../../images/broken_lines.gif"><a href="./property/request_book_to_property.jsp" target="accountingmainFrame"> Request Book to Property</a><br>
	<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","ORDERING-CANCEL ORDER")!=0){%>
			<img src="../../images/broken_lines.gif"><a href="cancel_order.jsp" target="accountingmainFrame"> Cancel Order</a><br>
	<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","ORDERING-REPRINT COLLEGE")!=0){%>
			<img src="../../images/broken_lines.gif"><a href="reprint_order.jsp" target="accountingmainFrame"> Re-print Order Slip - College</a><br>
	<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","ORDERING-REPRINT BASIC")!=0){%>
			<img src="../../images/broken_lines.gif"><a href="reprint_order_basic.jsp" target="accountingmainFrame"> Re-print Order Slip - Basic</a><br>
	<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","ORDERING-BOOK DELIVERY")!=0){%>
			<img src="../../images/broken_lines.gif"><a href="./property/accept_delivered_books.jsp" target="accountingmainFrame"> Accept Book Delivery</a><br>
	<%}%>
</span>
<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","REPORTS")!=0){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch4');swapFolder('folder4')"> <img src="../../images/box_with_plus.gif" border="0" id="folder4">
  <strong>REPORTS</strong></div>

<span class="branch" id="branch4"> 
	<%if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","REPORTS-ALERT LEVEL")!=0){%> 
		<img src="../../images/broken_lines.gif"><a href="reports/alert_level.jsp" target="accountingmainFrame"> Stocks Below/Equal to Alert Level  </a><br>
	<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","REPORTS-STOCKS ORDERED")!=0){%>
		<img src="../../images/broken_lines.gif"><a href="reports/stocks_ordered_basic.jsp" target="accountingmainFrame"> Stocks Ordered</a><br>
	<%}
		if(false){
		//if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","REPORTS-EXPIRED ORDER")!=0)%>
		<img src="../../images/broken_lines.gif"><a href="reports/expired/manage_expired_order.jsp" target="accountingmainFrame"> Manage Expired Order </a><br>
	<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","REPORTS-DISTRIBUTION INVENTORY")!=0){%>
		<img src="../../images/broken_lines.gif"><a href="reports/inventory.jsp?is_book_type=1" target="accountingmainFrame"> Distribution Inventory Management</a><br>
	<%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Bookstore","REPORTS-PROPERTY INVENTORY")!=0){%>
		<img src="../../images/broken_lines.gif"><a href="reports/inventory_property.jsp?is_book_type=1" target="accountingmainFrame"> Property Inventory Management</a><br>
		<img src="../../images/broken_lines.gif"><a href="reports/return_property_inv.jsp?is_book_type=1" target="accountingmainFrame" 
			title="View Current Inventory"> Return Property Inventory</a><br>
		<img src="../../images/broken_lines.gif"><a href="reports/view_returned_prop_inv.jsp" target="accountingmainFrame"> View Returned Items</a><br>
	<%}%>
</span>
<%}

if(strUserId == null)
	strErrMsg = "Session timeout. Please login again.";
else if(!isAuthorized)
	strErrMsg = "You are not authorized to view any link in this page. Please contact system admin for access permission.";
if(strErrMsg == null)
	strErrMsg = "";
%>
  <font size="2" face="Verdana, Arial, Helvetica, sans-serif"><%=strErrMsg%></font>
</div>
</body>
</html>
<%
if(dbOP != null) dbOP.cleanUP();
%>
