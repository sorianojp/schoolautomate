<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="file:///D|/ApacheTomcat4.1.31/webapps/lms_redesigned/css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#D0E19D">
<form>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#77A251"> 
      <td height="25" colspan="3" bgcolor="#77A251"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CIRCULATION : REPORTS : CIRCULATION BY BORROWERS GROUPS BY COLLECTION 
          SECTION PAGE ::::</strong></font></div></td>
    </tr>
    <tr valign="top"> 
      <td height="42" colspan="3"><a href="reports_main.jsp"><img src="../../images/goback_circulation.gif" width="54" height="29" border="0"></a></td>
    </tr>
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td width="14%">School Year</td>
      <td width="80%"><input name="textfield" type="text" size="4" maxlength="4">
        to 
        <input name="textfield2" type="text" size="4" maxlength="4"> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Frequency of Report</td>
      <td><font size="1"> 
        <select name="select2">
          <option>Daily</option>
          <option>Weekly</option>
          <option>Monthly</option>
          <option>Semestral</option>
          <option>Annual</option>
        </select>
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><input name="textfield3" type="text" size="10" maxlength="10"> <img src="../../images/calendar_new.gif" width="20" height="16"> 
        &lt;daily - specific date&gt;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><input name="textfield32" type="text" size="10" maxlength="10"> <img src="../../images/calendar_new.gif" width="20" height="16"> 
        to 
        <input name="textfield322" type="text" size="10" maxlength="10"> <img src="../../images/calendar_new.gif" width="20" height="16"> 
        &lt;weekly - specify the date of the week&gt;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><select name="select3">
          <option>January</option>
          <option>February</option>
          <option>March</option>
          <option>April</option>
          <option>May</option>
          <option>June</option>
          <option>July</option>
          <option>August</option>
          <option>September</option>
          <option>October</option>
          <option>November</option>
          <option>December</option>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><select name="select">
          <option>ALL</option>
          <option>1st Sem</option>
          <option>2nd Sem</option>
          <option>3rd Sem</option>
          <option>Summer</option>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><select name="select4">
          <option>2000</option>
          <option>2001</option>
          <option>2002</option>
          <option>2003</option>
        </select></td>
    </tr>
    <tr>
      <td height="42">&nbsp;</td>
      <td>&nbsp;</td>
      <td><img src="../../images/form_proceed.gif" width="81" height="21"></td>
    </tr>
    <tr> 
      <td height="42">&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><img src="../../images/print_circulation.gif" width="60" height="29"><font size="1">click 
          to print report</font></div></td>
    </tr>
    <tr bgcolor="#4BBA45"> 
      <td height="25" colspan="3"> <div align="center"><font color="#FFFFFF">CIRCULATION 
          BY BORROWERS GROUPS BY COLLECTION SECTION: <strong>$frequency_report 
          : $specific_value &lt;DAILY : 10/10/2005&gt;</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="12">NOTE TO THE PROGRAMMER : You get the value 
        for SECTIONS in the field BOOK LOCATION NAME in the Cataloging.</td>
    </tr>
    <tr> 
      <td width="12%" height="25"><div align="center"><strong><font size="1">SECTION 
          /BORROWERS GROUP</font></strong></div></td>
      <td width="4%"><div align="center"><strong><font size="1">ADMINISTRATION</font></strong></div></td>
      <td width="9%"><div align="center"><strong><font size="1">FACULTY</font></strong></div></td>
      <td width="15%" height="25"><div align="center"><strong><font size="1">EDUCATION</font></strong></div></td>
      <td width="7%" height="25"><div align="center"><strong><font size="1">ARTS 
          &amp; SCIENCES</font></strong></div></td>
      <td width="7%" height="25"><div align="center"><strong><font size="1">NURSING</font></strong></div></td>
      <td width="6%"><div align="center"><strong><font size="1">ENGINEERING</font></strong></div></td>
      <td width="6%"><div align="center"><strong><font size="1">CRIMINOLOGY</font></strong></div></td>
      <td width="6%"><div align="center"><font size="1"><strong>GRADUATE SCHOOL</strong></font></div></td>
      <td width="6%"><div align="center"><font size="1"><strong>SPECIAL MEMBERS</strong></font></div></td>
      <td width="6%"><div align="center"><font size="1"><strong>OUTSIDE RESERACHERS</strong></font></div></td>
      <td width="16%"><div align="center"><font size="1"><strong>TOTAL</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1">CIRCULATION</font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1">RESERVE</font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1">GEN. REF</font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1">FILIPINIANA</font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1">PERIODICALS</font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1">GRADUATE SCHOOL</font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1">ENGINEERING</font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1">LAW</font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1">AV COLLECTION</font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1">OTHERS</font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="left"><strong>TOTAL</strong></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><strong>TOTAL MEMBERS</strong> </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><strong>AVERAGE</strong> </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><strong>% OF USERS</strong> </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
