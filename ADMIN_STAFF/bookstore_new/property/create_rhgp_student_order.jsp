<%@ page language="java" import="utility.*, citbookstore.BookOrders, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	boolean bolIsCIT = strSchCode.startsWith("CIT");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
  
.nav {
     /**color: #000000;**/
	 font-weight:normal;
}
.nav-highlight {
     /**color: #0000FF;**/
     background-color:#BCDEDB;
}

</style>

<title>Ordering</title></head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
	
	function navRollOver(obj, state) {
  		document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
	}
	
	function checkAllSaveItems() {
			
		var maxDisp = document.form_.item_count.value;
		var bolIsSelAll = document.form_.selAllSaveItems.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
	function Search(){
		document.form_.search_.value = "1";
		document.form_.submit();
	}
	
	function CreateOrder(){
		document.form_.create_order.value = "1";
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
								"BOOKSTORE-PROPERTY","create_rhgp_student_order.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-PROPERTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		if(iAccessLevel == 0){
			response.sendRedirect("../../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	Vector vRetResult = new Vector();
	Vector vStudWithOrder = new Vector();
   Vector vStudWithoutOrder = new Vector();      
	Vector vStudWithRHGPOrderNoPayment = new Vector();
	BookOrders bo = new BookOrders();
	
	
	
	if(WI.fillTextValue("create_order").length() > 0){
		if(bo.createRHGPOrdertToStudent(dbOP, request, 2) == null)
			strErrMsg = bo.getErrMsg();
		else
			strErrMsg = "RHGP order successfully created.";	
	}

	if(WI.fillTextValue("search_").length() > 0){
		vRetResult = bo.createRHGPOrdertToStudent(dbOP, request, 1);
		if(vRetResult == null)
			strErrMsg = bo.getErrMsg();
	}
	
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./create_rhgp_student_order.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable1">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: STUDENT WITHOUT RHGP ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable2">
		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">SY/Term:</td>
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>
		  	<td width="" colspan="2">
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
		<tr >
			<td height="25" >&nbsp;</td>
			<td>Transaction Date: </td>
			<%
				strTemp = WI.fillTextValue("transaction_date");
				if(strTemp.length() == 0) 
					strTemp = WI.getTodaysDate(1);
			%>
			<td>
				<input name="transaction_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.transaction_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr><td height="15" colspan="4">&nbsp;</td></tr>
		<tr>
		  	<td height="25" colspan="2">&nbsp;</td>
	  	  	<td height="25"><input type="button" name="request_book2" value="VIEW STUDENT" 
					onclick="Search();" style="font-size:11px; height:25px;border: 1px solid #FF0000;" /></td>
		</tr>
	  <tr><td colspan="4" height="25">&nbsp;</td></tr>
	</table>



<%
if(vRetResult != null && vRetResult.size() > 0){

vStudWithOrder = (Vector)vRetResult.remove(0);
vStudWithoutOrder = (Vector)vRetResult.remove(0);
vStudWithRHGPOrderNoPayment = (Vector)vRetResult.remove(0);
int iCount = 1;
int iCountRow = 1;

if(vStudWithOrder != null && vStudWithOrder.size() > 0){
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td height="25" class="thinborder">&nbsp;</td>
		<td align="center" class="thinborder" width="10%"><strong>Select All</strong><br>
		<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();">		</td>
	</tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td class="thinborder" height="25" align="center" colspan="5"><strong>STUDENT WITH ORDERS BUT NO RHGP</strong></td></tr>
	<tr>
		<td class="thinborder" width="5%"><strong>COUNT</strong></td>
		<td height="25" class="thinborder" width="20%"><strong>STUDENT ID</strong></td>
		<td class="thinborder" width="40%"><strong>STUDENT NAME</strong></td>
		<td class="thinborder"><strong>YEAR LEVEL</strong> </td>
		<td align="center" class="thinborder" width="10%">&nbsp;
		</td>
	</tr>
	
	<%
	for(int i = 0; i < vStudWithOrder.size(); i+=5){
	%>
	<tr>
		<td class="thinborder"><%=iCountRow++%></td>
		<td height="25" class="thinborder" width="20%"><%=(String)vStudWithOrder.elementAt(i+1)%></td>
		<td class="thinborder" width="40%"><%=(String)vStudWithOrder.elementAt(i+2)%></td>
		<td class="thinborder"><%=(String)vStudWithOrder.elementAt(i+3)%></td>
		<td align="center" class="thinborder" width="10%">
		<input type="hidden" name="year_level_<%=iCount%>" value="<%=(String)vStudWithOrder.elementAt(i+4)%>" />
		<input type="checkbox" name="save_<%=iCount++%>" value="<%=(String)vStudWithOrder.elementAt(i)%>">
		</td>
	</tr>	
	<%}%>
</table>
<%}



if(vStudWithoutOrder != null && vStudWithoutOrder.size() > 0){
%>
<br><br><br>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td class="thinborder" height="25" align="center" colspan="5"><strong>STUDENT WITH NO ORDERS</strong></td></tr>
	<tr>
		<td class="thinborder" width="5%"><strong>COUNT</strong></td>
		<td height="25" class="thinborder" width="20%"><strong>STUDENT ID</strong></td>
		<td class="thinborder" width="40%"><strong>STUDENT NAME</strong></td>
		<td class="thinborder"><strong>YEAR LEVEL</strong> </td>
		<td align="center" class="thinborder" width="10%">&nbsp;
		</td>
	</tr>
	
	<%
	iCountRow = 1;
	for(int i = 0; i < vStudWithoutOrder.size(); i+=5){
	%>
	<tr>
		<td class="thinborder"><%=iCountRow++%></td>
		<td height="25" class="thinborder" width="20%"><%=(String)vStudWithoutOrder.elementAt(i+1)%></td>
		<td class="thinborder" width="40%"><%=(String)vStudWithoutOrder.elementAt(i+2)%></td>
		<td class="thinborder"><%=(String)vStudWithoutOrder.elementAt(i+3)%></td>
		
		<td align="center" class="thinborder" width="10%">
		<input type="hidden" name="year_level_<%=iCount%>" value="<%=(String)vStudWithoutOrder.elementAt(i+4)%>" />
		<input type="checkbox" name="save_<%=iCount++%>" value="<%=(String)vStudWithoutOrder.elementAt(i)%>">
		
		</td>
	</tr>	
	<%}%>
</table>
<%}



if(vStudWithRHGPOrderNoPayment != null && vStudWithRHGPOrderNoPayment.size() > 0){
%>
<br><br><br>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td class="thinborder" height="25" align="center" colspan="5"><strong>STUDENT WITH RHGP ORDERS BUT NO PAYMENT</strong></td></tr>
	<tr>
		<td class="thinborder" width="5%"><strong>COUNT</strong></td>
		<td height="25" class="thinborder" width="20%"><strong>STUDENT ID</strong></td>
		<td class="thinborder" width="40%"><strong>STUDENT NAME</strong></td>
		<td class="thinborder"><strong>YEAR LEVEL</strong> </td>
		<td align="center" class="thinborder" width="10%">&nbsp;
		</td>
	</tr>
	
	<%
	iCountRow = 1;
	for(int i = 0; i < vStudWithRHGPOrderNoPayment.size(); i+=5){
	%>
	<tr>
		<td class="thinborder"><%=iCountRow++%></td>
		<td height="25" class="thinborder" width="20%"><%=(String)vStudWithRHGPOrderNoPayment.elementAt(i+1)%></td>
		<td class="thinborder" width="40%"><%=(String)vStudWithRHGPOrderNoPayment.elementAt(i+2)%></td>
		<td class="thinborder"><%=(String)vStudWithRHGPOrderNoPayment.elementAt(i+3)%></td>
		
		<td align="center" class="thinborder" width="10%">
		<input type="hidden" name="year_level_<%=iCount%>" value="<%=(String)vStudWithRHGPOrderNoPayment.elementAt(i+4)%>" />
		<input type="hidden" name="with_rhgp_order_<%=iCount%>" value="1" />
		<input type="checkbox" name="save_<%=iCount++%>" value="<%=(String)vStudWithRHGPOrderNoPayment.elementAt(i)%>">
		
		</td>
	</tr>	
	<%}%>
</table>
<%}



%>
	<input type="hidden" name="item_count" value="<%=iCount%>"  />
	
	
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="right">
	<input type="button" name="request_book2" value="CREATE ORDER" 
					onclick="CreateOrder();" style="font-size:11px; height:25px;border: 1px solid #FF0000;" />
	</td></tr>
</table>
	
	
<%}%>
	
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="25" colspan="3">&nbsp;</td></tr>
<tr><td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
	<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>"  />
	<input type="hidden" name="create_order" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
