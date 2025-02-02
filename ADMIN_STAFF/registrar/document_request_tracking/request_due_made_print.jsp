<%@ page language="java" import="utility.*, enrollment.DocRequestTracking, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userIndex") == null){
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Document Request Tracking","request_due_made_print.jsp");
	}
	catch(Exception exp) {
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
														"Registrar Management","Document Request Tracking",request.getRemoteAddr(),
														"request_due_made_print.jsp");
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
	
	int iSearchResult = 0;	
	DocRequestTracking docReq = new DocRequestTracking();
	Vector vRetResult = new Vector();
	
	strTemp = WI.getStrValue(WI.fillTextValue("show_in"),"1");
	vRetResult = docReq.getRequestDueAndMade(dbOP, request, Integer.parseInt(strTemp));
	if(vRetResult == null)
		strErrMsg = docReq.getErrMsg();	

%>
<body <%if(strErrMsg == null){%>onLoad="window.print();"<%}%>>
<%
if(strErrMsg != null){%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
	<tr><td align="center"><font size="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>
</table>
<%}if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr><td><div align="center"><strong><font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br>
	  <font size="2"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font><br>
	  <font size="2"><strong>OFFICE OF THE REGISTRAR</strong></font></div></td>
</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
<tr> 
	<%
		strTemp = "REQUEST";
		if(WI.fillTextValue("show_in").equals("1"))
			strTemp = "DUE REQUEST";
	%>
	<td height="20" colspan="11" class="thinborderBOTTOM"><div align="center"><strong>TODAY'S <%=strTemp%> (<%=WI.getTodaysDate(6)%>) </strong></div></td>
</tr>	
<tr>
	<td colspan="4" align="right"><font size="1">Printed Date and Time : <%=WI.getTodaysDateTime()%></font></td>
</tr>
</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
				
		<tr>
			<td height="23" class="thinborder" width="5%"><strong>COUNT</strong></td>
			<td class="thinborder" width="12%"><strong>DATE REQUESTED</strong></td>
			<td class="thinborder" width="20%"><strong>STUDENT NAME</strong></td>
			<td class="thinborder" width="15%"><strong>DOCUMENT NAME</strong></td>
			<td class="thinborder" width="12%"><strong>EXPECTED RELEASE DATE </strong></td>
			<td class="thinborder" ><strong>REQUIREMENTS</strong></td>
			<td class="thinborder" align="center" width="17%"><strong>REMARKS</strong></td>
		</tr>
	<%	int iCount = 1;
		String strReleased = null;
		String strDocRequirement = null;
		Vector vReqList = new Vector();
		
		for(int i = 0; i < vRetResult.size(); i += 9){
			strReleased = (String)vRetResult.elementAt(i+7);
			strDocRequirement = "";
			vReqList = (Vector)vRetResult.elementAt(i+5);
				if(vReqList.size() > 0) {
					for(int x = 0; x < vReqList.size(); x++){
						if((String)vReqList.elementAt(x) != null){
							if(strDocRequirement.length() == 0)
								strDocRequirement = (String)vReqList.elementAt(x)+";";
							else
								strDocRequirement += "<br>"+(String)vReqList.elementAt(x)+";";						
						}
						
					}
				}
			
		
		%>
		<tr>
			<td height="23" class="thinborder"><%=iCount++%>.</td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder"><%=WI.getStrValue(strDocRequirement,"&nbsp;")%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%></td>
		</tr>
		<%}%>
	</table>
	
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td height="30" colspan="4">&nbsp;</td></tr>
	<tr>
		<td width="10%" height="23" align="right">Printed By : &nbsp;</td>
		<td width="40%" class="thinborderBOTTOM" align="center"><%=(String)request.getSession(false).getAttribute("first_name")%></td>
		<td width="10%" align="right">Noted By : &nbsp;</td>
		<td class="thinborderBOTTOM" align="center"><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"University Registrar",1),"&nbsp;")%></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td align="center">&nbsp;</td>
		<td>&nbsp;</td>
		<td align="center">University Registrar</td>
	</tr>
	
</table>
<%}%>	
</body>
</html>
<%
dbOP.cleanUP();
%>