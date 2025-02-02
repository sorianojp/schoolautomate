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
<form name="form_" 	method="post" action="./payroll_summary_for_bank.jsp">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	int i = 0;	
//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./payroll_summary_for_bank_Print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-PayrollGroupSummary","payroll_summary_for_bank.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"payroll_summary_for_bank.jsp");
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
	String strSchCode = dbOP.getSchoolIndex();
	double dSalary = 0d;
	vRetResult = RptPay.searchBankAccntSummary(dbOP);
		if(vRetResult == null){
			strErrMsg = RptPay.getErrMsg();
		}else{
			iSearchResult = RptPay.getSearchCount();
		}

if(WI.fillTextValue("year_of").length() > 0) {
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriod(dbOP, request, 4);
}

%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
      PAYROLL: PAYROLL SUMMARY (FOR BANK) PAGE ::::</strong></font></td>
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
      <td width="16%">Salary Period</td>
      <td width="82%" colspan="3"><strong> 
			<label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");		
		
		for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 8) {

		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {%>
          <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"> 
          <%=astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
		(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7)%> </option>
          <%}else{%>
          <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"> 
          <%=astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
		(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7)%></option>
          <%}//end of if condition.
		  strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		 }//end of for loop.%>
        </select>
				</label>
        </strong></td>
    </tr>
	<%if(bolIsSchool){%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Employee Category</td>
      <td height="10" colspan="3"><select name="employee_category" onChange="ReloadPage();">
          <option value="0" selected>ALL</option>
          <%if (WI.fillTextValue("employee_category").compareTo("1") ==0){%>
          <option value="1" selected>Non-teaching</option>
          <%}else{%>
          <option value="1">Non-teaching</option>
          <%}if (WI.fillTextValue("employee_category").compareTo("2") ==0){%>
          <option value="2" selected>Teaching</option>
          <%}else{%>
          <option value="2" >Teaching</option>
          <%}if (WI.fillTextValue("employee_category").compareTo("3") ==0){%>
          <option value="3" selected>Specified Employee</option>
          <%}else{%>
          <option value="3" >Specified Employee</option>
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
      <td height="10" colspan="3">
	    <select name="c_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> 
        </select></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26">Department/Office</td>
      <td height="26" colspan="3">
	    <select name="d_index" onChange="ReloadPage();">
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
      <td height="10">&nbsp;</td>
      <td height="10">Bank</td>
      <%
		strTemp = WI.fillTextValue("bank_index");		
  	  %>
      <td height="10" colspan="3"><select name="bank_index">
          <option value="">Select Bank</option>
          <%=dbOP.loadCombo("BANK_INDEX","BANK_NAME, BRANCH as Bank", " from FA_BANK_LIST", strTemp,false)%> </select></td>
    </tr>
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%" height="10">&nbsp;</td>
      <td width="11%" height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3"><input name="image" type="image" onClick="ViewRecords()" src="../../../images/form_proceed.gif">      </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <% if (vRetResult != null && vRetResult.size() > 0 ){%>
      <td height="10" colspan="4"><div align="right"></div></td>
      <%}%>
    </tr>
  </table>
  <% if (vRetResult != null && vRetResult.size() > 1 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18"><div align="right"><font size="2"> Number of Employees Per 
          Page :</font><font> 
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
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
    <tr> 
      <td height="24"><div align="center">&nbsp;</div></td>
      <% if (vRetResult!= null && vRetResult.size() > 0){
		strTemp = (String)vRetResult.elementAt(0);			
		}
	%>
      <td height="24"><font size="1">&nbsp;<%=WI.getStrValue(strTemp," ")%></font></td>
      <td height="24">&nbsp;</td>
      <%
	 	strTemp = WI.fillTextValue("sal_period_index");		

		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 8) {
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
          strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
          }
		 }
		%>
      <td height="24"><div align="center"><strong><font color="#0000FF">PAYROLL 
          DATE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></div></td>
      <td height="24">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="21%"><div align="center"><font size="1"><strong>ACCOUNT #</strong></font></div></td>
      <td width="4%">&nbsp;</td>
      <td width="51%"><div align="center"><font size="1"><strong>EMPLOYEE NAME</strong></font></div></td>
      <td width="22%"><div align="center"><font size="1"><strong>SALARY</strong></font></div></td>
    </tr>
    <% int iCount = 0;
	if (vRetResult != null && vRetResult.size() > 0){	  
	  for(i = 1,iCount=1; i < vRetResult.size(); i += 13,++iCount){%>
    <tr> 
      <td height="33"><div align="right"><%=iCount%></div></td>
      <%	strTemp = null;
		if (vRetResult!= null && vRetResult.size() > 0){
		strTemp = (String)vRetResult.elementAt(i+5);			
		}
	%>
      <td><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strTemp," ")%></font></td>
      <td>&nbsp;</td>
      <td><div align="left"><font size="1"><strong><%=WI.formatName(((String)vRetResult.elementAt(i+1)).toUpperCase(), (String)vRetResult.elementAt(i+2),
							((String)vRetResult.elementAt(i+3)).toUpperCase(), 4)%></strong></font></div></td>
      <% strTemp = null;
  	    if(strSchCode.startsWith("UI")){           
			if (vRetResult != null && vRetResult.size() > 0){
			
				strTemp = Double.toString(((Double)vRetResult.elementAt(i+4)).doubleValue());			
			}
		}else{
			if (vRetResult != null && vRetResult.size() > 0){
				dSalary = ((Double) vRetResult.elementAt(i+4)).doubleValue() + 
						  ((Double) vRetResult.elementAt(i+6)).doubleValue() + 
						  ((Double) vRetResult.elementAt(i+7)).doubleValue() + 
						  ((Double) vRetResult.elementAt(i+8)).doubleValue() + 
						  ((Double) vRetResult.elementAt(i+9)).doubleValue() + 
				  		  ((Double) vRetResult.elementAt(i+10)).doubleValue() + 
						  ((Double) vRetResult.elementAt(i+11)).doubleValue() + 
						  ((Double) vRetResult.elementAt(i+12)).doubleValue() ;
				strTemp = Double.toString(dSalary);
			}
		
		}
		%>
      <td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true)," ")%>&nbsp;&nbsp;&nbsp;</font></div></td>
    </tr>
    <% } // end for loop
	 }// end if%>
  </table>
  <%}%>
  
  <%if (vRetResult != null && vRetResult.size() > 1 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF"><div align="left"></div></td>
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