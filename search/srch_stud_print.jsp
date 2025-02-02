<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
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
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>

</head>

<body onLoad="window.print();">
<%@ page language="java" import="utility.*,search.SearchStudent,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-SEARCH-Students","srch_stud.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

int iSearchResult = 0;
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsFATIMA = strSchCode.startsWith("FATIMA");

SearchStudent searchStud = new SearchStudent(request);
	vRetResult = searchStud.searchGeneric(dbOP);
	if(vRetResult == null)
		strErrMsg = searchStud.getErrMsg();
	else
		iSearchResult = searchStud.getSearchCount();

int iRowsPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_pg"),"40"));

String[] astrConvertTerm = {"Summer","1st Term","2nd Term","3rd Term", "All Sem"};

  int iNameFormat = Integer.parseInt(WI.getStrValue(WI.fillTextValue("name_format"),"4"));
  int iCount = 0;
  String strCollegeName = null;
  boolean bolPrintPerCollege = false;
  if(WI.fillTextValue("per_course").length() > 0)
 	bolPrintPerCollege = true;
	
String strReportTitle = WI.fillTextValue("report_title");
if(strReportTitle.length() > 0) 
	strReportTitle = ConversionTable.replaceString(WI.fillTextValue("report_title"),"\r","<br>");
else {
	strReportTitle = " STUDENT LISTING ";
	if(WI.fillTextValue("sy_from").length() > 0) {
		strReportTitle += " FOR: "+ astrConvertTerm[Integer.parseInt(WI.getStrValue(WI.fillTextValue("semester"), "4"))]+
			", "+WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to");
	}
	if(WI.fillTextValue("doe_fr").length() > 0) {
		if(WI.fillTextValue("doe_to").length() > 0) 
			strReportTitle +="<br>Date Enrolled: "+WI.fillTextValue("doe_fr") + " - "+WI.fillTextValue("doe_to");
		else	
			strReportTitle +="<br>Date Enrolled: "+WI.fillTextValue("doe_fr");
	}
}
if(vRetResult != null && vRetResult.size() > 0)	
for(int i = 0; i< vRetResult.size(); ) {
//if(i == 0 || ((i-16)/16)%iRowsPerPage == 0){%>
<%if(i > 0){%>
<DIV style="page-break-after:always">&nbsp;</DIV>
<%}//break only if it is not last page.%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25" colspan="2" class="thinborderBOTTOM"><div align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
        <br>
		<%=strReportTitle%>
        <br>
      </div></td>
  </tr>
<!--
  <tr>
    <td height="19" colspan="2"><hr size="1"></td>
  </tr>
-->
  <tr valign="bottom">
    <td width="51%" height="18"><%if(i == 0) {%>Total Students :<b> <%=iSearchResult%></b><%}%></td>
    <td width="49%" height="18" align="right">Date &amp; Time Printed : <%=WI.getTodaysDateTime()%> &nbsp;&nbsp;</td>
  </tr>
</table>
<%//}
	strCollegeName = (String)vRetResult.elementAt(i + 12);
	if(bolPrintPerCollege){%>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr><td height="25" valign="bottom"><b><%=strCollegeName%></b></td></tr>
		</table>
	<%}

boolean bolShowCAddr = false; 
boolean bolShowHAddr = false; 
boolean bolShowEAddr = false; 
boolean bolShowLastSchool = false; 
boolean bolShowStudEmailTel = false;
boolean bolShowStudStat = false; 
boolean bolShowCurYear = false;

boolean bolShowFather  = false;
boolean bolShowMother  = false;

if(WI.fillTextValue("show_caddr").length() > 0)
	bolShowCAddr = true;
if(WI.fillTextValue("show_haddr").length() > 0)
	bolShowHAddr = true;
if(WI.fillTextValue("show_eaddr").length() > 0)
	bolShowEAddr = true;
if(WI.fillTextValue("show_lastschool").length() > 0) 
	bolShowLastSchool = true;
if(WI.fillTextValue("show_stud_emai_tel").length() > 0) 
	bolShowStudEmailTel = true;
if(WI.fillTextValue("show_reg_irreg").length() > 0) 
	bolShowStudStat = true;
if(WI.fillTextValue("show_cy_info").length() > 0) 
	bolShowCurYear = true;
if(WI.fillTextValue("show_father_info").length() > 0) 
	bolShowFather = true;
if(WI.fillTextValue("show_mother_info").length() > 0) 
	bolShowMother = true;
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr style="font-weight:bold" align="center">
    <td width="5%" class="thinborder" align="center"><strong><font size="1">SL
      #</font></strong></td>
    <%if(WI.fillTextValue("show_id").length() > 0) {%>
    <td width="12%" height="25" class="thinborder"><font size="1">STUDENT ID</font></td>
    <%}%>
    <td width="30%" class="thinborder"><font size="1">STUDENT NAME</font></td>
    <%if(WI.fillTextValue("show_gender").length() > 0) {%>
    <td width="5%" class="thinborder"><font size="1">GENDER</font></td>
    <%}if(WI.fillTextValue("show_course").length() > 0) {%>
    <td width="<%if(strSchCode.startsWith("CGH")){%>10%<%}else{%>22%<%}%>" align="center" class="thinborder"><font size="1">COURSE/MAJOR</font></td>
    <%}if(WI.fillTextValue("show_yr").length() > 0) {%>
    <td width="5%" align="center" class="thinborder"><strong><font size="1">YEAR</font></strong></td>
    <%}if(WI.fillTextValue("show_section").length() > 0) {%>
    <td width="10%" class="thinborder"><font size="1">SECTION</font></td>
    <%}if(WI.fillTextValue("search_foreign").length() > 0 || WI.fillTextValue("search_foreign_gspis").length() > 0) {%>
    <td width="5%" class="thinborder"><font size="1">NATIONALITY</font></td>
    <td width="10%" class="thinborder"><font size="1">PLACE OF BIRTH</font></td>
    <%}if(WI.fillTextValue("show_dob").length() > 0) {%>
    <td width="10%" class="thinborder"><font size="1">DOB</font></td>
<%}if(bolShowCAddr) {%>
    <td width="25%" class="thinborder"><font size="1">CURRENT ADDRESS </font></td>
<%}if(bolShowHAddr) {%>
    <td width="25%" class="thinborder" style="font-size:9px;">HOME ADDRESS </td>
<%}if(bolShowEAddr) {%>
    <td width="25%" class="thinborder" style="font-size:9px;">EMERGENCY ADDRESS </td>
<%}if(bolShowLastSchool) {%>
    <td width="25%" class="thinborder" style="font-size:9px; font-weight:bold">LAST SCHOOL ATTENDED</td>
<%}if(bolShowStudEmailTel){%>
    <td width="13%" class="thinborder" style="font-size:9px; font-weight:bold">STUDENT EMAIL</td>
    <td width="12%" class="thinborder" style="font-size:9px; font-weight:bold">STUDENT MOBILE</td>
<%}if(bolShowStudStat){%>
    <td width="12%" class="thinborder" style="font-size:9px; font-weight:bold">STUDENT STATUS </td>
<%}if(bolShowCurYear){%>
    <td width="12%" class="thinborder" style="font-size:9px; font-weight:bold">CURRICULUM YEAR </td>
<%}if(bolShowFather){%>
    <td width="12%" class="thinborder" style="font-size:9px; font-weight:bold">FATHER NAME </td>
<%}if(bolShowMother){%>
    <td width="12%" class="thinborder" style="font-size:9px; font-weight:bold">MOTHER NAME </td>
<%}%>
  </tr>
  <%
for(; i< vRetResult.size(); i += 26) {
	if(bolPrintPerCollege && strCollegeName.compareTo( (String)vRetResult.elementAt(i + 12)) != 0) {//System.out.print("break here.");
		iCount = 0;
		break;
	}%>
  <tr valign="top">
    <td class="thinborder"><%=++iCount%>.</td>
    <%if(WI.fillTextValue("show_id").length() > 0) {%>
    <td height="20" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
    <%}%>
    <td class="thinborder"><%=WebInterface.formatName((String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),
						(String)vRetResult.elementAt(i+2),iNameFormat)%></td>
    <%if(WI.fillTextValue("show_gender").length() > 0) {%>
    <td align="center" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+5),"n/f")%></td>
    <%}if(WI.fillTextValue("show_course").length() > 0) {%>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%> <%
	  if(vRetResult.elementAt(i+7) != null){%>
      /<%=(String)vRetResult.elementAt(i+7)%> <%}%></td>
    <%}if(WI.fillTextValue("show_yr").length() > 0) {%>
    <td align="center" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 8),"n/a")%></td>
    <%}if(WI.fillTextValue("show_section").length() > 0) {%>
    <td align="center" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%></td>
    <%}if(WI.fillTextValue("search_foreign").length() > 0 || WI.fillTextValue("search_foreign_gspis").length() > 0) {%>
    <td align="center" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 10),"&nbsp;")%></td>
    <td align="center" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 11),"&nbsp;")%></td>
    <%}if(WI.fillTextValue("show_dob").length() > 0) {
	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+13));
	if(strTemp.length() > 0) {
		if(!strTemp.startsWith("10") && !strTemp.startsWith("11") && !strTemp.startsWith("12"))
			strTemp = "0"+strTemp;
		if(strTemp.length() == 9)
			strTemp = strTemp.substring(0,3)+"0"+strTemp.substring(3);
	}
	%>
    <td align="center" class="thinborder"><font size="1"><%=WI.getStrValue(strTemp,"&nbsp;")%></font></td>
<%}if(bolShowCAddr) {%>
    <td class="thinborder"><font size="1"><%=WI.getStrValue(vRetResult.elementAt(i+18),"&nbsp;")%></font></td>
<%}if(bolShowHAddr) {%>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+22),"&nbsp;")%></td>
<%}if(bolShowEAddr) {%>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+23),"&nbsp;")%></td>
<%}if(bolShowLastSchool) {%>
	    <td class="thinborder"><font size="1"><%=WI.getStrValue(vRetResult.elementAt(i+15),"&nbsp;")%></font></td>
    <%}if(bolShowStudEmailTel){%>
        <td class="thinborder" style="font-size:9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+16),"&nbsp;")%></td>
        <td class="thinborder" style="font-size:9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+17),"&nbsp;")%></td>
      <%}if(bolShowStudStat){%>
        <td class="thinborder" style="font-size:9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+19),"&nbsp;")%></td>
<%}if(bolShowCurYear){%>
     	<td class="thinborder" style="font-size:9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+20),"&nbsp;")%><%=WI.getStrValue((String)vRetResult.elementAt(i+21),"-","","")%></td>
<%}if(bolShowFather){%>
        <td class="thinborder" style="font-size:9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+24),"&nbsp;")%></td>
<%}if(bolShowMother){%>
        <td class="thinborder" style="font-size:9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+25),"&nbsp;")%></td>
<%}%>
  </tr>
  <%//System.out.println((i+16)/16);
  	if(i/26 > 10 && ((i+26)/26)%iRowsPerPage == 0) {//System.out.print("break here."+ ((i+16)/16) );
		i += 26;
		break;
	}

  }//end of loop %>
</table>
<%}//end of outer for loop.
%>


</body>
</html>
<%
dbOP.cleanUP();
%>
