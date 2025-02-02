<%@ page language="java" import="utility.*, Accounting.billing.BillingTsuneishi, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>AC Proj Billing Manangement</title>
</head>

<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function PrintPg(strProjIndex, strInfoIndex){
		location = "./project_billing_mgmt_print.jsp?proj_index="+strProjIndex+"&info_index="+strInfoIndex;
	}
	
	function RefreshPage(strProjIndex){
		location = "./project_billing_mgmt.jsp?proj_index="+strProjIndex;
	}
	
	function ReloadPage(){
		document.form_.info_index.value = "";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.submit();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this billing?'))
				return;
		}
		
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
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
			
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
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

</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BILLING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ACCOUNTING-BILLING","project_billing_mgmt.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}	

	boolean bolHasPayment = false;
	String strProjIndex = WI.fillTextValue("proj_index");
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vProjectInfo = null;
	Vector vEditInfo  = null; 
	Vector vRetResult = null;
	
	BillingTsuneishi billTsu = new BillingTsuneishi();
	
	if(strProjIndex.length() > 0){
		vProjectInfo = billTsu.getProjectInfo(dbOP, request);
		if(vProjectInfo == null)
			strErrMsg = billTsu.getErrMsg();
		else{
			strTemp = WI.fillTextValue("page_action");
			
			if(strTemp.length() > 0){
				if(billTsu.operateOnProjectBillings(dbOP, request, Integer.parseInt(strTemp)) == null)
					strErrMsg = billTsu.getErrMsg();
				else{
					if(strTemp.equals("0"))
						strErrMsg = "Project billing successfully removed.";
					if(strTemp.equals("1"))
						strErrMsg = "Project billing successfully recorded.";
					if(strTemp.equals("2"))
						strErrMsg = "Project billing successfully edited.";
						
					strPrepareToEdit = "0";
				}
			}
			
			vRetResult = billTsu.operateOnProjectBillings(dbOP, request, 4);
			
			if(strPrepareToEdit.equals("1")){
				vEditInfo = billTsu.operateOnProjectBillings(dbOP, request, 3);
				if(vEditInfo == null)
					strErrMsg = billTsu.getErrMsg();
				else{
					double dPayableAmt = Double.parseDouble((String)vEditInfo.elementAt(15));
					double dBillAmount = Double.parseDouble((String)vEditInfo.elementAt(2));

					if(dBillAmount > dPayableAmt){
						strErrMsg = "Only editing of billing amount not allowed. Payment already done for billing.";
						bolHasPayment = true;
					}
				}
			}
		}
	}	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./project_billing_mgmt.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: PROJECT BILLING MANAGEMENT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Project: </td>
			<td width="80%">
				<select name="proj_index" onChange="ReloadPage();">
          			<option value="">Select Project</option>
          			<%=dbOP.loadCombo("project_index","project_name", " from ac_tun_project where is_valid = 1", WI.fillTextValue("proj_index"),false)%> 
        		</select></td>
		</tr>
	</table>
	
<%if(vProjectInfo != null && vProjectInfo.size() > 0){%>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15" colspan="3"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong>Project Information: </strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Project Name: </td>
			<td width="80%">&nbsp;<%=(String)vProjectInfo.elementAt(1)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Project Detail: </td>
			<td><div align="justify">&nbsp;<%=(String)vProjectInfo.elementAt(2)%></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Project Timetable: </td>
			<td>&nbsp;<%=(String)vProjectInfo.elementAt(3)%> - <%=(String)vProjectInfo.elementAt(4)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Project Lead: </td>
			<td>&nbsp;<%=(String)vProjectInfo.elementAt(6)%></td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15" colspan="4"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Billing Date: </td>
		    <td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(6);
					else
						strTemp = WI.fillTextValue("billing_date");
				%>
				<input name="billing_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.billing_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Billing Reference: </td>
		    <td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(7);
					else
						strTemp = WI.fillTextValue("bill_reference");
				%>
				<input type="text" name="bill_reference" value="<%=strTemp%>" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					size="32" maxlength="64"></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Billing #: </td>
		    <td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(8);
					else
						strTemp = WI.fillTextValue("billing_no");
				%>
				<input type="text" name="billing_no" value="<%=strTemp%>" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					size="32" maxlength="32">
				
				<input type="checkbox" name="auto_gen" value="1" />
				<font size="1">Check to auto-generate billing no.</font></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Bill Amount: </td>
	     	<td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(2);
					else
						strTemp = WI.fillTextValue("bill_amount");
					
					strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp, true), ",", "");
					if(strTemp.equals("0"))
						strTemp = "";
					
					if(bolHasPayment)
						strErrMsg = "readonly";
					else
						strErrMsg = "";
				%>
				<input type="text" name="bill_amount" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','bill_amount');style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','bill_amount')" size="10" maxlength="10" <%=strErrMsg%> /></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Start Date : </td>
		    <td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.fillTextValue("date_fr");
				%>
				<input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>End Date: </td>
		    <td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(4);
					else
						strTemp = WI.fillTextValue("date_to");
				%>
				<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Manpower: </td>
		    <td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("man_power");
				%>
				<input type="text" name="man_power" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','man_power');style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyInteger('form_','man_power')" size="10" maxlength="10" /></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Project Detail: </td>
		    <td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(9));
					else
						strTemp = WI.fillTextValue("proj_detail");
				%>
				<textarea name="proj_detail" style="font-size:12px" cols="40" rows="2" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Special Instruction: </td>
		    <td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp =  WI.getStrValue((String)vEditInfo.elementAt(10));
					else
						strTemp = WI.fillTextValue("special_ref");
				%>
				<textarea name="special_ref" style="font-size:12px" cols="40" rows="2" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Notes: </td>
		    <td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp =  WI.getStrValue((String)vEditInfo.elementAt(11));
					else
						strTemp = WI.fillTextValue("note");
				%>
				<textarea name="note" style="font-size:12px" cols="40" rows="2" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
	    </tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Project Leader: </td>
			<td width="25%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(14);
					else
						strTemp = WI.fillTextValue("emp_id");
				%>
				<input name="emp_id" type="text" class="textbox" size="16" onKeyUp="AjaxMapName();" value="<%=strTemp%>"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		    <td width="55%" valign="top"><label id="coa_info" style="position:absolute; width:350px;"></label></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="2">
			<%if(iAccessLevel > 1){
				if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save billing info.</font>
				    <%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
						<font size="1">Click to edit billing information.</font>
					    <%}
				}%>
				<a href="javascript:RefreshPage('<%=WI.fillTextValue("proj_index")%>');">
					<img src="../../../images/refresh.gif" border="0"></a>
				<font size="1">Click to refresh page.</font>
			<%}else{%>
				Not authorized.
			<%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
	</table>
	
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr> 
		  	<td height="20" colspan="9" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: PROJECT BILLING LISTING ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Billing Date</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Bill #</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Bill Reference</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Amount</strong></td>
			<td width="18%" align="center" class="thinborder"><strong>Timetable</strong></td>
			<td width="7%"  align="center" class="thinborder"><strong>Manpower</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Project Head</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%  int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=16, iCount++){%>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+8)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+7)%></td>
			<td class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+2), true)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%> - <%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+13)%></td>
			<td align="center" class="thinborder">
				<a href="javascript:PrintPg('<%=WI.fillTextValue("proj_index")%>', '<%=(String)vRetResult.elementAt(i)%>')">
					<img src="../../../images/print.gif" border="0"></a>
				
			<%if(iAccessLevel > 1){%>
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')">
					<img src="../../../images/edit.gif" border="0" /></a>
				<%if(iAccessLevel == 2){%>
					<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>')">
						<img src="../../../images/delete.gif" border="0" /></a>
				<%}
			}else{%>
				Not authorized.
			<%}%></td>
		</tr>
	<%}%>
	</table>
	<%}
}%>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
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