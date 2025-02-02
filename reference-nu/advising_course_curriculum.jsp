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
<form action="../../admission/./admission_course_curriculum.jsp" method="post" name="ccurriculum">
<%@ page language="java" import="utility.*,enrollment.SubjectSection, enrollment.CurriculumMaintenance,java.util.Vector" %>
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

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-course curriculum","advising_course_curriculum.jsp");
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
SubjectSection SS = new SubjectSection();

%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>::
        COURSES CURRICULUM ::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" width="1%">&nbsp;</td>
      <td width="39%">Course</td>
      <td width="34%">Major</td>
      <td width="26%">Curriculum Year</td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="39%" valign="middle"><strong>$course </strong></td>
      <td width="34%" valign="middle"><strong>$major</strong> </td>
      <td width="26%" valign="middle"> <select name="sy_from" onChange="ReloadPage();">
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
        <b><%=strSYTo%></b></font> <input type="hidden" name="sy_to" value="<%=strSYTo%>">
      </td>
    </tr>
    <tr>
      <td height="25" colspan="4"><hr size="1"></td>
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
	int[][] aiYearSem = CM.getMaxYearSemester(dbOP,strCourseIndex);

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
    <%
	String [] astrConvertToWord={"First","Second","Third","Forth","Fifth","Sixth","Seventh","Eighth","Nineth"};
	Vector vRetResult = new Vector();
	for( i = 1; i<= aiYearSem[0][0]; ++i) //[0][0] = no of years
	{%>
    <tr>
      <td>&nbsp;</td>
      <td><div align="right"><img src="../../../images/form_proceed.gif" width="81" height="21"></div></td>
      <td>&nbsp;</td>
      <td colspan="3"><font size="2">Tick box(boxes) to select subject for advising</font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="5"><div align="center"><strong><%=astrConvertToWord[i-1]%>
          Year </strong></font></div></td>
    </tr>
    <%
		for(j= 1; j<= aiYearSem[i][0]; ++j)
		{%>
    <tr>
      <td width="2%">&nbsp;</td>
      <td colspan="5"><strong><u><%=astrConvertToWord[j-1]%> Semester</u></strong></td>
    </tr>
    <%
			vRetResult = CM.viewCurrPerSemester(dbOP, strCourseIndex, i, strMajorIndex,j, strSYFrom, strSYTo);
			if(vRetResult != null)
				for(int k= 0 ; k< vRetResult.size(); ++k)
				{
//display the heading only once.
if(i ==1 && j ==1 && k==0)
{%>
    <tr>
      <td>&nbsp;</td>
      <td  height="19"><font size="1"><strong>SUBJECT CODE</strong></font></td>
      <td><font size="1"><strong>SUBJECT NAME/DESCRIPTION</strong></font></td>
      <td><font size="1"><strong>LEC.UNITS</strong></font></td>
      <td><font size="1"><strong>LAB.UNITS</strong></font></td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
    <tr>
      <td>&nbsp;</td>
      <td width="22%"  height="19"><div align="left"><%=(String)vRetResult.elementAt(k+1)%></div></td>
      <td width="46%"><div align="left"><%=(String)vRetResult.elementAt(k+2)%></div></td>
      <td width="16%"><div align="left"><%=(String)vRetResult.elementAt(k+3)%></div></td>
      <td width="14%"><%=(String)vRetResult.elementAt(k+4)%></td>
      <td width="14%"> <div align="left">
          <input type="checkbox" name="checkbox" value="checkbox">
        </div></td>
    </tr>
    <%
				iNoOfLECUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+3));
				iNoOfLABUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+4));
				k = k+5;
				}%>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td> <div align="left">
          <input type="checkbox" name="checkbox2" value="checkbox">
        </div></td>
    </tr>
    <tr>
      <td colspan="6"><div align="center"><em><strong>Total units : <%=(iNoOfLECUnitPerSem+iNoOfLABUnitPerSem)%>
          , Lecture Unit = <%=iNoOfLECUnitPerSem%>, Lab Unit=<%=iNoOfLABUnitPerSem%></strong></em></div></td>
    </tr>
    <tr>
      <td height="22" colspan="6">&nbsp;</td>
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
      <td colspan="5" align="center"><b>SUMMER</b></td>
    </tr>
    <%//
  	for(int p=0; p< vRetResult.size(); ++p)
	{%>
    <tr>
      <td>&nbsp;</td>
      <td width="22%"  height="19"><%=(String)vRetResult.elementAt(p+1)%></td>
      <td width="46%"><%=(String)vRetResult.elementAt(p+2)%></td>
      <td width="16%"><%=(String)vRetResult.elementAt(p+3)%></td>
      <td width="14%"><%=(String)vRetResult.elementAt(p+4)%></td>
      <td width="14%"> <div align="left">
          <input type="checkbox" name="checkbox" value="checkbox">
        </div></td>
    </tr>
    <%
		iNoOfLECUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(p+3));
		iNoOfLABUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(p+4));
		p = p+4;
	}%>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td> <div align="left">
          <input type="checkbox" name="checkbox2" value="checkbox">
        </div></td>
    </tr>
    <tr>
      <td colspan="6" align="center"><em><strong>Total units : <%=(iNoOfLECUnitPerSem+iNoOfLABUnitPerSem)%>
        ,Lecture Unit = <%=iNoOfLECUnitPerSem%>, Lab Unit=<%=iNoOfLABUnitPerSem%></strong></em></td>
    </tr>
    <tr>
      <td height="22" colspan="6">&nbsp;</td>
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
      <td colspan="2"></td>
    </tr>
    <%
//get Internship detail here,
String[] astrDuration= {"week","hours"};
vRetResult = CM.viewInternshipForCourse(dbOP, strCourseIndex,  strMajorIndex, strSYFrom, strSYTo);
if(vRetResult != null && vRetResult.size() > 0)
{%>
    <tr>
      <td colspan="3" align="center"><b>:SUGGESTED INTERNSHIP SCHEDULE:</b></td>
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
      <td width="40%"><%=(String)vRetResult.elementAt(q+2)%> <%=astrDuration[Integer.parseInt((String)vRetResult.elementAt(q+1))]%>
        - <%=(String)vRetResult.elementAt(q)%></td>
      <td width="10%"> <div align="left">
          <input type="checkbox" name="checkbox3" value="checkbox">
        </div></td>
    </tr>
    <%q = q+4;}

}//end of displaying internship%>
  </table>
<table width="100%" bgcolor="#FFFFFF">
<tr>
	<td width="6%">&nbsp;</td>
      <td> <font size="1"><img src="../../../images/form_proceed.gif" width="81" height="21"></font></td>
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
