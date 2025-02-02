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
   	document.getElementById('myADTable2').deleteRow(0);

   	document.getElementById('myADTable3').deleteRow(0);
   	document.getElementById('myADTable3').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
</script>
<body bgcolor="#FFFFFF">
<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

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
								"Admin/staff-Fee Assessment & Payments-REPORTS","auf_posted_to_ledger_print.jsp");
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

	Vector vRetResult  = new Vector();
	Vector vTellerInfo = new Vector();
	
String strSQLQuery = null;
String strExtraCon = "";
int iIndexOf = 0; 
double dGT = 0d;


if(WI.fillTextValue("date_fr").length() > 0) {
	if(WI.fillTextValue("date_to").length() > 0)
		strExtraCon = " and date_paid between '"+ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_fr"), false)+"' and '"+
						ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_to"), false)+"' ";
	else
		strExtraCon = " and date_paid = '"+ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_fr"), false)+"' ";
	
	if(WI.fillTextValue("emp_id").length() > 0) {
		strTemp = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
		if(strTemp != null)
			strExtraCon += " and created_by = "+strTemp;
	}
	if(WI.fillTextValue("show_all_").length() == 0) 
		strExtraCon += " and (auf_ledg_printed_by is null or auf_ledg_printed_by = "+(String)request.getSession(false).getAttribute("userIndex")+")";
	if(WI.fillTextValue("inc_empty_posted_").length() > 0) 
		strTemp = " left ";
	else	
		strTemp = "";
	
	strSQLQuery = "select date_paid, fa_stud_payment.created_by,createdBy.id_number, or_number, amount, "+
					"postedBy.id_number, auf_ledg_printed_date from fa_stud_payment "+
					" join user_table as createdBy on (createdBy.user_index = fa_stud_payment.created_by) "+
					strTemp+" join user_table as postedBy on (postedBy.user_index = auf_ledg_printed_by) "+
					" where fa_stud_payment.or_number is not null and fa_stud_payment.is_valid = 1 and "+
					"fa_stud_payment.amount > 0 "+strExtraCon+" order by createdBy.id_number, date_paid, or_number";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	double dTemp = 0d;
	while(rs.next()) {
		vRetResult.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(1)));//[0] date_paid
		vRetResult.addElement(new Integer(rs.getInt(2)));//[1] created_by
		vRetResult.addElement(rs.getString(3));//[2] createdBy.id_number
		vRetResult.addElement(rs.getString(4));//[3] or_number
		vRetResult.addElement(CommonUtil.formatFloat(rs.getDouble(5), true));//[4] amount
		dGT += rs.getDouble(5);
		
		vRetResult.addElement(rs.getString(6));//[5] id_number
		vRetResult.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(7)));//[6] auf_ledg_printed_date
		
		iIndexOf = vTellerInfo.indexOf(new Integer(rs.getInt(2)));
		if(iIndexOf == -1) {
			vTellerInfo.addElement(new Integer(rs.getInt(2)));
			vTellerInfo.addElement(new Double(rs.getDouble(5)));
		}
		else {
			dTemp = ((Double)vTellerInfo.elementAt(iIndexOf + 1)).doubleValue() + rs.getDouble(5);
			
			vTellerInfo.setElementAt(new Double(dTemp), iIndexOf + 1);
		}
	}					
	rs.close();	
	if(vRetResult.size() == 0) 
		strErrMsg = "No Result found.";	
}




%>

<form name="form_" method="post" action="./auf_posted_to_ledger_print.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          POSTED TO LEDGER ::::</strong></font></div></td>
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
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
        to
        <%
strTemp = WI.fillTextValue("date_to");
%>
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
        (for one day, leave to field empty.)
		
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="./auf_posted_to_ledger_print2.jsp">Go to Assign Manual Posting</a>
        </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Teller's ID </td>
      <td height="25" colspan="3" style="font-size:9px;">
	  <input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> (Optional)
	  &nbsp;&nbsp;&nbsp;
	  <input type="checkbox" name="show_all_" value="checked" <%=WI.fillTextValue("show_all_")%>> Show ALL
	  &nbsp;&nbsp;&nbsp;
	  <input type="checkbox" name="inc_empty_posted_" value="checked" <%=WI.fillTextValue("inc_empty_posted_")%>> 
	  Include records without posted by entry
	  
	  
	  </td>
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
	  	<input type="image" src="../../../../images/form_proceed.gif">      </td>
      <td width="26%" class="thinborderBOTTOM">&nbsp;
<%if(vRetResult != null) {%>
	  <a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>
	  <font size="1">click to print</font>
<%}%>	  </td>
    </tr>
  </table>

<!------------------- display report here ------------------------->
<%if(vRetResult != null && vRetResult.size() > 0) {
int iCurRow = 0;
int iPageCount = 0;
int iMaxRow = 45;
String strDatePrinted = WI.getTodaysDateTime();
boolean bolIsEnd = false;


while(vTellerInfo.size() > 0) {
++iPageCount;
iCurRow = 0;
if(iPageCount > 1){%>
<%="</table>"%>
<DIV style="page-break-after:always">&nbsp;</DIV>
<%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
	  <td width="20%" align="right">&nbsp;</td>
      <td width="60%" align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><i><%=SchoolInformation.getAddressLine1(dbOP,false,false)%><%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false),",","","")%></i></font></font>
		  <br>
		  <font style="font-family:'Century Gothic'"><strong>Daily Summary Report of Posted to Ledger</strong></font></td>
	  <td width="20%">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr valign="bottom">
      <td align="right" style="font-size:9px;">Date Time Printed  : <%=strDatePrinted%></td>
    </tr>
  </table>
  <%//while(vTellerInfo.size() > 0) {%>
	  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr style="font-weight:bold">
		  <td width="15%" height="24" class="thinborderTOPBOTTOM">OR Date</td>
		  <td width="15%" class="thinborderTOPBOTTOM">Cashier #</td>
		  <td width="15%" class="thinborderTOPBOTTOM">OR Number </td>
		  <td width="20%" class="thinborderTOPBOTTOM" align="right">Amount</td>
		  <td width="15%" class="thinborderTOPBOTTOM" align="center">Posted By</td>
		  <td width="20%" class="thinborderTOPBOTTOM">Date Posted</td>
		</tr>
	  <%while(vRetResult.size() > 0) {
		  iIndexOf = vRetResult.indexOf(vTellerInfo.elementAt(0));
		  if(iIndexOf == -1)
		  	break;
			
		  ++iCurRow;
	  %>
		<tr>
		  <td height="24"><%=vRetResult.elementAt(iIndexOf - 1)%></td>
		  <td><%=vRetResult.elementAt(iIndexOf + 1)%></td>
		  <td><%=vRetResult.elementAt(iIndexOf + 2)%></td>
		  <td align="right"><%=vRetResult.elementAt(iIndexOf + 3)%></td>
		  <td align="center"><%=WI.getStrValue(vRetResult.elementAt(iIndexOf + 4), "&nbsp;")%></td>
		  <td><%=WI.getStrValue(vRetResult.elementAt(iIndexOf + 5), "&nbsp;")%></td>
		</tr>
	  <%
	  	iIndexOf = iIndexOf - 1;
	  	vRetResult.remove(iIndexOf);vRetResult.remove(iIndexOf);vRetResult.remove(iIndexOf);vRetResult.remove(iIndexOf);
	  	vRetResult.remove(iIndexOf);vRetResult.remove(iIndexOf);vRetResult.remove(iIndexOf);
	  	if(iCurRow >= iMaxRow)
			break;
	  }
	  if(iIndexOf == -1 || vRetResult.size() == 0) {%>
		  <tr valign="bottom" align="right" style="font-weight:bold">
		  <td height="24">&nbsp;</td>
		  <td colspan="2">Total Payments Posted </td>
		  <td align="right" style="font-weight:bold"><%=CommonUtil.formatFloat(((Double)vTellerInfo.elementAt(1)).doubleValue(), true)%></td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
	    </tr>
		  <tr valign="bottom" align="right" style="font-weight:bold">
		  <td height="24" colspan="6">&nbsp;</td>
	    </tr>
	  </table>
	 <%vTellerInfo.remove(0);vTellerInfo.remove(0);
	 	iCurRow += 2;
	 	if((iCurRow + 2) >= iMaxRow)
			break;
	 }%>
	 
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td colspan="8" style="font-weight:bold">Grand Total: <%=CommonUtil.formatFloat(dGT, true)%></td>
    </tr>
  </table>

<%//}//end of out while.. 

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
