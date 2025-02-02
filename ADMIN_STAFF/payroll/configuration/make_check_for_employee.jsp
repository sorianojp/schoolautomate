<%@ page language="java" import="utility.*,java.util.Vector, payroll.PRSalaryExtn,payroll.PReDTRME" buffer="16kb"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
WebInterface WI = new WebInterface(request);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Make Check for Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
TD.thinborderBOTTOMRIGHT {
	border-right: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBOTTOM{
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOMLEFTRIGHT{
	border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.noBorder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.smallFont{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.smallFontTop{
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function SearchEmployee(){	
	document.form_.searchEmployee_.value="1";
	document.form_.print_page.value=""; 	
	this.SubmitOnce("form_");
}

function ReloadPage(){
	this.SubmitOnce("form_");
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.searchEmployee_.value="1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function DeleteRecord(){
  var vProceed = confirm('Delete records?');
  if(vProceed){
		document.form_.page_action.value = "0";
		document.form_.searchEmployee_.value = "1";
		document.form_.print_page.value = "";
		this.SubmitOnce("form_");
  }	
}
function CancelCheck(){
  var vProceed = confirm('Cancel check?');
  if(vProceed){
		document.form_.page_action.value = "2";
		document.form_.searchEmployee_.value = "1";
		document.form_.print_page.value = "";
		this.SubmitOnce("form_");
  }	
}

function PrepareToEdit(strInfoIndex,strPayable){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./make_check_for_employee.jsp";
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}


function SaveRequests(){
	document.form_.page_action.value = "1";
	//document.dtr_op.viewAll.value="1";
	document.form_.submit();
}
function loadSalPeriods() {
	var strMonth = document.form_.month_of.value;
	var strYear = document.form_.year_of.value;
	var strWeekly = null;
	
	if(document.form_.is_weekly){
		if(document.form_.is_weekly.checked)
			strWeekly = "1";
		else
			strWeekly = "";
	}
	
	var objCOAInput = document.getElementById("sal_periods");
	
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=301&month_of="+strMonth+
							 "&year_of="+strYear+"&is_weekly="+strWeekly;

	this.processRequest(strURL);
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
	document.getElementById("coa_info").innerHTML = "";
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}

function CopyRate(strBase){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	
		
		if(strBase == '0'){
			for (var i = 1 ; i < eval(vItems);++i)
				eval('document.form_.monthly_'+i+'.value=document.form_.monthly_1.value');			
		}else if(strBase == '1'){
			for (var i = 1 ; i < eval(vItems);++i)
				eval('document.form_.daily_'+i+'.value=document.form_.daily_1.value');					
		}else{
			for (var i = 1 ; i < eval(vItems);++i)
				eval('document.form_.hourly_'+i+'.value=document.form_.hourly_1.value');		
		}
}
-->
</script>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	String strHasWeekly = null;
	String strAllowanceName = WI.fillTextValue("allowance_name");
	boolean bolAllowOverride = false;
	boolean bolCheckDate = false;
//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="employee_allowances_print.jsp" />
<% return;}

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-CONFIGURATION"),"0"));
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
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Variable Allowance-Variable Allowance Management","employee_allowances.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolAllowOverride = (readPropFile.getImageFileExtn("ALLOWANCE_OVERRIDE","0")).equals("1");
		bolCheckDate = (readPropFile.getImageFileExtn("CHECK_ALLOWANCES_DATE","0")).equals("1");
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

//end of authenticaion code.
	Vector vRetResult = null;
	PRSalaryExtn prSalExtn = new PRSalaryExtn();
	PReDTRME prEdtrME = new PReDTRME();
	Vector vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	String strPayrollPeriod  = null;
	String strPayEnd = null;
 	String strPageAction = WI.fillTextValue("page_action");
	String strTemp2 = null;
	String strEmpCatg = null;
	String[] astrCategory = {"Staff","Faculty","Employees"};
	String[] astrStatus = {"Part-Time","Full-Time","Contractual",""}; 
	if(bolIsSchool)
		strTemp2 = "College";
	else
		strTemp2 = "Division";
	String[] astrSortByName    = {"Employee ID","Firstname",strTemp2,"Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","c_name","d_name"};
	
	String[] astrBasis={"Fixed Allowance","Present","Absences", "Hours Present"};

	String[] astrActualName ={"Every Salary Period","Monthly (Every Last Period of the Month)", 
												"Quarterly (Every Last Period of the Quarter)",
												"Bi-annual (June &amp; December)","Monthly (Every First Period)"};
	boolean bolHasItems = false;
	int iCount = 1;
	int i = 0;	
	boolean bolFixed = false;
	boolean bolHasSavedCheck = false;
	double dTemp = 0d;
	String strLine = null;
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		vRetResult = prSalExtn.operateOnCheckManagement(dbOP, request, Integer.parseInt(strTemp));
		if(vRetResult == null)
			strErrMsg = prSalExtn.getErrMsg();
		else
			strErrMsg = "Operation Succesful";
	} 	
	
		vRetResult = prSalExtn.operateOnCheckManagement(dbOP,request,4);
		
		if (vRetResult == null){
			strErrMsg = prSalExtn.getErrMsg();	
		}else{
			if( ((String)vRetResult.elementAt(7)).equals("1") )
				bolHasSavedCheck = true;
		}
		
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="make_check_for_employee.jsp" name="form_" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: CHECK MAKING FOR EMPLOYEE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0"> 
  	<tr> 
      <td height="28" colspan="5"><font size="2" color="#FF0000"><strong>&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>  
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employee ID </td>
			<%
				strTemp = WI.fillTextValue("emp_id");
			%>
      <td colspan="3"><input name="emp_id" type="text" class="textbox" value="<%=WI.getStrValue(strTemp,"")%>" size="16" maxlength="16"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
      <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
			<label id="coa_info"></label></td>
   </tr>  
	<tr> 
      <td height="25">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td colspan="3"> <select name="month_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>
        (Must be filled up to display salary period information)</td>
    </tr>
	 <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="21%">Salary Period</td>
      <td width="77%" colspan="3"><strong>
			<label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px">
        <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");		
		
		for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
			if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += "Whole Month";
			}else{
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			}
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
			strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - " + (String)vSalaryPeriod.elementAt(i + 7);
			strPayEnd = (String)vSalaryPeriod.elementAt(i + 7);
		%>
          <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"> 
          <%=strTemp2%> </option>
          <%}else{%>
          <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"> 
          <%=strTemp2%></option>
          <%}//end of if condition.		  
		 }//end of for loop.%>
        </select>
		</label>
        </strong>
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
        <%}// check if the company has weekly salary type%>      </td>
    </tr>
	 <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">
				<!--
				<input name="image" type="image" onClick="ReloadPage()" src="../../../images/form_proceed.gif"> 
				-->
				<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="javascript:SearchEmployee();">
				<font size="1">click to display employee list to print.</font></td>
    </tr>  
	<tr>
		  <td height="25" colspan="7" align="center">&nbsp;</td>
	</tr>  
  </table>	
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
   <input type="hidden" name="amount" value='<%=(String)vRetResult.elementAt(8)%>'>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">  
    <tr> 
      <td height="25" colspan="7" align="center" bgcolor="#B9B292"><strong>EMPLOYEE INFO </strong></td>
    </tr>
    <tr>       
      <td width="9%" align="center" class="thinborderBOTTOMRIGHT" height="20"><font size="1"><strong>EMPLOYEE ID </strong></font></td>
      <td width="18%" align="center" class="thinborderBOTTOMRIGHT"><font size="1"><strong>EMPLOYEE NAME </strong></font></td>
      <td width="19%" align="center" class="thinborderBOTTOMRIGHT"><font size="1"><strong>DEPARTMENT/OFFICE </strong></font></td>
	  <td width="12%" align="center" class="thinborderBOTTOMRIGHT"><font size="1"><strong>AMOUNT </strong></font></td>
	  <%if(bolHasSavedCheck){ //no check saved yet%>
	 	 <td width="14%" align="center" class="thinborderBOTTOMRIGHT"><font size="1"><strong>CHECK NO </strong></font></td>
 	 	 <td width="13%" align="center" class="thinborderBOTTOMRIGHT"><font size="1"><strong>BANK </strong></font></td>
		 <td width="15%" align="center" class="thinborderBOTTOMRIGHT"><font size="1"><strong>REMARKS </strong></font></td>		 
      <%}%>	
	</tr>
	
    <tr>      
			<td class="thinborderBOTTOMRIGHT" height="25"><span class="thinborder" >&nbsp;<%=(String)vRetResult.elementAt(1)%></span></td>
			<td class="thinborderBOTTOMRIGHT"><font size="1"><strong>&nbsp;<%=WI.formatName((String)vRetResult.elementAt(2), (String)vRetResult.elementAt(3),
							(String)vRetResult.elementAt(4), 4).toUpperCase()%></strong></font></td>       						
			<td class="thinborderBOTTOMRIGHT">
				<span class="thinborder">
					&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(5),"")%><%=WI.getStrValue((String)vRetResult.elementAt(6),"")%>				</span>			</td>	 
			<td class="thinborderBOTTOMRIGHT"><span class="thinborder">&nbsp; 
			<%=WI.getStrValue(CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(8),"0"),true),"0")%></span></td>
			<%if(bolHasSavedCheck){ //no check saved yet%>
				<td class="thinborderBOTTOMRIGHT"><span class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(10)%></span></td>
				<td class="thinborderBOTTOMRIGHT"><span class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(11)%></span></td>
				<td class="thinborderBOTTOMRIGHT"><span class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(12),"")%></span></td>
				<input type="hidden" name="check_index" value='<%=(String)vRetResult.elementAt(9)%>'> 	
			<%}%>	 
	</tr>
  </table> 
  
  <!---------------- start of buttons -------------->
   <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
   
   <tr>
		  <td height="25" colspan="7" align="center">&nbsp;</td>
	 </tr>
   <%if(!bolHasSavedCheck){ %> 
		<tr>
		  <td width="2%" height="25">&nbsp;</td>
		  <td height="25" colspan="5">Check Deatails</td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td width="2%" height="25">&nbsp;</td>
		  <td width="18%" height="25">
		  	Check Number</td>
		  <td>	
		  	<input type="text" name="check_number" value="<%=WI.fillTextValue("check_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">		  
		  </td>
		</tr>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td height="25">&nbsp;</td>
		  <td height="25">Select Bank </td>
		  <td width="78%">
		  <%
				strTemp = WI.fillTextValue("bank_index");		
		  %>     
			 <select name="bank_index">
			 <%=dbOP.loadCombo("BANK_INDEX","BANK_NAME, BRANCH", 
														" from FA_BANK_LIST where is_valid = 1 " +
														" order by BANK_NAME", strTemp, false)%> 
	      </select></td>
	 </tr>
	 <tr>
		  <td height="25">&nbsp;</td>
		  <td width="2%" height="25">&nbsp;</td>
		  <td width="18%" height="25">
		  	Remarks </td>
		  <td>	
		  <% 
			strTemp = WI.fillTextValue("remarks"); 
		  %> 
		  	<textarea name="remarks" cols="48" rows="3" class="textbox" 
	  onfocus="CharTicker('form_','256','remarks','count_');style.backgroundColor='#D3EBFF'" 
	  onBlur ="CharTicker('form_','256','remarks','count_');style.backgroundColor='white'" 
	  onkeyup="CharTicker('form_','256','remarks','count_');"><%=strTemp%></textarea>
              <br>
              <font size="1">Available Characters</font> 
              <input name="count_" type="text" class="textbox_noborder" size="5" maxlength="5" readonly="yes" tabindex="-1">
		  </td>
	 </tr>
	<%}else{%>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td width="2%" height="25">&nbsp;</td>
		  <td width="18%" height="25">
		  	Reason if cancelled:</td>
		  <td>	
		  <% 
			strTemp = WI.fillTextValue("cancel_reason"); 
		  %> 
		  	<textarea name="cancel_reason" cols="48" rows="3" class="textbox" 
	  onfocus="CharTicker('form_','256','cancel_reason','count_');style.backgroundColor='#D3EBFF'" 
	  onBlur ="CharTicker('form_','256','cancel_reason','count_');style.backgroundColor='white'" 
	  onkeyup="CharTicker('form_','256','cancel_reason','count_');"><%=strTemp%></textarea>
              <br>
              <font size="1">Available Characters</font> 
              <input name="count_" type="text" class="textbox_noborder" size="5" maxlength="5" readonly="yes" tabindex="-1">
		  </td>
		</tr>
	<%}%>
	 <tr>
      <td height="25" colspan="7" align="center">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="7" align="center">

			<%if(bolHasSavedCheck){
					if(iAccessLevel == 2){%>
				<input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord();">
				<font size="1">Click to delete selected </font>
				<input type="button" name="cancel_check" value=" Cancel Check " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:CancelCheck();">
        <font size="1"> click to cancel check </font>	
				<%}
				}else{
					if(iAccessLevel > 1){%>				
        <input type="button" name="122" value=" Save " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SaveRequests();">
        <font size="1">click to save entries</font>			 		  
        <%}
				}%>
		<input type="button" name="1223" value=" Reload " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:CancelRecord();">
        <font size="1"> click to reload </font>			
   		</td>
    </tr>   
  </table>
  
  <!-- end of buttons -->
   <%}//end vRetResult != null%>
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="print_page">
<input type="hidden" name="searchEmployee_"> 
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>