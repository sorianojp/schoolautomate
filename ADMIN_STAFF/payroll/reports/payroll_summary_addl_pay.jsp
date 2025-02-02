<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PReDTRME" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary For Bank</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css"> 
		TD.thinborderNONE {
			font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
			font-size: 10px;
		}

    TD.thinborderBOTTOM {
			border-bottom: solid 1px #000000;
			font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
			size:10px;		
    }

		TD.thinborderBOTTOMLEFT {
			border-left: solid 1px #000000;
			border-bottom: solid 1px #000000;
			font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
			font-size: 10px;
		}
		Table.thinborder {
			border-right: solid 1px #000000;
			border-top: solid 1px #000000;
			font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
			font-size: 10px;
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
function ViewRecords()
{
	document.form_.print_page.value="";	
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
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

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=301&month_of="+strMonth+
							 "&year_of="+strYear+"&is_weekly="+strWeekly;

	this.processRequest(strURL);
}
</script>
<body>
<form name="form_" 	method="post" action="./payroll_summary_addl_pay.jsp">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	double dTotal =0d;
		
//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./payroll_summary_addl_pay_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Summary(Salary Additional)","payroll_summary_addl_pay.jsp");
								
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
														"Payroll","REPORTS",request.getRemoteAddr(),
														"payroll_summary_addl_pay.jsp");
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
	
	Vector vRetResult = null;
	ReportPayroll RptPay = new ReportPayroll(request);
	String strPayrollPeriod  = null;
	String strTemp2 = null;
	if(bolIsSchool)
		strTemp2 = "College";
	else
		strTemp2 = "Division";
	String[] astrSortByName    = {strTemp2, "Department","Firstname","Lastname"};
	String[] astrSortByVal     = {"c_name","d_name", "fname", "lname"};
	double dTemp = 0d;
	
	if(WI.fillTextValue("searchEmployee").length() > 0){
		vRetResult = RptPay.searchAddlPay(dbOP);
			if(vRetResult == null)
				strErrMsg = RptPay.getErrMsg();
			else
				iSearchResult = RptPay.getSearchCount();
	}
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
		int i = 0;
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
        PAYROLL: PAYROLL SUMMARY (SALARY ADDITIONAL) PAGE ::::</strong></font></td>
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
      <td width="2%" height="25">&nbsp;</td>
      <td width="21%">Salary Period</td>
      <td width="77%" colspan="3"><strong> 
			<label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px">
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
          <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"> 
          <%=strTemp2%> </option>
          <%}else{%>
          <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"> 
          <%=strTemp2%></option>
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
    <%if(bolIsSchool){%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Employee Status</td>
      <td height="10" colspan="3"><select name="pt_ft" onChange="ReloadPage();">
        <option value="" selected>All</option>
        <%if (WI.fillTextValue("pt_ft").equals("0")){%>
        <option value="0" selected>Part - time</option>
        <option value="1">Full - time</option>
        <%}else if (WI.fillTextValue("pt_ft").equals("1")){%>
        <option value="0">Part - time</option>
        <option value="1" selected>Full - time</option>
        <%}else {%>
        <option value="0">Part - time</option>
        <option value="1">Full - time</option>
        <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee Category</td>
      <td height="10" colspan="3">
			<select name="employee_category" onChange="ReloadPage();">
        <option value="" selected>All</option>
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
    <%}else{%>
    <input type="hidden" name="employee_category" value="0">
    <%}%>
    <% 
	strTemp = WI.fillTextValue("employee_category");
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td height="10" colspan="3"> <select name="c_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Department/Office</td>
      <td height="26" colspan="3"> <select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee ID</td>
      <td height="10" colspan="3"><input name="emp_id" type="text" size="16"maxlength="16" value="<%=WI.fillTextValue("emp_id")%>"></td>
    </tr>
    
    
    <tr> 
      <td height="10" colspan="5"><hr size="1" color="#000000"></td>
    </tr>
  </table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td height="29"><select name="sort_by1">
        <option value="">N/A</option>
        <%=RptPay.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
        <%=RptPay.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>
        <%=RptPay.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
				<!--
				<input name="image" type="image" onClick="ReloadPage()" src="../../../images/form_proceed.gif"> 
				-->
				<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="javascript:SearchEmployee();">
				<font size="1">click to display employee list to print.</font></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
  </table>	
  <% if (vRetResult != null && vRetResult.size() > 0 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <%		
	int iPageCount = iSearchResult/RptPay.defSearchSize;		
	if(iSearchResult % RptPay.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>	
    <tr> 
      <td><div align="right"><font size="2">Jump To page: 
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
          </font></div></td>
    </tr>
	<%}%>	
  </table>	
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">	
    <tr> 
      <td height="24" colspan="10" align="center" class="thinborderBOTTOMLEFT"><font size="1">&nbsp;</font><strong><font color="#0000FF">PAYROLL 
        DATE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
      <% if (vRetResult!= null && vRetResult.size() > 0){
		strTemp = (String)vRetResult.elementAt(0);			
		} 
	  %>
    </tr>
    <tr> 
      <td width="4%" align="center" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td width="25%" align="center" class="thinborderBOTTOMLEFT"><strong>EMPLOYEE NAME</strong></td>
      <td width="8%" align="center" class="thinborderBOTTOMLEFT">OT</td>
      <td width="8%" align="center" class="thinborderBOTTOMLEFT">BONUS</td>
      <td width="8%" align="center" class="thinborderBOTTOMLEFT">NIGHT DIFF.</td>
      <td width="9%" align="center" class="thinborderBOTTOMLEFT">HOLIDAY PAY</td>
      <td width="10%" align="center" class="thinborderBOTTOMLEFT">ADDL RESP</td>
      <td width="10%" align="center" class="thinborderBOTTOMLEFT">ADDL PAY</td>
      <td width="9%" align="center" class="thinborderBOTTOMLEFT">TOTAL INCENTIVE</td>
      <td width="9%" align="center" class="thinborderBOTTOMLEFT">TOTAL</td>
    </tr>
    <% int iCount = 0;
	if (vRetResult != null && vRetResult.size() > 0){	  
	  for(i = 0,iCount=1; i < vRetResult.size(); i += 10,++iCount){	  
		dTotal = 0d;
	  %>
    <tr> 
      <td height="26" class="thinborderBOTTOMLEFT"><div align="right"><%=iCount%></div></td>
      <td class="thinborderBOTTOMLEFT"><strong>&nbsp;&nbsp;<strong><%=WI.formatName(((String)vRetResult.elementAt(i)).toUpperCase(), (String)vRetResult.elementAt(i+1),
							((String)vRetResult.elementAt(i+2)).toUpperCase(), 4)%></strong></strong></td>
      <%  
 				strTemp = (String)vRetResult.elementAt(i+3);
 				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dTotal += dTemp;
				if(dTemp <= 0d)
					strTemp = "";
				else
					strTemp = CommonUtil.formatFloat(strTemp,true);
 			%>
      <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
      <%  
 				strTemp = (String)vRetResult.elementAt(i+4);			
  			strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dTotal += dTemp;
				if(dTemp <= 0d)
					strTemp = "";
				else
					strTemp = CommonUtil.formatFloat(strTemp,true);
			%>
      <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp; </td>
      <%  
 				strTemp = (String)vRetResult.elementAt(i+5);			
 				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dTotal += dTemp;
				if(dTemp <= 0d)
					strTemp = "";
				else
					strTemp = CommonUtil.formatFloat(strTemp,true);
			%>
      <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
      <%  
 				strTemp = (String)vRetResult.elementAt(i+6);			
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dTotal += dTemp;
				if(dTemp <= 0d)
					strTemp = "";
				else
					strTemp = CommonUtil.formatFloat(strTemp,true);
			%>
      <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
      <%  
 				strTemp = (String)vRetResult.elementAt(i+7);			
 				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dTotal += dTemp;
				if(dTemp <= 0d)
					strTemp = "";
				else
					strTemp = CommonUtil.formatFloat(strTemp,true);
			%>
      <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
      <%  
 				strTemp = (String)vRetResult.elementAt(i+8);			
 				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dTotal += dTemp;
				if(dTemp <= 0d)
					strTemp = "";
				else
					strTemp = CommonUtil.formatFloat(strTemp,true);
			%>
      <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
      <%  
 				strTemp = (String)vRetResult.elementAt(i+9);			
 				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dTotal += dTemp;
				if(dTemp <= 0d)
					strTemp = "";
				else
					strTemp = CommonUtil.formatFloat(strTemp,true);
			%>
      <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(dTotal,true),"")%>&nbsp;</td>
    </tr>
    <% } // end for loop
	 }// end if%>
  </table>
  <%}%>
  
  <%if (vRetResult != null && vRetResult.size() > 0 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF"><div align="left"><font size="2">Number 
          of Employees Per Page :</font><font> 
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 16; i <=45 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></font></div></td>
    </tr>
  </table>
  <%}%>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_page" value="">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>