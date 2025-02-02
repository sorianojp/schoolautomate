<%
utility.WebInterface WI = new utility.WebInterface(request);
utility.DBOperation dbOP = new utility.DBOperation(-1);
String strErrMsg = null;
String strTemp = null;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript">
function ShowDetail(strPrintStat) {
	location = "./gen_journal_bir_print.jsp?show_detail="+strPrintStat+
	"&jv_month="+document.form_.jv_month[document.form_.jv_month.selectedIndex].value+
	"&jv_year="+document.form_.jv_year[document.form_.jv_year.selectedIndex].value+
	"&rows_per_pg="+document.form_.rows_per_pg[document.form_.rows_per_pg.selectedIndex].value;
}
</script>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="gen_journal_1st_page.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A" align="center"><font color="#FFFFFF">
	  <strong>:::: GENERAL JOURNAL PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="26">&nbsp;</td>
      <td width="12%" style="font-size:11px;">Month / Year </td>
      <td width="85%">
        <select name="jv_month">
          <%=dbOP.loadComboMonth(WI.fillTextValue("jv_month"))%>
        </select>
        <select name="jv_year">
          <%=dbOP.loadComboYear(WI.fillTextValue("jv_year"),5,1)%>
        </select>
	  </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" style="font-size:11px;">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="15%" height="25">&nbsp;</td>
      <td width="85%" height="25">Number of rows Per page : 
	  	<select name="rows_per_pg">
	  	<%
		int iDefVal = 0;
		strTemp = WI.fillTextValue("rows_per_pg");
		if(strTemp.length() == 0) 
			iDefVal = 30;
		else	
			iDefVal = Integer.parseInt(strTemp);
		for(int i =30; i < 100; ++i){
			if( i == iDefVal)
				strErrMsg = " selected";
			else	
				strErrMsg = "";%>
			<option value="<%=i%>"<%=strErrMsg%>><%=i%></option>
		<%}%>
	  	</select>
	  </td>
    </tr>
    <tr> 
      <td height="48">&nbsp;</td>
      <td height="48" valign="bottom" style="font-size:10px;">
	  <a href="javascript:ShowDetail('1');" target="_self"><img src="../../../../images/view.gif" border="0"></a> click to preview report &nbsp; 
	  <a href="javascript:ShowDetail('0');" target="_self"><img src="../../../../images/print.gif" border="0"></a> click to print report </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 </form>
</body>
</html>
