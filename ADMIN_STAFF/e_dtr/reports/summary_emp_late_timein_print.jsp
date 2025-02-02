<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR" %>
<%

///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
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
<body onLoad="window.print()">
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS-Employees with Late Time-in Record",
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
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"emp_late_timein_records.jsp");	
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
Vector vRetResultConsec = null;

	vRetResult = RE.searchLateTimeIn(dbOP);
	
	if (vRetResult == null || vRetResult.size() == 0)
		strErrMsg = RE.getErrMsg();

	if (WI.fillTextValue("consec_3_months").equals("1")){
		vRetResultConsec = RE.search3MonthsConsecutive9Late(dbOP);
	}


String[] astrMonth = {"","January", "February","March", "April", "May","June","July",  
						"August", "September", "October", "November", "December"};
		
	if (strErrMsg != null) { 
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  class="footerDynamic">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" ><%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>","</strong></font>","&nbsp;")%></td>
    </tr>
</table>
<%} if (vRetResult !=null){  %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <br> </div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;<strong>TOTAL : <%=RE.getSearchCount()%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ECF3FB"> 
   <% strTemp = WI.fillTextValue("from_date") + " - " + WI.fillTextValue("to_date"); 
    
	 if (WI.fillTextValue("month").length() > 0) {
	 	strTemp = astrMonth[Integer.parseInt(WI.getStrValue(WI.fillTextValue("month"),"0"))];
		
		strTemp += " " + WI.fillTextValue("year");
	 }
  %> 
	  
	  
      <td height="25"  colspan="6" align="center" class="thinborder"><strong>SUMMARY OF EMPLOYEES WITH LATE TIME-IN (<%=strTemp%>)</strong></td>
    </tr>
    <tr> 
      <td width="13%" height="30" align="center" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">EMPLOYEE 
        ID</font></strong></td>
      <td width="31%" height="30" align="center" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>EMPLOYEE 
        NAME </strong></font></td>
      <td width="18%" height="30" align="center" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>POSITION</strong></font></td>
      <td width="19%" align="center" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">
        <% if (bolIsSchool){%> 
	  COLLEGE / <%}%> OFFICE</font></strong></td>
      <td width="10%" align="center" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">FREQ . <br> 
      LATE </font></strong></td>
      <td width="9%" height="30" align="center" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">TOTAL 
          MINUTES </font></strong></td>
    </tr>
 <%  	for ( int i = 0 ; i< vRetResult.size(); i+=12){  %>
    <tr> 
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%>&nbsp;</td>
      <td class="thinborder"><%=WI.formatName((String)vRetResult.elementAt(i+2),
	  										  (String)vRetResult.elementAt(i+3),
											  (String)vRetResult.elementAt(i+4),4)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
	  <%
	  	strTemp = (String)vRetResult.elementAt(i+6);
		if (strTemp == null) 
			strTemp = (String)vRetResult.elementAt(i+7);
		else 
			strTemp += WI.getStrValue((String)vRetResult.elementAt(i+7), " :: ","","");
	  %>
      <td class="thinborder"><%=strTemp%>&nbsp;</td>
      <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+9)%>&nbsp;</td>
      <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+8)%>&nbsp;</td>
    </tr>
    <%} // end for loop%>
  </table>
<% if (vRetResultConsec!= null && vRetResultConsec.size() > 0){%>   
<br /><br/>
<table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ECF3FB"> 
      <td height="20"  colspan="4" align="center" class="thinborder"><strong>SUMMARY OF EMPLOYEES WITH 3 MONTHS CONSECUTIVE WITH 9 TARDINESS</strong></td>
    </tr>
    <tr> 
      <td width="12%" height="22" align="center" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">EMPLOYEE 
        ID</font></strong></td>
      <td width="30%" height="22" align="center" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>EMPLOYEE 
        NAME </strong></font></td>
      <td width="17%" height="22" align="center" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>POSITION</strong></font></td>
      <td width="18%" align="center" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">DEPT 
        / OFFICE</font></strong></td>
    </tr>
 <%	//System.out.println(vRetResult);
 	for ( int i = 0 ; i< vRetResultConsec.size(); i+=8){  
 %>
    <tr> 
      <td class="thinborder"><%=(String)vRetResultConsec.elementAt(i+1)%>&nbsp;</td>
      <td class="thinborder"><%=WI.formatName((String)vRetResultConsec.elementAt(i+2),
	  									(String)vRetResultConsec.elementAt(i+3),
										(String)vRetResultConsec.elementAt(i+4),4)%></td>
      <td class="thinborder"><%=(String)vRetResultConsec.elementAt(i+5)%></td>
	  <%
	  	strTemp = (String)vRetResultConsec.elementAt(i+6);
		if (strTemp == null) 
			strTemp = (String)vRetResultConsec.elementAt(i+7);
		else 
			strTemp += WI.getStrValue((String)vRetResult.elementAt(i+7), " :: ","","");
	  %>
      <td class="thinborder"><%=strTemp%>&nbsp;</td>
    </tr>
    <%} // end for loop%>
  </table>  
<%} 
}%>
</body>
</html>
<% dbOP.cleanUP(); %>