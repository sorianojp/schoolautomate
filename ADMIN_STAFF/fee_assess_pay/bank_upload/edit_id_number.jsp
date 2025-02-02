<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Transmittal Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function SaveIDNumber(){
		document.form_.save_id_number.value = "1";
		document.form_.submit();
	}
	
	function checkAllSave() {
		var maxDisp = document.form_.max_count.value;
		var bolIsSelAll = document.form_.selAllSave.checked;
		for(var i =0; i< maxDisp; ++i)
			eval('document.form_.change_'+i+'.checked='+bolIsSelAll);
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
	
	String[] astrSemester = {"Summer", "1st Sem", "2nd Sem", "3rd Sem"};
	
	BankPosting bp = new BankPosting();
	if(WI.fillTextValue("save_id_number").length() > 0){
		if(!bp.editUnexistingIDNumbers(dbOP, request))
			strErrMsg = bp.getErrMsg();
		else
			strErrMsg = "Operation successful.";
	}
	
	Vector vRetResult = bp.getUnexistingPaymentPosting(dbOP, request);
	if(vRetResult == null && WI.fillTextValue("save_id_number").length() == 0)
		strErrMsg = bp.getErrMsg();
%>
<body bgcolor="#D2AE72">
<form action="edit_id_number.jsp" method="post" name="form_">
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr bgcolor="#A49A6A" >
			<td height="25" colspan="2">
				<div align="center"><font color="#FFFFFF"><strong>:::: ID NUMBER EDITING PAGE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right">
				<a href="javascript:SaveIDNumber();"><img src="../../../images/edit.gif" border="0"></a>
				<font size="1">Click to edit selected ID numbers.</font>&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" width="8%" align="center" class="thinborder"><strong>Date Paid</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>SY/Term</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Reference No.</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Amount</strong></td>
			<td width="21%" align="center" class="thinborder"><strong>ID Number</strong></td>
			<td width="21%" align="center" class="thinborder"><strong>New ID Number</strong></td>
			<td width="5%"  align="center" class="thinborder"><strong>Select<br>All<br></strong>
				<input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();"></td>
		</tr>
	<%	int iCount = 0;
		for(int i = 0; i < vRetResult.size(); i += 8, iCount++){%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></td>
			<td class="thinborder">&nbsp;<%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+4))]%> 
				<%=(String)vRetResult.elementAt(i+2)%>-<%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
			<td align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+1), true)%>&nbsp;</td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
			<td align="center" class="thinborder">
				<input name="id_number_<%=iCount%>" type="text" class="textbox" value="<%=WI.fillTextValue("id_number_"+iCount)%>"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td align="center" class="thinborder">
				<input type="checkbox" name="change_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1"></td>
		</tr>
	<%}%>
		<input type="hidden" name="max_count" value="<%=iCount%>">
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="15"></td>
		</tr>
		<tr>
			<td height="25" align="center">
				<a href="javascript:SaveIDNumber();"><img src="../../../images/edit.gif" border="0"></a>
				<font size="1">Click to edit selected ID numbers.</font></td>
		</tr>
	</table>
<%}%>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A">
			<td height="25">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="save_id_number">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>