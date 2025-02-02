<%@ page language="java" import="utility.*,java.util.Vector,hr.HRPIT" %>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Old Service Record</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript">

	function OpenSearch() {
		var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
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
	
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1"+
		"&name_format=4&complete_name="+escape(strCompleteName);
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		objCOAInput.value = strID;
		objCOA.innerHTML = "";
		this.getServiceRecord();
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	function ReloadPage(){
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.info_index.value = "";
		this.getServiceRecord();
	}
	
	function getServiceRecord(){
		document.form_.get_service_record.value = "1";
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
		var loadPg = "../../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
		"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
		"&opner_form_name=form_&opner_form_field="+strFormField;
		
		var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function CancelOperation(strEmpID){
		location = "./govt_old_service_rcd.jsp?get_service_record=1&emp_id="+strEmpID;
	}
	
	function loadBranch(){
		document.form_.office_branch.value = document.form_.branch_preload.value;
	}
	
	function loadStation(){
		document.form_.office_station.value = document.form_.station_preload.value;
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to service record?'))
				return;
		}
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.print_page.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PrintPg(){
		document.form_.print_page.value = "1";
		document.form_.submit();
	}
	
</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./govt_old_service_rcd_print.jsp" />
	<% 
		return;}
		
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-OLD SERVICE RECORD MGMT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Reports and Statistics-Lighthouse Certification","govt_old_service_rcd.jsp");
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

	HRPIT hrPIT = new HRPIT();
	Vector vUserInfo = null;
	Vector vRetResult = null;
	Vector vEditInfo = null;
	
	String strPreviousDesignation = null;
	String strPreviousStatus = null;
	String strPreviousStation = null;
	String strPreviousBranch = null;
	String strPreviouseAbsences = null;
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	
	if(WI.fillTextValue("emp_id").length() > 0 || WI.fillTextValue("get_service_record").length() > 0){
		vUserInfo = hrPIT.getInfoForOldServiceRecord(dbOP, request);
		if(vUserInfo == null)
			strErrMsg = hrPIT.getErrMsg();
		else{
			strTemp = WI.fillTextValue("page_action");

			if(strTemp.length() > 0) {
				if(hrPIT.operateOnGovtOldServiceRecord(dbOP, request, Integer.parseInt(strTemp), (String)vUserInfo.elementAt(0)) == null)
					strErrMsg = hrPIT.getErrMsg();
				else {
					if(strTemp.equals("0"))
						strErrMsg = "Service record successfully removed.";
					if(strTemp.equals("1"))
						strErrMsg = "Service record successfully recorded.";
					if(strTemp.equals("2"))
						strErrMsg = "Service Record successfully edited.";
					
					strPrepareToEdit = "0";
				}
			}
		
			vRetResult = hrPIT.operateOnGovtOldServiceRecord(dbOP, request, 4, (String)vUserInfo.elementAt(0));	
			
			//get vEditInfo if it is called..
			if(strPrepareToEdit.equals("1")) {
				vEditInfo = hrPIT.operateOnGovtOldServiceRecord(dbOP, request, 3, (String)vUserInfo.elementAt(0));
				if(vEditInfo == null)
					strErrMsg = hrPIT.getErrMsg();
			}
		}
	}

%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="document.form_.emp_id.focus();">
<form action="govt_old_service_rcd.jsp" method="post" name="form_">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
			<font color="#FFFFFF" ><strong>:::: SERVICE RECORD ::::</strong></font></td>
		</tr>
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="4"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr> 
			<td width="3%" height="25">&nbsp;</td>
			<td width="15%">Employee ID</td>
			<td width="15%" height="25">
			<input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('emp_id','emp_id_');"></td>
			<td width="5%" height="25">
				<a href="javascript:OpenSearch();">
					<img src="../../../../images/search.gif" width="37" height="30" border="0"></a></td>
			<td width="62%" height="25" colspan="3"><label id="emp_id_"></label></td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
	  	  	<td colspan="3">
				<a href="javascript:getServiceRecord()"><img src="../../../../images/form_proceed.gif" border="0"></a>
       	   	 	<font size="1">click to get old service record </font></td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
	</table>

<%if(vUserInfo != null && vUserInfo.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="15" colspan="7"><hr size="1" color="#000000"></td>
		</tr>
		<tr> 
			<td height="25" colspan="3">&nbsp;<strong>EMPLOYEE INFORMATION: </strong></td>
		</tr>
		<tr> 
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr> 
			<td width="3%" height="25">&nbsp;</td>
		    <td width="17%">Name:</td>
		    <td width="80%"><%=WebInterface.formatName((String)vUserInfo.elementAt(1),(String)vUserInfo.elementAt(2),(String)vUserInfo.elementAt(3),7)%></td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td height="25">Birthday:</td>
			<td><%=WI.getStrValue((String)vUserInfo.elementAt(4), "&nbsp;")%></td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td height="25">Place of Birth :</td>
			<td><%=WI.getStrValue((String)vUserInfo.elementAt(5), "&nbsp;")%></td>
		</tr>
		<tr> 
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td width="3%" height="25">&nbsp;</td>
		    <td width="17%">Date From:</td>
	    <td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("date_fr");
				%>
				<input name="date_fr" type= "text"  class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="32" maxlength="255" 
			onBlur="style.backgroundColor='white';">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
		   onmouseover="window.status='Select date';return true;" 
		   onmouseout="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Date To: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(2));
					else
						strTemp = WI.fillTextValue("date_to");
				%>
				<input name="date_to" type= "text"  class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="32" maxlength="255" 
			onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
		   onmouseover="window.status='Select date';return true;" 
		   onmouseout="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Designation:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.getStrValue(WI.fillTextValue("designation"), "");
				%>
				<select name="designation">
					 <option value="">Select Designation</option>
         			 <%=dbOP.loadCombo("SAL_GRADE_INDEX","GRADE_NAME"," FROM HR_PRELOAD_SAL_GRADE order by grade_name",strTemp,false)%> 
				</select>
				&nbsp;&nbsp;
				<a href='javascript:viewList("HR_PRELOAD_SAL_GRADE","SAL_GRADE_INDEX","GRADE_NAME","SALARY GRADE",
					"HR_SALARY_GRADE,HR_INFO_SERVICE_RCD","SAL_GRADE_INDEX, SAL_GRADE_INDEX", 
					" and HR_SALARY_GRADE.is_del = 0, and HR_INFO_SERVICE_RCD.is_del = 0","","sal_grade_index")'>
				<img src="../../../../images/update.gif" border="0"></a>
				<font size="1">add an EMPLOYEE DESIGNATION to list</font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Status:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(7);
					else
						strTemp = WI.fillTextValue("status");
				%>
				<select name="status">
					<option value="">Select Status</option>
					<%=dbOP.loadCombo("status_index","status"," from user_status where is_for_student=0 order by status asc",strTemp, false)%> 
        </select>
				&nbsp;&nbsp;
				<a href='javascript:viewList("user_status","status_index","status","EMPLOYEE STATUS",
		  			"USER_TABLE,USER_TABLE,HR_INFO_EMP_HIST,HR_APPL_INFO_EMP_HIST,HR_INFO_SERVICE_RCD",
					"CURRENT_STATUS,ENTRY_STATUS,EMP_STATUS_INDEX,EMP_STATUS_INDEX,STATUS",
					" and user_table.is_del = 0 and user_table.is_valid = 1, and user_table.is_del=0 and 
					user_table.is_valid = 1, and HR_INFO_EMP_HIST.is_del =0 and HR_INFO_EMP_HIST.is_valid =1,
					and HR_APPL_INFO_EMP_HIST.is_del = 0 and HR_APPL_INFO_EMP_HIST.is_valid =1,
					and HR_INFO_SERVICE_RCD.IS_VALID=1 and HR_INFO_SERVICE_RCD.is_del = 0 ", " is_for_student = 0","status_index")'>
				<img src="../../../../images/update.gif" border="0"></a> 
                <font size="1"> add an EMPLOYMENT STATUS to list</font>			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Salary</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(9);
					else
						strTemp = WI.fillTextValue("salary");
				%>
				<input type="text" name="salary" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="16" maxlength="256" value="<%=WI.getStrValue(strTemp)%>"/> 
				<strong>(in Php)</strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Station: </td>
			<td>
				<%
					strTemp = 
						" from hr_srec_old_govt where is_valid = 1 and user_index = "+(String)vUserInfo.elementAt(0)+
						" order by office_station";
				%>
				<select name="station_preload" onChange="javascript:loadStation();">
					<option value="">Select Existing Station</option>
					<%=dbOP.loadCombo("distinct office_station","office_station",strTemp,WI.fillTextValue("station_preload"),false)%>
				</select>
				&nbsp;&nbsp;
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(11);
					else
						strTemp = WI.fillTextValue("office_station");
				%>
				 <input type="text" name="office_station" value="<%=WI.getStrValue(strTemp)%>" class="textbox" size="48" maxlength="256"
				 	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Branch: </td>
			<td>
				<%
					strTemp = 
						" from hr_srec_old_govt where is_valid = 1 and user_index = "+(String)vUserInfo.elementAt(0)+
						" order by office_branch";
				%>
				<select name="branch_preload" onChange="javascript:loadBranch();">
					<option value="">Select Existing Branch</option>
					<%=dbOP.loadCombo("distinct office_branch","office_branch",strTemp,WI.fillTextValue("branch_preload"),false)%>
				</select>
				&nbsp;&nbsp;
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(12);
					else
						strTemp = WI.fillTextValue("office_branch");
				%>
				 <input type="text" name="office_branch" value="<%=WI.getStrValue(strTemp)%>" class="textbox" size="48" maxlength="256"
				 	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>L/V ABS w/o Pay: </td>
			<td rowspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(13));
					else
						strTemp = WI.fillTextValue("leaves");
				%>
				<textarea name="leaves" style="font-size:12px" cols="65" rows="3" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Separation Date: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(14));
					else
						strTemp = WI.fillTextValue("separation_date");
				%>
				<input name="separation_date" type= "text"  class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="10" maxlength="10" 
			onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','separation_date','/');" 
			onKeyUp="AllowOnlyIntegerExtn('form_','separation_date','/');">
        <a href="javascript:show_calendar('form_.separation_date');" title="Click to select date" 
		   onmouseover="window.status='Select date';return true;" 
		   onmouseout="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Separation Cause: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(15));
					else
						strTemp = WI.fillTextValue("separation_cause");
				%>
				 <input type="text" name="separation_cause" value="<%=strTemp%>" class="textbox" size="48" maxlength="256"
				 	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Remarks: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(16));
					else
						strTemp = WI.fillTextValue("remarks");
				%>
				 <input type="text" name="remarks" value="<%=strTemp%>" class="textbox" size="48" maxlength="256"
				 	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Order number</td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(17));
					else
						strTemp = WI.fillTextValue("order_no");
					strTemp = WI.getStrValue(strTemp);
				%>			
		  <td><input name="order_no" type= "text"  class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="6" maxlength="8" 
			onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','order_no','.');" 
			onKeyUp="AllowOnlyIntegerExtn('form_','order_no','.');"></td>
	  </tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../../images/save.gif" border="0"></a>
				<%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
							<img src="../../../../images/edit.gif" border="0"></a>
					<%}
				}%>
				<a href="javascript:CancelOperation('<%=WI.fillTextValue("emp_id")%>')">
		<img src="../../../../images/cancel.gif" border="0"></a>		</tr>
	</table>
<%}

if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
		  	<td height="25" colspan="2" align="right">
		  		<font size="2">Number of Rows Per Page :</font>
				<select name="num_rec_page">
				<% 
				int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
				for(int i = 10; i <=40 ; i++) {
					if ( i == iDefault) {%>
						<option selected value="<%=i%>"><%=i%></option>
					<%}else{%>
						<option value="<%=i%>"><%=i%></option>
					<%}
				}%>
				</select>
				&nbsp;
				<a href="javascript:PrintPg()">
					<img src="../../../../images/print.gif" border="0"></a>
				<font size="1">click to service records</font></td>
		</tr>
		<tr>
		  <td height="25" align="right">Order  option : </td>
		  <td><select name="order_opt">
        <option value="asc">Ascending</option>
        <%if(WI.fillTextValue("order_opt").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
	  </tr>
		<tr>
		  <td width="19%" height="25" align="right">Certified by : </td>
	    <td width="81%"><input type="text" name="certified_by" value="<%=WI.fillTextValue("certified_by")%>" class="textbox" size="48" maxlength="256"
				 	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
		  <td height="25" align="right">Position : </td>
	    <td height="25"><input type="text" name="cert_position" value="<%=WI.fillTextValue("cert_position")%>" class="textbox" size="48" maxlength="256"
				 	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
	</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
			<td height="20" colspan="12" align="center" bgcolor="#B9B292" class="thinborder">
			  <strong>SERVICE RECORD </strong></td>
		</tr>
		<tr>
			<td height="30" align="center" class="thinborder" colspan="3"><strong>SERVICE<br>(Inclusive Dates)</strong></td>
			<td colspan="3" align="center" class="thinborder"><strong>RECORD OF APPOINTMENT</strong></td>
			<td colspan="2" align="center" class="thinborder"><strong>OFFICE ENTITY DIVISION</strong></td>
			<td rowspan="2" align="center" class="thinborder" width="8%"><strong>L/V ABS w/o PAY</strong><strong></strong></td>
			<td colspan="2" align="center" class="thinborder"><strong><u>SEPARATION</u><br>4</strong></td>
			<td width="10%" rowspan="2" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
		<tr>
		  <td align="center" class="thinborder" valign="top" width="3%">#</td>
			<td align="center" class="thinborder" valign="top" width="7%"><strong>From</strong></td>
			<td align="center" class="thinborder" valign="top" width="7%"><strong>To</strong></td>
			<td align="center" class="thinborder" valign="top" width="11%"><strong>Designation</strong></td>
			<td align="center" class="thinborder" valign="top" width="8%"><strong>Status<br><br>1</strong></td>
			<td align="center" class="thinborder" valign="top" width="14%"><strong>Salary<br><br>2</strong></td>
			<td align="center" class="thinborder" valign="top" width="14%"><strong>Station<br>Place of Assignment</strong></td>
			<td align="center" class="thinborder" valign="top" width="10%"><strong>Branch<br><br>3</strong></td>
			<td align="center" class="thinborder" valign="top" width="8%"><strong>Date</strong></td>
			<td align="center" class="thinborder" valign="top" width="10%"><strong>Cause</strong></td>
		</tr>
	<%
	int iCount = 0;	
	for(int i = 0; i < vRetResult.size(); i += 25){%>
		<tr>
		  <td align="center" class="thinborderLEFT"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+17), false)%></td>
			<td height="25" align="center" class="thinborderLEFT"><%=WI.getStrValue((String)vRetResult.elementAt(i+1), "&nbsp;")%></td>
			<td align="center" class="thinborderLEFT"><%=WI.getStrValue((String)vRetResult.elementAt(i+2), "&nbsp;")%></td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6));
				if(strPreviousDesignation != null){
					if(strTemp.equals(strPreviousDesignation))
						strTemp = "-do-";
					else
						strPreviousDesignation = strTemp;
				}
				else
					strPreviousDesignation = strTemp;
			%>
			<td align="center" class="thinborderLEFT"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			<%				
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+8));
				if(strPreviousStatus != null){
					if(strTemp.equals(strPreviousStatus))
						strTemp = "-do-";
					else
						strPreviousStatus = strTemp;
				}
				else
					strPreviousStatus = strTemp;
			%>			
			<td align="center" class="thinborderLEFT"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			<td align="right" class="thinborderLEFT">
				<%
				strTemp = (String)vRetResult.elementAt(i+9);
				if(strTemp != null && iCount == 0)
					iCount = 1;
					
				if(iCount==1){%>
					P&nbsp;&nbsp;
				<%}%>
				<%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			<%				
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+11));
				if(strPreviousStation != null){
					if(strTemp.equals(strPreviousStation))
						strTemp = "-do-";
					else
						strPreviousStation = strTemp;
				}
				else
					strPreviousStation = strTemp;
			%>	
			<td align="center" class="thinborderLEFT"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			<%				
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+12));
				if(strPreviousBranch != null){
					if(strTemp.equals(strPreviousBranch))
						strTemp = "-do-";
					else
						strPreviousBranch = strTemp;
				}
				else
					strPreviousBranch = strTemp;
			%>	
			<td align="center" class="thinborderLEFT"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+13), "None");
				if(strPreviouseAbsences != null){
					if(strTemp.equals(strPreviouseAbsences))
						strTemp = "-do-";
					else
						strPreviouseAbsences = strTemp;
				}
				else
					strPreviouseAbsences = strTemp;
			%>
			<td align="center" class="thinborderLEFT"><%=strTemp%></td>
			<%if((String)vRetResult.elementAt(i+16) != null && (String)vRetResult.elementAt(i+14) == null && (String)vRetResult.elementAt(i+15) == null){%>
				<td align="center" class="thinborderLEFT" colspan="2"><%=(String)vRetResult.elementAt(i+16)%></td>
			<%}else{%>
				<td align="center" class="thinborderLEFT"><%=WI.getStrValue((String)vRetResult.elementAt(i+14), "&nbsp;")%></td>
				<td align="center" class="thinborderLEFT"><%=WI.getStrValue((String)vRetResult.elementAt(i+15), "&nbsp;")%></td>
			<%}%>
			<td align="center" class="thinborderLEFTRIGHT">
			<%
			if(iAccessLevel > 1){%>
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../../images/edit.gif" border="0"></a>
				<%if(iAccessLevel == 2){%>
		  		<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../../images/delete.gif" border="0"></a>
				<%}
			}else{%>
				Not authorized.
			<%}%>			</td>
		</tr>
	<%}%>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" class="thinborderTOP">&nbsp;</td>
		</tr>
	</table>
<%}%>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="15" colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="get_service_record">
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