<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) {%>
<p style="font-weight:bold; font-size:14px; color:#FF0000">You are logged out. Please login again.</p>
<%return;}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css" />
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css" />
</head>
<script language="JavaScript">
function PrintEnrollmentForm() {
	var studID = prompt("Please enter Student's ID.", "Temp/ perm ID.");
	if(studID.length == 0)  {
		alert("Failed to process request. Stud. ID is empty.");
		return;
	}	
	var pgLoc = "./entrance_admission_slip_new_print.jsp?temp_id="+studID;
	var win=window.open(pgLoc,"AdmissionSlip",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintTestFeeSlip() {
	var studID = prompt("Please enter Student's ID.", "Temp/ perm ID.");
	if(studID.length == 0)  {
		alert("Failed to process request. Stud. ID is empty.");
		return;
	}	
	var pgLoc = "./admission_registration_print_new_stud.jsp?temp_id="+studID;
	var win=window.open(pgLoc,"AdmissionSlip",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UploadStudentImage() {
	var studID = prompt("Please enter Student's ID.", "Temporary ID.");
	if(studID.length == 0)  {
		alert("Failed to process request. Stud. ID is empty.");
		return;
	}	
	var pgLoc = "./upload_id_temp.jsp?temp_id="+studID;
	var win=window.open(pgLoc,"AdmissionSlip",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        CREATE / EDIT APPLICANT MAIN PAGE ::::</strong></font></div></td>
    </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./admission_registration_new.jsp">Create Enrollee (Name, Gender, and School Year)</a></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td width="71%"><a href="./<%if(!strSchCode.startsWith("UDMC")){%>admission_registration_new_com.jsp<%}else{%>admission_registration.jsp?remove_old=1<%}%>">Create Enrollee (Complete)</a></td>
  </tr>
  
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td width="71%"><a href="./admission_registration_cit.jsp?stud_status=Old&from_admission=1">Create Enrollee Old(Complete)</a></td>
  </tr>
  
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./admission_registration_new_edit.jsp">Edit Applicant (Name and Gender Only)</a></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="../admission/admission_registration_edit.jsp">Edit Applicant (Complete)</a></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td width="71%"><a href="../ADMISSION MAINTENANCE MODULE/entrance_exam_interview/applicant_sched_edit.jsp">Edit Applicant Schedule (Quick)</a></td>
  </tr>
  <tr> 
    <td width="12%" height="24">&nbsp;</td>
    <td width="15%" height="24">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="javascript:PrintEnrollmentForm();">Print Applicant Exam Schedule</a></td>
  </tr>
  <tr>
    <td height="24">&nbsp;</td>
    <td height="24">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
<%if(strSchCode.startsWith("CIT")){%>
  <tr>
    <td height="24">&nbsp;</td>
    <td height="24">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="javascript:PrintTestFeeSlip();">Print Testing Fee Payment Slip</a></td>
  </tr>
  <tr>
    <td height="24">&nbsp;</td>
    <td height="24">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
<%}%>
  <tr>
    <td height="24">&nbsp;</td>
    <td height="24">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="javascript:UploadStudentImage();">Upload Student Image</a></td>
  </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td width="49%">&nbsp;</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle">&nbsp;</td></tr>
  <tr bgcolor="#A49A6A"> 
    <td width="50%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>
</body>
</html>