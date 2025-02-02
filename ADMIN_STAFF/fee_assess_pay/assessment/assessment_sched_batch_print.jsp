<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>
</head>

<body>
<%@ page language="java" import="utility.*,enrollment.FAAssessment,enrollment.FAPaymentUtil,enrollment.CurriculumMaintenance,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;

	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-ASSESSMENT-assessment sched batch print","assessment_sched_batch_print.jsp");
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
														"Fee Assessment & Payments","ASSESSMENT",request.getRemoteAddr(),
														"assessment_sched_batch_print.jsp");
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

Vector vStudInfo = new Vector();
Vector vScheduledPmt = new Vector();
Vector vStudentIDList = new Vector();
String strCollegeName = null;

int iNoOfStudToPrint = Integer.parseInt(WI.getStrValue(WI.fillTextValue("stud_per_pg"),"4"));


FAAssessment FA = new FAAssessment();
FAPaymentUtil pmtUtil = new FAPaymentUtil();
vStudentIDList = FA.getStudIDList(dbOP,request);
if(vStudentIDList == null || vStudentIDList.size() ==0)
	strErrMsg = FA.getErrMsg();
else
	strCollegeName = new CurriculumMaintenance().getCollegeName(dbOP,request.getParameter("course_index"));

String[] strConvertYrSem = {"N/A","Summer","1st Sem","2nd Sem", "3rd Sem","4th Sem","5th","6th","7th"};
%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <%
  if(strErrMsg != null){%>
  <tr>
    <td height="10" colspan="2"><%=strErrMsg%></td>
  </tr>
  <%dbOP.cleanUP();
  return;}%>
  </table>

<%
Vector vStudInfo2 = new Vector();
Vector vScheduledPmt2 = new Vector();
for(int i=0; i< vStudentIDList.size(); i += 2)
{//print for batch of student.
  //System.out.println(vStudentIDList);
	vStudInfo = pmtUtil.getStudBasicInfoOLD(dbOP,(String)vStudentIDList.elementAt(i));
  	if(vStudInfo == null || vStudInfo.size() ==0)
  		strErrMsg = pmtUtil.getErrMsg();
  	else
	{
		//get scheduled payment information.
		vScheduledPmt =FA.getInstallmentSchedulePerStudPerExamSch(dbOP,request.getParameter("pmt_schedule"),(String)vStudInfo.elementAt(0),
			request.getParameter("sy_from"),request.getParameter("sy_to"),(String)vStudInfo.elementAt(4),(String)vStudInfo.elementAt(5));
		//System.out.println(vScheduledPmt);
		if(vScheduledPmt == null || vScheduledPmt.size() ==0)
			strErrMsg = FA.getErrMsg();
	}

	//get student info for 2nd line ;-)
	if(i+1 < vStudentIDList.size() && strErrMsg == null)
	{
		vStudInfo2 = pmtUtil.getStudBasicInfoOLD(dbOP,(String)vStudentIDList.elementAt(i+1));
		if(vStudInfo2 == null || vStudInfo2.size() ==0)
			strErrMsg = pmtUtil.getErrMsg();
		else
		{
			//get scheduled payment information.
			vScheduledPmt2 =FA.getInstallmentSchedulePerStudPerExamSch(dbOP,request.getParameter("pmt_schedule"),(String)vStudInfo2.elementAt(0),
				request.getParameter("sy_from"),request.getParameter("sy_to"),(String)vStudInfo2.elementAt(4),(String)vStudInfo2.elementAt(5));
			//System.out.println(vScheduledPmt);
			if(vScheduledPmt2 == null || vScheduledPmt2.size() ==0)
				strErrMsg = FA.getErrMsg();
		}
	}
	else
		vStudInfo2 = null;




//System.out.println(vStudInfo);
  %>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
<%
  if(strErrMsg != null){%>
  <tr>
    <td height="10" colspan="2">Error in processing for student :<strong> <%=(String)vStudentIDList.elementAt(i)%></strong>
      <br>
      Error Description:<strong> <%=strErrMsg%></strong></td>
  </tr>
  <%dbOP.cleanUP();
  return;}%>

  <tr>
    <td width="50%" height="25"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <%=strCollegeName%><br>
        <strong><br>
        </strong>STUDENT SCHEDULE ASSESSMENT <br>
        <br>
        <strong><%=((String)vScheduledPmt.elementAt(1)).toUpperCase()%> EXAMINATION</strong><br>
        <%=strConvertYrSem[Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(5),"0"))]%> , AY <%=request.getParameter("sy_from")%> to <%=request.getParameter("sy_to")%><br>
        <!--Schedule of examination period : <strong><%//=(String)vScheduledPmt.elementAt(2)%><br>--></strong>
      </div></td>
    <td width="50%">
	<%if(vStudInfo2 != null){%>
	 <div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <%=strCollegeName%><br>
        <strong><br>
        </strong>STUDENT SCHEDULE ASSESSMENT <br>
        <br>
        <strong><%=((String)vScheduledPmt2.elementAt(1)).toUpperCase()%> EXAMINATION</strong><br>
        <%=strConvertYrSem[Integer.parseInt(WI.getStrValue(vStudInfo2.elementAt(5),"0"))]%> , AY <%=request.getParameter("sy_from")%> to <%=request.getParameter("sy_to")%><br>
        <!--Schedule of examination period : <strong><%//=(String)vScheduledPmt2.elementAt(2)%>--></strong></div>
	<%}%>
	</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="14%" height="20">Student ID </td>
    <td width="36%"><strong><%=(String)vStudentIDList.elementAt(i)%></strong></td>
    <td width="14%" height="20"><%if(vStudInfo2 != null){%>Student ID <%}%></td>
    <td width="36%"><strong>
      <%if(vStudInfo2 != null){%>
      <%=(String)vStudentIDList.elementAt(i+1)%>
      <%}%>
      </strong></td>
  </tr>
  <tr>
    <td height="16">Student name </td>
    <td height="16"><strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
    <td height="16">
      <%if(vStudInfo2 != null){%>
      Student name
      <%}%>
    </td>
    <td height="16"><strong>
      <%if(vStudInfo2 != null){%>
      <%=(String)vStudInfo2.elementAt(1)%>
      <%}%>
      </strong></td>
  </tr>
  <tr>
    <td height="18">Course/Major </td>
    <td height="18"><strong><%=(String)vStudInfo.elementAt(2)%>
	<%if(vStudInfo.elementAt(3) != null){%>
	 / <%=WI.getStrValue(vStudInfo.elementAt(3))%>
	 <%}%>
	 </strong></td>
    <td height="18">
      <%if(vStudInfo2 != null){%>
      Course/Major
      <%}%>
    </td>
    <td height="18"><strong>
      <%if(vStudInfo2 != null){%>
      <%=(String)vStudInfo2.elementAt(2)%>
	  <%
	  if(vStudInfo2.elementAt(3) != null){%>
	  / <%=WI.getStrValue(vStudInfo2.elementAt(3))%>
	  <%}%>
      <%}%>
      </strong></td>
  </tr>
  <tr>
    <td height="18">Year level </td>
    <td height="18"><strong><%=strConvertYrSem[Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(4),"0"))]%></strong></td>
    <td height="18">
      <%if(vStudInfo2 != null){%>
      Year level
      <%}%>
    </td>
    <td height="18"><strong>
      <%if(vStudInfo2 != null){%>
      <%=strConvertYrSem[Integer.parseInt(WI.getStrValue(vStudInfo2.elementAt(4),"0"))]%>
      <%}%>
      </strong></td>
  </tr>
  <tr>
    <td height="18" colspan="2">&nbsp;</td>
    <td height="18" colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" colspan="2"><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong>Back Account/Balance
      previous due :<u><%=CommonUtil.formatFloat((String)vScheduledPmt.elementAt(4),true)%></u> Php</td>
    <td height="25" colspan="2"><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong>
      <%if(vStudInfo2 != null){%>
      Back Account/Balance previous due :<u><%=CommonUtil.formatFloat((String)vScheduledPmt2.elementAt(4),true)%></u>
      Php<strong>
      <%}%>
      </strong></td>
  </tr>
  <tr>
    <td height="25" colspan="2"><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong>&nbsp;Installment
      due for this period: <u><%=CommonUtil.formatFloat((String)vScheduledPmt.elementAt(0),true)%> Php</u></td>
    <td height="25" colspan="2"><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong>&nbsp;
      <%if(vStudInfo2 != null){%>
      Installment due for this period: <u><%=CommonUtil.formatFloat((String)vScheduledPmt2.elementAt(0),true)%>
      Php<strong>
      <%}%>
      </strong></u></td>
  </tr>
  <tr>
    <td height="25" colspan="2"><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong>&nbsp;Advance
      payment for this period: <u><%=CommonUtil.formatFloat((String)vScheduledPmt.elementAt(3),true)%> Php</u></td>
    <td height="25" colspan="2"><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong>&nbsp;
      <%if(vStudInfo2 != null){%>
      Advance payment for this period: <u><%=CommonUtil.formatFloat((String)vScheduledPmt2.elementAt(3),true)%>
      Php<strong>
      <%}%>
      </strong></u></td>
  </tr>
  <tr>
    <td height="25" colspan="2"><div align="left"><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong><strong>Total
        amount due for this period :<u><%=CommonUtil.formatFloat((String)vScheduledPmt.elementAt(5),true)%></u>
        Php</strong></div></td>
    <td height="25" colspan="2"><strong> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong><strong>
      <%if(vStudInfo2 != null){%>
      Total amount due for this period :<u><%=CommonUtil.formatFloat((String)vScheduledPmt2.elementAt(5),true)%></u>
      Php
      <%}%>
      </strong></td>
  </tr>
  <tr>
    <td height="10" colspan="2">&nbsp;</td>
    <td height="10" colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" colspan="2">&nbsp; Released by :<u><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></u></td>
    <td height="25" colspan="2">&nbsp;
      <%if(vStudInfo2 != null){%>
      Released by :<u><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></u><strong>
      <%}%>
      </strong></td>
  </tr>
  <tr>
    <td height="25" colspan="2" valign="top"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Business
        Office)</div></td>
    <td height="25" colspan="2" valign="top"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%if(vStudInfo2 != null){%>
        (Business Office)<strong>
        <%}%>
        </strong></div></td>
  </tr>
  <tr>
    <td height="25" colspan="2"><div align="center"></div></td>
    <td height="25" colspan="2">&nbsp;</td>
  </tr>
</table>
<%if( (i + 2) % iNoOfStudToPrint == 0 && (vStudentIDList.size() > (i + 2)) ) {//System.out.println(" i am here.:"+vStudentIDList.size());%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//end of page break.
}//for loop displays all the students.


dbOP.cleanUP();
if(strErrMsg == null)
{%>
<script language="JavaScript">
	window.print();

</script>
<%}%>
</body>
</html>
