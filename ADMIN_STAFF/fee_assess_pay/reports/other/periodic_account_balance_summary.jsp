<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
 }
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

</style>

</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.show_result.value='';
	document.form_.submit();
}
function PrintPage() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);

	document.getElementById('myADTable3').deleteRow(0);

	alert("Click OK to print this page");
	window.print();
}
function CallOnLoad() {
	document.all.processing.style.visibility='hidden';
	document.bgColor = "#FFFFFF";
}
function DeleteProj() {
	document.form_.del_projection.value = '1';
	document.all.processing.style.visibility='visible';
	document.bgColor = "#aaaaaa";
	document.form_.submit();
}
function GoToDetailed() {
	location = "./periodic_account_balance.jsp";
}
</script>
<body topmargin="0" bottommargin="0" onLoad="CallOnLoad();" bgcolor="#DDDDDD">
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFCC66">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page</font></p>

			<img src="../../../../Ajax/ajax-loader2.gif"></td>
      </tr>
</table>
</div>
<%@ page language="java" import="utility.*, java.util.Vector, java.util.Date"%>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assess & Payment - Reports - Installment Dues.",
								"installment_dues_ul.jsp");
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

enrollment.ReportFeeAssessment RFA = new enrollment.ReportFeeAssessment();
enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
Vector vRetResult = new Vector();
Vector vDPInfo = new Vector();
int iIndexOf   = 0; Integer iObj = null; String strDPInfo = null;

boolean bolIsBasic = false;
if(WI.fillTextValue("is_basic").length() > 0)
	bolIsBasic = true;

if(WI.fillTextValue("del_projection").length() > 0) {
	dbOP.executeUpdateWithTrans("update FA_FEE_HISTORY_PROJECTED_COL_RUNDATE set IS_RUNNING = 0, TO_PROCESS = 0", null, null, false);
}

if(WI.fillTextValue("show_result").length() > 0 && WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("pmt_schedule").length() > 0) {
	vRetResult = RFA.getPeriodicalExamBalancePerCollege(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RFA.getErrMsg();
}

%>
<form action="./periodic_account_balance_summary.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id='myADTable1'>
    <tr>
      <td width="100%" height="25" align="center" class="thinborderBOTTOM"><strong>:::: PERIODIC EXAM DUES SUMMARY::::</strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id='myADTable2'>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="9%">SY/TERM</td>
      <td width="55%"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">

	  <select name="semester">
          <option value="0">Summer</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
if(strTemp.equals("1"))
	strErrMsg = " selected";
else
	strErrMsg ="";
%>
        <option value="1" <%=strErrMsg%>><%if(bolIsBasic){%>Regular<%}else{%>1st Term<%}%></option>
 <%if(!bolIsBasic) {
if(strTemp.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg ="";
%>
       <option value="2" <%=strErrMsg%>>2nd Term</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg ="";
%>
          <option value="3" <%=strErrMsg%>>3rd Term</option>
<%}%>
      </select>
<%if(strSchCode.startsWith("UC")){%>
	&nbsp;&nbsp;
	<font style="color:#0000FF; font-weight:bold; font-size:9px">
		<input type="checkbox" name="is_basic" value="checked" <%=WI.fillTextValue("is_basic")%> onClick="document.form_.show_result.value='';document.form_.submit()"> Is Grade School	</font>
<%}%>
<% if(strSchCode.startsWith("FATIMA") || true){%>
	&nbsp;&nbsp;
	<font style="color:#0000FF; font-weight:bold; font-size:9px">
		<input type="checkbox" name="go_summary" onClick="GoToDetailed()"> 
		Go To Detailed	</font>
    <%}%>	  </td>
      <td>Exam Period:
<%
if(bolIsBasic)
	strTemp = "2";
else
	strTemp = "1";
%>
	  <select name="pmt_schedule">
	  <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME",
		" from FA_PMT_SCHEDULE where is_del=0 and is_valid="+strTemp+" order by EXAM_PERIOD_ORDER asc",
		WI.fillTextValue("pmt_schedule"), false)%>
	  </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td>
      	<input type="submit" name="_" value="Show Result" onClick="document.form_.show_result.value='1'">      	<!--
		<input type="checkbox" name="process_one_college" value="checked" <%=WI.fillTextValue("process_one_college")%>>
		 Process for Selected College
-->	  </td>
      <td width="34%">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id='myADTable3'>
    <tr align="right">
      <td height="25" style="font-size:9px;"><a href="javascript:PrintPage();"><img src="../../../../images/print.gif" border="0"></a>Print Report</td>
    </tr>
  </table>
<%
String strTodaysDateTime = WI.getTodaysDateTime();

String strSQLQuery   = null;
String strExamName   = null;

String[] astrConvertTerm = {"Summer","1st Term","2nd Term","3rd Term"};
if(WI.fillTextValue("pmt_schedule").length() > 0) {
	strSQLQuery = "select exam_name from fa_pmt_schedule where pmt_sch_index = "+WI.fillTextValue("pmt_schedule");
	strExamName = dbOP.getResultOfAQuery(strSQLQuery, 0);
}
int iStudCount = 1;

String strSYFrom = WI.fillTextValue("sy_from");
String strSemester = WI.fillTextValue("semester");

double dTotal = 0d;
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr align="center">
      <td height="25" style="font-size:16px; font-weight:bold" colspan="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
	  <font size="1" style="font-weight:normal"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%><%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false),",","","")%></font></td>
    </tr>
    <tr>
      <td height="25" colspan="2" align="center" style="font-weight:bold">Periodic Account Balance <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%>, <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr>
      <td width="8%" height="20" class="thinborder">Count</td>
      <td width="69%" class="thinborder">College</td>
      <td width="23%" class="thinborder">Amount Due </td>
    </tr>
	<%while(vRetResult.size() > 0){	
	dTotal += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(2),",",""));%>
		<tr>
		  <td height="20" class="thinborder"><%=iStudCount++%>. </td>
		  <td class="thinborder"><%=vRetResult.elementAt(1)%></td>
		  <td class="thinborder" align="right"><%=vRetResult.elementAt(2)%></td>
		</tr>
	<%vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
		  <td align="right">Total: <%=CommonUtil.formatFloat(dTotal, true)%></td>
    	</tr>
  </table>

<%}%>
<input type="hidden" name="show_result" value="<%=WI.fillTextValue("show_result")%>">
<input type="hidden" name="del_projection">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
