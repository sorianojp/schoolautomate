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
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
    }

-->
</style>
</head>

<body >
<%@ page language="java" import="utility.*,enrollment.FAElementaryPayment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	boolean bolIsFine = false;
	boolean bolIsDownPmt =false;

	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null)
		strSchoolCode = "";
	String strInfo5 = WI.getStrValue((String)request.getSession(false).getAttribute("info5"));

      String strORFormName = utility.CommonUtil.getORFileName(null, request);
      if(strORFormName != null) {
        strORFormName +="?or_number="+request.getParameter("or_number");
        response.sendRedirect(response.encodeRedirectURL(strORFormName));
        return;
      }
      /**
	if(strSchoolCode.startsWith("SPC")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_SPC.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	if(strSchoolCode.startsWith("WUP")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_WUP.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	if(strSchoolCode.startsWith("UPH")){
		if(strInfo5.length() > 0)
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_UPHS.jsp?or_number="+request.getParameter("or_number")));
		else
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_UPH1.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	if(strSchoolCode.startsWith("CDD")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_CDD.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	if(strSchoolCode.startsWith("VMA")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_VMA.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	if(strSchoolCode.startsWith("UC")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_UC.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	if(strSchoolCode.startsWith("EAC")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_EAC.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	if(strSchoolCode.startsWith("FATIMA")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_FATIMA.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	if(strSchoolCode.startsWith("CIT")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_CIT.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	if(strSchoolCode.startsWith("UL")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_UL.jsp?or_number="+request.getParameter("or_number")));
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
	if(strSchoolCode.startsWith("WNU")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_WNU.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	if(strSchoolCode.startsWith("PHILCST")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_PHILCST.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	if(strSchoolCode.startsWith("DBTC")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_DBTC.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	if(strSchoolCode.startsWith("PIT")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_PIT.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
      **/

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

FAElementaryPayment faPayment = new FAElementaryPayment();
Vector vRetResult = faPayment.viewPmtDetail(dbOP, request.getParameter("or_number"));//System.out.println(vRetResult);
if(vRetResult == null)
	strErrMsg = faPayment.getErrMsg();
if(vRetResult != null){//System.out.println(vRetResult);
String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

boolean bolShowReceiptHeading = false;
if(!bolShowReceiptHeading) { //forced to enter ;-)
	enrollment.ReadPropertyFileImpl readPropFileImpl = new enrollment.ReadPropertyFileImpl();
	int iRetValue = readPropFileImpl.showReceiptHeading();
	if(iRetValue == -1)
		strErrMsg = readPropFileImpl.getErrMsg();
	else if(iRetValue == 1)
		bolShowReceiptHeading = true;
}
String[] astrConvertToEduLevel = {"Preparatory","Elementary","High School"};
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
<%}%>    <tr >
      <td height="25" colspan="2" ><div align="center">OFFICIAL RECEIPT FOR DOWNPAYMENT/REGISTRATION
        FEE </div></td>
    </tr>
    <tr >
      <td width="48%" height="20" >Date and time
        printed(yyyy-mm-dd) : <strong><%=WI.getTodaysDateTime()%></strong></td>
      <td width="52%" height="20" ><div align="right">Reference Number : <strong><%=request.getParameter("or_number")%>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong></div></td>
    </tr>
    <tr >
      <td height="20" >Student ID :<strong> <%=WI.getStrValue(vRetResult.elementAt(4))%></strong></td>
    <td height="20" >Education Level : <%=astrConvertToEduLevel[Integer.parseInt((String)vRetResult.elementAt(0))]%></td>
    </tr>
    <tr >

    <td height="20" class="thinborderBOTTOM">Student name :<strong>
	<%=WebInterface.formatName((String)vRetResult.elementAt(6),(String)vRetResult.elementAt(7),
		(String)vRetResult.elementAt(8),4)%>
</strong></td>

    <td height="20" class="thinborderBOTTOM">&nbsp;</td>
    </tr>

  </table>

<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr >
    <td height="25" ><div align="center"></div></td>
    <td height="25"  colspan="2" ><div align="center">:: PAYMENT DETAILS ::</div></td>
  </tr>
  <tr >
    <td width="6%" height="20" >&nbsp;</td>
    <td width="18%" height="20" >Amount paid </td>
    <td width="76%" height="20" ><strong> <%=new ConversionTable().convertAmoutToFigure(Double.parseDouble((String)vRetResult.elementAt(9)),"Pesos","Centavos")%> (<%=CommonUtil.formatFloat((String)vRetResult.elementAt(9),true)%>)</strong></td>
  </tr>
  <tr >
    <td height="20" >&nbsp;</td>
    <td height="20" >Date paid</td>
    <td height="20" ><strong><%=WI.getStrValue(vRetResult.elementAt(11))%></strong></td>
  </tr>
  <%if(WI.getStrValue(vRetResult.elementAt(7)).length() > 0){%>
  <%}%>
  <tr >
    <td height="20" >&nbsp;</td>
    <td height="20" >Payment type</td>
    <td height="20" ><strong><%=(String)vRetResult.elementAt(12)%>
	<%=WI.getStrValue((String)vRetResult.elementAt(13),", Emp ID :","","")%></strong></td>
  </tr>
  <%
if(vRetResult.elementAt(10) != null){%>
  <tr >
    <td height="20" >&nbsp;</td>
    <td>Check #</td>
    <td><strong><%=WI.getStrValue(vRetResult.elementAt(10))%></strong></td>
  </tr>
  <%}%>
  <tr >
    <td height="10" >&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>


<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="51%" height="20"><div align="right">Payment received &amp; receipt
        printed by :</div></td>
    <td width="49%">&nbsp;<u><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></u></td>
  </tr>
  <tr>
    <td height="10" valign="bottom">&nbsp;</td>
    <td valign="top">&nbsp;&nbsp;&nbsp;&nbsp;<i>Business Office</i></td>
  </tr>
</table>
  <script language="JavaScript">
	window.print();
window.setInterval("javascript:window.close();",0);
</script>
<%}//if vRetResult not null
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
