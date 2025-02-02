<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
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

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAStudentLedger,enrollment.FAPaymentUtil,java.util.Vector,java.util.StringTokenizer" buffer="16kb"%>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";

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
Vector vEditInfo = null;
boolean bolErr = false; //only if there is any error in operation.
String strTemp2 = null;

FAPaymentUtil pmtUtil = new FAPaymentUtil();
FAStudentLedger studLedger = new FAStudentLedger();

vStudInfo = pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));

if(vStudInfo == null || vStudInfo.size() == 0) {
	strErrMsg = pmtUtil.getErrMsg();
	bolErr = true;
}
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

//get edit info if strPrepareToEdit is 1
//System.out.println(strPrepareToEdit);
if(strPrepareToEdit.compareTo("1") ==0)
{
	vEditInfo = studLedger.viewOldLedger(dbOP, request.getParameter("info_index"));
	if(vEditInfo == null)
		strErrMsg = studLedger.getErrMsg();
}


dbOP.cleanUP();
if(strErrMsg == null) strErrMsg = "";
%>
<form name="ledger_old" action="./old_student_ledger_view.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          OLD STUDENT LEDGER ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><%=strErrMsg%></strong></td>
    </tr>
  </table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="26">&nbsp;</td>
      <td height="26" colspan="2">School Year</td>
      <td width="22%" height="26"><input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("ledger_old","sy_from","sy_to")'>
        to
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"></td>
      <td width="65%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Term</td>
      <td height="25"><select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Student ID &nbsp;</td>
      <td height="25"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td><input type="image" src="../../../images/form_proceed.gif"></td>
    </tr>
  </table>


  <%
if(vStudInfo != null && vStudInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="25"><hr size="1">
        <!-- hidden student information here -->
        <input type="hidden" value="<%=(String)vStudInfo.elementAt(0)%>" name="stud_index">
        <input type="hidden" value="<%=(String)vStudInfo.elementAt(4)%>" name="year_level">
      </td>
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
      <td  colspan="4" height="25">Current Term : <strong><%=(String)vStudInfo.elementAt(5)%></strong></td>
    </tr>
    <tr>
      <td colspan="6" height="25"><hr size="1"></td>
    </tr>
  </table>
<%
if(vLedgerHist	!= null && vLedgerHist.size() > 1){%>
  <table   width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td width="11%" height="25" align="center"><font size="1"><strong>DATE</strong></font></td>
      <td align="center" width="40%" ><font size="1"><strong>PARTICULARS</strong></font></td>
      <td width="13%" align="center"><font size="1"><strong>DEBIT</strong></font></td>
      <td width="13%" align="center"><font size="1"><strong>CREDIT</strong></font></td>
      <td width="17%" align="center"><font size="1"><strong>BALANCE</strong></font></td>
    </tr>
    <tr>
      <td height="25" align="center">&nbsp;</td>
      <td align="center">Previous outstanding balance
        <%
	  if(((String)vLedgerHist.elementAt(0)).startsWith("-")){%>
        (Excess)
        <%}%>
      </td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(0))%></td>
    </tr>
    <%
for(int i = 1; i< vLedgerHist.size() ; ++i)
{%>
    <tr>
      <td height="25" align="center">&nbsp;<%=(String)vLedgerHist.elementAt(i+2)%></td>
      <td align="center">&nbsp;<%=WI.getStrValue(vLedgerHist.elementAt(i+3))%>
        <%
	  //if or number existing -- show it.
	  if(vLedgerHist.elementAt(i+1) != null){%>
        /OR No. <%=(String)vLedgerHist.elementAt(i+1)%>
        <%}%>
      </td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(i+4))%></td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(i+5))%></td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(i+7))%></td>
    </tr>
    <%
i = i+11;
}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
      <tr>
      <td width="12%" height="25">&nbsp;</td>
      <td height="25"><div align="left"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
          to print ledger</font></div></td>
    </tr>
</table>
 <%}//if vLedgerHist != null ;
 %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<%
}//if student information exists.
%>
    <!-- all hidden fields go here -->

</form>
</body>
</html>
