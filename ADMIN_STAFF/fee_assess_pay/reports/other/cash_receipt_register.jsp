<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Daily cash collection page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.bgColor = "#FFFFFF";
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);

   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);

   	document.getElementById('myADTable3').deleteRow(0);
   	document.getElementById('myADTable3').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	Vector vTuitionFee = null;
	Vector vOtherFee   = null;
	Vector vRetResult  = null;

	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}
	
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main_files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","cash_receipt_register.jsp");
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

	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	DailyCashCollection DCC = new DailyCashCollection();
	if(WI.fillTextValue("date_fr").length() > 0) {
		vRetResult = DCC.viewDailyCashColDetailWNU(dbOP, request);
		if(vRetResult != null) {
			vTuitionFee = (Vector)vRetResult.remove(0);
			vOtherFee   = (Vector)vRetResult.remove(0);
			if(vTuitionFee.size() == 0 && vOtherFee.size() == 0) 
				strErrMsg = "No Result found.";
		}
		else	
			strErrMsg = DCC.getErrMsg();
	}
//System.out.println(vTuitionFee);
//System.out.println(vOtherFee);

%>

<form name="daily_cash" method="post" action="./cash_receipt_register.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          CASH RECEIPT REGISTER::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td style="font-weight:bold; font-size:16px;"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="15%" height="25">Collection Date</td>
      <td height="25" colspan="3"><font size="1">
<%
strTemp = WI.fillTextValue("date_fr");
if(strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);
%>
        <input name="date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('daily_cash.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
        to
        <%
strTemp = WI.fillTextValue("date_to");
%>
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('daily_cash.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
        (for one day, leave to field empty.)
        </font></td>
    </tr>
    <tr>
      <td width="2%" height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td height="25" class="thinborderBOTTOM">&nbsp;<!--Teller ID--></td>
      <td width="13%" height="25" class="thinborderBOTTOM">&nbsp;<!--
<%
strTemp = WI.fillTextValue("col_by");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("userId");
if(strTemp == null)
	strTemp = "";
%>
	  <input name="col_by" type="text" size="16" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      --></td>
      <td width="44%" class="thinborderBOTTOM" style="font-size:9px;">&nbsp;&nbsp;&nbsp;
	  	<input type="image" src="../../../../images/form_proceed.gif">
      </td>
      <td width="26%" class="thinborderBOTTOM">&nbsp;
<%if(vRetResult != null) {%>
	  <a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>
	  <font size="1">click to print</font>
<%}%>
	  </td>
    </tr>
  </table>

<!------------------- display report here ------------------------->
<%if(vRetResult != null) {
int iCurRow = 0;
int iPageCount = 0;
int iMaxRow = 45;

double dTemp         = 0d;
double dRowTotal     = 0d; double dOldAccount = 0d; double dTotTuition = 0d; double dTotMisc = 0d;
String strPaymentFor = null;

while(true && (vTuitionFee.size() > 0 || vOtherFee.size() > 0)) {
++iPageCount;
iCurRow = 0;
if(iPageCount > 1){%>
<DIV style="page-break-after:always">&nbsp;</DIV>
<%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
	  <td width="31%" align="right">&nbsp;</td>
      <td width="45%" align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><i><%=SchoolInformation.getAddressLine1(dbOP,false,false)%><%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false),",","","")%></i></font></font>
		  <br>
		  <font style="font-family:'Century Gothic'"><strong>CASH RECEIPT REGISTER</strong></font></td>
	  <td width="24%">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr valign="bottom">
      <td width="42%" height="24">RUN DATE : <%=WI.getTodaysDateTime()%></td>
      <td width="35%" height="24">Collection Date 
	  	<%=WI.fillTextValue("date_fr")%><%=WI.getStrValue(WI.fillTextValue("date_to"), "-","", "")%>
	  </td>
      <td width="23%" height="24">Teller ID #:<%=WI.getStrValue(WI.fillTextValue("col_by"), "ALL")%></td>
    </tr>
  </table>
  <%if(vTuitionFee.size() > 0) { %>
	  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr align="right" style="font-weight:bold">
		  <td width="25%" height="24" class="thinborderBOTTOM" align="left">College/Deptartment</td>
		  <td width="25%" height="24" class="thinborderBOTTOM">Tuition</td>
		  <td width="25%" height="24" class="thinborderBOTTOM">Old Account</td>
		  <td width="25%" height="24" class="thinborderBOTTOM">Total</td>
		</tr>
	  <%while(vTuitionFee.size() > 0) {
	  ++iCurRow;
	  dOldAccount = 0d;
	  
	  dTemp = ((Double)vTuitionFee.remove(0)).doubleValue();
	  strTemp = (String)vTuitionFee.remove(0);
	  strPaymentFor = (String)vTuitionFee.remove(0);
	  if(strTemp.startsWith("_"))
	  	strTemp = strTemp.substring(2);
	  if(strPaymentFor.equals("10")) {
	  	dOldAccount = dTemp;
		dTemp = 0d;
	  }
	  else {
	  	if(vTuitionFee.size() > 0 && strTemp.equals(vTuitionFee.elementAt(1)) && ((String)vTuitionFee.elementAt(2)).equals("10") ) {
			dOldAccount = ((Double)vTuitionFee.remove(0)).doubleValue(); vTuitionFee.remove(0); vTuitionFee.remove(0);
		}
	  }
	  dTotTuition += dTemp + dOldAccount;
	
	  %>
		<tr align="right">
		  <td height="24" align="left"><%=strTemp%></td>
		  <td><%=CommonUtil.formatFloat(dTemp, true)%></td>
		  <td><%=CommonUtil.formatFloat(dOldAccount, true)%></td>
		  <td><%=CommonUtil.formatFloat(dTemp + dOldAccount, true)%></td>
		</tr>
	  <%}%>
		  <tr valign="bottom" align="right" style="font-weight:bold">
		  <td width="25%" height="24">&nbsp;</td>
		  <td width="25%" height="24">&nbsp;</td>
		  <td width="25%" height="24">Sub Total : </td>
		  <td width="25%" height="24"><%=CommonUtil.formatFloat(dTotTuition, true)%></td>
		</tr>
	  </table>
  <%}%>
  <%if(vOtherFee.size() > 0) {%>
  	  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr style="font-weight:bold">
		  <td width="75%" height="24"><u>Other School Fees : </u></td>
		  <td width="25%" height="24">&nbsp;</td>
		</tr>
  
  <%while(vOtherFee.size() > 0) {
		++iCurRow;
	  dTemp = ((Double)vOtherFee.remove(0)).doubleValue();
	  strTemp = (String)vOtherFee.remove(0);
	  vOtherFee.remove(0);	
	  dTotMisc += dTemp;
	%>
		<tr>
		  <td width="75%" height="24"><%=strTemp%></td>
		  <td width="25%" height="24" align="right"><%=CommonUtil.formatFloat(dTemp, true)%></td>
		</tr>
  
  <%if(iCurRow >= iMaxRow)
  		break;
   	}//end of while.
	if(vOtherFee.size() == 0) {%>
		<tr align="right" style="font-weight:bold">
		  <td width="75%" height="24">Sub Total : </td>
		  <td width="25%" height="24"><%=CommonUtil.formatFloat(dTotMisc, true)%></td>
		</tr>
		<tr align="right" style="font-weight:bold">
		  <td width="75%" height="24">Grand Total : </td>
		  <td width="25%" height="24"><%=CommonUtil.formatFloat(dTotTuition + dTotMisc, true)%></td>
		</tr>
	<%}//i have to show sub total and GT.. %>
	</table>
  <%}//end of if vOtherFee > 0%>

<%}//end of out while.. 

}//end of main loop .. if vRetResult != null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
