<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsUB = strSchCode.startsWith("UB");
boolean bolIsCIT = strSchCode.startsWith("CIT");
%>
<body bgcolor="#F2DFD2">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING REPORTS MAIN PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="26%" height="25">&nbsp;</td>
      <td width="50%" valign="top">&nbsp;</td>
      <td width="24%">&nbsp;</td>
    </tr>
	 <tr>
      <td height="25"><div align="right"><font size="3">&raquo;&raquo;</font></div></td>
      <td><div align="center"><a href="./book_distribution_per_course.jsp"><font color="#FF0000">Book Distribution Per Course</font></a></div></td>
      <td><font size="3">&laquo;&laquo;</font></td>
    </tr>
<%
if(bolIsUB){
%>	
	<tr>
      <td height="25"><div align="right"><font size="3">&raquo;&raquo;</font></div></td>
      <td><div align="center"><a href="./periodical_report.jsp"><font color="#FF0000">Periodical Report</font></a></div></td>
      <td><font size="3">&laquo;&laquo;</font></td>
    </tr>
<%}%>	
    <tr>
      <td height="25"><div align="right"><font size="3">&raquo;&raquo;</font></div></td>
      <td><div align="center"><a href="./generic_card_report.jsp?report_type=1"><font color="#FF0000">Bibliography 
        Report</font></a></div></td>
      <td><font size="3">&laquo;&laquo;</font></td>
    </tr>
    
    <tr> 
      <td height="25"><div align="right"><font size="3">&raquo;&raquo;</font></div></td>
      <td height="25"><div align="center"><a href="./generic_card_report.jsp?report_type=2"><font color="#FF0000">Shelf 
          List</font></a></div></td>
      <td height="25"><font size="3">&laquo;&laquo;</font></td>
    </tr>
    <tr> 
      <td height="25"><div align="right"><font size="3">&raquo;&raquo;</font></div></td>
      <td height="25"><div align="center"><a href="./generic_card_report.jsp?report_type=3"><font color="#FF0000">Author 
          Card</font></a></div></td>
      <td height="25"><font size="3">&laquo;&laquo;</font></td>
    </tr>
    <tr> 
      <td height="25"><div align="right"><font size="3">&raquo;&raquo;</font></div></td>
      <td height="25"><div align="center"><a href="./generic_card_report.jsp?report_type=4"><font color="#FF0000">Subject 
          Card</font></a></div></td>
      <td height="25"><font size="3">&laquo;&laquo;</font></td>
    </tr>
    <tr> 
      <td height="25"><div align="right"><font size="3">&raquo;&raquo;</font></div></td>
      <td height="25"><div align="center"><a href="./generic_card_report.jsp?report_type=5"><font color="#FF0000">Title 
          Card</font></a></div></td>
      <td height="25"><font size="3">&laquo;&laquo;</font></td>
    </tr>
    <tr> 
      <td height="25"><div align="right"><font size="3">&raquo;&raquo;</font></div></td>
      <td height="25"><div align="center"><a href="pro_col_by_material_type.jsp" target="_self"><font color="#FF0000">Processed 
          Collection by Material Type</font></a></div></td>
      <td height="25"><font size="3">&laquo;&laquo;</font></td>
    </tr>
<!--
    <tr> 
      <td height="25" valign="top"><div align="right"><font size="3">&raquo;&raquo;</font></div></td>
      <td height="25"><div align="center"><a href="pro_col_by_subject_area.jsp" target="_self"><font color="#FF0000">Processed 
          Collection by Subject Area/Classification</font></a></div></td>
      <td height="25"><font size="3"> &laquo;&laquo;</font></td>
    </tr>
-->
    <tr>
      <td height="25" valign="top"><div align="right"><font size="3">&raquo;&raquo;</font></div></td>
      <td height="25"><div align="center"><a href="./collection_status.jsp" target="_self"><font color="#FF0000">Per Book Collection Status </font></a></div></td>
      <td height="25"><font size="3"> &laquo;&laquo;</font></td>
    </tr>
<%if(false){%>
    <tr>
      <td height="25" valign="top"><div align="right"><font size="3">&raquo;&raquo;</font></div></td>
      <td height="25"><div align="center"><a href="./inventory_complete.jsp" target="_self"><font color="#FF0000">Complete Inventory</font></a> - not yet done.. </div></td>
      <td height="25"><font size="3"> &laquo;&laquo;</font></td>
    </tr>
<%}%>
    <tr> 
      <td colspan="3"><hr size="1" color="#CC9966"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td align="center"><u><b>For Printing Only</b></u> </td>
      <td>&nbsp;</td>
    </tr>
<!--
    <tr>
      <td height="25" align="right"><font size="3">&raquo;&raquo;</font></td>
      <td align="center"><a href="./inventory_complete.jsp" target="_self"><font color="#FF0000">Encode Card Type</font></a></td>
      <td><font size="3">&laquo;&laquo;</font></td>
    </tr>
-->
    <tr>
      <td height="25" align="right"><font size="3">&raquo;&raquo;</font></td>
      <td align="center"><a href="./card_print_info.jsp" target="_self"><font color="#FF0000">Encode Card Information</font></a></td>
      <td><font size="3">&laquo;&laquo;</font></td>
    </tr>
<%
if(bolIsCIT){
%>
	<tr>
      <td height="25" align="right"><font size="3">&raquo;&raquo;</font></td>
      <td align="center"><a href="./create_report.jsp" target="_self"><font color="#FF0000">Create Report</font></a></td>
      <td><font size="3">&laquo;&laquo;</font></td>
    </tr>
<%}%>
  </table>
</body>
</html>
