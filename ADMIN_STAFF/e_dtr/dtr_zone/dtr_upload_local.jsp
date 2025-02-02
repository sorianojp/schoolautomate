<%@ page language="java" import="utility.*,eDTR.StandAloneDTR,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function UploadDTRData(){
		document.form_.upload_dtr.value = "1";
		document.form_.submit();
	}
	
</script>
<body bgcolor="#D2AE72">
<form name="form_" action="./dtr_upload_local.jsp" method="post">
<%	
	DBOperation dbOP = null;
	String strErrMsg = null;
	//add security here.
	try {
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

	//I have to get information now.. 
	Vector vRetResult = null;
	StandAloneDTR standaloneDTR = new StandAloneDTR();
	if(WI.fillTextValue("upload_dtr").length() > 0) {
		vRetResult = standaloneDTR.uploadLocalDTR(dbOP, request);
		if(vRetResult == null)
			strErrMsg = standaloneDTR.getErrMsg();
		else
			strErrMsg = (String)vRetResult.remove(0);
	}
%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="2"><div align="center"><font color="#FFFFFF">
				<strong>:::: DTR Record Upload Page ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="50" width="3%">&nbsp;</td>
			<td width="97%" valign="top"><strong>
				<font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg,"MESSAGE: ","","")%></font></strong></td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
		<tr>
      		<td height="20" colspan="9" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>LIST OF UNPROCESSED RECORDS</strong></div></td>
    	</tr>
		<tr>
			<td height="25" width="16%" align="center" class="thinborder"><strong>ID Number</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Time-in Date </strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Time-out Date </strong></td>
			<td width="70%" align="center" class="thinborder"><strong>Fail Reason </strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i+=4){%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2))%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
		</tr>
	<%}%>
	</table>
<%}
	
if(WI.fillTextValue("upload_dtr").length() == 0) {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="24"><textarea name="data_to_upload" rows="35" cols="200" style="font-size:10px;"></textarea></td>
		</tr>
		<tr>
			<td height="24" align="center">
				<a href="javascript:UploadDTRData();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to upload DTR information. </font></td>
		</tr>
	</table>
<%}%>
	<input type="hidden" name="upload_dtr">
</form>
</body>
<%
dbOP.cleanUP();
%>	