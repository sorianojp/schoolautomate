<%@ page language="java" import="utility.*,payroll.PReDTRME, payroll.PRSalary,payroll.ReportPayroll, 
	payroll.PRMiscDeduction, payroll.PRRetirementLoan, java.util.Vector, java.util.Date" buffer="16kb"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><head>
<title>Additional Month Pay</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<!--
<link href="../../../../jscript/jquery-ui-1.8.17/development-bundle/themes/base/jquery.ui.all.css" rel="stylesheet" >
-->
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>

<!--
<script language="JavaScript" src="../../../../jscript/jquery-ui-1.8.17"></script>
<script src="../../../../jscript/jquery-ui-1.8.17/development-bundle/jquery-1.7.1.js"></script>
<script src="../../../../jscript/jquery-ui-1.8.17/development-bundle/ui/jquery.ui.core.js"></script>
<script src="../../../../jscript/jquery-ui-1.8.17/development-bundle/ui/jquery.ui.widget.js"></script>
<script src="../../../../jscript/jquery-ui-1.8.17/development-bundle/ui/jquery.ui.position.js"></script>
<script src="../../../../jscript/jquery-ui-1.8.17/development-bundle/ui/jquery.ui.autocomplete.js"></script>
<link rel="stylesheet" href="../../../../jscript/jquery-ui-1.8.17/development-bundle/demos/demos.css">
	<style>
/*
	#project-label {
		display: block;
		font-weight: bold;
		margin-bottom: 1em;
	}
	
	#project-icon {
		float: left;
		height: 32px;
		width: 32px;
	}*/
	
	#project-description {
		margin: 0;
		padding: 0;
	}
	</style>
-->	
	
<script language="JavaScript">
function ReloadPage() {	
	document.form_.prepareToEdit.value = "0";
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function CancelRecord(){
	document.form_.prepareToEdit.value = "0";
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}

function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;		
	if(strAction == 1) 
		document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../../images/blank.gif";
	this.SubmitOnce('form_');
}

function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function FocusID() {
	document.form_.emp_id.focus();
}

function UpdateToZero(strTextName){
	if(eval('document.form_.'+strTextName+'.value.length') == 0){		
		eval('document.form_.'+strTextName+'.value= "0"');
	}	
}

function ComputeLoanPayable(strRow){
	var vPrincipal = eval('document.form_.principal_amt'+strRow+'.value');
	var vInterest =  eval('document.form_.interest_amt'+strRow+'.value');
	var vPeriodPay =  null;
	var vTotalPay = 0;
	var vLoanCount = document.form_.loan_count.value;
	  if (vPrincipal.length == 0){
		vPrincipal = "0";
	  }	
	  
	  if (vInterest.length == 0){
		vInterest = "0";
	  }
	  
	  vPeriodPay = eval(vPrincipal) +  eval(vInterest);	 
	  eval('document.form_.period_pay'+strRow+'.value = vPeriodPay');
	  
	for(var i = 0; i < eval(vLoanCount);i++){
		vPeriodPay = eval('document.form_.period_pay'+i+'.value');
		vTotalPay = eval(vTotalPay) + eval(vPeriodPay);		
	}	
	document.form_.loans_adv_deduction.value = eval(vTotalPay);
	ComputeLoansMisc();
}

function ComputeMiscPayable(strRow){
	var vAmount = eval('document.form_.misc_amt'+strRow+'.value');
	var vPeriodPay =  null;
	var vTotalPay = 0;
	var vMiscCount = document.form_.misc_count.value;
	  if (vAmount.length == 0){
		return;
	  }

	for(var i = 0; i < eval(vMiscCount);i++){
		vPeriodPay = eval('document.form_.misc_amt'+i+'.value');
		vTotalPay = eval(vTotalPay) + eval(vPeriodPay);
	}
	document.form_.misc_deduction.value = eval(vTotalPay);
	ComputeLoansMisc();
}

function ComputeLoansMisc(){
  if(document.form_.loans_misc_ded){
	  document.form_.loans_misc_ded.value = eval(document.form_.loans_adv_deduction.value) +
											eval(document.form_.misc_deduction.value);
	  document.form_.loans_misc_ded.value = truncateFloat(document.form_.loans_misc_ded.value,2,false);
  }
}
function updateLoans(strBonusIndex){
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "../pay_loansmisc/pay_loans.jsp?emp_id="+document.form_.emp_id.value+
				"&index_name=emp_bonus_index&index="+strBonusIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function updateMiscellaneous(strBonusIndex){
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "../pay_loansmisc/pay_misc.jsp?emp_id="+document.form_.emp_id.value+
				"&index_name=emp_bonus_index&index="+strBonusIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

///////////////////////////////////////// used to collapse and expand filter ////////////////////
var openImg = new Image();
openImg.src = "../../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../../images/box_with_plus.gif";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else
		objBranch.display="block";
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('box_with_plus.gif')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
}

///////////////////////////////////////// End of collapse and expand filter ////////////////////

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
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
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

/*
	$(function() {
	
 		var projects = [
			{
				value: "jquery",
				label: "jQuery",
				desc: "the write less, do more, JavaScript library",
				icon: ""
			},
			{
				value: "jquery-ui",
				label: "jQuery UI",
				desc: "the official user interface library for jQuery",
				icon: ""
			},
			{
				value: "sizzlejs",
				label: "Sizzle JS",
				desc: "a pure-JavaScript CSS selector engine",
				icon: ""
			}
		];

		$( "#project" ).autocomplete({
			minLength: 0,
			source: projects,
			focus: function( event, ui ) {
				$( "#project" ).val( ui.item.label );
				return false;
			},
			
			select: function( event, ui ) {
				$( "#project" ).val( ui.item.label );
				$( "#project-id" ).val( ui.item.value );
				$( "#project-description" ).html( ui.item.desc );
				//$( "#project-icon" ).attr( "src", "images/" + ui.item.icon );

				return false;
			}
		})
		.data( "autocomplete" )._renderItem = function( ul, item ) {
			return $( "<li></li>" )
				.data( "item.autocomplete", item )
				.append( "<a>" + item.label + "<br>" + item.desc + "</a>" )
				.appendTo( ul );
		};
	});
	*/
	</script>

<body bgcolor="#D2AE72" onLoad="FocusID();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	WebInterface WI = new WebInterface(request);

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");	

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-DTR"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Additional Month Pay","addl_month.jsp");
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
		
	PReDTRME prEdtrME = new PReDTRME();
	Vector vRetResult = null;
	PRSalary salary = new PRSalary();
	ReportPayroll RptPay = new ReportPayroll(request);
		
	Vector vPersonalDetails = null; 
	Vector vMiscDeductions  = null;
	Vector vLoans			= null;
	double dLoansAdvMisc    = 0d;
	boolean bolMoreDeduct = false;
	
	String strEmpID = WI.fillTextValue("emp_id");
	String strReadOnly = null;	
	String strMonthTo = null;
    String strSYFr   = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	String strSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	String strCurSem = (String)request.getSession(false).getAttribute("cur_sem");
	int iCount = 0;
	int l = 0;	
	int iRow = 0;
	int iItems = 0;
	double dAddlMonthPay = 0d;
	boolean bolIsReleased = false;
	String strEmpIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));	
//	String strEmployeeIndex = dbOP.mapOneToOther("user_table","id_number","'"+WI.fillTextValue("emp_id")+"'",
//							"user_index"," and (auth_type_index is null or (auth_type_index <>4 and auth_type_index<>6))");

	String strSchCode = dbOP.getSchoolIndex();	
	String strPageAction = WI.fillTextValue("page_action");
		if(strPageAction.length() > 0) {
			if(salary.operateOnAddlMonthPay(dbOP, request, Integer.parseInt(strPageAction)) == null)
				strErrMsg = salary.getErrMsg();
			else {	
				if(strPageAction.equals("1"))
					strErrMsg = "Bonus successfully posted.";
				if(strPageAction.equals("2"))
					strErrMsg = "Bonus successfully edited.";
			}
		}	
	
if (strEmpID.length() > 0 && WI.fillTextValue("reset_page").length() == 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");

	if(vPersonalDetails == null){
		strErrMsg = "Employee Profile not Found";
	}
	
	if(WI.fillTextValue("pay_index").length() > 0){
	  vRetResult = salary.operateOnAddlMonthPay(dbOP,request,4);
	  if(vRetResult != null){
		vLoans          = (Vector)vRetResult.elementAt(1);
		vMiscDeductions = (Vector)vRetResult.elementAt(2);
			if((String)vRetResult.elementAt(0) != null){
				strPrepareToEdit = "1";
			}
	  }		
	}
	
	dAddlMonthPay = salary.computeAddlMonthPay(dbOP, request);
}

/*
	if(strPrepareToEdit.compareTo("1") == 0) {	
			vEditInfo = salary.operateOnAddlMonthPay(dbOP, request,4);
			vLoans          = (Vector)vEditInfo.elementAt(1);
			vMiscDeductions = (Vector)vEditInfo.elementAt(2);
		if(vEditInfo == null)
			strPrepareToEdit = "0";
			strErrMsg = salary.getErrMsg();		
	}
*/
%>
<form name="form_" action="./addl_month.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL :  ADDITIONAL MONTH PAY PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>      
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td>Employee ID</td>
      <td><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"> 
        <a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a>
				<label id="coa_info"></label>			</td>
    </tr>
    <!--
		<tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><div class="demo">
	<!--
	<div id="project-label">Select a project (type "j" for a start):</div>	
	<img id="project-icon" src="images/transparent_1x1.png" class="ui-state-default"/>
	
	<input id="project"/>
	<input type="hidden" id="project-id"/>
	<p id="project-description"></p>
</div><!-- End demo </td>
    </tr>
		-->
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Year</td>
      <td> 
        <select name="year_of" onChange="document.form_.reset_page.value='1';ReloadPage();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="19%">Additional pay name </td>
	  <%
	  	strTemp = WI.fillTextValue("pay_index");
	  %>
      <td width="78%"><select name="pay_index">
        <option value="">Select Additional Pay </option>
        <%=dbOP.loadCombo("pr_addl_pay_mgmt.pay_index","pay_name", " from pr_addl_pay_mgmt " +
		" join pr_add_month_emp_list on(pr_add_month_emp_list.pay_index = pr_addl_pay_mgmt.pay_index)" +
		" where pr_addl_pay_mgmt.is_valid = 1 and pr_addl_pay_mgmt.is_del = 0 " +
		" and pr_add_month_emp_list.is_valid = 1 and pr_add_month_emp_list.is_del = 0 " +		
		" and year = " + WI.getStrValue(WI.fillTextValue("year_of"),"0") + 
		" and pr_add_month_emp_list.user_index =" + strEmpIndex, strTemp,false)%>
      </select></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:ReloadPage();"><img src="../../../../images/refresh.gif" border="0"></a><font size="1">Click 
        to reload page.</font></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1" color="#0000FF"></td>
    </tr>
  </table>
 <% if((vPersonalDetails != null && vPersonalDetails.size() > 0) && vRetResult != null && vRetResult.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td height="29">Employee Name : </td>
      <td><strong>&nbsp;<%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Employee ID : </td>
      <td><strong>&nbsp;<%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29"> <%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : </td>
		  <%
		strTemp = (String)vPersonalDetails.elementAt(13);
		if (strTemp == null){
			strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
		}else{
			strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
		}
		%>			
      <td><strong>&nbsp;<%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td>Employment Type/Position : </td>
      <td><strong>&nbsp;<%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td width="25%">Employment Status<strong> : </strong></td>
      <td width="72%"><strong>&nbsp;<%=(String)vPersonalDetails.elementAt(16)%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td>Additional Month Bonus: </td>
      <td>&nbsp;<strong><%=CommonUtil.formatFloat(dAddlMonthPay,2)%><input type="hidden" name="amount" value="<%=CommonUtil.formatFloat(dAddlMonthPay,2)%>"></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#99CCFF"> 
      <td width="3%" height="18">&nbsp;</td>
      <td colspan="6"><strong><font color="#FF3300">:: DEDUCTIONS - LOANS ::</font></strong></td>
    </tr>
    <%if(vLoans != null && vLoans.size() > 1){%>
    <tr> 
      <td height="25" colspan="7"><div onClick="showBranch('branch2');swapFolder('folder2')"><img src="../../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder2"> 
          <b><font color="#0000FF">View Loans</font></b></div>
        <span class="branch" id="branch2"> 
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="3%">&nbsp;</td>
            <td width="34%"><div align="center"><font size="1"><strong>&nbsp;LOAN 
                CODE - NAME</strong></font></div></td>
            <td width="21%"><div align="center"><font size="1"><strong>PAYABLE 
                PRINCIPAL</strong></font></div></td>
            <td width="21%"><div align="center"><font size="1"><strong>PAYABLE 
                INTEREST </strong></font></div></td>
            <td width="21%"><div align="center"><font size="1"><strong>TOTAL PAYABLE</strong></font></div></td>
          </tr>
          <%iRow = 0;
		  for (l = 1; l < vLoans.size(); l+=9,iRow++){%>
          <tr> 
            <td>&nbsp;</td>
            <%  
				if(((String)vLoans.elementAt(l+6)).equals("0"))
					strTemp = " - Retirement";
				else if(((String)vLoans.elementAt(l+6)).equals("1"))
					strTemp = " - Emergency";
				else
					strTemp = "";
					
			    if(strPrepareToEdit.equals("1")){
				  strTemp2 = (String)vLoans.elementAt(l+4);
				  strTemp3 = (String)vLoans.elementAt(l+5);				
				} else {
				  strTemp2 = (String)vLoans.elementAt(l+5);
				  strTemp3 = (String)vLoans.elementAt(l);
				}
			%>
            <td height="18"><font size="1">&nbsp;<%=strTemp2%><%=WI.getStrValue(strTemp3," - ","",strTemp)%></font></td>
            <%
				strTemp = (String)vLoans.elementAt(l+2);				
			%>
            <td><div align="center"><font size="1">&nbsp;<strong> 
                <input name="principal_amt<%=iRow%>" type="text" size="10" maxlength="10" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
			  onKeyUp="AllowOnlyFloat('form_','principal_amt<%=iRow%>');ComputeLoanPayable('<%=iRow%>')" style="text-align : right"
			  onBlur="AllowOnlyFloat('form_','principal_amt<%=iRow%>');UpdateToZero('principal_amt<%=iRow%>');
			  ComputeLoanPayable('<%=iRow%>');style.backgroundColor='white'">
                <%if (strPrepareToEdit.equals("1")){%>
                <input type="hidden" name="old_principal<%=iRow%>" value="<%=WI.getStrValue(strTemp,"0")%>">
                <%}%>
                <input type="hidden" name="loan_index<%=iRow%>" value="<%=(String)vLoans.elementAt(l+7)%>">
                &nbsp; </strong></font></div></td>
            <%
				if(strPrepareToEdit.equals("1"))
					strTemp = (String)vLoans.elementAt(l+3);
				else
					strTemp = "";
			%>
            <td><div align="center"><font size="1"><strong> 
                <input name="interest_amt<%=iRow%>" type="text" size="10" maxlength="10" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
			  onKeyUp="AllowOnlyFloat('form_','interest_amt<%=iRow%>');ComputeLoanPayable('<%=iRow%>')" style="text-align : right"
			  onBlur="AllowOnlyFloat('form_','interest_amt<%=iRow%>');UpdateToZero('interest_amt<%=iRow%>');
			  ComputeLoanPayable('<%=iRow%>');style.backgroundColor='white'">
                <input type="hidden" name="old_interest<%=iRow%>" value="<%=WI.getStrValue(strTemp,"0")%>">&nbsp;</strong></font></div></td>
            <%
				if(strPrepareToEdit.equals("1"))
					strTemp = (String)vLoans.elementAt(l+1);
				else
					strTemp = "";
			%>

            <td><div align="center"><font size="1"><strong> 
                <input name="period_pay<%=iRow%>" type="text" size="10" maxlength="10" class="textbox_noborder"
			  value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right" readonly>
                &nbsp; </strong></font> </div></td>
          </tr>
          <%}%>
          <input type="hidden" name="loan_count" value="<%=iRow%>">
        </table>
        </span> </td>
    </tr>
    <%}// end if vLoans != null%>
    <tr> 
      <td height="29">&nbsp;</td>
      <td width="22%">Loans and Advances</td>
      <%
			strTemp = (String) vRetResult.elementAt(3);
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dLoansAdvMisc += Double.parseDouble(strTemp);
			%>
      <td width="14%">         
					<%if(iAccessLevel > 1){
					  if(strPrepareToEdit.compareTo("0") != 0) {%>
          <a href='javascript:updateLoans("<%=WI.getStrValue((String)vRetResult.elementAt(0),"0")%>");'> <img src="../../../../images/update.gif" width="60" height="26" border="0"></a>
          <%}
					}%>      
			</td>
      <td width="11%" align="right"> <font size="1"><strong> 
        <input name="loans_adv_deduction" type="text" size="10" maxlength="10" class="textbox_noborder"
		   value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right" readonly>
      </strong></font> </td>
      <td colspan="3"> 
        <!--
	  <strong><a href="javascript:ViewLoansAndOtherDetail();"><img src="../../../../images/view.gif" border="0"></a><font size="1">View 
        loans and advances detail</font></strong>
	  -->      </td>
    </tr>
    <tr bgcolor="#99CCFF"> 
      <td height="18">&nbsp;</td>
      <td colspan="6"><strong><font color="#FF3300">:: DEDUCTIONS - MISCELLANEOUS ::</font></strong></td>
    </tr>
    <%if(vMiscDeductions != null && vMiscDeductions.size() > 1){%>
    <tr> 
      <td height="34" colspan="7"><div onClick="showBranch('branch3');swapFolder('folder3')"> 
          <img src="../../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder3"> 
          <b><font color="#0000FF">View Miscellaneous Deductions</font></b></div>
        <span class="branch" id="branch3"> 
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="3%">&nbsp;</td>
            <td width="48%"> <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr> 
                  <td width="25%"><div align="center"><font size="1"><strong>&nbsp;CHARGES 
                      NAME </strong></font></div></td>
                  <td width="25%"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
                </tr>
                <% iRow = 0;
				for (l = 1; l < vMiscDeductions.size(); l+=4,iCount++,iRow++){
					if(iCount == 5){
						bolMoreDeduct = true;				
						break;
					}
				%>
                <tr> 
                  <td height="18">&nbsp;<%=(String)vMiscDeductions.elementAt(l+1)%></td>
                  <%
				  strTemp = (String)vMiscDeductions.elementAt(l+2);
				  strTemp = ConversionTable.replaceString(strTemp,",","");
				  %>
                  <td><div align="center">&nbsp;<strong><font size="1"> 
                      <input name="misc_amt<%=iRow%>" type="text" size="10" maxlength="10" class="textbox"
				  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
				  onKeyUp="AllowOnlyFloat('form_','misc_amt<%=iRow%>');ComputeMiscPayable('<%=iRow%>');" style="text-align : right"
				  onBlur="AllowOnlyFloat('form_','misc_amt<%=iRow%>');UpdateToZero('misc_amt<%=iRow%>');
				  ComputeMiscPayable('<%=iRow%>');style.backgroundColor='white'">
                      &nbsp; </font></strong></div></td>
                  <input type="hidden" name="old_misc<%=iRow%>" value="<%=WI.getStrValue(strTemp,"0")%>">
                  <%if(strPrepareToEdit.equals("1")){%>
                  <input type="hidden" name="misc_ded_index<%=iRow%>" value="<%=(String)vMiscDeductions.elementAt(l+3)%>">
                  <%}%>
                  <input type="hidden" name="post_deduct_index<%=iRow%>" value="<%=(String)vMiscDeductions.elementAt(l)%>">
                </tr>
                <%}%>
              </table></td>
            <td width="49%" valign="	"> <%if(bolMoreDeduct){%> <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr> 
                  <td width="25%"><div align="center"><font size="1"><strong>&nbsp;CHARGES 
                      NAME </strong></font></div></td>
                  <td width="25%"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
                </tr>
                <%for (; l < vMiscDeductions.size(); l+=4,iCount++,iRow++){%>
                <tr> 
                  <td height="18">&nbsp;<%=(String)vMiscDeductions.elementAt(l+1)%></td>
                  <%
				  strTemp = (String)vMiscDeductions.elementAt(l+2);
				  strTemp = ConversionTable.replaceString(strTemp,",","");
				  %>
                  <td><div align="center">&nbsp;<strong><font size="1"> 
                      <input name="misc_amt<%=iRow%>" type="text" size="10" maxlength="10" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
			  onKeyUp="AllowOnlyFloat('form_','misc_amt<%=iRow%>');ComputeMiscPayable('<%=iRow%>');" style="text-align : right"
			  onBlur="AllowOnlyFloat('form_','misc_amt<%=iRow%>');UpdateToZero('misc_amt<%=iRow%>');
			  ComputeMiscPayable('<%=iRow%>');style.backgroundColor='white'">
                      &nbsp; </font></strong></div></td>
                  <input type="hidden" name="old_misc<%=iRow%>" value="<%=WI.getStrValue(strTemp,"0")%>">
                  <%if(strPrepareToEdit.equals("1")){%>
                  <input type="hidden" name="misc_ded_index<%=iRow%>" value="<%=(String)vMiscDeductions.elementAt(l+3)%>">
                  <%}%>
                  <input type="hidden" name="post_deduct_index<%=iRow%>" value="<%=(String)vMiscDeductions.elementAt(l)%>">
                </tr>
                <%}// end for (; l < vMiscDeductions.size(); l+= ......%>
              </table>
              <%}// end if bolMoreDeduct%> </td>
          </tr>
        </table>
        </span> </td>
      <input type="hidden" name="misc_count" value="<%=iRow%>">
    </tr>
    <%}%>
    <tr> 
      <td height="29">&nbsp;</td>
      <td>Miscellaneous Deductions</td>
      <%

		strTemp = (String) vRetResult.elementAt(4);
		if (strTemp != null) {
			strTemp = ConversionTable.replaceString(strTemp,",","");				
			dLoansAdvMisc += Double.parseDouble(strTemp);
		}else{
			strTemp = "0";
		}
		
	   %>
      <td align="right">
				<%if(iAccessLevel > 1){%>
        <%if(strPrepareToEdit.compareTo("0") != 0 && !bolIsReleased) {%>
          <a href='javascript:updateMiscellaneous("<%=WI.getStrValue((String)vRetResult.elementAt(0),"0")%>");'><img src="../../../../images/update.gif" width="60" height="26" border="0"></a>
        <%}
				}%>
			</td>
      <td align="right"><font size="1"><strong> 
        <input name="misc_deduction" type="text" size="10" maxlength="10" class="textbox_noborder"
		   value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right" readonly>
      </strong></font> </td>
      <td colspan="3"> 
        <!--
	  <strong><a href="javascript:ViewOtherDeductionDetail();"><img src="../../../../images/view.gif" border="0"></a><font size="1">View 
        other deductions detail</font></strong>
	  -->      </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="2">Loans &amp; Miscellaneous Total</td>
      <%
	  	strTemp = WI.getStrValue(Double.toString(dLoansAdvMisc), WI.fillTextValue("loans_misc_ded"));		
		strTemp = CommonUtil.formatFloat(strTemp,true);
	  %>
      <td align="right"><strong> 
        <input name="loans_misc_ded" type="text" value="<%=WI.getStrValue(strTemp,"0")%>" 
		size="12" maxlength="12"  class="textbox_noborder" style="text-align: right" readonly>
      </strong></td>
      <td width="50%" colspan="3">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="46"  colspan="3" align="center" valign="bottom" bgcolor="#FFFFFF">
        <%if(iAccessLevel > 1) {%>
				<%if(strPrepareToEdit.compareTo("1") != 0) {%>
        
        <!--
					<a href='javascript:PageAction(1, "");'><img src="../../../../images/save.gif" border="0" id="hide_save"></a> 
					-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1', '');">
        <font size="1"> click to save entries</font>         
	      <%}else{%>
        <!--
					<a href='javascript:PageAction(2,"");'> <img src="../../../../images/edit.gif" border="0"></a>
					-->
				<input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2', '');">
				<font size="1">click to save changes</font> 
	      <%}%>
        <!--
					<a href="javascript:CancelRecord();"><img src="../../../../images/cancel.gif" border="0"></a> 
					-->
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">					
        <font size="1">Click to cancel or go previous</font>      
			<%}%>
			</td>
    </tr>
  </table>

<%}//show only if vPersonalDtls not null.%>
  <table cellpadding="0" cellspacing="0" width="100%">
    <tr>
      <td height="20"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
</table>
  
  <input type="hidden" name="month_to" value="<%=strMonthTo%>">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">  
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
   <%
  	if(vRetResult != null && vRetResult.size() > 0)
	  	strTemp = WI.getStrValue((String)vRetResult.elementAt(0),"0");
	else
		strTemp = WI.fillTextValue("emp_bonus_index");	
  %>
  <input type="hidden" name="emp_bonus_index" value="<%=strTemp%>">
  <input type="hidden" name="reset_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>