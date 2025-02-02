<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="javascript:window.print();">
<%@ page language="java" import="utility.*,eDTR.RestDays,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS-Summary Emp without Absent","summary_emp_without_absent.jsp");
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
														"summary_emp_without_absent.jsp");	
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

int iSearchResult = 0;

RestDays rD = new RestDays(request);

	vRetResult = rD.viewAbsentEmployees(dbOP, request,false);
	if(vRetResult == null)
		strErrMsg = rD.getErrMsg();
	else	
		iSearchResult = rD.getSearchCount();


if(vRetResult != null && vRetResult.size() > 0){%>

<div align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
            Human Resources Development Center<br>
       
		</div>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3"><div align="center"><strong>SUMMARY 
          OF EMPLOYEES WITHOUT ABSENT (<%=WI.formatDate(request.getParameter("date_fr"),10)%> - <%=WI.formatDate(request.getParameter("date_to"),10)%>)</strong></div></td>
    </tr>
    <tr>
      <td width="66%" ><b> TOTAL RESULT: <%=iSearchResult%> </b></td>
      <td width="34%">&nbsp;</td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="14%" height="25"  class="thinborder"><div align="center"><strong><font size="1">EMPLOYEE 
          ID</font></strong></div></td>
      <td width="25%" class="thinborder"><div align="center"><strong><font size="1">EMPLOYEE 
          NAME </font></strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong><font size="1">GENDER</font></strong></div></td>
      <td width="11%" class="thinborder"><div align="center"><strong><font size="1">EMP. 
          STATUS</font></strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong><font size="1">POSITION</font></strong></div></td>
      <td width="29%" class="thinborder"><div align="center"><strong><font size="1">DEPT / 
          OFFICE</font></strong></div></td>
    </tr>
    <%
	String[] astrConvertGender = {"M","F"};
for(int i = 0 ; i < vRetResult.size(); i +=12){%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),
	  (String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>
      <td class="thinborder"><%=astrConvertGender[Integer.parseInt((String)vRetResult.elementAt(i + 5))]%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder"> <% if(vRetResult.elementAt(i + 8) != null) {//outer loop.
	  		if(vRetResult.elementAt(i + 9) != null) {//inner loop.%> <%=(String)vRetResult.elementAt(i + 8)%>/<%=(String)vRetResult.elementAt(i + 9)%> <%}else{%> <%=(String)vRetResult.elementAt(i + 8)%> <%}//end of inner loop/
	  }else if(vRetResult.elementAt(i + 9) != null){//outer loop else%> <%=(String)vRetResult.elementAt(i + 9)%> <%}%> </td>
    </tr>
    <%}//end of for loop to display employee information.%>
  </table>
<%}//only if vRetResult not null
%>

</body>
</html>
<%
dbOP.cleanUP();
%>