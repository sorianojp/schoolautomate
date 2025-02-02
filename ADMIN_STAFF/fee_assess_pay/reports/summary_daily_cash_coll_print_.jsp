<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>SUMMARY DAILY CASH COLLECTION</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
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
	vCourseOffered = DC.getCoursesOffered(dbOP);
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
<body >
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td height="20" colspan="2" ><div align="center">
	<font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></div></td>
  </tr>
  <tr > 
    <td height="20" colspan="2" ><div align="center">SUMMARY 
        OF DAILY CASH COLLECTION REPORT</div></td>
  </tr>
  <tr > 
    <td height="20" colspan="2" ><div align="center">DATE : <strong><%=WI.fillTextValue("date_of_col")%></strong></div></td>
  </tr>
</table>
<%
if(strErrMsg != null){
dbOP.cleanUP();%>
<table width="100%" cellpadding="0" cellspacing="0">
 <tr>
	<td><font size="3">Error in processing : <%=strErrMsg%></font>
	</td>
 </tr>
</table>
<%return;
}
if(vCourseOffered  != null && vTellerInfo != null){%>
 <table  width="100%" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" align="center" width="10%" class="thinborder"><font size="1"><strong>COURSE/<br>CATEGORY</strong></font></td>
      <td colspan="<%=iNoOfTellers%>" align="center" class="thinborder"><font size="1"><strong>NAME OF TELLERS</strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>TOTAL</strong></font></td>
    </tr>

    <tr> 
      <td height="20" class="thinborder">&nbsp;</td>
	<%//System.out.println(vTellerInfo);//System.out.println(vCollectionInfo);
	for(int j=0; j<vTellerInfo.size(); ++j)
	{%>
	<td align="center" class="thinborder"><%=(String)vTellerInfo.elementAt(j+1)%></td>
	<%++j;}%>
	<td align="center" class="thinborder">&nbsp;</td>
    </tr>

<%
float fTotalCashPerCourse  = 0f;
float fTotalCheckPerCourse = 0f;
float fTotalCAPerCourse    = 0f;

float fTotalCashPerTeller  = 0f;
float fTotalCheckPerTeller = 0f;
float fTotalCAPerTeller    = 0f;

float fTotalCash  = 0f;
float fTotalCheck = 0f;
float fTotalCA    = 0f;

int iTellerIndex  = 0;
float fTempCash   = 0f;
float fTempCheck  = 0f;
float fTempCA     = 0f;

float[] fTotalCashTeller  = new float[iNoOfTellers];
float[] fTotalCheckTeller = new float[iNoOfTellers];
float[] fTotalCATeller    = new float[iNoOfTellers];

strErrMsg = "";
for(int i=0; i<vCourseOffered.size(); i += 2)
{
	vCollectionInfo = DC.summaryDailyCashCollectionPerCourse(dbOP,WI.fillTextValue("teller_id"),WI.fillTextValue("date_of_col"),
							(String)vCourseOffered.elementAt(i));
	
	fTotalCash  += fTotalCashPerCourse ;
	fTotalCheck += fTotalCheckPerTeller ;
	fTotalCA    += fTotalCAPerTeller ;
	fTotalCashPerCourse = 0f;fTotalCheckPerTeller = 0f;fTotalCAPerTeller = 0f;
		
	if(vCollectionInfo == null)
	{
		strErrMsg = DC.getErrMsg();
		break;
	}
%>
    <tr> 
      <td height="24" class="thinborder"><%=(String)vCourseOffered.elementAt(i+1)%></td>
	<%
	for(int j=0; j<vTellerInfo.size(); ++j)
	{
		iTellerIndex = -1;
		if(vTellerInfo.size() > j)
			iTellerIndex = vCollectionInfo.indexOf(vTellerInfo.elementAt(j));
		if(iTellerIndex == -1)
		{
			fTempCash  = 0f;
			fTempCheck = 0f;
			fTempCA    = 0f;
		}
		else if(vCollectionInfo.size() > iTellerIndex + 1)
		{
			fTempCash  = Float.parseFloat((String)vCollectionInfo.elementAt(iTellerIndex+1));
			fTempCheck = Float.parseFloat((String)vCollectionInfo.elementAt(iTellerIndex+2));
			fTempCA    = Float.parseFloat((String)vCollectionInfo.elementAt(iTellerIndex+3));	
		}
		fTotalCashPerCourse  += fTempCash ;
		fTotalCheckPerTeller += fTempCheck ;
		fTotalCAPerTeller    += fTempCA ;
		fTotalCashTeller[j/2]  += fTempCash;
		fTotalCheckTeller[j/2] += fTempCheck;
		fTotalCATeller[j/2]    += fTempCA;
		
		
	%>
	<td align="center" class="thinborder">
	<%//System.out.println(fTempCash);System.out.println(fTempCheck);System.out.println(fTempCA);
	if(fTempCash == 0f && fTempCheck == 0f && fTempCA == 0f){%>
	&nbsp;
	<%}else{%>
	<%=CommonUtil.formatFloat(fTempCash,true)%>/ <%=CommonUtil.formatFloat(fTempCheck,true)%>/ <%=CommonUtil.formatFloat(fTempCA,true)%>
	<%}%>
	</td>
	<%++j;}%>
	<td align="center" class="thinborder">
	<%
	if(fTotalCashPerCourse == 0f && fTotalCheckPerTeller == 0f && fTotalCAPerTeller == 0f){%>
	&nbsp;
	<%}else{%>
	<%=CommonUtil.formatFloat(fTotalCashPerCourse,true)%>/ <%=CommonUtil.formatFloat(fTotalCheckPerTeller,true)%>
						/ <%=CommonUtil.formatFloat(fTotalCAPerTeller,true)%></td>
    <%}%>
	</tr>
<%}//end of for(int i=0; i<vCourseOffered.size(); i += 2)

//I have to now get the daily cash collection for external payment type.. for example if payee is not a student / does not have ID.
vCollectionInfo = DC.summaryDailyCashCollectionPerCourse(dbOP,WI.fillTextValue("teller_id"),WI.fillTextValue("date_of_col"),null);
//System.out.println(vCollectionInfo);
 if(vCollectionInfo != null && vCollectionInfo.size() > 0){%>   <tr>
      <td height="25" class="thinborder">External payment</td>
	<%
			fTempCash  = 0f;
			fTempCheck = 0f;
			fTempCA    = 0f;
	for(int j=0; j<vTellerInfo.size(); ++j)
	{
		iTellerIndex = vCollectionInfo.indexOf(vTellerInfo.elementAt(j));
		if(iTellerIndex == -1)
		{
			fTempCash  = 0f;
			fTempCheck = 0f;
			fTempCA    = 0f;
		}
		else
		{
			fTempCash  = Float.parseFloat((String)vCollectionInfo.elementAt(iTellerIndex+1));
			fTempCheck = Float.parseFloat((String)vCollectionInfo.elementAt(iTellerIndex+2));
			fTempCA    = Float.parseFloat((String)vCollectionInfo.elementAt(iTellerIndex+3));
		}

		fTotalCashPerCourse  += fTempCash ;
		fTotalCheckPerTeller += fTempCheck ;
		fTotalCAPerTeller    += fTempCA ;
		fTotalCashTeller[j/2]  += fTempCash;
		fTotalCheckTeller[j/2] += fTempCheck;
		fTotalCATeller[j/2]    += fTempCA;


	%>
	<td align="center" class="thinborder">
	<%//System.out.println(fTempCash);System.out.println(fTempCheck);System.out.println(fTempCA);
	if(fTempCash == 0f && fTempCheck == 0f && fTempCA == 0f){%>
	&nbsp;
	<%}else{%>
	<%=CommonUtil.formatFloat(fTempCash,true)%>/ <%=CommonUtil.formatFloat(fTempCheck,true)%>/ <%=CommonUtil.formatFloat(fTempCA,true)%>
	<%}%>
	</td>
	<%++j;}
	fTotalCash  += fTotalCashPerCourse ;
	fTotalCheck += fTotalCheckPerTeller ;
	fTotalCA    += fTotalCAPerTeller ;

%>
	<td align="center" class="thinborder">
	<%
	if(fTotalCashPerCourse == 0f && fTotalCheckPerTeller == 0f && fTotalCAPerTeller == 0f){%>
	&nbsp;
	<%}else{%>
	<%=CommonUtil.formatFloat(fTotalCashPerCourse,true)%>/ <%=CommonUtil.formatFloat(fTotalCheckPerTeller,true)%>
						/ <%=CommonUtil.formatFloat(fTotalCAPerTeller,true)%></td>
    <%}fTotalCashPerCourse = 0f;fTotalCheckPerTeller = 0f;fTotalCAPerTeller = 0f;%>
	</tr>
<%}//end of for(int i=0; i<vCourseOffered.size(); i += 2)
//I have to collect the daily remittance here. 
vCollectionInfo = DC.viewRemittanceCollectionDetail(dbOP,WI.fillTextValue("teller_id"),WI.fillTextValue("date_of_col"));
//System.out.println(vCollectionInfo);
 while(vCollectionInfo != null && vCollectionInfo.size() > 0){
 			fTempCash  = 0f;
			fTempCheck = 0f;
			fTempCA    = 0f;%>   
	<%
	for(int j=0; j<vTellerInfo.size(); ++j)
	{
		iTellerIndex = vCollectionInfo.indexOf(vTellerInfo.elementAt(j));
		if(iTellerIndex == -1)
		{
			fTempCash  = 0f;
			fTempCheck = 0f;
			fTempCA    = 0f;
		}
		else
		{
			fTempCash  = Float.parseFloat((String)vCollectionInfo.elementAt(iTellerIndex+1));
			fTempCheck = Float.parseFloat((String)vCollectionInfo.elementAt(iTellerIndex+2));
			fTempCA    = Float.parseFloat((String)vCollectionInfo.elementAt(iTellerIndex+3));
		}

		fTotalCashPerCourse  += fTempCash ;
		fTotalCheckPerTeller += fTempCheck ;
		fTotalCAPerTeller    += fTempCA ;
		fTotalCashTeller[j/2]  += fTempCash;
		fTotalCheckTeller[j/2] += fTempCheck;
		fTotalCATeller[j/2]    += fTempCA;


	%>
	<tr>
      <td height="25" class="thinborder">Remittance (<%=(String)vCollectionInfo.elementAt(iTellerIndex+5)%>)</td>

	<td align="center" class="thinborder">
	<%//System.out.println(fTempCash);System.out.println(fTempCheck);System.out.println(fTempCA);
	if(fTempCash == 0f && fTempCheck == 0f && fTempCA == 0f){%>
	&nbsp;
	<%}else{%>
	<%=CommonUtil.formatFloat(fTempCash,true)%>/ <%=CommonUtil.formatFloat(fTempCheck,true)%>/ <%=CommonUtil.formatFloat(fTempCA,true)%>
	<%}%>
	</td>
	<%++j;
	if(iTellerIndex > -1) {
		vCollectionInfo.removeElementAt(iTellerIndex);vCollectionInfo.removeElementAt(iTellerIndex);
		vCollectionInfo.removeElementAt(iTellerIndex);vCollectionInfo.removeElementAt(iTellerIndex);
		vCollectionInfo.removeElementAt(iTellerIndex);vCollectionInfo.removeElementAt(iTellerIndex);
	}
}
fTotalCash  += fTotalCashPerCourse ;
fTotalCheck += fTotalCheckPerTeller ;
fTotalCA    += fTotalCAPerTeller ;%>
	<td align="center" class="thinborder">
	<%
	if(fTotalCashPerCourse == 0f && fTotalCheckPerTeller == 0f && fTotalCAPerTeller == 0f){%>
	&nbsp;
	<%}else{%>
	<%=CommonUtil.formatFloat(fTotalCashPerCourse,true)%>/ <%=CommonUtil.formatFloat(fTotalCheckPerTeller,true)%>
						/ <%=CommonUtil.formatFloat(fTotalCAPerTeller,true)%></td>
    <%}
	fTotalCashPerCourse = 0f;fTotalCheckPerTeller = 0f;fTotalCAPerTeller = 0f;%>
	</tr>
    <%}//end of displaying remittance. I have to show here basic edu collection.
//Basic education collection.
vCollectionInfo = DC.viewBasicColDetail(dbOP,WI.fillTextValue("teller_id"),WI.fillTextValue("date_of_col"));
//System.out.println(vCollectionInfo);
 while(vCollectionInfo != null && vCollectionInfo.size() > 0){
 			fTempCash  = 0f;
			fTempCheck = 0f;
			fTempCA    = 0f;%>
    <tr> 
      <td height="25" class="thinborder">Basic Edu</td>
      <%
	for(int j=0; j<vTellerInfo.size(); ++j)
	{
		iTellerIndex = vCollectionInfo.indexOf(vTellerInfo.elementAt(j));
		if(iTellerIndex == -1)
		{
			fTempCash  = 0f;
			fTempCheck = 0f;
			fTempCA    = 0f;
		}
		else
		{
			fTempCash  = Float.parseFloat((String)vCollectionInfo.elementAt(iTellerIndex+1));
			fTempCheck = Float.parseFloat((String)vCollectionInfo.elementAt(iTellerIndex+2));
			fTempCA    = Float.parseFloat((String)vCollectionInfo.elementAt(iTellerIndex+3));
		}

		fTotalCashPerCourse  += fTempCash ;
		fTotalCheckPerTeller += fTempCheck ;
		fTotalCAPerTeller    += fTempCA ;
		fTotalCashTeller[j/2]  += fTempCash;
		fTotalCheckTeller[j/2] += fTempCheck;
		fTotalCATeller[j/2]    += fTempCA;


	%>
      <td align="center" class="thinborder">
        <%//System.out.println(fTempCash);System.out.println(fTempCheck);System.out.println(fTempCA);
	if(fTempCash == 0f && fTempCheck == 0f && fTempCA == 0f){%>
        &nbsp; 
        <%}else{%>
        <%=CommonUtil.formatFloat(fTempCash,true)%>/ <%=CommonUtil.formatFloat(fTempCheck,true)%>/ <%=CommonUtil.formatFloat(fTempCA,true)%> 
        <%}%>
        </td>
      <%++j;
		if(iTellerIndex > -1) 
		{
			vCollectionInfo.removeElementAt(iTellerIndex);vCollectionInfo.removeElementAt(iTellerIndex);
			vCollectionInfo.removeElementAt(iTellerIndex);vCollectionInfo.removeElementAt(iTellerIndex);
			vCollectionInfo.removeElementAt(iTellerIndex);
		}
	}//end of for loop to display remittance.
	fTotalCash  += fTotalCashPerCourse ;
	fTotalCheck += fTotalCheckPerTeller ;
	fTotalCA    += fTotalCAPerTeller ;
%>
      <td align="center" class="thinborder"> 
        <%
	if(fTotalCashPerCourse == 0f && fTotalCheckPerTeller == 0f && fTotalCAPerTeller == 0f){%>
        &nbsp; 
        <%}else{%>
        <%=CommonUtil.formatFloat(fTotalCashPerCourse,true)%>/ <%=CommonUtil.formatFloat(fTotalCheckPerTeller,true)%> / <%=CommonUtil.formatFloat(fTotalCAPerTeller,true)%></td>
      <%}
	fTotalCashPerCourse = 0f;fTotalCheckPerTeller = 0f;fTotalCAPerTeller = 0f;%>
    </tr>
<%}//end of basic edu collection.

if(strErrMsg == null || strErrMsg.length() ==0){%>
	
    <tr> 
      <td height="25" class="thinborder">TOTAL</td>
  <%
  for(int i=0; i<iNoOfTellers; ++i)
  {%>    
      <td class="thinborder"><%=CommonUtil.formatFloat(fTotalCashTeller[i],true)%>/ <%=CommonUtil.formatFloat(fTotalCheckTeller[i],true)%>
						/ <%=CommonUtil.formatFloat(fTotalCATeller[i],true)%></td>
  <%}%>
	  <td align="center" class="thinborder"><%=CommonUtil.formatFloat(fTotalCash,true)%>/ <%=CommonUtil.formatFloat(fTotalCheck,true)%>
						/ <%=CommonUtil.formatFloat(fTotalCA,true)%></td>
    </tr>
<%}else{%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;</td>
      
      <td colspan="2" class="thinborder"><%=strErrMsg%></td>
    </tr>
<%}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
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
      <td width="20%" height="25"><strong>Php &nbsp;<%=CommonUtil.formatFloat(fTotalCash,true)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25">&nbsp;</td>
      <td height="25"><strong>CHECK : </strong></td>
      <td height="25"><strong>Php &nbsp;<%=CommonUtil.formatFloat(fTotalCheck,true)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25">&nbsp;</td>
      
    <td height="25"><strong>SD :</strong></td>
      <td height="25"><strong>Php &nbsp;<%=CommonUtil.formatFloat(fTotalCA,true)%></strong></td>
    </tr>
	<tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25" align="right"><strong>GRAND TOTAL COLLECTION: 
        &nbsp;</strong>&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Php &nbsp;<%=CommonUtil.formatFloat(fTotalCA+fTotalCheck+fTotalCash,true)%></strong></td>
    </tr>
  </table>
<script language="JavaScript">
window.print();
</script>
<%
	}//if collection information is not null.
%>
</body>
</html>
<%
 dbOP.cleanUP();
%> 
