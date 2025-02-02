<%@ page language="java" import="utility.*, Accounting.SalesPayment, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Check Banks</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	//called for add or edit and delete.
	function CancelOperation(){
		document.form_.donot_call_close_wnd.value = "1";
		location = "./check_banks.jsp";
	}
	
	function ReloadParentWnd() {
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
	
		if(document.form_.close_wnd_called.value == "0") 
			window.opener.ReloadPage();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this bank information?'))
				return;
		}
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function FocusField(){
		document.form_.bank_code.focus();
	}

</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
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
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Customer-Sales","check_banks.jsp");
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
	Vector vEditInfo  = null; 
	Vector vRetResult = null;

	SalesPayment payment  = new SalesPayment();
	strTemp = WI.fillTextValue("page_action");
	
	if(strTemp.length() > 0) {
		if(payment.operateOnCheckBanks(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = payment.getErrMsg();
		else {
			if(strTemp.equals("0"))
				strErrMsg = "Bank information successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Bank information successfully added.";
			if(strTemp.equals("2"))
				strErrMsg = "Bank information successfully edited.";
			
			strPrepareToEdit = "0";
		}
	}

	vRetResult = payment.operateOnCheckBanks(dbOP, request,4);
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = payment.operateOnCheckBanks(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = payment.getErrMsg();
	}
%>
<body topmargin="0" bgcolor="#D2AE72" onUnload="ReloadParentWnd();" onLoad="FocusField();">
<form name="form_" method="post" action="check_banks.jsp">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="5" bgcolor="#A49A6A" align="center">
				<div align="center"><font color="#FFFFFF"><strong>::: BANK MANAGEMENT PAGE :::</strong></font></div></td>
		</tr>
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Bank Code: </td>
			<td>
				<%  
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("bank_code");
				%>
				<input type="text" name="bank_code" value="<%=strTemp%>" class="textbox" size="36" maxlength="128"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="17%">Bank Name: </td>
			<td width="80%">
				<%  
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(2);
					else
						strTemp = WI.fillTextValue("bank_name");
				%>
				<textarea name="bank_name" style="font-size:12px" cols="40" rows="3" class="textbox"
					onfocus="CharTicker('form_','128','bank_name','count_');style.backgroundColor='#D3EBFF'" 
				  	onBlur ="CharTicker('form_','128','bank_name','count_');style.backgroundColor='white'" 
				  	onkeyup="CharTicker('form_','128','bank_name','count_');"><%=strTemp%></textarea>
				&nbsp;&nbsp;&nbsp;Allowed Characters 
				<input type="text" name="count_" class="textbox_noborder" readonly="yes" tabindex="-1" size="4"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Branch:</td>
			<td>
				<%  
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.fillTextValue("branch");
				%>
				<input type="text" name="branch" value="<%=strTemp%>" class="textbox" size="24" maxlength="24"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Address:</td>
			<td>
			<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(4);
			else
				strTemp = WI.getStrValue(WI.fillTextValue("address"),"");
			%>
				<textarea name="address" style="font-size:12px" cols="65" rows="4" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
		</tr>
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td height="25">
			<%if(iAccessLevel > 1){
				if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
				<%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
							<img src="../../../images/edit.gif" border="0"></a>
					<%}
				}%>
				
				<a href="javascript:CancelOperation();"><img src="../../../images/cancel.gif" border="0"></a>
			<%}else{%>
				Not authorized to save bank information.
			<%}%></td>
		</tr>
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="5" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>LIST OF BANKS</strong></div></td>
		</tr>
		<tr style="font-weight:bold">
			<td height="25" class="thinborder" width="20%" align="center">Bank Code </td>
			<td width="20%" class="thinborder" align="center">Bank Name</td>
			<td width="20%" class="thinborder" align="center">Branch</td>
			<td width="20%" class="thinborder" align="center">Address</td>
			<td width="20%" align="center" class="thinborder">Operations</td>
		</tr>
	<%
		int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=5, iCount++){
	%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
			<td align="center" class="thinborder">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/edit.gif" border="0"></a>
				<%if(iAccessLevel == 2){%>
				<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/delete.gif" border="0"></a>
				<%}
			}else{%>
				No edit/delete privilege.
			<%}%>
		</tr>
	<%}%>
	</table>
<%}%>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>">  	
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>