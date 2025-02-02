<%@ page language="java" import="utility.*, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
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
<%
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	
	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("SYSTEM ADMINISTRATION-SET PARAMETERS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("SYSTEM ADMINISTRATION"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administration-Advising Setting","set_advising_rule.jsp");
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

//end of authenticaion code.
	enrollment.SetParameter sParam = new enrollment.SetParameter();
	
	if(WI.fillTextValue("sy_from").length() > 0) {
		vRetResult = sParam.operateOnAdvisingRules(dbOP, request, 4);
		if (strErrMsg==null && vRetResult == null)
			strErrMsg = sParam.getErrMsg();
	}

String strReportName = null;
if( (WI.fillTextValue("show_blocked").length() == 0 && WI.fillTextValue("show_allowed").length() == 0) ||
	(WI.fillTextValue("show_blocked").length() > 0 && WI.fillTextValue("show_allowed").length() > 0) ) {
	strReportName = "List of Blocked Students and Allowed Students in Advising";	
}
else if(WI.fillTextValue("show_blocked").length() > 0) {
	strReportName = "List of Blocked Students in Advising";	
}
else if( WI.fillTextValue("show_allowed").length() > 0) {
	strReportName = "List of Allowed Students in Advising";	
}

String[] astrConvertTerm = {"Summer", "1st Sem","2nd Sem","3rd Sem"};
%>


<body onLoad="window.print();">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2">&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
    <tr>
      <td width="2%" height="15" colspan="2" align="center" style="font-size:14px; font-weight:bold"><%=strReportName%>
	  <br><font size="1" style="font-weight:normal"><%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>, <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></font></td>
    </tr>
    <tr>
      <td height="15" style="font-size:12px"> Total Count: <%=(vRetResult.size() - 4)/8%></td> 
      <td align="right" style="font-size:9px">Date and Time Printed: <%=WI.getTodaysDateTime()%>&nbsp;</td>
    </tr>
<%}//show only if sy_from infomration is entered.%>	
  </table>
<%
int iCount = 0;
if(vRetResult != null && vRetResult.size() > 0) {
	String[] astrConvertBlockReason = {"Allowed","Blocked"};%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DDDDDD">
      <td width="5%" class="thinborder" align="center"><strong>Count</strong></td> 
      <td width="20%" height="20" class="thinborder"> <div align="center"><strong>ID  (Name)</strong></div></td>
      <td width="36%" class="thinborder"> <div align="center"><strong>Reason</strong></div></td>
      <td align="center" class="thinborder" width="6%"><strong>Setting</strong> </td>
      <td width="15%" align="center" class="thinborder"><strong>Created By</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>Create Date</strong></td>
    </tr>
    <%
    for (int i = 4; i<vRetResult.size(); i+=8) { //System.out.println(vRetResult.elementAt(i + 1));%>
    <tr>
      <td class="thinborder"><%=++iCount%></td> 
      <td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+2)%>(<%=(String)vRetResult.elementAt(i+3)%>)</td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder">
	  <%if(vRetResult.elementAt(i + 1) == null) {%>&nbsp;<%}else{%>
	  	<%=astrConvertBlockReason[Integer.parseInt((String)vRetResult.elementAt(i + 1))]%>
	  <%}%>	
	  </td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%></td>
    </tr>
    <%}//end of for loop.%>
  </table>
<%}//show only if vRetResult is not null%>
</body>
</html>
<%
dbOP.cleanUP();
%>