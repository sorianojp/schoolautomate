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
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">

	function EditOtherData(strInfoIndex){
		document.form_.print_evaluation.value = "";
		document.form_.edit_other_data.value = strInfoIndex;
		document.form_.view_record.value = "1";
		document.form_.submit();
	}

	function EditCFOtherRates(strInfoIndex, strIIndex){
		document.form_.print_evaluation.value = "";
		document.form_.edit_cf_other_rates.value = strInfoIndex;
		document.form_.iIndex.value = strIIndex;
		document.form_.view_record.value = "1";
		document.form_.submit();
	}
	
	function UpdateOtherRates(strUserIndex){
		var vRPIndex = document.form_.rp_index.value;
		if(vRPIndex.length == 0)
			return;
		
		var pgLoc = "./update_other_rates.jsp?opner_form_name=form_&user_index="+strUserIndex+"&rp_index="+vRPIndex;
		var win=window.open(pgLoc,"UpdateOtherRates",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function AjaxUpdateRate(strECFIndex, objRemark, isEmployee) {		
		var objCOAInput = objRemark;
		
		this.InitXmlHttpObject(objCOAInput, 1);
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}

		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20203&new_value="+escape(objRemark.value)+
			"&ecf_index="+strECFIndex+"&is_employee="+isEmployee;
		this.processRequest(strURL);
	}

	function EditPerfRecord(strInfoIndex, strIIndex){
		document.form_.print_evaluation.value = "";
		document.form_.info_index.value = strInfoIndex;
		document.form_.iIndex.value = strIIndex;
		document.form_.view_record.value = "1";
		document.form_.submit();
	}

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

	function RefreshPage(){
		document.form_.print_evaluation.value = "";
		document.form_.view_record.value = "1";
		document.form_.submit();
	}

	function OpenSearch() {
		var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
		var win=window.open(pgLoc,"OpenSearch",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	var objCOA;
	var objCOAInput;
	
	function AjaxMapName(strFieldName, strLabelID) {
		objCOA=document.getElementById(strLabelID);
		var strCompleteName = eval("document.form_."+strFieldName+".value");
		eval('objCOAInput=document.form_.'+strFieldName);
		if(strCompleteName.length <= 2) {
			objCOA.innerHTML = "";
			return ;
		}		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
	
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1"+
		"&name_format=4&complete_name="+escape(strCompleteName);
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		objCOAInput.value = strID;
		objCOA.innerHTML = "";
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	function PrintEvaluation(){
		document.form_.print_evaluation.value = "1";
		document.form_.submit();
	}
	
	function ViewRecord(){
		document.form_.print_evaluation.value = "";
		document.form_.view_record.value = "1";
		document.form_.submit();
	}
	
	function FocusField(){
		document.form_.emp_id.focus();
	}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null; 
	
	if (WI.fillTextValue("print_evaluation").length() > 0){%>
		<jsp:forward page="./agency_perf_eval_print.jsp" />
	<% 
		return;}
	
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
			"Admin/staff-HR Management-Performance Evaluation Management-Quarterly Evaluation","agency_perf_eval.jsp");
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
	
	Vector vEmpRec = null;
	Vector vCF = null;
	Vector vCFOthers = null;
	Vector vPerf = null;
	Vector vOtherData = null;
	Vector vRetResult = null;
	GovtEvaluation eval = new GovtEvaluation();
	
	if(WI.fillTextValue("view_record").length() > 0){
		enrollment.Authentication authentication = new enrollment.Authentication();
		vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	
		if (vEmpRec == null || vEmpRec.size() == 0){
			if (strErrMsg == null || strErrMsg.length() == 0)
				strErrMsg = authentication.getErrMsg();
		}
		
		if(vEmpRec != null && vEmpRec.size() > 0){
			if(!eval.createReviewPeriodEvaluationRecords(dbOP, request, (String)vEmpRec.elementAt(0))){
				strErrMsg = eval.getErrMsg();
				vEmpRec = null;
			}
			else{
				if(WI.fillTextValue("edit_other_data").length() > 0){
					if(!eval.editEmployeePerfOtherData(dbOP, request))
						strErrMsg = eval.getErrMsg();
					else
						strErrMsg = "Evaluation other data entry successfully edited.";
				}
			
				if(WI.fillTextValue("info_index").length() > 0){
					if(!eval.editEmployeePerformanceEvaluation(dbOP, request))
						strErrMsg = eval.getErrMsg();
					else
						strErrMsg = "Performance evaluation entry successfully edited.";
				}
				
				if(WI.fillTextValue("edit_cf_other_rates").length() > 0){
					if(!eval.editCFOtherRates(dbOP, request))
						strErrMsg = eval.getErrMsg();
					else
						strErrMsg = "Rates successfully edited.";
				}
				
				vRetResult = eval.getEmployeeAgencyEvaluationRecords(dbOP, request, (String)vEmpRec.elementAt(0));
				if(vRetResult == null)
					strErrMsg = eval.getErrMsg();
				else{
					vCF = (Vector)vRetResult.elementAt(0);
					vCFOthers = (Vector)vRetResult.elementAt(1);
					vPerf = (Vector)vRetResult.elementAt(2);
					vOtherData = (Vector)vRetResult.elementAt(3);
				}
			}
		}
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="FocusField();">
<form action="agency_perf_eval.jsp" method="post" name="form_">

	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: AGENCY PERFORMANCE EVALUATION ::::</strong></font></td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Review Period: </td>
	      <td colspan="2">
				<select name="rp_index">
					<option value="">Select Rating Period</option>
					<%=dbOP.loadCombo("rp_index","rp_title"," from hr_lhs_review_period "+
						"where is_valid = 1 order by period_open_fr desc",WI.fillTextValue("rp_index"),false)%>
		  </select></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Employee ID: </td>
			<td width="25%" >
				<input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('emp_id','emp_id_');">
				<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
			<td width="55%" valign="top">&nbsp;<label id="emp_id_" style="position:absolute; width:350px"></label></td>
		</tr>
		<tr>
			<td height="40" colspan="2" valign="middle">&nbsp;</td>
		    <td colspan="2">
				<a href="javascript:ViewRecord();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
	    </tr>
	</table>

<%if(vEmpRec != null && vEmpRec.size() > 0){%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15" colspan="2"><hr size="1"></td>
		</tr>
		<tr>
			<td height="20" width="30%"><font size="1">*Rating (2,4,6,8,10)</font></td>
			<td width="70%" align="right">
				<a href="javascript:PrintEvaluation();"><img src="../../../images/print.gif" border="0"></a>
		    	<font size="1">Click to print  evaluation</font>
				&nbsp;
				<a href="javascript:RefreshPage();"><img src="../../../images/refresh.gif" border="0"></a>
				<font size="1">Click to refresh page.</font></td>
		</tr>
	</table>
	
<%if(vPerf != null && vPerf.size() > 0){%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="20"><strong>PART I: PERFORMANCE</strong></td>
		</tr>
	</table>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td rowspan="3" align="center" class="thinborder" width="23%"><strong>WORK/ACTIVITIES<br>(Unit of Measure)</strong></td>
		    <td height="15" colspan="6" align="center" class="thinborder"><strong>TARGET AND ACCOMPLISHMENT </strong></td>
		    <td colspan="6" align="center" class="thinborder"><strong>RATINGS</strong></td>
			<td rowspan="3" align="center" class="thinborder" width="7%"><strong>Edit</strong></td>
	    </tr>
		<tr>
			<td height="15" colspan="2" align="center" class="thinborder"><strong>Quantity</strong></td>
		    <td height="15" colspan="2" align="center" class="thinborder"><strong>Quality</strong></td>
		    <td height="15" colspan="2" align="center" class="thinborder"><strong>Time</strong></td>
	        <td colspan="3" align="center" class="thinborder"><strong>Supervisor</strong></td>
		    <td colspan="3" align="center" class="thinborder"><strong>Employee</strong></td>
		</tr>
		<tr>
			<td width="5%" height="15" align="center" class="thinborder"><font size="1">TARGET</font></td>
			<td width="5%" align="center" class="thinborder"><font size="1">ACCOMP</font></td>
			<td width="5%" align="center" class="thinborder"><font size="1">TARGET</font></td>
			<td width="5%" align="center" class="thinborder"><font size="1">ACCOMP</font></td>
			<td width="5%" align="center" class="thinborder"><font size="1">TARGET</font></td>
			<td width="5%" align="center" class="thinborder"><font size="1">ACCOMP</font></td>
			<td width="5%" align="center" class="thinborder">QN</td>
			<td width="5%" align="center" class="thinborder">QL</td>
			<td width="5%" align="center" class="thinborder">T</td>
			<td width="5%" align="center" class="thinborder">QN</td>
			<td width="5%" align="center" class="thinborder">QL</td>
			<td width="5%" align="center" class="thinborder">T</td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vPerf.size(); i += 17, iCount++){%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=(String)vPerf.elementAt(i+2)%><br>
				&nbsp;(<%=(String)vPerf.elementAt(i+4)%>)</td>
		    <td align="center" class="thinborder">
				<input type="text" name="qn_target_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','qn_target_<%=iCount%>');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','qn_target_<%=iCount%>')" size="3" maxlength="4"
					value="<%=WI.getStrValue((String)vPerf.elementAt(i+5))%>"/></td>
		    <td align="center" class="thinborder">
				<input type="text" name="qn_accomp_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','qn_accomp_<%=iCount%>');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','qn_accomp_<%=iCount%>')" size="3" maxlength="4"
					value="<%=WI.getStrValue((String)vPerf.elementAt(i+6))%>"/></td>
		    <td align="center" class="thinborder">
				<input type="text" name="ql_target_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','ql_target_<%=iCount%>');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','ql_target_<%=iCount%>')" size="3" maxlength="4"
					value="<%=WI.getStrValue((String)vPerf.elementAt(i+7))%>"/></td>
		    <td align="center" class="thinborder">
				<input type="text" name="ql_accomp_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','ql_accomp_<%=iCount%>');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','ql_accomp_<%=iCount%>')" size="3" maxlength="4"
					value="<%=WI.getStrValue((String)vPerf.elementAt(i+8))%>"/></td>
		    <td align="center" class="thinborder">
				<input type="text" name="t_target_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','t_target_<%=iCount%>');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','t_target_<%=iCount%>')" size="3" maxlength="4"
					value="<%=WI.getStrValue((String)vPerf.elementAt(i+9))%>"/></td>
		    <td align="center" class="thinborder">
				<input type="text" name="t_accomp_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','t_accomp_<%=iCount%>');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','t_accomp_<%=iCount%>')" size="3" maxlength="4"
					value="<%=WI.getStrValue((String)vPerf.elementAt(i+10))%>"/></td>
		    <td align="center" class="thinborder">
				<input type="text" name="sup_qn_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyGovtRating('form_','sup_qn_<%=iCount%>', '0');style.backgroundColor='white'" 
					onkeyup="AllowOnlyGovtRating('form_','sup_qn_<%=iCount%>', '1')" size="2" maxlength="2" 
					value="<%=WI.getStrValue((String)vPerf.elementAt(i+11))%>"/></td>
		    <td align="center" class="thinborder">
				<input type="text" name="sup_ql_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyGovtRating('form_','sup_ql_<%=iCount%>', '0');style.backgroundColor='white'" 
					onkeyup="AllowOnlyGovtRating('form_','sup_ql_<%=iCount%>', '1')" size="2" maxlength="2" 
					value="<%=WI.getStrValue((String)vPerf.elementAt(i+12))%>"/></td>
		    <td align="center" class="thinborder">
				<input type="text" name="sup_t_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyGovtRating('form_','sup_t_<%=iCount%>', '0');style.backgroundColor='white'" 
					onkeyup="AllowOnlyGovtRating('form_','sup_t_<%=iCount%>', '1')" size="2" maxlength="2" 
					value="<%=WI.getStrValue((String)vPerf.elementAt(i+13))%>"/></td>
		    <td align="center" class="thinborder">
				<input type="text" name="emp_qn_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyGovtRating('form_','emp_qn_<%=iCount%>', '0');style.backgroundColor='white'" 
					onkeyup="AllowOnlyGovtRating('form_','emp_qn_<%=iCount%>', '1')" size="2" maxlength="2" 
					value="<%=WI.getStrValue((String)vPerf.elementAt(i+14))%>"/></td>
		    <td align="center" class="thinborder">
				<input type="text" name="emp_ql_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyGovtRating('form_','emp_ql_<%=iCount%>', '0');style.backgroundColor='white'" 
					onkeyup="AllowOnlyGovtRating('form_','emp_ql_<%=iCount%>', '1')" size="2" maxlength="2" 
					value="<%=WI.getStrValue((String)vPerf.elementAt(i+15))%>"/></td>
		    <td align="center" class="thinborder">
				<input type="text" name="emp_t_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyGovtRating('form_','emp_t_<%=iCount%>', '0');style.backgroundColor='white'" 
					onkeyup="AllowOnlyGovtRating('form_','emp_t_<%=iCount%>', '1')" size="2" maxlength="2" 
					value="<%=WI.getStrValue((String)vPerf.elementAt(i+16))%>"/></td>
		    <td align="center" class="thinborder">
				<a href="javascript:EditPerfRecord('<%=(String)vPerf.elementAt(i)%>', '<%=iCount%>');">
					<img src="../../../images/edit.gif" border="0"></a></td>
		</tr>
	<%}%>
	</table>
<%}

if(vCF != null && vCF.size() > 0){%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="20"><strong>PART II: CRITICAL FACTORS</strong></td>
		</tr>
	</table>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
		  	<td rowspan="2" align="center" class="thinborder" width="25%">&nbsp;</td>
		  	<td rowspan="2" align="center" class="thinborder" width="45%"><strong>CRITICAL FACTORS</strong></td>
		  	<td height="20" colspan="2" align="center" class="thinborder"><strong>RATING</strong></td>
	  	</tr>
		<tr>
			<td width="15%" height="20" align="center" class="thinborder"><strong>SUPERVISOR</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>EMPLOYEE</strong></td>
		</tr>
	<%	
		boolean bolSupervisorOnly = false;
		int iCount = 1;
		for(int i = 0; i < vCF.size(); i += 7, iCount++){
			bolSupervisorOnly = ((String)vCF.elementAt(i+4)).equals("1");
	%>
		<tr>
			<td height="25" class="thinborder" valign="top">
				&nbsp;<%=iCount%>. <%=(String)vCF.elementAt(i+2)%>
				<%if(bolSupervisorOnly){%>
					<br>&nbsp;<font size="1">(For supervisors only)</font>
				<%}%></td>
		  	<td align="center" class="thinborder"><div align="justify" style="width:97%"><%=(String)vCF.elementAt(i+3)%></div></td>
			<td align="center" class="thinborder">
				<input type="text" name="supervisor_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyGovtRating('form_','supervisor_<%=iCount%>', '0');style.backgroundColor='white';javascript:AjaxUpdateRate('<%=(String)vCF.elementAt(i)%>',document.form_.supervisor_<%=iCount%>, '1');" 
					onkeyup="AllowOnlyGovtRating('form_','supervisor_<%=iCount%>', '1')" size="5" maxlength="4" 
					value="<%=WI.getStrValue((String)vCF.elementAt(i+5))%>"/></td>
			<td align="center" class="thinborder">
				<%
					if(bolSupervisorOnly)
						strTemp = "disabled";
					else
						strTemp = "";
				%>
				<input type="text" name="employee_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyGovtRating('form_','employee_<%=iCount%>', '0');style.backgroundColor='white';javascript:AjaxUpdateRate('<%=(String)vCF.elementAt(i)%>',document.form_.employee_<%=iCount%>, '0');" 
					onkeyup="AllowOnlyGovtRating('form_','employee_<%=iCount%>', '1')" size="5" maxlength="4" <%=strTemp%>
					value="<%=WI.getStrValue((String)vCF.elementAt(i+6))%>"/></td>
		</tr>
	<%}%>
	</table>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td width="3%">&nbsp;</td>
			<td height="25">
				<a href="javascript:UpdateOtherRates('<%=(String)vEmpRec.elementAt(0)%>');">
					<img src="../../../images/update.gif" border="0"></a>
				<font size="1">Click to update other rates.</font></td>
		</tr>
	</table>
<%}

if(vCFOthers != null && vCFOthers.size() > 0){%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td width="3%">&nbsp;</td>
			<td height="15"><font size="1">
				This is the weighted average scores encoding for subordinate, peer, and client rates.
				Valid input range: 0-10 </font></td>
		</tr>
	</table>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td height="25" width="10%" align="center" class="thinborder">&nbsp;</td>
			<td width="25%" align="center" class="thinborder"><strong>SUBORDINATE</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>PEER</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>CLIENT</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>EDIT</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vCFOthers.size(); i += 5, iCount++){%>
		<tr>
			<%
				strTemp = (String)vCFOthers.elementAt(i+4);
				if(strTemp.equals("1"))
					strTemp = "I";
				else
					strTemp = "II";
			%>
			<td class="thinborder">&nbsp;PART <%=strTemp%></td>
			<td align="center" class="thinborder">
		  <input type="text" name="subordinate_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','subordinate_<%=iCount%>');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','subordinate_<%=iCount%>')" size="5" maxlength="4"
					value="<%=WI.getStrValue((String)vCFOthers.elementAt(i+1))%>"/></td>
			<td align="center" class="thinborder">
				<input type="text" name="peer_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','peer_<%=iCount%>');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','peer_<%=iCount%>')" size="5" maxlength="4"
					value="<%=WI.getStrValue((String)vCFOthers.elementAt(i+2))%>"/></td>
			<td align="center" class="thinborder">
				<input type="text" name="client_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','client_<%=iCount%>');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','client_<%=iCount%>')" size="5" maxlength="4"
					value="<%=WI.getStrValue((String)vCFOthers.elementAt(i+3))%>"/></td>	
			<td height="25" align="center" class="thinborder">
				<a href="javascript:EditCFOtherRates('<%=(String)vCFOthers.elementAt(i)%>', '<%=iCount%>');">
					<img src="../../../images/edit.gif" border="0"></a></td>		
		</tr>
	<%}%>
	</table>
<%}

if(vOtherData != null && vOtherData.size() > 0){%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15" colspan="2"><hr size="1"></td>
		</tr>
		<tr>
			<td width="3%">&nbsp;</td>
			<td height="15"><font size="1">
				This is the weighted average scores encoding for subordinate, peer, and client rates.
				Valid input range: 0-10 </font></td>
		</tr>
	</table>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="3%">&nbsp;</td>
			<td height="25" width="30%">Additional Rating (Optional): </td>
			<td width="67%">
				<input type="text" name="add_rating" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','add_rating');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','add_rating')" size="5" maxlength="4"
					value="<%=WI.getStrValue((String)vOtherData.elementAt(2))%>"/></td>
		</tr>
		<tr>
			<td width="3%">&nbsp;</td>
			<td height="25" width="30%">Comments/Recommendations:</td>
			<td width="67%">
				<textarea name="comments" style="font-size:12px" cols="65" rows="3" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue((String)vOtherData.elementAt(1))%></textarea></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" align="center">
				<a href="javascript:EditOtherData('<%=(String)vOtherData.elementAt(0)%>');">
					<img src="../../../images/edit.gif" border="0"></a>
				<font size="1">Click to edit other additional rating and comments.</font></td>
		</tr>
	</table>
<%}

}%>
			
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="1" height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#0D3371">
			<td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="info_index">
	<input type="hidden" name="iIndex">
	<input type="hidden" name="view_record">
	<input type="hidden" name="edit_cf_other_rates">
	<input type="hidden" name="print_evaluation">
	<input type="hidden" name="edit_other_data">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>