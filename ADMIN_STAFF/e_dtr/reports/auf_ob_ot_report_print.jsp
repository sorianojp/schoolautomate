<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

td {
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
	
    TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<body onLoad="window.print()">
<%@ page language="java" import="utility.*,java.util.Vector,hr.HRStatsReports" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strTemp4 = null;
	int iSearchResult =0;
	int iPageCount = 0;
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS-OB / OT Reports",
								"auf_ob_ot_report.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"auf_ob_ot_report.jsp");	
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
String[] astrSortByName    = {"College","Department","Date","Scope", "Seminar Type"};
String[] astrSortByVal     = {"c_code","d_code","DATE_RANGE_FR","train_scope","seminar_type"};


HRStatsReports RE = new HRStatsReports(request);

vRetResult = RE.hrDemoTrainings(dbOP);
if (vRetResult == null) 
	strErrMsg = RE.getErrMsg();


if (strErrMsg != null) { 
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
      <td height="25">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>","</strong></font>","")%></td>
  </tr>
</table>
<%} else  if (vRetResult !=null && vRetResult.size() > 0){  %>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <% strTemp = WI.fillTextValue("date_from") + 
	  				 WI.getStrValue(WI.fillTextValue("date_to")," - ","",""); %>
      <td height="25"  colspan="6" align="center" ><strong>
	  <font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br> </font>
      <font size="2"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font> <br>
	  
	  <% if (strSchCode.startsWith("AUF")) {%> 
		  <br><br>Human Resources Development Center
	  <%}%> <br>
<br>
Report on <%=WI.fillTextValue("obot_label")%> 
<% if (strTemp.length() != 0) {%> <%=strTemp%> <%}%> 
	
	  </strong>
	    <br>
      <br></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center"> 
      <td height="20" colspan="2" class="thinborder"><strong>NAME</strong></td>
      <td width="17%" class="thinborder"><strong>DATE</strong></td>
      <td width="37%" height="20" class="thinborder"><strong>BUSINESS &amp; DESTINATION </strong></td>
      <td width="10%" height="20" class="thinborder"><strong>CATEGORY</strong></td>
      <td width="10%" height="20" class="thinborder"><strong>BUDGET</strong></td>
    </tr>
<%  strTemp2 = "";strTemp3 = "";
	String strUserID = "";
	String[] astrConvertDurationUnit={" hour(s)", " day(s)", " week(s)", " month(s)", " year(s)"};	
	for ( int i = 2 ; i< vRetResult.size(); i+=17){ 
%>
    <tr> 
      <td width="22%" height="21" class="thinborder">
	  <% if (!strUserID.equals((String)vRetResult.elementAt(i))) { %> 
	  <%=WI.formatName((String)vRetResult.elementAt(i+12),
	  													(String)vRetResult.elementAt(i+13),
														(String)vRetResult.elementAt(i+14),4)%>
	  <%}else{%>&nbsp;<%}%> 
														<br>
	  <% if (!strUserID.equals((String)vRetResult.elementAt(i))) {
	  	strUserID = (String)vRetResult.elementAt(i);
	  %> 
	  <%=strUserID%>
	  <%}else{%>&nbsp;<%}%>
	  </td>
      <td width="4%" class="thinborderBottom">&nbsp;<br>
	  	<% if ((String)vRetResult.elementAt(i+1) != null){%> 
			<%=(String)vRetResult.elementAt(i+1)%> 
		<%}else{%> 
			<%=(String)vRetResult.elementAt(i+2)%> 
		<%}%> 
	  
	  </td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+9) + WI.getStrValue((String)vRetResult.elementAt(i+10)," - " ,"","")%> <br>
	 <% strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6)," ::: ","","");
	    if (strTemp.length() > 0) {
			if ((String)vRetResult.elementAt(i+7) != null) 
				strTemp +=  astrConvertDurationUnit[Integer.parseInt((String)vRetResult.elementAt(i+7))];
		}else strTemp = "&nbsp;";%> <%=strTemp%>	  
	  </td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%><br>
	  
	 <% strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5));
	 	if (strTemp.length() > 0)
			strTemp +=WI.getStrValue((String)vRetResult.elementAt(i+15),", ","","") ;
		else
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+15)) ;
	 %>	&nbsp;<%=strTemp%>
	  </td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder" align="right"><%=WI.getStrValue((String)vRetResult.elementAt(i+8))%>&nbsp;</td>
    </tr>
    <%} // end for loop%>
</table>
  <%}%>

</body>
</html>
<% dbOP.cleanUP(); %>