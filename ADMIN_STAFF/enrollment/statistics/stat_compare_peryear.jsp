<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<%@ page language="java" import="utility.*,enrollment.StatEnrollment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation();
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
														"Enrollment","STATISTICS",request.getRemoteAddr(),
														"stat_compare_peryear.jsp");
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
StatEnrollment SE = new StatEnrollment();
Vector vRetResult = SE.getEnrolleeStatComparePerYrLevel(dbOP, request);
if(vRetResult == null) {
	strErrMsg = SE.getErrMsg();
	if(strErrMsg == null) 
		strErrMsg = "Un-known Error.";
}

if(strErrMsg != null) {
dbOP.cleanUP();%>
<font style="font-size:14px; font-weight:bold; color:#FF0000"><%=strErrMsg%></font>
<%return;}

String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
String[] astrConvertYear = {"N/A","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year","8th Year"};
%>
<body onLoad="window.print();">

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="2" align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <u>Enrollment Comparision Chart for 
			<%=WI.fillTextValue("prev_sy_from")%>, <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("prev_semester"))]%> - 
			<%=WI.fillTextValue("sy_from")%>, <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("prev_semester"))]%></u>
	 </td>
    </tr>
    <tr>
      <td width="37%" height="22" style="font-size:10px">&nbsp;</td>
      <td width="63%" align="right" style="font-size:10px">Date and time printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>
  <br>&nbsp;
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr>
      <td height="22" width="60%" style="font-size:11px; font-weight:bold" class="thinborder">COURSE</td>
      <td width="20%" style="font-size:11px; font-weight:bold" class="thinborder"><%=WI.fillTextValue("prev_sy_from")%>, <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("prev_semester"))]%></td>
      <td width="20%" style="font-size:11px; font-weight:bold" class="thinborder"><%=WI.fillTextValue("sy_from")%>, <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("prev_semester"))]%></td>
    </tr>
<%
Vector vStatInfo = null;
String strGTPrev = (String)vRetResult.remove(0);
String strGTCur  = (String)vRetResult.remove(0);
for(int i = 0; i < vRetResult.size(); i += 4) {
vStatInfo = (Vector)vRetResult.elementAt(i + 3);
%> 
    <tr>
      <td height="22" class="thinborder" style="font-size:11px; font-weight:bold">&nbsp;<%=vRetResult.elementAt(i)%></td>
      <td class="thinborder" style="font-size:11px; font-weight:bold">&nbsp;<%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" style="font-size:11px; font-weight:bold">&nbsp;<%=vRetResult.elementAt(i + 2)%></td>
    </tr>
    <%if(vStatInfo.size() == 3)
		continue;
	for(int p = 0; p < vStatInfo.size(); p += 3){%>
	<tr>
      <td height="22" class="thinborder" style="font-size:11px;">&nbsp;<%=astrConvertYear[Integer.parseInt(WI.getStrValue(vStatInfo.elementAt(p),"0"))]%></td>
      <td class="thinborder" style="font-size:11px;">&nbsp;<%=WI.getStrValue(vStatInfo.elementAt(p + 1), "0")%></td>
      <td class="thinborder" style="font-size:11px;">&nbsp;<%=WI.getStrValue(vStatInfo.elementAt(p + 2), "0")%></td>
    </tr>
	<%}//end of year level printing.. 
}//end of outer for loop.. %>
	<tr>
      <td height="22" class="thinborder" style="font-size:11px; font-weight:bold" align="right">Grand Total &nbsp;&nbsp;</td>
      <td class="thinborder" style="font-size:11px; font-weight:bold">&nbsp;<%=strGTPrev%></td>
      <td class="thinborder" style="font-size:11px; font-weight:bold">&nbsp;<%=strGTCur%></td>
    </tr>
  </table>
</body>
</html>
<%
dbOP.cleanUP();
%>
