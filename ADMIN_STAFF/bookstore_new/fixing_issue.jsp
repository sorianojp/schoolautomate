<%@ page language="java" import="utility.*, citbookstore.BookOrders, citbookstore.BookManagement, java.util.Vector"%>
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
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Ordering</title></head>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript">
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	function searchStudent(){
		document.form_.new_transaction.value = '1';
		document.form_.submit();
	}
	
	function FixOrder(strAction){
		document.form_.page_action.value = strAction;
		document.form_.new_transaction.value = '1';
		document.form_.submit();	
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strErrMsg2 = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-PROPERTY","fixing_issue.jsp");
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
	
	String[] astrSemester = {"Summer", "1st Sem", "2nd Sem", "3rd Sem"};
	String[] astrDropListEqual = {"Equal To","Starts With","Ends With","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	
	int iSearchResult = 0;
	
	Vector vPaymentInfo = new Vector();
	Vector vOrderItems = new Vector();
	Vector vRetResult = new Vector();
	
	BookOrders bo = new BookOrders();
	BookManagement bm = new BookManagement();
	
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(!bm.fixPreviousOrderSingle(dbOP,request, Integer.parseInt(strTemp)))
			strErrMsg2 = bm.getErrMsg();
		else
			strErrMsg = "Previous Error Fix";	
	}
	
	if(WI.fillTextValue("new_transaction").length() > 0){		
		vPaymentInfo = bm.getStudentOrderDetail(dbOP, request, 2);
		if(vPaymentInfo == null)
			strErrMsg = bm.getErrMsg();			
		
		vOrderItems = bm.getStudentOrderDetail(dbOP, request, 1);
		if(vOrderItems == null)
			strErrMsg = bm.getErrMsg();			
	}
		
		
	if(strErrMsg2 != null)
		strErrMsg = strErrMsg2;
	
	

%>
<body bgcolor="#D2AE72" onload="document.form_.id_number.focus();">
<form name="form_" action="fixing_issue.jsp" method="post">

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
				strTemp = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>
		  	<td width="80%" colspan="2">
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
			<td height="25">&nbsp;</td>
			<td>ID Number:</td>
			<td colspan="2">
				<input name="id_number" type="text" size="16" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp;&nbsp;
				
		</tr>
		
		
		<tr>
		  	<td height="25" colspan="2">&nbsp;</td>
		  	<td height="25">
			<input type="button" name="transaction_butt" value=" Proceed " 
					onclick="javascript:searchStudent();" style="font-size:11px; height:28px;border: 1px solid #FF0000;" /></td>
					
		  	<td align="right">
			<input type="button" name="fix_me" value=" FIX ORDER " 
					onclick="javascript:FixOrder('1');" style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
			</td>
	  </tr>
	</table>
	
	
<%if(vOrderItems != null && vOrderItems.size() > 0){%>	
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
          	<td height="20" bgcolor="#B9B292" colspan="10" class="thinborder"><div align="center"><strong>LIST OF ORDERED ITEMS </strong></div></td>
        </tr>
		<tr>
			<td align="center" class="thinborder" height="20"><strong>Order Index</strong></td>
			<td align="center" class="thinborder"><strong>Quantity </strong></td>
			<td align="center" class="thinborder"><strong>Payable Amt </strong></td>
			<td align="center" class="thinborder"><strong>Fee Name </strong></td>
			<td align="center" class="thinborder"><strong>Create Date </strong></td>
			<td align="center" class="thinborder"><strong>Payment Index</strong></td>
			<%if(strErrMsg2 != null){%>
			<td align="center" class="thinborder"><strong>Payment Index</strong></td>
			<%}%>
		</tr>
		
		<%
		int iCount = 1;
		for(int i = 0; i < vOrderItems.size(); i+=6, iCount++){%>	
		<tr>
			<td align="center" class="thinborder" height="20"><%=vOrderItems.elementAt(i)%></td>
			<td align="center" class="thinborder"><%=vOrderItems.elementAt(i+1)%></td>
			<td align="center" class="thinborder"><%=vOrderItems.elementAt(i+2)%></td>
			<td align="center" class="thinborder"><%=vOrderItems.elementAt(i+3)%></td>
			<td align="center" class="thinborder"><%=vOrderItems.elementAt(i+4)%></td>
			<td align="center" class="thinborder"><%=vOrderItems.elementAt(i+5)%></td>
			<%
			if(strErrMsg2 != null){					
				strTemp = WI.fillTextValue("payment_index_"+iCount) +","+ (String)vOrderItems.elementAt(i);
			%>
			
			<td align="left" class="thinborder">			
				<input type="text" name="payment_index_<%=iCount%>" value="<%=strTemp%>" />
				<font size="1">payment_index,order_index</font>
			</td>
			<%}%>
		</tr>
		<%}%>
		
		<input type="hidden" name="item_count" value="<%=iCount%>" />
	</table>
	
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr><td height="20">&nbsp;</td></tr>
		<tr></tr>
	</table>
<%}%>




<%if(vPaymentInfo != null && vPaymentInfo.size() > 0){%>	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr><td height="50" colspan="2">&nbsp;</td></tr>
	</table>
			
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">		
		<tr>
          	<td height="20" bgcolor="#B9B292" colspan="10" class="thinborder"><div align="center"><strong>LIST OF PAYMENT </strong></div></td>
        </tr>
		
		<tr>
			<td align="center" class="thinborder" height="20"><strong>Payment Index</strong></td>
			<td align="center" class="thinborder" height="20"><strong>Fee Name</strong></td>
			<td align="center" class="thinborder" height="20"><strong>Date Paid </strong></td>
			<td align="right" class="thinborder" height="20"><strong>Amount </strong></td>			
		</tr>
		
		<%
		double dTemp = 0d;
		for(int i = 0; i < vPaymentInfo.size(); i+=4){%>	
		<tr>
			<td align="center" class="thinborder" height="20"><%=vPaymentInfo.elementAt(i+2)%></td>
			<td align="center" class="thinborder" height="20"><%=vPaymentInfo.elementAt(i+3)%></td>
			<td align="center" class="thinborder" height="20"><%=vPaymentInfo.elementAt(i)%></td>
			
			<%
				dTemp += Double.parseDouble((String)vPaymentInfo.elementAt(i+1));
			%>
			<td align="right" class="thinborder"><%=vPaymentInfo.elementAt(i+1)%></td>			
		</tr>
		<%}%>
		
		<tr>
			<td height="20" align="right" class="thinborder" colspan="3">&nbsp;<strong>Total Paid</strong></td>
			<td align="right" class="thinborder"><%=dTemp%></td>
		</tr>
	</table>
	
<%}%>

	<%if(strErrMsg2 != null){	%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
		<td align="right">
			<input type="button" name="save_me" value=" SAVE " 
					onclick="javascript:FixOrder('2');" style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
		</td>		
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
	
	<input type="hidden" name="new_transaction"  value="<%=WI.fillTextValue("new_transaction")%>"/>
	<input type="hidden" name="get_payment_info" />
	<input type="hidden" name="order_index" value="<%=WI.fillTextValue("order_index")%>" />
	<input type="hidden" name="cancel_order" />
	<input type="hidden" name="delete_items" />
	<input type="hidden" name="for_order" value="1" />
	<input type="hidden" name="page_action" value="" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
