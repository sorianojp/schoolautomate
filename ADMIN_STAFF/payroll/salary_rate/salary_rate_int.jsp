<%@ page language="java" import="utility.*,payroll.PRSalaryRate, java.util.Vector, 
																 payroll.PRMiscDeduction, payroll.PRConfidential, payroll.PReDTRME" %>
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
<title>Salary Rate</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/builtin.js"></script>
<script language="JavaScript">
//called for add or edit.
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0 ){
		document.form_.info_index.value = strInfoIndex;
	}
	if(strAction == 1)
		document.form_.save.disabled = true;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage() {
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddAddlRes() {
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "./salary_rate_addl.jsp?emp_id="+document.form_.emp_id.value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPg() {
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}

	var pgLoc = "./salary_rate_print.jsp?emp_id="+document.form_.emp_id.value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}

function FocusID() {
	document.form_.emp_id.focus();
}

function ComputeRates(){
	var iDivVal = document.form_.days_per_month.value;
	//iDivVal = document.form_.days_per_month[document.form_.days_per_month.selectedIndex].value;

	if(iDivVal.length == 0)
		return;
		
	if (document.form_.basic_salary.value.length > 0){
		if (eval(document.form_.basic_salary.value) != 0){
			document.form_.daily_sal.value = eval(document.form_.basic_salary.value)/iDivVal;
			document.form_.daily_sal.value = truncateFloat(document.form_.daily_sal.value,1,false);

			//iDivVal = document.form_.hrs_per_day[document.form_.hrs_per_day.selectedIndex].value;
			iDivVal = document.form_.hrs_per_day.value;
			if(iDivVal.length == 0)
				return;
			document.form_.hourly_sal.value = eval(document.form_.daily_sal.value)/iDivVal;
			document.form_.hourly_sal.value = truncateFloat(document.form_.hourly_sal.value,1,false);
		}
	 }else{
		 document.form_.daily_sal.value ="0";
		 document.form_.hourly_sal.value ="0";
	 }

/**
	if (document.form_.daily_sal.value.length > 0){
		if (eval(document.form_.daily_sal.value) !=0){
			document.form_.hourly_sal.value = eval(document.form_.daily_sal.value)/iDivVal;
			document.form_.hourly_sal.value = truncateFloat(document.form_.hourly_sal.value,1,false);
		}
	 }else{
	 }
**/
}

function CopyID(strID){
	ClearFields();
	document.form_.print_page.value="";
	document.form_.emp_id.value=strID;
	this.SubmitOnce("form_");

}

function CancelRecord(){
	location = "salary_rate_int.jsp?info_index="+document.form_.info_index.value+
							"&prepareToEdit=1&emp_id="+document.form_.emp_id.value;
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	document.all.ajax_.style.visibility = "visible";
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
	document.all.ajax_.style.visibility = "hidden";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function UpdateBanks() {
	var pgLoc = "./bank_list_for_check.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=700,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ShowHideHourlyOpt(strBasis){
	if(strBasis == "")
		return;
	var vChecked = '0';
	
 	if(strBasis == '0'){		
		if(document.form_.use_hourly)
			document.form_.use_hourly.disabled = false;
	} else if(strBasis == '1') {
		if(document.form_.use_hourly){
			document.form_.use_hourly.disabled = true;
			document.form_.use_hourly.checked = false;
		}
	} else if(strBasis == '2'){
		if(document.form_.use_hourly){
			document.form_.use_hourly.disabled = true;
			document.form_.use_hourly.checked = false;
		}
	}

 	if(!document.form_.use_hourly)
		vChecked = '0';
	else{
		if(document.form_.use_hourly.checked)
			vChecked = "1";
	}
}

function UpdateNote(){
	if(!document.form_.holiday_opt)
		return;
	var vSelected = document.form_.holiday_opt.value;
	
 	if(vSelected == '0'){		
 		document.getElementById("note").innerHTML = 
				"<font size='1'><strong>No application needed</strong><br>"+
				"Employee automatically receives the additional percentage during holidays.<br>" +
				"The additional percentage is based on the value set in the holiday management page.</font>";
	} else if(vSelected == '1') {
 		document.getElementById("note").innerHTML = 
				"<font size='1'><strong>No application, no additional pay</strong><br>" +
				"The employee will not receive any additional pay if no application is filed</font>";
	}
}
function ClearFields(){
	document.form_.valid_fr.value = "";
	document.form_.valid_to.value = "";
	document.form_.basic_salary.value = "";
	document.form_.daily_sal.value = "";
	document.form_.hourly_sal.value = "";
	
	if(document.form_.teach_rate)
		document.form_.teach_rate.value = "";
	if(document.form_.overload_rate)
		document.form_.overload_rate.value = "";

	document.form_.bank_index.value = "";
	document.form_.bank_account.value = "";
}

function PrintNotice(strSalIndex){
 	var pgLoc = "./sal_adjustment_details.jsp?salary_index="+strSalIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=700, height=500, top=10, left=10, scrollbars=yes, toolbar=no, location=no, directories=no, status=no, menubar=no');
	win.focus();
}

function ComputeHourly(){
	var iDivVal = document.form_.hrs_per_day.value;
 
	if(iDivVal.length == 0)
		return;
		
	if (document.form_.daily_sal.value.length > 0){
		if (eval(document.form_.daily_sal.value) != 0){
			document.form_.hourly_sal.value = eval(document.form_.daily_sal.value)/iDivVal;
			document.form_.hourly_sal.value = truncateFloat(document.form_.hourly_sal.value,1,false);
		}
	 }
}

function loadSalPeriods() {
	var strEmpId = document.form_.emp_id.value;
	var strMonth = document.form_.month_of.value;
	var strYear = document.form_.year_of.value;
	
	if(strEmpId.length == 0)
		return;
	
	var objCOAInput = document.getElementById("sal_periods");
	
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=305&has_all=1&month_of="+strMonth+
							 "&onchange=selectPeriod()&year_of="+strYear+"&emp_id="+strEmpId;
	document.form_.valid_fr.value = "";
	document.form_.valid_to.value = "";
	this.processRequest(strURL);
}

function selectPeriod(){
	var strSelectedIndex = document.form_.sal_period_index[document.form_.sal_period_index.selectedIndex].value;
	if(strSelectedIndex.length == 0){
		document.form_.valid_fr.value = "";
		document.form_.valid_to.value = "";
	}else{
		document.form_.valid_fr.value = eval('document.form_.valid_fr_'+strSelectedIndex+'.value');
		document.form_.valid_to.value = eval('document.form_.valid_to_'+strSelectedIndex+'.value');	
	}
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	boolean bolIsGovernment = false;
	boolean bolUseSalPeriod = false;

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-SALARY RATE"),"0"));
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
								"Admin/staff-Payroll-SALARY RATE-SALARY RATE","salary_rate_int.jsp");
		
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		bolIsGovernment = (readPropFile.getImageFileExtn("IS_GOVERNMENT","0")).equals("1");
		bolUseSalPeriod = (readPropFile.getImageFileExtn("USE_SALARY_PERIOD","0")).equals("1");		
 
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
//			dbOP.cleanUP();
//			throw new Exception();
		}								
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
	PRSalaryRate prSalRate = new PRSalaryRate();
	PRMiscDeduction prd = new PRMiscDeduction(request);
	PRConfidential prCon = new PRConfidential();
	Vector vEmpRec    = null;
	Vector vEditInfo  = null;
	String strSchCode = dbOP.getSchoolIndex();
	boolean bolCheckAllowed = false;
	Vector vSalaryPeriod 	= null;// detail of salary period.
	String strDateFrom  = null;
	String strDateTo = null;
	
	if(WI.fillTextValue("year_of").length() > 0) {
	// old
	//	vSalaryPeriod = prEdtrME.operateOnSalaryPeriod(dbOP, request, 4);
	// new
	String strEmployeeIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
		vSalaryPeriod = prEdtrME.getEmployeePeriods(dbOP, request, strEmployeeIndex);
		if(vSalaryPeriod == null)
			strErrMsg = prEdtrME.getErrMsg();
	}	
 
strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(prSalRate.operateOnSalaryMain(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = prSalRate.getErrMsg();
		else {
			strPrepareToEdit = "0";
			if(strTemp.equals("1"))
				strErrMsg = "Salary Rate Information successfully added.";
			if(strTemp.equals("2"))
				strErrMsg = "Salary Rate Information successfully edited.";
			if(strTemp.equals("0"))
				strErrMsg = "Salary Rate Information successfully removed.";
		}//System.out.println(strErrMsg);
	}

if(WI.fillTextValue("emp_id").length() > 0) {
	
	bolCheckAllowed = (prCon.checkIfEmpIsProcessor(dbOP, request, WI.fillTextValue("emp_id"), true) == 1);
 	if(bolCheckAllowed){
		enrollment.Authentication authentication = new enrollment.Authentication();
		vEmpRec = authentication.operateOnBasicInfo(dbOP, request, "0");
 		if(vEmpRec == null)
			strErrMsg = "Employee has no profile.";
	}else
		strErrMsg = prCon.getErrMsg();
}

if(vEmpRec != null && vEmpRec.size() > 0) {
	if(strPrepareToEdit.equals("1"))
		vEditInfo = prSalRate.operateOnSalaryMain(dbOP, request, 3);
}

String[] astrConvertCivilStat = {"","Single","Married","Divorced/Separated","Widow/Widower"};
String[] astrConvertTaxStat   = {"Z (No Exemption)","Single","Head of Family","Married Employed"};
String[] astrConvertUnit = {"Per hr","Per unit","Per session", "Per Period"};
String[] astrTeachingUnit = {"Per Hour","Per Unit",""};
String[] astrConvertSalPeriod = {"Daily","Weekly","Bi-monthly","Monthly"};
int iIndexOf = 0;
int iCount = 0;
%>
<body bgcolor="#D2AE72" onLoad="FocusID();ShowHideHourlyOpt();" class="bgDynamic">
<form action="./salary_rate_int.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      PAYROLL : SALARY INFORMATION PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="13%">Employee ID</td>

      <td width="19%"><strong><%=WI.fillTextValue("emp_id")%><input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>"></strong></td>
      <td width="65%">&nbsp;</td>
    </tr>
  </table>
<%if(vEmpRec != null && vEmpRec.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="25%" height="18">&nbsp; </td>
      <td>
        <%strTemp = "<img src=\"../../../upload_img/"+WI.fillTextValue("emp_id")+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=1>";
		%>
		
        <%=WI.getStrValue(strTemp)%> <br> 
        <br>
        <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%>
        <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br>
        <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br> <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
        <%=new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font>
        <br></td>
      <td width="25%">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Effectivity Date</td>
			<%
			strTemp = null;
			strTemp2 = null;
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(9);			
				strTemp2 = (String)vEditInfo.elementAt(10);	
			}				
			%>
      <td height="25"><%=WI.fillTextValue(strTemp)%> to <%=WI.getStrValue(strTemp2)%></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td height="25" colspan="2"><u>Basic Rate</u></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">Monthly</td>
      <td height="25"> <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("basic_salary");
%> <input name="basic_salary" type="text" size="15" value="<%=WI.getStrValue(strTemp,"")%>"
	  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','basic_salary');style.backgroundColor='white';ComputeRates();"
	  onKeyUp="AllowOnlyFloat('form_','basic_salary');ComputeRates();"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Daily</td>
      <td height="25"> <%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = WI.fillTextValue("daily_sal");
	%> <input name="daily_sal" type="text" size="15" value="<%=WI.getStrValue(strTemp,"")%>"
	class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','daily_sal');style.backgroundColor='white';"
	onKeyUp="AllowOnlyFloat('form_','daily_sal');ComputeHourly();">
	<%
		strTemp = (String)request.getSession(false).getAttribute("days_pm");
		if(strTemp == null || !strTemp.equals(WI.getStrValue(WI.fillTextValue("days_per_month"),strTemp)) ) {
			strTemp = WI.fillTextValue("days_per_month");
			if(strTemp.length() == 0)
				strTemp = "30";
			request.getSession(false).setAttribute("days_pm",strTemp);
		}
	%>
	<input name="days_per_month" type="text" maxlength="6" size="8" value="<%=strTemp%>"
	class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" 
	onBlur="AllowOnlyFloat('form_','days_per_month');style.backgroundColor='white';ComputeRates();"
	onKeyUp="AllowOnlyFloat('form_','days_per_month');ComputeRates();"
	style="text-align:right" >
	<!--
	<select name="days_per_month" onChange="ComputeRates();">
	<%
		//strTemp = (String)request.getSession(false).getAttribute("days_pm");
		//if(strTemp == null || !strTemp.equals(WI.getStrValue(WI.fillTextValue("days_per_month"),strTemp)) ) {
		//	strTemp = WI.fillTextValue("days_per_month");
		//	if(strTemp.length() == 0)
		//		strTemp = "30";
		//	request.getSession(false).setAttribute("days_pm",strTemp);
		//}
		//int iDefVal = Integer.parseInt(strTemp);
		//for(int i = 20; i < 32; ++i) {
		//	if(i == iDefVal)
		//		strTemp = "selected";
		//	else
		//		strTemp = "";
	%>
          <option value="<%//=i%>" <%//=strTemp%>><%//=i%></option>
          <%//}%>
        </select>
				-->
        (number of days per month)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Hourly</td>
      <td height="25"> <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("hourly_sal");
%> <input name="hourly_sal" type="text" size="15" value="<%=WI.getStrValue(strTemp,"")%>"
	  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','hourly_sal');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','hourly_sal');"> 
		<!--
		<select name="hrs_per_day" onChange="ComputeRates();">
    <%
		//strTemp = (String)request.getSession(false).getAttribute("hrs_pd");
		//if(strTemp == null || !strTemp.equals(WI.getStrValue(WI.fillTextValue("hrs_per_day"),strTemp))) {
		//	strTemp = WI.fillTextValue("hrs_per_day");
		//	if(strTemp.length() == 0)
		//		strTemp = "30";
		//	request.getSession(false).setAttribute("hrs_pd",strTemp);
		//}
		//iDefVal = Integer.parseInt(strTemp);
		//for(int i = 7; i < 11; ++i) {
		//	if(i == iDefVal)
		//		strTemp = "selected";
		//	else
		//		strTemp = "";
		%>
          <option value="<%//=i%>" <%//=strTemp%>><%//=i%></option>
          <%//}%>
        </select>
				-->
        <%
		strTemp = (String)request.getSession(false).getAttribute("hrs_pd");
		if(strTemp == null || !strTemp.equals(WI.getStrValue(WI.fillTextValue("hrs_per_day"),strTemp)) ) {
			strTemp = WI.fillTextValue("hrs_per_day");
			if(strTemp.length() == 0)
				strTemp = "8";
			request.getSession(false).setAttribute("hrs_pd",strTemp);
		}
	%>
        <input name="hrs_per_day" type="text" maxlength="6" size="8" value="<%=strTemp%>"
	class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" 
	onBlur="AllowOnlyFloat('form_','hrs_per_day');style.backgroundColor='white';ComputeRates();"
	onKeyUp="AllowOnlyFloat('form_','hrs_per_day');ComputeHourly();" style="text-align:right" >
        (number of hours per day)</td>
    </tr>
		<input type="hidden" name="holiday_opt" value="0">
		<tr>
		  <td height="20">&nbsp;</td>
		  <td colspan="3"><label id="note"></label></td>
	  </tr>		
    <tr>
      <td height="11" colspan="4"><hr size="1"></td>
    </tr>
		<%if(bolIsGovernment){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Salary Grade </td>
			<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(23);
			else
				strTemp = WI.fillTextValue("salary_grade");
			strTemp = WI.getStrValue(strTemp);
 			%>
      <td height="25"><select name="salary_grade">
        <% for(int i = 1;i < 41;i++){
		if(strTemp.equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected>Salary Grade <%=i%></option>
        <%}else{%>
        <option value="<%=i%>">Salary Grade <%=i%></option>
        <%}%>
        <%}%>
      </select>
			<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(24);
			else
				strTemp = WI.fillTextValue("sal_step");
			strTemp = WI.getStrValue(strTemp);
 			%>			
        <select name="sal_step">
        <%for(int i = 1; i < 11;i++){%>
        <%if(strTemp.equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected>Step <%=i%></option>
        <%}else{%>
        <option value="<%=i%>">Step <%=i%></option>
        <%}%>
        <%}%>
      </select></td>
    </tr>
		<%}%>
    <%if(bolIsSchool){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Teaching Rate</td>
      <td height="25"> <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("teach_rate");
%> <input name="teach_rate" type="text" size="15" value="<%=WI.getStrValue(strTemp)%>"
	  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','teach_rate');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','teach_rate');">
					<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(6);
					else
						strTemp = WI.fillTextValue("teach_rate_unit");
						strTemp = WI.getStrValue(strTemp,"");
					%>
		<select name="teach_rate_unit">
			<%for(int i = 0; i < astrTeachingUnit.length; i++){	
				if(i == 2)
					continue;
				 if(strTemp.equals(Integer.toString(i))) {%>
          <option value="<%=i%>" selected><%=astrTeachingUnit[i]%></option>
         <%}else{%>
          <option value="<%=i%>"><%=astrTeachingUnit[i]%></option>
         <%}
				}%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Overload Rate</td>
      <td height="25"> <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(7);
else
	strTemp = WI.fillTextValue("overload_rate");
%> <input name="overload_rate" type="text" size="15" value="<%=WI.getStrValue(strTemp)%>"
	  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','overload_rate');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','overload_rate');"> <select name="overload_rate_unit">
          <option value="0">Per Hour</option>
          <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(8);
else
	strTemp = WI.fillTextValue("overload_rate_unit");
strTemp = WI.getStrValue(strTemp,"");
if(strTemp.equals("1")) {%>
          <option value="1" selected>Per Unit</option>
          <%}else{%>
          <option value="1">Per Unit</option>
          <%}if(strTemp.equals("2")) {%>
          <option value="2" selected>Per Session</option>
          <%}else{%>
          <option value="2">Per Session</option>
          <%}%>
        </select> <strong><font size="1">(set if employee having teaching overload)</font></strong></td>
    </tr>
		
		<%if(strSchCode.startsWith("FATIMA")){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">LEC Rate</td>
			<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(21);
			else
				strTemp = WI.fillTextValue("lec_rate");
			%>			
      <td>
		<input name="lec_rate" type="text" size="15" value="<%=WI.getStrValue(strTemp)%>" class="textbox"  
	  onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyFloat('form_','lec_rate');"
		onBlur="AllowOnlyFloat('form_','lec_rate');style.backgroundColor='white'"></td>
    </tr>
		<tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">LAB Rate</td>
			<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(22);
			else
				strTemp = WI.fillTextValue("lab_rate");
			%>			
      <td>
		<input name="lab_rate" type="text" size="15" value="<%=WI.getStrValue(strTemp)%>" class="textbox"  
	  onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyFloat('form_','lab_rate');"
		onBlur="AllowOnlyFloat('form_','lab_rate');style.backgroundColor='white'"></td>
    </tr>		
		<%}%>
				
    <%if(strSchCode.startsWith("WNU") || strSchCode.startsWith("FATIMA")){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">RLE Rate</td>
			<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(20);
			else
				strTemp = WI.fillTextValue("rle_rate");
			%>			
      <td>
		<input name="rle_rate" type="text" size="15" value="<%=WI.getStrValue(strTemp)%>" class="textbox"  
	  onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyFloat('form_','rle_rate');"
		onBlur="AllowOnlyFloat('form_','rle_rate');style.backgroundColor='white'"></td>
    </tr>
		<%}%>
		<%if(strSchCode.startsWith("CIT")){%>
<tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Per Subject/Class rate </td>
			<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(25);
			else
				strTemp = WI.fillTextValue("class_rate");
			%>			
      <td>
		<input name="class_rate" type="text" size="15" value="<%=WI.getStrValue(strTemp)%>" class="textbox"  
	  onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyFloat('form_','class_rate');"
		onBlur="AllowOnlyFloat('form_','class_rate');style.backgroundColor='white'"></td>
    </tr>			
		<%}%>
	<%}// end checking if for school%>
    <%if(iAccessLevel > 1) {%>
    
    <tr>
      <td height="46">&nbsp;</td>
      <td height="46" colspan="2">&nbsp;</td>
      <td width="75%" height="46" valign="bottom"><font size="1">
	      <input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction(2,'');">
        Click to edit event
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:CancelRecord();">
        Click to clear </font></td>
    </tr>
    <%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
 <%}//only if(vEmpRec != null && vEmpRec.size() > 0) %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="print_page" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
