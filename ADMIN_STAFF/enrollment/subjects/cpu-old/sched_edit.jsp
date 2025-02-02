<%@ page language="java" import="utility.*,enrollment.SubjectSection, enrollment.SubjectSectionCPU, java.util.Vector, java.util.Date" buffer="16kb"%>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;	
	Vector vEditInfo = null;
	WebInterface WI = new WebInterface(request);
	Vector vTemp = null;
	int iCtr = 0;
	int iCtr2 = 0;
	int iCtr3 = 0;
	int iCtr4 = 0;
	int i = -1;
	int j=0;
	String strSYTo = null; // this is used in
	String strCurIndex = null;
	String strCurIndex0 = null;
	boolean bolReloadInProgress = false;

	boolean bolFatalErr = false;
	boolean bolIsLaboratory = false;
	
	
	bolReloadInProgress = WI.fillTextValue("reload_in_progress").equals("1");

	//this is necessary for different types of subject offering.
	//degree_type=0->UG,1->Doctoral,2->medicine,3->with prep proper, 4-> care giver.
	//for care giver,doctoral, do not show year level, for prep_prop, show prep/prop status.

	String[] astrSchYrInfo = null;
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};
	String[] strConvertWeek = {
          "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
	String[] strConvertWeekInit = {
          "S", "M", "T", "W", "TH", "F", "SAT"};


	String strCollegeIndex = null;
	String strCollegeName  = null;
	String strDeptIndex    = null;
	String strDeptName     = null;
	String strStubCode     = WI.fillTextValue("stub_code");
	
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-subject sectioning","sched_edit.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		strTemp = "<form name=ssection><input type=hidden name=showsubject></form>";
		%><%=strTemp%><%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														"sched_edit.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	if(!response.isCommitted())
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
	else
	%>
		<script language="JavaScript">
		location = "../../../../commfile/fatal_error.jsp";
		</script>
	<%
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	if(!response.isCommitted())
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	else
	%>
		<script language="JavaScript">
		location = "../../../../commfile/unauthorized_page.jsp";
		</script>
	<%
	return;
}

//end of authenticaion code.
	
strTemp = WI.fillTextValue("page_action");


strErrMsg = null; //if there is any message set -- show at the bottom of the page.
SubjectSection SS = new SubjectSection();
SubjectSectionCPU SSCPU= new SubjectSectionCPU();
String strEditArea = WI.getStrValue(WI.fillTextValue("editArea"),"0");
String strTimeLeft = null;
String strSubIndex = null;

//System.out.println(strTemp);

if(strTemp.length() > 0) {

		if (strTemp.equals("10")) {
			if(SSCPU.deleteSectionCPU(dbOP,request)){
				strErrMsg = "Stub Code deleted successfully ";
			}else{
				strErrMsg = SSCPU.getErrMsg();
			}
		}else{
			if(SSCPU.operateOnSchedule(dbOP, request, Integer.parseInt(strTemp)) != null ) {
				strErrMsg = "Operation successful.";
			} else{
				strErrMsg = SSCPU.getErrMsg();
			}
		}
	}

	astrSchYrInfo = dbOP.getCurSchYr();
	if(astrSchYrInfo == null)//db error
	{
		strErrMsg = dbOP.getErrMsg();
		bolFatalErr = true;
	}
	
	if (!strTemp.equals("10")) {
		vEditInfo = SSCPU.operateOnSchedule(dbOP, request, 0);
	
//		System.out.println(vEditInfo);
		
		if (vEditInfo==null)
			strErrMsg = SSCPU.getErrMsg();	
	}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Subject Section Scheduling Page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>

.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
}
.trigger1 {	cursor: pointer;
	cursor: hand;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" SRC="../../../../jscript/td.js"></script>
<script language="JavaScript">

//var openImg = new Image();
//openImg.src = "../../../../images/add.gif";
//var closedImg = new Image();
//closedImg.src = "../../../images/box_with_plus.gif";

function showBranch(branch,strWeekDay){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block"){
		objBranch.display="none";
		document.ssection.force_add_schedule.value="";
		document.ssection.sub_sel124.value="";

	}else{
		objBranch.display="block";
		document.ssection.force_add_schedule.value="1";
		document.ssection.sub_sel124.value=strWeekDay;
	}
}

//function swapFolder(img){
//	objImg = document.getElementById(img);
//	if(objImg.src.indexOf('box_with_plus.gif')>-1)
//		objImg.src = openImg.src;
//	else
//		objImg.src = closedImg.src;
//}

function trimString (str) {
  str = this != window? this : str;
  return str.replace(/^\s+/g, '').replace(/\s+$/g, '');
}


function GoBack() {
	location = "./pick_sched.jsp";
}
/*
function SwitchArea()
{
	if (document.ssection.editArea[0].checked)
	{
//		document.ssection.c_index.disabled = false;
//		document.ssection.d_index.disabled = false;
//		document.ssection.school_year_fr.readOnly = false;
//		document.ssection.school_year_to.readOnly = false;
		showLayer('area1');
	}
	else
	{
//		document.ssection.c_index.disabled = true;
//		document.ssection.d_index.disabled = true;
//		document.ssection.school_year_fr.readOnly = true;
//		document.ssection.school_year_to.readOnly = true;
		hideLayer('area1');
	}
	
	if (document.ssection.editArea[1].checked)
	{
//		document.ssection.sub_stat.disabled = false;
//		document.ssection.section.readOnly = false;
//		document.ssection.off_cap.readOnly = false;
		showLayer('area2');
	}
	else
	{
//		document.ssection.sub_stat.disabled = true;
//		document.ssection.off_cap.readOnly = true;
		hideLayer('area2');
	}
	
	if (document.ssection.editArea[2].checked)
	{

//		document.ssection.course_index.disabled = false;
//		if (document.ssection.major_index) 
//			document.ssection.major_index.disabled = false;
//		document.ssection.yr_lvl.readOnly = false;
		showLayer('area3');
	}
	else
	{
//		document.ssection.course_index.disabled = true;
//		if (document.ssection.major_index) 
//			document.ssection.major_index.disabled = false;
//		document.ssection.yr_lvl.readOnly = true;
		hideLayer('area3');
	}

if (document.ssection.editArea[3].checked)
		showLayer('area4');
	else
		hideLayer('area4');

if (document.ssection.editArea[4].checked)
	{
//		document.ssection.fac_index.disabled = false;
//		document.ssection.scroll_fac.readOnly = false;
//		document.ssection.credit_load.readOnly = false;
//		document.ssection.hour_load.readOnly = false;
		showLayer('area5');
	}
	else
	{
//		document.ssection.fac_index.disabled = true;
//		document.ssection.scroll_fac.readOnly = true;
//		document.ssection.credit_load.readOnly = true;
//		document.ssection.hour_load.readOnly = true;
		hideLayer('area5');
	}
}
*/
function PageAction(strAction, strInfoIndex) {

	document.ssection.donot_call_close_wnd.value = "1";
	if(strInfoIndex.length > 0) 
		document.ssection.info_index.value = strInfoIndex;
	document.ssection.page_action.value = strAction;
	document.ssection.reload_in_progress.value="1";
	this.SubmitOnce('ssection');
}
function CheckValidHour(strFieldName) {

	var fldName = "document.ssection."+strFieldName+".value";
	if(eval(fldName) > 12 || eval(fldName) == 0) {
		alert('Time should be >0 and <= 12');
		eval(fldName +"= ''") ;
	}
}

function CheckValidMin(strFieldName) {
	
	var fldName = "document.ssection."+strFieldName+".value";
	if(eval(fldName) > 59) {
		alert('Time cannot be > 59');
		eval(fldName+ "= ''");
	}
}

function ReloadPage()
{
	document.ssection.donot_call_close_wnd.value = "1";
	if(document.ssection.reload_in_progress.value == 1)
		return;
	document.ssection.reload_in_progress.value = "1";
	document.ssection.submit();
}

function disableLec() {//call this only if subject is having either lec or lab but not mixed
	document.ssection.is_lec.selectedIndex = 0;
	document.ssection.is_lec.disabled = true;
}

function AddNewSection(){
	var strCurrentSection = document.ssection.section.value;
	var strCurrentForm = document.ssection;	
	var strCourseCode; // array, [0] code  [1] course name
	var strMajorCode; // array, [0] code  [1] course name
	var strCollegeCode; // array, [0] code  [1] course name
	
	
	if (strCurrentForm.college_index.selectedIndex > 0){	
		if (trimString(strCurrentSection).length> 0) {
			strCurrentSection = trimString(strCurrentSection) + "/"; // add single slash
		}else{
			strCurrentSection ="";
		}
		
		strCollegeCode = strCurrentForm.college_index[strCurrentForm.college_index.selectedIndex].text.split("(");
		strCurrentSection += strCollegeCode[0];   // Ag
		
		strCurrentForm.college_index.selectedIndex = 0;
		document.ssection.section.value = strCurrentSection;

	} else 
		if (strCurrentForm.course_index.selectedIndex > 0){
			if (trimString(strCurrentSection).length> 0) {
				strCurrentSection = trimString(strCurrentSection) + "/"; // add single slash
			}else{
				strCurrentSection ="";
			}
		
			strCourseCode = strCurrentForm.course_index[strCurrentForm.course_index.selectedIndex].text.split(" "); 
			strCurrentSection += strCourseCode[0];   // law 101/law _
		
			if (strCurrentForm.major_index){
				if (strCurrentForm.major_index.selectedIndex > 0){
					strMajorCode = strCurrentForm.major_index[strCurrentForm.major_index.selectedIndex].text.split(" ")
					strCurrentSection +="|"+strMajorCode[0];
				}
			}	
		}
	
	if (strCurrentForm.year_level.value.length > 0){
		if (strCurrentForm.section_number.value.length > 0){
			strCurrentSection += " " + strCurrentForm.year_level.value;
			if (strCurrentForm.section_number.value.length == 1) 
				strCurrentSection += "0" + strCurrentForm.section_number.value;
			else
				strCurrentSection += strCurrentForm.section_number.value;
		}else{
			alert(" Please enter section");
			strCurrentForm.section_number.focus();
			return;
		}
	}
		
	document.ssection.section.value = strCurrentSection;
	
}

function DisableCourseMajor(){
	if (document.ssection.c_index.selectedIndex != 0) {
		document.ssection.course_index.disable= true;
		if (document.ssection.major_index != null)
			document.ssection.major_index.disable = true;
	}else{
		document.ssection.course_index.disable= false;
		if (document.ssection.major_index != null)
			document.ssection.major_index.disable = true;
	}
}

function DeleteRecord(){
	document.ssection.donot_call_close_wnd.value = "1";
	document.ssection.page_action.value= "10";
	document.ssection.submit();
}


function CloseWindow(){
	document.ssection.close_wnd_called.value = "1";
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
	self.close();
}
function ReloadParentWnd() {	

  if(document.ssection.donot_call_close_wnd.value.length >0)
	return;

  if(document.ssection.close_wnd_called.value == "0") {
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
  }
}

function checkSubject(){
//	alert('hello');
	if (document.ssection.subject_offered) {
	
		var strDropListText = 
			document.ssection.subject_offered[document.ssection.subject_offered.selectedIndex].text;
		
//		alert(strDropListText) ;
		if (document.ssection.scroll_sub) { 
			
			var strAutoScrollText  = document.ssection.scroll_sub.value;
//
//			alert(strAutoScrollText) ;
//			alert(strAutoScrollText.length);
//			alert(strAutoScrollText.toUpperCase().equals(strDropListText.toUpperCase()));
	
			if(strAutoScrollText.length > 0 && 
				 strAutoScrollText.toUpperCase() != strDropListText.toUpperCase()){
			alert("Invalid Subject Code. Please check item in selection.");
			document.ssection.scroll_sub.value ='';
			document.ssection.subject_offered.selectedIndex = 0;
			return;
		}
  	  }
	}
}



</script>

<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<form name="ssection" action="./sched_edit.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          CLASS PROGRAMS - NEW CLASS PROGRAMS/SECTIONS PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="83%"> <font size="3" color="red"><b><%=WI.getStrValue(strErrMsg,"&nbsp;")%></b></font>      </td>
      <td width="14%">
	 <% if (WI.fillTextValue("opner_form_name").length() > 0) {%>
	  <a href="javascript:CloseWindow();"><img src="../../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a>
	 <%}else{%>
	  <a href="pick_sched.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0" align="right"></a>
	 
	 <%}%>  
	  </td>
    </tr>
    <% if(bolFatalErr){
		dbOP.cleanUP();//System.out.println(" I am here");
		strTemp = "<input type=hidden name=showsubject></form> </table>";
	 %>
    <%=strTemp%>
    <%return;}%>
        <input type="hidden" name="res_offering" value="1">
  </table>
  <%
  	if (vEditInfo!=null && vEditInfo.size() >0) {

  %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3"><div align="center"><font color="#FF0000" size="3"><strong>STUB CODE :<%=WI.fillTextValue("stub_code")%> </strong></font>&nbsp;&nbsp;
	  <a href="javascript:DeleteRecord()"><img src="../../../../images/delete.gif" border="0"></a></div></td>
    </tr>
    <tr> 
      <td width="2%" height="25"> &nbsp;
	<% 
//	   if (strEditArea.equals("1")) 
//			strTemp = "checked"; 
//	   else
//			strTemp = ""; 
	%>
<!--	  <input type="radio" value="1" name="editArea" onClick="javascript:SwitchArea();" 
				<%//=strTemp%>>
-->
	  </td>
      <td  colspan="2">Offering College: &nbsp; 
	<%
		
		if (vEditInfo!=null && vEditInfo.size()>0 && !bolReloadInProgress)
      		strTemp = (String)vEditInfo.elementAt(10);
	   	else
			strTemp = WI.fillTextValue("c_index");
			

	%> 
		<select name="c_index" onChange="ReloadPage();">
          <option value="">--</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		strTemp, false)%> 
		</select>	  </td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td  colspan="2">Offering Department: 
  <%
	if (vEditInfo!=null && vEditInfo.size()>0 && !bolReloadInProgress)
		strTemp2 = (String)vEditInfo.elementAt(11);
	else
		strTemp2 = WI.fillTextValue("d_index");
			
	if (strTemp != null && strTemp.length() > 0) 
		strTemp = " c_index = " + strTemp;
	else
		strTemp = "((c_index is not null and c_index <> 0)  or d_code ='NSTP')";
		
	strTemp = dbOP.loadCombo("d_index","d_name"," from department where IS_DEL=0 " +
					" and " + strTemp + " order by d_name asc", strTemp2, false);

	if (strTemp.length() > 0) {			
    %> 

	 <select name="d_index">
     <option value="">--</option>
	 	<%=strTemp%>
	 </select>      </td>
    </tr>
<%}%>
    <tr> 
      <td>&nbsp;</td>
      <td  colspan="2" height="25">Class Program for school year : 
        <%
	  if (vEditInfo!=null && vEditInfo.size()>0 && !bolReloadInProgress)
      	strTemp = (String)vEditInfo.elementAt(5);
	  else
	  	strTemp = WI.fillTextValue("school_year_fr");
		
	  if(strTemp.length() ==0) 
		  	strTemp = astrSchYrInfo[0];
	  %>
	  <input name="school_year_fr" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("ssection","school_year_fr","school_year_to")'> 
        - 
	  <%
        if (vEditInfo!=null && vEditInfo.size()>0 && !bolReloadInProgress)
    	  	strTemp = (String)vEditInfo.elementAt(6);
	   	else
		  strTemp = WI.fillTextValue("school_year_to");
	  
	  	if(strTemp.length() ==0) 
			strTemp = astrSchYrInfo[1];
	  %>		
        <input name="school_year_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        &nbsp;&nbsp;&nbsp;&nbsp; <select name="offering_sem">
          <option value="0">Summer</option>
          <%
	  
          if (vEditInfo!=null && vEditInfo.size()>0 && !bolReloadInProgress)
		   	strTemp = (String)vEditInfo.elementAt(7);
		  else
			strTemp = WI.fillTextValue("offering_sem");
			
		  if(strTemp.length() ==0)
			strTemp = astrSchYrInfo[2];
		  
		  if(strTemp.equals("1")){%>
	          <option value="1" selected>1st Sem</option>
          <%}else{%>
    	      <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
        	  <option value="2" selected>2nd Sem</option>
          <%}else{%>
	          <option value="2">2nd Sem</option>
          <%}%>
        </select> <input type="hidden" name="offering_sem_name" value="<%=astrConvertSem[Integer.parseInt(strTemp)]%>">      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="2" align="right">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2" align="right"><div align="center"><a href='javascript:PageAction(1,"");' id="area1"><img src="../../../../images/save.gif" border="0"></a></div></td>
    </tr>
    <tr> 
      <td colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%
	if (vEditInfo != null ){
		if ((String)vEditInfo.elementAt(8) != null && 
		((String)vEditInfo.elementAt(8)).equals("1")) {
		bolIsLaboratory = true;
	}

	if (bolIsLaboratory) {
%>
    <tr>
      <td height="25" colspan="5" align="center" bgcolor="#FAB4B6"><strong>LABORATORY SCHEDULE </strong></td>
    </tr>
	<%}else{%>
    <tr>
      <td height="25" colspan="5" align="center" bgcolor="#C1DDFF"><strong>LECTURE SCHEDULE</strong> </td>
    </tr>
<%	}
}%> 
    <tr> 
      <td width="2%"> &nbsp;
<%//if (strEditArea.equals("2"))
//			strTemp = "checked";
//			else
//			strTemp = "";
		%> 
		<!--<input type="radio" value="2" name="editArea" onClick="javascript:SwitchArea();" <%//=strTemp%>>      --></td>
      <td height="25" colspan="4" valign="bottom"> 
<%
	if (vEditInfo!=null && vEditInfo.size()>0 && !bolReloadInProgress)
		strTemp = (String)vEditInfo.elementAt(16);
	else
		strTemp = WI.fillTextValue("donot_check_conflict");
				
	if(strTemp.equals("1"))
		strTemp = " checked";
	else
		strTemp = "";
%> 
	<input type="checkbox" name="donot_check_conflict" value="1"<%=strTemp%>> 
        <font color="#0000FF"><strong>DO NOT CHECK CONFLICT (ex. Off campus subjects.)</strong></font></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td colspan="4" valign="bottom">Subject Title: 
<%
	if (vEditInfo!=null && vEditInfo.size()>0 && WI.fillTextValue("reloadPage").length() == 0)
		strSubIndex = (String)vEditInfo.elementAt(2);
	else
		strSubIndex = WI.fillTextValue("subject_offered");
	
	if (bolIsLaboratory) 
		strTemp = " (LABORATORY)";
	else 
		strTemp = "";

	if (WI.fillTextValue("reloadPage").length() > 0){
		strTemp = "";
	}else if (vEditInfo!=null && vEditInfo.size()>0) {
		strTemp = WI.getStrValue((String)vEditInfo.elementAt(25),"(",")","") + "&nbsp;&nbsp;" + 
			  WI.getStrValue((String)vEditInfo.elementAt(19),"&nbsp;") + strTemp;
	}
%>
					
	  <b><%=strTemp%></b>  	 </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">&nbsp;
		<input type="text" name="scroll_sub" class="textbox"
	     onKeyUp="AutoScrollListSubject('scroll_sub','subject_offered',true,'ssection');"
		 onBlur="checkSubject();">

	  <select name="subject_offered">
      <option value="selany">Select Subject code</option>
          <%=dbOP.loadCombo("sub_index","sub_code", " from subject where is_del=0 order by sub_code",
		  	strSubIndex, false)%> </select>
<!--	  	<input type="hidden" name="sub_index" value="<%//=strSubIndex%>"> -->
	  	<input type="hidden" name="is_lec" 
					value="<%=WI.getStrValue((String)vEditInfo.elementAt(8),"0")%>"> 
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="8%">Capacity: </td>
      <td width="34%"> <%
	  if (vEditInfo!=null && vEditInfo.size()>0)
		  strTemp = WI.getStrValue((String)vEditInfo.elementAt(17),"");
	  else
		  strTemp = WI.fillTextValue("off_cap");%> 
        <input name="off_cap" type="text" class="textbox" value="<%=strTemp%>" size="5" maxlength="5"
	   onKeyUp= 'AllowOnlyInteger("ssection","off_cap")' onFocus="style.backgroundColor='#D3EBFF'"
		onBlur='AllowOnlyInteger("ssection","off_cap");style.backgroundColor="white"'></td>
      <td width="14%">&nbsp;</td>
      <td width="42%" align="left">&nbsp; </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Status: </td>
      <td valign="bottom"> <%
      
      if (vEditInfo!=null && vEditInfo.size()>0)
      	strTemp = (String)vEditInfo.elementAt(15);
   	else
	     strTemp = WI.fillTextValue("sub_stat");%> 
        <select name="sub_stat">
          <%=dbOP.loadCombo("status_index","status"," from e_sub_status order by status_index asc",strTemp, false)%> </select> </td>
      <td>
<%	if (bolIsLaboratory) {%>
	  Lecture Index
<%	}%>	  </td>
      <td>
<%  if (bolIsLaboratory) {
	  if (vEditInfo!=null && vEditInfo.size()>0)
		  strTemp = WI.getStrValue((String)vEditInfo.elementAt(24),"");
	  else
		  strTemp = WI.fillTextValue("lec_index");%>
	 <input name="lec_index" type="text" class="textbox" value="<%=strTemp%>" size="5" maxlength="5"
	 onKeyUp= 'AllowOnlyInteger("ssection","lec_index")' onFocus="style.backgroundColor='#D3EBFF'"
	 onBlur='AllowOnlyInteger("ssection","lec_index");style.backgroundColor="white"'>
<% } %>	 </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4"> <div align="center"><a href="javascript:PageAction(2,'')" id="area2"><img src="../../../../images/save.gif" border="0"></a></div></td>
    </tr>
  </table>
    <input type="hidden" name="c_index2" value="<%=strCollegeIndex%>">
    <input type="hidden" name="d_index2" value="<%=WI.getStrValue(strDeptIndex,"")%>">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="6">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td colspan="6" align="center" height="25"><font color="#FFFFFF"><strong>::: 
        OWNERSHIP DETAILS :::</strong></font></td>
    </tr>
    <tr> 
      <td height="25" align="left" width="4%"> &nbsp;
	  <%	
  
  		vTemp = (Vector)vEditInfo.elementAt(18);

//  		if (strEditArea.equals("3"))
//			strTemp = "checked";
//			else
//			strTemp = "";%> <!--<input type="radio" value="3" name="editArea" onClick="javascript:SwitchArea();" <%//=strTemp%>> --></td>
      <td colspan="3">&nbsp;</td>
    </tr>
		
	<tr>
      <td width="3%">&nbsp;</td>
      <td width="11%">&nbsp;College:</td> 
	  <%
	 	strTemp = " from e_college_code join college  " + 
				  " on (e_college_code.c_index = college.c_index) " +
				  " order by e_college_code.c_code ";
	 %>
      <td width="86%">
		<select name="college_index" onChange="DisableCourseMajor()">
          <option value="">Specify College</option>
		 <%=dbOP.loadCombo("e_college_code.c_index", "e_college_code.c_code,college.c_name",
				 	strTemp,WI.fillTextValue("college_index"), false)%>
		</select>
	  </td>
	</tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="11%">&nbsp;Course:</td>
      <td width="86%"> 
        <select name="course_index" onChange="ReloadPage('3')">
          <option value="">OPEN TO ALL</option>
<%
  	strTemp = " from e_course_code join course_offered  on ( e_course_code.course_index = course_offered.course_index) " +
		 " order by e_code ";
%>
		  
  <%=dbOP.loadCombo("e_course_code.course_index",
  					" e_course_code.course_code  + ' :: '+ course_offered.course_name as e_code ",
							strTemp,WI.fillTextValue("course_index"), false)%>
		</select>
      </td>
    </tr>
<% if (WI.fillTextValue("course_index").length() > 0) {

  	strTemp = " from e_major_code join major  on (e_major_code.major_index = major.major_index) " +
		" where major.course_index =  " + WI.fillTextValue("course_index") +
	    " order by e_code";
	
	strTemp = dbOP.loadCombo("e_major_code.major_code",
		  					" e_major_code.major_code  + ' :: '+ major.major_name as e_code ",
							strTemp,WI.fillTextValue("major_index"), false);
							
	if (strTemp.length() > 0) {
%>
	
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;Major:</td>
      <td> 
        <select name="major_index">
          <option value="">Any Major</option>
		  <%=strTemp%>
        </select> 
      </td>
    </tr>
<%} // if strTemp.lenght > 0
} // if course is selected
%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Year Level: </td>
      <td> <input name="year_level" type="text" class="textbox" 
	   value="<%=WI.fillTextValue("year_level")%>" size="2" maxlength="1"
	   onKeyUp= 'AllowOnlyInteger("ssection","year_level")' onFocus="style.backgroundColor='#D3EBFF'"
	   onblur='AllowOnlyInteger("ssection","year_level");style.backgroundColor="white"'> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Section No :</td>
      <td align="left"> <input name="section_number" type="text" class="textbox" 
	  		value="<%=WI.fillTextValue("section_number")%>" 
		onFocus="style.backgroundColor='#D3EBFF'" size="2" 
	    onKeyUp= 'AllowOnlyInteger("ssection","section_number")'  maxlength="2"
		onblur='AllowOnlyInteger("ssection","section_number");style.backgroundColor="white"'> 
      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="left"><a href="javascript:AddNewSection()"><img src="../../../../images/add.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td valign="top">Section: </td>
      <td align="left"> <%
		if (vEditInfo!=null && vEditInfo.size()>0 && WI.fillTextValue("reloadPage").length() == 0){
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(4));
			if (strTemp.equals("*")) strTemp = "";
		}else
			strTemp = WI.fillTextValue("section");%> 
			<textarea name="section" cols="32" rows="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
    <tr> 
      <td colspan="3">&nbsp; </td>
    </tr>
    <tr> 
      <td colspan="3"> 
	  <%
	  	if (vTemp!= null && vTemp.size()>0){
//			System.out.println(vTemp);
	  %> 
	  	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder" >
          <tr bgcolor="#DDDDDD"> 
            <td height="20" colspan="5" align="center" class="thinborder"> <strong>::: OWNERSHIP DETAILS::: </strong></td>
          </tr>
          <tr>
            <td width="25%" align="center" class="thinborder"><strong>COLLEGE</strong></td> 
            <td width="26%" align="center" class="thinborder"><strong>COURSE</strong></td>
            <td width="23%" align="center" class="thinborder"><strong>MAJOR</strong></td>
            <td width="15%" align="center" class="thinborder"><strong>YEAR 
              LEVEL</strong></td>
            <td width="11%" align="center" class="thinborder"><font size="1"><strong>SECTION</strong>&nbsp;</font></td>
          </tr>
          <%	//System.out.println(vTemp);
		  	for (iCtr=0;iCtr<vTemp.size();iCtr+=9){%>
          <tr>
            <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vTemp.elementAt(iCtr+1),"-")%></td> 
            <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vTemp.elementAt(iCtr+3),"-")%></td>
            <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vTemp.elementAt(iCtr+5),"-")%></td>
            <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vTemp.elementAt(iCtr+7),"-")%></td>
            <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vTemp.elementAt(iCtr+8),"-")%></td>
          </tr>
          <%} // end for loop%>
        </table>
        <%}%> 
      </td>
    </tr>
    <tr>
      <td colspan="3"><div align="center"><a href='javascript:PageAction(4,"");' id="area3"><img src="../../../../images/save.gif" border="0"></a><font size="1">Save Section</font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="7"><hr size="1"></td>
      <%vTemp = (Vector)vEditInfo.elementAt(20);%>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td colspan="7" align="center" height="25"><font color="#FFFFFF"><strong>::: 
        SCHEDULE DETAILS :::</strong></font></td>
    </tr>
    <tr> 
      <td colspan="7" height="25" align="left"> <%
//  		if (strEditArea.equals("4"))
//			strTemp = "checked";
//			else
//			strTemp = "";%> 
<!--<input type="radio" value="4" name="editArea" onClick="javascript:SwitchArea();" <%//=strTemp%>> -->
      </td>
    </tr>
    <tr> 
      <td width="6%" height="25" align="center"><strong><font size="1">SELECT 
        </font></strong></td>
      <td width="14%"><strong><font size="1">&nbsp;WEEKDAY</font></strong></td>
      <td width="24%"><strong><font size="1">TIME FROM</font></strong></td>
      <td width="24%"><strong><font size="1">TIME TO</font></strong></td>
      <td width="24%"><strong><font size="1">ROOM</font></strong></td>
      <td width="8%" align="center"><font size="1"><strong>NEW SCHEDULE</strong></font></td>
    </tr>
    <%
	 
	for (iCtr = 0, iCtr3 = 0; iCtr < 7; ++iCtr) {
	if (vTemp!= null && vTemp.size()>0){
	iCtr4 = iCtr3;
	
	for(iCtr2 = 0; iCtr2 < vTemp.size(); iCtr2+=9){

	if (((String)vTemp.elementAt(iCtr2+1)).equals(Integer.toString(iCtr))){%>
    <tr> 
      <td align="center"><input type="checkbox" name="sub_sel<%=iCtr3%>" value="<%=iCtr%>" checked></td>
      <td align="left"><%=strConvertWeek[iCtr]%></td>
      <td><%strTemp = WI.getStrValue((String)vTemp.elementAt(iCtr2+2),"");%>
	  <input type="text" name="time_from_hr<%=iCtr3%>" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='AllowOnlyInteger("ssection","time_from_hr<%=iCtr3%>"); CheckValidHour("time_from_hr<%=iCtr3%>")'>
        : 
        <%strTemp = WI.getStrValue((String)vTemp.elementAt(iCtr2+3),"");%> 
	  <input type="text" name="time_from_min<%=iCtr3%>" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" 
	  onBlur='AllowOnlyInteger("ssection","time_from_min<%=iCtr3%>"); style.backgroundColor="white"' value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidMin('time_from_min<%=iCtr3%>');">
        : 
        <select name="time_from_AMPM<%=iCtr3%>">
          <option selected value="0">AM</option>
          <%
strTemp = WI.getStrValue((String)vTemp.elementAt(iCtr2+4));
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select> </td>
      <td><%strTemp = WI.getStrValue((String)vTemp.elementAt(iCtr2+5),"");%> 
	 <input type="text" name="time_to_hr<%=iCtr3%>" 
	  size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidHour('time_to_hr<%=iCtr3%>');">
        : 
        <%strTemp = WI.getStrValue((String)vTemp.elementAt(iCtr2+6),"");%>
	 <input type="text" name="time_to_min<%=iCtr3%>"  size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidMin('time_to_min<%=iCtr3%>');">
        : 
        <select name="time_to_AMPM<%=iCtr3%>">
          <option selected value="0">AM</option>
        <% strTemp = WI.getStrValue((String)vTemp.elementAt(iCtr2+7),"");
		if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
         <%}%>
        </select> </td>
      <td> <%strTemp = WI.getStrValue((String)vTemp.elementAt(iCtr2+8),"");%> 
	  <input type="text" name="room_list<%=iCtr3%>" size="15" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"> 
      </td>
      <td>
<div class="trigger" onClick="showBranch('branch1','<%=iCtr%>');"> 	
	 <img src="../../../../images/add.gif" width="42" height="32" border="0">
</div>
	  </td>
    </tr>
    <%
	 ++iCtr3;}%>
    <%}
	 if (iCtr4 == iCtr3)
	 {%>
    <tr> 
      <td align="center"><input type="checkbox" name="sub_sel<%=iCtr3%>" value="<%=iCtr%>"></td>
      <td align="left"><%=strConvertWeek[iCtr]%></td>
      <td> 
	  <input type="text" name="time_from_hr<%=iCtr3%>" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='AllowOnlyInteger("ssection","time_from_hr<%=iCtr3%>"); CheckValidHour("time_from_hr<%=iCtr3%>")'>
        : 
      <input type="text" name="time_from_min<%=iCtr3%>" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" 
	  onBlur='AllowOnlyInteger("ssection","time_from_min<%=iCtr3%>"); style.backgroundColor="white"' 
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidMin('time_from_min<%=iCtr3%>');">
        : 
      <select name="time_from_AMPM<%=iCtr3%>">
       <option selected value="0">AM</option>
 <%
	strTemp = WI.fillTextValue("time_from_AMPM"+iCtr3);
	if(strTemp.equals("1")){%>
          <option value="1" selected>PM</option>
    <%}else{%>
          <option value="1">PM</option>
 <%}%>
       </select> </td>
      <td> <input type="text" name="time_to_hr<%=iCtr3%>" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidHour('time_to_hr<%=iCtr3%>');">
        : 
        <input type="text" name="time_to_min<%=iCtr3%>"  size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidMin('time_to_min<%=iCtr3%>');">
        : 
        <select name="time_to_AMPM<%=iCtr3%>">
          <option selected value="0">AM</option>
          <%
strTemp = WI.fillTextValue("time_to_AMPM"+iCtr3);
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select> </td>
      <td> <input type="text" name="room_list<%=iCtr3%>" size="15" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("room_list"+iCtr3)%>"> 
      </td>
      <td>&nbsp;</td>
    </tr>
    <%++iCtr3;}%>
    <%} else {%>
    <tr> 
      <td align="center"><input type="checkbox" name="sub_sel<%=iCtr3%>" value="<%=iCtr%>"></td>
      <td align="left"><%=strConvertWeek[iCtr]%></td>
      <td> 
	  <input type="text" name="time_from_hr<%=iCtr3%>" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='AllowOnlyInteger("ssection","time_from_hr<%=iCtr3%>"); CheckValidHour("time_from_hr<%=iCtr3%>")'>
        : 
      <input type="text" name="time_from_min<%=iCtr3%>" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" 
	  onBlur='AllowOnlyInteger("ssection","time_from_min<%=iCtr3%>"); style.backgroundColor="white"' 
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidMin('time_from_min<%=iCtr3%>');">
        : 
        <select name="time_from_AMPM<%=iCtr3%>">
          <option selected value="0">AM</option>
          <%
strTemp = WI.fillTextValue("time_from_AMPM"+iCtr3);
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select> </td>
      <td> <input type="text" name="time_to_hr<%=iCtr3%>" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidHour('time_to_hr<%=iCtr3%>');">
        : 
        <input type="text" name="time_to_min<%=iCtr3%>"  size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidMin('time_to_min<%=iCtr3%>');">
        : 
        <select name="time_to_AMPM<%=iCtr3%>">
          <option selected value="0">AM</option>
          <%
strTemp = WI.fillTextValue("time_to_AMPM"+iCtr3);
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select> </td>
      <td> <input type="text" name="room_list<%=iCtr3%>" size="15" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("room_list"+iCtr3)%>"> 
      </td>
      <td>&nbsp;</td>
    </tr>
    <%
	 ++iCtr3;
	 } 
	 
	 }
	
	%>

	
    <tr>
      <td colspan="6" align="center">
<!-- variable is added with "124"  to indicate forced variable --> 
	  <input type="hidden" name="sub_sel124" value="<%=WI.fillTextValue("sub_sel124")%>">
<span class="branch" id="branch1">

	  	<table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td height="25" colspan="5" bgcolor="#FDF7F7"> 
				<strong>&nbsp;&nbsp;&nbsp;Add new Time / Room :</strong>
            </td>
          </tr>
          <tr> 
            <td width="12%">&nbsp; </td>
            <td width="23%" bgcolor="#FFFFFF">
                <input type="text" name="time_from_hr124" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=WI.fillTextValue("time_from_hr124")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='AllowOnlyInteger("ssection","time_from_hr124"); CheckValidHour("time_from_hr124")'>
              :
  <input type="text" name="time_from_min124" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("time_from_min124")%>"
	  onBlur='AllowOnlyInteger("ssection","time_from_min124"); style.backgroundColor="white"'
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidMin('time_from_min124');">
              :
  <select name="time_from_AMPM124">
    <option selected value="0">AM</option>
<%
	if(WI.fillTextValue("time_from_AMPM124").equals("1")){%>
    <option value="1" selected>PM</option>
<%}else{%>
    <option value="1">PM</option>
<%}%>
  </select>            </td>
            <td width="25%" bgcolor="#FFFFFF">
     <input type="text" name="time_to_hr124" 
	  size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=WI.fillTextValue("time_to_hr124")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidHour('time_to_hr124');">
              :
  <input type="text" name="time_to_min124"  size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=WI.fillTextValue("time_to_min124")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidMin('time_to_min124');">
              :
  <select name="time_to_AMPM124">
    <option selected value="0">AM</option>
    <%
	if(WI.fillTextValue("time_to_AMPM124").equals("1")){%>
    <option value="1" selected>PM</option>
    <%}else{%>
    <option value="1">PM</option>
    <%}%>
  </select>            </td>
            <td width="18%" bgcolor="#FFFFFF">
                <input type="text" name="room_list124" size="15" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=WI.fillTextValue("room_list124")%>">            </td>
            <td width="22%">
			<div class="trigger" onClick="showBranch('branch1','');"> 	
				<img src="../../../../images/cancel.gif" width="51" height="26" border="0"> 
			</div>
			</td>
          </tr>		  
        </table>
</span> &nbsp;
      </td>
    </tr>
    <tr> 
      <td colspan="6" align="center"><a href='javascript:PageAction(5,"");'><img src="../../../../images/save.gif" border="0"></a><font size="1">Save Schedule Details</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td colspan="3" align="center" height="25"><font color="#FFFFFF"><strong>::: 
        FACULTY LOADING DETAILS :::</strong></font></td>
    </tr>
    <tr> 
      <td height="25" width="10%">&nbsp;
<!--
	   <%
//  		if (strEditArea.equals("5"))
//			strTemp = "checked";
//			else
//			strTemp = "";%> <input type="radio" value="5" name="editArea" onClick="javascript:SwitchArea();" <%//=strTemp%>> 
-->
      </td>
      <td width="15%">Instructor: </td>
      <td width="75%"><input name="scroll_fac" type="text" class="textbox"
	     onKeyUp="AutoScrollList('ssection.scroll_fac','ssection.fac_index',true);" size="16"> 
        <%if (vEditInfo!= null && vEditInfo.size()>0)
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(21),"");
		else
			strTemp = WI.fillTextValue("fac_index");%> <select name="fac_index" title="SELECT A  TEACHER"
	  	style="font-size:11px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;">
          <option value="">Select a teacher</option>
          <%=dbOP.loadCombo("user_table.user_index","lname +' '+fname+' ('+id_number+')' as fac_name",
	" from user_table where exists (select * from faculty_sub_can_teach where "+
	" faculty_sub_can_teach.user_index = user_table.user_index and is_del = 0 " +
	 WI.getStrValue(strSubIndex, " and sub_index =","","") + ") order by fac_name",strTemp, false)%> </select> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25">Faculty Load: </td>
      <td> <%if (vEditInfo!= null && vEditInfo.size()>0)
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(22),"");
		else
			strTemp = WI.fillTextValue("credit_load");%> <input name="credit_load" type="text" class="textbox" value="<%=strTemp%>" size="5" maxlength="10"
	   onKeyUp= 'AllowOnlyFloat("ssection","credit_load")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyFloat("ssection","credit_load");style.backgroundColor="white"'> 
        <font size="1">(units)</font> &nbsp;&nbsp;&nbsp;&nbsp; &nbsp; <%if (vEditInfo!= null && vEditInfo.size()>0)
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(23),"");
		else
			strTemp = WI.fillTextValue("hour_load");%> <input name="hour_load" type="text" class="textbox" value="<%=strTemp%>" size="5" maxlength="10"
	   onKeyUp= 'AllowOnlyFloat("ssection","hour_load")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyFloat("ssection","hour_load");style.backgroundColor="white"'>	
        <font size="1">(hours)</font></td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><div align="center"><a href='javascript:PageAction(6,"");'><img src="../../../../images/save.gif" border="0"></a><font size="1">Save Faculty Loading</font></div></td>
    </tr>
  </table>
  <%} else {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
    	  <td height="25"><a href="javascript:GoBack();"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"> &nbsp;click to set another stub code </a></td>
	    </tr>
		<tr>
		  <td height="25">&nbsp;</td>
	  </tr>
	</table>
  <%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<!--  where to set the focus  --------->
<input type="hidden" name="set_focus_status" value="<%=WI.fillTextValue("set_focus_status")%>">
<!-------------->

<input name="info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="showsubject" value="<%=WI.fillTextValue("showsubject")%>">
<input type="hidden" name="stub_code" value="<%=strStubCode%>">
<input type="hidden" name="reload_in_progress" value="0">
<input type="hidden" name="force_add_schedule" value="">

<script language="JavaScript">
<!--

	if ( document.ssection.set_focus_status.value.length > 0) {
		switch(parseInt(document.ssection.set_focus_status.value)){
			case 1: document.ssection.scroll_sub.focus(); 
					if (document.ssection.subject_offered.selectedIndex != 0) 
						document.ssection.off_cap.focus();
				break;
			case 2: document.ssection.off_cap.focus(); break;
			case 3: document.ssection.year_level.focus(); break;
			case 4: document.ssection.scroll_sub.focus(); 
		}
	}
	
-->
</script>

  <input type="hidden" name="opner_form_name" value="<%=WI.fillTextValue("opner_form_name")%>">
  
<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
<!-- this is very important - onUnload do not call close window -->

<input type="hidden" name="maxSched" value="<%=iCtr3%>">
<%=dbOP.constructAutoScrollHiddenField()%>
</form>

</body>
</html>

<%
dbOP.cleanUP();
%>
