<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
								"Admin/staff-Fee Assessment & Payments-School facility ledger","schl_fac_ledger_print.jsp");
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
Vector vBasicInfo = null;
Vector vLedgerInfoNEW = null;
Vector vLedgerInfoOLD = null;
Vector vTemp = null;
String strDispDur = null;
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
//dbOP.cleanUP();

//get display duration.
if(WI.fillTextValue("year_availed_to").length()> 0)
{
	strDispDur = request.getParameter("year_availed_fr")+" to "+request.getParameter("year_availed_to");
}
else if(WI.fillTextValue("month_availed_to").compareTo("-1") !=0)
	strDispDur = astrConvertMonth[Integer.parseInt(request.getParameter("month_availed_fr"))] +" "+request.getParameter("year_availed_fr")+
		" to "+astrConvertMonth[Integer.parseInt(request.getParameter("month_availed_to"))]+" "+request.getParameter("year_availed_fr");
else
	strDispDur = astrConvertMonth[Integer.parseInt(request.getParameter("month_availed_fr"))] +" "+request.getParameter("year_availed_fr");
if(strErrMsg != null){dbOP.cleanUP();
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25"><div align="center"> <%=strErrMsg%> </div></td>
    </tr>
	</table>
<% return;}%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="6"><div align="center">
          <p><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,true)%></p>
          <p><u>SCHOOL FACILITIES LEDGER</u><br>
          </p>
        </div></td>
    </tr>
	</table>

  <table   width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">Date and time printed(yyyy-mm-dd) : <strong><%=WI.getTodaysDateTime()%></strong></td>
      <td><div align="right"><strong> &nbsp;&nbsp;</strong></div></td>
    </tr>
    <tr>
      <td colspan="2" height="25"><hr size="1"></td>
    </tr>
  </table>
<%
 if(vBasicInfo != null && vBasicInfo.size() > 0){%>

  <table   width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="45%" height="25">ID Number : <strong><%=request.getParameter("stud_id")%></strong></td>

    <td width="55%">Account Type : <strong>
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
  <table   width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>

    <td height="25" width="45%">Account name : <strong><%=(String)vBasicInfo.elementAt(1)%></strong></td>

    <td width="55%">Year/Term : <strong><%=(String)vBasicInfo.elementAt(4)%>/
      <%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%></strong></td>
    </tr>
    <tr>

    <td height="25" colspan="2">Course/Major :<strong> <%=(String)vBasicInfo.elementAt(2)%>
      <%
	  if(vBasicInfo.elementAt(3) != null){%>
      /<%=WI.getStrValue(vBasicInfo.elementAt(3))%>
      <%}%>
      </strong></td>
    </tr>
    <tr>
      <td height="25" colspan="2"><hr size="1"></td>
    </tr>
  </table>
<%}else if( vBasicInfo != null && vBasicInfo.size()> 0){%>
  <table   width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>

    <td>Account name : <strong><%=WI.formatName((String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),1)%></strong></td>

    <td height="26">Employee type :<strong> <%=(String)vBasicInfo.elementAt(15)%></strong></td>
    </tr>
    <tr>

    <td width="45%">Employee status : <strong><%=(String)vBasicInfo.elementAt(16)%></strong></td>

    <td width="55%" height="25">College/Department/Office : <strong><%=WI.getStrValue(vBasicInfo.elementAt(13))%>/<%=(String)vBasicInfo.elementAt(14)%></strong></td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<%}%>

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
    <tr>
      <td width="100%" height="25"  bgcolor="#E0DDCF"><div align="center">SCHOOL
        FACILITIES LEDGER <strong>DORMITORY - OLD</strong>
		<br>
          </strong>FOR <%=strDispDur%></div></td>
  </table>
  <table width="100%" border="1" cellspacing="0" cellpadding="0">
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
    <tr>
      <td width="100%" height="25" bgcolor="#E0DDCF"><div align="center">SCHOOL
          FACILITIES LEDGER FOR <strong>DORMITORY - NEW</strong>
		  <br>
          </strong>FOR <%=strDispDur%></div></td>
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
	  <td><%=(String)vPayment.elementAt(p)%>/<%=astrConvertMonth[Integer.parseInt((String)vPayment.elementAt(p+1))]%></td>
<%
	for(int i=0; i<vTemp.size(); ++i){%>
	<td>&nbsp;</td>
<%}%>
		<td height="25">&nbsp;</td>
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

<script language="JavaScript">
window.print();
window.setInterval("javascript:window.close();",0);
</script>

</body>
</html>
