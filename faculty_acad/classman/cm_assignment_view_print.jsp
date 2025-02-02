<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMAssignment" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolProceed = true;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-Class Management-Assignments/Homeworks","cm_assignment_view.jsp");

	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Faculty/Acad. Admin","CLASS MANAGEMENT",request.getRemoteAddr(), 
														"cm_assignment_view.jsp");	
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
	String strEmployeeID = (String)request.getSession(false).getAttribute("userId");
	String strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);
	String strSubSecIndex   = null;
	enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
	Vector vRetResult = null;
	Vector vSecDetail  = null;
	Vector vEditInfo = null;
	String strPageAction = WI.fillTextValue("page_action");

	String strSemester = WI.fillTextValue("offering_sem");
	String strSYFrom = WI.fillTextValue("sy_from");
	String strSYTo = WI.fillTextValue("sy_to");

if(strSemester.length() ==0)
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");
if(strSYFrom.length() ==0)
		strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strSYTo.length() ==0)
	strSYTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to");

if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
	strSubSecIndex = dbOP.mapOneToOther("E_SUB_SECTION join faculty_load on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
		"section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index", 
		" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+
		" and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
		strSYFrom +" and e_sub_section.offering_sy_to = "+ strSYTo+
		" and e_sub_section.offering_sem="+ strSemester +" and is_lec=0");
}

CMAssignment cm = new CMAssignment();

if(strSubSecIndex != null) {//get here subject section detail. 
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();

	if (WI.fillTextValue("copied_fr_index").length() > 0){
		vEditInfo = cm.operateOnAssignment(dbOP,request,3, strSubSecIndex);
		if(vEditInfo == null)
			strErrMsg = cm.getErrMsg();
	}
}

if ( vSecDetail != null && vEditInfo != null){
	vRetResult = cm.operateOnAssignScore(dbOP,request,4);
}


%>
<html>
<head>
<title>Print Assignment Scores</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="window.print()">
<form action="cm_assignment_view.jsp" method="post" name="form_" id="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="1%" height="25" rowspan="3" >&nbsp;</td>
      <td >SY / Term : <strong><%=WI.fillTextValue("sy_from") + " - " + WI.fillTextValue("sy_to")%> / <%=WI.fillTextValue("sem_label")%> </strong></td>
    </tr>
  </table>
  <%
if(strSYFrom.length() > 0 && strSYTo.length() >0){
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="1%"></td>
      <td height="25" colspan="2" >Instructor : <strong> 
        <%if(vSecDetail != null){%>
        <%=WI.getStrValue(vSecDetail.elementAt(0))%> 
        <%}%>
        </strong></td>
    </tr>
    <tr> 
      <td></td>
      <td width="36%" height="25" >Subject : <strong><%=WI.fillTextValue("subj_label")%></strong></td>
      <td width="63%" height="25" > Subject Title :<strong> 
        <% if(WI.fillTextValue("subject").length() > 0) {
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name"," and is_del=0");
%>
        <%}%>
        <strong> <%=WI.getStrValue(strTemp)%></strong> </strong> </td>
    </tr>
    <tr> 
      <td width="1%">s</td>
      <td height="25">Section : <strong><%=WI.fillTextValue("section_name")%></strong> </td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%}if(vSecDetail != null && vEditInfo != null ){%>
  <table width="100%" border="0" cellspacing="1" cellpadding="2" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td width="15%">&nbsp;</td>
      <td width="24%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>ROOM 
          NUMBER</strong></font></div></td>
      <td width="20%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>LOCATION</strong></font></div></td>
      <td width="26%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="15%">&nbsp;</td>
    </tr>
    <%for(int i = 1; i<vSecDetail.size(); i+=3){%>
    <tr> 
      <td>&nbsp;</td>
      <td align="center"><%=(String)vSecDetail.elementAt(i)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+1)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+2)%></td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td>&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<% if (vEditInfo != null) {%>
<table width="100%" border="0" cellpadding="2" cellspacing="0">
  <tr bgcolor="#FFFFFF">
    <td width="6%" align="center">&nbsp;</td>
    <td width="64%" style="font-size:11px; font-weight:bold"><%=(String)vEditInfo.elementAt(2)%></td>
    <td width="12%" style="font-size:10px; color:#FF0000; font-weight:bold">Max Score </td>
    <td width="18%" style="font-size:10px; color:#FF0000; font-weight:bold"><strong><%=(String)vEditInfo.elementAt(10)%></strong></td>
  </tr>
  <input type="hidden" name="max_score" value="<%=vEditInfo.elementAt(10)%>">
  <tr bgcolor="#FFFFFF">
    <td align="center">&nbsp;</td>
    <td style="font-size:11px;">Date Given : <strong><%=WI.formatDate((String)vEditInfo.elementAt(3),6)%></strong></td>
    <td style="font-size:10px; color:#FF0000; font-weight:bold">Due Date </td>
    <td style="font-size:10px; color:#FF0000; font-weight:bold"><%=WI.formatDate((String)vEditInfo.elementAt(4),6)%></td>
  </tr>
  <tr bgcolor="#FFFFFF">
    <td colspan="4" align="center"><hr size="1" noshade></td>
  </tr>
</table>
<% } // if vEditInfo != null
if (vRetResult != null) {
		Vector vRecorded = (Vector)vRetResult.elementAt(0);	
		Vector vUnrecorded = (Vector)vRetResult.elementAt(1);
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td>&nbsp;</td>
      <td height="25" width="60%">TOTAL STUDENTS ENROLLED IN THIS CLASS : <strong><%=Integer.parseInt((String)vRecorded.elementAt(0)) + Integer.parseInt((String)vUnrecorded.elementAt(0))%></strong></td>
      <td width="39%" height="25" align="right" style="font-size:9px;">Date and time printed : <%=WI.getTodaysDateTime()%></td>
    </tr>
</table>
<% 
if (vUnrecorded.size() > 1){
%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="27" colspan="6" align="center" class="thinborder"><strong>STUDENTS 
        WITHOUT SCORE</strong></td>
    </tr>
    <tr> 
      <td width="15%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>STUDENT 
        ID</strong></font></td>
      <td height="27" colspan="3" align="center" class="thinborder"><strong><font size="1">STUDENT 
        NAME</font></strong></td>
      <td width="25%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>COURSE/MAJOR</strong></font></td>
      <td width="5%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>YEAR 
        </strong></font></td>
    </tr>
    <tr> 
      <td width="15%" height="13" align="center" class="thinborder"><font size="1"><strong>LASTNAME</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>FIRSTNAME</strong></font></td>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>MI</strong></font></td>
    </tr>
    <% 		for(int k=1; k<vUnrecorded.size(); k+=7){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(String)vUnrecorded.elementAt(k)%></div></td>
      <td class="thinborder"><%=(String)vUnrecorded.elementAt(k+3)%></td>
      <td class="thinborder"><%=(String)vUnrecorded.elementAt(k+1)%></td>
      <td class="thinborder"><div align="center"><%=(WI.getStrValue((String)vUnrecorded.elementAt(k+2))).charAt(0)%></div></td>
      <td class="thinborder">&nbsp;<%=(String)vUnrecorded.elementAt(k+4)%> </td>
      <td class="thinborder"><div align="center"><%=(String)vUnrecorded.elementAt(k+5)%></div></td>
    </tr>
    <%}// end of for loop%>
  </table>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF">
    <% 		for(int k=1; k<vUnrecorded.size(); k+=7){%>
    <%}// end of for loop%>
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
  <%} if (vRecorded.size() > 1){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="27" colspan="7" align="center" class="thinborder"><strong>STUDENTS 
        WITH SCORE</strong></td>
    </tr>
    <tr> 
      <td width="15%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>STUDENT 
        ID</strong></font></td>
      <td height="27" colspan="3" align="center" class="thinborder"><strong><font size="1">STUDENT 
        NAME</font></strong></td>
      <td width="25%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>COURSE/MAJOR</strong></font></td>
      <td width="10%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>YEAR 
        </strong></font></td>
      <td width="10%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>SCORE</strong></font></td>
    </tr>
    <tr> 
      <td width="15%" height="13" align="center" class="thinborder"><font size="1"><strong>LASTNAME</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>FIRSTNAME</strong></font></td>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>MI</strong></font></td>
    </tr>
    <%	for(int k=1; k<vRecorded.size(); k+=9){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(String)vRecorded.elementAt(k)%></div></td>
      <td class="thinborder"><%=(String)vRecorded.elementAt(k+3)%></td>
      <td class="thinborder"><%=(String)vRecorded.elementAt(k+1)%></td>
      <td class="thinborder"><div align="center"><%=(WI.getStrValue((String)vRecorded.elementAt(k+2))).charAt(0)%></div></td>
      <td class="thinborder"><%=(String)vRecorded.elementAt(k+4)%> </td>
      <td class="thinborder"><%=(String)vRecorded.elementAt(k+5)%></td>
      <td class="thinborder"><div align="center"><%=(String)vRecorded.elementAt(k+7)%></div></td>
    </tr>
    <%}// end of for loop%>
  </table>
  <%}// vRecorded.size() > 1
  } // if vRetResult == null
} // if vSubSecDetail not found%>
<input type="hidden" name="sub_sec_index" value="<%=strSubSecIndex%>">
<input type="hidden" name="page_action">
<input type="hidden" name="sem_label">
<input type="hidden" name="subj_label">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("copied_fr_index")%>">
</form>

</body>
</html>
<%
	dbOP.cleanUP();
%>