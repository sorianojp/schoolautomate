<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
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
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>

</head>

<body >
<%@ page language="java" import="utility.*,search.SearchStudent,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-SEARCH-Students","srch_stud.jsp");
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

int iSearchResult = 0;

SearchStudent searchStud = new SearchStudent(request);
	vRetResult = searchStud.searchBasicEduStudent(dbOP,request);
	if(vRetResult == null)
		strErrMsg = searchStud.getErrMsg();
	else	
		iSearchResult = searchStud.getSearchCount();
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25" colspan="2" ><div align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br><br>
        STUDENT LISTING
      </div></td>
  </tr>
  <tr>
    <td width="50%" height="25" class="thinborderTOP">Total Students :<b> <%=iSearchResult%></b></td>
    <td width="50%" class="thinborderTOP" align="right">Date &amp; Time Printed : <%=WI.getTodaysDateTime()%></td>
  </tr>
</table>
<%
boolean bolShowDOB = false;
boolean bolShowSection = false;
if(WI.fillTextValue("show_dob").length() > 0) 
	bolShowDOB = true;
if(WI.fillTextValue("show_section").length() > 0) 
	bolShowSection = true;
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr align="center" style="font-weight:bold"> 
    <td width="20%" height="25" class="thinborder"><font size="1">STUDENT ID</font></td>
    <td width="24%" class="thinborder"><font size="1">LNAME,FNAME, MI</font></td>
    <td width="6%" class="thinborder"><font size="1">GENDER</font></td>
<%if(bolShowDOB) {%>
      <td width="12%" class="thinborder"><font size="1">DOB</font></td>
<%}%>
    <td width="35%" class="thinborder"><font size="1">GRADE LEVEL</font></td>
<%if(bolShowSection) {%>
    <td width="10%" class="thinborder"><font size="1">SECTION</font></td>
<%}%>
  </tr>
<%
int iNoOfFields = 9;
if(bolShowDOB) 
	iNoOfFields = 11;
if(bolShowSection) 
	iNoOfFields = 12;
	
for(int i = 0 ; i< vRetResult.size(); i += iNoOfFields) {%>
  <tr> 
    <td class="thinborder" height="20"><%=(String)vRetResult.elementAt(i+1)%></td>
    <td class="thinborder"><%=WebInterface.formatName((String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),
			(String)vRetResult.elementAt(i+2),4)%></td>
    <td class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(i+5),"not set")%></td>
<%if(bolShowDOB) {%>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+10),"not set")%></td>
<%}%>
    <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+6)%> 
      <%
	  if(vRetResult.elementAt(i+7) != null){%>
      - <%=(String)vRetResult.elementAt(i+7)%> 
      <%}%>
      </font></td>
<%if(bolShowSection) {%>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+11),"not set")%></td>
<%}%>
  </tr>
  <%}//end of loop %>
</table>


<script language="javascript">
window.print();

</script>

</body>
</html>
