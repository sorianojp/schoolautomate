<%@ page language="java" import="utility.*,iCafe.CafeReports,java.util.Vector "%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">

	function GoBack(){
		location = "../iL_users_per_hour_main.jsp";
	}
	
	function GenerateReport(){
		document.form_.generate_report.value = "1";
		document.form_.submit();
	}
	
</script>
<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Internet Cafe Management-INTERNET LAB OPERATION",
								"iL_users_per_hour.jsp");
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
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Internet Cafe Management",
															"INTERNET LAB OPERATION",request.getRemoteAddr(),
															"iL_users_per_hour.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}	
	//end of authenticaion code.
	
	String[] astrTime = {"12MN", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12NN", "1 PM", "2 PM", 
						"3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM", };
	
	Vector vRetResult = null;
	CafeReports cr = new CafeReports();
	if(WI.fillTextValue("generate_report").length() > 0){
		vRetResult = cr.getDailyUsageReport(dbOP, request);
		if(vRetResult == null)
			strErrMsg = cr.getErrMsg();
	}
%>
<form action="iL_users_per_hour.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3"><div align="center"><font color="#FFFFFF">
				<strong>:::: DAILY ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp; </td>
			<td width="87%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		    <td width="10%" align="right"><a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0"></a></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Location: </td>
			<td width="80%">
				<select name="location_index">
					<option value="">Select Location</option>
					 <%=dbOP.loadCombo("location_index","location"," from ic_comp_loc order by location", WI.fillTextValue("location_index"), false)%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Date: </td>
			<td>
				<input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a>
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Time Range: </td>
			<td>
				<%
					strTemp = WI.fillTextValue("time_fr");
				%>
				<select name="time_fr">
				<%if(strTemp.equals("6")){%>
					<option value="6" selected>6 AM</option>
				<%}else{%>
					<option value="6">6 AM</option>					
				<%}if(strTemp.length() == 0 || strTemp.equals("7")){%>
					<option value="7" selected>7 AM</option>
				<%}else{%>
					<option value="7">7 AM</option>
				<%}if(strTemp.equals("8")){%>
					<option value="8" selected>8 AM</option>
				<%}else{%>
					<option value="8">8 AM</option>
				<%}if(strTemp.equals("9")){%>
					<option value="9" selected>9 AM</option>
				<%}else{%>
					<option value="9">9 AM</option>
				<%}if(strTemp.equals("10")){%>
					<option value="10" selected>10 AM</option>
				<%}else{%>
					<option value="10">10 AM</option>					
				<%}if(strTemp.equals("11")){%>
					<option value="11" selected>11 AM</option>
				<%}else{%>
					<option value="11">11 AM</option>					
				<%}if(strTemp.equals("12")){%>
					<option value="12" selected>12 NN</option>
				<%}else{%>
					<option value="12">12 NN</option>
				<%}if(strTemp.equals("13")){%>
					<option value="13" selected>1 PM</option>
				<%}else{%>
					<option value="13">1 PM</option>
				<%}if(strTemp.equals("14")){%>
					<option value="14" selected>2 PM</option>
				<%}else{%>
					<option value="14">2 PM</option>
				<%}if(strTemp.equals("15")){%>
					<option value="15" selected>3 PM</option>
				<%}else{%>
					<option value="15">3 PM</option>
				<%}if(strTemp.equals("16")){%>
					<option value="16" selected>4 PM</option>
				<%}else{%>
					<option value="16">4 PM</option>
				<%}if(strTemp.equals("17")){%>
					<option value="17" selected>5 PM</option>
				<%}else{%>
					<option value="17">5 PM</option>
				<%}if(strTemp.equals("18")){%>
					<option value="18" selected>6 PM</option>
				<%}else{%>
					<option value="18">6 PM</option>
				<%}if(strTemp.equals("19")){%>
					<option value="19" selected>7 PM</option>
				<%}else{%>
					<option value="19">7 PM</option>
				<%}if(strTemp.equals("20")){%>
					<option value="20" selected>8 PM</option>
				<%}else{%>
					<option value="20">8 PM</option>
				<%}if(strTemp.equals("21")){%>
					<option value="21" selected>9 PM</option>
				<%}else{%>
					<option value="21">9 PM</option>
				<%}%>
				</select>
				&nbsp;to&nbsp;
				<%
					strTemp = WI.fillTextValue("time_to");
				%>
				<select name="time_to">
				<%if(strTemp.equals("6")){%>
					<option value="6" selected>6 AM</option>
				<%}else{%>
					<option value="6">6 AM</option>					
				<%}if(strTemp.equals("7")){%>
					<option value="7" selected>7 AM</option>
				<%}else{%>
					<option value="7">7 AM</option>
				<%}if(strTemp.equals("8")){%>
					<option value="8" selected>8 AM</option>
				<%}else{%>
					<option value="8">8 AM</option>
				<%}if(strTemp.equals("9")){%>
					<option value="9" selected>9 AM</option>
				<%}else{%>
					<option value="9">9 AM</option>
				<%}if(strTemp.equals("10")){%>
					<option value="10" selected>10 AM</option>
				<%}else{%>
					<option value="10">10 AM</option>					
				<%}if(strTemp.equals("11")){%>
					<option value="11" selected>11 AM</option>
				<%}else{%>
					<option value="11">11 AM</option>					
				<%}if(strTemp.equals("12")){%>
					<option value="12" selected>12 NN</option>
				<%}else{%>
					<option value="12">12 NN</option>
				<%}if(strTemp.equals("13")){%>
					<option value="13" selected>1 PM</option>
				<%}else{%>
					<option value="13">1 PM</option>
				<%}if(strTemp.equals("14")){%>
					<option value="14" selected>2 PM</option>
				<%}else{%>
					<option value="14">2 PM</option>
				<%}if(strTemp.equals("15")){%>
					<option value="15" selected>3 PM</option>
				<%}else{%>
					<option value="15">3 PM</option>
				<%}if(strTemp.equals("16")){%>
					<option value="16" selected>4 PM</option>
				<%}else{%>
					<option value="16">4 PM</option>
				<%}if(strTemp.length() == 0 || strTemp.equals("17")){%>
					<option value="17" selected>5 PM</option>
				<%}else{%>
					<option value="17">5 PM</option>
				<%}if(strTemp.equals("18")){%>
					<option value="18" selected>6 PM</option>
				<%}else{%>
					<option value="18">6 PM</option>
				<%}if(strTemp.equals("19")){%>
					<option value="19" selected>7 PM</option>
				<%}else{%>
					<option value="19">7 PM</option>
				<%}if(strTemp.equals("20")){%>
					<option value="20" selected>8 PM</option>
				<%}else{%>
					<option value="20">8 PM</option>
				<%}if(strTemp.equals("21")){%>
					<option value="21" selected>9 PM</option>
				<%}else{%>
					<option value="21">9 PM</option>
				<%}%>
				</select>
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>View Options: </td>
			<td>
				<%
					strErrMsg = WI.getStrValue(WI.fillTextValue("view_option"), "0");
					if(strErrMsg.equals("0"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input name="view_option" type="radio" value="0" <%=strTemp%>>View All
				<%
					if(strErrMsg.equals("1"))
						strTemp = "checked";
					else
						strTemp = "";
				%> 
				<input name="view_option" type="radio" value="1" <%=strTemp%>>Student Usage Only
				<%
					if(strErrMsg.equals("2"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input name="view_option" type="radio" value="2" <%=strTemp%>>Faculty Usage Only
		</tr>
		<tr>
			<td height="40" colspan="2">&nbsp;</td>
			<td><a href="javascript:GenerateReport();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to generate users per hour report.</font></td>
		</tr>
	</table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
			<td height="20" colspan="2" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: USERS PER HOUR LISTING ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="50%" align="center" class="thinborder"><strong>Time</strong></td>
			<td width="50%" align="center" class="thinborder"><strong>User Count</strong></td>
		</tr>
	<%	int iTotal = 0;
		for(int i = 0; i < vRetResult.size(); i += 3){
			iTotal += Integer.parseInt((String)vRetResult.elementAt(i+2));
	%>
		<tr>
			<td height="25" align="center" class="thinborder">
				<%=astrTime[Integer.parseInt((String)vRetResult.elementAt(i))]%> - <%=astrTime[Integer.parseInt((String)vRetResult.elementAt(i+1))]%></td>
			<td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
		</tr>
	<%}%>
		<tr>
			<td height="25" align="center" class="thinborder"><strong>Total</strong></td>
			<td align="center" class="thinborder"><%=iTotal%></td>
		</tr>
	</table>
<%}%>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="generate_report">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>