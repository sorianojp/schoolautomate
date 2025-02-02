<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
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

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
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
        <p><font size="1"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <br>
          <font size="2">CLASS PROGRAM</font><br>
          <strong><%=strConvertSem[Integer.parseInt(request.getParameter("offering_sem"))]%></strong>
          , &nbsp;<strong><%=request.getParameter("school_year_fr")%> - <%=request.getParameter("school_year_to")%>
          </strong><br>
          </font></p>

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
    <td colspan="2">Course :<strong>
	<%=WI.getStrValue(dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX", request.getParameter("course_index"),"COURSE_NAME", null),"For all course")%></strong></td>
  </tr>
  <%
strTemp = request.getParameter("major_index");
if(strTemp == null || strTemp.trim().length() == 0) strTemp = null;
else strTemp = dbOP.mapOneToOther("MAJOR","MAJOR_INDEX", request.getParameter("major_index"),"MAJOR_NAME",null);
if(strTemp != null && strTemp.trim().length() > 0){
%>
  <tr>
    <td width="1%" height="25">&nbsp;</td>
    <td colspan="2"> Major : <strong><%=strTemp%></strong></td>
  </tr>
  <%}%>
  <tr>
    <td height="25">&nbsp;</td>
    <td width="48%">
      <%
	  if(WI.fillTextValue("year").length() > 0){%>
      Year :<strong> <%=strConvertYear[Integer.parseInt(request.getParameter("year")) - 1]%></strong>
      <%}%>
    </td>
    <td width="51%">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="23%" height="25" align="center" class="thinborder"><font size="1"><strong>SUBJECT CODE </strong></font></td>
      <td width="22%" align="center" class="thinborder"><font size="1"><strong>SECTION</strong></font></td>
      <td width="18%" align="center" class="thinborder"><font size="1"><strong>ROOM #</strong></font></td>
      <td width="37%" align="center" class="thinborder"><font size="1"><strong>SCHEDULE(Days/Time)</strong></font></td>
<%if(bolIsHTC) {%>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>TERM TYPE</strong></font></td>
<%}%>
    </tr>
<%
boolean bolErrorInProcess = false;
strSection 				= null;
String strSubCode 		= null;
String strSubCodeToDisp = null;//use this to display.
String strLecLabStat    = null;

for(int i = 0; i< vSubSectionDetail.size(); ++i)
{
	strSection = (String)vSubSectionDetail.elementAt(i+2);
	if(strSubCode != null && strSubCode.compareTo((String)vSubSectionDetail.elementAt(i+1)) ==0 &&
		strLecLabStat.compareTo((String)vSubSectionDetail.elementAt(i+4)) ==0)
	{
		strSubCodeToDisp = "&nbsp;";
	}
	else
	{
		strSubCode = (String)vSubSectionDetail.elementAt(i+1);
		strSubCodeToDisp = strSubCode;
		if( ((String)vSubSectionDetail.elementAt(i+4)).compareTo("1") ==0)
		{
			strSubCodeToDisp = strSubCode+" (Lab Sched)";
			strLecLabStat = (String)vSubSectionDetail.elementAt(i+4);
		}
		else
			strLecLabStat = "0";

	}
	vRoomDetail = SS.getRoomScheduleDetailInMWF(dbOP,(String)vSubSectionDetail.elementAt(i),true);
	if(vRoomDetail == null)
	{
		bolErrorInProcess = true;
		break; //break the loop
	}
%>
	<tr>
      <td height="25" class="thinborder"><%=strSubCodeToDisp%></td>
      <td class="thinborder"><%=strSection%></td>
      <td class="thinborder"><%=WI.getStrValue(vRoomDetail.elementAt(1),"Not Assigned")%></td>
      <td class="thinborder"><%=WI.getStrValue(vSubSectionDetail.elementAt(i+3),"")%> <!--Offering duration -->
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
	</tr>
<%
for(int j=3;j<vRoomDetail.size()-2;){%>
		<tr>
		  <td height="25" class="thinborder">&nbsp;</td>
		  <td class="thinborder">&nbsp;</td>
		  <td class="thinborder"><%=WI.getStrValue(vRoomDetail.elementAt(j+1),"Not Assigned")%></td>
		  <td class="thinborder"><%=(String)vRoomDetail.elementAt(j+2)%></td>
<%if(bolIsHTC) {%>
		  <td class="thinborder">&nbsp;</td>
<%}%>
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

    <td colspan="<%if(bolIsHTC) {%>7<%}else{%>6<%}%>" class="thinborder"><strong>Error in getting Room information for section : <%=strSection%></strong></td>
    </tr>
    <%
return;	}%>
  </table>

  <script language="JavaScript">
	window.print();
window.setInterval("javascript:window.close();",0);
</script>

</body>
</html>


