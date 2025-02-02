<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/maintenancelinkscss.css" rel="stylesheet" type="text/css">
</head>

<body >
<form>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="2"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">SAN 
          PEDRO COLLEGE<br>
          Davao City</font> </div></td>
    </tr>
    <tr>
      <td height="10"  colspan="2"><div align="center"><strong><%=request.getParameter("c_name")%></strong></div></td>
    </tr>
    <tr> 
      <td  colspan="2" width="3%"><div align="center"><strong><%=request.getParameter("e_period")%></strong></div></td>
    </tr>
    <tr> 
      <td colspan="2"><div align="center"><strong><%=request.getParameter("month")%> &nbsp;</strong><strong><%=request.getParameter("year")%></strong></div></td>
    </tr>
  </table>
	
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="20" colspan="2"><div align="center"><strong><%=request.getParameter("sub_code")%> 
          - <%=request.getParameter("sub_name")%></strong></div></td>
    </tr>
    <tr> 
      <td height="20"><strong>INSTRUCTOR(S):</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="34%" height="20">$instructor_name1</td>
      <td width="66%">$instructor_name6</td>
    </tr>
    <tr> 
      <td height="20"> $instructor_name2 </td>
      <td> $instructor_name7</td>
    </tr>
    <tr> 
      <td height="20">$instructor_name3 </td>
      <td>$instructor_name8</td>
    </tr>
    <tr> 
      <td width="34%">$instructor_name4</td>
      <td> $instructor_name9</td>
    </tr>
    <tr> 
      <td> $instructor_name5</td>
      <td>$instructor_name10</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="5">Examination Duration : <strong><%=request.getParameter("duration")%></strong></td>
    </tr>
    <tr>
      <td colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="5"><strong>TEST I. $first_question_type.&lt;instruction&gt;</strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td width="4%">&nbsp;</td>
      <td width="10%">$question_num.</td>
      <td colspan="3">$question</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td colspan="3">$question</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td colspan="3">$question</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td colspan="3">$question</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="5"><strong>TEST II. $second_question_type.&lt;instruction&gt;</strong></td>
    </tr>
    <tr> 
      <td colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td colspan="3">$question</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td width="31%">a. $choice1</td>
      <td colspan="2">d. $choice4</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>b. $choice2</td>
      <td colspan="2">e. $choice5</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>c. $choice3</td>
      <td colspan="2">f. $choice6</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td colspan="3">$question</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td width="31%">a. $choice1</td>
      <td colspan="2">d. $choice4</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>b. $choice2</td>
      <td colspan="2">e. $choice5</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>c. $choice3</td>
      <td colspan="2">f. $choice6</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td colspan="3">$question</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td width="31%">a. $choice1</td>
      <td colspan="2">d. $choice4</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>b. $choice2</td>
      <td colspan="2">e. $choice5</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>c. $choice3</td>
      <td colspan="2">f. $choice6</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="5"><strong>TEST III. $third_question_type.&lt;instruction&gt;</strong></td>
    </tr>
    <tr> 
      <td colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="5">Set A.</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>COLUMN A</td>
      <td colspan="2">COLUMN A</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item1 </td>
      <td width="3%">A.</td>
      <td width="52%">$column_B_item1 </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item2</td>
      <td>A.</td>
      <td>$column_B_item2</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item3</td>
      <td>A.</td>
      <td>$column_B_item3</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item4</td>
      <td>A.</td>
      <td>$column_B_item4</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item5</td>
      <td width="3%">A.</td>
      <td width="52%">$column_B_item5</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item6</td>
      <td>A.</td>
      <td>$column_B_item6</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item3</td>
      <td>A.</td>
      <td>$column_B_item7</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item8</td>
      <td>A.</td>
      <td>$column_B_item8</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item9</td>
      <td>A.</td>
      <td>$column_B_item9</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item10</td>
      <td>A.</td>
      <td>$column_B_item10</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="5">Set B.</td>
    </tr>
    <tr> 
      <td colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item1 </td>
      <td width="3%">A.</td>
      <td width="52%">$column_B_item1 </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item2</td>
      <td>A.</td>
      <td>$column_B_item2</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item3</td>
      <td>A.</td>
      <td>$column_B_item3</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item4</td>
      <td>A.</td>
      <td>$column_B_item4</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item5</td>
      <td width="3%">A.</td>
      <td width="52%">$column_B_item5</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item6</td>
      <td>A.</td>
      <td>$column_B_item6</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item3</td>
      <td>A.</td>
      <td>$column_B_item7</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item8</td>
      <td>A.</td>
      <td>$column_B_item8</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item9</td>
      <td>A.</td>
      <td>$column_B_item9</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item10</td>
      <td>A.</td>
      <td>$column_B_item10</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="5">Set C.</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item1 </td>
      <td width="3%">A.</td>
      <td width="52%">$column_B_item1 </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item2</td>
      <td>A.</td>
      <td>$column_B_item2</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item3</td>
      <td>A.</td>
      <td>$column_B_item3</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item4</td>
      <td>A.</td>
      <td>$column_B_item4</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item5</td>
      <td width="3%">A.</td>
      <td width="52%">$column_B_item5</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item6</td>
      <td>A.</td>
      <td>$column_B_item6</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item3</td>
      <td>A.</td>
      <td>$column_B_item7</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item8</td>
      <td>A.</td>
      <td>$column_B_item8</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item9</td>
      <td>A.</td>
      <td>$column_B_item9</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td>$column_A_item10</td>
      <td>A.</td>
      <td>$column_B_item10</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="5"><strong>TEST IV. $fourth_question_type.&lt;instruction&gt;</strong></td>
    </tr>
    <tr> 
      <td colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td colspan="3">$question</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>($points)</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>$question_num.</td>
      <td colspan="3">$question</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">($points)</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
    </tr>
  </table>
 </form>
</body>
</html>
