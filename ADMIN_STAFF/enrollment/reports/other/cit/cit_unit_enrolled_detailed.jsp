<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript">
function PageLoading() {
	document.all.processing.style.visibility = "hidden";
	document.bgColor = "#FFFFFF";	
}

function PrintPg()
{
	var obj = document.getElementById('myID1');
	var obj1 = document.getElementById('myID2');
	document.getElementById('myID3').deleteRow(0);
 	
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	obj.deleteRow(0);
	obj.deleteRow(0);	
		
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	
	
	window.print();//called to remove rows, make bg white and call print.	
}

</script>

<body bgcolor="#cccccc" onLoad="PageLoading();">
<!--- Processing Div --->

<div id="processing" style="position:absolute; top:10px; left:10px; width:400px; height:125px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center bgcolor="#FFFF99" class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div>
<%
	String strTemp = null;
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORTS","cit_unit_enrolled_detailed.jsp");
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
														"cit_unit_enrolled_detailed.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

String[] astrConvertSem = {"Summer","First Semester","Second Semester","Third Semester","Fourth Semester"};
	
%>
<form action="./cit_unit_enrolled_detailed.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myID1">
    <tr>
      <td width="100%" height="25" colspan="4" align="center"><strong>:::: ENROLMENT STATUS STUDENT LOAD ::::</strong></td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myID2">
    
	<tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%" height="25">SY-Term </td>
      <td width="30%" height="25"> 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
%> 
	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
%> 
	<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
	  
	  <select name="semester">
          <option value="1">1st Sem</option><%
strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));
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
      <td width="57%">&nbsp;</td>
    </tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td height="25">College</td>
	  <td height="25" colspan="2">
		<%
		String strCollegeIndex = WI.fillTextValue("c_index");
		%>
	  <select name="c_index" onChange="document.form_.show_result.value='';document.form_.submit();">
        <option value=""></option>
        <%=dbOP.loadCombo("c_index", "c_name", " from college where is_del = 0 order by c_name", strCollegeIndex,false)%>
      </select></td>
    </tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td height="25">Course</td>
	  <td height="25" colspan="2">
		<%		
		if(strCollegeIndex.length() > 0)
			strTemp = " from course_offered where c_index = "+strCollegeIndex+" and is_valid = 1 and is_del = 0 and is_offered = 1 order by course_code";
		else
			strTemp = " from course_offered where is_valid = 1 and is_del = 0 and is_offered = 1 order by course_code";		
			
		String strCourseIndex = WI.fillTextValue("course_index");
		
		%>
	  <select name="course_index">
        <option value=""></option>
        <%=dbOP.loadCombo("course_index", "course_code, course_name ", strTemp,strCourseIndex,false)%>
      </select></td>
    </tr>
<!--
	<tr>
	  <td height="25">&nbsp;</td>
	  <td height="25">Year Level </td>
	  <td height="25">&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
-->
	<tr>
	  <td height="25">&nbsp;</td>
	  <td height="25">&nbsp;</td>
	  <td height="25"><input type="submit" name="Login" value="Generate Report" onClick="document.form_.show_result.value='1';"></td>
	  <td>&nbsp;</td>
    </tr>
  </table>
  
<%
if(WI.fillTextValue("show_result").length() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myID3">
		<tr><td align="right"><a href="javascript:PrintPg();"><img src="../../../../../images/print.gif" border="0"></a> 
			<font size="1">Click to print summary</font>		
		</td></tr>
	</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr><td align="center"><font size="3"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font><br>
			<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> 
				<%=WI.fillTextValue("sy_from")%><%=WI.getStrValue(WI.fillTextValue("sy_to"),"-","","")%>
				<!--<br>Student Unit Enrolled Report-->
			</td></tr>	
			<tr><td height="15">&nbsp;</td></tr>			
  	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td width="5%" height="22" class="thinborder">Count</td>
			<td width="15%" class="thinborder">Student ID</td>
			<td width="40%" class="thinborder">Student Name</td>
			<td width="20%" class="thinborder">Courses</td>
			<td width="10%" class="thinborder">Year Level </td>
			<td width="10%" class="thinborder">Units Enrolled</td>
		</tr>
<%
String strSQLQuery = "select id_number, fname, mname, lname, course_offered.course_code, major.course_code, year_level, u_e from stud_curriculum_hist "+
"join user_table on (user_Table.user_index = stud_curriculum_hist.user_index) "+
"join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
"left join major on (major.major_index = stud_curriculum_hist.major_index) "+
"join ( "+
	"	select user_index as ui, sum(unit_enrolled) as u_e from enrl_final_cur_list "+
	"	where is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from")+" and current_semester = "+WI.fillTextValue("semester")+
	"	and is_temp_stud = 0 group by user_index) as DT_EFCL on DT_EFCL.ui = stud_curriculum_hist.user_index "+
" where stud_curriculum_hist.is_valid = 1 and sy_from ="+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester")+
" and u_e > 0 ";
//System.out.println(strSQLQuery);
if(strCollegeIndex.length() > 0) 
	strSQLQuery += " and c_index = "+strCollegeIndex;
if(strCourseIndex.length() > 0) 
	strSQLQuery += " and stud_curriculum_hist.course_index = "+strCourseIndex;

strSQLQuery += " order by lname, fname";

java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
String[] astrConvertYrLevel = {"&nbsp;","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year"};
int iCount = 0;
int iYrLevel = 0;

while(rs.next()) {
//iYrLevel = rs.getInt(7);
//if(iYrLevel < 7)
//	strTemp = astrConvertYrLevel[iYrLevel];
strTemp = WI.getStrValue(rs.getString(7), "&nbsp;");
%>
	<tr>
		  <td height="22" class="thinborder"><%=++iCount%></td>
		  <td class="thinborder"><%=rs.getString(1)%></td>
		  <td class="thinborder"><%=WI.formatName(rs.getString(2),rs.getString(3),rs.getString(4),4)%></td>
		  <td class="thinborder"><%=rs.getString(5)%><%=WI.getStrValue(rs.getString(6),"-","","")%> </td>
		  <td class="thinborder"><%=strTemp%></td>
		  <td class="thinborder"><%=CommonUtil.formatFloat(rs.getDouble(8), true)%></td>
	  </tr>
<%}
rs.close();%>
	</table>
	
	
<%}%>
<input type="hidden" name="show_result">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>