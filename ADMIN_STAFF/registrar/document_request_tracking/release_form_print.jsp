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
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">

</head>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Document Request Tracking","release_document.jsp");		
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
														"release_document.jsp");
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
	Vector vRetResult = null;	
	
	vRetResult = docReq.getItemReadyForPrint(dbOP, request, WI.fillTextValue("id_number"));
	if(vRetResult == null)
		strErrMsg = docReq.getErrMsg();				
	
%>
<body <%if(strErrMsg == null){%>onLoad="window.print();"<%}%>>
<%
if(strErrMsg != null){%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
	<tr><td align="center"><font size="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>
</table>
<%}
if(vRetResult != null && vRetResult.size() > 0){%>

<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td><div align="center"><strong><font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br>
          <font size="2"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font><br>
		  <font size="2"><strong>OFFICE OF THE REGISTRAR</strong></font></div></td>
	</tr>
	
</table>

<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	  <td height="23" colspan="10" align="center"><strong>LIST OF DOCUMENT RELEASED </strong></td>
	</tr>
	<tr><td colspan="4" align="right"><font size="1">Printed Date and Time : <%=WI.getTodaysDateTime()%></font></td></tr>
</table>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	
	<tr>
		<td class="thinborder" height="23" width="20%"><strong>DOCUMENT NAME</strong></td>
		<td class="thinborder" width="12%"><strong>RELEASED DATE</strong></td>
		<td class="thinborder"><strong>REQUIREMENTS</strong></td>
		<td class="thinborder" width="30%"><strong>REMARKS</strong></td>
		<td class="thinborder" width="20%" align="center"><strong>RECEIVED BY</strong></td>
	</tr>
	<%
	
	
	
	String strDocRequirement = "";	
	Vector vReqList = new Vector();
	for(int i = 0; i < vRetResult.size(); i+=6){
		strDocRequirement = "";
		vReqList = (Vector)vRetResult.elementAt(i+3);
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
		<td class="thinborder" height="23"><%=((String)vRetResult.elementAt(i+1)).toUpperCase()%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(strDocRequirement.toUpperCase(),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
	</tr>	
	<%}%>
</table>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td height="30" colspan="4">&nbsp;
	<%if(WI.fillTextValue("print_remark").length() > 0) {%>
		<br>Remark: <%=WI.fillTextValue("print_remark")%><br><br>
	<%}%>
	</td></tr>
	<tr>
		<td width="9%" height="23">Printed By:</td>
	  <td width="31%" class="thinborderBOTTOM" align="center"><%=(String)request.getSession(false).getAttribute("first_name")%></td>
		<td width="29%" align="right">Noted By : &nbsp;</td>
		<td width="31%" align="center" class="thinborderBOTTOM"><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"University Registrar",1),"&nbsp;")%></td>
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