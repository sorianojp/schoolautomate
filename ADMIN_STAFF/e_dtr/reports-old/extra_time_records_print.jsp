<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
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
<body>
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	String strTemp2 = null;
	String strTemp3 = null;
	String strTemp4 = null;
	int iSearchResult =0;
	int iPageCount = 0;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Employees with Late Time-in Record",
								"emp_late_timein_records.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(), 
														"dtr_view.jsp");	
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
vRetResult = RE.searchExtraTime(dbOP);

if (vRetResult !=null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
  <td>
	<div align="center"><br>
          <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          </strong> <%=SchoolInformation.getAddressLine1(dbOP,false,true)%>
          <br>
	</div>
	</td>
  </tr>
    <tr> 
      <td width="100%" height="10">&nbsp;</td>
    </tr>
	</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
          <tr> 
            <% strTemp = request.getParameter("from_date") + " - " + request.getParameter("to_date"); %>
            <td  colspan="5" height="25" class="thinborder"><div align="center"><strong><font size="2">LIST OF 
                EMPLOYEE WITH EXTRA TIME (<%=strTemp%>)</font></strong></div></td>
          </tr>
          
          <tr bgcolor="#EBEBEB"> 
            <td width="17%" height="20" class="thinborder"><strong><font size="1">EMPLOYEE 
              ID</font></strong></td>
            <td width="16%" class="thinborder"><font size="1"><strong>DATE</strong></font></td>
            <td width="17%" class="thinborder"><font size="1"><strong>EXPECTED 
              TIME <%if(WI.fillTextValue("logSelect").startsWith("time_in")){%>IN
			  <%}else{%>OUT<%}%></strong></font></td>
            <td width="21%" class="thinborder"><strong><font size="1">ACTUAL TIME 
              <%if(WI.fillTextValue("logSelect").startsWith("time_in")){%>IN
			  <%}else{%>OUT<%}%> </font></strong></td>
            <td width="13%" class="thinborder"><strong><font size="1">EXTRA 
              MINUTES</font></strong></td>
          </tr>
          <%  strTemp2 = "";
	for ( int i = 0 ; i< vRetResult.size(); i+=5){ 
	
	strTemp = (String)vRetResult.elementAt(i);
	if (strTemp2.compareTo(strTemp) == 0){
		strTemp = "&nbsp;";
	}else{
		strTemp2 = strTemp;
	}
%>
          <tr> 
            <td height="20" class="thinborder"><%=strTemp%></td>
            <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
            <td class="thinborder"><%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+2)),2)%></td>
            <td class="thinborder"><%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+3)),2)%></td>
            <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%> &nbsp;</td>
          </tr>
          <%} // end for loop%>
        </table>
<script language="javascript">
<!--
window.setInterval("javascript:window.print();",0);
-->
</script>
<%}%>

</body>
</html>
<% dbOP.cleanUP(); %>