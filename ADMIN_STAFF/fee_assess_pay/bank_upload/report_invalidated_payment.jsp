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

	
	function SearchTemp(){
		document.form_.search_temp.value = "1";
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.search_temp.value = "";
		document.form_.submit();
	}
	
	function PrintPage(strPayment){
		var strTemp = "";
		if(document.form_.show_bank.checked)
			strTemp = "1";
		var pgLoc = "./report_invalidated_payment_print.jsp?show_bank="+strTemp+
			"&payment_type="+strPayment+
			"&sy_from="+document.form_.sy_from.value+
			"&offering_sem="+document.form_.offering_sem.value+
			"&date_type="+document.form_.date_type.value+
			"&date_fr="+document.form_.date_fr.value+
			"&date_to="+document.form_.date_to.value+
			"&bank_code="+document.form_.bank_code.value+
			"&stud_id="+document.form_.stud_id.value;
		var win=window.open(pgLoc,"PrintPage",'width=900,height=700,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	
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
	Vector vBankList = new Vector();
	if(WI.fillTextValue("search_temp").length() > 0){
		vRetResult = bp.getBankPostListing(dbOP, request);
		if(vRetResult == null)
			strErrMsg = bp.getErrMsg();
		else{
		vBankList = (Vector)vRetResult.remove(0);
		}
	}
String strPaymentType = "";
%>
<body bgcolor="#D2AE72">
<form action="report_invalidated_payment.jsp" method="post" name="form_">
	<table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr bgcolor="#A49A6A" >
			<td height="25" colspan="3">
				<div align="center"><font color="#FFFFFF"><strong>:::: PAYMENT INVALIDATION PAGE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<%
			strTemp = WI.fillTextValue("show_bank");
			if(strTemp.equals("1")){
				strErrMsg = "checked";				
			}else{				
				strErrMsg = "";
			}
			%>
			<td colspan="2"><input type="checkbox" <%=strErrMsg%> name="show_bank" value="1" onClick="ReloadPage();">
			Include Summary </td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Payment Type: </td>
		    <td>
				<%
					strTemp = WI.fillTextValue("payment_type");
					if(strTemp.equals("1") || strTemp.length() == 0)
						strErrMsg = "checked";
					else						
						strErrMsg = "";
					
				%>
				<input type="radio" name="payment_type" value="1" <%=strErrMsg%> onChange="ReloadPage();">Permanent
				<%
					if(strTemp.equals("2"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
				%>
				<input type="radio" name="payment_type" value="2" <%=strErrMsg%> onChange="ReloadPage();">Temporary</td>
				
				<%strPaymentType = strTemp;%>
		</tr>
		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">SY/Term:</td>
			
			<td width="80%" colspan="3">
				
				<%
					strTemp = WI.fillTextValue("sy_from");
				%>
				<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
					onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
				-
				<%
					strTemp = WI.fillTextValue("sy_to");
				%>
				<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
					readonly="yes">
					
				<%
				strTemp = WI.fillTextValue("offering_sem");
				%>
				
				<select name="offering_sem">
				<%if(strTemp.equals("1")){%>
					<option value="1" selected>1st Sem</option>
				<%}else{%>
					<option value="1">1st Sem</option>
				
				<%}if(strTemp.equals("2")){%>
					<option value="2" selected>2nd Sem</option>
				<%}else{%>
					<option value="2">2nd Sem</option>
					
				<%}if(strTemp.equals("3")){%>
					<option value="3" selected>3rd Sem</option>
				<%}else{%>
					<option value="3">3rd Sem</option>
				
				<%}if(strTemp.equals("0")){%>
					<option value="0" selected>Summer</option>
				<%}else{%>
					<option value="0">Summer</option>
				<%}%>
				</select>
					
					</td>
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
			<td height="25">&nbsp;</td>
			<td>Bank Code:</td>
			<td>
				<select name="bank_code">
					<option value="">Select Bank</option>
					<%=dbOP.loadCombo("bank_index","bank_name, bank_code"," from fa_bank_list  where is_used_bank_post = 1 order by bank_name", 
						WI.fillTextValue("bank_code"), false)%>
          		</select>
			</td>
		</tr>
		
		<tr>
			<td height="25">&nbsp;</td>
			<td>Student ID: </td>
			<td><input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
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
		<tr><td align="right"><a href="javascript:PrintPage('<%=strPaymentType%>');"><img src="../../../images/print.gif" border="0"></a></td></tr>
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
			<td align="center" class="thinborder" width="10%"><font size="1"><strong>Created By</strong></font></td>
		</tr>
	<%	
		for(int i = 0; i < vRetResult.size(); i += 15){%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%>-<%=((String)vRetResult.elementAt(i+7)).substring(2)%>/
				<%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+8))]%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+11)%></td>
		    <td class="thinborder" align="right"><%=(String)vRetResult.elementAt(i+5)%>&nbsp;</td>
		    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+14))%></td>
		    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+10))%></td>
		</tr>
	<%}%>
	</table>	
	
	<%if(vBankList != null && vBankList.size() > 0 && WI.fillTextValue("show_bank").equals("1")){%>	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
		  <td height="25" align="center"><strong>BANK PAYMENT SUMMARY</strong></td>
		</tr>
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder"	>		
		<tr>
			<td class="thinborder" height="25"><strong>Bank Code</strong></td>
			<td class="thinborder" height="25"><strong>Amount</strong></td>
		</tr>
		
		<%for(int i = 0; i < vBankList.size(); i+=4){
			strTemp = (String)vBankList.elementAt(i+2);
			if(strTemp == null)
				strTemp = "Not Found";
		%>
		<tr>
			<td class="thinborder" height="25"><%=strTemp%></td>
			<td class="thinborder" height="25"><%=(String)vBankList.elementAt(i+3)%></td>
		</tr>
		<%}%>
	</table>
	<%}%>
<%}%>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A">
			<td height="25">&nbsp;</td>
		</tr>
	</table>
	<input type="hidden" name="search_temp">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>