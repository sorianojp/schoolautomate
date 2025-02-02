<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
	body{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	}
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
</style>
</head>
<body onLoad="window.print()">
<%@ page language="java" import="utility.*,utility.SysTrack,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-System Tracking","final_gs_mod_print.jsp");
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
														"System Administration","System Tracking",request.getRemoteAddr(),
														"final_gs_mod_print.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = null;
SysTrack ST = new SysTrack(request);
strTemp = WI.fillTextValue("page_action");
int iSearchResult = 0;

	vRetResult = ST.searchGradeMod(dbOP);
	if(vRetResult == null)
		strErrMsg = ST.getErrMsg();
	else	
		iSearchResult = ST.getSearchCount();
String[] astrSemester = {"Summer","1st Sem","2nd Sem"," 3rd Sem"};
%>
<div align="center"> <font size="2">
  <% if(vRetResult != null && vRetResult.size() > 0){%>
  <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
  <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
  <%=SchoolInformation.getInfo1(dbOP,false,false)%></font></font> </div>
<br>
<br>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr>
      
    <td width="66%" ><b> <font size="2">TOTAL RESULT: <%=iSearchResult%> </font></b></td>
      <td width="34%">&nbsp; </td>
    </tr></table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
      <td height="25"><div align="center"><strong><font size="2">LIST OF GRADES 
        MODIFIED 
        <% if (WI.fillTextValue("emp_id").length() > 0){%>
        <br>
        ( by <%=(String)vRetResult.elementAt(9)%> ) 
        <%} // ennd i emp id %>
        </font> </strong></div></td>
    </tr>
</table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="9%" class="thinborder"><div align="center"><strong>DATE EDITED</strong></div></td>
      <td width="13%" height="25" class="thinborder"><div align="center"><strong>STUDENT ID</strong></div></td>
      <td width="26%" class="thinborder"><div align="center"><strong>STUDENT NAME </strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong>SCHOOL YEAR (SEMESTER)</strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong>SUBJECT</strong></div></td>
      <% if (WI.fillTextValue("emp_id").length() == 0){%>
      <td width="8%" class="thinborder"><strong>MODIFIED BY </strong></td>
      <%}%>
    </tr>
    <% for(int i =0;i< vRetResult.size(); i +=12){%>
    <tr> 
      <td  class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i)%></font></div></td>
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></div></td>
      <td class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4)%></font></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+5) + " - "+(String)vRetResult.elementAt(i+6) %><br>
          (<%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+7))]%>)</font></div></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+8)%></font></td>
      <% if (WI.fillTextValue("emp_id").length() == 0){%>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+9)%></font></td>
      <%}%>
    </tr>
    <%} //end for loop%>
  </table>
 
  <%} // end if vretResutl%>
</body>
</html>
<%
dbOP.cleanUP();
%>
