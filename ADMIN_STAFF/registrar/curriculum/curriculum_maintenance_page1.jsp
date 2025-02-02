<%@ page language="java" import="utility.*,enrollment.CurriculumCourse,java.util.Vector, java.util.Date" %>
<%
	WebInterface WI = new WebInterface(request);
	String strTemp = null;

strTemp = WI.fillTextValue("goNextPage");
if(strTemp.compareTo("1") ==0){
//forward page here,
strTemp = WI.fillTextValue("degree_type");
	if(strTemp.compareTo("0") ==0){strTemp = null;%>
		<jsp:forward page="./curriculum_maintenance.jsp" />
	<%}else if(strTemp.compareTo("1") ==0){strTemp = null;%>
		<jsp:forward page="./curriculum_maintenance_m_d.jsp" />
	<%}else if(strTemp.compareTo("2") ==0){strTemp = null;//System.out.println("forwarding to Medicine");%>
		<jsp:forward page="./curriculum_maintenance_medicine.jsp" />
	<%}else if(strTemp.compareTo("3") ==0){strTemp = null;//page forward changed from curriculum_maintenance_proper.jsps%>
		<jsp:forward page="./curriculum_maintenance.jsp" />
	<%}else if(strTemp.compareTo("4") ==0){strTemp = null;%>
		<jsp:forward page="./curriculum_maintenance_nosem.jsp" />
	<%}
	else strTemp = "Course curriculum format not found. Please check course offered list for detail.";
}
else if(strTemp.equals("2")) {%>
		<jsp:forward page="./curriculum_maintenance_subj_group_wnu.jsp" />
<%}
else
	strTemp = null;
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function GoNextPage()
{
	document.cmaintenance.goNextPage.value="1";
	document.cmaintenance.course_name.value = document.cmaintenance.course_index[document.cmaintenance.course_index.selectedIndex].text;
	if(document.cmaintenance.major_index.selectedIndex>0)
		document.cmaintenance.major_name.value = document.cmaintenance.major_index[document.cmaintenance.major_index.selectedIndex].text;
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
function GoToOtherFormat()
{
	document.cmaintenance.goNextPage.value="2";
	document.cmaintenance.submit();
}

</script>
<body bgcolor="#D2AE72">
<%

	DBOperation dbOP = null;
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

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";
%>
<form name="cmaintenance">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          COURSES CURRICULUM MAINTENANCE ::::</strong></font></div></td>
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
      <td colspan="2" height="25"> <select name="course_index" onChange="ReloadPage();">
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
      <td colspan="2" height="25"> <select name="major_index">
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
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <%
//show this only if course/major is selected properly.
if(WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("course_index").compareTo("0") != 0 &&
	WI.fillTextValue("changeProgram").compareTo("1") != 0 ){
strTemp = " and is_del=0 and is_valid=1";
strTemp = dbOP.mapOneToOther("COURSE_OFFERED","course_index", request.getParameter("course_index"),"DEGREE_TYPE",strTemp);

%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><input type="image" src="../../../images/form_proceed.gif" onClick="GoNextPage();"></td>
      <td><%if(strSchCode.startsWith("WNU")){%>
	  <a href="javascript:GoToOtherFormat()">
	  	Go To Format with Subject Group
	  </a><%}%>
	  </td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="changeProgram" value="0">
  <input type="hidden" name="course_name">
  <input type="hidden" name="major_name">
  <input type="hidden" name="degree_type" value="<%=strTemp%>">
  <input type="hidden" name="goNextPage">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
