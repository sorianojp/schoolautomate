<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/maintenancelinkscss.css" rel="stylesheet" type="text/css">
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



<body >
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-list print","enrollment_faculty_list_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
Vector vRetResult = null;
FacultyManagement FM = new FacultyManagement();

vRetResult = FM.viewFacultyPerDeptCollege( dbOP, request.getParameter("c_index"),request.getParameter("d_index"));
//dbOP.cleanUP();

if(vRetResult == null)
	strErrMsg = FM.getErrMsg();

if(strErrMsg == null) strErrMsg = "";
%>

  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%"><div align="center"><font size="1"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,true)%></font></div></td>
    </tr>
	<% if(strErrMsg != null){%>
	<tr>
      <td height="25">&nbsp;&nbsp; <%=strErrMsg%></td>
    </tr>
    <%}%>
	<tr>
      <td height="30"><div align="center"><strong>LIST OF FACULTIES</strong></div></td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0)
{%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="20%" height="25"><div align="center">COLLEGE NAME</div></td>
	  <td width="20%" height="25"><div align="center">DEPARTMENT</div></td>
      <td width="20%"><div align="center">EMPLOYEE ID</div></td>
      <td width="20%"><div align="center">EMPLOYEE NAME</div></td>
      <td width="6%"><div align="center">GENDER</div></td>
      <td width="12%"><div align="center">EMP. STATUS</div></td>
    </tr>
<%
	int iTotal = 0; //total faculty.
	String[] astrConvertGender = {"M","F"};
	String strCollgeIndex = null;
	String strDeptIndex = null;

	for(int i=0; i<vRetResult.size();){

	strCollgeIndex = (String)vRetResult.elementAt(i+9);
	strDeptIndex   = WI.getStrValue(vRetResult.elementAt(i+10));

	++iTotal;%>
	  <tr>
      <td height="25">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+7))%></td>
      <td height="25">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+8))%></td>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td><%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),1)%></td>
      <td><%=astrConvertGender[Integer.parseInt((String)vRetResult.elementAt(i+6))]%></td>
      <td><%=(String)vRetResult.elementAt(i+5)%></td>
    </tr>
<% i = i+11;
//check the next collge if it is same, do not display,
	for(int j=i; j< vRetResult.size(); )
	{
		if(strCollgeIndex.compareTo((String)vRetResult.elementAt(j+9)) !=0)
			break;
	 ++iTotal;
	 %>
	  <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;
	  <%
	  if(strDeptIndex.compareTo(WI.getStrValue(vRetResult.elementAt(j+10))) != 0)
	  {
	  	strDeptIndex = WI.getStrValue(vRetResult.elementAt(j+10));
		%><%=WI.getStrValue(vRetResult.elementAt(j+8))%>
	  <%}%>
	  </td>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td><%=WI.formatName((String)vRetResult.elementAt(j+2),(String)vRetResult.elementAt(j+3),(String)vRetResult.elementAt(j+4),1)%></td>
      <td><%=astrConvertGender[Integer.parseInt((String)vRetResult.elementAt(j+6))]%></td>
      <td><%=(String)vRetResult.elementAt(j+5)%></td>
    </tr>
<%
	j = j+11;
	i = j;
	}//end of inner loop
}%>
    <tr>
      <td  colspan="6" height="25">TOTAL NUMBER OF FACULTIES FOR
        THIS COLLEGE : <strong><%=iTotal%></strong></td>

    </tr>
  </table>
<%}//only if vRetResult is not null.
%>
<script language="JavaScript">
	window.print();
window.setInterval("javascript:window.close();",0);
</script>
</body>
</html>
