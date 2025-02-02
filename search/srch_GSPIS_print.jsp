<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student Print</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<%@ page language="java" import="utility.*, search.SearchStudent ,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	int iSearchResult = 0;
	boolean bolPageBreak = false;
	String strExecute = null;
	strExecute = WI.getStrValue(WI.fillTextValue("executeSearch"),"0");
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-Search","srch_GSPIS_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
<p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs","Search",request.getRemoteAddr(),
														"srch_GSPIS_print.jsp");
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
	response.sendRedirect("../commfile/unauthorized_page.jsp");
	return;
}
//end authentication

  	boolean bolShowCourseYr = false;
	if(WI.fillTextValue("sy_from").length() > 0) 
		bolShowCourseYr = true;
 	boolean bolShowHomeAddr = false;
	if(WI.fillTextValue("srchData").equals("2")) 
		bolShowHomeAddr = true;
	
	Vector vRetResult = null;
	Vector vAddlInfo  = null;//[0] user index, [1] address.
	int iIndexOf      = 0;
	  
    
	SearchStudent srchStud = new SearchStudent(request);		
	srchStud.defSearchSize = 1000000;
	if (strExecute.compareTo("1")==0) {
	    vRetResult = srchStud.searchGSPIS(dbOP);
		if (vRetResult != null && vRetResult.size()>0) {
			iSearchResult = srchStud.getSearchCount();
			vAddlInfo = (Vector)vRetResult.remove(0);
		}
		else{
			 strErrMsg = srchStud.getErrMsg();
		}
	}
	if(vAddlInfo == null)
		vAddlInfo = new Vector();
		System.out.println(vAddlInfo);
	
	if(vRetResult != null){
	     int iMaxStudPerPage =50; 
		 int iRowCount = 1;
		 int iNumstud = 0;
		 int iIncr    = 1;

		 if (WI.fillTextValue("num_stud_page").length() > 0){
			iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));
		 }
		 for ( ; iNumstud < vRetResult.size(); )
		 {	 
%>

<body onLoad="window.print()">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25" colspan="2" class="thinborderBOTTOM">
      <div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
       <strong><br>
        STUDENT GSPIS LISTING</strong>
      </div></td>
  </tr>
  <tr>
    <td width="50%" height="25" style="font-size:9px;">Total Students :<b> <%=iSearchResult%></b></td>
    <td width="50%" style="font-size:9px;" align="right">Date &amp; Time Printed : <%=WI.getTodaysDateTime()%></td>
  </tr>
</table>

<table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
  <tr>
    <td  width="5%" height="25" ><div align="center"><strong><font size="1"> No. </font></strong></div></td>
    <td  width="10%" height="25" ><div align="center"><strong><font size="1">STUDENT ID</font></strong></div></td>
    <td width="15%"><div align="center"><strong><font size="1">LASTNAME</font></strong></div></td>
    <td width="15%"><div align="center"><strong><font size="1">FIRSTNAME</font></strong></div></td>
    <td width="10%"><div align="center"><strong><font size="1">MI</font></strong></div></td>
<%if(bolShowCourseYr) {%>
      <td width="14%" align="center"><strong><font size="1">COURSE-YR</font></strong></td>
<%}if(bolShowHomeAddr) {%>
      <td width="50%" align="center"><strong><font size="1">HOME ADDRESS</font></strong></td>
<%}%>
 </tr>
  <%  for (; iNumstud < vRetResult.size(); iNumstud+=7, ++iIncr,++iRowCount) {
          int j = iNumstud;
          if (iRowCount > iMaxStudPerPage){
			bolPageBreak = true;	
			break;
		  }
		  else 
			bolPageBreak = false;
   %>
  <tr>
    <td><%=iIncr%> </td>
    <td height="25"><font size="1"><%=(String)vRetResult.elementAt(j+1)%></font></td>
    <td ><font size="1"><%=(String)vRetResult.elementAt(j+4)%></font></td>
    <td><font size="1"><%=(String)vRetResult.elementAt(j+2)%></font></td>
    <td><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(j+3),"&nbsp;")%></font></td>
	<%if(bolShowCourseYr) {
	strTemp = (String)vRetResult.elementAt(j + 5);
	if(strTemp != null)
		strTemp = strTemp + WI.getStrValue((String)vRetResult.elementAt(j + 6), " - ", "","");
	else	
		strTemp = "&nbsp;";
	%>
		  <td><%=strTemp%></td>
<%}if(bolShowHomeAddr) {
	iIndexOf = vAddlInfo.indexOf(vRetResult.elementAt(j));
	if(iIndexOf == -1)
		strTemp = null;
	else {
		vAddlInfo.remove(iIndexOf);
		strTemp = (String)vAddlInfo.remove(iIndexOf);
	}
%>
	      <td style="font-size:9px;"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
<%}%>
  </tr>
  <%}%>
</table>
<%if (bolPageBreak){
	iRowCount = 1;
%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<% }
}//outer loop%>

<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>
