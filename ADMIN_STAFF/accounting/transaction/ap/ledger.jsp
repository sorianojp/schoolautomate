<%@ page language="java" import="utility.*,Accounting.AccountPayable,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
	
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

//end of authenticaion code.

	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Admin/staff-Accounting-Transaction-A/P - View Ledger","ledger.jsp");
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
	AccountPayable AP = new AccountPayable();
	Vector vRetResult = null;

	vRetResult = AP.viewLedger(dbOP, request);	
	if(vRetResult == null)
		strErrMsg = AP.getErrMsg();
	
boolean bolIsCompany = !WI.fillTextValue("payee_type").equals("0");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
</script>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="./ledger.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" bgcolor="#A49A6A"><font color="#FFFFFF">
	  <strong>:::: SUPPLIER LEDGER PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td style="font-size:14px; font-weight:bold; color:#FF0000"><%=WI.getStrValue(strErrMsg,"Message : ","","")%></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td>
<%
if(bolIsCompany) {
	strTemp = " checked";
	strErrMsg = "";
}else{
	strTemp = "";
	strErrMsg = " checked";
}
if(bolIsCompany) {%>
	    <input name="payee_type" type="radio" value="1"<%=strTemp%> onClick="document.form_.page_action.value='';document.form_.ap_info.value='';document.form_.submit();"> Supplier - Company &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<%}else{%>
        <input name="payee_type" type="radio" value="0"<%=strErrMsg%> onClick="document.form_.page_action.value='';document.form_.ap_info.value='';document.form_.submit();"> Supplier - Individual	
<%}%> 
	  
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><u>Supplier Code (Name) - <%if(bolIsCompany){%>Company<%}else{%>Individual<%}%></u></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>
	  <select name="ap_info" onChange="document.form_.submit();" style="font-size:10px">
		<option value="">Select a Payee</option>
<%
strTemp = " from AC_AP_BASIC_INFO where is_valid = 1";
if(bolIsCompany)
	strTemp += " and supplier_index is not null";
else	
	strTemp += " and supplier_index is null";

strTemp += " order by PAYEE_CODE";
%>
<%=dbOP.loadCombo("AP_INFO_INDEX","PAYEE_CODE+' ('+PAYEE_NAME+')'",strTemp, WI.fillTextValue("ap_info"), false)%>   
	  </select>
	  </td>
    </tr>
  </table>
<%
boolean bolNegative = false;
if(vRetResult != null && vRetResult.size() > 0) {
strTemp = (String)vRetResult.remove(0);
if(strTemp.startsWith("-")) {
	bolNegative = true;
	strTemp = strTemp.substring(1);
}
else
	bolNegative = false;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="7" align="center" bgcolor="#B4C5D6" class="thinborder"><strong><font color="#000000">:: Complete Ledger :: </font></strong></td>
    </tr>
    <tr>
      <td width="15%" class="thinborder" height="25"><strong>Transaction Date </strong></td>
      <!--<td width="15%" class="thinborder" style="font-weight:bold">Reference</td>-->
      <td width="40%" class="thinborder"><strong>Transaction Note </strong></td>
      <td width="10%" class="thinborder" style="font-weight:bold">Encoded By </td>
      <td width="10%" class="thinborder"><strong>Debit</strong></td>
      <td width="10%" class="thinborder"><strong>Credit</strong></td>
      <td width="15%" class="thinborder"><strong>Balance</strong></td>
    </tr>
    <tr>
      <td height="25" colspan="5" class="thinborder" align="right">Balance Forwarded &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td class="thinborder" align="right"><%if(bolNegative){%>(<%}%><%=strTemp%><%if(bolNegative){%>)<%}%></td>
    </tr>

<%
for(int i = 0; i < vRetResult.size(); i += 6){
strTemp = (String)vRetResult.elementAt(i + 3);
if(strTemp.startsWith("-")) {
	bolNegative = true;
	strTemp = strTemp.substring(1);
}
else
	bolNegative = false;
%>
    <tr>
      <td class="thinborder" height="25"><%=vRetResult.elementAt(i)%></td>
      <!--<td class="thinborder"><%//=vRetResult.elementAt(i + 6)%></td>-->
      <td class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder" align="right"><%if(vRetResult.elementAt(i + 2).equals("1")){%><%=vRetResult.elementAt(i + 1)%><%}else{%>&nbsp;<%}%></td>
      <td class="thinborder" align="right"><%if(vRetResult.elementAt(i + 2).equals("0")){%><%=vRetResult.elementAt(i + 1)%><%}else{%>&nbsp;<%}%></td>
      <td class="thinborder" align="right"><%if(bolNegative){%>(<%}%><%=strTemp%><%if(bolNegative){%>)<%}%></td>
    </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="17%" height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>