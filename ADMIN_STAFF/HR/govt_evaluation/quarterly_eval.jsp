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

	function PrintEvaluation(){
		document.form_.print_evaluation.value = "1";
		document.form_.print_eval_work.value = "";
		document.form_.print_values_page.value = "";
		document.form_.submit();
	}

	function EditWorkRecord(strInfoIndex, strIIndex){
		document.form_.info_index.value = strInfoIndex;
		document.form_.iIndex.value = strIIndex;
		document.form_.view_record.value = "1";
		document.form_.print_eval_work.value = "";
		document.form_.print_values_page.value = "";
		document.form_.print_evaluation.value = "";
		document.form_.submit();
	}
	
	function PrintValuesWork(){		
		document.form_.print_eval_work.value = "1";
		document.form_.print_values_page.value = "";
		document.form_.print_evaluation.value = "";
		document.form_.submit();
	}
	
	function PrintValuesEval(){
		document.form_.print_values_page.value = "1";
		document.form_.print_eval_work.value = "";
		document.form_.print_evaluation.value = "";
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
		document.form_.view_record.value = "1";
		document.form_.print_eval_work.value = "";
		document.form_.print_values_page.value = "";
		document.form_.print_evaluation.value = "";
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
	
	function ViewRecord(){
		document.form_.print_eval_work.value = "";
		document.form_.print_values_page.value = "";
		document.form_.print_evaluation.value = "";
		document.form_.view_record.value = "1";
		document.form_.submit();
	}
	
	function FocusField(){
		document.form_.emp_id.focus();
	}
	
	function AjaxUpdateRate(strEVIndex, objRemark, iRating) {		
		var objCOAInput = objRemark;
		
		this.InitXmlHttpObject(objCOAInput, 1);
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}

		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20200&new_value="+escape(objRemark.value)+
			"&ev_index="+strEVIndex+"&rating="+iRating;
		this.processRequest(strURL);
	}
	
	function AjaxUpdatePA(strPAIndex, objRemark, strField) {		
		var objCOAInput = objRemark;
		
		this.InitXmlHttpObject(objCOAInput, 1);
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}

		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20201&new_value="+escape(objRemark.value)+
			"&pa_index="+strPAIndex+"&field="+strField;
		this.processRequest(strURL);
	}
	
	function AjaxUpdateTeamwork(strTWIndex, objRemark) {		
		var objCOAInput = objRemark;
		
		this.InitXmlHttpObject(objCOAInput, 1);
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}

		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20202&new_value="+escape(objRemark.value)+
			"&teamwork_index="+strTWIndex;
		this.processRequest(strURL);
	}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null; 
	
	if (WI.fillTextValue("print_values_page").length() > 0){%>
		<jsp:forward page="./values_print.jsp" />
	<% 
		return;}
		
	if (WI.fillTextValue("print_eval_work").length() > 0){%>
		<jsp:forward page="./work_print.jsp" />
	<% 
		return;}
		
	if (WI.fillTextValue("print_evaluation").length() > 0){%>
		<jsp:forward page="./quarterly_eval_print.jsp" />
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
			"Admin/staff-HR Management-Performance Evaluation Management-Quarterly Evaluation","quarterly_eval.jsp");
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
	Vector vValues = null;
	Vector vWork = null;
	Vector vPA = null;
	Vector vTeamwork = null;
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
			if(!eval.createEvaluationRecords(dbOP, request, (String)vEmpRec.elementAt(0))){
				strErrMsg = eval.getErrMsg();
				vEmpRec = null;
			}
			else{			
				if(WI.fillTextValue("info_index").length() > 0){
					if(!eval.editEmployeeWorkEvaluation(dbOP, request))
						strErrMsg = eval.getErrMsg();
					else
						strErrMsg = "Work evaluation entry successfully edited.";
				}
			
				vRetResult = eval.getEvaluationValues(dbOP, request, (String)vEmpRec.elementAt(0));
				if(vRetResult == null)
					strErrMsg = eval.getErrMsg();
				else{
					vValues = (Vector)vRetResult.elementAt(0);
					vPA = (Vector)vRetResult.elementAt(1);
					vTeamwork = (Vector)vRetResult.elementAt(2);
					vWork = (Vector)vRetResult.elementAt(3);
				}
			}
		}
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="FocusField();">
<form action="quarterly_eval.jsp" method="post" name="form_">

	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: QUARTERLY PERFORMANCE EVALUATION ::::</strong></font></td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Quarter: </td>
		  <td colspan="2">
				<%
					strTemp = WI.fillTextValue("quarter");
				%>
				<select name="quarter">
				<%if(strTemp.length() == 0){%>
					<option value="" selected>Select Quarter</option>
				<%}else{%>
					<option value="">Select Quarter</option>
				
				<%}if(strTemp.equals("1")){%>
					<option value="1" selected>1st Quarter</option>
				<%}else{%>
					<option value="1">1st Quarter</option>
				
				<%}if(strTemp.equals("2")){%>
					<option value="2" selected>2nd Quarter</option>
				<%}else{%>
					<option value="2">2nd Quarter</option>
				
				<%}if(strTemp.equals("3")){%>
					<option value="3" selected>3rd Quarter</option>
				<%}else{%>
					<option value="3">3rd Quarter</option>
				
				<%}if(strTemp.equals("4")){%>
					<option value="4" selected>4th Quarter</option>
				<%}else{%>
					<option value="4">4th Quarter</option>
				<%}%>
				</select>
			  	&nbsp;
		        <select name="year">
                  <%=dbOP.loadComboYear(WI.fillTextValue("year"),2,1)%>
                </select></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Employee ID: </td>
			<td width="25%" >
				<input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('emp_id','emp_id_');">
				<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>		</td>
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
<%if(vWork != null && vWork.size() > 0){%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" width="60%"><strong>PART I: WORK ACCOMPLISHMENT (50%)</strong></td>
			<td align="right" width="40%">
				<a href="javascript:PrintValuesWork();"><img src="../../../images/print.gif" border="0"></a>
				<font size="1">Click to print part I evaluation</font></td>
		</tr>
	</table>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td rowspan="3" align="center" class="thinborder" width="8%"><strong>Weight</strong></td>
		    <td rowspan="3" align="center" class="thinborder" width="22%"><strong>WORK/ACTIVITIES<br>(Unit of Measure) </strong></td>
		    <td height="15" colspan="5" align="center" class="thinborder"><strong>Target and Accomplishment</strong></td>
		    <td colspan="2" rowspan="2" align="center" class="thinborder"><strong>Supervisor's Rating</strong></td>
			<td rowspan="3" align="center" class="thinborder" width="7%"><strong>Edit</strong></td>
	    </tr>
		<tr>
			<td height="15" colspan="3" align="center" class="thinborder"><strong>Quantity</strong></td>
		    <td height="15" colspan="2" align="center" class="thinborder"><strong>Time</strong></td>
	    </tr>
		<tr>
			<td width="9%" height="15" align="center" class="thinborder"><strong>Target</strong></td>
			<td width="9%" align="center" class="thinborder"><strong>Accomp</strong></td>
			<td width="9%" align="center" class="thinborder"><strong>Pts/Unit</strong></td>
			<td width="9%" align="center" class="thinborder"><strong>Target</strong></td>
			<td width="9%" align="center" class="thinborder"><strong>Accomp</strong></td>
			<td width="9%" align="center" class="thinborder"><strong>Quantity</strong></td>
			<td width="9%" align="center" class="thinborder"><strong>Time</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vWork.size(); i += 11, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=CommonUtil.formatFloat((String)vWork.elementAt(i+1), false)%>%</td>
		    <td class="thinborder">&nbsp;<%=(String)vWork.elementAt(i+2)%><br>(<%=(String)vWork.elementAt(i+3)%>)</td>
		    <td align="center" class="thinborder">
				<%
					strTemp = WI.getStrValue((String)vWork.elementAt(i+4));
					if(strTemp.length() > 0)
						strTemp = CommonUtil.formatFloat(strTemp, false);
				%>
				<input type="text" name="qty_target_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','qty_target_<%=iCount%>');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','qty_target_<%=iCount%>')" size="6" maxlength="6" 
					value="<%=strTemp%>"/></td>
		    <td align="center" class="thinborder">
				<%
					strTemp = WI.getStrValue((String)vWork.elementAt(i+5));
					if(strTemp.length() > 0)
						strTemp = CommonUtil.formatFloat(strTemp, false);
				%>
				<input type="text" name="qty_accomp_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','qty_accomp_<%=iCount%>');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','qty_accomp_<%=iCount%>')" size="6" maxlength="6" 
					value="<%=strTemp%>"/></td>
		    <td align="center" class="thinborder">
				<%
					strTemp = WI.getStrValue((String)vWork.elementAt(i+8));
					if(strTemp.length() > 0)
						strTemp = CommonUtil.formatFloat(strTemp, false);
				%>
				<input type="text" name="pts_per_unit_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','pts_per_unit_<%=iCount%>');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','pts_per_unit_<%=iCount%>')" size="6" maxlength="6" 
					value="<%=strTemp%>"/></td>
		    <td align="center" class="thinborder">
				<%
					strTemp = WI.getStrValue((String)vWork.elementAt(i+6));
					if(strTemp.length() > 0)
						strTemp = CommonUtil.formatFloat(strTemp, false);
				%>
				<input type="text" name="time_target_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','time_target_<%=iCount%>');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','time_target_<%=iCount%>')" size="6" maxlength="6" 
					value="<%=strTemp%>"/></td>
		    <td align="center" class="thinborder">
				<%
					strTemp = WI.getStrValue((String)vWork.elementAt(i+7));
					if(strTemp.length() > 0)
						strTemp = CommonUtil.formatFloat(strTemp, false);
				%>
				<input type="text" name="time_accomp_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','time_accomp_<%=iCount%>');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','time_accomp_<%=iCount%>')" size="6" maxlength="6" 
					value="<%=strTemp%>"/></td>
		    <td align="center" class="thinborder">
				<input type="text" name="quantity_rate_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyGovtRating('form_','quantity_rate_<%=iCount%>', '0');style.backgroundColor='white'" 
					onkeyup="AllowOnlyGovtRating('form_','quantity_rate_<%=iCount%>', '1')" size="5" maxlength="4" 
					value="<%=WI.getStrValue((String)vWork.elementAt(i+9))%>"/></td>
		    <td align="center" class="thinborder">
				<input type="text" name="time_rate_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyGovtRating('form_','time_rate_<%=iCount%>', '0');style.backgroundColor='white'" 
					onkeyup="AllowOnlyGovtRating('form_','time_rate_<%=iCount%>', '1')" size="5" maxlength="4" 
					value="<%=WI.getStrValue((String)vWork.elementAt(i+10))%>"/></td>
			<td align="center" class="thinborder">
				<a href="javascript:EditWorkRecord('<%=(String)vWork.elementAt(i)%>', '<%=iCount%>');">
					<img src="../../../images/edit.gif" border="0"></a></td>
		</tr>
	<%}%>
	</table>
<%}

if(vValues != null && vValues.size() > 0){%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" width="60%"><strong>PART II: VALUES/BEHAVIOR/WORK ATTITUDE (30%)</strong></td>
			<td align="right" width="40%">
				<a href="javascript:PrintValuesEval();"><img src="../../../images/print.gif" border="0"></a>
		    	<font size="1">Click to print part II evaluation</font></td>
		</tr>
	</table>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td height="25" width="40%" align="center" class="thinborder">&nbsp;</td>
			<td width="15%" align="center" class="thinborder"><strong>Supervisor Rate</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Peer Rate</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Client Rate</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Subordinate Rate</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vValues.size(); i += 7, iCount++){%>
		<tr>
			<td height="25" class="thinborder"><%=iCount%>. <%=(String)vValues.elementAt(i+2)%></td>
			<td align="center" class="thinborder">
				<input type="text" name="supervisor_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyGovtRating('form_','supervisor_<%=iCount%>', '0');style.backgroundColor='white';javascript:AjaxUpdateRate('<%=(String)vValues.elementAt(i)%>',document.form_.supervisor_<%=iCount%>, '1');" 
					onkeyup="AllowOnlyGovtRating('form_','supervisor_<%=iCount%>', '1')" size="5" maxlength="4" 
					value="<%=WI.getStrValue((String)vValues.elementAt(i+3))%>"/></td>
			<td align="center" class="thinborder">
				<input type="text" name="peer_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyGovtRating('form_','peer_<%=iCount%>', '0');style.backgroundColor='white';javascript:AjaxUpdateRate('<%=(String)vValues.elementAt(i)%>',document.form_.peer_<%=iCount%>, '2');" 
					onkeyup="AllowOnlyGovtRating('form_','peer_<%=iCount%>', '1')" size="5" maxlength="4" 
					value="<%=WI.getStrValue((String)vValues.elementAt(i+4))%>"/></td>
			<td align="center" class="thinborder">
				<input type="text" name="client_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyGovtRating('form_','client_<%=iCount%>', '0');style.backgroundColor='white';javascript:AjaxUpdateRate('<%=(String)vValues.elementAt(i)%>',document.form_.client_<%=iCount%>, '3');" 
					onkeyup="AllowOnlyGovtRating('form_','client_<%=iCount%>', '1')" size="5" maxlength="4" 
					value="<%=WI.getStrValue((String)vValues.elementAt(i+5))%>"/></td>
			<td align="center" class="thinborder">
				<input type="text" name="subordinate_<%=iCount%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyGovtRating('form_','subordinate_<%=iCount%>', '0');style.backgroundColor='white';javascript:AjaxUpdateRate('<%=(String)vValues.elementAt(i)%>',document.form_.subordinate_<%=iCount%>, '4');" 
					onkeyup="AllowOnlyGovtRating('form_','subordinate_<%=iCount%>', '1')" size="5" maxlength="4" 
					value="<%=WI.getStrValue((String)vValues.elementAt(i+6))%>"/></td>
		</tr>
	<%}%>
	</table>
<%}//end of vValues != null

if(vPA != null && vPA.size() > 0){%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="20"><strong>PART III: PUNCTUALITY &amp; ATTENDANCE (10%)</strong></td>
		</tr>
	</table>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td height="25" colspan="2" class="thinborder">&nbsp;</td>
			<td align="center" class="thinborder"><strong>Punctuality</strong></td>
			<td align="center" class="thinborder"><strong>Attendance</strong></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder">1</td>
			<td width="65%" class="thinborder">&nbsp;Based on Records (DTR)</td>
			<td width="15%" align="center" class="thinborder">
				<input name="p_rating1" type="text" size="5" value="<%=WI.getStrValue((String)vPA.elementAt(1))%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyGovtRating('form_','p_rating1', '1')"
					onBlur="AllowOnlyGovtRating('form_','p_rating1', '0');style.backgroundColor='white';AjaxUpdatePA('<%=(String)vPA.elementAt(0)%>',document.form_.p_rating1,'p_rating1');"></td>
			<td width="15%" align="center" class="thinborder">
				<input name="a_rating1" type="text" size="5" value="<%=WI.getStrValue((String)vPA.elementAt(3))%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyGovtRating('form_','a_rating1', '1')"
					onBlur="AllowOnlyGovtRating('form_','a_rating1', '0');style.backgroundColor='white';AjaxUpdatePA('<%=(String)vPA.elementAt(0)%>',document.form_.a_rating1,'a_rating1');"></td>
		</tr>
		<tr>
		  	<td height="25" align="center" class="thinborder">2</td>
		  	<td class="thinborder">&nbsp;Based on Actual Punctuality &amp; Attendance in the work place </td>
		  	<td align="center" class="thinborder">
				<input name="p_rating2" type="text" size="5" value="<%=WI.getStrValue((String)vPA.elementAt(2))%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyGovtRating('form_','p_rating2', '1')"
					onBlur="AllowOnlyGovtRating('form_','p_rating2', '0');style.backgroundColor='white';AjaxUpdatePA('<%=(String)vPA.elementAt(0)%>',document.form_.p_rating2,'p_rating2');"></td>
		  	<td align="center" class="thinborder">
				<input name="a_rating2" type="text" size="5" value="<%=WI.getStrValue((String)vPA.elementAt(4))%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyGovtRating('form_','a_rating2', '1')"
					onBlur="AllowOnlyGovtRating('form_','a_rating2', '0');style.backgroundColor='white';AjaxUpdatePA('<%=(String)vPA.elementAt(0)%>',document.form_.a_rating2,'a_rating2');"></td>
		</tr>
	</table>
<%}

if(vTeamwork != null && vTeamwork.size() > 0){%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="20"><strong>PART IV: TEAMWORK (10%)</strong>&nbsp;&nbsp;
				<input name="teamwork_rating" type="text" size="5" value="<%=WI.getStrValue((String)vTeamwork.elementAt(1))%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyGovtRating('form_','teamwork_rating','1')"
					onBlur="AllowOnlyGovtRating('form_','teamwork_rating', '0');style.backgroundColor='white';AjaxUpdateTeamwork('<%=(String)vTeamwork.elementAt(0)%>',document.form_.teamwork_rating);"></td>
		</tr>
	</table>
<%}%>
<%}%>
			
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
	<input type="hidden" name="print_values_page">
	<input type="hidden" name="print_eval_work">
	<input type="hidden" name="print_evaluation">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>