<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Educational Degrees</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize11 {
		font-size:11px;
	}
	
	td {
		font-family:Verdana, Arial, Helvetica, sans-serif;
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
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Education","hr_faculty_educ_degrees.jsp");

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
														"hr_faculty_educ_degrees.jsp");
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


vRetResult = hrStat.getFacultyEducationalDegrees(dbOP);
if(vRetResult == null)
	strErrMsg = hrStat.getErrMsg();



//System.out.println(vRetResult);
	if (strErrMsg != null) { 
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>
  
 <%} 
  if (vRetResult != null && vRetResult.size() > 1) {
 	
	Vector vRanks = (Vector)vRetResult.elementAt(0);
	int iNumRanks = vRanks.size();
	int[] iColTotals = new int[iNumRanks*2];
	int iIndex = 0;
	
	for (int iNit = 0; iNit < iColTotals.length ; iNit++)
		iColTotals[iNit] = 0;
		
	int iRank = 0;
	int iRowTotals = 0; 
	String[] astrSemester={"Summer", "1st Semester", "2nd Semester", "3rd Semester"};
	
	if (strSchCode.startsWith("AUF"))
		iNumRanks--;
	
	
%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td>&nbsp;</td>
	</tr>  

	<tr>
		<td><div align="center"><strong><font size="3">Faculty Educational Degrees </font></strong></div></td>
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
  </table> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="22%" rowspan="2" align="center" class="thinborder"><strong><font size="2">COLLEGE</font></strong></td>
      <% for (iIndex = 0; iIndex < iNumRanks ; iIndex++){ %> 
      <td colspan="2" align="center" class="thinborder"><strong><%=(String)vRanks.elementAt(iIndex)%></strong></td>
      <%} 
	  	if (strSchCode.startsWith("AUF")) { 
	  %> 
      <td colspan="2" align="center" class="thinborder"><strong><%=(String)vRanks.elementAt(iIndex)%></strong></td>	  
	  <%}%> 
      <td width="10%" align="center" class="thinborder"><strong>TOTAL </strong></td>
    </tr>
    <tr>
<% for (iIndex = 0; iIndex < iNumRanks ; iIndex++){ %> 
      <td width="10%" class="thinborder" ><div align="center">Full-Time</div></td>
      <td width="10%" class="thinborder" ><div align="center">Part-Time</div></td>
      <%}
	  	if (strSchCode.startsWith("AUF")) { 
	  %> 
      <td width="10%" class="thinborder" ><div align="center">Full-Time</div></td>
      <td width="10%" class="thinborder" ><div align="center">Part-Time</div></td>
	  <%}%> 
      <td width="10%" class="thinborder" >&nbsp;</td>
    </tr>
<% 	
	boolean bolIncremented = false;
	String strCurrentCollege = null;
	Vector vDocLawyers = (Vector)vRetResult.elementAt(1);
	
	int k = 0; // index for the lawyers and dcotrs.. 
	
	for (int i = 2; i<vRetResult.size(); ) {
		
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
			&& ((String)vRetResult.elementAt(i+2)).equals("1")
			&& ((String)vRetResult.elementAt(i+1)).equals((String)vRanks.elementAt(iRank))) { 
			
			strTemp = (String)vRetResult.elementAt(i+3);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"0"));
			iColTotals[iRank*2] += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"0"));
			i += 4; bolIncremented = true; 
		}else{
			strTemp = "-";
		}
	  %>
      <td class="thinborder"><div align="center"><%=strTemp%></div></td>
	  <%if (i < vRetResult.size()
			&& strCurrentCollege.equals((String)vRetResult.elementAt(i))
			&& ((String)vRetResult.elementAt(i+2)).equals("0")
			&& ((String)vRetResult.elementAt(i+1)).equals((String)vRanks.elementAt(iRank)))  { 
			
			strTemp = (String)vRetResult.elementAt(i+3);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"0"));
			iColTotals[iRank*2+1] += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"0"));			
			i += 4;  bolIncremented = true; 
		}else{
			strTemp = "-";
		}
	  %>
      <td class="thinborder"><div align="center"><%=strTemp%></div></td>
      <%
	  } // for loop irank
	  	
		if (k < vDocLawyers.size()
			&& strCurrentCollege.equals((String)vDocLawyers.elementAt(k))
			&& ((String)vDocLawyers.elementAt(k+2)).equals("1")){
//			&& ((String)vDocLawyers.elementAt(i+1)).equals((String)vRanks.elementAt(iRank))

			strTemp = (String)vDocLawyers.elementAt(k+3);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vDocLawyers.elementAt(k+3),"0"));
			iColTotals[iRank*2] += Integer.parseInt(WI.getStrValue((String)vDocLawyers.elementAt(k+3),"0"));	
					
			k += 4;  bolIncremented = true; 
		}else{
			strTemp = "-";
		}
	  %>
      <td width="10%" class="thinborder" ><div align="center"><%=strTemp%></div></td>
	 <%
			if (k < vDocLawyers.size()
			&& strCurrentCollege.equals((String)vDocLawyers.elementAt(k))
			&& ((String)vDocLawyers.elementAt(k+2)).equals("0")){
//			&& ((String)vDocLawyers.elementAt(i+1)).equals((String)vRanks.elementAt(iRank))

			strTemp = (String)vDocLawyers.elementAt(k+3);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vDocLawyers.elementAt(k+3),"0"));
			iColTotals[iRank*2+1] += Integer.parseInt(WI.getStrValue((String)vDocLawyers.elementAt(k+3),"0"));			
			k += 4;  bolIncremented = true; 
		}else{
			strTemp = "-";
		}
		
	   %>
      <td width="10%" class="thinborder" ><div align="center"><%=strTemp%></div></td>
	  
	  
	  
      <td class="thinborder"><div align="center"><%=iRowTotals%></div></td>
    </tr>
<%
	if (!bolIncremented){ // infinite loop
		break;
	}
  } // for loop i = 1
%>
    <tr>
      <td height="25" class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;TOTAL</td>
	  <% 
	  iRowTotals = 0; 
	  for (iRank = 0 ;  iRank < iNumRanks; iRank++) {
	  	iRowTotals += iColTotals[iRank*2] + iColTotals[iRank*2+1];
	  %>
      <td align="center" class="thinborder"><%=iColTotals[iRank*2]%></td>
      <td align="center" class="thinborder"><%=iColTotals[iRank*2+1]%></td>
      <%}
	  	if (strSchCode.startsWith("AUF")) {
		iRowTotals += iColTotals[iRank*2] + iColTotals[iRank*2+1];
	  %> 
      <td align="center" class="thinborder"><%=iColTotals[iRank*2]%></td>
      <td align="center" class="thinborder"><%=iColTotals[iRank*2+1]%></td>
	<%}%> 
      <td align="center" class="thinborder"><%=iRowTotals%></td>
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