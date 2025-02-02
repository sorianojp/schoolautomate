<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null)
		strSchoolCode = "";
	
	if(strSchoolCode.startsWith("CGH") && WI.fillTextValue("or_number").length() > 0){
		response.sendRedirect(response.encodeRedirectURL("../payment/one_receipt_CGH.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	else if(strSchoolCode.startsWith("FATIMA") && WI.fillTextValue("or_number").length() > 0){
		response.sendRedirect(response.encodeRedirectURL("../payment/one_receipt_FATIMA.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	else if(strSchoolCode.startsWith("WUP") && WI.fillTextValue("or_number").length() > 0){
		response.sendRedirect(response.encodeRedirectURL("../payment/one_receipt_WUP.jsp?or_number="+request.getParameter("or_number")));
		return;
	}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
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
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPage() { 
	document.getElementById('myADTable1').deleteRow(0);
	//location = "./remittance_print.jsp?or_number="+escape('<%=request.getParameter("or_number")%>');
	var printNow = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(printNow)
        window.print();

}
function getORNumber() {
	if(document.form_.or_number.value.length == 0) {
		var strORNumber = prompt('Please enter OR Number.','');
		if(strORNumber.length > 0) 
			location = "./remittance_print.jsp?or_number="+escape(strORNumber);		
	}
}
</script>
<body <%if(WI.fillTextValue("or_number").length() == 0){%>onLoad="getORNumber()"<%}%>>
<form name="form_">
<%@ page language="java" import="utility.*,enrollment.FARemittance,java.util.Vector " %>
<%
	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REMITTANCE-Remittance","remittance_print.jsp");
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
//end of security code.
boolean bolShowReceiptHeading = false;
if(!bolShowReceiptHeading) { //forced to enter ;-)
	enrollment.ReadPropertyFileImpl readPropFileImpl = new enrollment.ReadPropertyFileImpl();
	int iRetValue = readPropFileImpl.showReceiptHeading();
	if(iRetValue == -1)
		strErrMsg = readPropFileImpl.getErrMsg();
	else if(iRetValue == 1)
		bolShowReceiptHeading = true;
}
if(strSchoolCode.startsWith("DBTC"))
	bolShowReceiptHeading = false;

String strPrintStatus =WI.fillTextValue("print_status");
if(strPrintStatus.length() == 0)	
	strPrintStatus = "1"; //by default print the page.
FARemittance faRemit = new FARemittance(dbOP);
Vector vRetResult = faRemit.getPaymentDetail( dbOP,request.getParameter("or_number"),(String)request.getSession(false).getAttribute("login_log_index"));
if(vRetResult == null)
	strErrMsg = faRemit.getErrMsg();


//dbOP.cleanUP();
if(strErrMsg != null)
{dbOP.cleanUP();%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
 	<td align="center"><b><%=strErrMsg%></b></td>
	</tr>
</table>
<input type="hidden" name="or_number">
<%return;}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  
  <%if(bolShowReceiptHeading){%>
    <tr>
      <td height="25" colspan="2" ><div align="center"><font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font> </font><br>
        <%=SchoolInformation.getInfo1(dbOP,false,false)%></div></td>
    </tr>
<%} // end show receipt heading
 if(strSchoolCode.startsWith("LNU"))
 	strTemp = "right";
 else 
 	strTemp = "center";
%>
    <tr >
      <td height="25" colspan="2" ><div align="<%=strTemp%>"><strong>REMITTANCE
          OFFICIAL RECEIPT</strong></div></td>
    </tr>
    <tr >
      
    <td width="48%" height="20" >Teller ID:<strong> <%=(String)vRetResult.elementAt(6)%></strong></td>
      <td width="52%" height="20" ><div align="right">&nbsp;O.R.
          Number : <strong><%=request.getParameter("or_number")%></strong></div></td>
    </tr>
    <tr >

    <td height="20" >&nbsp;</td>
      <td height="20" ><div align="right">&nbsp;Date/
          Time Printed : <strong><%=WI.getTodaysDateTime()%></strong></div></td>
    </tr>
    <tr >
      <td  colspan="2" height="19" ><hr size="1"></td>
    </tr>
  </table>
  
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="5%" height="20">&nbsp;</td>
    <td width="19%">Remittance Type</td>
    <td width="45%"><strong><%=WI.getStrValue((String)vRetResult.elementAt(9))%></strong></td>
    <td width="13%">Date/Remittted</td>
    <td width="18%"><strong><%=(String)vRetResult.elementAt(4)%></strong></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td>Account Name </td>
    <td colspan="3"><strong><%=(String)vRetResult.elementAt(0)%></strong></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td>Amount Remitted</td>
    <td colspan="3"><strong><%=CommonUtil.formatFloat((String)vRetResult.elementAt(1),true)%></strong></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td>Remitted by</td>
    <td colspan="3"><strong><%=WI.getStrValue(vRetResult.elementAt(2))%></strong></td>
  </tr>
  <%//System.out.println(vRetResult);
if(vRetResult.elementAt(7) != null){%>
  <tr> 
    <td height="20">&nbsp;</td>
    <td>Bank Name (Branch)</td>
    <td colspan="3"><strong><%=WI.getStrValue(vRetResult.elementAt(10))%></strong></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td>Check Number</td>
    <td colspan="3"><strong><%=WI.getStrValue(vRetResult.elementAt(7))%></strong></td>
  </tr>
  <%}if(vRetResult.elementAt(8) != null){%>
  <tr> 
    <td height="20">&nbsp;</td>
    <td>Description</td>
    <td colspan="3"><strong><%=WI.getStrValue(vRetResult.elementAt(8))%></strong></td>
  </tr>
  <%}%>
</table>

  <table  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="28">&nbsp;</td>

    <td valign="bottom">Printed by : <strong><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="24" valign="bottom">&nbsp;</td>

    <td height="24" valign="bottom">__________________________________________</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="48%" height="25"><div align="left"></div></td>
      <td width="52%" height="25">Teller</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<table id="myADTable1">
	<tr>
		<td><a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
Click to print receipt</td>
		<td></td>
	</tr>
</table>
<input type="hidden" name="or_number">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
