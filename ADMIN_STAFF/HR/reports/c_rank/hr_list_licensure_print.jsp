<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize10{
		font-size:11px;
	}
</style>
</head>

<body onLoad="window.print();">
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
								"hr_demographic_profile.jsp");

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
											request.getRemoteAddr(),"hr_demographic_profile.jsp");
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
					
int iIndex =1;

Vector vRetResult =  hrStat.hrDemographicProfile(dbOP);
	
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
    
<%}else  if (vRetResult != null && vRetResult.size() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4"><div align="center"><strong> LIST OF EMPLOYEES WITH LICENSURE</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <% 
		iIndex = 1;
		String strCurrentCollege = null;
		String strCurrEnty = null;
	for (int i=0; i < vRetResult.size(); i+=17){
			
		if (strCurrentCollege == null){
			strCurrentCollege = WI.getStrValue((String)vRetResult.elementAt(i+5));
			if (strCurrentCollege.length() == 0) 
				strCurrentCollege = WI.getStrValue((String)vRetResult.elementAt(i+6));
		}
			
		strCurrEnty = WI.getStrValue((String)vRetResult.elementAt(i+5));
		if (strCurrEnty.length() == 0) 
			strCurrEnty = WI.getStrValue((String)vRetResult.elementAt(i+6));
			
		if (i == 0 || !strCurrentCollege.equals(strCurrEnty))  {
			strCurrentCollege = strCurrEnty;
			iIndex = 1;
	%>
    <tr>
      <td height="25" colspan="5" class="thinborder"><strong>&nbsp;<%=strCurrentCollege.toUpperCase()%></strong></td>
    </tr>
	<%}%> 	
    <tr>
      <td width="5%" class="thinborder">&nbsp;<%=iIndex++%></td> 
      <td width="35%" height="23" class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2),
	  													(String)vRetResult.elementAt(i+3),
					 	  							    (String)vRetResult.elementAt(i+4),4)%></td>
      <td width="24%" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+12),"&nbsp;")%></td>
      <td width="17%" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%></td>
      <td width="19%" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+15),"&nbsp")%></td>
    </tr>
    <%}// end for loop%>
  </table>
<%}%>

</body>
</html>
<%
	dbOP.cleanUP();
%>