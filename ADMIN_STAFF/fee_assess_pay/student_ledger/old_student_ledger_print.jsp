<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
<script language="JavaScript">
function ReloadPage()
{
	document.ledger_old.submit();
}
function PrintPg()
{
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
	{
		var pgLoc = "./old_student_ledger_print.jsp?stud_id="+escape(document.ledger_old.stud_id.value)+"&sy_from="+
			document.ledger_old.sy_from.value+"&sy_to="+document.ledger_old.sy_to.value+"&semester="+
			document.ledger_old.semester[document.ledger_old.semester.selectedIndex].value;

	var win=window.open(pgLoc,"PrintWindow",'width=900,height=500,scrollbars=yes,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}

</script>

<body>
<%@ page language="java" import="utility.*,enrollment.FAStudentLedger,enrollment.FAPaymentUtil,java.util.Vector,java.util.StringTokenizer" buffer="16kb"%>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & OLD STUDENT ACCOUNT MGMT-Old student account mgmt","old_student_ledger.jsp");
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
														"Fee Assessment & Payments","OLD STUDENT ACCOUNT MGMT",request.getRemoteAddr(),
														"old_student_ledger.jsp");
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

Vector vStudInfo = new Vector();
Vector vLedgerHist = new Vector();
boolean bolErr = false; //only if there is any error in operation.
String strTemp2 = null;

FAPaymentUtil pmtUtil = new FAPaymentUtil();
FAStudentLedger studLedger = new FAStudentLedger();

vStudInfo = pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));

if(vStudInfo == null || vStudInfo.size() == 0)
	strErrMsg = pmtUtil.getErrMsg();
else//check if this student is called for old ledger information.
{
	int iDisplayType = studLedger.isOldLedgerInformation(dbOP, (String)vStudInfo.elementAt(0),request.getParameter("sy_from"),
										request.getParameter("sy_to"),request.getParameter("semester"));
	if(iDisplayType ==-1) //Error.
	{
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=studLedger.getErrMsg()%></font></p>
		<%
		dbOP.cleanUP();
		return;
	}
	if(iDisplayType ==0)//this is called for old ledger information.
	{
		dbOP.cleanUP();
		response.sendRedirect(response.encodeRedirectURL("./student_ledger.jsp?stud_id="+request.getParameter("stud_id")+"&sy_from="+
			request.getParameter("sy_from")+"&sy_to="+request.getParameter("sy_to")+"&semester="+request.getParameter("semester")));
		return;
	}
}

if(!bolErr) //get ledger history.
{
	vLedgerHist = studLedger.viewOldStudLedger(dbOP,(String)vStudInfo.elementAt(0),request.getParameter("sy_from"),
		request.getParameter("sy_to"),request.getParameter("semester"));
	if(vLedgerHist == null)
		strErrMsg = studLedger.getErrMsg();
}


//dbOP.cleanUP();
if(strErrMsg == null) strErrMsg = "";

if(vStudInfo == null || vStudInfo.size() ==0)
   dbOP.cleanUP();
else if(vStudInfo != null && vStudInfo.size() > 0){%>
  <table width="100%" border="0" >
    <tr>
      <td width="100%"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
        </div></td>
    </tr>
    <tr>
      <td height="30"><div align="center"><br>
        STUDENT LEDGER<br>
        <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>
		(<%=astrConvertTerm[Integer.parseInt(request.getParameter("semester"))]%>)

        </strong></div>
		<div align="right">Date and time printed: <%=WI.getTodaysDateTime()%></div></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>

    <td colspan="6" height="25">&nbsp; </td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="40%" height="25">Student name :<strong> <%=(String)vStudInfo.elementAt(1)%></strong></td>
      <td width="58%" height="25"  colspan="4">Course/Major : <strong><%=(String)vStudInfo.elementAt(2)%>
        <%if(vStudInfo.elementAt(3) != null){%>
        / <%=WI.getStrValue(vStudInfo.elementAt(3))%>
        <%}%>
        </strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Current Year :<strong> <%=(String)vStudInfo.elementAt(4)%></strong>
      </td>

    <td  colspan="4" height="25">Current Term : <strong><%=astrConvertTerm[Integer.parseInt((String)vStudInfo.elementAt(5))]%></strong></td>
    </tr>
    <tr>
      <td colspan="6"><hr size="1"></td>
    </tr>
  </table>
<%
if(vLedgerHist	!= null && vLedgerHist.size() > 1){%>
  <table   width="100%" border="1" cellpadding="0" cellspacing="0" >
    <tr bgcolor="#E6E6EA">
      <td width="11%" height="20" align="center"><font size="1"><strong>DATE</strong></font></td>
      <td width="11%" align="center"><font size="1"><strong>CATEGORY</strong></font></td>
      <td align="center" width="40%" ><font size="1"><strong>PARTICULARS</strong></font></td>
      <td width="13%" align="center"><font size="1"><strong>DEBIT</strong></font></td>
      <td width="13%" align="center"><font size="1"><strong>CREDIT</strong></font></td>
      <td width="17%" align="center"><font size="1"><strong>BALANCE</strong></font></td>
    </tr>
    <tr>
      <td height="25" align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">Previous outstanding balance
        <%
	  if(((String)vLedgerHist.elementAt(0)).startsWith("-")){%>
        (Excess)
        <%}%>      </td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(0))%></td>
    </tr>
    <%
for(int i = 1; i< vLedgerHist.size() ; ++i)
{%>
    <tr>
      <td height="25" align="center">&nbsp;<%=(String)vLedgerHist.elementAt(i+2)%></td>
      <td align="center"><%=WI.getStrValue(vLedgerHist.elementAt(i+9), "Default")%></td>
      <td align="center">&nbsp;<%=WI.getStrValue(vLedgerHist.elementAt(i+3))%>
        <%
	  //if or number existing -- show it.
	  if(vLedgerHist.elementAt(i+1) != null){%>
        /OR No. <%=(String)vLedgerHist.elementAt(i+1)%>
        <%}%>      </td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(i+4))%></td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(i+5))%></td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(i+7))%></td>
    </tr>
    <%
i = i+11;
}%>
  </table>
  <script language="JavaScript">
window.print();
window.setInterval("javascript:window.close();",0);
</script>

 <%}//if vLedgerHist != null ;
 }//if student information exists.
%>
    <!-- all hidden fields go here -->

</form>
</body>
</html>
