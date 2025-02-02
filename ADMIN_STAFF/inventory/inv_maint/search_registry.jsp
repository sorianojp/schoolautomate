<%@ page language="java" import="utility.*, inventory.InventorySearch, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);

	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements()) {
		strFormName = strToken.nextToken();	
	}

%><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>
function SearchNow()
{
	document.form_.executeSearch.value = "1";
	document.form_.print_pg.value = "";
	document.form_.focus_area.value = "2";
	this.SubmitOnce('form_');
}

function ReloadPage()
{
	document.form_.executeSearch.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function PrintPg(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
}
<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyItemCode(strItemCode)
{
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strItemCode;
	window.opener.focus();
	<%
	if(strFormName != null){%>
	window.opener.document.<%=strFormName%>.submit();
	<%}%>
	self.close();
}
<%}%>

function PageLoad(){
	var pageNo = "";
	pageNo = <%=WI.getStrValue(WI.fillTextValue("focus_area"),"1")%>
	if(eval('document.form_.page_no'+pageNo))
		eval('document.form_.page_no'+pageNo+'.focus()');
	else
		document.form_.page_no.focus();
 	//document.form_.req_no.focus();
}
</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
//add security here.
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./search_registry_print.jsp" />
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
								"Admin/staff-INVENTORY-INV_MAINT- View Inventory","search_registry.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}

	Vector vRetResult = null;
	int iTemp = 0;
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName   = {"Inventory Type", "Category", "Classification", "Item Code", 
															 "Item Name", "Brand name"};
	String[] astrSortByVal = {"pur_preload_item.is_supply", "inv_category","classification","item_code", 
														"item_name", "brand_name"};
	String strInvType  = null;
	String strCategory = null;
	String strClassification = null;

	InventorySearch InvSearch = new InventorySearch();
	if (WI.fillTextValue("executeSearch").equals("1")){
		vRetResult = InvSearch.searchItemCode(dbOP,request);
	}
	if (vRetResult!= null && vRetResult.size() > 0){
		iSearchResult = InvSearch.getSearchCount();
	}else{
		strErrMsg = InvSearch.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" onLoad="javascript:PageLoad();">
<form name="form_" action="search_registry.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY MAINTENANCE - VIEW INVENTORY PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3"><font size="3" color="red"><strong>&nbsp;<%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></font></td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="20%">Item Type</td>
			<%
			strInvType = WI.fillTextValue("item_type");
			%>
      <td colspan="2">
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
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="20%">Item Category</td>
			<%
				strCategory = WI.fillTextValue("item_cat_index");
			%> 
      <td width="80%">
			<select name="item_cat_index" onChange="ReloadPage();">
        <option value="">Select category</option>
        <%=dbOP.loadCombo("inv_cat_index","inv_category"," from inv_preload_category " +
		  					WI.getStrValue(strInvType," where is_supply_cat = ","","") + 
								"order by is_default desc, inv_category", strCategory, false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Item Classification </td>
			<%
			strClassification = WI.fillTextValue("class_index");
			%>
      <td colspan="3">
        <select name="class_index" onChange="ReloadPage();">
          <option value="">Select Class</option>
          <%=dbOP.loadCombo("inv_class_index","classification"," from inv_preload_class " +
		  					"where inv_cat_index = " + WI.getStrValue(strCategory,"0") + 
							" order by classification", strClassification, false)%>
        </select></td>
    </tr>    
    <tr>
      <td height="25">&nbsp;</td>
      <td>Item Brand </td>
			<%
				strTemp = WI.fillTextValue("brand");
			%>			
      <td>			
        <select name="brand">
          <option value="">Select brand</option>
          <%=dbOP.loadCombo("BRAND_INDEX","BRAND_NAME"," from PUR_PRELOAD_BRAND " +
														" where inv_cat_index = " + WI.getStrValue(strCategory,"-1") +
														" order by BRAND_NAME asc", strTemp, false)%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Item</td>
			<%
		   strTemp = WI.fillTextValue("item_index");
	    %>			
      <td> 
			<input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="16" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		  onKeyUp = "AutoScrollList('form_.starts_with','form_.item_index',true);"> 
        <select name="item_index">
          <option value="">Select item</option>
          <%=dbOP.loadCombo("item_index","item_name"," from pur_preload_item " +
		  					"where inv_cat_index = " + WI.getStrValue(strCategory,"0") +
							WI.getStrValue(strClassification," and inv_class_index = ","","") +
							" order by item_name", strTemp, false)%>
        </select>			</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Attributes</td>
      <td>
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
      <td width="3%" height="25">&nbsp;</td>
      <td>Item Code </td>
      <td><select name="item_code_con">
        <%=InvSearch.constructGenericDropList(WI.fillTextValue("item_code_con"),astrDropListEqual,astrDropListValEqual)%>
      </select>
        <input type="text" name="item_code" value="<%=WI.fillTextValue("item_code")%>" class="textbox"
			 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    
    <tr> 
      <td height="18" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"><strong>SORT</strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"> <select name="sort_by1">
          <option value="" selected>N/A</option>
          <%
		  strTemp = WI.fillTextValue("sort_by1");
		  for (int i = 0; i<6 ; i++){
		  %>
			  <%if(strTemp.equals(astrSortByVal[i])){%>
				  <option value="<%=astrSortByVal[i]%>" selected><%=astrSortByName[i]%></option>
			  <%} else {%>
				  <option value="<%=astrSortByVal[i]%>"><%=astrSortByName[i]%></option>
			  <%}%>
          <%}%>
        </select>        
				<select name="sort_by1_con">
          <%if (WI.fillTextValue("sort_by1_con").equals("asc")){%>
          <option value="asc" selected>Ascending</option>
          <%}else{%>
          <option value="asc">Ascending</option>
          <%}%>
          <%if (WI.fillTextValue("sort_by1_con").equals("desc")){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"><select name="sort_by2">
          <option value="" selected>N/A</option>
          <%
		  strTemp = WI.fillTextValue("sort_by2");
		  for (int i = 0 ; i<6 ; i++){
		  %>
          <%if(strTemp.equals(astrSortByVal[i])){%>
          <option value="<%=astrSortByVal[i]%>" selected><%=astrSortByName[i]%></option>
          <%} else {%>
          <option value="<%=astrSortByVal[i]%>"><%=astrSortByName[i]%></option>
          <%}%>
          <%}%>
        </select>        
				<select name="sort_by2_con">        
          <%if (WI.fillTextValue("sort_by2_con").equals("asc")){%>
          <option value="asc" selected>Ascending</option>
          <%}else{%>
          <option value="asc">Ascending</option>
          <%}%>
          <%if (WI.fillTextValue("sort_by2_con").equals("desc")){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">
			<select name="sort_by3">
          <option value="" selected>N/A</option>
          <%
		  strTemp = WI.fillTextValue("sort_by3");
		  for (int i = 0 ; i<6 ; i++){
		  %>
          <%if(strTemp.equals(astrSortByVal[i])){%>
          <option value="<%=astrSortByVal[i]%>" selected><%=astrSortByName[i]%></option>
          <%} else {%>
          <option value="<%=astrSortByVal[i]%>"><%=astrSortByName[i]%></option>
          <%}%>
          <%}%>
       </select>        
			 <select name="sort_by3_con">       
          <%if (WI.fillTextValue("sort_by3_con").equals("asc")){%>
          <option value="asc" selected>Ascending</option>
          <%}else{%>
          <option value="asc">Ascending</option>
          <%}%>
          <%if (WI.fillTextValue("sort_by3_con").equals("desc")){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:SearchNow();"><img src="../../../images/form_proceed.gif"  border="0">
      </a><input type="text" name="page_no" readonly size="1" 
			style="background-color:#FFFFFF;border-width: 0px;">
			</td>
    </tr>
  <%if (vRetResult != null && vRetResult.size() > 0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right">			
			<%if(WI.fillTextValue("opner_info").length() == 0) {%>
			<a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print list</font>
			<%}%></div>
			</td>
    </tr>
  <%}%>
  </table>
  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="20" colspan="5" align="center" class="thinborder"> <strong><font size="2">INVENTORY LIST</font></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="3" class="thinborderBOTTOMLEFT"><font size="1"><strong>TOTAL 
          ITEMS: &nbsp;&nbsp;<%=iSearchResult%></strong></font> <strong><font size="1">- Showing(<%=InvSearch.getDisplayRange()%>)</font></strong></td>
      <td height="25" colspan="2" align="right" class="thinborderBOTTOM"><%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/InvSearch.defSearchSize;
		if(iSearchResult % InvSearch.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>
Jump To page:
  <select name="jumpto" onChange="SearchNow();">
    <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
    <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
    <%}else{%>
    <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
    <%	}
			}
			%>
  </select>
  <%} else {%>
&nbsp;
<%}%></td>
    </tr>
    <tr>
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>ITEM CODE </strong></font></td> 
      <td width="32%" height="22" align="center" class="thinborder"><font size="1"><strong>ITEM</strong></font></td>
      <td width="18%" align="center" class="thinborder"><font size="1"><strong>CATEGORY</strong></font></td>
      <td width="18%" align="center" class="thinborder"><font size="1"><strong>CLASS</strong></font></td>
      <td width="18%" align="center" class="thinborder"><font size="1"><strong>BRAND</strong></font></td>
    </tr>
    <%if (vRetResult != null && vRetResult.size() > 0){
		for (int i = 0; i < vRetResult.size(); i+=6){
	%>
    <tr>
      <td class="thinborder"><font size="1">
        <%if(WI.fillTextValue("opner_info").length() > 0) {%>
        <a href='javascript:CopyItemCode("<%=(String)vRetResult.elementAt(i+1)%>");'> <%=(String)vRetResult.elementAt(i+1)%></a>
        <%}else{%>
        <%=(String)vRetResult.elementAt(i+1)%>
        <%}%>
      </font></td> 
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i + 2),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i + 3),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i + 4),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i + 5),"&nbsp;")%></td>
    </tr>
    <%}
	}%>
  </table>
  <%}// if (vRetResult != null && vRetResult.size() > 0)
     %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3"><div align="center">
        <input type="text" name="page_no2" readonly size="1" 
			style="background-color:#FFFFFF;border-width: 0px;">
      </div></td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="executeSearch" value="<%=WI.fillTextValue("executeSearch")%>">
  <input type="hidden" name="print_pg">
	  <!-- Instruction -- set the opner_from_name to the parent window to copy stuff -->  
	<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
	<input type="hidden" name="focus_area" value="<%=WI.fillTextValue("focus_area")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>