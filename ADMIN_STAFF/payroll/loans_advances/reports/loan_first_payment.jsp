<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan" %>
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
<title>Individual Total Loan balances</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

TD.BorderBottomLeft{
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottomLeftRight{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderAll{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottom{
    border-bottom: solid 1px #000000;
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
<!--
function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage(){
	document.form_.print_page.value="";
	document.form_.proceed.value = "1";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
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
-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp3 = null;
	int iRemaining = 0;
	boolean bolHasTeam = false;
//add security here.
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./loan_first_payment_print.jsp" />
<% return;}
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("RETIREMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("RETIREMENT"),"0"));
		}

		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES"),"0"));
			if(iAccessLevel == 0) {
				iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
			}						
		}		
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-LOANS-Reports-Individual Total balances","loan_first_payment.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");								
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
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	Vector vRetResult = null;
	String strLoanType = null;
	String strCodeIndex = null;
	String[] astrLoanType = {"Regular Retirement Loan","Emergency Loan","Institutional/Company Loan", "SSS Loan", "PAG-IBIG Loan", 
							"PERAA Loan","GSIS Loan"};
	String strTypeName = null;	
	boolean[] abolShowList= {false, false, false, false, false};
	int iIndex = 0;
	
	String[] astrSortByName    = {"Lastname","Loan Name"};
	String[] astrSortByVal     = {"lname","loan_name"};
	
	int iSearchResult = 0;
	int i = 0;
	int iDefault = 0;
	double dTotalLoan = 0d;
	double dTotalPaid = 0d;
	double dMonthlyTotal = 0d;
	double dPayable = 0d;
	String strPrevEmp = null;
	String strTemp2 = null;
	double dMonthly = 0d;
	double dBalance = 0d;
	for(; iIndex < 5; iIndex++){
		if(WI.fillTextValue("checkbox"+iIndex).equals("1")){
			abolShowList[iIndex] = true;
		}
	}
	if (WI.fillTextValue("proceed").length() > 0) {
		vRetResult = PRRetLoan.getLoanFirstPayment(dbOP,request);		
		if(vRetResult == null)
			strErrMsg = PRRetLoan.getErrMsg();		
		else{
		iSearchResult = PRRetLoan.getSearchCount();
		}
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="loan_first_payment.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: LOAN FIRST PAYMENT PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="3"color="#FF0000">&nbsp;<strong><a href="../loans_report_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a>&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"")%></strong></font></td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#E4EFFA">
    <tr>
      <td height="18" colspan="3">optional columns to display </td>
    </tr>
    <tr>
      <td width="27%" height="21">
			<%iIndex = 0;
		  if (abolShowList[0])  
				strTemp = "checked";
	  	else 
				strTemp = "1";
			%>
       <input type="checkbox" name="checkbox0" value="1" <%=strTemp%>>Reference </td>
      <td width="32%">
			<%if (abolShowList[1])  
					strTemp = "checked";
		  	else 
					strTemp = "2";
			%>
          <input type="checkbox" name="checkbox1" value="1" <%=strTemp%>>
      Date availed </td>
      <td width="41%">
			<%if (abolShowList[2])  
					strTemp = "checked";
		  	else 
					strTemp = "";
			%>
          <input type="checkbox" name="checkbox2" value="1" <%=strTemp%>>
      Show Loan Balance &nbsp;&nbsp; </td>
    </tr>
    <tr>
      <td height="21">
			<%if (abolShowList[3])  
					strTemp = "checked";	
				else 
				strTemp = "";%>
          <input type="checkbox" name="checkbox3" value="1" <%=strTemp%>>
        Payment to Date </td>
      <td>
			<%if (abolShowList[4])  
					strTemp = "checked";
		  	else 
					strTemp = "5";
			%>
          <input type="checkbox" name="checkbox4" value="1" <%=strTemp%>>
          Remaining Period </td>
      <td>&nbsp;</td>
    </tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		
		<tr>
		  <td height="24">&nbsp;</td>
		  <td>Start Date </td>
		  <td colspan="3">From
        <input name="date_from" type="text" size="10" maxlength="10"
	  value="<%=WI.fillTextValue("date_from")%>" class="textbox"
	  onKeyUp="AllowOnlyIntegerExtn('form_','date_from','/');"
	  onfocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_from','/')">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a> &nbsp;&nbsp;to
        &nbsp;&nbsp;
        <input name="date_to" type="text" size="10" maxlength="10"
		value="<%=WI.fillTextValue("date_to")%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'"
		onKeyUP = "AllowOnlyIntegerExtn('form_','date_to','/')"
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_to','/')">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
	  </tr>
		<%if(bolIsSchool){%>
		<tr>
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td colspan="3">
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
      <td colspan="3"> <select name="c_index" onChange="loadDept();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3">
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
      <td>Office/Dept filter</td>
      <td colspan="3"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee ID </td>
      <td height="10" colspan="3"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
        <label id="coa_info"></label>			</td>
    </tr>
		<%if(bolHasTeam){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Team</td>
      <td width="78%" colspan="2"><select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select></td>
    </tr>
    <%}%>
    <tr> 
      <td height="10" colspan="5"><hr size="1" color="#000000"></td>
    </tr>
    
    
		
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="19%" height="27">Loan Type</td>
      <%
	  	strLoanType = WI.fillTextValue("loan_type");
	  %>	  
      <td width="78%">
	  <select name="loan_type" onChange="ReloadPage();">	  	
		<option value="" selected>ALL</option>
		<%for(i = 2; i < 7; i++){%>        
        <%if(strLoanType.equals(Integer.toString(i))){
		strTypeName = astrLoanType[i];
		%>
        <option value="<%=i%>" selected><%=astrLoanType[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrLoanType[i]%></option>
        <%}%>
		<%}// end for loop%>
      </select>			</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27">Loan Name </td>
	  <%
	  	strCodeIndex = WI.fillTextValue("code_index");
	  %>
      <td height="27">
	    <select name="code_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%=dbOP.loadCombo("code_index","loan_name, loan_code",
		                    " from ret_loan_code where is_valid = 1 and loan_type = " + WI.getStrValue(strLoanType,"2"),
							strCodeIndex ,false)%>
        </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="18">Loan Balance </td>
			<%
				strTemp = WI.fillTextValue("balance_opt");
				if(request.getParameter("balance_opt") == null)
					strTemp = "1";
			%>
      <td height="18">
			<select name="balance_opt" onChange="ReloadPage();">
        <option value="">All</option>
        <%if (strTemp.equals("0")){%>
        <option value="0" selected>Without payable</option>
        <%}else{%>
        <option value="0">Without payable</option>
        <%}if (strTemp.equals("1")){%>
        <option value="1" selected>With payable</option>
        <%}else{%>
        <option value="1">With payable</option>
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="18">Process Option</td>
			<%
			String strAuthID = (String) request.getSession(false).getAttribute("userIndex");
			if(strAuthID == null || strAuthID.length() == 0)
				strAuthID = "0";
			%>					
      <td height="18"><select name="group_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("group_index","group_name"," from pr_preload_group " +
													" where exists(select user_index from pr_group_proc " +
													" 	where pr_preload_group.group_index = pr_group_proc.group_index " +
													" 	and user_index = " + strAuthID + ") order by group_name", WI.fillTextValue("group_index"), false)%>
      </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="18" colspan="2"><%
				if(WI.fillTextValue("view_all").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>
        <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">
View ALL </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="18">Sort by</td>
      <td height="18"><select name="sort_by1">
        <option value="">N/A</option>
        <%=PRRetLoan.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;</td>
      <td height="27"><select name="sort_by1_con">
        <option value="asc">Ascending</option>
        <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
    </tr>
    
    <tr> 
      <td>&nbsp;</td>
      <td height="27">&nbsp;</td>
      <td height="27">
			<!--
			<a href="javascript:ReloadPage()"><img src="../../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
			<font size="1">click to list loan balances</font></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="13" align="right">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="13" align="right">Number of records per page 
          <select name="num_rows">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rows"),"20"));
				for(i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
        <a href="javascript:PrintPg();"> <img src="../../../../images/print.gif" border="0"></a> 
        <font size="1">click to print list</font></td>
    </tr>
    <%		
		if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/PRRetLoan.defSearchSize;		
	if(iSearchResult % PRRetLoan.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr> 
      <td height="25" colspan="13" align="right">Jump To page: 
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
          </select>      </td>
    </tr>
    <%}
		}%>
    <tr>
      <td height="15" colspan="13" align="center" class="BorderBottom"><strong>Loans First Payment </strong></td>
    </tr>
    <tr> 
      <td width="3%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">COUNT</font></strong></td>
      <td width="7%" align="center" class="BorderBottomLeft"><strong><font size="1">ID</font></strong></td>
      <td width="24%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">EMPLOYEE 
      NAME</font></strong></td>
			<%if (abolShowList[0]){%>
      <td width="8%" align="center" class="BorderBottomLeft"><strong><font size="1">REF # </font></strong></td>
			<%}%>
      <td width="8%" align="center" class="BorderBottomLeft"><strong><font size="1">LOAN CODE </font></strong></td>
      <%if (abolShowList[1]){%>
			<td width="10%" align="center" class="BorderBottomLeft"><strong><font size="1">DATE AVAILED </font></strong></td>
			<%}%>
			<td width="8%" align="center" class="BorderBottomLeft"><strong><font size="1">START DATE </font></strong></td>
      <td width="8%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">AMOUNT LOAN </font></strong></td>
			<td width="8%" align="center" class="BorderBottomLeft"><strong><font size="1">MONTHLY </font></strong></td>
      <!--
			<td width="12%" align="center" class="BorderBottomLeft"><strong><font size="1">TOTAL PAYMENT</font></strong></td>
			-->
      <%if (abolShowList[2]){%>
			<td width="8%" align="center" class="BorderBottomLeft"><strong><font size="1">LOAN BALANCE</font></strong></td>
			<%}%>
      <%if (abolShowList[3]){%>
			<td width="8%" align="center" nowrap class="BorderBottomLeft"><strong><font size="1">PAYMENT<br>
			  TO DATE<br>
			  (in System)
</font></strong></td>
			<%}%>
			<%if (abolShowList[4]){%>
      <td width="8%" align="center" class="BorderBottomLeftRight"><strong><font size="1">REMAINING PERIOD </font></strong></td>
			<%}%>
    </tr>
    <%
	int iCount = 1;
	strPrevEmp = "";
	for(i = 0; i < vRetResult.size(); i+=20){
		if(strPrevEmp.equals((String)vRetResult.elementAt(i+8))){
			strTemp2 = "";
			strTemp = "";
			strTemp3 = "";
		}else{			
			strTemp = Integer.toString(iCount)+".";
			strTemp2 = WI.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), 4);
			strTemp3 = (String)vRetResult.elementAt(i+10);
			iCount++;
		}
	%>
    <tr> 
      <td height="24" align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
      <td class="BorderBottomLeft"><%=WI.getStrValue(strTemp3,"&nbsp;")%></td>
      <td height="24" class="BorderBottomLeft"><font size="1"><strong>&nbsp;&nbsp;<%=strTemp2%></strong></font></td>
      <%if (abolShowList[0]){%>
			<td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9),"&nbsp;")%></td>
			<%}%>
      <td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+13),"&nbsp;")%></td>
      <%if (abolShowList[1]){%>
			<td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+11),"&nbsp;")%></td>
			<%}%>
      <td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+16),"&nbsp;")%></td> 
      <%	
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+5),true);
				strTemp = ConversionTable.replaceString(strTemp,",","");		
				dTotalLoan += Double.parseDouble(strTemp);
			%>
			<td height="24" align="right" class="BorderBottomLeft">&nbsp;<%=strTemp%>&nbsp;</td>
      <%	
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+12),true);
			dMonthly = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));			
			dMonthlyTotal += dMonthly;
		  %>				
			<td align="right" class="BorderBottomLeft">&nbsp;<%=strTemp%>&nbsp;</td>			
	  <!--
		<td align="right" class="BorderBottomLeft">&nbsp;<%//=strTemp%>&nbsp;</td>
		-->
		<%if (abolShowList[2]){
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+6),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dBalance = Double.parseDouble(strTemp);
		dPayable += dBalance;
		%>      
	  <td align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
		<%}%>
	  <%if (abolShowList[3]){%>
		<%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+15),true);
	  %>	
    <td align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
		<%}%>
		<%if (abolShowList[4]){%>
		<%		
		//iRemaining = (int)(dBalance/dMonthly);
		//dBalance = dBalance - (dMonthly * iRemaining);
		//if(dBalance > 3)
		//	iRemaining++;
			strTemp = (String)vRetResult.elementAt(i+14);
	  %>			
    <td align="right" class="BorderBottomLeftRight"><%=strTemp%></td>
		<%}%>
    </tr>
    <%
		strPrevEmp = (String)vRetResult.elementAt(i+8);
		}// end for loop %>
    <tr> 
      <td height="24" colspan="3" align="right" class="BorderBottomLeft">TOTAL :&nbsp;&nbsp;&nbsp;</td>
      <%if (abolShowList[0]){%>
			<td class="BorderBottomLeft">&nbsp;</td>
      <%}%>
			<td class="BorderBottomLeft">&nbsp;</td>			
      <%if (abolShowList[1]){%>
			<td class="BorderBottomLeft">&nbsp;</td>
      <%}%>
			<td align="right" class="BorderBottomLeft">&nbsp;</td>			
			<td align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dTotalLoan,true)%>&nbsp;</td>			
      <td height="24" align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dMonthlyTotal,true)%>&nbsp;</td>
			
      <!--
			<td align="right" class="BorderBottomLeft"><%//=CommonUtil.formatFloat(dTotalPaid,true)%>&nbsp;</td>
			-->
			<%if (abolShowList[2]){%>
      <td align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dPayable,true)%>&nbsp;</td>
			<%}%>
      <%if (abolShowList[3]){%>
			<td align="right" class="BorderBottomLeft">&nbsp;</td>
			<%}%>
			<%if (abolShowList[4]){%>
      <td align="right" class="BorderBottomLeftRight">&nbsp;</td>
			<%}%>
    </tr>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="proceed">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>