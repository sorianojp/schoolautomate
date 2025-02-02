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

function ReloadPage(){
	document.form_.submit();
}

function SaveRecord(){
	document.form_.save_.value = "1";
	document.form_.submit();
}

function computeNonTaxebleTotal(){
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

	if(vBasicNoTax.length == 0)
		vBasicNoTax = "0";

	if(vHolidayPay.length == 0)
		vHolidayPay = "0";

	if(vOTNoTax.length == 0)
		vOTNoTax = "0";

	if(vNpPay.length == 0)
		vNpPay = "0";				
	
	if(vHazardNoTax.length == 0)
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
//	document.form_.non_taxable.value = truncateFloat(document.form_.non_taxable.value,1,false);	
} 
 
 function computeNonTaxebleTotal(){
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
			
	vNonTaxTotal = eval(vBasicTaxable) + eval(vRep) + eval(vTranspo) + eval(vCola)
		+ eval(vHousing) + eval(vRegAmtA) + eval(vRegAmtB) + eval(vCommission)
		+ eval(vProfitShare) + eval(vFees) + eval(vTaxableBonus) 
		+ eval(vTaxableHazard) + eval(vTaxableOT) + eval(vSupAmtA) 
		+ eval(vSupAmtB);	
		return;
	}

	document.form_.present_taxable.value = eval(vTaxableTotal);	
	document.form_.present_taxable_.value = eval(vTaxableTotal);	
//	document.form_.non_taxable.value = truncateFloat(document.form_.non_taxable.value,1,false);	
} 

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
try
	{
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
	String strEmpID = null;
 	
	vEmpInfo = prEmpInfo.getPersonalTaxInfo(dbOP, request, null);
	if(vEmpInfo == null)
		strErrMsg = prEmpInfo.getErrMsg();
	else{
		vDepInfo = (Vector)vEmpInfo.elementAt(9);
		vEmployer = (Vector)vEmpInfo.elementAt(10);
		vEditInfo = prEmpInfo.operateOnEmployee2316(dbOP, request, 4);
	}
		
	if(WI.fillTextValue("save_").length() > 0){
		if(prEmpInfo.operateOnEmployee2316(dbOP, request, 1) == null)
			strErrMsg = prEmpInfo.getErrMsg();
		else
			strErrMsg = "Operation successful";
	}
	
%>
<body>
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
<table width="780" height="70" border=2 cellpadding="0" cellspacing="0">
<tr>
	<td colspan="3">
	<table border="0" width="780" cellpadding="0" cellspacing="0">
	<tr>
		<td width="59"><img src="images/2316_logo.jpg" width="57" height="52"/></td>
		<td>	
			Republika ng Pilipinas<br/>
			Kagawaran ng Pananalapi<br/>
		  Kawanihan ng Rentas Internas		</td>
		<td width="470" align="center">
		<font size="5">
		Certificate of Compensation<br/>
		Payment/Tax Withheld		</font>		</td>
		<td width="141">
		BIR Form No.<br/>
		<font size="7"><b>2316</b></font><br/>		</td>
	</tr>
	<tr>
		<td colspan="3">
			For Compensation Payment With or Without Tax Withheld</td>
		<td>
			July 2008 (ENCS)		</td>
	</tr>
	</table>	</td>
</tr>
<tr>
	<td colspan="3">
		Fill in all applicable spaces. Mark all appropriate boxes with an "X"</td>
</tr>
<tr>
	<td colspan="2" bgcolor="#999999">
	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="100">
		1 For the Year<br/>
		&nbsp;&nbsp;&nbsp;&nbsp;(YYYY)		</td>
		<td>
		<img src="images/arrow.jpg" width="6" height="7" />		</td>
	  <td ><input type="text" maxlength="4" size="3" style="font-size:14px;" 
					name="year_" onFocus="style.backgroundColor='#D3EBFF'" readonly
				  value="<%=WI.fillTextValue("year_of")%>" onBlur="style.backgroundColor='white'"></td>
	</tr>
	</table></td>
	<td bgcolor="#999999">
		<table border="0" cellpadding="0" cellspacing="0">
		<tr>
		<td width="125">
		2 For the Period<br/>
		&nbsp;&nbsp;&nbsp;&nbsp;<img src="images/arrow.jpg" width="6" height="7" /> From &nbsp;&nbsp;&nbsp;&nbsp;(MM/DD)		</td>
		<td width="75" align="center">
				<img src="images/box_4_mid_cols.jpg" width="62" height="23" />		</td>
		<td valign="bottom" align="right" width="100">
		To&nbsp;&nbsp;&nbsp;(MM/DD)		</td>
		<td width="75" align="center">
			<img src="images/box_4_mid_cols.jpg" width="62" height="23" />		</td>
		</tr>
		</table>	</td>
</tr>
<tr>
	<td colspan="2">
		<b>Part I &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Employee Information</b>	</td>
	<td nowrap="nowrap">
		<b>Part IV-B &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="1">Details of Compensation Income and Tax Withheld from Present Employer</font></b>	</td>
</tr>
<tr valign="top" bgcolor="#999999">
	<td colspan="2">
	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td>
		3 Taxpayer<br/>
		&nbsp;&nbsp;&nbsp;Identification No.		</td>
		<td width="10"><img src="images/arrow.jpg" width="6" height="7" /></td>
		<%
			if(vEmpInfo != null && vEmpInfo.size() > 0){
				strTemp = (String)vEmpInfo.elementAt(1);
			}else{
				strTemp = "";
			}
		%>
		<td><input name="tin" type= "text" class="textbox"  value="<%=WI.getStrValue(strTemp)%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  size="16"></td>
	</tr>
	</table>	</td>
	<td rowspan="20">
<!-- Right Panel Starts Here -->
	<table border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="16">			</td>
			<td>			</td>
			<td>			</td>
			<td align="center">Amount			</td>
		</tr>
		<tr>
			<td height="29"><b>A</b></td>
			<td colspan="3"><b>NON-TAXABLE/EXEMPT COMPENSATION INCOME</b></td>
		</tr>
		<tr valign="top">
			<td width="16" height="39">32</td>
			<td width="171">
			Basic Salary/<br/>
		    Statutory Minimun Wage<br/>
			Minimun Wage Earner (MWE)</td>
			<td width="25">32</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("basic_sal_ntax");
				}
			%>				
			<td width="154" align="right">
			<input name="basic_sal_ntax" type="text" size="20" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeyUp="computeNonTaxebleTotal();"></td>
		</tr>
		<tr valign="top">
			<td width="16" height="32">33</td>
			<td width="171">
			Holiday Pay (MWE)</td>
			<td width="25">33</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("holiday_pay");
				}
			%>	
			<td width="154" align="right">
			<input name="holiday_pay" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeNonTaxebleTotal();"></td>
		</tr>
		<tr valign="top">
			<td width="16" height="32">34</td>
			<td width="171">
			Overtime Pay (MWE)</td>
			<td width="25">34</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("ot_non_taxable");
				}
			%>	
			<td width="154" align="right"><input name="ot_non_taxable" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeNonTaxebleTotal();"></td>
		</tr>
		<tr valign="top">
			<td width="16" height="34">35</td>
			<td width="171">
			Night Shift Differential (MWE)</td>
			<td width="25">35</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("np_pay");
				}
			%>	
			<td width="154" align="right"><input name="np_pay" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeNonTaxebleTotal();"></td>
		</tr>
		<tr valign="top">
			<td width="16" height="33">36</td>
			<td width="171">
			Hazard Pay (MWE)</td>
			<td width="25">36</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("hazard_non_tax");
				}
			%>	
			<td width="154" align="right"><input name="hazard_non_tax" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeNonTaxebleTotal();"></td>
		</tr>
		<tr valign="top">
			<td width="16" height="33">37</td>
			<td width="171">
			13th Month Pay<br/>
			and Other Benefits</td>
			<td width="25">37</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("bonus_non_tax");
				}
			%>	
			<td width="154" align="right"><input name="bonus_non_tax" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeNonTaxebleTotal();"></td>
		</tr>
		<tr valign="top">
			<td width="16" height="33">38</td>
			<td width="171">
			De Minimis Benefits</td>
			<td width="25">38</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("de_minimis");
				}
			%>				
			<td width="154" align="right"><input name="de_minimis" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeNonTaxebleTotal();"></td>
		</tr>
		<tr valign="top">
			<td width="16">39</td>
			<td width="171">
			SSS, GSIS, PHIC & Pag-ibig<br/>
			Contributions, & Union Dues<br/>
			<sup><i>(Employee share only)</i></sup></td>
			<td width="25">39</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("contributions");
				}
			%>				
			<td width="154" align="right"><input name="contributions" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"1
		onKeyUp="computeNonTaxebleTotal();"></td>
		</tr>
		<tr valign="top">
			<td width="16" height="41">40</td>
			<td width="171">
			Salaries & Other Forms of<br/>
			compensation</td>
			<td width="25">40</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("other_comp");
				}
			%>	
			<td width="154" align="right"><input name="other_comp" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="computeNonTaxebleTotal();"></td>
		</tr>
		<tr valign="top">
			<td width="16" height="41">41</td>
			<td width="171">
			Total Non-Taxable/Exempt<br/>
			Compensation Income</td>
			<td width="25">41</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				
			}else{
				strTemp = WI.fillTextValue("non_taxable");
			}		
		%>
			<td width="154" align="right"><input name="non_taxable" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly></td>
		</tr>
		<tr valign="top">
			<td height="38"><b>B</b></td>
			<td colspan="3"><b>TAXABLE COMPENSATION INCOME<br />REGULAR</b></td>
		</tr>
		<tr valign="top">
			<td width="16" height="34">42</td>
			<td width="171">
			Basic Salary</td>
			<td width="25">42</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("basic_taxable");
				}
			%>	
			<td width="154" align="right"><input name="basic_taxable" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>		
		<tr valign="top">
			<td width="16" height="40">43</td>
			<td width="171">
			Representation</td>
			<td width="25">43</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("representation");
				}
			%>	
			<td width="154" align="right"><input name="representation" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>		
		<tr valign="top">
			<td width="16" height="40">44</td>
			<td width="171">
			Transportation</td>
			<td width="25">44</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("transportation");
				}
			%>	
			<td width="154" align="right"><input name="transportation" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="16" height="33">45</td>
			<td width="171">
			Cost of Living Allowance</td>
			<td width="25">45</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("cola");
				}
			%>	
			<td width="154" align="right"><input name="cola" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="16" height="34">46</td>
			<td width="171">
			Fixed Housing Allowance</td>
			<td width="25">46</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("housing_allow");
				}
			%>	
			<td width="154" align="right"><input name="housing_allow" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td><b>47</b></td>
			<td colspan="3">Others (Specify)</td>
		</tr>
		<tr valign="top">
			<td width="16" height="34">47A</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("regular_desc_a");
				}
			%>	
			<td width="171"><input name="regular_desc_a" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td width="25">47A</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("regular_amt_a");
				}
			%>	
			<td width="154" align="right"><input name="regular_amt_a" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="16" height="33">47B</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("regular_desc_b");
				}
			%>	
			<td width="171"><input name="regular_desc_b" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td width="25">47B</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("regular_amt_b");
				}
			%>	
			<td width="154" align="right"><input name="regular_amt_b" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="16" height="33">48</td>
			<td width="171">
			Commission</td>
			<td width="25">48</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("commission");
				}
			%>	
			<td width="154" align="right"><input name="commission" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="16" height="35">49</td>
			<td width="171">
			Profit Sharing</td>
			<td width="25">49</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("profit_share");
				}
			%>			
			<td width="154" align="right"><input name="profit_share" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="16" height="33">50</td>
			<td width="171">
			Fees Including Director's<br/>Fees</td>
			<td width="25">50</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("fees");
				}
			%>	
			<td width="154" align="right"><input name="fees" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="16" height="33">51</td>
			<td width="171">
			Taxable 13th Month Pay<br/>and Other Benefits</td>
			<td width="25">51</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("bonus_taxable");
				}
			%>	
			<td width="154" align="right"><input name="bonus_taxable" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="16" height="33">52</td>
			<td width="171">
			Hazard Pay</td>
			<td width="25">52</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("hazard_taxable");
				}
			%>	
			<td width="154" align="right"><input name="hazard_taxable" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="16">53</td>
			<td width="171">
			Overtime Pay</td>
			<td width="25">53</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("ot_taxable");
				}
			%>	
			<td width="154" align="right"><input name="ot_taxable" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
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
			<td width="16" height="33">54A</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("sup_desc_a");
				}
			%>	
			<td width="171"><input name="sup_desc_a" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td width="25">54A</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("sup_amt_a");
				}
			%>	
			<td width="154" align="right"><input name="sup_amt_a" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="16" height="34">54B</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("sup_desc_b");
				}
			%>
			<td width="171"><input name="sup_desc_b" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td width="25">54B</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					//strTemp = (String)vEditInfo.elementAt(5);
				}else{
					strTemp = WI.fillTextValue("sup_amt_b");
				}
			%>
			<td width="154" align="right"><input name="sup_amt_b" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="16">55</td>
			<td width="171">
			Total Taxable COmpensation<br/>Income</td>
			<td width="25">55</td>
			<td width="154" align="right"><input name="present_taxable_" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
	</table>	
	
<!-- Right Panel Ends Here! -->	
	</td>
</tr>
<tr bgcolor="#999999">
	<td colspan="2">
	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="305">4 Employee's Name (Last Name, First Name, Middle Name)</td>
		<td width="79">5 RDO Code</td>
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
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  size="40"></td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(4);
			}else{
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
	<td colspan="2">
	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="305">6 Registered Address</td>
		<td width="80">6A Zip Code</td>
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
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  size="40"></td>
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
	<td colspan="2">
	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="305">6B Local Home Address</td>
		<td width="81">6C Zip Code</td>
	</tr>
	<tr>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(7);
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
		<input name="tin23" type= "text" class="textbox"  value="<%=strTemp%>" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  size="40"></td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(8);
			}else{
				strTemp = WI.fillTextValue("local_zip");
			}
		%>			
		<td align="right"><input name="local_zip" type= "text" class="textbox"  
		value="<%=strTemp%>" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  size="5"></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td colspan="2">
	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="305">6D Foreign Address</td>
		<td width="81">6E Zip Code</td>
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
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  size="40"></td>
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
	<td width="190">
	7 Date of Birth (MM/DD/YYYY)<br/>
	&nbsp;&nbsp;&nbsp;
	<input name="dob" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="UpdateAge();style.backgroundColor='white'" onKeyUP="AllowOnlyIntegerExtn('staff_profile','dob','/');UpdateAge()"></td>
		<%
			if(vEmpInfo != null && vEmpInfo.size() > 0){
				strTemp = (String)vEmpInfo.elementAt(6);
			}else{
				strTemp = "";
			}
		%>
    <td width="212">8 Telephone Number<br/>
	&nbsp;&nbsp;&nbsp;
	<input name="tel_no" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
  </tr>
<tr bgcolor="#999999">
	<td colspan="2">
	<table width="200" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td Colspan="4">9 Exemption Status</td>
	</tr>
	<tr>
		<%
			if(vEmpInfo != null && vEmpInfo.size() > 0)
				strTemp = (String)vEmpInfo.elementAt(8);
			else
				strTemp = "";			

			if(strTemp.equals("0") || strTemp.equals("1")){
				bolSingle = true;
				strTemp = "<img src='images/x_status_box.jpg' width='27' height='15' />";
			}else{
				bolSingle = false;
				strTemp = "<img src='images/status_box.jpg' width='27' height='15' />";
			}
				
		%>
		<td width="125"  align="right"><%=strTemp%></td>
		<td width="96" >&nbsp;&nbsp;&nbsp;&nbsp;Single</td>
		<%if(bolSingle){ 
			strTemp = "<img src='images/status_box.jpg' width='27' height='15' />";
		}else{
			strTemp = "<img src='images/x_status_box.jpg' width='27' height='15' />";
		}%>		
		<td width="39"  align="right"><%=strTemp%></td>
		<td width="115" >&nbsp;&nbsp;&nbsp;&nbsp;Married</td>
	</tr>
	<tr>
		<td Colspan="4" nowrap="nowrap">9A Is the wife claiming the additional exemption for quilified dependent children?</td>
	</tr>
	<tr>
	  <td colspan="4" align="right"><table width="100%" border="0" cellspacing="0" cellpadding="0">
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
        <td width="33%" align="right"><input type="radio" name="is_wife_claim" value="1" <%=strTemp%>></td>
        <td width="26%">Yes</td>
				<%
					if(strTemp.length() == 0)
						strTemp = "checked";
					else
						strTemp = "";	
				%>
        <td width="10%" align="right"><input type="radio" name="is_wife_claim" value="0" <%=strTemp%>></td>
        <td width="31%">No</td>
      </tr>
    </table></td>
	  </tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td colspan="2">
		<table width="393" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="249">10 Name of Qualified Dependent Children</td>
			<td width="144">11 Date of Birth (MM/DD/YYYY)</td>
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
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" height="18">
			</td>			
			<td align="center">
			<%
			if(vDepInfo != null && vDepInfo.size() > 0)
				strTemp = (String)vDepInfo.elementAt(3);
			else
				strTemp = "";
			%>
			<input name="bday_1" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<br>
			<%
			if(vDepInfo != null && vDepInfo.size() > 4)
				strTemp = (String)vDepInfo.elementAt(7);
			else
				strTemp = "";
			%>
			<input name="bday_2" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			  <br>
			  <%
			if(vDepInfo != null && vDepInfo.size() > 8)
				strTemp = (String)vDepInfo.elementAt(11);
			else
				strTemp = "";
			%>
			  <input name="bday_3" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			  <br>
			  <%
			if(vDepInfo != null && vDepInfo.size() > 12)
				strTemp = (String)vDepInfo.elementAt(15);
			else
				strTemp = "";
			%>
			  <input name="bday_4" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.imp_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"></a></td>
		</tr>
	  </table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td colspan="2">
		<table width="393" border="0" cellpadding="0" cellspacing="0">
		<tr valign="top">
			<td width="226" height="25">12 Statutory Minimun Wage rate per day</td>
			<td width="15">12</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(12);
				} else {
					strTemp = WI.fillTextValue("min_wage_day");
				}
				strTemp = CommonUtil.formatFloat(strTemp, true);
				strTemp = ConversionTable.replaceString(strTemp, ",", "");
			%>
			<td width="138">
			<input name="min_wage_day" type="text" size="12" maxlength="12" value="<%=strTemp%>" 			
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			class="textbox" style="text-align:right"></td>
		</tr>
		<tr valign="top">
			<td width="226">13 Statutory Minimun Wage rate per month</td>
			<td width="15">13</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(13);
				}else{
					strTemp = WI.fillTextValue("min_wage_month");
				}
				strTemp = CommonUtil.formatFloat(strTemp, true);
				strTemp = ConversionTable.replaceString(strTemp, ",", "");				
			%>			
			<td width="138">
			<input name="min_wage_month" type="text" size="12" maxlength="12" value="<%=strTemp%>"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			class="textbox" style="text-align:right"></td>
		</tr>
		</table>
		<table border="0" cellpadding="0" cellspacing="0">
		<tr valign="top">
			<td width="14">14</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(14);
				}else{
					strTemp = WI.fillTextValue("is_mwe");
				}
				
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
			<td width="28"><input type="checkbox" name="is_mwe" value="1" <%=strTemp%>></td>
			<td width="337">Minimun Wage Earner whose compensation is exempt from<br/>
		  withholding tax and not subject to income tax</td>
		</tr>
	  </table>	</td>
  </tr>
<tr>
	<td colspan="2">
	<b>Part II &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Employer Information (Present)</b>	</td>
  </tr>
<tr bgcolor="#999999">
	<td colspan="2">
	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="100">
		15 Taxpayer<br/>
		&nbsp;&nbsp;&nbsp;Identification No.		</td>
		<%
			if(vEmployer != null && vEmployer.size() > 0){
				strTemp = (String)vEmployer.elementAt(7);
			}else{
				strTemp = "";
			}
		%>
		<td>&nbsp;
		<img src="images/arrow.jpg" width="6" height="7" />
		<input name="tin4" type= "text" class="textbox"  value="<%=WI.getStrValue(strTemp)%>" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  
		size="16" readonly>
		</td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td colspan="2">
	<table width="393" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="387">16 Employer's Name</td>
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
		<input name="tin5" type= "text" class="textbox"  value="<%=WI.getStrValue(strTemp)%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  size="40"></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td colspan="2">
	<table width="393" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td>17 Registered Address</td><td>17A Zip Code</td>
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
		<input name="tin6" type= "text" class="textbox"  value="<%=WI.getStrValue(strTemp)%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  size="40"></td>
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
	<td colspan="2">
	<table width="393" border="0" cellpadding="0" cellspacing="0">
	<tr>
	  <td width="375" colspan="4"  align="right">
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
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
        <td width="25%" align="right"><input type="radio" name="is_main_emp" value="1" <%=strTemp%>></td>
        <td width="26%">Main Employer</td>
        <%
					if(strTemp.length() == 0)
						strTemp = "checked";
					else
						strTemp = "";	
				%>
        <td width="9%" align="right"><input type="radio" name="is_main_emp" value="0" <%=strTemp%>></td>
        <td width="40%">Secondary Employer</td>
      </tr>
    </table></td>
	  </tr>
	</table>	</td>
  </tr>
<tr>
	<td colspan="2">
	<b>Part III &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Employer Information (Previous)</b>	</td>
  </tr>
<tr bgcolor="#999999">
	<td colspan="2">
	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="100">
		18 Taxpayer<br/>
		&nbsp;&nbsp;&nbsp;Identification No.		</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(15);
			}else{
				strTemp = WI.fillTextValue("prev_emp_tin");
			}		
		%>
		<td>&nbsp;
		<img src="images/arrow.jpg" width="6" height="7" />
		<input name="prev_emp_tin" type= "text" class="textbox"  value="<%=WI.getStrValue(strTemp)%>" size="16"
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td colspan="2">
	<table width="393" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="387">19 Employer's Name</td>
	</tr>
	<tr>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(16);
			}else{
				strTemp = WI.fillTextValue("prev_emp_name");
			}		
		%>
		<td>
		<img src="images/arrow.jpg" width="6" height="7" />
		<input name="prev_emp_name" type= "text" class="textbox"  value="<%=WI.getStrValue(strTemp)%>" size="40"
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  ></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td colspan="2">
	<table width="393" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td>20 Registered Address</td><td>20A Zip Code</td>
	</tr>
	<tr>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(17);
			}else{
				strTemp = WI.fillTextValue("prev_emp_addr");
			}		
		%>
		<td>
		<img src="images/arrow.jpg" width="6" height="7" />
		<input name="prev_emp_addr" type= "text" class="textbox"  value="<%=WI.getStrValue(strTemp)%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  size="40"></td>
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
	<td colspan="2">
	<b>Part IV-A 				
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	Summary</b>	</td>
  </tr>
<tr bgcolor="#999999" valign="top">
	<td colspan="2">
		<table border="0" cellpadding="0" cellspacing="0" cllspacing="0">
		<tr valign="top">
			<td width="12">21</td>
			<td width="199"><font size="1">Gross Compensation Income from<br/>
		  Present Employer (Item 41 plus Item 55)</font></td>
			<td width="20">21</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(19);
			}else{
				strTemp = WI.fillTextValue("gross_income");
			}		
		%>
			<td width="150" align="right">
			<input name="gross_income" type="text" size="20" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly></td>
		</tr>
		<tr valign="top">
			<td width="12">22</td>
			<td width="199"><font size="1"><b>Less: Total Non-Taxable</b><br/>
		  	Exempt (Item 41)</font></td>
			<td width="20">22</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(20);
			}else{
				strTemp = WI.fillTextValue("non_taxable_");
			}		
		%>
			<td width="150" align="right"><input name="non_taxable_" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly></td>
		</tr>
		<tr valign="top">
			<td width="12">23</td>
			<td width="199"><font size="1"><b>Taxable Compensation Income</b><br/>
		  	from Present Employer (Item 55)</font></td>
			<td width="20">23</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(21);
			}else{
				strTemp = WI.fillTextValue("present_taxable");
			}		
		%>
			<td width="150" align="right">
			<input name="present_taxable" type="text" size="20" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly></td>
		</tr>
		<tr valign="top">
			<td width="12">24</td>
			<td width="199"><font size="1"><b>Add: Taxable Conpensation<br/>
		  	Income from Previous Exmployer</font></td>
			<td width="20">24</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				
			}else{
				strTemp = WI.fillTextValue("prev_emp_addr");
			}		
		%>
			<td width="150" align="right"><input name="tel_no24" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="12">25</td>
			<td width="199"><font size="1"><b>Gross Taxable<br/>
		  	Compensation Income</font></td>
			<td width="20">25</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				
			}else{
				strTemp = WI.fillTextValue("gross_taxable");
			}		
		%>
			<td width="150" align="right"><input name="gross_taxable" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="12">26</td>
			<td width="199"><font size="1"><b>Less: Total Exemptions</b></font></td>
			<td width="20">26</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					
				}else{
					strTemp = WI.fillTextValue("tot_exemption");
				}		
			%>
			<td width="150" align="right"><input name="tot_exemption" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="12">27</td>
			<td width="199"><font size="1"><b>Less: Premium Paid on Health</b><br/>
		  	and/or Hospital Insurance (if applicable)</font></td>
			<td width="20">27</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					
				}else{
					strTemp = WI.fillTextValue("health_premium");
				}		
			%>
			<td width="150" align="right"><input name="health_premium" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="12">28</td>
			<td width="199"><font size="1"><b>Net Taxable</b><br/>
		  	Compensation Income</font></td>
			<td width="20">28</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				
			}else{
				strTemp = WI.fillTextValue("net_taxable");
			}		
		%>			
			<td width="150" align="right"><input name="net_taxable" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="12">29</td>
			<td width="199"><font size="1"><b>Tax Due</b></font></td>
			<td width="20">29</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				
			}else{
				strTemp = WI.fillTextValue("tax_due");
			}		
		%>			
			<td width="150" align="right"><input name="tax_due" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="12">30</td>
			<td colspan="3"><font size="1">
			  <b>Amount of Taxes Withheld</b></font>			  </td>
		</tr>
		<tr valign="top">
			<td width="12"></td>
			<td width="199"><font size="1"><b>30A Present Employer</b></font></td>
			<td width="20">30A</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				
			}else{
				strTemp = WI.fillTextValue("pres_withheld");
			}		
		%>
			<td width="150" align="right"><input name="pres_withheld" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="12"></td>
			<td width="199"><font size="1"><b>30B Previous Employer</b></font></td>
			<td width="20">30B</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				
			}else{
				strTemp = WI.fillTextValue("prev_withheld");
			}		
		%>
			<td width="150" align="right"><input name="prev_withheld" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="top">
			<td width="12">31</td>
			<td width="199"><font size="1"><b>Total Amount of Taxes Withheld<br/>
			As Adjusted</b></font></td>
			<td width="20">31</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0){
				
			}else{
				strTemp = WI.fillTextValue("total_withheld");
			}		
		%>			
			<td width="150" align="right"><input name="total_withheld" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		</table>	</td>
</tr>
<tr>
	<td colspan="3" style="padding-left: 25px">
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;We declare, under the penalties of perjury, that this certificate has been made in good faith, verified by us, and to the best of our knowledge and belief, is true and correct pursuant to the provisions of the National Internal Revenue Code, as amended, and the regulations issued under authority thereof.<br/>
	<table width="725" border="0" cellpadding="0" cellspacing="0">
	<tr valign="top">
	<td width="384">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>56</b>_________________________________________
	<br/>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<sup>Present Employer/ Authorized Agent Signature Over Printed Name</sup>	
	</td>
	<td width="64">Date Signed</td>
	<%
		if(vEditInfo != null && vEditInfo.size() > 0){
			//strTemp = (String)vEditInfo.elementAt(5);
		}else{
			strTemp = WI.fillTextValue("er_date_sign");
		}
	%>	
	<td width="138"><input name="er_date_sign" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
    <a href="javascript:show_calendar('form_.imp_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
	<td width="139"></td>
	</tr>
	<tr>
		<td colspan="4">CONFORME:</td>
	</tr>
	<tr valign="top">
	<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>57</b>_________________________________________
	<br/>
	CTC No.
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<sup>Employee Signature Over Printed Name</sup>	
	</td>
	<td>Date Signed</td>
	<%
		if(vEditInfo != null && vEditInfo.size() > 0){
			//strTemp = (String)vEditInfo.elementAt(5);
		}else{
			strTemp = WI.fillTextValue("ctc_issue");
		}
	%>	
	<td><input name="ee_date_sign" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
    <a href="javascript:show_calendar('form_.imp_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
	<td align="center" valign="bottom">Amount Paid </td>
	</tr>
	<tr valign="top">
	<%
		if(vEditInfo != null && vEditInfo.size() > 0){
			//strTemp = (String)vEditInfo.elementAt(5);
		}else{
			strTemp = WI.fillTextValue("emp_ctc_no");
		}
	%>
	<td>of Employee
	<input name="emp_ctc_no" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px;">
	Place of Issue
	<%
		if(vEditInfo != null && vEditInfo.size() > 0){
			//strTemp = (String)vEditInfo.elementAt(5);
		}else{
			strTemp = WI.fillTextValue("ctc_issue");
		}
	%>	
	<input name="ctc_issue" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		style="font-size:10px" ></td>
	<td >Date of Issue</td>
	<%
		if(vEditInfo != null && vEditInfo.size() > 0){
			//strTemp = (String)vEditInfo.elementAt(5);
		}else{
			strTemp = WI.fillTextValue("ctc_issue_date");
		}
	%>	
	<td ><input name="ctc_issue_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
    <a href="javascript:show_calendar('form_.imp_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
	<%
		if(vEditInfo != null && vEditInfo.size() > 0){
			//strTemp = (String)vEditInfo.elementAt(5);
		}else{
			strTemp = WI.fillTextValue("ctc_amt");
		}
	%>	
	<td ><input name="ctc_amt" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		style="font-size:10px" ></td>
	</tr>
	</table>
	</td>
</tr>
<tr>
	<td colspan="3" align="center"><b>To be accomplished under subdstituted filing</b> 
	</td>
</tr>
<tr valign="top">
	<td colspan="2">
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
	  </table>
	</td>
	<td>
		&nbsp;&nbsp;&nbsp;I declare, under the penalties of perjury that i am qualified under substituted filing of Income Tax Returns(BIR Form No. 1700), since I received purely compensation income from only one employer in the Phils. for the calendar year; that taxes have been correctly withheld by my employer (tax due equals tax withheld);  that the  BIR Form No. 1604CF filed by  my  employer to the BIR shall constitute as my income tax return; and that BIR Form No. 2316 shall serve the same purpose as if BIR Form No. 1700 had been filed pursuant to the provisions of RR No. 3-2002, as amended.
		<table border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="350" align="center">59______________________________________________</td>
		</tr>
		<tr>
			<td align="center">Employee Signature Over Printed Name</td>
		</tr>
		</table>
	</td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td><font size="1">
      <input type="button" name="122" value=" SAVE " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SaveRecord();">
    click to save form 2316 values of employee </font></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  <td height="25" colspan="5" align="center">&nbsp;</td>
	  </tr>
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="5" align="center" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	<input type="hidden" name="save_">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>