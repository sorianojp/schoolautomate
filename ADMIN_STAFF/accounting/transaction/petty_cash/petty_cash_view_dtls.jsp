<%@ page language="java" import="utility.*, Accounting.Transaction, java.util.Vector"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}

function PrintPg(){
	document.form_.print_pg.value = 1;
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	if(WI.fillTextValue("print_pg").length() > 0){%>
		<jsp:forward page="petty_cash_print.jsp"/>
	<%}
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
								"Admin/staff-ACCOUNTING-TRANSACTION-PETTY CASH","petty_cash_view_dtls.jsp");
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
	String strPCIndex = null;	
	Vector vRetResult = null;
	Vector vChargedTo = null;
	
	if(strPageAction.length() > 0){
	  if(transaction.operateOnPettyCashEntry(dbOP,request,Integer.parseInt(strPageAction)) == null){
	  	strErrMsg = transaction.getErrMsg();			
	  }	  
	}
	
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
	
%>
<form name="form_" method="post" action="./petty_cash_view_dtls.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          VIEW PETTY CASH VOUCHER PAGE ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%if(vRetResult != null && vRetResult.size() > 0){
		strPCIndex = (String) vRetResult.elementAt(0);
	%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Voucher No.</td>
      <%
	  	strTemp = (String) vRetResult.elementAt(1);
	  %>
      <td width="70%" colspan="3"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
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
      <td width="5%" height="26">&nbsp;</td>
      <td width="25%">Voucher Date</td>
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
      <td colspan="3"><%=WI.getStrValue(strTemp,"")%> <input type="hidden" name="amount" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Charged to </td>
      <td colspan="3"><table width="60%" border="1" cellspacing="0" cellpadding="0" bgcolor="#CCCCCC">
          <%for(int i = 0; i < vChargedTo.size() ; i +=4){%>
          <tr> 
            <td width="74%" height="20"><strong><%=(String)vChargedTo.elementAt(i+1)%> :: <%=(String)vChargedTo.elementAt(i+2)%></strong></td>
            <td width="26%" height="20"><strong>&nbsp;<%=(String)vChargedTo.elementAt(i+3)%></strong></td>
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
  	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25" colspan="2"><div align="center"><font size="1"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>click 
          to print Petty Cash Voucher </font></div></td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="print_pg">
  <input type="hidden" name="voucher_no" value="<%=WI.fillTextValue("voucher_no")%>">
  <input type="hidden" name="info_index" value="<%=strPCIndex%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>