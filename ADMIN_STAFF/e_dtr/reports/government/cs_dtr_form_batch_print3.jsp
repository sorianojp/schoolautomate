<%@ page language="java" import="utility.*, eDTR.ReportEDTR,eDTR.eDTRUtil, eDTR.WorkingHour,
																java.util.Vector, java.util.Calendar,java.util.Date, 
																eDTR.AllowedLateTimeIN, eDTR.ReportEDTRExtn, payroll.PReDTRME"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>

</head>
 <script language="JavaScript" src="../../../../jscript/common.js"></script>
 <script language="JavaScript">
function copyLabel() {

	var iMaxItems = document.form_.emp_count.value;
	for(var i = 1; i <= iMaxItems;i++){
		if(!document.getElementById("copy_label_"+i) || !document.getElementById("main_label_"+i))
			return;		
		document.getElementById("copy_label_"+i).innerHTML = document.getElementById("main_label_"+i).innerHTML;
	}
}
</script>



<body onLoad="javascript:copyLabel();window.print();">
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode =  "";

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strAWOL = " AWOL (";
	if(strSchCode.startsWith("CLDH")){
		strAWOL = " ABSENT (";
	}else if(strSchCode.startsWith("PIT")){
		strAWOL = " NE (";
	}
	boolean bolHasOTLabel = false;

	String strOBLabel = "OB(";
	if(strSchCode.startsWith("AUF")){
		strOBLabel = " OL(";
	}
	
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strDate = null;
	int iIndexOf = 0;
	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS","cs_dtr_form_batch_print3.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(),
														"cs_dtr_form_batch_print3.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
int iSearchResult = 0;
int iTemp = 0;
ReportEDTR RE = new ReportEDTR(request);
ReportEDTRExtn rptExtn = new ReportEDTRExtn(request);
enrollment.FacultyManagement FM = new enrollment.FacultyManagement();
enrollment.Authentication authentication = new enrollment.Authentication();
AllowedLateTimeIN allowedLateTIN = new AllowedLateTimeIN();
PReDTRME prEdtrME = new PReDTRME();

String[] astrMonth={" &nbsp;", "January", "February", "March", "April", "May", "June",
					 "July","August", "September","October", "November", "December"};
String[] astrWeekDays={"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};

Vector vRetEDTR = null;
Vector vWorkingHours = null;
Vector vHoursWork = null;
Vector vLateTimeIn = null;

	int iTotalLateAM = 0;
	int iTotalLatePM = 0;
	int iFreqLateAM = 0;
	int iFreqLatePM = 0;

	int iTotalUTAM = 0;
	int iTotalUTPM = 0;
	int iFreqUTAM = 0;
	int iFreqUTPM = 0;

Vector vFacultyLoad = null;
Vector vSalaryPeriod = null;
Vector vRetResult = null;
Vector vWithoutGrace = null;
String strDateFr = null;
String strDateTo = null;

	double dTemp = 0d;
	double dHoursWork = 0d;
	String strHrsWork = null;
	int iTempHr = 0;
	int iTempMin = 0;

Calendar calendar = Calendar.getInstance();

String strMonths = WI.fillTextValue("strMonth");
String strYear = WI.fillTextValue("sy_");
int iMonth = 0;

if(strMonths.length() == 0)
	strMonths = Integer.toString(calendar.get(Calendar.MONTH) + 1);
if(strYear.length() == 0)
	strYear = Integer.toString(calendar.get(Calendar.YEAR));

iMonth = Integer.parseInt(strMonths);

String strSemester = null;
String strSYFrom = null;
String strSYTo = null;

String strLateUT = null;
String strHoliday = null;
String strEmployeeIndex = null;
String strEmpID = null;

String strLateSetting = "";
String strSQLQuery = null;
int iAllowedLateAm = 0;
int iAllowedLatePm = 0;
int iHours = 0;
int iMinutes = 0;
double dTotalHours = 0;
int iPageCount =  1;
boolean bolIsOB = false; 
String strDayOfWeek = null;

	if(WI.fillTextValue("searchEmployee").length() > 0){
		vWithoutGrace = rptExtn.getEmployeesWithoutGrace(dbOP);
		vRetResult = rptExtn.searchMonthlyEDTR(dbOP, false);
		if(vRetResult != null)
			iSearchResult = rptExtn.getSearchCount();
		if (rptExtn.defSearchSize != 0) {
			iPageCount = iSearchResult/rptExtn.defSearchSize;
			if(iSearchResult % rptExtn.defSearchSize > 0) ++iPageCount;
		}

 	}
	vLateTimeIn = allowedLateTIN.operateOnLateSetting(dbOP, request, 3);
	if(vLateTimeIn != null && vLateTimeIn.size() > 0){
		strLateSetting = (String)vLateTimeIn.elementAt(0);
	}
	
	vSalaryPeriod = prEdtrME.getSalaryPeriods(dbOP, request, Integer.toString(iMonth-1), strYear);
%>

<form name="form_">
	<%
	Integer iobjIndex = null;
	int iMain = 0;
	int iSize = 0;
	int iCount = 1;

	//as requestd, i have to show all the days worked and non worked.
	Vector vDayInterval = null;
//	Vector vRetHolidays = null;
//	Vector vEmpLeave = null;
//	Vector vRetOBOT = null;
	Vector vAWOLRecords = null;
//	Vector vLateUnderTime = null;
//	Vector vEmpLogout = null;
//	Vector vEmpOvertime = null;
//	Vector vSuspended = null;
	
	String strPrevDate = "";//this is added to avoid displaying date in 2nd row.
	boolean bolDateRepeated = false;
	String strDateEntry  = "";	
	String strLatePMEntry = null;
	String strUTPMEntry = null;
  	String strAmTimeIn = null;
	String strAmTimeOut = null;
	String strLateEntry = null;
	String strUTEntry = null;
	String strPmTimeIn = null;
	String strPmTimeOut = null;	
	boolean bolSkipAm = false;
	boolean bolSkipPm = false;	
	double dEmpTotalHours = 0d;
	if (vRetResult != null && vRetResult.size() > 0){
	 for(iMain = 0; iMain < vRetResult.size(); iMain += 13, iCount++) {	
	%>
<%if(iMain > 0){%>
<div style="page-break-after:always">&nbsp;</div>
<%}%>
	
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="47%">
		<%
		dEmpTotalHours = 0d;
		iTotalLateAM = 0;
		iTotalLatePM = 0;
		iFreqLateAM = 0;
		iFreqLatePM = 0;
	
		iTotalUTAM = 0;
		iTotalUTPM = 0;
		iFreqUTAM = 0;
		iFreqUTPM = 0;
			 
		strEmpID = (String)vRetResult.elementAt(iMain);
		strEmployeeIndex = (String)vRetResult.elementAt(iMain+6);
		if(vWithoutGrace != null){
			iobjIndex = new Integer(strEmployeeIndex);
			iIndexOf = vWithoutGrace.indexOf(iobjIndex);
		}

		if(iIndexOf != -1 && vLateTimeIn != null){
			iAllowedLateAm = Integer.parseInt((String)vLateTimeIn.elementAt(1));
			iAllowedLatePm = Integer.parseInt((String)vLateTimeIn.elementAt(2));
		}
	
 		 if ((!strMonths.equals("0") && strMonths.length() > 0)){
				try{			
					if (strYear.length()> 0){
						if (Integer.parseInt(strYear) >= 2005)
							calendar.set(Calendar.YEAR, Integer.parseInt(strYear));
					else
						strErrMsg = " Invalid year entry";
		
					}else{
						strYear = Integer.toString(calendar.get(Calendar.YEAR));
					}
				} catch (NumberFormatException nfe){
					strErrMsg = " Invalid year entry";
				}
		
				 calendar.set(Calendar.DAY_OF_MONTH,1);
		
				 if(!strMonths.equals("0") && strMonths.length() > 0){
						calendar.set(Calendar.MONTH,Integer.parseInt(strMonths)-1);
				 }else{
						strMonths = Integer.toString(calendar.get(Calendar.MONTH) + 1);
				 }
	
				if (calendar.get(Calendar.MONTH) <= 2 ||
						calendar.get(Calendar.MONTH) >= 10){// 2nd sem november
		
					strSemester = "2";
		
					if (calendar.get(Calendar.MONTH) <=2){
						strSYFrom = Integer.toString(calendar.get(Calendar.YEAR)-1);
						strSYTo = Integer.toString(calendar.get(Calendar.YEAR));
					}else{
						strSYFrom = Integer.toString(calendar.get(Calendar.YEAR));
						strSYTo = Integer.toString(calendar.get(Calendar.YEAR) + 1);
					}
		
				}else if (calendar.get(Calendar.MONTH) >=5 &&
						calendar.get(Calendar.MONTH) < 10){ // june to october
		
					strSemester = "1";
					strSYFrom = Integer.toString(calendar.get(Calendar.YEAR));
					strSYTo = Integer.toString(calendar.get(Calendar.YEAR)+1);
				}else{ // summer
					strSemester = "0";
					strSYFrom = Integer.toString(calendar.get(Calendar.YEAR)-1);
					strSYTo = Integer.toString(calendar.get(Calendar.YEAR));
				}

			if(WI.fillTextValue("sal_period_index").length() == 0){
				strDateFr = strMonths + "/01/" + calendar.get(Calendar.YEAR);
				strDateTo = strMonths + "/" + Integer.toString(calendar.getActualMaximum(Calendar.DAY_OF_MONTH))
						+ "/" + calendar.get(Calendar.YEAR);
			}
			
			if (strEmployeeIndex != null && strEmployeeIndex.length() > 1 
			&& WI.fillTextValue("hide_load").length() == 0){
				vFacultyLoad = FM.viewFacultyLoadSummary(dbOP, strEmployeeIndex,
							strSYFrom, strSYTo, strSemester, "",false,true);//get additional data.
			}
		
  }	else{
		strDateFr = WI.fillTextValue("date_from");
		strDateTo = WI.fillTextValue("date_to");
	}

		//System.out.println("\n329 strDateFr " + strDateFr);
		//System.out.println("329 strDateTo " + strDateTo);
	
	if (strDateFr != null && strDateFr.length() > 0){
		vHoursWork = RE.computeWorkingHour(dbOP, strEmpID,
											strDateFr, strDateTo, strMonths, strYear);
		 if (vHoursWork != null && vHoursWork.size()  > 0){
	 		for(int i = 0; i < vHoursWork.size(); i+=3)
				dEmpTotalHours += ((Double)vHoursWork.elementAt(i+2)).doubleValue();
 	  }											
	}

/*
System.out.println("vHoursWork : "+vHoursWork);
System.out.println("strDateFr : "+strDateFr);
System.out.println("strDateTo : "+strDateTo);
System.out.println("strMonths : "+strMonths);
System.out.println("strYear : "+strYear);
*/
%>
		<label for="main_label_<%=iCount%>">
		<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="main_label_<%=iCount%>">
		<tr>
		<td>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
			<tr>
			  <td align="center">CIVIL SERVICE FORM # 48</td>
			</tr>
			<tr>
				<td align="center">DAILY TIME RECORD</td>
			</tr>
			<tr>
			  <td align="center">&nbsp;</td>
			</tr>
		</table>	
		</td>
		</tr>
		<tr>
		<td>			
		<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="83%" height="19" colspan="2" align="center"  class="thinborderBOTTOM"><font size="2"><strong>&nbsp;
				<%=WI.formatName((String)vRetResult.elementAt(iMain+1),
			  "", (String)vRetResult.elementAt(iMain+2),4).toUpperCase()%></strong></font></td>
    </tr>
      <tr>
        <td height="25" colspan="2" align="center" valign="top">(Name)</td>
      </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <%	strTemp = (String)vRetResult.elementAt(iMain+3);
	if (strTemp != null){
		if (vRetResult.elementAt(iMain+4) != null) {
			strTemp += " :: " + (String)vRetResult.elementAt(iMain+4);
		}
	}else{
		strTemp = (String)vRetResult.elementAt(iMain+4);
	}
		
	strTemp = WI.getStrValue(strTemp);
	if(strTemp.length() > 20){
		strTemp = (String)vRetResult.elementAt(iMain+10);
		if (strTemp != null){
			if (vRetResult.elementAt(iMain+11) != null) {
				strTemp += " :: " + (String)vRetResult.elementAt(iMain+11);
			}
		}else{
			strTemp = (String)vRetResult.elementAt(iMain+11);
		}		
	}	
%>
      <%
				if(WI.fillTextValue("sal_period_index").length() == 0)
					strTemp = "For the month of <strong>" + astrMonth[iMonth] + " " + strYear + "</strong>";
				else
					strTemp = "For the period <strong>" + strDateFr + " - " + strDateTo + "</strong>";
			%>
      <td width="64%" height="25"  class="thinborderBOTTOM">&nbsp;<%=strTemp%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="12" bgcolor="#FFFFFF" class="thinborder"  style="border-right:1px solid #000000;" >&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    
<%
	vRetEDTR = RE.getDTRDetails(dbOP, strEmpID, true);
	iSize = 0;
	if(vRetEDTR != null)
		iSize = vRetEDTR.size();
	vWorkingHours = RE.getEmployeeWorkingHours(dbOP, false, strEmpID);
  	if ((vRetEDTR != null && iSize > 0) || true) {
		//as requestd, i have to show all the days worked and non worked.
		vDayInterval = RE.getDayNDateDetail(strDateFr,strDateTo);
		
		// holidays..
		//vRetHolidays = RE.getHolidaysOfMonth(dbOP,request, strEmployeeIndex);
		//System.out.println("vRetHolidays : "  + vRetHolidays);
		
		// leave..
		//vEmpLeave = RE.getEmployeeLeaveAndName(dbOP, strEmployeeIndex, strDateFr, strDateTo, strSchCode);
		//System.out.println("vEmpLeave : "  + vEmpLeave);
		
		// trainings / ob / otin
		//vRetOBOT = RE.getEmpOBOT(dbOP, strEmployeeIndex, strDateFr, strDateTo);
		//System.out.println("vRetOBOT : "  + vRetOBOT);
		
		//awol records..
		vAWOLRecords = RE.getAWOLEmployee(dbOP, strEmployeeIndex, strDateFr, strDateTo, strSchCode);
		//System.out.println("\n\n441 vAWOLRecords : " + vAWOLRecords);
		
		// late undertime records..
		//vLateUnderTime = RE.getMonthlyLateUTimeDetail(dbOP, request, strEmployeeIndex);
		//System.out.println("vLateUnderTime : "  + vLateUnderTime);
		
		//Employee Logout..
		//vEmpLogout = RE.getEmpLogout(dbOP, strEmployeeIndex, strDateFr, strDateTo);
		//System.out.println("vEmpLogout : "  + vEmpLogout);
		
//		if(strSchCode.startsWith("DEPED")){	
//			vEmpOvertime=  RE.getOTHours(dbOP, strEmpID,
//										 strDateFr, strDateTo, null, null, strEmployeeIndex);
//		}else{
//			vEmpOvertime = RE.getEmpOverTime(dbOP, strEmployeeIndex,
//										 strDateFr, strDateTo);
//		}		
//		vSuspended = RE.getEmpSuspensions(dbOP, strEmployeeIndex, strDateFr, strDateTo);
		
		%>
 
    <tr >
      <td width="15%" height="20" class="thinborder">  		<strong>&nbsp;DATE</strong></td>
      <td width="9%" align="center" class="thinborder">Arrival</td>
      <td width="9%" align="center" class="thinborder">Departure</td>
      <td width="9%" align="center" class="thinborder">Arrival</td>
      <td width="9%" align="center" class="thinborder">Departure</td>
      <td width="5%" align="center" class="thinborder">Hours</td>
      <td width="5%" align="center" class="thinborder">Minutes</td>
    </tr>
    <% 	if (iSize == 1){//non DTR employees %>
    <tr>
      <td height="20" colspan="7" align="center" class="thinborder"><strong><%=vRetEDTR.elementAt(0)%></strong></td>
    </tr>
    <%}else{
	strTemp3 = "";
	
	strPrevDate = "";//this is added to avoid displaying date in 2nd row.
	bolDateRepeated = false;
	strDateEntry  = "";	
	strLatePMEntry = null;	
	strUTPMEntry = null;
	iIndexOf = 0;
 	strAmTimeIn = null;
	strAmTimeOut = null;
	strLateEntry = null;
	strUTEntry = null;
	strPmTimeIn = null;
	strPmTimeOut = null;	
	bolSkipAm = false;
	bolSkipPm = false;

//	Vector vLateUnderTime = RE.getMonthlyLateUTimeDetail(dbOP, request);

	for(int iIndex = 0; iIndex< iSize ;iIndex +=8){
		bolSkipAm = false;
		bolSkipPm = false;
		
		strTemp =(String)vRetEDTR.elementAt(iIndex+4);
		strAmTimeIn = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 2)).longValue(),2);
		//strAmTimeIn = strAmTimeIn.substring(0, strAmTimeIn.length() -1);

		strAmTimeIn = ConversionTable.replaceString(strAmTimeIn," ","");			
		strAmTimeOut = WI.getStrValue(WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 3)).longValue(),2),"&nbsp;");
		strLateEntry = WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 6), "0");
		strUTEntry = WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 7), "0");
	
		if((strAmTimeIn.substring(strAmTimeIn.length() -2)).equals("PM") && 
			WI.fillTextValue("fixed_ampm").length() > 0){
			bolSkipAm = true;
		}
		
		if(bolSkipAm){
			strAmTimeIn = "&nbsp;";
			strAmTimeOut = "&nbsp;";
			strLateEntry = "0";
			strUTEntry = "0";		
		}
			
		if (!strLateEntry.equals("0")){
			iTemp = Integer.parseInt(strLateEntry);
			if(strSchCode.startsWith("AUF")){
					if(iTemp <= iAllowedLateAm) {
						iTemp = 0;
						iFreqLateAM++;
					}
			} else {
				if(WI.fillTextValue("show_only_deduct").equals("1")){
					if(iTemp <= iAllowedLateAm)
						iTemp = 0;
				}
				iFreqLateAM++;
			}
			iTotalLateAM += iTemp;			
		}else{
			strLateEntry = "&nbsp;";
		}

		if (!strUTEntry.equals("0")){
			iTotalUTAM += Integer.parseInt(strUTEntry);
			iFreqUTAM++;
		}else{
			strUTEntry = "&nbsp;";
		}
			
 		if (strTemp != null &&  (((iIndex+8) < vRetEDTR.size() &&
		 	strTemp.equals((String)vRetEDTR.elementAt(iIndex+12)))
			|| bolSkipAm)){
							
			if(bolSkipAm){
				strPmTimeIn = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 2)).longValue(),2);
				strPmTimeOut = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 3)).longValue(),2);
				strLatePMEntry = WI.getStrValue((String)vRetEDTR.elementAt(iIndex+6));
				strUTPMEntry = WI.getStrValue((String)vRetEDTR.elementAt(iIndex+7));
			}else{
				strPmTimeIn = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 10)).longValue(),2);
				strPmTimeIn = ConversionTable.replaceString(strPmTimeIn," ","");						
 				
				if(!(strPmTimeIn.substring(strPmTimeIn.length() - 2)).equals("PM") && 
					WI.fillTextValue("fixed_ampm").length() > 0){
					bolSkipPm = true;
				}
				
				if(bolSkipPm){
					strPmTimeIn = "&nbsp;";
					strPmTimeOut = "&nbsp;";
					strLatePMEntry = "0";
					strUTPMEntry = "0";
				}else{
					strPmTimeIn = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 10)).longValue(),2);
					strPmTimeOut = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 11)).longValue(),2);
					strLatePMEntry = WI.getStrValue((String)vRetEDTR.elementAt(iIndex+6+8), "0");
					strUTPMEntry = WI.getStrValue((String)vRetEDTR.elementAt(iIndex+7+8), "0");
					
					if (!strLatePMEntry.equals("0")){
							iTemp = Integer.parseInt(strLatePMEntry);
							if(strSchCode.startsWith("AUF")){
								if(iTemp <= iAllowedLatePm) {						
									iTemp = 0;
									iFreqLatePM++;
								}
							} else {
								if(WI.fillTextValue("show_only_deduct").equals("1")){
									if(iTemp <= iAllowedLatePm)
										iTemp = 0;
								}	
								iFreqLatePM++;
							}
						iTotalLatePM += iTemp;			
					} 

					if (!strUTPMEntry.equals("0")){
						iTotalUTPM += Integer.parseInt(strUTPMEntry);
						iFreqUTPM++;
					}				
				}
				

			}
		} else {
			strPmTimeIn =  null;
			strPmTimeOut = null;
			strLatePMEntry = "";
			strUTPMEntry = "";
		}
		
		if(strUTPMEntry.equals("0"))
			strUTPMEntry = "&nbsp;";
			
		if(strLatePMEntry.equals("0"))
			strLatePMEntry = "&nbsp;";	

		if(strPrevDate.equals((String)vRetEDTR.elementAt(iIndex+4))) {
			bolDateRepeated = true;
		}
		else {
			bolDateRepeated = false;
			strPrevDate = (String)vRetEDTR.elementAt(iIndex+4);
		}

//I ahve to display here for the days employee did not work.
//System.out.println(vDayInterval);
	if(!bolDateRepeated && vDayInterval != null && vDayInterval.size() > 0) {
		while(vDayInterval.size() > 0 && !strPrevDate.equals((String)vDayInterval.elementAt(0))) {

		strDateEntry = (String)vDayInterval.remove(0); %>
		 
		<tr>
		  <td height="21" nowrap class="thinborder"><%=strDateEntry.substring(strDateEntry.indexOf("/")+1,strDateEntry.lastIndexOf("/")) +
				"&nbsp;" + ((String)vDayInterval.remove(0)).substring(0,3)%></td>
		  <td height="21" align="center" class="thinborder">&nbsp;</td>
	    <td height="21" align="center" class="thinborder">&nbsp;</td>
	    <td height="21" align="center" class="thinborder">&nbsp;</td>
	    <td height="21" align="center" class="thinborder">&nbsp;</td>
	    <td height="21" align="center" class="thinborder">&nbsp;</td>
	    <td height="21" align="right" class="thinborder">&nbsp;</td>
		</tr>

		<%		  
		}//end of while looop

  if(vDayInterval.size() > 0)  {
  	vDayInterval.removeElementAt(0);
		strDayOfWeek = ((String)vDayInterval.remove(0)).substring(0,3);
		if(WI.fillTextValue("show_weekday").length() == 0)
			strDayOfWeek = "";
  }
}//end of if condition to print holidays.%>
    <tr>
      <td height="20" nowrap class="thinborder"><%if(!bolDateRepeated){
				strDate = WI.getStrValue((String)vRetEDTR.elementAt(iIndex+4));
				if(strDate.length() > 0){
					strDate = WI.formatDate(strDate, 2);
					strDate = strDate.substring(0,3).toUpperCase();
				}
				strDate = WI.getStrValue(strDate,"&nbsp;");
				//strDate = WI.formatDate(strDate, 1);
				//System.out.println("strDate " + strDate);				
			%>			
      <%=((String)vRetEDTR.elementAt(iIndex+4)).substring(((String)vRetEDTR.elementAt(iIndex+4)).indexOf("/")+1,((String)vRetEDTR.elementAt(iIndex+4)).lastIndexOf("/"))%>
			<%=strDate%>
      <%}else{%>  
				&nbsp;  
			<%}%>      </td>
      <td nowrap class="thinborder">&nbsp;<%=strAmTimeIn%></td>
      <td nowrap class="thinborder">&nbsp;<%=strAmTimeOut%> </td>
      <td nowrap class="thinborder">&nbsp;<%=WI.getStrValue(strPmTimeIn,"&nbsp;")%></td>
      <td nowrap class="thinborder">&nbsp;<%=WI.getStrValue(strPmTimeOut,"&nbsp;")%></td>
	<%
			iHours = 0;
			iMinutes = 0;
			 if (vHoursWork != null && vHoursWork.size()  > 0 &&
	 			strPrevDate.equals((String)vHoursWork.elementAt(1))){
				vHoursWork.removeElementAt(0);
				vHoursWork.removeElementAt(0); 
				dTotalHours = ((Double)vHoursWork.remove(0)).doubleValue();
				iHours = (int)dTotalHours;
				/*
				please take not that 0.40001d is just a temporary fix for the reports...
				this would work only for those employees with at most 2 rows per day from edtr_tin_tout 
				.4 is added in order to compensate for the loss of precision sa total hours worked
				due to the rounding off... 
				at its worst, ang diffrence per row is .2 thats why kailangan mag add og .2.
				but most have two rows.. to kelangan at its worst pud kay .2 per row... 
				so mao na .4 ang kailangan i add. ang 0001 after sa .4 kay addl na lang, defense against
				sa mga naay .99999 na treatment sa double.
				Now since ang gi add is .4... ang makaya lang na depensahan kay ang mga days lang na ang
				number of records kay 2 lang...
				
				1	0.0166667	0.02	0.02	1.2		(int)1.6 = 1
				2	0.0333333	0.03	0.03	1.8		(int)2.2 = 2
				3	0.0500000	0.05	0.05		3		(int)3.4 = 3
				4	0.0666667	0.07	0.07	4.2		(int)4.6 = 4
				5	0.0833333	0.08	0.08	4.8		(int)5.2 = 5
				6	0.1000000	0.1	  0.1	    6		(int)6.4 = 6
				7	0.1166667	0.12	0.12	7.2		(int)7.6 = 7
				8	0.1333333	0.13	0.13	7.8		(int)8.2 = 8
				9	0.1500000	0.15	0.15	  9		(int)9.4 = 9
				*/
				iMinutes = (int)(((dTotalHours - iHours) * 60) + 0.40001d);
 			}%>
			<%
				strTemp = Integer.toString(iHours);
				if(iHours == 0)
					strTemp = "&nbsp;";
			%>			
      <td align="right" nowrap class="thinborder"><font size="1"><%=strTemp%>&nbsp;</font></td>
			<%
				strTemp = Integer.toString(iMinutes);
				if(iHours == 0 && iMinutes == 0)
					strTemp = "&nbsp;";
			%>			
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <%
		if(strPmTimeIn != null && !bolSkipAm && !bolSkipPm) 
			iIndex += 8;

		if (!strTemp3.equals((String)vRetEDTR.elementAt(iIndex+4))){
				strTemp3  = (String)vRetEDTR.elementAt(iIndex+4);
		}
	%>
    </tr>
    <%
	  } // end for loop




	  //I have to now print if there are any days having zero working hours.
	while(vDayInterval != null && vDayInterval.size() > 0) {%> <tr>
      <td height="20" nowrap class="thinborder">
	  
	   <%=((String)vDayInterval.elementAt(0)).substring(((String)vDayInterval.elementAt(0)).indexOf("/")+1,((String)vDayInterval.elementAt(0)).lastIndexOf("/"))%>&nbsp;<%=(String)((String)vDayInterval.elementAt(1)).substring(0,3)%> 
	 
	  <% 
	  //this is the previous code. this will display 'mm/dd/yy MON'
	  //but this is not applicable because it should be the same as dates with working hour	 (17 MON ) not (6/12/2012 MON)
	  strTemp = (String)vDayInterval.remove(0)+"::"+(String)((String)vDayInterval.remove(0)).substring(0,3);	  
	  %>
	  <%//=strTemp%>	  
	  </td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder">&nbsp;</td>
    </tr>
    <% 
	  }//end of while looop
     }
	}else{

	 if (strErrMsg == null || strErrMsg.length() == 0)
	 strErrMsg = " 0 RECORD FOUND ";

	%>
    <tr >
      <td height="25" colspan="7" class="thinborder">&nbsp;&nbsp; <strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong> </td>
    </tr>
    <%} // end if (vRetEDTR.size() == 1)%>
  </table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td width="70%" align="right" class="thinborder">&nbsp;TOTAL&nbsp; </td>
    <td width="30%" align="center" class="thinborder" style="border-right:1px solid #000000;">&nbsp;<%=CommonUtil.formatFloat(dEmpTotalHours, true)%> hours</td>
    </tr>
</table>
<!--
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td  width="15%" height="18"  class="thinborder">&nbsp;</td>
      <td colspan="3" align="center" class="thinborder"><strong>TOTAL MINUTES</strong></td>
      <td colspan="3" align="center" class="thinborder"><strong>FREQUENCY </strong></td>
    </tr>
    <tr>
      <td height="14" class="thinborder">&nbsp;</td>
      <td width="13%" align="center" class="thinborder"><strong>AM</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>PM</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>TOTAL</strong></td>
      <td width="13%" align="center" class="thinborder"><strong>AM</strong></td>
      <td width="14%" align="center" class="thinborder"><strong>PM</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>TOTAL</strong></td>
    </tr>

    <tr>
      <td height="15" class="thinborder">&nbsp;<strong>TARDINESS</strong></td>
      <td align="right" class="thinborder">
      <% if (iTotalLateAM != 0){%><%=iTotalLateAM%> <%}%>&nbsp;</td>
	  <td align="right" class="thinborder">
      <% if (iTotalLatePM != 0){%><%=iTotalLatePM%><%}%>&nbsp;</td>
	  <td align="right" class="thinborder">
	    <% if (iTotalLateAM + iTotalLatePM != 0){%>
	  			<%=iTotalLateAM + iTotalLatePM%><%}%>&nbsp;      </td>
      <td align="right" class="thinborder">
      <% if (iFreqLateAM != 0){%><%=iFreqLateAM%><%}%>&nbsp;</td>
      <td align="right" class="thinborder">
      <% if (iFreqLatePM != 0){%><%=iFreqLatePM%><%}%>&nbsp;</td>
      <td align="right" class="thinborder">
        <% if (iFreqLateAM + iFreqLatePM != 0){%>
	  <%=iFreqLateAM + iFreqLatePM%><%}%>&nbsp;</td>
    </tr>
    <tr>
      <td height="15" class="thinborder"><strong>&nbsp;UNDERTIME </strong></td>
      <td align="right" class="thinborder">
      <% if (iTotalUTAM != 0){%><%=iTotalUTAM%><%}%>&nbsp;</td>
	  <td align="right" class="thinborder">
      <% if (iTotalUTPM != 0){%><%=iTotalUTPM%><%}%>&nbsp;</td>
	  <td align="right" class="thinborder">
	    <% if (iTotalUTAM + iTotalUTPM != 0){%>
	  <%=iTotalUTAM + iTotalUTPM%><%}%>&nbsp;</td>
      <td align="right" class="thinborder">
      <% if (iFreqUTAM != 0){%><%=iFreqUTAM%><%}%>&nbsp;</td>
      <td align="right" class="thinborder">
      <% if (iFreqUTPM != 0){%><%=iFreqUTPM%><%}%>&nbsp;</td>
      <td align="right" class="thinborder">
        <% if (iFreqUTAM + iFreqUTPM != 0){%>
	  <%=iFreqUTAM + iFreqUTPM%><%}%>&nbsp;</td>
    </tr>
</table>
<%
if (WI.fillTextValue("show_schedule").equals("1")){
%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="15" colspan="5" align="center" class="thinborder"><strong>WORK
        SCHEDULE </strong></td>
    </tr>
    <% if (vWorkingHours == null || vWorkingHours.size() == 0) {
		strErrMsg = RE.getErrMsg();
	if (strErrMsg == null || strErrMsg.length() ==0)
		strErrMsg = " No record of employee Working Hour.";
%>
    <tr>
      <td height="18" colspan="5" class="thinborder"><div align="center"><strong><%=strErrMsg%></strong></div></td>
    </tr>
    <%}else{%>
    <tr align="center">
      <td width="18%" height="15" class="thinborder"><strong>WEEK DAY</strong></td>
      <td width="20%" class="thinborder"><strong>IN</strong></td>
      <td width="20%" class="thinborder"><strong>OUT</strong></td>
      <td width="20%" class="thinborder"><strong>IN </strong></td>
      <td width="20%" class="thinborder"><strong>OUT</strong></td>
    </tr>
    <% 	String strTimeIn0 = null;
		String strTimeOut0 = null;
		String strTimeIn1 = null;
		String strTimeOut1 = null;
		String strWeekDay = null;
		boolean bolFlexTime = false;


  		for(int i = 0 ; i< vWorkingHours.size(); i+=40){
			 bolFlexTime = false;
			 strTimeIn0 = null;
			 strTimeOut0 = null;
			 strTimeIn1 = null;
			 strTimeOut1 = null;
			 strWeekDay = null;
		%>

      <%
				strWeekDay = (String)vWorkingHours.elementAt(i+4);
				if (strWeekDay== null)
					strWeekDay = (String)vWorkingHours.elementAt(i+19);

				if (strWeekDay!=null)
					strWeekDay = astrWeekDays[Integer.parseInt(strWeekDay)];
				else{
					strWeekDay = (String)vWorkingHours.elementAt(i+33);
					if(strWeekDay ==  null)
						strWeekDay = "N/A Weekday";
				}

				strTemp = (String)vWorkingHours.elementAt(i+18);
				if (strTemp== null){
					strTemp =(String)vWorkingHours.elementAt(i+20);
					if(strTemp!=null){
						strTimeIn0 = eDTRUtil.formatTime((String)vWorkingHours.elementAt(i+20),
							(String)vWorkingHours.elementAt(i+21),(String)vWorkingHours.elementAt(i+22));
						strTimeOut0 = eDTRUtil.formatTime((String)vWorkingHours.elementAt(i+23),
							(String)vWorkingHours.elementAt(i+24),(String)vWorkingHours.elementAt(i+25));
						if((String)vWorkingHours.elementAt(i+26)!=null){
							strTimeIn1 = eDTRUtil.formatTime((String)vWorkingHours.elementAt(i+26),
							   (String)vWorkingHours.elementAt(i+27),(String)vWorkingHours.elementAt(i+28));
							strTimeOut1 = eDTRUtil.formatTime((String)vWorkingHours.elementAt(i+29),
							   (String)vWorkingHours.elementAt(i+30),(String)vWorkingHours.elementAt(i+31));
						}
					}else{
						strTimeIn0 = eDTRUtil.formatTime((String)vWorkingHours.elementAt(i+5),
							(String)vWorkingHours.elementAt(i+6),(String)vWorkingHours.elementAt(i+7));
						strTimeOut0 = eDTRUtil.formatTime((String)vWorkingHours.elementAt(i+8),
							(String)vWorkingHours.elementAt(i+9),(String)vWorkingHours.elementAt(i+10));
						if ((String)vWorkingHours.elementAt(i+11)!=null){
							strTimeIn1 = eDTRUtil.formatTime((String)vWorkingHours.elementAt(i+11),
							   (String)vWorkingHours.elementAt(i+12),(String)vWorkingHours.elementAt(i+13));
							strTimeOut1 = eDTRUtil.formatTime((String)vWorkingHours.elementAt(i+14),
							   (String)vWorkingHours.elementAt(i+15),(String)vWorkingHours.elementAt(i+16));
						}
					}
				}else{
					bolFlexTime = true;
					strTemp += " hours (flex time)";
				}

	  if (!bolFlexTime) {
			%>
	 <tr>
	  <td height="15" class="thinborder">&nbsp;<%=strWeekDay%></td>
      <td class="thinborder">&nbsp;<%=strTimeIn0%></td>
      <td class="thinborder">&nbsp;<%=strTimeOut0%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTimeIn1)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTimeOut1)%></td>
	 </tr>
	 <%}else{%>
	 <tr>
	  <td height="15" class="thinborder">&nbsp;<%=strWeekDay%></td>
      <td class="thinborder" colspan="4">&nbsp;<%=strTemp%></td>
	 </tr>
	 <%}%>
    <%}
	} // end if vWorkingHours == null || vWorkingHours.size() ==0%>
</table>


<% if (vFacultyLoad != null && vFacultyLoad.size() > 0) {%>
<table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="15" colspan="6" align="center" class="thinborder"><strong>TEACHING LOAD SCHEDULE </strong></td>
    </tr>
    <tr align="center">
      <td width="15%" rowspan="2" class="thinborder"><strong>COLLEGE</strong></td>
      <td width="16%" rowspan="2" class="thinborder"><strong>SECTION</strong></td>
      <td width="16%" rowspan="2" class="thinborder"><strong>SUBJ CODE </strong></td>
      <td height="15" colspan="2" class="thinborder"><strong>SCHEDULE</strong></td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <tr align="center">
      <td width="16%" class="thinborder"><strong>DAY </strong></td>
      <td width="20%" height="15" class="thinborder"><strong>TIME </strong></td>
      <td width="17%" class="thinborder"><strong>ROOM</strong></td>
    </tr>
    <%
		String strFacultyWeekDay = null;
		String strFacTime = null;
  		for(int i = 0 ; i< vFacultyLoad.size(); i+=9){  %>
	 <tr>
	  <td height="15" class="thinborder"><%=(String)vFacultyLoad.elementAt(i + 2)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vFacultyLoad.elementAt(i + 4),"&nbsp;")%></td>
      <td class="thinborder"><%=(String)vFacultyLoad.elementAt(i)%></td>
<%  strFacultyWeekDay = (String)vFacultyLoad.elementAt(i + 6);

	if (strFacultyWeekDay  != null && strFacultyWeekDay.length() > 0){
		strFacTime = strFacultyWeekDay.substring(strFacultyWeekDay.indexOf(" "), strFacultyWeekDay.length());
		strFacultyWeekDay = strFacultyWeekDay.substring(0,strFacultyWeekDay.indexOf(" "));
	}else{
		strFacTime = "";
		strFacultyWeekDay = "";
	}
%>
      <td class="thinborder">&nbsp;<%=strFacultyWeekDay%></td>
      <td class="thinborder">&nbsp;<%=strFacTime%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vFacultyLoad.elementAt(i + 5),"Not Set")%></td>
	 </tr>
    <%} %>
</table>
<%} //  if (vFacultyLoad != null && vFacultyLoad.size%>
<%}// if (WI.fillTextValue("show_schedule")%>
-->
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="15" bgcolor="#FFFFFF">&nbsp;&nbsp;&nbsp;
        <div align="justify"><em>I Certify on my honor that the above is a true and correct report of the hours of work performed, record of which was made daily at time of arrival at and departure from office. </em></div></td>
    </tr>
    <tr>
      <td height="36" bgcolor="#FFFFFF">&nbsp;</td>
      </tr>
    <tr>
      <td height="4" align="center" valign="bottom" bgcolor="#FFFFFF" class="thinborderBOTTOM"><font size="2"><strong><%=WI.formatName((String)vRetResult.elementAt(iMain+1),
			  "", (String)vRetResult.elementAt(iMain+2),4).toUpperCase()%></strong></font></td>
    </tr>
    <tr>
      <td height="18" bgcolor="#FFFFFF">Verified as to the prescribed office Hrs. </td>
      </tr>
    <tr>
      <td height="29" align="center" valign="bottom" bgcolor="#FFFFFF" class="thinborderBOTTOM"><font size="2"><strong><%=WI.fillTextValue("in_charge")%></strong></font></td>
      </tr>
    <tr>
      <td height="15" align="center" bgcolor="#FFFFFF">In-Charge</td>
      </tr>
  </table>	
		</td>
		</tr>
		</table>
		</label></td>
    <td width="6%">&nbsp;</td>
    <td width="47%" onClick="copyLabel();"><label id="copy_label_<%=iCount%>"></label></td>
  </tr>
</table>
<%} // for(iMain = 0; iMain < vRetResult.size(); iMain += 13)
}// vRetResult != null && vRetResult.size() > 0%>

<input type="hidden" name="emp_count" value="<%=WI.fillTextValue("emp_count")%>">
 <script language="JavaScript">
 	copyLabel();
 </script>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
