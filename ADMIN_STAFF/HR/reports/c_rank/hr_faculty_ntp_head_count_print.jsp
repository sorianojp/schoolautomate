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
	.fontsize11 {
		font-size:11px;
	}
	td {
		font-family:Verdana, Arial, Helvetica, sans-serif;
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
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");


try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Education","hr_faculty_ntp_head_count_print.jsp");

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
														"hr_faculty_ntp_head_count_print.jsp");
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

vRetResult = hrStat.getHeadCount(dbOP);
if(vRetResult == null)
	strErrMsg = hrStat.getErrMsg();

if (strErrMsg != null) { 

%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>
 <%} else if (vRetResult != null && vRetResult.size() > 1) {
 	
 	
	Vector vRanks = (Vector)vRetResult.elementAt(0);

	int iNumRanks = vRanks.size();

	
	String strRowSpan = "";
	
//	System.out.println("vRanks : " + vRanks);
	
	if (vRanks.elementAt(0)  == null) 
	strRowSpan = " rowspan=\"2\"";
		
	
	
	int iExtraLength = 0;
	
	int[] iColTotals = new int[iNumRanks+6];
	int iIndex = 0;
	
	for (int iNit = 0; iNit < iColTotals.length ; iNit++)
		iColTotals[iNit] = 0;
	
	
	int iRank = 0;
	int iRowTotals = 0; 
	String[] astrPTFT = {"","FULLTIME", "PART-TIME", "CONS", "CONC"};
	String[] astrSemester={"Summer", "1st Semester", "2nd Semester", "3rd Semester"};
	
%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td>&nbsp;</td>
	</tr>  

  </table> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  
<% if (iNumRanks > 2 || (iNumRanks == 2 && vRanks.elementAt(1) != null)) {%> 
  
    <tr>
      <td rowspan="3" class="thinborder"><div align="center"><strong><font size="2">
	  <% if (strSchCode.startsWith("AUF")) {%> UNIT 
	  <%}else{%> OFFICE <%}%>
	  
	  </font></strong></div></td>
      <td colspan="<%=iNumRanks%>" class="thinborder"><div align="center">FULL - TIME </div></td>
      <td colspan="2" rowspan="2" class="thinborder"><div align="center">PART TIME </div></td>
<%if (strSchCode.startsWith("AUF")) {%>
      <td colspan="2" rowspan="2" class="thinborder"><div align="center">CONS </div></td>
      <td colspan="2" rowspan="2" class="thinborder"><div align="center">CONC</div></td>
<%}%> 
      <td width="7%" rowspan="3" align="center" class="thinborder">TOTAL</td>
    </tr>
    <tr>
      <% for (iIndex = 0; iIndex < iNumRanks ; iIndex += 2){ 
	  		if (!(WI.getStrValue((String)vRanks.elementAt(iIndex),"1")).equals("1")){
				break;
			}
	  %> 
      <td height="20" colspan="2" class="thinborder">
	  	<div align="center">
			<%=WI.getStrValue((String)vRanks.elementAt(iIndex+1),"&nbsp;")%></div></td>
      <%}%> 
    </tr>
    <tr>
      <%
		
	  	for (iIndex = 0; iIndex < iNumRanks ; iIndex += 2){ 
	  		if (!(WI.getStrValue((String)vRanks.elementAt(iIndex),"1")).equals("1")){
				break;
			}
	  %> 
      <td width="5%" height="20" class="thinborder" ><div align="center">M</div></td>
      <td width="5%" class="thinborder" ><div align="center">F</div></td>
	  <%}%> 
	  
      <td width="5%" align="center" class="thinborder" >M</td>
      <td width="5%" align="center" class="thinborder" >F</td>
<% if ( strSchCode.startsWith("AUF")) { %>
      <td width="5%" align="center" class="thinborder" >M</td>
      <td width="5%" align="center" class="thinborder" >F</td>
      <td width="5%" align="center" class="thinborder" >M</td>
      <td width="5%" align="center" class="thinborder" >F</td>
<%} // if auf  %>
  </tr>
<%
 } // end if iNumRanks > 2
  else { 
%> 


    <tr>
      <td rowspan="2" class="thinborder"><div align="center"><strong><font size="2">
	  <% if (strSchCode.startsWith("AUF")){%>UNIT <%}else{%>OFFICE
	  <%}%>
	  
	  </font></strong></div></td>
      <td height="20" colspan="2" class="thinborder"><div align="center">FULL - TIME </div></td>
      <td colspan="2" class="thinborder"><div align="center">PART TIME </div></td>
<%if (strSchCode.startsWith("AUF")) {%>
      <td colspan="2" rowspan="2" class="thinborder"><div align="center">CONS </div></td>
      <td colspan="2" rowspan="2" class="thinborder"><div align="center">CONC</div></td>
<%}%> 
      <td width="7%" rowspan="2" align="center" class="thinborder">TOTAL</td>
    </tr>
    <tr>
      <%
		
	  	for (iIndex = 0; iIndex < iNumRanks ; iIndex += 2){ 
	  		if (!(WI.getStrValue((String)vRanks.elementAt(iIndex),"1")).equals("1")){
				break;
			}
	  %> 
      <td width="5%" height="20" class="thinborder" ><div align="center">M</div></td>
      <td width="5%" class="thinborder" ><div align="center">F</div></td>
	  <%}%> 
	  
      <td width="5%" align="center" class="thinborder" >M</td>
      <td width="5%" align="center" class="thinborder" >F</td>
<% if (strSchCode.startsWith("AUF")) { %>
      <td width="5%" align="center" class="thinborder" >M</td>
      <td width="5%" align="center" class="thinborder" >F</td>
      <td width="5%" align="center" class="thinborder" >M</td>
      <td width="5%" align="center" class="thinborder" >F</td>
<%} // if auf  %>
  </tr>
<%}%>

  
<% 	boolean bolIncremented = false;
	String strCurrentCollege = null;
	
//	System.out.println("vRetResult : " + vRetResult);
	
	for (int i = 1; i<vRetResult.size(); ) {
		
		iIndex = 0;
	
		if (vRetResult.elementAt(i) != null) 
			strCurrentCollege = (String)vRetResult.elementAt(i);
		else
			strCurrentCollege= (String)vRetResult.elementAt(i+1);

		if (strCurrentCollege== null) 
			strCurrentCollege = "";

			
		iRank = 0; 
		bolIncremented = false;
		iRowTotals = 0;
%>
    <tr>
      <td height="20" class="thinborder">&nbsp;<%=strCurrentCollege%></td>
	  
	  <% for (iRank = 0 ;  iRank < iNumRanks; iRank += 2) {
	  
	 	if (i < vRetResult.size()
			// college
			&& strCurrentCollege.equals(WI.getStrValue((String)vRetResult.elementAt(i))) 
			// gender
			&& ((String)vRetResult.elementAt(i+4)).equals("0") 
			// status 
			&& (WI.getStrValue((String)vRetResult.elementAt(i+3))).equals(WI.getStrValue((String)vRanks.elementAt(iRank+1))) 
			// check part time full time 
			&& ((String)vRetResult.elementAt(i+2)).equals(WI.getStrValue((String)vRanks.elementAt(iRank)))) 
	   { 
			
			strTemp = (String)vRetResult.elementAt(i+5);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iColTotals[iIndex] += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			i += 6; 
			bolIncremented = true; 
		}else{
			strTemp = "&nbsp;";
		}
		iIndex++;
	  %>
      <td class="thinborder"><div align="center"><%=strTemp%></div></td>
 	  <%
	    if (i < vRetResult.size()
			// college
			&& strCurrentCollege.equals((String)vRetResult.elementAt(i)) 
			// gender
			&& ((String)vRetResult.elementAt(i+4)).equals("1") 
			// status
			&& (WI.getStrValue((String)vRetResult.elementAt(i+3))).equals(WI.getStrValue((String)vRanks.elementAt(iRank+1)))  
			// check part time full time
			&& ((String)vRetResult.elementAt(i+2)).equals(WI.getStrValue((String)vRanks.elementAt(iRank))))  
	   { 
			strTemp = (String)vRetResult.elementAt(i+5);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iColTotals[iIndex] += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			i += 6; bolIncremented = true; 
		}else{
			strTemp = "&nbsp;";
		}
		iIndex++;
	  %>
      <td class="thinborder"><div align="center"><%=strTemp%></div></td>
	  <%} // end of full time 
	    if (i < vRetResult.size()
			&& strCurrentCollege.equals((String)vRetResult.elementAt(i)) // college
			&& ((String)vRetResult.elementAt(i+4)).equals("0") // gender
			// status -> not required.. part time has only 1 status
//			&& ((String)vRetResult.elementAt(i+3)).equals((String)vRanks.elementAt(iRank+1)) 
			// check part time full time 
			&& ((String)vRetResult.elementAt(i+2)).equals("2")) 
	   { 
			strTemp = (String)vRetResult.elementAt(i+5);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iColTotals[iIndex] += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			i += 6; 
			bolIncremented = true; 
		}else{
			strTemp = "&nbsp;";
		}
		iIndex++;
	  %>
      <td class="thinborder"><div align="center"><%=strTemp%></div></td>
	  <%  if (i < vRetResult.size()
	  		// college
			&& strCurrentCollege.equals((String)vRetResult.elementAt(i)) 
			// gender
			&& ((String)vRetResult.elementAt(i+4)).equals("1") 
			// status -> not required.. part time has only 1 status
//			&& ((String)vRetResult.elementAt(i+3)).equals((String)vRanks.elementAt(iRank+1)) // status 
			&& ((String)vRetResult.elementAt(i+2)).equals("2")) 
	   { 
			
			strTemp = (String)vRetResult.elementAt(i+5);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iColTotals[iIndex] += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			i += 6; bolIncremented = true; 
		}else{
			strTemp = "&nbsp;";
		}
		iIndex++;
	  %>
      <td class="thinborder"><div align="center"><%=strTemp%></div></td>
<% if (strSchCode.startsWith("AUF")) {%>

	  <%  if (i < vRetResult.size()
	  		// college
			&& strCurrentCollege.equals((String)vRetResult.elementAt(i)) 
			// gender
			&& ((String)vRetResult.elementAt(i+4)).equals("0") 
			// 1 status only for consultants
//			&& ((String)vRetResult.elementAt(i+3)).equals((String)vRanks.elementAt(iRank+1)) // status 
			// consultants
			&& ((String)vRetResult.elementAt(i+2)).equals("3")) 
	   { 
			
			strTemp = (String)vRetResult.elementAt(i+5);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iColTotals[iIndex] += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			i += 6; bolIncremented = true; 
		}else{
			strTemp = "&nbsp;";
		}
		iIndex++;
	  %>

      <td class="thinborder"><div align="center"><%=strTemp%></div></td>
	  <%  if (i < vRetResult.size()
	  		// college
			&& strCurrentCollege.equals((String)vRetResult.elementAt(i)) 
			// gender
			&& ((String)vRetResult.elementAt(i+4)).equals("1") 
//			&& ((String)vRetResult.elementAt(i+3)).equals((String)vRanks.elementAt(iRank+1)) // status 
			&& ((String)vRetResult.elementAt(i+2)).equals("3")) // part time 
	   { 
			
			strTemp = (String)vRetResult.elementAt(i+5);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iColTotals[iIndex] += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			i += 6; bolIncremented = true; 
		}else{
			strTemp = "&nbsp;";
		}
		iIndex++;
	  %>

      <td class="thinborder"><div align="center"><%=strTemp%></div></td>
	  <%  if (i < vRetResult.size()
			&& strCurrentCollege.equals((String)vRetResult.elementAt(i)) // college
			&& ((String)vRetResult.elementAt(i+4)).equals("0") // gender
//			&& ((String)vRetResult.elementAt(i+3)).equals((String)vRanks.elementAt(iRank+1)) // status 
			&& ((String)vRetResult.elementAt(i+2)).equals("4")) // CONC????
	   { 
			
			strTemp = (String)vRetResult.elementAt(i+5);
//			iRowTotals = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iColTotals[iIndex] += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			i += 6; bolIncremented = true; 

		}else{
			strTemp = "&nbsp;";
		}


		iIndex++;
	  %>

      <td class="thinborder"><div align="center"><%=strTemp%></div></td>

<%  if (i < vRetResult.size()
			// college
			&& strCurrentCollege.equals((String)vRetResult.elementAt(i)) 
			// gender
			&& ((String)vRetResult.elementAt(i+4)).equals("1") 
//			&& ((String)vRetResult.elementAt(i+3)).equals((String)vRanks.elementAt(iRank+1)) // status 
			// CONCURRENT JOBS ==
			&& ((String)vRetResult.elementAt(i+2)).equals("4"))
	   { 
			strTemp = (String)vRetResult.elementAt(i+5);
//			iRowTotals = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iColTotals[iIndex] += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			
			i += 6; 
			bolIncremented = true; 
		}else{
			strTemp = "&nbsp;";
		}
		iIndex++;
	  %>

      <td class="thinborder"><div align="center"><%=strTemp%></div></td>
<%}%>
      <td class="thinborder"><div align="center"><%=iRowTotals%></div></td>
    </tr>
<%
	if (!bolIncremented){
	 // infinite loop
		break;
	}
  } // for loop i = 1
%>
    <tr>
      <td height="20" class="thinborder">TOTAL</td>
	  <% 
	  iRowTotals = 0;
	  for (iRank = 0 ;  iRank < iNumRanks; iRank += 2) {
		iRowTotals += iColTotals[iRank] + iColTotals[iRank+1]; 
	  %> 
      <td width="5%" class="thinborder" ><div align="center"><%=iColTotals[iRank]%></div></td>
      <td width="6%" class="thinborder" ><div align="center"><%=iColTotals[iRank+1]%></div></td>
	  <%}
	  
	  iRowTotals += iColTotals[iRank];
	  %> 
	  
      <td width="5%" align="center" class="thinborder" ><%=iColTotals[iRank++]%></td>
	  <%iRowTotals += iColTotals[iRank];%>
      <td width="6%" align="center" class="thinborder" ><%=iColTotals[iRank++]%></td>
<% if (strSchCode.startsWith("AUF")) { 
	  iRowTotals += iColTotals[iRank];
%>
      <td width="5%" align="center" class="thinborder" ><%=iColTotals[iRank++]%></td>
	  <%iRowTotals += iColTotals[iRank];%>
      <td width="6%" align="center" class="thinborder" ><%=iColTotals[iRank++]%></td>
	  <%iRowTotals += iColTotals[iRank];%>
      <td width="5%" align="center" class="thinborder" ><%=iColTotals[iRank++]%></td>
	  <%iRowTotals += iColTotals[iRank];%>
      <td width="7%" align="center" class="thinborder" ><%=iColTotals[iRank]%></td>
<%} // if auf %> 
      <td width="6%" align="center" class="thinborder" ><%=iRowTotals%></td>
    </tr>
    <tr>
      <td height="20" class="thinborder">&nbsp;</td>
  <% 
	  for (iRank = 0 ;  iRank < iNumRanks; iRank += 2) {
  %> 
      <td colspan="2" class="thinborder" >
	  	<div align="center"><%=iColTotals[iRank] + iColTotals[iRank+1]%></div>
	  </td>
  <%}

  %> 
      <td colspan="2" align="center" class="thinborder">
	  		<div align="center"><%= iColTotals[iRank] + iColTotals[iRank+1]%></div>
	   </td>
<% if (strSchCode.startsWith("AUF")) { 
	  iRank+=2;
%>
      <td colspan="2" align="center" class="thinborder" >
	  	<div align="center"><%=iColTotals[iRank] + iColTotals[iRank+1]%></div>
	  </td>
<%		iRank+=2; %>	  
      <td colspan="2" align="center" class="thinborder" >
	  	<div align="center"><%=iColTotals[iRank] + iColTotals[iRank+1]%></div>
	  </td>
<%}%>
      <td align="center" class="thinborder" >&nbsp;</td>
    </tr>
  </table>

<% if (strSchCode.startsWith("AUF")) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="20">&nbsp;  </td>
    </tr>  
    <tr>
      <td height="20">
		<u><strong>
			TOTAL HEAD COUNT = <%=iRowTotals - iColTotals[iRank] - iColTotals[iRank+1]%>
		</strong> </u> (FULL-TIME, PART-TIME, CONSULTANT) 
	  </td>
    </tr>
  </table>
<% 
  }
 } 
%>

</body>
</html>
<%
	dbOP.cleanUP();
%>