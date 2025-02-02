<%@ page language="java" import="utility.*, Accounting.billing.BillingTsuneishi, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>AC Proj Billing Manangement</title>
</head>
<body onload="window.print();">
<script language="javascript" src="../../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BILLING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
								"ACCOUNTING-BILLING","project_billing_mgmt.jsp");
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

	Vector vProjectInfo = null;
	Vector vRetResult = null;
	
	BillingTsuneishi billTsu = new BillingTsuneishi();
	
	vProjectInfo = billTsu.getProjectInfo(dbOP, request);
	vRetResult = billTsu.operateOnProjectBillings(dbOP, request, 3);
	
	if(vProjectInfo != null && vProjectInfo.size() > 0){%>
	
	<table width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td width="50%" height="25" align="left" style="font-size:9px;">Page 1 of 1</td>
		  	<td width="50%" align="right" style="font-size:9px;">Date and Time Printed : <%=WI.getTodaysDateTime()%>&nbsp;</td>
 	  </tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong>Project Information: </strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="22%">Project Name: </td>
			<td width="75%">&nbsp;<%=(String)vProjectInfo.elementAt(1)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Project Detail: </td>
			<td><div align="justify">&nbsp;<%=(String)vProjectInfo.elementAt(2)%></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Project Timetable: </td>
			<td>&nbsp;<%=(String)vProjectInfo.elementAt(3)%> - <%=(String)vProjectInfo.elementAt(4)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Project Lead: </td>
			<td>&nbsp;<%=(String)vProjectInfo.elementAt(6)%></td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15" colspan="3"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Billing Date: </td>
		    <td colspan="2"><%=(String)vRetResult.elementAt(6)%></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Billing Reference: </td>
		    <td><%=(String)vRetResult.elementAt(7)%></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Billing #: </td>
		    <td><%=(String)vRetResult.elementAt(8)%></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Bill Amount: </td>
	      	<td><%=CommonUtil.formatFloat((String)vRetResult.elementAt(2), true)%></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Start Date : </td>
		    <td><%=(String)vRetResult.elementAt(3)%></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>End Date: </td>
		    <td colspan="2"><%=(String)vRetResult.elementAt(4)%></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Manpower: </td>
		    <td><%=(String)vRetResult.elementAt(5)%></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Project Detail: </td>
		    <td><%=WI.getStrValue((String)vRetResult.elementAt(9))%></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Special Instruction: </td>
		    <td><%=WI.getStrValue((String)vRetResult.elementAt(10))%></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Notes: </td>
		    <td><%=WI.getStrValue((String)vRetResult.elementAt(11))%></td>
	    </tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="23%">Project Leader: </td>
			<td width="75%"><%=(String)vRetResult.elementAt(14)%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>