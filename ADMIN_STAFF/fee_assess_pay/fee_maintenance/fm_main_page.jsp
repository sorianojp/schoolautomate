<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#D2AE72">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        FEE MAINTENANCE MAIN PAGE ::::</strong></font></div></td>
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
<%
String strTemp = request.getParameter("operation");
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
String strLoggedInUser = (String)request.getSession(false).getAttribute("userId");
if(strLoggedInUser == null)
	strLoggedInUser = "";
if(strTemp == null) 
	strTemp = "";
if(strTemp.compareTo("1") == 0){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./copy_fee.jsp?operation=1">COPY 
        PREVIOUS TUITION FEE ENTRIES</a></div></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./fm_tution_fee.jsp">CREATE 
        NEW ENTRY</a></div></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./fm_tution_fee_replicate.jsp">REPLICATE 
        ENTRY </a></div></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./print_tuition_fee.jsp">PRINT 
        TUITION FEE</a></div></td>
  </tr>
<%}else if(strTemp.compareTo("2") == 0){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./copy_fee.jsp?operation=2">COPY 
        PREVIOUS MISCELLANEOUS ENTRIES</a></div></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./fm_misc_fee.jsp">CREATE 
        NEW ENTRY</a></div></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./fm_misc_fee_replicate.jsp">REPLICATE 
        ENTRY</a></div></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./print_misc_fee.jsp">PRINT 
        MISC FEE</a></div></td>
  </tr>
<%}else if(strTemp.compareTo("3") == 0){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./copy_fee.jsp?operation=3">COPY 
        PREVIOUS OTHER CHARGES ENTRIES</a></div></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./fm_misc_fee_other_charges.jsp">CREATE 
        NEW ENTRY</a></div></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./fm_misc_fee_oc_replicate.jsp">REPLICATE 
        ENTRY</a></div></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./print_misc_fee.jsp?oth_charge=1">PRINT 
        OTHER CHARGES</a></div></td>
  </tr>
<%}else if(strTemp.compareTo("4") == 0){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./copy_fee.jsp?operation=4">COPY 
        PREVIOUS OTHER SCHOOL FEE ENTRIES</a></div></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./fm_other_sch_fee.jsp">CREATE 
        NEW ENTRY</a></div></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./print_othsch_fee.jsp">PRINT OTHER SCHOOL FEES</a></div></td>
  </tr>
<%}else if(strTemp.compareTo("5") == 0){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./copy_fee.jsp?operation=5">COPY 
        PREVIOUS FEE ADJUSTMENT ENTRIES</a></div></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="../payment_maintenance/fee_adjustment_type.jsp">CREATE NEW ENTRY</a></div></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="../payment_maintenance/fee_adjustment_type_print.jsp">PRINT</a></div></td>
  </tr>
<%}else if(strTemp.compareTo("6") == 0){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./copy_fee.jsp?operation=6">COPY 
        PREVIOUS ENTRIES FOR EXCLUDED SUBJECT IN FEE ASSESSMENT</a></div></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./list_of_excluded_subjects.jsp">CREATE 
        NEW ENTRY</a></div></td>
  </tr>
<%}else if(strTemp.compareTo("7") == 0){
	if( !strSchoolCode.startsWith("UI") && !strSchoolCode.startsWith("AUF")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./copy_fee.jsp?operation=7">COPY 
        PREVIOUS ENTRIES FOR VARIABLE LOAD RATE</a></div></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./medicine_load_hours_rate.jsp">CREATE 
        NEW ENTRY FOR VARIABLE LOAD RATE</a></div></td>
  </tr>
  <%}else if(strSchoolCode != null){
  if(strSchoolCode.startsWith("AUF")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./medicine_load_hours_rate.jsp">CREATE 
        NEW ENTRY FOR VARIABLE UNIT RATE(Medicine)</a></div></td>
  </tr>
  <%}%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./variable_load_unit_rate.jsp">CREATE 
        NEW ENTRY FOR VARIABLE UNIT RATE(Non-medicine)</a></div></td>
  </tr>
<%	}
  }else if(strTemp.compareTo("8") == 0){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center">
	<!--<div align="left"><a href="./copy_fee.jsp?operation=8">COPY 
        PREVIOUS ENTRIES FOR BELOW MIN. STUD. ENROLLEES</a></div>--></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation :</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./below_min_stud_enrollees.jsp">CREATE 
        NEW ENTRY</a></div></td>
  </tr>
<%}%>

<%if(strSchoolCode.startsWith("CIT")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation :</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./manage_cit_syrange.jsp">Manage SY Range</a></div></td>
  </tr>
<%}%>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" width="1%">&nbsp;</td>
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
