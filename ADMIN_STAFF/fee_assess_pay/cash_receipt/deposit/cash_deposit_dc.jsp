<%@ page language="java" import="utility.*,Accounting.CashReceiptBook,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
	function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
			
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		document.form_.emp_id.value = strID;
		document.getElementById("coa_info").innerHTML = "";
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this record.'))
				return;
		}
		document.form_.page_action.value = strAction;
		document.form_.info_index.value  = strInfoIndex;
		document.form_.submit();
	}
</script>
<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-CASH DEPOSIT-create debit/credit entry","cash_deposit_dc.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Fee Assessment & Payments","CASH DEPOSIT",request.getRemoteAddr(),
															"cash_deposit_dc.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.
	
Vector vRetResult = null;
enrollment.CashDeposit CD = new enrollment.CashDeposit();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(CD.operateOnDebitCreditNote(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = CD.getErrMsg();
	else	
		strErrMsg = "Operation successful";
}
vRetResult = CD.operateOnDebitCreditNote(dbOP, request, 4);
if(strErrMsg == null && vRetResult == null)
	strErrMsg = CD.getErrMsg();

%>
<form name="form_" action="./cash_deposit_dc.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: CASH DEPOSIT ADJUSTMENT ENTRY::::</strong></font></div></td>
		</tr>
		<tr>
			<td width="3%" height="20">&nbsp;</td>
			<td width="97%" colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="3%" height="20">&nbsp;</td>
			<td width="15%" style="font-size:11px;">Teller ID: </td>
		    <td width="82%">
				<input name="emp_id" type="text" class="textbox" size="20" onKeyUp="AjaxMapName();" 
					onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("emp_id")%>"
					onBlur="style.backgroundColor='white'" autocomplete="off">&nbsp;
			
			<label id="coa_info" style="position:absolute; width:350px;"></label>
			
			<a href="#"><img src="../../../../images/refresh.gif" onClick="document.form_.page_action.value='',document.form_.submit();" border="0"></a>
			</td>
		</tr>
		<tr>
		  <td height="20">&nbsp;</td>
		  <td style="font-size:11px;">Amount to adjust </td>
		  <td>
			<input type="text" name="begin_balance" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		  onKeyUp="AllowOnlyFloat('form_','begin_balance');" value="<%=WI.fillTextValue("begin_balance")%>"> 
		  <font size="1">(enter +ve amount to increase cash on hand  and -ve amount to reduce cash on hand)</font></td>
	  </tr>
		<tr>
		  <td height="20">&nbsp;</td>
		  <td style="font-size:11px;">Date to adjust </td>
		  <td>
		<input name="as_of" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("as_of")%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      		<a href="javascript:show_calendar('form_.as_of');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
  		  </td>
	  </tr>
		<tr>
		  <td height="20">&nbsp;</td>
		  <td style="font-size:11px;">Debit/Credit Note </td>
		  <td>
		  <textarea name="note" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			 rows="2" cols="90" style="font-size:9px;"><%=WI.fillTextValue("note")%></textarea>
		  </td>
	  </tr>
		<tr>
		  <td height="20">&nbsp;</td>
		  <td style="font-size:11px;">&nbsp;</td>
		  <td style="font-size:11px;"><a href="javascript:PageAction('1', '')"><img src="../../../../images/save.gif" border="0"></a></td>
	  </tr>
	</table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr> 
		  	<td height="20" style="font-size:9px; font-weight:bold" align="center">::: DEBIT CREDIT INFORMATION :::</td>
		</tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		
		<tr style="font-weight:bold" align="center">
			<td width="5%" height="20" class="thinborder">Count</td>
			<td width="10%" class="thinborder">Teller ID</td>
			<td width="20%" class="thinborder">Teller Name</td>
			<td width="10%" class="thinborder">Amount Adjusted </td>
			<td width="55%" class="thinborder">Debit Credit Note</td>
		    <!--<td width="7%" class="thinborder">Edit</td>-->
	    </tr>
	<%	int iCount = 1;
	for(int i = 0; i < vRetResult.size(); i += 6) {%>
		<tr>
			<td height="20" align="center" class="thinborder"><%=iCount++%></td>
		    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 1), "&nbsp;")%></td>
		    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 2), "&nbsp;")%></td>
		    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 5), "&nbsp;")%></td>
	      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 4), "&nbsp;")%></td>
		  <!--<td class="thinborder"></td>-->
	    </tr>
	<%}%>
	</table>
<%}%>	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20">&nbsp;</td>
		</tr>
		<tr bgcolor="#B8CDD1">
			<td height="20" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>

<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>