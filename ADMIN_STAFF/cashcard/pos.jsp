<%@ page language="java" import="utility.*,java.util.Date, cashcard.Pos, hmsOperation.RestPOS,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>POS Terminal</title>
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/modalwindowcss.css" rel="stylesheet" type="text/css" media="all" >
<link href="../../css/treelinkcss.css" rel="stylesheet" type="text/css">


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


.navButton {   
	border-top: solid 1px #999999;
    border-left: solid 1px #999999;
    border-right: solid 1px #999999;
    border-bottom: solid 1px #999999;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
	font-weight:normal;
}
.navButton-highlight {  
	border-top: solid 1px #999999;
    border-left: solid 1px #999999;
    border-right: solid 1px #999999;
    border-bottom: solid 1px #999999;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;  
    background-color:#FF0000;
}



 
  div.processing{
    display:block;
	overflow:auto;
    position:absolute;
    right:0;
	top:0;
    width:350px;
	height:100px;
	background:#CCCCCC;
    border:1px solid #ddd;
  }


</style>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp   = null;
	String strDisabled  = null;
	String strImgFileExt = null;
	String strRootPath = null;//very important for file method.
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"), "0");
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD-POS TERMINAL"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD"),"0"));
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-POS TERMINAL","pos.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		strRootPath = readPropFile.getImageFileExtn("installDir");
		
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
		if(strRootPath == null || strRootPath.trim().length() ==0)
		{
			strErrMsg = "Installation directory path is not set. Please check the property file for installDir KEY.";
			dbOP.cleanUP();
			throw new Exception();
		}						
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
	
	Vector vEditInfo  = null; 
	Vector vRetResult = null; 
	Vector vIPResult = null;
	Vector vCardDetails = null;
	Vector vStudInfo  = null; 
	Vector vAllergies = null;
	Vector vFoodPD = null;
	String strTerminalIPIndex = "";
	String strAmtOrdered = "";
	String strOrderIndex = "";
	
	
	/******/
	Vector vOrderInfo = null;
	/*****/
	
	
	// total balance of the card | also for evaluation of the entered amount if higher than then total card balance
	double dBalance = 0d;
	
	// to evaluate if the entered amount is greater than the remaining usage per day
	double dUsableToday = 0d; 
	
	// used to evalute if the transaction amount is higher 
	//than the max usage per day or the remaining card balance
	double dAmount = 0d; 
	
	int i = 0;
	int iSearchResult = 0;
	
	boolean bolIsBasic = false;
	String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr","8th Yr"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};//not currently used..
	//String[] astrConvertYrLevelBasic = {"N/A", "Nursery", "Kinder I", "Kinder II", "Grade I", "Grade II", "Grade III", "Grade IV", 
	//									"Grade V", "Grade VI", "Grade VII", "First Year", "Second Year", "Third Year", "Fourth Year"};
	
	Pos pos = new Pos();
	RestPOS rPOS = new RestPOS();
	enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
	
	
	//String[] astrConvertYrLevelBasic = pos.getBasicYearLevel(dbOP);
	
	boolean bolIsStaff = false;
	boolean bolIsStudEnrolled = false;
	boolean bolBasicStudent = false;
	
	vIPResult = pos.operateOnIPFilter(dbOP, request);
	if (vIPResult == null) {%>
		<p style="font-weight:bold; font-color:red; font-size:16px;"><%=pos.getErrMsg()%></p>
		<%
		dbOP.cleanUP();
		return;	
	}

	if(((String)vIPResult.elementAt(5)).equals("0")){%>
		<p style="font-weight:bold; font-color:red; font-size:16px;">This terminal is not canteen type.</p>
		<%
		dbOP.cleanUP();
		return;	
	}
	strTerminalIPIndex = (String)vIPResult.elementAt(0);
	
	//String strStudID = WI.fillTextValue("stud_id");
	//if(WI.fillTextValue("scan_id").length() > 0) 
	String strStudID = WI.fillTextValue("scan_id");
	
	
	
	if(strStudID.length() > 0){
		if(bolIsSchool) {
			vStudInfo = OAdm.getStudentBasicInfo(dbOP, strStudID);
			if(vStudInfo == null) //may be it is the teacher/staff
			{
				request.setAttribute("emp_id", strStudID);
				vStudInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
				if(vStudInfo != null)
					bolIsStaff = true;
			}
			else {//check if student is currently enrolled
				Vector vTempBasicInfo = OAdm.getStudentBasicInfo(dbOP, strStudID,
				(String)vStudInfo.elementAt(10),(String)vStudInfo.elementAt(11),(String)vStudInfo.elementAt(9));
				if(vTempBasicInfo != null){
					bolIsStudEnrolled = true;
					if(((String)vTempBasicInfo.elementAt(5)).equals("0"))
						bolBasicStudent = true;
					//System.out.println("vTempBasicInfo: "+vTempBasicInfo);
				}
			}
			if(vStudInfo == null)
				strErrMsg = OAdm.getErrMsg();
		}
		else{//check faculty only if not school...
			request.setAttribute("emp_id", strStudID);
			vStudInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
			if(vStudInfo != null)
				bolIsStaff = true;
			if(vStudInfo == null)
				strErrMsg = "Employee Information not found.";
		}
	}
	String strUserIndex = null;
	if(vStudInfo != null) {
		strUserIndex = (String)vStudInfo.elementAt(12);
		if(bolIsStaff)
			strUserIndex = (String)vStudInfo.elementAt(0);
		
		if(WI.fillTextValue("cancel_transaction").length() > 0){// this should have a session of orders.
			if(!rPOS.cancelOrder(dbOP, request))
				strErrMsg = rPOS.getErrMsg();
		}
	
		strTemp = WI.fillTextValue("page_action");
		if(strTemp.length() > 0) {
			if(strTemp.equals("1")){
				try{
					dBalance = Double.parseDouble(WI.fillTextValue("dBalance"));
					dUsableToday = Double.parseDouble(WI.fillTextValue("dUsableToday"));
					dAmount = Double.parseDouble(WI.getStrValue(WI.fillTextValue("dAmount"), "0"));
					
				}
				catch(NumberFormatException nfe){
					dBalance = 0;
					dUsableToday = 0;
					dAmount = 0;
				}
			}
			else{
				dBalance = 0;
				dUsableToday = 0;
				dAmount = 0;
			}	
			
			if(dAmount > dUsableToday || dAmount > dBalance){
				strErrMsg = "The amount you enter is higher than the card balance/remaining usage.";				
			}			
			else{
				if(pos.operateOnTransaction(dbOP, request, Integer.parseInt(strTemp), strUserIndex) == null )
					strErrMsg = pos.getErrMsg();
				else {
				
					if(strTemp.equals("0"))
						strErrMsg = "Transaction successfully removed.";
					else if(strTemp.equals("1"))
						strErrMsg = "Transaction successfully added.";
					else if(strTemp.equals("2"))
						strErrMsg = "Transaction successfully edited.";
						
					strPrepareToEdit = "0";
					strAmtOrdered = "";
				}
				
				
			}
			
			
		}
		
		if(((String)vIPResult.elementAt(5)).equals("1")){
			vAllergies  = pos.getAllergies(dbOP, request, strUserIndex);
			vFoodPD = pos.getFoodPD(dbOP, request, strUserIndex);
		}
		

		
		vCardDetails = pos.getCardUserDetail(dbOP, strUserIndex);
		if(vCardDetails == null){
			strErrMsg = pos.getErrMsg();
			strDisabled = "disabled=\"disable\"";
		}
		
		if(vCardDetails != null && vCardDetails.size() > 0){		
			//sum from (amount * no units) ==> initial credits
			strTemp  = WI.getStrValue((String)vCardDetails.elementAt(5), "0");
			dBalance = Double.parseDouble(strTemp);
			
			//load adjustment: add load adjustments to initial credits
			strTemp  = WI.getStrValue((String)vCardDetails.elementAt(4), "0");
			dBalance = dBalance + Double.parseDouble(strTemp);
			
			//usage summary: swipes
			strTemp  = WI.getStrValue((String)vCardDetails.elementAt(3), "0");
			dBalance = dBalance - Double.parseDouble(strTemp);
			
			dBalance = pos.getCurrentBalance(dbOP, strUserIndex);
			//System.out.println("strTempaaa "+strTemp);
			
			//max usage per day
			strTemp  = WI.getStrValue((String)vCardDetails.elementAt(1), "0");
			if(Double.parseDouble(strTemp) > 0){
				//if card balance is greater than the max usage per day, the remaining usage for today is the max usage for today
				//minus the total of the swipes for today
				if(dBalance >= Double.parseDouble(strTemp)){
					dUsableToday = Double.parseDouble(strTemp);
					
					//total swipes for today
					strTemp  = WI.getStrValue((String)vCardDetails.elementAt(2), "0");
					dUsableToday = dUsableToday - Double.parseDouble(strTemp);
				}
				else
					dUsableToday = dBalance;
			}
			else
				dUsableToday = dBalance;//if unlimited, the remaining usage for today is equal to the initial credits for this person
			
			if(dUsableToday <= 0){
				strDisabled = "disabled=\"disable\"";
				strErrMsg = "You have maxed out your usage for today.";
			}
			
			strTemp  = WI.getStrValue((String)vCardDetails.elementAt(0), "0");
			if(Double.parseDouble(strTemp)>=dBalance) 
				strErrMsg = "Your balance is too low.";
			
		}// End of vCardDetail id not null
		
		vRetResult = pos.operateOnTransaction(dbOP, request, 4, strUserIndex);
		if(vRetResult == null && strErrMsg == null)
			strErrMsg = pos.getErrMsg();
		else	
			iSearchResult = pos.getSearchCount();
			
			
		if(WI.fillTextValue("page_action").equals("0")){
			if(!rPOS.cancelOrder(dbOP, request))
				strErrMsg = rPOS.getErrMsg();
		}
	
		
		strOrderIndex = rPOS.generateOrderedDetail(dbOP, request, strUserIndex);
		if(strOrderIndex == null){%>	
			<p style="font-weight:bold; font-color:red; font-size:16px;"><%=rPOS.getErrMsg()%></p>
		<%
		dbOP.cleanUP();
		return;	
		}
			
		if(strOrderIndex != null && strOrderIndex.length() > 0){
			strTemp = "select payable_amt from hms_rest_pos_sales_main where pos_sales_main_index = "+strOrderIndex;
			strAmtOrdered = WI.getStrValue(dbOP.getResultOfAQuery(strTemp, 0),"0");	
			if(Double.parseDouble(strAmtOrdered) == 0d)
				strAmtOrdered = "";
		}
			
	//	System.out.println("strAmtOrdered "+strAmtOrdered);
	}//only if vStudInfo is not null;
	
%>		


<script language="javascript" src="../../jscript/modal/jquery-latest.pack.js"></script>
<script language="javascript" src="../../jscript/modal/modalwindowjs.js"></script>
<script language="javascript" src="../../Ajax/ajax.js" ></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../jscript/td.js"></script>

<script language="javascript">

<%if(WI.fillTextValue("edit_called").length() > 0){%>

$(document).ready(function() {							   
	//when i press edit button
	$(window).load(function(e) {	
		//Cancel the link behavior
		e.preventDefault();
		
		//Get the A tag
		var id = "#dialog";  //$(this).attr('href');
		//var id = $(this).attr('href');
		
		
		//Get the screen height and width
		var maskHeight = $(document).height();
		var maskWidth = $(window).width();
	
		//Set heigth and width to mask to fill up the whole screen
		$('#mask').css({'width':maskWidth,'height':maskHeight});
		
		//transition effect		
		$('#mask').fadeIn(1);	
		//$('#mask').fadeTo("fast",0.6);
		$('#mask').fadeTo(0,0.5);
	
		//Get the window height and width
		var winH = $(window).height();
		var winW = $(window).width();
              
		//Set the popup window to center
		$(id).css('top',  winH/2-$(id).height()/2);
		$(id).css('left', winW/2-$(id).width()/2);
		
		/*$('#dialog').css('top',  winH/2-$('#dialog').height()/2);
		$('#dialog').css('left', winW/2-$('#dialog').width()/2);*/
	
		//transition effect
		$(id).fadeIn(2); 
		//$('#dialog').fadeIn(2000); 
	
	});	
});

<%}%>

</script>



<script language="javascript"> 

	function HideLayer(strDiv) {			
			document.getElementById(strDiv).style.visibility = 'hidden';
	}
	function PrintPg(strInfoIndex,strDate,strDate2)
	{
		var loadPg = "./pos_print.jsp?info_index="+strInfoIndex+"&TRANSACTION_DATE="+strDate+"&TRANSACTION_DATE2="+strDate2;	
		var win=window.open(loadPg,"myfile",'dependent=no,width=350,height=350,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function FocusField() {
		document.form_.scan_id.focus();
	}
	
	function PageAction(strAction,strInfoIndex,strOrderIndex){
		if(strAction == '0'){
			if(!confirm("Are you sure you want to delete this customer transaction?"))
				return;
		}
		document.form_.page_action.value = strAction;
		
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
			
		if(strOrderIndex.length > 0)
			document.form_.order_index.value = strOrderIndex;
		
		if(strAction == "2"){
			document.form_.pos_sales_main_index.value = "";
//			document.form_.info_index.value = "";
		}
		

		document.form_.submit();
	}
	
	function Cancel() {
			
		//in new order. its ok to cancel. 
		//it will delete all the ordered items and update the inventory.
		//
		if(document.form_.prepareToEdit.value == "0") //new order, in here i will update the distribution inventory and destroy the session
			document.form_.cancel_transaction.value = "1";
		else{
			document.form_.cancel_edited_order.value = "1";//edit order. if edit order i will destroy the session only.
		}
						
		document.form_.page_action.value = "";
		document.form_.info_index.value = "";
		document.form_.order_index.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.submit();
		
	}

	function SearchCollection(strKeyCode){
		if(strKeyCode == '13'){
			document.form_.submit();	
		}
	}
	function LaunchPOS(strStudIndex) {
		var loadPg = "./pos_orders.jsp?stud_="+strStudIndex;	
		var win=window.open(loadPg,"myfile",'fullscreen=yes,dependent=no, scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function EditTransaction(strPOSMainIndex,strStudIndex,strInfoIndex){
	
		document.form_.pos_sales_main_index.value = strPOSMainIndex;
		document.form_.info_index.value = strInfoIndex;
		document.form_.prepareToEdit.value = "1";
		document.form_.edit_called.value = "1";		
		document.form_.submit();
		/*var loadPg = "./pos_orders.jsp?stud_="+strStudIndex+"&order_index="+strPOSMainIndex;	
		var win=window.open(loadPg,"myfile",'fullscreen=yes,dependent=no, scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();*/
	}	
	
	
	
	
	
	
	//////////////////////// FROM POS_ORDERS.JSP ////////////////////////////////
	
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

function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}

function navButtonRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'navButton-highlight' : 'navButton';
}

function Qty(strQty) {

	var strItemIndex  = document.form_.order_item_init.value;
	var strOrderIndex = document.form_.order_index_init.value;	
	
	if(strItemIndex.length > 0) 
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

var strIsBeverage;
var strCatgItemIndex;
var strStudIndex = "";
var strItemCode;


function AddItem(strItemIndex, strItemCatgIndex, strICode) {//strICode = strItemCode in the ajax
	strCatgItemIndex = strItemCatgIndex;
	strItemCode = strICode;

	document.form_.order_item_init.value  = strItemIndex;
	document.form_.input_qty.focus();
	document.getElementById('blink_text').innerHTML = "Enter Qty";
}


if(strStudIndex.length == 0)	
	strStudIndex = <%=strUserIndex%>;
	

function AddItemFinalize() {
	var strItemIndex  = document.form_.order_item_init.value;
	var strOrderIndex = document.form_.order_index_init.value;
	
	if(strItemIndex.length == 0 || strOrderIndex.length == 0) {
		alert("No Item Selected");
		return;
	}
	
	if(document.form_.input_qty.value.length == 0) {
		alert("Please enter quantity to add");
		document.form_.input_qty.focus();
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
	this.setEIP(false);
	var objOrderItem = document.getElementById("order_info");
	this.InitXmlHttpObjectMultiple(objOrderItem,document.getElementById("order_summary"),document.getElementById("coa_info"));//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=5001&update_main=1&qty="+strQty+"&item_index="+strItemIndex+
		"&order_index="+strOrderIndex+"&stud_="+strStudIndex+"&is_beverage="+strIsBeverage+"&c_info="+strCatgItemIndex;		
	if(strItemCode.length > 0)			
		strURL += "&search_by_item_code=1&item_code="+strItemCode;
		
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
	this.InitXmlHttpObjectMultiple(objOrderItem, document.getElementById("order_summary"), document.getElementById("coa_info"));//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	initDiv();
	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=5003&update_main=1&item_index="+strItemIndex+"&is_beverage="+strIsBeverage+"&c_info="+strCatgItemIndex+
	"&terminal_ip_index="+document.form_.terminal_ip_index.value;;
	
	
	
	if(strItemCode.length > 0){
		/**
		i made it like this bec. when the user reload the page in the state of ordering, 
		the value of strItemCode, strIsBeverage, strCatgItemIndex becomes undefined bec. it is not initialize.
		so when the user reload, i initialize it to zero.
		*/
		if(strItemCode == "0")//i make it like this so it will return list of categories not list of items
			strItemCode = "";
		
		strURL += "&search_by_item_code=1&item_code="+strItemCode;
		
		if(strItemCode == "")//i make it like this so it will return list of categories not list of items
			strItemCode = "0";
	}
	
	this.processRequest(strURL);	
}

function AjaxOrderTable() {

	if(strCatgItemIndex == undefined)
		strCatgItemIndex = "0";
	if(strItemCode == undefined)
		strItemCode = "0";
	if(strIsBeverage == undefined)
		strIsBeverage = "0";

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
	document.form_.item_code.value = "enter item code";
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


function searchItemByItemCode(strKeyCode){
	if(strKeyCode != '13')
		return;
 	var objCOAInput = document.getElementById("coa_info");
	strItemCode = document.form_.item_code.value;
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=5005&search_by_item_code=1&item_code="+strItemCode+
	"&terminal_ip_index="+document.form_.terminal_ip_index.value; 	
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


function CancelOrder(){
	//document.form_.page_action.value = "0";
	document.form_.pos_sales_main_index.value = "";
	document.form_.submit();
}


function SaveOrder(){
	document.form_.item_code.value = "";
	document.form_.submit();	
}

function HideMe(){
if(document.getElementById('payee_name_external'))	{
	if(document.form_.payment_type.value=="1"){
		showLayer('payee_name_external');
		hideLayer('payee_name_internal');
	}else{		
		hideLayer('payee_name_external');
		showLayer('payee_name_internal');
	}
}
}

	
	
</script>








<body bgcolor="#6666B3" onLoad="FocusField();JSClock();AjaxOrderTable();">
<form name="form_" action="./pos.jsp" method="post">

	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" colspan="6" align="center"><font color="#FFFFFF" size="+2">
				<strong><%=(String)vIPResult.elementAt(3)%> - POS TERMINAL</strong></font></td>
		</tr>
		<tr>
			<td width="2%" height="25" >&nbsp;</td>
			<td height="25" colspan="5"><strong><font color="#FFFF00" size="2"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
		    <td height="25">&nbsp;</td>
		    <td><font color="#FFFFFF">Accounts:</font></td>
		    <td>
			<select name="payment_type" onChange="HideMe();">
          <option value="0">Internal</option>
          <%
if(WI.fillTextValue("payment_type").compareTo("1") ==0){%>
          <option value="1" selected>External</option>
          <%}else{%>
          <option value="1">External</option>
          <%}%>
        </select>
			</td>
		    <td>&nbsp;</td>
		    <td>&nbsp;</td>
		    <td>&nbsp;</td>
	    </tr>
		<tr>
			<td width="2%" height="25">&nbsp;</td>
			<td width="13%"><font color="#FFFFFF">Scan/Enter ID :&nbsp;</font></td>
			<td width="27%">
				<input name="scan_id" type="text" class="textbox" value="<%=WI.fillTextValue("scan_id")%>"
					style="font-size:20px; color: #FF0000;height:27px; width: 200px; border: 1px solid #6666B3;"
					size="16" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'
					onkeyup="javascript:SearchCollection(event.keyCode);">		  </td>
			<td width="14%">
			<input type="button" name="list" value=" List Transactions " 
					style="font-size:11px; height:25px;border: 1px solid #FF0000;" 
					onClick="javascript:SearchCollection('13');">			</td>
			
		    <td width="10%">
			<%if(strUserIndex != null) {%>
				<!--	<input type="button" name="list" value=" Launch POS" 
						style="font-size:11px; height:25px;border: 1px solid #FF0000;" 
						onClick="javascript:LaunchPOS('<%//=strUserIndex%>');">-->

				<%
				if(strDisabled == null){
				%>

				<a href="#dialog" name="modal" title="Launch POS"><input type="button" name="list__" value="Launch POS" 
					style="font-size:11px; height:25px;border: 1px solid #FF0000;"></a>
				<%}%>
			<%}%>			</td>
		    <td width="34%">&nbsp;			</td>
		</tr>
		<tr>
			<td colspan="6" ><hr size="1" color="#FFCC00"></td>
		</tr>
	<%if(vStudInfo != null) {%>
		<tr>
			<td height="25">&nbsp;</td>
			<td><font color="#FFFFFF">Name:</font></td>
	  	  	<td>
				<%
					if(!bolIsStaff)
						strTemp = WebInterface.formatName((String)vStudInfo.elementAt(0), (String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),4);
					else
						strTemp = WebInterface.formatName((String)vStudInfo.elementAt(1), (String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),4);
				%>
				
				<div id="payee_name_internal"><font color="#FFFFFF"><strong><%=strTemp%></strong></font></div>
				
				<div id="payee_name_external">					
					<input name="payee_name" type="text" class="textbox" value="<%=WI.fillTextValue("payee_name")%>"
						size="20" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'>
				</div>
				
				</td>
			<td colspan="3">
				<%
					if(!bolIsStaff){
						if(bolIsStudEnrolled)
							strTemp = "Currently Enrolled";
						else
							strTemp = "Not Currently Enrolled";
					}
					else
						strTemp = (String)vStudInfo.elementAt(16);
				%>
				<font color="#FFFFFF">Status: <strong><%=strTemp%></strong></font></td>
		</tr>
		<tr>
			<td height="25" >&nbsp;</td>
			<td>
				<%
					if(!bolIsStaff)
						strTemp = "Course/Major";
					else{
						if(bolIsSchool)
							strTemp = "College";
						else
							strTemp = "Division";
						strTemp += "/Office:";
					}
				%>
				<font color="#FFFFFF"><%=strTemp%></font></td>
			<td colspan="4">
				<%
					if(!bolIsStaff){
						strTemp = WI.getStrValue((String)vStudInfo.elementAt(7));
						strErrMsg = WI.getStrValue((String)vStudInfo.elementAt(8));
						if(strErrMsg.length() > 0)
							strTemp += "/" + strErrMsg;
					}
					else{
						strTemp = WI.getStrValue((String)vStudInfo.elementAt(13));
						strErrMsg = WI.getStrValue((String)vStudInfo.elementAt(14));
						if(strErrMsg.length() > 0)
							strTemp += "/" + strErrMsg;
					}
				%>
				<font color="#FFFFFF"><strong><%=strTemp%></strong></font></td>
		</tr>
		<tr valign="top">
			<td height="30" >&nbsp;</td>
			<td style="padding-top: 5px">
				<%
					if(!bolIsStaff)
						strTemp = "Year:";
					else
						strTemp = "Designation:";
				%>
				<font color="#FFFFFF"><%=strTemp%></font></td>
			<td style="padding-top: 5px">
				<%
					if(!bolIsStaff){
						if(bolBasicStudent)
							strTemp = dbOP.getBasicEducationLevel(Integer.parseInt((String)vStudInfo.elementAt(14)));
						else
							strTemp = astrConvertYrLevel[Integer.parseInt((String)vStudInfo.elementAt(14))];
					}
					else
						strTemp = (String)vStudInfo.elementAt(15);
				%>
				<font color="#FFFFFF"><strong><%=strTemp%></strong></font></td>
			<td colspan="2" valign="top">
				<table border="0">
					<tr>
						<td><font color="#FFCC00">Card Balance:</font></td>
						<td><font size="+2" color="#FFCC00"><strong><%=CommonUtil.formatFloat(dBalance, true)%></strong></font>
						<input type="hidden" name="dBalance" value="<%=dBalance%>" /></td>
					</tr>
				</table></td>
			<td>
				<table border="0">
					<tr>
						<td><font color="#FFCC00">Todays remaining usage:</font></td>
						<td align="right"><font color="#FFCC00" size="+2"><strong>
							<%=CommonUtil.formatFloat(dUsableToday, true)%></strong><br/></font></td>
							<input type="hidden" name="dUsableToday" value="<%=dUsableToday%>" /> 
					</tr>
					<tr>
						<td><font color="#FFCC00">Todays usage:</font></td>
						<td align="right"><font color="#FFCC00" size="+2"><strong>
							<%
								if(vCardDetails != null && vCardDetails.size() > 0){
									strTemp  = WI.getStrValue((String)vCardDetails.elementAt(2), "0");
									dBalance = Double.parseDouble(strTemp);
							%>
								<%=CommonUtil.formatFloat(dBalance, true)%>
							<%}%>
						</strong></font></td>
					</tr>
				</table></td>
		</tr>
		<tr>
			<td colspan="6" ><hr size="1" color="#FFCC00"></td>
		</tr>
		<tr valign="top">
			<td height="30" colspan="2">
				<!-- First Table -->
				<table border="0" width="100%">
					<tr>
						<td>
							<%
								strTemp = strStudID;
								if (vStudInfo != null && vStudInfo.size() > 0){
									strTemp = "../../upload_img/"+strTemp+"."+strImgFileExt;
									strTemp = "<img src=\""+strTemp+"\" width=130 height=130 border='1'>";
								}%>
								<%=strTemp%></td>
					</tr>
			  </table>			</td>
			<td>
				<!-- Second Table -->
				<div style="overflow:auto; width:auto; height:175px">
				<table border="0" width="100%">
					<tr>
						<td>
						<%
						strTemp = "";
						if(vAllergies != null){%>
							<font color="#FFCC00" size="+1"><strong>Allergy:</strong></font>
							<font color="#FFFFFF" size="+1"><br/> 
								<%for(i = 0; i < vAllergies.size(); i += 2){
									if(strTemp.length() > 0)
										strTemp += ", "+(String)vAllergies.elementAt(i + 1);
									else
										strTemp = (String)vAllergies.elementAt(i + 1);
								}%>
								<%=strTemp%>							</font>							
						<%}%></td>
					</tr>
					<tr>
						<td>
						<%if(vAllergies != null && vFoodPD != null){%>
							<hr size="1" color="#FFCC00">
						<%}
						strTemp = "";
						if(vFoodPD != null){%>
							<font color="#FFCC00" size="+1"><strong> Preference :</strong></font>
							<font color="#FFFFFF" size="+1"><br/> 
							<%for(i = 0; i < vFoodPD.size(); i += 3){
								if(strTemp.length() > 0)
									strTemp += ", ";
								if(((String)vFoodPD.elementAt(i + 2)).equals("1")){
									strTemp += "<font color=\"#003399\">";
									strTemp += (String)vFoodPD.elementAt(i + 1);
									strTemp += "</font>";
								}
								else
									strTemp += (String)vFoodPD.elementAt(i + 1);
							}%>
						  <%=strTemp%>						  </font>
						<%}%></td>
					</tr>
			  </table>
				</div>			</td>
			<td colspan="3">
				<!-- Third Table -->
				<table border="0" width="100%">
			  		<tr>
				  		<td width="23%" style="font-weight:bold; color:#FFFFFF; font-size:14px;">Transaction Date:</td>
						<td width="77%" style="font-weight:bold; color:#FFFFFF; font-size:14px;"><%=WI.formatDate(WI.getTodaysDate(1), 6)%></td>
					</tr>
					<tr>
				  		<td style="font-weight:bold; color:#FFFFFF; font-size:14px;">Amount:</td>
						<input type="hidden" name="dAmount" value="<%=strAmtOrdered%>" />
						
						
						
						<%
						strTemp = "";
						
						
						if(WI.fillTextValue("cancel_edited_order").length() > 0){
							request.getSession(false).removeAttribute("order_items");
							strAmtOrdered = "";
						}
						
						
						
						Vector vOrders = (Vector)request.getSession(false).getAttribute("order_items");				
						//System.out.println("vOrders "+vOrders);									
						if(vOrders != null && vOrders.size() > 0){
							for(i = 1; i < vOrders.size(); i+=11){
								if(strTemp.length() == 0)
									strTemp = (String)vOrders.elementAt(i+1) +"\t("+(String)vOrders.elementAt(i+3)+")\t"+(String)vOrders.elementAt(i+9);
								else
									strTemp += "\r\n" + (String)vOrders.elementAt(i+1) +"\t("+(String)vOrders.elementAt(i+3)+")\t"+(String)vOrders.elementAt(i+9);
								
							}
						}
												
						if(strAmtOrdered != null && strAmtOrdered.length() > 0 && vOrders != null && vOrders.size() > 0)
							strAmtOrdered = CommonUtil.formatFloat(strAmtOrdered,true);		
						else
							strAmtOrdered = "";
						
						
						if(vOrders != null && vOrders.size() < 1)
							strAmtOrdered = "";
																		
						%>
						<td>
				  			<input type="text" name="amount" size="32" maxlenght="64" class="textbox"  value="<%=strAmtOrdered%>"
								onfocus="style.backgroundColor='#D3EBFF'" 
								onBlur="AllowOnlyFloat('form_','amount');style.backgroundColor='white'" <%=strDisabled%> 
								onkeyup="AllowOnlyFloat('form_','amount');" 
							 	readonly="yes"	
								style="font-size:20px; font-weight:bold; color: #FF0000;height:27px; width: 200px; border: 1px solid #6666B3;"></td>
					</tr>
					<tr>
				  		<td valign="top" style="font-weight:bold; color:#FFFFFF; font-size:14px;"><br>Transaction Detail:</td>
						<td>
				  			<textarea name="transaction_note" cols="65" rows="8" class="textbox" 
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" <%=strDisabled%> 
								style="color: #FF0000;border: 1px solid #6666B3; font-size:11px;" readonly="readonly"><%=strTemp%></textarea></td>
					</tr>
					<tr>
						<td></td>
						<td height="35">
							<%if(iAccessLevel > 1){
								if(strPrepareToEdit.equals("0")){
							%>
								<input type="button" name="save" value=" Save Transaction " <%=strDisabled%>
									style="font-size:11px; height:25px;border: 1px solid #FF0000;" 
									onClick="javascript:PageAction('1','','');">
								
								&nbsp;&nbsp;&nbsp;
								<input type="button" value=" Cancel Transaction " 
									style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="Cancel();">	
									
								<%}else{%>
								<input type="button" name="edit" value=" Edit Transaction " <%=strDisabled%>
									style="font-size:11px; height:25px;border: 1px solid #FF0000;" 
									onClick="javascript:PageAction('2','','');">								
								<%}%>
								
							<%}//if page action > 1%></td>
					</tr>	
			  </table>			</td>
		</tr>
		<tr>
			<td colspan="6" ><hr size="1" color="#FFCC00"></td>
		</tr>
	<%}%> 
</table>





			
<%if(vRetResult != null) {%>
	<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
		<tr bgcolor="#DDDDEE"> 
			<td height="25" class="thinborder" align="center">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td width="85%" align="center"><font color="#FF0000"><strong>LIST OF TRANSACTIONS </strong></font></td>
						<td width="15%" align="right">
							<font size="2" color="#FF0000">Total:<strong><%=(String)vRetResult.remove(0)%></strong></font></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr bgcolor="#FFFFFF">
			<td width="72%" class="thinborderLEFT"><strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=pos.getDisplayRange()%></strong>)</strong></td>
			<td width="28%" class="thinborderRIGHT" height="25"> &nbsp;
		<%
			int iPageCount = 1;
			iPageCount = iSearchResult/pos.defSearchSize;		
			if(iSearchResult % pos.defSearchSize > 0) 
				++iPageCount;
			strTemp = " - Showing("+pos.getDisplayRange()+")";
			
			if(iPageCount > 1){%> 
				<div align="right">Jump To page: 
				<select name="jumpto" onChange="SearchCollection('13');">
				<%
					strTemp = WI.fillTextValue("jumpto");
					if(strTemp == null || strTemp.trim().length() ==0)
						strTemp = "0";
					i = Integer.parseInt(strTemp);
					if(i > iPageCount)
						strTemp = Integer.toString(--i);
		
					for(i =1; i<= iPageCount; ++i ){
						if(i == Integer.parseInt(strTemp) ){%>
							<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}else{%>
							<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}
					}
				%>
				</select>
		<%}%></div></td>
		</tr>
	</table>
	
	<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
		<tr style="font-weight:bold" align="center">
			<td height="25" align="center" class="thinborder" width="16%">Operation</td>
			<td align="center" class="thinborder" width="10%">Reference</td> 
			<td align="center" class="thinborder" width="">Transaction Note</td> 
			<td align="center" class="thinborder" width="15%">Transaction Date</td>  
			<td align="center" class="thinborder" width="10%">Amount</td>
		</tr>
	<%for(i = 0; i < vRetResult.size(); i += 13){%>	
		<tr> 
			<td height="25" class="thinborder" align="center">&nbsp;
				<a href="javascript:PrintPg(<%=(String)vRetResult.elementAt(i)%>,'<%=WI.fillTextValue("TRANSACTION_DATE")%>','<%=WI.fillTextValue("TRANSACTION_DATE2")%>');">
					<img src="../../images/print.gif" border="0" /></a>
				&nbsp;
				<a href="javascript:EditTransaction('<%=(String)vRetResult.elementAt(i+10)%>','<%=strUserIndex%>','<%=(String)vRetResult.elementAt(i)%>');"><img src="../../images/edit.gif" border="0" /></a>
				&nbsp;
				<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>','<%=(String)vRetResult.elementAt(i+10)%>');"><img src="../../images/delete.gif" border="0" /></a></td>	
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder" align="right">
				<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+4), true)%>&nbsp;</td>
		</tr>
	<%}//End of vTransResut%>
		<tr bgcolor="#DDDDEE"> 
			<td height="25" colspan="5" class="thinborder" align="center">&nbsp;	  </td>
		</tr>
	</table> 
<%}%>

<%
if(WI.fillTextValue("scan_id").length() > 0){

Vector vTemp = rPOS.operateOnFloatingOrders(dbOP, request, 4);
if(vTemp != null && vTemp.size() > 0){
%>

<script>
	alert("User account has order(s) from other canteen, please settle this account.");
</script>

<div id="processing" class="processing">
<table cellpadding=0 cellspacing=0 border=0 Width=100% align=Center class="thinborderALL">
  <!--<tr><td height="14" align="right" valign="top"><a href="javascript:HideLayer('processing')">Close Window X</a></td>
  </tr>	 --> 	  
  <tr><td height="14" align="center" valign="top"><u><b>ORDERS FROM OTHER CANTEEN</b></u></td>
  </tr>
  <tr>
	  <td valign="top">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">			
			  <tr>
			  	<td width="70%" style="font-size:11px;"><u>Item Name</u></td>
				<td align="center" width="15%" style="font-size:11px;"><u>Qty</u></td>
				<td align="center" width="15%" style="font-size:11px;"><u>Amount</u></td>
			  </tr>	
			  
			  <%
			  String strDeptName = "";
			  String strPrevDeptName = "";
			  Vector vTemp2 = new Vector();
			  for(int x = 0; x < vTemp.size(); x+=10){
			  	if(strTerminalIPIndex.equals((String)vTemp.elementAt(x+7))) //if the floating orders is same canteen then dont show
					continue;
			  	
				vTemp2 = (Vector)vTemp.elementAt(x+8);
			  	strDeptName = (String)vTemp.elementAt(x+6);
			  	if(!strPrevDeptName.equals(strDeptName)){
					strPrevDeptName = strDeptName;
			  %>
			  
			  <tr>
			  	<td colspan="3" align="center" style="font-size:11px;"><%=strDeptName%> 
					<%=WI.getStrValue(CommonUtil.formatFloat((String)vTemp.elementAt(x+9),true)," - TOTAL AMOUNT : ", "","")%></td>
			  </tr>
			  
			  	<%}%>
			 <%for(int j = 0; j < vTemp2.size(); j+=3){%>
				<tr>
					<td><font size="1"><%=(String)vTemp2.elementAt(j)%></font></td>
					<td align="center"><font size="1"><%=(String)vTemp2.elementAt(j+1)%></font></td>
					<td align="right"><font size="1"><%=CommonUtil.formatFloat((String)vTemp2.elementAt(j+2),true)%></font></td>		
								
				</tr>
			<%}%>
			  
			  <%}%>
			  		
		</table>
	  </td>
  </tr>
</table>
</div>
<%}
}
%>



<!------------------------------------------------------------------------------------------------------------------------------------------------------->
<!-------------------------------------------------------------------ORDERING POS BEGINS HERE------------------------------------------------------------>
<!------------------------------------------------------------------------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------------------------------------------------------------------->

<div id="boxes">
	<div id="dialog" class="window" style="top:10px;">
	<!--<div id="dialog" style="top:10px;">-->


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#A9B9D1">
  	<tr>
       <td width="28%" height="29" valign="top" bgcolor="#D2ACCD" class="thinborderALL"> 
	   	<font color="#000066" size="1"><b>Date: </b></font><font color="#0000FF" size="2"><%=WI.getTodaysDate(1)%><br />
		<label id="dispClk" style="font-size:16px;"></label>
		</font></td>     
  </tr>
</table>
<table width="100%" border="0" cellpadding="1" cellspacing="1" bgcolor="#A9B9D1">
	<tr>
		<!--<td height="29">
			<input type="button" name="cancel_order" value="CANCEL ORDER" style="font-size:15px; height:35px;border: 1px solid #FF0000;" 
			onClick="javascript:CancelOrder();" />			
		</td>-->
		<td height="29" align="">
			<input type="button" name="save" 
				value="RELOAD SCREEN" onclick="document.form_.edit_called.value = '1';document.form_.submit();" 
				style="font-size:15px; height:35px;border: 1px solid #FF0000;"/>
		</td>
		<td height="29" align="right">
			<!--<input type="button" name="save" value="SAVE ORDER" style="font-size:15px; height:35px;border: 1px solid #FF0000;" 
			onClick="javascript:SaveOrder();" />-->
			<input type="button" name="save" value="CLOSE SCREEN" style="font-size:15px; height:35px;border: 1px solid #FF0000;" 
			onClick="javascript:SaveOrder();" />
		</td>
	</tr>
</table>


  <table width="100%" border="0" cellpadding="1" cellspacing="1" bgcolor="#A9B9D1">
  <tr>
    <td width="50%" height="288"  valign="top" class="thinborderALL">			
			<div class="orderItems" id="div_items"><label id="order_info" style="font-size:11px; font-family:Verdana, Arial, Helvetica, sans-serif"></label></div>
     </td>
    <td width="50%" class="thinborderALL"  valign="top" >
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr bgcolor="#8FDA8F">
        <td width="25%" height="38">
			<input type="button" name="save" value="  MAIN MENU " style="font-size:15px; height:35px;border:1px solid #FF0000;" 
			onClick="javascript:loadCategories('1');" /></td>
        <%
		strTemp = WI.fillTextValue("item_code");
		if(strTemp.length() == 0)
			strTemp = "enter item code/item name";
		%>
		<td width="75%" align="center">
			<!--<input type="text" name="item_code" value="" height="20" />-->
			<input type="text" name="item_code" class="textbox"
				 style="text-align:center; height:25px; font-size:23px;"  value="<%=strTemp%>" 
				 onkeyup="searchItemByItemCode(event.keyCode);" 
				 onblur="if(this.value == '')this.value = 'enter item code/item name'"
				 onFocus="if(this.value=='enter item code/item name')this.value='';"><br>			
				 <font size="1">and press ENTER</font>
		</td>
      </tr>
      <tr>
        <td height="25" colspan="2" valign="top" bgcolor="#EBEBEB">
				<div class="itemListing" align="center"><label id="coa_info" style="font-size:11px; font-family:Verdana, Arial, Helvetica, sans-serif"></label></div></td>
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
    <td height="40" align="center" class="thinborderALL" valign="middle" style="font-size:24px; font-weight:bold;" >QTY : 
	
	<input type="text" name="input_qty" value="" size="12" style="font-size:24px; font-weight:bold; height:40px;">
	
	<input type="button" name="add_item" id="add_item" value="ADD ITEM" onClick="AddItemFinalize();" 
		class='navButton' onmouseover="navButtonRollOver('add_item', 'on')" onMouseOut="navButtonRollOver('add_item', 'off')"
		style="font-size:15px; height:40px; border:1px solid #FF0000;">	
	
	&nbsp;&nbsp;
	<label id="blink_text" style="font-size:16px; font-weight:bold; color:#FF0000; position:absolute;"></label>
	</td>
  </tr>
  
  
  <tr>
	<td height="60" align="center" class="thinborderALL" >
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#A9B9D1">
			<tr>
				<td align="center">
				<input type="button" name="___1" id="___1" value="1" onClick="Qty('1');" 
					class='navButton' onmouseover="navButtonRollOver('___1', 'on')" onMouseOut="navButtonRollOver('___1', 'off')"
					style="font-size:15px; height:40px; width:70px;border: 1px solid #FF0000;"> 
				<input type="button" name="___2" id="___2" value="2" onClick="Qty('2');" 
					class='navButton' onmouseover="navButtonRollOver('___2', 'on')" onMouseOut="navButtonRollOver('___2', 'off')"
					style="font-size:15px; height:40px; width:70px;border: 1px solid #FF0000;"> 
				<input type="button" name="___3" id="___3" value="3" onClick="Qty('3');" 
					class='navButton' onmouseover="navButtonRollOver('___3', 'on')" onMouseOut="navButtonRollOver('___3', 'off')"
					style="font-size:15px; height:40px; width:70px;border: 1px solid #FF0000;"> 
				<input type="button" name="___4" id="___4" value="4" onClick="Qty('4');" 
					class='navButton' onmouseover="navButtonRollOver('___4', 'on')" onMouseOut="navButtonRollOver('___4', 'off')"
					style="font-size:15px; height:40px; width:70px;border: 1px solid #FF0000;"> 
				<input type="button" name="___5" id="___5" value="5" onClick="Qty('5');" 
					class='navButton' onmouseover="navButtonRollOver('___5', 'on')" onMouseOut="navButtonRollOver('___5', 'off')"
					style="font-size:15px; height:40px; width:70px;border: 1px solid #FF0000;"> 
				<input type="button" name="___6" id="___6" value="6" onClick="Qty('6');" 
					class='navButton' onmouseover="navButtonRollOver('___6', 'on')" onMouseOut="navButtonRollOver('___6', 'off')"
					style="font-size:15px; height:40px; width:70px;border: 1px solid #FF0000;"> 
				</td>				
			</tr>
			<tr><td height="2"></td></tr>
			<tr>
				<td align="center">				
				<input type="button" name="___7" id="___7"  value="7" onClick="Qty('7');" 
					class='navButton' onmouseover="navButtonRollOver('___7', 'on')" onMouseOut="navButtonRollOver('___7', 'off')"
					style="font-size:15px; height:40px; width:70px;border: 1px solid #FF0000;"> 
				<input type="button" name="___8" id="___8"  value="8" onClick="Qty('8');" 
					class='navButton' onmouseover="navButtonRollOver('___8', 'on')" onMouseOut="navButtonRollOver('___8', 'off')"
					style="font-size:15px; height:40px; width:70px;border: 1px solid #FF0000;">
				<input type="button" name="___9" id="___9"  value="9" onClick="Qty('9');" 
					class='navButton' onmouseover="navButtonRollOver('___9', 'on')" onMouseOut="navButtonRollOver('___9', 'off')"
					style="font-size:15px; height:40px; width:70px;border: 1px solid #FF0000;"> 
				<input type="button" name="___0" id="___0"  value="0" onClick="Qty('0');" 
					class='navButton' onmouseover="navButtonRollOver('___0', 'on')" onMouseOut="navButtonRollOver('___0', 'off')"
					style="font-size:15px; height:40px; width:70px;border: 1px solid #FF0000;">
				<input type="button" name="___clear" id="___clear"  value="CLEAR" onClick="Qty('');" 
					class='navButton' onmouseover="navButtonRollOver('___clear', 'on')" onMouseOut="navButtonRollOver('___clear', 'off')"
					style="font-size:15px; height:40px; width:143px;border: 1px solid #FF0000;">
				</td>
			</tr>
		</table>
	</td>
  </tr>
</table>

	</div>
		<div id="mask"></div>
	
</div>






<script>HideMe()</script>



	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>"  />
	<input type="hidden" name="terminal_ip_index" value="<%=strTerminalIPIndex%>" />
	<input type="hidden" name="order_index"  value="<%=strOrderIndex%>"/>
	<input type="hidden" name="cancel_transaction" />
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>"  />
	<input type="hidden" name="cancel_edited_order" value="" />
	
	<input type="hidden" name="search_from_pos" value="1" /><!--used in searching for floating orders-->
	
	<input type="hidden" name="edit_called" value="" />	
	<input type="hidden" name="save_called" value="<%=WI.fillTextValue("save_called")%>" />

	<input type="hidden" name="order_item_init">
	<input type="hidden" name="order_index_init" value="<%=strOrderIndex%>">

	<input type="hidden" name="pos_sales_main_index" value="<%=WI.fillTextValue("pos_sales_main_index")%>"  />
</form>		
</body>
</html>

<%
dbOP.cleanUP();
%>
