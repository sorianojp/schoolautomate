<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date, hmsOperation.RestItems" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css" />

<style type="text/css">
.nav {   
	 font-weight:normal;
}
.nav-highlight {    
     background-color:#BCDEDB;
}

</style>

<title>Untitled Document</title>
<script language="JavaScript" src="../../../jscript/common.js" type="text/javascript"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js" type="text/javascript"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" type="text/javascript">
	function LogQty(){
		document.form_.log_qty.value = "1";
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	function checkAllSaveItems() {
		var maxDisp = document.form_.item_count.value;
		var bolIsSelAll = document.form_.selAllSaveItems.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
	function toggleSel(objQty, objChkBox){
		if(objQty.value.length > 0)
			objChkBox.checked = true;
		else
			objChkBox.checked = false;
	}
	
	function navRollOver(obj, state) {
	  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
	}
	
</script>
</head>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	 	
//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-Inventory-Manage Item Master List","inventory_log_ml.jsp");
	}catch(Exception exp){	
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"CASH CARD","Inventory",request.getRemoteAddr(),
														"inventory_log_ml.jsp");
	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	
	String[] astrDropListGT = {"Equal to","Less than","More than"};
	String[] astrDropListValGT = {"=","<",">"};
	
	String[] astrSortByName    = {"Category","Item name"};
	String[] astrSortByVal     = {"catg_name", "item_name" };

int i = 0;
RestItems restItems = new RestItems();
Vector vRetResult = null;
int iSearchResult = 0;

if(WI.fillTextValue("log_qty").length() > 0){
	if(restItems.operateOnMainInventory(dbOP,request,1) == null)
		strErrMsg = restItems.getErrMsg();	
}


vRetResult = restItems.operateOnMainInventory(dbOP,request,4);
if(vRetResult == null)
	strErrMsg = restItems.getErrMsg();
else
	iSearchResult = restItems.getSearchCount();


%>
<body bgcolor="#eeeeee" topmargin="0">
<form action="inventory_log_ml.jsp" method="post" name="form_"> 
<table border="0" cellspacing="0" cellpadding="0" >
	<tr>
		<td background=".././../../images/tableft.gif" height="24" width="10">&nbsp;</td>
		<td width="120" bgcolor="#00468C" align="center"><a href="item_master_list.jsp">Items Summary  </a></td>
		<td background=".././../../images/tabright.gif" width="10">&nbsp;</td>
		<td background=".././../../images/tableft.gif" height="24" width="10">&nbsp;</td>
		<td width="130" bgcolor="#00468C" align="center"><a href="item_master_list_manage.jsp">Add/Edit Items </a></td>
		<td background=".././../../images/tabright.gif" width="10">&nbsp;</td>	
		<td background=".././../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
		<td width="130" bgcolor="#A9B9D1" align="center" class="tabFont" >Inventory Log</td>
		<td background=".././../../images/tabright_selected.gif" width="10">&nbsp;</td>
		
		<td background=".././../../images/tableft.gif" height="24" width="10">&nbsp;</td>
		<td width="120" bgcolor="#00468C" align="center"><a href="log_report_ml.jsp">Log Report</a></td>
		<td background=".././../../images/tabright.gif" width="10">&nbsp;</td>
		
		<td width="650">&nbsp;</td>
	</tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0">

<tr>
	<td height="25" colspan="2"><%=WI.getStrValue(strErrMsg)%></td>
</tr>
<tr>
    <td height="25" align=""><b><font color="#000066">Transaction Date :</font></b></td>
		<%
			strTemp = WI.getTodaysDate(1);
		%>
    <td width="82%" height="25"><font color="#000066">
      <input name="transaction_date" type="text" size="10" maxlength="10" readonly="yes"  value="<%=strTemp%>"/>
      <strong><a href="javascript:show_calendar('form_.transaction_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0" /></a></strong> </font></td>
    </tr>
  <tr>
    <td width="15%"><font color="#000066"><b>Category : </b></font></td>
    <td width="85%" height="29"><select name="category" onchange="ReloadPage();">      
       <option value="">Select Category</option>
        <%=dbOP.loadCombo("item_catg_index","catg_name", " from hms_rest_item_catg " +
			" where exists(select * from hms_rest_item_inv_mf where catg_index = item_catg_index " +
			"		and is_valid = 1 and is_inv_item = 1) " + 
			" order by catg_name", WI.fillTextValue("category") , false)%>
      </select></td>
  </tr>
  <tr>
    <td><font color="#000066"><b>Item name : </b></font></td>
    <td height="29"><select name="item_name_con">
      <%=restItems.constructGenericDropList(WI.fillTextValue("item_name_con"),astrDropListEqual,astrDropListValEqual)%>
    </select>
      <input type="text" name="item_name_" value="<%=WI.fillTextValue("item_name_")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="16" /></td>
  </tr>
  <tr>
    <td><font color="#000066"><b>Selling Price  : </b></font></td>
    <td height="29"><select name="price_con">
      <%=restItems.constructGenericDropList(WI.fillTextValue("price_con"),astrDropListGT,astrDropListValGT)%>
    </select>
     
      <font size="1"><strong>
      <input name="price" type="text" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
		value="<%=WI.fillTextValue("price")%>" size="12" maxlength="12" 
		onkeyup="AllowOnlyIntegerExtn('form_','price','.');"
		onblur="AllowOnlyIntegerExtn('form_','price','.');style.backgroundColor='white'" />
      </strong></font></td>
  </tr>
  <tr>
    <td height="24"><font color="#000066"><b>Sort by: </b></font></td>
    <td height="24"><select name="sort_by1">
      <option value="">N/A</option>
      <%=restItems.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
    </select>
      <select name="sort_by1_con">
        <option value="asc">Ascending</option>
        <%
	if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
        <option value="desc" selected="selected">Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td height="29"><select name="sort_by2">
      <option value="">N/A</option>
      <%=restItems.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
    </select>
      <select name="sort_by2_con">
        <option value="asc">Ascending</option>
        <%
	if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
        <option value="desc" selected="selected">Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td height="35"><input type="button" name="12" value=" Search Inventory List " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onclick="ReloadPage();" /></td>
  </tr>
</table>



<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr>
	<td width="50%" align="right">&nbsp;
	<%if(iAccessLevel > 1){%>
		<input type="button" name="add" value=" LOG QTY " onclick="javascript:LogQty();"
		style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
	<%}%>
</td>
</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">	
  
    <tr> 
			<td class="">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(restItems.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25"> &nbsp;
			<%
				int iPageCount = 1;
				if(!WI.fillTextValue("view_all").equals("1")){
					iPageCount = iSearchResult/restItems.defSearchSize;		
					if(iSearchResult % restItems.defSearchSize > 0)
						++iPageCount;
				}
				strTemp = " - Showing("+restItems.getDisplayRange()+")";
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="document.form_.submit();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i = 1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}%> </td>
	</tr>
  <tr>
    <td height="25" bgcolor="#000033" class="thinborderALL" align="center" colspan="2" ><font color="#FFFFFF"><b>:: LIST OF ITEMS ::</b></font></td>
  </tr>
  </table>
  
  
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#A9B9D1" class="thinborder">
  <tr>
    <td width="14%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>CATEGORY</b></font></td>
    <td width="10%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>ITEM CODE </b></font></td>
    <td width="" bgcolor="#D3D3D3" class="thinborder" align="center"><b><font color="#000066" size="1">ITEM NAME </font></b></td>
    <td width="7%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><b><font color="#000066" size="1">PURCHASE UNIT </font></b></td>
    <td width="10%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>SELLING  UNIT </b></font></td>
    <td width="9%" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>CONVERSION</b></font></td>
    <td width="9%" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>SELLING PRICE </b></font></td>    
	<td width="5%" align="center" bgcolor="#D3D3D3" class="thinborder"><b><font color="#000066" size="1">AVAILABLE QTY</font></b></td>
	<td width="5%" align="center" bgcolor="#D3D3D3" class="thinborder"><b><font color="#000066" size="1">LOG QTY</font></b></td>
    <td width="5%" align="center" class="thinborder" bgcolor="#D3D3D3" ><b><font color="#000066" size="1">Select All<br /> </font></b>
				<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();"></td>
	</tr>
  <%
  int iCount = 1;
  for(i = 0; i < vRetResult.size(); i+= 17, iCount++){
  
  	 //if(((String)vRetResult.elementAt(i+13)).equals("0"))
	 //	continue;
  %>
	<tr class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')">
    <td height="22" bgcolor="#D3D3D3" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
    <td bgcolor="#D3D3D3" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
    <td bgcolor="#D3D3D3" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
    <td height="20" bgcolor="#D3D3D3" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6),"n/a")%></td>
    <td height="20" bgcolor="#D3D3D3" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+8)%></td>
    <td bgcolor="#D3D3D3" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9),"n/a")%></td>
		<%
			strTemp = (String)vRetResult.elementAt(i+10);
			strTemp = CommonUtil.formatFloat(strTemp, true);
		%>
    <td align="right" bgcolor="#D3D3D3" class="thinborder"><%=strTemp%>&nbsp;</td>    
	<td height="20" bgcolor="#D3D3D3" class="thinborder" align="right"><%=(String)vRetResult.elementAt(i+16)%>&nbsp;</td>
	<td class="thinborder" align="center" bgcolor="#D3D3D3">
				<input type="text" name="qty_<%=iCount%>" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','qty_<%=iCount%>');style.backgroundColor='white';toggleSel(document.form_.qty_<%=iCount%>, document.form_.save_<%=iCount%>)" 
					onkeyup="AllowOnlyInteger('form_','qty_<%=iCount%>')" size="3" maxlength="5"/></td>
	<td class="thinborder" align="center" bgcolor="#D3D3D3">				
				<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1" <%=strErrMsg%>></td>
    </tr>
	<%}%>
	
	<input type="hidden" name="item_count" value="<%=iCount%>"  />
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr><td height="20"></td></tr>
<tr>
	<td width="50%" align="right">&nbsp;
	<%if(iAccessLevel > 1){%>
		<input type="button" name="add" value=" LOG QTY " onclick="javascript:LogQty();"
		style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
	<%}%>
</td>
</tr>
</table>


<%}%>






	<input type="hidden" name="log_qty"  />
</form>
  </body>
</html>
<%
dbOP.cleanUP();
%>