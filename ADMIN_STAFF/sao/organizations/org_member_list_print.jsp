<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.Organization"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;

	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-OSA - Organization","org_member_update.jsp");
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
														"org_member_update.jsp");
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
Vector vRetResult = new Vector();
Vector vOrgInfo = null;
Vector vTemp = null;
Organization organization = new Organization();
String strPresidentName = null;

if (WI.fillTextValue("organization_id").length()>0 &&
		WI.fillTextValue("sy_from").length() > 0) 
{
	vOrgInfo = organization.operateOnOrganization(dbOP, request,3);
}

vRetResult = organization.operateOnOrgMember(dbOP, request, 5);
if(vOrgInfo != null && WI.fillTextValue("sy_from").length() > 0) {
	//get president name,
	strPresidentName = organization.getOrganizationPresidentName(dbOP, (String)vOrgInfo.elementAt(0),"President",
							WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"));
	if(strPresidentName == null)
		strErrMsg = organization.getErrMsg();
}


%>
<body bgcolor="#FFFFFF" onLoad="window.print()">
<% if (vOrgInfo != null && vOrgInfo.size()>0) {%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="2"><div align="center">
        <p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <!-- Martin P. Posadas Avenue, San Carlos City -->
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%>
          <!-- Pangasinan 2420 Philippines -->
          <br><br><br>
          <strong>STUDENT DEVELOPMENT OFFICE</strong>
          <br><br><br></div></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="5%" colspan="3">&nbsp;</td>
	</tr>
		<tr>
		<td width="5%" height="25">&nbsp;</td>
		<td width="20%"><strong>Organization Name: </strong></td>
		<td width="78%"><%=WI.getStrValue((String)vOrgInfo.elementAt(2),"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td><strong>Adviser: </strong></td>
		<td><%=WI.getStrValue((String)vOrgInfo.elementAt(8))%>
	  <%=WI.getStrValue((String)vOrgInfo.elementAt(14),",","","")%>
	  <%=WI.getStrValue((String)vOrgInfo.elementAt(15),",","","")%>		</td>
	</tr>
	<tr>
		<td width="5%" colspan="3">&nbsp;</td>
	</tr>
</table>
<%
if(vRetResult != null && vRetResult.size() > 0){
vTemp = (Vector)vRetResult.elementAt(0);
if (vTemp != null && vTemp.size()>0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr>
      <td height="25" colspan="6" bgcolor="#DDDDDD" class="thinborder"><div align="center"><strong>LIST
        OF OFFICERS FOR SCHOOL YEAR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></div></td>
    </tr>
    <tr>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>Position</strong></font></div></td>
      <td width="11%" class="thinborder"><font size="1"><strong>Student ID </strong></font></td>
      <td width="25%" height="25" class="thinborder"><div align="center"><font size="1"><strong>Name</strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>Course Year </strong></font></div></td>
      <td width="12%" class="thinborder"><font size="1"><strong>Contact No. </strong></font></td>
      <td width="28%" class="thinborder"><div align="center"><font size="1"><strong>Address</strong></font></div></td>
    </tr>
    <%
for(int i = 0 ; i < vTemp.size(); i += 12){%>
    <tr>
      <td class="thinborder"><%=(String)vTemp.elementAt(i + 2)%></td>
      <td class="thinborder"><%=(String)vTemp.elementAt(i + 4)%></td>
      <td height="25" class="thinborder"><%=(String)vTemp.elementAt(i + 5)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vTemp.elementAt(i + 6),"&nbsp;")%><%=WI.getStrValue((String)vTemp.elementAt(i + 7),"(",")","")%>&nbsp;<%=WI.getStrValue(vTemp.elementAt(i + 8),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vTemp.elementAt(i+11),"&nbsp;")%></td>
      <% strTemp = 	WI.getStrValue((String)vTemp.elementAt(i+9));
	  	  if (strTemp.length() > 0) 
		  	strTemp += ", ";
		 strTemp +=  WI.getStrValue((String)vTemp.elementAt(i+10));
	  %>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    </tr>
    <%}%>
  </table>
  <%
}//if list of officers is found
vTemp = (Vector) vRetResult.elementAt(1);
if (vTemp != null && vTemp.size()>0){%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr>
      <td height="18" >&nbsp;</td>
    </tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr>
    <td height="25" colspan="6" bgcolor="#DDDDDD" class="thinborder"><div align="center"><strong>LIST
      OF MEMBERS FOR SCHOOL YEAR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></div></td>
  </tr>
  <tr>
    <td width="6%" class="thinborder"><strong><font size="1">No.</font></strong></td>
    <td width="12%" class="thinborder"><strong><font size="1">Student ID </font></strong></td>
    <td width="24%" height="25" class="thinborder"><div align="center"><font size="1"><strong>Name</strong></font></div></td>
    <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>Course Year </strong></font></div></td>
    <td width="12%" class="thinborder"><font size="1"><strong>Contact No. </strong></font></td>
    <td width="33%" class="thinborder"><div align="center"><font size="1"><strong>Address</strong></font></div></td>
  </tr>
  <%
for(int i = 0,iCtr = 1 ; i < vTemp.size(); i += 12, iCtr++){%>
  <tr>
    <td class="thinborder">&nbsp;<%=iCtr%></td>
    <td class="thinborder">&nbsp;<%=(String)vTemp.elementAt(i + 4)%></td>
    <td class="thinborder" height="25"><%=(String)vTemp.elementAt(i + 5)%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vTemp.elementAt(i + 6),"&nbsp;")%><%=WI.getStrValue((String)vTemp.elementAt(i + 7),"(",")","")%>&nbsp;<%=WI.getStrValue(vTemp.elementAt(i + 8),"&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vTemp.elementAt(i+11),"&nbsp;")%></td>
    <% strTemp = 	WI.getStrValue((String)vTemp.elementAt(i+9));
	  	  if (strTemp.length() > 0) 
		  	strTemp += ", ";
		 strTemp +=  WI.getStrValue((String)vTemp.elementAt(i+10));
	  %>
    <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
  </tr>
  <%}%>
</table>
<%}//if list of members is found%>

<%}//vRetResult > 0
}//if organization was found%>

</body>
</html>
<%
dbOP.cleanUP();
%>
