<%@ page language="java"  buffer="16kb"
	import="utility.*,payroll.PRSalaryRate, java.util.Vector, payroll.PRMiscDeduction, 
					payroll.PRConfidential, payroll.PReDTRME" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.

boolean bolHasAUFStyle = false;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
  	if(strSchCode == null)
		strSchCode = "";		

int iMulFactor = 1;
int iDaysPerMonth = 0;///some are using days per year and some are using days per month.
if(strSchCode.startsWith("MARINER")) {
	iMulFactor = 12;//days per year.
	iDaysPerMonth = 313;
}

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

function ComputeRates(strOpt){
	var iDivVal = document.form_.days_per_month.value;
	//iDivVal = document.form_.days_per_month[document.form_.days_per_month.selectedIndex].value;
	var strMonthly =document.form_.basic_salary.value;
	var strDaily = document.form_.daily_sal.value;
	var strHourly = document.form_.hourly_sal.value;
	
	if(iDivVal.length == 0)
		return;
	
	if(strOpt == "1"){
		strMonthly =document.form_.basic_salary_int.value;
		strDaily = document.form_.daily_sal_int.value;
		strHourly = document.form_.hourly_sal_int.value;		
	}	
	
	if (strMonthly.length > 0){
		if (eval(strMonthly) != 0){
		<%if(iDaysPerMonth > 0) {%>
			strDaily = eval(strMonthly)*<%=iMulFactor%>/<%=iDaysPerMonth%>;
		<%}else{%>
			strDaily = eval(strMonthly)/iDivVal;
		<%}%>
		
			strDaily = truncateFloat(strDaily,1,false);
			//iDivVal = document.form_.hrs_per_day[document.form_.hrs_per_day.selectedIndex].value;
			iDivVal = document.form_.hrs_per_day.value;
			if(iDivVal.length == 0)
				return;
			strHourly = eval(strDaily)/iDivVal;
			strHourly = truncateFloat(strHourly,2,false);
		}
	 }else{
		 strDaily ="0";
		 strHourly ="0";
	 }
	 
	 if(strOpt == "1"){
			document.form_.daily_sal_int.value = strDaily;
			document.form_.hourly_sal_int.value = strHourly;	
	 }else{
			document.form_.daily_sal.value = strDaily;
			document.form_.hourly_sal.value = strHourly;
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

function viewHistory() {
	var pgLoc = "./salary_rate_history.jsp?emp_id="+document.form_.emp_id.value;
	var win=window.open(pgLoc,"view_history",'dependent=yes,width=600,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function CopyID(strID){
	ClearFields();
	document.form_.print_page.value="";
	document.form_.emp_id.value=strID;
	this.SubmitOnce("form_");

}

function CancelRecord(){
	location = "salary_rate.jsp?emp_id="+document.form_.emp_id.value;
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

function ComputeHourly(strOpt){
	var iDivVal = document.form_.hrs_per_day.value;
 
	if(iDivVal.length == 0)
		return;
		
	var strDaily = document.form_.daily_sal.value;
	var strHourly = document.form_.hourly_sal.value;
	
	if(strOpt == "1"){
		strDaily = document.form_.daily_sal_int.value;
		strHourly = document.form_.hourly_sal_int.value;		
	}
	
	if (strDaily.length > 0){
		if (eval(strDaily) != 0){
			strHourly = eval(strDaily)/iDivVal;
			strHourly = truncateFloat(strHourly,2,false);
		}
	 }
	 
	if(strOpt == "1"){
		document.form_.daily_sal_int.value = strDaily;
		document.form_.hourly_sal_int.value = strHourly;			
	}else{
		document.form_.daily_sal.value = strDaily;
		document.form_.hourly_sal.value = strHourly;		
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

function copyRange() {
	document.form_.copy_range.value = "1";
	ReloadPage(); 
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

function updateInternal(strIndex) {
	var pgLoc = "./salary_rate_int.jsp?info_index="+strIndex+
							"&prepareToEdit=1&emp_id="+document.form_.emp_id.value;
	var win=window.open(pgLoc,"updateInternal",'width=700,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function EncodeRatePerClass() {
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "./salary_rate_faculty_per_class.jsp?emp_id="+document.form_.emp_id.value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
	boolean bolHasInternal = false;

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
								"Admin/staff-Payroll-SALARY RATE-SALARY RATE","salary_rate.jsp");
		
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		bolHasAUFStyle = (readPropFile.getImageFileExtn("HAS_AUF_STYLE","0")).equals("1");
		bolIsGovernment = (readPropFile.getImageFileExtn("IS_GOVERNMENT","0")).equals("1");
		bolUseSalPeriod = (readPropFile.getImageFileExtn("USE_SALARY_PERIOD","0")).equals("1");		
 		bolHasInternal = (readPropFile.getImageFileExtn("HAS_INTERNAL","0")).equals("1");
		
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
	Vector vRetResult = null;
	Vector vEmpRec    = null;
	Vector vTaxStat   = null;
	Vector vEditInfo  = null;
	Vector vHistory   = null;
	Vector vEmpList = null;

	String srtIDateAttribute = " "; 
		if(!strSchCode.startsWith("EAC"))
			srtIDateAttribute = "readonly = 'yes'";
	 
	String strCheck = null;
	boolean bolCheckAllowed = false;
	String strDisabled = "";
	Vector vSalaryPeriod 	= null;// detail of salary period.
	String strDateFrom  = null;
	String strDateTo = null;
	boolean[] abolShowRate = new boolean[6];
	// 0 - LEC
	// 1 - LAB
	// 2 - Graduate
	// 3 - NSTP
	// 4 - RLE
	// 5 - Class
	for(int i = 0;i < abolShowRate.length; i++){
		abolShowRate[i] = false;
		if(i == 5)
			continue;
		if(strSchCode.startsWith("FATIMA") || strSchCode.startsWith("EAC"))
			abolShowRate[i] = true;
	}
	
	if(strSchCode.startsWith("WNU"))
		abolShowRate[4] = true;
	
	if(strSchCode.startsWith("UPH")) {
		abolShowRate[2] = true;
		abolShowRate[3] = true;
	}
	
	if(strSchCode.startsWith("CIT"))
		abolShowRate[5] = true;
		
	if(strSchCode.startsWith("UC"))
		abolShowRate[2] = true;
	
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
 
	vRetResult = prSalRate.operateOnSalaryMain(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = prSalRate.getErrMsg();
	vEmpList = prd.getEmployeesList(dbOP);
	vTaxStat = 	new payroll.PRTaxStatus().operateOnTaxStatus(dbOP, request,4);

	if(WI.fillTextValue("show_history").length() > 0){
 		vHistory = prSalRate.getSalaryRateHistory(dbOP, request);
		if(vHistory == null && strErrMsg == null)
			strErrMsg = prSalRate.getErrMsg();
 	}
}

String[] astrConvertCivilStat = {"","Single","Married","Divorced/Separated","Widow/Widower"};
String[] astrConvertTaxStat   = {"Z (No Exemption)","Single","Head of Family","Married Employed"};
String[] astrConvertUnit = {"Per hr","Per unit","Per session", "Per Period"};
String[] astrTeachingUnit = {"Per Hour","Per Unit",""};
String[] astrConvertSalPeriod = {"Daily","Weekly","Bi-monthly","Monthly"};
int iIndexOf = 0;
int iCount = 0;
boolean bolViewOnly = false;
if(WI.fillTextValue("view").length() > 0)
	bolViewOnly = true;
%>
<body bgcolor="#D2AE72" onLoad="FocusID();ShowHideHourlyOpt();" class="bgDynamic">
<form action="./salary_rate.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      PAYROLL : SALARY INFORMATION PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <%if(!bolViewOnly){%>
		<tr>
      <td height="23" colspan="2"><font size="1"><a href="./salary_rate_main.jsp"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></font></td>
      <td height="23" colspan="2" align="right"><%
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
	<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) < vEmpList.size()-1){%>
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
	<%}%>
    <tr>
      <td height="23" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="13%">Employee ID</td>
	  <%	
	  	String strReadOnly = "";
	  if(bolViewOnly){
	  	strReadOnly = " readonly";
	  }
	  %>
      <td width="19%"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" <%=strReadOnly%> onKeyUp="AjaxMapName(1);"><br>
		<div id="ajax_" style="position:absolute; width:400px; overflow:auto">
		<label id="coa_info"></label>
		</div></td>
      <td width="65%"><%if(!bolViewOnly){%><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
		<%}%>		</td>
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
		<%if(vTaxStat != null && vTaxStat.size() > 1){%>
    <tr>
      <td height="30">&nbsp;</td>
      <td height="30" colspan="2" valign="bottom"> Civil Status :<strong> <%=astrConvertCivilStat[Integer.parseInt((String)vTaxStat.elementAt(0))]%></strong></td>
    </tr>
		<%}%>
    <tr>
      <td height="18" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%if(!bolViewOnly){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<%if(bolUseSalPeriod){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td><select name="month_of" onChange="loadSalPeriods();">
            <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%>
          </select><select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"), 2, 1)%>
        </select></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td>
					<label id="sal_periods">
					<%for(int i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10,++iCount){%>
						<input type="hidden" name="valid_fr_<%=vSalaryPeriod.elementAt(i)%>" value="<%=vSalaryPeriod.elementAt(i+1)%>">
						<input type="hidden" name="valid_to_<%=vSalaryPeriod.elementAt(i)%>" value="<%=vSalaryPeriod.elementAt(i+2)%>">
					<%}%>					
					<select name="sal_period_index" style="font-weight:bold;font-size:11px;" onChange="selectPeriod();">
					<option value="">&nbsp;</option>
            <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");
 		for(int i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10){
			if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
			strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
			strTemp2 += "Whole Month";
		  }else{
			strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
			strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);			
//			strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//				(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		  }
				if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {%>
            <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
            <%
		  	strDateFrom = (String)vSalaryPeriod.elementAt(i+1);
		  	strDateTo = (String)vSalaryPeriod.elementAt(i+2);
		  %>
            <%}else{%>
            <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
            <%}//end of if condition.
		 }//end of for loop.%>
          </select>
					</label>					</td>
          <td>&nbsp;</td>
        </tr>
      </table></td>
    </tr>
		<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Effectivity Date</td>
      <td> <%
			if(WI.fillTextValue("copy_range").length() > 0){
				strTemp = strDateFrom;
			}else{
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(9);
				else
					strTemp = WI.fillTextValue("valid_fr");
			}%> 
		<input name="valid_fr" type="text" size="12" maxlength="12" <%=srtIDateAttribute%> value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.valid_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        to
        <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(10);
else
	strTemp = WI.fillTextValue("valid_to");
%> <input name="valid_to" type="text" size="12" maxlength="12" <%=srtIDateAttribute%> value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.valid_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>      </td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td colspan="2">Salary Period Type</td>
      <td><select name="salary_period">
          <!--<option value="0">Daily</option>-->
          <option value="2">Bi-monthly</option>
          <%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = WI.fillTextValue("salary_period");
	if(strTemp == null)
		strTemp = "";
					if(strTemp.equals("3")) {%>
          <option value="3" selected>Monthly</option>
          <%}else{%>
			<option value="3">Monthly</option>
          <%}if(strTemp.equals("1")) {%>
          <option value="1" selected>Weekly</option>
          <%}else{%>
          <option value="1">Weekly</option>
          <%}%>
        </select> <font size="1"> * this indictates when salary is given to employee</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
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
	strTemp = (String)request.getParameter("days_per_month");
	if(strTemp == null) {
		//I must get the default setting in payroll for daily rate. from read_property_file.
		strTemp = "select prop_val from READ_PROPERTY_FILE where prop_name = 'pr_sal_rate_days_pm'";
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		
	}
	//System.out.println(strTemp);
	if(strTemp == null)
		strTemp = (String)request.getSession(false).getAttribute("days_pm");

		if(strTemp == null || !strTemp.equals(WI.getStrValue(WI.fillTextValue("days_per_month"),strTemp)) ) {
			strTemp = WI.fillTextValue("days_per_month");
			if(strTemp.length() == 0)
				strTemp = "30";
			request.getSession(false).setAttribute("days_pm",strTemp);
		}
	%>
	<input name="days_per_month" type="text" maxlength="12" size="10" value="<%=strTemp%>"
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
		<%if(bolHasInternal){%>
		<tr bgcolor="#DDDDDD">
		  <td height="25">&nbsp;</td>
		  <td height="25" colspan="3">Internal Rate </td>
	  </tr>
		<tr bgcolor="#DDDDDD">
      <td height="25">&nbsp;</td>
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">Monthly</td>
      <td height="25"> <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(26);
else
	strTemp = WI.fillTextValue("basic_salary_int");
%> <input name="basic_salary_int" type="text" size="15" value="<%=WI.getStrValue(strTemp,"")%>"
	  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','basic_salary_int');style.backgroundColor='white';ComputeRates('1');"
	  onKeyUp="AllowOnlyFloat('form_','basic_salary_int');ComputeRates('1');"></td>
    </tr>
    <tr bgcolor="#DDDDDD">
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Daily</td>
      <td height="25"> <%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(27);
	else
		strTemp = WI.fillTextValue("daily_sal_int");
	%> <input name="daily_sal_int" type="text" size="15" value="<%=WI.getStrValue(strTemp,"")%>"
	class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','daily_sal_int');style.backgroundColor='white';"
	onKeyUp="AllowOnlyFloat('form_','daily_sal_int');ComputeHourly('1');"></td>
    </tr>
    <tr bgcolor="#DDDDDD">
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Hourly</td>
      <td height="25"> <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(28);
else
	strTemp = WI.fillTextValue("hourly_sal_int");
%> <input name="hourly_sal_int" type="text" size="15" value="<%=WI.getStrValue(strTemp,"")%>"
	  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','hourly_sal_int');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','hourly_sal_int');">		 </td>
    </tr>		
		<%}%>
		<%if(!strSchCode.startsWith("UI")){%>
		<%if(!strSchCode.startsWith("AUF")){// because monthly lang jud sila%>
		<%if(!strSchCode.startsWith("LCP")){%>
    <tr>
      <td height="41">&nbsp;</td>
      <td height="41" colspan="3"><table width="77%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td><u>Salary Computation Basis </u></td>
        </tr>
        <tr>
          <td>
				<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(16);
				else	
					strTemp = WI.fillTextValue("salary_basis");
					
				strTemp = WI.getStrValue(strTemp,"0");
				if(strTemp.compareTo("0") == 0) 
					strCheck = " checked";
				else{
					strCheck = "";	
					strDisabled = " disabled";
				}
				%>
        <input type="radio" name="salary_basis" value="0"<%=strCheck%> onClick="ShowHideHourlyOpt('0');">
            Monthly rate
			      <%
				if(strTemp.compareTo("1") == 0)
					strCheck = " checked";
				else
					strCheck = "";
				%>
			      <input type="radio" name="salary_basis" value="1"<%=strCheck%> onClick="ShowHideHourlyOpt('1');">
							Daily Rate
		          <%
				if(strTemp.compareTo("2") == 0) 
					strCheck = " checked";
				else
					strCheck = "";
				%>
		          <input type="radio" name="salary_basis" value="2"<%=strCheck%> onClick="ShowHideHourlyOpt('2');">
            Hourly Rate </td>
        </tr>
				<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(18);
				else	
					strTemp = WI.fillTextValue("use_hourly");
 				strTemp = WI.getStrValue(strTemp,"0");
				if(strTemp.compareTo("1") == 0) 
					strCheck = " checked";
				else	
					strCheck = "";	
				%>
        <tr>
          <td>
					<label id="show_hourly_opt">
 					<input type="checkbox" name="use_hourly" value="1" <%=strCheck%> <%=strDisabled%>>
 					<font size="1">Check if whole day absences will be computed based on the number of hours</font></label></td>
        </tr>
      </table>			</td>
    </tr>

		<%}// end if not LCP%>
		<%}// end if not AUF%>
		<%}// end if not UI%>
		<% if(bolHasAUFStyle){%>
    <tr>
      <td height="20">&nbsp;</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(17);
				else	
					strTemp = WI.fillTextValue("is_one_computation");
					
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
			%>
      <td height="20" colspan="3"><input type="checkbox" name="is_one_computation" value="1"<%=strTemp%>>
      <font size="1">Check if payroll is computed only once a month but released at least once</font></td>
    </tr>		
		<%}%>
		<!--
		<tr>
			<td height="20">&nbsp;</td>
			<%
			//if(vEditInfo != null && vEditInfo.size() > 0)
			//	strTemp = (String)vEditInfo.elementAt(19);
			//else
			//	strTemp = WI.fillTextValue("holiday_opt");
			%>			
			<td colspan="3">Holiday option : 
				<select name="holiday_opt" onChange="UpdateNote();">
				<option value="0">No Application needed</option>				
				<%//if(strTemp.equals("1")) {%>
				<option value="1" selected>No application, no additional pay</option>
				<%//}else{%>
				<option value="1">No application, no additional pay</option>
				<%//}%>
			</select>			
			</td>
		</tr>
		-->
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
		<%if(abolShowRate[0]){%>
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
		<%}%>
		<%if(abolShowRate[1]){%>
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
		<%if(abolShowRate[2]){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Graduate Rate</td>
			<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(29);
			else
				strTemp = WI.fillTextValue("grad_rate");
			%>			
      <td>
		<input name="grad_rate" type="text" size="15" value="<%=WI.getStrValue(strTemp)%>" class="textbox"  
	  onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyFloat('form_','grad_rate');"
		onBlur="AllowOnlyFloat('form_','grad_rate');style.backgroundColor='white'"></td>
    </tr>	
		<%}%>
		<%if(abolShowRate[3]){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">NSTP Rate</td>
			<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(30);
			else
				strTemp = WI.fillTextValue("nstp_rate");
			%>
      <td>
		<input name="nstp_rate" type="text" size="15" value="<%=WI.getStrValue(strTemp)%>" class="textbox"  
	  onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyFloat('form_','nstp_rate');"
		onBlur="AllowOnlyFloat('form_','nstp_rate');style.backgroundColor='white'"></td>
    </tr>						
		<%}%>
				
    <%if(abolShowRate[4]){%>
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
		<%if(abolShowRate[5]){%>
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
      <td height="19">&nbsp;</td>
      <td height="19" colspan="2">Bank Name</td>
      <td height="19" valign="bottom"> <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(11);
		else
			strTemp = WI.fillTextValue("bank_index");
		%> <select name="bank_index">
          <option value="">Select Bank</option>
          <%=dbOP.loadCombo("BANK_INDEX","BANK_NAME, BRANCH", " from FA_BANK_LIST where is_valid = 1 and is_del = 0", strTemp,false)%> </select> 
					<a href="javascript:UpdateBanks();"><img src="../../../images/update.gif" border="0" ></a><font size="1">
        click to add to the list banks</font></td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
      <td height="19" colspan="2">Account Number</td>
      <td height="19" valign="bottom">
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(12);
		else
			strTemp = WI.fillTextValue("bank_account");
		%> 
		<input name="bank_account" type="text"
	  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>" size="20" maxlength="20">
 <%
if(vEditInfo != null && vEditInfo.size() > 0){
	if(((String)vEditInfo.elementAt(13)).equals("1")){
		strTemp = " checked";
	}else{
		strTemp = "";
	}
}else{
	strTemp = "";
}
%>
   <input name="is_atm_account" type="checkbox" value="1"<%=strTemp%>>
        <font size="1">ATM Account (check if account is for ATM)</font></td>
    </tr>
    <tr>
      <td height="46">&nbsp;</td>
      <td height="46" colspan="2">&nbsp;</td>
      <td width="75%" height="46" valign="bottom"><font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>        
        <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction(1, '');">
        Click to save entries
        <%}else{%>        
        <input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction(2,'');">
        Click to edit event
        <%}%>
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:CancelRecord();">
        Click to clear</font></td>
    </tr>
    <%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <%}//end if bolIsView is false..%>

<%if(vRetResult != null && vRetResult.size() > 0) {
boolean bolIsFacSalary = false;
for (int i = 0; i < vRetResult.size(); i +=40){
	if(vRetResult.elementAt(i + 5) != null && !((String)vRetResult.elementAt(i + 5)).startsWith("0.0")){
		bolIsFacSalary = true;
		break;
	}
}
if(bolIsFacSalary) {%>
  <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="30" colspan="12" align="right" style="font-weight:bold; font-size:14px;"><a href="javascript:EncodeRatePerClass();">Encode/Manage Faculty Rate per class</a></td>
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#888888">
      <td height="30" colspan="12" align="center"><font color="#FFFFFF"><strong>:::
          SALARY RECORD DETAIL :::</strong></font></td>
    </tr>
  </table>
	<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">INCLUSIVE DATES</font></strong></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>BASIC SALARY</strong></font></td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">DAILY RATE</font></strong></td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">HOURLY RATE</font></strong></td>
      <%if(bolIsSchool){%>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">TEACH RATE</font></strong></td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">TEACH OVER LOAD RATE</font></strong></td>
			<%if(abolShowRate[0]){%>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">LEC RATE</font></strong> </td>
			<%}if(abolShowRate[1]){%>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">LAB RATE</font></strong> </td>
			<%}if(abolShowRate[2]){%>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">GRAD RATE</font></strong></td>
			<%}if(abolShowRate[3]){%>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">NSTP RATE</font></strong></td>
      <%}if(abolShowRate[4]){%>
			<td width="7%" align="center" class="thinborder"><strong><font size="1">RLE RATE</font></strong> </td>
			<%}if(abolShowRate[5]){%>
			<td width="7%" align="center" class="thinborder"><strong><font size="1">SUBJECT /CLASS RATE</font></strong> </td>
			<%}%>
      <%}%>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">SAL
        PERIOD</font></strong></td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">ACCOUNT
        NUMBER</font></strong></td>
			<!--
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>ADDL
        JOB</strong></font></td>
			-->
      <%if(!bolViewOnly){%>
      <!--
			nobody uses this link
			<td width="7%" align="center" class="thinborder"><font size="1">&nbsp;<strong>ADD
        ADDL JOB</strong></font></td>
			-->
      <td width="5%" align="center" class="thinborder"><strong><font size="1">EDIT</font></strong></td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">DELETE</font></strong></td>
      <%if(bolIsGovernment){%>
			<td width="5%" align="center" class="thinborder"><strong><font size="1">DETAIL</font></strong></td>
			<%}%>
      <%}%>
    </tr>
    <% for (int i = 0; i < vRetResult.size(); i +=40){%>
    <tr>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i + 9)%> <%=WI.getStrValue((String)vRetResult.elementAt(i + 10)," - <br>",""," - present")%></div></td>
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"","","&nbsp;")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 4),"","","&nbsp;")%></td>
	<%if(bolIsSchool){%>
      <td align="center" class="thinborder"> <%if(vRetResult.elementAt(i + 5) != null && ((String)vRetResult.elementAt(i + 5)).compareTo("0.0") != 0){%> <%=(String)vRetResult.elementAt(i + 5)%> <%=astrConvertUnit[Integer.parseInt((String)vRetResult.elementAt(i + 6))]%> <%}else{%> &nbsp; <%}%> </td>
      <td align="center" class="thinborder"> <%if(vRetResult.elementAt(i + 7) != null && ((String)vRetResult.elementAt(i + 7)).compareTo("0.0") != 0){%> <%=(String)vRetResult.elementAt(i + 7)%> <%=astrConvertUnit[Integer.parseInt((String)vRetResult.elementAt(i + 8))]%> <%}else{%> &nbsp; <%}%> </td>
	    <%if(abolShowRate[0]){%>
			<td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 21),"","","&nbsp;")%></td>
			<%}if(abolShowRate[1]){%>
	    <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 22),"","","&nbsp;")%></td>
			<%}if(abolShowRate[2]){%>
			<td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 29),"","","&nbsp;")%></td>
			<%}if(abolShowRate[3]){%>
			<td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 30),"","","&nbsp;")%></td>
			<%}if(abolShowRate[4]){%>
	    <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 20),"","","&nbsp;")%></td>
			<%}if(abolShowRate[5]){%>
			<td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 25),"","","&nbsp;")%></td>
			<%}%>
	    <%}%>
      <td align="center" class="thinborder"><%=astrConvertSalPeriod[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 2),"2"))]%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 12),"")%>&nbsp;</td>
      <!--
			<td align="right" class="thinborder"> 
        <%if((vRetResult.elementAt(i + 14) == null || ((String)vRetResult.elementAt(i + 14)).equals("0"))
		  	&& (vRetResult.elementAt(i + 15) == null || ((String)vRetResult.elementAt(i + 15)).equals("0"))
		   ) {%>
        <img src="../../../images/x.gif">
        <%}else{%>
        M <%=WI.getStrValue((String)vRetResult.elementAt(i + 14))%> <br>
        BI <%=WI.getStrValue((String)vRetResult.elementAt(i + 15))%>
        <%}%>      
				</td>
			-->	
      <%if(!bolViewOnly){%>
      <!--
			<td class="thinborder"><a href="javascript:AddAddlRes();">UPDATE</a></td>
			-->
      <td align="center" class="thinborder">
			<%if (iAccessLevel > 1){%>
			<input type="button" name="edit2" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
			<%}%>			</td>
      <td align="center" class="thinborder"> 
			<% if (iAccessLevel == 2){%> 
				<input type="button" name="delete" value="Delete" style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">				
			<%}else{%>
	  	N/A
	    <%}%>			</td>
      <%if(bolIsGovernment){%>
			<td align="center" class="thinborder">
			<%if(vHistory != null && vHistory.size() > 0){%>
			<a href="javascript:PrintNotice('<%=vRetResult.elementAt(i)%>');">VIEW</a>
			<%}else{%>
			&nbsp;
			<%}%>			</td>
			<%}%>
      <%}%>
    </tr>
    <% } // end for loop %>
  </table>
<%}//if vRetResult.size() > 0%>
  <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">	
	<tr>
      <td colspan="12"><div align="center">
	    <%if(!bolViewOnly){%>(
		  <%if(WI.fillTextValue("show_history").length() > 0)
		  	  strTemp = " checked";
			else
			  strTemp = "";
		  %>
			<input name="show_history" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">
			click to see salary rate history/advanced )
		  <%}%>
	  </div></td>
    </tr>
  </table>
<%//System.out.println("vHistory " + vHistory);
if(!bolViewOnly && vHistory != null && vHistory.size() > 0){%>
  <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#888888">
      <td height="30" colspan="10" align="center"><font color="#FFFFFF"><strong>:::
          PREVIOUS SALARY ::: </strong></font></td>
    </tr>
    <tr>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">INCLUSIVE
        DATES</font></strong></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>BASIC
        SALARY</strong></font></td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">DAILY
        RATE</font></strong></td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">HOURLY
        RATE</font></strong></td>
			<%if(bolIsSchool){%>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">TEACH
        RATE</font></strong></td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">TEACH
        OVER LOAD RATE</font></strong></td>
			<%}%>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">SAL
        PERIOD</font></strong></td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">BANK ACCOUNT</font></strong></td>
      <%if(!strSchCode.startsWith("UI")){%>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">EDIT</font></strong></td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">DELETE</font></strong></td>
      <%}%>
    </tr>
    <%//System.out.println(vHistory);
  for (int i = 0; i < vHistory.size(); i +=12){%>
    <tr>
      <td class="thinborder"><div align="center"><%=(String)vHistory.elementAt(i + 9)%> <%=WI.getStrValue((String)vHistory.elementAt(i + 10)," - <br>",""," - present")%></div></td>
      <td align="center" class="thinborder"><%=(String)vHistory.elementAt(i + 1)%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vHistory.elementAt(i + 3),"","","&nbsp;")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vHistory.elementAt(i + 4),"","","&nbsp;")%></td>
      <%if(bolIsSchool){%>
			<td align="center" class="thinborder"> <%if(vHistory.elementAt(i + 5) != null && ((String)vHistory.elementAt(i + 5)).compareTo("0.0") != 0){%> <%=(String)vHistory.elementAt(i + 5)%> <%=astrConvertUnit[Integer.parseInt((String)vHistory.elementAt(i + 6))]%> <%}else{%> &nbsp; <%}%> </td>
      <td align="center" class="thinborder"> <%if(vHistory.elementAt(i + 7) != null && ((String)vHistory.elementAt(i + 7)).compareTo("0.0") != 0){%> <%=(String)vHistory.elementAt(i + 7)%> <%=astrConvertUnit[Integer.parseInt((String)vHistory.elementAt(i + 8))]%> <%}else{%> &nbsp; <%}%> </td>
			<%}%>
      <td align="center" class="thinborder"><%=astrConvertSalPeriod[Integer.parseInt((String)vHistory.elementAt(i + 2))]%></td>
	  <td align="center" class="thinborder"><%=WI.getStrValue((String)vHistory.elementAt(i + 11), "&nbsp;")%></td>
	  <%if(!strSchCode.startsWith("UI")){%>
      <td align="center" class="thinborder">
        <% if (iAccessLevel > 1){%>
        <input type="button" name="edit3" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:PrepareToEdit('<%=(String)vHistory.elementAt(i)%>');">
        <%}%>      </td>
      <td align="center" class="thinborder">
        <% if (iAccessLevel == 2){%>
        <input type="button" name="delete2" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:PageAction('0','<%=(String)vHistory.elementAt(i)%>');">					
        <%}else{%>
        N/A
        <%}%>      </td>
      <%}%>
    </tr>
    <%} // end for loop vHistory %>
  </table>
  <%} // end if vHistory != null %>

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
<input type="hidden" name="copy_range">

<%if(bolViewOnly){%>
<input type="hidden" name="view" value="1">
<%}%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
