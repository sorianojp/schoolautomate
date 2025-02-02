<%@ page language="java" import="utility.*, citbookstore.BookOrders, citbookstore.BookManagement, java.util.Vector"%>
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
<title>Cancel Order</title></head>
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
		
		var vSemester = document.form_.offering_sem.value;
		var vSyFrom = document.form_.sy_from.value;
		var vSyTo = document.form_.sy_to.value;
		
		//var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=20700&id_number="+escape(strIDNumber);
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=20700&for_order=1&id_number="+escape(strIDNumber)+"&offering_sem="+vSemester+"&sy_from="+vSyFrom+"&sy_to="+vSyTo;
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
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	boolean bolFatalErr = false;
	
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-ORDERING-CANCEL ORDER","cancel_order.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-ORDERING-CANCEL ORDER"),"0"));
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
	
	strTemp = dbOP.mapOneToOther("BS_BOOK_LOGIN_TERMINAL","IP_ADDR","'"+request.getRemoteAddr()+"'",
                          "LOGIN_TERM_INDEX"," and is_valid = 1");
	if(strTemp == null) {
		strErrMsg = "IP : "+request.getRemoteAddr()+" IS NOT ASSINGED FOR LOGIN TERMINAL";
		bolFatalErr = true;
	}
	
	String strOrderIndex = null;
	Vector vOrderItems = null;
	BookOrders bo = new BookOrders();	
	
	BookManagement bm = new BookManagement();	
	Vector vLocCatgIndex = new Vector();	
	vLocCatgIndex = bm.checkIPAddress(dbOP,request,request.getRemoteAddr());
	
	if(WI.fillTextValue("get_order_info").length() > 0){
	
		String strSQLQuery = " select order_index from bs_book_order_main where is_valid=1 and order_number='"+WI.fillTextValue("id_number")+"' ";
    	strOrderIndex = dbOP.getResultOfAQuery(strSQLQuery, 0);
		
		if(strOrderIndex == null)
			strErrMsg = bo.getErrMsg();
		else{
		
			if(WI.fillTextValue("cancel_order_").length() > 0){
				if(!bo.cancelOrder(dbOP,request,strOrderIndex))
					strErrMsg = bo.getErrMsg();
				else
					strErrMsg = "Order canceled successfully.";
			}
				
					
			vOrderItems = bo.getOrderedItems(dbOP, request, strOrderIndex);
			if(vOrderItems == null)
				strErrMsg = bo.getErrMsg();
		}
	}
%>
<body bgcolor="#D2AE72" onload="document.form_.id_number.focus();"  onUnload="ReloadParentWnd();">

<%
if(bolFatalErr){
	dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3" color="#FFFF00">
		<strong><%=strErrMsg%></strong></font></p>
<%
	return;
}%>

<form name="form_" action="./cancel_order.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: CANCEL ORDER ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">SY/Term:</td>
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>
		  	<td width="80%">
				<select name="offering_sem">
              	<%if(strTemp.equals("1")){%>
              		<option value="1" selected>1st Sem</option>
              	<%}else{%>
              		<option value="1">1st Sem</option>
				
				<%}if(strTemp.equals("2")){%>
              		<option value="2" selected>2nd Sem</option>
              	<%}else{%>
              		<option value="2">2nd Sem</option>
					
				<%}if(strTemp.equals("3")){%>
              		<option value="3" selected>3rd Sem</option>
              	<%}else{%>
              		<option value="3">3rd Sem</option>
				
				<%}if(strTemp.equals("0")){%>
              		<option value="0" selected>Summer</option>
              	<%}else{%>
              		<option value="0">Summer</option>
              	<%}%>
            	</select>
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
				%>
				<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
					onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
				-
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
				%>
				<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
					readonly="yes"></td>
		</tr>
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
			<td><a href="javascript:getOrderedInfo();">
			<%if(iAccessLevel > 1){%>
			<img src="../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to get order information.</font>
			<%}else{%>	
			You are not authorized to access this page.
			<%}%>
				</td>
		</tr>
	<%}%>
	</table>
	
<%if(vOrderItems != null && vOrderItems.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td>
				<%
				strTemp = WI.fillTextValue("force_close");
				if(strTemp.equals("1"))
					strTemp = "checked";
				else
					strTemp = "";
				%>
				<!--<input type="checkbox" name="force_close" value="1" <%=strTemp%>  />Click to Force Cancel-->
				&nbsp;
			</td>
		
			<td height="15" align="right">
				<%if(iAccessLevel > 1){%>
				<input type="button" name="cancel_order" value=" Cancel Order " 
				onclick="CancelOrder();"
				style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
				<%}else{%>
				You are not authorized.
				<%}%>
			</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
        <tr>
          	<td height="20" bgcolor="#B9B292" colspan="10" class="thinborder"><div align="center"><strong>LIST OF ORDERED PRODUCTS </strong></div></td>
        </tr>
        <tr>
			<td width="5%"  align="center" height="25" class="thinborder"><strong>Count</strong></td>
			<td width="" align="center" class="thinborder"><strong>Book Title/Item Name</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Author</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Item Price </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Quantity</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Payable Amt </strong></td>				
        </tr>
        <%	
			int iCount = 1;
			for(int i = 0; i < vOrderItems.size(); i += 19, iCount++){
		%>
        <tr>
			<td height="25" class="thinborder" align="center"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vOrderItems.elementAt(i+5)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vOrderItems.elementAt(i+6), "N/A")%></td>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vOrderItems.elementAt(i+9), true)%>&nbsp;</td>
			<td class="thinborder" align="right"><%=(String)vOrderItems.elementAt(i+10)%>&nbsp;</td>
	  	  	<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vOrderItems.elementAt(i+11), true)%>&nbsp;</td>				
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
	
	
	<input type="hidden" name="cancel_order_"  />
	<input type="hidden" name="get_order_info" />
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>"> 
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
	<input type="hidden" name="reloadPage" value="0">
	<input type="hidden" name="is_forwarded" value="<%=WI.fillTextValue("is_forwarded")%>" />
	<input type="hidden" name="catg_index" value="<%=(String)vLocCatgIndex.elementAt(1)%>"  />
	<input type="hidden" name="ditribution_loc" value="<%=(String)vLocCatgIndex.elementAt(0)%>"  />
	<input type="hidden" name="for_order" value="1" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>