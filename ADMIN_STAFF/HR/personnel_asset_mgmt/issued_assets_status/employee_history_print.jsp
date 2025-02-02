<%@ page language="java" import="utility.*,java.util.Vector,hr.PersonnelAssetManagement"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Issued Item Status</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script src="../../../../jscript/td.js"></script>
<script src="../../../../jscript/common.js"></script>
<body onLoad="window.print();">
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-PERSONNEL ASSET MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Personnel Asset Management-Employee History","employee_history.jsp");
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
	
	Vector vUserInfo = null;
	Vector vRetResult = null;	
	int i = 0;
	int iSearchResult = 0;
	PersonnelAssetManagement  pam = new PersonnelAssetManagement();
  
	enrollment.Authentication auth = new enrollment.Authentication();
    request.setAttribute("emp_id", WI.fillTextValue("emp_id"));
    
	vUserInfo = auth.operateOnBasicInfo(dbOP, request, "0");
	if(vUserInfo != null)
		vRetResult = pam.viewEmployeeIssueItemHistory(dbOP, request, (String)vUserInfo.elementAt(0));
			
	if(vRetResult != null){
		int iCount = 0;
		int iNumRec = 0;
%>
	<table width="100%"  border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="3" align="center"><strong>:::: EMPLOYEE ISSUED ITEM HISTORY ::::</strong></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr> 
			<td height="10" colspan="2"><strong>EMPLOYEE INFORMATION: </strong></td>
		</tr>
		<tr> 
			<td height="10" colspan="2">&nbsp;</td>
		</tr>
		<tr> 
			<td width="15%" height="10">Name:</td>
			<td width="85%"><%=WebInterface.formatName((String)vUserInfo.elementAt(1),(String)vUserInfo.elementAt(2),(String)vUserInfo.elementAt(3),7)%></td>
		</tr>
		<tr> 
			<td>Dept/Office:</td>
			<%
				if((String)vUserInfo.elementAt(13)== null || (String)vUserInfo.elementAt(14)== null)
					strTemp = " ";			
				else
					strTemp = " - ";
			%>
			<td>
				<%=WI.getStrValue((String)vUserInfo.elementAt(13),"")%>
				<%=strTemp%>
				<%=WI.getStrValue((String)vUserInfo.elementAt(14),"")%> 
			</td>
		</tr>
		<tr> 
			<td height="10" colspan="2">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
			<td height="20" align="center" colspan="8" class="thinborder"><strong>EMPLOYEE ISSUED ITEM HISTORY</strong></td>
		</tr>
		<tr>
			<td width="5%"  height="23" class="thinborder">&nbsp;</td>
			<td width="23%" align="center" class="thinborder"><strong><font size="1">PROPERTY #. </font></strong></td>
			<td width="24%" align="center" class="thinborder"><strong><font size="1">DATE ISSUED </font></strong></td>
			<td width="24%" align="center" class="thinborder"><strong><font size="1">ISSUED BY </font></strong></td>
			<td width="24%" align="center" class="thinborder"><strong><font size="1">STATUS</font></strong></td>
		</tr>
		<% 		
			for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=7, ++iCount){
				i = iNumRec;
				strTemp = (String)vRetResult.elementAt(i+5);//to be returned?
				strErrMsg = (String)vRetResult.elementAt(i+1);//returned date
		%>
		<tr>
			<td height="25" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
			<td class="thinborder">
			<%=WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),7)%></td>
			<%
				if(strErrMsg != null)
					strErrMsg = "RETURNED";
				else{//else if the returned date is not null
					if(strTemp.equals("1"))
						strErrMsg = "UNRETURNED";
					else
						strErrMsg = "NOT TO BE RETURNED";
				}
			%>
			<td class="thinborder"><%=strErrMsg%></td>
		</tr>
		<%} //end for loop%>
	</table>
 	<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>