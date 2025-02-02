<%@ page language="java" import="utility.*,enrollment.ReportEnrollment, lms.LibraryAttendance, java.util.Vector" %>
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
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";
	document.forms[0].style.visibility = "hidden";
	document.forms[0].submit();
}

function PrintPg()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
	
	var obj = document.getElementById('myTable4');
	obj.deleteRow(0);
	obj.deleteRow(0);
		
	var obj1 = document.getElementById('myTable2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	
	document.getElementById('myTable3').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bg white and call print.	
	

	

}
function ReloadPage()
{
	document.form_.reloadPage.value = "1";
	document.form_.submit();
}

function GenerateReport(){
	var date = new Date();	
	var year = date.getFullYear(); 
	
	var value = year - document.form_.sy_from.value
	if(value < 4){
		alert("School year must be less than 5 years from todays year.");
		return;
	}
	document.form_.college.value = document.form_.college_name[document.form_.college_name.selectedIndex].text;
	document.form_.page_action.value = '1';
	document.form_.submit();
}
</script>
<body bgcolor="#D0E19D" topmargin="0" bottommargin="0">
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
								"LMS-CIRCULATION-REPORTS","attendance_statistics_per_program.jsp");
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
														"LIB_Circulation","REPORTS",request.getRemoteAddr(),
														"attendance_statistics_per_program_cit.jsp");
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
	

LibraryAttendance LA = new LibraryAttendance();


Vector vRetResult[] = null;
Vector vColumnDetail = null;
Vector vStudentResult = null;
Vector vFacultyResult = null;



if(WI.fillTextValue("page_action").length() > 0){
	vRetResult = LA.getDailyAttendanceStatPerProgram(dbOP, request);
	
	if(vRetResult == null)
		strErrMsg = LA.getErrMsg();
	else{
		vColumnDetail = vRetResult[0];
		vStudentResult = vRetResult[1];
		vFacultyResult = vRetResult[2];
	}
	
	//System.out.println("vColumnDetail "+vColumnDetail);
	//System.out.println("vStudentResult "+vStudentResult);
	//System.out.println("vFacultyResult "+vFacultyResult);

}

%>
<form action="./attendance_statistics_per_program_cit.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable1">
    <tr bgcolor="#77A251">
      <td width="100%" height="25" colspan="4"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          ATTENDANCE STATISTICS REPORT PER PROGRAM ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable2">
 	<tr>
		<td class="" height="25">&nbsp;</td>

		<td>College :</td>
		<%strTemp = WI.fillTextValue("college_name");%>
		<td>
		<select name="college_name">
			<%=dbOP.loadCombo("C_INDEX","C_NAME"," FROM college where is_del = 0 and " + 
					"exists (select * from course_offered where course_offered.is_valid = 1 and is_offered = 1 and is_visible = 1 " +
					"and course_offered.c_index = college.c_index) order by c_name",strTemp,false)%>
		</select></td>
	</tr>   
	<tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%" height="25">School year </td>
      <td width="22%" height="25">
	  <select name="sy_from">
		<%
		strTemp = WI.fillTextValue("sy_from");
		if(strTemp.length() == 0) {
			strTemp = String.valueOf(Integer.parseInt(WI.getTodaysDate(12)) - 4);
		}
		%>
	  
	  	<%=dbOP.loadComboYear(strTemp,8, 0)%>
	  </select>
	  </td>
      
      <td width="38%">
	  <input type="button" name="Login" value="Generate Report"	  
	   onClick="GenerateReport();" >	  </td>
    </tr>

    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
  
  
  
<%if(vColumnDetail != null && vColumnDetail.size() > 0){%>  

<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable3">
    <tr>
      <td width="12%" height="25">&nbsp;</td>
      <td align="right"><a href="javascript:PrintPg();"><img src="../../images/print_circulation.gif" border="0"></a> 
        <font size="1">click to print report</font></td>
    </tr>
  </table>
	
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  	<tr><td align="center" height="20"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td></tr>
	<tr><td align="center" height="20">Library and Learning Resource Center</td></tr>
	<tr><td>&nbsp;</td></tr>
	<tr><td align="center" height="20"><strong>Daily Attendance Statistics of Library User</strong></td></tr>
	<tr><td align="center" height="20">Student and Faculty</td></tr>	
	<tr><td>&nbsp;</td></tr>
	<tr><td align="center" height="20"><strong><%=WI.fillTextValue("college")%></strong></td></tr>
  </table>
  
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  		<tr>
			<td align="center" class="thinborder">School Year</td>
			<%if(vColumnDetail != null && vColumnDetail.size() > 0){
				for(int i =0; i<vColumnDetail.size(); i+=3){
			%>
				<td align="center" colspan="2" class="thinborder"><strong><%=(String)vColumnDetail.elementAt(i+2)%></strong></td>
			<%}
			}%>
		</tr>
	
	
	
	
	<%	
	//vStudentResult = vRetResult[1];
	//vFacultyResult = vRetResult[2];
	
	int iTemp = Integer.parseInt(WI.fillTextValue("sy_from"));
	int iLimit  = iTemp + 5;
	int iIndexOfStud = 0;
	int iIndexOfFaculty = 0;
	
	String strStudValue = "-";
	String strFacultyValue = "-";
	for(int i = iTemp; i < iLimit; i++){%>		
		<tr>
			<td align="left" class="thinborder"><strong><%=i%>-<%=i+1%></strong></td>
			
			<%for(int ii = 0; ii < vColumnDetail.size(); ii+=3){
				if(i == iTemp){%>
				<td align="center" class="thinborder">Student</td>
				<td align="center" class="thinborder">Faculty</td>
				
				<%}else{%>
				<td align="center" class="thinborder">&nbsp;</td>
				<td align="center" class="thinborder">&nbsp;</td>
			<%}
			}%>
		</tr>		
		<tr>
			<td align="right" class="thinborder">1st sem.</td>
			<%
			
			for(int aa = 0; aa < vColumnDetail.size(); aa+=3){
				for(int ii = 0;  ii < vStudentResult.size(); ii+=6){
					if(((String)vStudentResult.elementAt(ii + 4)).equals("1") && ((String)vStudentResult.elementAt(ii + 3)).equals(i+"") 
						&& ((String)vStudentResult.elementAt(ii)).equals((String)vColumnDetail.elementAt(aa)) ){
						strStudValue = (String)vStudentResult.elementAt(ii + 5);
						break;
					}
					else{
						strStudValue = "-";												
						continue;
					}
				}%>
				
				<%for(int ii = 0;  ii < vFacultyResult.size(); ii+=6){
					if(((String)vFacultyResult.elementAt(ii + 4)).equals("1") && ((String)vFacultyResult.elementAt(ii + 3)).equals(i+"") 
						&& ((String)vFacultyResult.elementAt(ii)).equals((String)vColumnDetail.elementAt(aa)) ){
						strFacultyValue = (String)vFacultyResult.elementAt(ii + 5);
						break;
					}
					else{
						strFacultyValue = "-";				
						continue;
					}
				}%>			
				
				
				<td align="center" class="thinborder"><%=strStudValue%></td>
				<td align="center" class="thinborder"><%=strFacultyValue%></td>
			<%}%>			
		</tr>
		
		<%
			strStudValue = "-";
			strFacultyValue = "-";
		%>
		<tr>
			<td align="right" class="thinborder">2nd sem.</td>
			
			<%
			
			for(int aa = 0; aa < vColumnDetail.size(); aa+=3){
				for(int ii = 0;  ii < vStudentResult.size(); ii+=6){
					if(((String)vStudentResult.elementAt(ii + 4)).equals("2") && ((String)vStudentResult.elementAt(ii + 3)).equals(i+"") 
						&& ((String)vStudentResult.elementAt(ii)).equals((String)vColumnDetail.elementAt(aa)) ){
						strStudValue = (String)vStudentResult.elementAt(ii + 5);
						break;
					}
					else{
						strStudValue = "-";												
						continue;
					}
				}%>
				
				<%for(int ii = 0;  ii < vFacultyResult.size(); ii+=6){
					if(((String)vFacultyResult.elementAt(ii + 4)).equals("2") && ((String)vFacultyResult.elementAt(ii + 3)).equals(i+"") 
						&& ((String)vFacultyResult.elementAt(ii)).equals((String)vColumnDetail.elementAt(aa)) ){
						strFacultyValue = (String)vFacultyResult.elementAt(ii + 5);
						break;
					}
					else{
						strFacultyValue = "-";				
						continue;
					}
				}%>			
				
				
				<td align="center" class="thinborder"><%=strStudValue%></td>
				<td align="center" class="thinborder"><%=strFacultyValue%></td>
			<%}%>
			
			
		</tr>
		
		<%
			strStudValue = "-";
			strFacultyValue = "-";
		%>
		<tr>
			<td align="right" class="thinborder">Summer <%=i+1%></td>
			
			<%
			
			for(int aa = 0; aa < vColumnDetail.size(); aa+=3){
				for(int ii = 0;  ii < vStudentResult.size(); ii+=6){
					if(((String)vStudentResult.elementAt(ii + 4)).equals("0") && ((String)vStudentResult.elementAt(ii + 3)).equals(i+"") 
						&& ((String)vStudentResult.elementAt(ii)).equals((String)vColumnDetail.elementAt(aa)) ){
						strStudValue = (String)vStudentResult.elementAt(ii + 5);
						break;
					}
					else{
						strStudValue = "-";												
						continue;
					}
				}%>
				
				<%for(int ii = 0;  ii < vFacultyResult.size(); ii+=6){
					if(((String)vFacultyResult.elementAt(ii + 4)).equals("0") && ((String)vFacultyResult.elementAt(ii + 3)).equals(i+"") 
						&& ((String)vFacultyResult.elementAt(ii)).equals((String)vColumnDetail.elementAt(aa)) ){
						strFacultyValue = (String)vFacultyResult.elementAt(ii + 5);
						break;
					}
					else{
						strFacultyValue = "-";				
						continue;
					}
				}%>			
				
				
				<td align="center" class="thinborder"><%=strStudValue%></td>
				<td align="center" class="thinborder"><%=strFacultyValue%></td>
			<%}%>
			
			
		</tr>		
	<%}%>
  
  
  </table>
 

<%}%>	
   
   
 



  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable4">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#77A251">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="summary_of_roe" value="<%=WI.fillTextValue("summary_of_roe")%>">
<input type="hidden" name="reloadPage">
<input type="hidden" name="college" value="<%=WI.fillTextValue("college")%>"/>
<input type="hidden" name="page_action" value="" />
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