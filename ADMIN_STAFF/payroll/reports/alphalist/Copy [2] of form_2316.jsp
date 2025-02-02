<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRTaxReport" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Form 2316 encoding</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css"> 

<style type="text/css">
td {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td.answer{
	font-family: Arial, Helvetica, sans-serif;
	font-size: 12px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--

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
	document.form_.print_pg.value = "";
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

function ajaxComputeTax(){
	var vNetTaxable = document.form_.net_taxable.value;
	var objTaxDue = document.form_.tax_due;
	
	this.InitXmlHttpObject(objTaxDue, 1);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=302&net_taxable="+vNetTaxable;
	this.processRequest(strURL);
}

function ReloadPage(){
	document.form_.print_pg.value = "";
	document.form_.submit();
}

function SaveRecord(){
	document.form_.print_pg.value = "";
	document.form_.page_action.value = "1";
	document.form_.submit();
}

function EditRecord(strInfoIndex){
	document.form_.print_pg.value = "";
	document.form_.page_action.value = "2";
	document.form_.info_index.value = strInfoIndex;	
	this.SubmitOnce('form_');
}

function DeleteRecord(strInfoIndex){
	document.form_.print_pg.value = "";
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;	
	this.SubmitOnce('form_');
}

function CancelRecord(){
	location = "./form_2316.jsp";
}

function PrintForm(){
	document.form_.print_pg.value = "1";
 	this.SubmitOnce('form_');
}

function computeNonTaxableTotal(){
 	var vTotalAmt = 0;
	var vBasicNoTax = document.form_.basic_sal_ntax.value;	
	var vHolidayPay = document.form_.holiday_pay.value;
	var vOTNoTax = document.form_.ot_non_taxable.value;
	var vNpPay = document.form_.np_pay.value;
	var vHazardNoTax = document.form_.hazard_non_tax.value;
	var vBonusNoTax = document.form_.bonus_non_tax.value;
	var vDeMinimis  = document.form_.de_minimis.value;
	var vContributions = document.form_.contributions.value;
	var vOtherComp = document.form_.other_comp.value;
	var vNonTaxTotal = null;

	
	if(isNaN(vBasicNoTax) || isNaN(vHolidayPay) || isNaN(vOTNoTax) || isNaN(vNpPay)
		|| isNaN(vHazardNoTax) || isNaN(vBonusNoTax) || isNaN(vDeMinimis) || isNaN(vContributions)
		|| isNaN(vOtherComp)){
		return;
	}

	if(vBasicNoTax.length == 0 || document.form_.basic_sal_ntax.disabled)
		vBasicNoTax = "0";

	if(vHolidayPay.length == 0 || document.form_.holiday_pay.disabled)
		vHolidayPay = "0";

	if(vOTNoTax.length == 0 || document.form_.ot_non_taxable.disabled)
		vOTNoTax = "0";

	if(vNpPay.length == 0 || document.form_.np_pay.disabled)
		vNpPay = "0";				
	
	if(vHazardNoTax.length == 0 || document.form_.hazard_non_tax.disabled)
		vHazardNoTax = "0";				
	
	if(vBonusNoTax.length == 0)
		vBonusNoTax = "0";				
	
	if(vDeMinimis.length == 0)
		vDeMinimis = "0";				
	
	if(vContributions.length == 0)
		vContributions = "0";				
	
	if(vOtherComp.length == 0)
		vOtherComp = "0";				
	
	vNonTaxTotal = eval(vBasicNoTax) + eval(vHolidayPay) + eval(vOTNoTax) + eval(vNpPay)
		+ eval(vHazardNoTax) + eval(vBonusNoTax) + eval(vDeMinimis) + eval(vContributions)
		+ eval(vOtherComp);	
 
	document.form_.non_taxable.value = eval(vNonTaxTotal);	
	document.form_.non_taxable_.value = eval(vNonTaxTotal);	
	computeGross();	
//	document.form_.non_taxable.value = truncateFloat(document.form_.non_taxable.value,1,false);	
}

 function computeTaxableTotal(){
 	var vBasicTaxable = document.form_.basic_taxable.value;	
	var vRep = document.form_.representation.value;
	var vTranspo = document.form_.transportation.value;
	var vCola = document.form_.cola.value;
	var vHousing = document.form_.housing_allow.value;
	var vRegAmtA = document.form_.regular_amt_a.value;
	var vRegAmtB = document.form_.regular_amt_b.value;
	var vCommission = document.form_.commission.value;
	var vProfitShare = document.form_.profit_share.value;
	
	var vFees = document.form_.fees.value;
	var vTaxableBonus = document.form_.bonus_taxable.value;
	var vTaxableHazard = document.form_.hazard_taxable.value;
	var vTaxableOT = document.form_.ot_taxable.value;
	var vSupAmtA = document.form_.sup_amt_a.value;
	var vSupAmtB = document.form_.sup_amt_b.value;
	var vTaxableTotal = null;

	
	if(isNaN(vBasicTaxable) || isNaN(vRep) || isNaN(vTranspo) || isNaN(vCola)
		|| isNaN(vHousing) || isNaN(vRegAmtA) || isNaN(vRegAmtB) || isNaN(vCommission)
		|| isNaN(vProfitShare) || isNaN(vFees) || isNaN(vTaxableBonus) 
		|| isNaN(vTaxableHazard) || isNaN(vTaxableOT) || isNaN(vSupAmtA)
		|| isNaN(vSupAmtB)){
		return;
	}

	if(vBasicTaxable.length == 0)
		vBasicTaxable = "0";

	if(vRep.length == 0)
		vRep = "0";

	if(vTranspo.length == 0)
		vTranspo = "0";

	if(vCola.length == 0)
		vCola = "0";				
	
	if(vHousing.length == 0)
		vHousing = "0";				
	
	if(vRegAmtA.length == 0)
		vRegAmtA = "0";				
	
	if(vRegAmtB.length == 0)
		vRegAmtB = "0";				
	
	if(vCommission.length == 0)
		vCommission = "0";				
	
	if(vProfitShare.length == 0)
		vProfitShare = "0";				

	if(vFees.length == 0)
		vFees = "0";				
	
	if(vTaxableBonus.length == 0)
		vTaxableBonus = "0";	
		
	if(vTaxableOT.length == 0)
		vTaxableOT = "0";				

	if(vTaxableHazard.length == 0)
		vTaxableHazard = "0";				
	
	if(vSupAmtA.length == 0)
		vSupAmtA = "0";	
		
	if(vSupAmtB.length == 0)
		vSupAmtB = "0";			
			
	vTaxableTotal = eval(vBasicTaxable) + eval(vRep) + eval(vTranspo) + eval(vCola)
		+ eval(vHousing) + eval(vRegAmtA) + eval(vRegAmtB) + eval(vCommission)
		+ eval(vProfitShare) + eval(vFees) + eval(vTaxableBonus) 
		+ eval(vTaxableHazard) + eval(vTaxableOT) + eval(vSupAmtA) 
		+ eval(vSupAmtB);	

	document.form_.present_taxable.value = eval(vTaxableTotal);	
	document.form_.present_taxable_.value = eval(vTaxableTotal);	
	computeGross();	
//	document.form_.non_taxable.value = truncateFloat(document.form_.non_taxable.value,1,false);	
} 

function computeGross(){
	var vTaxable = document.form_.present_taxable.value;
	var vNonTaxable = document.form_.non_taxable.value;
	
	if(vTaxable.length == 0)
		vTaxable = "0";
	
	if(vNonTaxable.length == 0)
		vNonTaxable = "0";

	document.form_.gross_income.value = eval(vNonTaxable)+ eval(vTaxable);
	computeGrossTaxable();
}

function computeGrossTaxable(){
	var vPreviousTaxable = document.form_.prev_taxable.value;
	var vPresentTaxable = document.form_.present_taxable.value;
	
	if(vPreviousTaxable.length == 0)
		vPreviousTaxable = "0";
	
	if(vPresentTaxable.length == 0)
		vPresentTaxable = "0";
		
	document.form_.gross_taxable.value = eval(vPreviousTaxable)+ eval(vPresentTaxable);
	computeNetTaxable();
}

function computeNetTaxable(){
	var vGross = document.form_.gross_taxable.value;
	var vExemption = document.form_.tot_exemption.value;
	var vHealthPrem = document.form_.health_premium.value;
	var vNet = "0";
	
	if(vGross.length == 0)
		vGross = "0";
	
	if(vExemption.length == 0)
		vExemption = "0";

	if(vHealthPrem.length == 0)
		vHealthPrem = "0";

	vNet = eval(vGross) - (eval(vExemption) + eval(vHealthPrem));
	if(vNet < 0)
		vNet = "0";
	document.form_.net_taxable.value = vNet;
 	//ajaxComputeTax();
}

function computeWithheld(){
	var vJanToNov = document.form_.jan_to_nov.value;
	var vDecWithheld = document.form_.dec_withheld.value;
	var vTaxRefund = document.form_.tax_refund.value;
 	var vTotal = "0";
	
	if(vJanToNov.length == 0)
		vJanToNov = "0";
	
	if(vDecWithheld.length == 0)
		vDecWithheld = "0";

	if(vTaxRefund.length == 0)
		vTaxRefund = "0";

	vTotal = eval(vJanToNov) + eval(vDecWithheld) - eval(vTaxRefund);
	document.form_.total_withheld.value = vTotal;
}

function focusID(){
	document.form_.emp_id.focus();
}

function initialize_values(){
	computeGross();
	computeWithheld();
}

function ToggleFields(bolIsMWE){
	var vIsMWE = document.form_.is_mwe.checked;
	if(!vIsMWE){
		if(bolIsMWE)
			vIsMWE = true;
	}
 
 	if(vIsMWE){
		document.form_.basic_sal_ntax.disabled = false;
		document.form_.holiday_pay.disabled = false;
		document.form_.ot_non_taxable.disabled = false;
		document.form_.np_pay.disabled = false;
		document.form_.hazard_non_tax.disabled = false;	
	}else{
		document.form_.basic_sal_ntax.disabled = true;
		document.form_.holiday_pay.disabled = true;
		document.form_.ot_non_taxable.disabled = true;
		document.form_.np_pay.disabled = true;
		document.form_.hazard_non_tax.disabled = true;		
	}
	
}
-->
</script>

<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	boolean bolSingle = true;
//add security here.
if (WI.fillTextValue("print_pg").length() > 0){ 	
%>
	<jsp:forward page="./form_2316_print.jsp"/>
<% return;}


try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions","emp_prev_salary.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"emp_prev_salary.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

	PRTaxReport prEmpInfo = new PRTaxReport();
	Vector vEmpInfo = null;
	Vector vEditInfo = null;
	Vector vDepInfo = null;
	Vector vEmployer  = null;
	Vector vPrevEmployer = null;
	String strEmpID = null;
	String strPageAction = WI.fillTextValue("page_action");
	double dTemp = 0d;
	boolean bolIsMWE = false;
	String[] astrExemptionName    = {"Zero(No Exemption)", "Single","Head of Family", "Head of Family 1 Dependent (HF1)", 
																	"Head of Family 2 Dependents (HF2)","Head of Family 3 Dependents (HF3)", 
																	"Head of Family 4 Dependents (HF4)", "Married Employed", 																	 
																	 "Married Employed 1 Dependent (ME1)", "Married Employed 2 Dependents (ME2)",
																	 "Married Employed 3 Dependents (ME3)", "Married Employed 4 Dependents (ME4)"};
	String[] astrExemptionVal     = {"0","1","2","21","22","23","24","3","31","32","33","34"};
	
	if(strPageAction.length() > 0){
		if(prEmpInfo.operateOnEmployee2316(dbOP, request, Integer.parseInt(strPageAction)) == null)
			strErrMsg = prEmpInfo.getErrMsg();
		else
			strErrMsg = "Operation successful";
	}
	 	
	vEmpInfo = prEmpInfo.getPersonalTaxInfo(dbOP, request, null);
	if(vEmpInfo == null)
		strErrMsg = prEmpInfo.getErrMsg();
	else{
		vDepInfo = (Vector)vEmpInfo.elementAt(9);
		vEmployer = (Vector)vEmpInfo.elementAt(10);
		vEditInfo = prEmpInfo.operateOnEmployee2316(dbOP, request, 4);
		vPrevEmployer = prEmpInfo.getPreviousEmployerInfo(dbOP, request, null, WI.fillTextValue("year_of"));
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(14);
			if(strTemp.equals("1"))
				bolIsMWE = true;
		}
  }
%>
<body onLoad="focusID();initialize_values();ToggleFields(<%=bolIsMWE%>);">
<form name="form_" action="./form_2316.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF"  size="2"><strong>::::
			PAYROLL:  FORM 2316 ENCODING ::::</strong></font></td>
		</tr>
	</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="3">&nbsp;<font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="19%">Employee ID</td>
			<%
				strEmpID = WI.fillTextValue("emp_id");
			%>
      <td><input name="emp_id" type="text" size="16" value="<%=strEmpID%>" class="textbox" onKeyUp="AjaxMapName(1);"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <div style="position:absolute; overflow:auto; width:300px;">
				<label id="coa_info"></label>
				</div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td><select name="year_of" onChange="ReloadPage();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"), 2, 1)%>
      </select></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td><!--<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a>-->
			<font size="1">
<input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">			
Click to reload page.</font></td>
    </tr>
    <tr>
      <td height="10" colspan="3"><hr size="1" color="#0000FF"></td>
    </tr>
  </table>

<font face="arial" style="font-size: 8pt"><b>DLN:</b></font>
<img src="images/arrow_white_bg.jpg" />
<table width="100%" height="70" border=2 cellpadding="0" cellspacing="0">
<tr>
	<td colspan="2">
	<table border="0" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="9%" align="center"><img src="images/2316_logo.jpg" width="57" height="52"/></td>
		<td width="19%">	
			Republika ng Pilipinas<br/>
			Kagawaran ng Pananalapi<br/>
		  Kawanihan ng Rentas Internas</td>
		<td width="53%" align="center">
		<font size="5">
		Certificate of Compensation<br/>
		Payment/Tax Withheld		</font>		</td>
		<td width="19%">
		BIR Form No.<br/>
		<font size="7"><b>2316</b></font><br/>		</td>
	</tr>
	<tr>
		<td colspan="3"><font size="1">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;For Compensation Payment With or Without Tax Withheld</font></td>
		<td>
			July 2008 (ENCS)		</td>
	</tr>
	</table>	</td>
</tr>
<tr>
	<td colspan="2">
		Fill in all applicable spaces. Mark all appropriate boxes with an "X"</td>
</tr>
<tr>
	<td bgcolor="#999999" width="50%">
	<table width="41%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="78%">
		1 For the Year<br/>
		&nbsp;&nbsp;&nbsp;&nbsp;(YYYY)		</td>
		<td width="7%">
		<img src="images/arrow.jpg" width="6" height="7" />		</td>
	  <td width="15%" ><input type="text" maxlength="4" size="3" style="font-size:14px;" 
					name="year_" onFocus="style.backgroundColor='#D3EBFF'" readonly
				  value="<%=WI.fillTextValue("year_of")%>" onBlur="style.backgroundColor='white'"></td>
	</tr>
	</table></td>
	<td width="50%" bgcolor="#999999">
		<table width="94%" border="0" cellpadding="0" cellspacing="0">
		<tr>
		<td width="33%">
		2 For the Period<br/>
		&nbsp;&nbsp;&nbsp;&nbsp;<img src="images/arrow.jpg" width="6" height="7" /> From &nbsp;&nbsp;&nbsp;&nbsp;(MM/DD)		</td>
		<td width="20%" align="center">
				<img src="images/box_4_mid_cols.jpg" width="62" height="23" />		</td>
		<td valign="bottom" align="right" width="27%">
		To&nbsp;&nbsp;&nbsp;(MM/DD)		</td>
		<td width="20%" align="center">
			<img src="images/box_4_mid_cols.jpg" width="62" height="23" />		</td>
		</tr>
		</table>	</td>
</tr>
<tr>
	<td>
		<b>Part I &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Employee Information</b>	</td>
	<td nowrap="nowrap">
		<b>Part IV-B <font style="font-size:7px;font-family:Verdana, Arial, Helvetica, sans-serif">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Details of Compensation Income and Tax Withheld from Present Employer</font></b></td>
</tr>
<tr valign="top" bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="29%">
		3 Taxpayer<br/>
		&nbsp;&nbsp;&nbsp;Identification No.		</td>
		<td width="7%"><img src="images/arrow.jpg" width="6" height="7" /></td>
		<%
			if(vEmpInfo != null && vEmpInfo.size() > 0){
				strTemp = (String)vEmpInfo.elementAt(1);
			}else{
				strTemp = "";
			}
		%>
		<td width="64%">
		<input name="tin" type= "text" class="textbox"  value="<%=WI.getStrValue(strTemp)%>" 
		onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyIntegerExtn('form_','tin', '-')"
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','tin', '-');" size="16"></td>
	</tr>
	</table>	</td>
	<td rowspan="20">
 	<table width="91%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="16"></td>
			<td></td>
			<td></td>
			<td align="center">Amount</td>
		</tr>
		<tr>
			<td height="29"><b>A</b></td>
			<td colspan="3"><b>NON-TAXABLE/EXEMPT COMPENSATION INCOME</b></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="39">32</td>
			<td width="47%">
			Basic Salary/<br/>
		    Statutory Minimun Wage<br/>
			Minimun Wage Earner (MWE)</td>
			<td width="7%" align="right">32</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(31);
				}else{
					strTemp = WI.fillTextValue("basic_sal_ntax");
				}
			%>				
			<td width="42%" align="right">
			<input name="basic_sal_ntax" type="text" size="20" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeyUp="computeNonTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="32">33</td>
			<td width="47%">
			Holiday Pay (MWE)</td>
			<td width="7%" align="right">33</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(32);
				}else{
					strTemp = WI.fillTextValue("holiday_pay");
				}
			%>	
			<td width="42%" align="right">
			<input name="holiday_pay" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeNonTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="32">34</td>
			<td width="47%">
			Overtime Pay (MWE)</td>
			<td width="7%" align="right">34</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(33);
				}else{
					strTemp = WI.fillTextValue("ot_non_taxable");
				}
			%>	
			<td width="42%" align="right"><input name="ot_non_taxable" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeNonTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="34">35</td>
			<td width="47%">
			Night Shift Differential (MWE)</td>
			<td width="7%" align="right">35</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(34);
				}else{
					strTemp = WI.fillTextValue("np_pay");
				}
			%>	
			<td width="42%" align="right"><input name="np_pay" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeNonTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="33">36</td>
			<td width="47%">
			Hazard Pay (MWE)</td>
			<td width="7%" align="right">36</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(35);
				}else{
					strTemp = WI.fillTextValue("hazard_non_tax");
				}
			%>	
			<td width="42%" align="right"><input name="hazard_non_tax" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeNonTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="33">37</td>
			<td width="47%">
			13th Month Pay<br/>
			and Other Benefits</td>
			<td width="7%" align="right">37</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(36);
				}else{
					strTemp = WI.fillTextValue("bonus_non_tax");
				}
			%>	
			<td width="42%" align="right"><input name="bonus_non_tax" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeNonTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="33">38</td>
			<td width="47%">
			De Minimis Benefits</td>
			<td width="7%" align="right">38</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(37);
				}else{
					strTemp = WI.fillTextValue("de_minimis");
				}
			%>				
			<td width="42%" align="right"><input name="de_minimis" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeNonTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%">39</td>
			<td width="47%">
			SSS, GSIS, PHIC & Pag-ibig<br/>
			Contributions, & Union Dues<br/>
			<sup><i>(Employee share only)</i></sup></td>
			<td width="7%" align="right">39</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(38);
				}else{
					strTemp = WI.fillTextValue("contributions");
				}
			%>				
			<td width="42%" align="right"><input name="contributions" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"1
		onKeyUp="computeNonTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="41">40</td>
			<td width="47%">
			Salaries & Other Forms of<br/>
			compensation</td>
			<td width="7%" align="right">40</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(39);
				}else{
					strTemp = WI.fillTextValue("other_comp");
				}
			%>	
			<td width="42%" align="right"><input name="other_comp" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeNonTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="41">41</td>
			<td width="47%">
			Total Non-Taxable/Exempt<br/>
			Compensation Income</td>
			<td width="7%" align="right">41</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(20);
			}else{
				strTemp = WI.fillTextValue("non_taxable");
			}		
		%>
			<td width="42%" align="right"><input name="non_taxable" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly
		style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td height="38"><b>B</b></td>
			<td colspan="3"><b>TAXABLE COMPENSATION INCOME<br />REGULAR</b></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="34">42</td>
			<td width="47%">
			Basic Salary</td>
			<td width="7%" align="right">42</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(40);
				}else{
					strTemp = WI.fillTextValue("basic_taxable");
				}
			%>	
			<td width="42%" align="right"><input name="basic_taxable" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeTaxableTotal();" style="text-align:right;" ></td>
		</tr>		
		<tr valign="top">
			<td width="4%" height="40">43</td>
			<td width="47%">
			Representation</td>
			<td width="7%" align="right">43</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(41);
				}else{
					strTemp = WI.fillTextValue("representation");
				}
			%>	
			<td width="42%" align="right"><input name="representation" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeTaxableTotal();" style="text-align:right;" ></td>
		</tr>		
		<tr valign="top">
			<td width="4%" height="40">44</td>
			<td width="47%">
			Transportation</td>
			<td width="7%" align="right">44</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(42);
				}else{
					strTemp = WI.fillTextValue("transportation");
				}
			%>	
			<td width="42%" align="right"><input name="transportation" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="33">45</td>
			<td width="47%">
			Cost of Living Allowance</td>
			<td width="7%" align="right">45</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(43);
				}else{
					strTemp = WI.fillTextValue("cola");
				}
			%>	
			<td width="42%" align="right"><input name="cola" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="34">46</td>
			<td width="47%">Fixed Housing Allowance</td>
			<td width="7%" align="right">46</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(44);
				}else{
					strTemp = WI.fillTextValue("housing_allow");
				}
			%>	
			<td width="42%" align="right"><input name="housing_allow" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td><b>47</b></td>
			<td colspan="3">Others (Specify)</td>
		</tr>
		<tr valign="top">
			<td width="4%" height="34">47A</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(45);
				}else{
					strTemp = WI.fillTextValue("regular_desc_a");
				}
			%>	
			<td width="47%"><input name="regular_desc_a" type="text" size="20" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td width="7%" align="right">47A</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(46);
				}else{
					strTemp = WI.fillTextValue("regular_amt_a");
				}
			%>	
			<td width="42%" align="right"><input name="regular_amt_a" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="33">47B</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(47);
				}else{
					strTemp = WI.fillTextValue("regular_desc_b");
				}
			%>	
			<td width="47%"><input name="regular_desc_b" type="text" size="20" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td width="7%" align="right">47B</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(48);
				}else{
					strTemp = WI.fillTextValue("regular_amt_b");
				}
			%>	
			<td width="42%" align="right"><input name="regular_amt_b" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="33">48</td>
			<td width="47%">
			Commission</td>
			<td width="7%" align="right">48</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(49);
				}else{
					strTemp = WI.fillTextValue("commission");
				}
			%>	
			<td width="42%" align="right"><input name="commission" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="35">49</td>
			<td width="47%">
			Profit Sharing</td>
			<td width="7%" align="right">49</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(50);
				}else{
					strTemp = WI.fillTextValue("profit_share");
				}
			%>			
			<td width="42%" align="right"><input name="profit_share" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="33">50</td>
			<td width="47%">
			Fees Including Director's<br/>Fees</td>
			<td width="7%" align="right">50</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(51);
				}else{
					strTemp = WI.fillTextValue("fees");
				}
			%>	
			<td width="42%" align="right"><input name="fees" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="33">51</td>
			<td width="47%">
			Taxable 13th Month Pay<br/>and Other Benefits</td>
			<td width="7%" align="right">51</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(52);
				}else{
					strTemp = WI.fillTextValue("bonus_taxable");
				}
			%>	
			<td width="42%" align="right"><input name="bonus_taxable" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="33">52</td>
			<td width="47%">
			Hazard Pay</td>
			<td width="7%" align="right">52</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(53);
				}else{
					strTemp = WI.fillTextValue("hazard_taxable");
				}
			%>	
			<td width="42%" align="right"><input name="hazard_taxable" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%">53</td>
			<td width="47%">
			Overtime Pay</td>
			<td width="7%" align="right">53</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(54);
				}else{
					strTemp = WI.fillTextValue("ot_taxable");
				}
			%>	
			<td width="42%" align="right"><input name="ot_taxable" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
		  <td height="15">&nbsp;</td>
		  <td colspan="3"><strong>SUPPLEMENTARY</strong></td>
		  </tr>
		<tr valign="top">
			<td height="15"><b>54</b></td>
			<td colspan="3">Others (Specify)</td>
		</tr>
		<tr valign="top">
			<td width="4%" height="33">54A</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(55);
				}else{
					strTemp = WI.fillTextValue("sup_desc_a");
				}
			%>	
			<td width="47%"><input name="sup_desc_a" type="text" size="20" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td width="7%" align="right">54A</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(56);
				}else{
					strTemp = WI.fillTextValue("sup_amt_a");
				}
			%>	
			<td width="42%" align="right"><input name="sup_amt_a" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="34">54B</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(57);
				}else{
					strTemp = WI.fillTextValue("sup_desc_b");
				}
			%>
			<td width="47%"><input name="sup_desc_b" type="text" size="20" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td width="7%" align="right">54B</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(58);
				}else{
					strTemp = WI.fillTextValue("sup_amt_b");
				}
			%>
			<td width="42%" align="right"><input name="sup_amt_b" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeTaxableTotal();" style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="4%">55</td>
			<td width="47%">
			Total Taxable Compensation<br/>Income</td>
			<td width="7%" align="right">55</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(21);
			}else{
				strTemp = WI.fillTextValue("present_taxable");
			}		
		%>			
			<td width="42%" align="right">
			<input name="present_taxable" type="text" size="20" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			style="text-align:right;" readonly></td>
		</tr>
	</table>	
	
 </td>
</tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="82%">4 Employee's Name (Last Name, First Name, Middle Name)</td>
		<td width="18%">5 RDO Code</td>
	</tr>
	<tr>
		<%
			if(vEmpInfo != null && vEmpInfo.size() > 0){
				strTemp = WI.formatName((String)vEmpInfo.elementAt(2), (String)vEmpInfo.elementAt(3), (String)vEmpInfo.elementAt(4), 5);
				//for(int o = 1; o < 12; o++)
				//	System.out.println("o - " + WI.formatName((String)vEmpInfo.elementAt(2), (String)vEmpInfo.elementAt(3), (String)vEmpInfo.elementAt(4), o));
			}else{
				strTemp = "";
			}
		%>
		<td>
		<img src="images/arrow.jpg" width="6" height="7" />
		<input name="emp_name" type= "text" class="textbox_noborder"  value="<%=strTemp%>" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		size="50" style="font-size:9px;"></td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(4);
			} else {
				strTemp = WI.fillTextValue("rdo_code");
			}
		%>
		<td align="right"><input name="rdo_code" type= "text" class="textbox"  
		value="<%=strTemp%>" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  size="5" maxlength="4"></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="81%">6 Registered Address</td>
		<td width="19%">6A Zip Code</td>
	</tr>
	<tr>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(5);
			}else{
				if(vEmpInfo != null && vEmpInfo.size() > 0){
					strTemp = (String)vEmpInfo.elementAt(7);
				}else{
					strTemp = WI.fillTextValue("reg_address");
				}
			}
		%>
		<td>
		<img src="images/arrow.jpg" width="6" height="7" />
		<input name="reg_address" type= "text" class="textbox"  value="<%=strTemp%>" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		size="50" style="font-size:9px;"></td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(6);
			}else{
				strTemp = WI.fillTextValue("reg_zip");
			}
		%>
		<td align="right"><input name="reg_zip" type= "text" class="textbox"  
		value="<%=strTemp%>" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  size="5"></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="81%">6B Local Home Address</td>
		<td width="19%">6C Zip Code</td>
	</tr>
	<tr>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(7);
			}else{
				if(vEmpInfo != null && vEmpInfo.size() > 0){
					strTemp = (String)vEmpInfo.elementAt(7);
				}else{
					strTemp = WI.fillTextValue("local_address");
				}
			}
		%>
		<td>
		<img src="images/arrow.jpg" width="6" height="7" />
		<input name="local_address" type= "text" class="textbox"  value="<%=WI.getStrValue(strTemp)%>" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  
		size="50" style="font-size:9px;"></td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(8);
			}else{
				strTemp = WI.fillTextValue("local_zip");
			}
		%>			
		<td align="right"><input name="local_zip" type= "text" class="textbox"  
		value="<%=WI.getStrValue(strTemp)%>" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  size="5"></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="81%">6D Foreign Address</td>
		<td width="19%">6E Zip Code</td>
	</tr>
	<tr>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(9);
			}else{
				strTemp = WI.fillTextValue("foreign_add");
			}
		%>
		<td>
		<img src="images/arrow.jpg" width="6" height="7" />
		<input name="foreign_add" type= "text" class="textbox"  value="<%=WI.getStrValue(strTemp)%>" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  
		size="50" style="font-size:9px;"></td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(10);
			}else{
				strTemp = WI.fillTextValue("foreign_zip");
			}
		%>
		<td align="right"><input name="foreign_zip" type= "text" class="textbox"  
		value="<%=WI.getStrValue(strTemp)%>" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  size="5"></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
		<%
			if(vEmpInfo != null && vEmpInfo.size() > 0){
				strTemp = (String)vEmpInfo.elementAt(5);
			}else{
				strTemp = "";
			}
		%>
	<td>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="52%">7 Date of Birth (MM/DD/YYYY)<br/>
	&nbsp;&nbsp;&nbsp;
	<input name="dob" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="UpdateAge();style.backgroundColor='white'" onKeyUP="AllowOnlyIntegerExtn('staff_profile','dob','/');UpdateAge()">
	</td>
		<%
			if(vEmpInfo != null && vEmpInfo.size() > 0){
				strTemp = (String)vEmpInfo.elementAt(6);
			}else{
				strTemp = "";
			}
		%>
      <td width="48%">8 Telephone Number<br/>
	&nbsp;&nbsp;&nbsp;
	<input name="tel_no" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
  </table></td>
    </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td>9 Exemption Status</td>
	</tr>
	<tr> 
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(67);
				} else {			
					if (vEmpInfo != null && vEmpInfo.size() > 0){
						strTemp = (String)vEmpInfo.elementAt(8);
					}else{
						strTemp = WI.fillTextValue("tax_status");
					}	
				}
 			%>	
		<td><select name="tax_status">
      <option value="0">Zero (Z)</option>
      <%for( int i =1; i <= 11; ++i ){
				if(astrExemptionVal[i].equals(strTemp)){%>
      <option selected value="<%=astrExemptionVal[i]%>"><%=astrExemptionName[i]%></option>
      <%}else{%>
      <option value="<%=astrExemptionVal[i]%>"> <%=astrExemptionName[i]%></option>
      <%}
			}%>
    </select></td>
		<%if(bolSingle){ 
			strTemp = "<img src='images/status_box.jpg' width='27' height='15' />";
		}else{
			strTemp = "<img src='images/x_status_box.jpg' width='27' height='15' />";
		}%>		
		</tr>
	<tr>
		<td nowrap="nowrap">9A Is the wife claiming the additional exemption for quilified dependent children?</td>
	</tr>
	<tr>
	  <td align="right"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0){
						strTemp = (String)vEditInfo.elementAt(11);
					}else{
						strTemp = WI.fillTextValue("is_wife_claim");
					}				
					
					strTemp = WI.fillTextValue("is_wife_claim");
					if(strTemp.equals("1"))
						strTemp = "checked";
					else
						strTemp = "";					
				%>
        <td width="34%" align="right"><input type="radio" name="is_wife_claim" value="1" <%=strTemp%>></td>
        <td width="25%">Yes</td>
				<%
					if(strTemp.length() == 0)
						strTemp = "checked";
					else
						strTemp = "";	
				%>
        <td width="8%" align="right"><input type="radio" name="is_wife_claim" value="0" <%=strTemp%>></td>
        <td width="33%">No</td>
      </tr>
    </table></td>
	  </tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="71%">10 Name of Qualified Dependent Children</td>
			<td width="29%">11 Date of Birth (MM/DD/YYYY)</td>
		</tr>
		<tr>
			<td align="right">
				<%
				if(vDepInfo != null && vDepInfo.size() > 0)
					strTemp = WI.formatName((String)vDepInfo.elementAt(0), (String)vDepInfo.elementAt(1), (String)vDepInfo.elementAt(2), 5);
				else
					strTemp = "";
				%>
			<input name="dep_1" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" height="18">
			  <br>
				<%
				if(vDepInfo != null && vDepInfo.size() > 4)
					strTemp = WI.formatName((String)vDepInfo.elementAt(4), (String)vDepInfo.elementAt(5), (String)vDepInfo.elementAt(6), 5);
				else
					strTemp = "";					
				%>
			  <input name="dep_2" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" height="18">
			  <br>
				<%
				if(vDepInfo != null && vDepInfo.size() > 8)
					strTemp = WI.formatName((String)vDepInfo.elementAt(8), (String)vDepInfo.elementAt(9), (String)vDepInfo.elementAt(10), 5);
				else
					strTemp = "";					
				%>				
			  <input name="dep_3" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" height="18">
        <br>
				<%
				if(vDepInfo != null && vDepInfo.size() > 12)
					strTemp = WI.formatName((String)vDepInfo.elementAt(12), (String)vDepInfo.elementAt(13), (String)vDepInfo.elementAt(14), 5);
				else
					strTemp = "";					
				%>
        <input name="dep_4" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" height="18">			</td>			
			<td align="center">
			<%
			if(vDepInfo != null && vDepInfo.size() > 0)
				strTemp = (String)vDepInfo.elementAt(3);
			else
				strTemp = "";
			%>
			<input name="bday_1" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<br>
			<%
			if(vDepInfo != null && vDepInfo.size() > 4)
				strTemp = (String)vDepInfo.elementAt(7);
			else
				strTemp = "";
			%>
			<input name="bday_2" type="text" size="10" maxlength="10" readonly value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			  <br>
			  <%
			if(vDepInfo != null && vDepInfo.size() > 8)
				strTemp = (String)vDepInfo.elementAt(11);
			else
				strTemp = "";
			%>
			  <input name="bday_3" type="text" size="10" maxlength="10" readonly value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			  <br>
			  <%
			if(vDepInfo != null && vDepInfo.size() > 12)
				strTemp = (String)vDepInfo.elementAt(15);
			else
				strTemp = "";
			%>
			  <input name="bday_4" type="text" size="10" maxlength="10" readonly value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.imp_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"></a></td>
		</tr>
	  </table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr valign="top">
			<td width="56%" height="25">12 Statutory Minimun Wage rate per day</td>
			<td width="3%">12</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(12);
				} else {
					strTemp = WI.fillTextValue("min_wage_day");
				}
				strTemp = CommonUtil.formatFloat(strTemp, true);
				strTemp = ConversionTable.replaceString(strTemp, ",", "");
			%>
			<td width="41%">
			<input name="min_wage_day" type="text" size="12" maxlength="12" value="<%=strTemp%>" 			
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			class="textbox" style="text-align:right"></td>
		</tr>
		<tr valign="top">
			<td width="56%">13 Statutory Minimun Wage rate per month</td>
			<td width="3%">13</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(13);
				}else{
					strTemp = WI.fillTextValue("min_wage_month");
				}
				strTemp = CommonUtil.formatFloat(strTemp, true);
				strTemp = ConversionTable.replaceString(strTemp, ",", "");				
			%>			
			<td width="41%">
			<input name="min_wage_month" type="text" size="12" maxlength="12" value="<%=strTemp%>"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			class="textbox" style="text-align:right"></td>
		</tr>
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr valign="top">
			<td width="3%">14</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(14);
				}else{
					strTemp = WI.fillTextValue("is_mwe");
				}
 				if(strTemp.equals("1"))
					strTemp = "checked";
				else
					strTemp = "";
			%>
			<td width="7%"><input type="checkbox" name="is_mwe" value="1" <%=strTemp%> onClick="ToggleFields();computeNonTaxableTotal();"></td>
			<td width="90%">Minimun Wage Earner whose compensation is exempt from<br/>
		  withholding tax and not subject to income tax</td>
		</tr>
	  </table>	</td>
  </tr>
<tr>
	<td>
	<b>Part II &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Employer Information (Present)</b>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="27%">
		15 Taxpayer<br/>
		&nbsp;&nbsp;&nbsp;Identification No.		</td>
		<%
			if(vEmployer != null && vEmployer.size() > 0){
				strTemp = (String)vEmployer.elementAt(7);
			}else{
				strTemp = "";
			}
		%>
		<td width="73%">&nbsp;
		<img src="images/arrow.jpg" width="6" height="7" />
		<input name="tin4" type= "text" class="textbox"  value="<%=WI.getStrValue(strTemp)%>" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  
		size="16" readonly>		</td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="100%">16 Employer's Name</td>
	</tr>
	<tr>
		<%
			if(vEmployer != null && vEmployer.size() > 0){
				strTemp = (String)vEmployer.elementAt(1);
			}else{
				strTemp = "";
			}
		%>
		<td>
		<img src="images/arrow.jpg" width="6" height="7" />
		<input name="tin5" type= "text" class="textbox"  value="<%=WI.getStrValue(strTemp)%>" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		size="50" style="font-size:9px;"></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="83%">17 Registered Address</td>
		<td width="17%">17A Zip Code</td>
	</tr>
	<tr>
		<%
			if(vEmployer != null && vEmployer.size() > 0){
				strTemp = (String)vEmployer.elementAt(2);
			}else{
				strTemp = "";
			}
		%>
		<td>
		<img src="images/arrow.jpg" width="6" height="7" />
		<input name="tin6" type= "text" class="textbox"  value="<%=WI.getStrValue(strTemp)%>" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  
		size="50" style="font-size:9px;"></td>
		<%
			if(vEmployer != null && vEmployer.size() > 0){
				strTemp = (String)vEmployer.elementAt(3);
			}else{
				strTemp = "";
			}
		%>
		<td><input name="tin342" type= "text" class="textbox"  
		value="<%=WI.getStrValue(strTemp)%>" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  size="5" maxlength="4"></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				} else {
					strTemp = WI.fillTextValue("is_main_emp");
				}
				
					strTemp = WI.getStrValue(strTemp, "1");
					if(strTemp.equals("1"))
						strTemp = "checked";
					else
						strTemp = "";					
				%>
        <td width="24%" align="right"><input type="radio" name="is_main_emp" value="1" <%=strTemp%>></td>
        <td width="25%">Main Employer</td>
        <%
					if(strTemp.length() == 0)
						strTemp = "checked";
					else
						strTemp = "";	
				%>
        <td width="6%" align="right"><input type="radio" name="is_main_emp" value="0" <%=strTemp%>></td>
        <td width="45%">Secondary Employer</td>
      </tr>
    </table></td>
  </tr>
<tr>
	<td>
	<b>Part III &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Employer Information (Previous)</b>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="43%">
		18 Taxpayer<br/>
		&nbsp;&nbsp;&nbsp;Identification No.		</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(15);
			}else{
				strTemp = WI.fillTextValue("prev_emp_tin");
			}		
		%>
		<td width="57%">&nbsp;
		<img src="images/arrow.jpg" width="6" height="7" />
		<input name="prev_emp_tin" type= "text" class="textbox"  value="<%=WI.getStrValue(strTemp)%>"
		onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyIntegerExtn('form_','prev_emp_tin', '-')"
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','prev_emp_tin', '-');" size="16"></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="100%">19 Employer's Name</td>
	</tr>
	<tr>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(16);
			}else{
				if(vPrevEmployer != null && vPrevEmployer.size() > 0)
					strTemp = (String)vPrevEmployer.elementAt(0);
				else
					strTemp = WI.fillTextValue("prev_emp_name");
			}		
		%>
		<td>
		<img src="images/arrow.jpg" width="6" height="7" />
		<input name="prev_emp_name" type= "text" class="textbox"  value="<%=WI.getStrValue(strTemp)%>"
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		size="50" style="font-size:9px;"></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="83%">20 Registered Address</td>
		<td width="17%">20A Zip Code</td>
	</tr>
	<tr>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(17);
			}else{
				if(vPrevEmployer != null && vPrevEmployer.size() > 0)
					strTemp = (String)vPrevEmployer.elementAt(1);
				else		
					strTemp = WI.fillTextValue("prev_emp_addr");
			}		
		%>
		<td>
		<img src="images/arrow.jpg" width="6" height="7" />
		<input name="prev_emp_addr" type= "text" class="textbox"  value="<%=WI.getStrValue(strTemp)%>" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		size="50" style="font-size:9px;"></td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(18);
			}else{
				strTemp = WI.fillTextValue("prev_emp_zip");
			}		
		%>
		<td><input name="prev_emp_zip" type= "text" class="textbox"
		value="<%=WI.getStrValue(strTemp)%>" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  size="5" maxlength="4"></td>
	</tr>
	</table>	</td>
  </tr>
<tr>
	<td>
	<b>Part IV-A 				
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	Summary</b>	</td>
  </tr>
<tr bgcolor="#999999" valign="top">
	<td>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" cllspacing="0">
		<tr valign="top">
			<td width="3%">21</td>
			<td width="53%">Gross Compensation Income from<br/>
		  <font style="font-size:9px;">Present Employer (Item 41 plus Item 55)</font></td>
			<td width="6%">21</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(19);
			}else{
				strTemp = WI.fillTextValue("gross_income");
			}		
		%>
			<td width="38%" align="right">
			<input name="gross_income" type="text" size="18" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly
			style="text-align:right;"></td>
		</tr>
		<tr valign="top">
			<td width="3%">22</td>
			<td width="53%"><font size="1"><b>Less: Total Non-Taxable</b><br/>
		  	Exempt (Item 41)</font></td>
			<td width="6%">22</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(20);
			}else{
				strTemp = WI.fillTextValue("non_taxable_");
			}		
		%>
			<td width="38%" align="right"><input name="non_taxable_" type="text" size="18" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly
		style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="3%">23</td>
			<td width="53%"><font size="1"><b>Taxable Compensation Income</b><br/>
		  	from Present Employer (Item 55)</font></td>
			<td width="6%">23</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(21);
			}else{
				strTemp = WI.fillTextValue("present_taxable_");
			}		
		%>
			<td width="38%" align="right">
			<input name="present_taxable_" type="text" size="18" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly
			style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="3%">24</td>
			<td width="53%"><font size="1"><b>Add: Taxable Compensation<br/>
		  	Income from Previous Exmployer</font></td>
			<td width="6%">24</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(22);
			}else{
				if(vPrevEmployer != null && vPrevEmployer.size() > 2){
					strTemp = (String)vPrevEmployer.elementAt(5);
					dTemp = Double.parseDouble(strTemp);

					strTemp = (String)vPrevEmployer.elementAt(6);
					dTemp += Double.parseDouble(strTemp);

					strTemp = (String)vPrevEmployer.elementAt(8);
					dTemp += Double.parseDouble(strTemp);
					strTemp = CommonUtil.formatFloat(dTemp, 2);
				}else
					strTemp = WI.fillTextValue("prev_taxable");
			}		
		%>
			<td width="38%" align="right">
		<input name="prev_taxable" type="text" size="18" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyIntegerExtn('form_','prev_taxable', '.');computeGrossTaxable();"
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','prev_taxable', '.');"
		style="text-align:right;" readonly></td>
		</tr>
		<tr valign="top">
			<td width="3%">25</td>
			<td width="53%"><font size="1"><b>Gross Taxable<br/>
		  	Compensation Income</font></td>
			<td width="6%">25</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(23);
			}else{
				strTemp = WI.fillTextValue("gross_taxable");
			}		
		%>
			<td width="38%" align="right"><input name="gross_taxable" type="text" size="18" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		style="text-align:right;" readonly></td>
		</tr>
		<tr valign="top">
			<td width="3%">26</td>
			<td width="53%"><font size="1"><b>Less: Total Exemptions</b></font></td>
			<td width="6%">26</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(24);
				}else{
					if(vEmpInfo != null && vEmpInfo.size() > 0)
						strTemp = (String)vEmpInfo.elementAt(11);
					else
						strTemp = WI.fillTextValue("tot_exemption");
 				}		
			%>
			<td width="38%" align="right"><input name="tot_exemption" type="text" size="18" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		style="text-align:right;" onKeyUp="computeNetTaxable('1');"></td>
		</tr>
		<tr valign="top">
			<td width="3%">27</td>
			<td width="53%"><b>Less: Premium Paid on Health</b><br/>
		  	<font style="font-size:9px">and/or Hospital Insurance (if applicable)</font></td>
			<td width="6%">27</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(25);
				}else{
					strTemp = WI.fillTextValue("health_premium");
				}		
			%>
			<td width="38%" align="right"><input name="health_premium" type="text" size="18" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		style="text-align:right;" onKeyUp="computeNetTaxable('1');" ></td>
		</tr>
		<tr valign="top">
			<td width="3%">28</td>
			<td width="53%"><font size="1"><b>Net Taxable</b><br/>
		  	Compensation Income</font></td>
			<td width="6%">28</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(26);
			}else{
				strTemp = WI.fillTextValue("net_taxable");
			}		
		%>			
			<td width="38%" align="right"><input name="net_taxable" type="text" size="18" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		style="text-align:right;" readonly></td>
		</tr>
		<tr valign="top">
			<td width="3%">29</td>
			<td width="53%"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="53%"><font size="1"><b>Tax Due</b></font></td>
            <td width="47%"><a href="javascript:ajaxComputeTax();">Recompute Tax Due</a></td>
          </tr>
        </table></td>
			<td width="6%">29</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(27);
			}else{
				strTemp = WI.fillTextValue("tax_due");
			}		
			System.out.println(" strTemp " + strTemp);
		%>			
		
			<td width="38%" align="right"><input name="tax_due" type="text" size="18" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		style="text-align:right;" ></td>
		</tr>
		<tr valign="top">
			<td width="3%">30</td>
			<td colspan="3"><font size="1">
			  <b>Amount of Taxes Withheld</b></font>			  </td>
		</tr>
		<tr valign="top">
			<td width="3%"></td>
			<td width="53%"><font size="1"><b>30A Present Employer</b></font></td>
			<td width="6%">30A</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(28);
			}else{
				if(vEmpInfo != null && vEmpInfo.size() > 0)
					strTemp = (String)vEmpInfo.elementAt(12);
				else
					strTemp = WI.fillTextValue("pres_withheld");
			}		
		%>
			<td width="38%" align="right"><input name="pres_withheld" type="text" size="18" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		style="text-align:right;"></td>
		</tr>
		<tr valign="top">
			<td width="3%"></td>
			<td width="53%"><font size="1"><b>30B Previous Employer</b></font></td>
			<td width="6%">30B</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(29);
			}else{
				if(vPrevEmployer != null && vPrevEmployer.size() > 2)
					strTemp = (String)vPrevEmployer.elementAt(7);
				else			
					strTemp = WI.fillTextValue("prev_withheld");
			}		
		%>
			<td width="38%" align="right"><input name="prev_withheld" type="text" size="18" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		style="text-align:right;"></td>
		</tr>
<tr valign="top">
		  <td></td>
		  <td>January - November</td>
		  <td align="right">&nbsp;</td>
		<% dTemp = 0d;
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(65);
			}else{
				if((vEmpInfo != null && vEmpInfo.size() > 0) || 
					(vPrevEmployer != null && vPrevEmployer.size() > 2)){
					
					if(vEmpInfo != null && vEmpInfo.size() > 0){
						strTemp = (String)vEmpInfo.elementAt(12);
						dTemp = Double.parseDouble(strTemp);
					}
					
					if(vPrevEmployer != null && vPrevEmployer.size() > 2){
						strTemp = (String)vPrevEmployer.elementAt(7);
						dTemp += Double.parseDouble(strTemp);
					}					
					strTemp = CommonUtil.formatFloat(dTemp, 2);			
				}else{
					strTemp = WI.fillTextValue("jan_to_nov");
				}
			}
		%>
			<td align="right"><input name="jan_to_nov" type="text" size="18" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyIntegerExtn('form_','jan_to_nov','.');computeWithheld();"
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','jan_to_nov','.');computeWithheld();" style="text-align:right;"></td>
		</tr>
		
		<tr valign="top">
		  <td></td>
		  <td>Amount w/held &amp; paid for in December </td>
		  <td>&nbsp;</td>
			<% dTemp = 0d;
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(66);
				}else{
					if(vEmpInfo != null && vEmpInfo.size() > 0){
						strTemp = (String)vEmpInfo.elementAt(13);
					}else{
						strTemp = WI.fillTextValue("jan_to_nov");
					}
				}
			%>			
		  <td align="right">
			<input name="dec_withheld" type="text" size="18" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyIntegerExtn('form_','dec_withheld','.');computeWithheld();"
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','dec_withheld','.');computeWithheld();" style="text-align:right;"></td>
		</tr>
		<tr valign="top">
		  <td></td>
		  <td>Overwithheld tax refunded to employee </td>
		  <td>&nbsp;</td>
			<% dTemp = 0d;
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(68);
				}else{
					if(vEmpInfo != null && vEmpInfo.size() > 0){
						strTemp = (String)vEmpInfo.elementAt(14);
					}else{
						strTemp = WI.fillTextValue("tax_refund");
					}
				}
			%>	
		  <td align="right"><input name="tax_refund" type="text" size="18" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyIntegerExtn('form_','tax_refund','.');computeWithheld();"
			onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','tax_refund','.');computeWithheld();" style="text-align:right;"></td>
		  </tr>
		<tr valign="top">
			<td width="3%">31</td>
			<td width="53%"><font size="1"><b>Total Amount of Taxes Withheld<br/>
			As Adjusted</b></font></td>
			<td width="6%">31</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(30);
			}else{
				strTemp = WI.fillTextValue("total_withheld");
			}		
		%>			
			<td width="38%" align="right">
			<input name="total_withheld" type="text" size="18" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		style="text-align:right;" readonly></td>
		</tr>
		</table>	</td>
</tr>
<tr>
	<td colspan="2" style="padding-left: 25px">
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;We declare, under the penalties of perjury, that this certificate has been made in good faith, verified by us, and to the best of our knowledge and belief, is true and correct pursuant to the provisions of the National Internal Revenue Code, as amended, and the regulations issued under authority thereof.<br/>
	<table width="725" border="0" cellpadding="0" cellspacing="0">
	<tr valign="top">
	<td width="384">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>56</b>_________________________________________
	<br/>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Present Employer/ Authorized Agent Signature Over Printed Name	</td>
	<td width="64">Date Signed</td>
	<%
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(63);
		} else {
			strTemp = WI.fillTextValue("er_date_sign");
		}
	%>	
	<td width="138"><input name="er_date_sign" type="text" size="12" maxlength="12" readonly value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
    <a href="javascript:show_calendar('form_.er_date_sign');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
	<td width="139"></td>
	</tr>
	<tr>
		<td colspan="4">CONFORME:</td>
	</tr>
	<tr valign="top">
	<td><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="11%"><b>57</b></td>
				<%
				if(vEmpInfo != null && vEmpInfo.size() > 0){
					strTemp = WI.formatName((String)vEmpInfo.elementAt(2), (String)vEmpInfo.elementAt(3), (String)vEmpInfo.elementAt(4), 7);
				}else{
					strTemp = "";
				}				
				%>
        <td width="56%" align="center" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp)%></td>
        <td width="33%">&nbsp;</td>
      </tr>
      <tr>
        <td>CTC No.</td>
        <td align="center">&nbsp;Employee Signature Over Printed Name </td>
        <td>&nbsp;</td>
      </tr>
    </table>
	  </td>
	<td>Date Signed</td>
	<%
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(61);
		}else{
			strTemp = WI.fillTextValue("ctc_issue");
		}
	%>	
	<td><input name="ee_date_sign" type="text" size="12" maxlength="12" readonly value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
    <a href="javascript:show_calendar('form_.ee_date_sign');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
	<td align="center" valign="bottom">Amount Paid </td>
	</tr>
	<tr valign="top">
	<%
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(59);
		}else{
			strTemp = WI.fillTextValue("emp_ctc_no");
		}
	%>
	<td>of Employee
	<input name="emp_ctc_no" type="text" size="20" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px;">
	Place of Issue
	<%
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(60);
		}else{
			strTemp = WI.fillTextValue("ctc_issue");
		}
	%>	
	<input name="ctc_issue" type="text" size="20" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		style="font-size:10px" ></td>
	<td >Date of Issue</td>
	<%
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(61);
		}else{
			strTemp = WI.fillTextValue("ctc_issue_date");
		}
	%>	
	<td ><input name="ctc_issue_date" type="text" size="12" maxlength="12" readonly value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
    <a href="javascript:show_calendar('form_.ctc_issue_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
	<%
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(62);
		}else{
			strTemp = WI.fillTextValue("ctc_amt");
		}
	%>	
	<td align="center" ><input name="ctc_amt" type="text" size="15" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		style="font-size:10px; text-align:right;" ></td>
	</tr>
	</table>	</td>
</tr>
<tr>
	<td colspan="2" align="center"><b>To be accomplished under subdstituted filing</b>	</td>
</tr>
<tr valign="top">
	<td>
	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;I declare, under the penalties of perjury,  that the information herein stated are reported 
   under BIR Form No. 1604CF which has been filed with the Bureau of Internal Revenue.<br/><br/>
	<table border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="350" align="center">58_________________________________________________________</td>
		</tr>
		<tr>
			<td align="center">Present Employer/ Authorized Agent Signature Over Printed Name</td>
		</tr>
		<tr>
			<td align="center">(Head of Accounting/Human Resource or Authorized Representative)</td>
		</tr>
	  </table>	</td>
	<td>
		&nbsp;&nbsp;&nbsp;I declare, under the penalties of perjury that i am qualified under substituted filing of Income Tax Returns(BIR Form No. 1700), since I received purely compensation income from only one employer in the Phils. for the calendar year; that taxes have been correctly withheld by my employer (tax due equals tax withheld);  that the  BIR Form No. 1604CF filed by  my  employer to the BIR shall constitute as my income tax return; and that BIR Form No. 2316 shall serve the same purpose as if BIR Form No. 1700 had been filed pursuant to the provisions of RR No. 3-2002, as amended.
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="25%" align="right">59</td>
				<%
				if(vEmpInfo != null && vEmpInfo.size() > 0){
					strTemp = WI.formatName((String)vEmpInfo.elementAt(2), (String)vEmpInfo.elementAt(3), (String)vEmpInfo.elementAt(4), 7);
				}else{
					strTemp = "";
				}				
				%>
		  <td width="50%" align="center" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp)%></td>
		  <td width="25%" align="center">&nbsp;</td>
		</tr>
		<tr>
			<td colspan="3" align="center">Employee Signature Over Printed Name</td>
		</tr>
		</table>	</td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td>
		<%if(vEditInfo == null || vEditInfo.size() == 0){%>
		<font size="1">
      <input type="button" name="122" value=" SAVE " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SaveRecord();">
    click to save form 2316 values of employee 
		<%}else{
			strTemp = (String)vEditInfo.elementAt(0);
		%>
    <input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:EditRecord(<%=strTemp%>);">
    to save changes
    <input type="button" name="edit2" value="  Delete  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord(<%=strTemp%>);">
to delete saved 2316
		<%}%>
    <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:CancelRecord();">
		  click to clear </font></td>
  </tr>
	<%if(vEditInfo != null && vEditInfo.size() > 0){%>
  <tr>
    <td><font size="1">
      <input type="button" name="1222" value=" PRINT " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:PrintForm();">
    </font></td>
  </tr>
	<%}%>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" colspan="5" align="center">&nbsp;</td>
	</tr>
	<tr bgcolor="#A49A6A">
		<td height="25" colspan="5" align="center" class="footerDynamic">&nbsp;</td>
	</tr>
</table>
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
