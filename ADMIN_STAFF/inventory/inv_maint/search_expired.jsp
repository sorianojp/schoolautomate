<%@ page language="java" import="utility.*, inventory.InventorySearch, inventory.InventoryMaintenance, 
																java.util.Vector"%>
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
<script language="JavaScript" src="../../../jscript/td.js"></script>
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
function SaveRecord(){
	document.form_.save_record.value="1";
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
	<jsp:forward page="./search_expired_print.jsp" />
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
								"Admin/staff-INVENTORY-INV_MAINT- View Inventory","search_expired.jsp");
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
	String[] astrSortByName   = {"College", "Laboratory/Stock Room", "Non-Acad Office/Department", "Building"};
	String[] astrSortByVal    = {"college.c_code", "e_room_detail.room_number", "department.d_name", "e_room_bldg.bldg_name"};
	InventorySearch InvSearch = new InventorySearch();
	InventoryMaintenance InvMaint = new InventoryMaintenance();

	if (WI.fillTextValue("save_record").equals("1")){
		if(InvMaint.operateOnExpiredChemical(dbOP,request) == false){
			strErrMsg = InvMaint.getErrMsg();	
		}
	}

	if (WI.fillTextValue("executeSearch").equals("1")){
		vRetResult = InvSearch.searchExpired(dbOP,request);
	}
	if (vRetResult!= null && vRetResult.size() > 0){
		iSearchResult = InvSearch.getSearchCount();
	}else{
		strErrMsg = InvSearch.getErrMsg();
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="search_expired.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY MAINTENANCE - VIEW EXPIRED CHEMICALS PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4"><font size="3" color="red"><strong>&nbsp;<%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></font></td>
    </tr>
    <tr> 
      <td width="4%" height="29">&nbsp;</td>
      <td colspan="2">College</td>
      <td height="29" valign="middle"> <%strTemp = WI.fillTextValue("c_index");%> <select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL =0 order by c_name asc", strTemp, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td colspan="2">Department</td>
      <td height="29" valign="middle"> <%strTemp2 = WI.fillTextValue("d_index");%> <select name="d_index">
          <% if(strTemp!=null && strTemp.compareTo("0") !=0){%>
          <option value="">All</option>
          <%} if (strTemp == null || strTemp.length() == 0 || strTemp.compareTo("0") == 0) strTemp = " and (c_index = 0 or c_index is null) ";
		else strTemp = " and c_index = " +  strTemp;%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + strTemp + " order by d_name asc",strTemp2, false)%> </select> </td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td colspan="2">Building</td>
      <td height="29" valign="middle"><%strTemp = WI.fillTextValue("bldg_index");%>
        <select name="bldg_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("BLDG_INDEX","BLDG_NAME"," from E_ROOM_BLDG where IS_DEL=0 order by BLDG_NAME", strTemp, false)%>
        </select></td>
    </tr>
    <tr> 
      <td width="4%" height="29">&nbsp;</td>
      <td colspan="2">Room</td>
      <td width="81%" height="29" valign="middle"> <%strTemp2 = WI.fillTextValue("room_idx");%> <select name="room_idx">
          <option value="">N/A</option>
          <%if (strTemp.length()>0){
				strTemp = " from E_ROOM_DETAIL join E_ROOM_BLDG on (E_ROOM_DETAIL.LOCATION = E_ROOM_BLDG.BLDG_NAME) where BLDG_INDEX = "+strTemp+
				" and E_ROOM_DETAIL.is_del = 0 order by ROOM_NUMBER";%>
          <%=dbOP.loadCombo("ROOM_INDEX","ROOM_NUMBER", strTemp, strTemp2, false)%> 
          <%}%>
      </select> </td>
    </tr>
    <tr> 
      <td height="18" colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td height="22" colspan="3"><strong>SORT</strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td width="3%" height="29">&nbsp;</td>
      <td height="29" colspan="2"> <select name="sort_by1">
          <option value="" selected>N/A</option>
          <%
		  strTemp = WI.fillTextValue("sort_by1");
		  for (int i = 0; i<4 ; i++){
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
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;</td>
      <td height="29" colspan="2"><select name="sort_by2">
          <option value="" selected>N/A</option>
          <%
		  strTemp = WI.fillTextValue("sort_by2");
		  for (int i = 0 ; i<4 ; i++){
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
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;</td>
      <td height="29" colspan="2"><select name="sort_by3">
          <option value="" selected>N/A</option>
          <%
		  strTemp = WI.fillTextValue("sort_by3");
		  for (int i = 0 ; i<4 ; i++){
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
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;</td>
      <td height="29" colspan="2"><a href="javascript:SearchNow();"><img src="../../../images/form_proceed.gif"  border="0"></a></td>
    </tr>
  <%if (vRetResult != null && vRetResult.size() > 0){%>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;</td>
      <td height="29" colspan="2"><div align="right"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print list</font></div></td>
    </tr>
  <%}%>
  </table>
  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="20" colspan="6" align="center" class="thinborder">        <p><strong><font size="2">INVENTORY LIST</font></strong></p></td></tr>
    <tr> 
      <td height="25" colspan="3" class="thinborderBOTTOMLEFT"><font size="1"><strong>TOTAL 
        ITEMS: &nbsp;&nbsp;<%=iSearchResult%></strong></font> </td>
      <td height="25" colspan="3" align="right" class="thinborderBOTTOMLEFT"><%
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
      <td width="13%" height="28" align="center" class="thinborder"><font size="1"><strong>QUANTITY</strong></font></td>
      <td width="19%" align="center" class="thinborder"><font size="1"><strong>ITEM</strong></font></td>
      <td width="31%" align="center" class="thinborder"><strong><font size="1">OWNERSHIP</font></strong></td>
      <td width="11%" align="center" class="thinborder"><strong><font size="1">STATUS</font></strong></td>
      <td width="13%" align="center" class="thinborder"><strong><font size="1">EXPIRY DATE </font></strong> </td>
      <td width="13%" align="center" class="thinborder"><strong><font size="1">OPTION</font></strong></td>
    </tr>
    <%
		int iCount = 1;
		if (vRetResult != null && vRetResult.size() > 0){		
			for (int i = 0; i < vRetResult.size(); i+=19, iCount++){
		%>
    <tr> 
			<input type="hidden" name="qty_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>">
			<input type="hidden" name="unit_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+9)%>">
			<input type="hidden" name="item_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+10)%>">			
			<input type="hidden" name="small_qty_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+16)%>">
			<input type="hidden" name="conversion_qty_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+17)%>">
			<input type="hidden" name="inv_entry_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+18)%>">			
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+1),"&nbsp;")%>&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+8),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i),"")%><%=WI.getStrValue((String) vRetResult.elementAt(i+12),"(",")","")%><font size="1"><%=WI.getStrValue((String) vRetResult.elementAt(i+15),"<br>&nbsp;Code: ","","")%></font></td>
      <%if(vRetResult.elementAt(i+2) == null || ((String) vRetResult.elementAt(i+2)).equals("0")
					|| vRetResult.elementAt(i+3) == null || ((String) vRetResult.elementAt(i+3)).equals("0")){
					strTemp = "";
				}else{
					strTemp = " - ";
				}				
			%>
			
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"",strTemp,"")%><%=WI.getStrValue((String) vRetResult.elementAt(i+3),"")%><%=WI.getStrValue((String) vRetResult.elementAt(i+4),"<br>","<br>","&nbsp;")%><%=WI.getStrValue((String) vRetResult.elementAt(i+5),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%></td>
      <td class="thinborder">
				<input name="optAction<%=iCount%>" type="radio" value="0" checked>
				Do nothing 
				<br>
        <input name="optAction<%=iCount%>" type="radio" value="1">
        Dispose
				<% if(vRetResult.elementAt(i+11) != null){%>
				<br>
        <input name="optAction<%=iCount%>" type="radio" value="2"> Return
				<%}%></td>
    </tr>
    <%}
	}%>
	<input type="hidden" name="item_count" value="<%=iCount%>">
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" align="center"><a href="javascript:SaveRecord()"><img src="../../../images/save.gif" width="48" height="28"  border="0"></a><font size="1">Click to save item option</font></td>
    </tr>
  </table>
  <%}// if (vRetResult != null && vRetResult.size() > 0)%>		
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="executeSearch" value="<%=WI.fillTextValue("executeSearch")%>">
  <input type="hidden" name="print_pg">
	<input type="hidden" name="save_record">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>