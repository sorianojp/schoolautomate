<%@ page language="java" import="utility.*, health.AUFHealthProgram, java.util.Vector " %>
<%
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(8);
	//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Program Members Detail</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;	

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","program_members.jsp");
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
															"Health Monitoring","Clinic Visit Log",request.getRemoteAddr(),
															"program_members.jsp");
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
	
	String strInfoIndex = WI.fillTextValue("info_index");
	String strUserIndex = WI.fillTextValue("user_index");
	if(strInfoIndex.length() == 0 || strUserIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Member reference is not found. Please close this window.</p>
		<%return;
	}
	
	Vector vRetResult = null;
	
	String[] astrGender = {"", "Male", "Female"};
	String[] astrStatus = {"", "Single", "Married", "Widowed/Widower", "Separated"};
	
	AUFHealthProgram hp = new AUFHealthProgram();	
		
	vRetResult = hp.operateOnHealthProgramMembers(dbOP,request, 3, strUserIndex);
	if(vRetResult == null)
		strErrMsg = hp.getErrMsg();
	
%>
<body bgcolor="#8C9AAA" class="bgDynamic">
<form action="./program_members.jsp" method="post" name="form_">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#697A8F"> 
			<td height="25" class="footerDynamic" colspan="3"><div align="center"><font color="#FFFFFF">
				<strong>:::: HEALTH PROGRAM MEMBER DETAILS::::</strong></font></div></td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		<tr>
			<!--name,gender,civil status,contact number,address,relation,validity-->
			<td height="25" width="3%">&nbsp;</td>
			<td width="22%">Name:</td>
			<td width="75%"><%=(String)vRetResult.elementAt(1)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Date of Birth:</td>
			<td><%=(String)vRetResult.elementAt(2)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Gender:</td>
			<td><%=astrGender[Integer.parseInt((String)vRetResult.elementAt(3))]%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Civil Status: </td>
			<td><%=astrStatus[Integer.parseInt((String)vRetResult.elementAt(4))]%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Contact Num: </td>
			<td><%=(String)vRetResult.elementAt(5)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Address:</td>
			<td><%=(String)vRetResult.elementAt(6)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Relation:</td>
			<td><%=(String)vRetResult.elementAt(9)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Validity:</td>
			<td><%=(String)vRetResult.elementAt(10)%> - <%=WI.getStrValue((String)vRetResult.elementAt(11), "to date")%></td>
		</tr>
	</table>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="10">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
	<input type="hidden" name="user_index" value="<%=strUserIndex%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
