<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
	
	TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
	body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
	
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

HRStatsReports hrStat = new HRStatsReports(request);


	vRetResult = hrStat.getSummaryFacultyRanking(dbOP);
	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();
	else	
		iSearchResult = hrStat.getSearchCount();



//System.out.println(vRetResult);
	if (strErrMsg!= null) { 
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>
 <%} if (vRetResult != null && vRetResult.size() > 1) {
 	
	Vector vRanks = (Vector)vRetResult.elementAt(0);
	int iNumRanks = vRanks.size();
	int[] iColTotals = new int[iNumRanks*2];
	int iIndex = 0;
	
	for (int iNit = 0; iNit < iColTotals.length ; iNit++)
		iColTotals[iNit] = 0;
		
	int iRank = 0;
	int iRowTotals = 0; 
	String[] astrSemester={"Summer", "1st Semester", "2nd Semester", "3rd Semester"};
%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td><div align="center"><font size="3"><strong>FACULTY RANKING</strong></font></div></td>
	</tr>  
	<% 
		if (WI.fillTextValue("semester").equals("0"))
			strTemp = astrSemester[0] + ", "  + WI.fillTextValue("sy_to");
		else
			strTemp = astrSemester[Integer.parseInt(WI.fillTextValue("semester"))] + 
						", A.Y. "  + WI.fillTextValue("sy_from") + " - " + WI.fillTextValue("sy_to");
	%> 
	<tr>
		<td><div align="center"><strong>(<%=strTemp%>)</strong></div></td>
	</tr>  
	<tr>
		<td>&nbsp;</td>
	</tr>  

  </table> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="15%" rowspan="2" class="thinborder"><div align="center"><strong><font size="2">COLLEGE</font></strong></div></td>
<% for (iIndex = 0; iIndex < iNumRanks ; iIndex++){ %> 
      <td colspan="2" class="thinborder"><div align="center"><strong><%=(String)vRanks.elementAt(iIndex)%></strong></div></td>
<%}%> 
	<td class="thinborder"> <div align="center">Total</div></td>
    </tr>
    <tr>
<% for (iIndex = 0; iIndex < iNumRanks ; iIndex++){ %> 
      <td width="10%" class="thinborder" ><div align="center">Full-Time</div></td>
      <td width="10%" class="thinborder" ><div align="center">Part-Time</div></td>
<%}%> 
	<td width="10%" class="thinborder">&nbsp;  </td>
    </tr>
<% 	
	boolean bolIncremented = false;
	String strCurrentCollege = null;
	for (int i = 1; i<vRetResult.size(); ) {
		
		strCurrentCollege = (String)vRetResult.elementAt(i);
		iRank = 0; 
		bolIncremented = false;
		iRowTotals = 0;
%>
    <tr>
      <td class="thinborder">&nbsp;<%=strCurrentCollege%></td>
	  <% for (iRank = 0 ;  iRank < iNumRanks; iRank++) { 
	  
	 	if (i < vRetResult.size()
			&& strCurrentCollege.equals((String)vRetResult.elementAt(i))
			&& ((String)vRetResult.elementAt(i+1)).equals("1")
			&& ((String)vRetResult.elementAt(i+2)).equals((String)vRanks.elementAt(iRank))) { 
			
			strTemp = (String)vRetResult.elementAt(i+3);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"0"));
			iColTotals[iRank*2] += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"0"));
			i += 4; bolIncremented = true; 
		}else{
			strTemp = "&nbsp;";
		}
	  %>
      <td class="thinborder"><div align="center"><%=strTemp%></div></td>
	  <%if (i < vRetResult.size()
			&& strCurrentCollege.equals((String)vRetResult.elementAt(i))
			&& ((String)vRetResult.elementAt(i+1)).equals("0")
			&& ((String)vRetResult.elementAt(i+2)).equals((String)vRanks.elementAt(iRank)))  { 
			
			strTemp = (String)vRetResult.elementAt(i+3);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"0"));
			iColTotals[iRank*2+1] += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"0"));

			i += 4;  bolIncremented = true; 
		}else{
			strTemp = "&nbsp;";
		}
	  %>
      <td class="thinborder"><div align="center"><%=strTemp%></div></td>
      <%
	  } // for loop irank%> 
      <td class="thinborder"><div align="center"><%=iRowTotals%></div></td>
    </tr>
<%
	if (!bolIncremented){ // infinite loop
		break;
	}
  } // for loop i = 1
%>
    <tr>
      <td height="25" class="thinborder">TOTAL</td>
	  <% 
	  iRowTotals = 0;
	  for (iRank = 0 ;  iRank < iNumRanks; iRank++) {
	  	iRowTotals += iColTotals[iRank*2] + iColTotals[iRank*2+1];
	  %>
      <td class="thinborder"><div align="center"><%=iColTotals[iRank*2]%></div></td>
      <td class="thinborder"><div align="center"><%=iColTotals[iRank*2+1]%></div></td>
	  <%}%> 
      <td class="thinborder"><div align="center"><%=iRowTotals%></div></td>
    </tr>
  </table>
 <script language="javascript">
 	window.setInterval("javascript:window.print()", 0);
 </script> 
  
 <%}%>

</body>
</html>
<%
	dbOP.cleanUP();
%>