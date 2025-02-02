<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan" %>
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
<title>Encode Retirement Loans</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>

<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PageAction(strPageAction, strInfoIndex){	
	document.form_.page_action.value = strPageAction;
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex,strPayable){	
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.payable.value = strPayable;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function ReloadPage()
{	
	document.form_.pageReloaded.value = "";
	this.SubmitOnce("form_");
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
function CheckTerm(){
	var vGrade = "";
	eval("vGrade = document.form_.terms.value");
	if (eval(vGrade) > 5 || eval(vGrade) < 1){
		alert ("Term should only be from 1 to 5");
		eval("document.form_.terms.value = 5 ");		
		return;
	}
}

function ViewSchedule() {
	var pgLoc = "../reports/sched_ind_payments.jsp?proceed=1&viewOnly=1&emp_id="+document.form_.emp_id.value+
				"&code_index="+document.form_.code_index.value;
	var win=window.open(pgLoc,"View",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("RETIREMENT-LOANS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("RETIREMENT"),"0"));
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
								"Admin/staff-RETIREMENT-ENCODE_LOADNS-Create Loans","loans_advances_entry.jsp");
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
	Vector vInfoDetail = null;
	
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);

	String strPageAction = WI.fillTextValue("page_action");
	String strEmpIndex = null;
	String strLoanType = WI.fillTextValue("loan_type");
	String strDefault  = null;
	String strReadOnly = null;

	String strCurSYFr  = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	String strCurSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	String strCurSem = (String)request.getSession(false).getAttribute("cur_sem");
	boolean bolShowView = false;
		
	if (WI.fillTextValue("emp_id").length() > 0) {
		enrollment.Authentication authentication = new enrollment.Authentication();
		vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
				
		strEmpIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
		strLoanType = WI.getStrValue(strLoanType,"0");	
		strTemp = dbOP.mapOneToOther("retirement_loan " +
									 " join ret_loan_code on(ret_loan_code.code_index = retirement_loan.code_index)" ,
									 "is_finished", "0" , "ret_loan_index" ,
	                                 " and retirement_loan.is_valid = 1 and user_index= " + strEmpIndex +
									 " and loan_type = " + strLoanType);
		if(strTemp != null){
			strErrMsg = "Employee still has an active loan";
			bolShowView = true;
		}else{
			bolShowView = false;
		}
		

		if (vPersonalDetails == null || vPersonalDetails.size()==0){
			strErrMsg = authentication.getErrMsg();
			vPersonalDetails = null;
		}
		
		if(strPageAction.length() > 0){
			if(PRRetLoan.operateOnRetirementLoan(dbOP,request,Integer.parseInt(strPageAction)) == null)
				strErrMsg = PRRetLoan.getErrMsg();
			else
				strErrMsg = "Operation Successful";		
		}		
	}	
%>
<body bgcolor="#D2AE72" onLoad="focusID();" class="bgDynamic">
<form name="form_" method="post" action="./encode_loans_data.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::RETIREMENT 
          - LOANS - ENCODE LOANS DATA PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="21%" height="27"><br>
        Employee ID :</td>
      <td width="76%" height="27"> <font size="1"> 
        <input name="emp_id" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16">
        <strong><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></strong> 
        <a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a> 
        </font></td>
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
      <td height="29">Employee ID : <strong><%=WI.fillTextValue("emp_id")%></strong></td>
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
        <%if(bolIsSchool){%>
        College
        <%}else{%>
        Division
        <%}%>
        /Office : <strong><%=strTemp%></strong></td>
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
      <td height="25" colspan="2"><hr size="1" noshade></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td>
      <td height="26">Loan Type :</td>
      <% 
		  strLoanType = WI.fillTextValue("loan_type");			
		  strLoanType = WI.getStrValue(strLoanType,"0");
		  
		  strDefault = dbOP.mapOneToOther("RET_LOAN_CODE","is_valid","1","code_index",
		  								  " and sy_from = " + strCurSYFr + 
										  " and semester = " + strCurSem + 
										  " and loan_type = " + strLoanType);
	  %>	  
      <td height="26"><select name="loan_type" onChange="pageReload();">
          <option value="0">Regular Retirement Fund</option>
          <%if(strLoanType.equals("1")){%>
          <option value="1" selected>Emergency</option>
          <%}else{%>
          <option value="1">Emergency</option>
          <%}%>
        </select></td>
      <td height="26">&nbsp;</td>
      <td height="26">&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="16%" height="26">Loan Code :</td>
      <%
	  	strTemp = WI.fillTextValue("code_index");
		if (strTemp.length() == 0)
			strTemp = strDefault;		
	  %>
      <td width="31%" height="26"> <font size="1"><strong> 
        <select name="code_index">
          <%=dbOP.loadCombo("code_index","loan_code", " from ret_loan_code where is_valid = 1 and loan_type=" + strLoanType, strTemp ,false)%> 
        </select>
        </strong></font></td>
      <td height="26">Loan Bank : </td>
      <td height="26"> <%
	   	strTemp = WI.fillTextValue("bank_index");
	   %> <select name="bank_index">
          <option value="">Select Bank</option>
          <%=dbOP.loadCombo("BANK_INDEX","BANK_NAME", " from AC_COA_BANKCODE WHERE is_valid = 1", strTemp,false)%> </select></td>
    </tr>
    <tr> 
      <td height="27" colspan="5"><hr size="1"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27">Amount Loaned :</td>
      <%
	  	strTemp = WI.fillTextValue("loan_amount");
	  %>
	  
      <td height="27"><font size="1"><strong> 
        <input name="loan_amount" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		value="<%=strTemp%>" size="12" maxlength="12" 
		onKeyUp="AllowOnlyIntegerExtn('form_','loan_amount','.');"
		onBlur="AllowOnlyIntegerExtn('form_','loan_amount','.');style.backgroundColor='white'">
        </strong></font></td>
      <td width="17%" height="27">Terms : </td>
      <%
	  	strTemp = WI.fillTextValue("terms");
		
		if(strLoanType.equals("1")){
			strTemp = "1";
			strReadOnly = "readonly";
		}else{
			strReadOnly = "";
		}
	  %>
	  
      <td width="33%" height="27"><strong><font size="1"> 
        <input name="terms" type="text" class="textbox"onFocus="style.backgroundColor='#D3EBFF'" 
		value="<%=strTemp%>" size="2" maxlength="1" onKeyUp="AllowOnlyInteger('form_','terms');"	 
	    onBlur="AllowOnlyInteger('form_','terms');CheckTerm();style.backgroundColor='white'" <%=strReadOnly%>>
        </font></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27">Voucher Date / Release date:</td>
      <%
	  	strTemp = WI.fillTextValue("release_date");
	  %>
      <td height="27"><strong> 
        <input name="release_date" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="yes">
        <a href="javascript:show_calendar('form_.release_date');"><img src="../../../images/calendar_new.gif" border="0"></a> 
        </strong></td>
      <td height="27">
	  <%if(strLoanType.equals("1")){%>
	  First Payment date:
	  <%}%>
	  </td>
      <td height="27"><strong>
	  <%if(strLoanType.equals("1")){%>
        <input name="start_date" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="yes">
        <a href="javascript:show_calendar('form_.start_date');"><img src="../../../images/calendar_new.gif" border="0"></a> 
	   <%}%>		
        </strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%if(strLoanType.equals("0")){%>
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="28%" height="25">Active Amount, 1st year (1) : </td>
      <%
			strTemp = WI.fillTextValue("active_amt1");
		%>
      <td width="69%" height="25"><font size="1"><strong> 
        <input name="active_amt1" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		value="<%=strTemp%>" size="12" maxlength="12" 
		onKeyUp="AllowOnlyIntegerExtn('form_','active_amt1','.');"
		onBlur="AllowOnlyIntegerExtn('form_','active_amt1','.');style.backgroundColor='white'">
        </strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Active Amount, 2nd year (2) : </td>
	  <%
		strTemp = WI.fillTextValue("active_amt2");
	  %>
      <td height="25"><font size="1"><strong> 
        <input name="active_amt2" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		value="<%=strTemp%>" size="12" maxlength="12" 
		onKeyUp="AllowOnlyIntegerExtn('form_','active_amt2','.');"
		onBlur="AllowOnlyIntegerExtn('form_','active_amt2','.');style.backgroundColor='white'">
        </strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Active Amount, 3rd year (3) : </td>
      <%
			strTemp = WI.fillTextValue("active_amt3");
		%>
      <td height="25"><font size="1"><strong> 
        <input name="active_amt3" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		value="<%=strTemp%>" size="12" maxlength="12" 
		onKeyUp="AllowOnlyIntegerExtn('form_','active_amt3','.');"
		onBlur="AllowOnlyIntegerExtn('form_','active_amt3','.');style.backgroundColor='white'">
        </strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Active Amount, 4th year (4) : </td>
      <%
			strTemp = WI.fillTextValue("active_amt4");
		%>
      <td height="25"><font size="1"><strong> 
        <input name="active_amt4" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		value="<%=strTemp%>" size="12" maxlength="12" 
		onKeyUp="AllowOnlyIntegerExtn('form_','active_amt4','.');"
		onBlur="AllowOnlyIntegerExtn('form_','active_amt4','.');style.backgroundColor='white'">
        </strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Active Amount, 5th year (5) : </td>
      <%
			strTemp = WI.fillTextValue("active_amt5");
		%>
      <td height="25"><font size="1"><strong> 
        <input name="active_amt5" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		value="<%=strTemp%>" size="12" maxlength="12" 
		onKeyUp="AllowOnlyIntegerExtn('form_','active_amt5','.');"
		onBlur="AllowOnlyIntegerExtn('form_','active_amt5','.');style.backgroundColor='white'">
        </strong></font></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <%}// end if if(WI.fillTextValue("loan_type").equals("1") %>
    <tr> 
      <td height="30" colspan="3"><div align="center"><font size="1"><a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a>click 
          to save entries <a href="#"><img src="../../../images/cancel.gif" border="0"></a>click 
          to cancel/clear entries </font></div></td>
    </tr>
    <%if(bolShowView){%>
	<tr> 
      <td height="10" colspan="3"><div align="center"><font size="1"><a href="javascript:ViewSchedule();"><img src="../../../images/view.gif" border="0"></a>click 
          to VIEW PAYMENT SCHEDULE</font></div></td>
    </tr>
	<%}%>		
  </table>
  <%}// largest if... (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails != null && vPersonalDetails.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="pageReloaded">
 <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>