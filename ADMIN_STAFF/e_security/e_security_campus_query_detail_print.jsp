<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style>
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }



</style>
</head>
<body>
<%@ page language="java" import="utility.*,eSC.CampusQuery,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	String strImgFileExt = null;
	
	Vector vStudInfo = null;
		
	String strReportToDisp = WI.fillTextValue("report_to_disp");
	String[] astrConvertToTerm ={"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eSecurity Check-Campus Query","e_security_campus_query_detail.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eSecurity Check","STUDENTS CAMPUS ATTENDANCE QUERY",request.getRemoteAddr(), 
														"e_security_campus_query_detail.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
int iSearchResult = 0;

boolean bolIsEmployee = false;
boolean bolSearchOther = WI.fillTextValue("search_other").equals("1");

CampusQuery CQ   = new CampusQuery(request);
if(bolSearchOther)
	vRetResult = CQ.searchCampusAttendance(dbOP, 4);
else
	vRetResult = CQ.getTimeInTimeOutDetail(dbOP,request,WI.fillTextValue("report_type"),WI.fillTextValue("stud_id"));

if(vRetResult == null)
	strErrMsg = CQ.getErrMsg();
else	
	iSearchResult = CQ.getSearchCount();

enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"),null,null,null);
if(vStudInfo == null) {
	//may be called for employees. 
	request.setAttribute("emp_id",request.getParameter("stud_id"));
	vStudInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
	bolIsEmployee = true;
}
if(vStudInfo == null) 
	strErrMsg = offlineAdm.getErrMsg();	

if (strErrMsg != null) {
%>	

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="20" colspan="5">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
<%} if(vStudInfo != null && vStudInfo.size() > 0){%>	  
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="88%" height="20" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CAMPUS ATTENDANCE DETAIL  ::::</strong></font></div></td>
    </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td width="21%"><%if(bolIsEmployee){%>Employee<%}else{%>Student<%}%> ID No.</td>
    <td width="43%"><strong><%=WI.fillTextValue("stud_id").toUpperCase()%></strong></td>
    <td width="34%" rowspan="5" valign="top"><img src="../../upload_img/<%=WI.fillTextValue("stud_id").toUpperCase()%>.<%=strImgFileExt%>" width="135" height="150"></td>
  </tr>
  <tr> 
    <td width="2%" height="20">&nbsp;</td>
    <td><%if(bolIsEmployee){%>Employee<%}else{%>Student<%}%> name </td>
    <td><strong>
	  	<%if(bolIsEmployee){%>
			<%=WebInterface.formatName((String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),4)%>
		<%}else{%>
			<%=WebInterface.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),4)%>
		<%}%>
	</strong></td>
  </tr>
  <tr> 
    <td height="26">&nbsp;</td>
    <td height="26"><%if(bolIsEmployee){%>College/Dept<%}else{%>Course/Major<%}%></td>
    <td height="26"><strong>
<%if(bolIsEmployee){%>
	<%=WI.getStrValue(vStudInfo.elementAt(13))%>/<%=WI.getStrValue(vStudInfo.elementAt(14))%>
<%}else{%>
	  <%=(String)vStudInfo.elementAt(7)%><%if(vStudInfo.elementAt(8) != null){%>/<%=(String)vStudInfo.elementAt(8)%> <%}%>
<%}%>
	</strong></td>
  </tr>
  <tr> 
    <td height="26">&nbsp;</td>
    <td height="26"><%if(bolIsEmployee){%>Emp. Status<%}else{%>Year level<%}%></td>
    <td height="26"><strong>
<%if(bolIsEmployee){%><%=(String)vStudInfo.elementAt(16)%><%}else{%><%=WI.getStrValue(vStudInfo.elementAt(14),"N/A")%><%}%>
	</strong></td>
  </tr>
  <tr> 
    <td height="26">&nbsp;</td>
    <td height="26" valign="top"><%if(bolIsEmployee){%>Designation<%}else{%>Current School Year &amp; Term<%}%></td>
    <td height="26" valign="top"><strong>
<%if(bolIsEmployee){%>
	<%=(String)vStudInfo.elementAt(15)%>
<%}else{%>
	  <%=(String)vStudInfo.elementAt(10)%> 
        - <%=(String)vStudInfo.elementAt(11)%> (<%=astrConvertToTerm[Integer.parseInt((String)vStudInfo.elementAt(9))]%>)</strong>
<%}%>
	</strong></td>
  </tr>
</table>
  <%}//stud info is notnull. 
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="20" colspan="4" bgcolor="#B9B292"><div align="center"><strong><%=strReportToDisp%></strong></div></td>
    </tr>
</table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="12%" height="25" align="center" class="thinborder"><strong>DATE</strong></td>
      <td width="19%" align="center" class="thinborder"><strong>TIME-IN</strong></td>
      <td width="19%" align="center" class="thinborder"><strong>LOCATION (IN) </strong></td>
      <td width="23%" align="center" class="thinborder"><strong>TIME-OUT</strong></td>
      <td width="27%" align="center" class="thinborder"><strong>LOCATION (OUT) </strong></td>
    </tr>
    <%for(int i = 0; i< vRetResult.size(); i +=5){%>
    <tr> 
      <td height="25" align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td align="center" class="thinborder">&nbsp;<%=WI.formatDateTime( ((Long)vRetResult.elementAt(i)).longValue(),3)%></td>
      <td height="25" align="center" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3))%></td>
      <td align="center" class="thinborder">
	  				<%=WI.getStrValue(WI.formatDateTime(((Long)vRetResult.elementAt(i+1)).longValue(),3),"&nbsp;")%></td>
      <td align="center" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4))%></td>
    </tr>
    <%}%>
</table>
<script language="javascript">
	window.print();
</script>
<%}//only if vRetResult is not null %>

</body>
</html>
<%
dbOP.cleanUP();
%>