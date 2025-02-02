<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Exam Result Print</title>
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
<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,java.util.Vector"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vExamName = null;
	Vector vSchedData = null;
	String strErrMsg = null;
	String strTemp = null;	
	String[] astrRetake = {"No","Yes"};
	String[] astrRemarks = {"Failed","Passed"};
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-ENTRANCE EXAM/INTERVIEW",
								"exam_interview_encode_result.jsp");
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
														"Admission Maintenance","ENTRANCE EXAM/INTERVIEW",
														request.getRemoteAddr(),"exam_interview_encode_result.jsp");
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
int iMaxStudPerPage = Integer.parseInt(WI.getStrValue(request.getParameter("appl_per_page"),"25"));
int iNumStud = 1;
int iNumStud2 = 1;
int u = 1;
int v = 1;
boolean bolPageBreak = false;
boolean bolStartNextTable = false;

request.setAttribute("info_index",WI.fillTextValue("sch_code"));
vRetResult = appMgmt.operateOnStudExamResult(dbOP, request, 4);
vSchedData = appMgmt.operateOnExamSched(dbOP,request,5);
Vector vEncoded = (Vector)vRetResult.elementAt(0);	
Vector vUnEncoded = (Vector)vRetResult.elementAt(1);
if(strSchCode.startsWith("CGH"))
	vUnEncoded = new Vector();


for (;(v < vEncoded.size()-1) || (u < vUnEncoded.size()-1);){%>	

<body bgcolor="white">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="table2">
    <tr> 
      <td height="25" colspan="3"><div align="center"> 
          <font size="2">
          <%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
			
		<% if (strSchCode.startsWith("UI")) {%>	

		  UNIVERSITY OF ILOILO<br>
		  Testing Service<br>
          AY 2006 - 2007<br>
          PLACEMENT TEST RESULT
		 <%}%>   
		  </font></div></td>
    </tr>
    <%
	String [] astrConvTime={" AM"," PM"};	
	%>
    <tr> 
      <td height="10" colspan="3"></td>
    </tr>
    <tr>
      <td width="37%" height="25">Date : <strong> <%=((String)vSchedData.elementAt(7))%></strong></td>
      <td width="46%">Venue : <strong> <%=((String)vSchedData.elementAt(12))%></strong></td>
      <td width="17%">Start Time :<strong><%=CommonUtil.formatMinute((String)vSchedData.elementAt(8))+':'+ 
      CommonUtil.formatMinute((String)vSchedData.elementAt(9))+
      astrConvTime[Integer.parseInt((String)vSchedData.elementAt(10))]%></strong></td>
    </tr>
    <tr> 
      <td>Contact Person : <strong><%=((String)vSchedData.elementAt(13))%></strong></td>
      <%vExamName = appMgmt.retreiveName(dbOP, request);
  	    for(int i = 0 ; i< vExamName.size(); i +=6){
			if(((String)vExamName.elementAt(i)).equals(request.getParameter("exam_index"))){%>
      <td height="25"><strong><%=(String)vExamName.elementAt(i+3)%></strong></td>
      <td width="20%">Duration (min) :<strong> <%=((String)vSchedData.elementAt(6))%></strong></td>
      <%  } }
	  %>
    </tr>
<%if(!strSchCode.startsWith("CGH")){//do not show for cgh.. %>    
	<tr> 
      <td>Contact Info : <strong><%=((String)vSchedData.elementAt(14))%> </strong></td>
	  <%
	  		strTemp = dbOP.mapOneToOther("NA_EXAM_SCHED","EXAM_SCHED_INDEX",request.getParameter("sch_code"),"SCHEDULE_CODE","");
	  %>
      <td height="25">Schedule Code : <strong><%=strTemp%></strong></td>
      <td height="25" valign="bottom">&nbsp;</td>
    </tr>
    <tr>	  
      <td>Maximum Score/Rate : <strong><%=((String)vSchedData.elementAt(15))%></strong></td>
      <td  width="512">Passing Score/Rate : <strong> <%=((String)vSchedData.elementAt(16))%></strong></td>      
      <td height="25" valign="bottom">&nbsp;</td>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
		<% if (u < vUnEncoded.size()-1 && vUnEncoded.size() > 1) {%> 
      <td height="23" align="right">&nbsp; </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td height="23" colspan="4" class="thinborderLeft"><div align="center"><strong><font size="1">LIST 
          OF APPLICANTS WITHOUT SCORES </font></strong></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4" class="thinborder"><strong><font size="1">TOTAL 
        APPLICANT(S) : <%=(String)vUnEncoded.elementAt(0)%></font></strong></td>
    </tr>
    <tr> 
      <td width="10%" class="thinborder"><div align="center" ><strong><font size="1">COUNT 
          NO.</font></strong></div></td>
      <td width="21%" height="25" class="thinborder"><div align="center"><strong><font size="1">TEMPORARY 
          /APPLICANT ID</font></strong></div></td>
      <td width="34%" class="thinborder"><div align="center"><strong><font size="1">APPLICANT 
          NAME</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">COURSE</font></strong></div></td>
    </tr>
    <% 	
	for(int iCount = 0; iCount <= iMaxStudPerPage; u += 7,++iNumStud,iCount++){		
		if (iCount >= iMaxStudPerPage || u >= vUnEncoded.size()){
			if(u >= vUnEncoded.size() && vEncoded.size() <= 1)
				bolPageBreak = false;
			else
				bolPageBreak = true;
			break;			
		}		
	%>   
    <tr> 
      <td class="thinborder" height="20"><div align="center"> <%=iNumStud%></div></td>         
      <td class="thinborder"><div align="left">&nbsp;&nbsp;<%=(String)vUnEncoded.elementAt(u+2)%></div></td>
      <td class="thinborder"><div align="left">&nbsp;&nbsp;<%=WI.formatName((String)vUnEncoded.elementAt(u+3),(String)vUnEncoded.elementAt(u+4),(String)vUnEncoded.elementAt(u+5),4)%></div></td>
      <td class="thinborder">&nbsp;&nbsp;<%=(String)vUnEncoded.elementAt(u+6)%></td>
    </tr>
    <%}  
	if (u >= vUnEncoded.size() && vEncoded.size() <= 1){	
	%>
    <tr><td class="thinborder" colspan="4" ><div align="center">
	  ***************** NOTHING FOLLOWS *******************</div></td>
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>    
    <tr> 
      <td class="thinborder" colspan="4" ><div align="center">
	  ************** CONTINUED ON NEXT PAGE ****************</div></td>
    </tr>
    <%}//end else%>   
  </table> 
  <% //INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END. 
    if (bolPageBreak) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
  }//if (u < vUnEncoded.size()-1)
  else{
  	bolStartNextTable = true;	
  }
  %>  
  <br><br>    
  <%    
  if ( u >= vUnEncoded.size() && v < vEncoded.size() && vEncoded.size() > 1 && bolStartNextTable) { %> 
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr> 
    <td height="23" colspan="6" class="thinborderLeft"><div align="center"><strong><font size="1"> 
        LIST OF APPLICANTS WITH SCORES</font></strong></div></td>
  </tr>
  <tr> 
    <td height="25" colspan="6" class="thinborder"><strong><font size="1"> TOTAL 
      APPLICANT(S) : <%=(String)vEncoded.elementAt(0)%></font></strong></td>
  </tr>
  <tr> 
    <td width="13%" class="thinborder"><div align="center" ><strong><font size="1"> 
        COUNT NO.</font></strong></div></td>
    <td width="25%" height="25" class="thinborder"><div align="center"><strong> 
        <font size="1">TEMPORARY /APPLICANT ID</font></strong></div></td>
    <td width="37%" class="thinborder"><div align="center"><strong><font size="1"> 
        APPLICANT NAME</font></strong></div></td>
    <td width="10%" class="thinborder"><div align="center"><strong><font size="1">COURSE</font></strong></div></td>
    <% if (!strSchCode.startsWith("CGH")) {%> 
    <td width="10%" class="thinborder"><div align="center"><strong><font size="1"> 
        SCORE</font></strong></div></td>
<%}%> 
    <td width="15%" class="thinborder"><div align="center"> 
        <div align="center"><strong><font size="1">REMARKS</font></strong></div>
      </div></td>
    <b> </b> </tr>
  <%
	int iRemarks = 0;	
	for(int iCount = 0; iCount <= iMaxStudPerPage; v += 12,++iNumStud2,iCount++){
		if (iCount >= iMaxStudPerPage || v >= vEncoded.size()){
			if(v >= vEncoded.size())
				bolPageBreak = false;	
			else
				bolPageBreak = true;
			break;
		}				
		
//		if (Integer.parseInt((String)vEncoded.elementAt(v+2)) >= Integer.parseInt(WI.getStrValue(request.getParameter("pScore"),"0")))
		if (Integer.parseInt((String)vEncoded.elementAt(v+2)) >= Integer.parseInt((String)vSchedData.elementAt(16)))			
			iRemarks = 1;
      	else
			iRemarks = 0;
	%>
  <tr> 
    <td height="25" class="thinborder"><div align="center"><%=iNumStud2%></div></td>
    <td class="thinborder">&nbsp;<%=((String)vEncoded.elementAt(v+5))%></td>
    <td class="thinborder">&nbsp;<%=WI.formatName((String)vEncoded.elementAt(v+6),(String)vEncoded.elementAt(v+7),(String)vEncoded.elementAt(v+8),4)%></td>
    <td class="thinborder">&nbsp;<%=((String)vEncoded.elementAt(v+11))%></td>
    <% if (!strSchCode.startsWith("CGH")) {%> 
    <td align="center" class="thinborder"><%=((String)vEncoded.elementAt(v+2))%></td>
<%}%> 
    <td align="center" class="thinborder"> <%=astrRemarks[iRemarks]%></td>
  </tr>
  <%}//for(int iCount = 0; iCount < iMaxStudPerPage; v += 10,++iNumStud2,iCount++)     
	if (v >= vEncoded.size()){%>
  <tr> 
    <td class="thinborder" colspan="6" ><div align="center"> ***************** 
        NOTHING FOLLOWS *******************</div></td>
  </tr>
  <%}else{// end iNumStud >= vRetResult.size()%>
  <tr> 
    <td class="thinborder" colspan="6" ><div align="center"> ************** CONTINUED 
        ON NEXT PAGE ****************</div></td>
  </tr>
  <%}//end else%>
</table>
  <% //INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END. 
if (bolPageBreak) {%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break only if it is not last page.
}//if (u >= vUnEncoded.size()-1 && v < vEncoded.size()-1 )
  }//for (;(v < vEncoded.size()-1) || (u < vUnEncoded.size()-1);)
%>  
<script language="JavaScript">
	window.print();
</script>  
</body>
</html>
<% 
dbOP.cleanUP();
%>