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

td {
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
	font-size: 10px;
    }
    .thinborderALL {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
	border-top: 1px solid #000000;
	border-right: 1px solid #000000;
	border-bottom: 1px solid #000000;
	border-left: 1px solid #000000;
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
<%@ page language="java" import="utility.*,enrollment.GraduationDataReport, enrollment.EntranceNGraduationData,java.util.Vector, java.util.Date,java.util.StringTokenizer" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp =  null;
	String strErrMsg = null;

	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester","5th Semester"};
	String[] astrConvYrLevel = {"short-term","1st-year", "2nd-year", "3rd-year"};

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

GraduationDataReport gdr = new GraduationDataReport(request);

Vector vRetResult = null;
int iCount = 1;

boolean bolError = false;

vRetResult = gdr.viewAllGraduates(dbOP);

if (vRetResult == null || vRetResult.size() == 0){
	strErrMsg = gdr.getErrMsg();
	bolError = true;
}
%>
	
<table width="1000" border="0" cellpadding="0" cellspacing="0">
  <% if (bolError || vRetResult == null || vRetResult.size()==0) { %>
  <tr> 
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td>&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
  </tr>
  <%}else{%>
  <tr>
  	<td>&nbsp;
	</td>
  </tr>
  <tr> 
    <td> <div align="center"> 
        <p><strong><font size="2">Republic of the Philippines</font></strong> 
          <br>
          <font size="2"> <strong>TECHNICAL EDUCATIONAL AND SKILLS DEVELOPMENT 
          AUTHORITY</strong><br>
          </font> <strong><br>
          <font size="2">TERMINAL REPORT</font><font size="3"><br>
          </font></strong>
        </div>
      <table width="1125" border="0" cellpadding="0" cellspacing="0" class="thinborder">
        <tr> 
          <td width="17%" rowspan="2" valign="top" class="thinborder"><p>Major 
              Classification<br>
              Course Level<br>
              Program Level<br>
              Venue:<br>
              Municipality/Province:<br>
              <font size=1><strong><%=WI.fillTextValue("mun_prov")%></strong></font><br>
            </p></td>
          <td width="5%" rowspan="2" valign="top" class="thinborder">Code No.</td>
          <td width="22%" valign="top" class="thinborder">Program/Course Title:<br> 
            <strong><%=dbOP.mapOneToOther("course_offered", "is_del","0","course_name"," and course_index =" + WI.fillTextValue("course_index"))%></strong> <br> </td>
          <td width="11%" rowspan="2" valign="top" class="thinborder">Training 
            Cost<br>
            A. TESDA<br>
            B. Other Agency/ies<br>
            1. P <br>
            2. P<br>
            3. P</td>
          <td width="6%" rowspan="2" valign="top" class="thinborder"><div align="center">Number 
              of Graduates:<br>
              <br>
              <strong><%=Integer.parseInt((String)vRetResult.elementAt(1)) +
									Integer.parseInt((String)vRetResult.elementAt(0))%> </strong></div></td>
          <td width="11%" valign="top" class="thinborder">Date of Start</td>
          <td width="12%" rowspan="2" valign="top" class="thinborder">No. of Training 
            Hours:<br>
            Lecture : <br>
            Practicum : </td>
          <td width="16%" rowspan="2" valign="top" class="thinborder">Instructor's Name:<br>
          </td>
        </tr>
        <tr> 
          <td valign="top" class="thinborder">Specific Training Site:<br> <strong><%=SchoolInformation.getSchoolName(dbOP,false, false)%></strong> <br> <strong><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></strong> </td>
          <td valign="top" class="thinborder">Date of Finish</td>
        </tr>
      </table>
	</td>
  </tr>
</table>
<%  int iCountLeft = 1; 
	int iCountRight =0;
	int k = 0 ;
	int i = 0 ;
	int iMaxStudPerPage = 19;   // set to max student for first page
	int iMaxStudPerPage2 = 26;
	if (vRetResult.size() > iMaxStudPerPage){
		k = (iMaxStudPerPage-1) * 17 + 2;   // +2 -> male and female count
	}
	
	for (i=2; i < vRetResult.size();){
		iCountLeft = iCountRight;
		iCountRight = iCountLeft + iMaxStudPerPage;
		if(iCountLeft == 0 )  {
			iCountLeft++;
			iCountRight = iCountLeft + iMaxStudPerPage -1;
		}

		
%>
<table width="1125" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr> 
    <td colspan="4" class="thinborder"><div align="center">GRADUATES</div></td>
    <td colspan="4" class="thinborder"><div align="center">GRADUATES</div></td>
    <td colspan="4" class="thinborder"><div align="center">DROP OUT</div></td>
    <td colspan="4" class="thinborder"><div align="center">DROP OUT</div></td>
  </tr>
  <tr> 
    <td class="thinborder">No.</td>
    <td class="thinborder"><div align="center">Last Name</div></td>
    <td class="thinborder"><div align="center">First Name</div></td>
    <td class="thinborder"><div align="center">MI.</div></td>
    <td class="thinborder">No.</td>
    <td class="thinborder"><div align="center">Last Name</div></td>
    <td class="thinborder"><div align="center">First Name</div></td>
    <td class="thinborder"><div align="center">M.I.</div></td>
    <td class="thinborder">No.</td>
    <td class="thinborder"><div align="center">Last Name</div></td>
    <td class="thinborder"><div align="center">First Name</div></td>
    <td class="thinborder"><div align="center">M.I.</div></td>
    <td class="thinborder">No.</td>
    <td class="thinborder"><div align="center">Last Name</div></td>
    <td class="thinborder"><div align="center">First Name</div></td>
    <td class="thinborder"><div align="center">M.I.</div></td>
  </tr>
<% 	
	for (; i < vRetResult.size();i+=17,k+=17){
	
		if (iCount == iMaxStudPerPage) { 
			i = k ;
			iMaxStudPerPage = iMaxStudPerPage2 ;
			k = ((iMaxStudPerPage) * 17 + i);
			iCount = 0;
			break;
		} 
	iCount++;
%>
  <tr> 
    <td class="thinborder" height="25"><%=iCountLeft++%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
    <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+4)," ").charAt(0)%></div></td>
    <% if (k+5 < vRetResult.size()) 
		strTemp =  Integer.toString(iCountRight++);
	else
		strTemp = "&nbsp;";
%>
    <td class="thinborder">&nbsp;<%=strTemp%></td>
    <% if (k+5 < vRetResult.size()) {
	strTemp = (String)vRetResult.elementAt(k+5); }else{ strTemp = "&nbsp";} %>
    <td class="thinborder"><%=strTemp%></td>
    <% if (k+3 < vRetResult.size()) {
	strTemp = (String)vRetResult.elementAt(k+3); }else{ strTemp = "&nbsp";} %>
    <td class="thinborder"><%=strTemp%></td>
    <% if (k+4 < vRetResult.size()) {
	strTemp = String.valueOf(WI.getStrValue((String)vRetResult.elementAt(k+4)," ").charAt(0));
	
	 }else{ strTemp = "&nbsp";} %>
    <td class="thinborder"><div align="center"><%=strTemp%></div></td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <% if (k+16 < vRetResult.size()) {
	strTemp = (String)vRetResult.elementAt(k+16); }else{ strTemp = "&nbsp";} %>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
  </tr>
  <% } // end inner loop %>
</table>

<% if ( i < vRetResult.size()) { %>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}
} //end outer for loop  
%>
<table width="1125" cellpadding="0" cellspacing="0" >
  <tr> 
    <td width="22%" rowspan="4" valign="top"><font size="1">1.) For Head Provincial 
      Office if benefeciary-based please write the title of the program</font></td>
    <td width="20%"><font size="1">&nbsp;&nbsp;2) Prepared by </font></td>
    <td width="20%"><font size="1">Noted by:</font></td>
    <td width="20%"><font size="1">Certified Correct by</font></td>
    <td width="18%"><font size="1">Date prepared:</font></td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td><div align="center"><u><font size="1">____<%=WI.fillTextValue("prepared")%>____</font></u></div></td>
    <td><div align="center"><u><font size="1">____<%=WI.fillTextValue("certified")%>____</font></u></div></td>
    <td>
<div align="center"><u><font size="1">___<%=WI.fillTextValue("attested")%>___</font></u></div></td>
    <td>&nbsp;<%=WI.getTodaysDate()%></td>
  </tr>
  <tr> 
    <td><div align="center"><font size="1"><%=WI.fillTextValue("designation3")%></font></div></td>
    <td><div align="center"><font size="1"><%=WI.fillTextValue("designation1")%></font></div></td>
    <td><div align="center"><font size="1"><%=WI.fillTextValue("designation2")%></font></div></td>
    <td>&nbsp;</td>
  </tr>
</table>

<script language="JavaScript">
window.print();
</script>
  <%}//(bolError || vRetResult == null || vRetResult.size()==0 || ) %>

</body>
</html>
