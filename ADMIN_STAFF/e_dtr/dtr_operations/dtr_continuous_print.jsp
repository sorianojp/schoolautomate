<%@page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR, eDTR.eDTRUtil" buffer="16kb"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
//if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
//	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print DTR</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="window.print()">
<%
 	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
    Vector vRetEDTR = new Vector();
	String strTemp2 = null;
	String strTemp3 = null;
	int iSearchResult =0;
	int iIndex = 0;
	int iDateFormat = 2; 	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-View/Print DTR","dtr_view.jsp");
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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(),
														"dtr_view.jsp");
														
 if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(),
														"dtr_view.jsp");
 }
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
if(strErrMsg == null) strErrMsg = "";


ReportEDTR RE = new ReportEDTR(request);
Vector vSummaryWrkHours = null;
Vector vHoursWork = null;
Vector vDayInterval = null;
Vector vDayIntervalTemp = null;
Vector vHoursOT = null;
String strDateFr = null;
String strDateTo = null;
int iIncr = 1;
int iTempMin = 0;
int iTempHr = 0;
int iRowCounter  = 0;

double dTemp = 0d;

		String strPrevDate = "";//this is added to avoid displaying date in 2nd row.
		boolean bolDateRepeated = false;

	String strLatePMEntry = null;
	String strUTPMEntry = null;
	String strCheckPMEntry = null;
	String strIndicator = null;
	String strLoginDate = null;
	String[] astrWeekday = {"","S","M","T","W","TH","F","SAT"};

	int iIndexOf = 0;
	String strHrsWork = null;

	double dHoursWork = 0d;
	long lCurrenTime  = 0l;
	// check the number of elements in the ReportEDTR.java file
	int iElementCount = 15;
//	long lSubTotalWorkingHr = 0l;//sub total total working hour of employee.
	long lGTWorkingHr = 0l;//Total working hour of the employee for the specified date.
	long lOTHours = 0l; // Total OT hour for the day


	double dOTTotal = 0l; // Total OT Hours for the specified date

	double dTotalHoursWork = 0d;

  if (WI.fillTextValue("viewRecords").equals("1")) {
	vRetResult = RE.searchEDTR(dbOP, false, true);
	
 	
	if (vRetResult == null)
		strErrMsg = RE.getErrMsg();

//added by biswa to get from and to date.
	if( WI.fillTextValue("DateDefaultSpecify").equals("0")) {
		String[] astrTemp = eDTRUtil.getCurrentCutoffDateRange(dbOP, true);
		if(astrTemp != null) {
			strDateFr = astrTemp[0];
			strDateTo = astrTemp[1];
		}
	}
	else {
		strDateFr = WI.fillTextValue("from_date");
		strDateTo = WI.fillTextValue("to_date");
	}

	if (WI.fillTextValue("SummaryDetail").equals("1")){
		vDayIntervalTemp = RE.getDayNDateDetail(strDateFr,strDateTo);

		if (vDayInterval == null)
			strErrMsg = RE.getErrMsg();
	}

}

 if (strErrMsg != null && strErrMsg.length() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" ><strong><font color="#FF0000" size="3">&nbsp;<%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>

<%} else if (WI.fillTextValue("viewRecords").equals("1")){
 	
	if (WI.fillTextValue("SummaryDetail").equals("0")){
  	vSummaryWrkHours = RE.computeWorkingHourSummary(dbOP,request, null);
		Vector vReqWrkHours = RE.computeRequiredHourSummary(dbOP, request, null);
	if (vRetResult != null) {
		iSearchResult = RE.getSearchCount();
	 //show this if page cournt >
	%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	 	<tr>

      <td width="66%" height="25"><b>Total Result: <%=iSearchResult%></b></td>
    </tr>
  </table>
	<%}%>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  class="thinborder">
    <tr>
      <td height="25" colspan="7" align="center" class="thinborder"><strong>DTR
          SUMMARY (From <%=strDateFr%> to <%=strDateTo%>)</strong></td>
    </tr>
<%
	if (vRetResult!=null) {
%>
    <tr >
      <td width="4%" align="center" class="thinborder">&nbsp;</td>
      <td width="12%" height="25" align="center" class="thinborder"><strong>ID NUMBER</strong></td>
      <td width="25%" height="25" align="center" class="thinborder"><strong>NAME</strong></td>
      <td width="23%" height="25" align="center" class="thinborder"><strong><%if(bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%>/OFFICE</strong></td>
      <td width="16%" align="center" class="thinborder"><strong>POSITION</strong></td>
      <td width="10%" height="25" align="center" class="thinborder"><strong>REQ
        HRS</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>&nbsp;HRS WORK </strong></td>
    </tr>
 <%
	for (int i=0; i<vRetResult.size() ; i+=13, iIncr++){
		strTemp = (String)vRetResult.elementAt(i+3);

		if(strTemp == null)
			strTemp = (String)vRetResult.elementAt(i+4);
		else if(vRetResult.elementAt(i+4) != null)
			strTemp += "/"+(String)vRetResult.elementAt(i+4);

	strTemp2 = "";
	if (vSummaryWrkHours != null && vSummaryWrkHours.size() > 0){
		iIndexOf  = vSummaryWrkHours.indexOf((String)vRetResult.elementAt(i));

		if (iIndexOf != -1){
			vSummaryWrkHours.removeElementAt(iIndexOf);
			strTemp2 = CommonUtil.formatFloat(((Double)vSummaryWrkHours.remove(iIndexOf)).doubleValue(), true);
		}
	}

// updated October 8, 2007
//		strTemp2 = CommonUtil.formatFloat(eDTRUtil.longHourToFloat(RE.computeWorkingHourSummary(dbOP,request,
//					                               (String)vRetResult.elementAt(i))),true);
%>
  <tr >
    <td align="right" class="thinborder"><%=iIncr%>&nbsp;</td>
  <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
  <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%>, <%=(String)vRetResult.elementAt(i+1)%> </td>
  <td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
  <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></td>
<%
	strTemp = "";
	if (vReqWrkHours != null && vReqWrkHours.size() > 0){
		iIndexOf  = vReqWrkHours.indexOf((String)vRetResult.elementAt(i));

		if (iIndexOf != -1){
			vReqWrkHours.removeElementAt(iIndexOf);
			strTemp = (String)vReqWrkHours.remove(iIndexOf);
		}
	}
%>
  <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"0.00")%></td>
  <td class="thinborder"><strong>&nbsp;&nbsp;<%=WI.getStrValue(strTemp2,"0.00")%></strong></td>
  </tr>
<% } // end for i < vRetResutl.size()
 } // if (vRetResult!=null)
else{ %>
    <tr>
      <td colspan="7" class="thinborder" > <strong><%=WI.getStrValue(RE.getErrMsg(),"")%></strong> <br>
        <strong> 0 RECORD FOUND</strong></td>
    </tr>
<%} // end error/no result%>
</table>
<% }
	else
   {  //end of display in  summary, begin of display in details


	/////////////////////////  display in details \\\\\\\\\\\\\\\\\\\\\\\\\\
	
//	long lStartTime = new java.util.Date().getTime();
 %>
  <% if (vRetResult!=null && vRetResult.size() > 0) {%>
  <% 
	lGTWorkingHr = 0l;//Total working hour of the employee for the specified date.
	lOTHours = 0l; // Total OT hour for the day


	dOTTotal = 0l; // Total OT Hours for the specified date

	dTotalHoursWork = 0d;
	
//as requestd, i have to show all the days worked and non worked.
  for (int i=0; i<vRetResult.size() ; i+=13){

	  strTemp = (String)vRetResult.elementAt(i+3);

	if(strTemp == null)
		strTemp = (String)vRetResult.elementAt(i+4);
	else if(vRetResult.elementAt(i+4) != null)
		strTemp += "/"+(String)vRetResult.elementAt(i+4);

	vDayIntervalTemp = vDayIntervalTemp;

%>
<%	if(i > 0  && false){
	//if(iRowCounter > 80){%>
	<div style="page-break-after:always">&nbsp;</div>
<% //iRowCounter = 0; 
} %>

<table width="100%" border="0" cellpadding="2" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
  <tr >
  	<% iRowCounter+=1; %>
    <td height="25" colspan="11" align="center" class="thinborder"><strong>DTR
      DETAILS (From <%=strDateFr%> to <%=strDateTo%>)</strong></td>
  </tr>
  <tr >
  	<% iRowCounter+=1; %>
    <td height="25" colspan="11" class="thinborder"><%=(String)vRetResult.elementAt(i)%> :: &nbsp; <%=(String)vRetResult.elementAt(i+2)%>, <%=(String)vRetResult.elementAt(i+1)%>  :: &nbsp; <%=WI.getStrValue(strTemp,"","::","")%><font color="#0000FF">&nbsp; </font> <%=(String)vRetResult.elementAt(i+5)%><br>
        <%=WI.getStrValue((String)vRetResult.elementAt(i+7), "Date Hired : ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+8), " -- ","","")%></td>
  </tr>
  <tr >
  	<% iRowCounter+=1; %>
    <td width="14%" height="25" align="center" class="thinborder"><strong><font size="1">DATE</font></strong></td>
    <td width="10%" align="center" class="thinborder"><strong><font size="1">TIME-IN</font></strong></td>
    <td width="6%" align="center" class="thinborder"><strong>LATE</strong></td>
    <td width="10%" align="center" class="thinborder"><strong><font size="1">TIME-OUT</font></strong></td>
    <td width="6%" align="center" class="thinborder"><strong>UT</strong></td>
    <td width="10%" align="center" class="thinborder"><strong><font size="1">TIME-IN</font></strong></td>
    <td width="6%" align="center" class="thinborder"><strong>LATE</strong></td>
    <td width="10%" align="center" class="thinborder"><strong><font size="1">TIME-OUT</font></strong></td>
    <td width="6%" align="center" class="thinborder"><strong>UT</strong></td>
    <td width="11%" align="center" class="thinborder"><strong><font size="1">NO. OF HOURS</font></strong></td>
    <td width="11%" align="center" class="thinborder"><strong><font size="1">OVERTIME</font></strong></td>
  </tr>
  <%

//long lCurrentTime =  new java.util.Date().getTime();

vRetEDTR = RE.getDTRDetails(dbOP,(String)vRetResult.elementAt(i), true, true);
vHoursWork = RE.computeWorkingHour(dbOP, (String)vRetResult.elementAt(i),
											strDateFr, strDateTo, null, null);
vHoursOT  =  RE.getOTHours(dbOP, (String)vRetResult.elementAt(i),
											strDateFr, strDateTo, null, null);
//System.out.println("vHoursOT " + vHoursOT);
if (vRetEDTR == null || vRetEDTR.size() ==  0) {
	strErrMsg=RE.getErrMsg();
}else{
	if (vRetEDTR.size() == 1){//non DTR employees
	
	iRowCounter+=1;
%>
  <tr>
    <td height="20" colspan="11" align="center" class="thinborder"><%=vRetEDTR.elementAt(0)%></td>
  </tr>
  <%}else{
		strTemp3 = "";

		strPrevDate = "";//this is added to avoid displaying date in 2nd row.
		bolDateRepeated = false;

		strLatePMEntry = null;
	  strUTPMEntry = null;
	
		strCheckPMEntry = null;

		iIndexOf = 0;
		strHrsWork = null;

		dHoursWork = 0d;
		lCurrenTime  = new java.util.Date().getTime();
		// check the number of elements in the ReportEDTR.java file
		iElementCount = 15;
	for(iIndex=0;iIndex<vRetEDTR.size();iIndex +=iElementCount){
 		strHrsWork = null;
		strTemp =(String)vRetEDTR.elementAt(iIndex+4);

		if (strTemp!=null &&  (iIndex+iElementCount) < vRetEDTR.size() &&
			strTemp.equals((String)vRetEDTR.elementAt(iIndex+iElementCount+4))){
			strTemp = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + iElementCount + 2)).longValue(),iDateFormat);
			strTemp2 = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + iElementCount + 3)).longValue(),iDateFormat);
			strLatePMEntry = WI.getStrValue((String)vRetEDTR.elementAt(iIndex+6+iElementCount));
			strUTPMEntry = WI.getStrValue((String)vRetEDTR.elementAt(iIndex+7+iElementCount));
			strCheckPMEntry = WI.getStrValue((String)vRetEDTR.elementAt(iIndex+8+iElementCount));
		}
		else {
			strTemp =  null;
			strTemp2 = null;
			strLatePMEntry = "";
			strUTPMEntry = "";
			strCheckPMEntry = "";
		}
		if(strPrevDate.equals((String)vRetEDTR.elementAt(iIndex+4))) {
			bolDateRepeated = true;
		}
		else {
			bolDateRepeated = false;
			strPrevDate = (String)vRetEDTR.elementAt(iIndex+4);
		}


//I ahve to display here for the days employee did not work.
if(!bolDateRepeated && vDayInterval != null && vDayInterval.size() > 0) {
	while(!strPrevDate.equals((String)vDayInterval.elementAt(0))) {
		iRowCounter+=1;
	%>
  <tr>
    <td height="20" class="thinborder" colspan="11" align="center"><%=(String)vDayInterval.remove(0)+":::"+(String)vDayInterval.remove(0)%></td>
  </tr>
  <%}//end of while looop
  if(vDayInterval.size() > 0)  {
  	vDayInterval.removeElementAt(0);vDayInterval.removeElementAt(0);
  }

}//end of if condition to print holidays.%>
  <tr>
  	<% iRowCounter+=1; %>
    <td height="20" class="thinborder">
		<%if(!bolDateRepeated){
			strLoginDate = (String)vRetEDTR.elementAt(iIndex+4);			
			%>
        <%=strLoginDate%>&nbsp;
				<%if(WI.fillTextValue("show_weekday").length() > 0){%>
					<%=astrWeekday[eDTR.eDTRUtil.getWeekDay(strLoginDate)]%>
				<%}%>
        <%}else{%>
      &nbsp;
      <%}%>
    </td>
		<%
			if(WI.fillTextValue("show_indicator").length() > 0)
				strIndicator = WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 8));
			else
				strIndicator = "";			
		%>
    <td class="thinborder"><%=WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 2)).longValue(),iDateFormat)%><%=strIndicator%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 6))%>&nbsp;</td>
    <td class="thinborder"><%=WI.getStrValue(WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 3)).longValue(),iDateFormat),
	  								"&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 7))%>&nbsp;</td>
		<%
			if(WI.fillTextValue("show_indicator").length() > 0)
				strIndicator = strCheckPMEntry;
			else
				strIndicator = "";		
		%>
    <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%><%=WI.getStrValue(strIndicator, "&nbsp;")%></td>
    <td class="thinborder"><%=strLatePMEntry%>&nbsp;</td>
    <td class="thinborder"><%=WI.getStrValue(strTemp2,"&nbsp;")%></td>
    <td class="thinborder"><%=strUTPMEntry%>&nbsp;</td>
    <%  // compute for the working hour for the day

//		System.out.println("heellow world");

		if(strTemp2 != null) iIndex += iElementCount;


//	 ---- Updated to Vector..
//		lSubTotalWorkingHr = RE.computeWorkingHour(dbOP, (String)vRetResult.elementAt(i),
//								(String)vRetEDTR.elementAt(iIndex+4));


//		System.out.println("lSubTotalWorkingHr : " + lSubTotalWorkingHr);

//		lOTHours = RE.getOTHours(dbOP,(String)vRetResult.elementAt(i),
//								(String)vRetEDTR.elementAt(iIndex+4));

//		if (lSubTotalWorkingHr < 0) lSubTotalWorkingHr = 0l;
//		if (lOTHours < 0) lOTHours = 0l;

//		if (!strTemp3.equals((String)vRetEDTR.elementAt(iIndex+4))){
//				strTemp3  = (String)vRetEDTR.elementAt(iIndex+4);
//				lGTWorkingHr += lSubTotalWorkingHr;
//				lOTTotal +=lOTHours;
//		}else{
//			lSubTotalWorkingHr = 0l;
//		}

		if (vHoursWork != null && vHoursWork.size() > 0){

			iIndexOf = vHoursWork.indexOf((String)vRetEDTR.elementAt(iIndex+4));
			if (iIndexOf != -1) {
				vHoursWork.removeElementAt(iIndexOf-1);
				vHoursWork.removeElementAt(iIndexOf-1);
				dHoursWork =((Double)vHoursWork.remove(iIndexOf-1)).doubleValue();
				if(WI.fillTextValue("show_actual").length() == 0)
					strHrsWork = CommonUtil.formatFloat(dHoursWork,true);
				else{
					iTempHr = (int)dHoursWork;
					dTemp = dHoursWork - iTempHr;
					iTempMin = (int)((dTemp * 60) + 0.2);
					strHrsWork = iTempHr + ":" + CommonUtil.formatMinute(Integer.toString(iTempMin));
				}
				dTotalHoursWork += dHoursWork;
			}
		}

		strTemp = null;
		if(iIndexOf != -1)
			strTemp = strHrsWork;
 	%>
    <td align="right" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
    <%		iIndexOf = -1;
			dHoursWork = 0d;
	if (vHoursOT != null && vHoursOT.size() > 0){
			iIndexOf = vHoursOT.indexOf((String)vRetEDTR.elementAt(iIndex+4));
			while (iIndexOf != -1) {
				vHoursOT.remove(iIndexOf);// remove date
				dTemp =((Double)vHoursOT.remove(iIndexOf)).doubleValue(); // remove hour
				vHoursOT.remove(iIndexOf-1);// remove index
				dHoursWork += dTemp;
				strHrsWork = CommonUtil.formatFloat(dHoursWork,true);
				dOTTotal += dTemp;
				iIndexOf = vHoursOT.indexOf((String)vRetEDTR.elementAt(iIndex+4));
			}
			if(WI.fillTextValue("show_actual").length() > 0){
				iTempHr = (int)dHoursWork;
				dTemp = dHoursWork - iTempHr;
				iTempMin = (int)((dTemp * 60) + 0.2);
				strHrsWork = iTempHr + ":" + CommonUtil.formatMinute(Integer.toString(iTempMin));
			}				
		} 
 		%>
    <td align="right" class="thinborder"><%=(dHoursWork > 0d)?strHrsWork:"&nbsp;"%></td>
  </tr>
   
	 
	<!-- break here  -->	
			
	 	
  <%
  			
	  } // end for loop	 
//	  System.out.println("Time : " + (lCurrenTime - new java.util.Date().getTime()));

	  //I have to now print if there are any days having zero working hours.
	while(vDayInterval != null && vDayInterval.size() > 0) {
	%>
  <tr>
  	<%iRowCounter+=1; %>
    <td height="20" class="thinborder" colspan="11" align="center"><%=(String)vDayInterval.remove(0)+":::"+(String)vDayInterval.remove(0)%></td>
  </tr>
  <%}//end of while looop

	
	 }
	}
	%>
  <tr >
  	<% iRowCounter+=1; %>
    <td height="20" colspan="8" align="right" class="thinborder"><strong>TOTAL
      HOURS WORKED</strong>&nbsp;&nbsp;&nbsp;</td>
    <td align="center" class="thinborder">&nbsp;</td>
		<%
				if(WI.fillTextValue("show_actual").length() == 0)
					strTemp = CommonUtil.formatFloat(dTotalHoursWork,true);
				else{
					iTempHr = (int)dTotalHoursWork;
					dTemp = dTotalHoursWork - iTempHr;
					iTempMin = (int)((dTemp * 60) + 0.2);
					strTemp = iTempHr + ":" + CommonUtil.formatMinute(Integer.toString(iTempMin));
				}		
		%>			
    <td align="right" class="thinborder"><%=strTemp%></td>
		<%
				if(WI.fillTextValue("show_actual").length() == 0)
					strTemp = CommonUtil.formatFloat(dOTTotal,true);
				else{
					iTempHr = (int)dOTTotal;
					dTemp = dOTTotal - iTempHr;
					iTempMin = (int)((dTemp * 60) + 0.2);
					strTemp = iTempHr + ":" + CommonUtil.formatMinute(Integer.toString(iTempMin));
				}		
		%>			
    <td align="right" class="thinborder"><%=strTemp%></td>
  </tr>
</table>
  <%
	dTotalHoursWork = 0d;
	dOTTotal = 0d;
	  }
	%>
<% } // if (vRetResult!=null && vRetResult.size() > 0)%>
<%}// end if(vRetEDTR == null || vRetEDTR.size() ==  0)
 }//%>
</body>
</html>
<%
dbOP.cleanUP();
%>
