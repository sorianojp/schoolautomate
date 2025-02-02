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
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
	function PrintPage() {
		if(!confirm('Click Ok to Print. Printing will Lock this report. Cancel to return to this page.'))
			return;
		location = './cash_deposit_teller_report.jsp?print_=1&col_date='+document.form_.date_fr.value;
	}
	function UpdateCDDetail(strInfoIndex) {
		var loadPg = "./record_cd_perbank.jsp?ref_="+strInfoIndex;
		var win=window.open(loadPg,"Record Cash Deposit Information",'dependent=yes,width=750,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}

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
	function ReloadPage() {
		document.form_.page_action.value = '';
		document.form_.submit();
	}
	function CopyValue(objChkBox, objCopyTo, objValToCopy) {
		if(objChkBox.checked) {
			objCopyTo.value = objValToCopy;
		}
		else if(objCopyTo.value == objValToCopy){
			objCopyTo.value = "";
		}
	}
	function ajaxUpdateSum() {
		if(!document.form_._copy3.checked) {
			document.form_._bank_deposited.value = '';
			return;
		}
		var strAmtToSum = document.form_._begin_bal.value+"_"+document.form_._cash_remitted.value+"_"+document.form_._check_remitted.value;
	
		var objCOAInput = document.form_._bank_deposited;
		this.InitXmlHttpObject(objCOAInput, 1);//I want to get value in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=150&input="+strAmtToSum+"&format=1";
		this.processRequest(strURL);
	}
	
	
</script>
<body bgcolor="#D2AE72" onLoad="document.form_.emp_id.focus()">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-CASH DEPOSIT-deposit","cash_deposit_main_restricted.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"cash_deposit_main_restricted.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","REPORTS-CASHIER REPORT",request.getRemoteAddr(),
														"cash_deposit_main_restricted.jsp");
}
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
Vector vEditInfo  = null; 
Vector vCDDetail = null; Vector vCDSummary = null;//cahs deposit detail and summary  - in bank.

String strTellerIndex = null;
String strTellerName  = null;
String strInfoIndex   = null;//set DEPOSIT_MAIN_INDEX if page_action = 1.

///information used in this page. 
double dCash     = 0d;
double dCheck    = 0d;
double dSD       = 0d;
double dCC       = 0d;
double dBeginBal = 0d;
/// end

Vector vDepositsMade = new Vector();

enrollment.CashDeposit CD = new enrollment.CashDeposit();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	Vector vTemp = CD.operateOnCashDepositMain(dbOP, request, Integer.parseInt(strTemp));
	if(vTemp == null) 
		strErrMsg = CD.getErrMsg();
	else {	
		strErrMsg = "Operation successful";
		if(strTemp.equals("1"))
			strInfoIndex = (String)vTemp.elementAt(0);
	}
}
Accounting.CashReceiptBook CRB = new Accounting.CashReceiptBook();
String strSQLQuery = null;
java.sql.ResultSet rs = null;

boolean bolShowPrint = false;
boolean bolIsLocked = false;

String strEmpID = (String)request.getSession(false).getAttribute("userId");
strTellerIndex = (String)request.getSession(false).getAttribute("userIndex");
strTellerName = (String)request.getSession(false).getAttribute("first_name");
String strDatePaid = null;
boolean bolSaveNotAllowed = false;

if(strInfoIndex == null && strTellerIndex != null) {//get details if there are any.. 
	strDatePaid = ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_fr"));

	strSQLQuery = "select DEPOSIT_MAIN_INDEX, create_time, DEPOSITED_IN_BANK,is_completed,deposited_in_bank from CASH_DEPOSIT_MAIN where is_valid = 1 and teller_index = "+strTellerIndex+
				" and DATE_DEPOSIT_FROM = '"+strDatePaid+"'";//System.out.println(strSQLQuery);
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vDepositsMade.addElement(rs.getString(1));
		vDepositsMade.addElement(CommonUtil.convert24HRTo12Hr(rs.getDouble(2)));
		vDepositsMade.addElement(CommonUtil.formatFloat(rs.getDouble(3), true));
		if(rs.getInt(4) == 2 || rs.getDouble(5) == 0d)///allow printing if there is no deposit made.. 
			bolShowPrint = true;
	}		
	rs.close();
	if(vDepositsMade.size() == 3)
		strInfoIndex = (String)vDepositsMade.elementAt(0);//set it, so it can be loaded s
}

if(strInfoIndex != null) {//either date is clicked in case of multiple deposit entries, or if first time created.. 
	request.setAttribute("info_index", strInfoIndex);
	vEditInfo = CD.operateOnCashDepositMain(dbOP, request, 3);

	vCDDetail = CD.operateOnCashDepositDetail(dbOP, request, 4, strInfoIndex); 
	if(vCDDetail != null && vCDDetail.size() > 0)
		vCDSummary = (Vector)vCDDetail.remove(0);
	
}
else if(strTellerIndex != null) {
	if(CD.checkIfAllowedToProcessDeposit(dbOP, strTellerIndex, strDatePaid) == 1) {
		vRetResult = CRB.getTotalTellerAmount(dbOP, request);
		if(vRetResult == null)
			strErrMsg = CRB.getErrMsg();
		//strSQLQuery = "select sum(BEGIN_BAL) from CASH_DEPOSIT_BEGIN_BAL where teller_index = "+strTellerIndex+" and is_valid = 1";
		strSQLQuery = "select cash_on_hand_encoded, check_on_hand_encoded from CASH_DEPOSIT_MAIN where teller_index = "+strTellerIndex+" and date_deposit_from < '"+strDatePaid+
		"' and is_valid = 1 order by date_deposit_from desc";
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next())	
			dBeginBal = rs.getDouble(1) + rs.getDouble(2);
		else {
			rs.close();
			strSQLQuery = "select sum(BEGIN_BAL) from CASH_DEPOSIT_BEGIN_BAL where teller_index = "+strTellerIndex+" and is_valid = 1";
			rs = dbOP.executeQuery(strSQLQuery);
			if(rs.next())	
				dBeginBal = rs.getDouble(1);
		}
		rs.close();
	}
	else {
		strErrMsg = CD.getErrMsg();
		bolSaveNotAllowed = true;
	}
}
//System.out.println(dBeginBal);

if(vEditInfo != null && ((String)vEditInfo.elementAt(14)).equals("1"))
	bolIsLocked = true;


%>
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFCC66">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page <label id="page_progress"></label></font></p>
			
			<!--<img src="../../../Ajax/ajax-loader2.gif">--></td>
      </tr>
</table>
</div>

<form name="form_" action="./cash_deposit_main_restricted.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: CASH DEPOSIT PAGE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td width="2%" height="20">&nbsp;</td>
			<td width="98%" colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="2%" height="20">&nbsp;</td>
			<td width="15%" style="font-size:11px;">Teller ID: </td>
		    <td colspan="2">
				<input name="emp_id" type="text" class="textbox_noborder" style="font-size:16px;" size="20" readonly="yes" value="<%=strEmpID%>" autocomplete="off"></td>
		</tr>
		
		<tr>
		  <td height="20">&nbsp;</td>
		  <td style="font-size:11px;">Collection Date:</td>
		  <td colspan="2">
<%
strTemp = WI.fillTextValue("date_fr");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
		<input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      		<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>	  		  </td>
	  </tr>
		
		<tr>
		  <td height="25">&nbsp;</td>
		  <td style="font-size:11px;">&nbsp;</td>
		  <td width="19%" valign="bottom" style="font-size:11px;"><a href="javascript:ReloadPage()"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
	      <td width="64%" valign="bottom" align="right" style="font-size:18px; font-weight:bold">
		  <%if(bolIsLocked) {%>
		  	Report is Locked. Modification is not allowed
		    <%}%>
		  
		  </td>
	  </tr>
	</table>
<%
if(vRetResult != null || vEditInfo != null) {
	if(vEditInfo != null) {
		dCash     = ((Double)vEditInfo.elementAt(4)).doubleValue();
		dCheck    = ((Double)vEditInfo.elementAt(5)).doubleValue();
		dSD       = ((Double)vEditInfo.elementAt(6)).doubleValue();
		dBeginBal = ((Double)vEditInfo.elementAt(3)).doubleValue();
	}
	if(vRetResult != null) {
		dCash     = ((Double)vRetResult.remove(0)).doubleValue();
		dCheck    = ((Double)vRetResult.remove(0)).doubleValue();
		dSD       = ((Double)vRetResult.remove(0)).doubleValue();
		dCC       = ((Double)vRetResult.remove(0)).doubleValue();
		dSD = dSD + dCC;//accumulated.
		dCC = 0d;
		//dBeginBal = 0d;//((Double)vRetResult.remove(0)).doubleValue();
	}
%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr> 
		  	<td style="font-size:14px; font-weight:bold" align="center" class="thinborderBOTTOM">::: COLLECTION INFORMATION :::</td>
		</tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td width="60%" valign="top">
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
					<tr>
						<td width="2%" height="25">&nbsp;</td>
						<td width="26%" style="font-size:14px;">Begining Balance:</td>
						<td width="72%" style="font-size:14px; font-weight:bold"><input type="text" name="_begin_bal" value="<%=CommonUtil.formatFloat(dBeginBal,true)%>" readonly="yes" class="textbox_bigfont" style="text-align:right; border:0px;" size="14"> 
						<font style="font-size:9px; font-weight:normal">(System generated)</font></td>
					</tr>
					<tr>
					  <td height="25">&nbsp;</td>
					  <td style="font-size:14px;">Cash Collected:</td>
					  <td style="font-size:14px; font-weight:bold"><input type="text" name="_cash" value="<%=CommonUtil.formatFloat(dCash,true)%>" readonly="yes" class="textbox_bigfont" style="text-align:right; border:0px;" size="14">
				      <font style="font-size:9px; font-weight:normal">(System generated)</font></td>
				  </tr>
					<tr>
					  <td height="25">&nbsp;</td>
					  <td style="font-size:14px;">Check Collected:</td>
					  <td style="font-size:14px; font-weight:bold"><input type="text" name="_check" value="<%=CommonUtil.formatFloat(dCheck,true)%>" readonly="yes" class="textbox_bigfont" style="text-align:right; border:0px;" size="14">
				      <font style="font-size:9px; font-weight:normal">(System generated)</font></td>
				  </tr>
					
					<tr>
					  <td height="25">&nbsp;</td>
					  <td colspan="2" style="font-size:14px;"><u><strong>Teller Cash/Check On Hand Information:</strong></u></td>
				  </tr>
					<tr>
					  <td height="25"></td>
					  <td style="font-size:14px;">Cash on hand:</td>
				      <td style="font-size:11px;">
				        <%if(vEditInfo != null)
							strTemp = CommonUtil.formatFloat(((Double)vEditInfo.elementAt(16)).doubleValue(), true);
						  else	
						  	strTemp = WI.fillTextValue("_cash_onhand_encoded");
						%>
						
						<input type="text" name="_cash_onhand_encoded" value="<%=strTemp%>" class="textbox_bigfont" style="text-align:right; " size="14"></td>
				   </tr>
					<tr>
					  <td height="25"></td>
					  <td style="font-size:14px;">Check on hand:</td>
				      <td style="font-size:11px;">
				        <%if(vEditInfo != null)
							strTemp = CommonUtil.formatFloat(((Double)vEditInfo.elementAt(17)).doubleValue(), true);
						  else	{
						  	strTemp = WI.fillTextValue("_check_onhand_encoded");
							//strTemp = CommonUtil.formatFloat(dCheck,true);
						  }
						%>
				        <input type="text" name="_check_onhand_encoded" value="<%=strTemp%>" class="textbox_bigfont" style="text-align:right;" size="14"></td>
				  </tr>
					<tr>
					  <td height="25">&nbsp;</td>
					  <td colspan="2" style="font-size:18px;"><u><strong>Bank Deposit Information:</strong></u></td>
				  </tr>
					<tr>
					  <td height="25"></td>
					  <td style="font-size:14px;"> Amount Deposited:  </td>
				      <td style="font-size:10px;">
				        <%if(vEditInfo != null)
							strTemp = CommonUtil.formatFloat(((Double)vEditInfo.elementAt(10)).doubleValue(), true);
						  else	
						  	strTemp = WI.fillTextValue("_bank_deposited");
						%>
				        <input type="text" name="_bank_deposited" value="<%=strTemp%>" class="textbox_bigfont" style="text-align:right;" size="14"></td>
				  </tr>
					<tr>
					  <td height="25"></td>
					  <td style="font-size:14px;">Date Deposited </td>
					  <td style="font-size:10px;">
				        <%if(vEditInfo != null)
							strTemp = (String)vEditInfo.elementAt(11);
						  else	
						  	strTemp = WI.fillTextValue("date_deposited");
						  if(strTemp.length() == 0) 
						  	strTemp = WI.getTodaysDate(1);
						%>
					  <input name="date_deposited" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox_bigfont" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      					<!--<a href="javascript:show_calendar('form_.date_deposited');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>-->					 </td>
				  </tr>
					<tr>
					  <td height="25"></td>
					  <td style="font-size:14px;">Remarks/Notes</td>
					  <td style="font-size:10px;">
				        <%if(vEditInfo != null)
							strTemp = (String)vEditInfo.elementAt(12);
						  else	
						  	strTemp = WI.fillTextValue("remarks");
						%>
					  <textarea name="remarks" cols="65" rows="1" class="textbox" style="font-size:11px;" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
				  </tr>
					<tr>
					  <td height="25"></td>
					  <td colspan="2" style="font-size:11px;">&nbsp;<!--
					  <strong><u>NOTE:</u></strong> <br>
					  Cash Short(-ve)/Over(+ve) = (Cash + Check Remitted) - (System generate Cash + Check Collected)<br>
					  Next Day Begining Balance = Begining Balance + (Cash + Check Remitted) - Amount deposited
					  -->				  </td>
				  </tr>
					<tr>
					  <td height="25"></td>
					  <td colspan="2" style="font-size:14px;" align="center">
						
<%
if(!bolIsLocked) {
	if(vEditInfo != null) {%>
						<!--
						<input type="submit" name="122" value="Edit Information" style="font-size:14px; height:30px;border: 1px solid #FF0000;" 
		  					onClick="document.form_.page_action.value='2';document.form_.info_index.value='<%=vEditInfo.elementAt(0)%>'">
							
						&nbsp;&nbsp;&nbsp; -->
						<input type="submit" name="122" value="Delete Information" style="font-size:14px; height:30px;border: 1px solid #FF0000; background:#99CCFF;" 
		  					onClick="document.form_.page_action.value='0';document.form_.info_index.value='<%=vEditInfo.elementAt(0)%>'">
							
	<%}else{%>
						<input type="submit" name="122" value="Save Information" style="font-size:14px; height:30px;border: 1px solid #FF0000;" 
		  					onClick="document.form_.page_action.value='1'">
	<%}
}//do not show edit/save option if Locked.. %>					  </td>
				  </tr>
				</table>			</td>
			<td width="40%" valign="top">
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<%if(dSD > 0d || dCC > 0d) {%>
						<tr>
						  <td style="font-size:14px;"><u><strong>Other Non-Depositable Collection</strong></u></td>
					  </tr>
						<%if(dSD > 0d) {%>
						<tr>
						  <td height="25" style="font-size:14px;">Accumulated: 
					        <input type="text" name="_sal_deduct" value="<%=CommonUtil.formatFloat(dSD,true)%>" readonly="yes" class="textbox_bigfont" style="text-align:right; border:0px;" size="14"></td>
					   </tr>
					   <%}if(dCC > 0d){%>
						<tr>
						  <td height="25" style="font-size:14px;">Credit Card Collection: <input type="text" name="_CC" value="<%=CommonUtil.formatFloat(dCC,true)%>" readonly="yes" class="textbox_bigfont" style="text-align:right; border:0px;" size="14"></td>
					  </tr>
					  <%}%>
				<%}%>
			  </table>
					
				<!-- this is for cash deposit details --> 	
				<br>
				<%if(vCDSummary != null && vCDSummary.size() > 0) {%>
					<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
						<tr>
						  <td colspan="4" style="font-size:11px;"><u><strong>Cash Deposit Detail</strong></u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						  <%if(!bolIsLocked) {%><a href="javascript:UpdateCDDetail('<%=strInfoIndex%>')">click here to update</a><%}%>					  </td>
					  </tr>
						<tr>
						  <td colspan="4" style="font-size:14px;">
							Total Recoded:  <%=vCDSummary.elementAt(1)%>
							To Encode: <%=vCDSummary.elementAt(2)%>						  </td>
					  </tr>
					</table>
					<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
						<tr align="center" style="font-weight:bold" bgcolor="#CCCCCC">
						  <td height="20" width="25%" class="thinborder">Bank Code </td>
						  <td width="25%" class="thinborder">Deposit Slip# </td>
						  <td width="25%" class="thinborder">Amount </td>
						  <td width="25%" class="thinborder">Deposit Type </td>
					   </tr>
					   <%for(int i = 0; i < vCDDetail.size(); i += 7) {%>
							<tr>
							  <td height="20" class="thinborder"><%=vCDDetail.elementAt(i + 1)%></td>
							  <td class="thinborder"><%=vCDDetail.elementAt(i + 3)%></td>
							  <td class="thinborder" align="right"><%=vCDDetail.elementAt(i + 4)%></td>
							  <td class="thinborder" align="center"><%=vCDDetail.elementAt(i + 6)%></td>
						  </tr>
					   <%}%>
					</table>	
				<%}//only if vCDSummary is not null%>
				
			</td>
		</tr>
<%if(bolShowPrint || bolIsLocked) {%>
		<tr>
		  <td valign="bottom">
				<font style="font-size:11px; font-weight:bold;">
					Note: <u>No Modification will be allowed after printing this report.</u></font>		  </td>
		  <td valign="bottom" align="right">
				<font style="font-size:11px;">
					<a href="javascript:PrintPage();"><img src="../../../../images/print.gif" border="0"></a> Print this report.</font>
		  </td>
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