<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<style type="text/css">
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.thinborderLEFT {thinborderTOPDoubleLine
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.thinborderTOPBOTTOMDoubleLine {
    border-top: solid 1px #000000;
    border-bottom: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
</style>

</style>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
function PrintPg() {
	if(document.getElementById('myADTable1')) {
		document.getElementById('myADTable1').deleteRow(0);
		document.getElementById('myADTable1').deleteRow(0);
	
		document.getElementById('myADTable2').deleteRow(0);
		document.getElementById('myADTable2').deleteRow(0);
		document.getElementById('myADTable2').deleteRow(0);
	}
	alert("Click OK to print.");
	window.print();
}	
	
</script>
<%@ page language="java" import="utility.*,enrollment.CashDeposit,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","cash_deposit_teller_report.jsp");
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
															null);
	if(iAccessLevel == 0) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Fee Assessment & Payments","REPORTS-CASHIER REPORT",request.getRemoteAddr(),
															null);
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.

Vector vRetResult   = null;
Vector vTuition     = null;
Vector vNonTuition  = null;
Vector vCashDeposit = null;
Vector vCDSummary   = null;

String strDepositMainIndex = null;

String strSQLQuery = null;
java.sql.ResultSet  rs = null;

String strTellerID    = (String)request.getSession(false).getAttribute("userId");
String strTellerIndex = (String)request.getSession(false).getAttribute("userIndex");
String strTellerName  = (String)request.getSession(false).getAttribute("first_name");

if(WI.fillTextValue("col_date").length() > 0) {
	CashDeposit cdeposit = new CashDeposit();
	
	vRetResult = cdeposit.cashDepositTellerReport(dbOP, request);
	if(vRetResult == null) 
		strErrMsg = cdeposit.getErrMsg();
	else {
		vTuition     = (Vector)vRetResult.remove(0);
		vNonTuition  = (Vector)vRetResult.remove(0);
		vCashDeposit = (Vector)vRetResult.remove(0);
		if(vCashDeposit != null && vCashDeposit.size() > 0) {
			vCDSummary = (Vector)vCashDeposit.remove(0);
			strDepositMainIndex = (String)vRetResult.remove(vRetResult.size() - 1);
		}
	}
	//System.out.println(vRetResult);
}
if(request.getSession(false).getAttribute("teller_i") != null) {
	strTellerIndex = (String)request.getSession(false).getAttribute("teller_i");
	
	request.getSession(false).setAttribute("teller_i", null);
	
	strSQLQuery = "select id_number, fname, mname, lname from user_table where user_index = "+strTellerIndex;
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		strTellerID = rs.getString(1);
		strTellerName = WI.formatName(rs.getString(2),rs.getString(3),rs.getString(4),4);
	}
	rs.close();
}
//printed.. so updated to is locked = 1
if(strDepositMainIndex != null)
	dbOP.executeUpdateWithTrans("update CASH_DEPOSIT_MAIN set is_completed = 1 where deposit_main_index= "+strDepositMainIndex, null, null, false);
//System.out.println(dBeginBal);
double dDebitCreditAmt = 0d;
Vector vDebitCreditNote = new Vector();
if(strDepositMainIndex != null) {
	strSQLQuery = "select note, BEGIN_BAL from CASH_DEPOSIT_BEGIN_BAL where is_valid = 1 and DEPOSIT_MAIN_INDEX =0 and teller_index = "+strTellerIndex+" and bal_date ='"+
			 ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("col_date"))+"'";
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		dDebitCreditAmt += rs.getDouble(2);
		vDebitCreditNote.addElement(rs.getString(1));
		vDebitCreditNote.addElement(CommonUtil.formatFloat(rs.getDouble(2), true));
	}
	rs.close();
}



%>
<body <%if(WI.fillTextValue("print_").length() > 0) {%> onLoad="PrintPg();"<%}%>>
<form name="form_" action="./cash_deposit_teller_report.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
		<tr>
			<td height="18" colspan="3" align="center"><strong>:::: CASH DEPOSIT TELLER REPORT ::::</strong></td>
		</tr>
		<tr>
			<td width="2%" height="18">&nbsp;</td>
			<td width="98%" colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
		<tr>
			<td width="2%" height="25">&nbsp;</td>
			<td width="16%" style="font-size:14px;">Teller ID: </td>
		    <td width="82%" style="; font-size:14px;">
			<%=strTellerName%> (<%=strTellerID%>)
		  </td>
		</tr>
		
		<tr>
		  <td height="25">&nbsp;</td>
		  <td style="font-size:14px;">Collection Date:</td>
		  <td>
<%
strTemp = WI.fillTextValue("col_date");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
		<input name="col_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      		<a href="javascript:show_calendar('form_.col_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>	  		  
			</td>
	  </tr>
		
		<tr>
		  <td height="60">&nbsp;</td>
		  <td style="font-size:11px;">&nbsp;</td>
		  <td style="font-size:11px;">
		  <input type="button" name="_" value="Generate Report" onClick="document.form_.submit();">
		  <%if(vRetResult != null) {%>
			<div align="right">
			  <a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a> Print Report
		  	</div>
		  <%}%>
		  </td>
	  </tr>
	</table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td colspan="3" align="center" style="" class="thinborderBOTTOM">
				<%=SchoolInformation.getSchoolName(dbOP,true,false)%>
				<br>
				TREASURY OFFICE
				<br>
				DAILY CASHIER'S SUMMARY WITH CASH DEPOSIT DETAILS			</td>
		</tr>
		<tr>
			<td width="34%">Run Date: <%=WI.getTodaysDateTime()%></td>
		    <td align="center" width="33%">Collection Date: <%=WI.fillTextValue("col_date")%></td>
		    <td align="right" width="33%">Teller: <%=strTellerID%>
			(<%=strTellerName%>)
			</td>
		</tr>
	</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td width="79%" height="25">Beginning Balance</td>
					<td width="21%" align="right"><%=vCashDeposit.elementAt(0)%></td>
				</tr>
		</table>
	<%if(vTuition != null && vTuition.size() > 0) {%>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td colspan="2" style=""><u>ACCOUNTS RECEIVABLE STUDENTS</u></td>
			</tr>
			
			<%
			for(int i =0; i < vTuition.size(); i += 2) {%>
				<tr>
					<td width="79%" height="12"><%=vTuition.elementAt(i)%></td>
					<td width="21%" align="right"><%=vTuition.elementAt(i + 1)%></td>
				</tr>
			<%}%> 
				<tr>
				    <td align="right" style="">&nbsp;</td>
					<td align="right" class="thinborderTOP" style="font-size:10px;">SubTotal: <%=vRetResult.elementAt(1)%></td>
				</tr>
		</table>
 	<%}%>
	<%if(vNonTuition != null && vNonTuition.size() > 0) {%>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td colspan="2" style=""><u>OTHER INCOME/OTHERS</u></td>
			</tr>
			
			<%for(int i =0; i < vNonTuition.size(); i += 2) {%>
				<tr>
					<td width="79%" height="12"><%=vNonTuition.elementAt(i)%></td>
					<td width="21%" align="right"><%=vNonTuition.elementAt(i + 1)%></td>
				</tr>
			<%}%> 
				<tr>
				    <td align="right" style="">&nbsp;</td>
					<td colspan="2" align="right" class="thinborderTOP" style="font-size:10px;">SubTotal: <%=vRetResult.elementAt(2)%></td>
				</tr>
		</table>
 	<%}
	
	double dTemp = Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(0), ",","")) + 
					Double.parseDouble(ConversionTable.replaceString((String)vCashDeposit.elementAt(0), ",",""));
	%>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td style="" height="20">Total Collection:</td>
					<td width="21%" align="right"><%=(String)vRetResult.elementAt(0)%></td>
				</tr>
				<tr>
					<td style="" height="20">Total Collection of Day( Begining Balance + Collection):</td>
					<td width="21%" align="right" class="thinborderTOP" style="font-size:10px;"><%=CommonUtil.formatFloat(dTemp, true)%></td>
				</tr>
		</table>
	<!--<DIV style="page-break-after:always" >&nbsp;</DIV>	-->
	<%if(vCashDeposit != null && vCashDeposit.size() > 0) {%>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td colspan="4" style=""><u>DEPOSIT DETAILS</u></td>
			</tr>
			<tr>
				<td width="34%" height="18">BANK</td>
			    <td width="16%" align="right">&nbsp;</td>
			    <td width="29%" align="right">DEPOSIT AMOUNT </td>
			    <td width="21%" align="right">&nbsp;</td>
			</tr>
				<!--
				<tr style="">
				  <td height="18">Begining Balance </td>
				  <td align="right">&nbsp;</td>
				  <td align="right">&nbsp;</td>
				  <td align="right"><%=vCashDeposit.elementAt(0)%></td>
				</tr>
				-->
				
			<%
			String[] astrConvertCashChk = {"Cash","Check"};
			boolean bolUnderLine = false;
			
			for(int i =5; i < vCashDeposit.size(); i += 4) {
				if(vCashDeposit.size() <= i + 4 || !vCDSummary.elementAt(0).equals(vCashDeposit.elementAt(i + 4)) )
					bolUnderLine = true;
				else	
					bolUnderLine = false;
			%>
				<tr>
				  <td height="12"><%=vCashDeposit.elementAt(i)%> - <%=astrConvertCashChk[Integer.parseInt((String)vCashDeposit.elementAt(i + 3))]%></td>
				  <td align="right">&nbsp;</td>
				  <td align="right"><%if(bolUnderLine){%><u><%}%><%=vCashDeposit.elementAt(i + 1)%><%if(bolUnderLine){%></u><%}%></td>
				  <td align="right" style="">
				  <%if(bolUnderLine) {%>
				  	<%=CommonUtil.formatFloat(((Double)vCDSummary.remove(1)).doubleValue(), true)%>
				  <%vCDSummary.remove(0);}%>				  </td>
				</tr>
			<%}%> 
				<tr style="">
				  <td height="12">Total Deposit </td>
				  <td align="right">&nbsp;</td>
				  <td align="right">&nbsp;</td>
				  <td align="right" class="thinborderTOP" style="font-size:10px;"><%=CommonUtil.formatFloat(Double.parseDouble(ConversionTable.replaceString((String)vCashDeposit.elementAt(1), ",","")) + Double.parseDouble(ConversionTable.replaceString((String)vCashDeposit.elementAt(2), ",","")), true)%></td>
		  </tr>
				<tr style="">
				  <td height="12">Ending Cash Balance</td>
				  <td align="right">&nbsp;</td>
				  <td align="right">&nbsp;</td>
				  <td align="right" class="" style="font-size:10px;"><%=(String)vCashDeposit.elementAt(3)%></td>
		  </tr>
				<tr style="">
				  <td height="12">Undeposited Collection </td>
				  <td align="right">&nbsp;</td>
				  <td align="right">&nbsp;</td>
				  <td align="right" class="" style="font-size:10px;"><%=CommonUtil.formatFloat(Double.parseDouble(ConversionTable.replaceString((String)vCashDeposit.elementAt(3), ",","")) + Double.parseDouble(ConversionTable.replaceString((String)vCashDeposit.elementAt(4), ",","")), true)%></td>
				<tr style="">
				  <td height="12">Cash 
				  <%
				  strTemp = (String)vCashDeposit.elementAt(4);
				  
				  dDebitCreditAmt += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
				  strTemp = CommonUtil.formatFloat(dDebitCreditAmt, true);
				  
				  if(strTemp.startsWith("-")){strTemp = strTemp.substring(1);%>
				  Short 
				  <%}else{strTemp = "("+strTemp+")";%> Over <%}%>				  </td>
				  <td align="right">&nbsp;</td>
				  <td align="right">&nbsp;</td>
				  <td align="right" class="thinborderTOPBOTTOMDoubleLine"><%=strTemp%></td>
				</tr>
				
				<tr>
				  <td height="12">&nbsp;</td>
				  <td colspan="3">&nbsp;</td>
		  </tr>
				<tr>
				  <td height="12">Official Receipts Used </td>
				  <td colspan="3">
				  <%if(vRetResult.elementAt(3) != null) {%>
					  <%=vRetResult.elementAt(3)%> - <%=vRetResult.elementAt(4)%>
				  <%}%>
				  </td>
			    </tr>
				<%if(vRetResult.elementAt(5) != null) {%>
					<tr>
					  <td height="12">Cancelled OR </td>
					  <td colspan="3"><%=vRetResult.elementAt(5)%></td>
					</tr>
				<%}%>
					<tr>
					  <td height="12" style="font-size:11px;">&nbsp;</td>
					  <td colspan="3">&nbsp;</td>
					</tr>

				<%if(vDebitCreditNote != null && vDebitCreditNote.size() > 0) {%>
					<tr>
					  <td height="12" style="font-size:11px;"><u>ADJUSTMENT DETAIL</u></td>
					  <td colspan="3">&nbsp;</td>
					</tr>
					<%for(int i = 0; i < vDebitCreditNote.size(); i += 2) {%>
						<tr>
						  <td height="12" colspan="3"><%=vDebitCreditNote.elementAt(i)%></td>
						  <td align="right"><%=vDebitCreditNote.elementAt(i + 1)%></td>
					    </tr>
					<%}%>
					<tr>
					  <td height="12">&nbsp;</td>
					  <td colspan="3">&nbsp;</td>
					</tr>
				<%}%>
				<tr>
				  <td height="12">For Accounting Office Use: </td>
				  <td colspan="3">&nbsp;</td>
			    </tr>
				<tr style="">
				  <td height="12">Total Cash Deposit </td>
				  <td align="right">&nbsp;</td>
				  <td align="right">&nbsp;</td>
				  <td align="right"><%=vCashDeposit.elementAt(1)%></td>
		  </tr>
				<tr style="">
				  <td height="12">Total Check Deposit </td>
				  <td align="right">&nbsp;</td>
				  <td align="right">&nbsp;</td>
				  <td align="right"><%=vCashDeposit.elementAt(2)%></td>
		  </tr>
				<tr>
				  <td height="18">&nbsp;</td>
				  <td colspan="3">&nbsp;</td>
			    </tr>
				<tr>
					<td colspan="4">
						<table width="100%" cellpadding="0" cellspacing="0">
							<tr>
							  <td height="18" width="20%">Prepared by:_________ </td>
							  <td width="30%">Collection verified By:_________ </td>
							  <td width="30%">Deposits checked by:_________ </td>
							  <td width="20%">Reviewed By:_________ </td>
							</tr>
						</table>					</td>
				</tr>
		</table>
 	<%}%>
		
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>