<%@ page language="java" import="utility.*,payroll.PReDTRME, payroll.PRSalary,payroll.ReportPayroll, 
	payroll.PRMiscDeduction, payroll.PRRetirementLoan, java.util.Vector, java.util.Date" buffer="16kb"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><head>
<title>Manual Employee contribution</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
</style>
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
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript">
function ReloadPage() {	
	document.form_.prepareToEdit.value = "0";
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function CancelRecord(){
	document.form_.prepareToEdit.value = "0";
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}

function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;		
	if(strAction == 1) 
		document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('form_');
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function FocusID() {
	document.form_.emp_id.focus();
}

function UpdateToZero(strTextName){
	if(eval('document.form_.'+strTextName+'.value.length') == 0){		
		eval('document.form_.'+strTextName+'.value= "0"');
	}	
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	WebInterface WI = new WebInterface(request);
	
	int i = 0;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");	

	//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-DTR"),"0"));
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
								"Admin/staff-Payroll-DTR-DTR Entry (Manual)","cont_manual_entry.jsp");
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
	Vector vRetResult = null;
	PRSalary salary = new PRSalary();
	ReportPayroll RptPay = new ReportPayroll(request);
		
	Vector vPersonalDetails = null; 
	Vector vMiscDeductions  = null;
	Vector vLoans			= null;
	double dLoansAdvMisc    = 0d;
	boolean bolMoreDeduct = false;
	
	String strEmpID = WI.fillTextValue("emp_id");
	String strReadOnly = null;	
	String strMonthTo = null;
    String strSYFr   = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	String strSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	String strCurSem = (String)request.getSession(false).getAttribute("cur_sem");
	int iCount = 0;
	int l = 0;	
	int iRow = 0;
	int iItems = 0;
	boolean bolIsReleased = false;
	String strEmpIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));	
	String[] astrQuarterName = {"January - March", "April - June", "July - September", "October - December"};
	String[] astrHalfName = {"1st Half(Jan - Jun)", "2nd Half(July - December)"};
	String strSQLQuery = null;
	String strApplicableDur = "";

	String strSchCode = dbOP.getSchoolIndex();	
	String strPageAction = WI.fillTextValue("page_action");
  	  if(strPageAction.length() > 0) {
		if(salary.operateOnAddlMonthPay(dbOP, request, Integer.parseInt(strPageAction)) == null)
			strErrMsg = salary.getErrMsg();
		else {	
			if(strPageAction.equals("1"))
				strErrMsg = "Bonus successfully posted.";
			if(strPageAction.equals("2"))
				strErrMsg = "Bonus successfully edited.";
		}
	  }	
	
if (strEmpID.length() > 0 && WI.fillTextValue("reset_page").length() == 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");

	if(vPersonalDetails == null){
		strErrMsg = "Employee Profile not Found";
	}
	
	if(WI.fillTextValue("contribution_index").length() > 0){
	  strSQLQuery = 
	  	"select applicable_dur from hr_benefit_incentive " +
		" where benefit_index = " + WI.fillTextValue("contribution_index");
	  strApplicableDur = dbOP.getResultOfAQuery(strSQLQuery,0);
	 //System.out.println("strApplicableDur " + strApplicableDur);
	  vRetResult = salary.operateOnAddlMonthPay(dbOP,request,4);	  
	}	
}

%>
<form name="form_" action="./cont_manual_entry.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PAYROLL :  CONTRIBUTIONS MANUAL ENTRY PAY PAGE ::::</strong></font></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>      
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="19%">Employee ID</td>
      <td width="78%"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Contribution name </td>
	  <%
	  	strTemp = WI.fillTextValue("contribution_index");
	  %>	  
      <td><select name="contribution_index" onChange="ReloadPage();">
        <option value="">Select Contribution Name</option>
        <%=dbOP.loadCombo("hr_benefit_incentive.BENEFIT_INDEX","benefit_name, sub_type", " from HR_PRELOAD_BENEFIT_TYPE  " +
		" join hr_benefit_incentive on (hr_preload_benefit_type.BENEFIT_TYPE_INDEX = hr_benefit_incentive.BENEFIT_TYPE_INDEX)" +
		" where hr_benefit_incentive.IS_VALID = 1 and hr_preload_benefit_type.IS_INCENTIVE = 0 " +
		" and hr_benefit_incentive.IS_BENEFIT = 0 " +
		" and (APPLICABLE_DUR  = 3 or APPLICABLE_DUR  = 4 or APPLICABLE_DUR = 5)" +
		" and benefit_name not in('loans','loan','leave','leave')", strTemp,false)
		
				/*
		select EMPLOYEE_SHARE, ELIGIBILITY_UNIT, ELIGIBILITY,  
		, SUB_TYPE, APPLICABLE_DUR, 
		COVERAGE_UNIT, IS_ADDED_PR, hr_preload_benefit_type.IS_INCENTIVE,
		hr_benefit_incentive.IS_BENEFIT
		  
		 */
		%>

		
      </select></td>
    </tr>
	<%if(strApplicableDur.equals("3")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Quarter</td>
      <td><select name="quarter">
        <%for(i = 0; i < 4; i++){
		  	if(WI.fillTextValue("quarter").equals(Integer.toString(i))){
		%>
        <option value="<%=i%>" selected><%=astrQuarterName[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrQuarterName[i]%></option>
        <%}%>
        <%}%>
      </select></td>
    </tr>
	<%}else if(strApplicableDur.equals("4")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Half</td>
      <td><select name="half">
        <%for(i = 0; i < 2; i++){
		  	if(WI.fillTextValue("half").equals(Integer.toString(i))){
		%>
        <option value="<%=i%>" selected><%=astrHalfName[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrHalfName[i]%></option>
        <%}%>
        <%}%>
      </select></td>
    </tr>
	<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Year</td>
      <td> 
        <select name="year_of" onChange="document.form_.reset_page.value='1';ReloadPage();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>      </td>
    </tr>
    
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a><font size="1">Click 
        to reload page.</font></td>
    </tr>
    <tr> 
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
  </table>
 <% if(vPersonalDetails != null && vPersonalDetails.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td height="29">Employee Name : </td>
      <td><strong>&nbsp;<%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Employee ID : </td>
      <td><strong>&nbsp;<%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29"> <%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : </td>
		  <%
		strTemp = (String)vPersonalDetails.elementAt(13);
		if (strTemp == null){
			strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
		}else{
			strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
		}
		%>
      <td><strong>&nbsp;<%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td>Employment Type/Position : </td>
      <td><strong>&nbsp;<%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td width="25%">Employment Status<strong> : </strong></td>
      <td width="72%"><strong>&nbsp;<%=(String)vPersonalDetails.elementAt(16)%></strong></td>
    </tr>
    
    <tr> 
      <td  height="10" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="25%">Employee Contribution : </td>
	  <%
		strTemp = WI.fillTextValue("contribution");
  	  %>
      <td width="47%"><input name="contribution" type="text" class="textbox"
	  	onFocus="style.backgroundColor='#D3EBFF'" style="text-align : right"
	    onBlur="AllowOnlyFloat('form_','contribution');UpdateToZero('contribution');style.backgroundColor='white'" 
		onKeyUp="AllowOnlyFloat('form_','contribution');"
		value="<%=WI.getStrValue(strTemp,"0")%>" size="10" maxlength="10"></td>
      <td width="25%">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="46"  colspan="3" valign="bottom" bgcolor="#FFFFFF"><div align="center">
          <%if(strPrepareToEdit.compareTo("1") != 0) {%>
          <%if(iAccessLevel > 1) {%>
          <a href='javascript:PageAction(1, "");'><img src="../../../images/save.gif" border="0" id="hide_save"></a> 
          <font size="1"> click to save entries</font> 
          <%}%>
		  <%}else{%>
          <a href='javascript:PageAction(2,"");'> <img src="../../../images/edit.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> 
          click to save changes</font> 
		  <%}%>
          <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
          <font size="1" face="Verdana, Arial, Helvetica, sans-serif"> click to 
          cancel or go previous</font> 
          <hr size="1" color="#0000FF">
        </div></td>
    </tr>
  </table>
  <%}%>
  <table cellpadding="0" cellspacing="0" width="100%">
    <tr>
      <td height="20"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
</table>
  
  <input type="hidden" name="month_to" value="<%=strMonthTo%>">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">  
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="reset_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>