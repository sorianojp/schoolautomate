<%@ page language="java" import="utility.*,java.lang.Integer, java.util.Vector,payroll.PayrollSheet, payroll.PReDTRME, eDTR.OverTime, eDTR.ReportEDTRExtn" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Control Total for Payroll</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
    table.TOPRIGHT {
    border-top: solid 1px #000000;
		border-right: solid 1px #000000;
    }

    TD.headerBOTTOMLEFT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: 9px;
    }
    TD.headerBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: 9px;
    }		

		TD.BOTTOMLEFT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: 9px;
    }
    TD.BOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: 9px;
    }		
    TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
		}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{	
	document.form_.generate_report.value = "";
	this.SubmitOnce('form_');
}
function UpdateLabel(objTxtBox, strLabel) {
	document.getElementById(strLabel).innerHTML = objTxtBox.value;
}
function PrintPg(){
	
	//delete table 1.
	document.getElementById('table1').deleteRow(0);
	/**
	var obj = document.getElementById('table2');
	var oRows = obj.getElementsByTagName('tr');
	var iRowCount = oRows.length;
	for(i = 0; i < iRowCount; ++i)
		obj.deleteRow(0);
	
	
	document.getElementById('table3').deleteRow(0)
	**/
	alert("Print this page?");
	window.print();
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

</script>

<%
	
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
	String strTemp2  = null;

	int iSearchResult = 0;
	
//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Control Payroll","control_report_ub.jsp");
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
														"control_report_ub.jsp");
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
	String strPayrollPeriod = null;
	Vector vSalaryPeriod  = null;

	Vector vRetResult = null;//[0] = tot loan ded, [1] tot misc ded. [2] total deductions.
	Vector vSummary   = null;//[0] gross pay, [1] net_pay, [2] tax, [3] SSS, [4] philhealth, [5] pag_ibig, [6] peraa, [7] ATM net, [8] non-ATM net
	Vector vLoanDed   = null;//[0] loan name, [1] loan amt
	Vector vMiscDed   = null;//[0] ded name, [1] amount.
	

	
	
//end of authenticaion code.
	PReDTRME prEdtrME      = new PReDTRME();
	payroll.ReportPayrollExtn repPayroll = new payroll.ReportPayrollExtn(request);
	
	
	String strSQLQuery = null;
	java.sql.ResultSet rs = null;

	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	if(WI.fillTextValue("generate_report").length() > 0 && WI.fillTextValue("sal_period_index").length() > 0) {
		vRetResult = repPayroll.getPayrollSummaryUB(dbOP);
		if(vRetResult == null) 
			strErrMsg = repPayroll.getErrMsg();
		else {
			vSummary        = (Vector)vRetResult.remove(3);
			vLoanDed        = (Vector)vRetResult.remove(3);
			vMiscDed        = (Vector)vRetResult.remove(3);
		}
	}

//I have to check if thre are details to be shown.
boolean bolShowDetails = false; //if true, show detail for that label.. 
int iIndexOf = 0;
%>
<body>
<form name="form_" 	method="post" action="control_report_ub.jsp">
<table  id="table1" width="100%"> 
<tr><td>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
      PAYROLL SUMMARY ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><font size="2" color="#FF0000"><strong>&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td colspan="3"> <select name="month_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select></td>
    </tr>
    <tr> 
      <td width="16%" height="22">&nbsp;</td>
      <td width="18%">Salary Period</td>
      <td width="66%" colspan="3">
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
            <span style="font-size:9px;">
            <input type="button" name="proceed_btn" value=" Generate Report " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.generate_report.value='1';document.form_.submit();">
            </span>
			<%if(vRetResult != null && vRetResult.size() > 0) {%>
			<a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a><font size="1">click to print</font>
			<%}%>			</td>
    </tr>
	
	<tr><td colspan="3"><hr size="1" color="#0000FF"></td></tr>
  </table> 
  
 </td></tr></table> <!-- end of table1 -->
 <% 
if(vRetResult != null && vRetResult.size() > 0){ %>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td align="center" colspan="2"><strong><font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong></td>	  
    </tr>  
	 <tr>
      <td align="center" colspan="2"><font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></td>	  
    </tr> 
    <tr>
      <td>&nbsp;</td>
	  <td align="right" style="font-size:9px;">&nbsp;Date and time printed : <%=WI.getTodaysDateTime()%></td>    
    </tr>
 </table>
	
	<table width="54%" border="0" align="center" cellpadding="5" cellspacing="0" >
	  <tr>	  
	  	<td height="50" align="center">
			<strong>PAYROLL SUMMARY FOR CUT-OFF :  <%=strPayrollPeriod%> </strong></td>
	</table>
	<!-- Gross Pay --> 
	<table width="54%" border="0" align="center" cellpadding="5" cellspacing="0" >
	  <tr>	  
	  	<td width="62%" height="50" style="font-weight:bold; font-size:14px;">Gross Pay</td>
		<td style="font-weight:bold; font-size:14px;" align="right"><%=vSummary.elementAt(0)%></td>
	  </tr>
	</table>
	<!-- Loan and other govt mandatory deductions -- 1st Block -->
	<table width="54%" border="0" align="center" cellpadding="0" cellspacing="0" >
      <tr>
        <td width="62%" height="25">Less Deductions</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td align="center"><table width="80%" cellpadding="0" cellspacing="0" border="0">
            <tr>
              <td width="70%" class="thinborderNONE" height="18">Withholding</td>
              <td align="right" class="thinborderNONE"><%=vSummary.elementAt(2)%></td>
            </tr>
            <%if(!vSummary.elementAt(3).equals("0.00")){%>
            <tr>
              <td class="thinborderNONE" height="18">SSS Contribution</td>
              <td align="right" class="thinborderNONE"><%=vSummary.elementAt(3)%></td>
            </tr>
            <%}if(!vSummary.elementAt(4).equals("0.00")){%>
            <tr>
              <td class="thinborderNONE" height="18">PHIC Contribution</td>
              <td align="right" class="thinborderNONE"><%=vSummary.elementAt(4)%></td>
            </tr>
            <%}if(!vSummary.elementAt(5).equals("0.00")){%>
            <tr>
              <td class="thinborderNONE" height="18">PAGIBIG Contribution</td>
              <td align="right" class="thinborderNONE"><%=vSummary.elementAt(5)%></td>
            </tr>
            <%}if(!vSummary.elementAt(6).equals("0.00")){%>
            <tr>
              <td class="thinborderNONE" height="18">PERAA Contribution</td>
              <td align="right" class="thinborderNONE"><%=vSummary.elementAt(6)%></td>
            </tr>
            <%}for(int i = 0; i < vLoanDed.size(); i += 2) {%>
            <tr>
              <td class="thinborderNONE" height="18"><%=vLoanDed.elementAt(i)%></td>
              <td align="right" class="thinborderNONE"><%=vLoanDed.elementAt(i + 1)%></td>
            </tr>
            <%}%>
            <tr>
              <td>&nbsp;</td>
              <td align="right" class="thinborderTOP"><%=vRetResult.elementAt(0)%></td>
            </tr>
        </table></td>
      </tr>
    </table>
	<!-- Misc Deduction -- 3rd block -->
    <br>
	<table width="54%" border="0" align="center" cellpadding="0" cellspacing="0" >
	  <tr>	  
	  	<td width="62%" height="25">Misc. Deductions</td>
		<td>&nbsp;</td>
	  </tr>
	  <tr>
	  	<td align="center">
			<table width="80%" cellpadding="0" cellspacing="0" border="0">
				<%for(int i = 0; i < vMiscDed.size(); i += 2) {%>
				<tr>
					<td class="thinborderNONE" height="18"><%=vMiscDed.elementAt(i)%></td>
					<td align="right" class="thinborderNONE"><%=vMiscDed.elementAt(i + 1)%></td>
				</tr>
				<%}%>
				
				<tr>
					<td>&nbsp;</td>
					<td align="right" class="thinborderTOP"><%=vRetResult.elementAt(1)%></td>
				</tr>
			</table>
		</td>
	  </tr>
	  
	</table>
	<table width="54%" border="0" align="center" cellpadding="5" cellspacing="0" >
	  <tr>	  
	  	<td width="62%" height="50" style="font-weight:bold; font-size:14px;">Total Deduction</td>
		<td style="font-weight:bold; font-size:14px;" align="right"><%=vRetResult.elementAt(2)%></td>
	  </tr>
	</table>
	<!-- Net Pay --> 
	<table width="54%" border="0" align="center" cellpadding="5" cellspacing="0" >
	  <tr>	  
	  	<td width="62%" height="50" style="font-weight:bold; font-size:14px;">Net Pay</td>
		<td style="font-weight:bold; font-size:14px;" align="right"><u><%=vSummary.elementAt(1)%></u></td>
	  </tr>
	</table>
	<table width="54%" border="0" align="center" cellpadding="5" cellspacing="0" >
	  <tr>	  
	  	<td width="62%" height="22">ATM Net Pay</td>
		<td><%=vSummary.elementAt(7)%></td>
	  </tr>
	  <tr>	  
	  	<td height="22">Non-ATM Net Pay</td>
		<td><%=vSummary.elementAt(8)%></td>
	  </tr>
	</table>
	
	<table width="54%" border="0" align="center" cellspacing="0" class="thinborder">

	</table>	

<%}//end if vRetResult is not null.. %>


<input type="hidden" name="generate_report">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>