<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script src="../../../jscript/date-picker.js"></script>
<script src="../../../jscript/common.js"></script>

<script language="JavaScript">

	function PageAction(strAction, strInfoIndex){
		if(strAction == '0'){
			if(!confirm("Do you want to delete this entry?"))
				return;
			else{
				
				var strReason = prompt("Reason to Delete","");
				if(strReason.length == 0){
					alert("Please provide reason to delete");
					return;
				}
				
				document.form_.delete_reason.value = strReason;
			}
		}
		
		if(strInfoIndex.length  > 0)
			document.form_.info_index.value = strInfoIndex;
			
		document.form_.page_action.value= strAction;
		document.form_.submit();
	}


	function PrepareToEdit(strInfoIndex){
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.page_action.value = "";
		document.form_.submit();
	}
	
	function CancelOperation(){
		document.form_.prepareToEdit.value = "0";
		document.form_.info_index.value = "";
		document.form_.page_action.value = "";
		this.clearFields();
		document.form_.submit();
	}
	
	function FocusID(){
		document.form_.check_no.focus();
	}
	
	function clearFields(){
		document.form_.check_no.value = "";
		document.form_.check_amt.value = "";
		document.form_.remarks.value = "";
		document.form_.bank_index.value = "";
	}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,enrollment.FAPayment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT","check_encashment.jsp");
		
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"check_encashment.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

	if(!comUtil.isTellerAllowedToCollectPmtUB(dbOP, (String)request.getSession(false).getAttribute("userIndex"), WI.getTodaysDate(), (String)request.getSession(false).getAttribute("school_code"))) {
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","<font style='font-size:24px; font-weight:bold'>Not allowed to encode check encashment information. Today's Teller report is already finalized.</font>");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}

FAPayment faPmt = new FAPayment();


	
	
String strDateEncash = WI.getStrValue(WI.fillTextValue("encash_date"), WI.getTodaysDate(1));

String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"), "0");
/**
boolean bolEdit = false
String strCheckNo = WI.fillTextValue("check_no"); //if this one has value then this is edit.
if(strCheckNo.length() > 0)
	bolEdit = true;
*/
Vector vRetResult = null;
Vector vEditInfo  = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(faPmt.operateOnCheckEncashment(dbOP, request, Integer.parseInt(strTemp), strDateEncash) == null)
		strErrMsg = faPmt.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg = "Check encashment entry successfully deleted.";
		if(strTemp.equals("1"))
			strErrMsg = "Check encashment entry successfully saved.";
		if(strTemp.equals("2"))
			strErrMsg = "Check encashment entry successfully updated.";			
		}	
	
	strPrepareToEdit = "0";	
}

vRetResult = faPmt.operateOnCheckEncashment(dbOP, request, 4, strDateEncash);
if(vRetResult == null)
	strErrMsg = faPmt.getErrMsg();

if(strPrepareToEdit.equals("1")){
	vEditInfo = faPmt.operateOnCheckEncashment(dbOP, request, 3, strDateEncash);
	if(vEditInfo == null)
		strErrMsg = faPmt.getErrMsg();
}



%>
<form action="./check_encashment.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          CHECK ENCASHMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" >&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>    
  </table>

 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">Check No</td>
		<%
		strTemp = WI.fillTextValue("check_no");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(2);				
		%>
		<td>
			<input type="text" name="check_no" value="<%=strTemp%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
		</td>
	</tr>
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">Check Amount</td>
		<%
		strTemp = WI.fillTextValue("check_amt");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(1);				
		%>
		<td>
			<input type="text" name="check_amt" value="<%=strTemp%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			 onKeyUp="AllowOnlyFloat('form_','check_amt');"
			onBlur="AllowOnlyFloat('form_','check_amt');style.backgroundColor='white'" >
		</td>
	</tr>
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">Date of Encashment</td>
		<td>
			<font size="1">
<%

strTemp = WI.fillTextValue("encash_date");

if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);			
		
if(strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);
	

%>
        <input name="encash_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" tabindex="-1">
        <!--
		<a href="javascript:show_calendar('form_.encash_date');" title="Click to select date" 
		  onMouseOver="window.status='Select date';return true;" 
		  onMouseOut="window.status='';return true;" tabindex="-1"><img src="../../../images/calendar_new.gif" border="0"></a>
        -->
		</font>
		</td>
	</tr>
	
	
	<tr>
		<td>&nbsp;</td>
		<td>Remarks</td>
		
		<%
		strTemp = WI.fillTextValue("remarks");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(4);				
		%>
		<td>
			<textarea rows="2" cols="60" name="remarks"><%=WI.getStrValue(strTemp)%></textarea>
			<font size="1">(Optional)</font>
		</td>
	</tr>
	
	<%if(strPrepareToEdit.equals("1")){%>
	<tr>
		<td>&nbsp;</td>
		<td>Reason to Modify</td>
		
		<%
		strTemp = WI.fillTextValue("mod_reason");
		//if(vEditInfo != null && vEditInfo.size() > 0)
		//	strTemp = (String)vEditInfo.elementAt(10);				
		%>
		<td>
			<textarea rows="2" cols="60" name="mod_reason"><%=WI.getStrValue(strTemp)%></textarea>			
		</td>
	</tr>
	<%}%>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Bank Information</td>
		<%
		strTemp = WI.fillTextValue("bank_index");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(12);				
		%>
		<td>
			<select name="bank_index" style="font-size:10px" >
          <option value=""></option>
          <%=dbOP.loadCombo("BANK_INDEX","BANK_CODE +':::'+BRANCH"," from FA_BANK_LIST  order by bank_code", strTemp, false)%>
        </select>
		</td>
	</tr>	
 </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td align="center">
		<%if(strPrepareToEdit.equals("0")){%>
		<a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0"></a>
		<font size="1">Click to save information</font>
		<%}else{%>
		
		<a href="javascript:PageAction('2','');"><img src="../../../images/edit.gif" border="0"></a>
		<font size="1">Click to update information</font>
		<%}%>
		<a href="javascript:CancelOperation();"><img src="../../../images/cancel.gif" border="0"></a>
		<font size="1">Click to cancel operation</font>
		
	</td></tr>
</table>

<%
if(vRetResult != null && vRetResult.size() > 0){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="16">&nbsp;</td></tr>
	<tr><td align="center" height="25"><strong>LIST OF ENCODED CHECK ENCASHMENT - <%=strDateEncash%></strong></td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td width="18%" height="22" class="thinborder"><div align="center"><font size="1"><strong>CHECK NO</strong></font></div></td>
		<td width="13%" height="22" class="thinborder"><div align="center"><font size="1"><strong>CHECK AMOUNT</strong></font></div></td>
		<td width="14%" height="22" class="thinborder"><div align="center"><font size="1"><strong>DATE ENCASH</strong></font></div></td>
		<td width="24%" height="22" class="thinborder"><div align="center"><font size="1"><strong>REMARKS</strong></font></div></td>
		<td width="18%" height="22" class="thinborder"><div align="center"><font size="1"><strong>BANK CODE</strong></font></div></td>
		<td width="13%" height="22" class="thinborder"><div align="center"><font size="1"><strong>OPTION</strong></font></div></td>
	</tr>
	
	<%
	
	
	for(int i = 0; i < vRetResult.size(); i+=17){%>
	<tr>
		<td class="thinborder" height="22"><%=(String)vRetResult.elementAt(i+2)%></td>
		<td class="thinborder" height="22" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+1),true)%>&nbsp; &nbsp;</td>
		<td class="thinborder" height="22"><%=(String)vRetResult.elementAt(i+3)%></td>
		<td class="thinborder" height="22"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></td>
		<td class="thinborder" height="22"><%=(String)vRetResult.elementAt(i+5)%></td>
		<td class="thinborder" height="22" align="center">
			<!--
			<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/edit.gif" border="0"></a>
			&nbsp;
			-->
			<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a>
		</td>
	</tr>	
	<%}%>
</table>
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr><td height="25" colspan="8" bgcolor="#FFFFFF">&nbsp;</td></tr>
<tr><td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>


  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action" value="">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>" >
  <input type="hidden" name="delete_reason" value="<%=WI.fillTextValue("delete_reason")%>" >
  <%
  if(strPrepareToEdit.equals("0")){
  %>
  <script>this.clearFields()</script>	
  <%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
