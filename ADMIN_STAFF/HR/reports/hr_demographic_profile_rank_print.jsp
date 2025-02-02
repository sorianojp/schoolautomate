<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize10{
		font-size:11px;
	}
</style>
</head>


<body onLoad="window.print()">
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
								"Admin/staff-HR Management-REPORTS AND STATISTICS-Education",
								"hr_demographic_profile_rank.jsp");

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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"HR Management","REPORTS AND STATISTICS",
											request.getRemoteAddr(),"hr_demographic_profile_rank.jsp");
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


HRStatsReports hrStat = new HRStatsReports(request);


String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"Rank", "Position", "Emp. Status","Last Name", "First Name"};
String[] astrSortByVal     = {"GRADE_NAME", "emp_type_name","status","lname","fname"};		

int iIndex =1;

Vector vRetResult = null;



	vRetResult = hrStat.hrDemographicRank(dbOP);
	
	if (vRetResult != null){
		iSearchResult = hrStat.getSearchCount();
	}else{
		strErrMsg = hrStat.getErrMsg();
	}


if (strErrMsg != null) { 

%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>

  </table>
  <%}
   if (vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="25%" height="25"  class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE 
          NAME</strong></font></div></td>
      <td width="13%"  class="thinborder"><div align="center"><font size="1"><strong>UNIT</strong></font></div></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>POSITION</strong></font></td>

      <td width="8%" align="center" class="thinborder"><strong><font size="1">STATUS</font></strong></td>
      <td width="19%" class="thinborder"><font size="1"><strong>LENGTH 
      OF SERVICE(PT)</strong></font></td>

      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>LENGTH OF SERVICE (FT) </strong></font></div></td>
    </tr>
    <% 
		for (int i=0; i < vRetResult.size(); i+=10){
	%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1),
	  															(String)vRetResult.elementAt(i+2),
																(String)vRetResult.elementAt(i+3),6)%></td>
      <% 
		strTemp = (String)vRetResult.elementAt(i+4);
		if (strTemp == null) strTemp = (String)vRetResult.elementAt(i+5);
	%>
      <td class="thinborder">&nbsp; <%=strTemp%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9))%></td>
    </tr>
    <%}// end for loop%>
  </table>
  
<%}%>
</body>
</html>
<%
	dbOP.cleanUP();
%>