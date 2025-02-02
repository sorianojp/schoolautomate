<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<body bgcolor="#D2AE72">
<form action="" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INTERNET OTHER SERVICES - POST CHARGE PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="25%"><strong>Date :</strong> $date_now</td>
      <td width="36%"><strong>Time :</strong> $time_now</td>
      <td width="38%"> <strong>Attendant Name : $CURRENT_USER</strong></td>
    </tr>
    <tr> 
      <td height="29" colspan="4"><hr size="1" noshade> </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
      <td height="25"><strong>User ID :</strong></td>
      <td width="16%" height="25"> <input type="text" name="textfield2"></td>
      <td width="57%"><img src="../../images/form_proceed.gif"></td>
    </tr>
    <tr> 
      <td height="15" colspan="5"><hr size="1" noshade></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
      <td width="11%" height="25">User Name :<strong> </strong></td>
      <td height="25" colspan="2"><strong>$user_name</strong></td>
    </tr>
    <tr> 
      <td width="8%" height="15">&nbsp;</td>
      <td width="8%" height="15">&nbsp;</td>
      <td height="15">Computer Name :</td>
      <td height="15" colspan="2"><strong>$comp_name</strong></td>
    </tr>
    <tr> 
      <td height="15" colspan="5"><hr size="1" noshade></td>
    </tr>
  </table>
	  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="5%" height="15">&nbsp;</td>
      <td width="21%">Max. Usage : <strong>$max_usage</strong></td>
      <td width="34%" height="15">Remaining Time For This Session: <strong>$rem_time</strong></td>
      <td width="40%" height="15"><div align="left"><font color="#0000FF">TOTAL 
          HOUR(S) LEFT IN ACCOUNT : <strong>$total_hrs_left</strong></font></div></td>
    </tr>
    <tr> 
      <td height="15" colspan="4"><hr size="1" noshade></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="16%" height="25">&nbsp;</td>
      <td width="16%" height="25"><strong>Service Type Name</strong></td>
      <td height="25" colspan="2"> <select name="select2">
          <option>Printing</option>
          <option>Scanning</option>
          <option>Encoding</option>
        </select> <select name="select">
          <option>Black - Dot Matrix - Short</option>
          <option>Black - Dot Matrix - Long</option>
          <option>Black - Laser - Long</option>
          <option>Black - Laser - Short</option>
          <option>Colored Deskjet/Inkjet - Short</option>
          <option>Colored Deskjet/Inkjet - Long</option>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Fee Rate / Unit</strong></td>
      <td width="32%"><strong>$cost_per_page / $unit</strong></td>
      <td width="36%" height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Quantity </strong></td>
      <td><input name="textfield" type="text" size="4" maxlength="4"></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Amount Due </strong></td>
      <td><strong>$TOT_AMOUNT</strong></td>
      <td height="25">&nbsp; </td>
    </tr>
    <tr> 
      <td height="15" colspan="4"><hr size="1" noshade></td>
    </tr>
    <tr> 
      <td height="49">&nbsp;</td>
      <td height="49" colspan="2"><font size="1"><img src="../../images/save.gif">click 
        to save entries/changes <img src="../../images/cancel.gif">click to cancel/clear 
        entries </font></td>
      <td height="49"><div align="right"><font size="1"><img src="../../images/cancel.gif">click 
          to print list </font></div></td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" >
    <tr bgcolor="#FFFF9F"> 
      <td height="34" colspan="8"><div align="center"><font color="#0000FF">LIST 
          OF INTERNET OTHER SERVICE CHARGES POSTED FOR USER $user_name (SY $school_year, 
          $term) </font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="10%"><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>SERVICE 
          TYPE CODE</strong></font></div></td>
      <td width="12%"><div align="center"><font color="#000000"><strong><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>SERVICE 
          TYPE NAME</strong></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font></strong></font></div></td>
      <td width="17%"><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>SERVICE 
          SUB-TYPE NAME</strong></font><font color="#000000"><strong></strong></font></div></td>
      <td width="12%"><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>FEE 
          RATE/ UNIT</strong></font></div></td>
      <td width="8%"><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>QTY</strong></font></div></td>
      <td width="10%"><div align="center"><font color="#000000"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">AMOUNT 
          DUE </font></strong></font></div></td>
      <td width="22%"><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>CHARGE 
          POSTED BY</strong></font></div></td>
      <td width="9%" height="24">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right">&nbsp;<img src="../../images/edit.gif"> <img src="../../images/delete.gif"></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

</form>
</body>
</html>
