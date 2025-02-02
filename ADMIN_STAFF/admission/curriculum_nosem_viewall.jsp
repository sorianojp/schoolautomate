<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript">
function PrintPage()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
		return true;
	return false;
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumMaintenance,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	WebInterface WI = new WebInterface(request);

	String strCourseIndex 	= WI.fillTextValue("course_index");
	String strCourseName 	= request.getParameter("cname");
	String strSYFrom 		= WI.fillTextValue("cy_from");
	String strSYTo 			= WI.fillTextValue("cy_to");
	if(strCourseIndex.length() ==0)
		strCourseIndex = WI.fillTextValue("ci");
	if(strSYFrom.length() ==0)
		strSYFrom = WI.fillTextValue("syf");
	if(strSYTo.length() ==0)
		strSYTo = WI.fillTextValue("syt");
	float fLecHrs = 0; float fLabHrs=0;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Courses Curriculum","curriculum_nosem_viewall.jsp");
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
														"curriculum_nosem_viewall.jsp");
iAccessLevel = 2;//Switch off security, i do not need security as this is a view page only.
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
	strErrMsg = "Can't process curriculum detail. couse, SY From , SY To information missing.";
	dbOP.cleanUP();
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=strErrMsg%></font></p>
	<%
	return;
}
vRetResult = CM.operateOnCurWithNoSem(dbOP, request,3);
dbOP.cleanUP();

if(vRetResult == null || vRetResult.size() ==0)
{
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=CM.getErrMsg()%></font></p>
	<%
	return;
}
%>
<form action="./curriculum_nosem_viewall_print.jsp" method="post" target="_blank" onSubmit="return PrintPage();">
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" ><div align="center"><font color="#FFFFFF"><strong>::::
          COURSES CURRICULUM ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><a href="javascript:history.back()" target="_self"> <img src="../../images/go_back.gif" width="50" height="27" border="0"></a></td>
      <td width="23%" height="25">&nbsp;</td>
      <td width="27%" height="25"><div align="right">
          <input type="image" src="../../images/print.gif" width="58" height="26">
          <font size="1">click to print curriculum</font></div></td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="49%" valign="middle">Course: <strong><%=strCourseName%></strong></td>
      <td  colspan="2" valign="middle">
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Curriculum Year :<strong> <%=strSYFrom%> - <%=strSYTo%></strong></td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" bgcolor="#FFFFFF">
    <%
if(vRetResult != null && vRetResult.size() > 0){%>
    <tr>
      <td width="2%" rowspan="2">&nbsp;</td>
      <td  height="19" rowspan="2"><div align="left"><font size="1"><strong>SUBJECT
          CODE</strong></font></div></td>
      <td rowspan="2"><div align="left"><font size="1"><strong>SUBJECT TITLE </strong></font></div></td>
      <td colspan="2"><div align="center"><font size="1"><strong>HOURS</strong></font></div></td>
      <td rowspan="2"><div align="center"><font size="1"><strong>TOTAL</strong></font></div></td>
    </tr>
    <tr>
      <td width="6%"><div align="center"><font size="1"><strong>LEC.</strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>LAB.</strong></font></div></td>
    </tr>
<%
String strCurIndex = null;
float fLecHrsTemp = 0;
float fLabHrsTemp = 0;
int i=0;

Vector vCurSubInfo = (Vector)vRetResult.remove(0);
for(i = 0; i< vRetResult.size();){
if( ((String)vRetResult.elementAt(i+5)).compareTo("1") ==0)// optional
	break;
if(vCurSubInfo.size() > 0)
	strCurIndex = (String)vRetResult.elementAt(i);
fLecHrsTemp = Float.parseFloat((String)vRetResult.elementAt(i+3));
fLabHrsTemp = Float.parseFloat((String)vRetResult.elementAt(i+4));

fLecHrs += fLecHrsTemp;
fLabHrs += fLabHrsTemp;
%>

    <tr>
      <td>&nbsp;</td>
      <td width="27%"  height="19"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td width="38%"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+3))%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+4))%></td>
      <td width="20%" align="center"><%=(fLecHrsTemp+fLabHrsTemp)%></td>
    </tr>
<%
i = i+6;

	while(vCurSubInfo.size() > 0){
	if( ((String)vCurSubInfo.elementAt(0)).compareTo(strCurIndex) !=0)
		break;

	fLecHrsTemp = Float.parseFloat((String)vCurSubInfo.elementAt(3));
	fLabHrsTemp = Float.parseFloat((String)vCurSubInfo.elementAt(4));

	%>
		 <tr>
		  <td>&nbsp;</td>
		  <td width="27%"  height="19"></td>
		  <td width="38%"> &nbsp;&nbsp;* <%=(String)vCurSubInfo.elementAt(2)%></td>
		  <td align="center">(<%=WI.getStrValue(vCurSubInfo.elementAt(3))%>)</td>
		  <td align="center">(<%=WI.getStrValue(vCurSubInfo.elementAt(4))%>)</td>
		  <td width="20%" align="center">(<%=(fLecHrsTemp+fLabHrsTemp)%>)</td>
		</tr>
	<%
	vCurSubInfo.removeElementAt(0);	vCurSubInfo.removeElementAt(0);
	vCurSubInfo.removeElementAt(0);	vCurSubInfo.removeElementAt(0);
	vCurSubInfo.removeElementAt(0);
	}
}%>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td colspan="6" align="center"><em><strong>Total hours : <%=(fLecHrs+fLabHrs)%>
        ,Lecture hours = <%=fLecHrs%>, Lab hours=<%=fLabHrs%></strong></em></td>
    </tr>
    <tr>
      <td height="22" colspan="6">&nbsp;</td>
    </tr>
<%
if(i<vRetResult.size()){//optional%>
	 <tr>
      <td height="22" colspan="6" align="center"><strong>OPTIONAL</strong></td>
    </tr>
<%
for(;i<vRetResult.size();++i){
fLecHrsTemp = Float.parseFloat((String)vRetResult.elementAt(i+3));
fLabHrsTemp = Float.parseFloat((String)vRetResult.elementAt(i+4));
%>

        <tr>
      <td>&nbsp;</td>
      <td width="27%"  height="19"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td width="38%"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+3))%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+4))%></td>
      <td width="20%" align="center"><%=(fLecHrsTemp+fLabHrsTemp)%></td>
    </tr>
<%
	i = i+5;
	}
}%>

  </table>
<%}%>
<table bgcolor="#FFFFFF" width="100%">
    <tr>
      <td colspan="5">&nbsp;</td>
    </tr>
  </table>


<table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="14%" height="25">&nbsp;</td>
    <td width="86%" height="25"><input type="image" src="../../images/print.gif" width="58" height="26"><font size="1">click
      to print curriculum</font></td>
  </tr>
  <tr>
    <td colspan="2"><div align="center"> </div></td>
  </tr>
  <tr>
    <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="course_index" value="<%=strCourseIndex%>">
<input type="hidden" name="cname" value="<%=request.getParameter("cname")%>">
<input type="hidden" name="cy_from" value="<%=strSYFrom%>">
<input type="hidden" name="cy_to" value="<%=strSYTo%>">
</form>

</body>
</html>
