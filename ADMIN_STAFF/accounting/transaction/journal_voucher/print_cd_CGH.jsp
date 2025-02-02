<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
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
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Transaction","journal_voucher_entry.jsp");
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
<%
if(strErrMsg != null) {
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td style="font-size:14px; color:#0000FF; font-weight:bold">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<%
	dbOP.cleanUP();
	return;
}
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="67%" height="25">
	  <div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        Accounting Office</div>

	  </td>
      <td width="33%" valign="top">
	  CD Number : <%=WI.fillTextValue("jv_number")%><br>
	  CD Date : <%=vJVInfo.elementAt(1)%><br>
	  Check # : <label id="check_info" onClick="ChangeLabelInfo('check_info')"><%=WI.getStrValue(strCheckNo,"&nbsp;&nbsp;&nbsp;&nbsp;")%></label><br>
	  Bank : <label id="bank_info_" onClick="ChangeLabelInfo('bank_info_')"><%=WI.getStrValue(strBankCode,"&nbsp;&nbsp;&nbsp;&nbsp;")%></label>
	  </td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" valign="bottom" style="font-size:16px; font-weight:bold" align="center"> DISBURSEMENT VOUCHER </td>
	</tr>
    <tr>
      <td height="9"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td>
      <td height="25" colspan="3" style="font-size:12px; font-weight:bold">Pay to: <u><%=vJVInfo.elementAt(5)%></u></td>
    </tr>
    <tr>
      <td style="font-size:13px; font-weight:bold">&nbsp;&nbsp;</td>
      <td height="25" colspan="3" style="font-size:12px; font-weight:bold">
	  	Amount :
		 <%=new ConversionTable().convertAmoutToFigure(Double.parseDouble((String)vJVInfo.elementAt(6)),"Pesos","Centavos")%>
		(<%=CommonUtil.formatFloat((String)vJVInfo.elementAt(6), true)%>)</td>
      </tr>
	<tr>
      <td style="font-size:13px; font-weight:bold" width="3%">&nbsp;</td>
      <td height="20" style="font-size:13px; font-weight:bold" width="67%"><u>DEBIT</u></td>
      <td style="font-size:13px; font-weight:bold" width="15%">&nbsp;</td>
      <td style="font-size:12px;" width="15%" align="right">Amount&nbsp;&nbsp;</td>
    </tr>
<%boolean bolPrintGroup = false;
String strBGRed = null;
for(int i =0; i < vGroupInfo.size(); i += 4){
	if(vGroupInfo.elementAt(i + 3).equals("0") && vJVInfo.elementAt(3).equals("0"))//coloring is for jv only , for cd - none.
		strBGRed = " bgcolor=red";
	else
		strBGRed = "";
	strTemp = (String)vGroupInfo.elementAt(i);//group number;
	bolPrintGroup = true;%>
	<%for(int p = 0; p < vJVDetail.size(); p += 5) {
		if(!vJVDetail.elementAt(p + 3).equals(strTemp) )
			continue;
		if(vJVDetail.elementAt(p + 4).equals("0"))//if not debit or if not belong to same group.. continue.
			continue;
		++iTotalLinePrinted;%>
    <tr<%=strBGRed%>>
      <td style="font-size:12px;" valign="top"><%if(bolPrintGroup){bolPrintGroup = false;%><%=strTemp%>.
      <%}%></td>
      <td height="18" style="font-size:12px;" valign="top"><%=vJVDetail.elementAt(p + 1)%></td>
      <td style="font-size:12px;" valign="top"><%=vJVDetail.elementAt(p + 0)%></td>
      <td style="font-size:12px;" align="right" valign="top"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(p + 2), true)%>&nbsp;</td>
    </tr>
	<%vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	p -= 5;}//end of while loop.
}//end of for loop to print all debit.%>
    <tr>
      <td height="10" colspan="4" style="font-size:12px;"><hr size="1"></td>
    </tr>
    <tr>
      <td style="font-size:13px; font-weight:bold">&nbsp;</td>
      <td height="20" style="font-size:13px; font-weight:bold"><u>CREDIT</u></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<%
for(int i =0; i < vGroupInfo.size(); i += 4){
	if(vGroupInfo.elementAt(i + 3).equals("0") && vJVInfo.elementAt(3).equals("0") )//coloring is for jv only , for cd - none.
		strBGRed = " bgcolor=red";
	else
		strBGRed = "";
	strTemp = (String)vGroupInfo.elementAt(i);//group number;
	bolPrintGroup = true;%>
	<%while(vJVDetail.size() > 0) {
		if(!vJVDetail.elementAt(3).equals(strTemp))//if not belong to same group.. break.
			break;
		++iTotalLinePrinted;%>
    <tr<%=strBGRed%>>
      <td style="font-size:12px;" valign="top"><%if(bolPrintGroup){bolPrintGroup = false;%><%=strTemp%>.<%}%></td>
      <td height="18" style="font-size:12px;" valign="top"><%=vJVDetail.elementAt(1)%></td>
      <td style="font-size:12px;" valign="top"><%=vJVDetail.elementAt(0)%></td>
      <td style="font-size:12px;" align="right" valign="top"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true)%>&nbsp;</td>
    </tr>
	<%
	vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
	vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);}//end of while loop.
}//end of for loop to print all debit.%>

    <tr>
      <td height="10" colspan="4" style="font-size:12px;"><hr size="1"></td>
    </tr>
    <tr>
      <td height="10" colspan="4" style="font-size:12px;">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" colspan="4" style="font-size:13px; font-weight:bold"><u>EXPLANATION</u></td>
    </tr>
<%
for(int i =0; i < vGroupInfo.size(); i += 4){
++iTotalLinePrinted;%>
    <tr>
      <td style="font-size:12px;" valign="top"><%=vGroupInfo.elementAt(i)%>.</td>
      <td height="25" colspan="3" valign="top"><%=WI.getStrValue(vGroupInfo.elementAt(i + 1))%></td>
    </tr>
<%}%>
    <tr>
      <td height="10" colspan="4" style="font-size:12px;"><hr size="1"></td>
    </tr>
    <tr>
      <td height="10" colspan="4">
	  	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<%for(; iTotalLinePrinted <= iMaxLine; ++iTotalLinePrinted) {%>
			<tr>
				<td height="18" colspan="4">&nbsp;</td>
			</tr>
		<%}%>
			<tr>
			  <td height="15" valign="bottom" align="center" style="font-size:10px; font-weight:bold">Prepared By </td>
			  <td valign="bottom" align="center" style="font-size:10px; font-weight:bold">Checked By </td>
			  <td valign="bottom" align="center" style="font-size:10px; font-weight:bold">Approved By </td>
			  <td valign="bottom" style="font-size:10px; font-weight:bold">Payment Received By</td>
			</tr>
			<tr>
				<td width="25%" height="25" align="center" style="font-size:11px;"><u><%=(String)request.getSession(false).getAttribute("first_name")%></u></td>
				<td width="24%">&nbsp;</td>
			  <td width="27%" valign="bottom" style="font-size:11px;" align="center"><u>Executive Director</u></td>
				<td width="24%" valign="bottom" style="font-size:10px;"><u>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				</u></td>
			</tr>
			<tr>
			  <td height="25" align="center" style="font-size:10px;">&nbsp;</td>
			  <td>&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;" align="center">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">Signature Over Printed Name<br>
			  Date: <u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</u>
			  </td>
		  </tr>
		</table>	  </td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
