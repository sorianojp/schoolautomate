<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll,payroll.PReDTRME,java.util.Date" %>
<%
///added code for HR/companies.
WebInterface WI = new WebInterface(request);
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
boolean bolHasConfidential = false;
boolean bolHasTeam = false;
boolean bolRemoveOtherEarnings = true;

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Allowance Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
TD.BOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.BOTTOMTOPLEFTRIGHT {
	border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.BOTTOMTOPLEFT {
	border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.BOTTOMTOPLEFT {
	border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.BOTTOMLEFTRIGHT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.BOTTOMLEFT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.BOTTOMRIGHT {
	border-right: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function PrintPg(){
	if(!confirm('Click OK to print report.'))
		return;
	
	var obj = document.getElementById('myADTable1');
	obj.deleteRow(0);
	
	obj = document.getElementById('myADTable2');
	for(i = 0; i < 10; ++i)
		obj.deleteRow(0);

	obj = document.getElementById('myADTable3');
	obj.deleteRow(0);
	obj.deleteRow(0);
	
	window.print();
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
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
							 "&year_of="+strYear+"&is_weekly="+strWeekly+"&onchange=ReloadPage()";

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
</script>

<%

	DBOperation dbOP = null;	
	String strErrMsg = null;

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Register","posted_allowance.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
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
														"posted_allowance_by_dept_basic.jsp.jsp");
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

	ReportPayroll rptPayroll = new ReportPayroll(request, dbOP);

	Vector vRetResult = rptPayroll.getYearlyNoTaxIncome(); 
	String[] astrTaxStatus = {"Zero Exemption","Single","Head of the Family","Married","Not Set"};
	if( vRetResult.isEmpty() )
		strErrMsg = "No Records Found.";

	String strTemp = null;
	double dTemp  = 0d;
	double dBasicSalaryDept = 0d;
	double dMiscAmtDept = 0d;
	double dOvertimeDept = 0d;
	double dTXIncomeDept = 0d;
	double dGrossSalaryDept = 0d;
	double dWTaxDept = 0d;
	double dPHICDept = 0d;
	double dSSSDept = 0d;
	double dHDMFDept = 0d;
	double dNTXIncomeDept = 0d;
	
	double dBasicSalaryGrand = 0d;
	double dMiscAmtGrand = 0d;
	double dOvertimeGrand = 0d;
	double dTXIncomeGrand = 0d;
	double dGrossSalaryGrand = 0d;
	double dWTaxGrand = 0d;
	double dPHICGrand = 0d;
	double dSSSGrand = 0d;
	double dHDMFGrand = 0d;
	double dNTXIncomeGrand = 0d;
%>
<body>
<form name="form_" 	method="post" >
<% if ( !vRetResult.isEmpty() ){ %>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">  	
  	<tr>      
      <td height="10" align="center"><strong><font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong> <br />
	  <font size ="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>
	  </td>
    </tr>  
		<tr> 
			<td height="30" align="center"><strong><font>NON-TAXABLE INCOME REPORT </font></strong></td>
		</tr>
	</table>
  
  <table width="100%" cellpadding="0" cellspacing="0">
  	 <tr>
      <td align="right" >Date and time printed : <%=WI.getTodaysDateTime()%></td>
    </tr>
  </table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" align="center" class="thinborder">  
    	<tr align="center" style="font-weight:bold">      
     		<td height="22" colspan="4" class="BOTTOM" >&nbsp;</td>
			<td width="4%" class="BOTTOMTOPLEFT"  align="center">A</td> 
			<td width="4%" class="BOTTOMTOPLEFT" >B</td> 
			<td width="4%" class="BOTTOMTOPLEFT" >C</td>
			<td width="6%" class="BOTTOMTOPLEFT" >D</td> 
			<td width="6%" class="BOTTOMTOPLEFT" >E</td>
			
			<td width="8%" class="BOTTOMTOPLEFT" >F</td> 
			<td width="8%" class="BOTTOMTOPLEFT" >G</td> 
			<td width="9%" class="BOTTOMTOPLEFT" >H</td>
			<td width="9%" class="BOTTOMTOPLEFT" >I</td> 
			<td width="8%" class="BOTTOMTOPLEFTRIGHT" >J</td> 
 		</tr>
		<tr align="center" style="font-weight:bold">      
     		<td width="11%" height="22" class="BOTTOMLEFT" >ID No.</td>
	 		<td width="9%" class="BOTTOMLEFT" >LAST NAME</td>
	 		<td width="8%" class="BOTTOMLEFT" >FIRST NAME</td>
			<td width="6%" class="BOTTOMLEFT" >TAX STATUS</td>
			<td width="4%" class="BOTTOMLEFT" >SUM OF BASIC SALARY</td> 
			<td width="4%" class="BOTTOMLEFT" >SUM OF MISC AMOUNT</td> 
			<td width="4%" class="BOTTOMLEFT" >SUM OF OVERTIME</td>
			<!--
			 -->
			<td width="6%" class="BOTTOMLEFT" >SUM OF OTHER TX INCOME</td> 
			<td width="6%" class="BOTTOMLEFT" >SUM OF GROSS INCOME</td>			
			<td width="8%" class="BOTTOMLEFT" >SUM OF WITHOLDING TAX</td> 
			<td width="8%" class="BOTTOMLEFT" >SUM OF EMPLOYEE SSS PREMIUM</td>
			<td width="9%" class="BOTTOMLEFT" >SUM OF EMPLOYEE PHIC PREMIUM</td> 
			<td width="9%" class="BOTTOMLEFT" >SUM OF EMPLOYEE HDMF PREMIUM</td>
			<td width="8%" class="BOTTOMLEFTRIGHT" >SUM OF OTHER NTX INCOME</td>  
 		</tr>
		<% 
		for(int i=0; i<vRetResult.size(); i+=20) {
		%>
		<tr align="right">
    	  <td  height="22" class="BOTTOMLEFT" align="left">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
    	  <td  class="BOTTOMLEFT" align="left">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
    	  <td  class="BOTTOMLEFT" align="left">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>	
		  <%
		  	int iTemp = ((Integer)vRetResult.elementAt(i+7)).intValue();
			strTemp = astrTaxStatus[( iTemp > 4 ? 4 : iTemp ) ];
		  %>	  
		  <td  class="BOTTOMLEFT" align="left">&nbsp;<%=strTemp%></td>
    	  <%
		  	double dBasicSalary = ((Double)vRetResult.elementAt(i+8)).doubleValue();
			dTemp = dBasicSalary;
			dBasicSalaryDept += dTemp;
			dBasicSalaryGrand += dTemp;
		  %>
		  <td  class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp+"",true)%>&nbsp;</td>
		  <%
		  	double dMiscAmt = ((Double)vRetResult.elementAt(i+9)).doubleValue();
			dTemp = dMiscAmt; 
		  	dMiscAmtDept += dTemp;
			dMiscAmtGrand += dTemp;
		  %>
		  <td  class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp+"",true)%>&nbsp;</td>
		  <%
		  	double dOvertime = ((Double)vRetResult.elementAt(i+10)).doubleValue();
			dTemp = dOvertime; 
		  	dOvertimeDept += dTemp;
			dOvertimeGrand += dTemp;
		  %>
    	  <td  class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp+"",true)%>&nbsp;</td>
		  <%
		  	double dOtherTXIncome = ((Double)vRetResult.elementAt(i+17)).doubleValue();
			dTemp = dOtherTXIncome; 
		  	dTXIncomeDept += dTemp;
			dTXIncomeGrand += dTemp;
		  %>
		  <td  class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp+"",true)%>&nbsp;</td>
		   <%
		  	//dTemp = ((Double)vRetResult.elementAt(i+11)).doubleValue(); 	
			dTemp = (dBasicSalary+dOvertime+dOtherTXIncome) - dMiscAmt;
			dGrossSalaryDept += dTemp;
			dGrossSalaryGrand += dTemp;
		  %>
		  <td  class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp+"",true)%>&nbsp;</td>
		  <%
		  	dTemp = ((Double)vRetResult.elementAt(i+12)).doubleValue();
			dWTaxDept += dTemp;
			dWTaxGrand += dTemp;
		  %>
    	  <td  class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp+"",true)%>&nbsp;</td>
		  <%
		  	dTemp = ((Double)vRetResult.elementAt(i+14)).doubleValue();
			dSSSDept += dTemp;
			dSSSGrand += dTemp;
		  %>
		  <td  class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp+"",true)%>&nbsp;</td>
		  <%
		  	dTemp = ((Double)vRetResult.elementAt(i+13)).doubleValue();
		  	dPHICDept += dTemp;
			dPHICGrand += dTemp;
		  %>
    	  <td  class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp+"",true)%>&nbsp;</td>
		  <%
		  	dTemp = ((Double)vRetResult.elementAt(i+15)).doubleValue();
			dHDMFDept += dTemp;
			dHDMFGrand += dTemp;
		  %>			
		  <td  class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp+"",true)%>&nbsp;</td>
		  <%
		  	dTemp = ((Double)vRetResult.elementAt(i+19)).doubleValue();
			dNTXIncomeDept += dTemp;
			dNTXIncomeGrand += dTemp;
		  %>
		  <td  class="BOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dTemp+"",true)%>&nbsp;</td>
		</tr>

		<%}%>  
		<tr align="right" style="font-weight:bold">
			<td  height="22" class="BOTTOMLEFT" >GRAND TOTAL: &nbsp;&nbsp;</td>
			<td  colspan="3" class="BOTTOM">&nbsp;</td>
			<td  class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dBasicSalaryGrand+"",true)%>&nbsp;</td>
			<td  class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dMiscAmtGrand+"",true)%>&nbsp;</td>
			<td  class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dOvertimeGrand+"",true)%>&nbsp;</td>
			<td  class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTXIncomeGrand+"",true)%>&nbsp;</td>
			<td  class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dGrossSalaryGrand+"",true)%>&nbsp;</td>
			<td  class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dWTaxGrand+"",true)%>&nbsp;</td>
			<td  class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dSSSGrand+"",true)%>&nbsp;</td>
			<td  class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dPHICGrand+"",true)%>&nbsp;</td>
			<td  class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dHDMFGrand+"",true)%>&nbsp;</td>
			<td  class="BOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dNTXIncomeGrand+"",true)%>&nbsp;</td>
  	  	</tr>
	</table>
	<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="searchEmployee">
  <input type="hidden" name="print_pg" value="">
  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>