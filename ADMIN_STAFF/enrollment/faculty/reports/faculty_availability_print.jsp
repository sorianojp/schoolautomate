<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body>
<%@ page language="java" import="utility.*,enrollment.FacMgmtSubstitution,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
		
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-REPORTS"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-substitute-REPORTS","faculty_availability_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
/**
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","FACULTY",request.getRemoteAddr(),
														"faculty_availability_print.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}
**/

//end of authenticaion code.

Vector vRetResult = new Vector();
FacMgmtSubstitution facSubs = new FacMgmtSubstitution(dbOP);
Vector vOccupied  = null;
Vector vAvailable = null;
	vRetResult = facSubs.getFacAvailabilityStat(dbOP,request);
	if(vRetResult == null)
		strErrMsg = facSubs.getErrMsg();
	else	
	{
		vOccupied  = (Vector)vRetResult.elementAt(0);
		vAvailable = (Vector)vRetResult.elementAt(1);
	}

if(vRetResult != null && vRetResult.size() > 0){
if(vOccupied != null && vOccupied.size() > 0){%>
  
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr bgcolor="#DBD8C8"> 
    <td width="91%" height="20"  class="thinborder"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;FACULTY 
      STATUS :<strong> OCCUPIED ::: TOTAL: <%=vAvailable.size()/ 5%></strong></font></td>
  </tr>
</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td width="15%" height="27" align="center" class="thinborder"><font size="1"><strong>EMPLOYEE 
        ID</strong></font></td>
      <td width="29%" align="center" class="thinborder"><font size="1"><strong>NAME</strong></font></td>
      <td width="24%" align="center" class="thinborder"><font size="1"><strong>COLLEGE</strong></font></td>
      <td width="24%" align="center" class="thinborder"><font size="1"><strong>DEPARTMENT</strong></font></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>LOAD UNIT</strong></font></td>
    </tr>
    <%
for(int i = 0; i< vOccupied.size();i +=5){%>
    <tr> 
      <td height="25" class="thinborder">
	  <%=(String)vOccupied.elementAt(i)%></td>
      <td class="thinborder"><%=(String)vOccupied.elementAt(i+1)%></td>
      <td class="thinborder"><%=WI.getStrValue(vOccupied.elementAt(i+2),"N/A")%></td>
      <td class="thinborder"><%=WI.getStrValue(vOccupied.elementAt(i+3),"N/A")%></td>
      <td class="thinborder"><%=(String)vOccupied.elementAt(i+4)%></td>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="89%" align="right">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
  </table>
<%}//if occupied room is having some value. 
if(vAvailable != null && vAvailable.size() > 0){%>
  
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr bgcolor="#DBD8C8"> 
    <td width="94%" height="20" class="thinborder" >
	&nbsp;&nbsp;&nbsp;&nbsp;<font size="1">FACULTY STATUS :<strong> AVAILABLE 
      ::: TOTAL: <%=vAvailable.size()/ 5%></strong></font></td>
  </tr>
</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td width="15%" height="27" align="center" class="thinborder"><font size="1"><strong>EMPLOYEE 
        ID</strong></font></td>
      <td width="29%" align="center" class="thinborder"><font size="1"><strong>NAME</strong></font></td>
      <td width="24%" align="center" class="thinborder"><font size="1"><strong>COLLEGE</strong></font></td>
      <td width="24%" align="center" class="thinborder"><font size="1"><strong>DEPARTMENT.</strong></font></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>LOAD UNIT</strong></font></td>
    </tr>
    <%
for(int i = 0; i< vAvailable.size();i +=5){%>
    
<tr> 
      <td height="25" class="thinborder"><%=(String)vAvailable.elementAt(i)%></td>
      <td class="thinborder"><%=(String)vAvailable.elementAt(i+1)%></td>
      <td class="thinborder"><%=WI.getStrValue(vAvailable.elementAt(i+2),"N/A")%></td>
      <td class="thinborder"><%=WI.getStrValue(vAvailable.elementAt(i+3),"N/A")%></td>
      <td class="thinborder"><%=(String)vAvailable.elementAt(i+4)%></td>
    </tr>
<%}%>
  </table>

<%
	}//if vAvailable Room is not null. 	
}//only if vRetResult is not null

if(strErrMsg != null){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><font size="3"><b><%=strErrMsg%></b></font></td>
    </tr>
	</table>

<%}%>
<script language="javascript">
	window.print();
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>