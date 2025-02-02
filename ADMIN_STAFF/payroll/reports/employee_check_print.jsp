<%@ page language="java" import="utility.*,java.util.Vector, payroll.PRSalaryExtn,payroll.PReDTRME,java.sql.Date" buffer="16kb"%>
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
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
	int iSearchResult = 0;
	boolean bolFixed = false;
	boolean bolHasSavedCheck = false;
	double dTemp = 0d;
	String strLine = null;
	
		vRetResult = prSalExtn.viewEmployeesWithCheck(dbOP,request);
		
		if (vRetResult == null){
			strErrMsg = prSalExtn.getErrMsg();	
		}else{
			iSearchResult = prSalExtn.getSearchCount();
		}
		
%>
<body bgcolor="#FFFFFF" onLoad="window.print()">
<form action="employee_check_print.jsp" name="form_" method="post">
<%if(vRetResult != null && vRetResult.size() > 0){
	strTemp = "Employee with Checks";
	if(WI.fillTextValue("cancelled_only").length() > 0){
		strTemp = "Employee with Cancelled Checks";
	}	
	String strCutOff = (String)vSalaryPeriod.elementAt(i+1) + "-" +(String)vSalaryPeriod.elementAt(i+2);
	strTemp2 = null;
	for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
			if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += "Whole Month";
			}else{
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			}
	}//end for loop	
				
%>
   <input type="hidden" name="amount" value='<%=(String)vRetResult.elementAt(8)%>'>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">  
    <tr> 
      <td height="28" colspan="8"  align="center"><strong><%=strTemp%></strong></td>
    </tr>
	 <tr> 
      <td height="28" colspan="8"  align="center">Salary Period: <%=strTemp2%> (<%=WI.getStrValue(strCutOff, "Cut Off : ","","")%>)</td>
    </tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">  
	<tr><td height="10">&nbsp;</td></tr>
	<tr><td  height="10" colspan="8"align="right"> Date and time printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;</td></tr>
	
    <tr>       
      <td width="8%" align="center" class="thinborder" height="29" style="border-top: solid 1px #000000"><font size="1"><strong>EMPLOYEE ID </strong></font></td>
      <td width="16%" align="center" class="thinborder" style="border-top: solid 1px #000000"><font size="1"><strong>EMPLOYEE NAME </strong></font></td>
      <td width="16%" align="center" class="thinborder" style="border-top: solid 1px #000000"><font size="1"><strong>DEPARTMENT/OFFICE </strong></font></td>
	  <td width="8%" align="center" class="thinborder" style="border-top: solid 1px #000000"><font size="1"><strong>AMOUNT </strong></font></td>	
	  <td width="11%" align="center" class="thinborder" style="border-top: solid 1px #000000"><font size="1"><strong>CHECK NUMBER </strong></font></td>
	  <%if(WI.fillTextValue("cancelled_only").length() > 0)
	  		strTemp = "";
		else
			strTemp = "border-right: solid 1px #000000;";
	  %>
	  <td width="16%" align="center" class="thinborder" style="border-top: solid 1px #000000;<%=strTemp%>"><font size="1"><strong>BANK </strong></font></td>	  
	  <%if(WI.fillTextValue("cancelled_only").length() > 0){%>
	  	 <td width="11%" align="center" class="thinborder" style="border-top: solid 1px #000000"><font size="1"><strong>DATE CANCELLED</strong></font></td>
	  	 <td width="14%" align="center" class="thinborder" style="border-top: solid 1px #000000;border-right: solid 1px #000000;"><font size="1"><strong>REASON FOR CANCELLING</strong></font></td>
	  <%}%>		 
     
	</tr>
	 <% 
		int j = 0;
		for (i = 0; i< vRetResult.size() ; i+=12, iCount++) {
		%>
    <tr>      
			<td class="thinborder" height="25"><span class="thinborder" >&nbsp;<%=(String)vRetResult.elementAt(i+1)%></span></td>
			<td class="thinborder"><font size="1"><strong>&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>       						
			<td class="thinborder">
				<span class="thinborder">
					&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"")%><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"")%>				</span>			</td>	 
			<td class="thinborder"><span class="thinborder">&nbsp; 
			<%=WI.getStrValue(CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(i+7),"0"),true),"0")%></span></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
			 <%if(WI.fillTextValue("cancelled_only").length() > 0)
					strTemp = "";
				else
					strTemp = " style='border-right: solid 1px #000000'";
			 %>
			<td class="thinborder" <%=strTemp%>>&nbsp;<%=(String)vRetResult.elementAt(i+8)%></td>
			<%if(WI.fillTextValue("cancelled_only").length() > 0){%>
			 	<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+10)%></td>
				<td class="thinborder" style="border-right: solid 1px #000000">&nbsp;<%=(String)vRetResult.elementAt(i+11)%></td>
			<%}%>
			<!--<input type="hidden" name="check_index" value='<%=(String)vRetResult.elementAt(9)%>'> 	-->
			 
	</tr>
	 <%}// end for loop%>
  </table>     
	<input type="hidden" name="emp_count" value="<%=iCount%>">
   <%}//end vRetResult != null%>  
  
<input type="hidden" name="print_page">
<input type="hidden" name="searchEmployee_"> 
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>