<%@ page language="java" import="utility.*, inventory.*, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);

	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements()) {
		strFormName = strToken.nextToken();	
	}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="javascript" src ="../../../jscript/common.js" ></script>
<script language="javascript" src ="../../../jscript/date-picker.js" ></script>
<script>
function ViewDetails(strInfoIndex)
{
	var pgLoc = "./view_property_dtls.jsp?info_index="+strInfoIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SearchNow()
{
	document.form_.focus_area.value = "2";
	document.form_.executeSearch.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function FocusArea() {
	var pageNo = <%=WI.getStrValue(WI.fillTextValue("focus_area"),"1")%>
	eval('document.form_.area'+pageNo+'.focus()');
}
function ReloadPage()
{
	document.form_.focus_area.value = "1";
	document.form_.executeSearch.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyPropNum(strPropNum)
{
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strPropNum;
	window.opener.focus();
	<%
	if(strFormName != null){%>
	window.opener.document.<%=strFormName%>.submit();
	<%}%>
	self.close();
}
<%}%>
function PrintPg(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
}
</script>

<%
	//authenticate user access level	
	if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./search_property_print.jsp" />
	<% return;}
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"INVENTORY-INVENTORY LOG","inv_borrow.jsp");
	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	int i = 0;
	int iTemp = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strQuery = "";
	String strInvType = null;
	String strCategory = null;
	String strClassification = null;

	int iSearchResult = 0;

	InventorySearch InvSearch = new InventorySearch();

	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName    = {"Property Number","Item Name","Log Date","College","Department"};
	String[] astrSortByVal     = {"prop_num","item_name","log_date","c_code","d_name"};

	if(WI.fillTextValue("executeSearch").compareTo("1") == 0){
	vRetResult = InvSearch.searchProperty(dbOP, request);
	if(vRetResult == null)
		strErrMsg = InvSearch.getErrMsg();
	else	
		iSearchResult = InvSearch.getSearchCount();
}
	
%>

<body bgcolor="#D2AE72" onLoad="javascript:FocusArea();">
<form action="./search_property.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY: PROPERTY SEARCH PAGE::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr> 
      <td height="25" colspan="4"><font size="3" color="red"><strong><%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></font></td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
	</table>
	  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<input type="hidden" name="item_type" value="0">
	  <%
				strInvType = "0";
		%> 
		<!--
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="20%">Item Type</td>
      <td colspan="4">
				<select name="item_type" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%if (strInvType.equals("0")){%>
          <option value="0" selected>Non-Supply</option>
          <%} else {%>
          <option value="0">Non-Supply</option>
          <%} if (strInvType.equals("1")) {%>
          <option value="1" selected>Supply</option>
          <%} else {%>
          <option value="1">Supply</option>
          <%} if (strInvType.equals("2")) {%>
          <option value="2" selected>Chemical</option>
          <%} else {%>
          <option value="2">Chemical</option>
          <%}%>
        </select></td>
    </tr>
		-->
    <tr> 
      <td height="25"><input type="text" name="area1" readonly="yes" size="2" style="background-color:#FFFFFF;border-width: 0px;"></td>
      <td>Item Category</td>
			<%
				strCategory = WI.fillTextValue("item_cat_index");
			%> 
      <td colspan="4">
			<select name="item_cat_index" onChange="ReloadPage();">
        <option value="">Select category</option>
        <%=dbOP.loadCombo("inv_cat_index","inv_category"," from inv_preload_category " +
		  					WI.getStrValue(strInvType," where is_supply_cat = ","","") + 
								"order by is_default desc, inv_category", strCategory, false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Item Brand </td>
			<%
				strTemp = WI.fillTextValue("brand");
			%>			
      <td colspan="4">			
        <select name="brand">
          <option value="">Select brand</option>
          <%=dbOP.loadCombo("BRAND_INDEX","BRAND_NAME"," from PUR_PRELOAD_BRAND " +
														" where inv_cat_index = " + WI.getStrValue(strCategory,"-1") +
														" order by BRAND_NAME asc", strTemp, false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Item Classification </td>
			<%
			strClassification = WI.fillTextValue("class_index");
			%>
      <td colspan="4">
        <select name="class_index" onChange="ReloadPage();">
          <option value="">Select Class</option>
          <%=dbOP.loadCombo("inv_class_index","classification"," from inv_preload_class " +
		  					"where inv_cat_index = " + WI.getStrValue(strCategory,"0") + 
							" order by classification", strClassification, false)%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Item</td>
			<%
		   strTemp = WI.fillTextValue("item_index");
	    %>			
      <td colspan="4"> 
			<input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="16" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		  onKeyUp = "AutoScrollList('form_.starts_with','form_.item_index',true);"> 
        <select name="item_index">
          <option value="">Select item</option>
          <%=dbOP.loadCombo("item_index","item_name"," from pur_preload_item " +
		  					"where inv_cat_index = " + WI.getStrValue(strCategory,"0") +
							WI.getStrValue(strClassification," and inv_class_index = ","","") +
							" order by item_name", strTemp, false)%>
        </select>
			</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Attributes</td>
      <td colspan="4">
	    <%if(WI.fillTextValue("expire").equals("1"))
	  		strTemp = "checked";
		else
			strTemp = "";%>
        <input type="checkbox" name="expire" value="1" <%=strTemp%>>		
        Expires 
	    <%if(WI.fillTextValue("transfer").equals("1"))
	  		strTemp = "checked";
		else
			strTemp = "";%>		
        <input type="checkbox" name="transfer" value="1" <%=strTemp%>>
        Transferrable 
	    <%if(WI.fillTextValue("borrow").equals("1"))
	  		strTemp = "checked";
		else
			strTemp = "";%>		
        <input type="checkbox" name="borrow" value="1" <%=strTemp%>>
        Borrowable 
	    <%if(WI.fillTextValue("consume").equals("1"))
	  		strTemp = "checked";
		else
			strTemp = "";%>		
        <input type="checkbox" name="consume" value="1" <%=strTemp%>>
        Consumable</td>
    </tr>
    <tr> 
      <td height="25" colspan="6"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td colspan="4"> <%strTemp = WI.fillTextValue("c_index");%> <select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department</td>
      <td colspan="4"><%strTemp2 = WI.fillTextValue("d_index");%> <select name="d_index">
          <% if(strTemp!=null && strTemp.compareTo("0") !=0){%>
          <option value="">All</option>
          <%} if (strTemp == null || strTemp.length() == 0 || strTemp.compareTo("0") == 0) strTemp = " and (c_index = 0 or c_index is null) ";
		else strTemp = " and c_index = " +  strTemp;%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + strTemp + " order by d_name asc",strTemp2, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Building</td>
      <td colspan="4"><%strTemp = WI.fillTextValue("bldg_index");%> <select name="bldg_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("BLDG_INDEX","BLDG_NAME"," from E_ROOM_BLDG where IS_DEL=0 order by BLDG_NAME", strTemp, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Room</td>
      <td colspan="4"><%strTemp2 = WI.fillTextValue("room_idx");%> <select name="room_idx">
          <option value="">N/A</option>
          <%if (strTemp.length()>0){
				strTemp = " from E_ROOM_DETAIL join E_ROOM_BLDG on (E_ROOM_DETAIL.LOCATION = E_ROOM_BLDG.BLDG_NAME) where BLDG_INDEX = "+strTemp+
				" and E_ROOM_DETAIL.is_del = 0 order by ROOM_NUMBER";%>
          <%=dbOP.loadCombo("ROOM_INDEX","ROOM_NUMBER", strTemp, strTemp2, false)%>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Loc Description</td>
      <td><select name="loc_con">
          <%=InvSearch.constructGenericDropList(WI.fillTextValue("loc_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td colspan="3"><input type="text" name="loc" value="<%=WI.fillTextValue("loc")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25" colspan="6"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Supplier</td>
      <td colspan="2"> <%strTemp = WI.fillTextValue("supp_index");%> <select name="supp_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("profile_index","supplier_code+' - '+supplier_name as name"," from pur_supplier_profile where is_del = 0 order by name", strTemp, false)%> </select> </td>
      <td width="8%">&nbsp;</td>
      <td width="30%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Property Number</td>
      <td width="10%"><select name="prop_con">
          <%=InvSearch.constructGenericDropList(WI.fillTextValue("prop_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td width="26%"><input type="text" name="prop" value="<%=WI.fillTextValue("prop")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Serial Number</td>
      <td><select name="serial_con">
          <%=InvSearch.constructGenericDropList(WI.fillTextValue("serial_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="serial" value="<%=WI.fillTextValue("serial")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Product Number</td>
      <td><select name="prod_con">
          <%=InvSearch.constructGenericDropList(WI.fillTextValue("prod_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="prod" value="<%=WI.fillTextValue("prod")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Addt'l Details</td>
      <td><select name="addtl_con">
          <%=InvSearch.constructGenericDropList(WI.fillTextValue("addtl_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="addtl" value="<%=WI.fillTextValue("addtl")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Status</td>
      <td colspan="2"><%strTemp = WI.fillTextValue("stat_index");%> <select name="stat_index">
          <option value="">Select category</option>
          <%=dbOP.loadCombo("inv_stat_index","inv_status"," from inv_preload_status order by inv_status", strTemp, false)%> </select></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="6"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Log Date</td>
      <td colspan="4"> <%strTemp = WI.fillTextValue("log_fr");%> <input name="log_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.log_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <%strTemp = WI.fillTextValue("log_to");%> <input name="log_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.log_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Warranty Date</td>
      <td colspan="4"> <%strTemp = WI.fillTextValue("warranty_fr");%> <input name="warranty_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.warranty_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <%strTemp = WI.fillTextValue("warranty_to");%> <input name="warranty_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.warranty_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Expire Date</td>
      <td colspan="4"> <%strTemp = WI.fillTextValue("expire_fr");%> <input name="expire_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.expire_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <%strTemp = WI.fillTextValue("expire_to");%> <input name="expire_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.expire_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>      </td>
    </tr>
  </table>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
    <td colspan="6">&nbsp;</td>
    </tr>
    
    <tr> 
      <td  width="3%" height="25">&nbsp;</td>
      <td width="20%">Sort by</td>
      <td width="24%">
	  <select name="sort_by1">
	 	<option value="">N/A</option>
          <%=InvSearch.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
      </select>
        <select name="sort_by1_con">
          <option value="asc">Ascending</option>
<% if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
      <td width="25%"><select name="sort_by2">
	 	<option value="">N/A</option>
          <%=InvSearch.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by2_con">
          <option value="asc">Ascending</option>
<% if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
      <td width="27%"><select name="sort_by3">
	 	<option value="">N/A</option>
          <%=InvSearch.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select> 
        <br/>
        <select name="sort_by3_con">
          <option value="asc">Ascending</option>
<% if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
      <td width="0%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:SearchNow();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult!=null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="7" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>PROPERTY NUMBERS </strong></font></div>      </td>
    </tr>
    <%if(WI.fillTextValue("opner_info").length() == 0) {%>
		<tr>
      <td height="25" colspan="7" align="right" class="thinborder">
			<a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a> 
			<font size="1">click to print list</font></td>
    </tr>
		<%}%>
    <tr>  
	  <td height="25" colspan="4" class="thinborder"><strong><font size="1"> TOTAL 
        ITEM(S) : <%=iSearchResult%> - Showing(<%=InvSearch.getDisplayRange()%>)</font></strong></td>
      <td height="25" colspan="3" align="right" class="thinborder"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/InvSearch.defSearchSize;
		if(iSearchResult % InvSearch.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>Jump To page: 
          <select name="jumpto" onChange="SearchNow();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%	}
			}
			%>
          </select>
          <%} else {%>&nbsp;<%}%></td>
    </tr>
    <tr> 
    <td width="10%" class="thinborder" align="center" height="25"><font size="1"><strong>PROPERTY NUMBER</strong></font></td>
      <td width="16%" class="thinborder" align="center"><font size="1"><strong>ITEM INFO</strong></font></td>
      <td width="16%" class="thinborder" align="center"><font size="1"><strong>ITEM DETAILS</strong></font></td>
      <td width="18%" class="thinborder" align="center"><font size="1"><strong>OWNERSHIP</strong></font></td>
      <td width="20%" class="thinborder" align="center"><font size="1"><strong>LOCATION</strong></font></td>
      <td width="14%" class="thinborder" align="center"><font size="1"><strong>OTHER DETAILS</strong></font></td>
      <td width="6%" class="thinborder" align="center"><font size="1"><strong>VIEW DETAILS</strong></font></td>
    </tr>
    <%for (i = 0; i<vRetResult.size(); i+=21){%>
    <tr> 
     <td class="thinborder"><font size="1">
     <%if(WI.fillTextValue("opner_info").length() > 0) {%>
		   <%if (WI.fillTextValue("propnum").length() > 0) {%>
			  <a href='javascript:CopyPropNum("<%=WI.fillTextValue("propnum")+","+(String)vRetResult.elementAt(i+6)%>");'>
			  <%=(String)vRetResult.elementAt(i+6)%></a>
		  <%}else{%>
			  <a href='javascript:CopyPropNum("<%=(String)vRetResult.elementAt(i+6)%>");'>
			  <%=(String)vRetResult.elementAt(i+6)%></a>
		  <%}%>	  
	  <%}else{%>
	  <%=(String)vRetResult.elementAt(i+6)%>
	  <%}%></font></td>
      <td class="thinborder"><font size="1">
      Item Name: <%=(String)vRetResult.elementAt(i+1)%><br>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"Category: ","<br>","")%><%=WI.getStrValue((String)vRetResult.elementAt(i+16),"Status: ","","")%>
      </font></td>
      <td height="25" class="thinborder"><font size="1">
      <%=WI.getStrValue((String)vRetResult.elementAt(i+15),"Supplier: ","<br>","")%>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+7),"Serial #: ","<br>","")%>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+8),"Product #: ","<br>","")%>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+9),"Details : ","","&nbsp;")%>
      </font></td>
      <td class="thinborder"><font size="1">
      <%=WI.getStrValue((String)vRetResult.elementAt(i+10),"College: ","<br>","")%>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+11),"Department: ","","&nbsp;")%>
      </font></td>
      <td class="thinborder"><font size="1">
      <%=WI.getStrValue((String)vRetResult.elementAt(i+12),"Building: ","<br>","")%>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+13),"Room: ","<br>","")%>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+14),"Description: ","","&nbsp;")%>
      </font></td>
      <td class="thinborder"><font size="1">
	  Log Date: <%=(String)vRetResult.elementAt(i+18)%><br>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+19),"Warranty until: ","<br>","")%>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+20),"Expires on: ","","")%>
      </font></td>
      <td align="center" class="thinborder"><a href='javascript:ViewDetails(<%=((String)vRetResult.elementAt(i))%>)'>
	  <img src="../../../images/view.gif" width="40" height="31" border="0"></a></td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3"><input type="text" name="area2" readonly="yes" size="2" style="background-color:#FFFFFF;border-width: 0px;"></td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
    <input type="hidden" name="executeSearch" value="<%=WI.fillTextValue("executeSearch")%>">
  	<input type="hidden" name="print_pg">
	<input type="hidden" name="propnum" value="<%=WI.fillTextValue("propnum")%>">

  <!-- Instruction -- set the opner_from_name to the parent window to copy stuff -->  
	<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">

	<input type="hidden" name="focus_area">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
