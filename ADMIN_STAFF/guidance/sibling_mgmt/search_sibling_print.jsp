<%@ page language="java" import="utility.*, enrollment.PersonalInfoManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Sibling</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body onLoad="window.print();">
<%
	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;

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
															"Guidance & Counseling","Student Tracker",request.getRemoteAddr(),
															"search_sibling.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../admin_staff/admin_staff_home_button_content.htm");
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
	
	int i = 0;
	int iSearchResult = 0;
	Vector vRetResult = null;
	PersonalInfoManagement pim = new PersonalInfoManagement();
	
		vRetResult = pim.searchSibling(dbOP, request);
		if(vRetResult == null)
			strErrMsg = pim.getErrMsg();
		else
			iSearchResult = pim.getSearchCount();

	boolean bolShowName = false;
if(WI.fillTextValue("show_name").length() > 0)
	bolShowName = true;
	
%>
		<%int iCount = 1;
if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr> 
			<td align="right">&nbsp;</td>
		</tr>
	</table>
<%if(bolShowName) {%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder" bgcolor="#FFFFFF">
		<tr bgcolor="#C4D0DD"> 
			<td height="25" colspan="3" align="center" class="thinborder"><strong>::: SIBLING SEARCH RESULTS ::: </strong></td>
		</tr>
		<tr> 
			<td height="25" colspan="2" class="thinborderBOTTOMLEFT">
				<strong>Total Results: <%=iSearchResult%></strong></td>
            <td height="25" align="right" class="thinborderBOTTOM">Date and time printed: <%=WI.getTodaysDateTime()%></td>
		</tr>
	<%
	 String strParentIndex = null;
	while(vRetResult.size() > 0) {
	 	iCount = 1;
		strParentIndex = (String)vRetResult.elementAt(0);%>
		<tr>
			<td height="25" colspan="3" class="thinborder"><strong> &nbsp;&nbsp; Father/Mother Name : <%=vRetResult.elementAt(1)%>/<%=vRetResult.elementAt(2)%></strong><strong></strong></td>
		</tr>
		<%while(vRetResult.size() > 0) {
			if(!vRetResult.elementAt(0).equals(strParentIndex))
				break;
			%>
			<tr>
				<td width="3%" height="25" align="center" class="thinborder"><%=iCount++%></td>
				<td width="30%" class="thinborder"><%=vRetResult.elementAt(6)%></td>
				<td width="67%" class="thinborder"><%=WebInterface.formatName((String)vRetResult.elementAt(3), (String)vRetResult.elementAt(4), (String)vRetResult.elementAt(5), 4)%></td>
			</tr>
		<%vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);}%>
	<%}%>
	</table>
<%}else{%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder" bgcolor="#FFFFFF">
		<tr bgcolor="#C4D0DD"> 
			<td height="25" colspan="4" align="center" class="thinborder"><strong>::: SIBLING SEARCH RESULTS ::: </strong></td>
		</tr>
		<tr> 
			<td height="25" colspan="2" class="thinborderBOTTOMLEFT">
				<strong>Total Results: <%=iSearchResult%></strong></td>
            <td height="25" class="thinborderBOTTOM" align="right" colspan="2">Date and time printed: <%=WI.getTodaysDateTime()%></td>
        </tr>
		<tr>
			<td height="25" align="center" class="thinborder" width="8%"><strong>Count</strong></td>
			<td align="center" class="thinborder" width="35%"><strong>Father's Name</strong></td>
			<td align="center" class="thinborder" width="35%"><strong>Mother's Name</strong></td>
			<td align="center" class="thinborder" width="12%"><strong>Children</strong></td>
		</tr>
	<%
	iCount = 1;
	for(i = 0; i < vRetResult.size(); i += 4, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
		</tr>
	<%}%>
	</table>
<%}%>	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
<%}%>

	<input type="hidden" name="search_sibling">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>