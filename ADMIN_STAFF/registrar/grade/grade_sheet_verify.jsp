<%
if(true) {
	response.sendRedirect("./grade_sheet_verify_new.jsp");
	return;
}%>

<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	Vector vSecDetail = null;
	int j = 0;
	
	if(WI.fillTextValue("print_pg").length() > 0) {%>
			<jsp:forward page="./grade_sheet_verify_print.jsp" />
	<%return;}


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Verify","grade_sheet_verify.jsp");
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
														null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Sheets Verification",request.getRemoteAddr(),
									null);

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
enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
enrollment.GradeSystem  GS = new enrollment.GradeSystem();
GradeSystemExtn gsExtn     = new GradeSystemExtn();
String strEmployeeIndex    = null;

String strEmployeeID = WI.fillTextValue("emp_id");
if(strEmployeeID.length() > 0)
	strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);

String strSubSecIndex   = null;

Vector vRetResult = null;
Vector vPendingGrade = new Vector();
Vector vEncodedGrade = new Vector();

strTemp = WI.fillTextValue("page_action");
if(strTemp.compareTo("1") == 0) //save grade sheet.
{
	if(gsExtn.verifyGrade(dbOP, WI.fillTextValue("section"),1,
		(String)request.getSession(false).getAttribute("userIndex")) )
		strErrMsg = "Grade sheet verified. Only registrar can modify grade.";
	else	
		strErrMsg = gsExtn.getErrMsg();
}
else if(strTemp.compareTo("0") == 0) { //call for delete.
	if(gsExtn.verifyGrade(dbOP, WI.fillTextValue("section"),0,
		(String)request.getSession(false).getAttribute("login_log_index")) )
		strErrMsg = "Grade sheet verification removed successfully. Faculty can modify this grade.";
	else	
		strErrMsg = gsExtn.getErrMsg();
}

//get here necessary information.
if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
	strSubSecIndex = dbOP.mapOneToOther("E_SUB_SECTION join faculty_load on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
						"section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index", 
						" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+
						" and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
						WI.fillTextValue("sy_from")+" and e_sub_section.offering_sem="+
						WI.fillTextValue("offering_sem")+" and is_lec=0");
						
}
if(strSubSecIndex != null) {//get here subject section detail. 
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsCGH = strSchCode.startsWith("CGH");
if(strSchCode.startsWith("CLDH"))
	bolIsCGH = true; //force for CGH also.. 
	
	
String strRedFont = null;
boolean bolIsSACI = strSchCode.startsWith("UDMC");

//Get here the pending grade to be encoded list and list of grades encoded.
if(strSubSecIndex != null) {
	vRetResult = gsExtn.getStudListForGradeSheetEncoding(dbOP, WI.fillTextValue("grade_for"),strSubSecIndex,false, "", false);
	if(vRetResult == null)
		strErrMsg = gsExtn.getErrMsg();
	else {
		vEncodedGrade = (Vector)vRetResult.remove(0);
		vPendingGrade = (Vector)vRetResult.remove(0);
	}
}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=gsheet.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageAction(strAction)
{
	document.gsheet.page_action.value = strAction;
	if(strAction == 0)
		document.gsheet.hide_del.src = "../../../images/blank.gif";
	if(strAction == 1)
		document.gsheet.hide_save.src = "../../../images/blank.gif";
	
	ReloadPage();
}
function ReloadPage()
{
	document.gsheet.submit();
}

function focusID() {
	document.gsheet.emp_id.focus();
}
function PrintPg() {
	document.gsheet.print_pg.value = "1";
	this.ReloadPage();
}
function printGradeFinalSheet() {
	var pgLoc = "./grade_sheet_final_report.jsp?print_page=1&section_name="+escape(document.gsheet.section_name[document.gsheet.section_name.selectedIndex].value)+
	"&subject="+document.gsheet.subject[document.gsheet.subject.selectedIndex].value+"&sy_from="+document.gsheet.sy_from.value+"&sy_to="+
	document.gsheet.sy_to.value+"&offering_sem="+document.gsheet.offering_sem[document.gsheet.offering_sem.selectedIndex].value+"&recompute=1&emp_id="+
	document.gsheet.emp_id.value+"&separate_grades=1";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ViewGrade(strPmtSchIndex) {
	document.all.embed_grade.style.visibility = "visible";
	var strVar = "&section=<%=strSubSecIndex%>&emp=<%=strEmployeeIndex%>&pmt_sch="+strPmtSchIndex;
	
	var objCOAInput;
	objCOAInput = document.getElementById("load_grade");
		
	this.InitXmlHttpObject2(objCOAInput, 2, "<img src='../../../Ajax/ajax-loader_small_black.gif'>");//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=210&action="+strVar;
	this.processRequest(strURL);
}
function CloseDiv() {
	document.all.embed_grade.style.visibility = "hidden";
}
function AjaxOperation(strAction, strInfoIndex, strPmtSchIndex) {
	if(true)
		return;
	<%
	if(request.getParameter("page_action") == null){%>
		return;
	<%}%>
	
	strVar = "";
	if(strAction == '0')
		strVar = "&info_index="+strInfoIndex;
	strVar = "&section=<%=strSubSecIndex%>&emp=<%=strEmployeeIndex%>&pmt_sch="+strPmtSchIndex+strVar;
	
	var objCOAInput;
	objCOAInput = document.getElementById("ajax_gradeoth_verify");
		
	this.InitXmlHttpObject2(objCOAInput, 2, "<img src='../../../Ajax/ajax-loader_small_black.gif'>");//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=209&action="+strAction+strVar;
	this.processRequest(strURL);
} 

//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.gsheet.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	document.gsheet.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.gsheet.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>
<body bgcolor="#D2AE72" onLoad="focusID();AjaxOperation('5','null')">
<form name="gsheet" action="./grade_sheet_verify.jsp" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <input type="hidden" name="section" value="<%=WI.getStrValue(strSubSecIndex)%>">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="7"><div align="center"><font color="#FFFFFF"><strong>:::: 
          GRADE SHEETS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="1%" height="25" rowspan="6" >&nbsp;</td>
      <td width="25%" height="25" valign="bottom" >Grades for</td>
      <td width="22%" valign="bottom" >Term</td>
      <td width="27%" valign="bottom" >School Year</td>
      <td colspan="2" >&nbsp; </td>
      <td width="8%" >&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" valign="bottom" > <select name="grade_for">
 <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME",
	 " from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 and exam_name like 'final%' order by EXAM_PERIOD_ORDER asc", request.getParameter("grade_for"), false)%> 
        </select></td>
      <td valign="bottom" > <select name="offering_sem" onChange="ReloadPage();">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("offering_sem");
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
        </select></td>
      <td valign="bottom" > <%
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
	  readonly="yes"> </td>
      <td colspan="2" > <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>      </td>
      <td width="8%" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25" align="right">Employee ID &nbsp;&nbsp;&nbsp;</td>
      <td><input name="emp_id" type="text" size="16" 
	  	value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"></td>
      <td><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td colspan="2" >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
    <tr>
      <td height="25" align="right">&nbsp;</td>
      <td colspan="4"><label id="coa_info"></label></td>
      <td >&nbsp;</td>
    </tr>
  </table>
<%
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() >0){
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="1%"></td>
      <td width="39%" height="25" valign="bottom" >Section Handled</td>
      <td valign="bottom" >Instructor </td>
    </tr>
    <tr> 
      <td></td>
      <td height="25" > 
        <%
strTemp = " from e_sub_section join FACULTY_LOAD on (FACULTY_LOAD.sub_sec_index = e_sub_section.sub_sec_index)  where "+
			"faculty_load.is_valid = 1 and e_sub_section.is_valid = 1 and e_sub_section.OFFERING_SY_FROM ="+
			WI.fillTextValue("sy_from")+" and e_sub_section.OFFERING_SY_TO="+WI.fillTextValue("sy_to")+
			" and e_sub_section.OFFERING_SEM = "+WI.fillTextValue("offering_sem")+" and faculty_load.user_index = "+
			strEmployeeIndex;
%>
        <select name="section_name" onChange="document.gsheet.subject.selectedIndex=0;document.gsheet.submit();">
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
      <td>Subject Title </td>
    </tr>
    <tr> 
      <td width="1%"></td>
      <td height="25" > 
        <%
strTemp = " from faculty_load join e_sub_section on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) "+
			"join subject on (e_sub_section.sub_index = subject.sub_index) where faculty_load.user_index = "+
			strEmployeeIndex+" and e_sub_section.section = '"+WI.fillTextValue("section_name")+
			"' and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
			WI.fillTextValue("sy_from")+" and e_sub_section.offering_sy_to = "+WI.fillTextValue("sy_to")+
			" and e_sub_section.offering_sem="+WI.fillTextValue("offering_sem");
%>
        <select name="subject" onChange="ReloadPage();">
          <option value="">Select a subject</option>
          <%=dbOP.loadCombo("distinct subject.sub_index","sub_code",strTemp, request.getParameter("subject"), false)%> 
          <%}%>
        </select></td>
      <td> <strong> 
<%if(WI.fillTextValue("subject").length() > 0) {
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name"," and is_del=0");%>
        <%=WI.getStrValue(strTemp)%>
<%}%></strong></td>
    </tr>
  </table>
<%if(vSecDetail != null){%>
 <table width="100%" border="0" cellspacing="1" cellpadding="1" bgcolor="#FFFFFF">
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
<%
if(vPendingGrade != null && vPendingGrade.size() > 0){%>
	<tr>
	  <td colspan="5" style="font-size:14px; font-weight:bold; color:#FF0000;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Number of student without grade :: <%=vPendingGrade.size()/10%></td>
    </tr>
<%}
if(strSchCode.startsWith("PHILCST") && strSubSecIndex!= null && strEmployeeIndex != null && WI.fillTextValue("grade_for").length() > 0) {%>
	<tr>
	  <td colspan="5" style="font-size:14px; font-weight:bold; color:#FF0000;" align="center">
	  <table width="50%"><tr><td>
	  <div style="height:120;">
	  <label id="ajax_gradeoth_verify">
	  	<%//=WI.getStrValue(gsExtn.verifyGradeOthers(dbOP, 4, request, strSubSecIndex, strEmployeeIndex, WI.fillTextValue("grade_for")))%>
	  </label>
	  </div>
	  </td></tr></table>
	  </td>
	</tr>   
<%}//show verification of other grade.. %>
</table>		
<%}
 if(vEncodedGrade != null && vEncodedGrade.size() > 0){%> 
 <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="5"><div align="center">LIST OF STUDENTS WITH GRADE 
          ENCODED</div></td>
    </tr>
  </table>
 <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
<%if(true){%>	
	<tr>
	  <td height="25">
        <a href="javascript:printGradeFinalSheet();">View/Print Final Grade Sheet</a>
      </td>
	  <td height="25" align="right">
	  <%if(strSchCode.startsWith("WNU")){%>
		  <a href="javascript:recomputeFinalGrade();">Recompute Final Grade Sheet</a>
	  <%}%>
	  </td>
    </tr>
<%}if(iAccessLevel > 1 && gsExtn.bolIsGSDelAllowed(dbOP,null,strSubSecIndex) && !strSchCode.startsWith("SWU")){%>	
	<tr>
      <td height="25">&nbsp;</td>
      <td height="25" align="right"> 
	  	<a href="javascript:PageAction(1)"><img src="../../../images/verify.gif" border="0" name="hide_save"></a><font size="1">Click to VERIFY Final grade sheeta</font>
	  </td>
</tr>
<%}else if(iAccessLevel ==2){%>
    <tr>
      <td width="50%" style="font-size:9px;">
<%if(bolIsCGH || strSchCode.startsWith("CSA")){%>	  
	  Click to Print this page. <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
<%}%>	  </td>
      <td width="50%" height="25" align="right" style="font-size:9px;"> <a href="javascript:PageAction(0)">
	  <img src="../../../images/delete.gif" border="0" name="hide_del"></a>Click to Remove VERIFICATION of grade sheet</td>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="4%" class="thinborder"><font size="1"><strong>SL. #</strong></font></td> 
      <td width="15%"  height="25" class="thinborder"><div align="center"><font size="1"><strong>STUDENT ID </strong></font></div></td>
      <td width="25%" class="thinborder"><div align="center"><font size="1"><strong>STUDENT NAME </strong></font></div></td>
      <td width="24%" align="center" class="thinborder"><font size="1"><strong>COURSE</strong></font></td>
      <td width="4%" align="center" class="thinborder"><font size="1"><strong>YEAR</strong></font></td>
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>CREDIT EARNED</strong></font></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>GRADE</strong></font></td>
<%if(bolIsCGH){%>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>%ge GRADE</strong></font></td>
      <%}%>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>REMARKS</strong></font></td>
    </tr>
    <%
j = 0;
int iIndexOf = 0; String strCGHGrade = null;
for(int i=0; i<vEncodedGrade.size(); i += 9,++j){
	iIndexOf = gsExtn.vCGHGrade.indexOf(vEncodedGrade.elementAt(i));
	if(iIndexOf > -1) {
		strCGHGrade = (String)gsExtn.vCGHGrade.elementAt(iIndexOf + 1);
		gsExtn.vCGHGrade.removeElementAt(iIndexOf);gsExtn.vCGHGrade.removeElementAt(iIndexOf);
	}
	else	
		strCGHGrade = null;

//make red if inc or fail
strTemp = ((String)vEncodedGrade.elementAt(i+8)).toLowerCase();

if(bolIsSACI && (strTemp.startsWith("inc") || strTemp.startsWith("fail")) )
	strRedFont = " style='color:#FF0000'";
else	
	strRedFont = "";
		%>
    <tr>
      <td class="thinborder"<%=strRedFont%>><%=j + 1%>.</td> 
      <td height="25" class="thinborder"<%=strRedFont%>><font size="1"><%=(String)vEncodedGrade.elementAt(i+1)%></font> </td>
      <td class="thinborder"<%=strRedFont%>><font size="1"><%=(String)vEncodedGrade.elementAt(i+2)%></font></td>
      <td class="thinborder"<%=strRedFont%>><font size="1"><%=(String)vEncodedGrade.elementAt(i+3)%> 
        <% if(vEncodedGrade.elementAt(i + 4) != null){%>
        :: <%=(String)vEncodedGrade.elementAt(i+4)%> 
        <%}%>
        </font></td>
      <td align="center" class="thinborder"<%=strRedFont%>><font size="1"><%=WI.getStrValue(vEncodedGrade.elementAt(i+5),"N/A")%></font></td>
      <td align="center" class="thinborder"<%=strRedFont%>><font size="1">
	  <%strTemp = (String)vEncodedGrade.elementAt(i+6);
	  if(bolIsCGH && strTemp != null && strTemp.endsWith(".0"))
	  	strTemp = strTemp + "0";
	  %>
	  <%=strTemp%></font></td>
      <td align="center" class="thinborder"<%=strRedFont%>><font size="1">
	  	  <%
		  strTemp = (String)vEncodedGrade.elementAt(i+7);
		  iIndexOf = -1;
		  if(bolIsCGH && strTemp != null)
		  	iIndexOf = strTemp.indexOf(".");
		  if(iIndexOf > -1 && strTemp.substring(iIndexOf).length() == 2)
		  	strTemp = strTemp + "0";
	  %>
	  <%=WI.getStrValue(strTemp,"&nbsp;")%></font></td>
<%if(bolIsCGH){%>
      <td align="center" class="thinborder">&nbsp;<%=WI.getStrValue(strCGHGrade, "&nbsp;")%></td>
<%}%>
      <td align="center" class="thinborder"<%=strRedFont%>><font size="1"><%=(String)vEncodedGrade.elementAt(i+8)%></font></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="40%">&nbsp;</td>
      <td width="60%">&nbsp; </td>
    </tr>
</table>
<%}//end of showing encoded grade 
if(vPendingGrade != null && vPendingGrade.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="5" class="thinborder" align="center" style="font-size:13px; color:#FF0000; font-weight:bold"> List of students not having Grade encoded</td>
    </tr>
    <tr>
      <td width="5%" class="thinborder"><font size="1"><strong>SL. #</strong></font></td> 
      <td width="20%"  height="25" class="thinborder"><div align="center"><font size="1"><strong>STUDENT ID </strong></font></div></td>
      <td width="25%" class="thinborder"><div align="center"><font size="1"><strong>STUDENT NAME </strong></font></div></td>
      <td width="25%" align="center" class="thinborder"><font size="1"><strong>COURSE</strong></font></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>YEAR</strong></font></td>
    </tr>
<%for(int i = 0; i < vPendingGrade.size(); i += 10){%>
    <tr>
      <td class="thinborder"><%=i/10 + 1%>.</td>
      <td  height="25" class="thinborder"><%=vPendingGrade.elementAt(i + 3)%></td>
      <td class="thinborder"><%=vPendingGrade.elementAt(i + 4)%></td>
      <td align="center" class="thinborder"><%=(String)vPendingGrade.elementAt(i+5)%> 
        <%if(vPendingGrade.elementAt(i + 6) != null){%> :: <%=(String)vPendingGrade.elementAt(i+6)%><%}%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue(vPendingGrade.elementAt(i + 7), "N/A")%></td>
    </tr>
<%}%>
  </table>
<%}%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  
 <!---->
<div id="embed_grade" style="position:absolute; top:10px; left:10px; width:700px; height:450px; visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center bgcolor="#FFCCFF">
      <tr>
            <td align="right"><a href="javascript:CloseDiv();"> Close Window</a></td>
      </tr>
      <tr>
            <td align="center">
			<label id="load_grade">
			<!--<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			<img src="../../../Ajax/ajax-loader_big_black.gif">-->
			</label>
			</td>
      </tr>
</table></div>
<!---->

<input type="hidden" name="page_action">
<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
