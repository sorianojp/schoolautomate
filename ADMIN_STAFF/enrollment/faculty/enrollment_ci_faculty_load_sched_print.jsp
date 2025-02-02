<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CI Faculty Loading Print</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
-->
</style>

</head>
<body>
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
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-LOADING(CLINICAL SCHEDULE)"),"0"));
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
Vector vRetSummaryLoad  = null;

FacultyManagement FM = new FacultyManagement();
Vector vUserDetail = null;
String strEmployeeIndex = dbOP.mapOneToOther("user_table","id_number","'"+WI.fillTextValue("emp_id")+"'",
							"user_index"," and (auth_type_index is null or (auth_type_index <>4 and auth_type_index<>6))");

if(strEmployeeIndex != null) {
	vUserDetail = FM.viewFacultyDetail(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"),
					WI.getStrValue(WI.fillTextValue("c_index")," and offered_by_college = ","",""));
	if(vUserDetail == null)
		strErrMsg = FM.getErrMsg();
	else {
	
		vRetResult = FM.operateOnFacultyLoadCI(dbOP,request,4);
					
		if(vRetResult == null)
			strErrMsg = FM.getErrMsg();
	}
}

String[] astrSemester = {"Summer", "1st Sem", "2nd Sem","3rd Sem",""};
String strSchCode = (String)request.getSession(false).getAttribute("school_code");

//end of authenticaion code.
%>
<table width="100%" border="0" bgcolor="#FFFFFF">
  <% if (strSchCode.startsWith("UI")){%>
  <tr> 
    <td><font size="1">UI - ACAD - 009-A</font></td>
    <td><div align="right"><font size="1">REVISION No. 02 Revision Date: 20 Apr 07 </font></div></td>
  </tr>
  <%}%>
  <tr> 
    <td width="100%" colspan="2"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></div>
      <br></td>
  </tr>
  <% if(strErrMsg != null){%>
  <tr> 
    <td height="25" colspan="2">&nbsp;&nbsp; <%=strErrMsg%></td>
  </tr>
  <%}%>
</table>
<%
if(vUserDetail != null && vUserDetail.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%">Employee Name</td>
      <td width="29%"><strong><%=(String)vUserDetail.elementAt(1)%></strong></td>
      <td width="19%">Employment Status</td>
      <td width="35%"><strong><%=(String)vUserDetail.elementAt(2)%></strong></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td><strong><%=WI.getStrValue(vUserDetail.elementAt(4))%></strong></td>
      <td>Employment Type</td>
      <td><strong><%=(String)vUserDetail.elementAt(7)%></strong></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td>Department</td>
      <td><strong><%=WI.getStrValue(vUserDetail.elementAt(5),"N/A")%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%}//end of vUserDetail.

 if (vRetResult != null && vRetResult.size() > 1) {
 
   String[] astrConvType ={" Hour(s)"," Day(s)"," Week(s)"," Month(s)"};
	Vector vTotalHours = (Vector)vRetResult.elementAt(0);
	String strTotal = "";
	
	//System.out.println("vTotalHours : " + vTotalHours);
	
	while(vTotalHours.size() > 0){
		if (strTotal.length() == 0) 
			strTotal = (String)vTotalHours.remove(0);			
		else
			strTotal += ", " + (String)vTotalHours.remove(0);
	
//		strTotal += (String)vTotalHours.remove(0);
		
		if (!strSchCode.startsWith("UI")) { 
			strTotal += " " + astrConvType[Integer.parseInt((String)vTotalHours.remove(0))];
		}else{
			vTotalHours.remove(0);
		}
	}
 
 if (strSchCode.startsWith("UI")) {
 %>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr>
	<td height="20" colspan="6"><div align="center"><strong>TEACHING LOAD ASSIGNMENT (AY : <%=WI.fillTextValue("sy_from")%> -  
        <%=WI.fillTextValue("sy_to")%>, <%=astrSemester[Integer.parseInt(WI.getStrValue(WI.fillTextValue("semester"),"1"))]%>)
    </strong></div></td>
</tr>
<tr>
  <td width="21%" height="20">TOTAL NO. OF SECTION: </td>
  <td width="19%"><%=((vRetResult.size()-1) / 15)%></td>
  <td width="14%">TOTAL UNITS : </td>
  <td width="14%">&nbsp;</td>
  <td width="23%"><div align="right">TOTAL NO. HOURS/WEEK: </div></td>
  <td width="9%">&nbsp;<%=strTotal%></td>
</tr>
</table>
<%}%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
<% if (!strSchCode.startsWith("UI")) { %>

  <tr> 
    <td height="25" colspan="6" align="center" class="thinborder"><strong>CLINICAL 
      INSTRUCTOR LOAD SCHEDULE 	   </strong></td>
  </tr>
<%}%> 
  <tr> 
    <td width="15%" align="center" class="thinborder"><font size="1"><strong>SUBJECT</strong></font></td>
    <td width="15%" align="center" class="thinborder"><font size="1"><strong>SCHEDULE</strong></font></td>
    <td width="21%" align="center" class="thinborder"><font size="1"><strong>HOSPITAL/CLINIC 
      NAME<br>
      ADDRESS</strong></font></td>
    <td width="10%" align="center" class="thinborder"><font size="1"><strong> 
      AREA OF ASSIGNMENT</strong></font></td>
<% if (strSchCode.startsWith("UI"))
		strTemp = "No. of Hrs/Week";
	else
		strTemp = "Duration";
%>
	  
    <td width="10%" height="27" align="center" class="thinborder"><font size="1"><strong><%=strTemp%></strong></font></td>
	
<% if (strSchCode.startsWith("UI"))
		strTemp = "Remark / <br> Date Started";
	else
		strTemp = "INCLUSIVE DATES";
%>	
    <td width="15%" align="center" class="thinborder"><strong><font size="1"><%=strTemp%></font></strong></td>
  </tr>
  <%		
	for (int i = 1; i < vRetResult.size(); i+=15) {

   %>
  <tr> 
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+11)%> 
	
<% if (!strSchCode.startsWith("UI")){%>
	&nbsp;(<%=(String)vRetResult.elementAt(i+13)%>)
<%}%>
	
	
	</td>
    <%
	 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+2));
		if (strTemp.length() > 0) {
			strTemp +=  WI.getStrValue((String)vRetResult.elementAt(i+3)," :: ","","");
		}else{
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+3));
		}
	 %>
    <td class="thinborder">&nbsp; <%=strTemp%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+8)%><br>
      &nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+10)%></td>
    <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4),"",astrConvType[Integer.parseInt((String)vRetResult.elementAt(i+5))],"&nbsp;")%></td>
    <td class="thinborder">&nbsp; <%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6));
		if (strTemp.length() > 0) {
			strTemp +=  WI.getStrValue((String)vRetResult.elementAt(i+7)," to ","","");
		}else{
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+7));
		}
	%> <%=strTemp%> </td>
  </tr>
  <%} // end for loop%>
</table>


<% if (strSchCode.startsWith("UI")){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="3"><div align="center"><strong>SUMMARY OF TEACHING LOAD</strong> </div></td>
  </tr>
  <tr>
    <td height="18" colspan="3">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr>
    <td width="62%" height="22" class="thinborder"><div align="center"><strong>COLLEGES / DEPARTMENTS</strong> </div></td>
    <td width="19%" class="thinborder"><div align="center"><strong>NO. OF UNITS </strong></div></td>
    <td width="19%" class="thinborder"> <div align="center"><strong>NO OF HOURS</strong> </div></td>
  </tr>
  <tr>
    <td height="22" class="thinborder">&nbsp;&nbsp;College of Nursing</td>
    <td class="thinborder">&nbsp;&nbsp;</td>
    <td class="thinborder">&nbsp;&nbsp;<%=strTotal%></td>
  </tr>
  <tr>
    <td height="22" class="thinborder"><div align="right"><strong>TOTAL &nbsp;&nbsp;&nbsp; </strong></div></td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;&nbsp;<%=strTotal%></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="6%">&nbsp;</td>
    <td width="29%">&nbsp;</td>
    <td>&nbsp;</td>
    <td width="32%">&nbsp;</td>
    <td width="6%" height="30">&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td width="25%">&nbsp;</td>
    <td class="thinborderBottom"><div align="center"><strong><%=((String)vUserDetail.elementAt(1)).toUpperCase()%></strong></div></td>
    <td><div align="center"><font size="2"></font></div></td>
  </tr>
  <tr>
    <td valign="bottom">&nbsp;</td>
    <td valign="bottom" class="thinborderBottom"><div align="center"><strong><%=WI.getStrValue(dbOP.mapOneToOther("COLLEGE","IS_DEL","0","DEAN_NAME"," and C_NAME like '%nursing'")).toUpperCase()%></strong></div></td>
    <td>&nbsp;</td>
    <td><div align="center">(Teacher's Signature over Printed Name)</div></td>
    <td><div align="center"></div></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="center">Dean,College of Nursing</div></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="3">
  <tr valign="bottom"> 
    <td height="25" colspan="2">&nbsp;</td>
    <td width="11%">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
    <td width="11%">&nbsp;</td>
  </tr>
  <tr valign="bottom"> 
    <td width="12%" height="25">Reviewed by:</td>
    <td width="27%" class="thinborderBottom">&nbsp;</td>
    <td class="thinborderBottom">&nbsp;</td>
    <td width="13%">&nbsp;&nbsp;Approved by:</td>
    <td width="26%" class="thinborderBottom">&nbsp;</td>
    <td class="thinborderBottom">&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="2"><div align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>BOBBIE 
        T. REYES</strong></div></td>
    <td><div align="center"><font size="1"><strong>Date </strong></font></div></td>
    <td colspan="2"><div align="center"><strong>AGNES L. SY, Ph.D </strong></div></td>
    <td><div align="center"><font size="1"><strong>Date</strong></font></div></td>
  </tr>
  <tr> 
    <td colspan="2"><div align="center"><font size="1">Director, HRM</font></div></td>
    <td>&nbsp;</td>
    <td colspan="2"><div align="center"><font size="1">Vice President for Academic 
        Affairs</font></div></td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td height="25" colspan="2">&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="2">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td valign="bottom">Received by:</td>
    <td valign="bottom" class="thinborderBottom">&nbsp;</td>
    <td valign="bottom" class="thinborderBottom">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="2"><div align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>&nbsp;Accounting 
        Department</strong></div></td>
    <td><div align="center"><font size="1"><strong>Date</strong></font></div></td>
    <td colspan="2">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<%
 }// end if strSchCode.startsWith UI
}//if vRetResult != null
 %>
<script language="Javascript">
	window.print();
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>