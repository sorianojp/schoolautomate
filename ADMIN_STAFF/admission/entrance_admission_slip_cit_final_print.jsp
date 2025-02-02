<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Admission</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">

<style type="text/css">
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TABLE.thinborderall {
    border: solid 1px #000000;
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
	font-size: 11px;
    }
</style>
</head>
<script language="javascript">
function PrintPage(){
	document.getElementById('header').deleteRow(5);
	window.print();	
}
</script>
<%@ page language="java" import="utility.*,enrollment.OfflineAdmission,java.util.Vector,enrollment.CourseRequirement"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;	
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Registration","entrance_admission_slip_new_print_cit.jsp");
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
														"Admission","Registration",request.getRemoteAddr(),null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"ADMISSION MAINTENANCE","ADMISSION SLIP",request.getRemoteAddr(),null);
}														
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
	String strTempID = WI.fillTextValue("temp_id");
	OfflineAdmission offlineAdd = new OfflineAdmission();
	enrollment.CourseRequirement cRequirement = new enrollment.CourseRequirement();
	enrollment.ApplicationMgmt applMgmt = new enrollment.ApplicationMgmt();
	
	Vector vRetResult = null;
	Vector vExamsPassed = null,vPendingRequirement = null;
	String strSYFrom = null;
	String strSYTo = null;
	String strSemester=null;
	String[] astrSemester = {"Summer", " 1st Semester ", "2nd Semester", "3rd Semester "};
	String[] astrPeriod = {"AM","PM"};
	
	strTempID = dbOP.mapOneToOther("NEW_APPLICATION", "TEMP_ID", 
           "'"+strTempID+"'","TEMP_ID", "");		
	
	if (strTempID != null){		
		vRetResult = offlineAdd.createAdmissionSlipReq(dbOP,strTempID);
		if (vRetResult == null)
			strErrMsg = offlineAdd.getErrMsg();	
		else {				
			strSYFrom = (String)vRetResult.elementAt(0);
			strSYTo = (String)vRetResult.elementAt(1);
			strSemester = (String)vRetResult.elementAt(12);
		
			vExamsPassed = offlineAdd.getExamResults(dbOP,request,strTempID);
			
			Vector vAdmissionReq = cRequirement.getStudentPendingCompliedList(dbOP,(String)vRetResult.elementAt(16),
					  strSYFrom,strSYTo,strSemester,true,true,true);//get both pending and complied list
			if(vAdmissionReq == null && strErrMsg == null)
					strErrMsg = cRequirement.getErrMsg();
			else 
				vPendingRequirement = (Vector)vAdmissionReq.elementAt(0);
		}	 		 			
	}
	else	    
		strErrMsg = "Invalid Temporary ID";
	
	
	String strApplicationStat = WI.fillTextValue("adm_stat");
	String strContentDisplay  = null;
	if(strApplicationStat.length() > 0) {
		strContentDisplay = "select status, DISPLAY_INFO from NA_ADMISSION_APPL_STAT_PRELOAD where STAT_INDEX = "+strApplicationStat;
		java.sql.ResultSet rs = dbOP.executeQuery(strContentDisplay);strContentDisplay = null;
		if(rs.next()) {
			strApplicationStat = rs.getString(1);
			strContentDisplay  = rs.getString(2);
		}rs.close();
	}
%>
<body bgcolor="#FFFFFF" onLoad="<%if(strErrMsg == null) {%>window.print()<%}%>">

<%if(strErrMsg != null){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="18"><font size="3"><strong><%=strErrMsg%></strong></font></td>
    </tr>
  </table>
<%}%>
<%if(strErrMsg == null){%>
    <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="2%" height="2">&nbsp;</td>
        <td width="98%" align="center">
		<font size="3"><strong><%=SchoolInformation.getSchoolName(dbOP,false,false)%></strong></font>
		<br>
		<font size="2"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>		
		<div align="right" style="font-size:22px; font-weight:bold; position:absolute; right:1px; top:10px;">Confidential</div>
		
		</td>
      </tr>
      <tr>
        <td height="2">&nbsp;</td>
        <td align="center" style="font-weight:bold;">BOARD OF ADMISSIONS </td>
      </tr>
      <tr>
        <td height="2">&nbsp;</td>
        <td align="center" style="font-weight:bold;">&nbsp;</td>
      </tr>
      <tr>
        <td height="2">&nbsp;</td>
        <td>
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td width="43%">Student ID No&nbsp;&nbsp;&nbsp;&nbsp;: <b><%=strTempID%></b></td>
					<td width="21%">Status: <b><%=WI.getStrValue((String)vRetResult.elementAt(2))%></b></td>
					<td width="36%">Term & SY: <b><%=astrSemester[Integer.parseInt(strSemester)]%>, <%=strSYFrom%>-<%=strSYTo.substring(2)%></b></td>
				</tr>
				<tr>
				  <td>Name of Student: <b><%=WI.getStrValue((String)vRetResult.elementAt(7))%></b></td>
				  <td>Course &amp; Year: <b><%=WI.getStrValue((String)vRetResult.elementAt(9))%><%=WI.getStrValue((String)vRetResult.elementAt(10),"(",")","")%> - <%=WI.getStrValue((String)vRetResult.elementAt(17), "N/A")%></b></td>
		          <td width="36%">Admission Status: <b><%=strApplicationStat%></b></td>
			  </tr>
			  <%if(WI.fillTextValue("hide_exam").length() == 0) {%>
				<tr>
				  <td height="25" style="font-size:13px; font-weight:bold">TEST RESULTS : 
				    <%if(vExamsPassed != null && vExamsPassed.size() > 0) {%>
				  	<%=((String)vExamsPassed.elementAt(0)).toUpperCase()%>: <%=WI.getStrValue(applMgmt.convertTestScore(dbOP,(String)vExamsPassed.elementAt(0+2), (String)vExamsPassed.elementAt(0+1)),"xxxxx").toUpperCase()%>
				  <%vExamsPassed.remove(0);vExamsPassed.remove(0);vExamsPassed.remove(0);vExamsPassed.remove(0);}%>				  </td>
				  <td height="25" style="font-size:13px; font-weight:bold">
				    <%if(vExamsPassed != null && vExamsPassed.size() > 0) {%>
				  	<%=((String)vExamsPassed.elementAt(0)).toUpperCase()%>: <%=WI.getStrValue(applMgmt.convertTestScore(dbOP,(String)vExamsPassed.elementAt(0+2), (String)vExamsPassed.elementAt(0+1)),"xxxxx").toUpperCase()%>
				  <%vExamsPassed.remove(0);vExamsPassed.remove(0);vExamsPassed.remove(0);vExamsPassed.remove(0);}%>				  </td>
		          <td width="36%" height="25" style="font-size:13px; font-weight:bold">
				    <%if(vExamsPassed != null && vExamsPassed.size() > 0) {%>
				  	<%=((String)vExamsPassed.elementAt(0)).toUpperCase()%>: <%=WI.getStrValue(applMgmt.convertTestScore(dbOP,(String)vExamsPassed.elementAt(0+2), (String)vExamsPassed.elementAt(0+1)),"xxxxx").toUpperCase()%>
				  <%vExamsPassed.remove(0);vExamsPassed.remove(0);vExamsPassed.remove(0);vExamsPassed.remove(0);}%>				  </td>
			  </tr>
			  <%}else{%>
				<tr>
				  <td height="10" style="font-size:13px; font-weight:bold">&nbsp;</td>
				  <td  style="font-size:13px; font-weight:bold">&nbsp;</td>
				  <td style="font-size:13px; font-weight:bold">&nbsp;</td>
			  </tr>
			  <%}%>
			</table>		</td>
      </tr>
    </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="header">
    <tr> 
      <td width="18" height="25">&nbsp;</td>
      <td height="25" colspan="2">
	  <%if(!WI.getStrValue((String)vRetResult.elementAt(2)).toLowerCase().startsWith("t") && strContentDisplay != null){
	  	if(WI.getStrValue((String)vRetResult.elementAt(2)).toLowerCase().startsWith("cross") && strContentDisplay.length() > 0) {
			if(strContentDisplay.startsWith("Congra"))
				strContentDisplay = strContentDisplay.substring(17);
		}
	  	%>
	  	<%=WI.getStrValue(strContentDisplay)%>
	  <%}%>
	  </td>
    </tr>
    
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">
		  <table width="100%" cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td width="60%" valign="top">
					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td colspan="6">Approved <%if(!strApplicationStat.startsWith("F")){%>for Enrollment<%}%> by: </td>
						</tr>
						<tr>
						  <td colspan="6">&nbsp;</td>
					  </tr>
						<tr>
						  <td width="31%" class="thinborderBottom">&nbsp;</td>
					      <td width="2%">&nbsp;</td>
					      <td width="31%" class="thinborderBottom">&nbsp;</td>
					      <td width="2%">&nbsp;</td>
					      <td width="31%" class="thinborderBottom">&nbsp;</td>
					      <td width="2%">&nbsp;</td>
					  </tr>
						<tr align="center">
						  <td>OAS</td>
						  <td>&nbsp;</td>
						  <td>SAO</td>
						  <td>&nbsp;</td>
						  <td>Dept Chair </td>
						  <td>&nbsp;</td>
					  </tr>
					</table>
				</td>
				<td valign="top">
					<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborderall">
						<%if(vPendingRequirement == null || vPendingRequirement.size() == 0) {%>
						<tr> 
							<td> <strong>- Complete Requirements -</strong> </td>
						</tr>
						<%}else{%>
							<tr>
								<td><u><strong>Lacking Requirements:</strong></u></td>
							</tr>
							<% for(int i = 0 ; i< vPendingRequirement.size(); i +=5){%>
								<tr> 
								  <td><%=(String)vPendingRequirement.elementAt(i+1)%></td>
								</tr>
							<%} //end for loop%>
						<%}%>
					</table>
				</td>
			</tr>	  
		  </table>
	  </td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td width="432" height="18">Prepared by: <b><%=(String)request.getSession(false).getAttribute("first_name")%></b></td>
      <td width="398" height="18" align="right" style="font-weight:bold"><%=WI.getTodaysDate(6)%></td>
    </tr>
  </table>
<%}%>
</body>
</html>
<% 
dbOP.cleanUP();
%>