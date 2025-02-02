

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
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Graduates","grad_stat_report.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%return;
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
		
		vRetResult = gradStat.getGraduationStatReport(dbOP, request, bolIsPerCollege,1);
		if(vRetResult == null)
			strErrMsg= gradStat.getErrMsg();
		else
			iElemCount = gradStat.getElemCount();			
	}
	
	if(vRetResult != null && vRetResult.size() > 0){
	
	String strSchName = SchoolInformation.getSchoolName(dbOP,true,false);
	String strAddress = SchoolInformation.getAddressLine1(dbOP,false,false);
	int iGradCount = 1;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong><%=strSchName%> </strong>
	<br><%=strAddress%><br><BR>
	<strong>OFFICE OF THE REGISTRAR</strong><br>
	CANDIDATES FOR GRADUATION<br>
	AS OF <%=WI.formatDate(WI.fillTextValue("graduation_date"),6)%>
	</td>
	</tr>
</table>
<%
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

String strPrevCourse = "";
String strCurrCurse = null;
boolean bolCourseBreak = false;		
int iCourseCount = 0;

Vector vCoursePageNo = new Vector();

for(int i = 0; i < vRetResult.size();){
	
	if(bolCourseBreak){
		vCoursePageNo.addElement(Integer.toString(iPageCount-1));
		iPageCount = 1;
		++iCourseCount;
	}
	bolCourseBreak = false;	
	
	iRowCount = 1;
	if(bolPageBreak){
		bolPageBreak = false;
		%>
		<div style="page-break-after:always;">&nbsp;</div>
	<%}
	
	
%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td colspan="5" height="30"><strong>COURSE: <%=WI.getStrValue((String)vRetResult.elementAt(i+9),"&nbsp;")%></strong></td>	
	</tr>
	<tr>
		<td width="7%" height="22" align="center" class="thinborderTOPLEFTBOTTOM"><strong>SEQ#</strong></td>
		<td width="12%" align="center" class="thinborderTOPBOTTOM"><strong>ID NUMBER</strong></td>
		<td width="28%" align="center" class="thinborderTOPBOTTOM"><strong>NAME</strong></td>
		<td width="29%" align="center" class="thinborderTOPBOTTOM"><strong>ADDRESS</strong></td>
		<td width="24%" align="center" class="thinborderTOPBOTTOMRIGHT"><strong>SPONSORS</strong></td>
	</tr>
	<%for(; i < vRetResult.size();){
	
	strCurrCurse = (String) vRetResult.elementAt(i+9);		   
	if(!strPrevCourse.equals(strCurrCurse) && i > 0){
		strPrevCourse = strCurrCurse;
		iGradCount = 1;
		bolPageBreak = true;	
		bolCourseBreak = true;					
		break;		
	}else
		strPrevCourse = 	strCurrCurse;
	%>
	<tr>
	    
		<td valign="top" height="22" align="center"><%=iGradCount++%>.</td>
		<td valign="top"><%=WI.getStrValue( (String)vRetResult.elementAt(i+1),"N/A")%></td>
		<td valign="top">
		<%=WI.getStrValue(WebInterface.formatName((String)vRetResult.elementAt(i+2),(String) vRetResult.elementAt(i+3),
		(String) vRetResult.elementAt(i+4), 4),"0")%></td>
		<td valign="top"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"")%></td>		
		<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6),"","","");
		if(strTemp.length() > 0)
			strTemp += "<br>";
		
		strTemp += WI.getStrValue((String)vRetResult.elementAt(i+7),"","","") +
			WI.getStrValue((String)vRetResult.elementAt(i+8),"<br>","","");
		%>
      	<td valign="top"><%=strTemp%></td>
	</tr>
	<%	
		i+=iElemCount;
		if(++iRowCount > iNoOfStudPerPage){						
			bolPageBreak = true;
			break;			
		}
		
	}//end of vRetResult loop%>	
	<tr>
		<td align="right" colspan="5" class="thinborderTOP" height="22">&nbsp;</td>
	</tr>
	<tr><td colspan="5" valign="bottom">
		Page <%=iPageCount%> of <label id="course_<%=iPageCount++%>_<%=iCourseCount%>"></label></td></tr>	
</table>
<%}//end of outer loop
vCoursePageNo.addElement(Integer.toString(iPageCount-1));
%>
<script>	
<%
int i=0;
while(vCoursePageNo.size() > 0){
	int iTemp = Integer.parseInt((String)vCoursePageNo.remove(0));
	if(iTemp == 0)
		continue;
	
	for(int x =1; x <= iTemp; ++x){
%>		
	document.getElementById('course_<%=x%>_<%=i%>').innerHTML = <%=iTemp%>;	

<%}++i;}%>		
window.print();

</script>
<%}else{%>
<div style="text-align:center; font-size:13px; color:#FF0000;"><%=WI.getStrValue(strErrMsg)%></div>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
