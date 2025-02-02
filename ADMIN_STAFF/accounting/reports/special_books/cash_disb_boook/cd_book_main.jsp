<%
utility.WebInterface WI = new utility.WebInterface(request);
String strErrMsg = null;

String strAuthType = (String)request.getSession(false).getAttribute("authTypeIndex");
if(strAuthType == null)
	strAuthType = "";
int iAuthType = Integer.parseInt(WI.getStrValue(strAuthType, "1"));

if(request.getSession(false).getAttribute("userIndex") == null)
	strErrMsg = "You are already logged out. Please login again.";
else if(iAuthType >3 || iAuthType == 0)
	strErrMsg = "You are not authorized to go to this link.";


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body bgcolor="#D2AE72">
<%if(strErrMsg != null) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" style="font-size:14px; font-weight:bold; color:#FF0000"><%=strErrMsg%></td>
  </tr>
</table>
<%return;}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
        DISBURSEMENT BOOK PAGE ::::</strong></font></div></td>
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
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25" align="right">Operation : </td>
    <td align="center">&nbsp;</td>
    <td align="left"><a href="./cd_book_1st_page.jsp" target="_self">Disbursement Book (Details) </a></td>
  </tr>
  <tr>
    <td width="12%" height="25">&nbsp;</td>
    <td width="21%" height="25" align="right">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="left"><a href="./cd_book_summary_1st_page.jsp" target="_self">Summary of Disbursement </a></td>
  </tr>
  <tr>
    <td width="12%" height="25">&nbsp;</td>
    <td width="21%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td align="left"><a href="./wholding_source_1st_page.jsp" target="_self">Withholding at Source (EWT Report) </a></td>
  </tr>
<%
if(strSchCode.startsWith("AUF")){%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="../../bank_adjustments/update_check_stat.jsp" target="_self">Check Register</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./sched_of_account_main.jsp" target="_self">Schedule Of Accounts</a></td>
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
