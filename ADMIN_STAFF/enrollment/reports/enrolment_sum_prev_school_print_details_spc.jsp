<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	String strErrMsg = null;
	java.sql.ResultSet  rs= null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-enrollment summary from prev School","enrolment_sum_prev_school.jsp");
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
														"enrolment_sum_prev_school.jsp");
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
ReportEnrollment reportEnrollment = new ReportEnrollment();
Vector vRetResult = null;
Vector vAdditionalInfo = new Vector();

if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0)
{
	request.setAttribute("detail_v2","1");
	vRetResult = reportEnrollment.getEnrolSumFromPrevSchoolDetail(dbOP, request);
	
	if(vRetResult == null){
		strErrMsg = reportEnrollment.getErrMsg();
		strTemp ="";
	}else{
		vRetResult.remove(0);
		
		String strCon = "";
		strTemp = WI.fillTextValue("specific_date");
    	if (strTemp.length() > 0) {
		  strTemp = ConversionTable.convertTOSQLDateFormat(strTemp);
		  if(strTemp != null && strTemp.length() > 0)
			  strCon += " and stud_curriculum_hist.date_of_enrollment='" + strTemp + "'";
		}
		
		strCon += " and stud_curriculum_hist.sy_from="+WI.fillTextValue("sy_from") + 
			" and stud_curriculum_hist.semester="+WI.fillTextValue("semester");
		if (WI.fillTextValue("yr_level").length() > 0)
		  strCon += " and stud_curriculum_hist.year_Level="+WI.fillTextValue("yr_level");
		  
		if (WI.fillTextValue("status_index").length() > 0)
			strCon += " and stud_curriculum_hist.status_index="+WI.fillTextValue("status_index");
		else {
			strTemp = "select status_index  from user_status where is_for_student=1   "+
				" and (status = 'old' or status = 'Second Course(Old stud)'  or status like '%shift%' or status like '%change%') ";	
			rs = dbOP.executeQuery(strTemp);
			while (rs.next())
			  strCon += " and stud_curriculuM_hist.status_index <> " + rs.getString(1);
			rs.close();
		} 
		
		strCon += " and exists (select * from enrl_final_cur_list where is_valid = 1 and is_temp_stud = 0 "+
			" and sy_from = stud_curriculum_hist.sy_from and current_semester = stud_curriculum_hist.semester and user_index = stud_curriculum_hist.user_index) ";
			
		strTemp = "create table #1(id_number nvarchar(32), sy_from int, level_attended nvarchar(64), level_section nvarchar(64))";
		dbOP.executeUpdateWithTrans(strTemp,null,null,false);
		
		strTemp = " insert into #1"+
			" select id_number, SEC_SY_FROM,UB_SEC_LVL_ATTENDED, UB_SEC_LVL_SECTION from user_table " + 
			" join stud_curriculum_Hist on (user_table.user_index = stud_curriculum_hist.user_index) " + 				
			" left join ENTRANCE_DATA on (ENTRANCE_DATA.stud_index = stud_curriculum_hist.user_index)"+
			" where stud_curriculum_hist.is_valid=1 " + strCon;	

		dbOP.executeUpdateWithTrans(strTemp,null,null,false);
		
		strTemp = "select id_number, sy_from, level_attended, level_section from #1";
		rs = dbOP.executeQuery(strTemp);
		while(rs.next()){
			if( vAdditionalInfo.indexOf(rs.getString(1)+"_id_number") >-1 )
				continue;
			
			vAdditionalInfo.addElement( rs.getString(1)+"_id_number" );
			vAdditionalInfo.addElement(rs.getString(2));
			vAdditionalInfo.addElement(rs.getString(3));
			vAdditionalInfo.addElement(rs.getString(4));
			
		}rs.close();
		

		
	}
} 

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.reloadPage.value = "1";
	document.form_.submit();
}
</script>
<body onLoad="window.print();">

<%
if (strErrMsg != null) {
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<%} else if(vRetResult != null){  


String strCurrSchool = null;
String strSchAddress = null;
boolean bolIsPageBreak = false;
boolean bolResetPageCount = false;
int iPageCount = 0;
int iStudCount = 0;
int iMaxStudCount = 25;
int iIndexOf = 0;
while(vRetResult.size() > 0){
	bolResetPageCount = false;
	iStudCount = 0;
	if(bolIsPageBreak){bolIsPageBreak = false;		
%>		
	<div style="page-break-after:always;">&nbsp;</div>
<%}
	

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td height="25" colspan="2" align="center">
	  	<strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP, true, false)%></font><br>
		<%=SchoolInformation.getAddressLine1(dbOP, false, false)%><br><br>
		REQUEST FOR FORM 137 / TOR<br></strong>(AY <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%>)	  </td>
    </tr>
    
  </table>


<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td align="center" width="25%" height="22" class="thinborder"><strong>STUDENT NAME</strong></td>
		<td align="center" width="17%" class="thinborder"><strong>SECTION</strong></td>
		<td align="center" width="14%" class="thinborder"><strong>SCHOOL YEAR GRADUATED</strong></td>
		<td align="center" width="14%" class="thinborder"><strong>COURSE</strong></td>
		<td align="center" width="30%" class="thinborder"><strong>SCHOOL</strong></td>
	</tr>
<%
while(vRetResult.size() > 0){

	if(++iStudCount > iMaxStudCount){		
		bolResetPageCount = false;
		bolIsPageBreak = true;		
		break;
	}

	
	strTemp = (String)vRetResult.elementAt(0);
	
	iIndexOf = vAdditionalInfo.indexOf(strTemp+"_id_number");
%>
	<tr>
	    <td height="22" class="thinborder"><%=(String)vRetResult.elementAt(1)%></td>
		<%
		strTemp = "&nbsp;";
		if(iIndexOf > -1)
			strTemp = (String)vAdditionalInfo.elementAt(iIndexOf + 3);
		%>
	    <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		strTemp = "&nbsp;";
		if(iIndexOf > -1){
			strTemp = (String)vAdditionalInfo.elementAt(iIndexOf + 1);
			if(strTemp != null)
				strTemp += "-"+Integer.toString((Integer.parseInt(strTemp)+1));
		}
		%>
	    <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(3))%></td>
	    <td class="thinborder"><%=(String)vRetResult.elementAt(2)%><br><%=(String)vRetResult.elementAt(6)%></td>
    </tr>
<%
	vRetResult.remove(0);//course
	vRetResult.remove(0);//major
	vRetResult.remove(0);//course
	vRetResult.remove(0);//major
	vRetResult.remove(0);//course
	vRetResult.remove(0);//major
	vRetResult.remove(0);//course
}
%>
</table>




<%

if(bolResetPageCount)
	iPageCount = 0;
}//end outer loop

}//only if vRetResult is not null%>
</body>
</html>
<%
dbOP.cleanUP();
%>