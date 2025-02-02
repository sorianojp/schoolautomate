<%@ page language="java" import="utility.*, inventory.*, java.util.Vector"%>
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
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}

function UpdateItem(strCategory,strSupply, strClass){	
	var loadPg = "../../purchasing/requisition/update_item.jsp?opner_form_name=form_"+ 
				 "&opner_form_field=item_idx&is_supply="+strSupply+"&cat_index="+strCategory + 
				 "&class_index="+strClass;
	var win=window.open(loadPg,"UpdateItem",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateCategory(strSupply){	
	var loadPg = "./update_category.jsp?opner_form_name=form_&opner_form_field=cat_index"+
				 "&is_supply="+strSupply+"&opner_form_field_value="+document.form_.cat_index.value;
	var win=window.open(loadPg,"UpdateCategory",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateClass(strCat){	
	var loadPg = "./update_class.jsp?opner_form_name=form_&opner_form_field=class_index&inv_cat_index="+strCat;	
	var win=window.open(loadPg,"UpdateClass",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function UpdateBrand(){
	var loadPg = "./update_brand.jsp?opner_form_name=form_&opner_form_field=brand&inv_cat_index="+document.form_.cat_index.value;
	var win=window.open(loadPg,"UpdateBrand",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}

function ChangeType()
{
	document.form_.prepareToEdit.value = "";
	document.form_.cat_index.value = "";
	this.SubmitOnce('form_');
}

function CleanUp()
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
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
//	alert("table " + table);
//	alert("indexname " + indexname);
//	alert("colname " + colname);
//	alert("labelname " + labelname);
//	alert("tablelist " + tablelist);
//	alert("strIndexes " + strIndexes);
//	alert("strExtraTableCond " + strExtraTableCond);
//	alert("strExtraCond " + strExtraCond);
//	alert("strFormField " + strFormField);
	
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SetUnit()
{
	if (document.form_.small_index.value != "")
		document.form_.small_u.value = document.form_.small_index[document.form_.small_index.selectedIndex].text;
	else
		document.form_.small_u.value = "";
}
function UpdateType(strType){
	if (strType != null)
		document.form_.inventory_type.value = strType;
	else 
		document.form_.inventory_type.value = "0";
}

</script>
<style type="text/css">
<!--
.style1 {font-weight: bold}
-->
</style>
</head>

<%
	DBOperation dbOP = null;
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
								"Admin/staff-Inventory - INV_LOG- INVENTORY_ENTRY_LOG","inv_registry.jsp");
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
	Vector vEditInfo = null;
	int i = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit = null;
	int iSearchResult = 0;
	String strFinCol = null;
	String strInvType = null;		
	String strClassification = WI.fillTextValue("class_index");
	String strCategory = WI.fillTextValue("cat_index");
	String strChecked = null;
	String strDisabled = null;
	strTemp = WI.fillTextValue("page_action");
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");	

	InventoryLog InvLog = new InventoryLog();
	
	InvLog.createDefaultCategory(dbOP);
	InvLog.createDefaultStatus(dbOP);
		
	if(strTemp.length() > 0) {
		if(InvLog.operateOnInventoryRegistry(dbOP, request, Integer.parseInt(strTemp)) != null ) 
			{
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
			}
		else
			strErrMsg = InvLog.getErrMsg();
	}
	
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = InvLog.operateOnInventoryRegistry(dbOP, request, 3);
	
	if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = InvLog.getErrMsg();
	}

	vRetResult = InvLog.operateOnInventoryRegistry(dbOP, request, 4);
	if (vRetResult != null)
		iSearchResult = InvLog.getSearchCount();
	else if (vRetResult == null && strErrMsg == null )
		strErrMsg = InvLog.getErrMsg();


/*
	if (WI.fillTextValue("crap").equals("1"))
	{
		int iTest = InvLog.cleanUpAdvisingList(dbOP);
		if (iTest == 1)
			strErrMsg = "By golly, cleanup has executed";
		else
			strErrMsg = "Oh Shi-- "+InvLog.getErrMsg();
	}
*/

%>
<body bgcolor="#D2AE72">
<form name="form_" action="./inv_registry.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY LOG - INVENTORY REGISTRY PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2">&nbsp;<font size="3" color="red"><strong><%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></font></td>
    </tr>
    <tr> 
      <td height="30">&nbsp; Inventory Type</td>
      <td align="left" valign="middle"><font size="1"> 
        <% 
				if (vEditInfo !=null && vEditInfo.size()>0)
					strInvType = (String) vEditInfo.elementAt(15);
				else
					strInvType = WI.getStrValue(WI.fillTextValue("inventory_type"),"0");
				if(strInvType.equals("1") || strInvType.equals("2")){
					strDisabled = "disabled";
				}else{
					strDisabled = "";
				}
				%>
        <select name="inventory_type" onChange="ChangeType();">
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
      <td height="30">&nbsp; Item Category</td>
      <td align="left" valign="middle"> 
    <%if (vEditInfo != null && vEditInfo.size()>0 && WI.fillTextValue("reload_page").length() == 0)
				strCategory = (String)vEditInfo.elementAt(2);
			else
				strCategory = WI.fillTextValue("cat_index");%>
        <select name="cat_index" onChange="document.form_.reload_page.value='1';ReloadPage();">
          <option value="">Select category</option>
          <%=dbOP.loadCombo("inv_cat_index","inv_category"," from inv_preload_category " +
		  					"where is_supply_cat = " + WI.getStrValue(WI.fillTextValue("inventory_type"),"0") + 
								"order by is_default desc, inv_category", strCategory, false)%> 
        </select> <font size="1"><a href="javascript:UpdateCategory('<%=WI.getStrValue(WI.fillTextValue("inventory_type"),"0")%>')";><img src="../../../images/update.gif" border="0"></a> 
        click to update list of CATEGORY</font></td>
    </tr>
	<%
	if(strCategory.length() > 0 && !strCategory.equals("0")){%>
    <tr>
      <td height="30">&nbsp;&nbsp;Item Brand </td>
      <td align="left" valign="middle">
			<%
				strTemp = WI.fillTextValue("brand");
			%>
        <select name="brand">
          <option value="">Select brand</option>
          <%=dbOP.loadCombo("BRAND_INDEX","BRAND_NAME"," from PUR_PRELOAD_BRAND " +
														" where inv_cat_index = " + WI.getStrValue(strCategory,"-1") +
														" order by BRAND_NAME asc", strTemp, false)%>
        </select>
        <!--<a href='javascript:ViewList("PUR_PRELOAD_BRAND","BRAND_INDEX","BRAND_NAME","BRAND NAME",
							 "PUR_REQUISITION_ITEM","ITEM_BRAND_INDEX", 
							 " and PUR_REQUISITION_ITEM.is_del = 0","","brand")'>	
				-->
        <a href='javascript:UpdateBrand();'> 
				<img src="../../../images/update.gif" width="60" height="25" border="0"></a> <font size="1">click to UPDATE list of Brand Name under the CATEGORY</font></td>
    </tr>
    <tr>
      <td height="30">&nbsp;&nbsp;Item Classification </td>
      <td align="left" valign="middle">
	    <%if (vEditInfo != null && vEditInfo.size()>0 && WI.fillTextValue("reload_page").length() == 0)
			strClassification = (String)vEditInfo.elementAt(16);
		else
			strClassification = WI.fillTextValue("class_index");%>
	    <select name="class_index" onChange="document.form_.reload_page.value='1';ReloadPage();">
        <option value="">Select Class</option>
        <%=dbOP.loadCombo("inv_class_index","classification"," from inv_preload_class " +
		  					"where inv_cat_index = " + WI.getStrValue(strCategory,"0") + 
							" order by classification", strClassification, false)%>
      </select>
      <font size="1"><a href="javascript:UpdateClass('<%=WI.getStrValue(strCategory,"0")%>')";><img src="../../../images/update.gif" border="0"></a> click to update list of CLASS (Optional) </font></td>
    </tr>
	<%}%>
    <tr> 
      <td width="18%" height="30">&nbsp; Item Name </td>
      <td width="82%" align="left" valign="middle">
		 <input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="3" 
		 class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeyUp = "AutoScrollList('form_.starts_with','form_.item_idx',true);" > 
        <font size="1"> Enter start of Name </font> 
        <%
	   if (vEditInfo !=null && vEditInfo.size()>0)
		   strTemp = WI.fillTextValue("info_index");
	   else
		   strTemp = WI.fillTextValue("item_idx");
	    %>
        <select name="item_idx">
          <option value="">Select item</option>
          <%=dbOP.loadCombo("item_index","item_name"," from pur_preload_item " +
		  			 "where inv_cat_index = " + WI.getStrValue(strCategory,"0") +
						 WI.getStrValue(strClassification," and inv_class_index = ","","") +
						 " order by item_name", strTemp, false)%> 
        </select> 
		<% 
		if(strCategory.length() > 0 && !strCategory.equals("0")){%>
		<font size="1">
		<a href="javascript:UpdateItem('<%=WI.getStrValue(strCategory,"0")%>',
									   '<%=WI.getStrValue(WI.fillTextValue("inventory_type"),"0")%>',
									   '<%=WI.getStrValue(WI.fillTextValue("class_index"),"0")%>')";>
		<img src="../../../images/update.gif" width="60" height="25" border="0"></a>click to update Item List </font>
		<%}%>		</td>
    </tr>
    <tr> 
      <td>&nbsp; Big Unit</td>
      <td height="18" valign="middle"> 
        <%if (vEditInfo != null && vEditInfo.size()>0)
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(4),"");
		else
			strTemp = WI.fillTextValue("big_index");%>
        <select name="big_index">
          <option value="">Select unit</option>
          <%=dbOP.loadCombo("unit_index","unit_name"," from pur_preload_unit order by unit_name", strTemp, false)%> 
        </select> 
        <a href='javascript:viewList("PUR_PRELOAD_UNIT","UNIT_INDEX","UNIT_NAME","UNITS",
		"INV_REG_ITEM, INV_REG_ITEM", "BIG_UNIT,small_unit", 
		" and INV_REG_ITEM.IS_VALID = 1, and INV_REG_ITEM.IS_VALID = 1","","big_index")'>
		<img src="../../../images/update.gif" border="0"></a> 
        <font size="1">click to update list of UNITS</font> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp; Small Unit</td>
      <td height="25" valign="middle"> 
        <%if (vEditInfo != null && vEditInfo.size()>0)
			strTemp = (String)vEditInfo.elementAt(6);
		else
			strTemp = WI.fillTextValue("small_index");%>
        <select name="small_index" onChange="javascript:SetUnit()">
          <option value="">Select unit</option>
          <%=dbOP.loadCombo("unit_index","unit_name"," from pur_preload_unit order by unit_name", strTemp, false)%> 
        </select>
        <font size="1">( Note: Fill up as 
        primary unit )</font> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp; Conversion</td>
      <td valign="middle"> 
        <%if (vEditInfo != null && vEditInfo.size()>0)
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(8),"");
		else
			strTemp = WI.fillTextValue("conv");%>
        <input name="conv" type="text" class="textbox" value="<%=strTemp%>" size="4" maxlength="4"
	   onKeyUp= 'AllowOnlyInteger("form_","conv")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","conv");style.backgroundColor="white"'> 
        <input name="small_u" type="text" class="textbox_noborder" style="font-size:9px" size="15" readonly="readonly"> 
        <script language="javascript">
       SetUnit();
       </script> </td>
    </tr>
    
    <tr> 
      <td height="25" valign="bottom">&nbsp; Attributes:</td>
      <td height="25" valign="middle">&nbsp;</td>
    </tr>
    <tr> 
      <td height="23" >&nbsp;</td>
      <%if (vEditInfo != null && vEditInfo.size()>0)
					strTemp = WI.getStrValue((String)vEditInfo.elementAt(9),"0");
				else
					strTemp = WI.fillTextValue("expire");
				
				if (strTemp.equals("1") || strInvType.equals("2"))
					strChecked = " checked";
				else
					strChecked = "";
			%>
      <td valign="middle"> 
        <input type="checkbox" name="expire" value="1" <%=strChecked%>> 
        Expires</td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <%if (vEditInfo != null && vEditInfo.size()>0)
					strTemp = WI.getStrValue((String)vEditInfo.elementAt(10),"0");
				else
					strTemp = WI.fillTextValue("transfer");
				if (strTemp.equals("1"))
					strChecked = " checked";
				else
					strChecked = "";				
				%>
      <td valign="middle"> 
        <input type="checkbox" name="transfer" value="1" <%=strChecked%> <%=strDisabled%>> 
        Transferrable</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <%if (vEditInfo != null && vEditInfo.size()>0)
					strTemp = WI.getStrValue((String)vEditInfo.elementAt(11),"0");
				else
					strTemp = WI.fillTextValue("borrow");
				if (strTemp.equals("1"))
					strChecked = " checked";
				else
					strChecked = "";				
				%>			
      <td height="21" valign="middle"> 
        <input type="checkbox" name="borrow" value="1" <%=strChecked%> <%=strDisabled%>> 
        Borrowable</td>
    </tr>
    <tr> 
      <td height="18" >&nbsp;</td>
      <%if (vEditInfo != null && vEditInfo.size()>0)
					strTemp = WI.getStrValue((String)vEditInfo.elementAt(12),"0");
				else
					strTemp = WI.fillTextValue("consume");
				if (strTemp.equals("1"))
					strChecked = " checked";
				else
					strChecked = "";
				%>
      <td valign="middle"> 
        <input type="checkbox" name="consume" value="1" <%=strChecked%>>
        Consumable </td>
    </tr>
		<%if(strInvType.equals("3")){%>
    <tr> 
      <td height="18" >&nbsp;</td>
       <%if (vEditInfo != null && vEditInfo.size()>0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(13),"0");
				 else
						strTemp = WI.fillTextValue("cpu_component");
				 if (strTemp.equals("1"))
						strChecked = " checked";
				 else
						strChecked = "";				
				%>
      <td valign="middle"> 
        <input type="checkbox" name="cpu_component" value="1" <%=strChecked%>> 
        Is Computer Part?        </td>
    </tr>
		<%}%>      
    <tr> 
      <td class="style1 bodystyle">&nbsp;</td>
      <td height="55" valign="bottom"><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to add entry 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit entry <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to cancel 
        <%}%>
        </font></td>
    </tr>
    <tr> 
			<%
				if(WI.fillTextValue("show_all").length() > 0){
					strTemp = " checked";
				}else{
					strTemp = "";
				}
			%>
      <td height="25" colspan="2"><input type="checkbox" name="show_all" value="1" <%=strTemp%> onClick="ReloadPage();">
        show all (including deleted items)</td>
    </tr>
  </table>
  <%if (vRetResult!= null && vRetResult.size()>0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="26" colspan="8" class="thinborder"><div align="center"> 
          <p><strong><font size="2">ITEM LIST </font></strong></p>
        </div></td>
    </tr>
    <tr> 
      <td  height="25" colspan="4" class="thinborderBOTTOMLEFT" align="left"><font size="1"><strong>TOTAL 
        ITEMS: &nbsp;&nbsp;<%=iSearchResult%></strong></font></td>
      <td colspan="4" align="right" class="thinborderBOTTOM">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/InvLog.defSearchSize;
		if(iSearchResult % InvLog.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1){%>
		Page 
        <select name="jumpto" onChange="ReloadPage();" style="font-size:11px">
          <%
			strTemp = WI.fillTextValue("jumpto");
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
      <td width="23%" height="25" align="center" class="thinborder"><strong>Item 
        Name </strong></td>
      <td width="14%" align="center" class="thinborder"><strong>Category</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>Class</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>Big Unit</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>Small Unit</strong></td>
      <td width="17%" align="center" class="thinborder"><strong>Attributes</strong></td>
      <td width="17%" colspan="2" align="center" class="thinborder"><strong>OPTIONS</strong></td>
    </tr>
    <%for (i=0;i<vRetResult.size(); i+=19){
    strTemp = (String)vRetResult.elementAt(i+14);
     if (strTemp.equals("0"))
	    strFinCol = " bgcolor = '#EEEEEE'";
	else 
		strFinCol = " bgcolor = '#FFFFFF'";
    %>
    <tr <%=strFinCol%>> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+17),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(((String)vRetResult.elementAt(i+5)),"","<br>","NONE")%> 
        <%=WI.getStrValue(((String)vRetResult.elementAt(i+8)),"&nbsp;("," "+(String)vRetResult.elementAt(i+7)+")","&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
      <td class="thinborder"> 
        <%if (((String)vRetResult.elementAt(i+9)).equals("1")){%>
        EXPIRES<br> 
        <%}
      if (((String)vRetResult.elementAt(i+10)).equals("1")){%>
        TRANSFERRABLE<br> 
        <%}
      if (((String)vRetResult.elementAt(i+11)).equals("1")){%>
        BORROWABLE<br> 
        <%}
      if (((String)vRetResult.elementAt(i+12)).equals("1")){%>
        CONSUMABLE 
        <%}
      if (((String)vRetResult.elementAt(i+13)).equals("1")){%>
        COMPUTER COMPONENT 
        <%}%>&nbsp;      </td>
      <%if (strTemp.equals("1")){%>
      <td align="center" class="thinborder"> 
        <%if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        &nbsp; 
        <%}%>      </td>
      <td align="center" class="thinborder"> 
        <%if (iAccessLevel == 2) {%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        &nbsp; 
        <%}%>      </td>
      <%} else {%>
      <td colspan="2" class="thinborder" align="center"> 
        <%if (iAccessLevel == 2){%>
        <a href='javascript:PageAction("5","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/undelete.gif" border="0"></a> 
        <%} else {%>
        &nbsp; 
        <%}%>      </td>
      <%}%>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
    <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
    <input type="hidden" name="page_action">
   	<input type="hidden" name="print_pg">
   	<input type="hidden" name="reload_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>