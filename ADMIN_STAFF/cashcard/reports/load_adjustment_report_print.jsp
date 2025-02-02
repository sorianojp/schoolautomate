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

<title>Load Adjustment</title>
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
								"Admin/staff-Cash Card-Reports","terminal_report.jsp");	
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
	
	int iElemCount    = 7; //vector row count	
	
	Vector vRetResult = null;
	ReportManagement reportMgt = new ReportManagement();
	vRetResult = reportMgt.getLoadAdjustmentReport(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportMgt.getErrMsg();

%>
<body>


<%if(strErrMsg != null){%>
	<div align="center"><strong><font size="2" color="#FF0000"><%=strErrMsg%></font></strong></div>
<%}

if(vRetResult != null && vRetResult.size() > 0){


String strSchName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchAdd = SchoolInformation.getAddressLine1(dbOP,false,true);

int iRowCount = 1;
int iNoOfRowPerPage = 45;

if(WI.fillTextValue("rows_per_pg").length() > 0)
	iNoOfRowPerPage = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
	
String strDebit = null;
String strCredit = null;
String strUserIndex = "";
String strPrevUserIndex = "";

int iPageCount = 1;
int iTotalCount = (vRetResult.size()/iElemCount);
int iTotalPageCount = iTotalCount/iNoOfRowPerPage;
if(iTotalCount % iNoOfRowPerPage > 0)
	++iTotalPageCount;
boolean bolPageBreak = false;
int iCount = 1;
double dTotAmt = 0d;
for(int i = 0; i < vRetResult.size();){
	iRowCount = 1;
	if(bolPageBreak){
		bolPageBreak = false;
%>
	<div style="page-break-after:always;">&nbsp;</div>
	<%}%>
	
	<table width="100%" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">	
	<%
	strTemp = " FOR " + WI.getStrValue("date_fr") + WI.getStrValue(WI.fillTextValue("date_to")," TO ","","");
	%>
	<tr><td align="center"><strong>
		<%=strSchName%><br>
		<%=strSchAdd%><br>
		LOAD ADJUSTMENT REPORT<br><%=strTemp%>
	</strong></td></tr>
</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder">
		
		<tr>
		<td align="center" class="thinborder"><strong>Name</strong></td>
		<td width="15%" height="22" align="center" class="thinborder"><strong>Date</strong></td>		
		<td width="20%" align="center" class="thinborder"><strong>Debit</strong></td>
		<td width="20%" align="center" class="thinborder"><strong>Credit</strong></td>		
	</tr>
	<%
		for(; i < vRetResult.size(); i += iElemCount){
			strUserIndex = (String)vRetResult.elementAt(i);
		%>
		<tr>
		
			<%
			strTemp = "&nbsp;";
			if(!strPrevUserIndex.equals(strUserIndex))
				strTemp = (String)vRetResult.elementAt(i + 2)+WI.getStrValue((String)vRetResult.elementAt(i+1)," (",")","") + 
					WI.getStrValue((String)vRetResult.elementAt(i + 3), " - ", "", "");
			%>				
			<td class="thinborder"><%=strTemp%></td>
			<td height="22" class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td> <!-- DATE -->
			<%
			strDebit = null;
			strCredit = null;
			
			strTemp = (String)vRetResult.elementAt(i + 6);
			if(strTemp.equals("1"))
				strDebit = (String)vRetResult.elementAt(i + 4);
			else
				strCredit = (String)vRetResult.elementAt(i + 4);
			%>
			<td class="thinborder" align="right"><%=WI.getStrValue(strDebit,"&nbsp;")%></td><!---DEBIT-->
			<td class="thinborder" align="right"><%=WI.getStrValue(strCredit,"&nbsp;")%></td><!---CREDIT--->
			
			
		</tr>
		
	<%
	strPrevUserIndex = strUserIndex;
	
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