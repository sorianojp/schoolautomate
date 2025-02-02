<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Training Statistics</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize10{
		font-size:11px;
	}
</style>
</head>

<body onLoad="window.print();">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	int iSearchResult = 0;
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Education","hr_stat_trainings.jsp");

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
														"hr_stat_trainings.jsp");
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

String strTemp2  = null;

HRStatsReports hrStat = new HRStatsReports(request);

Vector vRetResult = hrStat.hrDemoTrainings(dbOP);
Vector vPerCollege = null;
Vector vSummary = null;
	
	if (vRetResult != null){
		iSearchResult = hrStat.getSearchCount();
		
	}else{
		strErrMsg = hrStat.getErrMsg();
	}

%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <% if ( strErrMsg  != null) {%>
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
 <%}%>
    <tr> 
      <td width="3%" height="25"><div align="center"><font size="2">
	  <strong>
	  	<%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <%=SchoolInformation.getInfo1(dbOP,false,false)%> <br> <br>


	<% if (request.getParameter("title_report") != null && request.getParameter("title_report").trim().length() > 0) {%>
		<strong><%=request.getParameter("title_report")%></strong><br>
<br>
	<%}%>
        </font></div> </td>
    </tr> 
  </table>
  <% if (vRetResult != null && vRetResult.size() > 0) {
	    vSummary  = (Vector) vRetResult.elementAt(0);
  		vPerCollege  = (Vector) vRetResult.elementAt(1);
  %>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"><b>&nbsp;TOTAL RESULT : <%=iSearchResult%> </b>

      </td>
      <td>&nbsp; </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="17%" height="25"  class="thinborder"><div align="center"><strong><font size="1">EMP NAME </font></strong></div></td>
      <td width="9%"  class="thinborder"><div align="center"><font size="1"><strong>OFFICE 
      UNIT </strong></font></div></td>
      <td width="21%" align="center" class="thinborder"><font size="1"><strong>TITLE 
        OF SEMINAR / TRAINING</strong></font></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>DATE<br>
      (DURATION )</strong></font></div></td>
      <td width="21%" class="thinborder"><font size="1"><strong>VENUE</strong></font></td>
      <td width="11%" class="thinborder"><font size="1"><strong>APPROVED BUDGET</strong></font></td>
      <td width="9%" class="thinborder"><font size="1"><strong>SCOPE</strong></font></td>
    </tr>
    <% 	
	String[] astrConvertDurationUnit={" hour(s)", " day(s)", " week(s)", " month(s)", " year(s)"};
			for (int i=2; i < vRetResult.size(); i+=17){ %>
    <tr> 
      <td height="23" class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+12),
	  													(String)vRetResult.elementAt(i+13),
														(String)vRetResult.elementAt(i+14),4)%></td>
	  <% strTemp = (String)vRetResult.elementAt(i+1);
	  	  if (strTemp == null) 
		  	strTemp = (String)vRetResult.elementAt(i+2);
		  else 
		  	strTemp += WI.getStrValue((String)vRetResult.elementAt(i+2)," :: ","","");
	  %>
	  
      <td class="thinborder"> <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+9) + WI.getStrValue((String)vRetResult.elementAt(i+10)," - " ,"","")%>
	 <% strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6),"<br> Dur : ","","");
	    if (strTemp.length() > 0) {
			if ((String)vRetResult.elementAt(i+7) != null) 
				strTemp +=  astrConvertDurationUnit[Integer.parseInt((String)vRetResult.elementAt(i+7))];
		}%> <%=strTemp%>
	  </td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3))%></td>

    </tr>
    <%}// end for loop%>
</table>
<DIV style="page-break-before:always" >&nbsp;</DIV>

<%	if (WI.fillTextValue("per_college_summary").equals("1")
			&& vPerCollege != null && vPerCollege.size() > 0) {%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
  	<tr>
  	  <td height="25" colspan="4" class="thinborder"><div align="center"><strong>LISTING OF SEMINAR ATTENDANCE</strong> </div></td>
    </tr>
	
	
	<% for (int i = 0; i < vPerCollege.size();) {  
	
	 if((String)vPerCollege.elementAt(i) != null) { 
	%> 
  	<tr>
  	  <td height="20" colspan="4" bgcolor="#EFF4FA" class="thinborder">&nbsp;<strong><%=(String)vPerCollege.elementAt(i)%></strong></td>
    </tr>
  	<tr>
		<td width="25%" height="20" align="center" class="thinborder"> <%if(bolIsSchool){%>College<%}else{%>Division<%}%> / Office </td>
		<td width="25%" class="thinborder">&nbsp; No.</td>
		<td width="25%" class="thinborder"> <div align="center"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> :: Dept		</div></td>
	    <td width="25%" class="thinborder">&nbsp; No.</td>
  	</tr>
	<%}%> 
  	<tr>
		<td width="24%" height="25" class="thinborder">&nbsp;<%=(String)vPerCollege.elementAt(i+1)%></td>
		<td width="28%" class="thinborder">&nbsp;<%=(String)vPerCollege.elementAt(i+2)%></td>
	 <% i += 3;
	 	strTemp ="";
		strTemp2 = "";
	 	if (i < vPerCollege.size() && 
			(String)vPerCollege.elementAt(i) == null) {
				strTemp = (String)vPerCollege.elementAt(i+1);
				strTemp2 = (String)vPerCollege.elementAt(i+2);
			i+=3;
		 }	
	%>
		<td width="24%" class="thinborder">&nbsp;<%=strTemp%></td>
	    <td width="24%" class="thinborder">&nbsp;<%=strTemp2%></td>
    </tr>
   <%} // end for loop%>
   </table>
<%}

	if (WI.fillTextValue("per_employee").equals("1")
			&& vSummary != null && vSummary.size() > 0) {
%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
  	<tr>
  	  <td height="25" colspan="6" class="thinborder"><div align="center"><strong>LIST OF SEMINAR CATG PER EMPLOYEE </strong> </div></td>
    </tr>
  	<tr>
		<td width="31%" height="20" class="thinborder"><strong>&nbsp;Employee</strong></td>
		<td width="11%" class="thinborder"><strong>Internal </strong></td>
		<td width="10%" class="thinborder"><strong>External </strong></td>
		<td width="28%" class="thinborder"><strong>&nbsp;Employee</strong></td>
	    <td width="10%" class="thinborder">&nbsp;<strong> Internal </strong></td>
  	    <td width="10%" class="thinborder"><strong>&nbsp;External</strong></td>
  	</tr>
	
	<% 
	String strCurrID = null;
	String strCollege = null;
	String strCurrName = null;
	
	for (int i = 0; i < vSummary.size();) {  
	
		if (i == 0) 
			strCurrID = (String)vSummary.elementAt(i+1);
			
	 if((String)vSummary.elementAt(i) != null) { 
	 
	%> 
  	<tr>
  	  <td height="20" colspan="6" bgcolor="#EFF4FA" class="thinborder">&nbsp;
	  				<strong><%=(String)vSummary.elementAt(i)%></strong>
	   </td>
    </tr>
	<%
		vSummary.setElementAt(null, i);
	}%> 

  	<tr>
		<td width="31%" height="25" class="thinborder">&nbsp;<%=(String)vSummary.elementAt(i+2)%></td>
		<%  strCurrID = ""; strCurrName = "";
			if (  i < vSummary.size() && vSummary.elementAt(i) == null) {
				strCurrID = (String)vSummary.elementAt(i+1);
				strCurrName = (String)vSummary.elementAt(i+2);
			}
		
			if ( i < vSummary.size() && 
			    vSummary.elementAt(i) == null  && 
				strCurrID.equals((String)vSummary.elementAt(i+1))
				&& WI.getStrValue((String)vSummary.elementAt(i+3)).equals("0")) {
				
				strTemp = (String)vSummary.elementAt(i+4);
				i += 5;
				
			}else{
				strTemp = "";
			}
		%>
		<td width="11%" class="thinborder">&nbsp;<%=strTemp%></td>
		<% if ( i < vSummary.size() && 
			    vSummary.elementAt(i) == null  && 
				strCurrID.equals((String)vSummary.elementAt(i+1))
				&& WI.getStrValue((String)vSummary.elementAt(i+3)).equals("1")) {
				
				strTemp = (String)vSummary.elementAt(i+4);
				i += 5;
				
			}else{
				strTemp = "";
			}
		%>
		<td width="10%" class="thinborder">&nbsp;<%=strTemp%></td>
		<% strCurrID = ""; strCurrName = "";
			 if (  i < vSummary.size() && vSummary.elementAt(i) == null) {
				strCurrID = (String)vSummary.elementAt(i+1);
				strCurrName = (String)vSummary.elementAt(i+2);
			}
			if ( i < vSummary.size() && 
			    vSummary.elementAt(i) == null  && 
 				WI.getStrValue((String)vSummary.elementAt(i+3)).equals("0")) {

				strTemp = (String)vSummary.elementAt(i+4);
				i += 5;
				
			}else{
				strTemp = "";
			}
		%>
		<td width="28%" class="thinborder">&nbsp;<%=strCurrName%></td>
	    <td width="10%" class="thinborder">&nbsp;<%=strTemp%></td>
		<%  if ( i < vSummary.size() && 
			    vSummary.elementAt(i) == null  && 
				strCurrID.equals((String)vSummary.elementAt(i+1)) &&  
 				WI.getStrValue((String)vSummary.elementAt(i+3)).equals("1")) {

				strTemp = (String)vSummary.elementAt(i+4);
				i += 5;
				
			}else{
				strTemp = "";
			}
		%>		
        <td width="10%" class="thinborder">&nbsp;<%=strTemp%></td>
  	</tr>
   <%} // end for loop%>
  </table>
<%}

}%>
</body>
</html>
<%
	dbOP.cleanUP();
%>