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
	TD.thinborder9{
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
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
 
 String strRemarks = "PASSED";
%>
<table width="1130" border="0" cellpadding="0" cellspacing="0">
  <% if (bolError || vRetResult == null || vRetSubjects == null || vRetResult.size()==0 || vRetSubjects.size() == 0) { %>
  <tr> 
    <td colspan="<%=6+3*iNumSubjects%>">&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="<%=6+3*iNumSubjects%>">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
  </tr>
  <%}else{%>
  <tr> 
    <td colspan="<%=6+3*iNumSubjects%>"> <div align="center"> 
        <p><strong><font size="2"><%=strSchoolName%></font></strong> <font size="2"><br>
          <strong><%=strCollegeName%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>, <%=strAddressLine2%></font><br>
          <strong><br>
          <font size="2">SUMMARIZED RATING REPORT</font></strong> 
          <% if (strDegreeType.compareTo("4") == 0){%>
        <p> <font size="2"><strong><%=astrConvSem[Integer.parseInt(WI.fillTextValue("semester"))] + " " + WI.fillTextValue("sy_from") +"-" + WI.fillTextValue("sy_to")%></strong></font> </p>
        <%}%>
      </div></td>
  </tr>
  <tr valign="top"> 
    <td  height="19" class="subheader" colspan="<%=6+3*iNumSubjects%>"><strong>COURSE:</strong> 
      <%=dbOP.mapOneToOther("course_offered", "course_index" , WI.fillTextValue("course_index"),"course_name",null)%></td>
  </tr>
  <tr valign="top"> 
    <td  height="20" class="subheader" colspan="<%=6+3*iNumSubjects%>"><strong>SCHOOL:</strong><%=strSchoolName%> 
    </td>
  </tr>
  <%}

 if (!bolError && vRetResult!= null && vRetSubjects!= null && vRetResult.size()!=0 && vRetSubjects.size() != 0) { %>
  <tr> 
    <td height="24" class="thinborderALL" colspan="<%=6+3*iNumSubjects%>"><div align="center"><font size="2"><strong>SUBJECTS</strong></font></div></td>
  </tr>
  <% if (!bolError && vRetSubjects!=null) %>
  <tr> 
   <td class="thinborder">&nbsp;</td>
    <td colspan="3" class="thinborder"><div align="center"><font size="1">NAME 
        OF STUDENT</font></div></td>
    <td width="94" rowspan="2" class="thinborder"><div align="center"><font size="1">HOME 
        ADDRESS</font></div>
      <div align="center"></div></td>
    <%for (iIndex = 0 ; iIndex < vRetSubjects.size(); iIndex+=6){%>
    <td colspan="3" class="thinborder"><div align="center"><font size="1"><%=(String)vRetSubjects.elementAt(iIndex)%></font></div></td>
    <%}%>
    <td class="thinborderLRB">&nbsp;</td>
  </tr>
  <tr> 
    <td width="25" class="thinborder"><div align="center">NO.</div></td>
    <td width="111" class="thinborder"><div align="center">FAMILY NAME</div></td>
    <td width="103" class="thinborder">FIRST NAME</td>
    <td width="33" class="thinborder"><div align="center">M.I.</div></td>
    <%for (iIndex = 0 ; iIndex < iNumSubjects; iIndex++){%>
    <td width="27" class="thinborder"><div align="center">Final Rating</div></td>
    <td width="59" class="thinborder">No. of Hours</td>
    <td width="67" class="thinborder"><div align="center">Credit Unit</div></td>
    <%}%>
    <td width="194" class="thinborderLRB"><div align="center">REMARKS</div></td>
  </tr>
  <% int iCtr = 1;
  	 int k = 0;
	 int iMaxRows = 18;
	 int iRows = 1;
	 
  	for (iIndex = 0; iIndex < vRetResult.size() ;iCtr++,iRows++){ %>
	
  <tr> 
    <td height="25" class="thinborder9"><%=iCtr%></td>
    <td class="thinborder9"><div align="center"><%=(String)vRetResult.elementAt(iIndex+4)%></div></td>
    <td class="thinborder9"><%=(String)vRetResult.elementAt(iIndex+2)%></td>
    <td class="thinborder9"><div align="center"><%=((String)vRetResult.elementAt(iIndex+3))%></div></td>
    <td class="thinborder9"><div align="center"><%=WI.getStrValue((String)vRetResult.elementAt(iIndex+5),"")+WI.getStrValue((String)vRetResult.elementAt(iIndex+6),",","","")+WI.getStrValue((String)vRetResult.elementAt(iIndex+7),",","","&nbsp;")%></div></td>
    <%	
	for (k=0,iIndex+=9;k<iNumSubjects && iIndex < vRetResult.size();iIndex+=4,k++) {	
%>
    <td class="thinborder9"><%=WI.getStrValue((String)vRetResult.elementAt(iIndex),"-")%></td>
    <td class="thinborder9"><%=WI.getStrValue((String)vRetResult.elementAt(iIndex+3),"-")%></td>
    <td class="thinborder9"><%=WI.getStrValue((String)vRetResult.elementAt(iIndex+2),"-")%></td>
    <%} //iIndex -=4;//end of inner for loop %>
    <td class="thinborderLRB"><%=strRemarks%></td>
  </tr>
  <%	}// end for loop%>
  <tr> <td height="25" colspan="<%=6+3*iNumSubjects%>" class="thinborderLRB"><div align="center">xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</div></td></tr>  
  <%   while(iRows < iMaxRows){%>
     <tr> 
    <td height="25" class="thinborder">&nbsp;</td>
    <td width="111" class="thinborder">&nbsp;</td>
    <td width="103" class="thinborder">&nbsp;</td>
    <td width="33" class="thinborder">&nbsp;</td>
    <td width="94" class="thinborder">&nbsp;</td>
	<%for (iIndex = 0 ; iIndex < iNumSubjects; iIndex++){%>
    <td width="27" class="thinborder">&nbsp;</td>
    <td width="59" class="thinborder">&nbsp;</td>
    <td width="67" class="thinborder">&nbsp;</td>
    <%}%>
    <td width="194" class="thinborderLRB">&nbsp;</td>
  </tr>
  <%iRows++;}%>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
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
</table>
<script language="JavaScript">
window.print();
</script>
<%}//(bolError || vRetResult == null || vRetSubjects == null || vRetResult.size()==0 || vRetSubjects.size() == 0) %>

</body>
</html>
