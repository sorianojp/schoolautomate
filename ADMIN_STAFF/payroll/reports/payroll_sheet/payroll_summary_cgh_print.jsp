<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary For Bank</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TD.noBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 11px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: 11px;
    }
</style>

</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
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

function ViewRecords()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
}

</script>
<body onLoad="javascript:window.print();">
<form name="form_" 	method="post" action="./payroll_summary_cgh.jsp">
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, payroll.PReDTRME" %>
<%  WebInterface WI = new WebInterface(request);
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
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Summary by status","payroll_summary_cgh.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");								
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
	Vector vRetLoans  = new Vector();
	PayrollSheet pSheet = new PayrollSheet(request);
	String strPayEnd  = null;
	String strTemp2 = null;
	Vector vRows = null;
	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vEarnDed = null;	
	
//	double dPeriodRate     = 0d;
//	
//	double dOtherDeduction = 0d;
//	double dTotalDeduction = 0d;

	double dNetBasicPay1   = 0d;
	double dNetBasicPay2   = 0d;
	double dNetBasicPay3   = 0d;
	double dNetBasicPay4   = 0d;
	double dNetBasicPay5   = 0d;
 
	double dTemp           = 0d;
	double dLineTotal      = 0d;
	int iRow = 0;
	int iRowItem = 24; 
	
	vRetResult = pSheet.generatePSheetSummaryCGH(dbOP);
	if(vRetResult != null && vRetResult.size() > 0){
		vRows = (Vector)vRetResult.elementAt(0);
		vEarnings = (Vector)vRetResult.elementAt(1);
		vDeductions = (Vector)vRetResult.elementAt(2);
		vEarnDed = (Vector)vRetResult.elementAt(3);
	}
		vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	strTemp = WI.fillTextValue("sal_period_index");		
	 for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {			
			if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
				strPayEnd = (String)vSalaryPeriod.elementAt(i + 7);
				break;
			}
	 }
%>
		<%if(vRows != null && vRows.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
		  <td><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></td>
	  </tr>
		<tr>
		  <td>SUMMARY OF PAYROLL </td>
	  </tr>
		<tr>
			<td><%=WI.getStrValue(WI.formatDate(strPayEnd,6),"")%></td>
		</tr>
		<tr>
		  <td>&nbsp;</td>
	  </tr>
	</table>
			
  <table width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr> 
      <td width="27%" class="noBorder">&nbsp;</td>
      <td width="12%" align="center" class="noBorder">TEACHING FT </td>
      <td width="12%" align="center" class="noBorder">NON-TEACHING</td>
      <td width="12%" align="center" class="noBorder"><div align="center">PROF. FEE PT-TEACHING</div></td>
      <td width="12%" align="center" class="noBorder">BUILT IN CI</td>
      <td width="12%" align="center" class="noBorder">PT-PHYSICIAN/</td>
      <td width="12%" align="center" class="noBorder">GRAND TOTALS</td>
    </tr>
    <tr> 
      <td height="20" class="noBorder">Basic Pay</td>
			<% dLineTotal = 0d;
				strTemp = (String)vRows.elementAt(0);			
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay1 += dTemp;
				dLineTotal = dTemp;
			%>
      <td align="right" class="ThinborderTop">&nbsp;<%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem);			
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay2 += dTemp;
					dLineTotal += dTemp;				
			%>			
      <td align="right" class="ThinborderTop"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem*2);			
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay3 += dTemp;
					dLineTotal += dTemp;				
			%>			
      <td align="right" class="ThinborderTop"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem*3);								
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay4 += dTemp;
					dLineTotal += dTemp;
				
			%>			
      <td align="right" class="ThinborderTop">&nbsp;<%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem*4);			
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay5 += dTemp;
					dLineTotal += dTemp;
				
			%>			
      <td align="right" class="ThinborderTop"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
      <td align="right" class="ThinborderTop"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
    <tr> 
      <td height="20" class="noBorder">Undertime Deductions</td>
			<%
			 dLineTotal = 0d;
			
					// leave_deduction_amt
					strTemp = (String)vRows.elementAt(21);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					// awol_amt
					strTemp = (String)vRows.elementAt(22);
					dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
					// late_under_amt
					strTemp = (String)vRows.elementAt(23);
					dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay1 -= dTemp;
					dLineTotal = dTemp;
			 
			%>
			<td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem + 21);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

					strTemp = (String)vRows.elementAt(iRowItem + 22);
					dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

					strTemp = (String)vRows.elementAt(iRowItem + 23);
					dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay2 -= dTemp;
					dLineTotal += dTemp;					
			 
			%>
      <td align="right" class="noBorder">&nbsp;<%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 2 + 21);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

					strTemp = (String)vRows.elementAt(iRowItem * 2 + 22);
					dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

					strTemp = (String)vRows.elementAt(iRowItem * 2 + 23);
					dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay3 -= dTemp;
					dLineTotal += dTemp;					
				
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 3 + 21);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

					strTemp = (String)vRows.elementAt(iRowItem * 3 + 22);
					dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

					strTemp = (String)vRows.elementAt(iRowItem * 3 + 23);
					dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay4 -= dTemp;
					dLineTotal += dTemp;					
									
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 4 + 21);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

					strTemp = (String)vRows.elementAt(iRowItem * 4 + 22);
					dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

					strTemp = (String)vRows.elementAt(iRowItem * 4 + 23);
					dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay5 -= dTemp;
					dLineTotal += dTemp;
									
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>      
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
		<%if(vEarnDed != null && vEarnDed.size() > 1){
			for(iRow = 5; iRow < vEarnDed.size(); iRow+=6){
			 dLineTotal = 0d;
		%>		
    <tr> 
      <td height="20" class="noBorder">&nbsp;<%=(String)vEarnDed.elementAt(iRow)%></td>
			<%
				strTemp = (String)vEarnDed.elementAt(iRow+1);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay1 -= dTemp;
				dLineTotal += dTemp;
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				strTemp = (String)vEarnDed.elementAt(iRow+2);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay2 -= dTemp;
				dLineTotal += dTemp;
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				strTemp = (String)vEarnDed.elementAt(iRow+3);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay3 -= dTemp;
				dLineTotal += dTemp;
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				strTemp = (String)vEarnDed.elementAt(iRow+4);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay4 -= dTemp;
				dLineTotal += dTemp;
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				strTemp = (String)vEarnDed.elementAt(iRow+5);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay5 -= dTemp;
				dLineTotal += dTemp;
				
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
		<%}
		}%>    
    <tr> 
      <td height="28" class="noBorder">Net Basic Pay</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dNetBasicPay1,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dNetBasicPay2,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dNetBasicPay3,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dNetBasicPay4,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dNetBasicPay5,true)%>&nbsp;</td>
			<%dLineTotal = dNetBasicPay1 + dNetBasicPay2 + dNetBasicPay3 + dNetBasicPay4 + dNetBasicPay5;%>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
    <tr> 
      <td height="20" class="noBorder"> Overtime / Adjustment</td>
			<%
			 dLineTotal = 0d;
			
					// OT
					strTemp = (String)vRows.elementAt(2);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					// Adjustment amt
					strTemp = (String)vRows.elementAt(3);
					dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay1 += dTemp;
					dLineTotal = dTemp;
			 
			%>
			<td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
			
					// ot_amt
					strTemp = (String)vRows.elementAt(iRowItem + 2);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

					strTemp = (String)vRows.elementAt(iRowItem + 3);
					dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

					dNetBasicPay2 += dTemp;
					dLineTotal += dTemp;
			 
			%>
      <td align="right" class="noBorder">&nbsp;<%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 2 + 2);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

					strTemp = (String)vRows.elementAt(iRowItem * 2 + 3);
					dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

					dNetBasicPay3 += dTemp;
					dLineTotal += dTemp;
				
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 3 + 2);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

					strTemp = (String)vRows.elementAt(iRowItem * 3 + 3);
					dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

					dNetBasicPay4 += dTemp;
					dLineTotal += dTemp;
									
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 4 + 2);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

					strTemp = (String)vRows.elementAt(iRowItem * 4 + 3);
					dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
 
					dNetBasicPay5 += dTemp;
					dLineTotal += dTemp;
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td> 	
			<td align="right" class="noBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
    <tr>
      <td height="20" class="noBorder">Overload</td>
			<%
				// overload teaching Ft
				strTemp = (String)vRows.elementAt(1);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay1 += dTemp;
				dLineTotal = dTemp;			
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				// overload non teaching 
				strTemp = (String)vRows.elementAt(iRowItem + 1);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay2 += dTemp;
				dLineTotal += dTemp;			
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				// overload PT teaching
				strTemp = (String)vRows.elementAt(iRowItem * 2 + 1);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				dNetBasicPay3 += dTemp;
				dLineTotal += dTemp;			
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				// overload CI
				strTemp = (String)vRows.elementAt(iRowItem * 3 + 1);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay4 += dTemp;
				dLineTotal += dTemp;			
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				// overload Physician
				strTemp = (String)vRows.elementAt(iRowItem * 4 + 1);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay5 += dTemp;
				dLineTotal += dTemp;			
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
    <tr>
      <td height="20" class="noBorder">Sub- Teaching </td>
			<%
				// sub salary teaching Ft
				strTemp = (String)vRows.elementAt(13);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay1 += dTemp;
				dLineTotal = dTemp;			
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				// sub non teaching 
				strTemp = (String)vRows.elementAt(iRowItem + 13);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay2 += dTemp;
				dLineTotal += dTemp;			
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				// overload PT teaching
				strTemp = (String)vRows.elementAt(iRowItem * 2 + 13);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				dNetBasicPay3 += dTemp;
				dLineTotal += dTemp;			
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				// overload CI
				strTemp = (String)vRows.elementAt(iRowItem * 3 + 13);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay4 += dTemp;
				dLineTotal += dTemp;			
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				// overload Physician
				strTemp = (String)vRows.elementAt(iRowItem * 4 + 13);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay5 += dTemp;
				dLineTotal += dTemp;			
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
	
	<!-- start of cola  -->
    <tr>
      <td height="20" class="noBorder">Sub- Teaching </td>
			<%
				// cola salary teaching Ft
				strTemp = (String)vRows.elementAt(12);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay1 += dTemp;
				dLineTotal = dTemp;			
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				// cola non teaching 
				strTemp = (String)vRows.elementAt(iRowItem + 12);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay2 += dTemp;
				dLineTotal += dTemp;			
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				// cola PT teaching
				strTemp = (String)vRows.elementAt(iRowItem * 2 + 12);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				dNetBasicPay3 += dTemp;
				dLineTotal += dTemp;			
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				// cola CI
				strTemp = (String)vRows.elementAt(iRowItem * 3 + 12);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay4 += dTemp;
				dLineTotal += dTemp;			
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				// cola Physician
				strTemp = (String)vRows.elementAt(iRowItem * 4 + 12);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay5 += dTemp;
				dLineTotal += dTemp;			
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>	
	
	
	<!-- end of cola -->
	
    <%if(vEarnings != null && vEarnings.size() > 2){
			for(iRow = 10; iRow < vEarnings.size(); iRow+=6){
			 dLineTotal = 0d;
		%>		
    <tr> 
      <td height="20" class="noBorder"><%=(String)vEarnings.elementAt(iRow)%></td>
			<%
				strTemp = (String)vEarnings.elementAt(iRow+1);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay1 += dTemp;
				dLineTotal += dTemp;
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				strTemp = (String)vEarnings.elementAt(iRow+2);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay2 += dTemp;
				dLineTotal += dTemp;
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				strTemp = (String)vEarnings.elementAt(iRow+3);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay3 += dTemp;
				dLineTotal += dTemp;
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				strTemp = (String)vEarnings.elementAt(iRow+4);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dLineTotal += dTemp;
				dNetBasicPay4 += dTemp;
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				strTemp = (String)vEarnings.elementAt(iRow+5);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay5 += dTemp;
				dLineTotal += dTemp;
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
		<%}
		}%>
		<%if(false){%>
		<!--
    <tr> 
      <td height="20" class="noBorder">ECOLA</td>
			<%  dLineTotal = 0d;
					strTemp = (String)vRows.elementAt(8);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dLineTotal = dTemp;
					dNetBasicPay1 += dTemp;
			%>
			<td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem + 8);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay2 += dTemp;
					dLineTotal += dTemp;
			 
			%>
      <td align="right" class="noBorder">&nbsp;<%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 2 + 8);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dLineTotal += dTemp;
					dNetBasicPay3 += dTemp;
				
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 3 + 8);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dLineTotal += dTemp;
					dNetBasicPay4 += dTemp;
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 4 + 8);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dLineTotal += dTemp;
					dNetBasicPay5 += dTemp;
									
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td> 
			<td align="right" class="noBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
		-->
		<%}%>
    <tr>
      <td height="18" class="noBorder">Other income </td>
			<%
 				dLineTotal= 0d;				
				strTemp = (String)vEarnings.elementAt(1);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// addl_payment_amt
				strTemp = (String)vRows.elementAt(4);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// adhoc_bonus
				strTemp = (String)vRows.elementAt(5);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// holiday_pay_amt
				strTemp = (String)vRows.elementAt(6);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// addl_resp_amt
				strTemp = (String)vRows.elementAt(7);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// faculty_salary
				strTemp = (String)vRows.elementAt(9);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// fac_allowance
				strTemp = (String)vRows.elementAt(10);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// tax_refund
				strTemp = (String)vRows.elementAt(11);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// night_diff
				strTemp = (String)vRows.elementAt(14);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				dNetBasicPay1 += dTemp;
				dLineTotal += dTemp;				
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				strTemp = (String)vEarnings.elementAt(3);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				// addl_payment_amt
				strTemp = (String)vRows.elementAt(iRowItem + 4);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// adhoc_bonus
				strTemp = (String)vRows.elementAt(iRowItem + 5);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// holiday_pay_amt
				strTemp = (String)vRows.elementAt(iRowItem + 6);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// addl_resp_amt
				strTemp = (String)vRows.elementAt(iRowItem + 7);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// faculty_salary
				strTemp = (String)vRows.elementAt(iRowItem + 9);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// fac_allowance
				strTemp = (String)vRows.elementAt(iRowItem + 10);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// tax_refund
				strTemp = (String)vRows.elementAt(iRowItem + 11);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// night_diff
				strTemp = (String)vRows.elementAt(iRowItem + 14);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				dNetBasicPay2 += dTemp;
				dLineTotal += dTemp;
			%>					
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				strTemp = (String)vEarnings.elementAt(5);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// addl_payment_amt
				strTemp = (String)vRows.elementAt(iRowItem * 2 + 4);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// adhoc_bonus
				strTemp = (String)vRows.elementAt(iRowItem * 2 + 5);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// holiday_pay_amt
				strTemp = (String)vRows.elementAt(iRowItem * 2 + 6);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// addl_resp_amt
				strTemp = (String)vRows.elementAt(iRowItem * 2 + 7);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// faculty_salary
				strTemp = (String)vRows.elementAt(iRowItem * 2 + 9);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// fac_allowance
				strTemp = (String)vRows.elementAt(iRowItem * 2 + 10);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// tax_refund
				strTemp = (String)vRows.elementAt(iRowItem * 2 + 11);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// night_diff
				strTemp = (String)vRows.elementAt(iRowItem * 2 + 14);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				dNetBasicPay3 += dTemp;
				dLineTotal += dTemp;
			%>					
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				strTemp = (String)vEarnings.elementAt(7);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// addl_payment_amt
				strTemp = (String)vRows.elementAt(iRowItem * 3 + 4);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// adhoc_bonus
				strTemp = (String)vRows.elementAt(iRowItem * 3 + 5);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// holiday_pay_amt
				strTemp = (String)vRows.elementAt(iRowItem * 3 + 6);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// addl_resp_amt
				strTemp = (String)vRows.elementAt(iRowItem * 3 + 7);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// faculty_salary
				strTemp = (String)vRows.elementAt(iRowItem * 3 + 9);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// fac_allowance
				strTemp = (String)vRows.elementAt(iRowItem * 3 + 10);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// tax_refund
				strTemp = (String)vRows.elementAt(iRowItem * 3 + 11);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// night_diff
				strTemp = (String)vRows.elementAt(iRowItem * 3 + 14);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				dNetBasicPay4 += dTemp;
				dLineTotal += dTemp;
			%>					
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				strTemp = (String)vEarnings.elementAt(9);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// addl_payment_amt
				strTemp = (String)vRows.elementAt(iRowItem * 4 + 4);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// adhoc_bonus
				strTemp = (String)vRows.elementAt(iRowItem * 4 + 5);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// holiday_pay_amt
				strTemp = (String)vRows.elementAt(iRowItem * 4 + 6);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// addl_resp_amt
				strTemp = (String)vRows.elementAt(iRowItem * 4 + 7);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// faculty_salary
				strTemp = (String)vRows.elementAt(iRowItem * 4 + 9);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// fac_allowance
				strTemp = (String)vRows.elementAt(iRowItem * 4 + 10);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// tax_refund
				strTemp = (String)vRows.elementAt(iRowItem * 4 + 11);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// night_diff
				strTemp = (String)vRows.elementAt(iRowItem * 4 + 14);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				dNetBasicPay5 += dTemp;
				dLineTotal += dTemp;
			%>					
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" class="noBorder">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="ThinborderTop">&nbsp;</td>
      <td align="right" class="ThinborderTop">&nbsp;</td>
      <td align="right" class="ThinborderTop">&nbsp;</td>
      <td align="right" class="ThinborderTop">&nbsp;</td>
      <td align="right" class="ThinborderTop">&nbsp;</td>
    </tr>
    <tr> 
      <td height="20" align="center" class="noBorder">Total Gross Pay</td>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dNetBasicPay1,true)%>&nbsp;</td>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dNetBasicPay2,true)%>&nbsp;</td>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dNetBasicPay3,true)%>&nbsp;</td>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dNetBasicPay4,true)%>&nbsp;</td>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dNetBasicPay5,true)%>&nbsp;</td>
			<%dLineTotal = dNetBasicPay1 + dNetBasicPay2 + dNetBasicPay3 + dNetBasicPay4 + dNetBasicPay5;%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" class="noBorder">&nbsp;</td>
      <td align="right" class="noBorder">&nbsp;</td>
      <td align="right" class="noBorder">&nbsp;</td>
      <td align="right" class="noBorder">&nbsp;</td>
      <td align="right" class="noBorder">&nbsp;</td>
      <td align="right" class="noBorder">&nbsp;</td>
      <td align="right" class="noBorder">&nbsp;</td>
    </tr>
    <tr> 
      <td height="20" class="noBorder">Deductions</td>
      <td align="right" class="noBorder">&nbsp;</td>
      <td align="right" class="noBorder">&nbsp;</td>
      <td align="right" class="noBorder">&nbsp;</td>
      <td align="right" class="noBorder">&nbsp;</td>
      <td align="right" class="noBorder">&nbsp;</td>
      <td align="right" class="noBorder">&nbsp;</td>
    </tr>
    <tr> 
      <td height="20" class="noBorder">&nbsp;&nbsp;Withholding Tax</td>
			<%
			 dLineTotal = 0d;			
			 strTemp = (String)vRows.elementAt(17);
			 dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
			 dNetBasicPay1 -= dTemp;
			 dLineTotal = dTemp;			
			%>
			<td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem + 17);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay2 -= dTemp;
					dLineTotal += dTemp;			 
			%>
      <td align="right" class="noBorder">&nbsp;<%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 2 + 17);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay3 -= dTemp;
					dLineTotal += dTemp;				
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 3 + 17);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay4 -= dTemp;
					dLineTotal += dTemp;									
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 4 + 17);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dLineTotal += dTemp;
					dNetBasicPay5 -= dTemp;
									
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td> 
			<td align="right" class="noBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
    
    <tr> 
      <td height="20" class="noBorder">&nbsp;&nbsp;SSS Contribution</td>
			<%
			 dLineTotal = 0d;
			
					strTemp = (String)vRows.elementAt(15);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay1 -= dTemp;
					dLineTotal = dTemp;
			
			%>
			<td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem + 15);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay2 -= dTemp;
					dLineTotal += dTemp;
			 
			%>
      <td align="right" class="noBorder">&nbsp;<%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 2 + 15);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay3 -= dTemp;
					dLineTotal += dTemp;
				
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 3 + 15);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dLineTotal += dTemp;
					dNetBasicPay4 -= dTemp;
									
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 4 + 15);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dLineTotal += dTemp;
					dNetBasicPay5 -= dTemp;
									
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td> 
			<td align="right" class="noBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
    
    <tr> 
      <td height="20" class="noBorder">&nbsp;&nbsp;Medicare</td>
			<%
			 dLineTotal = 0d;			
					strTemp = (String)vRows.elementAt(16);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay1 -= dTemp;
					dLineTotal = dTemp;
			 
			%>
			<td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem + 16);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay2 -= dTemp;
					dLineTotal += dTemp;
			 
			%>
      <td align="right" class="noBorder">&nbsp;<%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 2 + 16);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay3 -= dTemp;
					dLineTotal += dTemp;
				
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 3 + 16);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dLineTotal += dTemp;
					dNetBasicPay4 -= dTemp;
									
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 4 + 16);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dLineTotal += dTemp;
					dNetBasicPay5 -= dTemp;
									
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td> 
			<td align="right" class="noBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
    
    <tr> 
      <td height="20" class="noBorder">&nbsp;&nbsp;Pag-ibig</td>
			<% dLineTotal = 0d;
			
					strTemp = (String)vRows.elementAt(18);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay1 -= dTemp;
					dLineTotal = dTemp;
			 
			%>
			<td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem + 18);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay2 -= dTemp;
					dLineTotal += dTemp;
			 
			%>
      <td align="right" class="noBorder">&nbsp;<%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 2 + 18);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dNetBasicPay3 -= dTemp;
					dLineTotal += dTemp;
				
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 3 + 18);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dLineTotal += dTemp;
					dNetBasicPay4 -= dTemp;
									
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
			<%
					strTemp = (String)vRows.elementAt(iRowItem * 4 + 18);
					dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
					dLineTotal += dTemp;
					dNetBasicPay5 -= dTemp;
									
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td> 
			<td align="right" class="noBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
    <%if(vDeductions != null && vDeductions.size() > 1){
			for(iRow = 5; iRow < vDeductions.size(); iRow+=6){
			 dLineTotal = 0d;
		%>		
    <tr> 
      <td height="20" class="noBorder">&nbsp;&nbsp;<%=(String)vDeductions.elementAt(iRow)%></td>
			<%
				strTemp = (String)vDeductions.elementAt(iRow+1);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay1 -= dTemp;
				dLineTotal += dTemp;
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				strTemp = (String)vDeductions.elementAt(iRow+2);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay2 -= dTemp;
				dLineTotal += dTemp;				
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				strTemp = (String)vDeductions.elementAt(iRow+3);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dNetBasicPay3 -= dTemp;
				dLineTotal += dTemp;				
			%>
			<td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				strTemp = (String)vDeductions.elementAt(iRow+4);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dLineTotal += dTemp;
				dNetBasicPay4 -= dTemp;
			%>			
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
				strTemp = (String)vDeductions.elementAt(iRow+5);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dLineTotal += dTemp;
				dNetBasicPay5 -= dTemp;
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
		<%}%>
     <tr>
      <td height="20" class="noBorder">&nbsp;&nbsp;Other Deduction </td>
			<%
				dLineTotal= 0d;
				strTemp = (String)vDeductions.elementAt(0);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// misc_deduction
				strTemp = (String)vRows.elementAt(20);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));				
				
				dNetBasicPay1 -= dTemp;
				dLineTotal += dTemp;
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
 				strTemp = (String)vDeductions.elementAt(1);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// misc_deduction
				strTemp = (String)vRows.elementAt(iRowItem + 20);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));								
				
				dNetBasicPay2 -= dTemp;
				dLineTotal += dTemp;
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
 				strTemp = (String)vDeductions.elementAt(2);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// misc_deduction
				strTemp = (String)vRows.elementAt(iRowItem * 2 + 20);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));								
				
				dNetBasicPay3 -= dTemp;
				dLineTotal += dTemp;
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
 				strTemp = (String)vDeductions.elementAt(3);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				// misc_deduction
				strTemp = (String)vRows.elementAt(iRowItem * 3 + 20);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));					
				
				dNetBasicPay4 -= dTemp;
				dLineTotal += dTemp;
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
			<%
 				strTemp = (String)vDeductions.elementAt(4);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				// misc_deduction
				strTemp = (String)vRows.elementAt(iRowItem * 4 + 20);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));	
								
				dNetBasicPay5 -= dTemp;
				dLineTotal += dTemp;
			%>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
      <td align="right" class="noBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
 		<%}%>
    <tr> 
      <td height="20" align="center" class="noBorder">&nbsp;&nbsp;Net pay</td>
      <td align="right" class="ThinborderTop"><%=CommonUtil.formatFloat(dNetBasicPay1,true)%>&nbsp;</td>
      <td align="right" class="ThinborderTop"><%=CommonUtil.formatFloat(dNetBasicPay2,true)%>&nbsp;</td>
      <td align="right" class="ThinborderTop"><%=CommonUtil.formatFloat(dNetBasicPay3,true)%>&nbsp;</td>
      <td align="right" class="ThinborderTop"><%=CommonUtil.formatFloat(dNetBasicPay4,true)%>&nbsp;</td>
      <td align="right" class="ThinborderTop"><%=CommonUtil.formatFloat(dNetBasicPay5,true)%>&nbsp;</td>
			<%dLineTotal = dNetBasicPay1 + dNetBasicPay2 + dNetBasicPay3 + dNetBasicPay4 + dNetBasicPay5;%>
      <td align="right" class="ThinborderTop"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
  </table>
  <%}%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="18" class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
    </tr>		
    <tr> 
      <td width="31%" height="18" class="NoBorder">Prepared by: </td>
      <td width="5%" class="NoBorder">&nbsp;</td>
      <td width="21%" class="NoBorder">&nbsp;</td>
      <td width="43%" class="NoBorder">Noted by: </td>
    </tr>
    <tr>
      <td height="18" class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
    </tr>
    <tr>
			<%
				strTemp = WI.fillTextValue("prepared_by");
			%>		
      <td height="18" class="NoBorder"><font size="1"><strong>&nbsp;<%=(WI.getStrValue(strTemp)).toUpperCase()%></strong></font></td>
      <td class="NoBorder">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("reviewed_by");
			%>
      <td class="NoBorder">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("noted_by");
			%>			
      <td class="NoBorder"><font size="1"><strong>&nbsp;<%=(WI.getStrValue(strTemp)).toUpperCase()%></strong></font></td>
    </tr>
    <tr>
      <td height="18" class="NoBorder">Personnel/ Payroll Officer </td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">Dean</td>
    </tr>

    <tr>
      <td height="18" class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
    </tr>		
    <tr> 
      <td width="31%" height="18" class="NoBorder">Reviewed by: </td>
      <td width="5%" class="NoBorder">&nbsp;</td>
      <td width="21%" class="NoBorder">&nbsp;</td>
      <td width="43%" class="NoBorder">Approved by: </td>
    </tr>
    <tr>
      <td height="18" class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
    </tr>
    <tr>
			<%
				strTemp = WI.fillTextValue("reviewed_by");
			%>
      <td height="18" class="NoBorder"><font size="1"><strong>&nbsp;<%=(WI.getStrValue(strTemp)).toUpperCase()%></strong></font></td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("approved_by");
			%>		
      <td class="NoBorder"><font size="1"><strong>&nbsp;<%=(WI.getStrValue(strTemp)).toUpperCase()%></strong></font></td>
    </tr>
    <tr>
      <td height="18" class="NoBorder">Assistant for Administrative Affairs </td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">Executive Director  </td>
    </tr>
  </table>
   </form>
</body>
</html>
<%
dbOP.cleanUP();
%>