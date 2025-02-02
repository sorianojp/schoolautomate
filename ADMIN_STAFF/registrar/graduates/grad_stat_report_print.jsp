

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/common.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
	@media print { 
	  @page {
			margin-bottom:.1in;
			/*margin-top:.1in;
			margin-right:.1in;
			margin-left:.1in;*/
		}
	}
</style>
</head>
<body>
<%@ page language="java" import="utility.*,enrollment.GraduationDataReport,
							enrollment.EntranceNGraduationData,java.util.Vector"%>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	String strErrMsg = null;
	
	boolean bolIsPerCollege = (WI.getStrValue(WI.fillTextValue("is_per_course"),"0").equals("0"));

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Graduates","grad_stat_report.jsp");
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
														"Registrar Management","GRADUATES",request.getRemoteAddr(),
														"grad_stat_report.jsp");
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
Vector vRetResult  = null;


int iElemCount = 0;
enrollment.GraduationStatistics gradStat = new enrollment.GraduationStatistics();
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length()  >0){
	vRetResult = gradStat.getGraduationStatReport(dbOP, request, bolIsPerCollege,0);
	if(vRetResult == null)
		strErrMsg= gradStat.getErrMsg();
	else
		iElemCount = gradStat.getElemCount();
}


if(vRetResult != null && vRetResult.size() > 0){

String strSchName = SchoolInformation.getSchoolName(dbOP,true,false);
String strAddress = SchoolInformation.getAddressLine1(dbOP,false,false);
int iGradCount = 0;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong><%=strSchName%> </strong>
	<br><%=strAddress%><br>
<%if(!bolIsPerCollege){%>	
	<strong>GRADUATION REPORT</strong><br>
	Graduation Date : <strong><%=WI.formatDate(WI.fillTextValue("graduation_date"), 6)%></strong>
<%}else{%>
	<strong>Office of the Registrar</strong><br>
	Tentative Number of Graduates
<%}%>
	</td>
	</tr>
</table>

<%if(bolIsPerCollege){%>	
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td height="25" colspan="2"><strong><%=WI.formatDate(WI.fillTextValue("graduation_date"),6)%></strong></td></tr>
	<%
	
	for(int i = 0 ; i < vRetResult.size(); i+=iElemCount){
		iGradCount += Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
	%>
	<tr>
		<td width="40%" height="22" style="padding-left:60px;"><%=WI.getStrValue(vRetResult.elementAt(i),"N/A")%></td>
		<td width="60%"><%=WI.getStrValue(vRetResult.elementAt(i+1),"0")%> </td>
	</tr>
	<%}%>
	<tr>
		<td width="40%" height="22" align="right"><strong>Total : &nbsp; &nbsp;</strong></td>
		<td width="60%"><strong><%=iGradCount%></strong></td>
	</tr>
</table>
<%}else{

int iRowCount = 1;
int iNoOfStudPerPage = 35;

if(WI.fillTextValue("rows_per_pg").length() > 0)
	iNoOfStudPerPage = Integer.parseInt(WI.fillTextValue("rows_per_pg"));			

int iPageCount = 1;
int iTotalStud = (vRetResult.size()/iElemCount);
int iTotalPageCount = iTotalStud/iNoOfStudPerPage;
if(iTotalStud % iNoOfStudPerPage > 0)
	++iTotalPageCount;
boolean bolPageBreak = false;

int iTemp  =0;
int iMaleTot = 0;
int iFemaleTot = 0;
for(int i = 0; i < vRetResult.size(); ){
	iRowCount = 1;
	if(bolPageBreak){
		bolPageBreak = false;
		%>
		<div style="page-break-after:always;">&nbsp;</div>
	<%}
%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="20%" height="22" align="center" class="thinborderTOPBOTTOM"><strong>Course Code</strong></td>
		<td align="center" class="thinborderTOPBOTTOM"><strong>Course Description</strong></td>
		<td width="10%" align="center" class="thinborderTOPBOTTOM"><strong>Male</strong></td>
		<td width="10%" align="center" class="thinborderTOPBOTTOM"><strong>Female</strong></td>
		<td width="10%" align="center" class="thinborderTOPBOTTOM"><strong>Total</strong></td>
	</tr>
	<%
	for(; i < vRetResult.size();){
	%>
	<tr>
		<td height="22"><%=WI.getStrValue(vRetResult.elementAt(i),"N/A")%></td>
		<td><%=WI.getStrValue(vRetResult.elementAt(i+1),"N/A")%></td>
		<td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+2),"0")%></td>
		<td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+3),"0")%></td>
		<%
		
		iMaleTot += Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+2),"0"));
		iFemaleTot += Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+3),"0"));
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+2),"0"))+Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+3),"0"));
		%>
		<td align="center"><%=iTemp%></td>
	</tr>
	<%
	i+=iElemCount;
	if(++iRowCount > iNoOfStudPerPage){				
		bolPageBreak = true;
		break;
	}
	}%>
	
	<tr>
		<td align="right" colspan="2" class="thinborderTOP" height="22">&nbsp;</td>
		<td align="center" class="thinborderTOP"><strong><%=iMaleTot%></strong></td>
		<td align="center" class="thinborderTOP"><strong><%=iFemaleTot%></strong></td>
		<td align="center" class="thinborderTOP"><strong><%=iFemaleTot+iMaleTot%></strong></td>
	</tr>
	<tr><td colspan="5" valign="bottom">Page <%=iPageCount++%> of <%=iTotalPageCount%></td></tr>
</table>
<%}//end of outer loop
}%>
<script>window.print();</script>
<%}else{%>
<div style="text-align:center; font-size:13px; color:#FF0000;"><%=WI.getStrValue(strErrMsg)%></div>
<%}%>



</body>
</html>
<%
dbOP.cleanUP();
%>
