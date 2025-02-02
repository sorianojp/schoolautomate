<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function SetFocus(){
	document.form_.po_no.focus();
}

function ProceedClicked(){
	document.form_.page_action.value = "";
	document.form_.proceedClicked.value = "1";
	document.form_.submit();
}

function PrintIssuance(strIssuanceNo){
	//var pgLoc = "./issuance_form_print.jsp?po_no="+strIssuanceNo;//use this to get only the issuance info
	var pgLoc = "./issuance_form_print.jsp?po_no="+document.form_.po_number_val.value+
		"&issuance_no="+strIssuanceNo;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function OpenSearchPO(){
	var pgLoc = "../purchase_order/purchase_request_view_search.jsp?opner_info=form_.po_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function OpenSearchIssuance(){
	var pgLoc = "./issuance_view_search.jsp?opner_info=form_.po_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

///////////////////////////////////////// used to collapse and expand filter ////////////////////
var openImg = new Image();
openImg.src = "../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../images/box_with_plus.gif";

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


function checkAllSaveItems() {
	var maxDisp = document.form_.item_count.value;
	var bolIsSelAll = document.form_.selAllSaveItems.checked;
	for(var i =1; i <= maxDisp; ++i)
		eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
}

function checkAllDelItems() {
	var maxDisp = document.form_.item_count_delete.value;
	var bolIsSelAll = document.form_.selAllDelItems.checked;
	for(var i =1; i <= maxDisp; ++i)
		eval('document.form_.issue_item_index_'+i+'.checked='+bolIsSelAll);
}


	function toggleSel(objQty, objChkBox){
		if(objQty.value.length > 0)
			objChkBox.checked = true;
		else
			objChkBox.checked = false;
	}

function CheckQty(strAvailQty, strCount){
	var strIntVal = eval('document.form_.qty_'+strCount);
	var strSave   = eval('document.form_.save_'+strCount);
	if(parseInt(strAvailQty) < parseInt(strIntVal.value)){
		alert("Cannot proceed, available qty is low than issue qty.");
		if(strIntVal.value.length > 1)
			strIntVal.value = strIntVal.value.substring(0, strIntVal.value.length - 1);
		else
			strIntVal.value = "";
			
		toggleSel(strIntVal, eval('document.form_.save_'+strCount));
	}
		
}

function PageAction(strAction){

if(strAction != "0"){
	if(document.form_.autogenerate.checked == false || document.form_.add_to_existing_issuance.checked == true){
		var strIssueNo = prompt("Please provide Issuance Number","");
		if(strIssueNo.length == 0)
			return;
		document.form_.issuance_number.value = strIssueNo;
	}
}


	document.form_.page_action.value = strAction;
	document.form_.proceedClicked.value = "1";
	document.form_.submit();
}

function Cancel(){
	var maxDisp = document.form_.item_count.value;
	document.form_.selAllSaveItems.checked = false;
	for(var i =1; i <= maxDisp; ++i){
		eval('document.form_.save_'+i+'.checked=false');
		eval('document.form_.qty_'+i+'.value=""');
	}
}

///////////////////////////////////////// End of collapse and expand filter ////////////////////
</script>
<body bgcolor="#D2AE72" onLoad="SetFocus()">
<%@ page language="java" import="utility.*,purchasing.IssuanceMgmt,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-DELIVERY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-DELIVERY-View delivery update Status","delivery_update_status.jsp");
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


	
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	
	
	
	IssuanceMgmt issueMgmt = new IssuanceMgmt();
	Vector vRetResult = null;
	Vector vPOItems = null;
	Vector vIssuanceInfo = null;
	Vector vIssuanceItem = null;
	Vector vPOInfo = null;
	int iElemCount = 0;
	String strPONumber = WI.fillTextValue("po_no");
	boolean bolIsPONumber = false;
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(!issueMgmt.operateOnIssuePOItems(dbOP, request, Integer.parseInt(strTemp)))
			strErrMsg = issueMgmt.getErrMsg();
	}
	
	if(WI.fillTextValue("proceedClicked").length() > 0){
		vPOInfo = issueMgmt.getPOIssueInfo(dbOP, request);
		if(vPOInfo == null)	
			strErrMsg = issueMgmt.getErrMsg();
		else{
			vRetResult = issueMgmt.getPOIssuanceItems(dbOP, request);
			if(vRetResult == null)
				strErrMsg = issueMgmt.getErrMsg();
			else{
				if(issueMgmt.isPONumber()){
					vPOItems = (Vector)vRetResult.elementAt(0);
					vIssuanceInfo = (Vector)vRetResult.elementAt(1);	
				}
			}
		}
	}
	
	bolIsPONumber = issueMgmt.isPONumber();
	if(!bolIsPONumber){
		vIssuanceInfo = issueMgmt.getIssuanceInfo(dbOP, request, null, WI.fillTextValue("po_no"));
		if(vIssuanceInfo != null && vIssuanceInfo.size() > 0)			
			vIssuanceInfo.insertElementAt(Integer.toString(issueMgmt.getElemCount()), 0);
		
		vPOItems = new Vector();
		if(vPOInfo != null && vPOInfo.size() > 0)
			strPONumber = (String)vPOInfo.elementAt(4);
	}
	
	
	
%>	
<form name="form_" method="post" action="issuance_mgmt.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" bgcolor="#A49A6A"><font color="#FFFFFF"><strong>:::: 
      ISSUANCE FORM MANAGEMENT PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%">PO Number / Issuance Number :</td>
      <td width="27%">
			<input type="text" name="po_no" class="textbox" value="<%=WI.fillTextValue("po_no")%>"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="50%"><a href="javascript:OpenSearchPO();"><img src="../../../images/search.gif" border="0"></a><font size="1">click to search po no.</font>
	  <a href="javascript:OpenSearchIssuance();"><img src="../../../images/search.gif" border="0"></a><font size="1">click to search issuance no.</font>
	  </td>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td colspan="4">&nbsp;</td>
    </tr>
  </table>  
<%if(vPOInfo != null && vPOInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="4%" height="26">&nbsp;</td>
	  <%
	  	if(bolIsPONumber)
	  		strTemp = "REQUISITION DETAILS FOR PURCHASE ORDER NO. : ";
		else
			strTemp = "ISSUANCE DETAILS FOR ISSUANCE NO : ";
	  %>
      <td colspan="4" align="center"><strong><%=strTemp%><%=(String)vPOInfo.elementAt(1)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>PO Status:</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vPOInfo.elementAt(3))]%></strong></td>
	  <%
	  	if(bolIsPONumber) strTemp = "PO Date :";
		else strTemp = "Issuance Date :";
	  %>
      <td><%=strTemp%></td>
      <td><strong><%=(String)vPOInfo.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
	  <%
	  	if(bolIsPONumber) strTemp = "Requisition No. :";
		else strTemp = "PO Number :";
	  %>
      <td width="22%"><%=strTemp%></td>
      <td width="28%"><strong><%=(String)vPOInfo.elementAt(4)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"> <strong><%=(String)vPOInfo.elementAt(5)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vPOInfo.elementAt(6))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vPOInfo.elementAt(7)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vPOInfo.elementAt(8))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vPOInfo.elementAt(9)%></strong></td>
    </tr>
    <%if(((String)vPOInfo.elementAt(10)) == null){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=(String)vPOInfo.elementAt(11)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vPOInfo.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vPOInfo.elementAt(10)+"/"+WI.getStrValue((String)vPOInfo.elementAt(11),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vPOInfo.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
    <%}%>
		<input type="hidden" name="supplier_index" value="<%=(String)vPOInfo.elementAt(14)%>">
  </table>
  
  
  
<%


int iCount = 0;
if(vPOItems != null && vPOItems.size() > 1){
iElemCount = Integer.parseInt((String)vPOItems.remove(0));
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td height="25" colspan="9" align="center" bgcolor="#B9B292" class="thinborder"><font color="#FFFFFF"><strong>LIST OF PURCHASE ORDER ITEM(S) DELIVERED </strong></font></td>
    </tr>
    <tr> 
      <td width="4%" height="25" align="center" valign="bottom" class="thinborder"><strong>ITEM#</strong></td>
      
      <td width="10%" align="center" valign="bottom" class="thinborder"><strong>UNIT</strong></td>
      <td width="38%" align="center" valign="bottom" class="thinborder"><strong>ITEM / PARTICULARS / DESCRIPTION </strong></td>
      <td width="12%" align="center" valign="bottom" class="thinborder"><strong>SUPPLIER CODE </strong></td>
      <td width="13%" align="center" valign="bottom" class="thinborder"><strong>BRAND</strong></td>
	  <td width="9%" align="center" valign="bottom" class="thinborder"><strong>UNIT PRICE</strong></td>
	  <%
	  if(bolIsPONumber)
	  	strTemp = "AVAIL<br>QTY";
	else
		strTemp = "ISSUED<br>QTY";
	  %>
	  <td width="5%" align="center" valign="bottom" class="thinborder"><strong><%=strTemp%></strong></td>
	  <%if(bolIsPONumber){%>
	  <td width="4%" align="center" valign="bottom" class="thinborder"><strong>ISSUE<br>QTY</strong></td>
	  <td width="5%" align="center" valign="bottom" class="thinborder"><strong>SELECT ALL <br>
	  </strong>
	  	<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();"></td><%}%>
    </tr>
    <%
	iCount = 0;
	String strPrevDeliveryNo = "";
	String strCurrDeliveryNo = null;
	for(int i = 0;i < vPOItems.size();i+=iElemCount){
		strCurrDeliveryNo = (String)vPOItems.elementAt(i+1);
		if(!strPrevDeliveryNo.equals(strCurrDeliveryNo)){
			strPrevDeliveryNo = strCurrDeliveryNo;
	%>
	<tr>
		<td height="25" colspan="9" class="thinborder"><strong>DELIVERY NO. : <%=strCurrDeliveryNo%></strong></td>
	</tr>
	<%}%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=++iCount%></div></td>
      <td class="thinborder"><%=WI.getStrValue(vPOItems.elementAt(i+4),"&nbsp;")%></td>
	  <%
	  strTemp = WI.getStrValue(vPOItems.elementAt(i+5))+WI.getStrValue((String)vPOItems.elementAt(i+6)," / ","","");
	  %>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vPOItems.elementAt(i+7),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vPOItems.elementAt(i+9),"&nbsp;")%></td>
      <td class="thinborder" align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vPOItems.elementAt(i+8),true),"&nbsp;")%></td>
	  <td class="thinborder" align="center"><%=(int)Double.parseDouble(WI.getStrValue(vPOItems.elementAt(i+3),"0"))%></td>
	  <input type="hidden" name="po_item_index_<%=iCount%>" value="<%=(String)vPOItems.elementAt(i+2)%>">
	  <input type="hidden" name="avail_qty_<%=iCount%>" value="<%=(int)Double.parseDouble(WI.getStrValue(vPOItems.elementAt(i+3),"0"))%>">
	  <%if(bolIsPONumber){%>
	  <td class="thinborder" align="center">
	  <input type="text" autocomplete="off" name="qty_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','qty_<%=iCount%>');style.backgroundColor='white';toggleSel(document.form_.qty_<%=iCount%>, document.form_.save_<%=iCount%>)" 
					onkeyup="AllowOnlyInteger('form_','qty_<%=iCount%>');
						CheckQty('<%=(int)Double.parseDouble(WI.getStrValue(vPOItems.elementAt(i+3),"0"))%>', <%=iCount%>)" size="3" maxlength="5" value=""/>
	  </td>
	  
	  <td class="thinborder" align="center">				
				<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vPOItems.elementAt(i)%>" tabindex="-1" <%=strErrMsg%>></td><%}%>
	  
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="9" class="thinborder"><strong>TOTAL 
        ITEM(S) : <%=iCount%></strong>        <input type="hidden" name="item_count" value="<%=iCount%>">
      </td>
    </tr>
  </table>
<%if(bolIsPONumber){%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 	<tr>
 	    <td width="25%" align="center">&nbsp;</td>
 	    <td width="75%">
			<input type="checkbox" name="autogenerate" value="1">Click to autogenerate issuance number.
			
			<input type="checkbox" name="add_to_existing_issuance" value="1">Click to add item in existing issuance number(Only if not received)
			
		</td>
 	</tr>
 	<tr>
		<td colspan="2" align="center">
		<a href="javascript:PageAction('1');"><img src="../../../images/save.gif" border="0"></a>
		<font size="1">Click to save issuance information.</font>
		
		<a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a>
		<font size="1">Click to save cancel operation.</font>		</td>
	</tr>
 </table>
 
<%}
}//end of vPOItems
  
if(vIssuanceInfo != null && vIssuanceInfo.size() > 1){
iElemCount = Integer.parseInt((String)vIssuanceInfo.remove(0));
String strIssuanceNo = null;
String strIssuanceIndex = null;
while(vIssuanceInfo.size() > 0){

	strIssuanceIndex = (String)vIssuanceInfo.remove(0);		
	strIssuanceNo = (String)vIssuanceInfo.remove(0);	
	
	vIssuanceItem = issueMgmt.getIssuanceItems(dbOP, request, strIssuanceIndex);
	if(vIssuanceItem == null)
		vIssuanceItem = new Vector();
	else
		iElemCount = issueMgmt.getElemCount();

%>	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td>&nbsp;</td><tr>
	<tr><td><hr size="1"></td></tr>
	<tr><td align="right">
		<a href="javascript:PrintIssuance('<%=strIssuanceNo%>');"><img src="../../../images/print.gif" border="0"></a>
	</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="4%" height="25">&nbsp;</td>
		<td width="22%">Issuance No. </td>		
		<td><%=strIssuanceNo%></td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Issued By</td>
		<%
		strTemp = WebInterface.formatName((String)vIssuanceInfo.remove(1),(String)vIssuanceInfo.remove(1),(String)vIssuanceInfo.remove(1),4)+
			WI.getStrValue((String)vIssuanceInfo.remove(0)," (",")","");
		%>
	    <td><%=strTemp%></td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Received By</td>
	   <%
		strTemp = WebInterface.formatName((String)vIssuanceInfo.remove(1),(String)vIssuanceInfo.remove(1),(String)vIssuanceInfo.remove(1),4)+
			WI.getStrValue((String)vIssuanceInfo.remove(0)," (",")","");
		%>
	    <td><%=strTemp%></td>
	    </tr>
		
		<%
		vIssuanceInfo.remove(0);//[10]ISSUANCE_DATE
		vIssuanceInfo.remove(0);//[11]ISSUANCE_DATETIME
		%>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td height="25" colspan="8" align="center" bgcolor="#99CCFF" class="thinborder">
	  	<strong>LIST OF ITEM(S) FOR ISSUANCE NO. : <%=strIssuanceNo%> </strong></td>
    </tr>
    <tr> 
      <td width="4%" height="25" align="center" valign="bottom" class="thinborder"><strong>ITEM#</strong></td>
      
      <td width="10%" align="center" valign="bottom" class="thinborder"><strong>UNIT</strong></td>
      <td align="center" valign="bottom" class="thinborder"><strong>ITEM / PARTICULARS / DESCRIPTION </strong></td>
      <td width="12%" align="center" valign="bottom" class="thinborder"><strong>SUPPLIER CODE </strong></td>
      <td width="13%" align="center" valign="bottom" class="thinborder"><strong>BRAND</strong></td>
	  <td width="10%" align="center" valign="bottom" class="thinborder"><strong>UNIT PRICE</strong></td>
	  <td width="5%" align="center" valign="bottom" class="thinborder"><strong>ISSUE<br>QTY</strong></td>
	  <%if(!bolIsPONumber){%> 
	  <td width="5%" align="center" valign="bottom" class="thinborder"><strong>SELECT ALL <br>
	  </strong>
	  	<input type="checkbox" name="selAllDelItems" value="0" onClick="checkAllDelItems();"></td><%}%>
    </tr>
    <%
	iCount = 0;
	for(int i = 0;i < vIssuanceItem.size();i+=iElemCount){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=++iCount%></div></td>
      <td class="thinborder"><%=WI.getStrValue(vIssuanceItem.elementAt(i+2),"&nbsp;")%></td>
	  <%
	  strTemp = WI.getStrValue(vIssuanceItem.elementAt(i+3))+WI.getStrValue((String)vIssuanceItem.elementAt(i+4)," / ","","");
	  %>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vIssuanceItem.elementAt(i+5),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vIssuanceItem.elementAt(i+8),"&nbsp;")%></td>
      <td class="thinborder" align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vIssuanceItem.elementAt(i+7),true),"&nbsp;")%></td>
	  <td class="thinborder" align="center"><%=(String)vIssuanceItem.elementAt(i+1)%></td>
	  <input type="hidden" name="issue_qty_<%=iCount%>" value="<%=(String)vIssuanceItem.elementAt(i+1)%>">
	  <%if(!bolIsPONumber){%> 
	  <td class="thinborder" align="center">				
				<input type="checkbox" name="issue_item_index_<%=iCount%>" value="<%=(String)vIssuanceItem.elementAt(i)%>" tabindex="-1" <%=strErrMsg%>></td><%}%>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="8" class="thinborder"><strong>TOTAL ITEM(S) : <%=iCount%>  </strong><input type="hidden" name="item_count_delete" value="<%=iCount%>"></td>
    </tr>
  </table>
<%if(!bolIsPONumber){%>  
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 	
 	<tr>
		<td colspan="2" align="center">
		<a href="javascript:PageAction('0');"><img src="../../../images/delete.gif" border="0"></a>
		<font size="1">Click to remove issuance information.</font></td>
	</tr>
 </table>
<%}//end if(!bolIsPONumber)
}//end of while
}// end if vIssuanceInfo
}%>	


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8"></td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  	
	<input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  	<input type="hidden" name="page_action" value="">
	<input type="hidden" name="issuance_number" value="<%=WI.fillTextValue("issuance_number")%>">
	
	<input type="hidden" name="po_number_val" value="<%=WI.getStrValue(strPONumber)%>">
  	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>