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
function ReloadPage()
{
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

function checkAllSaveItems(strType) {
	var maxDisp = "";
	var bolIsSelAll = false;
	if(strType == "0"){
		maxDisp = document.form_.not_posted_count.value;
		bolIsSelAll = document.form_.selAllNotPosted.checked;	
	}
	
	if(strType == "1"){
		maxDisp = document.form_.posted_count.value;
		bolIsSelAll = document.form_.selAllPosted.checked;
	}
	
	
	for(var i =1; i<= maxDisp; ++i){
		if(strType == "0")
			eval('document.form_.save_not_posted_'+i+'.checked='+bolIsSelAll);
		if(strType == "1")
			eval('document.form_.save_posted_'+i+'.checked='+bolIsSelAll);
	}
}

function toggleSel(objQty, objChkBox){
	if(objQty.value.length > 0)
		objChkBox.checked = true;
	else
		objChkBox.checked = false;
}

function PageAction(strAction){
	if(strAction == "0"){
		if(!confirm("Do you want to delete this posted charge(s)?"))
			return;
	}
	
	if(strAction == "1"){
		if(!confirm("Do you want to post this violation charge(s)?"))
			return;
			
		document.form_.hide_save.src = "../../../images/blank.gif";
	}
	
	document.form_.page_action.value =strAction;
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

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-VIOLATIONS & CONFLICTS","post_charge_stud_violation.jsp");
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
														"post_charge_stud_violation.jsp");
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

Vector vVioNotPosted = null;
Vector vVioPosted = null;
Vector vStudInfo = null;
enrollment.OfflineAdmission offAdm = new enrollment.OfflineAdmission();
osaGuidance.ViolationConflict violation = new osaGuidance.ViolationConflict();

int iNotPosted = 0;
int iPosted = 0;

String strStudId = WI.fillTextValue("stud_id");

String strDisabled = "";
boolean bolCanPost = true;

if(strStudId.length() > 0){
	vStudInfo = offAdm.getStudentBasicInfo(dbOP, strStudId, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
	if(vStudInfo == null)
		strErrMsg = offAdm.getErrMsg();
	else{
	
		strTemp = WI.fillTextValue("page_action");
		if(strTemp.length()  >0){
			if(strTemp.equals("1")){
				if(!violation.postStudViolationCharges(dbOP, request, (String)vStudInfo.elementAt(12)))
					strErrMsg = violation.getErrMsg();
				else
					strErrMsg = "Violation charge(s) successfully posted.";					
			}
			if(strTemp.equals("0")){
				if(!violation.removePostedStudViolationCharges(dbOP, request, (String)vStudInfo.elementAt(12)))
					strErrMsg = violation.getErrMsg();
				else
					strErrMsg = "Posted violation charge(s) successfully deleted.";					
			}
		}

	
	
		vVioPosted = violation.getStudViolationFine(dbOP, request,  (String)vStudInfo.elementAt(12), 1);
		if(vVioPosted != null && vVioPosted.size() > 0)
			iPosted = violation.getElemCount();
		
		vVioNotPosted = violation.getStudViolationFine(dbOP, request, (String)vStudInfo.elementAt(12), 0);
		if(vVioNotPosted != null && vVioNotPosted.size() > 0)
			iNotPosted = violation.getElemCount();		
			
		if(!violation.checkCurrentSYTerm(dbOP, (String)vStudInfo.elementAt(12), WI.fillTextValue("sy_from"), WI.fillTextValue("semester"))){
			strTemp = "SY-Term provided is not the current student enrollment term.<br>System cannot post or remove posted charge(s).";
			if(strErrMsg != null)
				strErrMsg += "<br>"+strErrMsg;
			else
				strErrMsg = strTemp;
			bolCanPost  = false;
			strDisabled="disabled";
			strTemp = null;
		}
	}
}
int iCount = 0;
%>
<form action="./post_charge_stud_violation.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF" ><strong>::::
          POST VIOLATION CHARGE PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2"><font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
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
</td>
    </tr>
    
    <tr>
      <td height="25" width="3%"></td>
      <td width="15%">Student ID</td>
	  <%strTemp = WI.fillTextValue("stud_id");%>
      <td width="82%"><input name="stud_id" type="text" class="textbox" size="20" maxlength="20" value="<%=strTemp%>" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();">        &nbsp; &nbsp; 
      	<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" align="absmiddle"></a>
		<a href="javascript:ReloadPage();">
      	<img src="../../../images/form_proceed.gif" border="0"></a>		
	&nbsp; &nbsp;
	<label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; width:400px; position:absolute;"></label>	
	</td>
      
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){
%>
<input type="hidden" name="year_level" value="<%=(String)vStudInfo.elementAt(14)%>">
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
        <td height="18" colspan="3"><hr size="1"></td>
        </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%">Student Name</td>
	  <%
	  strTemp = WebInterface.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),4);
	  %>
      <td><strong><%=strTemp%></strong><input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(12)%>"></td>
      </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Course/Major(cy)</td>
      <td><strong><%=(String)vStudInfo.elementAt(7)%>
        <%if(vStudInfo.elementAt(8) != null){%>
        /<%=(String)vStudInfo.elementAt(8)%>
        <%}%>
        (<%=(String)vStudInfo.elementAt(3)%> to <%=(String)vStudInfo.elementAt(4)%>
        )</strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>YEAR LEVEL</td>
      <td><strong><%=WI.getStrValue(vStudInfo.elementAt(14),"0")%></strong></td>
      </tr>    
        <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>

<%
if(vVioNotPosted == null || vVioNotPosted.size() == 0){
%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="center" height="25" bgcolor="#9FcFFF"><strong>NO LIST OF VIOLATION NOT POSTED</strong></td></tr>
</table>
<%}else{%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr><td align="center" colspan="8" height="25" class="thinborder"><strong>LIST OF VIOLATION NOT POSTED</strong></td></tr>
	<tr style="font-weight:bold;">
		<td width="11%" height="22"  align="center" class="thinborder">Date of Violation</td>
		<td width="14%" class="thinborder" align="center">Incident Type</td>
		<td width="16%" class="thinborder" align="center">Incident</td>
		<td width="21%" class="thinborder" align="center">Report Description</td>
		<td width="16%" class="thinborder" align="center">Remark</td>
		<td width="11%" class="thinborder" align="center">Posting Date</td>
		<td width="7%" class="thinborder" align="center">Amount</td>
		<td width="4%" class="thinborder" align="center">Post All<br>
		<input type="checkbox" name="selAllNotPosted" value="0" onClick="checkAllSaveItems('0');" <%=strDisabled%> > </td>
	</tr>
	<%
	iCount =0;
	for(int i = 0 ; i < vVioNotPosted.size(); i+=iNotPosted){%>
	<tr>
	    <td height="22" class="thinborder"><%=vVioNotPosted.elementAt(i+2)%></td>
	    <td class="thinborder"><%=vVioNotPosted.elementAt(i+6)%></td>
	    <td class="thinborder"><%=vVioNotPosted.elementAt(i+4)%>
		<%
		strTemp = (String)vVioNotPosted.elementAt(i+4);
		%>
		<input type="hidden" name="note_<%=++iCount%>" value="<%=ConversionTable.replaceString(strTemp,"\""," ")%>">
		</td>
	    <td class="thinborder"><%=vVioNotPosted.elementAt(i+7)%></td>
	    <td class="thinborder"><%=vVioNotPosted.elementAt(i+10)%></td>
		<%
		strTemp = WI.fillTextValue("date_post_"+iCount);
		if(strTemp.length() == 0)
			strTemp = WI.getTodaysDate(1);
		if(strDisabled.length() > 0)
			strTemp = "";
		%>
	    <td class="thinborder" align="center">
		<input name="date_post_<%=iCount%>" type="text" size="10" maxlength="10" readonly="yes" class="textbox" <%=strDisabled%> 
				value="<%=strTemp%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<%if(strDisabled.length() == 0){%>
			<a href="javascript:show_calendar('form_.date_post_<%=iCount%>');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
			<%}%>
		</td>
		<%
		strTemp =WI.fillTextValue("amount_"+iCount);
		if(strDisabled.length() > 0)
			strTemp = "";
		%>
	    <td class="thinborder" align="center">
		<input name="amount_<%=iCount%>" type="text" size="6" class="textbox" value="<%=strTemp%>"   <%=strDisabled%> 
				onfocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','amount_<%=iCount%>');
					toggleSel(document.form_.amount_<%=iCount%>, document.form_.save_not_posted_<%=iCount%>)"
				onKeyUp="AllowOnlyFloat('form_','amount_<%=iCount%>')">
		</td>
	    <td class="thinborder" align="center">
			<input type="checkbox" name="save_not_posted_<%=iCount%>" value="<%=vVioNotPosted.elementAt(i)%>" tabindex="-1" <%=strDisabled%> ></td>
	</tr>
	<%}%>
	<input type="hidden" name="not_posted_count" value="<%=iCount%>">
</table>

<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="center">
<%
if(bolCanPost){
%>
	<a href="javascript:PageAction('1')"><img name="hide_save" src="../../../images/save.gif" border="0"></a>
	<font size="1">Click to post charge violation</font>
<%}else{%><strong style="color:#FF0000">CANNOT POST CHARGE(S)</strong><%}%>
	</td></tr>
</table>

<%}%>


<%
if(vVioPosted == null || vVioPosted.size() == 0){
%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="center" height="25" bgcolor="#9FcFFF"><strong>NO LIST OF VIOLATION POSTED</strong></td></tr>
</table>
<%}else{%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td height="30">&nbsp;</td></tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr><td align="center" colspan="8" height="25" class="thinborder"><strong>LIST OF VIOLATION POSTED</strong></td></tr>
	<tr style="font-weight:bold;">
		<td width="11%" height="22"  align="center" class="thinborder">Date of Violation</td>
		<td width="14%" class="thinborder" align="center">Incident Type</td>
		<td width="16%" class="thinborder" align="center">Incident</td>
		<td width="21%" class="thinborder" align="center">Report Description</td>
		<td width="16%" class="thinborder" align="center">Remark</td>
		<td width="11%" class="thinborder" align="center">Date Posted</td>
		<td width="7%" class="thinborder" align="center">Amount</td>
		<td width="4%" class="thinborder" align="center">Post All<br>
		<input type="checkbox" name="selAllPosted" value="0" onClick="checkAllSaveItems('1');" <%=strDisabled%> ></td>
	</tr>
	<%
	iCount =0;
	for(int i = 0 ; i < vVioPosted.size(); i+=iPosted){%>
	<tr>
	    <td height="22" class="thinborder"><%=vVioPosted.elementAt(i+2)%></td>
	    <td class="thinborder"><%=vVioPosted.elementAt(i+4)%></td>
	    <td class="thinborder"><%=vVioPosted.elementAt(i+6)%></td>
	    <td class="thinborder"><%=vVioPosted.elementAt(i+7)%></td>
	    <td class="thinborder"><%=vVioPosted.elementAt(i+10)%></td>		
	    <td class="thinborder" align="center"><%=vVioPosted.elementAt(i+17)%>&nbsp;</td>
	    <td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vVioPosted.elementAt(i+16), true)%>&nbsp;</td>
		<input type="hidden" name="payable_index_<%=++iCount%>" value="<%=vVioPosted.elementAt(i+18)%>">
	    <td class="thinborder" align="center">
			<input type="checkbox" name="save_posted_<%=iCount%>" value="<%=vVioPosted.elementAt(i)%>" tabindex="-1" <%=strDisabled%> ></td>
	</tr>
	<%}%>
	<input type="hidden" name="posted_count" value="<%=iCount%>">
</table>

<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="center">
<%
if(bolCanPost){
%>
	<a href="javascript:PageAction('0')"><img src="../../../images/delete.gif" border="0"></a>
	<font size="1">Click to remove posted charge</font>
<%}else{%><strong style="color:#FF0000">CANNOT REMOVE POSTED CHARGE(S)</strong><%}%>
	</td></tr>
</table>

<%}%>

<%}%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable4">
<tr><td height="25" colspan="9">&nbsp;</td></tr>
<tr><td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>

<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
