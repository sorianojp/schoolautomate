<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
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

-->
</style>
<body onLoad="javascript:window.print();">
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR" %>
<%

String strSchCode = (String)request.getSession(false).getAttribute("school_code");

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strTemp4 = null;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS-Employees with Late Time-in Record"
								,"summary_emp_late_timein_detail_print.jsp");
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
														null);	
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Payroll","DTR",request.getRemoteAddr(), 
															null);	
}
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



	vRetResult = RE.searchLateTimeIn(dbOP);	
	if (vRetResult == null || vRetResult.size() == 0)
		strErrMsg = RE.getErrMsg();

%>
<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>","</strong></font>","&nbsp;")%>
<% if (vRetResult !=null){ 
	enrollment.Authentication authentication = new enrollment.Authentication();
    Vector vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	strTemp = WI.fillTextValue("emp_id");
	
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);
	
	strTemp3 = (String)vEmpRec.elementAt(13);

	if (strTemp3 == null) 
		strTemp3 = (String)vEmpRec.elementAt(14);
	else
		strTemp3+= WI.getStrValue((String)vEmpRec.elementAt(14),"/","","");


String[] astrMonth = {"","January", "February","March", "April", "May","June","July",  
						"August", "September", "October", "November", "December"};		
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      
    <td height="25"><%=WI.fillTextValue("emp_id")%> ::<strong> <%=WI.getStrValue(strTemp)%></strong> :: <%=WI.getStrValue(strTemp2)%> :: <%=WI.getStrValue(strTemp3)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ECF3FB"> 
   <% strTemp = WI.fillTextValue("from_date") + " - " + WI.fillTextValue("to_date"); %>
   <% 
	 if (WI.fillTextValue("month").length() > 0) {
	 	strTemp = astrMonth[Integer.parseInt(WI.getStrValue(WI.fillTextValue("month"),"0"))];
		
		strTemp += " " + WI.fillTextValue("year");
	 }
   %> 	  

      <td height="25"  colspan="4" align="center" class="thinborder"><strong>DETAIL 
      OF EMPLOYEE'S LATE TIME-IN (<%=strTemp%>)</strong></td>
    </tr>
    <tr> 
      <td width="22%" height="30" align="center" bgcolor="#EBEBEB" class="thinborder"><strong>DATE</strong></td>
      <td width="29%" height="30" align="center" bgcolor="#EBEBEB" class="thinborder"><strong>EXPECTED 
        TIME IN</strong></td>
      <td width="29%" align="center" bgcolor="#EBEBEB" class="thinborder"><strong>ACTUAL 
        TIME IN</strong></td>
      <td width="20%" height="30" align="center" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">TOTAL 
        MINUTES </font></strong></td>
    </tr>
<%  
	for ( int i = 0 ; i< vRetResult.size(); i+=5){  	
%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+2)),2)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+3)),2)%>&nbsp;</td>
      <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+4)%> &nbsp;</td>
    </tr>
    <%} // end for loop%>
  </table>
  <%}%>
</form>
</body>
</html>
<% dbOP.cleanUP(); %>