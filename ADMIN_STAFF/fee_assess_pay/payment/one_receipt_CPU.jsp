<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>One Receipt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
-->
</style>
</head>

<%@ page language="java" import="utility.*,enrollment.FAPayment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	boolean bolIsFine = false;
	boolean bolIsDownPmt =false;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Other school fees","otherschoolfees_print_receipt.jsp");
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
boolean bolShowLabel = false;//for actual, set it to false;
boolean bolIsGradeShoolPmt = false;

String strStudID     = null;
String strStudName   = null;
String strCourse     = null;
String strStudStatus = null;
String strAmount     = null;
String strBankName   = null;
String strCheckNo    = null;
String strDatePaid   = null;

String strPaymentFor = null;
String strPmtMode    = null;
Vector vPaymentList = null;

boolean bolIsDownPayment = false;// if it is true, must call RF to be printed. 


FAPayment faPayment = new FAPayment();
Vector vRetResult = faPayment.viewPmtDetail(dbOP, request.getParameter("or_number"));//System.out.println(vRetResult);
if(vRetResult == null) {
	//may be basic payment.
	vRetResult = new enrollment.FAElementaryPayment().viewPmtDetail(dbOP, request.getParameter("or_number"));//System.out.println(vRetResult);
	if(vRetResult != null) {
		bolIsGradeShoolPmt = true;
		strStudID     = (String)vRetResult.elementAt(4);
		strStudName   = WebInterface.formatName((String)vRetResult.elementAt(6),(String)vRetResult.elementAt(7),
						(String)vRetResult.elementAt(8),4);
		String[] astrConvertToEduLevel = {"Preparatory","Elementary","High School"};
		strCourse     = astrConvertToEduLevel[Integer.parseInt((String)vRetResult.elementAt(0))];
		strStudStatus = "";
		strPaymentFor = "Tuition and Miscellaneous Fees ";
		strAmount     = (String)vRetResult.elementAt(9);
		strPmtMode    = (String)vRetResult.elementAt(12);
		strBankName   = (String)vRetResult.elementAt(14);
		strCheckNo    = (String)vRetResult.elementAt(10);
		strDatePaid   = (String)vRetResult.elementAt(11);
	}
	else
		strErrMsg = faPayment.getErrMsg();

}
else {//not basic payment.
		if(vRetResult.elementAt(27).equals("0"))
			bolIsDownPayment = true;
		
		strStudID     = WI.getStrValue((String)vRetResult.elementAt(25),"External Pmt");
		//name
		if( vRetResult.elementAt(0) != null)
			strStudName     = (String)vRetResult.elementAt(18);
		else
			strStudName     = (String)vRetResult.elementAt(1);

		strCourse     = WI.getStrValue((String)vRetResult.elementAt(35),"");
		//student status.
		if( ((String)vRetResult.elementAt(29)).compareTo("0") == 0)
			strStudStatus = "Old Student";
		else
			strStudStatus = "New Student";

		strAmount     = (String)vRetResult.elementAt(11);
		if(vRetResult.elementAt(33) != null)
			strPaymentFor = (String)vRetResult.elementAt(33);
		else if( ((String)vRetResult.elementAt(4)).compareTo("0") == 0)
			strPaymentFor = "Tuition and Miscellaneous Fee";
		else {
			//if there is additional
			if(vRetResult.elementAt(42) != null)
				strPaymentFor = (String)vRetResult.elementAt(42);
			else if(vRetResult.elementAt(4).equals("10"))
				strPaymentFor = "Back Account";
			else
				strPaymentFor = (String)vRetResult.elementAt(5);
		}
//System.out.println(vRetResult);

		strPmtMode    = (String)vRetResult.elementAt(10);
		strBankName   = (String)vRetResult.elementAt(34);
		strCheckNo    = (String)vRetResult.elementAt(14);
		strDatePaid   = WI.getStrValue(vRetResult.elementAt(15));
}

	if (vRetResult != null && vRetResult.size() > 0 && 
		WI.fillTextValue("fund_type").length() > 0){
			
		vPaymentList = (Vector)vRetResult.elementAt(43);
		
		//System.out.println("vPaymentList : " + vPaymentList);
	} 


if(strErrMsg != null){dbOP.cleanUP();%>
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
 	<tr>
      <td align="center"><%=strErrMsg%></td>
    </tr>
</table>
<%return;}%>
<body topmargin="0" bottommargin="0" onLoad="PrintReceipt();document.form_.test_.focus();">
<form name="form_" onSubmit="PrintRF();return false;">
<table border=0 cellspacing=0 cellpadding=0 width=100%>
  <tr>
    <td>&nbsp;</td>
    <td width="442" align="center">
	<input type="text" name="test_" class="textbox_noborder" size="1">
	<input type="image" src="../../../images/blank.gif">
	<input type="hidden" name="or_number" value="<%=request.getParameter("or_number")%>">
	</td>
    <td colspan="2">&nbsp;
	  <%if (WI.fillTextValue("fund_type").length() == 0) {%>
	  <font size="3">R </font>
	  <%}else if (WI.fillTextValue("fund_type").equals("0")){%> 
	  <font size="3">G </font>
	  <%}else if (WI.fillTextValue("fund_type").equals("2")){%> 
	  <font size="3">FS </font>
	  <%}else if (WI.fillTextValue("fund_type").equals("1")){%> 
	  <font size="3">E </font>
	  <%}%>	</td>
  </tr>
  <tr>
    <td height="53">&nbsp;</td>
    <td align="center"><%if (WI.fillTextValue("fund_type").length() == 0) {%>
      <font size="2">AR Students</font>  
      <%}else if (WI.fillTextValue("fund_type").equals("0")){%>
      <font size="2">General Accounts </font>
      <%}else if (WI.fillTextValue("fund_type").equals("2")){%>
      <font size="2">Faculty / Staff </font>
      <%}else if (WI.fillTextValue("fund_type").equals("1")){%>
      <font size="2">Endowment Fund </font> 
      <%}%></td>
    <td width="133">&nbsp;</td>
    <td width="73">&nbsp;</td>
 </tr>
 <tr>
    <td width="116" >&nbsp;</td>
    <td><%=strStudName%>
	<% if (vRetResult != null && vRetResult.size() > 0) {%> 
	<%= WI.getStrValue((String)vRetResult.elementAt(25),"(", ")","")%> 
	<%}%>	</td>
    <td >&nbsp;</td>
    <td >&nbsp;</td>
 </tr>
 <tr>
   <td >&nbsp;</td>
   <td valign=middle>&nbsp;</td>
   <td>&nbsp;</td>
   <td>&nbsp;</td>
 </tr>
 
<% if (vPaymentList == null || vPaymentList.size() == 0) {%> 
 <tr>
    <td >&nbsp;</td>
    <td valign=middle><%=strPaymentFor%></td>
    <td><div align="right"><%=CommonUtil.formatFloat(strAmount,true)%></div></td>
    <td>&nbsp;</td>
 </tr>
<%}else{
	for (int i=0; i < vPaymentList.size(); i+=3) {
%>
 <tr>
    <td >&nbsp;</td>
    <td valign=middle><%=(String)vPaymentList.elementAt(i)%>&nbsp;&nbsp;
						<%=(String)vPaymentList.elementAt(i+1)%></td>
    <td><div align="right"><%=CommonUtil.formatFloat((String)vPaymentList.elementAt(i+2),true)%></div></td>
    <td>&nbsp;</td>
 </tr>
<%} // end for loop %>
 <tr>
    <td >&nbsp;</td>
    <td valign=middle><div align="right">TOTAL :: </div></td>
    <td><div align="right"><%=CommonUtil.formatFloat(strAmount,true)%></div></td>
    <td>&nbsp;</td>
 </tr>

<%
 }  // 
%>

 <tr>
   <td>&nbsp;</td>
   <td valign=middle>&nbsp;</td>
   <td>&nbsp;</td>
   <td>&nbsp;</td>
 </tr>
 <tr>
   <td>&nbsp;</td>
   <td valign=middle>[<%=(String)request.getSession(false).getAttribute("userId")%>] &nbsp;&nbsp;[<%=WI.getTodaysDate(1)%>]</td>
   <td>&nbsp;</td>
   <td>&nbsp;</td>
 </tr>
</table>

<script language="javascript">
function PrintReceipt() {
	<%if(!strAmount.equals("0.0")){%>
		window.print();
	<%}%>
}
function PrintRF() {
	<%if(!bolIsDownPayment){%>
		return;
	<%}%>
	var pgLoc = "./enrollment_receipt_print_cpu.jsp?or_number=<%=request.getParameter("or_number")%>";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
