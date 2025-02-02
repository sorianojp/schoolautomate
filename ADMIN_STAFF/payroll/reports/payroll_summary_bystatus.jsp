<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PReDTRME" %>
<%
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	boolean bolHasConfidential = false;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary For Bank</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TD.noBorder {
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
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
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function ViewRecords(){
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
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
</script>
<body>
<form name="form_" 	method="post" action="./payroll_summary_bystatus.jsp">
<%  WebInterface WI = new WebInterface(request);

if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./payroll_summary_bystatus_print.jsp" />
<% return;}
	
	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	int i = 0;

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
								"Admin/staff-Payroll-REPORTS-Payroll Summary by status","payroll_summary_bystatus.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");
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

	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	
	Vector vRetResult = null;
	Vector vRetLoans  = null;
	Vector vEarnings  = null;
	Vector vDeductions  = null;
	Vector vEarnHeadings  = null;
	
	ReportPayroll RptPay = new ReportPayroll(request);
	String strPayrollPeriod  = null;
	
	double dAdjustment     = 0d;
	double dPeriodRate     = 0d;
	double dGrossPay       = 0d;
	double dOtherDeduction = 0d;
	double dTotalDeduction = 0d;
	double dNetPay         = 0d;
	double dTemp           = 0d;
	/// USE THIS TO EASILY CONTROL THE NUMBER OF ROWS TO display for deductions.
	int iTotRows = 3;
	String strPTFT = WI.getStrValue(WI.fillTextValue("pt_ft"),"3");
	String strCategory = WI.getStrValue(WI.fillTextValue("employee_category"),"4");
	String[] astrPTFT = {"Part - time","Full - time"};
	String[] astrCategory = {"Non-Teaching","Teaching","Non-Teaching w/ Teaching Load"};
	String strTemp2 = null;
	int iStringLen = 15;
	
	if (WI.fillTextValue("searchEmployee").length() > 0) {
	vRetResult = RptPay.searchByStatusExt(dbOP);
		if(vRetResult == null){
			strErrMsg = RptPay.getErrMsg();
		}else{
			iSearchResult = RptPay.getSearchCount();
		}
	}
 	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);	
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
        PAYROLL: PAYROLL SUMMARY (BY STATUS) PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
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
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%">Salary Period</td>
      <td width="77%" colspan="3"><strong>
			<label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px" onChange="ReloadPage();">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");		
		
		for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
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
      <td height="10">&nbsp;</td>
      <td height="10">Position</td>
      <td height="10" colspan="3"><select name="emp_type_index" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_type_index"), false)%> </select> </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee Status</td>
      <td height="10" colspan="3">
        <select name="pt_ft" onChange="ReloadPage();">
          <option value="">ALL</option>
		  <%for(i = 0; i < 2; i++){
			  if(Integer.parseInt(strPTFT) == i)
				  strTemp = "selected";
			  else
				  strTemp = "";
		  %>
          <option value="<%=i%>" <%=strTemp%>><%=astrPTFT[i]%></option>
          <%}%>
        </select></td>
    </tr>
		<%if(bolIsSchool){%>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee Category</td>
      <td height="10" colspan="3"> 
        <select name="employee_category" onChange="ReloadPage();">
		<option value="">ALL</option>
          <%for(i = 0;i<3;i++){
			  if(Integer.parseInt(strCategory) == i)
				  strTemp = "selected";
			  else
				  strTemp = "";
		  %>
          <option value="<%=i%>" <%=strTemp%>><%=astrCategory[i]%></option>
          <%}%>
        </select></td>
    </tr>
		<%}%>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee Tenure</td>
      <td height="10" colspan="3"><select name="tenure"  onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",WI.fillTextValue("tenure"), false)%> </select></td>
    </tr>
    
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
      <td height="10" colspan="3"><select name="c_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Department/Office</td>
      <td height="10" colspan="3"><select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select></td>
    </tr>
		<%if(bolHasConfidential){%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Process Option</td>
			<%
			String strAuthID = (String) request.getSession(false).getAttribute("userIndex");
			if(strAuthID == null || strAuthID.length() == 0)
				strAuthID = "0";				
			%>		
      <td height="10" colspan="3"><select name="group_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("group_index","group_name"," from pr_preload_group " +
													" where exists(select user_index from pr_group_proc " +
													" 	where pr_preload_group.group_index = pr_group_proc.group_index " +
													" 	and user_index = " + strAuthID + ") order by group_name", WI.fillTextValue("group_index"), false)%>
      </select></td>
    </tr>
		<%}%>
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
      <td height="10" colspan="3">
        <font size="1">
        <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ViewRecords();">
      </font> </td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1" color="#000000"></td>
    </tr>
  </table>
  <% if (vRetResult != null && vRetResult.size() > 1 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="88%" height="24" align="center"><strong><font color="#0000FF">PAYROLL 
      DATE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
    </tr>
        <%		
		int iPageCount = iSearchResult/RptPay.defSearchSize;		
		if(iSearchResult % RptPay.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>
    <tr> 
      <td><div align="right">Jump To page: 
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
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="18%"><div align="center"><font size="1"><strong>ACCOUNT # / EMPLOYEE 
      NAME</strong></font></div></td>
      <td width="65%">&nbsp;</td>
      <td width="8%" align="center"><font size="1"><strong>TOTAL </strong></font></td>
      <td width="7%" align="center"><font size="1"><strong>NET PAY</strong></font></td>
    </tr>
    <% int iCount = 0;
		int iRow = 0;
		int iColumn = 0;
		int iColCount = 0;
	if (vRetResult != null && vRetResult.size() > 0){
		// Major update done on Dec. 17, 2007
	  for(i = 0,iCount=1; i < vRetResult.size(); i += 37,++iCount){
		vRetLoans = (Vector) vRetResult.elementAt(i+33);
		vEarnings = (Vector) vRetResult.elementAt(i+34);
		vEarnHeadings= (Vector) vRetResult.elementAt(i+35);
		vDeductions = (Vector) vRetResult.elementAt(i+36);
		
		dGrossPay = 0d;
		dTotalDeduction = 0d;
				
		//vFacultySalary = (Vector) vRetResult.elementAt(i+32);
		iColCount = 0;
	  %>
    <tr> 
      <td rowspan="2" valign="top" class="noBorder"><div align="right"><%=iCount%>&nbsp;</div></td>
      <td height="26" rowspan="2" valign="top" class="noBorder"> &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1)," ")%><br> &nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+2)), (String)vRetResult.elementAt(i+3),
							((String)vRetResult.elementAt(i+4)), 4)%><br> &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+32)," ")%> </td>
      <td rowspan="2" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr valign="top">
          <td width="15%" height="15" class="noBorder">Salary</td>
          <%  strTemp = CommonUtil.formatFloat(((String)vRetResult.elementAt(i+8)),true);
							if(!((String)vRetResult.elementAt(i+28)).equals("1")){				
								dGrossPay += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
							}
						%>
          <td width="10%" align="right" class="noBorder"> <%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td><%
					for(iColumn = 0; iColumn < vEarnHeadings.size(); iColumn+=2){
							strTemp = (String)vEarnHeadings.elementAt(iColumn);
					  if (strTemp.length() > iStringLen){							
							strTemp = strTemp.substring(0,iStringLen);
					  }							
						%>
          <td width="15%" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
          <%
							strTemp = (String)vEarnHeadings.elementAt(iColumn+1);
							dGrossPay += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
						%>
          <td width="10%" align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          <%
						iColCount++;
						if(iColCount==3)
								break;
					}%>
          <%// these are just fillers.. para fili maguba ang table					
					for(; iColCount < 3; iColCount++){					
					%>
          <td width="15%" class="noBorder">&nbsp;</td>
          <td width="10%" class="noBorder">&nbsp;</td>
          <%}%>
        </tr>
        <%if(vEarnHeadings != null && vEarnHeadings.size() > 6){										
					iColumn = 6;
					for(;iColumn < vEarnHeadings.size();){
					iColCount = 0;
				%>				
        <tr valign="top">
          <%for(; iColumn < vEarnHeadings.size(); iColumn+=2,iColCount++){%>
          <%
							strTemp = (String)vEarnHeadings.elementAt(iColumn);
					  if (strTemp.length() > iStringLen){							
							strTemp = strTemp.substring(0,iStringLen);
					  }								
						%>
          <td class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
          <%
							strTemp = (String)vEarnHeadings.elementAt(iColumn+1);
							dGrossPay += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
						%>
          <td  align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          <%if(iColCount ==3)
								break;
						}%>
          <%// fillers po ito for earnings... do not touch
					for(; iColCount < 3; iColCount++){%>
          <td class="noBorder">&nbsp;</td>
          <td class="noBorder">&nbsp;</td>
          <%}%>
        </tr>
        <%} //for(;iColumn < vEarnHeadings.size();)
				}// vEarnHeadings != null && vEarnHeadings.size() > 6%>
        <%if(vDeductions != null && vDeductions.size() > 0){
					iColumn = 0;
					for(; iColumn < vDeductions.size();){
						iColCount = 0;
					%>
        <tr valign="top">
          <%
						for(; iColumn < vDeductions.size(); iColumn+=2,iColCount++){
							iColCount = 0;
							strTemp = (String)vDeductions.elementAt(iColumn);
						%>
          <td class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
          <%
							strTemp = (String)vDeductions.elementAt(iColumn + 1);
							dTotalDeduction += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
						%>
          <td align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          <%
						if(iColCount==3)
								break;
					} // for loop%>
          <% // fillers sa deductions
					for(; iColCount < 3; iColCount++){%>
          <td class="noBorder" width="15%" >&nbsp;</td>
          <td class="noBorder" width="10%" >&nbsp;</td>
          <%}// complete the columns%>
        </tr>
        <%}// outer for loop
				 } // if(vDeductions != null && vDeductions.size() > 0%>
        <%if(vRetLoans != null && vRetLoans.size() > 0){
					iColumn = 0;
					for(; iColumn < vRetLoans.size();){
						iColCount = 0;
					%>
        <tr valign="top">
          <%
						for(; iColumn < vRetLoans.size(); iColumn+=3,iColCount++){
							iColCount = 0;
				      strTemp = (String) vRetLoans.elementAt(iColumn);
							strTemp = ConversionTable.replaceString(strTemp," ","");
								if (strTemp.length() > iStringLen - 4 && (vRetLoans.elementAt(iColumn+2) != null) ){							
								strTemp = strTemp.substring(0,iStringLen -4);
								}
							strTemp += WI.getStrValue((String)vRetLoans.elementAt(iColumn+2),"&nbsp;");												
						%>
          <td class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
          <%
							strTemp = (String)vRetLoans.elementAt(iColumn + 1);
							dTotalDeduction += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
						%>
          <td align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          <%
						if(iColCount==3)
							break;
						} // for loop%>
          <% // fillers sa Loans
					for(; iColCount < 3; iColCount++){%>
          <td class="noBorder">&nbsp;</td>
          <td class="noBorder">&nbsp;</td>
          <%}// complete the columns%>
        </tr>
        <%}// outer for loop
				 } // if(vDeductions != null && vDeductions.size() > 0%>
      </table>
        <%if(((String)vRetResult.elementAt(i+28)).equals("1")){%> 
		<font color="#FF0000"><strong>&nbsp;Employee 
      on leave</strong></font> <%}%></td>
      <td valign="top" class="noBorder"><div align="right"> <%=WI.getStrValue(CommonUtil.formatFloat(dGrossPay,true),"")%>&nbsp;</div></td>
      <%
					strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+5),true);
					dAdjustment = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
			
	  	dNetPay = dGrossPay - dTotalDeduction + dAdjustment;
		  %>
      <td rowspan="2" align="right" valign="bottom" class="noBorder"><br>
        <%=WI.getStrValue(CommonUtil.formatFloat(dNetPay,true)," ")%>&nbsp;</td>
    </tr>
    <tr>
      <td height="26" align="right" valign="top" class="noBorder"><%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"")%>&nbsp;<br>
        <%
					strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+5),true);
					if(dAdjustment == 0d)
						strTemp = "";
					%>
      <%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
    </tr>
    <tr> 
      <td valign="top" style="font-size: 9px">&nbsp;</td>
      <td height="15" valign="top" style="font-size: 9px">&nbsp;</td>
      <td colspan="3" valign="top"><hr size="1" color="#000000"></td>
    </tr>
    <%}// end if (vRetResult != null && vRetResult.size() > 0)
	} // end for(i = 0,iCount=1; i < vRetResult.size(); i += 30,++iCount){
	%>
  </table>
  <%}%>
  <%if (vRetResult != null && vRetResult.size() > 1 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF"><div align="center"><font><a href="javascript:PrintPg()"> 
          </a></font><font size="2">Number 
          of Employees Per Page :</font><font>
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 10; i <=25 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          </font><font><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a> <font size="1">click 
          to print</font></font></div></td>
    </tr>
  </table>
  <%}%>
  <input type="hidden" name="searchEmployee">
  <input type="hidden" name="print_page" value="">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>