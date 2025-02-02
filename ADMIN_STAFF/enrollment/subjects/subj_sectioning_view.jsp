<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
-->
</style></head>

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
		"&school_year_fr="+document.ssview.school_year_fr.value+"&school_year_to="+
		document.ssview.school_year_to.value+"&offering_sem="+document.ssview.offering_sem.value+"&year="+document.ssview.year.value+"&semester="+document.ssview.semester.value+
		"&prep_prop_stat="+document.ssview.prep_prop_stat.value+"&res_offering="+document.ssview.res_offering.value;
}
function DeleteRecord(strInfoIndex)
{
	document.ssview.deleteRecord.value = 1;
	document.ssview.info_index.value = strInfoIndex;
}
function ViewMTWTHFSFormat()
{
	var strViewOneSection = document.ssview.print_section.value;
	if(strViewOneSection.length > 0) 
		strViewOneSection = "&print_section="+escape(strViewOneSection);
	location = "./subj_sectioning_view_MWF_format.jsp?course_index="+document.ssview.course_index.value+"&major_index="+
		document.ssview.major_index.value+"&sy_from="+document.ssview.sy_from.value+"&sy_to="+
		document.ssview.sy_to.value+"&year="+document.ssview.year.value+"&semester="+document.ssview.semester.value+"&school_year_fr="+
			document.ssview.school_year_fr.value+"&school_year_to="+
			document.ssview.school_year_to.value+"&offering_sem="+document.ssview.offering_sem.value+
			"&prep_prop_stat="+document.ssview.prep_prop_stat.value+"&degreeType="+document.ssview.degreeType.value+"&res_offering="+
			document.ssview.res_offering.value+strViewOneSection;
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
</script>



<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.SubjectSection,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	Vector vTemp = null;

	String[] strConvertYear = {"1st year","2nd year","3rd year","4th year","5th year","6th year","7th year","8th year","9th year"};
	String[] strConvertWeek = {"Sun","Mon","Tues","Wed","Thurs","Fri","Sat"};
	String[] strConvertAMPM = {"AM","PM"};
	String[] strConvertSem  = {"Summer","1st Term", "2nd Term", "3rd Term", "4th Term", "5th Term"};
	String[] astrPrepProp   = {""," (Preparatory)"," (Proper)"};


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-subject sectioning view","subj_sectioning_view.jsp");
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
														"subj_sectioning_view.jsp");
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
//if delete is clicked -- delete record before displaying.
strTemp = request.getParameter("deleteRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	if(SS.delRoomSchedule(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
	{
		strErrMsg = "Time Schedule deleted successfully.";
	}
	else
	{
		dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=SS.getErrMsg()%></font></p>
		<%
		return;
	}
}


Vector vSubSectionDetail = new Vector();
Vector vRoomDetail = new Vector();

vSubSectionDetail = SS.getSectionScheduleDetail(dbOP,request);
//CHECK THIS JUST ABOVE THE COURSE OFFERED :-

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

<form name="ssview" action="./subj_sectioning_view.jsp" method="post">


  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          CLASS PROGRAMS PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="35%" height="25"><a href="javascript:GoBack();" target="_self"><img src="../../../images/go_back.gif" border="0"></a></td>
      <td width="18%" height="25">&nbsp;</td>
      <td width="46%" height="25">&nbsp;</td>
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
}else{

//this shows if information is deleted successfully.
if(strErrMsg != null)
{
%>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="3"><strong><%=strErrMsg%></strong></td>
    </tr>
    <%}%>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="2">Offerings for course: <strong><%=
	  WI.getStrValue(dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX", request.getParameter("course_index"),"COURSE_NAME", null),"For all course")%></strong></td>
      <td>
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
      <td>
        <%
	  if(WI.fillTextValue("year").length() > 0){%>
        Year/Term :<strong><%=strConvertYear[Integer.parseInt(request.getParameter("year")) - 1]%>/<%=strConvertSem[Integer.parseInt(request.getParameter("semester"))]%>
        <%=astrPrepProp[Integer.parseInt(WI.getStrValue(request.getParameter("prep_prop_stat"),"0"))]%></strong>
      </td>
      <td colspan="2">&nbsp; </td>
      <%}%>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>School Year: <strong><%=request.getParameter("school_year_fr")%> - <%=request.getParameter("school_year_to")%>
        </strong></td>
      <td colspan="2">Offering Term: <strong><%=strConvertSem[Integer.parseInt(request.getParameter("offering_sem"))]%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3"><a href="javascript:ViewMTWTHFSFormat();"><img src="../../../images/view.gif" border="0"></a><font size="1">click
        to view in MTWTHFS Format</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td height="36" colspan="5"><div align="center">LIST
          OF SUBJECT SCHEDULE<br>
          <font size="1">(Pls click<strong> EDIT/DELETE</strong> subjects schedule)</font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="1%" height="28"><div align="right"> </div></td>
      <td width="62%" height="28"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>
        <font size="1">click to print class program</font></td>
      <td width="25%" height="28">&nbsp;</td>
      <td width="8%" height="28">&nbsp;</td>
      <td width="4%" height="28">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="40%" height="25" align="center"><font size="1"><strong>SUBJECT CODE </strong></font></td>
      <td width="12%" align="center"><font size="1"><strong>SECTION</strong></font></td>
      <td width="15%" align="center"><font size="1"><strong>ROOM #</strong></font></td>
      <td width="20%" align="center"><font size="1"><strong>SCHEDULE(Days/Time)</strong></font></td>
      <td width="6%" align="center"><font size="1"><strong>DO NOT CHK CONFLICT</strong></font></td>
<%if(bolIsHTC) {%>
      <td width="6%" align="center"><font size="1"><strong>TERM TYPE</strong></font></td>
<%}%>
      <td width="6%" align="center"><font size="1"><b>DELETE</b></font></td>
    </tr>
    <%
boolean bolErrorInProcess = false;
for(int i = 0, iRAssinIndex=0; i< vSubSectionDetail.size(); ++i, ++iRAssinIndex)
{
		vRoomDetail = SS.getRoomScheduleDetail(dbOP,request,(String)vSubSectionDetail.elementAt(i));
		if(vRoomDetail == null)
		{
			bolErrorInProcess = true;
			i = vSubSectionDetail.size();
			continue; //break the loop
		}

		for(int j=0; j< vRoomDetail.size(); ++j)
		{
			//displaying the room schedle in Mon - 11:00AM to 12:00PM FORMAT. ---- if schedule is for lab -- display LAB.
			if( ((String)vSubSectionDetail.elementAt(i+4)).compareTo("1") ==0)
				strTemp = "(Lab Sched)";
			else strTemp = "";

		%>
    <tr> 
      <td height="25"><%=(String)vSubSectionDetail.elementAt(i+1)%><%=strTemp%></td>
      <td><%=(String)vSubSectionDetail.elementAt(i+2)%></td>
      <td><%=WI.getStrValue(vRoomDetail.elementAt(j+8),"Not Assigned")%></td>
      <td><%=WI.getStrValue(vSubSectionDetail.elementAt(i+3),"")%> <%=strConvertWeek[Integer.parseInt((String)vRoomDetail.elementAt(j+1))]%> - <%=(String)vRoomDetail.elementAt(j+2)%>:<%=(String)vRoomDetail.elementAt(j+3)%> <%=strConvertAMPM[Integer.parseInt((String)vRoomDetail.elementAt(j+4))]%> to <%=(String)vRoomDetail.elementAt(j+5)%>:<%=(String)vRoomDetail.elementAt(j+6)%> <%=strConvertAMPM[Integer.parseInt((String)vRoomDetail.elementAt(j+7))]%> </td>
      <td>&nbsp;</td>
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
      <td> <%if(iAccessLevel ==2){%> <input type="image" src="../../../images/delete.gif" onClick='DeleteRecord("<%=(String)vRoomDetail.elementAt(j)%>")'> 
        <input type="hidden" name="r_assign<%=iRAssinIndex++%>" value="<%=(String)vRoomDetail.elementAt(j)%>"> 
        <%}else{%>
        NA 
        <%}%> </td>
    </tr>
    <%	j = j+8;
	}//end of displaying room sechedule detail.

i = i +6;
}

if(bolErrorInProcess)
{%>
    <tr> 
      <td colspan="8"><strong><%=strTemp%></strong></td>
    </tr>
    <%}

}//only if vSubSectionDetail != null - this is the outer loop.
%>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
 <!-- all hidden fields go here -->
<%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="course_index" value="<%=WI.fillTextValue("course_index")%>">
<input type="hidden" name="major_index" value="<%=WI.fillTextValue("major_index")%>">
<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
<input type="hidden" name="year" value="<%=WI.fillTextValue("year")%>">
<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">
<input type="hidden" name="school_year_fr" value="<%=WI.fillTextValue("school_year_fr")%>">
<input type="hidden" name="school_year_to" value="<%=WI.fillTextValue("school_year_to")%>">
<input type="hidden" name="offering_sem" value="<%=WI.fillTextValue("offering_sem")%>">
<input type="hidden" name="prep_prop_stat" value="<%=WI.fillTextValue("prep_prop_stat")%>">
<input type="hidden" name="degreeType" value="<%=WI.fillTextValue("degreeType")%>">
<input type="hidden" name="res_offering" value="<%=WI.fillTextValue("res_offering")%>">

<input type="hidden" name="print_section" value="<%=WI.fillTextValue("print_section")%>">
</form>
</body>
</html>

<%dbOP.cleanUP();%>
