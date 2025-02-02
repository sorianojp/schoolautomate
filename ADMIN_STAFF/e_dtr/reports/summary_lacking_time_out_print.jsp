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

<body onLoad="javascript:window.print()">
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR, eDTR.eDTRUtil" %>
<%

	
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	Vector vRetResult = null;
	int iSearchResult =0;
	int iPageCount = 0;
		
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Employees with Lacking Time Out Record",
								"summary_emp_with_lacking_timeout_records.jsp");
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
														"summary_emp_with_lacking_timeout_records.jsp");	
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
	if (vRetResult == null) 
		strErrMsg = RE.getErrMsg();
	else iSearchResult = RE.getSearchCount();
	
	if (RE.defSearchSize  != 0){
		iPageCount = iSearchResult/RE.defSearchSize;
		if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;
	}

if (strErrMsg != null) { 
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5">&nbsp;<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>","</strong></font>","")%></td>
	</tr>
  </table>
<% }  if (vRetResult != null) {%>
<div align="center"> 
	<font size="2"> 
			<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
            Human Resources Development Center<br> </font>
       
</div>  
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="56%"><br>        &nbsp;&nbsp;<strong>Total : <%=iSearchResult%>  </strong>&nbsp;<strong>Records<br>
        <br>
        </strong></td>
    </tr>
  </table>
<% int iCtr = 0;int i=0;
	for (; i < vRetResult.size();) {
	  iCtr = 0; %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <% strTemp = WI.fillTextValue("from_date") + " - " + WI.fillTextValue("to_date"); %>
      <td height="25"  colspan="5" align="center" class="thinborder"> <strong>LIST 
      OF EMPLOYEE WITH LACKING TIME OUT (<%=strTemp%>)</strong></td>
    </tr>
    <tr> 
      <td width="14%" class="thinborder"><strong>&nbsp;EMPLOYEE ID</strong></td>
      <td width="32%" class="thinborder"><strong>&nbsp;NAME</strong></td>
      <td width="21%" height="30" class="thinborder"> <div align="center"><strong>DEPT 
          / OFFICE</strong></div></td>
      <td width="16%" height="30" class="thinborder"><strong>&nbsp;DATE</strong></td>
      <td width="17%" height="30" class="thinborder"><strong> &nbsp;TIME IN </strong></td>
    </tr>
    <%		strTemp = null;
		  		 for (; i < vRetResult.size() && iCtr < 51 ; i+=10, iCtr++ )  {%>
    <tr> 
      <% if (strTemp!=null && strTemp.compareTo((String)vRetResult.elementAt(i+1))==0){
		strTemp2 ="&nbsp;";
		strTemp3 ="&nbsp;";
	}else{
		strTemp = (String)vRetResult.elementAt(i+1);
		strTemp2 = (String)vRetResult.elementAt(i+7);
		strTemp3 = WI.formatName((String)vRetResult.elementAt(i+4),(String)vRetResult.elementAt(i+5),
								 (String)vRetResult.elementAt(i+6),4);
	}
%>
      <td class="thinborder">&nbsp;<%=strTemp2%></td>
      <td class="thinborder">&nbsp;<%=strTemp3%></td>
<% 
	strTemp3 = (String)vRetResult.elementAt(i+8);
	if (strTemp3 != null) 
		strTemp3 += WI.getStrValue((String)vRetResult.elementAt(i+9)," :: ","","");
	else strTemp3 = (String)vRetResult.elementAt(i+9);
%>
      <td class="thinborder">&nbsp;<%=strTemp3%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td height="20" class="thinborder"> &nbsp;<%=eDTRUtil.formatTime(((Long)vRetResult.elementAt(i+2)).longValue())%></td>
    </tr>
    <%} //end for loop%>
</table>
<% if (i < vRetResult.size())  {%> 
<div style="page-break-before:always"> </div>
<%
   } 
 } // end outer for loop %> 

<%}%>

</body>
</html>
<% dbOP.cleanUP(); %>