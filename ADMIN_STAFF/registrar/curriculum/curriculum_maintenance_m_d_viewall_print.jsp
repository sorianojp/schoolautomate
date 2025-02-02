<%@ page language="java" import="utility.*,enrollment.CurriculumMaintenance,java.util.Vector, java.util.Date" %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
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
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderBOTTOM {
		border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 9px;
    }
-->
</style>

</head>
<body onLoad="window.print();">
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	String strCourseIndex 	= request.getParameter("ci");
	String strCourseName 	= request.getParameter("cname");
	String strMajorIndex 	= request.getParameter("mi");
	String strMajorName 	= request.getParameter("mname");
	if(strMajorName == null || strMajorName.trim().length() ==0) strMajorName = "None";
	String strCYFrom 		= request.getParameter("syf");
	String strCYTo 			= request.getParameter("syt");
	String strCollegeName   = null;

	float fTotalUnit = 0;

	if(strCourseIndex == null || strCYFrom == null || strCYTo == null)
	{
		strErrMsg = "Can't process curriculum detail. couse, Curriculum Year from and to information missing.";
		dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=strErrMsg%></font></p>
		<%
		return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Courses curriculum - masteral print","curriculum_maintenance_m_d_viewall_print.jsp");
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


//end of security code.
strErrMsg = null; //if there is any message set -- show at the bottom of the page.
CurriculumMaintenance CM = new CurriculumMaintenance();
Vector[] vCurDetail = CM.getMasteralCurDetail(dbOP, strCourseIndex, strMajorIndex,strCYFrom, strCYTo);
if(vCurDetail != null)
	strCollegeName = CM.getCollegeName(dbOP,strCourseIndex);
//dbOP.cleanUP();


//get the footer Information. .
String strDeanName = null;
String strAssistRegistrar = null;
String strSchoolDirector  = null;

if(strSchCode.startsWith("UPH")){
	String strSQLQuery = "select dean_name from course_offered join college on (college.c_index = course_offered.c_index) where course_index =  "+strCourseIndex;
	strDeanName = WI.getStrValue(dbOP.getResultOfAQuery(strSQLQuery, 0)).toUpperCase();
	strAssistRegistrar = WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"Assistant Registrar",7)).toUpperCase();
	strSchoolDirector  = WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"School Director",7)).toUpperCase();
}



if(vCurDetail == null)
{
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=CM.getErrMsg()%></font></p>
		<%
		dbOP.cleanUP();
                return;
	}
%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
   <tr>
      <td height="25" colspan="4" ><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br><br>
        <%=strCollegeName%>
		</div></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2">Course: <strong><%=strCourseName%></strong></td>
      <td width="28%" valign="middle">CURRICULUM YEAR: <strong><%=strCYFrom%>
        - <%=strCYTo%></strong></td>
    </tr>
<%
if(strMajorName.compareTo("None") != 0){%>
	 <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="51%" valign="middle">Major: <strong><%=strMajorName%></strong></td>
      <td width="18%" valign="middle">&nbsp;</td>
      <td width="28%" valign="middle">&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>

    <td width="34%" bgcolor="#FFFFFF"><strong>Course Requirement</strong></td>
      <td width="39%" >&nbsp;</td>
      <td ><div align="center">Units</div></td>
      <td >&nbsp;</td>
    </tr>
    <tr>
<%
for(int i=0; i< vCurDetail[0].size(); ++i)
{
	fTotalUnit += Float.parseFloat((String)vCurDetail[0].elementAt(i+1));
%>
     <td height="25" >&nbsp;</td>
      <td ><%=(String)vCurDetail[0].elementAt(i++)%></td>
      <td >.................................................................</td>
      <td ><div align="center"><%=(String)vCurDetail[0].elementAt(i)%> units</div></td>
      <td >&nbsp;</td>
    </tr>
<%}%>

    <tr>
      <td height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td width="10%" valign="top" align="center" ><hr size="1"><%=fTotalUnit%></td>
      <td width="14%" >&nbsp;</td>
    </tr>
  </table>
  <table width="100%" height="100" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
<%
//System.out.println(vCurDetail[0]);
//System.out.println(vCurDetail[1]);
String strTemp2 = null;
for(int i=0, j=0; i< vCurDetail[0].size(); ++i) //arrange according to requirement
{
	strTemp = (String)vCurDetail[0].elementAt(i++);

%>
<tr>
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="4"><strong><%=strTemp%></strong></td>
    </tr>
<%	for(;j<vCurDetail[1].size();++j){
	strTemp2 = (String)vCurDetail[1].elementAt(j);
	if(strTemp.compareTo(strTemp2) != 0) break;
	%>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="9%">&nbsp;</td>
      <td width="23%"><%=(String)vCurDetail[1].elementAt(++j)%></td>
      <td width="47%"><%=(String)vCurDetail[1].elementAt(++j)%></td>
      <td width="18%"><%=(String)vCurDetail[1].elementAt(++j)%></td>
    </tr>
<%}
//}//if compare is matching.
}//outer loop%>

  </table>
  <%if(strSchCode.startsWith("UPH")){%><br><br>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr align="center">
      <td width="32%" class="thinborderBOTTOM"><%=WI.getStrValue(strDeanName, "&nbsp;")%></td>
      <td width="2%">&nbsp;</td>
      <td width="32%">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td width="32%" class="thinborderBOTTOM"><%=WI.getStrValue(strAssistRegistrar, "&nbsp;")%></td>
    </tr>
    <tr align="center">
      <td>Dean</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>Assistant Registrar</td>
    </tr>
    <tr align="center">
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr align="center">
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td width="32%" class="thinborderBOTTOM"><%=WI.getStrValue(strSchoolDirector, "DR. ALFONSO H. LORETO")%></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr align="center">
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>School Director</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%}%>
</body>
</html>
