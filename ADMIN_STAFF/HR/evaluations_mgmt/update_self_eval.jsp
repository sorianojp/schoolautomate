<%@ page language="java" import="utility.*,hr.HRLighthouse,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String strSelfEvalMainIndex = WI.fillTextValue("self_eval_main_index");
	String strReadOnly = WI.fillTextValue("read_only");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Self Evaluation</title>
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

	function UpdateSelfEval(){
		document.form_.submit_answers.value = "1";
		document.form_.submit();
	}
	
	function GoBack(){
		location = "../../../ess/lhs/evaluation_main.jsp?my_home=1";
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if(strSelfEvalMainIndex.length() == 0){%>
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
			"Admin/staff-HR Management-Performance Evaluation Management-Update Self Evaluation","update_self_eval.jsp");
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
	
	HRLighthouse hrl = new HRLighthouse();
	Vector vEmpRec = null;
	Vector vRetResult = null;
	
	if(strReadOnly.length() == 0){
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
			
	} else {
		vEmpRec = hrl.getEmpSelfEvaluationDetails(dbOP, request, strSelfEvalMainIndex);
		if(vEmpRec == null)
			strErrMsg = hrl.getErrMsg();
		
	}
	
	if(WI.fillTextValue("submit_answers").length() > 0){
		if(!hrl.updateSelfEvaluationAnswers(dbOP, request, strSelfEvalMainIndex))
			strErrMsg = hrl.getErrMsg();
		else
			strErrMsg = "Self evaluation form successfully updated.";
	}
	
	//get all the questions
	//3rd parameter -- > boolean isSelfEval
	//if true, get all the questions for self evaluation
	//else, get all for performance evaluation
	vRetResult = hrl.getAllQuestions(dbOP, request, strSelfEvalMainIndex, "");
	if(vRetResult == null)
		strErrMsg = hrl.getErrMsg();
	
	boolean bolIsReviewed = hrl.isSelfEvalMainReviewd(dbOP, request);
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" action="./update_self_eval.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A" class="footerDynamic">
			<td height="25" colspan="3" bgcolor="#A49A6A" align="center" class="footerDynamic">
			<font color="#FFFFFF" ><strong>:::: EMPLOYEE SELF EVALUATION ::::</strong></font></td>
		</tr>

		<tr> 
			<td height="25" width="5%">&nbsp;</td>
			<td width="80%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
			<td width="20%" align="right">
			<%if(strReadOnly.length() == 0){%>
				<a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0"></a>
			<%}%></td>
		</tr>
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="25" width="5%">&nbsp;</td>
			<td width="17%"><strong><font style="font-size:11px">Employee: </font></strong></td>
			<td width="35%" class="thinborderBOTTOM">&nbsp;<%=WebInterface.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3), 4)%></td>
			<td width="12%" align="right"><strong><font style="font-size:11px">Date: &nbsp;</font></strong></td>
			<td width="23%" class="thinborderBOTTOM">&nbsp;
				<%
				if(strReadOnly.length() == 0)
					strTemp = WI.formatDate(WI.getTodaysDate(1), 6);
				else
					strTemp = (String)vEmpRec.elementAt(4);
				%>
				<%=strTemp%></td>
			<td width="8%">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="6">&nbsp;</td>
		</tr>
	</table>
	
<%
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
		
		for(int j = 0; j < vQuestions.size(); j += 4, iCount++){%>
		<tr>
			<td height="25">&nbsp;</td>
			<td><%=(String)vQuestions.elementAt(j+1)%></td>
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
			<td colspan="2">&nbsp;</td>
		</tr>
	<%}%>
		<tr>
			<td colspan="2" align="center">
				<input type="hidden" name="ques_count" value="<%=iCount%>">
			<%if(!bolIsReviewed && strReadOnly.length() == 0){%>
				<a href="javascript:UpdateSelfEval();"><img src="../../../images/update.gif" border="0"></a>
				<font size="1">click to update self evaluation</font>
			<%}%></td>
		</tr>
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

	<input type="hidden" name="self_eval_main_index" value="<%=strSelfEvalMainIndex%>">
	<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
	<input type="hidden" name="submit_answers">
	<input type="hidden" name="read_only" value="<%=strReadOnly%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>