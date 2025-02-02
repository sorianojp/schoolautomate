<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
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
								"Admin/staff-REPORTS AND STATISTICS-Education","hr_educ_reports.jsp");

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
Vector vInnerResult = null;

HRStatsReports hrStat = new HRStatsReports(request);


	vRetResult = hrStat.getJrSrChancellorAppoint(dbOP);
	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();


String[] strJrSrLabel = {"Senior and Junior Staff", "Junior Staff","Senior Staff"};


if (strErrMsg != null) { 
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">

    <tr >
      <td height="25" bgcolor="#FFFFFF">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>

<%} if (vRetResult != null && vRetResult.size() > 0) {%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">

    <tr> 
      <td height="25" colspan="2" bgcolor="#CDC8B1"><div align="center"><strong><font color="#000000">LIST OF STAFF APPOINTED BY THE CHANCELLOR </font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
<% String strCurrentHeadOffice = "";
	for (int i=0; i < vRetResult.size(); i+=10){  
	  if (i == 0  || !strCurrentHeadOffice.equals((String)vRetResult.elementAt(i+9))){
	  strCurrentHeadOffice = (String)vRetResult.elementAt(i+9); 
%>
    <tr>
      <td height="25" colspan="4"  class="thinborder"><div align="center"><strong><%=strJrSrLabel[Integer.parseInt(WI.getStrValue(WI.fillTextValue("emp_catg"),"0"))]  + 
	  		" under the " + strCurrentHeadOffice%></strong></div></td>
    </tr>
    <tr> 
      <td width="10%" height="25"  class="thinborder"> <strong>Unit</strong></td>
      <td width="25%"  class="thinborder"><div align="center"><strong>Name</strong></div></td>
      <td width="40%"  class="thinborder"><div align="center"><strong> Position</strong></div></td>

      <td width="25%" class="thinborder"><strong>Duration of Appointment </strong></td>
    </tr>
	<%}
		strTemp = (String)vRetResult.elementAt(i+4);
		if (strTemp == null){
			strTemp = (String)vRetResult.elementAt(i+6);
		}
	%> 
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
	  <% strTemp = (String)vRetResult.elementAt(i+2);
	  		if (strTemp.toLowerCase().indexOf("dean") != -1  ||
				strTemp.toLowerCase().indexOf("direct") != -1 ||
				strTemp.toLowerCase().indexOf("secret") != -1){
					if ((String)vRetResult.elementAt(i+3) != null)
						strTemp +=", "  + (String)vRetResult.elementAt(i+3);
					else
						strTemp +=", "  + (String)vRetResult.elementAt(i+5);
				}
	   %>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder">&nbsp;
	  <%=WI.getStrValue((String)vRetResult.elementAt(i+7)) + " - "  +
	  		   WI.getStrValue((String)vRetResult.elementAt(i+8))%> </td>
    </tr>
    <%}// end for loop%>
  </table>
<%} //vRetResult != null && vRetResult.size() > 0%>

</body>
</html>
<%
	dbOP.cleanUP();
%>