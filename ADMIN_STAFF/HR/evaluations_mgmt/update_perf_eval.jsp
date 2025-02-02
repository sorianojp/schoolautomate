<%@ page language="java" import="utility.*,hr.HRLighthouse,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String strPerfEvalMainIndex = WI.fillTextValue("perf_eval_main_index");
	String strReadOnly = WI.fillTextValue("read_only");
	String strOpnerFormName = WI.fillTextValue("opner_form_name");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Performance Evaluation</title>
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

	function ReloadParentWnd() {
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
	
		if(document.form_.close_wnd_called.value == "0" && document.form_.opner_form_name.value.length > 0) 
			window.opener.ReloadPage();
	}

	function FinalizePerfReview(){
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.finalize_answers.value = "1";
		document.form_.submit();
	}

	function UpdatePerfEval(){
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.submit_answers.value = "1";
		document.form_.submit();
	}
	
	function GoBack(){
		location = "./pending_perf_evaluations.jsp?my_home=1";
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strSelfEvalMainIndex = null;
	
	HRLighthouse hrl = new HRLighthouse();
	
	if(strPerfEvalMainIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Reference index is missing. Please try again.</p>
		<%return;
	}
	
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
			"Admin/staff-HR Management-Performance Evaluation Management-Update Performance Evaluation","update_perf_eval.jsp");
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
	
	if(strPerfEvalMainIndex.equals("null")){
		strPerfEvalMainIndex = hrl.getPerfEvalMainIndex(dbOP, request);
		if(strPerfEvalMainIndex == null)
			strErrMsg = hrl.getErrMsg();
	}
	
	strSelfEvalMainIndex = hrl.getCorrespondingSEMI(dbOP, request, strPerfEvalMainIndex);
	if(strSelfEvalMainIndex == null)
		hrl.getErrMsg();
	
	Vector vEmpRec = null;
	Vector vRetResult = null;
	Vector vEmployeeInformation = null;
	Vector vRatings = null;
	Vector vPersonalEvaluation = null;
	
	if(WI.fillTextValue("submit_answers").length() > 0){
		if(!hrl.updatePerformanceEvaluationAnswers(dbOP, request, strPerfEvalMainIndex, false))
			strErrMsg = hrl.getErrMsg();
		else
			strErrMsg = "Performance evaluation form successfully updated.";
	}
	
	if(WI.fillTextValue("finalize_answers").length() > 0){
		if(!hrl.updatePerformanceEvaluationAnswers(dbOP, request, strPerfEvalMainIndex, true))
			strErrMsg = hrl.getErrMsg();
		else
			strErrMsg = "Performance evaluation form successfully reviewed.";
	}
	
	vEmployeeInformation = hrl.getEmpEvaluatedInfo(dbOP, request, strPerfEvalMainIndex);
	if(vEmployeeInformation == null)
		strErrMsg = hrl.getErrMsg();
	else{
		vRetResult = hrl.getAllQuestions(dbOP, request, "", strPerfEvalMainIndex);
		if(vRetResult == null)
			strErrMsg = hrl.getErrMsg();
			
		vRatings = hrl.getRatings(dbOP, request);
		if(vRatings == null)
			strErrMsg = hrl.getErrMsg();

		vPersonalEvaluation = hrl.getAllQuestions(dbOP, request, strSelfEvalMainIndex, "");
		if(vPersonalEvaluation == null)
			strErrMsg = hrl.getErrMsg();
	}
	
	boolean bolIsReviewed = hrl.isSelfEvalMainReviewd(dbOP, request);
	
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
	
%>
<body bgcolor="#D2AE72" class="bgDynamic" onUnload="ReloadParentWnd();">
<form name="form_" action="./update_perf_eval.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A" class="footerDynamic">
			<td height="25" colspan="3" bgcolor="#A49A6A" align="center" class="footerDynamic">
			<font color="#FFFFFF" ><strong>:::: PERFORMANCE REVIEW ::::</strong></font></td>
		</tr>

		<tr> 
			<td height="25" width="5%">&nbsp;</td>
			<td width="77%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
			<td width="18%" align="right">
			<%if(strReadOnly.length() == 0){%>
				<a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0"></a>
			<%}%></td>
		</tr>
	</table>

<%if(vEmployeeInformation != null && vEmployeeInformation.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" width="5%">&nbsp;</td>
		    <td width="10%">&nbsp;</td>
		    <td width="5%">&nbsp; </td>
		    <td width="12%">&nbsp;</td>
		    <td width="12%">&nbsp;</td>
		    <td width="38%">&nbsp;</td>
		    <td width="18%">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td><strong><font style="font-size:11px">Employee: </font></strong></td>
		    <td colspan="4" class="thinborderBOTTOM"><%=(String)vEmployeeInformation.elementAt(0)%></td>
		    <td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td colspan="3"><strong><font style="font-size:11px">Date of Performance Review: </font></strong></td>
		    <td colspan="2" class="thinborderBOTTOM"><%=(String)vEmployeeInformation.elementAt(1)%></td>
		    <td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td colspan="2"><strong><font style="font-size:11px">Review Period: </font></strong></td>
		    <td colspan="3" class="thinborderBOTTOM">
				<%=(String)vEmployeeInformation.elementAt(2)%> - <%=(String)vEmployeeInformation.elementAt(3)%></td>
		    <td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25" >&nbsp;</td>
		    <td colspan="4"><strong><font style="font-size:11px">Person Conducting Performance Review: </font></strong></td>
		    <td class="thinborderBOTTOM">
			<%if(strReadOnly.length() == 0){%>
				<%=WebInterface.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3), 4)%></td>
			<%}else{%>
				<%=(String)vEmployeeInformation.elementAt(4)%>
			<%}%>
		    <td>&nbsp;</td>
		</tr>
		<tr>
			<td height="15" colspan="7">&nbsp;</td>
		</tr>
	</table>
<%}

Vector vTemp = null;
if(vPersonalEvaluation != null && vPersonalEvaluation.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="2"><hr size="1"></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vPersonalEvaluation.size(); i += 2){
		vTemp = (Vector)vPersonalEvaluation.elementAt(i+1);
	%>	
		<tr>
			<td height="25" width="5%">&nbsp;</td>
			<td width="95%"><strong><u><%=WI.getStrValue((String)vPersonalEvaluation.elementAt(i), "EMPLOYEE SELF-EVALUATION")%></u></strong></td>
		</tr>
		<%for(int j = 0; j < vTemp.size(); j += 4, iCount++){%>
		<tr>
			<td height="25">&nbsp;</td>
			<td><strong><font style="font-size:11px"><%=iCount%>.) <%=(String)vTemp.elementAt(j+1)%></font></strong></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><font style="font-size:11px"><%=WI.getStrValue((String)vTemp.elementAt(j+2), "&nbsp;")%></font></td>
		</tr>
		<%}%>
		<tr>
			<td colspan="2">&nbsp;</td>
		</tr>
	<%}%>
		<tr>
			<td height="15" colspan="2"><hr size="1"></td>
		</tr>
	</table>
<%}

if(vRatings != null && vRatings.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" width="5%">&nbsp;</td>
			<td width="95%"><strong><font style="font-size:11px">Rating: </font></strong></td>
		</tr>
		<%for(int i = 0; i < vRatings.size(); i += 2){%>
		<tr>
			<td height="20">&nbsp;</td>
			<td><strong><font style="font-size:11px">
				<%=(String)vRatings.elementAt(i)%>=<%=(String)vRatings.elementAt(i+1)%></font></strong></td>
		</tr>
		<%}%>
		<tr>
			<td height="20" colspan="2">&nbsp;</td>
		</tr>
	</table>
<%}

int iCount = 1;
Vector vQuestions = null;
if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%for(int i = 0; i < vRetResult.size(); i += 2){
		vQuestions = (Vector)vRetResult.elementAt(i+1);
	%>	
		<tr>
			<td height="25" width="5%">&nbsp;</td>
			<td width="95%"><strong><%=WI.getStrValue((String)vRetResult.elementAt(i))%></strong></td>
		</tr>
	<%
	if(strReadOnly.equals("1"))
		strErrMsg = " readonly";
	else
		strErrMsg = "";
		
	for(int j = 0; j < vQuestions.size(); j += 5, iCount++){
		strTemp = WI.getStrValue((String)vQuestions.elementAt(j+4), WI.fillTextValue("rating_"+iCount));
	%>
		<tr>
			<td height="25">&nbsp;</td>
			<td><%=(String)vQuestions.elementAt(j+1)%>&nbsp;
				<input type="hidden" name="is_rating_<%=iCount%>" value="<%=(String)vQuestions.elementAt(j+3)%>">				
				
				<%
				//show only if rating type
				if(((String)vQuestions.elementAt(j+3)).equals("1")){
					//if for update
					if(strReadOnly.length() == 0 || strReadOnly.equals("0")){%>
						<select name="rating_<%=iCount%>">
							<option value="">Not Rated</option>
							<%=dbOP.loadCombo("point_order_no","point_order_no"," from hr_lhs_review_point ", strTemp, false)%>
						</select>
					<%}else{%>
						(Rating: <%=WI.getStrValue((String)vQuestions.elementAt(j+4), "Not Rated")%>)
					<%}
				}%>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>
				<%
					strTemp = WI.getStrValue((String)vQuestions.elementAt(j+2), WI.fillTextValue("answer_"+iCount));
				%>
				<textarea name="answer_<%=iCount%>" style="font-size:12px" cols="90" rows="2" 
					onFocus="style.backgroundColor='#D3EBFF'" class="textbox" 
					onBlur="style.backgroundColor='white'"<%=strErrMsg%>><%=strTemp%></textarea>
					
				<input type="hidden" name="ques_index_<%=iCount%>" value="<%=(String)vQuestions.elementAt(j)%>"></td>
		</tr>
		<%}%>
		<tr>
			<td height="15"colspan="2">&nbsp;</td>
		</tr>
	<%}
	
	if(strReadOnly.length() == 0 || strReadOnly.equals("0")){%>	
		<tr>
			<td colspan="2" align="center">
				<input type="hidden" name="ques_count" value="<%=iCount%>">
			<%if(!bolIsReviewed){%>
				<a href="javascript:UpdatePerfEval();"><img src="../../../images/update.gif" border="0"></a>
				<font size="1">click to update performance evaluation</font>
				&nbsp;
				<a href="javascript:FinalizePerfReview();"><img src="../../../images/execute_query.gif" border="0"></a>
				<font size="1">click to finalize performance evaluation </font>
			<%}%></td>
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

	<input type="hidden" name="perf_eval_main_index" value="<%=strPerfEvalMainIndex%>">
	<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
	<input type="hidden" name="finalize_answers">
	<input type="hidden" name="submit_answers">
	<input type="hidden" name="read_only" value="<%=strReadOnly%>">

	<input type="hidden" name="opner_form_name" value="<%=strOpnerFormName%>">  	
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>