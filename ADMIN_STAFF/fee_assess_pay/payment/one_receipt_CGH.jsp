<%
boolean bolShowLabel = false;//for actual, set it to false;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>One Receipt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style>
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
    TABLE.thinborder {
<%if(bolShowLabel){%>
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
<%}%>
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TABLE.thinborderALL {
<%if(bolShowLabel){%>
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
<%}%>
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborderALL {
<%if(bolShowLabel){%>
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
<%}%>
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborder {
<%if(bolShowLabel){%>
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
<%}%>
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderRIGHT {
<%if(bolShowLabel){%>
    border-right: solid 1px #000000;
<%}%>
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOM{
<%if(bolShowLabel){%>
    border-bottom: solid 1px #000000;
<%}%>
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOMRIGHT {
<%if(bolShowLabel){%>
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
<%}%>
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOMLEFTRIGHT {
<%if(bolShowLabel){%>
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
<%}%>
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
-->
</style>
</head>

<body topmargin="0" onLoad="window.print()">
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
double dChkAmt = 0d; double dCashAmt = 0; boolean bolIsRemittance = false;

FAPayment faPayment = new FAPayment();
Vector vRetResult = faPayment.viewPmtDetail(dbOP, request.getParameter("or_number"));
if(vRetResult == null) {//may be remittance.
	enrollment.FARemittance faR = new enrollment.FARemittance(request);
	if(faR.isRemittance(dbOP, request.getParameter("or_number")) ) {
		vRetResult = faR.getPaymentDetail(dbOP, request.getParameter("or_number"), "1");
		bolIsRemittance = true;
	}
}
//System.out.println(vRetResult);
String strSectionEnrolled = null;
//get section enrolled, if null, retain year level, else show section instead of year level.

if(vRetResult == null)
	strErrMsg = faPayment.getErrMsg();
else {
	dChkAmt = Double.parseDouble((String)vRetResult.elementAt(36));
	dCashAmt = Double.parseDouble((String)vRetResult.elementAt(37));
	if(vRetResult.elementAt(25) != null) {//stud id is not null
		strSectionEnrolled = new search.SearchStudent(request).getSectionOfAStud(dbOP, 
			(String)vRetResult.elementAt(25), (String)vRetResult.elementAt(23), 
			(String)vRetResult.elementAt(22));
		if(strSectionEnrolled != null) 
			vRetResult.setElementAt(strSectionEnrolled, 21);
	}
}

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

String[] astrConvertSem = {"Summer","1st","2nd"};

if(strErrMsg == null){%>
  <table width="725" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
		<td width="10%">&nbsp;</sup> </td>

    <td width="90%" height="18" align="center" valign="bottom"><strong>
      <%if(bolShowLabel){%>
      <font size="2">CHINESE GENERAL HOSPITAL COLLEGE OF NURSING & LIBERAL ARTS</font>
      <%}%>
      </strong></td>
    </tr>
   	<tr>
   	  <td width="10%">&nbsp;</td>

    <td> <div align="center">
        <%if(bolShowLabel){%>
        286 Blumentritt Street., Sta. Cruz, Manila 
<!--		
		<br>
		Trunkline : 7114141 local 601 /Telefax : 7110072
	
		<br>

		TIN : 283-617-702-000
-->
        <%}%>
      </div></td>
    </tr>
<!--
	<tr>
		<td colspan="2" align="center" height="10"><strong><%if(false){%>
      PROVISIONAL RECEIPT 
      <%}%></strong></td>
	</tr>
-->
</table>
    <table width="725" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
      <tr>
        <td width="160" height="54" class="thinborder"><font size="1">
          <%if(bolShowLabel){%>
        Student/Employee/Other
        <%}%></font>
        <br>
        <!-- No. --> 
		<%if(!bolIsRemittance) {%>
		<%=WI.getStrValue((String)vRetResult.elementAt(25),"External Pmt")%><%}%></td>
        <td width="138" class="thinborder"><font size="1">
          <%if(bolShowLabel){%>
        College/Dept.
        <%}%></font>
        <br>
        <%=WI.getStrValue((String)vRetResult.elementAt(35),"")%></td>
        <td width="195" class="thinborder"><font size="1">
          <%if(bolShowLabel){%>
        Semester/Year Level/School Year
        <%}%></font>
        <br>
        <b><% if(vRetResult.elementAt(22) != null){%>
		<%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(22))]%>/<%=WI.getStrValue((String)vRetResult.elementAt(21))%>/
		<%=(String)vRetResult.elementAt(23) + "-"+((String)vRetResult.elementAt(24)).substring(2)%>
		<%}%></b></td>
        <td width="93" class="thinborder"><font size="1">
          <%if(bolShowLabel){%>
        Date:
        <%}%>
        </font><br>
        <%=WI.getStrValue(vRetResult.elementAt(15))%></td>
        <td width="139" class="thinborder"><font size="1">
          <%if(bolShowLabel){%>
        Reference No.:
        <%}%></font>
        <br>
        <span class="thinborderBOTTOM"><%=request.getParameter("or_number")%></span></td>
      </tr>
    </table>
    <br>
	<table width="725" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      
      <tr>
        <td width="68" height="25" class="thinborderBOTTOM" valign="top">
          <%if(bolShowLabel){%>
        RECEIVED<br>
        FROM<%}%><br>&nbsp;</td>
        <td width="424" class="thinborderBOTTOMRIGHT" valign="top" align="left"><%
//if user index is null, the student is ex-studetn, so display only name,
if( vRetResult.elementAt(0) != null){%>
          <%=(String)vRetResult.elementAt(18)%>
          <%}else{%>
          <%=(String)vRetResult.elementAt(1)%>
        <%}%></td>
        <td width="233" rowspan="2" valign="top">&nbsp;&nbsp;&nbsp;<%if(bolShowLabel){%>Payment Type:<%}%> <br> 
          <!-- format cash  : xyz 
		              check : xyo
					  (check number)-->
<%if(dChkAmt > 0d){%>	
          Cash &nbsp;: <%=CommonUtil.formatFloat(dCashAmt,true)%>
<%}else if(vRetResult.elementAt(14) == null){%> 
	Cash &nbsp;: <%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%> <%}//show only cash.%>
<%if(dChkAmt > 0d){%>
	<br>Check : <%=CommonUtil.formatFloat(dChkAmt,true)%>
<%}else if(vRetResult.elementAt(14) != null){%> 
	<br>Check : <%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%> <%}//show only if check.%>
	
	<%=WI.getStrValue((String)vRetResult.elementAt(34),"<br>","","")%>
	<%=WI.getStrValue((String)vRetResult.elementAt(14),"<br>Check #: ","","")%>
		  
		  
		  
<!--
<%=(String)vRetResult.elementAt(10)%> <%=WI.getStrValue((String)vRetResult.elementAt(32)," (Emp ID: ",")","")%> 
--></td>
      </tr>
      <tr>
        <td height="25" class="thinborderBOTTOM" valign="top">
          <%if(bolShowLabel){%>
        THE SUM<br>
          OF<%}%><br>&nbsp;</td>
        <td class="thinborderBOTTOMRIGHT"><br>
		<%=new ConversionTable().convertAmoutToFigure(Double.parseDouble((String)vRetResult.elementAt(11)),"Pesos","Centavos")%> (<%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(11)),true)%>)</td>
      </tr>
      <tr>
        <td height="25" colspan="2" valign="top">
          <%if(bolShowLabel){%>
        AS PAYMENT OF<%}%><br><br><br>&nbsp;<br>
		<%=WI.getStrValue((String)vRetResult.elementAt(28),"","<br>","&nbsp;")%>
		
		<%if(WI.fillTextValue("payment_for_").length() > 0){%>
          <%=WI.fillTextValue("payment_for_")%>
          <%}else if(vRetResult.elementAt(33) != null) {%>
          <font size="1"><%=(String)vRetResult.elementAt(33)%></font>
          <%}else if( ((String)vRetResult.elementAt(4)).compareTo("0") == 0){%>
Tuition
<%
strTemp = (String)request.getSession(false).getAttribute("lf_reason");
request.getSession(false).removeAttribute("lf_reason");
/*** Here i am trying to show surcharge information -- it will fail if a student pays surcharge
	 and one same day he pays again but no surcharge. if OR is reprinted, this piece of code will 
	 print surcharge on both OR. To permanently fix this, add a surcharge_index in fa_stud_payment table
	 get surcharge index from fa_stud_payable after posting. and add 
   *   [43]=surcharge dtls. - added for CGH. in FAPayment.java.viewPmtDetail method.
***/
if(strTemp == null && WI.fillTextValue("reprint_").length() > 0 && vRetResult.elementAt(0) != null) {///i have to findout if this is re print or not..  
	//check if there is any late surcharge.
	String strSQLQuery = "select amount from fa_stud_Payable where note like 'Late payment surcharge%' "+
	"and user_index = "+vRetResult.elementAt(0)+" and is_valid = 1 and transaction_date = '"+
	ConversionTable.convertTOSQLDateFormat((String)vRetResult.elementAt(15))+"'";
	strTemp = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strTemp != null) {
		double dAmtPaidTemp = Double.parseDouble((String)vRetResult.elementAt(11));
		dAmtPaidTemp        = dAmtPaidTemp - Double.parseDouble(strTemp);
		strTemp             = " : P"+CommonUtil.formatFloat(dAmtPaidTemp,true)+
			"<br> Late payment surcharge : P"+CommonUtil.formatFloat(strTemp,true);//strTemp = null;
	}
}
if(strTemp != null) {%>
<%=strTemp%>
<%}%>
<%}else if(vRetResult.elementAt(5) != null){%>
<%=(String)vRetResult.elementAt(5)%>
<%}else{
					if(vRetResult.elementAt(42) != null)
						strTemp = (String)vRetResult.elementAt(42);
					else if(vRetResult.elementAt(4).equals("10"))
						strTemp = "Back Account";%>
<%=strTemp%>
<%}%></td>
        <td width="233" valign="bottom">
          <br>
          <br>
		  <br>
		  <br>
	          <br>
		  <br>
                  
              &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp;<%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%><br>
          <br>
        <%if(bolShowLabel){%>Cashier<br><%}%>&nbsp;</td>
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
