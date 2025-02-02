<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMLessonPlan" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
//add security here.

if (WI.fillTextValue("print_page").compareTo("1") == 0) {%>
<jsp:forward page="cm_lessonplan_print.jsp" />

<% return;} 
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
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String strEmployeeID = (String)request.getSession(false).getAttribute("userId");
String strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);

String strSYFrom = WI.fillTextValue("sy_from");
String strSYTo = WI.fillTextValue("sy_to");
if(strSYFrom.length() ==0)
		strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strSYTo.length() ==0)
	strSYTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to");

CMLessonPlan cm = new CMLessonPlan();
Vector vRetResult = null;
Vector vEditInfo = null;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");


if (strPageAction.compareTo("0") == 0){
	vRetResult = cm.operateOnContents(dbOP,request,0);
	if (vRetResult != null)
		strErrMsg = " Sub Description removed successfully";
	else
		strErrMsg = cm.getErrMsg();
}else if (strPageAction.compareTo("1") == 0){
	vRetResult = cm.operateOnContents(dbOP,request,1);
	if (vRetResult != null)
		strErrMsg = " Sub Description added successfully";
	else
		strErrMsg = cm.getErrMsg();
}else if (strPageAction.compareTo("2") == 0){
	vRetResult = cm.operateOnContents(dbOP,request,2);
	if (vRetResult != null){
		strErrMsg = " Sub Description edited successfully";
		strPrepareToEdit ="";
	}else
		strErrMsg = cm.getErrMsg();
}


vEditInfo = cm.operateOnContents(dbOP,request,5);



vRetResult = cm.operateOnContents(dbOP,request,4);
	if (vRetResult == null && strErrMsg == null){
		strErrMsg = cm.getErrMsg();
	}

int iCtr = 0;
%>
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="JavaScript" src="../../../jscript/date-picker.js" type="text/javascript"></script>
<script language="JavaScript" src="../../../jscript/common.js" type="text/javascript"></script>
<script language="JavaScript">
<!--
function insertAtCursor(myFieldname, myValue) {

var myField = eval('document.form_.'+myFieldname);
if (document.selection) {
	var temp;

	myField.focus();
	sel = document.selection.createRange();
	temp = sel.text.length;
	sel.text = myValue;

	if (myValue.length == 0) {
		sel.moveStart('character', myValue.length);
		sel.moveEnd('character', myValue.length);
	} else {
		sel.moveStart('character', -myValue.length + temp);
	}
	myField.focus();
}
//MOZILLA/NETSCAPE support
else if (myField.selectionStart || myField.selectionStart == '0') {
	var startPos = myField.selectionStart;
	var endPos = myField.selectionEnd;
	
		myField.value = myField.value.substring(0, startPos) + myValue + myField.value.substring(endPos, myField.value.length);
		myField.selectionStart = startPos + myValue.length;
		myField.selectionEnd = startPos + myValue.length;
	} else {
		myField.value += myValue;
	}
	myField.focus();
} 

function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location = "./cm_lessonplan.jsp";
}

function ReloadSection(){
	document.form_.subject.value="";
	ReloadPage();
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	document.form_.subj_label.value = document.form_.subject[document.form_.subject.selectedIndex].text;
	this.SubmitOnce('form_');
}
-->
</script>
</head>


<body bgcolor="#93B5BB">
<form action="cm_lessonplan.jsp" method="post" name="form_" id="form_">  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#6A99A2"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          LESSON PLAN MAINTENANCE PAGE::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="10%">&nbsp;</td>
      <td width="20%"><strong>SCHOOL YEAR</strong></td>
      <td width="70%" height="25"><input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strSYTo%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" readonly="yes"> 
      </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td><strong>SECTION</strong></td>
      <td height="25"><%
strTemp = " from e_sub_section join FACULTY_LOAD on (FACULTY_LOAD.sub_sec_index = e_sub_section.sub_sec_index)  where "+
			"faculty_load.is_valid = 1 and e_sub_section.is_valid = 1 and e_sub_section.OFFERING_SY_FROM ="+
			strSYFrom+" and e_sub_section.OFFERING_SY_TO="+strSYTo+" and faculty_load.user_index = "+
			strEmployeeIndex;
%> <select name="section_name" onChange="ReloadSection();">
          <option value="">Select a section</option>
          <%=dbOP.loadCombo("distinct section","section",strTemp, request.getParameter("section_name"), false)%> 
        </select> </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>SUBJECT 
        CODE:</strong></font></td>
      <td height="25"><%strTemp = " from faculty_load join e_sub_section on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) "+
			"join subject on (e_sub_section.sub_index = subject.sub_index) where faculty_load.user_index = "+
			strEmployeeIndex+" and e_sub_section.section = '"+WI.fillTextValue("section_name")+
			"' and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
			strSYFrom + " and e_sub_section.offering_sy_to = "+strSYTo;%> <select name="subject" id="subject" onChange="ReloadPage()">
          <option value="">Select a subject</option>
          <%=dbOP.loadCombo("distinct subject.sub_index","sub_code",strTemp, request.getParameter("subject"), false)%> 
        </select> <% if(WI.fillTextValue("subject").length() > 0) {
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name"," and is_del=0");
%> <strong> <%=WI.getStrValue(strTemp)%>
        <%}%>
        </strong> </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp;DATE 
        :&nbsp;</strong></font></td>
      <td height="25"><input name="date_for" type="text" class="textbox" id="date_for" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_for")%>"  size="12" maxlength="12" readonly> 
        &nbsp;<a href="javascript:show_calendar('form_.date_for');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
      </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td><div align="left"></div></td>
      <td height="25">&nbsp; </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
  </table>
<%	if (vRetResult  != null && WI.fillTextValue("sy_to").length() > 0
		 && WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0
		  && WI.fillTextValue("date_for").length() > 0) { %>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="2"><div align="right"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print Lesson Plan</font></div></td>
    </tr>
    <% 	iCtr = 0; int iIndex = 0;
	for (int i = 0; i < vRetResult.size() ; i+=6,iCtr++) {
		if (vRetResult.elementAt(i) != null){ %>
    <tr bgcolor="#D5EAEA"> 
      <td width="26%" height="25">&nbsp;</td>
      <td width="74%"><strong><font color="#FF0000"><%=(String)vRetResult.elementAt(i+1)%> </font></strong></td>
    </tr>
    <%}// if elementAt(i) != null%>
    <tr> 
      <td><strong><%=(String)vRetResult.elementAt(i+4)%></strong></td>
      <td>
	  <%
	  	if (vEditInfo != null){	
			iIndex = vEditInfo.indexOf(vRetResult.elementAt(i+3));
		
			if (iIndex != -1){
				strTemp = 	WI.getStrValue((String)vEditInfo.elementAt(iIndex+1));
				vEditInfo.removeElementAt(iIndex);
				vEditInfo.removeElementAt(iIndex);
			}
			else
				strTemp = "";
		}else  strTemp = WI.fillTextValue("textarea_"+iCtr);
	  %>
	  <textarea name="textarea_<%=iCtr%>" style="font-size:11px" cols="48" rows="4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  	onBlur="style.backgroundColor='white'"><%=strTemp%></textarea> <input type="hidden" name="sub_index_<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+3)%>">
<!--        <a href="javascript:insertAtCursor('textarea_<%=iCtr%>','<br>\n');">&lt;Insert EOL&gt;</a>--></td>
    </tr>
    <%}%>
    <tr> 
      <td colspan="2"> <div align="center">
          <% 	if (iAccessLevel > 1){
	  if(vEditInfo == null) { %>
          <a href="javascript:AddRecord()"><img border="0" src="../../../images/save.gif" width="48" height="28"></a> 
          <font size="1">click to add record</font> 
          <%     
  }else{ %>
          <a href="javascript:AddRecord()"><img src="../../../images/edit.gif" width="40" height="26" border="0"></a> 
          <font size="1">click to save changes </font><a href='javascript:CancelRecord();'><img src="../../../images/cancel.gif" width="51" height="26" border="0"></a> 
          <font size="1">click to cancel edit</font> 
          <%}}%>
        </div></td>
    </tr>
  </table>
<%}// end vRetResult != null %>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
  <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#6A99A2"> 
    <td height="25">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="page_action">
<input type="hidden" name="print_page">
<input type="hidden" name="info_index">
<input type="hidden" name="emp_id" value="<%=strEmployeeID%>">
<input type="hidden" name="iResult" value="<%=iCtr%>">
<input type="hidden" name="subj_label">
</form>
</body>
</html>