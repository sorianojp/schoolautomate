<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary by Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.NoBorder {
	font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }	
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
	TD.thinborderBOTTOMTOP {
    border-bottom: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 11px;
    }

	TD.thinborderBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
	TD.headerBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
	font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
	font-size: 8px;
    }
    TD.headerBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 8px;
    }    
	TD.thinborder {
	border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;	
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
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
	document.form_.print_pg.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
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
							 "&year_of="+strYear+"&is_weekly="+strWeekly;

	this.processRequest(strURL);
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, payroll.PReDTRME" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	
//add security here.


if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./psheet_summary_udmc_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Sheet Summary(UDMC)","psheet_summary_udmc.jsp");
								
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
														"psheet_summary_udmc.jsp");
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
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	
	PayrollSheet RptPSheet = new PayrollSheet(request);
	String strPayrollPeriod  = null;
	String strTemp2 = null;
//	int iStart = 29; // this is where the null fields start
	int iFieldCount =31;

	double dBasic = 0d;
	double dTemp = 0d;
	double dTotalSalary = 0d;			
	double dTotalBasic = 0d;
	double dTotalAbsences = 0d;
	double dTotalIncentive = 0d;
	double dTotalHonorarium = 0d;
	double dTotalRice = 0d;
	double dTotalOT = 0d;
	double dTotalCola = 0d;
	double dTotalSubsist = 0d;	
	double dTotalGross = 0d;
	double dTotalPhealth = 0d;
	double dTotHdmfLoan = 0d;
	double dTotalTax = 0d;
	double dTotalSSS = 0d;
	double dTotSSSLoan = 0d;
	double dTotalHdmf = 0d;		
	double dTotalNetBasic = 0d;
	double dTotalNetPay = 0d;
	double dLineTotal = 0d;
	double dTotalOtherDed = 0d;
	double dTotalOtherLoan = 0d;
	double dTotalSubTeach = 0d;
	double dTotalOtherEarn = 0d;
		
	Vector vRows = null;
	Vector vEarnCols = null;
	Vector vDedCols = null;
	Vector vEarnDedCols = null;

	Vector vRetResult = null;
	int iCols = 0;
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount = 0;

	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vEarnDed = null;
	Vector vOTDetail = null;
	Vector vSalDetail = null;
	double dOtherEarn = 0d;
	double dOtherDed  = 0d;
		
	vRetResult = RptPSheet.generatePSheetSummary(dbOP);
	if(vRetResult == null)
		strErrMsg = RptPSheet.getErrMsg();
	else{
		vRows = (Vector)vRetResult.elementAt(0);
		vEarnCols = (Vector)vRetResult.elementAt(1);
		vDedCols = (Vector)vRetResult.elementAt(2);		
		vEarnDedCols = (Vector)vRetResult.elementAt(3);			

		if(vEarnCols != null && vEarnCols.size() > 0)
			iEarnColCount = vEarnCols.size();

		if(vDedCols != null && vDedCols.size() > 0)
			iDedColCount = vDedCols.size();		

		if (vEarnDedCols != null && vEarnDedCols.size() > 0)
			iEarnDedCount = vEarnDedCols.size();
			
		iSearchResult = RptPSheet.getSearchCount();		
	}

 	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<body>
<form name="form_" 	method="post" action="psheet_summary_udmc.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
      PAYROLL: PAYROLL SHEET PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"> <font size="2" color="#FF0000"><strong>&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></font></td>
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
        <select name="sal_period_index" style="font-weight:bold;font-size:11px">
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
      <td>Employee Category</td>
      <td colspan="3">
	   <select name="employee_category" onChange="ReloadPage();">          
          <option value="0">Non-Teaching</option>
        <%if (WI.fillTextValue("employee_category").equals("1")){%>
          <option value="1" selected>Teaching</option>
        <%}else{%>
          <option value="1">Teaching</option>
        <%}%>
       </select></td>
    </tr>
    <% 	
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Salary base </td>
      <td height="10" colspan="3"><select name="salary_base" onChange="ReloadPage();">
        <option value="0">Monthly rate</option>
        <%if (WI.fillTextValue("salary_base").equals("1")){%>
        <option value="1" selected>Daily Rate</option>
        <option value="2">Hourly Rate</option>
        <%} else if (WI.fillTextValue("salary_base").equals("2")){%>
        <option value="1">Daily Rate</option>
        <option value="2" selected>Hourly Rate</option>
        <%}else{%>
        <option value="1">Daily Rate</option>
        <option value="2">Hourly Rate</option>
        <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td height="29"><select name="sort_by1">
          <option value="">N/A</option>
          <%if(WI.fillTextValue("sort_by1").equals("ID_NUMBER"))		    
			{%>
    	      <option selected value="ID_NUMBER">Employee ID</option>
          <%}else{%>
	          <option value="ID_NUMBER">Employee ID</option>
          <%}%>
          <%if(WI.fillTextValue("sort_by1").equals("LNAME"))
		    {%>
        	  <option selected value="LNAME">Lastname</option>
          <%}else{%>
    	      <option value="LNAME">Lastname</option>
          <%}%>
          <%if(WI.fillTextValue("sort_by1").equals("FNAME"))
		   {%>
         	 <option selected value="FNAME">Firstname</option>
          <%}else{%>
	          <option value="FNAME">Firstname</option>
          <%}%>
        </select></td>

      <td height="29"><select name="sort_by2">
          <option value="">N/A</option>
          <%if(WI.fillTextValue("sort_by2").equals("ID_NUMBER"))		    
			{%>
    	      <option selected value="ID_NUMBER">Employee ID</option>
          <%}else{%>
	          <option value="ID_NUMBER">Employee ID</option>
          <%}%>
          <%if(WI.fillTextValue("sort_by2").equals("LNAME"))
		    {%>
        	  <option selected value="LNAME">Lastname</option>
          <%}else{%>
    	      <option value="LNAME">Lastname</option>
          <%}%>
          <%if(WI.fillTextValue("sort_by2").equals("FNAME"))
		   {%>
         	 <option selected value="FNAME">Firstname</option>
          <%}else{%>
	          <option value="FNAME">Firstname</option>
          <%}%>
        </select></td>

      <td height="29"><select name="sort_by3">
          <option value="">N/A</option>
          <%if(WI.fillTextValue("sort_by3").equals("ID_NUMBER"))		    
			{%>
    	      <option selected value="ID_NUMBER">Employee ID</option>
          <%}else{%>
	          <option value="ID_NUMBER">Employee ID</option>
          <%}%>
          <%if(WI.fillTextValue("sort_by3").equals("LNAME"))
		    {%>
        	  <option selected value="LNAME">Lastname</option>
          <%}else{%>
    	      <option value="LNAME">Lastname</option>
          <%}%>
          <%if(WI.fillTextValue("sort_by3").equals("FNAME"))
		   {%>
         	 <option selected value="FNAME">Firstname</option>
          <%}else{%>
	          <option value="FNAME">Firstname</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td width="11%" height="15">&nbsp;</td>
      <td><select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
	if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3"><input name="image" type="image" onClick="ReloadPage()" src="../../../../images/form_proceed.gif"> 
        <font size="1">click to display employee list to print.</font></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
 	  <% if (vRows != null && vRows.size() > 0 ){%>
      <td height="10" colspan="4"><div align="right"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0"></a>
          <font size="1">click to print</font></div></td>
	   <%}%>
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
  </table>
  <% if (vRows != null && vRows.size() > 0 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="23"> <%
		int iPageCount = iSearchResult/RptPSheet.defSearchSize;
		if(iSearchResult % RptPSheet.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="ReloadPage();">
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
          <%}%>
        </div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="16"><div align="center"><strong><font color="#0000FF">PAYROLL 
          SHEET FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></div></td>
    </tr>
    
    <tr>
      <td width="8%" height="33" align="center" class="thinborderBOTTOM">NightDuty</td>
      <td width="5%" align="center" class="thinborderBOTTOM">Regular</td>
      <td width="7%" align="center" class="thinborderBOTTOM">OT pay </td>
      <td width="7%" align="center" class="thinborderBOTTOM">Adjustment</td> 
			<%for(iCols = 2;iCols < iEarnColCount; iCols ++){%>
      <td width="7%" height="33" align="center" class="thinborderBOTTOM"><%=(String)vEarnCols.elementAt(iCols)%></td>
			<%}%>
      <td width="7%" height="33" align="center" class="thinborderBOTTOM">Other Inc </td>
			<%for(iCols = 1;iCols < iEarnDedCount; iCols ++){%>			
      <td width="9%" align="center" class="thinborderBOTTOM"><%=(String)vEarnDedCols.elementAt(iCols)%>&nbsp;</td>
			<%}%>
      <td width="9%" align="center" class="thinborderBOTTOM">Earn Ded</td>
      <td width="9%" align="center" class="thinborderBOTTOM">Gross Pay </td>
      <td width="8%" align="center" class="thinborderBOTTOM">SSS Prem </td>
      <td width="7%" align="center" class="thinborderBOTTOM">Medicare</td>
      <td width="8%" align="center" class="thinborderBOTTOM">W/tax</td>
      <td width="8%" align="center" class="thinborderBOTTOM">Pag Prem </td>
      <%			
			for(iCols = 1;iCols < iDedColCount; iCols ++){
				strTemp = (String)vDedCols.elementAt(iCols);
			%>						
      <td align="center" class="thinborderBOTTOM"><%=strTemp%></td>
			<%}%>
      <td width="7%" align="center" class="thinborderBOTTOM">Other deds </td>
      <td width="5%" align="center" class="thinborderBOTTOM">Net pay </td>
    </tr>
    <% 
	if (vRows != null && vRows.size() > 0 ){
      for(int i = 0; i < vRows.size(); i += iFieldCount){
	  dLineTotal = 0d;
	  dBasic = 0d;
		dOtherDed = 0d;
		dOtherEarn = 0d;	
		vEarnings = (Vector)vRows.elementAt(i+28);
		vDeductions = (Vector)vRows.elementAt(i+29);
		vEarnDed = (Vector)vRows.elementAt(i+30);
	%>
    <tr>
			<%
				strTemp = WI.getStrValue((String)vRows.elementAt(i+2),(String)vRows.elementAt(i+3));  	
				strTemp = WI.getStrValue(strTemp,"No Office");
			%>
      <td height="18" colspan="16" class="NoBorder">&nbsp;<strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
		<%
			// Night diff
			strTemp = (String)vRows.elementAt(i + 4);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>
      <td height="21" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
		<%
			// period rate
			strTemp = (String)vRows.elementAt(i + 5);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>			
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
		<%
			// OT Amount
			strTemp = (String)vRows.elementAt(i + 6);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>			
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
		<%
			// Adjustment
			strTemp = (String)vRows.elementAt(i + 7);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = "";
			%>			
			<%for(iCols = 2;iCols < iEarnColCount; iCols++){
				strTemp = (String)vEarnings.elementAt(iCols);			
				dTemp = Double.parseDouble(strTemp);
				dLineTotal += dTemp;				
				if(dTemp == 0d)
					strTemp = "";			
			%>  
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%}%>
		<%
			dTemp = 0d;
			if(vEarnings != null){
				// subject allowances 
				strTemp = (String)vEarnings.elementAt(0); 
				if (strTemp.length() > 0){
					dTemp = Double.parseDouble(strTemp);
				}
				// ungrouped earnings.
				strTemp = (String)vEarnings.elementAt(1); 
				if (strTemp.length() > 0){
					dTemp += Double.parseDouble(strTemp);
				}				
			}	
			// addl_payment_amt
			strTemp = (String)vRows.elementAt(i + 8);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// adhoc_bonus
			strTemp = (String)vRows.elementAt(i + 9);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// holiday_pay_amt
			strTemp = (String)vRows.elementAt(i + 10);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// addl_resp_amt
			strTemp = (String)vRows.elementAt(i + 11);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// cola_amt
			strTemp = (String)vRows.elementAt(i + 12);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// faculty_salary
			strTemp = (String)vRows.elementAt(i + 13);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// fac_allowance
			strTemp = (String)vRows.elementAt(i + 14);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// tax_refund
			strTemp = (String)vRows.elementAt(i + 15);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// honorarium
			strTemp = (String)vRows.elementAt(i + 16);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// substitute_sal
			strTemp = (String)vRows.elementAt(i + 17);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// overload_amt
			strTemp = (String)vRows.elementAt(i + 18);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%for(iCols = 1;iCols < iEarnDedCount; iCols ++){
				strTemp = (String)vEarnDed.elementAt(iCols);			
				dTemp = Double.parseDouble(strTemp);
				dLineTotal -= dTemp;
				if(strTemp.equals("0"))
					strTemp = "";			
			%>				
		  <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%}%>
		  <%
			dTemp = 0d;
			if(vEarnDed != null){
				// subject allowances 
				strTemp = (String)vEarnDed.elementAt(0); 
				if (strTemp.length() > 0){
					dTemp = Double.parseDouble(strTemp);
				}
			}					
			// leave_deduction_amt
			strTemp = (String)vRows.elementAt(i + 24);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// awol_amt
			strTemp = (String)vRows.elementAt(i + 26);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// late_under_amt
			strTemp = (String)vRows.elementAt(i + 27);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			dLineTotal += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>			
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
      <td align="right" valign="top" class="NoBorder"><%=CommonUtil.formatFloat(dLineTotal,2)%>&nbsp;</td>
		<%
			// sss_amt
			strTemp = (String)vRows.elementAt(i + 19);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal -= dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
			// phealth
			strTemp = (String)vRows.elementAt(i + 20);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal -= dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
		<%
			// tax
			strTemp = (String)vRows.elementAt(i + 21);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal -= dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
		<%
			// pag ibig
			strTemp = (String)vRows.elementAt(i + 22);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal -= dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>
      <td align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%for(iCols = 1;iCols < iDedColCount; iCols++){
				strTemp = (String)vDeductions.elementAt(iCols);
				dTemp = Double.parseDouble(strTemp);
				dLineTotal -= dTemp;
				if(dTemp == 0d)
					strTemp = "";			
			%>  				
      <td width="7%" align="right" valign="top" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%}%>
		<%
			// gsis_ps
			strTemp = (String)vRows.elementAt(i + 23);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			// misc_deduction
			strTemp = (String)vRows.elementAt(i + 25);  	
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));		

			dLineTotal -= dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>			
			<td align="right" valign="top" class="NoBorder"><%=strTemp%></td>			
      <td align="right" valign="top" class="NoBorder"><%=CommonUtil.formatFloat(dLineTotal,2)%>&nbsp;</td>
    </tr>
    <%}//end for loop
	} // end if %>
    <tr> 
      <td height="20">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
			<%for(iCols = 2;iCols < iEarnColCount; iCols ++){%>
      <td align="right" class="thinborderTOP">&nbsp;</td>
			<%}%>
      <td align="right" class="thinborderTOP">&nbsp;</td>
			<%for(iCols = 1;iCols < iEarnDedCount; iCols++){%> 
      <td align="right" class="thinborderTOP">&nbsp;</td>
			<%}%>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <%for(iCols = 1;iCols < iDedColCount; iCols++){
			%> 			
      <td align="right" class="thinborderTOP">&nbsp;</td>
			<%}%>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
    </tr>
  </table>  
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">  
	<input type="hidden" name="is_for_sheet" value="0">  	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>