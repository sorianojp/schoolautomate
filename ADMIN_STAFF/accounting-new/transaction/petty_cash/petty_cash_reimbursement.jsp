<%@ page language="java" import="utility.*, Accounting.Transaction, java.util.Vector"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD.borderBottomLeftRight {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
TD.borderBottomLeft {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
TD.borderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
</style>
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
function searchRefNo() {
	var pgLoc = "./petty_cash_search_ref_no.jsp?opner_info=form_.cd_ref_no";
	var win=window.open(pgLoc,"SearchWindow",'width=600,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
								"Admin/staff-Accounting-Transaction-petty cash","petty_cash_reimbursement.jsp");
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
	double dTotalAmount = 0d;
	Vector vRetResult = null;
	boolean bolNotReleased = false;
	if(strPageAction.length() > 0){
  	  if(transaction.receivePCVReplenish(dbOP,request,Integer.parseInt(strPageAction)) == null){
		strErrMsg = transaction.getErrMsg();
	  }else{
	  	strErrMsg = "Operation successful";
	  }
	}
	if(WI.fillTextValue("cd_ref_no").length() > 0){
		vRetResult = transaction.receivePCVReplenish(dbOP,request,4);
		if(vRetResult == null && strErrMsg == null)
			strErrMsg = transaction.getErrMsg();
	}
	else
		strErrMsg = "Enter reference number";
%>
<form name="form_" method="post" action="./petty_cash_reimbursement.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          PETTY CASH VOUCHER - REIMBURSEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:13px; color:#FF0000; font-weight:bold"><a href="petty_cash.jsp"><img src="../../../../images/go_back.gif" border="0"></a>&nbsp;
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="5%" height="26">&nbsp;</td>
      <td width="16%">Reference No.</td>
      <td width="19%"><input name="cd_ref_no" type="text" size="16" value="<%=WI.fillTextValue("cd_ref_no")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>      </td>
      <td width="60%"><a href="javascript:searchRefNo();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a><a href="javascript:ProceedClicked();"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>CD Released List </td>
      <td colspan="2">
	  <table cellpadding="0" cellspacing="0" class="thinborder" width="90%">
<%
java.sql.ResultSet rs = dbOP.executeQuery("select distinct CD_REF_NO from AC_PC_VOUCHER where IS_CD_RELEASED = 1 and IS_REIMBURSED =0");
while(rs.next()) {%>
		  	<tr>
				<td class="thinborder" width="50%"><a href="./petty_cash_reimbursement.jsp?proceedClicked=1&cd_ref_no=<%=rs.getString(1)%>"><%=rs.getString(1)%></a></td>
				<td class="thinborder" width="50%">
					<%if(rs.next()){%>
						<a href="./petty_cash_reimbursement.jsp?proceedClicked=1&cd_ref_no=<%=rs.getString(1)%>"><%=rs.getString(1)%></a>
					<%}else{%>&nbsp;<%}%>			  </td>
			</tr>
<%}
rs.close();
%>
		</table>	  </td>
    </tr>
    <tr>
      <td height="26" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <%if(strProceedClicked.equals("1") && vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="3" class="borderBottom"><div align="center"><strong>REIMBURSEMENT
          FOR THE FOLLOWING VOUCHERS</strong></div></td>
    </tr>
    <tr>
      <td width="24%" class="borderBottomLeft"><div align="center"><strong>Voucher
          Date</strong></div></td>
      <td width="38%" class="borderBottomLeft"><div align="center"><strong>Petty
          Cash Voucher #</strong></div></td>
      <td width="26%"  height="25" class="borderBottomLeft"><div align="center"><strong>Amount</strong></div></td>
    </tr>
    <% int iRowCount = 0;
	for(int i = 0; i<vRetResult.size(); i+=4,iRowCount++){
		if(((String)vRetResult.elementAt(i+3)).equals("0")){
		  bolNotReleased = true;
		}
	%>
    <tr>
      <td class="borderBottomLeft">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td class="borderBottomLeft">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td height="24" class="borderBottomLeft"><div align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+2),true)%>&nbsp;</div></td>
	<%
	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+2),"0");
	dTotalAmount += Double.parseDouble(strTemp);
	%>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">Total amount: <%=CommonUtil.formatFloat(dTotalAmount,true)%>
	  <input type="hidden" name="total_amount" value="<%=dTotalAmount%>"></td>
    </tr>
    <tr>
      <td height="30"><div align="center"><font size="1">
          <%if(!bolNotReleased){%>
          <a href="javascript:PageAction(1);"><img src="../../../../images/save.gif" border="0"></a>
          <font size="1" >click to save update</font><a href="petty_cash_reimbursement.jsp"><img src="../../../../images/cancel.gif" border="0"></a>click
          to cancel</font>
          <%}else{%>
          Disbursement not yet released
          <%}%>
        </div></td>
    </tr>
    <tr>
      <td height="10"><div align="left"></div></td>
    </tr>
  </table>
  <%}// end if strProceedClicked == 1%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="94%" height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
