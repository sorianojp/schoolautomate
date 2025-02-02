<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Sheet/Register</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TD.header {
		font-family:  Verdana, Arial, Geneva, Helvetica, sans-serif;
		font-size: 9px;
    }
 		TD.BOTTOM {
    border-bottom: solid 1px #000000;
 		font-family:  Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;
    }
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function PrintPg(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
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

	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=301&month_of="+strMonth+
							 "&year_of="+strYear+"&is_weekly="+strWeekly+"&onchange=ReloadPage()";

	this.processRequest(strURL);
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, payroll.PReDTRME" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;	
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	
//add security here.
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./payroll_reg_udmc_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Sheet (UDMC)","payroll_reg_udmc.jsp");
								
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
														"PAYROLL","REPORTS",request.getRemoteAddr(),
														"payroll_reg_udmc.jsp");
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
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	
	PayrollSheet RptPSheet = new PayrollSheet(request);
	String strPayrollPeriod  = null;	
	int iFieldCount = 75;// number of fields in the vector..

	double dBasic = 0d;
	double dDaysWorked = 0d;
	double dTemp = 0d;
	double dLineOver = 0d;
	double dLineTotal = 0d;
	double dOtherDed = 0d;	

	Vector vRows = null;
	Vector vEarnCols = null;
	Vector vDedCols = null;
	Vector vEarnDedCols = null;
	Vector vRetResult = null;
	int iIncr = 1;
	int iCols = 0;
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount = 0;

	double dTotalDeductions = 0d;
	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vEarnDed = null;

	Vector vOTDetail = null;
	Vector vSalDetail = null;
	double dOtherEarn = 0d;
	boolean bolShowHeader = true;
	String strSalaryBase = null; 
	
	String strCurColl = null;
	String strNextColl = null;
	String strCurDept = null;
	String strNextDept = null;
		
	vRetResult = RptPSheet.getPSheetItems(dbOP);
	if(vRetResult == null)
		strErrMsg = RptPSheet.getErrMsg();
	else{
		vRows = (Vector)vRetResult.elementAt(0);
		vEarnCols = (Vector)vRetResult.elementAt(1);
		vDedCols = (Vector)vRetResult.elementAt(2);
		vEarnDedCols = (Vector)vRetResult.elementAt(3);		
		
		if(vEarnCols != null && vEarnCols.size() > 0)
			iEarnColCount = vEarnCols.size() - 2;
		 
 		if(vDedCols != null && vDedCols.size() > 0)
			iDedColCount = vDedCols.size() - 1;		
		 
 		if (vEarnDedCols != null && vEarnDedCols.size() > 0)
			iEarnDedCount = vEarnDedCols.size() - 1;
			
		iSearchResult = RptPSheet.getSearchCount();		
	}

 	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);	
%>
<body>
<form name="form_" 	method="post" action="payroll_reg_udmc.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
      PAYROLL: PAYROLL SHEET PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><font size="2" color="#FF0000"><strong>&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td colspan="3"> <select name="month_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>
        (Must be filled up to display salary period information)</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="21%">Salary Period</td>
      <td width="77%" colspan="3"><strong>
			<label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px" onChange="ReloadPage();">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");		
		
		for(int i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
			if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += "Whole Month";
			}else{
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);			
//				strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//					(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			}
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
			strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		%>
          <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%> </option>
          <%}else{%>
          <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%></option>
          <%}//end of if condition.		  
		 }//end of for loop.%>
        </select>
				</label>
        </strong>
        <% 
				if(strHasWeekly.equals("1")){
					strTemp = WI.fillTextValue("is_weekly");
					if(strTemp.compareTo("1") == 0) 
						strTemp = " checked";
					else	
						strTemp = "";
				%>
        <input type="checkbox" name="is_weekly" value="1" <%=strTemp%> onClick="ReloadPage();">
        <font size="1">for weekly </font>
        <%}// check if the company has weekly salary type%>      </td>
    </tr>
<tr>
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <td colspan="3"><select name="pt_ft" onChange="ReloadPage();">
        <option value="" selected>ALL</option>
        <%if (WI.fillTextValue("pt_ft").equals("0")){%>
        <option value="0" selected>Part - time</option>
        <option value="1">Full - time</option>
        <%}else if(WI.fillTextValue("pt_ft").equals("1")){%>
        <option value="0">Part - time</option>
        <option value="1" selected>Full - time</option>
        <%}else{%>
        <option value="0">Part - time</option>
        <option value="1">Full - time</option>
        <%}%>
      </select>
	  </td>
    </tr>		
    <tr>
      <td height="22">&nbsp;</td>
      <td>Employee Category</td>
      <td colspan="3">
	   <select name="employee_category" onChange="ReloadPage();">          
			 <option value="">ALL</option>
			 <%if (WI.fillTextValue("employee_category").equals("0")){%>
          <option value="0" selected>Non-Teaching</option>
					<option value="1">Teaching</option>
				<%} else if (WI.fillTextValue("employee_category").equals("1")){%>
					<option value="0">Non-Teaching</option>
          <option value="1" selected>Teaching</option>
        <%}else{%>
					<option value="0">Non-Teaching</option>
          <option value="1">Teaching</option>
        <%}%>
       </select></td>
    </tr>
    <% 	
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>College</td>
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
				</label>
			</td>
    </tr>
		<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td>Salary base </td>
			<%
				strSalaryBase =  WI.fillTextValue("salary_base");
			%>
      <td colspan="3">
			<select name="salary_base" onChange="ReloadPage();">
        <option value="0">Monthly rate</option>
        <%if (strSalaryBase.equals("1")){%>
        <option value="1" selected>Daily Rate</option>
        <option value="2">Hourly Rate</option>
        <%} else if (strSalaryBase.equals("2")){%>
        <option value="1">Daily Rate</option>
        <option value="2" selected>Hourly Rate</option>
        <%}else{%>
        <option value="1">Daily Rate</option>
        <option value="2">Hourly Rate</option>
        <%}%>
      </select></td>
    </tr>
		-->
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Show option </td>
			<%
				strTemp = WI.fillTextValue("is_resigned");
			%>			
      <td height="10" colspan="3"><select name="is_resigned" onChange="ReloadPage();">
        <option value="">ALL</option>
        <%if (strTemp.equals("1")){%>
        <option value="1" selected>Show only resigned for the period</option>
        <option value="2">Show only with valid status</option>
        <%}else if (strTemp.equals("2")){%>
        <option value="1">Show only resigned for the period</option>
        <option value="2"selected>Show only with valid status</option>
        <%}else{%>
        <option value="1">Show only resigned for the period</option>
        <option value="2">Show only with valid status</option>
        <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr> 
      <td width="3%" height="10">&nbsp;</td>
      <td width="13%" height="10">&nbsp;</td>
      <td height="10" colspan="3"><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
      <font size="1">click to display employee list to print.</font></td>
    </tr>
    <tr>
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
    <% if (vRows != null && vRows.size() > 0 ){%>
		<tr> 
      <td height="10">&nbsp;</td>
 	  
      <td height="10" colspan="4"><div align="right">
        <div align="right"><font size="2">&nbsp;&nbsp;Max number of Employees per 
          page :</font><font>
            <select name="num_rec_page">
              <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(int i = 10; i <=30 ; i++) {
				if ( i == iDefault) {%>
              <option selected value="<%=i%>"><%=i%></option>
              <%}else{%>
              <option value="<%=i%>"><%=i%></option>
              <%}}%>
            </select>
          <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></div>
      </div></td>	   
    </tr>
		<tr>
		  <td height="10">&nbsp;</td>
		  <td height="10" colspan="4" align="right"><font size="2">Font size of header:
          <select name="size_header">
            <option value="9">9 px</option>
            <%
strTemp = request.getParameter("size_header");
if(strTemp == null)
	strTemp = "10";
if(strTemp.compareTo("10") == 0) {%>
            <option value="10" selected>10 px</option>
            <%}else{%>
            <option value="10">10 px</option>
            <%}if(strTemp.compareTo("11") == 0) {%>
            <option value="11" selected>11 px</option>
            <%}else{%>
            <option value="11">11 px</option>
            <%}if(strTemp.compareTo("12") == 0) {%>
            <option value="12" selected>12 px</option>
            <%}else{%>
            <option value="12">12 px</option>
            <%}%>
          </select>
		  </font></td>
	  </tr>
		<tr>
		  <td height="10">&nbsp;</td>
		  <td height="10" colspan="4" align="right"><font size="2">Font size of details:
          <select name="font_size">
            <option value="9">9 px</option>
            <%
strTemp = request.getParameter("font_size");
if(strTemp == null)
	strTemp = "10";
if(strTemp.compareTo("10") == 0) {%>
            <option value="10" selected>10 px</option>
            <%}else{%>
            <option value="10">10 px</option>
            <%}if(strTemp.compareTo("11") == 0) {%>
            <option value="11" selected>11 px</option>
            <%}else{%>
            <option value="11">11 px</option>
            <%}if(strTemp.compareTo("12") == 0) {%>
            <option value="12" selected>12 px</option>
            <%}else{%>
            <option value="12">12 px</option>
            <%}%>
          </select>
		  </font></td>
	  </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Prepared by: </td>
			<%
					strTemp = WI.fillTextValue("prepared_by");		
			%>
      <td width="30%" height="10"><input type="text" name="prepared_by" maxlength="128" size="32" value="<%=strTemp%>"></td>
      <td width="28%" height="10">&nbsp;</td>
      <td width="26%" height="10">&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Verified by: </td>
			<%
				strTemp = WI.fillTextValue("verified_by");			
			%>			
      <td height="10"><input type="text" name="verified_by" maxlength="128" size="32" value="<%=strTemp%>"></td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
		<%}%>
  </table>
  <% if (vRows != null && vRows.size() > 0 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="23"> 
		<%
		int iPageCount = iSearchResult/RptPSheet.defSearchSize;
		if(iSearchResult % RptPSheet.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="SearchEmployee();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
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
        </div>
				<%}%></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="24" colspan="21" align="center"><strong><font color="#0000FF">PAYROLL 
      SHEET FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
    </tr>
    <tr>
      <td height="19" colspan="21">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td width="8%" height="33" align="center" class="header">Eamployee Name </td>
      <td width="5%" align="center" class="header">RATE<br> DaysWork</td>
      <td width="3%" align="center" class="header">SD Hr</td>
      <td width="5%" align="center" class="header">Holiday Day Off</td>
      <td width="2%" align="center" class="header">UT</td>
      <td width="4%" align="center" class="header">Leave Days</td>
      <td width="3%" align="center" class="header">Abs days </td>
			<td width="5%" align="center" class="header">Absence</td>
      <td width="4%" align="center" class="header">Basic</td>
      <td width="5%" align="center" class="header">SD Reg.</td>
      <td width="5%" align="center" class="header">Holiday Day Off</td>
      <td width="4%" align="center" class="header">Leave Pay</td>
      <%for(iCols = 2;iCols < iEarnColCount + 2; iCols ++){%>
      <td width="3%" align="center" class="header"><%=(String)vEarnCols.elementAt(iCols)%></td>			
		<%}%>
		<%for(iCols = 1;iCols < iEarnDedCount + 1; iCols ++){%>
	  <td width="5%" align="center" class="header"><%=(String)vEarnDedCols.elementAt(iCols)%>&nbsp;</td>
		<%}%>
      <td width="4%" align="center" class="header">OTHERS</td>      
      <td width="4%" align="center" class="header">Gross</td>
      <td width="5%" align="center" class="header">SSS PREM<br>Medicare</td>
      <td width="4%" align="center" class="header">WITHTAX</td>
      <td width="4%" align="center" class="header"><br>PagI Prem </td>
      <%			
			for(iCols = 1;iCols <= iDedColCount; iCols +=2){
				strTemp = (String)vDedCols.elementAt(iCols);
			%>				
      <td width="4%" align="center" class="header"><%=strTemp%></td>
			<%}%>
      <td width="5%" align="center" class="header">Others</td>
      <td width="4%" align="center" class="header">ADJ</td>
      <td width="4%" align="center" class="header">NET PAY</td>
    </tr>
    <% if (vRows != null && vRows.size() > 0 ){
      for(int i = 0; i < vRows.size();){
	  %>
	  <%if(bolShowHeader){
		bolShowHeader = false;
	  %>
    <tr>
      <td height="24" colspan="23" valign="bottom">&nbsp;<strong><%=(WI.getStrValue((String)vRows.elementAt(i+62),"Dept : ","","Dept : " + (String)vRows.elementAt(i+63))).toUpperCase()%></strong></td>
    </tr>
	<%}%>
  <%for(; i < vRows.size();){	
	if(i+iFieldCount+1 < vRows.size()){
		if(i == 0){
		strCurColl = WI.getStrValue((String)vRows.elementAt(i+2),"");		
		strCurDept = WI.getStrValue((String)vRows.elementAt(i+3),"");	
		}
		strNextColl = WI.getStrValue((String)vRows.elementAt(i + iFieldCount + 2),"");		
		strNextDept = WI.getStrValue((String)vRows.elementAt(i + iFieldCount + 3),"");		
 		
		if(!(strCurColl).equals(strNextColl) || !(strCurDept).equals(strNextDept)){
			bolShowHeader = true;
		}
	}
  	vEarnings = (Vector)vRows.elementAt(i+53);
	vDeductions = (Vector)vRows.elementAt(i+54);
	vSalDetail = (Vector)vRows.elementAt(i+55); 
	vOTDetail = (Vector)vRows.elementAt(i+56);
	vEarnDed  = (Vector)vRows.elementAt(i+59);
	dLineTotal = 0d;
	dBasic = 0d;
	dDaysWorked = 0d;
	dLineOver = 0d;
	dOtherEarn = 0d;
	dOtherDed = 0d;
		%>	
    <tr>
      <td height="18" valign="bottom" class="BOTTOM"><%=(String)vRows.elementAt(i+60)%><br><%=iIncr%>&nbsp;<strong>
      <%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
							(String)vRows.elementAt(i+6), 9)%></strong></td>
      <%
				//rate per hour
				//strTemp = (String)vRows.elementAt(i + iStart + 2);
				strSalaryBase = "";
				if(vSalDetail != null && vSalDetail.size() > 0)
					strSalaryBase = (String)vSalDetail.elementAt(6); 			
				if(strSalaryBase.equals("0")){
					strTemp = (String)vSalDetail.elementAt(7); 			
					dLineTotal = Double.parseDouble((String)vRows.elementAt(i + 7));
					strTemp2 = "";
				}else if(strSalaryBase.equals("1")){
					strTemp = (String)vSalDetail.elementAt(2); 					
					dDaysWorked = Double.parseDouble(strTemp);
					strTemp2 = (String)vRows.elementAt(i + 20); // days worked					
					dTemp = Double.parseDouble(strTemp2);
					dLineTotal = dDaysWorked * dTemp;
				}else if(strSalaryBase.equals("2")){
					strTemp = (String)vSalDetail.elementAt(5); 								
					dDaysWorked = Double.parseDouble(strTemp);
					strTemp2 = (String)vRows.elementAt(i + 8); // hours worked			
					dTemp = Double.parseDouble(strTemp2);
					dLineTotal = dDaysWorked * dTemp;					
				}else{
					strTemp = "";
					strTemp2 = "";
				}
			%>
      <td align="right" valign="bottom" class="BOTTOM"><%=strTemp%>&nbsp;<br>
      <%=WI.getStrValue(strTemp2,"")%>&nbsp;</td>
      <%
		// regular ot hours
		strTemp = null;
		dTemp = 0d;
		if(vOTDetail != null && vOTDetail.size() > 0){
			strTemp = (String)vOTDetail.elementAt(0);
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
		}
		if(dTemp == 0d)
			strTemp = "--";	
	  %>   
	  <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td> 	
	<%
		// rest day OT hour
		strTemp = null;
		dTemp = 0d;
		if(vOTDetail != null && vOTDetail.size() > 0){
			strTemp = (String)vOTDetail.elementAt(2);
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
		}
		if(dTemp == 0d)
			strTemp = "--";	
	%>	  		
      <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
		<%
			// late_under_amt
			strTemp = (String)vRows.elementAt(i + 48); 			
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal -= dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);
			if(dTemp == 0d)
				strTemp = "&nbsp;";
			%> 			
      <td align="right" valign="bottom" class="BOTTOM"><%=strTemp%>&nbsp;</td>
	   <%
		// leave days
		strTemp = (String)vRows.elementAt(i + 11);  	
		dTemp = Double.parseDouble(strTemp);
		strTemp = (String)vRows.elementAt(i + 12);  	
		dTemp += Double.parseDouble(strTemp);
		strTemp = Double.toString(dTemp);
		if(dTemp == 0d)
			strTemp = "";
	  %>   			
      <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
		<%
			// number of days absent
 			strTemp = (String)vRows.elementAt(i + 61); 			
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
			if(dTemp == 0d)
				strTemp = "";
		%>			  
      <td align="right" valign="bottom" class="BOTTOM"><%=strTemp%>&nbsp;</td>
		<%
			dTemp = 0d;
			// AWOL // i dont know if theres an awol anyway
			strTemp = (String)vRows.elementAt(i + 47); 			
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

			// leave_deduction_amt
			strTemp = (String)vRows.elementAt(i + 33); 			
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

			// faculty absences
			strTemp = (String)vRows.elementAt(i + 49); 			
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));				
			dLineTotal -= dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);
			if(dTemp == 0d)
				strTemp = "--";
		%>			
      <td align="right" valign="bottom" class="BOTTOM"><%=strTemp%>&nbsp;</td>
      <%
				// add the faculty salary
				dLineTotal += Double.parseDouble(WI.getStrValue((String)vRows.elementAt(i + 30),"0"));
			%>		     
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
		
		  <%
			// regular OT amount
			strTemp = null;
			dTemp = 0d;
			if(vOTDetail != null && vOTDetail.size() > 0){
				strTemp = (String)vOTDetail.elementAt(1);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
			}
			dLineOver += dTemp;
			if(dTemp == 0d)
				strTemp = "--";
			%> 
      <td align="right" valign="bottom" class="BOTTOM">&nbsp;<%=strTemp%>&nbsp;</td>
		<%
			// holiday pay amount
			strTemp = (String)vRows.elementAt(i + 26);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "&nbsp;";

			// rest day OT amount
			strTemp2 = null;
			dTemp = 0d;
			if(vOTDetail != null && vOTDetail.size() > 0){
				strTemp2 = (String)vOTDetail.elementAt(3);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp2,"0"));												
			}
			dLineOver += dTemp;
			if(dTemp == 0d)
				strTemp2 = "--";			
			%>  	
      <td align="right" valign="bottom" class="BOTTOM"><%=strTemp%>&nbsp;<br>
      <%=strTemp2%>&nbsp;</td>
		<%
			// leave deduction amt
			strTemp = (String)vRows.elementAt(i + 33);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "&nbsp;";
			%>  				
      <td align="right" valign="bottom" class="BOTTOM"><%=strTemp%>&nbsp;</td>
      <%
			for(iCols = 2;iCols < iEarnColCount + 2; iCols++){
			strTemp = (String)vEarnings.elementAt(iCols);			
			dTemp = Double.parseDouble(strTemp);
			dLineTotal += dTemp;
			if(strTemp.equals("0"))
				strTemp = "";
			%>
      <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
			<%}%>	
			<%for(iCols = 1;iCols < iEarnDedCount + 1; iCols ++){
				strTemp = (String)vEarnDed.elementAt(iCols);			
				dTemp = Double.parseDouble(strTemp);
				dLineTotal -= dTemp;
				if(strTemp.equals("0"))
					strTemp = "";			
			%>							
	  <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
			<%}%> 
      <%
				// overload amount
				strTemp = (String)vRows.elementAt(i + 22);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));	
				dOtherEarn += dTemp;

				// night differential amount
				strTemp = (String)vRows.elementAt(i + 24);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dOtherEarn += dTemp;
				
				// COLA
				strTemp = (String)vRows.elementAt(i + 25);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dOtherEarn += dTemp;


			if(vEarnings != null){
				// subject allowances 
				strTemp = (String)vEarnings.elementAt(0); 
				if (strTemp.length() > 0){
					dOtherEarn += Double.parseDouble(strTemp);
				}
				// ungrouped earnings.
				strTemp = (String)vEarnings.elementAt(1); 
				if (strTemp.length() > 0){
					dOtherEarn += Double.parseDouble(strTemp);
				}				
			}			
					
		// addl_payment_amt 
		if (vRows.elementAt(i+27) != null){	
			strTemp = (String)vRows.elementAt(i+27); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
		}

		// Adhoc Allowances
		if (vRows.elementAt(i+28) != null){	
			strTemp = (String)vRows.elementAt(i+28); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
		}

		// addl_resp_amt
		if (vRows.elementAt(i+29) != null){	
			strTemp = (String)vRows.elementAt(i+29); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
		}
		
		// substitute salary
		if (vRows.elementAt(i+38) != null){	
			strTemp = (String)vRows.elementAt(i+38); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
		}						
		dLineTotal += dOtherEarn;
		strTemp = Double.toString(dOtherEarn);
	  %>			
      <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>				
      <%
				dLineTotal += dLineOver;
			%>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
      <%
				// sss contribution
				strTemp = (String)vRows.elementAt(i + 39);			
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dLineTotal -= dTemp;													
				strTemp = CommonUtil.formatFloat(strTemp,true);
				if(dTemp == 0d)
					strTemp = "--";
					
				// philhealth
				strTemp2 = (String)vRows.elementAt(i + 40);				
				dTemp = Double.parseDouble(WI.getStrValue(strTemp2,"0"));	
				dLineTotal -= dTemp;											
				strTemp2 = CommonUtil.formatFloat(strTemp2,true);
				if(dTemp == 0d)
					strTemp2 = "--";
			%>				
      <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"")%>&nbsp;<br>
      <%=WI.getStrValue(strTemp2,"")%>&nbsp;</td>
      <%
				// tax withheld
				strTemp = (String)vRows.elementAt(i + 46);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));				
				dLineTotal -= dTemp;
				strTemp = CommonUtil.formatFloat(strTemp,true);														
				if(dTemp == 0d)
					strTemp = "--";
			%> 			
      <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <%
				// pag ibig
				strTemp = (String)vRows.elementAt(i +41);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dLineTotal -= dTemp;					
				strTemp = CommonUtil.formatFloat(strTemp,true);
				if(dTemp == 0d)
					strTemp = "--";
			%>				
      <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <%for(iCols = 1;iCols <= iDedColCount/2; iCols++){
				strTemp = (String)vDeductions.elementAt(iCols);
				dTemp = Double.parseDouble(strTemp);
				dLineTotal -= dTemp;
				if(dTemp == 0d)
					strTemp = "";			
			%> 			
      <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
			<%}%>
      <%
			// this is the other ungrouped deductions
			strTemp = (String)vDeductions.elementAt(0);
			dTemp = Double.parseDouble(strTemp);
			dOtherDed += dTemp;
			
			// misc_deduction
		if (vRows.elementAt(i + 45) != null){	
			strTemp = (String)vRows.elementAt(i + 45); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){ 
				dOtherDed += Double.parseDouble(strTemp);				
			}			
		}			
	  %> 
      <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(CommonUtil.formatFloat(dOtherDed,true),"&nbsp;")%>&nbsp;</td>
      <%
				// adjustment amount
				strTemp = (String)vRows.elementAt(i + 51); 	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp ,true);
				dLineTotal += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>				
	  <td align="right" valign="bottom" class="BOTTOM"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%>&nbsp;</td>
			<%
				dLineTotal -= dOtherDed;
			%>
      <td align="right" valign="bottom" class="BOTTOM"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
  <% 
     i = i + iFieldCount;  	
	 iIncr++;
	 if(i < vRows.size()){
		 strCurColl = WI.getStrValue((String)vRows.elementAt(i+2),"");
		 strCurDept = WI.getStrValue((String)vRows.elementAt(i+3),"");
	 }	 
  	 
	if(bolShowHeader){
		break;
	}

  %>
     <%}//end for loop %>
 
	<%
	 }// end outer for loop... for office name
	} // end if %>
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