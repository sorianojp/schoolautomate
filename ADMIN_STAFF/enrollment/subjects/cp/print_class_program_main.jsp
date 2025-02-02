<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#D2AE72">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A" align="center"><font color="#FFFFFF" ><strong>::::
        CLASS PROGRAM PRINTING MAIN PAGE ::::</strong></font></td>
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
<%if(strSchCode.startsWith("CDD")){%>
	  <tr> 
		<td width="12%" height="25">&nbsp;</td>
		<td width="15%" height="25" align="right">Operation : </td>
		<td width="2%">&nbsp;</td>
		<td width="71%"><a href="./class_time_sched_cdd.jsp?print_type=1">Class Time Schedule</a></td>
	  </tr>
	  <tr> 
		<td width="12%" height="25">&nbsp;</td>
		<td width="15%" height="25">&nbsp;</td>
		<td width="2%">&nbsp;</td>
		<td width="71%"><a href="./class_time_sched_cdd.jsp?print_type=2">Schedule Per Section</a></td>
	  </tr>
<%}else if(strSchCode.startsWith("UB")){%>
	  <tr> 
		<td width="12%" height="25">&nbsp;</td>
		<td width="15%" height="25" align="right">Operation : </td>
		<td width="2%">&nbsp;</td>
		<td width="71%">
			<a href="./print_per_college_dept_offering.jsp">Print Class Program Per College/Dept Offering</a>
		</td>
	  </tr>
<%}else if(strSchCode.startsWith("SWU")){%>
	  <tr> 
		<td width="12%" height="25">&nbsp;</td>
		<td width="15%" height="25" align="right">Operation : </td>
		<td width="2%">&nbsp;</td>
		<td width="71%">
			<a href="./print_per_college_dept_offering_SWU2.jsp">Print Class Program Per College/Dept Offering - Version 1</a>
		</td>
	  </tr>
	  <tr> 
		<td width="12%" height="25">&nbsp;</td>
		<td width="15%" height="25" align="right"> </td>
		<td width="2%">&nbsp;</td>
		<td width="71%">
			<a href="./print_per_college_dept_offering_SWU.jsp">Print Class Program Per College/Dept Offering - Version 2</a>
		</td>
	  </tr>
	  <tr> 
		<td width="12%" height="25">&nbsp;</td>
		<td width="15%" height="25" align="right"> </td>
		<td width="2%">&nbsp;</td>
		<td width="71%">
			<a href="../print_class_program.jsp">Print Class Program Per Section (old format)</a>
		</td>
	  </tr>
<%}else{%>
	<%if(strSchCode.startsWith("CIT")){%>
	  <tr> 
		<td width="12%" height="25">&nbsp;</td>
		<td width="15%" height="25" align="right">Operation : </td>
		<td width="2%">&nbsp;</td>
		<td width="71%">
			<a href="./print_per_college_dept_offering.jsp">Print Class Program Per College/Dept Offering</a>
		</td>
	  </tr>
	  <tr> 
		<td width="12%" height="25">&nbsp;</td>
		<td width="15%" height="25">&nbsp;</td>
		<td width="2%">&nbsp;</td>
		<td width="71%">&nbsp;</td>
	  </tr>
	<%}%>
	  <tr>
		<td height="25">&nbsp;</td>
		<td height="25">&nbsp;</td>
		<td>&nbsp;</td>
		<td><a href="./print_cp_plotted_main.jsp">Print Plotted Class Program(Per Section) </a></td>
	  </tr>
	
	  <tr>
		<td height="25">&nbsp;</td>
		<td height="25">&nbsp;</td>
		<td>&nbsp;</td>
		<td><a href="./print_plotted_room_assignment_main.jsp">Print Plotted Class Program(Per Room)</a></td>
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
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></tr>
  <tr bgcolor="#A49A6A"> 
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>

</body>
</html>
