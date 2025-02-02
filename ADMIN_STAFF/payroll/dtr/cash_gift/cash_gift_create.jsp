<%@ page language="java" import="utility.*, payroll.PReDTRME, payroll.PRSalaryExtn,
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
<title>Create Cash Gift</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
function updateLoans(strGiftIndex){
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "../pay_loansmisc/pay_loans.jsp?emp_id="+document.form_.emp_id.value+
				"&index_name=gift_index&index="+strGiftIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function updateMiscellaneous(strGiftIndex){
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "../pay_loansmisc/pay_misc.jsp?emp_id="+document.form_.emp_id.value+
				"&index_name=gift_index&index="+strGiftIndex;
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
								"Admin/staff-Payroll-DTR-Create Cash Gift","cash_gift_create.jsp");
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
	PRSalaryExtn salary = new PRSalaryExtn();

	Vector vRetResult = null;		
	Vector vPersonalDetails = null; 
	Vector vLoans 	  = null;
	Vector vMiscDed 	  = null;
	Vector vEditInfo  = null;
	String strEmpID   = WI.fillTextValue("emp_id");
	double dDaysTotal = 0d;
	double dLoansAdvMisc    = 0d;
	boolean bolMoreDeduct = false;
	boolean bolIsReleased = false;
		
	int l = 0;	
	int iRow = 0;
	double dCashGift = 0d;	
	String strInfoIndex = WI.fillTextValue("info_index");
	
	String strPageAction = WI.fillTextValue("page_action");
	if(strPageAction.length() > 0) {
		if(salary.operateOnEmpCashGift(dbOP, request, Integer.parseInt(strPageAction)) == null)
			strErrMsg = salary.getErrMsg();
		else {	
			if(strPageAction.equals("1"))
				strErrMsg = "Cash Gift successfully posted.";
			if(strPageAction.equals("2"))
				strErrMsg = "Cash Gift successfully edited.";
		}
	}	
	
 if (strEmpID.length() > 0 && WI.fillTextValue("reset_page").length() == 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");

	if(vPersonalDetails == null){
		strErrMsg = "Employee Profile not Found";
	}
	dCashGift = salary.computeCashGift(dbOP,request);	
	if(dCashGift == 0d){
		strErrMsg = salary.getErrMsg();
	}
}
	strPrepareToEdit = "1";
	vEditInfo = salary.operateOnEmpCashGift(dbOP, request,4);
	if(vEditInfo == null){
		strPrepareToEdit = "0";
		strErrMsg = salary.getErrMsg();				
	}else{
		strInfoIndex =(String)vEditInfo.elementAt(0);
		vLoans = (Vector)vEditInfo.elementAt(2);
		vMiscDed = (Vector)vEditInfo.elementAt(4);
	}
		
%>
<form name="form_" action="./cash_gift_create.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL :  CASH GIFT PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>      
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="19%">Employee ID</td>
      <td width="78%">
			<input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	     onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"> 
        <a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a><label id="coa_info"></label></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Year</td>
      <td>
        <select name="year_of" onChange="document.form_.reset_page.value='1';ReloadPage();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>      </td>
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
 <% if((vPersonalDetails != null && vPersonalDetails.size() > 0) && dCashGift > 0d){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td>Employee Name</td>
      <td colspan="2"><strong>&nbsp;<%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Employee ID</td>
      <td colspan="2"><strong>&nbsp;<%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td> <%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office</td>
		  <%
		strTemp = (String)vPersonalDetails.elementAt(13);
		if (strTemp == null){
			strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
		}else{
			strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
		}
		%>			
      <td colspan="2"><strong>&nbsp;<%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Employment Type/Position</td>
      <td colspan="2"><strong>&nbsp;<%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="25%">Employment Status</td>
      <td colspan="2"><strong>&nbsp;<%=(String)vPersonalDetails.elementAt(16)%></strong></td>
    </tr>
    
    <tr> 
      <td height="19">&nbsp;</td>
      <td>Cash Gift</td>
			<% 
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(1);
				else
					strTemp = Double.toString(dCashGift);
			%>
      <td width="11%"><font size="1"><strong>
        <input name="amount" type="text" size="10" maxlength="10" class="textbox"
		   value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right">
      </strong></font>
      <div align="right"></div></td>
      <td width="61%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" colspan="4"><hr size="1" noshade></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<%if(vLoans != null && vLoans.size() > 1){%>
    <tr bgcolor="#99CCFF"> 
      <td width="3%" height="18">&nbsp;</td>
      <td colspan="6"><strong><font color="#FF3300">:: DEDUCTIONS - LOANS ::</font></strong></td>
    </tr>    
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
		  for (l = 1; l < vLoans.size(); l+=8,iRow++){%>
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
					  <input type="hidden" name="oth_ded_index<%=iRow%>" value="<%=(String)vLoans.elementAt(l)%>">					
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
      <% strTemp = null;
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String) vEditInfo.elementAt(3);
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dLoansAdvMisc += Double.parseDouble(strTemp);
			}
		  %>		
      <td width="14%">         
          <%if(strPrepareToEdit.compareTo("0") != 0) {%>
          <a href='javascript:updateLoans("<%=WI.getStrValue((String)vEditInfo.elementAt(0),"0")%>");'> <img src="../../../../images/update.gif" width="60" height="26" border="0"></a>
          <%}%>   
      </td>
      <td width="11%"><div align="right"> <font size="1"><strong> 
          <input name="loans_adv_deduction" type="text" size="10" maxlength="10" class="textbox_noborder"
		   value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right" readonly>
      </strong></font> </div></td>
      <td colspan="3"> 
    <!--
	  <strong><a href="javascript:ViewLoansAndOtherDetail();"><img src="../../../../images/view.gif" border="0"></a><font size="1">View 
        loans and advances detail</font></strong>
		-->
      </td>
    </tr>
    <tr bgcolor="#99CCFF"> 
      <td height="18">&nbsp;</td>
      <td colspan="6"><strong><font color="#FF3300">:: DEDUCTIONS - MISCELLANEOUS ::</font></strong></td>
    </tr>
    <%if(vMiscDed != null && vMiscDed.size() > 1){%>
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
								int iCount  = 0;
				for (l = 1; l < vMiscDed.size(); l+=4,iCount++,iRow++){
					if(iCount == 5){
						bolMoreDeduct = true;				
						break;
					}
				%>
                <tr> 
                  <td height="18">&nbsp;<%=(String)vMiscDed.elementAt(l+1)%></td>
                  <%
				  strTemp = (String)vMiscDed.elementAt(l+2);
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
                  <input type="hidden" name="misc_ded_index<%=iRow%>" value="<%=(String)vMiscDed.elementAt(l+3)%>">
                  <%}%>
                  <input type="hidden" name="post_deduct_index<%=iRow%>" value="<%=(String)vMiscDed.elementAt(l)%>">
                </tr>
                <%}%>
              </table></td>
            <td width="49%" valign="	"> <%if(bolMoreDeduct){%> <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr> 
                  <td width="25%"><div align="center"><font size="1"><strong>&nbsp;CHARGES 
                      NAME </strong></font></div></td>
                  <td width="25%"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
                </tr>
                <%for (; l < vMiscDed.size(); l+=4,iCount++,iRow++){%>
                <tr> 
                  <td height="18">&nbsp;<%=(String)vMiscDed.elementAt(l+1)%></td>
                  <%
				  strTemp = (String)vMiscDed.elementAt(l+2);
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
                  <input type="hidden" name="misc_ded_index<%=iRow%>" value="<%=(String)vMiscDed.elementAt(l+3)%>">
                  <%}%>
                  <input type="hidden" name="post_deduct_index<%=iRow%>" value="<%=(String)vMiscDed.elementAt(l)%>">
                </tr>
                <%}// end for (; l < vMiscDed.size(); l+= ......%>
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
      <td><div align="right">
          <%if(strPrepareToEdit.compareTo("0") != 0 && !bolIsReleased) {%>
          <a href='javascript:updateMiscellaneous("<%=WI.getStrValue((String)vEditInfo.elementAt(0),"0")%>");'><img src="../../../../images/update.gif" width="60" height="26" border="0"></a>
          <%}%>
         </div></td>
      <% strTemp = null;
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String) vEditInfo.elementAt(5);
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dLoansAdvMisc += Double.parseDouble(strTemp);
			}
		  %>						
      <td><div align="right"><font size="1"><strong> 
          <input name="misc_deduction" type="text" size="10" maxlength="10" class="textbox_noborder"
		   value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right" readonly>
          </strong></font> </div></td>
      <td colspan="3"> 
        <!--
	  <strong><a href="javascript:ViewOtherDeductionDetail();"><img src="../../../../images/view.gif" border="0"></a><font size="1">View 
        other deductions detail</font></strong>
	  -->
      </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="2">Loans &amp; Miscellaneous Total</td>
      <%
	  	strTemp = WI.getStrValue(Double.toString(dLoansAdvMisc), WI.fillTextValue("loans_misc_ded"));		
			strTemp = CommonUtil.formatFloat(strTemp,true);
			%>
      <td><div align="right"><strong> 
          <input name="loans_misc_ded" type="text" value="<%=WI.getStrValue(strTemp,"0")%>" 
		size="12" maxlength="12"  class="textbox_noborder" style="text-align: right" readonly>
          </strong></div></td>
      <td width="50%" colspan="3">&nbsp;</td>
    </tr>
  </table>	
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td height="18"  colspan="3" bgcolor="#FFFFFF"><hr size="1" noshade></td>
    </tr>
    <tr> 
      <td height="31"  colspan="3" valign="bottom" bgcolor="#FFFFFF"><div align="center">
          <%if(strPrepareToEdit.compareTo("1") != 0) {%>
          <%if(iAccessLevel > 1) {%>
          <!--
					<a href='javascript:PageAction(1, "");'><img src="../../../../images/save.gif" border="0" id="hide_save"></a> 
					-->
					<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1', '');">
          <font size="1"> click to save entries</font> 
          <%}%>
		  <%}else{%>
          <!--
					<a href='javascript:PageAction(2,"");'> <img src="../../../../images/edit.gif" border="0"></a>
					-->
					<input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2', '');">
					<font size="1"> click to save changes</font> 
		  <%}%>
          <!--
					<a href="javascript:CancelRecord();"><img src="../../../../images/cancel.gif" border="0"></a> 
					-->
					<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">
          <font size="1">Click to cancel or go previous</font>           
      </div></td>
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
  <input type="hidden" name="info_index" value="<%=strInfoIndex%>">  
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="reset_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>