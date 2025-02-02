<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();

	String strCourseIndex 	= request.getParameter("ci");
	String strCourseName 	= request.getParameter("cname");
	String strMajorIndex 	= request.getParameter("mi");
	String strMajorName 	= request.getParameter("mname");
	if(strMajorName == null) strMajorName = "None";
	String strSYFrom 		= request.getParameter("syf");
	String strSYTo 			= request.getParameter("syt");

	float iNoOfLECUnitPerSem = 0f; float iNoOfLABUnitPerSem = 0f;
	float iNoOfLECUnitPerCourse = 0f;float iNoOfLABUnitPerCourse = 0f;
	
	double dNoOfLECHrPerSem = 0d;
	double dNoOfLABHrPerSem = 0d;

	WebInterface WI = new WebInterface(request);
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Courses curriculum - proper view","curriculum_maintenance_proper_viewall.jsp");
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
														"Registrar Management","CURRICULUM",request.getRemoteAddr(),
														"curriculum_maintenance_proper_viewall.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
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
vRetResult = CM.getPREPCurDetail(dbOP, strCourseIndex,strMajorIndex, strSYFrom,strSYTo);
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
<form action="./curriculum_maintenance_proper_viewall_print.jsp" method="post" target="_blank" onSubmit="return PrintPage();">
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" ><div align="center"><font color="#FFFFFF"><strong>::::
          COURSES CURRICULUM MAINTENANCE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><a href="javascript:history.back()" target="_self"> <img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></td>
      <td width="23%" height="25">&nbsp;</td>
      <td width="27%" height="25"><div align="right">
          <input type="image" src="../../../images/print.gif" width="58" height="26">
          <font size="1">click to print curriculum</font></div></td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="49%" valign="middle">Course: <strong><%=strCourseName%></strong></td>
      <td  colspan="2" valign="middle">
	  <%
	  if(strMajorName.compareTo("None") != 0){%>
	  Major: <strong><%=strMajorName%></strong><%}%></td>
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
String[] astrConvertToYr={"","First Year","Second Year","Third Year","Fourth Year","Fifth Year","Sixth Year","Seventh Year"};
String[] astrConvertToSem={"Summer","First Semester","Second Semester","Third Semester","Fourth Semester"};
String[] astrConvertToProper = {"","Preparatory","Proper"};

int iYear = 0;
int iSem  = 0;
int iPrep = 0;
for( int i = 0; i< vRetResult.size();) //preparatory subjects.
{
iYear = Integer.parseInt((String)vRetResult.elementAt(i+1));
iSem  = Integer.parseInt((String)vRetResult.elementAt(i+2));
iPrep = Integer.parseInt((String)vRetResult.elementAt(i+9));
%>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="7"><div align="center"><strong><%=astrConvertToYr[iYear]%> (<%=astrConvertToProper[iPrep]%>)</strong></div></td>
    </tr>
    <%
	for(int j= i; j<vRetResult.size();)
	{
		if( iYear != Integer.parseInt((String)vRetResult.elementAt(j+1)) || iPrep != Integer.parseInt((String)vRetResult.elementAt(i+9)))
			break;
		iSem  = Integer.parseInt((String)vRetResult.elementAt(j+2));
	%>
    <tr> 
      <td width="1%">&nbsp;</td>
      <td colspan="7"><strong><u><%=astrConvertToSem[iSem]%></u></strong></td>
    </tr>
    <%
		for(int k= i ; k< vRetResult.size();)
		{
			if(iSem != Integer.parseInt((String)vRetResult.elementAt(k+2)))
				break;

			//display the heading only once.
			if(k==0)
			{%>
    <tr> 
      <td rowspan="2">&nbsp;</td>
      <td  height="19" rowspan="2"><div align="left"><font size="1"><strong>SUBJECT 
          CODE</strong></font></div></td>
      <td rowspan="2"><div align="left"><font size="1"><strong>SUBJECT NAME/DESCRIPTION</strong></strong></font></div></td>
      <td colspan="2"><div align="center"><font size="1"><strong>HOURS</strong></font></div></td>
      <td colspan="2"><div align="center"><font size="1"><strong>UNITS</strong></font></div></td>
      <td rowspan="2"><div align="left"><font size="1"><strong>PRE-REQUISITE</strong></font></div></td>
    </tr>
    <tr> 
      <td width="7%"><div align="center"><font size="1"><strong>LEC.</strong></font></div></td>
      <td width="8%"><div align="center"><font size="1"><strong>LAB.</strong></font></div></td>
      <td width="5%"><div align="center"><font size="1"><strong>LEC.</strong></font></div></td>
      <td width="6%"><div align="center"><font size="1"><strong>LAB.</strong></font></div></td>
    </tr>
    <%}%>
    <tr> 
      <td>&nbsp;</td>
      <td width="18%"  height="19"><%=(String)vRetResult.elementAt(k+3)%></td>
      <td width="39%"><%=(String)vRetResult.elementAt(k+4)%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(k+7))%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(k+8))%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(k+5))%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(k+6))%></td>
      <td width="16%" align="center"><%=WI.getStrValue(vRetResult.elementAt(k+10))%></td>
    </tr>
    <%
					iNoOfLECUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+5));
					iNoOfLABUnitPerSem += Float.parseFloat((String)vRetResult.elementAt(k+6));
			
					dNoOfLECHrPerSem += Double.parseDouble((String)vRetResult.elementAt(k+7));
					dNoOfLABHrPerSem += Double.parseDouble((String)vRetResult.elementAt(k+8));

					k = k+11;
					j = k;
					i = j;
			}%>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td> <%
      if( i > vRetResult.size() -2){%>
        COMPREHENSIVE EXAM. 
        <%}%> <div align="right"><strong><font size="1">TOTAL</font></strong></div></td>
      <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=dNoOfLECHrPerSem%></strong></font></div></td>
      <td class="thinborderTOP"><div align="center"><font size="1"><strong><%=dNoOfLABHrPerSem%></strong></font></div></td>
      <td class="thinborderTOP"><div align="center"><strong><%=iNoOfLECUnitPerSem%></strong></div></td>
      <td class="thinborderTOP"><div align="center"><strong><%=iNoOfLABUnitPerSem%></strong></div></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="8" align="center"><font size="1"><strong>TOTAL ACADEMIC UNIT(S): 
        <%=(iNoOfLECUnitPerSem+iNoOfLABUnitPerSem)%></strong></font></td>
    </tr>
    <tr> 
      <td height="22" colspan="8">&nbsp;</td>
    </tr>
    <%
	iNoOfLECUnitPerCourse += iNoOfLECUnitPerSem;
	iNoOfLABUnitPerCourse += iNoOfLABUnitPerSem;

	iNoOfLECUnitPerSem = 0;
	iNoOfLABUnitPerSem = 0; dNoOfLABHrPerSem = 0d; dNoOfLECHrPerSem = 0d;
	}//end of loop for semesters



}//end of loop for year.
%>
  </table>

<table bgcolor="#FFFFFF" width="100%">


    <tr>
      <td colspan="5">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="5"><font size="2"><strong>Total academic units for course <%=strCourseName%>: <u><%=iNoOfLECUnitPerCourse+iNoOfLABUnitPerCourse%> ,Lecture Unit = <%=iNoOfLECUnitPerCourse%>, Lab Unit=<%=iNoOfLABUnitPerCourse%></u></strong></font></td>
    </tr>
    <tr>
      <td colspan="5">&nbsp;</td>
    </tr>
  </table>


<table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="14%" height="25">&nbsp;</td>
    <td width="86%" height="25"><input type="image" src="../../../images/print.gif" width="58" height="26"><font size="1">click
      to print curriculum</font></td>
  </tr>
  <tr>
    <td colspan="2"><div align="center"> </div></td>
  </tr>
  <tr>
    <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="ci" value="<%=request.getParameter("ci")%>">
<input type="hidden" name="cname" value="<%=request.getParameter("cname")%>">
<input type="hidden" name="mname" value="<%=WI.fillTextValue("mname")%>">

<%
strTemp = request.getParameter("mi");
if(strTemp == null) strTemp = "";
%>
<input type="hidden" name="mi" value="<%=strTemp%>">
<input type="hidden" name="syf" value="<%=request.getParameter("syf")%>">
<input type="hidden" name="syt" value="<%=request.getParameter("syt")%>">
</form>

</body>
</html>
