<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>
</head>

<body >
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FADonation,java.util.Vector" buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strStudStatus = WI.fillTextValue("stud_status");


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-DONATION-receive donation","receive_donation.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","DONATION",request.getRemoteAddr(),
														"receive_donation.jsp");
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

Vector vStudInfo = null;
Vector vRetResult = null;
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FADonation faDonation = new FADonation();
vRetResult = faDonation.generateDonationReceipt(dbOP, WI.fillTextValue("or_number"));

if(vRetResult != null && vRetResult.size() > 0)//only if student id is entered.
{
	vStudInfo = paymentUtil.getStudBasicInfo(dbOP,(String)vRetResult.elementAt(8) );
	if(vStudInfo == null) 
		strErrMsg = paymentUtil.getErrMsg();
}
else 
	strErrMsg = faDonation.getErrMsg();


boolean bolShowReceiptHeading = false;
if(!bolShowReceiptHeading) { //forced to enter ;-)
	enrollment.ReadPropertyFileImpl readPropFileImpl = new enrollment.ReadPropertyFileImpl();
	int iRetValue = readPropFileImpl.showReceiptHeading();
	if(iRetValue == -1)
		strErrMsg = readPropFileImpl.getErrMsg();
	else if(iRetValue == 1)
		bolShowReceiptHeading = true;
}

if(vRetResult != null){
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
<%if(bolShowReceiptHeading){%>
    <tr>
      <td height="25" colspan="2" ><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=SchoolInformation.getInfo1(dbOP,false,false)%><br>
        <br>
        <br>
      </div></td>
    </tr>
<%}%>
    <tr >
      <td height="25" colspan="2" ><div align="center">OFFICIAL RECEIPT FOR DONATION</div></td>
    </tr>
    <tr >
      <td width="48%" height="20" >Date and time
        printed(yyyy-mm-dd) : <strong><%=WI.getTodaysDateTime()%></strong></td>
      <td width="52%" height="20" ><div align="right">Reference Number : <strong><%=request.getParameter("or_number")%> 
        &nbsp;&nbsp;</strong></div></td>
    </tr>
    <tr >
      <td height="20" >Student ID :<strong> <%=WI.getStrValue(vRetResult.elementAt(8))%></strong></td>
    <td height="20" >Course/Major : <strong><%=(String)vStudInfo.elementAt(2)%><%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%></strong></td>
    </tr>
    <tr >

    <td height="20" >Student name :<strong> <%=(String)vStudInfo.elementAt(1)%></strong></td>

    <td height="20" >Year : <strong><%=(String)vStudInfo.elementAt(4)%></strong></td>
    </tr>

    <tr >
      <td colspan="2" height="25" ><hr size="1"></td>
    </tr>
  </table>

  
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="2%">&nbsp;</td>
    <td width="17%">Amount Paid</td>
    <td width="81%"><strong>
		<%=CommonUtil.formatFloat((String)vRetResult.elementAt(1),true)%></strong></td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td>Date Paid</td>
    <td><strong><%=WI.getStrValue(vRetResult.elementAt(5))%></strong></td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td>Payment Type</td>
    <td><strong><%=WI.getStrValue(vRetResult.elementAt(6))%></strong></td>
  </tr>
  <%//System.out.println(vRetResult);
if(vRetResult.elementAt(7) != null){%>
  <tr> 
    <td>&nbsp;</td>
    <td>Check #</td>
    <td><strong><%=WI.getStrValue(vRetResult.elementAt(7))%></strong></td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td>Bank Name</td>
    <td><strong><%=WI.getStrValue(vRetResult.elementAt(9))%></strong></td>
  </tr>
  <%}%>
</table>
  
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="18">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td height="25"><div align="right">Payment received &amp; receipt printed 
        by :</div></td>
    <td width="41%">&nbsp;<u><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></u></td>
  </tr>
  <tr> 
    <td height="10" valign="bottom">&nbsp;</td>
    <td valign="top">&nbsp;&nbsp;&nbsp;&nbsp;<i>Business Office</i></td>
  </tr>
</table>
<%
if(WI.fillTextValue("print_page").compareTo("0") != 0){%>
  <script language="JavaScript">
	window.print();
</script>
<%}

}//if vRetResult not null
else{%>
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
 	<tr>
      <td align="center"><%=strErrMsg%></td>
    </tr>
  </table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
