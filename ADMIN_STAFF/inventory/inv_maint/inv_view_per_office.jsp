<%@ page language="java" import="utility.*, inventory.InventorySearch, java.util.Vector"%>
<%
///added code for HR/companies.
WebInterface WI = new WebInterface(request);
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

	if(strSchCode.startsWith("VMA")){%>
	<jsp:forward page="./inv_view_per_office_vma.jsp"></jsp:forward>
	<%return;}
//strColorScheme is never null. it has value always.
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
	document.form_.status_name.value = document.form_.stat_index[document.form_.stat_index.selectedIndex].text;
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
	<jsp:forward page="./inv_view_per_office_print.jsp" />
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
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("EXECUTIVE MANAGEMENT SYSTEM"),"0"));
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
								"Admin/staff-INVENTORY-INV_MAINT- View Inventory","inv_view_per_office.jsp");
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

	int iElemCount  =0;
	Vector vRetResult = null;
	int iTemp = 0;
	String strTemp2 = null;
	String strTemp3 = null;
	String strQuery = "";	
	String[] astrSortByName   = {"Status", "College", "Laboratory/Stock Room", "Non-Acad Office/Department", "Building","Inventory Type"};
	String[] astrSortByVal    = {"inv_preload_status.INV_STATUS", "college.C_CODE", "E_ROOM_DETAIL.ROOM_NUMBER", "DEPARTMENT.D_NAME", "E_ROOM_BLDG.BLDG_NAME","pur_preload_item.is_supply"};
	InventorySearch InvSearch = new InventorySearch();
	if (WI.fillTextValue("executeSearch").equals("1")){
		vRetResult = InvSearch.viewInventorybyOffice(dbOP,request);
		if(vRetResult == null)
			strErrMsg = InvSearch.getErrMsg();
		else{
			iSearchResult = InvSearch.getSearchCount();
			iElemCount  =InvSearch.getElemCount();
		}
			
	}
	
	double dPageTotal = 0d;

%>
<body bgcolor="#D2AE72">
<form name="form_" action="inv_view_per_office.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY MAINTENANCE - INVENTORY PER OFFICE PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5"><font size="3" color="red"><strong>&nbsp;<%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></font></td>
    </tr>

    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td width="21%"><%if(bolIsSchool){%>
        College
          <%}else{%>
          Division
      <%}%></td>
      <td height="29" valign="middle"> 
		  <% 
				String strCollegeIndex = WI.fillTextValue("c_index");	
	  	%>
			<select name="c_index" onChange="ReloadPage();" style="width:250px;">
        <option value="">N/A</option>
        <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%>
      </select></td>
      <td valign="middle">Status</td>
      <td height="29" valign="middle"> 
			<%
				strTemp3 = WI.fillTextValue("stat_index");
			%> 
			<select name="stat_index" style="width:150px;">
        <option value="">Select category</option>
          <%=dbOP.loadCombo("inv_stat_index","inv_status",
					" from inv_preload_status order by inv_status", strTemp3, false)%> 
			</select>		 </td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td>Department</td>
      <td height="29" valign="middle"> 
			<%
				strTemp2 = WI.fillTextValue("d_index");
			%>
			<select name="d_index" onChange="ReloadPage();" style="width:250px;">
        <option value="" selected>ALL</option>
        <%if ((strCollegeIndex.length() == 0)){%>
        <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0", WI.fillTextValue("d_index"),false)%>
        <%}else if (strCollegeIndex.length() > 0){%>
        <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%>
        <%}%>
      </select></td>
      <td valign="middle">Building</td>
      <td height="29" valign="middle">
			<%
				strTemp = WI.fillTextValue("bldg_index");
			%>
			<select name="bldg_index" onChange="ReloadPage();" style="width:150px;">
          <option value="">N/A</option>
      <%=dbOP.loadCombo("BLDG_INDEX","BLDG_NAME"," from E_ROOM_BLDG where IS_DEL=0 " + 
			" order by BLDG_NAME", strTemp, false)%> 
			</select> </td>
    </tr>
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>Room</td>
      <td width="29%" height="29" valign="middle">
			<%
				strTemp2 = WI.fillTextValue("room_idx");
			%> 
			<select name="room_idx" style="width:250px;">
          <option value="">N/A</option>
         <%if (strTemp.length()>0){
				strTemp = 
					" from E_ROOM_DETAIL join E_ROOM_BLDG on (E_ROOM_DETAIL.LOCATION = E_ROOM_BLDG.BLDG_NAME) " +
					" where BLDG_INDEX = " + strTemp + " and E_ROOM_DETAIL.is_del = 0 order by ROOM_NUMBER";%>
          <%=dbOP.loadCombo("ROOM_INDEX","ROOM_NUMBER", strTemp, strTemp2, false)%> 
          <%}%>
      </select> </td>
    <td width="13%" valign="middle">
	  	Inventory Type			</td>
      <td width="34%" height="29" valign="middle"> <font size="1"> 
      <%
		  strTemp = WI.fillTextValue("inventory_type");
	    %>
      <select name="inventory_type" onChange="ReloadPage();" style="width:150px;">
				<option value="" selected>ALL</option>
				<%if(strTemp.equals("0")){%>
        <option value="0" selected>Non-Supplies/Equipment</option>
				<%}else{%>
				<option value="0">Non-Supplies/Equipment</option>				
        <%}if(strTemp.equals("1")){%>
        <option value="1" selected>Supplies</option>
        <%} else {%>
        <option value="1">Supplies</option>
        <%}if(strTemp.equals("2")){%>
        <option value="2" selected>Chemical</option>
        <%} else {%>
        <option value="2">Chemical</option>
        <%}if(strTemp.equals("3")){%>
        <option value="3" selected>Computer/parts</option>
        <%} else {%>
        <option value="3">Computer/parts</option>				
        <%}%>
      </select>
      </font>			</td>
    </tr>
    <tr> 
      <td height="18" colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
      <td height="19" colspan="4">OPTIONS:</td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
			<%
				if(WI.fillTextValue("show_property").equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
				
			%>
      <td height="19" colspan="4"><input name="show_property" type="checkbox" value="1" <%=strTemp%>> 
      show property number and date acquired </td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
		<%
			if(WI.fillTextValue("show_status").equals("1"))
				strTemp = " checked";
			else
				strTemp = "";				
		%>			
      <td height="19" colspan="4"><input name="show_status" type="checkbox" value="1" <%=strTemp%>>
show status </td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
		<%
			if(WI.fillTextValue("show_remarks").equals("1"))
				strTemp = " checked";
			else
				strTemp = "";				
		%>				  
      <td height="19" colspan="4"><input name="show_remarks" type="checkbox" value="1" <%=strTemp%>>
show remarks column </td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
		<%
			if(WI.fillTextValue("show_code").equals("1"))
				strTemp = " checked";
			else
				strTemp = "";				
		%>	  
      <td height="19" colspan="4"><input name="show_code" type="checkbox" value="1" <%=strTemp%>>
show item code </td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29" colspan="4"><a href="javascript:SearchNow();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  <%if (vRetResult != null && vRetResult.size() > 0){%>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29" colspan="4"><div align="right"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print list</font></div></td>
    </tr>
  <%}%>
  </table>
  <%strTemp = WI.fillTextValue("bldg_index");%>
  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="10" align="center"><font color="#FFFFFF"><strong>INVENTORY PER OFFICE</strong></font> </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="20" colspan="10"><div align="right"><span class="thinborderBOTTOM">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
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
			}// end page printing
			%>
        </select>
        <%} else {%>
  &nbsp;
  <%} //if no pages %>
      </span></div></td>
    </tr>
    <tr>
      <td width="6%" height="18" align="center" class="thinborderBOTTOM"><font size="1"><strong>QUANTITY</strong></font></td>
      <td width="12%" align="center" class="thinborderBOTTOM"><font size="1"><strong>LOCATION</strong></font></td>
      <td width="13%" align="center" class="thinborderBOTTOM"><font size="1"><strong>ITEM</strong></font></td>
	<%if(WI.fillTextValue("show_property").length() > 0){%>
      <td width="8%" align="center" class="thinborderBOTTOM"><strong><font size="1">PROPERTY # </font></strong></td>
      <td width="9%" align="center" class="thinborderBOTTOM"><strong><font size="1">DATE ACQUIRED </font></strong></td>
	<%}%>
	  <td width="7%" align="center" class="thinborderBOTTOM"><strong><font size="1">UNIT PRICE </font></strong></td>
	  <td width="6%" align="center" class="thinborderBOTTOM"><strong><font size="1">AMOUNT</font></strong></td>			
      <td width="9%" align="center" class="thinborderBOTTOM"><strong><font size="1">STATUS</font></strong></td>
	  <%if(WI.fillTextValue("show_remarks").length() > 0){%>
      <td width="16%" align="center" class="thinborderBOTTOM"><strong><font size="1">REMARKS</font></strong></td>
	  <%}%>
	  <%if(WI.fillTextValue("show_code").length() > 0){%>
      <td width="14%" align="center" class="thinborderBOTTOM"><strong>CODE</strong></td>
	  <%}%>
    </tr>
    <% 
	 for(int i = 0; i <vRetResult.size(); i+=iElemCount){%>
    <tr>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+4),"&nbsp;")%> <%=WI.getStrValue((String) vRetResult.elementAt(i+5),"&nbsp;")%></td>
			<%strTemp = "";
				strTemp2 = "";
				strTemp = WI.getStrValue((String) vRetResult.elementAt(i+6),"Bldg : ","","");
				if(strTemp.length() > 0)
					strTemp2 = "<br>";
				strTemp += WI.getStrValue((String) vRetResult.elementAt(i+7),strTemp2 + "Rm # : ","","&nbsp;");
				
				strTemp2 = "";
				if(strTemp.length() > 0)
					strTemp2 = "<br>";
				strTemp += WI.getStrValue((String) vRetResult.elementAt(i+10),strTemp2 +"Loc. Desc : ","","");
				
			%>
      <td class="thinborder"><%=strTemp%>&nbsp;</td>
      <td height="21" class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+8),"&nbsp;")%><%=WI.getStrValue((String) vRetResult.elementAt(i+9)," - ","","&nbsp;")%></td>
      <%if(WI.fillTextValue("show_property").length() > 0){%>
			<td class="thinborder"><%=WI.getStrValue((String) vRetResult.elementAt(i+13),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String) vRetResult.elementAt(i+14),"&nbsp;")%></td>
			<%}%>
			<%
				strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(i+15),true);
			%>
			<td align="right" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
				strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(i+16),true);
				
				if(vRetResult.elementAt(i+16) != null) 
					dPageTotal += Double.parseDouble((String)vRetResult.elementAt(i+16));
			%>			
			<td align="right" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>			
			<%
				if(WI.fillTextValue("show_status").equals("1"))
					strTemp = (String) vRetResult.elementAt(i+17);
				else
					strTemp = "";
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	 <%if(WI.fillTextValue("show_remarks").length() > 0){%>	
      <td class="thinborder">&nbsp;</td>
	  <%}%>
	  <%
		strTemp = (String) vRetResult.elementAt(i+18);
	  %>
	  <%if(WI.fillTextValue("show_code").length() > 0){%>
      <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%=strTemp%></td>
	  <%}%>
    </tr>
    <%}%>
    
    <tr>
      <td height="11" colspan="10">
	  <%if(strSchCode.startsWith("WUP")){%>
	  	Page Total: <%=CommonUtil.formatFloat(dPageTotal, true)%>
	  <%}else{%>
	  &nbsp;
	  <%}%>
	  </td>
    </tr>
    <tr>
      <td height="11" colspan="10"></td>
    </tr>
  </table>
  <%}// if (vRetResult != null && vRetResult.size() > 0)
     %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3"><div align="center"></div></td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="status_name" value="<%=WI.fillTextValue("status_name")%>">
   <input type="hidden" name="executeSearch" value="<%=WI.fillTextValue("executeSearch")%>">
  <input type="hidden" name="print_pg">
  <input type="hidden" name="is_chem" value="<%=WI.fillTextValue("is_chem")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>