<%@ page language="java" import="utility.*, inventory.InventorySearch, java.util.Vector"%>
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
<script language="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>
function SearchNow()
{
	document.form_.executeSearch.value = "1";
	document.form_.print_pg.value = "";
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
</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	boolean bolLooped = false;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
//add security here.
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./view_sup_per_office_print.jsp" />
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
								"Admin/staff-INVENTORY-INV_MAINT- View Inventory","view_csr_inventory.jsp");
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
	String strTemp2 = null;
	String strTemp3 = null;
	String strQuery = "";	
	String strInvType  = null;
	String strClassification = null;
	String strCategory  = null;

	String strCurCollege = null;
	String strCurDept = null;
	String strCollName = null;
	String strDeptName = null;	

	String[] astrSortByName    = {"Item Name","Log Date","College","Department"};
	String[] astrSortByVal     = {"item_name","log_date","c_code","d_name"};

	InventorySearch InvSearch = new InventorySearch();
	if(WI.fillTextValue("executeSearch").compareTo("1") == 0){
	vRetResult = InvSearch.viewSuppliesPerOffice(dbOP,request);	
	if (vRetResult!= null && vRetResult.size() > 0)
		iSearchResult = InvSearch.getSearchCount();
	else
		strErrMsg = InvSearch.getErrMsg();
	}	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="view_sup_per_office.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY MAINTENANCE - VIEW INVENTORY PER OFFICE PAGE ::::</strong></font></div></td>
    </tr>
	</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="1277952%" height="25" colspan="4"><font size="3" color="red"><strong>&nbsp;<%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></font></td>
    </tr>
  </table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="5%">&nbsp;</td>
      <td width="17%">Item Type</td>
			<%
				strInvType = WI.fillTextValue("item_type");
			%>
      <td width="78%" colspan="4">
				<select name="item_type" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%if (strInvType.equals("1")) {%>
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
      <td width="5%" height="25">&nbsp;</td>
      <td width="17%">Item Category</td>
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
        </select>			</td>
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
      <td height="18" colspan="6"><hr size="1"></td>
    </tr>
  </table>	
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">        
    <!--
		<tr> 
      <td  width="5%" height="25">&nbsp;</td>
      <td width="13%">Sort by</td>
      <td width="24%">
	  <select name="sort_by1">
	 	<option value="">N/A</option>
          <%=InvSearch.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
      </select></td>
      <td width="26%"><select name="sort_by2">
	 	<option value="">N/A</option>
          <%=InvSearch.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select></td>
      <td width="31%"><select name="sort_by3">
	 	<option value="">N/A</option>
          <%=InvSearch.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
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
		-->
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td colspan="2"><a href="javascript:SearchNow();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>	
  <%if (vRetResult != null && vRetResult.size() > 0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	   <tr> 
      <td width="319488%" height="29" colspan="4"><div align="right"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print list</font></div></td>
    </tr>
  </table>	
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="20" colspan="5" align="center" class="thinborder"><strong>SUPPLIES LIST</strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="3" class="thinborderBOTTOMLEFT"><font size="1"><strong>TOTAL 
        ITEMS: &nbsp;&nbsp;<%=iSearchResult%></strong></font> </td>
      <td height="25" colspan="2" align="right" class="thinborderBOTTOMLEFT"><span class="thinborderBOTTOM">
        <%
	  //if more than one page , constuct page count list here.  - 15 default display per page)
		int iPageCount = iSearchResult/InvSearch.defSearchSize;		
		if(iSearchResult % InvSearch.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1){%>
        <select name="jumpto" onChange="SearchNow();" style="font-size:11px">
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
			}// end page printing%>
        </select>
        <%} else {%>
			&nbsp;
			<%} //if no pages %>
      </span></td>
    </tr>
    <tr>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>ITEM CODE </strong></font></td> 
      <td width="38%" align="center" class="thinborder"><font size="1"><strong>ITEM</strong></font></td>
      <!--
			<td width="12%" align="center" class="thinborder"><font size="1"><strong>STOCK IN </strong></font></td>
			-->
      <td width="12%" height="28" align="center" class="thinborder"><font size="1"><strong>QUANTITY ON HAND </strong></font></td>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">UNIT PRICE</font></strong></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>AMOUNT</strong></font></td>
    </tr>
    <%
		int i = 0;
		for (; i < vRetResult.size();){
			if(i == 0){
				strCollName = (String)vRetResult.elementAt(16);
				strDeptName = (String)vRetResult.elementAt(17);
			}
		%>
    <tr>
      <td height="25" colspan="5" class="thinborder">&nbsp;<strong><%=WI.getStrValue(strCollName,strDeptName)%></strong></td>
    </tr>
		<% bolLooped = false;
		for (; i < vRetResult.size(); i+=18){
				if(bolLooped){
					if(!strCurCollege.equals((String) vRetResult.elementAt(i+14)) ||
						 !WI.getStrValue(strCurDept).equals(WI.getStrValue((String) vRetResult.elementAt(i+15)))){
						strCollName = (String) vRetResult.elementAt(i+16);
						strDeptName = (String) vRetResult.elementAt(i+17);
						break;
					}
				}
		%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+6),"&nbsp;")%></td> 
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+5),"","&nbsp;","")%><%=WI.getStrValue((String) vRetResult.elementAt(i+2),"&nbsp;")%><%=WI.getStrValue((String) vRetResult.elementAt(i+3),"(", ")","")%></td>
      <!--
			<td align="right" class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+1),"&nbsp;")%> <%=WI.getStrValue((String) vRetResult.elementAt(i+4),"&nbsp;")%>&nbsp;</td>
			-->
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+12),"&nbsp;")%> <%=WI.getStrValue((String) vRetResult.elementAt(i+4),"&nbsp;")%>&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat((String) vRetResult.elementAt(i+11),true)%>&nbsp;</td>
      <td align="right" class="thinborder"><%=WI.getStrValue((String) vRetResult.elementAt(i+13),"&nbsp;")%>&nbsp;</td>
    </tr>
    <%
			bolLooped = true;
			strCurCollege = (String) vRetResult.elementAt(i+14);
			strCurDept = (String) vRetResult.elementAt(i+15);
		  } // inner for loop%>
	<%} // outer for loop	%>
  </table>
  <%}// if (vRetResult != null && vRetResult.size() > 0) %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3"><div align="center"></div></td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>  
	<input type="hidden" name="executeSearch" value="">
  <input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>