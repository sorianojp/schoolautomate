<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	
%>
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
	td {
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;
	}
a:link {
	text-decoration: none;
}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function PrintPg()
{
<%if (strSchCode.startsWith("AUF")) { %>
	document.getElementById('footer').deleteRow(1);
<%}%> 

	document.getElementById('header').deleteRow(0);
	document.getElementById('header').deleteRow(0);
	document.getElementById('header').deleteRow(0);
	window.print();
}

function ReloadPage(){
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function showList(){
	document.form_.show_list.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

</script>

<body marginheight="0" >
<%

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
														null);
if(iAccessLevel == 0) 
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Executive Management System","ENROLLMENT",request.getRemoteAddr(),
														null);
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
boolean bolForceWriteMF = false; // force to write M / F if all employees are part time!

if ( WI.fillTextValue("show_list").equals("1")){
	vRetResult = hrStat.getFacultyHeadCount(dbOP);
	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();
}

%>
<form action="./hr_faculty_head_count.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
	  <% strTemp = WI.fillTextValue("cut_off_date");
	  	 if (strTemp.length() == 0)
		 	strTemp = WI.getTodaysDate(1);
		  else
		  	strTemp = WI.formatDate(strTemp, 6);
	   %>  	
      <td height="25" colspan="4" ><div align="center"><strong>FACULTY MANPOWER as of <%=strTemp%> </strong></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="header">
    <tr> 
      <td height="25" colspan="4">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%" class="fontsize11">Date of Reporting </td>

	  <% strTemp = WI.fillTextValue("cut_off_date");
	  	 if (strTemp.length() == 0)
		 	strTemp = WI.getTodaysDate(1);
	   %>  		  
	  
      <td width="17%"><input name="cut_off_date" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  value="<%=strTemp%>" size="10" maxlength="4">
	  <a href="javascript:show_calendar('form_.cut_off_date');" 
	  	title="Click to select date" onMouseOver="window.status='Select date';return true;"
		onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>	  </td>
      <td width="65%"><a href="javascript:showList()"%><img src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" valign="bottom" class="fontsize11"><strong>Note : This Report requires entries in the <font color="#FF0000">Service Record</font></strong> </td>
    </tr>
  </table>
  
 <% if (vRetResult != null && vRetResult.size() > 1) {
 	
 	
	Vector vRanks = (Vector)vRetResult.elementAt(0);

	int iNumRanks = vRanks.size();

	
	String strRowSpan = "";
	
//	System.out.println("vRanks : " + vRanks);
	
	if (vRanks.elementAt(0)  == null) 
	strRowSpan = " rowspan=\"2\"";
		
	
	
	int iExtraLength = 0;
	
	int[] iColTotals = new int[iNumRanks+9];
	int iIndex = 0;
	
	for (int iNit = 0; iNit < iColTotals.length ; iNit++)
		iColTotals[iNit] = 0;
	
	int iRank = 0;
	int iRowTotals = 0; 
	int iRowMaleTotal = 0;
	int iRowFemaleTotal = 0;
	int iColGroupTotal = 0;
	String[] astrPTFT = {"","FULLTIME", "PART-TIME", "CONS", "CONC"};
	
%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td>&nbsp;</td>
	</tr>  

  </table> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td rowspan="3" class="thinborder"><div align="center"><strong><font size="2">
	  <% if (strSchCode.startsWith("AUF")) {%> UNIT <%}else{%> OFFICE 
	  <%}%>
	  
	  </font></strong></div></td>
      <td colspan="<%=iNumRanks%>" class="thinborder"><div align="center"><strong>FULL - TIME</strong> </div></td>
      <td colspan="6" class="thinborder"><div align="center"><strong>PART - TIME </strong></div></td>
	  </td>
      <td rowspan="2" align="center" class="thinborder" colspan="3"><strong>GRAND TOTAL</strong> </td>
      <td rowspan="2" align="center" class="thinborder">&nbsp;</td>
    </tr>
    <tr>
      <% 
	  	 for (iIndex = 0; iIndex < iNumRanks ; iIndex += 3){
	  		if (!(WI.getStrValue((String)vRanks.elementAt(iIndex),"1")).equals("1")){
				break;
			}
	  %> 
      <td height="20" colspan="3" class="thinborder">
	  	<div align="center"><strong>
			<%=WI.getStrValue((String)vRanks.elementAt(iIndex+1),"&nbsp;").toUpperCase()%></strong></div></td>
      <%}%> 
      <td height="20" colspan="3" class="thinborder">
	  	<div align="center"><strong>OUTSIDE AUF</strong></div></td>
      <td height="20" colspan="3" class="thinborder">
	  	<div align="center"><strong>WITHIN AUF</strong></div></td>
    </tr>
    <tr>
      <%
	  	for (iIndex = 0; iIndex < iNumRanks ; iIndex += 3){ 
	  		if (!(WI.getStrValue((String)vRanks.elementAt(iIndex),"1")).equals("1")){
				break;
			}
	  %> 
      <td width="4%" height="20" class="thinborder" ><div align="center">M</div></td>
      <td width="4%" class="thinborder" ><div align="center">F</div></td>
      <td width="5%" class="thinborder" ><div align="center"><strong>T</strong></div></td>
	  <%}%> 
      <td width="4%" align="center" class="thinborder" >M</td>
      <td width="4%" align="center" class="thinborder" >F</td>
      <td width="5%" align="center" class="thinborder" ><strong>T</strong></td>
      <td width="4%" align="center" class="thinborder" >M</td>
      <td width="4%" align="center" class="thinborder" >F</td>
      <td width="5%" align="center" class="thinborder" ><strong>T</strong></td>
      <td width="4%" align="center" class="thinborder" >M</td>
      <td width="4%" align="center" class="thinborder" >F</td>
      <td width="5%" align="center" class="thinborder" ><strong>T</strong></td>
      <td width="5%" align="center" class="thinborder" ><font style="font-size:9px">w/o con</font></td>	  
  </tr>

  
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
		iRowMaleTotal = 0;
		iRowFemaleTotal = 0;		
%>
    <tr>
      <td height="18" class="thinborder">&nbsp;<%=strCurrentCollege%></td>
	  
	  <% for (iRank = 0 ;  iRank < iNumRanks; iRank += 3) {
	  
	  	iColGroupTotal = 0;
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
			iRowMaleTotal += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iColGroupTotal += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
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
			iRowFemaleTotal += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iColGroupTotal += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			i += 6; bolIncremented = true; 
		}else{
			strTemp = "&nbsp;";
		}
		iIndex++;
		iColTotals[iIndex++] += iColGroupTotal;
	  %>
      <td class="thinborder"><div align="center"><%=strTemp%></div></td>
	  <% if (iColGroupTotal == 0) 
		  	strTemp = "&nbsp;";
		else 
			strTemp = Integer.toString(iColGroupTotal);
		%>
      <td class="thinborder"><div align="center"><strong><%=strTemp%></strong></div></td>
	  <%} // end of full time 
	  	iColGroupTotal = 0;
	    if (i < vRetResult.size()
			&& strCurrentCollege.equals((String)vRetResult.elementAt(i)) // college
			&& ((String)vRetResult.elementAt(i+4)).equals("0") // gender
			&& ((String)vRetResult.elementAt(i+3)).equals("-1") 
			&& ((String)vRetResult.elementAt(i+2)).equals("2")) 
	   { 
			strTemp = (String)vRetResult.elementAt(i+5);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iColTotals[iIndex] += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iRowMaleTotal += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iColGroupTotal += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
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
			&& ((String)vRetResult.elementAt(i+4)).equals("1") // gender
			&& ((String)vRetResult.elementAt(i+3)).equals("-1") // status
			&& ((String)vRetResult.elementAt(i+2)).equals("2")) //  pt ft
	   { 
			
			strTemp = (String)vRetResult.elementAt(i+5);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iColTotals[iIndex] += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iRowFemaleTotal += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iColGroupTotal += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			i += 6; bolIncremented = true; 
		}else{
			strTemp = "&nbsp;";
		}
		iIndex++;
		iColTotals[iIndex++] += iColGroupTotal;		
	  %>
      <td class="thinborder"><div align="center"><%=strTemp%></div></td>
	  <% if (iColGroupTotal == 0) 
		  	strTemp = "&nbsp;";
		else 
			strTemp = Integer.toString(iColGroupTotal);
		%>	  
      <td class="thinborder"><div align="center"><strong><%=strTemp%></strong></div></td>
<% if (strSchCode.startsWith("AUF")) {%>
	  <%
		 iColGroupTotal = 0;  
	  	if (i < vRetResult.size()
			&& strCurrentCollege.equals((String)vRetResult.elementAt(i)) // college
			&& ((String)vRetResult.elementAt(i+4)).equals("0") // gender
			&& ((String)vRetResult.elementAt(i+3)).equals("0") // status 
			&& ((String)vRetResult.elementAt(i+2)).equals("2")) // PT FT
	   { 
			
			strTemp = (String)vRetResult.elementAt(i+5);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iColGroupTotal += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iColTotals[iIndex] += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			iRowMaleTotal += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
			i += 6; bolIncremented = true; 

		}else{
			strTemp = "&nbsp;";
		}
		iIndex++;
	  %>

      <td class="thinborder"><div align="center"><%=strTemp%></div></td>

<%  if (i < vRetResult.size()
		&& strCurrentCollege.equals((String)vRetResult.elementAt(i)) // college
		&& ((String)vRetResult.elementAt(i+4)).equals("1") // gender
		&& ((String)vRetResult.elementAt(i+3)).equals("0") // status 
		&& ((String)vRetResult.elementAt(i+2)).equals("2")) // PT
   { 
		strTemp = (String)vRetResult.elementAt(i+5);
		iRowTotals += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
		iColGroupTotal += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));		
		iColTotals[iIndex] += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
		iRowFemaleTotal += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
		i += 6; 
		bolIncremented = true; 
	}else{
		strTemp = "&nbsp;";
	}
	iIndex++;
	iColTotals[iIndex++] += iColGroupTotal;	
 %>
      <td class="thinborder"><div align="center"><%=strTemp%></div></td>
	  <% if (iColGroupTotal == 0) 
		  	strTemp = "&nbsp;";
		else 
			strTemp = Integer.toString(iColGroupTotal);
		%>		  
      <td class="thinborder"><div align="center"><strong><%=strTemp%></strong></div></td>
<%}  iColTotals[iIndex++] += iRowMaleTotal;%> 
      <td class="thinborder"><div align="center"><%=iRowMaleTotal%></div></td>
<%  iColTotals[iIndex++] += iRowFemaleTotal;%> 
      <td class="thinborder"><div align="center"><%=iRowFemaleTotal%></div></td>
<%  iColTotals[iIndex++] += iRowTotals;%>
      <td class="thinborder"><div align="center"><strong><%=iRowTotals%></strong></div></td>
      <td class="thinborder"><div align="center"><strong><%=iRowTotals - iColTotals[iIndex-4]%></strong></div></td>	  
    </tr>

<%
	if (!bolIncremented){
		System.out.println(vRetResult);
		System.out.println(i);
		break;
	}
  } // for loop i = 1
%>

    <tr>
      <td height="18" class="thinborder">&nbsp;TOTAL</td>
      <%
	  	
	  	for (iIndex = 0; iIndex < iNumRanks ; iIndex += 3){ 
	  %> 
      <td align="center" class="thinborder"><%=iColTotals[iIndex]%></td>
      <td align="center" class="thinborder"><%=iColTotals[iIndex+1]%></td>
      <td align="center" class="thinborder"><strong><%=iColTotals[iIndex+2]%></strong></td>
	  <%}%>
      <td align="center" class="thinborder">&nbsp;<%=iColTotals[iIndex++]%></td>
      <td align="center" class="thinborder">&nbsp;<%=iColTotals[iIndex++]%></td>
      <td align="center" class="thinborder">&nbsp;<strong><%=iColTotals[iIndex++]%></strong></td>
      <td align="center" class="thinborder">&nbsp;<%=iColTotals[iIndex++]%></td>
      <td align="center" class="thinborder">&nbsp;<%=iColTotals[iIndex++]%></td>
      <td align="center" class="thinborder">&nbsp;<strong><%=iColTotals[iIndex++]%></strong></td>
      <td align="center" class="thinborder">&nbsp;<%=iColTotals[iIndex++]%></td>
      <td align="center" class="thinborder">&nbsp;<%=iColTotals[iIndex++]%></td>
      <td align="center" class="thinborder">&nbsp;<strong><%=iColTotals[iIndex]%></strong></td>
      <td align="center" class="thinborder">&nbsp;<strong><%=iColTotals[iIndex] - iColTotals[iIndex-3]%></strong></td>
    </tr>

  </table>

<% if (strSchCode.startsWith("AUF")) { %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
	<tr>
		<td width="18%">&nbsp;</td>
		<td width="9%">&nbsp;</td>
		<td width="7%">&nbsp;</td>
		<td width="7%">&nbsp;</td>
		<td width="9%">&nbsp;</td>
		<td width="50%">&nbsp;</td>				
	</tr>  
<%  	
	 iColGroupTotal = 0;
	for (iIndex = 0; iIndex < iNumRanks ; iIndex += 3){ 
		iColGroupTotal += iColTotals[iIndex+2];
%>
	<tr>
		<td width="18%"><strong>&nbsp;<%=(String)vRanks.elementAt(iIndex+1)%></strong></td>
		<td width="9%"><div align="right"><strong><%=iColTotals[iIndex+2]%>&nbsp;&nbsp;</strong></div></td>
		<td width="7%">&nbsp; </td>
		<td width="7%">&nbsp; </td>
		<td width="9%">&nbsp;</td>
		<td width="50%">&nbsp; </td>				
	</tr>
<%}%>
	<tr>
	  <td class="thinborderTOP"><strong>&nbsp;Total Full Time</strong></td>
	  <td class="thinborderTOP" align="right"> <strong><%=iColGroupTotal%>&nbsp;&nbsp;</strong>	  </td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td align="right">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
<% 
	iColGroupTotal = iColTotals[iIndex+2]; 
%>
	<tr>
	  <td><strong>&nbsp;Outside AUF</strong></td>
	  <td align="right">
	    <strong><%=iColTotals[iIndex+2]%>&nbsp;	    </strong></td>
	  <td>&nbsp;</td>
	  <td><strong>Male </strong></td>
	 <% iRowTotals = 0;
	 	for (int i = 0; i < iColTotals.length - 4; i+= 3) 
	 		iRowTotals += iColTotals[i]; %>
			
	  <td align="right"><strong><%=iRowTotals%>&nbsp;</strong></td>
	  <td>&nbsp;</td>
    </tr>
<% 
	iIndex +=  3;
	iColGroupTotal += iColTotals[iIndex+2]; 
%>

	<tr>
	  <td><strong>&nbsp;Within AUF </strong></td>
	  <td align="right"><strong><%=iColTotals[iIndex+2]%>&nbsp;</strong></td>
	  <td>&nbsp;</td>
	  <td><strong>Female</strong></td>
	 <% iRowTotals = 0;
	 	for (int i = 0; i < iColTotals.length - 4; i+= 3) 
	 		iRowTotals += iColTotals[i+1]; %>	  
	  <td align="right"><strong><%=iRowTotals%>&nbsp;</strong></td>
	  <td>&nbsp;</td>
    </tr>
	<tr>
	  <td class="thinborderTOP"><strong>&nbsp;Total Part Time</strong></td>
	  <td align="right" class="thinborderTOP"><strong><%=iColGroupTotal%>&nbsp;</strong></td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td align="right">&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
	<tr>
	  <td>&nbsp;</td>
	  <td align="right">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td align="right">&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
	<tr>
	  <td colspan="2"><strong>Total W/ Concurrent </strong></td>
	  <td align="right"><strong>&nbsp;<%=iColTotals[iColTotals.length-1]%></strong></td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
	<tr>
	  <td colspan="2"><strong>Concurrent</strong></td>
	  <td align="right"><strong>&nbsp;<%=iColTotals[iColTotals.length-4]%></strong></td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
	<tr>
	  <td class="thinborderTOP">&nbsp;</td>
	  <td align="right" class="thinborderTOP">&nbsp;</td>
	  <td class="thinborderTOP">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td align="right">&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>	
	<tr>
	  <td><strong>Total Head Count</strong> </td>
	  <td align="right"><strong><%=iColTotals[iColTotals.length-1] - iColTotals[iColTotals.length-4]%>&nbsp;</strong></td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td align="right">&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
  </table>
  
  
  
  
  
  
<% }
 } 
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
	<% if (vRetResult != null && vRetResult.size() > 1) { %> 
    <tr>
      <td height="25"><div align="center"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0"></a><font size="1">click to print report</font> </div></td>
    </tr>
	<%}%> 
  </table>
  <input type="hidden" name="print_page" value="0">
  <input type="hidden" name="show_list" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>