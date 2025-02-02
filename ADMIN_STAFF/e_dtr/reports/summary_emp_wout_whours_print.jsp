<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR, eDTR.eDTRUtil" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.fontsize11 {		font-size : 11px;
}
-->
</style>
</head>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="Javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<body onLoad="javascript:window.print();">
<%	
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	Vector vRetResult = null;
	int iSearchResult =0;
	int iPageCount = 0;
	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Employees with Lacking Time Out Record",
								"summary_emp_wout_whours.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"summary_emp_wout_whours.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
//end of authenticaion code.

	ReportEDTR RE = new ReportEDTR(request);
	vRetResult = RE.searchWithoutWorkHours(dbOP);
%>
<form name="dtr_op" >
  <% if (vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="3" align="center" class="thinborder"> <strong>LIST 
          OF EMPLOYEE WITHOUT VALID WORKING HOUR As of (<%=WI.getTodaysDate(1)%>) </strong></td>
    </tr>
    <tr> 
      <td width="17%" class="thinborder"><strong>&nbsp;EMPLOYEE ID</strong></td>
      <td width="37%" class="thinborder"><strong>&nbsp;NAME</strong></td>
      <td width="46%" height="30" align="center" class="thinborder"> <strong>DEPT 
          / OFFICE</strong></td>
    </tr>
    <%		strTemp = null;
		  		 for (int i=0; i < vRetResult.size(); i+=8)  {%>
    <tr> 
  <% if (strTemp!=null && strTemp.equals((String)vRetResult.elementAt(i))){
		strTemp2 ="&nbsp;";
		strTemp3 ="&nbsp;";
	}else{
		strTemp2 = (String)vRetResult.elementAt(i + 1);
		strTemp3 = WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),
								 (String)vRetResult.elementAt(i+4),4);
	}
%>
      <td height="25" class="thinborder">&nbsp;<%=strTemp2%></td>
      <td class="thinborder">&nbsp;<%=strTemp3%></td>
<% 
	strTemp3 = (String)vRetResult.elementAt(i+5);
	if (strTemp3 != null) 
		strTemp3 += WI.getStrValue((String)vRetResult.elementAt(i+6)," :: ","","");
	else strTemp3 = (String)vRetResult.elementAt(i+6);
%>
      <td class="thinborder">&nbsp;<%=strTemp3%></td>
    </tr>
    <%} //end for loop%>
  </table>
<%}%>
 <input type="hidden" name="print_page">
</form>
</body>
</html>
<% 
dbOP.cleanUP(); 
%>