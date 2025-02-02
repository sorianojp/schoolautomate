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
		var pgLoc = "./student_ledger_viewall_print.jsp?stud_id="+escape(document.stud_ledg.stud_id.value);

		var win=window.open(pgLoc,"PrintWindow",'width=900,height=500,scrollbars=yes,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
function UpdateBalance(strLedgHistIndex, strExcessAmt) {
	document.stud_ledg.update_balance.value = "1";
	document.stud_ledg.ledg_hist_index.value = strLedgHistIndex;
	document.stud_ledg.excess_amt.value = strExcessAmt;
	document.stud_ledg.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAStudentLedger,java.util.Vector,java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr",
        				"5th Yr","6th Yr","7th Yr","8th Yr"};

	boolean bolProceed = true;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-Student ledger","student_ledger_viewall.jsp");
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
														"student_ledger_viewall.jsp");
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
Vector vOldLedgerSYInfo = null;//records curriculum hist detail.

Vector vLedgerInfo = null;Vector vLedgerHist = null;
FAStudentLedger faStudLedg = new FAStudentLedger();
basicEdu.UserInformation basicUserInfo = new basicEdu.UserInformation();

if(WI.fillTextValue("stud_id").length() > 0) {
	vBasicInfo = basicUserInfo.operateOnBasicInfo(dbOP, request, 4);
	if(vBasicInfo == null) //may be it is the teacher/staff
		strErrMsg = basicUserInfo.getErrMsg();
}
if(vBasicInfo != null) {
	//i have to update the outstanding balance if update is clicked.
	vOldLedgerSYInfo = faStudLedg.getSYInfoOfOldLedger(dbOP,(String)vBasicInfo.elementAt(0));
	if(vOldLedgerSYInfo == null)
		strErrMsg = faStudLedg.getErrMsg();
}


%>
<form name="stud_ledg" action="./basic_old_stud_ledger_viewall.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF"><strong>:::: 
          STUDENT'S COMPLETE LEDGER PAGE (BASIC EDUCATION)::::</strong></font></div></td>
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
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td width="37">&nbsp;</td>
      <td width="364"><input type="image" src="../../../images/form_proceed.gif"></td>
    </tr>
 <!--   <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4"><font size="3" color="#0000FF"> <strong>NOTE : If account
        carried over balance is incorrect , click update button to fix.</strong></font></td>
    </tr>-->
  </table>
<%
if(vBasicInfo != null && vBasicInfo.size() > 0 && vOldLedgerSYInfo != null && vOldLedgerSYInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="41%" height="25">Student name :<strong> <font size="1">
	  <%=(String)vBasicInfo.elementAt(1)%></font></strong></td>
      <td width="57%" height="25"  colspan="4">Education : <font size="1"><strong><%=(String)vBasicInfo.elementAt(14) + " - "+
	  	(String)vBasicInfo.elementAt(15)%></strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
  </table>

<%
//to update the ledger hist balance information
double dNewBalance  = 0d;
double dPrevBalance = 0d;
for(int i = 0 ; i < vOldLedgerSYInfo.size(); i += 3) {
	vLedgerHist = faStudLedg.viewOldStudLedger(dbOP,(String)vBasicInfo.elementAt(0),(String)vOldLedgerSYInfo.elementAt(i),
										(String)vOldLedgerSYInfo.elementAt(i + 1),(String)vOldLedgerSYInfo.elementAt(i + 2));
	if(vLedgerHist == null)
		strErrMsg = faStudLedg.getErrMsg();
	else
		strErrMsg = null;
	%>
  <table   width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="#808080">
    <tr bgcolor="#3366FF">
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp; <strong><font color="#FFFFFF">
        <%=(String)vOldLedgerSYInfo.elementAt(i)+ " - "+(String)vOldLedgerSYInfo.elementAt(i + 1)%> - OLD ACCOUNT</font></strong></td>
    </tr>
    <%
if(strErrMsg != null){%>
    <tr bgcolor="#FFFFAF">
      <td height="25" colspan="5"><strong><font size="1">ERROR IN GETTING LEDGER
        INFO : <%=strErrMsg%></font></strong></td>
    </tr>
    <%}else if(vLedgerHist	!= null && vLedgerHist.size() > 1){%>
    <tr bgcolor="#FFFFAF">
      <td width="11%" height="25" align="center"><font size="1"><strong>DATE</strong></font></td>
      <td align="center" width="40%" ><font size="1"><strong>PARTICULARS</strong></font></td>
      <td width="13%" align="center"><font size="1"><strong>DEBIT</strong></font></td>
      <td width="13%" align="center"><font size="1"><strong>CREDIT</strong></font></td>
      <td width="17%" align="center"><font size="1"><strong>BALANCE</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" align="center">&nbsp;</td>
      <td colspan="3" align="center">Previous outstanding balance
        <%
	  if(((String)vLedgerHist.elementAt(0)).startsWith("-")){%>
        (Excess)
        <%}%> </td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(0))%></td>
    </tr>
    <%
for(int p = 1; p< vLedgerHist.size() ; ++p)
{%>
    <tr bgcolor="#FFFFFF">
      <td height="25" align="center">&nbsp;<%=(String)vLedgerHist.elementAt(p+2)%></td>
      <td align="center">&nbsp;<%=WI.getStrValue(vLedgerHist.elementAt(p+3))%> <%
	  //if or number existing -- show it.
	  if(vLedgerHist.elementAt(p+1) != null){%>
        /OR No. <%=(String)vLedgerHist.elementAt(p+1)%> <%}%> </td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(p+4))%></td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(p+5))%></td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(p+7))%></td>
    </tr>
    <%
	p = p+11;
	}//end of for loop.
}//end of vLedgerInfo%>
  </table>


<%}//end of displaying old ledger info

%>

  </table>
<!--  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
      <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="4" height="25"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click
        to print ledger</font></td>
      <td colspan="3" height="25">&nbsp;</td>
    </tr>
	</table>
-->
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
