<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">
function ShowHideMonth()
{
	if(document.ledg_view.year_availed_to.value.length == 0)//hide layer
	{
		showLayer('month_fr_');
		showLayer('month_to_');
	}
	else //show layer.
	{
		hideLayer('month_fr_');
		hideLayer('month_to_');
	}
}
function SubmitPage()
{
	document.ledg_view.submit();
}
function ReloadPage()
{
	document.ledg_view.reloadPage.value="1";
	SubmitPage();
}
function PrintPg()
{
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
	{
		//check here if all the values are intact.
		var strStudID = document.ledg_view.stud_id.value;
		var strYrAvailedFr = document.ledg_view.year_availed_fr.value;
		var strYrAvailedTo = document.ledg_view.year_availed_to.value;
		var strMonAvailedFr = document.ledg_view.month_availed_fr[document.ledg_view.month_availed_fr.selectedIndex].value;
		var strMonAvailedTo = document.ledg_view.month_availed_to[document.ledg_view.month_availed_to.selectedIndex].value;
		if(strStudID.length ==0)
		{
			alert("Please enter student id.");
			return;
		}
		if(strYrAvailedFr.length ==0)
		{
			alert("Please enter year availed from.");
			return;
		}
		var pgLoc = "./schl_fac_ledger_print.jsp?stud_id="+escape(strStudID)+"&year_availed_fr="+strYrAvailedFr+"&year_availed_to="+
			strYrAvailedTo+"&month_availed_fr="+strMonAvailedFr+"&month_availed_to="+strMonAvailedTo;
		var win=window.open(pgLoc,"PrintWindow",'width=900,height=500,scrollbars=yes,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=ledg_view.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.Authentication,enrollment.FAStudentLedger,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	WebInterface WI = new WebInterface(request);
	MessageConstant mConst = new MessageConstant();

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;

	boolean bolProceed = true;
    String[] astrConvertMonth = {"JANUARY","FEBRUARY","MARCH","APRIL","MAY","JUNE","JULY","AUGUST","SEPTMBER","OCTOBER","NOVEMBER","DECEMBER"};
	String[] astrConvertTerm  = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-School facility ledger","schl_fac_ledger_view.jsp");
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
														"schl_fac_ledger_view.jsp");
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
Vector vLedgerInfoNEW = null;
Vector vLedgerInfoOLD = null;
Vector vTemp = null;
boolean bolIsStaff = false; //true only if the payee type is internal and not a student type.

FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAStudentLedger studLedg = new FAStudentLedger();

if(WI.fillTextValue("stud_id").length() > 0 && bolProceed)
{
	vBasicInfo = paymentUtil.getStudBasicInfo(dbOP, request.getParameter("stud_id"));
	if(vBasicInfo == null) //may be it is the teacher/staff
	{
		strErrMsg = paymentUtil.getErrMsg();
		bolIsStaff = true;
		request.setAttribute("emp_id",request.getParameter("stud_id"));
		vBasicInfo = new Authentication().operateOnBasicInfo(dbOP, request,"0");
	}
	//get posted charge detail.
	if(vBasicInfo != null && vBasicInfo.size() > 0)
	{
		//get ledger information to view
		vLedgerInfoOLD = studLedg.viewOldLedgerHM(dbOP, request);
		if(vLedgerInfoOLD == null)
			strErrMsg = studLedg.getErrMsg();
		//get new ledger info here.
		vLedgerInfoNEW = studLedg.viewLedgerHM(dbOP, request);
		//System.out.println(vLedgerInfoNEW);

	}
}

if(strErrMsg == null) strErrMsg = "";
%>

<form name="ledg_view" action="./schl_fac_ledger_view.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          SCHOOL FACILITIES LEDGER PAGE ::::<br>
          </strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  colspan="4" height="25">&nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="34%" height="25">Enter ID Number
        <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="5%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="59%" height="25"><input name="image" type="image" onClick="ReloadPage();" src="../../../images/form_proceed.gif"></td>
    </tr>
    <tr>
      <td  colspan="4" height="25"><hr size="1"></td>
    </tr>
  </table>

<%
 if(vBasicInfo != null && vBasicInfo.size() > 0){%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td  width="2%"height="25">&nbsp;</td>
      <td width="98%">Account type :<strong>
        <%
	  if(bolIsStaff){%>
        Employee
        <%}else{%>
        Student
        <%}%>
        </strong></td>
    </tr>
  </table>
<%
if(!bolIsStaff && vBasicInfo != null && vBasicInfo.size()> 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="44%">Account name : <strong><%=(String)vBasicInfo.elementAt(1)%></strong></td>
      <td width="54%">Year/Term : <strong><%=(String)vBasicInfo.elementAt(4)%>/
        <%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2">Course/Major :<strong> <%=(String)vBasicInfo.elementAt(2)%>
        <%
	  if(vBasicInfo.elementAt(3) != null){%>
        /<%=WI.getStrValue(vBasicInfo.elementAt(3))%>
        <%}%>
        </strong></td>
    </tr>
  </table>
<%}else if( vBasicInfo != null && vBasicInfo.size()> 0){%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td>Account name : <strong><%=WI.formatName((String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),1)%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%">Employee type :<strong> <%=(String)vBasicInfo.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Employee status : <strong><%=(String)vBasicInfo.elementAt(16)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">College/Department/Office : <strong><%=WI.getStrValue(vBasicInfo.elementAt(13))%>/<%=(String)vBasicInfo.elementAt(14)%></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="2"><hr size="1"></td>
    </tr>
  </table>
<%}%>

  <table bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2">Show ledger for the Year
        <input name="year_availed_fr" type="text" size="4" value="<%=WI.fillTextValue("year_availed_fr")%>" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        to
        <input name="year_availed_to" type="text" size="4" value="<%=WI.fillTextValue("year_availed_to")%>" maxlength="4" onKeyUp="ShowHideMonth();" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="46%"> month
        <select name="month_availed_fr" id="month_fr_">
          <option value="0">JANUARY</option>
          <%
strTemp = WI.fillTextValue("month_availed_fr");
for(int i=1; i< 12; ++i){
	if(strTemp.compareTo(Integer.toString(i)) ==0)
	{%>
          <option value="<%=i%>" selected><%=astrConvertMonth[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrConvertMonth[i]%></option>
          <%}
}%>
        </select>
        to
        <select name="month_availed_to" id="month_to_">
          <option value="-1"></option>
          <%
strTemp = WI.fillTextValue("month_availed_to");
for(int i=0; i< 12; ++i){
	if(strTemp.compareTo(Integer.toString(i)) ==0)
	{%>
          <option value="<%=i%>" selected><%=astrConvertMonth[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrConvertMonth[i]%></option>
          <%}
}%>
        </select>
<%
if(WI.fillTextValue("year_availed_to").length() >0)
{%>
<script language="JavaScript">
hideLayer('month_fr_');
hideLayer('month_to_');
</script>
<%}%>
</td>
      <td width="52%"><input type="image" onClick="ReloadPage();" src="../../../images/form_proceed.gif"></td>
    </tr>
<%
if((vLedgerInfoNEW != null && vLedgerInfoNEW.size()>0) || (vLedgerInfoOLD != null && vLedgerInfoOLD.size()>1) ){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
          to print ledger</font></div></td>
    </tr>
<%}%>
  </table>
<%
float fCredit = 0;
float fDebit = 0;
float fBalance = 0;//cumulative balance.
String strYrAvailed = null;
String strMonAvailed = null;
String strORNumber = "&nbsp;";
String strTransDate = "&nbsp;";
boolean bolIncr = true;

if(vLedgerInfoOLD != null && vLedgerInfoOLD.size()> 1){
vTemp = (Vector)vLedgerInfoOLD.elementAt(0);%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#B9B292"><div align="center">SCHOOL
          FACILITIES LEDGER FOR <strong>DORMITORY - OLD</strong></div></td>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" align="center"><strong><font size="1">YEAR/MONTH</font></strong></td>
<%
for(int i=0; i<vTemp.size();++i){%>
<td align="center"><strong><font size="1"><%=((String)vTemp.elementAt(i++)).toUpperCase()%></font></strong></td>
<%
}%>
      <td align="center"><font size="1"><strong>DEBIT</strong></font></td>
      <td align="center"><font size="1"><strong>DATE OF <br>PAYMENT</strong></font></td>
      <td align="center"><font size="1"><strong>O.R. NO.</strong></font></td>
      <td align="center"><font size="1"><strong>CREDIT</strong></font></td>
      <td align="center"><font size="1"><strong>BALANCE</strong></font></td>
    </tr>
<%
for(int i=1; i< vLedgerInfoOLD.size() ; ){//System.out.println(vLedgerInfoOLD);
strYrAvailed = (String)vLedgerInfoOLD.elementAt(i);
strMonAvailed = (String)vLedgerInfoOLD.elementAt(i+1);
%>
    <tr>
      <td height="25"><%=strYrAvailed%>/<%=astrConvertMonth[Integer.parseInt(strMonAvailed)]%></td>
<%
for(int j=0;j<vTemp.size(); ++j)
{//System.out.println(vTemp.elementAt(j));
//if(i>=vLedgerInfoOLD.size()) break;
	//if(strYrAvailed.compareTo((String)vLedgerInfoOLD.elementAt(i)) !=0 || strMonAvailed.compareTo((String)vLedgerInfoOLD.elementAt(i+1)) !=0){
	//{bolIncr = false;break;}
	//}
	//check if this is payment.
	if( i<vLedgerInfoOLD.size() && vLedgerInfoOLD.elementAt(i+2) == null)
	{
		fCredit = Float.parseFloat((String)vLedgerInfoOLD.elementAt(i+5));
		strORNumber = (String)vLedgerInfoOLD.elementAt(i+3);
		strTransDate = (String)vLedgerInfoOLD.elementAt(i+4);
		//System.out.println("printing : "+strORNumber+" "+strTransDate+" " +fCredit);
		i = i+6;--j;bolIncr = false;
		continue;
	}
	++j;
	if( i <vLedgerInfoOLD.size() &&  ((String)vLedgerInfoOLD.elementAt(i+2)).compareTo( (String)vTemp.elementAt(j)) ==0)
	{//only if it exists
		fDebit += Float.parseFloat((String)vLedgerInfoOLD.elementAt(i+5));
		strTemp = (String)vLedgerInfoOLD.elementAt(i+5);
		i = i+6;bolIncr = false;
	}
	else
	{
		strTemp = "&nbsp;";
	}
	%>
<td><%=strTemp%></td>
<%}
fBalance += fDebit-fCredit;%>
      <td><%=fDebit%></td>
      <td><%=strTransDate%></td>
      <td><%=strORNumber%></td>
      <td><%=fCredit%></td>
      <td><%=fBalance%></td>
    </tr>
<%
fDebit = 0;
fCredit = 0;
strTransDate = "&nbsp;";
strORNumber = "&nbsp;";
if(bolIncr) i = i+6;
bolIncr = true;
}%>
  </table>

<%
	}//only if vLedgerInfoOLD is not null
Vector vPayable = null;
Vector vPayment = null;
int iFeeNameSize = 0;
int iIndex = 0; //index of object in vector.
String strCredit="&nbsp;";
if(vLedgerInfoNEW != null && vLedgerInfoNEW.size()> 0){
vTemp 		= (Vector)vLedgerInfoNEW.elementAt(0);
vPayable 	= (Vector)vLedgerInfoNEW.elementAt(1);
vPayment 	= (Vector)vLedgerInfoNEW.elementAt(2);
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#B9B292"><div align="center">SCHOOL
          FACILITIES LEDGER FOR <strong>DORMITORY - NEW</strong></div></td>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" align="center"><strong><font size="1">YEAR/MONTH</font></strong></td>
<%
for(int i=0; i<vTemp.size();++i){%>
<td align="center"><strong><font size="1"><%=((String)vTemp.elementAt(i)).toUpperCase()%></font></strong></td>
<%
}%>
      <td align="center"><font size="1"><strong>DEBIT</strong></font></td>
      <td align="center"><font size="1"><strong>DATE OF <br>PAYMENT</strong></font></td>
      <td align="center"><font size="1"><strong>O.R. NO.</strong></font></td>
      <td align="center"><font size="1"><strong>CREDIT</strong></font></td>
      <td align="center"><font size="1"><strong>BALANCE</strong></font></td>
    </tr>
<%
iFeeNameSize = vTemp.size();
for(int i=0; i< vPayable.size() ; ){//System.out.println(vLedgerInfoOLD);
strYrAvailed = (String)vPayable.elementAt(2);
strMonAvailed = (String)vPayable.elementAt(3);
%>
    <tr>
      <td height="25"><%=strYrAvailed%>/<%=astrConvertMonth[Integer.parseInt(strMonAvailed)]%></td>
<%
for(int j=0;j<vTemp.size(); ++j)
{//System.out.println(vTemp.elementAt(j));
	if(vPayable.size() > 0)
		iIndex = vPayable.indexOf(vTemp.elementAt(j));
	else iIndex = -1;
	if(iIndex == -1)
		strTemp = "&nbsp;";
	else
	{
		//check if same year / or not
		if(strYrAvailed.compareTo((String)vPayable.elementAt(iIndex+2)) !=0 || strMonAvailed.compareTo((String)vPayable.elementAt(iIndex+3)) !=0)
			strTemp = "&nbsp;";
		else
		{
			fDebit += Float.parseFloat((String)vPayable.elementAt(iIndex+1));
			strTemp = (String)vPayable.elementAt(iIndex+1);
			vPayable.removeElementAt(iIndex+3);vPayable.removeElementAt(iIndex+2);vPayable.removeElementAt(iIndex+1);
			vPayable.removeElementAt(iIndex);
		}
	}%>



	<td><%=strTemp%></td>
<%}%>
      <td><%=fDebit%></td>
<%
//find here if occupant paid this month.
for(int p=0; p < vPayment.size(); )
{
	if(vPayment.size() > 0 && strYrAvailed.compareTo((String)vPayment.elementAt(0)) ==0 && strMonAvailed.compareTo((String)vPayment.elementAt(1)) ==0)
	{
		if(strTransDate.compareTo("&nbsp;") ==0)
			strTransDate = (String)vPayment.elementAt(2);
		else strTransDate += "<br>"+(String)vPayment.elementAt(2);

		if(strORNumber.compareTo("&nbsp;") ==0)
			strORNumber = (String)vPayment.elementAt(3);
		else strORNumber += "<br>"+(String)vPayment.elementAt(3);

		if(strCredit.compareTo("&nbsp;") ==0)
			strCredit = (String)vPayment.elementAt(4);
		else strCredit += "<br>"+(String)vPayment.elementAt(4);

		fCredit += Float.parseFloat((String)vPayment.elementAt(4));
		vPayment.removeElementAt(0);vPayment.removeElementAt(0);vPayment.removeElementAt(2);vPayment.removeElementAt(0);
		vPayment.removeElementAt(0);
	}
	else
		break;
}%>
      <td><%=strTransDate%></td>
      <td><%=strORNumber%></td>
      <td><%=strCredit%></td>
<%
fBalance += fDebit-fCredit;%>
      <td><%=fBalance%></td>
    </tr>
<%
fDebit = 0;
fCredit = 0;
strTransDate = "&nbsp;";
strORNumber = "&nbsp;";
strCredit = "&nbsp;";
}
//sometimes there is a payment for a month, but no posting.
if(vPayment.size() > 0){
for(int p=0; p < vPayment.size();++p)
{
	fCredit = Float.parseFloat((String)vPayment.elementAt(p+4));
	fBalance -= fCredit;
%>
	 <tr>
	  <td height="25"><%=(String)vPayment.elementAt(p)%>/<%=astrConvertMonth[Integer.parseInt((String)vPayment.elementAt(p+1))]%></td>
<%
	for(int i=0; i<vTemp.size(); ++i){%>
	<td>&nbsp;</td>
<%}%>
		<td>&nbsp;</td>
      <td><%=(String)vPayment.elementAt(p+2)%></td>
      <td><%=(String)vPayment.elementAt(p+3)%></td>
      <td><%=(String)vPayment.elementAt(p+4)%></td>
      <td><%=fBalance%></td>
    </tr>
<%
p = p+4;
	}
}// if vPayment is having information.%>
  </table>

<%
	}//only if vLedgerInfoNEW is not null

}//only if vBasicInfo !=null
%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="9"><div align="right">
	  <%
if((vLedgerInfoNEW != null && vLedgerInfoNEW.size()>0) || (vLedgerInfoOLD != null && vLedgerInfoOLD.size()>1) ){%>
<a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
          to print ledger</font>
<%}%>
</div></td>
    </tr>
    <tr>
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="reloadPage" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
