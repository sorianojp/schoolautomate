<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date, hmsOperation.RestItems" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css" />
<title>Restaurant Items</title>
<script language="JavaScript" src="../../../jscript/common.js" type="text/javascript"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js" type="text/javascript"></script>
<script language="JavaScript" type="text/javascript">
function ReloadPage(){
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');	
}

function PrintPg(){
	document.form_.print_pg.value = 1;
	this.SubmitOnce('form_');
}

</script>
</head>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	
	if (WI.fillTextValue("print_pg").length() > 0){%>
		<jsp:forward page="./item_master_list_print.jsp"/>
	  
		<% 
	return;}		
	 	
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-Inventory-Item Master Listing","item_master_list.jsp");
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
														"item_master_list.jsp");
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
	int iSearchResult = 0;
	int i = 0;
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	
	String[] astrDropListGT = {"Equal to","Less than","More than"};
	String[] astrDropListValGT = {"=","<",">"};
	
	String[] astrSortByName    = {"Category","Item name"};
	String[] astrSortByVal     = {"catg_name", "item_name" };
		
	vRetResult = restItems.operateOnInventoryItems(dbOP,request,4);
	if(vRetResult != null)
		iSearchResult = restItems.getSearchCount();
 %>
<body topmargin="0" bgcolor="#eeeeee">
<form action="item_master_list.jsp" method="post" name="form_">
<table border="0" cellspacing="0" cellpadding="0" >
  <tr>
    <td background=".././../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
    <td width="120" bgcolor="#A9B9D1" align="center" class="tabFont" >Items Summary  </td>
    <td background=".././../../images/tabright_selected.gif" width="10">&nbsp;</td>
    <td background=".././../../images/tableft.gif" height="24" width="10">&nbsp;</td>
    <td width="130" bgcolor="#00468C" align="center"><a href="item_master_list_manage.jsp">Add/Edit Items </a></td>
    <td background=".././../../images/tabright.gif" width="10">&nbsp;</td>
	<td background=".././../../images/tableft.gif" height="24" width="10">&nbsp;</td>
	<td width="120" bgcolor="#00468C" align="center"><a href="inventory_log_ml.jsp">Inventory Log</a></td>
	<td background=".././../../images/tabright.gif" width="10">&nbsp;</td>
	
	<td background=".././../../images/tableft.gif" height="24" width="10">&nbsp;</td>
	<td width="120" bgcolor="#00468C" align="center"><a href="log_report_ml.jsp">Log Report</a></td>
	<td background=".././../../images/tabright.gif" width="10">&nbsp;</td>
	
    <td width="650">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<%if(strErrMsg != null) {%>
  <tr>
    <td height="25" colspan="2"><%=strErrMsg%></td>
    </tr>
<%}%>
  <tr>
    <td width="15%"><font color="#000066"><b>Category : </b></font></td>
    <td width="85%" height="29"><select name="category" onchange="ReloadPage();">
        <%
					strTemp= WI.fillTextValue("category");
				%>
        <option value="">Select Category</option>
        <%=dbOP.loadCombo("item_catg_index","catg_name", " from hms_rest_item_catg order by catg_name",strTemp,false)%>
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
      <%
		strTemp = WI.fillTextValue("price");
		%>
      <font size="1"><strong>
      <input name="price" type="text" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
		value="<%=strTemp%>" size="12" maxlength="12" 
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
<table width="100%" border="0" cellpadding="0" cellspacing="0">	
  <tr>
    <td width="65%" height="29"  align="right"><font size="2">Number of records per page :</font>
      <select name="num_rec_page">
        <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i =20; i <=45 ; i++) {
				if ( i == iDefault) {%>
        <option selected="selected" value="<%=i%>"><%=i%></option>
        <%}else{%>
        <option value="<%=i%>"><%=i%></option>
        <%}
			}%>
      </select>
      <font size="1">
      <input type="button" name="cancel3" value=" Print " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onclick="javascript:PrintPg();" />
      </font><font color="#000066" size="1">Click to PRINT listing </font></td>
    </tr>
    <%		
	int iPageCount = iSearchResult/restItems.defSearchSize;		
	if(iSearchResult % restItems.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>	
  <tr>
    <td height="29"  align="right"><font size="2">Jump To page:
        <select name="jumpto" onchange="ReloadPage();">
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
    </font></td>
  </tr>
	<%}%>
  <tr>
    <td height="25" bgcolor="#000033" class="thinborderALL" align="center" ><font color="#FFFFFF"><b>:: LIST OF ITEMS CREATED  ::</b></font></td>
  </tr>
  </table>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#A9B9D1" class="thinborder">
  <tr>
    <td width="14%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>CATEGORY</b></font></td>
    <td width="10%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>ITEM CODE </b></font></td>
    <td width="14%" bgcolor="#D3D3D3" class="thinborder" align="center"><b><font color="#000066" size="1">ITEM NAME </font></b></td>
    <td width="7%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><b><font color="#000066" size="1">PURCHASE UNIT </font></b></td>
    <td width="10%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>SELLING  UNIT </b></font></td>
    <td width="9%" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>CONVERSION</b></font></td>
    <td width="9%" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>SELLING PRICE </b></font></td>
	<td width="9%" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>AVAILABLE QTY</b></font></td>
    <td width="10%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><b><font color="#000066" size="1"><font color="#000066">DATE CREATED </font> </font></b></td>
    </tr>
  <%for(i = 0; i < vRetResult.size(); i+= 17){%>
	<tr>
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
	<td height="20" bgcolor="#D3D3D3" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+14)%></td>
	
    </tr>
	<%}%>
</table>
<%}%>
<input type="hidden" name="print_pg"> 
</form>
 </body>
</html>
<%
dbOP.cleanUP();
%>