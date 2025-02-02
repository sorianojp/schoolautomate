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
<title>Untitled Document</title>
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

function DeleteLoan(strLoanIndex){
	var vProceed = confirm("This would delete saved loan schedule. Do you want to continue?");
	if(vProceed){
		document.form_.prepareToEdit.value = "0";
		document.form_.page_action.value = "";
		document.form_.loan_index.value = strLoanIndex;	
		document.form_.recompute.value = "1";
		this.SubmitOnce('form_');
	}else{
		return;
	}
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
function CheckTerm(){
	var vGrade = "";
	var vMaxTerm = "";
	eval("vGrade = document.form_.terms.value");
	eval("vMaxTerm = document.form_.max_term.value");
	if (eval(vGrade) > eval(vMaxTerm) || eval(vGrade) < 1){
		alert ("Term should only be from 1 to " + vMaxTerm);
		eval("document.form_.terms.value = vMaxTerm");
		return;
	}
}

function CheckLoanCode(){
	if(document.form_.code_index.value.length == 6){
	ReloadPage();
	}
}

function ViewSchedule() {
	var pgLoc = "../../retirement/reports/sched_ind_payments.jsp?proceed=1&viewOnly=1&emp_id="+document.form_.emp_id.value+
				"&code_index="+document.form_.code_index.value+
				"&loan_type="+document.form_.loan_type.value;
	var win=window.open(pgLoc,"View",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function CopyID(strID)
{
	document.form_.emp_id.value=strID;
	this.SubmitOnce("form_");
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
	Vector vTemp = null;
	Vector vEditInfo = null;
	Vector vEmpList = null;
	PRMiscDeduction prd = new PRMiscDeduction(request);
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);

	String strPageAction = WI.fillTextValue("page_action");
	String strEmpIndex = null;
	String strLoanType = WI.fillTextValue("loan_type");
	String[] astrTermUnit = {"months","years"};
	String strPrepareToEdit = "0";

    String strCurSem  = (String)request.getSession(false).getAttribute("cur_sem");
    String strCurSYFr = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	String strDefault  = null;
	String strReadOnly = null;
	String strMaxtTerm = null;

	if (WI.fillTextValue("emp_id").length() > 0) {
		enrollment.Authentication authentication = new enrollment.Authentication();
		vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");

		strEmpIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
/*		strLoanType = WI.getStrValue(strLoanType,"2");
		strTemp = dbOP.mapOneToOther("retirement_loan " +
									 " join ret_loan_code on(ret_loan_code.code_index = retirement_loan.code_index)" ,
									 "is_finished", "0" , "ret_loan_index" ,
	                                 " and retirement_loan.is_valid = 1 and user_index= " + strEmpIndex +
									 " and loan_type = " + strLoanType);
		if(strTemp != null)
			strErrMsg = "Employee still has an active loan";
*/
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

		if(WI.fillTextValue("code_index").length() > 0){
			vEditInfo = PRRetLoan.operateOnRetirementLoan(dbOP,request,5);
			if(vEditInfo != null && vEditInfo.size() > 0){
				strPrepareToEdit = "1";
			}
		}
		vEmpList = prd.getEmployeesList(dbOP);
	}
%>
<body bgcolor="#D2AE72" onLoad="focusID();" class="bgDynamic">
<form name="form_" method="post" action="./encode_approved_loan.jsp">
<input type="hidden" name="loan_type" value="2">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          PAYROLL : LOANS : ENCODE APPROVED LOAN DATA PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="54%" height="25"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></font></td>
      <td width="46%"><div align="right">
      <%
	  	if (vEmpList != null && vEmpList.size() > 0){
	  %>
		<%if (vEmpList.indexOf(WI.fillTextValue("emp_id")) != vEmpList.indexOf((String)vEmpList.elementAt(0))){%>
		  <a href="javascript:CopyID('<%=vEmpList.elementAt(0)%>');">FIRST</a>
		<%}else{%>
		  FIRST
		<%}%>

		<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) > 0){%>
          <a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) - 1)%>');"> PREVIOUS</a>
        <%}else{%>
		  PREVIOUS
		<%}%>

        <%if (vEmpList.indexOf(WI.fillTextValue("emp_id")) < vEmpList.size()-1){%>
             <a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) + 1)%>');"> NEXT</a>
        <%}else{%>
		     NEXT
		<%}%>

		<%if (vEmpList.indexOf(WI.fillTextValue("emp_id")) != vEmpList.size()-1){%>
		  <a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.size()-1)%>');">LAST</a>
        <%}else{%>
		  	LAST
		<%}%>

	  <%}// if (vEmpList != null && vEmpList.size() > 0)%>
      </div></td>
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
        <a href="javascript:ReloadPage()"></a>
        <input type="submit" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;">
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
      <td height="25" colspan="2"><hr size="1" noshade></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td>
      <%
	  	strTemp = WI.fillTextValue("code_index");
	  %>
      <td height="26">&nbsp;Loan Code : <font size="1"><strong> </strong></font>
      </td>
      <td height="26" colspan="3"><font size="1"><strong>
        <select name="code_index" onChange="ReloadPage();">
          <option value="">Select Loan</option>
          <%=dbOP.loadCombo("code_index","loan_name, loan_code",
		                    " from ret_loan_code where is_valid = 1 and loan_type = 2",
							strTemp ,false)%>
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
				strTemp = (String)vTemp.elementAt(12) + " " + astrTermUnit[Integer.parseInt((String)vTemp.elementAt(13))];
				strMaxtTerm = (String)vTemp.elementAt(12);
			}else{
				strTemp = "";
				strMaxtTerm = "0";
			}
	  %>
	  <input type="hidden" name="max_term" value="<%=strMaxtTerm%>">
      <td width="18%" height="26">&nbsp;Max. Term : </td>
      <td><strong><%=WI.getStrValue(strTemp,"")%></strong></td>
      <td height="26">&nbsp;Interest :</td>
      <%
	  	if(vTemp != null && vTemp.size() > 0)
			strTemp = (String)vTemp.elementAt(6);
		else
			strTemp = "";
	  %>
      <td><strong><%=WI.getStrValue(strTemp,"")%> % per annum</strong></td>
    </tr>
    <tr>
      <td height="17" colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>

      <td height="27">&nbsp;Amount Loaned : <font size="1"><strong> </strong></font></td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String) vEditInfo.elementAt(5);
			strTemp = ConversionTable.replaceString(strTemp,",","");
		}else
		  	strTemp = WI.fillTextValue("loan_amount");
	  %>
      <td width="22%"><font size="1"><strong>
        <input name="loan_amount" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		value="<%=strTemp%>" size="12" maxlength="12"
		onKeyUp="AllowOnlyIntegerExtn('form_','loan_amount','.');"
		onBlur="AllowOnlyIntegerExtn('form_','loan_amount','.');style.backgroundColor='white'">
        </strong></font></td>
      <td width="16%" height="27">&nbsp;Terms : <strong><font size="1"> </font></strong></td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String) vEditInfo.elementAt(6);
		}else
		  	strTemp = WI.fillTextValue("terms");
	  %>
      <td width="41%"><strong><font size="1">
        <input name="terms" type="text" class="textbox"onFocus="style.backgroundColor='#D3EBFF'"
		value="<%=strTemp%>" size="4" maxlength="4"
	    onKeyUp="AllowOnlyInteger('form_','terms');"
	    onBlur="AllowOnlyInteger('form_','terms');CheckTerm();style.backgroundColor='white'">
     <%if(vTemp != null && vTemp.size() > 0){%>
	   <%=astrTermUnit[Integer.parseInt((String)vTemp.elementAt(13))]%>
		 <input type="hidden" name="term_unit" value="<%=(String)vTemp.elementAt(13)%>">
	   <%}%>
		</font></strong></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;Release Date :<strong> </strong></td>
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
      <td height="27">&nbsp;First Payment : </td>
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
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%if(WI.fillTextValue("code_index").length() > 0 && (WI.fillTextValue("code_index").toLowerCase()).startsWith("r")){%>
    <tr>
      <td width="100%" height="10">&nbsp;</td>
    </tr>
    <%}// end if if(WI.fillTextValue("loan_type").equals("1") %>
		<%if (iAccessLevel > 1) { //if iAccessLevel > 1%>
    <tr>
      <td height="30"><div align="center"><font size="1">
          <%if(strPrepareToEdit.compareTo("1") != 0) {%>
          <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a><font size="1">
          click to save entries</font>
          <%}else{%>
          <a href="javascript:PageAction(2,'<%=(String)vEditInfo.elementAt(0)%>','');">
          <img src="../../../images/edit.gif"border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">
          click to save changes</font>
          <%}%>
          <a href="encode_approved_loan.jsp?emp_id=<%=WI.fillTextValue("emp_id")%>"><img src="../../../images/cancel.gif" border="0"></a>click
          to cancel/clear entries </font></div></td>
    </tr>
	<%if(strPrepareToEdit.compareTo("1") == 0) {%>
    <tr>
      <td height="10" align="center"><font size="1"><a href="javascript:ViewSchedule();"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>click to DELETE LOAN</font></td>
    </tr>
    <tr>
      <td height="10"><div align="center"><font size="1"><a href="javascript:ViewSchedule();"><img src="../../../images/view.gif" border="0"></a>click
          to VIEW PAYMENT SCHEDULE</font></div></td>
    </tr>
	<%}%>
	<%} // if (iAccessLevel > 1) %>
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