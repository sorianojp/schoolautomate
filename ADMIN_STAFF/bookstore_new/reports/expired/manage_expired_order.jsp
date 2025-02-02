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
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Ordering</title></head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript">
function deleteOrders() {
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
								"BOOKSTORE-REPORTS-EXPIRED ORDER","manage_expired_order.jsp");
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
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		if(iAccessLevel == 0){
			response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	Vector vRetResult = new Vector();
	BookOrders BO = new BookOrders();
	
	if(WI.fillTextValue("sy_from").length() > 0) {
		Vector vOrderList = BO.getExpiredOrdersList(dbOP, request);
		if(vOrderList == null || vOrderList.size() == 0) {
			strErrMsg = BO.getErrMsg();
			//System.out.println(strErrMsg);
		}
		else {
			if(WI.fillTextValue("page_action").length() == 0) {
				vRetResult = BO.viewExpiredOrdersList(dbOP, vOrderList);
				if(vRetResult == null)
					strErrMsg = BO.getErrMsg();
			}
			else {
				if(BO.delExpiredOrdersList(dbOP, vOrderList))
					strErrMsg = "Expired orders removed successfully.";
				else	
					strErrMsg = BO.getErrMsg();
			}	
		}
	}
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./manage_expired_order.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: ORDERING ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">SY/Term:</td>
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>
		  	<td width="80%">
				<select name="semester">
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
		  	<td height="25" colspan="2">&nbsp;</td>
		  	<td height="25">
			<input type="button" name="transaction_" value=" View Expired Transaction " 
					onclick="document.form_.page_action.value='';document.form_.submit();" style="font-size:11px; height:28px;border: 1px solid #FF0000;" /></td>
	  </tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
        <tr>
          	<td height="20" bgcolor="#B9B292" colspan="9" class="thinborder"><div align="center"><strong>LIST OF ORDERED ITEMS </strong></div></td>
        </tr>
        <tr>
			<td width="2%"  align="center" height="25" class="thinborder"><strong>Count</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Student ID</strong></td>
			<td width="33%" align="center" class="thinborder"><strong>Student Name</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Transaction Date</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Order Number</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Payable Amt </strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Is Finalized</strong></td>
		</tr>
        <%	
			int iCount = 0;
			for(int i = 0; i < vRetResult.size(); i += 7){
		%>
        <tr>
			<td height="25" class="thinborder" align="center"><%=++iCount%></td>
			<td class="thinborder"><%=vRetResult.elementAt(i)%></td>
			<td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
			<td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
			<td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
			<td class="thinborder" align="right"><%=vRetResult.elementAt(i + 4)%></td>
	  	  	<td class="thinborder"> <%=vRetResult.elementAt(i + 5)%></td>
	  	</tr>
		<input type="hidden" name="book_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+6)%>" />
        <%}%>
        <tr>
			<td height="25" colspan="9" align="center">
			<%if(iAccessLevel == 2){%>
		  		<input type="button" name="delete2" value=" Delete Orders " 
					onclick="javascript:deleteOrders();" style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
              <%}else{%>
            		Not authorized to remove items from order.
              <%}%></td>
        </tr>
        <tr>
			<td height="20" colspan="9">&nbsp;</td>
        </tr>
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
	
	<input type="hidden" name="page_action"/>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
