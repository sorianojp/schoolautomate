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
	document.form_.page_action.value = strAction;
	document.form_.show_list.value ="1";
	document.form_.print_page.value = "";
	
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

		<jsp:forward page="./edit_applicant_interview_print.jsp"/>

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
								"editr_applicant_interview.jsp");
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
														request.getRemoteAddr(),"editr_applicant_interview.jsp");
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
		vSchedData = appMgmt.operateOnInterview(dbOP, request, 4);
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./edit_applicant_interview.jsp" method="post">
<input type="hidden" name="get_all" value="1">

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="table1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center">
      <font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif" ><strong>::::
          RESULT REVIEW  PAGE::::</strong></font></div></td>
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
          <option value="0" selected>Review Schedule</option>
          <%}else{%>
          <option value="0">Review Schedule</option>
          <%}if(strTemp.equals("1")){%>
          <option value="1" selected>Review Interview Result</option>
          <%}else{%>
          <option value="1">Review Interview Result</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>Review Subjects to take</option>
          <%}else{%>
          <option value="2">Review Subjects to take</option>
          <%}%>
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
	if (WI.fillTextValue("view_set").equals("0") && vSchedData != null
			&& vSchedData.size() > 0) {
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFFFF">
      <td height="23">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="23" colspan="5" align="center" class="thinborder"><strong>APPLICANT INTERVIEW SCHEDULE</strong></td>
    </tr>
    <tr>
      <td width="8%" align="center" class="thinborder"><strong>
      NO.</strong></td>
      <td width="15%" height="21" align="center" class="thinborder"><strong>
      TEMPORARY  ID</strong></td>
      <td width="39%" align="center" class="thinborder"><strong>APPLICANT NAME</strong></td>
      <td width="20%" align="center" class="thinborder"><strong>SCHEDULE</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>
          ALL
          <input name="selAll" type="checkbox" id="selAll" onClick="CheckAll();" value="0">
      </strong></td>
      </tr>
<% 	String[] astrPassFail = {"Fail", "Pass","Pending"};
	for (int t = 0; t < vSchedData.size() ; t+= 9) {%>
    <tr>
	  <td height="25" align="right" class="thinborder">
  	  <%=iCount2++%><input type="hidden" name="user_index<%=iCount%>"
	  		value="<%=(String)vSchedData.elementAt(t)%>">&nbsp;	  </td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=(String)vSchedData.elementAt(t+1)%></td>
      <td class="thinborder">&nbsp; <%=WI.formatName((String)vSchedData.elementAt(t+2),(String)vSchedData.elementAt(t+3),
							(String)vSchedData.elementAt(t+4),4)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vSchedData.elementAt(t+5)) +
	  					" (" +  WI.getStrValue((String)vSchedData.elementAt(t+6)) + ")"%>		</td>
      <td align="center" class="thinborder"><input name="checkbox<%=iCount++%>" type="checkbox" value="1"></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="45%" height="30" align="right">&nbsp;</td>
      <td width="55%" align="right">&nbsp;<a href="javascript:PageAction('6')"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a> <font size="1">click to delete selected </font></td>
    </tr>
  </table>
  <%
    }
	if (WI.fillTextValue("view_set").equals("1") && vSchedData != null
			&& vSchedData.size() > 0) {
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFFFF">
      <td height="23">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="23" colspan="5" align="center" class="thinborder"><strong>APPLICANT INTERVIEW RESULTS </strong></td>
    </tr>
    <tr>
      <td width="10%" align="center" class="thinborder"><strong>
      NO.</strong></td>
      <td width="17%" height="21" align="center" class="thinborder"><strong>
      TEMPORARY  ID</strong></td>
      <td width="47%" align="center" class="thinborder"><strong>APPLICANT NAME</strong></td>
      <td width="14%" align="center" class="thinborder"><strong>RESULT</strong></td>
      <td width="12%" align="center" class="thinborder"><strong>
          ALL
          <input name="selAll" type="checkbox" id="selAll" onClick="CheckAll();" value="0">
      </strong></td>
    </tr>
<% 	String[] astrPassFail = {"Fail", "Pass","Pending"};
	for (int t = 0; t < vSchedData.size() ; t+= 9) {%>
    <tr>
	  <td height="25" align="right" class="thinborder">
  	  <%=iCount2++%><input type="hidden" name="user_index<%=iCount%>"
	  		value="<%=(String)vSchedData.elementAt(t)%>">&nbsp;	  </td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=(String)vSchedData.elementAt(t+1)%></td>
      <td class="thinborder">&nbsp; <%=WI.formatName((String)vSchedData.elementAt(t+2),(String)vSchedData.elementAt(t+3),
							(String)vSchedData.elementAt(t+4),4)%></td>
      <td class="thinborder">&nbsp;
	  	<%=astrPassFail[Integer.parseInt(WI.getStrValue((String)vSchedData.elementAt(t+8),
													"2"))]%></td>
      <td align="center" class="thinborder"><input name="checkbox<%=iCount++%>" type="checkbox"  value="1"></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="45%" height="30" align="right">&nbsp;</td>
      <td width="55%" align="right">&nbsp;<a href="javascript:PageAction(10)"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a> <font size="1">click to delete selected </font></td>
    </tr>
  </table>
<%
    }

  if (WI.fillTextValue("view_set").equals("2") &&
  		vSchedData != null && vSchedData.size() > 0) {  %>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFFFF">
      <td height="23" colspan="3">&nbsp;</td>
    </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="23" colspan="5" align="center" class="thinborder"><strong><font color="#000000">APPLICANTS SUBJECTS TO TAKE </font></strong></td>
    </tr>
    <tr>
      <td width="8%" align="center" class="thinborder"><strong>
      NO.</strong></td>
      <td width="15%" height="25" align="center" class="thinborder"><strong>
      TEMPORARY  ID</strong></td>
      <td width="45%" align="center" class="thinborder"><strong>APPLICANT NAME</strong></td>
      <td width="22%" align="center" class="thinborder"><strong>SUBJECT TO TAKE</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>ALL
          <input name="selAll" type="checkbox" id="selAll" onClick="CheckAll();" value="0">
      </strong></td>
    </tr>
<%  String[] astrREGEEME = {"REG", "EE","ME","EE and ME",""};
	for(int t = 0; t < vSchedData.size(); t+=9){ %>
    <tr>
	  <td height="25" align="right" class="thinborder">
  	  <%=iCount2++%>&nbsp;
	  <input type="hidden" name="stud_index<%=iCount%>"
	  							value="<%=(String)vSchedData.elementAt(t)%>">
  	  </td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=(String)vSchedData.elementAt(t+1)%></td>
      <td class="thinborder">&nbsp; <%=WI.formatName((String)vSchedData.elementAt(t+2),(String)vSchedData.elementAt(t+3),
							(String)vSchedData.elementAt(t+4),4)%></td>
      <td class="thinborder">&nbsp;<%=astrREGEEME[Integer.parseInt(WI.getStrValue((String)vSchedData.elementAt(t+7),"4"))]%></td>
      <td class="thinborder"><input name="checkbox<%=iCount++%>" type="checkbox"  value="1"></td>
    </tr>
    <%}%>
  </table>

    <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
      <tr>
        <td width="45%" height="30" align="right">&nbsp;</td>
        <td width="55%" align="right">&nbsp;<a href="javascript:PageAction(9)"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a> <font size="1">click to delete selected </font></td>
      </tr>
    </table>
    <%
	 }

	if (vSchedData != null && vSchedData.size() > 0){  %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" height="30" align="center">
<!--
	  Number of Applicants Per Page
        <select name="appl_per_page">
          <option>20</option>
          <option>25</option>
          <option>30</option>
          <option>35</option>
          <option>40</option>
          <option>45</option>
          <option>50</option>
        </select> -->
      &nbsp;<a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a> <font size="1">click to print list</font></td>
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
