<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

//function ReloadPage(){
//	document.form_.reload_page.value="1";
//	document.form_.submit();
//}

function autoFix(){
	document.form_.save_records.value="";
	document.form_.auto_fix.value="1";
	document.form_.submit();
}

function SaveRecords(){
	document.form_.save_records.value="1";
	document.form_.auto_fix.value="1";
	document.form_.submit();
	
}

</script>
<body bgcolor="#D2AE72" >
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-Student schedule","student_sched.jsp");
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
														"grad_missing_grades.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}


//end of authenticaion code.

Vector vRetResult = null;
Vector vStudDetail= null;
int iNoFixValues = 0;
int iCtr =0;
int iRunOnce = Integer.parseInt(WI.getStrValue(WI.fillTextValue("run_once"),"0"));

iRunOnce++;

AllProgramFix apF = new AllProgramFix();


if (WI.fillTextValue("auto_fix").equals("1")){

	if (!WI.fillTextValue("save_records").equals("1") || iRunOnce == 1){
		iNoFixValues = apF.autoFixGradSchoolGrade(dbOP,request);
		strErrMsg  = "No of students fixed : " + iNoFixValues;
	}else{
	   if (apF.manualFixGradSchoolGrades(dbOP, request, 2) != null){
		   	strErrMsg = " Operation Successful";
		}
	}
	
	vRetResult = apF.manualFixGradSchoolGrades(dbOP, request, 4);
}else{
	vRetResult = apF.gradSchoolUIMissingGrades(dbOP);
	
	if (vRetResult == null){
		strErrMsg = apF.getErrMsg();
	}
}

if(strErrMsg == null) strErrMsg = "";
%>

<form action="./grad_missing_grades_all.jsp" method="post" name="form_">
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>::::
          GRADUATE SCHOOL MISSING GRADES PAGE::::</strong></font></strong></font></div></td>
    </tr>
  </table>


  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong> </td>
    </tr>

  </table>


<% if (vRetResult != null && vRetResult.size() > 0) {
	
		String strPrevSY = null;
		String strCurrSY = null;
		String[] astrSemester = {"Summer", "1st Sem", "2nd Sem"};  
		

 if (!WI.fillTextValue("auto_fix").equals("1")) {%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" ><div align="right"><a href="javascript:autoFix()"><img src="../../../images/update.gif" width="60" height="26" border="0"></a> <font size="1">click to autofix grades/enrollments</font> </div></td>
    </tr>
</table>


<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="4" class="thinborder"><div align="center"><strong>LIST OF STUDENTS WITH MISSING GRADES </strong></div></td>
    </tr>
    <tr>
      <td width="17%" class="thinborder"><div align="center"><strong>STUDENT ID </strong></div></td>
      <td width="41%" height="25" class="thinborder"><div align="center"><strong>STUDENT NAME </strong></div></td>
      <td width="29%" class="thinborder"><div align="center"><strong>SCHOOL YEAR (SEM) </strong> </div></td>
      <td width="13%" class="thinborder"><div align="center"><strong> COUNT </strong></div></td>
    </tr>
	<% 
		String strStudIDNumber = null;
		 boolean bolShowAll = false;
		 String strName = null;
	for (int i = 0; i < vRetResult.size() ; i+=9) {
		bolShowAll = false;
		strName = "";
		
		
			strCurrSY = (String)vRetResult.elementAt(i+2) + " - " + 
				(String)vRetResult.elementAt(i+7) + " (" +
				astrSemester[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"1"))]
				+ ") ";


			if (strStudIDNumber  == null || !strStudIDNumber.equals((String)vRetResult.elementAt(i+1))) { // change all 
				bolShowAll = true;
				strStudIDNumber = (String)vRetResult.elementAt(i+1);
				strName = WI.formatName((String)vRetResult.elementAt(i+4), 
										(String)vRetResult.elementAt(i+5),
										(String)vRetResult.elementAt(i+6),4);
			}
			
			if (strPrevSY == null || !strCurrSY.equals(strPrevSY)
				|| bolShowAll){
				strPrevSY = strCurrSY;
			}else{
				strCurrSY = "";
			}
	%>
    <tr>
      <td class="thinborder">&nbsp; <%=strStudIDNumber%></td>
      <td height="25" class="thinborder">&nbsp;<%=strName%></td>
      <td class="thinborder">&nbsp;<%=strCurrSY%></td>
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i))%></td>
    </tr>
	<%}%> 
  </table>
 <%}else{%>  
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="6" class="thinborder"><div align="center"><strong>LIST OF STUDENTS WITH MISSING GRADES </strong></div></td>
    </tr>
    <tr>
      <td width="11%" class="thinborder"><div align="center"><strong>STUD ID </strong></div></td>
      <td width="26%" height="25" class="thinborder"><div align="center"><strong>STUDENT NAME </strong></div></td>
      <td width="19%" class="thinborder"><div align="center"><strong>COURSE/MAJOR (CY)</strong></div></td>
      <td width="16%" class="thinborder"><div align="center"><strong>SY (SEM) </strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>SUBJECT</strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong> CORRECT SUBJ </strong></div></td>
    </tr>
	<% iCtr = 0;
	for (int i = 0; i < vRetResult.size() ; i+=16,iCtr++) {
		
			strCurrSY = (String)vRetResult.elementAt(i+3) + " - " + 
				(String)vRetResult.elementAt(i+4) + " (" +
				astrSemester[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"1"))]
				+ ") ";
	%>
    <tr>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7) + 
				WI.getStrValue((String)vRetResult.elementAt(i+8),"(",")","") +
				"(" + (String)vRetResult.elementAt(i+9) + " - " + 
				(String)vRetResult.elementAt(i+10) + ")"%>        </td>
      <td class="thinborder">&nbsp;<%=strCurrSY%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
      <td class="thinborder">
        <div align="center">&nbsp;
	<input type="hidden" name="cy_from<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+9)%>"> 
	<input type="hidden" name="cy_to<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+10)%>"> 
	<input type="hidden" name="course_index<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+11)%>"> 
	<input type="hidden" name="major_index<%=iCtr%>" value="<%=WI.getStrValue((String)vRetResult.elementAt(i+12))%>"> 
	<input type="hidden" name="user_index<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+1)%>">		
	<input type="hidden" name="enroll_index<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+13)%>"> 			
	<input type="hidden" name="sy_from<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+3)%>"> 			
	<input type="hidden" name="semester<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+5)%>"> 				
	<input type="hidden" name="sub_sec_index<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+14)%>"> 								
	<input type="hidden" name="cur_hist_index<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+15)%>"> 								
	
    <input name="sub<%=iCtr%>" type="text" class="textbox" size="12">
      </div></td>
    </tr>
	<%}	%> 
    <tr>
      <td height="25" colspan="6" class="thinborder" align="center">&nbsp;
	  <a href="javascript:SaveRecords()">
	  		<img src="../../../images/save.gif" border="0">
	  </a>
	  </td>
    </tr>
  </table>  
<%
  } // end if else
}%>

  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" value ="<%=WI.fillTextValue("auto_fix")%>" name="auto_fix">
 <input type="hidden" value="<%=iCtr%>" name="max_display">
  <input type="hidden" value="" name="save_records">
  <input type="hidden" value="<%=iRunOnce%>" name="run_once">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
