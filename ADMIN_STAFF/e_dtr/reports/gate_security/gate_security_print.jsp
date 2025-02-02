<%@ page language="java" import="utility.*,eDTR.GateSecurity,payroll.PReDTRME,java.util.Vector" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employees with absences</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css"> 
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script> 
<body onLoad="javascript:window.print();">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	
	Vector vRetResult = null;
 	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Reports & Statistics - Gate Security","gate_security.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"gate_security.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}			

//end of authenticaion code. 
int iSearchResult = 0;
int i =0;
	String strPayrollPeriod  = null;	
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);

GateSecurity gSec = new GateSecurity(request);

vRetResult = gSec.operateGateSecurityExcessBreak(dbOP, request, 4);
%>
<form name="form_">
  <% if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100" height="25" colspan="3" align="right">&nbsp;</td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="11%" height="25" align="center"  class="thinborder"><strong><font size="1">EMPLOYEE 
      ID</font></strong></td>
      <td width="38%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE 
      NAME </font></strong></td>
			<!--
      <td width="10%" align="center" class="thinborder"><strong><font size="1">EMP. 
      TYPE</font></strong></td>
      <td width="11%" align="center" class="thinborder"><strong><font size="1">EMP. 
      STATUS</font></strong></td>
      
			<td width="16%" align="center" class="thinborder"><strong><font size="1">DEPT/ 
      OFFICE</font></strong></td>
			-->
      <td width="11%" align="center" class="thinborder"><strong><font size="1">TOTAL<br> 
      LATE / UT </font></strong></td>
      <td width="11%" align="center" class="thinborder"><strong><font size="1">HOURLY RATE</font></strong></td>
      <td width="11%" align="center" class="thinborder"><strong><font size="1">DEDUCTION</font></strong></td>
    </tr>
    <%
		String[] astrConvertGender = {"M","F"};
		int iCount = 1;
		for(i = 0 ; i < vRetResult.size(); i +=15,iCount++){
			if ((WI.getStrValue((String)vRetResult.elementAt(i + 11), "0")).equals("0")) 
				continue;
		%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),
	  (String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>
			<!--
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 6)%></td>      
			<td class="thinborder"> &nbsp; 
        <% if(vRetResult.elementAt(i + 8) != null) {//outer loop.
	  		if(vRetResult.elementAt(i + 9) != null) {//inner loop.%> <%=(String)vRetResult.elementAt(i + 8)%>/<%=(String)vRetResult.elementAt(i + 9)%> <%}else{%> <%=(String)vRetResult.elementAt(i + 8)%> <%}//end of inner loop/
	  	}else if(vRetResult.elementAt(i + 9) != null){//outer loop else%> <%=(String)vRetResult.elementAt(i + 9)%> <%}%> </td>
			-->
      <td align="right" class="thinborder"> <%=(String)vRetResult.elementAt(i + 11)%>&nbsp;</td>
      <td class="thinborder" align="right"><%=(String)vRetResult.elementAt(i + 12)%>&nbsp;</td>
      <td class="thinborder" align="right"><%=(String)vRetResult.elementAt(i + 13)%>&nbsp;</td>
    </tr>
    <%}//end of for loop to display employee information.%>
  </table>
   <%}//only if vRetResult not null
%>
    

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>