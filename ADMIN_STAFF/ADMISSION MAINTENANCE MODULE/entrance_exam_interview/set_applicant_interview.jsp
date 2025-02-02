<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Exam Result Encoding </title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	document.form_.print_page.value = "";
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.page_action.value="";
	document.form_.show_list.value ="1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function CheckAll()
{
	document.form_.print_page.value = "";
	var iMaxDisp = document.form_.max_display.value;
	if (iMaxDisp.length == 0)
		return;
	if (document.form_.selAll.checked ){
		for (var i = 0 ; i < eval(iMaxDisp); ++i )
			eval('document.form_.checkbox'+i+'.checked=true');
	}
	else
		for (var i = 0 ; i < eval(iMaxDisp);++i)
			eval('document.form_.checkbox'+i+'.checked=false');

}


function PrintPage(){
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}
</script>
<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,java.util.Vector"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	if(WI.fillTextValue("print_page").compareTo("1") == 0){%>

		<jsp:forward page="./set_applicant_interview_print.jsp"/>

<%return;}

	Vector vRetResult = null;
	Vector vSchedData = null;
	String strErrMsg = null;
	String strTemp = null;
	int iCount = 0;
	int iCount2 = 1;

	String[] astrRemarks = {"Failed","Passed"};
	int iEncoded = 1;
	String strSchCode  = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-ENTRANCE EXAM/INTERVIEW",
								"exam_interview_encode_result.jsp");
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
														"Admission Maintenance","ENTRANCE EXAM/INTERVIEW",
														request.getRemoteAddr(),"exam_interview_encode_result.jsp");
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
		if(appMgmt.operateOnInterview(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = appMgmt.getErrMsg();
	}
	//view all
	if (WI.fillTextValue("show_list").equals("1")){
		vRetResult = appMgmt.operateOnInterview(dbOP, request, 4);
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./set_applicant_interview.jsp" method="post">

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="table1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center">
      <font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif" ><strong>::::
          RESULT ENCODING  PAGE::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="table2">
    <tr>
      <td height="25" colspan="4"> &nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr>
      <td width="6%" height="25">&nbsp;</td>
      <td width="20%">School Year / Term</td>
      <td colspan="2"> <% strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %>
	<input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
        <%  strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %>
	<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
    <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 )
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
          <%}

		  if (!strSchCode.startsWith("CPU")) {

		  if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  }
		  %>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>List Option </td>
      <td width="28%">
        <select name="view_set">
<%
	strTemp = WI.fillTextValue("view_set");
	if(strTemp.equals("0")){%>
          <option value="0" selected>Set Interview Schedule</option>
          <%}else{%>
          <option value="0">Set Interview Schedule</option>
          <%}if(strTemp.equals("1")){%>
          <option value="1" selected>Set Interview Result</option>
          <%}else{%>
          <option value="1">Set Interview Result</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>Set Subject To Take</option>
          <%}else{%>
          <option value="2">Set Subject To Take</option>
          <%} %>


        </select></td>
      <td width="46%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<%
	if (vRetResult != null  && WI.fillTextValue("view_set").equals("0")) {
		if (vRetResult.size() > 0 ) {
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="23" colspan="5" align="center" class="thinborder"><strong><font color="#FFFFFF">SCHEDULE APPLICANTS FOR INTERVIEW</font></strong> </td>
    </tr>

    <tr>
      <td height="50" colspan="5" align="center" class="thinborder">DATE OF INTERVIEW :
    <input type="text"  class="textbox" onBlur="style.backgroundColor='white'" readonly maxlength="10" name="date_interview" size="10"
	onFocus= "style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyIntegerExtn('form_','date_interview','/')"	
	value="<%=WI.fillTextValue("date_interview")%>" >&nbsp;
	  <a href="javascript:show_calendar('form_.date_interview');"
	  title="Click to select date" onMouseOver="window.status='Select date';return true;"
	  onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif"
	  border="0"></a>
		&nbsp;&nbsp;TIME OF INTERVIEW :
      <input name="hh" type="text" size="2" maxlength="2" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	onKeyUp= "AllowOnlyInteger('form_','hh')">
:
	<input name="mm" type="text" size="2" maxlength="2" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	onKeyUp= "AllowOnlyInteger('form_','mm')">&nbsp;&nbsp;
	<select name="am_pm">
		<option value="0"> AM </option>
	<%if (WI.fillTextValue("am_pm").equals("1")) {%>
		<option value="1" selected> PM </option>
	<%}else{%>
		<option value="1"> PM </option>
	<%}%>
	</select>	</td>
    </tr>

    <tr>
      <td width="7%" align="center" class="thinborder"><strong>
      NO.</strong></td>
      <td width="20%" height="25" align="center" class="thinborder"><strong>
      TEMPORARY /<br>
      APPLICANT ID</strong></td>
      <td width="53%" align="center" class="thinborder"><strong>
      APPLICANT NAME</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>COURSE</strong></td>
      <b> </b>
      <td align="center" class="thinborder"><b>SELECT </b> <br>
        <input type="checkbox" name="selAll" value="0" onClick="CheckAll();"></td>
    </tr>
    <%
		for(int t = 0 ; t < vRetResult.size(); t+=10){

   	%>
    <tr>
	  <td height="25" align="right" class="thinborder">
  	  <%=iCount + 1%><input type="hidden" name="user_index<%=iCount%>"
	  		value="<%=(String)vRetResult.elementAt(t)%>">&nbsp;	  </td>
      <td class="thinborder">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(t+1)%></td>
      <td class="thinborder">&nbsp;
        <%=WI.formatName((String)vRetResult.elementAt(t+2),(String)vRetResult.elementAt(t+3),(String)vRetResult.elementAt(t+4),4)%></td>
      <td class="thinborder">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(t+9)%></td>
      <td width="16%" align="center" class="thinborder">
      <input type="checkbox" name="checkbox<%=iCount++%>" value="1"></td>
    </tr>
    <%}%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" align="center"><a href='javascript:PageAction(1);'>
        <img src="../../../images/save.gif"  border=0></a>
          <font size="1"> click to save selected entries&nbsp;</font></td>
    </tr>
  </table>
<% }
	vSchedData = appMgmt.operateOnInterview(dbOP, request, 4,true);

	if ( vSchedData != null) {
	String strDateInterview = "";
	String strTimeInterview = "";
	for (int t = 0; t < vSchedData.size();) {

		if (t == 0) {
			strDateInterview = WI.getStrValue((String)vSchedData.elementAt(t+5));
			strTimeInterview = WI.getStrValue((String)vSchedData.elementAt(t+6));
		}

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFFFF">
      <td height="23">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
 <% if (t == 0) {%>
    <tr bgcolor="#B9B292">
      <td height="23" colspan="4" align="center" class="thinborder"><strong>SCHEDULED APPLICANTS FOR INTERVIEW</strong>   </td>
    </tr>
 <%}%>
    <tr>
      <td height="28" colspan="2" class="thinborder">
	  <input type="checkbox" name="_<%=t%>" value="1">
	  
	  <strong>&nbsp;&nbsp;<font size="3">DATE   :
	  			<font color="#FF0000"><%=strDateInterview%>   </font></font></strong></td>
      <td height="28" colspan="2" class="thinborder"><font size="3"><strong>TIME :</strong> <strong><font color="#FF0000"><%=strTimeInterview%> </font></strong></font></td>
    </tr>
    <tr>
      <td width="7%" align="center" class="thinborder"><strong>
      NO.</strong></td>
      <td width="21%" height="25" align="center" class="thinborder"><strong>
      TEMPORARY /<br>
      APPLICANT ID</strong></td>
      <td width="60%" align="center" class="thinborder"><strong>
      APPLICANT NAME</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>COURSE</strong></td>
    <b> </b>    </tr>
<%  strDateInterview += " :: " + strTimeInterview;

	for(; t < vSchedData.size(); t+=10){

		if (!strDateInterview.equals(WI.getStrValue((String)vSchedData.elementAt(t+5))
							+ " :: " + 	 WI.getStrValue((String)vSchedData.elementAt(t+6)))) {

			strDateInterview = WI.getStrValue((String)vSchedData.elementAt(t+5));
			strTimeInterview = WI.getStrValue((String)vSchedData.elementAt(t+6));
			break;
		}
%>
    <tr>
	  <td height="25" align="right" class="thinborder">
  	  <%=iCount2++%><input type="hidden" name="user_index<%=iCount%>"
	  		value="<%=(String)vSchedData.elementAt(t)%>">&nbsp;	  </td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=(String)vSchedData.elementAt(t+1)%></td>
      <td class="thinborder">&nbsp;
        <%=WI.formatName((String)vSchedData.elementAt(t+2),(String)vSchedData.elementAt(t+3),
							(String)vSchedData.elementAt(t+4),4)%></td>
      <td class="thinborder">&nbsp;&nbsp;<%=(String)vSchedData.elementAt(t+9)%></td>
    </tr>
    <%}%>
  </table>
<%
  }
%>
<!--
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" align="center"><a href='javascript:PageAction(7);'>
        <img src="../../../images/delete.gif"  border=0></a>
          <font size="1"> click to save selected entries&nbsp;</font></td>
    </tr>
  </table>
-->
    <%
   }
 }  if (vRetResult != null && WI.fillTextValue("view_set").equals("1")) {

	String strDateInterview = "";
	for (int t = 0; t < vRetResult.size();) {

		if (t == 0)
			strDateInterview = WI.getStrValue((String)vRetResult.elementAt(t+5)) + " :: " +
					WI.getStrValue((String)vRetResult.elementAt(t+6));
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
 <% if (t == 0) {%>
    <tr bgcolor="#B9B292">
      <td height="23" colspan="6" align="center" class="thinborder"><strong><font color="#FFFFFF"> APPLICANTS FOR INTERVIEW</font></strong> </td>
    </tr>
 <%}%>
    <tr>
      <td height="28" colspan="6" class="thinborder"><strong>&nbsp;&nbsp;DATE / TIME OF INTERVIEW :
	  			<font color="#FF0000"><%=strDateInterview%>	    </font></strong></td>
    </tr>
    <tr>
      <td width="7%" align="center" class="thinborder"><strong>
      NO.</strong></td>
      <td width="17%" height="25" align="center" class="thinborder"><strong>
      TEMPORARY /<br>
      APPLICANT ID</strong></td>
      <td width="54%" align="center" class="thinborder"><strong>APPLICANT NAME</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>COURSE</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>PASSED</strong></td>
      <b> </b>
      <td align="center" class="thinborder">
	 <% if (t == 0) {%>
	  <b>SELECT </b> <br>
        <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">
	 <%}else{%>
	 	&nbsp;
	 <%}%>	  </td>
    </tr>
<%
	for(; t < vRetResult.size(); t+=10){

		if (!strDateInterview.equals(WI.getStrValue((String)vRetResult.elementAt(t+5)) + " :: " +
									 WI.getStrValue((String)vRetResult.elementAt(t+6)))) {

			strDateInterview = WI.getStrValue((String)vRetResult.elementAt(t+5)) + " :: " +
					WI.getStrValue((String)vRetResult.elementAt(t+6));
			break;
		}
%>
    <tr>
	  <td height="25" align="right" class="thinborder">
  	  <%=iCount+1%><input type="hidden" name="user_index<%=iCount%>"
	  		value="<%=(String)vRetResult.elementAt(t)%>">&nbsp;	  </td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=(String)vRetResult.elementAt(t+1)%></td>
      <td class="thinborder">&nbsp;
        <%=WI.formatName((String)vRetResult.elementAt(t+2),(String)vRetResult.elementAt(t+3),
							(String)vRetResult.elementAt(t+4),4)%></td>
      <td class="thinborder">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(t+9)%></td>
      <td align="center" class="thinborder">
	  	<input type="checkbox" name="pass_fail<%=iCount%>" value="1" checked>	  </td>
      <td width="12%" align="center" class="thinborder">
      <input type="checkbox" name="checkbox<%=iCount++%>" value="1">      </td>
    </tr>
    <%}%>
  </table>
<%
  } if (vRetResult != null && vRetResult.size() > 0) {
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" align="center"><a href='javascript:PageAction(7);'>
        <img src="../../../images/save.gif"  border=0></a>
          <font size="1"> click to save selected entries&nbsp;</font></td>
    </tr>
  </table>

<% }
	vSchedData = appMgmt.operateOnInterview(dbOP, request, 4,true);

	if ( vSchedData != null && vSchedData.size() > 0) {%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFFFF">
      <td height="23" colspan="3">&nbsp;</td>
    </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="23" colspan="4" align="center" class="thinborder"><strong><font color="#000000">APPLICANTS WHO PASSED THE INTERVIEW </font></strong></td>
    </tr>
    <tr>
      <td width="7%" align="center" class="thinborder"><strong>
      NO.</strong></td>
      <td width="16%" height="25" align="center" class="thinborder"><strong>
      TEMPORARY /<br>
      APPLICANT ID</strong></td>
      <td width="70%" align="center" class="thinborder"><strong>
      APPLICANT NAME</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>COURSE</strong></td>
    <b> </b>    </tr>
<%  for(int t = 0; t < vSchedData.size(); t+=10){ %>
    <tr>
	  <td height="25" align="right" class="thinborder">
  	  <%=iCount2++%>&nbsp;	  </td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=(String)vSchedData.elementAt(t+1)%></td>
      <td class="thinborder">&nbsp;
        <%=WI.formatName((String)vSchedData.elementAt(t+2),(String)vSchedData.elementAt(t+3),
							(String)vSchedData.elementAt(t+4),4)%></td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=(String)vSchedData.elementAt(t+9)%></td>
    </tr>
    <%}%>
  </table>
    <%
	 }
	}  if (vRetResult != null && WI.fillTextValue("view_set").equals("2")) {

		if (vRetResult.size() > 0) {
	%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="23" colspan="6" align="center" class="thinborder"><strong><font color="#FFFFFF">APPLICANTS LISTING FOR SUBJECT TO TAKE</font></strong></td>
    </tr>
    <tr>
      <td width="7%" align="center" class="thinborder"><strong>
      NO.</strong></td>
      <td width="17%" height="25" align="center" class="thinborder"><strong>
      TEMPORARY /<br>
      APPLICANT ID</strong></td>
      <td width="54%" align="center" class="thinborder"><strong>
      APPLICANT NAME</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>COURSE</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>SUBJECT TO TAKE </strong></td>
      <td align="center" class="thinborder">
	  <b>SELECT </b> <br>
        <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">  </td>
    </tr>
<%  for(int t = 0; t < vRetResult.size(); t+=10){ %>
    <tr>
	  <td height="25" align="right" class="thinborder">
  	  <%=iCount+1%><input type="hidden" name="user_index<%=iCount%>"
	  		value="<%=(String)vRetResult.elementAt(t)%>">&nbsp;	  </td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=(String)vRetResult.elementAt(t+1)%></td>
      <td class="thinborder">&nbsp;
        <%=WI.formatName((String)vRetResult.elementAt(t+2),(String)vRetResult.elementAt(t+3),
							(String)vRetResult.elementAt(t+4),4)%></td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=(String)vRetResult.elementAt(t+9)%></td>
      <td align="center" class="thinborder"><select name="subj_<%=iCount%>">
        <option value="0"> REG </option>
        <option value="1"> EE </option>
        <option value="2"> ME </option>
        <option value="3"> EE and ME </option>
      </select></td>
      <td width="12%" align="center" class="thinborder">
      <input type="checkbox" name="checkbox<%=iCount++%>" value="1">      </td>
    </tr>
    <%}%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" align="center"><a href='javascript:PageAction(8);'>
        <img src="../../../images/save.gif"  border=0></a>
          <font size="1"> click to save selected entries&nbsp;</font></td>
    </tr>
  </table>
<% }
	vSchedData = appMgmt.operateOnInterview(dbOP, request, 4,true);

	String[] astrSubj ={"REG","EE","ME","EE and ME"};
	if ( vSchedData != null) { %>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFFFF">
      <td height="23" colspan="3">&nbsp;</td>
    </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="23" colspan="5" align="center" class="thinborder"><strong><font color="#000000">APPLICANTS LISTING FOR SUBJECT TO TAKE</font></strong></td>
    </tr>
    <tr>
      <td width="7%" align="center" class="thinborder"><strong>
      NO.</strong></td>
      <td width="17%" height="25" align="center" class="thinborder"><strong>
      TEMPORARY /<br>
      APPLICANT ID</strong></td>
      <td width="54%" align="center" class="thinborder"><strong>
      APPLICANT NAME</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>COURSE</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>SUBJECT TO TAKE </strong></td>
    </tr>
<%  for(int t = 0; t < vSchedData.size(); t+=10){ %>
    <tr>
	  <td height="25" align="right" class="thinborder">
  	  <%=iCount2++%>&nbsp;	  </td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=(String)vSchedData.elementAt(t+1)%></td>
      <td class="thinborder">&nbsp;
        <%=WI.formatName((String)vSchedData.elementAt(t+2),(String)vSchedData.elementAt(t+3),
							(String)vSchedData.elementAt(t+4),4)%></td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=(String)vSchedData.elementAt(t+9)%></td>
      <td align="center" class="thinborder">&nbsp;
	  	<%=astrSubj[Integer.parseInt(WI.getStrValue((String)vSchedData.elementAt(t+7),"0"))]%></td>
    </tr>
    <%}%>
  </table>
 <%}%>
  <%} if (vSchedData != null && vSchedData.size() > 0){  %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="45%" height="30" align="right">&nbsp;</td>
      <td width="55%">&nbsp;</td>
    </tr>
    <tr>
      <td height="30" align="right">
	  Number of Applicants Per Page
        <select name="appl_per_page">
          <option>20</option>
          <option>25</option>
          <option>30</option>
          <option>35</option>
          <option>40</option>
          <option>45</option>
          <option>50</option>
        </select>
      &nbsp;</td>
      <td><a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a> <font size="1">click to print list</font></td>
    </tr>
  </table>
	<%} // show print.. %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>


<input type="hidden" name="page_action" >
<input type="hidden" name="change_exam_index">
<input type="hidden" name="print_page" value="">
<input type="hidden" name="show_list" value="<%=WI.fillTextValue("show_list")%>">
<input type="hidden" name="max_display" value="<%=iCount%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
