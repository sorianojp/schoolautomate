<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date, hmsOperation.RestItems" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css" />
<title>Inventory Adjustment</title>
<script language="JavaScript" src="../../../jscript/common.js" type="text/javascript"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js" type="text/javascript"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" type="text/javascript">

function ViewResult(){
	document.form_.canteen_name.value = document.form_.restaurant_index[document.form_.restaurant_index.selectedIndex].text;
	document.form_.view_result.value = "1";
	document.form_.submit();
}

function ReloadPage(){		
	document.form_.submit();
}

function PrintPage(){
	document.form_.print_pg.value = "1";
	document.form_.submit();
}

</script>
</head>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	
	if(WI.fillTextValue("print_pg").length() > 0){%>
		<jsp:forward page="./inv_log_new_report_print.jsp" />
		<%return;
	}
	 	
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-Inventory","inv_log_new_report.jsp");
	}
catch(Exception exp)
	{
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
														"inv_log_new_report.jsp");
	
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

//end of authenticaion code.
	RestItems restItems = new RestItems();
	Vector vRetResult = null;

	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	
	String[] astrSortByName    = {"Item Name","Item Code","Log Date"};
	String[] astrSortByVal     = {"item_name_","item_code_","log_date_"};
	
	String[] astrDropListGT = {"Equal to","Less than","More than"};
	String[] astrDropListValGT = {"=","<",">"};

	
int i = 0;
if(WI.fillTextValue("view_result").length() > 0){
	vRetResult = restItems.operateOnInventoryReport(dbOP, request, 2);
	if(vRetResult == null)
		strErrMsg = restItems.getErrMsg();
}

 %>
<body bgcolor="#eeeeee" topmargin="0">
<form action="inv_log_new_report.jsp" method="post" name="form_">
  <jsp:include page="./tabs.jsp?pgIndex=10"></jsp:include>


<table width="100%" border="0" cellpadding="1" cellspacing="1">
<tr><td height="25" colspan="12" style="padding-left:30px;"><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td></tr>
  <tr>
    <td width="11%" align="right">Canteen : </td>
    <td width="89%" height="25">
	<select name="restaurant_index">
      <% strTemp= WI.fillTextValue("restaurant_index");%>
      <option value="">Select</option>
      <%=dbOP.loadCombo("TERMINAL_DEPT_INDEX","DEPT_NAME", " from CC_TERMINAL_DEPT where is_valid = 1 " +
												" order by DEPT_NAME",strTemp,false)%>
    </select></td>
    </tr>
  <tr>
    <td align="right">Category : </td>
    <td height="25">
	<select name="category">
      <%strTemp= WI.fillTextValue("category");%>
      <option value="">Select Category</option>
      <%=dbOP.loadCombo("item_catg_index","catg_name", " from hms_rest_item_catg " +
			" where exists(select * from hms_rest_item_inv_mf where catg_index = item_catg_index " +
			"		and is_valid = 1 and is_inv_item = 1) " + 
			" order by catg_name",strTemp,false)%>
    </select></td>
    </tr>
	<tr>
		<td align="right">Item Code :</td>
		<td height="25">
			<select name="item_code_con">
				<%=restItems.constructGenericDropList(WI.fillTextValue("item_code_con"),astrDropListEqual,astrDropListValEqual)%>
			</select>
			<input type="text" name="item_code_" value="<%=WI.fillTextValue("item_code_")%>" class="textbox"
				onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="16" />
		</td>
	</tr>
	<tr>
		<td align="right">Item name :</td>
		<td height="25">
			<select name="item_name_con">
				<%=restItems.constructGenericDropList(WI.fillTextValue("item_name_con"),astrDropListEqual,astrDropListValEqual)%>
			</select>
			<input type="text" name="item_name_" value="<%=WI.fillTextValue("item_name_")%>" class="textbox"
				onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="16" />
		</td>
	</tr>
	
	<tr>
		<td align="right">Selling Price  :</td>
		<td height="25">
			<select name="price_con">
				<%=restItems.constructGenericDropList(WI.fillTextValue("price_con"),astrDropListGT,astrDropListValGT)%>
			</select>     

				<input name="price" type="text" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					value="<%=WI.fillTextValue("price")%>" size="12" maxlength="12" 
					onkeyup="AllowOnlyIntegerExtn('form_','price','.');"
					onblur="AllowOnlyIntegerExtn('form_','price','.');style.backgroundColor='white'" />
		</td>
	</tr>
	
	<tr>
		<td align="right">Log Date : </td>
		<td width="80%" colspan="3">
		<%
		strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "1");
		%>
			<select name="date_type" onchange="ReloadPage();">
			<%if (strTemp.equals("1")){%>
			<option value="1" selected>Specific Date</option>
			<%}else{%>
			<option value="1">Specific Date</option>
			<%}if (strTemp.equals("2")){%>
			<option value="2" selected>Date Range</option>
			<%}else{%>
			<option value="2">Date Range</option>
			<%}%>
			</select>
		<input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
		<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
			<img src="../../../images/calendar_new.gif" border="0"></a>
		<%
		strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "1");
		if(strTemp.equals("2")){
		%>
		to 
		<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
		value="<%=WI.fillTextValue("date_to")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
		<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" border="0"></a>
		<%}%>
		</td>
	</tr>
	
  	<tr><td height="10" colspan="3"></td></tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td>SORT BY :</td>
      <td width="29%" height="25"><select name="sort_by1">
        <option value="">N/A</option>
					<%=restItems.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td width="30%" height="25"><select name="sort_by2">
        <option value="">N/A</option>
					<%=restItems.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>      
			</select></td>

      <td width="30%" height="25"><select name="sort_by3">
        <option value="">N/A</option>        
					<%=restItems.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
      </select></td>
    </tr>
    <tr> 
      <td width="11%" height="15">&nbsp;</td>
      <td><select name="sort_by1_con">
        <option value="asc">Ascending</option>
        <%
	if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
      <td><select name="sort_by2_con">
        <option value="asc">Ascending</option>
        <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
      <td><select name="sort_by3_con">
        <option value="asc">Ascending</option>
        <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
    </tr>
    <tr><td height="10" colspan="7">&nbsp;</td></tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">
        <a href="javascript:ViewResult();"><img src="../../../images/form_proceed.gif" border="0" /></a>
       </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
  </table>
  
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="right"><a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0" /></a></td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#A9B9D1" class="thinborder">
  <tr bgcolor="#D3D3D3">
    <td width="7%" height="25" class="thinborder" align="center"><font color="#000066" size="1"><b>CATEGORY</b></font></td>
    <td width="7%" class="thinborder" align="center"><font color="#000066" size="1"><b>ITEM CODE </b></font></td>
    <td width="" class="thinborder" align="center"><font color="#000066" size="1"><b>ITEM NAME </b></font></td>
    <td width="7%" class="thinborder" align="center"><font color="#000066" size="1"><b>PURCHASE UNIT </b></font></td>
    <td width="7%" class="thinborder" align="center"><font color="#000066" size="1"><b>SELLING  UNIT </b></font></td>
    <td width="5%"  class="thinborder" align="center"><font color="#000066" size="1"><b>CONVERSION</b></font></td>
    <td width="5%"  class="thinborder" align="center"><font color="#000066" size="1"><b>SELLING PRICE </b></font></td>
	<td width="5%"  class="thinborder" align="center"><font color="#000066" size="1"><b>LOG QTY</b></font></td>
	<td width="15%"  class="thinborder" align="center"><font color="#000066" size="1"><b>REMARKS</b></font></td>
    <td width="10%" class="thinborder" align="center"><font color="#000066" size="1"><b>LOGGED BY</b></font></td>
	<td width="12%" class="thinborder" align="center"><font color="#000066" size="1"><b>LOGGED DATE</b></font></td>
    </tr>
  <%for(i = 0; i < vRetResult.size(); i+= 14){%>
	<tr bgcolor="#D3D3D3">
    <td height="22" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"n/a")%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"n/a")%></td>
		<%
			strTemp = (String)vRetResult.elementAt(i+6);
			strTemp = CommonUtil.formatFloat(strTemp, true);
		%>
    <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
	
	<%
		int iTemp = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+13),"-1"));
		strTemp = (String)vRetResult.elementAt(i+7);
		if(iTemp > 0 && iTemp == 2)
			strTemp = "-"+strTemp;
	%>
	
    <td class="thinborder" align="right"><%=strTemp%>&nbsp;</td>
	<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+12))%></td>
	<%
	strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+9),(String)vRetResult.elementAt(i+10),(String)vRetResult.elementAt(i+11),4);
	%>
	<td class="thinborder"><%=strTemp%></td>
	<td class="thinborder"><%=(String)vRetResult.elementAt(i+8)%></td>
    </tr>
	<%}%>
</table>

<%}%>
  
  
  	<input type="hidden" name="print_pg" />
	<input type="hidden" name="canteen_name" value="<%=WI.fillTextValue("canteen_name")%>" />
	<input type="hidden" name="view_result" />
</form>
  </body>
</html>
<%
dbOP.cleanUP();
%>