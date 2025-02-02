<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
    }

-->
</style>
</head>
<body>
<%@ page language="java" import="utility.*,enrollment.SubjectSection,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	Vector vTemp = null;

	String strSubjectCode = null; //used to display.
	String strSection = null;
	String strSubjectType = null;
	String strWeek = ""; // this is in MWF format.
	String strTime = null;
	//String strTempTime = null;

	//to remove the repeating information.
	String strSubjectCodePrev 	= "";
	String strSubjectTypePrev 	= "";
	String strSectionPrev 		= "";

	String[] strConvertYear = {"1st year","2nd year","3rd year","4th year","5th year","6th year","7th year","8th year","9th"};
	String[] strConvertWeek = {"Sun ","M","T","W","TH","F","Sat"};
	String[] strConvertAMPM = {"AM","PM"};
	String[] strConvertSem  = {"Summer","1st Term", "2nd Term", "3rd Term", "4th Term", "5th Term"};

	String[] astrPrepProp   = {""," (Preparatory)"," (Proper)"};
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-subject sectioning MWF Format","subj_sectioning_print_MWF_format.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

strErrMsg = null; //if there is any message set -- show at the bottom of the page.
SubjectSection SS = new SubjectSection();

Vector vSubSectionDetail = new Vector();
Vector vRoomDetail = new Vector();

vSubSectionDetail = SS.getSectionScheduleDetail(dbOP,request);

//for displaying.. 
String strSubCode 		= null;
String strSubCodeToDisp = null;//use this to display.
boolean bolErrorInProcess = false;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsPhilCST = strSchCode.startsWith("PHILCST");
String strSYFrom = (String)request.getParameter("school_year_fr"); 
String strSem    = (String)request.getParameter("offering_sem");

boolean bolIsHTC = strSchCode.startsWith("HTC");
Vector vHTCTermType = new Vector();
int iIndexOf = 0;
if(bolIsHTC && WI.fillTextValue("school_year_fr").length() > 0) {
	String strSQLQuery = "select sub_sec_index, term_ess from e_sub_section where term_ess > 0 and is_valid = 1 and offering_sy_from = "+
						WI.fillTextValue("school_year_fr")+" and offering_sem = "+WI.fillTextValue("offering_sem");
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vHTCTermType.addElement(rs.getString(1));//[0] sub_sec_index
		vHTCTermType.addElement(rs.getString(2));//[1] term type.
	}
	rs.close();
}


%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td><div align="center">
        <p><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <br>
          CLASS PROGRAM<br>
          <strong><%=strConvertSem[Integer.parseInt(strSem)]%></strong>
          , &nbsp;<strong><%=strSYFrom%> - <%=request.getParameter("school_year_to")%>
          </strong><br>
        </p>

        </div></td>
    </tr>
  </table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <%
if(vSubSectionDetail == null || vSubSectionDetail.size() == 0)
{
strTemp = SS.getErrMsg();
if(strTemp == null || strTemp.trim().length() ==0) strTemp = "No Information found.";

dbOP.cleanUP();
return;
}  %>
  <tr>
    <td width="1%" height="25">&nbsp;</td>
    <td colspan="2">Course : <strong><%=
	  WI.getStrValue(dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX", request.getParameter("course_index"),"COURSE_NAME", null),"For all course")%></strong></td>
  </tr>
  <%
strTemp = request.getParameter("major_index");
if(strTemp == null || strTemp.trim().length() == 0) strTemp = null;
else strTemp = dbOP.mapOneToOther("MAJOR","MAJOR_INDEX", request.getParameter("major_index"),"MAJOR_NAME",null);
if(strTemp != null && strTemp.trim().length() > 0){
%>
  <tr>
    <td width="1%" height="25">&nbsp;</td>
    <td width="44%"> Major : <strong><%=strTemp%></strong></td>
    <td width="55%">&nbsp;</td>
  </tr>
  <%}%>
  <tr>
    <td height="25">&nbsp;</td>
    <td>
      <%
	  if(WI.fillTextValue("year").length() > 0){%>
      Year - Section :<strong> <%=strConvertYear[Integer.parseInt(request.getParameter("year")) - 1]%></strong>
      <%}%>
     <strong> - <%=request.getParameter("print_section")%></strong></td>
    <td>&nbsp;</td>
  </tr>
</table>
<%
if(WI.fillTextValue("sched_per_section").length() == 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC" class="thinborder">
  <tr style="font-weight:bold" align="center">
<%if(bolIsPhilCST){%>
    <td width="10%" class="thinborder" style="font-size:9px;">SCHEDULE CODE </td>
<%}%>
    <td width="40%" height="25" class="thinborder" style="font-size:9px;">SUBJECT CODE</td>
    <td width="7%" class="thinborder" style="font-size:9px;">ROOM #</td>
    <td width="33%" class="thinborder" style="font-size:9px;">SCHEDULE(Days/Time)</td>
    <td width="15%" class="thinborder" style="font-size:9px;">SECTION (if different from section above) </td>
<%if(bolIsHTC) {%>
    <td width="5%" class="thinborder" style="font-size:9px;">TERM TYPE </td>
<%}%>
  </tr>
  <%
strSection = request.getParameter("print_section"); 
for(int i = 0; i< vSubSectionDetail.size(); ++i)
{
	//strSection = (String)vSubSectionDetail.elementAt(i+2);
	if(strSubCode != null && strSubCode.compareTo((String)vSubSectionDetail.elementAt(i+1)) ==0)
	{
		strSubCodeToDisp = "&nbsp;";
	}
	else
	{
		strSubCode = (String)vSubSectionDetail.elementAt(i+1);
		strSubCodeToDisp = strSubCode;
		if( ((String)vSubSectionDetail.elementAt(i+4)).compareTo("1") ==0)
					strSubCodeToDisp = strSubCode+" (Lab Sched)";
	}
	vRoomDetail = SS.getRoomScheduleDetailInMWF(dbOP,(String)vSubSectionDetail.elementAt(i));
	if(vRoomDetail == null)
	{
		bolErrorInProcess = true;
		break; //break the loop
	}
%>
  <tr>
<%if(bolIsPhilCST && !strSubCodeToDisp.equals("&nbsp;")){%>
    <td class="thinborder">&nbsp;<%=WI.getStrValue(SS.convertSubSecIndexToOfferingCount(dbOP, request, (String)vSubSectionDetail.elementAt(i), strSYFrom, strSem, strSchCode))%></td>
<%}%>
    <td height="25" class="thinborder"><%=strSubCodeToDisp%></td>
    <td class="thinborder"><%=WI.getStrValue(vRoomDetail.elementAt(1),"Not Assigned")%></td>
    <td class="thinborder"><%=WI.getStrValue(vSubSectionDetail.elementAt(i+3),"")%> <!--Offering duration -->
	<%=(String)vRoomDetail.elementAt(2)%></td>
    <td class="thinborder"><%if(strSection.equals(vSubSectionDetail.elementAt(i+2))){%>&nbsp;<%}else{%><%=vSubSectionDetail.elementAt(i+2)%><%}%></td>
<%if(bolIsHTC) {
iIndexOf = vHTCTermType.indexOf(vSubSectionDetail.elementAt(i));
if(iIndexOf == -1)
	strTemp = "ALL";
else {
	strTemp = (String)vHTCTermType.elementAt(iIndexOf + 1);
	
	//vHTCTermType.remove(iIndexOf);vHTCTermType.remove(iIndexOf);
}%>
      <td class="thinborder"><%=strTemp%></td>
<%}%>
  </tr>
  <%
for(int j=3;j<vRoomDetail.size()-2;){%>
  <tr>
<%if(bolIsPhilCST){%>
    <td class="thinborder">&nbsp;</td>
<%}%>
    <td height="25" class="thinborder">&nbsp;</td>
    <td class="thinborder"><%=WI.getStrValue(vRoomDetail.elementAt(j+1),"Not Assigned")%></td>
    <td class="thinborder"><%=(String)vRoomDetail.elementAt(j+2)%></td>
    <td class="thinborder">&nbsp;</td>
<%if(bolIsHTC) {%>
    <td class="thinborder">&nbsp;</td>
<%}%>
  </tr>
  <%
	j = j+3;
	}
i = i+6;
}
if(bolErrorInProcess)
{%>
  <tr>
    <td colspan="<%if(bolIsHTC) {%>8<%}else{%>7<%}%>"><strong>Error in getting Room information for section : <%=strSection%></strong></td>
  </tr>
  <%
return;	}%>
</table>
<%}else{//called from faculty report.%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC" class="thinborder">
  <tr style="font-weight:bold" align="center">
<%if(bolIsPhilCST){%>
    <td width="9%" align="center" class="thinborder" style="font-size:9px;">SCHEDULE CODE</td> 
<%}%>
    <td width="23%" height="25" class="thinborder" style="font-size:9px;">SUBJECT CODE</td>
    <td width="8%" class="thinborder" style="font-size:9px;">ROOM #</td>
    <td width="25%" class="thinborder" style="font-size:9px;">SCHEDULE(Days/Time)</td>
<%if(bolIsHTC) {%>
    <td width="5%" class="thinborder" style="font-size:9px;">TERM TYPE </td>
<%}%>
    <td width="25%" class="thinborder" style="font-size:9px;">FACULTY</td>
    <td width="10%" class="thinborder" style="font-size:9px;">NO OF STUDENT</td>
  </tr>
  <%
strSection  = null;
Vector vFacultyAndStudInfo = null;
for(int i = 0; i< vSubSectionDetail.size(); ++i)
{
	strSection = (String)vSubSectionDetail.elementAt(i+2);
	if(strSubCode != null && strSubCode.compareTo((String)vSubSectionDetail.elementAt(i+1)) ==0)
	{
		strSubCodeToDisp = "&nbsp;";
	}
	else
	{
		strSubCode = (String)vSubSectionDetail.elementAt(i+1);
		strSubCodeToDisp = strSubCode;
		if( ((String)vSubSectionDetail.elementAt(i+4)).compareTo("1") ==0)
					strSubCodeToDisp = strSubCode+" (Lab Sched)";
	}
	vRoomDetail = SS.getRoomScheduleDetailInMWF(dbOP,(String)vSubSectionDetail.elementAt(i));
	vFacultyAndStudInfo = SS.getFacNameAndNoOfStudInASec(dbOP, 
								(String)vSubSectionDetail.elementAt(i));
	if(vRoomDetail == null)
	{
		bolErrorInProcess = true;
		break; //break the loop
	}
%>
  <tr>
<%if(bolIsPhilCST && !strSubCodeToDisp.equals("&nbsp;")){%>
    <td class="thinborder">&nbsp;<%=WI.getStrValue(SS.convertSubSecIndexToOfferingCount(dbOP, request, (String)vSubSectionDetail.elementAt(i), strSYFrom, strSem, strSchCode))%></td>
<%}%>
    <td height="25" class="thinborder"><%=strSubCodeToDisp%></td>
    <td class="thinborder"><%=WI.getStrValue(vRoomDetail.elementAt(1),"Not Assigned")%></td>
    <td class="thinborder"><%=WI.getStrValue(vSubSectionDetail.elementAt(i+3),"")%> 
      <!--Offering duration -->
      <%=(String)vRoomDetail.elementAt(2)%></td>
<%if(bolIsHTC) {
iIndexOf = vHTCTermType.indexOf(vSubSectionDetail.elementAt(i));
if(iIndexOf == -1)
	strTemp = "ALL";
else {
	strTemp = (String)vHTCTermType.elementAt(iIndexOf + 1);
	
	//vHTCTermType.remove(iIndexOf);vHTCTermType.remove(iIndexOf);
}%>
      <td class="thinborder"><%=strTemp%></td>
<%}%>
    <td class="thinborder">
	<%if(vFacultyAndStudInfo != null && vFacultyAndStudInfo.size() > 0) {%>
		<%=WI.getStrValue(vFacultyAndStudInfo.elementAt(0), "Not Assigned")%>
	<%}%>	</td>
    <td class="thinborder">
	<%if(vFacultyAndStudInfo != null && vFacultyAndStudInfo.size() > 0) {%>
		<%=WI.getStrValue(vFacultyAndStudInfo.elementAt(2), "Not Assigned")%>
	<%}%></td>
  </tr>
  <%
for(int j=3;j<vRoomDetail.size()-2;){%>
  <tr>
<%if(bolIsPhilCST){%>
    <td class="thinborder">&nbsp;</td> 
<%}%>
    <td height="25" class="thinborder">&nbsp;</td>
    <td class="thinborder"><%=WI.getStrValue(vRoomDetail.elementAt(j+1),"Not Assigned")%></td>
    <td class="thinborder"><%=(String)vRoomDetail.elementAt(j+2)%></td>
<%if(bolIsHTC) {%>
    <td class="thinborder">&nbsp;</td>
<%}%>
    <td class="thinborder">
	<%if(vFacultyAndStudInfo != null && vFacultyAndStudInfo.size() > 0) {%>
		<%=WI.getStrValue(vFacultyAndStudInfo.elementAt(0), "Not Assigned")%>
	<%}%>	</td>
    <td class="thinborder">&nbsp;</td>
  </tr>
  <%
	j = j+3;
	}
i = i+6;
}

dbOP.cleanUP();
if(bolErrorInProcess)
{%>
  <tr> 
    <td colspan="<%if(bolIsHTC) {%>9<%}else{%>8<%}%>"><strong>Error in getting Room information for section : <%=strSection%></strong></td>
  </tr>
  <%
return;	}%>
</table>
<%}//end of else to show if sched_per_section is set.
if(WI.fillTextValue("print_stat").compareTo("0") != 0){%>
  <script language="JavaScript">
	window.print();
</script>
<%}%>

</body>
</html>

<%
dbOP.cleanUP();
%>
