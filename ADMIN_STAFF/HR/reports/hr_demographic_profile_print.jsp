<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Demographic Profile Print</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">

<style>
	.fontsize10{
		font-size:11px;
	}
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


HRStatsReports hrStat = new HRStatsReports(request);

boolean[] abolShowList = new boolean[22];
						
boolean bolShowID= WI.fillTextValue("show_id").equals("1");
					
int iIndex =1;

String[] astrCivilStatus={"","Single","Married","Separated", "Widow / Widower"};
String[] astrSalaryBasis = {"Monthly", "Daily", "Hourly"};
for(; iIndex <= 22; iIndex++){
	if(WI.fillTextValue("checkbox"+iIndex).equals("1"))
		abolShowList[iIndex] = true;	
}

Vector vRetResult = hrStat.hrDemographicProfile(dbOP);
	String[] astrConvertGender = {"Male","Female"};
	if (vRetResult != null)
		iSearchResult = hrStat.getSearchCount();
	else
		strErrMsg = hrStat.getErrMsg();
	
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
if(strSchCode == null)
	strSchCode = "";

%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <% if (strErrMsg  != null) {%>
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
<% } %>
    <tr> 
      <td width="3%" height="25"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <%=SchoolInformation.getInfo1(dbOP,false,false)%> <br> <br><br>


	<% if (request.getParameter("title_report") != null && request.getParameter("title_report").trim().length() > 0) {%>
		<strong><%=request.getParameter("title_report")%></strong><br>
<br>
<br>

	<%}%>
        </font></div> </td>
    </tr>
  </table>
  <% int iMaxEmployeePerPage = Integer.parseInt(WI.fillTextValue("max_lines"));
     int iIncrementNextPage  =iMaxEmployeePerPage + 2;  
     int iCount = 0;
	 //System.out.println(vRetResult.size());
  	if (vRetResult != null && vRetResult.size() > 0) {
  	Vector vServiceRec = null;
	 for (int i=0; i < vRetResult.size();){
	 	if (i != 0) 
			iMaxEmployeePerPage = iIncrementNextPage;
  %>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
	<% if (bolShowID) {%> 
      <td width="5%"  class="thinborder" align="center"><font size="1"><strong>ID NO.</strong></font></td> 
	<%}%>
      <td width="12%" height="25"  class="thinborder" align="center"> <font size="1"><strong>EMPLOYEE 
          NAME</strong></font> </td>
<%
if(!bolIsSchool)
	strTemp = "Division/Office";
else {
	if(strSchCode.startsWith("AUF"))
		strTemp = "UNIT";
	else	
		strTemp = "College/Dept";
}%>
      <td width="3%"  class="thinborder"><font size="1"><strong><%=strTemp.toUpperCase()%></strong></font></td>
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>POSITION</strong></font></td>	  
      <% iIndex = 1; if (abolShowList[iIndex++]){%>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">EMP. STATUS</font></strong></td>
      <%}if (abolShowList[14]){%>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">HIRING BATCH</font></strong></td>
      <%}if (abolShowList[15]){%>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">TEAM</font></strong></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="6%" align="center" class="thinborder"><strong><font size="1">MARITAL STATUS</font></strong></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="6%" class="thinborder"><font size="1"><strong>RELIGION</strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="8%" class="thinborder"><font size="1"><strong>NATIONALITY</strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="7%" class="thinborder"><font size="1"><strong>BIRTHDATE</strong></font></td>
      <td width="3%" class="thinborder"><font size="1"><strong>AGE</strong></font></td>
      <%}if (abolShowList[13]){%>
      <td width="3%" class="thinborder"><font size="1"><strong>GENDER</strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="9%" class="thinborder"><font size="1"><strong>PLACE OF BIRTH</strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="4%" class="thinborder"><font size="1"><strong>DATE OF ENTRY</strong></font></td>
			<%}if (abolShowList[16]){%>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>EXPIRY DATE </strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>LENGTH OF SERVICE</strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="5%" class="thinborder"><strong><font size="1">LICENSE</font></strong></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="3%" class="thinborder"><strong><font size="1">RANK</font></strong></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="3%" class="thinborder"><strong><font size="1">CON NO.</font></strong></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="10%" class="thinborder"><strong><font size="1">ADDRESS</font></strong></td>
			<%}if (abolShowList[18]){%>
      <td width="6%" align="center" class="thinborder"><strong><font size="1">IMMEDIATE HEAD</font></strong></td>
			<%}if (abolShowList[19]){%>
      <td width="6%" align="center" class="thinborder"><strong><font size="1">BLOOD TYPE </font></strong></td>
			<%}if (abolShowList[20]){%>
      <td width="6%" align="center" class="thinborder"><strong><font size="1">SALARY BASIS </font></strong></td>
			<%}if (abolShowList[21]){%>
      <td width="6%" align="center" class="thinborder"><strong><font size="1">JOB CODE </font></strong></td>
      <%}%>
    </tr>
    <% iCount = 1;		
		for (; i < vRetResult.size() && iCount < iMaxEmployeePerPage; i+=35,++iCount){
		vServiceRec = (Vector)vRetResult.elementAt(i+26);
		iIndex = 1;
	%>
    <tr>
	  <%if (bolShowID) {%> 
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td> 
	  <%}%> 
      <td height="25" class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2),
	  													(String)vRetResult.elementAt(i+3),
					 	  							    (String)vRetResult.elementAt(i+4),5)%></td>
	<% 
		strTemp = (String)vRetResult.elementAt(i+5);
		if (strTemp == null) strTemp = (String)vRetResult.elementAt(i+6);
		else strTemp += WI.getStrValue((String)vRetResult.elementAt(i+6)," :: ","","");
	%>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+12),"&nbsp;")%></td>	  
      <%if (abolShowList[iIndex++]){%>	
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+7),"&nbsp;")%></td>
      <%}if (abolShowList[14]){%>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+22),"&nbsp;")%></td>
      <%}if (abolShowList[15]){%>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+23),"&nbsp;")%></td>
      <%}if (abolShowList[iIndex++]){%>	
      <td class="thinborder">
	  	&nbsp;<%=astrCivilStatus[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+8),"0"))]%></td>
      <%}if (abolShowList[iIndex++]){%>	      
	  <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+13),"&nbsp;")%></td>
      <%}if (abolShowList[iIndex++]){%>		  
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+14),"&nbsp;")%></td>
      <%}if (abolShowList[iIndex++]){
	  		if ((String)vRetResult.elementAt(i+9) != null) {
				strTemp = "&nbsp;" +
						 ConversionTable.differenceInYearMonthDaysNow((String)vRetResult.elementAt(i+9));
				if (strTemp.indexOf("Years") != -1) 
					strTemp = strTemp.substring(0,strTemp.indexOf("Years"));
				else 
					strTemp = "&nbsp;";
			}else
				strTemp = "&nbsp;";
	  %>	
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <%}if (abolShowList[13]){%>
      <td class="thinborder"><%=astrConvertGender[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+21),"0"))]%></td>
      <%}if (abolShowList[iIndex++]){%>		  
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+10))%></td>
      <%}if (abolShowList[iIndex++]){%>	
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+11),"&nbsp;")%></td>
			<%}if (abolShowList[16]){%>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+24),"&nbsp;")%></td>
      <%}if (abolShowList[iIndex++]){
	  		if ((String)vRetResult.elementAt(i+11) != null) {
				if(vRetResult.elementAt(i+24) != null && ((String)vRetResult.elementAt(i+24)).length() > 6) {//valid end of contract
					java.util.Date dDateLHS = ConversionTable.convertMMDDYYYYToDate((String)vRetResult.elementAt(i+24));
					java.util.Date dDateRHS = ConversionTable.convertMMDDYYYYToDate((String)vRetResult.elementAt(i+11));
					
					strTemp = "&nbsp;" +
						 ConversionTable.differenceInYearMonthDays(dDateLHS, dDateRHS, 2);
						 
					//if(vRetResult.elementAt(i + 1).equals("05112")) {
					//	System.out.println(dDateLHS.toString());
					//	System.out.println(dDateRHS.toString());
					//}
				}
				else
					strTemp = "&nbsp;" +
						 ConversionTable.differenceInYearMonthDaysNow((String)vRetResult.elementAt(i+11));
						 
				if (strTemp.indexOf("Months") != -1) {
					strTemp = strTemp.substring(0,strTemp.indexOf("M")) + " Months";
				}else if (strTemp.indexOf("Month") != -1) 
					strTemp = strTemp.substring(0,strTemp.indexOf("M")) + " Month";

			}else
				strTemp = "&nbsp;";	  
	  %>
	  	
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <%}if (abolShowList[iIndex++]){%>	
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+15))%></td>
      <%}if (abolShowList[iIndex++]){%>	
	  <td class="thinborder">&nbsp;<%if(vServiceRec.size() > 1){%><%=vServiceRec.elementAt(1)%><%}else{%>&nbsp;<%}%><%//=WI.getStrValue((String)vRetResult.elementAt(i+18),"&nbsp;")%></td>
      <%}if (abolShowList[iIndex++]){%>	
	  <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+19),"&nbsp;")%></td>
      <%}if (abolShowList[iIndex++]){%>	
	  <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+20),"&nbsp;")%></td>
 <%}if (abolShowList[18]){
			 	strTemp = null;
			 	if(vServiceRec != null && vServiceRec.size() > 0){
					strTemp = WI.formatName((String)vServiceRec.elementAt(2), 
														 			(String)vServiceRec.elementAt(3), 
																	(String)vServiceRec.elementAt(4), 4);
				}
			 %>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>
			<%}if (abolShowList[19]){%>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+25),"&nbsp;")%></td>
			<%}if (abolShowList[20]){%>
      <td class="thinborder"><%=astrSalaryBasis[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+27),"0"))]%></td>
			<%}if (abolShowList[21]){
			 	strTemp = null;
			 	if(vServiceRec != null && vServiceRec.size() > 0){
					strTemp = (String)vServiceRec.elementAt(1);
				}
			 %>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>
	  <%}%>
    </tr>
    <%}// end of inner for loop %>
  </table>
<% if (i < vRetResult.size()) { %>
<DIV style="page-break-before:always">&nbsp;</DIV>
<%}
} // END OF outer for loop %>
  
<%}%>
</body>
</html>
<%
	dbOP.cleanUP();
%>