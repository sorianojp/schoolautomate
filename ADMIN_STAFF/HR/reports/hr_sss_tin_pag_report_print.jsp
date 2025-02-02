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
</style>
</head>

<body marginheight="0" onLoad="window.print()">
<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iSearchResult = 0;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	boolean bolAUF = strSchCode.startsWith("AUF");
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-SSS/TIN/PAG-IBIG","hr_sss_tin_pag_report.jsp");

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
														"hr_sss_tin_pag_report.jsp");
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

boolean[] abolShowColumns={false, false, false, false,false, false, false}; 
boolean bolShowAtLeastOne = false;
int iShowColumns =0;
for (int i = 0; i < 7; i++){
	if ( WI.fillTextValue("checkbox"+i).equals("1")){
		abolShowColumns[i]= true;
		iShowColumns++;
	}
}
HRStatsReports hrStat = new HRStatsReports(request);

vRetResult = hrStat.searchSSSTINPagIbig(dbOP);
if(vRetResult == null)
	strErrMsg = hrStat.getErrMsg();
else	
	iSearchResult = hrStat.getSearchCount();


if (strErrMsg != null) {
%>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>

<%} else if (vRetResult != null && vRetResult.size() > 0) {%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td height="25" colspan="2"><div align="center"><strong><div align="center"><font size="2"><strong>
	  	<%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <%=SchoolInformation.getInfo1(dbOP,false,false)%> <br> <br><br>

	<% if (request.getParameter("title_report") != null && request.getParameter("title_report").trim().length() > 0) {%>
		<strong><%=request.getParameter("title_report")%></strong><br>
<br>
<br>

	<%}%>
        </font></div></strong></div></td>
    </tr>
    <tr> 
      <td width="49%" height="25"><b>&nbsp;TOTAL RESULT : <%=iSearchResult%> </b></td>
      <td width="51%">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="28%" height="20"  class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE NAME </strong></font></div></td>

      <td width="9%"  class="thinborder"><div align="center"><strong><font size="1">POSITION</font></strong></div></td>
      <td width="11%"  class="thinborder"><div align="center"><strong><font size="1">OFFICE 
          </font></strong></div></td>
      <% if (abolShowColumns[0]) {%>
      <td width="13%"  class="thinborder"><div align="center"><font size="1"><strong>SSS</strong></font></div></td>
      <%} if (abolShowColumns[1]){%>
      <td width="12%"  class="thinborder"><div align="center"><font size="1"><strong>TIN</strong></font></div></td>
      <%} if (abolShowColumns[2]){%>	  
      <td width="12%" align="center" class="thinborder"><strong><font size="1">PAG-IBIG</font></strong></td>
      <%} if (abolShowColumns[3]){%>
      <td width="15%" align="center" class="thinborder"><strong><font size="1">PHILHEALTH</font></strong></td>
      <%} if (abolShowColumns[4]){%>
      <td width="13%" align="center" class="thinborder"><strong><font size="1"><%if(bolAUF){%>AUF RETIREMENT PLAN<%}else{%>PERAA<%}%></font></strong></td>
      <%} if (abolShowColumns[5]){%>
      <td width="13%" align="center" class="thinborder"><strong><font size="1">HIRING BATCH</font></strong></td>
      <%} if (abolShowColumns[6]){%>
      <td width="13%" align="center" class="thinborder"><strong><font size="1">TEAM</font></strong></td>
      <%}%>
    </tr>
    <% 	for (int i=0; i < vRetResult.size(); i+=14){ %>
    <tr> 
      <td class="thinborder">&nbsp;(<%=(String)vRetResult.elementAt(i)%>)&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1),
	  								(String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),4)%> </td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6))%> </td>
	 <% 
	 	strTemp = (String)vRetResult.elementAt(i+4); 
		if (strTemp == null) 
			strTemp = (String)vRetResult.elementAt(i+5); 
		else
			strTemp +=  WI.getStrValue((String)vRetResult.elementAt(i+5),"(", ")","");
		 
	 %>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%> </td>
      <%if (abolShowColumns[0]){ %>
      <td class="thinborder">&nbsp;<%= WI.getStrValue((String)vRetResult.elementAt(i+7))%></td>
      <%}if (abolShowColumns[1]){ %>
      <td class="thinborder">&nbsp;<%= WI.getStrValue((String)vRetResult.elementAt(i+8))%></td>
      <%}if (abolShowColumns[2]){ %>
      <td class="thinborder">&nbsp;<%= WI.getStrValue((String)vRetResult.elementAt(i+9))%></td>
      <%}if (abolShowColumns[3]){ %>
      <td class="thinborder">&nbsp;<%= WI.getStrValue((String)vRetResult.elementAt(i+10))%></td>
      <%}if (abolShowColumns[4]){ %>
      <td class="thinborder">&nbsp;<%= WI.getStrValue((String)vRetResult.elementAt(i+11))%></td>
      <%}if (abolShowColumns[5]){ %>
      <td class="thinborder">&nbsp;<%= WI.getStrValue((String)vRetResult.elementAt(i+12))%></td>
      <%} if (abolShowColumns[6]){%>
      <td class="thinborder">&nbsp;<%= WI.getStrValue((String)vRetResult.elementAt(i+13))%></td>
      <%}%>
    </tr>
    <%}// end for loop
	%>
  </table>
<%}%>
</body>
</html>
<%
	dbOP.cleanUP();
%>