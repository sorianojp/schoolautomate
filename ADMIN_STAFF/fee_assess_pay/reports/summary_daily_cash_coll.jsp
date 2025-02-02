<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Summary of daily cash collection</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PrintPg() {
	if(document.daily_cash.date_of_col.value.length ==0) {
		alert("Please enter date of collection.");
		return;
	}
	//I have to call here the print page.
	var pgLoc = "./summary_daily_cash_coll_print.jsp?date_of_col="+document.daily_cash.date_of_col.value+
	"&teller_id="+escape(document.daily_cash.teller_id.value);
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	String strPrepareToEdit=WI.getStrValue(request.getParameter("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","summary_daily_cash_coll.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"summary_daily_cash_coll.jsp");
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
Vector vCourseOffered  = null;
Vector vTellerInfo     = null;
Vector vCollectionInfo = null;
int iNoOfTellers       = 0;

DailyCashCollection DC   = new DailyCashCollection();
if(WI.fillTextValue("date_of_col").length() > 0)
{
	vCourseOffered = DC.getCoursesOffered(dbOP);//System.out.println(vCourseOffered);
	if(vCourseOffered == null)
		strErrMsg = DC.getErrMsg();
	else
	{
		vTellerInfo = DC.getTellerForADay(dbOP,WI.fillTextValue("date_of_col"),WI.fillTextValue("teller_id"));
		if(vTellerInfo == null)
			strErrMsg = DC.getErrMsg();
	}
}
if(vTellerInfo != null)
	iNoOfTellers = vTellerInfo.size()/2;


%>
<form name="daily_cash" action="./summary_daily_cash_coll.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          SUMMARY OF DAILY CASH COLLECTION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Tell ID : 
        <input name="teller_id" type="text" size="16" value="<%=WI.fillTextValue("teller_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        (only if summary of daily cash collection is for one teller)</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="32%" height="25">Reference Date <font size="1"> 
        <input name="date_of_col" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_of_col")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('daily_cash.date_of_col');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></font></td>
      <td width="66%"><input type="image" src="../../../images/form_proceed.gif" width="81" height="21"></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
 <%
if(vCourseOffered  != null && vTellerInfo != null){%>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" align="center" width="10%"><font size="1"><strong>COURSE/<br>
        CATEGORY</strong></font></td>
      <td colspan="<%=iNoOfTellers%>" align="center"><font size="1"><strong>NAME 
        OF TELLER/S</strong></font></td>
      <td align="center"><font size="1"><strong>TOTAL</strong></font></td>
    </tr>
    <tr> 
      <td><font size="1">&nbsp;</font></td>
      <%//System.out.println(vTellerInfo);//System.out.println(vCollectionInfo);
	for(int j=0; j<vTellerInfo.size(); ++j)
	{%>
      <td align="center"><font size="1"><%=(String)vTellerInfo.elementAt(j+1)%></font></td>
      <%++j;}%>
      <td align="center"><font size="1">&nbsp;</font></td>
    </tr>
    <%
double dTotalCashPerCourse  = 0d;
double dTotalCheckPerCourse = 0d;
double dTotalCAPerCourse    = 0d;

double dTotalCashPerTeller  = 0d;
double dTotalCheckPerTeller = 0d;
double dTotalCAPerTeller    = 0d;

double dTotalCash  = 0d;
double dTotalCheck = 0d;
double dTotalCA    = 0d;

int iTellerIndex  = 0;
double dTempCash   = 0d;
double dTempCheck  = 0d;
double dTempCA     = 0d;


double[] dTotalCashTeller  = new double[iNoOfTellers];
double[] dTotalCheckTeller = new double[iNoOfTellers];
double[] dTotalCATeller    = new double[iNoOfTellers];

strErrMsg = "";//System.out.println(vCourseOffered);
for(int i=0; i<vCourseOffered.size(); i += 2) {
	vCollectionInfo = DC.summaryDailyCashCollectionPerCourse(dbOP,WI.fillTextValue("teller_id"),WI.fillTextValue("date_of_col"),
							(String)vCourseOffered.elementAt(i));
	//for the payment from student donot belong school.
	if(vCollectionInfo == null)	{
		strErrMsg = DC.getErrMsg();
		break;
	}
	if(vCollectionInfo.size() <=1)
		continue;
%>
    <tr> 
      <td height="25"><font size="1"><%=(String)vCourseOffered.elementAt(i+1)%></font></td>
      <%
	//System.out.println(vCollectionInfo);
	for(int j=0; j<vTellerInfo.size(); ++j)	{
	//if( ((String)vTellerInfo.elementAt(j)).compareTo("2154") == 0)
	//	System.out.println(vCollectionInfo);
		
		iTellerIndex = vCollectionInfo.indexOf(vTellerInfo.elementAt(j));
		if(iTellerIndex == -1) {
			dTempCash  = 0d;
			dTempCheck = 0d;
			dTempCA    = 0d;
		}
		else {
			dTempCash  = Double.parseDouble((String)vCollectionInfo.elementAt(iTellerIndex+1));
			dTempCheck = Double.parseDouble((String)vCollectionInfo.elementAt(iTellerIndex+2));
			dTempCA    = Double.parseDouble((String)vCollectionInfo.elementAt(iTellerIndex+3));
		}
		dTotalCashPerCourse    += dTempCash ;
		dTotalCheckPerTeller   += dTempCheck ;
		dTotalCAPerTeller      += dTempCA ;
		dTotalCashTeller[j/2]  += dTempCash;
		dTotalCheckTeller[j/2] += dTempCheck;
		dTotalCATeller[j/2]    += dTempCA;


	%>
      <td align="center"> <font size="1"> 
        <%//System.out.println(dTempCash);System.out.println(dTempCheck);System.out.println(dTempCA);
	if(dTempCash == 0f && dTempCheck == 0f && dTempCA == 0f){%>
        &nbsp; 
        <%}else{%>
        <%=CommonUtil.formatFloat(dTempCash,true)%>/ <%=CommonUtil.formatFloat(dTempCheck,true)%>/ <%=CommonUtil.formatFloat(dTempCA,true)%> 
        <%}%>
        </font></td>
      <%++j;}
	dTotalCash  += dTotalCashPerCourse ;
	dTotalCheck += dTotalCheckPerTeller ;
	dTotalCA    += dTotalCAPerTeller ;
	

%>
      <td align="center"> <font size="1"> 
        <%
	if(dTotalCashPerCourse == 0f && dTotalCheckPerTeller == 0f && dTotalCAPerTeller == 0f){%>
        &nbsp; 
        <%}else{%>
        <%=CommonUtil.formatFloat(dTotalCashPerCourse,true)%>/ <%=CommonUtil.formatFloat(dTotalCheckPerTeller,true)%> / <%=CommonUtil.formatFloat(dTotalCAPerTeller,true)%></font></td>
      <%}
	dTotalCashPerCourse = 0d;dTotalCheckPerTeller = 0d;dTotalCAPerTeller = 0d;%>
    </tr>
    <%}//end of for(int i=0; i<vCourseOffered.size(); i += 2)

//I have to now get the daily cash collection for external payment type.. for example if payee is not a student / does not have ID.
vCollectionInfo = DC.summaryDailyCashCollectionPerCourse(dbOP,WI.fillTextValue("teller_id"),WI.fillTextValue("date_of_col"),null);
//System.out.println(vCollectionInfo);
 if(vCollectionInfo != null && vCollectionInfo.size() > 0){%>
    <tr> 
      <td height="25"><font size="1">External payment</font></td>
      <%
			dTempCash  = 0d;
			dTempCheck = 0d;
			dTempCA    = 0d;
	for(int j=0; j<vTellerInfo.size(); ++j)
	{
		iTellerIndex = vCollectionInfo.indexOf(vTellerInfo.elementAt(j));
		if(iTellerIndex == -1)
		{
			dTempCash  = 0d;
			dTempCheck = 0d;
			dTempCA    = 0d;
		}
		else
		{
			dTempCash  = Double.parseDouble((String)vCollectionInfo.elementAt(iTellerIndex+1));
			dTempCheck = Double.parseDouble((String)vCollectionInfo.elementAt(iTellerIndex+2));
			dTempCA    = Double.parseDouble((String)vCollectionInfo.elementAt(iTellerIndex+3));
		}

		dTotalCashPerCourse  += dTempCash ;
		dTotalCheckPerTeller += dTempCheck ;
		dTotalCAPerTeller    += dTempCA ;
		dTotalCashTeller[j/2]  += dTempCash;
		dTotalCheckTeller[j/2] += dTempCheck;
		dTotalCATeller[j/2]    += dTempCA;


	%>
      <td align="center"> <font size="1"> 
        <%//System.out.println(dTempCash);System.out.println(dTempCheck);System.out.println(dTempCA);
	if(dTempCash == 0f && dTempCheck == 0f && dTempCA == 0f){%>
        &nbsp; 
        <%}else{%>
        <%=CommonUtil.formatFloat(dTempCash,true)%>/ <%=CommonUtil.formatFloat(dTempCheck,true)%>/ <%=CommonUtil.formatFloat(dTempCA,true)%> 
        <%}%>
        </font></td>
      <%++j;}
	dTotalCash  += dTotalCashPerCourse ;
	dTotalCheck += dTotalCheckPerTeller ;
	dTotalCA    += dTotalCAPerTeller ;

%>
      <td align="center"> <font size="1"> 
        <%
	if(dTotalCashPerCourse == 0f && dTotalCheckPerTeller == 0f && dTotalCAPerTeller == 0f){%>
        &nbsp; 
        <%}else{%>
        <%=CommonUtil.formatFloat(dTotalCashPerCourse,true)%>/ <%=CommonUtil.formatFloat(dTotalCheckPerTeller,true)%> / <%=CommonUtil.formatFloat(dTotalCAPerTeller,true)%></font></td>
      <%}
	dTotalCashPerCourse = 0d;dTotalCheckPerTeller = 0d;dTotalCAPerTeller = 0d;%>
    </tr>
    <%}//end of for(int i=0; i<vCourseOffered.size(); i += 2)
//I have to collect the daily remittance here. 
vCollectionInfo = DC.viewRemittanceCollectionDetail(dbOP,WI.fillTextValue("teller_id"),WI.fillTextValue("date_of_col"));
//System.out.println(vCollectionInfo);
 while(vCollectionInfo != null && vCollectionInfo.size() > 0){
 			dTempCash  = 0d;
			dTempCheck = 0d;
			dTempCA    = 0d;%>
    <tr> 
      <td height="25"><font size="1">Remittance 
        <!--(<%//=(String)vCollectionInfo.elementAt(iTellerIndex+5)%>) - can't show type name , it is mixed. -->
        </font></td>
      <%
	for(int j=0; j<vTellerInfo.size(); ++j)
	{
		iTellerIndex = vCollectionInfo.indexOf(vTellerInfo.elementAt(j));
		if(iTellerIndex == -1)
		{
			dTempCash  = 0d;
			dTempCheck = 0d;
			dTempCA    = 0d;
		}
		else
		{
			dTempCash  = Double.parseDouble((String)vCollectionInfo.elementAt(iTellerIndex+1));
			dTempCheck = Double.parseDouble((String)vCollectionInfo.elementAt(iTellerIndex+2));
			dTempCA    = Double.parseDouble((String)vCollectionInfo.elementAt(iTellerIndex+3));
		}

		dTotalCashPerCourse  += dTempCash ;
		dTotalCheckPerTeller += dTempCheck ;
		dTotalCAPerTeller    += dTempCA ;
		dTotalCashTeller[j/2]  += dTempCash;
		dTotalCheckTeller[j/2] += dTempCheck;
		dTotalCATeller[j/2]    += dTempCA;


	%>
      <td align="center"> <font size="1"> 
        <%//System.out.println(dTempCash);System.out.println(dTempCheck);System.out.println(dTempCA);
	if(dTempCash == 0f && dTempCheck == 0f && dTempCA == 0f){%>
        &nbsp; 
        <%}else{%>
        <%=CommonUtil.formatFloat(dTempCash,true)%>/ <%=CommonUtil.formatFloat(dTempCheck,true)%>/ <%=CommonUtil.formatFloat(dTempCA,true)%> 
        <%}%>
        </font></td>
      <%++j;
		if(iTellerIndex > -1) 
		{
			vCollectionInfo.removeElementAt(iTellerIndex);vCollectionInfo.removeElementAt(iTellerIndex);
			vCollectionInfo.removeElementAt(iTellerIndex);vCollectionInfo.removeElementAt(iTellerIndex);
			vCollectionInfo.removeElementAt(iTellerIndex);vCollectionInfo.removeElementAt(iTellerIndex);
		}
	}//end of for loop to display remittance.
	dTotalCash  += dTotalCashPerCourse ;
	dTotalCheck += dTotalCheckPerTeller ;
	dTotalCA    += dTotalCAPerTeller ;
%>
      <td align="center"> <font size="1"> 
        <%
	if(dTotalCashPerCourse == 0f && dTotalCheckPerTeller == 0f && dTotalCAPerTeller == 0f){%>
        &nbsp; 
        <%}else{%>
        <%=CommonUtil.formatFloat(dTotalCashPerCourse,true)%>/ <%=CommonUtil.formatFloat(dTotalCheckPerTeller,true)%> / <%=CommonUtil.formatFloat(dTotalCAPerTeller,true)%></font></td>
      <%}
	dTotalCashPerCourse = 0d;dTotalCheckPerTeller = 0d;dTotalCAPerTeller = 0d;%>
    </tr>
    <%}//end of displaying remittance. I have to show here basic edu collection.
//Basic education collection.
vCollectionInfo = DC.viewBasicColDetail(dbOP,WI.fillTextValue("teller_id"),WI.fillTextValue("date_of_col"));
//System.out.println(vCollectionInfo);
 while(vCollectionInfo != null && vCollectionInfo.size() > 0){
 			dTempCash  = 0d;
			dTempCheck = 0d;
			dTempCA    = 0d;%>
    <tr> 
      <td height="25"><font size="1">Basic Edu</font></td>
      <%
	for(int j=0; j<vTellerInfo.size(); ++j)
	{
		iTellerIndex = vCollectionInfo.indexOf(vTellerInfo.elementAt(j));
		if(iTellerIndex == -1)
		{
			dTempCash  = 0d;
			dTempCheck = 0d;
			dTempCA    = 0d;
		}
		else
		{
			dTempCash  = Double.parseDouble((String)vCollectionInfo.elementAt(iTellerIndex+1));
			dTempCheck = Double.parseDouble((String)vCollectionInfo.elementAt(iTellerIndex+2));
			dTempCA    = Double.parseDouble((String)vCollectionInfo.elementAt(iTellerIndex+3));
		}

		dTotalCashPerCourse  += dTempCash ;
		dTotalCheckPerTeller += dTempCheck ;
		dTotalCAPerTeller    += dTempCA ;
		dTotalCashTeller[j/2]  += dTempCash;
		dTotalCheckTeller[j/2] += dTempCheck;
		dTotalCATeller[j/2]    += dTempCA;


	%>
      <td align="center"> <font size="1"> 
        <%//System.out.println(dTempCash);System.out.println(dTempCheck);System.out.println(dTempCA);
	if(dTempCash == 0f && dTempCheck == 0f && dTempCA == 0f){%>
        &nbsp; 
        <%}else{%>
        <%=CommonUtil.formatFloat(dTempCash,true)%>/ <%=CommonUtil.formatFloat(dTempCheck,true)%>/ <%=CommonUtil.formatFloat(dTempCA,true)%> 
        <%}%>
        </font></td>
      <%++j;
		if(iTellerIndex > -1) 
		{
			vCollectionInfo.removeElementAt(iTellerIndex);vCollectionInfo.removeElementAt(iTellerIndex);
			vCollectionInfo.removeElementAt(iTellerIndex);vCollectionInfo.removeElementAt(iTellerIndex);
			vCollectionInfo.removeElementAt(iTellerIndex);
		}
	}//end of for loop to display remittance.
	dTotalCash  += dTotalCashPerCourse ;
	dTotalCheck += dTotalCheckPerTeller ;
	dTotalCA    += dTotalCAPerTeller ;
%>
      <td align="center"> <font size="1"> 
        <%
	if(dTotalCashPerCourse == 0f && dTotalCheckPerTeller == 0f && dTotalCAPerTeller == 0f){%>
        &nbsp; 
        <%}else{%>
        <%=CommonUtil.formatFloat(dTotalCashPerCourse,true)%>/ <%=CommonUtil.formatFloat(dTotalCheckPerTeller,true)%> / <%=CommonUtil.formatFloat(dTotalCAPerTeller,true)%></font></td>
      <%}
	dTotalCashPerCourse = 0d;dTotalCheckPerTeller = 0d;dTotalCAPerTeller = 0d;%>
    </tr>
<%}//end of basic edu collection.
	
if(strErrMsg == null || strErrMsg.length() ==0){%>
    <tr> 
      <td height="25"><font size="1">TOTAL</font></td>
      <%
  for(int i=0; i<iNoOfTellers; ++i)
  {%>
      <td><font size="1"><%=CommonUtil.formatFloat(dTotalCashTeller[i],true)%>/ <%=CommonUtil.formatFloat(dTotalCheckTeller[i],true)%> / <%=CommonUtil.formatFloat(dTotalCATeller[i],true)%></font></td>
      <%}%>
      <td align="center"><font size="1"><%=CommonUtil.formatFloat(dTotalCash,true)%>/ <%=CommonUtil.formatFloat(dTotalCheck,true)%> / <%=CommonUtil.formatFloat(dTotalCA,true)%></font></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"><%=strErrMsg%></td>
    </tr>
    <%}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="26" colspan="5"><font size="1"><strong><em><font color="#0000FF">NOTE
        :</font> <font color="#0000FF">TOTAL = CASH/CHECK/SALARY DEDUCTION</font></em></strong></font></td>
      <td height="26" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25"><div align="right"><strong>TOTAL COLLECTION:
          &nbsp;</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </div></td>
      <td width="7%" height="25"><strong>CASH : </strong></td>
      <td width="20%" height="25"><strong>Php &nbsp;<%=CommonUtil.formatFloat(dTotalCash,true)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25">&nbsp;</td>
      <td height="25"><strong>CHECK : </strong></td>
      <td height="25"><strong>Php &nbsp;<%=CommonUtil.formatFloat(dTotalCheck,true)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25">&nbsp;</td>
      <td height="25"><strong>SD :</strong></td>
      <td height="25"><strong>Php &nbsp;<%=CommonUtil.formatFloat(dTotalCA,true)%></strong></td>
    </tr>
	<tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25" align="right"><strong>GRAND TOTAL COLLECTION:
        &nbsp;</strong>&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Php &nbsp;<%=CommonUtil.formatFloat(dTotalCA+dTotalCheck+dTotalCash,true)%></strong></td>
    </tr>
    <tr>
      <td width="6%" height="25">&nbsp;</td>
      <td colspan="4" height="25"><div align="left"><font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click
          to print summary of daily cash collection</font></font></div></td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>

<%}//outer loop if(vCourseOffered  != null && vTellerInfo)
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="7">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="7" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
