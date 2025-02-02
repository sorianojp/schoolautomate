<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRLoansAdv" %>
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
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
<!--
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function StopLoan(strInfoIndex){
	document.form_.page_action.value = "6";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex,strPayable){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.payable.value = strPayable;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./loans_advances_entry.jsp?emp_id="+document.form_.emp_id.value;
}

function ReloadPage()
{
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function ComputeDue(){
	
	if (document.form_.terms.value.length > 0){
		if (eval(document.form_.terms.value) !=0){
			document.form_.due.value = eval(document.form_.amount.value)/eval(document.form_.terms.value);
			document.form_.due.value = truncateFloat(document.form_.due.value,1,false);
		}
	 }else{
		 document.form_.due.value ="0";
	 }
	
}
function focusID() {
	document.form_.emp_id.focus();
}

-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./loans_advances_entry_print.jsp" />
<% return;}

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES"),"0"));
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
								"Admin/staff-Payroll-LOANS/ADVANCES-Create Loans","loans_advances_entry.jsp");
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
Vector vPersonalDetails = null;
Vector vRetResult = null;
Vector vInfoDetail = null;
Vector vDate = null;

PRLoansAdv prd = new PRLoansAdv(request);

String[]  astrSchedDeduct={
	"Every Salary Period", "Every 5th of Month", "Every 15th of Month", "Every 20th of Month",
	"Every end of Month", "Every Week"};


if (WI.fillTextValue("emp_id").length() > 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	
	if (vPersonalDetails == null || vPersonalDetails.size()==0){
		strErrMsg = authentication.getErrMsg();
		vPersonalDetails = null;
	}
}

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");
String strSalDateFr = null;
String strTDColor = null;
if (strPageAction.length() > 0){
	if (strPageAction.compareTo("0")==0) {
		if (prd.operateOnLoansAdv(dbOP,request,0) != null){
			strErrMsg = " Loan/Advance removed successfully ";
		}else{
			strErrMsg = prd.getErrMsg();
		}
	}else if(strPageAction.compareTo("1") == 0){
		if (prd.operateOnLoansAdv(dbOP,request,1) != null){
			strErrMsg = " Loan/Advance posted successfully ";
		}else{
			strErrMsg = prd.getErrMsg();
		}
	}else if(strPageAction.compareTo("2") == 0){
		if (prd.operateOnLoansAdv(dbOP,request,2) != null){
			strErrMsg = " Loan/Advance updated successfully ";
			strPrepareToEdit = "";
		}else{
			strErrMsg = prd.getErrMsg();
		}
	}else if(strPageAction.compareTo("6") == 0){
		if (prd.operateOnLoansAdv(dbOP,request,6) != null){
			strErrMsg = " Loan/Advance updated successfully ";
			strPrepareToEdit = "";
		}else{
			strErrMsg = prd.getErrMsg();
		}
	}
}

if (strPrepareToEdit.length() > 0){
	vInfoDetail = prd.operateOnLoansAdv(dbOP,request,3);
	if (vInfoDetail == null)
		strErrMsg = prd.getErrMsg();
}
vDate = prd.getSalaryPeriodInfo(dbOP,WI.getTodaysDate());
if(vDate!= null && vDate.size() > 0){
	strSalDateFr = (String)vDate.elementAt(0);
}

vRetResult = prd.operateOnLoansAdv(dbOP,request,4);
if (vRetResult == null && strErrMsg == null){						
	strErrMsg = prd.getErrMsg();
}
boolean bolViewOnly = false;
if(WI.fillTextValue("view").length() > 0)
	bolViewOnly = true;
%>


<body bgcolor="#D2AE72" onLoad="focusID();" class="bgDynamic">
<form name="form_" method="post" action="./loans_advances_entry.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PAYROLL: LOANS/PREMIUMS ENTRY PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><strong>&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="4%" height="30">&nbsp;</td>
      <td width="13%">Employee ID</td>
      <td width="14%"><input name="emp_id" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16">
      </td>
	  <%if(!bolViewOnly){%>
	      <td width="8%"><strong><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></strong></td>
	  <%}%>
      <td width="58%"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>

<% if (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails !=null && vPersonalDetails.size() > 0){ %>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="10" colspan="2"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="6%" height="29">&nbsp;</td>
      <td height="29">Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong> </td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Employee ID : <strong><%=WI.fillTextValue("emp_id")%></strong></td>
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
      <td height="29"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td>Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%></strong></td>

    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td width="94%">Employment Status<strong> : <%=(String)vPersonalDetails.elementAt(16)%> </strong></td>

    </tr>
    <tr> 
      <td height="25" colspan="2"><hr size="1" noshade></td>
    </tr>
  </table>
  <% if(vInfoDetail != null)  strTemp=(String)vInfoDetail.elementAt(15);
	  	strTemp = WI.fillTextValue("deduct_date");%>
<%if(!bolViewOnly){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29" colspan="2">Type : 
        <% 
	  	
		if (vInfoDetail != null) strTemp = (String)vInfoDetail.elementAt(7);
		else strTemp = WI.fillTextValue("benefit_index");
		
		//String strLoanIndex = dbOP.mapOneToOther("HR_PRELOAD_BENEFIT_TYPE","benefit_name","'loan'","benefit_type_index"," or benefit_name like 'loan%'");	
	  %> 
	  	<select name="benefit_index">
          <option value="">Select Premium/Loan Type</option>
          <%// if (strLoanIndex !=null && strLoanIndex.length()> 0){%>
          <%/*=dbOP.loadCombo("benefit_index", "sub_type", " from HR_BENEFIT_INCENTIVE join HR_PRELOAD_BENEFIT_TYPE " +
		" on (HR_PRELOAD_BENEFIT_TYPE.BENEFIT_TYPE_INDEX = HR_BENEFIT_INCENTIVE.BENEFIT_TYPE_INDEX) " +
		" where  HR_BENEFIT_INCENTIVE.BENEFIT_TYPE_INDEX ="+strLoanIndex+" and is_incentive = 0 and is_valid=1 and is_del =0 and is_benefit =0"
		, strTemp,false)*/%> 
          <%//}%>
		<%=dbOP.loadCombo("benefit_index","benefit_name, sub_type as astype", " from HR_BENEFIT_INCENTIVE join HR_PRELOAD_BENEFIT_TYPE " +
		" on (HR_PRELOAD_BENEFIT_TYPE.BENEFIT_TYPE_INDEX = HR_BENEFIT_INCENTIVE.BENEFIT_TYPE_INDEX) " +
		" where  benefit_name <> 'Leave' and benefit_name <> 'Govt Mandated'  and is_incentive = 0 and is_valid=1 and is_del =0 and is_benefit =0"
		, strTemp,false)%> 
        </select> <a href="../../HR/personnel/sal_ben_incent_mgmt_benefits.jsp"><img src="../../../images/update.gif" border="0" ></a><font size="1"> 
        click to add to the list loans/advances</font> <font size="1">&nbsp;</font></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td width="4%" height="29">&nbsp;</td>
      <td width="40%" height="29">Date Applied: 
        <%	if(vInfoDetail!=null) strTemp= (String)vInfoDetail.elementAt(9);
	else strTemp= WI.fillTextValue("date_applied");%> <input name="date_applied" type="text" class="textbox" id="date_applied"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" 
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" size="12" maxlength="12" readonly="yes"> 
        <a href="javascript:show_calendar('form_.date_applied');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
      </td>
      <td width="63%" height="29">Date Approved: 
        <%	if(vInfoDetail!=null) strTemp= (String)vInfoDetail.elementAt(10);
	else strTemp= WI.fillTextValue("date_approved");%> <input name="date_approved" type="text" class="textbox" id="date_approved"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="yes"> 
        <a href="javascript:show_calendar('form_.date_approved');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29" valign="bottom">Application No:<strong> 
        <% if(vInfoDetail != null)  strTemp=(String)vInfoDetail.elementAt(11);
	  	else strTemp = WI.fillTextValue("appl_no");%>
        <input name="appl_no" type="text" class="textbox" id="appl_no" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12">
        </strong></td>
      <td height="29">Amount Applied : <font size="1"><strong> 
        <% if(vInfoDetail != null)  strTemp=(String)vInfoDetail.elementAt(12);
	  	else strTemp = WI.fillTextValue("amount");%>
        <input name="amount" type="text" class="textbox" id="amount" onFocus="style.backgroundColor='#D3EBFF'" 
		onblur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12"
		onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
		onKeyUp="ComputeDue()";>
        </strong></font></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Terms : <strong> 
        <% if(vInfoDetail != null)  strTemp=(String)vInfoDetail.elementAt(13);
	  	else strTemp = WI.fillTextValue("terms");%>
        <input name="terms" type="text" class="textbox" id="terms" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4" 
		onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
		 onKeyUp="ComputeDue()";>
        </strong></td>
      <td height="29">Schedule of Deduction : 
        <select name="sched_deduct">
          <% if(vInfoDetail != null)  strTemp=(String)vInfoDetail.elementAt(14);
	  	else strTemp = WI.fillTextValue("sched_deduct");
			for (int j = 0;j < astrSchedDeduct.length; ++j){
				if (strTemp.compareTo(Integer.toString(j)) == 0){%>
          <option value="<%=j%>" selected><%=astrSchedDeduct[j]%></option>
          <%}else{%>
          <option value="<%=j%>" ><%=astrSchedDeduct[j]%></option>
          <%} // end if else
		} // end for loop%>
        </select></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Start of Deduction : 
        <% if(vInfoDetail != null)  
			strTemp=(String)vInfoDetail.elementAt(15);
	  	   else 
			strTemp = WI.fillTextValue("deduct_date");			
			if (strTemp.trim().length() == 0 && strSalDateFr!= null && strSalDateFr.trim().length() > 0){
				strTemp = strSalDateFr;
			}
			%> 
	  <input name="deduct_date" type="text" class="textbox" id="deduct_date"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="yes"> 
        <a href="javascript:show_calendar('form_.deduct_date');"><img src="../../../images/calendar_new.gif" border="0"></a> 
      </td>
      <td height="29">Due per Deduction : <font size="1"><strong> 
        <% if(vInfoDetail != null)  strTemp=(String)vInfoDetail.elementAt(16);
	  	else strTemp = WI.fillTextValue("due");%>
        <input name="due" type="text" class="textbox" id="due" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12"
		onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        </strong></font></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29" colspan="2"> Description : 
        <%if(vInfoDetail != null)  strTemp=(String)vInfoDetail.elementAt(19);
	  	else strTemp = WI.fillTextValue("description");%> <textarea name="description" cols="40" rows="2"  class="textbox" id="description" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" maxlength="256" onKeyUp='return isMaxLen(this)'><%=strTemp%></textarea></td>
    </tr>
    <tr> 
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29" colspan="2"><div align="center"> 
          <% if (iAccessLevel > 1) { 
		if (vInfoDetail == null) {%>
          <a href="javascript:AddRecord();"><img src="../../../images/save.gif" width="48" height="28" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click 
          to add</font> 
          <%}else{%>
          <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click 
          to save changes</font> 
          <%}%>
          <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
          <font size="1" face="Verdana, Arial, Helvetica, sans-serif">click to 
          cancel or go previous</font> 
          <%} //end iAccessLevel > 1%>
        </div></td>
    </tr>
  </table>
  <%}// end if(!bolViewOnly) %>
<% if (vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2"><div align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0" ></a> 
          click to print</font></div></td>
    </tr>
  </table>
  
  <table  bgcolor="#FFFFFF" width="106%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="13" bgcolor="#B9B292"><div align="center"><strong>ADVANCES/DEDUCTIONS 
          STATUS </strong></div></td>
    </tr>
    <tr> 
      <td height="28" colspan="4"><strong><font size="1">TOTAL APPLIED ADVANCES/DEDUCTIONS 
        : <font color="#0000FF"><%=(String)vRetResult.elementAt(0)%></font></font></strong></td>
      <td height="28" colspan="4"><font size="1"><strong>TOTAL ACTIVE APPLIED 
        ADVANCES/DEDUCTIONS : <font color="#FF9900"><%=(String)vRetResult.elementAt(1)%></font></strong></font></td>
      <td height="28" colspan="5"><font size="1"><strong>CURRENT BALANCE : <font color="#FF0000">Php 
        <%=CommonUtil.formatFloat((String)vRetResult.elementAt(2),true)%></font></strong></font></td>
    </tr>
    <tr> 
      <td width="4%"><div align="center"><font size="1"><strong>LOAN</strong></font></div></td>
      <td width="6%" height="28"><div align="center"><font size="1"><strong>DATE 
          APPLIED</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>APPLICATION NO.</strong></font></div></td>
      <td><div align="center"><font size="1"><strong>AMOUNT APPLIED</strong></font></div></td>
      <td><div align="center"><font size="1"><strong>DATE APPROVED</strong></font></div></td>
      <td><div align="center"><font size="1"><strong>TERMS </strong></font></div></td>
      <td><div align="center"><font size="1"><strong>SCHEDULE OF DEDUCTION</strong></font></div></td>
      <td><div align="center"><font size="1"><strong>START OF DEDUCTION</strong></font></div></td>
      <td><div align="center"><font size="1"><strong>DUE PER DEDUCTION</strong></font></div></td>
      <td><div align="center"><font size="1"><strong>BALANCE</strong></font></div></td>
      <%if(!bolViewOnly){%>
      <td colspan="3"><div align="center"><font size="1"><strong>OPTIONS</strong></font></div></td>
      <%}%>
    </tr>
    <% for (int i = 3; i < vRetResult.size() ; i+=18){ 
	if(vRetResult.elementAt(i + 15) != null && (Double.parseDouble((String)vRetResult.elementAt(i + 15)) < 1))
		strTDColor = "bgcolor=#DDDDDD";
	else
		strTDColor = "";
	%>
    <tr <%=strTDColor%>> 
      <td><%=(String)vRetResult.elementAt(i+5)%></td>
      <td height="25"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+6)%></font></div></td>
      <td height="25"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+8)%></font></div></td>
      <td width="13%"><div align="center"><font size="1"> <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+9),true)%></font></div></td>
      <td width="7%"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></div></td>
      <td width="5%"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+10)%></font></div></td>
      <td width="8%"><div align="center"><font size="1"><%=astrSchedDeduct[Integer.parseInt((String)vRetResult.elementAt(i+11))]%></font></div></td>
      <td width="13%"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+12)%></font></div></td>
      <td width="8%"><div align="center"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+13),true)%></font></div></td>
      <td width="6%"><div align="center"><font size="1"> <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+15),true)%></font></div></td>
      <%if(!bolViewOnly){%>
      <td width="5%"> <% if (iAccessLevel > 1  && strTDColor.length() == 0 && ((String)vRetResult.elementAt(i+14)).compareTo("1") != 0){%> <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>','<%=(String)vRetResult.elementAt(i+15)%>')"><img src="../../../images/edit.gif" border=0 ></a> 
        <%}else{%> <div align="center">N/A</div>
        <%}%> </td>
      <td width="7%"> <% if (iAccessLevel == 2  && strTDColor.length() == 0 && ((String)vRetResult.elementAt(i+14)).compareTo("1") != 0){%> <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border=0></a> 
        <%}else{%> <div align="center">N/A</div>
        <%}%> </td>
      <%}%>
	  
      <td width="8%">
	  <%if(strTDColor.length() > 0){%>
		  	&nbsp;	
	  <%}else{%>
	  	  <a href="javascript:StopLoan('<%=(String)vRetResult.elementAt(i)%>')">
		  <%if ((WI.getStrValue((String)vRetResult.elementAt(i+16),"0")).equals("1")){%>
		  	<img src="../../../images/enable.gif" width="63" height="24" border=0>
		  <%}else{%>
		  	<img src="../../../images/disable.gif" width="63" height="24" border=0>	
		  <%}%>
		  </a>
	  <%}%>
	  </td>
    </tr>
    <%}%>
  </table>
<%}}%>
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
<input type="hidden" name="payable" value="<%=WI.fillTextValue("payable")%>">

<%if(bolViewOnly){%>
<input type="hidden" name="view" value="1">
<%}%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>