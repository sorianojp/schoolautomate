<%@ page language="java" import="utility.*, inventory.InventoryLog, java.util.Vector"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script>
function ReloadPage()
{
	document.form_.executeSearch.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
</script>
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
								"INVENTORY-INVENTORY LOG","inv_borrow.jsp");

	InventoryLog InvLog = new InventoryLog();	
	Vector vRetResult = null;

	String[] astrAssetTypeName = {"Buildings","Building Improvements","Land","Land Improvements","Equipment"};

%>
<body bgcolor="#D2AE72">
<form>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          FIXED ASSETS MANAGEMENT - ENCODE ASSET PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="10%" height="25">&nbsp;</td>
      <td width="14%" height="25">Asset Type</td>
      <td width="76%" height="25">
	  <select name="asset_type" onChange="ReloadPage();">
		<%for(int i = 0;i<6;i++){
			
		%>
      	<option value="<%=i%>"><%=astrAssetTypeName[i]%></option>
		<%}%>
      </select></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">NOTE : Show this for EQUIPMENT Asset Type and 
        the Table below</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">Show Delivery for </td>
      <td height="25"><select name="select">
          <option>Specific Date</option>
          <option>Date Range</option>
          <option>Month</option>
          <option>Year</option>
        </select></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><input name="textfield" type="text" size="10" maxlength="10"> 
        <font size="1"><a href="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf/ADMIN_STAFF/accounting/transaction/petty_cash/petty_cash.htm"><img src="../../../images/calendar_new.gif" border="0"></a></font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">From 
        <input name="textfield32" type="text" size="10" maxlength="10"> <font size="1"><a href="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf/ADMIN_STAFF/accounting/transaction/petty_cash/petty_cash.htm"><img src="../../../images/calendar_new.gif" border="0"></a></font> 
        &nbsp;&nbsp;&nbsp;&nbsp;To 
        <input name="textfield4" type="text" size="10" maxlength="10"> <font size="1"><a href="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf/ADMIN_STAFF/accounting/transaction/petty_cash/petty_cash.htm"><img src="../../../images/calendar_new.gif" border="0"></a></font> 
      </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><select name="select4">
          <option>January</option>
          <option>February</option>
          <option>March</option>
          <option>April</option>
          <option>May</option>
          <option>June</option>
          <option>July</option>
          <option>August</option>
          <option>September</option>
          <option>October</option>
          <option>November</option>
          <option>December</option>
        </select></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><select name="select11">
          <option>2007</option>
          <option>2006</option>
          <option>2005</option>
          <option>2004</option>
        </select></td>
    </tr>
  </table>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">NOTE: Show this table for LAND Asset Type</td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="16%" valign="middle">Name/Description </td>
      <td width="80%"><textarea name="textarea" cols="32" rows="3"></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date Acquired</td>
      <td><input name="textfield22" type="text" size="16" maxlength="16"> <font size="1"><a href="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf/ADMIN_STAFF/accounting/transaction/fixed_assets_depre_update_type.jsp" target="_self"><img src="../../../images/calendar_new.gif" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Purchased Value</td>
      <td> <input name="textfield2" type="text" size="16" maxlength="16"> <font size="1">&nbsp;(optional) 
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Purchased From</td>
      <td><input name="textfield23" type="text" size="32" maxlength="64"> <font size="1">(optional) 
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Current Assessed Value</td>
      <td><input name="textfield3" type="text" size="16" maxlength="16"> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date Last Assessed</td>
      <td><input name="textfield222" type="text" size="16" maxlength="16"> <font size="1"><a href="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf/ADMIN_STAFF/accounting/transaction/fixed_assets_depre_update_type.jsp" target="_self"><img src="../../../images/calendar_new.gif" border="0"></a></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Fixed Asset Status</td>
      <td><select name="select3">
          <option>Current</option>
          <option>Donated</option>
        </select></td>
    </tr>
  </table>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">NOTE: Show this table for LAND IMPROVEMENTS 
        Asset Type</td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="16%" valign="middle">Name/Description </td>
      <td width="80%"><textarea name="textarea" cols="32" rows="3"></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date of Improvement</td>
      <td><input name="textfield22" type="text" size="16" maxlength="16"> <font size="1"><a href="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf/ADMIN_STAFF/accounting/transaction/fixed_assets_depre_update_type.jsp" target="_self"><img src="../../../images/calendar_new.gif" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Contractor</td>
      <td> <font size="1"> 
        <input name="textfield234" type="text" size="64" maxlength="128">
        (optional) </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Cost of Improvement</td>
      <td> <font size="1"> 
        <input name="textfield25" type="text" size="16" maxlength="16">
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Life</td>
      <td><input name="textfield5" type="text" size="8" maxlength="8"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Remaining Asset Life</td>
      <td>$date_cons-current_date</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Yearly Depreciation</td>
      <td><strong>$yr_dep</strong> ( cost of improvement/life) (Note: if life 
        is 0, then set yearly depreciation to 1)</td>
    </tr>
  </table>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">NOTE: Show this table for BUILDINGS Asset Type</td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="16%" valign="middle">Building Name</td>
      <td width="80%"><input name="textfield232" type="text" size="64" maxlength="128"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Description </td>
      <td><textarea name="textarea2" cols="32" rows="3"></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Location</td>
      <td><input name="textfield2322" type="text" size="64" maxlength="128"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date Constructed</td>
      <td><input name="textfield22" type="text" size="16" maxlength="16"> <font size="1"><a href="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf/ADMIN_STAFF/accounting/transaction/fixed_assets_depre_update_type.jsp" target="_self"><img src="../../../images/calendar_new.gif" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Contractor</td>
      <td><input name="textfield23" type="text" size="64" maxlength="128"> <font size="1">(optional) 
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Cost of Building <br> </td>
      <td><input name="textfield52" type="text" size="16" maxlength="16"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Life</td>
      <td><input name="textfield5" type="text" size="8" maxlength="8"> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Remaining Asset Life</td>
      <td>$date_cons-current_date</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Yearly Depreciation</td>
      <td><strong>$yr_dep</strong> ( current cost of building/life) (Note: if 
        life is 0, then set yearly depreciation to 1)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Fixed Asset Status</td>
      <td><select name="select5">
          <option>Current</option>
          <option>Donated</option>
          <option>Abandoned</option>
        </select></td>
    </tr>
  </table>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">NOTE: Show this table for BUILDINGS IMPROVEMENTS 
        Asset Type</td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="16%" valign="middle">Name/Description </td>
      <td width="80%"><textarea name="textarea3" cols="32" rows="3"></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date of Improvement</td>
      <td><input name="textfield224" type="text" size="16" maxlength="16"> <font size="1"><a href="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf/ADMIN_STAFF/accounting/transaction/fixed_assets_depre_update_type.jsp" target="_self"><img src="../../../images/calendar_new.gif" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Cost of Improvement</td>
      <td> <input name="textfield24" type="text" size="16" maxlength="16"> <font size="1">&nbsp;</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Contractor</td>
      <td><input name="textfield233" type="text" size="64" maxlength="128"> <font size="1">(optional) 
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Cost of Improvement</td>
      <td> <input name="textfield2" type="text" size="16" maxlength="16"> <font size="1">&nbsp;</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Life</td>
      <td><input name="textfield5" type="text" size="8" maxlength="8"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Remaining Asset Life</td>
      <td>$date_cons-current_date</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Yearly Depreciation</td>
      <td><strong>$yr_dep</strong> ( cost of improvement/life) (Note: if life 
        is 0, then set yearly depreciation to 1)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="1"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#99CCFF"> 
      <td height="25" colspan="9"><div align="center"><strong><font color="#FF0000">:: 
          LIST OF EQUIPMENT PURCHASED AND DELIVERED - $SPECIFIC DATE/$DATE_RANGE/$MONTH/YEAR 
          ::</font></strong></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="5"><font size="1"><strong>TOTAL ITEM(S) : $total</strong></font></td>
      <td height="25" colspan="4">NOTE : Click ADD button to record to Fixed Asset</td>
    </tr>
    <tr> 
      <td width="5%">&nbsp;</td>
      <td width="6%" height="25"><div align="center"><strong><font size="1">COUNT</font></strong></div></td>
      <td width="8%" valign="middle"><div align="center"><strong><font size="1">ITEM 
          NAME</font></strong></div></td>
      <td width="16%"><div align="center"><strong><font size="1">BRAND NAME</font></strong></div></td>
      <td width="10%"><div align="center"><strong><font size="1">DATE ACQUIRED</font></strong></div></td>
      <td width="21%" height="25"><div align="center"><strong><font size="1">SUPPLIER</font></strong></div></td>
      <td width="9%" valign="middle"><div align="center"><strong><font size="1">QTY/UNIT</font></strong></div></td>
      <td width="11%"><div align="center"><strong><font size="1">UNIT COST</font></strong></div></td>
      <td width="14%"><div align="center"><strong><font size="1">ACQUISITION COST</font></strong></div></td>
    </tr>
    <tr> 
      <td><font size="1"><a href="encode_fixed_asset_equipment.htm" target="_self"><img src="../../../images/add.gif" border="0"></a></font></td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="73%"><div align="center"><font size="1"><a href="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf/ADMIN_STAFF/accounting/transaction/fixed_assets_depre_update_type.jsp" target="_self"><img src="../../../images/save.gif" border="0"></a>click 
          to save entries&nbsp;&nbsp;&nbsp; <a href="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf/ADMIN_STAFF/accounting/transaction/fixed_assets_depre_update_type.jsp" target="_self"><img src="../../../images/cancel.gif" border="0"></a>click 
          to cancel/clear entries</font></div></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="1"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="8" bgcolor="#B9B292"><div align="center">LIST OF 
          ASSET(S) ENCODED TODAY (MM/DD/YYYY)</div></td>
    </tr>
    <tr> 
      <td width="11%" height="25"><div align="center"><font size="1"><strong> 
          ASSET TYPE</strong></font></div></td>
      <td width="31%"><div align="center"><font size="1"><strong>ASSET DESCRIPTION</strong></font></div></td>
      <td width="12%"><div align="center"><font size="1"><strong>DATE ACQUIRED/ 
          IMPROVEMENT</strong></font></div></td>
      <td width="14%"><div align="center"><font size="1"><strong>COST</strong></font></div></td>
      <td width="4%"><div align="center"><strong><font size="1">LIFE</font></strong></div></td>
      <td width="8%"><div align="center"><strong><font size="1">DEPRECIATION</font></strong></div></td>
      <td width="8%"><div align="center"><font size="1"><strong>ASSET STATUS</strong></font></div></td>
      <td width="12%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><font size="1">Buildings</font></td>
      <td><font size="1">Hospital with 4 floors</font></td>
      <td><font size="1">09/14/2004</font></td>
      <td><font size="1">11,123,456.78</font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><font size="1">CURRENT</font></td>
      <td><font size="1"><a href="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf/ADMIN_STAFF/accounting/transaction/fixed_assets_depre_update_type.jsp" target="_self"><img src="../../../images/view.gif" border="0"></a><a href="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf/ADMIN_STAFF/accounting/transaction/fixed_assets_depre_update_type.jsp" target="_self"><img src="../../../images/edit.gif" border="0"></a><a href="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf/ADMIN_STAFF/accounting/transaction/fixed_assets_depre_update_type.jsp" target="_self"><img src="../../../images/delete.gif" border="0"></a></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="22">&nbsp;</td>
      <td colspan="4" height="22">&nbsp;</td>
      <td height="22" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="4" height="25"><div align="left"><font size="1"><a href="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf/ADMIN_STAFF/fee_assess_pay/reports/statement_of_account_print.htm" target="_blank"><img src="file:///D|/ApacheTomcat4.1.31/webapps/schoolbliz_vmuf/images/print.gif" width="58" height="26" border="0"></a><font size="1">click
          to print list of assets</font></font></div></td>
      <td width="1%" height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>