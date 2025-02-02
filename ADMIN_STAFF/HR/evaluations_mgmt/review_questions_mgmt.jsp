<%@ page language="java" import="utility.*,java.util.Vector, hr.HRLighthouse" %>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Review Questions Mgmt</title>
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

	function ReloadPage(){
		if(document.form_.category)
			document.form_.category_name.value = document.form_.category[document.form_.category.selectedIndex].text;
		document.form_.submit();
	}
	
	function PrepareToEdit(index){
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = index;
		document.form_.submit();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this question?'))
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
		document.form_.page_action.value = '';
		document.form_.prepareToEdit.value = '';
		document.form_.info_index.value = '';
		document.form_.question.value = '';
		document.form_.order_no.value = '';
		document.form_.submit();
	}
	
	function UpdateCategory(){
		var pgLoc = "./update_category.jsp?opner_form_name=form_";
		var win=window.open(pgLoc,"UpdateCategory",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
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
			"Admin/staff-HR Management-Performance Evaluation Management-Review Questions Mgmt","review_questions_mgmt.jsp");
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
	
	String strPrepareToEdit =  WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	HRLighthouse hrl = new HRLighthouse();

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(hrl.operateOnReviewQuestions(dbOP, request, Integer.parseInt(strTemp)) == null){
			strErrMsg = hrl.getErrMsg();

		} else {
			if(strTemp.equals("0"))
				strErrMsg = " Review Question removed successfully";
			if(strTemp.equals("1"))
				strErrMsg = " Review Question recorded successfully";
			if(strTemp.equals("2"))
				strErrMsg = " Review Question updated successfully";
				
			strPrepareToEdit = "0";
		}
	}
	
	vRetResult = hrl.operateOnReviewQuestions(dbOP, request, 4);
	
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = hrl.operateOnReviewQuestions(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = hrl.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="document.form_.question.focus();">
<form action="review_questions_mgmt.jsp" method="post" name="form_">

	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: REVIEW QUESTIONS ::::</strong></font></td>
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
			<td width="3%" height="25">&nbsp;</td>
			<td width="17%">Evaluation Type: </td>
			<td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(2);
					else
						strTemp = WI.fillTextValue("is_self_eval");
					
					if(strTemp.length() == 0 || strTemp.equals("1")){
						strTemp = "checked";
						strErrMsg = "";
					}
					else{
						strTemp = "";
						strErrMsg = "checked";
					}
				%>	
				<input name="is_self_eval" type="radio" onChange="ReloadPage();" value="1" <%=strTemp%>>Self Evaluation
				<input name="is_self_eval" type="radio" onChange="ReloadPage();" value="0" <%=strErrMsg%>>Performance Evaluation
			</td>
		</tr>
	<%if(WI.fillTextValue("is_self_eval").equals("0")){%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Category: </td>
			<td>
				<%if(vEditInfo != null && vEditInfo.size() > 0){%>
					<input type="hidden" name="category" value="<%=(String)vEditInfo.elementAt(5)%>">
					<%=(String)vEditInfo.elementAt(6)%>	
				<%}else{%>
					<select name="category" onChange="ReloadPage();">
						<option value="">Select Category</option>
						<%=dbOP.loadCombo("catg_index","category"," from hr_lhs_ques_catg order by order_no", WI.fillTextValue("category"), false)%>
					</select>
					&nbsp;
					<%if(iAccessLevel > 1){%>
						<a href="javascript:UpdateCategory();"><img src="../../../images/update.gif" border="0"></a>
						<font size="1">click to update question categories.</font>
					<%}%>
				<%}%>
		  </td>
		</tr>
	<%}%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Question: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("question");
				%>
				<textarea name="question" style="font-size:12px" cols="60" rows="2" 
					onFocus="style.backgroundColor='#D3EBFF'" class="textbox" 
					onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Order No.</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.fillTextValue("order_no");
				%>
				<input type="text" name="order_no" class="textbox" maxlength="10" value="<%=strTemp%>"
					onBlur="AllowOnlyInteger('form_','order_no');style.backgroundColor='white'" 
					onkeyup="AllowOnlyInteger('form_','order_no')" onFocus="style.backgroundColor='#D3EBFF'"/></td>
		</tr>
	<%if(WI.fillTextValue("is_self_eval").equals("0")){%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Has Rating? </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(4);
					else
						strTemp = WI.fillTextValue("is_rating");
					
					if(strTemp.length() == 0 || strTemp.equals("0")){
						strTemp = "checked";
						strErrMsg = "";
					}
					else{
						strTemp = "";
						strErrMsg = "checked";
					}
				%>
				<input name="is_rating" type="radio" value="1" <%=strErrMsg%>>Yes
				<input name="is_rating" type="radio" value="0" <%=strTemp%>>No
			</td>
		</tr>
	<%}%>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
			
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="20%" height="25">&nbsp;</td>
			<td width="80%">
			<%if (iAccessLevel > 1){
				if (vEditInfo  == null){%>        
					<a href="javascript:PageAction('1','');">
						<img src="../../../images/save.gif" border="0" name="hide_save"></a> 
					<font size="1">click to save entry </font> 
				<%}else{ %>        
					<a href="javascript:PageAction('2','<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a> 
					<font size="1">click to save changes</font>
				<%} // end else vEdit Info == null%>
				
				<a href="javascript:CancelRecord();">					
					<img src="../../../images/refresh.gif" border="0"></a>
				<font size="1">click to cancel and clear entries</font> 				
			<%} // end iAccessLevel  > 1%></td>
		</tr> 
		<tr>
			<td colspan="2">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr bgcolor="#B9B292">
			<td height="28" align="center" class="thinborder">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("is_self_eval"), "1");
					if(strTemp.equals("1")){
						strTemp = "";
						strErrMsg = "Self Evaluation Questions";
					}
					else{
						strTemp = " ("+WI.fillTextValue("category_name")+")";
						strErrMsg = "Performance Evaluation Questions";
					}
				%>
				<strong>::: <%=strErrMsg%><%=strTemp%> ::: </strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td height="25" width="10%" align="center" class="thinborder"><strong>Order No.</strong></td>	
			<td width="60%" align="center" class="thinborder"><strong>Question</strong></td>
		<%if(WI.fillTextValue("is_self_eval").equals("0")){%>	
			<td width="12%" align="center" class="thinborder"><strong>Has Rating?</strong></td>
		<%}%>	
			<td width="18%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 7){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>		
			<td width="36%" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		<%if(WI.fillTextValue("is_self_eval").equals("0")){
			strTemp = (String)vRetResult.elementAt(i+4);	
			if(strTemp.equals("1"))
				strTemp = "Yes";
			else
				strTemp = "No";
		%>	
			<td width="12%" align="center" class="thinborder"><%=strTemp%></td>
		<%}%>	
			<td width="15%" align="center" class="thinborder">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>');">
							<img src="../../../images/delete.gif" border="0"></a>
					<%}
				}else{%>
					No edit/delete privilege.
				<%}%></td>
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
	<input type="hidden" name="category_name" value="<%=WI.fillTextValue("category_name")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>