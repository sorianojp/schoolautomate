<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript">
function ChangeLabelInfo(labelID) {
	var newVal = prompt('Please enter new value.','');
	if(newVal == null || newVal.length == 0) 
		return;
	document.getElementById(labelID).innerHTML = newVal;
}
</script>
<%@ page language="java" import="utility.*,Accounting.JvCD,java.util.Vector" %>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//authenticate this user.
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
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

//end of authenticaion code.


//add security here.
	try {
		dbOP = new DBOperation();
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

String strJVNumber = WI.fillTextValue("jv_number");/////I must get when i save / edit.
JvCD jvCD = new JvCD();

boolean bolIsCD = false;
int iVoucherType = 0;//0 = jv, 1 = cd, 2 = petty cash.

Vector vJVDetail  = null; //to show detail at bottom of page. 
Vector vJVInfo    = null;
Vector vGroupInfo = null;

if(strJVNumber.length() > 0) {
	vJVDetail = jvCD.viewDetailJV(dbOP, strJVNumber);
	if(vJVDetail == null)
		strErrMsg = jvCD.getErrMsg();
	else {
	    vJVInfo    = (Vector)vJVDetail.remove(0);//[0]=JV_INDEX,[1]=JV_DATE, [2] = jv_type, [3] = is_cd,[4] lock_date, [5] = payee name.
	    vGroupInfo = (Vector)vJVDetail.remove(0);//[0]=group number, [1]=Explanation, [2]=remarks.
    	vJVDetail  = (Vector)vJVDetail.remove(0);//[0]=coa_number,[1]=PARTICULAR,[2]=AMOUNT,[3]=GROUP_NUMBER,[4]=is_debit
	
		iVoucherType = Integer.parseInt((String)vJVInfo.elementAt(3));
		
	}
}
else 
	strErrMsg = "JV Number not found.";

int iTotalLinePrinted = 0; int iMaxLine = 10;
String strCheckNo = null;
String strBankCode = null;
if(vJVInfo != null && vJVInfo.size() > 0) {
	strTemp = "select BANK_CODE,CHECK_NO from AC_CD_CHECK_DTL join AC_COA_BANKCODE on (AC_COA_BANKCODE.bank_index = AC_CD_CHECK_DTL.bank_index) where cd_index = "+
			vJVInfo.elementAt(0);
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	if(rs.next()) {
		strBankCode = rs.getString(1);
		strCheckNo  = rs.getString(2);
	}		
	rs.close();
}	
%>

<body onLoad="window.print()" topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">
<form name="form_">
<table height="80" cellpadding="0" cellspacing="0" width="100%">
	<tr valign="top">
	  <td width="13%" align="center" style="font-size:24px; font-weight:bold">&nbsp;</td>
		<td width="64%" align="center" style="font-size:24px; font-weight:bold"><!--
		WEST NEGROS UNIVERSITY<BR><font style="font-weight:normal; font-size:9px">Bacolod City</font>
		<br>
		<font style="font-size:18px">CHECK VOUCHER</font>		-->&nbsp;</td>	
	  <td width="23%" valign="bottom">
	  	<table width="100%">
			<tr>
				<td style="font-weight:bold; font-size:14px;"><!--CV No : 92178-->&nbsp;
				<br><br>
				<!--Check No :--> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<label id="check_info" onClick="ChangeLabelInfo('check_info')"><%=WI.getStrValue(strCheckNo,"&nbsp;&nbsp;&nbsp;&nbsp;")%></label>				</td>
			</tr>
		</table>	  </td>
	</tr>
</table>

<table height="25" cellpadding="0" cellspacing="0" width="100%">
	<tr valign="bottom">
	  <td width="77%"><!--TO : -->&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=vJVInfo.elementAt(5)%></td>	
	  <td width="23%"><!--Date : --> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=vJVInfo.elementAt(1)%></td>
	</tr>
</table>
<br><br><br><br><br>
<table height="250" cellpadding="0" cellspacing="0" width="100%">
	<tr valign="top">
		<td width="39%" valign="top">
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
				  <td width="38%" height="25"><%--<u>Account Number</u>--%>&nbsp;</td>	
				  <td width="28%"><%--<u>Debit</u>--%>&nbsp;</td>
				  <td width="34%"><%--<u>Credit</u>--%>&nbsp;</td>
				</tr>
				<%	String strDebit  = null;
					String strCredit = null;
					for(int p = 0; p < vJVDetail.size(); p += 5) {
						if(vJVDetail.elementAt(p + 4).equals("0")) {//if not debit or if not belong to same group.. continue. - this is credit.. 
							strDebit = null;
							strCredit = CommonUtil.formatFloat((String)vJVDetail.elementAt(p + 2), true);
						}
						else {
							strCredit = null;
							strDebit  = CommonUtil.formatFloat((String)vJVDetail.elementAt(p + 2), true);
						}%>
						<tr valign="top">
						  <td><%=vJVDetail.elementAt(p + 0)%></td>
						  <td align="right"><%=WI.getStrValue(strDebit, "&nbsp;")%></td>
						  <td align="right"><%=WI.getStrValue(strCredit, "&nbsp;")%></td>
						</tr>
				<%}%>
			</table>
	  </td>
		<td width="61%" valign="top">
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
				  <td width="78%" height="26">&nbsp;<%=WI.getStrValue(vGroupInfo.elementAt(1))%></td>	
				  <td width="22%" align="right"><%=CommonUtil.formatFloat((String)vJVInfo.elementAt(6), true)%></td>
			    </tr>
				<tr>
				  <td height="26">&nbsp;</td>
				  <td align="right">&nbsp;</td>
			  </tr>
				<tr>
				  <td height="26">&nbsp;</td>
				  <td align="right">&nbsp;</td>
			  </tr>
				<tr>
				  <td height="26">&nbsp;</td>
				  <td align="right">&nbsp;</td>
			  </tr>
				<tr>
				  <td height="26">&nbsp;</td>
				  <td align="right">&nbsp;</td>
			  </tr>
				<tr>
				  <td height="26">&nbsp;</td>
				  <td align="right">&nbsp;</td>
			  </tr>
				<tr>
				  <td height="26">&nbsp;</td>
				  <td align="right">&nbsp;</td>
			  </tr>
				<tr>
				  <td height="26">&nbsp;</td>
				  <td align="right">&nbsp;</td>
			  </tr>
				<tr>
				  <td height="26" align="right"><%--Total--%></td>
				  <td align="right"><%=CommonUtil.formatFloat((String)vJVInfo.elementAt(6), true)%></td>
			  </tr>
			</table>

	  </td>
	</tr>
</table>


<table width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%--Received the sum ______________________________________________________________ Pesos--%>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
		<%=new ConversionTable().convertAmoutToFigure(Double.parseDouble((String)vJVInfo.elementAt(6)),"Pesos","Centavos")%><br>
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=CommonUtil.formatFloat((String)vJVInfo.elementAt(6), true)%> <!--as a payment for the above account--></td>
	</tr>
</table>
<table width="100%" cellpadding="0" cellspacing="0">
	<tr>
	  <td width="50%"><%--Bank Account : __________ --%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <label id="bank_info_" onClick="ChangeLabelInfo('bank_info_')"><%=WI.getStrValue(strBankCode,"&nbsp;&nbsp;&nbsp;&nbsp;")%></label></td>
	  <td width="50%">&nbsp;</td>
	</tr>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
	<tr>
	  <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <%--Prepared By : ___________ --%>
	  <%=(String)request.getSession(false).getAttribute("first_name")%>	  </td>
	  <td><%--Payee--%> </td>
  </tr>
</table>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>