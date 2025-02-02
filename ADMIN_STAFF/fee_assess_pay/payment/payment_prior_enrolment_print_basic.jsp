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
<%@ page language="java" import="utility.*,enrollment.FAPayment,java.util.Vector" %>
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
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_SPC.jsp?or_number="+
			request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("UB")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_UB.jsp?or_number="+
			request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("WUP")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_WUP.jsp?or_number="+
			request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("UC")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_UC.jsp?or_number="+
			request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("CDD")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_CDD.jsp?or_number="+
			request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("UPH")){
		if(strInfo5.length() > 0)
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_UPHS.jsp?or_number="+request.getParameter("or_number")));
		else
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_UPH1.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("EAC")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_EAC.jsp?payment_for_=Applicatoin/Registration&or_number="+
			request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("FATIMA")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_FATIMA.jsp?payment_for_=Applicatoin/Registration&or_number="+
			request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("CIT")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_CIT.jsp?payment_for_=Applicatoin/Registration&or_number="+
			request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("PHILCST")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_PHILCST.jsp?payment_for_=Applicatoin/Registration&or_number="+
			request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("UL")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_UL.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("DBTC")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_DBTC.jsp?payment_for_=Reservation&or_number="+request.getParameter("or_number")+strSukli));
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
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_AUF.jsp?payment_for_=Tuition&or_number="+request.getParameter("or_number")));
		return;
	}
	else if(strSchoolCode.startsWith("WNU")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_WNU.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	else if(strSchoolCode.startsWith("CLDH")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_CLDH.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}**/
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

FAPayment faPayment = new FAPayment();
Vector vStudInfo = null;
enrollment.Advising advising = new enrollment.Advising();

Vector vRetResult = faPayment.viewPmtDetail(dbOP, request.getParameter("or_number"));

//System.out.println("vRetResult : " + vRetResult);
//System.out.println(vRetResult);
if(vRetResult == null)
	strErrMsg = faPayment.getErrMsg();
if(vRetResult != null){//System.out.println(vRetResult);
String[] astrConvertToSem = {"Summer","",""};

vStudInfo = advising.getStudInfo(dbOP, (String)vRetResult.elementAt(25));
//System.out.println("vStudInfo " + vStudInfo);
if(vStudInfo == null) {
	vStudInfo = new enrollment.OfflineAdmission().getStudentBasicInfo(dbOP, (String)vRetResult.elementAt(25),
				(String)vRetResult.elementAt(23),(String)vRetResult.elementAt(24),(String)vRetResult.elementAt(22));
	if(vStudInfo != null) {
		vStudInfo.setElementAt(vStudInfo.elementAt(14), 6);
	}
}

boolean bolShowReceiptHeading = false;
if(!bolShowReceiptHeading) { //forced to enter ;-)
	ReadPropertyFile readPropFile = new ReadPropertyFile();
	strTemp = readPropFile.getImageFileExtn("showHeadingOnPrintReceipt");
	if(strTemp != null && strTemp.compareTo("1") == 0)
		bolShowReceiptHeading = true;
}

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
      </div></td>
    </tr>
<%}if(strSchoolCode.startsWith("UI")){%>
  <tr >
    <td height="20" colspan="2" ><div align="center">
	<strong>OFFICIAL RECEIPT</strong></div></td>
  </tr>
 <%}
 if(strSchoolCode.startsWith("LNU"))
 	strTemp = "right";
 else
 	strTemp = "center";
%>
<tr >
      <td height="25" colspan="2" >
	<% if (strSchoolCode.startsWith("VMUF") && vRetResult != null && vRetResult.elementAt(44) != null) {%>
		<div align="center"><font style="font-size:11px"><strong><%=(String)vRetResult.elementAt(44)%></strong></font><br></div>
	<%}else{%>
	  <div align="<%=strTemp%>">PAYMENT FOR DOWNPAYMENT/APPLICATION/REGISTRATION
        FEE &nbsp;&nbsp;&nbsp;</div>
	<%}%>
		</td>
    </tr>
    <tr >

    <td width="57%" height="21" >Date and time printed: <strong><%=WI.getTodaysDateTime()%></strong></td>
      <td width="43%" height="21" ><div align="right">Reference Number : <strong><%=request.getParameter("or_number")%>
      &nbsp;&nbsp;</strong></div></td>
    </tr>
    <tr >
      <td height="20" >Student ID :<strong> <%=WI.getStrValue(vRetResult.elementAt(25))%></strong></td>
    <td height="20" >Year : <strong><%=dbOP.getBasicEducationLevel(Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(6),"0")))%></strong></td>
    </tr>
    <tr >

    <td height="20" class="thinborderBOTTOM">Student name :<strong>
	<%
//if user index is null, the student is ex-studetn, so display only name,
if( vRetResult.elementAt(0) != null){%>
<%=(String)vRetResult.elementAt(18)%>
<%}else{%><%=(String)vRetResult.elementAt(1)%>
<%}%>
</strong></td>

    <td height="20" class="thinborderBOTTOM">&nbsp;School Year  :
      <%if(vRetResult.elementAt(22) != null){%>
      <strong> <%=(String)vRetResult.elementAt(23) + " - "+(String)vRetResult.elementAt(24)%><%=astrConvertToSem[Integer.parseInt((String)vRetResult.elementAt(22))]%></strong> <%}%> </td>
    </tr>
  </table>

<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr >
    <td height="23" ><div align="center"></div></td>
    <td colspan="2" ><div align="center">:: PAYMENT DETAILS ::</div></td>
  </tr>
  <tr >
    <td width="6%" height="20" >&nbsp;</td>
    <td width="20%" height="20" >Amount paid </td>
    <td width="74%" height="20" ><strong> <%=new ConversionTable().convertAmoutToFigure(Float.parseFloat((String)vRetResult.elementAt(11)),"Pesos","Centavos")%> (<%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>)</strong></td>
  </tr>
  <tr >
    <td height="20" >&nbsp;</td>
    <td height="20" >Date paid</td>
    <td height="20" ><strong><%=WI.getStrValue(vRetResult.elementAt(15))%></strong></td>
  </tr>
  <%if(WI.getStrValue(vRetResult.elementAt(7)).length() > 0){%>
  <%}%>
  <tr >
    <td height="20" >&nbsp;</td>
    <td height="20" >Payment type</td>
    <td height="20" ><strong><%=(String)vRetResult.elementAt(10)%></strong></td>
  </tr>
  <tr >
    <td height="20" >&nbsp;</td>
    <td height="20" >Payment receive type</td>
    <td height="20" ><strong><%=(String)vRetResult.elementAt(2)%></strong></td>
  </tr>
  <%
if(vRetResult.elementAt(14) != null){%>
  <tr >
    <td height="20" >&nbsp;</td>
    <td>Check #</td>
    <td><strong><%=WI.getStrValue(vRetResult.elementAt(14))%></strong></td>
  </tr>
  <tr >
    <td height="20" >&nbsp;</td>
    <td height="20" >Bank name</td>
    <td height="20" ><strong><%=WI.getStrValue(vRetResult.elementAt(34))%></strong></td>
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
    <td width="51%" height="10"><div align="right">Payment received &amp; receipt
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
