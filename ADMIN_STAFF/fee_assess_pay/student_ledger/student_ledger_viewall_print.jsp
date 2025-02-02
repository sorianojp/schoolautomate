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

-->
</style>
</head>
<body>
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAStudentLedger,java.util.Vector,java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String[] astrConvertTerm = {"Summer","1st Term","2nd Term","3rd Term","4th Term","5th Term"};
	String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr",
        				"5th Yr","6th Yr","7th Yr","8th Yr"};

	boolean bolProceed = true;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-Student ledger","student_ledger_viewall_print.jsp");
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
														"student_ledger_viewall_print.jsp");
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
Vector vCurHistInfo = null;//records curriculum hist detail.

Vector vLedgerInfo = null;Vector vLedgerHist = null;

FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAStudentLedger faStudLedg = new FAStudentLedger();
student.ChangeCriticalInfo changeInfo = new student.ChangeCriticalInfo();
enrollment.FAStudentLedgerExtn faStudLedgExtn = new enrollment.FAStudentLedgerExtn();

if(WI.fillTextValue("stud_id").length() > 0) {
	vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
	if(vBasicInfo == null) //may be it is the teacher/staff
		strErrMsg = paymentUtil.getErrMsg();
}
if(vBasicInfo != null) {
	vCurHistInfo = changeInfo.operateOnStudCurriculumHist(dbOP,request,(String)vBasicInfo.elementAt(0),4);
	if(vCurHistInfo == null)
		strErrMsg = changeInfo.getErrMsg();
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode= "";
boolean bolShowDiscDetail = true;
if(strSchCode.startsWith("PWC"))
	bolShowDiscDetail = false;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#CCCCCC">
      <td width="100%" height="20"><div align="center"><strong><font size="2">:::: 
        STUDENT'S COMPLETE LEDGER ::::</font></strong></div></td>
    </tr>
<%if(strErrMsg != null){%>
		<tr>
			<td height="20">&nbsp;&nbsp;&nbsp; <font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    	</tr>
	<%}%>
  </table>

<%
if(vBasicInfo != null && vBasicInfo.size() > 0 && vCurHistInfo != null && vCurHistInfo.size() > 0){%>
  <table width="100%" border="0" >
    <tr>
      <td width="100%"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        </div></td>
    </tr>
    <tr>
      <td height="30"><div align="center"><u>STUDENT COMPLETE LEDGER</u></div>
		<div align="right">Date and time printed: <%=WI.getTodaysDateTime()%></div></td>
    </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="20">&nbsp;</td>
    <td height="20" colspan="2">Student Name :<strong> <%=(String)vBasicInfo.elementAt(1)%></strong></td>
  </tr>
  <tr> 
    <td  width="2%" height="20">&nbsp;</td>
    <td width="59%" height="20">Student ID : <strong><%=WI.fillTextValue("stud_id")%></strong></td>
    <td width="39%" height="20">SY /Term :<strong> <%=(String)vBasicInfo.elementAt(8) + " - " +(String)vBasicInfo.elementAt(9)%> 
      / <%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%></strong>    </td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td height="20">Course/Major :<strong> <%=(String)vBasicInfo.elementAt(2)%> 
      <%
	  if(vBasicInfo.elementAt(3) != null){%>
      /<%=WI.getStrValue(vBasicInfo.elementAt(3))%> 
      <%}%>
      </strong></td>
    <td height="20">Year Level : <strong><%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue((String)vBasicInfo.elementAt(4),"0"))]%></strong></td>
  </tr>
</table>

<%
String strGrant = null;

//first i have to find all the old ledger information here,
int iDispType = 0; // 0= new ledger type, 1 = old leger, -1 = error.
for(int i = 0 ; i < vCurHistInfo.size(); i += 16) {
	iDispType = faStudLedg.isOldLedgerInformation(dbOP, (String)vBasicInfo.elementAt(0),(String)vCurHistInfo.elementAt(i + 1),
										(String)vCurHistInfo.elementAt(i + 2),(String)vCurHistInfo.elementAt(i + 3));
	if(iDispType != 1)
		continue;
	vLedgerHist = faStudLedg.viewOldStudLedger(dbOP,(String)vBasicInfo.elementAt(0),(String)vCurHistInfo.elementAt(i + 1),
										(String)vCurHistInfo.elementAt(i + 2),(String)vCurHistInfo.elementAt(i + 3));
	if(vLedgerHist == null)
		strErrMsg = faStudLedg.getErrMsg();
	else
		strErrMsg = null;
	%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>

  <table   width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="#808080">
    <tr bgcolor="#3366FF">
      <td height="20" colspan="5">&nbsp;&nbsp;&nbsp; <strong><font color="#FFFFFF">
        <%=(String)vCurHistInfo.elementAt(i + 1)+ " - "+(String)vCurHistInfo.elementAt(i + 2)%> (<%=astrConvertTerm[Integer.parseInt((String)vCurHistInfo.elementAt(i + 3))]%>) - OLD ACCOUNT</font></strong></td>
    </tr>
    <%
if(strErrMsg != null){%>
    <tr bgcolor="#FFFFAF">
      <td height="20" colspan="5"><strong>ERROR IN GETTING LEDGER
        INFO : <%=strErrMsg%></strong></td>
    </tr>
    <%}else if(vLedgerHist	!= null && vLedgerHist.size() > 1){%>
    <tr bgcolor="#FFFFAF">
      <td width="11%" height="20" align="center"><strong>DATE</strong></td>
      <td align="center" width="40%" ><strong>PARTICULARS</strong></td>
      <td width="13%" align="center"><strong>DEBIT</strong></td>
      <td width="13%" align="center"><strong>CREDIT</strong></td>
      <td width="17%" align="center"><strong>BALANCE</strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="20" align="center">&nbsp;</td>
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
      <td height="20" align="center">&nbsp;<%=(String)vLedgerHist.elementAt(p+2)%></td>
      <td align="center">&nbsp;<%=WI.getStrValue(vLedgerHist.elementAt(p+3))%> <%
	  //if or number existing -- show it.
	  if(vLedgerHist.elementAt(p+1) != null){%>
        /OR No. <%=(String)vLedgerHist.elementAt(p+1)%> <%}%> </td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(p+4))%></td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(p+5))%></td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(p+7))%></td>
    </tr>
    <%
	p = p+7;
	}//end of for loop.
}//end of vLedgerInfo%>
  </table>


<%}//end of displaying old ledger info

//start of new ledger info display.
for(int i = 0 ; i < vCurHistInfo.size(); i += 15) {
	iDispType = faStudLedg.isOldLedgerInformation(dbOP, (String)vBasicInfo.elementAt(0),(String)vCurHistInfo.elementAt(i + 1),
										(String)vCurHistInfo.elementAt(i + 2),(String)vCurHistInfo.elementAt(i + 3));
	if(iDispType != 0)
		continue;
	vLedgerInfo = faStudLedgExtn.viewLedgerTuitionDetail(dbOP,(String)vBasicInfo.elementAt(0),(String)vCurHistInfo.elementAt(i + 1),
										(String)vCurHistInfo.elementAt(i + 2),(String)vCurHistInfo.elementAt(i + 3));
	if(vLedgerInfo == null)
		strErrMsg = faStudLedgExtn.getErrMsg();
	else
		strErrMsg = null;
	%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>
  <table   width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="#808080">
    <tr bgcolor="#3366FF">
      <td height="20" colspan="6">&nbsp;&nbsp;&nbsp; <strong><font color="#FFFFFF">
        <%=(String)vCurHistInfo.elementAt(i + 1)+ " - "+(String)vCurHistInfo.elementAt(i + 2)%> (<%=astrConvertTerm[Integer.parseInt((String)vCurHistInfo.elementAt(i + 3))]%>)</font></strong></td>
    </tr>
    <%
if(strErrMsg != null){%>
    <tr bgcolor="#FFFFAF">
      <td height="20" colspan="6"><strong>ERROR IN GETTING LEDGER
        INFO : <%=strErrMsg%></strong></td>
    </tr>
    <%}else if(vLedgerInfo	!= null && vLedgerInfo.size() > 1){%>
    <tr bgcolor="#FFFFAF">
      <td width="10%" height="20" align="center"><strong>DATE</strong></td>
      <td align="center" width="43%" ><strong>PARTICULARS</strong></td>
      <td width="10%" align="center"><strong>COLLECTED BY ID</strong></td>
      <td width="11%" align="center"><strong>DEBIT</strong></td>
      <td width="11%" align="center"><strong>CREDIT</strong></td>
      <td width="15%" align="center"><strong>BALANCE</strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="20" align="center">&nbsp;</td>
      <td colspan="4" align="center">Previous outstanding balance
        <%
	  if(((String)vLedgerInfo.elementAt(0)).startsWith("-")){%>
        (Excess)
        <%}%> </td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerInfo.elementAt(0))%></td>
    </tr>
    <%
for(int p = 2; p< vLedgerInfo.size() ; p += 6) {
	strGrant = WI.getStrValue(vLedgerInfo.elementAt(p + 1));
	if(!bolShowDiscDetail && strGrant != null && strGrant.length() > 20 && strGrant.indexOf("<br>") > 0) {
		strGrant = strGrant.substring(0, strGrant.indexOf("<br>"));
	}
%>
    <tr bgcolor="#FFFFFF">
      <td height="20" align="center">&nbsp;<%=WI.getStrValue(vLedgerInfo.elementAt(p))%></td>
      <td align="center"><%=strGrant%> </td>
      <td align="center"><%=WI.getStrValue(vLedgerInfo.elementAt(p + 2))%></td>
      <td align="center"><%=WI.getStrValue(vLedgerInfo.elementAt(p + 3))%></td>
      <td align="center"><%=WI.getStrValue(vLedgerInfo.elementAt(p + 4))%></td>
      <td align="center"><%=WI.getStrValue(vLedgerInfo.elementAt(p + 5))%></td>
    </tr>
    <%	}//end of for loop.
}//end of vLedgerInfo%>
  </table>


<%}//end of displaying new ledger info.%>
  </table>
<table width="100%" cellpadding="0" cellspacing="0" height="30">
	<tr valign="bottom">
		<td width="50%">Prepared by: __________________________</td>
		<td align="right">Approved by: __________________________</td>
	</tr>
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
