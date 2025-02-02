<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
function PageAction(strAction,strInfoIndex) {
	if(!confirm("Are you sure you want to delete this record?"))
		return;
	document.form_.page_action.value = strAction;
	document.form_.info_index.value  = strInfoIndex;
	
	document.form_.submit();
}
function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,Accounting.AccountPayable, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-ACCOUNTING-TRANSACTION-AP-AP PROCESSING","ap_payment_scheduled_not_paid.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	AccountPayable AP = new AccountPayable(); boolean bolErrInUpdate = false;
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(AP.operateOnAPRequestForPayment(dbOP, request, Integer.parseInt(strTemp)) == null)
			bolErrInUpdate = true;
		strErrMsg = AP.getErrMsg();
	}
	
	Vector vRetResult = AP.operateOnAPRequestForPayment(dbOP, request, 6);//show all supplier having delivery payment.. 
	if(vRetResult == null && strErrMsg == null) 
		strErrMsg = AP.getErrMsg();
%>
<form name="form_" method="post" action="ap_payment_scheduled_not_paid.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" bgcolor="#A49A6A"><font color="#FFFFFF">
	  <strong>:::: PAYMENT ALREADY SCHEDULED BUT NOT PAID ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
  <tr bgcolor="#B4C5D6"> 
    <td width="15%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Item Name </td>
    <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Amount requested for Releasing </td>
    <td width="15%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">To be Paid on or before </td>
    <td width="5%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Delete (Remove Request) </td>
    </tr>
<%
int iSupplierCount = 0; double dSupplierTotal = 0d;
for(int i = 0;i < vRetResult.size();i+=5){
if(vRetResult.elementAt(i) != null){
if(i > 0) {%>
	<script>
	document.getElementById('<%=iSupplierCount%>').innerHTML = "<%=CommonUtil.formatFloat(dSupplierTotal, true)%>";
	</script>
	<%
	++iSupplierCount;
}
dSupplierTotal = 0d;%>
    <tr bgcolor="#DDDDDD">
	    <td height="25" colspan="4" class="thinborder" style="font-size:9px; font-weight:bold">&nbsp;<%=vRetResult.elementAt(i)%>
		&nbsp;&nbsp; Total : <label id="<%=iSupplierCount%>"></label>
		</td>
    </tr>
<%}
dSupplierTotal += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i+2),",",""));
%>
  <tr> 
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
    <td class="thinborder" align="right"><%=(String)vRetResult.elementAt(i+2)%>&nbsp;</td>
    <td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i+3)%>&nbsp;</td>
    <td height="25" align="center" class="thinborder">
	<a href="javascript:PageAction('0', '<%=vRetResult.elementAt(i + 1)%>')"><img src="../../../../images/delete.gif" border="0"></a>
	</td>
    </tr>
<%}%>
	<script>
	document.getElementById('<%=iSupplierCount%>').innerHTML = "<%=CommonUtil.formatFloat(dSupplierTotal, true)%>";
	</script>

  </table>
<%}%>
<input type="hidden" name="page_action">	
<input type="hidden" name="info_index">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
