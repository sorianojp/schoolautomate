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
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
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
	location = "./inv_beginning_bal.jsp"; 
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

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=500&item_code="+escape(strCode);
	
	this.processRequest(strURL);
} 

function updateItemCode(strCode, strItemMFIndex) {
	document.form_.item_code.value = strCode;
	document.getElementById("item_code_").innerHTML = "";
	//"<font size='1' color=blue>...end of processing..</font>";
	//document.form_.submit();
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
								"Admin/staff-Cash Card-Inventory-Inventory Begin Balance","inv_beginning_bal.jsp");
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
														"inv_beginning_bal.jsp");
	
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
		vRetResult = restItems.operateOnItemBeginningBalance(dbOP, request, Integer.parseInt(WI.fillTextValue("page_action")));
		if(vRetResult == null)
			strErrMsg = restItems.getErrMsg();
	}
	
	vRetResult = restItems.getRestaurantItems(dbOP,request);
	if(vRetResult == null)
		strErrMsg = restItems.getErrMsg();
	else
		iSearchResult = restItems.getSearchCount();
	
 %>
<body bgcolor="#eeeeee" topmargin="0">
<form action="inv_beginning_bal.jsp" method="post" name="form_" id="form_">
  <jsp:include page="./tabs.jsp?pgIndex=5"></jsp:include>
<table width="99%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="18" colspan="2"><font size="+1" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  <tr>
    <td height="25" align="right"><b><font color="#000066">Beginning <br />
      Balance Date : </font></b></td>
		<%
			strTemp = WI.getTodaysDate(1);
		%>
    <td width="82%" height="25"><font color="#000066">
      <input name="begin_bal_date" type="text" size="10" maxlength="10"  value="<%=strTemp%>"/>
      <strong><a href="javascript:show_calendar('form_.begin_bal_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0" /></a></strong> </font></td>
    </tr>
  <tr>
    <td height="14" colspan="2"><hr size="1" /></td>
  </tr>
  <tr>
    <td height="25" align="right"><strong><font color="#000066">Canteen : </font></strong></td>
    <td height="25"><select name="restaurant_index" onchange="ReloadPage();">
      <% strTemp= WI.fillTextValue("restaurant_index");%>
      <option value="">Select</option>
      <%=dbOP.loadCombo("TERMINAL_DEPT_INDEX","DEPT_NAME", " from CC_TERMINAL_DEPT where is_valid = 1 " +
												" order by DEPT_NAME",strTemp,false)%>
    </select></td>
    </tr>
  <tr>
    <td width="18%" height="25" align="right"><b><font color="#000066">Category : </font></b></td>
    <td height="25"><select name="catg_index">
      <%strTemp= WI.fillTextValue("catg_index");%>
      <option value="">Select Category</option>
      <%=dbOP.loadCombo("item_catg_index","catg_name", " from hms_rest_item_catg order by catg_name",strTemp,false)%>
    </select>
      <font color="#000066">&nbsp;</font></td>
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
  <tr>
    <td height="25" align="right">&nbsp;</td>
    <td height="25">&nbsp;</td>
    </tr>
</table>
<table width="99%" border="0" cellspacing="0" cellpadding="0">
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
        <option value="desc" selected="selected">Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
      <td><select name="sort_by2_con">
        <option value="asc">Ascending</option>
        <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
        <option value="desc" selected="selected">Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
      <td><select name="sort_by3_con">
        <option value="asc">Ascending</option>
        <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
        <option value="desc" selected="selected">Descending</option>
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
        <input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onclick="javascript:ReloadPage();" />
        <font size="1">click to display item list </font></td>
    </tr>
  </table>
 <%if(vRetResult != null && vRetResult.size() > 0){%>
 <table width="99%" border="0" cellpadding="0" cellspacing="0">  
    <%		
	int iPageCount = iSearchResult/restItems.defSearchSize;		
	if(iSearchResult % restItems.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>	
  <tr>
    <td height="25" colspan="8" class="thinborderALL" align="right" ><font size="2">Jump To page:
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
	<%}%>
  <tr>
    <td height="25" colspan="8" bgcolor="#000033" class="thinborderALL" align="center" ><font color="#FFFFFF"><b>:: LIST OF ITEMS   :: </b></font></td>
  </tr>
 </table>
 <table width="99%" border="0" cellpadding="0" cellspacing="0" class="thinborder">	
  <tr>
    <td width="13%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>ITEM CODE </b></font></td>
    <td width="" bgcolor="#D3D3D3" class="thinborder" align="center"><b><font color="#000066" size="1">ITEM NAME </font></b></td>
    <td width="12%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><b><font color="#000066" size="1">PURCHASE UNIT </font></b></td>
    <td width="10%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>SELLING UNIT </b></font></td>
    <td width="11%" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>DATE LAST SET </b></font></td>
    <td width="12%" bgcolor="#D3D3D3" class="thinborder" align="center"><b><font color="#000066" size="1">QTY ON HAND <br />
      (in Selling Unit ) </font></b></td>
    <td width="8%" bgcolor="#D3D3D3" class="thinborder" align="center"><b><font color="#000066" size="1">BEGINNING BALANCE </font></b></td>
    <td width="7%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><b><font color="#000066" size="1">SELECT ALL <br>
            <input type="checkbox" name="selAllSave" value="0" onclick="checkAllSave();" checked="checked" />
</font></b></td>
  </tr>
	<%
	iCount = 1;
	for(i = 0; i < vRetResult.size(); i += 13, iCount++){%>
  <tr>
		<input name="item_index_<%=iCount%>" type="hidden" value="<%=(String)vRetResult.elementAt(i)%>" />
		<input name="item_code_<%=iCount%>" type="hidden" value="<%=(String)vRetResult.elementAt(i+2)%>" />
    <td height="20" bgcolor="#D3D3D3" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
    <td bgcolor="#D3D3D3" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
    <td height="20" bgcolor="#D3D3D3" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8))%></td>
    <td height="20" bgcolor="#D3D3D3" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
		<td bgcolor="#D3D3D3" class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+12),"&nbsp;")%></td>
		<%
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+11),"0");
		%>
		<input name="cur_bal_<%=iCount%>" type="hidden" value="<%=strTemp%>" />
    <td bgcolor="#D3D3D3" class="thinborder" align="center"><%=strTemp%></td>
    <td bgcolor="#D3D3D3" class="thinborder" align="center">
		<input name="beginning_bal_<%=iCount%>" type="text" size="6" maxlength="10" /></td>
    <td height="20" bgcolor="#D3D3D3" class="thinborder" align="center"><input type="checkbox" name="save_<%=iCount%>" value="1" checked="checked" tabindex="-1" /></td>
  </tr>	
	<%}%>
	<input type="hidden" name="max_items" value="<%=iCount%>" />
  </table>
 <table width="99%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="29" colspan="8" align="right"><%if(WI.fillTextValue("with_record").equals("1")){%>
      <input type="button" name="save" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
		onclick="javascript:DeleteRecord();" />
click to Delete entries
<%}%>
<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
		onclick="javascript:SaveRecord();" />
click to SAVE entries
<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
		onclick="javascript:CancelRecord();" />
click to CANCEL entries</td>
  </tr>
 </table>
	<%}%>
	<input type="hidden" name="print_pg" /> 
	<input type="hidden" name="page_action" /> 	
	<input type="hidden" name="show_beginning" value="1" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>