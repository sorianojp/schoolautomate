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
	location = "./inv_summary.jsp"; 
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

</script>
</head>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	
	if (WI.fillTextValue("print_pg").length() > 0){%>
		<jsp:forward page="./inv_summary_print.jsp"/>
	  
		<% 
	return;}		
	 	
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-Inventory","inv_summary.jsp");
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
														"inv_summary.jsp");
	
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
	String[] astrSortByName    = {"Item Name","Item Code","Selling Unit"};
	String[] astrSortByVal     = {"item_name","item_code","small.unit_name"};
		
	int iSearchResult = 0;
	int i = 0;
	int iCount = 0;
 
	vRetResult = restItems.getRestaurantItems(dbOP,request);
	if(vRetResult == null)
		strErrMsg = restItems.getErrMsg();
	else
		iSearchResult = restItems.getSearchCount();
	
 %>
<body bgcolor="#eeeeee" topmargin="0">
<form action="inv_summary.jsp" method="post" name="form_">
  <jsp:include page="./tabs.jsp?pgIndex=1"></jsp:include>
<table width="100%" border="0" cellpadding="1" cellspacing="1">
  <tr>
    <td height="29" colspan="12" align="right">&nbsp;</td>
    </tr>
  <tr>
    <td width="11%" align="right">Canteen : </td>
    <td width="89%" height="29" colspan="11" align="left"><select name="restaurant_index" onchange="ReloadPage();">
      <% strTemp= WI.fillTextValue("restaurant_index");%>
      <option value="">Select</option>
      <%=dbOP.loadCombo("TERMINAL_DEPT_INDEX","DEPT_NAME", " from CC_TERMINAL_DEPT where is_valid = 1 " +
												" order by DEPT_NAME",strTemp,false)%>
    </select></td>
    </tr>
  <tr>
    <td align="right">Category : </td>
    <td height="29" colspan="11" align="left"><select name="catg_index">
      <%strTemp= WI.fillTextValue("catg_index");%>
      <option value="">Select Category</option>
      <%=dbOP.loadCombo("item_catg_index","catg_name", " from hms_rest_item_catg order by catg_name",strTemp,false)%>
    </select></td>
    </tr>
  <tr>
    <td align="right">&nbsp;</td>
		<%
			strTemp = WI.fillTextValue("reorder_only");
			if(strTemp.equals("1"))
				strTemp = "checked";
			else
				strTemp = "";
		%>
    <td height="20" colspan="11" align="left"><input type="checkbox" name="reorder_only" value="1" <%=strTemp%> />
    show only items reaching reorder point </td>
    </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td>SORT BY :</td>
      <td width="29%" height="29"><select name="sort_by1">
        <option value="">N/A</option>
					<%=restItems.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td width="30%" height="29"><select name="sort_by2">
        <option value="">N/A</option>
					<%=restItems.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>      
			</select></td>

      <td width="30%" height="29"><select name="sort_by3">
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
    <tr>
      <td height="21">&nbsp;</td>
      <td height="21" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">
        <input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
        <font size="1">click to display item list </font></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="6" align="right" ><font size="2">Number of records per page :</font>
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
    <td height="25" colspan="6" align="right" ><font size="2">Jump To page:
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
    <td height="25" colspan="6" bgcolor="#000033" class="thinborderALL" align="center" ><font color="#FFFFFF"><b>:: LIST OF ITEMS  :: </b></font></td>
  </tr>
  <tr>
    <td width="10%" height="25" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT" align="center"><font color="#000066" size="1"><b>ITEM CODE </b></font></td>
    <td width="33%" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT" align="center"><b><font color="#000066" size="1">ITEM NAME </font></b></td>
    <td width="11%" height="25" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT" align="center"><b><font color="#000066" size="1">PURCHASE UNIT </font></b></td>
    <td width="11%" height="25" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT" align="center"><font color="#000066" size="1"><b>SELLING UNIT </b></font></td>
    <td width="12%" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT" align="center"><b><font color="#000066" size="1">QTY ON HAND<br />
(in Selling Unit ) </font></b></td>
    <td width="12%" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT" align="center"><font color="#000066" size="1"><b>SELLING PRICE </b></font></td>
    </tr>
	<%
	iCount = 1;
	for(i = 0; i < vRetResult.size(); i+=13, iCount++){%>
  <tr>
		<input type="hidden" name="item_inv_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
		<input type="hidden" name="item_mf_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i + 1)%>">		
    <td height="23" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
    <td bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
    <td height="23" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><%=WI.getStrValue((String)vRetResult.elementAt(i+8))%></td>
    <td height="23" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><%=(String)vRetResult.elementAt(i+7)%></td>
		<% strTemp = WI.getStrValue((String)vRetResult.elementAt(i+11),"0"); %>
		<td align="right" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
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