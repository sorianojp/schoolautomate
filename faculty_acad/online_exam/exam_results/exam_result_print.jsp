<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/maintenancelinkscss.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function AddRecord()
{
	document.question.addRecord.value =1;
	document.question.reloadPage.value =0;
	
}
function ReloadPage()
{
	document.question.addRecord.value =0;
	document.question.reloadPage.value =1;
	
	document.question.submit();
	
}



</script>
<body >
		<form name="question" method="post" action="../../ADMISSION%20MAINTENANCE%20MODULE/one%20files/QUESTION%20BANK/./admission_question_add.jsp">
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">SAN 
          PEDRO COLLEGE<br>
          Davao City</font> </div></td>
    </tr>
    <tr> 
      <td height="10"  colspan="4"><div align="center"><font size="1">$college_name</font></div></td>
    </tr>
    <tr> 
      <td  colspan="4"><div align="center"><font size="1"><strong>$exam_period</strong></font></div></td>
    </tr>
    <tr> 
      <td colspan="4"><div align="center"><font size="1">&lt;month&gt;&lt; year&gt;</font></div></td>
    </tr>
    <tr> 
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td width="11%"><font size="1">Subject code</font></td>
      <td width="38%"><font size="1"><strong>$subject_code</strong></font></td>
      <td width="9%"><font size="1">Room #</font></td>
      <td width="42%"><font size="1"><strong>#room_number</strong></font></td>
    </tr>
    <tr> 
      <td><font size="1">Description</font></td>
      <td><font size="1"><strong>$subject_desc</strong></font></td>
      <td><font size="1">Exam Date</font></td>
      <td><font size="1"><strong>$exam_date</strong></font></td>
    </tr>
    <tr> 
      <td><font size="1">Section</font></td>
      <td><font size="1"><strong>$section</strong></font></td>
      <td><font size="1">Exam Time</font></td>
      <td><font size="1"><strong>$exam_time</strong></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDBCC"> 
      <td height="20" colspan="2"><div align="center"><font size="1">EXAMINATION 
          RESULT</font></div></td>
    </tr>
    <tr> 
      <td width="71%" height="25" bgcolor="#FFFFFF"><font size="1">TOTAL POINTS 
        FOR THIS EXAM : <strong>$total_points</strong></font></td>
      <td width="29%" height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
	
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="12%" height="21" rowspan="2"><div align="center"><font size="1">STUDENT 
          ID</font></div></td>
      <td width="23%" rowspan="2"><div align="center"><font size="1">STUDENT NAME</font></div></td>
      <td width="30%" rowspan="2"><div align="center"><font size="1">COURSE/MAJOR</font></div></td>
      <td width="5%" rowspan="2"><div align="center"><font size="1">YEAR</font></div></td>
      <td colspan="5" width="20%"><div align="center"><font size="1">SCORE</font></div></td>
      <td width="5%" rowspan="2"><div align="center"><font size="1">TOTAL SCORE</font></div></td>
      <td width="5%" rowspan="2"><div align="center"><font size="1">PERCENT-AGE 
          (%) </font></div></td>
    </tr>
    <tr> 
      <td width="4%"><div align="center">I</div></td>
      <td width="4%"><div align="center">II</div></td>
      <td width="4%"><div align="center">III</div></td>
      <td width="4%"><div align="center">IV</div></td>
      <td width="4%"><div align="center">V</div></td>
    </tr>
    <tr> 
      <td height="25"><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="71%" height="25"><font size="1">TOTAL STUDENTS TAKING THIS EXAM 
        : <strong>$total_number_students</strong></font></td>
      <td width="29%">&nbsp;</td>
    </tr>
  </table>


  </form>
</body>
</html>
