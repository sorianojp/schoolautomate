<%@ page language="java" import="utility.*,inventory.InventorySetting,java.util.Vector" %>
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
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}

function CancelRecord(){
  document.form_.cancelClicked.value = "1";
	document.form_.proceedClicked.value = "1";
	document.form_.pageAction.value = "";
	document.form_.strIndex.value = "";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}

function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}

function ReloadPage(){
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}

function ChangeType(){
	document.form_.printPage.value = "";
	document.form_.cat_index.value = "";
	document.form_.class_index.value = "";	
	document.form_.brand.value = "";	
	this.SubmitOnce('form_');
}

</script>
<body bgcolor="#D2AE72">
<%if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="item_reorder_point_print.jsp"/>
	<%return;}
	
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-INVENTORY SETTING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-MASTERLIST"),"0"));
		}
	}

	if(WI.fillTextValue("my_home").equals("1"))
		iAccessLevel = 2 ;
	
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
								"Admin/staff-PURCHASING-InventorySetting-InventorySetting Items","item_reorder_point.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.

	InventorySetting InvSetting = new InventorySetting();	
	Vector vRetResult = null;
	String[] astrSupplyType = {"Non-Supplies / Equipmment","Supplies","Chemical","Computers/Parts"};	
	String[] astrSortByName    = {"Item Name","Item Code", "Reorder point"};
	String[] astrSortByVal     = {"item_name","item_code", "reorder_point"};
	int iDefault = 0;
	String strSupply = WI.getStrValue(WI.fillTextValue("is_supply"),"0");
	String strClass = WI.fillTextValue("class_index");
	String strCategory = WI.fillTextValue("cat_index");	String strItem = null;
	String strChecked = null;
	int iSearchResult = 0;
	int i = 0;
	if(WI.fillTextValue("proceedClicked").length() > 0){
		vRetResult = InvSetting.getBelowReorderPoint(dbOP,request);
		if(vRetResult  == null)
			strErrMsg = InvSetting.getErrMsg();
		else
			iSearchResult = InvSetting.getSearchCount();
	}
	
%>
<form name="form_" method="post" action="./item_reorder_point.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">    
	<tr bgcolor="#A49A6A">
      <td height="25" align="center"><font color="#FFFFFF"><strong>:::: 
     ITEMS REACHING REORDER POINT PAGE ::::</strong></font></td>
    </tr>	  
  
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td  height="25" colspan="3"><hr size="1"> </td>
    </tr>

    <tr>
      <td height="26">&nbsp;</td>
      <td valign="bottom">Department</td>
      <td colspan="3">
			<select name="d_index" onChange="ReloadPage();">
				<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 " +
				" and (c_index = 0 or c_index is null) and is_central_office > 0 ", WI.fillTextValue("d_index"),false)%>
      </select></td>
    </tr>
    <tr>
      <td width="3%" height="26">&nbsp;</td>
      <td width="22%" valign="bottom">Inventory Type</td>
      <td colspan="3"><select name="is_supply" onChange="ChangeType();">
          <option value="0"><%=astrSupplyType[0]%></option>
		<%for(i = 1; i < 4; i++){%>
          <%if(strSupply.equals(Integer.toString(i))){%>
          <option value="<%=i%>" selected><%=astrSupplyType[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrSupplyType[i]%></option>
          <%}%>
		<%}%>
      </select></td>
    </tr>

	
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="bottom"> Item Category</td>
			<%
				strCategory = WI.fillTextValue("cat_index");
			%>
      <td valign="bottom"><select name="cat_index" onChange="ReloadPage();">
				<option value="">Select Category</option>
        <%=dbOP.loadCombo("inv_cat_index","inv_category"," from inv_preload_category " +
		  					"where is_supply_cat = " + strSupply + "order by inv_category", strCategory, false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="bottom">Item Classification </td>
      <td valign="bottom"><select name="class_index" onChange="ReloadPage();">
          <option value="">Select Class</option>
          <%=dbOP.loadCombo("inv_class_index","classification"," from inv_preload_class " +
		  					" where inv_cat_index = " + WI.getStrValue(strCategory,"-1") + 
								" order by classification", strClass, false)%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="bottom">Item :</td>
			<%
				strTemp = WI.fillTextValue("item_index");
			%>
      <td width="75%" valign="bottom"><select name="item_index" onChange="ReloadPage();">
          <option value="">Select Item</option>
          <%=dbOP.loadCombo("item_index","item_name"," from pur_preload_item " +
		  " where inv_cat_index =" + WI.getStrValue(strCategory,"-1") +
		  " and exists(select * from inv_reg_item where PUR_PRELOAD_ITEM.ITEM_INDEX = ITEM_INDEX)" +
		  WI.getStrValue(strClass," and inv_class_index = ","","") +
		  " order by ITEM_NAME asc",strTemp, false)%> 
 	  </select> 
	  <!--
	  <a href="javascript:UpdateItem()";> 
	  <img src="../../../images/update.gif" width="60" height="25" border="0">
	  </a> 
	  --></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="bottom">Brand:</td>
      <td><select name="brand">
          <option value="">Select brand</option>
          <%=dbOP.loadCombo("BRAND_INDEX","BRAND_NAME"," from PUR_PRELOAD_BRAND " +
														" where inv_cat_index = " + WI.getStrValue(strCategory,"-1") +
														" order by BRAND_NAME asc", strTemp, false)%> 
			 </select>			 </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				if(WI.fillTextValue("view_all").length() > 0)
					strChecked = " checked";
				else
					strChecked = "";
			%>
      <td valign="bottom"><input type="checkbox" name="view_all" value="1" <%=strChecked%>>
View All </td>
      <td>&nbsp;</td>
    </tr>
  </table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		
		<tr> 
			<td  width="3%" height="25">&nbsp;</td>
			<td width="10%">Sort by</td>
			<td width="25%">
		<select name="sort_by1">
		<option value="">N/A</option>
					<%=InvSetting.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
			</select></td>
			<td width="25%"><select name="sort_by2">
		<option value="">N/A</option>
					<%=InvSetting.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
				</select></td>
			<td width="36%"><select name="sort_by3">
		<option value="">N/A</option>
					<%=InvSetting.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
				</select> 
				<br/></td>
			<td width="1%">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td>&nbsp;</td>
			<td><select name="sort_by1_con">
				<option value="asc">Ascending</option>
				<% if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
				<option value="desc" selected>Descending</option>
				<%}else{%>
				<option value="desc">Descending</option>
				<%}%>
			</select></td>
			<td><select name="sort_by2_con">
				<option value="asc">Ascending</option>
				<% if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
				<option value="desc" selected>Descending</option>
				<%}else{%>
				<option value="desc">Descending</option>
				<%}%>
			</select></td>
			<td><select name="sort_by3_con">
				<option value="asc">Ascending</option>
				<% if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
				<option value="desc" selected>Descending</option>
				<%}else{%>
				<option value="desc">Descending</option>
				<%}%>
			</select></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="19">&nbsp;</td>
			<td>&nbsp;</td>
			<td colspan="2">&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td>&nbsp;</td>
			<td colspan="2"><font size="1">
				<input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ProceedClicked();">
			</font></td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="18">&nbsp;</td>
			<td>&nbsp;</td>
			<td colspan="2"><strong><font size="2">
				<input type="text" name="area2" readonly="yes" size="2" style="background-color:#FFFFFF;border-width: 0px;">
			</font></strong></td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
	</table>	
	<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="84%" height="29"><div align="right"> 
          <font size="1">Items per page</font> 
          <select name="num_rows">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rows"),"15"));
				for(i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select> 
          <a href="javascript:PrintPage();"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print list of items </font> 
      </div></td>
    </tr>
    <tr> 
      <td height="10" align="right"><span class="thinborderBOTTOM">
      <%
		if(WI.fillTextValue("view_all").length() == 0){
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/InvSetting.defSearchSize;
		if(iSearchResult % InvSetting.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1){%>
Page
<select name="jumpto" onChange="ProceedClicked();" style="font-size:11px">
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
<%} //if no pages 
				}// %>
      </span></td>
    </tr>
  </table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	  <tr>
      	<td height="25" align="center" bgcolor="#B9B292"  colspan="5" class="thinborderTOPLEFTRIGHT"><font color="#FFFFFF"><strong>LIST OF  ITEMS BELOW REORDER POINT </strong></font></td>
	  </tr>    
    <tr>
      <td width="4%" align="center" class="thinborder">&nbsp;</td> 
      <td width="10%" align="center" class="thinborder">ITEM CODE  </td>
      <td width="14%" height="25" align="center" class="thinborder">AVAILABLE QTY</td>
      <td width="55%" align="center" class="thinborder">PARTICULARS/ITEM DESCRIPTION </td>
      <td width="17%" align="center" class="thinborder">Reorder point </td>
    </tr>
    <% int iCountItem = 1;
	for(int iLoop = 0;iLoop < vRetResult.size();iLoop+=14,iCountItem++){%>
	<tr>
	  <td align="right" class="thinborder"><%=iCountItem%></td> 
      <td class="thinborder"><%=vRetResult.elementAt(iLoop+1)%>&nbsp;</td>
			<%
				
				strTemp = (String)vRetResult.elementAt(iLoop+12);
				strTemp = ConversionTable.replaceString(strTemp,",","");
				if(Double.parseDouble(strTemp) == 0d)
					strTemp = "";
				else
					strTemp = WI.getStrValue(strTemp,"","&nbsp;" +(String)vRetResult.elementAt(iLoop+3),"");
			%>
      <td height="25" align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(iLoop+2)%><%=WI.getStrValue((String)vRetResult.elementAt(iLoop+5))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(iLoop+9), "","&nbsp;" +(String)vRetResult.elementAt(iLoop+3),"")%></td>
	</tr>
	<%} // end for loop%>
	<input type="hidden" name="item_count" value="<%=iCountItem%>">
    <tr> 
      <td class="thinborder" height="25" colspan="5">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
	<%}%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">   
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!--
  <input type="hidden" name="is_supply" value="<%=strSupply%>">
  -->
  <input type="hidden" name="proceedClicked" value="">
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="cancelClicked" value="">
  <input type="hidden" name="strIndex" value="<%=WI.fillTextValue("strIndex")%>">
  <input type="hidden" name="printPage" value=""> 
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>"> 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>