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
<%@ page language="java" import="utility.*,java.util.Vector,health.CTPreEnrollment"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;		
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinical Test",
								"search_ct_print.jsp");
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
														"Health Monitoring","Clinical Test",
														request.getRemoteAddr(),"search_ct_print.jsp");
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

    CTPreEnrollment CTPE = new CTPreEnrollment();
	
	int iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));
	int iNumStud = 1;
	int iNumStud2 = 1;
	int u = 0;
	int v = 0;
	boolean bolPageBreak = false;
	boolean bolStartNextTable = false;
	String strTempAddlVenue = "";
    String strTempAddlTestDate = "";
	
	Vector vRetResult = new Vector();
	Vector vTempStud = new Vector();
	Vector vPermStud = new Vector();
	vRetResult = null;
 	
	vRetResult = CTPE.operateOnSearchList(dbOP,request,Integer.parseInt(WI.fillTextValue("stud_type")));
	if(vRetResult == null)
		strErrMsg = CTPE.getErrMsg();
	else{
		vPermStud = (Vector)vRetResult.elementAt(0);
		vTempStud = (Vector)vRetResult.elementAt(1);					
	}
	for (;(v < vPermStud.size()-1) || (u < vTempStud.size()-1);){%>
<body onLoad="window.print()">  
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="table2">
  <tr> 
    <td height="25" colspan="2"><div align="center"> 
        <p><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></p>
        <font size="2"> UNIVERSITY OF ILOILO<br>
        Testing Service<br>
        AY 2006 - 2007<br>
        PLACEMENT TEST RESULT </font> </div></td>
  </tr>
  <tr> 
    <td height="10" colspan="2"></td>
  </tr>
  <tr> 
    <td width="50%" height="25"> &nbsp;&nbsp; Test Type : <strong><font size="1"><%=WI.getStrValue(dbOP.mapOneToOther("HM_CT_TESTTYPE","TEST_TYPE_INDEX",WI.fillTextValue("test_type"),"TEST_TYPE",""),"All")%></font></strong></td>
    <%if(WI.fillTextValue("stud_type").compareTo("0") == 0)
		strTemp = "Permanent";
	  else if(WI.fillTextValue("stud_type").compareTo("1") == 0)
		strTemp = "Temporary";
	  else
	  	strTemp = "All";
	%>
    <td width="50%"> &nbsp;&nbsp; Student Type : <strong><font size="1"><%=strTemp%></font></strong></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;&nbsp; Test Code : <strong><font size="1"><%=WI.getStrValue(dbOP.mapOneToOther("HM_CT_SCHED","SCHED_INDEX",WI.fillTextValue("test_code"),"TEST_CODE",""),"All")%></font></strong></td>
    <td height="25">&nbsp;&nbsp; Date of Test : <strong><font size="1"><%=WI.getStrValue(WI.fillTextValue("exam_date_fr")," - ")+" "+WI.getStrValue(WI.fillTextValue("exam_date_to"),"")%></font></strong></td>
  </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>		
      <td height="23" align="right">&nbsp; </td>
    </tr>
  </table> 
<% if (u < vTempStud.size()-1 && vTempStud.size() > 1) {%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr> 
    <td height="23" colspan="6" class="thinborder"><div align="center"><strong><font  size="1">LIST 
        OF TEMPORARY STUDENT(S)</font></strong></div></td>
  </tr>
  <tr> 
    <td width="6%" class="thinborder"><div align="center" ><strong><font size="1">COUNT NO.</font></strong></div></td>
    <td width="12%" height="25" class="thinborder"><div align="center"><strong><font size="1">STUDENT 
        ID</font></strong></div></td>
    <td width="23%" class="thinborder"><div align="center"><strong><font size="1">STUDENT 
        NAME</font></strong></div></td>
    <td width="23%" class="thinborder"><div align="center"><strong><font size="1">TEST 
        TYPE / CODE</font></strong></div></td>
    <td width="15%" class="thinborder"><div align="center"><strong><font size="1">VENUE</font></strong></div></td>
    <td width="21%" class="thinborder"><div align="center"><strong><font size="1">DATE 
        OF TEST</font></strong></div></td>
  </tr>
  <% 
 for(int iCount = 0; iCount <= iMaxStudPerPage; u += 8,++iNumStud,iCount++){
  	if (iCount >= iMaxStudPerPage || u >= vTempStud.size()){
		if(u >= vTempStud.size() && vPermStud.size() <= 1)
			bolPageBreak = false;
		else
			bolPageBreak = true;
			break;			
		}%>	
    <tr>
	  <td class="thinborder" height="25"><div align="center"><%=iNumStud%></div></td>
      <td class="thinborder" height="25"><div align="center"><font size="1"><%=(String)vTempStud.elementAt(u)%></font></div></td>
      <td class="thinborder" height="25"><font size="1">&nbsp;<%=WI.formatName((String)vTempStud.elementAt(u+1),(String)vTempStud.elementAt(u+2),(String)vTempStud.elementAt(u+3),4)%></font></td>
      <td class="thinborder" height="25"><font size="1">&nbsp; <%=(String)vTempStud.elementAt(u+4)+" / "+(String)vTempStud.elementAt(u+5)%><%
			for(; (u + 8) < vTempStud.size() ;){
			 if(((String)vTempStud.elementAt(u)).compareTo((String)vTempStud.elementAt(u + 8)) != 0)
					break;
			 strTempAddlVenue += (String)vTempStud.elementAt(u + 6) +"<br>&nbsp; ";
			 strTempAddlTestDate += (String)vTempStud.elementAt(u + 7) +"<br>&nbsp; ";%>
			 <br>&nbsp; <%=(String)vTempStud.elementAt(u + 8 + 4)+" / "+(String)vTempStud.elementAt(u + 8 +  5)%>
		     <%u += 8;}%>
			</font></td>
            <td height="25" class="thinborder"><font size="1">&nbsp; <%=strTempAddlVenue + (String)vTempStud.elementAt(u+6)%></font></td>
            <td height="25" class="thinborder"><font size="1">&nbsp; <%=strTempAddlTestDate + (String)vTempStud.elementAt(u+7)%></font></td>
          </tr>
          <%
		  strTempAddlVenue = "";strTempAddlTestDate = "";
		  %>	
	<%}  
	if (u >= vTempStud.size() && vPermStud.size() < 1){	
   %>
  <tr> 
    <td class="thinborder" colspan="6" ><div align="center"> *****************NOTHING FOLLOWS *******************</div></td>
  </tr>
   <%}else{%>    
  <tr> 
    <td class="thinborder" colspan="6" ><div align="center"> ************** CONTINUED ON NEXT PAGE ****************</div></td>
  </tr>
  <%}%>
</table><%
//INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END. 
    if (bolPageBreak) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
    }
    else{
  		bolStartNextTable = true;	
    }
  %>
  <br><br>    
  <%    
  if ( u >= vTempStud.size() && v < vPermStud.size() && vPermStud.size() > 1 && bolStartNextTable) { %> 

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr> 
    <td height="23" colspan="6"  class="thinborder"><div align="center"><strong><font size="1"> 
        LIST OF PERMANENT STUDENT(S)</font></strong></div></td>
  </tr>
  <tr> 
    <td width="6%" class="thinborder"><div align="center" ><strong><font size="1">COUNT NO.</font></strong></div></td>
    <td width="12%" height="25" class="thinborder"><div align="center"><strong><font size="1">STUDENT 
        ID</font></strong></div></td>
    <td width="23%" class="thinborder"><div align="center"><strong><font size="1">STUDENT 
        NAME</font></strong></div></td>
    <td width="24%" class="thinborder"><div align="center"><strong><font size="1">TEST TYPE 
        / CODE</font></strong></div></td>
    <td width="15%" class="thinborder"><div align="center"><strong><font size="1">VENUE</font></strong></div></td>
    <td width="20%" class="thinborder"><div align="center"><strong><font size="1">DATE OF 
        TEST</font></strong></div></td>
  </tr>
  <%for(int iCount = 0; iCount <= iMaxStudPerPage; v += 8,++iNumStud2,iCount++){
		if (iCount >= iMaxStudPerPage || v >= vPermStud.size()){
			if(v >= vPermStud.size())
				bolPageBreak = false;	
			else
				bolPageBreak = true;
			break;
		}
	%>
     <tr> 
       <td height="25" class="thinborder"><div align="center"><%=iNumStud2%></div></td>
       <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vPermStud.elementAt(v)%></font></div></td>
       <td height="25" class="thinborder"><font size="1">&nbsp;<%=WI.formatName((String)vPermStud.elementAt(v+1),(String)vPermStud.elementAt(v+2),(String)vPermStud.elementAt(v+3),4)%></font></td>
       <td height="25" class="thinborder"><font size="1">&nbsp; <%=(String)vPermStud.elementAt(v+4)+" / "+(String)vPermStud.elementAt(v+5)%><%
			for(; (v + 8) < vPermStud.size() ;){
			 if(((String)vPermStud.elementAt(v)).compareTo((String)vPermStud.elementAt(v + 8)) != 0)
					break;
			 strTempAddlVenue += (String)vPermStud.elementAt(v + 6) +"<br>&nbsp; ";
			 strTempAddlTestDate += (String)vPermStud.elementAt(v + 7) + "<br>&nbsp; ";%>
			 <br>&nbsp; <%=(String)vPermStud.elementAt(v + 8 + 4)+" / "+(String)vPermStud.elementAt(v + 8 +  5)%>
		     <%v += 8;}%>
			</font></td>
            <td height="25" class="thinborder"><font size="1">&nbsp; <%=strTempAddlVenue + (String)vPermStud.elementAt(v+6)%></font></td>
            <td height="25" class="thinborder"><font size="1">&nbsp; <%=strTempAddlTestDate + (String)vPermStud.elementAt(v+7)%></font></td>
          </tr>
          <%
		  strTempAddlVenue = "";strTempAddlTestDate = "";
		  %>
  <%}
  if (v >= vPermStud.size()){%>
  <tr> 
    <td class="thinborder" colspan="6" ><div align="center"> ***************** NOTHING FOLLOWS *******************</div></td>
  </tr>
  <%}else{%>
  <tr> 
    <td class="thinborder" colspan="6" ><div align="center"> ************** CONTINUED ON NEXT PAGE ****************</div></td>
  </tr>
  <%}//end else%>
</table>
<%}
//INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END. 
 if (bolPageBreak) {%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
 <%}//page break only if it is not last page. 
 }%>  
</body>
</html>
<% 
dbOP.cleanUP();
%>