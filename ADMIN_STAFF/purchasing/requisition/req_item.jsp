<%@ page language="java" import="utility.*,purchasing.Requisition,java.util.Vector" %>
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function UpdateBrand(){
	document.form_.printPage.value = "";
	var loadPg = "../../inventory/inv_log/update_brand.jsp?opner_form_name=form_&opner_form_field=brand&inv_cat_index="+document.form_.cat_index.value;
	var win=window.open(loadPg,"UpdateBrand",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ViewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	document.form_.printPage.value = "";
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function PageAction(strAction,strIndex,strDelItem){
	if(strAction == 0){
		var vProceed = confirm('Delete '+strDelItem+' ?');
		if(vProceed){
			document.form_.pageAction.value = strAction;
			document.form_.strIndex.value = strIndex;
			document.form_.printPage.value = "";
			this.SubmitOnce('form_');
		}		
	} else {
		document.form_.pageAction.value = strAction;
		document.form_.strIndex.value = strIndex;
		document.form_.printPage.value = "";
		this.SubmitOnce('form_');
	}	
}
function CancelRecord(){
  document.form_.cancelClicked.value = "1";
	document.form_.proceedClicked.value = "1";
	document.form_.pageAction.value = "";
	document.form_.strIndex.value = "";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
function PageLoad(){
 	document.form_.req_no.focus();
}
function OpenSearch(strSupply){
	document.form_.printPage.value = "";
	var pgLoc = "../requisition/requisition_view_search.jsp?opner_info=form_.req_no&is_supply=form_.is_supply&nsupply="+strSupply;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage(){
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function ChangeType(){
	document.form_.printPage.value = "";
	document.form_.cat_index.value = "";
	document.form_.class_index.value = "";	
	document.form_.brand.value = "";	
	this.SubmitOnce('form_');
}

</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<%if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="req_item_print.jsp"/>
	<%return;}
	
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-REQUISITION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}

	if(WI.fillTextValue("my_home").equals("1"))
		iAccessLevel = 2 ;
	
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
								"Admin/staff-PURCHASING-REQUISITION-Requisition Items","req_item.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.

	Requisition REQ = new Requisition();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vRetResult = null;
	boolean bolIsErr = false;
	boolean bolAllowEdit = false;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode ="";
		
	String strSupply = WI.getStrValue(WI.fillTextValue("is_supply"),"0");
	String[] astrSupplyVal = {"0","1","2","3"};
	String[] astrSupplyType = {"Non-Supplies / Equipmment","Supplies","Chemical","Computers/Parts"};	
	int iDefault = 0;
	String strCategory = null;
	String strClass = null;
	String strItem = null;
	
	//added 2014-09-10 to handle the following
	//1. if requisition is approved, can't add items, can't delete and item. 

	vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);
	if(vReqInfo == null && WI.fillTextValue("req_no").length() > 0
	     				&& WI.fillTextValue("pageAction").length() < 1)
		strErrMsg = REQ.getErrMsg();
	if(WI.fillTextValue("req_no").length() < 1)
		strErrMsg = "Input Requisition No.";

	if(vReqInfo != null && vReqInfo.size() > 0){
		//strSupply = (String)vReqInfo.elementAt(19);
		/** modified to if approved, cna't modify anymore.
		strTemp = dbOP.mapOneToOther("pur_po_info", "requisition_index",
								 (String)vReqInfo.elementAt(0), "po_index", "and is_del = 0");
		if(strTemp == null){
			bolAllowEdit = true;
		}
		**/
		if(!vReqInfo.elementAt(10).equals("1"))
			bolAllowEdit = true;

	}				
	if(WI.fillTextValue("pageAction").length() > 0){
		vRetResult = REQ.operateOnReqItems(dbOP,request,Integer.parseInt(WI.fillTextValue("pageAction")));
		if(vRetResult == null){
			strErrMsg = REQ.getErrMsg();
			if(WI.fillTextValue("pageAction").equals("2"))
				bolIsErr = true;
		}			
		else{
			if(!WI.fillTextValue("pageAction").equals("3")){
				strErrMsg = "Operation Successful.";
				vRetResult = null;
			}				
		}	
	}	
	vReqItems = REQ.operateOnReqItems(dbOP,request,4);		
%>
<form name="form_" method="post" action="./req_item.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">    
	<tr bgcolor="#A49A6A">
      <td height="25" align="center"><font color="#FFFFFF"><strong>:::: 
      REQUISITION : ENCODE ITEM REQUISITION PAGE ::::</strong></font></td>
    </tr>	  
  
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="21%">Requisition No.</td>
      <td width="76%"><strong> 
        <input type="text" name="req_no" class="textbox" value="<%=WI.fillTextValue("req_no")%>"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong>&nbsp;
		<a href="javascript:OpenSearch('<%=WI.getStrValue(WI.fillTextValue("is_supply"),"0")%>');">
		<img src="../../../images/search.gif" border="0"></a>
		<a href="javascript:ProceedClicked();"> 
        <img src="../../../images/form_proceed.gif" border="0">
        </a>
	  </td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%if(vReqInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="3%" height="26">&nbsp;</td>
      <td colspan="4" align="center"><strong>REQUISITION DETAILS </strong></td>
    </tr>
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="25%"><strong><%=WI.fillTextValue("req_no")%></strong></td>
      <td width="21%">Requested By :</td>
      <td width="29%"> <strong><%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(1))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vReqInfo.elementAt(5)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(10))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(7)%></strong></td>
    </tr>
	<%if(((String)vReqInfo.elementAt(3)).equals("0")){%> 
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></strong></td>
    </tr>
	<%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)+"/"+WI.getStrValue((String)vReqInfo.elementAt(9),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></strong></td>
    </tr>
	<%}%>	
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td  height="25" colspan="3"><hr size="1"> </td>
    </tr>
<%if(bolAllowEdit){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td valign="bottom">Inventory Type</td>
      <td colspan="3">
			<%if(vRetResult != null && vRetResult.size() > 3)
	  		strTemp = (String)vRetResult.elementAt(13);				
	    else if(WI.fillTextValue("is_supply").length() > 0 && !WI.fillTextValue("cancelClicked").equals("1"))
	  		strTemp = WI.fillTextValue("is_supply");
			else
				strTemp = "";
			strSupply = WI.getStrValue(strTemp,"0");
	  %>
			<select name="select" onChange="ChangeType();">
              <option value="0"><%=astrSupplyType[0]%></option>
              <%for(int i = 1; i < 4; i++){%>
              <%if(strSupply.equals(Integer.toString(i))){%>
              <option value="<%=i%>" selected><%=astrSupplyType[i]%></option>
              <%}else{%>
              <option value="<%=i%>"><%=astrSupplyType[i]%></option>
              <%}%>
              <%}%>
            </select></td>
    </tr>

	
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="bottom"> Item Category</td>
      <td valign="bottom">
	  <%if(vRetResult != null && vRetResult.size() > 3)
	  		strTemp = (String)vRetResult.elementAt(11);				
	    else if(WI.fillTextValue("cat_index").length() > 0 && !WI.fillTextValue("cancelClicked").equals("1"))
	  		strTemp = WI.fillTextValue("cat_index");
			else
				strTemp = "";
			strCategory = WI.getStrValue(strTemp,WI.fillTextValue("cat_index"));

	  %>
	  <select name="cat_index" onChange="ReloadPage();">
				<option value="">Select Category</option>
        <%=dbOP.loadCombo("inv_cat_index","inv_category"," from inv_preload_category " +
		  					"where is_supply_cat = " + strSupply + "order by inv_category", strTemp, false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="bottom">Item Classification </td>
      <td valign="bottom">
	  <%if(vRetResult != null && vRetResult.size() > 3){
	  		strTemp = (String)vRetResult.elementAt(12);
	    }else if(WI.fillTextValue("class_index").length() > 0 && !WI.fillTextValue("cancelClicked").equals("1")){
	  		strTemp = WI.fillTextValue("class_index");
			}else
				strTemp = "";			
			strClass = WI.getStrValue(strTemp,"");
	  %>
        <select name="class_index" onChange="ReloadPage();">
          <option value="">Select Class</option>
          <%=dbOP.loadCombo("inv_class_index","classification"," from inv_preload_class " +
		  					" where inv_cat_index = " + WI.getStrValue(strCategory,"-1") + 
								" order by classification", strTemp, false)%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="bottom">Item :</td>
      <td width="75%" valign="bottom"> 
	  <%if(vRetResult != null && vRetResult.size() > 3)
	  		strTemp = (String)vRetResult.elementAt(0);
	    else if(WI.fillTextValue("item_index").length() > 0 && !WI.fillTextValue("cancelClicked").equals("1"))
	  		strTemp = WI.fillTextValue("item_index");
			else
				strTemp = "";
			strItem = WI.getStrValue(strTemp,"-1");
	  %> 
	  <select name="item_index" onChange="ReloadPage();">
          <option value="">Select Item</option>
          <%=dbOP.loadCombo("item_index","item_name"," from pur_preload_item " +
		  " where inv_cat_index =" + WI.getStrValue(strCategory,"-1") +
		  " and exists(select * from inv_reg_item where PUR_PRELOAD_ITEM.ITEM_INDEX = ITEM_INDEX)" +
		  WI.getStrValue(strClass," and inv_class_index = ","","") +
		  " order by ITEM_NAME asc",strTemp, false)%> 
 	  </select> 
	  <!--
	  <a href="javascript:UpdateItem()";> 
	  <img src="../../../images/update.gif" width="60" height="25" border="0">
	  </a> 
	  --></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="bottom">Particulars/Item Description : </td>
      <td> <%
	  	if(vRetResult != null)
			strTemp = (String)vRetResult.elementAt(2);
	    else if(WI.fillTextValue("particular").length() > 0 && !WI.fillTextValue("cancelClicked").equals("1"))
	  		strTemp = WI.fillTextValue("particular");
		else
			strTemp = "";  
	  %> <input name="particular" type="text" size="64" class="textbox" value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="22%" valign="bottom">Quantity :</td>
      <td valign="bottom"> <%
	      if(vRetResult != null)
		  	strTemp = (String)vRetResult.elementAt(1);
	      else if(WI.fillTextValue("qty").length() > 0 && !WI.fillTextValue("cancelClicked").equals("1"))
			strTemp = WI.fillTextValue("qty");
		  else
		   	strTemp = "";		
		%> <input name="qty" type="text" size="5" class="textbox" value="<%=strTemp%>"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="AllowOnlyIntegerExtn('form_','qty','.')"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="bottom">Unit :</td>
      <td> 
			<% if(vRetResult != null)
				  	strTemp = (String)vRetResult.elementAt(3);
	       else if(WI.fillTextValue("unit_index").length() > 0 && !WI.fillTextValue("cancelClicked").equals("1"))
	  				strTemp = WI.fillTextValue("unit_index");
			   else
						strTemp = ""; %> 
				<select name="unit_index">
          <option value="">Select unit</option>
          <%=dbOP.loadCombo("UNIT_INDEX","UNIT_NAME"," from PUR_PRELOAD_UNIT " +
		  			" where exists(select * from inv_reg_item where item_index = " + WI.getStrValue(strItem,"0") + 
						" and (UNIT_INDEX = small_unit or unit_index = big_unit))" + 
						" order by UNIT_NAME asc ", strTemp, false)%> </select> 
		  
		  <!--
		  <a href='javascript:ViewList("PUR_PRELOAD_UNIT","UNIT_INDEX","UNIT_NAME","UNIT",
									   "PUR_REQUISITION_ITEM","UNIT_INDEX", 
				                       " and PUR_REQUISITION_ITEM.is_del = 0","","unit_index")'>	
          <img src="../../../images/update.gif" width="60" height="25" border="0"></a> 
		  -->      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="bottom">Unit Price :</td>
      <td> <%
	      if(vRetResult != null)
		  	strTemp = WI.getStrValue((String)vRetResult.elementAt(6),"");
	      else if(WI.fillTextValue("unit_price").length() > 0 && !WI.fillTextValue("cancelClicked").equals("1"))
	  		strTemp = WI.fillTextValue("unit_price");
		  else
			strTemp = "";	  
	  %> <input type="text" name="unit_price" class="textbox" value="<%=strTemp%>"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="AllowOnlyIntegerExtn('form_','unit_price','.')"></td>
    </tr>
    <%if(WI.fillTextValue("is_supply").equals("1")){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="bottom">Availability :</td>
      <td> <%if(vRetResult != null)
		 	strTemp = (String)vRetResult.elementAt(5);
		   else if(WI.fillTextValue("in_stock").length() > 0 && !WI.fillTextValue("cancelClicked").equals("1"))
		   	 strTemp = WI.fillTextValue("in_stock");
		   else
		   	 strTemp = "";
				 strTemp = WI.getStrValue(strTemp,"");
	  	  %> <select name="in_stock" onChange="ProceedClicked()">
          <option value="1">Available</option>
          <%if(strTemp.equals("0")){%>
          <option value="0" selected>Not Available</option>
          <%}else{%>
          <option value="0">Not Available</option>
          <%}%>
        </select> <%if(!WI.fillTextValue("in_stock").equals("0")){
		if(vRetResult != null)
			strTemp = WI.getStrValue((String)vRetResult.elementAt(7),"");
		  else if(WI.fillTextValue("stock_qty").length() > 0 && !WI.fillTextValue("cancelClicked").equals("1"))
			strTemp = WI.fillTextValue("stock_qty");
		  else
		  	strTemp = "";%> <input name="stock_qty" type="text" size="5" class="textbox" value="<%=strTemp%>"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="AllowOnlyIntegerExtn('form_','stock_qty','.')"> <font size="1">(Qty. 
        Available)</font> <%}%> </td>
    </tr>
    <%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="bottom">Brand:</td>
      <td> <%
	      if(vRetResult != null)
		  	strTemp = (String)vRetResult.elementAt(4);
	      else if(WI.fillTextValue("brand").length() > 0 && !WI.fillTextValue("cancelClicked").equals("1"))
			strTemp = WI.fillTextValue("brand");
		  else
		  	strTemp = "";		
		%> <select name="brand">
          <option value="">Select brand</option>
          <%=dbOP.loadCombo("BRAND_INDEX","BRAND_NAME"," from PUR_PRELOAD_BRAND " +
														" where inv_cat_index = " + WI.getStrValue(strCategory,"-1") +
														" order by BRAND_NAME asc", strTemp, false)%> 
			 </select> 
			 <%if(strCategory.length() > 0){%>
			 <!--<a href='javascript:ViewList("PUR_PRELOAD_BRAND","BRAND_INDEX","BRAND_NAME","BRAND NAME",
							 "PUR_REQUISITION_ITEM","ITEM_BRAND_INDEX", 
							 " and PUR_REQUISITION_ITEM.is_del = 0","","brand")'>	
				-->
				<a href='javascript:UpdateBrand();'>					
        <img src="../../../images/update.gif" width="60" height="25" border="0"></a>
				<font size="1">click to UPDATE list of Brand Name</font>
			 <%}%>		 </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="bottom">Supplier : </td>
      <td> <%
	    if(vRetResult != null)
			strTemp = (String)vRetResult.elementAt(8);
	    else if(WI.fillTextValue("supplier").length() > 0 && !WI.fillTextValue("cancelClicked").equals("1"))
	  		strTemp = WI.fillTextValue("supplier");
		else
			strTemp = "";	  
	  %> <select name="supplier">
          <option value="">Select supplier</option>
          <%=dbOP.loadCombo("PROFILE_INDEX","SUPPLIER_CODE",
		  " from PUR_SUPPLIER_PROFILE	where is_del = 0 and status = 1 order by SUPPLIER_CODE asc", 
		  strTemp, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="bottom">Level of Urgency:</td>
      <td> <%
	    if(vRetResult != null)
			strTemp = (String)vRetResult.elementAt(10);
	    else if(WI.fillTextValue("urgency").length() > 0 && !WI.fillTextValue("cancelClicked").equals("1"))
	  		strTemp = WI.fillTextValue("urgency");
		else
			strTemp = "";	  
	    %> <select name="urgency">
          <option value="1">Normal</option>
          <%if(strTemp.equals("0")){%>
          <option value="0" selected>Low</option>
          <option value="2">High</option>
          <%}else if(strTemp.equals("2")){%>
          <option value="0">Low</option>
          <option value="2" selected>High</option>
          <%}else{%>
          <option value="0">Low</option>
          <option value="2">High</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="bottom">Remarks : </td>
      <td> <%
	      if(vRetResult != null)
		  	strTemp = WI.getStrValue((String)vRetResult.elementAt(9),"");
	      else if(WI.fillTextValue("remarks").length() > 0 && !WI.fillTextValue("cancelClicked").equals("1"))
			strTemp = WI.fillTextValue("remarks");
		  else
		  	strTemp = "";
			%> <input name="remarks" type="text" class="textbox" value="<%=strTemp%>"size="64" maxlength="64" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
	<tr> 
	  <td height="25" colspan="3"> <div align="center"> 
		  <%if(vRetResult == null && !bolIsErr){%>
		  <a href="javascript:PageAction(1,0,'');"> <img src="../../../images/add.gif" border="0"></a> 
		  <font size="1" >click to save entry</font> 
		  <%}else{%>
		  <a href="javascript:PageAction(2,<%=WI.fillTextValue("strIndex")%>,'');"><img src="../../../images/edit.gif" border="0"></a> 
		  <font size="1">click to save changes</font> <a href="javascript:CancelRecord();"> 
		  <img src="../../../images/cancel.gif" border="0"></a> <font size="1">click 
		  to cancel edit</font> 
		  <%}%>
		</div></td>
	</tr>
<%}else{%>
		<tr> 
		  <td height="25" colspan="3" style="font-weight:bold; font-size:16px;"> Requisition already Approved. Modification not allowed</td>
		</tr>
<%}%>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;</td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;</td>
      <td height="29"><div align="right"> 
          <%if(vReqItems != null){
		  //System.out.println(strSchCode);%>
          <%if (!strSchCode.startsWith("UI")){%>
          <font size="1">Items per page</font> 
          <select name="num_rows">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rows"),"15"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <%}else{%>
          <input type="hidden" name="num_rows" value="15">
          <%}%>
          <a href="javascript:PrintPage();"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print Requisition Form</font> 
          <%}%>
        </div></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <%if(vReqItems != null){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
      <%if(WI.fillTextValue("is_supply").equals("0")){%>
	  <tr>
      	  <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT">
		  <div align="center"><font color="#FFFFFF"><strong>LIST OF REQUESTED ITEMS</strong></font></div>
		  </td>
	  </tr>
	  <%}else{%>
	  <tr>
	  	  <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT">
		  <div align="center"><font color="#FFFFFF"><strong>LIST OF REQUESTED SUPPLIES</strong></font></div>
		  </td>
	  </tr>
	  <%}%>    
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td height="25" colspan="10" class="thinborder">Requested by : <strong><%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td width="5%" height="25" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong>QUANTITY</strong></div></td>
      <td width="4%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="4%" class="thinborder"><div align="center"><strong>ITEM</strong></div></td>
      <td width="21%" class="thinborder"><div align="center"><strong>PARTICULARS/ITEM DESCRIPTION </strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong>SUPPLIER</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>EDIT</strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong>DELETE</strong></div></td>
    </tr>
    <% int iCountItem = 0;
	for(int iLoop = 2;iLoop < vReqItems.size();iLoop+=9,iCountItem++){%>
	<tr> 
      <td height="25" class="thinborder"><div align="center"><%=(iLoop+7)/9%></div></td>
      <td class="thinborder"><div align="center"><%=vReqItems.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItems.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItems.elementAt(iLoop+3)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItems.elementAt(iLoop+4)%></div></td>
      <td class="thinborder"><div align="left"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+5),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+6),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right">
	  	<%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
	 		&nbsp;
		<%}else{%>
			<%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%>
		<%}%></div></td>
      <td class="thinborder"> 
        <%if (bolAllowEdit){%>		
		    <a href="javascript:PageAction(3,<%=vReqItems.elementAt(iLoop)%>,'');"> 
	        <img src="../../../images/edit.gif" border="0"></a> 
		<%}else{%>	
			N/A
		<%}%>
	  </td>
      <td class="thinborder"> 
	  <%if(iAccessLevel == 2 && bolAllowEdit){%>
	  <a href="javascript:PageAction(0,<%=vReqItems.elementAt(iLoop)%>,'<%=vReqItems.elementAt(iLoop+3)%>')">
	  <img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
		N/A
		<%}%>
	  </td>
    </tr>
	<%} // end for loop%>
	<input type="hidden" name="item_count" value="<%=iCountItem%>">
    <tr> 
      <td class="thinborder" height="25" colspan="5">
	  <div align="left"><strong>TOTAL ITEM(S) : <%=vReqItems.elementAt(0)%></strong></div></td>
      <td class="thinborder" height="25" colspan="2"><div align="right"><strong>TOTAL AMOUNT : </strong></div></td>
      <td class="thinborder" height="25"><div align="right"><strong><%=vReqItems.elementAt(1)%></strong></div></td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%}
}else{%>
 <input type="hidden" name="is_supply">
<%}%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">   
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!--
  <input type="hidden" name="is_supply" value="<%=strSupply%>">
  -->
  <input type="hidden" name="proceedClicked" value="">
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="cancelClicked" value="">
  <input type="hidden" name="strIndex" value="<%=WI.fillTextValue("strIndex")%>">
  <input type="hidden" name="printPage" value=""> 
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>"> 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>