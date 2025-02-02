<%@ page language="java" import="utility.*,java.util.Vector,hr.HRTsuneishi" %>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Performance Appraisal</title>
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
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">

	function ReloadTotal(){
		if(document.form_.factor_1){
			var objCOA=document.getElementById("load_total");
			
			var vTotal = 0;
			var vFactor1 = document.form_.factor_1.value;
			if(vFactor1.length == 0)
				vFactor1 = 0;
				
			var vFactor2 = document.form_.factor_2.value;
			if(vFactor2.length == 0)
				vFactor2 = 0;
				
			var vFactor3 = document.form_.factor_3.value;
			if(vFactor3.length == 0)
				vFactor3 = 0;
				
			var vFactor4 = document.form_.factor_4.value;
			if(vFactor4.length == 0)
				vFactor4 = 0;
				
			var vFactor5 = document.form_.factor_5.value;
			if(vFactor5.length == 0)
				vFactor5 = 0;
				
			var vFactor6 = document.form_.factor_6.value;
			if(vFactor6.length == 0)
				vFactor6 = 0;
				
			var vFactor7 = document.form_.factor_7.value;
			if(vFactor7.length == 0)
				vFactor7 = 0;
				
			var vFactor8 = document.form_.factor_8.value;
			if(vFactor8.length == 0)
				vFactor8 = 0;
				
			var vFactor9 = document.form_.factor_9.value;
			if(vFactor9.length == 0)
				vFactor9 = 0;
			
			vTotal = eval(vFactor1) + eval(vFactor2) + eval(vFactor3) + eval(vFactor4) + eval(vFactor5) + 
					 eval(vFactor6) + eval(vFactor7) + eval(vFactor8) + eval(vFactor9);
			objCOA.innerHTML = vTotal;
		}
	}
	
	function FocusField(){
		document.form_.emp_id.focus();
	}

	function OpenSearch() {
		var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
		var win=window.open(pgLoc,"OpenSearch",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}

	function ViewDetails(strEvalIndex){
		var pgLoc = "./hr_personnel_nontechnial_details.jsp?is_technical=0&is_view=1&info_index="+strEvalIndex;	
		var win=window.open(pgLoc,"ViewDetails",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}

	function UpdatePeriods(){
		var pgLoc = "./hr_personnel_perf_appraisal_period.jsp?is_popup=1&opner_form_name=form_";	
		var win=window.open(pgLoc,"UpdatePeriods",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}

	function CancelOperation(){	
		document.form_.print_page.value = "";
		document.form_.info_index.value = "";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.app_date.value = "";
		document.form_.current_level.value = "";
		document.form_.rp_index.value = "";
		document.form_.target_level.value = "";
		document.form_.actual_level.value = "";
		document.form_.overall_rating.value = "";
		
		for(var i=1; i<10; i++){
			eval('document.form_.factor_'+i+'.value=""');
			eval('document.form_.rating_'+i+'.value=""');
		}
		
		document.form_.view_perf_appraisal.value = "1";
		document.form_.submit();
	}

	function ViewPerfAppraisal(){
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.view_perf_appraisal.value = "1";
		document.form_.submit();
	}
	
	function PrintPg(strInfoIndex){
		document.form_.print_page.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.view_perf_appraisal.value = "1";
		document.form_.submit();
	}
	
	function FocusField(){
		document.form_.emp_id.focus();
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
		document.form_.print_page.value = "";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.view_perf_appraisal.value = "1";
		document.form_.submit();
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this performance evaluation?'))
				return;
		}
		document.form_.page_action.value = strAction;
		document.form_.print_page.value = "";
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.view_perf_appraisal.value = "1";
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.print_page.value = "";
		document.form_.view_perf_appraisal.value = "1";
		document.form_.submit();
	}
	
	function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index&all=1";
		this.processRequest(strURL);
	}
	
	function ReloadPage(){
		document.form_.view_perf_appraisal.value = "1";
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
		
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-PERSONNEL"),"0"));
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
	
	if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Personnel-Performance Evaluation","hr_personnel_perf_appraisal_tun_nontechnical.jsp");
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
	
	//add security here.
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./hr_personnel_perf_appraisal_tun_nontechnical_print.jsp" />
	<% 
		return;}
	
	Vector vEmpRec = null;
	Vector vRetResult = null;
	Vector vEditInfo = null;
	int iSearchResult = 0;
	
	HRTsuneishi tun = new HRTsuneishi();
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	
	if(WI.fillTextValue("view_perf_appraisal").length() > 0){
		enrollment.Authentication authentication = new enrollment.Authentication();
		vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	
		if (vEmpRec == null || vEmpRec.size() == 0){
			if (strErrMsg == null || strErrMsg.length() == 0)
				strErrMsg = authentication.getErrMsg();
		}
		
		if(vEmpRec != null && vEmpRec.size() > 0){
			strTemp = WI.fillTextValue("page_action");
			if(strTemp.length() > 0){
				if(tun.operateOnPerfEvaluation(dbOP, request, Integer.parseInt(strTemp)) == null)
					strErrMsg = tun.getErrMsg();
				else{
					if(strTemp.equals("0"))
						strErrMsg = "Performance evaluation successfully removed.";
					if(strTemp.equals("1"))
						strErrMsg = "Performance evaluation successfully recorded.";
					if(strTemp.equals("2"))
						strErrMsg = "Performance evaluation successfully edited.";
					
					strPrepareToEdit = "0";
				}
			}
				
			vRetResult = tun.operateOnPerfEvaluation(dbOP, request, 4);
			if(vRetResult != null)
				iSearchResult = tun.getSearchCount();
				
			if(strPrepareToEdit.equals("1")) {
				vEditInfo = tun.operateOnPerfEvaluation(dbOP, request,3);
				if(vEditInfo == null)
					strErrMsg = tun.getErrMsg();
			}
		}	
	}
	
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="FocusField();ReloadTotal();">
<form action="hr_personnel_perf_appraisal_tun_nontechnical.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: PERFORMANCE EVALUATION  ::::</strong></font></td>
		</tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
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
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td colspan="2">
				<a href="javascript:ViewPerfAppraisal();">
					<img src="../../../images/form_proceed.gif" border="0"></a></td>
	    </tr>
	</table>
	
<%if(vEmpRec != null && vEmpRec.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="5"><hr size="1"></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td width="20%">Name:</td>
		    <td width="22%"><%=WI.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3), 4)%></td>
			<td width="20%">ID No: </td>
			<td width="35%"><%=WI.fillTextValue("emp_id")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Position : </td>
		    <td><%=(String)vEmpRec.elementAt(15)%></td>
		    <td>Employment Start </td>
		    <td><%=(String)vEmpRec.elementAt(6)%></td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Appraisal Date: </td>
		    <td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(6);
					else
						strTemp = WI.fillTextValue("app_date");
				%>
				<input name="app_date" type="text" size="16" maxlength="10" readonly="yes" value="<%=strTemp%>"
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">&nbsp; 
				<a href="javascript:show_calendar('form_.app_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td>Period Covered: </td>
	        <td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("rp_index");
				%>
				<select name="rp_index">
					<option value="">Select Appraisal Period</option>
					<%=dbOP.loadCombo("rp_index","rp_title"," from hr_lhs_review_period where is_valid = 1 "+
						"order by period_open_fr desc ",strTemp,false)%>
				</select>
				&nbsp;
				<a href="javascript:UpdatePeriods();"><img src="../../../images/update.gif" border="0"></a></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td height="25" width="35%">Skill Level (start of evaluation): </td>
		    <td height="25" width="62%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.fillTextValue("current_level");
				%>				
				<input name="current_level" type="text" size="32" value="<%=strTemp%>" class="textbox" maxlength="64"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td height="25">Target skill  Level (end of evaluation): </td>
		    <td height="25">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(4);
					else
						strTemp = WI.fillTextValue("target_level");
				%>				
				<input name="target_level" type="text" size="32" value="<%=strTemp%>" class="textbox" maxlength="64"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td height="25" colspan="2">Actual Result: 
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("actual_level");
				%>				
				<input name="actual_level" type="text" size="32" value="<%=strTemp%>" class="textbox" maxlength="64"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	    </tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" colspan="6" align="center" class="thinborder"><strong>EVALUATION FACTORS</strong></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder" width="3%">1</td>
			<td class="thinborder" width="67%">&nbsp;CONTRIBUTION TO ATTAINMENT OF OBJECTIVES </td>
			<td align="center" class="thinborderBOTTOM" width="5%">40%</td>
			<td align="center" class="thinborderBOTTOM" width="5%">&nbsp;</td>
			<td align="center" class="thinborder" width="10%">Points</td>
			<td align="center" class="thinborder" width="10%">Rating</td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Attendance Ratio</td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">20%</td>
			<td class="thinborder" align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(7);
					else
						strTemp = WI.fillTextValue("factor_1");
				%>
				<input type="text" name="factor_1" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','factor_1');ReloadTotal();style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','factor_1')" size="5" maxlength="10" /></td>
			<td class="thinborder" align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(17);
					else
						strTemp = WI.fillTextValue("rating_1");
				%>
				<input type="text" name="rating_1" class="textbox" value="<%=strTemp%>" size="5" maxlength="10"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"/></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Achieved the aligned objectives with the team </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">20%</td>
			<td class="thinborder" align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(8);
					else
						strTemp = WI.fillTextValue("factor_2");
				%>
				<input type="text" name="factor_2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','factor_2');ReloadTotal();style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','factor_2')" size="5" maxlength="10" /></td>
			<td class="thinborder" align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(18);
					else
						strTemp = WI.fillTextValue("rating_2");
				%>
				<input type="text" name="rating_2" class="textbox" value="<%=strTemp%>" size="5" maxlength="10"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"/></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder" width="3%">2</td>
			<td class="thinborder" width="67%">&nbsp;QUALITY &amp; QUANTITY OF WORK </td>
			<td align="center" class="thinborderBOTTOM" width="5%">30%</td>
			<td align="center" class="thinborderBOTTOM" width="5%">&nbsp;</td>
			<td align="center" class="thinborder" width="10%">Points</td>
			<td align="center" class="thinborder" width="10%">Rating</td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Quality level of outputs </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">10%</td>
			<td class="thinborder" align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(9);
					else
						strTemp = WI.fillTextValue("factor_3");
				%>
				<input type="text" name="factor_3" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','factor_3');ReloadTotal();style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','factor_3')" size="5" maxlength="10" /></td>
			<td class="thinborder" align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(19);
					else
						strTemp = WI.fillTextValue("rating_3");
				%>
				<input type="text" name="rating_3" class="textbox" value="<%=strTemp%>" size="5" maxlength="10"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"/></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Timeliness in submission of outputs </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">15%</td>
			<td class="thinborder" align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(10);
					else
						strTemp = WI.fillTextValue("factor_4");
				%>
				<input type="text" name="factor_4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','factor_4');ReloadTotal();style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','factor_4')" size="5" maxlength="10" /></td>
			<td class="thinborder" align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(20);
					else
						strTemp = WI.fillTextValue("rating_4");
				%>
				<input type="text" name="rating_4" class="textbox" value="<%=strTemp%>" size="5" maxlength="10"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"/></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Initiative of providing extra outputs </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">5%</td>
			<td class="thinborder" align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(11);
					else
						strTemp = WI.fillTextValue("factor_5");
				%>
				<input type="text" name="factor_5" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','factor_5');ReloadTotal();style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','factor_5')" size="5" maxlength="10" /></td>
			<td class="thinborder" align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(21);
					else
						strTemp = WI.fillTextValue("rating_5");
				%>
				<input type="text" name="rating_5" class="textbox" value="<%=strTemp%>" size="5" maxlength="10"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"/></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder" width="3%">3</td>
			<td class="thinborder" width="67%">&nbsp;JOB KNOWLEDGE &amp; SKILLS </td>
			<td align="center" class="thinborderBOTTOM" width="5%">5%</td>
			<td align="center" class="thinborderBOTTOM" width="5%">&nbsp;</td>
			<td align="center" class="thinborder" width="10%">Points</td>
			<td align="center" class="thinborder" width="10%">Rating</td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Applies appropriate skills in carrying out tasks </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">5%</td>
			<td class="thinborder" align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(12);
					else
						strTemp = WI.fillTextValue("factor_6");
				%>
				<input type="text" name="factor_6" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','factor_6');ReloadTotal();style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','factor_6')" size="5" maxlength="10" /></td>
			<td class="thinborder" align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(22);
					else
						strTemp = WI.fillTextValue("rating_6");
				%>
				<input type="text" name="rating_6" class="textbox" value="<%=strTemp%>" size="5" maxlength="10"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"/></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder" width="3%">4</td>
			<td class="thinborder" width="67%">&nbsp;ATTITUDE</td>
			<td align="center" class="thinborderBOTTOM" width="5%">25%</td>
			<td align="center" class="thinborderBOTTOM" width="5%">&nbsp;</td>
			<td align="center" class="thinborder" width="10%">Points</td>
			<td align="center" class="thinborder" width="10%">Rating</td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Compliance with company rules &amp; work attitude </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">15%</td>
			<td class="thinborder" align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(13);
					else
						strTemp = WI.fillTextValue("factor_7");
				%>
				<input type="text" name="factor_7" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','factor_7');ReloadTotal();style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','factor_7')" size="5" maxlength="10" /></td>
			<td class="thinborder" align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(23);
					else
						strTemp = WI.fillTextValue("rating_7");
				%>
				<input type="text" name="rating_7" class="textbox" value="<%=strTemp%>" size="5" maxlength="10"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"/></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Supports team, group, company activities and undertakings </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">5%</td>
			<td class="thinborder" align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(14);
					else
						strTemp = WI.fillTextValue("factor_8");
				%>
				<input type="text" name="factor_8" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','factor_8');ReloadTotal();style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','factor_8')" size="5" maxlength="10" /></td>
			<td class="thinborder" align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(24);
					else
						strTemp = WI.fillTextValue("rating_8");
				%>
				<input type="text" name="rating_8" class="textbox" value="<%=strTemp%>" size="5" maxlength="10"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"/></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Punctuality </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">5%</td>
			<td class="thinborder" align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(15);
					else
						strTemp = WI.fillTextValue("factor_9");
				%>
				<input type="text" name="factor_9" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','factor_9');ReloadTotal();style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','factor_9')" size="5" maxlength="10" /></td>
			<td class="thinborder" align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(25);
					else
						strTemp = WI.fillTextValue("rating_9");
				%>
				<input type="text" name="rating_9" class="textbox" value="<%=strTemp%>" size="5" maxlength="10"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"/></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right" width="80%">Total Points: &nbsp;</td>
		    <td width="10%"><label id="load_total">0</label></td>
		    <td width="10%">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" align="right">Overall Rating: &nbsp;</td>
		    <td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(27));
					else
						strTemp = WI.fillTextValue("overall_rating");
				%>
				<input type="text" name="overall_rating" class="textbox" value="<%=strTemp%>" size="10" maxlength="10"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"/></td>
	    </tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="center">
			<%if(iAccessLevel > 1){%>
				<%if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
				<%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
					<%}
				}%>
				
				<a href="javascript:CancelOperation();"><img src="../../../images/cancel.gif" border="0"></a>
			<%}else{%>
				Not authorized.
			<%}%></td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
<%}

if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="6" bgcolor="#B9B292" class="thinborder" align="center">
				<div><strong>::: LIST OF NON-TECHNICAL PERSONNEL EVALUATIONS ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="4">
				<strong>Total Results: <%=iSearchResult%> - 
					Showing(<strong><%=WI.getStrValue(tun.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="2">&nbsp;
			<%
			if(WI.fillTextValue("view_all").length() == 0){
				int iPageCount = 1;
				iPageCount = iSearchResult/tun.defSearchSize;		
				if(iSearchResult % tun.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+tun.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="ViewPerfAppraisal();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i =1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}}%></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder" width="5%"><strong>Count</strong></td>
		    <td align="center" class="thinborder" width="12%"><strong>Date<br>Prepared</strong></td>			
			<td align="center" class="thinborder" width="29%"><strong>Evaluation Period </strong></td>
			<td align="center" class="thinborder" width="12%"><strong>Total<br>Points </strong></td>
			<td align="center" class="thinborder" width="12%"><strong>Overall<br>Rating</strong></td>
			<td align="center" class="thinborder" width="30%"><strong>Options</strong></td>
		</tr>
		<%	int iCount = 1;
			double dOverall = 0d;
			for(int i = 0; i < vRetResult.size(); i+=28, iCount++){
				dOverall = 
					Double.parseDouble((String)vRetResult.elementAt(i+7)) + Double.parseDouble((String)vRetResult.elementAt(i+8)) +
					Double.parseDouble((String)vRetResult.elementAt(i+9)) + Double.parseDouble((String)vRetResult.elementAt(i+10)) +
					Double.parseDouble((String)vRetResult.elementAt(i+11)) + Double.parseDouble((String)vRetResult.elementAt(i+12)) +
					Double.parseDouble((String)vRetResult.elementAt(i+13)) + Double.parseDouble((String)vRetResult.elementAt(i+14)) +
					Double.parseDouble((String)vRetResult.elementAt(i+15)) + Double.parseDouble((String)vRetResult.elementAt(i+16));%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>			
			<td class="thinborder">&nbsp;<%=CommonUtil.formatFloat(dOverall, true)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+27), "&nbsp;")%></td>
			<td class="thinborder" align="center">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
							<img src="../../../images/delete.gif" border="0"></a>
					<%}
				}%>
				<a href="javascript:ViewDetails('<%=(String)vRetResult.elementAt(i)%>')">
					<img src="../../../images/view.gif" border="0"></a>
				<a href="javascript:PrintPg('<%=(String)vRetResult.elementAt(i)%>')">
					<img src="../../../images/print.gif" border="0"></a></td>
		</tr>
		<%}%>
	</table>
<%}%>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="view_perf_appraisal">
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="print_page">
	<input type="hidden" name="is_technical" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
