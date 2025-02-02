<%
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");

if (strSchoolCode == null) {%>
	<p style="font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif; font-size:14px;">You are already logged out. Please login again.
<%return;
}


if(strSchoolCode.startsWith("NEU")){%>
	<jsp:forward page="./teaching_load_slip_print_neu.jsp" />
<%}
if(strSchoolCode.startsWith("VMA")){%>
	<jsp:forward page="./teaching_load_slip_print_vma.jsp" />
<%}
if(strSchoolCode.startsWith("UB")){%>
	<jsp:forward page="./teaching_load_slip_print_ub.jsp" />
<%}

if(strSchoolCode.startsWith("CDD")){%>
	<jsp:forward page="./teaching_load_slip_print_cdd.jsp" />
<%}
if(strSchoolCode.startsWith("SWU")){%>
	<jsp:forward page="./teaching_load_slip_print_swu.jsp" />
<%}%>

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

FacultyManagement FM = new FacultyManagement();


// for UI as of now..  any other request. please update on per school basis

int iMaxRows = Integer.parseInt(WI.getStrValue(WI.fillTextValue("iMaxRows"),"15"));
int iRowsPrinted = 1;

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
					WI.getStrValue(WI.fillTextValue("c_index")," and offered_by_college = ","",""), true, true);
					
		if(vRetResult == null)
			strErrMsg = FM.getErrMsg();
		
		if (bolAllowLoadHour || WI.fillTextValue("dynamic").length() > 0) {
			vRetSummaryLoad = FM.getFacultySummaryLoadCollege(dbOP,request);
			if ( vRetSummaryLoad == null) 
				strErrMsg =  FM.getErrMsg();
			else {//get total number of hours. 
				for (int i= 0; i < vRetSummaryLoad.size() ; i+=8)
					dTotalLoadHour += Double.parseDouble((String)vRetSummaryLoad.elementAt(i + 7));
			}
		}
	}
}


boolean bolIsEAC = strSchoolCode.startsWith("EAC");

String[] astrSemester={"Summer", "1st Sem", "2nd Sem","3rd Sem"};
//end of authenticaion code.
if(strErrMsg != null){%>
<table width="100%">
  <tr> 
    <td height="25" colspan="2">&nbsp;&nbsp; <%=strErrMsg%></td>
  </tr>
</table>
<%} 


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
    <td width="10%" align="left">
<%if (strSchoolCode.startsWith("UL")){%>
	<img src="../../../images/logo/UL_DAGUPAN.gif" height="100" width="100">
<%}%>
	</td>
    <td align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>
      <br></td>
  </tr>
</table>
<%  if(vUserDetail != null && vUserDetail.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      
    <td width="10%">Faculty </td>
      <td width="45%"><strong><%=((String)vUserDetail.elementAt(1)).toUpperCase()%>(<%=WI.fillTextValue("emp_id")%>)</strong></td>
      <td width="18%">Employment Status</td>
      <td width="27%"><strong>
	  <%if (!strSchoolCode.startsWith("UI") && !strSchoolCode.startsWith("UB")) {%> 
	  <%=(String)vUserDetail.elementAt(2)%>
	  <%}else{%>
	  <%=(String)vUserDetail.elementAt(2) + " : " + strPTFT%>
	  <%}%> 	  
	  </strong></td>
    </tr>
    <tr > 
      <td height="22">&nbsp;</td>
      <td>College</td>
      <td><strong><%=WI.getStrValue(vUserDetail.elementAt(4))%></strong></td>
      <td>Employment Type</td>
      <td><strong><%=(String)vUserDetail.elementAt(7)%></strong></td>
    </tr>
    <tr > 
      <td height="22">&nbsp;</td>
      <td>Department</td>
      <td><strong><%=WI.getStrValue(vUserDetail.elementAt(5),"N/A")%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
</table>
<%}//end of vUserDetail.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
<% if (strSchoolCode != null && strSchoolCode.startsWith("UI")) 
		strTemp = "TEACHING LOAD ASSIGNMENT";
	else
		strTemp = "TEACHING LOAD DETAILS";
%>
      <td height="20" colspan="3" class="thinborderBottom" align="center"><strong><%=strTemp%>
	  (<%="AY : " + WI.fillTextValue("sy_from")  +" - " + WI.fillTextValue("sy_to")%>
		 <% if (WI.fillTextValue("semester").length() > 0) 
		 		strTemp = astrSemester[Integer.parseInt(WI.fillTextValue("semester"))];
			else strTemp = "";
		 %><%=WI.getStrValue(strTemp," , ","","")%>)
	  </strong></td>
    </tr>
<%//System.out.println("Dynamic : "+WI.fillTextValue("dynamic"));%>    
<%if (strSchoolCode.startsWith("WUP")){
strTemp = (String)vUserDetail.elementAt(6);
int iIndexOf = strTemp.indexOf("(");
if(iIndexOf > -1)
	strTemp = strTemp.substring(0,iIndexOf);
	%>
	<tr> 
      <td width="33%" height="20"><font size="1">TOTAL NO. OF SECTION : <strong><%=(String)vUserDetail.elementAt(8)%></strong></font></td>
      <td width="26%"> <font size="1">TOTAL UNITS :<strong><%=strTemp%></strong></font></td>
      <td width="37%"><font size="1">TOTAL NO. OF HOURS/WEEK : <strong>
	  <%if(bolAllowLoadHour || WI.fillTextValue("dynamic").length() > 0){%>
	  	<%=CommonUtil.formatFloat(dTotalLoadHour,false)%><%}else{%>
	  <%=(String)vUserDetail.elementAt(9)%><%}%>
	  </strong></font></td>
    </tr>
	<tr>
	  <td height="20" style="font-size:9px;">TOTAL NO. OF HOURS: <font size="1"><strong><%=CommonUtil.formatFloat(dTotalLoadHour,false)%></strong></font></td>
	  <td style="font-size:9px;">TOTAL LOADS: <strong><%=CommonUtil.formatFloat(dTotalLoadHour/3d,false)%></strong></td>
	  <td>&nbsp;</td>
	</tr>
<%}else{%>
	<tr> 
      <td width="33%" height="25"><font size="1">TOTAL NO. OF SECTION : <strong><%=(String)vUserDetail.elementAt(8)%></strong></font></td>
      <td width="26%"> <font size="1">TOTAL UNITS :<strong><%=CommonUtil.formatFloat((String)vUserDetail.elementAt(6),true)%></strong></font></td>
      <td width="37%"><font size="1">TOTAL NO. OF HOURS/WEEK : <strong>
	  <%if(bolAllowLoadHour || WI.fillTextValue("dynamic").length() > 0){%>
	  	<%=CommonUtil.formatFloat(dTotalLoadHour,false)%><%}else{%>
	  <%=(String)vUserDetail.elementAt(9)%><%}%>
	  </strong></font></td>
    </tr>
<%}%>
  </table>
	
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr> 
    <td width="9%" height="25" class="thinborder"><div align="center"><font size="1"><strong>SUBJECT CODE</strong></font></div></td>
    <td width="21%" class="thinborder"><div align="center"><font size="1"><strong>SUBJECT TITLE </strong></font></div></td>
    <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>COLLEGE OFFERING </strong></font></div></td>
    <td width="4%" class="thinborder"><div align="center"><font size="1"><strong><%if(strSchoolCode.startsWith("UI") || strSchoolCode.startsWith("WUP")){%>LOAD UNITS <%}else{%>LEC/LAB UNITS<%}%></strong></font></div></td>
    <td width="5%" class="thinborder"><div align="center"><strong><font size="1"><%if(bolAllowLoadHour){%>LOAD HOURS<%}else{%>FACULTY LOAD<%}%></font></strong></div></td>
    <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>SECTION </strong></font></div></td>
    <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>SCHEDULE</strong></font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>ROOM</strong></font></div></td>
    <td width="4%" class="thinborder"><div align="center"><font size="1"><strong>NO. OF STUD.</strong></font></div></td>
<% 	if (strSchoolCode!= null && strSchoolCode.startsWith("UI"))
		strTemp = "REMARKS/DATE STARTED";
	else if (strSchoolCode.startsWith("WUP"))
		strTemp = "DATE STARTED";
	else
		strTemp = "DEAN'S SIGNATURE";
if(!bolIsEAC) {%>
    <td width="7%" class="thinborder"><div align="center"><font size="1"><strong> <%=strTemp%></strong></font></div></td>
<%}%>
  </tr>
  <%
for(; i < vRetResult.size() ; i +=12){%>
  <tr> 
    <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
    <td class="thinborder" align="center">&nbsp; 
      <%if(strSchoolCode.startsWith("UI") || strSchoolCode.startsWith("WUP")){%><%=(String)vRetResult.elementAt(i + 8)%> <%}else{%><%=(String)vRetResult.elementAt(i + 3)%><%}%>    </td>
    <td class="thinborder"><div align="center">
      <%if(bolAllowLoadHour){%>
        <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 9),false)%>
<%}else{%><%=(String)vRetResult.elementAt(i + 8)%><%}%>
      </div></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5),"Not Set")%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 7)%></td>
<%if(!bolIsEAC) {%>
    <td class="thinborder">&nbsp;</td>
<%}%>
  </tr>
  <%
   iRowsPrinted++;
	   if (iRowsPrinted == iMaxRows + 1) {
			i += 12;
			break;
		}
  }
 
  if (i< vRetResult.size()) {
  %>
</table>
  <table width="100%" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25" colspan="10" align="center" class="thinborderNONE"> <strong>********** Continued on Next Page</strong> ********** </td>
  </tr>  
<%}%> 
</table>
<%if (i< vRetResult.size()) { %>
	<DIV style="page-break-after:always" >&nbsp;</DIV>
<%  iRowsPrinted = 1; // reset rows printed to 1
   }
 } // end  outer for loop
%>



 <!-- signatory -- different for different schools.-->
<%
if(strSchoolCode.startsWith("MARINER")) {%> 
<br>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="30%">&nbsp;</td>
	   <td width="40%">&nbsp;</td>
	   <td width="30%" align="center">Conforme:</td>
	</tr>
	<tr>
	   <td height="30" valign="bottom" align="center"><u><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "Academics Secretary",7)).toUpperCase()%></u></td>
	   <td valign="bottom" align="center"><u><%=WI.getStrValue(vUserDetail.elementAt(10),"DR. GABRIEL LAZARO JIMENEZ").toUpperCase()%></u></td>
	   <td valign="bottom" align="center"><u><%=WI.getStrValue(vUserDetail.elementAt(1)).toUpperCase()%></u></td>
   </tr>
	<tr>
	   <td align="center">Academics Secretary</td>
	   <td align="center">Dean</td>
	   <td align="center">Faculty</td>
   </tr>
	<tr>
	   <td height="40" valign="bottom">&nbsp;</td>
	   <td valign="bottom" align="center"><u>DR. MARILISSA J. AMPUAN</u></td>
	   <td valign="bottom" align="center">&nbsp;</td>
   </tr>
	<tr>
	   <td align="center"></td>
	   <td align="center">President</td>
	   <td align="center"></td>
   </tr>
</table>
<%}else if(strSchoolCode.startsWith("UL")) {%>   
<br><table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr valign="bottom">
    <td width="4%" height="25">&nbsp;</td>
    <td width="48%" height="25">Conforme:</td>
    <td width="48%" height="25">Recommending Approval:</td>
  </tr>
  <tr valign="bottom">
    <td height="25">&nbsp;</td>
    <td valign="bottom">__________________________________</td>
    <td valign="bottom">__________________________________</td>
  </tr>
  <tr valign="top">
    <td height="25">&nbsp;</td>
    <td><%=WI.getStrValue(vUserDetail.elementAt(1)).toUpperCase()%><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Faculty</td>
    <td><%=WI.getStrValue(vUserDetail.elementAt(10)).toUpperCase()%><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Dean</td>
  </tr>
  <tr valign="top">
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr valign="bottom">
    <td height="25">&nbsp;</td>
    <td valign="bottom">__________________________________</td>
    <td valign="bottom">__________________________________</td>
  </tr>
  <tr valign="top">
    <td height="25">&nbsp;</td>
    <td>MRS. DOLORES B. BUSTILLO<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Personnel Officer</td>
    <td>DR. AURORA M. SAMSON-REYNA<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;VP for Academic Affairs</td>
  </tr>
</table>


<%}else if(strSchoolCode.startsWith("UPH")){%>
<br>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr valign="bottom">
    <td width="4%" height="20">&nbsp;</td>
    <td width="48%">&nbsp;</td>
    <td width="48%">&nbsp;</td>
  </tr>
  <tr valign="bottom" align="center">
    <td height="20">&nbsp;</td>
    <td valign="bottom">__________________________________</td>
    <td valign="bottom">__________________________________</td>
  </tr>
  <tr valign="top" align="center">
    <td height="25">&nbsp;</td>
    <td><%=WI.getStrValue(vUserDetail.elementAt(10)).toUpperCase()%><br>
    Dean</td>
    <td><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "HR Head",7)).toUpperCase()%><br>
      HR Head </td>
  </tr>
  <tr valign="top">
    <td height="20">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr valign="bottom"  align="center">
    <td height="20">&nbsp;</td>
    <td valign="bottom">__________________________________</td>
    <td valign="bottom">__________________________________</td>
  </tr>
  <tr valign="top" align="center">
    <td height="25">&nbsp;</td>
    <td><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "School Director",7)).toUpperCase()%><br>
      School Director </td>
    <td><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "IT Director",7)).toUpperCase()%><br>
      IT Director </td>
  </tr>
  <tr valign="top" align="center">
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr valign="top">
    <td height="25">&nbsp;</td>
    <td colspan="2">This Teaching Load Form is subject to the provision of the Faculty Manual, as this may be amended from time to time. The details stated herein are true as of printing and subject to change upon sole discretion of the University Administration.</td>
    </tr>
  <tr valign="top">
    <td height="25">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr valign="bottom"  align="center">
    <td height="20">&nbsp;</td>
    <td valign="bottom">Conformed: __________________________________</td>
    <td valign="bottom">Date: _________________</td>
  </tr>
  <tr valign="top" align="center">
    <td>&nbsp;</td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Signature</td>
    <td>&nbsp;</td>
  </tr>
</table>

<%}if(strSchoolCode.startsWith("WNU")) {%>   
<br><table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr valign="bottom"> 
    <td width="7%" height="55">&nbsp;</td>
    <td width="38%" align="center">____________________________________</td>
    <td width="11%" align="center"></td>
    <td width="44%" align="center">____________________________________</td>
  </tr>
  <tr valign="top">
    <td height="10">&nbsp;</td>
    <td align="center"><font size="2">VP-Academic Affairs </font></td>
    <td align="center">&nbsp;</td>
    <td align="center"><font size="2">VP-Finance</font></td>
  </tr>
</table>
<%}else if(strSchoolCode.startsWith("WUP")) {%>   
<br><table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr valign="bottom" align="center"> 
    <td width="19%"  height="55">________________<br>Faculty</td>
    <td width="1%"></td>
    <td width="19%">________________<br>Dean</td>
    <td width="1%" ></td>
    <td width="19%">________________<br>Registrar</td>
    <td width="1%"></td>
    <td width="19%">________________<br>VPAA</td>
    <td width="1%"></td>
    <td width="20%">________________<br>President</td>
  </tr>
</table>
<%}else if(strSchoolCode.startsWith("VMUF") || strSchoolCode.startsWith("PHILCST")) {%>   
<br><table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr valign="bottom"> 
    <td width="1%" height="75">&nbsp;</td>
    <td width="22%" align="center"><!--<%if(strSchoolCode.startsWith("VMUF")){%>_____________________<%}else{%><u><%=((String)vUserDetail.elementAt(1)).toUpperCase()%></u><%}%>-->_____________________</td>
    <td width="23%" align="center">_____________________</td>
    <td width="30%" align="center"><%if(strSchoolCode.startsWith("VMUF")){%>__________________________<%}%></td>
    <td width="24%" align="center">_____________________    </td>
  </tr>
  <tr valign="top">
    <td height="10">&nbsp;</td>
    <td align="center"><font size="2">Faculty</font></td>
    <td align="center"><font size="2"><%if(strSchoolCode.startsWith("VMUF")){%>HR Manager<%}else{%>Dean's Signature<%}%></font></td>
    <td align="center"><font size="2"><%if(strSchoolCode.startsWith("VMUF")){%>VP, Academic Affairs<%}%></font></td>
    <td align="center"><font size="2"><%if(strSchoolCode.startsWith("VMUF")){%>Registrar<%}else{%>VP, Academic Affairs<%}%></font></td>
  </tr>
</table>
 <%} else if(strSchoolCode.startsWith("LNU")){%>
 
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr valign="bottom"> 
    <td width="2%" height="10">&nbsp;</td>
    <td><font size="2"><br>Recommended by : </font></td>
    <td width="49%" align="center"></td>
  </tr>
  <tr valign="top"> 
    <td height="25">&nbsp;</td>
    <td width="49%" align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
  <tr valign="top"> 
    <td height="25">&nbsp;</td>
    <td align="center"><font size="2">
	<%  // c_index != null exclusive of LNU ONLY!
	if (WI.fillTextValue("c_index").length() > 0) {%>
			<%=dbOP.mapOneToOther("COLLEGE","c_index",WI.fillTextValue("c_index"),"DEAN_NAME"," and is_del = 0")%><br>
      Dean, <%=dbOP.mapOneToOther("COLLEGE","c_index",WI.fillTextValue("c_index"),"C_NAME"," and is_del = 0")%><br> 
	<%}else{%>
			<%=WI.getStrValue((String)vUserDetail.elementAt(10))%><br>
      Dean, <%=WI.getStrValue((String)vUserDetail.elementAt(4))%><br> 
	 <%}%>		  
	  </font></td>
    <td align="center"><font size="2">DR. IRMINA B. FRANCISCO<br>
      Director, Academic Affairs </font></td>
  </tr>
  <tr valign="top"> 
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
  <tr valign="top"> 
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
  <tr valign="top"> 
    <td height="25">&nbsp;</td>
    <td align="center"><font size="2">MS. LORENA L. PANELO<br>
      Acting Director, Human Resource Dev't. </font></td>
    <td align="center"><font size="2">MRS.NENITA Q. CUISON<br>
      Internal Auditor </font></td>
  </tr>
  <tr valign="top"> 
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
  <tr valign="top"> 
    <td height="25">&nbsp;</td>
    <td colspan="2" align="center"><font size="2">Approved By: </font></td>
  </tr>
  <tr valign="top"> 
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
  <tr valign="top"> 
    <td height="25">&nbsp;</td>
    <td colspan="2" align="center"><font size="2">ATTY. GONZALO T. DUQUE, Ed.D.<br>
      President</font></td>
  </tr>
</table>
 
 <%
}if(strSchoolCode.startsWith("EAC")) {
	boolean bolIsCavite = false;
	strTemp = dbOP.getResultOfAQuery("select info5 from sys_info", 0);
	if(strTemp != null && strTemp.equals("Cavite"))
		bolIsCavite = true;
%>   
<br>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr valign="bottom">
    <td width="2%" height="25">&nbsp;</td>
    <td width="45%" height="25"><!--Posted By:--> </td>
    <td width="53%" height="25">Verified By: </td>
  </tr>
  <tr valign="bottom">
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr valign="bottom">
    <td height="25">&nbsp;</td>
    <td align="center">
		<table width="75%" cellpadding="0" cellspacing="0">
			<tr>
				<td align="center" <%if(bolIsCavite){%>class="thinborderBottom"<%}%>>&nbsp;
				<%if(bolIsCavite){%>
					<%=WI.getStrValue(new CommonUtil().getName(dbOP, Integer.parseInt((String)request.getSession(false).getAttribute("userIndex")),7)).toUpperCase()%>
				<%}else{%>
					<!--<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "Asst. Registrar",7)).toUpperCase()%>-->
				<%}%>
				</td>
			</tr>
			<tr>
				<td align="center" class="thinborderNONE"><%if(bolIsCavite){%>&nbsp;<%}else{%><!--Assist. Registrar--><%}%></td>
			</tr>
		</table>	</td>
    <td align="center">
		<table width="75%" cellpadding="0" cellspacing="0">
      <tr>
        <td align="center" class="thinborderBottom">&nbsp;<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)).toUpperCase()%></td>
      </tr>
      <tr>
        <td align="center" class="thinborderNONE"> Registrar </td>
      </tr>
    </table>	</td>
  </tr>
  <tr valign="bottom">
    <td height="25">&nbsp;</td>
    <td>Loaded By: </td>
    <td>Reviewed and Endorsed for Approval: </td>
  </tr>
  <tr valign="bottom">
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr valign="bottom">
    <td height="25">&nbsp;</td>
    <td align="center">
		<table width="75%" cellpadding="0" cellspacing="0">
      <tr>
        <td align="center" class="thinborderBottom">&nbsp;<%=WI.getStrValue(vUserDetail.elementAt(10)).toUpperCase()%></td>
      </tr>
      <tr>
        <td align="center" class="thinborderNONE"> Dean/OIC </td>
      </tr>
    </table>	</td>
    <td align="center">
		<table width="75%" cellpadding="0" cellspacing="0">
      <tr>
        <td align="center" class="thinborderBottom">&nbsp;
				<%if(bolIsCavite){%>
					<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "Administrator",7)).toUpperCase()%>
				<%}else{%>
					<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "VPAA",7)).toUpperCase()%>
				<%}%></td>
      </tr>
      <tr>
        <td align="center" class="thinborderNONE"> 
					<%if(bolIsCavite){%>Administrator/Finance Officer<%}else{%>Vice-President for Academic Affairs<%}%> </td>
      </tr>
    </table>	</td>
  </tr>
  <tr valign="bottom">
    <td height="25">&nbsp;</td>
    <td>Accepted By: </td>
    <td>Approved By: </td>
  </tr>
  <tr valign="bottom">
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr valign="bottom">
    <td height="25">&nbsp;</td>
    <td align="center">
		<table width="75%" cellpadding="0" cellspacing="0">
			<tr>
				<td align="center" class="thinborderBottom">&nbsp;
				<%=WI.getStrValue(vUserDetail.elementAt(1)).toUpperCase()%>
				</td>
			</tr>
			<tr>
				<td align="center" class="thinborderNONE">Faculty</td>
			</tr>
		</table>	</td>
    <td align="center">
		<table width="75%" cellpadding="0" cellspacing="0">
			<tr>
				<td align="center" class="thinborderBottom">&nbsp;
				<%if(bolIsCavite){%>
					<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "VPAA",7)).toUpperCase()%>
				<%}else{%>
					<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "VPA",7)).toUpperCase()%>
				<%}%>
				</td>
			</tr>
			<tr>
				<td align="center" class="thinborderNONE">
				<%if(bolIsCavite){%>
					Vice-President for Academic Affairs  
				<%}else{%>
					Vice-President for Administration  
				<%}%>
				</td>
			</tr>
		</table>	</td>
  </tr>
</table>
  <%} else if (vRetSummaryLoad != null && strSchoolCode.startsWith("UI")) {%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td width="96%" height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="16"><div align="center"><strong><font size="2">SUMMARY 
        OF TEACHING LOAD</font></strong></div></td>
  </tr>
  <tr>
    <td height="15">&nbsp;</td>
  </tr>
</table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr> 
    <td width="56%" height="20" class="thinborder"><div align="center"><strong>COLLEGES 
        / DEPARTMENTS</strong></div></td>
    <td width="24%" class="thinborder"> <div align="center"><strong> 
        <%if(bolAllowLoadHour){%>
        NO OF UNITS
        <%}else{%>
        LOAD
        <%}%>
        </strong></div></td>
    <%if(bolAllowLoadHour){%>
    <td width="20%" class="thinborder"><div align="center"><strong>NO OF HOURS</strong></div></td>
    <%}%>
  </tr>
  <%  String[] astrConvertUnitType = {"unit(s)", "","",""};
  		dTotalLoadUnit = 0;
for (int j= 0; j < vRetSummaryLoad.size() ; j+=8){
	dTotalLoadUnit += Double.parseDouble((String)vRetSummaryLoad.elementAt(j+2));%>
  <tr> 
    <td height="20" class="thinborder">&nbsp;<%=(String)vRetSummaryLoad.elementAt(j) + 
	  			WI.getStrValue((String)vRetSummaryLoad.elementAt(j+1), " / ","","")%></td>
    <td class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetSummaryLoad.elementAt(j+2),true) + " " +  
	  			astrConvertUnitType[Integer.parseInt(WI.getStrValue((String)vRetSummaryLoad.elementAt(j+3),"3"))]%></td>
    <%if(bolAllowLoadHour){%>
    <td class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetSummaryLoad.elementAt(j+7),true)%></td>
    <%}%>
  </tr>
    <%} // end for loop 
if(bolAllowLoadHour){%>
  <tr>
    <td height="20" class="thinborder"><div align="right"><strong>TOTAL</strong> 
        &nbsp;&nbsp;&nbsp;</div></td>
    <td class="thinborder">&nbsp;<%=CommonUtil.formatFloat(dTotalLoadUnit,true)%></td>
    <td class="thinborder">&nbsp;<%=CommonUtil.formatFloat(dTotalLoadHour,true)%></td>
  </tr>
<%}%>
</table> 
  
  
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="20%">&nbsp;</td>
    <td>&nbsp;</td>
    <td width="32%">&nbsp;</td>
    <td width="5%" height="30">&nbsp;</td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td width="43%">&nbsp;</td>
    <td class="thinborderBottom"><div align="center"><strong><%=((String)vUserDetail.elementAt(1)).toUpperCase()%></strong></div></td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><div align="center">(Teacher's Signature over Printed Name)</div></td>
    <td><div align="center"></div></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="2">

  <tr align="center"> 
<% 
	int iMaxCount = Integer.parseInt(WI.getStrValue(request.getParameter("max_counter"),"0"));
	int iCount = 0;
	for (int j= 1; j < iMaxCount ; j++) {
		if (WI.fillTextValue("signatory"+j).length() > 0	
			&&  WI.fillTextValue("position"+j).length() > 0){
				iCount++;
%> 
    <td><strong><%=WI.fillTextValue("signatory"+j)%></strong></td>
<%  }
  } 
  // use for the width of the columsn.. 100% divided by number of items.. 
  iCount = 100 / iCount; 
  
%>
  </tr>
  <tr align="center"> 
<% 
	for (int j= 1; j < iMaxCount ; j++) {
		if (WI.fillTextValue("signatory"+j).length() > 0	
			&&  WI.fillTextValue("position"+j).length() > 0) {
%> 
    <td  width="<%=iCount%>%"><div align="center"><%=WI.fillTextValue("position"+j)%></div></td>
<%}
 }

%>
  </tr>  
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr valign="bottom"> 
    <td width="40%" height="20">&nbsp;</td>
    <td width="10%">&nbsp;</td>
    <td width="40%">&nbsp;</td>
    <td width="10%">&nbsp;</td>
  </tr>
  <tr valign="bottom"> 
    <td height="25">Reviewed by : &nbsp;&nbsp;_____________________________</td>
    <td>____________</td>
    <td>&nbsp;&nbsp;Approved by: _____________________________&nbsp;&nbsp;</td>
    <td><div align="center">____________</div></td>
  </tr>
  <tr> 
    <td><div align="center"><font size="2">&nbsp;&nbsp;&nbsp;&nbsp;<font size="1"><strong>MRS. BOBBIE 
        T. REYES</strong></font></font></div></td>
    <td><font size="1"><strong>Date </strong></font></td>
    <td><div align="center"><font size="1"><strong>&nbsp;&nbsp;&nbsp;FLOR AGNES L. SY, Ph.D </strong></font></div></td>
    <td><font size="1"><strong>Date</strong></font></td>
  </tr>
  <tr> 
    <td><div align="center">Director, HRM</div></td>
    <td>&nbsp;</td>
    <td><div align="center">Vice President for Academic Affairs</div></td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td valign="bottom">Received by : &nbsp;&nbsp;_____________________________</td>
    <td valign="bottom">____________</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td><div align="center"><font size="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="1"><strong>&nbsp;Accounting 
        Department</strong></font></font></div></td>
    <td><font size="1"><strong>Date</strong></font></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<%}else if (strSchoolCode.startsWith("NEU")) {%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0">
 	 <tr>
  		<td colspan="5">WORK/TEACHING LOAD OUTSIDE NEU:</td>
  	</tr>
	<tr>
		<td width="23%" align="center">OFFICE/SCHOOL</td>
		<td width="17%" align="center">TEL. NO.</td>
		<td width="21%" align="center">NATURE OF WORK</td>
		<td width="14%" align="center">DAYS/ TIME</td>
		<td width="25%" align="center">TOTAL HOURS/ WEEK</td>
	</tr>
	<tr>
	    <td valign="bottom" height="25"><div style="border-bottom:solid 1px #000000; margin-right:10px;">&nbsp;</div></td>
		<td valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; margin:0 10px 0 10px;">&nbsp;</div></td>
		<td valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; margin:0 10px 0 10px;">&nbsp;</div></td>
		<td valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; margin:0 10px 0 10px;">&nbsp;</div></td>
		<td valign="bottom"><div style="border-bottom:solid 1px #000000; margin-left:10px;">&nbsp;</div></td>
	</tr>
	<tr>
	    <td valign="bottom" height="25"><div style="border-bottom:solid 1px #000000; margin-right:10px;">&nbsp;</div></td>
		<td valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; margin:0 10px 0 10px;">&nbsp;</div></td>
		<td valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; margin:0 10px 0 10px;">&nbsp;</div></td>
		<td valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; margin:0 10px 0 10px;">&nbsp;</div></td>
		<td valign="bottom"><div style="border-bottom:solid 1px #000000; margin-left:10px;">&nbsp;</div></td>
	</tr>
</table>
 <table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="5">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="5" style="text-indent:50px;" align="justify"> IN ADDITION TO THE FOREGOING, I further certify that during my full-time employment at the New Era University, I will first inform the University before I will accept any work with any school, company or institution, whether full-time or part-time so that it can change my status, if necessary. Should I fail to observe this, I am willing to abide by any disciplinary measure or action to be imposed by New Era University including, but not limited to, reimbursement or return of the monetary benefit I received.</td>
	</tr>
	<tr>
		<td colspan="5" height="20">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="5" valign="bottom" align="center">
		    <table width="100%" border="0" cellpadding="0" cellspacing="0">
			   <tr>
			   		<td width="47%" height="25" align="center" valign="bottom">
				 <div style="border-bottom:solid 1px #000000; width:30%;"><%=WI.getTodaysDate(6)%></div></td>
		   		 <td width="53%" align="center" valign="bottom">
				 <div style="border-bottom:solid 1px #000000; width:60%;">&nbsp;</div>
				 </td>	
			   </tr>
			    <tr>
			   		<td align="center" height="25">Date</td>
			   		<td align="center">Signature</td>	
			   </tr>
			</table>
		</td>
	</tr>
	<tr>
		<td colspan="3"><div style="border-bottom: solid 1px #000000;"></div></td>
	</tr>
	<tr>
		<td height="25"><strong>Attested to:</strong></td>
		<td><strong>Noted:</strong></td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td colspan="3" height="30">&nbsp;</td>
	</tr>
	
			   <tr>
			   	 <td width="33%" height="25" valign="bottom">
				 <div style="border-bottom:solid 1px #000000; width:90%">&nbsp;</div></td>
		   		 <td align="center" valign="bottom">
				 <div style="border-bottom:solid 1px #000000; width:90%;">&nbsp;</div>
				 </td>	
				 <td align="center" valign="bottom"width="33%">
				 <div style="border-bottom:solid 1px #000000; width:90%">&nbsp;</div>
				 </td>
			   </tr>
			    <tr>
			   		<td align="center" height="0">Principal / Dean</td>
			   		<td align="center">Personel Officer</td>	
					<td align="center">President</td>	
			   </tr>
			
 </table> 
<%}
}//if vRetResult != null%>
</body>
</html>
<%
dbOP.cleanUP();
%>