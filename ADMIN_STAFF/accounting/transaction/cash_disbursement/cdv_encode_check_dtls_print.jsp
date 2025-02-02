<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		//cancell is called.
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
		
		document.form_.check_no.value = "";
		document.form_.amount.value = "";
	}
}
function PreparedToEdit(strInfoIndex) {
//	alert("I am here.");
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
}
function AddCOA(strCOACF) {
	location = "./chart_of_account.jsp?coa_cf="+strCOACF;
}
function ConfirmDel(strInfoIndex) {
	if(confirm("Do you want to delete."))
		return this.PageAction('0',strInfoIndex);
}
function PrintChk(strChkIndex) {
	var pgLoc = "./print_check.jsp?chk_index="+strChkIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=500,scrollbars=yes,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body onLoad="window.print();">
<%@ page language="java" import="utility.*,Accounting.JvCD,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Transaction","cdv_encode_check_dtls.jsp");
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
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
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

String strJVNumber = WI.fillTextValue("cd_index");/////I must get when i save / edit.
JvCD jvCD = new JvCD();

Vector vJVDetail  = null; //to show detail at bottom of page. 
Vector vJVInfo    = null;
Vector vGroupInfo = null;

Vector vRetResult = null;//all regarding check detail. 
Vector vEditInfo  = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");

if(WI.fillTextValue("page_action").length() > 0) {
	if(jvCD.operateOnCDCheck(dbOP, request, Integer.parseInt(WI.fillTextValue("page_action"))) == null) 
		strErrMsg = jvCD.getErrMsg();
	else {
		strErrMsg = "Operation successful.";
		strPreparedToEdit = "0";
	} 	
}
double dTotalCheckMade = 0d;
double dTotalBal       = 0d;
if(strPreparedToEdit.equals("1")) {	
	vEditInfo = jvCD.operateOnCDCheck(dbOP, request, 3);
	if(vEditInfo != null) {
		vEditInfo.removeElementAt(0);vEditInfo.removeElementAt(0);
	}
}
if(strJVNumber.length() > 0) {
	vRetResult = jvCD.operateOnCDCheck(dbOP, request, 4);
	
	if(vRetResult != null) {
		dTotalBal       = Double.parseDouble((String)vRetResult.remove(0));
		dTotalCheckMade = Double.parseDouble((String)vRetResult.remove(0));
	}
}





if(strJVNumber.length() > 0) {
	vJVDetail = jvCD.viewDetailJV(dbOP, strJVNumber);
	if(vJVDetail == null)
		strErrMsg = jvCD.getErrMsg();
	else {
	    vJVInfo    = (Vector)vJVDetail.remove(0);//[0]=JV_INDEX,[1]=JV_DATE, [2] = jv_type, [3] = is_cd,[4] lock_date, [5] = payee name, [6] = total debit.. 
	    vGroupInfo = (Vector)vJVDetail.remove(0);//[0]=group number, [1]=Explanation, [2]=remarks.
    	vJVDetail  = (Vector)vJVDetail.remove(0);//[0]=coa_number,[1]=PARTICULAR,[2]=AMOUNT,[3]=GROUP_NUMBER,[4]=is_debit
		
		if(vJVInfo.elementAt(3).equals("0")) {
			strErrMsg = "Please enter Cash disbursement voucher number.";
			vJVInfo = null;
		}
	}
}
else 
	strErrMsg = "Please enter voucher number.";

//for CD, i should get error if balance is not zero.. 
if(vJVInfo != null && !vJVInfo.elementAt(7).equals("0.0")){
	strErrMsg = "Balance is not matching. Please check credit/debit amount. Both amount must match.";
	vRetResult = null;
}

if(strErrMsg != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:11px; font-weight:bold; color:#FF0000">
	  	<a href="cash_disbursement.jsp"></a>
			&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%>
	  </td>
    </tr>
  </table>
<%}

if(vJVDetail != null && vJVDetail.size() > 0 && vRetResult != null) {
String strCheckNo   = null; String strBankIndex = null;

//I must findout if there are two columns to be made.. 
double dAmount1 = 0d;
double dAmount2 = 0d;

boolean bolPB = false; String strSQLQuery = null; java.sql.ResultSet rs = null;

strCheckNo = (String)vRetResult.elementAt(3);
if(strCheckNo.startsWith("*"))
	bolPB = true;
	
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26" colspan="4" align="right" style="font-size:9px;">Date and Time Printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="13%">Voucher No.</td>
      <td width="29%"><%=WI.fillTextValue("cd_index")%></td>
      <td width="54%">Total Voucher Amount : <%=CommonUtil.formatFloat(dTotalCheckMade + dTotalBal, true)%></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#999999"> 
      <td height="26" style="font-size:11px; font-weight:bold; color:#0000FF" align="center" class="thinborderTOPLEFTRIGHT">::: LIST OF CHECK ISSUED	::: 	</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="12%">Account # </td> 
      <td height="26" class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="8%">Bank Code </td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="10%">Check # </td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="30%">Payee Name </td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="10%">Date</td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="7%">Check Status </td>
<%if(bolPB){%>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="8%">Amount1</td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="5%">Amount2</td>
<%}%>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="8%">Total</td>
    </tr>
<%String[] astrConvertCheckStat = {"O/S","Cleared","Bounced"};
int iChkStat = 0;
strSQLQuery = "select jv_number,amount from ac_jv join AC_CD_CHECK_DTL on (cd_index = jv_index) where ";

for(int i = 0; i < vRetResult.size(); i += 12){
iChkStat = Integer.parseInt((String)vRetResult.elementAt(i + 7));

strCheckNo   = (String)vRetResult.elementAt(i + 3);
strBankIndex = (String)vRetResult.elementAt(i + 1);
if(strCheckNo.startsWith("*")) {
	rs = dbOP.executeQuery(strSQLQuery +" chk_index <> "+(String)vRetResult.elementAt(i)+" and check_no='"+strCheckNo+"' and bank_index="+strBankIndex);
	while(rs.next())
		dAmount2 += rs.getDouble(2);
	rs.close();
}
dAmount1 = Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 4),",",""));

%>
    <tr>
      <td class="thinborder"><%=vRetResult.elementAt(i + 8)%></td> 
      <td height="26" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=strCheckNo%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=astrConvertCheckStat[iChkStat]%></td>
<%if(bolPB){%>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dAmount1, true)%>&nbsp;</td>
      <td class="thinborder" align="right"><%if(dAmount2 > 0d){%><%=CommonUtil.formatFloat(dAmount2, true)%><%}%>&nbsp;</td>
<%}%>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dAmount1 + dAmount2, true)%>&nbsp;</td>
    </tr>
<%dAmount2 = 0d;
}%>
  </table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size:13px; font-weight:bold" width="3%">&nbsp;</td> 
      <td height="25" style="font-size:13px; font-weight:bold" width="67%"><u>DEBIT</u></td>
      <td style="font-size:13px; font-weight:bold" width="15%">&nbsp;</td>
      <td style="font-size:11px;" width="15%" align="right">Amount&nbsp;&nbsp;</td>
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
			continue;%>
    <tr<%=strBGRed%>>
      <td style="font-size:11px;" valign="top"><%if(bolPrintGroup){bolPrintGroup = false;%><%=strTemp%>. 
      <%}%></td>
      <td height="25" style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(p + 1)%></td>
      <td style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(p + 0)%></td>
      <td style="font-size:11px;" align="right" valign="top"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(p + 2), true)%>&nbsp;</td>
    </tr>
	<%vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	p -= 5;}//end of while loop. 
}//end of for loop to print all debit.%>
    <tr>
      <td height="10" colspan="4" style="font-size:11px;"><hr size="1"></td>
    </tr>
    <tr>
      <td style="font-size:13px; font-weight:bold">&nbsp;</td> 
      <td height="25" style="font-size:13px; font-weight:bold"><u>CREDIT</u></td>
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
			break;%>
    <tr<%=strBGRed%>>
      <td style="font-size:11px;" valign="top"><%if(bolPrintGroup){bolPrintGroup = false;%><%=strTemp%>.<%}%></td>
      <td height="25" style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(1)%></td>
      <td style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(0)%></td>
      <td style="font-size:11px;" align="right" valign="top"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true)%>&nbsp;</td>
    </tr>
	<%
	vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
	vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);}//end of while loop. 
}//end of for loop to print all debit.%>

    <tr>
      <td height="10" colspan="4" style="font-size:11px;"><hr size="1"></td>
    </tr>
    <tr>
      <td height="10" colspan="4" style="font-size:11px;">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" colspan="4" style="font-size:11px;">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" colspan="4" style="font-size:13px; font-weight:bold"><u>EXPLANATION</u></td>
    </tr>
<%
for(int i =0; i < vGroupInfo.size(); i += 4){%>
    <tr>
      <td style="font-size:11px;" valign="top"><%=vGroupInfo.elementAt(i)%>.</td>
      <td height="25" colspan="3" valign="top"><%=WI.getStrValue(vGroupInfo.elementAt(i + 1))%></td>
    </tr>
<%}%>
  </table>
<%}//if(vJVDetail != null && vJVDetail.size() > 0) {%>

</body>
</html>
<%
dbOP.cleanUP();
%>