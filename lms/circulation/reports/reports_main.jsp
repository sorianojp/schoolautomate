<%

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#D0E19D">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#77A251"> 
      <td height="30" colspan="4" bgcolor="#77A251"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CIRCULATION : REPORTS MAIN PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="20" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="30" width="20%">&nbsp;</td>
      <td width="77%"><a href="./accountability_summary.jsp" target="_self"><font color="#804040">Accountability Summary </font></a></td>
      <td width="3%">&nbsp;</td>
    </tr>
    
    <tr> 
      <td height="30">&nbsp;</td>
      <td><a href="./overdue_summary.jsp"><font color="#804040">Borrowing/ Overdue 
        Summary</font></a></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td><a href="collection_usage_summary_new.jsp"><font color="#804040">Collection Usage Summary </font></a></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td><a href="circ_by_borrowers_group_by_subject_area.jsp"><font color="#804040">Circulation by Borrowers Group by Subject Area</font></a></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td><a href="circ_by_borrowers_group_by_collection_section.jsp" target="_self"><font color="#804040">Circulation by Borrowers Group by Collection Section</font></a></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td><a href="circ_by_collection_section_by_subject_area.jsp" target="_self"><font color="#804040">Circulation by Collection Section by Subject Area</font></a> </td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td><a href="circ_by_borrowers_group_yearly.jsp" target="_self"><font color="#804040">Circulation Summary by Borrowers Group (Annual)</font></a></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td><a href="circ_by_subject_group_yearly.jsp" target="_self"><font color="#804040">Circulation Summary by Subject Group (Annual)</font></a></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td><a href="circ_by_borrowers_group_monthly.jsp" target="_self"><font color="#804040">Circulation Summary by Borrowers Group (Monthly)</font></a></td>
      <td>&nbsp;</td>
    </tr>
	
    <tr> 
      <td height="30">&nbsp;</td>
      <td><a href="./circ_by_subject_group_monthly.jsp" target="_self"><font color="#804040">Circulation Summary by Subject Group (Monthly)</font></a></td>
      <td>&nbsp;</td>
    </tr>
	<%if(strSchCode.startsWith("CIT")){%>
	<tr> 
      <td height="30">&nbsp;</td>
      <td><a href="statistics_per_program_CIT.jsp" target="_self"><font color="#804040">Statistics per program</font></a></td>
      <td>&nbsp;</td>
    </tr>
	
	<tr> 
      <td height="30">&nbsp;</td>
      <td><a href="attendance_statistics_per_program_cit.jsp" target="_self"><font color="#804040">Attendance Statistics per Program</font></a></td>
      <td>&nbsp;</td>
    </tr>
	
	<tr> 
      <td height="30">&nbsp;</td>
      <td><a href="borrowing_statistics_cit.jsp" target="_self"><font color="#804040">Borrowing Statistics</font></a></td>
      <td>&nbsp;</td>
    </tr>
	<tr> 
      <td height="30">&nbsp;</td>
      <td><a href="view_patron_type.jsp" target="_self"><font color="#804040">View Patron by Type</font></a></td>
      <td>&nbsp;</td>
    </tr>
	<%}%>

  </table>
</body>
</html>
