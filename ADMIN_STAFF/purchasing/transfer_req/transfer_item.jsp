<%@ page language="java" import="utility.*,inventory.InventoryMaintenance,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

%>
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
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
 function CheckAll()
{
	document.form_.printPage.value = "";
	var iMaxDisp = document.form_.item_count.value;
	if (iMaxDisp.length == 0)
		return;	
	if (document.form_.selAll.checked ){
		for (var i = 1 ; i <= eval(iMaxDisp);++i)
			eval('document.form_.transfer_'+i+'.checked=true');
	}
	else
		for (var i = 1 ; i <= eval(iMaxDisp);++i)
			eval('document.form_.transfer_'+i+'.checked=false');
		
}
function ProceedClicked(){
	document.form_.focus_area.value = "";
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function PageAction(strAction,strIndex,strDelItem){
	if(strAction == '1') {
		var iMaxCount = document.form_.item_count.value;
		var objChkbox;
		var bolIsChecked = false;
		for(i = 1; i <= iMaxCount; ++i) {
			eval('objChkBox = document.form_.transfer_'+i);		
			if(!objChkBox)
				continue;
			if(objChkBox.checked) {
				bolIsChecked = true;
				break;	
			}
		}
		if(!bolIsChecked) {
			alert("Please select atleast one item from the list.");
			return;
		}	
	}
	if(strAction == 0){
		document.form_.focus_area.value = "3";
		var vProceed = confirm('Delete '+strDelItem+' ?');
		if(vProceed){
			document.form_.pageAction.value = strAction;
			document.form_.strIndex.value = strIndex;
			document.form_.printPage.value = "";
			this.SubmitOnce('form_');
		}		
	} else {
		document.form_.focus_area.value = "2";
		document.form_.pageAction.value = strAction;
		document.form_.strIndex.value = strIndex;
		document.form_.printPage.value = "";
		this.SubmitOnce('form_');
	}	
}
function CancelRecord(){
  document.form_.cancelClicked.value = "1";
	document.form_.proceedClicked.value = "1";
	document.form_.pageAction.value = "";
	document.form_.strIndex.value = "";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
function PageLoad(){
	var pageNo = "";
	pageNo = <%=WI.getStrValue(WI.fillTextValue("focus_area"),"1")%>
	if(eval('document.form_.req_no'+pageNo))
		eval('document.form_.req_no'+pageNo+'.focus()');
	else
		document.form_.req_no.focus();
}
function OpenSearch(strSupply){
	document.form_.printPage.value = "";
	var pgLoc = "./request_view_search.jsp?opner_info=form_.req_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function OpenSearchIssuance(){
	document.form_.printPage.value = "";
	var pgLoc = "./issuance_view_search.jsp?opner_info=form_.issuance_no";
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage(){
	document.form_.category_name.value = document.form_.cat_index[document.form_.cat_index.selectedIndex].text;
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
 
function ViewItem(strIndex){
	var pgLoc = "issuance_details_view.jsp?issuance_index="+strIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

//ajax update..
function ajaxUpdate(strRef, strFieldName, labelID) {
	//if there is no change, just return here..
	var strInput = prompt('Please enter new value','');
	if(strInput == null || strInput.length == 0)
		return;
	
	var strParam = "field_="+strFieldName+"&field_v="+escape(strInput)+"&field_ref="+strRef;
	var objCOAInput = document.getElementById(labelID);
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get value in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=117&"+strParam;
	this.processRequest(strURL);
}

//end of ajax update.



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

///////////////////////////////////////// End of collapse and expand filter ////////////////////

</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<p>
  <%		
    if(WI.fillTextValue("printPage").equals("1")){%>
  <jsp:forward page="request_item_print.jsp"/>
  
    <%return;}
	
	DBOperation dbOP = null;	
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-REQUISITION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}				
	}

	if(WI.fillTextValue("my_home").equals("1"))
		iAccessLevel = 2 ;
	
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
								"Admin/staff-PURCHASING-REQUISITION-Requisition Items","transfer_item.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
</p>
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.

	InventoryMaintenance InvMaint = new InventoryMaintenance();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vTransfer = null;
	Vector vRetResult = null;
	Vector vCheck = null;
	Vector vIssuances = null;
	boolean bolIsErr = false;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String strSchCode = dbOP.getSchoolIndex();
	String strSupply = WI.getStrValue(WI.fillTextValue("is_supply"),"0");
	int iDefault = 0;
	String strCategory = null;
	String strClass = null;
	String strItem = null;
	int iCount = 1;
	int i = 0;
 	
	if(WI.fillTextValue("req_no").length() == 0)
		strErrMsg = "Input Requisition No.";

	vReqInfo = InvMaint.operateOnTransferReqInfo(dbOP,request,3);
	if(vReqInfo == null && WI.fillTextValue("req_no").length() > 0
	     				&& WI.fillTextValue("pageAction").length() == 0)
		strErrMsg = InvMaint.getErrMsg();

	if(vReqInfo != null && vReqInfo.size() > 0){
		if(!((String)vReqInfo.elementAt(13)).equals("1")){
			strErrMsg = "Request is not approved";
			vReqInfo = null;
		}
	}

	if(WI.fillTextValue("pageAction").length() > 0){
		vCheck = InvMaint.operateOnTransferDel(dbOP,request,Integer.parseInt(WI.fillTextValue("pageAction")));
		if(vCheck == null){
			strErrMsg = InvMaint.getErrMsg();
			if(WI.fillTextValue("pageAction").equals("2"))
				bolIsErr = true;
		}			
		else{
			if(!WI.fillTextValue("pageAction").equals("3")){
				strErrMsg = "Operation Successful.";
				vCheck = null;
			}				
		}	
	}	
	
	if(vReqInfo != null && vReqInfo.size() > 0){		
		vIssuances = InvMaint.getItemIssuances(dbOP,(String) vReqInfo.elementAt(0));
		vRetResult = InvMaint.operateOnTransferDel(dbOP,request,4);		
		if(vRetResult != null && vRetResult.size() > 0){
			vReqItems = (Vector) vRetResult.elementAt(0);
			vTransfer = (Vector) vRetResult.elementAt(1);
		}		
	}
%>
<form name="form_" method="post" action="transfer_item.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">    
	<tr bgcolor="#A49A6A">
      <td height="25" align="center"><font color="#FFFFFF"><strong>:::: 
        REQUISITION : ITEM TRANSFER REQUEST PAGE ::::</strong></font></td>
	</tr>	  
  
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:14px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="21%">Requisition No.</td>
      <td width="76%"><strong> 
        <input type="text" name="req_no" class="textbox" value="<%=WI.fillTextValue("req_no")%>"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong>&nbsp;
		<a href="javascript:OpenSearch('<%=WI.getStrValue(WI.fillTextValue("is_supply"),"0")%>');">
		<img src="../../../images/search.gif" border="0"></a>
		<a href="javascript:ProceedClicked();"> 
        <img src="../../../images/form_proceed.gif" border="0">
        </a>
	  </td>
    </tr>
    <tr> 
      <td height="15" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%if(vReqInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<input type="hidden" name="c_index_fr" value="<%=(String)vReqInfo.elementAt(1)%>">
		<input type="hidden" name="d_index_fr" value="<%=(String)vReqInfo.elementAt(2)%>">
		<input type="hidden" name="c_index_to" value="<%=(String)vReqInfo.elementAt(5)%>">
		<input type="hidden" name="d_index_to" value="<%=(String)vReqInfo.elementAt(6)%>">
    <tr bgcolor="#C78D8D"> 
      <td width="3%" height="26">&nbsp;</td>
      <td colspan="4" align="center"><strong>REQUISITION DETAILS </strong></td>
    </tr>
		<%if(((String)vReqInfo.elementAt(1)).equals("0")){%> 
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4"><strong>ITEM SOURCE</strong> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Office :</td>
      <td colspan="3"><strong><%=(String)vReqInfo.elementAt(4)%></strong></td>
    </tr>
		<%}else{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td colspan="3"><strong><%=(String)vReqInfo.elementAt(3)+"/"+WI.getStrValue((String)vReqInfo.elementAt(4),"All")%></strong></td>
    </tr>
		<%}%>
    <tr>
      <td height="15" colspan="5"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="25%"><strong><%=WI.fillTextValue("req_no")%></strong></td>
      <td width="21%">Requested By :</td>
      <td width="29%"> <strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vReqInfo.elementAt(10)%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(13))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(12)%></strong></td>
    </tr>
	<%if(((String)vReqInfo.elementAt(5)).equals("0")){%> 
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(11),"&nbsp;")%></strong></td>
    </tr>
	<%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(7)+"/"+WI.getStrValue((String)vReqInfo.elementAt(8),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(11),"&nbsp;")%></strong></td>
    </tr>
	<%}%>	
    <tr>
      <td height="19" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <%
	if(vReqItems != null && vReqItems.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	  <tr bgcolor="#B9B292">
	  	  <td width="100%" height="25" colspan="6" align="center" class="thinborderBOTTOMLEFT"><font color="#FFFFFF"><strong>LIST OF REQUESTED SUPPLIES</strong></font></td>
	  </tr>
    <tr> 
      <td width="10%" height="25" align="center" class="thinborder"><strong>ITEM CODE </strong></td>
      <td width="9%" align="center" class="thinborder"><strong>QUANTITY</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="50%" align="center" class="thinborder"><strong>ITEM</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>DATE RECEIVED</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>
        <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">
      </strong>all</td>
    </tr>
    <%
	for(i = 0;i < vReqItems.size();i+=16,iCount++){%>
	<tr> 
			<input type="hidden" name="req_index_<%=iCount%>" value="<%=(String)vReqItems.elementAt(i)%>">
			<input type="hidden" name="req_item_index_<%=iCount%>" value="<%=(String)vReqItems.elementAt(i+1)%>">
			<input type="hidden" name="req_qty_<%=iCount%>" value="<%=(String)vReqItems.elementAt(i+3)%>">
			<input type="hidden" name="delivered_qty_<%=iCount%>" value="<%=(String)vReqItems.elementAt(i+4)%>">
			<input type="hidden" name="item_reg_index_<%=iCount%>" value="<%=(String)vReqItems.elementAt(i+10)%>">
			<input type="hidden" name="item_name_<%=iCount%>" value="<%=(String)vReqItems.elementAt(i+7)%>">
			<input type="hidden" name="unit_index_<%=iCount%>" value="<%=(String)vReqItems.elementAt(i+9)%>">
			<!-- conversion is already checked. unit transfered is cross checked with the registry-->			
			<input type="hidden" name="conversion_qty_<%=iCount%>" value="<%=(String)vReqItems.elementAt(i+13)%>">
			
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vReqItems.elementAt(i+2),"&nbsp;")%></td>
      <td align="right" class="thinborder">
			  <input name="new_deliver_qty_<%=iCount%>" type="text" class="textbox" tabindex="-1" 
				onBlur="AllowOnlyFloat('form_','new_deliver_qty_<%=iCount%>');style.backgroundColor='white';"
				onKeyUp="AllowOnlyFloat('form_','new_deliver_qty_<%=iCount%>');"
				onFocus="style.backgroundColor='#D3EBFF'" value="<%=ConversionTable.replaceString((String)vReqItems.elementAt(i+5),",","")%>" 
				size="3" maxlength="10" style="text-align:right">&nbsp;
	  </td>
      <td class="thinborder">&nbsp;<%=vReqItems.elementAt(i+6)%></td>
			
      <td class="thinborder">&nbsp;<%=(String)vReqItems.elementAt(i+7)%><%=WI.getStrValue((String)vReqItems.elementAt(i+8)," (", ")","")%></td>
      <td align="center" class="thinborder">
			 	<input name="date_<%=iCount%>" type="text" size="9" maxlength="10" class="textbox"
				 value="<%=WI.getTodaysDate(1)%>" onFocus="style.backgroundColor='#D3EBFF'" 
				 onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.date_<%=iCount%>');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td align="center" class="thinborder"><input type="checkbox" name="transfer_<%=iCount%>" value="1"></td>
	</tr>
	<%} // end for loop%>
	<input type="hidden" name="item_count" value="<%=iCount-1%>">
    <tr> 
      <td class="thinborder" height="25" colspan="4">
	      <strong>TOTAL ITEM(S) : <%=iCount-1%></strong></td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="14%">Received by:</td>
      <%
				strTemp = WI.fillTextValue("received_by");
				if(strTemp.length() == 0)
					strTemp = (String)vReqInfo.elementAt(9);
			%>
      <td width="86%" height="25"><input type="text" name="received_by" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td>Issuance No. </td>
			<%
				strTemp = WI.fillTextValue("issuance_no");
			%>			
      <td height="25"><input type="text" name="issuance_no" class="textbox" value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="1"><a href="javascript:OpenSearchIssuance();"><img src="../../../images/search.gif" border="0"></a>Enter Issuance No. to append to an existing issuance record </font></td>
    </tr>
    <tr>
      <td>Date issued </td>
			<%
				strTemp = WI.fillTextValue("issue_date");
			%>			
      <td height="25"><input name="issue_date" type="text" size="9" maxlength="10" class="textbox"
				 value="<%=strTemp%>" onFocus="style.backgroundColor='#D3EBFF'" 
				 onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.issue_date');" title="Click to select date" 
			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td>PO Number </td>
      <td height="25"><input type="text" name="po_num" class="textbox" value="<%=WI.fillTextValue("po_num")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        (optional)</td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2"><div align="center"><a href="javascript:PageAction(1,0);"> <img src="../../../images/save.gif" border="0"> </a><font size="1">click to save update</font> <a href="javascript:CancelRecord();"> <img src="../../../images/cancel.gif" border="0"> </a> <font size="1">click to cancel</font> </div></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <%}%>
	<%
	if(vTransfer != null && vTransfer.size() > 0){%>	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	  <tr bgcolor="#B9B292">
	  	  <td height="25" colspan="4" align="center" class="thinborderBOTTOMLEFT"><font color="#FFFFFF"><strong>LIST OF TRANSFERRED SUPPLIES</strong></font></td>
	  </tr>
    <tr> 
      <td width="17%" height="25" align="center" class="thinborder"><strong>ITEM CODE </strong></td>
      <td width="10%" align="center" class="thinborder"><strong>QUANTITY</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="63%" align="center" class="thinborder"><strong>ITEM</strong></td>
    </tr>
    <%
	for(i = 0;i < vTransfer.size();i+=16,iCount++){%>
	<tr> 
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vTransfer.elementAt(i+2),"&nbsp;")%></td>
      <td align="right" class="thinborder"><%=(String)vTransfer.elementAt(i+4)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=vTransfer.elementAt(i+6)%></td>
			
      <td class="thinborder">&nbsp;<%=(String)vTransfer.elementAt(i+7)%><%=WI.getStrValue((String)vTransfer.elementAt(i+8)," (", ")","")%></td>
    </tr>
	<%} // end for loop%>
    <tr> 
      <td class="thinborder" height="25" colspan="4">
	      <strong>TOTAL ITEM(S) : <%=iCount-1%></strong></td>
    </tr>
  </table>
	<%}%>
<%}else{%>
 <input type="hidden" name="is_supply">
<%}%>
<%if(vIssuances != null && vIssuances.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td><div onClick="showBranch('branch6');swapFolder('folder6')">
          <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6">
          <b><font color="#0000FF">Issuances made </font></b></div>
        <span class="branch" id="branch6">
  <table width="95%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="5" align="center" bgcolor="#B9B292" class="thinborder"><font color="#FFFFFF"><strong>LIST OF ISSUANCES MADE </strong></font></td>
    </tr>
    <tr> 
      <td width="20%" height="20" align="center" class="thinborder"><strong>ISSUANCE NO </strong></td>
      <td width="15%" align="center" class="thinborder"><strong>DATE ISSUED </strong></td>
      <td width="20%" align="center" class="thinborder"><strong>RECEIVED BY </strong></td>
      <td width="20%" align="center" class="thinborder"><strong>PO NUMBER</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>DETAILS</strong></td>
      <!--
			<td width="8%" class="thinborder"><div align="center"><strong>CHANGE STATUS</strong></div></td>
			-->
    </tr>
    <%iCount = 1;
	for(i = 0;i < vIssuances.size();i+=5,++iCount){%>
    <tr> 
      <td height="20" class="thinborder">&nbsp;<%=(String)vIssuances.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<label id="_1<%=i%>" onClick="ajaxUpdate('<%=vIssuances.elementAt(i)%>','issue_date','_1<%=i%>')"><%=(String)vIssuances.elementAt(i+2)%></label></td>
	  <td class="thinborder">&nbsp;<label id="_2<%=i%>" onClick="ajaxUpdate('<%=vIssuances.elementAt(i)%>','received_by','_2<%=i%>')"><%=WI.getStrValue((String)vIssuances.elementAt(i+3), "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")%></label></td>
	  <td class="thinborder">&nbsp;<label id="_3<%=i%>" onClick="ajaxUpdate('<%=vIssuances.elementAt(i)%>','po_num','_3<%=i%>')"><%=WI.getStrValue((String)vIssuances.elementAt(i+4), "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")%></label></td>
	  <td align="center" class="thinborder"><a href="javascript:ViewItem('<%=(String)vIssuances.elementAt(i)%>');">VIEW DETAILS</a></td>
     </tr>
    <%}%>
    <tr> 
      <td height="20" colspan="5" class="thinborder"><strong>TOTAL ITEM(S) : <%=iCount - 1%> </strong></td>
    </tr>
  </table>
      </span></td>
    </tr>
  </table>	
	  <%}// end vIssuances != null && vIssuances.size() > 3%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">   
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!--
  <input type="hidden" name="is_supply" value="<%=strSupply%>">
  -->
  <input type="hidden" name="proceedClicked" value="">
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="cancelClicked" value="">
  <input type="hidden" name="strIndex" value="<%=WI.fillTextValue("strIndex")%>">
  <input type="hidden" name="printPage" value=""> 
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>"> 
	<input type="hidden" name="focus_area" value="<%=WI.fillTextValue("focus_area")%>">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>