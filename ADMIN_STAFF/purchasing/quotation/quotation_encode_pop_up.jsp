<%@ page language="java" import="utility.*,purchasing.Quotation,java.util.Vector" %>
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
//	if(document.form_.opner_form_name.value == "form_1"){
//		window.opener.document.form_1.donot_call_close_wnd.value="1";
//	}
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
	self.close();		
}
function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length >0)
		return;
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
	
//	if(document.form_.close_wnd_called.value == "0") {
//		if(document.form_.opner_form_name.value == "form_1"){
//			window.opener.document.form_1.donot_call_close_wnd.value="1";
//		}			
//		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
//		window.opener.focus();
//	}
}
function ReloadPage(){
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.pageReloaded.value = "1";			
	this.SubmitOnce('form_');
}
function PageAction(strAction,strInfoIndex,strDel){
	document.form_.donot_call_close_wnd.value = 1;
	if(strAction == 0){
		if(!confirm('Delete '+strDel+' from quotation list?'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;	
	this.SubmitOnce('form_');
}
function ChangeUnit(){
	if(document.form_.discount_unit.value == 0)
		document.form_.discount_quote_unit.disabled = false;
	else
		document.form_.discount_quote_unit.disabled = true;
}
function CancelClicked(){
	document.form_.donot_call_close_wnd.value = 1;
	location = "./quotation_encode_pop_up.jsp?req_index=<%=WI.fillTextValue("req_index")%>&req_item_index="+
	"<%=WI.fillTextValue("req_item_index")%>&encode_pop=1&is_credited=<%=WI.fillTextValue("is_credited")%>";
}
function ViewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');	
	win.focus();
}

function UpdateBrand(){
	var loadPg = "../../inventory/inv_log/update_brand.jsp?opner_form_name=form_&opner_form_field=brand&inv_cat_index="+document.form_.cat_index.value;
	var win=window.open(loadPg,"UpdateBrand",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function doNotClose(){	
	document.form_.donot_call_close_wnd.value = 1;
	//return;
	}
</script>
<body bgcolor="#D2AE72" onLoad ="doNotClose();" onUnload="ReloadParentWnd();">
<%

//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-QUOTATION"),"0"));
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
								"PURCHASING-QUOTATION","quotation_encode_pop_up.jsp");
								
	Quotation QTN = new Quotation();		
	Vector vReqItems = null;	
	Vector vRetQuotedItems = null;
	Vector vRetNonQuotedItems = null;	
	Vector vEditInfo = new Vector();
	String[] astrQuoteUnit = {"(Per Unit)","(Whole Order)"};
	String strErrMsg = null;
	String strTemp = null;
	String strInfoIndex = WI.fillTextValue("info_index");
	String strReqIndex = WI.fillTextValue("req_index");
	String strReqItemIndex = WI.fillTextValue("req_item_index");	
	int iLoop = 0;
	boolean bolIsEditErr = false;	
//	System.out.println("strReqItemIndex " + strReqItemIndex);
//	System.out.println("page action " + WI.fillTextValue("page_action"));
	if(WI.fillTextValue("page_action").length() > 0 && !(WI.fillTextValue("page_action")).equals("3") 
		&& !WI.fillTextValue("pageReloaded").equals("1")){
		vReqItems = QTN.operateOnReqItemsQtn(dbOP,request,Integer.parseInt(WI.fillTextValue("page_action")),strReqIndex);
		if(vReqItems == null){
			strErrMsg = QTN.getErrMsg();
			if(WI.fillTextValue("page_action").equals("2"))
				bolIsEditErr = true;
		}
		else
			strErrMsg = "Operation Successful.";
	}

	if(WI.fillTextValue("supplier").length() > 0 || (WI.fillTextValue("page_action")).equals("3")){
		if(WI.fillTextValue("is_credited").equals("0") && strInfoIndex.length() > 0)
			vEditInfo = QTN.showUncreditedInfo(dbOP,request);		
		else
			vEditInfo = QTN.showSupplierInfo(dbOP,request);		

		if(vEditInfo == null)
			strErrMsg = QTN.getErrMsg();					
	}
	
	vReqItems = QTN.operateOnReqItemsQtn(dbOP,request,3,strReqIndex);	
	if(vReqItems == null)
		strErrMsg = QTN.getErrMsg();
	else{
		vRetNonQuotedItems = (Vector)vReqItems.elementAt(0);
		vRetQuotedItems = (Vector)vReqItems.elementAt(1);
	}
%>
<form name="form_" method="post" action="./quotation_encode_pop_up.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          QUOTATION - ENCODE QUOTATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="85%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        &nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
      <td width="15%"><div align="right"><a href="javascript:CloseWindow();"> 
          <img src="../../../images/close_window.gif" border="0"></a></div></td>
    </tr>
  </table>
  <%if(vEditInfo != null && vRetNonQuotedItems != null && vRetNonQuotedItems.size() > 3){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="46%">Canvassing No. : <strong><%=WI.getStrValue((String)vRetNonQuotedItems.elementAt(4),"No Canvass")%></strong></td>
      <td width="50%">Canvassing Date : <strong><%=WI.getStrValue((String)vRetNonQuotedItems.elementAt(6),"No Canvass")%></strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="24">&nbsp;</td>
      <td width="32%" height="24">Item : <strong><%=(String)vRetNonQuotedItems.elementAt(0)%></strong></td>
      <td width="32%" height="24">Quantity : <strong><%=(String)vRetNonQuotedItems.elementAt(1)%></strong></td>
      <td width="32%">Unit : <strong><%=(String)vRetNonQuotedItems.elementAt(3)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Particulars/Item Description: <strong><%=(String)vRetNonQuotedItems.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
  </table>  
  <table width="100%" height="277" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="3">Supplier : 
      <%if(vEditInfo != null && vEditInfo.size() > 3)
				strTemp = (String)vEditInfo.elementAt(3);		
		  else
				strTemp = WI.fillTextValue("supplier");%>
        <select name="supplier" onChange="ReloadPage()">
          <option value="">Select supplier</option>
          <%=dbOP.loadCombo("PROFILE_INDEX","SUPPLIER_CODE"," from PUR_SUPPLIER_PROFILE " +
		  " where is_del = 0 and status = 1 order by SUPPLIER_CODE asc", strTemp, false)%> 
        </select>
				<!--
		<%/*	strTemp = WI.getStrValue(strTemp,"");
				if (strTemp.length() == 0){
			  if (vEditInfo != null && vEditInfo.size() > 3)
				if(vEditInfo.elementAt(2) == null)
					strTemp = (String)vEditInfo.elementAt(10);
				else
					strTemp = "";
			  else
				strTemp = WI.fillTextValue("non_ac_supplier");
				*/
		%>
		<input type="text" name="non_ac_supplier" class="textbox" value="<%//=strTemp%>"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="1">Enter name here for uncredited suppliers</font> 
        <%//}%>      
				-->
			</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><u>Contact Information :</u></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td height="20">Supplier name : </td>
      <td width="81%">
			  <%if(vEditInfo != null && vEditInfo.size() > 1){%>
        	<%=WI.getStrValue((String)vEditInfo.elementAt(2),"")%>&nbsp;
        <%}else{%>
					&nbsp;
				<%}%>
			</td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td width="1%" height="20">&nbsp;</td>
      <td width="16%" height="20">Contact Person : </td>
      <td> 
        <%if(vEditInfo != null && vEditInfo.size() > 1){%>
        <%=WI.getStrValue((String)vEditInfo.elementAt(1),"")%>&nbsp; 
        <%}else{%>
        &nbsp; 
        <%}%>      </td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">Contact Nos. : </td>
      <td valign="top"> 
        <%if(vEditInfo != null && vEditInfo.size() > 1){%>
        <%=WI.getStrValue((String)vEditInfo.elementAt(0),"")%>&nbsp; 
        <%}else{%>
        &nbsp; 
        <%}%>      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Brand Name</td>
      <td height="25"><input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="6" class="textbox"
	   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeyUp = "AutoScrollList('form_.starts_with','form_.brand',true);" >
      <%if(vEditInfo != null && vEditInfo.size() > 3)
					strTemp = (String)vEditInfo.elementAt(9);
				else
	  			strTemp = WI.fillTextValue("brand");%>
        <select name="brand">
          <option value="">Select brand</option>
          <%=dbOP.loadCombo("BRAND_INDEX","BRAND_NAME"," from PUR_PRELOAD_BRAND " +
														" where inv_cat_index = " + WI.getStrValue(WI.fillTextValue("cat_index"),"0") +
														" order by BRAND_NAME asc", strTemp, false)%>
        </select>         
        <a href='javascript:UpdateBrand();'><img src="../../../images/update.gif" width="60" height="25" border="0"></a><font size="1">click to UPDATE list of Brand Name</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Price Quoted :</td>
      <td height="25"> 
        <%if(vEditInfo != null && vEditInfo.size() > 3)
			strTemp = (String)vEditInfo.elementAt(4);
		else
	  		strTemp = WI.fillTextValue("price_quoted");%>
        <input type="text" name="price_quoted" class="textbox" value="<%=strTemp%>"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="AllowOnlyIntegerExtn('form_','price_quoted','.')"> 
      <%if(vEditInfo != null && vEditInfo.size() > 3)
					strTemp = (String)vEditInfo.elementAt(7);
			  else{
					if(WI.fillTextValue("quote_unit").equals("0"))
						strTemp = "0";
					else
						strTemp = "1";
			 	}
			 %>
        &nbsp; <select name="quote_unit">
          <option value="0">Per Unit</option>
          <%if(strTemp.equals("1")){%>
          <option value="1" selected>Whole Order</option>
          <%}else{%>
          <option value="1">Whole Order</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Discount : </td>
      <td> 
        <%if(vEditInfo != null && vEditInfo.size() > 3)
			strTemp = (String)vEditInfo.elementAt(5);
	    else
	  		strTemp = WI.fillTextValue("discount");%>
        <input type="text" name="discount" class="textbox" value="<%=strTemp%>"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="AllowOnlyIntegerExtn('form_','discount','.')"> 
        <%if(vEditInfo != null && vEditInfo.size() > 3)
			strTemp = (String)vEditInfo.elementAt(6);
		  else{
			if(WI.fillTextValue("discount_unit").equals("0"))
				strTemp = "0";
			else
				strTemp = "1";
		  }%>
        &nbsp; <select name="discount_unit" onChange="ChangeUnit();">
          <option value="">Select Unit</option>
          <%if(strTemp.equals("0")){%>
          <option value="1">Percentage</option>
          <option value="0" selected>Specific Amount</option>
          <%}else if(strTemp.equals("1")){%>
          <option value="1" selected>Percentage</option>
          <option value="0">Specific Amount</option>
          <%}else{%>
          <option value="1">Percentage</option>
          <option value="0">Specific Amount</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        <%if(strTemp.equals("0"))
			strErrMsg = "";
		  else
			strErrMsg = "disabled";
		  if(vEditInfo != null && vEditInfo.size() > 3)
				strTemp = WI.getStrValue((String)vEditInfo.elementAt(8));
		  else{
				if(WI.fillTextValue("discount_quote_unit").equals("0"))
					strTemp = "0";
				else
					strTemp = "1";
		   }%>
        <select name="discount_quote_unit" <%=strErrMsg%>>
          <option value="0">Per Unit</option>
          <%if(strTemp.equals("1")){%>
          <option value="1" selected>Whole Order</option>
          <%}else{%>
          <option value="1">Whole Order</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><div align="center"><font size="1"> 
          <%if(WI.fillTextValue("page_action").equals("3") || bolIsEditErr){%>
          <a href="javascript:PageAction(2,'<%=strInfoIndex%>','');"> <img src="../../../images/edit.gif" border="0"></a>click 
          to EDIT quotation details 
          <%}else{%>
          <a href="javascript:PageAction(1,'','');"> <img src="../../../images/add.gif" border="0"></a>click 
          to ADD quotation details 
          <%}%>
          <a href="javascript:CancelClicked();"> <img src="../../../images/cancel.gif" border="0"></a>click 
          to CANCEL entries </font></div></td>
    </tr>
  </table>
  <%if(vRetQuotedItems != null && vRetQuotedItems.size() > 3){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="9" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>ITEM 
          QUOTATION(S)</strong></font></div></td>
    </tr>
    <tr> 
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>COUNT</strong></font></div></td>
      <td width="18%" height="25" class="thinborder"><div align="center"><font size="1"><strong>SUPPLIER</strong></font></div></td>
      <td width="23%" class="thinborder"><div align="center"><font size="1"><strong>BRAND 
          NAME</strong></font></div></td>
      <td width="23%" class="thinborder"><div align="center"><font size="1"><strong>PRICE 
          QUOTED</strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>DISCOUNT</strong></font></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>UNIT 
          PRICE</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>TOTAL 
          AMOUNT</strong></font></div></td>
      <td width="7%" class="thinborder"><div align="center"><font size="1"><strong>EDIT</strong></font></div></td>
      <td width="7%" class="thinborder"><div align="center"><font size="1"><strong>DELETE</strong></font></div></td>
    </tr>
    <%for(iLoop = 0;iLoop < vRetQuotedItems.size();iLoop+=17){%>
    <tr> 
      <td class="thinborder"><div align="center"><%=(iLoop+17)/17%></div></td>
      <td height="25" class="thinborder"><%=WI.getStrValue((String)vRetQuotedItems.elementAt(iLoop+4),"","","(uncredited)"+ (String)vRetQuotedItems.elementAt(iLoop+14))%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetQuotedItems.elementAt(iLoop+13),"&nbsp;")%></td>
      <td class="thinborder"><div align="right"><%=vRetQuotedItems.elementAt(iLoop+5)%> 
          <%=astrQuoteUnit[Integer.parseInt((String)vRetQuotedItems.elementAt(iLoop+10))]%></div></td>
      <td class="thinborder"><div align="right"> 
          <%if(((String)vRetQuotedItems.elementAt(iLoop+7)).equals("1")){%>
          <%=CommonUtil.formatFloat(Double.parseDouble((String)vRetQuotedItems.elementAt(iLoop+6)),false)%>% 
          <%}else{%>
          <%=CommonUtil.formatFloat(Double.parseDouble((String)vRetQuotedItems.elementAt(iLoop+6)),true)+
		  astrQuoteUnit[Integer.parseInt((String)vRetQuotedItems.elementAt(iLoop+12))]%> 
          <%}%>
        </div></td>
      <td class="thinborder"><div align="right"><%=vRetQuotedItems.elementAt(iLoop+11)%></div></td>
      <td class="thinborder"><div align="right"><%=vRetQuotedItems.elementAt(iLoop+8)%></div></td>
      <td class="thinborder"><div align="center"> 
	  <a href="javascript:PageAction(3,'<%=vRetQuotedItems.elementAt(iLoop+9)%>','')"> 
          <img src="../../../images/edit.gif" border="0"></a></div></td>
      <td class="thinborder"><div align="center"> <a href="javascript:PageAction(0,'<%=vRetQuotedItems.elementAt(iLoop+9)%>','<%=vRetQuotedItems.elementAt(iLoop+4)%>')"> 
          <img src="../../../images/delete.gif" border="0"></a></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="9" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : &nbsp;&nbsp;<%=((iLoop+17)/17)-1%></strong></div></td>
    </tr>
  </table>
  <%}%>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table> 
  <input type="hidden" name="info_index" value="<%=strInfoIndex%>">
  <input type="hidden" name="req_index" value="<%=strReqIndex%>">
  <input type="hidden" name="req_item_index" value="<%=strReqItemIndex%>">
  <%if(vRetNonQuotedItems != null && vRetNonQuotedItems.size() > 3)
  		strTemp = (String)vRetNonQuotedItems.elementAt(1);
	else
		strTemp = "";
	strTemp = ConversionTable.replaceString(strTemp,",","");		
%>
  <input type="hidden" name="qty" value="<%=strTemp%>">  
  <input type="hidden" name="encode_pop" value="1">
  <input type="hidden" name="page_action" value="<%=WI.fillTextValue("page_action")%>">
  <input type="hidden" name="pageReloaded" value="">
  <input type="hidden" name="opner_form_name" value="<%=WI.fillTextValue("opner_form_name")%>">
  <input type="hidden" name="is_credited" value="<%=WI.fillTextValue("is_credited")%>">
  <input type="hidden" name="cat_index" value="<%=WI.fillTextValue("cat_index")%>">
  <!--<input type="hidden" name="opner_form_name" value="<%//=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>"> -->
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