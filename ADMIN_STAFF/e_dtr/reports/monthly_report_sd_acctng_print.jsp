<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Monthly Attendance Monitoring</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="javascript:window.print();">
<%@ page language="java" import="utility.*, eDTR.ReportEDTR,eDTR.eDTRUtil, eDTR.WorkingHour,java.util.Vector, java.util.Calendar" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;

	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS","monthly_report_sd_acctng.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"monthly_report_sd_acctng.jsp");	
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
int iSearchResult = 0;
ReportEDTR RE = new ReportEDTR(request);


String[] astrMonth={"","January", "February", "March", "April", "May", "June", "July",
					"August", "September","October", "November", "December"};
String[] astrWeekDays={"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}; 


Vector vRetResult =  RE.getOfcDeptMonthlyReport(dbOP);
	
if (vRetResult == null)
	strErrMsg = RE.getErrMsg();

if (strErrMsg != null) {%> 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

 <%} if (vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;
          <div align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
            PERSONNEL TARDINESS/ UNDERTIME / AWOL <br>
            FOR THE MONTH OF </font>
		    <%=WI.fillTextValue("month_label")%> &nbsp;			
		<%=WI.fillTextValue("sy_")%>
		</div></td>
    </tr>
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="13%" rowspan="2" class="thinborder"><strong>&nbsp;UNIT</strong></td>
      <td width="15%" rowspan="2" class="thinborder"><strong> &nbsp;ID #</strong> </td>
      <td width="30%" rowspan="2" class="thinborder"><strong>&nbsp;Name</strong></td>
      <td width="17%" rowspan="2" class="thinborder"><div align="center"><strong>Tardiness</strong> / <br>
        <strong>Undertime (min)</strong> </div></td>
      <td height="21" colspan="2" class="thinborder"><div align="center"><strong>AWOL</strong></div></td>
    </tr>
    <tr>
      <td width="15%" height="12" class="thinborder"><strong>&nbsp;Date</strong></td>
      <td width="10%" class="thinborder"><strong>&nbsp;Hour(s)</strong></td>
    </tr>
<% 


	Vector vAwol = new Vector();
	int k = 0;
	int iMaxLines = 0;
	
	for (int i = 0; i < vRetResult.size(); i+= 15) {
		iMaxLines = 0;
		vAwol.clear();
		
		if ((Vector)vRetResult.elementAt(i+9) != null) 
			vAwol.addAll((Vector)vRetResult.elementAt(i+9));
			
		if ((Vector)vRetResult.elementAt(i+10) != null)
			vAwol.addAll((Vector)vRetResult.elementAt(i+10));		
			
		if (vAwol != null && vAwol.size()/2 > iMaxLines)
			iMaxLines = vAwol.size()/2;

	if (iMaxLines == 0) 
		iMaxLines++;

	for (k = 0; k < iMaxLines;  k++){
	
%> 
    <tr>
	<% if (k == 0) {
			strTemp = (String)vRetResult.elementAt(i+13);
			if (strTemp == null) 
				strTemp = (String)vRetResult.elementAt(i+14);
			
		}else{
			strTemp = "&nbsp;";
		}
	%> 		
      <td class="thinborder">&nbsp;<%=strTemp%></td>
	<% if (k == 0) {
			strTemp = (String)vRetResult.elementAt(i+1);
		}else{
			strTemp = "";
		}
	%> 	  
      <td class="thinborder">&nbsp;<%=strTemp%></td>
	<% if (k == 0) {
			strTemp = (String)vRetResult.elementAt(i+2);
		}else{
			strTemp = "";
		}
	%> 
      <td class="thinborder" height="18">&nbsp;<%=strTemp%></td>
      <% if (k == 0){
	 		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;");
		 }else{
		 	strTemp =  "&nbsp;";
		 }
	  %> 
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;&nbsp;</td>
      <% if (vAwol != null &&  k*2 < vAwol.size())
		strTemp = (String)vAwol.elementAt(k*2);
	   else
		strTemp = "&nbsp;";
	%>		  
      <td class="thinborder">&nbsp;<%=strTemp%></td>
	<% if (vAwol != null &&  k*2 < vAwol.size())
		strTemp = (String)vAwol.elementAt(k*2 +1);
	   else
		strTemp = "&nbsp;";
	%>		   
      <td class="thinborder">&nbsp;<%=CommonUtil.formatFloat(strTemp, false)%></td>
    </tr>
<%
 }// end employee.. 
}%>
  </table>
<%}%> 

</body>
</html>
<%
dbOP.cleanUP();
%>