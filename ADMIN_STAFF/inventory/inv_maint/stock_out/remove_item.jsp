<%@ page language="java" import="utility.*,inventory.InventoryMaintenance,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
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

function CheckAll()
{
	document.form_.printPage.value = "";
	var iMaxDisp = document.form_.item_count.value;
	if (iMaxDisp.length == 0)
		return;	
	if (document.form_.selAll.checked ){
		for (var i = 1 ; i <= eval(iMaxDisp);++i)
			eval('document.form_.remove_'+i+'.checked=true');
	}
	else
		for (var i = 1 ; i <= eval(iMaxDisp);++i)
			eval('document.form_.remove_'+i+'.checked=false');
		
}
function ProceedClicked(){
	document.form_.focus_area.value = "";
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function SaveRemoval(){
		document.form_.save_removal.value = "1";	
		document.form_.focus_area.value = "2";
		document.form_.printPage.value = "";
		this.SubmitOnce('form_');
}
function CancelRecord(){
  document.form_.cancelClicked.value = "1";
	document.form_.proceedClicked.value = "1";
	document.form_.save_removal.value = "";
	document.form_.strIndex.value = "";
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
}
function OpenSearch(){
	document.form_.printPage.value = "";
	var pgLoc = "stock_out_view_search.jsp?opner_info=form_.req_no";
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
function ChangeType(){
	document.form_.printPage.value = "";
	document.form_.cat_index.value = "";
	document.form_.class_index.value = "";	
	document.form_.category_name.value = "";	
	document.form_.focus_area.value = "2";
	this.SubmitOnce('form_');
}

</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<%		
    if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="request_item_print.jsp"/>
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-LOG"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}

	if(WI.fillTextValue("my_home").equals("1"))
		iAccessLevel = 2 ;
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-REQUISITION-Requisition Items","remove_item.jsp");
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

	InventoryMaintenance InvMaint = new InventoryMaintenance();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vTransfer = null;
	Vector vRetResult = null;
	Vector vCheck = null;
	boolean bolIsErr = false;
	boolean bolAllowEdit = false;
	String[] astrReqStatus = {"Disapproved","Approved","Pending"};	
	String[] astrReqType = {"Donate Items","Dispose / discard items","Consume / use items"};	
	String strSchCode = dbOP.getSchoolIndex();
	String strSupply = WI.getStrValue(WI.fillTextValue("is_supply"),"0");
	int iDefault = 0;
	String strCategory = null;
	String strClass = null;
	String strItem = null;
	int iCount = 1;
	int i = 0;
	
	vReqInfo = InvMaint.operateOnStockOutInfo(dbOP,request,3);
	if(vReqInfo == null && WI.fillTextValue("req_no").length() > 0
	     				&& WI.fillTextValue("save_removal").length() < 1)
		strErrMsg = InvMaint.getErrMsg();
	if(WI.fillTextValue("req_no").length() < 1)
		strErrMsg = "Input Requisition No.";

	if(WI.fillTextValue("save_removal").length() > 0){
		vCheck = InvMaint.operateOnStockRemoval(dbOP, request, 1);
		if(vCheck == null)
			strErrMsg = InvMaint.getErrMsg();
	}	
	vRetResult = InvMaint.operateOnStockRemoval(dbOP,request,4);

	if(vRetResult != null && vRetResult.size() > 0){
		vReqItems = (Vector) vRetResult.elementAt(0);
		vTransfer = (Vector) vRetResult.elementAt(1);
	}
	
	
%>
<form name="form_" method="post" action="remove_item.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">    
	<tr bgcolor="#A49A6A">
      <td height="25" align="center"><font color="#FFFFFF"><strong>:::: 
        REQUISITION : STOCK OUT PAGE ::::</strong></font></td>
	</tr>	  
  
    <tr bgcolor="#FFFFFF">
      <td height="25"><a href="request_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
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
		<a href="javascript:OpenSearch();">
		<img src="../../../../images/search.gif" border="0"></a>
		<a href="javascript:ProceedClicked();"> 
        <img src="../../../../images/form_proceed.gif" border="0">
        </a>
	  </td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%if(vReqInfo != null){%>
			<input type="hidden" name="c_index" value="<%=(String)vReqInfo.elementAt(5)%>">
			<input type="hidden" name="d_index" value="<%=(String)vReqInfo.elementAt(6)%>">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D">
      <td width="3%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS </strong></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Request Type</td>
			<input type="hidden" name="request_type" value="<%=(String)vReqInfo.elementAt(3)%>">
      <td colspan="3"><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(3))]%></strong></td>
    </tr>
    <tr>
      <td height="25" width="3%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="25%"><strong><%=WI.fillTextValue("req_no")%></strong></td>
      <td width="21%">Requested By :</td>
      <td width="29%"><strong><%=(String)vReqInfo.elementAt(4)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(10))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(5)).equals("0")){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Non-Acad. Office/Dept :</td>
      <td colspan="3"><strong><%=(String)vReqInfo.elementAt(8)%></strong></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>College/Dept :</td>
      <td colspan="3"><strong><%=(String)vReqInfo.elementAt(7)+"/"+WI.getStrValue((String)vReqInfo.elementAt(8),"All")%></strong></td>
    </tr>
    <%}%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Remarks</td>
      <td colspan="3"><strong><%=WI.getStrValue((String)vReqInfo.elementAt(9))%></strong></td>
    </tr>
  </table>
  <%if(vReqItems != null && vReqItems.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	  <tr bgcolor="#B9B292">
	  	  <td width="100%" height="25" colspan="6" align="center" class="thinborderBOTTOMLEFT"><font color="#FFFFFF"><strong>LIST OF REQUESTED ITEMS FOR STOCK OUT </strong></font></td>
	  </tr>
    <tr> 
      <td width="10%" height="25" align="center" class="thinborder"><strong>ITEM CODE </strong></td>
      <td width="9%" align="center" class="thinborder"><strong>QUANTITY</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="50%" align="center" class="thinborder"><strong>ITEM</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>DATE REMOVED </strong></td>
      <td width="8%" align="center" class="thinborder"><strong>
        <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">
      </strong>all</td>
    </tr>
    <%
	for(i = 0;i < vReqItems.size();i+=16,iCount++){%>
	<tr> 
			<input type="hidden" name="out_item_index_<%=iCount%>" value="<%=(String)vReqItems.elementAt(i)%>">
			<input type="hidden" name="req_index_<%=iCount%>" value="<%=(String)vReqItems.elementAt(i+1)%>">			
			<input type="hidden" name="req_qty_<%=iCount%>" value="<%=(String)vReqItems.elementAt(i+3)%>">
			<input type="hidden" name="released_qty_<%=iCount%>" value="<%=(String)vReqItems.elementAt(i+4)%>">
			<input type="hidden" name="item_reg_index_<%=iCount%>" value="<%=(String)vReqItems.elementAt(i+10)%>">
			<input type="hidden" name="item_name_<%=iCount%>" value="<%=(String)vReqItems.elementAt(i+7)%>">
			<!--unit refers to the actual unit index requested-->
			<input type="hidden" name="unit_index_<%=iCount%>" value="<%=(String)vReqItems.elementAt(i+9)%>">
			<!-- conversion is already checked. unit transfered is cross checked with the registry-->			
			<input type="hidden" name="conversion_qty_<%=iCount%>" value="<%=(String)vReqItems.elementAt(i+13)%>">
			
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vReqItems.elementAt(i+2),"&nbsp;")%></td>
      <td align="right" class="thinborder">
			  <input name="new_remove_qty_<%=iCount%>" type="text" class="textbox" tabindex="-1" 
				onBlur="AllowOnlyFloat('form_','new_remove_qty_<%=iCount%>');style.backgroundColor='white';"
				onKeyUp="AllowOnlyFloat('form_','new_remove_qty_<%=iCount%>');"
				onFocus="style.backgroundColor='#D3EBFF'" value="<%=(String)vReqItems.elementAt(i+5)%>" 
				size="3" maxlength="10" style="text-align:right">&nbsp;
			</td>
      <td class="thinborder">&nbsp;<%=vReqItems.elementAt(i+6)%></td>
			
      <td class="thinborder">&nbsp;<%=(String)vReqItems.elementAt(i+7)%><%=WI.getStrValue((String)vReqItems.elementAt(i+8)," (", ")","")%></td>
      <td align="center" class="thinborder">
			 	<input name="date_<%=iCount%>" type="text" size="9" maxlength="10" class="textbox"
				 value="<%=WI.getTodaysDate(1)%>" onFocus="style.backgroundColor='#D3EBFF'" 
				 onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.date_<%=iCount%>');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../../images/calendar_new.gif" border="0"></a></td>
      <td align="center" class="thinborder"><input type="checkbox" name="remove_<%=iCount%>" value="1"></td>
	</tr>
	<%} // end for loop%>
	<input type="hidden" name="item_count" value="<%=iCount-1%>">
    <tr> 
      <td class="thinborder" height="25" colspan="4">
	      <strong>TOTAL ITEM(S) : <%=iCount-1%></strong></td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <%
		strTemp = WI.fillTextValue("received_by");
	%>
      <td height="25">Received by:
        <input type="text" name="received_by" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25"><div align="center"><a href="javascript:SaveRemoval();"> <img src="../../../../images/save.gif" border="0"> </a><font size="1">click to save update</font> <a href="javascript:CancelRecord();"> <img src="../../../../images/cancel.gif" border="0"> </a> <font size="1">click to cancel</font> </div></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
    </tr>
  </table>
  <%}%>
	<%if(vTransfer != null && vTransfer.size() > 0){%>	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	  <tr bgcolor="#B9B292">
	  	  <td height="25" colspan="4" align="center" class="thinborderBOTTOMLEFT"><font color="#FFFFFF"><strong>LIST OF REMOVED SUPPLIES</strong></font></td>
	  </tr>
    <tr> 
      <td width="17%" height="25" align="center" class="thinborder"><strong>ITEM CODE </strong></td>
      <td width="10%" align="center" class="thinborder"><strong>QUANTITY</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="63%" align="center" class="thinborder"><strong>ITEM</strong></td>
    </tr>
    <% for(i = 0;i < vTransfer.size();i+=16,iCount++){%>
	<tr> 
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vTransfer.elementAt(i+2),"&nbsp;")%></td>
      <td align="right" class="thinborder"><%=(String)vTransfer.elementAt(i+4)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=vTransfer.elementAt(i+6)%></td>
			
      <td class="thinborder">&nbsp;<%=(String)vTransfer.elementAt(i+7)%><%=WI.getStrValue((String)vTransfer.elementAt(i+8)," (", ")","")%></td>
    </tr>
	<%} // end for loop%>
    <tr> 
      <td class="thinborder" height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
	<%}%>
<%}else{%>
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
  <input type="hidden" name="save_removal">
  <input type="hidden" name="cancelClicked" value="">
  <input type="hidden" name="strIndex" value="<%=WI.fillTextValue("strIndex")%>">
  <input type="hidden" name="printPage" value=""> 
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>"> 
	<input type="hidden" name="focus_area" value="<%=WI.fillTextValue("focus_area")%>">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>