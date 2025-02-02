<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script src="../../../jscript/common.js"></script>
<script src="../../../jscript/date-picker.js"></script>
<script src="../../../jscript/td.js"></script>
<script language="javascript">
function UpdateBalance() {
	var iFineAmt   = document.form_.fine_amt.value;
	var iAmtPaid   = document.form_.amt_paid.value;
	var iAmtWaived = document.form_.amt_waived.value;
	if(iFineAmt.length ==0)
		iFineAmt = 0;
	if(iAmtPaid.length ==0)
		iAmtPaid = 0;
	if(iAmtWaived.length ==0)
		iAmtWaived = 0;
	var iAmtBalance = eval(iFineAmt) - eval(iAmtPaid) - eval(iAmtWaived);
	if(eval(iAmtBalance) < 0) {
		alert("Balance can't be -ve");
		return;
	}
	iAmtBalance = iAmtBalance * 100;
	iAmtBalance = Math.round(iAmtBalance);
	iAmtBalance = iAmtBalance/100;
	document.getElementById("balance").innerHTML = eval(iAmtBalance);
	
}
function CloseWnd() {
	window.opener.document.form_.submit();
	self.close();
}
function ShowHide() {
	if(document.form_.post_ledger.checked) {
		showLayer('post_ledger_1');
		showLayer('post_ledger_2');
	}
	else {	
		hideLayer('post_ledger_1');
		hideLayer('post_ledger_2');
	}
}
function PrintReceipt(strReceiptCode) {
	var loadPg = "./fine_pmt_receipt.jsp?code_no="+strReceiptCode;
	var win=window.open(loadPg,"myfile",'dependent=no,width=700,height=500,top=5,left=5,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%@ page language="java" import="utility.*,lms.LmsUtil,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null; String strTemp = null;
	String strUserIndex  = WI.fillTextValue("user_i");

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Circulation-Patrons Fine".toUpperCase()),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Circulation".toUpperCase()),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
//end of authenticaion code.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Circulation-FineMgmt","fine_main_page.jsp");
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

lms.FineManagement fineMgmt = new lms.FineManagement();
if(WI.fillTextValue("page_action").length() > 0) {
	String strReceiptNo = fineMgmt.payBalance(dbOP, strUserIndex, request);
	if(strReceiptNo != null) {
		strErrMsg = "Fine paid successfully. <a href='javascript:CloseWnd();'>"+
		"Click here to close this window.</a>. To print Payment receipt click the Payment receipt #."+
		"Payment receipt number is <a href='javascript:PrintReceipt("+strReceiptNo+");'><font size=3>"+
		strReceiptNo+"</font></a>";
	}
	else	
		strErrMsg = fineMgmt.getErrMsg();
}

double dTotalPayable = 0d;
java.sql.ResultSet rs = dbOP.executeQuery("select sum(FINE_BALANCE) from LMS_BOOK_FINE where user_index="+
                   	            strUserIndex);
if(rs.next())
	dTotalPayable = rs.getDouble(1);
rs.close();

%>
<body bgcolor="#D0E19D">
<form action="./fine_paybalance.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#77A251"><div align="center"><font color="#FFFFFF" ><strong>::::
        FINE MANAGEMENT == POST FINE  ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
</table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td colspan="2"><font size="1">Patron Name (ID) : 
		<b>
<%
rs = dbOP.executeQuery("select fname,mname,lname,id_number from user_table where "+
						"user_index="+strUserIndex);
rs.next();
%><%=WI.formatName(rs.getString(1),rs.getString(2),rs.getString(3),4) + " ("+rs.getString(4)+")"%>
<%rs.close();%>		
		</b>
		</font></td>
      </tr>
<%if(strErrMsg != null){%>
      <tr>
        <td colspan="2"><font size="3" color="#FF0000"><b><%=strErrMsg%></b></font></td>
      </tr>
<%}%>
      <tr>
        <td height="10" colspan="2"><hr size="1"></td>
      </tr>
    </table>

		    <table width="100%" border="0" cellpadding="0" cellspacing="0">
              <tr>
                <td width="2%" height="25">&nbsp;</td>
                <td width="17%" class="thinborderNONE">Fine Balance </td>
                <td width="9%" class="thinborderNONE">
                <input type="text" class="textbox_noborder" style="font-size:11px;background-color:#D0E19D" 
	  		value="<%=dTotalPayable%>" size="8" name="fine_amt" readonly="yes">                </td>
                <td width="2%" class="thinborderNONE">&nbsp;</td>
                <td width="70%" class="thinborderNONE">&nbsp;
<%strTemp = WI.fillTextValue("post_ledger");
if(strTemp.length() > 0) 
	strTemp = " checked";
else	
	strTemp = "";
%>                    <input name="post_ledger" type="checkbox" value="1" onClick="ShowHide();"<%=strTemp%>>
                Post To Ledger</td>
              </tr>
<%if(dTotalPayable > 0d){%>
              <tr>
                <td height="25">&nbsp;</td>
                <td class="thinborderNONE">Amount Paid </td>
                <td><span class="thinborder">
                  <input type="text" class="textbox" style="font-size:11px;" 
	  		value="" size="8" name="amt_paid" onKeyUp="UpdateBalance();">
                </span></td>
                <td>&nbsp;</td>
                <td id="post_ledger_1">
				<%
  	strTemp = WI.fillTextValue("sy_from");
	if(strTemp.length() == 0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	if(strTemp == null)
		strTemp = "";		
%>&nbsp;&nbsp;
                    <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo();">
                  -
  <%
  	strTemp = WI.fillTextValue("sy_to");
	if(strTemp.length() == 0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	if(strTemp == null)
		strTemp = "";		
%>
  <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
  <%
  	strTemp = WI.fillTextValue("semester");
	if(strTemp.length() == 0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	if(strTemp == null)
		strTemp = "";		
%>
  <select name="semester">
    <option value="0">Summer</option>
    <%
if(strTemp.equals("1")){%>
    <option value="1" selected>1st Sem</option>
    <%}else{%>
    <option value="1">1st Sem</option>
    <%}if(strTemp.equals("2")){%>
    <option value="2" selected>2nd Sem</option>
    <%}else{%>
    <option value="2">2nd Sem</option>
    <%}if(strTemp.equals("3") ){%>
    <option value="3" selected>3rd Sem</option>
    <%}else {%>
    <option value="3">3rd Sem</option>
    <%}%>
</select>
		</td>
              </tr>
              <tr>
                <td height="25">&nbsp;</td>
                <td class="thinborderNONE">Waived</td>
                <td><span class="thinborder">
                  <input type="text" class="textbox" style="font-size:11px;" 
	  		value="" size="8" name="amt_waived" onKeyUp="UpdateBalance();">
                </span></td>
                <td>&nbsp;</td>
                <td class="thinborderNONE" id="post_ledger_2">&nbsp;&nbsp;Post Fee Note : 
<%
strTemp = WI.fillTextValue("post_ledger_note");
if(strTemp.length() == 0) 
	strTemp = "Fine from Library.";				
%>
					<input type="text" name="post_ledger_note" class="textbox" value="<%=strTemp%>">
				
				</td>
              </tr>
<script language="javascript">
this.ShowHide();
</script>			 
              
              <tr>
                <td height="25">&nbsp;</td>
                <td class="thinborderNONE">Balance</td>
                <td colspan="3"><label id="balance" style="color:#FF0000; font-weight:bold"></label></td>
              </tr>
<script language="javascript">
	this.UpdateBalance();
</script>
             <tr>
                <td height="25">&nbsp;</td>
               <td colspan="4" align="center"><input type="submit" value="Accept Payment >>" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value=1">
                <font size="1">&nbsp;&nbsp;&nbsp;Click to accept fine</font></td>
              </tr>
<%}%>
            </table>



<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td height="25">&nbsp;</td>
    <td width="49%" valign="middle">&nbsp;</td>
    <td width="50%" valign="middle">&nbsp;</td>
  </tr>
  <tr bgcolor="#77A251"> 
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="page_action">
<input type="hidden" name="user_i" value="<%=WI.fillTextValue("user_i")%>"><!-- to save index -->
<input type="hidden" name="fine_code">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>