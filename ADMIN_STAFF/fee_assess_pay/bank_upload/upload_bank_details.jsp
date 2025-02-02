<%@ page language="java" import="utility.*,java.util.Vector" %>
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
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
	
	function FocusField(){
		document.form_.sy_from.focus();		
	}
	
	function UpdateBankList(){
		var pgLoc = "./update_bank_list.jsp?opner_form_name=form_";
		var win=window.open(pgLoc,"UpdateBankList",'width=800,height=450,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	function DisplaySYTo() {
		var strSYFrom = document.form_.sy_from.value;
		if(strSYFrom.length == 4)
			document.form_.sy_to.value = eval(strSYFrom) + 1;
		if(strSYFrom.length < 4)
			document.form_.sy_to.value = "";
	}
	
	function UploadFile(){
		var vSYFrom = document.form_.sy_from.value;
		var vSYTo = document.form_.sy_to.value;
		var vSemester = document.form_.semester.value;
		var vBankCode = document.form_.bank_code.value;
		var vFileExt = document.form_.file_ext.value;
		var vBankIndex = document.form_.bank_code.value;
		var vPmtSchIndex = document.form_.pmt_sch_index.value;
		var vDateReceipt = document.form_.date_receipt.value;
	
		if(vSYFrom.length == 0 || vSYTo.length == 0){
			alert("Please provide school year information.");
			return;
		}
		
		if(vSemester.length == 0){
			alert("Please provide school term information.");
			return;
		}
		
		if(vBankCode.length == 0){
			alert("Please select bank.");
			return;
		}
		else{
			vBankIndex = vBankCode;
			vBankCode = document.form_.bank_code[document.form_.bank_code.selectedIndex].text;
		}
		
		if(vFileExt.length == 0){
			alert("Please choose file extension.");
			return;
		}
		
		if(vDateReceipt.length == 0){
			alert("Please provide payment date.");
			return;
		}
		
		var sT = "./upload_file.jsp?opner_form_name=form_&first_load=1&sy_from="+vSYFrom+"&semester="+vSemester+"&bank_code="+vBankCode+"&file_ext="+vFileExt+"&bank_index="+vBankIndex+"&pmt_sch_index="+vPmtSchIndex+"&date_receipt="+vDateReceipt;
		var win=window.open(sT,"UploadFile",'dependent=yes,width=700,height=200,top=200,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
	
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};
%>
<body bgcolor="#D2AE72" onLoad="FocusField();">
<form action="upload_bank_details.jsp" method="post" name="form_">
	<table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr bgcolor="#A49A6A" >
			<td height="25" colspan="3">
				<div align="center"><font color="#FFFFFF"><strong>:::: UPLOAD MANAGEMENT PAGE ::::</strong></font></div></td>
		</tr>
	</table>
	
	<table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td colspan="2"><%=WI.getStrValue(strErrMsg)%>&nbsp;</td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="17%">School Year: </td>
			<td width="80%">
        		<input name="sy_from" type="text" size="4" maxlength="4" class="textbox"
					value="<%=WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"))%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
					onKeyUp='DisplaySYTo("gsheet","sy_from","sy_to")'>
				-
				<input name="sy_to" type="text" size="4" maxlength="4" class="textbox"
					value="<%=WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"))%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
					readonly="yes"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Term:</td>
			<td>
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));
				%>
				<select name="semester">
				<%if(strTemp.equals("0")){%>
					<option value="0" selected>Summer</option>
				<%}else{%>
					<option value="0">Summer</option>			
				
          		<%}if(strTemp.equals("1")){%>
					<option value="1" selected>1st Sem</option>
				<%}else{%>
					<option value="1">1st Sem</option>
					
				<%}if(strTemp.equals("2")){%>
					<option value="2" selected>2nd Sem</option>
				<%}else{%>
					<option value="2">2nd Sem</option>
				<%}%>
       		 	</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Bank Code: </td>
			<td>
				<select name="bank_code">
					<option value="">Select Bank</option>
					<%=dbOP.loadCombo("bank_index","bank_name, bank_code"," from fa_upload_bank_list order by bank_name", 
						WI.fillTextValue("bank_code"), false)%>
          		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>File Extension: </td>
			<td>
				<%
					strTemp = WI.fillTextValue("file_ext");
				%>
				<select name="file_ext">
					<option value="">Select File Extension</option>
				<%if(strTemp.equals("1")){%>
					<option value="1" selected>.txt</option>
				<%}else{%>
					<option value="1">.txt</option>
				
				<%}if(strTemp.equals("2")){%>
					<option value="2" selected>.xls</option>
				<%}else{%>
					<option value="2">.xls</option>
				
				<%}if(strTemp.equals("3")){%>
					<option value="3" selected>.csv</option>
				<%}else{%>
					<option value="3">.csv</option>
				<%}%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Payment For:</td>
		    <td>
				<select name="pmt_sch_index">
					<option value="0">Downpayment</option>
					<%=dbOP.loadCombo("pmt_sch_index","exam_name"," from fa_pmt_schedule where is_valid = 1 and is_del = 0 order by exam_period_order", 
						WI.fillTextValue("pmt_sch_index"), false)%>
		  		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Payment Date: </td>
			<td>
				<%
					strTemp = WI.fillTextValue("date_receipt");
					if(strTemp.length() == 0)
						strTemp = WI.getTodaysDate(1);
				%>
				<input name="date_receipt" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.date_receipt');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
					<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<a href="javascript:UploadFile();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">click this to upload file</font></td>
		</tr>
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
    </table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr bgcolor="#A49A6A">
			<td height="25">&nbsp;</td>
		</tr>
	</table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
