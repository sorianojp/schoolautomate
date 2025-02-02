<%@ page language="java" import="utility.*,Accounting.CashReceiptBook,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">

function AjaxUpdate(strInfoIndex, strLoc) {
	var objCOAInput = document.getElementById("_"+strLoc);
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=219&update_ref=1&bank_ref="+strInfoIndex;
	this.processRequest(strURL);
}
	
</script>
<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-CASH DEPOSIT-set bank","set_bank.jsp");
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
															"Fee Assessment & Payments","CASH DEPOSIT",request.getRemoteAddr(),
															"set_bank.jsp");
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
	
String strSQLQuery = null;
java.sql.ResultSet rs = null;
%>
<form name="form_" action="./set_bank.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: ISSUE OR PAGE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="97%" colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr> 
		  	<td height="20" style="font-size:9px; font-weight:bold" align="center">::: LIST OF BANK :::</td>
		</tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		
		<tr style="font-weight:bold" align="center">
			<td width="5%" height="25" class="thinborder">Count</td>
			<td width="15%" class="thinborder">Bank Code</td>
			<td width="20%" class="thinborder">Bank Name</td>
			<td width="20%" class="thinborder">Bank Branch </td>
			<td width="25%" class="thinborder">Address</td>
			<td width="15%" class="thinborder">Use for Deposit</td>
		</tr>
	<%	
		strSQLQuery = "select bank_code, bank_name, branch, address,IS_USED_BANK_DEPOSIT, bank_index "+
				"from fa_bank_list where is_valid = 1 order by bank_code";
		int iCount = 1;
		rs = dbOP.executeQuery(strSQLQuery); 
		while(rs.next()){
		strTemp = "No";
		if(rs.getInt(5) == 1)
			strTemp = "Yes";
		%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount++%></td>
		    <td class="thinborder"><%=WI.getStrValue(rs.getString(1), "&nbsp;")%></td>
		    <td class="thinborder"><%=WI.getStrValue(rs.getString(2), "&nbsp;")%></td>
		    <td class="thinborder"><%=WI.getStrValue(rs.getString(3), "&nbsp;")%></td>
		    <td class="thinborder"><%=WI.getStrValue(rs.getString(4), "&nbsp;")%></td>
	        <td class="thinborder"><label id="_<%=iCount%>"><%=strTemp%></label>&nbsp;&nbsp;&nbsp;<a href="javascript:AjaxUpdate('<%=rs.getString(6)%>','<%=iCount%>')">Toggle</a></td>
		</tr>
	<%}
	rs.close();%>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
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