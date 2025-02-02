<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,enrollment.Advising,java.util.Vector,java.util.Calendar"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strSchCode =  
			WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));	
	
	if(WI.fillTextValue("print_page").equals("1")){
		if (strSchCode.startsWith("CGH")) { %>
			<jsp:forward page="applicant_scheduling_print_cgh.jsp"/>
		<%}else{%>
			<jsp:forward page="applicant_scheduling_print.jsp"/>
		<%}	
	return;}%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Applicant Scheduling</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	document.form_.print_page.value = "";
	document.form_.donot_call_close_wnd.value = "1";	
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.print_page.value = "";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() {
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.print_page.value = "";
	document.form_.info_index.value = "";
	document.form_.temp_id.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.reload_page.value = "1";	
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.reload_page.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function MainExamTypeReloaded() {
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.main_examtype_reloaded.value = "1";
	this.SubmitOnce("form_");
}
function OpenSearch(){
	document.form_.donot_call_close_wnd.value = "1";
	var pgLoc = "../../../search/srch_stud_temp.jsp?opner_info=form_.temp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintPage(){
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');	
}

function ReloadParentWnd() {

	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		if (window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.searchApplicant){
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.searchApplicant.value = 1;
		}

		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
		window.opener.focus();
	}
}

function CloseWindow(){
	document.form_.close_wnd_called.value = "1";
	if (window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.searchApplicant)
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.searchApplicant.value = 1;
	
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
	self.close();
}

function PrintEnrollmentForm() {
	var studID = prompt("Please enter Student's ID.", "Temp/ perm ID.");
	if(studID.length == 0)  {
		alert("Failed to process request. Stud. ID is empty.");
		return;
	}	
	var pgLoc = "../../admission/entrance_admission_slip_new_print.jsp?temp_id="+studID;
	var win=window.open(pgLoc,"AdmissionSlip",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%
	Advising adv = new Advising();
	Calendar calendar = Calendar.getInstance();
	Vector vStudInfo = null;
	Vector vRetResult = null;
	Vector vEditInfo  = null;
	Vector vExamName = null;
	Vector vSchedData = null;
	String strErrMsg = null;
	String strErrMsg2 = null;
	String strTemp = null;
	String strPrepareToEdit = null;
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-ENTRANCE EXAM/INTERVIEW","applicant_scheduling.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();

int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission Maintenance","ENTRANCE EXAM/INTERVIEW",request.getRemoteAddr(),
														"applicant_scheduling.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}//end of authenticaion code.
	ApplicationMgmt appMgmt = new ApplicationMgmt();
	String [] astrConvTime={" AM"," PM"};
	
	request.setAttribute("info_index",WI.fillTextValue("sch_code"));
	if(WI.fillTextValue("main_examtype_reloaded").length() == 0) 
		vSchedData = appMgmt.operateOnExamSched(dbOP,request,5);
			
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(appMgmt.operateOnStudExamSched(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strPrepareToEdit = "0";
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = appMgmt.getErrMsg();
	}
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = appMgmt.operateOnStudExamSched(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = appMgmt.getErrMsg();
	}	
	//view all 
	if(WI.fillTextValue("reload_page").compareTo("1") == 0)
		vRetResult = appMgmt.operateOnStudExamSched(dbOP, request, 4);
%>
<body bgcolor="#D2AE72"  onUnload="ReloadParentWnd();">
<form name="form_" action="./applicant_scheduling.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" bgcolor="#A49A6A"><font color="#FFFFFF" ><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">:::: 
        APPLICANT SCHEDULING PAGE::::</font></strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
      <td width="10%">
	 <% if (WI.fillTextValue("opner_form_name").length() > 0){%>
	  <a href="javascript:CloseWindow();">
	  		<img src="../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a>
	 <%}%>  	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="22%">School Year / Term</td>
      <td width="34%"> <% strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %> <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%  strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %> <input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
        / 
        <select name="semester">
          <% strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 )
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected="selected">1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  if (!strSchCode.startsWith("CPU")) {
	  	   if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  }%>
      </select></td>
      <td colspan="2"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
	  <%if(strSchCode.startsWith("CIT")){%>
	  		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="javascript:PrintEnrollmentForm();">Print Applicant Exam Schedule</a>
	  <%}%>
	  </td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="23">&nbsp;</td>
      <td width="22%">Scheduling Type/Sub-type</td>
      <td><select name="exam_index" onChange="MainExamTypeReloaded();">
        <%	   	
		strTemp = WI.fillTextValue("exam_index");
				
	  	vExamName = appMgmt.retreiveName(dbOP, request);
	  	if(vExamName != null && vExamName.size() > 0) {
		  for(int i = 0 ; i< vExamName.size(); i +=6){ 
			if( strTemp.compareTo((String)vExamName.elementAt(i)) == 0) {%>
          <option value="<%=(String)vExamName.elementAt(i)%>" selected><%=(String)vExamName.elementAt(i+3)%></option>
          <%}else{%>
          <option value="<%=(String)vExamName.elementAt(i)%>"><%=(String)vExamName.elementAt(i+3)%></option>
          <%}
			}
		   }%>
        </select>       
      <td width="32%">      
    <td>    </tr>
    <tr> 
      <td height="23">&nbsp;</td>
      <td width="22%">Schedule Code</td>
      <td><select name="sch_code" onChange="ReloadPage();">
<%if(WI.fillTextValue("exam_index").length() > 0) {
if(WI.fillTextValue("show_expired").length() > 0)
	strTemp = " <'"+WI.getTodaysDate()+"' ";
else	
	strTemp = " >='"+WI.getTodaysDate()+"' ";
		  
	strTemp = " FROM NA_EXAM_SCHED WHERE IS_DEL=0 AND IS_VALID=1 AND EXAM_NAME_INDEX ="+WI.fillTextValue("exam_index")+"AND SY_FROM ="
	+WI.fillTextValue("sy_from")+" AND SY_TO ="+WI.fillTextValue("sy_to")+" AND SEMESTER = "+WI.fillTextValue("semester")+
	" and date_of_exam "+strTemp+" order by date_of_exam, start_time_24, schedule_code asc";
	
	//" AND ((date_of_exam = '"+WI.getTodaysDate()+"' and start_time_24 > "+Integer.toString(calendar.get(Calendar.HOUR_OF_DAY))+") "+
    //" or (date_of_exam > '"+WI.getTodaysDate()+"')) order by SCHEDULE_CODE asc" ;
	%>
          <%=dbOP.loadCombo("EXAM_SCHED_INDEX","SCHEDULE_CODE",strTemp, request.getParameter("sch_code"), false)%> 
          <%}%>
        </select> &nbsp;&nbsp;<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a></td>
      <td style="font-size:9px; color:#0000FF; font-weight:bold">
	  <%if(!strSchCode.startsWith("CIT")) {%> 
	  		<input type="checkbox" name="show_expired" value="checked" <%=WI.fillTextValue("show_expired")%>> Show Expired
	  <%}%>	
	  
	  </td>
      <td>&nbsp;</td>
    </tr>
	<tr><td>&nbsp;</td>
		<td height="30" colspan="5">
		View &nbsp;&nbsp;
		<%
		strTemp = WI.fillTextValue("view_new");
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<input type="checkbox" name="view_new" value="1" <%=strErrMsg%> >New Student
		<%		
		strTemp = WI.fillTextValue("view_old");
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<input type="checkbox" name="view_old" value="1" <%=strErrMsg%> >Old Student
		</td>
	</tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
    <tr>
	<% if(vSchedData != null && vSchedData.size() > 0){%>
      <td width="2%" height="25">&nbsp;</td>
      <td width="22%">Date : <strong><%=((String)vSchedData.elementAt(7))%></strong></td>
      <td>Start Time :<strong><%=CommonUtil.formatMinute((String)vSchedData.elementAt(8))+':'+ CommonUtil.formatMinute((String)vSchedData.elementAt(9))+astrConvTime[Integer.parseInt((String)vSchedData.elementAt(10))]%></strong></td>
      <td colspan="2">Duration(min) :<strong><%=((String)vSchedData.elementAt(6))%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Contact Person</td>
      <td height="25"><strong><%=((String)vSchedData.elementAt(13))%></strong></td>
      <td height="25" colspan="2">Venue : <strong><%=((String)vSchedData.elementAt(12))%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Contact Info</td>
      <td height="25" colspan="3" valign="bottom"><strong><%=((String)vSchedData.elementAt(14))%></strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
    <%}//if(vSchedData != null && vSchedData.size() > 0)%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<%
strTemp =null;
if((vSchedData != null && vSchedData.size() > 0) ||
	 WI.fillTextValue("temp_id").length()>0){%>    
	 <tr> 
      <td  width="2%" height="25">&nbsp;</td>
      <td width="23%" height="25">Temporary/Applicant ID</td>
      <td width="14%" height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);				
else	
	strTemp = WI.fillTextValue("temp_id");
%>      
	  
  	  <input name="temp_id" type="text" class="textbox" value="<%=strTemp%>" size="16" maxlength="16"
        onfocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"' ></td>
  	  <td width="61%" height="25" valign="bottom"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a><font size="1">click 
        to search Temporary ID</font></td>
    </tr>
     <tr> 
	  <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
	<%}//show if temp id is entered%>
	<%if (strTemp != null && strTemp.length() > 0)
		vStudInfo = adv.getStudInfo(dbOP,strTemp,WI.fillTextValue("sy_from"),
	  									WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
										
		if(vStudInfo == null && WI.fillTextValue("semester").equals("1")){			
			vStudInfo = adv.getStudInfo(dbOP,strTemp, Integer.toString(Integer.parseInt(WI.fillTextValue("sy_from")) - 1),
	  									Integer.toString(Integer.parseInt(WI.fillTextValue("sy_to")) - 1),
										"0");
		}

	if (vStudInfo != null && vSchedData != null && vSchedData.size() > 0) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Applicant Name : <strong>
        
        <%=(String)vStudInfo.elementAt(1)%></strong></td>
    </tr>
    <!--<tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Date Applied : <strong><%=((String)vStudInfo.elementAt(0))%></strong></td>
    </tr>-->
	 <%	  
	  strTemp = WI.getStrValue((String)vStudInfo.elementAt(7),"");	  
	  strTemp += WI.getStrValue((String)vStudInfo.elementAt(8),"/","","");

	  %>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Course/Major Applied : <strong><%=WI.getStrValue(strTemp,"Not Available")%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Year Level: <strong><%=WI.getStrValue((String)vStudInfo.elementAt(6),"Not Available")%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Status: <strong><%=WI.getStrValue((String)vStudInfo.elementAt(11),"Not Available")%></strong> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Contact Information :
        <%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(11);
			else	
				strTemp = WI.fillTextValue("contact_info");			
		%>      
      <input name="contact_info" type="text" size="32" value="<%=WI.getStrValue(strTemp,"-")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="43">&nbsp;</td>
      <td height="43">&nbsp;</td>
      <td height="43" colspan="2" valign="bottom"><font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> Click to save entries
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a>Click to edit event
        <%}%>
        <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> Click to clear entries </font></td>
    </tr>
	
    <%}
	else{ strErrMsg2 = adv.getErrMsg();	}%>
	<tr>
	  <td height="10" colspan="4"><strong><%=WI.getStrValue(strErrMsg2)%></strong></td>
    </tr>
  </table>
  <% 

  if(vRetResult != null && vRetResult.size() > 0){ %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
      <tr>
        <td width="41%" style="padding-left:100px;">
			<font color="#0099FF"><strong>&bull; NEW STUDENT</strong></font><br>
			<font color="#999999"><strong>&bull; OLD STUDENT</strong></font>
		</td>        
      <td width="59%"><div align="right"><font size="1"><select name="row_perpg">
	  <%
	  int iDefault = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_perpg"), "20"));
	  for(int i = 15; i < 45; ++i) {
	  	if(iDefault == i)
			strTemp = " selected";
		else	
			strTemp = "";
	  %>
	  	<option value="<%=i%>" <%=strTemp%>><%=i%></option>
	  <%}%>  	
	  </select> rows per page
	  &nbsp; &nbsp; &nbsp; &nbsp; <a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>Click to print list</font> &nbsp;&nbsp;</div></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="23" colspan="8" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>LIST 
          OF APPLICANTS </strong></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="8" class="thinborder"><strong><font size="1">TOTAL 
        APPLICANT(S) : <%=vRetResult.size()/13%> </font></strong></td>
    </tr>
    <tr> 
      <td width="6%" align="center" class="thinborder"><strong><font size="1">COUNT 
          NO.</font></strong></td>
      <td width="14%" height="25" class="thinborder"><div align="center"><strong><font size="1">TEMPORARY/ 
          APPLICANT ID</font></strong></div></td>
      <td width="23%" align="center" class="thinborder"><strong><font size="1">APPLICANT 
        NAME</font></strong></td>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">DATE 
        APPLIED</font></strong></td>
      <td width="17%" align="center" class="thinborder"><strong><font size="1">COURSE/MAJOR 
        APPLIED</font></strong></td>
      <td width="17%" align="center" class="thinborder"><b><font size="1">CONTACT 
        INFORMATION</font></b></td>
      <b> </b> 
      <td colspan="2" align="center" class="thinborder"><b><font size="1">OPTIONS</font></b></td>
    </tr>
    <%
int iCount = 1;
String strBGColor = " bgcolor='#FFFFFF'";
for(int i = 0 ; i< vRetResult.size(); i+=13)

{

if((String)vRetResult.elementAt(i+12) == null && ((String)vRetResult.elementAt(i+12)).equals("1"))//temp stud
	strBGColor = " bgcolor='#0099FF'";
else
	strBGColor = " bgcolor='#999999'";
%>
    <tr <%=strBGColor%>> 
      <td align="center" class="thinborder"> <%=iCount++%> </td>
      <td class="thinborder" > &nbsp; <%=((String)vRetResult.elementAt(i+2))%></td>
      <td class="thinborder" > &nbsp; <%=WI.formatName((String)vRetResult.elementAt(i+5),(String)vRetResult.elementAt(i+6),(String)vRetResult.elementAt(i+7),4)%></td>
      <td align="center" class="thinborder" ><%=((String)vRetResult.elementAt(i+8))%></td>
      <td class="thinborder" > &nbsp; <%	  
	  strTemp = WI.getStrValue((String)vRetResult.elementAt(i+9),"");
	  strTemp += WI.getStrValue((String)vRetResult.elementAt(i+10),"/","","");
	  %> <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+11),"&nbsp;")%></td>
      <td width="5%" align="center" class="thinborder"> <font size="1"> 
        <%
	  if((iAccessLevel ==2 || iAccessLevel == 3) && ((String)vRetResult.elementAt(i+3))==null ){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        Not authorized to edit 
        <%}%>
        </font></td>
      <td width="8%" align="center" class="thinborder"> <font size="1"> 
        <%
	  if(iAccessLevel ==2 && ((String)vRetResult.elementAt(i+3))==null){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        Not authorized to delete 
        <%}%>
        </font></td>
    </tr>
    <%}%>
  </table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
      <tr>
        <td height="30" align="center">&nbsp; <a href="javascript:PrintPage();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">Click 
          to print list</font> &nbsp;&nbsp;</td>
      </tr>
  </table>
 <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
    <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
    <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
    <input type="hidden" name="page_action">
	<input type="hidden" name="print_page" value="">
	<input type="hidden" name="main_examtype_reloaded"><!-- cleans the page. -->
	<input type="hidden" name="reload_page"  value="">
	
  <input type="hidden" name="opner_form_name" value="<%=WI.fillTextValue("opner_form_name")%>">	
	
<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
<!-- this is very important - onUnload do not call close window -->	
</form>
</body>
</html>
<% dbOP.cleanUP();
%>