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
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="hold_payslip.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL: FINALIZE PAY SLIP PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td> <select name="month_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>
        (Must be filled up to display salary period information)</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%">Salary Period</td>
      <td width="77%">
				<label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");		
		
		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
			if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += "Whole Month";
			}else{
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);			
//				strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//					(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			}
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		   strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		%>
          <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%> </option>
          <%}else{%>
          <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%></option>
          <%}//end of if condition.		  
		 }//end of for loop.%>
        </select>
				</label>
        <% 
				if(strHasWeekly.equals("1")){
					strTemp = WI.fillTextValue("is_weekly");
					if(strTemp.compareTo("1") == 0) 
						strTemp = " checked";
					else	
						strTemp = "";
				%>
        <input type="checkbox" name="is_weekly" value="1" <%=strTemp%> onClick="ReloadPage();">        <font size="1">for weekly </font>
        <%}// check if the company has weekly salary type%></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Status</td>
      <td><select name="pt_ft" onChange="ReloadPage();">
        <option value="">All</option>
        <%if (WI.fillTextValue("pt_ft").equals("0")){%>
        <option value="0" selected>Part-time</option>
        <%}else{%>
        <option value="0">Part-time</option>
        <%}if (WI.fillTextValue("pt_ft").equals("1")){%>
        <option value="1" selected>Full-time</option>
        <%}else{%>
        <option value="1">Full-time</option>
        <%}%>
      </select></td>
    </tr>
		<%if(bolIsSchool){%>
		<tr>
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td>
	   <select name="employee_category" onChange="ReloadPage();">          
        <option value="">All</option>
				<%if (WI.fillTextValue("employee_category").equals("0")){%>
				  <option value="0" selected>Non-Teaching</option>
        <%}else{%>
          <option value="0">Non-Teaching</option>				
        <%}if (WI.fillTextValue("employee_category").equals("1")){%>
          <option value="1" selected>Teaching</option>
        <%}else{%>
          <option value="1">Teaching</option>
        <%}%>
       </select></td>
    </tr>
		<%}%>
    <% 	
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td> <select name="c_index" onChange="loadDept();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td>
			<label id="load_dept">
	  	<select name="d_index">
          <option value="">ALL</option>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
      </select>	  
			</label>			</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee ID </td>
      <td height="10"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
      <strong><a href="javascript:OpenSearch();"></a></strong>
			<label id="coa_info"></label></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>Salary Status </td>
			<%
				strTemp = WI.fillTextValue("sal_release_stat");
			%>
      <td>
			<select name="sal_release_stat">
			<%for(i = 0; i < astrSalaryStat.length;i++){
				if(i == 1)
					continue;
			
					if(strTemp.equals(Integer.toString(i))){%>
				<option value="<%=i%>" selected><%=astrSalaryStat[i]%></option>
				<%}else{%>
				<option value="<%=i%>"><%=astrSalaryStat[i]%></option>
			<%}
			}%>
			</select>			</td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1" color="#000000"></td>
    </tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td height="29"><select name="sort_by1">
        <option value="">N/A</option>
					<%=rptExtn.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
					<%=rptExtn.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>      
				</select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>        
					<%=rptExtn.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
      </select></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td width="11%" height="15">&nbsp;</td>
      <td><select name="sort_by1_con">
        <option value="asc">Ascending</option>
        <%
	if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
      <td><select name="sort_by2_con">
        <option value="asc">Ascending</option>
        <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
      <td><select name="sort_by3_con">
        <option value="asc">Ascending</option>
        <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">
        <input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
        <font size="1">click to display employee list to print.</font></td>
    </tr>
  </table>    
  <% if (vRetResult != null &&  vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <%if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/rptExtn.defSearchSize;		
	if(iSearchResult % rptExtn.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    
    <%} // end if pages > 1
		}// end if not view all%>
	<%if(WI.fillTextValue("sal_release_stat").equals("2")){%>
    <tr>
      <td align="right"><font size="2"> Number of Employees Per Page :</font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i =20; i <=45 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}
			}%>
        </select>
        <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print List </font></td>
    </tr>
		<%}%>		
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
			<%
				strTemp = WI.fillTextValue("sal_release_stat");
				if(strTemp.equals("0"))
					strTemp = " HAVING UNRELEASED SALARY FOR PERIOD";
				else
					strTemp = " HAVING ON HOLD SALARY FOR PERIOD";
			%>
      <td height="20" colspan="8" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF EMPLOYEES <%=strTemp%></strong></td>
    </tr>
    <tr>
      <td width="3%" class="thinborder">&nbsp;</td>
      <td width="10%" class="thinborder">&nbsp;</td> 
      <td width="29%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="30%" align="center" class="thinborder"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">SALARY</font></strong></td>
      <%if(WI.fillTextValue("sal_release_stat").equals("2") && iAccessLevel == 2){%>
			<td width="9%" align="center" class="thinborder"><strong>PRINT</strong></td>
			<%}%>
      <td width="9%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
        </strong>
        <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>
      </font></td>
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
      <td align="center" class="thinborder">
				<a href='javascript:PrintSlip("<%=(String)vRetResult.elementAt(i)%>",
	  								"<%=WI.fillTextValue("sal_period_index")%>",
									"<%=(String)vRetResult.elementAt(i+7)%>",
									"<%=(String)vRetResult.elementAt(i+9)%>",
									"<%=iCount%>","<%=WI.fillTextValue("pt_ft")%>",
									"<%=WI.fillTextValue("is_atm")%>",
									"<%=WI.fillTextValue("tenure_name")%>",
									"<%=(String)vRetResult.elementAt(i+12)%>",
									"<%=WI.fillTextValue("is_weekly")%>",
									"<%=(String)vRetResult.elementAt(i+13)%>")'>
									<img src="../../../../images/print.gif" border="0"></a> </td>
			<%}%>
      <td align="center" class="thinborder">
			<% 
			strTemp = (String)vRetResult.elementAt(i+15);
			if(strTemp.equals("1")){%>
			Finalized<input type="hidden" name="save_<%=iCount%>" value="">
			<%}else{%>
			<input type="checkbox" name="save_<%=iCount%>" value="1" checked tabindex="-1">
			<%}%>			</td>
    </tr>
    <%} //end for loop%>
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
		<%if(iAccessLevel == 2){%>
    <tr>
      <td height="25" colspan="8">Note : If you print payslip from this page, the salary status will be finalized/released.</td>
    </tr>
    <tr>
			<%
				strTemp = WI.fillTextValue("salary_stat_new");
			%>
      <td height="25" colspan="8">
			New Salary Status : 
			<select name="salary_stat_new">
        <%for(i = 0; i < astrSalaryStat.length;i++){
					if(i == 1)
						continue;
				
					if(strTemp.equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected><%=astrSalaryStat[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrSalaryStat[i]%></option>
        <%}
			}%>
      </select></td>
    </tr>
    <tr>
      <td height="25" colspan="8" align="center">				
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:SaveData();">
				<font size="1">Click to save entries</font>
			  <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">
				<font size="1"> click to cancel</font></td>
    </tr>
		<%}else{%>
    <tr>
      <td height="25" colspan="8" align="center">Only those with full access will be allowed to use this page.</td>
    </tr>
		<%}%>
    <input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
<% } // end vRetResult != null && vRetResult.size() > 0 %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="searchEmployee" > 
  <input type="hidden" name="page_action">	
	<input type="hidden" name="copy_all">		
	<input type="hidden" name="sal_period_val">		
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>