<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Exam Result Encoding </title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	document.form_.print_page.value = "";
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.NewType.value=document.form_.exam_index[document.form_.exam_index.selectedIndex].text;
	document.form_.page_action.value="";
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
		for (var i = 1 ; i < eval(iMaxDisp);++i)
			eval('document.form_.checkbox'+i+'.checked=true');
	}
	else
		for (var i = 1 ; i < eval(iMaxDisp);++i)
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
	Vector vExamName = null;
	Vector vSchedData = null;
	String strErrMsg = null;
	String strTemp = null;
	String strMScore = "0";
//	String strPScore = "0";
	String[] astrRetake = {"No","Yes"};
	String[] astrRemarks = {"Failed","Passed"};
	int iEncoded = 1;
	int iNotEncoded = 1;
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
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission Maintenance","Exam SubType",
														request.getRemoteAddr(), "Result Encoding");
}
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
	if (WI.fillTextValue("change_exam_index").length()==0){
		vRetResult = appMgmt.operateOnStudExamResult(dbOP, request, 4);
	}
%>
<body bgcolor="#D2AE72"> 
<form name="form_" action="./exam_interview_encode_result.jsp" method="post">

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="table1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center">
      <font color="#FFFFFF" ><strong><font color="#FFFFFF" size="2"
      face="Verdana, Arial, Helvetica, sans-serif">::::
          RESULT ENCODING / VIEWING PAGE::::</font></strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="table2">
    <tr>
      <td height="25" colspan="5"> &nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>School Year / Term</td>
      <td colspan="3"> <% strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %> <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
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
        </select>
	  </td>
	</tr>
    <tr>
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25" width="1%">&nbsp;</td>
      <td width="21%">Scheduling Type/Sub-type</td>
      <td colspan="3"><select name="exam_index" onChange="ChangeExamIndex();">
        <%strTemp = WI.fillTextValue("exam_index");
	  	vExamName = appMgmt.retreiveName(dbOP, request);
  	if(vExamName != null && vExamName.size() > 0) {
	  for(int i = 0 ; i< vExamName.size(); i +=6){
		if( strTemp.compareTo((String)vExamName.elementAt(i)) == 0) {%>
          <option value="<%=(String)vExamName.elementAt(i)%>" selected><%=(String)vExamName.elementAt(i+3)%></option>
          <%}else{%>
          <option value="<%=(String)vExamName.elementAt(i)%>"><%=(String)vExamName.elementAt(i+3)%></option>
          <%} //else
			} //for loop
		   }%>
		</select> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="21%">Schedule Code</td>
      <td colspan="3"><select name="sch_code" onChange="ReloadPage();">
<% if(WI.fillTextValue("exam_index").length() > 0)
	{
			strTemp = " FROM NA_EXAM_SCHED WHERE IS_DEL=0 AND IS_VALID=1 AND EXAM_NAME_INDEX =" +
			WI.fillTextValue("exam_index") + " AND SY_FROM =" + WI.fillTextValue("sy_from") +
			" AND SEMESTER =" + WI.fillTextValue("semester") +
			" order by SCHEDULE_CODE asc" ;	%>
          <%=dbOP.loadCombo("EXAM_SCHED_INDEX","SCHEDULE_CODE",strTemp, request.getParameter("sch_code"), false)%>
  <%}%>
        </select></td>
    </tr>
    <% if (WI.fillTextValue("change_exam_index").length()==0)
{
	request.setAttribute("info_index",WI.fillTextValue("sch_code"));
	vSchedData = appMgmt.operateOnExamSched(dbOP,request,5);
}

if(vSchedData != null && vSchedData.size() > 0)
{
	strMScore = (String)vSchedData.elementAt(15);
//	strPScore = (String)vSchedData.elementAt(16);
}

	String [] astrConvTime={" AM"," PM"};

	if(vSchedData != null && vSchedData.size() > 0) { %>
    <tr>
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="21%">Date : <strong> <%=((String)vSchedData.elementAt(7))%></strong></td>
      <td width="26%">Start Time :<strong><%=CommonUtil.formatMinute((String)vSchedData.elementAt(8))+':'+
      CommonUtil.formatMinute((String)vSchedData.elementAt(9))+
      astrConvTime[Integer.parseInt((String)vSchedData.elementAt(10))]%></strong></td>
      <td width="30%">Duration (min):<strong> <%=((String)vSchedData.elementAt(6))%></strong></td>
      <td width="22%">Venue : <strong> <%=((String)vSchedData.elementAt(12))%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Contact Person</td>
      <td height="25" colspan="3"><strong><%=((String)vSchedData.elementAt(13))%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Contact Info</td>
      <td height="25" colspan="3" valign="bottom"><strong><%=((String)vSchedData.elementAt(14))%> </strong></td>
    </tr>
    <tr>
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25"><div align="right"></div></td>
      <td width="20%" height="25">Maximum Score/Rate :</td>
      <td width="12%" height="25"><strong>
      <%=((String)vSchedData.elementAt(15))%></strong></td>
      <td width="66%" height="25">Passing Score/Rate : <strong>
      <%=((String)vSchedData.elementAt(16))%></strong>
	  	<input type="hidden" value="<%=((String)vSchedData.elementAt(16))%>" name="passing_score">
      </td>
      <td width="1%" height="25">&nbsp;</td>
    </tr>
    <%}  //if(vSchedData != null && vSchedData.size() > 0)%>
 <tr>
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>

  </table>
  <% if (vRetResult != null) {
  int iCount = 1;
		Vector vEncoded = (Vector)vRetResult.elementAt(0);
		Vector vUnEncoded = (Vector)vRetResult.elementAt(1);
 %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
		<%if (vUnEncoded.size()>1) {%>
      <td height="23" align="right">&nbsp; </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="23" colspan="7" align="center" class="thinborder"><strong><font color="#FFFFFF">LIST
          OF APPLICANTS WITHOUT SCORES </font></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="7" class="thinborder"><strong><font size="1">TOTAL
        APPLICANT(S) : <%=(String)vUnEncoded.elementAt(0)%>
			<input type="hidden" value="<%=((String)vSchedData.elementAt(16))%>" name="passing_score">
		</font></strong></td>
    </tr>
    <tr align="center">
      <td width="8%" class="thinborder"><strong>NO.</strong></td>
      <td width="21%" height="25" class="thinborder"><strong>TEMPORARY
        /APPLICANT ID</strong></td>
      <td width="38%" class="thinborder"><strong>APPLICANT NAME</strong></td>
      <td width="10%" class="thinborder"><strong>COURSE</strong></td>
      <td width="15%" class="thinborder"><strong>
	  <% if (strSchCode.startsWith("CGH")) {%>
  		  PASSED
        <%}else{%>
		  SCORE
        <%}%>


</strong></td>
	<% if (!strSchCode.startsWith("CGH")) {%>
      <td width="10%" class="thinborder"><strong>RETAKE ? </strong></td>
	 <%}%>
    </tr>
   <%
   
   for(int u=1; u<vUnEncoded.size(); u+=7, iNotEncoded++){%>
    <tr>
      <td align="center" class="thinborder">       
        <%=iCount++%><input type="hidden" name="studindex<%=iNotEncoded%>" value="<%=(String)vUnEncoded.elementAt(u)%>">        </td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=(String)vUnEncoded.elementAt(u+2)%></td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=WI.formatName((String)vUnEncoded.elementAt(u+3),(String)vUnEncoded.elementAt(u+4),(String)vUnEncoded.elementAt(u+5),4)%></td>
      <td class="thinborder">&nbsp;&nbsp;<%=(String)vUnEncoded.elementAt(u+6)%></td>
      <td align="center" class="thinborder">
        <% if (strSchCode.startsWith("CGH")){%>
        <input  name="pass_fail<%=iNotEncoded%>" type="checkbox" value="1" checked>
        <%}else{%>
        <input name="score<%=iNotEncoded%>" type="text" id="score" size="4" maxlength="4" class="textbox"
        onKeyUp= 'AllowOnlyInteger("form_","score<%=iNotEncoded%>")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","score<%=iNotEncoded%>");style.backgroundColor="white"' >
        <%}%>        </td>
	<% if (!strSchCode.startsWith("CGH")) {%>
      <td class="thinborder">        <input name="chkRetake<%=iNotEncoded%>" type="checkbox" id="chkretake" value="1">        </td>
      <%}%>
    </tr>
    <%}%>
  </table>
  <% if (vUnEncoded != null && vUnEncoded.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="52"  colspan="3" align="center"><a href='javascript:PageAction(1,"");'>
        <img src="../../../images/save.gif" width="48" height="28" border="0"></a><font size="1">click
          to save entries</font></td>
    </tr>
  </table>
	<%}%>
  <%} if (vEncoded.size() >1) { %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="23" colspan="8" class="thinborder"><div align="center"><strong><font color="#FFFFFF">
      LIST OF APPLICANTS WITH SCORES</font></strong></div></td>
    </tr>
    <tr>
      <td height="25" colspan="8" class="thinborder"><strong>
      TOTAL APPLICANT(S) : <%=(String)vEncoded.elementAt(0)%></strong></td>
    </tr>
    <tr>
      <td width="10%" align="center" class="thinborder"><strong>
      NO.</strong></td>
      <td width="22%" height="25" align="center" class="thinborder"><strong>
      TEMPORARY /APPLICANT ID</strong></td>
      <td width="33%" align="center" class="thinborder"><strong>
      APPLICANT NAME</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>COURSE</strong></td>
      <% if (!strSchCode.startsWith("CGH")) {%>
      <td width="8%" align="center" class="thinborder"><strong>
      SCORE</strong></td>
      <td width="8%" align="center" class="thinborder">
      <strong>RETAKE</strong></td>
<%}%>
      <td width="11%" align="center" class="thinborder">
      <strong>REMARKS</strong></td>
      <b> </b>
      <td align="center" class="thinborder"><b>SELECT ALL</b>
        <br> <input type="checkbox" name="selAll" value="0" onClick="CheckAll();"></td>
    </tr>
    <%
		int iRemarks = 0;
		iCount = 1;
	for(int t = 1; t < vEncoded.size(); t+=12, iEncoded++){

		if (Integer.parseInt((String)vEncoded.elementAt(t+2)) >= Integer.parseInt((String)vSchedData.elementAt(16)))
			iRemarks = 1;
      	else
			iRemarks = 0;
      	%>
    <tr>
	  <td height="25" align="center" class="thinborder"><%=iCount%></td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=((String)vEncoded.elementAt(t+5))%></td>
      <td class="thinborder">&nbsp;
        <%=WI.formatName((String)vEncoded.elementAt(t+6),(String)vEncoded.elementAt(t+7),(String)vEncoded.elementAt(t+8),4)%></td>
      <td class="thinborder"><%=((String)vEncoded.elementAt(t+11))%></td>
      <% if (!strSchCode.startsWith("CGH")) {%>
      <td align="center" class="thinborder"><%=((String)vEncoded.elementAt(t+2))%></td>
      <td align="center" class="thinborder"><%=astrRetake[Integer.parseInt((String)vEncoded.elementAt(t+9))]%></td>
<%}%>
      <td align="center" class="thinborder"><%=astrRemarks[iRemarks]%>      </td>
      <td width="8%" align="center" class="thinborder">
        <input type="checkbox" name="checkbox<%=iEncoded%>" value="<%=(String)vEncoded.elementAt(t)%>">      </td>
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
    <%} %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="50%" height="30">
        <div align="right">Number of Applicants Per Page
          <select name="appl_per_page">
                  <option>20</option>
                  <option>25</option>
                  <option>30</option>
                  <option>35</option>
                  <option>40</option>
                  <option>45</option>
                  <option>50</option>
          </select>
      &nbsp;&nbsp;</div></td>
      <td width="50%"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a> <font size="1">click to print list</font>
	  <font style="font-size:11px; font-weight:bold; color:blue">
<%
strTemp = WI.fillTextValue("info_");
if(strTemp.equals("1"))
	strTemp = " selected";
else	
	strTemp = "";
%> 
	  	<input name="info_" type="checkbox" value="1" <%=strTemp%>>Print only Passed Applicant</font>
	  </td>
    </tr>
  </table>
  <%} %>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 	<input type="hidden" name="cEnc" value ="<%=iEncoded%>">
	<input type="hidden" name="cNotEnc" value ="<%=iNotEncoded%>">
	<input type="hidden" name="mScore" value= "<%=strMScore%>">
<!--	<input type="hidden" name="pScore" value="<%//=strPScore%>">
-->	<input type="hidden" name="page_action" >
    <input type="hidden" name="NewType">
    <input type="hidden" name="NewCode">
    <input type="hidden" name="change_exam_index">
	<input type="hidden" name="print_page" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
