<%@ page language="java" import="utility.*,java.util.Vector" buffer="16kb"%>
<%
String strAuthIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
if(strAuthIndex == null || strAuthIndex.equals("4")) {%>
	<p align="center" style="font-size:16px; font-weight:bold; color:#FF0000"> You are not allowed to access this page.
<%return;}

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	boolean bolPrintPage = false;
	if(WI.fillTextValue("print_page").length() > 0) 
		bolPrintPage = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../..//css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../..//jscript/date-picker.js"></script>
<script language="JavaScript" src="../../..//jscript/common.js"></script>
<script language="JavaScript">
function UpdateOR(strAction, strInfoIndex) {
	if(strAction != '')
		document.form_.print_page.value='';
	if(strAction == '0') {
		if(!confirm('Are you sure you want to remove this record?'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value  = strInfoIndex;
	
	document.form_.submit();
}
function printPage() {
	document.form_.print_page.value='1';
	UpdateOR('','');
}
function focusID() {
	<%if(bolPrintPage){%>
		var obj = document.getElementById('myADTable1');
		obj.deleteRow(0);
		obj.deleteRow(0);
		obj = document.getElementById('myADTable2');
		obj.deleteRow(0);
		obj.deleteRow(0);
		obj.deleteRow(0);
		obj.deleteRow(0);
		obj.deleteRow(0);
		obj.deleteRow(0);
		obj = document.getElementById('myADTable3');
		obj.deleteRow(0);
		obj = document.getElementById('myADTable4');
		obj.deleteRow(0);
		obj.deleteRow(0);
		
		document.bgColor = "#FFFFFF";
		window.print();
	<%}else{%>
		document.form_.damaged_or.focus();
	<%}%>
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID();">
<%
	String strErrMsg = null;
	String strTemp = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT MAINTENANCE-Manage Damaged OR","damaged_or.jsp");
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
	Vector vRetResult = null;
	enrollment.FAPmtMaintenance pmtMaintenance = new enrollment.FAPmtMaintenance();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		vRetResult = pmtMaintenance.operateOnDamagedOR(dbOP, request, Integer.parseInt(strTemp));
		if(vRetResult == null)
			strErrMsg = "Operation Successful.";
		else
			strErrMsg  = pmtMaintenance.getErrMsg();
	}
	
	vRetResult = pmtMaintenance.operateOnDamagedOR(dbOP, request, 4);
	if(strErrMsg == null && vRetResult == null) 
		strErrMsg = pmtMaintenance.getErrMsg();
  %>
<form name="form_" action="./damaged_or.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          DAMAGED OR MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-weight:bold; font-size:14px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="12%" height="25">Damaged OR  </td>
      <td width="86%" height="25">
	  <input name="damaged_or" type="text" size="16" value="<%=WI.fillTextValue("damaged_or")%>" class="textbox_bigfont"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top"><br>
      Reason</td>
      <td height="25">
	  	<textarea name="damaged_reason" rows="3" cols="70" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("damaged_reason")%></textarea>	  </td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td>
	  	<input type="button" name="12" id="_update_info" value=" Save >> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="UpdateOR('1','');">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Search: </td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">
	  	<table width="75%" bgcolor="#CCCCCC" border="0" cellpadding="0" cellspacing="0" class="thinborder">
			<tr>
				<td width="26%" height="18" class="thinborder">Date Created Range: </td>
				<td width="74%" class="thinborder">
					<input name="cancel_date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("cancel_date_fr")%>" class="textbox"
					  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        			<a href="javascript:show_calendar('form_.cancel_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
				to 
					<input name="cancel_date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("cancel_date_to")%>" class="textbox"
					  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        			<a href="javascript:show_calendar('form_.cancel_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
				</td>
			</tr>
			<tr>
				<td height="18" class="thinborder">OR Range:</td>
				<td class="thinborder">
				<input name="or_fr" type="text" size="16" value="<%=WI.fillTextValue("or_fr")%>" class="textbox"
				 onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				 
				 to 
				 
				 <input name="or_to" type="text" size="16" value="<%=WI.fillTextValue("or_to")%>" class="textbox"
				  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				
				</td>
			</tr>
		</table>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td>
	  <input type="button" name="122" id="12" value=" Apply Search Filter/Show ALL >> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.print_page.value='';document.form_.search_.value='1';UpdateOR('','');">
	  </td>
    </tr>
  </table>
  
<%
if(vRetResult != null && vRetResult.size() > 0){%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr>
      <td height="25" style="font-size:9px;" align="right"><a href="javascript:printPage();"><img src="../../../images/print.gif" border="0"></a> Print Report&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td style="font-size:9px;" align="right">Date and Time Printed: <%=WI.getTodaysDateTime()%></td>
    </tr>
    <tr>
      <td style="font-weight:bold;" align="center">LIST OF DAMAGED OR</td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr style="font-weight:bold;" align="center">
		<td width="10%" height="22" class="thinborder">OR Number</td>
		<td width="50%" class="thinborder">Reason</td>		
		<td width="15%" class="thinborder">Date Created </td>
		<td width="15%" class="thinborder">Created By </td>
<%if(!bolPrintPage) {%>
		<td width="10%" class="thinborder">Delete</td>
<%}%>
	</tr>
	<%for (int i=0; i  < vRetResult.size(); i +=4 ){%>
	<tr>
		<td class="thinborder" style="padding-left:5px;" height="22"><%=vRetResult.elementAt(i)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
<%if(!bolPrintPage) {%>
		<td class="thinborder" align="center">
			<a href="javascript:UpdateOR('0', '<%=(String)vRetResult.elementAt(i)%>')">
			<img src="../../../images/delete.gif" border="0"></a>		</td>
<%}%>
	</tr>
	<%}%>	
</table>
  
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index">
  <input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>">
  <input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>