<%@ page language="java" import="utility.*, inventory.*, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";

boolean bolIsVMA = strSchCode.startsWith("VMA");
boolean bolIsUB  = strSchCode.startsWith("UB");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
	if(strAction == 1) 
		document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
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
function SetUnit(){
	if (document.form_.small_index)
		document.form_.small_u.value = "";		
//	else
//		document.form_.small_u.value = document.form_.small_index[document.form_.small_index.selectedIndex].text;			
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateBrand(){
	var loadPg = "./update_brand.jsp?opner_form_name=form_&opner_form_field=brand&inv_cat_index="+document.form_.inv_cat_index.value;
	var win=window.open(loadPg,"UpdateBrand",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function goBack(strMainForm) {
	location = strMainForm + "inv_date="+document.form_.log_date.value+
						"&entry_type="+document.form_.entry_type.value+
						"&inventory_type="+document.form_.inventory_type.value+
						"&inv_date_fr="+document.form_.date_fr.value+
						"&inv_date_to="+document.form_.date_to.value+
						"&proceedClicked=1";
}
</script></head>

<%
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
								"INVENTORY-INVENTORY LOG","inv_entry_log_items.jsp");
	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	Vector vEntryDetails = null;
	Vector vTemp = null;
	int iElemCount = 0;
	int i = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit = null;
	int iSearchResult = 0;
	String strFinCol = null;
	String[] astrEntryType = {"DONATION","PURCHASED","EXISTING STOCKS"};
	String[] astrInvType = {"NON-SUPPLIES","SUPPLIES","CHEMICALS"};
	String strEntryIndex = WI.fillTextValue("entry_index");
	String strEntryType = WI.fillTextValue("entry_type");	
	String strDispQty = null;
	String strAvailable = null;
//	boolean bolNonPO = false;
	double dTemp = 0d;
	InventoryLog InvLog = new InventoryLog();
	
//	if(WI.fillTextValue("non_po_index").length() > 0)
//		bolNonPO = true;
		
	strTemp = WI.fillTextValue("page_action");
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	
	vEntryDetails = InvLog.getEntryDetails(dbOP, request, strEntryIndex, strEntryType);
	//System.out.println("vEntryDetails " + vEntryDetails);
	if (vEntryDetails == null){
		strErrMsg = InvLog.getErrMsg();
	} else{	
		if(strTemp.length() > 0) {
		  if(InvLog.operateOnInventoryEntryDtl(dbOP, request, Integer.parseInt(strTemp)) != null ) 
			{
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
			}
		  else
			strErrMsg = InvLog.getErrMsg();
		}
	
		if(strPrepareToEdit.compareTo("1") == 0) {
			vEditInfo = InvLog.operateOnInventoryEntryDtl(dbOP, request, 3);
 		if(vEditInfo == null && strErrMsg == null ) 
				strErrMsg = InvLog.getErrMsg();
	}
	
		vRetResult = InvLog.operateOnInventoryEntryDtl(dbOP, request, 4);
	
		if(vRetResult == null){
			strErrMsg = InvLog.getErrMsg();
		}else{
			iSearchResult = InvLog.getSearchCount();
			iElemCount = InvLog.getElemCount();
		}
	}


boolean bolIsReload = false; // only if edit is called and page reloaded.. 
if(strSchCode.startsWith("DBTC")){//allow editing bldg /room info.. 
	if(WI.fillTextValue("is_reload").length() > 0) 
		bolIsReload = true;
}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./inv_entry_log_items.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY LOG - <%=astrEntryType[Integer.parseInt(WI.fillTextValue("inventory_type"))]%> ENTRY LOG - <%=astrEntryType[Integer.parseInt(strEntryType)]%>
          ::::</strong></font></div></td>
    </tr>	
    <tr> 
      <td height="33">
      <font size="1"><a href="javascript:goBack('<%=WI.fillTextValue("main_form")%>');"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></font>
      <font size="3" color="red"><strong><%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></font></td>
    </tr>
</table>
<%
if (vEntryDetails != null && vEntryDetails.size()>0){
if (strEntryType.equals("1")){%>
  <input name="price" type="hidden" value="<%=WI.getStrValue((String)vEntryDetails.elementAt(10),"0")%>">  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="5%" height="26" bgcolor="#C78D8D">&nbsp;</td>
      <td colspan="2" bgcolor="#C78D8D"><strong>ENDORSEMENT DETAILS<font color="#FFFFFF"></font></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td width="16%"><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></font></td>
      <td width="79%"><strong><%=WI.getStrValue((String)vEntryDetails.elementAt(7),"&nbsp;")%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1">Department</font></td>
      <td><strong><%=WI.getStrValue((String)vEntryDetails.elementAt(9),"&nbsp;")%></strong></td>
    </tr>
      <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1">Request Type</font></td>
      <td><strong>
      <%if (((String)vEntryDetails.elementAt(13)).equals("0")){%>New<%}else{%>Replacement<%}%>
      </strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1">Building</font></td>
      <td> 
      <%if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      	strTemp = WI.getStrValue((String)vEditInfo.elementAt(10),"");
      else
				strTemp = WI.fillTextValue("bldg_index");%>
      <select name="bldg_index" onChange="ReloadPage();">
                <option value="">N/A</option>
        <%=dbOP.loadCombo("BLDG_INDEX","BLDG_NAME"," from E_ROOM_BLDG where IS_DEL=0 order by BLDG_NAME", strTemp, false)%> </select></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td><font size="1">Room</font></td>
      <td>
       <%if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      	strTemp2 = WI.getStrValue((String)vEditInfo.elementAt(9),"");
      else
	     strTemp2 = WI.fillTextValue("room_idx");%>
      <select name="room_idx" onChange="ReloadPage();">
		<option value="">N/A</option>
		<%
		if (strTemp.length()>0){
		strTemp = " from E_ROOM_DETAIL join E_ROOM_BLDG on (E_ROOM_DETAIL.LOCATION = E_ROOM_BLDG.BLDG_NAME) where BLDG_INDEX = "+strTemp+
		" and E_ROOM_DETAIL.is_del = 0 order by ROOM_NUMBER";
		%>
		<%=dbOP.loadCombo("ROOM_INDEX","ROOM_NUMBER", strTemp, strTemp2, false)%><%}%> </select></td>
    </tr>
       <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1">Location Description</font></td>
      <td><%
      if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      	strTemp = WI.getStrValue((String)vEditInfo.elementAt(13),"");
      else
      strTemp = WI.fillTextValue("loc_desc");%>
      <input name="loc_desc" type="text" class="textbox" size="32" maxlength="32" value="<%=strTemp%>"></td>	  
    </tr>
	  
    <tr> 
      <td height="18" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%} else { %>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td colspan="2"><strong><u>LOCATION</u></strong></td>
      <td width="73%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="3%">&nbsp;</td>
      <td width="19%"><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></font></td>
      <td>
      <%
      if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      strTemp = WI.getStrValue((String)vEditInfo.elementAt(7),"0");
      else
      strTemp = WI.fillTextValue("c_index");%>
      <select name="c_index" onChange="document.form_.is_reload.value='1';ReloadPage();">
                <option value="0">N/A</option>
                <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select>

      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><font size="1">Department</font></td>
      <td>
		<%if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
	    	  strTemp2 = WI.getStrValue((String)vEditInfo.elementAt(8),"");
		  else
		      strTemp2 = WI.fillTextValue("d_index");%>
       <select name="d_index">
		<% if(strTemp!=null && strTemp.compareTo("0") !=0){%>
                <option value="">All</option>
	<%}  
   if (strTemp == null || strTemp.length() == 0 || strTemp.compareTo("0") == 0) strTemp = " and (c_index = 0 or c_index is null) ";
	  else strTemp = " and c_index = " +  strTemp;
%><%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + strTemp + " order by d_name asc",strTemp2, false)%> </select>
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><font size="1">Building</font></td>
      <td>
	<%if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      	strTemp = WI.getStrValue((String)vEditInfo.elementAt(10),"");
      else
		strTemp = WI.fillTextValue("bldg_index");%>
      <select name="bldg_index" onChange="document.form_.is_reload.value='1';ReloadPage();">
                <option value="">N/A</option>
        <%=dbOP.loadCombo("BLDG_INDEX","BLDG_NAME"," from E_ROOM_BLDG where IS_DEL=0 order by BLDG_NAME", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><font size="1">Room</font></td>
      <td>
      <%if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      	strTemp2 = WI.getStrValue((String)vEditInfo.elementAt(9),"");
      else
	     strTemp2 = WI.fillTextValue("room_idx");%>
      <select name="room_idx" onChange="document.form_.is_reload.value='1';ReloadPage();">
                <option value="">N/A</option>
				<%
				if (strTemp.length()>0){
				strTemp = " from E_ROOM_DETAIL join E_ROOM_BLDG on (E_ROOM_DETAIL.LOCATION = E_ROOM_BLDG.BLDG_NAME) where BLDG_INDEX = "+strTemp+
				" and E_ROOM_DETAIL.is_del = 0 order by ROOM_NUMBER";
				%>
        <%=dbOP.loadCombo("ROOM_INDEX","ROOM_NUMBER", strTemp, strTemp2, false)%><%}%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><font size="1">Location Description</font></td>
      <td>
      <%
      if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      	strTemp = WI.getStrValue((String)vEditInfo.elementAt(13),"");
      else
	    strTemp = WI.fillTextValue("loc_desc");%>
      <input name="loc_desc" type="text" class="textbox" size="32" 
			maxlength="32" value="<%=strTemp%>">
      </td>
    </tr>
    <tr>
    <td colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <%}%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="5%" height="26">&nbsp;</td>
      <td width="25%">Item Name :<strong><%=(String)vEntryDetails.elementAt(2)%></strong></td>
			<%
				strTemp = (String)vEntryDetails.elementAt(3);
				strTemp = ConversionTable.replaceString(strTemp, ",","");
			%>
      <td width="26%">Quantity : <strong><%=strTemp%></strong> <input type="hidden" name="total_quantity" value="<%=strTemp%>">      </td>
      <td width="44%">Unit : <strong><%=(String)vEntryDetails.elementAt(5)%></strong> <input type="hidden" name="unit_index" value="<%=(String)vEntryDetails.elementAt(4)%>">      </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="3">Particulars/Item Description : <strong>
      <%if (strEntryType.equals("1")){
				strTemp = (String)vEntryDetails.elementAt(12);
				strTemp2 = "class=textbox_noborder readonly";
		  } else {
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = WI.getStrValue((String)vEditInfo.elementAt(28),"");
				}else{
					strTemp = WI.fillTextValue("item_desc");
				}
				
				strTemp2 = "class=textbox";
		  }
		%>      
		<input name="item_desc" type="text" size="32" maxlength="32" <%=strTemp2%> value="<%=strTemp%>"
		onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'> 
        </strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="3">Current inventory on hand for this ITEM for the Specified
        Location: <strong> 
        <%vTemp = InvLog.operateOnGetItems(dbOP, request);
        if (vTemp != null && vTemp.size() == 1){%>
        <%=(String)vTemp.elementAt(0)%> 
        <%}else if(vTemp != null && vTemp.size() > 1){%>
        &nbsp; 
        <%}else{%>
        0 
        <%}%>
        </strong> </td>
    </tr>
    <%if (vTemp != null && vTemp.size() > 1){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="3"> <table bgcolor="#DADADA" width="50%" class="thinborder">
          <tr> 
            <td width="50%" class="thinborder"><font size="1"><strong>QUANTITY</strong></font></td>
            <td width="50%" class="thinborder"><font size="1"><strong>UNIT MEASURE</strong></font></td>
          </tr>
          <%for (i=0; i< vTemp.size(); i+=3){%>
          <tr> 
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vTemp.elementAt(i),"")%> </font></td>
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vTemp.elementAt(i+1),"")%></font></td>
          </tr>
          <%}%>
        </table></td>
    </tr>
    <%}%>
    <tr> 
      <td height="18" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%if(!WI.fillTextValue("inventory_type").equals("0")){%>
		<%
		if(!WI.fillTextValue("conversion_qty").equals("1.0")){%>		
    <tr> 
      <td height="25" width="4%">&nbsp;</td>
      <td width="19%"><strong>Item Unit</strong></td>
      <td> <%if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      	strTemp = WI.getStrValue((String)vEditInfo.elementAt(21),"");
      else
	    strTemp = WI.fillTextValue("small_index");
	    %> <select name="small_index"  onchange="javascript:SetUnit()">
          <option value="">Select unit</option>
          <%//=dbOP.loadCombo("unit_index","unit_name"," from pur_preload_unit order by unit_name", strTemp, false)%> 
          <%=dbOP.loadCombo("UNIT_INDEX","UNIT_NAME"," from PUR_PRELOAD_UNIT " +
		  					" where exists(select * from inv_reg_item where item_index = " + 
								WI.getStrValue((String)vEntryDetails.elementAt(1),"0") + 
								WI.getStrValue(WI.fillTextValue("brand")," and brand_index = ", ""," and brand_index is null") +
								" and (UNIT_INDEX = small_unit or unit_index = big_unit))" + 
								" order by UNIT_NAME asc ", strTemp, false)%>
		  </select></td>
    </tr>
		<%}else{%>
		<input type="hidden" name="small_index" value="<%=(String)vEntryDetails.elementAt(4)%>">
		<%}%>
    <tr> 
      <td>&nbsp;</td>
      <td><strong>Quantity</strong></td>
      <td> <% 
	  if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      	strTemp = WI.getStrValue((String)vEditInfo.elementAt(22),"");
      else
		strTemp = WI.fillTextValue("smallq");%> 
        <input name="smallq" type="text" class="textbox" value="<%=strTemp%>" size="12" maxlength="12"
	   onKeyUp= 'AllowOnlyFloat("form_","smallq")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyFloat("form_","smallq");style.backgroundColor="white"'> 
        <input type="text" name="small_u" class="textbox_noborder" readonly="readonly" style="font-size:9px"> 
        <script language="javascript">
       SetUnit();
       </script> </td>
    </tr>
    <%}// if inventory type != 0(not equipment/non-supplies)%>
		<%if(WI.fillTextValue("inventory_type").equals("0")){%>
	  <tr> 
      <td height="25">&nbsp;</td>
      <td ><strong>Property #</strong></td>
      <td width="77%"> <%	  
      if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      	strTemp = WI.getStrValue((String)vEditInfo.elementAt(14),"");
      else
      	strTemp = WI.fillTextValue("prop_no");%> 
        <input name="prop_no" type="text" class="textbox" size="32" maxlength="32" value="<%=strTemp%>">      
		
		<%if(bolIsUB){%><input type="checkbox" name="auto_gen" value="1">Auto-generate property number		<%}%></td>
    </tr>		
      <tr> 
      <td height="25">&nbsp;</td>
      <td><strong>Serial #</strong></td>
      <td> <%
   	  if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      	strTemp = WI.getStrValue((String)vEditInfo.elementAt(15),"");
      else
      strTemp = WI.fillTextValue("serial_no");%> 
        <input name="serial_no" type="text" class="textbox" size="32" maxlength="32" value="<%=strTemp%>"> 
        <font size="1"> &nbsp;(if Applicable)</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><strong>Product #</strong></td>
      <td> <%
      if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      	strTemp = WI.getStrValue((String)vEditInfo.elementAt(16),"");
      else
      strTemp = WI.fillTextValue("prod_no");%> 
        <input name="prod_no" type="text" class="textbox" size="32" maxlength="32" value="<%=strTemp%>"> 
        <font size="1"> &nbsp;(if Applicable)</font></td>
    </tr>
		<%}// end if inventory type != 1 %>
		
    <tr>
      <td height="24">&nbsp;</td>
	  <%
	  if(!bolIsVMA)
	  	strTemp = "Additional Details";
	else
		strTemp = "Remarks";
	  %>
      <td><strong><%=strTemp%></strong></td>
      <td><%
   	  if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      	strTemp = WI.getStrValue((String)vEditInfo.elementAt(32),"");
      else
      strTemp = WI.fillTextValue("addtl_dtls");%>
        <input name="addtl_dtls" type="text" class="textbox" size="32" maxlength="32" value="<%=strTemp%>"
			 onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'>
        <font size="1"> &nbsp;(if Applicable)</font></td>
    </tr>

    <%if (strEntryType.equals("0") || strEntryType.equals("2")){%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><strong>Price </strong></td>
      <td> <%
   	  if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      	strTemp = WI.getStrValue((String)vEditInfo.elementAt(4),"");
      else
	      strTemp = WI.fillTextValue("price");%> 
        <input name="price" type="text" class="textbox"  onKeyUp= 'AllowOnlyFloat("form_","price")' onFocus="style.backgroundColor='#D3EBFF'"
	   onblur='AllowOnlyFloat("form_","price");style.backgroundColor="white"' value="<%=strTemp%>">
        <font size="1">per unit </font></td>
    </tr>
    <%}%></td>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><strong>Status</strong></td>
      <td> <%
   	  if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload){
      	strTemp = WI.getStrValue((String)vEditInfo.elementAt(17),"");
				strTemp2 = " where inv_stat_index = " + strTemp;
			}else{
				strTemp = WI.fillTextValue("stat_index");
				strTemp2 = " where is_default = 0 ";
			}
	  %> 
	  
		<select name="stat_index">
	      <%if(!strPrepareToEdit.equals("1")) {%>
	      <option value="">Select status</option>
		  <%}%>
          <%=dbOP.loadCombo("inv_stat_index","inv_status"," from inv_preload_status " + strTemp2 + 
														" order by inv_status", strTemp, false)%> 
		</select> 
		<%if(!strPrepareToEdit.equals("1")) {%>
		<font size="1"> 
		<!--table, indexname, colname, labelname, tablelist,strIndexes, strExtraTableCond, strExtraCond,strFormField-->
		<a href='javascript:viewList("inv_preload_status","inv_stat_index","inv_status","INVENTORY STATUS",
						"inv_item, inv_stat_update_log","inv_stat_index, status_fr",
						"and inv_item.is_valid = 1, and inv_stat_update_log.is_valid = 1","is_default = 0","stat_index")'> 
		  <img src="../../../images/update.gif" border="0">		</a>click to update STATUS list</font> 
		<%}%>	  </td>
    </tr>
		<%if(WI.fillTextValue("inventory_type").equals("2")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td><strong>Expire Date</strong></td>
      <td><%
   	  if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      	strTemp = WI.getStrValue((String)vEditInfo.elementAt(33),"");
      else
      	strTemp = WI.fillTextValue("exp_date");%>
        <input name="exp_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.exp_date');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
		<%}else{%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><strong>Warranty Until </strong></td>
      <td><%
   	  if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      	strTemp = WI.getStrValue((String)vEditInfo.elementAt(20),"");
      else
	      strTemp = WI.fillTextValue("warranty");%> <input name="warranty" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.warranty');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>      </td>
    </tr>
		<%if(WI.fillTextValue("inventory_type").equals("0") ||
		 		 WI.fillTextValue("inventory_type").equals("3")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td><strong>Date Acquired </strong></td>
      <td>
			<%
   	  if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      	strTemp = WI.getStrValue((String)vEditInfo.elementAt(36),"");
      else
      	strTemp = WI.fillTextValue("date_acquired");
			if(strTemp == null)
				strTemp = WI.fillTextValue("log_date");
			%>
        <input name="date_acquired" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.date_acquired');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>

		<%}%>
		<%}%>
		<%
if(bolIsVMA){
%>
	<tr>
        <td height="25">&nbsp;</td>
        <td><strong>Life Span</strong></td>
		<%

		String[] astrLifeSpanUnit = {"Day(s)","Month(s)", "Year(s)"};
		
		strTemp = WI.fillTextValue("life_span");
   	  	if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      		strTemp = WI.getStrValue((String)vEditInfo.elementAt(37));  
		%>
        <td>
		<input name="life_span" type="text" size="3" maxlength="3" value="<%=strTemp%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp;
		<select name="life_span_unit">
		<%
		strTemp = WI.fillTextValue("life_span_unit");
		if (vEditInfo!=null && vEditInfo.size()>0 && !bolIsReload)
      		strTemp = WI.getStrValue((String)vEditInfo.elementAt(38));  
		for(i = 0; i < astrLifeSpanUnit.length; ++i){
		if(strTemp.equals(Integer.toString(i)))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%>
		<option value="<%=i%>" <%=strErrMsg%>><%=astrLifeSpanUnit[i]%></option>
		<%}%>
		</select>
		</td>
    </tr>

    <!--<tr>
        <td height="25">&nbsp;</td>
        <td><strong>Life Span</strong></td>
		<%
		strTemp = WI.fillTextValue("life_span");
		%>
        <td>
		<input name="life_span" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.life_span');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
		</td>
    </tr>-->
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%">
        <font size="1">
     <%if(!strPrepareToEdit.equals("1")  || vEditInfo == null || vEditInfo.size() == 0) {%> 
		 <a href='javascript:PageAction(1,"");'>
		 <img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to add entry 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit entry <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to cancel 
        <%}%></font>
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%if (vRetResult!=null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="8" align="center" class="thinborder"><strong><font size="2"> INVENTORY ENTRY LIST FOR THE DATE (<%=WI.fillTextValue("log_date")%>)</font></strong></td>
    </tr>
		<%if(WI.fillTextValue("inventory_type").equals("1"))
				strTemp = "2";
			else
				strTemp = "3";
		%>

    <tr> 
      <td  height="25" colspan="<%=strTemp%>" class="thinborderBOTTOMLEFT" align="left"><font size="1"><strong>TOTAL 
        ITEMS: &nbsp;&nbsp;<%=iSearchResult%></strong></font></td>
      <td colspan="4" align="right" class="thinborderBOTTOM"><%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/InvLog.defSearchSize;
		if(iSearchResult % InvLog.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1){%> <select name="jumpto" onChange="ReloadPage();" style="font-size:11px">
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
        </select> <%} else {%> &nbsp; <%} //if no pages %></td>
    </tr>
    <tr valign="top"> 
      
      <td width="9%" align="center" class="thinborder"><font size="1"><strong>QUANTITY</strong></font></td>
      <td width="19%" align="center" class="thinborder"><font size="1"><strong>LOCATION / OWNERSHIP </strong></font></td>
			<%if(WI.fillTextValue("inventory_type").equals("0")){%>
      <td width="17%" align="center" class="thinborder"><font size="1"><strong>PROPERTY 
        DETAILS</strong></font></td>
			 <%}%>
      <td width="12%" align="center" class="thinborder"><font size="1"><strong>STATUS</strong></font></td>
      <td width="16%" align="center" class="thinborder"><font size="1"><strong>SUPPLIER 
        / DONOR</strong></font></td>
			<%if(WI.fillTextValue("inventory_type").equals("2"))
					strTemp = "EXPIRY DATE";
				else
					strTemp = "WARRANTY UNTIL / DATE ACQUIRED";
			%>
      <td width="12%" align="center" class="thinborder"><font size="1"><strong><%=strTemp%></strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>OPTION</strong></font></td>
    </tr>
    <% 
	for (i =0; i<vRetResult.size(); i+=iElemCount){%>
    <tr>       
			<%
				strTemp	= (String)vRetResult.elementAt(i+30);
				if(strTemp != null && strTemp.length() > 1){
					strTemp2 = WI.getStrValue(WI.fillTextValue("conversion_qty"),"1");
					dTemp = Double.parseDouble(strTemp2);
					dTemp = dTemp * Double.parseDouble((String)vRetResult.elementAt(i+22));
					strTemp2 = CommonUtil.formatFloat(dTemp,true) ;
					strTemp2 += " " + strTemp;
				}else{
					strTemp2 = "";
				}				
				
				strTemp = (String)vRetResult.elementAt(i+22);				
				strTemp += " " + (String)vRetResult.elementAt(i+29);				
			%>						
      <td valign="top" class="thinborder"><font size="1"><%=strTemp%> <%=WI.getStrValue(strTemp2,"(",")" ,"")%></font></td>
      <td valign="top" class="thinborder">
	      <font size="1"> 
        <%=WI.getStrValue((String)vRetResult.elementAt(i+12),"Building: ","<br>","")%> 
	      <%=WI.getStrValue((String)vRetResult.elementAt(i+11),"Room: ","<br>","")%> 
      <%=WI.getStrValue((String)vRetResult.elementAt(i+13),"Location: ","","&nbsp;")%>	      </font></td>
			<%if(WI.fillTextValue("inventory_type").equals("0")){%>
      <td valign="top" class="thinborder">
	  	  <font size="1">
			<%=WI.getStrValue((String)vRetResult.elementAt(i+14),"Property #: ","<br>","")%>
			<%=WI.getStrValue((String)vRetResult.elementAt(i+15),"Serial   #: ","<br>","")%>
			<%=WI.getStrValue((String)vRetResult.elementAt(i+16),"Product  #: ","<br>","")%>&nbsp;	      </font></td>
			<%}%>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+18)%></font></td>
      <td valign="top" class="thinborder"><font size="1"> 
        <%if (strEntryType.equals("1")){%>
        <%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%> 
        <%}else if (strEntryType.equals("0")){%>
        <%=WI.getStrValue((String)vRetResult.elementAt(i+23),"&nbsp;")%> 
        <%}else{%>
        &nbsp; 
        <%}%>
      </font></td>
			<%
				strTemp = "";
				if(WI.fillTextValue("inventory_type").equals("2")){
					strTemp = (String)vRetResult.elementAt(i+33);
				}else{
					strTemp = WI.getStrValue((String)vRetResult.elementAt(i+20),"Warranty<br>","","");
					if(strTemp.length() > 0)
						strTemp += "<br>";
					strTemp += WI.getStrValue((String)vRetResult.elementAt(i+36),"Date Acquired<br>","","");
				}
			%>
      <td valign="top" class="thinborder"><font size="1"><%=WI.getStrValue(strTemp,"&nbsp;")%></font></td>
      <td align="center" class="thinborder"> 
			<%
				strDispQty = WI.getStrValue((String)vRetResult.elementAt(i+34));
				strAvailable = WI.getStrValue((String)vRetResult.elementAt(i+35));
			%>
			 <%
			 if(!((String)vRetResult.elementAt(i+31)).equals("1") && 
					 (strDispQty).equals(strAvailable)){%>
			   <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
         <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
			 <%}else{%>
			 	N/a
			 <%}%>			
			</td>
    </tr>
    <%}%>
  </table>
  <%}
  }%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="print_pg">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">	
	<input type="hidden" name="entry_type" value="<%=WI.fillTextValue("entry_type")%>">
	<input type="hidden" name="entry_index" value="<%=WI.fillTextValue("entry_index")%>">   	
	<input type="hidden" name="item_index" value="<%=WI.fillTextValue("item_index")%>">   	
	<input type="hidden" name="inventory_type" value="<%=WI.fillTextValue("inventory_type")%>">
	<input type="hidden" name="reference_index" value="<%=WI.fillTextValue("reference_index")%>">
	<input type="hidden" name="log_date" value="<%=WI.fillTextValue("log_date")%>">
	<input type="hidden" name="inv_cat_index" value="<%=WI.fillTextValue("inv_cat_index")%>">	
	<input type="hidden" name="brand" value="<%=WI.fillTextValue("brand")%>">
	<input type="hidden" name="conversion_qty" value="<%=WI.fillTextValue("conversion_qty")%>">
	
	<input type="hidden" name="main_form" value="<%=WI.fillTextValue("main_form")%>">	
	<input type="hidden" name="date_fr" value="<%=WI.fillTextValue("date_fr")%>">	
	<input type="hidden" name="date_to" value="<%=WI.fillTextValue("date_to")%>">	
	
	<input type="hidden" name="is_reload" value="">
	<!--
	<input type="hidden" name="non_po_index" value="<%=WI.fillTextValue("non_po_index")%>">
	-->
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>