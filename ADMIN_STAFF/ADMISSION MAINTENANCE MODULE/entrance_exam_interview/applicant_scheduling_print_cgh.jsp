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
	
    TD.thinborderBottom {
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
<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt, java.util.Vector"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vSchedData = null;
	String strErrMsg = null;
	int iStartHH = 0;
	int iStartAMPM = 0;
	
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
	
	String strTemp = null;
	
	for (;u < vRetResult.size()-1;){
%>

<body bgcolor="#FFFFFF">  
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="25" colspan="3"><div align="center"> 
        <p><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></p>
</div></td>
  </tr>
  <tr>
    <td height="10" colspan="3">&nbsp;</td>
  </tr>
   <% 
   String strEntranceExamInterviewName = "ENTRANCE EXAMINATION";
   
	request.setAttribute("info_index",WI.fillTextValue("sch_code"));
	if(WI.fillTextValue("main_examtype_reloaded").length() == 0) 
		vSchedData = appMgmt.operateOnExamSched(dbOP,request,5);
	String [] astrConvTime={" AM"," PM"};

	if(vSchedData != null && vSchedData.size() > 0){
		iStartHH = Integer.parseInt((String)vSchedData.elementAt(8));
		iStartAMPM = Integer.parseInt((String)vSchedData.elementAt(10));				
		
		// hard coded .. 3 hrs.
		
		iStartHH += 3;
		
		if (iStartHH >= 12) {
			if (iStartHH > 12) 
				iStartHH -= 12;
			iStartAMPM = 1;
		}
		if(((String)vSchedData.elementAt(vSchedData.size() - 1)).endsWith("Interview"))
			strEntranceExamInterviewName = "INTERVIEW";
	
	%>
  <%}//if(vSchedData != null && vSchedData.size() > 0)%>
</table>
  <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFFF" class="thinborder"> 
      <td height="13" colspan="7" align="center" class="thinborderLeft"><strong>LIST OF STUDENTS FOR <%=strEntranceExamInterviewName%><!--ENTRANCE EXAMINATIONS--></strong> </td>
    </tr>
    <tr>
      <td height="23" colspan="7" align="center" class="thinborder"><strong>&nbsp;
  		  <%=WI.formatDate((String)vSchedData.elementAt(7),6)%>
		   (<%=CommonUtil.formatMinute((String)vSchedData.elementAt(8))+':'+ CommonUtil.formatMinute((String)vSchedData.elementAt(9))+astrConvTime[Integer.parseInt((String)vSchedData.elementAt(10))]%>
	- 
    <%=CommonUtil.formatMinute(Integer.toString(iStartHH))+':'+ CommonUtil.formatMinute((String)vSchedData.elementAt(9))+astrConvTime[iStartAMPM]%>)	  </strong></td>
    </tr>
    <tr> 
      
    <td height="23" colspan="7" class="thinborder"><strong><font size="1">&nbsp;TOTAL 
      APPLICANT(S) : <%=vRetResult.size()/12%> </font></strong></td>
    </tr>
    <tr class="thinborder"> 
      <td width="5%" align="center" class="thinborder"><strong><font size="1"> NO.</font></strong></td>
      <td width="15%" align="center" class="thinborder"><strong><font size="1">APPLICANT ID</font></strong> </td>
      <!--
      <td width="13%" height="25" class="thinborder"><div align="center"><strong><font size="1">TEMPORARY/<br>
        APPLICANT ID</font></strong></div></td>
-->
      <td width="25%" align="center" class="thinborder"><strong><font size="1">LAST NAME</font></strong> </td>
      <td width="25%" align="center" class="thinborder"><strong><font size="1">FIRST NAME</font></strong> </td>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">M.I</font></strong></td>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">APPLICANT COURSE</font></strong> </td>
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

	  strTemp = WI.getStrValue((String)vRetResult.elementAt(u+9),"");
	  strTemp += WI.getStrValue((String)vRetResult.elementAt(u+10),"/","","");

	%>    
    <tr> 
      <td height="25" class="thinborder">&nbsp;&nbsp; 
          <%=iNumStud%>.</td>
      <td class="thinborder" > &nbsp; <%=((String)vRetResult.elementAt(u+2))%></td>
      <td class="thinborder" > &nbsp;<%=(String)vRetResult.elementAt(u+7)%></td>
      <td class="thinborder" >&nbsp;<%=(String)vRetResult.elementAt(u+5)%></td>
      <td align="center" class="thinborder" >&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(u+6)," ").charAt(0) + "." %></td>
      <td class="thinborder" ><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
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