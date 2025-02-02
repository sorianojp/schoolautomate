<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscDeduction, payroll.PReDTRME" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
///added code for HR/companies.
boolean bolPopUp = false;
String strReadOnly = "";
if(WI.fillTextValue("popup").length() > 0){
	bolPopUp = true;
	strReadOnly = " readonly";
}

boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
	boolean bolMyHome = false;	
	String strEmpID = null;
	boolean bolViewOnly = false;
	
//add security here.
	if (WI.fillTextValue("my_home").equals("1")){
		strColorScheme = CommonUtil.getColorScheme(9);
		bolMyHome = true;
		bolViewOnly = true;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Misc. Deduction posting</title>
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
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
function OpenSearch() {
	document.form_.donot_call_close_wnd.value="0";
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddRecord(){
	document.form_.donot_call_close_wnd.value="0";
	document.form_.page_action.value = "1";
	document.form_.print_page.value="";	
	document.form_.save.disabled = true;
	document.form_.submit();
//	this.SubmitOnce("form_");
}
function EditRecord(){
	document.form_.donot_call_close_wnd.value="0";
	document.form_.page_action.value = "2";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.donot_call_close_wnd.value="0";
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex){
	document.form_.donot_call_close_wnd.value="0";
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	document.form_.donot_call_close_wnd.value="0";
	
		location ="./post_ded.jsp?popup="+document.form_.popup.value+
							"&emp_id="+document.form_.emp_id.value+
							"&month_of="+document.form_.month_of.value+
							"&year_of="+document.form_.year_of.value+
							"&sal_period_index="+document.form_.sal_period_index.value+
							"&date_from="+document.form_.date_from.value+
							"&date_to="+document.form_.date_to.value;
}

function ReloadPage()
{
	document.form_.donot_call_close_wnd.value="0";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function viewList(table,indexname,colname,labelname,tablelist, 
									strIndexes, strExtraTableCond,strExtraCond,
									strFormField){
//	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname+
//	"&opner_form_name=form_";
	document.form_.donot_call_close_wnd.value="0";
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPg(){
	document.form_.donot_call_close_wnd.value="0";
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
function focusID() {	
	<%if(!bolPopUp){%>
	document.form_.emp_id.focus();
	<%}%>
}
function CopyID(strID)
{	
	document.form_.print_page.value="";
	document.form_.emp_id.value=strID;
	this.SubmitOnce("form_");

}

function ReloadMain(){
	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();

		window.opener.focus();
	}
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
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
function clearDates(){
	document.form_.start_date.value = "";
	document.form_.end_date.value = "";
} 

function UpdateValue(strRowIndex, strLabelID, strFieldName) {
	var strValue = prompt("Please enter new value","");
	if(strValue == null || strValue.length == 0) 
		return;
	//else I have to call for Ajax here.. 
	this.ajaxUpdateValue(strRowIndex, strLabelID, strValue, strFieldName, null);
}

function UpdatePayable(strRowIndex, strLabelID) {
	var strReason = prompt("Please enter reason for updating payable to zero","");
	if(strReason == null || strReason.length == 0) 
		return;
	//else I have to call for Ajax here.. 
	this.ajaxUpdateValue(strRowIndex, strLabelID, "0", "payable_bal", strReason);
}

function ajaxUpdateValue(strRowIndex, strLabelID, strValue, strFieldName, strReason) {
		var objCOAInput = document.getElementById(strLabelID);
		
		this.InitXmlHttpObject(objCOAInput, 2);
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=303&new_value="+strValue+
			"&post_deduct_index="+strRowIndex+"&fieldName="+strFieldName+
			"&reason="+strReason;
			
		this.processRequest(strURL);
}

function updatePreload(){	
	var loadPg = "./post_ded_preload_mgmt.jsp?opner_form_name=form_&opner_form_field=deduct_index"+
				 "&opner_form_field_value="+document.form_.deduct_index.value;
	var win=window.open(loadPg,"updatePreload",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function checkKeyPress(strFormName, strFieldName, strExtn, strKeyCode){
	/*
		strKeyCodes
			35 = end, 36 = home, 37 = left, 38 = up, 39 = right, 40 = down
			8 = backspace, 46 = delete
			96 - 105 - numpad
			48 - 57 - kanang sa taas na numbers
			110 - period sa main
			190 - period sa numpad
			111 - / sa keypad
			191 - / sa main
	*/
	//alert("strKeyCode - " + strKeyCode);
 	if((strKeyCode >= 35 && strKeyCode <= 40)		
		|| (strKeyCode >= 48	&& strKeyCode <= 57)
		|| (strKeyCode >= 96	&& strKeyCode <= 105)
		|| strKeyCode == 8	|| strKeyCode == 46)
		return;
	
	AllowOnlyFloat(strFormName, strFieldName);
}
 
-->
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	boolean bolIsRecurring = false;

if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="post_ded_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions (Per Employee)","post_ded.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
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
														"post_ded.jsp");
	strEmpID = (String)request.getSession(false).getAttribute("userId");
	if (strEmpID != null ){
		if(bolMyHome){
			iAccessLevel  = 2;
			request.getSession(false).setAttribute("encoding_in_progress_id",strEmpID);
		}
	}						

	strEmpID = WI.fillTextValue("emp_id");
 	if(strEmpID.length() == 0)
		strEmpID = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
	else	
		request.getSession(false).setAttribute("encoding_in_progress_id",strEmpID);
	strEmpID = WI.getStrValue(strEmpID, "");
	if (WI.fillTextValue("emp_id").length() == 0 && strEmpID.length() > 0){
		request.setAttribute("emp_id",strEmpID);
	}
	
	if (strEmpID == null) 
		strEmpID = "";

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vPersonalDetails = null;
Vector vRetResult = null;
Vector vEmpList = null;
Vector vDate = null;
boolean bolIsRestricted = false;

PRMiscDeduction prd = new PRMiscDeduction(request);
//start of authentication if employee is restricted for misc deduction
String strAuthID = (String) request.getSession(false).getAttribute("userIndex");
    if (strAuthID == null) {
       dbOP.cleanUP();
	   request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	   request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	   response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
    }
	
if( prd.hasRestrictionToMiscDeduction(dbOP,strAuthID) == true){ System.out.println("has restriction");%>
	<jsp:forward page="post_ded_restricted.jsp" />
<%}else
	System.out.println("No restriction");
//end of 2nd auth






PReDTRME prEdtrME = new PReDTRME();
Vector vSalaryPeriod 		= null;//detail of salary period.
String strSchCode = dbOP.getSchoolIndex();
	payroll.PRConfidential prCon = new payroll.PRConfidential();
	boolean bolCheckAllowed = true;
	if(!WI.getStrValue(strSchCode).toUpperCase().startsWith("FADI") && !bolMyHome)
		bolCheckAllowed = (prCon.checkIfEmpIsProcessor(dbOP, request, WI.fillTextValue("emp_id"), true) == 1);
	
if (WI.fillTextValue("emp_id").length() > 0 || strEmpID != null) {
	if(bolCheckAllowed){
		enrollment.Authentication authentication = new enrollment.Authentication();
		vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	
		if (vPersonalDetails == null || vPersonalDetails.size()==0){
			strErrMsg = authentication.getErrMsg();
			vPersonalDetails = null;
		}	
	}else
	   strErrMsg = prCon.getErrMsg();
 }

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");

String strDateFr = null;
String strDateTo = null;
String strPayrollPeriod  = null;
String strEmployeeIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
int iSearchResult = 0;
int i = 0;
double dPayable = 0d;

if (strPageAction.length() > 0){
	if (strPageAction.compareTo("0")==0) {
		if (prd.operateOnMiscDeductions(dbOP,request,0) != null){
			strErrMsg = " Deduction removed successfully ";
		}else{
			strErrMsg = prd.getErrMsg();
		}
	}else if(strPageAction.compareTo("1") == 0){
		if (prd.operateOnMiscDeductions(dbOP,request,1) != null){
			strErrMsg = " Deduction posted successfully ";
		}else{
			strErrMsg = prd.getErrMsg();
		}
	}else if(strPageAction.compareTo("2") == 0){
		if (prd.operateOnMiscDeductions(dbOP,request,2) != null){
			strErrMsg = " Deduction updated successfully ";
			strPrepareToEdit = "";
		}else{
			strErrMsg = prd.getErrMsg();
			if(strErrMsg.startsWith("Salary of"))
				strPrepareToEdit = "";
		}
	}
}
 	if (WI.fillTextValue("emp_id").length() > 0 || strEmpID != null) {
		/*		vDate = prd.getSalaryPeriodInfo(dbOP,WI.getTodaysDate());
			if(vDate != null && vDate.size() > 0){
			  strDateFr = (String)vDate.elementAt(0);
			  strDateTo = (String)vDate.elementAt(1);
			}else{
			  strDateFr = "";
			  strDateTo = "";
			}*/
		vRetResult = prd.operateOnMiscDeductions(dbOP,request,4);
 		if(vRetResult == null && strErrMsg == null){
			strErrMsg = prd.getErrMsg();
		}else{
			iSearchResult = prd.getSearchCount();
		}
		vEmpList = prd.getEmployeesList(dbOP);
		
	}


Vector vInfoDetail = null;
if (strPrepareToEdit.length() > 0){
	vInfoDetail = prd.operateOnMiscDeductions(dbOP, request, 3);
	if (vInfoDetail == null)
		strErrMsg = prd.getErrMsg();
}

if(WI.fillTextValue("view").length() > 0){
	bolViewOnly = true;
	strReadOnly = " readonly";
}

	if(WI.fillTextValue("year_of").length() > 0 && WI.fillTextValue("reset_page").length() == 0) {
		vSalaryPeriod = prEdtrME.getEmployeePeriods(dbOP, request, strEmployeeIndex);
		if(vSalaryPeriod == null)
			strErrMsg = prEdtrME.getErrMsg();

	}
%>
<body bgcolor="#D2AE72" onLoad="focusID();" onUnload="ReloadMain();" class="bgDynamic">
<form action="post_ded.jsp" method="post" name="form_" id="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr bgcolor="#A49A6A">
		<td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
		 MISC. DEDUCTIONS : POST DEDUCTIONS PAGE ::::</strong></font></td>
	</tr>
</table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		
    <tr>
      <td height="23" colspan="4"><strong><font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>		
</table>	
 <%if(!bolMyHome){%>
 <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<% if(!bolPopUp){%>		
    <tr>
      <td height="23" colspan="2"><a href="./misc_deduction_main.jsp"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></td>
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
<%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) < vEmpList.size()-1){%>
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
						
    <tr>
      <td width="13" height="10">&nbsp;</td>
      <td width="149" >Employee ID</td>
			<%
				if(strReadOnly.length() == 0)
					strReadOnly = "onKeyUp = AjaxMapName(1);";
			%>
		  <td width="272">
			<input name="emp_id" type="text" class="textbox" <%=strReadOnly%> 
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			value="<%=WI.fillTextValue("emp_id")%>" size="16">
	    <a href="javascript:OpenSearch()">
			<%if(!bolPopUp){%>
			<%if(!bolViewOnly){%>
			<img src="../../../images/search.gif" width="37" height="30" border="0">
      <%}%>
			<%}%>			
			</a>			</td>		        
      <td width="307"><div style="position:absolute;" ><label id="coa_info"></label></div></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Salary period for Yr</td>
      <td height="10">
			<select name="month_of" onChange="document.form_.reset_page.value='1';ReloadPage();">
        <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%>
      </select>
-
<select name="year_of" onChange="document.form_.reset_page.value='1';ReloadPage();">
  <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%>
</select></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Salary Period</td>
			<%
				if(vInfoDetail != null) {
					strTemp= (String)vInfoDetail.elementAt(20);
					if(strTemp == null || strTemp.length() == 0)
						strTemp = WI.fillTextValue("sal_period_index");
				}else
					strTemp = WI.fillTextValue("sal_period_index");
				strTemp = WI.getStrValue(strTemp);
			%>			
      <td height="10" colspan="2">
 			<select name="sal_period_index" style="font-weight:bold;font-size:11px" onChange="clearDates();ReloadPage();">
        <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};
	 	
		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
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
		  	strDateFr = (String)vSalaryPeriod.elementAt(i+1);
		  	strDateTo = (String)vSalaryPeriod.elementAt(i+2);
		  %>
        <%}else{%>
        <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
        <%}//end of if condition.
		 }//end of for loop.%>
      </select>
			<input type="hidden" name="date_from" value="<%=strDateFr%>">
		  <input type="hidden" name="date_to" value="<%=strDateTo%>"><font size="1">(period when the misc posting will be deducted from employee)</font></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td><input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #000000;" onClick="javascript:ReloadPage();"></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
			<%}else{%>
	<input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
	<input type="hidden" name="month_of" value="<%=WI.fillTextValue("month_of")%>">
	<input type="hidden" name="year_of" value="<%=WI.fillTextValue("year_of")%>">
	<input type="hidden" name="sal_period_index" value="<%=WI.fillTextValue("sal_period_index")%>">	
	<input type="hidden" name="date_from" value="<%=WI.fillTextValue("date_from")%>">	
	<input type="hidden" name="date_to" value="<%=WI.fillTextValue("date_to")%>">	
	<%}%>
  </table>
  <%}else{// if(!bolMyHome)%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		
    <tr>
      <td width="4%">&nbsp;</td>
      <td width="96%" height="19">Employee ID :         
				<input type="text" name="emp_id" value="<%=strEmpID%>" size="32" class="textbox_noborder" readonly>
			</td>
    </tr>		
	</table>	
	<%}%>
	<% if (vPersonalDetails !=null && vPersonalDetails.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="4%" height="28">&nbsp;</td>
      <td height="28" colspan="2">Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <%
	strTemp = (String)vPersonalDetails.elementAt(13);
	if (strTemp == null){
		strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
	}else{
		strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
	}
%>
      <td height="29" colspan="2"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td width="46%">Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%>
        </strong></td>
      <td width="50%" height="29">Employment Status : <strong><%=(String)vPersonalDetails.elementAt(16)%>
        </strong></td>
    </tr>
    <tr>
      <td height="15" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
<%if(!bolViewOnly){%>
<%if(WI.fillTextValue("sal_period_index").length() > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="29">&nbsp;</td>
      <td width="19%" height="29">Deduction Name </td>
      <td width="78%"><select name="deduct_index" id="deduct_index">
          <%	if(vInfoDetail!=null) strTemp= (String)vInfoDetail.elementAt(1);
	else strTemp= WI.fillTextValue("deduct_index");%>
          <option value="">Select Deduction Name</option>
          <%=dbOP.loadCombo("PRE_DEDUCT_INDEX","PRE_DEDUCT_NAME", " from preload_deduction order by pre_deduct_name",strTemp,false)%>
        </select>
				<%if(iAccessLevel > 1){%>
        <a href='javascript:updatePreload();'><img src="../../../images/update.gif" border="0" ></a>
			<font size="1">click to add to the list miscellaneous deductions</font>
				<%}%></td>
    </tr>
    <!--
    <tr>
			<td width="3%" height="29">&nbsp;</td>
      <td height="29">&nbsp;</td>			
      <td height="29"><strong>
        <%	if(vInfoDetail != null)
				strTemp= (String)vInfoDetail.elementAt(4);
			else
				strTemp= WI.fillTextValue("date_from");

			if(strTemp.trim().length() == 0)
				strTemp = strDateFr;
		%>
        <input name="date_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        </strong> to <strong>
        <%	if(vInfoDetail!=null)
				strTemp = (String)vInfoDetail.elementAt(5);
			else
				strTemp= WI.fillTextValue("date_to");

			if(strTemp.trim().length() == 0)
				strTemp = strDateTo;
		%>

        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        </strong></td>
    </tr>
		-->
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29">Amount<strong> </strong></td>
      <td height="29"><strong>
        <%	if(vInfoDetail!=null) strTemp= (String)vInfoDetail.elementAt(6);
	else strTemp= WI.fillTextValue("amount");%>
        <input  type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onblur="style.backgroundColor='white'"  name="amount" value="<%=strTemp%>" size="10" maxlength="10"
		title="Current Payable balance of the posting"	  
		onKeyUp="checkKeyPress('form_','amount',event.keyCode);">
			<%//onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"%>
        </strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Reference #</td>
      <td height="25"><strong>
        <%if(vInfoDetail != null) 
						strTemp= (String)vInfoDetail.elementAt(15);
					else 
						strTemp= WI.fillTextValue("ref_no");
				%>
        <input type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
				onblur="style.backgroundColor='white'"  name="ref_no" value="<%=WI.getStrValue(strTemp)%>" 
				maxlength="32"></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Maximum Deduction</td>
      <td><strong>
      <%	
				if(vInfoDetail != null) 
					strTemp= (String)vInfoDetail.elementAt(16);
				else 
					strTemp = WI.fillTextValue("max_deduction");
				strTemp = CommonUtil.formatFloat(strTemp, false);
				strTemp = ConversionTable.replaceString(strTemp, ",","");
			%>
        <input  type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onblur="style.backgroundColor='white'"  name="max_deduction" value="<%=WI.getStrValue(strTemp)%>" size="10" maxlength="10"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"		  >
      </strong>
			<font size="1">(Set this to blank or zero if misc. deduction is to be deducted as soon as possible)</font></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>Previous Payments</td>
      <td><strong>
			<%	
				if(vInfoDetail != null) 
					strTemp= (String)vInfoDetail.elementAt(17);
				else 
					strTemp = WI.fillTextValue("payment_to_date");
				strTemp = CommonUtil.formatFloat(strTemp, false);
				strTemp = ConversionTable.replaceString(strTemp, ",","");
			%>
      <input type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
			 onblur="style.backgroundColor='white'"  name="payment_to_date" 
			 value="<%=WI.getStrValue(strTemp)%>" size="10" maxlength="10"
			 title="Total amount of payment before posting in the system. "
	  	 onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
			  
			 >
        </strong><font size="1">Total amount of payment made before posting in the system</font></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>From</td>
      <td>
			<%
				if(vInfoDetail != null) 
					strTemp= (String)vInfoDetail.elementAt(18);
				else
					strTemp = WI.fillTextValue("start_date");
				strTemp = WI.getStrValue(strTemp);
 				if(strTemp == null || strTemp.length() == 0)
					strTemp = strDateFr;
				strTemp = WI.getStrValue(strTemp);
			%>
        <input name="start_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.start_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>      </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>To</td>
      <td> 
      <%	
				if(vInfoDetail != null) 
					strTemp= (String)vInfoDetail.elementAt(19);
				else 
					strTemp = WI.fillTextValue("end_date");
				strTemp = WI.getStrValue(strTemp);
 				if(strTemp == null || strTemp.length() == 0)
					strTemp = strDateTo;
				strTemp = WI.getStrValue(strTemp);
			%>			
      <input name="end_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			 title="Estimated date when the deduction would be fully paid.">
  		<a href="javascript:show_calendar('form_.end_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>  		</td>
    </tr>
    <tr>
      <td height="21">&nbsp;</td>
      <td>Remarks</td>
      <td>
			<%	
				if(vInfoDetail != null) 
					strTemp= (String)vInfoDetail.elementAt(21);
				else 
					strTemp = WI.fillTextValue("misc_note");
				strTemp = WI.getStrValue(strTemp);
			%>
      <input name="misc_note" type="text" size="48" maxlength="128" 
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			value="<%=strTemp%>" class="textbox">
			</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td colspan="2">Note : <font size="1">Date from and date to are just for reporting purposes. 
														These values will not stop or halt the deductions of the employee even 
														though the current period will be outside the range entered</font></td>
    </tr>
  <%if (iAccessLevel > 1) { //if iAccessLevel > 1%>
	
	<tr>
	  <td height="21">&nbsp;</td>
	  <td height="21" colspan="2" align="center">&nbsp;</td>
	  </tr>
	<tr>
      <td height="29">&nbsp;</td>
      <td height="29" colspan="2" align="center">
			<%if (vInfoDetail == null) {%>
        <!--
					<a href="javascript:AddRecord();"><img src="../../../images/save.gif" width="48" height="28" border="0"></a>
					-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:AddRecord();">
				<font size="1">click to add</font>
        <%}else{%>
        <!--
					<a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a>
					-->
				<input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:EditRecord();">
				<font size="1">click to save changes</font>
        <%}%>
        <!--
					<a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
					-->
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">
        <font size="1">click to cancel or go previous</font>      </td>
    </tr>
<%} //end iAccessLevel > 1%>
  </table>
	<%} // if sal_period_index > 0%>
<%}//end if bolIsView is false..%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
	<%
		if(WI.fillTextValue("show_option").length() > 0)
			strTemp = " checked";
		else
			strTemp = "";
	%>	
    <td colspan="2"><input type="checkbox" name="show_option" value="1" <%=strTemp%> onClick="ReloadPage();">
		Show View Options</td>
    </tr>
	<%if(WI.fillTextValue("show_option").length() > 0){%>
  <tr>
    <td width="5%">&nbsp;</td>
      <%if(WI.fillTextValue("show_paid").length() > 0)
		  	  strTemp = " checked";
			else
			  strTemp = "";
		  %>
    <td width="95%">(<input name="show_paid" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">
click to include in table already paid dues)</td>
  </tr>
  	
  <tr>
    <td>&nbsp;</td>
    <td><table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">						
						<!--
						<tr>
							<td width="9%" height="25">Period</td>
							<td width="85%" height="25"><input name="search_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("search_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
                <a href="javascript:show_calendar('form_.search_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> to
                <input name="search_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("search_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
                <a href="javascript:show_calendar('form_.search_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
						</tr>
						-->
						<tr>
							<td width="11%" height="25">Deduction</td>
							<%
								strTemp = WI.fillTextValue("search_ded_index");
							%>
							<td width="89%" height="25">
							<select name="search_ded_index" id="select">                
                <option value="">ALL</option>
                <%=dbOP.loadCombo("PRE_DEDUCT_INDEX","PRE_DEDUCT_NAME", " from preload_deduction order by pre_deduct_name",strTemp,false)%>
              </select></td>
						</tr>						
						<tr>
						  <td height="17" colspan="2"><input type="button" name="122" value=" Search " style="font-size:11px; height:24px;border: 1px solid #000000;" onClick="javascript:ReloadPage();"></td>
				  </tr>
						<tr>
							<td height="17" colspan="2"><hr size="1" color="#000000"></td>
						</tr>
					</table>			</td>
  </tr>
	<%}%>
</table>
<%if (vRetResult != null &&  vRetResult.size() > 0) {
	String strTDColor = null;//grey if already deducted.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2"><div align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a>
          click to print</font></div></td>
    </tr>
    <%
		int iPageCount = iSearchResult/prd.defSearchSize;		
		if(iSearchResult % prd.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2"><div align="right">Jump To page:
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
      </div></td>
    </tr>
		<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="26" colspan="11" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST
      OF POSTED MISCELLANEOUS DEDUCTIONS</strong></td>
    </tr>
    <tr>
      <td width="18%" align="center" class="thinborder"><strong><font size="1">DEDUCTION NAME</font></strong></td>
      <td width="18%" height="28" align="center" class="thinborder"><strong><font size="1">START DEDUCTION<br>(in System)</font></strong></td>
      <td width="19%" align="center" class="thinborder"><strong><font size="1">DEDUCTION RANGE </font></strong></td>
      <td width="11%" align="center" class="thinborder"><font size="1"><strong>AMOUNT</strong></font></td>
	    <td width="10%" align="center" class="thinborder"><font size="1"><strong>MAX DEDUCTION </strong></font></td>
	    <td width="10%" align="center" class="thinborder"><font size="1"><strong>PAYABLE BALANCE</strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>DATE POSTED</strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>DETAILS</strong></font></td>
      <!--
			<td align="center" class="thinborder"><font size="1"><strong>POSTED BY</strong></font></td>
			-->
 <%if(!bolViewOnly && !bolPopUp){%>
      <td colspan="2" align="center" class="thinborder"><font size="1"><strong>OPTIONS</strong></font></td>
 <%}%>
    </tr>
	<% for (i = 0; i < vRetResult.size(); i+=25){
		bolIsRecurring = false;
		strTemp = (String)vRetResult.elementAt(i + 8);
 		if(strTemp != null && !strTemp.equals("0")){
			strTDColor = "bgcolor=#DDDDDD";
			if(strTemp.equals("2")){
				strTemp2 = "Recurring";
				bolIsRecurring = true;
			}else if(strTemp.equals("3")){
				strTemp2 = "Stopped";
			} else {
				strTemp2 = "&nbsp;";
			}
		}else{
			strTDColor = "";
			//strTemp2 = (String)vRetResult.elementAt(i+4) +"-"+
			strTemp2 = (String)vRetResult.elementAt(i+5);
 		}
	%>
    <tr <%=strTDColor%>>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td class="thinborder"><font size="1"><%=strTemp2%></font></td>
			<%
				strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+18), ""," - "+(String)vRetResult.elementAt(i+19),"&nbsp;");
			%>
			<td class="thinborder"><font size="1"><%=strTemp2%></font></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+6),true);
			%>			
      <td align="right" class="thinborder"><font size="1"><%=strTemp%>&nbsp;</font></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+16),true);
			%>				
			<td align="right" class="thinborder">
 			<font size="1"><label id="max_ded_<%=i%>" <%if(!bolIsRecurring){%>onDblClick="UpdateValue('<%=vRetResult.elementAt(i)%>','max_ded_<%=i%>', 'max_deduction');"<%}%>>
			<%=strTemp%>&nbsp;</label></font></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+13),true);
				dPayable = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
			%>						
	    <td align="right" class="thinborder">
			<!--
			onDblClick="UpdateValue('<%=vRetResult.elementAt(i)%>','payable_<%=i%>', 'payable_bal');"
			-->
			<font size="1"><label id="payable_<%=i%>"<%if(!bolIsRecurring && dPayable > 0d){%>onDblClick="UpdatePayable('<%=vRetResult.elementAt(i)%>','payable_<%=i%>');"<%}%>>
			<%=strTemp%>&nbsp;</label></font>			</td>
      <td width="10%" align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></td>
			<td width="10%" align="center" class="thinborder">&nbsp;</td>
			<!--
      <td width="12%" height="25" class="thinborder"><font size="1">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+10),
								(String)vRetResult.elementAt(i+11),(String)vRetResult.elementAt(i+12),4)%></font></td>
			-->			
 <%if(!bolViewOnly && !bolPopUp){%>
      <td width="6%" class="thinborder">
	  <% if (iAccessLevel > 1 && strTDColor.length() == 0){%>
	  <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border="0" ></a>
	  <%}else{%> N/A <%}%>	  </td>

      <td width="8%" align="center" class="thinborder">
	  <%if (iAccessLevel==2 && strTDColor.length() == 0) {%>
	  <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0" ></a>
	  <%}else{%>
	  N/A
	  <%}%>	  </td>
<%}%>
    </tr>
    <%} //end for loop%>
  </table>

<% } // end vRetResult != null && vRetResult.size() > 0

}// end if Employee ID is null %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="print_page">
<input type="hidden" name="reset_page">
<%if(bolViewOnly){%>
<input type="hidden" name="view" value="1">
<%}%>
<input type="hidden" name="popup" value="<%=WI.fillTextValue("popup")%>">

<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
<!-- this is very important - onUnload do not call close window -->

<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
