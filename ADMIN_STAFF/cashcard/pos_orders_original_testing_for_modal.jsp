<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date, hmsOperation.RestPOS, cashcard.Pos" %>
<%
	WebInterface WI = new WebInterface(request);
	if (WI.fillTextValue("print_pg").length() > 0){%>
		<jsp:forward page="./restaurant_items_listing_print.jsp"/>
		<% 
	return;}	
	DBOperation dbOP = null;
	RestPOS rPOS = new RestPOS();	
	Pos pos = new Pos();
	String strItemInfo = null;
	String strErrMsg = null;

	try	{
		dbOP = new DBOperation();
	} catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
	String strTemp = null;
	String strTemp2 = null;
	
	//set session if no one is logged in.
	if(request.getSession(false).getAttribute("userIndex") == null) {
		request.getSession(false).setAttribute("userIndex","1");
	}
	 	
//add security here.
//authenticate this user.
//CommonUtil comUtil = new CommonUtil();
//int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
//														"PAYROLL","DTR",request.getRemoteAddr(),
//														"restaurant_orders.jsp");
	
/*															
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
*/

//end of authenticaion code.	
	Vector vRetResult  = null;
	Vector vEditInfo   = null;
	Vector vOrderInfo  = null;
	Vector vIPResult   = null;
	
	int iSearchResult = 0;
	int i = 0;
	String strPageAction = WI.fillTextValue("page_action");
	String strOutletUsage = "";
	String strRestIndex = null;
	String strOutletName = null;
	String strIsOnEditMode = "1";
	boolean bolIsReloaded = WI.fillTextValue("is_reloaded").equals("1");
	String strInfoIndex = null;
	String strGuestIndex = null;
	String strRoomIndex = null;
	boolean bolIsCharged = false;
	String strOrderIndex = null;
	String strTerminalIPIndex = "";
	
	
	vIPResult = pos.operateOnIPFilter(dbOP, request);
	if (vIPResult == null) {%>
		<p style="font-weight:bold; font-color:red; font-size:16px;"><%=pos.getErrMsg()%></p>
		<%
		dbOP.cleanUP();
		return;	
	}
	strTerminalIPIndex = (String)vIPResult.elementAt(0);
	
	if(strPageAction.equals("0")){
		if(!rPOS.cancelOrder(dbOP, request))
			strErrMsg = rPOS.getErrMsg();
	}

	
	strOrderIndex = rPOS.generateOrderedDetail(dbOP, request, WI.fillTextValue("stud_"));
	if(strOrderIndex == null)
		strErrMsg = rPOS.getErrMsg();
	
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css" />
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css" />
<title>Restaurant orders</title>
<style type="text/css">
<!--.itemListing {height: 275px; width:470px; overflow: auto;}-->
<!--.orderItems {height: 380px; width:575px; overflow: auto;}-->
<!--.nameList {height: 50px; width:230px; overflow: auto;}-->

.itemListing {
height: 275px; width:auto; overflow: auto;
}
.orderItems {
height: 320px; width:auto; overflow: auto;
}
.nameList {
height: 50px; width:230px; overflow: auto;
}
.capsLock {
}
.capsUnlock{
   font-weight: bold;
   color: #0000FF;
   background-color: #000000;
   border: 1px solid #0000FF;
}

TD.thinborderALL {
    border-top: solid 1px #999999;
    border-left: solid 1px #999999;
    border-right: solid 1px #999999;
    border-bottom: solid 1px #999999;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;		
}
	
.nav {   
	border-top: solid 1px #999999;
    border-left: solid 1px #999999;
    border-right: solid 1px #999999;
    border-bottom: solid 1px #999999;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
	font-weight:normal;
}
.nav-highlight {  
	border-top: solid 1px #999999;
    border-left: solid 1px #999999;
    border-right: solid 1px #999999;
    border-bottom: solid 1px #999999;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;  
    background-color:#BCDEDB;
}


</style>
<script language="JavaScript" src="../../jscript/common.js" type="text/javascript"></script>
<script language="JavaScript" src="../../jscript/date-picker.js" type="text/javascript"></script>
<script language="JavaScript" src="../../Ajax/ajax.js" type="text/javascript"></script>
<script language="JavaScript" type="text/javascript">
var iTime = <%=new Date().getTime()%>;
function JSClock() 
{
   var serverTime = new Date(iTime);
   var hour = serverTime.getHours()
   var minute = serverTime.getMinutes()
   var second = serverTime.getSeconds()
   var temp = "" + ((hour > 12) ? hour - 12 : hour)
   if (hour == 0)
      temp = "12";
   temp += ((minute < 10) ? ":0" : ":") + minute
   temp += ((second < 10) ? ":0" : ":") + second
   temp += (hour >= 12) ? " PM" : " AM"

   //document.form_.dispClk.value=temp;
   iTime += 1000;
		if(document.getElementById("dispClk"))
	 	 document.getElementById("dispClk").innerHTML = " <strong>"+temp+"</strong>";
				
//if(document.dtr_record.emp_id.value.length ==0)
//	document.dtr_record.emp_id.value=(new Date().getHours())+":"+(new Date().getMinutes())+":"+(new Date().getSeconds()+" start time");
   window.setTimeout("JSClock()", 1000);
}
//all about ajax - to display student list with same name.

var objDivBox = null;
function initDiv(){
	if(objDivBox == null){
		objDivBox = document.getElementById("div_items");
	}
	
	if(!objDivBox)
		return;	
	objDivBox.scrollTop = objDivBox.scrollHeight;	
}

//function AjaxMapName() {
//	if(document.form_.cat_info.value.length == 0){
//		document.getElementById("coa_info").innerHTML = "";
//		return;
//	}
//	var objCOAInput = document.getElementById("coa_info");
//	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
//		if(this.xmlHttp == null) {
//		alert("Failed to init xmlHttp.");
//		return;
//	}
//	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=3&c_info="+document.form_.cat_info.value+
//							 "&table_no="+document.form_.table_no.value;
//	this.processRequest(strURL);
//} 


function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}

function Qty(strQty) {

	var strItemIndex  = document.form_.order_item_init.value;
	var strOrderIndex = document.form_.order_index_init.value;	
	
	if(strItemIndex.length > 0 || strOrderIndex.length > 0 ) 
		document.getElementById('blink_text').innerHTML = "Enter Qty";
	
	var strInput = document.form_.input_qty.value;
	if(strQty.length == 0) {
		document.form_.input_qty.value = "";
		return;
	}
	document.getElementById('blink_text').innerHTML = "";

	if(strInput.length == 0)
		strInput = strQty;
	else	
		strInput = strInput + strQty;
	
	document.form_.input_qty.value = strInput;
}
//Initialize the add item.. 
/**function AddItem(strItemIndex, strOrderIndex) {
	document.form_.order_item_init.value  = strItemIndex;
	document.form_.order_index_init.value = strOrderIndex;
	document.form_.input_qty.focus();
	document.getElementById('blink_text').innerHTML = "Enter Qty";
}*/


function AddItem(strItemIndex) {
	document.form_.order_item_init.value  = strItemIndex;
	document.form_.input_qty.focus();
	document.getElementById('blink_text').innerHTML = "Enter Qty";
}


var strIsBeverage;
var strCatgItemIndex;
var strStudIndex = "";

if(strStudIndex.length == 0)
	 strStudIndex = <%=WI.fillTextValue("stud_")%>;

function AddItemFinalize() {
	var strItemIndex  = document.form_.order_item_init.value;
	var strOrderIndex = document.form_.order_index_init.value;
	//document.getElementById("send_to_kitchen_lbl").innerHTML = "";
	
	if(strItemIndex.length == 0 || strOrderIndex.length == 0) {
		alert("No Item Selected");
		return;
	}
	
	if(document.form_.input_qty.value.length == 0) {
		alert("Please enter quantity to add");
		return;
	}
	
	strQty = document.form_.input_qty.value;
	if(strQty == null || strQty.length == 0){
		strQty = "1";		
	}

	if(isNaN(strQty)){		
		alert("Numeric Only");
		return;
	}	

	var objOrderItem = document.getElementById("order_info");
	this.InitXmlHttpObjectMultiple(objOrderItem,document.getElementById("order_summary"),document.getElementById("coa_info"));//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=5001&update_main=1&qty="+strQty+"&item_index="+strItemIndex+
		"&order_index="+strOrderIndex+"&stud_="+strStudIndex+"&is_beverage="+strIsBeverage+"&c_info="+strCatgItemIndex;		
	this.processRequest(strURL);	
	
	document.form_.order_item_init.value  = "";
	//document.form_.order_index_init.value = "";
	document.form_.input_qty.value = "";
	document.getElementById('blink_text').innerHTML = "";
}

function RemoveItem(strItemIndex){	
	if(!confirm("Continue removing item?"))
		return;
		
	var objOrderItem = document.getElementById("order_info");
	this.InitXmlHttpObjectMultiple(objOrderItem, document.getElementById("order_summary"), null);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	initDiv();
	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=5003&update_main=1&item_index="+strItemIndex+"&is_beverage="+strIsBeverage;
	this.processRequest(strURL);	
}

function AjaxOrderTable() {
	var objOrderItem = document.getElementById("order_info");	
	this.InitXmlHttpObjectMultiple(objOrderItem,document.getElementById("order_summary"),document.getElementById("coa_info"));//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
 	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=5002&terminal_ip_index="+document.form_.terminal_ip_index.value;
	this.processRequest(strURL);
}



function loadCategories(strBeverage) {
	var objCOAInput = document.getElementById("coa_info");
	strIsBeverage = strBeverage;
	
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
 	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=5004&is_beverage="+strBeverage+"&terminal_ip_index="+document.form_.terminal_ip_index.value;  
	this.processRequest(strURL);
	document.getElementById('blink_text').innerHTML = "";
	document.form_.input_qty.value = "";
} 

function selectCategory(strCatIndex){
 	var objCOAInput = document.getElementById("coa_info");
	strCatgItemIndex = strCatIndex;
	//document.form_.catg_index.value = strCatIndex;
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=5000&c_info="+strCatIndex;	
	this.processRequest(strURL);	
}




function SaveRecord(strOption){
	document.form_.page_action.value = strOption;			
	document.form_.submit();
}

function CancelRecord(){
	document.form_.page_action.value = "0";			
	document.form_.submit();	
}

function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.is_reloaded.value = "1";	
	document.form_.is_beverage.value = "1";	
	this.loadCategories("1");
	document.form_.submit();
}
function ReloadTable(strTableIndex) {
	document.form_.table_no.value = strTableIndex;
	this.ReloadPage();
}
function focusTable(){
	document.form_.table_no.focus();
}

function searchWaiterCode(strRestIndex){
	var strCompleteName = document.form_.waiter_code.value;
	var objCOAInput = document.getElementById("waiter_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=14&name_format=4&list_all=1"+
			"&complete_name="+escape(strCompleteName)+"&rest_index="+strRestIndex;

	this.processRequest(strURL);
}

function UpdateID(strID) {
	document.form_.waiter_code.value = strID;
	document.getElementById("waiter_info").innerHTML = "";
	//"<font size='1' color=blue>...end of processing..</font>";	
	//document.form_.submit();
}

function UpdateName(strName) {
	document.getElementById("waiter_name").innerHTML = strName;
	//"<font size='1' color=blue>...end of processing..</font>";	
	//document.form_.submit();
}

function printForKitchen(strIsBeverage){
	//if it is called for print for kitchen, i must send to kitchen also.. 
	if(strIsBeverage == '0') {
		this.SendOrderToKitchen('<%=strInfoIndex%>');	
	}
	var pgLoc = "./print_orders.jsp?print_separate=1&is_beverage="+strIsBeverage+"&table_no="+document.form_.table_no.value;
	var win=window.open(pgLoc,"printOrders",'width=550,height=340,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function printSalesOrder(){
	var pgLoc = "../sales/print_sales.jsp?guest_name="+document.form_.guest_name.value+"&table_no="+document.form_.table_no.value;
	var win=window.open(pgLoc,"printOrders",'width=550,height=340,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=yes');
	win.focus();
}

/// send order to kitchen.. 
function SendOrderToKitchen(strItemIndex) {
	var objOrderItem = document.getElementById("send_to_kitchen_lbl");
	if(objOrderItem == null)
		return;
	this.InitXmlHttpObject(objOrderItem, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=51&item_ref="+strItemIndex;
	this.processRequest(strURL);
}






/** Virtual Keyboard here.. **/
var objVKB; //var objTableButton;
var fieldOnFocus;
var caps = false;
function hideVirtualKB(){
	objVKB.style.visibility="hidden";
	//objTableButton.style.visibility="visible";
	fieldOnFocus = null;
	caps = false;
}

function showVirtualKB(strFieldFocus){
	if(!objVKB) {
		objVKB = document.getElementById("virtual_kb");
		//objTableButton = document.getElementById("tables_occupied");
	}
		
  	fieldOnFocus = strFieldFocus;
	objVKB.style.visibility="visible";
	//objTableButton.style.visibility="hidden";
}
function vkb(strVal) {
	if(!fieldOnFocus) {
		alert("Please focus a input.");
		return;
	}
	
	if(strVal.length == 0) {
		fieldOnFocus.value = '';
		return;
	}
	//for back space.. 
	var strInput = fieldOnFocus.value;

	if(strVal == 'bk') {
		strInput = strInput.substring(0,strInput.length - 1);
		strVal = '';
	}
	
	if(strVal == 'caps') {
		if(caps) {
			caps = false;
		}
		else {
			caps = true;
		}
		return;
	}
	if(caps)
		strVal = strVal.toUpperCase();
			
	if(strInput.length == 0)
		strInput = strVal;
	else	
		strInput = strInput + strVal;
	
	fieldOnFocus.value = strInput;
}

function CancelOrder(){
	document.form_.page_action.value = "0";
	document.form_.submit();
}


function SaveOrder(){

	window.opener.document.form_.order_index.value = document.form_.order_index_init.value;
	window.opener.document.form_.submit();
	window.opener.focus();
	window.close();
}

</script>
</head>
<body bgcolor="#D88B33" topmargin="0" onLoad="JSClock();AjaxOrderTable();">
<form action="pos_orders.jsp?stud_=<%=WI.fillTextValue("stud_")%>" method="post" name="form_">
<table width="100%" border="0" bgcolor="#80BD83">
  <tr>
    <td height="15">&nbsp;<strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
  </tr>
</table>
<%//if(vTerminalInfo != null && vTerminalInfo.size() > 0 && strOutletUsage.equals("0")){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#A9B9D1">
  	<tr>
		<%
			if(vOrderInfo != null && vOrderInfo.size() > 0)
				strTemp = (String) vOrderInfo.elementAt(9);
			else
				strTemp = WI.fillTextValue("table_no");
		%>	
    
       <td width="28%" height="29" valign="top" bgcolor="#D2ACCD" class="thinborderALL"> 
	   	<font color="#000066" size="1"><b>Date: </b></font><font color="#0000FF" size="2"><%=WI.getTodaysDate(1)%><br />
		<label id="dispClk" style="font-size:16px;"></label>
		</font></td>      
		
  </tr>
</table>
<table width="100%" border="0" cellpadding="1" cellspacing="1" bgcolor="#A9B9D1">
  <!--
  <tr>
		<%
			if(strIsOnEditMode.equals("2"))
				strTemp = "EDIT ORDER";
			else{
				strTemp = "SAVE ORDER";
			}
		%>	
    <td height="29" colspan="5" align="right" bgcolor="#80BD83" class="thinborderALL">
<% if(strIsOnEditMode.equals("2")) {%>

	<input type="button" name="save_" value="SEND ORDER TO KITCHEN" style="font-size:11px; height:35px;border: 1px solid #FF0000; font-weight:bold; background-color:#FFCC66" onClick="javascript:SendOrderToKitchen('<%=strInfoIndex%>');" />
&nbsp;&nbsp;&nbsp;&nbsp;
<label id="send_to_kitchen_lbl"></label>
<%}%>
	<input type="button" name="save" value="<%=strTemp%>" style="font-size:11px; height:35px;border: 1px solid #FF0000;" onClick="javascript:SaveRecord('<%=strIsOnEditMode%>');" />
      <% if(strIsOnEditMode.equals("2")) {%>
      	<input type="button" name="save2" value="CANCEL ORDER" style="font-size:11px; height:35px;border: 1px solid #FF0000;" onClick="javascript:CancelRecord();" />		  
      	<input type="button" name="save3" value="PRINT FOR KITCHEN" style="font-size:11px; height:35px;border: 1px solid #FF0000;" onClick="javascript:printForKitchen('0');" />
      	<input type="button" name="save32" value="PRINT FOR BEVERAGES" style="font-size:11px; height:35px;border: 1px solid #FF0000;" onClick="javascript:printForKitchen('1');" /> 
      	<input type="button" name="save3" value="PRINT SALES ORDER - FOR GUEST" style="font-size:11px; height:35px;border: 1px solid #FF0000;" onClick="javascript:printSalesOrder('<%=WI.fillTextValue("guest_name")%>');" />
	 <%}%>		
      </font></td>
    </tr>
	
	-->
	
	
	<tr>
		<td height="29">
			<input type="button" name="cancel_order" value="CANCEL ORDER" style="font-size:15px; height:35px;border: 1px solid #FF0000;" onClick="javascript:CancelOrder();" />			
		</td>
		<td height="29" align="">
			<input type="button" name="save" value="RELOAD SCREEN" style="font-size:15px; height:35px;border: 1px solid #FF0000;" onClick="javascript:document.form_.submit()();" />
		</td>
		<td height="29" align="right">
			<input type="button" name="save" value="SAVE ORDER" style="font-size:15px; height:35px;border: 1px solid #FF0000;" onClick="javascript:SaveOrder();" />
		</td>
	</tr>
	
	
	
	
</table>
  <table width="100%" border="0" cellpadding="1" cellspacing="1" bgcolor="#A9B9D1">
  <tr>
    <td width="50%" height="288"  valign="top" class="thinborderALL">			
			<div class="orderItems" id="div_items"><label id="order_info" style="font-size:11px; font-family:Verdana, Arial, Helvetica, sans-serif"></label></div>
     </td>
    <td width="50%" class="thinborderALL"  valign="top" >
		<table width="100%" border="0">
      <tr>
        <td width="90%" height="38" align="" bgcolor="#8FDA8F">
			<input type="button" name="save" value="  MAIN MENU " style="font-size:15px; height:35px;border:1px solid #FF0000; width:20%;" onClick="javascript:loadCategories('1');" />
				<font size="1">Click to load all inventory</font>
				<!--<%
				strTemp = WI.getStrValue(WI.fillTextValue("is_beverage"));
				if(bolIsReloaded)
					strTemp = "1";
 				if(strTemp.equals("0"))
					strErrMsg = " checked";
				else
					strErrMsg = "";					
				%>	
				<label for="_id1" style="font-size:28px; font-weight:bold">			
					<input type="radio" name="is_beverage" id="_id1" value="0" <%=strErrMsg%> onClick="loadCategories('0');"/>Food</label>
        		<%
					if(strTemp.equals("1"))
						strErrMsg = " checked";
					else
						strErrMsg = "";
				%>&nbsp;&nbsp;&nbsp;&nbsp;
				<label for="_id2" style="font-size:28px; font-weight:bold">			
        			<input type="radio" name="is_beverage" id="_id2" value="1" <%=strErrMsg%> onClick="loadCategories('1');"/> Beverages</label>	-->			</td>
      </tr>
      <tr>
        <td height="25" bgcolor="#EBEBEB" valign="top">
				<div class="itemListing"><label id="coa_info" style="font-size:11px; font-family:Verdana, Arial, Helvetica, sans-serif"></label></div></td>
      </tr>
    </table>
	</td>
    </tr>
	
  <tr>
		<%
		strTemp = "";
		if(vOrderInfo != null && vOrderInfo.size() > 0)
			strTemp = (String) vOrderInfo.elementAt(21);
		%>
    <td rowspan="2" valign="top" class="thinborderALL">
	<table width="96%" border="0">
        <tr><td width="50%"><font color="#0000FF"><b><u>TOTAL</u></b></font></td></tr>
        <tr><td valign="top"><label id="order_summary" style="font-size:11px; font-family:Verdana, Arial, Helvetica, sans-serif"></label></td></tr>
    </table>
	</td>
    <td height="60"  class="thinborderALL" >Quantity of Item : 
	<input type="text" name="input_qty" style="font-size:16px; font-weight:bold;" size="12">
	<input type="button" name="___" value="ADD ITEM" onClick="AddItemFinalize();" style="font-size:15px; height:35px;border: 1px solid #FF0000;">	
	
	&nbsp;&nbsp;
	<label id="blink_text" style="font-size:16px; font-weight:bold; color:#FF0000"></label>
	</td>
  </tr>
  <tr>
    <td height="60" align="center" class="thinborderALL" >
	<input type="button" name="___1" value="1" onClick="Qty('1');" style="font-size:15px; height:35px; width:45px;border: 1px solid #FF0000;"> 
	<input type="button" name="___2" value="2" onClick="Qty('2');" style="font-size:15px; height:35px; width:45px;border: 1px solid #FF0000;"> 
	<input type="button" name="___3" value="3" onClick="Qty('3');" style="font-size:15px; height:35px; width:45px;border: 1px solid #FF0000;"> 
	<input type="button" name="___4" value="4" onClick="Qty('4');" style="font-size:15px; height:35px; width:45px;border: 1px solid #FF0000;"> 
	<input type="button" name="___5" value="5" onClick="Qty('5');" style="font-size:15px; height:35px; width:45px;border: 1px solid #FF0000;"> 
	<input type="button" name="___6" value="6" onClick="Qty('6');" style="font-size:15px; height:35px; width:45px;border: 1px solid #FF0000;"> 
	<input type="button" name="___7" value="7" onClick="Qty('7');" style="font-size:15px; height:35px; width:45px;border: 1px solid #FF0000;"> 
	<input type="button" name="___8" value="8" onClick="Qty('8');" style="font-size:15px; height:35px; width:45px;border: 1px solid #FF0000;" />
	<input type="button" name="___9" value="9" onClick="Qty('9');" style="font-size:15px; height:35px; width:45px;border: 1px solid #FF0000;"> 
	<input type="button" name="___0" value="0" onClick="Qty('0');" style="font-size:15px; height:35px; width:45px;border: 1px solid #FF0000;">	&nbsp;&nbsp;&nbsp;	
	<input type="button" name="___0" value="CLEAR" onClick="Qty('');" style="font-size:15px; height:35px; width:65px;border: 1px solid #FF0000;">	</td>
  </tr>
</table>

<!--

<table width='95%' border='0' cellpadding='3' cellspacing='3'>
	<tr>
			<td height="36" id='msg0' class='thinborderALL nav' width='20%' align='center'
				onclick="selectCategory('6');" onMouseOver="navRollOver('msg0', 'on')" onMouseOut="navRollOver('msg0', 'off')">
			<strong><font color=#0000FF>Food</font></strong></td>
			<td height='36' id='msg1' class='thinborderALL nav' width='20%' align='center'  
				onclick="selectCategory('7');" onMouseOver="navRollOver('msg1', 'on')" onMouseOut="navRollOver('msg1', 'off')">
			<strong><font color=#0000FF>Beverage</font></strong></td>
			<td height='36' class='thinborderALL' bgcolor='#009900' width='20%'>&nbsp;</td>
			<td height='36' class='thinborderALL' bgcolor='#009900' width='20%'>&nbsp;</td>
			<td height='36' class='thinborderALL' bgcolor='#009900' width='20%'>&nbsp;</td>
	</tr>
</table>
-->

<%//}%>		
	<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="is_reloaded">
	<input type="hidden" name="ignore_code" value="1">
	<input type="hidden" name="charged_to_room">
	
<!-- for virtual key board to function -->
	<input type="hidden" name="order_item_init">
	<input type="hidden" name="order_index_init" value="<%=strOrderIndex%>">
	<input type="hidden" name="stud_" value="<%=WI.fillTextValue("stud_")%>" >
	<input type="hidden" name="terminal_ip_index" value="<%=strTerminalIPIndex%>" >
	
	
	<!-- i need this to load the coa_info when adding/removing an item. ajax --->
	<input type="hidden" name="catg_index" value="<%=WI.fillTextValue("catg_index")%>"  />
	<input type="hidden" name="loaded_category" value="<%=WI.fillTextValue("loaded_category")%>"  />	
</form>
	</body>
</html>
<%
dbOP.cleanUP();
%>