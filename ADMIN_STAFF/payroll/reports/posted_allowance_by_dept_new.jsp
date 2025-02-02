<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRAllowances,payroll.PReDTRME,java.util.Date" %>
<%
///added code for HR/companies.
WebInterface WI = new WebInterface(request);
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
boolean bolHasConfidential = false;
boolean bolHasTeam = false;
boolean bolRemoveOtherEarnings = true;

boolean bolOfficeTotal = false;
boolean bolShowHeader = true; 
String strCurColl = null;
String strNextColl = null;
String strCurDept = null;
String strNextDept = null;


%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Allowance Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    table.TOPRIGHT {
    border-top: solid 1px #000000;
		border-right: solid 1px #000000;
    }

    TD.headerTOPBOTTOMLEFT {
    	border-top: solid 1px #000000;
    	border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("size_header"),"12")%>px;		
    }
    TD.headerBOTTOMLEFT {
    	border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("size_header"),"12")%>px;		
    }
    TD.headerBOTTOMLEFTRIGHT {
    	border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("size_header"),"12")%>px;
    }		
    TD.headerTOPBOTTOMLEFTRIGHT {
    	border-top: solid 1px #000000;
    	border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("size_header"),"12")%>px;
    }		

		TD.BOTTOMLEFT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
    }
    TD.BOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
    }
	TD.BOTTOM {
		border-bottom: solid 1px #000000;		
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
    }		
    TD.NoBorder {
		font-family:  Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
		}
		
	.others_header{
		border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("size_header"),"9")%>px;
	}	
	.others_body{		
    	border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
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
	for(i = 0; i < 11; ++i)
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
	String strTemp = null;
	String strTemp2 = null;	
	String strUserId = (String)request.getSession(false).getAttribute("userId");
	String strHasWeekly = null;
	String strPayrollPeriod  = null;
	String[] astrSalaryBase = {"Monthly rate", "Daily Rate", "Hourly Rate"};
	boolean bolProceed = true;
	int iSearchResult = 0;
	int i = 0;

	boolean bolShowALL = false;
	if(strUserId != null && (strUserId.equals("bricks") || strUserId.equals("SA-01")) )
		bolShowALL = true;	
	boolean bolShowBorder = false;

try
	{
		dbOP = new DBOperation(strUserId,
								"Admin/staff-Payroll-REPORTS-Payroll Register","posted_allowance_by_dept_new.jsp");
								
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
														"posted_allowance_by_dept_new.jsp");
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
	PReDTRME prEdtrME           = new PReDTRME();
	PRAllowances prAllowances   = new PRAllowances();
	Vector vNetPay              = null;
	
	Vector vRetResult = null;	 Vector vEmpInfo = null;
	
	if(WI.fillTextValue("searchEmployee").equals("1")) {
		vRetResult = prAllowances.getAllAllowanceForPeriodNew(dbOP,request, 1);
		if(vRetResult == null)
			strErrMsg = prAllowances.getErrMsg();
		else {
			vEmpInfo = (Vector)vRetResult.remove(0);
		}
	}
	
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<body>
<form name="form_" 	method="post" action="posted_allowance_by_dept_new.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
      EMPLOYEE ALLOWANCES::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
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
        <select name="sal_period_index" style="font-weight:bold;font-size:11px">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");		
		
		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
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
						strTemp = "0.00";
				%>
        <input type="checkbox" name="is_weekly" value="1" <%=strTemp%> onClick="ReloadPage();">
        <font size="1">for weekly </font>
        <%}// check if the company has weekly salary type%>      </td>
    </tr>
		<%if(bolIsSchool){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td colspan="3">
	   <select name="employee_category">          
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
      <td height="25">&nbsp;</td>
      <td>Office/Dept filter</td>
      <td colspan="3"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Salary base </td>
			<%
				strTemp = WI.fillTextValue("salary_base");
			%>
      <td colspan="3">
			<select name="salary_base">
				<option value="">ALL</option>
        <%for(i = 0; i < astrSalaryBase.length; i++){
					if(strTemp.equals(Integer.toString(i))){
				%>
				<option value="<%=i%>" selected><%=astrSalaryBase[i]%></option>
				<%}else{%>
				<option value="<%=i%>"><%=astrSalaryBase[i]%></option>
				<%}
				}%>
      </select></td>
    </tr>
 	<tr>
      <td height="25">&nbsp;</td>
      <td>Taxable/Non-Taxable</td>
      <td colspan="3">
	  	<%	strTemp = WI.fillTextValue("taxable_status"); %>
			<select name="taxable_status">
				<option value="" <%=strTemp.equals("")?"selected":"" %> > All </option>
				<option value="1" <%=strTemp.equals("1")?"selected":"" %> >Taxable</option>
				<option value="0" <%=strTemp.equals("0")?"selected":"" %> >Non - Taxable</option>
			</select>
	  </td>
    </tr>	
		
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Employee ID </td>
		  <td><input name="emp_id" type="text" size="16"maxlength="128" value="<%=WI.fillTextValue("emp_id")%>"
											onKeyUp="AjaxMapName(1);"><label id="coa_info"></label>	</td>
	  </tr>
			
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    
   
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td width="47%" height="10"><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
      <font size="1">Show Result</font></td>
      <td width="45%" height="10" align="right">
        Number of Employees / rows Per Page :
            <select name="num_rec_page">
              <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"40"));
			for(i = 15; i <=60 ; i++) {
				if ( i == iDefault) {%>
              <option selected value="<%=i%>"><%=i%></option>
              <%}else{%>
              <option value="<%=i%>"><%=i%></option>
              <%}
			 }%>
            </select>
			<% if (vEmpInfo != null && vEmpInfo.size() > 0 ){%>
            	<a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font>
			<%}%>
	  </td>
    </tr>
  </table>
  
  <% if (vRetResult != null && vRetResult.size() > 0 ){
String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strAddressL1  = SchoolInformation.getAddressLine1(dbOP,false,false);
String strDateTimePrinted = WI.getTodaysDateTime();

String strReportHeading = null;
if(WI.fillTextValue("taxable_status").equals("1"))
	strReportHeading = "TAXABLE ";
else if(WI.fillTextValue("taxable_status").equals("0"))
	strReportHeading = "NON-TAXABLE ";
else
	strReportHeading = "";

int iRowPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
int iRowCount = 0;
boolean bolIsContinue = false;//true when employee crosses over to next page.

		double dEmpTotal = 0d;
		double dNetPayTotal = 0d;
		double dNetPayGrand = 0d;
		double dGrandTotal = 0d;	
		double dTemp = 0d;		
		double dDeductedAmount = 0d;
		double dMonthlyAmount = 0d;

for(i = 0; i < vRetResult.size(); i += 12){
if(i > 1) {%>
	</table>
	<DIV style="page-break-after:always">&nbsp;</Div>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  	<tr align="center">      
      <td>
		  <strong><font size="3"><%=strSchoolName%></font></strong>
		  <br>
		  <font size ="1"><%=strAddressL1%></font>
		  <br>
		  <strong><%=strReportHeading%>OTHER INCOME DETAIL PER DEPARTMENT</strong>
		  <br>
		  <font size="1"> PAYROLL - <%=WI.getStrValue(strPayrollPeriod,"")%></font>	  </td>
    </tr>
  	<tr align="right">
  	  <td style="font-size:9px;">Date and Time Printed: <%=strDateTimePrinted%></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" align="center">
    <tr>      
     <td width="10%" height="33" align="center" class="headerTOPBOTTOMLEFT"><strong>EMP. ID # </strong></td>
	 <td width="28%" height="33"  align="center" class="headerTOPBOTTOMLEFT"><strong>EMPLOYEE NAME</strong></td> 
	 <td width="12%" height="33"  align="center" class="headerTOPBOTTOMLEFT"><strong>DATE</strong></td>  
	 <td width="20%" height="33" align="center" class="headerTOPBOTTOMLEFT"><strong>INCOME CODE </strong></td>	
	 <td width="10%" height="33" align="center" class="headerTOPBOTTOMLEFT"><strong>MONTHLY AMOUNT </strong></td>	
	 <td width="10%" height="33" align="center" class="headerTOPBOTTOMLEFT"><strong>DEDUCTIONS </strong></td>
	 <td width="10%" height="33" align="center" class="headerTOPBOTTOMLEFTRIGHT" ><strong>AMOUNT</strong></td>	  
 	 <!--<td width="13%" height="33" align="center" class="headerBOTTOMLEFTRIGHT"><strong>NET PAY </strong></td>-->	
   </tr>
		
   
    <% 
		
		
      for(; i < vRetResult.size(); i += 12){
	  
  	if(iRowCount >= iRowPerPage) {
		iRowCount = 0;
		i = i -12;
		break;
	}
	++iRowCount;
	
	  		dDeductedAmount = 0d;
			dMonthlyAmount  = 0d;
			
			if(bolShowHeader){
				bolShowHeader = false;
				
	 		 %>
			<tr>
			  <%
					if(bolIsSchool)
						strTemp = "College : ";
					else
						strTemp = "Division : ";
						
					strTemp2 = (String)vRetResult.elementAt(i+8);										
					vNetPay = prAllowances.geNetPayByEmpCutOff(dbOP, request, (String)vRetResult.elementAt(i));
					strTemp2 = WI.getStrValue(strTemp2," Dept : ","","");
					%>
			  <td height="15" colspan="7" valign="bottom" class='BOTTOM' >
			  	<strong><%=(WI.getStrValue((String)vRetResult.elementAt(i+7),strTemp, strTemp2, strTemp2)).toUpperCase()%></strong> 
				</td>
			</tr>
			<%}	
			
			if(i+12 < vRetResult.size()){
				if(i == 0){
					strCurColl = WI.getStrValue((String)vRetResult.elementAt(i+9),"0");		
					strCurDept = WI.getStrValue((String)vRetResult.elementAt(i+10),"0");	
				}
				strNextColl = WI.getStrValue((String)vRetResult.elementAt(i + 21),"0");		
				strNextDept = WI.getStrValue((String)vRetResult.elementAt(i + 22),"0");	
				
				
				//if(!(strCurColl).equals(strNextColl) || !(strCurDept).equals(strNextDept)){		
				//if( ( !(strCurColl).equals(strNextColl) )    ||  ( !(strCurDept).equals(strNextDept) &&  strCurColl.equals("0") )  ){			
				//	bolShowHeader = true;
				//}				
				if(!(strCurColl).equals(strNextColl) || !(strCurDept).equals(strNextDept)){			
					bolOfficeTotal = true;					
					bolShowHeader = true;
				}	
			}		
	  		
	%>
    <tr>
	  <td  height="18" align="left" class="BOTTOMLEFT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i),"")%></td>	
	  <% vNetPay = prAllowances.geNetPayByEmpCutOff(dbOP, request, vRetResult.elementAt(i)+""); %>
      <td  class="BOTTOMLEFT" align="left">&nbsp;<strong>&nbsp;<%=((String)vRetResult.elementAt(i + 1)).toUpperCase()%></strong></td>	
	  
	  <%	  	
	  	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4),"");
	  	if(strTemp.length() == 0)
			strTemp = "Till Date";	
	  %>					
	  <td align="left" class="BOTTOMLEFT">&nbsp;<%=strTemp%></td>
	  <td align="left" class="BOTTOMLEFT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2),"")%>
	  	<%
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5),"");//sub type
			if(strTemp.length() > 0)
				strTemp = " - " + strTemp;
		%>
		<%=strTemp%>
	  </td>
	  
	   <%		
	   	dMonthlyAmount = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue((String)vRetResult.elementAt(i+6),"0"),",",""));	  
	  %>
	  <td align="right" class="BOTTOMLEFT">&nbsp;<%=CommonUtil.formatFloat(dMonthlyAmount ,true)%>&nbsp;&nbsp;</td>  
	   
	   <%		
	   	dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue((String)vRetResult.elementAt(i+3),"0"),",",""));	
		dMonthlyAmount =  Double.parseDouble((CommonUtil.formatFloat(dMonthlyAmount,true)).replaceAll(",","")) ;		
  	    dDeductedAmount =  dMonthlyAmount - Double.parseDouble((CommonUtil.formatFloat(dTemp,true)).replaceAll(",",""));   
	  %>
	  <td align="right" class="BOTTOMLEFT">&nbsp;<%= (dDeductedAmount > 0)? "(" + CommonUtil.formatFloat(dDeductedAmount,true) + ")" : "0.00"%>&nbsp;&nbsp;</td>  
		<%		
	   	//dTemp = Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
	  	dEmpTotal += dTemp;
	  %>
	  <td align="right" class="BOTTOMLEFTRIGHT">&nbsp;<%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;&nbsp;</td>     
	  <%		
			dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(vNetPay.elementAt(4),"0"),",",""));
			dNetPayTotal += dTemp;
		%>
		<!--<td align="right" class="BOTTOMLEFTRIGHT">&nbsp;<%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;&nbsp;</td>-->	
	 </tr>
	 
	 <%
	 	if(i+12 < vRetResult.size()){
		 strCurColl = WI.getStrValue((String)vRetResult.elementAt(i+21),"0");
		 strCurDept = WI.getStrValue((String)vRetResult.elementAt(i+22),"0");
	    }	
	 
	 %>
	 
	 <%
	 if(bolOfficeTotal ||  (i+12) >= vRetResult.size() ){
	  	bolOfficeTotal = false;  
		
				iRowCount += 3;
 	%>
	 <tr>
	 	<td colspan="6">&nbsp;</td>
		<td align="right" class="NoBorder" height="15"><strong><u><%=CommonUtil.formatFloat(dEmpTotal,true)%></u></strong>&nbsp;&nbsp;</td>
		<!--<td align="right" class="NoBorder" height="25"><strong><u><%=CommonUtil.formatFloat(dNetPayTotal,true)%></u></strong>&nbsp;&nbsp;</td>-->
	 </tr>	
	 <%
	 	dGrandTotal += dEmpTotal;
		dNetPayGrand += dNetPayTotal;
		dEmpTotal = 0d;
		dNetPayTotal = 0d;	 
	 }//end of not same id%>
	<%}//end of for inner loop
	}//for outer loop.%>
	 <tr>
		<td align="right" class="NoBorder" height="25" style="font-size:11px;" colspan="7"><strong>Grand Total: <u><%=CommonUtil.formatFloat(dGrandTotal,true)%></u></strong>&nbsp;</td>
		<!--<td align="right" class="NoBorder" height="25"><strong><u></u></strong>&nbsp;&nbsp;</td>-->
	 </tr>	
	<%}//end of if vRetResult
	%>
</table>
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