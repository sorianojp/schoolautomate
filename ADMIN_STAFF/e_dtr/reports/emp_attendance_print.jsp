<%@ page language="java" import="utility.*, eDTR.ReportEDTR,eDTR.eDTRUtil, eDTR.WorkingHour,
																java.util.Vector, java.util.Calendar,java.util.Date, 
																eDTR.AllowedLateTimeIN, eDTR.ReportEDTRExtn, payroll.PReDTRME"%>
<%
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();">
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
	}
	
	String strOBLabel = "OB(";
	if(strSchCode.startsWith("AUF")){
		strOBLabel = " OL(";
	}
	
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strLeave = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS","emp_attendance.jsp");
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
														"emp_attendance.jsp");

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
String strInc = "&nbsp;";
if(strSchCode.startsWith("AUF"))
	strInc = "-inc-";

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
//boolean bolHasInc = false;
boolean bolHasEntry = false;
String strTime = null;
boolean bolIsOB = false;

	vWithoutGrace = rptExtn.getEmployeesWithoutGrace(dbOP);
	vRetResult = rptExtn.searchMonthlyEDTR(dbOP, false);
 	
	vLateTimeIn = allowedLateTIN.operateOnLateSetting(dbOP, request, 3);
	if(vLateTimeIn != null && vLateTimeIn.size() > 0){
		strLateSetting = (String)vLateTimeIn.elementAt(0);
	}
	
	vSalaryPeriod = prEdtrME.getSalaryPeriods(dbOP, request, Integer.toString(iMonth-1), strYear, WI.fillTextValue("sal_period_index"));
	if(vSalaryPeriod != null && vSalaryPeriod.size() > 0){
		strDateFr = (String)vSalaryPeriod.elementAt(1);
		strDateTo = (String)vSalaryPeriod.elementAt(2);	
	}
 %>
<form name="form_">
  <%
	int iIndexOf = 0;
	Integer iobjIndex = null;
	int iMain = 0;

	String strPrevDate = "";//this is added to avoid displaying date in 2nd row.
	boolean bolDateRepeated = false;
	String strLatePMEntry = null;
	String strUTPMEntry = null;
	//as requestd, i have to show all the days worked and non worked.
	Vector vDayInterval = null;
	Vector vRetHolidays = null;
	Vector vEmpLeave = null;
	Vector vRetOBOT = null;
	Vector vAWOLRecords = null;
//	Vector vLateUnderTime = null;
	Vector vEmpLogout = null;
	Vector vEmpOvertime = null;
	Vector vSuspended = null;
	int iSize = 0;
	
	if (vRetResult != null && vRetResult.size() > 0){
	 for(iMain = 0; iMain < vRetResult.size(); iMain += 13) {
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

//	System.out.println("strDateFr " + strDateFr);
//	System.out.println("strDateTo " + strDateTo);
	
	if (strDateFr != null && strDateFr.length() > 0){
		vHoursWork = RE.computeWorkingHour(dbOP, strEmpID,
											strDateFr, strDateTo, strMonths, strYear);
	}

/**
System.out.println("vHoursWork : "+vHoursWork);
System.out.println("strDateFr : "+strDateFr);
System.out.println("strDateTo : "+strDateTo);
System.out.println("strMonths : "+strMonths);
System.out.println("strYear : "+strYear);
**/
%>
<%if(iMain > 0){%>
<div style="page-break-after:always">&nbsp;</div>
<%}%>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
      <tr>
        <td height="25" colspan="2" align="center"  class="thinborder">
				<font size="2"><strong><%=strEmpID%>&nbsp;</strong></font></td>
        <td width="83%" height="25" colspan="2"  class="thinborder"><font size="2"><strong>&nbsp;<%=WI.formatName((String)vRetResult.elementAt(iMain+1),
	  "", (String)vRetResult.elementAt(iMain+2),4).toUpperCase()%></strong></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td width="9%" height="25"  class="thinborder"> &nbsp;UNIT </td>
<%	strTemp = (String)vRetResult.elementAt(iMain+3);
	if (strTemp != null){
		if (vRetResult.elementAt(iMain+4) != null) {
			strTemp += " :: " + (String)vRetResult.elementAt(iMain+4);
		}
	}else{
		strTemp = (String)vRetResult.elementAt(iMain+4);
	}
%>
      <td width="27%"  class="thinborder"><strong>&nbsp;<%=WI.getStrValue(strTemp)%> </strong></td>
			<%
				if(WI.fillTextValue("sal_period_index").length() == 0)
					strTemp = astrMonth[iMonth] + " " + strYear;
				else
					strTemp = strDateFr + " - " + strDateTo;
			%>			
      <td width="64%" height="25"  class="thinborder">&nbsp;<strong><%=strTemp%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="11" align="center" class="thinborder"><strong><font color="#000000">DAILY
        TIME RECORD</font></strong></td>
    </tr>
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
		vRetHolidays = RE.getHolidaysOfMonth(dbOP,request, strEmployeeIndex);
		//System.out.println("vRetHolidays : "  + vRetHolidays);
		
		// leave..
		vEmpLeave = RE.getEmployeeLeaveAndName(dbOP, strEmployeeIndex, strDateFr, strDateTo, strSchCode);
		//System.out.println("vEmpLeave : "  + vEmpLeave);
		
		// trainings / ob / otin
		vRetOBOT = RE.getEmpOBOT(dbOP, strEmployeeIndex, strDateFr, strDateTo);
		//System.out.println("vRetOBOT : "  + vRetOBOT);
		
		// awol records..
		vAWOLRecords = RE.getAWOLEmployee(dbOP, strEmployeeIndex, strDateFr, strDateTo, strSchCode);
		//System.out.println("vAWOLRecords " + vAWOLRecords);
		
		// late undertime records..
		//vLateUnderTime = RE.getMonthlyLateUTimeDetail(dbOP, request, strEmployeeIndex);
		//System.out.println("vLateUnderTime : "  + vLateUnderTime);
		
		//Employee Logout..
		vEmpLogout = RE.getEmpLogout(dbOP, strEmployeeIndex, strDateFr, strDateTo);
		//System.out.println("vEmpLogout : "  + vEmpLogout);
		
		vEmpOvertime = RE.getEmpOverTime(dbOP, strEmployeeIndex, strDateFr, strDateTo);
		
		vSuspended = RE.getEmpSuspensions(dbOP, strEmployeeIndex, strDateFr, strDateTo);		
		%>
    <tr >
      <td width="15%" height="20" class="thinborder"><strong>&nbsp;DATE</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>IN</strong></td>
      <td width="6%" align="center" class="thinborder"><strong>L</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>OUT</strong></td>
      <td width="5%" align="center" class="thinborder"><strong>U</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>IN</strong></td>
      <td width="6%" align="center" class="thinborder"><strong>L</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>OUT</strong></td>
      <td width="5%" align="center" class="thinborder"><strong>U</strong></td>
      <td width="6%" align="center" class="thinborder"><strong>TOT</strong></td>
      <td width="21%" align="center" class="thinborder"><strong>REMARKS</strong></td>
    </tr>
    <% 	if (iSize == 1){//non DTR employees %>
    <tr>
      <td height="20" colspan="11" align="center" class="thinborder"><strong><%=vRetEDTR.elementAt(0)%></strong></td>
    </tr>
    <%}else{
	strTemp3 = "";

	strPrevDate = "";//this is added to avoid displaying date in 2nd row.
	bolDateRepeated = false;
	strLatePMEntry = null;
	strUTPMEntry = null;

//	Vector vLateUnderTime = RE.getMonthlyLateUTimeDetail(dbOP, request);

	for(int iIndex = 0; iIndex < iSize; iIndex += 8){
		//bolHasInc = false;
		bolIsOB = false;
		bolHasEntry = false;
 		strTemp =(String)vRetEDTR.elementAt(iIndex+4);

		if (strTemp!=null &&  (iIndex+8) < vRetEDTR.size() &&
		 	strTemp.equals((String)vRetEDTR.elementAt(iIndex+12))){

			strTemp = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 10)).longValue(),2);
			strTemp2 = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 11)).longValue(),2);
			strLatePMEntry = WI.getStrValue((String)vRetEDTR.elementAt(iIndex+6+8));
			strUTPMEntry = WI.getStrValue((String)vRetEDTR.elementAt(iIndex+7+8));
		}
		else {
			strTemp =  null;
			strTemp2 = null;
			strLatePMEntry = "";
			strUTPMEntry = "";
		}

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

			//System.out.println("(String)vRetHolidays.elementAt(1) " + (String)vRetHolidays.elementAt(1));
			//System.out.println("(String)vDayInterval.elementAt(0) " + (String)vDayInterval.elementAt(0));
			strHoliday = "";
			if (vRetHolidays != null && vRetHolidays.size() > 0 
				//&& ((String)vRetHolidays.elementAt(1)).equals((String)vDayInterval.elementAt(0))
				&& !bolDateRepeated){

				//strHoliday = (String)vRetHolidays.remove(0);
				//vRetHolidays.removeElementAt(0);
				iIndexOf = vRetHolidays.indexOf((String)vDayInterval.elementAt(0));
				//System.out.println("(String)vDayInterval.elementAt(0) - " + (String)vDayInterval.elementAt(0));
				while(iIndexOf != -1){
					strHoliday += (String)vRetHolidays.elementAt(iIndexOf-1) + "<br>";
					vRetHolidays.remove(iIndexOf);
					vRetHolidays.remove(iIndexOf-1);					
					iIndexOf = vRetHolidays.indexOf((String)vDayInterval.elementAt(0));
				}
			}else
				strHoliday = "";
			
 			if (vEmpLeave != null && vEmpLeave.size() > 0 &&
				!bolDateRepeated){
				
				iIndexOf = vEmpLeave.indexOf((String)vDayInterval.elementAt(0));
				while(iIndexOf != -1){
					vEmpLeave.remove(iIndexOf);// remove date
					strLeave = (String)vEmpLeave.remove(iIndexOf); // remove leave hours
					vEmpLeave.remove(iIndexOf);// remove leave status
					if(strSchCode.startsWith("AUF")){
						vEmpLeave.remove(iIndexOf);// remove leave type
						strLeave = "Leave(" + strLeave +")";
					}else{
						strLeave = WI.getStrValue((String)vEmpLeave.remove(iIndexOf),"w/out pay") + "(" + strLeave +")";
					}
					vEmpLeave.remove(iIndexOf); // remove free
					vEmpLeave.remove(iIndexOf); // remove free
					vEmpLeave.remove(iIndexOf); // remove free
					vEmpLeave.remove(iIndexOf); // remove free
					vEmpLeave.remove(iIndexOf); // remove free
					vEmpLeave.remove(iIndexOf); // remove free
					strHoliday += strLeave; 
					
					iIndexOf = vEmpLeave.indexOf((String)vDayInterval.elementAt(0));
				}				
			}

			if (vRetOBOT != null && vRetOBOT.size() > 0 &&
				((String)vRetOBOT.elementAt(0)).equals((String)vDayInterval.elementAt(0)) &&
				!bolDateRepeated){

				vRetOBOT.removeElementAt(0);
				strHoliday += " OB/OT";
			}

			if (vEmpLogout != null && vEmpLogout.size() > 0 &&
			((String)vEmpLogout.elementAt(0)).equals((String)vDayInterval.elementAt(0))
				&& !bolDateRepeated){

				vEmpLogout.removeElementAt(0);
				strHoliday += strOBLabel + WI.getStrValue((String)vEmpLogout.remove(0),"Whole Day") +")";
				if(vEmpLogout != null){
					iIndexOf = vEmpLogout.indexOf((String)vDayInterval.elementAt(0));
					while(iIndexOf != -1){
						vEmpLogout.remove(iIndexOf);// date
						vEmpLogout.remove(iIndexOf);// hours
						iIndexOf = vEmpLogout.indexOf((String)vDayInterval.elementAt(0));
					}
				}								
				bolIsOB = true;
			}

			if (vAWOLRecords != null && vAWOLRecords.size() > 0 &&
			(ConversionTable.convertMMDDYYYY((Date)vAWOLRecords.elementAt(0)).equals((String)vDayInterval.elementAt(0)))
				&& !bolDateRepeated && !bolIsOB){
				iIndexOf = -1;
				if(vSuspended != null && vSuspended.size() > 0)
					iIndexOf = vSuspended.indexOf((String)vDayInterval.elementAt(0));
		
				if(iIndexOf != -1){
					vAWOLRecords.removeElementAt(0);
					vAWOLRecords.removeElementAt(0);
					strHoliday += "Suspended";
				}else{
					vAWOLRecords.removeElementAt(0);
					strHoliday += strAWOL + (String)vAWOLRecords.remove(0) +")";			
				}
			}

			if (vEmpOvertime != null && vEmpOvertime.size() > 0 &&
			((String)vEmpOvertime.elementAt(0)).equals((String)vDayInterval.elementAt(0))
				&& !bolDateRepeated){

				vEmpOvertime.removeElementAt(0); // date
				strHoliday += "OT (" + (String)vEmpOvertime.remove(0) +")";
			}

	//	strDateEntry = (String)vDayInterval.remove(0);

		if(strHoliday.length() > 0){%>
		<tr>
		  <td height="20" class="thinborder"> &nbsp;<%=(String)vDayInterval.remove(0)+ "::" +
											((String)vDayInterval.remove(0)).substring(0,3)%></td>
		  <td height="20" colspan="10" align="center" class="thinborder"><strong><%=strHoliday%></strong></td>
		</tr>
		<%}else{%>
		<tr>
		  <td height="20" class="thinborder"> &nbsp;<%=(String)vDayInterval.remove(0) + "::" +
											((String)vDayInterval.remove(0)).substring(0,3)%></td>
		  <td height="20" colspan="10" align="center" class="thinborder">&nbsp;</td>
	  </tr>

		<%
		  }
		}//end of while looop

  if(vDayInterval.size() > 0)  {
  	vDayInterval.removeElementAt(0);vDayInterval.removeElementAt(0);
  }
}//end of if condition to print holidays.%>
    <tr>
      <td height="20" class="thinborder">&nbsp;<%if(!bolDateRepeated){%>
	  			<%=(String)vRetEDTR.elementAt(iIndex+4)%> <%}else{%> &nbsp; <%}%>	  </td>
			<%
				bolHasEntry = true;
			%>
      <td class="thinborder">
			  <%=WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 2)).longValue(),2)%>	  </td>

	  <%
	  	if (!WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 6), "0").equals("0")){
				iTemp = Integer.parseInt(WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 6),"0"));
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
		}
	  %>
      <td align="right" class="thinborder"><%=WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 6))%>&nbsp;</td>
			<%
				strTime = WI.getStrValue(WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 3)).longValue(),2),strInc);
				//System.out.println("strTime - " + strTime);
				//if(strTime.equals(strInc))
				//	bolHasInc = true;
			%>			
      <td class="thinborder"> <%=strTime%>	  </td>
	  <%
	  	if (!WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 7), "0").equals("0")){
			iTotalUTAM += Integer.parseInt((String)vRetEDTR.elementAt(iIndex + 7));
			iFreqUTAM++;
		}
	  %>
      <td align="right" class="thinborder"><%=WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 7))%>&nbsp;</td>
      <% strTime=WI.getStrValue(strTemp,"&nbsp;");%>
      <td class="thinborder">&nbsp;<%=strTime%></td>
	  <%
	  	if (!WI.getStrValue(strLatePMEntry, "0").equals("0")){
				iTemp = Integer.parseInt(WI.getStrValue(strLatePMEntry,"0"));
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
	  %>
      <td align="right" class="thinborder"><%=strLatePMEntry%>&nbsp;</td>
			<%
			if (!strTime.equals("&nbsp;")) {
				strTime=WI.getStrValue(strTemp2,strInc);
				//bolHasInc = true;
			}else{
				strTime=WI.getStrValue(strTemp2,"&nbsp;");
			}
				//strTime = WI.getStrValue(strTemp2,strInc);
				//if(strTime.equals(strInc))
				//	bolHasInc = true;
			%>				
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTime,"&nbsp;")%></td>
	  <%
	  	if (!WI.getStrValue(strUTPMEntry, "0").equals("0")){
			iTotalUTPM += Integer.parseInt(strUTPMEntry);
			iFreqUTPM++;
		}
	  %>
      <td align="right" class="thinborder"><%=strUTPMEntry%>&nbsp;</td>

      <td class="thinborder">&nbsp;
	 <%	
//	 System.out.println("strPrevDate " + strPrevDate);
//	 System.out.println("(String)vHoursWork.elementAt(1) " + (String)vHoursWork.elementAt(1));
	 if (vHoursWork != null && vHoursWork.size()  > 0 &&
	 			strPrevDate.equals((String)vHoursWork.elementAt(1))){
			vHoursWork.removeElementAt(0);
			vHoursWork.removeElementAt(0); 
			// please see explanation on the main page ngano naay added na 0.40001d
			dTotalHours = ((Double)vHoursWork.remove(0)).doubleValue();
			if(WI.fillTextValue("show_actual_time").length() > 0){
				iHours = (int)dTotalHours;
				iMinutes = (int)(((dTotalHours - iHours) * 60) + 0.40001d);
				strTemp = Integer.toString(iMinutes);
				if(strTemp.length() == 1)
					strTemp = "0" + strTemp;
				strTemp = iHours + ":" + strTemp;
			}else
				strTemp = CommonUtil.formatFloat(dTotalHours,true);		
			%>
				<%=strTemp%>
	<%}%>	  </td>
      <% 
			strHoliday = "";
			if (vRetHolidays != null && vRetHolidays.size() > 0 
				&&((String)vRetHolidays.elementAt(1)).equals(strPrevDate) 
				&& !bolDateRepeated){
			//strHoliday = (String)vRetHolidays.elementAt(0);
			//vRetHolidays.removeElementAt(0);
			//vRetHolidays.removeElementAt(0);

			iIndexOf = vRetHolidays.indexOf(strPrevDate);			
			while(iIndexOf != -1){
				strHoliday += (String)vRetHolidays.elementAt(iIndexOf-1) + "<br>";
				vRetHolidays.remove(iIndexOf);
				vRetHolidays.remove(iIndexOf-1);					
				iIndexOf = vRetHolidays.indexOf(strPrevDate);
			}					
	}else
		strHoliday = "";

	if (vEmpLeave != null && vEmpLeave.size() > 0 &&
		!bolDateRepeated){
			iIndexOf = vEmpLeave.indexOf(strPrevDate);
			while(iIndexOf != -1){
 				vEmpLeave.remove(iIndexOf);// remove date
				strLeave = (String)vEmpLeave.remove(iIndexOf); // remove leave hours
        vEmpLeave.remove(iIndexOf);// remove leave status
				if(strSchCode.startsWith("AUF")){
					vEmpLeave.remove(iIndexOf);// remove leave type
					strLeave = "Leave(" + strLeave +")";
				}else{
					strLeave = WI.getStrValue((String)vEmpLeave.remove(iIndexOf),"w/out pay") + "(" + strLeave +")";
				}
				vEmpLeave.remove(iIndexOf); // remove free
				vEmpLeave.remove(iIndexOf); // remove free
				vEmpLeave.remove(iIndexOf); // remove free
				vEmpLeave.remove(iIndexOf); // remove free
				vEmpLeave.remove(iIndexOf); // remove free
				vEmpLeave.remove(iIndexOf); // remove free
				strHoliday += strLeave; 
				iIndexOf = vEmpLeave.indexOf(strPrevDate);
			}
	}

	if (vRetOBOT != null && vRetOBOT.size() > 0 &&
		((String)vRetOBOT.elementAt(0)).equals(strPrevDate) &&
		!bolDateRepeated){

		vRetOBOT.removeElementAt(0);
		strHoliday += " OB/OT";
	}

	if (vEmpLogout != null && vEmpLogout.size() > 0 &&
		((String)vEmpLogout.elementAt(0)).equals(strPrevDate)
		&& !bolDateRepeated){

		vEmpLogout.removeElementAt(0);
		strHoliday += strOBLabel + WI.getStrValue((String)vEmpLogout.remove(0),"Whole Day") +")";
		if(vEmpLogout != null){
			iIndexOf = vEmpLogout.indexOf(strPrevDate);
			while(iIndexOf != -1){
				vEmpLogout.remove(iIndexOf);// date
				vEmpLogout.remove(iIndexOf);// hours
				iIndexOf = vEmpLogout.indexOf(strPrevDate);
			}
		}		
		bolIsOB = true;
	}

	if (vAWOLRecords != null && vAWOLRecords.size() > 0 &&
		ConversionTable.convertMMDDYYYY((Date)vAWOLRecords.elementAt(0)).equals(strPrevDate)
		&& !bolDateRepeated && !bolIsOB){
		iIndexOf = -1;
			if(vSuspended != null && vSuspended.size() > 0)
				iIndexOf = vSuspended.indexOf(strPrevDate);
	
			if(iIndexOf != -1){
				vAWOLRecords.removeElementAt(0);
				vAWOLRecords.removeElementAt(0);
				strHoliday += "Suspended";
			}else{
				vAWOLRecords.removeElementAt(0);
				strHoliday += strAWOL + (String)vAWOLRecords.remove(0) +")";			
			}
	}

	if (vEmpOvertime != null && vEmpOvertime.size() > 0 &&
	((String)vEmpOvertime.elementAt(0)).equals(strPrevDate)
		&& !bolDateRepeated){

		vEmpOvertime.removeElementAt(0); // date
		strHoliday += "OT (" + (String)vEmpOvertime.remove(0) +")";
	}
	//if(strSchCode.startsWith("AUF") && bolHasInc){	
	if(strSchCode.startsWith("AUF") && bolHasEntry){
		strHoliday = strHoliday.replaceFirst("AWOL","INC. ENTRIES");		
	}	
%>
      <td class="thinborder">&nbsp;<%=strHoliday%></td>
      <%
		if(strTemp2 != null) iIndex += 8;

		if (!strTemp3.equals((String)vRetEDTR.elementAt(iIndex+4))){
				strTemp3  = (String)vRetEDTR.elementAt(iIndex+4);
		}
	%>
    </tr>
    <%
	  } // end for loop


	  //I have to now print if there are any days having zero working hours.
	while(vDayInterval != null && vDayInterval.size() > 0) {
		if (vRetHolidays != null && vRetHolidays.size() > 0 &&
			((String)vRetHolidays.elementAt(1)).equals((String)vDayInterval.elementAt(0))
			&& !bolDateRepeated){

			strHoliday = (String)vRetHolidays.remove(0);
			vRetHolidays.removeElementAt(0);
		}else
			strHoliday = "";

		if (vEmpLeave != null && vEmpLeave.size() > 0 &&
			((String)vEmpLeave.elementAt(0)).equals((String)vDayInterval.elementAt(0)) &&
			!bolDateRepeated){
 				vEmpLeave.removeElementAt(0);// remove date
				strLeave = (String)vEmpLeave.remove(0); // remove leave hours
        vEmpLeave.remove(0);// remove leave status
				if(strSchCode.startsWith("AUF")){
					vEmpLeave.remove(0);// remove leave type
					strLeave = "Leave(" + strLeave +")";
				}else{
					strLeave = WI.getStrValue((String)vEmpLeave.remove(0),"w/out pay") + "(" + strLeave +")";
				}
				vEmpLeave.remove(0); // remove free
				vEmpLeave.remove(0); // remove free
				vEmpLeave.remove(0); // remove free
				vEmpLeave.remove(0); // remove free
				vEmpLeave.remove(0); // remove free
				vEmpLeave.remove(0); // remove free
				strHoliday += strLeave; 			
		}

		if (vRetOBOT != null && vRetOBOT.size() > 0 &&
			((String)vRetOBOT.elementAt(0)).equals((String)vDayInterval.elementAt(0)) &&
			!bolDateRepeated){

			vRetOBOT.removeElementAt(0);
			strHoliday += " OB/OT";
		}

		if (vEmpLogout != null && vEmpLogout.size() > 0 &&
		((String)vEmpLogout.elementAt(0)).equals((String)vDayInterval.elementAt(0))
			&& !bolDateRepeated){

			vEmpLogout.removeElementAt(0);
			strHoliday += strOBLabel + WI.getStrValue((String)vEmpLogout.remove(0),"Whole Day") +")";
			if(vEmpLogout != null){
				iIndexOf = vEmpLogout.indexOf((String)vDayInterval.elementAt(0));
				while(iIndexOf != -1){
					vEmpLogout.remove(iIndexOf);// date
					vEmpLogout.remove(iIndexOf);// hours
					iIndexOf = vEmpLogout.indexOf((String)vDayInterval.elementAt(0));
				}
			}					
			bolIsOB = true;
		}

		if (vAWOLRecords != null && vAWOLRecords.size() > 0 &&
		(ConversionTable.convertMMDDYYYY((Date)vAWOLRecords.elementAt(0)).equals((String)vDayInterval.elementAt(0)))
			&& !bolDateRepeated && !bolIsOB){
			iIndexOf = -1;
			if(vSuspended != null && vSuspended.size() > 0)
				iIndexOf = vSuspended.indexOf((String)vDayInterval.elementAt(0));
	
			if(iIndexOf != -1){
				vAWOLRecords.removeElementAt(0);
				vAWOLRecords.removeElementAt(0);
				strHoliday += "Suspended";
			}else{
				vAWOLRecords.removeElementAt(0);
				strHoliday += strAWOL + (String)vAWOLRecords.remove(0) +")";			
			}
		}

		if (vEmpOvertime != null && vEmpOvertime.size() > 0 &&
		((String)vEmpOvertime.elementAt(0)).equals((String)vDayInterval.elementAt(0))
			&& !bolDateRepeated){

			vEmpOvertime.removeElementAt(0); // date
			strHoliday += "OT (" + (String)vEmpOvertime.remove(0) +")";
		}

	if (strHoliday.length()  > 0) {
	%>
    <tr>
      <td height="20" class="thinborder"> &nbsp;<%=(String)vDayInterval.remove(0)+ "::" +
											((String)vDayInterval.remove(0)).substring(0,3)%></td>
      <td height="20" colspan="10" align="center" class="thinborder"><strong>&nbsp;<%=strHoliday%></strong></td>
    </tr>
<%}else{%>
    <tr>
      <td height="20" class="thinborder"> &nbsp;<%=(String)vDayInterval.remove(0)+"::"+(String)((String)vDayInterval.remove(0)).substring(0,3)%></td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp; </td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp; </td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
    </tr>
    <% }
	  }//end of while looop
     }
	}else{

	 if (strErrMsg == null || strErrMsg.length() == 0)
	 strErrMsg = " 0 RECORD FOUND ";

	%>
    <tr >
      <td height="25" colspan="11" class="thinborder">&nbsp;&nbsp; <strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong> </td>
    </tr>
    <%} // end if (vRetEDTR.size() == 1)%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="18" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
</table>
<% //Vector vLateUnderTime = RE.getMonthlyLateUTime(dbOP,request); %>
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
      <td width="15%" align="center" class="thinborder"><div align="center"><strong>TOTAL</strong></div></td>
      <td width="13%" align="center" class="thinborder"><strong>AM</strong></td>
      <td width="14%" align="center" class="thinborder"><strong>PM</strong></td>
      <td width="15%" class="thinborder"><div align="center"><strong>TOTAL</strong></div></td>
    </tr>

    <tr>
      <td height="25" class="thinborder">&nbsp;<strong>TARDINESS</strong></td>
      <td align="right" class="thinborder">
      <% if (iTotalLateAM != 0){%><%=iTotalLateAM%> <%}%>&nbsp;</td>
	  <td align="right" class="thinborder">
      <% if (iTotalLatePM != 0){%><%=iTotalLatePM%><%}%>&nbsp;</td>
	  <td align="right" class="thinborder">
	    <% if (iTotalLateAM + iTotalLatePM != 0){%>
	  			<%=iTotalLateAM + iTotalLatePM%><%}%>&nbsp;      </td>
      <td align="right" class="thinborder">
      <% if (iFreqLateAM != 0){%>
			<%=iFreqLateAM%><%}%>&nbsp;</td>
      <td align="right" class="thinborder">
      <% if (iFreqLatePM != 0){%><%=iFreqLatePM%><%}%>&nbsp;</td>
      <td align="right" class="thinborder">
        <% if (iFreqLateAM + iFreqLatePM != 0){%>
	  <%=iFreqLateAM + iFreqLatePM%><%}%>&nbsp;</td>
    </tr>
    <tr>
      <td height="25" class="thinborder"><strong>&nbsp;UNDERTIME </strong></td>
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
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
	<%if(WI.fillTextValue("hide_schedule").length() == 0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="5" align="center" class="thinborder"><strong>WORK
        SCHEDULE </strong></td>
    </tr>
    <% if (vWorkingHours == null || vWorkingHours.size() == 0) {
		strErrMsg = RE.getErrMsg();
	if (strErrMsg == null || strErrMsg.length() ==0)
		strErrMsg = " No record of employee Working Hour.";
%>
    <tr>
      <td height="25" colspan="5" align="center" class="thinborder"><strong><%=strErrMsg%></strong></td>
    </tr>
    <%}else{%>
    <tr align="center">
      <td width="18%" height="25" class="thinborder"><strong>WEEK DAY</strong></td>
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
				else {
					strWeekDay = (String)vWorkingHours.elementAt(i+33);
					if(strWeekDay == null)
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
	  <td height="25" class="thinborder">&nbsp;<%=strWeekDay%></td>
      <td class="thinborder">&nbsp;<%=strTimeIn0%></td>
      <td class="thinborder">&nbsp;<%=strTimeOut0%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTimeIn1)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTimeOut1)%></td>
	 </tr>
	 <%}else{%>
	 <tr>
	  <td height="25" class="thinborder">&nbsp;<%=strWeekDay%></td>
      <td class="thinborder" colspan="4">&nbsp;<%=strTemp%></td>
	 </tr>
	 <%}%>
    <%}
	} // end if vWorkingHours == null || vWorkingHours.size() ==0%>
  </table>
	<%}%>
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
      <td width="16%" height="15" class="thinborder"><strong>TIME </strong></td>
      <td width="21%" class="thinborder"><strong>ROOM</strong></td>
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
<%}%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="2" valign="bottom"><div align="center"><font size="1">I HEREBY
        CERTIFY THAT THE ABOVE RECORDS ARE TRUE AND CORRECT</font></div></td>
    </tr>
    <tr>
        <td width="50%" height="25" align="center" valign="bottom" bgcolor="#FFFFFF"><strong><font size="1">Certified
          Correct</font></strong></td>
      <td width="50%" align="center" valign="bottom" bgcolor="#FFFFFF"><strong><font size="1">Verified
        and Attested Correct </font></strong></td>
    </tr>
    <tr>
      <td height="25" align="center" valign="bottom" bgcolor="#FFFFFF"> <%=WI.fillTextValue("certified")%> </td>
      <td align="center" valign="bottom" bgcolor="#FFFFFF"> <%=WI.fillTextValue("verified_attested")%> </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="32%" valign="bottom" bgcolor="#FFFFFF"><div align="center"><strong></strong></div></td>
    </tr>
    <tr>
      <td valign="bottom" bgcolor="#FFFFFF"><div align="center"><strong><font size="1">Noted
        by </font></strong> <%=WI.fillTextValue("verified")%> </div></td>
    </tr>
  </table>
<%} // end for(iMain....)%>
<%} // if (vRetResult != null && vRetResult.size() > 0)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
