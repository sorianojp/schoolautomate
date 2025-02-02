<%@ page language="java" import="utility.*" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
//strColorScheme is never null. it has value always.
boolean bolUseFacSchedule = false;
String strUserId = (String)request.getSession(false).getAttribute("userId");
boolean bolShowAllLinks = false;
	if(strUserId != null && strUserId.equals("bricks"))// para show tanan links
		bolShowAllLinks = true;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

	ReadPropertyFile readPropFile = new ReadPropertyFile();
	bolUseFacSchedule = (readPropFile.getImageFileExtn("IS_FACULTY_APPLICABLE","0")).equals("1");

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary by Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript">
	function InitFatimaGracePeriod() {
		location = "./working_hour_main.jsp?_init_grace=1";
	}
</script>
 <body bgcolor="#D2AE72" class="bgDynamic">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
      eDTR :  MULTIPLE WORKING HOURS MAIN PAGE ::::</strong></font></td>
    </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" height="25">&nbsp;</td>
    <td width="71%" height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
	<%if(strSchCode.startsWith("FATIMA") || strSchCode.startsWith("EAC") || bolShowAllLinks){%> 
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./set_subject_type.jsp">Set subject type</a></td>
  </tr>	
	<%}%>	
	<%if(bolUseFacSchedule || bolShowAllLinks){%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./faculty_sched_setting.jsp">Working hour late setting </a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./faculty_schedule.jsp">Faculty Schedule</a></td>
  </tr>   
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./faculty_schedule_batch.jsp">Faculty Schedule (Batch)</a></td>
  </tr>  
   <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./post_faculty_deduction.jsp">Post deductions</a></td>
  </tr>
	<tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./faculty_makeup_schedule.jsp">Faculty Makeup Schedule</a></td>
  </tr> 
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./add_dtr_faculty_sched.jsp">Faculty schedule update (Individual)</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./batch_faculty_update.jsp">Faculty schedule update (Batch)</a></td>
  </tr>
<!--
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./post_faculty_deduction.jsp">Post deductions</a></td>
  </tr>
-->	
	<tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./force_pay_schedule.jsp">Force schedules to with/without pay</a></td>
  </tr>	
	
	<%}else{%>	
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./post_offenses.jsp">Post deductions</a></td>
  </tr> 		
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25" align="right">&nbsp; </td>
    <td align="center">&nbsp;</td>
    <td><a href="./set_multiple_workhours.jsp">Set multiple working hours(batch)</a></td>
  </tr>  
	
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./set_emp_working_multiple.jsp">Multiple working hours (Individual)</a></td>
  </tr> 
<%}%>
 <%if(!bolIsSchool){%> 
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./add_dtr_multiple.jsp">Add/Edit Time in</a></td>
  </tr>
<%}else{
		if(!strSchCode.startsWith("CLDH")){
	%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./add_dtr_faculty.jsp">Add/Edit Time in Faculty</a></td>
  </tr>
	<%}
	}%>

	<%if(!strSchCode.startsWith("CLDH")){%> 
	 <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./dtr_multiple_report.jsp">View Time Logs</a></td>
  </tr>
	<%}%>
	<%if(strSchCode.startsWith("FATIMA") || strSchCode.startsWith("EAC") || true){%> 
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>
		<% if(strSchCode.startsWith("FATIMA") ) { %>
			<a href="./faculty_sched_detail_fatima.jsp">
		<%}else{%>
			<a href="./faculty_sched_detail.jsp">
		<%}%>
		View Time Logs(detailed)
	</a>
	</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>
		<% if(strSchCode.startsWith("FATIMA") ) { %>
			<a href="./faculty_sched_detail_fatima.jsp?show_amount=1">
		<%}else{%>
			<a href="./faculty_sched_detail.jsp?show_amount=1">
		<%}%>
	View Time Logs(detailed with amount)</a></td>
  </tr>	
	<%}%>
<% if(strSchCode.startsWith("FATIMA") || strSchCode.startsWith("UPH")) { 
String strSQLQuery = null;
int iGracePeriod   = 0;
utility.WebInterface WI  = new WebInterface(request);
utility.DBOperation dbOP = new utility.DBOperation();
//check if 
java.util.Calendar cal1 = java.util.Calendar.getInstance();
java.util.Calendar cal2 = java.util.Calendar.getInstance();
cal1.add(java.util.Calendar.DATE, -90);
cal2.add(java.util.Calendar.DATE, -1);

String strAllowedGracePeriod = " late_min between 1 and 5 ";
if(strSchCode.startsWith("UPH"))
	strAllowedGracePeriod = " late_min between 1 and 15 ";

if(WI.fillTextValue("_init_grace").length() > 0) {
	strSQLQuery = "update tin_tout_faculty set gp_late = LATE_MIN where login_date between '"+WI.getTodaysDate(cal1)+"' and '"+
					WI.getTodaysDate(cal2)+"' and "+strAllowedGracePeriod+" and (gp_late = 0 or gp_late is null)";
	//System.out.println(strSQLQuery);
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	
	strSQLQuery = "update tin_tout_faculty set gp_applied = 1, late_min = 0,ACTUAL_LATE_MIN = 0, "+
            "MINS_WORKED = mins_worked + late_min where gP_late > 0 and gp_applied = 0 and login_date between '"+
			WI.getTodaysDate(cal1)+"' and '"+ WI.getTodaysDate(cal2)+"'";
	//System.out.println(strSQLQuery);
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
}

strSQLQuery = "select count(*) from tin_tout_faculty where login_date between '"+WI.getTodaysDate(cal1)+"' and '"+
					WI.getTodaysDate(cal2)+"' and "+strAllowedGracePeriod+" and (gp_late = 0 or gp_late is null)";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
if(rs.next())
	iGracePeriod = rs.getInt(1);
rs.close();


/**
   dbOP.executeUpdateWithTrans("update tin_tout_faculty set gp_late = LATE_MIN where late_min <= 5 and "+
            "late_min >0 and login_date >= '2013-09-01' and (gp_late = 0 or gp_late is null)", null, null, false);
    
    dbOP.executeUpdateWithTrans("update tin_tout_faculty set gp_applied = 1, late_min = 0,ACTUAL_LATE_MIN = 0, "+
            "MINS_WORKED = mins_worked + late_min where gP_late > 0 and gp_applied = 0", null, null, false);
**/
%>
   <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>	
 <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>Grace Period Pending for Initialization (<%=iGracePeriod%>)
	<%if(iGracePeriod > 0){%>
		<a href="javascript:InitFatimaGracePeriod()">Click to Initialize</a>
	<%}%>
	</td>
  </tr>	
<%}%>
</table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" width="1%">&nbsp;</td>
    <td width="49%">&nbsp;</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></tr>
  <tr bgcolor="#A49A6A">
    <td width="1%" height="25" colspan="3" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
<form name="form_">
<input type="hidden" name="_init_grace">
</form>
</body>
</html>
