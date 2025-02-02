<%@ page language="java" import="utility.*,Accounting.COASetting,java.util.Vector" %>
<%
	WebInterface WI  = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COA Country Code Setup</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
	
	function CancelOperation(){
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.info_index.value = "";
		document.form_.submit();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this account classification?'))
				return;
		}
		
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	
	String strTemp   = null;
	String strErrMsg = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","coa_setup_acct_classification.jsp");
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
	
	int iMaxValue = 0;
	Vector vSegmentSetup = null;
	Vector vRetResult = null;
	Vector vEditInfo = null;
	
	String strACDigits = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	COASetting coa = new COASetting();
	
	strTemp = WI.fillTextValue("page_action");
	vSegmentSetup = coa.operateOnSegmentSetup(dbOP, request, 4);
	if(vSegmentSetup == null)
		strErrMsg = coa.getErrMsg();
	else{
		strACDigits = (String)vSegmentSetup.elementAt(1);		
		if(strACDigits.equals("1"))
			iMaxValue = 9;
		else
			iMaxValue = 99;
		
		
		if(strTemp.length() > 0){
			if(coa.operateOnCOACF(dbOP, request, Integer.parseInt(strTemp)) == null)
				strErrMsg = coa.getErrMsg();
			else{
				if(strTemp.equals("0"))
					strErrMsg = "Acct classification information successfully removed.";
				if(strTemp.equals("1"))
					strErrMsg = "Acct classification information successfully recorded.";
				if(strTemp.equals("2"))
					strErrMsg = "Acct classification information successfully edited.";
				
				strPrepareToEdit = "0";
			}
		}
		
		vRetResult = coa.operateOnCOACF(dbOP, request, 4);
		
		if(strPrepareToEdit.equals("1")){
			vEditInfo = coa.operateOnCOACF(dbOP, request, 3);
			if(vEditInfo == null)
				strErrMsg = coa.getErrMsg();
		}
	}
%>
<body bgcolor="#D2AE72" onLoad="document.form_.cf_name.focus();">
<form action="./coa_setup_acct_classification.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF">
			  	<strong>:::: ACCOUNT CLASSIFICATION SETUP ::::</strong></font></div></td>
    	</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Classification Name: </td>
			<td width="77%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("cf_name");
				%>
				<input name="cf_name" type="text" size="32" maxlength="32" class="textbox" value="<%=strTemp%>" 
	  				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Classification Order: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(0);
					else
						strTemp = WI.fillTextValue("coa_cf");
				%>				
				<select name="coa_cf">
				<% 
				int iDefault = Integer.parseInt(WI.getStrValue(strTemp,"1"));
				for(int i = 1; i <= iMaxValue ; i++) {
					if ( i == iDefault) {%>
						<option selected value="<%=i%>"><%=i%></option>
					<%}else{%>
						<option value="<%=i%>"><%=i%></option>
					<%}
				}%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Account Effect: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.getStrValue(WI.fillTextValue("is_debit_type"), "1");
					
					if(strTemp.equals("0")){
						strTemp = "";
						strErrMsg = " checked";
					}
					else{
						strTemp = " checked";
						strErrMsg = "";
					}
				%>
				<input name="is_debit_type" type="radio" value="1"<%=strTemp%>>Debit
				<input name="is_debit_type" type="radio" value="0"<%=strErrMsg%>>Credit </td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(4);
					else
						strTemp = WI.getStrValue(WI.fillTextValue("is_balance_forwarded"), "0");					
					
					if(strTemp.equals("1"))
						strTemp = " checked";				
					else
						strTemp = "";
				%>
				<input name="is_balance_forwarded" type="checkbox" value="1"<%=strTemp%>> Balance forwarded to next year</td>
		</tr>
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
		    <td height="25">
			<%if(iAccessLevel > 1){
				if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../../images/save.gif" border="0"></a>
				<%}else {
					if(vEditInfo!=null){%>
					<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../../images/edit.gif" border="0"></a>
					<%}
				}%>
				<a href="javascript:CancelOperation();"><img src="../../../../images/cancel.gif" border="0"></a>
			<%}else{%>
				Not authorized to add/modify coa account classification.
			<%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
  	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="20" colspan="5" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: ACCOUNT TYPE IN RECORD :::</strong></div></td>
	 	</tr>
		<tr>
			<td height="25" width="40%" align="center" class="thinborder"><strong>Classification Name</strong></td>
			<td width="13%" align="center" class="thinborder"><strong>Code</strong></td>
			<td width="13%" align="center" class="thinborder"><strong>Type</strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Balance Forwarded</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 6){%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
			<td class="thinborder">
				<%
					if(((String)vRetResult.elementAt(i+3)).equals("0"))
						strTemp = "Credit";
					else
						strTemp = "Debit";
				%>
				<%=strTemp%></td>
			<td class="thinborder">
				<%
					if(((String)vRetResult.elementAt(i+4)).equals("1"))
						strTemp = "Yes";
					else
						strTemp = "No";
				%>
				<%=strTemp%></td>
			<td align="center" class="thinborder">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../../images/edit.gif" border="0"></a>
				<%if(iAccessLevel == 2){%>
					<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../../images/delete.gif" border="0"></a>
				<%}
			}else{%>
				Not authorized.
			<%}%></td>
		</tr>
	<%}%>
	</table>
<%}%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A"> 
			<td height="25">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>