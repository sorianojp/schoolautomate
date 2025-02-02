<%@ page language="java" import="utility.*,Accounting.COASetting,java.util.Vector" %>
<%
	WebInterface WI  = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COA Country Code Setup</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">

	function UpdateSubAccounts(strCostCenterIndex){
		var sT = "./coa_update_sub_account_list.jsp?cost_center_index="+strCostCenterIndex+"&opner_form_name=form_";
		var win=window.open(sT,"UpdateSubAccounts",'dependent=yes,width=900,height=500,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function CancelOperation(){
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.info_index.value = "";
		document.form_.submit();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this cost center?'))
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
	
</script>
<%
	DBOperation dbOP = null;
	
	String strTemp   = null;
	String strErrMsg = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","coa_setup_cost_centers.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-ADMINISTRATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
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
	
	int iMaxValue = 0;
	Vector vRetResult = null;
	Vector vEditInfo = null;
	Vector vSegmentSetup = null;
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	String strCostCenterDigits = null;
	COASetting coa = new COASetting();
	
	strTemp = WI.fillTextValue("page_action");
	vSegmentSetup = coa.operateOnSegmentSetup(dbOP, request, 4);
	if(vSegmentSetup == null)
		strErrMsg = coa.getErrMsg();
	else{
		strCostCenterDigits = (String)vSegmentSetup.elementAt(4);

		if(strCostCenterDigits.equals("1"))
			iMaxValue = 9;
		else if(strCostCenterDigits.equals("2"))
			iMaxValue = 99;
		else
			iMaxValue = 999;
			
		if(strTemp.length() > 0){
			if(coa.operateOnCostCenters(dbOP, request, Integer.parseInt(strTemp)) == null)
				strErrMsg = coa.getErrMsg();
			else{
				if(strTemp.equals("0"))
					strErrMsg = "Cost center information successfully removed.";
				if(strTemp.equals("1"))
					strErrMsg = "Cost center information successfully recorded.";
				if(strTemp.equals("2"))
					strErrMsg = "Cost center information successfully edited.";
				
				strPrepareToEdit = "0";
			}
		}
		
		vRetResult = coa.operateOnCostCenters(dbOP, request, 4);
		
		if(strPrepareToEdit.equals("1")){
			vEditInfo = coa.operateOnCostCenters(dbOP, request, 3);
			if(vEditInfo == null)
				strErrMsg = coa.getErrMsg();
		}
	}
%>
<body bgcolor="#D2AE72" onLoad="document.form_.cost_center_code.focus();">
<form action="./coa_setup_cost_centers.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF">
			  	<strong>:::: UNIT CENTER SETUP ::::</strong></font></div></td>
    	</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Unit Center Code: </td>
			<td width="77%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(0);
					else
						strTemp = WI.fillTextValue("cost_center_code");
				%>
				<input name="cost_center_code" type="text" size="32" maxlength="64" class="textbox" value="<%=strTemp%>" 
	  				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Unit Center Name: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("cost_center_name");
				%>
				<input name="cost_center_name" type="text" size="32" maxlength="64" class="textbox" value="<%=strTemp%>" 
	  				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Order of Display: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(2);
					else
						strTemp = WI.fillTextValue("disp_order");
				%>				
				<select name="disp_order">
				<% 
				int iDefault = Integer.parseInt(WI.getStrValue(strTemp,"1"));
				for(int i = 1; i <= iMaxValue ; i++) {
					if ( i == iDefault) {%>
						<option selected value="<%=i%>"><%=i%></option>
					<%}else{%>
						<option value="<%=i%>"><%=i%></option>
					<%}
				}%>
				</select></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
			<%if(iAccessLevel > 1){
				if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../../images/save.gif" border="0"></a>
				<%}else {
					if(vEditInfo!=null){%>
					<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(2)%>');">
						<img src="../../../../images/edit.gif" border="0"></a>
					<%}
				}%>
				<a href="javascript:CancelOperation();"><img src="../../../../images/cancel.gif" border="0"></a>
			<%}else{%>
				Not authorized to add/modify coa country code setup.
			<%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
  	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="20" colspan="6" bgcolor="#B9B292" class="thinborder"><div align="center">
				<strong>::: COST CENTERS IN RECORD :::</strong></div></td>
	 	</tr>
		<tr>
			<td height="25" width="20%" align="center" class="thinborder"><strong>Unit Center Code</strong></td>
			<td width="30%" align="center" class="thinborder"><strong>Unit Center Name</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Order</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Is Applied</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Update<br>Sub-Accounts </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 5){%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder" align="center"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder" align="center">
				<%
					strTemp = (String)vRetResult.elementAt(i+4);
					if(strTemp.equals("0"))
						strTemp = "NO";
					else
						strTemp = "YES";
				%><%=strTemp%></td>
			<td class="thinborder" align="center">
				<a href="javascript:UpdateSubAccounts('<%=(String)vRetResult.elementAt(i+2)%>');">
					<img src="../../../../images/update.gif" border="0"></a></td>
			<td class="thinborder" align="center">
			<%if(iAccessLevel > 1){
				if(((String)vRetResult.elementAt(i+4)).equals("0")){%>
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i+2)%>')">
						<img src="../../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i+2)%>')">
							<img src="../../../../images/delete.gif" border="0"></a>
					<%}%>
				<%}else{%>
					Not allowed.
				<%}
			}else{%>
				Not authoized.
			<%}%></td>
		</tr>
	<%}%>
	</table>
<%}%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A"> 
			<td height="25">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>