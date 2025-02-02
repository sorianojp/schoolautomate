<%
String strStudID    = (String)request.getSession(false).getAttribute("userId");
if(strStudID == null) {
%>
 <p style="font-size:14px; color:#FF0000;">You are already logged out. Please login again.</p>
<%return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PAYER INFORMATION</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
<body>
<%@ page language="java" import="utility.*,java.util.Vector,onlinepayment.Registration" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
//add security here.
	try
	{
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
//authenticate this user.
	Vector vRetResult  	= null;
    Vector vUserInfo 	= null;
    Vector vPaymentInfo = null;
	
	boolean bolIsRegistered = true;
	
	String strSchCode = dbOP.getSchoolIndex();

	Registration registration = new Registration();
	vRetResult = registration.getPayerInfoSummary(dbOP, request);
	//vRetResult = null;
	if(vRetResult == null) {//forward page to registration.. 
		//dbOP.cleanUP();
		//response.sendRedirect("./register_new.jsp");
		//return;
		vRetResult = registration.autoCreateUserProfile(dbOP, request, true);
		if(vRetResult == null) {
			strErrMsg = "Failed to autocreate Profile. Please proceed to Accounting/Registrar’s Office for ONEPAY registration.";
			if(strSchCode.startsWith("FATIMA") || true)
				bolIsRegistered = false;
		}
		else {
			vRetResult = registration.getPayerInfoSummary(dbOP, request);
			if(vRetResult == null) {
				strErrMsg = "You are not officially registered to the ONEPAY system. Please proceed to Accounting/Registrar’s Office for registration - 02.";
				if(strSchCode.startsWith("FATIMA") || true)
					bolIsRegistered = false;
			}
			else {
				vUserInfo    = (Vector)vRetResult.remove(0);
				vPaymentInfo = (Vector)vRetResult.remove(0);
				if(vUserInfo.elementAt(7).equals("0")) {
					bolIsRegistered = false;
					strErrMsg = "Your status is IN-ACTIVE. Please contact school administrator.";
				}
			}
		}
	}
	else {
		vUserInfo    = (Vector)vRetResult.remove(0);
		vPaymentInfo = (Vector)vRetResult.remove(0);
		if(vUserInfo.elementAt(7).equals("0")) {
			bolIsRegistered = false;
			strErrMsg = "Your status is IN-ACTIVE. Please contact school administrator.";
		}
	}


String strOnlinePaymentHelpURL = "http://www.fatima.edu.ph/content.asp?pid=281&cat=8";
//change the URL per school request.

if(strErrMsg != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" style="font-size:18px;"><u>Error Message:</u><br><%=strErrMsg%></td>
    </tr>
  </table>
<%if(!bolIsRegistered) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">
	  <p style="font-weight:bold; font-size:14px;" align="center"><br><u>OVERVIEW & ADVANTAGES OF OLFU ONEPAY</u></p>
	  <p align="justify">
		OLFU ONEPAY (Online Enrollment Payment System) is an online  (internet based) payment system for officially enrolled  OLFU students and its alumni. 
		ONEPAY allows OLFU students, their  parents or guardians to pay for school  fees (tuition or matriculation fees, installment fees, payments etc.) 
		in the comfort of their own homes using any computer or notebook with internet access. All that is needed is a valid Bancnet member ATM card (with sufficient balance) 
		to cover the payment to be made. ONEPAY has been fully integrated to the SchoolAutomate Student Enrollment system OLFU students are familiar with .
		Once logged in to Schoolautotmate, students or parents/guardians can access the ONEPAY facility and use their Bancnet Member ATM card info and pincode to submit 
		their payments. Payment information is recorded in real time to the student’s ledger. 
	  </p>
	  <p align="justify">Students and parents/guardians no longer need endure long lines observed during traditional over the counter payments at OLFU nearby banks. 
	  Likewise the  need to fall in line at Campus Cahier’s Windows to pay installment or enrollment fees are eliminated. 
	  Payments can be made at ANYTIME of the day (24/7) with real time posting and confirmation of transactions made. 
	  Using l SchoolAutomate students and their parents or guardians can immediately view successful ONEPAY transactions, as payments made are immediately reflected in 
	  the student’s enrollment ledger.  The system is processed through  and backed up by industry stalwart BancNet  to ensure security of ONEPAY transactions  made. 
	  A service fee is deducted from the payee’s account for each successful payment transaction.
	  </p>
	  <p align="justify">Students that are registered to OLFU ONEPAY also has the ability to print their examination permits online. 
	  The need to fall in line during peak periods of exam permit distribution in the Registrar/Student Accounting offices. 
	  Students can print their exam permits at home or any other location with printer access using regular bond paper. 
	  Printed permits can then be immediately presented to proctors during major examinations.
	  </p>
	  <p>Students need to register to use the system only once.</p>
	  
	  </td>
    </tr>
  </table>
<%}
dbOP.cleanUP();

return;}%>
<jsp:include page="./inc.jsp?pgIndex=1" />

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="2" align="center" bgcolor="#BECED3" class="thinborder"><font size="1"><strong>REGISTERED PAYER INFORMATION </strong></font></td>
    </tr>
    <tr >
      <td width="14%" height="20" class="thinborder">Name: </td>
      <td width="86%" class="thinborder"><%=vUserInfo.elementAt(4)%></td>
    </tr>
    <tr >
      <td height="20" class="thinborder">Email ID: </td>
      <td class="thinborder"><%=vUserInfo.elementAt(0)%></td>
    </tr>
    <tr >
      <td height="20" class="thinborder">DOB: </td>
      <td class="thinborder"><%=vUserInfo.elementAt(1)%></td>
    </tr>
    <tr >
      <td height="20" class="thinborder">Telephone: </td>
      <td class="thinborder"><%=vUserInfo.elementAt(2)%></td>
    </tr>
    <tr >
      <td height="20" class="thinborder">Address: </td>
      <td class="thinborder"><%=vUserInfo.elementAt(3)%></td>
    </tr>
    <tr >
      <td height="20" class="thinborder">Payer Type: </td>
      <td class="thinborder"><%=vUserInfo.elementAt(8)%></td>
    </tr>
    <tr >
      <td height="20" class="thinborder">Create Date-Time: </td>
      <td class="thinborder"><%=vUserInfo.elementAt(6)%></td>
    </tr>
  </table>
	<br>
	
	<font style="font-weight:bold; font-size:14px;"><u>INSTRUCTION: </u></font><br>
	<p>- Click on Make Payment to submit matriculation fee payments using one pay. </p>
	<p>- Click on Payment History to review previous  ONEPAY transactions</p>
	<p>- Click on Print Permit AFTER completing payments</p> 
	
	<font style="font-weight:bold; font-size:14px;"><u>IMPORTANT REMINDERS: </u></font><br>
	<p>Please note that a service fee is deducted from the BANCNET account used for every successful payment transaction using ONEPAY. 
	Make sure that the BANCNET ATM accounts to be used have sufficient balance to cover payments to be made.
	</p>
	<!--
    <table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr> 
		<td width="34%" height="50">&nbsp;</td>
		<td width="32%">&nbsp;</td>
		<td width="34%">&nbsp;</td>
  	</tr>
	<tr>
	  <td height="50" valign="top"><a href="<%=strOnlinePaymentHelpURL%>" target="_blank"><img src="../../images/one_pay_help.jpg" border="0"></a></td>
	  <td>&nbsp;</td>
	  <td align="center" valign="top"><img src="../../images/one_pay_help_qr.jpg" border="0">
	  <br>
	  <div align="left">
	  <font size="1">
	  Scan the above QR image using your smartphone for detailed instructions on how to use SA1Pay. Download and install free QR code scanner applications  : for Android users – use google store to install QR Reader, QR Droid etc. For Apple Users you can install QR Reader for iPhone or Bakodo through ITUNES.( You must have an internet or data 
	  </font>
	  </div>
	  </td>
    </tr>
  </table>
	-->
	
	
</body>
</html>
<%
dbOP.cleanUP();
%>