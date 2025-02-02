<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRAddlPay" %>
<%
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
	
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>SET ADDITIONAL MONTH PAY PARAMETERS</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

    TD.thinborderBOTTOMLEFT {
	border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
	
	TD.thinborderBOTTOMLEFTRIGHT {
	border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PageAction(strPageAction,strInfoIndex,strBonusName){
	if(strPageAction == 0){
	var vProceed = confirm('Delete '+strBonusName+' ?');
	  if(!vProceed){
		return;
	  }
	}

	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;	
				
	document.form_.page_action.value = strPageAction;
	document.form_.print_page.value="";
	document.form_.prepareToEdit.value = "";
	if(strPageAction == 1) 
		document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../../images/blank.gif";
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex,strPayable){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.pay_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./additional_pay_mgmt.jsp?year="+document.form_.year.value;
}

function ShowAll() {
	var pgLoc = "./set_items_included_comp_adtl_pay_all.jsp";
	var win=window.open(pgLoc,"ShowAll",'dependent=yes,width=700,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage()
{
	document.form_.print_page.value="";
	document.form_.page_reloaded.value = "1";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}


function focusID() {
	document.form_.emp_id.focus();
}

function UpdateSource(strPayIndex){
	var pgLoc = "./set_items_inc_addl_pay.jsp?year="+document.form_.year.value+
				"&salary_type=0&pay_index="+document.form_.pay_index.value;
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function UpdateReleased(strPayIndex, strYearOf){
	var pgLoc = "./set_sub_bonus.jsp?pay_index="+strPayIndex+"&year_of="+strYearOf;
	var win=window.open(pgLoc,"updatReleased",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"OpenSearch",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function SearchEmployee() {
 	var strEmpCatg = "";
	if(document.form_.employee_category){
		strEmpCatg = document.form_.employee_category.value;
	}
		
 	var pgLoc = "./emplist_addl_month.jsp?emp_id="+document.form_.emp_id.value+
				"&employee_category="+strEmpCatg+
				"&pt_ft="+document.form_.pt_ft.value+
				"&c_index="+document.form_.c_index.value+
				"&d_index="+document.form_.d_index.value;
	var win=window.open(pgLoc,"SearchEmployee",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function VerifyBonus(strInfoIndex){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.verify.value = "1";
	this.SubmitOnce("form_");
}

//function GenerateList(strInfoIndex){
//	document.form_.print_page.value="";
//	document.form_.page_action.value = "";
//	document.form_.info_index.value=strInfoIndex;
//	document.form_.generate_list.value = "1";
//	this.SubmitOnce("form_");	
//}

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

function CopyName(){
	if (document.form_.pay_name_combo.selectedIndex != 0) 
		document.form_.pay_name.value= 
			document.form_.pay_name_combo[document.form_.pay_name_combo.selectedIndex].text;
}

</script>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolHasTeam = false;	
//add security here.

if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="set_items_included_comp_adtl_pay_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Set Additional Month  Pay Parameters","set_num_of_mths_pay.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"additional_pay_mgmt.jsp");
if(iAccessLevel == 0){
iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION-SETADDLMNTH",request.getRemoteAddr(), null);
}
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

//end of authenticaion code.
Vector vRetResult = null;
Vector vEditInfo = null;
Vector vSource = null;
PRAddlPay prAddl = new PRAddlPay();

String strSchCode = WI.getStrValue(dbOP.getSchoolIndex(),"");
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"");
String strPageAction = WI.fillTextValue("page_action");
String strProcType = WI.fillTextValue("procedure");
String strSalaryType = WI.fillTextValue("salary_type");
String[] astrTypeLabel = {"Basic Salary","Gross Salary","Net Salary",""};
String[] astrOBI = {"Benefit", "Incentive", "Overtime",""};
String[] astrProcedure = {"Specific Amount","Computed"};
String[] astrUnit = {"day(s)", "week(s)", "month(s)", "year(s)"};
String[] astrCategory = {"Staff","Faculty","Employees"};
String[] astrStatus = {"Part-Time","Full-Time",""};
boolean bolHasItems = false;
String[] astrMonth = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};

if(WI.fillTextValue("verify").length() > 0){
	if(!prAddl.verifyBonus(dbOP, request)){
		strErrMsg = prAddl.getErrMsg();
	}else{
		strErrMsg = "Verified Additional Month pay";
	}		
}

//if(WI.fillTextValue("generate_list").length() > 0){
//	if(prAddl.OperateOnBonusEmpList(dbOP, request, 1) == null){
//		strErrMsg = prAddl.getErrMsg();
//	}else{
//		strErrMsg = "Generated Additional Month List";
//	}		
//}

if (strPageAction.length() > 0){
	if (strPageAction.compareTo("0")==0) {
		if (prAddl.operateOnAddlMonthPay(dbOP,request,0) != null){
			strErrMsg = "  Item removed successfully ";
		}else{
			strErrMsg = prAddl.getErrMsg();
		}
	}else if(strPageAction.compareTo("1") == 0){
		if (prAddl.operateOnAddlMonthPay(dbOP,request,1) != null){
			strErrMsg = " Item posted successfully ";
		}else{
			strErrMsg = prAddl.getErrMsg();
		}
	}else if(strPageAction.compareTo("2") == 0){
		if (prAddl.operateOnAddlMonthPay(dbOP,request,2) != null){
			strErrMsg = " Item updated successfully ";
			strPrepareToEdit = "";
		}else{
			strErrMsg = prAddl.getErrMsg();
		}
	}
}
if (strPrepareToEdit.length() > 0){
	vEditInfo = prAddl.operateOnAddlMonthPay(dbOP,request,3);
	if (vEditInfo == null)
		strErrMsg = prAddl.getErrMsg();
	
	vSource = (Vector)vEditInfo.elementAt(19);
 }

vRetResult = prAddl.operateOnAddlMonthPay(dbOP,request,4);
if (vRetResult != null && strErrMsg == null){
	strErrMsg = prAddl.getErrMsg();	
}

%>

<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./additional_pay_mgmt.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL : ADDITIONAL MONTH PAY PARAMETERS PAGE ::::</strong></font><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;</font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1"><a href="addtl_mth_pay_main.jsp"><img src="../../../../images/go_back.gif" border="0"></a></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="27">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="23%">Effectivity Period/Year</td>
      <% if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String) vEditInfo.elementAt(5);
		 else
	  		strTemp = WI.fillTextValue("year");
	  %>
      <td width="74%"><select name="year" onChange="ReloadPage();">
	  	<option value="">ALL</option>
        <%=dbOP.loadComboYear(WI.fillTextValue("year"),2,1)%>
      </select>
      <a href='javascript:ReloadPage();'><img src="../../../../images/refresh.gif " width="71" height="23" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td> Additional Pay Name</td>
      <td width="74%"> 
	  <% if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String) vEditInfo.elementAt(1);
		 else
	  		strTemp = WI.fillTextValue("pay_name");
	  %> <input name="pay_name" type="text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" value="<%=strTemp%>" 
		size="32" maxlength="128">
	  <select name="pay_name_combo" onChange="CopyName();">
      <option value="">Select Additional Pay </option>
      <%=dbOP.loadCombo("distinct pay_name","pay_name", " from pr_addl_pay_mgmt " +
					" where is_valid = 1 ", strTemp,false)%>
    </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Procedure</td>
      <% if(vEditInfo != null && vEditInfo.size() > 0)
	  		strProcType = (String) vEditInfo.elementAt(2);
		 else
	  		strProcType = WI.fillTextValue("procedure");
	  %>
      <td> <select name="procedure" onChange="ReloadPage()">
          <option value="0">Specific Amount</option>
          <% if (strProcType.compareTo("1") == 0) {%>
          <option value="1" selected>Computed</option>
          <%}else{%>
          <option value="1">Computed</option>
          <%}%>
        </select></td>
    </tr>
    <%if(WI.getStrValue(strProcType,"0").equals("0")){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Amount</td>
      <% if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String) vEditInfo.elementAt(2);
		 else
	  		strTemp = WI.fillTextValue("amount");
	  %>
      <td><input name="amount" type="text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" 
		  onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('form_','amount','.')" 
		  value="<%=WI.fillTextValue("amount")%>" size="4" maxlength="6"></td>
    </tr>
    <%}else{%>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="23%">Inclusive Month</td>
      <td> <%
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(3);
		else	
			strTemp = "0";
	   %> <select name="month_fr">
          <%=dbOP.loadComboMonth(strTemp)%> 
        </select>
        - 
        <%
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(4);
		else	
			strTemp = "11";
	   %> <select name="month_to">
          <%=dbOP.loadComboMonth(strTemp)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Compensation Source for Computation</td>
      <% if(vEditInfo != null && vEditInfo.size() > 0 && !WI.fillTextValue("page_reloaded").equals("1"))
			if(vSource != null && vSource.size() > 0){
			  strSalaryType = (String)vSource.elementAt(2);
			}else{
			  strSalaryType = WI.fillTextValue("salary_type");
			}
	 	 else
	  		strSalaryType = WI.fillTextValue("salary_type");
		//System.out.println("vEditInfo " + vEditInfo);
	  %>
	  
      <td><select name="salary_type" onChange="ReloadPage()">
        <% for(int i =2 ; i >= 0 ; i--) { 
	if (Integer.parseInt(WI.getStrValue(strSalaryType,"2")) == i){ %>
        <option value="<%=i%>" selected><%=astrTypeLabel[i]%></option>
        <%}else{%>
        <option value="<%=i%>" ><%=astrTypeLabel[i]%></option>
        <%}}%>
      </select>
        <% if (strSalaryType.compareTo("0") == 0){%> 
		 <%if (strPrepareToEdit.compareTo("1") == 0){%> 
		   <a href='javascript:UpdateSource();'> <img src="../../../../images/update.gif" width="60" height="26" border="0"> </a> 
		 <%}%> 
    <%}%> 
		 <%if(strSalaryType.equals("0")){
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String) vEditInfo.elementAt(24);
				else
					strTemp = WI.fillTextValue("include_deductions");
			
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
		 %><br>
			<input type="checkbox" name="include_ded" value="1" <%=strTemp%>>
      <font size="1">don't deduct <%=(!strSchCode.startsWith("FATIMA")?"tardiness, undertime and ":"")%>absences from basic pay</font>
			<%}%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Computation Formula</td>
      <%
			if(vEditInfo != null && vEditInfo.size() > 0 && !WI.fillTextValue("page_reloaded").equals("1"))
				strTemp = (String)vEditInfo.elementAt(10);
			else
				strTemp = WI.fillTextValue("operator1");
		%>
      <td height="25">Summation of Source 
        <select name="operator1">
          <option value="0">/</option>
          <% if (strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>*</option>
          <%}else{%>
          <option value="1">*</option>
          <%}%>
        </select> 
				<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(11);
				else
					strTemp = WI.fillTextValue("value1");
				%> 
			<input name="value1" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		  onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('form_','value1','.')" 
		  value="<%=strTemp%>" size="4" maxlength="4">
        <strong>X</strong>
				<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(25);
				else
					strTemp = WI.fillTextValue("opt_multiplier");
				%> 				
        <input name="opt_multiplier" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		  onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('form_','opt_multiplier','.')" 
		  value="<%=WI.getStrValue(strTemp, "1")%>" size="6" maxlength="6" style="text-align:right"><font size="1">(optional multiplying factor)</font>
        <br>
        plus 
        <%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(12);
			else
				strTemp = WI.fillTextValue("value2");
		%> <input name="value2" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		  onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('form_','value2','.')" 
		  value="<%=WI.fillTextValue("value2")%>" size="10" maxlength="10">
        <br>
        Ex. [sum(Jan - dec)/12 <strong>*</strong> 1 ] </td>
    </tr>
    <%}// end if computed formula%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Eligibility Period/Schedule</td>
      <%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(6);
			else
				strTemp = WI.fillTextValue("eligibility");
		%>
      <td height="25"><input name="eligibility" type= "text" class="textbox" value="<%=strTemp%>" size="10" 
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','eligibility');style.backgroundColor='white'"
			 onKeyUp="AllowOnlyInteger('form_','eligibility')"> <%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(7);
			else
				strTemp = WI.fillTextValue("eligibility_unit");
		%> <select name="eligibility_unit">
          <option value="0">day(s)</option>
          <%
		if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>week(s)</option>
          <%}else{%>
          <option value="1">week(s)</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>month(s)</option>
          <%}else{%>
          <option value="2">month(s)</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>year(s)</option>
          <%}else{%>
          <option value="3">year(s)</option>
          <%}%>
        </select>
        of work</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="23%" height="25"><strong>Implementation Setting </strong></td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Specific Employee (ID)</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(21);
		else
			strTemp = WI.fillTextValue("emp_id");
			
	  %>
      <td width="40%" height="25"><input name="emp_id" type="text" size="16" value="<%=WI.getStrValue(strTemp, "")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="34%">&nbsp;</td>
    </tr>	
		<%if(bolIsSchool){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Employee Category</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0 && !WI.fillTextValue("page_reloaded").equals("1"))
			strTemp = (String)vEditInfo.elementAt(14);
		else	  
		  	strTemp = WI.fillTextValue("employee_category");
		strTemp = WI.getStrValue(strTemp,"");
	  %>
      <td height="25" colspan="2"><select name="employee_category" onChange="ReloadPage();">
        <option value="">All</option>
        <%if(strTemp.equals("0")){%>
        <option value="0" selected>Staff</option>
        <option value="1">Faculties</option>
        <%}else if(strTemp.equals("1")){%>
        <option value="0">Staff</option>
        <option value="1" selected>Faculties</option>
        <%}else{%>
        <option value="0">Staff</option>
        <option value="1">Faculties</option>
        <%}%>
      </select></td>
    </tr>
		<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Employee Status</td>
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0 && !WI.fillTextValue("page_reloaded").equals("1"))
			strTemp = (String)vEditInfo.elementAt(15);
		else	  
		  	strTemp = WI.fillTextValue("pt_ft");
		
		strTemp = WI.getStrValue(strTemp,"");
	  %>
      <td height="25" colspan="2"><select name="pt_ft" onChange="ReloadPage();">
        <option value="">All</option>
        <%if(strTemp.equals("0")){%>
        <option value="0" selected>Part-time</option>
        <option value="1">Full-time</option>
        <%}else if(strTemp.equals("1")){%>
        <option value="0">Part-time</option>
        <option value="1" selected>Full-time</option>
        <%}else{%>
        <option value="0">Part-time</option>
        <option value="1">Full-time</option>
        <%}%>
      </select></td>
    </tr>
    <%
	String strCollegeIndex = null;
	if(vEditInfo != null && vEditInfo.size() > 0 && !WI.fillTextValue("page_reloaded").equals("1"))
		strCollegeIndex = (String)vEditInfo.elementAt(22);
	else	 	
		strCollegeIndex = WI.fillTextValue("c_index");
	strCollegeIndex = WI.getStrValue(strCollegeIndex,"");
	%>	
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>	  
      <td height="25" colspan="2"><select name="c_index" onChange="loadDept();">
        <option value="">N/A</option>
        <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Department/Office</td>
	  <%
		if(vEditInfo != null && vEditInfo.size() > 0 && !WI.fillTextValue("page_reloaded").equals("1"))
			strTemp = (String)vEditInfo.elementAt(23);
		else	 	
		    strTemp = WI.fillTextValue("d_index");
	  %>
      <td height="25" colspan="2">
			<label id="load_dept">
			<select name="d_index">
        <option value="">ALL</option>
        <%if (strCollegeIndex.length() == 0){%>
        <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", strTemp,false)%>
        <%}else if (strCollegeIndex.length() > 0){%>
        <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , strTemp,false)%>
        <%}%>
      </select>
			</label>
			</td>
    </tr>
		<%if(bolHasTeam){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Team</td>
	  <%
		if(vEditInfo != null && vEditInfo.size() > 0 && !WI.fillTextValue("page_reloaded").equals("1"))
			strTemp = (String)vEditInfo.elementAt(26);
		else	 	
		    strTemp = WI.fillTextValue("team_index");
	  %>			
      <td height="25" colspan="2"><select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", strTemp, false)%>
      </select></td>
    </tr>
		<%}%>
    <tr>
      <td height="33">&nbsp;</td>
      <td height="33">&nbsp;</td>
      <td height="33" colspan="2"><font size="1"><a href='javascript:SearchEmployee();'><img src="../../../../images/view.gif" width="40" height="31" border="0"></a> View Employees to be affected </font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
    <tr> 
      <td width="95%" height="50" align="center"> 
        <% if (iAccessLevel > 1){
	if (strPrepareToEdit.compareTo("1") != 0){%> 
        <!--
				<a href='javascript:PageAction(1,"");'><img src="../../../../images/save.gif" name="hide_save" width="48" height="28" border="0"></a> 
				-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');">				
        <font size="1">click to save entries</font> 
        <%}else{%> 
        <!--
				<a href='javascript:PageAction(2,"");'><img src="../../../../images/edit.gif" width="40" height="26" border="0"></a> 
				-->
			  <input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2', '');">				
        <font size="1">click to save changes</font> 
        <%}
	   }%> 
	 		  <!--
        <a href="./additional_pay_mgmt.jsp"><img src="../../../../images/cancel.gif" width="51" height="26" border="0"></a>
				-->
			  <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">
			    <font size="1">click to cancel and clear entries</font> </td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%if(false){%>
	<tr> 
      <td height="30" colspan="7"><div align="right"><font size="1"><img src="../../../../images/print.gif" width="58" height="26" border="0">click 
          to print list</font></div></td>
    </tr>
	<%}%>
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="7" align="center" class="thinborder"><font color="#FFFFFF"><strong>:: 
      List of Valid additional month pay :: </strong></font></td>
    </tr>
    <tr> 
      <td width="12%" height="37" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>ADDITIONAL 
              PAY NAME</strong></font></td>
      <td width="8%" height="37" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>INCLUSIVE 
              MONTH</strong></font></td>
      <td width="18%" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>COMPENSATION 
              SOURCE FOR COMPUTATION</strong></font></td>
      <td width="24%" height="37" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1">DETAILS</font></strong></td>
      <td width="29%" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>SETTING</strong></font></td>
      <td width="9%" align="center" class="thinborderBOTTOMLEFTRIGHT"><strong><font size="1">MULTIPART PAY </font></strong></td>
      <td width="9%" height="37" align="center" class="thinborderBOTTOMLEFTRIGHT"><font size="1"><strong>OPTION</strong></font></td>
    </tr>
    <%boolean bolShowHeaders = true;
	int j = 0 ;
	int i = 0;
	for(int k = 0; k < vRetResult.size(); k+=30){	
		j = 0;
		i = 0;
		vSource = (Vector)vRetResult.elementAt(k+19);
		//System.out.println("vSource " + vSource);		
		bolShowHeaders = true;
	%>
    <tr> 
      <td class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(k+1)%></td>
	<%
		strTemp = "";
		if(vRetResult.elementAt(k+3) != null && vRetResult.elementAt(k+4) != null){
		strTemp = astrMonth[Integer.parseInt((String)vRetResult.elementAt(k+3))];
		strTemp += " - " + astrMonth[Integer.parseInt((String)vRetResult.elementAt(k+4))];
		}		
	%>
      <td class="thinborderBOTTOMLEFT">
      <div align="center"><%=WI.getStrValue(strTemp, "&nbsp;")%></div></td>
      <td class="thinborderBOTTOMLEFT">
	  <%if(vSource != null && vSource.size() > 0){%>
        <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">

	<%  
	for (i = 0; i < vSource.size(); i+=6 ){	
	  if ((String)vSource.elementAt(i+1) != null){
		bolShowHeaders = false; 	
		j = i;
	  }	  
	if (bolShowHeaders) {
	%>
          <tr> 
            <td width="572" height="18"> &nbsp; 
	  <%for (;j < vSource.size(); j+=6){
		if (vSource.elementAt(j+1) != null && j != i){	
			bolShowHeaders = false;
			break;
	    }else{%> 
		  	<font color="#000000"><strong>
			<%=astrTypeLabel[Integer.parseInt(WI.getStrValue((String)vSource.elementAt(j+2),"3"))]/* salary type*/%>
			</strong> </font> 
		<%}//end if else  inner loop
		}// end innner for loop 
		bolShowHeaders = false;
		%>		    </td>
          </tr>
     <%} //end bolShowHeaders%>
	
          <tr> 
            <td height="18" style="font-size:10px"> &nbsp;-
              <% 
			  // DO NOT WONDER WHAT OBI MEANS. ITS OVERTIME, BENEFIT, INCENTIVE
			  strTemp =(String)vSource.elementAt(i+5);	
	   	if (strTemp == null){
			strTemp = astrOBI[Integer.parseInt(WI.getStrValue((String)vSource.elementAt(i+3),"3"))];/* O B I */ 
			strTemp += WI.getStrValue((String)vSource.elementAt(i+5)," (",")","")/*sub - type*/;
		}
		
		if (strTemp.length() == 0)
			strTemp = astrTypeLabel[Integer.parseInt(WI.getStrValue((String)vSource.elementAt(i+2),"3"))] ;
		%> <%=strTemp%></td>
          </tr>
          <% } //end for int i = 0 loop%>
        </table>
        <%}else {// end if vSource%>
		N/A
	  <%}%>	  </td>
	  <%
	  	strTemp = "<strong>PROCEDURE :</strong> " + astrProcedure[Integer.parseInt((String)vRetResult.elementAt(k+2))];
		strTemp += "<br> <strong>EFFECTIVITY YEAR :</strong> " + (String)vRetResult.elementAt(k+5);
		strTemp += "<br> <strong>ELIGIBILITY :</strong> " + (String)vRetResult.elementAt(k+6) + astrUnit[Integer.parseInt((String)vRetResult.elementAt(k+7))];
	  %>
      <td valign="top" class="thinborderBOTTOMLEFT">&nbsp;<%=strTemp%> </td>
      <%	    
		if(vRetResult.elementAt(k+13) != null){ // FOR SPECIFIC EMPLOYEE
	  		strTemp = "Employee: " + (String) vRetResult.elementAt(k+20);
			strTemp += WI.getStrValue((String)vRetResult.elementAt(k+21)," (",")","");
		}else{
		  strTemp = "All ";
		  strTemp += astrStatus[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(k+15),"2"))];
		  strTemp += " " + astrCategory[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(k+14),"2"))];
		  
		  if(vRetResult.elementAt(k+16) != null || vRetResult.elementAt(k+17) != null)
		  strTemp += "<br> Under ";
		  
		  if(vRetResult.elementAt(k+16) != null){		  			  	
			strTemp += (String)vRetResult.elementAt(k+16);
			if(vRetResult.elementAt(k+17) != null)
			  strTemp += " - ";
		  }
		  if(vRetResult.elementAt(k+17) != null){		  			  	
			strTemp += "<br> " + (String)vRetResult.elementAt(k+17);
		  }
		}		
	  %>
      <td valign="top" class="thinborderBOTTOMLEFT"><font size="1"><%=strTemp%></font></td>
      <td class="thinborderBOTTOMLEFTRIGHT">
			<%if(iAccessLevel > 1 && !((String)vRetResult.elementAt(k+18)).equals("0")){%>
			<a href="javascript:UpdateReleased('<%=(String)vRetResult.elementAt(k)%>', '<%=(String)vRetResult.elementAt(k+5)%>');"><img src="../../../../images/update.gif" width="60" height="26" border="0"></a>
			<%}else{%>
			N/a
			<%}%>
			</td>
      <td class="thinborderBOTTOMLEFTRIGHT">
		 <div align="center">&nbsp;		 	 
		   <%if( ((String)vRetResult.elementAt(k+18)).equals("0") ){%>
			 <%if(iAccessLevel > 1){%>
		   <a href='javascript:VerifyBonus("<%=(String)vRetResult.elementAt(k)%>");'>
		    VERIFY</a><br>		   
		    <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(k)%>");'>
		    <img src="../../../../images/edit.gif" width="40" height="26" border="0"></a><br>
				<%if(iAccessLevel == 2){%>
		    <a href='javascript:PageAction(0,"<%=(String)vRetResult.elementAt(k)%>","<%=(String)vRetResult.elementAt(k+1)%>");'>
		    <img src="../../../../images/delete.gif" width="55" height="28" border="0"></a>				
				<%}
				 }
				}else{%>			
		   	VERIFIED
				<!--
				<br>					
					<a href='javascript:GenerateList("<%//=(String)vRetResult.elementAt(k)%>");'>GENERATE LIST</a>			
					-->
		    <%}%>&nbsp;
	     </div></td>
    </tr>
    <%		
	}// end for loop%>
  </table>
  <%}// if(vRetResult != null)%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="pay_index" value="<%=WI.fillTextValue("pay_index")%>">
  <input type="hidden" name="verify">
  <!--
	<input type="hidden" name="generate_list">
	-->
  <input type="hidden" name="page_reloaded">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>