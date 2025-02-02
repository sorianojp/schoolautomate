<%@ page language="java" import="utility.*,enrollment.FacultyEvaluation, java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Evaluation - View Comments</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body onLoad="window.print();">
<%
	String strErrMsg = null;
	String strTemp = null;
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling-Faculty Evaluation-Reports-View Comment","view_comments.jsp");
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

CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Guidance & Counseling","FACULTY EVALUATION",request.getRemoteAddr(),
														"view_comments.jsp");
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


FacultyEvaluation facEval = new FacultyEvaluation();
Vector vRetResult = null; Vector vComments = null;

vRetResult = facEval.viewFacEvalComments(dbOP, request);
if(vRetResult == null) 
	strErrMsg = facEval.getErrMsg();
else	
	vComments = (Vector)vRetResult.remove(0);


String strIsLAB = WI.fillTextValue("is_lab");
if(strIsLAB.equals("0"))
	strIsLAB = "LEC";
else	
	strIsLAB = "LAB";
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4"><div align="center"><strong>:::: FACULTY EVALUATED COMMENTS ::::</strong></div></td>
    </tr>
  </table>
<%if(strErrMsg != null) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
<%}
String strSQLQuery = "select id_number, fname, mname, lname from user_table where user_index = "+WI.fillTextValue("fac_ref");
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
if(rs.next())
	strSQLQuery = WebInterface.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 4)+" ( "+rs.getString(1)+")";
else	
	strSQLQuery = null;
rs.close();

String strDepartment = "select c_code from info_faculty_basic join college on (college.c_index = info_faculty_basic.c_index) where info_faculty_basic.is_valid = 1 and user_index = "+
						WI.fillTextValue("fac_ref");
rs = dbOP.executeQuery(strDepartment);
if(rs.next()) 
	strDepartment = rs.getString(1);
else	
	strDepartment = null;
						
String[] astrConvertTerm = {"SUMMER","1ST SEM","2ND SEM","3RD SEM"};
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="16%" style="font-size:13px; font-weight:bold">Faculty Name (ID) </td>
      <td width="38%" style="font-size:13px; font-weight:bold"><%=strSQLQuery%></td>
      <td width="16%" style="font-size:13px; font-weight:bold">SY/Term</td>
      <td width="29%" style="font-size:13px; font-weight:bold">
	  <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>, <%=WI.fillTextValue("sy_from")%> - <%=Integer.parseInt(WI.fillTextValue("sy_from")) + 1%>
	  
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-size:13px; font-weight:bold">Department</td>
      <td style="font-size:13px; font-weight:bold"><%=WI.getStrValue(strDepartment,"-")%></td>
      <td style="font-size:13px; font-weight:bold">Subject Type</td>
      <td style="font-size:13px; font-weight:bold"><%=strIsLAB%></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){
int iIndexOf = 0;
	for(int i = 0; i < vRetResult.size(); i += 6) {
		iIndexOf = vComments.indexOf(new Integer((String)vRetResult.elementAt(i + 3)));
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" style="font-weight:bold; font-size:11px;">&nbsp;</td>
      <td style="font-weight:bold; font-size:11px;">&nbsp;</td>
      <td style="font-weight:bold; font-size:11px;">&nbsp;</td>
    </tr>
    <tr>
      <td width="54%" height="25" style="font-weight:bold; font-size:11px;">Subject :   <%=vRetResult.elementAt(i + 1)%> ::: <%=vRetResult.elementAt(i + 2)%></td>
      <td width="21%" style="font-weight:bold; font-size:11px;">Section : <%=vRetResult.elementAt(i + 4)%></td>
      <td width="25%" style="font-weight:bold; font-size:11px;">Time : <%=vRetResult.elementAt(i + 5)%></td>
    </tr>
  </table>
<%if(iIndexOf == -1) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td style="font-weight:bold; font-size:11px; color:#FF0000"> No Recommendation/Remarks given by student(s)</td>
    </tr>
  </table>
<%continue;}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="4%" height="25" align="center" style="font-size:9px; font-weight:bold;" class="thinborder">Count </td>
      <td width="32%" height="25" align="center" style="font-size:9px; font-weight:bold;" class="thinborder">Recommendation</td>
      <td width="32%" align="center" style="font-size:9px; font-weight:bold;" class="thinborder">Positive Remark </td>
      <td width="32%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Negative Remark </td>
    </tr>
<%int iCount = 1;
while(iIndexOf > -1) {
vComments.remove(iIndexOf);%>
    <tr> 
      <td height="25" class="thinborder"><%=iCount++%>.</td>
      <td height="25" class="thinborder"><%=WI.getStrValue(vComments.remove(iIndexOf), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vComments.remove(iIndexOf), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vComments.remove(iIndexOf), "&nbsp;")%></td>
    </tr>
<%
	if(vComments.size() > 0)
		iIndexOf = vComments.indexOf(new Integer((String)vRetResult.elementAt(i + 3)));
	else	
		iIndexOf = -1;
	
}%>
  </table>
  <%
  	}//end of outer for loop.. 
}//vRetResult is not null
%>
</body>
</html>
<%
dbOP.cleanUP();
%>