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

<body >
<%@ page language="java" import="utility.*,enrollment.HostelManagement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	WebInterface WI = new WebInterface(request);
	MessageConstant mConst = new MessageConstant();

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	boolean bolProceed = true;
	boolean bolIsStaff = true;
	String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
    String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","Septmber","October","November","December"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/Hostel Management-CHARGES- Billing statement","obs_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Hostel Management","CHARGES",request.getRemoteAddr(),
														"obs_print.jsp");
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

Vector vTemp = null;//occupant information
Vector vRetResult = null;//all occupants' information
Vector vStudBasicInfo = null;

HostelManagement HM = new HostelManagement();
vRetResult = HM.getBillingStatement(dbOP,request);
if(vRetResult == null)
{
	strErrMsg = HM.getErrMsg();
	bolProceed = false;
}

if(strErrMsg == null) strErrMsg = "";

if(!bolProceed)
{%><%=strErrMsg%>
<%
	dbOP.cleanUP();
	return;
}

float fTotalAmountDue = 0f;
for(int i= 0; i<vRetResult.size() ; ++i){
vTemp = (Vector)vRetResult.elementAt(i);
//System.out.println(vRetResult);

if(((String)vTemp.elementAt(2)).compareTo("4") ==0)
	bolIsStaff = false;
else
	bolIsStaff = true;
%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr >
		  <td height="25" colspan="6"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
			<%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
			<br>
			OCCUPANT'S BILLING STATEMENT (OBS)<strong><br>
			<br>
			</strong></div></td>
		</tr>
		</table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td height="25" colspan="2"><div align="right">Date &amp; time
			printed : <%=(String)WI.getTodaysDateTime()%></div></td>
	  </tr>
	 </table>

 <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="55%" height="25">ID Number : <strong><%=(String)vTemp.elementAt(0)%></strong></td>
    <td width="45%">Account category :<strong>
      <%
	  if(bolIsStaff){%>
      Employee
      <%}else{%>
      Student
      <%}%>
      </strong></td>
  </tr>
</table>
<%
if(!bolIsStaff){
vStudBasicInfo = HM.getCurrentSchoolYrCourseInfo(dbOP,(String)vTemp.elementAt(5));
if(vStudBasicInfo == null || vStudBasicInfo.size() ==0)
{
dbOP.cleanUP();
%>
<%=strErrMsg%>
<%
return;
}

%>


<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="55%" height="22">Account name : <strong><%=(String)vTemp.elementAt(1)%></strong></td>
    <td width="45%">School year : <strong><%=(String)vStudBasicInfo.elementAt(0)%> - <%=(String)vStudBasicInfo.elementAt(1)%></strong></td>
  </tr>
  <tr>
    <td height="25">Course/Major :<strong> <%=(String)vStudBasicInfo.elementAt(4)%>
      </strong></td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">Current Year/Term : <strong><%=(String)vStudBasicInfo.elementAt(2)%>/
      <%=astrConvertTerm[Integer.parseInt((String)vStudBasicInfo.elementAt(3))]%></strong></td>
    <td height="25">&nbsp;</td>
  </tr>
</table>
<%}else{%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25">Account name : <strong><%=(String)vTemp.elementAt(1)%></strong></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="25" colspan="2">College/Department/Office : <strong><%=WI.getStrValue(vTemp.elementAt(6))%>
	<%
	if(vTemp.elementAt(7) != null){%>
	/<%=(String)vTemp.elementAt(7)%>
	<%}%></strong></td>
  </tr>
</table>
<%}%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" colspan="4">Location/Name : <strong> <%=(String)vTemp.elementAt(3)%></strong></td>
    <td>Room #/House# : <strong><%=(String)vTemp.elementAt(4)%></strong></td>
  </tr>
  <tr>
    <td width="42%" height="25" colspan="4">Billing for : <strong>
	<%=astrConvertMonth[Integer.parseInt(request.getParameter("month_availed"))]%>
      - <%=request.getParameter("year_availed")%></strong></td>
    <td width="58%">&nbsp;</td>
  </tr>
</table>

<table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
  <tr>
    <td width="60%"><div align="center"><strong>PARTICULARS</strong></div></td>
    <td width="40%" height="25"><div align="center"><strong>AMOUNT DUE</strong></div></td>
  </tr>
<%
for(int j=10 ; j<vTemp.size(); ++j)
{//System.out.println((String)vTemp.elementAt(j+1));
fTotalAmountDue += Float.parseFloat((String)vTemp.elementAt(j+1));
%>
  <tr>
    <td height="25"><%=(String)vTemp.elementAt(j)%></td>
    <td><%=(String)vTemp.elementAt(j+1)%></td>
  </tr>
<%
++j;
}%>
  <tr>
    <td height="25">&nbsp;</td>
    <td>TOTAL AMOUNT DUE : <%=fTotalAmountDue%></td>
  </tr>
  </table>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>

 <%fTotalAmountDue = 0f;}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
