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

<body onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.FAPayment,enrollment.FAAssessment,enrollment.FAPaymentUtil,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	boolean bolIsFine = false;

		strTemp = WI.fillTextValue("fp");
		if(strTemp.equals("1"))
			strTemp = "&fp=1";
		else
			strTemp = "";//if full payment, i have to show ok for midterm. - for CSA.


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
      String strSukli = WI.fillTextValue("sukli");
	if(strSukli != null)
		strSukli = "&sukli="+strSukli;
	else
		strSukli = "";//System.out.println("Sukli : "+strSukli);

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
	if(strSchoolCode.startsWith("UPH")){
		if(strInfo5.length() > 0)
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_UPHS.jsp?or_number="+request.getParameter("or_number")));
		else
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_UPH1.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("CDD")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_CDD.jsp?or_number="+request.getParameter("or_number")+strSukli));
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
	if(strSchoolCode.startsWith("PHILCST")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_PHILCST.jsp?or_number="+request.getParameter("or_number")+strSukli));
		return;
	}
	if(strSchoolCode.startsWith("CSA")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_CSA.jsp?or_number="+request.getParameter("or_number")+strTemp));
		return;
	}
	if(strSchoolCode.startsWith("AUF")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_AUF.jsp?or_number="+request.getParameter("or_number")));
		return;
	}
	if(strSchoolCode.startsWith("WNU")){
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
	}
	else if(strSchoolCode.startsWith("CPU")){
		response.sendRedirect(response.encodeRedirectURL("./one_receipt_CPU.jsp?or_number="+request.getParameter("or_number")+"&fund_type=" + request.getParameter("fund_type")));
		return;
	}
	**/

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-installment fees print","install_assessed_fees_pritn_receipt.jsp");
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
FAAssessment FA = new FAAssessment();
FAPaymentUtil pmtUtil = new FAPaymentUtil();

Vector vRetResult = faPayment.viewPmtDetail(dbOP, request.getParameter("or_number"));
Vector vStudInfo = null;
Vector vScheduledPmt = null;
//double dChkAmt = 0d; double dCashAmt = 0;

if(vRetResult != null && vRetResult.size() > 0)
{
	vStudInfo = pmtUtil.getStudBasicInfoOLD(dbOP,(String)vRetResult.elementAt(25));
	if(vStudInfo == null)
		strErrMsg = pmtUtil.getErrMsg();
	//dChkAmt = Double.parseDouble((String)vRetResult.elementAt(36));
	//dCashAmt = Double.parseDouble((String)vRetResult.elementAt(37));
/**
	vScheduledPmt =FA.getInstallmentSchedulePerStudPerExamSch(dbOP,(String)vRetResult.elementAt(27),(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(8),
						(String)vStudInfo.elementAt(9),(String)vStudInfo.elementAt(4),(String)vStudInfo.elementAt(5));
	if(vScheduledPmt == null || vScheduledPmt.size() ==0)
		strErrMsg = FA.getErrMsg();
*/
		//vScheduledPmt.addelementAt("0");vScheduledPmt.addElement("0");vScheduledPmt.addElement("0");
		//vScheduledPmt.addElement("0");vScheduledPmt.addElement("0");vScheduledPmt.addElement("0");
	//System.out.println((String)vRetResult.elementAt(27));
	//System.out.println((String)vRetResult.elementAt(28));
}
else
	strErrMsg = pmtUtil.getErrMsg();

if(vRetResult == null)
	strErrMsg = faPayment.getErrMsg();

boolean bolShowReceiptHeading = false;
if(!bolShowReceiptHeading) { //forced to enter ;-)
	enrollment.ReadPropertyFileImpl readPropFileImpl = new enrollment.ReadPropertyFileImpl();
	int iRetValue = readPropFileImpl.showReceiptHeading();
	if(iRetValue == -1)
		strErrMsg = readPropFileImpl.getErrMsg();
	else if(iRetValue == 1)
		bolShowReceiptHeading = true;
}
String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
if(vRetResult != null){
%>


<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <%if(bolShowReceiptHeading){%>
  <tr>
    <td height="31" colspan="2" ><div align="center"><font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font> </font><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=SchoolInformation.getInfo1(dbOP,false,false)%></div></td>
  </tr>
  <%}if(strSchoolCode.startsWith("UI")){%>
  <tr >
    <td height="20" colspan="2" ><div align="center"><strong>OFFICIAL RECEIPT</strong></div></td>
  </tr>
 <%}
 if(strSchoolCode.startsWith("LNU"))
 	strTemp = "right";
 else
 	strTemp = "center";
%>
  <tr >
    <td height="25" colspan="2" ><div align="<%=strTemp%>">PAYMENT FOR <%=((String)vRetResult.elementAt(28)).toUpperCase()%>&nbsp;&nbsp;&nbsp;</div></td>
  </tr>
  <tr >
    <td width="48%" height="25" >Date and time printed : <strong><%=WI.getTodaysDateTime()%></strong></td>
    <td width="52%" height="25" ><div align="right">Reference Number : <strong><%=request.getParameter("or_number")%> &nbsp;&nbsp;</strong></div></td>
  </tr>
  <tr >
    <td height="25" >Student ID :<strong> <%=WI.getStrValue(vRetResult.elementAt(25))%></strong></td>
    <td height="25" >Course-Major : <strong><%=WI.getStrValue(vRetResult.elementAt(19))%>
	<%=WI.getStrValue((String)vRetResult.elementAt(20),"/","","")%></strong></td>
  </tr>
  <tr >
    <td height="25" class="thinborderBOTTOM">Student name :<strong>
      <%
//if user index is null, the student is ex-studetn, so display only name,
if( vRetResult.elementAt(0) != null){%>
      <%=(String)vRetResult.elementAt(18)%>
      <%}else{%>
      <%=(String)vRetResult.elementAt(1)%>
      <%}%>
      </strong></td>
    <td height="25" class="thinborderBOTTOM">Year/Sem/SY :
   <%if(vRetResult.elementAt(22) != null){%>
   <strong><%=WI.getStrValue(vRetResult.elementAt(21),"N/A")%>/<%=astrConvertToSem[Integer.parseInt((String)vRetResult.elementAt(22))]%> (<%=(String)vRetResult.elementAt(23) + "-"+(String)vRetResult.elementAt(24)%>) </strong>
   <%}%>
   </td>
  </tr>
</table>

<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr >
    <td height="23" ><div align="center"></div></td>
    <td colspan="3" ><div align="center">:: PAYMENT DETAILS ::</div></td>
  </tr>
  <tr >
    <td width="4%" >&nbsp;</td>
    <td width="22%" height="20" >Amount paid </td>
    <td colspan="2" ><strong><%=new ConversionTable().convertAmoutToFigure(Double.parseDouble((String)vRetResult.elementAt(11)),"Pesos","Centavos")%> (<%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>)</strong></td>
  </tr>
  <tr >
    <td >&nbsp;</td>
    <td height="20" >Date Paid </td>
    <td width="33%"><strong><%=WI.getStrValue(vRetResult.elementAt(15))%></strong></td>
    <td width="41%" rowspan="3">
	<%
	if(vRetResult.elementAt(33) != null) {%>
	<font size="1"><%=(String)vRetResult.elementAt(33)%>
	</font>
	<%}%>
	</td>
  </tr>
  <tr >
    <td >&nbsp;</td>
    <td height="20" >Payment type</td>
    <td><strong><%=(String)vRetResult.elementAt(10)%> <%=WI.getStrValue((String)vRetResult.elementAt(32)," (Emp ID: ",")","")%></strong></td>
  </tr>
  <tr >
    <td >&nbsp;</td>
    <td height="20" >Payment receive type</td>
    <td><strong><%=(String)vRetResult.elementAt(2)%></strong></td>
  </tr>
  <%
if(vRetResult.elementAt(14) != null){%>
  <tr >
    <td >&nbsp;</td>
    <td height="20" >Check #</td>
    <td colspan="2"><strong><%=(String)vRetResult.elementAt(14)%></strong></td>
  </tr>
  <tr >
    <td >&nbsp;</td>
    <td height="20" >Bank name</td>
    <td colspan="2"><strong><%=WI.getStrValue(vRetResult.elementAt(34))%></strong></td>
  </tr>
  <%}%>
</table>


<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="46%" height="10">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="10"><div align="right">Payment received &amp; receipt printed
        by :</div></td>
    <td width="54%"><u><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></u></td>
  </tr>
  <tr>
    <td height="10" valign="bottom">&nbsp;</td>
    <td valign="top">&nbsp;Business Office</td>
  </tr>
</table>
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
