<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, payroll.PReDTRME" %>
<%
		WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Sheet/Register Printing</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TD.NoBorder {
 	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }	
    TD.thinbordeRIGHT {
		border-right: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }			
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-payrollsheet","payroll_sheet_cgh.jsp");
								
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
														"payroll_sheet_cgh.jsp");
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
	String strPayEnd = null;
	String strHourlyRate = null;
//	int iStart = 29; // this is where the null fields start
	int iFieldCount = 75;

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
	double dTotalOverload = 0d;
	double dTempHours = 0d;
		
	Vector vRows = null;
	Vector vEarnCols = null;
	Vector vDedCols = null;
	Vector vEarnDedCols = null;
	Vector vRetResult = null;
	int iCols = 0;
	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vEarnDed = null;
	Vector vOTDetail = null;
	Vector vSalDetail = null;
	Vector vLateUtDetail = null;
	Vector vAWOL = null;
	double dOtherEarn = 0d;
	double dOtherDed  = 0d;
	int i = 0;
	String strUserIndex = null;
	int iIndex = 0;

	String strEmpCatg = "";
	if(WI.fillTextValue("employee_category").length() > 0){
		if(WI.fillTextValue("employee_category").equals("1"))
			strEmpCatg = "Teaching";
		else
			strEmpCatg = "Non-Teaching";
	}

	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	strTemp = WI.fillTextValue("sal_period_index");		
 	 for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {			
			if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
				strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) + "-" + (String)vSalaryPeriod.elementAt(i + 7);
				strPayEnd = (String)vSalaryPeriod.elementAt(i + 7);
				break;
			}
	 }
		
	vRetResult = RptPSheet.getPSheetItems(dbOP);
	vAWOL = RptPSheet.getAWOLHours(dbOP,request);
	if (vRetResult != null) {
	int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	int iNumRec = 0;//System.out.println(vRows);
	
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount = 0;

	boolean bolPageBreak = false;

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

	int iTotalPages = (vRows.size())/(iFieldCount*iMaxRecPerPage);			
	double[] adEarningTotal = new double[iEarnColCount];
	double[] adDeductTotal = new double[iDedColCount];
	double[] adEarnDedTotal = new double[iEarnDedCount];
	
	if((vRows.size() % (iFieldCount*iMaxRecPerPage)) > 0) 
		 ++iTotalPages;

	 for (;iNumRec < vRows.size();iPage++){

			/*
		 dTotalBasic = 0d;
		 for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
				adEarningTotal[iCols - 2] = 0d;	
		 }

		 dTotalOtherEarn = 0d;
		 dTotalAbsences = 0d;
		 dTotalGross = 0d;
		 
		 dTotalSSS = 0d;
		 dTotalPhealth = 0d;
		 dTotalHdmf = 0d;			
		 dTotalTax = 0d;
		 // reset the page total 
		 for(iCols = 1;iCols <= iDedColCount; iCols++){
			 adDeductTotal[iCols-1] = 0d;
		 }
		 dTotalOtherDed = 0d;
		 dTotalNetPay = 0d;	
		 
		 for(iCols = 1;iCols <= iEarnDedCount; iCols++){
			 adEarnDedTotal[iCols-1] = 0d;
		 }		 
		 */		 		 
%>
<body onLoad="javascript:window.print();">
<form name="form_">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td>
    </tr>
    <tr>
      <td>PAYROLL - <%=strPayEnd%></td>
    </tr>
    <%if(strEmpCatg.length() > 0){%>
    <tr>
      <td>PAYROLL FOR <%=WI.getStrValue(strEmpCatg).toUpperCase()%> STAFF </td>
    </tr>
    <%}%>		
    <tr>
      <td height="19" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr> 
      <td width="14%" height="33" rowspan="2" align="center" valign="bottom" class="thinborderBOTTOM">NAME 
          OF EMPLOYEE </td>
      <!--
			<td width="4%" rowspan="2" align="center" valign="bottom" class="thinborderBOTTOM">BASIC</td>
			-->
      <td width="5%" rowspan="2" align="center" valign="bottom" class="thinborderBOTTOM">SEMI-MO</td>
      <td width="3%" rowspan="2" align="center" valign="bottom" class="thinborderBOTTOM">RATE 
          PER HOUR</td>
      <td height="24" colspan="2" align="center" valign="bottom" class="NoBorder">UT / <br>
      ABSENCES</td>
      <td colspan="2" align="center" valign="bottom" class="NoBorder">NET 
          BASIC </td>
      <td width="3%" rowspan="2" align="center" valign="bottom" class="thinborderBOTTOM">OT 
          RATE</td>
      <td width="4%" rowspan="2" align="center" valign="bottom" class="thinborderBOTTOM">OVERTIME</td>
      <%if(WI.fillTextValue("employee_category").equals("1")){%>
			<td width="4%" colspan="2" align="center" valign="bottom"><span class="NoBorder">OVERLOAD</span></td>
			<%}%>
			<%for(iCols = 2;iCols <= iEarnColCount +1; iCols ++){%>
      <td rowspan="2" align="center" valign="bottom" class="thinborderBOTTOM"><%=(String)vEarnCols.elementAt(iCols)%></td>
			<%}%>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){%>
      <td rowspan="2" align="center" valign="bottom" class="thinborderBOTTOM"><%=(String)vEarnDedCols.elementAt(iCols)%></td>
			<%}%>			
      <td width="4%" rowspan="2" align="center" valign="bottom" class="thinborderBOTTOM">OTHER INC. </td>
      <td width="5%" rowspan="2" align="center" valign="bottom" class="thinborderBOTTOM">TOTAL 
          GROSS PAY</td>      
      <td width="4%" rowspan="2" align="center" valign="bottom" class="thinborderBOTTOM">TAX</td>
      <td width="4%" rowspan="2" align="center" valign="bottom" class="thinborderBOTTOM">SSS</td>
			<td width="4%" rowspan="2" align="center" valign="bottom" class="thinborderBOTTOM">MED.</td>
      <td width="4%" rowspan="2" align="center" valign="bottom" class="thinborderBOTTOM">HDMF</td>
      <%			
			for(iCols = 1;iCols <= iDedColCount; iCols +=2){
				strTemp = (String)vDedCols.elementAt(iCols);
			%>			
      <td rowspan="2" align="center" valign="bottom" class="thinborderBOTTOM"><%=strTemp%></td>
			<%}%>
      <td width="4%" rowspan="2" align="center" valign="bottom" class="thinborderBOTTOM">OTHER DED. </td>
      <td width="5%" rowspan="2" align="center" valign="bottom" class="thinborderBOTTOM">NET 
          PAY</td>
    </tr>
    <tr> 
      <td width="3%" height="17" align="center" valign="bottom" class="thinborderBOTTOM"><br>
HRS</td>
      <td width="4%" height="17" align="center" valign="bottom" class="thinborderBOTTOM">AMT</td>
      <td width="3%" align="center" valign="bottom" class="thinborderBOTTOM">Hours Worked </td>
      <td width="4%" align="center" valign="bottom" class="thinborderBOTTOM">AMT</td>
			<%if(WI.fillTextValue("employee_category").equals("1")){%>
      <td width="2%" align="center" valign="bottom" class="thinborderBOTTOM">Rate</td>
      <td width="2%" align="center" valign="bottom" class="thinborderBOTTOM">Amount</td>
			<%}%>
    </tr>
	  <% 
		for(iCount = 1;iNumRec < vRows.size(); iNumRec += iFieldCount, ++iCount){
	  dLineTotal = 0d;		
		dOtherDed = 0d;
		dTempHours = 0d;
		i = iNumRec;
		strUserIndex = (String)vRows.elementAt(i+1);
		vEarnings = (Vector)vRows.elementAt(i+53);
		vDeductions = (Vector)vRows.elementAt(i+54);
		vSalDetail = (Vector)vRows.elementAt(i+55); 
		vOTDetail = (Vector)vRows.elementAt(i+56);
		vEarnDed  = (Vector)vRows.elementAt(i+59);
		vLateUtDetail= (Vector)vRows.elementAt(i+64);
		
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	  %>
			
    <tr> 
      <td height="20" valign="bottom" class="thinbordeRIGHT"><strong><%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
							(String)vRows.elementAt(i+6), 4)%></strong></td>
			<!--
      <%
	  	//basic monthly
			//	strTemp2 = "";
			//	if(vSalDetail != null && vSalDetail.size() > 0)
			//		strTemp2 = (String)vSalDetail.elementAt(7); 			
  	  %>
      <td align="right" valign="bottom" class="NoBorder"><%//=strTemp2%>&nbsp;</td>
			-->
      <%
				// period rate
					dLineTotal = Double.parseDouble((String)vRows.elementAt(i + 7));

				// add the faculty salary
				dLineTotal += Double.parseDouble(WI.getStrValue((String)vRows.elementAt(i + 30),"0"));
				dTotalBasic += dLineTotal;
			%>			
      <td align="right" valign="bottom" class="thinbordeRIGHT"><%=CommonUtil.formatFloat(dLineTotal,true)%></td>
      <%
	  	//rate per hour
				strHourlyRate = "";
				if(vSalDetail != null && vSalDetail.size() > 0)
					strHourlyRate = (String)vSalDetail.elementAt(5); 			
  	  %>
      <td align="right" valign="bottom" class="thinbordeRIGHT">&nbsp;
        <%=strHourlyRate%></td>
			<%
				// number of days absent (AWOL)
				//strTemp = (String)vRows.elementAt(i + 61); 			
				///dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
			dTemp = 0d;
			
			// leave days
			//strTemp = (String)vRows.elementAt(i + 11); // day with pay
			//dTemp = Double.parseDouble(strTemp);
			strTemp = (String)vRows.elementAt(i + 12); // day without pay
			dTemp = Double.parseDouble(strTemp);
			dTemp = dTemp * 8;
 			/*
			if(vAWOL != null && vAWOL.size() > 0){
				iIndex = vAWOL.indexOf(strUserIndex);
				if(iIndex != -1){
					dTemp = ((Double)vAWOL.remove(iIndex+1)).doubleValue();
					vAWOL.remove(iIndex);
				}
			}
			*/
			
			strTemp = (String)vRows.elementAt(i + 66); // hours_awol
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
			//if(dTemp == 0d)
			//	strTemp = "";
				
			strTemp2 = "";
			if(vLateUtDetail != null && vLateUtDetail.size() > 0){
				strTemp = (String)vLateUtDetail.elementAt(4);
				dTemp += Double.parseDouble(strTemp)/60;
			}
			strTemp2 = CommonUtil.formatFloat(dTemp,false);
			if(dTemp == 0d)
				strTemp2 = "";
		%>  					
      <td align="right" valign="bottom" class="thinbordeRIGHT"><%=WI.getStrValue(strTemp2,"<br>","","")%>&nbsp;</td>
      <%			
			dTemp = 0d;
	
			// late_under_amt
			strTemp = (String)vRows.elementAt(i + 48); 			
 			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
			
			// faculty absences
			strTemp = (String)vRows.elementAt(i + 49); 			
			strTemp = ConversionTable.replaceString(strTemp,",","");					
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
			
			// leave_deduction_amt
			strTemp = (String)vRows.elementAt(i + 33); 			
 			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
	
			// AWOL // i dont know if theres an awol anyway
			strTemp = (String)vRows.elementAt(i + 47); 			
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

			strTemp = CommonUtil.formatFloat(dTemp,true);
			
			dLineTotal -= dTemp;
			dTotalAbsences += dTemp;
			if(dTemp == 0d)
				strTemp = "";
			%>
      <td align="right" valign="bottom" class="thinbordeRIGHT"><%=strTemp%>&nbsp;</td>
      <%
				// hours worked
				strTemp = (String)vRows.elementAt(i + 8);  	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
				strTemp = CommonUtil.formatFloat(dTemp,false);
							
				if(dTemp == 0d)
					strTemp = "";
			%>			
      <td align="right" valign="bottom" class="thinbordeRIGHT"><%=strTemp%>&nbsp;</td>
			<%
			dTotalNetBasic += dLineTotal;
			%>			
      <td align="right" valign="bottom" class="thinbordeRIGHT"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
      <%
	  	// ot rate based on the regular working days		
//	  	if (vRows.elementAt(i+34) != null)	
//				strTemp = (String) vRows.elementAt(i+34); 			
//			else
				dTemp = Double.parseDouble(WI.getStrValue(strHourlyRate,"0"));
				dTemp = 1.25 * dTemp;
				strTemp = CommonUtil.formatFloat(dTemp,2);
				if(dTemp == 0d)
					strTemp = "";
			%>
      <td align="right" valign="bottom" class="thinbordeRIGHT"><%=strTemp%>&nbsp;</td>
		<%
			// OVERTIME amount
			strTemp = (String)vRows.elementAt(i + 23);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			dTotalOT += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%>   
      <td align="right" valign="bottom" class="thinbordeRIGHT"><%=strTemp%>&nbsp;</td>
 		<%
			// moved to other income
			// COLA amount
			%> 		
			<%if(WI.fillTextValue("employee_category").equals("1")){%>
      <%
	  	//rate per hour
				strTemp = "";
				if(vSalDetail != null && vSalDetail.size() > 0)
					strTemp = (String)vSalDetail.elementAt(3);
  	  %>			
      <td align="right" valign="bottom" class="thinbordeRIGHT"><%=strTemp%></td>
	 		<%
			// overload
			strTemp = (String)vRows.elementAt(i + 22);  	
			dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
			
			dLineTotal += dTemp;
			dTotalOverload += dTemp;
			strTemp = CommonUtil.formatFloat(dTemp,true);

			if(dTemp == 0d)
				strTemp = "";
			%> 					
			<td align="right" valign="bottom" class="thinbordeRIGHT"><%=strTemp%>&nbsp;</td>
			<%}%>
		<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
			strTemp = (String)vEarnings.elementAt(iCols);			
			dTemp = Double.parseDouble(strTemp);
			dLineTotal += dTemp;
			adEarningTotal[iCols - 2] = adEarningTotal[iCols - 2] + dTemp;
			
			if(dTemp == 0d)
				strTemp = "";			
		%>          
      <td align="right" valign="bottom" class="thinbordeRIGHT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
			<%}%>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){
				strTemp = (String)vEarnDed.elementAt(iCols);			
				dTemp = Double.parseDouble(strTemp);
				dLineTotal -= dTemp;
				adEarnDedTotal[iCols-1] = adEarnDedTotal[iCols-1] + dTemp;				
				if(strTemp.equals("0"))
					strTemp = "";			
			%>			
      <td align="right" valign="bottom" class="thinbordeRIGHT"><%=WI.getStrValue(strTemp,"")%></td>
			<%}%>					
      <%		
			
			if(vEarnings != null){
				// subject allowances 
				strTemp = (String)vEarnings.elementAt(0); 
				if (strTemp.length() > 0){
					dOtherEarn = Double.parseDouble(strTemp);
				}
				// ungrouped earnings.
				strTemp = (String)vEarnings.elementAt(1); 
				if (strTemp.length() > 0){
					dOtherEarn += Double.parseDouble(strTemp);
				}				
			}			
	  	
			// adjustment amount
	  if (vRows.elementAt(i+51) != null){	
			strTemp = (String)vRows.elementAt(i+51); 
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
		}

		// holiday_pay_amt
		if (vRows.elementAt(i+26) != null){	
			strTemp = (String)vRows.elementAt(i+26); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dOtherEarn += Double.parseDouble(strTemp);
			}
		}
		
		// overload
		//if (vRows.elementAt(i+22) != null){	
		//	strTemp = (String)vRows.elementAt(i+22); 
		//	strTemp = ConversionTable.replaceString(strTemp,",","");
		//	if (strTemp.length() > 0){
		//		dOtherEarn += Double.parseDouble(strTemp);
		//	}
		//}
		
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
		
		// COLA
		strTemp = (String)vRows.elementAt(i + 25);  	
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));		
		dOtherEarn += dTemp;
		
		dTotalOtherEarn += dOtherEarn;
		dLineTotal += dOtherEarn;
		strTemp = CommonUtil.formatFloat(dOtherEarn,2);
		if(dOtherEarn == 0d)
			strTemp = "";
	  %>			
			<td align="right" valign="bottom" class="thinbordeRIGHT"><%=strTemp%>&nbsp;</td>
      <%
	  	dTotalGross += dLineTotal;
	  %>
      <td align="right" valign="bottom" class="thinbordeRIGHT"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
      <%
				// tax withheld
				strTemp = (String)vRows.elementAt(i + 46);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);														
				dLineTotal -= dTemp;
				dTotalTax += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>   		
      <td align="right" valign="bottom" class="thinbordeRIGHT"><%=strTemp%>&nbsp;</td>
      <%
				// sss contribution
				strTemp = (String)vRows.elementAt(i + 39);			
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dLineTotal -= dTemp;
				dTotalSSS += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>			
      <td align="right" valign="bottom" class="thinbordeRIGHT"><%=strTemp%>&nbsp;</td>     
      <%
				// philhealth
				strTemp = (String)vRows.elementAt(i + 40);				
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dLineTotal -= dTemp;
				dTotalPhealth += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
			%>			
      <td align="right" valign="bottom" class="thinbordeRIGHT"><%=strTemp%>&nbsp;</td>
      <%
				// pag ibig
				strTemp = (String)vRows.elementAt(i +41);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));					
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dLineTotal -= dTemp;
				dTotalHdmf +=dTemp;		
				if(dTemp == 0d)
					strTemp = "--";
			%>			
      <td align="right" valign="bottom" class="thinbordeRIGHT"><%=strTemp%>&nbsp;</td>
			<%for(iCols = 1;iCols <= iDedColCount/2; iCols++){
				strTemp = (String)vDeductions.elementAt(iCols);
				dTemp = Double.parseDouble(strTemp);
				adDeductTotal[iCols-1] = adDeductTotal[iCols-1] + dTemp;					
				dLineTotal -= dTemp;
				if(dTemp == 0d)
					strTemp = "";			
			%>  			
      <td align="right" valign="bottom" class="thinbordeRIGHT"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
			<%}%>
      <%
			// this is the other ungrouped deductions
			strTemp = (String)vDeductions.elementAt(0);
			dTemp = Double.parseDouble(strTemp);
			dOtherDed += dTemp;
			
			// misc_deduction
			strTemp = (String)vRows.elementAt(i + 45); 
			strTemp = WI.getStrValue(strTemp,"0");
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dOtherDed += Double.parseDouble(strTemp);				

			dTotalOtherDed += dOtherDed;
			dLineTotal -= dOtherDed;
			strTemp = CommonUtil.formatFloat(dOtherDed,true);
			if(dOtherDed == 0d)
				strTemp = "";
	  %>				
      <td align="right" valign="bottom" class="thinbordeRIGHT"><%=strTemp%>&nbsp;</td>
      <%
	  dTotalNetPay += dLineTotal;
	  %>
      <td align="right" valign="bottom" class="thinbordeRIGHT"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
    <%}//end for loop%>
		<%if(iNumRec >= vRows.size()){%>
    <tr> 
      <td height="28"><div align="right"><font size="1"><strong>GRAND TOTAL :   </strong></font></div></td>
      <!--
			<td align="right" class="thinborderTOP">&nbsp;</td>
			-->
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalBasic,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalAbsences,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalNetBasic,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalOT,true)%>&nbsp;</td>
      <%if(WI.fillTextValue("employee_category").equals("1")){%>
			<td align="right" class="thinborderTOP">&nbsp;</td>
			<td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalOverload,true)%>&nbsp;</td>
			<%}%>
  		<%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){%> 
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(adEarningTotal[iCols - 2],true)%></td>
      <%}%>
  		<%for(iCols = 1;iCols <= iEarnDedCount; iCols++){%> 
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(adEarnDedTotal[iCols-1],true)%></td>
      <%}%>					
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalOtherEarn,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalGross,true)%>&nbsp;</td>      
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalTax,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalSSS,true)%>&nbsp;</td>
			<td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalPhealth,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalHdmf,true)%>&nbsp;</td>
      <%for(iCols = 1;iCols <= (iDedColCount/2); iCols ++){
				//adGDeductTotal[iCols] += adDeductTotal[iCols];	
			%> 
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(adDeductTotal[iCols-1],true)%>&nbsp;</td>
			<%}%>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalOtherDed,true)%>&nbsp;</td>
      <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalNetPay,true)%>&nbsp;</td>
    </tr>
		<%}else{%>
    <tr>
      <td height="15">&nbsp;</td>
      <!--
			<td align="right" class="thinborderTOP">&nbsp;</td>
			-->
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <%if(WI.fillTextValue("employee_category").equals("1")){%>
			<td align="right" class="thinborderTOP">&nbsp;</td>
			<td align="right" class="thinborderTOP">&nbsp;</td>
			<%}%>
      <%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){%> 
			<td align="right" class="thinborderTOP">&nbsp;</td>
			<%}%>
			<%for(iCols = 1;iCols <= iEarnDedCount; iCols++){%> 
      <td align="right" class="thinborderTOP">&nbsp;</td>
			<%}%>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
			<%for(iCols = 1;iCols <= (iDedColCount/2); iCols ++){%>
      <td align="right" class="thinborderTOP">&nbsp;</td>
			<%}%>
      <td align="right" class="thinborderTOP">&nbsp;</td>
      <td align="right" class="thinborderTOP">&nbsp;</td>
    </tr>
		<%}%>
  </table>  
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="18" class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
    </tr>		
    <tr> 
      <td width="22%" height="18" class="NoBorder">Prepared by: </td>
      <td width="5%" class="NoBorder">&nbsp;</td>
      <td width="35%" class="NoBorder">Reviewed by: </td>
      <td width="3%" class="NoBorder">&nbsp;</td>
      <td width="35%" class="NoBorder">Noted by: </td>
    </tr>
    <tr>
      <td height="18" class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
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
      <td class="NoBorder"><font size="1"><strong>&nbsp;<%=(WI.getStrValue(strTemp)).toUpperCase()%></strong></font></td>
      <td class="NoBorder">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("noted_by");
			%>			
      <td class="NoBorder"><font size="1"><strong>&nbsp;<%=(WI.getStrValue(strTemp)).toUpperCase()%></strong></font></td>
    </tr>
    <tr>
      <td height="18" class="NoBorder">Personnel/ Payroll Officer </td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">Assistant for Administrative Affairs </td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">Dean</td>
    </tr>
  </table>	
  <%if (iNumRec < vRows.size()){%>
  <DIV style="page-break-before:always">&nbsp;</Div>
  <% }//page break ony if it is not last page.
	  } //end for (iNumRec < vRows.size()
  } //end end upper most if (vRows !=null)%>	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>