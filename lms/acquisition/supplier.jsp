<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

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
//authenticate this user.


//end of authenticaion code.
lms.LmsAcquision lmsAcq = new lms.LmsAcquision();
Vector vRetResult = null; Vector vEditInfo = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");

strTemp = WI.fillTextValue("page_action");
if(strTemp.equals("10")) {
	strTemp = WI.fillTextValue("info_index");
	if(strTemp.length() > 0) {
		strTemp = "update lms_acq_supplier set is_active = 1 where supplier_index = "+strTemp;
		if(dbOP.executeUpdateWithTrans(strTemp, null, null, false) == -1)
			strErrMsg = "Request Failed. Error in SQLQuery.";
		else	
			strErrMsg = "Supplier Activated. Please check the supplier in Active supplier list.";
	}
	else
		strErrMsg = "Reference index is missing.";
	strTemp = "";
}
if(strTemp.length() > 0) {
	if(lmsAcq.operateOnLMSSupplier(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = lmsAcq.getErrMsg();
	else {	
		strErrMsg = "Request processed successfully.";
		strPreparedToEdit = "0";
	}
}
if(strPreparedToEdit.equals("1")) {
	vEditInfo = lmsAcq.operateOnLMSSupplier(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = lmsAcq.getErrMsg();
}
vRetResult = lmsAcq.operateOnLMSSupplier(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = lmsAcq.getErrMsg();
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Suppliers</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex, bolIsUsed) {
	if(strAction == '0') {
		var strProceed;
		if(bolIsUsed) {
			if(!confirm('Are you sure you want to in-activate this supplier?'))
				return;
		}
		else	
			if(!confirm('Are you sure you want to delete this supplier?'))
				return;
			
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function PreparedToEdit(strInfoIndex) {
	document.form_.preparedToEdit.value = '1';
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
</script>
<body bgcolor="#FAD3E0" onLoad="document.form_.supplier_code.focus();">
<form name="form_" method="post" action="supplier.jsp" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#0D3371"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          LMS - SUPPLIERS : PROFILES PAGE ::::</strong></font></div></td>
    </tr>
    <tr valign="top"> 
      <td height="34" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%" height="25">Supplier Code</td>
      <td width="82%" height="25"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);	
else 
	strTemp = WI.fillTextValue("supplier_code");
%> 
	<input name="supplier_code" type="text"  value="<%=strTemp%>" size="16" maxlength="16" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur='style.backgroundColor="white"'></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td>Supplier Name</td>
      <td> 
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);	
else 
	strTemp = WI.fillTextValue("supplier_name");
%> 
	 <input name="supplier_name" type="text" value="<%=strTemp%>" size="68" maxlength="128" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur='style.backgroundColor="white"'></td>
    </tr>
    <tr>
      <td height="15">&nbsp;</td>
      <td>Contact Number </td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(4);	
else 
	strTemp = WI.fillTextValue("tel_no");
%> 
	  <input name="tel_no" type="text" value="<%=WI.getStrValue(strTemp)%>" size="68" maxlength="128" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur='style.backgroundColor="white"'></td>
    </tr>
    <tr>
      <td height="15">&nbsp;</td>
      <td>Supplier Since </td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(5);	
else 
	strTemp = WI.fillTextValue("supplier_since");
%> 
<input name="supplier_since" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=strTemp%>"> 
        <a href="javascript:show_calendar('form_.supplier_since');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a>
	  </td>
    </tr>
    <tr>
      <td height="15">&nbsp;</td>
      <td valign="top"><br>Address</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);	
else 
	strTemp = WI.fillTextValue("addr");
%> 
        <textarea name="addr" cols="65" rows="2" class="textbox" style="font-size:11px; font-family:Verdana, Arial, Helvetica, sans-serif"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea> 
	  </td>
    </tr>
    <tr>
      <td height="15">&nbsp;</td>
      <td valign="top"><br>Notes</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(6);	
else 
	strTemp = WI.fillTextValue("addl_note");
%> 
        <textarea name="addl_note" cols="65" rows="2" class="textbox" style="font-size:11px; font-family:Verdana, Arial, Helvetica, sans-serif"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea> 
	  </td>
    </tr>
    <tr>
      <td height="15">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%if(strPreparedToEdit.equals("0")){%>	  
	  <input type="submit" name="1" value="&nbsp; Add Supplier &nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1';document.form_.preparedToEdit.value='';">
<%}else{%>	  
	  <input type="submit" name="1" value="&nbsp; Edit Supplier &nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.info_index.value='<%=vEditInfo.remove(0)%>';document.form_.page_action.value='2';document.form_.preparedToEdit.value='';">
	  &nbsp;&nbsp;&nbsp;
	  <input type="submit" name="1" value="&nbsp; Cancel Edit &nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='';document.form_.preparedToEdit.value='';">
<%}%>	  
	  </td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="100%" height="25" class="thinborderTOPLEFTRIGHT"><div align="center"><strong>LIST OF SUPPLIERS</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td height="25" colspan="8" class="thinborder"><strong>Total Active Supplier : </strong></td>
    </tr>
    <tr bgcolor="#9DB6F4" align="center" style="font-weight:bold"> 
      <td width="8%" height="25" class="thinborder" style="font-size:9px;">Supplier Code </td>
      <td width="15%" class="thinborder" style="font-size:9px;">Supplier Name </td>
      <td width="12%" class="thinborder" style="font-size:9px;">Contact No </td>
      <td width="20%" class="thinborder" style="font-size:9px;">Address</td>
      <td width="20%" class="thinborder" style="font-size:9px;">Notes</td>
      <td width="10%" class="thinborder" style="font-size:9px;">Supplier Since </td>
      <td width="7%" class="thinborder"  style="font-size:9px;">EDIT</td>
      <td width="8%" class="thinborder"  style="font-size:9px;">DEL/In-activate</td>
    </tr>
    <%
	boolean bolIsUsed = false;
	while(vRetResult.size() > 0) {
	if(vRetResult.elementAt(7).equals("0"))
		break;
	if(vRetResult.remove(8).equals("1"))
		bolIsUsed = true;
	else	
		bolIsUsed = false;
	vRetResult.remove(7);
	strTemp = (String)vRetResult.remove(0);
		%>
		<tr> 
		  <td height="25" class="thinborder"><%=vRetResult.remove(0)%></td>
		  <td class="thinborder"><%=vRetResult.remove(0)%></td>
		  <td class="thinborder"><%=vRetResult.remove(1)%></td>
		  <td class="thinborder"><%=vRetResult.remove(0)%></td>
		  <td class="thinborder"><%=vRetResult.remove(1)%></td>
		  <td class="thinborder"><%=vRetResult.remove(0)%></td>
		  <td class="thinborder" align="center"><input type="button" name="_" value="Edit" onClick="PreparedToEdit('<%=strTemp%>')"></td>
		  <td class="thinborder" align="center"><input type="button" name="_" value="<%if(bolIsUsed){%>In-Activate<%}else{%>Delete<%}%>" onClick="PageAction('0','<%=strTemp%>',<%=bolIsUsed%>)"></td>
		</tr>
  	<%}//end of while.. %>
  </table>
  <%if(vRetResult.size() > 0) {%>
  <br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#CCCCCC">
    <tr> 
      <td height="25" colspan="7" class="thinborder"><strong>Total In-Active Supplier : </strong></td>
    </tr>
    <tr bgcolor="#9DB6F4" align="center" style="font-weight:bold"> 
      <td width="8%" height="25" class="thinborder" style="font-size:9px;">Supplier Code </td>
      <td width="15%" class="thinborder" style="font-size:9px;">Supplier Name </td>
      <td width="12%" class="thinborder" style="font-size:9px;">Contact No </td>
      <td width="20%" class="thinborder" style="font-size:9px;">Address</td>
      <td width="20%" class="thinborder" style="font-size:9px;">Notes</td>
      <td width="10%" class="thinborder" style="font-size:9px;">Supplier Since </td>
      <td width="8%" class="thinborder"  style="font-size:9px;">Activate</td>
    </tr>
	<%while(vRetResult.size() > 0) {
	vRetResult.remove(8);vRetResult.remove(7);
	strTemp = (String)vRetResult.remove(0); %>
		<tr> 
		  <td height="25" class="thinborder"><%=vRetResult.remove(0)%></td>
		  <td class="thinborder"><%=vRetResult.remove(0)%></td>
		  <td class="thinborder"><%=vRetResult.remove(1)%></td>
		  <td class="thinborder"><%=vRetResult.remove(0)%></td>
		  <td class="thinborder"><%=vRetResult.remove(1)%></td>
		  <td class="thinborder"><%=vRetResult.remove(0)%></td>
		  <td class="thinborder" align="center"><input type="button" name="_" value="Activate" onClick="PageAction('10','<%=strTemp%>')"></td>
		</tr>
	<%}%>
  </table>  
  <%}//if there is any in-active supplier to show.. 

}//end of vRetResult... %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>

    <tr> 
      <td height="25" colspan="8" bgcolor="#0D3371">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>
