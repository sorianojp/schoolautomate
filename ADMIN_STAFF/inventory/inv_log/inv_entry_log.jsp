<%@ page language="java" import="utility.*, inventory.*, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode ="";
boolean bolIsVMA = strSchCode.startsWith("VMA");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Inventory Entry Log</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function ChangeType()
{
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function OpenSearchPO(){
	document.form_.print_pg.value = "";
	var pgLoc = "../../purchasing/purchase_order/purchase_request_view_search.jsp?opner_info=form_.po_num";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function OpenSearchREQ(){
	document.form_.print_pg.value = "";
	var pgLoc = "../../purchasing/requisition/requisition_view_search.jsp?opner_info=form_.po_num&is_supply=form_.inventory_type";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();	
}

function UpdateDonors() {
	var pgLoc = "../inv_log/donors.jsp?donor_type="+document.form_.type_index.value;
	var win=window.open(pgLoc,"UpdateDonor",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPg(){
	document.form_.print_pg.value = "1";
	this.SubmitOnce('form_');
}
//*** according to donbosco, i have to let them edit qty.. **/
function AjaxUpdateQty(labelID, strRef) {
	strNewQty = prompt('Please enter new quantity.','');
	if(strNewQty == null || strNewQty.length == 0) 
		return;
	//update here.. 
		var objCOAInput = document.getElementById(labelID);

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=151&new_qty="+strNewQty+"&ref="+strRef;
	
		this.processRequest(strURL);

}


</script>
</head>
<%
	if (WI.fillTextValue("print_pg").length() > 0){%>
		<jsp:forward page="./inv_entry_log_print.jsp" />
	<% return;}
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-LOG"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
								"INVENTORY-INVENTORY LOG","inv_entry_log.jsp");
	
	Vector vRetResult = null;
	Vector vPODtls = null;
	Vector vPOItems = null;
	int i = 0;
	String strErrMsg = null;
	String strType = null;
	String strPurType = WI.getStrValue(WI.fillTextValue("purchase_type"),"1");
	String strDonorType = null;
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit = null;
	int iSearchResult = 0;
	String strFinCol = null;
	double dTotalPrice = 0d;
	double dTemp = 0d;
	String strClass = null;
	String[] astrEntryType = {"DONATION","PURCHASE","EXISTING STOCKS"};	
	String strReadonly = "";
	String strRefIndex = null;

	
	strTemp = WI.fillTextValue("page_action");
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");

	InventoryLog InvLog = new InventoryLog();
	if(strSchCode.startsWith("UDMC"))
		InvLog.fixEntryLogs(dbOP);
		
	strTemp2 = WI.fillTextValue("entry_type");
		// this here is for deleting an item	
	if(strTemp.length() > 0  && strTemp.equals("0")) {
		if(InvLog.operateOnInventoryEntryMain(dbOP, request, 0) != null){
				strErrMsg = "Item Deletion successful.";
				strPrepareToEdit = "0";
		}else{
				strErrMsg = InvLog.getErrMsg();
		}
	}
	
	if (strTemp2.length() > 0) {
	   if (strTemp2.equals("1")){
		//  hidden jan. 26, 2008 there is no need to have non po items... 
		//	if(strPurType.equals("0"))
		// 	vPODtls = InvLog.getNonPODtls(dbOP, request, 1);				
		//	else
				vPODtls = InvLog.getPODtls(dbOP, request, 1);
				
		  if (vPODtls != null) {
				 if(strTemp.length() > 0 && strTemp.equals("1")) {// log purchased PO
					 if(InvLog.operateOnInventoryEntryMain(dbOP, request, 1) != null ) {
						 strErrMsg = "Operation successful.";
						 strPrepareToEdit = "0";
					 } else {
						 strErrMsg = InvLog.getErrMsg();
					 }
				 }
				 
//			   if(strPurType.equals("0"))
//					 vPOItems = InvLog.getNonPODtls(dbOP, request, 2);
//				else

					vPOItems = InvLog.getPODtls(dbOP, request, 2);
			   if (vPOItems == null) {
					 if(strErrMsg == null)						 
						strErrMsg = InvLog.getErrMsg();
				 }
		   } else {
				if(strErrMsg == null)
					strErrMsg = InvLog.getErrMsg();
		   }
		} else {// if (strTemp2.equals("1")) entry for donations and old stocks
		  if(strTemp.length() > 0 && strTemp.equals("1")) {
			 if(InvLog.operateOnInventoryEntryMain(dbOP, request, 1) != null ){
				strErrMsg = "Item Entry successful.";
				strPrepareToEdit = "0";
			 }else{
				strErrMsg = InvLog.getErrMsg();
			 }
		   }
	    } // else // if (strTemp2.equals("1"))
	}//if (strTemp2.length() > 0)

	vRetResult = InvLog.operateOnInventoryEntryMain(dbOP, request, 4);
	if (vRetResult != null)
		iSearchResult = InvLog.getSearchCount();
	else if (vRetResult == null && strErrMsg == null && WI.fillTextValue("inv_date").length()>0)
		strErrMsg = InvLog.getErrMsg();

boolean bolLogItemsNotLogged = false;
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./inv_entry_log.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY LOG - INVENTORY ENTRY LOG PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><font size="3" color="red"><strong><%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></font></td>
    </tr>
<%
if(bolIsVMA){
%>
	<tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%" height="25">SY-TERM</td>
      <td height="25" colspan="4"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        -
        <select name="semester">
		<%
		strTemp = WI.fillTextValue("semester");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
		%>
		<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
          
        </select>
	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3">
<%
strTemp = WI.fillTextValue("show_con");
if(strTemp.equals("1")) {
	strTemp = "";
	strErrMsg = " checked";
	bolLogItemsNotLogged = true;
}
else {
	strTemp = " checked";
	strErrMsg = "";	
}
%>
	  <input type="radio" name="show_con" value="0" <%=strTemp%> onClick="ReloadPage();"> Log Per Date
	  <input type="radio" name="show_con" value="1" <%=strErrMsg%> onClick="ReloadPage();"> Log All Items not yet Logged
	  </td>
    </tr>
    <tr> 
      <td height="25" width="4%">&nbsp;</td>
      <td width="20%">Date: </td>
      <td width="18%">

<%if(!bolLogItemsNotLogged) {

strTemp = WI.fillTextValue("inv_date");
if (strTemp.length()==0)
	strTemp = WI.getTodaysDate(1);
%>
      <input name="inv_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
    <a href="javascript:show_calendar('form_.inv_date');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
<%}else{%>
		xxxxxxx
<%}%>	
	</td>
	<td width="58%" align="left"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
</table>
<%if (WI.fillTextValue("inv_date").length()>0) {%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="4%" height="30">&nbsp;</td>
      <td width="20%">Entry Type</td>
			<%
		  	strType = WI.fillTextValue("entry_type");
			%> 
      <td valign="middle">
			 <select name="entry_type" onChange="ReloadPage();">
          <option value="" selected>Select Type</option>
          <%if (strType.equals("0")){%>
          <option value="0" selected>Donation</option>
          <option value="1">Purchase</option>
          <option value="2">On Hand</option>
          <%}else if (strType.equals("1")){%>
          <option value="0">Donation</option>
          <option value="1" selected>Purchase</option>
          <option value="2">On Hand</option>
          <%} else if (strType.equals("2")) {%>
          <option value="0">Donation</option>
          <option value="1">Purchase</option>
          <option value="2" selected>On Hand</option>
          <%} else {%>
          <option value="0">Donation</option>
          <option value="1">Purchase</option>
          <option value="2">On Hand</option>
          <%}%>
        </select></td>
    </tr>
		<input type="hidden" name="purchase_type" value="1">
		
	  <%if (strType.equals("1")){%>
		<!--
    <tr>
      <td height="30">&nbsp;</td>
      <td>Purchase type </td>
			<%
		  	strPurType = WI.getStrValue(WI.fillTextValue("purchase_type"),"1");
			%> 
      <td height="30" valign="middle">						
			<select name="purchase_type" onChange="ReloadPage();">
        <option value="0">Non PO Item</option>
        <%if (strPurType.equals("1")){%>
        <option value="1" selected>PO Item</option>
        <%} else {%>
        <option value="1">PO Item</option>
        <%}%>
      </select>
			
			</td>
    </tr>
		-->
		<%
			if (strPurType.equals("1"))	
				strTemp = "Purchase Order No.";
			else
				strTemp = "Requisition No.";
		%>
    <tr> 
      <td height="30">&nbsp;</td>
      <td><%=strTemp%></td>
		 <%if(WI.fillTextValue("po_num").length() > 0){
		 			strTemp = WI.fillTextValue("po_num");
		   }else{
					strTemp = "";
		   }		 
		  %> 			
      <td width="76%" height="30" valign="middle"> 
 		  <input name="po_num" type="text" class="textbox" size="20" maxlength="20" value="<%=strTemp%>">
			<%if(strPurType.equals("1")){%>
 			  <a href="javascript:OpenSearchPO();"><img src="../../../images/search.gif" border="0"></a>
			<%}else{%>
				<a href="javascript:OpenSearchREQ();"><img src="../../../images/search.gif" border="0"></a>      
			<%}%>
	  </td>
    </tr>		
		
    <%} else if(strType.equals("0")) {%>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Donor Type</td>
			<%
				strDonorType = WI.fillTextValue("type_index");
			%>			
      <td height="30" valign="middle"> 
	    <select name="type_index" onChange="ReloadPage();">
          <option value="">Select Type</option>
          <%=dbOP.loadCombo("donor_type_index","donor_type"," from inv_preload_donor_type " +
		  					"order by donor_type", strDonorType, false)%> 
		</select> 
		<a href='javascript:viewList("inv_preload_donor_type","DONOR_TYPE_INDEX","DONOR_TYPE",
		"DONOR TYPE","INV_DONOR_LIST","DONOR_TYPE_INDEX"," and is_valid = 1","","type_index")'>
		<img src="../../../images/update.gif" border="0"></a> 
		<!--<a href='javascript:viewList("PUR_PRELOAD_UNIT","UNIT_INDEX","UNIT_NAME","UNITS",
		"INV_REG_ITEM, INV_REG_ITEM", "BIG_UNIT,small_unit", 
		" and INV_REG_ITEM.IS_VALID = 1, and INV_REG_ITEM.IS_VALID = 1","","big_index")'>
		-->
        <font size="1">click to update DONOR TYPE list</font></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Donor Name</td>
        <%
					strTemp2 = WI.fillTextValue("donor_index");
				%>
      <td height="30" valign="middle"> 
			  <select name="donor_index" onChange="ReloadPage();">
          <option value="">Select donor</option>
					<%if (strDonorType.length()>0){%>
  	        <%=dbOP.loadCombo("donor_index","name"," from inv_donor_list where is_valid = 1 " +
							" and donor_type_index = "+strDonorType+" order by name", strTemp2, false)%> 
          <%}%>
        </select>
        <%if (strDonorType.length() > 0){%>
					<font size="1"><a href="javascript:UpdateDonors();">
					<img src="../../../images/update.gif"  border="0"> 
					</a> click to update list of DONORS </font>
				<%}%></td>
    </tr>
    <%}%>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="30" valign="middle">&nbsp; </td>
    </tr>
  </table>
  <%if (strType.equals("1")){
		  if (vPODtls!=null && vPODtls.size()>0){%>	
			<%if (strPurType.equals("1")){
				strTemp = "PO ";
			%>
        <input type="hidden" name="po_index" value="<%=(String)vPODtls.elementAt(0)%>">
			<%}else{
			strTemp = "REQUISITION ";
			%>
				<input type="hidden" name="requisition_index" value="<%=(String)vPODtls.elementAt(0)%>">
			<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	 <tr> 
      <td height="19" colspan="3"><hr size="1"></td>
    </tr>
    <tr bgcolor="#C78D8D"> 
      <td width="5%" height="26">&nbsp;</td>
      <td colspan="2" bgcolor="#C78D8D"><strong><%=strTemp%> DETAILS<font color="#FFFFFF"></font></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td width="18%"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td width="77%"><strong><%=WI.getStrValue((String)vPODtls.elementAt(3),"&nbsp;")%></strong></td>
    </tr>

    <tr> 
      <td height="26">&nbsp;</td>
      <td>Department</td>
      <td><strong><%=WI.getStrValue((String)vPODtls.elementAt(5),"&nbsp;")%></strong></td>
    </tr>

    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type</td>
      <td><strong>
      <%if (((String)vPODtls.elementAt(i+7)).equals("0")){%>New<%}else{%>Replacement<%}%>
      </strong></td>
    </tr>
  </table>
<%if (vPOItems != null && vPOItems.size()>0){%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td  height="25" colspan="9" align="center"><font color="#FFFFFF"><strong>LIST 
          OF ITEMS DELIVERED </strong></font></td>
    </tr>
	<!--
    <tr> 
      <td  height="28" colspan="8"><font size="1">ITEM USER GROUP </font>: <font size="1"> 
        <strong>$user_group </strong></font></td>
    </tr>
	-->
    <tr> 
      <td width="5%"  height="28" align="center"><font size="1"><strong>ITEM 
        #</strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>QTY</strong></font></td>
      <td width="4%" align="center"><strong><font size="1">UNIT</font></strong></td>
      <td width="28%" align="center"><font size="1"><strong>PARTICULARS/ITEM 
        DESCRIPTION </strong></font></td>
      <td width="27%" align="center"><font size="1"><strong>SUPPLIER</strong></font></td>
      <td width="8%" align="center"><font size="1"><strong>UNIT PRICE</strong></font></td>
      <td width="9%" align="center"><strong><font size="1">TOTAL PRICE</font></strong></td>
      <td width="7%" align="center"><strong><font size="1">CONVERSION QTY </font></strong></td>
      <td width="7%" align="center"><strong><font size="1">LOG ITEM</font></strong></td>
    </tr>
    <% int iTemp = 1;
    for (i = 0 ; i < vPOItems.size(); i+=15, ++iTemp){	
		//	if(((String)vPOItems.elementAt(i+12)).equals("1.0"))
		//		strReadonly = " readonly";
		//	else
		//		strReadonly = "";
		%>
    <tr> 
      <input type="hidden" name="item_index_<%=(String)vPOItems.elementAt(i)%>" 
				value="<%=(String)vPOItems.elementAt(i+1)%>">				
			<input type="hidden"  name="qty_<%=(String)vPOItems.elementAt(i)%>" 
				value="<%=(String)vPOItems.elementAt(i+4)%>" >
      <input type="hidden" name="unit_index_<%=(String)vPOItems.elementAt(i)%>" 
				value="<%=(String)vPOItems.elementAt(i+5)%>">
      <input type="hidden" name="brand_index_<%=(String)vPOItems.elementAt(i)%>" 
				value="<%=WI.getStrValue((String)vPOItems.elementAt(i+10),"")%>">				
      <td  height="26" align="center"><font size="1"><%=iTemp%></font></td>
      <td align="right"><font size="1"><%=CommonUtil.formatFloat((String)vPOItems.elementAt(i+4),true)%></font></td>
      <td><font size="1"> 
        <%=(String)vPOItems.elementAt(i+6)%>
      <!--
				<select name="small_index<%//=(String)vPOItems.elementAt(i)%>" style="font-size:9px">
          <option value="">Select unit</option>
          <%//=dbOP.loadCombo("unit_index","unit_name"," from pur_preload_unit order by unit_name", strTemp, false)%> 
			    <%//=dbOP.loadCombo("unit_index","unit_name"," from pur_preload_unit " + 
					//			" where UNIT_INDEX = " + (String)vPOItems.elementAt(i+8) +
					//			" order by unit_name", strTemp, false)%> 
        </select>				
				-->
      </font></td>
			<%
				strTemp = "";
				if(((String)vPOItems.elementAt(i + 14)).equals("1")){
					strTemp = "<br>[free item]";
				}				
			%>			
      <td><font size="1"><%=(String)vPOItems.elementAt(i+2)%> <%=WI.getStrValue((String)vPOItems.elementAt(i+3),"/ ","","")%> <%=WI.getStrValue((String)vPOItems.elementAt(i+11),"(",")","")%> <%=strTemp%></font></td>
      <td><font size="1"><%=(String)vPOItems.elementAt(i+7)%></font></td>
      <td align="right"><font size="1"><%=(String)vPOItems.elementAt(i+8)%></font></td>
	  <%
	  	dTotalPrice += Double.parseDouble((String)vPOItems.elementAt(i+9));
	  %>
      <td align="right"><font size="1"><%=CommonUtil.formatFloat(Double.parseDouble((String)vPOItems.elementAt(i+9)),true)%></font></td>
			<%if(WI.fillTextValue("inventory_type").equals("0") || 
		 			 WI.fillTextValue("inventory_type").equals("3"))
					 strReadonly = " readonly";
				 else
				 		strReadonly = "";
					 
			%>					
      <td>
				<input name="conversion_qty_<%=(String)vPOItems.elementAt(i)%>" type="text" class="textbox" tabindex="-1" 
				onBlur="AllowOnlyFloat('form_','conversion_qty_<%=(String)vPOItems.elementAt(i)%>');style.backgroundColor='white';"
				onKeyUp="AllowOnlyFloat('form_','conversion_qty_<%=(String)vPOItems.elementAt(i)%>');"
				onFocus="style.backgroundColor='#D3EBFF'" <%=strReadonly%>
				value="<%=(String)vPOItems.elementAt(i+12)%>" size="3" maxlength="10" style="text-align:right">
			<font size="1"><%=(String)vPOItems.elementAt(i+13)%></font></td>
      <td align="center"> <a href='javascript:PageAction(1,"<%=(String)vPOItems.elementAt(i)%>");'><img src="../../../images/save.gif" border="0"></a></td>
    </tr>
    <%}%>
    <tr> 
      <td  height="25" colspan="4"><font size="1"><strong>TOTAL 
          ITEM(S) : &nbsp;&nbsp;<%=iTemp-1%></strong></font></td>
      <td  height="25" colspan="2" align="right"><font size="1"><strong>TOTAL 
          AMOUNT : </strong></font></td>
      <td  height="25" align="right"><font size="1"><strong><%=CommonUtil.formatFloat(dTotalPrice,true)%>&nbsp;</strong></font></td>
      <td align="right">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%}//po items
  }//po dtls%>
  <%} else {
  if (WI.fillTextValue("donor_index").length()>0 ||  (strType.equals("2"))){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25" width="4%">&nbsp;</td>
      <td width="18%"><strong>Item Category</strong></td>
      <td width="78%">
      <%strTemp = WI.fillTextValue("cat_index");%>
		<select name="cat_index" onChange="ReloadPage();">
          <option value="">Select category</option>
		<%=dbOP.loadCombo("inv_cat_index","inv_category"," from inv_preload_category " +
		  					"where is_supply_cat = " + WI.getStrValue(WI.fillTextValue("inventory_type"),"0") + "order by inv_category", strTemp, false)%> 
    </select>
        <!--
		<font size="1">		
		<a href='javascript:viewList("INV_PRELOAD_CATEGORY","INV_CAT_INDEX","INV_CATEGORY","ITEM CATEGORIES",
		"INV_REG_ITEM","INV_CAT_INDEX","","","cat_index")'>
		<img src="../../../images/update.gif" border="0"></a> 
        click to update list of CATEGORY</font>
		-->		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td ><strong>Item Classification</strong></td>
	  <%
		strClass = WI.fillTextValue("class_index");
	  %>
      <td>
	  <select name="class_index" onChange="ReloadPage();">
        <option value="">Select Class</option>
        <%=dbOP.loadCombo("inv_class_index","classification"," from inv_preload_class " +
		  				  "where inv_cat_index = " + WI.getStrValue(WI.fillTextValue("cat_index"),"-1") + 
						  "order by classification", strClass, false)%>
      </select></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td ><strong>Item Name</strong></td>
      <td>
      <input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="12" class="textbox"
	   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeyUp = "AutoScrollList('form_.starts_with','form_.item_reg_index',true);" >
	   &nbsp;<%strTemp2 = WI.fillTextValue("item_reg_index");%>
		<select name="item_reg_index" onChange="ReloadPage();">
          <option value="">Select item</option>		
		<%if (strTemp.length()>0){%>		
			<%/*=dbOP.loadCombo("item_index","isnull(classification,''), item_name"," from pur_preload_item " +
					"left join inv_preload_class on (pur_preload_item.inv_class_index = inv_preload_class.inv_class_index)" +
					"where pur_preload_item.inv_cat_index = " + WI.getStrValue(strTemp,"0") +
					" and exists(select * from inv_reg_item where pur_preload_item.item_index = item_index)" +
					WI.getStrValue(WI.fillTextValue("class_index")," and inv_class_index = ","","") +
					"order by item_name", strTemp2, false) */%> 		

			<%=dbOP.loadCombo("item_reg_index","item_name, brand_name"," from pur_preload_item " +
					"join inv_reg_item on (pur_preload_item.item_index = inv_reg_item.item_index) " +
					"left join pur_preload_brand on (inv_reg_item.brand_index = pur_preload_brand.brand_index) " +
					"where pur_preload_item.inv_cat_index = " + WI.getStrValue(strTemp,"0") +
					WI.getStrValue(WI.fillTextValue("class_index")," and inv_class_index = ","","") +
					" and is_valid = 1 order by item_name", strTemp2, false)%> 												
		<%}%>
    </select>
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><strong>Quantity</strong></td>
      <td>
      <%strTemp = WI.fillTextValue("qty");%> 
       <input name="qty" type="text" class="textbox" value="<%=strTemp%>" size="12" maxlength="12"
	   onKeyUp= 'AllowOnlyFloat("form_","qty")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyFloat("form_","qty");style.backgroundColor="white"'>
        &nbsp; 
        <%strTemp = WI.fillTextValue("small_index");%>
        <select name="small_index">
          <option value="">Select unit</option>
		<%//=dbOP.loadCombo("unit_index","unit_name"," from pur_preload_unit order by unit_name", strTemp, false)%>		
          <%=dbOP.loadCombo("UNIT_INDEX","UNIT_NAME"," from PUR_PRELOAD_UNIT " +
		  					" where exists(select * from inv_reg_item where item_reg_index = " + 
									WI.getStrValue(WI.fillTextValue("item_reg_index"),"0") + 
									"and (UNIT_INDEX = small_unit or unit_index = big_unit))" + 
							" order by UNIT_NAME asc ", strTemp, false)%>		
    </select>      </td>
    </tr>
    <tr> 
      <td height="18" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%">&nbsp;<font size="1">
     <%if (iAccessLevel>1){%> 
     <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> Click to add entry 
     <%}%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%}
  }%>
  <%if (vRetResult!=null && vRetResult.size()>0){
  String strSQLQuery = "select count (*) from inv_item where inv_entry_index = ? and is_valid = 1 " +
	              " and not exists(select inv_stat_index from inv_preload_status where is_default = 1 " +
    	          " and inv_preload_status.inv_stat_index = inv_item.inv_stat_index) ";
  //get number of items already logged.. 				
  java.sql.PreparedStatement pstmt = dbOP.getPreparedStatement(strSQLQuery);
  java.sql.ResultSet rs = null;
  
  %>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="12" class="thinborder"><div align="center"> 
          <p><strong><font size="2"> INVENTORY ENTRY LIST FOR THE DATE (<%=WI.fillTextValue("inv_date")%>)</font></strong></p>
        </div></td>
    </tr>
    <tr> 
      <td  height="25" colspan="3" class="thinborderBOTTOMLEFT" align="left"><font size="1"><strong>TOTAL 
        ITEMS: &nbsp;&nbsp;<%=iSearchResult%></strong></font></td>
      <td colspan="3" align="right" class="thinborderBOTTOM">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/InvLog.defSearchSize;
		if(iSearchResult % InvLog.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1){%>
        Page
        <select name="jumpto" onChange="ReloadPage();">
          <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
          <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%	}
			}// end page printing
			%>
        </select> 
        <%} else {%>
        &nbsp;
        <%} //if no pages %>      </td>
    </tr>
    <tr align="center" style="font-weight:bold"> 
      <td width="14%" height="25" class="thinborder"><font size="1">Entry Type </font></td>
      <td width="27%" class="thinborder"><font size="1">Reference</font></td>
      <td width="29%" class="thinborder"><font size="1">Item</font></td>
      <td width="13%" class="thinborder"><font size="1">Quantity</font></td>
      <td width="13%" class="thinborder"><font size="1">Already Logged</font></td>
      <td width="17%" class="thinborder">&nbsp;</td>
    </tr>
    <%
			//System.out.println("vRetResult " + vRetResult);
		for (i=0; i< vRetResult.size(); i+=19) {%>
    <tr> 
      <td class="thinborder"><font size="1"> 
				<%=astrEntryType[Integer.parseInt((String)vRetResult.elementAt(i+1))]%>
      </font> </td>
      <td class="thinborder"><font size="1"> 
				<!-- for donated items-->	
	      &nbsp;
	      <%if ((String)vRetResult.elementAt(i+5) != null){
					strRefIndex = WI.getStrValue((String)vRetResult.elementAt(i+7),"0");
				%>
	      <font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></font>
	      <!-- for purchased  items-->	
        <%} else if(vRetResult.elementAt(i+6) != null) {
					strRefIndex = WI.getStrValue((String)vRetResult.elementAt(i+9),"0");
				%>
        <%=WI.getStrValue((String)vRetResult.elementAt(i+6),"PO Number : ","<br>","&nbsp;")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp;")%> 
				<!-- for purchased items from non credited suppliers -->	
        <%} //else {
					//strRefIndex = WI.getStrValue((String)vRetResult.elementAt(i+21),"0");
				%>
        <%//=WI.getStrValue((String)vRetResult.elementAt(i+20),"REQ. Number : ","<br>","&nbsp;")%> <%//=WI.getStrValue((String)vRetResult.elementAt(i+19),"&nbsp;")%> 
        <%//}%>
      </font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+15),"Item Code: ","<br>","")%><%=((String)vRetResult.elementAt(i+3))%></font></td>
			<%strTemp =(String)vRetResult.elementAt(i+16);			
			strTemp = WI.getStrValue(strTemp,"1");
			dTemp = Double.parseDouble(strTemp);
			if(dTemp > 1){
				dTemp = dTemp * Double.parseDouble((String)vRetResult.elementAt(i+2));
				strTemp = CommonUtil.formatFloat(dTemp,true);
				strTemp += " " + (String)vRetResult.elementAt(i+18);
			} else {
				strTemp = "";
			}				
			%>			
      <td align="right" class="thinborder"><font size="1"> <label id="updateQTY<%=i%>" onDblClick="AjaxUpdateQty('updateQTY<%=i%>','<%=vRetResult.elementAt(i)%>');"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+2),false)%></label>&nbsp;<%=((String)vRetResult.elementAt(i+4))%><br>
      &nbsp;<%=WI.getStrValue(strTemp,"(",")" ,"")%></font></td>
      <td class="thinborder"> &nbsp;
	  <%
	  pstmt.setInt(1, Integer.parseInt((String)vRetResult.elementAt(i)));
	  rs = pstmt.executeQuery();
	  if(rs.next()) 
	  	strTemp = rs.getString(1);
	  else	
	  	strTemp = "0";
	  %>
	  <%=strTemp%>
	  </td>
      <td align="center" class="thinborder">
			 <%
			 	strTemp = "inv_entry_log.jsp?";
		//	 if(WI.fillTextValue("inventory_type").equals("2")){%>
		<!--
			<a href="./cons_entry_log_items.jsp?entry_type=<%=(String)vRetResult.elementAt(i+1)%>
							&entry_index=<%=(String)vRetResult.elementAt(i)%>
							&inventory_type=2
							&reference_index=<%=WI.fillTextValue("reference_index")%>
							&log_date=<%=WI.fillTextValue("inv_date")%>
							&item_index=<%=(String)vRetResult.elementAt(i+12)%>
							&inv_cat_index=<%=(String)vRetResult.elementAt(i+13)%> 
							&brand=<%=(String)vRetResult.elementAt(i+14)%>
							&main_form=<%=strTemp%>
							&conversion_qty=<%=(String)vRetResult.elementAt(i+16)%>"> 
        <img src="../../../images/update.gif" border="0"></a> 
			-->
			<%//} else {%>
			<a href="./inv_entry_log_items.jsp?entry_type=<%=(String)vRetResult.elementAt(i+1)%>
							&entry_index=<%=(String)vRetResult.elementAt(i)%>
							&inventory_type=<%=WI.fillTextValue("inventory_type")%>
							&reference_index=<%=strRefIndex%>
							&log_date=<%=WI.fillTextValue("inv_date")%>
							&item_index=<%=(String)vRetResult.elementAt(i+12)%>
							&inv_cat_index=<%=(String)vRetResult.elementAt(i+13)%>
							&brand=<%=(String)vRetResult.elementAt(i+14)%>
							&main_form=<%=strTemp%>							
							&conversion_qty=<%=(String)vRetResult.elementAt(i+16)%>"> 
        <img src="../../../images/update.gif" border="0"></a> 
			<%//}%>
			<a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'>
			<img src="../../../images/delete.gif" border="0"></a>			</td>
    </tr>
    <%}%>
    <tr> 
      <td height="25"  colspan="7"><div align="center"><font size="1">
			 <a href='javascript:PrintPg();'><img src="../../../images/print.gif" border="0"></a>
			 click to print list</font></div></td>
    </tr>
  </table>
  <%}//if results exists
  }%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="proceedClicked" value="">
	<input type="hidden" name="page_action">
	<input type="hidden" name="print_pg">
	<input type="hidden" name="inventory_type" value="<%=WI.fillTextValue("inventory_type")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>