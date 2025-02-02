<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMAssignment" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-CLASS MANAGEMENT-Assignments/Homeworks","cm_assignment.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Faculty/Acad. Admin","CLASS MANAGEMENT",request.getRemoteAddr(), 
														"cm_assignment.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	String strEmployeeID = (String)request.getSession(false).getAttribute("userId");
	String strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);
	String strSubSecIndex   = null;
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
	Vector vRetResult = null;
	Vector vSecDetail  = null;
	Vector vEditInfo = null;
	String strPageAction = WI.fillTextValue("page_action");
	String strSem = WI.fillTextValue("offering_sem");
	String strSYFrom = WI.fillTextValue("sy_from");
	String strSYTo = WI.fillTextValue("sy_to");

	
if(strSem.length() ==0)
	strSem = (String)request.getSession(false).getAttribute("cur_sem");
if(strSYFrom.length() ==0)
		strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strSYTo.length() ==0)
	strSYTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to");


if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
	strSubSecIndex = dbOP.mapOneToOther("E_SUB_SECTION join faculty_load on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
		"section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index", 
		" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+
		" and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
		strSYFrom +" and e_sub_section.offering_sy_to = "+ strSYTo+
		" and e_sub_section.offering_sem="+ strSem +" and is_lec=0");
}

if(strSubSecIndex != null) {//get here subject section detail. 
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
}

CMAssignment cm = new CMAssignment();
boolean bolOperation = false;

if (strPageAction.compareTo("0")==0) {
	bolOperation = true;
	vRetResult = cm.operateOnAssignment(dbOP,request,0, strSubSecIndex);
	if (vRetResult != null){
		strErrMsg = " Assignment/Homework successfully removed";

	}else
		strErrMsg = cm.getErrMsg();
}else if (strPageAction.compareTo("1") == 0){
	bolOperation = true;
	vRetResult = cm.operateOnAssignment(dbOP,request,1, strSubSecIndex);
	if (vRetResult != null){
		strErrMsg = " Assignment/Homework successfully added";
	}else
		strErrMsg = cm.getErrMsg();
}else if (strPageAction.compareTo("2") == 0){
	bolOperation = true;
	vRetResult = cm.operateOnAssignment(dbOP,request,2, strSubSecIndex);
	if (vRetResult != null){
		strErrMsg = " Assignment/Homework successfully edited";
		strPrepareToEdit = "";
	}else
		strErrMsg = cm.getErrMsg();
}

if (strPrepareToEdit.compareTo("1") == 0){
	vEditInfo = cm.operateOnAssignment(dbOP,request,3, strSubSecIndex,true);
	if (vEditInfo == null)
		strErrMsg = cm.getErrMsg();
}

if (strSubSecIndex  != null){
	vRetResult = cm.operateOnAssignment(dbOP,request,4, strSubSecIndex);
	if (vRetResult == null && !bolOperation){
		strErrMsg = cm.getErrMsg();
	}
}

%>
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">	
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>

</head>
<script language="JavaScript" src="../../jscript/td.js"></script>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
<!--
function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function ReloadSection(){
	document.form_.subject.value="";
	ReloadPage();
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	document.form_.prepareToEdit.value ="";
	this.SubmitOnce("form_");
}

function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.print_page.value = "";
	document.form_.prepareToEdit.value ="";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.prepareToEdit.value ="";
	document.form_.page_action.value = "0";
	document.form_.print_page.value = "";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex){
	document.form_.page_action.value ="";
	document.form_.info_index.value = strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	document.form_.print_page.value ="";
	this.SubmitOnce("form_");
}
function CancelRecord(){
	location = "./cm_assignment.jsp?section_name="+escape(document.form_.section_name[document.form_.section_name.selectedIndex].value)+"&subject="+document.form_.subject[document.form_.subject.selectedIndex].value+
	"&sy_from="+document.form_.sy_from.value+"&offering_sem="+document.form_.offering_sem.value;
}

function PrintPg(){
	document.form_.print_page.value = "1";
	document.form_.sem_label.value = document.form_.offering_sem[document.form_.offering_sem.selectedIndex].text;
	document.form_.subj_label.value = document.form_.subject[document.form_.subject.selectedIndex].text;
	this.SubmitOnce("form_");
}

function UpdateRecord(strInfoIndex, strSubSecIndex){
	location = "./cm_assignment_detail.jsp?section_name="+
	escape(document.form_.section_name[document.form_.section_name.selectedIndex].value)+
	"&subject="+document.form_.subject[document.form_.subject.selectedIndex].value+
	"&sy_from="+document.form_.sy_from.value+"&offering_sem="+
	document.form_.offering_sem.value + "&sy_to="+document.form_.sy_to.value+"&info_index=" + 
	strInfoIndex+"&sub_sec_index="+strSubSecIndex;
}

function  ShowHideDetail() {
	//strShow = 1 , show the table rows. else hide the table rows.
	var strShow = 0;
	if(document.form_.show_drop.checked)
		this.showLayer('tr_1');
	else
		this.hideLayer('tr_1');
}

-->
</script>

<body bgcolor="#93B5BB">
<form name="form_" method="post" action="./cm_assignment.jsp">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <input type="hidden" name="section" value="<%=WI.getStrValue(strSubSecIndex)%>">
    <input type="hidden" name="show_delete">
    <input type="hidden" name="show_save">
    <tr bgcolor="#6A99A2"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          CLASS ASSIGNMENT MAINTENANCE PAGE::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;<strong><font size="2" color="#FF0000"> 
        <%=WI.getStrValue(strErrMsg,"MESSAGE: ","","")%></font></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp; <strong><font color="blue">NOTE: 
        Subject/Sections appear are the sections handled by the logged in faculty 
        Employee ID: <%=strEmployeeID%></font></strong></td>
    </tr>
    <tr> 
      <td width="3%" height="25" rowspan="4" >&nbsp;</td>
      <td width="21%" valign="bottom" >Term</td>
      <td width="21%" valign="bottom" >School Year</td>
      <td width="55%" >&nbsp;</td>
    </tr>
    <tr> 
      <td valign="bottom" > <select name="offering_sem" id="offering_sem" onChange="ReloadPage();">
          <option value="1">1st Sem</option>
          <% 
if(strSem.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strSem.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strSem.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td valign="bottom" > <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strSYTo%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"> </td>
      <td ><a href="javascript:ReloadPage();"><img src="../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
  </table>
<%if(strSYFrom.length() > 0 && strSYTo.length() >0 && strSem.length() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3"><hr size="1" noshade></td>
    </tr>
    <tr> 
      <td width="1%"></td>
      <td width="39%" height="25" valign="bottom" >Section Handled</td>
      <td valign="bottom" >Instructor (Name of logged in user)</td>
    </tr>
    <tr> 
      <td></td>
      <td height="25" > <%
strTemp = " from e_sub_section join FACULTY_LOAD on (FACULTY_LOAD.sub_sec_index = e_sub_section.sub_sec_index)  where "+
			"faculty_load.is_valid = 1 and e_sub_section.is_valid = 1 and e_sub_section.OFFERING_SY_FROM ="+
			strSYFrom+" and e_sub_section.OFFERING_SY_TO="+strSYTo+
			" and e_sub_section.OFFERING_SEM = "+strSem+" and faculty_load.user_index = "+
			strEmployeeIndex;
%> <select name="section_name" onChange="ReloadSection();">
          <option value="">Select a section</option>
          <%=dbOP.loadCombo("distinct section","section",strTemp, request.getParameter("section_name"), false)%> 
        </select> </td>
      <td height="25" > <strong> 
        <%if(vSecDetail != null){%>
        <%=WI.getStrValue(vSecDetail.elementAt(0))%> 
        <%}%>
        </strong> </td>
    </tr>
    <tr> 
      <td width="1%"></td>
      <td height="25">Subject Handled</td>
      <td>Subject Title</td>
    </tr>
    <tr> 
      <td width="1%"></td>
      <td height="25" > <%strTemp = " from faculty_load join e_sub_section on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) "+
			"join subject on (e_sub_section.sub_index = subject.sub_index) where faculty_load.user_index = "+
			strEmployeeIndex+" and e_sub_section.section = '"+WI.fillTextValue("section_name")+
			"' and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
			strSYFrom + " and e_sub_section.offering_sy_to = "+strSYTo+
			" and e_sub_section.offering_sem="+strSem;
%> <select name="subject" id="subject" onChange="ReloadPage()">
          <option value="">Select a subject</option>
          <%=dbOP.loadCombo("distinct subject.sub_index","sub_code",strTemp, request.getParameter("subject"), false)%> 
        </select></td>
      <td> <% if(WI.fillTextValue("subject").length() > 0) {
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name"," and is_del=0");
%> <strong> <%=WI.getStrValue(strTemp)%></strong></td>
      <%}%>
    </tr>
  </table>
<%} if(vSecDetail != null){%>
  <table width="100%" border="0" cellspacing="1" cellpadding="2" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td width="15%">&nbsp;</td>
      <td width="24%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>ROOM 
          NUMBER</strong></font></div></td>
      <td width="20%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>LOCATION</strong></font></div></td>
      <td width="26%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="15%">&nbsp;</td>
    </tr>
    <%for(int i = 1; i<vSecDetail.size(); i+=3){%>
    <tr> 
      <td>&nbsp;</td>
      <td align="center"><%=(String)vSecDetail.elementAt(i)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+1)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+2)%></td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td>&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" nFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><div align="right"><font size="1">Items 
          with (<font color="#FF0000">*</font>) are required.</font></div></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="21%" height="25"><div align="left"><strong>Assignment Name<font color="#FF0000">*</font></strong></div></td>
      <td width="76%" height="25" nFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <%if(vEditInfo!= null) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(2));
 else 
	strTemp = WI.fillTextValue("assign_name");%> <input name="assign_name" type="text"   class="textbox"   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="48" maxlength="64"
	value="<%=strTemp%>"> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Date of Assignment<font color="#FF0000">*</font></strong></td>
      <td height="25" > <%if(vEditInfo!= null) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(3));
 else 
	strTemp = WI.fillTextValue("date_assign");%> <input name="date_assign" type="text" class="textbox" id="date_assign"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=strTemp%>" size="11" readonly="yes"> <a href="javascript:show_calendar('form_.date_assign');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Due Date of Submission <font color="#FF0000">*</font></strong></td>
      <td height="25"> <%
if(vEditInfo!= null) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(4));
else 
	strTemp = WI.fillTextValue("date_submit");
%>
        <input name="date_submit" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=strTemp%>" size="11" readonly="yes"> <a href="javascript:show_calendar('form_.date_submit');" title="Click to select date" 
		onmouseover="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Student Notes</strong></td>
      <td height="25"> <%if(vEditInfo!= null) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(7));
 else 
	strTemp = WI.fillTextValue("stud_note");%> <input name="stud_note" type="text"   class="textbox"   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="48" maxlength="128"
	value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Instructor Notes</strong></td>
      <td height="25"> <%if(vEditInfo!= null) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(6));
 else 
	strTemp = WI.fillTextValue("instr_note");%> <input name="instr_note" type="text"   class="textbox"   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="48" maxlength="128"
	value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Reference Notes</strong></td>
      <td height="25"> 
<%
if(vEditInfo!= null) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(5));
else 
	strTemp = WI.fillTextValue("remarks");
%> <textarea name="remarks" cols="48" rows="2"   class="textbox" maxlength="256" onKeyUp="return isMaxLen(this)" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td style="font-weight:bold;">Maximum Score</td>
      <td>
<%
if(vEditInfo!= null) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(10));
else 
	strTemp = WI.fillTextValue("max_score");
%>	  <input name="max_score" type="text" size="3" maxlength="3" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur='AllowOnlyInteger("form_","max_score"); style.backgroundColor="white" ; '
	   onKeyUp='AllowOnlyInteger("form_","max_score")' value="<%=WI.getStrValue(strTemp,"0")%>"> 
	  <font style="font-size:10px; color:#0000FF; font-weight:bold">
	  	(NOTE : If Max score = 0, assignment will not appear in student's home page)</font>
	  </td>
    </tr>
    <%	String strTemp2 = null;
	if(vEditInfo!= null) 
		strTemp2 = WI.getStrValue((String)vEditInfo.elementAt(8));
	else 
		strTemp2 = WI.fillTextValue("copied_fr_index");
	
	if (vEditInfo == null || !(vEditInfo.elementAt(0)).equals(vEditInfo.elementAt(8))){
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><input type="checkbox" name="show_drop" id="show_drop" value="1" onClick="ShowHideDetail()">
        tick to share assignment from another section</td>
    </tr>
    <tr bgcolor="#FFFFFF" id="tr_1"> 
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Copy Assignment From</strong></td>
      <td height="25"> 
<% strTemp = " from cm_assignment " +//join cm_assigment as self_cm on (cm_assignment.assignment_index = self_cm.copied_fr_index) "+
	   " join CM_ASSIGN_DETAIL on (cm_assignment.copied_fr_index = CM_ASSIGN_DETAIL.copied_fr_index) " +
	   " where cm_assignment.sy_from =" + strSYFrom + 
	   " and cm_assignment.SUB_INDEX = " + WI.fillTextValue("subject") + " and cm_assignment.semester = " + 
		WI.fillTextValue("offering_sem") + " and cm_assignment.sub_sec_index <>" + strSubSecIndex +
			" and CM_ASSIGN_DETAIL.is_del =0 and (cm_assignment.copied_fr_index = cm_assignment.assignment_index)"+
			" and cm_assignment.is_del = 0 and cm_assignment.is_valid = 1 ";
///problem here --- it shows the assignment even though it is already copied for that subject.
			%>
        <select name="copied_fr_index" id="copied_fr_index">
          <%=dbOP.loadCombo("distinct cm_assignment.COPIED_FR_INDEX","ASSIGN_NAME",strTemp,strTemp2,false)%> </select> </td>
    </tr>
<script language="JavaScript">
this.ShowHideDetail();
</script>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><div align="left"></div></td>
      <td height="25"><div align="left"></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3" align="center">
<% 	if (iAccessLevel > 1){
	  if(vEditInfo == null) { %> 
	  <a href="javascript:AddRecord()"><img border="0" src="../../images/add.gif" width="42" height="32"></a> 
        <font size="1">click to add record</font> <%     
  }else{ %> <a href="javascript:EditRecord()"><img src="../../images/edit.gif" width="40" height="26" border="0"></a> 
        <font size="1">click to save changes </font><a href='javascript:CancelRecord();'><img src="../../images/cancel.gif" width="51" height="26" border="0"></a> 
        <font size="1">click to cancel edit</font> <%}}%> </td>
    </tr>
    <tr> 
      <td height="25" colspan="3" align="center"><div align="right"></div></td>
    </tr>
  </table>
<% if (vRetResult != null){%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#EBF5F5"> 
      <td height="25" colspan="8" class="thinborder"><div align="center"><strong>LIST OF ASSIGNMENTS</strong></div></td>
    </tr>
    <tr> 
      <td width="20%" height="25" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Assignment Name </td>
      <td width="20%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Date of Submission </td>
      <td width="30%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Reference</td>
      <td width="6%" class="thinborder"  align="center" style="font-size:9px; font-weight:bold">Max. Score  </td>
      <td width="6%" class="thinborder"  align="center" style="font-size:9px; font-weight:bold">No Of  Questions </td>
      <td width="6%" class="thinborder" style="font-size:9px; font-weight:bold">&nbsp;</td>
      <td width="6%" class="thinborder" style="font-size:9px; font-weight:bold">&nbsp;</td>
      <td width="7%" class="thinborder" style="font-size:9px; font-weight:bold">&nbsp;</td>
    </tr>
    <% for (int i = 0; i < vRetResult.size(); i+=12) {%>
    <tr> 
      <td height="34" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%> - <%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+10),"&nbsp;")%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i+11)%></td>
      <td class="thinborder"><a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../images/edit.gif"  border="0" ></a></td>
      <td class="thinborder"><a href="javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../images/delete.gif"  border="0"></a></td>
      <td class="thinborder"><a href="javascript:UpdateRecord(<%=(String)vRetResult.elementAt(i + 8)%>,<%=(String)vRetResult.elementAt(i + 9)%>)"><img src="../../images/update.gif"  border="0"></a></td>
    </tr>
    <%} // end of for loop%>
  </table>
<%}// vRetREsult != null
} // if vSubSecDetail not found %>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#6A99A2"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="print_page">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="sub_sec_index" value="<%=strSubSecIndex%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>