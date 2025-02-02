<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan,payroll.PRMiscDeduction" %>
<%
WebInterface WI = new WebInterface(request);
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
 //strColorScheme is never null. it has value always.
	boolean bolMyHome = false;	
	String strEmpID = null;
	
//add security here.
	if (WI.fillTextValue("my_home").equals("1")) {
		strColorScheme = CommonUtil.getColorScheme(9);
		bolMyHome = true;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee Loans Balances</title>
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

function CopyID(strID)
{
	document.form_.print_page.value="";
	document.form_.emp_id.value=strID;
	document.form_.proceed.value = "1";
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
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.proceed.value = "1";
		document.form_.print_page.value="";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function focusID(){
	<%if(!bolMyHome){%>
	document.form_.emp_id.focus();
	<%}%>
}
-->
</script>
<%
	DBOperation dbOP = null;	
	String strErrMsg = "";
	String strTemp = null;
		
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./emp_loans_balance_print.jsp" />
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
		
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES"),"0"));
			if(iAccessLevel == 0) {
				iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
			}						
		}
	}
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
								"Admin/staff-Payroll-LOANS-Reports-Employee Loan Balances","emp_loans_balance.jsp");
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
	String strSchCode = dbOP.getSchoolIndex();
	//end of authenticaion code.	
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	PRMiscDeduction prd = new PRMiscDeduction(request);
	Vector vRetResult = null;
	Vector vPersonalDetails = null;
	Vector vEmpList = null;
	String strLoanType = null;
	String strCodeIndex = null;
	String[] astrLoanType = {"Retirement","Emergency","Institutional/Company", "SSS ", "PAG-IBIG", 
							"PERAA","GSIS"};
	String strTypeName = null;	
	
	String[] astrSortByName    = {"Lastname","Loan Name"};
	String[] astrSortByVal     = {"lname","loan_name"};
	
	int iSearchResult = 0;
	int i = 0;
	int iDefault = 0;
	double dTotalLoan = 0d;
	double dTotalPaid = 0d;
	double dPayable = 0d;
	payroll.PRConfidential prCon = new payroll.PRConfidential();
	boolean bolCheckAllowed = (prCon.checkIfEmpIsProcessor(dbOP, request, WI.fillTextValue("emp_id"), true) == 1);
	 
	if (WI.fillTextValue("proceed").length() > 0 || (strEmpID != null && strEmpID.length() > 0)) {
		if(bolCheckAllowed || bolMyHome){
			enrollment.Authentication authentication = new enrollment.Authentication();
			vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	
			if (vPersonalDetails == null || vPersonalDetails.size()==0){
				strErrMsg = authentication.getErrMsg();
				vPersonalDetails = null;
			}
			
			if(PRRetLoan.loanSchedulingFix(dbOP) == false)
				strErrMsg = PRRetLoan.getErrMsg();
	 
			//if(strSchCode.startsWith("FOODA") && !bolMyHome){
				if(PRRetLoan.fixLoanPayable(dbOP, request) == false)
					strErrMsg = PRRetLoan.getErrMsg();
		//	}
	
			vRetResult = PRRetLoan.getEmpLoanWithBalance(dbOP,request);		
			if(vRetResult == null)
				strErrMsg = PRRetLoan.getErrMsg();		
			else{
				iSearchResult = PRRetLoan.getSearchCount();
			}
		}else
	   strErrMsg = prCon.getErrMsg();
	}
	vEmpList = prd.getEmployeesList(dbOP);
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="focusID();">
<form name="form_" method="post" action="emp_loans_balance.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: EMPLOYEE LOAN BALANCES PAGE ::::</strong></font></td>
    </tr>
	<%if(!bolMyHome){%>
    <tr bgcolor="#FFFFFF">
      <td height="25" align="right"><%
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
	<%}%>
    <tr bgcolor="#FFFFFF">
      <td height="25"> 
        <%if(!bolMyHome){%>
      	<a href="../loans_report_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a>&nbsp;
      <%}%><strong><font color="#FF0000" size="3"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
  </table>
  <%if(!bolMyHome){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="14%" height="27">Employee ID</td>
      <td width="83%">
			<input name="emp_id" type="text" size="16" onKeyUp="AjaxMapName(1);"
			value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	 		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18" valign="top">
			<div style="position:absolute;width:500px;">
			<label id="coa_info"></label>
			</div>
			</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27">&nbsp;</td>
      <td height="27">
			<!--
			<a href="javascript:ReloadPage()"><img src="../../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();"></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
	<%}else{%>
		<input type="hidden" name="emp_id" value="<%=strEmpID%>">
	<%}%>
<%if(vRetResult != null && vRetResult.size() > 0 && vPersonalDetails != null && vPersonalDetails.size() > 0){%>  
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td width="3%" height="29">&nbsp;</td>
      <td height="29">&nbsp;Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;Employee ID : <strong><%=strEmpID%></strong></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <%
	strTemp = (String)vPersonalDetails.elementAt(13);
	if (strTemp == null){
		strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
	}else{
		strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
	}
%>
      <td height="30">&nbsp;
        <%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>&nbsp;Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td width="97%">&nbsp;Employment Status<strong> : <%=(String)vPersonalDetails.elementAt(16)%> </strong></td>
    </tr>
    <tr>
      <td height="19" colspan="2"><hr size="1" noshade></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="97%" height="27">OUTSTANDING BALANCES of <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 1).toUpperCase()%></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27"> AS OF <%=WI.getTodaysDate(1)%></td>
    </tr>
    <tr> 
			<%
				strTemp = WI.fillTextValue("show_payable");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else	
					strTemp = "";
			%>
      <td height="10" colspan="2">
	  <input type="checkbox" name="show_payable" value="1" <%=strTemp%> onClick="javascript:ReloadPage();"> Show TOTAL PAYABLE column 
	  &nbsp;&nbsp;&nbsp;
	  <input type="checkbox" name="show_closed" value="checked" <%=WI.fillTextValue("show_closed")%> onClick="javascript:ReloadPage();"> Show Loans Already Closed/Paid in Full
	  
	  </td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="8" align="right"><a href="javascript:PrintPg();"> <img src="../../../../images/print.gif" border="0"></a> 
        <font size="1">click to print list</font></td>
    </tr>
    <%		
	int iPageCount = iSearchResult/PRRetLoan.defSearchSize;		
	if(iSearchResult % PRRetLoan.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr> 
      <td height="25" colspan="8" align="right">Jump To page: 
          <select name="jumpto" onChange="SearchEmployee();">
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
    <%}%>
    <tr>
      <td height="15" colspan="8" class="BorderBottom">&nbsp;</td>
    </tr>
    <tr> 
      <td width="5%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">COUNT</font></strong></td>
      <td width="33%" align="center" class="BorderBottomLeft"><strong><font size="1">LOAN NAME </font></strong></td>
      <td width="10%" align="center" class="BorderBottomLeft"><strong><font size="1">REF NO </font></strong></td>
      <td width="10%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">      LOAN APPLIED</font></strong></td>
      <%if(WI.fillTextValue("show_payable").length() > 0){%>
			<td width="11%" align="center" class="BorderBottomLeft"><strong><font size="1">TOTAL PAYABLE </font></strong></td>
			<%}%>
      <td width="11%" align="center" class="BorderBottomLeft"><strong><font size="1">TOTAL PAYMENT</font></strong></td>
      <td width="10%" align="center" class="BorderBottomLeftRight"><strong><font size="1">LOAN BALANCE</font></strong></td>
      <td width="10%" align="center" class="BorderBottomLeftRight"><strong>DETAILS</strong></td>
    </tr>
    <%
	int iCount = 1;
	for(i = 0; i < vRetResult.size(); i+=13,iCount++){
	%>
    <tr> 
      <td height="24" align="right" class="BorderBottomLeft"><%=iCount%>&nbsp;</td>
      <td class="BorderBottomLeft">&nbsp;<%=astrLoanType[Integer.parseInt((String)vRetResult.elementAt(i+2))]%> (<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%>)</td>
      <td align="left" class="BorderBottomLeft"><%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp;")%></td>
      <%	
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+3),true);
				strTemp = ConversionTable.replaceString(strTemp,",","");		
				dTotalLoan += Double.parseDouble(strTemp);
			%>							
      <td height="24" align="right" class="BorderBottomLeft">&nbsp;<%=strTemp%>&nbsp;</td>
      <%if(WI.fillTextValue("show_payable").length() > 0){%>
			<%	
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+9),true);
				strTemp = ConversionTable.replaceString(strTemp,",","");		
			%>		
      <td align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
			<%}%>
      <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+5),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTotalPaid += Double.parseDouble(strTemp);
	%>      
	  <td align="right" class="BorderBottomLeft">&nbsp;<%=strTemp%>&nbsp;</td>
    <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dPayable += Double.parseDouble(strTemp);
	%>      
	  <td align="right" class="BorderBottomLeftRight">&nbsp;<%=strTemp%>&nbsp;</td>
      <!--
	  <td class="BorderBottomLeftRight"><div align="center"><a href="javascript:ViewDetails('<%=(String)vRetResult.elementAt(i+6)%>')"><img src="../../../../images/view.gif" border="0" ></a></div></td>
	  -->
	  <td class="BorderBottomLeftRight"><div align="center">
	  <a href="../reconciliation/emp_loans_recon.jsp?code_index=<%=(String)vRetResult.elementAt(i+6)%>&emp_id=<%=WI.getStrValue(WI.fillTextValue("emp_id"), strEmpID)%>&my_home=<%=WI.fillTextValue("my_home")%>">
	  <img src="../../../../images/view.gif" border="0" ></a></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="24" colspan="3" align="right" class="BorderBottomLeft">TOTAL :&nbsp;&nbsp;&nbsp;</td>
      <td height="24" align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dTotalLoan,true)%>&nbsp;</td>
      <%if(WI.fillTextValue("show_payable").length() > 0){%>
			<td align="right" class="BorderBottomLeft">&nbsp;</td>
			<%}%>
      <td align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dTotalPaid,true)%>&nbsp;</td>
      <td align="right" class="BorderBottomLeftRight"><%=CommonUtil.formatFloat(dPayable,true)%>&nbsp;</td>
      <td class="BorderBottomLeftRight">&nbsp;</td>
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
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
  <input type="hidden" name="print_page">
  <input type="hidden" name="proceed">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>