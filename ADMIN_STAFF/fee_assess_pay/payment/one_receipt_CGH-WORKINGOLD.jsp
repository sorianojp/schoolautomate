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

<body>
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
boolean bolShowLabel = true;//for actual, set it to false;
double dChkAmt = 0d; double dCashAmt = 0;

FAPayment faPayment = new FAPayment();
Vector vRetResult = faPayment.viewPmtDetail(dbOP, request.getParameter("or_number"));//System.out.println(vRetResult);
if(vRetResult == null)
	strErrMsg = faPayment.getErrMsg();
else {
	dChkAmt = Double.parseDouble((String)vRetResult.elementAt(36));
	dCashAmt = Double.parseDouble((String)vRetResult.elementAt(37));
}

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

if(strErrMsg == null){%>
  <table width="725" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    <tr>
		<td width="10%" rowspan="3">&nbsp;</td>

    <td height="25" valign="bottom" colspan = "2" align="center"><strong>
      <%if(bolShowLabel){%>
      CHINESE GENERAL HOSPITAL COLLEGE OF NURSING & LIBERAL ARTS
      <%}%>
      </strong></td>
    </tr>
   	<tr>

    <td> <div align="center">
        <%if(bolShowLabel){%>
        286 Blumentritt Street., Sta. cruz, Manila 1014 
        <%}%>
      </div></td>

    <td rowspan="2"><font size="3">
      <%if(false){%>
      No. <font color="red">117248
      <%}%>
      </font></font></td>
    </tr>
	<tr>

    <td height="18" valign="top">
      <%if(false){%>
      NON-VAT Reg. TIN 213-380-025-000
      <%}%>
    </td>
	</tr>
	<tr>
		<td colspan="3" align="center" height="10"><strong><%if(bolShowLabel){%>
      PROVISIONAL RECEIPT 
      <%}%></strong></td>
	</tr>
    </table>
    <table width="725" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderLEFTRIGHT">
		<tr>
			<td width="12.5" height="25">&nbsp;</td>

    <td colspan="2"><%if(vRetResult.elementAt(25) != null){%>
      Student ID : 
      <%}%>
	<%=WI.getStrValue((String)vRetResult.elementAt(25),"External Pmt")%>
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

    <td width="100" align="left">
      <%if(bolShowLabel){%>
      Recieved from
      <%}%>
      </td>

    <td width="360">
      <%
//if user index is null, the student is ex-studetn, so display only name,
if( vRetResult.elementAt(0) != null){%>
      <%=(String)vRetResult.elementAt(18)%>
      <%}else{%>
      <%=(String)vRetResult.elementAt(1)%>
      <%}%>
    </td>

    <td>
      <%if(bolShowLabel){%>
      Course/Yr
      <%}%>
      </td>

    <td><%=WI.getStrValue((String)vRetResult.elementAt(35),"")%>
	<%=WI.getStrValue((String)vRetResult.elementAt(21)," - ","","")%>
	</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="18">&nbsp;</td>

    <td align="left">
      <%if(bolShowLabel){%>
      The sum of 
      <%}%></td>

    <td colspan="2"><%=new ConversionTable().convertAmoutToFigure(Double.parseDouble((String)vRetResult.elementAt(11)),"Pesos","Centavos")%></td>

    <td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="18">&nbsp;</td>

    <td align="left"><%if(vRetResult.elementAt(28) != null) {%>As Payment of<%}%></td>

    <td colspan="2"><%=WI.getStrValue((String)vRetResult.elementAt(28))%>
	</td>

    <td>&nbsp;</td>
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
              Tuition
<%
strTemp = (String)request.getSession(false).getAttribute("lf_reason");
request.getSession(false).removeAttribute("lf_reason");
if(strTemp != null) {%><%=strTemp%>
<%}%>			  
              <%}else if(vRetResult.elementAt(5) != null){%>
              	<%=(String)vRetResult.elementAt(5)%>
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
    <td width="12">&nbsp;</td>
    <td width="250">&nbsp;</td>
    <td width="210">&nbsp;</td>
    <td width="250" height = "25"><em> 
      <%if(false){%>
      Thank You, 
      <%}%>
      </em></td>
    <td width="12">&nbsp;</td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td> <%if(bolShowLabel && vRetResult.elementAt(14) != null){%>
      CHECK&nbsp;Bank/No: 
      <%}else{%> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
      <%}%> <%=WI.getStrValue(vRetResult.elementAt(34))%> &nbsp; <%=WI.getStrValue(vRetResult.elementAt(14))%> <br></td>
    <td> <%if(bolShowLabel && vRetResult.elementAt(14) != null){%>
      Amount: 
      <%}else{%> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
      <%}%> &nbsp; 
	  <%if(	dChkAmt > 0d){%>
	  <%=CommonUtil.formatFloat(dChkAmt,true)%>
	  <%}else if(vRetResult.elementAt(14) != null){%> <%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%> <%}//show only if check.%></td>
    <td>&nbsp; </td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td valign="BOTTOM"> <%if(bolShowLabel){%>
      CASH Amount: 
      <%}else{%> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
      <%}%> 
	  <%if(	dChkAmt > 0d){%>
	  <%=CommonUtil.formatFloat(dCashAmt,true)%>
	  <%}else if(vRetResult.elementAt(14) == null){%> <%=CommonUtil.formatFloat((String)vRetResult.elementAt(11),true)%> <%}//show only if check.%> </td>
    <td> <%if(false){%>
      Change:&nbsp; <%}%> </td>
    <td align="center" class="thinborderBOTTOM"> <%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td class="thinborderBOTTOM" height="25">&nbsp;</td>
    <td class="thinborderBOTTOM" valign="top"> <%if(bolShowLabel){%>
      Ref no.: 
      <%}%> <%=request.getParameter("or_number")%></td>
    <td class="thinborderBOTTOM">&nbsp;</td>
    <td valign="top" align="center" class="thinborderBOTTOM"> <%if(bolShowLabel){%>
      Cashier 
      <%}%> </td>
    <td class="thinborderBOTTOM">&nbsp;</td>
  </tr>
</table>
<script language="JavaScript">
window.print();
</script>
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
