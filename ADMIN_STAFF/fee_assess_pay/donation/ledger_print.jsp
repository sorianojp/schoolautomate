<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>STUDENT LEDGER</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
-->
</style>
</head>
<body>
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FADonation,java.util.Vector,java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
	String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr",
        				"5th Yr","6th Yr","7th Yr","8th Yr"};

	boolean bolProceed = true;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Donation","ledger.jsp");
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
														"Fee Assessment & Payments","DONATION",request.getRemoteAddr(),
														"ledger.jsp");
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

Vector vBasicInfo = null;
Vector vLedgerInfo = null;

FAPaymentUtil paymentUtil = new FAPaymentUtil();
FADonation faDonation = new FADonation();

if(WI.fillTextValue("stud_id").length() > 0) {
	vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
	if(vBasicInfo == null) //may be it is the teacher/staff
		strErrMsg = paymentUtil.getErrMsg();
}
if(vBasicInfo != null) {
	vLedgerInfo = faDonation.viewLedger(dbOP, WI.fillTextValue("stud_id"));
	if(vLedgerInfo == null)
		strErrMsg = faDonation.getErrMsg();
}


%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#CCCCCC">
      <td width="100%" height="20"><div align="center"><strong>:::: 
          STUDENT'S COMPLETE DONATION LEDGER PAGE ::::</strong></div></td>
    </tr>
    <tr>
      <td height="20">&nbsp;&nbsp;&nbsp; <font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

<%
if(vBasicInfo != null && vBasicInfo.size() > 0 ){%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="20">&nbsp;</td>
    <td height="20">Student ID : <strong><%=WI.fillTextValue("stud_id")%></strong></td>
    <td height="20"  colspan="4">&nbsp;</td>
  </tr>
  <tr> 
    <td  width="2%" height="20">&nbsp;</td>
    <td width="37%" height="20">Student name :<strong> <%=(String)vBasicInfo.elementAt(1)%></strong></td>
    <td width="61%" height="20"  colspan="4">Current Sch Yr, Year,Term :<strong> 
      <%=(String)vBasicInfo.elementAt(8) + " - " +(String)vBasicInfo.elementAt(9)%>, <%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue((String)vBasicInfo.elementAt(4),"0"))]%>, <%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%></strong> </td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td height="20" colspan="5">Course/Major :<strong> <%=(String)vBasicInfo.elementAt(2)%> 
      <%
	  if(vBasicInfo.elementAt(3) != null){%>
      /<%=WI.getStrValue(vBasicInfo.elementAt(3))%> 
      <%}%>
      </strong></td>
  </tr>
</table>
<%
if(vLedgerInfo != null && vLedgerInfo.size() > 0){%>
  <table   width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#ffffff" class="thinborder">
    <tr bgcolor="#FFFFAF">
      <td width="10%" height="20" align="center" class="thinborder"><font size="1"><strong>DATE</strong></font></td>
      <td align="center" width="43%" class="thinborder"><font size="1"><strong>PARTICULARS</strong></font></td>
      
    <td width="10%" align="center" class="thinborder"><font size="1"><strong>POSTED/ COLLECTED BY</strong></font></td>
      <td width="11%" align="center" class="thinborder"><font size="1"><strong>DEBIT</strong></font></td>
      <td width="11%" align="center" class="thinborder"><font size="1"><strong>CREDIT</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>BALANCE</strong></font></td>
    </tr>
    <%
for(int i = 0; i< vLedgerInfo.size() ; i += 10)
{%>
    <tr>
      <td height="20" align="center" class="thinborder">&nbsp;
	  <%if(vLedgerInfo.elementAt(i + 3) == null){%>
	  <%=(String)vLedgerInfo.elementAt(i + 4)%><%}else{%>
	   <%=(String)vLedgerInfo.elementAt(i + 3)%><%}%></td>
      <td align="center" class="thinborder">&nbsp;<%=WI.getStrValue(vLedgerInfo.elementAt(i + 5))%>
	  <%if(vLedgerInfo.elementAt(i + 5) != null){%>
	  <%=WI.getStrValue((String)vLedgerInfo.elementAt(i + 6),"(",")","")%><%}%></td>
      <td align="center" class="thinborder">&nbsp;<%=WI.getStrValue(vLedgerInfo.elementAt(i + 8))%></td>
      <td align="center" class="thinborder">&nbsp;<%=WI.getStrValue(vLedgerInfo.elementAt(i + 1))%></td>
      <td align="center" class="thinborder">&nbsp;<%=WI.getStrValue(vLedgerInfo.elementAt(i + 2))%></td>
      <td align="center" class="thinborder">&nbsp;<%=WI.getStrValue(vLedgerInfo.elementAt(i + 9))%></td>
    </tr>
<%}%>
  </table>


<%}//end of displaying new ledger info.%>

  </table>
<script language="JavaScript">
	window.print();
</script>
<%} //only if basic info is not null -- the biggest and outer loop.;
%>

</body>
</html>
<%
dbOP.cleanUP();
%>
