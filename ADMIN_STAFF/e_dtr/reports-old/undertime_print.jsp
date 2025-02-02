<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Undertime Records</title>
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
	font-size: 9px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

-->
</style>
</head>
<body>

<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR, eDTR.eDTRUtil" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
    Vector vRetEDTR = new Vector();
	String strTemp2 = null;
	String strTemp3 = null;
	int iSearchResult =0;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-View/Print DTR","undertime_print.jsp");
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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(), 
														"undertime_print.jsp");	
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

ReportEDTR RE = new ReportEDTR(request);
vRetResult = RE.searchUndertime(dbOP);

%>
<% if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="5" cellspacing="5" bgcolor="#FFFFFF">
  <tr> 
  <td><br>
	<div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
	  <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br><br>
	</div>
	</td>
  </tr>
    <tr> 
      <td><table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
          <tr bgcolor="#cccccc"> 
            <td colspan="5" class="thinborder" height="20"><div align="center"><strong>LIST 
                OF EMPLOYEE UNDERTIME RECORDS (<%=WI.getStrValue(request.getParameter("from_date"),"")%> 
                - <%=WI.getStrValue(request.getParameter("to_date"),"")%>)</strong></font></div></td>
          </tr>
          <tr> 
            <td width="22%" class="thinborder" height="20"><div align="center"><strong><font size="1">EMPLOYEE 
                ID</font></strong></div></td>
            <td width="19%" class="thinborder"><div align="center"><font size="1"><strong>DATE</strong></font></div></td>
            <td width="24%" class="thinborder"><div align="center"><font size="1"><strong>ACTUAL 
                TIMEOUT</strong></font></div></td>
            <td width="24%" class="thinborder"><font size="1"><strong>REQUIRED TIME OUT</strong></font></td>
            <td width="24%" class="thinborder"><div align="center"><font size="1"><strong>MINUTES 
                UNDERTIME</strong></font></div></td>
          </tr>
          <% for (int iIndex= 0; iIndex < vRetResult.size() ; iIndex+=5) {%>
          <tr> 
            <td class="thinborder" height="20"><%=(String)vRetResult.elementAt(iIndex)%></td>
            <td class="thinborder"><%=(String)vRetResult.elementAt(iIndex+1)%></td>
            <td class="thinborder"><%=(String)vRetResult.elementAt(iIndex+3)%></td>
            <td class="thinborder"><%=(String)vRetResult.elementAt(iIndex+2)%></td>
            <td class="thinborder"><%=(String)vRetResult.elementAt(iIndex+4)%></td>
          </tr>
          <%} //end for loop%>
        </table></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
    </tr>
  </table>
<%}  // if vRetResult == null%>
</form>
<script language="javascript"><!--
window.setInterval("javascript:window.print();",0);
//window.setInterval("javascript:window.close();",0)
--></script>
</body>
</html>
