<%@ page language="java" import="utility.*, health.HealthExamination ,java.util.Vector " %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
strSchCode = "UB";
%>

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
	
	boolean bolIsMedicalCert = (WI.fillTextValue("report_type").equals("3") || WI.fillTextValue("report_type").equals("4"));
	
	boolean bolIsExcuseSlip = WI.fillTextValue("report_type").equals("4");
	
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
		  <%if(strSchCode.startsWith("UB")){
		  		if(bolIsMedicalCert)
					strTemp = "MEDICAL";
				else
					strTemp = "DENTAL";
		  %><br><%=strTemp%> CLINIC<br><br><%=strTemp%> CERTIFICATE<br><%}%><br>
		  </div></td></tr>
	<tr>
		<td width="50%"></td>
		<td height="20" valign="bottom" align="center"> Date : <%=WI.getTodaysDate(1)%></td>
	</tr>
	<tr>
		<td height="15" colspan="2"></td>
	</tr>
	<%
	if(bolIsExcuseSlip)
		strTemp = "Sir / Madam";
	else
		strTemp = "TO WHOM IT MAY CONCERN";
	%>
	<tr><td colspan="2"><%=strTemp%>:</td></tr>
	<tr><td colspan="2" height="15"></td></tr>
	<tr>
		<td style="text-indent:40px; text-align:justify;" colspan="2">
			This is to certify that <strong><%=(String)vRetResult.elementAt(1)%></strong> was examined <%if(!bolIsExcuseSlip){%>and treated <%}%>on
			<%=(String)vRetResult.elementAt(7)%> <%if(!bolIsExcuseSlip){%>up to <%=WI.getStrValue((String)vRetResult.elementAt(8), "", "", "")%><%}%>.
		</td>
	</tr>
</table>
  
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td height="25" colspan="2"></td></tr>
	
	<tr><td colspan="2">IMPRESSION/REMARKS:</td></tr>
	<tr>
		<td height="75" valign="top" style="padding-left:30px;"><%=WI.getStrValue((String)vRetResult.elementAt(11))%></td>
	</tr>
	
	
	<tr>
		<td height="20" width="51%"></td>		
		<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(14),"<br>License No. ","","");
		%>
		<td width="49%" align="center" valign="bottom"><%=WI.getStrValue((String)vRetResult.elementAt(13))%><%=strTemp%></td>		
	</tr>
	<tr>
		<td height="20" width="51%" ></td>				
		<%
		if(WI.fillTextValue("report_type").equals("2"))
		strTemp = "School Dentist";
	if(WI.fillTextValue("report_type").equals("3"))
		strTemp = "School Physician";
	if(WI.fillTextValue("report_type").equals("4"))
		strTemp = "School Nurse";
		%>
		<td align="center" valign="top"><%=strTemp%></td>		
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
