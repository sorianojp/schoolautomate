<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<body>
<%@ page language="java" import="utility.*,enrollment.FAPayment,java.util.Vector" buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Modifications","payment_modification.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"payment_modification.jsp");
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

FAPayment faPayment = new FAPayment();
//enrollment.FAPaymentExtn faPayment = new enrollment.FAPaymentExtn();


Vector vRetResult =null;
int iElemCount = 0;

vRetResult = faPayment.generateModifiedOR(dbOP, request);
if(vRetResult == null)
	strErrMsg = faPayment.getErrMsg();
else
	iElemCount = faPayment.getElemCount();


String[] astrConvertSem = {"Summer", "First Semester", "Second Semester", "Third Semester", "Fourth Semester"};
if(vRetResult != null && vRetResult.size() > 0){

boolean bolPageBreak = false;

int iRowCount = 0;
int iNoOfStudPerPage = 35;

if(WI.fillTextValue("rows_per_pg").length() > 0)
	iNoOfStudPerPage = Integer.parseInt(WI.fillTextValue("rows_per_pg"));

int iPageCount = 0;
int iTotalStud = (vRetResult.size()/iElemCount);
int iTotalPageCount = iTotalStud/iNoOfStudPerPage;
if(iTotalStud % iNoOfStudPerPage > 0)
	++iTotalPageCount;

for(int i = 0; i < vRetResult.size(); ) {
	iRowCount = 0;
	if(bolPageBreak){
		bolPageBreak = false;
		%>
		<div style="page-break-after:always;">&nbsp;</div>
	<%}
%>  
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" align="center"><strong><%=SchoolInformation.getSchoolName(dbOP, true, false)%></strong><br>
	  <%=SchoolInformation.getAddressLine1(dbOP, false, false)%><br><br>	  </td>
    </tr>
    <tr> 
      <td height="25" bgcolor=""><div align="center"><strong>LIST OF MODIFIED PAYMENT</strong><br>
	  <%
	  strTemp = WI.fillTextValue("sy_from");
	  if(strTemp.length() > 0)
	  	strTemp = " S.Y. "+strTemp+"-"+WI.fillTextValue("sy_to");
	  if(WI.fillTextValue("semester").length() > 0)	
	  	strTemp = astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))] + strTemp;
	  %><%=strTemp%></div></td>
    </tr>
    <tr>
        <td height="25" align="right"><font size="1">Page <%=++iPageCount%> of <%=iTotalPageCount%></font></td>
    </tr>
  </table>
  <table class="thinborder" width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr align="center"> 
      <td class="thinborder" width="6%" height="25"><div align="center"><font size="1"><strong>OR. No.</strong></font></div></td>
      <td class="thinborder" width="6%"><font size="1"><strong>Student ID</strong></font></td>
      <td class="thinborder" width="10%"><font size="1"><strong>Student Name</strong></font></td>
      <td class="thinborder" width="8%"><div align="center"><font size="1"><strong>SY (Term)</strong></font></div></td>
      <td class="thinborder" width="8%"><div align="center"><font size="1"><strong>Amount</strong></font></div></td>
      <td class="thinborder" width="10%"><div align="center"><font size="1"><strong>OR Printed By</strong></font></div></td>
      <td class="thinborder" width="8%"><div align="center"><font size="1"><strong>Transaction Date</strong></font></div></td>
      <td class="thinborder" width="8%"><div align="center"><font size="1"><strong>Payment For</strong></font></div></td>
      <td class="thinborder" width="15%"><div align="center"><font size="1"><strong>Reason</strong></font></div></td>
      <td class="thinborder" width="10%"><font size="1"><strong>Modified By</strong></font></td>      
	  <td class="thinborder" width="8%"><font size="1"><strong>Date Modified</strong></font></td>      
    </tr>
    <%
 for(; i < vRetResult.size(); i += iElemCount) {
 
 	if(++iRowCount > iNoOfStudPerPage){				
		bolPageBreak = true;
		break;
	}
 %>
    <tr> 
      <td class="thinborder" height="25"><%=vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i+1)%></td>
	  <%
	  strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4);
	  %>
      <td class="thinborder"><%=strTemp%></td>
	  <%
	  strTemp = (String)vRetResult.elementAt(i + 5)+"-"+((String)vRetResult.elementAt(i + 6)).substring(2)+
		  	WI.getStrValue((String)vRetResult.elementAt(i + 7)," (",")","");
	  %>
      <td class="thinborder"><%=strTemp%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 8),true)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i+9)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i+13)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i+15)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i+16)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i+17)%></td>      
	  <td class="thinborder"><%=vRetResult.elementAt(i+14)%></td>      
    </tr>
    <%}%>
  </table>
 <%}%>
 <script>window.print();</script>
<%}%>


</body>
</html>
<%
dbOP.cleanUP();
%>