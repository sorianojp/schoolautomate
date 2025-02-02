<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Transfer Of Credential</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.branch{
	display: none;
	margin-left: 16px;
}
</style>
</head>
<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	document.form_.print_pg.value = "";
	
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == "1")
		document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.print_pg.value = "";

	document.form_.info_index.value = strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage() {
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintPg() {
	document.form_.print_pg.value = "1";
	this.SubmitOnce('form_');
}
/////////////////// for tree collapse /////////////////////////
var openImg = new Image();
openImg.src = "../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../images/box_with_plus.gif";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else
		objBranch.display="block";
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('box_with_plus.gif')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
}

//all about ajax.
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
<%@ page language="java" import="utility.*,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Administration-system_administration-set_parameters-tc",
								"tc.jsp");
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
/**
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Internet Cafe Management",
														"INTERNET OTHER SERVICES",request.getRemoteAddr(),
														"vio.jsp");
**/


//end of authenticaion code.
enrollment.ReportRegistrar tcr = new enrollment.ReportRegistrar();
Vector vEditInfo = null;
Vector vRetResult = null;
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(tcr.operateOnTc(dbOP, request, Integer.parseInt(strTemp)) == null) {
		strErrMsg = tcr.getErrMsg();		
	}
	else {	
		strErrMsg = "Operation is successful.";
		strPrepareToEdit = "0";
	}
}
//I have to get here information.
if(strPrepareToEdit.compareTo("0") != 0) {
	vEditInfo = tcr.operateOnTc(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = tcr.getErrMsg();
}
 if(WI.fillTextValue("semester").length() > 0){  
	vRetResult = tcr.operateOnTc(dbOP, request, 4);
	if(strErrMsg == null && vRetResult == null)
		strErrMsg = tcr.getErrMsg();
}


String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"Student ID","Lastname","Firstname","Year Level"};
String[] astrSortByVal     = {"user1.id_number","user1.lname","user1.fname","yr_level"};
utility.ConstructSearch constructSearch = new utility.ConstructSearch();

boolean bolPrintPg = false;
if(WI.fillTextValue("print_pg").equals("1")) 
	bolPrintPg = true;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsCGH  = strSchCode.startsWith("CGH");
boolean bolIsSACI = strSchCode.startsWith("UDMC");

%>
<body>
<form action="./tc.jsp" method="post" name="form_">
<%if(!bolPrintPg){//do not show this if called for printing.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          TRANSFER OF CREDENTIAL INFORMATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="22">&nbsp;</td>
      <td width="16%">SY-Term</td>
      <td width="41%"><%
	   strTemp = WI.fillTextValue("sy_from");
	   if(strTemp.length() ==0) 
	  	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	   %>
          <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from","sy_to")'> 
        <%
		strTemp = WI.fillTextValue("sy_to");
		if(strTemp.length() ==0) 
	    	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	   %>
       
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"> &nbsp;&nbsp;&nbsp;&nbsp; <select name="semester">
          <option value="0">Summer</option>
          <% strTemp = WI.fillTextValue("semester");
		   if(strTemp.length() ==0){
			  strTemp = (String)request.getSession(false).getAttribute("cur_sem");
			}  
           if(strTemp.compareTo("1") ==0){%>
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
        </select>      </td>
      <td width="41%"> &nbsp;<a href='javascript:ReloadPage();'><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="22">&nbsp;</td>
      <td width="16%">Student  ID</td>
      <td width="24%"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("stud_id");
%> <input name="stud_id" type="text" length="16" maxlength="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" 
	   onKeyUp="AjaxMapName('1');"
	  onBlur="style.backgroundColor='white'"> 
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="28" height="23" border="0"></a>      </td>
      <td width="58%"><label id="coa_info" style="position:absolute; width:400px;"></label></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td>TC Date</td>
      <td colspan="2"> 
<%
 if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("tc_date");
if(strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);
%> 
	<input name="tc_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.tc_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Admission Date </td>
      <td colspan="2">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(10);
else	
	strTemp = WI.fillTextValue("sy_from2");
%>        <input name="sy_from2" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from2","sy_to2")'>
      &nbsp;
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(11);
else	
	strTemp = WI.fillTextValue("sy_to2");
%>	  <input name="sy_to2" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
&nbsp;&nbsp;&nbsp;&nbsp;
<select name="semester2">
  <option value="0">Summer</option>
  <% 
  if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(12);
  else	
	strTemp = WI.fillTextValue("sy_from2");
  if(strTemp == null) strTemp = "";
     if(strTemp.compareTo("1") ==0){%>
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
      <td height="25">&nbsp;</td>
      <td valign="top">Reason</td>
      <% if(vEditInfo != null && vEditInfo.size() > 0)
	       strTemp = (String)vEditInfo.elementAt(6);
		 else
		   strTemp = WI.fillTextValue("reason");
		%>
      <td colspan="2"><textarea name="reason" cols="60" rows="4" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
<%if(!bolIsCGH) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>School To Transfer</td>
      <td colspan="2">
<%
 if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = WI.getStrValue(vEditInfo.elementAt(17));
else	
	strTemp = WI.fillTextValue("sch_index");
%> 
	  <select name="sch_index" style="font-size:10px;">
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_CODE + ' :: '+SCH_NAME",
		  " from SCH_ACCREDITED where IS_DEL=0 and sch_name not like '%elem%' order by SCH_CODE",strTemp,false)%>
	    </select>	  </td>
    </tr>
<%}if(bolIsSACI){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Interviewd By</td>
      <td colspan="2" style="font-size:9px">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(13);
else	
	strTemp = WI.fillTextValue("interviewed_by");
%> <input name="interviewed_by" type="text" length="16" maxlength="16" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
- Name </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Date Interviewed</td>
      <td colspan="2">
<%
 if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = WI.getStrValue(vEditInfo.elementAt(14));
else	
	strTemp = WI.fillTextValue("interview_date");
if(strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);
%> 
	<input name="interview_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.interview_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>School To Transfer</td>
      <td colspan="2">
<%
 if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = WI.getStrValue(vEditInfo.elementAt(17));
else	
	strTemp = WI.fillTextValue("sch_index");
%> 
	  <select name="sch_index" style="font-size:10px;">
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_CODE + ' :: '+SCH_NAME",
		  " from SCH_ACCREDITED where IS_DEL=0 and sch_name not like '%elem%' order by SCH_CODE",strTemp,false)%>
	    </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Application Status</td>
      <td colspan="2">
<%
 if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = WI.getStrValue(vEditInfo.elementAt(18));
else	
	strTemp = WI.fillTextValue("application_stat");
%> 	
		<select name="application_stat">
		<option value="3">Granted TC</option>
<%
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="1"<%=strErrMsg%>>For Interview</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="2"<%=strErrMsg%>>Returned</option>
<%
if(strTemp.equals("0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="0"<%=strErrMsg%>>Cancelled</option>
		</select>	  </td>
    </tr>
<%}%>
  </table>
	
<%if(iAccessLevel > 1){%>	  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr> 
      <td width="23%" height="39">&nbsp;</td>
      <td width="77%" valign="bottom">
	  <%if(strPrepareToEdit.compareTo("0") == 0) {%>
	  <a href='javascript:PageAction("1","");'><img src="../../../images/save.gif" border="0" name="hide_save"></a>
	  <%}else{%>
	  <a href='javascript:PageAction("2","");'><img src="../../../images/edit.gif" border="0"></a>
	  <%}%>
	  <font size="1">click to save entries/changes 
	  <a href="./tc.jsp?sy_from=<%=WI.fillTextValue("sy_from")%>&sy_to=<%=WI.fillTextValue("sy_to")%>&semester=<%=WI.fillTextValue("semester")%>"><img src="../../../images/cancel.gif" border="0"></a>click to cancel/clear 
        entries </font></td>
    </tr>
    <tr>
      <td height="22" colspan="2"><div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
	  <a href="#" style="text-decoration:none"><font color="#0000FF" size="1">Click for additional search condtion</font></a></div></td>
    </tr>
<%}//if iAccessLevel > 1%>
    <tr>
      <td height="22" colspan="2" align="center">
<span class="branch" id="branch1"> 
	  <table width="90%" cellpadding="0" cellspacing="0" border="0" class="thinborderALL">
        <tr>
          <td width="15%" height="22">Course</td>
          <td><select name="course_index" style="font-size:10px;">
              <option value="">ALL</option>
              <%
	strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and is_offered=1 order by course_code asc";
%>
              <%=dbOP.loadCombo("course_index","course_code+' ::: '+course_name",strTemp,
				  	WI.fillTextValue("course_index"), false)%>
          </select></td>
        </tr>
        <tr>
          <td height="22">Year Leve l</td>
          <td><select name="year_level">
              <option value="">ALL</option>
              <%
boolean bolIsSelected = false;
strTemp = WI.fillTextValue("year_level");
if(strTemp.length() == 0) 
	bolIsSelected = true;

if(bolIsSelected)
	strErrMsg = "";
else if(strTemp.equals("1")) {
	strErrMsg = " selected";
	bolIsSelected = true;
}
else	
	strErrMsg = "";
%>
              <option value="1"<%=strErrMsg%>>1st</option>
              <%
if(bolIsSelected)
	strErrMsg = "";
else if(strTemp.equals("2")) {
	strErrMsg = " selected";
	bolIsSelected = true;
}
else	
	strErrMsg = "";
%>
              <option value="2"<%=strErrMsg%>>2nd</option>
              <%
if(bolIsSelected)
	strErrMsg = "";
else if(strTemp.equals("3")) {
	strErrMsg = " selected";
	bolIsSelected = true;
}
else	
	strErrMsg = "";
%>
              <option value="3"<%=strErrMsg%>>3rd</option>
              <%
if(bolIsSelected)
	strErrMsg = "";
else if(strTemp.equals("4")) {
	strErrMsg = " selected";
	bolIsSelected = true;
}
else	
	strErrMsg = "";
%>
              <option value="4"<%=strErrMsg%>>4th</option>
              <%
if(bolIsSelected)
	strErrMsg = "";
else if(strTemp.equals("5")) {
	strErrMsg = " selected";
	bolIsSelected = true;
}
else	
	strErrMsg = "";
%>
              <option value="5"<%=strErrMsg%>>5th</option>
              <%
if(bolIsSelected)
	strErrMsg = "";
else if(strTemp.equals("6")) {
	strErrMsg = " selected";
	bolIsSelected = true;
}
else	
	strErrMsg = "";
%>
              <option value="6"<%=strErrMsg%>>6th</option>
          </select>
		  &nbsp;&nbsp; TC Date Range : 
	<input name="tc_date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("tc_date_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.tc_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
		&nbsp;&nbsp;&nbsp;
	<input name="tc_date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("tc_date_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.tc_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
				  

		  
		  </td>
        </tr>
        <tr>
          <td width="15%" height="22">Appl. Stat</td>
          <td>
	<select name="application_stat_search">
		<option value=""></option>
<%
strTemp = WI.fillTextValue("application_stat_search");
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="3"<%=strErrMsg%>>Granted TC</option>
<%
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="1"<%=strErrMsg%>>For Interview</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="2"<%=strErrMsg%>>Returned</option>
<%
if(strTemp.equals("0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="0"<%=strErrMsg%>>Cancelled</option>
		</select>
		  </td>
        </tr>

        <tr>
          <td>Sort by </td>
          <td><select name="sort_by1" style="font-size:10px">
              <option value="">N/A</option>
              <%=constructSearch.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
            </select>
              <select name="sort_by1_con" style="font-size:10px">
                <option value="asc">Asc</option>
                <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
                <option value="desc" selected>Desc</option>
                <%}else{%>
                <option value="desc">Desc</option>
                <%}%>
              </select>
            and
            <select name="sort_by2" style="font-size:10px">
              <option value="">N/A</option>
              <%=constructSearch.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
            </select>
            <select name="sort_by2_con" style="font-size:10px">
              <option value="asc">Asc</option>
              <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
              <option value="desc" selected>Desc</option>
              <%}else{%>
              <option value="desc">Desc</option>
              <%}%>
            </select>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href='javascript:ReloadPage();'><img src="../../../images/refresh.gif" border="0"></a></td>
        </tr>
<%if(!bolIsCGH && !bolIsSACI){%>
        <tr>
          <td>&nbsp;</td>
          <td>
<%
strTemp = WI.fillTextValue("inc_dropout");
if(strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>		  <input type="checkbox" name="inc_dropout" value="1"<%=strTemp%>>
            <font color="#0000FF"><strong>Include Dropout student in this list</strong></font></td>
        </tr>
<%}%>
      </table>
<!--- Show or hide --->
</span>
	  <div align="right">
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>Click to print report	  </div>	  </td>
    </tr>
    <tr>
      <td height="22" colspan="2">&nbsp; In Printing : &nbsp;&nbsp;&nbsp;
<%
strTemp = WI.fillTextValue("hide_reason");
if(strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input name="hide_reason" type="checkbox" value="1"<%=strTemp%>>Hide Reason &nbsp;&nbsp;&nbsp;
<%
strTemp = WI.fillTextValue("hide_encodedby");
if(strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input name="hide_encodedby" type="checkbox" value="1"<%=strTemp%>>Hide Encoded By 
&nbsp;&nbsp;
<%
strTemp = WI.fillTextValue("hide_lastA");
if(strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input name="hide_lastA" type="checkbox" value="1"<%=strTemp%>>Hide Last Attendance</td>
    </tr>
  </table>
<%}//show only if not called for printing.
else{///print heading. %>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
  <tr>
    <td colspan="2"><div align="center">
        <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <!-- Martin P. Posadas Avenue, San Carlos City -->
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%>
          <!-- Pangasinan 2420 Philippines -->
          <br>
          <!-- Tel Nos. (075) 532-2380; (075) 955-5054 FAX No. (075) 955-5477 -->
          <%=WI.getStrValue(SchoolInformation.getAddressLine3(dbOP,false,false),"","<br>","")%>
          <strong><!-- REGION I -->
          <%=WI.getStrValue(SchoolInformation.getInfo2(dbOP,false,false),"","<br>","")%></strong>
          <strong><%=dbOP.getHETerm(Integer.parseInt(request.getParameter("semester")))%></strong>, Academic Year <strong><%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></strong> </div>
		  <br>
	  </td>
  </tr>
</table>



<%}//end of printing heading. 
String[] astrConvertToSem = {"SU","FS","SS","TS",""};

boolean bolHideReason    = false;
boolean bolHideEncodedBy = false;
boolean bolHideLA        = false;//hide last attendance.
if(WI.fillTextValue("hide_reason").length() > 0)
	bolHideReason = true;
if(WI.fillTextValue("hide_encodedby").length() > 0)
	bolHideEncodedBy = true;
if(WI.fillTextValue("hide_lastA").length() > 0)
	bolHideLA = true;

if(vRetResult != null && vRetResult.size() > 0) {
Vector vDropoutList = null;
if(WI.fillTextValue("inc_dropout").length() > 0) 
	vDropoutList = (Vector)vRetResult.remove(0);
if(!bolIsSACI){//show if not saci.. %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFF9F"> 
      <td height="23" colspan="11" class="thinborder"><font color="#0000FF"><strong>
	  Total Student(s) with TC: <%=vRetResult.size()/20%></strong></font></td>
    </tr>
<%if(vRetResult.size() > 0){%>
    <tr>
      <td width="5%" class="thinborder" style="font-size:9px; font-weight:bold">SL # </td> 
      <td width="10%" height="23" class="thinborder"><div align="center"><font size="1"><strong>STUDENT ID</strong></font></div></td>
      <td width="15%" class="thinborder" align="center"><font size="1"><strong>NAME</strong></font></td>
      <td width="8%" class="thinborder" align="center"><font size="1"><b>ADMITTED</b></font></td>
<%if(!bolHideLA){%>
      <td width="8%" class="thinborder" align="center"><font size="1"><b>LAST ATTENDANCE</b></font></td>
<%}if(!bolHideReason){%>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>REASON</strong></font></div></td>
<%}if(!bolIsCGH){%>
      <td width="15%" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold">SCHOOL TO TRANSFER</span></td>
<%}%>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>TC 
          DATE</strong></font></div></td>
<%if(!bolHideEncodedBy){%>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>ENCODED BY </strong></font></div></td>
<%}if(!bolPrintPg){%>
      <td width="7%" class="thinborder">&nbsp;</td>
      <td width="8%" class="thinborder">&nbsp;</td>
<%}%>
    </tr>
<%}
for(int i = 0; i < vRetResult.size() ; i += 20){%>
    <tr>
      <td class="thinborder"><%=i/20 + 1%>.</td> 
      <td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 8)%></td>
      <td class="thinborder"><%=astrConvertToSem[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i + 12),"4"))]%><br>
        <%=WI.getStrValue((String)vRetResult.elementAt(i + 10),"","-"+(String)vRetResult.elementAt(i + 11),"")%></td>
<%if(!bolHideLA){%>
      <td class="thinborder"><%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("semester"))]%><br>
	  <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%></td>
<%}if(!bolHideReason){%>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
<%}if(!bolIsCGH){%>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 15),"&nbsp;")%></td>
<%}%>	  
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
<%if(!bolHideEncodedBy){%>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 9)%></td>
<%}if(!bolPrintPg){%>
      <td class="thinborder"> <%if(iAccessLevel > 1){%> <a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>);"><img src="../../../images/edit.gif" border="0"></a> 
        <%}%> </td>
      <td class="thinborder"> <%if(iAccessLevel == 2){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a> 
        <%}%> </td>
<%}//do not show if print page is called. %>
    </tr>
    <%}//end of for loop%>
  </table>
<%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFF9F"> 
      <td height="23" colspan="11" class="thinborder"><font color="#0000FF"><strong>Total Student(s) with TC: <%=vRetResult.size()/20%></strong></font></td>
    </tr>
<%if(vRetResult.size() > 0){%>
    <tr>
      <td width="5%" class="thinborder" style="font-size:9px; font-weight:bold">SL # </td> 
      <td width="10%" height="23" class="thinborder"><div align="center"><font size="1"><strong>STUDENT ID</strong></font></div></td>
      <td width="10%" class="thinborder" align="center"><font size="1"><strong>NAME</strong></font></td>
      <td width="10%" class="thinborder" align="center"><font size="1"><b>COURSE</b></font></td>
      <td width="10%" class="thinborder" align="center"><font size="1"><b>DATE FILED</b></font></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>DATE INTERVIEWED </strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>REASON</strong></font></div></td>
      <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">SCHOOL TO TRANSFER </td>
      <td width="5%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">STATUS</td>
<%if(!bolPrintPg){%>
      <td width="7%" class="thinborder">&nbsp;</td>
      <td width="8%" class="thinborder">&nbsp;</td>
<%}%>
    </tr>
<%}
Vector vSummary = new Vector(); int iIndexOf = 0; //int iCount = 0;
String[] astrConvetTCStat = {"Cancelled","For Interview","Returned","TC Granted",""};
for(int i = 0; i < vRetResult.size() ; i += 20){
strTemp = (String)vRetResult.elementAt(i + 19);
iIndexOf = vSummary.indexOf(strTemp);
if(iIndexOf == -1) {
	vSummary.addElement(strTemp);
	vSummary.addElement("1");
	
	if(vRetResult.elementAt(i + 14) == null)
		vSummary.addElement("0");
	else
		vSummary.addElement("1");
}
else {
	vSummary.setElementAt(Integer.toString(Integer.parseInt((String)vSummary.elementAt(iIndexOf + 1)) + 1), iIndexOf + 1);
	 if(vRetResult.elementAt(i + 14) != null)
		vSummary.setElementAt(Integer.toString(Integer.parseInt((String)vSummary.elementAt(iIndexOf + 2)) + 1), iIndexOf + 2);
}
%>
    <tr>
      <td class="thinborder"><%=i/20 + 1%>.</td> 
      <td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 8)%></td>
      <td class="thinborder"><%=strTemp%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 14),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 15),"&nbsp;")%></td>
      <td class="thinborder"><%=astrConvetTCStat[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i + 18),"4"))]%></td>
 <%if(!bolPrintPg){%>
      <td class="thinborder">&nbsp;<%if(iAccessLevel > 1){%> <a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>);"><img src="../../../images/edit.gif" border="0"></a><%}%></td>
      <td class="thinborder">&nbsp;<%if(iAccessLevel == 2){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a><%}%></td>
<%}%>
    </tr>
    <%}//end of for loop%>
  </table>
<!-- Summary -->
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="23" colspan="2" style="font-size:9px; font-weight:bold;">Summary</td>
    </tr>
	<tr>
	<td width="48%">
	  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  <td style="font-size:9px; font-weight:bold;" class="thinborder" align="center">Course</td>
		  <td height="20" style="font-size:9px; font-weight:bold;" class="thinborder" align="center">Filed</td>
		  <td style="font-size:9px; font-weight:bold;" class="thinborder" align="center">Interviewed</td>
		</tr>
		<%for(int i = 0; i < vSummary.size(); i += 6) {%>
			<tr>
			  <td style="font-size:9px;" class="thinborder" align="center"><%=vSummary.elementAt(i)%></td>
			  <td height="20" style="font-size:9px;" class="thinborder" align="center"><%=vSummary.elementAt(i + 1)%></td>
			  <td style="font-size:9px;" class="thinborder" align="center"><%=vSummary.elementAt(i + 2)%></td>
		  	</tr>
	  	<%}%>
	  </table>
	</td>
	<td width="4%">&nbsp;</td>
	<td width="48%" valign="top">
	  <%if(vSummary.size() > 3){%>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  <td height="20" style="font-size:9px; font-weight:bold;" class="thinborder" align="center">Course</td>
		  <td style="font-size:9px; font-weight:bold;" class="thinborder" align="center">Filed</td>
		  <td style="font-size:9px; font-weight:bold;" class="thinborder" align="center">Interviewed</td>
		</tr>
		<%for(int i = 3; i < vSummary.size(); i += 6) {%>
			<tr>
			  <td style="font-size:9px;" class="thinborder" align="center"><%=vSummary.elementAt(i)%></td>
			  <td height="20" style="font-size:9px;" class="thinborder" align="center"><%=vSummary.elementAt(i + 1)%></td>
			  <td style="font-size:9px;" class="thinborder" align="center"><%=vSummary.elementAt(i + 2)%></td>
		  	</tr>
	  	<%}%>
	  </table>
	  <%}//show if size of vector > 1%>
	</td>
    </tr>
  </table>

<%}///show only if SACI.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr><td>&nbsp;</td></tr>
  </table>
<%
//I have to display Drop out student list. 
if(vDropoutList != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFF9F"> 
      <td height="23" colspan="2" class="thinborder"><font color="#0000FF"><strong>
	  Total Student(s) Droppedout: <%=vDropoutList.size()/3%></strong></font></td>
    </tr>
<%if(vDropoutList.size() > 0) {%>
    <tr> 
      <td width="36%" height="23" class="thinborder"><div align="center"><font size="1"><strong>STUDENT ID</strong></font></div></td>
      <td width="64%" class="thinborder"><div align="center"><font size="1"><strong>NAME</strong></font></div></td>
    </tr>
<%}
for(int i = 0; i < vDropoutList.size() ; i += 3){%>
    <tr> 
      <td class="thinborder" height="22"><%=(String)vDropoutList.elementAt(i + 1)%></td>
      <td class="thinborder"><%=(String)vDropoutList.elementAt(i + 2)%></td>
    </tr>
    <%}//end of for loop%>
  </table>
<%}//vDropoutList is not null.
}//end of if vRetResult is not null.%>

<%
if(!bolPrintPg){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<%}else{%>
<!-- print here. -->
<script language="javascript">
 window.print();
</script>
<%}%>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>