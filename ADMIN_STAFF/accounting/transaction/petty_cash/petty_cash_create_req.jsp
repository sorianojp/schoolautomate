<%@ page language="java" import="utility.*, Accounting.Transaction, java.util.Vector"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
TD.borderAll {
    border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	border-top: solid 1px #000000;
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

function checkAll()
{
	var maxDisp = document.form_.row_count.value;
	//unselect if it is unchecked.
	if(!document.form_.selAll.checked)
	{
		for(var i =0; i< maxDisp; ++i)
		{
			eval('document.form_.pc_voucher'+i+'.checked=false');
		}
		return;
	}
	//this is the time I will check all.
	for(var i =0; i< maxDisp; ++i)
	{
		eval('document.form_.pc_voucher'+i+'.checked = true');
	}
}

function checkAllDel()
{
	var maxDisp = document.form_.row_encoded.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllDel.checked)
	{
		for(var i =0; i< maxDisp; ++i)
		{
			eval('document.form_.pc_voucher_en'+i+'.checked=false');
		}
		return;
	}
	//this is the time I will check all.
	for(var i =0; i< maxDisp; ++i)
	{
		eval('document.form_.pc_voucher_en'+i+'.checked = true');
	}
}
function searchRefNo() {
	var pgLoc = "./petty_cash_search_ref_no.jsp?opner_info=form_.cd_ref_no";
	var win=window.open(pgLoc,"SearchWindow",'width=600,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="document.form_.cd_ref_no.focus()">
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
								"Admin/staff-Accounting-Transaction-petty cash","petty_cash_create_req.jsp");
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
	String strTDColor = "";
	Vector vRetResult = null;	
	Vector vPending = null;
	Vector vEncoded = null;
	boolean bolNoDelete = false;
	if(strPageAction.length() > 0){
  	  if(transaction.operateonPCVReplenish(dbOP,request,Integer.parseInt(strPageAction)) == null){
		strErrMsg = transaction.getErrMsg();
	  }
	}
	
	if(strProceedClicked.equals("1")){	  
		vRetResult = transaction.operateonPCVReplenish(dbOP,request,4);
		if(vRetResult != null){
			vPending = (Vector) vRetResult.elementAt(0);
			vEncoded = (Vector) vRetResult.elementAt(1);
		}else{
		  if(WI.fillTextValue("cd_ref_no").length() > 0)
			strErrMsg = transaction.getErrMsg();
		}
	}
			
%>
<form name="form_" method="post" action="./petty_cash_create_req.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          PETTY CASH VOUCHER - CREATE REQUISITION FOR REPLENISHMENT::::</strong></font></div></td>
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
      <td width="17%"><input name="cd_ref_no" type="text" size="16" value="<%=WI.fillTextValue("cd_ref_no")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td><a href="javascript:searchRefNo();"><img src="../../../../images/search.gif" border="0"></a><input type="image" src="../../../../images/form_proceed.gif" onClick="document.form_.proceedClicked.value='1';"></td>
    </tr>
    <tr> 
      <td height="26" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <%if(strProceedClicked.equals("1") && vPending != null && vPending.size() > 0){%>
<!---->  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="4" class="borderAll"><div align="center"><strong>PETTY 
          CASH VOUCHERS NOT YET REQUESTED FOR REPLENISHMENT</strong></div></td>
    </tr>
    <tr> 
      <td width="24%" class="borderBottomLeft"><div align="center"><strong>Voucher 
          Date</strong></div></td>
      <td width="38%" class="borderBottomLeft"><div align="center"><strong>Petty 
          Cash Voucher #</strong></div></td>
      <td width="26%"  height="25" class="borderBottomLeft"><div align="center"><strong>Amount</strong></div></td>
      <td width="12%" class="borderBottomLeftRight"><div align="center"><strong>SELECT<br>
          <input type="checkbox" name="selAll" value="0" onClick="checkAll();">
          </strong></div></td>
    </tr>
    <% int iRowCount = 0;
	for(int i = 0; i<vPending.size(); i+=5,iRowCount++){
		if(!WI.getStrValue((String)vPending.elementAt(i+4),"0").equals("1"))
			strTDColor = "bgcolor=#DDDDDD";
		else
			strTDColor = "";
	%>
    <tr <%=strTDColor%>> 
      <td class="borderBottomLeft">&nbsp;<%=(String)vPending.elementAt(i+1)%></td>
      <td class="borderBottomLeft">&nbsp;<%=(String)vPending.elementAt(i+2)%></td>
      <td height="24" class="borderBottomLeft"><div align="right"><%=CommonUtil.formatFloat((String)vPending.elementAt(i+3),true)%>&nbsp;</div></td>
      <td class="borderBottomLeftRight"> <div align="center"> 
          <input type="hidden" name="pc_index<%=iRowCount%>" value="<%=(String)vPending.elementAt(i)%>">
          <input type="checkbox" name="pc_voucher<%=iRowCount%>" value="1">
        </div></td>
    </tr>
    <%}%>
    <input type="hidden" name="row_count" value="<%=iRowCount%>">
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="18"><font size="1"></font></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="30"><div align="center"><font size="1"><a href="javascript:PageAction(1);"><img src="../../../../images/save.gif" border="0"></a> 
          <font size="1" >click to save update</font><a href="petty_cash_create_req.jsp"><img src="../../../../images/cancel.gif" border="0"></a>click 
          to cancel</font></div></td>
    </tr>
    <tr> 
      <td height="10"><div align="left"></div></td>
    </tr>
  </table>
<!---->  
  <%}// end if strProceedClicked == 1%>
  <%if(strProceedClicked.equals("1") && vEncoded != null && vEncoded.size() > 0){
  double dTotAmout = 0d;%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="4" class="borderAll"><div align="center"><strong>PETTY CASH FOR REPLENISHMENT</strong></div></td>
    </tr>
    <tr> 
      <td width="24%" class="borderBottomLeft"><div align="center"><strong>Voucher Date</strong></div></td>
      <td width="38%" class="borderBottomLeft"><div align="center"><strong>Petty Cash 
          Voucher #</strong></div></td>
      <td width="26%"  height="25" class="borderBottomLeft"><div align="center"><strong>Amount</strong></div></td>
      <td width="12%" class="borderBottomLeftRight"><div align="center"><strong>SELECT<br>
          <input type="checkbox" name="selAllDel" value="0" onClick="checkAllDel();">
          </strong></div></td>
    </tr>
    <% int iRowEncoded = 0;
	for(int i = 0; i<vEncoded.size(); i+=5,iRowEncoded++){
	  if(((String)vEncoded.elementAt(i+4)).equals("1")){
		bolNoDelete = true;
	  }
	  dTotAmout += Double.parseDouble((String)vEncoded.elementAt(i+3));
	%>
    <tr> 
      <td class="borderBottomLeft">&nbsp;<%=(String)vEncoded.elementAt(i+1)%></td>
      <td class="borderBottomLeft">&nbsp;<%=(String)vEncoded.elementAt(i+2)%></td>
      <td height="24" class="borderBottomLeft"><div align="right"><%=CommonUtil.formatFloat((String)vEncoded.elementAt(i+3),true)%>&nbsp;</div></td>
      <td class="borderBottomLeftRight"> <div align="center"> 
          <input type="hidden" name="pc_index_en<%=iRowEncoded%>" value="<%=(String)vEncoded.elementAt(i)%>">
          <input type="checkbox" name="pc_voucher_en<%=iRowEncoded%>" value="1">
        </div></td>
    </tr>
    <%}%>
    <input type="hidden" name="row_encoded" value="<%=iRowEncoded%>">
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="25%" height="25">&nbsp;</td>
      <td width="37%" height="25">&nbsp;</td>
      <td width="26%" height="25" align="right" style="font-size:11px;">Total Amount: <%=CommonUtil.formatFloat(dTotAmout,true)%>&nbsp;</td>
      <td width="12%" height="25">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>	
    <tr> 
      <td height="30"><div align="center">
	  <%if(!bolNoDelete){%>
	  <a href="javascript:PageAction(0);"><img src="../../../../images/delete.gif" width="55" height="28" border="0"></a> 
          <font size="1" >click to remove from request</font></div>
	  <%}else{%>
        Delete no longer Allowed.Cash disbursement voucher already created 
        <%}%>
	  </td>
    </tr>
    <tr> 
      <td height="10"><div align="left"></div></td>
    </tr>
  </table>
  <%}%>
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