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
function PageLoad(){
 	document.form_.req_no.focus();
}
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";	
	this.SubmitOnce('form_');
}
function PageAction(strAction,strIndex){
  document.form_.printPage.value = "";
	document.form_.proceedClicked.value = "1";
	document.form_.pageAction.value = strAction;
	document.form_.strIndex.value = strIndex;
	this.SubmitOnce('form_');
}
function CancelClicked(){
	location = "./delivery_update_status.jsp";
}

function OpenSearchPO(){
	var pgLoc = "../purchase_order/purchase_request_view_search.jsp?opner_info=form_.req_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ChangeItem(strPOItemIndex){
	var pgLoc = "../purchase_order/purchase_request_change_item.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=650,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}

function ReloadPage()
{
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function CopyInvoice(){
	var vItems = document.form_.strNumOfItems.value;
	if (vItems.length == 0)
		return;	
	for (var i = 1 ; i < eval(vItems)+1;++i)
		eval('document.form_.invoice'+i+'.value=document.form_.invoice1.value');				
}
function CopyShip(){
	var vItems = document.form_.strNumOfItems.value;
	if (vItems.length == 0)
		return;	
	for (var i = 1 ; i < eval(vItems)+1;++i)
		eval('document.form_.ship_method'+i+'.value=document.form_.ship_method1.value');				
}
function CopyStatus(){
	var vItems = document.form_.strNumOfItems.value;
	if (vItems.length == 0)
		return;	
	for (var i = 1 ; i < eval(vItems)+1;++i)
		eval('document.form_.status_'+i+'.value=document.form_.status_1.value');				
}

function ViewItem(strIndex){
	var pgLoc = "delivery_details_view.jsp?delivery_index="+strIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewRetDetail(strIndex,strSupplier){
	var pgLoc = "delivery_returns_view.jsp?req_no="+document.form_.req_no.value+
							"&supplier_code="+strSupplier+"&search_po=1&return_index="+strIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function SearchReceiver() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.received_by";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SearchChecker() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.checked_by";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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

///////////////////////////////////////// End of collapse and expand filter ////////////////////
</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<%@ page language="java" import="utility.*,purchasing.Delivery,java.util.Vector" %>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

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


   if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="delivery_update_status_print.jsp"/>
   <%}	
	Delivery DEL = new Delivery();	
	Vector vReqInfo = null;
	Vector vDeliveries = null;
	Vector vReqPO = null;
	Vector vPOItemsRet = null;
	Vector vReqItems = null;
	Vector vRetResult = null;
	Vector vReturns = null;
	int iCount = 1;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	
	
	if (WI.fillTextValue("proceedClicked").equals("1")){
		vReqInfo = DEL.operateOnReqInfoDel(dbOP,request);
		if(vReqInfo == null)
			strErrMsg = DEL.getErrMsg();
		else{
		  if(Integer.parseInt(WI.getStrValue((String)vReqInfo.elementAt(3),"0")) != 1){
		  	strErrMsg = "PO not yet approved";
		  }else{
			if(WI.fillTextValue("pageAction").length() > 0){
				vRetResult = DEL.operateOnReqItemsDel(dbOP, request,
													  Integer.parseInt(WI.fillTextValue("pageAction")), (String)vReqInfo.elementAt(0));
				if(vRetResult == null)
					strErrMsg = DEL.getErrMsg();
				else
					strErrMsg = "Operation Successful";
			}

			vRetResult = DEL.operateOnReqItemsDel(dbOP,request,4,(String)vReqInfo.elementAt(0));
			if(vRetResult == null)
				strErrMsg = DEL.getErrMsg();
			else{
				vReqPO = (Vector)vRetResult.elementAt(0);
				vDeliveries = (Vector)vRetResult.elementAt(3);
				vPOItemsRet = (Vector)vRetResult.elementAt(2);
				vReqItems = (Vector)vRetResult.elementAt(1);
				vReturns =(Vector)vRetResult.elementAt(4);
			}	
		}
	 }
	}
%>	
<form name="form_" method="post" action="delivery_update_status.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" bgcolor="#A49A6A"><font color="#FFFFFF"><strong>:::: 
      DELIVERY - UPDATE PO RECEIVE STATUS PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%">PO No. :</td>
      <td width="27%">
			<%if(WI.fillTextValue("req_no").length() > 0){
		  		strTemp = WI.fillTextValue("req_no");
			  }else{
	  			strTemp = "";
      	}%> 
			<input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="50%"><a href="javascript:OpenSearchPO();"><img src="../../../images/search.gif" border="0"></a><font size="1">click to search po no.</font></td>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td colspan="4">&nbsp;</td>
    </tr>
  </table>  
<%if(vReqInfo != null && vReqInfo.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4" align="center"><strong>REQUISITION DETAILS FOR PURCHASE ORDER NO. : <%=(String)vReqInfo.elementAt(1)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>PO Status:</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(3))]%></strong></td>
      <td>PO Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="28%"><strong><%=(String)vReqInfo.elementAt(4)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"> <strong><%=(String)vReqInfo.elementAt(5)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(6))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vReqInfo.elementAt(7)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(8))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(10)) == null){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=(String)vReqInfo.elementAt(11)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(10)+"/"+WI.getStrValue((String)vReqInfo.elementAt(11),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
    <%}%>
		<input type="hidden" name="supplier_index" value="<%=(String)vReqInfo.elementAt(14)%>">
  </table>
  <%if((vReqPO != null && vReqPO.size() > 3) || 
       (vDeliveries != null && vDeliveries.size() > 0) ||
	   (vPOItemsRet != null && vPOItemsRet.size() > 3)){
	   
 if( ( vReqPO == null || vReqPO.size() == 0 ) || !strSchCode.startsWith("SWU")){%>
  <table bgcolor="#FFFFFF" width="100%" border="0"> 
  	<tr>
			<td height="30" align="right">
			  <a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
			  <font size="1">click to print</font></td>
		</tr>
	
  </table>
  <%}if(vReqPO != null && vReqPO.size() > 3){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td height="25" colspan="6" align="center" bgcolor="#B9B292" class="thinborder"><font color="#FFFFFF"><strong>LIST 
        OF PO ITEM(S) NOT RECEIVED </strong></font></td>
    </tr>
    <tr> 
      <td width="7%" height="25" align="center" valign="bottom" class="thinborder"><strong>ITEM#</strong></td>
      <td width="9%" align="center" valign="bottom" class="thinborder"><strong>QTY</strong></td>
      <td width="8%" align="center" valign="bottom" class="thinborder"><strong>UNIT</strong></td>
      <td width="33%" align="center" valign="bottom" class="thinborder"><strong>ITEM / PARTICULARS 
      / DESCRIPTION </strong></td>
      <td width="22%" align="center" valign="bottom" class="thinborder"><strong>SUPPLIER 
      CODE </strong></td>
      <td width="21%" align="center" valign="bottom" class="thinborder"><strong>RECEIVE STATUS</strong><br>
        <strong><font size="1"><a href="javascript:CopyStatus();">Copy First </a></font></strong></td>
    </tr>
    <%
		for(int i = 0;i < vReqPO.size();i+=10,++iCount){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=iCount%></div></td>
      <td class="thinborder"><div align="center">
				<input type="hidden" name="po_qty_<%=iCount%>" value="<%=ConversionTable.replaceString((String)vReqPO.elementAt(i+1),",","")%>">
				<input type="hidden" name="delivered_qty_<%=iCount%>" value="<%=ConversionTable.replaceString((String)vReqPO.elementAt(i+9),",","")%>">
        <input name="new_deliver_qty_<%=iCount%>" type="text" class="textbox" tabindex="-1" 
				onBlur="AllowOnlyFloat('form_','new_deliver_qty_<%=iCount%>');style.backgroundColor='white';"
				onKeyUp="AllowOnlyFloat('form_','new_deliver_qty_<%=iCount%>');"
				onFocus="style.backgroundColor='#D3EBFF'"
				value="<%=ConversionTable.replaceString((String)vReqPO.elementAt(i+8),",","")%>" size="3" maxlength="10" style="text-align:right">
      </div></td>
      <td class="thinborder"><%=(String)vReqPO.elementAt(i+2)%></td>
      <td class="thinborder"><%=(String)vReqPO.elementAt(i+3)%> / <%=(String)vReqPO.elementAt(i+4)%> 
			  <%=WI.getStrValue((String)vReqPO.elementAt(i+7),"(",")","")%></td>
      <td class="thinborder"><%=(String)vReqPO.elementAt(i+5)%></td>
      <td class="thinborder"><div align="center"> 
          <%if(((String)vReqInfo.elementAt(3)).equals("1")){%>
          <select name="status_<%=iCount%>">
            <option value="0">Not Received</option>
            <option value="1">Received and OK</option>
            <option value="2">Received and not OK</option>
          </select>
          <%}else{%>
          N/A 
          <%}%>
          <input type="hidden" name="itemIndex_<%=iCount%>" value="<%=(String)vReqPO.elementAt(i)%>">
        </div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="6" class="thinborder"><strong>TOTAL 
        ITEM(S) : <%=iCount - 1%></strong>        <input type="hidden" name="strNumOfItems" value="<%=iCount - 1%>">
      </td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%">
  	<tr>
			<td height="20">&nbsp;</td>
		</tr>	
  </table>
  <%}//end vReqPO != null && vReqPO.size() > 3%>  
  <%if(vReqItems != null && vReqItems.size() > 3){%>	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="5" align="center" bgcolor="#B9B292" class="thinborder"><font color="#FFFFFF"><strong>LIST 
        OF PO ITEM(S) RECEIVED</strong></font></td>
    </tr>
    <tr> 
      <td width="7%" height="25" align="center" class="thinborder"><strong>ITEM#</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="13%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="49%" align="center" class="thinborder"><strong>ITEM / PARTICULARS 
        / DESCRIPTION </strong></td>
      <td width="21%" align="center" class="thinborder"><strong>SUPPLIER 
        CODE </strong></td>
      <!--
			<td width="8%" class="thinborder"><div align="center"><strong>CHANGE STATUS</strong></div></td>
			-->
    </tr>
    <%iCount = 1;
	for(int i = 0;i < vReqItems.size();i+=14,++iCount){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=iCount%></div></td>
      <td align="right" class="thinborder"><%=(String)vReqItems.elementAt(i+12)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=(String)vReqItems.elementAt(i+2)%></td>
      <td class="thinborder"><%=(String)vReqItems.elementAt(i+3)%> / <%=(String)vReqItems.elementAt(i+4)%><%=WI.getStrValue((String)vReqItems.elementAt(i+9),"(",")","")%></td>
      <td class="thinborder"><%=(String)vReqItems.elementAt(i+5)%></td>
      <!--
      <td class="thinborder"><div align="center"> 
					<%//if(((String)vReqItems.elementAt(i+8)).equals("0")){%>
          <a href="javascript:PageAction(0,<%//=(String)vReqItems.elementAt(i)%>);"> 
          <img src="../../../images/select.gif" border="0"> </a> 
					<%//}else{%>
					N/A 
          <%//}%>
        </div></td>
				-->
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="5" class="thinborder"><strong>TOTAL 
          ITEM(S) : <%=iCount - 1%> </strong></td>
    </tr>
  </table>	
	<%}// end if(vReqItems != null && vReqItems.size() > 3)%>	
<%if(vDeliveries != null && vDeliveries.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td><div onClick="showBranch('branch6');swapFolder('folder6')">
          <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6">
          <b><font color="#0000FF">Deliveries made </font></b></div>
        <span class="branch" id="branch6">
  <table width="95%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="5" align="center" bgcolor="#B9B292" class="thinborder"><font color="#FFFFFF"><strong>LIST 
        OF DELIVERIES FOR THE PO </strong></font></td>
    </tr>
    <tr> 
      <td width="12%" height="20" align="center" class="thinborder"><strong>DELIVERY No</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>&nbsp;SHIPPING 
        METHOD</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>INVOICE NO</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>DATE RECEIVED</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>DETAILS</strong></td>
      <!--
			<td width="8%" class="thinborder"><div align="center"><strong>CHANGE STATUS</strong></div></td>
			-->
    </tr>
    <%iCount = 1;
	for(int i = 0;i < vDeliveries.size();i+=5,++iCount){%>
    <tr> 
      <td height="20" class="thinborder"><%=(String)vDeliveries.elementAt(i+1)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vDeliveries.elementAt(i+4),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vDeliveries.elementAt(i+2),"&nbsp;")%></td>
      <td class="thinborder"><%=(String)vDeliveries.elementAt(i+3)%></td>
			<td align="center" class="thinborder">
				<a href="javascript:ViewItem('<%=(String)vDeliveries.elementAt(i)%>');">VIEW DETAILS</a></td>
			<!--
      <td class="thinborder"><div align="center"> 
					<%//if(((String)vDeliveries.elementAt(i+8)).equals("0")){%>
          <a href="javascript:PageAction(0,<%//=(String)vDeliveries.elementAt(i)%>);"> 
          <img src="../../../images/select.gif" border="0"> </a> 
					<%//}else{%>
					N/A 
          <%//}%>
        </div></td>
				-->
    </tr>
    <%}%>
    <tr> 
      <td height="20" colspan="5" class="thinborder"><strong>TOTAL 
          ITEM(S) : <%=iCount - 1%> </strong></td>
    </tr>
  </table>
      </span></td>
    </tr>
  </table>	
	  <%}// end vDeliveries != null && vDeliveries.size() > 3%>
	<%if(vReturns != null && vReturns.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td><div onClick="showBranch('branch1');swapFolder('folder1')">
          <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
          <b><font color="#0000FF">Returns made </font></b></div>
        <span class="branch" id="branch1">
  <table width="95%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="3" align="center" bgcolor="#B9B292" class="thinborder"><font color="#FFFFFF"><strong>LIST 
        OF RETURNS FOR THE PO </strong></font></td>
    </tr>
    <tr> 
      <td width="12%" height="20" align="center" class="thinborder"><strong>RETURN # </strong></td>
      <td width="10%" align="center" class="thinborder"><strong>DATE RETURNED </strong></td>
      <td width="8%" align="center" class="thinborder"><strong>DETAILS</strong></td>
      <!--
			<td width="8%" class="thinborder"><div align="center"><strong>CHANGE STATUS</strong></div></td>
			-->
    </tr>
    <%iCount = 1;
	for(int i = 0;i < vReturns.size();i+=3,++iCount){%>
    <tr> 
      <td height="20" class="thinborder">&nbsp;<%=WI.getStrValue((String)vReturns.elementAt(i+1),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vReturns.elementAt(i+2),"&nbsp;")%></td>
			<td align="center" class="thinborder">
				<a href="javascript:ViewRetDetail('<%=(String)vReturns.elementAt(i)%>');">VIEW DETAILS</a></td>
    </tr>
    <%}%>
    <tr> 
      <td height="20" colspan="3" class="thinborder"><strong>TOTAL 
          ITEM(S) : <%=iCount - 1%> </strong></td>
    </tr>
  </table>
      </span></td>
    </tr>
  </table>
	<%} // end vReturns != null%>
			
  <%if(vReqPO != null && vReqPO.size() > 3){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%">&nbsp;</td>
	  <%
	  strTemp = "Delivery ";
	  if(strSchCode.startsWith("SWU"))
	  	strTemp = "Receive ";
	  %>
      <td width="17%" height="25"><%=strTemp%> #: </td>
			<%
				strTemp = WI.fillTextValue("delivery_no");
			%>			
      <td colspan="2"><input type="text" name="delivery_no" class="textbox" value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">   
	  <%
	  strTemp = "delivery ";
	  if(strSchCode.startsWith("SWU"))
	  	strTemp = "receive ";
	  %>     
        <font size="1">Leave blank if <%=strTemp%> # should be system generated </font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Invoice #:</td>
			<%
				strTemp = WI.fillTextValue("invoice_no");
			%>
      <td width="27%"><input name="invoice_no" type="text" class="textbox" tabindex="-1" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					value="<%=strTemp%>" size="8"></td>
			<%
				strTemp = WI.fillTextValue("invoice_date");
			%>
      <td width="53%">Invoice Date : 
        <input name="invoice_date" type="text" size="9" maxlength="10" class="textbox"
				 value="<%=strTemp%>" onFocus="style.backgroundColor='#D3EBFF'" 
				 onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.invoice_date');" title="Click to select date" 
			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Date Delivered </td>
			<%
				strTemp = WI.fillTextValue("date_delivered");
				if(strTemp == null || strTemp.length() == 0)
					strTemp = WI.getTodaysDate(1);
			%>
      <td><input name="date_delivered" type="text" size="9" maxlength="10" class="textbox"
				 value="<%=strTemp%>" onFocus="style.backgroundColor='#D3EBFF'" 
				 onBlur="style.backgroundColor='white'" readonly>
      <a href="javascript:show_calendar('form_.date_delivered');" title="Click to select date" 
			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
			<img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td>Issuance Number: 
      <input type="text" name="issuance_no" class="textbox" value="<%=WI.fillTextValue("issuance_no")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Shipping Method </td>
			<%
				strTemp = WI.fillTextValue("ship_method");
			%>
      <td>
				<select name="ship_method">
          <option value="">Select Type</option>
          <%=dbOP.loadCombo("SHIPPING_INDEX","METHOD_NAME"," from PUR_PRELOAD_SHIPPING order by METHOD_NAME", strTemp, false)%>
        </select>			</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td> 
		<%
			strTemp = WI.fillTextValue("received_by");
		%>
      <td height="25">Received by:        </td>
      <td><input type="text" name="received_by" class="textbox" value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td><a href="javascript:SearchReceiver();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a> <font size="1">click to search receiver ID</font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
	<%
	  strTemp = "Checked ";
	  if(strSchCode.startsWith("SWU"))
	  	strTemp = "Approved ";
	  %>	
      <td height="25"><%=strTemp%> by:        </td>
      <td><input type="text" name="checked_by" class="textbox" value="<%=WI.fillTextValue("checked_by")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td><a href="javascript:SearchChecker();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
	  
	  <%
	  strTemp = "checker";
	  if(strSchCode.startsWith("SWU"))
	  	strTemp = "approver ";
	  %><font size="1">click to search <%=strTemp%> ID</font></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><div align="center"><a href="javascript:PageAction(1,0);"> 
          <img src="../../../images/save.gif" border="0"></a><font size="1">click to save update</font> 
          <a href="javascript:CancelClicked();"> <img src="../../../images/cancel.gif" border="0"></a> <font size="1">click to cancel</font> </div></td>
    </tr>
  </table>
  <%}if((vReqPO == null && vReqPO.size() < 3) || (vDeliveries == null && vDeliveries.size() < 3)){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8"><div align="center"> 
          <a href="javascript:CancelClicked();"><img src="../../../images/go_back.gif" border="0"></a>
		  <font size="1">click to go back</font></div></td>
    </tr>
  </table>  
  <%}}}%>
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
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="strIndex" value="">
  <input type="hidden" name="printPage" value="">
	<input type="hidden" name="search_po" value="1">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>