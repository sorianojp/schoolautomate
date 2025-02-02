<%@ page language="java" import="utility.*,enrollment.FAPayment,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee assessment & payment-Bank Deposit management","bd_main_print.jsp");
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
														"Fee Assessment & Payments","REPORTS",request.getRemoteAddr(),
														"bd_main.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
FAPayment faPmt = new FAPayment();

vRetResult = faPmt.operateOnBankDeposits(dbOP, request, 4);
boolean bolShowSummary = WI.fillTextValue("show_summary").equals("1");

String strTotalAmount = null;
if(vRetResult != null && vRetResult.size() > 0) 
	strTotalAmount = (String)vRetResult.remove(0);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body onLoad="window.print();">
<%if(strErrMsg != null) {%>
<p style="font-size:14px; font-weight:bold; color:#FF0000; font-family:Verdana, Arial, Helvetica, sans-serif"><%=strErrMsg%></p>
<%dbOP.cleanUP();
return;}
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	 <tr>
      <td height="25" colspan="7" align="center">
	  		<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          	<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <br>
        <font style="font-size:11px; font-weight:bold"><u> :: Bank Deposit Listing :: </u></font>
	   </td>
    </tr>
    <tr>
      <td height="25" colspan="7" align="right" style="font-size:9px;">Date and time printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp; </td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){
%>
<%if(bolShowSummary){%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">    
    <tr>
      <td class="thinborder" width="5%" height="22">SL #</td>
      <td class="thinborder" width="33%">Bank Code : Branch </td>
      <td class="thinborder" width="12%" align="center">Amount</td>
    </tr>
<%
int j = 0;
for(int i = 0; i < vRetResult.size(); i += 3){	%>
    <tr>
      <td class="thinborder" height="22"><%=++j%>.</td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i)%> : <%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" align="right"><%=(String)vRetResult.elementAt(i + 2)%></td>
    </tr>
<%}%>
    <tr>
      <td class="thinborder" height="22" colspan="3" align="right"><b>Total : <%=strTotalAmount%></b></td>
    </tr>
  </table>

<%}else{%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">    
    <tr>
      <td class="thinborder" width="5%" height="22">SL #</td>
      <td class="thinborder" width="17%">OR Number  </td>
      <!--<td class="thinborder" width="24%">Payee Name </td>-->
      <td class="thinborder" width="33%">Bank Code : Branch </td>
      <td class="thinborder" width="12%" align="center">Amount</td>
    </tr>
<%boolean bolNewPrint = false;
int j = 0;
for(int i = 0; i < vRetResult.size(); ++j){
	bolNewPrint = true;
	vRetResult.removeElementAt(i);
	vRetResult.removeElementAt(i);
for(; i < vRetResult.size(); i += 4){
	if(vRetResult.elementAt(i) == null)
		break;
	%>
    <tr>
      <td class="thinborder"><%if(bolNewPrint){%><%=j + 1%>.<%}else{%>&nbsp;<%}%></td>
      <td class="thinborder" height="22">
	  	<%if(bolNewPrint){%>
			<%=(String)vRetResult.remove(i)%><br><font color="red"> Total Amount : <%=(String)vRetResult.remove(i)%></font>
	  <%}else{%>&nbsp;<%}%></td>
      <!--<td class="thinborder"><%//=(String)vRetResult.elementAt(i + 2)%></td>-->
      <td class="thinborder"><%=(String)vRetResult.elementAt(i)%> : <%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" align="right"><%=(String)vRetResult.elementAt(i + 2)%></td>
    </tr>
<%bolNewPrint = false;}
}%>
    <tr>
      <td class="thinborder" height="22" colspan="4" align="right"><b>Total : <%=strTotalAmount%></b></td>
    </tr>
  </table>
  <%
	}//vRetResult is not null
}//if !bolShowSummary
%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
