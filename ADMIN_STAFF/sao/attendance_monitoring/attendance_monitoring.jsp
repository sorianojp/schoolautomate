<%@ page language="java" import="utility.*, enrollment.AttendanceMonitoringCDD, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

<style type="text/css">

 /*this is what we want the div to look like*/
  div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:0;
	top:0;
    width:350px;
	height:200;/** it expands on its own.. **/
    
    /*give it some background and border
    background:#007fb7;*/
	background:#FFCC99;
    border:1px solid #ddd;
  }


</style>

<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script language="javascript" src ="../../../jscript/common.js" ></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">

function UpdateStatusNoExam(strAttendanceIndex, strStatus){
	if(strStatus == "1"){
		if(!confirm("Do you want to set to No Exam?"))
			return;
	}else{
		if(!confirm("Do you want to remove No Exam grade?"))
			return;
	}
	
	if(strAttendanceIndex != '')
		document.form_.attendance_index_.value = strAttendanceIndex;
	document.form_.update_no_exam.value = strStatus;
	document.form_.page_action.value = "";	
	document.form_.submit();
}

function ReloadPage()
{
	document.form_.submit();
}

function UpdateStatusClaimed(strAction, strStat, strUpdateFromList, strAttendanceIndex){
	var strTemp = "";
	if(strStat == '1')
		strTemp = "Claimed?";
	else
		strTemp = "Unclaimed?";
	
	if(!confirm("Do you want to set the status to "+strTemp))
		return;
		
	if(strAttendanceIndex != '')
		document.form_.attendance_index_.value = strAttendanceIndex;
	
	document.form_.status_.value = strStat;
	document.form_.page_action.value = strAction;	
	document.form_.update_from_list.value = strUpdateFromList;
	document.form_.update_no_exam.value = "";
	document.form_.submit();
}

function SetFocusID(){
	document.form_.stud_id.focus();
}

function UpdateStatusDropped(strAction, strStat, strUpdateFromList, strAttendanceIndex){
	var strTemp = "";
	if(strStat == '1')
		strTemp = "drop";
	else
		strTemp = "undrop";

	if(!confirm("Do you want to "+strTemp+" the student in this subject?"))
		return;
	
	document.form_.drop_reason.value = prompt("Reason");
	
	if(strAttendanceIndex != '')
		document.form_.attendance_index_.value = strAttendanceIndex;

	document.form_.status_.value = strStat;
	document.form_.page_action.value = strAction;
	document.form_.update_from_list.value = strUpdateFromList;
	document.form_.update_no_exam.value = "";
	document.form_.submit();
}

function ChangeMaxAbsences(){
	if(!confirm("Do you want to change change the value of maximum absences?"))
		return;
	
	document.form_.page_action.value = '9';
	document.form_.update_no_exam.value = "";
	document.form_.submit();
}

function PageAction(strAction, strInfoIndex, strAttendanceIndex){
	if(strAction == '0'){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}
	
	if(strAttendanceIndex.length > 0)
		document.form_.attendance_index_.value = strAttendanceIndex;
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	
	document.form_.update_no_exam.value = "";	
	document.form_.page_action.value = strAction;
	document.form_.submit();


}

function HideLayer(strDiv) {			
	document.getElementById(strDiv).style.visibility = 'hidden';
	document.form_.show_claimed_cc.checked = false;
}

function ShowLayer(strDiv) {	
	if(document.form_.show_claimed_cc.checked)	
		document.getElementById(strDiv).style.visibility = 'visible';
	else
		document.getElementById(strDiv).style.visibility = 'hidden';
}

function PrintLetter(strUserIndex){
	var pgLoc = "./format_letter_to_parent.jsp?user_index="+strUserIndex+
	"&sy_from="+document.form_.sy_from.value+
	"&offering_sem="+document.form_.offering_sem.value;
	var win=window.open(pgLoc,"PrintLetter",'width=900,height=700,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.update_no_exam.value = "";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

function PrintPermit(strAttendanceIndex){
	if(strAttendanceIndex.length == 0)
		return;
	var pgLoc = "format_admission_slip_print.jsp?attendance_index="+strAttendanceIndex;
	var win=window.open(pgLoc,"PrintPermit",'width=700,height=500,top=0,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}

</script>
</head>
<body bgcolor="#D2AE72" onLoad="SetFocusID();HideLayer('processing2');">
<%
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("STUDENT AFFAIRS-STUDENT TRACKER"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("STUDENT AFFAIRS"),"0"));
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
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"STUDENT AFFAIRS-STUDENT TRACKER","attendance_monitoring.jsp");
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
Vector vStudDtls  = null;
Vector vCCStatus  = new Vector();
Vector vClaimedCC = new Vector();
Vector vCCNotClaimed = new Vector();
Vector vSubDropped = new Vector();
Vector vSubNoExam = new Vector();

AttendanceMonitoringCDD attendanceCDD = new AttendanceMonitoringCDD();

if(WI.fillTextValue("update_no_exam").length() > 0){
	if(!attendanceCDD.setSubjToNoExam(dbOP, request))
		strErrMsg = attendanceCDD.getErrMsg();
	else
		strErrMsg = "Entry Successfully Updated.";
}

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	vRetResult = attendanceCDD.operateOnAttendanceMonitoringCDD(dbOP, request, Integer.parseInt(strTemp));
	if(vRetResult == null)
		strErrMsg = attendanceCDD.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg = "Entry Successfully Deleted.";
		if(strTemp.equals("1"))
			strErrMsg = "Entry Successfully Saved.";
		if(strTemp.equals("2"))
			strErrMsg = "Entry Successfully Updated.";
			
		if(strTemp.equals("6") && vRetResult.size() == 1){%>
			<script>PrintPermit('<%=vRetResult.elementAt(0)%>')</script>
		<%}
		
	}
}

String strErrMsg2 = null;	
if(WI.fillTextValue("stud_id").length()>0){
	vStudDtls = attendanceCDD.operateOnAttendanceMonitoringCDD(dbOP, request, 5);
	if(vStudDtls == null)
		strErrMsg = attendanceCDD.getErrMsg();
	else{
		vRetResult = attendanceCDD.operateOnAttendanceMonitoringCDD(dbOP, request, 4);
		if(vRetResult == null)
			strErrMsg = attendanceCDD.getErrMsg();
		//else if(vRetResult != null && vRetResult.size() > 0 && bolIsQuery){
			vCCNotClaimed = attendanceCDD.operateOnAttendanceMonitoringCDD(dbOP, request, 10);
			//if(vCCNotClaimed == null)
			//	strErrMsg = attendanceCDD.getErrMsg();
			vSubDropped = attendanceCDD.operateOnAttendanceMonitoringCDD(dbOP, request, 11);
			//if(vSubDropped == null)
			//	strErrMsg = attendanceCDD.getErrMsg();
			
			vSubNoExam = attendanceCDD.generateExamPeriodWithNoExam(dbOP, request);
			
			vClaimedCC = attendanceCDD.operateOnAttendanceMonitoringCDD(dbOP, request, 12);	
			if(vClaimedCC == null)
				strErrMsg2 = attendanceCDD.getErrMsg();
		//}	
		vCCStatus = attendanceCDD.operateOnAttendanceMonitoringCDD(dbOP, request, 8);		
	}
}


String strBGColor = null;
%>
<form action="./attendance_monitoring.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>::::
          ATTENDANCE MONITORING ::::</strong></font></div></td>
    </tr>
    <tr >
	<td height="25" colspan="3">&nbsp; &nbsp; &nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
	<td rowspan="3" valign="top">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr>
				
				<td valign="top" width="32%">
					
					<%if(vCCNotClaimed != null && vCCNotClaimed.size() > 0){%>
					<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
						<tr>
							<td colspan="2" align="center" class="thinborder"><strong>Unclaimed Class Card</strong></td>
						</tr>
						<!--<tr>
							<td class="thinborder">Subj Code</td>							
							<td class="thinborder">Option</td>
						</tr>-->
						
						<%
						for(int i = 0; i < vCCNotClaimed.size(); i+=4){
						%>
						<tr bgcolor="#CCCCCC" onDblClick="UpdateStatusClaimed('6','1','1','<%=(String)vCCNotClaimed.elementAt(i)%>');">
							<td class="thinborder"><%=WI.getStrValue((String)vCCNotClaimed.elementAt(i+2))%></td>							
							<!--<td class="thinborder">
								<input type="button" name="update_cc" value="Claim" style="height:15px;" 
									onClick="">
							</td>-->
						</tr>
						<%}%>
						
					</table>
					<%}%>
				</td>
				
				<td width="1%">&nbsp;</td>
				
				<td valign="top" width="32%">				
				<%if(vSubDropped != null && vSubDropped.size() > 0){%>
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
					<tr>
						<td colspan="2" align="center" class="thinborder"><strong>Dropped Subject</strong></td>
					</tr>
					<!--<tr>
						<td class="thinborder">Subj Code</td>						
						<td class="thinborder">Option</td>
					</tr>-->
					
					<%
						for(int i = 0; i < vSubDropped.size(); i+=4){
					%>
					<tr bgcolor="#CCCCCC" onDblClick="UpdateStatusDropped('7','0', '1', '<%=(String)vSubDropped.elementAt(i)%>');">
						<td class="thinborder"><%=WI.getStrValue((String)vSubDropped.elementAt(i+2))%></td>						
						<!--<td class="thinborder">
							<input type="button" name="update_cc" value="Undropped" onClick="">
						</td>-->
					</tr>
					<%}%>
				</table>
				<%}%>
				</td>
				
				<td width="1%">&nbsp;</td>
				
				<td valign="top" width="34%">		
				<%if(vSubNoExam != null && vSubNoExam.size() > 0){%>						
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
					<tr>
						<td colspan="2" align="center" class="thinborder"><strong>No Exam List</strong></td>
					</tr>
					<!--<tr>
						<td class="thinborder">Subj Code</td>						
						<td class="thinborder">Exam Period</td>
					</tr>-->
					
					<%
					for(int i = 0; i < vSubNoExam.size(); i+=3){
					%>
					<tr bgcolor="#CCCCCC" onDblClick="UpdateStatusNoExam('<%=vSubNoExam.elementAt(i)%>','0');">
						<td class="thinborder"><%=WI.getStrValue((String)vSubNoExam.elementAt(i+2))%></td>												
					</tr>
					<%}%>
				</table>
				<%}%>
				</td>
				
				
			</tr>
		</table>
	</td>
	</tr>

	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="15%">SY/Term</td>		
		<td width="35%">			
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
			%>
			<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			-
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
			%>
			<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				
			<%
			strTemp = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>
			<select name="offering_sem">
			<%if(strTemp.equals("1")){%>
				<option value="1" selected>1st Sem</option>
			<%}else{%>
				<option value="1">1st Sem</option>
			
			<%}if(strTemp.equals("2")){%>
				<option value="2" selected>2nd Sem</option>
			<%}else{%>
				<option value="2">2nd Sem</option>
				
			<%}if(strTemp.equals("3")){%>
				<option value="3" selected>3rd Sem</option>
			<%}else{%>
				<option value="3">3rd Sem</option>
			
			<%}if(strTemp.equals("0")){%>
				<option value="0" selected>Summer</option>
			<%}else{%>
				<option value="0">Summer</option>
			<%}%>
			</select></td>		
	</tr>
	
    <tr>
      <td height="25" width="3%"></td>
      <td width="15%">Student ID</td>
	  <%strTemp = WI.fillTextValue("stud_id");%>
      <td width=""><input name="stud_id" type="text" class="textbox" size="20" maxlength="20" value="<%=strTemp%>" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">        &nbsp; &nbsp; 
      	<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" align="absmiddle"></a>
		<a href="javascript:ReloadPage();">
      	<img src="../../../images/form_proceed.gif" border="0"></a>		</td>
      
    </tr>
	
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
	</tr>
	
        
  </table>
<%if (vStudDtls!= null && vStudDtls.size()>0){
String strUpdateStat = null;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr >
      <td height="25" colspan="5"><hr size="1">      </td>
    </tr>
	<tr>
		<td>&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("show_claimed_cc");
		if(strTemp.equals("1"))
			strTemp = "checked";
		else
			strTemp = "";
		%>
		<td colspan="2">
			<input type="checkbox" value="1" name="show_claimed_cc" onClick="ShowLayer('processing2');" <%=strTemp%> />
			<font size="1">Click to show claimed classcard</font>		</td>
	</tr>
	<tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%" height="25">Student Name </td>
      <td width="51%" height="25"><strong><%=(String)vStudDtls.elementAt(1)%></strong></td>
	  
	  
	    
	  <td width="31%">
	  <%
	  if(vCCStatus != null && vCCStatus.size() > 0 && WI.fillTextValue("enroll_index").length() > 0){
	  	if(((String)vCCStatus.elementAt(0)).equals("1")){
			strBGColor = "#0033FF";
			strTemp = "Class card is claimed";
			strUpdateStat = "0";
		}else{
			strBGColor = "#FF0000";
			strTemp = "Class card is unclaimed";
			strUpdateStat = "1";
		}	  
	  %>
	  <font color="<%=strBGColor%>"><strong><%=strTemp%></strong></font>
	  <a href="javascript:UpdateStatusClaimed('6','<%=strUpdateStat%>','','');">
	  <img src="../../../images/update.gif" border="0" align="absmiddle"></a>	 <%}%> </td>    
	  
    </tr>
	
	
	<tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%" height="25">Subject  </td>
	  <%
	  strTemp = WI.fillTextValue("enroll_index");
	  
	  String strTemp2 = " from subject join curriculum on (curriculum.sub_index = subject.sub_index) "+
	  	" join enrl_final_cur_list on (enrl_final_cur_list.cur_index = curriculum.cur_index) "+
		" where enrl_final_cur_list.sy_from = "+WI.fillTextValue("sy_from")+" and enrl_final_cur_list.current_semester = "+WI.fillTextValue("offering_sem")+
		" and is_temp_stud = 0 and enrl_final_cur_list.is_valid = 1 "+
		" and user_index = "+(String)vStudDtls.elementAt(0)+" order by sub_code";
	  
	  
	  %>
      <td height="25">
	  <select name="enroll_index" style="width:200px;" onChange="document.form_.submit();">
	  <option value=""></option>
	  <%=dbOP.loadCombo("enroll_index","sub_code, sub_name", strTemp2, strTemp, false)%> 
	  </select>	  </td>
	        
      <td height="25">
	  <%
	  if(vCCStatus != null && vCCStatus.size() > 0  && WI.fillTextValue("enroll_index").length() > 0){
	  	if(((String)vCCStatus.elementAt(1)).equals("1")){
			strBGColor = "#FF0000";
			strTemp = "Subject Dropped";
			strUpdateStat = "0";
		}else{
			strBGColor = "#0033FF";
			strTemp = "Set Subject to Drop";
			strUpdateStat = "1";
		}
	  %>
	  <font color="<%=strBGColor%>"><strong><%=strTemp%></strong></font>	  
	  <a href="javascript:UpdateStatusDropped('7','<%=strUpdateStat%>','','');">
	  <img src="../../../images/update.gif" border="0" align="absmiddle"></a>
	  <%}%>
	  </td>
	</tr>
	
	<%
	if(WI.fillTextValue("enroll_index").length() > 0){
	%>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Number of Absences  </td>
	<%
	//get the max no of that entry for every student.
	strTemp2 = WI.fillTextValue("enroll_index");
	String strTemp3 = null;	
	if(strTemp2.length() > 0){	
		strTemp = "select MAX_NO_ABSENCES from CDD_ATTENDANCE_MAIN "+
			" where sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("offering_sem")+
			" and user_index = "+(String)vStudDtls.elementAt(0)+" and enroll_index = "+strTemp2;
		strTemp3 = dbOP.getResultOfAQuery(strTemp, 0);
	}
	%>	
	
		<td>
		<select name="no_of_absences"  <%if(vCCStatus != null && vCCStatus.size() > 0){%>onChange="ChangeMaxAbsences();"<%}%>>
		<%
		strTemp = WI.fillTextValue("no_of_absences");
		if(strTemp.equals("24"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="24" <%=strErrMsg%>>108-hour (max 24hrs absences)</option>
		<%
		if(strTemp.equals("20"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="20" <%=strErrMsg%>>90-hour (max 20hrs absences)</option>
				
		<%
		if(strTemp.equals("12"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="12" <%=strErrMsg%>>54-hour (max 12 hrs absences)</option>
				
		<%
		if(strTemp.equals("8"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="8" <%=strErrMsg%>>36-hour (max 8 hrs absences) </option>
			</select>		</td>
		<td>
		<%
	  if(WI.fillTextValue("enroll_index").length() > 0){
	  	
			strBGColor = "#0033FF";
			strTemp = "Set Subject to No Exam";
			strUpdateStat = "1";
		
	  %>
	  <font color="<%=strBGColor%>"><strong><%=strTemp%></strong></font>	  
	  <a href="javascript:UpdateStatusNoExam('','1');">
	  <img src="../../../images/update.gif" border="0" align="absmiddle"></a>
	  
	  <select name="pmt_sch_index">
	  <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME", " from fa_pmt_schedule where is_valid = 1 and BSC_GRADING_NAME is not null order by EXAM_PERIOD_ORDER", WI.fillTextValue("pmt_sch_index"), false)%>
	  </select>
	  
	  <%}%>
		</td>
	</tr>
	
	<tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%" height="25">Day of Absent  </td>
      <td width="51%" height="25">
	  		<input name="day_absent" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
				value="<%=WI.fillTextValue("day_absent")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<a href="javascript:show_calendar('form_.day_absent');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
			<img src="../../../images/calendar_new.gif" border="0"></a>	  </td>	  
	  <td width="31%">&nbsp;</td>  
    </tr>
	
	
	<tr> 
      <td height="25">&nbsp;</td>
      <td>Reason </td>
	  <%
	  strTemp = WI.fillTextValue("reason");	  
	  %>
      <td colspan="2">
	  	<textarea name="reason" cols="48" rows="3" class="textbox" 
			id="reason" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
    </tr>
	
	<tr><td colspan="4">&nbsp;</td></tr>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td colspan="2">
		<a href="javascript:PageAction('1','','');">
		<img src="../../../images/save.gif" border="0"></a>
		<font size="1">Click to save</font>		</td>
	</tr>
	
	<%}%>
	<tr><td colspan="4">&nbsp;</td></tr>
  </table>
<%

if (vRetResult!= null && vRetResult.size()>0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="right" height="25">
	<a href="javascript:PrintLetter('<%=(String)vStudDtls.elementAt(0)%>')">
	<img src="../../../images/print.gif" border="0"></a>
	<font size="1">Click to print letter</font>
	</td></tr>
	</table>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td class="thinborder" height="25" align="" width="14%"><strong>Subect Code</strong></td>
			<td class="thinborder" align="" width="23%"><strong>Subect Name</strong></td>
			<td class="thinborder" align="center" width="13%"><strong>Date Absent</strong></td>
			<td class="thinborder" align="center" width="14%"><strong>No of Hours</strong></td>
			<td width="29%" align="" class="thinborder"><strong>Reason</strong></td>
			<td class="thinborder" align="" width="7%"><strong>Option</strong></td>
		</tr>
		
		<%
		
		String strColor = null;
		String strCurCode = null;
		String strPrevCode = "";
		
		//String[] astrMin = {"","","","","","30 mins","","","","","","","","",""};
		String[] astrMin = new String[30];
		astrMin[5] = "30 mins";
		
		
		
		String[] astrHrAbsent = null;
		String strHrAbsent = null;
		int iCount = 0;
		
		for(int i = 0; i < vRetResult.size(); i+=8){
			strCurCode = (String)vRetResult.elementAt(i+3);
			
			
			strHrAbsent = (String)vRetResult.elementAt(i+7);
			if( strHrAbsent != null && strHrAbsent.length() > 0){
				iCount = 0;
				astrHrAbsent = new String[strHrAbsent.length()];
				while(strHrAbsent.indexOf(".") > -1) {
					astrHrAbsent[iCount] = strHrAbsent.substring(0, strHrAbsent.indexOf("."));
					strHrAbsent = strHrAbsent.substring(strHrAbsent.indexOf(".")+1);
					++iCount;
				}
				
				if(strHrAbsent.length() > 0)
					astrHrAbsent[iCount] = strHrAbsent;
					
				if(astrHrAbsent != null && astrHrAbsent.length >= 2){
					strHrAbsent = null;
					if(astrHrAbsent[0] != null && astrHrAbsent[0].length() > 0)
						strHrAbsent = astrHrAbsent[0]+" Hr(s)";
					if(astrHrAbsent[1] != null && astrHrAbsent[1].length() > 0)
						strHrAbsent += WI.getStrValue(astrMin[Integer.parseInt(astrHrAbsent[1])]," ","","");
				}
			}
			
			
			if(strColor == null)
				strColor = "#999999";
			else{
				if(strColor.equals("#999999") && !strPrevCode.equals(strCurCode))
					strColor = "#FFFFFF";
				else{
					if(strColor.equals("#FFFFFF") && strPrevCode.equals(strCurCode))
						strColor = "#FFFFFF";
					else
						strColor = "#999999";				
				}
					
			}
		%>
		
		<tr>
			<td bgcolor="<%=strColor%>" class="thinborder" height="25"><%=strCurCode%></td>
			<td bgcolor="<%=strColor%>" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4))%></td>
			<td bgcolor="<%=strColor%>" class="thinborder" align="center"><%=vRetResult.elementAt(i+5)%></td>
			<td bgcolor="<%=strColor%>" class="thinborder" align="center"><%=WI.getStrValue(strHrAbsent,"&nbsp;")%></td>
			<td bgcolor="<%=strColor%>" class="thinborder" align=""><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%></td>
			<td class="thinborder" align="">
			<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>','<%=(String)vRetResult.elementAt(i+1)%>')">
			<img src="../../../images/delete.gif" border="0"></a>
			</td>
		</tr>
		
		<%
			strPrevCode = strCurCode;
		}%>
	</table>

<%}//end vRetResult not null%>


<div id="processing2" class="processing">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL" bgcolor="#9999CC">
	<tr><td valign="top" align="right"><a href="javascript:HideLayer('processing2')">Close Window X</a></td></tr>	  	  
<%if(strErrMsg2 != null){%>
  	<tr><td valign="top"><font size="3"><strong><%=WI.getStrValue(strErrMsg2)%></strong></font></td></tr>
<%
}
if(vClaimedCC != null && vClaimedCC.size() > 0){
%>
  <tr><td valign="top" align="center"><u><b>LIST OF CLAIMED CLASS CARD</b></u></td></tr>
  <tr>
	  <td valign="top">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td width="30%" valign="top">Subj Code</td>
				<td width="35%">Date Received</td>
				<td width="35%">Date Claimed</td>
			</tr>
			<%
			for(int i = 0; i < vClaimedCC.size(); i += 4){			
			%>
			<tr>
				<td><%=WI.getStrValue(vClaimedCC.elementAt(i+1))%></td>
				<td><%=WI.getStrValue(vClaimedCC.elementAt(i+3))%></td>
				<td><%=WI.getStrValue(vClaimedCC.elementAt(i+2))%></td>
			</tr>
			<%}%>
		</table>
	  </td>
  </tr>
<%}%>
</table>
</div>



<%}//end vStudDtls not null%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="status_" value="<%=WI.fillTextValue("status_")%>" />
<input type="hidden" name="page_action" />
<input type="hidden" name="drop_reason" value="<%=WI.fillTextValue("drop_reason")%>" />
<input type="hidden" name="update_from_list" />
<input type="hidden" name="attendance_index_" />
<input type="hidden" name="update_no_exam" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
