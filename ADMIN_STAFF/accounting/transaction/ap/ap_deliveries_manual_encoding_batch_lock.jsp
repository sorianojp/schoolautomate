<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript">
function ReloadPage() {	
	document.form_.page_action.value = '';
	document.form_.submit()
}
function SaveInformation() {
	document.form_.page_action.value = '1';
	document.form_.submit();
}
function CopyLockDate(strStartI) {
	if(!confirm('Are you sure you want to copy Lock Date to rest of Vouchers below this row.'))
		return;
		
	var iMaxCount = document.form_.max_disp.value;
	var strDefVal;
	eval('strDefVal = document.form_.lock_date_'+strStartI+'.value');
	
	
	var obj; var obj2;
	for(i = strStartI; i < iMaxCount; ++i) {
		eval('obj=document.form_.lock_date_'+i);
		eval('obj2=document.form_.cb_'+i);
		if(!obj)
			continue;
		//alert("I amhere."+i);
		obj.value = strDefVal;
		if(strDefVal.length > 0)
			obj2.checked = true;
		else
			obj2.checked = false;		
	}
}
function UpdateCheckBox(objLockDate, objCheckBox) {
	if(objLockDate.value.length == 0)
		objCheckBox.checked = false;
	else
		objCheckBox.checked = true;
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*, purchasing.Delivery, Accounting.AccountPayable, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-ACCOUNTING-TRANSACTION-AP-AP PROCESSING-Batch Locking","ap_deliveries_manual_encoding_batch_lock.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	AccountPayable AP = new AccountPayable();
	Vector vRetResult = null;
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(AP.operateOnProcessAPManualNew(dbOP, request, 5) == null) 
			strErrMsg = AP.getErrMsg();
		else	
			strErrMsg = "Operation Successful.";
	}
	vRetResult = AP.operateOnProcessAPManualNew(dbOP, request, 4);
	
	if(vRetResult == null)
		strErrMsg = AP.getErrMsg();

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<form name="form_" method="post" action="ap_deliveries_manual_encoding_batch_lock.jsp">
  
  <%if(strErrMsg != null) {%>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
		  <tr>
			<td style="font-weight:bold; font-size:14px; color:#FF0000"><%=strErrMsg%></td>
			</tr>
	  </table>
  <%}if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
  <tr>
    <td height="25" colspan="11" align="center" bgcolor="#B4C5D6" class="thinborderTOPLEFTRIGHT"><strong><font color="#000000">:: ENCODED DELIVERY INFORMATION :: </font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
  <tr> 
    <td width="18%" align="center"class="thinborder" style="font-size:9px; font-weight:bold">Supplier</td>
    <td width="8%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Posted Date</td>
    <td width="18%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Item Detail </td>
    <td width="10%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Reference</td>
    <td width="7%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Payable Amt</td>
    <td width="7%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Balance Payable </td>
    <td width="7%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">To be Processed Amt  </td>
    <td width="15%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Charged To Account</td>
    <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Voucher Number </td>
    <td width="7%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Lock Date </td>
    <td width="5%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Select</td>
  </tr>
<%int iCount = 0; 
Vector vDCAccount = null;
for(int i = 0;i < vRetResult.size();i+=14,++iCount){
	if(vRetResult.elementAt(i + 11) != null)
		continue;
	
	if(vRetResult.elementAt(i + 10) != null) {
		strErrMsg = " bgcolor='cccccc'";
		continue;
	}
	else	
		strErrMsg = "";
	vDCAccount = null;
	if(vRetResult.elementAt(i + 13) != null)
		vDCAccount = (Vector)vRetResult.elementAt(i + 13);
	
%>
  <tr<%=strErrMsg%>> 
    <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%> <br><%=(String)vRetResult.elementAt(i + 8)%></td>
    <td class="thinborder" align="center">
	<input name="date_posted_<%=iCount%>" type="text" size="11" class="textbox_noborder" style="font-size:9px;"
			onBlur="style.backgroundColor='white'"
			value="<%=(String)vRetResult.elementAt(i + 2)%>" onFocus="style.backgroundColor='#D3EBFF'">	</td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6), "Not Set")%></td>
    <td align="right" class="thinborder"><%=ConversionTable.replaceString(CommonUtil.formatFloat((String)vRetResult.elementAt(i+1),true),",","")%>	
	</td>
    <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+4)%>&nbsp;</td>
    <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%>&nbsp;</td>
    <td class="thinborder">
	<%if(vDCAccount == null) {%>
		Not Defined
	<%}else{%>
		<table cellpadding="0" cellspacing="0">
			<!--<tr>
				<td class="thinborderBOTTOM">Account Code</td>
				<td class="thinborderBOTTOM">Account Name</td>
				<td class="thinborderBOTTOM">Amount</td>				
			</tr>-->
			<%while(vDCAccount.size() > 0) {
			if(vDCAccount.remove(0).equals("0"))
				strErrMsg = " bgcolor='#dddddd'";
			else
				strErrMsg = "";%>
			<tr<%=strErrMsg%>>
				<td class="thinborderBOTTOMRIGHT" style="font-size:9px;"><%=vDCAccount.remove(0)%></td>
				<td class="thinborderBOTTOMRIGHT" style="font-size:9px;"><%=vDCAccount.remove(0)%></td>
				<td class="thinborderBOTTOMRIGHT" style="font-size:9px;"><%=vDCAccount.remove(0)%></td>				
			</tr>
			<%}%>
		</table>
	
	<%}%>	</td>
    <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+12), "Not Set")%></td>
    <td class="thinborder" onDblClick="CopyLockDate(<%=iCount%>);">
	<input name="lock_date_<%=iCount%>"  type= "text" class="textbox"  value="<%=WI.fillTextValue("lock_date_"+iCount)%>" 
			 size="10" maxlength="10" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','lock_date_<%=iCount%>','/');UpdateCheckBox(document.form_.lock_date_<%=iCount%>,document.form_.cb_<%=iCount%>);"  
				onKeyUp="AllowOnlyIntegerExtn('form_','lock_date_<%=iCount%>','/')">
	</td>
    <td class="thinborder" align="center">
		<input type="checkbox" name="cb_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
	
	</td>
  </tr>
<%}%>
	<input type="hidden" name="max_disp" value="<%=iCount%>">
  </table>
 	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  <td align="center">
		  <input type="button" name="1" value="&nbsp;&nbsp;Lock Selected Vouchers&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="SaveInformation()">	  </td>
		</tr>
	</table>


  <%}%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td width="100%" height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>	
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
