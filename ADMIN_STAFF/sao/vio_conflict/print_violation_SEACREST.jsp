<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.ViolationConflict"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-VIOLATIONS & CONFLICTS","print_violation_SACI.jsp");
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
boolean bolIsStudent = WI.fillTextValue("is_student").equals("1");
String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
if(strAuthTypeIndex != null && strAuthTypeIndex.equals("4")) {
	bolIsStudent = true;
	request.setAttribute("is_student", "1");
}

CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 0;
if(bolIsStudent)
	iAccessLevel = 2;
else	
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs","VIOLATIONS & CONFLICTS",request.getRemoteAddr(),
														"vio_conflict.jsp");
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
Vector vRetResult = new Vector();//It has all information.
String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};
ViolationConflict VC = new ViolationConflict();
int iElemCount = 0;
if(WI.fillTextValue("sy_from").length() > 0  || WI.fillTextValue("show_all_sem").equals("1") ) {
	vRetResult = VC.operateOnViolation(dbOP, request,4, true);
	if(vRetResult == null) {dbOP.cleanUP();%>
		<p align="center" style="font-size:14px; color:#FF0000; font-weight:bold"><%=VC.getErrMsg()%></p>
		
<%return;}

iElemCount = VC.getElemCount();

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsCGH = strSchCode.startsWith("CGH");

String strReportName = null;
  if(WI.fillTextValue("sy_range_fr").length() > 0) {
	if(WI.fillTextValue("sy_range_to").length() > 0) {
		strReportName = WI.fillTextValue("sy_range_fr")+" to "+Integer.toString(Integer.parseInt(WI.fillTextValue("sy_range_to")) + 1);
	}
	else 
		strReportName = WI.fillTextValue("sy_range_fr")+" to "+Integer.toString(Integer.parseInt(WI.fillTextValue("sy_range_fr")) + 1);
  }
  else
	strReportName = WI.fillTextValue("sy_from") +" - "+astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))];
%>

 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="9" align="center">
          <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <!-- Martin P. Posadas Avenue, San Carlos City -->
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%>
          <!-- Pangasinan 2420 Philippines -->
          <br><br>
	  <strong>VIOLATIONS & CONFLICTS FOR SCHOOL YEAR <%=strReportName%></strong></td>
    </tr>
 </table>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="2%" height="26" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Count</td>
      <td width="7%"  class="thinborder" align="center" style="font-size:9px; font-weight:bold">Case Number</td>
      <td width="8%"  class="thinborder" align="center" style="font-size:9px; font-weight:bold">Student ID </td>
      <td width="10%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Student Name </td>

  	<td width="9%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Incident Type</td>
	<td width="12%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Incident</td>
	<td width="14%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Case Summary</td>

      <td width="9%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Date Reported</td>
      
      <td width="8%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Complainant</td>
      <td width="7%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Action Taken</td>
	  <td width="7%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Recommendation</td>
	  <td width="7%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Status</td>
    </tr>
    <%for(int i = 0, j = 0; i< vRetResult.size(); i += iElemCount){
		if(WI.getStrValue(vRetResult.elementAt(i + 6)).equals("1"))
			strTemp = " Cleared";
		else	
			strTemp = " <font color=red>Pending</font>";
		%>
    <tr>
      <td height="25" class="thinborder"><%=++j%>.</td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+7)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>      
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 8)%></td>	  
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 9)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 10), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 3), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 11), "&nbsp;")%></td>
	  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 12), "&nbsp;")%></td>
	  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 13), "&nbsp;")%></td>
	  <%
	  if(WI.getStrValue(vRetResult.elementAt(i + 6)).equals("1"))
		strTemp = " Cleared";
	else	
		strTemp = " <font color=red>Pending</font>";
	  %>
	  <td class="thinborder"><%=strTemp%></td>
    </tr>
    <%}%>
  </table>
<%}//only if vRetResult is not null
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable4">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

</body>
</html>
<%
dbOP.cleanUP();
%>
