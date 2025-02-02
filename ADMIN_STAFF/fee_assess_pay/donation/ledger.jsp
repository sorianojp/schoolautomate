<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>STUDENT LEDGER</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PrintPg()
{
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
	{
		var pgLoc = "./ledger_print.jsp?stud_id="+escape(document.form_.stud_id.value);

		var win=window.open(pgLoc,"PrintWindow",'width=900,height=500,scrollbars=yes,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
function FocusID() {
	document.form_.stud_id.focus();
}
function EditRecord(strIndex) {
	var pgLoc = "./payment_modification.jsp?info_index="+strIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=500,scrollbars=yes,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
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
<form name="form_" action="./ledger.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF"><strong>::::
          STUDENT'S COMPLETE DONATION LEDGER PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp; <font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="13" height="25">&nbsp;</td>
      <td width="101">Student ID &nbsp;</td>
      <td width="148"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
      </td>
      <td width="37"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="364"><input type="image" src="../../../images/form_proceed.gif"></td>
    </tr>
 <!--   <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4"><font size="3" color="#0000FF"> <strong>NOTE : If account
        carried over balance is incorrect , click update button to fix.</strong></font></td>
    </tr>-->
  </table>
<%
if(vBasicInfo != null && vBasicInfo.size() > 0 ){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="37%" height="25">Student name :<strong> <%=(String)vBasicInfo.elementAt(1)%></strong></td>
      <td width="61%" height="25"  colspan="4">Current Sch Yr, Year,Term :<strong>
	  <%=(String)vBasicInfo.elementAt(8) + " - " +(String)vBasicInfo.elementAt(9)%>,
        <%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue((String)vBasicInfo.elementAt(4),"0"))]%>, <%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%></strong> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5">Course/Major :<strong> <%=(String)vBasicInfo.elementAt(2)%>
        <%
	  if(vBasicInfo.elementAt(3) != null){%>
        /<%=WI.getStrValue(vBasicInfo.elementAt(3))%>
        <%}%>
        </strong></td>
    </tr>
  </table>
<%
if(vLedgerInfo != null && vLedgerInfo.size() > 0){%>
  <table   width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="#808080">
    <tr bgcolor="#FFFFAF">
      <td width="15%" height="25" align="center"><font size="1"><strong>DATE</strong></font></td>
      <td align="center" width="43%" ><font size="1"><strong>PARTICULARS</strong></font></td>
      <td width="10%" align="center"><font size="1"><strong>COLLECTED BY ID</strong></font></td>
      <td width="11%" align="center"><font size="1"><strong>DEBIT</strong></font></td>
      <td width="11%" align="center"><font size="1"><strong>CREDIT</strong></font></td>
      <td width="15%" align="center"><font size="1"><strong>BALANCE</strong></font></td>
      <td width="10%" align="center"><strong><font size="1">EDIT</font></strong></td>
    </tr>
    <%
for(int i = 0; i< vLedgerInfo.size() ; i += 10)
{%>
    <tr bgcolor="#FFFFFF">
      <td height="25" align="center">&nbsp; <%if(vLedgerInfo.elementAt(i + 3) == null){%> <%=(String)vLedgerInfo.elementAt(i + 4)%>
        <%}else{%> <%=(String)vLedgerInfo.elementAt(i + 3)%>
        <%}%></td>
      <td align="center"><%=WI.getStrValue(vLedgerInfo.elementAt(i + 5))%> <%if(vLedgerInfo.elementAt(i + 5) != null){%> <%=WI.getStrValue((String)vLedgerInfo.elementAt(i + 6),"(",")","")%>
        <%}%></td>
      <td align="center"><%=WI.getStrValue(vLedgerInfo.elementAt(i + 8))%></td>
      <td align="center"><%=WI.getStrValue(vLedgerInfo.elementAt(i + 1))%></td>
      <td align="center"><%=WI.getStrValue(vLedgerInfo.elementAt(i + 2))%></td>
      <td align="center"><%=WI.getStrValue(vLedgerInfo.elementAt(i + 9))%></td>
      <td align="center">
	  <a href='javascript:EditRecord("<%=(String)vLedgerInfo.elementAt(i)%>");'>
	  <img src="../../../images/edit.gif" border="0"></a></td>
    </tr>
    <%}%>
  </table>


<%}//end of displaying new ledger info.%>










  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
      <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="4" height="25"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click
        to print ledger</font></td>
      <td colspan="3" height="25">&nbsp;</td>
    </tr>
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="user_index" value="<%=(String)vBasicInfo.elementAt(0)%>">

<%} //only if basic info is not null -- the biggest and outer loop.;
%>

<input type="hidden" name="update_balance">
<input type="hidden" name="ledg_hist_index">
<input type="hidden" name="excess_amt">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
