<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="file:///D|/ApacheTomcat4.1.31/webapps/lms_redesigned/css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#DEC9CC">
<form>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING : REPORTS - PROCESSED COLLECTION BY SUBJECT AREA ::::</strong></font></div></td>
    </tr>
    <tr valign="top"> 
      <td height="42" colspan="3"><font size="1"><font size="1"><a href="main_page.jsp" target="_self"><img src="file:///D|/ApacheTomcat4.1.31/webapps/lms_redesigned/images/go_back.gif" border="0" ></a></font></font
        ></td>
    </tr>
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td width="14%">Year</td>
      <td width="80%"> <select name="select4">
          <option>2000</option>
          <option>2001</option>
          <option>2002</option>
          <option>2003</option>
        </select> </td>
    </tr>
    <tr> 
      <td height="42">&nbsp;</td>
      <td>&nbsp;</td>
      <td><img src="file:///D|/ApacheTomcat4.1.31/webapps/lms_redesigned/images/form_proceed.gif" width="81" height="21"></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td height="20"><div align="right"><font size="1"><a href="file:///D|/ApacheTomcat4.1.31/webapps/lms_redesigned/circulation/reports/subject_card_print.htm" target="_blank"><img src="file:///D|/ApacheTomcat4.1.31/webapps/lms_redesigned/images/print.gif" border="0" ></a></font
        ><font size="1">click to print report</font></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="20%" height="25"><strong><font size="1">SUBJECT AREA</font></strong></td>
      <td width="6%" height="25"><div align="center"><font size="1"><strong>JNE</strong></font></div></td>
      <td width="6%" height="25"><div align="center"><font size="1"><strong>JLY</strong></font></div></td>
      <td width="6%" height="25"><div align="center"><font size="1"><strong>AUG</strong></font></div></td>
      <td width="6%" height="25"><div align="center"><font size="1"><strong>SEPT</strong></font></div></td>
      <td width="6%" height="25"><div align="center"><font size="1"><strong>OCT</strong></font></div></td>
      <td width="6%" height="25"><div align="center"><font size="1"><strong>NOV</strong></font></div></td>
      <td width="6%" height="25"><div align="center"><font size="1"><strong>DEC</strong></font></div></td>
      <td width="6%" height="25"><div align="center"><font size="1"><strong>JAN</strong></font></div></td>
      <td width="6%" height="25"><div align="center"><font size="1"><strong>FEB</strong></font></div></td>
      <td width="6%" height="25"><div align="center"><font size="1"><strong>MAR</strong></font></div></td>
      <td width="6%" height="25"><div align="center"><font size="1"><strong>APR</strong></font></div></td>
      <td width="6%" height="25"><div align="center"><font size="1"><strong>MAY</strong></font></div></td>
      <td width="8%" height="25"><div align="center"><font size="1"><strong>YEAR 
          TOT</strong></font></div></td>
    </tr>
    <%
	for(int i = 0; i< strBNumStWith.length; ++i) //for Sub category range 000 to 099
	{
			aiResult = report.getPBookBySCatg(strBNumStWith[i], iYearFrom);
			if(report.getErrMsg() != null)
			{
				dbOP.cleanUP();
				%>
    <p> <%=report.getErrMsg()%></p>
    <%
				return;
			}
		
			for(int j = 0; j< 12; ++j)
			{
				aiMonthlyTot[j] += aiResult[j];
				iYearTotal += aiResult[j];
			}%>
    <tr> 
      <td height="25">000</td>
      <td height="25"><%=aiResult[6]%></td>
      <td height="25"><%=aiResult[7]%></td>
      <td height="25"><%=aiResult[8]%></td>
      <td height="25"><%=aiResult[9]%></td>
      <td height="25"><%=aiResult[10]%></td>
      <td height="25"><%=aiResult[11]%></td>
      <td height="25"><%=aiResult[0]%></td>
      <td height="25"><%=aiResult[1]%></td>
      <td height="25"><%=aiResult[2]%></td>
      <td height="25"><%=aiResult[3]%></td>
      <td height="25"><%=aiResult[4]%></td>
      <td height="25"><%=aiResult[5]%></td>
      <td height="25"><%=iYearTotal%></td>
    </tr>
    <%
		iYearTotal = 0;
		} //end of for loop to display complete report.
		
		//display here the fictoin type - Means the book classification number starts with other than number.
			aiResult = report.getPBookBySCatg(null,iYearFrom);
			iYearTotal = 0;
			if(report.getErrMsg() != null)
			{
				dbOP.cleanUP();
				%>
    <p> <%=report.getErrMsg()%> 
      <%
				return;
			}
			for(int j = 0; j< 12; ++j)
			{
				aiMonthlyTot[j] += aiResult[j];
				iYearTotal += aiResult[j];
			}%>
    <tr> 
      <td height="25">100</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">200</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">300</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">400</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">500</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">600</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">700</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">800</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">900</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">Filipiniana</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">Fiction</td>
      <td height="25"><%=aiResult[6]%></td>
      <td height="25"><%=aiResult[7]%></td>
      <td height="25"><%=aiResult[8]%></td>
      <td height="25"><%=aiResult[9]%></td>
      <td height="25"><%=aiResult[10]%></td>
      <td height="25"><%=aiResult[11]%></td>
      <td height="25"><%=aiResult[0]%></td>
      <td height="25"><%=aiResult[1]%></td>
      <td height="25"><%=aiResult[2]%></td>
      <td height="25"><%=aiResult[3]%></td>
      <td height="25"><%=aiResult[4]%></td>
      <td height="25"><%=aiResult[5]%></td>
      <td height="25"><%=iYearTotal%></td>
    </tr>
    <%
		//display here monthly total.
		iYearTotal = 0;
		for(int j = 0 ; j<12; ++j)
			iYearTotal += aiMonthlyTot[j];
		%>
    <tr> 
      <td height="25"><strong>TOTAL</strong></td>
      <td height="25"><B><%=aiMonthlyTot[6]%></b></td>
      <td height="25"><B><%=aiMonthlyTot[7]%></b></td>
      <td height="25"><B><%=aiMonthlyTot[8]%></b></td>
      <td height="25"><B><%=aiMonthlyTot[9]%></b></td>
      <td height="25"><B><%=aiMonthlyTot[10]%></b></td>
      <td height="25"><B><%=aiMonthlyTot[11]%></b></td>
      <td height="25"><B><%=aiMonthlyTot[0]%></b></td>
      <td height="25"><B><%=aiMonthlyTot[1]%></b></td>
      <td height="25"><B><%=aiMonthlyTot[2]%></b></td>
      <td height="25"><B><%=aiMonthlyTot[3]%></b></td>
      <td height="25"><B><%=aiMonthlyTot[4]%></b></td>
      <td height="25"><B><%=aiMonthlyTot[5]%></b></td>
      <td height="25"><B><%=iYearTotal%></b></td>
    </tr>
  </table>
</form>
</body>
</html>
