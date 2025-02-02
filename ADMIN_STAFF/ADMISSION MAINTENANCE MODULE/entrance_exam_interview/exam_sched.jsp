<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript">
function FillScore()
{
	var selIndex = document.form_.exam_index.selectedIndex;
	if(selIndex == "0") {
		document.form_.max_scr.value = "";
		document.form_.pass_scr.value = "";
		return;
	}
	document.form_.max_scr.value = eval('document.form_.score1'+selIndex+'.value');
	document.form_.pass_scr.value = eval('document.form_.score2'+selIndex+'.value');
}
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function TypeCreate()
{
	var pgLoc = "../entrance_exam_interview/subtype_create.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() {
	location = "./exam_sched.jsp?sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value+"&semester="+document.form_.semester.value;
}
function ReloadPage()
{
    document.form_.page_action.value="";
	this.SubmitOnce('form_');
}
function PrintPg() {
	//remove unwanted rows.
	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable1').deleteRow(0);document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	
	var vMaxDisp = document.form_.max_disp.value;
	for(i =0; i < eval(vMaxDisp); ++i) {
		eval('document.form_.hide_0'+i+'.src=\"../../../images/blank.gif\"');
		eval('document.form_.hide_1'+i+'.src=\"../../../images/blank.gif\"');
	}
	
	alert("Click OK to Print.");
	window.print();
}
function OpenSearch()
{
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.contact_person";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AjaxLoadSchCode() {
		var objCOAInput = document.getElementById("load_schcode");
		if(!objCOAInput)
			return;
			
		var strExamNameIndex = document.form_.load_sch[document.form_.load_sch.selectedIndex].value;
		if(strExamNameIndex.length == 0) {
			objCOAInput.innerHTML = "";
			return;
		}		

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?all=1&methodRef=111&exam_name="+strExamNameIndex+
		"&sel_name=sch_code&sy_from="+document.form_.sy_from.value+"&semester="+
		document.form_.semester[document.form_.semester.selectedIndex].value;
		if(document.form_.show_valid.checked)
			strURL += "&show_valid=1";

		this.processRequest(strURL);
}
function onchange() {
	//.. do nothing..
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	Vector vRetResult = null;
	Vector vExamName  = null;
	Vector vEditInfo  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	String strPrepareToEdit = null;
	boolean bolErrorInEdit = false;
	int iMaxDisp = 0;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";
			
	boolean bolCIT = strSchCode.startsWith("CIT");
	int iTemp = 0;
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-ENTRANCE EXAM/INTERVIEW","exam_sched.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission Maintenance","ENTRANCE EXAM/INTERVIEW",request.getRemoteAddr(),
														"exam_sched.jsp");
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
	ApplicationMgmt appMgmt = new ApplicationMgmt();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(appMgmt.operateOnExamSched(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strPrepareToEdit = "0";
			strErrMsg = appMgmt.getErrMsg();
			//strErrMsg = "Operation successful.";
		}
		else {
			strErrMsg = appMgmt.getErrMsg();
			if(strTemp.compareTo("2") == 0) 
				bolErrorInEdit = true;
		}
	}
	if(strPrepareToEdit.compareTo("1") == 0 && !bolErrorInEdit) {
		vEditInfo = appMgmt.operateOnExamSched(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = appMgmt.getErrMsg();
	}
	//view all 
	
	vRetResult = appMgmt.operateOnExamSched(dbOP, request, 4);
%>
<form name="form_" action="./exam_sched.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><strong><font color="#FFFFFF">:::: 
          ENTRANCE EXAMINATION/INTERVIEW SCHEDULING PAGE::::</font></strong></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%> </strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>School Year /Term</td>
      <td colspan="2"> <% strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %> <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%  strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %> <input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
        / 
        <select name="semester">
          <% strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected=>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  
		  if (!strSchCode.startsWith("CPU")) {
			  if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  }
		  %>
        </select> <a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a> 
        <font size="1">display the exam schedules for this SY. </font></td>
    </tr>
    <tr> 
      <td height="10" colspan="4"> <hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Schedule for</td>
      <td colspan="2"> <select name="exam_index" onChange="javascript:FillScore()">
          <option value="">Select a schedule</opiton> 
          <% if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(4);
		else	
			strTemp = WI.fillTextValue("exam_index");
				
	  	vExamName = appMgmt.retreiveName(dbOP, request);
	  	if(vExamName != null && vExamName.size() > 0) {
		  for(int i = 0, j=0 ; i< vExamName.size(); i +=6,++j){ 
			if( strTemp.compareTo((String)vExamName.elementAt(i)) == 0) {%>
          <option value="<%=(String)vExamName.elementAt(i)%>" selected><%=(String)vExamName.elementAt(i+3)%></option>
          <%}else{%>
          <option value="<%=(String)vExamName.elementAt(i)%>"><%=(String)vExamName.elementAt(i+3)%></option>
          <%} //else
				}//for
		   }//if%>
        </select> <%
				for(int i = 0, j=1 ;vExamName != null && i< vExamName.size(); i +=6,++j){%> <input name="score1<%=j%>" value="<%=(String)vExamName.elementAt(i+4)%>" type="hidden"> 
        <input name="score2<%=j%>" value="<%=(String)vExamName.elementAt(i+5)%>" type="hidden"> 
        <%	}//end of for%> <a href="javascript:TypeCreate();"><img src="../../../images/update.gif" border="0"></a>      </td>
    </tr>
    <tr> 
      <td height="10" colspan="4"> <hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Schedule Code</td>
      <td colspan="2"> <%	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(5);
			else	
				strTemp = WI.fillTextValue("exam_code");  %> <input name="exam_code" type="text" size="16" maxlength="32"
	  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Duration</td>
      <td colspan="2"> <% if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(6);
		else	
			strTemp = WI.fillTextValue("dur_in_min");  %> <input name="dur_in_min" type="text" class="textbox" value="<%=strTemp%>" size="4" maxlength="4"
	   onKeyUp= 'AllowOnlyInteger("form_","dur_in_min")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","dur_in_min");style.backgroundColor="white"' >
        (in mins)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date</td>
      <% if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(7);
		else	
			strTemp = WI.fillTextValue("exam_date");  %>
      <td colspan="2"> <input name="exam_date" type="text" class="textbox" size="10" maxlength="10" value="<%=strTemp%>" readonly="yes"> 
        <a href="javascript:show_calendar('form_.exam_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td>Start Time </td>
      <td colspan="2"> <select name="start_hr">
          <% if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(8);
			else	
				strTemp = WI.fillTextValue("start_hr");
		  	iTemp = Integer.parseInt(WI.getStrValue(strTemp,"9"));
		for(int i = 1 ; i<=12; ++i) {
		if (iTemp == i){%>
          <option value="<%=i%>" selected>
          <%if(i < 10){%>
          0
          <%}%>
          <%=i%></option>
          <%}else{%>
          <option value="<%=i%>">
          <%if(i < 10){%>
          0
          <%}%>
          <%=i%></option>
          <%}}%>
        </select> <select name="start_min">
          <%	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(9);
			else	
				strTemp = WI.fillTextValue("start_min");
	  	iTemp = Integer.parseInt(WI.getStrValue(strTemp,"0"));
		for(int i = 0 ; i<=55; i += 5) {
		if (iTemp == i){%>
          <option value="<%=i%>" selected>
          <%if(i < 10){%>
          0
          <%}%>
          <%=i%></option>
          <%}else{%>
          <option value="<%=i%>">
          <%if(i < 10){%>
          0
          <%}%>
          <%=i%></option>
          <%}}%>
        </select> <select name="start_ampm">
          <% if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(10);
			else	
				strTemp = WI.fillTextValue("start_ampm");
			if(strTemp.compareTo("1") == 0)	{%>
          <option value="0">AM</option>
          <option value="1" selected >PM</option>
          <%}else{%>
          <option value="0" selected>AM</option>
          <option value="1">PM</option>
          <%}%>
        </select>
        (hour,min,AM/PM)</td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="20%">Venue</td>
      <td width="30%"> <% if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(12);
			else	
				strTemp = WI.fillTextValue("venue"); %> <input type="text" name="venue" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>Maximum Capacity : 
        <% if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(17);
			else	
				strTemp = WI.fillTextValue("max_cap");  %> <input name="max_cap" type="text" class="textbox" value="<%=strTemp%>" size="4" maxlength="4"
        onKeyUp= 'AllowOnlyInteger("form_","max_cap")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","max_cap");style.backgroundColor="white"' ></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Contact Person(ID)</td>
      <td valign="bottom"> <% if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(13);
			else	
				strTemp = WI.fillTextValue("contact_person");	%> <input name="contact_person" type="text" size="32" maxlength="64" value="<%=strTemp%>" 
	    class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td valign="bottom"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" hspace="0" vspace="0" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Contact Info</td>
      <td colspan="2" valign="bottom"> <% if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(14);
			else	
				strTemp = WI.fillTextValue("contact_info");	%> <input name="contact_info" type="text" size="32" value="<%=strTemp%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Maximum Score/ Rate </td>
      <td colspan="2" valign="bottom"> <%
			
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(15);
else	
	strTemp = WI.fillTextValue("max_scr"); 
	
	if (strSchCode.startsWith("CPU")) { %>
	<input name="max_scr" type="text" class="textbox" value="<%=strTemp%>" size="4" readonly="yes" > 
	<%}else{%> 
	<input name="max_scr" type="text" class="textbox" value="<%=strTemp%>" size="4" maxlength="4" 
		onKeyUp= 'AllowOnlyInteger("form_","max_scr")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","max_scr");style.backgroundColor="white"' > 
	<%}%>      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Passing Score/ Rate </td>
      <td colspan="2" valign="bottom"> <% if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(16);
		else	
			strTemp = WI.fillTextValue("pass_scr"); 

		if (strSchCode.startsWith("CPU")) { %>			
		<input name="pass_scr" type="text"  class="textbox" value="<%=strTemp%>" size="4"
			readonly = "yes" > 
		<%}else{%> 
		<input name="pass_scr" type="text"  class="textbox" value="<%=strTemp%>" size="4" maxlength="4"
        onKeyUp= 'AllowOnlyInteger("form_","pass_scr")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","pass_scr");style.backgroundColor="white"' > 
		<%}%>      </td>
    </tr>
    <%
if(vExamName != null && vExamName.size() > 0) {%>
    <tr> 
      <td height="43">&nbsp;</td>
      <td height="43">&nbsp;</td>
      <td height="43" colspan="2" valign="bottom"><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to clear entries </font></td>
    </tr>
    <%}%>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10" colspan="4" align="center">
	  	<table width="90%" cellpadding="0" cellspacing="0" class="thinborderALL" bgcolor="#CCCCCC">
			<tr>
			  <td width="29%" height="10" align="center" style="font-size:11px; color:#0000FF; font-weight:bold"><u>Search Filter</u> </td>
			  <td width="71%" style="font-size:11px; color:#0000FF;">Schedule For :			  
				  <%if(vExamName != null && vExamName.size() > 0) {%>
				  <select name="load_sch" onChange="AjaxLoadSchCode();" style="font-size:10px;">
				  <option value="">Select a schedule</opiton> 
				  <%for(int i = 0 ; i< vExamName.size(); i +=6){ %>
					<option value="<%=(String)vExamName.elementAt(i)%>"><%=(String)vExamName.elementAt(i+3)%></option>
				  <%}%>
				</select> 
			  	<%}%>
			  </td>
			</tr>
			<tr>
			  <td height="10" style="font-size:11px; color:#0000FF;">
			  <%
			  strTemp = WI.fillTextValue("show_valid");
			  if(strTemp.equals("1"))
			  	strErrMsg = "checked";
			else
				strErrMsg = "";
			  
			  if(bolCIT || true)
			  	 strErrMsg = "checked";
			  %>
			  <input name="show_valid" type="checkbox" value="1" <%=strErrMsg%>> Show Only Valid Schedule </td>
			  <td style="font-size:11px; color:#0000FF;">Schedule Code : <label id="load_schcode"></label>
			  </td>
			</tr>
			
		</table>
	  </td>
    </tr>
  </table>
<% if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr> 
      <td height="23" align="right"> <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">Print this page.</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="23" colspan="9" class="thinborder"><div align="center"><strong><font color="#FFFFFF" size="1">LIST 
          OF EXAMINATION/INTERVIEW SCHEDULES FOR AY : <%=WI.fillTextValue("sy_from") + " - "+WI.fillTextValue("sy_to")+" , "+
		  dbOP.getHETerm(Integer.parseInt(WI.getStrValue(request.getParameter("semester"),"-1"))).toUpperCase()%></font></strong></div></td>
    </tr>
    <tr> 
      <td width="12%" height="20" class="thinborder"><div align="center"><strong><font size="1">SCHEDULING 
          TYPE</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">SCHEDULE 
          CODE</font></strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong><font size="1">DURATION 
          (MIN)</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><b><font size="1">DATE</font></b></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">START 
          TIME</font></strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><b>VENUE</b></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><b>CONTACT 
          INFORMATION</b></font></div></td>
      <td width="4%" align="center" class="thinborder">&nbsp;</td>
      <td width="3%" align="center" class="thinborder">&nbsp;</td>
    </tr>
    <%
	String [] astrConvType={"Written","Interview"};
	String [] astrConvTime={" AM"," PM"};
for(int i = 0 ; i< vRetResult.size(); ++i, ++iMaxDisp)
{%>
    <tr> 
      <td class="thinborder"><div align="center"><%=astrConvType[Integer.parseInt((String)vRetResult.elementAt(i + 18))]%> ::: <%=(String)vRetResult.elementAt(i+19)%></div></td>
      <td class="thinborder"><div align="center"><%=((String)vRetResult.elementAt(i+5))%></div></td>
      <td class="thinborder"><div align="center"><%=((String)vRetResult.elementAt(i+6))%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+7)%></div></td>
      <td class="thinborder"><div align="center"><%=CommonUtil.formatMinute((String)vRetResult.elementAt(i+8))+':'+
	  CommonUtil.formatMinute((String)vRetResult.elementAt(i+9))+astrConvTime[Integer.parseInt((String)vRetResult.elementAt(i + 10))]%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+12)%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+13)%> <br>
          <font color="#0000FF"><%=(String)vRetResult.elementAt(i+14)%></font></div></td>
      <td align="center" class="thinborder"> <font size="1"> 
        <%  if(iAccessLevel ==2 || iAccessLevel == 3){  %>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0" id="hide_0<%=iMaxDisp%>"></a> 
        <%}else{%>
        Not authorized to edit 
        <%}%>
        </font></td>
      <td align="center" class="thinborder"> <font size="1"> 
        <% if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0" id="hide_1<%=iMaxDisp%>"></a> 
        <%}else{%>
        Not authorized to delete 
        <%}%>
        </font></td>
    </tr>
    <%
	i = i+19;
}%>
  </table>
  
 <%}//if vRetResult != null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
    <input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
    <input name="strExIndex" type="hidden">
    <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
    <input type="hidden" name="page_action" >
	<input type="hidden" name="max_disp" value="<%=iMaxDisp%>">
</form>
</body>
</html>
<% dbOP.cleanUP();
%>