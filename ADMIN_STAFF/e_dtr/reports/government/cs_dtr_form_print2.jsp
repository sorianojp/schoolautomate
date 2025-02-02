<%@ page language="java" import="utility.*, eDTR.ReportEDTR,eDTR.eDTRUtil, eDTR.WorkingHour,
																java.util.Vector, java.util.Calendar,java.util.Date, 
																eDTR.AllowedLateTimeIN"%>
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
	document.getElementById("copy_label").innerHTML = document.getElementById("main_label").innerHTML;
}
</script>

<body onLoad="javscript:copyLabel();window.print();">
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
	int iIndexOf2 = 0;
	int iAwolType = -1;
	//double dTemp = 0d;
	
	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0)
		bolMyHome = true;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS","cs_dtr_form.jsp");
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
														"cs_dtr_form.jsp");
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		iAccessLevel = 1;
		request.setAttribute("emp_id",strTemp);
	}
}

if (strTemp == null)
	strTemp = "";
//

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
enrollment.FacultyManagement FM = new enrollment.FacultyManagement();
enrollment.Authentication authentication = new enrollment.Authentication();
AllowedLateTimeIN allowedLateTIN = new AllowedLateTimeIN();

String[] astrMonth={" &nbsp;", "January", "February", "March", "April", "May", "June",
					 "July","August", "September","October", "November", "December"};
String[] astrWeekDays={"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};

Vector vEmpDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
if ( vEmpDetails == null || vEmpDetails.size() ==0){
	strErrMsg = authentication.getErrMsg();
}
Vector vRetEDTR = null;
Vector vWorkingHours =  RE.getEmployeeWorkingHours(dbOP,false);
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
	int iFirstDayBlank = 0;

	Vector vFacultyLoad = null;
	Vector vSalaryPeriod = null;
	String strDateFr = null;
	String strDateTo = null;
	double dTotalHours = 0d;

	double dTemp = 0d;
	double dHoursWork = 0d;
	String strHrsWork = null;
	int iTempHr = 0;
	int iTempMin = 0;
	
	Calendar calendar = Calendar.getInstance();
	
	String strMonths = WI.fillTextValue("strMonth");
	String strYear = WI.fillTextValue("sy_");
	if(strMonths.length() == 0)
		strMonths = Integer.toString(calendar.get(Calendar.MONTH) + 1);
	if(strYear.length() == 0)
		strYear = Integer.toString(calendar.get(Calendar.YEAR));
	
	String strSemester = null;
	String strSYFrom = null;
	String strSYTo = null;
	
	String strLateUT = null;
	String strHoliday = null;
	String strEmployeeIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
	
	String strLateSetting = "";
	String strSQLQuery = null;
	int iAllowedLateAm = 0;
	int iAllowedLatePm = 0;
	
	String strDayOfWeek = null;

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
	
  if ((!strMonths.equals("0") && strMonths.length() > 0) || bolMyHome){
		if(WI.fillTextValue("sal_period").length() > 0){
			vSalaryPeriod = RE.getEmployeeCutOffRange(dbOP, request, strEmployeeIndex);
			if(vSalaryPeriod != null && vSalaryPeriod.size() > 0){
				strDateFr = (String)vSalaryPeriod.elementAt(0);
				strDateTo = (String)vSalaryPeriod.elementAt(1); 
			}
		} else {
			try{			
				if (strYear.length()> 0){
					if (Integer.parseInt(strYear) >= 2005)
						calendar.set(Calendar.YEAR, Integer.parseInt(strYear));
				else
					strErrMsg = " Invalid year entry";
	
				}else{
					strYear = Integer.toString(calendar.get(Calendar.YEAR));
				}
			}
			catch (NumberFormatException nfe){
			strErrMsg = " Invalid year entry";
			}
	
			calendar.set(Calendar.DAY_OF_MONTH,1);
	
			 if(!strMonths.equals("0") && strMonths.length() > 0){
					calendar.set(Calendar.MONTH,Integer.parseInt(strMonths)-1);
			 }else{
					strMonths = Integer.toString(calendar.get(Calendar.MONTH) + 1);
			 }
	
	
	
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
	
			if (vEmpDetails != null && vEmpDetails.size() > 1){
				vFacultyLoad = FM.viewFacultyLoadSummary(dbOP,(String)vEmpDetails.elementAt(0),
							strSYFrom,strSYTo,strSemester, "",false,true);//get additional data.
			}
		}
  }	else{
		strDateFr = WI.fillTextValue("date_from");
		strDateTo = WI.fillTextValue("date_to");
	}


	if (strDateFr != null && strDateFr.length() > 0 && vEmpDetails != null){
		vHoursWork = RE.computeWorkingHour(dbOP, WI.fillTextValue("emp_id"),
											strDateFr, strDateTo, strMonths,strYear);
//	 System.out.println("strPrevDate " + strPrevDate);
//	 System.out.println("(String)vHoursWork.elementAt(1) " + (String)vHoursWork.elementAt(1));
	 if (vHoursWork != null && vHoursWork.size()  > 0){
	 		for(int i = 0; i < vHoursWork.size(); i+=3)
				dTotalHours += ((Double)vHoursWork.elementAt(i+2)).doubleValue();
 	  }
	}

/**
System.out.println("vHoursWork : "+vHoursWork);
System.out.println("strDateFr : "+strDateFr);
System.out.println("strDateTo : "+strDateTo);
System.out.println("strMonths : "+strMonths);
System.out.println("strYear : "+strYear);
**/
%>
<form method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="49%"><label for="main_label">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" id="main_label">
  
  <tr>
    <td>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
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
      <%
 			if (vEmpDetails != null && vEmpDetails.size() > 0){ %>
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
      <%	strTemp = (String)vEmpDetails.elementAt(11);
	if ( strTemp != null){
		strTemp = dbOP.mapOneToOther("COLLEGE","C_INDEX", strTemp,"C_CODE"," and is_del = 0");
		if ((String)vEmpDetails.elementAt(12) != null) {
			strTemp += " :: " + dbOP.mapOneToOther("DEPARTMENT","D_INDEX", (String)vEmpDetails.elementAt(12),"D_CODE"," and is_del = 0");
		}
	}else{
		strTemp = dbOP.mapOneToOther("DEPARTMENT","D_INDEX", (String)vEmpDetails.elementAt(12),"D_CODE"," and is_del = 0");
	}

%>
			<%
				strTemp = WI.fillTextValue("sal_period");
				if(strTemp.length() > 0)
					strTemp = "For the period " + strDateFr + " to " + strDateTo;
				else
					strTemp = " For the month of " + WI.fillTextValue("month_label") + " " + WI.fillTextValue("sy_");	
			%>
      <td width="64%" height="19"  class="thinborder"><strong><%=strTemp%></strong></td>
    </tr>
  </table>
   <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    
    <%

	if (WI.fillTextValue("my_home").equals("1"))
		strTemp = (String)request.getSession(false).getAttribute("userId");
	else
		strTemp = WI.fillTextValue("emp_id");


	vRetEDTR = RE.getDTRDetails(dbOP,strTemp,true);

	if (vRetEDTR!=null && vRetEDTR.size() > 0) {

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
    <% 	if (vRetEDTR.size() == 1){//non DTR employees %>
    <tr>
      <td height="19" colspan="10" class="thinborder"> <div align="center"><strong><%=vRetEDTR.elementAt(0)%></strong></div></td>
    </tr>
    <%}else{
//	strTemp3 = "";

	String strPrevDate = "";//this is added to avoid displaying date in 2nd row.
	boolean bolDateRepeated = false;
	String strDateEntry  = "";	
	
	String strLateEntry = null;	
	String strUTEntry = null;	
	String strAmTimeIn = null;
	String strAmTimeOut = null;

	String strLatePMEntry = null;
	String strUTPMEntry = null;
	String strPmTimeIn = null;
	String strPmTimeOut = null;	
	boolean bolSkipAm = false;
	boolean bolSkipPm = false;		

//as requestd, i have to show all the days worked and non worked.
	Vector vDayInterval = RE.getDayNDateDetail(strDateFr,strDateTo);	
	Vector vAWOLRecords = RE.getAWOLEmployee(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo, strSchCode);
	Vector vAWOLRecordsFormatted = null;
	Vector vAwolType = null;
	//if(strSchCode.startsWith("DEPED")){			
//			if(vAWOLRecords != null && vAWOLRecords.size() > 0){
//				vAwolType = RE.getAWOLEmployeeWithSet(dbOP,strEmployeeIndex,vAWOLRecords);
//				vAWOLRecordsFormatted = new Vector();
//				
//				for(int k = 0,l = 0; k < vAWOLRecords.size(); k+=2,l++){
//					strTemp = ConversionTable.convertMMDDYYYY((Date)vAWOLRecords.elementAt(k));
//					vAWOLRecordsFormatted.addElement(strTemp);
//					vAWOLRecordsFormatted.addElement(vAWOLRecords.elementAt(k+1));
//				}	
//			}	
//	}//end of if deped
									
									
									

	Vector vLateUnderTime = RE.getMonthlyLateUTimeDetail(dbOP, request);
	Vector vEmpLeave = RE.getEmployeeLeave(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo, strSchCode); 	
	
	Vector vRetHolidays = RE.getHolidaysOfMonth(dbOP,request, strEmployeeIndex);

	Vector vRetOBOT = RE.getEmpOBOT(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo);

	Vector vEmpLogout = RE.getEmpLogout(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo);

	Vector vEmpOvertime = null;
	if(strSchCode.startsWith("DEPED")){	
		vEmpOvertime=  RE.getOTHours(dbOP, WI.fillTextValue("emp_id"),
									 strDateFr, strDateTo, null, null, (String)vEmpDetails.elementAt(0));
	}else{
		vEmpOvertime = RE.getEmpOverTime(dbOP, (String)vEmpDetails.elementAt(0),
									 strDateFr, strDateTo);
	}

	for(int iIndex=0;iIndex<vRetEDTR.size();iIndex +=8){		
		bolHasOTLabel = false;
		strTemp =(String)vRetEDTR.elementAt(iIndex+4);

		bolSkipAm = false;
		bolSkipPm = false;
		
 		strAmTimeIn = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 2)).longValue(),2);
		//System.out.println("strAmTimeIn " + strAmTimeIn);
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

		if(strPrevDate.equals( (String)vRetEDTR.elementAt(iIndex+4))) {
			bolDateRepeated = true;
		}
		else {
			bolDateRepeated = false;
			strPrevDate = (String)vRetEDTR.elementAt(iIndex+4);
		}


	//System.out.println("569 day   : " + (String)vDayInterval.elementAt(0));
	//System.out.println("bolDateRepeated: " + bolDateRepeated);
	
	
//I ahve to display here for the days employee did not work.
if(!bolDateRepeated && vDayInterval != null && vDayInterval.size() > 0) {
	strTemp3 = ""; iFirstDayBlank = 0;
	while(strPrevDate.compareTo((String)vDayInterval.elementAt(0)) != 0) {
	//if(strPrevDate.compareTo((String)vDayInterval.elementAt(0)) != 0) {
		//System.out.println("\nwhile day  : " + (String)vDayInterval.elementAt(0));
		//System.out.println("leave date : " + (String)vEmpLeave.elementAt(0));
		if (iFirstDayBlank  == 0)
			strTemp3 = "thinborderTopBottomLeft";
		else
			strTemp3 = "thinborder";
		iFirstDayBlank++;

		if (vRetHolidays != null && vRetHolidays.size() > 0 &&
			((String)vRetHolidays.elementAt(1)).equals((String)vDayInterval.elementAt(0))
			&& !bolDateRepeated){

			strHoliday = (String) vRetHolidays.remove(0);
			vRetHolidays.removeElementAt(0);
		}else
			strHoliday = "";
		
		//System.out.println("before leave(day): " + (String)vDayInterval.elementAt(0));
		//System.out.println("leave date       : " + (String)vEmpLeave.elementAt(0));
		//System.out.println("leave size       : " + vEmpLeave.size());		
		//System.out.println("\nbefore vEmpLeave " + vEmpLeave);
		if (vEmpLeave != null && vEmpLeave.size() > 0 &&
			((String)vEmpLeave.elementAt(0)).equals((String)vDayInterval.elementAt(0)) &&
			!bolDateRepeated){				
			vEmpLeave.removeElementAt(0);
			strHoliday += " leave (" + (String)vEmpLeave.remove(0) +")";
                       vEmpLeave.remove(0);//type of leave, with/without pay.	
		}	
		//System.out.println("after vEmpLeave " + vEmpLeave);
		
		if (vRetOBOT != null && vRetOBOT.size() > 0 &&
			((String)vRetOBOT.elementAt(0)).equals((String)vDayInterval.elementAt(0)) &&
			!bolDateRepeated){

			vRetOBOT.removeElementAt(0);
			strHoliday += " OB/OT";
		}

		if (vAWOLRecords != null && vAWOLRecords.size() > 0 &&
		(ConversionTable.convertMMDDYYYY((Date)vAWOLRecords.elementAt(0)).equals((String)vDayInterval.elementAt(0)))
			&& !bolDateRepeated){

			vAWOLRecords.removeElementAt(0);
			strHoliday += strAWOL + (String)vAWOLRecords.remove(0) +")";
		}

		if (vEmpLogout != null && vEmpLogout.size() > 0 &&
		((String)vEmpLogout.elementAt(0)).equals((String)vDayInterval.elementAt(0))
			&& !bolDateRepeated){

			vEmpLogout.removeElementAt(0);
			strHoliday += strOBLabel + (String)vEmpLogout.remove(0) +")";
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
      <td height="18" class="thinborder">
	  	<%=strDateEntry.substring(strDateEntry.indexOf("/") + 1,strDateEntry.lastIndexOf("/"))
				+ "&nbsp;" + ((String)vDayInterval.remove(0)).substring(0,3)%></td>		
     <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
    </tr>
<%}else{%>
    <tr>
      <td height="18" class="thinborder">
	  	<%=strDateEntry.substring(strDateEntry.indexOf("/")+1,strDateEntry.lastIndexOf("/")) +
				"&nbsp;" + ((String)vDayInterval.remove(0)).substring(0,3)%></td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder"><font size="1"><%=WI.getStrValue(strHoliday,"&nbsp;")%></font></td>
    </tr>


    <% } // if else show holiday..
	 }//end of  while looop
  
  if(vDayInterval.size() > 0)  {
 	vDayInterval.removeElementAt(0);vDayInterval.removeElementAt(0);
  }

}//end of if condition to print holidays.%>
    <tr>

      <td height="18" nowrap class="thinborder"> <font size="1">
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
      <td nowrap class="thinborder"><font size="1"><%=strAmTimeIn%></font></td>
	  	 <%	 
	// if(strSchCode.startsWith("DEPED") && vAWOLRecordsFormatted != null && vAWOLRecordsFormatted.size() > 0 ){
//		 //get here AWOL.. 
//		  iIndexOf2 = vAWOLRecordsFormatted.indexOf(vRetEDTR.elementAt(iIndex+4));		  
//			if(iIndexOf2 > -1) {						
//				dTemp = Double.parseDouble((String)vAWOLRecordsFormatted.remove(iIndexOf2 + 1)); //dTemp has the hours			
//				vAWOLRecordsFormatted.remove(iIndexOf2);				
//				iAwolType = Integer.parseInt((String)vAwolType.elementAt(iIndexOf2/2));
//				if(iAwolType == 0){ //am awol
//					if(strLateEntry.equals("&nbsp;"))
//						strLateEntry = "0";											
//					strLateEntry = CommonUtil.formatFloat(( (dTemp*60) + Double.parseDouble(WI.getStrValue(strLateEntry,"0"))),false);					
//					if(strLateEntry.equals("0"))
//						strLateEntry = "&nbsp;";
//				}else if(iAwolType == 1){//pm awol					
//					if(strUTEntry.equals("&nbsp;"))
//						strUTEntry = "0";														
//					strUTEntry = CommonUtil.formatFloat(( (dTemp*60) + Double.parseDouble(WI.getStrValue(strUTEntry,"0"))),false);					
//					if(strUTEntry.equals("0"))
//						strUTEntry = "&nbsp;";					
//						
//				}			
//				vAwolType.remove(iIndexOf2/2);
//				//strAbsentAWOL = CommonUtil.formatFloat(dTemp, false);			
//			}
//	 }//end of if deped
	 %>
	  
	  
      <td align="right" nowrap class="thinborder"><font size="1"><%=strLateEntry%>&nbsp;</font></td>
      <td nowrap class="thinborder"><font size="1"><%=strAmTimeOut%></font></td>
       <td align="right" nowrap class="thinborder"><font size="1"><%=strUTEntry%>&nbsp;</font></td>
      <td nowrap class="thinborder"><font size="1"><%=WI.getStrValue(strPmTimeIn,"&nbsp;")%></font></td> 
      <td align="right" nowrap class="thinborder"><font size="1"><%=strLatePMEntry%>&nbsp;</font></td>
      <td nowrap class="thinborder"><font size="1"><%=WI.getStrValue(strPmTimeOut,"&nbsp;")%></font></td> 
      <td align="right" nowrap class="thinborder"><font size="1"><%=strUTPMEntry%>&nbsp;</font></td>

 <% if (vRetHolidays != null && vRetHolidays.size() > 0 &&
		((String)vRetHolidays.elementAt(1)).equals(strPrevDate) && !bolDateRepeated){
		strHoliday = "holiday";
		//strHoliday = (String)vRetHolidays.elementAt(0);		
		vRetHolidays.removeElementAt(0);
		vRetHolidays.removeElementAt(0);
	}else
		strHoliday = "";
 	if (vEmpLeave != null && vEmpLeave.size() > 0){
		if(((String)vEmpLeave.elementAt(0)).equals(strPrevDate) && !bolDateRepeated){
			vEmpLeave.removeElementAt(0);
			strHoliday += " leave ";
			strHoliday += " leave (" + (String)vEmpLeave.remove(0) +")";			
			vEmpLeave.remove(0);//type of leave, with/without leave.
		} 
	}
 	if (vRetOBOT != null && vRetOBOT.size() > 0 &&
		((String)vRetOBOT.elementAt(0)).equals(strPrevDate) &&
		!bolDateRepeated){

		vRetOBOT.removeElementAt(0);
		strHoliday += " OB/OT";
	}

	if (vAWOLRecords != null && vAWOLRecords.size() > 0 &&
		ConversionTable.convertMMDDYYYY((Date)vAWOLRecords.elementAt(0)).equals(strPrevDate)
		&& !bolDateRepeated){

		vAWOLRecords.removeElementAt(0);
		strTemp = (String)vAWOLRecords.remove(0);		
		if(!(strSchCode.startsWith("DEPED") && Double.parseDouble(strTemp) == 4 && (iAwolType == 0 || iAwolType == 1) ))
			strHoliday += strAWOL + strTemp +")";
	}

	if (vEmpLogout != null && vEmpLogout.size() > 0 &&
		((String)vEmpLogout.elementAt(0)).equals(strPrevDate)
		&& !bolDateRepeated){

		vEmpLogout.removeElementAt(0);
		vEmpLogout.remove(0);// remove ol time
		strHoliday += "OB";
		//strHoliday += "OL(" + (String)vEmpLogout.remove(0) +")";
	}

	if (vEmpLogout != null && vEmpLogout.size() > 0 &&
		((String)vEmpLogout.elementAt(0)).equals(strPrevDate)
		&& !bolDateRepeated){

		vEmpLogout.removeElementAt(0);
		vEmpLogout.remove(0);// remove ol time
		strHoliday += "OB";
		//strHoliday += "OL(" + (String)vEmpLogout.remove(0) +")";
	}

	if (vEmpOvertime != null && vEmpOvertime.size() > 0	
		&& !bolDateRepeated){
		if(strSchCode.startsWith("DEPED")){				
			dHoursWork = 0d;
			iIndexOf = vEmpOvertime.indexOf(strPrevDate);
			while (iIndexOf != -1) {
				vEmpOvertime.removeElementAt(iIndexOf-1);
				vEmpOvertime.removeElementAt(iIndexOf-1);
				dTemp = ((Double)vEmpOvertime.remove(iIndexOf-1)).doubleValue();				
				dHoursWork += dTemp;
				strHrsWork = "OT(" +CommonUtil.formatFloat(dHoursWork,true) +")";
				iIndexOf = vEmpOvertime.indexOf(strPrevDate);
			}
			
			if(WI.fillTextValue("show_actual").length() > 0){
				iTempHr = (int)dHoursWork;
				dTemp = dHoursWork - iTempHr;
				iTempMin = (int)((dTemp * 60) + 0.2);
				strHrsWork = iTempHr + ":" + CommonUtil.formatMinute(Integer.toString(iTempMin));
			}			
			strHoliday +=(dHoursWork > 0d)?strHrsWork:"";
		}else{	
			iIndexOf = vEmpOvertime.indexOf(strPrevDate);
			while(iIndexOf != -1){
				vEmpOvertime.remove(iIndexOf); // date
				vEmpOvertime.remove(iIndexOf);// remove ot time
					if(!bolHasOTLabel)
						strHoliday += " OT";
					bolHasOTLabel = true;			
				iIndexOf = vEmpOvertime.indexOf(strPrevDate);
			}
		}
	}

%>
      <td class="thinborder"><font size="1"><%=WI.getStrValue(strHoliday,"&nbsp;")%></font></td>
      <%
		if((strPmTimeIn != null && strPmTimeIn.length() > 0) && !bolSkipAm && !bolSkipPm) 
			iIndex += 8;
		%>
    </tr>
    <%
	  } // end for loop

	  //I have to now print if there are any days having zero working hours.

	while(vDayInterval != null && vDayInterval.size() > 0) {

		if (vRetHolidays != null && vRetHolidays.size() > 0 &&
			((String)vRetHolidays.elementAt(1)).equals((String)vDayInterval.elementAt(0))
			&& !bolDateRepeated){

			strHoliday = "holiday";
			vRetHolidays.removeElementAt(0);vRetHolidays.removeElementAt(0);
		}else
			strHoliday = "";

		if (vEmpLeave != null && vEmpLeave.size() > 0 &&
			((String)vEmpLeave.elementAt(0)).equals((String)vDayInterval.elementAt(0)) &&
			!bolDateRepeated){

			vEmpLeave.removeElementAt(0);
			strHoliday += " leave (" + (String)vEmpLeave.remove(0) +")";
                        vEmpLeave.remove(0);//type of leave, with/without leave.
		}

		if (vRetOBOT != null && vRetOBOT.size() > 0 &&
			((String)vRetOBOT.elementAt(0)).equals((String)vDayInterval.elementAt(0)) &&
			!bolDateRepeated){

			vRetOBOT.removeElementAt(0);
			strHoliday += " OB/OT";
		}

		if (vAWOLRecords != null && vAWOLRecords.size() > 0 &&
		(ConversionTable.convertMMDDYYYY((Date)vAWOLRecords.elementAt(0)).equals((String)vDayInterval.elementAt(0)))
			&& !bolDateRepeated){

			vAWOLRecords.removeElementAt(0);
			strHoliday += strAWOL + (String)vAWOLRecords.remove(0) +")";
		}

		if (vEmpLogout != null && vEmpLogout.size() > 0 &&
		((String)vEmpLogout.elementAt(0)).equals((String)vDayInterval.elementAt(0))
			&& !bolDateRepeated){

			vEmpLogout.removeElementAt(0);
			strHoliday += "OL (" + (String)vEmpLogout.remove(0) +")";


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
      <td height="18" class="thinborder">
	  	<%=strDateEntry.substring(strDateEntry.indexOf("/")+1,strDateEntry.lastIndexOf("/"))+"&nbsp;"+((String)vDayInterval.remove(0)).substring(0,3)%></td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder"><%=WI.getStrValue(strHoliday,"&nbsp;")%></td>
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
      <td height="20" colspan="10" class="thinborder">&nbsp;&nbsp; <strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
    <%} // end if (vRetEDTR.size() == 1)%>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="20%" align="right" class="thinborderTOPLEFT">&nbsp;TOTAL&nbsp; </td>
    <td width="32%" align="center" class="thinborderTOPBOTTOM">&nbsp;<%=CommonUtil.formatFloat(dTotalHours, true)%> hours</td>
    <td width="48%" class="thinborderTOPRIGHT">&nbsp;</td>
  </tr>
</table>

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
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="15" bgcolor="#FFFFFF">&nbsp;&nbsp;&nbsp;
        <div align="justify"><em>I Certify on my honor that the above is a true and correct report of the hours of work performed, record of which was made daily at time of arrival at and departure from office. </em></div></td>
    </tr>
    <tr>
      <td height="36" bgcolor="#FFFFFF">&nbsp;</td>
      </tr>
    <tr>
      <td height="4" align="center" valign="bottom" bgcolor="#FFFFFF" class="thinborderBOTTOM"><font size="2"><strong><%=WI.formatName((String)vEmpDetails.elementAt(1),
	  (String)vEmpDetails.elementAt(2), (String)vEmpDetails.elementAt(3), 7)%></strong></font></td>
    </tr>
    <tr>
      <td height="18" bgcolor="#FFFFFF">Verified as to the prescribed office Hrs. </td>
      </tr>
    <tr>
      <td height="29" align="center" valign="bottom" bgcolor="#FFFFFF" class="thinborderBOTTOM"><strong><%=WI.fillTextValue("in_charge")%></strong></td>
      </tr>
    <tr>
      <td height="15" align="center" bgcolor="#FFFFFF">In-Charge</td>
      </tr>
  </table>		
	</td>
  </tr>
</table>

    		
		</label></td>
    <td width="2%">&nbsp;</td>
    <td width="49%" onClick="copyLabel();"><label id="copy_label"></label></td>
  </tr>
</table>

  <%}//end  to display employee information.%>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
<input type="hidden" name="print_page" value="0">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
<input type="hidden" name="view_only" value="<%=WI.fillTextValue("view_only")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
