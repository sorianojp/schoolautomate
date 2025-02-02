<%@ page language="java" import="utility.*,enrollment.ReportFeeAssessment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	String[] astrConvertSem= {"Summer","1st Term","2nd Term","3rd Term","4th Term"};

	WebInterface WI = new WebInterface(request);

//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Fee adjustments Print","list_educational_assistance_print_summary.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
							//							"fee_adjustment.jsp");
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
Vector vRetResult = null;
ReportFeeAssessment rFA = new ReportFeeAssessment();
	vRetResult = rFA.getStudListAssistanceSummary(dbOP,request);
	if(vRetResult == null) {
		strErrMsg = rFA.getErrMsg();
	}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Scholarship Page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css"  type="text/css" rel="stylesheet">
<link href="../../../css/tableBorder.css"  type="text/css" rel="stylesheet">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
    }

    TD.thinborder {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

-->
</style>
</head>
<body onLoad="window.print();">
<%if(strErrMsg != null) {%>
	<p align="center" style="font-weight:bold; font-size:14px; color:#FF0000"><%=strErrMsg%></p>
<%}
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25"><div align="center"><font size="2"><strong>EDUCATIONAL ASSISTANE SUMMARY </strong></font><br>
          SY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>, <%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    
    <tr align="center" style="font-weight:bold"> 
      <td width="65%" height="25" class="thinborder"><font size="1">GRANT NAME</font></td>
      <td width="20%" class="thinborder"><font size="1">DISCOUNT ON</font></td>
      <td width="15%" class="thinborder"><font size="1">AMOUNT</font></td>
    </tr>
<% 
strTemp = "Test";
for(int i = 1; i < vRetResult.size(); i += 5){
	if(!strTemp.equals(vRetResult.elementAt(i + 2))) {
		strTemp = (String)vRetResult.elementAt(i + 2);
	%>
		<tr> 
		  <td height="25" class="thinborder" colspan="3" style="font-weight:bold; font-size:14px;"><%=strTemp%></td>
		</tr>
	<%}%>
    <tr> 
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" align="right"><%=vRetResult.elementAt(i + 4)%></td>
    </tr>
<%}%>
  </table>
<%}%>
</body>
</html>
<%
	dbOP.cleanUP();
%>