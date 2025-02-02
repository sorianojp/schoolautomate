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
function ChangeExamIndex()
{
	document.form_.NewType.value=document.form_.exam_index[document.form_.exam_index.selectedIndex].text;
	document.form_.NewCode.value="";
	document.form_.page_action.value="";
	document.form_.print_page.value = "";
	document.form_.change_exam_index.value="1";
	this.SubmitOnce('form_');
}
function CheckAll()
{
	document.form_.print_page.value = "";
	var iMaxDisp = document.form_.cEnc.value;
	if (iMaxDisp.length == 0)
		return;
	if (document.form_.selAll.checked ){
		for (var i = 1 ; i <= eval(iMaxDisp);++i)
			eval('document.form_.checkbox'+i+'.checked=true');
	}
	else
		for (var i = 1 ; i <= eval(iMaxDisp);++i)
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

		<jsp:forward page="exam_interview_encode_result_print.jsp"/>

<%return;}

	Vector vRetResult = null;
	Vector vSchedData = null;
	String strErrMsg = null;
	String strTemp = null;
	int iCount = 1;



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
		if(appMgmt.operateOnStudExamResult(dbOP, request, Integer.parseInt(strTemp)) != null ) {
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
          RESULT ENCODING / VIEWING PAGE::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="table2">
    <tr>
      <td height="25" colspan="3"> &nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr>
      <td width="6%" height="25">&nbsp;</td>
      <td width="20%">School Year / Term</td>
      <td width="74%"> <% strTemp = WI.fillTextValue("sy_from");
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
      <td>
        <select name="view_option">
<%
	strTemp = WI.fillTextValue("view_option");
	if(strTemp.equals("0")){%>
          <option value="0" selected>For Interview Scheduling</option>
          <%}else{%>
          <option value="0">For Interview Scheduling</option>
          <%}if(strTemp.equals("1")){%>
          <option value="1" selected>For Interview</option>
          <%}else{%>
          <option value="1">For Interview</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>Interviewed</option>
          <%}else{%>
          <option value="2">Interviewed</option>
          <%} if(strTemp.equals("3")){%>
          <option value="3" selected>Show Only Passed</option>
          <%}else{%>
          <option value="3">Show Only Passed</option>
          <%} %>
        </select>
	<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
	if (vRetResult != null) {

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="23" colspan="5" align="center" class="thinborder"><strong><font color="#FFFFFF">SCHEDULE APPLICANTS FOR INTERVIEW</font></strong> </td>
    </tr>
    <tr>
      <td width="8%" align="center" class="thinborder"><strong>
      NO.</strong></td>
      <td width="15%" height="25" align="center" class="thinborder"><strong>
      TEMPORARY /<br>
      APPLICANT ID</strong></td>
      <td width="38%" align="center" class="thinborder"><strong>
      APPLICANT NAME</strong></td>
      <td width="32%" align="center" class="thinborder">
      <strong>DATE / TIME </strong></td>
      <b> </b>
      <td align="center" class="thinborder"><b>SELECT </b> <br>
        <input type="checkbox" name="selAll" value="0" onClick="CheckAll();"></td>
    </tr>
    <%
		int iRemarks = 0;
		for(int t = 0; t < vRetResult.size(); t+=10){
   	%>
    <tr>
	  <td height="25" align="right" class="thinborder">
  	  <%=iCount++%>&nbsp;</td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=((String)vRetResult.elementAt(t+1))%></td>
      <td class="thinborder">&nbsp;
        <%=WI.formatName((String)vRetResult.elementAt(t+2),(String)vRetResult.elementAt(t+3),(String)vRetResult.elementAt(t+4),4)%></td>
      <td align="center" class="thinborder">
	<input type="text" name="intv<%=iCount%>" size="10" maxlength="10"
	value="<%=strTemp%>" class="textbox" onBlur="style.backgroundColor='white'"
	onFocus= "style.backgroundColor='#D3EBFF'">

        &nbsp;<a href="javascript:show_calendar('form_.intv<%=iCount%>');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;
        <input name="hh<%=iCount%>" type="text" size="2" maxlength="2"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
      :
      <input name="mm<%=iCount%>" type="text" size="2" maxlength="2"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	onKeyUp="AllowOnlyInteger('form_','mm<%=iCount%>')"></td>
      <td width="7%" align="center" class="thinborder">
      <input type="checkbox" name="checkbox<%=iCount%>" value="1">      </td>
    </tr>
    <%}%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"><div align="right"><a href='javascript:PageAction(0,"");'>
          <img src="../../../images/delete.gif" width="55" height="28" border=0></a>
      <font size="1"> click to delete selected entries&nbsp;</font></div></td>
    </tr>
  </table>
    <%} if (vRetResult != null && vRetResult.size() > 0){  %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="50%" height="30" align="right">Number of Applicants Per Page
        <select name="appl_per_page">
                <option>20</option>
                <option>25</option>
                <option>30</option>
                <option>35</option>
                <option>40</option>
                <option>45</option>
                <option>50</option>
        </select>&nbsp;&nbsp;</td>
      <td width="50%"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a> <font size="1">click to print list</font></td>
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
<input type="hidden" name="show_list" value="">
<input type="hidden" name="max_display" value="<%=iCount%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
