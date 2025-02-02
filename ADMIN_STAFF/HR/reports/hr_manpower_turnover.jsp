<%@ page language="java" import="utility.*,java.util.Vector,hr.HRStatsReports" %>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Manpower Turnover</title>
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
	
	function ShowManpower(){
		document.form_.show_rate.value = "1";
		document.form_.submit();
	}
	
</script>
<body bgcolor="#C39E60" marginheight="0" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-HR Manpower Turnover","hr_manpower_turnover.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"HR Management","REPORTS AND STATISTICS",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) 
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Executive Management System","ENROLLMENT",request.getRemoteAddr(),
														null);
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	Vector vRetResult = null;
	HRStatsReports stats = new HRStatsReports(request);
	if(WI.fillTextValue("show_rate").length() > 0){
		vRetResult = stats.getTurnoverRate(dbOP, request);
		if(vRetResult == null)
			strErrMsg = stats.getErrMsg();
	}
%>
<form action="./hr_manpower_turnover.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center">
				<font color="#FFFFFF"><strong>:::: MANPOWER TURNOVER RATE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Separation Date:</td>
			<td width="80%">
				<input name="date_from" type="text" size="16" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_from")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp;
				<a href="javascript:show_calendar('form_.date_from');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
				-
				<input name="date_to" type="text" size="16" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp;
				<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Cutoff Date: </td>
			<td>
				<input name="cutoff_date" type="text" size="16" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("cutoff_date")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp;
				<a href="javascript:show_calendar('form_.cutoff_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
	  	</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td><a href="javascript:ShowManpower();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to show manpower turnover rate.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
		<tr>
			<td height="15" colspan="3"><hr size="1"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Total Resigned: </td>
		    <td><strong><%=(String)vRetResult.elementAt(0)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Total Manpower: </td>
		    <td><strong><%=(String)vRetResult.elementAt(1)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Manpower Turnover Rate: </td>
		    <td><strong><%=(String)vRetResult.elementAt(2)%>%</strong></td>
		</tr>
	<%}%>
	</table>
				
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="show_rate">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>