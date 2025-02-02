<%@ page language="java" import="utility.*,hr.HRLighthouse,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Health Insurance Tracking</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../jscript/td.js"></script>
<script language="javascript">
	
	function SendExitForm(){
		document.form_.send_exit_form.value = "1";
		document.form_.submit();
	}
	
	function FocusField(){
		document.form_.Q1.focus();
	}
	
</script>
</head>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	Vector vEmpRec = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-MEMO"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	
	if(bolMyHome)
		iAccessLevel = 1;
	
	if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"my_home","lhs_exit_intv_form.jsp");
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
	
	strTemp = (String)request.getSession(false).getAttribute("userId");
	
	if(strTemp.length() == 0)
		strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
	else	
		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
		
	strTemp = WI.getStrValue(strTemp);

	if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0) 	
		request.setAttribute("emp_id",strTemp);
	
	enrollment.Authentication authentication = new enrollment.Authentication();
	vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	
	if(vEmpRec == null)
		strErrMsg = authentication.getErrMsg();
	
	HRLighthouse hrl = new HRLighthouse();
	if(WI.fillTextValue("send_exit_form").length() > 0){
		if(!hrl.sendExitIntvForm(dbOP, request, (String)vEmpRec.elementAt(6)))
			strErrMsg = hrl.getErrMsg();
		else
			strErrMsg = "Exit Interview Form Successfully Submitted.";
	}

%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="FocusField();">
<form name="form_" action="lhs_exit_intv_form.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A" class="footerDynamic">
			<td height="25" colspan="2" bgcolor="#A49A6A" align="center" class="footerDynamic">
				<font color="#FFFFFF"><strong>:::: EXIT INTERVIEW FORM ::::</strong></font></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td width="5%" height="25">&nbsp;</td>
			<td width="95%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="5%">&nbsp;</td>
			<td width="20%">Name: </td>
			<td width="30%" class="thinborderBOTTOM"><%=WebInterface.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3), 4)%></td>
			<td width="45%">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Position:</td>
			<td class="thinborderBOTTOM"><%=WI.getStrValue((String)vEmpRec.elementAt(14),"&nbsp;")%></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Department:</td>
			<td class="thinborderBOTTOM"><%=WI.getStrValue((String)vEmpRec.elementAt(15),"&nbsp;")%></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Length of Service: </td>
			<td class="thinborderBOTTOM"><%=new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></td>
			<td>&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" width="5%">&nbsp;</td>
			<td colspan="2">Instructions: </td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">Please answer the following questions honestly. All information gathered will be kept confidential.</td>
		</tr>
		<tr>
			<td height="20" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				1.) State at least two (2) reasons why you accepted the job offer at Lighthouse.</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td colspan="2">
				<textarea name="Q1" style="font-size:12px" cols="90" rows="2" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("Q1")%></textarea></td>
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
			<td>&nbsp;</td>
			<td colspan="2">
				<textarea name="Q2_1" style="font-size:12px" cols="90" rows="2" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("Q2_1")%></textarea></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">Were these expectations met? Why or why not?</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td colspan="2">
				<textarea name="Q2_2" style="font-size:12px" cols="90" rows="2" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("Q2_2")%></textarea></td>
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
			<td>&nbsp;</td>
			<td colspan="2">
				<textarea name="Q3" style="font-size:12px" cols="90" rows="2" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("Q3")%></textarea></td>
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
			<td>&nbsp;</td>
			<td colspan="2">
				<textarea name="Q4" style="font-size:12px" cols="90" rows="2" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("Q4")%></textarea></td>
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
			<td colspan="2">
				<%
					
					if(WI.fillTextValue("Q5_RATING").length() == 0 || WI.fillTextValue("Q5_RATING").equals("1"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input name="Q5_RATING" type="radio" value="1" <%=strTemp%>>1
				
				<%
					if(WI.fillTextValue("Q5_RATING").equals("2"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input name="Q5_RATING" type="radio" value="2" <%=strTemp%>>2
				
				<%
					if(WI.fillTextValue("Q5_RATING").equals("3"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input name="Q5_RATING" type="radio" value="3" <%=strTemp%>>3
				
				<%
					if(WI.fillTextValue("Q5_RATING").equals("4"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input name="Q5_RATING" type="radio" value="4" <%=strTemp%>>4
				
				<%
					if(WI.fillTextValue("Q5_RATING").equals("5"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input name="Q5_RATING" type="radio" value="5" <%=strTemp%>>5	</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td colspan="2">
				<textarea name="Q5" style="font-size:12px" cols="90" rows="2" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("Q5")%></textarea></td>
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
			<td width="40%">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("Q6_1"), "1");
				%>
				<select name="Q6_1">
					<%for(int i = 1; i < 6; i++){
						if(strTemp.equals(Integer.toString(i)))
							strErrMsg = "selected";
						else
							strErrMsg = "";
					%>
						<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
					<%}%>	
				</select>&nbsp;
				Cash Compensation</td>
		    <td width="55%">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("Q6_6"), "1");
				%>
				<select name="Q6_6">
					<%for(int i = 1; i < 6; i++){
						if(strTemp.equals(Integer.toString(i)))
							strErrMsg = "selected";
						else
							strErrMsg = "";
					%>
						<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
					<%}%>
				</select>&nbsp;
				Employee Relations & Communications Program</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="30%">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("Q6_2"), "1");
				%>
				<select name="Q6_2">
					<%for(int i = 1; i < 6; i++){
						if(strTemp.equals(Integer.toString(i)))
							strErrMsg = "selected";
						else
							strErrMsg = "";
					%>
						<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
					<%}%>
				</select>&nbsp;
				Policies and Procedures </td>
		    <td width="65%">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("Q6_7"), "1");
				%>
				<select name="Q6_7">
					<%for(int i = 1; i < 6; i++){
						if(strTemp.equals(Integer.toString(i)))
							strErrMsg = "selected";
						else
							strErrMsg = "";
					%>
						<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
					<%}%>
				</select>&nbsp;
				Benefit Package</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="30%">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("Q6_3"), "1");
				%>
				<select name="Q6_3">
					<%for(int i = 1; i < 6; i++){
						if(strTemp.equals(Integer.toString(i)))
							strErrMsg = "selected";
						else
							strErrMsg = "";
					%>
						<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
					<%}%>
				</select>&nbsp;
				Management Style</td>
		    <td width="65%">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("Q6_8"), "1");
				%>
				<select name="Q6_8">
					<%for(int i = 1; i < 6; i++){
						if(strTemp.equals(Integer.toString(i)))
							strErrMsg = "selected";
						else
							strErrMsg = "";
					%>
						<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
					<%}%>
				</select>&nbsp;
				Career Opportunity</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="30%">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("Q6_4"), "1");
				%>
				<select name="Q6_4">
					<%for(int i = 1; i < 6; i++){
						if(strTemp.equals(Integer.toString(i)))
							strErrMsg = "selected";
						else
							strErrMsg = "";
					%>
						<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
					<%}%>
				</select>&nbsp;
				Performance Review/ Appraisal</td>
		    <td width="65%">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("Q6_9"), "1");
				%>
				<select name="Q6_9">
					<%for(int i = 1; i < 6; i++){
						if(strTemp.equals(Integer.toString(i)))
							strErrMsg = "selected";
						else
							strErrMsg = "";
					%>
						<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
					<%}%>
				</select>&nbsp;
				Rewards & Recognition Program</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("Q6_5"), "1");
				%>
				<select name="Q6_5">
					<%for(int i = 1; i < 6; i++){
						if(strTemp.equals(Integer.toString(i)))
							strErrMsg = "selected";
						else
							strErrMsg = "";
					%>
						<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
					<%}%>
				</select>&nbsp;
				Work Environment / Culture</td>
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
			<td>&nbsp;</td>
			<td colspan="2">
				<textarea name="Q7" style="font-size:12px" cols="90" rows="2" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("Q7")%></textarea></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				8.) Would you consider working for LSCI again?
				
				<%
					if(WI.fillTextValue("Q8_YESNO").length() == 0 || WI.fillTextValue("Q8_YESNO").equals("1"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input name="Q8_YESNO" type="radio" value="1" <%=strTemp%>>
				Yes
				
				<%
					if(WI.fillTextValue("Q8_YESNO").equals("0"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input name="Q8_YESNO" type="radio" value="0" <%=strTemp%>>
				No</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				Why?</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td colspan="2">
				<textarea name="Q8" style="font-size:12px" cols="90" rows="2" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("Q8")%></textarea></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><div align="justify">
				Thank you for your time and effort in answering these questions. Be assured that your
				answers will be kept confidential, and may be referred to by select 
				HR personnel in the implementation of new policies and procedures.</div></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	<%if(hrl.hasNotSentExitIntvForm(dbOP, (String)vEmpRec.elementAt(0))){%>
		<tr>
			<td height="25" colspan="3" align="center">
				<a href="javascript:SendExitForm();"><img src="../../images/save.gif" border="0"></a>
				<font size="1">Click to send exit interview form.</font></td>
		</tr>
	<%}%>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A" class="footerDynamic"> 
			<td width="1%" height="25">&nbsp;</td>
		</tr>
	</table>

	<input type="hidden" name="send_exit_form">
	<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>