<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	WebInterface WI = new WebInterface(request);	

	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-PREVENTIVE_MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
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

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Inventory -PREVENTIVE MAINTENANCE","view_maintenance_status.jsp");
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
	
int iElemCount = 0;
Vector vRetResult = new Vector();

String[] strStatus = {"On-going","Complete"};
inventory.InvPreventiveMaintenance prevMain = new inventory.InvPreventiveMaintenance();

	vRetResult = prevMain.generateMaintenanceStatus(dbOP, request);
	if(vRetResult == null)
		strErrMsg = prevMain.getErrMsg();
	else{		
		iElemCount = prevMain.getElemCount();
	}


if(vRetResult != null && vRetResult.size() > 0){

String strSchName = SchoolInformation.getSchoolName(dbOP, true, false);
String strSchAddr = SchoolInformation.getAddressLine1(dbOP, false, false);

int iRowCount = 0;
int iRowCountPerPage = 35;

if(WI.fillTextValue("rows_per_pg").length() > 0)
	iRowCountPerPage = Integer.parseInt(WI.fillTextValue("rows_per_pg"));

int iPageCount = 0;
int iTotalCount = (vRetResult.size()/iElemCount);
int iTotalPageCount = iTotalCount/iRowCountPerPage;
if(iTotalCount % iRowCountPerPage > 0)
	++iTotalPageCount;
boolean bolPageBreak = false;

for(int i = 0 ; i < vRetResult.size() ;){
iRowCount = 0;
if(bolPageBreak){
bolPageBreak = false;
%>
<div style="page-break-after:always;">&nbsp;</div>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td align="center"><strong style="font-size:14px"><%=strSchName%></strong><br><%=strSchAddr%>
		<br><br>LIST OF MAINTENANCE STATUS
		<br><%
		strTemp = WI.fillTextValue("date_fr");
		strErrMsg = WI.fillTextValue("date_to");
		if(strTemp.length() > 0){
			if(strErrMsg.length() > 0)
				strTemp = "From "+strTemp+" to "+strErrMsg;
			else
				strTemp = "As of "+strTemp;
		}		
		%><%=strTemp%><br><div style="text-align:right">Page <%=++iPageCount%> of <%=iTotalPageCount%></div></td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr style="font-weight:bold">
	    <td align="center" width="10%" class="thinborder">Date</td>
	    <td align="center" width="9%" class="thinborder">Property No</td>
	    <td align="center" width="14%" class="thinborder">Item Name</td>
	    <td align="center" width="13%" class="thinborder">Office/Department</td>
	    <td align="center" width="11%" class="thinborder">Building/Room</td>
	    <td align="center" width="8%" height="25" class="thinborder">Category</td>
	    <td align="center" width="8%" class="thinborder">Classification</td>
	    <td align="center" width="7%" class="thinborder">Serial Number</td>
	    <td align="center" width="9%" class="thinborder">Product Number</td>
	    <td align="center" width="11%" class="thinborder">Status</td>
	</tr>
<%


for(; i < vRetResult.size() ; i+=iElemCount){

if(++iRowCount > iRowCountPerPage){
	bolPageBreak = true;
	iRowCount = 0;
	break;
}
%>
	<tr>
	    <td class="thinborder"><%=vRetResult.elementAt(i)%></td>
	    <td class="thinborder"><%=vRetResult.elementAt(i+1)%></td>
	    <td class="thinborder"><%=vRetResult.elementAt(i+2)%></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+6));
		strErrMsg = WI.getStrValue(vRetResult.elementAt(i+8));
		if(strTemp.length() > 0 && strErrMsg.length() > 0)
			strTemp += " / ";
		strTemp += strErrMsg;
		%>
	    <td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+10));
		strErrMsg = WI.getStrValue(vRetResult.elementAt(i+11));
		if(strTemp.length() > 0 && strErrMsg.length() > 0)
			strTemp += " / ";
		strTemp += strErrMsg;
		%>
	    <td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
	    <td height="25" class="thinborder"><%=vRetResult.elementAt(i+3)%></td>
	    <td height="25" class="thinborder"><%=vRetResult.elementAt(i+4)%></td>
	    <td height="25" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+12),"&nbsp;")%></td>
	    <td height="25" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+13),"&nbsp;")%></td>
	    <td class="thinborder"><%=strStatus[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+14),"0"))]%></td>
	</tr>
<%}%>
</table>
<%}}%>



</body>
</html>
<%
dbOP.cleanUP();
%>
