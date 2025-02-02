<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>

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
</head>
<body onLoad="window.print()">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	int iSearchResult =0;
	int iPageCount = 0;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics  and Reports - Non DTR Employees",
								"emp_non_dtr_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"emp_non_dtr_print.jsp");	
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

vRetResult = RE.getListNonDTREmployees(dbOP, true);
	
if (vRetResult !=null){ %>
     
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr> 
    <td height="25" colspan="4" align="center" bgcolor="#cccccc" class="thinborder"><strong>LIST 
        OF NON DTR EMPLOYEES</strong></td>
  </tr>
  <tr> 
    <td height="25" align="center" bgcolor="#EBEBEB" class="thinborder"><strong>EMPLOYEE 
      ID</strong></td>
    <td align="center" bgcolor="#EBEBEB" class="thinborder"><strong>NAME</strong></td>
    <td align="center" bgcolor="#EBEBEB" class="thinborder"><strong><%if(bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%> 
      / OFFICE</strong></td>
    <td align="center" bgcolor="#EBEBEB" class="thinborder"><strong>EMPLOYEE 
      TYPE </strong></td>
  </tr>
<% 	for (int i = 0; i < vRetResult.size(); i+=8){%>
  <tr> 
    <td width="14%" height="23" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
    <td width="26%" class="thinborder"><%= WI.formatName((String)vRetResult.elementAt(i+2),
												(String)vRetResult.elementAt(i+3),
												(String)vRetResult.elementAt(i+4),4)%></td>
    <% strTemp = (String)vRetResult.elementAt(i+5);
			   if (strTemp == null)
			   		strTemp = (String)vRetResult.elementAt(i+6);
				else{
					if ((String)vRetResult.elementAt(i+6)!=null){
						strTemp += " / "  + (String)vRetResult.elementAt(i+6);
					}
				}
			%>
    <td width="26%" class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"")%></td>
    <td width="21%" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
  </tr>
 <%	
 }//end of for loop.
 %>
</table> 	
 
<%}//end if vRetResult !null
else {%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
<tr>
	<td ><%=RE.getErrMsg()%></td>
</tr>
</table>
<%}%>       
</body>
</html>
<% dbOP.cleanUP(); %>