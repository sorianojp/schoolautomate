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

-->
</style>
</head>
<body>
<%@ page language="java" import="utility.*,enrollment.CurriculumMaintenance,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	String strErrMsg = null;
	String strTemp = null;

	String strCourseIndex 	= request.getParameter("ci");
	String strCourseName 	= request.getParameter("cname");
	String strMajorIndex 	= request.getParameter("mi");
	String strMajorName 	= request.getParameter("mname");
	if(strMajorName == null || strMajorName.trim().length() ==0) strMajorName = "None";
	String strSYFrom 		= request.getParameter("syf");
	String strSYTo 			= request.getParameter("syt");

	WebInterface WI = new WebInterface(request);
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Courses Curriculum","curriculum_medicine_viewall.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission","Courses Curriculum",request.getRemoteAddr(),
														"curriculum_medicine_viewall.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.


strErrMsg = null; //if there is any message set -- show at the bottom of the page.
CurriculumMaintenance CM = new CurriculumMaintenance();
if(strCourseIndex == null || strSYFrom == null || strSYTo == null)
{
	strErrMsg = "Can't process curriculum detail. course, Curriculum year From /To information missing.";
	dbOP.cleanUP();
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=strErrMsg%></font></p>
	<%
	return;
}

//get here curriculum list.
Vector vCurDetail = CM.getCOMCurDetail(dbOP, strCourseIndex, strSYFrom,strSYTo);
String 	strCollegeName = CM.getCollegeName(dbOP,strCourseIndex);

//dbOP.cleanUP();

if(vCurDetail == null || vCurDetail.size() ==0)
{
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=CM.getErrMsg()%></font></p>
	<%
	dbOP.cleanUP();
        return;
}

%>
  <table width="100%" border="0"  cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4" ><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=strCollegeName%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,true)%></div></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="40%" colspan="2">Course Name : <strong><%=strCourseName%></strong></td>
      <td width="29%">&nbsp;</td>
    </tr><tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="40%">Curriculum Year :<strong> <%=strSYFrom%>
        - <%=strSYTo%></strong></td>
      <td width="29%">&nbsp;</td>
      <td width="29%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" >
    <%
String[] astrConvertTerm  = {"Summer","First Semester","Second Semester"};
String[] astrConvertToWord={"","First","Second","Third","Fourth","Fifth","Sixth","Seventh","Eighth","Nineth"};
String[] astrConvertToYear={"","First Year","Second Year","Third Year","4th Year<br><u>Twelve Full-Month Clinical Clerkship Program</u>"};
String[] astrConvertGrading= {"Semestral","Yearly"};

String strPrevYear = null;String strYear = null;
String strPrevSem  = null;String strSem = null;
String strPrevMainSubCode = null; //if main subject code repeats, it hs having sub subject code.
String strMainSubCode = null;
//System.out.println(vCurDetail);
for( int i = 0; i< vCurDetail.size();) //
{
strPrevYear = (String)vCurDetail.elementAt(i+8);
%>
    <tr>
      <td>&nbsp;</td>
      <td colspan="6"><div align="center"><strong><%=astrConvertToYear[Integer.parseInt(strPrevYear)]%></strong></div></td>
    </tr>
    <%
	for(int j= i; j< vCurDetail.size();)
	{
	strYear = (String)vCurDetail.elementAt(j+8);
	if(strPrevYear.compareTo(strYear) != 0) break; //start off a new year.

	strPrevSem = (String)vCurDetail.elementAt(j+9);
	if(strPrevSem != null){%>
    <tr>
      <td width="3%">&nbsp;</td>
      <td colspan="6"><strong><u><!--<%//=astrConvertToWord[Integer.parseInt(strPrevSem)]%>Semester-->
	  <%=astrConvertTerm[Integer.parseInt(strPrevSem)]%></u></strong></td>
    </tr>
     <%}
	 for(int k=j; k< vCurDetail.size() ;)
	 {
	 	strSem = (String)vCurDetail.elementAt(k+9);//System.out.println(strSem);System.out.println(strPrevSem);
		if(strPrevSem != null && strSem == null) break;//
		if(strPrevSem != null && strPrevSem.compareTo(strSem) != 0) break;////start off a new sem - DO NOT CHECK FOR YEARLY COURSE WITH NO SEM

		strYear = (String)vCurDetail.elementAt(k+8);
		if(strPrevYear.compareTo(strYear) != 0) break; //start off a new year.

	 	strPrevMainSubCode = (String)vCurDetail.elementAt(k);
		//strMainSubCode = (String)vCurDetail.elementAt(k);
		%>
    <tr>
      <td>&nbsp;</td>
      <td ><%=strPrevMainSubCode%></td>
      <td colspan="3"><%=(String)vCurDetail.elementAt(k+1)%></td>
      <td><%
if(((String)vCurDetail.elementAt(k+7)).compareTo("1") ==0){%>
	  <%=astrConvertGrading[Integer.parseInt((String)vCurDetail.elementAt(k+7))]%>
<%}%>  </td>
      <td><%=(String)vCurDetail.elementAt(k+4)%>(<%=(String)vCurDetail.elementAt(k+6)%>)</td>
    </tr>
    <%
	if( (k+15) < vCurDetail.size() && ((String)vCurDetail.elementAt(k+10)).compareTo(strPrevMainSubCode) ==0)
	{k = k+10;
		for(int l = k; l< vCurDetail.size();)
		{
			//only if main subject code is same.
			strMainSubCode = (String)vCurDetail.elementAt(l);
			//System.out.println(strMainSubCode);System.out.println(strPrevMainSubCode);
			if(strMainSubCode.compareTo(strPrevMainSubCode) ==0)
			{
				%>
				<tr>
				  <td>&nbsp;</td>
				  <td width="18%">&nbsp;</td>
				  <td colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;<%=(String)vCurDetail.elementAt(l+2)%></td>
				  <td width="34%"><%=(String)vCurDetail.elementAt(l+3)%></td>

      <td width="8%">&nbsp;</td>
				  <td width="18%"><div align="left">(<%=(String)vCurDetail.elementAt(l+5)%>)</div></td>
				</tr>
		<% 	l = l+10;
			k = l;
			}
			else{k = k-10; break;}
		}
	}
  k = k+10;
  j = k;}//for(int k=j; k< vCurDetail.size() ;)
 i = j;}//for(int j= i; j<= vCurDetail.size(); ++j)
}//for( int i = 0; i<= vCurDetail.size(); ++i)
%>
    <!--<tr>
    	<td></td>
    	<td> </td>
    	<td colspan="5">R E V A L I D A</td>
    </tr>
	-->
  </table>
<script language="javascript">
window.print();
window.setInterval("javascript:window.close();",0);
//window.setInterval("javascript:window.close();",1)
</script>
</body>
</html>
