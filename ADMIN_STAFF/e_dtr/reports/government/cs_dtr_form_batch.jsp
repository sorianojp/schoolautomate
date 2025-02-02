<%@ page language="java" import="utility.*, eDTR.ReportEDTR,eDTR.eDTRUtil, eDTR.WorkingHour,
																java.util.Vector, java.util.Calendar, java.util.Date, 
																eDTR.AllowedLateTimeIN, eDTR.ReportEDTRExtn, payroll.PReDTRME,utility.ConversionTable"%>
<%
	WebInterface WI = new WebInterface(request);

	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(7);

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0){
		bolMyHome = true;
		strColorScheme = CommonUtil.getColorScheme(9);
	}	
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
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--
function ReloadPage(){
	document.form_.print_page.value="";
	document.form_.submit();
}
function PrintPg(){
	document.form_.print_page.value="1";
	if(document.form_.in_charge.value.length == 0){
		alert("Please enter name of in charge");
		return;
	}
	document.form_.submit();
}

function ShowRecords(){
	document.form_.print_page.value="";
	document.form_.searchEmployee.value="1";	
	document.form_.submit();
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	document.form_.print_page.value="";
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
function loadSalPeriods() {
	var strMonth = document.form_.strMonth.value;
	var strYear = document.form_.sy_.value;
	var strWeekly = null;
	strMonth = eval(strMonth) - 1;
	if(document.form_.is_weekly)
		strWeekly = document.form_.is_weekly.value;
	
	var objCOAInput = document.getElementById("sal_periods");
	
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=301&has_all=1&month_of="+strMonth+
							 "&year_of="+strYear+"&is_weekly="+strWeekly;

	this.processRequest(strURL);
}
-->
</script>

<body bgcolor="#D2AE72" class="bgDynamic">
<%
	boolean bolHasEntry = false;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode =  "";

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strAWOL = " AWOL (";
	if(strSchCode.startsWith("CLDH")){
		strAWOL = " ABSENT (";
	}

	String strOBLabel = "OB(";
	if(strSchCode.startsWith("AUF")){
		strOBLabel = " OL(";
	}
	
	if (WI.fillTextValue("print_page").equals("1")){
		if (WI.fillTextValue("in_charge").length() > 0){
			if(WI.fillTextValue("print_format").equals("0")){
 		%>
			<jsp:forward page="./cs_dtr_form_batch_print3.jsp"/>
			<%}else{%>
		 <jsp:forward page="./cs_dtr_form_batch_print2.jsp"/>
		 <%}
		 return;
		 
		}else{
			strErrMsg = " Enter name of In-charge. ";
		}
	}

	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strLeave = null;
	boolean bolHasTeam = false;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS","cs_dtr_form_batch.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
														"cs_dtr_form_batch.jsp");
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
int iCount = 0;

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
 		if(vRetResult != null){
			iSearchResult = rptExtn.getSearchCount();
			iCount = iSearchResult;
		}
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
<form action="./cs_dtr_form_batch.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF"><strong>::::
       SUMMARY REPORT OF EMPLOYEE ATTENDANCE ::::</strong></font></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
		<tr>
      <td width="3%" height="24">&nbsp;</td>
      <td width="21%">Employee ID</td>
      <td width="20%"><input name="emp_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=WI.fillTextValue("emp_id")%>" size="16" maxlength="32" onKeyUp="AjaxMapName(1);">      </td>
      <td width="56%" align="left" valign="top"><label id="coa_info"></label></td>
    </tr>

    <tr>
      <td height="24">&nbsp;</td>
      <td>Month / Year</td>
      <td colspan="2"><select name="strMonth" onChange="loadSalPeriods();">
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
        <input type="hidden" name="month_label">	 	  
		<%
			strTemp = WI.fillTextValue("sy_");
			if (strTemp.length() == 0)
				strTemp = strYear;
		%>		
		<select name="sy_" onChange="loadSalPeriods();">
      <%=dbOP.loadComboYear(WI.fillTextValue("sy_"),2,1)%>
    </select></td>
    </tr>    
    <tr>
      <td height="24">&nbsp;</td>
      <td>Salary Cut-Off</td>
			<% 
				strTemp = WI.fillTextValue("sal_period_index"); 
			%>
      <td colspan="2">
			<label id="sal_periods">
			<select name="sal_period_index" style="font-weight:bold;font-size:11px" onChange="ReloadPage()">
        <option value="">&nbsp;</option>
        <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");

		for(int i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10){
			if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += "Whole Month";
			}else{
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);			
//				strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//					(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			}			
			if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
				strDateFr = (String)vSalaryPeriod.elementAt(i+1);
				strDateTo = (String)vSalaryPeriod.elementAt(i+2);			
				%>
        <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
        <%}else{%>
        <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
        <%}//end of if condition.
				 }//end of for loop.%>
      </select>
			</label></td>
    </tr>		
		<%if(strSchCode.startsWith("AUF")){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employment Category</td>
      <td colspan="2"><select name="emp_type_catg" onChange="ReloadPage();">
        <option value="">ALL</option>
        <%
							strTemp = WI.fillTextValue("emp_type_catg");
							for(int i = 0;i < astrCategory.length;i++){
								if(strTemp.equals(Integer.toString(i))) {%>
        <option value="<%=i%>" selected><%=astrCategory[i]%></option>
        <%}else{%>
        <option value="<%=i%>"> <%=astrCategory[i]%></option>
        <%}
							}%>
      </select></td>
    </tr>
		<%}%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employment Type</td>
      <td colspan="2"><%strTemp2 = WI.fillTextValue("emp_type");%>
        <select name="emp_type">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 " +
								WI.getStrValue(WI.fillTextValue("emp_type_catg"), " and emp_type_catg = " ,"","") +
								"order by EMP_TYPE_NAME asc", strTemp2, false)%>
        </select></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>
College
  <%}else{%>
Division
<%}%></td>
      <td colspan="2"><select name="c_index" onChange="ReloadPage();">
        <option value="">N/A</option>
        <%
	strTemp = WI.fillTextValue("c_index");
	if (strTemp.length()<1) strTemp="0";
   if(strTemp.compareTo("0") ==0)
	   strTemp2 = "Offices";
   else
	   strTemp2 = "Department";%>
        <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%>
      </select></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td><%=strTemp2%></td>
      <td colspan="2"><select name="d_index">
        <% if(strTemp.compareTo("") ==0){//only if from non college.%>
        <option value="">All</option>
        <%}else{%>
        <option value="">All</option>
        <%} strTemp3= WI.fillTextValue("d_index");%>
        <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL = 0 and c_index = " + strTemp+" order by d_name asc",strTemp3, false)%>
      </select></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Office/Dept filter</td>
      <td colspan="2"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
		<%if(bolHasTeam){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Team</td>
      <td colspan="2"><select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select></td>
    </tr>
    <%}%>
		<%if(strLateSetting.equals("1") && !strSchCode.startsWith("AUF")){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td colspan="3">		
			<%  		
	  	if (WI.fillTextValue("show_only_deduct").equals("1"))
				strTemp = "checked";
			else 
				strTemp = "";
		  %>
        <input name="show_only_deduct" type="checkbox" id="show_only_deduct" value="1" <%=strTemp%>>
        check to exclude late within grace period from total late</td>
    </tr>
		<%}// end if strLateSetting.equals("1")%>
    <tr>
      <td height="24">&nbsp;</td>
      <td colspan="3"><%  		
	  	if (WI.fillTextValue("show_actual_time").equals("1"))
				strTemp = "checked";
			else 
				strTemp = "";
		  %>
        <input name="show_actual_time" type="checkbox" value="1" <%=strTemp%>>Show total hours work in actual hours and minutes</td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td colspan="3">
			<%  		
				if (WI.fillTextValue("exclude_ghosts").equals("1"))
					strTemp = "checked";
				else 
					strTemp = "";
		  %>
        <input name="exclude_ghosts" type="checkbox" value="1" <%=strTemp%>>
      Exclude employees without dtr entries</td>
    </tr>    
		<tr>
		  <td height="24">&nbsp;</td>
		  <td colspan="3"><%  		
				if (WI.fillTextValue("hide_schedule").equals("1"))
					strTemp = "checked";
				else 
					strTemp = "";
		  %>
        <input name="hide_schedule" type="checkbox" value="1" <%=strTemp%>>
Hide Working Schedule</td>
	  </tr>
		<%if(bolIsSchool){%>
		<tr>
      <td height="24">&nbsp;</td>
      <td colspan="3">
			<%  		
				if (WI.fillTextValue("hide_load").equals("1"))
					strTemp = "checked";
				else 
					strTemp = "";
		  %>
        <input name="hide_load" type="checkbox" value="1" <%=strTemp%>>
			Hide Teaching load</td>
    </tr>		
		<%}%>
		<tr>
		  <td height="24">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("fixed_ampm");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%> 
		  <td colspan="3"><input type="checkbox" name="fixed_ampm" value="1" <%=strTemp%>>
show AM login in first set and PM login in second set </td>
	  </tr>	
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">			 
			 <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ShowRecords();">		  </td>
    </tr>		
  </table>
	<%if (vRetResult != null && vRetResult.size() > 0 && iPageCount > 1){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="28%">&nbsp;</td>
			<td width="72%" align="right">&nbsp;
        <% if (!WI.fillTextValue("show_all").equals("1")) {%>
			Jump To page:
			<select name="jumpto" onChange="ShowRecords();">
				<%
				strTemp = request.getParameter("jumpto");
				if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
				for(int i =1; i<= iPageCount; ++i){
				if(i == Integer.parseInt(strTemp)){%>
				<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
				<%}else{%>
				<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
				<%}
				} // end for loop%>
			</select>
			<%}%>
			</td>
		</tr>
	</table>
<%}%>

 <%
	int iIndexOf = 0;
	int iIndexOf2 = 0;
	int iAwolType = -1;
	Integer iobjIndex = null;
	int iMain = 0;
	int iSize = 0;
	double dTemp = 0d;

	//as requestd, i have to show all the days worked and non worked.
	Vector vDayInterval = null;
	Vector vRetHolidays = null;
	Vector vEmpLeave = null;
	Vector vRetOBOT = null;
	Vector vAWOLRecords = null;
	Vector vAWOLRecordsFormatted = null;
	Vector vAwolType = null;
//	Vector vLateUnderTime = null;
	Vector vEmpLogout = null;
	Vector vEmpOvertime = null;
	Vector vSuspended = null;
	
	String strPrevDate = "";//this is added to avoid displaying date in 2nd row.
	boolean bolDateRepeated = false;
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

/*
System.out.println("vHoursWork : "+vHoursWork);
System.out.println("strDateFr : "+strDateFr);
System.out.println("strDateTo : "+strDateTo);
System.out.println("strMonths : "+strMonths);
System.out.println("strYear : "+strYear);
*/
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="16"><hr width="99%" size="1" noshade color="#0000FF"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
      <tr>
        <td height="25" colspan="2" align="center"  class="thinborder">
				<font size="2"><strong><%=strEmpID%>&nbsp;</strong></font></td>
        <td width="83%" height="25" colspan="2"  class="thinborder"><font size="2"><strong>&nbsp;
				<%=WI.formatName((String)vRetResult.elementAt(iMain+1),
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
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="12" bgcolor="#FFFFFF"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#EEEDE6" >
      <td height="25" colspan="10" align="center" class="thinborder"><strong><font color="#000000">DAILY
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
		
	//	if(strSchCode.startsWith("DEPED")){
//			//System.out.println("\nvAWOLRecords: " + vAWOLRecords);
//			if(vAWOLRecords != null && vAWOLRecords.size() > 0){
//				vAwolType = RE.getAWOLEmployeeWithSet(dbOP,strEmployeeIndex,vAWOLRecords);
//				vAWOLRecordsFormatted = new Vector();
//				
//				for(int k = 0,l = 0; k < vAWOLRecords.size(); k+=2,l++){
//					strTemp = ConversionTable.convertMMDDYYYY((Date)vAWOLRecords.elementAt(k));
//					vAWOLRecordsFormatted.addElement(strTemp);
//					vAWOLRecordsFormatted.addElement(vAWOLRecords.elementAt(k+1));					
//					//System.out.println("\nDate: " + vAWOLRecords.elementAt(k));
//					//System.out.println("hours: " + vAWOLRecords.elementAt(k+1));
//					//System.out.println("am_pm: " + vAwolType.elementAt(l));
//					//System.out.println("strTemp: " + strTemp);
//				}	
//			}	
//		}//end of if deped
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
      <td width="15%" height="20" class="thinborder">  		<strong>&nbsp;DATE</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>IN</strong></td>
      <td width="6%" align="center" class="thinborder"><strong>L</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>OUT</strong></td>
      <td width="5%" align="center" class="thinborder"><strong>U</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>IN</strong></td>
      <td width="6%" align="center" class="thinborder"><strong>L</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>OUT</strong></td>
      <td width="5%" align="center" class="thinborder"><strong>U</strong></td>
      <td width="5%" align="center" class="thinborder"><strong>TOTAL</strong></td>
    </tr>
    <% 	if (iSize == 1){//non DTR employees %>
    <tr>
      <td height="20" colspan="10" align="center" class="thinborder"><strong><%=vRetEDTR.elementAt(0)%></strong></td>
    </tr>
    <%}else{
	strTemp3 = "";
	
	strPrevDate = "";//this is added to avoid displaying date in 2nd row.
	bolDateRepeated = false;
	strLatePMEntry = null;
	strUTPMEntry = null;
	iIndexOf = 0;
	iIndexOf2 = 0;
	iAwolType = -1;
	dTemp = 0;
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
			strPrevDate = WI.getStrValue((String)vRetEDTR.elementAt(iIndex+4));
		}

//I ahve to display here for the days employee did not work.
//System.out.println(vDayInterval);
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
 				vEmpLeave.removeElementAt(0); // remove date 
				strHoliday += " leave (" + (String)vEmpLeave.remove(0) +")"; // remove hours
       			vEmpLeave.remove(0);// remove status
				vEmpLeave.remove(0); // remove sub_type
				vEmpLeave.remove(0); // remove free
				vEmpLeave.remove(0); // remove free
				vEmpLeave.remove(0); // remove free
				vEmpLeave.remove(0); // remove free
				vEmpLeave.remove(0); // remove free
				vEmpLeave.remove(0); // remove free
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
				strHoliday += strOBLabel + (String)vEmpLogout.remove(0) +")";
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
		  <td height="19" class="thinborder"> &nbsp;<%=(String)vDayInterval.remove(0)+ "::" +
											((String)vDayInterval.remove(0)).substring(0,3)%></td>
		  <td height="19" colspan="9" align="center" class="thinborder"><strong><%=strHoliday%></strong></td>
		</tr>
		<%}else{%>
		<tr bgcolor="#E6F0ED">
		  <td height="20" class="thinborder"> &nbsp;<%=(String)vDayInterval.remove(0) + "::" +
											((String)vDayInterval.remove(0)).substring(0,3)%></td>
		  <td height="20" colspan="9" align="center" class="thinborder">&nbsp;</td>
	  </tr>

		<%
		  }
		}//end of while looop

  if(vDayInterval.size() > 0)  {
  	vDayInterval.removeElementAt(0);
		strDayOfWeek = ((String)vDayInterval.remove(0)).substring(0,3);
		if(WI.fillTextValue("show_weekday").length() == 0)
			strDayOfWeek = "";
  }
}//end of if condition to print holidays.%>
    <tr>
      <td height="20" class="thinborder">&nbsp;<%if(!bolDateRepeated){%>
	  			<%=(String)vRetEDTR.elementAt(iIndex+4)%> <%=strDayOfWeek%><%}else{%> &nbsp; <%}%>	  </td>
				
	 <%	 
//	 if(strSchCode.startsWith("DEPED") && vAWOLRecordsFormatted != null && vAWOLRecordsFormatted.size() > 0 ){
//		 //get here AWOL.. 
//		  iIndexOf2 = vAWOLRecordsFormatted.indexOf(vRetEDTR.elementAt(iIndex+4));		  
//			if(iIndexOf2 > -1) {						
//				dTemp = Double.parseDouble((String)vAWOLRecordsFormatted.remove(iIndexOf2 + 1)); //dTemp has the hours			
//				vAWOLRecordsFormatted.remove(iIndexOf2);
//				
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
				
				
      <td class="thinborder">&nbsp;<%=strAmTimeIn%></td>
      <td align="right" class="thinborder"><%=strLateEntry%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=strAmTimeOut%> </td>
      <td align="right" class="thinborder"><%=strUTEntry%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strPmTimeIn,"&nbsp;")%></td>
      <td align="right" class="thinborder"><%=strLatePMEntry%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strPmTimeOut,"&nbsp;")%></td>
      <td align="right" class="thinborder"><%=strUTPMEntry%>&nbsp;</td>
			<%strTemp = "";
			 if (vHoursWork != null && vHoursWork.size()  > 0 &&
	 			strPrevDate.equals((String)vHoursWork.elementAt(1))){
				vHoursWork.removeElementAt(0);
				vHoursWork.removeElementAt(0); 
				dTotalHours = ((Double)vHoursWork.remove(0)).doubleValue();
				if(WI.fillTextValue("show_actual_time").length() > 0){
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
					strTemp = Integer.toString(iMinutes);
					if(strTemp.length() == 1)
						strTemp = "0" + strTemp;
						
					strTemp = iHours + ":" + strTemp;
				}else{
					strTemp = CommonUtil.formatFloat(dTotalHours,true);
				}
 			}%>
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
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
    vEmpLeave.remove(0);// leave type - with or without pay.
		vEmpLeave.remove(0); // remove sub_type		
		vEmpLeave.remove(0);// remove free
		vEmpLeave.remove(0);// remove free
		vEmpLeave.remove(0);// remove free
		vEmpLeave.remove(0);// remove free
		vEmpLeave.remove(0);// remove free
		vEmpLeave.remove(0);// remove free
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
			vEmpLeave.remove(0); // remove sub_type
			vEmpLeave.remove(0);// remove free
			vEmpLeave.remove(0);// remove free
			vEmpLeave.remove(0);// remove free
			vEmpLeave.remove(0);// remove free
			vEmpLeave.remove(0);// remove free
			vEmpLeave.remove(0);// remove free			
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
			strHoliday += strOBLabel + (String)vEmpLogout.remove(0) +")";


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
      <td height="20" class="thinborder"> &nbsp;<%=(String)vDayInterval.remove(0)+ "::" +
											((String)vDayInterval.remove(0)).substring(0,3)%></td>
      <td height="20" colspan="9" align="center" class="thinborder"><strong>&nbsp;<%=strHoliday%></strong></td>
    </tr>
<%}else{%>
    <tr bgcolor="#E6F0ED">
      <td height="20" class="thinborder"> &nbsp;<%=(String)vDayInterval.remove(0)+"::"+(String)((String)vDayInterval.remove(0)).substring(0,3)%></td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td height="20" align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
    </tr>
    <% }
	  }//end of while looop
     }
	}else{

	 if (strErrMsg == null || strErrMsg.length() == 0)
	 strErrMsg = " 0 RECORD FOUND ";

	%>
    <tr >
      <td height="25" colspan="10" class="thinborder">&nbsp;&nbsp; <strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong> </td>
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
      <td height="12" bgcolor="#FFFFFF"></td>
    </tr>
  </table>
	<%if(WI.fillTextValue("hide_schedule").length() == 0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#EEEDE6">
      <td height="25" colspan="5" align="center" class="thinborder"><strong>WORK
        SCHEDULE </strong></td>
    </tr>
    <% 
 		if (vWorkingHours == null || vWorkingHours.size() == 0) {
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
<%} // end for(iMain....)%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="4" valign="bottom" bgcolor="#FFFFFF"><font size="1"><strong>(NOTE:
        Please fill up information below before clicking PRINT) </strong></font></td>
    </tr>
    <tr>
      <td width="1%" height="41" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="33%" valign="bottom" bgcolor="#FFFFFF"><strong><font size="1">Certified
        Correct</font></strong></td>
      <td width="34%" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="32%" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="30" valign="bottom" bgcolor="#FFFFFF">
			<input name="in_charge"  type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" size="24"  value="<%=WI.fillTextValue("in_charge")%>"> 
			</td>
      <td valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>

    <tr>
      <td height="30" colspan="2" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
      <td valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("print_format");
			%>
      <td height="30" colspan="3" align="center" valign="bottom" bgcolor="#FFFFFF"><font size="1"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0"></a>click
      to print list
          <select name="print_format">
            <option value="0" selected>CS form No. 48</option>
            <%if(strTemp.equals("1")) {%>
            <option value="1" selected>Edited version</option>
            <%} else {%>
            <option value="1">Edited version</option>
            <%}%>
          </select>
      </font></td>
    </tr>
  </table>
 <%} // if (vRetResult != null && vRetResult.size() > 0)%>

  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="emp_count" value="<%=iCount%>">

<input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
<input type="hidden" name="print_page" value="0">
<input type="hidden" name="view_only" value="<%=WI.fillTextValue("view_only")%>">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
