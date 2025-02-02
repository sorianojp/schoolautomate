<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td.thinborder{
	font-family:Verdana, Arial, Helvetica, sans-serif;
	font-size:11px;
	border-left: #000000 1px solid;
	border-bottom:#000000 1px solid;
}
table.thinborder{
	font-family:Verdana, Arial, Helvetica, sans-serif;
	font-size:11px;
	border-right: #000000 1px solid;
	border-top:#000000 1px solid;
}

</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.Organization"%>
<%
	
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String[] strHighestOfficer = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-OSA - Organization","aciton_plan_org_update.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs",
														"ORGANIZATIONS",request.getRemoteAddr(),
														"action_plan_org_update.jsp");
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

Organization organization = new Organization();
Vector vRetResult = null;
Vector vOrgInfo = null;
String strPresidentName = null;

vOrgInfo = organization.operateOnOrganization(dbOP, request,3);
vRetResult = organization.operateOnActionPlan(dbOP, request,4);
if(vOrgInfo != null && WI.fillTextValue("sy_from").length() > 0) {
	//get president name,
	strHighestOfficer = organization.getHighestPossibleOfficer(dbOP, 
								(String)vOrgInfo.elementAt(0), WI.fillTextValue("sy_from"));
	if(strHighestOfficer == null)
		strErrMsg = organization.getErrMsg();	
	
//	strPresidentName = organization.getOrganizationPresidentName(dbOP, ,"President",
//							WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"));
//	if(strPresidentName == null)
//		strErrMsg = organization.getErrMsg();
}

%>
<body bgcolor="#FFFFFF">
<% if (vOrgInfo != null && vOrgInfo.size()>0) {%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="2"><div align="center">
        <p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <!-- Martin P. Posadas Avenue, San Carlos City -->
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%>
          <!-- Pangasinan 2420 Philippines -->
          <br><br><br>
          <strong>STUDENT DEVELOPMENT OFFICE</strong><br><br>
	    </div></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="5%" colspan="3">&nbsp;</td>
	</tr>
		<tr>
		<td width="2%" height="25">&nbsp;</td>
		<td width="20%"><strong>Organization Name: </strong></td>
		<td width="78%"><%=WI.getStrValue((String)vOrgInfo.elementAt(2),"&nbsp;")%></td>
	</tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td ><% if (strHighestOfficer != null && strHighestOfficer[0] != null) {%>
		  <strong><%=strHighestOfficer[0]%></strong> &nbsp;
	  	<%}%> 
	  </td>
      <td >
	<% if (strHighestOfficer != null && strHighestOfficer[1] != null) {%>
		  	<%=strHighestOfficer[1]%>&nbsp;
	  	<%}%> 	  
	  </td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td><strong>Adviser: </strong></td>
		<td>
		 <%if (vOrgInfo.elementAt(9)!=null){%>
	  <%=WI.getStrValue((String)vOrgInfo.elementAt(14))%><%} else {%>
	  <%=WI.getStrValue((String)vOrgInfo.elementAt(8))%><%}%>&nbsp;
		</td>
	</tr>
	<tr>
		<td width="5%" colspan="3">&nbsp;</td>
	</tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DDDDDD">
      <td height="25" colspan="8" align="center" class="thinborder"><strong>ACTION
          PLAN LIST FOR SCHOOL YEAR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></td>
    </tr>
    <tr>
      <td width="14%" height="27" class="thinborder" ><div align="center"><font size="1"><strong>OBJECTIVES</strong></font></div></td>
      <td width="14%" height="27" class="thinborder"><div align="center"><font size="1"><strong>KEY
      RESULT AREA</strong></font></div></td>
      <td width="11%" height="27" class="thinborder"><div align="center"><font size="1"><strong>ACTIVITIES</strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>PERFORMANCE INDICATOR</strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>TIME FRAME</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>PERSON IN-CHARGE</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>BUDGET AMT.</strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>SOURCE</strong></font></div></td>

    </tr>
<%
for(int i = 0 ; i < vRetResult.size(); i += 13){%>
    <tr>
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 4)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 5)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 2)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 6)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 7)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 8)%>(<%=(String)vRetResult.elementAt(i + 9)%>)</font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 10)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 11)%></font></td>
    </tr>
<%}%>

</table>
  <script language="JavaScript">
		window.print();
	</script>
<%}//if result exists
}//if organization exists%>

</body>
</html>
<%
dbOP.cleanUP();
%>
