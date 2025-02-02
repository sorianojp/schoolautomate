<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMAssignment" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Admin.-CLASS MANAGEMENT-Assignments/Homeworks","cm_assignment.jsp");
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
		" and e_sub_section.offering_sem="+ strSem +" and is_lec=0 and e_sub_section.is_valid = 1");
}

if(strSubSecIndex != null) {//get here subject section detail. 
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
}

CMAssignment cm = new CMAssignment();

if (strPageAction.compareTo("5") == 0){
	if (cm.duplicateQuestions(dbOP,request,strSubSecIndex)) 
		strErrMsg = " Assignment/Homework successfully copied";
	else
		strErrMsg = cm.getErrMsg();


}



String strReadOnly = "";
if (WI.fillTextValue("assign_name_index").length() > 0){
	vEditInfo = cm.operateOnAssignment(dbOP,request,3, strSubSecIndex,true);
	strReadOnly = " readonly = 'yes'";
	if (vEditInfo == null)
		strErrMsg = cm.getErrMsg();
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
function ReloadSectionSrc(){
	document.form_.src_subject.value="";
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

function PrepareToEdit(){
	document.form_.page_action.value ="";
	document.form_.info_index.value = document.form_.assign_name_index[document.form_.assign_name_index.selectedIndex].value;
	document.form_.print_page.value ="";
	this.SubmitOnce("form_");
}
function CancelRecord(){
	location = "./cm_duplicate.jsp?section_name="+escape(document.form_.section_name[document.form_.section_name.selectedIndex].value)+"&subject="+document.form_.subject[document.form_.subject.selectedIndex].value+
	"&sy_from="+document.form_.sy_from.value+"&offering_sem="+document.form_.offering_sem.value;
}

function PrintPg(){
	document.form_.print_page.value = "1";
	document.form_.sem_label.value = document.form_.offering_sem[document.form_.offering_sem.selectedIndex].text;
	document.form_.subj_label.value = document.form_.subject[document.form_.subject.selectedIndex].text;
	this.SubmitOnce("form_");
}


function  ShowHideDetail() {
	//strShow = 1 , show the table rows. else hide the table rows.
	var strShow = 0;
	if(document.form_.show_drop.checked)
		this.showLayer('tr_1');
	else
		this.hideLayer('tr_1');
}

function DuplicateRecords(){
	document.form_.page_action.value = "5";
	this.SubmitOnce("form_");
}

-->
</script>

<body bgcolor="#93B5BB">

<form name="form_" method="post" action="./cm_duplicate.jsp">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <input type="hidden" name="section" value="<%=WI.getStrValue(strSubSecIndex)%>">
    <input type="hidden" name="show_delete">
    <input type="hidden" name="show_save">
    <tr bgcolor="#6A99A2"> 
      <td height="25" colspan="4"><div align="center">
          <p><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
            DUPLICATE ASSIGNMENT MAINTENANCE PAGE::::</strong></font></p>
          </div></td>
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
<!-- no need of this because i am going to copy assignment from other assignment 
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="21%" height="25"><div align="left"><strong>Assignment Name</strong></div></td>
      <td width="76%" height="25" nFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <select name="assign_name_index" onChange="PrepareToEdit()">
          <option value="">Select Assignment Name or Add New</option>
          <%=dbOP.loadCombo("distinct cm_assignment.assignment_index","ASSIGN_NAME"," from cm_assignment " + 
	 " where cm_assignment.sy_from =" + strSYFrom +   " and cm_assignment.SUB_INDEX = " + 
	 WI.fillTextValue("subject") + " and cm_assignment.semester = " +  WI.fillTextValue("offering_sem") +
	 " and cm_assignment.sub_sec_index =" + strSubSecIndex ,WI.fillTextValue("assign_name_index"),false)%> 
        </select> </td>
    </tr>
-->	
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Assignment Name<font color="#FF0000">*</font></strong></td>
      <td height="25" >
  <% 
	  if(vEditInfo!= null)	strTemp = WI.getStrValue((String)vEditInfo.elementAt(2)); 
	  else  strTemp = WI.fillTextValue("assign_name");
  %>
	  <input name="assign_name" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="48" maxlength="64"
		value="<%=strTemp%>" <%=strReadOnly%>></td>
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
      <td height="25"><strong>Last Date of Submission <font color="#FF0000">*</font></strong></td>
      <td height="25"> <%
if(vEditInfo!= null) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(4));
else 
	strTemp = WI.fillTextValue("date_submit");
%> <input name="date_submit" type="text" class="textbox"
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
	value="<%=strTemp%>"  <%=strReadOnly%>></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Instructor Notes</strong></td>
      <td height="25"> <%if(vEditInfo!= null) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(6));
 else 
	strTemp = WI.fillTextValue("instr_note");%> <input name="instr_note" type="text"   class="textbox"   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="48" maxlength="128"
	value="<%=strTemp%>"  <%=strReadOnly%>></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Reference Notes</strong></td>
      <td height="25"> <%
if(vEditInfo!= null) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(5));
else 
	strTemp = WI.fillTextValue("remarks");
%> <textarea name="remarks" cols="48" rows="2"  <%=strReadOnly%> class="textbox" maxlength="256" onKeyUp="return isMaxLen(this)" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea> 
      </td>
    </tr>
    <%	
	if(vEditInfo!= null) 
		strTemp2 = WI.getStrValue((String)vEditInfo.elementAt(8));
	else 
		strTemp2 = WI.fillTextValue("copied_fr_index");
%>
    <tr> 
      <td height="25" colspan="3"><hr size="1" noshade></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><strong>SELECT REFERENCE / SOURCE ASSIGNMENT</strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Section<font color="#FF0000">*</font></strong></td>
      <td height="25"> <%
strTemp = " from e_sub_section join FACULTY_LOAD on (FACULTY_LOAD.sub_sec_index = e_sub_section.sub_sec_index)  where "+
			"faculty_load.is_valid = 1 and e_sub_section.is_valid = 1 and e_sub_section.OFFERING_SY_FROM ="+
			strSYFrom+" and e_sub_section.OFFERING_SY_TO="+strSYTo+ " and e_sub_section.OFFERING_SEM = "+strSem+" and faculty_load.user_index = "+
			strEmployeeIndex + " and section <> '"+ WI.fillTextValue("section_name") + "'";
%> <select name="src_section_name" id="src_section_name" onChange="ReloadSectionSrc();">
          <option value="">Select a section</option>
          <%=dbOP.loadCombo("distinct section","section",strTemp, request.getParameter("src_section_name"), false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><div align="left"><strong>Subject<font color="#FF0000">*</font></strong></div></td>
      <td height="25"><div align="left"> 
          <%strTemp = " from faculty_load join e_sub_section on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) "+
			"join subject on (e_sub_section.sub_index = subject.sub_index) where faculty_load.user_index = "+
			strEmployeeIndex+" and e_sub_section.section = '"+WI.fillTextValue("src_section_name")+
			"' and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
			strSYFrom + " and e_sub_section.offering_sy_to = "+strSYTo+
			" and e_sub_section.offering_sem="+strSem;%>
          <select name="src_subject" id="select" onChange="ReloadPage()">
            <option value="">Select a subject</option>
            <%=dbOP.loadCombo("distinct subject.sub_index","sub_code",strTemp, request.getParameter("src_subject"), false)%> 
          </select>
        </div></td>
    </tr>
    <% if (WI.fillTextValue("src_subject").length() > 0 && WI.fillTextValue("src_section_name").length() > 0) {%>
    <tr> 
      <td height="25" align="center">&nbsp;</td>
      <td height="25"><strong>Assigment Name<font color="#FF0000">*</font></strong></td>
      <td height="25"> 
	  <% 
	  String strSrcSubSecIndex =  dbOP.mapOneToOther("E_SUB_SECTION ",
		"section","'"+WI.fillTextValue("src_section_name")+"'"," e_sub_section.sub_sec_index", 
		" and e_sub_section.sub_index = "+WI.fillTextValue("src_subject")+ 
		" and e_sub_section.offering_sy_from = "+ strSYFrom +
		" and e_sub_section.offering_sy_to = "+ strSYTo+
		" and e_sub_section.offering_sem="+ strSem +" and is_lec=0 and is_valid = 1");
				
	  strTemp = " from cm_assignment " +//join cm_assigment as self_cm on (cm_assignment.assignment_index = self_cm.copied_fr_index) "+
	   " join CM_ASSIGN_DETAIL on (cm_assignment.copied_fr_index = CM_ASSIGN_DETAIL.copied_fr_index) " +
	   " where cm_assignment.sy_from =" + strSYFrom + 
	   " and cm_assignment.SUB_INDEX = " + WI.fillTextValue("src_subject") + " and cm_assignment.semester = " + 
		WI.fillTextValue("offering_sem") + " and cm_assignment.sub_sec_index =" + strSrcSubSecIndex +
			" and CM_ASSIGN_DETAIL.is_del =0 and (cm_assignment.copied_fr_index = cm_assignment.assignment_index)";%> 
			<select name="src_copied_fr_index" id="src_copied_fr_index">
          <%=dbOP.loadCombo("distinct cm_assignment.COPIED_FR_INDEX","ASSIGN_NAME",strTemp,WI.fillTextValue("src_copied_fr_index"),false)%> </select> 
      <input type="hidden" name="src_sub_sec_index" value="<%=WI.getStrValue(strSrcSubSecIndex)%>">
	  </td>
    </tr>
    <%}%>
    <tr> 
      <td height="15" colspan="3" align="center">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3" align="center"> 
	  <%if (iAccessLevel > 1){ %>
	  	<a href="javascript:DuplicateRecords()"><img border="0" src="../../images/copy_all.gif" width="55" height="27"></a> 
        click to add list of question <%}%> &nbsp;</td>
    </tr>
  </table>
<%} // if vSubSecDetail not found %>
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
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">

<input type="hidden" name="sub_sec_index" value="<%=strSubSecIndex%>">
</form>

</body>
</html>
<%
	dbOP.cleanUP();
%>