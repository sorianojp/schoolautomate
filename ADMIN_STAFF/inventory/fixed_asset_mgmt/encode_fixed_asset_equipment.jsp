<%@ page language="java" import="utility.*, inventory.InvFixedAssetMngt, java.util.Vector"%>
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
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;		
	if(strAction == 1) 
		document.form_.hide_save.src = "../../../images/blank.gif";
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

function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function CancelClicked(){
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}

function goBack(){
	location = "encode_fixed_asset.jsp?asset_type=4&delivery_for="+document.form_.delivery_for.value+
						 "&del_fr="+document.form_.del_fr.value+"&del_to="+document.form_.del_to.value+
						 "&del_year="+document.form_.del_year.value+"&del_month="+document.form_.del_month.value;

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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-FIXED_ASSET"),"0"));
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
							"INVENTORY-INVENTORY LOG","encode_fixed_asset_equipment.jsp");
		
	InvFixedAssetMngt InvFAM = new InvFixedAssetMngt();	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	Vector vAssetInfo = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strAssetType = WI.getStrValue(WI.fillTextValue("asset_type"),"0");
	String strPageAction = WI.fillTextValue("page_action");
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

	if(strPageAction.length() > 0){
	  if(InvFAM.operateOnEquipments(dbOP,request,Integer.parseInt(strPageAction)) == null)
		strErrMsg = InvFAM.getErrMsg();
	  strPrepareToEdit = "";
	}

	if(WI.fillTextValue("is_for_log").length() > 0){
		vAssetInfo = InvFAM.operateOnEquipments(dbOP,request,5);
		  if(vAssetInfo == null || vAssetInfo.size() == 0)
			strErrMsg = InvFAM.getErrMsg();
		//System.out.println("vAssetInfo " + vAssetInfo);
	}
	
	if(strPrepareToEdit.length() > 0){
		vEditInfo = InvFAM.operateOnEquipments(dbOP,request,3);			
	}	
	vRetResult = InvFAM.operateOnEquipments(dbOP,request,4);		
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./encode_fixed_asset_equipment.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          FIXED ASSETS MANAGEMENT -ENCODE ASSET - EQUIPMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><a href="javascript:goBack();"><img src="../../../images/go_back.gif" border="0"></a>
				<%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
    </tr>
    <tr> 
      <td height="25" width="6%">&nbsp;</td>
      <td width="16%">ASSET TYPE : </td>
      <td width="18%"><strong>EQUIPMENT</strong></td>
      <td width="60%" align="left">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td width="22%" valign="middle">Item Name</td>
	  <%
	  	if (vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(2);
		else if (vAssetInfo != null && vAssetInfo.size() > 0)
			strTemp = (String)vAssetInfo.elementAt(1);		
	  %>	  
      <td width="72%"><%=WI.getStrValue(strTemp,"")%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Brand Name</td>
	  <%
	  	if (vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(3);
		else if (vAssetInfo != null && vAssetInfo.size() > 0)
			strTemp = (String)vAssetInfo.elementAt(2);
	  %>	  
      <td><%=WI.getStrValue(strTemp,"")%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Supplier Name</td>
	  <%
	  	if (vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(5);
		else if (vAssetInfo != null && vAssetInfo.size() > 0)
			strTemp = (String)vAssetInfo.elementAt(4);
	  %>	  
      <td><%=WI.getStrValue(strTemp,"")%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date Acquired</td>
	  <%
	  	if (vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(4);
		else if (vAssetInfo != null && vAssetInfo.size() > 0)
			strTemp = (String)vAssetInfo.elementAt(3);
	  %>	  
      <td><%=WI.getStrValue(strTemp,"")%>
<input type="hidden" name="date_acquired" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Unit Cost</td>
	  <%
	  	if (vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(6);
		else if (vAssetInfo != null && vAssetInfo.size() > 0)
			strTemp = (String)vAssetInfo.elementAt(6);
	  %>	  
      <td><%=WI.getStrValue(strTemp,"")%>
<input type="hidden" name="unit_cost" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Unit</td>
	  <%
	  	if (vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(7);
		else if (vAssetInfo != null && vAssetInfo.size() > 0)
			strTemp = (String)vAssetInfo.elementAt(5);
	  %>	  
      <td><%=WI.getStrValue(strTemp,"")%></td>
    </tr>
	<!--
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Acquisition Cost</td>
      <td><%//=(String)vAssetInfo.elementAt(11)%></td>
    </tr>
	-->
    <tr>
      <td height="25">&nbsp;</td>
      <td>Salvage Value </td>
			<%	strTemp = null;
				if (vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(17);
			%>	  
      <td><font size="1">
        <input name="salvage_value" type="text" size="16" maxlength="16"				
				onKeyUp="AllowOnlyIntegerExtn('form_','salvage_value','.')"
		 		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','salvage_value','.')" 
		 		onFocus="style.backgroundColor='#D3EBFF';" value="<%=CommonUtil.formatFloat(strTemp,true)%>">
      </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Life</td>
	  <%
	  	if (vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(8);
		else
			strTemp = WI.fillTextValue("asset_life");
	  %>
      <td><input name="asset_life" type="text" size="8" maxlength="8" value="<%=WI.getStrValue(strTemp,"0")%>"
onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Asset Status</td>
      <td height="25" valign="bottom"> 
	  <%
	  	if (vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(15);
		else
			strTemp = WI.fillTextValue("asset_status");
	  %>
	  <select name="asset_status">
        <option value="">Select status</option>
        <%=dbOP.loadCombo("pre_asset_index","asset_name"," from INV_PRELOAD_FX_ASSET order by asset_name", strTemp, false)%> 
	  </select> <font size="1">
		  <a href='javascript:viewList("INV_PRELOAD_FX_ASSET","PRE_ASSET_INDEX","ASSET_NAME","FIXED ASSET LIST","INV_FIXED_ASSET","asset_status","","","asset_status")'> 
        <img src="../../../images/update.gif" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
    </tr>
    <% if ((vEditInfo != null && vEditInfo.size() > 0) || (vAssetInfo != null && vAssetInfo.size() > 0)){%>
	<tr> 
      <td width="73%"><div align="center">
          <%if(strPrepareToEdit.compareTo("1") != 0) {%>
          <a href='javascript:PageAction(1, "");'> <img src="../../../images/save.gif" border="0" id="hide_save"></a><font size="1"> 
          click to save entries</font> 
          <%}else{%>
          <a href='javascript:PageAction(2,"");'> <img src="../../../images/edit.gif" border="0"></a><font size="1"> 
          click to save changes</font> 
          <%}%>
          <a href="javascript:CancelClicked();"><img src="../../../images/cancel.gif" border="0"></a> 
          <font size="1"> click to cancel or clear entries</font></div></td>
    </tr>
	<%}%>	
  </table>
  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="1"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="7" bgcolor="#B9B292"><div align="center">LIST OF 
          EQUIPMENTS ENCODED</div></td>
    </tr>
    <tr> 
      <td width="31%" height="25" align="center"><font size="1"><strong>ASSET 
        DESCRIPTION</strong></font></td>
      <td width="11%" align="center"><font size="1"><strong>DATE ACQUIRED</strong></font></td>
      <td width="10%" align="center"><font size="1"><strong>COST</strong></font></td>
      <td width="6%" align="center"><font size="1"><strong>LIFE</strong></font></td>
      <td width="12%" align="center"><font size="1"><strong>DEPRECIATION</strong></font></td>
      <td width="15%" align="center"><font size="1"><strong>ASSET STATUS</strong></font></td>
      <td width="15%"><font size="1">&nbsp;</font></td>
    </tr>
    <%for(int i = 0;i < vRetResult.size(); i+=22){%>
    <tr> 
      <td height="25"><font size="1"><%=WI.getStrValue((String) vRetResult.elementAt(i+16),"")%><%=WI.getStrValue((String) vRetResult.elementAt(i+2),"")%>&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+11),"")%></font></td>
      <% 
		strTemp = (String) vRetResult.elementAt(i + 21);
		if(strTemp == null){
			strTemp =  (String) vRetResult.elementAt(i+4);
		}
		strTemp2 =  (String) vRetResult.elementAt(i+6);
	  %>
      <td><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
      <td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp2,true),"")%>&nbsp;</font></div></td>
      <td><div align="right"><font size="1"><%=WI.getStrValue((String) vRetResult.elementAt(i+8),"")%></font></div></td>
      <%
	  	strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(i+10),true);
	  %>
      <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></div></td>
      <td><div align="center"><font size="1"><%=(String) vRetResult.elementAt(i + 12)%></font></div></td>
      <td><font size="1">
        <a href='javascript:PrepareToEdit("<%=WI.getStrValue((String)vRetResult.elementAt(i))%>");'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a> 
        <a href='javascript:PageAction(0,"<%=WI.getStrValue((String)vRetResult.elementAt(i))%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a></font></td>
    </tr>
    <%}%>
  </table>
  <%}// end if vRetResult != null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
    <input type="hidden" name="page_action">
   	<input type="hidden" name="print_pg">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="is_for_log" value="<%=WI.fillTextValue("is_for_log")%>">
	<input type="hidden" name="delivery_for" value="<%=WI.fillTextValue("delivery_for")%>">
	<input type="hidden" name="del_fr" value="<%=WI.fillTextValue("del_fr")%>">	
	<input type="hidden" name="del_to" value="<%=WI.fillTextValue("del_to")%>">	
	<input type="hidden" name="del_year" value="<%=WI.fillTextValue("del_year")%>">	
	<input type="hidden" name="del_month" value="<%=WI.fillTextValue("del_month")%>">	
	
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>