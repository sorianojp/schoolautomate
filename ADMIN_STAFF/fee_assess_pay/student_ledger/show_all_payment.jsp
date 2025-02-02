<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>

<body>
<%@ page language="java" import="utility.*,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & STUDENT LEDGER-view all Payment","show_all_payment.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","STUDENT LEDGER",request.getRemoteAddr(),
														"show_all_payment.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String strStudIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
if(strStudIndex == null)
	strErrMsg = "Student Id not found.";

if(strErrMsg != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><%=strErrMsg%></strong></td>
    </tr>
  </table>
<%}
if(strStudIndex	!= null){%>
<table   width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>COUNT</strong></font></td>
      <td width="10%" height="22" align="center" class="thinborder"><font size="1"><strong>DATE</strong></font></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>TELLER</strong></font></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>OR NUMBER</strong></font></td>
      <td align="center" width="50%" class="thinborder"><font size="1"><strong>PARTICULARS</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>AMOUNT PAID </strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>SY-TERM</strong></font></td>
    </tr>

<%
Vector vPmtSchedule = new Vector();
Vector vOthSchFee   = new Vector();
String strSQLQuery  = null;
java.sql.ResultSet rs = null;
int iCount = 0;

strSQLQuery = "select pmt_sch_index, exam_name from fa_pmt_schedule";
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	vPmtSchedule.addElement(rs.getString(1));//[0] pmt_sch_index
	vPmtSchedule.addElement(rs.getString(2));//[1] exam_name
}
rs.close();

strSQLQuery = "select othsch_fee_index,fee_name from fa_oth_sch_fee";
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	vOthSchFee.addElement(rs.getString(1));//[0] pmt_sch_index
	vOthSchFee.addElement(rs.getString(2));//[1] exam_name
}
rs.close();



strSQLQuery = "select date_paid, or_number, teller.id_number, teller.fname, teller.mname, teller.lname, payment_for, multiple_pmt_note, "+//8
			"othsch_fee_index,sy_from, semester,pmt_sch_index, amount from fa_stud_payment "+//13
			"join user_table as teller on (teller.user_index = created_by) "+
			"where fa_stud_payment.user_index = "+strStudIndex+" and is_stud_temp = 0 and fa_stud_payment.is_valid = 1 and amount > 0 "+
			"and or_number is not null order by date_paid desc";
rs = dbOP.executeQuery(strSQLQuery);
int iIndexOf = 0; String strBGColor = null;
while(rs.next()){
strBGColor = "";

strTemp = rs.getString(7);
if(strTemp.equals("0")) {
	strTemp = "Tuition - ";
	if(rs.getInt(12) == 0)
		strTemp += "Downpayment";
	else {
		iIndexOf = vPmtSchedule.indexOf(rs.getString(12));
		if(iIndexOf > -1) 
			strTemp += (String)vPmtSchedule.elementAt(iIndexOf + 1);
	}
}
else if(strTemp.equals("10")) {
	strTemp = "Back Account";
	strBGColor = " bgcolor='#0099FF'";
}
else if(strTemp.equals("1")) {
	strTemp = "Other School Fee - ";
		iIndexOf = vOthSchFee.indexOf(rs.getString(9));
		if(iIndexOf > -1) 
			strTemp += (String)vOthSchFee.elementAt(iIndexOf + 1);
	strBGColor = " bgcolor='#CCCCCC'";
}
else if(strTemp.equals("8")) {
	strTemp = "Multiple Payment - Details <br>"+rs.getString(8);
	strBGColor = " bgcolor='#CCCCCC'";
}

%>
    <tr<%=strBGColor%>>
      <td class="thinborder"><%=++iCount%>.</td>
      <td height="22" class="thinborder"><%=ConversionTable.convertMMDDYYYY(rs.getDate(1))%></td>
      <td class="thinborder"><%=rs.getString(6)%></td>
      <td class="thinborder"><%=rs.getString(2)%></td>
      <td class="thinborder"><%=strTemp%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(rs.getDouble(13), true)%></td>
      <td class="thinborder"><%=rs.getString(10)%>-<%=rs.getString(11)%></td>
    </tr>
<%}
rs.close();
%>
  </table>
<%
}//if ShowLedgerDetail is 1
%>
</body>
</html>
<%
dbOP.cleanUP();
%>
