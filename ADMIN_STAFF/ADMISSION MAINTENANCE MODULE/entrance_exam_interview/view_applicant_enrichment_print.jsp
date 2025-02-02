<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Exam Result Encoding </title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,java.util.Vector"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	String strErrMsg = null;
	String strTemp = null;
	int iCount = 0;
	String strSchCode  = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-ENTRANCE EXAM/INTERVIEW",
								"view_applicant_enrichment.jsp");
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

int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission Maintenance","ENTRANCE EXAM/INTERVIEW",
														request.getRemoteAddr(),"view_applicant_enrichment.jsp");
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
//end of authenticaion code.
	ApplicationMgmt appMgmt = new ApplicationMgmt();
	if (WI.fillTextValue("show_list").equals("1")){
		vRetResult = appMgmt.generatePerGroup(dbOP, request);
		if (vRetResult == null)
			strErrMsg = appMgmt.getErrMsg();
	}

	int iPageCount  = 1;
	int iPageNumber = 1;
	int iStudPerPage =
		 Integer.parseInt(WI.getStrValue(WI.fillTextValue("appl_per_page"),"25"));

%>
<body onLoad="window.print();">
<% if (strErrMsg != null) {%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="table2">
    <tr>
      <td width="100%" height="25"> &nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>
<% }
	if (vRetResult != null) {
		String[] astrSubj ={"REG","EE","ME","EE and ME","&nbsp;"};

	for (int t = 0; t < vRetResult.size();) {

	if (iPageCount == 1){
%>
		<div align="center">
        <font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font><br><br>
</div>
<%   }%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
    <tr>
      <td height="53"  align="center" ><font size="2"><strong>QUALIFIED APPLICANTS WITH SUBJECT TO TAKE </strong></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="10%" align="center" class="thinborder"><strong>
      NO.</strong></td>
      <td width="20%" height="25" align="center" class="thinborder"><strong>
      TEMPORARY /<br>
      APPLICANT ID</strong></td>
      <td width="50%" align="center" class="thinborder"><strong>
      APPLICANT NAME</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>COURSE</strong></td>
      <td width="16%" align="center" class="thinborder"><strong>SUBJECT TO TAKE </strong></td>
    </tr>
<%
	  for(; t < vRetResult.size(); t+=6, iCount++){
		if (iPageCount > iStudPerPage){
			iPageCount = 1;
			break;
		}

		iPageCount++;
%>
    <tr>
	  <td height="25" align="right" class="thinborder">
  	  <%=iCount+1%>&nbsp;	  </td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=(String)vRetResult.elementAt(t)%></td>
      <td class="thinborder">&nbsp;
        <%=WI.formatName((String)vRetResult.elementAt(t+1),(String)vRetResult.elementAt(t+2),
							(String)vRetResult.elementAt(t+3),4)%></td>
      <td class="thinborder">&nbsp;
        <%=(String)vRetResult.elementAt(t + 5)%></td>
      <td align="center" class="thinborder">&nbsp;
  	<%=astrSubj[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(t+4),"4"))]%>	  </td>
    </tr>
    <%} if ( t >= vRetResult.size()) {%>
    <tr>
	  <td height="17" colspan="5" align="right" class="thinborder">
	  				<div align="center">********NOTHING FOLLOWS *********	  </div></td>
    </tr>
	<%}%>
</table>
<% if (iPageCount == 1 || t >= vRetResult.size()) { %>
	<br><br>
  <div align="center">Page <%=iPageNumber++%>&nbsp;&nbsp;</div>
<%}%>
    <% if (t < vRetResult.size() && iPageCount == 1) {%>
	  <DIV style="page-break-before:always" >&nbsp;</DIV>
<%   } // if t < vRetResult.size()
  }
} %>

</body>
</html>
<%
dbOP.cleanUP();
%>
