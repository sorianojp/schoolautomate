<%@ page language="java" import="utility.*,Accounting.AccountPayable,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
	
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

//end of authenticaion code.

	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Admin/staff-Accounting-Transaction-A/P Debit/Credit/Adjustment","encode_debit_credit.jsp");
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
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

	AccountPayable AP = new AccountPayable();
	Vector vEditInfo  = null; Vector vRetResult = null; boolean bolAdded = false;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(AP.operateOnStartingBalance(dbOP, request, Integer.parseInt(strTemp), "0") == null)
			strErrMsg = AP.getErrMsg();
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Ledger information successfully removed.";
			if(strTemp.compareTo("1") == 0) {
				strErrMsg = "Ledger information successfully added.";
				bolAdded = true;
			}
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Ledger information successfully edited.";

			strPrepareToEdit = "0";
		}
	}
	vRetResult = AP.operateOnStartingBalance(dbOP, request,4, "0");	
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = AP.getErrMsg();
	
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = AP.operateOnStartingBalance(dbOP, request,3, "0");
		if(vEditInfo == null)
			strErrMsg = AP.getErrMsg();
	}

boolean bolIsCompany = !WI.fillTextValue("payee_type").equals("0");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
</head>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
function CancelOperation() {
	var strPayeeType;
	<%if(bolIsCompany){%>
		strPayeeType = "?payee_type=1";
	<%}else{%>
		strPayeeType = "?payee_type=0";
	<%}%>
	if(document.form_.ap_info.selectedIndex > 0) 
		strPayeeType +="&ap_info="+document.form_.ap_info[document.form_.ap_info.selectedIndex].value;	
	location = "./encode_debit_credit.jsp"+strPayeeType;
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0' && !confirm("Do you want to remove ledger information."))
		return;
	
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();	
}
</script>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="./encode_debit_credit.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" bgcolor="#A49A6A"><font color="#FFFFFF">
	  <strong>:::: DEBIT/CREDIT/ADJUSTMENT PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td style="font-size:14px; font-weight:bold; color:#FF0000"><%=WI.getStrValue(strErrMsg,"Message : ","","")%></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td>
<%
if(bolIsCompany) {
	strTemp = " checked";
	strErrMsg = "";
}else{
	strTemp = "";
	strErrMsg = " checked";
}
if(bolIsCompany || vEditInfo == null) {%>
	    <input name="payee_type" type="radio" value="1"<%=strTemp%> onClick="document.form_.page_action.value='';document.form_.ap_info.value='';document.form_.submit();"> Supplier - Company &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<%}if(!bolIsCompany || vEditInfo == null) {%>
        <input name="payee_type" type="radio" value="0"<%=strErrMsg%> onClick="document.form_.page_action.value='';document.form_.ap_info.value='';document.form_.submit();"> Supplier - Individual	
<%}%> 
	  
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><u>Supplier Code (Name) - <%if(bolIsCompany){%>Company<%}else{%>Individual<%}%></u></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>
	  <select name="ap_info" onChange="document.form_.page_action.value='';document.form_.prepareToEdit.value='';document.form_.info_index.value='';document.form_.submit();" style="font-size:10px">
		<option value="">Select a Payee</option>
<%
strTemp = " from AC_AP_BASIC_INFO where is_valid = 1";
if(bolIsCompany)
	strTemp += " and supplier_index is not null";
else	
	strTemp += " and supplier_index is null";

strTemp += " order by PAYEE_CODE";
%>
<%=dbOP.loadCombo("AP_INFO_INDEX","PAYEE_CODE+' ('+PAYEE_NAME+')'",strTemp, WI.fillTextValue("ap_info"), false)%>   
	  </select>
	  </td>
    </tr>
  </table>
<%if(WI.fillTextValue("ap_info").length() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    <tr>
      <td height="15" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="17%">Transaction type:      </td>
      <td width="79%">
	  <select name="is_debit">
        <option value="1">Debit</option>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("is_debit");
if(strTemp.equals("0"))
	strTemp = "selected";
else
	strTemp = "";
%>
        <option value="0" <%=strTemp%>>Credit</option>
      </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Transaction date: </td>
      <td>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("trans_date");
%>	  <input name="trans_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.trans_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>&nbsp;(mm/dd/yyyy)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Amount : </td>
      <td>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("amount");
if(strTemp.indexOf(",") != -1)
	strTemp = ConversionTable.replaceString(strTemp, ",","");
%>
	  <input name="amount" type="text" size="16" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="AllowOnlyFloat('form_','amount');style.backgroundColor='white'" onKeyUp="AllowOnlyFloat('form_','amount')"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Debit/Credit Note </td>
      <td>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("dc_note");
%>	  <input name="dc_note" type="text" size="90" value="<%=strTemp%>" class="textbox" style="font-size:11px" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Transaction Reference </td>
      <td><%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("oth_note");
%>	  <input name="oth_note" type="text" size="90" value="<%=WI.getStrValue(strTemp)%>" class="textbox" style="font-size:11px" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="50">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
        <%if(!strPrepareToEdit.equals("1")) {%>
		<input type="submit" value=" Save Information " style="font-size:10px; height:22px;border: 1px solid #FF0000;" 
			onClick="document.form_.page_action.value='1';document.form_.prepareToEdit.value='';document.form_.info_index.value=''"> 
        <%}else {%>
        <input type="submit" value=" Edit Information " style="font-size:10px; height:22px;border: 1px solid #FF0000;" 
			onClick="document.form_.page_action.value='2';document.form_.info_index.value='<%=(String)vEditInfo.elementAt(0)%>'">
        <%}%>
        &nbsp;&nbsp;&nbsp;
		<input type="button" value=" Cancel Operation " style="font-size:10px; height:22px;border: 1px solid #FF0000;" onClick="CancelOperation();">	  </td>
    </tr>
  </table>
<%}
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="8" align="center" bgcolor="#B4C5D6" class="thinborder"><strong><font color="#000000">:: Old Accounts Encoded :: </font></strong></td>
    </tr>
    <tr>
      <td width="10%" class="thinborder" height="25"><strong>Transaction Date </strong></td>
      <td width="15%" class="thinborder" style="font-weight:bold">Transaction Note</td>
      <td width="30%" class="thinborder"><strong>Debit/Credit Note </strong></td>
      <td width="10%" class="thinborder"><strong>Debit</strong></td>
      <td width="10%" class="thinborder"><strong>Credit</strong></td>
      <td width="10%" class="thinborder"><strong>Balance</strong></td>
      <td width="7%" class="thinborder"><strong>Edit</strong></td>
      <td width="8%" class="thinborder"><strong>Delete</strong></td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 7){%>
    <tr>
      <td class="thinborder" height="25"><%=vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 4),"&nbsp;")%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder" align="right"><%if(vRetResult.elementAt(i + 2).equals("1")){%><%=vRetResult.elementAt(i + 1)%><%}else{%>&nbsp;<%}%></td>
      <td class="thinborder" align="right"><%if(vRetResult.elementAt(i + 2).equals("0")){%><%=vRetResult.elementAt(i + 1)%><%}else{%>&nbsp;<%}%></td>
      <td class="thinborder" align="right"><%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder" align="center">
	  <%if(iAccessLevel > 1){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/edit.gif" border="0"></a> 
	  <%}%>	  </td>
      <td class="thinborder" align="center">
	  <%if(iAccessLevel > 1){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/delete.gif" border="0"></a> 
	  <%}%>	  </td>
    </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="17%" height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>