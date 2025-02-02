<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsCGH = strSchCode.startsWith("CGH");
if(strSchCode.startsWith("UDMC"))
	bolIsCGH = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.trigger{
	/**
	cursor: pointer;
	cursor: hand;
	**/
}
.branch{
	display: block;
	margin-left: 16px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=gsheet.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage(){
	document.gsheet.submit();
}
function PrepareToEdit(strGSIndex, strPrevGrade, strPrevRemark, strCE) {
	document.gsheet.edit_grade_prev.value=strPrevGrade;
	document.gsheet.edit_remark_prev.value=strPrevRemark;
	document.gsheet.edit_ce_prev.value=strCE;
	document.gsheet.edit_info_index.value=strGSIndex;
	document.gsheet.edit_prep.value=1;

	this.ReloadPage();
}
function EditGrade() {
	document.gsheet.edit_grade.value = "1";
	document.gsheet.remarkName.value =
		document.gsheet.remark_index[document.gsheet.remark_index.selectedIndex].text;

	if (document.gsheet.completion_date && document.gsheet.completion_date.value.length > 0){
		if (document.gsheet.re_exam_grade.value.length == 0){
			alert("Re-Exam grade required");
			return ;
		}
	}

	this.ReloadPage();
}
function CancelEdit() {
	location = "./grade_modification.jsp?stud_id="+document.gsheet.stud_id.value+"&sy_from="+document.gsheet.sy_from.value+
	"&sy_to="+document.gsheet.sy_to.value+"&semester="+document.gsheet.semester[document.gsheet.semester.selectedIndex].value+
	"&grade_for="+escape(document.gsheet.grade_for[document.gsheet.grade_for.selectedIndex].value);
}
function focusID() {
	document.gsheet.stud_id.focus();
}

///////////////////////////////////////// used to collapse and expand filter ////////////////////
var openImg = new Image();
openImg.src = "../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../images/box_with_plus.gif";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block" || objBranch.display==""){
		objBranch.display="none";
		document.gsheet.is_collapsed.value="0";
	}else{
		objBranch.display="block";
		document.gsheet.is_collapsed.value="1";
	}
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('box_with_plus.gif')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
}
///////////////////////////////////////// End of collapse and expand filter////////////////////

// for AUF / CGH ONLY!!!

var iFailedSelectedIndex = -1;
var iPassedSelectedIndex = -1;
function GetFailedSelectedIndex(strRemark){
	for (v=eval("document.gsheet."+strRemark+".length")-1 ; v >= 0; --v){
		if (eval("document.gsheet."+strRemark+
					"[" + v + "].text").toLowerCase().indexOf('failed') != -1)
			return v;
	}

}
function GetPassedSelectedIndex(strRemark){
	for (v=eval("document.gsheet."+strRemark+".length")-1 ; v >= 0; --v){
		if (eval("document.gsheet."+strRemark+
					"[" + v + "].text").toLowerCase().indexOf('pass') != -1)
			return v;
	}

}

/**
function UpdateRemarks(strGrade,strRemark,strFieldID){
	<%if(!bolIsCGH && strSchCode.startsWith("AUF")){%>
		return;
	<%}%>
	var vGrade = "";
	eval("vGrade = document.gsheet."+strGrade+".value");

	if(vGrade.length == 0 || vGrade <= 5)
		return;

	if (vGrade < 75){
		if (iFailedSelectedIndex == -1)
			iFailedSelectedIndex = GetFailedSelectedIndex(strRemark);
		eval("document.gsheet."+strRemark+".selectedIndex=" + iFailedSelectedIndex);
	}
	else if (vGrade >= 75){
		if (iPassedSelectedIndex == -1)
			iPassedSelectedIndex = GetPassedSelectedIndex(strRemark);
		eval("document.gsheet."+strRemark+".selectedIndex=" + iPassedSelectedIndex);
	}
	this.ConvertGrade(strFieldID);

}
**/
function UpdateRemarks(strGrade,strRemark, strFieldID){
	var vGrade = "";
	eval("vGrade = document.gsheet."+strGrade+".value");
	
	//alert(vGrade);
	if(vGrade.length == 0)
	return;
	
	//1 = 3 to 5 fail, else pass., 
	var iGradeSystem = 0;// 0 meaning 0 to 100
	
	var bolIsPass = false;
	
	//if fatima grade system is 1, but if encode in %ge grade, then it is in %ge.
	var bolInvalidGrade = false;
		
	<%if((strSchCode.startsWith("FATIMA")  || strSchCode.startsWith("NEU")) && !bolIsCGH) {%>
		iGradeSystem = 1;//Final Point.
		if(eval(vGrade) == 1 || eval(vGrade) == 1.25 || eval(vGrade) == 1.5 || eval(vGrade) == 1.75 || 
			eval(vGrade) == 2 || eval(vGrade) == 2.25 || eval(vGrade) == 2.5 || eval(vGrade) == 2.75 ||
			eval(vGrade) == 3 || eval(vGrade) == 5)
			bolInvalidGrade = false;
		else {	
			alert("Invalid Grade.");
			eval("document.gsheet."+strGrade+".value=''");
			eval("document.gsheet."+strGrade+".focus()");
			
		}
	<%}%>
	<%if(strSchCode.startsWith("EAC") && !bolIsCGH) {%>
		iGradeSystem = 0;
	<%}else if(strSchCode.startsWith("WUP")){%>
		iGradeSystem = 5;
	<%}else if(strSchCode.startsWith("DBTC") || strSchCode.startsWith("SWU")){%>
		iGradeSystem = 1;
	<%}else if (strSchCode.startsWith("PIT")) {%>
		iGradeSystem = 2;
	<%}else if (strSchCode.startsWith("UB") || strSchCode.startsWith("NEU")) {%>
		iGradeSystem = 6;
	<%}else if (strSchCode.startsWith("PWC")) {%>
		iGradeSystem = 7;
	<%}else if (strSchCode.startsWith("CIT")) {//1, 2 to 2.9 = fail, 3 to 5 pass, other not allowed.%>
			iGradeSystem = 4;//for final, grade system = 4
	<%}%>

	<%if(strSchCode.startsWith("CSA")) {%>
		if ( eval(vGrade) <1 || eval(vGrade) > 100){
			alert ("Invalid grade. Grade must be within 1-100");
			eval("document.gsheet."+strGrade+".focus()");
			eval("document.gsheet."+strGrade+".select()");
			return;
		}
	<%}%>
	if(iGradeSystem == 0) {
		if ( eval(vGrade) < 75){
			if (iFailedSelectedIndex == -1)
				iFailedSelectedIndex = GetFailedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iFailedSelectedIndex);
		}
		else if ( eval(vGrade) >= 75){
			if (iPassedSelectedIndex == -1)
				iPassedSelectedIndex = GetPassedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iPassedSelectedIndex);
			bolIsPass = true;
		}
	}
	else if(iGradeSystem == 1) {//for DBTC.. 
		if ( eval(vGrade) > 3){//failed..
			if (iFailedSelectedIndex == -1)
				iFailedSelectedIndex = GetFailedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iFailedSelectedIndex);
		}
		else {
			if (iPassedSelectedIndex == -1)
				iPassedSelectedIndex = GetPassedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iPassedSelectedIndex);
			bolIsPass = true;
		}
	}
	else if(iGradeSystem == 2) {//for PIT.. 
		if ( eval(vGrade) > 4.49){//failed..
			if (iFailedSelectedIndex == -1)
				iFailedSelectedIndex = GetFailedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iFailedSelectedIndex);
		}
		else if ( eval(vGrade) > 3.49){//failed..
			if (iConditioanlSelectedIndex == -1)
				iConditioanlSelectedIndex = GetConditionalSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iConditioanlSelectedIndex);
		}
		else {
			if (iPassedSelectedIndex == -1)
				iPassedSelectedIndex = GetPassedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iPassedSelectedIndex);
			bolIsPass = true;
		}
	}
	else if(iGradeSystem == 3 || iGradeSystem == 4) {//for CIT.. 
		//for 4, only 1, and 3 to 5 allowed.
		if(iGradeSystem == 4) {
			if(eval(vGrade) > 1 && eval(vGrade) <3) {
				alert("Invalid Grade. Please enter grade 1 or 3-5");
				eval("document.gsheet."+strGrade+".value=''");
				eval("document.gsheet."+strGrade+".focus()");
				
				return;
			}
		}
		if(vGrade.length > 3 || eval(vGrade) < 1 || eval(vGrade) > 5) {
			alert("Invalid Grade.");
			eval("document.gsheet."+strGrade+".value=''");
			eval("document.gsheet."+strGrade+".focus()");
			
			return;
		}
		if ( eval(vGrade) < 3){//failed..
			if (iFailedSelectedIndex == -1)
				iFailedSelectedIndex = GetFailedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iFailedSelectedIndex);
		}		
		else {
			if (iPassedSelectedIndex == -1)
				iPassedSelectedIndex = GetPassedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iPassedSelectedIndex);
			bolIsPass = true;
		}
	}
	else if(iGradeSystem == 5) {
		if ( eval(vGrade) < 85){
			if (iFailedSelectedIndex == -1)
				iFailedSelectedIndex = GetFailedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iFailedSelectedIndex);
		}
		else if ( eval(vGrade) >= 85){
			if (iPassedSelectedIndex == -1)
				iPassedSelectedIndex = GetPassedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iPassedSelectedIndex);
			bolIsPass = true;
		}
	}
	else if(iGradeSystem == 6) {
		if(eval(vGrade) < 1 || eval(vGrade) > 5) {
			alert("Invalid Grade.");
			eval("document.gsheet."+strGrade+".value=''");
			eval("document.gsheet."+strGrade+".focus()");
			
			return;
		}
	
	
		if ( eval(vGrade) >3){
			if (iFailedSelectedIndex == -1)
				iFailedSelectedIndex = GetFailedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iFailedSelectedIndex);
		}
		else{
			if (iPassedSelectedIndex == -1)
				iPassedSelectedIndex = GetPassedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iPassedSelectedIndex);
			bolIsPass = true;
		}
	}
	else if(iGradeSystem == 7) {
		if ( eval(vGrade) >4){
			if (iFailedSelectedIndex == -1)
				iFailedSelectedIndex = GetFailedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iFailedSelectedIndex);
		}
		else{
			if (iPassedSelectedIndex == -1)
				iPassedSelectedIndex = GetPassedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iPassedSelectedIndex);
			bolIsPass = true;
		}
	}
	
	if(bolIsPass) {
		if(document.gsheet.re_credit_earned)
			document.gsheet.re_credit_earned.value=document.gsheet.ce_enrolled_.value;	
		if(document.gsheet.ce)
			document.gsheet.ce.value=document.gsheet.ce_enrolled_.value;
		
		if (iPassedSelectedIndex == -1)
			iPassedSelectedIndex = GetPassedSelectedIndex(strRemark);
		if(document.gsheet.re_exam_remark)
			eval("document.gsheet.re_exam_remark.selectedIndex=" + iPassedSelectedIndex);
	}
	else {
		if(document.gsheet.re_credit_earned)
			document.gsheet.re_credit_earned.value='';	
		if(document.gsheet.ce)
			document.gsheet.ce.value='';
		if (iFailedSelectedIndex == -1)
			iFailedSelectedIndex = GetFailedSelectedIndex(strRemark);
		if(document.gsheet.re_exam_remark)
			eval("document.gsheet.re_exam_remark.selectedIndex=" + iFailedSelectedIndex);
	}

	if(strFieldID.length > 0) 
		this.ConvertGrade(strFieldID);

}

function jumpToInternship() {
	location = "./grade_modification_internship.jsp";
}
function jumpToThesis() {
	location = "./grade_modification_thesis.jsp";
}

function AjaxMapName(strRef) {
		var strSearchCon = "&search_temp=2";
		
		var strCompleteName = document.gsheet.stud_id.value;
		if(strCompleteName.length  < 3) 
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2"+strSearchCon+"&name_format=5&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
		//document.getElementById("coa_info").innerHTML=this.strPrevEntry+this.bolReturnStrEmpty
}
function UpdateID(strID, strUserIndex) {
	//do nothing.
	document.gsheet.stud_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}


</script>
<body bgcolor="#D2AE72" onLoad="focusID();">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Modification","grade_modification.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(),
														"grade_modification.jsp");
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Modification",request.getRemoteAddr(),
									"grade_modification.jsp");

}
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

GradeSystem GS = new GradeSystem();
FAPaymentUtil pmtUtil = new FAPaymentUtil();
String strEditGrade = WI.fillTextValue("edit_prep");
String strAutoCE = "";



//get student information first before getting grade details.
Vector vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
Vector vGradeDetail = null;

String strUserIndex = null;

String strGSIndex = WI.fillTextValue("edit_info_index");
boolean bolIsFinal = false;
if(WI.fillTextValue("grade_for").toLowerCase().startsWith("final"))
	bolIsFinal = true;

if(vStudInfo == null)
	strErrMsg = pmtUtil.getErrMsg();
else
{
	strUserIndex = (String)vStudInfo.elementAt(0);
	if (strEditGrade.length() > 0){
		if(bolIsFinal)
			strAutoCE = GS.getLoadingForSubject(dbOP,null, strGSIndex);
		else {
			String strStudIndex   = null;
			String strCurIndex    = null;
			String strSYFrom      = null;
			String strSemester    = null;
			String  strSQLQuery   = null;
    		java.sql.ResultSet rs = null;
			
			strSQLQuery = "select user_index_,cur_index, cur_hist_index from grade_sheet where gs_index = "+strGSIndex;
			rs = dbOP.executeQuery(strSQLQuery);
			if(rs.next()) {
				strStudIndex = rs.getString(1);
				strCurIndex  = rs.getString(2);
				strSQLQuery  = rs.getString(3);
			}
			rs.close();
			if(strStudIndex != null) {
				strSQLQuery = "select sy_from, semester from stud_curriculum_hist where cur_hist_index = "+strSQLQuery;
				rs = dbOP.executeQuery(strSQLQuery);
				if(rs.next()) {
					strSYFrom   = rs.getString(1);
					strSemester = rs.getString(2);
				}
				rs.close();
				strSQLQuery = "select unit_enrolled from enrl_final_cur_list where user_index = "+strStudIndex+
				" and is_valid = 1 and is_temp_stud = 0 and sy_from = "+strSYFrom+" and current_semester = "+strSemester+
				" and cur_index = "+strCurIndex;
				rs = dbOP.executeQuery(strSQLQuery);
				if(rs.next())
					strAutoCE = CommonUtil.formatFloat(rs.getDouble(1), false);
				rs.close();
			}
		}
	}
	//for wup i have to make sure the grade is submitted, verified and received.
	strErrMsg = null;
	if(strSchCode.startsWith("WUP") && strGSIndex != null && strGSIndex.length() > 0){
		String strSQLQuery = "select sub_sec_index from g_sheet_final where gs_index = "+strGSIndex;
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			strSQLQuery = rs.getString(1);
			if(strSQLQuery != null) {
				strSQLQuery = "select DATE_SUBMITTED_WUP,is_verified, date_received_WUP from faculty_load where sub_sec_index = "+strSQLQuery+
					" order by date_submitted_wup desc";
				rs = dbOP.executeQuery(strSQLQuery);
				if(rs.next()) {
					if(rs.getDate(1) == null) 
						strErrMsg = "Editing is not allowed. Grade sheet is not yet submitted.";
					if(rs.getInt(2) == 0) 
						strErrMsg = "Editing is not allowed. Grade sheet is not yet verified.";
					if(rs.getDate(3) == null) 
						strErrMsg = "Editing is not allowed. Grade sheet is not yet received.";
				}
				rs.close();
			}
		}
		if(strErrMsg != null)
			strEditGrade = "";
			
	}



	if(WI.fillTextValue("edit_grade").equals("1")) {//edit grade here.
		if(GS.gradeModification(dbOP, request)){//successful.
			strErrMsg = "Grade changed successfully.";
			strEditGrade = "";
		}
		else
			strErrMsg = GS.getErrMsg();
	}
	//get grade sheet release information.
	vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),
											request.getParameter("grade_for"),
											request.getParameter("sy_from"),
											request.getParameter("sy_to"),
											request.getParameter("semester"));

	if(vGradeDetail == null){
		strErrMsg = GS.getErrMsg();
	}
}

if(strErrMsg == null)
	strErrMsg = "";

boolean bolModFinalsOnly = true;
if(strSchCode.startsWith("UPHP"))
	bolModFinalsOnly = false;
boolean bolIsIsabella = false;
if(strSchCode.startsWith("UPH10"))
	bolIsIsabella = true;


boolean bolShowOnlyCompletionGrade = false;
//if(strSchCode.startsWith("SWU"))
	//bolShowOnlyCompletionGrade = true;
	
	
%>

<form name="gsheet" action="./grade_modification.jsp" method="post">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center"><font color="#FFFFFF"><strong>::::
        FINAL GRADE MODIFICATION PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" colspan="4" ><strong><%=strErrMsg%></strong></td>
    </tr>
<%
if(strUserIndex != null)
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 4);
else
	strTemp = null;
if(strTemp != null){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="3" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strTemp%></td>
      <td height="25" >&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="4" >Grade for: <strong>
<%
if(bolModFinalsOnly && false)
	strTemp = " and exam_name like 'final%' ";
else	
	strTemp = "";
%>
        <select name="grade_for" onChange="ReloadPage();">
          <%=dbOP.loadCombo("FA_PMT_SCHEDULE.EXAM_NAME","FA_PMT_SCHEDULE.EXAM_NAME",
		  " from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 "+strTemp+" order by EXAM_PERIOD_ORDER desc", request.getParameter("grade_for"), false)%>
        </select>
        </strong></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="48%" height="25" >Student ID: &nbsp; <input name="stud_id" type="text" size="16"
	  	value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF;position:absolute"></label>
	        </td>
      <td width="5%" ><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="43%" colspan="2" style="font-size:9px; font-weight:bold; color:#0000FF">
	  	<input name="modify_internship" type="checkbox" value="1" onClick="jumpToInternship();"> Modify Internship Information(finals)
<%if(strSchCode.startsWith("WNU")){%>
	<br>
	  	<input name="modify_thesis" type="checkbox" value="1" onClick="jumpToThesis();"> Modify Thesis/Project Paper Information(finals)
<%}%>
	  </td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >School Year/ Term:
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("gsheet","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes"> <select name="semester" onChange="ReloadPage();">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
      <td >&nbsp;</td>
      <td ><input name="image3" type="image" src="../../../images/form_proceed.gif"></td>
      <td width="2%">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="5" height="25" ><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" >Student name : <strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >Course/Major : <strong><%=(String)vStudInfo.elementAt(2)%>
         <%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td width="98%" height="25" >Year : <strong>
	  <%=WI.getStrValue((String)vStudInfo.elementAt(4),"N/A")%></strong></td>
    </tr>
    <tr>
      <td colspan="2" height="25" ><hr size="1"></td>
    </tr>
  </table>

<%}//only if vStudInfo is not null.
if(strEditGrade.equals("1")) {%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(bolIsCGH) {%>
    <tr >
      <td height="25">&nbsp;</td>
      <td colspan="4"><strong><font color="#0000FF" size="1">NOTE: Please encode grade in Percentage entry box. Once cursor goes out of focus, Final point and remarks are set automatically.</font></strong></td>
    </tr>
<%}if(strSchCode.startsWith("WUP")){%>
    <tr >
      <td height="25">&nbsp;</td>
      <td style="font-weight:bold; font-size:14px;"><input type="checkbox" name="is_removal" checked="checked"> Is Removal Grade </td>
      <td colspan="2">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<%}%>
    <tr >
      <td height="25" width="1%">&nbsp;</td>
      <td width="32%" height="25">Grade in record: <strong><%=WI.fillTextValue("edit_grade_prev")%></strong></td>
      <td height="25" colspan="2">New grade</td>
      <td width="53%" height="25"><input name="grade" type="text" size="3" class="textbox"
	   <%if(bolIsCGH){%>readonly<%}%> tabindex="-1"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';UpdateRemarks('grade','remark_index','');"
	  	  onKeyUp=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        <%if(bolIsCGH){%><strong>(Final Point)</strong> &nbsp;&nbsp;
          <input name="grade_percent" type="text" size="3" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white';UpdateRemarks('grade_percent','remark_index','0');"
	  	  onKeyUp="AllowOnlyFloat('gsheet','grade_percent');">
          <strong>(%ge) </strong>
        <%}%>
		<%if(bolIsIsabella){%><strong>(Semestral Grade)</strong> &nbsp;&nbsp;
          <input name="grade2" type="text" size="3" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white';UpdateRemarks('grade_percent_re','re_exam_remark','1');"
	  	  onKeyUp="AllowOnlyFloat('gsheet','grade2');">
          <strong>(Final Grade)</strong>
		  
          <input name="grade_percent" type="text" size="3" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white');"
	  	  onKeyUp="AllowOnlyFloat('gsheet','grade_percent');">
          <strong>(Avg Grade) </strong>
          <%}%>
		</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Remark in Record:<strong><%=WI.fillTextValue("edit_remark_prev")%></strong></td>
      <td height="25" colspan="2">New Remark</td>
      <td height="25"><select name="remark_index">
          <%=dbOP.loadCombo("REMARK_INDEX","REMARK"," from REMARK_STATUS where IS_DEL=0 and is_internal=1",null , false)%> </select>
&nbsp;&nbsp;&nbsp;Date :
<input name="apv_date" type="text" size="10" class="textbox" readonly="yes"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("apv_date")%>">
<a href="javascript:show_calendar('gsheet.apv_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Credit Earned in Record:<strong><%=WI.fillTextValue("edit_ce_prev")%></strong></td>
      <td height="25" colspan="2">New CE: </td>
      <td height="25">
	  <input name="ce" type="text" size="3" class="textbox" value="<%=strAutoCE%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">Reason for change:
        <input name="reason_to_change" type="text" size="60" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("reason_to_change")%>"></td>
    </tr>
  </table>

<% 
strTemp = WI.fillTextValue("edit_remark_prev").toLowerCase();
//System.out.println(strTemp);
if(!strSchCode.startsWith("WUP") && bolIsFinal) {
if ( (strTemp.startsWith("i") && strTemp.indexOf("progress") == -1) || strTemp.startsWith("no final exam") || strTemp.startsWith("conditional") || strTemp.startsWith("no exam")) {%>
<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="25" colspan="4">
  	  <div onClick="showBranch('branch1');swapFolder('folder1')" class="trigger">
          <img src="../../../images/box_with_minus.gif" width="7" height="7" border="0" id="folder1">
          <b><u>Encode ReExam/Completion Grade</u></b></div>
	  <span class="branch" id="branch1">
	    <table width="100%" cellpadding="0" cellspacing="0" border="0">
          <tr>
            <td height="25">ReExam Grade</td>
            <td width="3%"><input name="re_exam_grade" type="text" class="textbox" <%if(bolIsCGH){%>readonly<%}%>
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyFloat('gsheet','re_exam_grade');UpdateRemarks('re_exam_grade','remark_index','');" size="4"
	   maxlength="5" onKeyUp="AllowOnlyFloat('gsheet','re_exam_grade')"
	   value="<%=WI.fillTextValue("re_exam_grade")%>"></td>
            <td width="51%">
		<%if(bolIsCGH){%><strong>(Final Point)</strong> &nbsp;&nbsp;
          <input name="grade_percent_re" type="text" size="3" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white';UpdateRemarks('grade_percent_re','re_exam_remark','1');"
	  	  onKeyUp="AllowOnlyFloat('gsheet','grade_percent_re');">
          <strong>(%ge) </strong>
        <%}%>
		<%if(bolIsIsabella){%><strong>(Semestral Grade)</strong> &nbsp;&nbsp;
          <input name="grade2_re" type="text" size="3" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white';UpdateRemarks('grade_percent_re','re_exam_remark','1');"
	  	  onKeyUp="AllowOnlyFloat('gsheet','grade_percent_re');">
          <strong>(Final Grade)</strong>
		  
          <input name="grade_percent_re" type="text" size="3" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';" onKeyUp="AllowOnlyFloat('gsheet','grade_percent_re');">
          <strong>(Avg Grade) </strong>
          <%}%>


			Credit Earned :
            <input name="re_credit_earned" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyFloat('gsheet','re_credit_earned')" size="4" value="<%=strAutoCE%>"
	   maxlength="4" onKeyUp="AllowOnlyFloat('gsheet','re_credit_earned')"></td>
            <td> Remark</td>
            <td><select name="re_exam_remark">
                <%=dbOP.loadCombo("REMARK_INDEX","REMARK"," from REMARK_STATUS where IS_DEL=0 and is_internal=1",null , false)%>
				</select>
			</td>
          </tr>
          <tr>
            <td width="16%" height="25">Completion Date</td>
            <td colspan="2"><input name="completion_date" type="text" size="10" class="textbox" readonly="yes"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("completion_date")%>">
              <a href="javascript:show_calendar('gsheet.completion_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
            </td>
            <td width="6%">&nbsp; </td>
            <td width="24%">&nbsp; </td>
          </tr>
        </table>
	  </span>
</table>
<%}
}%>

	  </td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="25" colspan="4">
<%if(iAccessLevel == 2) {%>
	  <div align="center"> <a href="javascript:EditGrade();"><img src="../../../images/save.gif" border="0"></a>click
          to save changes <a href="javascript:CancelEdit();"><img src="../../../images/cancel.gif" border="0"></a>click
          to cancel edit</div>
<%}%>
	  </td>
    </tr>
  </table>
  <%}
if(vGradeDetail != null && vGradeDetail.size() > 0){%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="25" colspan="4"><div align="right"></div></td>
    </tr>
    <tr bgcolor="#B9B292">
      <td height="25" colspan="4"><div align="center"><strong>
	  <%=WI.fillTextValue("grade_name")%></strong>
          GRADES FOR <strong><%=WI.fillTextValue("semester_name")%></strong> <strong><%=WI.fillTextValue("sy_from")%>-
		  <%=WI.fillTextValue("sy_to")%></strong>
        </div></td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF"  width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td width="15%" height="25" align="center" ><font size="1"><strong>SUBJECT
        CODE </strong></font></td>
      <td width="30%" align="center" ><font size="1"><strong>SUBJECT NAME/DESCRIPTION
        </strong></font></td>
      <td width="10%" align="center"><font size="1"><strong>CREDIT EARNED</strong></font></td>
      <td width="20%" align="center"><font size="1"><strong>INSTRUCTOR</strong></font></td>
      <td width="8%" align="center"><font size="1"><strong>GRADE<%if(bolIsCGH){%><br>Final Point<%}%></strong></font></td>
<%if(bolIsCGH){%>
      <td width="8%" align="center"><font size="1"><strong>GRADE %ge</strong></font></td>
<%}%>      <td width="10%" align="center"><font size="1"><strong>REMARKS</strong></font></td>
      <td width="7%" align="center"><strong><font size="1">EDIT</font></strong></td>
    </tr>
    <%
for(int i=0,j = 0; i< vGradeDetail.size(); i += 7, ++j){
	if(bolShowOnlyCompletionGrade && !((String)vGradeDetail.elementAt(i+6)).toLowerCase().startsWith("i"))
		continue;
%>
    <tr>
      <td height="25" ><%=(String)vGradeDetail.elementAt(i + 1)%></td>
      <td ><%=(String)vGradeDetail.elementAt(i+2)%></td>
      <td ><%=(String)vGradeDetail.elementAt(i+3)%></td>
      <td ><%=WI.getStrValue((String)vGradeDetail.elementAt(i+4),"n/f")%></td>
      <td ><div align="center"><%=(String)vGradeDetail.elementAt(i+5)%></div></td>
<%if(bolIsCGH){%>
      <td align="center"><font size="1"><%=WI.getStrValue(GS.vCGHGrade.elementAt(j * 2 + 1))%>&nbsp;</font></td>
<%}%>
      <td ><div align="center"><%=(String)vGradeDetail.elementAt(i+6)%></div></td>
      <td align="center">
<%if(iAccessLevel == 2) {%>
	  <a href='javascript:PrepareToEdit("<%=(String)vGradeDetail.elementAt(i)%>",
	  	"<%=(String)vGradeDetail.elementAt(i+5)%>",
		"<%=(String)vGradeDetail.elementAt(i+6)%>","<%=(String)vGradeDetail.elementAt(i+3)%>");'>
		<img src="../../../images/edit.gif" border="0"></a>
<%}%>
	  </td>
    </tr>
    <%}%>
  </table>
<%
	}//if vGradeDetail size > 0
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="edit_grade_prev" value="<%=WI.fillTextValue("edit_grade_prev")%>">
<input type="hidden" name="edit_remark_prev" value="<%=WI.fillTextValue("edit_remark_prev")%>">
<input type="hidden" name="edit_ce_prev" value="<%=WI.fillTextValue("edit_ce_prev")%>">
<input type="hidden" name="edit_info_index" value="<%=WI.fillTextValue("edit_info_index")%>">
<input type="hidden" name="edit_prep" value="<%=strEditGrade%>">
<input type="hidden" name="edit_grade">
<input type="hidden" name="remarkName" value="<%=WI.fillTextValue("remarkName")%>">
<input type="hidden" name="is_collapsed" value="0">

<input type="hidden" name="ce_enrolled_" value="<%=WI.getStrValue(strAutoCE)%>">


<script language="javascript">
<%
//I have to add here converting grade from percent to final point.
Vector vGradeSystem = GS.viewAllGrade(dbOP, request);
if(vGradeSystem != null){%>
var vFailedGrade = "";
function ConvertGrade(strFieldID){
	var bolError = false;
	var gradeEncoded   = ""; var gradeEquivalent = "";
	if(strFieldID == '0')
		gradeEncoded = document.gsheet.grade_percent.value;
	else
		gradeEncoded = document.gsheet.grade_percent_re.value;

	if(gradeEncoded.length == 0) {
		document.gsheet.grade.value='';
		return;
	}
	gradeEquivalent = "";
	//I have to now check for if grade is within limit
		<%//double dGrade = 100d;
		for(int i =0; i < vGradeSystem.size(); i += 7){
			//if( ((String)vGradeSystem.elementAt(i + 5)).toLowerCase().startsWith("p"))
				//if(dGrade > Double.parseDouble((String)vGradeSystem.elementAt(i + 2)))
					//dGrade = Double.parseDouble((String)vGradeSystem.elementAt(i + 2));
				%>
			<%if(i > 0){%>else <%}%>if(gradeEncoded >= <%=(String)vGradeSystem.elementAt(i + 2)%> &&
					gradeEncoded <= <%=(String)vGradeSystem.elementAt(i + 3)%>)
				gradeEquivalent = <%=(String)vGradeSystem.elementAt(i + 1)%>;
		<%}//System.out.println(dGrade);%>
		//if grade equivalent is having final point, change it, else continue;

		if(gradeEquivalent.length == 0) {
			bolError = true;
		}
		else {
			if(strFieldID == '0')
				document.gsheet.grade.value = gradeEquivalent;
			else
				document.gsheet.re_exam_grade.value = gradeEquivalent;
		}

	if(bolError)
		alert("Error in converting grade. Please check all grades encoded.");

}
<%}else{%>
function ConvertGrade(){
	alert("Grade system is not set. Please check link :: Grade System :: and fill up the grade system.");
	return;
}
<%}%>
</script>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
