<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize11 {
		font-size:11px;
	}

a:link {
	text-decoration: none;
}
</style>
</head>

<body marginheight="0" onLoad="window.print()">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iSearchResult = 0;

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Education","hr_educ_summary.jsp");

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
														"hr_educ_summary.jsp");
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
Vector vRetResult = null;

HRStatsReports hrStat = new HRStatsReports(request);

vRetResult = hrStat.summaryDistributionPerCourse(dbOP);
if (vRetResult == null)
	strErrMsg = hrStat.getErrMsg();

if (strErrMsg != null) { %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>
  <% 
 }else { 
	if (vRetResult != null && vRetResult.size() > 0) {%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4"><div align="center"><font size="2"><strong>
	  	<%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <%=SchoolInformation.getInfo1(dbOP,false,false)%> <br> <br><br>
	<% if (request.getParameter("title_report") != null && request.getParameter("title_report").trim().length() > 0) {%>
		<strong><%=request.getParameter("title_report")%></strong><br><br><br>
	<%}%>
        </font></div></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="10%" align="center"  class="thinborder"><strong>EDUC TYPE </strong></td>
      <td width="67%" align="center"  class="thinborder"><strong>DEGREE EARNED</strong></td>
      <td width="7%" align="center"  class="thinborder">MALE</td>
      <td width="8%" align="center"  class="thinborder">FEMALE</td>
      <td width="8%" align="center"  class="thinborder"><strong>TOTAL </strong></td>
    </tr>
    <%  
		for (int i=0; i < vRetResult.size(); i += 7){%>				
			<tr>
			  <td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
			  <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%> </td>
			  <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
			  <td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
			  <td class="thinborder">&nbsp;<%=Integer.parseInt((String)vRetResult.elementAt(i+4)) + Integer.parseInt((String)vRetResult.elementAt(i+5))%></td>
			</tr>
    <%	}// end for loop %>
  </table>
  <%}//end of for.
 } //end of else.
 %>

</body>
</html>
<%
	dbOP.cleanUP();
%>