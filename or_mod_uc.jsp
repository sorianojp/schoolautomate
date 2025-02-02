<%
String strAuthIndex = (String)request.getSession(false).getAttribute("authTypeIndex");

if(strAuthIndex == null || strAuthIndex.equals("4") ) {%>
	<p align="center" style="font-size:16px; font-weight:bold; color:#FF0000"> You are not allowed to access this page.
<%return;}%>



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="./css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="./css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="./jscript/date-picker.js"></script>
<script language="JavaScript" src="./jscript/common.js"></script>
<script language="JavaScript">
function ResetOR() {
	document.form_.or_series.value = '';
}
function MakeORList() {
	ResetOR();
	var iORFrom = document.form_.or_fr.value;
	var iORTo   = document.form_.or_to.value;
	
	var strORSeries = "";
	for(i = iORFrom; i <= iORTo; ++i) {
		if(strORSeries == "")
			strORSeries = iORFrom;
		else	
			strORSeries += ","+i;
	}	
	document.form_.or_series.value = strORSeries;
}
function UpdateOR() {
	document.form_.update_date_.value = '1';
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID();">
<%@ page language="java" import="utility.*,java.util.Vector" buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strPaymentFor = null;//fine-fine description or other school fee - fee name
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	boolean bolIsWNU = strSchCode.startsWith("WNU");
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-OR Change Date","or_mod_uc.jsp");
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
	String strUpdate = WI.fillTextValue("update_date_");
	String strNewDate = WI.fillTextValue("new_date");
	if(strNewDate.length() > 0) 
		strNewDate = ConversionTable.convertTOSQLDateFormat(strNewDate);
	
	if(strUpdate.length() > 0 && strNewDate.length() > 0 && WI.fillTextValue("or_series").length() > 0) {
		Vector vORSeries = CommonUtil.convertCSVToVector(WI.fillTextValue("or_series"));
		String strSQLQuery = null;
		for(int i = 0; i < vORSeries.size(); ++i) {
			if(strSQLQuery == null)
				strSQLQuery = "'"+(String)vORSeries.elementAt(i)+"'";
			else	
				strSQLQuery = strSQLQuery + ",'"+(String)vORSeries.elementAt(i)+"'";
		}
		dbOP.executeUpdateWithTrans("update fa_stud_payable set transaction_date = '"+strNewDate+
		"' from fa_stud_payable join fa_stud_payment on (fa_stud_payment.user_index = fa_stud_payable.user_index) "+
		"   and reference_index = othsch_fee_index "+
		"	and date_paid = transaction_date "+
		"	and fa_stud_payment.amount = fa_stud_payable.amount * no_of_units "+
		"where or_number in ("+strSQLQuery +")", null, null, false);
		
		strSQLQuery = "update fa_stud_payment set date_paid = '"+strNewDate+
			"',last_modify_date = '"+WI.getTodaysDate()+"', modified_by = "+(String)request.getSession(false).getAttribute("userIndex")+
			",modify_reason = date_paid  where or_number in ("+strSQLQuery +")";
		if(dbOP.executeUpdateWithTrans(strSQLQuery, (String)request.getSession(false).getAttribute("login_log_index"), "FA_STUD_PAYMENT",true) == -1)
			strErrMsg = "Error in SQLQuery. Failed to update.";
		else	
			strErrMsg = "Updated successfully.";
		//System.out.println(strSQLQuery);
	}

  %>
<form name="form_" action="./or_mod_uc.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          TEMPORARY - OR DATE MODIFICATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="12%" height="25">OR Range </td>
      <td width="84%" height="25">
	  <input name="or_fr" type="text" size="16" value="<%=WI.fillTextValue("or_fr")%>" class="textbox_bigfont"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="ResetOR();">
	   - 
	  <input name="or_to" type="text" size="16" value="<%=WI.fillTextValue("or_to")%>" class="textbox_bigfont"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="MakeORList();style.backgroundColor='white'">

	 <input type="button" name="12" value=" Proceed >>> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="MakeORList();">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top"><br>OR Series: </td>
      <td height="25"><textarea name="or_series" rows="5" cols="70" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></textarea></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>New Date </td>
      <td>
		<input name="new_date" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("new_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.new_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="./images/calendar_new.gif" border="0"></a>      
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td align="center">
	  	<input type="button" name="12" id="_update_date" value=" Update Date >> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="UpdateOR();">
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="update_date_">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>