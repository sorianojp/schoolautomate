<%
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";
	
if(strSchoolCode.startsWith("HTC")){%>
<jsp:forward page="./student_sched_print_htc.jsp"></jsp:forward>
<%}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
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
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

-->
</style>
<body >
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-student load print","student_sched_print.jsp");
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
Vector vRetResult = null;
Vector vStudDetail= null;

String strMaxAllowedLoad = null;
String strOverLoadDetail = null;
String strCollegeName = null;

ReportEnrollment reportEnrl= new ReportEnrollment();
vRetResult = reportEnrl.getStudentLoad(dbOP, request.getParameter("stud_id"),request.getParameter("sy_from"),
						request.getParameter("sy_to"),request.getParameter("offering_sem"));
if(vRetResult == null)
	strErrMsg = reportEnrl.getErrMsg();
else {
	enrollment.EnrlAddDropSubject enrlAD = new enrollment.EnrlAddDropSubject();
	vStudDetail = enrlAD.getEnrolledStudInfo(dbOP, null, WI.fillTextValue("stud_id"),
					WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),
					WI.fillTextValue("offering_sem"));

	if(vStudDetail == null || vStudDetail.size() > 0)
		strErrMsg = enrlAD.getErrMsg();
}
if(vStudDetail != null && vStudDetail.size() > 0) {
	strCollegeName = new enrollment.CurriculumMaintenance().getCollegeName(dbOP,(String)vStudDetail.elementAt(5));
	enrollment.Advising advising = new enrollment.Advising();
	Vector vMaxLoadDetail = advising.getMaxAllowedUnit(dbOP,WI.fillTextValue("stud_id"),(String)vStudDetail.elementAt(5),
							(String)vStudDetail.elementAt(6),	WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),
							(String)vStudDetail.elementAt(4),WI.fillTextValue("offering_sem"),
							(String)vStudDetail.elementAt(7),	(String)vStudDetail.elementAt(8));
	if(vMaxLoadDetail == null)
		strErrMsg = advising.getErrMsg();

	else
	{
		strMaxAllowedLoad = (String)vMaxLoadDetail.elementAt(0);
		if(vMaxLoadDetail.size() > 1)
			strOverLoadDetail = "Maximum load in curriculum for this sem "+(String)vMaxLoadDetail.elementAt(1)+
			" overloaded load "+(String)vMaxLoadDetail.elementAt(0)+" (approved on :"+(String)vMaxLoadDetail.elementAt(2)+")";
		if(strMaxAllowedLoad.compareTo("-1") ==0)
			strMaxAllowedLoad = "N/A";
	}
}

boolean bolIsCIT = strSchoolCode.startsWith("CIT");

String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester","5th Semester"};

if(strErrMsg != null){dbOP.cleanUP();
%>
<table width="100%" border="0">
    <tr>
      <td width="100%"><div align="center"><%=strErrMsg%></div></td>
    </tr>
</table>
<%}else{%>

  <table width="100%" border="0">
<%
if(strSchoolCode.startsWith("LNU")){%>
    <tr>
      <td height="7" colspan="7" align="left">L-NU REG # 100</td>
    </tr>
<%}%>
    <tr>
      <td width="100%" align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
		  <br>
          <strong><font size="2"><%=strCollegeName%></font></strong>
	  </td>
    </tr>
    <tr>
      <td height="30"><div align="center"><strong> <br>
        <font size="2">STUDENT ENROLMENT LOAD</font><br>
        </strong><%=astrConvertSem[Integer.parseInt(request.getParameter("offering_sem"))]%>, AY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></div></td>
    </tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr >
    <td height="19" colspan="2"><div align="center">
        <hr size="1">
      </div></td>
  </tr>
  <tr >
    <td height="18">&nbsp;</td>
    <td height="18" align="right">Date and time printed :<strong> <%=WI.getTodaysDateTime()%></strong></td>
  </tr>
  <tr >
    <td width="42%" height="25">Student ID :<strong>
	<font size="2"><%=request.getParameter("stud_id")%></font></strong></td>
    <td width="58%" height="25">Course/Major :<strong><%=(String)vStudDetail.elementAt(2)%>
      <%if(vStudDetail.elementAt(3) != null){%>
      / <%=(String)vStudDetail.elementAt(3)%>
      <%}%>
      </strong></td>
  </tr>
  <tr >
    <td height="25">Student Name : <strong><%=(String)vStudDetail.elementAt(1)%></strong></td>
    <td height="25">Curriculum SY : <strong><%=(String)vStudDetail.elementAt(7)%>
      - <%=(String)vStudDetail.elementAt(8)%></strong></td>
  </tr>
  <tr >
    <td height="25">Student type : <strong><%=(String)vStudDetail.elementAt(15)%></strong></td>
    <td>Year : <strong><%=(String)vStudDetail.elementAt(4)%></strong></td>
  </tr>
<%if(!bolIsCIT){%>
	  <tr>
		<td height="25">Student's Signature : _____________________</td>
		<td height="25">Parent's Signature : ______________________</td>
	  </tr>
</table>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
	
		<td width="152%" height="10" colspan="6">&nbsp;</td>
		</tr>
	  </table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	  <%
	if(strOverLoadDetail != null){%>
	  <tr>
		<td  height="25">&nbsp;</td>
		<td colspan="2">Overload detail : <%=strOverLoadDetail%></td>
	  </tr>
	  <%}%>
	  <tr>
		<td width="9" height="25">&nbsp;</td>
		<td height="25" colspan="2">Maximum units the student can take : <strong><%=strMaxAllowedLoad%></strong></td>
	  </tr>
<%}%>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr>
    <td width="13%" height="34" class="thinborder"><div align="center"><strong>SUBJECT
        CODE </strong></div></td>
    <td width="23%" class="thinborder"><div align="center"><strong>SUBJECT TITLE </strong></div></td>
    <td width="20%" class="thinborder"><div align="center"><strong>SCHEDULE</strong></div></td>
    <td width="13%" class="thinborder"><div align="center"><strong>SECTION &amp; ROOM
        #</strong></div></td>
<%
if(WI.fillTextValue("show_instructor").compareTo("1") == 0){%>
     <td width="13%" class="thinborder"><div align="center"><strong>INSTRUCTOR</strong></div></td>
<%}%>    <td width="6%" class="thinborder"><div align="center"><strong>LEC. UNITS </strong></div></td>
    <td width="6%" class="thinborder"><div align="center"><strong>LAB. UNITS</strong></div></td>
    <td width="6%" class="thinborder"><div align="center"><strong>TOTAL UNITS </strong></div></td>
  </tr>
 <%
 int fTotalLoad = 0;//System.out.println(vRetResult);
 for(int i=1; i< vRetResult.size(); ++i){
 if( !((String)vRetResult.elementAt(i+9)).startsWith("("))
	 fTotalLoad += Float.parseFloat((String)vRetResult.elementAt(i+9));
 %>
  <tr>
    <td height="20" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%>
      <!--/<%=(String)vRetResult.elementAt(i+4)%>(<%=(String)vRetResult.elementAt(i+5)%>) -- Room location-->
    </td>
<%
if(WI.fillTextValue("show_instructor").compareTo("1") == 0){%>
     <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+6),"&nbsp;")%></td>
<%}%>    <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+7)%></td>
    <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+8)%></td>
    <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+9)%></td>
  </tr>
<% i = i+10;
}%>
  <tr>
    <td colspan="8" height="25" class="thinborder"><div align="center">TOTAL LOAD UNITS : <%=fTotalLoad%></div></td>
  </tr>
</table>
<%if(bolIsCIT){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td height="25">Printed by : <%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></td>
	</table>	
<%}else{%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" colspan="4">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">Printed by: </td>
    <td height="25" colspan="3"><strong><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></strong></td>
    </tr>
<!--
  <tr>
    <td width="16%" height="18">&nbsp;</td>
    <td colspan="3" valign="top"><em>Dean / Faculty/Secretary</em></td>
  </tr>
-->
  <tr>
    <td height="18">&nbsp;</td>
    <td height="18">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="25">Approved by: </td>
    <td width="37%" height="25">_____________________________________</td>
    <td>Confirmed by: </td>
    <td>___________________________________</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25" valign="top"><em><%if(strSchoolCode.startsWith("DBTC") && vStudDetail.elementAt(19).equals("TVED")){%>
		TVED Director<%}else{%>College Dean/Dept. Head<%}%></em></td>
    <td width="10%">&nbsp;</td>
    <td width="37%" valign="top"><em>Registrar</em></td>
  </tr>
  <%
if(strSchoolCode.startsWith("LNU")){%>
  <tr>
    <td height="25" colspan="4"><font size="2"><strong>NOTE : </strong><br>
    Please proceed to Student Affairs Office for ID application/validation to be <strong>OFFICIALLY ENROLLED
    <br>Get ten percent
      (10%) discount on tuition fees upon full paymentof total school fees not
      later than 1st week of classes</strong></font></td>
  </tr>
  <tr>
    <td height="25" colspan="4" align="center">
		<table width="98%" cellpadding="0" cellspacing="0" class="thinborderALL">
        <tr>
          <td width="20%" align="center">ISSUE STATUS</td>
          <td width="20%" align="center">REVISION</td>
          <td width="20%" align="center">DATE</td>
          <td width="20%" align="center">APPROVED BY</td>
          <td width="20%" align="center">PAGE</td>
        </tr>
        <tr>
          <td align="center">1</td>
          <td align="center">0</td>
          <td align="center">15 May 2005</td>
          <td align="center">(SGD) Atty. Gonzalo T. Duque</td>
          <td align="center">1</td>
        </tr>
      </table>	</td>
  </tr>
  <%}%>
</table>
<%}%>

<script language="JavaScript">
	window.print();

</script>
<%} // only if there is no error
%>



</body>
</html>
<%
dbOP.cleanUP();
%>
