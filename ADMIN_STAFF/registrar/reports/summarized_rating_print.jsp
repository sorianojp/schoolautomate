<cfprocessingdirective pageEncoding="iso-8859-1">
<cfcontent type="text/html; charset=iso-8859-1">
<cfset setEncoding("URL", "iso-8859-1")>
<cfset setEncoding("FORM", "iso-8859-1")>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Summarized Rating Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td.subheader {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}	

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
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
	font-size: 8px;
    }
    TD.thinborderALL {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
    }
    TD.thinborderLRB {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
    }

-->
</style>
</head>

<body leftmargin="1" topmargin="0">
<%@ page language="java" import="utility.*,enrollment.ReportRegistrar,enrollment.CurriculumMaintenance,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-TESDA Reports","summarized_rating_print.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","REPORTS",request.getRemoteAddr(), 
														"summarized_rating_print.jsp");	
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

// end of authentication

String strCollegeName = new enrollment.CurriculumMaintenance().getCollegeName(dbOP,WI.fillTextValue("course_index"));
String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strAddressLine2 = SchoolInformation.getAddressLine2(dbOP,false,false);
String[] astrConvSem = {"SUMMER", "1ST SEMESTER", "2nd SEMESTER", "3RD SEMESTER"};

if (strAddressLine2 != null){
	int iIndex = strAddressLine2.indexOf(" ");
	
	if (iIndex != -1)
		strAddressLine2 = strAddressLine2.substring(0,iIndex);
}

ReportRegistrar rr = new ReportRegistrar();
Vector vRetSubjects = null;
Vector vRetResult = null;
boolean bolError = false;
int iNumSubjects = 0;
int iIndex = 0;

vRetSubjects = rr.viewGraduatingSubjects(dbOP,request);

String strDegreeType = WI.fillTextValue("degree_type");


if (vRetSubjects == null || vRetSubjects.size() == 0){
	bolError = true;
	strErrMsg = rr.getErrMsg();
}else{
	iNumSubjects = vRetSubjects.size() / 6;
}
if (!bolError){
	vRetResult = rr.viewSummarizedRating(dbOP,request,vRetSubjects);
	
	if (vRetResult == null || vRetResult.size() == 0){
		bolError = true;	
		strErrMsg = rr.getErrMsg();
	}

 }
%>
<table width="1125" border="0" cellpadding="0" cellspacing="0">
<% if (bolError || vRetResult == null || vRetSubjects == null || vRetResult.size()==0 || vRetSubjects.size() == 0) { %>
  <tr>
    <td colspan="<%=5+4*iNumSubjects%>">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="<%=5+4*iNumSubjects%>">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
  </tr>
<%}else{%>
  <tr> 
    <td colspan="<%=5+4*iNumSubjects%>"> <div align="center"> 
        <p><strong><font size="2"><%=strSchoolName%></font></strong> <font size="2"><br>
          <strong><%=strCollegeName%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>, <%=strAddressLine2%></font><br>
          <strong><br>
          <font size="2">SUMMARIZED RATING REPORT</font></strong>
<% if (strDegreeType.compareTo("4") == 0){%>
<p>
<%=astrConvSem[Integer.parseInt(WI.fillTextValue("semester"))] + " " + WI.fillTextValue("sy_from") +"-" + WI.fillTextValue("sy_to")%>
</p>
<%}%>
		  
		  
		  </div></td>
  </tr>
  <tr valign="top"> 
    <td  height="20" class="subheader" colspan="<%=5+4*iNumSubjects%>"><strong>COURSE:</strong> <%=dbOP.mapOneToOther("course_offered", "course_index" , WI.fillTextValue("course_index"),"course_name",null)%></td>
  </tr>
  <tr valign="top"> 
    <td  height="20" class="subheader" colspan="<%=5+4*iNumSubjects%>"><strong>SCHOOL:</strong><%=strSchoolName%> </td>
  </tr>
<%}

 if (!bolError && vRetResult!= null && vRetSubjects!= null && vRetResult.size()!=0 && vRetSubjects.size() != 0) { %>
  <tr> 
    <td height="24" class="thinborderALL" colspan="<%=5+4*iNumSubjects%>"><div align="center"><font size="2"><strong>SUBJECTS</strong></font></div></td>
  </tr>
<% if (!bolError && vRetSubjects!=null) %>
  <tr> 
    <td class="thinborder">&nbsp; </td>
    <td colspan="3" class="thinborder"><div align="center"><font size="1">NAME 
        OF STUDENT</font></div></td>
    <td class="thinborder"><div align="center"><font size="1">HOME ADDRESS</font></div></td>
    <%for (iIndex = 0 ; iIndex < vRetSubjects.size(); iIndex+=6){%>
    <td colspan="4" class="thinborderLRB"><div align="center"><font size="1"><%=(String)vRetSubjects.elementAt(iIndex)%></font></div></td>
    <%}%>
  </tr>
  <tr> 
    <td width="35" class="thinborder"><div align="center">NO.</div></td>
    <td width="100" class="thinborder"><div align="center">FAMILY NAME</div></td>
    <td width="100" class="thinborder">FIRST NAME</td>
    <td width="35" class="thinborder"><div align="center">M.I.</div></td>
    <td width="200" class="thinborder"><div align="center">HOUSE. NO. ST BRGY 
        MUNICIPALITY</div></td>
    <%for (iIndex = 0 ; iIndex < iNumSubjects; iIndex++){%>
    <td width="30" class="thinborder"><div align="center">Final Rating</div></td>
    <td width="38" class="thinborder">Action Taken</td>
    <td width="33" class="thinborder">No. of Hours</td>
    <td width="44" class="thinborderLRB"><div align="center">Credit Unit</div></td>
    <%}%>
  </tr>
  <% int iCtr = 1;
  	 int k = 0;
	 
  	for (iIndex = 0; iIndex < vRetResult.size() ;iCtr++){ %>
  <tr> 
    <td height="24" class="thinborder">&nbsp;<%=iCtr%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(iIndex+4)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(iIndex+2)%></td>
    <td class="thinborder"><div align="center"><%=((String)vRetResult.elementAt(iIndex+3))%></div></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(iIndex+5),"")+WI.getStrValue((String)vRetResult.elementAt(iIndex+6),",","","")+WI.getStrValue((String)vRetResult.elementAt(iIndex+7),",","","&nbsp;")%></td>
<%	
	for (k=0,iIndex+=9;k<iNumSubjects && iIndex < vRetResult.size();iIndex+=4,k++) {	
%>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(iIndex),"-")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(iIndex+1),"-")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(iIndex+2),"-")%></td>
    <td class="thinborderLRB"><%=WI.getStrValue((String)vRetResult.elementAt(iIndex+3),"-")%></td>
<%} //iIndex -=4;//end of inner for loop %>
  </tr>
 <%	}// end for loop%>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <% if (strDegreeType.compareTo("4") != 0){%>
  <tr> 
    <td width="2%">&nbsp; </td>
    <td width="28%"><font size="1">Certified Correct:</font></td>
    <td width="28%"><font size="1">Attested by:</font></td>
    <td width="28%">&nbsp;</td>
    <td width="14%">&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="5">&nbsp;</td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td><div align="center"><u><font size="1">____<%=WI.fillTextValue("certified")%>____</font></u></div></td>
    <td><div align="center"><u><font size="1">___<%=WI.fillTextValue("attested")%>___</font></u></div></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td><div align="center"><font size="1"><%=WI.fillTextValue("designation1")%></font></div></td>
    <td><div align="center"><font size="1"><%=WI.fillTextValue("designation2")%></font></div></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <%}else{%>
  <tr> 
    <td width="2%">&nbsp; </td>
    <td width="28%"><font size="1">Prepared by:</font></td>
    <td width="28%"><font size="1">Noted by:</font></td>
    <td width="28%"><font size="1">Certified Correct:</font></td>
    <td width="14%">&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="5">&nbsp;</td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td><div align="center"><u><font size="1">____<%=WI.fillTextValue("prepared")%>____</font></u></div></td>
    <td><div align="center"><u><font size="1">___<%=WI.fillTextValue("noted")%>___</font></u></div></td>
    <td><div align="center"><u><font size="1">___<%=WI.fillTextValue("certified")%>___</font></u></div></td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td><div align="center"><font size="1"><%=WI.fillTextValue("designation")%></font></div></td>
    <td><div align="center"><font size="1"><%=WI.fillTextValue("designation3")%></font></div></td>
    <td><div align="center"><font size="1"><%=WI.fillTextValue("designation4")%></font></div></td>
    <td>&nbsp;</td>
  </tr>
  <%}%>
</table>
<script language="JavaScript">
window.print();
</script>
<%}//(bolError || vRetResult == null || vRetSubjects == null || vRetResult.size()==0 || vRetSubjects.size() == 0) %>

</body>
</html>
