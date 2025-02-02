<%@ page language="java" import="utility.*,Accounting.COASetting,java.util.Vector" %>
<%
	WebInterface WI  = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>COA Cost Center Listing</title>

<style type="text/css">
.unadded {
	height:200px; overflow:auto; width:auto; background-color:#FFFFFF;
}
.added {
	height:200px; overflow:auto; width:auto; background-color:#FFFFFF;
}
</style>
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
	
	function checkAllSaveSubAccount() {
		var maxDisp = document.form_.unadded_count.value;
		var bolIsSelAll = document.form_.selAllSaveSubAccount.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
	function checkAllDelSubAccount() {
		var maxDisp = document.form_.added_count.value;
		var bolIsSelAll = document.form_.selAllDelSubAccount.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.delete_'+i+'.checked='+bolIsSelAll);
	}
	
	function PageAction(strAction){
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.page_action.value = strAction;
		document.form_.submit();
	}
	
	function ReloadParentWnd() {
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
	
		if(document.form_.close_wnd_called.value == "0") 
			window.opener.CancelOperation();
	}

	
</script>
<%
	DBOperation dbOP = null;
	
	String strTemp   = null;
	String strErrMsg = null;
	
	String strCostCenterIndex = WI.fillTextValue("cost_center_index");
	if(strCostCenterIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Cost center reference missing. Please close this window and click update button again from main window.</p>
		<%return;
	}
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","coa_update_sub_account_list.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-ADMINISTRATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
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
	
	Vector vUnaddedSubAccounts = null;
	Vector vAddedSubAccounts = null;
	COASetting coa = new COASetting();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(coa.operateOnSubAccountList(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = coa.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Sub-accounts successfully removed.";
			else
				strErrMsg = "Sub-accounts successfully recorded.";
		}
	}
	
	vUnaddedSubAccounts = coa.operateOnSubAccountList(dbOP, request, 4);
	vAddedSubAccounts = coa.operateOnSubAccountList(dbOP, request, 5);
	
	if(vUnaddedSubAccounts == null && vAddedSubAccounts == null)
		strErrMsg = "No header(non-postable) chart of accounts with cost center created.";
%>
<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<form action="./coa_update_sub_account_list.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF">
			  	<strong>:::: SUB-ACCOUNT LISTING ::::</strong></font></div></td>
    	</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
  	</table>

<%if(vUnaddedSubAccounts != null && vUnaddedSubAccounts.size() > 0){%>
	<div class="unadded">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right" valign="top">&nbsp;
				<%if(iAccessLevel > 1){					
					strTemp = WI.getStrValue(WI.fillTextValue("name_option"), "0");
					
					if(strTemp.equals("0")){
						strTemp = "";
						strErrMsg = " checked";
					}
					else{
						strTemp = " checked";
						strErrMsg = "";
					}
				%>
					<input name="name_option" type="radio" value="0"<%=strErrMsg%>>
					Use unit center name.
					<input name="name_option" type="radio" value="1"<%=strTemp%>>Append sub account name to cost center code.					
					<a href="javascript:PageAction('1');"><img src="../../../../images/save.gif" border="0"></a>
				<%}%></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
		<tr> 
		  	<td height="20" colspan="14" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>LIST OF UNADDED SUB-ACCOUNTS </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="10%" align="center" class="thinborder"><strong>Country</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Sub-Account Level</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Account Name</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Account Code</strong></td>			
			<td width="8%" align="center" class="thinborder"><strong>Select<br />All<br /></strong>
		<input type="checkbox" name="selAllSaveSubAccount" value="0" onClick="checkAllSaveSubAccount();"></tr>
	<%	int iCount = 1;
		for(int i = 0; i < vUnaddedSubAccounts.size(); i += 5, iCount++){%>
		<tr>
			<td height="25" class="thinborder"><%=WI.getStrValue((String)vUnaddedSubAccounts.elementAt(i+1), "N/A")%></td>
			<td class="thinborder"><%=(String)vUnaddedSubAccounts.elementAt(i+2)%></td>
			<td class="thinborder"><%=(String)vUnaddedSubAccounts.elementAt(i+3)%></td>
			<td class="thinborder"><%=(String)vUnaddedSubAccounts.elementAt(i+4)%></td>			
			<td align="center" class="thinborder">
				<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vUnaddedSubAccounts.elementAt(i)%>" tabindex="-1"></td>
		</tr>
	<%}%>
	<input type="hidden" name="unadded_count" value="<%=iCount%>">
	</table>
	</div>
<%}

if(vAddedSubAccounts != null && vAddedSubAccounts.size() > 0){%>
	<div class="added">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right">&nbsp;
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PageAction('0');"><img src="../../../../images/delete.gif" border="0"></a>
				<%}%></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
		<tr> 
		  	<td height="20" colspan="14" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>LIST OF ADDED SUB-ACCOUNTS </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="10%" align="center" class="thinborder"><strong>Country</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Sub-Account Level</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Account Name</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Account Code</strong></td>
			<td width="8%" align="center" class="thinborder"><strong>Select<br />All<br /></strong>
				<input type="checkbox" name="selAllDelSubAccount" value="0" onClick="checkAllDelSubAccount();">				
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vAddedSubAccounts.size(); i += 5, iCount++){%>
		<tr>
			<td height="25" class="thinborder"><%=WI.getStrValue((String)vAddedSubAccounts.elementAt(i+1), "N/A")%></td>
			<td class="thinborder"><%=(String)vAddedSubAccounts.elementAt(i+2)%></td>
			<td class="thinborder"><%=(String)vAddedSubAccounts.elementAt(i+3)%></td>
			<td class="thinborder"><%=(String)vAddedSubAccounts.elementAt(i+4)%></td>
			<td align="center" class="thinborder">
				<input type="checkbox" name="delete_<%=iCount%>" value="<%=(String)vAddedSubAccounts.elementAt(i)%>" tabindex="-1"></td>
		</tr>
	<%}%>
	<input type="hidden" name="added_count" value="<%=iCount%>">
	</table>
	</div>
<%}%>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A"> 
			<td height="25">&nbsp;</td>
		</tr>
	</table>

	<input type="hidden" name="cost_center_index" value="<%=strCostCenterIndex%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>">  	
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>