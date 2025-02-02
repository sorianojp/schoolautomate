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

	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strDate = null;
	int iIndexOf = 0;
	
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
	int iHours = 0;
	int iMinutes = 0;
	double dTotalHours = 0;	
	double dGrandTotalHours = 0d;

	Vector vFacultyLoad = null;
	Vector vSalaryPeriod = null;
	String strDateFr = null;
	String strDateTo = null;
	
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
				dGrandTotalHours += ((Double)vHoursWork.elementAt(i+2)).doubleValue();
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
			  <td align="center">CIVIL SERVICE FORM # 48 </td>
			  </tr>
			<tr>
				<td align="center">DAILY TIME RECORD</td>
			</tr>
			<tr>
			  <td align="center">&nbsp;</td>
			  </tr>
		</table>

      <%if (vEmpDetails != null && vEmpDetails.size() > 0){ %>
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
      <td width="16%" height="13" align="center" class="thinborder">&nbsp;&nbsp;&nbsp;Date</td>
      <td width="14%" align="center" class="thinborder">Arrival</td>
      <td width="14%" align="center" class="thinborder">Departure</td>
      <td width="14%" align="center" class="thinborder">Arrival</td>
      <td width="14%" align="center" class="thinborder">Departure</td>
      <td width="14%" align="center" class="thinborder">Hours</td>
      <td width="14%" align="center" class="thinborder">Minutes</td>
    </tr>
    <% 	if (vRetEDTR.size() == 1){//non DTR employees %>
    <tr>
      <td height="19" colspan="7" class="thinborder"> <div align="center"><strong><%=vRetEDTR.elementAt(0)%></strong></div></td>
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

	Vector vLateUnderTime = RE.getMonthlyLateUTimeDetail(dbOP, request);
	Vector vEmpLeave = RE.getEmployeeLeave(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo, strSchCode);
 
	Vector vRetHolidays = RE.getHolidaysOfMonth(dbOP,request, strEmployeeIndex);

	Vector vRetOBOT = RE.getEmpOBOT(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo);

	Vector vEmpLogout = RE.getEmpLogout(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo);

	Vector vEmpOvertime = RE.getEmpOverTime(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo);

	for(int iIndex=0;iIndex<vRetEDTR.size();iIndex +=8){
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

	strDateEntry = (String)vDayInterval.remove(0);
	%>
    <tr>
			<%
			vDayInterval.remove(0); // remove weekday
			%>
      <td height="18" class="thinborder">
	  	<%=strDateEntry.substring(strDateEntry.indexOf("/")+1,strDateEntry.lastIndexOf("/"))%></td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>


    <%
	 }//end of while looop
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
			<%//=strDate%>
      <%}else{%>  
				&nbsp;  
			<%}%>
      </font></td>

      <td nowrap class="thinborder">
	    <font size="1">
	    <%strTemp3 = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 2)).longValue(),2);
			strTemp3 = strTemp3.substring(0, strTemp3.length() -1);
			strTemp3 = ConversionTable.replaceString(strTemp3," ","");
			%>
			<%=strTemp3%></font></td>

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
      <td nowrap class="thinborder">
  			<font size="1">
	  <%  strTemp3=WI.getStrValue(WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 3)).longValue(),2));
	  //if (!strTemp3.equals("&nbsp;")) {
		  strTemp3=WI.getStrValue(strTemp3,"-inc-");
		//}else{
		 // strTemp3=WI.getStrValue(strTemp3,"&nbsp;");
		//}		
				if (strTemp3.length() == 8)
					strTemp3 = strTemp3.substring(0, 7);
				strTemp3 = ConversionTable.replaceString(strTemp3," ","");
				%><%=strTemp3%></font></td>
	  <%
	  	if (!WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 7), "0").equals("0")){
			iTotalUTAM += Integer.parseInt((String)vRetEDTR.elementAt(iIndex + 7));
			iFreqUTAM++;
		}
	  %>
      <td nowrap class="thinborder"><font size="1">
		<% strTemp3 = WI.getStrValue(strTemp,"&nbsp;");
		 if (strTemp3.length() == 8)
			strTemp3  = strTemp3.substring(0,7);
			strTemp3 = ConversionTable.replaceString(strTemp3," ","");
		%>
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
      <td nowrap class="thinborder"><font size="1">
    <%
	  if (!strTemp3.equals("&nbsp;")) {
		  strTemp3=WI.getStrValue(strTemp2,"-inc-");
		}else{
		  strTemp3=WI.getStrValue(strTemp2,"&nbsp;");
		}
	  if (strTemp3.length() == 8)
			strTemp3 = strTemp3.substring(0,7);
		strTemp3 = ConversionTable.replaceString(strTemp3," ","");
	  %><%=strTemp3%>
	  </font></td>
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
      <td align="right" class="thinborder"><font size="1"><%=strTemp%>&nbsp;</font></td>
			<%
				strTemp = Integer.toString(iMinutes);
				if(iHours == 0 && iMinutes == 0)
					strTemp = "&nbsp;";
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <%
		if(strTemp2 != null) iIndex += 8;

	%>
    </tr>
    <%
	  } // end for loop

	  //I have to now print if there are any days having zero working hours.

	while(vDayInterval != null && vDayInterval.size() > 0) {

		strDateEntry = (String)vDayInterval.remove(0);
		vDayInterval.remove(0);// remove weekday
  %>
    <tr>
      <td height="18" class="thinborder">
	  	<%=strDateEntry.substring(strDateEntry.indexOf("/")+1,strDateEntry.lastIndexOf("/"))%></td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td height="18" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
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
      <td height="20" colspan="7" class="thinborder">&nbsp;&nbsp; <strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong> </td>
    </tr>
    <%} // end if (vRetEDTR.size() == 1)%>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="74%" align="right" class="thinborderTOP">&nbsp;TOTAL&nbsp; </td>
    <td width="26%" align="center" class="thinborderTOPBOTTOM">&nbsp;<%=CommonUtil.formatFloat(dGrandTotalHours, true)%> hours</td>
    </tr>
</table>
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
  </table>		</td>
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
