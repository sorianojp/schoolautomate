<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style>
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
	TD.thinborderTopBottomLeft {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }


    TD.thinborderLeft {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

	TD.thinborderDate {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
	TD.thinborderLeft {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

	TD {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
	TD.thinborderTop{
	    border-top: solid 1px #000000;
	}
	
	TD.thinborderBottom{
    border-bottom: solid 1px #000000;
    }	
</style>
</head>

<body onLoad="window.print()">
<%@ page language="java" import="utility.*, eDTR.ReportEDTR,eDTR.eDTRUtil, eDTR.WorkingHour,
																java.util.Vector, java.util.Calendar,java.util.Date, eDTR.AllowedLateTimeIN" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strDate = null;
	int iIndexOf = 0;
	String strLeave = null;
	//boolean bolHasInc = false;
	boolean bolHasEntry = false;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");	
	if (strSchCode == null)
		strSchCode =  "";
		
	String strAWOL = " AWOL (";
	if(strSchCode.startsWith("CLDH")){
		strAWOL = " ABSENT (";
	}

	String strOBLabel = "OB(";
	if(strSchCode.startsWith("AUF")){
		strOBLabel = " OL(";
	}

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").equals("1"))
		bolMyHome = true;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS-Ind Monthly Report of Emp Attendance","monthly_report_emp_attendance_print.jsp");
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
														"monthly_report_emp_attendance_print.jsp");

strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		iAccessLevel = 1;
		request.setAttribute("emp_id",strTemp);
	}
}

if (strTemp == null)
	strTemp = "";

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
int iTemp = 0;
int iSearchResult = 0;
ReportEDTR RE = new ReportEDTR(request);
enrollment.FacultyManagement FM = new enrollment.FacultyManagement();
enrollment.Authentication authentication = new enrollment.Authentication();
AllowedLateTimeIN allowedLateTIN = new AllowedLateTimeIN();
String[] astrMonth={" &nbsp", "January", "February", "March", "April", "May", "June", "July",
					"August", "September","October", "November", "December"};
String[] astrWeekDays={"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};

Vector vEmpDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
if ( vEmpDetails == null || vEmpDetails.size() ==0){
	strErrMsg = authentication.getErrMsg();
}
Vector vRetEDTR = null;

Vector vWorkingHours =  RE.getEmployeeWorkingHours(dbOP,false);
Vector vFacultyLoad = null;
Vector vSalaryPeriod = null;
Vector vLateTimeIn  = null;
	int iTotalLateAM = 0;
	int iTotalLatePM = 0;
	int iFreqLateAM = 0;
	int iFreqLatePM = 0;

	int iTotalUTAM = 0;
	int iTotalUTPM = 0;
	int iFreqUTAM = 0;
	int iFreqUTPM = 0;

	int iFirstDayBlank = 0;
	

String strDateFr = null;
String strDateTo = null;

String strMonths = WI.fillTextValue("strMonth");
String strYear = WI.fillTextValue("sy_");

String strLateUT = null;
String strHoliday = null;
String strSemester = null;
String strSYFrom = null;
String strSYTo = null;
Calendar calendar = Calendar.getInstance();
String strEmployeeIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
	if(bolMyHome)
		strEmployeeIndex = (String)request.getSession(false).getAttribute("userIndex");
String strLateSetting = null;
String strSQLQuery = null;
int iAllowedLateAm = 0;
int iAllowedLatePm = 0;
boolean bolIsOB = false;
int iSize = 0;

	vLateTimeIn = allowedLateTIN.operateOnLateSetting(dbOP, request, 3);
	if(vLateTimeIn != null && vLateTimeIn.size() > 0){
		strLateSetting = (String)vLateTimeIn.elementAt(0);
	}
	strSQLQuery = "select user_index_ from edtr_no_grace where user_index_ = " + strEmployeeIndex;
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery,0);
	// check if in the no grace period table
	//      if(strSQLQuery == null && (strLateSetting.equals("2") || strLateSetting.equals("3"))){
	if(strSQLQuery == null && vLateTimeIn != null){
		iAllowedLateAm = Integer.parseInt((String)vLateTimeIn.elementAt(1));
		iAllowedLatePm = Integer.parseInt((String)vLateTimeIn.elementAt(2));
	}
    if (!strMonths.equals("0") && strMonths.length() > 0){
      
		if(WI.fillTextValue("sal_period").length() > 0){
			vSalaryPeriod = RE.getEmployeeCutOffRange(dbOP, request, strEmployeeIndex);
			if(vSalaryPeriod != null && vSalaryPeriod.size() > 0){
				strDateFr = (String)vSalaryPeriod.elementAt(0);
				strDateTo = (String)vSalaryPeriod.elementAt(1); 
			}
		} else {
			try{
	
				if ( strYear.length()> 0){
					if (Integer.parseInt(strYear) >= 2005)
						calendar.set(Calendar.YEAR, Integer.parseInt(strYear));
				else
					strErrMsg = " Invalid year entry";
				}
			}
			catch (NumberFormatException nfe){
			strErrMsg = " Invalid year entry";
			}
			calendar.set(Calendar.DAY_OF_MONTH,1);
				calendar.set(Calendar.MONTH,Integer.parseInt(strMonths)-1);
	
			if (calendar.get(Calendar.MONTH) <=2 ||
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
	
	
				strDateFr = strMonths + "/01/" + calendar.get(Calendar.YEAR);
				strDateTo = strMonths + "/" + Integer.toString(calendar.getActualMaximum(Calendar.DAY_OF_MONTH))
						+ "/" + calendar.get(Calendar.YEAR);
	
		 vFacultyLoad = FM.viewFacultyLoadSummary(dbOP,(String)vEmpDetails.elementAt(0),
					strSYFrom,strSYTo,strSemester, "",false,true);//get additional data.
			}
    }
	if (strErrMsg != null) {
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
<%} if (vEmpDetails != null && vEmpDetails.size() > 0){ %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
      <tr>
        <td height="20" colspan="2" align="center"  class="thinborder"><font size="2"><strong>
		<% if (!WI.fillTextValue("my_home").equals("1")){%>
		<%=WI.fillTextValue("emp_id")%>
		<%}else{%>
		<%=(String)request.getSession(false).getAttribute("userId")%>
		<%}%></strong></font></td>
        <td width="83%" height="20" colspan="2"  class="thinborder"><font size="2"><strong>&nbsp;<%=WI.formatName((String)vEmpDetails.elementAt(1),
	  (String)vEmpDetails.elementAt(2), (String)vEmpDetails.elementAt(3),4).toUpperCase()%></strong></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td width="9%" height="19"  class="thinborder"> &nbsp;UNIT </td>
<%	strTemp = (String)vEmpDetails.elementAt(11);
	if (strTemp != null){
		strTemp = dbOP.mapOneToOther("COLLEGE","C_INDEX", strTemp,"C_CODE"," and is_del = 0");
		if ((String)vEmpDetails.elementAt(12) != null) {
			strTemp += " :: " + dbOP.mapOneToOther("DEPARTMENT","D_INDEX", (String)vEmpDetails.elementAt(12),"D_CODE"," and is_del = 0");
		}
	}else{
		strTemp = dbOP.mapOneToOther("DEPARTMENT","D_INDEX", (String)vEmpDetails.elementAt(12),"D_CODE"," and is_del = 0");
	}

%>
      <td width="27%"  class="thinborder"><strong>&nbsp;<%=WI.getStrValue(strTemp)%> </strong></td>
      <td width="64%" height="19"  class="thinborder">&nbsp;MONTH OF <strong>
		<%=astrMonth[Integer.parseInt(WI.getStrValue(strMonths,"1"))]%>&nbsp;<%=WI.fillTextValue("sy_")%>
      </strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="15" bgcolor="#FFFFFF"><font size="1">&nbsp;</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr >
      <td height="13" colspan="10" align="center" class="thinborder"><strong>DAILY TIME RECORD</strong></td>
    </tr>
    <%

	if (WI.fillTextValue("my_home").equals("1"))
		strTemp = (String)request.getSession(false).getAttribute("userId");
	else
		strTemp = WI.fillTextValue("emp_id");


	vRetEDTR = RE.getDTRDetails(dbOP,strTemp,true);
	if(vRetEDTR != null)
		iSize = vRetEDTR.size();
	if ((vRetEDTR!=null && iSize > 0) || true) {

%>
    <tr >
      <td width="10%" height="13" class="thinborder">  		<strong>&nbsp;&nbsp;&nbsp;DATE</strong></td>
      <td width="13%" class="thinborder"><strong>&nbsp;&nbsp;IN</strong></td>
      <td width="5%" class="thinborder"><strong>&nbsp;&nbsp;L</strong></td>
      <td width="13%" class="thinborder"><strong>&nbsp;&nbsp;OUT</strong></td>
      <td width="5%" class="thinborder"><strong>&nbsp;&nbsp;U</strong></td>
      <td width="13%" class="thinborder"><strong>&nbsp;&nbsp;IN</strong></td>
      <td width="5%" class="thinborder"><strong>&nbsp;&nbsp;L</strong></td>
      <td width="13%" class="thinborder"><strong>&nbsp;&nbsp;OUT</strong></td>
      <td width="5%" class="thinborder"><strong>&nbsp;&nbsp;U</strong></td>
      <td width="18%" class="thinborder"><strong>&nbsp;&nbsp;REMARKS</strong></td>
    </tr>
    <% 	if (iSize == 1){//non DTR employees %>
    <tr>
      <td height="19" colspan="10" class="thinborder"> <div align="center"><strong><%=vRetEDTR.elementAt(0)%></strong></div></td>
    </tr>
    <%}else{
//	strTemp3 = "";

	String strPrevDate = "";//this is added to avoid displaying date in 2nd row.
	boolean bolDateRepeated = false;
	String strLatePMEntry = null;
	String strUTPMEntry = null;
	String strDateEntry  = "";

//as requestd, i have to show all the days worked and non worked.
	Vector vDayInterval = RE.getDayNDateDetail(strDateFr,strDateTo);
	Vector vAWOLRecords = RE.getAWOLEmployee(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo, strSchCode);
	//System.out.println("vAWOLRecords " + vAWOLRecords);
	Vector vLateUnderTime = RE.getMonthlyLateUTimeDetail(dbOP, request);
	Vector vEmpLeave = RE.getEmployeeLeaveAndName(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo, strSchCode);
 
	Vector vRetHolidays = RE.getHolidaysOfMonth(dbOP,request, strEmployeeIndex);

	Vector vRetOBOT = RE.getEmpOBOT(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo);

	Vector vEmpLogout = RE.getEmpLogout(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo);

	Vector vEmpOvertime = RE.getEmpOverTime(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo);
	Vector vSuspended = RE.getEmpSuspensions(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo);

	for(int iIndex=0;iIndex<iSize;iIndex +=8){
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

		if(strPrevDate.equals( (String)vRetEDTR.elementAt(iIndex+4))) {
			bolDateRepeated = true;
		}
		else {
			bolDateRepeated = false;
			strPrevDate = (String)vRetEDTR.elementAt(iIndex+4);
		}



//I ahve to display here for the days employee did not work.
if(!bolDateRepeated && vDayInterval != null && vDayInterval.size() > 0) {
	strTemp3 = ""; iFirstDayBlank = 0;
	while(strPrevDate.compareTo((String)vDayInterval.elementAt(0)) != 0) {

		if (iFirstDayBlank  == 0)
			strTemp3 = "thinborderTopBottomLeft";
		else
			strTemp3 = "thinborder";
		iFirstDayBlank++;

		strHoliday = "";
		if (vRetHolidays != null && vRetHolidays.size() > 0 
			//&& ((String)vRetHolidays.elementAt(1)).equals((String)vDayInterval.elementAt(0))
			&& !bolDateRepeated){

			//strHoliday = (String) vRetHolidays.remove(0);
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
			strHoliday += strOBLabel +  WI.getStrValue((String)vEmpLogout.remove(0),"Whole day") +")";
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
			&& !bolDateRepeated  && !bolIsOB){
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

	strDateEntry = (String)vDayInterval.remove(0);

	if (strHoliday.length() == 0) {
%>

    <tr>
      <td height="18" class="thinborderLeft">
	  	<%=strDateEntry.substring(strDateEntry.indexOf("/") + 1,strDateEntry.lastIndexOf("/"))
				+ "&nbsp;" + ((String)vDayInterval.remove(0)).substring(0,3)%></td>
      <td class="thinborderLeft">&nbsp;</td>
      <td class="thinborderLeft">&nbsp;</td>
      <td class="thinborderLeft">&nbsp;</td>
      <td class="thinborderLeft">&nbsp;</td>
      <td class="thinborderLeft">&nbsp;</td>
      <td class="thinborderLeft">&nbsp;</td>
      <td class="thinborderLeft">&nbsp;</td>
      <td class="thinborderLeft">&nbsp;</td>
      <td class="thinborderLeft">&nbsp;</td>
    </tr>
<%}else{%>
    <tr>
      <td height="18" class="thinborderLeft">
	  	<%=strDateEntry.substring(strDateEntry.indexOf("/")+1,strDateEntry.lastIndexOf("/")) +
				"&nbsp;" + ((String)vDayInterval.remove(0)).substring(0,3)%></td>
      <td class="thinborderLeft">&nbsp;</td>
      <td class="thinborderLeft">&nbsp;</td>
      <td class="thinborderLeft">&nbsp;</td>
      <td class="thinborderLeft">&nbsp;</td>
      <td class="thinborderLeft">&nbsp;</td>
      <td class="thinborderLeft">&nbsp;</td>
      <td class="thinborderLeft">&nbsp;</td>
      <td class="thinborderLeft">&nbsp;</td>
      <td class="thinborderLeft"><font size="1"><%=WI.getStrValue(strHoliday,"&nbsp;")%></font></td>
    </tr>
    <% } // if else show holiday..
	 }//end of while looop
  if(vDayInterval.size() > 0)  {
  	vDayInterval.removeElementAt(0);vDayInterval.removeElementAt(0);
  }

}//end of if condition to print holidays.%>
    <tr>

      <td height="18" class="thinborderLeft"> <font size="1">
      <%if(!bolDateRepeated){
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
			<%}%>
      </font></td>

      <td class="thinborderLeft">
	    <font size="1">
	    <%
				bolHasEntry = true;				
				strTemp3 = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 2)).longValue(),2);
				strTemp3 = strTemp3.substring(0, strTemp3.length() -1);
			%>
	  	<%=strTemp3%>  </font></td>

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
      <td class="thinborderLeft"><font size="1"><%=WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 6))%>&nbsp;</font></td>
      <td class="thinborderLeft">
  			<font size="1">
	  <%  strTemp3=WI.getStrValue(WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 3)).longValue(),2));
	  //if (!strTemp3.equals("&nbsp;")) {
		  strTemp3=WI.getStrValue(strTemp3,"-inc-");
			//if(strTemp3.equals("-inc-"))
			//	bolHasInc = true;			
		//}else{
		 // strTemp3=WI.getStrValue(strTemp3,"&nbsp;");
		//}		
				if (strTemp3.length() == 8)
					strTemp3 = strTemp3.substring(0, 7);%>
  			<font size="1"><%=strTemp3%></font></font></td>
	  <%
	  	if (!WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 7), "0").equals("0")){
			iTotalUTAM += Integer.parseInt((String)vRetEDTR.elementAt(iIndex + 7));
			iFreqUTAM++;
		}
	  %>
      <td class="thinborderLeft"><font size="1"><%=WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 7))%>&nbsp;</font></td>
      <td class="thinborderLeft"><font size="1">
      <% strTemp3=WI.getStrValue(strTemp,"&nbsp;");%>
	  <% if (strTemp3.length() == 8)
	  		strTemp3  = strTemp3.substring(0,7); %>
	  <%=strTemp3%>
	  </font></td>
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
      <td class="thinborderLeft"><font size="1"><%=strLatePMEntry%>&nbsp;</font></td>
      <td class="thinborderLeft"><font size="1">
    <%
	  if (!strTemp3.equals("&nbsp;")) {
		  strTemp3 = WI.getStrValue(strTemp2,"-inc-");
			//bolHasInc = true;
		} else {
		  strTemp3 = WI.getStrValue(strTemp2,"&nbsp;");
		}
	  if (strTemp3.length() == 8)
			strTemp3 = strTemp3.substring(0,7);
	  %>
		<%=strTemp3%>
	  </font>
		</td>
	  <%
	  if (!WI.getStrValue(strUTPMEntry, "0").equals("0")){
			iTotalUTPM += Integer.parseInt(strUTPMEntry);
			iFreqUTPM++;
		}
	  %>
      <td class="thinborderLeft"><font size="1"><%=strUTPMEntry%>&nbsp;</font></td>

 <%
 	if (vRetHolidays != null && vRetHolidays.size() > 0 
 		&& ((String)vRetHolidays.elementAt(1)).equals(strPrevDate) 
		&& !bolDateRepeated){
		//strHoliday = (String)vRetHolidays.elementAt(0);
		//vRetHolidays.removeElementAt(0);
		//vRetHolidays.removeElementAt(0);
		
		iIndexOf = vRetHolidays.indexOf(strPrevDate);
		//System.out.println("(String)vDayInterval.elementAt(0) - " + (String)vDayInterval.elementAt(0));
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
		strHoliday += strOBLabel +  WI.getStrValue((String)vEmpLogout.remove(0),"Whole day") +")";
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
		&& !bolDateRepeated  && !bolIsOB){

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

	if (vEmpOvertime != null && vEmpOvertime.size() > 0	
		&& !bolDateRepeated){
		iIndexOf = vEmpOvertime.indexOf(strPrevDate);
		while(iIndexOf != -1){
			vEmpOvertime.remove(iIndexOf); // date
			strHoliday += " OT (" + (String)vEmpOvertime.remove(iIndexOf) +")";
			iIndexOf = vEmpOvertime.indexOf(strPrevDate);
		}
	}
	
	//if(strSchCode.startsWith("AUF") && bolHasInc){	
	//System.out.println("bolHasEntry " + bolHasEntry);
	if(strSchCode.startsWith("AUF") && bolHasEntry){	
		strHoliday = strHoliday.replaceFirst("AWOL","INC. ENTRIES");		
	}	
%>
      <td class="thinborderLeft"><font size="1"><%=WI.getStrValue(strHoliday,"&nbsp;")%></font></td>
      <%
		if(strTemp2 != null) iIndex += 8;

	%>
    </tr>
    <%
	  } // end for loop

	  //I have to now print if there are any days having zero working hours.

	while(vDayInterval != null && vDayInterval.size() > 0) {
		strHoliday = "";
		if (vRetHolidays != null && vRetHolidays.size() > 0 
			//&&((String)vRetHolidays.elementAt(1)).equals((String)vDayInterval.elementAt(0))
			&& !bolDateRepeated){

			//strHoliday = "holiday";
			//vRetHolidays.removeElementAt(0);
			//vRetHolidays.removeElementAt(0);
			iIndexOf = vRetHolidays.indexOf((String)vDayInterval.elementAt(0));
			//System.out.println("(String)vDayInterval.elementAt(0) - " + (String)vDayInterval.elementAt(0));
			while(iIndexOf != -1){
				strHoliday += (String)vRetHolidays.elementAt(iIndexOf-1) + "<br>";
				vRetHolidays.remove(iIndexOf);
				vRetHolidays.remove(iIndexOf-1);					
				iIndexOf = vRetHolidays.indexOf((String)vDayInterval.elementAt(0));
				//strHoliday = "holiday";
			}			
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
			strHoliday += strOBLabel +  WI.getStrValue((String)vEmpLogout.remove(0),"Whole day") +")";
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
			&& !bolDateRepeated  && !bolIsOB){
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


		strDateEntry = (String)vDayInterval.remove(0);

  %>
    <tr>
      <td height="18" class="thinborderLeft">
	  	<%=strDateEntry.substring(strDateEntry.indexOf("/")+1,strDateEntry.lastIndexOf("/"))+"&nbsp;"+((String)vDayInterval.remove(0)).substring(0,3)%></td>
      <td height="18" class="thinborderLeft">&nbsp;</td>
      <td height="18" class="thinborderLeft">&nbsp;</td>
      <td height="18" class="thinborderLeft">&nbsp;</td>
      <td height="18" class="thinborderLeft">&nbsp;</td>
      <td height="18" class="thinborderLeft">&nbsp;</td>
      <td height="18" class="thinborderLeft">&nbsp;</td>
      <td height="18" class="thinborderLeft">&nbsp;</td>
      <td height="18" class="thinborderLeft">&nbsp;</td>
      <td height="18" class="thinborderLeft"><%=WI.getStrValue(strHoliday,"&nbsp;")%></td>
    </tr>
    <%
  	   } //end of while looop
	  } %>
<!--
    <tr >
      <td height="20" colspan="10" align="center" class="thinborderTopBottomLeft">*********** end daily time record ***********</td>
    </tr>
-->
<%
	 }else{

	 if (strErrMsg == null || strErrMsg.length() == 0)
	 strErrMsg = " 0 RECORD FOUND ";

	%>
    <tr >
      <td height="20" colspan="10" class="thinborder">&nbsp;&nbsp; <strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong> </td>
    </tr>
    <%} // end if (vRetEDTR.size() == 1)%>
</table>

<% //Vector vLateUnderTime = RE.getMonthlyLateUTime(dbOP,request); 
	if (WI.fillTextValue("hide_summary").length() ==0){
%>
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
<%}%>
	<%if(WI.fillTextValue("hide_schedule").length() == 0){%>
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
<%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="6" valign="bottom"><div align="center"><font size="1">I HEREBY
        CERTIFY THAT THE ABOVE RECORDS ARE TRUE AND CORRECT</font></div></td>
    </tr>
    <tr>
        <td height="25" colspan="3" align="center" valign="bottom" bgcolor="#FFFFFF"><strong><font size="1">Certified
          Correct</font></strong></td>
      <td colspan="3" align="center" valign="bottom" bgcolor="#FFFFFF"><strong><font size="1">Verified
        and Attested Correct </font></strong></td>
    </tr>
    <tr>
      <td height="25" align="center" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="25" align="center" valign="bottom" bgcolor="#FFFFFF" class="thinborderBottom"><%=WI.fillTextValue("certified")%> </td>
      <td height="25" align="center" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td align="center" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td align="center" valign="bottom" bgcolor="#FFFFFF" class="thinborderBottom"><%=WI.fillTextValue("verified_attested")%> </td>
      <td align="center" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <%if(strSchCode.startsWith("AUF")){%>
		<tr>
      <td width="10%" height="19" align="center" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="30%" align="center" valign="bottom" bgcolor="#FFFFFF">Faculty/NTP</td>
      <td width="10%" align="center" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="10%" align="center" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="30%" align="center" valign="bottom" bgcolor="#FFFFFF">Dean/Head</td>
      <td width="10%" align="center" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
		<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td colspan="3" valign="bottom" bgcolor="#FFFFFF"><div align="center"><strong></strong></div></td>
    </tr>
    <tr>
      <td align="right" valign="bottom" bgcolor="#FFFFFF"><strong><font size="1">Noted
        by </font></strong></td>
      <td width="28%" valign="bottom" bgcolor="#FFFFFF" class="thinborderBottom">&nbsp;<%=WI.fillTextValue("verified")%> </td>
      <td width="22%" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <%if(strSchCode.startsWith("AUF")){%>
		<tr>
      <td width="50%" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td colspan="2" valign="bottom" bgcolor="#FFFFFF">&nbsp;HRDC</td>
    </tr>
		<%}%>
  </table>
  <%}//end  to display employee information.%>
</body>
</html>
<%
dbOP.cleanUP();
%>
