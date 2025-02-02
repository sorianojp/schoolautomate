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
								"Admin/staff-Registrar Management-GRADES-Grade Verify","grade_sheet_verify_wup.jsp");
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
Vector vEmployeeInfo       = new Vector();

String strSQLQuery = null;
java.sql.ResultSet rs  = null;
String strEmployeeID = WI.fillTextValue("emp_id");
if(strEmployeeID.length() > 0) {
	strSQLQuery = "select fname, mname, lname, c_code, c_name,d_code, d_name, user_table.user_index from info_faculty_basic "+
		"join user_table on (user_table.user_index = info_faculty_basic.user_index) "+
		"left join college on (college.c_index = info_faculty_basic.c_index) "+
		"left join department on (department.d_index = info_faculty_basic.d_index) where id_number = '"+
		strEmployeeID+"' ";
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		vEmployeeInfo.addElement(WebInterface.formatName(rs.getString(1), rs.getString(2), rs.getString(3), 4));
		if(rs.getString(4) == null)
			vEmployeeInfo.addElement(rs.getString(7));
		else
			vEmployeeInfo.addElement(rs.getString(5));
			
		strEmployeeIndex = rs.getString(8);
	}
	rs.close();
}
Vector vRetResult = null;
boolean bolIsDean = false; //if having college in profile : dean, else => Registrar.

strTemp = WI.fillTextValue("unsubmit_gs");

if(strTemp.length() > 0) {//unsubmit called by dean.. 
	strTemp = "update faculty_load set date_submitted_wup_removed_date = '"+WI.getTodaysDate()+"', date_submitted_wup_removed_by = "+
		(String)request.getSession(false).getAttribute("userIndex")+",date_submitted_wup = null,date_submitted_wup_old =date_submitted_wup  where load_index = "+strTemp;
	dbOP.executeUpdateWithTrans(strTemp, "FACULTY_LOAD", (String)request.getSession(false).getAttribute("login_log_index"), true);
}

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	gsExtn.verifyGradeSheetWUP(dbOP, request, Integer.parseInt(strTemp));
	strErrMsg = gsExtn.getErrMsg();
}
//get here employee load information.
if(strEmployeeIndex != null) {
	vRetResult = gsExtn.getGradeToVerifyWUP(dbOP, request, strEmployeeIndex);
	if(vRetResult == null && strErrMsg != null)
		strErrMsg = gsExtn.getErrMsg();
	else if(vRetResult != null){
		bolIsDean = ((Boolean)vRetResult.remove(0)).booleanValue();
	}
	
	if(vRetResult == null)
		vRetResult = new Vector();
}
String strSubSecIndex = null;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
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
function ReloadPage(){
	document.gsheet.unsubmit_gs.value = '';
	document.gsheet.submit();
}

function focusID() {
	document.gsheet.emp_id.focus();
}
function FinalizeGS(strAction) {
	document.gsheet.page_action.value = strAction;
	document.gsheet.unsubmit_gs.value = '';
	this.ReloadPage();
}
function showGradeSheetFinalReport(strSection,strSubject) {
	var pgLoc = "./grade_sheet_final_report_print_wup.jsp?donot_print=1&section_name="+escape(strSection)+
	"&subject="+strSubject+"&sy_from="+document.gsheet.sy_from.value+"&sy_to="+
	document.gsheet.sy_to.value+"&offering_sem="+document.gsheet.offering_sem[document.gsheet.offering_sem.selectedIndex].value+"&emp_id="+
	document.gsheet.emp_id.value;
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
/**
* Unsumiit called by dean.
*/
function UnSubmitGS(strLoadIndex) {
	document.gsheet.unsubmit_gs.value = strLoadIndex;
	document.gsheet.page_action.value = '';

	document.gsheet.submit();
}



function CloseDiv() {
	document.all.embed_grade.style.visibility = "hidden";
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
<body bgcolor="#D2AE72" onLoad="focusID();">
<form name="gsheet" action="./grade_sheet_verify_wup.jsp" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="7"><div align="center"><font color="#FFFFFF"><strong>:::: 
          GRADE SHEETS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="7" style="font-weight:bold; font-size:14px;">&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
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
<%if(vEmployeeInfo != null && vEmployeeInfo.size() > 0) {%>
 <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="10%"><img src="../../../upload_img/<%=WI.fillTextValue("emp_id")%>.jpg" width="125" height="125" border="1"></td>
      <td width="2%">&nbsp;</td>
      <td valign="top">
	  	<table width="100%" cellpadding="0" cellspacing="0">
			<tr>
				<td colspan="2" style="font-size:24px; font-weight:bold" class="thinborderBOTTOM"><%=vEmployeeInfo.elementAt(0)%></td>
			</tr>
			<tr>
				<td width="10%" style="font-size:11px;">Department: </td>
				<td style="font-size:11px;"><%=vEmployeeInfo.elementAt(1)%></td>
			</tr>
			<tr>
				<td colspan="2" style="font-weight:bold; font-size:11px;">Assigned Schedule: <%=vRetResult.size()/13%></td>
			</tr>
		</table>
	  </td>
    </tr>
  </table>
<%}if(vRetResult != null && vRetResult.size() > 0) {%>
 <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="5"><div align="center">LIST OF LOAD SCHEDULE</div></td>
    </tr>
  </table>
 <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center">
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>Unlock</strong></font></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>Verify</strong></font></td>
      <td width="13%"  height="25" class="thinborder"><strong><font size="1">Section</font></strong></td>
      <td width="10%" class="thinborder"><strong><font size="1">Subject Code </font></strong></td>
      <td width="25%" align="center" class="thinborder"><font size="1"><strong>Subject Name </strong></font></td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">Load Unit </font></strong></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>Status</strong></font></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>Receive</strong></font></td>
    </tr>
	<%
	String strStatus = null;
	boolean bolAuthorized = false;
	int iCount = 0;
	
	boolean bolShowButtonV = false;
	boolean bolShowButtonR = false;
	
	
	for(int i = 0; i < vRetResult.size(); i += 13) {
		if(vRetResult.elementAt(i + 7) == null)
			strStatus = "Unedited";
		else	
			strStatus = "Submitted";
			
		if(vRetResult.elementAt(i + 6) != null)
			strStatus = "Approved";
		if(vRetResult.elementAt(i + 9) != null)
			strStatus += " and Received";
		
		if(vRetResult.elementAt(i + 10).equals("1"))
			bolAuthorized = true;
		else	
			bolAuthorized = false;
	%>
		<tr <%if(bolAuthorized){%>onDblClick="showGradeSheetFinalReport('<%=vRetResult.elementAt(i + 1)%>','<%=vRetResult.elementAt(i + 11)%>');"<%}else{%> bgcolor="#DDDDDD"<%}%>>
		  <td class="thinborder" align="center">
		  <%if(!bolAuthorized){%>
		  	N/A
		  <%}else if(vRetResult.elementAt(i + 7) == null) {//not submitted%>
		  	N/A
		  <%}else if(vRetResult.elementAt(i + 6) != null) {//already verified%>
		  	<%=ConversionTable.convertMMDDYYYY((java.util.Date)vRetResult.elementAt(i + 6))%>
		  <%}else if(!bolIsDean){//not dean,, so can't verify%>
		  	N/A
		  <%}else{bolShowButtonV = true;%>		  
		  	<input type="button" name="_" value=" Unlock " onClick="UnSubmitGS('<%=vRetResult.elementAt(i + 12)%>');"style="font-size:11px; height:25px; width:60px; border: 1px solid #FF0000;">
		  <%}%>
		  </td>
		  <td class="thinborder" align="center">
		  <%if(!bolAuthorized){%>
		  	N/A
		  <%}else if(vRetResult.elementAt(i + 7) == null) {//not submitted%>
		  	N/A
		  <%}else if(vRetResult.elementAt(i + 6) != null) {//already verified%>
		  	<%=ConversionTable.convertMMDDYYYY((java.util.Date)vRetResult.elementAt(i + 6))%>
		  <%}else if(!bolIsDean){//not dean,, so can't verify%>
		  	N/A
		  <%}else{bolShowButtonV = true;%>		  
			  <input type="checkbox" value="<%=vRetResult.elementAt(i + 12)%>" name="_v<%=iCount%>">
		  <%}%>		  </td>
		  <td  height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
		  <td class="thinborder"><%=strStatus%></td>
		  <td class="thinborder" align="center">
		  <%if(vRetResult.elementAt(i + 7) == null) {//not submitted%>
		  	N/A
		  <%}else if(vRetResult.elementAt(i + 6) == null) {//not verified%>
		  	N/A
		  <%}else if(bolIsDean){//not dean,, so can't verify%>
		  	N/A
		  <%}else if(vRetResult.elementAt(i + 9) != null) {//already received%>
		  	<%=ConversionTable.convertMMDDYYYY((java.util.Date)vRetResult.elementAt(i + 9))%>
		  <%}else{bolShowButtonR = true;%>		  
			  <input type="checkbox" value="<%=vRetResult.elementAt(i + 12)%>" name="_r<%=iCount%>">
		  <%}%>		  </td>
		</tr>
	<%++iCount;}%>
	<input type="hidden" name="max_disp" value="<%=iCount%>">
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="40%">
		<%if(bolShowButtonV){%>
	  		<input type="button" name="_" value="<<< Verify Grade Sheet >>>" onClick="FinalizeGS('0');"style="font-size:11px; height:30px; width:160px; border: 1px solid #FF0000;">
		<%}%>
	  </td>
      <td width="60%" align="right">
		<%if(bolShowButtonR){%>
		  	<input type="button" name="_2" value="<<< Receive Grade Sheet >>>" onClick="FinalizeGS('1');"style="font-size:11px; height:30px; width:180px; border: 1px solid #FF0000;">
		<%}%>
	  </td>
    </tr>
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
<input type="hidden" name="unsubmit_gs">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
