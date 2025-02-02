<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.ReportRegistrar, enrollment.FAPaymentUtil,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strSYFrom = WI.fillTextValue("sy_from");
	if(strSYFrom.length() == 0)
		strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	
	String strSYTo   = WI.fillTextValue("sy_to");
	if(strSYTo.length() == 0)
		strSYTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	
	String strSemester = (String)request.getSession(false).getAttribute("cur_sem");

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/common.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	document.form_.print_page.value="";
	document.form_.submit();
}

function PrintPg(){
		document.form_.print_page.value="1";
		document.form_.submit();
}
function focusID() {
	document.form_.stud_id.focus();
}
function ChangeFontSize() {
	var vFontSize = document.form_.font_size[document.form_.font_size.selectedIndex].value;
	eval('document.form_.font_size_test.style.fontSize = '+vFontSize);
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
	document.form_.print_page.value="";
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
<body bgcolor="#D2AE72" onLoad="focusID();">
<%
	String strErrMsg = null;
	String strTemp = null;
	String strPrintPage = "";
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null) 
		strSchCode = "";

//add security here.
	 if(WI.fillTextValue("print_page").compareTo("1") == 0) {
	%>
		<jsp:forward page="./student_permanent_record_print_cdd.jsp" />
	<%return;
	} // if printPage = 1
	try
	{
		dbOP = new DBOperation();
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
									"Registrar Management","GRADES-Grade Certification",request.getRemoteAddr(),
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

GradeSystem GS = new GradeSystem();
FAPaymentUtil pmtUtil = new FAPaymentUtil();
Vector vRetResult  = null;

//get student information first before getting grade details.
Vector vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
Vector vGradeDetail = null;
if(vStudInfo == null)
	strErrMsg = pmtUtil.getErrMsg();

%>

<form name="form_" action="./student_permanent_record_print_cdd_main.jsp" method="post">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center"><font color="#FFFFFF"><strong>:::: 
        STUDENT PERMANENT RECORD ::::</strong></font></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" colspan="4" >&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="19%" height="25" >Student ID: &nbsp;</td>
      <td width="26%" >
        <input name="stud_id" type="text" id="stud_id" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxMapName('1');">      </td>
      <td width="11%" ><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td width="42%" ><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute; width:400px"></label></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >SY-Term</td>
      <td colspan="3" >
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strSYTo%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
	  - 
	          <select name="semester">
          <option value="1">1st Semester</option>
          <%
strTemp = request.getParameter("semester");
if(strTemp == null) {
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	if(strTemp == null)
		strTemp = "";
}
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Semester</option>
          <%}else{%>
          <option value="2">2nd Semester</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Semester</option>
          <%}else{%>
          <option value="3">3rd Semester</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
      </select>	  </td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >Grade Period </td>
      <td colspan="3" >
	  
	    <select name="grade_for">
          <%=dbOP.loadCombo("EXAM_NAME","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 and exam_name like 'final%' order by exam_period_order", request.getParameter("grade_for"), false)%>
        </select> 
		
		</td>
    </tr>
    <tr>
      <td colspan="5" height="25" >
	  
	  <hr size="1"></td>
    </tr>
  </table>
<% if(vStudInfo != null && vStudInfo.size() > 0){%>
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
      <td width="98%" height="25" >Year : <strong><%=(String)vStudInfo.elementAt(4)%></strong></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25" align="center"><input type="button" name="_" value="Print SPR" onClick="document.form_.print_page.value='1';document.form_.submit();"></td>
    </tr>
  </table>
  <%
} // if vStudinfo == null%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="5" height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="5" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
</table>
<input type="hidden" name="print_page" value="<%=strPrintPage%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
