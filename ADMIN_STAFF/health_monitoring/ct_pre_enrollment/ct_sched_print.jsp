<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Admission</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">

<style type="text/css">
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

    TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-size: 11px;
    }
</style>
</head>
<body onLoad="window.print()">
<%@ page language="java" import="utility.*,java.util.Vector,health.CTPreEnrollment"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
		
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinical Test","ct_sched_print.jsp");
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
														"Health Monitoring","Clinical Test",request.getRemoteAddr(),
														"ct_sched_print.jsp");
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

	CTPreEnrollment CTPE = new CTPreEnrollment();
	Vector vRetResult = new Vector();
	
	vRetResult = CTPE.printTestSchedule(dbOP,WI.fillTextValue("temp_id"));
		if(vRetResult == null)	
			strErrMsg = CTPE.getErrMsg();

//end of authenticaion code.
		
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  <%if(vRetResult == null){%>
    <tr> 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
	<%}else{%>
    <tr>
      <td width="91%" height="25"><div align="center"><strong><font size="2">:::: 
        CLINICAL TESTS SCHEDULE SLIP::::</font></strong></div></td>	
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      
    <td width="100%" height="18"><font size="3">&nbsp;</font></td>
    </tr>
  </table>    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="header">
    <tr> 
      <td width="17" height="25">&nbsp;</td>    
    <td width="403" height="25"> Name : <%=(String)vRetResult.elementAt((vRetResult.size()-1))%></td>
      
    <td width="350" height="25">Student ID : <%=WI.fillTextValue("temp_id")%></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
    <td height="18" colspan="2"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      
    <td height="25" colspan="2">Schedule of Test(s):</td>
    </tr>
    <tr> 
      <td height="15" colspan="3"> <table width="98%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
          <tr bgcolor="#FFFFFF"> 
            <td width="13%"  class="thinborder" ><div align="center">Test Type</div></td>
            <td width="14%" class="thinborder"><div align="center">Test Code</div></td>
            <td width="11%" class="thinborder"><div align="center">Date of Test</div></td>
            <td width="23%" class="thinborder"><div align="center">Time</div></td>
            <td width="11%" class="thinborder"><div align="center">Venue</div></td>
            <td width="28%" class="thinborder"><div align="center">Contact Person</div></td>
          </tr>   
          <%if(vRetResult != null){
		  for(int iLoop = 0; iLoop < vRetResult.size()-1; iLoop+=7){%>       
          <tr bgcolor="#FFFFFF"> 
            <td class="thinborder" height="25"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(iLoop)%></font></div></td>
            <td class="thinborder" height="25"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(iLoop+1)%></font></div></td>
            <td class="thinborder" height="25"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(iLoop+2)%></font></div></td>
            <td class="thinborder" height="25"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(iLoop+3)%></font></div></td>
            <td class="thinborder" height="25"> <div align="center"><font size="1"><%=(String)vRetResult.elementAt(iLoop+4)%></font> </div></td>
            <td class="thinborder" height="25"><div align="center"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(iLoop+5),WI.getStrValue((String)vRetResult.elementAt(iLoop+6),"&nbsp;"))%></font></div></td>
          </tr>
		  <%}}%>         
        </table></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18"><div align="right"></div></td>
      <td height="18" align="right"><font size="1">print date: <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><div align="center"> </div></td>
    </tr>
  </table>   
  <%}%>
  </body>
</html>
<% 
dbOP.cleanUP();
%>