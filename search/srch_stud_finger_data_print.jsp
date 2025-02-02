<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student Without Finger Data</title>
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

<body >
<%@ page language="java" import="utility.*,search.StudentFingerInfo,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));
	int i = 0;
	boolean bolPageBreak = false;
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

StudentFingerInfo searchStud = new StudentFingerInfo(request);
	vRetResult = searchStud.searchGeneric(dbOP);
	if(vRetResult == null)
		strErrMsg = searchStud.getErrMsg();
	else	
		iSearchResult = searchStud.getSearchCount();
		
if(vRetResult != null && vRetResult.size() > 0){
	for(;i< vRetResult.size();){		
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25" colspan="2" ><div align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
        <br>
        STUDENT LISTING WITHOUT FINGER DATA<br>
        <br>
      </div></td>
  </tr>
  <tr>
    <td height="25" colspan="2"><hr size="1"></td>
  </tr>
  <tr>
    <td width="51%" height="25">Total Students :<b> <%=iSearchResult%></b></td>
    <td width="49%" height="25">Date &amp; Time Printed : <%=WI.getTodaysDateTime()%></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr> 
    <td width="20%" height="25" class="thinborder"><div align="center"><strong><font size="1">STUDENT 
        ID</font></strong></div></td>
    <td width="24%" class="thinborder"><div align="center"><strong><font size="1">LNAME,FNAME, MI</font></strong></div></td>
    <td width="6%" class="thinborder"><div align="center"><strong><font size="1">GENDER</font></strong></div></td>
    <td width="47%" align="center" class="thinborder"><strong><font size="1">COURSE/MAJOR</font></strong></td>
    <td width="8%" align="center" class="thinborder"><strong>YEAR</strong></td>
  </tr>
  <% 
 	for(int iCount = 0; iCount <= iMaxStudPerPage; i += 9,++iCount){
  		if (iCount >= iMaxStudPerPage || i >= vRetResult.size()){
			if(i >= vRetResult.size())
				bolPageBreak = false;
			else
				bolPageBreak = true;
			break;			
	 }%>
  <tr> 
    <td class="thinborder" height="20"><%=(String)vRetResult.elementAt(i+1)%></td>
    <td class="thinborder"><%=WebInterface.formatName((String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),
			(String)vRetResult.elementAt(i+2),4)%></td>
    <td class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(i+5),"n/f")%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%> 
      <%
	  if(vRetResult.elementAt(i+7) != null){%>
      
      /<%=(String)vRetResult.elementAt(i+7)%> 
      <%}%></td>
    <td align="center" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 8),"n/a")%></td>
  </tr>
  <%}}//end of loop %>
</table>
<% if (i >= vRetResult.size()){	
   %> 

<table width="100%" border="0" cellspacing="0" cellpadding="1">
  <tr>
    <td><div align="center">*****************NOTHING FOLLOWS *******************</div></td>
  </tr>
  <tr> 
    <td><div align="center">************** CONTINUED ON NEXT PAGE ****************</div></td>
  </tr>
</table>
<%
//INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END. 
    if (bolPageBreak) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
  }}%>
  <script language="javascript">
window.print();

</script>
</p>
</body>
</html>
