<%@ page language="java" import="utility.*, health.HealthExamination ,java.util.Vector " %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
 	String strErrMsg = null;
	String strTemp = null;
	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Report","dental_checkup_result_print.jsp");		
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Health Monitoring","Report",request.getRemoteAddr(),
														"dental_checkup_result_print.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

HealthExamination HE = new HealthExamination();

Vector vRetResult = null;

vRetResult = HE.operateOnDentalMedicalExamination(dbOP, request, 5);
if(vRetResult == null)
	strErrMsg = HE.getErrMsg();	

String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchoolAdd  = SchoolInformation.getAddressLine1(dbOP,false,false);
 
%>
<body <%if(strErrMsg == null){%>onLoad="window.print();"<%}%>>
<%if(strErrMsg == null){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td colspan="2"><div align="center"><strong><%=strSchoolName%></strong><br>
          <%=strSchoolAdd%><br>
		  </div></td></tr>
	<tr>
		<td width="50%"></td>
		<td height="20" valign="bottom" align="center"><%=WI.getTodaysDate(1)%></td>
	</tr>
	<tr>
		<td></td>
		<td height="20" valign="top" align="center">Date</td>
	</tr>
	<tr><td colspan="2">Dear <%=WI.getStrValue((String)vRetResult.elementAt(0), "", ", ", "")%></td></tr>
	<tr><td colspan="2" height="15"></td></tr>
	<tr>
		<td style="text-indent:40px; text-align:justify;" colspan="2">
			I would like to inform you that your child <strong><%=(String)vRetResult.elementAt(1)%></strong> has been examined and was found a dental problem on :
		</td>
	</tr>
</table>
<table bgcolor="#FFFFFF" width="60%" border="0" cellpadding="0" cellspacing="0">	
	<tr><td width="40%" height="20" align="right">
		<%
			strTemp = (String)vRetResult.elementAt(2);
			if(strTemp.equals("1"))
				strTemp = "<img src='../../../../images/tick.gif' border='0'> &nbsp; ";
			else
				strTemp = "_____";
		%>
		<%=strTemp%></td>
		<td>&nbsp; Cavity for Filling</td></tr>
	<tr><td height="20" align="right">
		<%
			strTemp = (String)vRetResult.elementAt(3);
			if(strTemp.equals("1"))
				strTemp = "<img src='../../../../images/tick.gif' border='0'> &nbsp; ";
			else
				strTemp = "_____";
		%>
		<%=strTemp%></td>
		<td>&nbsp; Tooth/Teeth for Extraction</td></tr>
	<tr><td height="20" align="right">
		<%
			strTemp = (String)vRetResult.elementAt(4);
			if(strTemp.equals("1"))
				strTemp = "<img src='../../../../images/tick.gif' border='0'> &nbsp; ";
			else
				strTemp = "_____";
		%>
		
		<%=strTemp%></td>
		<td>&nbsp; Oral Prohylaxis</td></tr>
		
		
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td height="15"></td></tr>
	<tr>
		<td style="text-indent:40px; text-align:justify;" colspan="2">
			In this connection, I would like to refer your child to your family dentist for treatment.
		</td>
	</tr>
</table>
  
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td height="30" colspan="2"></td></tr>
	<tr>
		<td height="20" width="60%"></td>
		<%
		strTemp = WI.fillTextValue("license_no");
		%>
		<td align="center" valign="bottom"><%=WI.fillTextValue("school_physician_index")%><%=WI.getStrValue(strTemp,"<br>License No. ","","")%></td>		
	</tr>
	<tr>
		<td height="20" width="60%" ></td>
		<td align="center" valign="top">School Dentist</td>		
	</tr>
</table>
<%}else{%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="center"><strong><font color="#FF0000" size="2"><%=WI.getStrValue(strErrMsg)%></font></strong></td></tr>
</table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
