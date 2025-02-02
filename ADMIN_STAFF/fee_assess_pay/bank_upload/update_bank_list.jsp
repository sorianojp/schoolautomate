<%@ page language="java" import="utility.*,basicEdu.BasicEduReports,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Upload Bank Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	//called for add or edit and delete.
	function ReloadParentWnd() {
		if(document.form_.forwarded.value.length == 0){
			if(document.form_.donot_call_close_wnd.value.length > 0)
				return;
	
			if(document.form_.close_wnd_called.value == "0") 
				window.opener.ReloadPage();
		}
	}
	
	function CancelOperation(){
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.bank_code.value = "";
		document.form_.bank_branch.value = "";
		document.form_.bank_name.value = "";
		document.form_.submit();
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
	
	//add security here.
	try
	{
		dbOP = new DBOperation();
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
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vRetResult = null;
	Vector vEditInfo = null;
	
	BasicEduReports bedReports = new BasicEduReports();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(bedReports.operateOnBankList(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = bedReports.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Bank information successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Bank information successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "Bank information successfully edited.";
			
			strPrepareToEdit = "0";
		}
	}
	
	vRetResult = bedReports.operateOnBankList(dbOP, request, 4);
	
	if(strPrepareToEdit.equals("1")){
		vEditInfo = bedReports.operateOnBankList(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = bedReports.getErrMsg();
	}
%>
<body bgcolor="#8C9AAA" onLoad="FocusField();" onUnload="ReloadParentWnd();">
<form action="update_bank_list.jsp" method="post" name="form_">
	<table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr bgcolor="#697A8F" >
			<td height="25" colspan="3">
				<div align="center"><font color="#FFFFFF"><strong>:::: BANK MANAGEMENT PAGE ::::</strong></font></div></td>
		</tr>
	</table>
	
	<table bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		    <td align="right" width="15%">
				<%if(WI.fillTextValue("forwarded").length() > 0){%>
					<a href="../../../index.htm"><img src="../../../images/go_back.gif" border="0"></a>
				<%}%>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="17%">Bank Code: </td>
			<td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("bank_code");
				%>
			<input name="bank_code" type="text" value="<%=strTemp%>" class="textbox"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					size="8" maxlength="8" ></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Bank Name: </td>
			<td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(2);
					else
						strTemp = WI.fillTextValue("bank_name");
				%>
				<input name="bank_name" type="text" value="<%=strTemp%>" class="textbox" size="32" maxlength="256"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
	  	</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Bank Branch: </td>
			<td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(3));
					else
						strTemp = WI.fillTextValue("bank_branch");
				%>
				<input name="bank_branch" type="text" value="<%=strTemp%>" class="textbox" size="32" maxlength="256"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
	  	</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="2">
				<%if(strPrepareToEdit.equals("0")){//save%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
				<%}else{//edit%>
					<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
				<%}%>
				<a href="javascript:CancelOperation();"><img src="../../../images/cancel.gif" border="0"></a></td>
		</tr>
    </table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="5" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF BANKS :::</strong></div></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder" width="5%"><strong>Count</strong></td>
		    <td align="center" class="thinborder" width="15%"><strong>Bank Code</strong></td>
		    <td align="center" class="thinborder" width="40%"><strong>Bank Name</strong></td>
		    <td align="center" class="thinborder" width="25%"><strong>Bank Branch</strong></td>
		    <td align="center" class="thinborder" width="15%"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 4, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "&nbsp;")%></td>
			<td align="center" class="thinborder">
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')">
					<img src="../../../images/edit.gif" border="0"></a>
				<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>')">
					<img src="../../../images/delete.gif" border="0"></a></td>
		</tr>
	<%}%>
	</table>
<%}%>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr bgcolor="#FFFFFF">
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#697A8F">
			<td height="25">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>">  	
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
	<input type="hidden" name="forwarded" value="<%=WI.fillTextValue("forwarded")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>