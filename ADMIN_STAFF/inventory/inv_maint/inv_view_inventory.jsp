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
<style type="text/css">
    table.TOPRIGHT {
    border-top: solid 1px #000000;
		border-right: solid 1px #000000;
    }

		TD.BOTTOMLEFT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: 9px;
    }
    TD.BOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: 9px;
    }		
    TD.NoBorder {
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
		}
</style>
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
	String strImgFileExt = null;
	int iSearchResult = 0;
	
//add security here.
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./inv_view_inventory_print.jsp" />
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
								"Admin/staff-INVENTORY-INV_MAINT- View Inventory","inv_view_inventory.jsp");
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
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName   = {"Status", "College", "Laboratory/Stock Room", "Non-Acad Office/Department", 
															 "Building", "Item Name"};
	String[] astrSortByVal    = {"inv_preload_status.INV_STATUS", "C_CODE", "ROOM_NUMBER", "D_NAME", 
															 "BLDG_NAME", "item_name"};
	InventorySearch InvSearch = new InventorySearch();
	int iSortCount = 6;
	int i = 0;
	if (WI.fillTextValue("executeSearch").equals("1")){
		if(WI.fillTextValue("inventory_type").equals("0"))
			vRetResult = InvSearch.searchInventory(dbOP,request);
		else
			vRetResult = InvSearch.searchCompInventory(dbOP,request);
	}
	if (vRetResult!= null && vRetResult.size() > 0){
		iSearchResult = InvSearch.getSearchCount();
	}else{
		strErrMsg = InvSearch.getErrMsg();
	}
%>
<body bgcolor="#FFFFFF">
<form name="form_" action="inv_view_inventory.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" bgcolor="#A49A6A"><font color="#FFFFFF" ><strong>:::: 
        INVENTORY MAINTENANCE - VIEW INVENTORY PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6"><font size="3" color="red"><strong>&nbsp;<%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></font></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2">College</td>
      <td valign="middle"> <%strTemp = WI.fillTextValue("c_index");%> <select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select> </td>
      <td valign="middle">Status</td>
      <td valign="middle"> <%strTemp3 = WI.fillTextValue("stat_index");%> <select name="stat_index">
          <option value="">Select category</option>
          <%=dbOP.loadCombo("inv_stat_index","inv_status"," from inv_preload_status order by inv_status", strTemp3, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Department</td>
      <td valign="middle"> <%strTemp2 = WI.fillTextValue("d_index");%> <select name="d_index">
          <% if(strTemp!=null && strTemp.compareTo("0") !=0){%>
          <option value="">All</option>
          <%} if (strTemp == null || strTemp.length() == 0 || strTemp.compareTo("0") == 0) strTemp = " and (c_index = 0 or c_index is null) ";
		else strTemp = " and c_index = " +  strTemp;%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + strTemp + " order by d_name asc",strTemp2, false)%> </select> </td>
      <td valign="middle">Building</td>
      <td valign="middle"> <%strTemp = WI.fillTextValue("bldg_index");%> <select name="bldg_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("BLDG_INDEX","BLDG_NAME"," from E_ROOM_BLDG where IS_DEL=0 order by BLDG_NAME", strTemp, false)%> </select> </td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2">Room</td>
      <td width="27%" valign="middle"> <%strTemp2 = WI.fillTextValue("room_idx");%> <select name="room_idx">
          <option value="">N/A</option>
          <%if (strTemp.length()>0){
				strTemp = " from E_ROOM_DETAIL join E_ROOM_BLDG on (E_ROOM_DETAIL.LOCATION = E_ROOM_BLDG.BLDG_NAME) where BLDG_INDEX = "+strTemp+
				" and E_ROOM_DETAIL.is_del = 0 order by ROOM_NUMBER";%>
          <%=dbOP.loadCombo("ROOM_INDEX","ROOM_NUMBER", strTemp, strTemp2, false)%> 
          <%}%>
      </select> </td>
      <td width="15%" valign="middle"> Inventory Type </td>
      <td width="36%" valign="middle"><font size="1">
        <%
		  strTemp = WI.fillTextValue("inventory_type");
	    %>
        <select name="inventory_type" onChange="ReloadPage();">
          <option value="0" selected>Non-Supplies/Equipment</option>
          <%if(strTemp.equals("3")){%>
          <option value="3" selected>Computer/parts</option>
          <%} else {%>
          <option value="3">Computer/parts</option>
          <%}%>
        </select>
      </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Loc. Description</td>
      <td valign="middle"><select name="loc_con">
        <%=InvSearch.constructGenericDropList(WI.fillTextValue("loc_con"),astrDropListEqual,astrDropListValEqual)%>
      </select>
    <input type="text" name="loc" value="<%=WI.fillTextValue("loc")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		 size="16"></td>
      <td valign="middle">&nbsp;</td>
      <td valign="middle">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" colspan="6"><hr size="1"></td>
    </tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td width="2%" height="19">&nbsp;</td>
      <td height="19" colspan="2">OPTIONS:</td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
			<%
				if(WI.fillTextValue("show_property").equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
				
			%>
      <td height="19"><input name="show_property" type="checkbox" value="1" <%=strTemp%>> 
      show property number and date acquired </td>
			<%
				if(WI.fillTextValue("show_update").equals("1"))
					strTemp = " checked";
				else
					strTemp = "";				
			%>	 				
      <td width="51%"><input name="show_update" type="checkbox" value="1" <%=strTemp%>>
show date last updated </td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
			<%
				if(WI.fillTextValue("show_owner").equals("1"))
					strTemp = " checked";
				else
					strTemp = "";				
			%>	 			
      <td height="19"><input name="show_owner" type="checkbox" value="1" <%=strTemp%>>
show owner office </td>
			<%
				if(WI.fillTextValue("show_remarks").equals("1"))
					strTemp = " checked";
				else
					strTemp = "";				
			%>	 		
      <td><input name="show_remarks" type="checkbox" value="1" <%=strTemp%>>
show remarks </td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
		<%
			if(WI.fillTextValue("show_status").equals("1"))
				strTemp = " checked";
			else
				strTemp = "";				
		%>			
      <td height="19"><input name="show_status" type="checkbox" value="1" <%=strTemp%>>
show status </td>
		<%
			if(WI.fillTextValue("show_code").equals("1"))
				strTemp = " checked";
			else
				strTemp = "";				
		%>		
      <td><input name="show_code" type="checkbox" value="1" <%=strTemp%>>
show item code </td>
    </tr>
    
    <tr>
      <td height="19" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="23">&nbsp;</td>
      <td height="23" colspan="5"><strong>SORT</strong></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td width="3%" height="24">&nbsp;</td>
      <td width="95%" height="24" colspan="4"> 
			<select name="sort_by1">
         <option value="" selected>N/A</option>
          <%
		  strTemp = WI.fillTextValue("sort_by1");
		  for (i = 0; i<iSortCount ; i++){
		  %>
			  <%if(strTemp.equals(astrSortByVal[i])){%>
				  <option value="<%=astrSortByVal[i]%>" selected><%=astrSortByName[i]%></option>
			  <%} else {%>
				  <option value="<%=astrSortByVal[i]%>"><%=astrSortByName[i]%></option>
			  <%}%>
          <%}%>
        </select> <select name="sort_by1_con">
          <option value="" selected>N/A</option>
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
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td height="24" colspan="4"><select name="sort_by2">
          <option value="" selected>N/A</option>
          <%
		  strTemp = WI.fillTextValue("sort_by2");
		  for (i = 0 ; i<iSortCount ; i++){
		  %>
          <%if(strTemp.equals(astrSortByVal[i])){%>
          <option value="<%=astrSortByVal[i]%>" selected><%=astrSortByName[i]%></option>
          <%} else {%>
          <option value="<%=astrSortByVal[i]%>"><%=astrSortByName[i]%></option>
          <%}%>
          <%}%>
        </select> <select name="sort_by2_con">
          <option value="" selected>N/A</option>
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
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td height="24" colspan="4"><select name="sort_by3">
          <option value="" selected>N/A</option>
          <%
		  strTemp = WI.fillTextValue("sort_by3");
		  for (i = 0 ; i<iSortCount ; i++){
		  %>
          <%if(strTemp.equals(astrSortByVal[i])){%>
          <option value="<%=astrSortByVal[i]%>" selected><%=astrSortByName[i]%></option>
          <%} else {%>
          <option value="<%=astrSortByVal[i]%>"><%=astrSortByName[i]%></option>
          <%}%>
          <%}%>
        </select> <select name="sort_by3_con">
          <option value="" selected>N/A</option>
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
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td height="24" colspan="4"><select name="sort_by4">
          <option value="" selected>N/A</option>
          <%
		  strTemp = WI.fillTextValue("sort_by4");
		  for (i = 0 ; i<iSortCount ; i++){
		  %>
          <%if(strTemp.equals(astrSortByVal[i])){%>
          <option value="<%=astrSortByVal[i]%>" selected><%=astrSortByName[i]%></option>
          <%} else {%>
          <option value="<%=astrSortByVal[i]%>"><%=astrSortByName[i]%></option>
          <%}%>
          <%}%>
        </select> <select name="sort_by4_con">
          <option value="" selected>N/A</option>
          <%if (WI.fillTextValue("sort_by4_con").equals("asc")){%>
          <option value="asc" selected>Ascending</option>
          <%}else{%>
          <option value="asc">Ascending</option>
          <%}%>
          <%if (WI.fillTextValue("sort_by4_con").equals("desc")){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td height="24" colspan="4"><select name="sort_by5">
          <option value="" selected>N/A</option>
          <%
		  strTemp = WI.fillTextValue("sort_by5");
		  for (i = 0 ; i<iSortCount ; i++){
		  %>
          <%if(strTemp.equals(astrSortByVal[i])){%>
          <option value="<%=astrSortByVal[i]%>" selected><%=astrSortByName[i]%></option>
          <%} else {%>
          <option value="<%=astrSortByVal[i]%>"><%=astrSortByName[i]%></option>
          <%}%>
          <%}%>
        </select> <select name="sort_by5_con">
          <option value="" selected>N/A</option>
          <%if (WI.fillTextValue("sort_by5_con").equals("asc")){%>
          <option value="asc" selected>Ascending</option>
          <%}else{%>
          <option value="asc">Ascending</option>
          <%}%>
          <%if (WI.fillTextValue("sort_by5_con").equals("desc")){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;</td>
      <td height="29" colspan="4"><a href="javascript:SearchNow();"><img src="../../../images/form_proceed.gif"  border="0"></a></td>
    </tr>
  <%if (vRetResult != null && vRetResult.size() > 0){%>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;</td>
      <td height="29" colspan="4"><div align="right"><font size="2"> Number of records per page :</font>
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i =20; i <=45 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}
			}%>
          </select>
          <a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print list</font></div></td>
    </tr>
  <%}%>
  </table>
  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="7"><div align="center"> 
          <p><strong><font size="2">EQUIPMENT  INVENTORY LIST</font></strong></p>
      </div></td>
    </tr>
    <tr> 
      <td height="25" colspan="5"><font size="1"><strong>TOTAL 
            ITEMS: &nbsp;<%=iSearchResult%></strong></font> </td>
      <td width="30%" height="25" colspan="2" align="right"> 
		<%
	  //if more than one page , constuct page count list here.  - 15 default display per page)
		int iPageCount = iSearchResult/InvSearch.defSearchSize;		
		if(iSearchResult % InvSearch.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1){%> 
			<font size="2">Jump To page: </font>
		<select name="jumpto" onChange="SearchNow();" style="font-size:11px">
          <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
          <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%	}
			}// end page printing%>
      </select> <%} else {%> &nbsp; <%} //if no pages %></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="TOPRIGHT">
    <tr> 
			<td width="7%" height="28" align="center" class="BOTTOMLEFT"><font size="1"><strong>QUANTITY</strong></font></td>
      <td width="14%" align="center" class="BOTTOMLEFT"><font size="1"><strong>ITEM</strong></font></td>
			<%if(WI.fillTextValue("show_property").length() > 0){%>
      <td width="8%" align="center" class="BOTTOMLEFT"><span class="thinborderBOTTOM"><strong><font size="1">PROPERTY # </font></strong></span></td>
      <td width="8%" align="center" class="BOTTOMLEFT"><span class="thinborderBOTTOM"><strong><font size="1">DATE ACQUIRED </font></strong></span></td>
			<%}%>
      <td width="15%" align="center" class="BOTTOMLEFT"><font size="1"><strong>LABORATORY/STOCK 
        ROOM/LOC DESC. </strong></font></td>
			<% if(WI.fillTextValue("show_owner").equals("1")){ %>					
      <td width="12%" align="center" class="BOTTOMLEFT"><strong><font size="1">COLLEGE/ NON-ACAD OFFICE/DEPT.</font></strong></td>
			<%}%>
			<td width="6%" align="center" class="BOTTOMLEFT"><span class="thinborderBOTTOM"><strong><font size="1">UNIT PRICE </font></strong></span></td>
			<td width="6%" align="center" class="BOTTOMLEFT"><strong><font size="1">AMOUNT</font></strong></td>			
      <td width="6%" align="center" class="BOTTOMLEFT"><strong><font size="1">STATUS</font></strong></td>
			<% if(WI.fillTextValue("show_update").equals("1")){ %>
      <td width="7%" align="center" class="BOTTOMLEFT"><strong><font size="1">DATE 
        STATUS UPDATED</font></strong></td>
			<%}%>
      <td width="15%" align="center" class="BOTTOMLEFT"><strong><font size="1">REMARKS</font></strong></td>
			<% if(WI.fillTextValue("show_code").equals("1")){ %>
      <td width="8%" align="center" class="BOTTOMLEFT"><strong><font size="1">ITEM CODE </font></strong></td>
			<%}%>
    </tr>
    <%if (vRetResult != null && vRetResult.size() > 0){
		for (i = 0; i < vRetResult.size(); i+=17){
	%>
    <tr> 
      <td height="25" class="BOTTOMLEFT">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+1),"&nbsp;")%> <%=WI.getStrValue((String) vRetResult.elementAt(i+9),"&nbsp;")%></td>
			<%
				strTemp = (String) vRetResult.elementAt(i);
				strTemp += WI.getStrValue((String) vRetResult.elementAt(i+12),"<br> - ","","");
			%>
      <td class="BOTTOMLEFT">&nbsp;<%=strTemp%></td>
      <%if(WI.fillTextValue("show_property").length() > 0){%>
			<td class="BOTTOMLEFT"><%=WI.getStrValue((String) vRetResult.elementAt(i+13),"&nbsp;")%></td>
      <td class="BOTTOMLEFT"><%=WI.getStrValue((String) vRetResult.elementAt(i+14),"&nbsp;")%></td>
			<%}%>
      <td class="BOTTOMLEFT"><%=WI.getStrValue((String) vRetResult.elementAt(i+4),"","","")%>
														 <%=WI.getStrValue((String) vRetResult.elementAt(i+5),"<br>","&nbsp;","")%>
														 <%=WI.getStrValue((String) vRetResult.elementAt(i+10),"<br>","","&nbsp;")%></td>
			<%
				if(vRetResult.elementAt(i+2) == null || vRetResult.elementAt(i+3) == null){
					strTemp = "";
				}else{
					strTemp = " - ";
				}
			%>									
			<% if(WI.fillTextValue("show_owner").equals("1")){ %>										 
      <td class="BOTTOMLEFT"><%=WI.getStrValue((String) vRetResult.elementAt(i+2),"&nbsp;")%><%=strTemp%><%=WI.getStrValue((String) vRetResult.elementAt(i+3),"&nbsp;")%></td>
			<%}%>
			<%
				strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(i+15),true);
			%>
			<td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
				strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(i+16),true);
			%>			
			<td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>			
			<%
				if(WI.fillTextValue("show_status").equals("1"))
					strTemp = (String) vRetResult.elementAt(i+6);
				else
					strTemp = "";
			%>			
      <td class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
				if(WI.fillTextValue("show_update").equals("1")){
			%>
      <td class="BOTTOMLEFT"><%=WI.getStrValue((String) vRetResult.elementAt(i+8),"&nbsp;")%></td>
			<%}%>
			<%if(WI.fillTextValue("show_remarks").length() > 0)
					strTemp = (String) vRetResult.elementAt(i+7);
				else
					strTemp = "";
				
			%>
			
      <td class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<% if(WI.fillTextValue("show_code").equals("1")){ %>
      <td class="BOTTOMLEFT"><%=WI.getStrValue((String) vRetResult.elementAt(i+11),"&nbsp;")%></td>
			<%}%>
    </tr>
    <%}
	}%>
  </table>
  <%}// if (vRetResult != null && vRetResult.size() > 0)
     %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3"><div align="center"></div></td>
    </tr>
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="executeSearch" value="<%=WI.fillTextValue("executeSearch")%>">
  <input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>