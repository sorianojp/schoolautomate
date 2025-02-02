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
function GoToSummary() {
	location = "./periodic_account_balance_summary.jsp";
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
	vRetResult = RFA.getPeriodicalExamBalance(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RFA.getErrMsg();
}

boolean bolIsCDD = strSchCode.startsWith("CDD");
boolean bolIsSPC = strSchCode.startsWith("SPC");
boolean bolIsUC = strSchCode.startsWith("UC");

boolean bolIsJonelta = false;
boolean bolShowGT    = false;

if(strSchCode.startsWith("UPH")) {
	if(request.getSession(false).getAttribute("info5") != null)
		bolIsJonelta = true;
	
	bolShowGT = true;
}
double dGT            = 0d;
double dGTFinals      = 0d;
String strStudPlan    = null;

Vector vStudPlanInfo  = new Vector();
java.sql.ResultSet rs = null;
String strSQLQuery    = null;
//get here the plan.
if(vRetResult != null && vRetResult.size() > 0 &&  bolIsJonelta) {
	strSQLQuery = "select stud_index, plan_name from FA_STUD_MIN_REQ_DP_PER_STUD  "+
					"join FA_STUD_PLAN_FATIMA on (FA_STUD_PLAN_FATIMA.PLAN_REF = FA_STUD_MIN_REQ_DP_PER_STUD.PLAN_REF) "+
					"where FA_STUD_MIN_REQ_DP_PER_STUD.IS_TEMP_STUD = 0 and sy_from = "+WI.fillTextValue("sy_from")+
					" and semester = "+WI.fillTextValue("semester");
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vStudPlanInfo.addElement(rs.getString(1));
		vStudPlanInfo.addElement(rs.getString(2));
	}
	rs.close();
}

%>
<form action="./periodic_account_balance.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id='myADTable1'>
    <tr>
      <td width="100%" height="25" align="center" class="thinborderBOTTOM"><strong>:::: PERIODIC EXAM DUES ::::</strong></td>
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
		<input type="checkbox" name="is_basic" value="checked" <%=WI.fillTextValue("is_basic")%> onClick="document.form_.show_result.value='';document.form_.submit()"> Is Grade School
	</font>
<%}%>
<% if(strSchCode.startsWith("FATIMA")){%>
	&nbsp;&nbsp;
	<font style="color:#0000FF; font-weight:bold; font-size:9px">
		<input type="checkbox" name="go_summary" onClick="GoToSummary()"> Go To Summary
	</font>
<%}%>


	  </td>
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
	  </select>
	  </td>
    </tr>
<%if(bolIsBasic){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Grade Level</td>
      <td colspan="2">
      <%strTemp = WI.fillTextValue("year_level");%>
      <select name="year_level" style="font-size:11px;">
	  <option value=""></option>
          <%=dbOP.loadCombo("g_level","level_name"," from bed_level_info order by edu_level",
		  		WI.fillTextValue("year_level"), false)%> </select>
	  </td>
      </tr>
<%}else{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td colspan="2">
      <%strTemp = WI.fillTextValue("c_index");%>
      <select name="c_index" style="font-size:11px; width:400px">
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		WI.fillTextValue("c_index"), false)%> </select>
		<input type="checkbox" name="gen_one_college" value="selected" <%=WI.fillTextValue("gen_one_college")%>> Process One College
	  </td>
      </tr>
<%}%>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td colspan="2">
	<%if (strTemp==null || strTemp.length()==0 )
		strTemp = " from course_offered where is_del = 0 and is_valid = 1 order by course_name asc";
	else
		strTemp = " from course_offered where is_del = 0 and is_valid = 1 and c_index = "+strTemp+
		" order by course_name asc";

	String strTemp2 = WI.fillTextValue("course_index");%>
      <select name="course_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, strTemp2, false)%>
        </select>	  </td>
      </tr>
<%
if(strTemp2.length() > 0) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Major</td>
      <td colspan="2">
      <select name="major_index">
          <option value="">All</option>
          <%=dbOP.loadCombo("major_index","major_name"," from major where is_del = 0 and course_index = "+strTemp2 + " order by course_code asc", WI.fillTextValue("major_index"), false)%>
        </select>	  </td>
      </tr>
<%}%>

-->
    <tr>
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td>
      	<input type="submit" name="_" value="Show Result" onClick="document.form_.show_result.value='1'">

		&nbsp;
		<input type="checkbox" name="show_with_balance" value="checked" <%=WI.fillTextValue("show_with_balance")%>>
		 Show with Balance
<!--
		<input type="checkbox" name="process_one_college" value="checked" <%=WI.fillTextValue("process_one_college")%>>
		 Process for Selected College
-->
	  </td>
      <td width="34%">
	  Rows Per Page:
         <select name="rows_per_page">
	<%
	int iRowsPerPage = 0;
	strTemp = request.getParameter("rows_per_page");
	if(strTemp == null)
		strTemp = "40";
	iRowsPerPage = Integer.parseInt(strTemp);

	for(int i = 35; i < 70; ++i) {
		if( i == iRowsPerPage)
			strTemp = " selected";
		else
			strTemp = "";
	%>
      <option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>	</select>	  </td>
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

Vector vScheduleInfo = null;
String strCourseName = null;
String strExamName   = null;

String[] astrConvertTerm = {"Summer","1st Term","2nd Term","3rd Term"};
if(WI.fillTextValue("c_index").length() > 0) {
	strSQLQuery = "select c_name from college where c_index = "+WI.fillTextValue("c_index");
	strCourseName = dbOP.getResultOfAQuery(strSQLQuery, 0);
}
if(WI.fillTextValue("pmt_schedule").length() > 0) {
	strSQLQuery = "select exam_name from fa_pmt_schedule where pmt_sch_index = "+WI.fillTextValue("pmt_schedule");
	strExamName = dbOP.getResultOfAQuery(strSQLQuery, 0);
}

    boolean bolIsMTerm = false;
	if(strExamName != null && strExamName.toLowerCase().startsWith("midterm") || strExamName.toLowerCase().startsWith("third"))
      bolIsMTerm = true;
/**
if(WI.fillTextValue("major_index").length() > 0) {
	strSQLQuery = "select course_code from major where major_index = "+WI.fillTextValue("major_index");
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery != null)
		strCourseName = strCourseName + " - "+strSQLQuery;
}
if(WI.fillTextValue("yr_lvl").length() > 0)
	strCourseName += " - "+WI.fillTextValue("yr_lvl");
**/
int iStudCount = 1;


double dCurrentCharge = 0d;
double dPreviousBal   = 0d;
double dTotal = 0d;

String strPrelim = null;
String strMidterm = null;
String strSemiFinal = null;
String strFinal = null;

String strPmtSch    = WI.fillTextValue("pmt_schedule");
String strAdmSlipNo = null;

String strSYFrom = WI.fillTextValue("sy_from");
String strSemester = WI.fillTextValue("semester");

int iPageNo = 0;

boolean bolOnlyWithBalance = false;
if(WI.fillTextValue("show_with_balance").length() > 0)
	bolOnlyWithBalance = true;

while(vRetResult.size() > 0) {
if(iStudCount > 1) {
%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr align="center">
      <td height="25" style="font-size:16px; font-weight:bold" colspan="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
	  <font size="1" style="font-weight:normal"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%><%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false),",","","")%></font></td>
    </tr>
    <tr>
      <td height="25" colspan="2" align="center" style="font-weight:bold">Periodic Account Balance <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%>, <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%></td>
    </tr>
<%if(strCourseName != null) {%>
    <tr>
      <td width="55%">College: <%=WI.getStrValue(strCourseName,"&nbsp;")%></td>
      <td width="45%" style="font-size:9px;" align="right">Date time printed: <%=strTodaysDateTime%>

	  &nbsp;&nbsp;&nbsp; Page #: <%=++iPageNo%>
	  </td>
    </tr>
<%}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr>
      <td width="5%" class="thinborder">Count</td>
<%if(!bolIsSPC) {%>
      <td width="10%" class="thinborder">Admission Slip#</td>
<%}%>
      <td width="10%" class="thinborder">Student ID</td>
      <td width="20%" class="thinborder">Student Name</td>
      <td width="10%" class="thinborder"><%if(bolIsBasic){%>Grade Level<%}else{%>Course-YR<%}%></td>
	  <%if(bolIsJonelta) {%>
      	<td width="5%" class="thinborder">Payment Plan </td>
      <%}if(!bolIsBasic){%>
      <td width="5%" class="thinborder">Units</td>
<%}%>
      <td width="10%" height="20" class="thinborder"><%=strExamName.toUpperCase()%></td>
<%if(bolIsMTerm){%>
      <td width="10%" class="thinborder"><%if(bolIsBasic){%> FOURTH GRADING<%}else{%>FINALS<%}%></td>
<%}%>
      <!--52-->
      <!--52-->
    </tr>
	<%
			strSQLQuery = "select adm_slip_number from adm_slip_prn_count where sy_from = "+strSYFrom+" and semester = "+strSemester+" and pmt_sch_index = "+strPmtSch+
							" and user_index = ? and ADM_SLIP_NUMBER is not null and ADM_SLIP_NUMBER <> '0' and is_valid = 1";
			rs = null;
			
			java.sql.PreparedStatement pstmt = dbOP.getPreparedStatement(strSQLQuery);
	while(vRetResult.size() > 0){
		//get admission slip number here.
		strAdmSlipNo = null;
		
		if(bolIsUC && false) {
			//strAdmSlipNo = reportEnrl.autoGenAdmSlipNum(dbOP, (String)vRetResult.elementAt(0),strPmtSch, strSYFrom, strSemester,
            //                (String)request.getSession(false).getAttribute("userIndex"));
		}
		else {
			pstmt.setInt(1, Integer.parseInt((String)vRetResult.elementAt(0)));
			rs = pstmt.executeQuery();
			if(rs.next())
				strAdmSlipNo = rs.getString(1);
			rs.close();
		}

		strTemp = WI.getStrValue(vRetResult.elementAt(7), "&nbsp;");
		if(strTemp.startsWith("-") || strTemp.startsWith("0.00")) {
			strTemp = "OK";
			if(bolIsCDD)
				strTemp = "0.00";

			if(bolOnlyWithBalance) {
				vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
				vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
				continue;
			}
		}
		
		//get GT and GT Finals.
		strStudPlan =  WI.getStrValue(vRetResult.elementAt(7), "0.00");
		if(!strStudPlan.startsWith("-"))
			dGT += Double.parseDouble(ConversionTable.replaceString(strStudPlan, ",",""));
		
		strStudPlan =  WI.getStrValue(vRetResult.elementAt(8), "0.00");
		if(!strStudPlan.startsWith("-"))
			dGTFinals += Double.parseDouble(ConversionTable.replaceString(strStudPlan, ",",""));

	%>
    <tr>
      <td class="thinborder"><%=iStudCount++%>. </td>
<%if(!bolIsSPC) {%>
      <td class="thinborder"><%=WI.getStrValue(strAdmSlipNo,"&nbsp;")%></td>
<%}%>
      <td class="thinborder"><%=vRetResult.elementAt(1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(3)%><%//=WI.getStrValue((String)vRetResult.elementAt(4), "-","","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(5), "-","","")%></td>
 	  <%if(bolIsJonelta) {
	  	iIndexOf = vStudPlanInfo.indexOf(vRetResult.elementAt(0));
		if(iIndexOf == -1) 
			strStudPlan = "&nbsp;";
		else {
			strStudPlan = (String)vStudPlanInfo.remove(iIndexOf + 1);
			vStudPlanInfo.remove(iIndexOf);
		}
		
	  %>
     	<td class="thinborder"><%=strStudPlan%></td>
      <!--course-major-yr-->
<%}if(!bolIsBasic){%>
      <td class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(6),true)%></td>
<%}%>
      <td height="20" class="thinborder"> <%=strTemp%></td>
<%if(bolIsMTerm) {
	  strTemp = WI.getStrValue(vRetResult.elementAt(8), "&nbsp;");
	  if(strTemp.startsWith("-") || strTemp.startsWith("0.00"))
	  	strTemp = "OK";
%>
      <td class="thinborder"><%=strTemp%></td>
<%}%>
    </tr>
	<%
	vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
	vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
	
	if(bolShowGT && vRetResult.size() == 0) {
	%>
		<tr>
		  <td height="20" colspan="7" class="thinborder" align="right">Grade Total: </td>
		  <td height="20" class="thinborder" align="right"><%=CommonUtil.formatFloat(dGT, true)%></td>
		  <%if(bolIsMTerm) {%>
			  <td height="20" class="thinborder" align="right"><%=CommonUtil.formatFloat(dGTFinals, true)%></td>
		  <%}%>
		</tr>
	<%}
	if( (iStudCount-1) %iRowsPerPage == 0)
		break;
	}%>
  </table>

<%}//end of outer while loop..

	}//end of if condition.%>
<input type="hidden" name="show_result" value="<%=WI.fillTextValue("show_result")%>">
<input type="hidden" name="del_projection">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
