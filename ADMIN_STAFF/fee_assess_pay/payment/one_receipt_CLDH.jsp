<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>One Receipt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
-->
</style>
</head>

<body onLoad="window.print();">
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

double dChkAmt = 0d; double dCashAmt = 0;
FAPayment faPayment = new FAPayment();

enrollment.FAAssessment FA     = new enrollment.FAAssessment();
String strPmtSchName = null;
boolean bolIsOkForExam = false;

String strAmtTendered = null;
String strAmtChange   = null;

Vector vRetResult = faPayment.viewPmtDetail(dbOP, request.getParameter("or_number"));//System.out.println(vRetResult);
if(vRetResult == null)
	strErrMsg = faPayment.getErrMsg();
else {
	dChkAmt = Double.parseDouble((String)vRetResult.elementAt(36));
	dCashAmt = Double.parseDouble((String)vRetResult.elementAt(37));

	//to know if it is ok for prelim/mterm / finals.
	strPmtSchName = (String)vRetResult.elementAt(28);
	if(strPmtSchName != null && vRetResult.elementAt(0) != null) {
		Vector vInstallmentInfo = FA.getPaymentDueForAnExam(dbOP, (String)vRetResult.elementAt(0),
								  (String)vRetResult.elementAt(23), (String)vRetResult.elementAt(24), (String)vRetResult.elementAt(21), 
								  (String)vRetResult.elementAt(22), null, strPmtSchName);
		if(vInstallmentInfo != null && vInstallmentInfo.elementAt(1).equals("0")) {
			strTemp = (String)vRetResult.elementAt(4);
			if(strTemp != null && strTemp.equals("0")) {
				bolIsOkForExam = true;
			}
		}
	}

		strAmtTendered = (String)vRetResult.elementAt(48);
		strAmtChange   = (String)vRetResult.elementAt(49);

		if(strAmtTendered.equals("0.00"))
			strAmtTendered = CommonUtil.formatFloat((String)vRetResult.elementAt(11),true);
}
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

if(strErrMsg == null){%>
  <table width="725" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    <tr>
		<td width="10%" rowspan="3">&nbsp;</td>

    <td height="25" valign="bottom" colspan = "2"><strong>
      <%if(bolShowLabel){%>
      CENTRAL LUZON DOCTORS' HOSPITAL-EDUCATIONAL INSTITUTION
      <%}%>
      </strong></td>
    </tr>
   	<tr>

    <td>
      <%if(bolShowLabel){%>
      Romulo Blvd., San Vicante, Tarlac City
      <%}%>
    </td>

    <td rowspan="2"><font size="3">
      <%if(bolShowLabel){%>
      No. <font color="red">117248
      <%}%>
      </font></font></td>
    </tr>
	<tr>

    <td height="18" valign="top">
      <%if(bolShowLabel){%>
      NON-VAT Reg. TIN 213-380-025-000
      <%}%>
    </td>
	</tr>
	<tr>
		<td colspan="3" align="center" height="10"><strong><%if(bolShowLabel){%>OFFICIAL RECEIPT<%}%></strong></td>
	</tr>
    </table>
    <table width="725" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderLEFTRIGHT">
		<tr>
			<td width="12.5" height="25">&nbsp;</td>

    <td colspan="2"><%=WI.getStrValue((String)vRetResult.elementAt(25),"External Pmt")%>
      <%if(bolShowLabel){%>
      (Student ID)
      <%}%>
    </td>
			<td width="100"><%if(bolShowLabel){%>
      Date
      <%}%>
      </td>

    <td width="150"> <%=WI.getStrValue(vRetResult.elementAt(15))%></td>
			<td width="12.5">&nbsp;</td>
		</tr>
		<tr>
			<td height="18">&nbsp;</td>

    <td width="100" align="left"><em>
      <%if(bolShowLabel){%>
      Recieved from
      <%}%>
      </em></td>

    <td width="360">
      <%
//if user index is null, the student is ex-studetn, so display only name,
if( vRetResult.elementAt(0) != null){%>
      <%=(String)vRetResult.elementAt(18)%>
      <%}else{%>
      <%=(String)vRetResult.elementAt(1)%>
      <%}%>
    </td>

    <td><em>
      <%if(bolShowLabel){%>
      Course/Yr
      <%}%>
      </em></td>

    <td><%=WI.getStrValue((String)vRetResult.elementAt(35),"")%>
	<%=WI.getStrValue((String)vRetResult.elementAt(21)," - ","","")%>
	</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="18">&nbsp;</td>

    <td align="left"><em>
      <%if(bolShowLabel){%>
      the sum of
      <%}%>
      </em></td>

    <td colspan="2"><%=new ConversionTable().convertAmoutToFigure(Double.parseDouble((String)vRetResult.elementAt(11)),"Pesos","Centavos")%></td>

    <td>&nbsp;&nbsp;&nbsp;&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%></td>
			<td>&nbsp;</td>
		</tr>
    </table>
    <table width="725" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderLEFTRIGHT">
	<tr>
		<td width="12.5">&nbsp;</td>
		<td width="710" height="80" valign="top">
				<table width="100%" class="thinborderALL">
        <tr>
          <td width="100%" align="center" class="thinborderBOTTOM"> &nbsp;<%if(bolShowLabel){%>
            PAYMENT DESCRIPTION <%}%> </td>
        </tr>
       <tr>
          <td align="center" class="thinborderBOTTOM"> <div align="left">
              <%if(WI.fillTextValue("payment_for_").length() > 0){%>
              <%=WI.fillTextValue("payment_for_")%>
              <%}else if(vRetResult.elementAt(33) != null) {%>
              <font size="1"><%=(String)vRetResult.elementAt(33)%></font>
              <%}else if( ((String)vRetResult.elementAt(4)).compareTo("0") == 0){%>
              <%if(false){%>Tuition(do not show)<%}%>AR SCHOOL FEES
              <%}else if(vRetResult.elementAt(5) != null){%>
              <%=(String)vRetResult.elementAt(5)%> : <%=CommonUtil.formatFloat((String)vRetResult.elementAt(6),true)%>
              <%}else{
					if(vRetResult.elementAt(42) != null)
						strTemp = (String)vRetResult.elementAt(42);
					else if(vRetResult.elementAt(4).equals("10"))
						strTemp = "Back Account";%>
					<%=strTemp%>
					
			  <%}%>
            </div></td>
        </tr>
      </table>
		</td>
		<td width="12.5">&nbsp;</td>
	</tr>
    </table>
    <table width="725" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderLEFTRIGHT">
		<tr>
			<td width="12.5">&nbsp;</td>
			<td width="250">&nbsp;</td>
			<td width="210">&nbsp;</td>

    <td width="250" height = "25"><em>
      <%if(bolShowLabel){%>
      Thank You,
      <%}%>
      </em></td>
			<td width="12.5">&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>

    <td>
      <%if(bolShowLabel){%>
      CHECK&nbsp;Bank/No:
      <%}else{%>
      <br>
      <%}%>
      <%=WI.getStrValue(vRetResult.elementAt(34))%> <%=WI.getStrValue(vRetResult.elementAt(14))%> <br></td>

    <td>
      <%if(bolShowLabel){%>
      Amount:
      <%}else{%>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <%}%>
      &nbsp;<%if(vRetResult.elementAt(14) != null){
	  	if(dChkAmt > 0d){%>
			<%=CommonUtil.formatFloat(dChkAmt,true)%>
		<%}else{%>
      		<%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>
		<%}
		}//show only if check.%></td>

    <td>
      <%if(bolShowLabel){%>
      Central Luzon Doctors' Hospital-Educational Institution by:
      <%}%>
      </td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>

    <td valign="BOTTOM">
        <%if(bolShowLabel){%>
        CASH Amount:
        <%}else{%>
      <br>
      <%}%>
        <%if(vRetResult.elementAt(14) == null){%>
        <%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%>
        <%}//show only if check.
		else if(dChkAmt > 0d){%>
		<%=CommonUtil.formatFloat(dCashAmt,true)%>
        <%}%>

      </td>

    <td>
      <%if(bolShowLabel){%>
      Change:&nbsp;
      <%}else{%><br>
	  <%=strAmtChange%>
	  <%}%>
      </td>

    <td align="left" class="thinborderBOTTOM">&nbsp;&nbsp;&nbsp;
	<%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td class="thinborderBOTTOM" height="25">&nbsp;</td>

    <td class="thinborderBOTTOM" valign="top">
      <%if(bolShowLabel){%>
      Ref no.:
      <%}%><br>
      <%=request.getParameter("or_number")%></td>
	  <%
	  if(bolIsOkForExam) {
		  int iIndexOf = strPmtSchName.indexOf(" ");
		  if(iIndexOf > -1) 
			strPmtSchName = strPmtSchName.substring(0, iIndexOf);
	  }
	  %>
			<td class="thinborderBOTTOM" style="font-size:15px; font-weight:bold"><%if(bolIsOkForExam) {%>OK FOR <%=strPmtSchName.toUpperCase()%><%}%>&nbsp;</td>

    <td valign="top" align="center" class="thinborderBOTTOM">
      <%if(bolShowLabel){%>
      Cashier
      <%}%>
      </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
		</tr>


    </table>
<%}else{//print error msg%>
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
