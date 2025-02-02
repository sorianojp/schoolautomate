<%@ page language="java" import="utility.*,purchasing.Requisition,purchasing.PO,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);

	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

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
	document.form_.focus_area.value = "";
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function PageAction(strAction,strInfoIndex,strDelItem){
	if(strAction == 0){
		document.form_.focus_area.value = "3";
		var vProceed = confirm('Delete '+strDelItem+' ?');
		if(vProceed){
			document.form_.pageAction.value = strAction;
			document.form_.info_index.value = strInfoIndex;
			document.form_.printPage.value = "";
			this.SubmitOnce('form_');
		}		
	} else {
		document.form_.focus_area.value = "2";
		document.form_.pageAction.value = strAction;
		document.form_.info_index.value = strInfoIndex;
		document.form_.printPage.value = "";
		this.SubmitOnce('form_');
	}	
}
function CancelRecord(){
  document.form_.cancelClicked.value = "1";
	document.form_.proceedClicked.value = "1";
	document.form_.pageAction.value = "";
	document.form_.info_index.value = "";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
function PageLoad(){
	var pageNo = "";
	pageNo = <%=WI.getStrValue(WI.fillTextValue("focus_area"),"1")%>
	if(eval('document.form_.req_no'+pageNo))
		eval('document.form_.req_no'+pageNo+'.focus()');
	else
		document.form_.req_no.focus();
 	//document.form_.req_no.focus();
}

function OpenSearchPO(){
	document.form_.printPage.value = "";
	var pgLoc = "../purchase_order/purchase_request_view_search.jsp?opner_info=form_.req_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage(){
	document.form_.category_name.value = document.form_.cat_index[document.form_.cat_index.selectedIndex].text;
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}

function getPrepName(){
	document.form_.preparation.value = document.form_.prep_index[document.form_.prep_index.selectedIndex].text;	
}
function getBrandName(){
	document.form_.brand_name.value = document.form_.brand[document.form_.brand.selectedIndex].text;	
}
function ChangeType(){
	document.form_.printPage.value = "";
	document.form_.cat_index.value = "";
	document.form_.class_index.value = "";	
	document.form_.brand.value = "";	
	document.form_.category_name.value = "";	
	document.form_.focus_area.value = "2";
	this.SubmitOnce('form_');
}

</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<%		
    if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="free_item_print.jsp"/>
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
								"Admin/staff-PURCHASING-REQUISITION-Requisition Items","free_item.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authentication code.

	Requisition REQ = new Requisition();	
	PO PO = new PO();
	Vector vReqInfo = null;
	Vector vFreeItems = null;
	Vector vRetResult = null;
	boolean bolIsErr = false;
	boolean bolAllowEdit = false;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String strSchCode = dbOP.getSchoolIndex();
	String strSupply = WI.getStrValue(WI.fillTextValue("is_supply"),"0");
	String[] astrSupplyVal = {"0","1","2","3"};
	String[] astrSupplyType = {"Non-Supplies / Equipmment","Supplies","Chemical","Computers/Parts"};	
	int iDefault = 0;
	String strCategory = null;
	String strClass = null;
	String strItem = null;
	
	if(WI.fillTextValue("proceedClicked").length() > 0){
		vReqInfo = PO.operateOnReqInfo(dbOP,request,3);
		if(vReqInfo == null && WI.fillTextValue("req_no").length() > 0
								&& WI.fillTextValue("pageAction").length() < 1)
			strErrMsg = PO.getErrMsg();
		
		if(WI.fillTextValue("req_no").length() < 1)
			strErrMsg = "Input Requisition No.";

		if(vReqInfo != null && vReqInfo.size() > 0){
			//strSupply = (String)vReqInfo.elementAt(19);
			strTemp = dbOP.mapOneToOther("pur_po_info", "requisition_index",
									 (String)vReqInfo.elementAt(0), "po_index", "and is_del = 0");
			if(strTemp == null)
				bolAllowEdit = true;
		}
	}
	
	if(WI.fillTextValue("pageAction").length() > 0){
		vRetResult = PO.operateOnFreeItems(dbOP,request,Integer.parseInt(WI.fillTextValue("pageAction")));
		if(vRetResult == null)
			strErrMsg = PO.getErrMsg();
		else{
			if(!WI.fillTextValue("pageAction").equals("3")){
				strErrMsg = "Operation Successful.";
				vRetResult = null;
			}				
		}	
	}	
	vFreeItems = PO.operateOnFreeItems(dbOP,request,4);		
%>
<form name="form_" method="post" action="./free_item.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">    
	<tr bgcolor="#A49A6A">
      <td height="25" align="center"><font color="#FFFFFF"><strong>:::: 
        REQUISITION : ENCODE FREE ITEMS PAGE ::::</strong></font></td>
	</tr>	  
  
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="21%">PO No. :</td>
      <td width="76%"><strong> 
        <input type="text" name="req_no" class="textbox" value="<%=WI.fillTextValue("req_no")%>"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong>&nbsp;
		    <a href="javascript:OpenSearchPO();"><img src="../../../images/search.gif" border="0"></a><a href="javascript:OpenSearch('<%=WI.getStrValue(WI.fillTextValue("is_supply"),"0")%>');"></a>
		<a href="javascript:ProceedClicked();"> 
        <img src="../../../images/form_proceed.gif" border="0">
        </a>
	  </td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%		
	if(vReqInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D">
      <td width="3%" height="26">&nbsp;</td>
      <td colspan="4" align="center"><strong>REQUISITION DETAILS </strong></td>
    </tr>
    <tr>
      <td height="25" width="3%">&nbsp;</td>
      <td width="21%">Requisition No. :</td>
      <td width="25%"><strong>&nbsp;<%=(String)vReqInfo.elementAt(13)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="31%"><strong>&nbsp;<%=(String)vReqInfo.elementAt(3)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong>&nbsp;<%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(2))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong>&nbsp;<%=(String)vReqInfo.elementAt(6)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong>&nbsp;<%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(11))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong>&nbsp;<%=(String)vReqInfo.elementAt(8)%></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(4)).equals("0")){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong>&nbsp;<%=(String)vReqInfo.elementAt(10)%></strong></td>
      <td>Date Needed :</td>
      <td><strong>&nbsp;<%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></strong></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong>&nbsp;<%=(String)vReqInfo.elementAt(9)+"/"+WI.getStrValue((String)vReqInfo.elementAt(10),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong>&nbsp;<%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></strong></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td  height="25" colspan="3"><hr size="1"> </td>
    </tr>

    <tr>
      <td height="26">&nbsp;</td>
      <td>Inventory Type</td>
      <td colspan="3">
			<%if(vRetResult != null && vRetResult.size() > 3)
	  		strTemp = (String)vRetResult.elementAt(7);				
	    else if(WI.fillTextValue("is_supply").length() > 0 && !WI.fillTextValue("cancelClicked").equals("1"))
	  		strTemp = WI.fillTextValue("is_supply");
			else
				strTemp = "";
			strSupply = WI.getStrValue(strTemp,"0");
	  %>
	    <select name="is_supply" onChange="ChangeType();">
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
      <td> Item Category</td>
      <td valign="bottom">
	  <%if(vRetResult != null && vRetResult.size() > 0)
	  		strTemp = (String)vRetResult.elementAt(8);				
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
      </select>
			<input type="hidden" name="category_name" value="<%=WI.fillTextValue("category_name")%>">	</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>			
      <td>Item Classification </td>
      <td valign="bottom">
	  <%if(vRetResult != null && vRetResult.size() > 0){
	  		strTemp = (String)vRetResult.elementAt(9);
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
		<%if(WI.fillTextValue("category_name").equals("DRUGS/MEDICINE")){%>
    <tr>
      <td bgcolor="#DFDFFF">&nbsp;</td>
      <td height="25" bgcolor="#DFDFFF">Generic Name </td>
			<%
				strTemp = WI.fillTextValue("pndf_index");
			%>
      <td align="left" valign="middle" bgcolor="#DFDFFF">
				<input name="pndf_index" type="text" size="64" value="<%=strTemp%>"></td>
    </tr>
    <tr>
      <td bgcolor="#DFDFFF">&nbsp;</td>
      <td height="25" bgcolor="#DFDFFF">Route </td>
      <td align="left" valign="middle" bgcolor="#DFDFFF">
			<select name="route_index">
        <option>Oral</option>
        <option>Inj</option>
        <option>Solution</option>
      </select></td>
    </tr>
    <tr>
      <td bgcolor="#DFDFFF">&nbsp;</td>
      <td height="25" bgcolor="#DFDFFF">Preparation </td>
      <td align="left" valign="middle" bgcolor="#DFDFFF">
			<select name="prep_index" onChange="getPrepName();">
        <option value="1">50 mg and 100 mg tablet</option>
        <option value="2">250 mg tablet</option>
      </select>
        <font size="1">
        <input type="hidden" name="preparation" value="<%=WI.fillTextValue("preparation")%>">
        </font></td>
    </tr>
		<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="middle">Item :</td>
      <td width="75%" valign="bottom"> 
	  <%if(vRetResult != null && vRetResult.size() > 0)
	  		strTemp = (String)vRetResult.elementAt(12);
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
		  " and exists(select * from inv_reg_item where PUR_PRELOAD_ITEM.ITEM_INDEX = ITEM_INDEX " +
			WI.getStrValue(WI.fillTextValue("pndf_index")," and pndf_index = " ,"" ,"") +
			WI.getStrValue(WI.fillTextValue("prep_index")," and prep_index = " ,"" ,"") + 
			" and is_valid = 1)" +
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
      <td valign="middle">Particulars / <br>
      Item Description : </td>
      <td> <%
	  	if(vRetResult != null)
			strTemp = (String)vRetResult.elementAt(5);
	    else if(WI.fillTextValue("particular").length() > 0 && !WI.fillTextValue("cancelClicked").equals("1"))
	  		strTemp = WI.fillTextValue("particular");
		else
			strTemp = "";  
	  %> <input name="particular" type="text" size="64" class="textbox" value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="22%" valign="middle">Quantity :</td>
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
      <td valign="middle">Unit :</td>
      <td> 
			<% if(vRetResult != null)
				  	strTemp = (String)vRetResult.elementAt(10);
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
      <td valign="middle">Unit Price :</td>
      <td> <%
	      if(vRetResult != null)
		  	strTemp = WI.getStrValue((String)vRetResult.elementAt(4),"");
	      else if(WI.fillTextValue("unit_price").length() > 0 && !WI.fillTextValue("cancelClicked").equals("1"))
	  		strTemp = WI.fillTextValue("unit_price");
		  else
			strTemp = "";	  
	  %> <input type="text" name="unit_price" class="textbox" value="<%=strTemp%>"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="AllowOnlyIntegerExtn('form_','unit_price','.')"></td>
    </tr>
    <%if(WI.fillTextValue("is_supply").equals("1")){%>
    
    <%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="middle">Brand:</td>
      <td> <%
	      if(vRetResult != null)
		  	strTemp = (String)vRetResult.elementAt(11);
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
      <td height="18">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><div align="center"> 
          <%if(vRetResult == null && !bolIsErr){%>
          <a href="javascript:PageAction(1,0,'');"> <img src="../../../images/add.gif" border="0"></a> 
          <font size="1" >click to save entry</font> 
          <%}else{%>
          <a href="javascript:PageAction(2,<%=WI.fillTextValue("info_index")%>,'');"><img src="../../../images/edit.gif" border="0"></a> 
          <font size="1">click to save changes</font> <a href="javascript:CancelRecord();"> 
          <img src="../../../images/cancel.gif" border="0"></a> <font size="1">click 
          to cancel edit</font> 
          <%}%>
          <input type="text" name="req_no2" readonly size="2" 
			style="background-color:#FFFFFF;border-width: 0px;">
      </div></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
  </table>
  <%if(vFreeItems != null && vFreeItems.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;</td>
      <td height="29"><div align="right"><a href="javascript:PrintPage();"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print  Form</font></div></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
  </table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	  <tr>
	  	  <td width="100%" height="25" align="center" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT">
		      <font color="#FFFFFF"><strong>LIST OF FREE ITEMS</strong></font></td>
	  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    
    <tr> 
      <td width="8%" height="25" align="center" class="thinborder"><strong>ITEM#</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>QUANTITY</strong></td>
      <td width="11%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="16%" align="center" class="thinborder"><strong>ITEM</strong></td>
      <td width="38%" align="center" class="thinborder"><strong>PARTICULARS/ITEM DESCRIPTION </strong></td>
      <td width="9%" align="center" class="thinborder"><strong>EDIT</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>DELETE</strong></td>
    </tr>
    <% int iCountItem = 1;
		for(int i = 0;i < vFreeItems.size();i+=14,iCountItem++){%>
	<tr> 
      <td height="25" align="center" class="thinborder"><%=iCountItem%></td>
      <td align="center" class="thinborder"><%=vFreeItems.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=vFreeItems.elementAt(i+2)%></td>
      <td class="thinborder">&nbsp;<%=vFreeItems.elementAt(i+3)%></td>
      <td class="thinborder">&nbsp;<%=vFreeItems.elementAt(i+5)%></td>
			<%
				if(((String)vFreeItems.elementAt(i+13)).equals("0"))
					bolAllowEdit = true;
			%>
      <td align="center" class="thinborder">
			<%if(bolAllowEdit){%>
			<a href="javascript:PageAction(3,<%=vFreeItems.elementAt(i)%>,'');"> 
      <img src="../../../images/edit.gif" border="0"></a>
			<%}else{%>
				N/A
			<%}%>
			</td>
      <td align="center" class="thinborder"> 
	  <%if(iAccessLevel == 2 && bolAllowEdit){%>
	  <a href="javascript:PageAction(0,<%=vFreeItems.elementAt(i)%>,'<%=vFreeItems.elementAt(i+3)%>')">
	  <img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
		N/A
		<%}%>	  </td>
    </tr>
	<%} // end for loop%>
	<input type="hidden" name="item_count" value="<%=iCountItem-1%>">
    <tr> 
      <td class="thinborder" height="25" colspan="5">
	      <strong>TOTAL ITEM(S) : <%=iCountItem-1%></strong></td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25"><input type="text" name="req_no3" readonly size="2" 
			style="background-color:#FFFFFF;border-width: 0px;"></td>
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
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="cancelClicked" value="">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="printPage" value=""> 	
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>"> 
	<input type="hidden" name="focus_area" value="<%=WI.fillTextValue("focus_area")%>">
	<input type="hidden" name="isForPO" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>