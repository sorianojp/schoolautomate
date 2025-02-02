<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date, hmsOperation.RestItems" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css" />
<title>Untitled Document</title>
<script language="JavaScript" src="../../../jscript/common.js" type="text/javascript"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js" type="text/javascript"></script>
<script language="JavaScript" type="text/javascript">
function ReloadPage(){
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');	
}

function SaveRecord(){	
	document.form_.page_action.value = 1;
	this.SubmitOnce('form_');	
}
function DeleteRecord(page_action) {
	document.form_.page_action.value = 0;
	this.SubmitOnce('form_');
}

function EditRecord(){
	document.form_.page_action.value = 1;
	this.SubmitOnce('form_');	
}

function CancelRecord() 
{
	location = "./inv_items.jsp"; 
}

function PrintPg(){
	document.form_.print_pg.value = 1;
	this.SubmitOnce('form_');
}

function checkAllSave() {
	var maxDisp = document.form_.max_items.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}
}

function copyFirst() {
	var maxDisp = document.form_.max_items.value;
	//unselect if it is unchecked.
	if(document.form_.reorder_pt_1.value.length > 0) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.reorder_pt_'+i+'.value='+document.form_.reorder_pt_1.value);
	}
}

function checkKeyPress(strFormName, strFieldName, strExtn, strKeyCode){
	/*
		strKeyCodes
			35 = end, 36 = home, 37 = left, 38 = up, 39 = right, 40 = down
			8 = backspace, 46 = delete
			96 - 105 - numpad
			48 - 57 - kanang sa taas
			110 - period sa main
			190 - period sa numpad
	*/
	// alert("strKeyCode - " + strKeyCode);
 	if((strKeyCode >= 35 && strKeyCode <= 40)		
		|| (strKeyCode >= 48	&& strKeyCode <= 57)
		|| (strKeyCode >= 96	&& strKeyCode <= 105)
		|| strKeyCode == 8	|| strKeyCode == 46
		|| strKeyCode == 110	|| strKeyCode == 190)
		return;
	if(strExtn.length > 0)
		AllowOnlyIntegerExtn(strFormName,strFieldName, strExtn);
	else
		AllowOnlyInteger(strFormName,strFieldName);
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
		<jsp:forward page="./restaurant_items_listing_print.jsp"/>
	  
		<% 
	return;}		
	 	
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-Inventory","inv_items.jsp");
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
														"inv_items.jsp");
	
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
	Vector vEditInfo = null;
	String[] astrSortByName    = {"Item Name","Item Code","Selling Unit", "Selling Price"};
	String[] astrSortByVal     = {"item_name","item_code","small.unit_name", "selling_price"};
		
	int iSearchResult = 0;
	int i = 0;
	int iCount = 0;
	if(WI.fillTextValue("page_action").length() > 0){
		vRetResult = restItems.operateOnRestaurantItems(dbOP, request, Integer.parseInt(WI.fillTextValue("page_action")));
		if(vRetResult == null)
			strErrMsg = restItems.getErrMsg();
	}
 
	vRetResult = restItems.operateOnRestaurantItems(dbOP,request,4);
	if(vRetResult == null)
		strErrMsg = restItems.getErrMsg();
	else
		iSearchResult = restItems.getSearchCount();
	
 %>
<body bgcolor="#eeeeee" topmargin="0">
<form action="inv_items.jsp" method="post" name="form_">
  <jsp:include page="./tabs.jsp?pgIndex=4"></jsp:include>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="23" colspan="3"><font  color="#FF0000" size="+1"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  
  <tr>
    <td height="10" colspan="3"><hr size="1" /></td>
  </tr>
  <tr>
    <td align="right">&nbsp;</td>
    <td height="25" align="right"><b><font color="#000066">Canteen  :</font></b></td>
    <td width="85%" height="25"><select name="restaurant_index" onchange="ReloadPage();">
      <% strTemp= WI.fillTextValue("restaurant_index");%>
      <option value="">Select</option>
      <%=dbOP.loadCombo("TERMINAL_DEPT_INDEX","DEPT_NAME", " from CC_TERMINAL_DEPT where is_valid = 1 " +
												" order by DEPT_NAME",strTemp,false)%>
    </select></td>
    </tr>
  <tr>
    <td width="3%" align="right">&nbsp;</td>
    <td width="12%" height="25" align="right"><b><font color="#000066">Category : </font></b></td>
    <td height="25">
		<select name="catg_index">
      <%strTemp= WI.fillTextValue("catg_index");%>
      <option value="">Select Category</option>
      <%=dbOP.loadCombo("item_catg_index","catg_name", " from hms_rest_item_catg order by catg_name",strTemp,false)%>
    </select>
      <font color="#000066"><a href="#"></a></font></td>
    </tr>
  <tr>
    <td align="right">&nbsp;</td>
    <td height="15" align="right">&nbsp;</td>
    <td height="15">&nbsp;</td>
    </tr>
  <tr>
    <td align="right">&nbsp;</td>
    <td height="25" align="right">OPTION:</td>
    <td height="25"><%
	strTemp = WI.fillTextValue("with_record");
	strTemp = WI.getStrValue(strTemp,"1");
	if(strTemp.compareTo("1") == 0) 
		strTemp = " checked";
	else	
		strTemp = "";	
%>
      <input type="radio" name="with_record" value="1"<%=strTemp%> onclick="ReloadPage();" />
View  items for the restaurant
<%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%>
<input type="radio" name="with_record" value="0"<%=strTemp%> onclick="ReloadPage();" />
View unregistered items </td>
    </tr>
  <tr>
    <td height="25" align="right">&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td><%
				if(WI.fillTextValue("inv_item_only").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>
      <input name="inv_item_only" type="checkbox" value="1"<%=strTemp%> onclick="ReloadPage();" />
      show only inventory items </td>
    </tr>
  <tr>
    <td height="25" align="right">&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td><%
				if(WI.fillTextValue("view_all").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>
        <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">
        View result in single page </td>
    </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td width="28%" height="29"><select name="sort_by1">
        <option value="">N/A</option>
					<%=restItems.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td width="29%" height="29"><select name="sort_by2">
        <option value="">N/A</option>
					<%=restItems.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>      
			</select></td>

      <td width="29%" height="29"><select name="sort_by3">
        <option value="">N/A</option>        
					<%=restItems.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
      </select></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
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
    <tr>
      <td height="21">&nbsp;</td>
      <td height="21">&nbsp;</td>
      <td height="21" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">
        <input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
        <font size="1">click to display item list </font></td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="1" cellspacing="1">
      <%		
	if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/restItems.defSearchSize;		
	if(iSearchResult % restItems.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>	
  <tr>
    <td height="25" colspan="7" class="thinborderALL" align="right" ><font size="2">Jump To page:
        <select name="jumpto" onchange="ReloadPage();">
          <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
          <option selected="selected" value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%
					}
			}
			%>
        </select>
    </font></td>
  </tr>
	<%}
	}%>
  <tr>
    <td height="25" colspan="7" bgcolor="#000033" class="thinborderALL" align="center" ><font color="#FFFFFF"><b>:: LIST OF ITEMS UNDER CATEGORY  :: </b></font></td>
  </tr>
  <tr>
    <td width="10%" height="25" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT" align="center"><font color="#000066" size="1"><b>ITEM CODE </b></font></td>
    <td width="33%" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT" align="center"><b><font color="#000066" size="1">ITEM NAME </font></b></td>
    <td width="11%" height="25" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT" align="center"><b><font color="#000066" size="1">PURCHASE UNIT </font></b></td>
    <td width="11%" height="25" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT" align="center"><font color="#000066" size="1"><b>SELLING UNIT </b></font></td>
    <td width="12%" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT" align="center"><font color="#000066" size="1"><b>SELLING PRICE </b></font></td>
    <td width="13%" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT" align="center"><b><font color="#000066" size="1">REORDER POINT<br />
      (in selling unit)<br />
      <a href="javascript:copyFirst();"><u>COPY</u></a>
</font></b></td>
    <td width="10%" height="25" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT" align="center"><b><font color="#000066" size="1">SELECT<br />
      </font><font size="1">
      <input type="checkbox" name="selAllSave" value="0" onclick="checkAllSave();" checked="checked" />
      </font><font color="#000066" size="1">     ALL        </font></b></td>
  </tr>
	<%
	iCount = 1;
	for(i = 0; i < vRetResult.size(); i+=12, iCount++){%>
  <tr>
		<input type="hidden" name="item_inv_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
		<input type="hidden" name="item_mf_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i + 1)%>">		
    <td height="20" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><%=(String)vRetResult.elementAt(i+2)%></td>
    <td bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><%=(String)vRetResult.elementAt(i+3)%></td>
    <td height="20" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><%=WI.getStrValue((String)vRetResult.elementAt(i+8))%></td>
    <td height="20" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><%=(String)vRetResult.elementAt(i+7)%></td>
		<%
			strTemp = (String)vRetResult.elementAt(i+4);
			strTemp = CommonUtil.formatFloat(strTemp,true);
		%>
    <td align="right" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
    <%
			if(WI.fillTextValue("with_record").equals("1"))
				strTemp = (String)vRetResult.elementAt(i+10);
			else
				strTemp = "";
		%>
		<td bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT" align="center">
		<%if(((String)vRetResult.elementAt(i+11)).equals("1")){%>
		<input type="text" name="reorder_pt_<%=iCount%>" maxlength="10" size="6" value="<%=strTemp%>" 
		style="text-align:right" onfocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'; AllowOnlyIntegerExtn('form_','reorder_pt_<%=iCount%>','.');"
		onkeyup="checkKeyPress('form_','reorder_pt_<%=iCount%>','.',event.keyCode);">
		<%}%>
		</td>
    <td height="20" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT" align="center"><input type="checkbox" name="save_<%=iCount%>" value="1" checked="checked" tabindex="-1" /> </td>
  </tr>
	<%}%>
  <input type="hidden" name="max_items" value="<%=iCount%>">
  <tr>
    <td height="29" colspan="7" align="right">
		<%if(WI.fillTextValue("with_record").equals("1")){%>
		<input type="button" name="save" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
		onclick="javascript:DeleteRecord();" /> click to Delete entries
		<%}%>
		<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
		onclick="javascript:SaveRecord();" /> click to SAVE entries
		<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
		onclick="javascript:CancelRecord();" />click to CANCEL entries</td>
  </tr>
</table>
<%}%>
	<input type="hidden" name="print_pg"> 
	<input type="hidden" name="page_action"> 
	
</form>
  </body>
</html>
<%
dbOP.cleanUP();
%>