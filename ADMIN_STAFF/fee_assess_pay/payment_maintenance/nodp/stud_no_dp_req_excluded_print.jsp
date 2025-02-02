<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body>
<%@ page language="java" import="utility.*,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-ASSESSMENT ","stud_no_dp_req_excluded.jsp");
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
														"Fee Assessment & Payments","ASSESSMENT",request.getRemoteAddr(),
														"stud_no_dp_req_excluded.jsp");


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


//end of security code.
int iSearchResult = 0;
FAPmtMaintenance faPmt = new FAPmtMaintenance();
Vector vRetResult = null;

if(WI.fillTextValue("sy_from").length() > 0){
	vRetResult = faPmt.operateOnExcludeDP(dbOP, request, 3);	
	if(vRetResult == null)
		strErrMsg = faPmt.getErrMsg();
	else
		iSearchResult = faPmt.getSearchCount();			
}
if(strErrMsg != null){
	dbOP.cleanUP();
%>
<div align="center"><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></div>
  
<%return;}

if(vRetResult != null && vRetResult.size() > 0){
	
int iRowCount = 0;
int iMaxRowCount = 40;
boolean bolPageBreak = false;
int iCount = 1;
for(int i = 0; i < vRetResult.size(); )	{
	
		if(bolPageBreak){
			bolPageBreak = false;
%>		<div style="page-break-after:always;">&nbsp;</div>
		<%}%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	
 	<tr>
   	<td align="center">
      	<strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
         <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
         </font></strong>
      </td>
   </tr>
	<tr><td colspan="3" height="20" align="center"><strong>LIST OF STUDENT EXCLUDED FROM DOWNPAYMENT FOR SY <%=WI.fillTextValue("sy_from") + "-" +WI.fillTextValue("sy_to")%>
   	<%
		if(WI.fillTextValue("semester").length() > 0)
			strTemp = astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))];
		else
			strTemp = "";
		%><%=strTemp%></strong>
   </td>  
	</tr>
</table>

<table  bgcolor="#FFFFFF" class="thinborder" width="100%" border="0" cellspacing="0" cellpadding="0">
	
   
   <tr>
      <td width="5%" class="thinborder" align="center"><strong>COUNT</strong></td>
   	<td width="31%" height="20" class="thinborder"><strong>ID NUMBER</strong></td>
      <td width="35%" class="thinborder"><strong>STUDENT NAME</strong></td>
      <td width="29%" class="thinborder"><strong>COURSE - MAJOR</strong></td>      
   </tr>
   <%
	
	for(; i < vRetResult.size(); i+=5){
		iRowCount++;
		%>
   <tr>
      <td class="thinborder" align="right"><%=iCount++%>.&nbsp; &nbsp;</td>
   	<td height="18" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
      <%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4);
		%>
      <td height="18" class="thinborder"><%=strTemp%></td>
      
      <td height="18" class="thinborder"><%=strTemp%></td>   
   </tr>
   <%
		if(iRowCount >= iMaxRowCount){
			iRowCount = 0;
			bolPageBreak = true;
			i+=5;
			break;	
		}
	
	}%>
   
   
</table>

<%
	}//end outer loop%>
   
   <script>window.print();</script>
   
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>
