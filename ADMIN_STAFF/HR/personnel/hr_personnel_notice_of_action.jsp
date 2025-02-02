<%@ page language="java" import="utility.*,java.util.Vector,hr.HRTamiya" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Notice of Personnel Action</title>
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

	function ViewPersonnelNotice(){
		document.form_.view_personnel_notice.value = "1";
		document.form_.submit();
	}
	
	function PrintPg(strInfoIndex){
		document.form_.print_page.value = "1";
		document.form_.info_index.value = strInfoIndex;
		this.ViewPersonnelNotice();
	}
	
	function OpenSearch() {
		var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
		var win=window.open(pgLoc,"OpenSearch",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
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
		this.ViewPersonnelNotice();
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this seminar position?'))
				return;
		}
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		this.ViewPersonnelNotice();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		this.ViewPersonnelNotice();
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
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Personnel-Notice of Action","hr_personnel_notice_of_action.jsp");
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
		<jsp:forward page="./hr_personnel_notice_of_action_print.jsp" />
	<% 
		return;}
	
	Vector vEmpRec = null;
	Vector vRetResult = null;
	Vector vEditInfo = null;
	
	HRTamiya tamiya = new HRTamiya();
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	
	if(WI.fillTextValue("view_personnel_notice").length() > 0){
		enrollment.Authentication authentication = new enrollment.Authentication();
		vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	
		if (vEmpRec == null || vEmpRec.size() == 0){
			if (strErrMsg == null || strErrMsg.length() == 0)
				strErrMsg = authentication.getErrMsg();
		}
		
		if(vEmpRec != null && vEmpRec.size() > 0){
			strTemp = WI.fillTextValue("page_action");
			if(strTemp.length() > 0){
				if(tamiya.operateOnPersonnelNotice(dbOP, request, Integer.parseInt(strTemp)) == null)
					strErrMsg = tamiya.getErrMsg();
				else{
					if(strTemp.equals("0"))
						strErrMsg = "Personnel notice successfully removed.";
					if(strTemp.equals("1"))
						strErrMsg = "Personnel notice successfully recorded.";
					if(strTemp.equals("2"))
						strErrMsg = "Personnel notice successfully edited.";
					
					strPrepareToEdit = "0";
				}
			}
			
			vRetResult = tamiya.operateOnPersonnelNotice(dbOP, request, 4);
			//if(vRetResult == null && strTemp.length() == 0)
				//strErrMsg = tamiya.getErrMsg();
				
			if(strPrepareToEdit.equals("1")) {
				vEditInfo = tamiya.operateOnPersonnelNotice(dbOP, request,3);
				if(vEditInfo == null)
					strErrMsg = tamiya.getErrMsg();
			}
		}
	}
		
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="FocusField()">
<form action="hr_personnel_notice_of_action.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: NOTICE OF PERSONNEL ACTION ::::</strong></font></td>
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
				<a href="javascript:ViewPersonnelNotice();">
					<img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to view personnel notices.</font></td>
	    </tr>
	</table>
	
<%if(vEmpRec != null && vEmpRec.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="7"><hr size="1"></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td width="20%">Name of Employee: </td>
		    <td width="35%" class="thinborderBOTTOM">
				<%=WI.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3), 4)%></td>
		    <td width="5%">&nbsp;</td>
		    <td width="14%">ID #: </td>
			<td width="20%" class="thinborderBOTTOM"><%=WI.fillTextValue("emp_id")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Employment Status: </td>
			<td class="thinborderBOTTOM"><%=(String)vEmpRec.elementAt(16)%></td>
			<td>&nbsp;</td>
			<td>Date of Hiring: </td>
			<td class="thinborderBOTTOM"><%=(String)vEmpRec.elementAt(6)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Division:</td>
			<td class="thinborderBOTTOM"><%=(String)vEmpRec.elementAt(13)%></td>
			<td>&nbsp;</td>
			<td>Group:</td>
			<td class="thinborderBOTTOM">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="7"></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		    <td>I. Nature of Action: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0){
						strTemp = (String)vEditInfo.elementAt(1);
						
						if(Integer.parseInt(strTemp) > 0)
							strTemp = "checked";
						else
							strTemp = "";
					}
					else{
						strTemp = WI.fillTextValue("is_employment");					
					
						if(strTemp.length() > 0)
							strTemp = " checked";				
						else
							strTemp = "";
					}
				%>
				<input name="is_employment" type="checkbox" value="1"<%=strTemp%> onClick="ViewPersonnelNotice();">Employment</td>
			<td>
				<%if(strTemp.length() > 0){
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.getStrValue(WI.fillTextValue("is_regular"), "1");

					if(strTemp.equals("1")){
						strTemp = " checked";
						strErrMsg = "";
					}
					else{
						strTemp = "";
						strErrMsg = " checked";
					}%>
					<input type="radio" name="is_regular" value="1"<%=strTemp%>>Regular
					&nbsp;
  		  			<input type="radio" name="is_regular" value="2"<%=strErrMsg%>>Others
				<%}%></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0){
						strTemp = (String)vEditInfo.elementAt(2);
						
						if(Integer.parseInt(strTemp) > 0)
							strTemp = "checked";
						else
							strTemp = "";
					}
					else{
						strTemp = WI.fillTextValue("is_promotion");					
					
						if(strTemp.length() > 0)
							strTemp = " checked";				
						else
							strTemp = "";
					}
				%>
				<input name="is_promotion" type="checkbox" value="1"<%=strTemp%>>Promotion</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0){
						strTemp = (String)vEditInfo.elementAt(3);
						
						if(Integer.parseInt(strTemp) > 0)
							strTemp = "checked";
						else
							strTemp = "";
					}
					else{
						strTemp = WI.fillTextValue("is_skill_level");					
					
						if(strTemp.length() > 0)
							strTemp = " checked";				
						else
							strTemp = "";
					}
				%>
				<input name="is_skill_level" type="checkbox" value="1"<%=strTemp%>>Skill Level</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0){
						strTemp = (String)vEditInfo.elementAt(4);
						
						if(Integer.parseInt(strTemp) > 0)
							strTemp = "checked";
						else
							strTemp = "";
					}
					else{
						strTemp = WI.fillTextValue("is_demotion");					
					
						if(strTemp.length() > 0)
							strTemp = " checked";				
						else
							strTemp = "";
					}
				%>
				<input name="is_demotion" type="checkbox" value="1"<%=strTemp%>>Demotion</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0){
						strTemp = (String)vEditInfo.elementAt(5);
						
						if(Integer.parseInt(strTemp) > 0)
							strTemp = "checked";
						else
							strTemp = "";
					}
					else{
						strTemp = WI.fillTextValue("is_transfer");					
					
						if(strTemp.length() > 0)
							strTemp = " checked";				
						else
							strTemp = "";
					}
				%>
				<input name="is_transfer" type="checkbox" value="1"<%=strTemp%> onClick="ViewPersonnelNotice();">Transfer</td>
			<td>
				<%if(strTemp.length() > 0){
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.getStrValue(WI.fillTextValue("inter_division"), "1");

					if(strTemp.equals("1")){
						strTemp = " checked";
						strErrMsg = "";
					}
					else{
						strTemp = "";
						strErrMsg = " checked";
					}%>
					<input type="radio" name="inter_division" value="1"<%=strTemp%>>Inter-division
					&nbsp;
  		  			<input type="radio" name="inter_division" value="2"<%=strErrMsg%>>Inter-group
				<%}%></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td>Others: 
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(6), "");
					else
						strTemp = WI.fillTextValue("others");
				%>
				<input type="text" name="others" value="<%=strTemp%>" class="textbox" maxlength="64"
	  				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		    <td>Specify: 
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(7), "");
					else
						strTemp = WI.fillTextValue("specify");
				%>
				<input type="text" name="specify" value="<%=strTemp%>" class="textbox" maxlength="64"
	  				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>II. Date of Effectivity:  </td>
		    <td colspan="2">
				<%
					if (vEditInfo != null && vEditInfo.size() > 0) 
						strTemp = (String)vEditInfo.elementAt(8);
					else{
						strTemp = WI.fillTextValue("eff_date"); 
						if(strTemp.length() == 0)
							strTemp = WI.getTodaysDate(1);
					}
				%>
				<input name="eff_date" type="text" size="16" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">&nbsp; 
				<a href="javascript:show_calendar('form_.eff_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td colspan="3">III.</td>
	    </tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td align="center" width="23%">&nbsp;</td>
		    <td width="30%">Current</td>
		    <td>New Status </td>
	    </tr>
		<% 	
			String strCollegeIndex = null;
			if(vEditInfo != null && vEditInfo.size() > 0)
				strCollegeIndex = WI.getStrValue((String)vEditInfo.elementAt(16), "");
			else
				strCollegeIndex = WI.fillTextValue("c_index");
		%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;&nbsp;&nbsp;&nbsp;Division</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0){
						strTemp = (String)vEditInfo.elementAt(10);
						strErrMsg = (String)vEditInfo.elementAt(23);
					}
					else{
						strTemp = (String)vEmpRec.elementAt(11);
						strErrMsg = (String)vEmpRec.elementAt(13);
					}
				%>
				<input type="hidden" name="cur_division" value="<%=strTemp%>">
				<%=WI.getStrValue(strErrMsg, "&nbsp;")%></td>
			<td>
				<select name="c_index" onChange="loadDept();">
					<option value="">N/A</option>
					<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;&nbsp;&nbsp;&nbsp;Section</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0){
						strTemp = (String)vEditInfo.elementAt(9);
						strErrMsg = (String)vEditInfo.elementAt(24);
					}
					else{
						strTemp = (String)vEmpRec.elementAt(12);
						strErrMsg = (String)vEmpRec.elementAt(14);
					}
				%>
				<input type="hidden" name="cur_section" value="<%=strTemp%>">
				<%=WI.getStrValue(strErrMsg, "&nbsp;")%></td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(15), "");
					else
						strTemp = WI.fillTextValue("d_index");
				%>
				<label id="load_dept">
				<select name="d_index">
					<option value="">ALL</option>
					<%if (strCollegeIndex.length() == 0){%>
						<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", strTemp,false)%> 
					<%}else if (strCollegeIndex.length() > 0){%>
						<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , strTemp,false)%> 
					<%}%>
				</select></label></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;&nbsp;&nbsp;&nbsp;Position</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0){
						strTemp = (String)vEditInfo.elementAt(11);
						strErrMsg = (String)vEditInfo.elementAt(25);
					}
					else{
						strTemp = (String)vEmpRec.elementAt(9);
						strErrMsg = (String)vEmpRec.elementAt(15);
					}
				%>
				<input type="hidden" name="cur_position" value="<%=strTemp%>">
              	<%=WI.getStrValue(strErrMsg, "&nbsp;")%></td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(16), "");
					else
						strTemp = WI.fillTextValue("emp_type_index");
				%>
				<select name="emp_type_index">
					<option value="">Select Group / Position </option>
					<%=dbOP.loadCombo("emp_type_index","emp_type_name",
						" FROM hr_employment_type where is_del = 0 " +
						" order by position_order, emp_type_name",strTemp,false)%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;&nbsp;&nbsp;&nbsp;Pay Class/Grade </td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;&nbsp;&nbsp;&nbsp;Salary</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;&nbsp;&nbsp;&nbsp;Allowance</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td colspan="3">IV. Reason for Action: </td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td colspan="3">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(21), "");
					else
						strTemp = WI.fillTextValue("reason");
				%>
				<textarea name="reason" style="font-size:12px" onFocus="style.backgroundColor='#D3EBFF'" 
					cols="80" rows="3" class="textbox" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
        </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td colspan="3">V. Remarks or Other Conditions of this Personnel Action: </td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td colspan="3">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(22), "");
					else
						strTemp = WI.fillTextValue("remarks");
				%>
				<textarea name="remarks" style="font-size:12px" onFocus="style.backgroundColor='#D3EBFF'" 
					cols="80" rows="3" class="textbox" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
        </tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" align="center" colspan="4">
			<%
			if(iAccessLevel > 1){%>
				<%if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
				<%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
					<%}
				}
			}else{%>
				Not authorized to add/edit personnel notice of action.
			<%}%>			</td>
		</tr>
	</table>

	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="5" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF PERSONNEL NOTICES ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder" width="5%"><strong>Count</strong></td>
		    <td align="center" class="thinborder" width="15%"><strong>Effective Date </strong></td>
			<td align="center" class="thinborder" width="35%"><strong>Reason</strong></td>
			<td align="center" class="thinborder" width="15%"><strong>Status</strong></td>
			<td align="center" class="thinborder" width="35%"><strong>Options</strong></td>
		</tr>
		<%	int iCount = 1;
			for(int i = 0; i < vRetResult.size(); i+=30, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+8)%></td>
		    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+21), "&nbsp;")%></td>
		    <td class="thinborder">
				<%
					strTemp = (String)vRetResult.elementAt(i+26);
					if(strTemp.equals("0"))
						strTemp = "Disapproved";
					if(strTemp.equals("1"))
						strTemp = "Approved";
					if(strTemp.equals("2"))
						strTemp = "Pending";
				%><%=strTemp%></td>
		    <td align="center" class="thinborder">			
				<%if(iAccessLevel > 1){
					if(strTemp.equals("Pending")){%>
						<a href="javascript:PageAction('5','<%=(String)vRetResult.elementAt(i)%>');">APPROVE</a>&nbsp;
						<a href="javascript:PageAction('6','<%=(String)vRetResult.elementAt(i)%>');">DISAPPROVE</a><br>
						
						<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
							<img src="../../../images/edit.gif" border="0"></a>
						<%if(iAccessLevel == 2){%>
							<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
								<img src="../../../images/delete.gif" border="0"></a>
						<%}
					}
				}%>		
				<a href="javascript:PrintPg('<%=(String)vRetResult.elementAt(i)%>')">
					<img src="../../../images/print.gif" border="0"></a>		
			</td>
		</tr>
		<%}%>
	</table>
	<%}
}%>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="view_personnel_notice">
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>