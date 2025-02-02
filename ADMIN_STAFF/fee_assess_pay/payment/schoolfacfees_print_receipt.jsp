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

<body >
<%@ page language="java" import="utility.*,enrollment.FASchoolFacility,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	boolean bolIsFine = false;

	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null)
		strSchoolCode = "";
	String strInfo5 = WI.getStrValue((String)request.getSession(false).getAttribute("info5"));

	String strSukli = WI.fillTextValue("sukli");
	if(strSukli != null)
		strSukli = "&sukli="+strSukli;
	else
		strSukli = "";//System.out.println("Sukli : "+strSukli);

      String strORFormName = utility.CommonUtil.getORFileName(null, request);
      if(strORFormName != null) {
        strORFormName +="?or_number="+request.getParameter("or_number");
        response.sendRedirect(response.encodeRedirectURL(strORFormName));
        return;
      }

      /**
	if(strSchoolCode.startsWith("SPC")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_SPC.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("UB")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_UB.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("WUP")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_WUP.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("CDD")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_CDD.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("UPH")){
		if(strInfo5.length() > 0)
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_UPHS.jsp?or_number="+request.getParameter("or_number")));
		else
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_UPH1.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("VMA")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_VMA.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("UC")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_UC.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("EAC")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_EAC.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("FATIMA")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_FATIMA.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("CIT")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_CIT.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("UL")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_UL.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("DBTC")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_DBTC.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("PIT")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_PIT.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	if(strSchoolCode.startsWith("CSA")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_CSA.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	if(strSchoolCode.startsWith("AUF")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_AUF.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	else if(strSchoolCode.startsWith("WNU")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_WNU.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	else if(strSchoolCode.startsWith("CLDH")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_CLDH.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	else if(strSchoolCode.startsWith("CGH")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_CGH.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	else if(strSchoolCode.startsWith("UDMC")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_UDMC.jsp?or_number="+request.getParameter("or_number")));
		return;
	}**/
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-School faclities fees","school_facilities.jsp");
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

FASchoolFacility faSchFac = new FASchoolFacility();
Vector vUserInfo = null;
Vector vSchFacInfo = null;
Vector vPmtInfo = null;

Vector vRetResult = faSchFac.getPmtReciept(dbOP, request.getParameter("or_number"));
if(vRetResult == null) {
	strErrMsg = faSchFac.getErrMsg();
	//System.out.println("I am here.");
}
else
{
	vUserInfo 	= (Vector)vRetResult.elementAt(0);
	vSchFacInfo = (Vector)vRetResult.elementAt(1);
	vPmtInfo 	= (Vector)vRetResult.elementAt(2);
}
//System.out.println(vRetResult);
String strCurSYInfo[] = dbOP.getCurSchYr();
String strConvertSem[] = {"Summer","1st Sem","2nd Sem","3rd Sem"};

boolean bolShowReceiptHeading = false;
if(!bolShowReceiptHeading) { //forced to enter ;-)
	enrollment.ReadPropertyFileImpl readPropFileImpl = new enrollment.ReadPropertyFileImpl();
	int iRetValue = readPropFileImpl.showReceiptHeading();
	if(iRetValue == -1)
		strErrMsg = readPropFileImpl.getErrMsg();
	else if(iRetValue == 1)
		bolShowReceiptHeading = true;
}

if(strErrMsg == null){%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0">
<%if(bolShowReceiptHeading){%>
    <tr>
      <td height="25" colspan="2" ><div align="center">
        <p><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=SchoolInformation.getInfo1(dbOP,false,false)%><br>
        </p>
      </div></td>
    </tr>
<%}%>
    <tr >
      <td height="25" colspan="2" ><div align="center">PAYMENT FOR SCHOOL FACILITIES
        FEES<br>
        <%=strConvertSem[Integer.parseInt(strCurSYInfo[2])]%>, School Year <%=strCurSYInfo[0]%> - <%=strCurSYInfo[1]%><br>
      </div></td>
    </tr>
    <tr >

    <td width="48%" height="25" >Date and time printed : <strong><%=WI.getTodaysDateTime()%></strong></td>
      <td width="52%" height="25" ><div align="right">Reference
          Number : <strong><%=request.getParameter("or_number")%> &nbsp;&nbsp;</strong></div></td>
    </tr>
	</table>

 <table width="100%" border="0" cellpadding="0" cellspacing="0">
 <%
 //only if user is student.
 if( vUserInfo != null && ((String)vUserInfo.elementAt(0)).compareTo("1") ==0)
 {%>
    <tr >

    <td width="46%" height="20" >Student ID :<strong><%=(String)vUserInfo.elementAt(1)%></strong></td>
    <td width="54%" height="20" >Course/Major : <strong><%=(String)vUserInfo.elementAt(3)%>
      <%
	  if(vUserInfo.elementAt(4)!= null){%>
	  / <%=(String)vUserInfo.elementAt(4)%>
	  <%}%>
	  </strong></td>
    </tr>
    <tr >

    <td height="20" >Student name :<strong> <%=(String)vUserInfo.elementAt(2)%></strong></td>

    <td height="20" >Year : <strong><%=(String)vUserInfo.elementAt(7)%></strong></td>
    </tr>
<%}else if( vUserInfo != null && ((String)vUserInfo.elementAt(0)).compareTo("2") ==0) //teacher
 {%>
  <tr >
    <td width="46%" height="20" >Employee ID :<strong> <%=(String)vUserInfo.elementAt(1)%></strong></td>
    <td width="54%" height="20" >Employee type : <strong><%=(String)vUserInfo.elementAt(3)%></strong></td>
  </tr>
  <tr >
    <td height="20" >Employee name :<strong> <%=(String)vUserInfo.elementAt(2)%></strong></td>
    <td height="20" >College/Department/Office : <strong>
	<%if(vUserInfo.elementAt(4) != null){%>
	<%=(String)vUserInfo.elementAt(4)%>
	<%}if(vUserInfo.elementAt(5) != null){%> -
	<%=(String)vUserInfo.elementAt(5)%>
	<%}%>
	</strong></td>
  </tr>
<%}else if(vUserInfo != null){%>
  <tr >
    <td width="46%" height="20" colspan="2">Payee Name:<strong> <%=WI.getStrValue(vUserInfo.elementAt(1))%></strong></td>
  </tr>
  <tr >
    <td height="20" colspan="2">Address :<strong> <%=WI.getStrValue(vUserInfo.elementAt(2))%></strong></td>
  </tr>
<%}%>
  <tr >
    <td height="25" colspan="2"><hr size="1"></td>
  </tr>
</table>


<%
if( ((String)vSchFacInfo.elementAt(0)).compareTo("0") ==0) //single fee charge
{%>
<table  width="100%" border="0" cellspacing="0" cellpadding="0">

  <tr >
    <td height="25"  colspan="2" ><div align="center">:: FEE DETAILS ::</div></td>
    <td height="25"  colspan="2" ><div align="center">:: PAYMENT DETAILS ::</div></td>
  </tr>
  <tr >
    <td width="16%" height="20" >School Fee name</td>
    <td width="30%" height="20" ><strong><%=(String)vSchFacInfo.elementAt(1)%> </strong></td>
    <td width="21%" height="20" >Amount Paid </td>
    <td width="33%" height="20" ><%=(String)vPmtInfo.elementAt(4)%></td>
  </tr>
  <tr >
    <td height="20" >School Fee type</td>
    <td height="20" ><strong>Single Fee Charge</strong></td>
    <td height="20" >Payment Status</td>
    <td height="20" ><%=(String)vPmtInfo.elementAt(7)%></td>
  </tr>
  <tr >
    <td height="20" >Fee rate / unit</td>
    <td height="20" ><strong><%=(String)vSchFacInfo.elementAt(2)%> / <%=(String)vSchFacInfo.elementAt(4)%></strong></td>
    <td height="20" >Approval No.</td>
    <td height="20" >
	<%if(vPmtInfo.elementAt(2) == null){%>
	N/A
	<%}else{%>
	<%=(String)vPmtInfo.elementAt(2)%>
	<%}%>
	</td>
  </tr>
  <tr >
    <td height="20" ><%
	if(WI.fillTextValue("no_of_unit").length() > 0){%>
	Usage
	<%}%>
	</td>
    <td height="20" ><strong><%
	if(WI.fillTextValue("no_of_unit").length() > 0){%>
	<%=request.getParameter("no_of_unit")%>
	<%}%></strong></td>
    <td height="20" >Payment Type</td>
    <td height="20" ><%=(String)vPmtInfo.elementAt(3)%></td>
  </tr>
  <tr >
    <td height="20" >
      <%
	if(WI.fillTextValue("cal_amount").length() > 0){%>
      Amount Payable
      <%}%>
    </td>
    <td height="20" ><strong>
      <%
	if(WI.fillTextValue("cal_amount").length() > 0){%>
      <%=request.getParameter("cal_amount")%>
      <%}%>
      </strong></td>
    <td height="20" >Payment Receive Type</td>
    <td height="20" ><%=(String)vPmtInfo.elementAt(0)%></td>
  </tr>
<%
if(vPmtInfo.elementAt(1) != null){%>
  <tr >
    <td height="20" >&nbsp;</td>
    <td height="20" >&nbsp;</td>
    <td height="20" >Bank Name</td>
    <td height="20" >
      <%=(String)vPmtInfo.elementAt(1)%>
    </td>
  </tr>
<%}
if(vPmtInfo.elementAt(5) != null){%>
  <tr >
    <td height="20" >&nbsp;</td>
    <td height="20" >&nbsp;</td>
    <td height="20" >Check #</td>
    <td height="20" ><%=(String)vPmtInfo.elementAt(5)%>
    </td>
  </tr>
<%}%>
</table>
<%
}else if( ((String)vSchFacInfo.elementAt(0)).compareTo("1") ==0)//multiple fee charge.
{%>

<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr >
    <td height="15"  colspan="3" ><div align="center">:: FEE DETAILS ::</div></td>
    <td height="15"  colspan="2" ><div align="center">:: PAYMENT DETAILS ::</div></td>
  </tr>
  <tr >
    <td height="20" colspan="2" >School Fee name</td>
    <td width="28%" height="20" ><strong><%=(String)vSchFacInfo.elementAt(1)%></strong></td>
    <td width="21%" height="20" >Amount Paid </td>
    <td width="33%" height="20" ><%=(String)vPmtInfo.elementAt(4)%></td>
  </tr>
  <tr >
    <td height="20" colspan="2" >School Fee type</td>
    <td height="20" ><strong>Multiple Fee Charge</strong></td>
    <td height="20" >Payment Status</td>
    <td height="20" ><%=(String)vPmtInfo.elementAt(7)%></td>
  </tr>
  <tr >
    <td height="20" colspan="2" >Charges</td>
    <td height="20" >&nbsp;</td>
    <td height="20" >Approval No.</td>
    <td height="20" >
      <%if(vPmtInfo.elementAt(2) == null){%>
      N/A
      <%}else{%>
      <%=(String)vPmtInfo.elementAt(2)%>
      <%}%>
    </td>
  </tr>
  <tr >
    <td width="2%" height="20" >&nbsp;</td>
    <td width="16%" height="20" >$charges1</td>
    <td height="20" >$amount1</td>
    <td height="20" >Payment Type</td>
    <td height="20" ><%=(String)vPmtInfo.elementAt(3)%></td>
  </tr>
  <tr >
    <td height="20" >&nbsp;</td>
    <td height="20" >$charges2</td>
    <td height="20" >$amount2</td>
    <td height="20" >Payment Receive Type</td>
    <td height="20" ><%=(String)vPmtInfo.elementAt(0)%></td>
  </tr>
  <tr >
    <td height="20" >&nbsp;</td>
    <td height="20" >$chargesn</td>
    <td height="20" >$amountn</td>
    <td height="20" >Bank Name</td>
    <td height="20" >
      <%if(vPmtInfo.elementAt(1) == null){%>
      N/A
      <%}else{%>
      <%=(String)vPmtInfo.elementAt(1)%>
      <%}%>
    </td>
  </tr>
  <tr >
    <td height="20" colspan="2" >Total Amount Payable </td>
    <td height="20" ><strong>$amt_payable</strong></td>
    <td height="20" >Check #</td>
    <td height="20" >
      <%if(vPmtInfo.elementAt(5) == null){%>
      N/A
      <%}else{%>
      <%=(String)vPmtInfo.elementAt(5)%>
      <%}%>
    </td>
  </tr>
  <tr >
    <td height="20" colspan="2" >Payable for month/year</td>
    <td height="20" ><strong>$month/year</strong></td>
    <td height="20" >&nbsp;</td>
    <td height="20" >&nbsp;</td>
  </tr>
</table>
<%
}else if( ((String)vSchFacInfo.elementAt(0)).compareTo("2") ==0)//Deposit slip.
{%>
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr >
    <td height="15"  colspan="3" ><div align="center">:: FEE DETAILS ::</div></td>
    <td height="15"  colspan="2" ><div align="center">:: PAYMENT DETAILS ::</div></td>
  </tr>
  <tr >
    <td height="20" colspan="2" >Fee name</td>
    <td width="28%" height="20" ><strong><%=(String)vSchFacInfo.elementAt(1)%></strong></td>
    <td width="21%" height="20" >Amount Paid </td>
    <td width="33%" height="20" ><%=(String)vPmtInfo.elementAt(5)%></td>
  </tr>
  <tr >
    <td height="20" colspan="2" >Fee type</td>
    <td height="20" ><strong>Multiple Fee Charge</strong></td>
    <td height="20" >Payment Status</td>
    <td height="20" >Deposit (one time)</td>
  </tr>
  <tr >
    <td height="20" colspan="3" >Charges - usage unit</td>
    <td height="20" >Approval No.</td>
    <td height="20" >
      <%if(vPmtInfo.elementAt(3) == null){%>
      N/A
      <%}else{%>
      <%=(String)vPmtInfo.elementAt(3)%>
      <%}%>
    </td>
  </tr>
  <tr >
    <td width="1%" height="20" >&nbsp;</td>
    <td height="20" colspan="2" valign="top">
		<table width="100%">
		<%
		 for(int i=5; i< vSchFacInfo.size(); ++i){%>
		 <tr>
			<td width="38%"><%=(String)vSchFacInfo.elementAt(i++)%></td>
			<td width="62%"><%=(String)vSchFacInfo.elementAt(i)%></td>
		</tr>
		 <%}%>
		 </table>

    </td>
    <td height="20" valign="top" >Payment Type<br> <br>
      Payment Receive Type <br> <br>
      Bank Name <br> <br>
      Check # </td>
    <td height="20" valign="top"><%=(String)vPmtInfo.elementAt(4)%><br> <br> <%=(String)vPmtInfo.elementAt(1)%><br>
      <br>
      <%if(vPmtInfo.elementAt(2) == null){%>
      N/A
      <%}else{%>
      <%=(String)vPmtInfo.elementAt(2)%>
      <%}%>
      <br> <br>
      <%if(vPmtInfo.elementAt(6) == null){%>
      N/A
      <%}else{%>
      <%=(String)vPmtInfo.elementAt(6)%>
      <%}%>
    </td>
  </tr>
  <tr >
    <td height="15" colspan="2" >Start Date of Occupancy</td>
    <td height="20" ><%=(String)vPmtInfo.elementAt(0)%></td>
    <td height="15" >&nbsp;</td>
    <td height="15" >&nbsp;</td>
  </tr>
</table>
<%}%>


<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="15">&nbsp;</td>
    <td height="15">&nbsp;</td>
  </tr>
  <tr>
    <td height="15"><div align="right">Payment received &amp; receipt printed
        by :</div></td>
    <td width="41%" height="15" valign="bottom">&nbsp;&nbsp;&nbsp;&nbsp;<strong><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></strong><br>
	&nbsp;&nbsp;_______________________________________
      </td>
  </tr>
  <tr>
    <td height="15" valign="bottom">&nbsp;</td>
    <td height="15" >&nbsp;&nbsp;&nbsp;&nbsp;<i>Business Office</i></td>
  </tr>
</table>
  <script language="JavaScript">
	window.print();
window.setInterval("javascript:window.close();",0);
</script>
<%
}//only if no error message
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
