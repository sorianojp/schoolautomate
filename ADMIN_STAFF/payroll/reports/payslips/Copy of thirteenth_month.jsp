<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PReDTRME" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = null;
	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) {
		bolMyHome = true;
		strColorScheme = CommonUtil.getColorScheme(9);
	}else{
		strColorScheme = CommonUtil.getColorScheme(6);
	}
	boolean bolHasConfidential = false;
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Payslip</title>
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
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>

<script language="JavaScript">

function ReloadPage()
{	
	document.form_.reset_page.value = "1";
	document.form_.print_pg.value = "";
	document.form_.print_all.value ="";	
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.reset_page.value = "";
	document.form_.print_pg.value = "";
	document.form_.print_all.value ="";	
	this.SubmitOnce('form_');
}

function PrintSlip(emp_id, pay_index,emp_bonus_index, strStatus,strBonusAmt)
{
	var pgLoc = "./payroll_slip_print_bonus.jsp?emp_id="+emp_id+"&pay_index="+pay_index+
				"&emp_bonus_index="+emp_bonus_index+"&pt_ft="+strStatus+"&bonus_amt="+strBonusAmt+
				"&finalize=1&pay_name="+document.form_.pay_name.value;
	var win=window.open(pgLoc,"PrintWindow",'width=700,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


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

function PrintALL() {
	document.form_.print_all.value ="1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
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

function CopyName(){
	if (document.form_.pay_index.selectedIndex != 0) 
		document.form_.pay_name.value= 
			document.form_.pay_index[document.form_.pay_index.selectedIndex].text;
}
</script>
<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	String strPayrollPeriod  = null;

	String strHasWeekly = null;
	boolean bolHasTeam = false;	
		if(WI.fillTextValue("print_batch").equals("1")){%>
		<jsp:forward page="batch_print_bonus.jsp"/>
				<!--
		<jsp:forward page="payroll_slip_batch.jsp"/>
		-->
	<%return;}
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payslips-Additional Month","thirteenth_month.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");
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
														"PAYROLL","REPORTS",request.getRemoteAddr(),
														"thirteenth_month.jsp");
if(bolMyHome)
	iAccessLevel = 2;
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


String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","5"};

Vector vSalaryPeriod 		= null;//detail of salary period.

PReDTRME prEdtrME = new PReDTRME();
EnrlReport.StatementOfAccount SOA = new EnrlReport.StatementOfAccount();

Vector vRetResult = null;
ReportPayroll RptPay = new ReportPayroll(request);
String strTenure = WI.fillTextValue("tenure_name");
Vector vSalaryRange = null;
if(WI.fillTextValue("searchEmployee").equals("1") || bolMyHome){
  if (WI.fillTextValue("year_of").length() > 0 || bolMyHome){	
	if(WI.fillTextValue("pay_index").length() > 0 || bolMyHome){
		vRetResult = RptPay.searchAddMonthPay(dbOP);
		if (vRetResult == null)
			strErrMsg = RptPay.getErrMsg();
		else{
		//System.out.println("vRetResult " +vRetResult);
			iSearchResult = RptPay.getSearchCount();			
		}
	}
	//System.out.println("vRetResult " + vRetResult);
  }else{
	strErrMsg = "Enter Year";
  }
}

if(strErrMsg == null) 
strErrMsg = "";
%>

<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="./thirteenth_month.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
      PAYROLL :  PAY SLIPS - ADDITIONAL MONTH PAGE ::::</strong></font></td>
    </tr>
    <%if(!bolMyHome){%>
		<tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;<a href="./pay_slips_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font></td>
    </tr>
		<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="27"><strong><%=strErrMsg%></strong></td>
    </tr>
  </table>
	<%if(!bolMyHome){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"> Year :</td>
      <td width="75%" height="25">
        <%strTemp = WI.fillTextValue("year_of");%>
      <input name="year_of" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','year_of');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyInteger('form_','year_of')"></td>
    </tr>
    <tr> 
      <td  width="5%"height="29">&nbsp;</td>
      <td width="20%" height="29">Additional pay name : </td>
	  <%
	  	strTemp = WI.fillTextValue("pay_index");
	  %>
      <td height="29"><select name="pay_index" onChange="CopyName();">
        <option value="">Select Additional Pay </option>
        <%=dbOP.loadCombo("pr_addl_pay_mgmt.pay_index","pay_name", " from pr_addl_pay_mgmt " +
		" where pr_addl_pay_mgmt.is_valid = 1 and pr_addl_pay_mgmt.is_del = 0 " +
		" and year = " + WI.getStrValue(WI.fillTextValue("year_of"),"0"), strTemp,false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
		<%if(bolIsSchool){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Payroll Category :</td>
      <td height="25"> 
	  <select name="employee_category" onChange="ReloadPage();">
		  <option value="" selected>ALL</option>
          <%if (WI.fillTextValue("employee_category").equals("0")){%>
		  <option value="0" selected>Non-Teaching</option>
          <option value="1">Teaching</option>
		  <%}else if (WI.fillTextValue("employee_category").equals("1")){%>
		  <option value="0">Non-Teaching</option>
          <option value="1" selected>Teaching</option>
          <%}else{%>
		  <option value="0">Non-Teaching</option>
          <option value="1">Teaching</option>
          <%}%>
        </select></td>
    </tr>
		<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Payroll Status :</td>
      <td height="25"> 
	    <select name="pt_ft" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%if (WI.fillTextValue("pt_ft").equals("0")){%>
		  <option value="0" selected>Part - time</option>
          <option value="1">Full - time</option>
		  <option value="2">Contractual</option>
          <%}else if (WI.fillTextValue("pt_ft").equals("1")){%>
		  <option value="0">Part - time</option>
          <option value="1" selected>Full - time</option>
		  <option value="2">Contractual</option>
          <%}else if (WI.fillTextValue("pt_ft").equals("2")){%>
		  <option value="0">Part - time</option>
          <option value="1">Full - time</option>
		  <option value="2" selected>Contractual</option>
          <%}else{%>
		  <option value="0">Part - time</option>
          <option value="1">Full - time</option>
		  <option value="2">Contractual</option>
          <%}%>
        </select> </td>
    </tr>
		<!--
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Pay Mode :</td>
      <td height="25">
	  	<select name="is_atm" onChange="ReloadPage();">
          <option value="">All</option>		  
          <%if (WI.fillTextValue("is_atm").equals("0")){%>
		  <option value="0" selected>Non-ATM Account</option>
          <option value="1">ATM Account</option>
          <%}else if (WI.fillTextValue("is_atm").equals("1")){%>
		  <option value="0">Non-ATM Account</option>
          <option value="1" selected>ATM Account</option>
		  <%}else{%>
		  <option value="0">Non-ATM Account</option>
          <option value="1">ATM Account</option>
          <%}%>
        </select></td>
    </tr>
		-->
<%if(bolHasConfidential){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Process Option</td>
			<%
			String strAuthID = (String) request.getSession(false).getAttribute("userIndex");
			if(strAuthID == null || strAuthID.length() == 0)
				strAuthID = "0";				
			%>						
      <td height="25"><select name="group_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("group_index","group_name"," from pr_preload_group " +
													" where exists(select user_index from pr_group_proc " +
													" 	where pr_preload_group.group_index = pr_group_proc.group_index " +
													" 	and user_index = " + strAuthID + ") order by group_name", WI.fillTextValue("group_index"), false)%>
      </select></td>
    </tr>
		<%}%>
 		<%if(bolHasTeam){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Team</td>
      <td>
			<select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select>      </td>
    </tr>
		<%}%>		
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><strong><u>Print by :</u></strong></td>
      <td height="25">&nbsp;</td>
    </tr>
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td height="25"><select name="c_index" onChange="loadDept();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Office</td>
      <td height="26">
				<label id="load_dept">
				<select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select>
				</label>				</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Employee ID </td>
      <td height="25"><input name="emp_id" type="text" size="16"maxlength="16" value="<%=WI.fillTextValue("emp_id")%>" onKeyUp="AjaxMapName(1);"><label id="coa_info"></label></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">&nbsp;</td>
      <td height="26"><a href="javascript:SearchEmployee();"><img src="../../../../images/form_proceed.gif" border="0"></a><font size="1">click 
        to display employee list to print.</font></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Print Employee payroll whose lastname starts 
        with 
        <select name="lname_from" onChange="ReloadPage();">
          <%
	 strTemp = WI.fillTextValue("lname_from");
	 int j = 0; //displays from and to to avoid conflict -- check the page ;-)
	 for(int i=0; i<28; ++i){
	   if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
	   j = i; %>
          <option selected><%=strConvertAlphabet[i]%></option>
       <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
       <%}
	 }%>
        </select>
        to 
        <select name="lname_to">
          <option value="0"></option>
          <%
			 strTemp = WI.fillTextValue("lname_to");
			 
		for(int i=++j; i<28; ++i){
		  if(strTemp.compareTo(strConvertAlphabet[i]) ==0){%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
		}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
	<% if(vRetResult != null && vRetResult.size() > 0) { %>
    <tr> 
      <td height="25">&nbsp;</td>
      <%if (vRetResult != null)
	  	  strTemp = Integer.toString(iSearchResult);
		else
		  strTemp = "";
	  %>	  
      <td height="25" colspan="2"><font size="3">TOTAL EMPLOYEES TO BE PRINTED 
        : <strong><%=WI.getStrValue(strTemp,"0")%></strong></font></td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">PRINT OPTION : <br> <font color="#0099FF">&nbsp; </font></td>
      <td height="25"><input name="print_option2" type="text" size="16" maxlength="32" 
	  value="<%=WI.fillTextValue("print_option2")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <font color="#0099FF" size="1"><strong><br>
        (Enter payslip numbers and/or payslip 
        ranges separated by commas. For ex: 1,3,5-12)</strong></font></td>
    </tr>
	<%}// end if(vRetResult != null && vRetResult.size() > 0) %>
  </table>
	<%} else {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">    
    <tr bgcolor="#FFFFFF"> 
      <td width="14%" height="25" align="right">Year&nbsp; </td>
      <td width="86%"><select name="year_of" onChange="javascript:SearchEmployee();">
        <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%>
      </select></td>
    </tr>
  </table>  
	<%}%>	
	
  <% if(vRetResult != null && vRetResult.size() > 0  && WI.fillTextValue("reset_page").length() == 0) {%>
	<%if(!bolMyHome){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">    
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="5" align="right"><a href="javascript:forwardSlip();"> 
        <img src="../../../../images/print.gif" border="0"></a> <font size="1">Click 
        to print payslip</font>&nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>
	<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">    	
    <tr bgcolor="#B9B292" class="thinborder"> 
      <td height="23" colspan="5" align="center"><b>LIST OF EMPLOYEES FOR PRINTING.</b></td>
    </tr>
    <tr bgcolor="#ffff99" class="thinborder"> 
      <td class="thinborder" height="25" colspan="2" align="center"><strong>EMPLOYEE 
        ID</strong></td>
      <td class="thinborder" width="29%" align="center"><strong>EMPLOYEE NAME</strong></td>
			<%
				strTemp = "DEPARTMENT/OFFICE";
				if(bolMyHome)
					strTemp = "PAY NAME";
			%>
      <td class="thinborder" width="43%" align="center"><strong><%=strTemp%></strong></td>
      <td class="thinborder" width="8%" align="center"><strong>PRINT</strong></td>
    </tr>
    <% 	//System.out.println("size " +vRetResult.size());	
	for(int i = 0,iCount=1; i < vRetResult.size(); i +=15,++iCount){		
	%>
    <tr bgcolor="#FFFFFF" class="thinborder"> 
      <td class="thinborder" width="4%">&nbsp;<%=iCount%>.</td>
      <td class="thinborder" width="16%" height="30">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder" ><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
    <%
		 if(bolMyHome){
		 	strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+10));
		 } else {
				if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null)
					strTemp = " ";			
				else
					strTemp = " - ";
							
				strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i + 5)," ");
				strTemp2 += strTemp;
				strTemp2 += WI.getStrValue((String)vRetResult.elementAt(i + 6)," ");
		 }
		%>
      <td class="thinborder" >&nbsp;<%=strTemp2%></td>
      <td class="thinborder" align="center">
									<a href='javascript:PrintSlip("<%=(String)vRetResult.elementAt(i+1)%>",
	  							"<%=vRetResult.elementAt(i+8)%>",
									"<%=(String)vRetResult.elementAt(i)%>",
									"<%=(String)vRetResult.elementAt(i+9)%>",
									"<%=(String)vRetResult.elementAt(i+7)%>")'><img src="../../../../images/print.gif" border="0"></a></td>
    </tr>
    <%} // end for loop%>	
  </table>
  <%} // end if vRetResult != null && vRetResult.size() %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="reset_page">
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">
  <input type="hidden" name="print_all" value=""> 
	<input type="hidden" name="pay_name">	
	<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
<%
//if print all - i have to print all one by one.. 
if(WI.fillTextValue("print_all").compareTo("1") == 0 && vRetResult != null && vRetResult.size() > 0){
int iMaxPage = vRetResult.size()/15;
if(WI.fillTextValue("print_option2").length() > 0) {
//I have to now check if format entered is correct.
	int[] aiPrintPg = SOA.getPrintPage(WI.fillTextValue("print_option2"),iMaxPage);
	if(aiPrintPg == null) {
		strErrMsg = SOA.getErrMsg();%> 
		<script language="JavaScript">alert("<%=strErrMsg%>");</script><%
	}
	else {//print here.
		int iCount = 0; %>
		<script language="JavaScript">
		var countInProgress = 0;
		<%
		for(int i = 0; i < aiPrintPg.length; ++i,++iCount) {%>
			function PRINT_<%=iCount%>() {
				var pgLoc = "./payroll_slip_print_bonus.jsp?emp_id=<%=(String)vRetResult.elementAt(aiPrintPg[i] * 15 - 14)%>" +
					"&pay_index=<%=vRetResult.elementAt(aiPrintPg[i] * 15 - 7)%>&emp_bonus_index=<%=(String)vRetResult.elementAt(aiPrintPg[i] * 15 - 15)%>"+
					"&pt_ft=<%=vRetResult.elementAt(aiPrintPg[i] * 15 - 6)%>" +
					"&bonus_amt=<%=(String)vRetResult.elementAt(aiPrintPg[i] * 15 - 8)%>&finalize=1";
				window.open(pgLoc,"",'width=700,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
			}
		<%}%>
		function callPrintFunction() {
			//alert(countInProgress);
			if(eval(countInProgress) > <%=iCount-1%>)
				return;
			eval('this.PRINT_'+countInProgress+'()');//alert(countInProgress);
			countInProgress = eval(countInProgress) + 1;//alert(printCountInProgress);
		
			window.setTimeout("callPrintFunction()", 6000);
		}
		this.callPrintFunction();
		</script>
	<%
	}
}
else {
	//enter this only if page number is selected. -- but call the above only if page range in enter in the input box.
	int iPrintRangeTo = Integer.parseInt(WI.getStrValue(WI.fillTextValue("print_page_range"),"0"));
	int iPrintRangeFr = iPrintRangeTo - 25; if(iPrintRangeFr < 1) iPrintRangeFr = 0;
	if(iPrintRangeTo == iMaxPage && iMaxPage %25 > 0) {
		//i can't subtract just like that.. i have to find the last page count.
		iPrintRangeFr = iMaxPage - iMaxPage%25;	
	}
	%>
		<script language="JavaScript">
			var printCountInProgress = 0;
			var totalPrintCount = 0;
			<%int iCount = 0; 
			for(int i = 0; i < vRetResult.size(); i += 15,++iCount) {
				if(iPrintRangeTo > 0) {
					if( (iCount + 1) < iPrintRangeFr || (iCount + 1) > iPrintRangeTo)
						continue;				
				}%>
				
				function PRINT_<%=iCount%>() {
					var pgLoc = "./payroll_slip_print_bonus.jsp?emp_id=<%=(String)vRetResult.elementAt(i+1)%>" +
						"&pay_index=<%=vRetResult.elementAt(i+8)%>&emp_bonus_index=<%=(String)vRetResult.elementAt(i)%>" +
						"&pt_ft=<%=vRetResult.elementAt(i+9)%>" +
						"&bonus_amt=<%=(String)vRetResult.elementAt(i+7)%>&finalize=1";
					  window.open(pgLoc,"",'width=700,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');	
					//window.open(pgLoc);
				}//end of printing function.
			<%
		}//end of for loop.
		
		//for(int i = 0;  i < vRetResult.size(); i += 2){
		%>totalPrintCount = <%=iCount%>;
		printCountInProgress = <%=iPrintRangeFr%>;
		<%if(iPrintRangeTo == 0)
			iPrintRangeTo = iCount;
		%>
		totalPrintCount = <%=iPrintRangeTo%>;
		function callPrintFunction() {
			//alert(printCountInProgress);
			if(eval(printCountInProgress) >= eval(totalPrintCount))
				return;
			eval('this.PRINT_'+printCountInProgress+'()');//alert(printCountInProgress);
			printCountInProgress = eval(printCountInProgress) + 1;//alert(printCountInProgress);
		
			window.setTimeout("callPrintFunction()", 6000);
		}
		//function PrintALL(strIndex) {
			//if(eval(strIndex) < eval(totalPrintCount))
		//}	
			this.callPrintFunction();
		</script>

<%}//end if print_option2 is not entered.

}//end if print is called.%>
</body>
</html>
<%
dbOP.cleanUP();
%>