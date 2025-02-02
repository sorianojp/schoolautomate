<%@ page language="java" import="utility.*,purchasing.Requisition,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
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
function CloseWindow(){
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
	self.close();		
}
function ReloadParentWnd() {
	if(document.form_1.donot_call_close_wnd.value.length >0)
		return;
	
	if(document.form_1.close_wnd_called.value == "0") {
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
		window.opener.focus();
	}
}
function ReloadPage(){
	if(!document.form_1.supplier.value == ""){
		document.form_1.donot_call_close_wnd.value = "1";
		document.form_1.saveClicked.value = "";
		document.form_1.pageReloaded.value = "1";
		this.SubmitOnce('form_1');
	}		
}
function SaveClicked(){
	document.form_1.donot_call_close_wnd.value = "1";
	document.form_1.saveClicked.value = "1";
	document.form_1.pageReloaded.value = "";
	this.SubmitOnce('form_1');
}
function QuoteItem(strReqItemIndex,strReqIndex){	
	var pgLoc = "../quotation/quotation_encode_pop_up.jsp?req_item_index="+strReqItemIndex+"&opner_form_name=form_1&encode_pop=1&req_index="+strReqIndex;
	var win=window.open(pgLoc,"MyPage",'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SupplierSelected(){
	var selectedIndex = document.form_1.supplier.selectedIndex;	
	if(selectedIndex == 0){
		document.form_1.quoted_price.value = "";
		document.form_1.discount.value = "";
		document.form_1.unit_price.value = "";
		document.form_1.unit_price_save.value = "";
		document.form_1.total_price.value = "";
		document.form_1.brand.value = "";
		document.form_1.brand_index.value = "";
		return;
	}
	document.form_1.quoted_price.value = eval('document.form_1.quoted_price_'+selectedIndex+'.value');	
	document.form_1.discount.value = eval('document.form_1.discount_'+selectedIndex+'.value');
	document.form_1.unit_price.value = eval('document.form_1.unit_price_'+selectedIndex+'.value');
	document.form_1.unit_price_save.value = eval('document.form_1.unit_price_save_'+selectedIndex+'.value');
	document.form_1.total_price.value = eval('document.form_1.total_price_'+selectedIndex+'.value');
	document.form_1.brand.value = eval('document.form_1.brand_'+selectedIndex+'.value');	
	if (document.form_1.brand.value == 'null'){
		document.form_1.brand.value = "";
	}
	document.form_1.brand_index.value = eval('document.form_1.brand_index_'+selectedIndex+'.value');
}
</script>
<%
	
//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-PURCHASE ORDER"),"0"));
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
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"PURCHASING-PURCHASE ORDER","request_pop_up.jsp");
	Requisition REQ = new Requisition();
	Vector vReqItemsQtn = null;
	Vector vReqItems = null;
	Vector vRetResult = new Vector();
	String[] astrQuoteUnit = {"(per unit)","(whole order)"};
	String strErrMsg = null;
	String strTemp1 = null;
	String strTemp2 = null;
	String strReqIndex = WI.fillTextValue("req_index");
	String strReqItemIndex = WI.fillTextValue("req_item_index");
	int iLoop = 0;
	int iCount = 0;	

	if(WI.fillTextValue("saveClicked").equals("1")){
		if(!REQ.updateReqDetails(dbOP,request))
			strErrMsg = REQ.getErrMsg();
		else
			strErrMsg = "Operation Successful.";
	}

	vReqItems = REQ.getNonPOReqItems(dbOP,request, strReqIndex);	
	vReqItemsQtn = REQ.showQuotedNonPOItems(dbOP,request,strReqIndex);
	if(vReqItemsQtn == null || vReqItems == null)
		strErrMsg = REQ.getErrMsg();
//	if(WI.fillTextValue("pageReloaded").equals("1")){		
//		vRetResult = PO.getSupplierDetails(dbOP,request);
//		if(vRetResult == null)
//			strErrMsg = PO.getErrMsg();
//	}
%>
<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<form name="form_1" method="post" action="./request_pop_up.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A" colspan="2"><div align="center"><font color="#FFFFFF"><strong>:::: 
          REQUISITION - UPDATE ENTRIES PAGE ::::</strong></font></div></td>
    </tr>  
    <tr bgcolor="#FFFFFF"> 
      <td width="80%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        &nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong> </td>
      <td width="20%"><div align="right"><a href="javascript:CloseWindow();"> 
          <img src="../../../images/close_window.gif" border="0"> </a></div></td>
    </tr>
  </table>
  <%if(vReqItemsQtn != null && vReqItemsQtn.size() > 3){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="7" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF ITEM QUOTATION</strong></font></div></td>
    </tr>
    <tr> 
      <td width="6%" height="26" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="16%" class="thinborder"><div align="center"><strong>ITEM / PARTICULARS 
          / DESCRIPTION </strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong>SUPPLIER 
          CODE </strong></div></td>
      <td width="19%" class="thinborder"><div align="center"><strong>PRICE QUOTED</strong></div></td>
      <td width="21%" class="thinborder"><div align="center"><strong>DISCOUNT</strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong>FINAL PRICE</strong></div></td>
    </tr>
    <%for(iLoop = 0,iCount = 1;iLoop < vReqItemsQtn.size();iLoop+=12,++iCount){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=vReqItemsQtn.elementAt(iLoop)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItemsQtn.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItemsQtn.elementAt(iLoop+2)%> / <%=vReqItemsQtn.elementAt(iLoop+3)%></div></td>
      <td class="thinborder"><div align="center"><%=vReqItemsQtn.elementAt(iLoop+4)%> 
          <%		  	
			strTemp1 = "";
			strTemp2 = "";
			strErrMsg = "";
			for(; (iLoop + 12) < vReqItemsQtn.size() ;){
			 if(!(((String)vReqItemsQtn.elementAt(iLoop+9)).equals((String)vReqItemsQtn.elementAt(iLoop + 21))))
					break;
			 if(((String)vReqItemsQtn.elementAt(iLoop+7)).equals("1")){
			 System.out.println("Entered !!!!" + iLoop);
          		strTemp1 += CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),false)+
				"%<br>&nbsp;";
				
          	 }else{
          		strTemp1 += CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),true) + 
				astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+11))]+"<br>&nbsp;";
          	 }
			 strErrMsg += (String)vReqItemsQtn.elementAt(iLoop+5) + 
			 			   astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+10))]+ "<br>&nbsp;";
			 strTemp2 += (String)vReqItemsQtn.elementAt(iLoop + 8) + "<br>&nbsp;";%>
          <br>
          <%=(String)vReqItemsQtn.elementAt(iLoop + 12 + 4)%> 
          <%iLoop += 12;}
		  
		  %>
        </div></td>
      <td class="thinborder"><div align="right"><%=strErrMsg + (String)vReqItemsQtn.elementAt(iLoop+5)+
	  		astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+10))]%></div></td>
      <td class="thinborder"><div align="right"> <%=strTemp1%> 
          <%
		  	System.out.println("discount 0------------" + ((String)vReqItemsQtn.elementAt(iLoop+7)).equals("1"));
		  if(((String)vReqItemsQtn.elementAt(iLoop+7)).equals("1")){%>
          <%=CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),false)%>% 
          <%}else{%>
          <%=CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),true)+
		  astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+11))]%> 
          <%}%>
		  
        </div></td>
      <td class="thinborder"><div align="right"><%=strTemp2 + (String)vReqItemsQtn.elementAt(iLoop+8)%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="7" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : &nbsp;&nbsp;<%=iCount-1%></strong></div></td>
    </tr>
  </table>
  <%}%>
  <table bgcolor="#FFFFFF" width="100%">
  	<tr>
		<td>&nbsp;</td>
	</tr>
  </table>

<%if(vReqItems != null && vReqItems.size() > 0){%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="7" bgcolor="#B9B292" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>REQUISITION 
          ITEM</strong></font></div></td>
    </tr>
    <tr> 
      <td width="10%" height="25" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="26%" class="thinborder"><div align="center"><strong>ITEM / PARTICULARS 
          / DESCRIPTION</strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>SUPPLIER 
          CODE</strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>BRAND</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="16%" class="thinborder"><div align="center"><strong>TOTAL AMOUNT</strong></div></td>
    </tr>
    <%System.out.println("vReqItems " + vReqItems);
	for(iLoop = 1;iLoop < vReqItems.size();iLoop+=8){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(String)vReqItems.elementAt(iLoop+1)%> 
          <input type="hidden" name="qty" value="<%=(String)vReqItems.elementAt(iLoop+1)%>">
        </div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+3)%> / <%=(String)vReqItems.elementAt(iLoop+4)%></div></td>
      <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+5),"&nbsp;")%></div></td>
      <td class="thinborder"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+7),"&nbsp;")%></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+6),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right"></div></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="11%" height="25">&nbsp;</td>
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><div align="right">Supplier : 
          <%strTemp1 = WI.fillTextValue("supplier");
		  if(vReqItems != null && vReqItems.size() > 0){
		vRetResult = (Vector)vReqItems.elementAt(iLoop);
		for(int i = 0;i < vRetResult.size();i+=8){%>
          <input type="hidden" name="quoted_price_<%=(i+8)/8%>" value="<%=vRetResult.elementAt(i+2)%>">
          <input type="hidden" name="discount_<%=(i+8)/8%>" value="<%=vRetResult.elementAt(i+3)%>">
          <input type="hidden" name="unit_price_<%=(i+8)/8%>" value="<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true)%>">
          <input type="hidden" name="unit_price_save_<%=(i+8)/8%>" value="<%=vRetResult.elementAt(i+4)%>">
          <input type="hidden" name="total_price_<%=(i+8)/8%>" value="<%=vRetResult.elementAt(i+5)%>">
          <input type="hidden" name="brand_<%=(i+8)/8%>" value="<%=vRetResult.elementAt(i+6)%>">
          <input type="hidden" name="brand_index_<%=(i+8)/8%>" value="<%=vRetResult.elementAt(i+7)%>">
          <%}
		  }%>
        </div></td>
      <td width="26%"><select name="supplier" onChange="SupplierSelected();">
          <option value="">Select Supplier</option>
          <%for(iLoop = 0;iLoop < vRetResult.size();iLoop+=8){
		  		if(strTemp1.equals((String)vRetResult.elementAt(iLoop))){%>
          <option value="<%=vRetResult.elementAt(iLoop)%>"><%=vRetResult.elementAt(iLoop+1)%></option>
          <%}else{%>
          <option value="<%=vRetResult.elementAt(iLoop)%>"><%=vRetResult.elementAt(iLoop+1)%></option>
          <%}}%>
        </select></td>
      <td colspan="2"> <a href="javascript:QuoteItem('<%=strReqItemIndex%>','<%=strReqIndex%>')"> 
        click HERE to encode quotation</a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="21%" ><div align="right">Quoted Price : </div></td>
      <td colspan="2"><input type="text" class="textbox_noborder" name="quoted_price" readonly="yes" size="40"></td>
      <td width="15%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="18"><div align="right">Discount : </div></td>
      <td height="18" colspan="2"><input type="text" class="textbox_noborder" name="discount" readonly="yes" size="40"></td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="18"><div align="right">Unit Price : </div></td>
      <td height="18" colspan="2"><input type="text" class="textbox_noborder" name="unit_price" readonly="yes" size="40"> 
        <input type="hidden" name="unit_price_save"></td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="18"><div align="right">Total Price : </div></td>
      <td height="18" colspan="2"><input type="text" class="textbox_noborder" name="total_price" readonly="yes" size="40"></td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="18"><div align="right">Brand : </div></td>
      <td height="18" colspan="2"><input type="text" class="textbox_noborder" name="brand" readonly="yes" size="40"> 
        <input type="hidden" name="brand_index"></td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="5"><div align="center"><a href="javascript:SaveClicked();"> 
          <img src="../../../images/save.gif" border="0"></a><font size="1">click 
          to SAVE PO details</font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  
  <!-- all hidden fields go here -->
  <input type="hidden" name="req_index" value="<%=strReqIndex%>">
  <input type="hidden" name="req_item_index" value="<%=strReqItemIndex%>">
  <input type="hidden" name="pageReloaded" value="">
  <input type="hidden" name="isForPop" value="1">
  <input type="hidden" name="saveClicked" value="">
  <!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>