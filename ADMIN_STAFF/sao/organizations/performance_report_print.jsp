<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>
<body >
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;
	String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-student load print","student_sched_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");
		
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
	<%}

Vector vOrganizationDtl = null;
osaGuidance.Organization organization = new osaGuidance.Organization();	


boolean bolRetainValue = false;//if it is true, use wi.fillTextValue(..);

String strOrgIndex = null;
Vector vRetResult = null;
Vector vEditInfo  = null;
String[] strHighestOfficer = null;
	
vOrganizationDtl = organization.operateOnOrganization(dbOP, request,3);
if(vOrganizationDtl == null)
	strErrMsg = organization.getErrMsg();	

if(vOrganizationDtl != null) {
	//get president name,
	strOrgIndex = (String)vOrganizationDtl.elementAt(0);
}

if(vOrganizationDtl != null && WI.fillTextValue("sy_from").length() > 0) {
	//get president name,
	strHighestOfficer = organization.getHighestPossibleOfficer(dbOP, strOrgIndex, 
							WI.fillTextValue("sy_from"));
							
	if(strHighestOfficer == null)
		strErrMsg = organization.getErrMsg();
}

vRetResult = organization.operateOnPerformance(dbOP, request,4);

if(vOrganizationDtl != null && vOrganizationDtl.size() > 0){%>
<table width="100%" border="0">
  <tr> 
    <td width="100%"><div align="center"><strong  style="font-size:14px"><%=SchoolInformation.getSchoolName(dbOP, true, false)%></strong><br>
        <font style="font-size:12px;"><%=SchoolInformation.getAddressLine1(dbOP, false, false)%></font><br>        
        <br>
        <font size="2"><strong>PERFORMANCE REPORT</strong></font><br>
         <font style="font-size:12px;">School Year <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%></font><br>
        <br>
      </div></td>
  </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="8%">&nbsp;</td>
      <td width="20%">Organization ID</td>
      <td width="72%"><strong><%=WI.fillTextValue("organization_id")%></strong></td>
    </tr>
     <tr>
      <td height="25">&nbsp;</td>
      <td >Organization Name</td>
      <td ><strong><%=(String)vOrganizationDtl.elementAt(2) %></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td ><% if (strHighestOfficer != null && strHighestOfficer[0] != null) {%>
		  	<%=strHighestOfficer[0]%> &nbsp;
	  	<%}%> 
	  </td>
      <td >
	<% if (strHighestOfficer != null && strHighestOfficer[1] != null) {%>
		  	<strong><%=strHighestOfficer[1]%></strong> &nbsp;
	  	<%}%> 	  
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Adviser</td>
      <td><strong>
	  <%if (vOrganizationDtl.elementAt(9)!=null){%>
	  <%=(String)vOrganizationDtl.elementAt(14)%><%} else {%>
	  <%=(String)vOrganizationDtl.elementAt(8)%><%}%></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
</table>
<%
if(vRetResult != null && vRetResult.size() > 0){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFFF">
      <td class="thinborder"height="25" colspan="7"><div align="center"><font color=""><strong>PERFORMANCE
          REPORT FOR SCHOOL YEAR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></font></div></td>
    </tr>
    <tr>
      <td class="thinborder" width="13%" height="27" ><div align="center"><font size="1"><strong>PLANNED
          ACTIVITIES </strong></font></div></td>
      <td class="thinborder" width="21%" height="27"><div align="center"><font size="1"><strong>ACCOMPLISHMENT
          TO DATE</strong></font></div></td>
      <td class="thinborder" width="6%" height="27"><div align="center"><font size="1"><strong>%
          PROFILE </strong></font></div></td>
      <td class="thinborder" width="15%"><div align="center"><font size="1"><strong>PROBLEMS ENCOUNTERED</strong></font></div></td>
      <td class="thinborder" width="15%"><div align="center"><font size="1"><strong>ACTION TAKEN
          </strong></font></div></td>
      <td class="thinborder" width="10%"><div align="center"><font size="1"><strong>PROJECTION</strong></font></div></td>
      <td class="thinborder" width="12%"><div align="center"><font size="1"><strong>EVALUATION</strong></font></div></td>
    </tr>
    <%
for(int i = 0 ; i < vRetResult.size(); i += 13){%>
    <tr>
      <td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 8)%></td>
    </tr>
    <%}%>
  </table>
<script>window.print();</script>
<%}}%>
</body>
</html>
<%
dbOP.cleanUP();
%>