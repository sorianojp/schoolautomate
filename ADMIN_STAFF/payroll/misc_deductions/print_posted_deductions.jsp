<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscDeduction" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>View/print posted deductions</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">

<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
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
	font-size: 10px;
    }

-->
</style>
<script language="JavaScript" src="../../../jscript/common.js"></script> 
</head>

<body onLoad="window.print(); ">
<%
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
//add security here.	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-View/Print Posted","view_print_posted.jsp");

	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"view_print_posted.jsp");
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
Vector vRetResult = null;
PRMiscDeduction prMiscDed = new PRMiscDeduction(request);
boolean bolShowDeducted = false;
double dTemp = 0d;
	vRetResult = prMiscDed.searchMiscDeductions(dbOP);
%>
<form name="form_">
  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder" id="search1">
    <tr>
      <td height="26" colspan="9" align="center" class="thinborder"><strong><font color="#000000" size="2">LIST 
      OF POSTED MISC. DEDUCTIONS</font></strong></td>
    </tr>
    <tr> 
      <td width="8%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE ID</font></strong></td>
      <td width="14%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME</font></strong></td>
      <td width="14%" align="center" class="thinborder"><strong><font size="1">DEDUCTION NAME</font></strong></td>
      <td width="11%" height="26" align="center" class="thinborder"><font size="1"><strong>PERIOD</strong></font></td>
      <td width="9%" align="center" class="thinborder"><font size="1"><strong>AMOUNT</strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>DATE POSTED</strong></font></td>			
      <td align="center" class="thinborder"><font size="1"><strong>POSTED BY</strong></font></td>  
			<% if(WI.fillTextValue("is_posted").equals("1")){ %>    
			<td align="center" class="thinborder"><font size="1"><strong>PAYABLE BALANCE </strong></font></td>
			<%}%>
      <td align="center" class="thinborder"><font size="1"><strong>REFERENCE/ REMARKS </strong></font></td>
    </tr>
    <% 	for (int i= 0; i < vRetResult.size(); i+=24){	%>
    <tr> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1),(String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),4)%></td>
      <%
	String strTemp2 = (String)vRetResult.elementAt(i+5);
	if (strTemp2 == null)
		strTemp2 = (String)vRetResult.elementAt(i+7);
	else
		strTemp2 += WI.getStrValue((String)vRetResult.elementAt(i+7)," :: ","","");
		
%>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+10)%></td>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+11) +" - "+(String)vRetResult.elementAt(i+12)%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+13), true);
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <td width="12%" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+14)%></td>
      <td width="8%" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+15)%></td>
			<% if(WI.fillTextValue("is_posted").equals("1")){ 
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+17),true);
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(strTemp);
			if(dTemp == 0d)
				strTemp = "--";
			%>			
			<td width="10%" align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%}%>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+18),"");
				if(strTemp.length() > 0)
					strTemp += "<br>";				
				strTemp += WI.getStrValue((String)vRetResult.elementAt(i+19),"&nbsp;");
			%>
      <td width="14%" class="thinborder"><%=strTemp%></td>
    </tr>
    <%} //end for loop%>
  </table>
 
 <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr> 
      <td height="26">&nbsp;</td>
    </tr>
</table> 
 <%}%> 
 </form>
</body>
</html>
<%
dbOP.cleanUP();
%>