<%@ page language="java" import="utility.*,enrollment.CurriculumCourse,enrollment.SubjectSection,java.util.Vector, java.util.Date" %>
<%
	WebInterface WI = new WebInterface(request);
	String strTemp = null;

if(WI.fillTextValue("goNextPage").compareTo("1") ==0){
//forward page here,
strTemp = WI.fillTextValue("degree_type");
	if(strTemp.compareTo("0") ==0){strTemp = null;%>
		<jsp:forward page="./curriculum_viewall.jsp" />
	<%}else if(strTemp.compareTo("1") ==0){strTemp = null;%>
		<jsp:forward page="./curriculum_m_d_viewall.jsp" />
	<%}else if(strTemp.compareTo("2") ==0){strTemp = null;%>
		<jsp:forward page="./curriculum_medicine_viewall.jsp" />
	<%}else if(strTemp.compareTo("3") ==0){strTemp = null;%>
		<jsp:forward page="./curriculum_proper_viewall.jsp" />
	<%}else if(strTemp.compareTo("4") ==0){strTemp = null;%>
		<jsp:forward page="./curriculum_nosem_viewall.jsp" />
	<%}
	else strTemp = "Course curriculum format not found. Please check course offered list for detail.";
}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CURRICULUM-main</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function GoNextPage()
{
	document.cmaintenance.goNextPage.value="1";
	document.cmaintenance.cname.value = document.cmaintenance.course_index[document.cmaintenance.course_index.selectedIndex].text;
	if(document.cmaintenance.major_index.selectedIndex>0)
	{
		document.cmaintenance.mname.value = document.cmaintenance.major_index[document.cmaintenance.major_index.selectedIndex].text;
		document.cmaintenance.mi.value =  document.cmaintenance.major_index[document.cmaintenance.major_index.selectedIndex].value;
	}
	document.cmaintenance.ci.value = document.cmaintenance.course_index.value;
}
function ChangeProgram()
{
	document.cmaintenance.changeProgram.value="1";
	ReloadPage();
}
function ReloadPage()
{
	document.cmaintenance.goNextPage.value="0";
	document.cmaintenance.submit();
}
function ReloadCourseIndex()
{
	if(document.cmaintenance.syf.selectedIndex > -1)
		document.cmaintenance.syf[document.cmaintenance.syf.selectedIndex].value = "";
	if(document.cmaintenance.major_index.selectedIndex > -1)
		document.cmaintenance.major_index[document.cmaintenance.major_index.selectedIndex].value = "";
	ReloadPage();
}
</script>
<body bgcolor="#9FBFD0">
<%

	DBOperation dbOP = null;
	SessionInterface sessInt= new SessionInterface();
	MessageConstant mConst 	= new MessageConstant();
	String strSYFrom       	= request.getParameter("syf");
	String strSYTo 		   	= null; // this is used in
	Vector vTemp			= new Vector();

SubjectSection SS = new SubjectSection();
int i=0;int j=0;
//add security here.

	try
	{
		dbOP = new DBOperation();
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
if(strTemp == null) strTemp = "";
%>
<form name="cmaintenance">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#47768F">
      <td height="25" colspan="4" bgcolor="#47768F"><div align="center"><font color="#FFFFFF"><strong>::::
      COURSES CURRICULUM INFORMATION::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td width="18%" height="25">&nbsp;</td>
      <td width="38%" height="25">Programs</td>
      <td width="44%" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td  colspan="2" height="25"><select name="cc_index" onChange="ChangeProgram();">
          <option value="0">Select a Program</option>
          <%=dbOP.loadCombo("cc_index","cc_name"," from CCLASSIFICATION where IS_DEL=0 order by cc_name asc", request.getParameter("cc_index"), false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Course</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" height="25"> <select name="course_index" onChange="ReloadCourseIndex();">
          <option value="0">Select a course</option>
          <%
if(WI.fillTextValue("cc_index").length()>0){%>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 and cc_index="+
 						request.getParameter("cc_index")+" order by course_name asc", request.getParameter("course_index"), false)%>
          <%}%>
        </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Major</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" height="25"> <select name="major_index" onChange="ReloadPage();">
          <%
if(WI.fillTextValue("course_index").length()>0 && WI.fillTextValue("changeProgram").compareTo("1") != 0){
strTemp = " from major where IS_DEL=0 and course_index="+request.getParameter("course_index")+" order by major_name asc";
%>
          <%=dbOP.loadCombo("major_index","major_name"," from major where IS_DEL=0 and course_index="+
 							request.getParameter("course_index")+" order by major_name asc", request.getParameter("major_index"), false)%>
          <%}%>
        </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Curriculum year :
        <select name="syf" onChange="ReloadPage();">
          <%
//get here school year
if(WI.fillTextValue("changeProgram").compareTo("1") ==0)
	vTemp.clear();
else
	vTemp = SS.getSchYear(dbOP, request);
strTemp = request.getParameter("syf");//System.out.println(strTemp);
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
        </select> to <b><%=strSYTo%></b></font> <input type="hidden" name="syt" value="<%=strSYTo%>">
      </td>
      <td height="25">&nbsp;</td>
    </tr>
    <%
//show this only if course/major is selected properly.
if(WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("course_index").compareTo("0") != 0 &&
	WI.fillTextValue("changeProgram").compareTo("1") != 0){
strTemp = " and is_del=0 and is_valid=1";
strTemp = dbOP.mapOneToOther("COURSE_OFFERED","course_index", request.getParameter("course_index"),"DEGREE_TYPE",strTemp);

%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">
	<%if(WI.getStrValue(strSYTo,"").length()>0){%>
		<input type="image" src="../../../../images/form_proceed.gif" onClick="GoNextPage();">
		<%}%></td>
      <td height="25">&nbsp;</td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="changeProgram" value="0">
  <input type="hidden" name="cname">
  <input type="hidden" name="mname">
  <input type="hidden" name="ci">
  <input type="hidden" name="mi">
  <input type="hidden" name="degree_type" value="<%=strTemp%>">
  <input type="hidden" name="goNextPage">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
