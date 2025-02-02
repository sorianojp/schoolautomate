<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector,java.util.Calendar,java.text.*,java.util.Date " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>



<script language="JavaScript">
function submitForm() {
	document.form_.reloadPage.value='1';
	document.form_.submit();
}

function PrintPg()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myID1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
		
	var obj1 = document.getElementById('myID2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	
	document.getElementById('myID3').deleteRow(0);
	document.getElementById('myID3').deleteRow(0);
	
	document.getElementById('myID4').deleteRow(0);
	document.getElementById('myID4').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bg white and call print.	
	

	

}



function ReloadPage()
{
	document.form_.reloadPage.value = "1";
	document.form_.submit();
}
</script>




<style type="text/css">
    TD.thinborderTOPLEFTBOTTOM {
    border-top: solid 1px #000000;
    border-bottom:: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
</style>

<body bgcolor="#D2AE72">
<%
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.
	int iElemSubTotal = 0;
	int iHSSubTotal = 0;
	int iPreElemSubTotal = 0;	
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-enrollment summary","enrollment_status_summary_cit.jsp");
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
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"enrollment_status_summary_cit.jsp");
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";//for UI, the detrails are different from others. UI adds elementary details.
	
	
String strSQLQuery = null;
java.sql.ResultSet rs  = null;

Vector vDateRange = new Vector();
Vector vTodaysResult = new Vector();
Vector vEndOfDate = new Vector();
Vector vLastYear = new Vector();
Vector vLast2Year = new Vector();
Vector vCourse 	  = new Vector();
Vector vRetResult = new Vector();
Vector vCollege = new Vector();

String strRangeWD = null;
String strTodayWD = null;

String strDateFrom = null;

	strDateFrom = WI.fillTextValue("specific_date");
	
	if(WI.fillTextValue("specific_date").length() == 0)	
		strDateFrom = WI.getTodaysDate(1);
	
	strDateFrom = ConversionTable.convertTOSQLDateFormat(strDateFrom);

	
int iYear = 0;
int iSemester = 0;

int iTempSem1 = 0;
int iTempSem2 = 0;
int iTempYear1 = 0;
int iTempYear2 = 0;

if(WI.fillTextValue("reloadPage").length()>0){
	iYear = Integer.parseInt(WI.fillTextValue("sy_from"));
	iSemester = Integer.parseInt(WI.fillTextValue("offering_sem"));
	
	iTempYear1 = iYear - 1;
	iTempSem1 = iSemester;	
	
	if(iSemester == 1){		
		iTempYear2 = iTempYear1;		
		iTempSem2 = 2;
	}
	else if(iSemester == 2) {//2nd sem		
		iTempYear2 = iTempYear1;		
		iTempSem2 = 1;
	}
	else if(iSemester == 0) {//summer		
		iTempYear2 = iYear - 2;
		iTempSem2 = 0;
	}
	
	strSQLQuery = " select college.c_index, c_name, c_code from  college "+
			" join course_offered on (course_offered.c_index = college.c_index) "+
			" where course_offered.is_valid=1 and "+
			" is_offered=1 "+
			" group by college.c_index,c_name, c_code";
				rs = dbOP.executeQuery(strSQLQuery);				
				while(rs.next()) {
					vCollege.addElement(rs.getString(1)); //[0]c_index
					vCollege.addElement(rs.getString(2)); //[1]c_name
					vCollege.addElement(rs.getString(3)); //[2]c_code								
				}rs.close();
	
	strSQLQuery = " select college.c_index, course_offered.course_code, course_offered.course_index, major.course_code, major_index "+
			" from course_offered "+
			" join college on(college.c_index = course_offered.c_index) "+
			" left join major on(major.course_index = course_offered.course_index) "+
			" where course_offered.is_valid=1 and "+
			" is_offered=1 "+
			" order by c_name,course_offered.course_code,major.course_code";
				
				rs = dbOP.executeQuery(strSQLQuery);				
				while(rs.next()) {
					vCourse.addElement(rs.getString(1)); //[0]c_index
					vCourse.addElement(rs.getString(2)); //[1]course_code
					vCourse.addElement(rs.getString(4)); //[2]course_code
					vCourse.addElement(rs.getString(3)+"-"+rs.getString(5));  //[3]course_index,major_index					
				}rs.close();
				
	//enrolment list before selected date		
	strSQLQuery = " select course_index,major_index, count(*), new_stat from stud_curriculum_hist "+
			" join user_status on (user_status.status_index = stud_curriculum_hist.status_index) "+
			" where stud_curriculum_hist.is_valid = 1 and "+
			" sy_from = "+iYear+" and semester="+iSemester+
			" and exists (select * from enrl_final_cur_list where "+
			" is_valid = 1 and sy_from = stud_curriculum_hist.sy_from and "+
			" current_semester = stud_curriculum_hist.semester and user_index = stud_curriculum_hist.user_index) "+
			" and course_index > 0 "+
			" and date_enrolled < '"+strDateFrom+"' and date_enrolled is not null "+
			" group by course_index,major_index, new_stat"+
			" order by course_index ";
			
			rs = dbOP.executeQuery(strSQLQuery);				
			while(rs.next()) {
				vDateRange.addElement(rs.getString(3)); //[0] count(*)
				vDateRange.addElement(rs.getString(4)); //[1] new_stat				
				vDateRange.addElement(rs.getString(1)+"-"+rs.getString(2));  //[2] course_index,major_index				
			}rs.close();
					
	//enrolment list on selected date				
	strSQLQuery = " select course_index,major_index, count(*), new_stat from stud_curriculum_hist "+
			" join user_status on (user_status.status_index = stud_curriculum_hist.status_index) "+
			" where stud_curriculum_hist.is_valid = 1 and "+
			" sy_from = "+iYear+" and semester="+iSemester+
			" and exists (select * from enrl_final_cur_list where "+
			" is_valid = 1 and sy_from = stud_curriculum_hist.sy_from and "+
			" current_semester = stud_curriculum_hist.semester and user_index = stud_curriculum_hist.user_index) "+
			" and course_index > 0 "+
			" and date_enrolled = '"+strDateFrom+"' and date_enrolled is not null "+
			" group by course_index,major_index, new_stat "+
			" order by course_index ";
			
			rs = dbOP.executeQuery(strSQLQuery);				
			while(rs.next()) {
				vTodaysResult.addElement(rs.getString(3)); //[0] count(*)
				vTodaysResult.addElement(rs.getString(4)); //[1] new_stat				
				vTodaysResult.addElement(rs.getString(1)+"-"+rs.getString(2));  //[2] course_index,major_index					
			}rs.close();				
			
	
	//current sy_from - 1
	
	strSQLQuery = " select course_index,major_index, count(*) from stud_curriculum_hist "+
			" join user_status on (user_status.status_index = stud_curriculum_hist.status_index) "+
			" where stud_curriculum_hist.is_valid = 1 and "+
			" sy_from = "+iTempYear1+" and semester="+iTempSem1+
			" and exists (select * from enrl_final_cur_list where "+
			" is_valid = 1 and sy_from = stud_curriculum_hist.sy_from and  "+
			" current_semester = stud_curriculum_hist.semester and user_index = stud_curriculum_hist.user_index) "+
			" and course_index > 0 "+
			" group by course_index,major_index "+
			" order by course_index ";
			
			rs = dbOP.executeQuery(strSQLQuery);				
			while(rs.next()) {
				vLastYear.addElement(rs.getString(3)); //[0] count(*)				
				vLastYear.addElement(rs.getString(1)+"-"+rs.getString(2));  //[1] course_index,major_index				
			}rs.close();	
			
			
	//current sy_from - 2
	strSQLQuery = " select course_index,major_index, count(*) from stud_curriculum_hist "+
			" join user_status on (user_status.status_index = stud_curriculum_hist.status_index) "+
			" where stud_curriculum_hist.is_valid = 1 and "+
			" sy_from = "+iTempYear2+" and semester="+iTempSem2+
			" and exists (select * from enrl_final_cur_list where "+
			" is_valid = 1 and sy_from = stud_curriculum_hist.sy_from and  "+
			" current_semester = stud_curriculum_hist.semester and user_index = stud_curriculum_hist.user_index) "+
			" and course_index > 0 "+
			" group by course_index,major_index "+
			" order by course_index ";
			
			rs = dbOP.executeQuery(strSQLQuery);				
			while(rs.next()) {
				vLast2Year.addElement(rs.getString(3)); //[0] count(*)						
				vLast2Year.addElement(rs.getString(1)+"-"+rs.getString(2));  //[1] course_index,major_index				
			}rs.close();	
	
	
	strSQLQuery = " select course_index,major_index, count(*) from stud_curriculum_hist "+
			" join user_status on (user_status.status_index = stud_curriculum_hist.status_index) "+
			" where stud_curriculum_hist.is_valid = 1 and "+
			" sy_from = "+iYear+" and semester="+iSemester+
			" and not exists (select * from enrl_final_cur_list where "+
			" is_valid = 1 and sy_from = stud_curriculum_hist.sy_from and "+
			" current_semester = stud_curriculum_hist.semester and user_index = stud_curriculum_hist.user_index) "+
			" and course_index > 0 "+
			" and date_enrolled is not null "+
			" group by course_index,major_index"+
			" order by course_index";
			
			rs = dbOP.executeQuery(strSQLQuery);				
			while(rs.next()) {
				vEndOfDate.addElement(rs.getString(3)); //[0] count(*)				
				vEndOfDate.addElement(rs.getString(1)+"-"+rs.getString(2));  //[1] course_index,major_index				
			}rs.close();
			
			
	strSQLQuery = " select count(*) from stud_curriculum_hist "+
			" join user_status on (user_status.status_index = stud_curriculum_hist.status_index) "+
			" where stud_curriculum_hist.is_valid = 1 and "+
			" sy_from = "+iYear+" and semester="+iSemester+
			" and not exists (select * from enrl_final_cur_list where "+
			" is_valid = 1 and sy_from = stud_curriculum_hist.sy_from and  "+
			" current_semester = stud_curriculum_hist.semester and user_index = stud_curriculum_hist.user_index) "+
			" and course_index > 0 "+
			" and date_enrolled is not null and date_enrolled = '"+strDateFrom+"' ";			
			strTodayWD = dbOP.getResultOfAQuery(strSQLQuery,0);
			
			
	strSQLQuery = " select count(*) from stud_curriculum_hist "+
			" join user_status on (user_status.status_index = stud_curriculum_hist.status_index) "+
			" where stud_curriculum_hist.is_valid = 1 and "+
			" sy_from = "+iYear+" and semester="+iSemester+
			" and not exists (select * from enrl_final_cur_list where "+
			" is_valid = 1 and sy_from = stud_curriculum_hist.sy_from and  "+
			" current_semester = stud_curriculum_hist.semester and user_index = stud_curriculum_hist.user_index) "+
			" and course_index > 0 "+
			" and date_enrolled is not null and date_enrolled < '"+strDateFrom+"' ";			
			
			strRangeWD = dbOP.getResultOfAQuery(strSQLQuery,0);
			
}	
	
//I have to get if this is per college or per course program.
boolean bolIsGroupByCollege = WI.getStrValue(WI.fillTextValue("g_by"), "1").equals("2");
String[] strConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
	
%>
<form action="./enrollment_status_summary_cit.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myID1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          SUMMARY REPORT ON ENROLMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID2">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%" height="25">School year </td>
      <td width="22%" height="25"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> </td>
      <td width="5%">Term</td>
      <td width="22%" height="25"><select name="offering_sem">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("offering_sem");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td width="38%">
	  <input type="button" name="Login" value="Generate Report" onClick="submitForm();">	  </td>
    </tr>

    <tr> 
      <td>&nbsp;</td>
      <td width="11%" height="25">
		Date as of
      </td>
	
	<%
	strTemp = WI.fillTextValue("specific_date");
	if(strTemp.length() ==0)
		strTemp = WI.getTodaysDate(1);
	%>
	  <td colspan="3"><input name="specific_date" type="text" size="10" value="<%=strTemp%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
        <a href="javascript:show_calendar('form_.specific_date');" 
			title="Click to select date" onMouseOver="window.status='Select date';return true;" 
			onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        </font> </td>
	
    </tr>
    
    <tr>
      <td>&nbsp;</td>
      <td height="25" colspan="5">&nbsp;</td>
    </tr>

    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
  
<%

if(vCourse.size() > 0 && vCourse != null){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID3">
		<tr><td align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
			<font size="1">Click to print summary</font>		
		</td></tr>
		<td height="15">&nbsp;</td>
	</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr><td align="center"><font size="2">CEBU INSTITUTE OF TECHNOLOGY - UNIVERSITY</font><br>
				<font size="1">Enrollment Status <%=strConvertSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> 
				<br> <%=strConvertSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> <%=WI.fillTextValue("sy_from")%> <br>
				As of <%=strDateFrom%></font>
			</td></tr>	
			<tr><td height="15">&nbsp;</td></tr>			
  	</table>


<%
		String strCourse = null;
		String strPrevCourse = null;
		String strSumCount = null;
		String strPercentage = null;
		String strSumPercentage = null;
		
		String strSumRangeOld = null;
		String strSumRangeNew = null;
		String strSumTodayOld = null;
		String strSumTodayNew = null;
		String strSumTempOld = null;
		String strSumTempNew = null;
		String strSumWD = null;
		String strSumEndTotal = null;
		String strSumLastYear = null;
		String strSumLast2Year = null;		
		
		int iIndexOf = 0;		
		int iTempOld = 0;
		String strTempOld = null;
		String strTempNew = null;
		int iTempNew = 0;		
		
		String strRangeOldTot = null;
		String strRangeNewTot = null;	
			
		String strTodayOldTot = null;
		String strTodayNewTot = null;	
			
		int iEndOldTot = 0;
		int iEndNewTot = 0;
		int iEndTot = 0;
		int iEndGrandTot = 0;
		int iWDTot = 0;		
		int iLastYearTot = 0;
		int iLast2YearTot = 0;		
		int iCountTot = 0;
		int iPercentage = 0;
		
		
		int iSumRangeOld = 0;
		int iSumRangeNew = 0;
		int iSumTodayOld = 0;
		int iSumTodayNew = 0;
		int iSumTempOld  = 0;
		int iSumTempNew  = 0;
		int iSumWD		 = 0;
		int iSumEndTotal = 0;
		int iSumLastYear = 0;
		int iSumLast2Year = 0;
		int iSumCount = 0;
		double dSumPercentage = 0d;
		
		int iColSpan = 0;
		boolean bolIsCalTot = false;
		boolean bolIsCollege = false;
		boolean bolIsLastCount = false;
		
		int iIndex = 0;
		
		int iSubTotRangeOld = 0;
		int iSubTotRangeNew = 0;
		int iSubTotTodayOld = 0;
		int iSubTotTodayNew = 0;
		int iSubTotEndOld = 0;
		int iSubTotEndNew = 0;
		int iSubTotWD 	  = 0;
		int iSubTotEndTotal = 0;
		int iSubTotLastYear = 0;
		int iSubTotLast2Year = 0 ;
		int iSubTotCount = 0;
		double dSubTotPercent = 0d;
		
		int iGrandRangeTotal = 0;
		int iGrandTodayTotal = 0;

		int iETEEAPRangeOld = 0;
		int iETEEAPRangeNew = 0;
		int iETEEAPTodayOld = 0;
		int iETEEAPTodayNew = 0;
		
		int iETEEAPWD = 0;
		int iETEEAPLastYear = 0;
		int iETEEAPLast2Year = 0;
		
		String strETEEAPRangeOld  = null;
		String strETEEAPRangeNew  = null;
		String strETEEAPTodayOld  = null;
		String strETEEAPTodayNew  = null;
		
		int iETEEAPEndTotal = 0;
		int iETEEAPCount = 0;
		
		double dETEEAPPercent = 0d;
		String strETEEAPPercent = null;
		String strETEEAPCount = null;
		String strETEEAPEndTotal = null;
		String strETEEAP = null;

		int iLineCount = 0;
		int iCourseSize = 4;
		int i =0;
		boolean bolIsPageBreak = false;
while(iCourseSize <= vCourse.size()){
	iLineCount = 0;
	%>
	
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		
			<%
				strDateFrom = WI.fillTextValue("specific_date");
				if(WI.fillTextValue("specific_date").length() == 0)	
					strDateFrom = WI.getTodaysDate(1);
				
				Calendar cal = Calendar.getInstance();				
				DateFormat dateFormat = new SimpleDateFormat("MM/dd/yyyy");	
				Date date = (Date)dateFormat.parse(strDateFrom);				
				cal.setTime(date);
				cal.add(cal.DATE,-1);				
			%>
		
		<tr>
			<td width="" rowspan="2" align="center" class="thinborder"><font size="1">Course Code</font></td>
			<td colspan="2" align="center" class="thinborder">As of <%=dateFormat.format(cal.getTime())%></td>
			
			
			
			<td colspan="2" align="center" class="thinborder"><font size="1"><%=WI.formatDate(strDateFrom,2)%></font></td>
			<td colspan="4" align="center" class="thinborder"><font size="1">End of <%=WI.formatDate(strDateFrom,6)%></font></td>
			<td align="center" class="thinborder"><font size="1"><%=strConvertSem[iTempSem1]%></font></td>
			<td align="center" class="thinborder"><font size="1"><%=strConvertSem[iTempSem2]%></font></td>
			<td colspan="2" align="center" class="thinborder"><font size="1">
				<%=strConvertSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> 
				<%=iYear%> O/(U)<%=strConvertSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> 
				<%=iYear - 1%></font></td>
		</tr>
		
		<tr>			
			<td width="5%" height="23" align="center" class="thinborder"><font size="1">Old</font></td>
			<td width="5%"  align="center" class="thinborder"><font size="1">New</font></td>
			<td width="5%"  align="center" class="thinborder"><font size="1">Old</font></td>
			<td width="5%"  align="center" class="thinborder"><font size="1">New</font></td>
			
			<td width="5%"  align="center" class="thinborder"><font size="1">Old</font></td>
			<td width="5%"  align="center" class="thinborder"><font size="1">New</font></td>
			<td width="5%"  align="center" class="thinborder"><font size="1">W/D All</font></td>
			<td width="5%"  align="center" class="thinborder"><font size="1">Total</font></td>
			
			<td width="5%"  align="center" class="thinborder"><font size="1"><%=iTempYear1%></font></td>
			<td width="5%"  align="center" class="thinborder"><font size="1"><%=iTempYear2%></font></td>
			<td width="5%"  align="center" class="thinborder"><font size="1">Count</font></td>
			<td width="5%"  align="center" class="thinborder"><font size="1">Percentage</font></td>
		</tr>
		
		<%
		
		iLineCount+=2;
	
		  	for(; i < vCourse.size();i+=4){			
			iLineCount++;
			iCourseSize += 4;
			
			
			if(strPrevCourse == null)
				strPrevCourse = (String)vCourse.elementAt(i);
			else{	
				if(!strPrevCourse.equalsIgnoreCase((String)vCourse.elementAt(i))){	
					bolIsCalTot = true;
					strPrevCourse = (String)vCourse.elementAt(i);
					i-=4;			
					//iCourseSize-=4;
				}
				else
					bolIsCalTot = false;			
			}			
			
			if(i+4 == vCourse.size())
				bolIsLastCount = true;
			else
				bolIsLastCount = false;
			
			if(strCourse == null){		
				iIndex = vCollege.indexOf(vCourse.elementAt(i));
				bolIsCollege = true;				
			}else{	
				bolIsCollege = false;
			}
				
				strCourse = (String)vCourse.elementAt(i+1);
						
				if((String)vCourse.elementAt(i+2) != null)
					strCourse = strCourse+"_"+(String)vCourse.elementAt(i+2);				
				strCourse = "&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;"+strCourse;
				
				
				//first column	----- new 			
				iIndexOf = vDateRange.indexOf(vCourse.elementAt(i+3));
				if(iIndexOf == -1)
					strRangeNewTot = null;
				else{
					if(((String)vDateRange.elementAt(iIndexOf-1)).equalsIgnoreCase("New")){
						strRangeNewTot = (String)vDateRange.elementAt(iIndexOf-2);
						if(strCourse.startsWith("&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;ETEEAP"))
							iETEEAPRangeNew += Integer.parseInt((String)vDateRange.elementAt(iIndexOf-2));
							
						//iETEEAPEndNew += iETEEAPRangeNew;
						if(!bolIsLastCount){												
							vDateRange.remove(iIndexOf);vDateRange.remove(iIndexOf-1);vDateRange.remove(iIndexOf-2);
						}else{				
							if((vCourse.elementAt(i+3)).equals(vDateRange.elementAt(iIndexOf+3))){								
								vDateRange.remove(iIndexOf);vDateRange.remove(iIndexOf-1);vDateRange.remove(iIndexOf-2);							
							}
						}
					}
				}	
							//------- old
				iIndexOf = vDateRange.indexOf(vCourse.elementAt(i+3));
				if(iIndexOf == -1)
					strRangeOldTot = null;				
				else{
					if(((String)vDateRange.elementAt(iIndexOf-1)).equalsIgnoreCase("Old"))
						strRangeOldTot = (String)vDateRange.elementAt(iIndexOf-2);
					if(strCourse.startsWith("&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;ETEEAP"))
						iETEEAPRangeOld += Integer.parseInt((String)vDateRange.elementAt(iIndexOf-2));
					//iETEEAPEndOld += iETEEAPRangeOld;
				}	
				
					
					
				
				//2nd column				
				iIndexOf = vTodaysResult.indexOf(vCourse.elementAt(i+3));
				if(iIndexOf == -1){					
					strTodayNewTot = null;					
					iTempNew = Integer.parseInt(WI.getStrValue(strRangeNewTot,"0")) + Integer.parseInt(WI.getStrValue(strTodayNewTot,"0"));			
				}
				else{
					if(((String)vTodaysResult.elementAt(iIndexOf-1)).equalsIgnoreCase("New")){
						strTodayNewTot = (String)vTodaysResult.elementAt(iIndexOf-2);
						if(strCourse.startsWith("&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;ETEEAP"))
							iETEEAPTodayNew += Integer.parseInt((String)vTodaysResult.elementAt(iIndexOf-2));																
						if(!bolIsLastCount){					
							vTodaysResult.remove(iIndexOf);vTodaysResult.remove(iIndexOf-1);vTodaysResult.remove(iIndexOf-2);
						}else{
							if((vCourse.elementAt(i+3)).equals(vTodaysResult.elementAt(iIndexOf+3))){								
								vTodaysResult.remove(iIndexOf);vTodaysResult.remove(iIndexOf-1);vTodaysResult.remove(iIndexOf-2);
							}
						}	
					}	
					iTempNew = Integer.parseInt(WI.getStrValue(strRangeNewTot,"0")) + Integer.parseInt(WI.getStrValue(strTodayNewTot,"0"));		
				}
				
				iIndexOf = vTodaysResult.indexOf(vCourse.elementAt(i+3));
				if(iIndexOf == -1){
					strTodayOldTot = null;					
					iTempOld = Integer.parseInt(WI.getStrValue(strRangeOldTot,"0")) + Integer.parseInt(WI.getStrValue(strTodayOldTot,"0"));						
				}
				else{
					if(((String)vTodaysResult.elementAt(iIndexOf-1)).equalsIgnoreCase("Old")){
						strTodayOldTot = (String)vTodaysResult.elementAt(iIndexOf-2);		
						if(strCourse.startsWith("&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;ETEEAP"))
							iETEEAPTodayOld += Integer.parseInt((String)vTodaysResult.elementAt(iIndexOf-2));							
					}
					iTempOld = Integer.parseInt(WI.getStrValue(strRangeOldTot,"0")) + Integer.parseInt(WI.getStrValue(strTodayOldTot,"0"));
				}
				
				
				
				
				//3rd column
				iIndexOf = vEndOfDate.indexOf(vCourse.elementAt(i+3));			
				if(iIndexOf == -1){
					iWDTot = 0;
					iEndTot = (iTempOld+iTempNew)-iWDTot;	
				}
				else{
					iWDTot = Integer.parseInt((String)vEndOfDate.elementAt(iIndexOf-1));
					iEndTot = (iTempOld+iTempNew)-iWDTot;		
					if(strCourse.startsWith("&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;ETEEAP"))
						iETEEAPWD += Integer.parseInt((String)vEndOfDate.elementAt(iIndexOf-1));						
				}
				
				
				//4th column
				iIndexOf = vLastYear.indexOf(vCourse.elementAt(i+3));			
				if(iIndexOf==-1)
					iLastYearTot = 0;			
				else{
					iLastYearTot = Integer.parseInt((String)vLastYear.elementAt(iIndexOf-1));
					if(strCourse.startsWith("&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;ETEEAP"))
						iETEEAPLastYear += Integer.parseInt((String)vLastYear.elementAt(iIndexOf-1));					
				}
					
				//5th column
				iIndexOf = vLast2Year.indexOf(vCourse.elementAt(i+3));			
				if(iIndexOf==-1)
					iLast2YearTot = 0;	
				else{
					iLast2YearTot = Integer.parseInt((String)vLast2Year.elementAt(iIndexOf-1));
					if(strCourse.startsWith("&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;ETEEAP"))
						iETEEAPLast2Year += Integer.parseInt((String)vLast2Year.elementAt(iIndexOf-1));
				}
					
					
				//6th column
				iCountTot = iEndTot - iLastYearTot;			
				if(iCountTot < 0)
					strTemp = WI.getStrValue((Integer.toString(iCountTot)).substring(1),"(",")","0");
				else
					strTemp = WI.getStrValue(Integer.toString(iCountTot),"","","0");							
				
							
				double dPercentage = 0d;
				if(iCountTot != 0 && iEndTot != 0)					
					dPercentage = (Double.parseDouble(Integer.toString(iCountTot))/Double.parseDouble(Integer.toString(iEndTot))) * 100;
				else
					dPercentage = 100d;
					
					strPercentage = CommonUtil.formatFloat(Math.ceil((dPercentage)),1);
					strPercentage = strPercentage.substring(0,strPercentage.length()-2);
					strPercentage = WI.getStrValue(strPercentage,"","%","");
			
			if(strCourse.startsWith("&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;ETEEAP"))
					continue;
					
		%>
		
		
		<%if(!bolIsCalTot){
				iSumRangeOld+=Integer.parseInt(WI.getStrValue(strRangeOldTot,"0"));
				iSumRangeNew+=Integer.parseInt(WI.getStrValue(strRangeNewTot,"0"));				
				iSumTodayOld+=Integer.parseInt(WI.getStrValue(strTodayOldTot,"0"));
				iSumTodayNew+=Integer.parseInt(WI.getStrValue(strTodayNewTot,"0"));
				iSumTempOld+=iTempOld;
				iSumTempNew+=iTempNew;				
				iSumWD+=iWDTot;
				iSumEndTotal+=iEndTot;				
				iSumLastYear+=iLastYearTot;
				iSumLast2Year+=iLast2YearTot;	
				
				iSumCount+=iCountTot;				
				
				if(iSumCount < 0)
					strSumCount = WI.getStrValue((Integer.toString(iSumCount)).substring(1),"(",")","-");
				
				if(iSumCount != 0 && iSumEndTotal != 0)	
					dSumPercentage = (Double.parseDouble(Integer.toString(iSumCount))/Double.parseDouble(Integer.toString(iSumEndTotal))) * 100;
				else
					dSumPercentage = 100d;
					
					strSumPercentage = CommonUtil.formatFloat(Math.ceil((dSumPercentage)),1);
					strSumPercentage = strSumPercentage.substring(0,strSumPercentage.length()-2);
					strSumPercentage = WI.getStrValue(strSumPercentage,"","%","");		
		%>
		
			<%if(bolIsCollege){
			
			%>
			<tr>
				<td align="center"><font size="1"><strong><%=(((String)vCollege.elementAt(iIndex+1)).substring(11)).toUpperCase()%></strong></font></td>
				<td align="left" colspan="2" class="thinborderLEFT">&nbsp;</td>
				<td align="left" colspan="2" class="thinborderLEFT">&nbsp;</td>
				<td align="left" colspan="4" class="thinborderLEFT">&nbsp;</td>
				<td align="left" colspan="0" class="thinborderLEFT">&nbsp;</td>
				<td align="left" colspan="0" class="thinborderLEFT">&nbsp;</td>
				<td align="left" colspan="2" class="thinborderLEFT">&nbsp;</td>					
			</tr>	
			<%}%>
					
			<tr>
				<td align="left"> <font size="1"><%=WI.getStrValue(strCourse)%></font></td>			
				<td align="Right" class="thinborderLEFT"><font size="1"><%=WI.getStrValue(strRangeOldTot,"-")%></font></td>
				
				<td align="Right"><font size="1"><%=WI.getStrValue(strRangeNewTot,"-")%></font></td>
																	
				<td align="Right" class="thinborderLEFT"><font size="1"><font size="1">
				</font><%=WI.getStrValue(strTodayOldTot,"-")%></font></td>	
				<td align="Right"><font size="1"><%=WI.getStrValue(strTodayNewTot,"-")%></font></td>
				
				<%
					strTempOld = Integer.toString(iTempOld);
					if(iTempOld == 0)
						strTempOld = null;						
						
					strTempNew = Integer.toString(iTempNew);
					if(iTempNew == 0)
						strTempNew = null;	
				%>
								
				<td align="Right" class="thinborderLEFT"><font size="1"><%=WI.getStrValue(strTempOld,"-")%></font></td>
				<td align="Right"><font size="1"><%=WI.getStrValue(strTempNew,"-")%></font></td>				
				
				<%
					String strWDTot = Integer.toString(iWDTot);
					if(iWDTot == 0)
						strWDTot = null;
					
				%>
				
				<td align="Right"><font size="1"><%=WI.getStrValue(strWDTot,"-")%></font></td>
				
				<%
					String strEndTot = Integer.toString(iEndTot);					
					if(iEndTot == 0)
						strEndTot = null;
				
				%>
										
				<td align="Right"><font size="1"><%=WI.getStrValue(strEndTot,"-")%></font></td>	
				
				<%
					String strLastYearTot = Integer.toString(iLastYearTot);					
					if(iLastYearTot == 0)
						strLastYearTot = null;
				
				%>
				
				<td align="Right" class="thinborderLEFT"><font size="1"><%=WI.getStrValue(strLastYearTot,"-")%></font></td>
				
				<%
					String strLast2YearTot = Integer.toString(iLast2YearTot);					
					if(iLast2YearTot == 0)
						strLast2YearTot = null;
				
				%>
				
				<td align="Right" class="thinborderLEFT"><font size="1"><%=WI.getStrValue(strLast2YearTot,"-")%></font></td>
				
				<%					
					if(strTemp.equals("0"))
						strTemp = null;						
					strTemp = WI.getStrValue(strTemp,"-");
				%>
				
				<td align="Right" class="thinborderLEFT"><font size="1"><%=strTemp%></font></td>
				<td align="Right"><font size="1"><%=strPercentage%></font></td>	
			</tr>	
			
			
		<%}if(bolIsCalTot || bolIsLastCount){
				iSubTotRangeOld+=iSumRangeOld;
				iSubTotRangeNew+=iSumRangeNew;
				iSubTotTodayOld+=iSumTodayOld;
				iSubTotTodayNew+=iSumTodayNew;
				iSubTotEndOld += iSumTempOld;
				iSubTotEndNew+=iSumTempNew;
				iSubTotWD+=iSumWD;
				iSubTotEndTotal+=iSumEndTotal;
				iSubTotLastYear+=iSumLastYear;
				iSubTotLast2Year+=iSumLast2Year;
				iSubTotCount+=iSumCount;
				if(bolIsLastCount){
					iETEEAPEndTotal = (iETEEAPRangeNew+iETEEAPTodayNew)-iETEEAPWD;
					iETEEAPCount = iETEEAPEndTotal - iETEEAPLastYear;
				
					iSubTotRangeOld += iETEEAPRangeOld;
					iSubTotRangeNew += iETEEAPRangeNew;
					iSubTotTodayOld += iETEEAPTodayOld;
					iSubTotTodayNew += iETEEAPTodayNew;
					iSubTotEndOld += iETEEAPRangeOld + iETEEAPTodayOld;
					iSubTotEndNew += iETEEAPRangeNew+iETEEAPTodayNew;
					iSubTotWD += iETEEAPWD;
					iSubTotEndTotal += iETEEAPEndTotal;
					iSubTotLastYear += iETEEAPLastYear;
					iSubTotLast2Year += iETEEAPLast2Year;
					iSubTotCount += iETEEAPCount;
				}
			
				strCourse = null;	
		%>
		<tr>
			<td align="right"><font size="1">Total <%=vCollege.elementAt(iIndex+2)%></font></td>								
			<td align="Right" class="thinborderTOPLEFTBOTTOM"><font size="1"><%=iSumRangeOld%></font></td>			
			<td align="Right" class="thinborderTOPLEFTBOTTOM"><font size="1"><%=iSumRangeNew%></font></td>				
			<td align="Right" class="thinborderTOPLEFTBOTTOM"><font size="1"><%=iSumTodayOld%></font></td>		
			<td align="Right" class="thinborderTOPLEFTBOTTOM"><font size="1"><%=iSumTodayNew%></font></td>			
			<td align="Right" class="thinborderTOPLEFTBOTTOM"><font size="1"><%=iSumTempOld%></font></td>
			<td align="Right" class="thinborderTOPLEFTBOTTOM"><font size="1"><%=iSumTempNew%></font></td>
			<td align="Right" class="thinborderTOPLEFTBOTTOM"><font size="1"><%=iSumWD%></font></td>
			<td align="Right" class="thinborderTOPLEFTBOTTOM"><font size="1"><%=iSumEndTotal%></font></td>
			<td align="Right" class="thinborderTOPLEFTBOTTOM"><font size="1"><%=iSumLastYear%></font></td>
			<td align="Right" class="thinborderTOPLEFTBOTTOM"><font size="1"><%=iSumLast2Year%></font></td>
			<td align="Right" class="thinborderTOPLEFTBOTTOM"><font size="1"><%=strSumCount%></font></td>
			<td align="Right" class="thinborderTOPLEFTBOTTOM"><font size="1"><%=strSumPercentage%></font></td>
		</tr>
		<%		
		iSumRangeOld = 0;
		iSumRangeNew = 0;
		iSumTodayOld = 0;
		iSumTodayNew = 0;
		iSumTempOld = 0;
		iSumTempNew = 0;
		iSumWD = 0;
		iSumEndTotal = 0;
		iSumLastYear = 0;
		iSumLast2Year = 0;
		iSumCount = 0;
		dSumPercentage = 0d;
		}%>
		
		
		<%				
			if(iLineCount > 60){
					bolIsPageBreak = true;	
					i+=4;	
					break;				
				}else
					bolIsPageBreak = false;	
		%>
		
		
		
		<%}%>
		

		
		<%if(bolIsLastCount){%>		
		<tr>
			<td align="right"><font size="1">Total ETEEAP</font></td>
			<%					
				strETEEAP = Integer.toString(iETEEAPRangeOld);
				if(strETEEAP.equals("0"))
					strETEEAP = null;
			%>
			<td align="right" class="thinborder"><font size="1"><%=WI.getStrValue(strETEEAP,"-")%></font></td>
			<%
				strETEEAP = Integer.toString(iETEEAPRangeNew);
				if(strETEEAP.equals("0"))
					strETEEAP = null;
			%>
			<td align="right" class="thinborderBOTTOM"><font size="1"><%=WI.getStrValue(strETEEAP,"-")%></font></td>
			<%
				strETEEAP = Integer.toString(iETEEAPTodayOld);
				if(strETEEAP.equals("0"))
					strETEEAP = null;
			%>						
			<td align="right" class="thinborder"><font size="1"><%=WI.getStrValue(strETEEAP,"-")%></font></td>
			<%
				strETEEAP = Integer.toString(iETEEAPTodayNew);
				if(strETEEAP.equals("0"))
					strETEEAP = null;
			%>
			<td align="right" class="thinborderBOTTOM"><font size="1"><%=WI.getStrValue(strETEEAP,"-")%></font></td>
			<%
				strETEEAP = Integer.toString(iETEEAPRangeOld+iETEEAPTodayOld);
				if(strETEEAP.equals("0"))
					strETEEAP = null;
			%>
			<td align="right" class="thinborder"><font size="1"><%=WI.getStrValue(strETEEAP,"-")%></font></td>
			
			<%
				strETEEAP = Integer.toString(iETEEAPRangeNew+iETEEAPTodayNew);
				if(strETEEAP.equals("0"))
					strETEEAP = null;
			%>
			<td align="right" class="thinborderBOTTOM"><font size="1"><%=WI.getStrValue(strETEEAP,"-")%></font></td>
			<%
				strETEEAP = Integer.toString(iETEEAPWD);
				if(strETEEAP.equals("0"))
					strETEEAP = null;
			%>
			<td align="right" class="thinborderBOTTOM"><font size="1"><%=WI.getStrValue(strETEEAP,"-")%></font></td>
			<%
				strETEEAPEndTotal = Integer.toString(iETEEAPEndTotal);	
				if(strETEEAPEndTotal.equals("0"))			
					strETEEAPEndTotal = null;
			%>
			<td align="right" class="thinborderBOTTOM"><font size="1"><%=WI.getStrValue(strETEEAPEndTotal,"-")%></font></td>
			<td align="right" class="thinborder"><font size="1"><%=WI.getStrValue(Integer.toString(iETEEAPLastYear),"-")%></font></td>
			<td align="right" class="thinborder"><font size="1"><%=WI.getStrValue(Integer.toString(iETEEAPLast2Year),"-")%></font></td>
			<%
				strETEEAPCount = Integer.toString(iETEEAPCount);
				if(strETEEAPCount.equals("0"))			
					strETEEAPCount = null;
					
				if(iETEEAPCount < 0)
					strETEEAPCount = WI.getStrValue((Integer.toString(iETEEAPCount)).substring(1),"(",")","-");
			%>
			<td align="right" class="thinborder"><font size="1"><%=WI.getStrValue(strETEEAPCount,"-")%></font></td>
			<%
				
				if(iETEEAPCount != 0 && iETEEAPEndTotal != 0)	
					dETEEAPPercent = (Double.parseDouble(Integer.toString(iETEEAPCount))/Double.parseDouble(Integer.toString(iETEEAPEndTotal))) * 100;
				else
					dETEEAPPercent = 0d;
					
					strETEEAPPercent = CommonUtil.formatFloat(Math.ceil((dETEEAPPercent)),1);
					strETEEAPPercent = strETEEAPPercent.substring(0,strETEEAPPercent.length()-2);
					strETEEAPPercent = WI.getStrValue(strETEEAPPercent,"","%","");			
			%>
			
			<td align="right" class="thinborderBOTTOM"><font size="1"><%=WI.getStrValue(strETEEAPPercent,"-")%></font></td>
		</tr>
		
		
		<tr>
			<td width="">&nbsp;</td>
			<%
				strSumRangeOld = Integer.toString(iSubTotRangeOld);
				if(iSubTotRangeOld == 0)
					strSumRangeOld = null;
			%>
			<td align="Right" width="5%" class="thinborder"><strong><font size="1"><%=WI.getStrValue(strSumRangeOld,"-")%></font></strong></td>
			
			<%
				strSumRangeNew = Integer.toString(iSubTotRangeNew);
				if(iSubTotRangeNew == 0)
					strSumRangeNew = null;
			%>
			<td align="Right" width="5%" class="thinborderBOTTOM"><strong><font size="1"><%=WI.getStrValue(strSumRangeNew,"-")%></font></strong></td>			
			<%
				strSumTodayOld = Integer.toString(iSubTotTodayOld);
				if(iSubTotTodayOld == 0)
					strSumTodayOld = null;
			%>
			<td align="Right" width="5%" class="thinborder"><strong><font size="1"><%=WI.getStrValue(strSumTodayOld,"-")%></font></strong></td>			
			<%
				strSumTodayNew = Integer.toString(iSubTotTodayNew);
				if(iSubTotTodayNew == 0)
					strSumTodayNew = null;
			%>
			<td align="Right" width="5%" class="thinborderBOTTOM"><strong><font size="1"><%=WI.getStrValue(strSumTodayNew,"-")%></font></strong></td>
			<%
				strSumTempOld = Integer.toString(iSubTotEndOld);
				if(iSubTotEndOld == 0)
					strSumTempOld = null;
			%>
			<td align="Right" width="5%" class="thinborder"><strong><font size="1"><%=WI.getStrValue(strSumTempOld,"-")%></font></strong></td>
			<%
				strSumTempNew = Integer.toString(iSubTotEndNew);
				if(iSubTotEndNew == 0)
					strSumTempNew = null;
			%>
			<td align="Right" width="5%" class="thinborderBOTTOM"><strong><font size="1"><%=WI.getStrValue(strSumTempNew,"-")%></font></strong></td>
			<%
				strSumWD = Integer.toString(iSubTotWD);
				if(iSubTotWD == 0)
					strSumWD = null;
			%>
			<td align="Right" width="5%" class="thinborderBOTTOM"><strong><font size="1"><%=WI.getStrValue(strSumWD,"-")%></font></strong></td>
			<%
				strSumEndTotal = Integer.toString(iSubTotEndTotal);
				if(iSubTotEndTotal == 0)
					strSumEndTotal = null;
			%>
			<td align="Right" width="5%" class="thinborderBOTTOM"><strong><font size="1"><%=WI.getStrValue(strSumEndTotal,"-")%></font></strong></td>
			<%
				strSumLastYear = Integer.toString(iSubTotLastYear);
				if(iSubTotLastYear == 0)
					strSumLastYear = null;
			%>
			<td align="Right" width="5%" class="thinborder"><strong><font size="1"><%=WI.getStrValue(strSumLastYear,"-")%></font></strong></td>
			<%
				strSumLast2Year = Integer.toString(iSubTotLast2Year);
				if(iSubTotLast2Year == 0)
					strSumLast2Year = null;
			%>
			<td align="Right" width="5%" class="thinborder"><strong><font size="1"><%=WI.getStrValue(strSumLast2Year,"-")%></font></strong></td>
			<%
				strSumCount = Integer.toString(iSubTotCount);
				if(iSubTotCount == 0)
					strSumCount = null;
					
				if(iSubTotCount < 0)
					strSumCount = WI.getStrValue((Integer.toString(iSubTotCount)).substring(1),"(",")","-");
			%>
			<td align="Right" width="5%" class="thinborder"><strong><font size="1"><%=WI.getStrValue(strSumCount,"-")%></font></strong></td>
			
			
			<%
				if(iSubTotCount != 0 && iSubTotEndTotal != 0)	
					dSubTotPercent = (Double.parseDouble(Integer.toString(iSubTotCount))/Double.parseDouble(Integer.toString(iSubTotEndTotal))) * 100;
				else
					dSubTotPercent = 0d;
					
					strSumPercentage = CommonUtil.formatFloat(Math.ceil((dSubTotPercent)),1);
					strSumPercentage = strSumPercentage.substring(0,strSumPercentage.length()-2);
					strSumPercentage = WI.getStrValue(strSumPercentage,"","%","");
			
			%>
			
			<td align="Right" width="5%" class="thinborder"><strong><font size="1"><%=WI.getStrValue(strSumPercentage,"-")%></font></strong></td>
		</tr>
		
		
		<!------------WITHDRAW----------------->
		<tr>
			<td>&nbsp;</td>			
			<td class="thinborder"><font size="1">Withdraw</font></td>
			<td class="thinborder" align="right"><font size="1"><%=WI.getStrValue(strRangeWD,"-")%></font></td>			
			<td class="thinborder"><font size="1">Withdraw</font></td>
			<td class="thinborder" align="right"><font size="1"><%=WI.getStrValue(strTodayWD,"-")%></font></td>
			
			<%
				iGrandRangeTotal = iSubTotRangeOld + iSubTotRangeNew;
				iGrandRangeTotal = iGrandRangeTotal - Integer.parseInt(strRangeWD);		
					
				iGrandTodayTotal = iSubTotTodayOld + iSubTotTodayNew;
				iGrandTodayTotal = iGrandTodayTotal - Integer.parseInt(strTodayWD);	
				
				int iTotal = iGrandRangeTotal+iGrandTodayTotal;
			%>	
			
			<td class="thinborder" rowspan="2" colspan="4" align="center" valign="bottom"><strong><%=iTotal%></strong></td>	
			<td rowspan="2" colspan="4" align="center" valign="bottom" class="thinborder">&nbsp;</td>	
		</tr>
		
		
		<tr>
			<td align="right"><font size="1"><strong>GRAND TOTAL</strong></font> &nbsp; &nbsp; &nbsp;</td>
			<td class="thinborder" align="center" colspan="2"><strong><%=iGrandRangeTotal%></strong></td>
			<td class="thinborder" align="center" colspan="2"><strong><%=iGrandTodayTotal%></strong></td>		
		</tr>
		
		<%}%>
		</table>
		
		
	<%if(bolIsPageBreak){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}%>
		
<%}%>
		
		
<%}%>
	
	
	
  
  
  

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID4">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="summary_of_roe" value="<%=WI.fillTextValue("summary_of_roe")%>">
<input type="hidden" name="reloadPage">
</form>


<!--- Processing Div --->

<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div>

</body>
</html>
<%
dbOP.cleanUP();
%>