<%@ page language="java" import="utility.*, Accounting.CashReceiptBook, java.util.Vector" %>
<%
String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
if(strAuthTypeIndex == null || strAuthTypeIndex.equals("4")){%>
	<p style="font-size:14px; font-weight:bold;">You are logged out. Please login again."</p>
<%return;}

WebInterface WI = new WebInterface(request);
DBOperation dbOP = new DBOperation();
String strErrMsg = null;

CashReceiptBook CRB = new CashReceiptBook();
    Vector vMainInfo = new Vector();//[0] teller Index, [1] or range, [2] trans_date, [3] cash on hand [4] cash short, [5] total cash
    Vector vTeller   = new Vector();//[0] teller Index, [1] name,     [2] Id.
    Vector vTuition  = new Vector();//[0] date paid,    [1] amount,   [2] teller index

    Vector vTransDate = new Vector();//[0] transaction_date
    Vector vFeeInfo   = new Vector();//[0] fee_name
    Vector vFeeInfoCoa= new Vector();//[0] fee_name, [1] coa
	Vector vFeeCollected = new Vector();//[0] teller_index, [1] date paid, [2] fee_name [3] amount.


Vector vRetResult = CRB.getCashReceiptReportPerTeller(dbOP, request);
if(vRetResult == null)
	strErrMsg = CRB.getErrMsg();
else {
	vMainInfo     = (Vector)vRetResult.remove(0);
	vTeller       = (Vector)vRetResult.remove(0);
	vTuition      = (Vector)vRetResult.remove(0);
	vTransDate    = (Vector)vRetResult.remove(0);
	vFeeInfo      = (Vector)vRetResult.remove(0);
	vFeeInfoCoa   = (Vector)vRetResult.remove(0);
	vFeeCollected = (Vector)vRetResult.remove(0);
}

//System.out.println(vFeeCollected);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../../jscript/common.js"></script>
<script language="javascript">

</script>
<body <%if(WI.fillTextValue("print_stat").equals("1")){%> onLoad="window.print();"<%}%>>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25" align="center" style="font-weight:bold"> <strong>::::  CASH RECEIPTS BOOK  ::::</td>
  </tr>
  <%if(strErrMsg != null) {%>
	  <tr bgcolor="#FFFFFF">
		<td height="25"><font size="2"><strong><font color="#0000FF"><%=strErrMsg%></font></strong></font></td>
	  </tr>
  <%}else{%>
	  <tr bgcolor="#FFFFFF">
		<td height="25"><font size="2"><strong><font color="#0000FF"><%=request.getAttribute("report_format")%></font></strong></font></td>
	  </tr>
  <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold;" align="center">
      <td height="20" class="thinborder" width="7%"><font size="1">DATE</font></td>
      <td class="thinborder" width="8%"><font size="1">TELLER ID</font></td>
      <td class="thinborder" width="10%"><font size="1">OR NUMBER</font></td>
      <td class="thinborder" width="5%"><font size="1">CASH ON HAND</font></td>
      <td class="thinborder" width="5%"><font size="1">TOTAL COLLECTION</font></td>
      <td class="thinborder" width="5%"><font size="1">CASH SHORT/OVER</font></td>
      <td class="thinborder" width="5%"><font size="1">AR STUDENT</font></td>
<%for(int p = 0; p < vFeeInfo.size(); p += 2) {%>
      <td class="thinborder" width="5%"><font size="1"><%=vFeeInfo.elementAt(p)%></font></td>
<%}%>
    </tr>
<%
int iIndexOf = 0; int iIndexOf2 = 0;
String strTeller  = null;
String strTuition = null;
String strTellerIndex = null;

String strOthSchFee = null;


double dCashOnHand = 0d;
double dTotalCol   = 0d;
double dCashShort  = 0d;
double dARStudent  = 0d;


//System.out.println(vTuition);

for(int i = 0; i < vTransDate.size(); ++i) {
	iIndexOf = vMainInfo.indexOf((String)vTransDate.elementAt(i));
	if(iIndexOf == -1)
		continue;
	
	strTellerIndex = (String)vMainInfo.elementAt(iIndexOf - 2);
	
	iIndexOf2 = vTeller.indexOf(strTellerIndex);
	if(iIndexOf2 == -1)
		strTeller = null;
	else	
		strTeller = (String)vTeller.elementAt(iIndexOf2 + 2);
	
	//get tuition fee.
	strTuition = null;
	iIndexOf2 = vTuition.indexOf(strTellerIndex);
	if(iIndexOf2 > -1) {
		if(vTuition.elementAt(iIndexOf2 - 2).equals(vTransDate.elementAt(i))) {
			strTuition = (String)vTuition.elementAt(iIndexOf2 - 1);
			vTuition.remove(iIndexOf2 -2);vTuition.remove(iIndexOf2 -2);vTuition.remove(iIndexOf2 -2);
		}
		
	}


dCashOnHand += Double.parseDouble(ConversionTable.replaceString((String)vMainInfo.elementAt(iIndexOf + 1), ",","")) ;
dTotalCol   += Double.parseDouble(ConversionTable.replaceString((String)vMainInfo.elementAt(iIndexOf + 3), ",","")) ;
dCashShort  += Double.parseDouble(ConversionTable.replaceString((String)vMainInfo.elementAt(iIndexOf + 2), ",","")) ;
dARStudent  += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTuition, "0"), ",","")) ;
%>
    <tr>
      <td height="20" class="thinborder"><%=vTransDate.elementAt(i)%></td>
      <td class="thinborder"><%=strTeller%></td>
      <td class="thinborder"><%=vMainInfo.elementAt(iIndexOf - 1)%></td>
      <td class="thinborder" align="right"><%=vMainInfo.elementAt(iIndexOf + 1)%></td>
      <td class="thinborder" align="right"><%=vMainInfo.elementAt(iIndexOf + 3)%></td>
      <td class="thinborder" align="right"><%=vMainInfo.elementAt(iIndexOf + 2)%></td>
      <td class="thinborder" align="right"><%=WI.getStrValue(strTuition, "&nbsp;")%></td>
<%for(int p = 0; p < vFeeInfo.size(); p += 2) {
iIndexOf2 = vFeeCollected.indexOf(strTellerIndex);
strOthSchFee = null;

if(iIndexOf2 > -1) {
	//check if date matching and fee name matching.. 
	if(vFeeCollected.elementAt(iIndexOf2 + 1).equals(vTransDate.elementAt(i)) && 
		vFeeCollected.elementAt(iIndexOf2 + 2).equals(vFeeInfo.elementAt(p)) ) {
		strOthSchFee = (String)vFeeCollected.elementAt(iIndexOf2 + 3);
		
		vFeeCollected.remove(iIndexOf2);vFeeCollected.remove(iIndexOf2);
		vFeeCollected.remove(iIndexOf2);vFeeCollected.remove(iIndexOf2);
	}
}
%>
      <td class="thinborder" width="5%" align="right"><font size="1"><%=WI.getStrValue(strOthSchFee, "&nbsp;")%></font></td>
<%}%>
    </tr>
<%
iIndexOf = iIndexOf - 2;
vMainInfo.remove(iIndexOf);vMainInfo.remove(iIndexOf);vMainInfo.remove(iIndexOf);
vMainInfo.remove(iIndexOf);vMainInfo.remove(iIndexOf);vMainInfo.remove(iIndexOf);





///repeat for multiple tellers.. 
while(true) {
	iIndexOf = vMainInfo.indexOf((String)vTransDate.elementAt(i));
	if(iIndexOf == -1)
		break;

	strTellerIndex = (String)vMainInfo.elementAt(iIndexOf - 2);
	
	iIndexOf2 = vTeller.indexOf(strTellerIndex);
	if(iIndexOf2 == -1)
		strTeller = null;
	else	
		strTeller = (String)vTeller.elementAt(iIndexOf2 + 2);
	
	//get tuition fee.
	strTuition = null;
	iIndexOf2 = vTuition.indexOf(strTellerIndex);
	if(iIndexOf2 > -1) {
		if(vTuition.elementAt(iIndexOf2 - 2).equals(vTransDate.elementAt(i))) {
			strTuition = (String)vTuition.elementAt(iIndexOf2 - 1);
			vTuition.remove(iIndexOf2 -2);vTuition.remove(iIndexOf2 -2);vTuition.remove(iIndexOf2 -2);
		}
		
	}
dCashOnHand += Double.parseDouble(ConversionTable.replaceString((String)vMainInfo.elementAt(iIndexOf + 1), ",","")) ;
dTotalCol   += Double.parseDouble(ConversionTable.replaceString((String)vMainInfo.elementAt(iIndexOf + 3), ",","")) ;
dCashShort  += Double.parseDouble(ConversionTable.replaceString((String)vMainInfo.elementAt(iIndexOf + 2), ",","")) ;
dARStudent  += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTuition, "0"), ",","")) ;
%>
    <tr>
      <td height="20" class="thinborder">&nbsp;</td>
      <td class="thinborder"><%=strTeller%></td>
      <td class="thinborder"><%=vMainInfo.elementAt(iIndexOf - 1)%></td>
      <td class="thinborder" align="right"><%=vMainInfo.elementAt(iIndexOf + 1)%></td>
      <td class="thinborder" align="right"><%=vMainInfo.elementAt(iIndexOf + 3)%></td>
      <td class="thinborder" align="right"><%=vMainInfo.elementAt(iIndexOf + 2)%></td>
      <td class="thinborder" align="right"><%=WI.getStrValue(strTuition, "&nbsp;")%></td>
<%for(int p = 0; p < vFeeInfo.size(); p += 2) {
iIndexOf2 = vFeeCollected.indexOf(strTellerIndex);
strOthSchFee = null;

if(iIndexOf2 > -1) {
	//check if date matching and fee name matching.. 
	if(vFeeCollected.elementAt(iIndexOf2 + 1).equals(vTransDate.elementAt(i)) && 
		vFeeCollected.elementAt(iIndexOf2 + 2).equals(vFeeInfo.elementAt(p)) ) {
		strOthSchFee = (String)vFeeCollected.elementAt(iIndexOf2 + 3);
		
		vFeeCollected.remove(iIndexOf2);vFeeCollected.remove(iIndexOf2);
		vFeeCollected.remove(iIndexOf2);vFeeCollected.remove(iIndexOf2);
	}
}
%>
      <td class="thinborder" width="5%" align="right"><font size="1"><%=WI.getStrValue(strOthSchFee, "&nbsp;")%></font></td>
<%}
iIndexOf = iIndexOf - 2;
vMainInfo.remove(iIndexOf);vMainInfo.remove(iIndexOf);vMainInfo.remove(iIndexOf);
vMainInfo.remove(iIndexOf);vMainInfo.remove(iIndexOf);vMainInfo.remove(iIndexOf);
%>
    </tr>
<%}//while (true)


}//end of loop transaction date.%>    
    <tr>
      <td height="20" class="thinborder">TOTAL</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dCashOnHand, true)%></td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTotalCol, true)%></td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dCashShort, true)%></td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dARStudent, true)%></td>
<%for(int p = 0; p < vFeeInfo.size(); p += 2) {%>
      <td class="thinborder" width="5%" align="right"><font size="1"><%=vFeeInfo.elementAt(p + 1)%></font></td>
<%}%>
    </tr>
  </table>
</body>
</html>
<%
dbOP.cleanUP();
%>