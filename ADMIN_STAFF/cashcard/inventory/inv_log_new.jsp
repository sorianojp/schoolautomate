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
function ReloadPage(){	
	document.form_.canteen_name.value = document.form_.restaurant_index[document.form_.restaurant_index.selectedIndex].text;
	document.form_.submit();
}

function SaveRecord(){	
	if(!confirm("Do you want to log qty? "))
		return;
		
	document.form_.page_action.value = "1";
	document.form_.submit();
}


function toggleSel(objQty, objChkBox){
	if(objQty.value.length > 0)
		objChkBox.checked = true;
	else
		objChkBox.checked = false;
}

function CancelRecord() 
{
	location = "./inv_log_new.jsp"; 
}

function checkAllSave() {
	var maxDisp = document.form_.item_count.value;
	var bolIsSelAll = document.form_.selAllSaveItems.checked;
	for(var i =1; i< maxDisp; ++i)
		eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
}

function checkKeyPress(strFormName, strFieldName, strExtn, strKeyCode){
	/*
		strKeyCodes
			32 - spacebar
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
		|| strKeyCode == 32)
		//|| strKeyCode == 110	|| strKeyCode == 190
		return;

	if(strExtn != undefined  && strExtn.length > 0)
		AllowOnlyIntegerExtn(strFormName,strFieldName, strExtn);
	else
		AllowOnlyInteger(strFormName, strFieldName);
}

function AjaxSearchCode() {
	var objCOAInput = document.getElementById("item_code_");
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	
	var strCode = document.form_.item_code.value;
			
	if(strCode.length <= 2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=5005&item_code="+escape(strCode);
	
	this.processRequest(strURL);
} 

function updateItemCode(strCode, strItemMFIndex) {
	document.form_.item_code.value = strCode;
	document.getElementById("item_code_").innerHTML = "";	
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
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-Inventory","inv_log_new.jsp");
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
														"inv_log_new.jsp");
	
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
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	
	String[] astrSortByName    = {"Item Name","Item Code","Selling Unit"};
	String[] astrSortByVal     = {"item_name","item_code","small.unit_name"};
		
	int iSearchResult = 0;
	int i = 0;
	int iCount = 0;
	
	if(WI.fillTextValue("page_action").length() > 0){		
		if(!restItems.operateOnCanteenInventory(dbOP, request))
			strErrMsg = restItems.getErrMsg();	
	}
	
	vRetResult = restItems.getItemInventory(dbOP,request);
	if(vRetResult == null)
		strErrMsg = restItems.getErrMsg();	
	
 %>
<body bgcolor="#eeeeee" topmargin="0">
<form action="inv_log_new.jsp" method="post" name="form_">
  <jsp:include page="./tabs.jsp?pgIndex=7"></jsp:include>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="21" colspan="2"><font size="+1" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
<tr>
    <td height="25" align="right"><b><font color="#000066">Transaction Date : </font></b></td>
		<%
			strTemp = WI.getTodaysDate(1);
		%>
    <td width="83%" height="25"><font color="#000066">
      <input name="transac_date" type="text" size="10" maxlength="10"  value="<%=strTemp%>"/>
      <strong><a href="javascript:show_calendar('form_.transac_date');" 
			title="Click to select date" onmouseover="window.status='Select date';return true;" 
			onmouseout="window.status='';return true;">
			<img src="../../../images/calendar_new.gif" border="0" /></a></strong></font></td>
    </tr>  
  <tr>
    <td height="25" align="right"><b><font color="#000066">Canteen : </font></b></td>
    <td width="83%" height="25"><select name="restaurant_index" onchange="ReloadPage();">
      <% strTemp= WI.fillTextValue("restaurant_index");%>
      <option value="">Select</option>
      <%=dbOP.loadCombo("TERMINAL_DEPT_INDEX","DEPT_NAME", " from CC_TERMINAL_DEPT where is_valid = 1 " +
												" order by DEPT_NAME",strTemp,false)%>
    </select></td>
    </tr>
  <tr>
    <td width="17%" height="25" align="right"><b><font color="#000066">Item Category : </font></b></td>
    <td height="25"><select name="catg_index">
      <%strTemp= WI.fillTextValue("catg_index");%>
      <option value="">Select Category</option>
      <%=dbOP.loadCombo("item_catg_index","catg_name", " from hms_rest_item_catg " +
			" where exists(select * from hms_rest_item_inv_mf where catg_index = item_catg_index " +
			"		and is_valid = 1 and is_inv_item = 1) " + 
			" order by catg_name",strTemp,false)%>
    </select>
      <font color="#000066"><a href="#"></a></font></td>
    </tr>
		<tr>
    <td height="25" align="right"><b><font color="#000066">Item Code  : </font></b></td>
    <td height="25"><font color="#000066">
      <b><font color="#000066">
      <select name="item_code_con">
        <%=restItems.constructGenericDropList(WI.fillTextValue("item_code_con"),astrDropListEqual,astrDropListValEqual)%>
      </select>
      </font></b>
      <input name="item_code" type="text" size="20" maxlength="16"  class="textbox" 
			onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
			onkeyup="AjaxSearchCode();" value="<%=WI.fillTextValue("item_code")%>"/>
    <label id="item_code_" style="position:absolute; width:400px;"></label></font></td>
    </tr>
	<tr><td height="10" colspan="5"></td></tr>	
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
   <tr><td height="10" colspan="5"></td></tr>	
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">
        <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0" /></a>        </td>
    </tr>
    <tr>
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0">  
	
	
  <tr>
    <td height="25" colspan="8" bgcolor="#000033" class="thinborderALL" align="center" ><font color="#FFFFFF"><b>:: LIST OF ITEMS 
		<%=WI.getStrValue(WI.fillTextValue("canteen_name").toUpperCase())%>  :: </b></font></td>
  </tr>
  <tr bgcolor="#D3D3D3">
    <td class="thinborderBOTTOMLEFT" width="10%" height="25" align="center"><font color="#000066" size="1"><b>ITEM CODE </b></font></td>
    <td class="thinborderBOTTOMLEFT" align="center"><b><font color="#000066" size="1">ITEM NAME </font></b></td>
    <td class="thinborderBOTTOMLEFT" width="10%" align="center"><b><font color="#000066" size="1">MAIN AVAILABLE QTY</font></b></td>
    <td class="thinborderBOTTOMLEFT" width="10%" align="center"><b><font color="#000066" size="1">CANTEEN QTY ON HAND</font></b></td>
    <td class="thinborderBOTTOMLEFT" width="19%" align="center"><b><font color="#000066" size="1">REMARKS</font></b></td>
    <td class="thinborderBOTTOMLEFT" width="7%" align="center"><strong><font color="#000066" size="1">LOG QTY</font></strong></td> 
    <td class="thinborderBOTTOMLEFT" width="6%" align="center"><b><font color="#000066" size="1">SELECT ALL
      <input type="checkbox" name="selAllSave" value="0" onclick="checkAllSave();" />
      </font></b></td>
  </tr>
	<%
	iCount = 1;
	for(i = 0; i < vRetResult.size(); i += 5, iCount++){
	
	
	%>
  <tr bgcolor="#D3D3D3">	
    <td class="thinborderBOTTOMLEFT" height="20" ><%=(String)vRetResult.elementAt(i)%></td>
    <td class="thinborderBOTTOMLEFT"><%=(String)vRetResult.elementAt(i+1)%></td>
    <td class="thinborderBOTTOMLEFT" align="right"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"0")%>&nbsp; &nbsp; </td>   
    <td class="thinborderBOTTOMLEFT" align="right"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"0")%>&nbsp; &nbsp; </td>	
	<%
		strTemp = WI.getStrValue(WI.fillTextValue("remarks_"+iCount));
	%>	
    <td class="thinborderBOTTOMLEFT" align="center">
		<input name="remarks_<%=iCount%>" type="text" size="22" maxlength="128"  class="textbox" value="<%=strTemp%>"
		onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" /></td>
		<%
			strTemp = WI.fillTextValue("qty_"+iCount);
		%>
    <td bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT" align="center">
		<input name="qty_<%=iCount%>" type="text" size="5" maxlength="5" class="textbox"
		style="text-align:right" onfocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>"
		onBlur="style.backgroundColor='white'; AllowOnlyInteger('form_','qty_<%=iCount%>');toggleSel(document.form_.qty_<%=iCount%>, document.form_.save_<%=iCount%>);"
		onkeyup="checkKeyPress('form_','qty_<%=iCount%>','',event.keyCode);"/>		</td>
		
		
		<%
		if(strTemp != null && strTemp.length() > 0 && Integer.parseInt(strTemp) > 0)
			strTemp = " checked";
		%>
		
    <td height="20" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT" align="center">
		<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+4)%>" <%=strTemp%> tabindex="-1" /></td>
  </tr>	
	<%}%>
	<input type="hidden" name="item_count" value="<%=iCount%>">
  <tr>
    <td height="29" colspan="8" align="right"> 
    <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
		onclick="javascript:SaveRecord();" />click to SAVE entries
	<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
		onclick="javascript:CancelRecord();" />click to CANCEL entries</td>
  </tr>
 </table>
	<%}%>
	<input type="hidden" name="page_action"> 	
	<input type="hidden" name="canteen_name" value="<%=WI.fillTextValue("canteen_name")%>"  />
</form>
  </body>
</html>
<%
dbOP.cleanUP();
%>