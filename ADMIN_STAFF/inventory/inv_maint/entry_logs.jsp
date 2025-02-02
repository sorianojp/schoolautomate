<%@ page language="java" import="utility.*, inventory.*, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Inventory Entry Log</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	document.form_.print_pg.value = "";
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function Proceed(){
	document.form_.print_pg.value = "";
	document.form_.proceedClicked.value = "1";
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

function UpdateDonors() {
	var pgLoc = "../inv_log/donors.jsp?donor_type="+document.form_.type_index.value;
	var win=window.open(pgLoc,"UpdateDonor",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPg(){
	document.form_.print_pg.value = "1";
	this.SubmitOnce('form_');
}

</script>
</head>
<%
	if (WI.fillTextValue("print_pg").length() > 0){%>
		<jsp:forward page="./entry_logs_print.jsp" />
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
								"INVENTORY-INVENTORY LOG","entry_logs.jsp");
	
	Vector vRetResult = null;
	Vector vPODtls = null;
	Vector vPOItems = null;
	int i = 0;
	String strErrMsg = null;
	String strType = null;
	String strInvType = null;
	String strDonorType = null;
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit = null;
	int iSearchResult = 0;
	String strFinCol = null;
	double dTotalPrice = 0d;
	String strClass = null;
	String[] astrEntryType = {"DONATION","PURCHASE","EXISTING STOCKS"};	
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};

	strTemp = WI.fillTextValue("page_action");
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	String strSchCode = dbOP.getSchoolIndex();

	InventoryLog InvLog = new InventoryLog();
		// this here is for deleting an item	
	if(strSchCode.startsWith("UDMC"))
		InvLog.fixEntryLogs(dbOP);
	if(strTemp.length() > 0  && strTemp.equals("0")) {
		if(InvLog.operateOnInventoryEntryMain(dbOP, request, 0) != null){
				strErrMsg = "Item Deletion successful.";
				strPrepareToEdit = "0";
		}else{
				strErrMsg = InvLog.getErrMsg();
		}
	}
	if(WI.fillTextValue("proceedClicked").length() > 0){
		vRetResult = InvLog.getEntryLogs(dbOP, request);	
		if (vRetResult != null)
			iSearchResult = InvLog.getSearchCount();
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./entry_logs.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        INVENTORY LOG - INVENTORY ENTRY LOG PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="3"><font size="3" color="red"><strong><%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></font></td>
    </tr>
    <tr>
      <td height="25" width="4%">&nbsp;</td>
      <td width="20%">Date: </td>
      <td width="76%">
			<%strTemp = WI.fillTextValue("inv_date_fr");
      if (strTemp.length()==0)
      	strTemp = WI.getTodaysDate(1);%>
      <input name="inv_date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.inv_date_fr');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
			<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> to
        <%strTemp = WI.fillTextValue("inv_date_to");%> 
      <input name="inv_date_to" type="text" size="12" maxlength="12" class="textbox" value="<%=strTemp%>"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.inv_date_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
  </table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td>Inventory Type </td>
			<%
				strInvType = WI.getStrValue(WI.fillTextValue("inventory_type"),"0");
			%>
      <td valign="middle"><font size="1">
        <select name="inventory_type" onChange="Proceed();">
          <option value="0" selected>Non-Supplies/Equipment</option>
          <%if(strInvType.equals("1")){%>
          <option value="1" selected>Supplies</option>
          <%} else {%>
          <option value="1">Supplies</option>
          <%}if(strInvType.equals("2")){%>
          <option value="2" selected>Chemical</option>
          <%} else {%>
          <option value="2">Chemical</option>
          <%}if(strInvType.equals("3")){%>
          <option value="3" selected>Computer/Parts</option>
          <%} else {%>
          <option value="3">Computer/Parts</option>
          <%}%>
        </select>
      </font></td>
    </tr>
    <tr> 
      <td width="4%" height="30">&nbsp;</td>
      <td width="20%">Entry Type </td>
			<%
		  	strType = WI.fillTextValue("entry_type");
			%> 
      <td valign="middle">
			 <select name="entry_type" onChange="Proceed();">
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
	  <%if (strType.equals("1")){%>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Purchase Order No.</td>
		 <%if(WI.fillTextValue("po_num").length() > 0){
		 			strTemp = WI.fillTextValue("po_num");
		   }else{
					strTemp = "";
		   }		 
		  %> 			
      <td width="76%" height="30" valign="middle"> 
 		    <select name="po_num_con">
          <%=InvLog.constructGenericDropList(WI.fillTextValue("po_num_con"),astrDropListEqual,astrDropListValEqual)%>
        </select>
 		    <input name="po_num" type="text" class="textbox" size="20" maxlength="20" value="<%=strTemp%>">
 		  <a href="javascript:OpenSearchPO();"></a>      </td>
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
		</select></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Donor's Name</td>
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
        </select></td>
    </tr>
    <%}%>
    <tr>
      <td height="21">&nbsp;</td>
      <td height="21" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="21">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="21" valign="middle"><a href="javascript:Proceed();"><img src="../../../images/form_proceed.gif" border="0"></a> </td>
    </tr>
  </table>	
  <%if (vRetResult!=null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="12" class="thinborder"><div align="center"> 
          <p><strong><font size="2"> INVENTORY ENTRY LIST</font></strong></p>
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
        <select name="jumpto" onChange="Proceed();">
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
    <tr> 
      <td width="12%" height="25" align="center" class="thinborder"><font size="1"><strong>ENTRY 
      TYPE </strong></font></td>
      <td width="23%" class="thinborder" align="center"><font size="1"><strong>REFERENCE</strong></font></td>
      <td width="26%" class="thinborder" align="center"><font size="1"><strong>ITEM</strong></font></td>
      <td width="8%" class="thinborder" align="center"><font size="1"><strong>QTY</strong></font></div></td>
      <td width="13%" class="thinborder" align="center"><font size="1"><strong>LOGGED DATE </strong></font></td>
      <td width="18%" class="thinborder">&nbsp;</td>
    </tr>
    <%for (i=0; i< vRetResult.size(); i+=18) {%>
    <tr> 
      <td class="thinborder"><font size="1"> 
				<%=astrEntryType[Integer.parseInt((String)vRetResult.elementAt(i+1))]%>
      </font> </td>
      <td class="thinborder"><font size="1"> 
        <%if (vRetResult.elementAt(i+5) != null){%>
        <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%> 
        <input type="hidden" name="reference_index" value="<%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%>">
        <%} else {%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i+6),"PO Number : ","<br>","&nbsp;")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp;")%>         
        <input type="hidden" name="reference_index" value="<%=WI.getStrValue((String)vRetResult.elementAt(i+9),"&nbsp;")%>">
        <%}%>
      </font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+16),"Item Code: ","<br>","")%><%=((String)vRetResult.elementAt(i+3))%></font></td>
      <td align="right" class="thinborder"><font size="1"> <%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(i+2)),false)%>&nbsp;<%=((String)vRetResult.elementAt(i+4))%>&nbsp;</font></td>
      <td align="right" class="thinborder"><font size="1"><%=((String)vRetResult.elementAt(i+15))%></font></td>
      <td align="center" class="thinborder">
			<%strTemp = "../inv_maint/entry_logs.jsp?";
				if(WI.fillTextValue("inventory_type").equals("3")){
			%>
			<a href="../comp_log/comp_entry_log_items.jsp?entry_type=<%=(String)vRetResult.elementAt(i+1)%>
							&entry_index=<%=(String)vRetResult.elementAt(i)%>
							&inventory_type=<%=WI.fillTextValue("inventory_type")%>
							&reference_index=<%=WI.fillTextValue("reference_index")%>
							&log_date=<%=(String)vRetResult.elementAt(i+15)%>
							&item_index=<%=(String)vRetResult.elementAt(i+12)%>
							&inv_cat_index=<%=(String)vRetResult.elementAt(i+13)%>
							&brand=<%=(String)vRetResult.elementAt(i+14)%>
							&date_fr=<%=WI.fillTextValue("inv_date_fr")%>
							&date_to=<%=WI.fillTextValue("inv_date_to")%>
							&main_form=<%=strTemp%>
							&is_component=<%=(String)vRetResult.elementAt(i+10)%>
							&conversion_qty=<%=(String)vRetResult.elementAt(i+17)%>"> 							
        <img src="../../../images/update.gif" border="0"></a> 
			<%}else{%>			
			<a href="../inv_log/inv_entry_log_items.jsp?entry_type=<%=(String)vRetResult.elementAt(i+1)%>
							&entry_index=<%=(String)vRetResult.elementAt(i)%>
							&inventory_type=<%=WI.fillTextValue("inventory_type")%>
							&reference_index=<%=WI.fillTextValue("reference_index")%>
							&log_date=<%=(String)vRetResult.elementAt(i+15)%>
							&item_index=<%=(String)vRetResult.elementAt(i+12)%>
							&inv_cat_index=<%=(String)vRetResult.elementAt(i+13)%>
							&brand=<%=(String)vRetResult.elementAt(i+14)%>
							&date_fr=<%=WI.fillTextValue("inv_date_fr")%>
							&date_to=<%=WI.fillTextValue("inv_date_to")%>
							&main_form=<%=strTemp%>
							&conversion_qty=<%=(String)vRetResult.elementAt(i+17)%>"> 							
        <img src="../../../images/update.gif" border="0"></a> 
			<%}%>
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
  <%}//if results exists%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="proceedClicked" value="">
	<input type="hidden" name="page_action">
	<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>

