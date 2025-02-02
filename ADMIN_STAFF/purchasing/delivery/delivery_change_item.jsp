<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function PageLoad(){
	document.form_.printPage.value = "";
 	document.form_.req_no.focus();
}
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";	
	document.form_.change_item.value = "";	
	this.SubmitOnce('form_');
}
function PageAction(strAction){
    document.form_.printPage.value = "";
	document.form_.proceedClicked.value = "1";
	document.form_.pageAction.value = strAction;
	this.SubmitOnce('form_');
}
function CancelClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.change_item.value = "";
	document.form_.printPage.value = "";	
	this.SubmitOnce('form_');
}

function OpenSearchPO(){
	var pgLoc = "../purchase_order/purchase_request_view_search.jsp?opner_info=form_.req_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ChangeItem(strItem,strParticular,strPrice,strPOItemIndex,strIsSupply,strItemFr,strQtyFr,strUnitFr,strUnitIndexFr,strBrandFr,strBrandIndexFr){
	document.form_.printPage.value = "";
	document.form_.change_item.value = "1";
	document.form_.item_name.value = strItem;
	document.form_.old_price.value = strPrice;
	document.form_.particular_old.value = strParticular;
	document.form_.po_item_index.value = strPOItemIndex;
	document.form_.is_supply.value = strIsSupply;
	document.form_.item_fr.value = strItemFr;
	document.form_.quantity_old.value = strQtyFr;
	document.form_.unit_old.value = strUnitFr;	
	document.form_.unit_index_fr.value = strUnitIndexFr;	
	document.form_.brand_old.value = strBrandFr;	
	document.form_.brand_fr.value = strBrandIndexFr;	
	this.SubmitOnce('form_');
}

function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<%@ page language="java" import="utility.*,purchasing.Delivery,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="delivery_change_item_print.jsp"/>
	<%}
	
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
								"Admin/staff-PURCHASING-DELIVERY-View delivery update Status","delivery_change_item.jsp");
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
	
	Delivery DEL = new Delivery();	
	Vector vReqInfo = null;
	Vector vPOItemsRet = null;
	Vector vRetResult = null;
	Vector vChangeItem = null;
	int iCount = 1;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	
	String strChangeItem = WI.getStrValue(WI.fillTextValue("change_item"),"");
	if (WI.fillTextValue("proceedClicked").equals("1")){
		vReqInfo = DEL.operateOnReqInfoDel(dbOP,request);
		if(vReqInfo == null)
			strErrMsg = DEL.getErrMsg();
		else{
			if(WI.fillTextValue("pageAction").length() > 0){
				vRetResult = DEL.operateOnChangeItem(dbOP, request,Integer.parseInt(WI.fillTextValue("pageAction")), (String)vReqInfo.elementAt(0));
				
				if(vRetResult == null)
					strErrMsg = DEL.getErrMsg();
				else{
					strErrMsg = "Operation Successful";
					strChangeItem = "";
					}
			}
	
			vRetResult = DEL.operateOnReqItemsDel(dbOP,request,4,(String)vReqInfo.elementAt(0));
			if(vRetResult == null)
				strErrMsg = DEL.getErrMsg();
			else{
				vPOItemsRet = (Vector)vRetResult.elementAt(2);
				if (vPOItemsRet == null || vPOItemsRet.size() == 0)
					strErrMsg = "No Returned Items found";
			}
			vChangeItem = DEL.operateOnChangeItem(dbOP, request,4, (String)vReqInfo.elementAt(0));
			//System.out.println("vChangeItem " + vChangeItem);
		}
	}
%>
<form name="form_" method="post" action="delivery_change_item.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          DELIVERY - CHANGE ITEM PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="28%">PO No. :</td>
      <td width="25%"> <%if(WI.fillTextValue("req_no").length() > 0){
	  		strTemp = WI.fillTextValue("req_no");
	  }else{
	  		strTemp = "";
      }%> <input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="44%"><a href="javascript:OpenSearchPO();"><img src="../../../images/search.gif" border="0"></a><font size="1">click to search po no.</font></td>
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
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS FOR PURCHASE ORDER NO. : <%=(String)vReqInfo.elementAt(1)%></strong></div></td>
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
      <td>Office</td>
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
  </table>
  <%if((vChangeItem != null && vChangeItem.size() > 0)){%> 
    <table bgcolor="#FFFFFF" width="100%" border="0">
  		<tr>
			  <td height="30" align="right">
			      <a href="javascript:PrintPage();">
	          <img src="../../../images/print.gif" border="0">		          </a>
			      <font size="1">click to print</font>		      </td>
  		</tr>
  </table> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="10" align="center" bgcolor="#B9B292" class="thinborder"><font color="#FFFFFF"><strong>LIST 
        OF PO ITEM CHANGES</strong></font></td>
    </tr>
    <tr> 
      <td width="6%" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="6%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="11%" align="center" class="thinborder"><strong>ITEM (FROM)</strong></td>
      <td width="20%" align="center" class="thinborder"><strong>PARTICULARS 
        / DESCRIPTION (FROM)</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>PRICE (FROM)</strong></td>
      <td width="6%" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="6%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="11%" align="center" class="thinborder"><strong>ITEM (TO)</strong></td>
      <td width="20%" height="25" align="center" class="thinborder"><strong>PARTICULARS 
        / DESCRIPTION (TO)</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>PRICE(TO)</strong></td>
    </tr>
    <%
	for(int iLoop = 0;iLoop < vChangeItem.size();iLoop+=16){%>
    <tr> 
      <td class="thinborder">&nbsp;<%=(String)vChangeItem.elementAt(iLoop+7)%></td>
      <td class="thinborder">&nbsp;<%=(String)vChangeItem.elementAt(iLoop+12)%></td>
      <td height="24" class="thinborder">&nbsp;<%=(String)vChangeItem.elementAt(iLoop+1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vChangeItem.elementAt(iLoop+2)%><%=WI.getStrValue((String)vChangeItem.elementAt(iLoop+14),"(",")","")%></td>
      <td class="thinborder"><div align="right">&nbsp;<%=WI.getStrValue(CommonUtil.formatFloat((String)vChangeItem.elementAt(iLoop+3),true),"")%>&nbsp;</div></td>
      <td class="thinborder">&nbsp;<%=(String)vChangeItem.elementAt(iLoop+9)%></td>
      <td class="thinborder">&nbsp;<%=(String)vChangeItem.elementAt(iLoop+13)%></td>
      <td class="thinborder">&nbsp;<%=(String)vChangeItem.elementAt(iLoop+4)%></td>
      <td class="thinborder">&nbsp; <%=(String)vChangeItem.elementAt(iLoop+5)%><%=WI.getStrValue((String)vChangeItem.elementAt(iLoop+15),"(",")","")%></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vChangeItem.elementAt(iLoop+6),true),"")%>&nbsp;</div></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <%if((vPOItemsRet != null && vPOItemsRet.size() > 3)){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="6" align="center" bgcolor="#B9B292" class="thinborder"><font color="#FFFFFF"><strong>LIST 
        OF PO ITEM(S) RETURNED</strong></font></td>
    </tr>
    <tr> 
      <td width="8%" height="25" align="center" class="thinborder"><strong>ITEM#</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="48%" align="center" class="thinborder"><strong>ITEM / PARTICULARS 
        / DESCRIPTION </strong></td>
      <td width="12%" align="center" class="thinborder"><strong>PRICE</strong></td>
      <td width="17%" align="center" class="thinborder"><strong>CHANGE ITEM</strong></td>
    </tr>
    <%iCount = 1;
	for(int iLoop = 0;iLoop < vPOItemsRet.size();iLoop+=13,++iCount){%>
    <tr> 
      <td height="28" class="thinborder"><div align="center"><%=iCount%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vPOItemsRet.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><%=(String)vPOItemsRet.elementAt(iLoop+2)%></td>
      <td class="thinborder"><%=(String)vPOItemsRet.elementAt(iLoop+3)%> / <%=(String)vPOItemsRet.elementAt(iLoop+4)%><%=WI.getStrValue((String)vPOItemsRet.elementAt(iLoop+11),"(",")","")%></td>
      <%
	  	strTemp = (String)vPOItemsRet.elementAt(iLoop+7);
	  %>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"")%>&nbsp;</div></td>
      <td class="thinborder"><div align="center"> 
	  <a href="javascript:ChangeItem('<%=(String)vPOItemsRet.elementAt(iLoop+3)%>',
	  								 '<%=(String)vPOItemsRet.elementAt(iLoop+4)%>',
									 '<%=(String)vPOItemsRet.elementAt(iLoop+7)%>',
									 '<%=(String)vPOItemsRet.elementAt(iLoop)%>',
									 '<%=(String)vPOItemsRet.elementAt(iLoop+8)%>',
									 '<%=(String)vPOItemsRet.elementAt(iLoop+9)%>',
									 '<%=(String)vPOItemsRet.elementAt(iLoop+1)%>',
									 '<%=(String)vPOItemsRet.elementAt(iLoop+2)%>',
									 '<%=(String)vPOItemsRet.elementAt(iLoop+10)%>',
									 '<%=(String)vPOItemsRet.elementAt(iLoop+11)%>',
									 '<%=(String)vPOItemsRet.elementAt(iLoop+12)%>');"> 
          <img src="../../../images/update.gif" width="60" height="26" border="0">          </a> </div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="6" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=iCount - 1%> </strong></div></td>
    </tr>
  </table>
  <%if (strChangeItem.length() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="18" colspan="2">&nbsp;</td>
    </tr>
    <%
		strTemp = WI.fillTextValue("item_name");
	%>
    <tr> 
      <td width="36%" height="22">&nbsp;&nbsp;&nbsp;Item:</td>
      <td width="64%" height="22"><%=WI.getStrValue(strTemp,"")%> </td>
    </tr>
    <%
		strTemp = WI.fillTextValue("particular_old");
	%>
    <tr> 
      <td height="22">&nbsp;&nbsp;&nbsp;Particulars/Item Description (old) : </td>
      <td height="22"><%=WI.getStrValue(strTemp,"")%></td>
    </tr>
    <%
		strTemp = WI.fillTextValue("old_price");
	%>
    <tr> 
      <td height="22">&nbsp;&nbsp;&nbsp;Unit Price (old) :</td>
      <td height="22"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"")%></td>
    </tr>
    <%
		strTemp = WI.fillTextValue("quantity_old");
	%>
    <tr> 
      <td height="22">&nbsp;&nbsp;&nbsp;Quantity :</td>
      <td height="22"><%=WI.getStrValue(strTemp,"")%></td>
    </tr>
    <%
		strTemp = WI.fillTextValue("unit_old");
	%>
    <tr> 
      <td height="22">&nbsp;&nbsp;&nbsp;Unit Measure :</td>
      <td height="22"><%=WI.getStrValue(strTemp,"")%></td>
    </tr>
    <%
		strTemp = WI.fillTextValue("brand_old");
	%>
    <tr> 
      <td height="22">&nbsp;&nbsp;&nbsp;Brand :</td>
      <td height="22"><%=WI.getStrValue(strTemp,"")%></td>
    </tr>
    <tr> 
      <td height="22"><strong>Replacement item info</strong></td>
      <td height="22">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;&nbsp;&nbsp;Item:</td>
      <%
		strTemp = WI.fillTextValue("item_to");
	  %>
      <td> <select name = "item_to">
          <option value="">Select Item</option>
          <%=dbOP.loadCombo("ITEM_INDEX","ITEM_NAME"," from PUR_PRELOAD_ITEM where IS_SUPPLY = "+
		  		WI.fillTextValue("is_supply")+" order by ITEM_NAME asc",strTemp, false)%> </select> </td>
    </tr>
    <tr> 
      <td>&nbsp;&nbsp;&nbsp;Particulars/Item Description : </td>
      <%
	  	strTemp = WI.fillTextValue("particular");
	  %>
      <td> <input name="particular" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="50" maxlength="64"> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;Unit Price :</td>
      <%
	  	strTemp = WI.fillTextValue("unit_price");
	  %>
      <td><input name="unit_price" type="text" class="textbox"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="AllowOnlyIntegerExtn('form_','unit_price','.')" value="<%=strTemp%>" size="12" maxlength="12"></td>
    </tr>
    <%
	  strTemp = WI.fillTextValue("quantity");
    %>
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;Quantity:</td>
      <td><input name="quantity" type="text" class="textbox"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="AllowOnlyIntegerExtn('form_','quantity','.')" value="<%=strTemp%>" size="6" maxlength="6"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;Unit Measure:</td>
      <% if(WI.fillTextValue("unit_index").length() > 0)
	  		strTemp = WI.fillTextValue("unit_index");
		  else
			strTemp = "";
	  %>
      <td><select name="unit_index">
          <option value="">Select unit</option>
          <%=dbOP.loadCombo("UNIT_INDEX","UNIT_NAME"," from PUR_PRELOAD_UNIT order by UNIT_NAME asc", strTemp, false)%> </select></td>
    </tr>
      <% if(WI.fillTextValue("brand_to").length() > 0)
	  		strTemp = WI.fillTextValue("brand_to");
		  else
			strTemp = "";
	  %>	
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp;Brand :</td>
      <td><select name="brand_to">
          <option value="">Select unit</option>
          <%=dbOP.loadCombo("BRAND_INDEX","BRAND_NAME"," from PUR_PRELOAD_BRAND order by BRAND_NAME asc", strTemp, false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
	<%
		strTemp = WI.fillTextValue("remarks");
	%>
    <tr> 
      <td height="25">REASON FOR CHANGE:</td>
      <td><input name="remarks" type="text" size="64" class="textbox" value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
  </table>
  <%}%>
  <%if(WI.fillTextValue("change_item").length() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><a href="javascript:PageAction('1');"> 
          <img src="../../../images/save.gif" border="0"> </a><font size="1">click to save update</font> 
          <a href="javascript:CancelClicked();"> <img src="../../../images/cancel.gif" border="0"> 
          </a> <font size="1">click to cancel</font></div></td>
    </tr>
  </table>
  <%}// if Change Item%>
  <%}// vPOItemsRet != null && vPOItemsRet.size()%>
  <%}// vReqInfo != null && vReqInfo.size()%>
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
  <input type="hidden" name="change_item" value="<%=WI.getStrValue(strChangeItem,"")%>">
  <input type="hidden" name="item_name" value="<%=WI.fillTextValue("item_name")%>">
  <input type="hidden" name="item_fr" value="<%=WI.fillTextValue("item_fr")%>">
  <input type="hidden" name="old_price" value="<%=WI.fillTextValue("old_price")%>">
  <input type="hidden" name="particular_old" value="<%=WI.fillTextValue("particular_old")%>"> 
  <input type="hidden" name="quantity_old" value="<%=WI.fillTextValue("quantity_old")%>"> 
  <input type="hidden" name="unit_old" value="<%=WI.fillTextValue("unit_old")%>">
  <input type="hidden" name="unit_index_fr" value="<%=WI.fillTextValue("unit_index_fr")%>">
  <input type="hidden" name="brand_old" value="<%=WI.fillTextValue("brand_old")%>">
  <input type="hidden" name="brand_fr" value="<%=WI.fillTextValue("brand_fr")%>">
  <input type="hidden" name="po_item_index" value="<%=WI.fillTextValue("po_item_index")%>">  
  <input type="hidden" name="is_supply" value="<%=WI.fillTextValue("is_supply")%>">  	  
  <input type="hidden" name="search_po" value="1">  	  
</form>
  
</body>
</html>
<%
dbOP.cleanUP();
%>