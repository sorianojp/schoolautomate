<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
	function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
			
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		document.form_.emp_id.value = strID;
		document.getElementById("coa_info").innerHTML = "";
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this record.'))
				return;
		}
		document.form_.page_action.value = strAction;
		document.form_.info_index.value  = strInfoIndex;
		document.form_.submit();
	}
</script>
<body bgcolor="#D2AE72" onLoad="document.form_.emp_id.focus();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-CASH DEPOSIT UNLOCK-Unlock Cash Deposit","cash_deposit_unlock.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Fee Assessment & Payments","CASH DEPOSIT",request.getRemoteAddr(),
															"cash_deposit_unlock.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
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
strErrMsg = null;
String strTellerIndex = WI.fillTextValue("emp_id");
String strReason      = WI.fillTextValue("note");

String strDateToUnlock = WI.fillTextValue("date_to_unlock");
if(strDateToUnlock.length() > 0 && strTellerIndex.length() > 0) {
	strTellerIndex = dbOP.mapUIDToUIndex(strTellerIndex);
	if(strTellerIndex == null)
		strErrMsg = "Employee ID not found.";
	else {
		strDateToUnlock = ConversionTable.convertTOSQLDateFormat(strDateToUnlock);
		if(strDateToUnlock == null || strDateToUnlock.length() == 0)
			strErrMsg = "Wrong date format, Please enter in mm/dd/yyyy format.";
	}
}

if(strTellerIndex != null && strTellerIndex.length() > 0 && strDateToUnlock != null && strDateToUnlock.length() > 0 && strErrMsg == null) {
	if(strReason.length() == 0) 
		strErrMsg = "Please enter reason to unlock";
}
if(strTellerIndex != null && strTellerIndex.length() > 0 && strDateToUnlock != null && strDateToUnlock.length() > 0 && strErrMsg == null) {
	String strSQLQuery    = null;
	java.sql.ResultSet rs = null;
	
	strSQLQuery = "select deposit_main_index from CASH_DEPOSIT_MAIN where is_valid = 1 and is_completed = 1 and teller_index = "+strTellerIndex+
						" and date_deposit_from = '"+strDateToUnlock+"'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery == null) {
		strErrMsg = "Record is not yet locked. Failed to Proceed.";
	}
	else {
		strTemp = null; 
		strSQLQuery = "select deposit_main_index from CASH_DEPOSIT_MAIN where is_valid = 1 and is_completed = 1 and teller_index = "+strTellerIndex+
						" and date_deposit_from >= '"+strDateToUnlock+"'";
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			if(strTemp == null)
				strTemp = rs.getString(1);
			else
				strTemp = strTemp +", "+rs.getString(1);
		}
		rs.close();
		
		if(strTemp != null) {
			strSQLQuery = "update CASH_DEPOSIT_MAIN set is_completed = 2 where deposit_main_index in ("+strTemp+")";
			if(dbOP.executeUpdateWithTrans(strSQLQuery, (String)request.getSession(false).getAttribute("login_log_index"), "CASH_DEPOSIT_MAIN", true) > 0) {
				strSQLQuery = "insert into CASH_DEPOSIT_MAIN_UNLOCKED (teller_index,deposit_main_index,DATE_DEPOSIT_FROM, BEGINING_BALANCE, CASH_COLLECTED, "+
				"CHK_COLLECTED, OTHER_NON_DEPOSITABLE, or_range_csv, CASH_REMITTED, CHECK_REMITTED, DEPOSITED_IN_BANK, DATE_DEPOSITED,ENDING_BAL, "+
				"cash_on_hand_encoded, unlocked_by, unlock_reason, create_date, create_time) "+
				"select "+strTellerIndex+",deposit_main_index,DATE_DEPOSIT_FROM, BEGINING_BALANCE, CASH_COLLECTED, CHK_COLLECTED, OTHER_NON_DEPOSITABLE, "+
				"or_range_csv, CASH_REMITTED, CHECK_REMITTED, DEPOSITED_IN_BANK, DATE_DEPOSITED,ENDING_BAL, cash_on_hand_encoded,"+
				(String)request.getSession(false).getAttribute("userIndex")+","+WI.getInsertValueForDB(strReason, true, null)+
				",'"+WI.getTodaysDate()+"',"+WI.getTodaysDate(27)+" from CASH_DEPOSIT_MAIN  where deposit_main_index in ("+strTemp+")";
				
				dbOP.executeUpdateWithTrans(strSQLQuery,null, null, false);
				
				strErrMsg = "Entries Unlocked successfully.";
			}
		}
	}				
			
 

}
%>
<form name="form_" action="./cash_deposit_unlock.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: BEGINING BALANCE SET UP PAGE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td width="3%" height="20">&nbsp;</td>
			<td width="97%" colspan="2"><font size="4" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="3%" height="20">&nbsp;</td>
			<td width="15%" style="font-size:11px;">Teller ID: </td>
		    <td width="82%">
				<input name="emp_id" type="text" class="textbox" size="20" onKeyUp="AjaxMapName();" 
					onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("emp_id")%>"
					onBlur="style.backgroundColor='white'" autocomplete="off">&nbsp;
			
			<label id="coa_info" style="position:absolute; width:350px;"></label>			</td>
		</tr>
		
		<tr>
		  <td height="20">&nbsp;</td>
		  <td style="font-size:11px;">As of Date </td>
		  <td>
		<input name="date_to_unlock" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to_unlock")%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      		<a href="javascript:show_calendar('form_.date_to_unlock');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>	  		  </td>
	  </tr>
		<tr>
		  <td height="20">&nbsp;</td>
		  <td style="font-size:11px;">Remaks</td>
		  <td>
		  <textarea name="note" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			 rows="2" cols="90" style="font-size:9px;"><%=WI.fillTextValue("note")%></textarea>		  </td>
	  </tr>
		<tr>
		  <td height="20">&nbsp;</td>
		  <td style="font-size:11px;">&nbsp;</td>
		  <td style="font-size:11px;"><a href="javascript:PageAction('1', '')"><img src="../../../../images/save.gif" border="0"></a></td>
	  </tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20">&nbsp;</td>
		</tr>
		<tr bgcolor="#B8CDD1">
			<td height="20" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>

<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>