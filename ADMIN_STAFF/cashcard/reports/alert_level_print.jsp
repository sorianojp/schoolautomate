<%@ page language="java" import="utility.*,cashcard.ReportManagement,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

<title>Alert Level</title>
</head>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD-REPORTS"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD"),"0"));
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
								"Admin/staff-Cash Card-Reports","daily_report.jsp");
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
	
	
	int iElemCount    = 13; //vector row count
	Vector vRetResult = null;
	
	ReportManagement reportMgmt = new ReportManagement();
	
	vRetResult = reportMgmt.getItemOnAlertLevel(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportMgmt.getErrMsg();

%>
<body>


<%if(strErrMsg != null){%>
	<div align="center"><strong><font size="2" color="#FF0000"><%=strErrMsg%></font></strong></div>
<%}

if(vRetResult != null && vRetResult.size() > 0){


int iRowCount = 1;
int iNoOfRowPerPage = 45;

if(WI.fillTextValue("rows_per_pg").length() > 0)
	iNoOfRowPerPage = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
	
String strSchName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchAdd = SchoolInformation.getAddressLine1(dbOP,false,true);	

int iPageCount = 1;
int iTotalCount = (vRetResult.size()/iElemCount);
int iTotalPageCount = iTotalCount/iNoOfRowPerPage;
if(iTotalCount % iNoOfRowPerPage > 0)
	++iTotalPageCount;
boolean bolPageBreak = false;
int iCount = 1;
for(int i = 0; i < vRetResult.size();){
	iRowCount = 1;
	if(bolPageBreak){
		bolPageBreak = false;
%>
	<div style="page-break-after:always;">&nbsp;</div>
	<%}%>
	
<table width="100%" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable2">	
	<tr><td align="center"><strong>
		<%=strSchName%><br>
		<%=strSchAdd%><br>
		Item on Inventory Alert Level
	</strong></td></tr>
</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder">
		
		<tr>
			<td width="15%" align="center" class="thinborder"><strong><font size="1">Department</font></strong></td>
			<td width="13%" align="center" class="thinborder"><strong><font size="1">Category Name</font></strong></td>
			<td width="15%" align="center" class="thinborder"><strong><font size="1">Item Code</font></strong></td>
			<td width="33%" align="center" class="thinborder"><strong><font size="1">Item Name</font></strong></td>
			<td width="9%" height="22" align="center" class="thinborder"><strong><font size="1">Selling Price</font></strong></td>		
			<td width="8%" align="center" class="thinborder"><strong><font size="1">Current Balance</font></strong></td>
			<td width="7%" height="22" align="center" class="thinborder"><strong><font size="1">Alert Level</font></strong></td>		
		</tr>
	<%
		for(; i < vRetResult.size(); i += iElemCount){%>
		<tr>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>								
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>		
			<td height="22" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%> &nbsp; </td>
			<td class="thinborder" align="">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true)%>&nbsp;</td>
			<td align="right" class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+6),true)%></td>
			<td class="thinborder" align="right">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>	
		</tr>
	<%
	if(iRowCount++ >= iNoOfRowPerPage){		
		i+=iElemCount;
		bolPageBreak = true;
		break;
	}
	}%>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
		<td width="48%"><font size="1">Date and Time Printed : <%=WI.formatDateTime(null,4)%></font></td>
		<td width="52%" height="16" align="right"><font size="1">Page <%=iPageCount++%> of <%=iTotalPageCount%></font></td>
	</tr>
	</table>
	
<%}//outer loop%>
<script>window.print();</script>	
<%}%>
	
</body>
</html>
<%
dbOP.cleanUP();
%>