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
<body bgcolor="#FFFFFF" onLoad="window.print();">
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
	String strAuthID = (String)request.getSession(false).getAttribute("userIndex");
	

if(WI.fillTextValue("date_fr").length() > 0) {
	if(WI.fillTextValue("date_to").length() > 0)
		strExtraCon = " and date_paid between '"+ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_fr"), false)+"' and '"+
						ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_to"), false)+"' ";
	else
		strExtraCon = " and date_paid = '"+ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_fr"), false)+"' ";
	
	strSQLQuery = "select date_paid, fa_stud_payment.created_by,createdBy.id_number, or_number, amount, "+
					"null, null from fa_stud_payment "+
					" join user_table as createdBy on (createdBy.user_index = fa_stud_payment.created_by) "+
					" where fa_stud_payment.or_number is not null and fa_stud_payment.is_valid = 1 and "+
					"fa_stud_payment.amount > 0 "+strExtraCon+" and auf_ledg_printed_manual = "+strAuthID+" order by createdBy.id_number, date_paid, or_number";
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
      <td width="50%" style="font-weight:bold">Grand Total: <%=CommonUtil.formatFloat(dGT, true)%></td>
      <td width="50%" style="font-weight:bold" align="right">Printed By: <%=request.getSession(false).getAttribute("first_name")%></td>
    </tr>
  </table>

<%//}//end of out while.. 

}//end of main loop .. if vRetResult != null%>
</body>
</html>
<%
dbOP.cleanUP();
%>
