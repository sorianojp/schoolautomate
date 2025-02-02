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
	font-size: 10px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

-->
</style>
</head>
<body>
<%@ page language="java" import="utility.*,iCafe.ComputerUsage,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Internet Cafe Management-USAGE DETAILS -user usage detail",
								"iL_usage_users.jsp");
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
														"Internet Cafe Management",
														"USAGE DETAILS",request.getRemoteAddr(),
														"iL_usage_users.jsp");
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
ComputerUsage compUsage = new ComputerUsage();
Vector vRetResult = null;
int iSearchResult = 0;
	vRetResult = compUsage.getComputerUsageSummaryPerUser(dbOP, request);
	if(vRetResult == null || vRetResult.size() == 0)
		strErrMsg = compUsage.getErrMsg();
	else	
		iSearchResult = compUsage.getSearchCount();
 
//end of authenticaion code.
boolean bolIsStaff = false;
if(WI.fillTextValue("is_staff").length() > 0) 
	bolIsStaff = true;

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="62%" height="25">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
      <td width="38%" align="right"><font size="1"><strong>Date / Time :</strong> <%=WI.getTodaysDateTime()%></font></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="66%" height="25"><b> Total Result : <%=iSearchResult%></b></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFF9F"> 
      <td height="24" colspan="7" class="thinborder"><div align="center"><font color="#0000FF"><strong>SUMMARY 
          OF USAGE</strong></font></div></td>
    </tr>
    <tr> 
<%if(!bolIsStaff){%>      
      <td width="15%" height="20" class="thinborder"><div align="center"><font size="1"><strong>COLLEGE</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong><font size="1">COURSE</font></strong></div></td>
<%}%>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong><%if(bolIsStaff){%>EMPLOYEE<%}else{%>STUDENT<%}%> ID</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>LNAME, 
        FNAME, MI</strong></font></div></td>
      <td width="12%" class="thinborder"><strong><font size="1">TOTAL HOURS ALLOWED</font></strong></td>
      <td width="12%" class="thinborder"><strong><font size="1">TOTAL HOURS USED</font></strong></td>
      <td width="12%" class="thinborder"> <div align="center"><strong><font size="1">HRS 
        REMAINING </font> </strong> </div></td>
    </tr>
    <%
for(int i = 0; i < vRetResult.size(); i += 8){%>
    <tr> 
<%if(!bolIsStaff){%>      
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></font></td>
<%}%>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 4)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 5)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 6)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 7)%></font></td>
    </tr>
    <%}%>
  </table>
<script language="JavaScript">
window.print();
</script>  
 <%}//only if vRetResult not null
 %>
</body>
</html>
<%
dbOP.cleanUP();
%>