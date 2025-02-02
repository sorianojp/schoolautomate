<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<%@ page language="java" import="utility.*,java.util.Vector,enrollment.ReportEnrollment,ClassMgmt.CMAttendance " %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;

	Vector vSecDetail = null;


try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"STUDENT AFFAIRS-STUDENT TRACKER","attendance_summary_report.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"STUDENT AFFAIRS","STUDENT TRACKER",request.getRemoteAddr(), 
														"attendance_summary_report.jsp");

if(iAccessLevel == 0)														
iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Faculty/Acad. Admin","CLASS MANAGEMENT",request.getRemoteAddr(), 
														"cm_attendance_view_summary.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../faculty_acad/faculty_acad_bottom_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	String strEmployeeID    = (String)request.getSession(false).getAttribute("userId");
	String strEmployeeIndex = (String)request.getSession(false).getAttribute("userIndex");
	String strSubSecIndex   = null;
	enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
	enrollment.AttendanceMonitoringCDD attendance= new enrollment.AttendanceMonitoringCDD();
	Vector vRetResult = null;
	
	

if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
	strSubSecIndex = dbOP.mapOneToOther("E_SUB_SECTION join faculty_load on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
		"section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index", 
		" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+
		" and faculty_load.is_valid = 1 and e_sub_section.is_valid =1 and e_sub_section.offering_sy_from = "+
		WI.fillTextValue("sy_from")+" and e_sub_section.offering_sy_to = "+WI.fillTextValue("sy_to")+
		" and e_sub_section.offering_sem="+
		WI.fillTextValue("offering_sem")+" and is_lec=0 and e_sub_section.is_valid = 1");
						
}

int iElemCount = 0;
if(strSubSecIndex != null) {//get here subject section detail. 
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
		
	vRetResult = attendance.generateAttendanceSummary(dbOP, request, strSubSecIndex);
	if(vRetResult == null)
		strErrMsg = attendance.getErrMsg();
	else
		iElemCount = attendance.getElemCount();
}
	


%>
<body>




<%
if(vRetResult != null && vRetResult.size() > 0){
Vector vHeaderList = (Vector)vRetResult.remove(0);
Vector vStudList = (Vector)vRetResult.remove(0);
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%"><div align="center"><strong style="font-size:14px;"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></div></td>
    </tr>

   </table>
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr > 
    <td height="10" colspan="2" ><div align="center"> 
        <hr size="1">
      </div></td>
  </tr>
  <tr > 
    <td width="42%" height="10" >Subject code : <%=request.getParameter("subject_code")%></td>
    <td width="58%">Descriptive Title : <%=request.getParameter("subject_name")%></td>
  </tr>
  <tr > 
    <td colspan="2" height="10" ><hr size="1"></td>
  </tr>
  <tr > 
    <td height="25" >Section : <%=request.getParameter("section_name")%></td>
    <td height="25" >Instructor : 
      <%if(vSecDetail != null){%>
      <%=WI.getStrValue(vSecDetail.elementAt(0))%> 
      <%}%>
    </td>
  </tr>
  <tr > 
    <td height="25" colspan="2" align="center">
<%if(vSecDetail != null){%>
		<table width="75%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
			<tr>
          	  <td height="20" align="center" class="thinborder"><font size="1"><strong>ROOM NUMBER</strong></font></td>
			  <td align="center" class="thinborder"><font size="1"><strong>LOCATION</strong></font></td>
			  <td align="center" class="thinborder"><font size="1"><strong>SCHEDULE</strong></font></td>
			</tr>
    <%for(int i = 1; i<vSecDetail.size(); i+=3){%> 
			<tr>			  
			  <td height="20" align="center" class="thinborder"><%=(String)vSecDetail.elementAt(i)%></td>				  
			  <td align="center" class="thinborder"><%=(String)vSecDetail.elementAt(i+1)%></td>				  
          	  <td align="center" class="thinborder"><%=(String)vSecDetail.elementAt(i+2)%></td>
			</tr>
	<%}%>
		  </table>
<%}%>
	</td>
  </tr>
  
  
</table>

<table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td align="center" height="25"><strong>SUMMARY OF STUDENT ABSENCES</strong></td></tr>
</table>
<table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td width="3%" height="25" class="thinborder" align="center"><strong style="font-size:10px;">COUNT</strong></td>
	    <td width="13%" class="thinborder" align="center"><strong style="font-size:10px;">ID NUMBER</strong></td>
	    <td class="thinborder" align="center"><strong style="font-size:10px;">STUDENT NAME</strong></td>
	    <td width="20%" class="thinborder" align="center"><strong style="font-size:10px;">COURSE & YEAR</strong></td>
	    <%		
		if(vHeaderList != null && vHeaderList.size() > 0){
		for(int i = 0 ; i < vHeaderList.size(); ++i){
		%>
		<td width="10%" class="thinborder" align="center"><strong style="font-size:10px;"><%=WI.getStrValue(vHeaderList.elementAt(i))%></strong></td>		
		<%}}%>
		<td width="5%" class="thinborder" align="center"><strong style="font-size:10px;">TOTAL HOUR(S)</strong></td>
	</tr>
	
	<%
	Vector vAbsentList = null;
	int iIndexOf = 0;
	Vector vTemp = null;
	String strUserIndex = null;
	int iCount = 0;
	int iTemp  = 0;
	for(int i = 0 ; i < vStudList.size(); i+=iElemCount){
	strUserIndex = (String)vStudList.elementAt(i);
	vAbsentList = (Vector)vStudList.elementAt(i+8);
	%>
	<tr>
	    <td height="25" class="thinborder" align="right"><%=++iCount%>.&nbsp;</td>
	    <td class="thinborder">&nbsp;<%=vStudList.elementAt(i+1)%></td>
		<%
		strTemp = WebInterface.formatName((String)vStudList.elementAt(i+2),(String)vStudList.elementAt(i+3),(String)vStudList.elementAt(i+4),4);
		%>
	    <td class="thinborder">&nbsp;<%=strTemp%></td>
		<%
		strTemp = (String)vStudList.elementAt(i+5)+WI.getStrValue((String)vStudList.elementAt(i+6)," / ","","")
			+WI.getStrValue((String)vStudList.elementAt(i+7)," - ","","");
		%>
	    <td class="thinborder">&nbsp;<%=strTemp%></td>
		 <%
		 if(vHeaderList != null && vHeaderList.size() > 0){
		for(int j = 0 ; j < vHeaderList.size(); ++j){
			iIndexOf = vAbsentList.indexOf(strUserIndex+"_"+vHeaderList.elementAt(j));
			
			
		%>
	    <td class="thinborder" valign="top">
		<%
		if(iIndexOf > -1){
		%>
			<table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
			<%
			strTemp = (String)vAbsentList.elementAt(iIndexOf + 1);
			vTemp = CommonUtil.convertCSVToVector(strTemp);
			while(vTemp.size() > 0){
			iTemp = 0;	
			%>
				<tr>
					<%while(vTemp.size() > 0){
					if(++iTemp > 1)
						break;
					%>
					<td><%=vTemp.remove(0)%></td>
					<%}%>
				</tr>
			<%}%>
			</table>
		<%}else{%>&nbsp;<%}%>		
		</td>
		<%}}%>
		<td class="thinborder" align="center"><%=(String)vStudList.elementAt(i+9)%></td>
	    </tr>
	<%}%>
</table>
<script>window.print();</script>
<%}%>
</body>
</html>
<%
	dbOP.cleanUP();
%>
