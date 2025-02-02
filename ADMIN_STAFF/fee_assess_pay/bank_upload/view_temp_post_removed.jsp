<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null) {%>
		<p style="font-size:15px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000">
			You are already logged out. Please login again.
		</p>
	<%return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Non-Posting Payments Mgmt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function checkAllSave() {
		var maxDisp = document.form_.max_count.value;
		var bolIsSelAll = document.form_.selAllSave.checked;
		for(var i =0; i< maxDisp; ++i)
			eval('document.form_.invalidate_'+i+'.checked='+bolIsSelAll);
	}
	
	function DeletePayments(){
		document.form_.search_temp.value = "1";
		document.form_.delete_payments.value = "1";
		document.form_.submit();
	}
	
	function SearchTemp(){
		document.form_.search_temp.value = "1";
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.search_temp.value = "";
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
	
	Vector vRetResult = null;
	String[] astrSemester = {"Summer", "1st Sem", "2nd Sem", "3rd Sem"};
	BankPosting bp = new BankPosting();	
	
	if(WI.fillTextValue("search_temp").length() > 0){
		vRetResult = bp.viewDeletedTempPosting(dbOP, request);
		if(vRetResult == null && WI.fillTextValue("delete_payments").length() == 0)
			strErrMsg = bp.getErrMsg();
		
	}

boolean bolDelAllowed = false;
if(strSchCode.startsWith("FATIMA"))
	bolDelAllowed = true;

%>
<body bgcolor="#D2AE72">
<form action="view_temp_post_removed.jsp" method="post" name="form_">
	<table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr bgcolor="#A49A6A" >
			<td height="25" colspan="3">
				<div align="center"><font color="#FFFFFF"><strong>:::: TEMPORARY PAYMENT INVALIDATED ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		
		<tr>
			<td height="25">&nbsp;</td>
			<td width="17%">Date Paid: </td>
		    <td width="80%">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "1");
				%>
				<select name="date_type" onChange="ReloadPage();">
                  	<%if (strTemp.equals("1")){%>
					<option value="1" selected>Specific Date</option>
                  	<%}else{%>
                  	<option value="1">Specific Date</option>
                  	<%}if (strTemp.equals("2")){%>
                  	<option value="2" selected>Date Range</option>
                  	<%}else{%>
                  	<option value="2">Date Range</option>
                  	<%}%>
                </select>
				<input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "1");
					if(strTemp.equals("2")){
				%>
				to 
				<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
					value="<%=WI.fillTextValue("date_to")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
				<%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		  	<td><a href="javascript:SearchTemp();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to search.</font></td>
	  	</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
		
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
		  	<td height="20" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT">
				<div align="center"><strong>::: SEARCH RESULT :::</strong></div></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" align="center" class="thinborder" width="13%"><strong>ID Number </strong></td>
		    <td align="center" class="thinborder" width="22%"><strong>Name</strong></td>
		    <td align="center" class="thinborder" width="15%"><strong>SY/Term</strong></td>
		    <td align="center" class="thinborder" width="12%"><strong>Date Paid</strong></td>
		    <td align="center" class="thinborder" width="10%"><strong>OR Number</strong> </td>
		    <td align="center" class="thinborder" width="13%"><strong>Amount</strong></td>
			<td align="center" class="thinborder" width="10%"><strong>Bank</strong></td>
		</tr>
	<%	int iCount = 0;
		for(int i = 0; i < vRetResult.size(); i += 16, iCount++){%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%>-<%=((String)vRetResult.elementAt(i+7)).substring(2)%>/
				<%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+8))]%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+11)%></td>
		    <td class="thinborder" align="right"><%=(String)vRetResult.elementAt(i+5)%>&nbsp;</td>
		    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+14))%></td>
		</tr>
	<%}%>
	</table>
	<input type="hidden" name="max_count" value="<%=iCount%>">
<%}%>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A">
			<td height="25">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="delete_payments">
	<input type="hidden" name="search_temp">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>