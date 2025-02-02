<%
/* It works but i can't use it here.
if(request.getParameter("printpage") != null && request.getParameter("printpage").compareTo("1") ==0)
{
	String sT = "./courses_curriculum_print.jsp?ci="+request.getParameter("course_index")+"&cname="+request.getParameter("course_name")+
		"&mi="+request.getParameter("major_index")+"&manme="+request.getParameter("major_name")+"&syf="+request.getParameter("sy_from")+
		"&syt="+request.getParameter("sy_to");
	response.sendRedirect(response.encodeRedirectURL(sT));
	return;
}*/
%>


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
	font-size: 12px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
-->
</style>
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript">
function MyLink()
{
	confirm("you are here");
}
function PrintPg()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	var sT = "#";
	if(vProceed && document.ccurriculum.major_index.selectedIndex > 0)
	{
	sT = "./admission_courses_curriculum_print.jsp?ci="+document.ccurriculum.course_index[document.ccurriculum.course_index.selectedIndex].value+"&cname="+
	escape(document.ccurriculum.course_name.value)+"&mi="+document.ccurriculum.major_index[document.ccurriculum.major_index.selectedIndex].value+
	"&manme="+escape(document.ccurriculum.major_index[document.ccurriculum.major_index.selectedIndex].text)+
	"&syt="+document.ccurriculum.sy_to.value+"&syf="+document.ccurriculum.sy_from[document.ccurriculum.sy_from.selectedIndex].text;
	//	document.ccurriculum.major_name.value = document.ccurriculum.major_index[ccurriculum.major_index.selectedIndex].text;
	}
	else if(vProceed)
	{
		sT = "./admission_courses_curriculum_print.jsp?ci="+document.ccurriculum.course_index[document.ccurriculum.course_index.selectedIndex].value+"&cname="+
		escape(document.ccurriculum.course_name.value)+"&syt="+document.ccurriculum.sy_to.value+"&syf="+
		document.ccurriculum.sy_from[document.ccurriculum.sy_from.selectedIndex].text;
	}

	//print here
	if(vProceed)
	{
		var win=window.open(sT,"PrintWindow",'scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
function ReloadCourseIndex()
{
	document.ccurriculum.view_info.value = 0;
	//course index is changed -- so reset all dynamic fields.
	if(document.ccurriculum.sy_from.selectedIndex > -1)
		document.ccurriculum.sy_from[document.ccurriculum.sy_from.selectedIndex].value = "";
	if(document.ccurriculum.major_index.selectedIndex > -1)
		document.ccurriculum.major_index[document.ccurriculum.major_index.selectedIndex].value = "";

	document.ccurriculum.course_name.value = document.ccurriculum.course_index[document.ccurriculum.course_index.selectedIndex].text;
	document.ccurriculum.submit();
}
function ReloadPage()
{
	document.ccurriculum.view_info.value = 0;
	document.ccurriculum.submit();
}
function ViewInfo()
{

	document.ccurriculum.view_info.value = 1;
	document.ccurriculum.submit();
}


</script>
<body bgcolor="#D2AE72">
<form action="../../../../ADMIN_STAFF/admission/admission_course_curriculum.jsp" method="post" name="ccurriculum">
<%@ page language="java" import="utility.*,enrollment.SubjectSection,enrollment.CurriculumMaintenance,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	int i = -1;
	int j=0;
	String strCourseIndex 	= request.getParameter("course_index");
	String strCourseName 	= request.getParameter("course_name");
	String strMajorIndex 	= request.getParameter("major_index");
	String strSYFrom 		= request.getParameter("sy_from");
	String strSYTo = null; // this is used in
	Vector vTemp = new Vector();
	float iNoOfLECUnitPerSem = 0; float iNoOfLABUnitPerSem = 0;
	float iNoOfLECUnitPerCourse = 0;float iNoOfLABUnitPerCourse = 0;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Courses Curriculum","admission_course_curriculum.jsp");
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
														"admission_course_curriculum.jsp");
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
SubjectSection SS = new SubjectSection();

boolean bolShowCoReq = false;
String strSQLQuery = "select count(*) from SUBJECT_PREQUISITE where is_coreq = 1 and (is_del = 0 or (is_del = 0 and is_preq_disable = 1)) ";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null) {
	if(!strSQLQuery.equals("0"))
		bolShowCoReq = true;
}

%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center"><font color="#FFFFFF"><strong>::
        COURSES CURRICULUM ::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
	<tr>
      <td height="25" width="2%">&nbsp;</td>
	  <td width="31%">Course</td>
	  <td width="22%">Major</td>
	  <td width="27%">Curriculum Year</td>
	  <td width="18%">&nbsp;</td>
    </tr>

    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="31%" valign="middle">
<select name="course_index" onChange="ReloadCourseIndex();">
          <option value="selany">Select Any</option>
<%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc", strCourseIndex, false)%>
        </select>
      </td>
      <td width="22%" valign="middle">
<select name="major_index" onChange="ReloadPage();">
		<option></option>

<%
if(strCourseIndex != null && strCourseIndex.compareTo("selany") != 0)
{
strTemp = " from major where is_del=0 and course_index="+strCourseIndex+" order by major_name asc" ;
%>
<%=dbOP.loadCombo("major_index","major_name",strTemp, strMajorIndex, false)%>
<%}%>

   </select>

      </td>
      <td width="27%" valign="middle">
        <select name="sy_from" onChange="ReloadPage();">
          <%
//get here school year
vTemp = SS.getSchYear(dbOP, request);
strTemp = request.getParameter("sy_from");//System.out.println(strTemp);
if(strTemp == null) strTemp = "";

for(i = 0, j=0 ; i< vTemp.size();)
{
	if(	((String)vTemp.elementAt(i)).compareTo(strTemp) == 0)
	{%>
          <option value="<%=(String)vTemp.elementAt(i)%>" selected><%=(String)vTemp.elementAt(i)%></option>
          <%	j = i;
	}
	else{
	%>
          <option value="<%=(String)vTemp.elementAt(i)%>"><%=(String)vTemp.elementAt(i)%></option>
          <%	}
	i = i+2;

}
if(vTemp.size() > 0)
	strSYTo = (String)vTemp.elementAt(j+1);
else
	strSYTo = "";

%>
        </select> <font size="2" face="Verdana, Arial, Helvetica, sans-serif">to
        <b><%=strSYTo%></b></font>
        <input type="hidden" name="sy_to" value="<%=strSYTo%>">
	  </td>
      <td width="18%" valign="middle"><input type="image" src="../../../../images/view.gif" name="Submit2" onClick="ViewInfo();"></td>
    </tr>
    <tr>
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
 <%
 //get here curriculum information
if(request.getParameter("view_info") != null && request.getParameter("view_info").compareTo("1") == 0)
{
	CurriculumMaintenance CM = new CurriculumMaintenance();
	if(strCourseIndex == null || strCourseIndex.trim().length() == 0  ||
		request.getParameter("sy_from") == null || request.getParameter("sy_from").trim().length() == 0 || strSYTo == null)
	{
		strErrMsg = "Can't process curriculum detail. Curriculum Year information missing.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=strErrMsg%></font></p>
		<%
	}

	//get here total year and semester of the course.
	int[][] aiYearSem = CM.getMaxYearSemester(dbOP,strCourseIndex, strSYFrom, strSYTo);

	if(aiYearSem == null && strErrMsg == null)
	{
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=CM.getErrMsg()%></font></p>
		<%
	}
	else{
	%>


  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td>
      <td colspan="7"><div align="right"> <a href="javascript:PrintPg();"><img src="../../../../images/print.gif" width="58" height="26" border="0"></a>
          <font size="1">click to print course curriculum</font> </div></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%
	String [] astrConvertToWord={"First","Second","Third","Forth","Fifth","Sixth","Seventh","Eighth","Nineth"};
	Vector vRetResult = new Vector();
	for( i = 1; i<= aiYearSem[0][0]; ++i) //[0][0] = no of years
	{%>
    <tr>
      <td>&nbsp;</td>
      <td colspan="7"><div align="center"><strong><%=astrConvertToWord[i-1]%>
          Year </strong></font></div></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%
		for(j= 1; j<= aiYearSem[i][0]; ++j)
		{%>
    <tr>
      <td width="2%">&nbsp;</td>
      <td colspan="7"><strong><u><%=astrConvertToWord[j-1]%> Semester</u></strong></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%
			vRetResult = CM.viewCurrPerSemester(dbOP, strCourseIndex, i, strMajorIndex,j, strSYFrom, strSYTo);
			int iGenderSpecific = 0;
			if(vRetResult != null)
				for(int k= 0 ; k< vRetResult.size(); ++k)
				{
//display the heading only once.
if(i ==1 && j ==1 && k==0)
{%>
    <tr>
      <td rowspan="2">&nbsp;</td>
      <td  height="19" rowspan="2"><font size="1"><strong>SUBJECT CODE</strong></font></td>
      <td rowspan="2"><font size="1"><strong>SUBJECT NAME/DESCRIPTION</strong></font></td>
      <td colspan="2" align="center"><strong><font size="1">HOURS</font></strong></td>
      <td colspan="2" align="center"><strong><font size="1">UNITS</font></strong></td>
      <td rowspan="2"><font size="1"><strong>PRE-REQUISITE</strong></font></td>
<%if(bolShowCoReq){%>
      <td rowspan="2"><font size="1"><strong>CO-REQUISITE</strong></font></td>
<%}%>
    </tr>
    <tr>
      <td align="center"><font size="1"><strong>LEC</strong></font></td>
      <td align="center"><font size="1"><strong>LAB</strong></font></td>
      <td align="center"><font size="1"><strong>LEC</strong></font></td>
      <td align="center"><font size="1"><strong>LAB</strong></font></td>
    </tr>
    <%}%>
    <tr>
      <td>&nbsp;</td>
      <td width="22%"  height="19"><%=(String)vRetResult.elementAt(k+1)%></td>
      <td width="46%"><%=(String)vRetResult.elementAt(k+2)%></td>
      <td width="8%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+5))%></td>
      <td width="8%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+6))%></td>
      <td width="7%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+3))%></td>
      <td width="7%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+4))%></td>
      <td width="14%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+7))%></td>
<%if(bolShowCoReq){%>
      <td width="10%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+9))%></td>
<%}%>
    </tr>
    <%
		if(iGenderSpecific <1) {
			iNoOfLECUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+3));
			iNoOfLABUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+4));
		}
		if( vRetResult.elementAt(k + 8) != null && iGenderSpecific ==0) {
			++iGenderSpecific;
		}else
			iGenderSpecific = 0;
//				iNoOfLECUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+3));
//				iNoOfLABUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+4));
				k = k+9;
				}%>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td>&nbsp;</td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <tr>
      <td colspan="8"><div align="center"><em><strong>Total units : <%=(iNoOfLECUnitPerSem+iNoOfLABUnitPerSem)%>
          , Lecture Unit = <%=iNoOfLECUnitPerSem%>, Lab Unit=<%=iNoOfLABUnitPerSem%></strong></em></div></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <tr>
      <td height="22" colspan="8">&nbsp;</td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%
		iNoOfLECUnitPerCourse += iNoOfLECUnitPerSem;
		iNoOfLABUnitPerCourse += iNoOfLABUnitPerSem;

		iNoOfLECUnitPerSem = 0;
		iNoOfLABUnitPerSem = 0;
		}//end of loop for semesters

/// end of a year == check if it is having summer for this year.
	vRetResult = CM.viewSummerCurrPerYr(dbOP,strCourseIndex,i, strMajorIndex,strSYFrom, strSYTo);
	if(vRetResult != null && vRetResult.size() > 0)
	{//start of summer courses.
	%>
    <tr>
      <td>&nbsp;</td>
      <td colspan="7" align="center"><b>SUMMER</b></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%//
  	for(int p=0; p< vRetResult.size(); ++p)
	{%>
    <tr>
      <td>&nbsp;</td>
      <td width="22%"  height="19"><%=(String)vRetResult.elementAt(p+1)%></td>
      <td width="46%"><%=(String)vRetResult.elementAt(p+2)%></td>
      <td width="8%" align="center"><%=WI.getStrValue(vRetResult.elementAt(p+5))%></td>
      <td width="8%" align="center"><%=WI.getStrValue(vRetResult.elementAt(p+6))%></td>
      <td width="7%" align="center"><%=WI.getStrValue(vRetResult.elementAt(p+3))%></td>
      <td width="7%" align="center"><%=WI.getStrValue(vRetResult.elementAt(p+4))%></td>
      <td width="14%" align="center"><%=WI.getStrValue(vRetResult.elementAt(p+7))%></td>
<%if(bolShowCoReq){%>
      <td width="10%" align="center">&nbsp;</td>
<%}%>
    </tr>
    <%
		iNoOfLECUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(p+3));
		iNoOfLABUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(p+4));
		p = p+7;
	}%>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td>&nbsp;</td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <tr>
      <td colspan="8" align="center"><em><strong>Total units : <%=(iNoOfLECUnitPerSem+iNoOfLABUnitPerSem)%>
        ,Lecture Unit = <%=iNoOfLECUnitPerSem%>, Lab Unit=<%=iNoOfLABUnitPerSem%></strong></em></td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <tr>
      <td height="22" colspan="8">&nbsp;</td>
<%if(bolShowCoReq){%>
      <td></td>
<%}%>
    </tr>
    <%
	iNoOfLECUnitPerCourse += iNoOfLECUnitPerSem;
	iNoOfLABUnitPerCourse += iNoOfLABUnitPerSem;

	iNoOfLECUnitPerSem = 0;
	iNoOfLABUnitPerSem = 0;
	}//end of loop for Summer == It starts after semister loops.



}//end of loop for year.
	%>
  </table>
	<table bgcolor="#FFFFFF" width="100%">
    <tr>
      <td colspan="5">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="5"><strong>Total
        units for course <%=strCourseName%>: <u><%=iNoOfLECUnitPerCourse+iNoOfLABUnitPerCourse%>
        ,Lecture Unit = <%=iNoOfLECUnitPerCourse%>, Lab Unit=<%=iNoOfLABUnitPerCourse%></u></strong></td>
    </tr>
    <tr>
      <td colspan="5">&nbsp;</td>
    </tr>
  </table>

<table width="100%" bgcolor="#FFFFFF">
<tr>
<td width="50%"></td>
<td width="50%"></td>
</tr>
<%
//get Internship detail here,
String[] astrDuration= {"week","hours"};
vRetResult = CM.viewInternshipForCourse(dbOP, strCourseIndex,  strMajorIndex, strSYFrom, strSYTo);
if(vRetResult != null && vRetResult.size() > 0)
{%>
	<tr>
	<td colspan="2" align="center"><b>:SUGGESTED INTERNSHIP SCHEDULE:</b></td>
	</tr>
<%
	for(int q=0; q< vRetResult.size() ; ++q)
	{
		if( ((String)vRetResult.elementAt(q+4)).compareTo("0") ==0)//in summer.
			strTemp = "Summer after "+astrConvertToWord[Integer.parseInt((String)vRetResult.elementAt(q+3)) - 1]+" year";
		else //sem break
			strTemp = astrConvertToWord[Integer.parseInt((String)vRetResult.elementAt(q+4)) - 1]+" Sem break of the "+
						astrConvertToWord[Integer.parseInt((String)vRetResult.elementAt(q+3)) - 1]+" year";
		%>
		<tr>
		<td align="right"><%=strTemp%>&nbsp; &nbsp; &nbsp;</td>
		<td><%=(String)vRetResult.elementAt(q+2)%> <%=astrDuration[Integer.parseInt((String)vRetResult.elementAt(q+1))]%> -
			<%=(String)vRetResult.elementAt(q)%></td>
		</tr>
 	<%q = q+4;}

}//end of displaying internship%>



</table>
<%
Vector vElectiveSubList = CM.getElectiveSubListPerCurriculum(dbOP, strCourseIndex,strMajorIndex, strSYFrom, strSYTo);
if(vElectiveSubList != null && vElectiveSubList.size() > 0)
{%>
<table width="100%" bgcolor="#FFFFFF">
	<tr>
	<td width="17%"></td>
	<td width="83%"></td>
	</tr>
	<tr>
	  <td colspan="2" align="center"><b>:ELECTIVE SUBJECT LIST:</b></td>
	</tr>
<%//System.out.println(vElectiveSubList);
for(int s=0; s< vElectiveSubList.size(); ++s){
strTemp = (String)vElectiveSubList.elementAt(s);
%>
	<tr>
	  <td align="right" valign="top"><strong><%=strTemp%></strong>&nbsp; &nbsp; &nbsp;</td>
	<td>
	<%
	for(int t=0;s<vElectiveSubList.size(); ++s,++t){
	if(strTemp.compareTo((String)vElectiveSubList.elementAt(s)) ==0){
	if(t !=0){%>,<%}%>
	<%=(String)vElectiveSubList.elementAt(s+1)%>
	<% s = s+1;
	continue;
	}else {s = s-2; break;}
	}%>
	</td>
	</tr>
<%++s;
}%>
</table>
<%}//if there is elective.
%>


<table width="100%" bgcolor="#FFFFFF">
<tr>
	<td width="6%">&nbsp;</td>
      <td> <a href="javascript:PrintPg();"><img src="../../../../images/print.gif" width="58" height="26" border="0"></a>
        <font size="1">click to print course curriculum</font></td>
 </tr>
  </table>

<%} //if no error in getting curriculum .
}//this is end of displaying curriculum information if view is clicked..%>

  <table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" colspan="2">&nbsp;</td>
    </tr>

    <tr>
      <td colspan="2"><div align="center"> </div></td>
    </tr>
    <tr>
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="course_name" value="<%=request.getParameter("course_name")%>">
<input type="hidden" name="view_info" value="0">
<input type="hidden" name="printpage" value="0">
<input type="hidden" name="major_name" value="">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
