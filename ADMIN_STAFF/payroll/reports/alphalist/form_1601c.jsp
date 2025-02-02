<%@ page language="java" import="utility.*,java.util.Vector, payroll.PRTaxReport, payroll.PRRemittance" 
				 buffer="16kb"%>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Bureau of Internal Revenue - 1601-C</title>
<style>
	body{
		margin:0px;
		font-family:Arial, Helvetica, sans-serif;
		font-size:11px;
		color:#333333;
		font-weight:normal;
	}

	.container{
		border:4px #333333 solid;
	}
	
	.marginBottom{
		margin-bottom:2px;
	}
	.borderBottom{
		border-bottom:4px #333333 solid;
	}
	.borderBottomII{
		border-bottom:1px #333333 solid;
	}
	.borderRight{
		border-right:1px #333333 solid;
		background-color:#CCCCCC;
	}
	.borderRightBottom{
		border-bottom:1px #333333 solid;
		border-right:1px #333333 solid;
	}
	.borderLeft{
		border-left: 4px #333333 solid;
	}
	.textTitleHeader{
		font-family:Arial, Helvetica, sans-serif;
		font-size:21px;
		font-weight:bold;
		color:#333333;
	}
	td {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 11px;
	}
	
	.textbox_smallfont {
	background-color: #FDFDFD;
	border-style: inset;
	border-width: 1px;
	border-color: #194685;
	font-family: Arial, Verdana,  Helvetica, sans-serif;
	font-size: 11px;
}
	
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
function initializeFields(){
	toggleRelief(<%=WI.fillTextValue("is_on_relief")%>);
//	if(document.form_.adjust_1)
//		computeSectionA();
}

function PrintPg(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
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
	document.form_.is_reloaded.value = "1";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce('form_');
}

function DeleteRecord(strInfoIndex){
	if(!confirm("Continue deleting saved 1601c form?"))
		return;
	document.form_.print_pg.value = "";
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;	
	this.SubmitOnce('form_');
}

function CancelRecord(){
	location = "./form_1601c.jsp";
}

function PrintPage(){
	document.form_.print_pg.value = "1";
 	this.SubmitOnce('form_');
}

function toggleRelief(strRelief){
	if(!document.form_.relief_details)
		return;
		
	if(strRelief == '1')
		document.form_.relief_details.disabled = false;
	else
		document.form_.relief_details.disabled = true;			
}

function computePenalty(){
	var dSurcharge = document.form_.surcharge.value;
	var dInterest = document.form_.interest.value;
	var dCompromise = document.form_.compromise.value;
	var dTotal = 0;
	
	if(isNaN(dSurcharge) || dSurcharge.length == 0)
		dSurcharge = 0;

	if(isNaN(dInterest) || dInterest.length == 0)
		dInterest = 0;

	if(isNaN(dCompromise) || dCompromise.length == 0)
		dCompromise = 0;

	dTotal = eval(dSurcharge) +  eval(dInterest) + eval(dCompromise);
	document.form_.total_penalty.value = dTotal;	
	computeAfterPenalty();
}

function computeSectionA(){
//	var dSurcharge = document.form_.surcharge.value;
//	var dInterest = document.form_.interest.value;
//	var dCompromise = document.form_.compromise.value;
	var dPrevious = 0;
	var dAdjust = 0;
	var dTotal = 0;
	
	for(var i = 1; i < 4; i++){
		dAdjust = eval('document.form_.adjust_'+i+'.value');
		if(isNaN(dAdjust) || dAdjust.length == 0)
			dAdjust = 0;

		dPrevious  = eval('document.form_.adjust_prev_'+i+'.value'); 
		if(isNaN(dPrevious) || dPrevious.length == 0)
			dPrevious = 0;		
		
		dTotal += eval(dAdjust) + eval(dPrevious);		
	}
	dTotal = truncateFloat(dTotal,2,false);
	document.form_.adjust_total.value = dTotal;	
	document.form_.adjustment.value = dTotal;		
	computeForRemittance();
}

function computeForRemittance(){
 	var dToWithhold = document.form_.to_be_withheld.value;
	var dAdjustment = document.form_.adjustment.value;
	var dTotal = 0;
	
	if(isNaN(dToWithhold) || dToWithhold.length == 0)
		dToWithhold = 0;

	if(isNaN(dAdjustment) || dAdjustment.length == 0)
		dAdjustment = 0;
 
	dTotal = eval(dToWithhold) +  eval(dAdjustment);
	document.form_.for_remittance.value = dTotal;	
	computeStillDue();
}

function computeStillDue(){
 	var dForRemittance = document.form_.for_remittance.value;
	var dPrevRemittance = document.form_.prev_remittance.value;
	var dTotal = 0;
	
	if(isNaN(dForRemittance) || dForRemittance.length == 0)
		dForRemittance = 0;

	if(isNaN(dPrevRemittance) || dPrevRemittance.length == 0)
		dPrevRemittance = 0;
 
	dTotal = eval(dForRemittance) -  eval(dPrevRemittance);
	document.form_.tax_due.value = dTotal;	
	computeAfterPenalty();
}

function computeAfterPenalty(){
 	var dTaxDue = document.form_.tax_due.value;
	var dPenalty = document.form_.total_penalty.value;
	var dTotal = 0;
	
	if(isNaN(dTaxDue) || dTaxDue.length == 0)
		dTaxDue = 0;

	if(isNaN(dPenalty) || dPenalty.length == 0)
		dPenalty = 0;
 
	dTotal = eval(dTaxDue) -  eval(dPenalty);
	document.form_.final_due.value = dTotal;	
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
if (WI.fillTextValue("print_pg").length() > 0){%>
	<jsp:forward page="./form_1601c_print.jsp"/>
<% return; }
try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions","form_1601c.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0){
			strErrMsg = "Image file extension is missing. Please contact admin.";
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
														"form_1601c.jsp");
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
 	Vector vEditInfo = null;
 	Vector vEmployer = null;
	Vector vMonthValues = null;
 	String strEmpID = null;
	String strPageAction = WI.fillTextValue("page_action");
	double dTemp = 0d;
	boolean bolIsReloaded = (WI.fillTextValue("is_reloaded").length() > 0);
	int iTemp = 0;
	int i = 0;
	int iCurYear = Integer.parseInt(WI.getTodaysDate(12));
	double dSectionATotal = 0d;
	
	String[] astrMonth = {"", "01-Jan", "02-Feb","03-Mar", "04-Apr", "05-May","06-Jun","07-Jul",  
						"08-Aug", "09-Sep", "10-Oct", "11-Nov", "12-Dec"};	
	String strEmployerIndex = WI.fillTextValue("employer_index");
	if(strPageAction.length() > 0){
		if(prEmpInfo.operateOnEmployer1601c(dbOP, request, Integer.parseInt(strPageAction)) == null)
			strErrMsg = prEmpInfo.getErrMsg();
		else
			strErrMsg = "Operation successful";
	}
	
	vMonthValues = prEmpInfo.getMonthlyReturnValue(dbOP, request, strEmployerIndex);	
	if(vMonthValues == null){
			strErrMsg = prEmpInfo.getErrMsg(); 
	} else {
		vEmployer = (Vector)vMonthValues.remove(0);
		if(vEmployer == null){
			strErrMsg = prEmpInfo.getErrMsg(); 
		} else {
			vEditInfo = prEmpInfo.operateOnEmployer1601c(dbOP, request, 4);
		}		
	}
%>
<body onload="initializeFields();">
<form name="form_" action="./form_1601c.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr bgcolor="#A49A6A">
		<td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" size="2"><strong>::::
		PAYROLL: FORM 1601c ENCODING ::::</strong></font></td>
	</tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
 <tr>
  <td height="23" colspan="3">&nbsp;<font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></td>
 </tr>
 
 <tr>
   <td height="25">&nbsp;</td>
   <td>Employer </td>
   <td nowrap="nowrap"><select name="employer_index" onchange="ReloadPage();">
	 	<option value="0">Select Employer</option>
     <%
			String strEmployer = WI.fillTextValue("employer_index");
			boolean bolIsDefEmployer = false;
			java.sql.ResultSet rs = null;
			strTemp = "select employer_index,employer_name,is_default from pr_employer_profile where is_del = 0 order by is_default desc";
			rs = dbOP.executeQuery(strTemp);
			while(rs.next()){
				strTemp = rs.getString(1);
				if(strEmployer.length() == 0 || strEmployer.equals(strTemp)) {
					strErrMsg = " selected";
					if(rs.getInt(3) == 1)
						bolIsDefEmployer = true;
					if(strEmployer.length() == 0)
						strEmployer = strTemp;
				}
				else	
					strErrMsg = "";
					
			%>
     <option value="<%=strTemp%>" <%=strErrMsg%>><%=rs.getString(2)%></option>
     <%}
			rs.close();
		%>
   </select>	 </td>
   </tr>
 <tr>
  <td width="4%" height="25">&nbsp;</td>
  <td width="15%">Month / Year </td>
  <td width="81%" nowrap="nowrap"><select name="month_of" onchange="ReloadPage();">
   <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%>
  </select>
  <select name="year_of" onChange="ReloadPage();">
    <%=dbOP.loadComboYear(WI.fillTextValue("year_of"), 2, 1)%>
  </select></td>
  </tr>
 <tr>
   <td height="10">&nbsp;</td>
   <td>&nbsp;</td>
	 <%
	 	if(WI.fillTextValue("inc_resigned").length() > 0)
			strTemp = "checked";
		else
			strTemp = "";
	 %>
   <td>&nbsp;<input type="checkbox" name="inc_resigned" value="1" <%=strTemp%>>include resigned employees</td>
 </tr>
 <tr>
  <td height="10">&nbsp;</td>
  <td>&nbsp;</td>
  <td><!--<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a>-->
			<font size="1">
<input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">			
Click to reload page</font></td>
 </tr>
 <tr>
  <td height="10" colspan="3"><hr size="1" color="#0000FF"></td>
 </tr>
</table>
<%if(vEmployer != null && vEmployer.size() > 0){%>
	<table width="98%" border="0" cellpadding="0" cellspacing="0" class="marginBottom">   
		<tr>
			<td height="14" colspan="8" valign="top">(To be filled up by the BIR)</td>
		</tr>
		<tr>
			<td width="5%" height="14" ><img src="images/arrow2.png" width="6" height="6"/> DLN:</td>
			<td width="49%" >				<input name="textfield" type="text" id="textfield" style="width:345px; height:11px; text-align:left; border:1px #999999 solid"/>			</td>
				<td width="1%" ><img src="images/arrow2.png" width="6" height="6"/></td>
				<td width="5%" >PSOC:</td>
				<td width="17%" >					<input name="textfield" type="text" id="textfield" style="width:110px; height:11px; text-align:left; border:1px #999999 solid"/>			</td>
				<td width="1%" ><img src="images/arrow2.png" width="6" height="6"/></td>
				<td width="4%" >PSIC:</td>
				<td width="18%" ><input name="textfield" type="text" id="textfield" style="width:110px; height:11px; text-align:left; border:1px #999999 solid"/></td>
		</tr>
	</table>
	<table width="98%" border="0" cellpadding="0" cellspacing="0" bgcolor="#CCCCCC" class="container">
		<tr>
			<td width="100%" height="70" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
					<tr>
						<td width="8%" height="66" bgcolor="#FFFFFF"><img src="images/bir_logo.png" width="64" height="48"/></td>
						<td width="24%" bgcolor="#FFFFFF"> Republika ng Pilipinas<br/>
							Kagawaran ng Pananalapi<br/>
							Kawanihan ng Rentas Internas </td>
						<td width="48%" bgcolor="#FFFFFF"><div align="center" class="textTitleHeader"> Monthly Remittance Return<br/>
							of Income Taxes Withheld<br/>
							on Compensation</div></td>
						<td width="20%" bgcolor="#FFFFFF"><div > <span>BIR Form No.</span><br/>
										<span class="textTitleHeader">1601-C</span><br/>
							September 2001 (ENCS) </div></td>
					</tr>
			</table></td>
		</tr>
		<tr>
			<td height="18" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
					<tr>
						<td height="14" bgcolor="#FFFFFF"><div > Fill in all applicable spaces. Mark all appropriate boxes with an &quot;X&quot; </div></td>
					</tr>
			</table></td>
		</tr>
		<tr>
			<td valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
					<tr>
						<td width="14%" height="14"><strong>1</strong> For the month</td>
						<td colspan="2" class="borderRight">&nbsp;</td>
						<td colspan="6" class="borderRight"><strong>2</strong> Amended Return?</td>
						<td colspan="2" class="borderRight"><strong>3</strong> No. of sheets attached</td>
						<td colspan="6" ><strong>4</strong> Any Taxes Withheld?</td>
					</tr>
					<tr>
						<td height="25" valign="top">&nbsp;&nbsp;&nbsp;(MM/YYYY)</td>
						<td width="1%" bgcolor="#CCCCCC" img="img"/bg1.gif><img src="images/arrow1.png" width="6" height="6"/></td>
						<%
						strTemp = WI.fillTextValue("month_of");
						iTemp = Integer.parseInt(strTemp) + 1;
						strTemp = Integer.toString(iTemp);								
						if(strTemp.length() == 1)
							strTemp = "0"+strTemp;
					%>
						<td width="20%" class="borderRight">
						<input name="month_" type="text" value="<%=strTemp%>" maxlength="2" size="3" class="textbox_smallfont"
						onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
						readonly/>
								<%
							strTemp = WI.fillTextValue("year_of");
						%>
								<input name="year_" type="text" value="<%=strTemp%>" maxlength="4" size="5" class="textbox_smallfont"
						onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
						readonly/></td>
						<td width="3%" >&nbsp;</td>
						<td width="2%" ><img src="images/arrow1.png" width="6" height="6"/></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(3);
							else
								strTemp = WI.fillTextValue("is_ammended");
							
						if(strTemp.equals("1"))
								strTemp = "checked";
							else
								strTemp = "";
						%>
						<td width="3%" ><input type="radio" name="is_ammended" value="1" <%=strTemp%>/></td>
						<td width="5%" >Yes</td>
						<%
							if(strTemp.length() == 0)
								strTemp = "checked";
							else
								strTemp = "";
						%>								
						<td width="3%"><input type="radio" name="is_ammended" value="0" <%=strTemp%>/></td>
						<td width="6%" class="borderRight">No</td>
						<td width="12%">&nbsp;</td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(4);
							else						
								strTemp = WI.fillTextValue("addl_sheets");
						%>
						<td width="7%" class="borderRight">
						<input name="addl_sheets" type="text" class="textbox_smallfont" onfocus="style.backgroundColor='#D3EBFF'"
						onblur="AllowOnlyFloat('form_','addl_sheets');style.backgroundColor='white'"
						onkeyup="AllowOnlyFloat('form_','addl_sheets');" style="text-align : right"
						value="<%=WI.getStrValue(strTemp,"0")%>" size="4" maxlength="3"/></td>
						<td width="4%">&nbsp;</td>
						<td width="1%"><img src="images/arrow1.png" width="6" height="6"/></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(5);
							else						
								strTemp = WI.fillTextValue("has_withheld");
							if(strTemp.equals("1"))
								strTemp = "checked";
							else
								strTemp = "";
						%>
						<td width="3%"><input type="radio" name="has_withheld" value="1" <%=strTemp%>/></td>
						<td width="7%">Yes</td>
						<%									
							if(strTemp.length() == 0)
								strTemp = "checked";
							else
								strTemp = "";
						%>
						<td width="3%"><input type="radio" name="has_withheld" value="0" <%=strTemp%>/></td>
						<td width="6%">No</td>
					</tr>
			</table></td>
		</tr>
		<tr>
			<td height="18" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
				<tr background="images/bg1.gif">
					<td width="13%" height="14" bgcolor="#CCCCCC"><strong>Part I</strong></td>
					<td width="74%" align="center" bgcolor="#CCCCCC"><strong>Background Information</strong></td>
					<td width="13%" align="center" bgcolor="#CCCCCC">&nbsp;</td>
				</tr>
			</table>
			</td>
		</tr>
		<tr>
			<td valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#CCCCCC" class="borderBottom">
					<tr>
						<td height="37" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottomII">
								<tr>
									<td height="12" nowrap="nowrap" ><strong>5</strong> TIN</td>
									<td height="12" >&nbsp;</td>
									<%
										if(vEmployer != null && vEmployer.size() > 0)											
											strTemp = (String)vEmployer.elementAt(7);
										else
											strTemp = WI.fillTextValue("tin");
									%>
									<td width="18%" rowspan="2" class="thinborderRIGHT" >
									<input name="tin" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
									onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
									readonly/></td>
									<td nowrap="nowrap"><strong>6</strong> RDO Code</td>
									<td>&nbsp;</td>
									<%
										if(vEmployer != null && vEmployer.size() > 0)											
											strTemp = (String)vEmployer.elementAt(13);
										else
											strTemp = WI.fillTextValue("rdo_code");
									%>									
									<td width="10%" rowspan="2" class="thinborderRIGHT">
									<input name="rdo_code" type="text" value="<%=strTemp%>" maxlength="3" size="4" class="textbox_smallfont"
									onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"/></td>
									<td width="14%" rowspan="2" valign="top" nowrap><strong>7</strong> Line of Business/<br/>
									Occupation</td>
									<td width="3%" >&nbsp;</td>
									<%
									if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
										strTemp = (String)vEditInfo.elementAt(7);
									else															
										strTemp = WI.fillTextValue("business_line");
									%>
									<td width="36%" rowspan="2">
									<input name="business_line" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="128" size="32" class="textbox_smallfont"
									onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"/></td>
								</tr>
								<tr>
									<td width="5%" height="12" align="right" ><img src="images/arrow1.png" width="6" height="6"/></td>
									<td width="2%" align="right" >&nbsp;</td>
									<td width="10%" height="12" align="right" ><img src="images/arrow1.png" width="6" height="6"/></td>
									<td width="2%" align="right" >&nbsp;</td>
									<td width="3%" align="right" ><img src="images/arrow1.png" width="6" height="6"/></td>
								</tr>
						</table>
						</td>
					</tr>
					<tr>
						<td height="49" valign="top">
						<table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottomII">
							<tr>
								<td colspan="3" class="borderRight"><strong>8</strong> Withholding Agent's Name (Last Name, First Name, Middle Name for Individuals)/(Registered Name for Non-Individual)</td>
								<td height="17" colspan="2" ><strong>9</strong> Telephone Number</td>
							</tr>
							<tr>
								<td width="4%" align="right" class="thinborderBOTTOM" ><img src="images/arrow1.png" width="6" height="6"/></td>
								<td width="2%" align="right" class="thinborderBOTTOM" >&nbsp;</td>
								<%
									if(vEmployer != null && vEmployer.size() > 0)											
										strTemp = (String)vEmployer.elementAt(12);
									else
										strTemp = WI.fillTextValue("agent_name");
								%>
								<td width="78%" class="thinborderBOTTOM">
								<input name="agent_name" type="text" value="<%=strTemp%>" maxlength="128" size="64" class="textbox_smallfont"
								onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
								</td>
								<%
									if(vEmployer != null && vEmployer.size() > 0)											
										strTemp = (String)vEmployer.elementAt(5);
									else
										strTemp = WI.fillTextValue("tel_no");
								%>
								<td height="21" colspan="2" class="thinborderBOTTOM">
								<input name="tel_no" type="text" value="<%=strTemp%>" maxlength="7" size="8" class="textbox_smallfont"
								onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" style="width:auto"/>
								</td>
							</tr>
							<tr>
								<td colspan="3" class="borderRight"><strong>10</strong> Registered Address</td>
								<td height="12" colspan="2" ><strong>11</strong> Zip Code</td>
							</tr>
							<tr>
								<td width="4%" align="right" class="thinborderBOTTOM" ><img src="images/arrow1.png" width="6" height="6"/></td>
								<td width="2%" align="right" class="thinborderBOTTOM" >&nbsp;</td>
								<%
									if(vEmployer != null && vEmployer.size() > 0)											
											strTemp = (String)vEmployer.elementAt(3);
									else
										strTemp = WI.fillTextValue("agent_address");
								%>
								<td width="78%" class="thinborderBOTTOM"><input name="agent_address" type="text" value="<%=strTemp%>" maxlength="128" size="64" class="textbox_smallfont"
								onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" style="width:auto"/></td>
								<td width="2%" height="27" align="right" class="thinborderBOTTOM" ><img src="images/arrow1.png" width="6" height="6"/></td>
								<%
									if(vEmployer != null && vEmployer.size() > 0)											
										strTemp = (String)vEmployer.elementAt(4);
									else
										strTemp = WI.fillTextValue("zip_code");
								%>
								<td width="14%" class="thinborderBOTTOM">
								<input name="zip_code" type="text" value="<%=strTemp%>" maxlength="7" size="7" class="textbox_smallfont"
								onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"/></td>
							</tr>
							<tr>
								<td colspan="3" class="borderRight"><table width="100%" border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td height="18" colspan="6" rowspan="2" valign="top" class="borderRight"><strong>12</strong> Category of Withholding Agent</td>
								<td colspan="6"><strong>13</strong> Are there payees availing tax relief under Special law</td>
								</tr>
							<tr>
								<td>&nbsp;</td>
								<td colspan="4">or International Tax Treaty?</td>
								<%
									if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
										strTemp = (String)vEditInfo.elementAt(9);
									else										
										strTemp = WI.fillTextValue("relief_details");
								%>
								<td width="34%" rowspan="2"><input name="relief_details" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="64" size="24" class="textbox_smallfont"
									onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"/></td>
							</tr>
							<tr>
								<td width="1%" height="20" align="right" ><img src="images/arrow1.png" width="6" height="6"/></td>
								<td width="1%" >&nbsp;</td>
								<%
									if(vEmployer != null && vEmployer.size() > 0){
										strTemp = (String)vEmployer.elementAt(2);
										if(strTemp.equals("1"))
											strTemp = "1";
										else
											strTemp = "0";
										
									}else
										strTemp = WI.fillTextValue("is_private");
									
									if(strTemp.equals("1"))
										strTemp = "checked";
									else
										strTemp = "";									
								%>								
								<td width="4%" ><input type="radio" name="is_private" value="1" <%=strTemp%>/></td>
								<td width="7%" >Private</td>
								<%
									if(strTemp.length() == 0)
										strTemp = "checked";
									else
										strTemp = "";
								%>																
								<td width="4%" ><input type="radio" name="is_private" value="0" <%=strTemp%>/></td>
								<td width="15%" class="borderRight">Government</td>
								<%
									if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
										strTemp = (String)vEditInfo.elementAt(8);
									else															
										strTemp = WI.fillTextValue("is_on_relief");
										
									if(strTemp.equals("1"))
										strTemp = "checked";
									else
										strTemp = "";
								%>								
								<td width="3%" ><input type="radio" name="is_on_relief" value="1" <%=strTemp%> onclick="toggleRelief('1');"/></td>
								<td width="8%" >Yes</td>
								<%
									if(strTemp.length() == 0)
										strTemp = "checked";
									else
										strTemp = "";
								%>									
								<td width="3%" ><input type="radio" name="is_on_relief" value="0" <%=strTemp%> onclick="toggleRelief('0');"/></td>
								<td width="6%" >No</td>
								<td width="14%" >If yes, specify</td>
								</tr>
							</table>
							</td>
								<td height="21" colspan="2" valign="top">
									<table width="100%" border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td colspan="2"><strong>14</strong> ATC </td>
											</tr>
										<tr>
											<td width="13%" align="right"><img src="images/arrow1.png" width="6" height="6"/></td>
											<%
											if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
												strTemp = (String)vEditInfo.elementAt(10);
											else													
												strTemp = WI.fillTextValue("atc_code");
											%>
											<td width="87%"><input name="atc_code" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="7" size="7" class="textbox_smallfont"
								onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"/></td>
										</tr>
									</table>
								</td>
							</tr>
					</table>
					</td>
					</tr>
			</table>
			</td>
		</tr>
		<tr>
			<td height="19" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
					<tr>
						<td width="13%" height="15" ><strong>Part II</strong></td>
						<td width="74%" align="center"><img src="images/arrow1.png" width="6" height="6"/><strong> Computation of Tax</strong></td>
						<td width="13%" >&nbsp;</td>
					</tr>
			</table></td>
		</tr>
		<tr>
			<td valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
					<tr>
						<td height="17" colspan="2" align="center"><strong>Particulars</strong></td>
						<td colspan="2" align="center"><strong>Amount of Compensation</strong></td>
						<td colspan="2" align="center"><strong>Tax Due</strong></td>
					</tr>
					<tr>
						<td height="17" colspan="2" ><strong>15</strong> Total amount of Compensation</td>
						<td><strong>15</strong></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(11);
							else if (vMonthValues != null && vMonthValues.size() > 0){
								strTemp = (String)vMonthValues.elementAt(0);
							}else
								strTemp = WI.fillTextValue("total_comp");
							
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
						<td><input name="total_comp" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','total_comp');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','total_comp');"
							style="text-align:right" />
						</td>
						<td colspan="2">&nbsp;</td>
					</tr>
					<tr>
						<td height="17" colspan="2" ><strong>16</strong> Less: Non Taxable Compensation</td>
						<td ><strong>16</strong></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(12);
							else if (vMonthValues != null && vMonthValues.size() > 0){
								strTemp = (String)vMonthValues.elementAt(1);
							}else							
								strTemp = WI.fillTextValue("non_tax_comp");

							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";								
						%>						
						<td ><input name="non_tax_comp" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','non_tax_comp');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','non_tax_comp');"
							style="text-align:right" /></td>
						<td colspan="2" >&nbsp;</td>
					</tr>
					<tr>
						<td height="17" colspan="2" ><strong>17</strong> Taxable Compensation</td>
						<td ><strong>17</strong></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(13);
							else if (vMonthValues != null && vMonthValues.size() > 0){
								strTemp = (String)vMonthValues.elementAt(2);
							}else
								strTemp = WI.fillTextValue("taxable_comp");
								
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
						<td ><input name="taxable_comp" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','taxable_comp');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','taxable_comp');"
							style="text-align:right" /></td>
						<td colspan="2" >&nbsp;</td>
					</tr>
					<tr>
						<td height="17" colspan="4" ><strong>18</strong> Tax Required to be Withheld</td>
						<td><strong>18</strong></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(14);
							else if (vMonthValues != null && vMonthValues.size() > 0){
								strTemp = (String)vMonthValues.elementAt(3);
							}else
								strTemp = WI.fillTextValue("to_be_withheld");
								
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
						<td><input name="to_be_withheld" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','to_be_withheld');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','to_be_withheld');"
							style="text-align:right" /></td>
					</tr>
					<tr>
						<td height="17" colspan="4" ><strong>19</strong> Add/Less: Adjustment (from Item 25 of Section A)</td>
						<td ><strong>19</strong></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(15);
							else							
								strTemp = WI.fillTextValue("adjustment");
								
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
						<td><input name="adjustment" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','adjustment');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','adjustment');"
							style="text-align:right" readonly /></td>
					</tr>
					<tr>
						<td height="17" colspan="4" ><strong>20</strong> Tax Required to be Withheld for Remittance</td>
						<td ><strong>20</strong></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(16);
							else							
								strTemp = WI.fillTextValue("for_remittance");
							
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
						<td><input name="for_remittance" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','for_remittance');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','for_remittance');"
							style="text-align:right"/></td>
					</tr>
					<tr>
						<td height="17" colspan="4" ><strong>21</strong> Less: Tax Previously Remitted in Return Previously Filed, if this is an ammended return</td>
						<td ><strong>21</strong></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(17);
							else							
								strTemp = WI.fillTextValue("prev_remittance");
							
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
						<td><input name="prev_remittance" type="text" value="<%=strTemp%>" maxlength="12" size="14" 							
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','prev_remittance');computeStillDue();" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','prev_remittance');computeStillDue()"
							style="text-align:right" class="textbox_smallfont"/></td>
					</tr>
					<tr>
						<td height="17" colspan="4" ><strong>22</strong> Tax Still Due/(Overremittance)</td>
						<td ><strong>22</strong></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(18);
							else							
								strTemp = WI.fillTextValue("tax_due");
								
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
						<td><input name="tax_due" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','tax_due');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','tax_due');"
							style="text-align:right" /></td>
					</tr>
					<tr>
						<td height="14" colspan="6" ><strong>23</strong> Add: Penalties</td>
					</tr>
					<tr>
					  <td>&nbsp;</td>
				    <td colspan="3" >
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="4%">&nbsp;</td>
                <td colspan="2" align="center"><strong>Surcharge</strong></td>
                <td colspan="2" align="center"><strong>Interest</strong></td>
                <td colspan="2" align="center"><strong>Compromise</strong></td>
                </tr>
              <tr>
                <td>&nbsp;</td>
                <td width="7%"><strong>23A</strong></td>
								<%
								if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
									strTemp = (String)vEditInfo.elementAt(19);
								else									
									strTemp = WI.fillTextValue("surcharge");
									
								dTemp = 0d;
								if(strTemp.length() > 0){
									dTemp = Double.parseDouble(strTemp);
								}
								if(dTemp <= 0d)
									strTemp = "";
								%>
                <td width="27%"><input name="surcharge" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','surcharge');computePenalty();" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','surcharge');"
							style="text-align:right"/></td>
                <td width="7%"><strong>23B</strong></td>
								<%
								if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
									strTemp = (String)vEditInfo.elementAt(20);
								else									
									strTemp = WI.fillTextValue("interest");
								
								dTemp = 0d;
								if(strTemp.length() > 0){
									dTemp = Double.parseDouble(strTemp);
								}
								if(dTemp <= 0d)
									strTemp = "";
								%>
                <td width="25%"><input name="interest" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','interest');computePenalty();" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','interest');"
							style="text-align:right" /></td>
                <td width="6%"><strong>23C</strong></td>
								<%
								if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
									strTemp = (String)vEditInfo.elementAt(21);
								else									
									strTemp = WI.fillTextValue("compromise");
								dTemp = 0d;
								if(strTemp.length() > 0){
									dTemp = Double.parseDouble(strTemp);
								}
								if(dTemp <= 0d)
									strTemp = "";
								%>								
                <td width="24%"><input name="compromise" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','compromise');computePenalty();" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','compromise');"
							style="text-align:right"/></td>
                </tr>
            </table></td>
				    <td height="14" ><strong>23D</strong></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(22);
							else							
								strTemp = WI.fillTextValue("total_penalty");
							
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
				    <td valign="bottom"><input name="total_penalty" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_noborder"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','total_penalty');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','total_penalty');"
							style="text-align:right" readonly /></td>
					</tr>
					<tr>
						<td height="17" colspan="4" ><strong>24</strong> Total Amount Still Due/(Overremittance) </td>
						<td><strong>24</strong></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(23);
							else							
								strTemp = WI.fillTextValue("final_due");
								
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
						<td><input name="final_due" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeypress="AllowOnlyFloat('form_','final_due');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','final_due');"
							style="text-align:right" /></td>
					</tr>
					<tr>
					  <td width="2%" height="0"></td>
					  <td width="45%"></td>
					  <td width="4%" ></td>
					  <td width="25%"></td>
					  <td width="4%"></td>
					  <td width="20%"></td>
				  </tr>
			</table>
			</td>
		</tr>
		<tr>
			<td height="18" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
					<tr>
						<td width="13%" height="14" bgcolor="#CCCCCC"><strong>Section A</strong></td>
						<td width="74%" align="center" bgcolor="#CCCCCC"><strong>Adjustment of Taxes Withheld on Compensation For Previous Months</strong></td>
						<td width="13%" align="center" bgcolor="#CCCCCC">&nbsp;</td>
					</tr>
			</table></td>
		</tr>
		<tr>
			<td valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
					<tr>
						<td height="57" colspan="2" align="center" class="borderRightBottom"> Previous Month(s)<br/>
							(1)<br/>
							(MM/YYYY)</td>
						<td align="center" class="borderRightBottom"> Date Paid<br/>
							(2)<br/>
							(MM/DD/YYYY)</td>
						<td width="25%" align="center" class="borderRightBottom"> Bank Validation/<br/>
							ROR No.<br/>
							(3)</td>
						<td width="25%" align="center" class="borderBottomII"> Bank Code<br/>
							(4)<br/>
							&nbsp;</td>
					</tr>
					<tr>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(37);
							else									
								strTemp = WI.fillTextValue("month_1");						
							strTemp = WI.getStrValue(strTemp);
 						%>					
						<td width="9%" height="29" align="center" class="borderRightBottom">
						<select name="month_1">
							<option value="">&nbsp;</option>
							<%for (i = 1; i < astrMonth.length; i++) {
						if (strTemp.equals(Integer.toString(i))){%>
							<option value="<%=i%>" selected><%=astrMonth[i]%></option>
							<%}else{%>
							<option value="<%=i%>"><%=astrMonth[i]%></option>
							<%}
						}%>
						</select></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(38);
							else									
								strTemp = WI.fillTextValue("year_1");			
							strTemp = WI.getStrValue(strTemp);			
 						%>		
						<td width="16%" align="center" class="borderRightBottom">
						<select name="year_1">
							<option value="">&nbsp;</option>
							<%for (i = iCurYear-2; i < (iCurYear+2); i++) {
						if (strTemp.equals(Integer.toString(i))){%>
							<option value="<%=i%>" selected><%=i%></option>
							<%}else{%>
							<option value="<%=i%>"><%=i%></option>
							<%}
						}%>
						</select></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(43);
							else									
								strTemp = WI.fillTextValue("date_paid_1");			
							strTemp = WI.getStrValue(strTemp);			
 						%>								
						<td align="center" class="borderRightBottom"><input name="date_paid_1" type="text" size="12" maxlength="12" readonly="readonly" value="<%=WI.getStrValue(strTemp)%>" class="textbox_smallfont"
	 					 onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
              <a href="javascript:show_calendar('form_.date_paid_1');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0" /></a></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(46);
							else									
								strTemp = WI.fillTextValue("validation_1");			
							strTemp = WI.getStrValue(strTemp);			
 						%>	
						<td align="center" class="borderRightBottom">
						<input name="validation_1" type="text" value="<%=strTemp%>" maxlength="32" size="20" class="textbox_smallfont"
						onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"/></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(49);
							else									
								strTemp = WI.fillTextValue("bank_code_1");			
							strTemp = WI.getStrValue(strTemp);			
 						%>	
						<td align="center" class="borderBottomII"><input name="bank_code_1" type="text" value="<%=strTemp%>" maxlength="32" size="20" class="textbox_smallfont"
						onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"/></td>
					</tr>
					<tr>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(39);
							else									
								strTemp = WI.fillTextValue("month_2");
							strTemp = WI.getStrValue(strTemp);
						%>						
						<td height="31" align="center" class="borderRightBottom"><select name="month_2">
							<option value="">&nbsp;</option>
							<%for (i = 1; i < astrMonth.length; i++) {
						if (strTemp.equals(Integer.toString(i))){%>
							<option value="<%=i%>" selected><%=astrMonth[i]%></option>
							<%}else{%>
							<option value="<%=i%>"><%=astrMonth[i]%></option>
							<%}
						}%>
						</select></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(40);
							else									
								strTemp = WI.fillTextValue("year_2");				
							strTemp = WI.getStrValue(strTemp);		
						%>	
						<td height="31" align="center" class="borderRightBottom"><select name="year_2">
							<option value="">&nbsp;</option>
							<%for (i = iCurYear-2; i < (iCurYear+2); i++) {
						if (strTemp.equals(Integer.toString(i))){%>
							<option value="<%=i%>" selected><%=i%></option>
							<%}else{%>
							<option value="<%=i%>"><%=i%></option>
							<%}
						}%>
						</select></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(44);
							else									
								strTemp = WI.fillTextValue("date_paid_2");			
							strTemp = WI.getStrValue(strTemp);			
 						%>							
						<td height="31" align="center" class="borderRightBottom"><input name="date_paid_2" type="text" size="12" maxlength="12" readonly="readonly" value="<%=WI.getStrValue(strTemp)%>" class="textbox_smallfont"
	 					 onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
              <a href="javascript:show_calendar('form_.date_paid_2');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0" /></a></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(47);
							else									
								strTemp = WI.fillTextValue("validation_2");			
							strTemp = WI.getStrValue(strTemp);			
 						%>	
						<td height="31" align="center" class="borderRightBottom"><input name="validation_2" type="text" value="<%=strTemp%>" maxlength="32" size="20" class="textbox_smallfont"
						onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"/></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(50);
							else									
								strTemp = WI.fillTextValue("bank_code_2");			
							strTemp = WI.getStrValue(strTemp);			
 						%>	
						<td height="31" align="center" class="borderBottomII"><input name="bank_code_2" type="text" value="<%=strTemp%>" maxlength="32" size="20" class="textbox_smallfont"
						onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"/></td>
					</tr>
					<tr>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(41);
							else									
								strTemp = WI.fillTextValue("month_3");		
							strTemp = WI.getStrValue(strTemp);				
						%>						
						<td height="30" align="center" class="borderRight"><select name="month_3">
							<option value="">&nbsp;</option>
							<%for (i = 1; i < astrMonth.length; i++) {
						if (strTemp.equals(Integer.toString(i))){%>
							<option value="<%=i%>" selected><%=astrMonth[i]%></option>
							<%}else{%>
							<option value="<%=i%>"><%=astrMonth[i]%></option>
							<%}
						}%>
						</select></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(42);
							else									
								strTemp = WI.fillTextValue("year_3");		
							strTemp = WI.getStrValue(strTemp);				
						%>			
						<td height="30" align="center" class="borderRight"><select name="year_3">
							<option value="">&nbsp;</option>
							<%for (i = iCurYear-2; i < (iCurYear+2); i++) {
						if (strTemp.equals(Integer.toString(i))){%>
							<option value="<%=i%>" selected><%=i%></option>
							<%}else{%>
							<option value="<%=i%>"><%=i%></option>
							<%}
						}%>
						</select></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(45);
							else									
								strTemp = WI.fillTextValue("date_paid_3");			
							strTemp = WI.getStrValue(strTemp);			
 						%>							
						<td height="30" align="center" class="borderRight"><input name="date_paid_3" type="text" size="12" maxlength="12" readonly="readonly" value="<%=WI.getStrValue(strTemp)%>" class="textbox_smallfont"
	 					 onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
              <a href="javascript:show_calendar('form_.date_paid_3');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0" /></a></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(48);
							else									
								strTemp = WI.fillTextValue("validation_3");			
							strTemp = WI.getStrValue(strTemp);			
 						%>	
						<td height="30" align="center" class="borderRight"><input name="validation_3" type="text" value="<%=strTemp%>" maxlength="32" size="20" class="textbox_smallfont"
						onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"/></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(51);
							else									
								strTemp = WI.fillTextValue("bank_code_3");			
							strTemp = WI.getStrValue(strTemp);			
 						%>	
						<td height="30" align="center"><input name="bank_code_3" type="text" value="<%=strTemp%>" maxlength="32" size="20" class="textbox_smallfont"
						onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"/></td>
					</tr>
			</table></td>
		</tr>
		<tr>
			<td height="19" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
					<tr>
						<td width="21%" height="14" bgcolor="#CCCCCC"><strong>Section A (Continuation)</strong></td>
						<td width="66%" align="center" bgcolor="#CCCCCC">&nbsp;</td>
						<td width="13%" align="center" bgcolor="#CCCCCC">&nbsp;</td>
					</tr>
			</table></td>
		</tr>
		<tr>
			<td height="178" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
					<tr>
						<td width="25%" rowspan="2" align="center" class="borderRightBottom"> Tax Paid (Excluding Penalties)<br/>
							for the month<br/>
							(5)</td>
						<td colspan="2" rowspan="2" align="center" class="borderRightBottom"> Should Be Tax Due<br/>
							for the Month<br/>
							(6)</td>
						<td height="23" colspan="2" align="center" class="borderBottomII">Adjustment (7)</td>
					</tr>
					<tr>
						<td width="24%" height="29" align="center" class="borderRightBottom">From Current Year <br/>
							(7a)</td>
						<td width="26%" align="center" class="borderBottomII"> From Year - End Adjustment of the<br/>
							Immediately Preceeding Year (7)</td>
					</tr>
					<tr>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(52);
							else									
								strTemp = WI.fillTextValue("tax_paid_1");			
							strTemp = WI.getStrValue(strTemp);			
 						%>						
						<td height="29" align="center" class="borderRightBottom"><input name="tax_paid_1" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','tax_paid_1');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','tax_paid_1');"
							style="text-align:right" /></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(55);
							else									
								strTemp = WI.fillTextValue("tax_due_1");			
							strTemp = WI.getStrValue(strTemp);			
 						%>								
						<td colspan="2" align="center" class="borderRightBottom"><input name="tax_due_1" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','tax_due_1');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','tax_due_1');"
							style="text-align:right" /></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(58);
							else									
								strTemp = WI.fillTextValue("adjust_1");			
							strTemp = WI.getStrValue(strTemp);	
							if(strTemp.length() > 0)	
								dSectionATotal += Double.parseDouble(strTemp);
 						%>							
						<td align="center" class="borderRightBottom"><input name="adjust_1" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','adjust_1');computeSectionA();" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','adjust_1');computeSectionA();"
							style="text-align:right" /></td>
					<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(61);
							else									
								strTemp = WI.fillTextValue("adjust_prev_1");			
							strTemp = WI.getStrValue(strTemp);			
							if(strTemp.length() > 0)	
								dSectionATotal += Double.parseDouble(strTemp);
 						%>
						<td align="center" class="borderBottomII">
						<input name="adjust_prev_1" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','adjust_prev_1');computeSectionA();" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','adjust_prev_1');computeSectionA();"
							style="text-align:right" /></td>
					</tr>
					<tr>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(53);
							else									
								strTemp = WI.fillTextValue("tax_paid_2");			
							strTemp = WI.getStrValue(strTemp);			
 						%>						
						<td height="29" align="center" class="borderRightBottom"><input name="tax_paid_2" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','tax_paid_2');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','tax_paid_2');"
							style="text-align:right" /></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(56);
							else									
								strTemp = WI.fillTextValue("tax_due_2");			
							strTemp = WI.getStrValue(strTemp);			
 						%>								
						<td colspan="2" align="center" class="borderRightBottom"><input name="tax_due_2" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','tax_due_2');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','tax_due_2');"
							style="text-align:right" /></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(59);
							else									
								strTemp = WI.fillTextValue("adjust_2");			
							strTemp = WI.getStrValue(strTemp);			
							if(strTemp.length() > 0)	
								dSectionATotal += Double.parseDouble(strTemp);
 						%>								
						<td align="center" class="borderRightBottom"><input name="adjust_2" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','adjust_2');computeSectionA();" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','adjust_2');computeSectionA();"
							style="text-align:right" /></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(62);
							else									
								strTemp = WI.fillTextValue("adjust_prev_2");			
							strTemp = WI.getStrValue(strTemp);			
							if(strTemp.length() > 0)	
								dSectionATotal += Double.parseDouble(strTemp);
 						%>
						<td align="center" class="borderBottomII"><input name="adjust_prev_2" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','adjust_prev_2');computeSectionA();" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','adjust_prev_2');computeSectionA();"
							style="text-align:right" /></td>
					</tr>
					<tr>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(54);
							else									
								strTemp = WI.fillTextValue("tax_paid_3");			
							strTemp = WI.getStrValue(strTemp);			
 						%>						
						<td height="29" align="center" class=" borderRightBottom"><input name="tax_paid_3" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','tax_paid_3');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','tax_paid_3');"
							style="text-align:right" /></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(57);
							else									
								strTemp = WI.fillTextValue("tax_due_3");			
							strTemp = WI.getStrValue(strTemp);			
 						%>								
						<td colspan="2" align="center" class=" borderRightBottom"><input name="tax_due_3" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','tax_due_3');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','tax_due_3');"
							style="text-align:right" /></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(60);
							else									
								strTemp = WI.fillTextValue("adjust_3");			
							strTemp = WI.getStrValue(strTemp);			
							if(strTemp.length() > 0)	
								dSectionATotal += Double.parseDouble(strTemp);
 						%>								
						<td align="center" class=" borderRightBottom"><input name="adjust_3" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','adjust_3');computeSectionA();" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','adjust_3');computeSectionA();"
							style="text-align:right" /></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(63);
							else									
								strTemp = WI.fillTextValue("adjust_prev_3");			
							strTemp = WI.getStrValue(strTemp);			
							if(strTemp.length() > 0)	
								dSectionATotal += Double.parseDouble(strTemp);
 						%>
						<td align="center" class="borderBottomII"><input name="adjust_prev_3" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','adjust_prev_3');computeSectionA();" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','adjust_prev_3');computeSectionA();"
							style="text-align:right" /></td>
					</tr>
					<tr>
						<td height="27" colspan="2" ><strong>25</strong> Total (7a plus 7b) (To Item 19)</td>
						<%
							strTemp = CommonUtil.formatFloat(dSectionATotal, 2);			
 						%>	
						<td colspan="3" align="center"><input name="adjust_total" type="text" value="<%=strTemp%>" maxlength="13" size="16" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','adjust_total');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','adjust_total');"
							style="text-align:right" /></td>
					</tr>
					<tr>
						<td height="0"></td>
						<td width="17%"></td>
						<td></td>
						<td></td>
						<td></td>
					</tr>
					<tr>
						<td height="1"></td>
						<td></td>
						<td width="8%"></td>
						<td></td>
						<td></td>
					</tr>
			</table></td>
		</tr>
		<tr>
			<td height="145" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
					<tr>
						<td colspan="2">
						<pre style="font-family:Arial, Verdana, Helvetica, sans-serif;font-size:10px;">
            I declare, under the penalties of perjury, that this return has been made in good faith, verified me, and to the best of my knowledge and belief, 
 is true and correct, pursuant to the provisions of the National Internal Revenue Code, as amended, and the regulations issued under authority thereof.</pre></td>
					</tr>
					<tr>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(24);
							else							
								strTemp = WI.fillTextValue("signatory");
						%>
						<td width="364" height="22" align="center"><strong>26</strong>&nbsp;
					  <input name="signatory" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="128" size="40" class="textbox_smallfont"
								onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" style="width:auto"/></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(25);
							else							
								strTemp = WI.fillTextValue("position");
						%>
						<td width="368" align="center"><strong>27</strong>&nbsp;
								<input name="position" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="128" size="40" class="textbox_smallfont"
								onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" style="width:auto"/></td>
					</tr>
					<tr>
						<td height="23" align="center"> Signature over printed name of Taxpayer/<br/>
							Authorized Representative</td>
						<td width="368" align="center">Title/Position of Signatory</td>
					</tr>
					<tr>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(26);
							else							
								strTemp = WI.fillTextValue("agent_tin");
						%>
						<td height="23" align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<input name="agent_tin" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="128" size="40" class="textbox_smallfont"
								onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" style="width:auto"/></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(27);
							else							
								strTemp = WI.fillTextValue("accreditation_no");
						%>
						<td height="23" align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<input name="accreditation_no" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="128" size="40" class="textbox_smallfont"
								onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" style="width:auto"/></td>
					</tr>
					<tr>
						<td height="23" align="center">TIN of Tax Agent (If applicable)</td>
						<td height="23" align="center">Tax Agent Accreditation No. (If applicable)</td>
					</tr>
			</table></td>
		</tr>
		<tr>
			<td height="19" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
					<tr>
						<td width="10%" height="15" bgcolor="#CCCCCC"><strong>Part III</strong></td>
						<td width="77%" align="center" bgcolor="#CCCCCC"><strong>Details of Payment</strong></td>
						<td width="13%" align="center" bgcolor="#CCCCCC">&nbsp;</td>
					</tr>
			</table></td>
		</tr>
		<tr>
			<td height="131" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
					<tr>
						<td width="15%" height="27" rowspan="2" align="center" valign="bottom" class="borderRightBottom"><strong >Particulars</strong></td>
						<td colspan="2" rowspan="2" align="center" class="borderRightBottom"><strong>Drawee Bank/<br/>
							Agency</strong></td>
						<td colspan="2" rowspan="2" align="center" valign="bottom" class="borderRightBottom"><strong>Number</strong></td>
						<td align="center">&nbsp;</td>
						<td width="6%" align="center" class="borderBottomII">&nbsp;</td>
						<td align="center" class="borderBottomII"><strong>Date</strong></td>
						<td align="center" class="borderRightBottom">&nbsp;</td>
						<td colspan="2" rowspan="2" align="center" valign="bottom" class="borderBottomII"><strong >Amount</strong></td>
						<td width="18%" rowspan="5" align="center" valign="top" class="borderLeft">Stamp of Receiving<br/>
							Office and Date of<br/>
						Receipt</td>
					</tr>
					<tr>
						<td align="center" class="borderRightBottom">&nbsp;</td>
						<td align="center" class="borderRightBottom"><strong>MM</strong></td>
						<td width="6%" align="center" class="borderRightBottom"><strong>DD</strong></td>
						<td width="7%" align="center" class="borderRightBottom"><strong>YYYY</strong></td>
					</tr>
					<tr>
						<td height="28" valign="top"><strong>28</strong> Cash/Bank<br/>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Debit Memo</td>
						<td height="28" colspan="2" >&nbsp;</td>
						<td height="28" colspan="2" >&nbsp;</td>
						<td height="28" colspan="4" >&nbsp;</td>
						<td width="3%" height="28" align="right" ><strong>28</strong><br/>
						<img src="images/arrow1.png"/></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(28);
							else							
								strTemp = WI.fillTextValue("cash_amt");
								
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
						<td width="13%"><input name="cash_amt" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','cash_amt');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','cash_amt');"
							style="text-align:right" /></td>
					</tr>
					<tr>
						<td height="26" ><strong>29</strong> Check</td>
						<td width="3%" height="26" align="right" ><strong>29A</strong><br/>
						<img src="images/arrow1.png"/></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(29);
							else	
								strTemp = WI.fillTextValue("check_drawee");
						%>							
						<td width="13%" height="26" ><input name="check_drawee" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'; "/></td>
						<td width="3%" height="26" align="right" ><strong>29B</strong><br/>
						<img src="images/arrow1.png"/></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(30);
							else	
								strTemp = WI.fillTextValue("check_no");
						%>								
						<td width="10%" ><input name="check_no" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'; "/></td>
						<td width="3%" height="26" align="right" ><strong>29C</strong><br/>
						<img src="images/arrow1.png"/></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(31);
							else	
								strTemp = WI.fillTextValue("check_date");
						%>	
						<td height="26" colspan="3" >
						<input name="check_date" type="text" size="12" maxlength="12" readonly="readonly" value="<%=WI.getStrValue(strTemp)%>" class="textbox_smallfont"
	 					 onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
              <a href="javascript:show_calendar('form_.check_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0" /></a></td>
						<td height="26" align="right" ><strong>29D</strong><br/>
								<img src="images/arrow1.png"/></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(32);
							else	
								strTemp = WI.fillTextValue("check_amt");
							
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>									
						<td height="26" ><input name="check_amt" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','check_amt');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','check_amt');"
							style="text-align:right" /></td>
					</tr>
					<tr>
						<td height="22" ><strong>30</strong> Others</td>
						<td height="22" align="right" ><strong>30A</strong><br/>
								<img src="images/arrow1.png"/></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(33);
							else	
								strTemp = WI.fillTextValue("other_drawee");
						%>									
						<td height="22" ><input name="other_drawee" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white';"/></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(34);
							else	
								strTemp = WI.fillTextValue("other_no");
						%>		
						<td height="22" align="right" ><strong>30B</strong><br/>
								<img src="images/arrow1.png"/></td>
						<td height="22" ><input name="other_no" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'"  onblur="style.backgroundColor='white'; "/></td>
						<td height="22" align="right" ><strong>30C</strong><br/>
								<img src="images/arrow1.png"/></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(35);
							else	
								strTemp = WI.fillTextValue("other_date");
						%>									
						<td height="22" colspan="3" ><input name="other_date" type="text" size="12" maxlength="12" readonly="readonly" value="<%=WI.getStrValue(strTemp)%>" class="textbox_smallfont"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
              <a href="javascript:show_calendar('form_.other_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0" /></a></td>
						<td height="22" align="right" ><strong>29D</strong><br/>
								<img src="images/arrow1.png"/></td>
						<%
							if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded)
								strTemp = (String)vEditInfo.elementAt(36);
							else	
								strTemp = WI.fillTextValue("other_amt");
							
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>									
						<td height="22" ><input name="other_amt" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','other_amt');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','other_amt');"
							style="text-align:right" /></td>
					</tr>
			</table></td>
		</tr>
		<tr>
			<td height="56" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td width="732" height="57" valign="top" bgcolor="#FFFFFF">Machine Validation/Revenue Official Receipt Details(If not filed with the bank)</td>
					</tr>
			</table></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="21" colspan="3" valign="top">
			<%if(vEditInfo == null || vEditInfo.size() == 0){%>
        <font size="1">
        <input type="button" name="122" value=" SAVE " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onclick="javascript:SaveRecord();" />
click to save form 1601c 
<%}else{
			strTemp = (String)vEditInfo.elementAt(0);
		%>
<input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onclick="javascript:EditRecord(<%=strTemp%>);" />
to save changes
<input type="button" name="edit2" value="  Delete  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onclick="javascript:DeleteRecord(<%=strTemp%>);" />
to delete saved 1601c
<%}%>
<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onclick="javascript:CancelRecord();" />
click to clear </font></td>
		</tr>		
		<tr>
			<td width="29%" rowspan="3" align="center"></td>
			<td height="14" align="center"></td>
			<td width="34%" rowspan="3" align="center"></td>
		</tr>
		<tr>
			<td width="37%" height="26" align="center"><a href="javascript:PrintPage();"><img src="images/print.png" width="31" height="26" hspace="3" border="0"/></a>Print this Form</td>
		</tr>
		<tr>
			<td height="24" align="center">&nbsp; </td>
		</tr>
		<tr>
			<td height="23" colspan="3" align="center" valign="top">&nbsp;</td>
		</tr>
 </table>
	<%}%>
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="is_reloaded">	
	<input type="hidden" name="print_pg">
</form>	
</body>
</html>
<%
dbOP.cleanUP();
%>