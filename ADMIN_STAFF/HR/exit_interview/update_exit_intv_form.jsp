<%@ page language="java" import="utility.*,hr.HRLighthouse,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
		
	String strExitIntvIndex = WI.fillTextValue("exit_intv_index");
	String strReadOnly = WI.fillTextValue("read_only");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Exit Interview Form</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
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
<script language="javascript" src="../../../jscript/td.js"></script>
<script language="javascript">

	function UpdateExitIntvForm(){
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.update_exit_intv_form.value = "1";
		document.form_.submit();
	}
	
	//called for add or edit and delete.
	function ReloadParentWnd() {
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
	
		if(document.form_.close_wnd_called.value == "0") 
			window.opener.ReloadPage();
	}
		
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;	
	
	if(strExitIntvIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Resignation reference is not found. Please close this window and click update link again..</p>
		<%return;
	}

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-EXIT INTERVIEW MANAGEMENT"),"0"));
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
	
	if (bolMyHome)
		iAccessLevel = 1;
	
	if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"my_home","update_exit_intv_main.jsp");
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
	
	String strLocation = null;
	Vector vRetResult = null;	
	HRLighthouse hrl = new HRLighthouse();
	
	if(WI.fillTextValue("update_exit_intv_form").length() > 0){
		if(hrl.operateOnExitInterviewData(dbOP, request, 2) == null)
			strErrMsg = hrl.getErrMsg();
		else
			strErrMsg = "Exit Interview Form updated successfully.";
	}
	
	vRetResult =  hrl.operateOnExitInterviewData(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = hrl.getErrMsg();
%>
<body bgcolor="#D2AE72" class="bgDynamic" onUnload="ReloadParentWnd();">
<form name="form_" action="./update_exit_intv_form.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A" class="footerDynamic">
			<%
			if(strReadOnly.length() == 0)
				strTemp = ":::: UPDATE EXIT INTERVIEW FORMS ::::";
			else
				strTemp = ":::: EMPLOYEE EXIT INTERVIEW FORM ::::";
			%>
			<td height="25" colspan="2" align="center" bgcolor="#A49A6A" class="footerDynamic">
			<font color="#FFFFFF" ><strong><%=strTemp%></strong></font></td>
		</tr>
		<tr>
			<td height="25" width="5%">&nbsp;</td>
	        <td width="95%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="5%">&nbsp;</td>
			<td width="20%">Name: </td>
			<td width="30%" class="thinborderBOTTOM"><strong><%=(String)vRetResult.elementAt(0)%></strong></td>
			<td width="45%">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Position:</td>
			<td class="thinborderBOTTOM"><strong><%=(String)vRetResult.elementAt(1)%></strong></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Division:</td>
			<td class="thinborderBOTTOM"><strong><%=(String)vRetResult.elementAt(2)%></strong></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Department:</td>
			<td class="thinborderBOTTOM"><strong><%=(String)vRetResult.elementAt(3)%></strong></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Length of Service: </td>
			<td class="thinborderBOTTOM">
				<%
					strTemp = (String)vRetResult.elementAt(4);
					if(strTemp.equals("0"))
						strTemp = "";
					else
						strTemp = strTemp + "years ";
						
					strTemp += (String)vRetResult.elementAt(5) + " months ";
				%>
				<strong><%=strTemp%></strong></td>
			<td>&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="20" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td width="5%" height="25">&nbsp;</td>
			<td colspan="2">
				1.) State at least two (2) reasons why you accepted the job offer at Lighthouse.</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><%=(String)vRetResult.elementAt(7)%></strong></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				2.) When you first started, what were your expectations?</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><%=(String)vRetResult.elementAt(8)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">Were these expectations met? Why or why not?</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><%=(String)vRetResult.elementAt(9)%></strong></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				3.) In your stint with LSCI, are you generally satisfied with your work (in terms of nature of work, 
				career path, relationship with peers and immediate superior, etc)? Why or why not?</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><%=(String)vRetResult.elementAt(10)%></strong></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				4.) Looking at your own team, what could be its strengths? Weaknesses?</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><%=(String)vRetResult.elementAt(11)%></strong></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				5.) In a scale of 1 to 5 (with 5 as the highest), how would you rate the LSCI organization
				as a whole? Explain your rating.</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">Rating: <strong><%=(String)vRetResult.elementAt(13)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><%=(String)vRetResult.elementAt(12)%></strong></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				6.) In a scale of 1 to 5 (with 5 as the highest), rate your satisfaction level of the following:</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="40%">Cash Compensation: <strong><%=(String)vRetResult.elementAt(14)%></strong></td>
		    <td width="65%">Employee Relations & Communications Program: <strong><%=(String)vRetResult.elementAt(19)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="40%">Policies and Procedures: <strong><%=(String)vRetResult.elementAt(15)%></strong></td>
		    <td width="65%">Benefit Package: <strong><%=(String)vRetResult.elementAt(20)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="40%">Management Style: <strong><%=(String)vRetResult.elementAt(16)%></strong></td>
		    <td width="65%">Career Opportunity: <strong><%=(String)vRetResult.elementAt(21)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="40%">Performance Review/ Appraisal: <strong><%=(String)vRetResult.elementAt(17)%></strong></td>
		    <td width="65%">Rewards & Recognition Program: <strong><%=(String)vRetResult.elementAt(22)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">Work Environment / Culture: <strong><%=(String)vRetResult.elementAt(18)%></strong></td>
	    </tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				7.) What  would you recommend to LSCI, or the HR Department, or your own  department for its  improvement?</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><%=(String)vRetResult.elementAt(23)%></strong></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				8.) Would you consider working for LSCI again? 
				<%
					strTemp = (String)vRetResult.elementAt(25);
					if(strTemp.equals("1"))
						strTemp = "YES";
					else
						strTemp = "NO";
				%>
				<strong><%=strTemp%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				Why?</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><%=(String)vRetResult.elementAt(24)%></strong></td>
		</tr>
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
	<%
	if(hrl.isExitInterviewDataCompleted(dbOP, request, WI.fillTextValue("exit_intv_index")))
		strReadOnly = "1";
	
	if(strReadOnly.length() == 0){%>
		<tr>
			<td height="15" colspan="3"><hr size="1"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td height="25" colspan="2">Qualified for Re-hire? 
				<%
					if(WI.fillTextValue("is_rehirable").length() == 0 || WI.fillTextValue("is_rehirable").equals("1"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input name="is_rehirable" type="radio" value="1" <%=strTemp%>>Yes
				
				<%
					if(WI.fillTextValue("is_rehirable").equals("0"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input name="is_rehirable" type="radio" value="0" <%=strTemp%>>No</td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td height="25" colspan="2">Remarks:</td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td colspan="2">
				<textarea name="remarks" style="font-size:12px" cols="90" rows="2" 
					onFocus="style.backgroundColor='#D3EBFF'" class="textbox" 
					onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("remarks")%></textarea></td>
	    </tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" align="center">
				<a href="javascript:UpdateExitIntvForm();"><img src="../../../images/update.gif" border="0"></a></td>
		</tr>
	<%}else{
		Vector vHRDetails = hrl.getExitIntvHRDetails(dbOP, request, strExitIntvIndex);%>
		<tr>
			<td height="15" colspan="3"><hr size="1"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<%
				strTemp = (String)vHRDetails.elementAt(0);
				if(strTemp.equals("0"))
					strErrMsg = (String)vHRDetails.elementAt(1);
				else{
					strTemp = (String)vHRDetails.elementAt(1);
					if(strTemp.equals("0"))
						strErrMsg = "NO.";
					else
						strErrMsg = "YES.";
				}
			%>
		    <td height="25" colspan="2">Qualified for Re-hire? <strong><%=strErrMsg%></strong>			
		</td>
		<tr>
			<td height="25">&nbsp;</td>
		    <td height="25" colspan="2">Remarks:</td>
	    </tr>
		<tr>
			<td height="40">&nbsp;</td>
	      	<td colspan="2" valign="top"><strong><%=WI.getStrValue((String)vHRDetails.elementAt(2), "&nbsp;")%></strong></td>
	    </tr>
	<%}%>
	</table>
<%}%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A" class="footerDynamic"> 
			<td width="1%" height="25">&nbsp;</td>
		</tr>
	</table>

	<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
	<input type="hidden" name="exit_intv_index" value="<%=strExitIntvIndex%>">
	<input type="hidden" name="update_exit_intv_form">
	
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>"> 
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
	<input type="hidden" name="read_only" value="<%=strReadOnly%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>