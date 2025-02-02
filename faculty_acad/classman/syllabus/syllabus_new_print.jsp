<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMSyllabusNew" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FACULTY/ACAD. ADMIN-CLASS MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FACULTY/ACAD. ADMIN"),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../faculty_acad/faculty_acad_bottom_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out.Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	//end of authenticaion code.

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-CLASS MANAGEMENT-Syllabus","syllabus_new.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"><%=strErrMsg%></p>
		<%
		return;
	}

CMSyllabusNew cmsNew   = new CMSyllabusNew();
Vector vSubInfo     = null;
Vector vGeneralInfo = null; Vector vFacultyInfo = null;

///
Vector vTempInfo       = null;

vGeneralInfo = cmsNew.operateOnGC(dbOP, request, 4);
if(vGeneralInfo.size() > 0 && vGeneralInfo.elementAt(0) == null) {
	vGeneralInfo.removeElementAt(0);
	strErrMsg = cmsNew.getErrMsg();
}
String strFacultyIndex = (String)request.getSession(false).getAttribute("userIndex");

vFacultyInfo = cmsNew.operateOnID(dbOP, request, 4,	strFacultyIndex);
if(vFacultyInfo.size() > 0 && vFacultyInfo.elementAt(0) == null) {
	vFacultyInfo.removeElementAt(0);
	strErrMsg = cmsNew.getErrMsg();
}
String strSubIndex = WI.fillTextValue("sub_index");

////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////GENERIC OPERATIONS //////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////

if(strSubIndex.length() > 0) {
	vSubInfo = cmsNew.getSubInfo(dbOP,strSubIndex, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"));
	if(vSubInfo == null) 
		strErrMsg = cmsNew.getErrMsg();
}


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";


java.sql.ResultSet rs = null;
String[] astrConvertSem = {"Summer", "1st Sem", "2nd Sem","3rd Sem"};


int iLinePerPg = 30;
int iCurLine   = 0;

int i = 0;
boolean bolIsPrinted = false;//do not print the lebel - like -> Course Reference... etc.. 
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="<%if(strErrMsg == null) {%>window.print();<%}%>">
<%
if(strErrMsg != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;
	  <font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
<%dbOP.cleanUP();
return;}%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="100%" height="25"><div align="center">
	  <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=vFacultyInfo.elementAt(2)%><br>
          <br>
          <font size="4"><strong>SYLLABUS</strong></font></div>
		  <div align="right"><font size="1">Date and time Printed : <%=WI.getTodaysDateTime()%></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborder">
    <tr> 
      <td height="25" colspan="2" class="thinborder"><strong><font color="#000000">:: GENERAL COURSE 
        INFORMATION ::</font></strong></td>
    </tr>
    <tr> 
      <td width="21%" height="25" class="thinborder">Course Number :</td>
      <td width="79%" class="thinborder"><span class="thinborderNONE"><%=vSubInfo.remove(0)%></span></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder">Course Title :</td>
      <td class="thinborder"><span class="thinborderNONE"><%=vSubInfo.remove(0)%></span></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder">No. of Teaching Hours : </td>
      <td class="thinborder"><span class="thinborderNONE">
<%
strTemp = (String)vSubInfo.remove(1);
%>	  <%=strTemp%> hours a week</span></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder">Unit Credit : </td>
      <td class="thinborder"><span class="thinborderNONE"><%=vSubInfo.remove(0)%> units </span></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder">Total Hours :</td>
      <td class="thinborder"><span class="thinborderNONE"><%=Integer.parseInt(strTemp) * 18%></span></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder">Schoo Year :</td>
      <td class="thinborder">
	  <%=WI.fillTextValue("sy_from") + " - "+WI.fillTextValue("sy_to")+", "+astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>	  </td>
    </tr>
    <tr> 
      <td height="25" class="thinborder">Time Allotment :</td>
      <td class="thinborder"><%=WI.getStrValue(vGeneralInfo.elementAt(2),"&nbsp;")%></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder">Prerequisites :</td>
      <td class="thinborder">
        <%strTemp = "";
	  for(i =0; i < vSubInfo.size(); i += 2) {
	  	if(strTemp.length() == 0)
			strTemp = WI.getStrValue(vSubInfo.elementAt(i))+" "+WI.getStrValue(vSubInfo.elementAt(i + 1));
		else
			strTemp = strTemp +", "+ WI.getStrValue(vSubInfo.elementAt(i))+" "+WI.getStrValue(vSubInfo.elementAt(i + 1));
	  }%>
        <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    </tr>
    <tr>
      <td height="25" class="thinborder">Course Description </td>
      <td class="thinborder"><%=(String)vGeneralInfo.elementAt(0)%></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT">Course Objectives</td>
      <td class="thinborderLEFT"><%=(String)vGeneralInfo.elementAt(1)%></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborder">
    <tr> 
      <td height="25" colspan="2" class="thinborder"><strong><font color="#000000">:: INSTRUCTOR 
        DETAILS ::</font></strong></td>
    </tr>
    <tr> 
      <td width="21%" height="25" class="thinborder">Name :</td>
      <td width="79%" class="thinborder"><%=vFacultyInfo.remove(0)%> ::: <%=vFacultyInfo.remove(0)%></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder">Position / College:</td>
      <td class="thinborder">
<%
strTemp = (String)vFacultyInfo.remove(0);
if(strTemp == null)
	strTemp = (String)vFacultyInfo.remove(0);
else	
	vFacultyInfo.removeElementAt(0);
strTemp = (String)vFacultyInfo.remove(0)+" / "+strTemp;
%>
	  <%=strTemp%></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder">Email Address : </td>
      <td class="thinborder"><%=WI.getStrValue((String)vFacultyInfo.remove(3),"&nbsp;")%></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder">Office Phone No. :</td>
      <td class="thinborder"><%=WI.getStrValue((String)vFacultyInfo.remove(0),"&nbsp;")%></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder">Office Room Nos. :</td>
      <td class="thinborder"><%=WI.getStrValue((String)vFacultyInfo.remove(0),"&nbsp;")%></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderBOTTOMLEFT">Counseling Hours :</td>
      <td class="thinborderBOTTOMLEFT"><%=WI.getStrValue((String)vFacultyInfo.remove(0),"&nbsp;")%></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
<%
bolIsPrinted = false;
iCurLine = 23;
vTempInfo = cmsNew.operateOnCourseCalendar(dbOP, request, 4);
if(vTempInfo != null){
i = 0;
while(i < vTempInfo.size()){
	iCurLine   += 2;
if(iCurLine >= iLinePerPg) {iCurLine = 2;%>
	<DIV style="page-break-after:always">&nbsp;</DIV>
<%}%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborder">
<%if(!bolIsPrinted){bolIsPrinted = true;%>
    <tr> 
      <td height="25" colspan="5" class="thinborder"><strong>:: COURSE CALENDAR :: </strong></td>
    </tr>
<%}else{--iCurLine;}%>
    <tr> 
      <td width="5%" height="25" class="thinborder"><div align="center"><strong><font size="1">WEEK</font></strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">DATE</font></strong></div></td>
      <td width="31%" class="thinborder"><div align="center"><strong><font size="1">TOPIC</font></strong></div></td>
      <td width="30%" class="thinborder"><div align="center"><strong><font size="1">READING DUE</font></strong></div></td>
      <td width="26%" class="thinborder"><div align="center"><strong><font size="1">ADDITIONAL INFO</font></strong></div></td>
    </tr>
<%
for(; i < vTempInfo.size(); i += 6){
	++iCurLine; 
	if(iCurLine >= iLinePerPg) {iCurLine=0;break;}%>
    <tr> 
      <td height="25" class="thinborder"><span style="font-size:9px"><%=vTempInfo.elementAt(i + 1)%></span></td>
      <td class="thinborder"><span style="font-size:9px"><%=WI.getStrValue(vTempInfo.elementAt(i + 2))%></span></td>
      <td class="thinborder"><span style="font-size:9px"><%=WI.getStrValue(vTempInfo.elementAt(i + 3))%></span></td>
      <td class="thinborder"><span style="font-size:9px"><%=WI.getStrValue(vTempInfo.elementAt(i + 4))%></span></td>
      <td class="thinborder"><span style="font-size:9px"><%=WI.getStrValue(vTempInfo.elementAt(i + 5))%></span></td>
    </tr>
<%}//for loop.
%>
  </table>
<%}//while loop to take care of page break.
}//if vCourseCalendar not null. %>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
<%
bolIsPrinted = false;
++iCurLine;
vTempInfo = cmsNew.operateOnCourseRequirement(dbOP, request, 4);
if(vTempInfo != null){
i = 0;
while(i < vTempInfo.size()){
	iCurLine   += 2;
if(iCurLine >= iLinePerPg) {iCurLine = 2;%>
	<DIV style="page-break-after:always">&nbsp;</DIV>
<%}%>  
<table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborder">
<%if(!bolIsPrinted){bolIsPrinted = true;%>
    <tr> 
      <td height="25" colspan="2" class="thinborder"><strong>:: COURSE REQUIREMENTS :: </strong></td>
    </tr>
<%}else{--iCurLine;}%>
    <tr> 
      <td width="49%" height="25" class="thinborder"><strong><font size="1">REQUIREMENTS/EVALUATION 
          </font></strong></td>
      <td width="51%" class="thinborder"><strong><font size="1">PERCENTAGE</font></strong></td>
    </tr>
<%for(; i < vTempInfo.size(); i += 3){
++iCurLine; 
	if(iCurLine > iLinePerPg) {break;}%>
    <tr> 
      <td height="25" class="thinborder"><span style="font-size:9px"><%=WI.getStrValue(vTempInfo.elementAt(i + 1))%></span></td>
      <td class="thinborder"><span style="font-size:9px"><%=WI.getStrValue(vTempInfo.elementAt(i + 2))%>&nbsp;</span></td>
    </tr>
<%}//end of for loop%>
</table>
<%}//while loop to take care of page break.
}//end of course requirement. %>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
<%
bolIsPrinted = false;
++iCurLine;
vTempInfo = cmsNew.operateOnGradingSystem(dbOP, request, 4);
if(vTempInfo != null){
i = 0;
while(i < vTempInfo.size()){
	iCurLine   += 1;
if(iCurLine >= iLinePerPg) {iCurLine = 1;%>
	<DIV style="page-break-after:always">&nbsp;</DIV>
<%}%>  
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborder">
<%if(!bolIsPrinted){bolIsPrinted = true;%>
    <tr> 
      <td height="26" colspan="3" class="thinborder"><strong>:: GRADING SYSTEM :: </strong></td>
    </tr>
<%}else{--iCurLine;}%>
    <tr> 
      <td width="13%" class="thinborder"><strong><font size="1">LETTER GRADE</font></strong></td>
      <td width="21%" height="25" class="thinborder"><strong><font size="1">NUMERICAL 
          EQUIVALENT </font></strong></td>
      <td width="66%" class="thinborder"><strong><font size="1">PERCENTAGES EQUIVALENT</font></strong></td>
    </tr>
<%for(; i < vTempInfo.size(); i += 4){
++iCurLine; 
	if(iCurLine > iLinePerPg) {break;}%>
    <tr> 
      <td class="thinborder"><%=vTempInfo.elementAt(i + 1)%></td>
      <td height="25" class="thinborder"><%=vTempInfo.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vTempInfo.elementAt(i + 3)%></td>
    </tr>
<%}//end of for loop%>
  </table>
<%}//while loop to take care of page break.
}//end of Grading system. %>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
<%
bolIsPrinted = false;
++iCurLine;
vTempInfo = cmsNew.operateOnMethods(dbOP, request, 4);
if(vTempInfo != null){
i = 0;
while(i < vTempInfo.size()){
	iCurLine   += 1;
if(iCurLine >= iLinePerPg) {iCurLine = 1;%>
	<DIV style="page-break-after:always">&nbsp;</DIV>
<%}%>  
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborder">
<%if(!bolIsPrinted){bolIsPrinted = true;%>
    <tr> 
      <td height="25" colspan="2" class="thinborder"><strong>:: METHODS AND STRATEGIES ::</strong></td>
    </tr>
<%}else{--iCurLine;}%>
    <tr> 
      <td width="48%" class="thinborder"><strong><font size="1">METHODS</font></strong></td>
      <td width="52%" height="25" class="thinborder"><font size="1"><strong>STRATEGIES</strong></font></td>
    </tr>
<%for(; i < vTempInfo.size(); i += 3){
++iCurLine; 
	if(iCurLine > iLinePerPg) {break;}%>
    <tr> 
      <td class="thinborder"><%=WI.getStrValue(vTempInfo.elementAt(i + 1))%></td>
      <td height="25" class="thinborder"><%=WI.getStrValue(vTempInfo.elementAt(i + 2))%></td>
    </tr>
<%}//end of for loop%>
  </table>
<%}//while loop to take care of page break.
}//end of Grading system. %>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
<%
bolIsPrinted = false;
++iCurLine;
vTempInfo = cmsNew.operateOnMaterial(dbOP, request, 4);
if(vTempInfo != null){
i = 0;
while(i < vTempInfo.size()){
	iCurLine   += 1;
if(iCurLine >= iLinePerPg) {iCurLine = 1;%>
	<DIV style="page-break-after:always">&nbsp;</DIV>
<%}%>  
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborder">
<%if(!bolIsPrinted){bolIsPrinted = true;%>
    <tr> 
      <td height="25" colspan="2" class="thinborder"><strong>:: MATERIALS NEEDED :: </strong></td>
    </tr>
<%}else{--iCurLine;}%>
    <tr> 
      <td width="18%" class="thinborder"><strong><font size="1">MATERIALS</font></strong></td>
      <td width="22%" height="25" class="thinborder"><strong><font size="1">REMARKS</font></strong></td>
    </tr>
<%for(; i < vTempInfo.size(); i += 3){
++iCurLine; 
	if(iCurLine > iLinePerPg) {break;}%>
    <tr> 
      <td class="thinborder"><%=WI.getStrValue(vTempInfo.elementAt(i + 1))%></td>
      <td height="25" class="thinborder"><%=WI.getStrValue(vTempInfo.elementAt(i + 2))%></td>
    </tr>
<%}//end of for loop%>
  </table>
<%}//while loop to take care of page break.
}//end of Grading system. %>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborder">
    <tr> 
      <td height="25" colspan="4" class="thinborder"><strong>::TEXTBOOK AND REFERENCES ::</strong></td>
    </tr>
<%
vTempInfo = cmsNew.operateOnTextBook(dbOP, request, 4);
if(vTempInfo != null){%>
    <tr> 
      <td height="25" colspan="4" class="thinborder"><font size="1"><strong>TEXTBOOK 
          :</strong>
		  <%
strTemp = "";
for(i = 0; i < vTempInfo.size() ; i += 5) {
	if(vTempInfo.elementAt(i + 4).equals("0"))
		continue;
	if(strTemp.length() > 0) 
		strTemp = strTemp + ",";
	strTemp = strTemp + vTempInfo.elementAt(i + 1);

vTempInfo.removeElementAt(i);vTempInfo.removeElementAt(i);vTempInfo.removeElementAt(i);
vTempInfo.removeElementAt(i);vTempInfo.removeElementAt(i);
i -= 5;
}
if(strTemp.length() == 0) 
	strTemp = "Not set.";%>
        <%=strTemp%> 
		  
		  
		  </font></td>
    </tr>
  </table>
<%
bolIsPrinted = false;
iCurLine += 2;//text book and detail.
i = 0;
while(i < vTempInfo.size()){
	iCurLine   += 1;
if(iCurLine >= iLinePerPg) {iCurLine = 1;%>
	<DIV style="page-break-after:always">&nbsp;</DIV>
<%}%>  
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborder">
    <tr> 
      <td height="25" colspan="4" class="thinborder"><font size="1"><strong>REFERENCES</strong></font>        </td>
    </tr>
<%for(; i < vTempInfo.size(); i += 5) {
++iCurLine; 
	if(iCurLine > iLinePerPg) {break;}%>
    <tr> 
      <td width="5%" class="thinborder"><%=i/5 + 1%>.</td>
      <td width="45%" height="25" class="thinborder"><%=vTempInfo.elementAt(i + 1)%></td>
      <td width="25%" class="thinborder"><%=vTempInfo.elementAt(i + 2)%></td>
      <td width="25%" height="25" class="thinborder"><%=vTempInfo.elementAt(i + 3)%></td>
    </tr>
<%}//end of for loop%>
  </table>
<%}//while loop to take care of page break.
}//end of References. %>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
<%
boolean bolShow = true;
bolIsPrinted = false;

vTempInfo = cmsNew.operateOnIndividualLesson(dbOP, request, 4);
if(vTempInfo != null){
iCurLine += 2;//text book and detail.
i = 0;
while(i < vTempInfo.size()){
if(iCurLine >= iLinePerPg) {iCurLine = 0;%>
	<DIV style="page-break-after:always">&nbsp;</DIV>
<%}%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborder">
<%if(!bolIsPrinted){bolIsPrinted = true;%>
    <tr> 
      <td height="25" colspan="6" class="thinborder"><strong>:: INDIVIDUAL LESSON ::</strong></td>
    </tr>
<%}else{--iCurLine;}%>
    <tr> 
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>LEARNING OBJECTIVE</strong></font></div></td>
      <td width="30%" height="25" class="thinborder"><div align="center"><font size="1"><strong>CONTENT/TOPIC</strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>TEACHING STRATEGY</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>EVALUATION</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>TIMEFRAME <br>(Hours) </strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>REFERENCES</strong></font></div></td>
    </tr>
<%
for(; i < vTempInfo.size(); i += 11){
///for per page display.. 
++iCurLine; 
	if(iCurLine > iLinePerPg) {break;}
	
if(i > 0 && vTempInfo.elementAt(i + 1).equals(strTemp))
	bolShow = false;
else {	
	bolShow = true;
	strTemp = (String)vTempInfo.elementAt(i + 1);
}
if(bolShow){++iCurLine;%>
    <tr> 
      <td height="25" colspan="6" class="thinborder" style="font-size:11px; font-weight:bold; color:#0066FF">&nbsp;
	  		<%=vTempInfo.elementAt(i + 1)%>. <%=vTempInfo.elementAt(i + 2)%></td>
    </tr>
<%}
if(WI.getStrValue((String)vTempInfo.elementAt(i + 3)).length() > 0){++iCurLine;%>
    <tr> 
      <td height="25" colspan="6" class="thinborder" style="font-size:11px; font-weight:bold">
	  &nbsp;&nbsp;&nbsp;
	  <%=vTempInfo.elementAt(i + 3)%>. <%=vTempInfo.elementAt(i + 4)%>	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25" class="thinborder" style="font-size:9px;" valign="top"><%=ConversionTable.replaceString(WI.getStrValue(vTempInfo.elementAt(i + 5),"&nbsp;"),"\r\n","<br>")%></td>
      <td style="font-size:9px;" class="thinborder" valign="top"><%=WI.getStrValue(vTempInfo.elementAt(i + 6),"&nbsp;")%></td>
      <td style="font-size:9px;" class="thinborder" valign="top"><%=WI.getStrValue(vTempInfo.elementAt(i + 7),"&nbsp;")%></td>
      <td style="font-size:9px;" class="thinborder" valign="top"><%=WI.getStrValue(vTempInfo.elementAt(i + 8),"&nbsp;")%></td>
      <td style="font-size:9px;" class="thinborder" valign="top"><%=WI.getStrValue(vTempInfo.elementAt(i + 9),"&nbsp;")%></td>
      <td style="font-size:9px;" class="thinborder" valign="top"><%=WI.getStrValue(vTempInfo.elementAt(i + 10),"&nbsp;")%></td>
    </tr>
<%}//end of for loop..
%>
  </table>	
<%
	}//while loop.. for page break
}  
%>
	<DIV style="page-break-after:always">&nbsp;</DIV>
<%
bolIsPrinted = false;
vTempInfo = cmsNew.operateOnIndividualLesson(dbOP, request, 5);
if(vTempInfo != null && vTempInfo.size() > 0) {
String strTotalHr = (String)vTempInfo.remove(0);

iCurLine = 2;//text book and detail.
i = 0;
while(i < vTempInfo.size()){
	iCurLine   += 1;
if(iCurLine >= iLinePerPg) {iCurLine = 1;%>
	<DIV style="page-break-after:always">&nbsp;</DIV>
<%}%>  
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborder">
<%if(!bolIsPrinted){bolIsPrinted = true;%>
    <tr> 
      <td height="25" colspan="3" class="thinborder"><strong>:: SUMMARY OF LESSON ::</strong></td>
    </tr>
<%}else{--iCurLine;}%>
    <tr> 
      <td width="11%" height="25" class="thinborder"><div align="center"><font size="1"><strong>
	  PART NO. / LESSON NAME </strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">
	  UNIT NO./UNIT NAME</font></strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>
	  TIMEFRAME <br> (Hours) </strong></font></div></td>
    </tr>
<%
for(; i < vTempInfo.size(); i += 5){
++iCurLine; 
	if(iCurLine > iLinePerPg) {break;}
if(i > 0 && vTempInfo.elementAt(i).equals(strTemp))
	bolShow = false;
else {	
	bolShow = true;
	strTemp = (String)vTempInfo.elementAt(i);
}%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<font size="1">
        <%if(bolShow){%>
        <%=vTempInfo.elementAt(i)%>.<%=vTempInfo.elementAt(i + 1)%>
        <%}%>
      </font></td>
      <td class="thinborder"><font size="1">&nbsp;</font>&nbsp;<font size="1"><%=WI.getStrValue((String)vTempInfo.elementAt(i + 2),"",". ","")%><%=WI.getStrValue(vTempInfo.elementAt(i + 3))%></font></td>
      <td class="thinborder"><div align="center"><font size="1"><%=vTempInfo.elementAt(i + 4)%></font></div></td>
    </tr>
<%}//end of for loop.
if(i > vTempInfo.size()){%>
    <tr> 
      <td height="26" colspan="2" class="thinborder"> <div align="center"><font size="1">&nbsp;</font><font size="1">&nbsp;TOTAL 
          HOURS </font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><u>&nbsp;<%=strTotalHr%>&nbsp;</u> </font></div></td>
    </tr>
<%}%>
  </table>
<%
	}//while loop.. for page break
}  
%>
</body>
</html>
<%
dbOP.cleanUP();
%>