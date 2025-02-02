<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}%>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Student Not Enrolled</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>



<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>

<script language="JavaScript">


function PrintPg()
{	
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
		
	var obj1 = document.getElementById('myTable2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	
	document.getElementById('myTable3').deleteRow(0);
	document.getElementById('myTable3').deleteRow(0);
	
	var obj = document.getElementById('myTable4');
	obj.deleteRow(0);
	obj.deleteRow(0);	
	
	window.print();
}

function Search(){
	document.form_.search_.value = '1';
	document.form_.submit();
}

</script>

<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-student not enrolled","student_not_enrolled.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

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
														null);
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
	
String[] astrConvertSem = {"SUMMER", "FIRST TRIMESTER", "SECOND TRIMESTER", "THIRD TRIMESTER", "FOURTH TRIMESTER"};
Vector vRetResult = new Vector();
ReportEnrollment enrlStatus = new ReportEnrollment();

if(WI.fillTextValue("search_").length() > 0){
	vRetResult = enrlStatus.viewStudentNotEnrolled(dbOP, request);
	if(vRetResult == null)
		strErrMsg = enrlStatus.getErrMsg();	
}



%>
<form action="./student_not_enrolled.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          STUDENT NOT ENROLLED LIST ::::</strong></font></div></td>
    </tr>
	<tr bgcolor="#FFFFFF">
		<td height="25" width="3%">&nbsp;</td>
		<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
	</tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable2">
  	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">Previous SY/Term:</td>		
		<td width="80%" colspan="3">			
			<%
				//strTemp = WI.getStrValue(WI.fillTextValue("prev_sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
				//strTemp = Integer.toString(Integer.parseInt(strTemp) - 1);
				strTemp = WI.fillTextValue("prev_sy_from");
			%>
			<input name="prev_sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","prev_sy_from","prev_sy_to")'>
			-
			<%
				//strTemp = WI.getStrValue(WI.fillTextValue("prev_sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
				//strTemp = Integer.toString(Integer.parseInt(strTemp) - 1);
				strTemp = WI.fillTextValue("prev_sy_to");				
			%>
			<input name="prev_sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				
			<%
			//strTemp = WI.getStrValue(WI.fillTextValue("prev_offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
			//if(!strTemp.equals("0"))
			//	strTemp = Integer.toString(Integer.parseInt(strTemp) - 1);
			strTemp = WI.fillTextValue("prev_offering_sem");
			%>
			<select name="prev_offering_sem">
			<%if(strTemp.equals("1")){%>
				<option value="1" selected>1st Sem</option>
			<%}else{%>
				<option value="1">1st Sem</option>
			
			<%}if(strTemp.equals("2")){%>
				<option value="2" selected>2nd Sem</option>
			<%}else{%>
				<option value="2">2nd Sem</option>
				
			<%}if(strTemp.equals("3")){%>
				<option value="3" selected>3rd Sem</option>
			<%}else{%>
				<option value="3">3rd Sem</option>
			
			<%}if(strTemp.equals("0")){%>
				<option value="0" selected>Summer</option>
			<%}else{%>
				<option value="0">Summer</option>
			<%}%>
			</select>	
			
			
	  </td>
				
			
	</tr>
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">SY/Term:</td>		
		<td width="80%" colspan="3">			
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
			%>
			<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			-
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
			%>
			<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				
			<%
			strTemp = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>
			<select name="offering_sem">
			<%if(strTemp.equals("1")){%>
				<option value="1" selected>1st Sem</option>
			<%}else{%>
				<option value="1">1st Sem</option>
			
			<%}if(strTemp.equals("2")){%>
				<option value="2" selected>2nd Sem</option>
			<%}else{%>
				<option value="2">2nd Sem</option>
				
			<%}if(strTemp.equals("3")){%>
				<option value="3" selected>3rd Sem</option>
			<%}else{%>
				<option value="3">3rd Sem</option>
			
			<%}if(strTemp.equals("0")){%>
				<option value="0" selected>Summer</option>
			<%}else{%>
				<option value="0">Summer</option>
			<%}%>
			</select>	
			
			
			</td>
				
			
	</tr>
	
	
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>College</td>
		<td colspan="3"> 
		<select name="college_index" onChange="document.form_.submit();">
		<option value="">All</option>
		<%=dbOP.loadCombo("c_index","c_name, c_code", " from college where is_del = 0 order by c_name ", WI.fillTextValue("college_index"), false)%> 
		</select>		</td>
	</tr>
	
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Course</td>
		<%
		strTemp = WI.fillTextValue("college_index");
		
		if(strTemp.length() > 0)
			strTemp = " where is_valid = 1 and is_offered = 1 and c_index = "+strTemp+" order by course_name ";
		else
			strTemp = " where is_valid = 1 and is_offered = 1 order by course_name ";
		
		%>
		<td colspan="3"> 
		<select name="course_index">
		<option value="">All</option>
		<%=dbOP.loadCombo("course_index","course_name, course_code", " from course_offered "+strTemp , WI.fillTextValue("course_index"), false)%> 
		</select>		</td>
	</tr>	
	<tr><td colspan="6">&nbsp;</td></tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>&nbsp;</td>
		<td colspan="3">
		<a href="javascript:Search();">
		<img src="../../../images/form_proceed.gif" border="0">		</a>		</td>
	</tr>
  </table>
  
  
  
  
  
<%if(vRetResult != null && vRetResult.size() > 0){%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable3">
	<tr><td align="right" valign="middle">	
		<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	</td></tr>
	<tr><td>&nbsp;</td></tr>
	<tr><td><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,true)%></div></td></tr>
	<tr>
		<td align="right"><font size="1"><strong></strong></font><font size="1">Date and Time Printed: <%=WI.getTodaysDateTime()%></font>&nbsp;</td>
	</tr>
</table>
 
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td height="25" align="center" width="5%" class="thinborder"><strong>Count</strong></td>
		<td width="15%" align="" class="thinborder"><strong>Student ID</strong></td>
		<td width="25%" align="" class="thinborder"><strong>Student Name </strong></td>
		<td width="15%" align="center" class="thinborder"><strong>Gender</strong></td>
		<td width="20%" align="" class="thinborder"><strong>Course</strong></td>
		<td width="10%" align="center" class="thinborder"><strong>Year</strong></td>
		<td width="10%" align="center" class="thinborder"><strong>Student Status</strong></td>
	</tr>
	
	<%
	int iCount = 1;
	for(int i = 0; i < vRetResult.size(); i+= 9){
	%>
	<tr>
		<td height="25" align="" class="thinborder"><%=iCount++%></td>		
		<td height="25" align="" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>		
		<td height="25" align="left" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
		<%
		strTemp = (String)vRetResult.elementAt(i+7);
		if(strTemp.equals("M"))
			strTemp = "Male";
		else
			strTemp = "Female";
		%>		
		<td height="25" align="center" class="thinborder"><%=strTemp%></td>
		<td height="25" align="left" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 3))%>
		<%=WI.getStrValue((String)vRetResult.elementAt(i+4),"- ","","")%></td>
		<td height="25" align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"&nbsp;")%></td>
		<td height="25" align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 8),"&nbsp;")%></td>
	</tr>
	<%}%>
	
</table>



<%}%>

  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable4">
  <tr>
    <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>