<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="Javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function GoBack() {
	location = "./action_plan_org.jsp?organization_id="+
		escape(document.form_.organization_id.value)+"&performance=1";
}

function PrintPage(){
	document.form_.print_page.value = "1";
	document.form_.submit();
}

function PageAction(strInfoIndex,strAction) {
	document.form_.page_action.value = strAction;
	if(strAction == 1)
		document.form_.hide_save.src = "../../../images/blank.gif";
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value = "";
	document.form_.reload_page.value = "1";
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value = "";
	document.form_.reload_page.value = "1";
	document.form_.submit();
}
function Cancel() {
	document.form_.prepareToEdit.value = "0";
	document.form_.print_page.value = "";
	document.form_.submit();
}
function ReloadPage() {
	document.form_.reload_page.value = "1";
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	document.form_.submit();
}
function ClearEntries() {
	location = "./performance_report_update.jsp?sy_from="+escape(document.form_.sy_from.value)+
		"&sy_to="+escape(document.form_.sy_to.value)+"&organization_index="+
		escape(document.form_.organization_index.value)+"&organization_id="+
		escape(document.form_.organization_id.value);
}
function OpenSearch(strField) {
	//var pgLoc = "../search/srch_mem.jsp?opner_info=form_."+strField;
	var pgLoc = "../search/srch_mem.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.Organization"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	
	
	if(WI.fillTextValue("print_page").length() > 0){%>	
	<jsp:forward page="./performance_report_print.jsp"></jsp:forward>
<%	return;}

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-OSA - Organization","performance_report_update.jsp");
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
														"performance_report_update.jsp");
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
boolean bolRetainValue = false;//if it is true, use wi.fillTextValue(..);

String strOrgIndex = null;
Organization organization = new Organization();
Vector vRetResult = null;
Vector vEditInfo  = null;
String[] strHighestOfficer = null;

if(WI.fillTextValue("sy_from").length() > 0){
	vOrganizationDtl = organization.operateOnOrganization(dbOP, request,3);
	if(vOrganizationDtl == null)
		strErrMsg = organization.getErrMsg();
}
if(vOrganizationDtl != null) {
	//get president name,
	strOrgIndex = (String)vOrganizationDtl.elementAt(0);
}

if(vOrganizationDtl != null && WI.fillTextValue("sy_from").length() > 0) {
	//get president name,
	strHighestOfficer = organization.getHighestPossibleOfficer(dbOP, strOrgIndex, 
							WI.fillTextValue("sy_from"));
							
	if(strHighestOfficer == null)
		strErrMsg = organization.getErrMsg();
}

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(organization.operateOnPerformance(dbOP, request,Integer.parseInt(strTemp)) == null) {
		strErrMsg = organization.getErrMsg();
		bolRetainValue = true;
	}
	else {
		strPrepareToEdit = "0";
		strErrMsg = "Operation successful";
	}
}
if(strPrepareToEdit.compareTo("1") == 0){
	bolRetainValue = false;
	vEditInfo = organization.operateOnPerformance(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = organization.getErrMsg();
}
vRetResult = organization.operateOnPerformance(dbOP, request,4);

if(!bolRetainValue)
	if(WI.fillTextValue("reload_page").compareTo("1") == 0 || vEditInfo == null)
		bolRetainValue = true;
		
if(vEditInfo != null && vEditInfo.size() > 0)
	bolRetainValue = false;

%>
<body bgcolor="#D2AE72">
<form action="./performance_report_update.jsp" method="post" name="form_">

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>::::
          ORGANIZATIONS - PERFORMANCE REPORT - UPDATE PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%"><a href="javascript:GoBack();"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a>&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%" >School year</td>
      <td width="18%">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUP="DisplaySYTo('form_','sy_from','sy_to')">
        -
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">      </td>
      <td width="69%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td >&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>

<%
if(vOrganizationDtl != null && vOrganizationDtl.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="8%">&nbsp;</td>
      <td width="20%">Organization ID</td>
      <td width="72%"><strong><%=WI.fillTextValue("organization_id")%></strong></td>
    </tr>
     <tr>
      <td height="25">&nbsp;</td>
      <td >Organization Name</td>
      <td ><strong><%=(String)vOrganizationDtl.elementAt(2) %></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td ><% if (strHighestOfficer != null && strHighestOfficer[0] != null) {%>
		  	<%=strHighestOfficer[0]%> &nbsp;
	  	<%}%> 
	  </td>
      <td >
	<% if (strHighestOfficer != null && strHighestOfficer[1] != null) {%>
		  	<strong><%=strHighestOfficer[1]%></strong> &nbsp;
	  	<%}%> 	  
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Adviser</td>
      <td><strong>
	  <%if (vOrganizationDtl.elementAt(9)!=null){%>
	  <%=(String)vOrganizationDtl.elementAt(14)%><%} else {%>
	  <%=(String)vOrganizationDtl.elementAt(8)%><%}%></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<% if (strHighestOfficer != null) {%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="24">&nbsp;</td>
      <td height="24" width="25%" valign="top">Planned Activities</td>
      <td height="24" width="73%">
<%
if(bolRetainValue)
	strTemp = WI.fillTextValue("ACTIVITY_INDEX");
else
	strTemp = (String)vEditInfo.elementAt(1);
%>
        <select name="ACTIVITY_INDEX">
          <%
if(WI.fillTextValue("sy_from").length() > 0){%>
          <%=dbOP.loadCombo("distinct OSA_ORG_ACTION_PLAN.ACTIVITY_INDEX","ACTIVITY_NAME",
		  	" FROM OSA_ORG_ACTION_PLAN join OSA_PRELOAD_ORG_ACTIVITY on (OSA_PRELOAD_ORG_ACTIVITY.activity_index= "+
			"OSA_ORG_ACTION_PLAN.activity_index) where OSA_ORG_ACTION_PLAN.is_valid = 1  and OSA_ORG_ACTION_PLAN.organization_index = "+strOrgIndex+
			" and OSA_ORG_ACTION_PLAN.sy_from="+WI.fillTextValue("sy_from")+" order by ACTIVITY_NAME ",strTemp,false)%>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td valign="top">Accomplishment to Date</td>
      <td >
<%
if(bolRetainValue)
	strTemp = WI.fillTextValue("ACCOMPLISHMENT");
else
	strTemp = (String)vEditInfo.elementAt(3);
%>
        <textarea name="ACCOMPLISHMENT" cols="50" rows="2" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td valign="middle">Percentage Profile</td>
      <td valign="middle">
<%
if(bolRetainValue)
	strTemp = WI.fillTextValue("PERCENT_PROFILE");
else
	strTemp = (String)vEditInfo.elementAt(4);
%>
        <font size="1"><strong>
        <input name="PERCENT_PROFILE" type="text" size="6" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        </strong></font></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td valign="top">Problems Encountered</td>
      <td >
<%
if(bolRetainValue)
	strTemp = WI.fillTextValue("PROBLEMS");
else
	strTemp = (String)vEditInfo.elementAt(5);
%>
        <textarea name="PROBLEMS" cols="50" rows="2" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td valign="top">Action Taken</td>
      <td >
<%
if(bolRetainValue)
	strTemp = WI.fillTextValue("ACTION_TAKEN");
else
	strTemp = (String)vEditInfo.elementAt(6);
%>
        <textarea name="ACTION_TAKEN" cols="50" rows="2" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td valign="top">Projection</td>
      <td >
<%
if(bolRetainValue)
	strTemp = WI.fillTextValue("PROJECTION");
else
	strTemp = (String)vEditInfo.elementAt(7);
%>
        <textarea name="PROJECTION" cols="50" rows="2" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td valign="top">Evaluation</td>
      <td >
<%
if(bolRetainValue)
	strTemp = WI.fillTextValue("EVALUATION");
else
	strTemp = (String)vEditInfo.elementAt(8);
%>
        <textarea name="EVALUATION" cols="50" rows="2" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
      <tr>
        <td height="23">&nbsp;</td>
        <td valign="bottom" colspan="4">Approved by:</td>
      </tr>
      <tr>
        <td height="23" width="6%">&nbsp;</td>
        <td width="12%" height="23">&nbsp;</td>
        <td height="23" width="23%">ID :
          <%
if(bolRetainValue)
	strTemp = WI.fillTextValue("APPROVED_BY");
else
	strTemp = (String)vEditInfo.elementAt(9);
%>
            <input name="APPROVED_BY" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=strTemp%>" size="16">
        </td>
        <td width="5%"><a href="javascript:OpenSearch('APPROVED_BY');"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
        <td width="54%"><%
if(!bolRetainValue){%>
Position : <%=(String)vEditInfo.elementAt(11)%>
<%}%></td>
      </tr>
      <tr>
        <td height="23">&nbsp;</td>
        <td colspan="4" valign="bottom">Prepared by:</td>
      </tr>
      <tr>
        <td height="23">&nbsp;</td>
        <td >&nbsp;</td>
        <td >ID :
          <%
if(bolRetainValue)
	strTemp = WI.fillTextValue("PREPARED_BY");
else
	strTemp = (String)vEditInfo.elementAt(10);
%>
            <input name="PREPARED_BY" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=strTemp%>" size="16">
          </td>
        <td height="23"><a href="javascript:OpenSearch('PREPARED_BY');"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
        <td height="23"><%
if(!bolRetainValue){%>
Position : <%=(String)vEditInfo.elementAt(12)%>
<%}%></td>
      </tr>
      <tr>
        <td height="10">&nbsp;</td>
        <td>&nbsp;</td>
        <td colspan="3">&nbsp;</td>
      </tr>
    </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="5%" height="25"><div align="center">
          <div align="center">
            <%if(iAccessLevel > 1){
	if(strPrepareToEdit.compareTo("0")  == 0){%>
            <a href='javascript:PageAction("","1");'> <img src="../../../images/save.gif" border="0" name="hide_save"></a><font size="1">click
            to save &nbsp;&nbsp;&nbsp; <a href="javascript:ClearEntries();"><img src="../../../images/clear.gif" border="0"></a>
            <%}else{%>
            <a href='javascript:PageAction("","2");'> <img src="../../../images/edit.gif" border="0" name="hide_save"></a>click
            to edit &nbsp;&nbsp; </font> <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a>
            <font size="1">click to cancel </font>
            <%}
    }%>
          </div>
        </div></td>
    </tr>
  </table>
<%}//only if organization detail is not null//
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td><div align="right"><font size="1"><a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0" ></a>click
          to print action plan</font></div></td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="9"><div align="center"><font color="#FFFFFF"><strong>PERFORMANCE
          REPORT FOR SCHOOL YEAR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></font></div></td>
    </tr>
    <tr>
      <td width="13%" height="27" ><div align="center"><font size="1"><strong>PLANNED
          ACTIVITIES </strong></font></div></td>
      <td width="21%" height="27"><div align="center"><font size="1"><strong>ACCOMPLISHMENT
          TO DATE</strong></font></div></td>
      <td width="6%" height="27"><div align="center"><font size="1"><strong>%
          PROFILE </strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>PROBLEMS ENCOUNTERED</strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>ACTION TAKEN
          </strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>PROJECTION</strong></font></div></td>
      <td width="12%"><div align="center"><font size="1"><strong>EVALUATION</strong></font></div></td>
      <td width="4%"><strong><font size="1">DELETE</font></strong></td>
      <td width="4%"><div align="center"><font size="1"><strong>EDIT</strong>&nbsp;</font></div></td>
    </tr>
    <%
for(int i = 0 ; i < vRetResult.size(); i += 13){%>
    <tr>
      <td height="25"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td><%=(String)vRetResult.elementAt(i + 7)%></td>
      <td><%=(String)vRetResult.elementAt(i + 8)%></td>
      <td><%if(iAccessLevel == 2){%>
	  <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'>
	  	<img src="../../../images/delete.gif" border="0"></a><%}%></td>
      <td><%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'>
	  		<img src="../../../images/edit.gif" border="0"></a><%}%></td>
    </tr>
    <%}%>
  </table>
<%}
 } // show onli if highest officer is available
%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="organization_index" value="<%=strOrgIndex%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="reload_page">
<input type="hidden" value="<%=WI.fillTextValue("organization_id")%>" name="organization_id">
<input type="hidden" name="print_page" value="">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
