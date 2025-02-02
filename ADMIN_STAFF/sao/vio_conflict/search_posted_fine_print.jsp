<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<body>
<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.ViolationConflict"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-VIOLATIONS & CONFLICTS","search_posted_fine.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.


CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs","VIOLATIONS & CONFLICTS",request.getRemoteAddr(),
														"search_posted_fine.jsp");
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
enrollment.OfflineAdmission offAdm = new enrollment.OfflineAdmission();
osaGuidance.ViolationConflict violation = new osaGuidance.ViolationConflict();

Vector vStudInfo = null;
Vector vRetResult = null;

String strStudId = WI.fillTextValue("stud_id");
int iElemCount =0;

	strErrMsg = null;
	if(strStudId.length() > 0){
		vStudInfo = offAdm.getStudentBasicInfo(dbOP, strStudId, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
		if(vStudInfo == null)
			strErrMsg = offAdm.getErrMsg();
		else
			strStudId = (String)vStudInfo.elementAt(12);
	}
	
	
	if(strErrMsg == null){
		strTemp = WI.getStrValue(WI.fillTextValue("not_posted"),"1");
		
		vRetResult = violation.getStudViolationFine(dbOP, request, strStudId, Integer.parseInt(strTemp));
		if(vRetResult == null)
			strErrMsg = violation.getErrMsg();
		else
			iElemCount = violation.getElemCount();
	}



int iCount = 0;

if(strErrMsg != null){dbOP.cleanUP();%>
<div style="text-align: center; font-size:13px; color: #FF0000; font-weight:bold;"><%=strErrMsg%></div>
<%return;}
if(vRetResult != null && vRetResult.size() > 0){

int iRowCount = 0;
int iMaxRowCount = 35;
if(WI.fillTextValue("rows_per_pg").length() > 0)
	iMaxRowCount = Integer.parseInt(WI.fillTextValue("rows_per_pg"));



String strSchName = SchoolInformation.getSchoolName(dbOP, true, false);
String strSchAddr = SchoolInformation.getAddressLine1(dbOP, false, false);
String strCurrID = null;
String strPrevID = "";
boolean bolPageBreak = false;
for(int i = 0 ; i < vRetResult.size(); ){
iRowCount = 0;

if(bolPageBreak){
	bolPageBreak = false;
%>
<div style="page-break-after:always;">&nbsp;</div>
<%}%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="center" headers="25"><strong style="font-size:13px;"><%=strSchName%></strong><br><%=strSchAddr%><br>
	<%
	strTemp = "";
	if(WI.fillTextValue("date_post_fr").length() > 0 && WI.fillTextValue("date_post_to").length() == 0)
		strTemp = "Date Posted : "+WI.fillTextValue("date_post_fr");
	else if(WI.fillTextValue("date_post_fr").length() > 0 && WI.fillTextValue("date_post_to").length() > 0)
		strTemp = "Date Posted : "+WI.fillTextValue("date_post_fr")+" to "+WI.fillTextValue("date_post_to");
		
	if(WI.fillTextValue("violation_date_fr").length() > 0 && WI.fillTextValue("violation_date_to").length() == 0)
		strTemp = "Violation Date : "+WI.fillTextValue("violation_date_fr");
	else if(WI.fillTextValue("violation_date_fr").length() > 0 && WI.fillTextValue("violation_date_to").length() > 0)
		strTemp = "Violation Date : "+WI.fillTextValue("violation_date_fr")+" to "+WI.fillTextValue("violation_date_to");
	%><%=strTemp%>
	</td></tr>
	<tr>
	    <td align="center" headers="25" height="25">&nbsp;</td>
    </tr>
</table>

<%
if(vStudInfo != null && vStudInfo.size() > 0){
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%">Student Name</td>
	  <%
	  strTemp = WebInterface.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),4);
	  %>
      <td><strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Course/Major(cy)</td>
      <td><strong><%=(String)vStudInfo.elementAt(7)%>
        <%if(vStudInfo.elementAt(8) != null){%>
        /<%=(String)vStudInfo.elementAt(8)%>
        <%}%>
        (<%=(String)vStudInfo.elementAt(3)%> to <%=(String)vStudInfo.elementAt(4)%>
        )</strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>YEAR LEVEL</td>
      <td><strong><%=WI.getStrValue(vStudInfo.elementAt(14),"0")%></strong></td>
    </tr>    
        
</table>
<%}%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
<%
strTemp = WI.fillTextValue("not_posted");
if(strTemp.equals("0"))
	strTemp = "LIST OF VIOLATION NOT POSTED";
else
	strTemp = "LIST OF VIOLATION POSTED";
%>
	<tr><td align="center" colspan="7" height="25" class="thinborder"><strong><%=strTemp%></strong></td></tr>
	<tr style="font-weight:bold;">
		<td width="11%" height="22"  align="center" class="thinborder">Date of Violation</td>
		<td width="14%" class="thinborder" align="center">Incident Type</td>
		<td width="16%" class="thinborder" align="center">Incident</td>
		<td width="21%" class="thinborder" align="center">Report Description</td>
		<td width="16%" class="thinborder" align="center">Remark</td>
	<%
	if(WI.fillTextValue("not_posted").length() == 0){
	%>
		<td width="11%" class="thinborder" align="center">Date Posted</td>
		<td width="7%" class="thinborder" align="center">Amount</td>
	<%}%>
	</tr>
	<%
	
	for( ; i < vRetResult.size(); i+=iElemCount){	
	if(++iRowCount > iMaxRowCount){
		bolPageBreak = true;
		break;
	}	
	strCurrID = (String)vRetResult.elementAt(i+19);	
	if(!strPrevID.equals(strCurrID) && WI.fillTextValue("stud_id").length() == 0){
		strPrevID = strCurrID;
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+20),(String)vRetResult.elementAt(i+21),(String)vRetResult.elementAt(i+22),4);
	%>
	<tr>
	    <td height="22" colspan="7" class="thinborder"><strong>Student Name : <%=strTemp%> (<%=strCurrID%>)</strong></td>
    </tr>
	<%}%>	
	<tr>
	    <td height="22" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+2),"&nbsp;")%></td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+4),"&nbsp;")%></td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+6),"&nbsp;")%></td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+7),"&nbsp;")%></td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+10),"&nbsp;")%></td>		
	<%if(WI.fillTextValue("not_posted").length() == 0){%>
	    <td class="thinborder" align="center"><%=vRetResult.elementAt(i+17)%>&nbsp;</td>
	    <td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+16), true)%>&nbsp;</td>
	<%}%>		
    </tr>
	<%}%>
	
</table>
<%}//end of outer loop%>
<script>window.print();</script>
<%}%>


</body>
</html>
<%
dbOP.cleanUP();
%>
