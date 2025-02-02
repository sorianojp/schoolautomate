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
	document.form_.page_action.value = "";	
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');	
}

function SaveRecord(){
	document.form_.page_action.value = "1";
	this.SubmitOnce('form_');	
}
function DeleteRecord(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = 0;
	this.SubmitOnce('form_');
}

function EditRecord(){
	document.form_.page_action.value = 2;
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');	
}

function CancelRecord() 
{
	location = "./item_master_list_manage.jsp"; 
}
 
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function PrintPg(){
	document.form_.print_pg.value = 1;
	this.SubmitOnce('form_');
}

function viewList(table,indexname,colname,labelname,tablelist, 
									strIndexes, strExtraTableCond,strExtraCond,
									strFormField){				
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//      <a href='javascript:viewList("hms_lf_item_loc","lf_item_loc","location",
//			 "LOCATION", "hms_lf_item", "location_ref",
//				 "","","location_ref");'>
</script></head>
</html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
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
								"Admin/staff-Cash Card-Inventory-Manage Item Master List","item_master_list_manage.jsp");
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
														"item_master_list_manage.jsp");
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
	int iSearchResult = 0;
	int i = 0;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
 	String strPageAction = WI.fillTextValue("page_action");
 	if(strPageAction.length() > 0){
		vRetResult = restItems.operateOnInventoryItems(dbOP, request, Integer.parseInt(strPageAction));
		if(vRetResult == null)
			strErrMsg = restItems.getErrMsg();
		else 
			strPrepareToEdit = "0"; 
 	}

	if(strPrepareToEdit.compareTo("1") == 0)
		vEditInfo = restItems.operateOnInventoryItems(dbOP, request, 3); 

	vRetResult = restItems.operateOnInventoryItems(dbOP,request,4);
	if(vRetResult != null)
		iSearchResult = restItems.getSearchCount();
 %>
<body topmargin="0" bgcolor="#eeeeee">
<form action="item_master_list_manage.jsp" method="post" name="form_">
  <table border="0" cellspacing="0" cellpadding="0" >
	  <tr>
		<td background=".././../../images/tableft.gif" height="24" width="10">&nbsp;</td>
		<td width="120" bgcolor="#00468C" align="center"><a href="item_master_list.jsp">Items Summary  </a></td>
		<td background=".././../../images/tabright.gif" width="10">&nbsp;</td>
		<td background=".././../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
		<td width="130" bgcolor="#A9B9D1" align="center" class="tabFont" >Add/Edit Items </td>
		<td background=".././../../images/tabright_selected.gif" width="10">&nbsp;</td>
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
    <tr> 
      <td height="20" colspan="4"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1" /></td>
    </tr>
    <tr> 
      <td width="15%" height="25" align="right"><b><font color="#000066">Category 
        : </font></b></td>
      <td width="34%" height="25"><select name="catg_index">
          <%if(vEditInfo != null  && vEditInfo.size() > 0) 
					strTemp = (String)vEditInfo.elementAt(1);
				else 
					strTemp= WI.fillTextValue("catg_index");
			%>
          <option value="">Select Category</option>
          <%=dbOP.loadCombo("item_catg_index","catg_name", " from hms_rest_item_catg order by catg_name",strTemp,false)%> </select> 
		  
		  &nbsp;&nbsp;
		  <a href='javascript:viewList("hms_rest_item_catg","item_catg_index","catg_name","CATEGORY", "hms_rest_item_inv_mf", "catg_index"," and is_valid = 1","","catg_index");'> 
        <u><font color="#FF6633"><b>UPDATE</b></font></u></a> </td>
      <td width="13%" height="25" align="right">&nbsp;</td>
      <td width="38%" height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" align="right"><b><font color="#000066">Item Code :</font></b></td>
      <%if(vEditInfo != null  && vEditInfo.size() > 0) 
				strTemp = (String)vEditInfo.elementAt(3);
			else 
				strTemp = WI.fillTextValue("item_code");
		%>
      <td height="25"><input name="item_code" type="text" size="18"  maxlength="18" value="<%=strTemp%>" 
			class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" /></td>
      <td align="right"><b><font color="#000066">Purchase Unit : </font></b></td>
      <td><select name="pur_unit_index">
          <%if(vEditInfo != null  && vEditInfo.size() > 0) 
					strTemp = (String)vEditInfo.elementAt(5);
				else
					strTemp= WI.fillTextValue("pur_unit_index");
			%>
          <option value="">Select Purchasing Unit</option>
          <%=dbOP.loadCombo("UNIT_INDEX","UNIT_NAME", " from PUR_PRELOAD_UNIT order by UNIT_NAME",strTemp,false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" align="right"><b><font color="#000066">Item Name :</font></b></td>
      <%if(vEditInfo != null  && vEditInfo.size() > 0) 
				strTemp = (String)vEditInfo.elementAt(4);
			else 
				strTemp = WI.fillTextValue("item_name");
		%>
      <td height="25"><input name="item_name" type="text" size="32"  maxlength="32" value="<%=strTemp%>" 
			class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" /></td>
      <td align="right"><b><font color="#000066">Selling Unit : </font></b></td>
      <td><select name="sell_unit_index">
          <%if(vEditInfo != null  && vEditInfo.size() > 0) 
					strTemp = (String)vEditInfo.elementAt(7);
				else
					strTemp= WI.fillTextValue("sell_unit_index");
			%>
          <option value="">Select Selling Unit</option>
          <%=dbOP.loadCombo("UNIT_INDEX","UNIT_NAME", " from PUR_PRELOAD_UNIT order by UNIT_NAME",strTemp,false)%> </select> 
		  &nbsp;&nbsp;
		  <a href='javascript:viewList("pur_preload_unit","UNIT_INDEX","UNIT_NAME","UNIT NAME", "hms_rest_item_inv, hms_rest_item_inv", "pur_unit_index, sell_unit_index"," and is_valid = 1, and is_valid = 1","","catg_index");'> 
        <u><font color="#FF6633"><b>UPDATE</b></font></u></a> </td>
    </tr>
    <tr> 
      <td height="27" align="right"><b><font color="#000066">Selling Price :</font></b></td>
      <%if(vEditInfo != null  && vEditInfo.size() > 0) 
				strTemp = (String)vEditInfo.elementAt(10);
			else 
				strTemp = WI.fillTextValue("selling_price");
			strTemp = CommonUtil.formatFloat(strTemp, true);
			strTemp = ConversionTable.replaceString(strTemp, ",", "");
		%>
      <td height="27"><b><font color="#000066">Php</font></b> <input name="selling_price" type="text" size="10"  maxlength="16" value="<%=strTemp%>" 
			class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="AllowOnlyFloat('form_','selling_price');style.backgroundColor='white'" onkeyup="AllowOnlyFloat('form_','selling_price')">      </td>
      <td align="right"><b><font color="#000066">Conversion :</font></b></td>
      <%
			if(vEditInfo != null  && vEditInfo.size() > 0) 
				strTemp = (String)vEditInfo.elementAt(9);
			else
				strTemp = WI.fillTextValue("conversion");
		%>
      <td><input name="conversion" type="text" size="10"  maxlength="16" value="<%=WI.getStrValue(strTemp)%>" 
			class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="AllowOnlyInteger('form_','conversion');style.backgroundColor='white'" onkeyup="AllowOnlyInteger('form_','conversion')"></td>
    </tr>
    <tr>
      <td height="25" align="right"><b><font color="#000066">Item Cost :</font></b></td>
      <%if(vEditInfo != null  && vEditInfo.size() > 0) 
				strTemp = (String)vEditInfo.elementAt(15);
			else 
				strTemp = WI.fillTextValue("item_cost");
			strTemp = CommonUtil.formatFloat(strTemp, true);
			strTemp = ConversionTable.replaceString(strTemp, ",", "");
		%>	  
      <td height="25"><b><font color="#000066">Php</font></b> <input name="item_cost" type="text" size="10"  maxlength="16" value="<%=strTemp%>" 
			class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="AllowOnlyFloat('form_','item_cost');style.backgroundColor='white'" onkeyup="AllowOnlyFloat('form_','item_cost')">	  </td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" align="right"><b><font color="#000066">Tax : </font></b></td>
      <%if(vEditInfo != null  && vEditInfo.size() > 0) 
				strTemp = (String)vEditInfo.elementAt(11);
			else 
				strTemp = WI.fillTextValue("tax");
		%>
      <td height="25"><input name="tax" type="text" size="10"  maxlength="16" value="<%=strTemp%>" 
			class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="AllowOnlyInteger('form_','tax');style.backgroundColor='white'" onkeyup="AllowOnlyInteger('form_','tax')" />
      %</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" align="right"><b><font color="#000066">Options : </font></b></td>
      <%
				if(vEditInfo != null  && vEditInfo.size() > 0) 
					strTemp = (String)vEditInfo.elementAt(12);
				else 
					strTemp = WI.fillTextValue("is_tax_included");
					
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
			%>
      <td height="25"><input type="checkbox" name="is_tax_included" value="1" <%=strTemp%>/> 
        <font size="1">Tax is included in the selling price</font></td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" align="right">&nbsp;</td>
      		<%
				strTemp = WI.fillTextValue("is_inv_item");
				if(vEditInfo != null  && vEditInfo.size() > 0) 
					strTemp = (String)vEditInfo.elementAt(13);
				
				if(strTemp.equals("0"))
					strErrMsg = " checked";
				else
					strErrMsg = "";
			%>
      <td height="25">
	  			<input type="radio" name="is_inv_item" value="0" <%=strErrMsg%>>NON-INVENTORY ITEM
				<%
					if(strTemp.length() == 0 || strTemp.equals("1"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
				%>
				<input type="radio" name="is_inv_item" value="1" <%=strErrMsg%>>INVENTORY ITEM</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    
    <tr> 
      <td height="25" align="right">&nbsp;</td>
      <td height="25" colspan="3"><font size="1" color="#000066"> 
        <%if(strPrepareToEdit.equals("1")){%>
        <input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onclick="javascript:EditRecord();" />
        click to SAVE entries 
        <%}else{%>
        <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onclick="javascript:SaveRecord();" />
        click to SAVE entries 
        <%}%>
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onclick="javascript:CancelRecord();" />
        click to CANCEL entries</font></td>
    </tr>
    <tr>
      <td height="20" align="right">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" align="right"><b><font color="#000066">View Option: </font></b></td>
      <td height="25" colspan="3">
			<select name="category" onchange="ReloadPage();">
        <% strTemp= WI.fillTextValue("category");%>
        <option value="">Select Category</option>
        <%=dbOP.loadCombo("item_catg_index","catg_name", " from hms_rest_item_catg order by catg_name",strTemp,false)%>
      </select></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="22" colspan="5"  align="right"><font size="2">Number of records per page :</font>
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
      <input type="button" name="cancel3" value=" Print " style="font-size:11px; height:22px;border: 1px solid #FF0000;" 
					onclick="javascript:PrintPg();" />
      </font><font color="#000066" size="1">Click to PRINT listing </font></td>
  </tr>
    <%		
	int iPageCount = iSearchResult/restItems.defSearchSize;		
	if(iSearchResult % restItems.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>	
  <tr>
    <td height="22" colspan="5"  align="right"><font size="2">Jump To page:
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
    <td height="25" colspan="10" bgcolor="#000033" class="thinborderALL" align="center" ><font color="#FFFFFF"><b>:: LIST OF ITEMS CREATED  ::</b></font></td>
  </tr>
  </table> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#A9B9D1" class="thinborder">
    <tr> 
      <td width="10%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>CATEGORY</b></font></td>
      <td width="10%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>ITEM 
        CODE </b></font></td>
      <td width="22%" bgcolor="#D3D3D3" class="thinborder" align="center"><b><font color="#000066" size="1">ITEM 
        NAME </font></b></td>
      <td width="10%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><b><font color="#000066" size="1">PURCHASE 
        UNIT </font></b></td>
      <td width="10%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>SELLING 
        UNIT </b></font></td>
      <td width="6%" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>CONVERSION</b></font></td>
      <td width="6%" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>AT 
        COST </b></font></td>
      <td width="6%" bgcolor="#D3D3D3" class="thinborder" align="center"><font color="#000066" size="1"><b>SELLING 
        PRICE </b></font></td>
      <td width="10%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><b><font color="#000066" size="1"><font color="#000066">DATE 
        CREATED </font> </font></b></td>
      <td width="10%" height="25" bgcolor="#D3D3D3" class="thinborder" align="center"><b><font color="#000066" size="1">OPTIONS</font></b></td>
    </tr>
    <%for(i = 0; i < vRetResult.size(); i+= 17){%>
    <tr> 
      <td height="20" bgcolor="#D3D3D3" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
      <td bgcolor="#D3D3D3" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td bgcolor="#D3D3D3" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
      <td height="20" bgcolor="#D3D3D3" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6),"n/a")%></td>
      <td height="20" bgcolor="#D3D3D3" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+8)%></td>
      <td bgcolor="#D3D3D3" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9),"n/a")%></td>
      <%
			strTemp = (String)vRetResult.elementAt(i+15);
			strTemp = CommonUtil.formatFloat(strTemp, true);
		%>
      <td align="right" bgcolor="#D3D3D3" class="thinborder"><%=strTemp%></td>
      <%
			strTemp = (String)vRetResult.elementAt(i+10);
			strTemp = CommonUtil.formatFloat(strTemp, true);
		%>
      <td align="right" bgcolor="#D3D3D3" class="thinborder"><%=strTemp%>&nbsp;</td>
      <td height="20" bgcolor="#D3D3D3" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+14)%></td>
      <td height="20" bgcolor="#D3D3D3" class="thinborder"><font size="1"> 
        <input type="button" name="cancel222" value="  Edit  " style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
					onclick="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');" />
        <input type="button" name="cancel22" value="Delete" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
					onclick="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>');" />
        </font></td>
    </tr>
    <%}%>
  </table>
<%}%>
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>" />
	<input type="hidden" name="page_action" />
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" />
	<input type="hidden" name="print_pg" /> 
</form>
    </body>
</html>

<%
dbOP.cleanUP();
%>