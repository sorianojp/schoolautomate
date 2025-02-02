<%@ page language="java" import="utility.*,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Leave</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<%
	String strErrMsg = null;
	String strTemp = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-MEMO"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if (bolMyHome)
		iAccessLevel = 1;
	
	if(iAccessLevel == -1)//for fatal error.
	{
		if(bolIsSchool)
			request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		else
			request.getSession(false).setAttribute("go_home","../../../index.jsp");
		
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"my_home","overtime.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}

	Vector vRetResult = null;
	Vector vRetDetail = null;
	
	hr.HRNotification  not = new hr.HRNotification();
		
	strTemp = (String)request.getSession(false).getAttribute("userId");	
	
	if (strTemp.length() > 0) {
		vRetResult = not.getPendingLeaveApplications(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
		if (vRetResult == null)
			strErrMsg = not.getErrMsg();
	}
%>
<body bgcolor="#FFFFFF"  class="bgDynamic">
<form action="./messages.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic" align="center">
	  	<font color="#FFFFFF" ><strong>:::: PENDING LEAVE APPLICATION DETAILS PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr > 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="16%" height="25">EMPLOYEE ID </td>
 	  <td height="25">
		<font size="3" color="#FF000"><strong><%=(String)request.getSession(false).getAttribute("userId")%> </strong> </font>	  </td>
    </tr>
    <tr>
      <td colspan="3" height="18">&nbsp;</td>
    </tr>
  </table>

<%
if (vRetResult != null && vRetResult.size() > 0) {%>
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
		  <td height="25" colspan="6" align="center" bgcolor="#F4F2F3" class="thinborder"><strong>LIST OF LEAVE APPLICATIONS </strong></td>
		</tr>
		<tr>
		  	<td width="13%" align="center" class="thinborder" height="25"><strong>DATE FILED</strong></td>
			<td width="22%" align="center" class="thinborder"><strong>DATE OF LEAVE </strong><strong></strong></td>
			<td width="13%" align="center" class="thinborder"><strong>DURATION</strong></td>
			<td width="16%" align="center" class="thinborder"><strong>TIME</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>REASON</strong></td>
			<td width="16%" align="center" class="thinborder"><strong>STATUS</strong></td>
		</tr>
	<% 
		String strTimeFormatTo = null;
		String strTimeFormatFrom = null;
		String strStatus = null;
		String strTableColor = "#FFFFFF";
		for(int i = 0; i < vRetResult.size(); i+=13){
			strStatus = (String)vRetResult.elementAt(i+12);
			if(strStatus.equals("0")){
				strStatus = "DISAPPROVED";
				strTableColor = "#999999";
			}
			else if (strStatus.equals("1")){
				strStatus = "APPROVED";
				strTableColor = "#FFFF00";
			}
			else
				strStatus = "PENDING";
	%> 
    	<tr bgcolor="<%=strTableColor%>">
    	  	<td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%><%=WI.getStrValue((String)vRetResult.elementAt(i + 5), " ::: ","","")%></td>
			<%
				double dTemp = 0d;
				if((String)vRetResult.elementAt(i+10) != null )
					dTemp = Double.parseDouble((String)vRetResult.elementAt(i+10));
				if(dTemp == 0){
					strTemp = (String)vRetResult.elementAt(i+11);
					if(strTemp.equals("0"))
						strTemp = "&nbsp;";
					else
						strTemp = strTemp += " days";
				}
				else
					strTemp = dTemp + " hrs.";
			%>
			<td class="thinborder"><%=strTemp%></td>
			<%
				strTimeFormatFrom = (String)vRetResult.elementAt(i+4);
				if(strTimeFormatFrom.equals("0"))
					strTimeFormatFrom = "AM";
				else
					strTimeFormatFrom = "PM";
					
				strTimeFormatTo = (String)vRetResult.elementAt(i+8);
				if(strTimeFormatTo.equals("0"))
					strTimeFormatTo = "AM";
				else
					strTimeFormatTo = "PM";
				
				if((String)vRetResult.elementAt(i+2)!=null){
					strTemp =  (String)vRetResult.elementAt(i+2) + ":" + (String)vRetResult.elementAt(i+3) + strTimeFormatFrom;
					if((String)vRetResult.elementAt(i+6)!=null)			
						strTemp =  strTemp + " to " + (String)vRetResult.elementAt(i+6) + ":" + (String)vRetResult.elementAt(i+7) + strTimeFormatTo;
				}
				else
					strTemp = "N/A";
		  	%>
			<td class="thinborder"><%=strTemp%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+9), "&nbsp")%></td>
			<td class="thinborder"><%=strStatus%></td>
    	</tr>
	<%}%> 
  </table>
<%}%> 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>