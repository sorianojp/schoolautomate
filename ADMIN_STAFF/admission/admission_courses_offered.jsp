<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
	a{	
		text-decoration: none;
	}

</style>

<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
</head>
<script language="JavaScript">
function goToNextSearchPage()
{
	document.ccourse.submit();
}


function viewCurriculum(strCourseIndex, strMajorIndex,strCName, strMname){
	document.ccourse.ci.value = strCourseIndex;
	document.ccourse.mi.value  = strMajorIndex;
	document.ccourse.course_index.value = strCourseIndex;
	document.ccourse.major_index.value  = strMajorIndex;
	document.ccourse.cname.value  = strCName;
	document.ccourse.mname.value  = strMname;	
	document.ccourse.submit();
}

function popCurriculum(strCourseIndex, strMajorIndex,strSYFrom, strSYTo, 
						strDegreeType,strCName, strMname)
{
	var pgLoc;
	var numDegreType = Number(strDegreeType);
	
//	alert(numDegreType);
	
	switch(numDegreType){
		case 0 : pgLoc = "./curriculum_viewall.jsp?ci=" + strCourseIndex + "&mi="+strMajorIndex + 
					"&syf="+strSYFrom + "&syt="+ strSYTo + "&cname="+ escape(strCName) + 
					"&mname="+ escape(strMname);
				break;

		case 1 : pgLoc = "./curriculum_m_d_viewall.jsp?ci=" + strCourseIndex + "&mi="+strMajorIndex + 
					"&syf="+strSYFrom + "&syt="+ strSYTo + "&cname="+ escape(strCName) + 
					"&mname="+ escape(strMname);
				break;

		case 2 : pgLoc = "./curriculum_medicine_viewall.jsp?ci=" + strCourseIndex + 
					"&mi="+strMajorIndex + "&syf="+strSYFrom + "&syt="+ strSYTo + 
					"&cname="+ escape(strCName) + "&mname="+ escape(strMname);
				break;

		case 3 : pgLoc = "./curriculum_proper_viewall.jsp?ci=" + strCourseIndex + 
					"&mi="+strMajorIndex + "&syf="+strSYFrom + "&syt="+ strSYTo + 
					"&cname="+ escape(strCName) + "&mname="+ escape(strMname);
				break;

		case 4 : pgLoc = "./curriculum_nosem_viewall.jsp?ci=" + strCourseIndex + "&mi="+strMajorIndex + 
					"&syf="+strSYFrom + "&syt="+ strSYTo + 
					"&cname="+ escape(strCName) + "&mname="+ escape(strMname);
				break;
	}
		
//	alert(pgLoc);
		
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumCourse,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
					"Admin/staff-Admission-Courses Offered","admission_courses_offered.jsp");
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
//CommonUtil comUtil = new CommonUtil();
//int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
//								(String)request.getSession(false).getAttribute("userId"),
//								"Admission","Courses Offered",request.getRemoteAddr(),
//								"admission_courses_offered.jsp");
								
//if(iAccessLevel == -1)//for fatal error.
//{
//	dbOP.cleanUP();
//	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
//	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
//	response.sendRedirect("../../commfile/fatal_error.jsp");
//	return;
//}
//else if(iAccessLevel == 0)//NOT AUTHORIZED.
//{
//	dbOP.cleanUP();
//	response.sendRedirect("../../commfile/unauthorized_page.jsp");
//	return;
//}

//end of authenticaion code.

strErrMsg = null; //if there is any message set -- show at the bottom of the page.
CurriculumCourse CC = new CurriculumCourse();
//collect all the schedule information.
int iSearchResult = 0;
Vector vRetResult = CC.viewAll(dbOP,request,false,true);
iSearchResult = CC.iSearchResult;

String strSYFrom   = null;
String strSYTo = null;
String strDegreeType = null;

if (WI.fillTextValue("ci").length() > 0){
	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED", 
								"COURSE_INDEX", WI.fillTextValue("course_index"),
								"degree_type", " and is_valid = 1 and is_del = 0");
	
	if (strDegreeType != null) {
		Vector vTemp = new enrollment.SubjectSection().getSchYear(dbOP, request, true);
		if (vTemp != null && vTemp.size() > 0){
			strSYFrom = (String)vTemp.elementAt(0);
			strSYTo = (String)vTemp.elementAt(1);
		}	
	}
} 

%>
<form action="./admission_courses_offered.jsp" method="post" name="ccourse">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="6" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
      COURSES ::::</strong></font></div></td>
    </tr>
    <%
if(strErrMsg != null)
{%>
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" colspan="5"><strong><%=strErrMsg%></strong></td>
    </tr>
    <%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5">To filter enter course code starts with 
        <input type="text" name="filter_course" value="<%=WI.fillTextValue("filter_course")%>" size="6" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        and click REFRESH<a href="javascript:goToNextSearchPage();"><img src="../../images/refresh.gif" border="0"></a> 
      </td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0)
{%>
  <table width="100%" bgcolor="#FFFFFF">
    <tr> 
      <td width="66%" height="45"><b> Total courses created: <%=iSearchResult%> - Showing(<%=CC.strDispRange%>)</b></td>
      <td width="34%"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/CC.defSearchSize;
		if(iSearchResult % CC.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="goToNextSearchPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
          <%}%>
        </div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="11%" height="25" class="thinborder"><div align="center"><strong><font size="1">COURSE
      CODE </font></strong></div></td>
      <td width="23%" class="thinborder"><div align="center"><strong><font size="1">COURSE NAME </font></strong></div></td>
      <td width="22%" class="thinborder"><div align="center"><strong><font size="1">MAJOR</font></strong></div></td>
      <td width="17%" class="thinborder"><div align="center"><strong><font size="1">CLASSIFICATION</font></strong></div></td>
      <td width="19%" class="thinborder"><div align="center"><strong><font size="1">COLLEGE </font></strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">CUR FORMAT</font></strong></div></td>
    </tr>
 <% for(int i = 0 ; i< vRetResult.size(); ++i) {%>
    <tr>
      <td height="25" class="thinborder">
	  <a href="javascript:viewCurriculum('<%=(String)vRetResult.elementAt(i)%>','<%=WI.getStrValue((String)vRetResult.elementAt(i+9))%>','<%=(String)vRetResult.elementAt(i+4)%>','<%=WI.getStrValue(vRetResult.elementAt(i+7))%>')"><%=(String)vRetResult.elementAt(i+3)%> </a>
	 
  	  </td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+7),"&nbsp;")%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
    </tr>
    <%
	i = i+9;
}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
      <tr>
		<td>&nbsp;</td>
    </tr>
    <tr>
		<td>
			<strong><font size="1">Click on the course code to view Latest course curriculum</font>
			</strong></td>
    </tr>
  </table>
 <%}//end of showing if there is course created.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"></tr>


    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="ci" value="">
<input type="hidden" name="mi" value="">
<input type="hidden" name="course_index" value="">
<input type="hidden" name="major_index" value="">
<input type="hidden" name="degree_type" value="">
<input type="hidden" name="cname" value="">
<input type="hidden" name="mname" value="">

</form>

<script language="javascript">
<% if (strSYFrom != null) {%> 
	popCurriculum('<%=WI.fillTextValue("ci")%>','<%=WI.fillTextValue("mi")%>',
					<%=strSYFrom%>,<%=strSYTo%>,'<%=WI.getStrValue(strDegreeType)%>',
					'<%=WI.fillTextValue("cname")%>','<%=WI.getStrValue(WI.fillTextValue("mname"))%>');
<%}%> 
</script>

</body>
</html>

<%
dbOP.cleanUP();
%>