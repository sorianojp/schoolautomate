<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn, payroll.PReDTRME" %>
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
<form name="form_" 	method="post" action="./payroll_breakdown.jsp">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	int i = 0;	
	
//add security here.
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./payroll_breakdown_print.jsp" />
<%return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Breakdown","payroll_breakdown.jsp");
								
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
														"payroll_breakdown.jsp");
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
	ReportPayrollExtn RptPayExtn = new ReportPayrollExtn(request);
	String strPayrollPeriod  = null;	
	String strTemp2 = null;
	double dSalary = 0d;

	
	vRetResult = RptPayExtn.payrollBreakdown(dbOP);
		if(vRetResult == null){
			strErrMsg = RptPayExtn.getErrMsg();
		}else{
			iSearchResult = RptPayExtn.getSearchCount();
		}

	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
      PAYROLL: PAYROLL BREAKDOWN::::</strong></font></td>
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
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Employee Status</td>
      <td height="10" colspan="3">
	   <select name="pt_ft" onChange="ReloadPage();">
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
		<%if(bolIsSchool){%>
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
    <%}%>
<tr>
      <td height="10">&nbsp;</td>
      <td height="10">Show Option </td>
      <td height="10" colspan="3">
			<select name="show_option" onChange="ReloadPage();">
        <option value="0" selected>Net Salary</option>
        <%if (WI.fillTextValue("show_option").equals("1")){%>
        <option value="1" selected>Gross Salary</option>
        <%}else{%>
        <option value="1">Gross Salary</option>
        <%}%>
      </select></td>
    </tr>		
    <% 
	strTemp = WI.fillTextValue("employee_category");
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="10">&nbsp;</td>
      <td width="21%" height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3"><input name="image" type="image" onClick="ViewRecords()" src="../../../images/form_proceed.gif">      </td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1" color="#000000"></td>
    </tr>
  </table>
  <% if (vRetResult != null && vRetResult.size() > 1 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18"><div align="right">	    <font size="2">	    
		Number of Departments Per Page :</font>
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i =15; i <=45 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}
			}%>
          </select><a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></div></td>
    </tr>
    <%		
	int iPageCount = iSearchResult/RptPayExtn.defSearchSize;		
	if(iSearchResult % RptPayExtn.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%> 
    <tr>
      <td height="18" align="right"><font size="2">Jump To page:
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
      </font></td>
    </tr>
	<%}%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="24" class="thinborderNONE">&nbsp;</td>
      <td width="2%" class="thinborderNONE">&nbsp;</td>
      <% if (vRetResult!= null && vRetResult.size() > 1){
		strTemp = (String)vRetResult.elementAt(0);			
		}
	%>
      <td width="19%" height="24" class="thinborderNONE"><font size="1">&nbsp;<%=WI.getStrValue(strTemp," ")%></font></td>
      <td width="51%" height="24" align="center" class="thinborderNONE"><strong><font color="#0000FF">PAYROLL 
        DATE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
      <td width="25%" height="24" class="thinborderNONE">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="5%" align="center" class="thinborderNONE">&nbsp;</td>
      <td width="4%" align="center" class="thinborderNONE">&nbsp;</td>
      <td width="62%" align="center" class="thinborderNONE">&nbsp;</td>
			<%
				strTemp = "Net Salary";
				if(WI.fillTextValue("show_option").equals("1"))
					strTemp = "Gross Salary";
			%>
      <td width="29%" align="center" class="thinborderNONE"><%=strTemp%></td>
    </tr>
    <% int iCount = 0;
 
	if (vRetResult != null && vRetResult.size() > 1){	  
	  for(i = 0,iCount=1; i < vRetResult.size(); i += 3,++iCount){
	  %>
    <tr> 
      <td height="18" class="thinborderNONE"><div align="right"><%=iCount%></div></td>
      <td class="thinborderNONE">&nbsp;</td>
 	  <%
	  	strTemp = WI.getStrValue((String)vRetResult.elementAt(i),(String)vRetResult.elementAt(i+1));
		strTemp = WI.getStrValue(strTemp);
	  %>
      <td class="thinborderNONE">&nbsp;<%=strTemp%></td>
	  
      <td class="thinborderNONE"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vRetResult.elementAt(i+2),true),"&nbsp;")%>&nbsp;</div></td>
    </tr>
    <% 
		} // end for loop
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