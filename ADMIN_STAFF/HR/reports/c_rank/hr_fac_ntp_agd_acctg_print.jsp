<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize11 {
		font-size:11px;
	}

a:link {
	text-decoration: none;
}
</style>
</head>
<body marginheight="0" >
<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iSearchResult = 0;
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Ranking/Re-Ranking","hr_faculty_agd.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","REPORTS AND STATISTICS",request.getRemoteAddr(),
														"hr_educ_reports.jsp");
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
Vector vRetResult = null;

HRStatsReports hrStat = new HRStatsReports(request);

	vRetResult = hrStat.getAUFC6Report(dbOP);
	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();
	else	
		iSearchResult = hrStat.getSearchCount();

//System.out.println(vRetResult);

String[] astrSemester={"Summer", "1st Sem", "2nd Sem", "3rd Sem","4th Sem"};

	if (strErrMsg != null) { 
%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>

  <%} if (vRetResult != null && vRetResult.size() > 0)  { %>
<div align="center"> <strong>Faculty/NTP with MA / PhD for AGD Purpose (for Accounting)</strong><br><br></div>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">

<% 
	// check to see if any change in i (index) to prevent infinite loop
	String strCurrentUserIndex = null; 
	String strTemp2 = null;
	int iNTPCount = 1;
	
	String strCurrentOffice = "";
	
	for (int i = 0; i < vRetResult.size();i+=10) {
	
	
	strTemp = (String)vRetResult.elementAt(i);
	if (strTemp == null) 
		strTemp = (String)vRetResult.elementAt(i+1);	
	
	if (i == 0 || !strCurrentOffice.equals(strTemp)) {
		strCurrentOffice = strTemp;
		iNTPCount = 1;
%>
    <tr>
      <td height="25" colspan="8" class="thinborder">
	  			<div align="center"><strong><%=strCurrentOffice%></strong></div>	  </td>
    </tr>	
    <tr>
      <td width="4%" height="25" class="thinborder">&nbsp;</td>
	  
      <td width="4%" class="thinborder">&nbsp;</td>
      <td width="8%" class="thinborder">&nbsp;</td>
      <td width="26%" class="thinborder"><div align="center">NAME </div></td>
      <td width="20%" class="thinborder"><div align="center">POSITION</div></td>
      <td width="15%" class="thinborder"><div align="center">RANK </div></td>
      <td width="15%" class="thinborder"> <div align="center">LICENSURE</div></td>
      <td width="8%" class="thinborder"><div align="center">AGD</div></td>
    </tr>
<%}%> 
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=iNTPCount++%></td>
	  
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8))%></td>
    </tr>
<% } //end for loop%> 
</table>
 
<%
 } 
%> 

</body>
</html>
<%
	dbOP.cleanUP();
%>