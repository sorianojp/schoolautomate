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
<body onLoad="javascript:window.print();">
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR, eDTR.eDTRUtil" %>
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
								"Admin/staff-eDaily Time Record-Employees with Lacking Time Out Record",
								"emp_no_timeout_records.jsp");
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
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"emp_no_timeout_records.jsp");	
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
vRetResult = RE.getLapseTInTout(dbOP);

if (vRetResult!=null){%>

<div align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
            Human Resources Development Center<br>
       
		</div>

        <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		  <tr> 
            <div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
              <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br><br>
            </div>
          </tr>
          <tr> 
            <% strTemp = WI.fillTextValue("from_date") + " - " + WI.fillTextValue("to_date"); %>
            <td  colspan="4" class="thinborder"><div align="center"><strong><font size="2">LIST 
        OF EMPLOYEE WITHOUT TIME OUT (<%=strTemp%>)</font></strong></div></td>
          </tr>
          <tr bgcolor="#EBEBEB"> 
            <td width="14%" class="thinborder"><strong><font size="1">EMPLOYEE 
              ID</font></strong></td>
            <td width="36%" height="20" class="thinborder"><strong><font size="1">NAME</font></strong></td>
            <td width="21%" class="thinborder"><font size="1"><strong>DATE</strong></font></td>
            <td width="18%" class="thinborder"><font size="1"><strong> 
              TIME IN </strong></font></td>
          </tr>
          <%	strTemp = null; strTemp2 = null; strTemp3 = null;
    for (int i=0; i < vRetResult.size(); i+=8)  {%>
          <tr> 
<% if (strTemp!=null && strTemp.compareTo((String)vRetResult.elementAt(i+1))==0){
		strTemp2 ="&nbsp;";
		strTemp3 ="&nbsp;";
	}else{
		strTemp = (String)vRetResult.elementAt(i+1);
		strTemp2 = (String)vRetResult.elementAt(i+7);
		strTemp3 = WI.formatName((String)vRetResult.elementAt(i+4),(String)vRetResult.elementAt(i+5),
								 (String)vRetResult.elementAt(i+6),1);
	}
%>
            <td class="thinborder" height="20"><%=strTemp2%></td>
            <td class="thinborder"><%=strTemp3%></td>
            <td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
            <td class="thinborder"><%=eDTRUtil.formatTime(((Long)vRetResult.elementAt(i+2)).longValue())%></td>
          </tr>
          <%}%>
</table>
    <%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td><strong><%=RE.getErrMsg()%></strong></td>
    </tr>
  </table>
<%}%>

</body>
</html>
<% dbOP.cleanUP(); %>