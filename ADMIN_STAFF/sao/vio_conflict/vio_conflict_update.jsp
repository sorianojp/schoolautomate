<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.ViolationConflict"%>
<%
		WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript">

var strPartyType = "";
function AjaxMapName(strType) {
		
		strPartyType = strType;
		var strCompleteName = "";
		var objCOAInput = "";
		if(strType == '0'){
			strCompleteName = document.form_.charged_party_text.value;
			objCOAInput = document.getElementById("coa_info");
		}else{
			strCompleteName = document.form_.complainant_text.value;
			objCOAInput = document.getElementById("coa_info1");
		}
			
		if(strCompleteName.length < 2)
			return;
			
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
	if(strPartyType == '0'){
		if(document.form_.charged_party.value.length == 0)
			document.form_.charged_party.value = strID;
		else
			document.form_.charged_party.value += ","+ strID;
	}else{
		if(document.form_.complainant.value.length == 0)
			document.form_.complainant.value = strID;
		else
			document.form_.complainant.value += ","+ strID;
	}
}
function UpdateName(strFName, strMName, strLName) {
	
}
function UpdateNameFormat(strName) {
	if(strPartyType == '0'){
		document.getElementById("coa_info").innerHTML = strName;
	}else{
		document.getElementById("coa_info1").innerHTML = strName;
	}
}

function PageAction(strAction){
	document.form_.page_action.value=strAction;
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}

function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname +
	"&colname=" + colname+"&label="+labelname+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function GoBack() {
	location = document.form_.parent_url.value;
}
function PrintPage(){
	document.form_.print_pg.value = "1";
	this.SubmitOnce("form_");
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./vio_conflict_update_print.jsp" />
	<%}
	
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-VIOLATIONS & CONFLICTS","vio_conflict_update.jsp");
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
														"vio_conflict_update.jsp");
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
Vector vRetResult = new Vector();//It has all information.
boolean bolNoRecord = true;
String strInfoIndex = WI.fillTextValue("info_index");
ViolationConflict VC = new ViolationConflict();

strTemp = WI.fillTextValue("page_action");
if(WI.fillTextValue("sy_from").length() > 0) {
	if(strTemp.length() > 0) {
		if( (vRetResult = VC.operateOnViolation(dbOP, request,Integer.parseInt(strTemp))) == null)
			strErrMsg = VC.getErrMsg();
		else {
			strErrMsg = "Operation Successful.";
			//added for UB to show how many violations a student already has.
			if(strTemp.equals("1") && vRetResult != null && vRetResult.size() == 1){
				osaGuidance.ViolationConflictExtn VCExtn = new osaGuidance.ViolationConflictExtn();
				strTemp = VCExtn.getStudentViolationCount(dbOP, request, (String)vRetResult.elementAt(0));
				if(strTemp != null && strTemp.length() > 0)
					strErrMsg += "<br>"+strTemp;
			}	

			//if(strTemp.compareTo("1") == 0)
			//	strInfoIndex = (String)vRetResult.elementAt(0);
			vRetResult = new Vector();
			//if(!strTemp.equals("0")) 
				bolNoRecord = false;
		}
	}
}
//change of design. It will keep adding information. It will show edit / delete button only if
//it is called from edit button.
if(strInfoIndex.length() > 0 && strErrMsg == null) {
	vRetResult = VC.operateOnViolation(dbOP, request,3);
	if(vRetResult == null)
		strErrMsg = VC.getErrMsg();
	else	
		bolNoRecord = false;	
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsCleared = false;

%>
<body bgcolor="#D2AE72">
<form action="./vio_conflict_update.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>::::
          VIOLATION AND CONFLICT MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%"><a href="./vio_conflict.jsp"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a>&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(!bolNoRecord){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" style="font-size:12px; font-weight:bold">
	  <a href="./vio_conflict_update.jsp">
	  Click to Create New Case Information. </a></td>
    </tr>
<%}%>
    <tr>
      <td width="2%" height="30">&nbsp;</td>
      <td width="17%" height="30">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="61%" height="30"><div align="right">
          <%
if(!bolNoRecord){%>
          <a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a><font size="1">click to print
          this record
          <%}%></font>
        </div></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td height="30">SY-TERM</td>
      <td height="30" colspan="2"> <%
if(!bolNoRecord && WI.fillTextValue("reloadPage").compareTo("1") != 0)
	strTemp = (String)vRetResult.elementAt(1);
else
	strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        -
        <%
if(!bolNoRecord && WI.fillTextValue("reloadPage").compareTo("1") != 0)
	strTemp = (String)vRetResult.elementAt(2);
else
	strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        -
        <select name="semester">
          <%
if(!bolNoRecord && WI.fillTextValue("reloadPage").compareTo("1") != 0)
	strTemp = (String)vRetResult.elementAt(3);
else
	strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td height="30">Date Of Violation</td>
      <td height="30" colspan="2"> <font size="1">
        <%
if(!bolNoRecord && WI.fillTextValue("reloadPage").compareTo("1") != 0)
	strTemp = (String)vRetResult.elementAt(4);
else
	strTemp = WI.fillTextValue("date_of_violation");
%>
        <input name="date_of_violation" type="text" value="<%=strTemp%>" size="15" readonly="true" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
        <a href="javascript:show_calendar('form_.date_of_violation');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        </font></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td height="30">Date reported</td>
      <td height="30" colspan="2"> <font size="1">
        <%
if(!bolNoRecord && WI.fillTextValue("reloadPage").compareTo("1") != 0)
	strTemp = (String)vRetResult.elementAt(5);
else
	strTemp = WI.fillTextValue("date_reported");
%>
        <input name="date_reported" type="text" value="<%=strTemp%>" size="15" readonly="true" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
        <a href="javascript:show_calendar('form_.date_reported');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        </font></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="30">Case #</td>
      <td height="24" colspan="2"> <%
if(!bolNoRecord && WI.fillTextValue("reloadPage").compareTo("1") != 0)
	strTemp = (String)vRetResult.elementAt(6);
else
	strTemp = WI.fillTextValue("case_no");
if(VC.strNewCaseNo != null)
	strTemp = VC.strNewCaseNo;	
%> <input name="case_no" type="text" class="textbox_noborder" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=strTemp%>" readonly="yes"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="30">Incident Type</td>
      <td height="25" colspan="2"> <%
if(!bolNoRecord && WI.fillTextValue("reloadPage").compareTo("1") != 0)
	strTemp = (String)vRetResult.elementAt(7);
else
	strTemp = WI.fillTextValue("violation_type");
%> 
	<select name="violation_type">
          <%=dbOP.loadCombo("VIOLATION_TYPE_INDEX","VIOLATION_NAME"," FROM OSA_PRELOAD_VIOL_TYPE ",strTemp,false)%> 
	</select> 
	<strong> 
		  <%if (WI.fillTextValue("allowEdit").equals("1")){%>
		  <a href='javascript:viewList("OSA_PRELOAD_VIOL_TYPE","VIOLATION_TYPE_INDEX","VIOLATION_NAME","INCIDENT TYPE",
		  "OSA_VIOLATION","VIOLATION_TYPE_INDEX"," and OSA_VIOLATION.IS_VALID =1","","violation_type")'><img src="../../../images/update.gif" border="0"></a></strong><font size="1">click
        to update list of incident type</font><%}%></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="30">Incident</td>
      <td height="0" colspan="2"> <select name="incident_index">
          <%
if(!bolNoRecord && WI.fillTextValue("reloadPage").compareTo("1") != 0)
	strTemp = (String)vRetResult.elementAt(14);
else
	strTemp = WI.fillTextValue("incident_index");
%>
          <%=dbOP.loadCombo("INCIDENT_INDEX","INCIDENT"," FROM OSA_PRELOAD_VIOL_INCIDENT",strTemp,false)%> </select> <strong> 
		  <%if (WI.fillTextValue("allowEdit").equals("1")){%>
		  <a href='javascript:viewList("OSA_PRELOAD_VIOL_INCIDENT","INCIDENT_INDEX","INCIDENT","VIOLATION INCIDENT NAME",
		  "OSA_VIOLATION","INCIDENT_INDEX"," and OSA_VIOLATION.IS_VALID =1","","incident_index")'><img src="../../../images/update.gif" border="0"></a></strong><font size="1">click
        to update list of Incident</font><%}%></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="30" valign="top"><font color="#0000CC">Charged Party</font>
        (Student Must provide ID #)</td>
      <td height="0" colspan="2"> 
		<input name="charged_party_text" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value=""  onKeyUp="AjaxMapName('0');">
		<label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute; width:300px;"></label><br>
		<%
if(!bolNoRecord && WI.fillTextValue("reloadPage").compareTo("1") != 0)
	strTemp = (String)vRetResult.elementAt(13);
else
	strTemp = WI.fillTextValue("charged_party");
%> <textarea name="charged_party" cols="50" rows="3" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea>
        <font size="1">&lt;separate entries with comma&gt;<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></font>
		   
		  </td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="30" valign="top"><font color="#0000FF">Complainant</font>
        (Student Must provide ID #)</td>
      <td height="0" colspan="2">
		<input name="complainant_text" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="" onKeyUp="AjaxMapName('1');">
		<label id="coa_info1" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute; width:300px;"></label><br>
        <%
if(!bolNoRecord && WI.fillTextValue("reloadPage").compareTo("1") != 0)
	strTemp = (String)vRetResult.elementAt(16);
else
	strTemp = WI.fillTextValue("complainant");
%>
        <textarea name="complainant" cols="50" rows="3" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea>
        <font size="1">&lt;separate entries with comma&gt;</font> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a>
		   
		  </td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="30" valign="top">Report of Description</td>
      <td height="0" colspan="2"> <%
if(!bolNoRecord && WI.fillTextValue("reloadPage").compareTo("1") != 0)
	strTemp = (String)vRetResult.elementAt(9);
else
	strTemp = WI.fillTextValue("violation_desc");
%> <textarea name="violation_desc" cols="50" rows="3" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="30" valign="top">Action Taken</td>
      <td height="0" colspan="2"> <%
if(!bolNoRecord && WI.fillTextValue("reloadPage").compareTo("1") != 0)
	strTemp = (String)vRetResult.elementAt(10);
else
	strTemp = WI.fillTextValue("action_taken");
%> <textarea name="action_taken" cols="50" rows="3" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td height="30" valign="top">Recommendation</td>
      <td height="23" colspan="2"> <%
if(!bolNoRecord && WI.fillTextValue("reloadPage").compareTo("1") != 0)
	strTemp = (String)vRetResult.elementAt(11);
else
	strTemp = WI.fillTextValue("recommendation");
%> <textarea name="recommendation" cols="50" rows="3" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td height="30" valign="top">Remarks(Resolution)</td>
      <td height="23" colspan="2"> <%
if(!bolNoRecord && WI.fillTextValue("reloadPage").compareTo("1") != 0)
	strTemp = WI.getStrValue((String)vRetResult.elementAt(17),"");
else
	strTemp = WI.fillTextValue("remark");
%> <textarea name="remark" cols="50" rows="3" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>
    </tr>
	<tr>
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td valign="top">Clear Case: </td>
      <td height="23" colspan="2">
      <%
	if(!bolNoRecord && WI.fillTextValue("reloadPage").compareTo("1") != 0)
		strTemp = (String)vRetResult.elementAt(18);
	else	
      strTemp = WI.fillTextValue("is_clear");

     if (strTemp.equals("1")) {
	      strTemp = "checked";
		  bolIsCleared = true;
	  }
      else
    	  strTemp = "";%>
      <input type="checkbox" name="is_clear" value="1" <%=strTemp%>></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>Clear Date:</td>
      <td colspan="2">
        <%
			if(!bolNoRecord && WI.fillTextValue("reloadPage").compareTo("1") != 0)
				strTemp = WI.getStrValue((String)vRetResult.elementAt(19),"");
			else
				strTemp = WI.fillTextValue("clear_date");%>
        <input name="clear_date" type="text" value="<%=strTemp%>" size="15" readonly="true" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
        <a href="javascript:show_calendar('form_.clear_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>      </td>
    </tr>
   	<tr>
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td >&nbsp;</td>
      <td colspan="2">
      <%if (WI.fillTextValue("allowEdit").equals("1")){%>
      Send EMAIL to Parent: <font size="1"><img src="../../../images/send_email.gif"><%}%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(bolNoRecord){%>
    <tr>
      <td height="25"><a href="javascript:PageAction(1);"><img src="../../../images/save.gif" border="0" name="hide_save"></a><font size="1">click to save </td>
    </tr>
<%}else{%>
    <tr>
      <td height="25"><div align="center">
<%if (WI.fillTextValue("allowEdit").equals("1")){
if(iAccessLevel > 1){
	if(strInfoIndex == null || strInfoIndex.length() == 0){%>
		 <a href="javascript:PageAction(1);">
		 	<img src="../../../images/save.gif" border="0" name="hide_save"></a><font size="1">click
          to save &nbsp;&nbsp;&nbsp;
	<%}else{%>
		  <a href="javascript:PageAction(2);">
		  <img src="../../../images/edit.gif" border="0" name="hide_save"></a>click
          to edit &nbsp;&nbsp; </font>
		  <a href="javascript:GoBack();"><img src="../../../images/cancel.gif" border="0"></a>
		  <font size="1">click to cancel &nbsp;&nbsp;</font>
		<%}
		}
		}
		if(!bolNoRecord){%>
          <a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a><font size="1">click to print
          this record
          <%}if(!bolIsCleared) {%>
		  &nbsp;&nbsp;&nbsp;&nbsp;
         	<input type="button" name="122" value=" Delete/Remove Violation Record " style="font-size:11px; height:24px;border: 1px solid #FF0000;" onClick="PageAction(0);">
		  
		  <%}%>
</font></div></td>
    </tr>
  </table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9"><font color="#FF0000" size="1"><em>
<!--	  note to programmer:
        show SAVE/CANCEL when UPDATE; show EDIT/DELETE/CANCEL when VIEW from VIO_CONFLICT_UPDATE
        page ; show no buttons if called from Student Tracker page--></em></font></td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<!-- set it to 0 while calling update -->
<input type="hidden" name="reloadPage" value="1">
<input type="hidden" name="parent_url" value="<%=WI.fillTextValue("parent_url")%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="print_pg">
<input type="hidden" name="allowEdit" value="<%=WI.fillTextValue("allowEdit")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
