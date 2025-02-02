<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
//// - all about ajax..
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

//print admission slip.
function printExamPermit() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);

	window.print();
}
function ReloadPage() {
	document.form_.show_result.value='';
	document.form_.submit();
}
function GoToPromisory() {
	location = "./promisory_note.jsp?stud_id="+document.form_.stud_id.value+"&sy_from="+
	document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+"&semester="+
	document.form_.semester[document.form_.semester.selectedIndex].value+"&pmt_schedule="+
	document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value;
}

</script>
<%
	DBOperation dbOP = null;
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-PAYMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
		//may be called from registrar.
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}




//add security here.
	try
	{
		dbOP = new DBOperation();
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

boolean bolIsBasic = false;
if(WI.fillTextValue("is_basic").length() > 0) 
	 bolIsBasic = true;	
	 
String strExamName = null;
String strExamPeriod = null;
String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

String strStudID   = WI.fillTextValue("stud_id");
String strSYFrom   = WI.fillTextValue("sy_from");
String strSYTo     = WI.fillTextValue("sy_to");
String strSemester = WI.fillTextValue("semester");
strExamPeriod      = WI.fillTextValue("pmt_schedule");

Vector vRetResult  = null;//get subject schedule information.

boolean bolAllowPrinting = false;
String strAdmSlipPrnNumber = null;


Vector vStudInfo   = null; double dDueForThisPeriod = 0d;
if(WI.fillTextValue("show_result").length() > 0) {
	enrollment.EnrlAddDropSubject enrlStudInfo = new enrollment.EnrlAddDropSubject();
	vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),	strStudID,strSYFrom, strSYTo, strSemester);
		//check if rfid is scanned.. 
	if(dbOP.strBarcodeID != null)
		strStudID = dbOP.strBarcodeID;

	
	if(vStudInfo == null)
		strErrMsg = enrlStudInfo.getErrMsg();
	else {
		if(vStudInfo.elementAt(2) == null) {
			if(!bolIsBasic) {
				strErrMsg = "Please enter ID of Grade School Student.";
				vStudInfo = null;
			}
		}
		else {
			if(bolIsBasic) {
				strErrMsg = "Please enter ID of College Student.";
				vStudInfo = null;
			}
		}
	}
}

if(vStudInfo != null && vStudInfo.size() > 0) {
	//check if already having adm slip created..
	String strSQLQuery = "select ADM_SLIP_NUMBER from ADM_SLIP_PRN_COUNT where user_index = " + vStudInfo.elementAt(0) + " and pmt_sch_index = " +
          strExamPeriod + " and sy_from = " + strSYFrom + " and semester = " +strSemester;
	strAdmSlipPrnNumber = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strAdmSlipPrnNumber == null) {//check for PN
		strSQLQuery = "select pn_index from FA_STUD_PROMISORY_NOTE where user_index = " + vStudInfo.elementAt(0) + " and pmt_sch_index = " +
          strExamPeriod + " and sy_from = " + strSYFrom + " and semester = " +strSemester+" and is_valid = 1";
		strAdmSlipPrnNumber = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strAdmSlipPrnNumber != null) {
			strAdmSlipPrnNumber = new enrollment.ReportEnrollment().autoGenAdmSlipNum(dbOP, (String)vStudInfo.elementAt(0),strExamPeriod, strSYFrom, strSemester,
                            (String)request.getSession(false).getAttribute("userIndex"));
		}
	}
	else
		bolAllowPrinting = true;

	if(strAdmSlipPrnNumber == null && strSemester.equals("0")) {//if summer, i have to check if enroled in 1st sem.
		String strAdvanceSY = Integer.toString(Integer.parseInt(strSYFrom) + 1);
		strSQLQuery = "select cur_hist_index from stud_Curriculum_hist where sy_from = "+strAdvanceSY+" and semester = 1 and is_valid = 1 and user_index = "+
								(String)vStudInfo.elementAt(0);
		if(dbOP.getResultOfAQuery(strSQLQuery, 0) != null) {
			strAdmSlipPrnNumber = new enrollment.ReportEnrollment().autoGenAdmSlipNum(dbOP, (String)vStudInfo.elementAt(0),strExamPeriod, strSYFrom, strSemester,
                            (String)request.getSession(false).getAttribute("userIndex"));		
			bolAllowPrinting = true;
		}
	}

	if(strAdmSlipPrnNumber == null) {	
		enrollment.FAAssessment FA = new enrollment.FAAssessment();
		FA.setIsBasic(bolIsBasic);
		
		Vector vInstallmentDtls = FA.getInstallmentSchedulePerStudPerExamSch(dbOP,strExamPeriod, (String)vStudInfo.elementAt(0),
								strSYFrom,strSYTo,(String)vStudInfo.elementAt(4), strSemester) ;
		if(vInstallmentDtls == null)
			strErrMsg = FA.getErrMsg();
		else {
			dDueForThisPeriod = Double.parseDouble((String)vInstallmentDtls.elementAt(5));
			//System.out.println("Before : "+dDueForThisPeriod);
	/**		if(dDueForThisPeriod >= 1d) {
				//get bank payment..
				strTemp = "select sum(amount) from FA_STUD_TEMP_POSTING_PAYMENT where stud_index = "+vStu//dInfo.elementAt(0)+
							"and sy_from =  "+strSYFrom+" and semester = "+strSemester+
						" and is_valid = 1 and payment_for = "+strExamPeriod+ " and is_temp_stud = 0";
				strTemp = dbOP.getResultOfAQuery(strTemp, 0);
				if(strTemp != null && strTemp.length() > 0)
					dDueForThisPeriod = dDueForThisPeriod - Double.parseDouble(strTemp);
			}
	**/		//System.out.println("After : "+dDueForThisPeriod);
			//System.out.println(vInstallmentDtls);
			if(true || dDueForThisPeriod >= 1d) {
				vInstallmentDtls = FA.getInstallmentSchedulePerStudAllInOne(dbOP, (String)vStudInfo.elementAt(0),strSYFrom,strSYTo,(String)vStudInfo.elementAt(4), strSemester);
				if(vInstallmentDtls != null && vInstallmentDtls.size() > 0) {
					double dOSBalance = Double.parseDouble(ConversionTable.replaceString((String)vInstallmentDtls.elementAt(6),",",""));
					if(dOSBalance < dDueForThisPeriod)
						dDueForThisPeriod = dOSBalance;

				}
				//System.out.println("Before2 : "+dDueForThisPeriod);
			}
			if(dDueForThisPeriod < 1d) {
				dDueForThisPeriod = 0d;
				bolAllowPrinting = true;
				strAdmSlipPrnNumber = new enrollment.ReportEnrollment().autoGenAdmSlipNum(dbOP, (String)vStudInfo.elementAt(0),strExamPeriod, strSYFrom, strSemester,
                            (String)request.getSession(false).getAttribute("userIndex"));
			}
			else {
				strErrMsg = "Balance for this Period: "+CommonUtil.formatFloat(dDueForThisPeriod,true);
			}
		}
	}//call this only if adm sli pnumber is null
}//System.out.println("Before3 : "+dDueForThisPeriod);
%>
<body onLoad="document.form_.stud_id.focus();<%if(bolAllowPrinting){%>printExamPermit();<%}%>">
<form name="form_" action="./charge_slip_print_control_number_ub.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr>
      <td height="25" align="center"><b>:::: PRINT ADMISSION SLIP PAGE :::: </b></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font style="font-size:16px; font-weight:bold; color:#FF0000"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr valign="top">
      <td height="25">&nbsp;</td>
      <td height="25">Student ID </td>
      <td height="25" colspan="2">
	  <input name="stud_id" type="text" size="24" maxlength="24" value="<%=strStudID%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxMapName('1');">
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="13%" height="25">SY/TERM</td>
      <td height="25" colspan="2"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

		// force to 1 (regular for basic ) if not summer and if basic
		if (WI.fillTextValue("is_basic").equals("1") && !strTemp.equals("0"))
			strTemp = "1";

		  if(strTemp.equals("1")){
		  %>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp;&nbsp;
		<input type="checkbox" name="is_basic" value="checked" <%=WI.fillTextValue("is_basic")%> onClick="ReloadPage();">
        <font color="#0000FF" size="1"><strong>Show For Grade School</strong></font>		</td>
    </tr>
    <tr>
      <td width="2%">&nbsp;</td>
      <td height="25">Exam Period</td>
      <td width="14%" height="25"><select name="pmt_schedule">
        <%if(bolIsBasic){%>
        <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=2 and bsc_grading_name is not null order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
        <%}else{%>
        <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
        <%}%>
      </select></td>
      <td width="71%">
	  <%//if(dDueForThisPeriod > 0d) {%>
	  	<!--
		<font style="font-weight:bold; font-size:14px; color:#FF0000">Balance for this Period: <%=CommonUtil.formatFloat(dDueForThisPeriod,true)%>
		-->
	  <%//}%>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">
	  <input type="submit" name="1" value="&nbsp;&nbsp;Show Result&nbsp;&nbsp;"
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_result.value='1'"></td>
      <td height="25" align="right"><a href="javascript:GoToPromisory();">Go to Promisory Note</a></td>
    </tr>
  </table>


<%if(strAdmSlipPrnNumber != null){
strExamName = "select exam_name from fa_pmt_schedule where pmt_sch_index = "+strExamPeriod;
if(bolIsBasic)
	strExamName = "select bsc_grading_name from fa_pmt_schedule where pmt_sch_index = "+strExamPeriod;
	
strExamName = dbOP.getResultOfAQuery(strExamName, 0);
strExamName = strExamName.toLowerCase();

String strPrelim    = "&nbsp;";
String strMTerm     = "&nbsp;";
String strSemiFinal = "&nbsp;";
String strFinals    = "&nbsp;";

if(!bolIsBasic) {
	if(strExamName.startsWith("p"))
		strPrelim = "P"+strAdmSlipPrnNumber;
	else if(strExamName.startsWith("m"))
		strMTerm = "M"+strAdmSlipPrnNumber;
	else if(strExamName.startsWith("s"))
		strSemiFinal = "S"+strAdmSlipPrnNumber;
	else if(strExamName.startsWith("fin"))
		strFinals = "F"+strAdmSlipPrnNumber;
}
else {
	if(strExamName.startsWith("first"))
		strPrelim = "B1-"+strAdmSlipPrnNumber;
	else if(strExamName.startsWith("second"))
		strMTerm = "B2-"+strAdmSlipPrnNumber;
	else if(strExamName.startsWith("third"))
		strSemiFinal = "B3-"+strAdmSlipPrnNumber;
	else if(strExamName.startsWith("fourth"))
		strFinals = "B4-"+strAdmSlipPrnNumber;
}


%>
<!--
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td colspan="2" style="font-size:9px;" align="right"><a href="javascript:printExamPermit();"><img src="../../../images/print.gif" border="0"></a>Print Admission Slip &nbsp;&nbsp;</td>
  </tr>
</table>
-->
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td>
	  <table width="100%" cellpadding="0" cellspacing="0">
	  	<tr>
			<td width="25%" align="center"><table cellpadding="0" cellspacing="0"><tr><td width="117" height="24" align="center" style="font-weight:bold; font-size:16px;"><%=strPrelim%></td></tr></table></td>
			<td width="25%" align="center"><table cellpadding="0" cellspacing="0"><tr><td width="117" height="24" align="center" style="font-weight:bold; font-size:16px;"><%=strMTerm%></td></tr></table></td>
			<td width="25%" align="center"><table cellpadding="0" cellspacing="0"><tr><td width="117" height="24" align="center" style="font-weight:bold; font-size:16px;"><%=strSemiFinal%></td></tr></table></td>
			<td width="25%" align="center"><table cellpadding="0" cellspacing="0"><tr><td width="117" height="24" align="center" style="font-weight:bold; font-size:16px;"><%=strFinals%></td></tr></table></td>
		</tr>
	  </table>
	</td>
  </tr>
</table>

<%}//vRetResult is not null%>
  <input type="hidden" name="show_result">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
