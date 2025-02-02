<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
String strUserId  = (String)request.getSession(false).getAttribute("userId");
if(strUserId == null)
	strUserId = "";
if(strSchCode == null)
	strSchCode = "";
%>
<body bgcolor="#D2AE72">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        LIST OF ALL OTHER REPORTS ::::</strong></font></div></td>
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
<%if(strSchCode.startsWith("CSA")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./nstp_graduate_ul.jsp?ched=1">NSTP Graduate - CHED</a></td>
  </tr>
<%}if(strSchCode.startsWith("UL")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td><a href="./nstp_graduate_ul.jsp">NSTP Enrollment List</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td><a href="./nstp_graduate_ul.jsp?ched=1">NSTP Graduate - CHED</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td><a href="./nstp_graduate_ul_redcross.jsp">NSTP Redcross</a></td>
  </tr>
<%}if(strSchCode.startsWith("CDD")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td><a href="./nstp_graduate_ul.jsp">NSTP Enrollment List</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right"></td>
    <td width="2%" align="center">&nbsp;</td>
    <td><a href="./nstp_graduate_ul.jsp?ched=1">NSTP Graduate - CHED</a></td>
  </tr>
<%}else if(strSchCode.startsWith("UC")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td><a href="./nstp_enrollment.jsp">NSTP Enrollment List</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right"></td>
    <td width="2%" align="center">&nbsp;</td>
    <td><a href="./nstp_graduate_philcst.jsp?ched=1">NSTP Graduate - CHED</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right"></td>
    <td width="2%" align="center">&nbsp;</td>
    <td><a href="./otr_print_track.jsp">OTR Print Information</a></td>
  </tr>
<%}else if(strSchCode.startsWith("UB")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td><a href="./nstp_graduate_philcst.jsp?ched=1">NSTP Graduate - CHED</a></td>
  </tr>
<%}else if(strSchCode.startsWith("SPC")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./assign_section.jsp">Assign Section</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right"> </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./spc/certificate_of_grade.jsp">Certification of Grade</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right"> </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./spc/deliberation_report.jsp">Deliberation Report</a></td>
  </tr>
<%}else if(strSchCode.startsWith("CIT")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./cit/enrollment_per_subject_offering.jsp">List of Subject with Pass/Fail status</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right"> </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./cit/all_failed_count.jsp">List of Subject with All Pass/ All Fail</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right"> </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./cit/pass_fail_statistics_per_faculty.jsp">Pass-Fail Statistics Per Faculty</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right"> </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./cit/final_grade_report_cit.jsp">Generate Final Grade In Batch</a></td>
  </tr>
<%}else if(strSchCode.startsWith("PHILCST")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./nstp_graduate_philcst.jsp">NSTP Graduate - CHED</a></td>
  </tr>
<%}else{
	if(strSchCode.startsWith("AUF")){%>
	  <tr> 
		<td width="12%" height="25">&nbsp;</td>
		<td width="15%" height="25" align="right">Operation : </td>
		<td width="2%" align="center">&nbsp;</td>
		<td width="71%"><a href="./grade_certification_auf.jsp">Grade Certification</a></td>
	  </tr>
	<%}else{%>
	  <tr> 
		<td width="12%" height="25">&nbsp;</td>
		<td width="15%" height="25" align="right">Operation : </td>
		<td width="2%" align="center">&nbsp;</td>
		<td width="71%"><a href="./capping_and_similar_report.jsp">
			<%if(strSchCode.startsWith("VMUF")){%>
				Check Graduating Student Potential for Licensure Exam
			<%}else{%>
				Capping/Pinning/Other similar report
			<%}%>
		</a></td>
	  </tr>
	<%}
}%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%">&nbsp;</td>
  </tr>
<%
//System.out.println(strSchCode);	
if( strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./rle_main.jsp">PRC RLE Report Requirement </a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./subject_deficiency.jsp">Subject Deficiency </a></td>
  </tr>
<%if(strSchCode.startsWith("CGH")){%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="../../residency/stud_cur_residency_eval_print_CGH.jsp">Evaluation for CHED</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./nstp_graduate.jsp">NSTP Graduate</a></td>
  </tr>
   <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./nstp_graduate.jsp?ched=1">NSTP Graduate - CHED</a></td>
  </tr>
 <tr>
    <td height="25" colspan="4">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./assign_section.jsp">Assign Section</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./grade_per_section.jsp">Grade per Section </a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="../../../HR/personnel/hr_cgh_201_file.jsp">Faculty Information Sheet</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="../../../guidance/good_moral_cert/cgh_certificate_main.jsp">Good moral Certification </a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./certification/main.jsp">Other Certifications</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./cgh/loa.jsp">Leave of Application</a></td>
  </tr>
<%}//end of CGH Specific 
}//if( strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC") || strUserId.equals("1770")){%>
<%if(strSchCode.startsWith("UDMC")){%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./eched_saci.jsp">eCHED Report</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="../../../guidance/good_moral_cert/udmc_certificate_main.jsp">Good moral Certification </a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./saci/completion_grade_encode_or.jsp">Completion Grade (Encoding of OR) </a></td>
  </tr>
<%}%>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td width="49%">&nbsp;</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td width="49%">&nbsp;</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25" width="1%">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></tr>
  <tr bgcolor="#A49A6A"> 
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>

</body>
</html>
