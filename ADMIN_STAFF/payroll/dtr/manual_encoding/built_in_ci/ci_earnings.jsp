<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig, payroll.PReDTRME,
									payroll.PRMiscDeduction, payroll.PRBuiltInCI, payroll.PRSalary, payroll.PRSalaryExtn"%>
<%
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CI Earnings</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../../jscript/formatFloat.js"></script>
<script>
<!--
function Recompute(){
	var vProceed = confirm("This would remove the employee payroll. Do you want to continue?");
	if(vProceed){
		document.form_.prepareToEdit.value = "0";
		document.form_.page_action.value = "";
		document.form_.remove_.value = "1";
		document.form_.submit();
	//this.SubmitOnce('form_');
	}else{
		return;
	}
}

function PageAction(strAction, strInfoIndex) {
	document.form_.print_pg.value="";
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../../images/blank.gif";
	document.form_.submit();
}

function PrepareToEdit(strIndex){
	document.form_.print_pg.value="";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strIndex;
	document.form_.submit();
}

function CancelRecord(){
	document.form_.prepareToEdit.value = "0";
	document.form_.page_action.value = "";
	document.form_.print_pg.value="";
	this.SubmitOnce('form_');
}

function ComputeTax(){
	if(document.form_.tax_value.value.length == 0){
		alert("Enter tax amount or percentage");
		return;
	}

	if(document.form_.hourly_rate.value.length == 0 || 
		document.form_.hourly_rate.value == 'null'){
		alert("Enter teaching rate at the salary rate page");
		return;
	}
	
	
	if(document.form_.con_unit.value == "1")
		document.form_.tax_amount.value = document.form_.tax_value.value;
	else{
		var vHoursWork = document.form_.hours_work.value;
		var vMinsWork  = document.form_.minutes_work.value;
		var vTotalWork = eval((vHoursWork * 60)) +  eval(vMinsWork);
		var vRate = document.form_.hourly_rate.value;

		vTotalWork = formatFloat(vTotalWork/60,1,true);

		var vTax = eval(vTotalWork) * eval(vRate);
		vTax = vTax * eval(document.form_.tax_value.value)/100;
		vTax = formatFloat(vTax,1,false);
		document.form_.tax_amount.value = vTax;
	}
}

function OpenSearch() {
	var pgLoc = "../../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage() {
	document.form_.prepareToEdit.value = "0";
	document.form_.page_action.value = "";
	document.form_.print_pg.value="";
	this.SubmitOnce('form_');
}

function CopyID(strID)
{
	document.form_.emp_id.value=strID;
	document.form_.print_pg.value="";
	this.SubmitOnce("form_");
}

function UpdateToZero(strTextName){
	if(eval('document.form_.'+strTextName+'.value.length') == 0){
		eval('document.form_.'+strTextName+'.value= "0"');
	}
}
///////////////////////////////////////// used to collapse and expand filter ////////////////////
var openImg = new Image();
openImg.src = "../../../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../../../images/box_with_plus.gif";

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
	var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
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
<body bgcolor="#D2AE72" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit = null;
	String strHasWeekly = null;

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
								"Admin/staff-Payroll-DTR-CI Earnings","ci_earnings.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");								
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
	PRBuiltInCI prBuiltIn = new PRBuiltInCI();
	PRSalary Salary = new PRSalary();
	PRSalaryExtn salExtn = new PRSalaryExtn();
	
	Vector vRetResult = null;
	Vector vEditInfo= null;	
	Vector vPersonalDetails = null;
	Vector vEmpList         = null;
	Vector vSalaryPeriod 	= null;//detail of salary period.
	Vector vSalaryDetails = null;
		
	String strEmpID = WI.fillTextValue("emp_id");
	String strPageAction = WI.fillTextValue("page_action");
	strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String strEmployeeIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
	String[] astrRateType = {"%","Specific Amount"};
	String strPayrollPeriod = null;
	String strSalDateFr = null;
	String strSalDateTo = null;
	int iTotalHours = 0;
	int iTotalMin = 0;
	int iTemp = 0;
	String strReadOnly = "0";
	
	double dHourlyRate = 0d;
	boolean bolCheckCI = false;
	bolCheckCI = prBuiltIn.checkIfEmployeeIsCI(dbOP, strEmployeeIndex);
	if(!bolCheckCI)
		strErrMsg = prBuiltIn.getErrMsg();
		
	if (strEmpID.length() > 0 && WI.fillTextValue("sal_period_index").length() > 0 && bolCheckCI) {
			enrollment.Authentication authentication = new enrollment.Authentication();
			vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
 	
		if(vPersonalDetails == null){
			strErrMsg = "Employee Profile not Found";
		}
	}//System.out.println(vPersonalDetails);

		
	if(WI.fillTextValue("year_of").length() > 0) {
		vSalaryPeriod = prEdtrME.getEmployeePeriods(dbOP, request, strEmployeeIndex);
		if(vSalaryPeriod == null)
			strErrMsg = prEdtrME.getErrMsg();
	}	

	if (strPageAction.length() > 0){
		if (strPageAction.compareTo("0")==0) {

		}else if(strPageAction.compareTo("1") == 0){
			if (prBuiltIn.operateOnBuiltInSalary(dbOP,request,1) != null){
				strErrMsg = " CI Earnings saved successfully ";
			}else{
				strErrMsg = prBuiltIn.getErrMsg();
			}
		}else if(strPageAction.compareTo("2") == 0){
			if (prBuiltIn.operateOnBuiltInSalary(dbOP,request,2) != null){
				strErrMsg = " CI Earnings updated successfully ";
				strPrepareToEdit = "";
			}else{
				strErrMsg = prBuiltIn.getErrMsg();
			}
		}
	}
	
	if(WI.fillTextValue("remove_").length() > 0){
		if (salExtn.removeSavedPayroll(dbOP,request, WI.fillTextValue("sal_index")) == false)
			strErrMsg = salExtn.getErrMsg();
		else{
			strErrMsg = "Removed Payroll";
		}
	}

	vEditInfo = prBuiltIn.operateOnBuiltInSalary(dbOP,request,4);
 	if (vEditInfo == null)
		strErrMsg = prBuiltIn.getErrMsg();	
	else
		strPrepareToEdit = "1";
	
	Vector vTemp = null;
	double dAdjustment = 0d;
	String strAdjToggle = null;
	if(WI.fillTextValue("sal_period_index").length()  > 0){
		vTemp = salExtn.getManualAdjustments(dbOP, WI.fillTextValue("sal_period_index"), strEmployeeIndex);
		if (vTemp != null && vTemp.size() > 0) {
			dAdjustment = Double.parseDouble((String) vTemp.elementAt(0));
			if (vTemp.size() > 3)
				strReadOnly = "1";
		}
	}
%>
<form action="ci_earnings.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL - SET CI EARNINGS PAGE ::::</strong></font></td>
    </tr>
  </table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="3">&nbsp;<font size="2" color="#FF0000"><strong><font size="1"><a href="./ci_main.jsp"><img src="../../../../../images/go_back.gif" width="50" height="27" border="0"></a></font></strong></font><%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td>Employee ID</td>
      <td><input name="emp_id" type="text" size="16" value="<%=strEmpID%>" class="textbox" onKeyUp="AjaxMapName(1);"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:OpenSearch();"><img src="../../../../../images/search.gif" width="37" height="30" border="0"></a><label id="coa_info"></label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td> <select name="month_of" onChange="document.form_.reset_page.value='1';ReloadPage();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%>
        </select>
        -
        <select name="year_of" onChange="document.form_.reset_page.value='1';ReloadPage();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%>
        </select>
        (Must be filled up to display salary period information)      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="19%">Salary Period</td>
      <td>
	  <select name="sal_period_index" style="font-weight:bold;font-size:11px" onChange="ReloadPage();">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};		
	 	strTemp = WI.fillTextValue("sal_period_index");
		for(int i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
		  if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
			strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
			strTemp2 += "Whole Month";
		  }else{
			strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
			strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);			
//			strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//				(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		  }
			
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
			strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			strSalDateFr = (String)vSalaryPeriod.elementAt(i + 6);
			strSalDateTo = (String)vSalaryPeriod.elementAt(i + 7);
		%>		
			<option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
			<%}else{%>
			<option value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
			<%}//end of if condition.
		 }//end of for loop.
		 if(strSalDateFr != null && strSalDateTo != null){
			 vSalaryDetails = Salary.getSalaryDetails(dbOP, strEmployeeIndex, strSalDateFr, strSalDateTo);
			 if(vSalaryDetails != null && vSalaryDetails.size() > 0){
				 strTemp = WI.getStrValue((String)vSalaryDetails.elementAt(4),(String)vSalaryDetails.elementAt(5));
 			 }else{
				 strTemp = "";
			 }
		 }
		 %>
        </select> 
			<input type="hidden" name="hourly_rate" value="<%=strTemp%>">
			<% 
				if(strHasWeekly.equals("1")){
					strTemp = WI.fillTextValue("is_weekly");
					if(strTemp.compareTo("1") == 0) 
						strTemp = " checked";
					else	
						strTemp = "";
				%>
      <input type="checkbox" name="is_weekly" value="1" <%=strTemp%> onClick="ReloadPage();">
      <font size="1">for weekly </font>
      <%}// check if the company has weekly salary type%></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:ReloadPage();"></a><font size="1">
        <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
        Click
        to reload page.</font></td>
    </tr>
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>	
	<%if(vPersonalDetails != null && vPersonalDetails.size() > 0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
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
      <td height="29"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : </td>
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
      <td  height="10" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>	
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
    
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="23%">&nbsp;Hours Worked : </td>
			<%
					if (vEditInfo != null) 
						strTemp = (String)vEditInfo.elementAt(7);
					else 
						strTemp = WI.fillTextValue("hours_work"); 				
			%>		
      <td width="74%" height="26">
			<input name="hours_work" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp="AllowOnlyInteger('form_','hours_work')" value="<%=WI.getStrValue(strTemp,"0")%>" size="6" maxlength="6" 
			onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','hours_work');UpdateToZero('hours_work');">
			(hrs) 
			<%
					if (vEditInfo != null) 
						strTemp = (String)vEditInfo.elementAt(8);
					else 
						strTemp = WI.fillTextValue("minutes_work"); 				
			%>	
			and	
			<input name="minutes_work" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp="AllowOnlyInteger('form_','minutes_work')" value="<%=WI.getStrValue(strTemp,"0")%>" size="6" maxlength="6" 
			onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','minutes_work');UpdateToZero('minutes_work');">
			(minutes)</td>
    </tr>
    
    
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26" colspan="2"><div onClick="showBranch('branch6');swapFolder('folder6')">
          <img src="../../../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6">
           <strong><font color="#0000FF">Compute Tax</font></strong></div>
        <span class="branch" id="branch6">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="13%">
						<% 
							strTemp = WI.fillTextValue("tax_value");
						%>
              <input name="tax_value" type="text" size="8" maxlength="10" value="<%=WI.getStrValue(strTemp,"2")%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
              <select name="con_unit">
                <option value="0">Percent of Earning</option>
                <%
								if(vEditInfo != null && vEditInfo.size() > 0) 
									strTemp = (String)vEditInfo.elementAt(2);
								else	
									strTemp = WI.fillTextValue("con_unit");
								if(strTemp.compareTo("1") == 0) {%>
                <option value="1" selected>Fixed Amount</option>
                <%}else{%>
                <option value="1">Fixed Amount</option>
                <%}%>
              </select>
            <input type="button" name="compute" value=" Compute " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:ComputeTax();"></td>					
          </tr>
        </table>
        </span> </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>&nbsp;Tax</td>

			<%
					if (vEditInfo != null) 
						strTemp = (String)vEditInfo.elementAt(5);
					else 
						strTemp = WI.fillTextValue("tax_amount");				
					
			%>				
      <td height="26"><input name="tax_amount" type="text" class="textbox_noborder" value="<%=strTemp%>" readonly></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td> &nbsp;Adjustment</td>
			<%
				if (vEditInfo != null) 
					strTemp = (String)vEditInfo.elementAt(9);
				else{
					if(strReadOnly.equals("1")) {						
						strTemp = CommonUtil.formatFloat(dAdjustment, 2);
					}else {
						strTemp = WI.fillTextValue("adjustment_amt");					
					}
				}
 				strTemp = ConversionTable.replaceString(strTemp,"-","");
				if(strReadOnly.equals("1"))
					strReadOnly = " readonly";
				else
					strReadOnly = "";
 			%>
      <td height="26"><input name="adjustment_amt" type="text" size="10" maxlength="10" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
	  onKeyUp="AllowOnlyFloat('form_','adjustment_amt');" style="text-align : right" <%=strReadOnly%>
	  onBlur="AllowOnlyFloat('form_','adjustment_amt'); UpdateToZero('adjustment_amt');style.backgroundColor='white'">
        <%if(strReadOnly.length() == 0){%>
        <select name="adjustment_type">
          <option value="0">credit</option>
          <%if(dAdjustment < 0){%>
          <option value="1" selected>debit</option>
          <%} else {%>
          <option value="1">debit</option>
          <%}%>
        </select>
        <%}else{%>
        <%if(dAdjustment < 0){%>
debit
<input type="hidden" name="adjustment_type" value="1">
<%}else{%>
credit
<input type="hidden" name="adjustment_type" value="0">
<%}%>
<%}%></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="26">&nbsp;</td>
    </tr>
		<% if(vEditInfo != null) {%>
    <tr>
      <td height="43" colspan="3" align="center">			
			<%if(iAccessLevel == 2){%>
			<font size="1">
        <input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:Recompute();">
click to delete saved payroll </font>
			<%}else{%>
				Not Authorized to delete
			<%}%>
			</td>
    </tr>
		<%}%>
    <tr> 
      <td height="43" colspan="3" align="center">  
				<% if(vEditInfo != null) {%>
				<!--
          <a href='javascript:PageAction(2,<%=WI.fillTextValue("info_index")%>);'><img src="../../../../../images/edit.gif" width="40" height="26" border="0"></a>
					-->
				<input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2','<%=WI.getStrValue((String)vEditInfo.elementAt(0))%>');">
				<font size="1">click to save changes</font>
        <%}else{%>
        <!--
					<a href='javascript:PageAction(1,"");'><img src="../../../../../images/save.gif" border="0" name="hide_save"></a>
					-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');">
				<font size="1">click to add</font> 
        <%}%>
       	<!--
				  <a href="javascript:CancelRecord();"><img src="../../../../../images/cancel.gif" width="51" height="26" border="0"></a>
					-->
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">					
				<font size="1">click to cancel</font>				</td>
    </tr>
  </table>
		<%}%>
	  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="24"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
	<%
		strTemp = "";
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(1);
	%>
	<input type="hidden" name="sal_index" value="<%=WI.getStrValue(strTemp,"0")%>">	
  </table>
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="print_pg">
<input type="hidden" name="reset_page">
<input type="hidden" name="remove_">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>