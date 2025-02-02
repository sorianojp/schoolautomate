<%
String strMethodType = request.getMethod();
if(!strMethodType.toLowerCase().equals("post")) {%>
	<p style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold">
		Wrong Call. Please consult support.</p>
<%return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<%@ page language="java" import="utility.*,Accounting.IncomeStatement, java.util.Vector" %>
<%
	WebInterface WI  = new WebInterface(request);
	DBOperation dbOP = null;

	String strTemp   = null;
	String strErrMsg = null;

//add security here.
	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
IncomeStatement IS = new IncomeStatement();
Vector vRetResult = IS.getIncomeStatementMonthlyYearly(dbOP, request);
if(vRetResult == null)
	strErrMsg = IS.getErrMsg();
//System.out.println(vRetResult);

String strReportType  = WI.fillTextValue("report_format");
String strMonth       = WI.fillTextValue("month_");
String strYear        = WI.fillTextValue("year_");
String strPrevYr      = WI.fillTextValue("prev_yr");
boolean bolShowPrevYr = false;
String strReportName  = null;

if(strPrevYr.length() > 0)
	bolShowPrevYr = true;

String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","September","October","November","December"};
if(strReportType.equals("0")) {//monthly.
	strReportName = astrConvertMonth[Integer.parseInt(strMonth)] + ", "+strYear;
}
else if(strReportType.equals("2")) {//Date Range..
	strReportName = "For Date Range: "+WI.fillTextValue("date_fr")+" - "+WI.fillTextValue("date_to");
}
else {
	if(WI.fillTextValue("fiscal_yr").length() > 0)
		strReportName = "Fiscal Year "+strYear;
	else
		strReportName = "Year "+strYear;
	if(IS.getErrMsg() != null && vRetResult != null)
		strReportName = strReportName + " : "+IS.getErrMsg();
}
boolean bolIsDebitAccount = false;
Vector vDebitCreditInfo   = new Vector();

String strSQLQuery = "select is_main_index, is_debit_type from AC_SET_IS_MAIN join ac_coa_cf on (coa_cf_ref = coa_cf) where is_valid = 1 ";
java.sql.ResultSet rs  = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	vDebitCreditInfo.addElement(new Integer(rs.getInt(1)));
	vDebitCreditInfo.addElement("1");
}
rs.close();


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
/**
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null) {
	if(dbOP.vResultSetOfAQuery != null && dbOP.vResultSetOfAQuery != null) {
		for(int i = 0; i < dbOP.vResultSetOfAQuery.size(); i += 2) {
			vDebitCreditInfo.addElement(new Integer(String.valueOf(dbOP.vResultSetOfAQuery.elementAt(i))));
			vDebitCreditInfo.addElement(String.valueOf(dbOP.vResultSetOfAQuery.elementAt(i + 1)));
		}	
	
	}
}**/

%>
<body>
<%if(vRetResult == null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" style="font-size:14px; color:#FF0000; font-weight:bold"><%=strErrMsg%></td>
    </tr>
  </table>
<%
dbOP.cleanUP();
return;}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" align="center">
      	<font size="2">
      	<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>      </td>
    </tr>
    <tr>
      <td height="25"><div align="center"><strong><u>Income Statement For (<%=strReportName%>) </u></strong></div></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
    </tr>
  </table>
<%
dbOP.cleanUP();
%>
  <table width="100%" border="0" bgcolor="#FFFFFF">
<%if(bolShowPrevYr){%>
    <tr style="font-weight:bold">
      <td>&nbsp;</td>
      <td colspan="2" align="center">&nbsp;</td>
      <td align="center"><u><%=strPrevYr%></u></td>
      <td align="center"><u><%=strYear%></u></td>
    </tr>
<%}

Vector vSubGroup = null;
String strGroupTitle = null;
boolean bolIsInLine  = false;

String strTotalCur  = (String)vRetResult.remove(0);
String strTotalPrev = (String)vRetResult.remove(0);

int iIndexOf = 0;
for(int i = 0; i < vRetResult.size(); i += 9) {
vSubGroup = (Vector)vRetResult.elementAt(i + 8);
bolIsInLine = vRetResult.elementAt(i + 3).equals("1");
//System.out.println(bolIsInLine);

//check if the account type is debit or credit, if Credit type, must display +ve.. 
iIndexOf = vDebitCreditInfo.indexOf(vRetResult.elementAt(i));
//System.out.println("x iIndexOf : "+iIndexOf);
if(iIndexOf > -1) {//System.out.println(vDebitCreditInfo.elementAt(iIndexOf + 1));

	if(vDebitCreditInfo.elementAt(iIndexOf + 1).equals("1"))
		bolIsDebitAccount = true;
	else
		bolIsDebitAccount = false;
}
else	
	bolIsDebitAccount = false;
//System.out.println("Print : "+bolIsDebitAccount);
//System.out.println("Print 2: "+vRetResult.elementAt(i));
%>
    <tr style="font-weight:bold">
      <td width="3%">&nbsp;</td>
      <td colspan="2"><%=vRetResult.elementAt(i + 1)%></td>
      <td width="19%" align="right"><%if(bolIsInLine && bolShowPrevYr){%><%=vRetResult.elementAt(i + 7)%><%}%></td>
      <td width="20%" align="right"><%if(bolIsInLine){%><%=vRetResult.elementAt(i + 6)%><%}%></td>
    </tr>
<%if(vSubGroup != null)
	for(int a = 0; a < vSubGroup.size(); a += 3){
	
	strTemp  = WI.getStrValue((String)vSubGroup.elementAt(a + 2));
	strErrMsg = WI.getStrValue((String)vSubGroup.elementAt(a + 1));

	if(!bolIsDebitAccount) {
		if(strTemp.startsWith("-"))
			strTemp = strTemp.substring(1);
		else if(strTemp.length() > 0)
			strTemp = "-"+strTemp;
			
		if(strErrMsg.startsWith("-"))
			strErrMsg = strErrMsg.substring(1);
		else if(strErrMsg.length() > 0)
			strErrMsg = "-"+strErrMsg;
			
	}
	%>
    <tr>
      <td>&nbsp;</td>
      <td width="5%">&nbsp;</td>
      <td width="53%"><%=vSubGroup.elementAt(a)%></td>
      <td align="right"><%if(bolShowPrevYr){%><%=CommonUtil.formatFloatToLedger(strTemp)%><%}%></td>
      <td align="right"><%=CommonUtil.formatFloatToLedger(strErrMsg)%></td>
    </tr>
<%}if(!bolIsInLine){
strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 7));
strErrMsg = WI.getStrValue((String)vRetResult.elementAt(i + 6));
//System.out.println("Print 1.. "+strErrMsg+ " " +vRetResult.elementAt(i));
if(!bolIsDebitAccount) {
		if(strTemp.startsWith("-"))
			strTemp = strTemp.substring(1);
		else if(strTemp.length() > 0)
			strTemp = "-"+strTemp;
			
		if(strErrMsg.startsWith("-"))
			strErrMsg = strErrMsg.substring(1);
		else if(strErrMsg.length() > 0)
			strErrMsg = "-"+strErrMsg;
		
}%>
    <tr style="font-weight:bold">
      <td>&nbsp;</td>
      <td colspan="2"><%=vRetResult.elementAt(i + 4)%></td>
      <td align="right"><%if(bolShowPrevYr){%><%=strTemp%><%}%></td>
      <td align="right"><%=strErrMsg%></td>
    </tr>
<%}%>
    <tr>
      <td>&nbsp;</td>
      <td colspan="4">&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
<%
	///it is a credit type, because this is income statement..
/**	
		if(strTotalPrev.startsWith("-"))
			strTotalPrev = strTotalPrev.substring(1);
		else
			strTotalPrev = "-"+strTotalPrev;
			
		if(strTotalCur.startsWith("-"))
			strTotalCur = strTotalCur.substring(1);
		else
			strTotalCur = "-"+strErrMsg;
**/		
%>
    <tr style="font-weight:bold">
      <td>&nbsp;</td>
      <td colspan="2"><%if(strSchCode.startsWith("CDD")) {%>NET EXCESS OF REVENUES OVER EXPENSES<%}else{%>Net Income/Loss<%}%></td>
      <td align="right"><%if(bolShowPrevYr){%><%=strTotalPrev%><%}%></td>
      <td align="right"><%=strTotalCur%></td>
    </tr>
  </table>

<!----------------
<form>
/****************this is example only. *****************/


  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" align="center"><font color="#000000" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>$SCHOOL_NAME</strong></font></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#FFFFFF" align="center">MONTHLY INCOME STATEMENT </td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td width="4%" height="25" bgcolor="#FFFFFF">YEAR-TO-DATE : <strong>$enddate_of_the_selected_month</strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><strong>$group_A_title</strong></td>
      <td height="25"><strong>$total_style1_prev</strong></td>
      <td width="17%"><strong>$total_style1_cur</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$sub_groupname_1</td>
      <td width="17%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$sub_group_items</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$sub_group_items</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td width="66%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$sub_group_items</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$sub_groupname_2</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$sub_groupname_2</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><strong>$TOTAL_NAME_IF_TOTAL_IS_SET_TO_BELOW </strong></td>
      <td height="25"><strong>$total_style2_prev</strong></td>
      <td height="25"><strong>$total_style2_prev</strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><strong>$group_B_title</strong></td>
      <td height="25"><strong>$total_style1_prev</strong></td>
      <td height="25"><strong>$total_style1_cur</strong>&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$sub_groupname_1</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$sub_group_items</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$sub_group_items</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$sub_groupname_2</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><strong>$TOTAL_NAME_IF_TOTAL_IS_SET_TO_BELOW </strong></td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><strong>$group_C_title</strong></td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><strong>$group_D_title</strong></td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><strong>$NET_INCOME_NAME_FOR_LAST_EQUAL</strong></td>
      <td height="25"><strong>$net_income_prev</strong></td>
      <td height="25"><strong>$net_income_current</strong></td>
    </tr>
  </table>
</form>
-->

</body>
</html>
