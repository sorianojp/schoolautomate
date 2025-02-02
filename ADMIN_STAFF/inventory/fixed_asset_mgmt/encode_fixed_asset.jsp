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

function ReloadPage()
{
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}

function resetPage(){
	document.form_.jumpto.value = "0";
	ReloadPage();
}

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

function EncodeEquipment(strIndex){
	document.form_.info_index.value = strIndex;
	document.form_.encode_equip.value = "1";
	this.SubmitOnce('form_');
}

</script>
</head>
<%
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if (WI.fillTextValue("encode_equip").length() > 0){%>
		<jsp:forward page="./encode_fixed_asset_equipment.jsp?is_for_log=1" />
	<% return;}
	
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
							"INVENTORY-INVENTORY LOG","encode_fixed_asset.jsp");
		
	InvFixedAssetMngt InvFAM = new InvFixedAssetMngt();	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	Vector vEquipment = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolEditMode = false;
	String strReadOnly = "";
	String strAssetType = WI.getStrValue(WI.fillTextValue("asset_type"),"0");
	String strPageAction = WI.fillTextValue("page_action");
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	int iSearch = 0;

	String[] astrAssetTypeName = {"Buildings","Building Improvements","Land","Land Improvements","Equipment"};
	String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
								"September","October","November","December"};

	if(strPageAction.length() > 0){
		if(InvFAM.operateOnFixedAsset(dbOP,request,Integer.parseInt(strPageAction)) == null)
			strErrMsg = InvFAM.getErrMsg();
		strPrepareToEdit = "";
	}
	
	if(strPrepareToEdit.length() > 0){
	  vEditInfo = InvFAM.operateOnFixedAsset(dbOP,request,3);
	  if (vEditInfo == null)
	  	strErrMsg = InvFAM.getErrMsg();
	  else{
	  	bolEditMode = true;	  
		strReadOnly = "readonly";
	  }
	}
	
	if(strAssetType.equals("4")){
		vEquipment = InvFAM.getEquipments(dbOP,request,4);
		if(vEquipment != null)
			iSearch = InvFAM.getSearchCount();	
	}

	vRetResult = InvFAM.operateOnFixedAsset(dbOP,request,4);		
	if(vRetResult != null)
	  iSearch = InvFAM.getSearchCount();
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./encode_fixed_asset.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          FIXED ASSETS MANAGEMENT - ENCODE ASSET PAGE ::::</strong></font><font color="#FFFFFF" ></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><font size="3" color="red"><strong><%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></font></td>
    </tr>
    <tr> 
      <td height="25" width="6%">&nbsp;</td>
      <td width="16%">Asset Type</td>
	  <%if(vRetResult != null && vRetResult.size() > 0)
	  		strTemp = "resetPage();";
		else
			strTemp = "ReloadPage();";
	  %>
      <td width="18%"> 
	     <select name="asset_type" onChange="<%=strTemp%>">
          <%for(int i = 0;i<5;i++){
			  if(Integer.parseInt(strAssetType) == i)
				  strTemp = "selected";
			  else
				  strTemp = "";
		  %>
          <option value="<%=i%>" <%=strTemp%>><%=astrAssetTypeName[i]%></option>
          <%}%>
        </select> <a href="javascript:show_calendar('form_.inv_date');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        </a></td>
      <td width="60%" align="left">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <%if(strAssetType.equals("4")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" dwcopytype="CopyTableRow">
    <tr bgcolor="#FFFFFF"> 
      <td width="7%" height="25">&nbsp;</td>
      <td width="21%" height="25">Show Delivery for </td>
      <td width="72%" height="25"> 
	    <%
			strTemp = WI.fillTextValue("delivery_for");
		%>
		<select name="delivery_for" onChange="ReloadPage();">
          <option value="0" selected>Specific Date</option>
          <%if (strTemp.equals("1")){%>		  
          <option value="1" selected>Date Range</option>
          <%}else{%>
          <option value="1">Date Range</option>
          <%}if (strTemp.equals("2")){%>
          <option value="2" selected>Year</option>
          <%}else{%>
          <option value="2">Year</option>
          <%}%>
        </select> </td>
    </tr>
    <%if(strTemp.equals("1")){%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"> <%strTemp = WI.fillTextValue("del_fr");%> <input name="del_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.del_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <%strTemp = WI.fillTextValue("del_to");%> <input name="del_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.del_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
      </td>
    </tr>
    <%}else if(strTemp.equals("2")){%>
    <tr bgcolor="#FFFFFF"> 
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td height="24"> 
	    <select name="del_year" onChange="ReloadPage();">
          <%=dbOP.loadComboYear(WI.fillTextValue("del_year"),2,1)%> 
		</select> 
		<%
			strTemp = WI.fillTextValue("del_month");
		%>
		<select name="del_month">
          <option value="">All</option>
          <%for(int i = 0; i < 12; ++i){%>
		  	<%if(strTemp.equals(Integer.toString(i+1))){%>
          		<option value="<%=i+1%>" selected><%=astrConvertMonth[i]%></option>
		  	<%}else{%>
		  		<option value="<%=i+1%>"><%=astrConvertMonth[i]%></option>
			<%}%>	
          <%}%>
        </select> </td>
    </tr>
    <%}else{%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" width="7%">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"> <%strTemp = WI.fillTextValue("del_fr");%> <input name="del_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <font size="1"><a href="javascript:show_calendar('form_.del_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></td>
    </tr>
     <%}%>
	<tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
   
  </table>
  <%}%>
  <%if(strAssetType.equals("2")){%>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" dwcopytype="CopyTableRow">
    <tr> 
      <td width="7%" height="25">&nbsp;</td>
      <td width="21%" valign="middle">Name/Description </td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(2);
	  	else
			strTemp = WI.fillTextValue("description");
	  %>
      <td width="72%">
				<textarea name="description" cols="32" rows="3" onFocus="style.backgroundColor='#D3EBFF'" 
				onblur='style.backgroundColor="white"'><%=WI.getStrValue(strTemp,"")%></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(4);
	  	else
			strTemp = WI.fillTextValue("date_acquired");
	  %>
      <td>Date Acquired</td>
      <td><input name="date_acquired" type="text" size="16" maxlength="16" 
			onFocus="style.backgroundColor='#D3EBFF';" onBlur="style.backgroundColor='white';"
			value="<%=WI.getStrValue(strTemp,"")%>" readonly> 
        <font size="1"><a href="javascript:show_calendar('form_.date_acquired');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Purchased Value</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(7);
	  	else
			strTemp = WI.fillTextValue("purchase_value");
	  %>
      <td> 
			<input name="purchase_value" type="text" size="16" maxlength="16" 
			onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp= "AllowOnlyIntegerExtn('form_','purchase_value','.')"
			onblur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','purchase_value','.')"
			value="<%=WI.getStrValue(strTemp,"")%>"> <font size="1">&nbsp;(optional) 
        </font></td>
    </tr>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(8);
	  	else
			strTemp = WI.fillTextValue("purchase_from");
	  %>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Purchased From</td>
      <td><input name="purchase_from" type="text" size="32" maxlength="64" 
			onFocus="style.backgroundColor='#D3EBFF';" onBlur="style.backgroundColor='white';"
			value="<%=WI.getStrValue(strTemp,"")%>"> <font size="1">(optional) 
        </font></td>
    </tr>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(16);
	  	}else{
			strTemp = WI.fillTextValue("cur_assessed_value");
		}
	  %>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Current Assessed Value</td>
      <td>
			 <input name="cur_assessed_value" type="text" size="16" maxlength="16"
	  	 onKeyUp="AllowOnlyIntegerExtn('form_','cur_assessed_value','.')"
			 onFocus="style.backgroundColor='#D3EBFF'" 
		   onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','cur_assessed_value','.')" 
			 value="<%=CommonUtil.formatFloat(strTemp,true)%>" <%=strReadOnly%>> 
		<%if(bolEditMode){%>  
		<font size="1" color="#FF0000">*To update this and succeeding fields go to update fixed asset page</font>
		<%}%>
	  </td>
    </tr>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(17);
	  	else
			strTemp = WI.fillTextValue("date_last_assessed");
	  %>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date Last Assessed</td>
      <td><input name="date_last_assessed" type="text" size="16" maxlength="16" 
			onFocus="style.backgroundColor='#D3EBFF';" onBlur="style.backgroundColor='white';"
			value="<%=WI.getStrValue(strTemp,"")%>" readonly> 
        <font size="1">
		<%if(!bolEditMode){%>
		<a href="javascript:show_calendar('form_.date_last_assessed');" title="Click to select date" 
	    onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
		<%}%>
		</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Fixed Asset Status</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(14);
			strTemp2 = " where pre_asset_index = " + strTemp; 
	  	}else{
			strTemp = WI.fillTextValue("asset_status");
			strTemp2 = "";
		}	
		%>
      <td>
		 <select name="asset_status">
          <%if(!bolEditMode){%>
		  <option value="">Select status</option>
		  <%}%>		  
          <%=dbOP.loadCombo("pre_asset_index","asset_name"," from INV_PRELOAD_FX_ASSET " + strTemp2 + "order by asset_name", strTemp, false)%> 
        </select> <font size="1">
		<%if(!bolEditMode){%>
		<a href='javascript:viewList("INV_PRELOAD_FX_ASSET","PRE_ASSET_INDEX","ASSET_NAME","FIXED ASSET LIST","INV_FIXED_ASSET","asset_status","","","asset_status")'><img src="../../../images/update.gif" border="0"></a>
		<%}%>
		</font>
		</td>
    </tr>
  </table>
  <%}%>
  <%if(strAssetType.equals("3")){%>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" dwcopytype="CopyTableRow">
    <tr> 
      <td height="25" width="7%">&nbsp;</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(2);
	  	else
			strTemp = WI.fillTextValue("description");
		%>
      <td width="21%" valign="middle">Name/Description </td>
      <td width="72%"><textarea name="description" cols="32" rows="3" onFocus="style.backgroundColor='#D3EBFF'" 
				onblur='style.backgroundColor="white"'><%=WI.getStrValue(strTemp,"")%></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(6);
	  	else
			strTemp = WI.fillTextValue("date_improved");
		%>	  
      <td>Date of Improvement</td>
      <td><input name="date_improved" type="text" size="16" maxlength="16" 
			onFocus="style.backgroundColor='#D3EBFF';" onBlur="style.backgroundColor='white';"
			value="<%=WI.getStrValue(strTemp,"")%>" readonly> 
        <font size="1"><a href="javascript:show_calendar('form_.date_improved');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(6);
	  	else
			strTemp = WI.fillTextValue("contractor");
		%>	  	  
      <td>Contractor</td>
      <td> <font size="1"> 
        <input name="contractor" type="text" size="64" maxlength="128" 
				onFocus="style.backgroundColor='#D3EBFF';" onBlur="style.backgroundColor='white';"
				value="<%=WI.getStrValue(strTemp,"")%>">
        (optional) </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(9);
	  	else
			strTemp = WI.fillTextValue("cost_improve");
		%>
      <td>Cost of Improvement</td>
      <td> <font size="1"> 
        <input name="cost_improve" type="text" size="16" maxlength="16"
				onFocus="style.backgroundColor='#D3EBFF';"
		 onKeyUp="AllowOnlyIntegerExtn('form_','cost_improve','.')"
		 onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','cost_improve','.')" 
		 value="<%=CommonUtil.formatFloat(strTemp,true)%>">
        </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Salvage  Value</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(23);
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
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(12);
	  	else
			strTemp = WI.fillTextValue("asset_life");
		%>	  
      <td>Life</td>
      <td><input name="asset_life" type="text" size="8" maxlength="8" 
			onFocus="style.backgroundColor='#D3EBFF';" value="<%=WI.getStrValue(strTemp,"")%>"
			onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" 
		  onblur="style.backgroundColor='white';AllowOnlyInteger('form_','asset_life');"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(13);
	  	else
			strTemp = "";
	  %>	  
      <td>Remaining Asset Life</td>
      <td>&nbsp;<%=strTemp%></td>
    </tr>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(15);
	  	else
			strTemp = "";
	  %>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Yearly Depreciation</td>
      <td>&nbsp;<%=CommonUtil.formatFloat(strTemp,true)%></td>
    </tr>
  </table>
  <%}%>
  <%if(strAssetType.equals("0")){%>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="7%" height="25">&nbsp;</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(1);
	  	else
			strTemp = WI.fillTextValue("name");
	  %>	  	  
      <td width="21%" valign="middle">Building Name</td>
      <td width="72%"><input name="name" type="text" size="64" maxlength="128" 
			onFocus="style.backgroundColor='#D3EBFF';" onBlur="style.backgroundColor='white';"
			value="<%=WI.getStrValue(strTemp,"")%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(2);
	  	else
			strTemp = WI.fillTextValue("description");
	  %>	  	  	  	  
      <td>Description </td>
      <td><textarea name="description" cols="32" rows="3" onFocus="style.backgroundColor='#D3EBFF'" 
				onblur='style.backgroundColor="white"'><%=WI.getStrValue(strTemp,"")%></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(3);
	  	else
			strTemp = WI.fillTextValue("location");
	  %>	  
      <td>Location</td>
      <td><input name="location" type="text" size="64" maxlength="128" 
			onFocus="style.backgroundColor='#D3EBFF';" onBlur="style.backgroundColor='white';"
			value="<%=WI.getStrValue(strTemp,"")%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(5);
	  	else
			strTemp = WI.fillTextValue("date_construct");
	  %>	  
      <td>Date Constructed</td>
      <td><input name="date_construct" type="text" size="16" maxlength="16" 
			onFocus="style.backgroundColor='#D3EBFF';" onBlur="style.backgroundColor='white';"
			value="<%=WI.getStrValue(strTemp,"")%>" readonly> 
        <font size="1"><a href="javascript:show_calendar('form_.date_construct');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(11);
	  	else
			strTemp = WI.fillTextValue("contractor");
	  %>	  	  
      <td>Contractor</td>
      <td><font size="1">
        <input name="contractor" type="text" size="64" maxlength="128" 
				onFocus="style.backgroundColor='#D3EBFF';" onBlur="style.backgroundColor='white';"
				value="<%=WI.getStrValue(strTemp,"")%>">
      </font><font size="1">(optional) 
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(10);
	  	else
			strTemp = WI.fillTextValue("building_cost");
	  %>	  	  
      <td>Cost of Building</td>
      <td>
			<input name="building_cost" type="text" size="16" maxlength="16"
	     onKeyUp="AllowOnlyIntegerExtn('form_','building_cost','.')"
		   onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','building_cost','.')"  
			 onFocus="style.backgroundColor='#D3EBFF';" value="<%=CommonUtil.formatFloat(strTemp,true)%>">
			</td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Salvage Value </td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(23);
	  	else
			strTemp = WI.fillTextValue("salvage_value");
	  %>				
      <td><font size="1">
        <input name="salvage_value" type="text" size="16" maxlength="16"
		 onKeyUp="AllowOnlyIntegerExtn('form_','salvage_value','.')"
		 onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','salvage_value','.')" 
		 onFocus="style.backgroundColor='#D3EBFF';"value="<%=CommonUtil.formatFloat(strTemp,true)%>">
      </font></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(12);
	  	else
			strTemp = WI.fillTextValue("asset_life");
	  %>	  	  
      <td>Life</td>
      <td>
			<input name="asset_life" type="text" size="8" maxlength="8" 
			value="<%=WI.getStrValue(strTemp,"")%>"
			onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" 
			onFocus="style.backgroundColor='#D3EBFF';"
		  onblur="style.backgroundColor='white';AllowOnlyInteger('form_','asset_life');">      
		  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(13);
	  	else
			strTemp = "";
	  %>
      <td>Remaining Asset Life</td>
      <td>&nbsp;<%=strTemp%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(15);
	  	else
			strTemp = "";
	  %>	  	  	  
      <td>Yearly Depreciation</td>
      <td>&nbsp;<%=CommonUtil.formatFloat(strTemp,true)%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Fixed Asset Status</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(14);
			strTemp2 = " where pre_asset_index = " + strTemp;
	  	}else{
			strTemp = WI.fillTextValue("asset_status");
			strTemp2 = "";
		}
	  %>
      <td><select name="asset_status">
	       <%if(!bolEditMode){%>
		  <option value="">Select status</option>
		  <%}%>        
		  <%=dbOP.loadCombo("pre_asset_index","asset_name"," from INV_PRELOAD_FX_ASSET " + strTemp2 + " order by asset_name", strTemp, false)%> 
        </select>
		<%if(!bolEditMode){%>
        <font size="1">
		<a href='javascript:viewList("INV_PRELOAD_FX_ASSET","PRE_ASSET_INDEX","ASSET_NAME","FIXED ASSET LIST","INV_FIXED_ASSET","asset_status","","","asset_status")'><img src="../../../images/update.gif" border="0"></a></font>
		<%}else{%>
        <font size="1" color="#FF0000">*To update this field go to update fixed asset page</font> 
		<%}%>		</td>
    </tr>
  </table>
  <%}%>
  <%if(strAssetType.equals("1")){%>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="7%" height="25">&nbsp;</td>
      <td width="21%" valign="middle">Name/Description </td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(2);
	  	else
			strTemp = WI.fillTextValue("description");
	  %>	  		  
      <td width="72%">
			<textarea name="description" cols="32" rows="3" onFocus="style.backgroundColor='#D3EBFF'" 
				onblur='style.backgroundColor="white"'><%=WI.getStrValue(strTemp,"")%></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date of Improvement</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(6);
	  	else
			strTemp = WI.fillTextValue("date_improved");
	  %>	  
      <td><input name="date_improved" type="text" size="16" maxlength="16" 
			onFocus="style.backgroundColor='#D3EBFF';" onBlur="style.backgroundColor='white';"
			value="<%=WI.getStrValue(strTemp,"")%>" readonly> 
        <font size="1"><a href="javascript:show_calendar('form_.date_improved');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Cost of Improvement</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(9);
	  	else
			strTemp = WI.fillTextValue("cost_improve");
	  %>	  
      <td> <font size="1">
			<input name="cost_improve" type="text" size="16" maxlength="16"
			onKeyUp="AllowOnlyIntegerExtn('form_','cost_improve','.')"
		  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','cost_improve','.')"
			onFocus="style.backgroundColor='#D3EBFF';" value="<%=CommonUtil.formatFloat(strTemp,true)%>"> 
		   </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Contractor</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(11);
	  	else
			strTemp = WI.fillTextValue("contractor");
	  %>	  	  
      <td><input name="contractor" type="text" size="64" maxlength="128" 
			onFocus="style.backgroundColor='#D3EBFF';" onBlur="style.backgroundColor='white';"
			value="<%=WI.getStrValue(strTemp,"")%>"><font size="1">(optional)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Salvage Value </td>
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
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(12);
	  	else
			strTemp = WI.fillTextValue("asset_life");
	  %>	  	  
      <td><input name="asset_life" type="text" size="8" maxlength="8" 
			value="<%=WI.getStrValue(strTemp,"")%>" onFocus="style.backgroundColor='#D3EBFF';"
		  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" 
		  onblur="style.backgroundColor='white';AllowOnlyInteger('form_','asset_life');"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(13);
	  	else
			strTemp = "";
	  %>	  	  
      <td>Remaining Asset Life</td>
      <td>&nbsp;<%=strTemp%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(15);
	  	else
			strTemp = "";
	  %>	  	  	  
      <td>Yearly Depreciation</td>
      <td>&nbsp;<%=CommonUtil.formatFloat(strTemp,true)%></td>
    </tr>
  </table>
  <%}%>
  <%if(strAssetType.equals("4") && vEquipment != null && vEquipment.size() > 0){%>
  <table width="100%" border="0"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#99CCFF"> 
      <td height="25" colspan="9" align="center"><strong><font color="#FF0000">:: 
        LIST OF LOGGED EQUIPMENT ::</font></strong></td>
    </tr>

    <tr> 
      <td height="25" colspan="5" class="thinborderBOTTOM">&nbsp;</td>
      <td height="25" colspan="4" align="right" class="thinborderBOTTOM">
	  <%
		int iPageCount = iSearch/InvFAM.defSearchSize;
		double dTotalItems = 0d;
		double dTotalAmount = 0d;
		if(iSearch % InvFAM.defSearchSize > 0) ++iPageCount;				
		if(iPageCount > 1){%>
			&nbsp; 	            
          Jump to page:
            <select name="jumpto" onChange="ReloadPage();">
              <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
              <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
              <%}else{%>
              <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
              <%
				}
			}
		%>
            </select>
			<%}%>			</td>
    </tr>
    <tr> 
      <td width="6%" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td width="6%" height="29" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1">COUNT</font></strong></td>
      <td width="17%" align="center" valign="middle" class="thinborderBOTTOMLEFT"><strong><font size="1">ITEM 
        NAME</font></strong></td>
      <td width="10%" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1">BRAND NAME</font></strong></td>
      <td width="10%" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1">DATE ACQUIRED</font></strong></td>
      <td width="23%" height="29" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1">SUPPLIER / DONOR </font></strong></td>
      <td width="8%" align="center" valign="middle" class="thinborderBOTTOMLEFT"><strong><font size="1">QTY/UNIT</font></strong></td>
      <td width="10%" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1">UNIT COST</font></strong></td>
      <td width="10%" align="center" class="thinborderBOTTOMLEFTRIGHT"><strong><font size="1">ACQUISITION COST</font></strong></td>
    </tr>
    <%int iCount = 1;
	for (int i = 0;i< vEquipment.size(); i+=14,iCount++){%>
    <tr> 
      <td class="thinborderBOTTOMLEFT"><font size="1">
				<a href="javascript:EncodeEquipment('<%=(String)vEquipment.elementAt(i)%>');">
			<img src="../../../images/add.gif" border="0"></a></font></td>
      <td height="25" align="right" class="thinborderBOTTOMLEFT"><font size="1"><%=iCount%>&nbsp;</font></td>
      <td class="thinborderBOTTOMLEFT"><font size="1">&nbsp;<%=(String)vEquipment.elementAt(i+1)%><%=WI.getStrValue((String)vEquipment.elementAt(i+10)," (",")","")%></font></td>
      <td class="thinborderBOTTOMLEFT"><font size="1">&nbsp;<%=WI.getStrValue((String)vEquipment.elementAt(i+2),"")%></font></td>
			<%
				strTemp = (String)vEquipment.elementAt(i+13);
				if(strTemp == null)
					strTemp = (String)vEquipment.elementAt(i+3);
				
			%>
      <td class="thinborderBOTTOMLEFT"><font size="1">&nbsp;<%=strTemp%></font></td>
			<%if((String)vEquipment.elementAt(i+4) != null)
					strTemp = (String)vEquipment.elementAt(i+4);
				else if((String)vEquipment.elementAt(i+11) != null)
					strTemp = (String)vEquipment.elementAt(i+11);
				else
					strTemp = "";
			
			%>
      <td class="thinborderBOTTOMLEFT"><font size="1">&nbsp;<%=strTemp%></font></td>
      <td align="right" class="thinborderBOTTOMLEFT"><font size="1">&nbsp;<%=(String)vEquipment.elementAt(i+5)%>&nbsp;</font></td>
			<%
				strTemp = (String)vEquipment.elementAt(i+6);
				strTemp = CommonUtil.formatFloat(strTemp,true);
			%>
      <td align="right" class="thinborderBOTTOMLEFT"><font size="1">&nbsp;<%=strTemp%></font></td>
      <td align="right" class="thinborderBOTTOMLEFTRIGHT"><font size="1">&nbsp;<%=strTemp%></font></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <%if(!strAssetType.equals("4")){%>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="73%"><div align="center">
          <%if(strPrepareToEdit.compareTo("1") != 0) {%>
          <a href='javascript:PageAction(1, "");'> <img src="../../../images/save.gif" border="0" id="hide_save"></a><font size="1"> 
          click to save entries</font> 
          <%}else{%>
          <a href='javascript:PageAction(2,"");'> <img src="../../../images/edit.gif" border="0"></a><font size="1"> 
          click to save changes</font> 
          <%}%>
          <a href="./encode_fixed_asset.jsp?asset_type=<%=WI.fillTextValue("asset_type")%>"><img src="../../../images/cancel.gif" border="0"></a> 
          <font size="1"> click to 
          cancel or clear entries</font></div></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%}%>
  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="8" bgcolor="#B9B292"><div align="center">LIST OF ASSET(S) ENCODED</div></td>
    </tr>
	  <%
		int iPageCount = iSearch/InvFAM.defSearchSize;
		double dTotalItems = 0d;
		double dTotalAmount = 0d;
		if(iSearch % InvFAM.defSearchSize > 0) ++iPageCount;				
		if(iPageCount > 1){%>
    <tr> 
      <td height="25" colspan="8" class="thinborderBOTTOM"><div align="right">&nbsp; 	            
          Jump to page: 
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
				}
			}
		%>
          </select>
        </div></td>
    </tr>
	  <%}else{%>
	  <input type="hidden" name="jumpto" value="0">
	  <%}%>
    <tr> 
      <td width="21%" height="25" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>ASSET 
        DESCRIPTION</strong></font></td>
      <td width="13%" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>DATE 
        ACQUIRED/ IMPROVEMENT</strong></font></td>
      <td width="7%" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>COST</strong></font></td>
      <%if(!strAssetType.equals("2")){%>
      <td width="4%" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1">LIFE</font></strong></td>
      <td width="10%" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1">SALVAGE VALUE </font></strong></td>
      <td width="12%" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1"> YEARLY DEPRECIATION</font></strong></td>
      <%}%>
      <%if(strAssetType.equals("2") || strAssetType.equals("0")){%>
      <td width="18%" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>ASSET 
      STATUS</strong></font></td>
      <%}%>
      <td width="15%" align="center" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
    <%for(int i = 0;i < vRetResult.size(); i+=24){%>
    <tr> 
      <td height="25" class="thinborderBOTTOMLEFT"><%=WI.getStrValue((String) vRetResult.elementAt(i+1),"")%>&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2),"")%></td>
      <% 
			if(strAssetType.equals("0")){ // for building
				strTemp =  (String) vRetResult.elementAt(i+5);
				strTemp2 =  (String) vRetResult.elementAt(i+10);
			}else if(strAssetType.equals("1") || strAssetType.equals("3")){ // for improvements
				strTemp =  (String) vRetResult.elementAt(i+6);
				strTemp2 =  (String) vRetResult.elementAt(i+9);
			}else if(strAssetType.equals("2")){// for land
				strTemp = (String) vRetResult.elementAt(i+4);
				strTemp2 = (String) vRetResult.elementAt(i+7);
			}
		%>
      <td class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp2,true),"")%>&nbsp;</td>
      <%if(!strAssetType.equals("2")){%>
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue((String) vRetResult.elementAt(i+12),"")%></td>
      <%
		  	strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(i+23),true);
		  %>
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%></td>
      <%
		  	strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(i+15),true);
		  %>
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%></td>
      <%}%>
      <%if(strAssetType.equals("2") || strAssetType.equals("0")){%>
      <td align="center" class="thinborderBOTTOMLEFT"><%=(String) vRetResult.elementAt(i+18)%></td>
      <%}%>
      <td class="thinborderBOTTOMLEFTRIGHT"><div align="center"><a href="../../accounting/transaction/fixed_assets_depre_update_type.jsp" target="_self"> 
          <!--<img src="../../../images/view.gif" border="0">-->
          </a> <a href='javascript:PrepareToEdit("<%=WI.getStrValue((String)vRetResult.elementAt(i))%>");'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a> 
          <a href='javascript:PageAction(0,"<%=WI.getStrValue((String)vRetResult.elementAt(i))%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a></div></td>
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
	<input type="hidden" name="encode_equip">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>