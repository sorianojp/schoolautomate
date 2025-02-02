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

-->
</style>
</head>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR,eDTR.TimeInTimeOut" %>
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
								"Admin/staff-eDaily Time Record-Employees with Adjustments",
								"emp_dtr_adjustments.jsp");
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
														"edtr_adjustments_print.jsp");	
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
TimeInTimeOut tRec = new TimeInTimeOut();

 strTemp = request.getParameter("info_index");

vRetResult = RE.searchEDTRAdjustments(dbOP);


%>
<form action="./edtr_adjustments_print.jsp" name="dtr_op" >
  <table width="100%" border="0" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
        </td>
  </tr>
<% if (vRetResult!= null) { %>
  <tr> 
      <td> 
        <br> 
      <table width="100%" border="1" cellpadding="3" cellspacing="0">
          <tr bgcolor="#006A6A"> 
            <% strTemp = request.getParameter("from_date") + " - " + request.getParameter("to_date"); %>
            <td  colspan="6"><div align="center"><font color="#FFFFFF"><strong>LIST 
                OF EMPLOYEE DTR ADJUSTMENTS (<%=strTemp%>)</strong></font></div></td>
          </tr>
          <tr> 
            <td width="13%" height="30" bgcolor="#EBEBEB"><strong><font size="1">EMPLOYEE 
              ID</font></strong></td>
            <td width="12%" height="30" bgcolor="#EBEBEB"><font size="1"><strong>STATUS</strong></font></td>
            <td width="12%" height="30" bgcolor="#EBEBEB"><font size="1"><strong>DATE</strong></font></td>
            <td width="14%" height="30" bgcolor="#EBEBEB"><font size="1"><strong>FROM 
              </strong></font></td>
            <td width="15%" height="30" bgcolor="#EBEBEB"><font size="1"><strong>ADJUSTED 
              DATE</strong></font></td>
            <td width="14%" height="30" bgcolor="#EBEBEB"><font size="1"><strong>ADJUSTED 
              TIME</strong></font></td>
          </tr>
          <% 
	String strTempName = null;
	long lTemp = 0l;
	for (int i = 0; i < vRetResult.size();  i+=22){
	if ((strTempName !=null) && (strTempName == ((String)vRetResult.elementAt(i+1)))){
		strTempName = "&nbsp";
	}else{
		strTempName = (String)vRetResult.elementAt(i+1);
	}
%>
          <tr> 
            <td><font size="1"><strong><%=strTempName%></strong></font></td>
            <%
	
lTemp = ((Long)vRetResult.elementAt(i+3)).longValue();
if (lTemp == 0){ 
	strTempName = "Time In";
	strTemp =  ((Long)vRetResult.elementAt(i+2)).toString();
	strTemp2 = (String)vRetResult.elementAt(i+4);
	strTemp3 = ((Long)vRetResult.elementAt(i+6)).toString();
	strTemp4 = (String)vRetResult.elementAt(i+8);
}else{
	strTempName = "Time Out";
	strTemp2 = (String)vRetResult.elementAt(i+5);
	strTemp3 = (String)vRetResult.elementAt(i+7);
	strTemp4 = (String)vRetResult.elementAt(i+9);
}	
	if (strTemp3!=null)
	 	strTemp3 = WI.formatDateTime(Long.parseLong(strTemp3),2);
	 else
	 	strTemp3 = "&nbsp;";	

%>
            <td><font size="1"><strong><%=strTempName%></strong></font></td>
            <td><font size="1"><strong><%=WI.getStrValue(strTemp2,"&nbsp;")%></strong></font></td>
            <td><font size="1"><strong><%=WI.getStrValue(Long.toString(lTemp),"&nbsp;")%></strong></font></td>
            <td><font size="1"><strong><%=WI.getStrValue(strTemp4,"&nbsp;")%></strong></font></td>
            <td><font size="1"><strong><%=WI.getStrValue(strTemp3,"&nbsp;")%></strong></font></td>
          </tr>
          <%
	strTempName =(String)vRetResult.elementAt(i+1);
} // end for loop
%>
        </table>
	</td>
  </tr>
<%}else{%>
  	<tr> 
    	  <td><strong><%=RE.getErrMsg()%></strong> </td>
	  </tr>
<%}%>
</table>        
<input type="hidden" name="info_index">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>