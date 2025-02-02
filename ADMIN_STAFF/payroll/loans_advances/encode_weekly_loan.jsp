<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan,payroll.PRMiscDeduction" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Encode Loans for weekly employees</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: block;
	margin-left: 10px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
///////////////////////////////////////// used to collapse and expand filter ////////////////////
function initBranches(){	
	showBranch('branch1','show_schedule');
}
function showBranch(branch, strFieldName){
	if(!document.getElementById(branch))
		return;
	var objBranch = document.getElementById(branch).style;
	if(eval('document.form_.'+strFieldName+'.checked'))
		objBranch.display="block";
	else
		objBranch.display="none";
	
	//if(objBranch.display=="block")
	//	objBranch.display="none";
	//else
	//	objBranch.display="block";
}

///////////////////////////////////////// End of collapse and expand filter ////////////////////

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function DeleteLoan(){
	var vProceed = confirm("This would delete saved loan schedule. Do you want to continue?");
	if(vProceed){
		document.form_.page_action.value = "0";
		this.SubmitOnce('form_');
	}else{
		return;
	}
}

function PageAction(strPageAction, strInfoIndex){
	document.form_.page_action.value = strPageAction;
	if(strPageAction == 1){
		if(document.form_.payable_amt.value.length == 0)
			document.form_.payable_amt.value = document.form_.loan_amount.value;
		document.form_.save.disabled = true;
	}
	document.form_.submit();
	//this.SubmitOnce("form_");
}

function ReloadPage()
{
	document.form_.pageReloaded.value = "";
	ClearFields();
	this.SubmitOnce("form_");
}
function ClearFields()
{
	document.form_.terms.value = "";
	document.form_.loan_amount.value = "";
	document.form_.release_date.value = "";
	document.form_.start_date.value = "";
}

function pageReload()
{
	document.form_.pageReloaded.value = "1";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function focusID() {
	document.form_.emp_id.focus();
}

function UpdateToBlank(strTextName){
	if(eval('document.form_.'+strTextName+'.value') == 0){
		eval('document.form_.'+strTextName+'.value= ""');
	}
}

function CopyID(strID)
{
	document.form_.emp_id.value=strID;
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location = "./encode_weekly_loan.jsp?emp_id="+document.form_.emp_id.value;
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}

function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}


function UpdateSchedule(strRetLoanIndex){
	var loadPg = "update_loan_schedule.jsp?emp_id="+document.form_.emp_id.value+
				 "&code_index="+document.form_.code_index.value+
				 "&loan_type="+document.form_.loan_type.value +
				 "&ret_loan_index="+strRetLoanIndex;
	var win=window.open(loadPg,"updateSchedule",'dependent=yes,width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}
-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-LOANS-Encode Loans (Weekly)","encode_weekly_loan.jsp");
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

	//end of authenticaion code.
	Vector vPersonalDetails = null;
	Vector vRetResult = null;
	Vector vSchedule = null;
	Vector vTemp = null;
	Vector vEditInfo = null;
	Vector vEmpList = null;
	PRMiscDeduction prd = new PRMiscDeduction(request);
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);

	String strPageAction = WI.fillTextValue("page_action");
	String strEmpIndex = null;
	String strLoanType = WI.fillTextValue("loan_type");
	String[] astrTermUnit = {"months","years"};
	String[] astrInterestUnit = {"per year","per month"};
	String strPrepareToEdit = "0";

	String strCurSem  = (String)request.getSession(false).getAttribute("cur_sem");
	String strCurSYFr = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	String strDefault  = null;
	String strMaxtTerm = null;
	String strEmpSchedType = null;
	int j = 0;
	
	double dTotalPay = 0d;
	double dPrincipal = 0d;
	double dInterest = 0d;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";	
	
	if(strSchCode.startsWith("AUF"))
		strTemp = "PS Bank Loans";
	else
		strTemp = "PERAA Loans";
	
	String[] astrLoanType = {"", "", "Internal Loan","SSS Loans","Pag-ibig Loans", strTemp, "GSIS Loans" };

	if (WI.fillTextValue("emp_id").length() > 0) {
		enrollment.Authentication authentication = new enrollment.Authentication();
		vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");

		strEmpIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
		
		if (vPersonalDetails == null || vPersonalDetails.size()==0){
			strErrMsg = authentication.getErrMsg();
			vPersonalDetails = null;
		}
 
		strEmpSchedType = PRRetLoan.checkEmployeeSalaryType(dbOP, request, strEmpIndex);
 		if(strEmpSchedType != null && strEmpSchedType.length() > 0){
			if(!strEmpSchedType.equals("3")){
				strErrMsg = "Cannot process employees with non weekly salary schedule from this page";
				vPersonalDetails = null;
			}	
		}else{
			strErrMsg = "No salary schedule set for the employee";
			vPersonalDetails = null;
		}
		
		if(strPageAction.length() > 0){
			if(PRRetLoan.operateOnWeeklyTypeLoans(dbOP,request,Integer.parseInt(strPageAction)) == null)
				strErrMsg = PRRetLoan.getErrMsg();
			else
				strErrMsg = "Operation Successful";
		}

		if(WI.fillTextValue("code_index").length() > 0){
			vEditInfo = PRRetLoan.operateOnWeeklyTypeLoans(dbOP,request,5);
			if(vEditInfo != null && vEditInfo.size() > 0){
				strPrepareToEdit = "1";
			}
			vRetResult = PRRetLoan.getLoanPaySchedule(dbOP,request);
			if(vRetResult != null && vRetResult.size() > 0){
				vSchedule = (Vector)vRetResult.elementAt(17);			
			}
		}
		vEmpList = prd.getEmployeesList(dbOP);
	}
%>
<body bgcolor="#D2AE72" onLoad="focusID();initBranches();" class="bgDynamic">
<form name="form_" method="post" action="./encode_weekly_loan.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
      PAYROLL : LOANS : ENCODE APPROVED LOAN DATA PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="65%" height="25"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></font></td>
      <td width="35%" align="right"><%
	  		if (vEmpList != null && vEmpList.size() > 0){
			  %>
        <%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) != vEmpList.indexOf((String)vEmpList.elementAt(0))){%>
        <a href="javascript:CopyID('<%=vEmpList.elementAt(0)%>');">FIRST</a>
        <%}else{%>
FIRST
<%}%>
<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) > 0){%>
<a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) - 1)%>');"> PREVIOUS</a>
<%}else{%>
PREVIOUS
<%}%>
<%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) < vEmpList.size()-1){%>
<a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) + 1)%>');"> NEXT</a>
<%}else{%>
NEXT
<%}%>
<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) != vEmpList.size()-1){%>
<a href="javascript:CopyID('<%=((String)vEmpList.elementAt(vEmpList.size()-1)).toUpperCase()%>');">LAST</a>
<%}else{%>
LAST
<%}%>
<%}// if (vEmpList != null && vEmpList.size() > 0)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="21%" height="27"><br>
        Employee ID :</td>
      <td width="76%" height="27"> <font size="1">
        <input name="emp_id" type="text" class="textbox" onKeyUp="AjaxMapName(1);"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16">
        <strong><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></strong>        
        <input type="submit" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;">
        </font><label id="coa_info"></label></td>
    </tr>
  </table>
  <% if (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails != null && vPersonalDetails.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="10" colspan="2"><hr size="1"></td>
    </tr>
    <tr>
      <td width="3%" height="29">&nbsp;</td>
      <td height="29">Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong>
      </td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>Employee ID : <strong><%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <%
		strTemp = (String)vPersonalDetails.elementAt(13);
		if (strTemp == null){
			strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
		}else{
			strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
		}
	  %>
      <td height="29">
        <%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td width="97%">Employment Status<strong> : <%=(String)vPersonalDetails.elementAt(16)%>
        </strong></td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td>
      <td height="26">Loan Type</td>
			<%
				strLoanType = WI.fillTextValue("loan_type");				
				strLoanType = WI.getStrValue(strLoanType, "2");
			%>
      <td height="26" colspan="3">
			<select name="loan_type" onChange="ReloadPage();">
 				<%for(int i = 2; i < astrLoanType.length; i++){
					if(i == 5 && !bolIsSchool)
						continue;
					
					if(strLoanType.equals(Integer.toString(i))){%>	
					<option value="<%=i%>" selected><%=astrLoanType[i]%></option>
				<%}else{%>
					<option value="<%=i%>"><%=astrLoanType[i]%></option>
				<%}
				}%>
      </select>			</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <%
	  	strTemp = WI.fillTextValue("code_index");
	  %>
      <td height="26">&nbsp;Loan Code</td>
      <td height="26" colspan="3"><font size="1"><strong>
        <select name="code_index" onChange="ReloadPage();">
          <option value="">Select Loan</option>
          <%=dbOP.loadCombo("code_index","loan_code, loan_name ",
		                    " from ret_loan_code where is_valid = 1 and loan_type = " + strLoanType +
												" order by loan_code", strTemp ,false)%>
        </select>
        </strong></font></td>
    </tr>
    <%
	vTemp = PRRetLoan.operateOnLoanCode(dbOP,request,5,WI.getStrValue(strTemp,"0"));
	%>
    <tr>
      <td width="3%">&nbsp;</td>
      <%
	  	if(vTemp != null && vTemp.size() > 0){
				if(vTemp.elementAt(13) != null)
					strTemp = (String)vTemp.elementAt(12) + " " + astrTermUnit[Integer.parseInt((String)vTemp.elementAt(13))];				
				else
				 	strTemp = "n/a";
				strMaxtTerm = (String)vTemp.elementAt(12);
			}else{
				strTemp = "";
				strMaxtTerm = "0";
			}
	  %>
	  <input type="hidden" name="max_term" value="<%=strMaxtTerm%>">
      <td width="22%" height="26">&nbsp;Max. Term</td>
      <td><strong><%=WI.getStrValue(strTemp,"")%></strong></td>
      <td height="26">&nbsp;Interest</td>
      <%
	  	if(vTemp != null && vTemp.size() > 0){
				strTemp = (String)vTemp.elementAt(6);
			strTemp = CommonUtil.formatFloat(strTemp, false);
			strTemp = ConversionTable.replaceString(strTemp,",","");
						
			if(Double.parseDouble(strTemp) == 0)
					strTemp = "";
					
			strTemp = WI.getStrValue(strTemp,"","% " +astrInterestUnit[Integer.parseInt((String)vTemp.elementAt(7))],"");			
			}else
				strTemp = "";
	  %>
      <td><strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="17" colspan="5"><hr size="1"></td>
    </tr>		
    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;Amount Loaned<font size="1"><strong> </strong></font></td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String) vEditInfo.elementAt(5);					
			else
				strTemp = WI.fillTextValue("loan_amount");
 
			strTemp = CommonUtil.formatFloat(strTemp, true);
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
			%>			
      <td><font size="1"><strong>
        <input name="loan_amount" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		value="<%=strTemp%>" size="12" maxlength="12"
		onKeyUp="AllowOnlyIntegerExtn('form_','loan_amount','.');"
		onBlur="AllowOnlyIntegerExtn('form_','loan_amount','.');style.backgroundColor='white';">
      </strong></font></td>
      <td height="27">&nbsp;</td>
      <td>&nbsp;<input type="hidden" name="schedule_basis" value="1"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;Amount Payable<font size="1"><strong> </strong></font></td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String) vEditInfo.elementAt(13);					
			else
				strTemp = WI.fillTextValue("payable_amt");
			
			strTemp = CommonUtil.formatFloat(strTemp, true);
			strTemp = ConversionTable.replaceString(strTemp,",","");
			%>			
      <td><font size="1"><strong>
        <input name="payable_amt" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		value="<%=strTemp%>" size="12" maxlength="12"
		onKeyUp="AllowOnlyIntegerExtn('form_','payable_amt','.');"
		onBlur="AllowOnlyIntegerExtn('form_','payable_amt','.');style.backgroundColor='white'">
      </strong></font></td>
      <td height="27">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>

      <td height="27"> &nbsp;Deduction per period </td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String) vEditInfo.elementAt(17);
				else
			  	strTemp = WI.fillTextValue("weekly_amt");			
				strTemp = CommonUtil.formatFloat(strTemp, true);
				strTemp = ConversionTable.replaceString(strTemp,",","");
			%>
      <td width="22%"><font size="1"><strong>
        <input name="weekly_amt" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		value="<%=strTemp%>" size="12" maxlength="12"
		onKeyUp="AllowOnlyIntegerExtn('form_','weekly_amt','.');" 
		onBlur="AllowOnlyIntegerExtn('form_','weekly_amt','.');style.backgroundColor='white'">
      </strong></font></td>
      <td width="16%" height="27">&nbsp;Terms<strong><font size="1"> </font></strong></td>
      <%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String) vEditInfo.elementAt(6);
			else
				strTemp = WI.fillTextValue("terms");
			%>
      <td width="37%"><strong><font size="1">
        <input name="terms" type="text" class="textbox_noborder"value="<%=strTemp%>" readonly size="6"
				 style="text-align:right">
        payments</font></strong>
				<input type="hidden" name="term_unit" value="2">				</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;Release Date<strong> </strong></td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String) vEditInfo.elementAt(7);
		}else
		  	strTemp = WI.fillTextValue("release_date");
	  %>
      <td><strong>
        <input name="release_date" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="yes">
        <a href="javascript:show_calendar('form_.release_date');"><img src="../../../images/calendar_new.gif" border="0"></a>
        </strong></td>
      <td height="27">&nbsp;First Payment</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String) vEditInfo.elementAt(15);
		else
		  	strTemp = WI.fillTextValue("start_date");
	  %>
      <td> <strong>
        <input name="start_date" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="yes">
        <a href="javascript:show_calendar('form_.start_date');"><img src="../../../images/calendar_new.gif" border="0"></a>
        </strong></td>
    </tr>
    
    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;Loan Reference No. </td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String) vEditInfo.elementAt(22);
			}else
					strTemp = WI.fillTextValue("reference_no");
			%>				
      <td height="27" colspan="3"><input name="reference_no" type="text" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			value="<%=WI.getStrValue(strTemp)%>" size="32" maxlength="32"><font size="1">(optional)</font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;Remarks</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String) vEditInfo.elementAt(21);
			}else
					strTemp = WI.fillTextValue("loan_remarks");
			%>			
      <td height="27" colspan="3">
			<textarea name="loan_remarks" cols="40" rows="2" class="textbox"
	  onFocus="CharTicker('form_','256','loan_remarks','count_');style.backgroundColor='#D3EBFF'" 
	  onBlur ="CharTicker('form_','256','loan_remarks','count_');style.backgroundColor='white'" 
	  onKeyUp="CharTicker('form_','256','loan_remarks','count_');"><%=WI.getStrValue(strTemp)%></textarea>
      <input name="count_" type="text" class="textbox_noborder" tabindex="-1" size="4" readonly="yes"><font size="1">(optional)</font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("use_4");
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
			%>				
      <td height="27" colspan="4"><input type="checkbox" name="use_4" value="1" <%=strTemp%>>
        deduct only on first four(4) schedules of the month </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String) vEditInfo.elementAt(19);
				else
					strTemp = WI.fillTextValue("use_flat");

				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
			%>			
      <td height="27" colspan="4"><input type="checkbox" name="use_flat" value="1" <%=strTemp%>>
use flat method to compute for the interest. <font size="1">[interest amt = (loan amount * interest rate)/ duration]</font></td>
    </tr>
    <tr>
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%if(WI.fillTextValue("code_index").length() > 0 && (WI.fillTextValue("code_index").toLowerCase()).startsWith("r")){%>
    <tr>
      <td width="100%" height="10">&nbsp;</td>
    </tr>
    <%}// end if if(WI.fillTextValue("loan_type").equals("1")%>
		<%if (iAccessLevel > 1) { //if iAccessLevel > 1%>
    <tr>
      <td height="30" align="center">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <!--
					<a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a>
					-->
				<input type="button" name="save" value="  Save  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');">
				<font size="1"> click to save entries</font>
        <%}else{%>
        <!--
					<a href="javascript:PageAction(2,'<%=(String)vEditInfo.elementAt(0)%>','');"><img src="../../../images/edit.gif"border="0"></a>
					-->
				<input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction(2,'<%=(String)vEditInfo.elementAt(0)%>','');">
				<font size="1">click to save changes</font>
        <%}%>
        <!--
					<a href="encode_weekly_loan.jsp?emp_id=<%=WI.fillTextValue("emp_id")%>"><img src="../../../images/cancel.gif" border="0"></a>
					-->
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">					
			    <font size="1">click to cancel/clear entries </font></td>
    </tr>
	<%if(strPrepareToEdit.compareTo("1") == 0) {%>
    <tr>
      <td height="10" align="center"><font size="1"><a href="javascript:DeleteLoan();">
        <input type="button" name="edit2" value=" DELETE " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:DeleteLoan();"></a>
				click to DELETE LOAN </font></td>
    </tr>
    <tr>
      <td height="10" align="center"><font size="1">
        <input type="button" name="edit22" value=" UPDATE " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:UpdateSchedule('<%=(String)vEditInfo.elementAt(0)%>');">
					click to Update interest schedule </font></td>
    </tr>
	<%}%>
	<%} // if (iAccessLevel > 1) %>
  </table>
	<%if(vSchedule != null && vSchedule.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td><%
			strTemp = WI.fillTextValue("show_schedule");
			if(strTemp.equals("1"))
				strTemp = "checked";
			else
				strTemp = "";
		%>			
			<label for="schedule_">
					<input type="checkbox" name="show_schedule" value="1" <%=strTemp%> id="schedule_" 
					onClick="showBranch('branch1','show_schedule')" tabindex="-1"/>
					<strong><u><font color="#400000">Show / Hide Schedule </font></u></strong></label>
					
			<span class="branch" id="branch1">
			<table width="80%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr bgcolor="#99CCFF"> 
				<td height="25" colspan="6" align="center" class="BorderAll"><strong>:: 
						SCHEDULE OF SALARY DEDUCTIONS FOR LOAN PAYMENTS ::</strong></td>
			</tr>
			<tr> 
				<td width="20%" height="24" align="center" class="BorderBottomLeft"><strong><font size="1">PAYROLL 
				PERIOD</font></strong></td>
				<td width="20%" height="24" align="center" class="BorderBottomLeft"><strong><font size="1">TOTAL</font></strong></td>
				<td height="20" colspan="2" align="center" class="BorderBottomLeft"><strong><font size="1"> PRINCIPAL</font></strong></td>
				<td width="20%" align="center" class="BorderBottomLeft"><strong><font size="1"> INTEREST</font></strong></td>
				<td width="20%" align="center" class="BorderBottomLeftRight"><strong><font size="1">PRINCIPAL 
				BALANCE</font></strong></td>
			</tr>
			<tr> 
				<td height="10" colspan="6"><hr size="1"></td>
			</tr>
			<%if(vSchedule != null && vSchedule.size() > 0){
				for(;j < vSchedule.size();j+=9){
				if(j%2 == 0)
					strTemp= "bgcolor=#EEEEEE";
				else
					strTemp= "";
				%>
			<tr <%=strTemp%>> 
				<td height="18"><%=(String)vSchedule.elementAt(j)%> <%=(String)vSchedule.elementAt(j+1)%>, <%=(String)vSchedule.elementAt(j+2)%></td>
				<%
				strTemp = (String)vSchedule.elementAt(j+3);
			dTotalPay += Double.parseDouble(strTemp);
			%>
			<td height="18" align="right"><%=(String)vSchedule.elementAt(j+3)%>&nbsp;</td>
				<%
				strTemp = (String)vSchedule.elementAt(j+4);
			dPrincipal += Double.parseDouble(strTemp);
			%>	  
				<td height="18" colspan="2" align="right"><%=(String)vSchedule.elementAt(j+4)%>&nbsp;</td>
				<%
				strTemp = (String)vSchedule.elementAt(j+5);
			dInterest += Double.parseDouble(strTemp);
			%>
				<td align="right"><%=(String)vSchedule.elementAt(j+5)%>&nbsp;</td>  
				<td align="right"><%=(String)vSchedule.elementAt(j+6)%>&nbsp;</td>
			</tr>
			<%}
		}%>
			<tr> 
				<td height="14" colspan="6"><hr size="1"></td>
			</tr>
			<tr> 
				<td>TOTAL :</td>	  
				<td height="24" align="right"><%=CommonUtil.formatFloat(dTotalPay,true)%></td>
				<td height="24" colspan="2" align="right"><%=CommonUtil.formatFloat(dPrincipal,true)%></td>
				<td align="right"><%=CommonUtil.formatFloat(dInterest,true)%></td>
				<td align="right">&nbsp;</td>
			</tr>
			<!--
		<tr> 
				<td height="25" colspan="6"><div align="center"><font size="1"><a href='javascript:SaveClicked();'><img src="../../../../images/save.gif" border="0" name="hide_save"></a>click 
						to save entries</font></div></td>
			</tr>
		-->
		</table>
			
			</span>	</td>
    </tr>
  </table>
	
	<%} // end if vSchedule != null && vSchedule.size() > 0
  }// largest if... (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails != null && vPersonalDetails.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="pageReloaded">
 <input type="hidden" name="print_page"> 
 <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>