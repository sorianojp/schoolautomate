<%@ page language="java" import="utility.*,java.util.Vector,hr.HRTamiya" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
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
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
</style>
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">

	var openImg = new Image();
	openImg.src = "../../../images/box_with_minus.gif";
	var closedImg = new Image();
	closedImg.src = "../../../images/box_with_plus.gif";
	
	function showBranch(branch){
		var objBranch = document.getElementById(branch).style;
		if(objBranch.display=="block")
			objBranch.display="none";
		else
			objBranch.display="block";
	}
	
	function swapFolder(img){
		objImg = document.getElementById(img);
		if(objImg.src.indexOf('box_with_plus.gif')>-1)
			objImg.src = openImg.src;
		else
			objImg.src = closedImg.src;
	}
	
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
			
			vTotal = (vFactor1*20) + (vFactor2*15) + (vFactor3*15) + (vFactor4*30) + (vFactor5*20);
			objCOA.innerHTML = vTotal;
		}
	}

	function ViewAppraisal(strInfoIndex){
		var pgLoc = "./hr_personnel_perf_appraisal_view.jsp?opner_form_name=form_&is_view=1&info_index="+strInfoIndex;	
		var win=window.open(pgLoc,"ViewAppraisal",'width=900,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}

	function CancelOperation(){	
		document.form_.print_page.value = "";
		document.form_.info_index.value = "";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.app_date.value = "";
		document.form_.rp_index.value = "";
		document.form_.perf_remark1.value = "";
		document.form_.perf_remark2.value = "";
		document.form_.perf_remark3.value = "";
		document.form_.perf_remark4.value = "";
		
		for(var i=1; i<6; i++){
			eval('document.form_.factor_'+i+'.value=""');
			eval('document.form_.remarks_'+i+'.value=""');
		}
		
		this.ViewPerfAppraisal();
	}

	function ViewPerfAppraisal(){
		document.form_.view_perf_appraisal.value = "1";
		document.form_.submit();
	}
	
	function PrintPg(strInfoIndex){
		document.form_.print_page.value = "1";
		document.form_.info_index.value = strInfoIndex;
		this.ViewPerfAppraisal();
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
		document.form_.print_page.value = "";
		this.ViewPerfAppraisal();
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this performance appraisal?'))
				return;
		}
		document.form_.page_action.value = strAction;
		document.form_.print_page.value = "";
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		this.ViewPerfAppraisal();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.print_page.value = "";
		this.ViewPerfAppraisal();
	}
	
	function loadDept() {
		var objCOA=document.getElementById("load_total");
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
	
	if (bolMyHome)
		iAccessLevel = 2;
	
	if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Personnel-Notice of Action","hr_personnel_perf_appraisal.jsp");
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
	
	//add security here
	if (WI.fillTextValue("print_page").length() > 0){
		strTemp = "./hr_personnel_perf_appraisal_print.jsp";
		if(bolMyHome)
			strTemp += "?my_home=1";
	%>
		<jsp:forward page="<%=strTemp%>" />
	<% 
		return;}
	
	boolean bolIsSupervisor = false;
	Vector vEmpRec = null;
	Vector vRetResult = null;
	Vector vEditInfo = null;
	
	HRTamiya tamiya = new HRTamiya();
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	
	if(WI.fillTextValue("view_perf_appraisal").length() > 0){
		enrollment.Authentication authentication = new enrollment.Authentication();
		vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	
		if (vEmpRec == null || vEmpRec.size() == 0){
			if (strErrMsg == null || strErrMsg.length() == 0)
				strErrMsg = authentication.getErrMsg();
		}
		
		if(vEmpRec != null && vEmpRec.size() > 0){
			bolIsSupervisor = tamiya.isSupervisor(dbOP, request, (String)vEmpRec.elementAt(0));
			
			if(bolMyHome && !bolIsSupervisor){
				vEmpRec = null;
				strErrMsg = "Not allowed to view performance appraisal. You are not the supervisor of this employee.";
			}
			else{
				strTemp = WI.fillTextValue("page_action");
				if(strTemp.length() > 0){
					if(tamiya.operateOnPerfAppraisal(dbOP, request, Integer.parseInt(strTemp)) == null)
						strErrMsg = tamiya.getErrMsg();
					else{
						if(strTemp.equals("0"))
							strErrMsg = "Performance appraisal successfully removed.";
						if(strTemp.equals("1"))
							strErrMsg = "Performance appraisal successfully recorded.";
						if(strTemp.equals("2"))
							strErrMsg = "Performance appraisal successfully edited.";
						
						strPrepareToEdit = "0";
					}
				}
				
				vRetResult = tamiya.operateOnPerfAppraisal(dbOP, request, 4);
				if(vRetResult == null && !bolIsSupervisor)
					strErrMsg = tamiya.getErrMsg();
					
				if(strPrepareToEdit.equals("1")) {
					vEditInfo = tamiya.operateOnPerfAppraisal(dbOP, request,3);
					if(vEditInfo == null)
						strErrMsg = tamiya.getErrMsg();
				}
			}
		}
	}
	
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="FocusField();ReloadTotal();">
<form action="hr_personnel_perf_appraisal.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: PERFORMANCE APPRAISAL FORM ::::</strong></font></td>
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
			<td width="25%">
				<input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('emp_id','emp_id_');">
				<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
			<td width="55%" valign="top">&nbsp;<label id="emp_id_" style="position:absolute; width:350px"></label></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td colspan="2">
				<a href="javascript:ViewPerfAppraisal();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
	    </tr>
	</table>
	
<%if(vEmpRec != null && vEmpRec.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="5"><hr size="1"></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td width="15%">Name:</td>
		    <td width="27%"><%=WI.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3), 4)%></td>
			<td width="15%">ID No: </td>
			<td width="40%"><%=WI.fillTextValue("emp_id")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Position Title: </td>
		    <td><%=(String)vEmpRec.elementAt(15)%></td>
		    <td>Sec./Dept.</td>
		    <td>
				<%
					if((String)vEmpRec.elementAt(11)== null || (String)vEmpRec.elementAt(12)== null)
						strTemp = " ";			
					else
						strTemp = " - ";
				%>      		
	   			<%=WI.getStrValue((String)vEmpRec.elementAt(13),"")%>
				<%=strTemp%>
				<%=WI.getStrValue((String)vEmpRec.elementAt(14),"")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Date of Hiring: </td>
		    <td><%=(String)vEmpRec.elementAt(6)%></td>
		    <td>Emp. Status: </td>
		    <td><%=(String)vEmpRec.elementAt(16)%></td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
	</table>
	
<%if(bolIsSupervisor){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="2">
				<div onClick="showBranch('perfTable');swapFolder('perfFolder')">
					&nbsp;<img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="perfFolder">
					&nbsp;<strong><font color="#0000FF">View/hide Sample Table</font></strong></div>
				<span class="branch" id="perfTable">
				<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
					<tr>
						<td height="20" colspan="2" class="thinborder">&nbsp;Criteria</td>
						<td class="thinborder">&nbsp;Rating</td>
					</tr>
					<tr>
						<td height="25" colspan="3" class="thinborder">&nbsp;1. Job Knowledge (20)</td>
					</tr>
					<tr>
					  	<td height="25" width="3%" class="thinborder">&nbsp;</td>
					 	<td width="87%" class="thinborderBOTTOM">a.) Has exceptional mastery and understanding of all phases of his job</td>
					  	<td width="10%" class="thinborder">5</td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">b.) Has throrough knowledge and understanding of almost all phases of his job </td>
					  	<td class="thinborder">4</td>
				  	</tr>
					<tr>
						<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">c.) Knowledge and understanding of the job is adequate to carry on normal job requirement </td>
					  	<td class="thinborder">3</td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">d.) Knowledge and understanding of the job is insufficient, Needs follow-up and checking </td>
					  	<td class="thinborder">2</td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">e.) Knowledge and understanding of the job is very inadequate; Helpless, needs a lot of coaching from immediate supervisor </td>
					  	<td class="thinborder">1</td>
					</tr>
					<tr>
					 	 <td height="25" colspan="3" class="thinborder">&nbsp;2.) Quality of Work (15) </td>
					</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
				      	<td class="thinborderBOTTOM">a.) Requires absolute minimum supervision; result almost always accurate; zero defect </td>
				      	<td class="thinborder">5</td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">b.) Requires little supervision, exact and precise most of the time; no reject /mistake most of the time </td>
					  	<td class="thinborder">4</td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">c.) Usually accurate, makes only average %age of rejects/ mistakes </td>
					  	<td class="thinborder">3</td>
				  	</tr>
					<tr>
						<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">d.) Careless, often makes errors; high percentage of rejects/ mistakes </td>
					  	<td class="thinborder">2</td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">e.) Makes frequent errors, very high percentage of errors/ rejects </td>
					  	<td class="thinborder">1</td>
				  	</tr>
					<tr>
					  	<td height="25" colspan="3" class="thinborder">&nbsp;3.) Quantity of Work (15) </td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
				      	<td class="thinborderBOTTOM">a.) Superior work production record; meets 50% or more than the requirement </td>
				      	<td class="thinborder">5</td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">b.) Good productivity; meets 25% or more than the requirement </td>
					  	<td class="thinborder">4</td>
					</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">c.) Productivity is satisfactory; meets expected requirement/ quota </td>
					  	<td class="thinborder">3</td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">d.) Productivity does not meet requirement; about 25% less of the requirement </td>
					  	<td class="thinborder">2</td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">e.) Productivity is highly problematic </td>
					  	<td class="thinborder">1</td>
				  	</tr>
					<tr>
					  	<td height="25" colspan="3" class="thinborder">&nbsp;4.) Attendance (30) </td>
				 	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
				      	<td class="thinborderBOTTOM">a.) Perfect attendance on the job; No leave, no tardy, no undertime </td>
				      	<td class="thinborder">5</td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">b.) Very good attendance on the job; leave within credited, no tardy </td>
					  	<td class="thinborder">4</td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">c.) Good attendance; Absences after credited leave without prior approval; no tardy </td>
					  	<td class="thinborder">3</td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">d.) Frequently absent or late for trivial reasons </td>
					  	<td class="thinborder">2</td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">e.) Shows little concern for time lost for work; high record of tardiness, absences and undertime w/o prior approval; issued with written warning </td>
					  	<td class="thinborder">1</td>
				  	</tr>
					<tr>
					  	<td height="25" colspan="3" class="thinborder">&nbsp;5.) Attitude toward Work and the Company (20)</td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
				      	<td class="thinborderBOTTOM">a.) Shows very high regard for ones job and the company; very cooperative and strong force for group morale</td>
				      	<td class="thinborder">5</td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">b.) Shows markes interest and pride for his job and the company; cooperates willingly and can work well with others </td>
					  	<td class="thinborder">4</td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
					 	<td class="thinborderBOTTOM">c.) Shows interest in the company and his work as ordinarily expected; cooperates, if asked </td>
					 	<td class="thinborder">3</td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">d.) Sometimes indifferent; limited cooperation; sometimes difficult to work with </td>
					  	<td class="thinborder">2</td>
				  	</tr>
					<tr>
					  	<td height="25" class="thinborder">&nbsp;</td>
					  	<td class="thinborderBOTTOM">e.) Lacks interest in his work and the company; very low regard for his work; critical about the comany; reluctant to cooperate; difficult to work with others </td>
					  	<td class="thinborder">1</td>
				  	</tr>
				</table>
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
					<tr>
						<td height="15">&nbsp;</td>
					</tr>
				</table>
				</span>
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Appraisal Date: 
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
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
		    <td>Appraisal Period Covered: 
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(18);
					else
						strTemp = WI.fillTextValue("rp_index");
				%>
				<select name="rp_index">
					<option value="">Select Appraisal Period</option>
					<%=dbOP.loadCombo("rp_index","rp_title"," from hr_lhs_review_period where is_valid = 1 "+
						"order by period_open_fr desc ",strTemp,false)%>
				</select></td>
	    </tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td width="40%" align="center">Criteria/Factor</td>
		    <td width="11%" align="center">Weight</td>
			<td width="11%" align="center">Rating</td>
			<td width="35%" align="center">Remarks</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>1.) Job Knowledge </td>
			<td align="center">20</td>
			<td align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(4);
					else
						strTemp = WI.fillTextValue("factor_1");
				%>
				<input type="text" name="factor_1" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','factor_1');ReloadTotal();style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','factor_1')" size="5" maxlength="10" /></td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(9), "");
					else
						strTemp = WI.fillTextValue("remarks_1");
				%>
				<input name="remarks_1" type="text" size="32" value="<%=strTemp%>" class="textbox"
					maxlength="128"	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>2.) Quality of Work </td>
			<td align="center">15</td>
			<td align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("factor_2");
				%>
				<input type="text" name="factor_2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','factor_2');ReloadTotal();style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','factor_2')" size="5" maxlength="10" /></td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(10), "");
					else
						strTemp = WI.fillTextValue("remarks_2");
				%>
		    	<input name="remarks_2" type="text" size="32" value="<%=strTemp%>" class="textbox"
					maxlength="128"	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>3.) Quantity of Work </td>
			<td align="center">15</td>
			<td align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(6);
					else
						strTemp = WI.fillTextValue("factor_3");
				%>
				<input type="text" name="factor_3" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','factor_3');ReloadTotal();style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','factor_3')" size="5" maxlength="10" /></td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(11), "");
					else
						strTemp = WI.fillTextValue("remarks_3");
				%>
		    	<input name="remarks_3" type="text" size="32" value="<%=strTemp%>" class="textbox"
					maxlength="128"	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>4.) Attendance </td>
			<td align="center">30</td>
			<td align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(7);
					else
						strTemp = WI.fillTextValue("factor_4");
				%>
				<input type="text" name="factor_4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','factor_4');ReloadTotal();style.backgroundColor='white'" value="<%=strTemp%>" 
					onkeyup="AllowOnlyFloat('form_','factor_4')" size="5" maxlength="10" /></td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(12), "");
					else
						strTemp = WI.fillTextValue("remarks_4");
				%>
		    	<input name="remarks_4" type="text" size="32" value="<%=strTemp%>" class="textbox"
					maxlength="128"	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>5.) Attitude Toward Work and the Company </td>
			<td align="center">20</td>
			<td align="center">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(8);
					else
						strTemp = WI.fillTextValue("factor_5");
				%>
				<input type="text" name="factor_5" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','factor_5');ReloadTotal();style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','factor_5')" size="5" maxlength="10" /></td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(13), "");
					else
						strTemp = WI.fillTextValue("remarks_5");
				%>
				<input name="remarks_5" type="text" size="32" value="<%=strTemp%>" class="textbox"
					maxlength="128"	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Total</td>
			<td align="center">100</td>
			<td align="center"><label id="load_total">0</label></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
			<td><strong><u>Performance Summary</u></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%">Strengths</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = WI.getStrValue((String)vEditInfo.elementAt(14), "");
				else
					strTemp = WI.getStrValue(WI.fillTextValue("perf_remark1"),"");
			%>
				<textarea name="perf_remark1" style="font-size:12px" cols="100" rows="3" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Continuous Improvement</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = WI.getStrValue((String)vEditInfo.elementAt(15), "");
				else
					strTemp = WI.getStrValue(WI.fillTextValue("perf_remark2"),"");
			%>
				<textarea name="perf_remark2" style="font-size:12px" cols="100" rows="3" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Additional Comments </td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = WI.getStrValue((String)vEditInfo.elementAt(16), "");
				else
					strTemp = WI.getStrValue(WI.fillTextValue("perf_remark3"),"");
			%>
				<textarea name="perf_remark3" style="font-size:12px" cols="100" rows="3" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td><strong><u>Career Development Plan </u></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Development and Actions </td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = WI.getStrValue((String)vEditInfo.elementAt(17), "");
				else
					strTemp = WI.getStrValue(WI.fillTextValue("perf_remark4"),"");
			%>
				<textarea name="perf_remark4" style="font-size:12px" cols="100" rows="3" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="center">
			<%
			if(iAccessLevel > 1){%>
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
				Not authorized to add/edit performance appraisal.
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
		  	<td height="20" colspan="4" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF PERSONNEL APPRAISAL ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder" width="10%"><strong>Count</strong></td>
		    <td align="center" class="thinborder" width="25%"><strong>Appraisal Date </strong></td>
			<td align="center" class="thinborder" width="35%"><strong>Appraisal Period Covered</strong></td>
			<td align="center" class="thinborder" width="30%"><strong>Options</strong></td>
		</tr>
		<%	int iCount = 1;
			for(int i = 0; i < vRetResult.size(); i+=19, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%> - <%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder" align="center">
				<%if(iAccessLevel > 1){
					if(bolIsSupervisor){%>
						<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
							<img src="../../../images/edit.gif" border="0"></a>
						<%if(iAccessLevel == 2){%>
							<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
								<img src="../../../images/delete.gif" border="0"></a>
						<%}
					}
					else{%>
						<a href="javascript:ViewAppraisal('<%=(String)vRetResult.elementAt(i)%>');">
							<img src="../../../images/view.gif" border="0"></a>
					<%}
				}%>
				<a href="javascript:PrintPg('<%=(String)vRetResult.elementAt(i)%>')">
					<img src="../../../images/print.gif" border="0"></a></td>
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
	
	<input type="hidden" name="view_perf_appraisal">
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="print_page">
	<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%

dbOP.cleanUP();
%>