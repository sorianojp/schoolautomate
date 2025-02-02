<%@ page language="java" import="utility.*, Accounting.billing.BillingTsuneishi, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Expense Distribution Mgmt</title>
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function PageAction(strAction, strInfoIndex) {
		document.form_.donot_call_close_wnd.value = "1";
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this detail?'))
				return;
		}
		
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function ReloadParentWnd() {
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
	
		if(document.form_.close_wnd_called.value == "0") 
			window.opener.RefreshPage();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	String strExpenseIndex = WI.fillTextValue("expense_index");
	if(strExpenseIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Expense account reference is not found. Please close this window and click update link again from main window.</p>
		<%return;
	}
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BILLING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		if(iAccessLevel == 0){
			response.sendRedirect("../../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ACCOUNTING-BILLING","expense_distribution.jsp");
	}
	catch(Exception exp){

		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vRetResult = new Vector();
	Vector vExpenseInfo = null;
	BillingTsuneishi billTsu = new BillingTsuneishi();
	
	vExpenseInfo = billTsu.getExpenseAcctInfo(dbOP, request, strExpenseIndex);
	if(vExpenseInfo == null)
		strErrMsg = billTsu.getErrMsg();
	else{
		strTemp = WI.fillTextValue("page_action");
		if(strTemp.length() > 0){
			if(billTsu.operateOnExpenseDistribution(dbOP, request, Integer.parseInt(strTemp)) == null)
				strErrMsg = billTsu.getErrMsg();
			else{
				if(strTemp.equals("0"))
					strErrMsg = "Team member information successfully removed.";
				if(strTemp.equals("1"))
					strErrMsg = "Team member information successfully recorded.";
				
				strPrepareToEdit = "0";
			}
		}
		
		vRetResult = billTsu.operateOnExpenseDistribution(dbOP, request, 4);
	}
%>
<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<form name="form_" action="./expense_distribution.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: EXPENSE DISTRIBUTION MANAGEMENT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong>Expense Account Information:</strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Expense Account  Name: </td>
			<td><%=(String)vExpenseInfo.elementAt(1)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Effectivity Date: </td>
			<td><%=(String)vExpenseInfo.elementAt(3)%> - <%=(String)vExpenseInfo.elementAt(4)%></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Team:</td>
			<td width="77%">
				<select name="team_index">
              		<option value="">Select Team</option>
              		<%=dbOP.loadCombo("team_index","team_name", " from ac_tun_team where is_valid = 1", WI.fillTextValue("team_index"),false)%>
            	</select></td>
	    </tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a> 
						<font size="1">click to add team to expense account.</font>
				        <%}else{%>
					Not authorized.
				<%}%></td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" bgcolor="#B9B292" class="thinborder" colspan="5">
				<div align="center"><strong>::: TEAM  LISTING ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="6%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="40%" align="center" class="thinborder"><strong>Team Name</strong></td>
			<td width="30%" align="center" class="thinborder"><strong>Team Code</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Member Count</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Delete</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 4, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "0")%></td>
			<td align="center" class="thinborder">
				<%if(iAccessLevel == 2){%>
					<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>')">
						<img src="../../../images/delete.gif" border="0" /></a>
				<%}else{%>
					Not authorized.
				<%}%></td>
		</tr>
	<%}%>
	</table>
<%}%>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="expense_index" value="<%=strExpenseIndex%>">
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>"> 
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
	<input type="hidden" name="reloadPage" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>