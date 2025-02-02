<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TABLE.thinborderall {
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderGrade {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
-->
</style>
</head>
<body>
<%@ page language="java" import="utility.*,java.util.Vector,enrollment.ApplicationMgmt " %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	Vector vExamIndex = new Vector();	
	Vector vMasterList = null;
	Vector vExamList = null;
	String strErrMsg  = null;
	String strTemp    = null;
	String astrSemester[] = {" Summer "," First Semester "," Second Semester "," Third Semester "};	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	
	boolean bolIsAUF = strSchCode.startsWith("AUF");//there are few changes in the form for AUF.. 
	
	int iSearch = 0;	
	int iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));
	int u = 0;
	
	if (strSchCode.startsWith("UI"))
		u = 3;
	
	
	int iNumStud = 1;
	boolean bolPageBreak = false;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-ENTRANCE EXAM/INTERVIEW","exam_sched.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission Maintenance","ENTRANCE EXAM/INTERVIEW",request.getRemoteAddr(),
														"exam_sched.jsp");
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
}//end of authenticaion code.
	
	ApplicationMgmt appMgmt = new ApplicationMgmt();
	
	vExamList = appMgmt.operateOnMasterList(dbOP,request,1);
	if(vExamList == null)
		strErrMsg = appMgmt.getErrMsg();
	
	vMasterList = appMgmt.operateOnMasterList(dbOP,request,2);
	if(vMasterList == null)
		strErrMsg = appMgmt.getErrMsg();
		
	if(vMasterList != null){
	for (;u < vMasterList.size();){%>		
		
  
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="25" colspan="5"><div align="center"> 
        <p><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></p>
</div></td>
  </tr>
  </tr>
  <tr> 
    <td height="20" valign="bottom">&nbsp;&nbsp; School Year / Term: <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%> / <%=astrSemester[Integer.parseInt(WI.fillTextValue("semester"))]%></td>
  </tr>
  <tr> 
    
  <td height="20" valign="bottom">&nbsp;&nbsp; Master List For: 
    <%if(vExamList != null){
	  		for(int iLoop = 0;iLoop < vExamList.size();iLoop += 2){
				if(WI.fillTextValue("subject_"+(iLoop+2)/2).length() > 0){%>
					<%=" [ "+(String)vExamList.elementAt(iLoop+1)+" ] "%>					
		  <%}}}%>	</td>
  </tr>
</table>
	<table width="100%"  border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
        <tr bgcolor="#FFFFFF"> 
          <td height="23"><div align="center"><strong><font size="1">LIST OF APPLICANTS</font></strong></div></td>
        </tr>
	</table>
	<table width="100%"  class="thinborder" border="0" cellpadding="1" cellspacing="1" bgcolor="#FFFFFF">
        <tr align="center" style="font-weight:bold"> 
          <td width="5%" rowspan="2" class="thinborder"><font size="1">Count</font></td>
          <td width="10%" rowspan="2" class="thinborder"><font size="1">ID Number </font></td>
          <td width="15%" rowspan="2" class="thinborder"><font size="1">Student Name </font></td>
          <td width="5%" rowspan="2" class="thinborder"><font size="1">Gender</font></td>
		  <td width="15%" rowspan="2" class="thinborder"><font size="1">School Name </font></td>
          <td width="20%" rowspan="2" class="thinborder"><font size="1">School Address</font></td>
           <%if(WI.fillTextValue("show_college").length() > 0){%><td width="7%" rowspan="2" class="thinborder"><font size="1">College</font></td><%}%>
          <td width="7%" rowspan="2" class="thinborder"><font size="1">Course</font></td>
          <td width="8%" rowspan="2" class="thinborder"><font size="1">Date Taken </font></td>
          <%if(bolIsAUF)
				vExamList = null;
			  if(vExamList != null){
			  for(int iLoop = 0;iLoop < vExamList.size();iLoop += 2){
				if(WI.fillTextValue("subject_"+(iLoop+2)/2).length() > 0){
				    vExamIndex.addElement((String)vExamList.elementAt(iLoop));%>
          <td height="25" colspan="2" class="thinborder"><div align="center"> 
              <strong><font size="1"><%=(String)vExamList.elementAt(iLoop+1)%></font></strong></div></td>
          <%}}}%>
        </tr>
        <tr> 
          <%
			  if(vExamList != null){
			  for(int iLoop = 0;iLoop < vExamList.size();iLoop += 2){
				if(WI.fillTextValue("subject_"+(iLoop+2)/2).length() > 0){%>
          <td height="25" class="thinborder"><div align="center"><strong><font size="1">Score</font></strong></div></td>
          <td class="thinborder"><div align="center"><strong><font size="1">Classi-<br>fication</font></strong></div></td>
          <%}}}%>
        </tr>
		
		<%for(int iCount2 = 0; iCount2 <= iMaxStudPerPage; u += 15,++iNumStud,iCount2++){
		if (iCount2 >= iMaxStudPerPage || u >= vMasterList.size()){
			if(u >= vMasterList.size())
				bolPageBreak = false;	
			else
				bolPageBreak = true;
			break;
		}
		%>		
        <tr> 
          <td class="thinborder"  height="25"><%=iNumStud%></td>
          <td class="thinborder"><%=(String)vMasterList.elementAt(u)%></td>
          <td class="thinborder"><%=WI.formatName((String)vMasterList.elementAt(u+1),(String)vMasterList.elementAt(u+2),(String)vMasterList.elementAt(u+3),4)%></td>
          <td class="thinborder"><%=(String)vMasterList.elementAt(u+4)%></td>
		  <td class="thinborder"><%=WI.getStrValue((String)vMasterList.elementAt(u+11),"&nbsp;")%></td>
          <td class="thinborder"><%=WI.getStrValue((String)vMasterList.elementAt(u+8),"&nbsp;")%></td>
          <%if(WI.fillTextValue("show_college").length() > 0){%><td class="thinborder"><%=WI.getStrValue((String)vMasterList.elementAt(u+14),"&nbsp;")%></td><%}%>
          <td class="thinborder"><%=WI.getStrValue((String)vMasterList.elementAt(u+10),"&nbsp;")%></td>
          <td class="thinborder"><%=(String)vMasterList.elementAt(u+5)%> 
              <%
				for(int v = u; (v + 15) < vMasterList.size() ;){
				 if(((String)vMasterList.elementAt(v)).compareTo((String)vMasterList.elementAt(v + 15)) != 0)
						break;%>
              <br>
              <%=(String)vMasterList.elementAt(v + 15 + 5)%> 
              <%v += 15;}%>            
			</td>
          <%
			  if(vExamList != null){
			  int iCount = 0;
			  for(int iLoop = 0;iLoop < vExamList.size();iLoop += 2){
				if(WI.fillTextValue("subject_"+(iLoop+2)/2).length() > 0){
				    iCount++;					
			   if(u < vMasterList.size()){
			  		if(((String)vExamIndex.elementAt(iCount-1)).equals((String)vMasterList.elementAt(u+6))){%>
          <td width="193" class="thinborder"><%=WI.getStrValue((String)vMasterList.elementAt(u+9),"&nbsp;")%></td>
          <td width="166" class="thinborder"><%=WI.getStrValue((String)vMasterList.elementAt(u+7),"&nbsp;")%></td>
          <%if(u+15 < vMasterList.size()){
			   		if(((String)vMasterList.elementAt(u)).compareTo((String)vMasterList.elementAt(u + 15)) == 0)
			   			u+=15;
			     } 
			   }else{%>
          <td width="193" class="thinborder"><div align="center">&nbsp;</div></td>
          <td width="166" class="thinborder"><div align="center">&nbsp;</div></td
			   >
          <%}}}}}%>
        </tr>
        <%} 	        
	if (u >= vMasterList.size()-1){%>
  <tr> 
    <td width="100%"  colspan="<%=WI.fillTextValue("colSpan")%>" class="thinborder" ><div align="center"> ***************** NOTHING FOLLOWS *******************</div></td>
  </tr>
  <%}else{// end iNumStud >= vRetResult.size()%>
  <tr> 
    <td class="thinborder" colspan="<%=WI.fillTextValue("colSpan")%>"><div align="center"> ************** CONTINUED ON NEXT PAGE ****************</div></td>
  </tr>
  <%}//end else%>
</table>
<% //INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END. 
if (bolPageBreak) {%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break only if it is not last page.
 } // end for loop %>
 
<% }//end first else  vMasterList != null%>
<script language="JavaScript">
	window.print();
</script>
</body>
</html>
<% dbOP.cleanUP(); %>