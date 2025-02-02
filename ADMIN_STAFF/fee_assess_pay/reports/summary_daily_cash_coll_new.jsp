<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	String strPrepareToEdit=WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","summary_daily_cash_coll_new.jsp");
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
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Summary of daily cash collection</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
/**
	if(document.daily_cash.date_of_col.value.length ==0) {
		alert("Please enter date of collection.");
		return;
	}
	//I have to call here the print page.
	var pgLoc = "./summary_daily_cash_coll_new_print.jsp?date_of_col="+document.daily_cash.date_of_col.value+
	"&teller_id="+escape(document.daily_cash.teller_id.value);
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
*/
//I AM JUST DELETING THE TABLE TO PRINT THIS PAGE. NO RELOADING.
	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable').deleteRow(0);
	document.getElementById('myADTable').deleteRow(0);
	document.getElementById('myADTable').deleteRow(0);
	document.getElementById('myADTable').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
<%
strTemp = WI.fillTextValue("date_of_col");
if(WI.fillTextValue("date_of_col_to").length() > 0) {
	strTemp = strTemp + " to " +WI.fillTextValue("date_of_col_to");
}
%>
	var strInfo = "<div align=\"center\"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font>";
	strInfo += "<font size =\"1\">SUMMARY OF DAILY CASH COLLECTION REPORT<br><br>DATE OF COLLECTION :<b><%=strTemp%></b></font></div>";
	this.insRowVarTableID('myADTable3',0, 1, strInfo);

	alert("Click OK to print this page");
	window.print();
}
</script>
<body bgcolor="#D2AE72">
<%
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"summary_daily_cash_coll_new.jsp");
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
Vector vTellerInfo     = null; Vector vTellerInfoWithID = null;//use this to get teller info with ID./
Vector vBasicSchoolCodes = null; 

boolean bolRemoveLacInfo = false;
Vector vCollectionInfo = null;
int iNoOfTellers       = 0;
Vector vRetResult      = null;

DailyCashCollection DC   = new DailyCashCollection();
if(WI.fillTextValue("date_of_col_to").length() > 0) {
	DC.strCollectionDateTo = WI.fillTextValue("date_of_col_to");
}
if(WI.fillTextValue("date_of_col").length() > 0)
{
	vCourseOffered = DC.getCoursesOffered(dbOP);//System.out.println(vCourseOffered);
	if(vCourseOffered == null)
		strErrMsg = DC.getErrMsg();
	else
	{
		vTellerInfo = DC.getTellerForADay(dbOP,WI.fillTextValue("date_of_col"),WI.fillTextValue("teller_id"), false);
		vTellerInfoWithID = DC.getTellerForADay(dbOP,WI.fillTextValue("date_of_col"),WI.fillTextValue("teller_id"), true);
		if(vTellerInfo == null)
			strErrMsg = DC.getErrMsg();
	}
	if(strErrMsg == null)  {
		vRetResult = DC.summaryDailyCashCollection(dbOP,WI.fillTextValue("date_of_col"),request.getParameter("teller_id"));
		
		if(vRetResult == null) 
			strErrMsg = DC.getErrMsg();
		else {
			vBasicSchoolCodes = DC.getBasicSchoolCodes(dbOP, null);
			//System.out.println(vRetResult);
	
			if(vRetResult.indexOf("Lacking Info") != -1)  {
				bolRemoveLacInfo = true;
				vCourseOffered.addElement("0");
				vCourseOffered.addElement("Lacking Info");
			}
			
			if (!strSchCode.startsWith("VMUF")) {
				if(vRetResult.indexOf("Basic Education") != -1)  {
					vCourseOffered.addElement("0");
					vCourseOffered.addElement("Basic Education");
				}
			}else if ( vBasicSchoolCodes != null && vBasicSchoolCodes.size() > 0) {
				for (int j = 0; j < vBasicSchoolCodes.size(); j+=2){
					if(vRetResult.indexOf("Basic Education : " + (String)vBasicSchoolCodes.elementAt(j+1)) != -1)  {
						vCourseOffered.addElement("0");
						vCourseOffered.addElement("Basic Education : " + (String)vBasicSchoolCodes.elementAt(j+1));
					}
				}
			}
			
		}
			
	}
}
//System.out.println(vTellerInfoWithID);
//System.out.println(vTellerInfo);

if(vTellerInfo != null)
	iNoOfTellers = vTellerInfo.size()/2;

%>
<form name="daily_cash" action="./summary_daily_cash_coll_new.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable3">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center">
	  <strong>SUMMARY OF DAILY CASH COLLECTION REPORT</strong></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Tell ID : 
        <input name="teller_id" type="text" size="16" value="<%=WI.fillTextValue("teller_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        (only if summary of daily cash collection is for one teller)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"> <%
strTemp = WI.fillTextValue("remove_college");
if(strTemp.compareTo("1") == 0) 
	strTemp = " checked";
else	
	strTemp = "";
%> <input type="checkbox" name="remove_college" value="1"<%=strTemp%>> 
        <font color="#0000FF">Remove Colleges from list if no collection for the 
        day.</font></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td height="25">Reference Date <font size="1"> 
<%
	strTemp = WI.fillTextValue("date_of_col");
	if(strTemp.length() == 0) 
		strTemp = WI.getTodaysDate(1);
%>
        <input name="date_of_col" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('daily_cash.date_of_col');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
		
		<%if(strSchCode != null && (strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC") || strSchCode.startsWith("CLDH") || strSchCode.startsWith("AUF")) ) {%>        
		to 
		<%
		strTemp = WI.fillTextValue("date_of_col_to");
		%>
			   <input name="date_of_col_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('daily_cash.date_of_col_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
				(for one day, leave to field empty.)
		<%}//show date to only for CGH%>
		</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="image" src="../../../images/form_proceed.gif" width="81" height="21"></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>
 <%
if(vCourseOffered  != null && vTellerInfo != null && vRetResult != null){
String strTellerID = null;
String strCourseCode = null;
int iIndex = 0;
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" align="center" width="10%" class="thinborder"><font size="1"><strong>COURSE/<br>
        CATEGORY</strong></font></td>
      <td colspan="<%=iNoOfTellers%>" align="center" class="thinborder"><font size="1"><strong>NAME 
        OF TELLER/S</strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>TOTAL</strong></font></td>
    </tr>
    <tr> 
      <td class="thinborder"><font size="1">&nbsp;</font></td>
      <%//System.out.println(vTellerInfo);//System.out.println(vCollectionInfo);
	for(int j=0; j<vTellerInfo.size(); ++j){%>
      <td align="center" class="thinborder"><font size="1"><%=(String)vTellerInfo.elementAt(j+1)%></font></td>
      <%++j;}%>
      <td align="center" class="thinborder"><font size="1">&nbsp;</font></td>
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
////remove coleges from list if there is no collection only if selected. 
if(WI.fillTextValue("remove_college").length() > 0) {
	for(int i = 0; i < vCourseOffered.size(); i += 2){
		if(vRetResult.indexOf(vCourseOffered.elementAt(i + 1)) == -1) {
			vCourseOffered.removeElementAt(i);vCourseOffered.removeElementAt(i);
			i -= 2;
		}
			
	}
}

////////////////////////////////////////////////////////////// start of college collection. //////////////////////////////////////////
String strTRCol = null;//if it has information 
//System.out.println(vRetResult);
for(int i=0; i<vCourseOffered.size(); i += 2) {
strCourseCode = (String)vCourseOffered.elementAt(i+1);
if(strCourseCode.compareTo("Lacking Info") == 0) 
	strTRCol = "#FFFF00";
else
	strTRCol = "";
//System.out.println(strCourseCode);	%>
    <tr bgcolor="<%=strTRCol%>"> 
      <td height="20" class="thinborder"><font size="1"><%=(String)vCourseOffered.elementAt(i+1)%></font></td>
      <%
	//System.out.println(vCollectionInfo);
	for(int j=0; j<vTellerInfoWithID.size(); ++j)	{
		strTellerID = (String)vTellerInfoWithID.elementAt(j);
		//System.out.println(strTellerID);
		//if(strTellerID.equals("E-081") && strCourseCode.equals("BSCrim"))
		//	System.out.println(vRetResult);
		iIndex = vRetResult.indexOf(strCourseCode);//System.out.prinltn("What to do.");
		if(iIndex == -1 || strTellerID.compareTo((String)vRetResult.elementAt(iIndex - 1)) != 0) {
			dTempCash  = 0d;
			dTempCheck = 0d;
			dTempCA    = 0d;
		}
		else {
			dTempCash  = Double.parseDouble((String)vRetResult.elementAt(iIndex+1));
			dTempCheck = Double.parseDouble((String)vRetResult.elementAt(iIndex+2));
			dTempCA    = Double.parseDouble((String)vRetResult.elementAt(iIndex+3));
			
			vRetResult.removeElementAt(iIndex); vRetResult.removeElementAt(iIndex); vRetResult.removeElementAt(iIndex);
			vRetResult.removeElementAt(iIndex);   vRetResult.removeElementAt(iIndex); vRetResult.removeElementAt(iIndex-1);//System.out.println(vRetResult);
		}
		dTotalCashPerCourse    += dTempCash ;
		dTotalCheckPerTeller   += dTempCheck ;
		dTotalCAPerTeller      += dTempCA ;
		dTotalCashTeller[j/2]  += dTempCash;
		dTotalCheckTeller[j/2] += dTempCheck;
		dTotalCATeller[j/2]    += dTempCA;


	%>
      <td align="center" class="thinborder"> <font size="1"> 
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
      <td align="center" class="thinborder"> <font size="1"> 
        <%
	if(dTotalCashPerCourse == 0f && dTotalCheckPerTeller == 0f && dTotalCAPerTeller == 0f){%>
        &nbsp; 
        <%}else{%>
        <%=CommonUtil.formatFloat(dTotalCashPerCourse,true)%>/ <%=CommonUtil.formatFloat(dTotalCheckPerTeller,true)%> / <%=CommonUtil.formatFloat(dTotalCAPerTeller,true)%></font></td>
      <%}
	dTotalCashPerCourse = 0d;dTotalCheckPerTeller = 0d;dTotalCAPerTeller = 0d;%>
    </tr>
    <%}//end of display per college.
	
//I have to remove the Lacking Info added, if i have added.
if(	bolRemoveLacInfo) {
	vCourseOffered.removeElementAt(vCourseOffered.size() - 1);
	vCourseOffered.removeElementAt(vCourseOffered.size() - 1);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//I have to now get the daily cash collection for external payment type.. for example if payee is not a student / does not have ID.
vCollectionInfo = DC.summaryDailyCashCollectionPerCourse(dbOP,WI.fillTextValue("teller_id"),WI.fillTextValue("date_of_col"),null);
//System.out.println(vCollectionInfo);
 if(vCollectionInfo != null && vCollectionInfo.size() > 0){%>
    <tr> 
      <td height="20" class="thinborder"><font size="1">External payment</font></td>
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
      <td align="center" class="thinborder"> <font size="1"> 
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
      <td align="center" class="thinborder"> <font size="1"> 
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
      <td height="20" class="thinborder"><font size="1">Remittance 
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
      <td align="center" class="thinborder"> <font size="1"> 
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
      <td align="center" class="thinborder"> <font size="1"> 
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
      <td height="20" class="thinborder"><font size="1">Basic Payment</font></td>
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
      <td align="center" class="thinborder"> <font size="1"> 
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
      <td align="center" class="thinborder"> <font size="1"> 
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
      <td height="20" class="thinborder"><font size="1">TOTAL</font></td>
  <%
  for(int i=0; i<iNoOfTellers; ++i)
  {%>
      <td class="thinborder"><font size="1"><%=CommonUtil.formatFloat(dTotalCashTeller[i],true)%>/ <%=CommonUtil.formatFloat(dTotalCheckTeller[i],true)%> / <%=CommonUtil.formatFloat(dTotalCATeller[i],true)%></font></td>
  <%}%>
      <td align="center" class="thinborder"><font size="1"><%=CommonUtil.formatFloat(dTotalCash,true)%>/ <%=CommonUtil.formatFloat(dTotalCheck,true)%> / <%=CommonUtil.formatFloat(dTotalCA,true)%></font></td>
    </tr>
<%if(strSchCode.startsWith("UDMC") && WI.fillTextValue("date_of_col_to").length() == 0) {
	Vector vORRange = null;
	String strORRange = null;
	%>
    <tr> 
      <td height="20" class="thinborder"><font size="1">OR Range</font></td>
  <%
  for(int i=0; i<iNoOfTellers; ++i)
  {//System.out.println(vTellerInfo.elementAt(i * 2));
  	vORRange = DC.getOrNumberRangeUsed(dbOP, (String)vTellerInfo.elementAt(i * 2),  WI.fillTextValue("date_of_col"));
	//System.out.println(vORRange);
	if(vORRange != null && vORRange.size() > 0 && vORRange.elementAt(0) != null) 
		strORRange = (String)vORRange.elementAt(0) + " to "+(String)vORRange.elementAt(vORRange.size() - 1);
	else {
		strORRange = "";
	}
  %>
      <td class="thinborder"><font size="1">&nbsp;<%=strORRange%></font></td>
  <%}%>
      <td align="center" class="thinborder">&nbsp;</td>
    </tr>
    <%}//show only if UDMC.
	}else{%>
    <tr> 
      <td class="thinborder">&nbsp;</td>
      <td colspan="2" class="thinborder"><%=strErrMsg%></td>
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
      <td width="6%" height="25">&nbsp;</td>
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
  </table>

<%}//outer loop if(vCourseOffered  != null && vTellerInfo)
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td width="94%" height="25">
<%if(vCourseOffered  != null && vTellerInfo != null && vRetResult != null){%>
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">click to print summary of daily cash collection</font>
<%}%>
	  </td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
