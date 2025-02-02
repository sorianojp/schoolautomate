<%@ page language="java" import="utility.*, Accounting.Transaction, java.util.Vector"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}

function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}

function searchVoucher(strPCIndex,strTotalAmount) {
	var pgLoc = "./petty_cash_summary.jsp?opner_info=form_.voucher_no";
	var win=window.open(pgLoc,"SearchWindow",'width=700,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");	

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
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
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-DTR Entry (Manual)","petty_cash_update_payment_stat.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}
		
	Transaction transaction = new Transaction();
	String strPageAction = WI.fillTextValue("page_action");
	String strProceedClicked = WI.getStrValue(WI.fillTextValue("proceedClicked"),"0");
	String strPCIndex = null;	
	Vector vRetResult = null;
	Vector vChargedTo = null;
	
	if(strPageAction.length() > 0){
	  if(transaction.operateOnPettyCashEntry(dbOP,request,Integer.parseInt(strPageAction)) == null){
	  	strErrMsg = transaction.getErrMsg();			
	  }	  
	}
	
	if(strProceedClicked.equals("1")){
		if (WI.fillTextValue("voucher_no").length() > 0){
		vRetResult = transaction.operateOnPettyCashEntry(dbOP,request,3);
			if(vRetResult == null){
				strErrMsg = transaction.getErrMsg();
			}else{
				strPCIndex = (String) vRetResult.elementAt(0);
				vChargedTo = transaction.operateOnChargeTo(dbOP,request,4,strPCIndex);
				if(((String)vRetResult.elementAt(11)).equals("1")){
					strErrMsg = "Payment released to payee";		
				}
			}
		}else{
			strErrMsg = "Enter Voucher Number";
		}
	}		
	
%>
<form name="form_" method="post" action="./petty_cash_update_payment_stat.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          PETTY CASH VOUCHER - UPDATE PAYMENT RECEIVED STATUS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:13px; color:#FF0000; font-weight:bold"><a href="petty_cash.jsp"><img src="../../../../images/go_back.gif" border="0"></a>&nbsp; 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Voucher No.</td>
      <td width="18%"><input name="voucher_no" type="text" size="16" value="<%=WI.fillTextValue("voucher_no")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
      </td>
      <td width="9%"><font size="1"><a href="javascript:searchVoucher();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a></font></td>
      <td width="54%"><font size="1"><a href="javascript:ProceedClicked();"><img src="../../../../images/form_proceed.gif" border="0"></a></font></td>
    </tr>
     <tr>
      <td height="26">&nbsp;</td>
      <td>Pending Voucher </td>
      <td colspan="3">
	  <table cellpadding="0" cellspacing="0" class="thinborder" width="90%">
<%
java.sql.ResultSet rs = dbOP.executeQuery("select VOUCHER_NO from AC_PC_VOUCHER where PC_VOUCHER_STAT = 0 order by voucher_no");
while(rs.next()) {%>
		  	<tr>
				<td class="thinborder" width="50%"><a href="./petty_cash_update_payment_stat.jsp?proceedClicked=1&voucher_no=<%=rs.getString(1)%>"><%=rs.getString(1)%></a></td>
				<td class="thinborder" width="50%">
					<%if(rs.next()){%>
						<a href="./petty_cash_update_payment_stat.jsp?proceedClicked=1&voucher_no=<%=rs.getString(1)%>"><%=rs.getString(1)%></a>
					<%}else{%>&nbsp;<%}%>			  </td>
			</tr>
<%}
rs.close();
%>		
		</table>	  </td>
    </tr>
   <tr> 
      <td height="26" colspan="5"><hr size="1"></td>
    </tr>
	<%if(strProceedClicked.equals("1") && vRetResult != null && vRetResult.size() > 0){
		strPCIndex = (String) vRetResult.elementAt(0);
	%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Voucher No.</td>
	  <%
	  	strTemp = (String) vRetResult.elementAt(1);
	  %>
      <td colspan="3"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition No.</td>
	  <%
	  	strTemp = (String) vRetResult.elementAt(2);
	  %>	  
      <td colspan="3"><%=WI.getStrValue(strTemp,"")%></td>
    </tr>
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="15%">Voucher Date</td>
	  <%
	  	strTemp = (String) vRetResult.elementAt(3);
	  %>	  
      <td colspan="3"><%=WI.getStrValue(strTemp,"")%></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Payee</td>
	  <%
	  	strTemp = (String) vRetResult.elementAt(4);
	  %>			  
      <td colspan="3"><%=WI.getStrValue(strTemp,"")%></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Explanation(s)</td>
	  <%
	  	strTemp = (String) vRetResult.elementAt(5);
	  %>	  
      <td colspan="3"><%=WI.getStrValue(strTemp,"")%></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Amount </td>
	  <%
	  	strTemp = (String) vRetResult.elementAt(6);
	  %>
      <td colspan="3"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"")%><input type="hidden" name="amount" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Charged to </td>
      <td colspan="3"><table width="60%" border="1" cellspacing="0" cellpadding="0" bgcolor="#CCCCCC">
          <%for(int i = 0; i < vChargedTo.size() ; i +=4){%>
          <tr> 
            <td width="74%" height="20"><strong><%=(String)vChargedTo.elementAt(i+1)%> 
              :: <%=(String)vChargedTo.elementAt(i+2)%></strong></td>
            <td width="26%" height="20"><div align="right"><strong>&nbsp;<%=CommonUtil.formatFloat((String)vChargedTo.elementAt(i+3),true)%>&nbsp;</strong></div></td>
          </tr>
          <%}%>
        </table></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Prepared by</td>
	  <%
	  	strTemp = (String) vRetResult.elementAt(7);
	  %>
      <td colspan="3"><%=WI.getStrValue(strTemp,"")%></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Checked by</td>
	  <%
	  	strTemp = (String) vRetResult.elementAt(8);
	  %>	  
      <td colspan="3"><%=WI.getStrValue(strTemp,"")%></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Approved for Payment</td>
	  <%
	  	strTemp = (String) vRetResult.elementAt(9);
	  %>	  
      <td colspan="3"><%=WI.getStrValue(strTemp,"")%></td>
    </tr>
	<%}// end if strProceedClicked == 1%>
  </table>
  	<%if(strProceedClicked.equals("1") && vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="4%" height="50">&nbsp;</td>
      <td width="14%">&nbsp;</td>
      <td width="26%">Status : 
        <%
			strTemp = WI.fillTextValue("voucher_stat");
		%> <select name="voucher_stat">
          <!--<option value="0">Payment Still in Cashier</option>-->
          <%if(strTemp.equals("1")){%>
          <option value="1" selected>Payment Given to Payee </option>
          <%}else{%>
          <option value="1">Payment Given to Payee </option>
          <%}%>
        </select> </td>
      <td width="56%">Date Payment Given to Payee : 
	  	<%	
			if(WI.fillTextValue("date_given").length() > 0)
				strTemp = WI.fillTextValue("date_given");
			else
				strTemp = WI.getTodaysDate(1);
		%>
        <input name="date_given" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.date_given');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="50" colspan="4"> <div align="center"> 
          <%if(!((String) vRetResult.elementAt(11)).equals("1")){%>
          <a href="javascript:PageAction(5,'');"><img src="../../../../images/save.gif" border="0"></a> 
          <font size="1">click to save update</font> 
          <%}%>
          <a href="petty_cash_update_payment_stat.jsp"><img src="../../../../images/cancel.gif" border="0"></a> 
          <font size="1">click to cancel/clear update</font></div></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><div align="left"></div></td>
    </tr>
  </table>
  <%}// end if strProceedClicked == 1%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25"><div align="left"></div></td>
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="info_index" value="<%=strPCIndex%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">	

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>