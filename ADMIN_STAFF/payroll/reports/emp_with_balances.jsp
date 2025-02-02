<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan,payroll.ReportPayrollExtn" %>
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
<title>Employee balances</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
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
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.print_page.value="";
 	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.proceed.value = "1";	
	document.form_.submit();
}

function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function ViewDetails(strCodeIndex) {
	var pgLoc = "../loans_advances/reconciliation/emp_loans_recon.jsp?hide_navigator=1"+
							"&emp_id="+document.form_.emp_id.value+"&code_index="+strCodeIndex+
							"&my_home="+document.form_.my_home.value;
 	var win=window.open(pgLoc,"viewDetails",'width=700,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolMyHome = false;	
	String strEmpID = null;
//add security here.
	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;
		
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./emp_with_balances_print.jsp" />
<% return;}

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-REPORTS"),"0"));
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
								"Admin/staff-Payroll-Reports-Employee Payable Balances","emp_with_balances.jsp");
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
	ReportPayrollExtn rptMisc = new ReportPayrollExtn(request);
	Vector vLoans = null;
	Vector vPersonalDetails = null;
	Vector vPostCharges = null;
	int iCount = 1;
	String[] astrLoanType = {"Retirement","Emergency","Institutional/Company", "SSS ", "PAG-IBIG", 
							"PERAA","GSIS"};
	
	int iLoansResult = 0;
	int iChargeResult = 0;
	int i = 0;
	int iDefault = 0;
	double dTotalLoan = 0d;
	double dTotalPaid = 0d;
	double dPayable = 0d;	

	if (WI.fillTextValue("proceed").length() > 0) {
		enrollment.Authentication authentication = new enrollment.Authentication();
		vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");

		if (vPersonalDetails == null || vPersonalDetails.size()==0){
			strErrMsg = authentication.getErrMsg();
			vPersonalDetails = null;
		}
			
		vLoans = PRRetLoan.getEmpLoanWithBalance(dbOP,request);		
		if(vLoans != null)
			iLoansResult = PRRetLoan.getSearchCount();
		
		vPostCharges = rptMisc.getUnpaidPostCharges(dbOP);
		if(vPostCharges != null && vPostCharges.size() > 1)
			iChargeResult = rptMisc.getSearchCount();		
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="emp_with_balances.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: REPORTS - EMPLOYEE BALANCES PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font color="#FF0000"><strong><%=WI.getStrValue(strErrMsg,"")%></strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%if(!bolMyHome){%>
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="14%" height="27">Employee ID</td>
      <td width="83%">
			<input name="emp_id" type="text" size="16" onKeyUp="AjaxMapName(1);"
			value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	 		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
    </tr>
	<%}else{%>
		<input type="hidden" name="emp_id" value="<%=strEmpID%>">
	<%}%>
		<!--
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="12%" height="27"> Date :</td>
	  <%
	  	strTemp = WI.fillTextValue("end_date");
		if(strTemp.length() == 0){
			strTemp = WI.getTodaysDate(1);
		}
	  %>	  
	  <td width="85%"><strong>
	    <input name="end_date" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp,"")%>" size="12" maxlength="12" readonly="yes">
        <a href="javascript:show_calendar('form_.end_date');"><img src="../../../images/calendar_new.gif" border="0"></a></strong></td>
    </tr>
    -->
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
			<a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">			</td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
	<%if(vPersonalDetails != null && vPersonalDetails.size() > 0){%>  
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
      <td height="29">&nbsp;Employee ID : <strong><%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <%
				strTemp = (String)vPersonalDetails.elementAt(13);
				if (strTemp == null)
					strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
				else
					strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
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
      <td height="13" colspan="2"><hr size="1" noshade></td>
    </tr>
  </table>
	<%}%>
	<%if((vLoans != null && vLoans.size() > 0)
		|| (vPostCharges != null && vPostCharges.size() > 1)){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="97%" height="18">OUTSTANDING BALANCES AS OF <%=WI.getTodaysDate(1)%></td>
    </tr>
    <tr> 
      <td height="10" colspan="2" align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> <font size="1">click to print list</font></td>
    </tr>
  </table>  
	<%}%>
	<%if(vLoans != null && vLoans.size() > 0){%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    <%		
	int iPageCount = iLoansResult/PRRetLoan.defSearchSize;		
	if(iLoansResult % PRRetLoan.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr> 
      <td height="25" colspan="6"><div align="right">Jump To page: 
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
          </select>
        </div></td>
    </tr>
    <%}%>
    <tr>
      <td height="10" colspan="6" class="BorderBottom">&nbsp;</td>
    </tr>
    <tr> 
      <td width="7%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">COUNT</font></strong></td>
      <td width="30%" align="center" class="BorderBottomLeft"><strong><font size="1">LOAN NAME </font></strong></td>
      <td width="16%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">TOTAL 
      LOAN </font></strong></td>
      <td width="16%" align="center" class="BorderBottomLeft"><strong><font size="1">TOTAL PAYMENT</font></strong></td>
      <td width="16%" align="center" class="BorderBottomLeftRight"><strong><font size="1"> BALANCE</font></strong></td>
      <td width="15%" align="center" class="BorderBottomLeftRight"><strong>DETAILS</strong></td>
    </tr>
    <%
	iCount = 1;
	for(i = 0; i < vLoans.size(); i+=13,iCount++){
	%>
    <tr> 
      <td height="24" align="right" class="BorderBottomLeft"><%=iCount%>&nbsp;</td>
      <td class="BorderBottomLeft">&nbsp;<%=astrLoanType[Integer.parseInt((String)vLoans.elementAt(i+2))]%> (<%=WI.getStrValue((String)vLoans.elementAt(i+1),"&nbsp;")%>)</td>
      <%	
		strTemp = CommonUtil.formatFloat((String)vLoans.elementAt(i+3),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTotalLoan += Double.parseDouble(strTemp);
	%>							
      <td height="24" align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
    <%	
		strTemp = CommonUtil.formatFloat((String)vLoans.elementAt(i+5),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTotalPaid += Double.parseDouble(strTemp);
	%>      
	  <td align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
    <%	
		strTemp = CommonUtil.formatFloat((String)vLoans.elementAt(i+4),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dPayable += Double.parseDouble(strTemp);
	%>      
	  <td align="right" class="BorderBottomLeftRight"><%=strTemp%>&nbsp;</td>
      <!--
	  <td class="BorderBottomLeftRight"><div align="center"><a href="javascript:ViewDetails('<%=(String)vLoans.elementAt(i+6)%>')"><img src="../../../images/view.gif" border="0" ></a></div></td>
	  -->
	    <td align="center" class="BorderBottomLeftRight">
	        <a href="javascript:ViewDetails('<%=(String)vLoans.elementAt(i+6)%>');">
          <img src="../../../images/view.gif" border="0" ></a></td>
    </tr>
    <%}%>
    <tr> 
      <td height="24" colspan="2" align="right" class="BorderBottomLeft">TOTAL :&nbsp;&nbsp;&nbsp;</td>
      <td height="24" align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dTotalLoan,true)%>&nbsp;</td>
      <td align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dTotalPaid,true)%>&nbsp;</td>
      <td align="right" class="BorderBottomLeftRight"><%=CommonUtil.formatFloat(dPayable,true)%>&nbsp;</td>
      <td class="BorderBottomLeftRight">&nbsp;</td>
    </tr>
  </table>
	<%}%>
<%if(vPostCharges != null && vPostCharges.size() > 1){%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    <%		
	int iPageCount = iChargeResult/rptMisc.defSearchSize;		
	if(iChargeResult % rptMisc.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr> 
      <td height="25" colspan="3" align="right">Jump To page: 
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
          </select>        </td>
    </tr>
    <%}%>
    <tr>
      <td height="10" colspan="3" class="BorderBottom">&nbsp;</td>
    </tr>
    <tr> 
      <td width="13%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">COUNT</font></strong></td>
      <td width="58%" align="center" class="BorderBottomLeft"><strong><font size="1">POST CHARGE NAME </font></strong></td>
      <td width="29%" align="center" class="BorderBottomLeftRight"><strong><font size="1">BALANCE</font></strong></td>
    </tr>
    <%
	iCount = 1;
	dPayable = 0d;
	for(i = 1; i < vPostCharges.size(); i+=3,iCount++){
	%>
    <tr> 
      <td height="24" align="right" class="BorderBottomLeft"><%=iCount%>&nbsp;</td>
      <td class="BorderBottomLeft"><%=WI.getStrValue((String)vPostCharges.elementAt(i+1),"&nbsp;")%></td>
      <%	
				strTemp = CommonUtil.formatFloat((String)vPostCharges.elementAt(i+2),true);
				strTemp = ConversionTable.replaceString(strTemp,",","");		
				dPayable += Double.parseDouble(strTemp);
			%>      
	  <td align="right" class="BorderBottomLeftRight">&nbsp;<%=strTemp%>&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td height="24" colspan="2" align="right" class="BorderBottomLeft">TOTAL :&nbsp;&nbsp;&nbsp;</td>
      <td align="right" class="BorderBottomLeftRight"><%=CommonUtil.formatFloat(dPayable,true)%>&nbsp;</td>
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