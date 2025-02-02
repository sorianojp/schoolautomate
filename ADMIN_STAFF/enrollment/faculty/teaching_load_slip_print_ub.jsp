<%
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");

if (strSchoolCode == null) {%>
	<p style="font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif; font-size:14px;">You are already logged out. Please login again.
<%return;
}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>teaching load slip</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
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

@media print { 
	.container{
		width:100%;
		border-top:solid 1px #000000;
		/*position:absolute;*/
		bottom:10px;
	}
	
  	.footer{
		width:100%;
		border-top:solid 1px #000000;
		/*position:absolute;*/
		bottom:10px;
	}
}

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderNONE {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }	
	
	TD.thinborderBottomTop {
    border-bottom: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
    TD.thinborderTop {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }	
-->
</style>

</head>
<body topmargin="0" onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	WebInterface WI = new WebInterface(request);

	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-TEACHING LOAD"),"0"));
		}
		
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-SUMMARY LOAD"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-Faculty Load Print","teaching_load_slip_print.jsp");
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
/**
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","FACULTY",request.getRemoteAddr(),
														"teaching_load_slip_print.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
**/


Vector vRetResult = null;
Vector vRetSummaryLoad  = null; double dTotalLoadHour = 0d; double dTotalLoadUnit = 0d;

enrollment.GradeSystem GS = new enrollment.GradeSystem();
FacultyManagement FM = new FacultyManagement();


// for UI as of now..  any other request. please update on per school basis

int iMaxRows = Integer.parseInt(WI.getStrValue(WI.fillTextValue("iMaxRows"),"20"));
int iRowsPrinted = 1;

boolean bolShowEnrolled = (WI.fillTextValue("show_enroll_stud").length() > 0);

boolean bolAllowLoadHour = true;

Vector vUserDetail = null;
String strPTFT = null;
String strEmployeeIndex = dbOP.mapOneToOther("user_table","id_number","'"+WI.fillTextValue("emp_id")+"'",
							"user_index"," and (auth_type_index is null or (auth_type_index <>4 and auth_type_index<>6))");


if(strEmployeeIndex != null) {
	
	if ( strSchoolCode.startsWith("UI") || strSchoolCode.startsWith("UB")){
		strPTFT = dbOP.mapOneToOther("INFO_FACULTY_BASIC","user_index", strEmployeeIndex, "PT_FT", 
									" and is_del = 0" );
		if (strPTFT == null || strPTFT.equals("0")) {	
			strPTFT = "Part Time";
		}else{
			strPTFT = "Full Time";
		}
	}

	vUserDetail = FM.viewFacultyDetail(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"),
					WI.getStrValue(WI.fillTextValue("c_index")," and offered_by_college = ","",""));
	if(vUserDetail == null)
		strErrMsg = FM.getErrMsg();
	else {//System.out.println("Print : "+vUserDetail);
	
		vRetResult = FM.viewFacultyLoadSummary(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"),
					WI.getStrValue(WI.fillTextValue("c_index")," and offered_by_college = ","",""), true, false);
					
		if(vRetResult == null)
			strErrMsg = FM.getErrMsg();
		
		/*if (bolAllowLoadHour || WI.fillTextValue("dynamic").length() > 0) {
			vRetSummaryLoad = FM.getFacultySummaryLoadCollege(dbOP,request);
			if ( vRetSummaryLoad == null) 
				strErrMsg =  FM.getErrMsg();
			else {//get total number of hours. 
				for (int i= 0; i < vRetSummaryLoad.size() ; i+=8)
					dTotalLoadHour += Double.parseDouble((String)vRetSummaryLoad.elementAt(i + 7));
			}
		}*/
	}
}


boolean bolIsEAC = strSchoolCode.startsWith("EAC");

String[] astrSemester={"Summer", "1st SEMESTER", "2nd SEMESTER","3rd SEMESTER"};
//end of authenticaion code.
if(strErrMsg != null){%>
<table width="100%">
  <tr> 
    <td height="25" colspan="2">&nbsp;&nbsp; <%=strErrMsg%></td>
  </tr>
</table>
<%} 

String strPrevCCode = "";
String strCurrCCode = null;

String strCreditUnit = null;
strTemp = " select e_sub_section.sub_index from E_SUB_SECTION "+
		" join subject on (subject.SUB_INDEX = E_SUB_SECTION.SUB_INDEX)   "+
		" where subject.IS_DEL = 0 and E_SUB_SECTION.IS_VALID= 1  "+
		" and OFFERING_SY_FROM = "+WI.fillTextValue("sy_from")+
		" and OFFERING_SEM = "+WI.fillTextValue("semester")+
		" and sub_code = ?"+
		" and SECTION =?";
java.sql.PreparedStatement pstmtSelSubIndex = dbOP.getPreparedStatement(strTemp);
java.sql.ResultSet rs = null;

double dTotLoadHr = 0d;
double dTotLoadUnit =0d;
double dLoadHr = 0d;
double dLoadUnit = 0d;
int iSectionCount = 0;
int iCollegeCount = 0;

 if(vRetResult != null && vRetResult.size() > 0){
	  for (int i = 0; i< vRetResult.size();) { %>

<% if (strSchoolCode.startsWith("UI")){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td width="50%">UI - ACAD - 009</td>
    <td width="50%"><div align="right"><font size="1">Revision No. 02 Revision 
        Date : 20 Apr 07 </font></div></td>
  </tr>
</table>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
      <td align="right"><img src="../../../images/logo/UB_BOHOL.gif" border="0" height="70" width="70"></td>
      <td align="center" valign="bottom"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></td>
      <td align="center">&nbsp;</td>
  </tr>
  <tr>     
    
    <td width="21%" align="right">&nbsp;</td>
	<td align="center"><font size="2"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>
      <br><br>
	  Teacher's Schedule of Classes by College
	  <br>
	  
	  School Year : <%=WI.fillTextValue("sy_from")  +"-" + WI.fillTextValue("sy_to")%> / 
	   <% if (WI.fillTextValue("semester").length() > 0) 
		 		strTemp = astrSemester[Integer.parseInt(WI.fillTextValue("semester"))];
			else strTemp = "";
		 %><%=WI.getStrValue(strTemp," , ","","")%>	 </td>
    <td width="21%" align="center">&nbsp;</td>
  </tr>
</table>
<%  if(vUserDetail != null && vUserDetail.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td height="22"><strong>Prof No : <%=WI.fillTextValue("emp_id")%></strong></td>
	</tr>
	<tr>
	    <td height="22"><strong>Fullname : <%=((String)vUserDetail.elementAt(1)).toUpperCase()%></strong></td>
    </tr>
</table>

<%}//end of vUserDetail.%>
  

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="18%" height="20" class="thinborderBottomTop"><div><font size="1"><strong>SUBJECT CODE</strong></font></div></td>
		<!--<td class="thinborderBottomTop"><div align="center"><font size="1"><strong>SUBJECT NAME</strong></font></div></td>-->
		<td class="thinborderBottomTop" width="18%"><div><font size="1"><strong>SECTION</strong></font></div></td>
		<td class="thinborderBottomTop" width="13%"><div><font size="1"><strong>ROOM</strong></font></div></td>
		<td width="27%" class="thinborderBottomTop"><div><font size="1"><strong>SCHEDULE</strong></font></div></td>
		<td class="thinborderBottomTop" width="8%"><div align="center"><font size="1"><strong>CREDIT UNIT</strong></font></div></td>
		<%if(bolShowEnrolled){%><td class="thinborderBottomTop" width="8%"><div align="center"><font size="1"><strong>ENROLLED</strong></font></div></td><%}%>
		<td class="thinborderBottomTop" width="8%"><div align="center"><font size="1"><strong>PAY UNIT</strong></font></div></td>
	</tr>
<%
String strPayUnit = null;
for(; i < vRetResult.size() ; i +=12){

strCreditUnit = null;

pstmtSelSubIndex.setString(1, (String)vRetResult.elementAt(i));
pstmtSelSubIndex.setString(2, (String)vRetResult.elementAt(i+4));
rs = pstmtSelSubIndex.executeQuery();
if(rs.next())
	strCreditUnit = GS.getLoadingForSubject(dbOP, rs.getString(1));
rs.close();

strCurrCCode = (String)vRetResult.elementAt(i + 2);
if(!strPrevCCode.equals(strCurrCCode)){
	strPrevCCode = strCurrCCode;
	
if(i > 0){
%>
	<tr style="font-weight:bold;"><td height="20" class="thinborderBottom">Sub Total : </td>
	    <!--<td class="thinborderBottom">&nbsp;</td>-->
	    <td class="thinborderBottom">&nbsp;</td>
	    <td class="thinborderBottom">&nbsp;</td>
	    <td class="thinborderBottom">&nbsp;</td>
	    <td class="thinborderBottom" align="center"><%=dLoadUnit%></td>
	    <%if(bolShowEnrolled){%><td class="thinborderBottom">&nbsp;</td><%}%>
	    <td class="thinborderBottom" align="center"><%=CommonUtil.formatFloat(dLoadHr,true)%></td>
	</tr>
<%}%>
  <tr><td height="22" class="thinborderBottom" colspan="8"><strong><font size="1">DEPARTMENT : <%=WI.getStrValue(strCurrCCode).toUpperCase()%></font></strong></td></tr>

<%

dTotLoadHr += dLoadHr;
dTotLoadUnit += dLoadUnit;

iSectionCount = 0;
dLoadUnit = 0d;
dLoadHr = 0d;
}

strPayUnit = (String)vRetResult.elementAt(i + 9);
if(strPayUnit == null || strPayUnit.length() == 0 || Double.parseDouble(strPayUnit) == 0d)
	strPayUnit = (String)vRetResult.elementAt(i + 8);
if(strPayUnit == null || strPayUnit.length() == 0 || Double.parseDouble(strPayUnit) == 0d)
	strPayUnit = (String)vRetResult.elementAt(i + 11);	


++iSectionCount;
try{
	dLoadUnit += Double.parseDouble(WI.getStrValue(strCreditUnit,"0"));
}catch(Exception e){}
try{
	dLoadHr += Double.parseDouble(strPayUnit);
}catch(Exception e){}


%>
	<tr>
		<td valign="top" height="18"><%=(String)vRetResult.elementAt(i)%>
		<%
		if(WI.fillTextValue("show_sub_desc").length() > 0){
		%> - <%=(String)vRetResult.elementAt(i+1)%><%}%>
		</td>
		<!--<td valign="top"><%=(String)vRetResult.elementAt(i + 1)%></td>-->
		<td valign="top"><%=(String)vRetResult.elementAt(i + 4)%></td>
		<td valign="top"><%=WI.getStrValue(vRetResult.elementAt(i + 5),"Not Set")%></td>
		<td valign="top"><%=(String)vRetResult.elementAt(i + 6)%></td>
		<td valign="top" align="center"><%=WI.getStrValue(strCreditUnit)%></td>
		<%if(bolShowEnrolled){%><td valign="top" align="center"><%=(String)vRetResult.elementAt(i + 7)%></td><%}%>
		<td valign="top" align="center"><%=CommonUtil.formatFloat(strPayUnit,true)%></td>
	</tr>
  
  
  <%
   iRowsPrinted++;
   if (iRowsPrinted == iMaxRows + 1) {
		i += 12;
		break;
	}
  }
  
dTotLoadHr += dLoadHr;
dTotLoadUnit += dLoadUnit;

  %>
  <tr style="font-weight:bold;"><td height="20" class="thinborderBottom">Sub Total : </td>
      <!--<td class="thinborderBottom">&nbsp;</td>-->
      <td class="thinborderBottom">&nbsp;</td>
      <td class="thinborderBottom">&nbsp;</td>
      <td class="thinborderBottom">&nbsp;</td>
      <td class="thinborderBottom" align="center"><%=dLoadUnit%></td>
      <%if(bolShowEnrolled){%><td class="thinborderBottom">&nbsp;</td><%}%>
      <td class="thinborderBottom" align="center"><%=CommonUtil.formatFloat(dLoadHr,true)%></td>
  </tr>
  <%
  dLoadHr = 0d;
dLoadUnit = 0d;
  if ( (i +12) > vRetResult.size()) {%>
  <tr style="font-weight:bold;"><td height="20" class="thinborderBottom"></td>
      <!--<td class="thinborderBottom">&nbsp;</td>-->
      <td class="">&nbsp;</td>
      <td class="">&nbsp;</td>
      <td class="">TOTAL UNITS : </td>
      <td class="" align="center"><%=dTotLoadUnit%></td>
      <%if(bolShowEnrolled){%><td class="">&nbsp;</td><%}%>
      <td class="" align="center"><%=CommonUtil.formatFloat(dTotLoadHr, true)%></td>
  </tr>
  <%}%>
</table>
  <table width="100%" cellpadding="0" cellspacing="0">
  <%if (i< vRetResult.size()) {%>
  <tr>
    <td height="20" colspan="10" align="center" class="thinborderNONE"> <strong>********** Continued on Next Page</strong> ********** </td>
  </tr>  
<%}%>
</table>
<%if (i< vRetResult.size()) { %>
	<DIV style="page-break-after:always" >&nbsp;</DIV>
<%  iRowsPrinted = 1; // reset rows printed to 1
   }
 } // end  outer for loop
%>


<div class="container">
<div class="footer">
<%
strTemp = (String)request.getSession(false).getAttribute("first_name");
%>
	<div style="float:left;width:33%;text-align:left">Printed By: <%=WI.getStrValue(strTemp)%></div>
	<div style="float:left;width:52%;">Time Printed: <%=WI.formatDateTime(Long.parseLong(WI.getTodaysDate(28)),3)%> 
		Date Printed: <%=WI.getTodaysDate(1)%></div>
	<div style="float:left;width:15%;text-align:right;">Page 1 of 1</div>
</div>
</div>

<%}//if vRetResult != null%>
</body>
</html>
<%
dbOP.cleanUP();
%>