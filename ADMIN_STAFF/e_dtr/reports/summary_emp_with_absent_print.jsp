<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize11{
		font-size : 11px;
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
	
</style>
</head>

<body onLoad="javascript:window.print();" >
<%@ page language="java" import="utility.*,eDTR.RestDays,java.util.Vector" %>
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
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS- Emp With Absences","summary_emp_with_absent.jsp");
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
														"summary_emp_with_absent.jsp");	
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
if(WI.fillTextValue("searchEmployee").equals("1")){
	vRetResult = rD.viewAbsentEmployees(dbOP, request);
	if(vRetResult == null)
		strErrMsg = rD.getErrMsg();
	else	
		iSearchResult = rD.getSearchCount();
}

String[] astrMonth = {" Select Month"," January"," February", " March", " April", " May", " June",
					  " July", " August", " September"," October", " November", " December"};
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4" align="center"><strong>:::: 
        SUMMARY OF EMPLOYEES WITH ABSENCES PAGE ::::</strong></td>
    </tr>
  </table>

   <% if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="66%" ><b> TOTAL RESULT: <%=iSearchResult%> <br>
        <br>
      </b></td>
      <td width="34%" align="right">&nbsp;       </td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="13%" height="25" align="center"  class="thinborder"><strong><font size="1">EMPLOYEE 
      ID</font></strong></td>
      <td width="24%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE 
      NAME </font></strong></td>
<% if (!strSchCode.startsWith("AUF")) {%>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">GENDER</font></strong></td>
      <td width="9%" align="center" class="thinborder"><strong><font size="1">EMP. 
      TYPE</font></strong></td>
<%}%>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">EMP. 
      STATUS</font></strong></td>
      <td width="15%" align="center" class="thinborder"><strong><font size="1">DEPT/ 
      OFFICE</font></strong></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">TOTAL 
          ABSENCES </font></strong></div></td>
    </tr>
    <%
	String[] astrConvertGender = {"M","F"};
for(int i = 0 ; i < vRetResult.size(); i +=12){
	if (((String)vRetResult.elementAt(i + 11)).compareTo("0") ==0) continue;
%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),
	  (String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>
<% if (!strSchCode.startsWith("AUF")) {%>
      <td class="thinborder">&nbsp;<%=astrConvertGender[Integer.parseInt((String)vRetResult.elementAt(i + 5))]%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 7)%></td>
<%}%>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"> &nbsp; 
        <% if(vRetResult.elementAt(i + 8) != null) {//outer loop.
	  		if(vRetResult.elementAt(i + 9) != null) {//inner loop.%> <%=(String)vRetResult.elementAt(i + 8)%>/<%=(String)vRetResult.elementAt(i + 9)%> <%}else{%> <%=(String)vRetResult.elementAt(i + 8)%> <%}//end of inner loop/
	  }else if(vRetResult.elementAt(i + 9) != null){//outer loop else%> <%=(String)vRetResult.elementAt(i + 9)%> <%}%> </td>
      <td class="thinborder"> <div align="center"><%=(String)vRetResult.elementAt(i + 11)%></div></td>
    </tr>
    <%}//end of for loop to display employee information.%>
  </table>
<%}//only if vRetResult not null %>
  

</body>
</html>
<%
dbOP.cleanUP();
%>