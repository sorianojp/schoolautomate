<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
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
	
    TD.thinborderLeft {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,enrollment.Advising,java.util.Vector"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Advising adv = new Advising();
	Vector vStudInfo = null;
	Vector vRetResult = null;
	Vector vEditInfo  = null;
	Vector vExamName = null;
	Vector vSchedData = null;
	String strErrMsg = null;
	String strErrMsg2 = null;
	String strTemp = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-ENTRANCE EXAM/INTERVIEW","applicant_scheduling.jsp");
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
														"Admission Maintenance","ENTRANCE EXAM/INTERVIEW",request.getRemoteAddr(),
														"applicant_scheduling.jsp");
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
	ApplicationMgmt appMgmt = new ApplicationMgmt();
	//view all 
	vRetResult = appMgmt.operateOnStudExamSched(dbOP, request, 4);
	int iMaxStudPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_perpg"),"20"));
	int iNumStud = 1;
	int u = 0;
	boolean bolPageBreak = false;
	for (;u < vRetResult.size()-1;){
%>

<body bgcolor="#FFFFFF">  
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="25" colspan="3"><div align="center"> 
        <p><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></p>
<% if (strSchCode.startsWith("UI")) {%>
        <font size="2">
		UNIVERSITY OF ILOILO<br>
		Testing Service<br>
        AY 2006 - 2007<br>
		Applicant Schedule<br>
        </font> 
<%} // show for UI only%>		
		
		</div></td>
  </tr>
  <tr>
    <td height="10" colspan="3">&nbsp;</td>
  </tr>
  <tr> 
    <% 
	request.setAttribute("info_index",WI.fillTextValue("sch_code"));
	if(WI.fillTextValue("main_examtype_reloaded").length() == 0) 
		vSchedData = appMgmt.operateOnExamSched(dbOP,request,5);
	String [] astrConvTime={" AM"," PM"};

	if(vSchedData != null && vSchedData.size() > 0){%>
    <td width="37%" height="25">Date : <strong><%=((String)vSchedData.elementAt(7))%></strong></td>
    <td width="46%" height="25">Venue : <strong><%=((String)vSchedData.elementAt(12))%></strong></td>
    <td width="17%">Start Time :<strong><%=CommonUtil.formatMinute((String)vSchedData.elementAt(8))+':'+ CommonUtil.formatMinute((String)vSchedData.elementAt(9))+astrConvTime[Integer.parseInt((String)vSchedData.elementAt(10))]%></strong></td>
  </tr>
  <tr> 
    <td>Contact Person: <strong><%=((String)vSchedData.elementAt(13))%></strong></td>
    <%vExamName = appMgmt.retreiveName(dbOP, request);
  	    for(int i = 0 ; i< vExamName.size(); i +=6){
			if(((String)vExamName.elementAt(i)).equals(request.getParameter("exam_index"))){%>
    <td height="25">Scheduling Type/Sub-type: <strong><%=(String)vExamName.elementAt(i+3)%></strong></td>
    <td width="17%">Duration(min) :<strong><%=((String)vSchedData.elementAt(6))%></strong></td>
    <%  } }
	  %>
  </tr>
  <tr> 
    <td>Contact Info: <strong><%=((String)vSchedData.elementAt(14))%></strong></td>
    <%
	  		strTemp = dbOP.mapOneToOther("NA_EXAM_SCHED","EXAM_SCHED_INDEX",request.getParameter("sch_code"),"SCHEDULE_CODE","");
	  %>
    <td height="25">Schedule Code: <strong><%=strTemp%></strong></td>
    <td width="17%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="10" colspan="3">&nbsp;</td>
  </tr>
  <%}//if(vSchedData != null && vSchedData.size() > 0)%>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <%
strTemp =null;
if((vSchedData != null && vSchedData.size() > 0) ||
	 WI.fillTextValue("temp_id").length()>0){%>
    <%}//show if temp id is entered%>
    <%if (strTemp != null && strTemp.length() > 0)
		vStudInfo = adv.getTempStudInfo(dbOP,strTemp,WI.fillTextValue("sy_from"),
	  									WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if (vStudInfo != null && vSchedData != null && vSchedData.size() > 0) {%>
    <%	  
	  strTemp = WI.getStrValue((String)vStudInfo.elementAt(7),"/","");
	  strTemp += WI.getStrValue((String)vStudInfo.elementAt(5),"");	  
	  %>
    <%}
	else{ strErrMsg2 = adv.getErrMsg();}%>
    <tr> 
      <td width="325%" height="10" colspan="4"><strong><%=WI.getStrValue(strErrMsg2)%></strong></td>
    </tr>
  </table>  
  <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFFF" class="thinborder"> 
      <td height="23" colspan="6" class="thinborderLeft"><div align="center"><strong><font size="1">LIST 
          OF APPLICANTS </font></strong></div></td>
    </tr>
    <tr> 
      
    <td height="23" colspan="6" class="thinborder"><strong><font size="1">&nbsp;TOTAL 
      APPLICANT(S) : <%=vRetResult.size()/12%> </font></strong></td>
    </tr>
    <tr class="thinborder"> 
      <td width="7%" class="thinborder"><div align="center"><strong><font size="1">COUNT NO.</font></strong></div></td>
      <td width="16%" height="25" class="thinborder"><div align="center"><strong><font size="1">TEMPORARY/<br>
        APPLICANT ID</font></strong></div></td>
      <td width="25%" class="thinborder"><div align="center"><strong><font size="1">APPLICANT NAME</font></strong></div></td>
      <td width="11%" class="thinborder"><div align="center"><strong><font size="1">DATE APPLIED</font></strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong><font size="1">COURSE/MAJOR APPLIED</font></strong></div></td>
      <td width="21%" class="thinborder"><div align="center"><b><font size="1">CONTACT INFORMATION</font></b></div></td>
    </tr>
    <%
	for(int iCount = 0; iCount <= iMaxStudPerPage; u += 13,++iNumStud,iCount++){
		if (iCount >= iMaxStudPerPage || u > vRetResult.size()-1){
			if(u > vRetResult.size()-1)
				bolPageBreak = false;
			else
				bolPageBreak = true;
			break;
		}		
	%>    
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <%=iNumStud%>
		  </div></td>
      <td class="thinborder" ><div align="left"> &nbsp; <%=((String)vRetResult.elementAt(u+2))%></div></td>
      <td class="thinborder" > &nbsp;<%=WI.formatName((String)vRetResult.elementAt(u+5),(String)vRetResult.elementAt(u+6),(String)vRetResult.elementAt(u+7),4)%></td>
      <td class="thinborder" ><div align="center"><%=((String)vRetResult.elementAt(u+8))%></div></td>
      
    <td class="thinborder" > &nbsp; 
      <%	  
	  strTemp = WI.getStrValue((String)vRetResult.elementAt(u+9),"");	  
	  strTemp += WI.getStrValue((String)vRetResult.elementAt(u+10),"/","","");

	  %> <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vRetResult.elementAt(u+11),"&nbsp;")%></div></td>
    </tr>
    <%	
	}
	if (u >= vRetResult.size()-1){%>
    <tr> 
      <td class="thinborder" colspan="6" ><div align="center">
	  ***************** NOTHING FOLLOWS *******************</div></td>
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>    
    <tr> 
      <td class="thinborder" colspan="6" ><div align="center">
	  ************** CONTINUED ON NEXT PAGE ****************</div></td>
    </tr>
    <%}//end else%>	
  </table>
  <%if (bolPageBreak) {%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
    <%}//page break only if it is not last page.
  }%>
  <script language="JavaScript">
	window.print();
</script>
</body>
</html>
<% dbOP.cleanUP();
%>