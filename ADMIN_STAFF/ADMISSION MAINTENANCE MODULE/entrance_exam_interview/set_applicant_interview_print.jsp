<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Exam Result Encoding </title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,java.util.Vector"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	Vector vRetResult = null;
	Vector vSchedData = null;
	String strErrMsg = null;
	String strTemp = null;
	int iCount = 1;

	String[] astrRemarks = {"Failed","Passed"};
	int iEncoded = 1;
	String strSchCode  = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-ENTRANCE EXAM/INTERVIEW",
								"exam_interview_encode_result.jsp");
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
														"Admission Maintenance","ENTRANCE EXAM/INTERVIEW",
														request.getRemoteAddr(),"exam_interview_encode_result.jsp");
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
	ApplicationMgmt appMgmt = new ApplicationMgmt();
	vSchedData = appMgmt.operateOnInterview(dbOP, request, 4,true);
	if (vSchedData == null)
		strErrMsg = appMgmt.getErrMsg();
	int iPageNumber = 1;
	int iPageCount = 1;
	int iStudPerPage =
		 Integer.parseInt(WI.getStrValue(WI.fillTextValue("appl_per_page"),"25"));
%>
<body onLoad="window.print()">
<% if (strErrMsg != null){%>
 <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" height="25"> <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
</table>
<% }
	if (WI.fillTextValue("view_set").equals("0")) {
	if ( vSchedData != null) {  %>
<%
	String strDateInterview = "";
	String strTimeInterview = "";
	
	String strEliminateDateIntv = "";
	String strEliminateTimeIntv = "";
	

	for (int t = 0; t < vSchedData.size();) {
		if(WI.fillTextValue("_"+t).length() > 0)  {
			strEliminateDateIntv = WI.getStrValue((String)vSchedData.elementAt(t+5));
			strEliminateTimeIntv = WI.getStrValue((String)vSchedData.elementAt(t+6));
		}
		//I have to now eliminate date and time intv.
		if(!strEliminateDateIntv.equals(WI.getStrValue((String)vSchedData.elementAt(t+5))) || 
			!strEliminateTimeIntv.equals(WI.getStrValue((String)vSchedData.elementAt(t+6))) ) {
			t+=10;
			continue;
		}

	if (iPageCount == 1){
%>
		<div align="center">
        <font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>
</div>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="42" colspan="3" align="center" >
	  		<strong><font size="2">LIST OF STUDENT WITH INTERVIEW SCHEDULE</font></strong>	  </td>
    </tr>
</table>
<%	} //  show header

		if (iPageCount == 1) {
			strDateInterview = WI.getStrValue((String)vSchedData.elementAt(t+5));
			strTimeInterview = WI.getStrValue((String)vSchedData.elementAt(t+6));
		}
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
 <% if (iPageCount == 1) {%>
    <tr>
      <td align="center" class="thinborder"><strong>
      NO.</strong></td>
      <td height="25" align="center" class="thinborder"><strong>      APPLICANT ID</strong></td>
      <td align="center" class="thinborder"><strong>
      APPLICANT NAME</strong></td>
      <td align="center" class="thinborder"><strong>COURSE</strong></td>
    <b> </b>    </tr>
<%}%>
    <tr>
      <td height="28" colspan="2" class="thinborder"><font size="3"><strong>&nbsp;&nbsp;DATE : <font color="#FF0000"><%=strDateInterview%>	    </font></strong></font></td>
      <td height="28" colspan="2" class="thinborderBOTTOM"><font size="3"><strong>TIME : <font color="#FF0000"><%=strTimeInterview%> </font></strong></font></td>
    </tr>
<%  strDateInterview += " :: " + strTimeInterview;
	for(; t < vSchedData.size(); t+=10){

		if (iPageCount > iStudPerPage){
			iPageCount = 1;
			break;
		}
//////////////// breaking per page updated..
		if (!strDateInterview.equals(WI.getStrValue((String)vSchedData.elementAt(t+5)) + " :: " +
									 WI.getStrValue((String)vSchedData.elementAt(t+6)))) {

			strDateInterview = WI.getStrValue((String)vSchedData.elementAt(t+5));
			strTimeInterview = WI.getStrValue((String)vSchedData.elementAt(t+6));
			break;
		}
		iPageCount++;
%>
    <tr>
	  <td width="11%" height="25" align="right" class="thinborder">
  	  <%=iCount++%>&nbsp;	  </td>
      <td width="19%" class="thinborder">&nbsp;&nbsp;
        <%=(String)vSchedData.elementAt(t+1)%></td>
      <td width="60%" class="thinborder">&nbsp;
        <%=WI.formatName((String)vSchedData.elementAt(t+2),(String)vSchedData.elementAt(t+3),
							(String)vSchedData.elementAt(t+4),4)%></td>
      <td width="10%" class="thinborder">&nbsp;
      <%=(String)vSchedData.elementAt(t+9)%></td>
    </tr>
    <%} if ( t >= vSchedData.size()) {%>
    <tr>
	  <td height="17" colspan="4" align="right" class="thinborder">
	  				<div align="center">********NOTHING FOLLOWS *********	  </div></td>
    </tr>
	<%}%>
</table>
<% if (iPageCount == 1 || t >= vSchedData.size()) { %>
	<br><br>
  <div align="center">Page <%=iPageNumber++%>&nbsp;&nbsp;</div>
<%}%>
    <% if (t < vSchedData.size() && iPageCount == 1) {%>
	  <DIV style="page-break-before:always" >&nbsp;</DIV>
<%   } // if t < vSchedData.size()
	}
   }
 }

 if (WI.fillTextValue("view_set").equals("1")) {
	if ( vSchedData != null) {

  for(int t = 0; t < vSchedData.size();){ 	%>

<div align="center">
        <p><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></p>
</div>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="30" colspan="3" align="center"><strong><font color="#000000" size="2">LIST OF APPLICANT QUALIFIED  INTERVIEW </font></strong></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">

    <tr>
      <td width="9%" align="center" class="thinborder"><strong>
      NO.</strong></td>
      <td width="17%" height="25" align="center" class="thinborder"><strong>      APPLICANT ID</strong></td>
      <td width="70%" align="center" class="thinborder"><strong>
      APPLICANT NAME</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>COURSE</strong></td>
    <b> </b>    </tr>
<%
  for(; t < vSchedData.size(); t+=10){

		if (iPageCount > iStudPerPage){
			iPageCount = 1;
			break;
		}

		iPageCount++;
%>
    <tr>
	  <td height="25" align="right" class="thinborder">
  	  <%=iCount++%>&nbsp;	  </td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=(String)vSchedData.elementAt(t+1)%></td>
      <td class="thinborder">&nbsp;
        <%=WI.formatName((String)vSchedData.elementAt(t+2),(String)vSchedData.elementAt(t+3),
							(String)vSchedData.elementAt(t+4),4)%></td>
      <td class="thinborder">&nbsp;
        <%=(String)vSchedData.elementAt(t+9)%></td>
    </tr>
    <%} if ( t >= vSchedData.size()) {%>
    <tr>
	  <td height="17" colspan="4" align="right" class="thinborder">
	  				<div align="center">********NOTHING FOLLOWS *********	  </div></td>
    </tr>
	<%}%>
</table>
<% if (iPageCount == 1 || t >= vSchedData.size()) { %>
	<br><br>
  <div align="center">Page <%=iPageNumber++%>&nbsp;&nbsp;</div>
<%}
   if (t < vSchedData.size() && iPageCount == 1) {%>
	  <DIV style="page-break-before:always" >&nbsp;</DIV>
<%   } // if t < vSchedData.size()
   }
 }
}
if (WI.fillTextValue("view_set").equals("2")) {
String[] astrSubj ={"REG","EE","ME","EE and ME"};

if ( vSchedData != null) {
	int iMECnt = 0;
	int iEECnt = 0;
	int iMEEECnt = 0;

  for(int t = 0; t < vSchedData.size();){ 	%>

<div align="center">
        <font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>
</div>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="34" colspan="5" align="center"><strong><font color="#000000" size="2">OFFICIAL LIST OF QUALIFIED APPLICANTS</font></strong></td>
    </tr>
    <tr>
      <td width="10%" align="center"><font size="1"><strong>
      NO.</strong></font></td>
      <td width="15%" height="25" align="center"><font size="1"><strong>      APPLICANT ID</strong></font></td>
      <td width="50%" align="center"><font size="1"><strong>
      APPLICANT NAME</strong></font></td>
      <td width="10%" align="center"><font size="1"><strong>COURSE</strong></font></td>
      <td width="16%" align="center"><font size="1"><strong>SUBJECT TO TAKE </strong></font></td>
    </tr>
<%
	for(; t < vSchedData.size(); t+=10){

		if (iPageCount > iStudPerPage){
			iPageCount = 1;
			break;
		}
		iPageCount++;

		if ((String)vSchedData.elementAt(t+7)!= null){
			if (((String)vSchedData.elementAt(t+7)).equals("1"))
				iEECnt++;
			else
				if (((String)vSchedData.elementAt(t+7)).equals("2")	)
					iMECnt++;
			else
				if (((String)vSchedData.elementAt(t+7)).equals("3"))
					iMEEECnt++;

		}
%>
    <tr>
	  <td height="25">
  	  &nbsp;&nbsp;<%=iCount++%></td>
      <td>&nbsp;&nbsp;
        <%=(String)vSchedData.elementAt(t+1)%></td>
      <td>&nbsp;
        <%=WI.formatName((String)vSchedData.elementAt(t+2),(String)vSchedData.elementAt(t+3),
							(String)vSchedData.elementAt(t+4),4)%></td>

      <td>&nbsp;
        <%=(String)vSchedData.elementAt(t+9)%></td>
      <td align="center">&nbsp;
	  	<%=astrSubj[Integer.parseInt(WI.getStrValue((String)vSchedData.elementAt(t+7),"0"))]%></td>
    </tr>
    <%} if ( t >= vSchedData.size()) {%>
    <tr>
	  <td height="17" colspan="5" align="center">
	  				<div align="center">********NOTHING FOLLOWS *********	  </div></td>
    </tr>
	<%}%>
</table>
<% if (iPageCount == 1 || t >= vSchedData.size()) { %>
	<br><br>
  <div align="center">Page <%=iPageNumber++%>&nbsp;&nbsp;</div>
<% }
   if (t < vSchedData.size() && iPageCount == 1) {%>
	  <DIV style="page-break-before:always" >&nbsp;</DIV>
<% } // if t < vSchedData.size()
 }%>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="23" colspan="4" align="center">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="4"><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SUMMARY : </strong></td>
    </tr>
    <tr>
	  <td width="4%" height="25" align="right">&nbsp;</td>
      <td width="30%"><strong>&nbsp;English Enrichment : <%=iEECnt%></strong></td>
      <td width="32%"><strong>Math Enrichment : <%=iMECnt%></strong></td>
      <td width="34%"><strong>Math and English Enrichment : <%=iMEEECnt%></strong></td>
    </tr>
</table>

 <%}
 }%>
</body>
</html>
<%
dbOP.cleanUP();
%>
