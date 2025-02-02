<%@ page language="java" import="utility.*,hr.HRApplicantSearch,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements()) {
		strFormName = strToken.nextToken();
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
td{
	font-size:11px;
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
</style>
</head>


<body onLoad="window.print();">
<%
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;

// if this page is calling print page, i have to forward page to print page.


	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-Applicants Directory","applicant_search_name.jsp");
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

//Invalidate a temp student's enrollment if it is called.

int iSearchResult = 0;

HRApplicantSearch searchAppl = new HRApplicantSearch(request);

	vRetResult = searchAppl.searchApplicantName(dbOP);
	if(vRetResult == null)
		strErrMsg = searchAppl.getErrMsg();
	else	
		iSearchResult = searchAppl.getSearchCount();

%>
<% if (strErrMsg != null) {%> 
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3" bgcolor="#FFFFFF" align="right">&nbsp;</td>
    </tr>
</table>
<%}else if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3"><div align="center"><strong><font size="2">LIST OF APPLICANTS </font></strong></div></td>
    </tr>
    <tr>
      <td width="66%" height="42" ><b> Total Students : <%=iSearchResult%></b></td>
      <td width="34%">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td  width="21%" height="25" class="thinborder" ><div align="center"><strong><font size="1">APPLICANT 
          ID </font></strong></div></td>
      <td width="41%" class="thinborder"><div align="center"><strong><font size="1">LNAME, FNAME, 
          MI </font></strong></div></td>
      <td width="38%" class="thinborder"><div align="center"><strong><font size="1">CONTACT INFORMATION</font></strong></div></td>
    </tr>
    <%
for(int i=0; i<vRetResult.size(); i+=6){%>
    <tr> 
      <td height="25" class="thinborder"><font size="1"> &nbsp; 
        <%if(WI.fillTextValue("opner_info").length() > 0) {%>
        <a href='javascript:CopyID("<%=(String)vRetResult.elementAt(i)%>");'> 
        <%=(String)vRetResult.elementAt(i)%></a> 
        <%}else{%>
        <%=(String)vRetResult.elementAt(i)%> 
        <%}%>
        </font></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%>, <%=(String)vRetResult.elementAt(i+1)%> 
	  		<%=WI.getStrValue((String)vRetResult.elementAt(i+2)," ")%> </td>
			
<% strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4));
   if (strTemp.length() == 0) 
   		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5));
	else
		strTemp += "<br>&nbsp; " + WI.getStrValue((String)vRetResult.elementAt(i+5));
%>
      <td class="thinborder">&nbsp; <%=strTemp%>
	  
      </td>
    </tr>
    <%}%>
  </table>
<%}//vRetResult is not null %>

</body>
</html>
<%
dbOP.cleanUP();
%>