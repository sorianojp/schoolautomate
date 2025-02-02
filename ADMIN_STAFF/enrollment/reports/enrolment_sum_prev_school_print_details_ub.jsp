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
	strTemp = "window.print();";
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
<body onLoad="<%=strTemp%>">

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
int iMaxStudCount = 20;
int iIndexOf = 0;
while(vRetResult.size() > 0){
	bolResetPageCount = false;
	iStudCount = 0;
	if(bolIsPageBreak){bolIsPageBreak = false;		
%>		
	<div style="page-break-after:always;">&nbsp;</div>
<%}
	strCurrSchool = (String)vRetResult.elementAt(2);	
	strSchAddress = (String)vRetResult.elementAt(6);

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td height="25" colspan="2" align="center">
	  	<strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP, true, false)%></font><br>
		<%=SchoolInformation.getAddressLine1(dbOP, false, false)%><br><br>
		OFFICE OF THE REGISTRAR</strong>	  </td>
    </tr>
    <tr>
        <td width="50%"  align="center">&nbsp;</td>
        <td  align="center"><%=WI.getTodaysDate(1)%></td>
    </tr>
    <tr>
        <td height="22" style="padding-left:40px;">The Principal</td>
        <td  align="center">&nbsp;</td>
    </tr>
    <tr>
        <td height="22" style="padding-left:40px;" valign="bottom">
		<div style="border-bottom:solid 1px #000000; width:80%;"><%=strCurrSchool%></div></td>
        <td  align="center">&nbsp;</td>
    </tr>
    <tr>
        <td height="22" style="padding-left:40px;" valign="bottom">
		<div style="border-bottom:solid 1px #000000; width:80%;"><%=strSchAddress%></div></td>
        <td  align="center">&nbsp;</td>
    </tr>
    <tr>
        <td height="22" style="padding-left:40px;" valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%;"></div></td>
        <td  align="center">&nbsp;</td>
    </tr>
    <tr>
        <td height="20" colspan="2">&nbsp;</td>
      </tr>
    <tr>
        <td height="25" style="padding-left:40px;">Sir/Madam:</td>
        <td  align="center">&nbsp;</td>
    </tr>
    <tr>
        <td height="25" colspan="2" style="padding-left:40px; text-indent:40px; text-align:justify;">
			Please furnish us the certified copy of the BPS Form 137-A (Student Permanent Records)
			of the said student/students who attended in your school. These students are temporarily
			enrolled in this school pending receipt of the form requested above.		</td>
      </tr>
    <tr>
        <td height="20">&nbsp;</td>
        <td  align="center">&nbsp;</td>
    </tr>
    <tr>
        <td height="25" colspan="2" style="padding-left:40px;text-indent:40px;text-align:justify;">
		Please return this request form properly filled out.</td>
      </tr>
  </table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td class="thinborder" width="50%" align="center" valign="top">NAME OF STUDENTS</td>
		<td class="thinborder" width="15%" align="center">Grade/Year<br>
	    Level Attended</td>
		<td class="thinborder" width="16%" align="center">School<br>
	    Year</td>
		<td class="thinborder" width="19%" align="center" valign="top">Remarks</td>
	</tr>
<%
while(vRetResult.size() > 0){

	if(++iStudCount > iMaxStudCount){		
		bolResetPageCount = false;
		bolIsPageBreak = true;		
		break;
	}

	if(vRetResult.elementAt(2) != null && !strCurrSchool.equals((String)vRetResult.elementAt(2))){//from top the element(0) is stud name
		bolIsPageBreak = true;		
		bolResetPageCount = true;
		break;
	}
	
	strTemp = (String)vRetResult.elementAt(0);
	
	iIndexOf = vAdditionalInfo.indexOf(strTemp+"_id_number");
%>
	<tr>
		<td height="20" class="thinborder"><%=(String)vRetResult.elementAt(1)%></td>
		<%
		strTemp = "&nbsp;";
		if(iIndexOf > -1)
			strTemp = (String)vAdditionalInfo.elementAt(iIndexOf + 2);
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
		<%
		strTemp = "&nbsp;";
		if(iIndexOf > -1)
			strTemp = (String)vAdditionalInfo.elementAt(iIndexOf + 3);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
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
	
	
	
	while(iStudCount <= iMaxStudCount){
		++iStudCount;
%>
	<tr>
		<td height="20" class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
	</tr>	
<%}%>
</table>


<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td height="20" colspan="2">&nbsp;</td></tr>
	<tr>
		<td colspan="2" style="padding-left:40px;text-indent:40px;">
		In case your records have been destroyed or lost, it is requested
that a certificate of eligibility for admission
to high school/college be issued in favor of the said student.</td>
	</tr>
	<tr>
	    <td height="30" width="56%">&nbsp;</td>
        <td width="44%">Very truly yours,</td>
	</tr>
	<tr>
	    <td height="30" width="56%">&nbsp;</td>
		<%
		strTemp = WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)).toUpperCase();
		if(strTemp.length() == 0)
			strTemp = "DALIA MELDA T. MAGNO, CPA";
		%>
        <td width="44%" valign="bottom"><%=strTemp%></td>
	</tr>
	<tr>
	    <td>&nbsp;</td>
        <td style="padding-left:60px;">Registrar</td>
	</tr>
	<tr>
	    <td>[&nbsp;&nbsp;]1<sup>st</sup> request<br>
			[&nbsp;&nbsp;]2<sup>nd</sup> request<br>
			[&nbsp;&nbsp;]3<sup>rd</sup> request<br>
			[&nbsp;&nbsp;]urgent<br>
			[&nbsp;&nbsp;]Please entrust the bearer<br>		</td>
	    <td valign="bottom">by:_______________<br> &nbsp; &nbsp; &nbsp;Clerk-In-Charge</td>
    </tr>
		
</table>

<%

if(bolResetPageCount)
	iPageCount = 0;
}%>
	

<%}//only if vRetResult is not null%>
</body>
</html>
<%
dbOP.cleanUP();
%>