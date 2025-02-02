<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPg(){
	document.form_.print_page.value="1";
	document.form_.submit();
}

function ShowRecords(){
	document.form_.print_page.value="0";
}

function UpdateMonth(){

	if (document.form_.strMonth) {
		if (document.form_.strMonth.selectedIndex !=0) {
			if ( document.getElementById("month_"))
				document.getElementById("month_").innerHTML =
					document.form_.strMonth[document.form_.strMonth.selectedIndex].text;
				document.form_.month_label.value =
					document.form_.strMonth[document.form_.strMonth.selectedIndex].text;
		}else{
			if (document.getElementById("month_"))
				document.getElementById("month_").innerHTML = "";
			document.form_.month_label.value = "";

		}
	}


}

//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");

		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
-->
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*, eDTR.ReportEDTR,eDTR.eDTRUtil, eDTR.WorkingHour,java.util.Vector, java.util.Calendar,java.util.Date" %>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode =  "";

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	if (WI.fillTextValue("print_page").equals("1")){
		//if (strSchCode.startsWith("AUF")) {
		  if (WI.fillTextValue("certified").length() > 0 && WI.fillTextValue("verified_attested").length() >0
				&& WI.fillTextValue("verified").length() > 0){%>
		 <jsp:forward page="./monthly_report_emp_attendance_print.jsp" />
<%	   return;}else{
		strErrMsg = " Please complete the list of signatories ";
	   }
	  //}
	}

	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0)
		bolMyHome = true;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS","monthly_report_emp_attendance.jsp");
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
														"monthly_report_emp_attendance.jsp");
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
ReportEDTR RE = new ReportEDTR(request);
enrollment.FacultyManagement FM = new enrollment.FacultyManagement();
enrollment.Authentication authentication = new enrollment.Authentication();

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

	int iTotalLateAM = 0;
	int iTotalLatePM = 0;
	int iFreqLateAM = 0;
	int iFreqLatePM = 0;

	int iTotalUTAM = 0;
	int iTotalUTPM = 0;
	int iFreqUTAM = 0;
	int iFreqUTPM = 0;

Vector vFacultyLoad = null;
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

    if ((!strMonths.equals("0") && strMonths.length() > 0) || bolMyHome){

	  try{

		  if ( strYear.length()> 0){
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
	else{
		strDateFr = WI.fillTextValue("date_from");
		strDateTo = WI.fillTextValue("date_to");
	}


	if (strDateFr.length() > 0 && vEmpDetails != null){
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
<form action="./monthly_report_emp_attendance.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center" bgcolor="#A49A6A"><font color="#FFFFFF"><strong>::::
        MONTHLY SUMMARY REPORT OF EMPLOYEE ATTENDANCE ::::</strong></font></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
<% if (!WI.fillTextValue("my_home").equals("1")) {%>
    <tr>
      <td width="2%" height="24">&nbsp;</td>
      <td width="12%">Employee ID</td>
      <td width="18%"><input name="emp_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=WI.fillTextValue("emp_id")%>" size="16" maxlength="32" onKeyUp="AjaxMapName(1);">      </td>
      <td width="4%">
<% if (!WI.fillTextValue("view_only").equals("1")) {%>
	  <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a>
<%}else{%> &nbsp;<%}%>
	  </td>
      <td width="20%">
<% if (!WI.fillTextValue("view_only").equals("1")) {%>
			<input name="image2" type="image" src="../../../images/form_proceed.gif"
			width="81" height="21" onClick="ShowRecords()">
<%}else{%>&nbsp;<%}%>
	  </td>
      <td width="44%"><label id="coa_info"></label></td>

    </tr>
<%}%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Month</td>
      <td colspan="4">
	  <select name="strMonth" onChange="UpdateMonth()">
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
	  </select> <input type="hidden" name="month_label">
	 <% if (WI.fillTextValue("my_home").equals("1")) {%>
		  <input name="image" type="image" src="../../../images/form_proceed.gif"
		  		width="81" height="21" onClick="ShowRecords()">
	  <%}%>	  </td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Year</td>
<%
	strTemp = WI.fillTextValue("sy_");
	if (strTemp.length() == 0)
		strTemp = strYear;
%>
     <td colspan="4"><input name="sy_" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','sy_')"  value="<%=strTemp%>" size="4" maxlength="4" onKeyUp="AllowOnlyInteger('form_','sy_')"></td>
    </tr>
  </table>
<% if (vEmpDetails != null && vEmpDetails.size() > 0){ %>

<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="19"><hr width="99%" size="1" noshade color="#0000FF"></td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
      <tr>
        <td height="25" colspan="2" align="center"  class="thinborder"><font size="2"><strong>
		<% if (WI.fillTextValue("my_home").equals("1"))
				strTemp = (String)request.getSession(false).getAttribute("userId");
			else
				strTemp = WI.fillTextValue("emp_id"); %>

		<%=strTemp%>&nbsp;</strong></font></td>
        <td width="83%" height="25" colspan="2"  class="thinborder"><font size="2"><strong>&nbsp;<%=WI.formatName((String)vEmpDetails.elementAt(1),
	  (String)vEmpDetails.elementAt(2), (String)vEmpDetails.elementAt(3),4).toUpperCase()%></strong></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td width="9%" height="25"  class="thinborder"> &nbsp;UNIT </td>
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
      <td width="27%"  class="thinborder"><strong>&nbsp;<%=strTemp%> </strong></td>
      <td width="64%" height="25"  class="thinborder">&nbsp;MONTH OF &nbsp;
	  <strong><label id="month_"></label>&nbsp;<%=strYear%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#EEEDE6" >
      <td height="25" colspan="11" class="thinborder"><div align="center"><strong><font color="#000000">DAILY
          TIME RECORD</font></strong></div></td>
    </tr>
    <%
	if (WI.fillTextValue("my_home").equals("1"))
		strTemp = (String)request.getSession(false).getAttribute("userId");
	else
		strTemp = WI.fillTextValue("emp_id");

	vRetEDTR = RE.getDTRDetails(dbOP,strTemp,true);

	if (vRetEDTR!=null && vRetEDTR.size() > 0) {


//as requestd, i have to show all the days worked and non worked.
Vector vDayInterval = RE.getDayNDateDetail(strDateFr,strDateTo);
//System.out.println("vDayInterval : "  + vDayInterval);

// holidays..
Vector vRetHolidays = RE.getHolidaysOfMonth(dbOP,request);
//System.out.println("vRetHolidays : "  + vRetHolidays);

// leave..
Vector vEmpLeave = RE.getEmployeeLeave(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo);
//System.out.println("vEmpLeave : "  + vEmpLeave);

// trainings / ob / otin
Vector vRetOBOT = RE.getEmpOBOT(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo);
//System.out.println("vRetOBOT : "  + vRetOBOT);

// awol records..
Vector vAWOLRecords = RE.getAWOLEmployee(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo);
//System.out.println("vAWOLRecords : "  + vAWOLRecords);

// late undertime records..
Vector vLateUnderTime = RE.getMonthlyLateUTimeDetail(dbOP, request);
//System.out.println("vLateUnderTime : "  + vLateUnderTime);

//Employee Logout..
Vector vEmpLogout = RE.getEmpLogout(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo);
//System.out.println("vEmpLogout : "  + vEmpLogout);

Vector vEmpOvertime = RE.getEmpOverTime(dbOP, (String)vEmpDetails.elementAt(0),
									strDateFr, strDateTo);

%>
    <tr >
      <td width="15%" height="20" class="thinborder">  		<strong>&nbsp;DATE</strong></td>
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
    <% 	if (vRetEDTR.size() == 1){//non DTR employees %>
    <tr>
      <td height="20" colspan="11" align="center" class="thinborder"><strong><%=vRetEDTR.elementAt(0)%></strong></td>
    </tr>
    <%}else{
	strTemp3 = "";

	String strPrevDate = "";//this is added to avoid displaying date in 2nd row.
	boolean bolDateRepeated = false;
	String strLatePMEntry = null;
	String strUTPMEntry = null;


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


//I ahve to display here for the days employee did not work.
//System.out.println(vDayInterval);
if(!bolDateRepeated && vDayInterval != null && vDayInterval.size() > 0) {
		while(vDayInterval.size() > 0 && !strPrevDate.equals((String)vDayInterval.elementAt(0))) {

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
 				vEmpLeave.removeElementAt(0);
				strHoliday += " leave (" + (String)vEmpLeave.remove(0) +")";
                                vEmpLeave.remove(0);
																
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
				strHoliday += " AWOL (" + (String)vAWOLRecords.remove(0) +")";
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

	//	strDateEntry = (String)vDayInterval.remove(0);

		if(strHoliday.length() > 0){%>
		<tr bgcolor="#E6F0ED">
		  <td height="20" class="thinborder"> &nbsp;<%=(String)vDayInterval.remove(0)+ "::" +
											((String)vDayInterval.remove(0)).substring(0,3)%></td>
		  <td height="20" colspan="10" align="center" class="thinborder">&nbsp;<strong><%=strHoliday%></strong></td>
		</tr>
		<%}else{%>
		<tr bgcolor="#E6F0ED">
		  <td height="20" class="thinborder"> &nbsp;<%=(String)vDayInterval.remove(0) + "::" +
											((String)vDayInterval.remove(0)).substring(0,3)%></td>
		  <td height="20" align="center" class="thinborder">&nbsp;</td>
		  <td height="20" align="center" class="thinborder">&nbsp;</td>
		  <td height="20" align="center" class="thinborder">&nbsp;</td>
		  <td height="20" align="center" class="thinborder">&nbsp;</td>
		  <td height="20" align="center" class="thinborder">&nbsp;</td>
		  <td height="20" align="center" class="thinborder">&nbsp;</td>
		  <td height="20" align="center" class="thinborder">&nbsp;</td>
		  <td height="20" align="center" class="thinborder">&nbsp;</td>
		  <td align="center" class="thinborder">&nbsp;</td>
		  <td height="20" align="center" class="thinborder">&nbsp;</td>
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
      <td class="thinborder">
			  <%=WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 2)).longValue(),2)%>	  </td>

	  <%
	  	if (!WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 6), "0").equals("0")){
			iTotalLateAM += Integer.parseInt((String)vRetEDTR.elementAt(iIndex + 6));
			iFreqLateAM++;
		}
	  %>
      <td align="right" class="thinborder"><%=WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 6))%>&nbsp;</td>
      <td class="thinborder"> <%=WI.getStrValue(WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 3)).longValue(),2),"&nbsp;")%>	  </td>
	  <%
	  	if (!WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 7), "0").equals("0")){
			iTotalUTAM += Integer.parseInt((String)vRetEDTR.elementAt(iIndex + 7));
			iFreqUTAM++;
		}
	  %>
      <td align="right" class="thinborder"><%=WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 7))%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	  <%
	  	if (!WI.getStrValue(strLatePMEntry, "0").equals("0")){
			iTotalLatePM += Integer.parseInt(strLatePMEntry);
			iFreqLatePM++;
		}
	  %>
      <td align="right" class="thinborder"><%=strLatePMEntry%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp2,"&nbsp;")%></td>
	  <%
	  	if (!WI.getStrValue(strUTPMEntry, "0").equals("0")){
			iTotalUTPM += Integer.parseInt(strUTPMEntry);
			iFreqUTPM++;
		}
	  %>
      <td align="right" class="thinborder"><%=strUTPMEntry%>&nbsp;</td>

      <td class="thinborder">&nbsp;
	 <%	if (vHoursWork != null && vHoursWork.size()  > 0 &&
	 			strPrevDate.equals((String)vHoursWork.elementAt(1))){
			vHoursWork.removeElementAt(0);vHoursWork.removeElementAt(0); %>
				<%=CommonUtil.formatFloat(((Double)vHoursWork.remove(0)).doubleValue(),true)%>
	<%}%>	  </td>
      <% if (vRetHolidays != null && vRetHolidays.size() > 0 &&
		((String)vRetHolidays.elementAt(1)).equals(strPrevDate) && !bolDateRepeated){
		strHoliday = (String)vRetHolidays.elementAt(0);
		vRetHolidays.removeElementAt(0);vRetHolidays.removeElementAt(0);
	}else
		strHoliday = "";

	if (vEmpLeave != null && vEmpLeave.size() > 0 &&
		((String)vEmpLeave.elementAt(0)).equals(strPrevDate) &&
		!bolDateRepeated){

		vEmpLeave.removeElementAt(0);
		strHoliday += " leave (" + (String)vEmpLeave.remove(0) +")";
                vEmpLeave.remove(0);//leave type - with or without pay.
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
		strHoliday += " AWOL (" + (String)vAWOLRecords.remove(0) +")";
	}

	if (vEmpLogout != null && vEmpLogout.size() > 0 &&
		((String)vEmpLogout.elementAt(0)).equals(strPrevDate)
		&& !bolDateRepeated){

		vEmpLogout.removeElementAt(0);
		strHoliday += "OL(" + (String)vEmpLogout.remove(0) +")";
	}

	if (vEmpOvertime != null && vEmpOvertime.size() > 0 &&
	((String)vEmpOvertime.elementAt(0)).equals(strPrevDate)
		&& !bolDateRepeated){

		vEmpOvertime.removeElementAt(0); // date
		strHoliday += "OT (" + (String)vEmpOvertime.remove(0) +")";
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

			vEmpLeave.removeElementAt(0);
			strHoliday += " leave (" + (String)vEmpLeave.remove(0) +")";
                        vEmpLeave.remove(0);//with or without pay.
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
			strHoliday += " AWOL (" + (String)vAWOLRecords.remove(0) +")";
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

	if (strHoliday.length()  > 0) {
	%>
    <tr bgcolor="#E6F0ED">
      <td height="20" class="thinborder"> &nbsp;<%=(String)vDayInterval.remove(0)+ "::" +
											((String)vDayInterval.remove(0)).substring(0,3)%></td>
      <td height="20" colspan="10" align="center" class="thinborder"><strong>&nbsp;<%=strHoliday%></strong></td>
    </tr>
<%}else{%>
    <tr bgcolor="#E6F0ED">
      <td height="20" class="thinborder"> &nbsp;<%=(String)vDayInterval.remove(0)+"::"+(String)((String)vDayInterval.remove(0)).substring(0,3)%></td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp; </td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
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
    <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
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
      <% if (iFreqLateAM != 0){%><%=iFreqLateAM%><%}%>&nbsp;</td>
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
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#EEEDE6">
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
      <td height="25" colspan="4" valign="bottom" bgcolor="#FFFFFF"><font size="1"><strong>(NOTE:
        Please fill up information below before clicking PRINT) </strong></font></td>
    </tr>
    <tr>
      <td width="1%" height="41" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="33%" valign="bottom" bgcolor="#FFFFFF"><strong><font size="1">Certified
        Correct</font></strong></td>
      <td width="34%" valign="bottom" bgcolor="#FFFFFF"><strong><font size="1">Verified
        and Attested Correct </font></strong></td>
      <td width="32%" valign="bottom" bgcolor="#FFFFFF"> <strong><font size="1">Noted</font></strong></td>
    </tr>
    <tr>
      <td height="30" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="30" valign="bottom" bgcolor="#FFFFFF">
<input name="certified"  type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="24"  value="<%=WI.fillTextValue("certified")%>"> </td>
      <td valign="bottom" bgcolor="#FFFFFF">
<input name="verified_attested"  type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="24"  value="<%=WI.fillTextValue("verified_attested")%>"> </td>
      <td valign="bottom" bgcolor="#FFFFFF">
<input name="verified"  type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="24" value="<%=WI.fillTextValue("verified")%>"> </td>
    </tr>

    <tr>
      <td height="30" colspan="2" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="30" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td align="center" valign="bottom" bgcolor="#FFFFFF"><font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a>click
        to print list</font></td>
      <td valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
 <%}//end  to display employee information.%>

  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
<input type="hidden" name="print_page" value="0">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
<input type="hidden" name="view_only" value="<%=WI.fillTextValue("view_only")%>">


<script language="javascript">
<!--
UpdateMonth();
-->
</script>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
