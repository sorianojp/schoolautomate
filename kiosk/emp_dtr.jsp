<%@ page language="java" import="utility.*, eDTR.ReportEDTR,eDTR.eDTRUtil, eDTR.WorkingHour,
																java.util.Vector, java.util.Calendar,java.util.Date, 
																eDTR.AllowedLateTimeIN"%>
<%
	WebInterface WI = new WebInterface(request);
	
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(9);

	boolean bolMyHome = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Individual Employee Attendance</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

  TD.thinborderResize {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"), "9")%>px;
  }
</style>
</head>
<script language="JavaScript" src="../Ajax/ajax.js"></script>
<script language="JavaScript" src="../jscript/common.js"></script>
<script language="JavaScript" src="../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--

function OpenSearch() {
	var pgLoc = "../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPg(){
	if(document.form_.certified.value.length == 0){
		alert("Enter certified by");
		document.form_.certified.focus();		
		return
	}

	if(document.form_.verified_attested.value.length == 0){
		alert("Enter verified by");
		document.form_.verified_attested.focus();		
		return
	}

	if(document.form_.verified.value.length == 0){
		alert("Enter noted by");
		document.form_.verified.focus();
		return
	}
	
	document.form_.print_page.value="1";
	document.form_.submit();
}

function ShowRecords(){
	document.form_.print_page.value="";
}
 
-->
</script>

<body bgcolor="#D2AE72" class="bgDynamic" onLoad="focusID();">
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode =  "";

	DBOperation dbOP = null;	
	String strErrMsg = null;
	
	String strAWOL = " AWOL (";
	if(strSchCode.startsWith("CLDH")){
		strAWOL = " ABSENT (";
	}

	String strOBLabel = "OL(";
	if(strSchCode.startsWith("PIT") || strSchCode.startsWith("TSUNEISHI")){
		strOBLabel = " OB(";
	}
 
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strLeave = null;
	boolean bolHasWeekly = false;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS-Individual Attendance","emp_dtr.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasWeekly = (readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0")).equals("1");
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
														"emp_dtr.jsp");
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
		iAccessLevel = 1;
		request.setAttribute("emp_id",strTemp);
}

if (strTemp == null)
	strTemp = "";
//
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
	String strHoliday = null;
	String strEmployeeIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
	if(bolMyHome)
		strEmployeeIndex = (String)request.getSession(false).getAttribute("userIndex");
	
	String strLateSetting = "";
	String strSQLQuery = null;
	int iAllowedLateAm = 0;
	int iAllowedLatePm = 0;
	
	String strDayOfWeek = null;
	String strTime = null;

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
	
			if (vEmpDetails != null && vEmpDetails.size() > 1
			&& WI.fillTextValue("hide_load").length() == 0){
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

	}

/**
System.out.println("vHoursWork : "+vHoursWork);
System.out.println("strDateFr : "+strDateFr);
System.out.println("strDateTo : "+strDateTo);
System.out.println("strMonths : "+strMonths);
System.out.println("strYear : "+strYear);
**/
%>
<form action="./emp_dtr.jsp" method="post" name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="20" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr> 
    <tr>
      <td width="2%" height="24">&nbsp;</td>
      <td width="17%">Month</td>
      <td colspan="2">
	  <select name="strMonth">
	  <%
	  int iDefMonth = Integer.parseInt(strMonths);
	  	for (int i = 1; i <= 12; ++i) {
	  		if (iDefMonth == i)
				strTemp = " selected";
			else
				strTemp = "";
	   %>
	  	<option value="<%=i%>" <%=strTemp%>><%=astrMonth[i]%></option>
	  <%} // end for lop%>
	  </select> 
		<select name="sy_">
			<%=dbOP.loadComboYear(WI.fillTextValue("sy_"),2,1)%> 
		</select>		
		<input name="image" type="image" src="../images/form_proceed.gif"
		 width="81" height="21" onClick="ShowRecords()"></td>
    </tr>
    
    <tr>
      <td height="24">&nbsp;</td>
      <td>Salary Cut-Off</td>
			<% 
				strTemp = WI.fillTextValue("sal_period"); 
			%>
      <td colspan="2">
			<select name="sal_period">
				<option value="" selected>Ignore Cut-off</option>
				<%if(strTemp.equals("1")) {%>
        <option value="1" selected>1st</option>
        <%} else {%>
        <option value="1">1st</option>
        <%}%>
				<%if(strTemp.equals("2")) {%>
        <option value="2" selected>2nd</option>
        <%}else{%>
        <option value="2">2nd</option>
        <%}%>        
				<%if(bolHasWeekly){%>
        <%if(strTemp.equals("3")) {%>
        <option value="3" selected>3rd</option>
        <%}else{%>
        <option value="3">3rd</option>
				<%}%>
        <%if(strTemp.equals("4")) {%>
        <option value="4" selected>4th</option>
        <%}else{%>
        <option value="4">4th</option>
				<%}%>
        <%if(strTemp.equals("6")) {%>
        <option value="6" selected>5th</option>
        <%}else{%>
        <option value="6">5th</option>
        <%}%>
				<%}%>
        <%if(strTemp.equals("5")) {%>
        <option value="5" selected>Monthly Salary Cut-off</option>
        <%}else{%>
        <option value="5">Monthly Salary Cut-off</option>
        <%}%>
      </select></td>
    </tr>
		
		<tr>
		  <td height="24">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td><%  		
				if (WI.fillTextValue("hide_schedule").equals("1"))
					strTemp = "checked";
				else 
					strTemp = "";
		  %>
        <input name="hide_schedule" type="checkbox" value="1" <%=strTemp%> id="hide_schedule_">
			<label for="hide_schedule_">Hide Working Schedule</label></td>
			<%
				strTemp = WI.fillTextValue("font_size");
				if(strTemp.length() == 0)
					strTemp = "9";
 			%>
	    <td><font size="2">Font size of details:
          <select name="font_size">
            <%for(int i = 8; i < 13; i++){%>
            <%if(strTemp.equals(Integer.toString(i))){%>
            <option value="<%=i%>" selected><%=i%> px</option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> px</option>
            <%}
						}%>
          </select>
      </font></td>
		</tr>
		<tr>
		  <td height="24">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td colspan="2"><%  		
				if (WI.fillTextValue("hide_summary").equals("1"))
					strTemp = "checked";
				else 
					strTemp = "";
		  %>
        <input name="hide_summary" type="checkbox" value="1" <%=strTemp%> id="hide_summary_">
				<label for="hide_summary_">Hide summary</label></td>
	  </tr>
		<%if(bolIsSchool){%>
		<tr>
		  <td height="24">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td width="54%"><%  		
				if (WI.fillTextValue("hide_load").equals("1"))
					strTemp = "checked";
				else 
					strTemp = "";
		  %>
        <input name="hide_load" type="checkbox" value="1" <%=strTemp%> id="hide_load_">
			<label for="hide_load_">
			Hide Teaching load			</label>			</td>
	    <td width="27%">&nbsp;</td>
    </tr>		
		<%}%>
  </table>
<% if (vEmpDetails != null && vEmpDetails.size() > 0){ %>

<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="19"><hr width="99%" size="1" noshade color="#0000FF"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    
    <%
		strTemp = (String)request.getSession(false).getAttribute("userId");

	vRetEDTR = RE.getDTRDetails(dbOP, strTemp, true);
	if (vRetEDTR != null && vRetEDTR.size() > 0) {

//as requestd, i have to show all the days worked and non worked.
Vector vDayInterval = RE.getDayNDateDetail(strDateFr, strDateTo);
 
// holidays..
Vector vRetHolidays = RE.getHolidaysOfMonth(dbOP,request, strEmployeeIndex);
//System.out.println("vRetHolidays : "  + vRetHolidays);

// leave..

Vector vEmpLeave = RE.getEmployeeLeaveAndName(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo, strSchCode);
//Vector vEmpLeave = RE.getEmployeeLeave(dbOP, (String)vEmpDetails.elementAt(0),
//									strDateFr, strDateTo, strSchCode);

//System.out.println("vEmpLeave : "  + vEmpLeave);

// trainings / ob / otin
Vector vRetOBOT = RE.getEmpOBOT(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo);
//System.out.println("vRetOBOT : "  + vRetOBOT);

// awol records..
Vector vAWOLRecords = RE.getAWOLEmployee(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo, strSchCode);
//System.out.println("vAWOLRecords " + vAWOLRecords);

// late undertime records..
Vector vLateUnderTime = RE.getMonthlyLateUTimeDetail(dbOP, request);
//System.out.println("vLateUnderTime : "  + vLateUnderTime);

//Employee Logout..
Vector vEmpLogout = RE.getEmpLogout(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo);

Vector vEmpOvertime = RE.getEmpOverTime(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo);
//System.out.println("vEmpOvertime " + vEmpOvertime);
%>
    <tr >
      <td width="15%" height="18" class="thinborderResize">  		<strong>&nbsp;DATE</strong></td>
      <td width="9%" align="center" class="thinborderResize"><strong>IN</strong></td>
      <td width="6%" align="center" class="thinborderResize"><strong>L</strong></td>
      <td width="9%" align="center" class="thinborderResize"><strong>OUT</strong></td>
      <td width="5%" align="center" class="thinborderResize"><strong>U</strong></td>
      <td width="9%" align="center" class="thinborderResize"><strong>IN</strong></td>
      <td width="6%" align="center" class="thinborderResize"><strong>L</strong></td>
      <td width="9%" align="center" class="thinborderResize"><strong>OUT</strong></td>
      <td width="5%" align="center" class="thinborderResize"><strong>U</strong></td>
      <td width="6%" align="center" class="thinborderResize"><strong>TOT</strong></td>
      <td width="21%" align="center" class="thinborderResize"><strong>REMARKS</strong></td>
    </tr>
    <% 	if (vRetEDTR.size() == 1){//non DTR employees %>
    <tr>
      <td height="18" colspan="11" align="center" class="thinborderResize"><strong><%=vRetEDTR.elementAt(0)%></strong></td>
    </tr>
    <%}else{
	strTemp3 = "";

	String strPrevDate = "";//this is added to avoid displaying date in 2nd row.
	boolean bolDateRepeated = false;
	String strLatePMEntry = null;
	String strUTPMEntry = null;
	int iIndexOf = 0;

//	Vector vLateUnderTime = RE.getMonthlyLateUTimeDetail(dbOP, request);

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

		if(strPrevDate.equals((String)vRetEDTR.elementAt(iIndex+4))) {
			bolDateRepeated = true;
		}
		else {
			bolDateRepeated = false;
			strPrevDate = (String)vRetEDTR.elementAt(iIndex+4);
		}


//I have to display here for the days employee did not work.
//	System.out.println("vDayInterval " + vDayInterval);
	if(!bolDateRepeated && vDayInterval != null && vDayInterval.size() > 0) {
		
		while(vDayInterval.size() > 0 && !strPrevDate.equals((String)vDayInterval.elementAt(0))) {

			//System.out.println("(String)vRetHolidays.elementAt(1) " + (String)vRetHolidays.elementAt(1));
			//System.out.println("(String)vDayInterval.elementAt(0) " + (String)vDayInterval.elementAt(0));
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
				strLeave = WI.getStrValue((String)vEmpLeave.remove(0),"w/out pay") + "(" + strLeave +")";
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
				strHoliday += strOBLabel +WI.getStrValue((String)vEmpLogout.remove(0),"Whole day") +")";
			}

			if (vEmpOvertime != null && vEmpOvertime.size() > 0 &&
			((String)vEmpOvertime.elementAt(0)).equals((String)vDayInterval.elementAt(0))
				&& !bolDateRepeated){

				vEmpOvertime.removeElementAt(0); // date
				strHoliday += "OT (" + (String)vEmpOvertime.remove(0) +")";
			}

	//	strDateEntry = (String)vDayInterval.remove(0);

		if(strHoliday.length() > 0){%>
		<tr bgcolor="#E6F0ED">
		  <td height="18" class="thinborderResize"> &nbsp;<%=(String)vDayInterval.remove(0)+ "::" +
											((String)vDayInterval.remove(0)).substring(0,3)%></td>
		  <td height="18" colspan="10" align="center" class="thinborderResize"><strong><%=strHoliday%></strong></td>
		</tr>
		<%}else{%>
		<tr bgcolor="#E6F0ED">
		  <td height="18" class="thinborderResize"> &nbsp;<%=(String)vDayInterval.remove(0) + "::" +
											((String)vDayInterval.remove(0)).substring(0,3)%></td>
		  <td height="18" colspan="10" align="center" class="thinborderResize">&nbsp;</td>
	  </tr>

		<%
		  }
		}//end of while looop

  if(vDayInterval.size() > 0)  {
  	vDayInterval.removeElementAt(0);
		strDayOfWeek = ((String)vDayInterval.remove(0)).substring(0,3);
		//if(WI.fillTextValue("show_weekday").length() == 0)
		//	strDayOfWeek = "";
  }
}//end of if condition to print holidays.
 %>
    <tr>
      <td height="18" class="thinborderResize"><%if(!bolDateRepeated){%><%=(String)vRetEDTR.elementAt(iIndex+4)%>::<%=strDayOfWeek%>
				<%}else{%>
					&nbsp;
				<%}%></td>
			<%
				strTime = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 2)).longValue(),2);
				strTime = ConversionTable.replaceString(strTime, " ", "");
			%>	
			<td class="thinborderResize"><%=strTime%>	  </td>
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
      <td align="right" class="thinborderResize"><%=WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 6))%>&nbsp;</td>
			<%
				strTime = WI.getStrValue(WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 3)).longValue(),2),"&nbsp;");
				strTime = ConversionTable.replaceString(strTime, " ", "");
			%>	
      <td class="thinborderResize"> <%=strTime%>	  </td>
	  <%
	  	if (!WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 7), "0").equals("0")){
			iTotalUTAM += Integer.parseInt((String)vRetEDTR.elementAt(iIndex + 7));
			iFreqUTAM++;
		}
	  %>
      <td align="right" class="thinborderResize"><%=WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 7))%>&nbsp;</td>
			<%
				strTime = strTemp;
				strTime = ConversionTable.replaceString(strTime, " ", "");
			%>	
      <td class="thinborderResize">&nbsp;<%=WI.getStrValue(strTime,"&nbsp;")%></td>
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
      <td align="right" class="thinborderResize"><%=strLatePMEntry%>&nbsp;</td>
			<%
				strTime = strTemp2;
				strTime = ConversionTable.replaceString(strTime, " ", "");
			%>				
      <td class="thinborderResize">&nbsp;<%=WI.getStrValue(strTime,"&nbsp;")%></td>
	  <%
	  	if (!WI.getStrValue(strUTPMEntry, "0").equals("0")){
			iTotalUTPM += Integer.parseInt(strUTPMEntry);
			iFreqUTPM++;
		}
	  %>
      <td align="right" class="thinborderResize"><%=strUTPMEntry%>&nbsp;</td>

      <td class="thinborderResize">
	 <%	
//	 System.out.println("strPrevDate " + strPrevDate);
//	 System.out.println("(String)vHoursWork.elementAt(1) " + (String)vHoursWork.elementAt(1));
	 if (vHoursWork != null && vHoursWork.size()  > 0 &&
	 			strPrevDate.equals((String)vHoursWork.elementAt(1))){
			vHoursWork.removeElementAt(0);vHoursWork.removeElementAt(0); %>
				<%=CommonUtil.formatFloat(((Double)vHoursWork.remove(0)).doubleValue(),true)%>
	<%}else{%>&nbsp;<%}%></td>
      <% if (vRetHolidays != null && vRetHolidays.size() > 0 &&
		((String)vRetHolidays.elementAt(1)).equals(strPrevDate) && !bolDateRepeated){
		strHoliday = (String)vRetHolidays.elementAt(0);
		vRetHolidays.removeElementAt(0);vRetHolidays.removeElementAt(0);
	}else
		strHoliday = "";

	if (vEmpLeave != null && vEmpLeave.size() > 0 &&
		((String)vEmpLeave.elementAt(0)).equals(strPrevDate) &&
		!bolDateRepeated){
 				vEmpLeave.removeElementAt(0);// remove date
				strLeave = (String)vEmpLeave.remove(0); // remove leave hours
        vEmpLeave.remove(0);// remove leave status
				strLeave = WI.getStrValue((String)vEmpLeave.remove(0),"w/out pay") + "(" + strLeave +")";
				vEmpLeave.remove(0); // remove free
				vEmpLeave.remove(0); // remove free
				vEmpLeave.remove(0); // remove free
				vEmpLeave.remove(0); // remove free
				vEmpLeave.remove(0); // remove free
				vEmpLeave.remove(0); // remove free
				strHoliday += strLeave; 
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
		strHoliday += strAWOL + (String)vAWOLRecords.remove(0) +")";
	}

	if (vEmpLogout != null && vEmpLogout.size() > 0 &&
		((String)vEmpLogout.elementAt(0)).equals(strPrevDate)
		&& !bolDateRepeated){

		vEmpLogout.removeElementAt(0);
		strHoliday += strOBLabel + (String)vEmpLogout.remove(0) +")";
	}
	
	//System.out.println("strPrevDate  - " + strPrevDate);
	//System.out.println("bolDateRepeated  - " + bolDateRepeated);	
	if (vEmpOvertime != null && vEmpOvertime.size() > 0	
		&& !bolDateRepeated){
		iIndexOf = vEmpOvertime.indexOf(strPrevDate);
		while(iIndexOf != -1){
			vEmpOvertime.remove(iIndexOf);// date
			strHoliday += " OT (" + (String)vEmpOvertime.remove(iIndexOf) +")";
			iIndexOf = vEmpOvertime.indexOf(strPrevDate);
		}
	}
%>
      <td class="thinborderResize">&nbsp;<%=strHoliday%></td>
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
				strLeave = WI.getStrValue((String)vEmpLeave.remove(0),"w/out pay") + "(" + strLeave +")";
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
			strHoliday += strOBLabel + WI.getStrValue((String)vEmpLogout.remove(0),"Whole day") +")";
		}

		//if (vEmpOvertime != null && vEmpOvertime.size() > 0 &&
		//((String)vEmpOvertime.elementAt(0)).equals((String)vDayInterval.elementAt(0))
		//	&& !bolDateRepeated){
		//	System.out.println("second - " + (String)vEmpOvertime.remove(0));
		//	strHoliday += "OT (" + (String)vEmpOvertime.remove(0) +")";
		//}

	if (strHoliday.length()  > 0) {
	%>
    <tr bgcolor="#E6F0ED">
      <td height="18" class="thinborderResize"> &nbsp;<%=(String)vDayInterval.remove(0)+ "::" +
											((String)vDayInterval.remove(0)).substring(0,3)%></td>
      <td height="18" colspan="10" align="center" class="thinborderResize"><strong>&nbsp;<%=strHoliday%></strong></td>
    </tr>
<%}else{%>
    <tr bgcolor="#E6F0ED">
      <td height="18" class="thinborderResize"> &nbsp;<%=(String)vDayInterval.remove(0)+"::"+(String)((String)vDayInterval.remove(0)).substring(0,3)%></td>
      <td height="18" align="center" class="thinborderResize">&nbsp;</td>
      <td height="18" align="center" class="thinborderResize">&nbsp;</td>
      <td height="18" align="center" class="thinborderResize">&nbsp;</td>
      <td height="18" align="center" class="thinborderResize">&nbsp;</td>
      <td height="18" align="center" class="thinborderResize">&nbsp; </td>
      <td height="18" align="center" class="thinborderResize">&nbsp;</td>
      <td height="18" align="center" class="thinborderResize">&nbsp;</td>
      <td height="18" align="center" class="thinborderResize">&nbsp;</td>
      <td align="center" class="thinborderResize">&nbsp;</td>
      <td height="18" align="center" class="thinborderResize">&nbsp;</td>
    </tr>
    <%}
	   }//end of while looop
    }
	}// end if (vRetEDTR.size() == 1)%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="20" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
</table>
<%if(vRetEDTR != null && vRetEDTR.size() > 0){%>
<% //Vector vLateUnderTime = RE.getMonthlyLateUTime(dbOP,request); 
	if (WI.fillTextValue("hide_summary").length() ==0){
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td  width="15%" height="18"  class="thinborderResize">&nbsp;</td>
      <td colspan="3" align="center" class="thinborderResize"><strong>TOTAL MINUTES</strong></td>
      <td colspan="3" align="center" class="thinborderResize"><strong>FREQUENCY </strong></td>
    </tr>
    <tr>
      <td height="14" class="thinborderResize">&nbsp;</td>
      <td width="13%" align="center" class="thinborderResize"><strong>AM</strong></td>
      <td width="15%" align="center" class="thinborderResize"><strong>PM</strong></td>
      <td width="15%" align="center" class="thinborderResize"><div align="center"><strong>TOTAL</strong></div></td>
      <td width="13%" align="center" class="thinborderResize"><strong>AM</strong></td>
      <td width="14%" align="center" class="thinborderResize"><strong>PM</strong></td>
      <td width="15%" class="thinborderResize"><div align="center"><strong>TOTAL</strong></div></td>
    </tr>

    <tr>
      <td height="20" class="thinborderResize">&nbsp;<strong>TARDINESS</strong></td>
      <td align="right" class="thinborderResize">
      <% if (iTotalLateAM != 0){%><%=iTotalLateAM%> <%}%>&nbsp;</td>
	  <td align="right" class="thinborderResize">
      <% if (iTotalLatePM != 0){%><%=iTotalLatePM%><%}%>&nbsp;</td>
	  <td align="right" class="thinborderResize">
	    <% if (iTotalLateAM + iTotalLatePM != 0){%>
	  			<%=iTotalLateAM + iTotalLatePM%><%}%>&nbsp;      </td>
      <td align="right" class="thinborderResize">
      <% if (iFreqLateAM != 0){%>
			<%=iFreqLateAM%><%}%>&nbsp;</td>
      <td align="right" class="thinborderResize">
      <% if (iFreqLatePM != 0){%><%=iFreqLatePM%><%}%>&nbsp;</td>
      <td align="right" class="thinborderResize">
        <% if (iFreqLateAM + iFreqLatePM != 0){%>
	  <%=iFreqLateAM + iFreqLatePM%><%}%>&nbsp;</td>
    </tr>
    <tr>
      <td height="20" class="thinborderResize"><strong>&nbsp;UNDERTIME </strong></td>
      <td align="right" class="thinborderResize">
      <% if (iTotalUTAM != 0){%><%=iTotalUTAM%><%}%>&nbsp;</td>
	  <td align="right" class="thinborderResize">
      <% if (iTotalUTPM != 0){%><%=iTotalUTPM%><%}%>&nbsp;</td>
	  <td align="right" class="thinborderResize">
	    <% if (iTotalUTAM + iTotalUTPM != 0){%>
	  <%=iTotalUTAM + iTotalUTPM%><%}%>&nbsp;</td>
      <td align="right" class="thinborderResize">
      <% if (iFreqUTAM != 0){%><%=iFreqUTAM%><%}%>&nbsp;</td>
      <td align="right" class="thinborderResize">
      <% if (iFreqUTPM != 0){%><%=iFreqUTPM%><%}%>&nbsp;</td>
      <td align="right" class="thinborderResize">
        <% if (iFreqUTAM + iFreqUTPM != 0){%>
	  <%=iFreqUTAM + iFreqUTPM%><%}%>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
	<%}%>
	<%if(WI.fillTextValue("hide_schedule").length() == 0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#EEEDE6">
      <td height="20" colspan="5" align="center" class="thinborderResize"><strong>WORK
        SCHEDULE</strong></td>
    </tr>
    <% if (vWorkingHours == null || vWorkingHours.size() == 0) {
		strErrMsg = RE.getErrMsg();
	if (strErrMsg == null || strErrMsg.length() ==0)
		strErrMsg = " No record of employee Working Hour.";
%>
    <tr>
      <td height="20" colspan="5" align="center" class="thinborderResize"><strong><%=strErrMsg%></strong></td>
    </tr>
    <%}else{%>
    <tr align="center">
      <td width="18%" height="20" class="thinborderResize"><strong>WEEK DAY</strong></td>
      <td width="20%" class="thinborderResize"><strong>IN</strong></td>
      <td width="20%" class="thinborderResize"><strong>OUT</strong></td>
      <td width="20%" class="thinborderResize"><strong>IN </strong></td>
      <td width="20%" class="thinborderResize"><strong>OUT</strong></td>
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
			
			strWeekDay = (String)vWorkingHours.elementAt(i+4);
			//System.out.println("strWeekDay " + strWeekDay);
			if (strWeekDay == null)
				strWeekDay = (String)vWorkingHours.elementAt(i+19);
				//System.out.println("strWeekDay2 " + strWeekDay);
				
				if (strWeekDay != null)
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
	  <td height="20" class="thinborderResize">&nbsp;<%=strWeekDay%></td>
      <td class="thinborderResize">&nbsp;<%=strTimeIn0%></td>
      <td class="thinborderResize">&nbsp;<%=strTimeOut0%></td>
      <td class="thinborderResize">&nbsp;<%=WI.getStrValue(strTimeIn1)%></td>
      <td class="thinborderResize">&nbsp;<%=WI.getStrValue(strTimeOut1)%></td>
	 </tr>
	 <%}else{%>
	 <tr>
	  <td height="20" class="thinborderResize">&nbsp;<%=strWeekDay%></td>
      <td class="thinborderResize" colspan="4">&nbsp;<%=strTemp%></td>
	 </tr>
	 <%}%>
    <%}
	} // end if vWorkingHours == null || vWorkingHours.size() ==0%>
  </table>
	<%}%>
<% if (vFacultyLoad != null && vFacultyLoad.size() > 0) {%>
<table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="15" colspan="6" align="center" class="thinborderResize"><strong>TEACHING LOAD SCHEDULE </strong></td>
    </tr>
    <tr align="center">
      <td width="15%" rowspan="2" class="thinborderResize"><strong>COLLEGE</strong></td>
      <td width="16%" rowspan="2" class="thinborderResize"><strong>SECTION</strong></td>
      <td width="16%" rowspan="2" class="thinborderResize"><strong>SUBJ CODE </strong></td>
      <td height="15" colspan="2" class="thinborderResize"><strong>SCHEDULE</strong></td>
      <td class="thinborderResize">&nbsp;</td>
    </tr>
    <tr align="center">
      <td width="16%" class="thinborderResize"><strong>DAY </strong></td>
      <td width="16%" height="15" class="thinborderResize"><strong>TIME </strong></td>
      <td width="21%" class="thinborderResize"><strong>ROOM</strong></td>
    </tr>
    <%
		String strFacultyWeekDay = null;
		String strFacTime = null;
  		for(int i = 0 ; i< vFacultyLoad.size(); i+=9){  %>
	 <tr>
	  <td height="15" class="thinborderResize"><%=(String)vFacultyLoad.elementAt(i + 2)%></td>
      <td class="thinborderResize"><%=WI.getStrValue((String)vFacultyLoad.elementAt(i + 4),"&nbsp;")%></td>
      <td class="thinborderResize"><%=(String)vFacultyLoad.elementAt(i)%></td>
<%  strFacultyWeekDay = (String)vFacultyLoad.elementAt(i + 6);

	if (strFacultyWeekDay  != null && strFacultyWeekDay.length() > 0){
		strFacTime = strFacultyWeekDay.substring(strFacultyWeekDay.indexOf(" "), strFacultyWeekDay.length());
		strFacultyWeekDay = strFacultyWeekDay.substring(0,strFacultyWeekDay.indexOf(" "));
	}else{
		strFacTime = "";
		strFacultyWeekDay = "";
	}

%>
      <td class="thinborderResize">&nbsp;<%=strFacultyWeekDay%></td>
      <td class="thinborderResize">&nbsp;<%=strFacTime%></td>
      <td class="thinborderResize">&nbsp;<%=WI.getStrValue(vFacultyLoad.elementAt(i + 5),"Not Set")%></td>
	 </tr>
    <%} %>
</table>
<%}
 }
}//end  to display employee information.%>

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
