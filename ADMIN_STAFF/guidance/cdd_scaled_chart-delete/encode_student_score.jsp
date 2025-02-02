<%@ page language="java" import="utility.*,enrollment.ScaledScoreConversion,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%
response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>

</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../Ajax/ajax2.js"></script>

<script language="JavaScript">
function ReloadPage(){
	document.form_.info_index.value = '';
	document.form_.prepareToEdit.value = '';
	document.form_.submit();
}

function PageAction(strAction, strInfoIndex){
	if(strAction == '0'){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	
	document.form_.page_action.value = strAction;	
	document.form_.submit();
}

function PrepareToEdit(strInfoIndex){
	document.form_.prepareToEdit.value = '1';
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

function SetFocusID(){
	document.form_.stud_id.focus();
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddTestScore(){	
	if(document.form_.exam_main_index.value == ''){
		alert("Please select test name.");
		return;
	}
	document.form_.submit();
}	


function UpdateLabel(strLevelID) {
	var newVal = prompt('Please enter new Value');
	if(newVal == null)
		return;
	document.getElementById(strLevelID).innerHTML = newVal;
}

var objCOAInput;
var objTextBoxValue = "";

var objCOAInput2;
var objTextBox2 = "";

var strDigitScore = "-1,1";
var strPiccom = "-1,2";
var strSpatial = "-1,3";
var strPicarr = "-1,4";
var strObject = "-1,5";

var strInfo = "-1,6";
var strCompre = "-1,7";
var strArith = "-1,8";
var strSimilar = "-1,9";
var strVocab = "-1,10";

function AjaxGetScaledScore(strLabelID, strRawScore, strIQSSRank, strExamCatgIndex, strExamCatgDtlsIndex){		
	if(strLabelID == "" || strRawScore == "" || strIQSSRank == "" || strExamCatgIndex == "" || strExamCatgDtlsIndex == "")
		return;	
	
	objTextBoxValue = eval('document.form_.'+strRawScore+'.value');	
	if(objTextBoxValue == "")
		return;
	
	objCOAInput = document.getElementById(strLabelID);	
		
	this.InitXmlHttpObject2(objCOAInput, 2,"<img src='../../../Ajax/ajax-loader_small_black.gif' height='25'>");
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}	
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=30000&raw_score="+objTextBoxValue+"&exam_catg_dtls_index="+strExamCatgDtlsIndex;	
	this.processRequest(strURL);
	
	////////////////////////update for IQ-SS-RANK/////////////////////////////////////////////
	
	//i have to manually check here the value of each text box. phew!
	if(strRawScore == 'score_digit')
		strDigitScore = objTextBoxValue+","+strExamCatgDtlsIndex;
	if(strRawScore == 'score_piccom')
		strPiccom = objTextBoxValue+","+strExamCatgDtlsIndex;
	if(strRawScore == 'score_spatial')
		strSpatial = objTextBoxValue+","+strExamCatgDtlsIndex;
	if(strRawScore == 'score_picarr')
		strPicarr = objTextBoxValue+","+strExamCatgDtlsIndex;	
	if(strRawScore == 'score_object')
		strObject = objTextBoxValue+","+strExamCatgDtlsIndex;
		
	if(strRawScore == 'score_info')
		strInfo = objTextBoxValue+","+strExamCatgDtlsIndex;
	if(strRawScore == 'score_compre')
		strCompre = objTextBoxValue+","+strExamCatgDtlsIndex;
	if(strRawScore == 'score_arith')
		strArith = objTextBoxValue+","+strExamCatgDtlsIndex;
	if(strRawScore == 'score_similar')
		strSimilar = objTextBoxValue+","+strExamCatgDtlsIndex;		
	if(strRawScore == 'score_vocab')
		strVocab = objTextBoxValue+","+strExamCatgDtlsIndex;
	var strRawScoreList = "";	
	if(strExamCatgIndex == '1')
		strRawScoreList = strDigitScore+","+strPiccom+","+strSpatial+","+strPicarr+","+strObject;
	else
		strRawScoreList = strInfo+","+strCompre+","+strArith+","+strSimilar+","+strVocab;
	
	//alert(strRawScoreList);  aararaaraaronvfsdfsdf asdfasdfsdf  asdfasdf
	
	objCOAInput2 = document.getElementById(strIQSSRank);	
		
	this.InitXmlHttpObject4(objCOAInput2, 2,"<img src='../../../Ajax/ajax-loader_small_black.gif' height='25'>");
	if(this.xmlHttp2 == null) {
		alert("Failed to init xmlHttp.");
		return;
	}	
	var strURL2 = "../../../Ajax/AjaxInterface.jsp?methodRef=30001&exam_catg_index="+strExamCatgIndex+"&raw_score_list="+strRawScoreList+
		"&stud_age="+document.form_.stud_age.value;	
	this.processRequest2(strURL2);	
}


function AjaxGetTotalIQSSRank(){			
	var strAllRawScoreList = "";
	strAllRawScoreList = strDigitScore+","+strPiccom+","+strSpatial+","+strPicarr+","+strObject+","+strInfo+","+strCompre+","+strArith+","+strSimilar+","+strVocab;
		
	objCOAInput = document.getElementById('total_iq_ss_rank');			
	this.InitXmlHttpObject2(objCOAInput, 2, "<img src='../../../Ajax/ajax-loader_small_black.gif' height='25'>");
	if(this.xmlHttp == null){
		alert("Failed to init xmlHttp.");
		return;
	}		
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=30002&all_raw_score_list="+strAllRawScoreList+
			"&stud_age="+document.form_.stud_age.value;	
	this.processRequest(strURL);
}


function AjaxGetIQDescription(){		

	var strRawScore = document.form_.raw_score.value;	
	var strExamNameIndex = document.form_.rating_main_index.value;
		
	objCOAInput = document.getElementById('iq_description');			
	this.InitXmlHttpObject2(objCOAInput, 2, "<img src='../../../Ajax/ajax-loader_small_black.gif' height='25'>");
	if(this.xmlHttp == null){
		alert("Failed to init xmlHttp.");
		return;
	}		
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=30003&raw_score="+strRawScore+
		"&rating_main_index="+strExamNameIndex+"&stud_age="+document.form_.stud_age.value;	
	this.processRequest(strURL);
}

//// - all about ajax.. 
function AjaxMapName() {
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
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

</script>


<body bgcolor="#D2AE72" onLoad="SetFocusID();">

<%
	DBOperation dbOP  = null;
	String strErrMsg  = null;	
	String strTemp    = null;
	String strTemp2   = null;
	String strTemp3   = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-IQ Score Rating","encode_student_score.jsp");
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
									"Registrar Management","GRADES-IQ Score Rating",request.getRemoteAddr(), null);

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

ScaledScoreConversion scoreConversion = new ScaledScoreConversion();
Vector vRetResult = new Vector();
Vector vEditInfo  = new Vector();
Vector vStudDtls  = new Vector();
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");


strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){		
	if(scoreConversion.operateOnStudentIQTestScore(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = scoreConversion.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg = "Entry Successfully Deleted.";
		if(strTemp.equals("1"))
			strErrMsg = "Entry Successfully Saved.";
		if(strTemp.equals("2"))
			strErrMsg = "Entry Successfully Updated.";
		strPrepareToEdit = "";
		
	}
}
Vector vIQScore = new Vector();
Vector vMABScore = new Vector();

if(WI.fillTextValue("stud_id").length() > 0){
	vStudDtls = scoreConversion.operateOnStudentIQTestScore(dbOP, request, 5);
	if(vStudDtls == null)
		strErrMsg = scoreConversion.getErrMsg();
	else{
		vRetResult = scoreConversion.operateOnStudentIQTestScore(dbOP, request, 4);
		if(vRetResult == null)
			strErrMsg = scoreConversion.getErrMsg();		
	}
}
	
if(strPrepareToEdit.length() > 0){
	vEditInfo = scoreConversion.operateOnStudentIQTestScore(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = scoreConversion.getErrMsg();
}

%>
<form name="form_" action="./encode_student_score.jsp" method="post">
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">

    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          ENCODE STUDENT SCORE ::::</strong></font></div></td>
    </tr>
    <tr><td height="25" colspan="6">&nbsp; &nbsp; &nbsp; <strong><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="15%">SY/Term: </td>
		
		<td colspan="3">			
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
			</select>
	  </td>
	</tr>
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="15%">Student ID</td>
		<%
		strTemp = WI.fillTextValue("stud_id");
		%>
	  <td colspan="2">		
		<input type="text" name="stud_id" value="<%=strTemp%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" size="20" maxlength="32" onKeyUp="AjaxMapName();">
		&nbsp; &nbsp; &nbsp; 
		<a href="javascript:OpenSearch();">
		<img src="../../../images/search.gif" border="0" align="absmiddle"></a>
				&nbsp;
		<a href="javascript:document.form_.submit();">
		<img src="../../../images/form_proceed.gif" border="0" align="absmiddle"></a>
	  </td>		
	</tr>
	<tr><td colspan="2">&nbsp;</td>
	<td><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
	<td>&nbsp;</td>
	</tr>
	<%if(vStudDtls != null && vStudDtls.size() > 0){%>	
	<tr><td colspan="4"><hr width="100%"></td></tr>
	<tr><td colspan="4">&nbsp;</td></tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Student ID</td>
		<td><strong><%=WI.getStrValue((String)vStudDtls.elementAt(0))%></strong></td>
		<td rowspan="4" width="30%">&nbsp;
			<!--<img src="../../../images/logo/CIT_CEBU.gif" border="0" height="90" width="90">-->
		</td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Student Name </td>
		<td><strong><%=WI.getStrValue((String)vStudDtls.elementAt(1))%></strong></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Student Age </td>
		<td><strong><%=WI.getStrValue((String)vStudDtls.elementAt(4))%> y/o</strong></td>
	</tr>
	<input type="hidden" name="stud_age" value="<%=(String)vStudDtls.elementAt(4)%>" />
	<tr>
		<td height="25">&nbsp;</td>
		<td>Course</td>
		<td><strong><%=WI.getStrValue((String)vStudDtls.elementAt(2))%></strong></td>
	</tr>
	
	
	<tr><td colspan="3">&nbsp;</td></tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Test Name</td>
		<td colspan="2">
		<select name="exam_main_index">
			<option value="">Select Any</option>
			<%=dbOP.loadCombo("EXAM_MAIN_INDEX","exam_name", " from CDD_EXAM_MAIN where is_valid = 1 order by exam_name ", WI.fillTextValue("exam_main_index"), false)%>
		</select>
		</td>
	</tr>
	<tr>
		<td colspan="2" height="25">&nbsp;</td>
		<td colspan="2">
		<a href="javascript:AddTestScore();">
		<img src="../../../images/add.gif" border="0"></a>
		<font size="1">Click to add test score</font>
		</td>
	</tr>
	<tr><td colspan="5">&nbsp;</td></tr>
	<%}%>
</table>


<%if(WI.fillTextValue("exam_main_index").length() > 0){
	if(WI.fillTextValue("exam_main_index").equals("2")){
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr><td height="20" colspan="14">&nbsp;<strong>IQ Test</strong></td></tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td width="15%">Exam Name</td>
		<td colspan="13">
		<select name="rating_main_index" onChange="document.form_.submit();" >
			<option value="">Select Any</option>
			<%=dbOP.loadCombo("RATING_MAIN_INDEX","IQ_EXAM_NAME", " from CDD_IQ_RATING_EXAM_NAME where is_valid = 1 order by IQ_EXAM_NAME ", WI.fillTextValue("rating_main_index"), false)%>
		</select>
		</td>
	</tr>
	
	<%if(WI.fillTextValue("rating_main_index").length() > 0){%>
	<tr>
		<td height="20" colspan="2">&nbsp;</td>
		<td width="21%"><strong>SCORE</strong></td>
		<td width="20%"><strong>IQ</strong></td>
		<td><strong>Description</strong></td>
	</tr>
	
	
	<tr>
		<td height="20" colspan="2">&nbsp;</td>		
		<%
		strTemp = WI.fillTextValue("raw_score");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(1);
		%>
		<td>
		<input type="text" name="raw_score" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','raw_score');style.backgroundColor='white';" 
					onkeyup="AjaxGetIQDescription();AllowOnlyInteger('form_','raw_score')" size="10" maxlength="5" value="<%=strTemp%>" />
		</td>
		<td colspan="2"><label id="iq_description"></label></td>
	</tr>
</table>
	<%}
	}else{%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">	
	<tr><td height="20" colspan="14"><strong>M.A.B. Test</strong></td></tr>
	<tr>
		<td height="20" colspan="2"><strong>DIGIT</strong></td>		
		<td colspan="2"><strong>PIC COM</strong></td>		
		<td colspan="2"><strong>SPATIAL</strong></td>		
		<td colspan="2"><strong>PIC ARR</strong></td>		
		<td colspan="2"><strong>OBJECT</strong></td>		
		<td width="10%"><strong>TOTAL</strong></td>
		<td width="10%"><strong>IQ</strong></td>
		<td width="10%"><strong>SS</strong></td>
		<td width="10%"><strong>RANK</strong></td>
	</tr>
	
	
	<tr>		
		<td height="20" width="7%">
			<input type="text" name="score_digit" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="AjaxGetTotalIQSSRank();AllowOnlyInteger('form_','score_digit');style.backgroundColor='white';" 
				onkeyup="AjaxGetScaledScore('obj_digit','score_digit','performance_total_iq_ss_rank','1','1');					
					AllowOnlyInteger('form_','score_digit');"						
				size="7" maxlength="5" value="<%=WI.fillTextValue("score_digit")%>" />		</td>
		<td width="5%"><label id="obj_digit"></label></td>
		<td width="7%">
		<input type="text" name="score_piccom" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="AjaxGetTotalIQSSRank();AllowOnlyInteger('form_','score_piccom');style.backgroundColor='white';" 
				onkeyup="AjaxGetScaledScore('obj_piccom','score_piccom','performance_total_iq_ss_rank','1','2');
					AllowOnlyInteger('form_','score_piccom')" 
				size="7" maxlength="5" value="<%=WI.fillTextValue("score_piccom")%>" />		</td>
		<td width="5%"><label id="obj_piccom"></label></td>
		<td width="7%">
		<input type="text" name="score_spatial" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="AjaxGetTotalIQSSRank();AllowOnlyInteger('form_','score_spatial');style.backgroundColor='white';" 
				onkeyup="AjaxGetScaledScore('obj_spatial','score_spatial','performance_total_iq_ss_rank','1','3');
					AllowOnlyInteger('form_','score_spatial');" 				
				size="7" maxlength="5" value="<%=WI.fillTextValue("score_spatial")%>" />	</td>
		<td width="5%"><label id="obj_spatial"></label></td>
		<td width="7%">
		<input type="text" name="score_picarr" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="AjaxGetTotalIQSSRank();AllowOnlyInteger('form_','score_picarr');style.backgroundColor='white';" 
				onkeyup="AjaxGetScaledScore('obj_picarr','score_picarr','performance_total_iq_ss_rank','1','4');
					AllowOnlyInteger('form_','score_picarr');" 
				size="7" maxlength="5" value="<%=WI.fillTextValue("score_picarr")%>" />		</td>
		<td width="5%"><label id="obj_picarr"></label></td>
		<td width="7%">
		<input type="text" name="score_object" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="AjaxGetTotalIQSSRank();AllowOnlyInteger('form_','score_object');style.backgroundColor='white';" 
				onKeyUp="AjaxGetScaledScore('obj_object','score_object','performance_total_iq_ss_rank','1','5');
					AllowOnlyInteger('form_','score_object');"
				size="7" maxlength="5" value="<%=WI.fillTextValue("score_object")%>" /></td>
		<td width="5%"><label id="obj_object"></label></td>
		
		<td colspan="4"><strong><label id="performance_total_iq_ss_rank"></label></strong></td>
	</tr>
	
	<tr bgcolor="#999999"><td colspan="14">&nbsp;</td></tr>
	
	<tr>
		<td height="20" colspan="2"><strong>INFO</strong></td>		
		<td colspan="2"><strong>COMPRE</strong></td>		
		<td colspan="2"><strong>ARITH</strong></td>		
		<td colspan="2"><strong>SIMILAR</strong></td>		
		<td colspan="2"><strong>VOCAB</strong></td>		
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>

	<tr>
		<td height="20" width="7%">
			<input type="text" name="score_info" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AjaxGetTotalIQSSRank();AllowOnlyInteger('form_','score_info');style.backgroundColor='white';" 
					onkeyup="AjaxGetScaledScore('obj_info','score_info','verbal_total_iq_ss_rank','2','6');AllowOnlyInteger('form_','score_info')" 
					size="7" maxlength="5" value="<%=WI.fillTextValue("score_info")%>" />		</td>
		<td width="5%"><label id="obj_info"></label></td>
		<td width="7%">
		<input type="text" name="score_compre" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AjaxGetTotalIQSSRank();AllowOnlyInteger('form_','score_compre');style.backgroundColor='white';" 
					onkeyup="AjaxGetScaledScore('obj_compre','score_compre','verbal_total_iq_ss_rank','2','7');AllowOnlyInteger('form_','score_compre')" 
					size="7" maxlength="5" value="<%=WI.fillTextValue("score_compre")%>" />		</td>
		<td width="5%"><label id="obj_compre"></label></td>
		<td width="7%">
		<input type="text" name="score_arith" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AjaxGetTotalIQSSRank();AllowOnlyInteger('form_','score_arith');style.backgroundColor='white';" 
					onkeyup="AjaxGetScaledScore('obj_arith','score_arith','verbal_total_iq_ss_rank','2','8');AllowOnlyInteger('form_','score_arith')" 
					size="7" maxlength="5" value="<%=WI.fillTextValue("score_arith")%>" />		</td>
		<td width="5%"><label id="obj_arith"></label></td>
		<td width="7%">
		<input type="text" name="score_similar" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AjaxGetTotalIQSSRank();AllowOnlyInteger('form_','score_similar');style.backgroundColor='white';" 
					onkeyup="AjaxGetScaledScore('obj_similar','score_similar','verbal_total_iq_ss_rank','2','9');AllowOnlyInteger('form_','score_similar')" 
					size="7" maxlength="5" value="<%=WI.fillTextValue("score_similar")%>" />		</td>
		<td width="5%"><label id="obj_similar"></label></td>
		<td width="7%">
		<input type="text" name="score_vocab" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AjaxGetTotalIQSSRank();AllowOnlyInteger('form_','score_vocab');style.backgroundColor='white';" 
					onkeyup="AjaxGetScaledScore('obj_vocab','score_vocab','verbal_total_iq_ss_rank','2','10');AllowOnlyInteger('form_','score_vocab')" 
					size="7" maxlength="5" value="<%=WI.fillTextValue("score_vocab")%>" />		</td>
		<td width="5%"><label id="obj_vocab"></label></td>
		
		
		<td colspan="4"><strong><label id="verbal_total_iq_ss_rank"></label>
		</strong></td>
	</tr>
	
	<tr>
		<td height="25" colspan="10">&nbsp;</td>
		<td colspan="4"><strong><label id="total_iq_ss_rank"></label></strong></td>
	</tr>	
</table>	



<%}%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr><td colspan="3">&nbsp;</td></tr>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="15%">&nbsp;</td>
		<td>
			<a href="javascript:PageAction('1','');">
			<img src="../../../images/save.gif" border="0"></a>			
			<font size="1">Click to save scores</font>
		</td>
	</tr>
	<tr><td colspan="3">&nbsp;</td></tr>
</table>
<%}%>

  
  
<%
String[] astrConvertSem = {"Summer", "1st Sem", "2nd Sem", "3rd Sem", "4th Sem", "5th Sem", "6th Sem"};
if(vRetResult != null && vRetResult.size() > 0){
vIQScore = (Vector)vRetResult.remove(0);
vMABScore = (Vector)vRetResult.remove(0);
	if(vIQScore != null && vIQScore.size() > 0 || vMABScore != null && vMABScore.size() > 0)
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr bgcolor="#A49A6A"><td height="25" align="center"><strong>:::: TEST TAKEN ::::</strong></td></tr>
</table>

<%if(vIQScore != null && vIQScore.size() > 0){%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	<tr><td class="thinborder" colspan="7" height="20" align="center"><strong>I.Q. Test</strong></td></tr>
	<tr bgcolor="#0066FF">
		<td class="thinborder" height="20" width="20%"><strong>EXAM NAME</strong></td>
		<td class="thinborder" height="20" width="7%"><strong>SCORE</strong></td>
		<td class="thinborder" height="20" width="7%"><strong>IQ</strong></td>
		<td class="thinborder" height="20" width="30%"><strong>DESCRIPTION</strong></td>
		<td class="thinborder" height="20" width="10%"><strong>AGE</strong></td>
		<td class="thinborder" height="20" width="20%"><strong>SEMESTER</strong></td>
		<td class="thinborder" height="20"><strong>OPTION</strong></td>
	</tr>
	
	<%
	for(int i = 0; i < vIQScore.size(); i+=11){
	%>
	<tr>
		<td class="thinborder" height="20"><%=(String)vIQScore.elementAt(i+2)%></td>
		<td class="thinborder" height="20"><%=(String)vIQScore.elementAt(i+9)%></td>
		<td class="thinborder" height="20"><%=(String)vIQScore.elementAt(i+4)%></td>
		<td class="thinborder" height="20"><%=(String)vIQScore.elementAt(i+8)%></td>
		<td class="thinborder" height="20"><%=(String)vIQScore.elementAt(i+10)%></td>
		<td class="thinborder" height="20">
			<%=astrConvertSem[Integer.parseInt((String)vIQScore.elementAt(i+7))]%>
			S.Y. <%=(String)vIQScore.elementAt(i+5)%>-<%=(String)vIQScore.elementAt(i+6)%> 		
		</td>
		<td class="thinborder" height="20" align="center"><a href="javascript:PageAction('0','<%=(String)vIQScore.elementAt(i)%>')" >
		<img src="../../../images/x_small.gif" border="0"></a></td>
	</tr>
	<%}%>
	
</table>

	<%}%>
	
 <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
 <tr><td>&nbsp;</td></tr>
 </table>
	
	<%if(vMABScore != null && vMABScore.size() > 0){%>
    
    <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">	
	<tr><td class="thinborder" colspan="50" height="20" align="center"><strong>M.A.B. Test</strong></td></tr>
	<tr bgcolor="#CCCCCC">
		<td width="10%" height="20" class="thinborder" align="center" colspan="2"><strong>DIGIT</strong></td>		
		<td width="10%" class="thinborder" align="center" colspan="2"><strong>PIC COM</strong></td>		
		<td width="10%" class="thinborder" align="center" colspan="2"><strong>SPATIAL</strong></td>		
		<td width="10%" class="thinborder" align="center" colspan="2"><strong>PIC ARR</strong></td>		
		<td width="10%" class="thinborder" align="center" colspan="2"><strong>OBJECT</strong></td>		
		<td width="10%" class="thinborder" align="center" colspan="2"><strong>INFO</strong></td>		
		<td width="10%" class="thinborder" align="center" colspan="2"><strong>COMPRE</strong></td>		
		<td width="10%" class="thinborder" align="center" colspan="2"><strong>ARITH</strong></td>		
		<td width="10%" class="thinborder" align="center" colspan="2"><strong>SIMILAR</strong></td>		
		<td width="10%" class="thinborder" align="center" colspan="3"><strong>VOCAB</strong></td>	
	</tr>
	
	<tr>
		<td class="thinborder" align="center"><strong>RAW</strong></td>
		<td class="thinborder" align="center"><strong>SCALED</strong></td>
		<td class="thinborder" align="center"><strong>RAW</strong></td>
		<td class="thinborder" align="center"><strong>SCALED</strong></td>
		<td class="thinborder" align="center"><strong>RAW</strong></td>
		<td class="thinborder" align="center"><strong>SCALED</strong></td>
		<td class="thinborder" align="center"><strong>RAW</strong></td>
		<td class="thinborder" align="center"><strong>SCALED</strong></td>
		<td class="thinborder" align="center"><strong>RAW</strong></td>
		<td class="thinborder" align="center"><strong>SCALED</strong></td>
		<td class="thinborder" align="center"><strong>RAW</strong></td>
		<td class="thinborder" align="center"><strong>SCALED</strong></td>
		<td class="thinborder" align="center"><strong>RAW</strong></td>
		<td class="thinborder" align="center"><strong>SCALED</strong></td>
		<td class="thinborder" align="center"><strong>RAW</strong></td>
		<td class="thinborder" align="center"><strong>SCALED</strong></td>
		<td class="thinborder" align="center"><strong>RAW</strong></td>
		<td class="thinborder" align="center"><strong>SCALED</strong></td>
		<td class="thinborder" align="center"><strong>RAW</strong></td>
		<td class="thinborder" align="center" colspan="2"><strong>SCALED</strong></td>
	</tr>
	
	<%		
	for(int i = 0; i < vMABScore.size(); i += 32){		
	%>
	
	<tr>
		<td height="20" class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+9)%></td>
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+4)%></td>		
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+10)%></td>
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+5)%></td>		
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+11)%></td>		
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+6)%></td>
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+12)%></td>		
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+7)%></td>
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+13)%></td>		
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+8)%></td>
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+19)%></td>		
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+14)%></td>
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+20)%></td>		
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+15)%></td>
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+21)%></td>		
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+16)%></td>
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+22)%></td>		
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+17)%></td>
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+23)%></td>	
		<td class="thinborder" align="center"><%=(String)vMABScore.elementAt(i+18)%></td>
		<td class="thinborder" align="center" rowspan="2">
		<a href="javascript:PageAction('0','<%=(String)vMABScore.elementAt(i)%>')" ><img src="../../../images/x_small.gif" border="0"></a>
		</td> 
	</tr>
	
	<tr>		
		<td class="thinborder" colspan="4">TOTAL SCALED SCORE <strong><%=(String)vMABScore.elementAt(i+24)%></strong></td>
		<td class="thinborder" colspan="5">IQ RATING <strong><%=(String)vMABScore.elementAt(i+25)%> ::: <%=(String)vMABScore.elementAt(i+31)%></strong></td>
		<td class="thinborder" colspan="3">STANDARD SCORE <strong><%=(String)vMABScore.elementAt(i+26)%></strong></td>
		<td class="thinborder" colspan="2">RANK <strong><%=(String)vMABScore.elementAt(i+27)%></strong></td>
		<td class="thinborder" colspan="2" height="20">STUDENT AGE <strong><%=(String)vMABScore.elementAt(i+3)%></strong></td>
		<td class="thinborder" colspan="4" height="20">
		<strong><%=astrConvertSem[Integer.parseInt((String)vMABScore.elementAt(i+30))]%>
			S.Y. <%=(String)vMABScore.elementAt(i+28)%>-<%=(String)vMABScore.elementAt(i+29)%></strong>
		</td>
	</tr>
	<%}%>
</table>
	<%}%>

<%}%>


  
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" >
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" />
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
