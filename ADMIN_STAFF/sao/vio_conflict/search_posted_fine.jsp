<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script language="javascript" src ="../../../jscript/common.js" ></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage(strShoResult)
{
	document.form_.show_result.value = strShoResult;
	document.form_.print_page.value = "";
	document.form_.submit();
}

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

function PrintPage(){
	document.form_.print_page.value = "1";
	document.form_.submit();
}


</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.ViolationConflict"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	if(WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./search_posted_fine_print.jsp"></jsp:forward>
	<%return;}
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-VIOLATIONS & CONFLICTS","search_posted_fine.jsp");
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
														"Student Affairs","VIOLATIONS & CONFLICTS",request.getRemoteAddr(),
														"search_posted_fine.jsp");
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

osaGuidance.ViolationConflict violation = new osaGuidance.ViolationConflict();


Vector vRetResult = null;

String strStudId = WI.fillTextValue("stud_id");
int iElemCount =0;
if(WI.fillTextValue("show_result").length() > 0){
	strErrMsg = null;
	if(strStudId.length() > 0){
		strStudId = dbOP.mapUIDToUIndex(strStudId,4);
		if(strStudId == null)
			strErrMsg = "Student id does not exists or is invalidated";
	}
	
	
	if(strErrMsg == null){
		strTemp = WI.getStrValue(WI.fillTextValue("not_posted"),"1");
		
		vRetResult = violation.getStudViolationFine(dbOP, request, strStudId, Integer.parseInt(strTemp));
		if(vRetResult == null)
			strErrMsg = violation.getErrMsg();
		else
			iElemCount = violation.getElemCount();
	}

}

int iCount = 0;
%>
<form action="./search_posted_fine.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF" ><strong>::::
          VIEW POSTED/UNPOSTED VIOLATION CHARGE PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td width="15%">SY/Term</td>
     <td width="82%"> 

<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> 
<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to')">
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" readonly>
        -
        <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
%>
<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select>
		
		&nbsp;&nbsp;
		<%
		strTemp = WI.fillTextValue("not_posted");
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";

		%>
		<input type="checkbox" name="not_posted" value="0" <%=strErrMsg%> onClick="ReloadPage('')">Click to show not posted violation(s)
		</td>
    </tr>
 <%if(WI.fillTextValue("not_posted").length() == 0){%>  
    <tr>
        <td height="25"></td>
        <td>Posted Date Range </td>
        <td>
		<input name="date_post_fr" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
				value="<%=WI.fillTextValue("date_post_fr")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<a href="javascript:show_calendar('form_.date_post_fr');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
		 - 
		<input name="date_post_to" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
				value="<%=WI.fillTextValue("date_post_to")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<a href="javascript:show_calendar('form_.date_post_to');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
				
		
		</td>
    </tr>
<%
}else{
%>
	<tr>
        <td height="25"></td>
        <td>Violation Date Range</td>
        <td>
		<input name="violation_date_fr" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
				value="<%=WI.fillTextValue("violation_date_fr")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<a href="javascript:show_calendar('form_.violation_date_fr');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
		 - 
		<input name="violation_date_to" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
				value="<%=WI.fillTextValue("violation_date_to")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<a href="javascript:show_calendar('form_.violation_date_to');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
				
		
		</td>
    </tr>
<%}%>
    <tr>
        <td height="25"></td>
        <td>Incident Type</td>
        <td>
		<select name="incident_type" style=" width:300px;">
			<option value="">Select Incident Type</option>
			<%
			strTemp = " from OSA_PRELOAD_VIOL_TYPE order by VIOLATION_NAME ";
			%>
			<%=dbOP.loadCombo("VIOLATION_TYPE_INDEX","VIOLATION_NAME",strTemp, WI.fillTextValue("incident_type"), false)%>
		</select>
		</td>
    </tr>
    <tr>
        <td height="25"></td>
        <td>Incident</td>
        <td>
		<select name="incident" style=" width:300px;">
			<option value="">Select Incident</option>
			<%
			strTemp = " from OSA_PRELOAD_VIOL_INCIDENT order by INCIDENT ";
			%>
			<%=dbOP.loadCombo("INCIDENT_INDEX","INCIDENT",strTemp, WI.fillTextValue("incident"), false)%>
		</select>
		</td>
    </tr>
   
    <tr>
      <td height="25" width="3%"></td>
      <td width="15%">Student ID</td>
	  <%strTemp = WI.fillTextValue("stud_id");%>
      <td width="82%"><input name="stud_id" type="text" class="textbox" size="20" maxlength="20" value="<%=strTemp%>" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();">        &nbsp; &nbsp; 
      	<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" align="absmiddle"></a>
		<a href="javascript:ReloadPage('1');">
      	<img src="../../../images/form_proceed.gif" border="0"></a>		
	&nbsp; &nbsp;
	<label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; width:400px; position:absolute;"></label>	</td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0){
%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="right">
		Rows Per Page: 
	  <select name="rows_per_pg">
<%
int iDefVal = 35;
if(WI.fillTextValue("rows_per_pg").length() > 0)
	iDefVal = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
for(int i = 35; i < 70; ++i) {
	if(iDefVal == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
	<option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>
	<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
	<font size="1">Click to print report</font>
	</td></tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
<%
strTemp = WI.fillTextValue("not_posted");
if(strTemp.equals("0"))
	strTemp = "LIST OF VIOLATION NOT POSTED";
else
	strTemp = "LIST OF VIOLATION POSTED";
%>
	<tr><td align="center" colspan="7" height="25" class="thinborder"><strong><%=strTemp%></strong></td></tr>
	<tr style="font-weight:bold;">
		<td width="11%" height="22"  align="center" class="thinborder">Date of Violation</td>
		<td width="14%" class="thinborder" align="center">Incident Type</td>
		<td width="16%" class="thinborder" align="center">Incident</td>
		<td width="21%" class="thinborder" align="center">Report Description</td>
		<td width="16%" class="thinborder" align="center">Remark</td>
	<%
	if(WI.fillTextValue("not_posted").length() == 0){
	%>
		<td width="11%" class="thinborder" align="center">Date Posted</td>
		<td width="7%" class="thinborder" align="center">Amount</td>
	<%}%>
		</tr>
	<%
	String strCurrID = null;
	String strPrevID = "";
	for(int i = 0 ; i < vRetResult.size(); i+=iElemCount){
	strCurrID = (String)vRetResult.elementAt(i+19);
	
	if(!strPrevID.equals(strCurrID) && WI.fillTextValue("stud_id").length() == 0){
		strPrevID = strCurrID;
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+20),(String)vRetResult.elementAt(i+21),(String)vRetResult.elementAt(i+22),4);
	%>
	<tr>
	    <td height="22" colspan="7" class="thinborder"><strong>Student Name : <%=strTemp%> (<%=strCurrID%>)</strong></td>
    </tr>
	<%}%>
	<tr>
	    <td height="22" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+2),"&nbsp;")%></td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+4),"&nbsp;")%></td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+6),"&nbsp;")%></td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+7),"&nbsp;")%></td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+10),"&nbsp;")%></td>		
	<%
	if(WI.fillTextValue("not_posted").length() == 0){
	%>

	    <td class="thinborder" align="center"><%=vRetResult.elementAt(i+17)%>&nbsp;</td>
	    <td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+16), true)%>&nbsp;</td>
	<%}%>		
	    </tr>
	<%}%>
	
</table>
<%}%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable4">
<tr><td height="25" colspan="9">&nbsp;</td></tr>
<tr><td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>

<input type="hidden" name="show_result">
<input type="hidden" name="is_search" value="1">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
