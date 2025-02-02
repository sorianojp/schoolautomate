<%@ page language="java" import="utility.*,java.util.Vector, hr.GovtEvaluation" %>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Quarterly Performance Evaluation</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function AllowOnlyGovtRating(strFormName,strFieldNameToValidate,strKeyUp) {
		strIntVal = eval('document.'+strFormName+'.'+strFieldNameToValidate+'.value');
		if(strIntVal.length == 0)
			return;
			
		if(strIntVal.length > 2)
			strIntVal = strIntVal.charAt(0) + strIntVal.charAt(1);
		
		if(strKeyUp == '1'){
			var vFirst = strIntVal.charAt(0);
			if(vFirst != '1' && vFirst != '2' && vFirst != '4' && vFirst != '6' && vFirst != '8')
				strIntVal = "";
				
			if(strIntVal.length == 2){
				if(strIntVal.charAt(1) != '0')
					strIntVal = vFirst;
				else{
					if(vFirst != '1')
						strIntVal = vFirst;
				}
			}
		}
		else{
			if(strIntVal != '2' && strIntVal != '4' && strIntVal != '6' && strIntVal != '8' && strIntVal != '10')
				strIntVal = "";
		}
			
		eval('document.'+strFormName+'.'+strFieldNameToValidate+'.value="'+strIntVal+'"');
	}

	//called for add or edit and delete.
	function ReloadParentWnd() {
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
	
		if(document.form_.close_wnd_called.value == "0") 
			window.opener.RefreshPage();
	}
	
	function CancelOperation(){
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.info_index.value = "";
		document.form_.submit();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this rate information?'))
				return;
		}
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function FocusField(){
		document.form_.rate_desc.focus();
	}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null; 
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-PERFORMANCE EVALUATION MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
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
			"Admin/staff-HR Management-Performance Evaluation Management-Quarterly Evaluation","update_other_rates.jsp");
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
	
	String strUserIndex = WI.fillTextValue("user_index");
	String strRPIndex = WI.fillTextValue("rp_index");
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo = null;
	Vector vRetResult = null;
	
	GovtEvaluation eval = new GovtEvaluation();
	
	strTemp = WI.fillTextValue("page_action");	
	if(strTemp.length() > 0) {
		if(eval.operateOnOtherCFRAtes(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = eval.getErrMsg();
		else {
			if(strTemp.equals("0"))
				strErrMsg = "Rate information successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Rate information successfully added.";
			if(strTemp.equals("2"))
				strErrMsg = "Rate information successfully edited.";
			
			strPrepareToEdit = "0";
		}
	}

	vRetResult = eval.operateOnOtherCFRAtes(dbOP, request, 4);
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = eval.operateOnOtherCFRAtes(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = eval.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="FocusField();" onUnload="ReloadParentWnd();">
<form action="update_other_rates.jsp" method="post" name="form_">

	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: OTHER RATES ENCODING ::::</strong></font></td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Desc.:</td>
	        <td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("rate_desc");
				%>
				<input name="rate_desc" type="text" size="64" value="<%=strTemp%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="128"></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Rate:</td>
			<td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(2);
					else
						strTemp = WI.fillTextValue("rate");
				%>
				<input type="text" name="rate" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyGovtRating('form_','rate', '0');style.backgroundColor='white'" 
					onkeyup="AllowOnlyGovtRating('form_','rate', '1')" size="5" maxlength="4" 
					value="<%=strTemp%>"/></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.fillTextValue("is_supervisor");
						
					if(strTemp.equals("1"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input name="is_supervisor" type="checkbox" value="1" <%=strTemp%>>
				<font size="1">Check if supervisor, else employee.</font></td>
		</tr>
		<tr>
			<td height="40" colspan="2" valign="middle">&nbsp;</td>
		    <td>
				<%if(iAccessLevel > 1){
					if(strPrepareToEdit.equals("0")) {%>
						<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<%}else {
						if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
							<img src="../../../images/edit.gif" border="0"></a>
						<%}
					}%>
					<a href="javascript:CancelOperation();"><img src="../../../images/cancel.gif" border="0"></a>
				<%}else{%>
					Not authorized to save other rate information.
				<%}%></td>
	    </tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="6" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>LIST OF OTHER RATES</strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="45%" align="center" class="thinborder"><strong>Description</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Rate</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Supervisor</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Employee</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 4, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+3);
			%>
			<td align="center" class="thinborder">
				<%if(strTemp.equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
			<td align="center" class="thinborder">
				<%if(strTemp.equals("0")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
			<td align="center" class="thinborder">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
							<img src="../../../images/delete.gif" border="0"></a>
					<%}
				}else{%>
					N/A
				<%}%></td>
		</tr>
	<%}%>
	</table>
<%}%>
			
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="1" height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#0D3371">
			<td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>">  	
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
	<input type="hidden" name="user_index" value="<%=strUserIndex%>">
	<input type="hidden" name="rp_index" value="<%=strRPIndex%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
