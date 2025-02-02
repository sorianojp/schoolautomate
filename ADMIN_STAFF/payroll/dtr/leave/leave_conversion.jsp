<%@ page language="java" import="utility.*, payroll.PReDTRME, payroll.PRLeaveConversion,
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
<title>Leave Conversion</title>
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

function ComputeLeavePayable(strRow){
	//var vLeaveAmt = eval('document.form_.leave'+strRow+'.value');
	var vTotalPay = 0;
	var vDays = 0;  
	var vTemp = 0;
	var vLeaveCount = document.form_.leave_count.value;
	var vRate =  document.form_.rate.value;
//	if (vLeaveAmt.length == 0){
//		 return;
//	}

	for(var i = 0; i < eval(vLeaveCount);i++){		
		vTemp = eval('document.form_.leave'+i+'.value');
		
		if(isNaN(vTemp) || vTemp.length == 0)
			vTemp = 0;		
		vDays = eval(vDays) + eval(vTemp);		
	}	
	
	vTotalPay = eval(vDays)  * eval(vRate);	
	document.form_.total_amount.value = eval(vTotalPay);
	document.form_.total_amount.value = truncateFloat(document.form_.total_amount.value,2,true);
	document.form_.total_days.value = eval(vDays);
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
	  document.form_.loans_misc_ded.value = truncateFloat(document.form_.loans_misc_ded.value,1,true);
  }
}
function updateLoans(strConversionIndex){
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "../pay_loansmisc/pay_loans.jsp?emp_id="+document.form_.emp_id.value+
				"&index_name=conversion_index&index="+strConversionIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function updateMiscellaneous(strConversionIndex){
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "../pay_loansmisc/pay_misc.jsp?emp_id="+document.form_.emp_id.value+
				"&index_name=conversion_index&index="+strConversionIndex;
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

function ForwardLeave() {	
	document.form_.forward_leave.value = "1";
	this.SubmitOnce('form_');
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
								"Admin/staff-Payroll-DTR-Leave Conversion","leave_conversion.jsp");
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
	PRLeaveConversion prLeave = new PRLeaveConversion();

	Vector vRetResult = null;		
	Vector vPersonalDetails = null; 
	Vector vLeaves	  = null;
	Vector vEditInfo  = null;
	Vector vMiscDeductions  = null;
	Vector vLoans			= null;
	double dLoansAdvMisc    = 0d;
	boolean bolMoreDeduct = false;
	String strEmpID   = WI.fillTextValue("emp_id");
	double dDaysTotal = 0d;
		
	int l = 0;	
	int iRow = 0;
	int iItems  = 0;
	String strConversionIndex = WI.fillTextValue("conversion_index");
	boolean bolIsReleased = false;
	String strReleased  = null;
	int iCount = 0;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
  if(strSchCode == null)
		strSchCode = "";	

	if(WI.fillTextValue("forward_leave").length() > 0){
		if(!prLeave.forwardLeaveConversion(dbOP, request, strConversionIndex))
			strErrMsg = prLeave.getErrMsg();
		else
			strErrMsg = "Forwarding successful";
	}
	
	String strPageAction = WI.fillTextValue("page_action");
	if(strPageAction.length() > 0) {
		if(prLeave.operateOnLeaveConversion(dbOP, request, Integer.parseInt(strPageAction)) == null)
			strErrMsg = prLeave.getErrMsg();
		else {	
			if(strPageAction.equals("1"))
				strErrMsg = "Leave Conversion successfully posted.";
			if(strPageAction.equals("2"))
				strErrMsg = "Leave Conversion successfully edited.";
			if(strPageAction.equals("0")){
				strErrMsg = "Leave Conversion successfully removed.";
				strPrepareToEdit = "0";
			}
		}
	}	
	
 if (strEmpID.length() > 0 && WI.fillTextValue("reset_page").length() == 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");

	if(vPersonalDetails == null){
		strErrMsg = "Employee Profile not Found";
	}

	vRetResult = prLeave.getAvailableLeave(dbOP,request);
	if(vRetResult == null){
		strErrMsg = prLeave.getErrMsg();
	}else{
		vLeaves = (Vector)vRetResult.elementAt(0);
		strConversionIndex = (String)vRetResult.elementAt(5);
		strReleased = (String)vRetResult.elementAt(6);
		strReleased = WI.getStrValue(strReleased);
		if(strReleased.equals("1"))
			bolIsReleased = true;
	}
	
}

if(strConversionIndex != null && strConversionIndex.length() > 0){
		strPrepareToEdit = "1";
		vEditInfo = prLeave.operateOnLeaveConversion(dbOP, request,4, strConversionIndex);		
		if(vEditInfo == null){
			strPrepareToEdit = "0";
			strErrMsg = prLeave.getErrMsg();		
		}else{
			vLeaves = (Vector)vEditInfo.elementAt(1);
			vLoans = (Vector)vEditInfo.elementAt(4);
			vMiscDeductions = (Vector)vEditInfo.elementAt(6);
		}
}

%>
<form name="form_" action="./leave_conversion.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL :  LEAVE CONVERSION PAGE ::::</strong></font></td>
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
			<input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox" onKeyUp="AjaxMapName(1);"
	     onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
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
      <td><font size="1">
        <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
        Click 
        to reload page</font></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1" color="#0000FF"></td>
    </tr>
  </table>
 <% if((vPersonalDetails != null && vPersonalDetails.size() > 0) && vRetResult != null && vRetResult.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td width="3%" height="20">&nbsp;</td>
      <td>Employee Name</td>
      <td colspan="2"><strong>&nbsp;<%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td>Employee ID</td>
      <td colspan="2"><strong>&nbsp;<%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
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
      <td height="20">&nbsp;</td>
      <td>Employment Type/Position</td>
      <td colspan="2"><strong>&nbsp;<%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td width="25%">Employment Status</td>
      <td colspan="2"><strong>&nbsp;<%=(String)vPersonalDetails.elementAt(16)%></strong></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Daily rate </td>
			<%
				strTemp = (String)vRetResult.elementAt(3);
			%>
      <td width="11%"><div align="right"><strong><%=strTemp%><input type="hidden" name="rate" value="<%=strTemp%>"></strong></div></td>
      <td width="61%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td>Leave conversion amount</td>
			<% 
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(2);
				else
					strTemp = (String)vRetResult.elementAt(2);
				strTemp = CommonUtil.formatFloat(strTemp, true);
				strTemp = ConversionTable.replaceString(strTemp, ",", "");
			%>
      <td align="right"><font size="1"><strong>
        <input name="total_amount" type="text" size="10" maxlength="10" class="textbox_noborder"
		   value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right" readonly>
      </strong></font></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" colspan="4"><hr size="1" noshade></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#99CCFF">
      <td width="4%">&nbsp;</td> 
      <td width="96%" height="18"><strong><font color="#FF3300">:: AVAILABLE LEAVES ::</font></strong></td>
    </tr>
    <tr>
      <td colspan="2"><div align="center">
        <table width="50%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">        
            <%if(vLeaves != null && vLeaves.size() > 0){%>
          <tr>
            <td width="50%"><div align="center"><font size="1"><strong>LEAVE NAME </strong></font></div></td>
              <td width="50%"><div align="center"><font size="1"><strong>LEAVE TO CONVERT </strong></font></div></td>
            </tr>
          <%iRow = 0;					
				  for (l = 0; l < vLeaves.size(); l+=4,iRow++){%>
            <tr>
              <%
							strTemp = (String)vLeaves.elementAt(l+1);
							%>
              <td height="18"><font size="1">&nbsp;<%=strTemp%></font></td>
              <%
								strTemp = (String)vLeaves.elementAt(l+2);								
								dDaysTotal += Double.parseDouble(strTemp);
							%>
              <td><div align="center"><font size="1">&nbsp;<strong>
                  <input name="leave<%=iRow%>" type="text" size="8" maxlength="65" class="textbox"
									onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
									onKeyUp="AllowOnlyFloat('form_','leave<%=iRow%>');ComputeLeavePayable('<%=iRow%>')" style="text-align : right"
									onBlur="AllowOnlyFloat('form_','leave<%=iRow%>');
									ComputeLeavePayable('<%=iRow%>');style.backgroundColor='white'">									
									<%if(strPrepareToEdit.equals("1")){%>
									<input type="hidden" name="old_leave<%=iRow%>" value="<%=(String)vLeaves.elementAt(l+2)%>">
									<input type="hidden" name="leave_detail_index<%=iRow%>" value="<%=(String)vLeaves.elementAt(l+3)%>">
									<%}%>
									<input type="hidden" name="avail_leave_index<%=iRow%>" value="<%=(String)vLeaves.elementAt(l)%>">									
                  &nbsp; </strong></font></div></td>
            </tr>
            <%}%>
          <input type="hidden" name="leave_count" value="<%=iRow%>">
					<input type="hidden" name="total_days" value="<%=dDaysTotal%>">
          <%}// end if vLeaves != null%>
          </table>
      </div></td>
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
			  	iItems = 8;
		  for (l = 1; l < vLoans.size(); l+=iItems,iRow++){%>
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
				strTemp = (String) vEditInfo.elementAt(5);
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dLoansAdvMisc += Double.parseDouble(strTemp);
			}
		  %>		
      <td width="15%">         
          <%if(strPrepareToEdit.equals("1") && !bolIsReleased) {%>
          <a href='javascript:updateLoans("<%=WI.getStrValue(strConversionIndex,"0")%>");'> <img src="../../../../images/update.gif" width="60" height="26" border="0"></a>
          <%}%>   
      </td>
      <td width="12%"><div align="right"> <font size="1"><strong> 
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
      <td><div align="right">
          <%if(strPrepareToEdit.equals("1") && !bolIsReleased) {%>
          <a href='javascript:updateMiscellaneous("<%=WI.getStrValue(strConversionIndex,"0")%>");'><img src="../../../../images/update.gif" width="60" height="26" border="0"></a>
          <%}%>
         </div></td>
      <% strTemp = null;
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String) vEditInfo.elementAt(7);
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
      <td width="48%" colspan="3">&nbsp;</td>
    </tr>
  </table>		
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="13"  colspan="3" bgcolor="#FFFFFF"><hr size="1" color="#0000FF"></td>
    </tr>
    <tr> 
      <td height="31"  colspan="3" valign="bottom" bgcolor="#FFFFFF"><div align="center">
			<%if(bolIsReleased){%>
			Already Released
			<%}else{%>
        <%if(!strPrepareToEdit.equals("1")) {%>
          <%if(iAccessLevel > 1) {%>
          <a href='javascript:PageAction(1, "");'></a> 
          <font size="1"> 
          <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction(1, '');">
          click to save entries</font> 
          <%}%>
		    <%}else{%>          
          <input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction(2, '');">
          <font size="1">click to save changes</font>
					 <%if(iAccessLevel == 2) {%>
          <input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction(0, '');">
          <font size="1">click to remove saved conversion </font>
		      <%}
					}%>
		      <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:CancelRecord();">
          <font size="1"> click to cancel or go previous</font>           
			<%}%>			
      </div></td>
    </tr>
  </table>
	<%if(strSchCode.startsWith("TAMIYA") && strPrepareToEdit.equals("1") && !bolIsReleased){%>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
			<%
				strTemp = WI.fillTextValue("date_release");
				if(strTemp.length() > 0)
					strTemp = WI.getTodaysDate(1);
				
			%>
      <td height="25" bgcolor="#FFFFFF"><strong>
        <input name="date_release" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_release');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../../images/calendar_new.gif" border="0"></a></strong></td>
    </tr>

    <tr> 
      <td height="25" bgcolor="#FFFFFF"><input type="button" name="cancel2" value=" Forward " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:ForwardLeave();">
			<font size="1">forward the leave conversion to salary</font></td>
    </tr>
    <tr>
      <td height="25" bgcolor="#FFFFFF"><p><strong>Notes</strong><br>
        1. Users should create a 'Leave conversion' as earning name<br>
        2. Forwarded to salary leaves will fall under 'leave conversion' earnings<br>
        3. Leaves that are forwarded as earning will be considered as released leaves and can no longer be reverted as leaves. <br>
        4. Leaves forwarded in excess of 10 days will be  considered a taxable earning
      </p>
        </td>
    </tr>
  </table>
	<%}%>
<%}//show only if vPersonalDtls not null.%>
  <table cellpadding="0" cellspacing="0" width="100%">
    <tr>
      <td height="20"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
</table>
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">  
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="reset_page">
	<input type="hidden" name="conversion_index" value="<%=strConversionIndex%>">
	<input type="hidden" name="forward_leave">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>