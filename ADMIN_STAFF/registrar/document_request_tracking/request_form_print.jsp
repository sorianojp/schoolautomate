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
	if(WI.fillTextValue("transaction_no").length() > 0){
		
		vRetResult = docReq.getItemReadyForPrint(dbOP, request, WI.fillTextValue("transaction_no"));
		if(vRetResult == null)
			strErrMsg = docReq.getErrMsg();				
		
	}
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
          <font size="2"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font><br><br>
		  <font size="2"><strong>OFFICE OF THE REGISTRAR</strong></font><br><br><br></div></td>
	</tr>
	
</table>


<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td class="thinborder" height="23" colspan="10" align="center"><strong>LIST OF DOCUMENT REQUESTED</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="23" width="20%"><strong>DOCUMENT NAME</strong></td>
		<td class="thinborder" width="12%"><strong>EXPECTED RELEASE DATE</strong></td>
		<td class="thinborder"><strong>REQUIREMENTS</strong></td>
		<td class="thinborder" width="30%"><strong>REMARKS</strong></td>
		<td class="thinborder" width="20%" align="center"><strong>RECEIVED BY</strong></td>
	</tr>
	<%
	
	
	String strCurrDoc = "";
	String strPrevDoc = "";
	String strReleaseDate = "";
	String strDocRequirement = "";
	int iIndexOf = 0;
	boolean bolDisplayData = false;
	String strReceivedBy = null;
	String strRemarks = "";
	for(int i = 0; i < vRetResult.size(); i+=6){
		strCurrDoc = (String)vRetResult.elementAt(i+1);		
		strReleaseDate = (String)vRetResult.elementAt(i+2);
		strReceivedBy = (String)vRetResult.elementAt(i+5);
		strRemarks = (String)vRetResult.elementAt(i+4);
		
		if((String)vRetResult.elementAt(i+3) != null){
			if(strDocRequirement.length()==0)
				strDocRequirement = (String)vRetResult.elementAt(i+3)+";";
			else
				strDocRequirement += "<br>"+(String)vRetResult.elementAt(i+3)+";";
		}
		
		iIndexOf = i + 7;
		if(iIndexOf > vRetResult.size())
			iIndexOf = iIndexOf - 7;
		
		strPrevDoc = (String)vRetResult.elementAt(iIndexOf);
			
		if(!strPrevDoc.equals(strCurrDoc))
			bolDisplayData = true;
		else
			bolDisplayData = false;			
			
		if(bolDisplayData){				
			bolDisplayData = false;	
	%>
	<tr>
		<td class="thinborder" height="23"><%=strCurrDoc.toUpperCase()%></td>
		<td class="thinborder"><%=strReleaseDate.toUpperCase()%></td>
		<td class="thinborder"><%=WI.getStrValue(strDocRequirement.toUpperCase(),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(strRemarks,"&nbsp;")%></td>
		<td class="thinborder"><%=strReceivedBy%></td>
	</tr>	
		<%strDocRequirement = "";}
	}%>
</table>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td height="50" colspan="4">&nbsp;</td></tr>
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
	<tr>
		<td colspan="4"><font size="1">Printed Date and Time : <%=WI.getTodaysDateTime()%></font></td>
	</tr>
</table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>