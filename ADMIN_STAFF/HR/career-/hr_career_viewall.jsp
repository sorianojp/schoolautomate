<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Assessment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">

function AddRecord()
{
	alert("add record");
}

</script>
<body bgcolor="#663300">
<form action="" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CAREER EVALUATION SUMMARY ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25"><hr size="1">
        <table width="95%" border="0" align="center" cellpadding="5" cellspacing="0">
          <tr> 
            <td colspan="3">Show : 
              <select name="select3">
                <option>Teaching</option>
                <option>Non-Teaching</option>
                <option>All</option>
              </select></td>
            <td width="57%" colspan="3">&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="6">Order by : 
              <select name="select">
                <option value="1">Employee ID</option>
                <option value="2">Lastname</option>
                <option>Firstname</option>
                <option>Grand Total Score</option>
                <option value="3">Date of Evaluation</option>
              </select> <select name="select4">
                <option>Ascending</option>
                <option>Descending</option>
              </select>
              <select name="select6">
                <option value="1">Employee ID</option>
                <option value="2">Lastname</option>
                <option>Firstname</option>
                <option>Grand Total Score</option>
                <option value="3">Date of Evaluation</option>
              </select> 
              <select name="select5">
                <option>Ascending</option>
                <option>Descending</option>
              </select> </td>
          </tr>
          <tr> 
            <td colspan="3"><div align="right"><img src="../../../images/print.gif" ><font size="1">click 
                to print summary </font></div></td>
            <td colspan="3"><div align="right">Jump to Page : 
                <select name="select2">
                  <option>1 of 4</option>
                  <option>2 of 4</option>
                  <option>3 of 4</option>
                  <option>4 of 4</option>
                </select>
              </div></td>
          </tr>
		  </table>
		    
        <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
          <tr bgcolor="#CCCCCC"> 
            <td height="25" colspan="6"><div align="center"><strong><font color="#FF0000">LIST 
                OF ALL $SHOW EMPLOYEES</font></strong></div>
              <div align="center"></div></td>
          </tr>
          <tr> 
            <td width="13%" height="25"><div align="center"><strong>Employee ID </strong></div></td>
            <td width="29%"> <div align="center"><strong>Name</strong></div></td>
            <td width="22%" align="center"><strong>Evaluator</strong></td>
            <td width="17%" align="center"><strong>Date of Evaluation</strong></td>
            <td width="14%" align="center"><strong>Grand Total Score</strong></td>
            <td width="5%" align="center">&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td align="center">&nbsp;</td>
            <td align="center">&nbsp;</td>
            <td align="center">&nbsp;</td>
            <td align="center"><a href="../assessment/hr_assessment_teaching.jsp"> 
              </a><a href="hr_career_evaluation.jsp"><img src="../../../images/view.gif" border="0" ></a></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td align="center">&nbsp;</td>
            <td align="center">&nbsp;</td>
            <td align="center">&nbsp;</td>
            <td align="center"><a href="hr_career_evaluation.jsp"><img src="../../../images/view.gif" border="0" ></a></td>
          </tr>
        </table>
        
      </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3"><div align="center"><img src="../../../images/print.gif" ><font size="1">click 
          to print summary </font></div></td>
    </tr>
    <tr> 
      <td height="24"  colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>

