<%@ page language="java" import="utility.*,java.util.Vector, hr.HRLighthouse" %>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Create Review Period</title>
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
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
	
	function PrepareToEdit(index){
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = index;
		document.form_.submit();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this review period?'))
				return;
		}
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function CancelRecord(){
		location ="./create_review_period.jsp";
	}
	
	function FocusField(){
		document.form_.rp_title.focus();
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
			"Admin/staff-HR Management-Performance Evaluation Management-Create Review Period","create_review_period.jsp");
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
	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	
	String[] astrMonth = {"January", "February", "March", "April", "May", "June", "July", 
						"August", "September", "October", "November", "December"};
	
	String strPrepareToEdit =  WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	HRLighthouse hrl = new HRLighthouse();

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(hrl.operateOnReviewPeriod(dbOP, request, Integer.parseInt(strTemp)) == null){
			strErrMsg = hrl.getErrMsg();

		} else {
			if(strTemp.equals("0"))
				strErrMsg = " Review Period removed successfully";
			if(strTemp.equals("1"))
				strErrMsg = " Review Period recorded successfully";
			if(strTemp.equals("2"))
				strErrMsg = " Review Period updated successfully";
				
			strPrepareToEdit = "0";
		}
	}
	
	vRetResult = hrl.operateOnReviewPeriod(dbOP, request, 4);
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = hrl.operateOnReviewPeriod(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = hrl.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="FocusField();">
<form action="create_review_period.jsp" method="post" name="form_">

	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: REVIEW PERIOD MANAGEMENT PAGE ::::</strong></font>			</td>
		</tr>
		<tr>
			<td height="10" colspan="2">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="22%">Title: </td>
			<td width="75%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("rp_title");
				%>
				<textarea name="rp_title" style="font-size:12px" cols="60" rows="2" 
					onFocus="style.backgroundColor='#D3EBFF'" class="textbox" 
					onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Evaluation Date From: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(2);
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
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Evaluation Date To: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else{
						strTemp = WI.fillTextValue("date_to");
						if(strTemp.length() == 0) 
							strTemp = WI.getTodaysDate(1);
					}
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
			<td>Review Date </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(4);
					else
						strTemp = WI.getStrValue(WI.fillTextValue("r_month"), "0");
				%>
				<select name="r_month">
					<%for(int i = 0; i < 12; i++){
						if(strTemp.equals(Integer.toString(i)))
							strErrMsg = "selected";
						else
							strErrMsg = "";
					%>
						<option value="<%=i%>" <%=strErrMsg%>><%=astrMonth[i]%></option>
					<%}%>
				</select>
				&nbsp;
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("r_year");
				%>
				<select name="r_year">
					<%=dbOP.loadComboYear(strTemp, 2, 2)%>
				</select>
			</td>
		</tr>
	</table>
			
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="25%" height="25">&nbsp;</td>
			<td width="75%">
			<%if (iAccessLevel > 1){
				if (vEditInfo  == null){%>        
					<a href="javascript:PageAction('1','');">
						<img src="../../../images/save.gif" border="0" name="hide_save"></a> 
					<font size="1">click to save entry </font> 
				<%}else{ %>        
					<a href="javascript:PageAction('2','<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a> 
					<font size="1">click to save changes</font>
				<%}// end else vEdit Info == null%> 
				
				<a href="javascript:CancelRecord();">
					<img src="../../../images/refresh.gif" border="0"></a>
				<font size="1">click to cancel and clear entries</font> 
			<%}%><td>
		</tr> 
		<tr>
			<td height="20" colspan="2">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr bgcolor="#B9B292">
			<td height="28" colspan="5" align="center" class="thinborder">
				<strong>::: LIST OF REVIEW PERIODS CREATED ::: </strong></td>
		</tr>
		<tr>
			<td height="25" width="7%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="32%" align="center" class="thinborder"><strong>Title</strong></td>
			<td width="23%" align="center" class="thinborder"><strong>Evaluation Period</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Review Period</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%
	int iCount = 1;
	for(int i = 0; i < vRetResult.size(); i += 8, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">
				<%=WI.formatDate((String)vRetResult.elementAt(i+2), 6)%> - <br>
				<%=WI.formatDate((String)vRetResult.elementAt(i+3), 6)%></td>
			<td class="thinborder">
				<%=astrMonth[Integer.parseInt((String)vRetResult.elementAt(i+4))]%> <%=(String)vRetResult.elementAt(i+5)%></td>
			<td align="center" class="thinborder">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/edit.gif" border="0"></a>
				<%if(iAccessLevel == 2){%>
					<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/delete.gif" border="0"></a>
				<%}
			}else{%>
				No edit/delete privileges.
			<%}%>			</td>
		</tr>
	<%}%>
	</table>
<%}//if vRetResult is not null%>
			
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

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>