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
<title>Encode Loans Amortization</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

TD.BorderBottomLeft{
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottomLeftRight{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderAll{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
function DeleteLoan(strLoanName){
	document.form_.print_page.value="";
	var vProceed = confirm("This would delete "+strLoanName+" saved loan schedule. Do you want to continue?");
	if(vProceed){
		document.form_.page_action.value = "0";
		this.SubmitOnce('form_');
	}else{
		return;
	}
}

function OpenSearch() {
	document.form_.print_page.value="";
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PageAction(strPageAction, strInfoIndex){
	document.form_.page_action.value = strPageAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	if(strPageAction == 1)
		document.form_.save.disabled = true;
	document.form_.submit();
//	this.SubmitOnce("form_");
}

function UpdateLoan(strLoanType){
	var loadPg = "loan_setting.jsp?opner_form_name=form_&opner_form_field=code_index"+
				 "&show_close=1&loan_type="+strLoanType;
	var win=window.open(loadPg,"updateLoanName",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateSchedule(strRetLoanIndex){
	document.form_.print_page.value="";
	var loadPg = "update_loan_schedule.jsp?emp_id="+document.form_.emp_id.value+
				 "&code_index="+document.form_.code_index.value+
				 "&loan_type="+document.form_.loan_type.value+
				 "&ret_loan_index="+strRetLoanIndex;
	var win=window.open(loadPg,"updateSchedule",'dependent=yes,width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function ReloadPage()
{
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function ChangeBasis()
{
	//document.form_.terms.value="0";
	//document.form_.monthly_amount.value="0.00";
	if(!document.form_.schedule_basis)
		return;
		
	var vSelected = document.form_.schedule_basis.value;
	
 	if(vSelected == '0'){		
 		document.getElementById("note").innerHTML = 
				"<font size='1'><strong>Loan schedule is based on the number of entered term.</strong></font>";
		document.form_.terms.disabled = false;
		document.form_.monthly_amount.disabled = true;		
		document.form_.payable_amt.disabled = false;		
	} else if(vSelected == '1') {
 		document.getElementById("note").innerHTML = 
				"<font size='1'><strong>Loan schedule is based on the monthly amortization.</strong></font>";
		document.form_.terms.disabled = true;
		document.form_.monthly_amount.disabled = false;						
		document.form_.payable_amt.disabled = false;		
	} else if(vSelected == '2'){
 		document.getElementById("note").innerHTML =
				"<font size='1'><strong>Loan schedule is based on both the term and the monthly amortization<br></strong>" +
				" Amount payable equals term multiplied by the monthly amortization. (Payable = Terms * Monthly)<br>" +
				" If the amount loaned is zero or blank, amount loaned will be the same as computed payable amount</font>";
		document.form_.terms.disabled = false;
		document.form_.monthly_amount.disabled = false;
		document.form_.payable_amt.disabled = true;		
	}
	
	//ReloadPage();	
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function focusID() {
	document.form_.emp_id.focus();
}

function CopyID(strID)
{
	document.form_.print_page.value="";
	document.form_.emp_id.value=strID;
	this.SubmitOnce("form_");

}

function clearFields(){
	document.form_.loan_amount.value="";
	document.form_.terms.value="";
	document.form_.monthly_amount.value="";
	document.form_.collection_period.value="";
	document.form_.start_date.value="";
}
function CancelRecord(){
	location = "./encode_loan_amo.jsp?loan_type="+document.form_.loan_type.value+
						 "&emp_id="+document.form_.emp_id.value;
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
-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./loan_amo_schedule_print.jsp" />
<% return;}
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
								"Admin/staff-Payroll-LOANS-Encode Loans","encode_loan_amo.jsp");
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
	Vector vEditInfo = null;
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	PRMiscDeduction prd = new PRMiscDeduction(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

	String strPageAction = WI.fillTextValue("page_action");
	String strLoanType = WI.fillTextValue("loan_type");
	String strCodeIndex = null;
	String strTypeName = null;
	String strLoanName = null;
	String strPrepareToEdit = "0";
	String strSalDateFr = null;
	double dTotalPay = 0d;
	double dPrincipal = 0d;
	double dInterest = 0d;

	String strReadOnly = "";
	String strSchedBase = null;
	Vector vEmpList = null;
	String strEmpIndex = null;
	String strEmpSchedType = null;
	payroll.PRConfidential prCon = new payroll.PRConfidential();

	boolean bolCheckAllowed = true;
	if(!strSchCode.toUpperCase().startsWith("FADI"))
		bolCheckAllowed = (prCon.checkIfEmpIsProcessor(dbOP, request, WI.fillTextValue("emp_id"), true) == 1);
		
	if (WI.fillTextValue("emp_id").length() > 0) {
		if(bolCheckAllowed){
			enrollment.Authentication authentication = new enrollment.Authentication();
			vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
			
			if (vPersonalDetails == null || vPersonalDetails.size()==0){
				strErrMsg = authentication.getErrMsg();
				vPersonalDetails = null;
			}
	
			strEmpIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
			strEmpSchedType = PRRetLoan.checkEmployeeSalaryType(dbOP, request, strEmpIndex);
			if(strEmpSchedType != null && strEmpSchedType.length() > 0){
				if(strEmpSchedType.equals("3")){
					strErrMsg = "Cannot process employees with weekly salary schedule from this page";
					vPersonalDetails = null;
				}	
			}else{
				strErrMsg = "No salary schedule set for the employee";
				vPersonalDetails = null;
			}
	
			if(strPageAction.length() > 0){
				if(PRRetLoan.operateOnRetirementLoan(dbOP,request,Integer.parseInt(strPageAction)) == null)
					strErrMsg = PRRetLoan.getErrMsg();
				else
					strErrMsg = "Operation Successful";
			}
	
			if(WI.fillTextValue("code_index").length() > 0){
				//ResultSet rs = null;
				//strLoanName = dbOP.mapOneToOther("ret_loan_code","code_index",WI.fillTextValue("code_index"),
				//								 "'(' + loan_code + ' :: ' + loan_name + ')' ","");
				java.sql.ResultSet rs = null;
				strLoanName = "select loan_name, loan_code from ret_loan_code where is_valid = 1 " +
				" and code_index = " + WI.fillTextValue("code_index");
				rs = dbOP.executeQuery(strLoanName);
				if(rs.next()){
					strLoanName = rs.getString(1) + "(" + rs.getString(2) + ")";
				}rs.close();
				
				vEditInfo = PRRetLoan.operateOnRetirementLoan(dbOP,request,5);
				if(vEditInfo != null && vEditInfo.size() > 0){
					strPrepareToEdit = "1";
				}
			}
	
			vRetResult = PRRetLoan.operateOnAmortization(dbOP,request,4);
	
			if (vRetResult != null && strErrMsg == null){
				strErrMsg = PRRetLoan.getErrMsg();
			}
			
		}else
			 strErrMsg = prCon.getErrMsg();
		
		vEmpList = prd.getEmployeesList(dbOP);
	}
%>
<body bgcolor="#D2AE72" onLoad="focusID();ChangeBasis();" class="bgDynamic">
<form name="form_" method="post" action="./encode_loan_amo.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <%if(strLoanType.equals("3")){
		strTypeName = "SSS";
	}else if(strLoanType.equals("4")){
		strTypeName = "PAG-IBIG";
	}else if(strLoanType.equals("5")){
 		if(strSchCode.startsWith("AUF"))
			strTypeName = "PSBank";
		else
			strTypeName = "PERAA";
	}else if(strLoanType.equals("6")){
		strTypeName = "GSIS";		
	}%>
	<tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
        PAYROLL : LOANS : ENCODE <%=strTypeName%> LOAN AMORTIZATION PAGE ::::</strong></font></td>
	</tr>
    <tr bgcolor="#FFFFFF">
      <td width="65%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></td>
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
         <input type="submit" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #999999;"
				 onClick="document.form_.print_page.value=''">
        </font><label id="coa_info"></label></td>
    </tr>
  </table>
    <% if (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails != null && vPersonalDetails.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td width="3%" height="29">&nbsp;</td>
      <td height="29">&nbsp;Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;Employee ID : <strong><%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <%
	strTemp = (String)vPersonalDetails.elementAt(13);
	if (strTemp == null){
		strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
	}else{
		strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
	}
%>
      <td height="30">&nbsp;
        <%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>&nbsp;Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td width="97%">&nbsp;Employment Status<strong> : <%=(String)vPersonalDetails.elementAt(16)%> </strong></td>
    </tr>
    <tr>
      <td height="19" colspan="2"><hr size="1" noshade></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="21%" height="25">&nbsp;<%=strTypeName%> Loan Name</td>
	  <%
	  	strCodeIndex = WI.fillTextValue("code_index");
	  %>
      <td width="77%"><font size="1"><strong>
        <select name="code_index" onChange="ReloadPage();">
          <option value="">Select Loan</option>
          <%=dbOP.loadCombo("code_index","loan_code, loan_name ",
		                    " from ret_loan_code where is_valid = 1 and loan_type = " + strLoanType,
							strCodeIndex ,false)%>
        </select>
        </strong></font>
				<%if(iAccessLevel > 1){%>
				<font size="1"><a href='javascript:UpdateLoan("<%=strLoanType%>")'><img src="../../../images/update.gif" border="0"></a></font>
        click to UPDATE list of <%=strTypeName%>  Loan Name
				<%}%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;Schedule based on</td>
	  <%
	  	strSchedBase = WI.getStrValue(WI.fillTextValue("schedule_basis"),"0");
	  %>
      <td><font size="1"><strong>
        <select name="schedule_basis" onChange="ChangeBasis();">
          <option value="0">Term</option>
          <%if(strSchedBase.equals("1")){%>
          <option value="1" selected>Monthly Amortization</option>
          <%}else{%>
          <option value="1">Monthly Amortization</option>
          <%}%>
          <%if(strSchedBase.equals("2")){%>
          <option value="2" selected>Monthly Amortization and Terms</option>
          <%}else{%>
          <option value="2">Monthly Amortization and Terms</option>
          <%}%>					
        </select>
      </strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("note");
			%>
      <td height="25" colspan="2"><label id="note">&nbsp;<%=strTemp%>&nbsp;</label></td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td height="25">&nbsp;Amount Loan applied</td>
      <%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String) vEditInfo.elementAt(5);			
			else
		  	strTemp = WI.fillTextValue("loan_amount");
			strTemp = CommonUtil.formatFloat(strTemp, true);
			strTemp = ConversionTable.replaceString(strTemp,",","");
	  %>
      <td><font size="1"><strong>
        <input name="loan_amount" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		value="<%=strTemp%>" size="12" maxlength="12"
		onKeyUp="AllowOnlyIntegerExtn('form_','loan_amount','.');"
		onBlur="AllowOnlyIntegerExtn('form_','loan_amount','.');style.backgroundColor='white'">
        </strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;Amount Loan payable</td>
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
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;Term</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String) vEditInfo.elementAt(6);
		else
		  	strTemp = WI.fillTextValue("terms");

		//if(strSchedBase.equals("1"))
		//	strReadOnly = " readonly";			
		//else
		//	strReadOnly = "";
	  %>
      <td><strong><font size="1">
        <input name="terms" type="text" class="textbox"onFocus="style.backgroundColor='#D3EBFF'"
		value="<%=strTemp%>" size="4" maxlength="4"
	    onKeyUp="AllowOnlyInteger('form_','terms');"
	    onBlur="AllowOnlyInteger('form_','terms');style.backgroundColor='white'" <%//=strReadOnly%>>
      </font></strong>Month(s)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;Monthly Amortization</td>
	  <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String) vEditInfo.elementAt(17);
		else
		  strTemp = WI.fillTextValue("monthly_amount");
				
		strTemp = CommonUtil.formatFloat(strTemp, true);
		strTemp = ConversionTable.replaceString(strTemp,",","");

		//if(strSchedBase.equals("0"))
		//	strReadOnly = " readonly";
		//else
		//	strReadOnly = "";
	  %>
      <td><font size="1"><strong>
        <input name="monthly_amount" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		value="<%=strTemp%>" size="12" maxlength="12"
		onKeyUp="AllowOnlyIntegerExtn('form_','monthly_amount','.');" <%//=strReadOnly%>
		onBlur="AllowOnlyIntegerExtn('form_','monthly_amount','.');style.backgroundColor='white'">
      </strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;Collection Period</td>
	  <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String) vEditInfo.elementAt(16);
		else
		  	strTemp = WI.fillTextValue("collection_period");
	  %>
      <td><font size="1"><strong>
        <input name="collection_period" type="text" class="textbox"
		onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp)%>" size="32" maxlength="32"
		onBlur="style.backgroundColor='white'">
      </strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;Schedule of Deduction</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String) vEditInfo.elementAt(18);
		else
		  	strTemp = WI.fillTextValue("deduct_period");
		strTemp = WI.getStrValue(strTemp, "0");
		%>
      <td><select name="deduct_period">
        <option value="0">Every Salary Period </option>
        <%
if(strTemp.equals("1")) {%>
        <option value="1" selected>1st</option>
        <%}else{%>
        <option value="1">1st</option>
        <%}if(strTemp.equals("2")) {%>
        <option value="2" selected>2nd</option>
        <%}else{%>
        <option value="2">2nd</option>
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;Release Date</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String) vEditInfo.elementAt(7);
			}else
					strTemp = WI.fillTextValue("release_date");
			%>			
      <td><strong>
        <input name="release_date" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="yes">
        <a href="javascript:show_calendar('form_.release_date');"><img src="../../../images/calendar_new.gif" border="0"></a></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;Start of Deduction</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String) vEditInfo.elementAt(15);
		else
		  	strTemp = WI.fillTextValue("start_date");
	  %>
      <td><strong>
        <input name="start_date" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="yes">
        <a href="javascript:show_calendar('form_.start_date');"><img src="../../../images/calendar_new.gif" border="0"></a></strong></td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
	<%if(strCodeIndex != null && strCodeIndex.length() > 0){%>
    <tr>
      <td height="32" colspan="3" align="center">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <!--
					<a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a>
					-->
        <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');">
        <font size="1">click to save entries</font>
        <%}else{%>
        <!--
					<a href="javascript:PageAction(2,'<%=(String)vEditInfo.elementAt(0)%>','');"><img src="../../../images/edit.gif"border="0"></a>
					-->
        <input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction(2,'<%=(String)vEditInfo.elementAt(0)%>','');">
        <font size="1">click to save changes</font> 					
        <!--
					<a href="javascript:UpdateSchedule()"><img src="../../../images/schedule.gif" border="0"></a>
          <font size="1">click to UPDATE/ENCODE Payment Schedule</font>
					-->
        <%}%>          
        <!--
				  <a href="encode_loan_amo.jsp?loan_type=<%=WI.fillTextValue("loan_type")%>&emp_id=<%=WI.fillTextValue("emp_id")%>"><img src="../../../images/cancel.gif" border="0"></a>
					-->
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">
        <font size="1">click to cancel/clear entries </font></td>
    </tr>
		<%if(strPrepareToEdit.compareTo("1") == 0) {%>
    <tr>
      <td height="32" colspan="3" align="center"><font size="1"><a href="javascript:DeleteLoan('<%=strLoanName%>');"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>click to DELETE LOAN
        <input type="button" name="edit22" value=" UPDATE " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:UpdateSchedule('<%=(String)vEditInfo.elementAt(0)%>');">
      click to Update loan schedule </font></td>
    </tr>
    <tr>
			<%
				strTemp = WI.fillTextValue("show_all");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else	
					 strTemp = "";
			%>		
      <td height="32" colspan="3"><input type="checkbox" name="show_all" value="1" <%=strTemp%> onClick="ReloadPage();">
show complete schedule </td>
    </tr>
		<%}%>
	<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><font size="1">Note: Loans can still be edited/deleted if no payment is found in the system yet.</font></td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#99CCFF">
      <td height="25" colspan="2" align="center" class="BorderAll"><strong>::
      AMORTIZATION SCHEDULE FOR <%=strTypeName%> LOAN <%=strLoanName%> ::</strong></td>
    </tr>
    <tr>
      <td width="13%" height="24" align="center" class="BorderBottomLeft"><strong><font size="1">PAYROLL
      PERIOD</font></strong></td>
      <td width="22%" height="24" align="center" class="BorderBottomLeft"><strong><font size="1">AMOUNT
      DUE</font></strong></td>
    </tr>
    <%for(int i = 0; i < vRetResult.size() ; i+=15){%>
    <tr>
      <td class="BorderBottomLeft">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+2);
			strTemp = CommonUtil.formatFloat(strTemp, true);
			if(((String)vRetResult.elementAt(i+6)).equals("2"))
				strTemp = "**" + strTemp;
			else{
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTotalPay += Double.parseDouble(strTemp);
			}
			%>
      <td height="24" align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+3);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dPrincipal += Double.parseDouble(strTemp);
	  %>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+4);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dInterest += Double.parseDouble(strTemp);
	  %>
    </tr>
    <%}%>
    <tr>
      <td height="19" colspan="2"><hr size="1"></td>
    </tr>
    <tr>
      <td>TOTALS :</td>
      <td height="24" align="right"><%=CommonUtil.formatFloat(dTotalPay,true)%>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>

      <td height="25">** - extended schedule </td>
    </tr>
    <tr>
      <td height="25"><div align="center"><font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0" ></a>
          click to print</font></div></td>
    </tr>
  </table>
  <%} // end if vRetResult != null %>
  <%}// largest if... (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails != null && vPersonalDetails.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="print_page">
  <input type="hidden" name="page_action">
  <input type="hidden" name="loan_type" value="<%=WI.fillTextValue("loan_type")%>">
  <input type="hidden" name="loan_name" value="<%=strLoanName%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>