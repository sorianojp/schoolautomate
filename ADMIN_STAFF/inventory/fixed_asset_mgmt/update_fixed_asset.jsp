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
	document.form_.focus_area.value = "";
	document.form_.info_index.value = "";
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

function PrepareToUpdate(strInfoIndex) {
	document.form_.focus_area.value = "2";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}

function PageLoad(){
	var pageNo = "";
	pageNo = <%=WI.getStrValue(WI.fillTextValue("focus_area"),"1")%>
	if(eval('document.form_.area'+pageNo))
		eval('document.form_.area'+pageNo+'.focus()');
	else
		document.form_.area.focus();
}
</script>
</head>
<%
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
							"INVENTORY-INVENTORY LOG","update_fixed_asset.jsp");
		
	InvFixedAssetMngt InvFAM = new InvFixedAssetMngt();	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	Vector vEquipment = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strAssetType = WI.getStrValue(WI.fillTextValue("asset_type"),"0");
	String strPageAction = WI.fillTextValue("page_action");
	int iSearch = 0;
	int i = 0;
	
	if(strPageAction.length() > 0){
	  if(InvFAM.operateOnFixedAsset(dbOP,request,5) == null){
		strErrMsg = InvFAM.getErrMsg();
	  }
	}	
	if(WI.fillTextValue("info_index").length() > 0){
		vEditInfo = InvFAM.operateOnFixedAsset(dbOP,request,3);
		  if(vEditInfo== null)
		    strErrMsg = InvFAM.getErrMsg();
	}	
	
	vRetResult = InvFAM.operateOnFixedAsset(dbOP,request,4);

	if(vRetResult == null)
	  strErrMsg = InvFAM.getErrMsg();
	else
	  iSearch = InvFAM.getSearchCount();
%>
<body bgcolor="#D2AE72" onLoad="javascript:PageLoad();">
<form name="form_" action="./update_fixed_asset.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          FIXED ASSETS MANAGEMENT - UPDATE ASSET (LANDS/BUILDINGS) PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3" style="font-size:13px; color:#FF0000; font-weight:bold">&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="10%" height="25">&nbsp;</td>
      <td width="14%" height="25">Asset Type</td>
      <td width="76%" height="25"> 
	  <%if(vRetResult != null && vRetResult.size() > 0)
	  		strTemp = "resetPage();";
		else
			strTemp = "ReloadPage();";
	  %>
	    <select name="asset_type" onChange="<%=strTemp%>">
          <option value="0">Buildings</option>
          <%if(strAssetType.equals("2")){%>
          <option value="2" selected>Land</option>
          <%}else{%>
          <option value="2">Land</option>
          <%}%>
        </select>
	    <input type="text" name="area" readonly size="2" 
			style="background-color:#FFFFFF;border-width: 0px;"></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%
  if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
  <%	
	if(strAssetType.equals("0")){
		strTemp= "Buildings";		
	}else{
		strTemp = "Land";
	}
  %>
    <tr> 
      <td height="25" colspan="9" bgcolor="#C0BB9C"><div align="center"><font color="#000000"><strong>:: 
          LIST OF <%=strTemp%> ::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4" class="thinborderBOTTOM">&nbsp;</td>
      <%
		int iPageCount = iSearch/InvFAM.defSearchSize;
		double dTotalItems = 0d;
		double dTotalAmount = 0d;
		if(iSearch % InvFAM.defSearchSize > 0) ++iPageCount;				
	  %>
      <td width="35%" colspan="5" class="thinborderBOTTOM"> <div align="right">&nbsp; 
          <%if(iPageCount > 1){%>
          Jump to page: 
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
            <%
				}
			}
		%>
          </select>
          <%}else{%>
		  	<input type="hidden" name="jumpto" value="0">
		  <%}%>
        </div></td>
    </tr>
	</table>
	<%if(strAssetType.equals("0")){%>
	<table width="100%" border="0"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="9%" height="25" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td width="25%" class="thinborderBOTTOMLEFT"><div align="center"><font size="1"><strong>ASSET DESCRIPTION</strong></font></div></td>
      <td width="13%" class="thinborderBOTTOMLEFT"><div align="center"><font size="1"><strong>DATE CONSTRUCTED</strong></font></div></td>
      <td width="10%" class="thinborderBOTTOMLEFT"><div align="center"><font size="1"><strong>VALUE</strong></font></div></td>
      <td width="8%" class="thinborderBOTTOMLEFT"><div align="center"><strong><font size="1">CURRENT LIFE</font></strong></div></td>
      <td width="11%" class="thinborderBOTTOMLEFT"><div align="center"><strong><font size="1">DEPRECIATION</font></strong></div></td>
      <td width="9%" class="thinborderBOTTOMLEFT"><div align="center"><font size="1"><strong>CURRENT VALUE</strong></font></div></td>
      <td width="7%" class="thinborderBOTTOMLEFT"><div align="center"><strong><font size="1">LAST UPDATED</font></strong></div></td>
      <td width="8%" class="thinborderBOTTOMLEFTRIGHT"><div align="center"><font size="1"><strong>ASSET STATUS</strong></font></div></td>
    </tr>
    <%for(i = 0;i < vRetResult.size(); i+=24){%>
    <tr> 
      <td height="25" class="thinborderBOTTOMLEFT"><font size="1"><a href='javascript:PrepareToUpdate("<%=WI.getStrValue((String)vRetResult.elementAt(i))%>");'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
      <td class="thinborderBOTTOMLEFT"><%=WI.getStrValue((String) vRetResult.elementAt(i+1),"")%>&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2),"")%></td>
      <% 
		if(strAssetType.equals("0")){ // for building
			strTemp =  (String) vRetResult.elementAt(i+5);
			strTemp2 =  (String) vRetResult.elementAt(i+10);
		}
	  %>
      <td class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <td class="thinborderBOTTOMLEFT"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp2,true),"")%>&nbsp;</div></td>
      <td class="thinborderBOTTOMLEFT"><div align="right">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+13),"")%>&nbsp;</div></td>
      <%
	  	strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+15),true);
	  %>
      <td class="thinborderBOTTOMLEFT"><div align="right">&nbsp;<%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
      <%
	  	strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+21),true);
	  %>
      <td class="thinborderBOTTOMLEFT"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+22);
	  %>
      <td class="thinborderBOTTOMLEFT"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
      <td class="thinborderBOTTOMLEFTRIGHT"><div align="center"><%=(String)vRetResult.elementAt(i+18)%></div></td>
    </tr>
    <%}%>
  </table>
  <%}else{%>
	
  <table width="100%" border="0"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="9%" height="25" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td width="25%" class="thinborderBOTTOMLEFT"><div align="center"><font size="1"><strong>ASSET DESCRIPTION</strong></font></div></td>
      <td width="14%" class="thinborderBOTTOMLEFT"><div align="center"><font size="1"><strong>DATE ACQUIRED</strong></font></div></td>
      <td width="11%" class="thinborderBOTTOMLEFT"><div align="center"><font size="1"><strong>PURCHASE VALUE</strong></font></div></td>
      <td width="14%" class="thinborderBOTTOMLEFT"><div align="center"><font size="1"><strong>CURRENT ASSESSED 
      VALUE</strong></font></div></td>
      <td width="12%" class="thinborderBOTTOMLEFT"><div align="center"><strong><font size="1">LAST ASSESSED</font></strong></div></td>
      <td width="15%" class="thinborderBOTTOMLEFTRIGHT"><div align="center"><font size="1"><strong>ASSET STATUS</strong></font></div></td>
    </tr>
    <%for(i = 0;i < vRetResult.size(); i+=24){%>
    <tr> 
      <td height="25" class="thinborderBOTTOMLEFT"><font size="1"><a href='javascript:PrepareToUpdate("<%=WI.getStrValue((String)vRetResult.elementAt(i))%>");'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
      <td class="thinborderBOTTOMLEFT"><%=WI.getStrValue((String) vRetResult.elementAt(i+1),"")%>&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2),"")%></td>
      <% 
			if(strAssetType.equals("2")){// for land
				strTemp = (String) vRetResult.elementAt(i+4);
				strTemp2 = (String) vRetResult.elementAt(i+7);
			}
	  %>
      <td class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <%
	  	strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(i+7),true);
	  %>	  
      <td class="thinborderBOTTOMLEFT"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
      <%
	  	strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(i+16),true);
	  %>
      <td class="thinborderBOTTOMLEFT"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(17);
	  %>
      <td class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <td class="thinborderBOTTOMLEFTRIGHT"><div align="center"><%=(String) vRetResult.elementAt(i+18)%></div></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <%if (vEditInfo != null && vEditInfo.size() > 0){%>
  <%if(strAssetType.equals("2")){%>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <%
	  		if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(2);
	    %>
      <td valign="middle">&nbsp;Name/Description </td>
      <td colspan="3" valign="middle"><strong>&nbsp;<%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="18%">&nbsp;Date Acquired</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(4);
	  %>
      <td width="33%"><strong>&nbsp;<%=WI.getStrValue(strTemp,"")%></strong></td>
      <td width="25%">&nbsp;Current Assessed Value</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(16);
	  %>
      <td width="20%"><strong>&nbsp;<%=CommonUtil.formatFloat(strTemp,true)%> </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;Purchased Value</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(7);
	  %>
      <td><strong>&nbsp;<%=WI.getStrValue(strTemp,"")%></strong></td>
      <td>&nbsp;Date Last Assessed</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(17);
	  %>
      <td><strong>&nbsp;<%=WI.getStrValue(strTemp,"")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;Purchased From</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(8);
	  %>
      <td><strong>&nbsp;<%=WI.getStrValue(strTemp,"")%></strong></td>
      <td>&nbsp;Current Asset Status</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(18);
		%>
      <td><strong>&nbsp;<%=WI.getStrValue(strTemp,"")%></strong></td>
    </tr>
  </table>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C0BB9C"> 
      <td height="18" colspan="5"><div align="center"><strong><font color="#000000">:: 
          UPDATE ::</font></strong></div></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="21%"> Assessed Value</td>
      <td colspan="3"> <%
		   	strTemp = WI.fillTextValue("cur_assessed_value");
		   %> <input name="cur_assessed_value" type="text" size="16" maxlength="16"
	  	   onKeyUp="AllowOnlyIntegerExtn('form_','cur_assessed_value','.')"
		   onBlur="AllowOnlyIntegerExtn('form_','cur_assessed_value','.')" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td> Asset Status</td>
      <td colspan="3"><select name="asset_status">
          <option value="">Select status</option>
          <%=dbOP.loadCombo("pre_asset_index","asset_name"," from INV_PRELOAD_FX_ASSET order by asset_name", strTemp, false)%> </select> <font size="1"><a href='javascript:viewList("INV_PRELOAD_FX_ASSET","PRE_ASSET_INDEX","ASSET_NAME","FIXED ASSET LIST","INV_FIXED_ASSET","asset_status","","","asset_status")'><img src="../../../images/update.gif" border="0"></a></font></td>
    </tr>	
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date Assessed</td>
      <%	  	
	  	strTemp = WI.fillTextValue("date_last_assessed");
		if(strTemp.length() == 0)
			strTemp = WI.getTodaysDate(1);
	  %>
      <td colspan="3"><input name="date_last_assessed" type="text" size="16" maxlength="16" value="<%=strTemp%>" readonly> 
        <font size="1"><a href="javascript:show_calendar('form_.date_last_assessed');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></td>
    </tr>
  </table>
  <%}else{%>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="middle">Building Name</td>
      <%
	  		if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(1);
	    %>
      <td colspan="3" valign="middle">&nbsp;<strong><%=WI.getStrValue(strTemp,"")%></strong></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(2);
		  %>
      <td valign="middle">Description</td>
      <td colspan="3" valign="middle">&nbsp;<strong><%=WI.getStrValue(strTemp,"")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Location</td>
      <%			
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(3);
	  %>
      <td><strong>&nbsp;<%=WI.getStrValue(strTemp,"")%></strong></td>
      <td width="23%">Life</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(12);
	  %>
      <td width="31%"><strong>&nbsp;<%=WI.getStrValue(strTemp,""," yrs.","")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="19%">Date Constructed</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(5);
	  %>
      <td width="24%"><strong>&nbsp;<%=strTemp%></strong></td>
      <td>Yearly Depreciation</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(15);
	  %>
      <td><strong>&nbsp;<%=CommonUtil.formatFloat(strTemp,true)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Contractor</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(11);
	  %>
      <td><strong>&nbsp;<%=WI.getStrValue(strTemp,"")%></strong></td>
      <td>Current Asset Status</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(18);
	  %>
      <td><strong>&nbsp;<%=WI.getStrValue(strTemp,"")%> 
        <input type="hidden" name="current_status" value="<%=(String) vEditInfo.elementAt(14)%>">
        </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Cost of Building</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(10);
	  %>
      <td><strong>&nbsp;<%=CommonUtil.formatFloat(strTemp,true)%></strong></td>
      <td>Status Last Updated</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(20);
	  %>
      <td><strong>&nbsp;<%=WI.getStrValue(strTemp,"")%></strong></td>
    </tr>
  </table>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C0BB9C"> 
      <td height="18" colspan="5"><div align="center"><strong><font color="#000000">:: 
          UPDATE ::</font></strong></div></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="25%"> Asset Status</td>
      <td colspan="3"> <%
	  	strTemp = WI.fillTextValue("asset_status");
	  %> <select name="asset_status">
          <option value="">Select status</option>
          <%=dbOP.loadCombo("pre_asset_index","asset_name"," from INV_PRELOAD_FX_ASSET order by asset_name", strTemp, false)%> </select> <font size="1"><a href='javascript:viewList("INV_PRELOAD_FX_ASSET","PRE_ASSET_INDEX","ASSET_NAME","FIXED ASSET LIST","INV_FIXED_ASSET","asset_status","","","asset_status")'><img src="../../../images/update.gif" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date Status Updated</td>
      <%
	  	strTemp = WI.fillTextValue("date_last_assessed");
		if(strTemp.length() == 0)
		  strTemp = WI.getTodaysDate(1);
	  %>
      <td colspan="3"><input name="date_last_assessed" type="text" size="16" maxlength="16" value="<%=strTemp%>" readonly> 
        <font size="1"><a href="javascript:show_calendar('form_.date_last_assessed');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></td>
    </tr>
  </table>
  <%}%>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="73%"><div align="center"><font size="1"><a href='javascript:PageAction(5, "");'><img src="../../../images/save.gif" border="0" id="hide_save"></a>click 
          to save entries&nbsp;&nbsp;&nbsp; <a href="./update_fixed_asset.jsp?asset_type=<%=WI.fillTextValue("asset_type")%>"><img src="../../../images/cancel.gif" border="0"></a>click 
          to cancel/clear entries</font>
          <input type="text" name="area2" readonly size="2" 
			style="background-color:#FFFFFF;border-width: 0px;">
      </div></td>
    </tr>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <%} // end if vRetResult != null%>
    <input type="hidden" name="page_action">
   	<input type="hidden" name="print_pg">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="focus_area" value="<%=WI.fillTextValue("focus_area")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>