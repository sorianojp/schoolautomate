<%@ page language="java" import="utility.*, inventory.*, java.util.Vector"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>


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

function UpdateItem(strSupply){	
	var loadPg = "../../purchasing/requisition/update_item.jsp?opner_form_name=form_&opner_form_field=item_idx&is_supply="+strSupply;
	var win=window.open(loadPg,"UpdateCity",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage()
{
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-MASTERLIST"),"0"));
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
								"Admin/staff-Inventory - INV_LOG-INVENTORY_ENTRY_LOG","item_masterlist.jsp");
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
	strTemp = WI.fillTextValue("page_action");
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");

	InventoryLog InvLog = new InventoryLog();
	
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
<form name="form_" action="./item_masterlist.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PURCHASING - ITEMS MASTERLIST PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;<font size="3" color="red"><strong><%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></font></td>
    </tr>
    <tr>
      <td>&nbsp;</td> 
      <td height="30">&nbsp; Inventory Type</td>
      <td align="left" valign="middle"><font size="1"> 
        <% 
		  if (vEditInfo !=null && vEditInfo.size()>0)
		   	strInvType = (String) vEditInfo.elementAt(15);
		  else
		  	strInvType = WI.getStrValue(WI.fillTextValue("inventory_type"),"0");
	    %>
        <select name="inventory_type" onChange="ReloadPage();">
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
      <td>&nbsp;</td> 
      <td height="30">&nbsp; Item Category</td>
      <td align="left" valign="middle"> 
        <%if (vEditInfo != null && vEditInfo.size()>0)
			strTemp = (String)vEditInfo.elementAt(2);
		else
			strTemp = WI.fillTextValue("cat_index");%>
        <select name="cat_index">
          <option value="">Select category</option>
          <%=dbOP.loadCombo("inv_cat_index","inv_category"," from inv_preload_category order by inv_category", strTemp, false)%> 
        </select> <font size="1"><a href='javascript:viewList("INV_PRELOAD_CATEGORY","INV_CAT_INDEX","INV_CATEGORY",
		"ITEM CATEGORIES", "INV_REG_ITEM", "INV_CAT_INDEX"," and INV_REG_ITEM.is_valid = 1","","cat_index")'><img src="../../../images/update.gif" border="0"></a> 
        click to update list of CATEGORY</font></td>
    </tr>
    <tr>
      <td width="3%">&nbsp;</td> 
      <td width="15%" height="30">&nbsp; Item Name </td>
      <td width="82%" align="left" valign="middle"><input name="item_name" type="text" value="<%=strTemp%>" size="32" maxlength="32" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr>
      <td class="style1 bodystyle">&nbsp;</td> 
      <td class="style1 bodystyle">&nbsp; Big Unit</td>
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
      <td class="style1 bodystyle">&nbsp;</td> 
      <td height="25" class="style1 bodystyle">&nbsp; Small Unit</td>
      <td height="25" valign="middle"> 
        <%if (vEditInfo != null && vEditInfo.size()>0)
			strTemp = (String)vEditInfo.elementAt(6);
		else
			strTemp = WI.fillTextValue("small_index");%>
        <select name="small_index" onChange="javascript:SetUnit()">
          <option value="">Select unit</option>
          <%=dbOP.loadCombo("unit_index","unit_name"," from pur_preload_unit order by unit_name", strTemp, false)%> 
        </select> 
        <font size="1"> (Note: Fill up as 
        primary unit )</font> </td>
    </tr>
    <tr>
      <td>&nbsp;</td> 
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
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">	
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="15%">&nbsp;Apply to : </td>
      <td  width="21%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td> 
      <td>&nbsp;</td>
      <td>&nbsp; Employee Status</td>
      <td><select name="pt_ft" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%if (WI.fillTextValue("pt_ft").equals("0")){%>
		  <option value="0" selected>Part - time</option>
          <option value="1">Full - time</option>
          <%}else if(WI.fillTextValue("pt_ft").equals("1")){%>
		  <option value="0">Part - time</option>
          <option value="1" selected>Full - time</option>
          <%}else{%>
		  <option value="0">Part - time</option>
          <option value="1">Full - time</option>
          <%}%>
      </select></td>
    </tr>	
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
	<%if(bolIsSchool){%>
    <tr>
      <td>&nbsp;</td> 
      <td>&nbsp;</td>
      <td>&nbsp; Employee Category</td>
      <td><select name="employee_category" onChange="ReloadPage();">                    
          <option value="" selected>ALL</option>
          <%if (WI.fillTextValue("employee_category").equals("0")){%>
		  <option value="0" selected>Non-Teaching</option>
          <option value="1">Teaching</option>          
          <%}else if (WI.fillTextValue("employee_category").equals("1")){%>
		  <option value="0">Non-Teaching</option>
          <option value="1" selected>Teaching</option>          
          <%}else{%>
		  <option value="0">Non-Teaching</option>
          <option value="1">Teaching</option>          
          <%}%>
        </select> </td>
    </tr>
	<%}%>
    
    <tr>
      <td>&nbsp;</td> 
      <td>&nbsp;</td>
      <td>&nbsp;
  <%if(bolIsSchool){%>College<%}else{%>Division<%}%></td><td> <select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr>
      <td>&nbsp;</td> 
      <td>&nbsp;</td>
      <td>&nbsp; Department/Office</td>
      <td> <select name="d_index" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="3%" >&nbsp;</td>
      <td width="15%" height="23" ><span class="style1 bodystyle">&nbsp; Attributes:</span></td>
      <td width="82%" valign="middle">&nbsp;</td>
    </tr>
    <tr>
      <td >&nbsp;</td> 
      <td height="23" >&nbsp;</td>
      <td valign="middle"> 
        <%if (vEditInfo != null && vEditInfo.size()>0)
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(9),"0");
		else
			strTemp = WI.fillTextValue("expire");
		if (strTemp != null && strTemp.equals("1")){%>
        <input type="checkbox" name="expire" value="1" checked> 
        <%} else {%>
        <input type="checkbox" name="expire" value="1"> 
        <%}%>
        Expires</td>
    </tr>
    <tr>
      <td>&nbsp;</td> 
      <td height="24">&nbsp;</td>
      <td valign="middle"> 
        <%if (vEditInfo != null && vEditInfo.size()>0)
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(10),"0");
		else
			strTemp = WI.fillTextValue("transfer");
	  if(strTemp != null && strTemp.equals("1")){%>
        <input type="checkbox" name="transfer" value="1" checked> 
        <%} else {%>
        <input type="checkbox" name="transfer" value="1"> 
        <%}%>
        Transferrable</td>
    </tr>
    <tr>
      <td>&nbsp;</td> 
      <td>&nbsp;</td>
      <td height="21" valign="middle"> 
        <%if (vEditInfo != null && vEditInfo.size()>0)
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(11),"0");
		else
			strTemp = WI.fillTextValue("borrow");
		if(strTemp != null && strTemp.equals("1")){%>
        <input type="checkbox" name="borrow" value="1" checked> 
        <%} else {%>
        <input type="checkbox" name="borrow" value="1"> 
        <%}%>
        Borrowable</td>
    </tr>
    <tr>
      <td >&nbsp;</td> 
      <td height="18" >&nbsp;</td>
      <td valign="middle"> 
        <%if (vEditInfo != null && vEditInfo.size()>0)
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(12),"0");
		else
			strTemp = WI.fillTextValue("consume");
		if(strTemp != null && strTemp.equals("1")){%>
        <input type="checkbox" name="consume" value="1" checked> 
        <%} else {%>
        <input type="checkbox" name="consume" value="1"> 
        <%}%>
        Consumable </td>
    </tr>
    <tr>
      <td >&nbsp;</td> 
      <td height="18" >&nbsp;</td>
      <td valign="middle"> 
        <%if(strInvType.equals("3")){%>
        <%if (vEditInfo != null && vEditInfo.size()>0)
				strTemp = WI.getStrValue((String)vEditInfo.elementAt(13),"0");
			else
				strTemp = WI.fillTextValue("cpu_component");
			if(strTemp != null && strTemp.equals("1")){%>
        <input type="checkbox" name="cpu_component" value="1" checked> 
        <%} else {%>
        <input type="checkbox" name="cpu_component" value="1"> 
        <%}%>
        Is Computer Part? 
        <%}%>      </td>
    </tr>
    <tr>
      <td class="style1 bodystyle">&nbsp;</td> 
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
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
  <%if (vRetResult!= null && vRetResult.size()>0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="26" colspan="7" class="thinborder"><div align="center"> 
          <p><strong><font size="2">ITEM LIST </font></strong></p>
        </div></td>
    </tr>
    <tr> 
      <td  height="25" colspan="3" class="thinborderBOTTOMLEFT" align="left"><font size="1"><strong>TOTAL 
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
        <%} //if no pages %>
      </td>
    </tr>
    <tr> 
      <td width="23%" height="25" class="thinborder"><div align="center"><strong>Item 
          Name </strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong>Category</strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>Big Unit</strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>Small Unit</strong></div></td>
      <td width="17%" class="thinborder"><div align="center"><strong>Attributes</strong></div></td>
      <td width="17%" colspan="2" align="center" class="thinborder"><div align="center"><strong>OPTIONS</strong></div></td>
    </tr>
    <%for (i=0;i<vRetResult.size(); i+=16){
    strTemp = (String)vRetResult.elementAt(i+14);
     if (strTemp != null && strTemp.equals("0"))
	    strFinCol = " bgcolor = '#EEEEEE'";
	else 
		strFinCol = " bgcolor = '#FFFFFF'";
    %>
    <tr <%=strFinCol%>> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(((String)vRetResult.elementAt(i+5)),"","<br>","NONE")%> 
        <%=WI.getStrValue(((String)vRetResult.elementAt(i+8)),"&nbsp;("," "+(String)vRetResult.elementAt(i+7)+")","&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
      <td class="thinborder"> 
        <%if (WI.getStrValue(vRetResult.elementAt(i+9)).equals("1")){%>
        EXPIRES<br> 
        <%}
       if (WI.getStrValue(vRetResult.elementAt(i+10)).equals("1")){%>
        TRANSFERRABLE<br> 
        <%}
      if (WI.getStrValue(vRetResult.elementAt(i+11)).equals("1")){%>
        BORROWABLE<br> 
        <%}
      if (WI.getStrValue(vRetResult.elementAt(i+12)).equals("1")){%>
        CONSUMABLE 
        <%}
      if (WI.getStrValue(vRetResult.elementAt(i+13)).equals("1")){%>
        COMPUTER COMPONENT 
        <%}%>
      </td>
      <%if(strTemp != null && strTemp.equals("1")){%>
      <td align="center" class="thinborder"> 
        <%if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        &nbsp; 
        <%}%>
      </td>
      <td align="center" class="thinborder"> 
        <%if (iAccessLevel == 2) {%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        &nbsp; 
        <%}%>
      </td>
      <%} else {%>
      <td colspan="2" class="thinborder" align="center"> 
        <%if (iAccessLevel == 2){%>
        <a href='javascript:PageAction("5","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/undelete.gif" border="0"></a> 
        <%} else {%>
        &nbsp; 
        <%}%>
      </td>
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
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>