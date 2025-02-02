<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.Organization"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function GoBack() {
	location = "./action_plan_org.jsp?organization_id="+
		escape(document.form_.organization_id.value);
}
function PageAction(strInfoIndex,strAction) {
	document.form_.print_pg.value = "";
	document.form_.page_action.value = strAction;
	if(strAction == 1)
		document.form_.hide_save.src = "../../../images/blank.gif";
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.print_pg.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function Cancel() {
	document.form_.print_pg.value = "";
	document.form_.prepareToEdit.value = "0";
	document.form_.submit();
}
function ReloadPage() {
	document.form_.print_pg.value = "";
	document.form_.reload_page.value = "1";
	document.form_.page_action.value = "";
	document.form_.submit();
}
function viewList(table,indexname,colname,labelname){
	document.form_.print_pg.value = "";
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname +
	"&colname=" + colname+"&label="+labelname+"&opner_form_name=form_";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ClearEntries() {
	location = "./action_plan_org_update.jsp?sy_from="+escape(document.form_.sy_from.value)+
		"&sy_to="+escape(document.form_.sy_to.value)+"&organization_index="+
		escape(document.form_.organization_index.value)+"&organization_id="+
		escape(document.form_.organization_id.value);

}
function OpenSearch() {
	var pgLoc = "../search/srch_mem.jsp?opner_info=form_.PERSON_IN_CHARGE&org_index=" +
	document.form_.organization_index.value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	document.form_.print_pg.value = "";
	win.focus();
}
function PrintPage(){
	document.form_.print_pg.value = "1";
	this.SubmitOnce("form_");
}
</script>
<%
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./action_plan_org_list_print.jsp" />
	<%}
	
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-OSA - Organization","aciton_plan_org_update.jsp");
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
														"action_plan_org_update.jsp");
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
String strPresidentName = null;//get the president of organization.
Organization organization = new Organization();
Vector vRetResult = null;
Vector vEditInfo  = null;
String[] strHighestOfficer = null;

//if(WI.fillTextValue("sy_from").length() > 0){
	vOrganizationDtl = organization.operateOnOrganization(dbOP, request,4);
	if(vOrganizationDtl == null)
		strErrMsg = organization.getErrMsg();
	else 
		strOrgIndex = (String)vOrganizationDtl.elementAt(0);
	
//}
if(vOrganizationDtl != null && WI.fillTextValue("sy_from").length() > 0) {
	//get president name,
	strHighestOfficer = organization.getHighestPossibleOfficer(dbOP, strOrgIndex, 
							WI.fillTextValue("sy_from"));
	if(strHighestOfficer == null)
		strErrMsg = organization.getErrMsg();
}
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(organization.operateOnActionPlan(dbOP, request, Integer.parseInt(strTemp)) != null ) 
			{
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
			}
		else
			strErrMsg = organization.getErrMsg();
}
if(strPrepareToEdit.compareTo("1") == 0){
	vEditInfo = organization.operateOnActionPlan(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = organization.getErrMsg();
}

vRetResult = organization.operateOnActionPlan(dbOP, request,4);

if(WI.fillTextValue("reload_page").compareTo("1") == 0 || vEditInfo == null)
	bolRetainValue = true;


%>
<body bgcolor="#D2AE72">
<form action="./action_plan_org_update.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>::::
          ORGANIZATIONS - ACTION PLAN - UPDATE PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td width="5%" height="25">&nbsp;</td>
      <td width="95%"><a href="javascript:GoBack();"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a>
	  &nbsp;&nbsp;&nbsp; <font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td width="15%" >School year</td>
      <td width="17%"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUP="DisplaySYTo('form_','sy_from','sy_to')">
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
      </td>
      <td width="63%"><a href="javascript:ReloadPage();">
	  	<img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%
if(vOrganizationDtl != null && vOrganizationDtl.size() > 0 && WI.fillTextValue("sy_from").length() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="5%">&nbsp;</td>
      <td width="23%">Organization ID</td>
      <td width="72%"><strong><%=WI.fillTextValue("organization_id")%></strong></td>
    </tr>
     <tr>
      <td height="25">&nbsp;</td>
      <td >Organization Name</td>
      <td ><strong><%=(String)vOrganizationDtl.elementAt(2)%></strong></td>
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
	  <%=WI.getStrValue((String)vOrganizationDtl.elementAt(14))%><%} else {%>
	  <%=WI.getStrValue((String)vOrganizationDtl.elementAt(8))%><%}%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>ADD/EDIT
          ACTION PLAN FOR SCHOOL YEAR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></font> </div></td>
    </tr>
    <tr>
      <td width="4%" height="24">&nbsp;</td>
      <td width="22%" height="24">Date Submitted</td>
      <td colspan="2"><font size="1">
<%
if(bolRetainValue)
	strTemp = WI.fillTextValue("DATE_SUBMITTED");
else
	strTemp = (String)vEditInfo.elementAt(3);
%>        <input name="DATE_SUBMITTED" type="text" value="<%=strTemp%>" size="15" readonly="true" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
        <a href="javascript:show_calendar('form_.DATE_SUBMITTED');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        </font></td>
    </tr>
    <tr>
      <td height="24" colspan="4"><hr size="1"></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24" valign="top">Objectives</td>
      <td height="24" colspan="2">
<%
if(bolRetainValue)
	strTemp = WI.fillTextValue("OBJECTIVE");
else
	strTemp = (String)vEditInfo.elementAt(4);
%>	  <textarea name="OBJECTIVE" cols="50" rows="2" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24" valign="top">Key Result Area</td>
      <td height="24" colspan="2">
<%
if(bolRetainValue)
	strTemp = WI.fillTextValue("KEY_RESULT_AREA");
else
	strTemp = (String)vEditInfo.elementAt(5);
%>
	  <textarea name="KEY_RESULT_AREA" cols="50" rows="2" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24">Activities</td>
      <td height="24" colspan="2">
<%
if(bolRetainValue)
	strTemp = WI.fillTextValue("ACTIVITY_INDEX");
else
	strTemp = (String)vEditInfo.elementAt(2);
%>
	  <select name="ACTIVITY_INDEX">
          <%=dbOP.loadCombo("ACTIVITY_INDEX","ACTIVITY_NAME"," FROM OSA_PRELOAD_ORG_ACTIVITY order by ACTIVITY_NAME",strTemp,false)%>
        </select>
        <strong>
		<a href='javascript:viewList("OSA_PRELOAD_ORG_ACTIVITY","ACTIVITY_INDEX","ACTIVITY_NAME",
						"ACTIVITY TYPE")'><img src="../../../images/update.gif" border="0">
		</a></strong>      </td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24" valign="top">Performance Indicator</td>
      <td height="24" colspan="2">
<%
if(bolRetainValue)
	strTemp = WI.fillTextValue("PERFORMANCE_FACTOR");
else
	strTemp = (String)vEditInfo.elementAt(6);
%>	  <textarea name="PERFORMANCE_FACTOR" cols="50" rows="2" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24" valign="top">Time Frame</td>
      <td height="24" colspan="2">
<%
if(bolRetainValue)
	strTemp = WI.fillTextValue("TIME_FRAME");
else
	strTemp = (String)vEditInfo.elementAt(7);
%>	  <textarea name="TIME_FRAME" cols="50" rows="2" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24">Person In-charge (ID)</td>
      <td width="28%" height="24">
<%
if(bolRetainValue)
	strTemp = WI.fillTextValue("PERSON_IN_CHARGE");
else
	strTemp = (String)vEditInfo.elementAt(8);
%>	  <input name="PERSON_IN_CHARGE" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=strTemp%>"></td>
      <td width="46%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24">Budget Amount</td>
      <td height="24" colspan="2"><font size="1"><strong>
<%
if(bolRetainValue)
	strTemp = WI.fillTextValue("BUDGET_AMT");
else
	strTemp = (String)vEditInfo.elementAt(10);
%>        <input name="BUDGET_AMT" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        </strong></font></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td height="23" valign="top">Source</td>
      <td height="23" colspan="2">
<%
if(bolRetainValue)
	strTemp = WI.fillTextValue("SOURCE");
else
	strTemp = (String)vEditInfo.elementAt(11);
%>	  <textarea name="SOURCE" cols="50" rows="2" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td height="23">Signed by(Name) :</td>
      <td height="23" colspan="2">
<%
if(bolRetainValue)
	strTemp = WI.fillTextValue("SIGNED_BY");
else
	strTemp = (String)vEditInfo.elementAt(12);
%>	  <input name="SIGNED_BY" type="text" class="textbox" size="64" maxlength="64"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=strTemp%>"></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td height="23" valign="top">&nbsp;</td>
      <td height="23" colspan="2">&nbsp;</td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="5%" height="25"><div align="center">
          <%if(iAccessLevel > 1){
	if(strPrepareToEdit.compareTo("0")  == 0){%>
          <a href='javascript:PageAction("","1");'> <img src="../../../images/save.gif" border="0" name="hide_save"></a><font size="1">click
          to save </font>&nbsp;&nbsp;&nbsp; <a href="javascript:ClearEntries();"><img src="../../../images/clear.gif" border="0"></a>
          <%}else{%>
          <a href='javascript:PageAction("","2");'> <img src="../../../images/edit.gif" border="0" name="hide_save"></a><font size="1">click
          to edit  </font>&nbsp;&nbsp; <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a>
          <font size="1">click to cancel </font>
		  <%}
    }%>
		</div></td>
    </tr>
  </table>

<%}//only if organization detail is not null//
	if(vRetResult != null && vRetResult.size() > 0){

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25"><div align="right"><font size="1"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a>click
          to print action plan</font></div></td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="10"><div align="center"><font color="#FFFFFF"><strong>ACTION
          PLAN LIST FOR SCHOOL YEAR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></font></div></td>
    </tr>
    <tr>
      <td width="9%" height="27" ><div align="center"><font size="1"><strong>OBJECTIVES</strong></font></div></td>
      <td width="10%" height="27"><div align="center"><font size="1"><strong>KEY
      RESULT AREA</strong></font></div></td>
      <td width="10%" height="27"><div align="center"><font size="1"><strong>ACTIVITIES</strong></font></div></td>
      <td width="11%"><div align="center"><font size="1"><strong>PERFORMANCE INDICATOR</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>TIME FRAME</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>PERSON IN-CHARGE</strong></font></div></td>
      <td width="11%"><div align="center"><font size="1"><strong>BUDGET AMT.</strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>SOURCE</strong></font></div></td>
      <td width="6%"><font size="1">&nbsp;<strong>EDIT</strong></font></td>
      <td width="8%" height="27"><div align="center"><strong><font size="1">DELETE</font></strong></div></td>
    </tr>
<%
for(int i = 0 ; i < vRetResult.size(); i += 13){%>
    <tr>
      <td height="25"><font size="1"><%=(String)vRetResult.elementAt(i + 4)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i + 5)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i + 2)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i + 6)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i + 7)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i + 8)%>(<%=(String)vRetResult.elementAt(i + 9)%>)</font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i + 10)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i + 11)%></font></td>
      <td><%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'>
	  		<img src="../../../images/edit.gif" border="0"></a>
			<%}%></td>
      <td><%if(iAccessLevel == 2){%>
	  <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'>
	  	<img src="../../../images/delete.gif" border="0"></a>
	 <%}%>	 </td>
    </tr>
<%}%>
  </table>
<%}%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" value="<%=WI.fillTextValue("organization_id")%>" name="organization_id">
<input type="hidden" name="organization_index" value="<%=strOrgIndex%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="reload_page">
<input type="hidden" name="print_pg">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
