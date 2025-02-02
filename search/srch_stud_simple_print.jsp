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

-->
</style>

</head>

<body onLoad="window.print();">
<%@ page language="java" import="utility.*,search.SearchStudent,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;

	try {
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

SearchStudent searchStud = new SearchStudent(request);
	vRetResult = searchStud.searchGeneric(dbOP);
	if(vRetResult == null)
		strErrMsg = searchStud.getErrMsg();
	else
		iSearchResult = searchStud.getSearchCount();

int iRowsPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_pg"),"40"));


  int iNameFormat = Integer.parseInt(WI.getStrValue(WI.fillTextValue("name_format"),"4"));
  int iCount = 0;
  String strCollegeName = null;
  boolean bolPrintPerCollege = false;
  if(WI.fillTextValue("per_course").length() > 0)
 	bolPrintPerCollege = true;
for(int i = 0; i< vRetResult.size(); ) {
//if(i == 0 || ((i-16)/16)%iRowsPerPage == 0){%>
<%if(i > 0){%>
<DIV style="page-break-after:always">&nbsp;</DIV>
<%}//break only if it is not last page.%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25" colspan="2" ><div align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
        <br>
        STUDENT LISTING 
      </div></td>
  </tr>
  <tr>
    <td height="19" colspan="2"><hr size="1"></td>
  </tr>
  <tr>
    <td width="51%" height="18"><%if(i == 0) {%>Total Students :<b> <%=iSearchResult%></b><%}%></td>
    <td width="49%" height="18" align="right">Date &amp; Time Printed : <%=WI.getTodaysDateTime()%> &nbsp;&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr>
    <td width="15%" class="thinborder" align="center"><strong><font size="1">SL #</font></strong></td>
    <td width="31%" height="25" class="thinborder"><div align="center"><strong><font size="1">STUDENT ID</font></strong></div></td>
    <td width="54%" class="thinborder"><div align="center"><strong><font size="1">STUDENT NAME</font></strong></div></td>
  </tr>
  <%
for(; i< vRetResult.size(); i += 5) {%>
  <tr valign="top">
    <td class="thinborder"><%=++iCount%>.</td>
    <td height="20" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
    <td class="thinborder"><%=WebInterface.formatName((String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),
						(String)vRetResult.elementAt(i+2),iNameFormat)%></td>
  </tr>
  <%//System.out.println((i+16)/16);
  	if(i/5 > 10 && ((i+5)/5)%iRowsPerPage == 0) {//System.out.print("break here."+ ((i+16)/16) );
		i += 5;
		break;
	}

  }//end of loop %>
</table>
<%}//end of outer for loop.
%>


</body>
</html>
<%
dbOP.cleanUP();
%>
