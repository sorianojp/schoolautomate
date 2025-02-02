<%@ page language="java" import="utility.*, hr.HRInsuranceTracking, java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Insurance Details</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
//called for add or edit and delete.
function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length > 0)
		return;

	if(document.form_.close_wnd_called.value == "0") 
		window.opener.ReloadPage();
}

function PageAction(strAction, strInfoIndex) {
	document.form_.donot_call_close_wnd.value = "1";
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete this insurance information?'))
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
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

function RefreshPage() {
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.prepareToEdit.value='';
	document.form_.amount.value = "";
	document.form_.note.value = "";	
	location = "./health_insurance_dtls_update.jsp?insurance_index="+document.form_.insurance_index.value;
}

function ReloadPage(){
	document.form_.reloadPage.value = "1";
	document.form_.submit();
}

</script>
<body onLoad="document.form_.amount.focus()" onUnload="ReloadParentWnd();">
<%
	String strInsuranceIndex = WI.fillTextValue("insurance_index");	
	if(strInsuranceIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Insurance reference is not found. Please close this window and click update  link again from update insurance window.</p>
		<%return;
	}
	
	String strErrMsg = null;
	String strTemp   = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-PERSONNEL"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		if(bolIsSchool)
			request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		else
			request.getSession(false).setAttribute("go_home","../../../../index.jsp");
		
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	if(strAuthTypeIndex == null){
		request.getSession(false).setAttribute("go_home","../../../../index.jsp");
		request.getSession(false).setAttribute("errorMessage","You are not logged in. Please login to access this page.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Personnel-Health Insurance Details Update","health_insurance_dtsl_update.jsp");
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
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo  = null; 
	Vector vRetResult = null;

	HRInsuranceTracking hriTracker  = new HRInsuranceTracking();
	strTemp = WI.fillTextValue("page_action");
	
	if(strTemp.length() > 0) {
		if(hriTracker.operateOnInsuranceDetails(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = hriTracker.getErrMsg();
		else {
			if(strTemp.equals("0"))
				strErrMsg = "Insurance detail successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Insurance detail successfully added.";
			if(strTemp.equals("2"))
				strErrMsg = "Insurance detail successfully edited.";
			
			strPrepareToEdit = "0";
		}
	}

	vRetResult = hriTracker.operateOnInsuranceDetails(dbOP, request,4);	
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = hriTracker.operateOnInsuranceDetails(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = hriTracker.getErrMsg();
		
	}
%>

<form name="form_" method="post" action="health_insurance_dtls_update.jsp">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
		  	<td height="25" colspan="5" bgcolor="#488E7B" align="center"><font color="#FFFFFF" ><strong>:::: HEALTH INSURANCE DETAILS PAGE ::::</strong></font></td>
		</tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td colspan="2">&nbsp;</td>
        </tr>
		<tr>
			<td width="3%">&nbsp;</td>
	        <td><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
        </tr>
		<tr>
			<td colspan="2">&nbsp;</td>
        </tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td>Date Consumed </td>
			<td>
				<%
					//place here the index of vEditInfo that would serve as reference to the hriTracker date
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else{
						strTemp = WI.fillTextValue("date_fr");
						if(strTemp.length() == 0) 
							strTemp = WI.getTodaysDate(1);
					}
				%>
				<input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../../images/calendar_new.gif" border="0"></a>			</td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="20%">Amount</td>
			<td width="77%">
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(2);			
				else
					strTemp = WI.fillTextValue("amount");
				strTemp = CommonUtil.formatFloat(strTemp, true);
				if(strTemp.equals("0"))
					strTemp = "";
			%>
				<input type="text" name="amount" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','amount');style.backgroundColor='white'" 
					 onKeyUp="AllowOnlyFloat('form_','amount');">			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td height="25">Note</td>
			<td height="25">
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(4);
				else
					strTemp = WI.getStrValue(WI.fillTextValue("note"),"");
			%>
				<textarea name="note" style="font-size:12px" cols="65" rows="6" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>			</td>
		</tr>
		<tr>
			<td height="10" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td height="25">
			<%
			boolean isPrepareToEdit = strPrepareToEdit.equals("0");
			if(isPrepareToEdit && iAccessLevel > 1) {%>
				<a href="javascript:PageAction('1', '');"><img src="../../../../images/save.gif" border="0"></a>
			<%}if(!isPrepareToEdit && iAccessLevel > 1) {
				if(vEditInfo!=null){%>
					<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
					<img src="../../../../images/edit.gif" border="0"></a>
				<%}
			}%>
			<a href="javascript:RefreshPage();"><img src="../../../../images/refresh.gif" border="0"></a>			</td>
		</tr>
		<tr>
			<td height="10" colspan="3">&nbsp;</td>
		</tr>
	</table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
		<tr>
		  	<td height="25" colspan="4" align="center" bgcolor="#64B09B" class="thinborder" style="font-weight:bold"><font color="#000000">&nbsp;Consumption </font></td>
		</tr>
		<tr bgcolor="#FFFF99" style="font-weight:bold">
			<td height="25" class="thinborder" width="20%" align="center">Date Consumed </td>
			<td class="thinborder" width="20%" align="center">Amount</td>
			<td class="thinborder" width="40%" align="center">Note</td>
			<td class="thinborder" width="20%" align="center">Options</td>
		</tr>
		<%for(int i=0; i<vRetResult.size(); i+=5){%>
		<tr>
			<td height="25" class="thinborder"><%=vRetResult.elementAt(i+3)%></td>
			<td class="thinborder"><%=CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(i + 2),""), true)%></td>
			<td class="thinborder"><%=vRetResult.elementAt(i+4)%></td>
			<td align="center" class="thinborder">
			<%if(iAccessLevel > 1){%>
		  		<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../../images/edit.gif" border="0"></a>&nbsp;	&nbsp;	&nbsp;		  
		  	<%}
			if(iAccessLevel == 2){%>
				<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../../images/delete.gif" border="0"></a></td>
	    	<%}%>&nbsp;
		</tr>
		<%}%>
	<%}%>
  	</table>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#488E7B">&nbsp;</td>
		</tr>
	</table>

	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="insurance_index" value="<%=strInsuranceIndex%>">
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>">  	
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
	<input type="hidden" name="reloadPage" value="0">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>