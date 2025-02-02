<%@ page language="java" import="utility.*,java.util.Vector, payroll.ReportPayroll,
																payroll.ReportPayrollExtn, payroll.PReDTRME" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Finalize Payslip</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
function forwardSlip(){
	if(document.form_.print_option2.value.length == 0){
		alert("Enter range to print");
		document.form_.print_option2.focus();
		return;
	} else {
		document.form_.print_batch.value = "1";
		this.SubmitOnce('form_');	
	}
}

function ReloadPage(){
	document.form_.searchEmployee.value="";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function SearchEmployee(){	
	document.form_.searchEmployee.value="1";
	document.form_.print_page.value="";
	document.form_.submit();
}

function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}
}

function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}

function DeleteRecord(){
  var vProceed = confirm('Set selected records as not finalized?');
  if(vProceed){
		document.form_.page_action.value = "0";
		document.form_.searchEmployee.value = "1";
		document.form_.print_page.value = "";
		this.SubmitOnce("form_");
  }	
}

function SaveData() {
	document.form_.page_action.value = "6";
	document.form_.print_page.value = "";
	document.form_.searchEmployee.value = "1";
	document.form_.save.disabled = true;
	//document.form_.hide_save.src = "../../../../images/blank.gif";
	document.form_.sal_period_val.value = document.form_.sal_period_index[document.form_.sal_period_index.selectedIndex].text;
	document.form_.submit();
	//this.SubmitOnce('form_');
}

function CancelRecord(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function CopyAll(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	
		
		for (var i = 1 ; i < eval(vItems);++i)
			eval('document.form_.amount_'+i+'.value=document.form_.amount_1.value');			
}

function CopyDuration(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	

	for (var i = 1 ; i < eval(vItems);++i)
		eval('document.form_.days_'+i+'.value=document.form_.days_1.value');			
}

function CopyHour(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	

	for (var i = 1 ; i < eval(vItems);++i)
		eval('document.form_.hours_'+i+'.value=document.form_.hours_1.value');			
}

function CopyMinute(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	

	for (var i = 1 ; i < eval(vItems);++i)
		eval('document.form_.minutes_'+i+'.value=document.form_.minutes_1.value');			
}


function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
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

	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=301&month_of="+strMonth+
							 "&year_of="+strYear+"&is_weekly="+strWeekly;

	this.processRequest(strURL);
}

function PrintSlip(emp_id, sal_period_index, sal_index, strBankAcct, strReceiptNo, strStatus, 
				   strIsAtm, strTenure, strSalaryType, strIsWeekly, strRank) {	
	var pgLoc = "./payroll_slip_print.jsp?emp_id="+emp_id+"&sal_period_index="+sal_period_index+
				"&sal_index="+sal_index+"&bank_account="+strBankAcct+
				"&rec_no="+strReceiptNo+"&pt_ft="+strStatus+"&is_atm="+strIsAtm+"&tenure="+strTenure+
				"&finalize=1&my_home=0&salary_period="+strSalaryType+
				"&month_of="+document.form_.month_of.value+"&year_of="+document.form_.year_of.value+
				"&is_weekly="+strIsWeekly+"&rank="+strRank;
	var win=window.open(pgLoc,"PrintWindow",'width=770,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	String strHasWeekly = null;
	boolean bolAllowUnfinalize = false;
//add security here.
	if(WI.fillTextValue("print_page").equals("1")){%>
		<jsp:forward page="batch_print.jsp"/>
	<% return; }
		
try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payslips-Finalize Payslip","hold_payslip.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");		
		bolAllowUnfinalize = (readPropFile.getImageFileExtn("ALLOW_UNFINALIZE","0")).equals("1");		
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
														"Payroll","REPORTS",request.getRemoteAddr(),
														"hold_payslip.jsp");
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

	Vector vRetResult = null;
	Vector vSalaryPeriod 		= null;//detail of salary period.
	ReportPayroll RptPay = new ReportPayroll(request);
	ReportPayrollExtn rptExtn = new ReportPayrollExtn(request);
	
	PReDTRME prEdtrME = new PReDTRME();
	int iSearchResult = 0;
	int i = 0;
	String strWithSched = WI.getStrValue(WI.fillTextValue("with_schedule"),"1");
	String strPayrollPeriod  = null;
	String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","5"};
	
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";	
	String[] astrSortByName = {"Employee ID","Firstname","Lastname",strTemp,"Department"};
	String[] astrSortByVal  = {"id_number","user_table.fname","lname","c_name","d_name"};
	
	String[] astrSalaryStat =  {"Not Finalized","Finalized/Released","On Hold"};
	
	String strPageAction = WI.fillTextValue("page_action");
 	if(strPageAction.length() > 0){
		if(rptExtn.operateOnPeriodPayslip(dbOP, request, Integer.parseInt(strPageAction)) == null)
			strErrMsg = rptExtn.getErrMsg();
		else
			strErrMsg = "Operation success!";				
	}
	
	if(WI.fillTextValue("searchEmployee").length() > 0){
 	  vRetResult = RptPay.searchRegularPaySlip(dbOP);
		if(vRetResult == null)
			strErrMsg = RptPay.getErrMsg();
		else
			iSearchResult = RptPay.getSearchCount();
	}	
 	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	
%>
<body>
<form name="form_">
  <% if (vRetResult != null &&  vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
			<%
				strTemp = WI.fillTextValue("sal_release_stat");
				if(strTemp.equals("0"))
					strTemp = " HAVING UNRELEASED SALARY FOR PERIOD";
				else
					strTemp = " HAVING ON HOLD SALARY FOR PERIOD";
			%>
      <td height="20" colspan="6" align="center" class="thinborder"><strong>LIST OF EMPLOYEES <%=strTemp%></strong></td>
    </tr>
    <tr>
      <td width="3%" class="thinborder">&nbsp;</td>
      <td width="10%" class="thinborder">&nbsp;</td> 
      <td width="29%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="30%" align="center" class="thinborder"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">SALARY</font></strong></td>
      <%if(WI.fillTextValue("sal_release_stat").equals("2") && iAccessLevel == 2){%>
			<%}%>
    </tr>
    <% 	int iCount = 1;
	   for (i = 0; i < vRetResult.size();  i += 27,iCount++){
		 %>
    <tr>
      <td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%>, <%=(String)vRetResult.elementAt(i + 1)%> </td>
			<input type="hidden" name="id_number_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
			<input type="hidden" name="u_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+11)%>">
			<input type="hidden" name="sal_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+7)%>">
      <%if((String)vRetResult.elementAt(i + 3)== null || (String)vRetResult.elementAt(i + 4)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
		%>
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 4),"")%> </td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+5), true);
			%>
			<input type="hidden" name="sal_amt_<%=iCount%>" value="<%=strTemp%>">
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%if(WI.fillTextValue("sal_release_stat").equals("2") && iAccessLevel == 2){%>
      <%}%>
    </tr>
    <%} //end for loop%>
    
		<%if(iAccessLevel == 2){%>
    
		<%}else{%>
    
		<%}%>
   </table>
<% } // end vRetResult != null && vRetResult.size() > 0 %>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>