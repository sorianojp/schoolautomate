<%@ page language="java" import="utility.*, citbookstore.BookOrders, java.util.Vector"%>
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
<title>Re-Print Order</title></head>
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
		document.form_.cancel_order_.value = "";
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
	
	function CancelOrder(){
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.get_order_info.value = "1";
		document.form_.cancel_order_.value = "1";
		document.form_.submit();
	}
	
	function RePrintOrderSlip(){
		document.form_.page_action.value = '1';
		document.form_.submit();
	}
	
		
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-ORDERING-REPRINT COLLEGE","reprint_order.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-ORDERING-REPRINT COLLEGE"),"0"));
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
	
	String strOrderIndex = WI.fillTextValue("order_index");
	String strSYFrom = WI.fillTextValue("sy_from");
	String strSYTo = WI.fillTextValue("sy_to");
	String strSemester = WI.fillTextValue("offering_sem");	
	
	Vector vOrderItems = null;
	BookOrders bo = new BookOrders();	
	
	
	if(WI.fillTextValue("page_action").length() > 0){
		strOrderIndex = bo.reprintOrder(dbOP, request);		
		if(strOrderIndex == null){
			strErrMsg = bo.getErrMsg();			
		}else{			
			strTemp = "select sy_from from bs_book_order_main where order_number='"+WI.fillTextValue("id_number")+"'";			
			strSYFrom = dbOP.getResultOfAQuery(strTemp,0);
		
			strTemp = "select sy_to from bs_book_order_main where order_number='"+WI.fillTextValue("id_number")+"'";			
			strSYTo = dbOP.getResultOfAQuery(strTemp,0);
		
			strTemp = "select semester from bs_book_order_main where order_number='"+WI.fillTextValue("id_number")+"'";			
			strSemester = dbOP.getResultOfAQuery(strTemp,0);

			dbOP.cleanUP();
			response.sendRedirect("./print_orderlist.jsp?order_index="+strOrderIndex+"&sy_from="+strSYFrom+"&offering_sem="+strSemester+"&reprint=1&print_order=1");							
			return;}
	}
%>
<!--<body bgcolor="#D2AE72" onload="document.form_.id_number.focus();"  onUnload="ReloadParentWnd();">-->
<body bgcolor="#D2AE72" onload="document.form_.id_number.focus();">
<form name="form_" action="./reprint_order.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: RE-PRINT ORDER SLIP ::::</strong></font></div></td>
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
			<td><a href="javascript:RePrintOrderSlip();"><img src="../../images/print.gif" border="0" /></a>
				<font size="1">Click to get print order slip.</font></td>
		</tr>
	<%}%>
	</table>
	

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	
	<input type="hidden" name="order_index" value="<%=strOrderIndex%>" />
	<input type="hidden" name="page_action" />
	<input type="hidden" name="offering_sem" value="<%=strSemester%>"  />
	<input type="hidden" name="sy_from" value="<%=strSYFrom%>"  />
	<input type="hidden" name="sy_to" value="<%=strSYTo%>"  />
	<input type="hidden" name="is_basic" value="0"  />	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>