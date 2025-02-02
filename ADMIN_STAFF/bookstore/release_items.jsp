<%@ page language="java" import="utility.*, bookstore.BookOrders, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsForwarded = WI.fillTextValue("is_forwarded").equals("1");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
a{
	text-decoration: none;
}
</style>
<title>Release Items</title></head>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">
	
	var objCOA;
	var objCOAInput;
	function AjaxMapOrders() {
		var strIDNumber = document.form_.id_number.value;
		objCOAInput = document.getElementById("coa_info");
		eval('objCOA=document.form_.id_number');
		if(strIDNumber.length < 3) {
			objCOAInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=20700&id_number="+escape(strIDNumber);
		this.processRequest(strURL);
	}
	
	function updateCustomerCode(strOrderIndex, strIDNumber, strOrderNumber){
		document.form_.id_number.value = strOrderNumber;
		document.getElementById("coa_info").innerHTML = "";
		document.form_.submit();
	}
	
	function getOrderedInfo(){
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.get_order_info.value = "1";
		document.form_.submit();
	}
	
	function ReleaseItem(strOrderItemIndex){
		if(!confirm("Are you sure you want to release this order item?"))
			return;
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.order_item_index.value = strOrderItemIndex;
		document.form_.release_item.value = "1";
		document.form_.get_order_info.value = "1";
		document.form_.submit();
	}
	
	function UnreleaseItem(strOrderItemIndex){
		if(!confirm("Are you sure you want to unrelease this order item?"))
			return;
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.order_item_index.value = strOrderItemIndex;
		document.form_.unrelease_item.value = "1";
		document.form_.get_order_info.value = "1";
		document.form_.submit();
	}
	
	function FinalizeItem(strOrderItemIndex){
		if(!confirm("Are you sure you want to finalize this order item?"))
			return;
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.order_item_index.value = strOrderItemIndex;
		document.form_.finalize_item.value = "1";
		document.form_.get_order_info.value = "1";
		document.form_.submit();
	}
	
	function ReloadParentWnd() {
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
		
		<%if(bolIsForwarded){%>
		if(document.form_.close_wnd_called.value == "0") 
			window.opener.ReloadPage();
		<%}%>
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-BOOK MANAGEMENT","release_items.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-ORDERING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		if(iAccessLevel == 0){
			response.sendRedirect("../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	String strOrderIndex = null;
	Vector vOrderItems = null;
	BookOrders bo = new BookOrders();
	
	if(WI.fillTextValue("get_order_info").length() > 0){
		strOrderIndex = bo.isOrderReadyForReleasing(dbOP, request);
		if(strOrderIndex == null)
			strErrMsg = bo.getErrMsg();
		else{
			if(WI.fillTextValue("release_item").length() > 0){
				if(!bo.operateOnReleaseFinalize(dbOP, request, 1))
					strErrMsg = bo.getErrMsg();
				else
					strErrMsg = "Order item successfully released.";
			}
			
			if(WI.fillTextValue("unrelease_item").length() > 0){
				if(!bo.operateOnReleaseFinalize(dbOP, request, 0))
					strErrMsg = bo.getErrMsg();
				else
					strErrMsg = "Order item successfully unreleased.";
			}
			
			if(WI.fillTextValue("finalize_item").length() > 0){
				if(!bo.operateOnReleaseFinalize(dbOP, request, 2))
					strErrMsg = bo.getErrMsg();
				else
					strErrMsg = "Order item successfully finalized.";
			}
		
			vOrderItems = bo.getOrderedItems(dbOP, request, strOrderIndex);
			if(vOrderItems == null)
				strErrMsg = bo.getErrMsg();
		}
	}
%>
<body bgcolor="#D2AE72" onload="document.form_.id_number.focus();"  onUnload="ReloadParentWnd();">
<form name="form_" action="./release_items.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: RELEASE ITEMS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Order Number: </td>
			<td width="80%">
				<%if(bolIsForwarded){%>
					<input type="hidden" name="id_number" value="<%=WI.fillTextValue("id_number")%>" />
					<strong><font size="3" color="#FF0000"><%=WI.fillTextValue("id_number")%></font></strong>
				<%}else{%>
					<input name="id_number" type="text" size="16" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
						onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapOrders();">
				<%}%>
				&nbsp;&nbsp;
				<label id="coa_info" style="width:300px; position:absolute"></label></td>
		</tr>
	<%if(!bolIsForwarded){%>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td><a href="javascript:getOrderedInfo();"><img src="../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Clcik to get order information.</font></td>
		</tr>
	<%}%>
	</table>
	
<%if(vOrderItems != null && vOrderItems.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
        <tr>
          	<td height="20" bgcolor="#B9B292" colspan="10" class="thinborder"><div align="center"><strong>LIST OF ORDERED PRODUCTS </strong></div></td>
        </tr>
        <tr>
			<td width="5%"  align="center" height="25" class="thinborder"><strong>Count</strong></td>
			<td width="21%" align="center" class="thinborder"><strong>Title</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Author</strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Item Price </strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Quantity</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Payable Amt </strong></td>
			<td width="7%"  align="center" class="thinborder"><strong>Release</strong></td>
			<td width="7%"  align="center" class="thinborder"><strong>Finalize</strong></td>
        </tr>
        <%	
			int iCount = 1;
			for(int i = 0; i < vOrderItems.size(); i += 17, iCount++){
		%>
        <tr>
			<td height="25" class="thinborder" align="center"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vOrderItems.elementAt(i+5)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vOrderItems.elementAt(i+6), "N/A")%></td>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vOrderItems.elementAt(i+9), true)%>&nbsp;</td>
			<td class="thinborder">&nbsp;<%=(String)vOrderItems.elementAt(i+10)%></td>
	  	  	<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vOrderItems.elementAt(i+11), true)%>&nbsp;</td>
			<%
				strTemp = (String)vOrderItems.elementAt(i+14);
			%>
		  	<td align="center" class="thinborder">
				<%if(strTemp.equals("0")){%>
					<a href="javascript:ReleaseItem('<%=(String)vOrderItems.elementAt(i)%>');">Release</a>
				<%}else if(strTemp.equals("1")){%>
					<a href="javascript:UnreleaseItem('<%=(String)vOrderItems.elementAt(i)%>');">Unrelease</a>
				<%}else{%>
					Finalized
				<%}%></td>
			<td align="center" class="thinborder">
				<%if(strTemp.equals("0") || strTemp.equals("1")){%>
					<a href="javascript:FinalizeItem('<%=(String)vOrderItems.elementAt(i)%>');">Finalize</a>
				<%}else{%>
					Finalized
				<%}%></td>
		</tr>
        <%}%>
	</table>
<%}%>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="release_item" />
	<input type="hidden" name="unrelease_item" />
	<input type="hidden" name="finalize_item" />
	<input type="hidden" name="get_order_info" />
	<input type="hidden" name="order_item_index" />
	
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>"> 
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
	<input type="hidden" name="reloadPage" value="0">
	<input type="hidden" name="is_forwarded" value="<%=WI.fillTextValue("is_forwarded")%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>