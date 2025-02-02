<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payment Posting</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function PrintPg(strORFrom, strORTo){
		var pgLoc = "./batch_print_or_print.jsp?or_from="+strORFrom+"&or_to="+strORTo;	
		var win=window.open(pgLoc,"PrintPg",'width=850,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function ReloadPage(){
		document.form_.batch_print_or.value = "1";
		document.form_.submit();
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
	
	BankPosting bp = new BankPosting();
	
	if(WI.fillTextValue("batch_print_or").length() > 0){
		if(!bp.verifyOR(dbOP, request))
			strErrMsg = bp.getErrMsg();
		else{
			strTemp = "./payment_posting_print.jsp?or_from="+WI.fillTextValue("or_from")+"&or_to="+WI.fillTextValue("or_to");
		
			dbOP.cleanUP();
			
			response.sendRedirect(response.encodeRedirectURL(strTemp));
		 return;
		}
	}
%>
<body bgcolor="#D2AE72">
<form action="batch_print_or.jsp" method="post" name="form_">
	<table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr bgcolor="#A49A6A" >
			<td height="25" colspan="3">
				<div align="center"><font color="#FFFFFF"><strong>:::: OR BATCH PRINTING ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>	
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">OR Range: </td>
			<td width="80%"><input name="or_from" type="text" value="<%=WI.fillTextValue("or_from")%>" class="textbox" size="32" maxlength="32"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
				-
				<input name="or_to" type="text" value="<%=WI.fillTextValue("or_to")%>" class="textbox" size="32" maxlength="32"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td><a href="javascript:ReloadPage();"><img src="../../../images/print.gif" border="0"></a>
				<font size="1">Click to batch print OR.</font></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A">
			<td height="25">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="batch_print_or">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>