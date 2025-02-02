<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">


var objCOA;
var objCOAInput;
function AjaxMapName() {
	var strIDNumber = document.form_.EVALUATION_PREP_BY.value;
	objCOAInput = document.getElementById("coa_info");
	
	eval('objCOA=document.form_.EVALUATION_PREP_BY');
	if(strIDNumber.length < 3) {
		objCOAInput.innerHTML = "";
		return ;
	}
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strIDNumber);
	
	this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	objCOA.value = strID;
	//objCOAInput.innerHTML = "";	
	this.AjaxMapName();
}

function UpdateName(strFName, strMName, strLName) {
		//do nothing.
}

function UpdateNameFormat(strName) {
	//do nothing.
}


function Cancel() {
	location = "./year_end_report.jsp?";
}
function ReloadPage() {
	document.form_.print_page.value = "";
	document.form_.page_action.value = "";
	document.form_.submit();
}
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	document.form_.print_page.value = "";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function FocusID() {
	document.form_.organization_id.focus();
}
function OpenSearch() {
	var pgLoc = "../search/srch_org.jsp?opner_info=form_.organization_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearch2() {
	var pgLoc = "../search/srch_mem.jsp?opner_info=form_.EVALUATION_PREP_BY";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPage() {
	document.form_.print_page.value = "1";
	document.form_.submit();
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.Organization"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	if(WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./year_end_report_print.jsp"></jsp:forward>
	<%return;}

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-OSA - Organization","year_end_report.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs",
														"ORGANIZATIONS",request.getRemoteAddr(),
														"year_end_report.jsp");
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
Vector vOrganizationDtl = null;
boolean bolNoRecord = false;//if it is true, it is having yearly report, activate EDIT.

String strOrgIndex = null;
Organization organization = new Organization();
Vector vRetResult = null;
Vector vActivityInfo = null;//there should be activity information to record yearly report.

if(WI.fillTextValue("organization_id").length() > 0 && WI.fillTextValue("sy_from").length() > 0){
	vOrganizationDtl = organization.operateOnOrganization(dbOP, request,3);
	if(vOrganizationDtl == null)
		strErrMsg = organization.getErrMsg();
	else
	{
		strOrgIndex = (String)vOrganizationDtl.elementAt(0);
		if(WI.fillTextValue("organization_index").length() ==0) 
			request.setAttribute("organization_index",strOrgIndex);
	}
}

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(organization.operateOnYrEndReport(dbOP, request,Integer.parseInt(strTemp)) == null)
		strErrMsg = organization.getErrMsg();
	else {
		strErrMsg = "Operation successful";
	}
}
if(WI.fillTextValue("sy_from").length() > 0 && strOrgIndex != null) {
	
	vRetResult = organization.operateOnYrEndReport(dbOP, request,4);
	if(vRetResult == null)
		strErrMsg = organization.getErrMsg();
		

}
if(vRetResult == null || vRetResult.size() ==0)
	bolNoRecord = true;

if(vOrganizationDtl != null && vOrganizationDtl.size() > 0){
	vActivityInfo = organization.operateOnActivity(dbOP, request,4);
}
%>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<form action="./year_end_report.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>::::
          ORGANIZATIONS - YEAR-END REPORT PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%" >Organization ID</td>
      <td width="18%"> <input name="organization_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=WI.fillTextValue("organization_id")%>" size="16"></td>
      <td width="6%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="58%"><input name="image" type="image" src="../../../images/form_proceed.gif"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >School Year</td>
      <td colspan="3">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
  </table>
<%
if(vOrganizationDtl != null && vOrganizationDtl.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="48%" height="25">Organization name : <strong><%=(String)vOrganizationDtl.elementAt(2)%></strong></td>
      <td width="50%" height="25">Date accredited: <strong><%=(String)vOrganizationDtl.elementAt(3)%></strong></td>
    </tr>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">College/Department : <strong><%=WI.getStrValue(vOrganizationDtl.elementAt(5))%><%=WI.getStrValue((String)vOrganizationDtl.elementAt(7),"/","","")%></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="3"><div align="right"><font size="1"><font size="1"><a href="activities_view_all.htm"><img src="../../../images/view.gif" width="40" height="31" border="0"></a>c<font size="1">lick
          to view other activities of the organization</font></font></font></div></td>
    </tr> -->
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%}//only if organization information is correct.
if(WI.fillTextValue("sy_from").length() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td colspan="3">I - PROJECT AND ACTIVITIES UNDERTAKEN DURING THE YEAR <font size="1">(separate
        each entry by pressing enter)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3">
	  <%
	  if(!bolNoRecord){%><table class="thinborderALL" width="70%" border="0" cellpadding="0" cellspacing="0">
	  <tr><td><%=(String)vRetResult.elementAt(9)%></td></tr></table><%}%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3">II - EVALUATION (impact on members, school and community)
        <font size="1">(separate each entry by pressing enter)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3">
<%
if(bolNoRecord)
	strTemp = WI.fillTextValue("EVALUATION");
else
	strTemp = (String)vRetResult.elementAt(1);
%>
	  <textarea name="EVALUATION" cols="65" rows="4" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3">III - DIFFICULTIES &amp; PROBLEMS <font size="1">(separate
        each entry by pressing enter)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3">
<%
if(bolNoRecord)
	strTemp = WI.fillTextValue("DIFFICULTIES");
else
	strTemp = (String)vRetResult.elementAt(2);
%>	  <textarea name="DIFFICULTIES" cols="65" rows="4" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3">IV - SOME SUGGESTIONS TO IMPROVE THE ORGANIZATION <font size="1">(separate
        each entry by pressing enter)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">
<%
if(bolNoRecord)
	strTemp = WI.fillTextValue("SUGGESTIONS");
else
	strTemp = (String)vRetResult.elementAt(3);
%>	  <textarea name="SUGGESTIONS" cols="65" rows="4" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">V - FINANCIAL STATUS :
<%
if(bolNoRecord)
	strTemp = WI.fillTextValue("FINANCIAL_STAT");
else
	strTemp = (String)vRetResult.elementAt(4);
%>        <input name="FINANCIAL_STAT" type="text" size="50" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=strTemp%>"></td>
    </tr>
    <tr>
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Evaluation prepared by:</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="3%" height="25">&nbsp;</td>
      <td width="10%">ID : </td>
      <td width="82%">
<%
if(bolNoRecord)
	strTemp = WI.fillTextValue("EVALUATION_PREP_BY");
else
	strTemp = (String)vRetResult.elementAt(5);
%>	  <input name="EVALUATION_PREP_BY" size="12" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=strTemp%>"  onKeyUp="AjaxMapName();">
	  	<a href="javascript:OpenSearch2();"><img src="../../../images/search.gif" width="22" height="20" border="0"></a>
		&nbsp; <label id="coa_info" style="width:300px; position:absolute"></label>
	  	</td>
    </tr>
<%
if(!bolNoRecord){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>Position : </td>
      <td><%=WI.getStrValue(vRetResult.elementAt(7),"Not a member")%></td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>Date :</td>
      <td><font size="1">
        <%
if(bolNoRecord)
	strTemp = WI.fillTextValue("DATE_PREPARED");
else
	strTemp = (String)vRetResult.elementAt(6);
%>
        <input name="DATE_PREPARED" type="text" value="<%=strTemp%>" size="15" readonly="true" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
        <a href="javascript:show_calendar('form_.DATE_PREPARED');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="25%" height="25"><div align="center">
                <% if (iAccessLevel > 1){
	if(bolNoRecord) {%>
                <a href="javascript:PageAction(1);">
				<img src="../../../images/save.gif" border="0" name="hide_save"></a>
                <font size="1">click to save entries&nbsp;<a href='javascript:Cancel();'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
                to cancel and clear entries</font></font>
                <%}else{%>
                <a href="javascript:PageAction(2);"><img src="../../../images/edit.gif" border="0" name="hide_save"></a>
                <font size="1">click to save changes</font>
				
				<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0" name="hide_save"></a>
                <font size="1">click to print report</font>
<%}}%>
	  </div></td>
    </tr>
  </table>

<%}//WI.fillTextValue("sy_from").length() > 0
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="print_page">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
