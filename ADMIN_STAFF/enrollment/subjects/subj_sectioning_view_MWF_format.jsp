<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>

<script language="JavaScript">
function GoBack()
{
	var strMajorIndCon = document.ssview.major_index.value;
	if(strMajorIndCon.length ==0)
		strMajorIndCon = "";
	else
		strMajorIndCon = "&major_nidex="+strMajorIndCon;

	location = "./subj_sectioning.jsp?course_index="+document.ssview.course_index.value+strMajorIndCon+
		"&sy_from="+document.ssview.sy_from.value+"&sy_to="+document.ssview.sy_to.value+
		"&school_year_fr="+document.ssview.school_year_fr.value+"&school_year_to="+document.ssview.school_year_to.value+
		"&offering_sem="+document.ssview.offering_sem.value+"&year="+document.ssview.year.value+"&semester="+document.ssview.semester.value+
		"&prep_prop_stat="+document.ssview.prep_prop_stat.value+"&res_offering="+document.ssview.res_offering.value;

}
function PrintPg()
{
var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
	{
	var strViewOneSection = document.ssview.print_section.value;
	if(strViewOneSection.length > 0) 
		strViewOneSection = "&print_section="+escape(strViewOneSection);

		var pgLoc = "./subj_sectioning_print_MWF_format.jsp?course_index="+document.ssview.course_index.value+"&major_index="+
				document.ssview.major_index.value+"&sy_from="+document.ssview.sy_from.value+"&sy_to="+
				document.ssview.sy_to.value+"&year="+document.ssview.year.value+"&semester="+document.ssview.semester.value+"&school_year_fr="+
				document.ssview.school_year_fr.value+"&school_year_to="+
				document.ssview.school_year_to.value+"&offering_sem="+document.ssview.offering_sem.value+
				"&prep_prop_stat="+document.ssview.prep_prop_stat.value+"&degreeType="+document.ssview.degreeType.value+
				"&res_offering="+document.ssview.res_offering.value+strViewOneSection;

		var win=window.open(pgLoc,"PrintWindow",'width=700,height=600,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
function DeleteMWF(strSubSecIndex)
{
	document.ssview.info_index.value=strSubSecIndex;
	document.ssview.deleteMWF.value="1";
	document.ssview.submit();
}
</script>



<body bgcolor="#D2AE72">
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

	String[] strConvertYear = {"1st","2nd","3rd","4th","5th","6th","7th","8th","9th"};
	String[] strConvertWeek = {"Sun ","M","T","W","TH","F","Sat"};
	String[] strConvertAMPM = {"AM","PM"};
	String[] strConvertSem  = {"Summer","1st Term", "2nd Term", "3rd Term", "4th Term", "5th Term"};
	String[] astrPrepProp   = {""," (Preparatory)"," (Proper)"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-subject sectioning view MWF format","subj_sectioning_view_MWF_format.jsp");
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
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														"subj_sectioning_view_MWF_format.jsp");
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
SubjectSection SS = new SubjectSection();

Vector vSubSectionDetail = new Vector();
Vector vRoomDetail = new Vector();

if(WI.fillTextValue("deleteMWF").compareTo("1") ==0)
{
	if(SS.delRoomScheduleMWF(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")) )
		strErrMsg = "Section sechedule deleted successfully.";
	else
		strErrMsg = SS.getErrMsg();
}

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

<form name="ssview" action="./subj_sectioning_view_MWF_format.jsp" method="post">
	<input type="hidden" name="course_index" value="<%=request.getParameter("course_index")%>">
	<input type="hidden" name="major_index" value="<%=request.getParameter("major_index")%>">
	<input type="hidden" name="sy_from" value="<%=request.getParameter("sy_from")%>">
	<input type="hidden" name="sy_to" value="<%=request.getParameter("sy_to")%>">
	<input type="hidden" name="year" value="<%=WI.fillTextValue("year")%>">
	<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">
	<input type="hidden" name="prep_prop_stat" value="<%=WI.fillTextValue("prep_prop_stat")%>">
	<input type="hidden" name="school_year_fr" value="<%=WI.fillTextValue("school_year_fr")%>">
	<input type="hidden" name="school_year_to" value="<%=WI.fillTextValue("school_year_to")%>">
	<input type="hidden" name="offering_sem" value="<%=WI.fillTextValue("offering_sem")%>">
	<input type="hidden" name="degreeType" value="<%=WI.fillTextValue("degreeType")%>">
	<input type="hidden" name="res_offering" value="<%=WI.fillTextValue("res_offering")%>">

<input type="hidden" name="print_section" value="<%=WI.fillTextValue("print_section")%>">


  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          CLASS PROGRAMS PAGE - VIEW IN MTWTHFS FORMAT::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><a href="javascript:GoBack();" target="_self"><img src="../../../images/go_back.gif" border="0"></a>
        &nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font>
      </td>
    </tr>
    <%
if(vSubSectionDetail == null || vSubSectionDetail.size() == 0)
{
strTemp = SS.getErrMsg();
if(strTemp == null || strTemp.trim().length() ==0) strTemp = "No Information found.";

%>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="3"><strong><%=strTemp%> </strong></td>
    </tr>
    <%
dbOP.cleanUP();
return;
}  %>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="2"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Offerings
        for course : <strong><%=
	  WI.getStrValue(dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX", request.getParameter("course_index"),"COURSE_NAME", null),"For all course")%></strong></font></td>
      <td width="43%">
        <%
strTemp = request.getParameter("major_index");
if(strTemp != null && strTemp.trim().length() > 0)
{
	strTemp = dbOP.mapOneToOther("MAJOR","MAJOR_INDEX", request.getParameter("major_index"),"MAJOR_NAME",null);
%>
        Major : <strong><%=strTemp%></strong>
        <%}%>
      </td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="3"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">
        <%//System.out.println(WI.fillTextValue("year"));
	  if(WI.fillTextValue("year").length() > 0){%>
        Year/Term :<strong><%=strConvertYear[Integer.parseInt(request.getParameter("year")) - 1]%>/<%=strConvertSem[Integer.parseInt(request.getParameter("semester"))]%>
        <%=astrPrepProp[Integer.parseInt(WI.getStrValue(request.getParameter("prep_prop_stat"),"0"))]%></strong></font>
        <%}%>
        <font size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp; </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="36%"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">School
        Year: <strong><%=request.getParameter("school_year_fr")%> - <%=request.getParameter("school_year_to")%>
        </strong> </font>
      </td>
      <td colspan="2"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Offering
        Term: <strong><%=strConvertSem[Integer.parseInt(request.getParameter("offering_sem"))]%></strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="5"><div align="center">LIST
          OF SUBJECT SCHEDULE<br>
          </div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="3%" height="25"><div align="right"> </div></td>
      <td width="60%" height="25"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>
        <font size="1">click to print subject offerings </font> </td>
      <td width="25%" height="25">&nbsp;</td>
      <td width="8%" height="25">&nbsp;</td>
      <td width="4%" height="25">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="23%" height="25" align="center"><font size="1"><strong>SUBJECT CODE </strong></font></td>
      <td width="22%" align="center"><font size="1"><strong>SECTION</strong></font></td>
      <td width="18%" align="center"><font size="1"><strong>ROOM #</strong></font></td>
      <td width="30%" align="center"><font size="1"><strong>SCHEDULE(Days/Time)</strong></font></td>
<%if(bolIsHTC) {%>
     <td width="7%" align="center"><font size="1"><strong>TERM TYPE</strong></font></td>
<%}%>
      <td width="7%" align="center"><font size="1"><strong>DELETE</strong></font></td>
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
		bolErrorInProcess = true;//System.out.println(SS.getErrMsg());
		break; //break the loop
	}
%>
    <tr>
      <td height="25"><%=strSubCodeToDisp%></td>
      <td><%=strSection%></td>
      <td><%=WI.getStrValue(vRoomDetail.elementAt(1),"Not Assigned")%></td>
      <td><%=WI.getStrValue(vSubSectionDetail.elementAt(i+3),"")%> <!--Offering duration -->
	  <%=(String)vRoomDetail.elementAt(2)%></td>
<%if(bolIsHTC) {
iIndexOf = vHTCTermType.indexOf(vSubSectionDetail.elementAt(i));
if(iIndexOf == -1)
	strTemp = "ALL";
else {
	strTemp = (String)vHTCTermType.elementAt(iIndexOf + 1);
	
	//vHTCTermType.remove(iIndexOf);vHTCTermType.remove(iIndexOf);
}%>
      <td style="font-size:11px; font-weight:bold"><%=strTemp%></td>
<%}%>
      <td align="center">
	  <%
	  if(iAccessLevel ==2){%>
	  <a href='javascript:DeleteMWF("<%=(String)vSubSectionDetail.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
	  <%}else{%>NA<%}%>	  </td>
    </tr>
    <%
for(int j=3;j<vRoomDetail.size()-2;){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><%=WI.getStrValue(vRoomDetail.elementAt(j+1),"Not Assigned")%></td>
      <td><%=(String)vRoomDetail.elementAt(j+2)%></td>
<%if(bolIsHTC) {%>
      <td align="center">&nbsp;</td>
<%}%>
      <td align="center">&nbsp;</td>
    </tr>
    <%
	j = j+3;
	}
i = i+6;
}

if(bolErrorInProcess)
{%>
    <tr>
      <td colspan="<%if(bolIsHTC) {%>8<%}else{%>7<%}%>"><strong>Error in getting Room infomration for section : <%=strSection%></strong></td>
    </tr>
    <%}%>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="deleteMWF">
<input type="hidden" name="info_index">
</form>
</body>
</html>

<%dbOP.cleanUP();%>
