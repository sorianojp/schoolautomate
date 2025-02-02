<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn, payroll.PReDTRME" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Sheet/Register Printing</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TABLE.thinborder {
    border-top: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
     }
		TD.thinborderLEFT {  
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
    }

	TD.thinborderBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
    }
	TD.thinborderBOTTOMLEFTDashed {
    border-bottom: solid 1px #000000;    
			border-left: dashed 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }		
    TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
    }
 
    TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
    }	

    TD.thinborderTOP {
    border-top: solid 1px #000000;		
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
    }
		
    TD.thinborderTOPLEFTDashed {
    border-top: solid 1px #000000;
		border-left: dashed 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.thinborderBOTTOMTOPLEFTDashed {
    border-top: solid 1px #000000;
		border-bottom: solid 1px #000000;
		border-left: dashed 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
    }
	
	TD.thinborderTOPLEFT {
    border-left: solid 1px #000000;
		border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
    }
	TD.thinborderTOPLEFTRIGHT {
    border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
    }
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>


<%
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
	String strTemp2 = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-payrollsheet","payroll_sheet_auf.jsp");
								
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
														"PAYROLL","REPORTS",request.getRemoteAddr(),
														"payroll_sheet_auf.jsp");
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
	ReportPayrollExtn RptPay = new ReportPayrollExtn(request);
	String strPayrollPeriod  = null;
	boolean bolPageBreak = false;

	double dBasic = 0d;
	double dLessTemp = 0d;
	double dTotalAbsences = 0d;
	double dLineTotal = 0d;
	double dTotalDeduction = 0d;
	double dTemp = 0d;
	double dTemp2 = 0d;
	double dTemp3 = 0d;
	double dTemp4= 0d;
	double dTemp5 = 0d;	
	double dNetPay = 0d;
	double dNetPay2 = 0d;
	
	// these here are used for the total... daghan kaayo 
	double dBasicTotal = 0d;
	double dAdminTotal = 0d;
	double dSumAdmin = 0d;
	double dLessAdmin = 0d;	
	
	double dRiceTotal = 0d;
	double dSumRice = 0d;
	double dLessRice = 0d;
		
	double dEarnings = 0d;
	double dSumEarnings = 0d;
	double dLessEarnings = 0d;	

	double dHonorTotal = 0d;
	double dIncentiveTot = 0d;
	double dCashIncTot = 0d;
	double dOverPBTot = 0d;
	double dUnderPBTot = 0d; 
	double dAGDTot = 0d;
	double dPerfBonusTot = 0d;
	double dRetroTot = 0d;
	double dTeachIncTot = 0d;
	double dOtherEarnTot = 0d; 
	double dOverPayTot = 0d;
	double dUnderPayTot = 0d;
	double dRefundNTTot = 0d;
	double dRefTaxableTot = 0d;
	double dUnderEarnTot = 0d;
	double dExtServiceTot = 0d;
	double dHolidayTot = 0d;
	double dOTTotal = 0d;
	double dOverEarnTot = 0d;
	double dPagibigTot = 0d;
	double dRetPremTot = 0d;
	double dSSSTotal = 0d;
	double dPHICTotal = 0d;
	double dWTPTotal = 0d; 
	double dPbigLoanTot = 0d;
	double dCCITot = 0d; 
	double dPSBLoanTot = 0d; 
	double dHousingTot = 0d;
	double dSalaryTot = 0d;
	double dBkStoreTot = 0d;
	double dCashAdvTot = 0d;
	double dCAPTotal = 0d; 
	double dDentalTot = 0d;
	double dTogaTotal = 0d; 
	double dHospTotal = 0d; 
	double dAUFHPTot = 0d;
	double dOthersDedTot = 0d;
	double dIntlHouseTot = 0d;
	double dPeraaLoanTot = 0d;	
	double dCanteenTot = 0d;	
	double dTelTotal = 0d;
	double dTuitionTot = 0d; 
	double dUniformTot = 0d; 
	double dPageTotDed  = 0d;
	double dNetpay1Tot = 0d;
	double dNetpay2Tot = 0d;
	double dPageNetTot = 0d;			

	// these here are used for the total... daghan kaayo 
	double dGBasicTotal = 0d;
	double dGAdminTotal = 0d;
	double dGSumAdmin = 0d;
	double dGLessAdmin = 0d;
	
	double dGRiceTotal = 0d;
	double dGSumRice = 0d;
	double dGLessRice = 0d;
	
	double dGEarnings = 0d;
	double dGSumEarnings = 0d;
	double dGLessEarnings = 0d;
	
	double dGHonorTotal = 0d;
	double dGIncentiveTot = 0d;
	double dGCashIncTot = 0d;
	double dGOverPBTot = 0d;
	double dGUnderPBTot = 0d; 
	double dGAGDTot = 0d;
	double dGPerfBonusTot = 0d;
	double dGRetroTot = 0d;
	double dGTeachIncTot = 0d;
	double dGOtherEarnTot = 0d; 
	double dGOverPayTot = 0d;
	double dGUnderPayTot = 0d;
	double dGRefundNTTot = 0d;
	double dGRefTaxableTot = 0d;
	double dGUnderEarnTot = 0d;
	double dGExtServiceTot = 0d;
	double dGHolidayTot = 0d;
	double dGOTTotal = 0d;
	double dGOverEarnTot = 0d;
	double dGPagibigTot = 0d;
	double dGRetPremTot = 0d;
	double dGSSSTotal = 0d;
	double dGPHICTotal = 0d;
	double dGWTPTotal = 0d; 
	double dGPbigLoanTot = 0d;
	double dGCCITot = 0d; 
	double dGPSBLoanTot = 0d; 
	double dGHousingTot = 0d;
	double dGSalaryTot = 0d;
	double dGBkStoreTot = 0d;
	double dGCashAdvTot = 0d;
	double dGCAPTotal = 0d; 
	double dGDentalTot = 0d;
	double dGTogaTotal = 0d; 
	double dGHospTotal = 0d; 
	double dGAUFHPTot = 0d;
	double dGOthersDedTot = 0d;
	double dGIntlHouseTot = 0d;
	double dGPeraaLoanTot = 0d;	
	double dGCanteenTot = 0d;	
	double dGTelTotal = 0d;
	double dGTuitionTot = 0d; 
	double dGUniformTot = 0d; 
	double dGrandTotDed  = 0d;
	double dGNetpay1Tot = 0d;
	double dGNetpay2Tot = 0d;
	double dGrandNet = 0d;			
	int i = 0; 
	int iPay = 0;
	int iDivider = 0;	
	int iIndexOf = 0;
	Vector vPeriods = null;
	Vector vEarnings = null;
	Vector vRiceSubsidy = null;
	Vector vOtherEarn = null;
	
	vRetResult = RptPay.generateMasterList(dbOP);

	vEarnings = RptPay.getEmpEarnings(dbOP, WI.fillTextValue("sal_period_index"));
	vRiceSubsidy = RptPay.getRiceSubsidy(dbOP, WI.fillTextValue("sal_period_index"));
	vOtherEarn = RptPay.getOtherEarnings(dbOP, WI.fillTextValue("sal_period_index"));	
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriod(dbOP, request, 4);
	vPeriods = RptPay.getMonthlyPeriods(dbOP);
	if(vPeriods != null && vPeriods.size() > 0)
		iDivider = vPeriods.size()/9;
	//iDivider = RptPay.getPeriodCount(dbOP, request);
	double[] aiNetpay = null;
	double[] aiGrandNetpay = new double[iDivider];
	
	strTemp = WI.fillTextValue("sal_period_index");
	for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 6) {
	if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
	  strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
	  }
	 }

	if (vRetResult != null) {
		
		int iPage = 1; 
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"5"));
			

		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iTotalPages = vRetResult.size()/(69*iMaxRecPerPage);	
	  if((vRetResult.size() % (69*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){	   
	 aiNetpay = new double[iDivider];	   
	 dBasicTotal = 0d;
	 dAdminTotal = 0d;
	 dRiceTotal = 0d;
	 dEarnings = 0d;
	 
	 dSumAdmin = 0d;
	 dLessAdmin = 0d;
	 dSumRice = 0d;
	 dLessRice = 0d;
	 dSumEarnings = 0d;
	 dLessEarnings = 0d; 
	 
	 dHonorTotal = 0d;
	 dIncentiveTot = 0d;
	 dCashIncTot = 0d;
	 dOverPBTot = 0d;
	 dUnderPBTot = 0d; 
	 dAGDTot = 0d;
	 dPerfBonusTot = 0d;
	 dRetroTot = 0d;
	 dTeachIncTot = 0d;
	 dOtherEarnTot = 0d; 
	 dOverPayTot = 0d;
	 dUnderPayTot = 0d;
	 dRefundNTTot = 0d;
	 dRefTaxableTot = 0d;
	 dUnderEarnTot = 0d;
	 dExtServiceTot = 0d;
	 dHolidayTot = 0d;
	 dOTTotal = 0d;
	 dOverEarnTot = 0d;
	 dPagibigTot = 0d;
	 dRetPremTot = 0d;
	 dSSSTotal = 0d;
	 dPHICTotal = 0d;
	 dWTPTotal = 0d; 
	 dPbigLoanTot = 0d;
	 dCCITot = 0d; 
	 dPSBLoanTot = 0d; 
	 dHousingTot = 0d;
	 dSalaryTot = 0d;
	 dBkStoreTot = 0d;
	 dCashAdvTot = 0d;
	 dCAPTotal = 0d; 
	 dDentalTot = 0d;
	 dTogaTotal = 0d; 
	 dHospTotal = 0d; 
	 dAUFHPTot = 0d;
	 dOthersDedTot = 0d;
	 dIntlHouseTot = 0d;
	 dPeraaLoanTot = 0d;	
	 dCanteenTot = 0d;	
	 dTelTotal = 0d;
	 dTuitionTot = 0d; 
	 dUniformTot = 0d; 
	 dPageTotDed  = 0d;
	 dNetpay1Tot = 0d;
	 dNetpay2Tot = 0d;
	 dPageNetTot = 0d;	 
	 dTotalDeduction = 0d;
%>
<body onLoad="javascript:window.print()">
<form name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="91%" height="18">Angeles University Foundation </td>
    </tr>
    <tr>
      <td>PAYROLL LEDGER </td>
    </tr>
    <tr> 
      <td>For the Pay Period :<%=WI.getStrValue(strPayrollPeriod,"")%></td>
    </tr>
    <tr>
      <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="6%">&nbsp;</td>
          <td width="16%">&nbsp;</td>
          <td width="9%" class="thinborderBOTTOM">&nbsp;</td>
          <td width="9%">&nbsp;</td>
          <td width="10%" class="thinborderBOTTOM">&nbsp;</td>
          <td width="7%">&nbsp;</td>
          <td width="9%" class="thinborderBOTTOM">&nbsp;</td>
          <td width="34%">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="2" class="NoBorder"><%=WI.fillTextValue("college_name")%> <%=WI.getStrValue(WI.fillTextValue("dept_name"),"(",")","")%></td>
          <td class="NoBorder">Prepared by: </td>
          <td>&nbsp;</td>
          <td class="NoBorder">Checked by : </td>
          <td>&nbsp;</td>
          <td class="NoBorder">Verified by: </td>
          <td>&nbsp;</td>
        </tr>
      </table></td>
    </tr>
</table>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td height="19" valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td colspan="3" valign="bottom" class="thinborderTOPLEFT"><div align="center">OTHER EARNINGS </div></td>
      <td valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td valign="bottom" class="thinborderTOPLEFT"><div align="center">PREMIUM</div></td>
      <td valign="bottom" class="thinborderTOPLEFT"><div align="center">LOANS</div></td>
      <td colspan="3" valign="bottom" class="thinborderTOPLEFT"><div align="center">OTHER DEDUCTIONS </div></td>
      <td valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td valign="bottom" class="thinborderTOPLEFT">&nbsp;</td>
      <td valign="bottom" class="thinborderTOPLEFTRIGHT">&nbsp;</td>
    </tr>
    <tr>
      <td width="3%" valign="bottom" class="thinborderBOTTOMLEFT">&nbsp;</td> 
      <td width="13%" height="33" align="center" valign="bottom" class="thinborderBOTTOMLEFT">NAME OF EMPLOYEE </td>
      <td width="4%" align="center" valign="bottom" class="thinborderBOTTOMLEFT">BASIC</td>
      <td width="5%" align="center" valign="bottom" class="thinborderBOTTOMLEFT">Basic<br>
        Less<br>
        (Abs/UT/L)<br>
        ------------<br>
      Basic</td>
      <td width="5%" align="center" valign="bottom" class="thinborderBOTTOMLEFT">Adm/Pos<br>
      Less<br>
      (Abs/UT/L)<br>
      ------------<br>
      Net Admin </td>
      <td width="5%" align="center" valign="bottom" class="thinborderBOTTOMLEFT">Rice Subs<br>
      Less<br>
      (Abs/UT/L)<br>
      ------------<br>      &nbsp;</td>
      <td width="5%" align="center" valign="bottom" class="thinborderBOTTOMLEFT">Othr Erngs<br>
        Less<br>
        (Abs/UT/L)<br> 
      ------------<br>
Net earnings </td>
      <td width="5%" valign="bottom" class="thinborderBOTTOMLEFT">a. Honor<br>
        b. Incentive<br>
        c. Cash I<br>
        d. OP PB<br>
        e. UP PB      </td>
      <td width="5%" valign="bottom" class="thinborderBOTTOMLEFT">
        f. AGD<br>
        g. Perf Bonus<br>
        h. Retro<br>
        i.Tchng Inc<br>
      j. Others        </td>
      <td width="5%" valign="bottom" class="thinborderBOTTOMLEFT">k. Over Pay<br>
        l. Und Pay<br>
        m. Refund NT<br>
        n. Refund T<br>
        o. UP Earn</td>
      <td width="5%" valign="bottom" class="thinborderBOTTOMLEFT">p. Ext Ser<br>
        q. Sn.Hol<br>
        r. Reg OT<br>
        s. OP Earn GROSS</td>
      <td width="5%" valign="bottom" class="thinborderBOTTOMLEFT">a. Pagibig<br>
        b. Ret Prem<br>
        c. SSS<br>
        d. Philhealth<br>
        e. WTP <br>        <br>      </td>
      <td width="5%" valign="bottom" class="thinborderBOTTOMLEFT">
        a. pl Loan <br>
        b. PSB Loan <br>
        c. Housing<br>
      d. Salary</td>
      <td width="5%" valign="bottom" class="thinborderBOTTOMLEFT">****<br>
        a. BkStore<br>
        b. Cash Ad <br>
        d. Dental</td>
      <td width="5%" valign="bottom" class="thinborderBOTTOMLEFT">e. TOGA<br>
        f. Hospital<br>
        g. AUFHP<br>
        h. Others<br>
        i. IH</td>
      <td width="5%" valign="bottom" class="thinborderBOTTOMLEFT">j. CCI<br>
        k. Canteen<br>
        l. Tel Bill<br>
        m. Tuition<br>
        n. Uniform</td>
      <td width="5%" align="center" valign="bottom" class="thinborderBOTTOMLEFT">Total Deduction </td>
			<%
			strTemp = null;
			for(iPay = 0;iPay < iDivider;iPay++){
				if(strTemp == null)
					strTemp = "Netpay" + (iPay+1);
				else
					strTemp += "<br>Netpay" + (iPay+1);
			}%>
      <td width="5%" align="center" valign="bottom" class="thinborderBOTTOMLEFT"><%=strTemp%></td>
      <td width="5%" align="center" valign="bottom" class="thinborderBOTTOMLEFTRIGHT">NET 
          PAY</td>
    </tr>
    
    <%  int iStart = 30;
		for(iCount = 1;iNumRec<vRetResult.size(); iNumRec+=74,++iIncr, ++iCount){
		dLineTotal = 0d;
		dBasic = 0d;
	    dTotalDeduction = 0d;
		dLessTemp = 0d;
		
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>	
    <tr>
			<%
				strTemp = (String)vRetResult.elementAt(i+29);
			%>
      <td valign="bottom" class="thinborderBOTTOMLEFT">&nbsp;<%=strTemp%></td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+40));
				strTemp += "<br>" + WI.getStrValue((String)vRetResult.elementAt(i+iStart+41));
				strTemp += "<br>" + WI.getStrValue((String)vRetResult.elementAt(i+iStart+42));
				strTemp += "<br>" + WI.getStrValue((String)vRetResult.elementAt(i+iStart+43)) + "<br>";
			%>			
      <td height="32" valign="bottom" class="thinborderBOTTOMLEFTDashed"><%=strTemp%><strong><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4)%></strong></td>
      <%		
	  	// basic monthly
		strTemp = (String) vRetResult.elementAt(i+5); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		if (strTemp.length() > 0){
			dBasic = Double.parseDouble(strTemp);
			dLineTotal += dBasic;
			dBasicTotal += dBasic;
		}		
	  %>
      <td align="right" valign="bottom" class="thinborderBOTTOMLEFTDashed"><%=CommonUtil.formatFloat(dBasic,true)%></td> 
      <%
	  	dTemp = 0d;
		// late_under_amt
		if (vRetResult.elementAt(i+18) != null){	
			strTemp = (String)vRetResult.elementAt(i+18); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dLessTemp += Double.parseDouble(strTemp);
			}
		}
		
		//faculty_absence
	  	if (vRetResult.elementAt(i+19) != null){	
			strTemp = (String)vRetResult.elementAt(i+19); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dLessTemp += Double.parseDouble(strTemp);
			}
		}
		
		//leave_deduction_amt
	  	if (vRetResult.elementAt(i+20) != null){	
			strTemp = (String)vRetResult.elementAt(i+20); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dLessTemp += Double.parseDouble(strTemp);
			}
		}
		
		//awol_amt
	  	if (vRetResult.elementAt(i+21) != null){	
			strTemp = (String)vRetResult.elementAt(i+21); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dLessTemp += Double.parseDouble(strTemp);
			}
		}

		dTotalAbsences += dLessTemp;
		dLineTotal -= dLessTemp;		
	  %>	       
      <td align="right" valign="bottom" class="thinborderBOTTOMLEFTDashed"><%=CommonUtil.formatFloat(dBasic,true)%>&nbsp;<br>
        <%=CommonUtil.formatFloat(dLessTemp,true)%>&nbsp;<br>
      <%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
      <%
									// dTemp for the actual released
		dTemp2 = 0d; // for the original amount set
		dTemp3 = 0d; // for the difference between actual released and the orig
		iIndexOf = vEarnings.indexOf((Long)vRetResult.elementAt(i+1));
	  if(iIndexOf != -1){
			vEarnings.remove(iIndexOf);
			dTemp2 = Double.parseDouble((String)vEarnings.remove(iIndexOf));
		}
		
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
		if(dTemp2 > 0d)
			strTemp2 = CommonUtil.formatFloat(dTemp2,true);
		else
			strTemp2 = "";
		
		dTemp3 = dTemp2 - dTemp;
		strTemp2 += "<br>";
		if(dTemp3 > 0d)
			strTemp2 += CommonUtil.formatFloat(dTemp3,true);
		else
			strTemp2 += "";
		strTemp2 += "<br>" + CommonUtil.formatFloat(dTemp,true);
		
		dLineTotal += dTemp;
		dAdminTotal += dTemp;
		dSumAdmin += dTemp2;
		dLessAdmin += dTemp3;		
	  %>  
      <td align="right" valign="bottom" class="thinborderBOTTOMLEFTDashed"><%=strTemp2%></td>      
	  <%
		dTemp2 = 0d;
		dTemp3 = 0d;
		iIndexOf = vRiceSubsidy.indexOf((Long)vRetResult.elementAt(i+1));
	  if(iIndexOf != -1){
			vRiceSubsidy.remove(iIndexOf);
			dTemp2 = Double.parseDouble((String)vRiceSubsidy.remove(iIndexOf));
		}
		
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+1),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
		if(dTemp2 > 0d)
			strTemp2 = CommonUtil.formatFloat(dTemp2,true);
		else
			strTemp2 = "";
		
		dTemp3 = dTemp2 - dTemp;
		strTemp2 += "<br>";
		if(dTemp3 > 0d)
			strTemp2 += CommonUtil.formatFloat(dTemp3,true);
		else
			strTemp2 += "";
		strTemp2 += "<br>" + CommonUtil.formatFloat(dTemp,true);
		dLineTotal += dTemp;
		dRiceTotal += dTemp;
		dSumRice += dTemp2;
		dLessRice += dTemp3;
	  %>  
      <td align="right" valign="bottom" class="thinborderBOTTOMLEFTDashed"><%=strTemp2%></td>
	  <%
			dTemp2 = 0d;
			dTemp3 = 0d;
			iIndexOf = vOtherEarn.indexOf((Long)vRetResult.elementAt(i+1));
			if(iIndexOf != -1){
				vOtherEarn.remove(iIndexOf);
				dTemp2 = Double.parseDouble((String)vOtherEarn.remove(iIndexOf));
			}
			
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+ iStart + 38),"0"); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(strTemp);
			if(dTemp2 > 0d)
				strTemp2 = CommonUtil.formatFloat(dTemp2,true);
			else
				strTemp2 = "";
			
			dTemp3 = dTemp2 - dTemp;
			strTemp2 += "<br>";
			if(dTemp3 > 0d)
				strTemp2 += CommonUtil.formatFloat(dTemp3,true);
			else
				strTemp2 += "";
			strTemp2 += "<br>" + CommonUtil.formatFloat(dTemp,true);	
			
		dEarnings += dTemp;
		dSumEarnings += dTemp2;
		dLessEarnings += dTemp3;		
	  %>  
      <td align="right" valign="bottom" class="thinborderBOTTOMLEFTDashed"><%=strTemp2%></td>
	  <%
		strTemp2 = "";
	  	// honorarium
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+2),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
		dLineTotal += dTemp;
		dHonorTotal += dTemp;

		// other incentives
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+6),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp2 = Double.parseDouble(strTemp);
		dLineTotal += dTemp2;
		dIncentiveTot += dTemp2;

		// cash incentive
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+3),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp3 = Double.parseDouble(strTemp);
		dLineTotal += dTemp3;
 		dCashIncTot += dTemp3;

		// overpayment pb
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+7),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp4 = Double.parseDouble(strTemp);				
		dLineTotal -= dTemp4;
		dOverPBTot += dTemp4;

		// under payment pb
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+10),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp5 = Double.parseDouble(strTemp);
		dLineTotal += dTemp5;
		dUnderPBTot += dTemp5;
		
		if(dTemp == 0d && dTemp2 == 0d && dTemp3 == 0d && dTemp4 == 0d && dTemp5 == 0d)
			strTemp2 = "&nbsp;";
		else{
			strTemp2 = CommonUtil.formatFloat(dTemp,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp2,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp3,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp4,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp5,true);
		}
	  %>
      <td align="right" valign="bottom" class="thinborderBOTTOMLEFTDashed"><%=strTemp2%></td>
	  <%
		strTemp2 = "";
	   // agd
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+5),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
		dLineTotal += dTemp;
		dAGDTot += dTemp;

		// performance bonus
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+9),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp2 = Double.parseDouble(strTemp);
		dLineTotal += dTemp2;
		dPerfBonusTot += dTemp2;

		// retroactive  pay
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+11),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp3 = Double.parseDouble(strTemp);
		dLineTotal += dTemp3;
		dRetroTot += dTemp3;

		// teachin incentive
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+4),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp4 = Double.parseDouble(strTemp);				
		dLineTotal += dTemp4;
		dTeachIncTot += dTemp4;

		// others
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+18),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp5 = Double.parseDouble(strTemp);
		dLineTotal += dTemp5;
		dOtherEarnTot += dTemp5;
		
		if(dTemp == 0d && dTemp2 == 0d && dTemp3 == 0d && dTemp4 == 0d && dTemp5 == 0d)
			strTemp2 = "&nbsp;";
		else{
			strTemp2 = CommonUtil.formatFloat(dTemp,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp2,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp3,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp4,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp5,true);
		} 
	  %>		  
      <td align="right" valign="bottom" class="thinborderBOTTOMLEFTDashed"><%=strTemp2%></td>
	  <%
	  	// over payment
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+8),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
		dLineTotal -= dTemp;
 		dOverPayTot += dTemp;
		//under payment
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+12),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp2 = Double.parseDouble(strTemp);
		dLineTotal += dTemp2;
		dUnderPayTot += dTemp2;
		// refund non taxable
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+13),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp3 = Double.parseDouble(strTemp);
		dLineTotal += dTemp3;
		dRefundNTTot += dTemp3;
		// refund taxable
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+14),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp4 = Double.parseDouble(strTemp);				
		dLineTotal += dTemp4;
		dRefTaxableTot += dTemp4;
		// underpayment earnings
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+16),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp5 = Double.parseDouble(strTemp);
		dLineTotal += dTemp5;
		dUnderEarnTot += dTemp5;		

		if(dTemp == 0d && dTemp2 == 0d && dTemp3 == 0d && dTemp4 == 0d && dTemp5 == 0d)
			strTemp2 = "&nbsp;";
		else{
			strTemp2 = CommonUtil.formatFloat(dTemp,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp2,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp3,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp4,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp5,true);
		} 		
	  %>			  
      <td align="right" valign="bottom" class="thinborderBOTTOMLEFTDashed"><%=strTemp2%></td>
	  <%
	  	// extended service
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+17),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
		dLineTotal += dTemp;
		dExtServiceTot += dTemp;
		
		// holiday
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+17),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp2 = Double.parseDouble(strTemp);
		dLineTotal += dTemp2;
		dHolidayTot += dTemp2;

		//Regular OT		
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+16),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp3 = Double.parseDouble(strTemp);
		dLineTotal += dTemp3;
		dOTTotal += dTemp3;

		// OP earning
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+15),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp4 = Double.parseDouble(strTemp);				
		dLineTotal -= dTemp4;
		dOverEarnTot += dTemp4;
		
		if(dTemp == 0d && dTemp2 == 0d && dTemp3 == 0d && dTemp4 == 0d)
			strTemp2 = "&nbsp;";
		else{
			strTemp2 = CommonUtil.formatFloat(dTemp,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp2,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp3,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp4,true);
		} 
		
	  %>		  
      <td align="right" valign="bottom" class="thinborderBOTTOMLEFTDashed"><%=strTemp2%><br>
      <%=CommonUtil.formatFloat(dLineTotal,true)%></td>
	  <%
	  	// pagibig
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+12),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
		dTotalDeduction += dTemp;
		dPagibigTot += dTemp;

		// retirement premium
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+28),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp2 = Double.parseDouble(strTemp);		
		dTotalDeduction += dTemp2;
		dRetPremTot += dTemp2;

		// sss
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+10),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp3 = Double.parseDouble(strTemp);
		dTotalDeduction += dTemp3;
		dSSSTotal += dTemp3;

		// PHIC
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+11),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp4 = Double.parseDouble(strTemp);				
		dTotalDeduction += dTemp4;
		dPHICTotal += dTemp4;

		// WTP
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+13),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp5 = Double.parseDouble(strTemp);				
		dTotalDeduction += dTemp5;
		dWTPTotal += dTemp5;

		if(dTemp == 0d && dTemp2 == 0d && dTemp3 == 0d && dTemp4 == 0d && dTemp5 == 0d)
			strTemp2 = "&nbsp;";
		else{
			strTemp2 = CommonUtil.formatFloat(dTemp,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp2,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp3,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp4,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp5,true);
		} 
	  %>			
      <td align="right" valign="bottom" class="thinborderBOTTOMLEFTDashed"><%=strTemp2%></td>
	  <%
	  	// pl Loan
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+32),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
		dTotalDeduction += dTemp;
		dPbigLoanTot += dTemp;
		
		//// PSB LOan
		//strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+35),"0"); 
		//strTemp = ConversionTable.replaceString(strTemp,",","");
		//dTemp3 = Double.parseDouble(strTemp);
		//dTotalDeduction += dTemp3;
		//dPSBLoanTot += dTemp3;
		
	  	// peraa loan
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+33),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp2 = Double.parseDouble(strTemp);
		dTotalDeduction += dTemp2;
		dPeraaLoanTot += dTemp2;		

		// Housing
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+36),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp3 = Double.parseDouble(strTemp);				
		dTotalDeduction += dTemp3;
		dHousingTot += dTemp3;

		// salary		
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+37),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp4 = Double.parseDouble(strTemp);
		dTotalDeduction += dTemp4;
		dSalaryTot += dTemp4;

		if(dTemp == 0d && dTemp2 == 0d && dTemp3 == 0d && dTemp4 == 0d)
			strTemp2 = "&nbsp;";
		else {
			strTemp2 = CommonUtil.formatFloat(dTemp,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp2,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp3,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp4,true);
		} 
	  %>		  
      <td align="right" valign="bottom" class="thinborderBOTTOMLEFTDashed"><%=strTemp2%></td>
	  <%
	  	// bookstore
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+19),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
		dTotalDeduction += dTemp;
		dBkStoreTot += dTemp;
				
		// cash advance
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+20),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp2 = Double.parseDouble(strTemp);
		dTotalDeduction += dTemp2;
		dCashAdvTot += dTemp2;
		
		//// CAP
		//strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+31),"0"); 
		//strTemp = ConversionTable.replaceString(strTemp,",","");
		//dTemp3 = Double.parseDouble(strTemp);
		//dTotalDeduction += dTemp3;
		//dCAPTotal += dTemp3;
		
		// dental
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+21),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp4 = Double.parseDouble(strTemp);								
		dTotalDeduction += dTemp4;
		dDentalTot += dTemp4;
		
		if(dTemp == 0d && dTemp2 == 0d && dTemp3 == 0d && dTemp4 == 0d)
			strTemp2 = "&nbsp;";
		else{
			strTemp2 = CommonUtil.formatFloat(dTemp,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp2,true) + "<br>";
			//strTemp2 += CommonUtil.formatFloat(dTemp3,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp4,true);
		} 		
	  %>			  
      <td align="right" valign="bottom" class="thinborderBOTTOMLEFTDashed"><%=strTemp2%></td>
	  <%
	  	//toga
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+22),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
		dTotalDeduction += dTemp;
		dTogaTotal += dTemp;
		// hospital
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+23),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp2 = Double.parseDouble(strTemp);
		dTotalDeduction += dTemp2;
		dHospTotal += dTemp2;

		// AUFHP
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+30),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp3 = Double.parseDouble(strTemp);
		dTotalDeduction += dTemp3;
		dAUFHPTot += dTemp3;

		// others;
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+29),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp4 = Double.parseDouble(strTemp);								
		dTotalDeduction += dTemp4;
		dOthersDedTot += dTemp4;

		// IH
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+24),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp5 = Double.parseDouble(strTemp);										
		dTotalDeduction += dTemp5;
		dIntlHouseTot += dTemp5;
		if(dTemp == 0d && dTemp2 == 0d && dTemp3 == 0d && dTemp4 == 0d && dTemp5 == 0d)
			strTemp2 = "&nbsp;";
		else{
			strTemp2 = CommonUtil.formatFloat(dTemp,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp2,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp3,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp4,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp5,true);
		} 		
	  %>		  
      <td align="right" valign="bottom" class="thinborderBOTTOMLEFTDashed"><%=strTemp2%></td>
	  <%

		// CCI
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+34),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
		dTotalDeduction += dTemp;
		dCCITot += dTemp;

		// canteen
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+25),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp2 = Double.parseDouble(strTemp);
		dTotalDeduction += dTemp2;
		dCanteenTot += dTemp2;

		// tel bill
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+26),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp3 = Double.parseDouble(strTemp);
		dTotalDeduction += dTemp3;
		dTelTotal += dTemp3;

		// Tuition
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+27),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp4 = Double.parseDouble(strTemp);								
		dTotalDeduction += dTemp4;
		dTuitionTot += dTemp4;

		// Uniform
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iStart+28),"0"); 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp5 = Double.parseDouble(strTemp);										
		dTotalDeduction += dTemp5;
		dUniformTot += dTemp5;
		dPageTotDed += dTotalDeduction;

		if(dTemp == 0d && dTemp2 == 0d && dTemp3 == 0d && dTemp4 == 0d && dTemp5 == 0d)
			strTemp2 = "&nbsp;";
		else{
			strTemp2 = CommonUtil.formatFloat(dTemp,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp2,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp3,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp4,true) + "<br>";
			strTemp2 += CommonUtil.formatFloat(dTemp5,true);
		} 		
	  %>		  
      <td align="right" valign="bottom" class="thinborderBOTTOMLEFTDashed"><%=strTemp2%></td>
      <td align="right" valign="bottom" class="thinborderBOTTOMLEFTDashed"><%=CommonUtil.formatFloat(dTotalDeduction,true)%></td>
	  <%
	  dNetPay = dLineTotal - dTotalDeduction;
		dNetPay = CommonUtil.formatFloatToCurrency(dNetPay,2);
		strTemp = null;
		
		dPageNetTot +=dNetPay;
		dNetPay2 = dNetPay/iDivider;
		dNetPay2 = CommonUtil.formatFloatToCurrency(dNetPay2,2);
		dTemp = 0d;		
		
		for(iPay = 0;iPay < iDivider;iPay++){
			if(strTemp == null){
				aiNetpay[iPay] = aiNetpay[iPay] + dNetPay2;
				aiGrandNetpay[iPay] = aiGrandNetpay[iPay] + dNetPay2;
				strTemp = "" + CommonUtil.formatFloat(dNetPay2,2);
			}else{				
				if(iPay < iDivider-1){					
					strTemp += "<br>" + CommonUtil.formatFloat(dNetPay2,2);			
				}else{
					dNetPay2 = dNetPay-dTemp;
					strTemp += "<br>" + CommonUtil.formatFloat(dNetPay2,2);
				}
				aiNetpay[iPay] = aiNetpay[iPay] + dNetPay2;
				aiGrandNetpay[iPay] = aiGrandNetpay[iPay] + dNetPay2;
			}
			dTemp = dTemp + dNetPay2;
		}				
		/*dNetPay = dLineTotal - dTotalDeduction;
	  dPageNetTot +=dNetPay;
	  dNetPay2 = dNetPay/2;
	  strTemp = CommonUtil.formatFloat(dNetPay2,true);
	  strTemp = ConversionTable.replaceString(strTemp,",","");
	  dTemp = Double.parseDouble(strTemp);
	  dNetpay1Tot += dTemp;
	  dNetPay2 = dNetPay - dTemp;
	  dNetpay2Tot += dNetPay2;
		*/
	  %>
      <td align="right" valign="bottom" class="thinborderBOTTOMLEFTDashed"><%=strTemp%><br>      </td>
      <td align="right" valign="bottom" class="thinborderBOTTOMLEFTDashed"><%=CommonUtil.formatFloat(dNetPay,true)%></td>
    </tr>
    <tr>
      <td></td>
      <td height="5"></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
	  <td></td>
	  <td></td>
	  <td></td>
	  <td></td>
	  <td></td>
    </tr>
    <%}//end for loop%>
    <tr>
      <td class="thinborderLEFT">&nbsp;</td> 
      <td height="33">PAGE TOTAL</td>
      <td valign="bottom">&nbsp;</td>
      <td valign="bottom">&nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat(dSumAdmin ,true);
				strTemp += "<br>" + CommonUtil.formatFloat(dLessAdmin ,true);
				strTemp += "<br>" + CommonUtil.formatFloat(dAdminTotal ,true);
			%>
      <td align="right" valign="bottom" class="thinborderTOPLEFTDashed"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat(dSumRice  ,true);
				strTemp += "<br>" + CommonUtil.formatFloat(dLessRice  ,true);
				strTemp += "<br>" + CommonUtil.formatFloat(dRiceTotal ,true);
			%>
			<td align="right" valign="bottom" class="thinborderTOPLEFTDashed"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat(dSumEarnings ,true);
				strTemp += "<br>" + CommonUtil.formatFloat(dLessEarnings ,true);
				strTemp += "<br>" + CommonUtil.formatFloat(dEarnings ,true);
			%>
      <td align="right" valign="bottom" class="thinborderTOPLEFTDashed"><%=strTemp%></td>
      <td align="right" valign="bottom" class="thinborderTOPLEFTDashed"><%=CommonUtil.formatFloat(dHonorTotal ,true)%><br>
        <%=CommonUtil.formatFloat(dIncentiveTot ,true)%><br>
        <%=CommonUtil.formatFloat(dCashIncTot ,true)%><br>
        <%=CommonUtil.formatFloat(dOverPBTot ,true)%><br>
      <%=CommonUtil.formatFloat(dUnderPBTot ,true)%></td>
      <td align="right" valign="bottom" class="thinborderTOPLEFTDashed"><%=CommonUtil.formatFloat(dAGDTot ,true)%><br>
        <%=CommonUtil.formatFloat(dPerfBonusTot ,true)%><br>
        <%=CommonUtil.formatFloat(dRetroTot ,true)%><br>
        <%=CommonUtil.formatFloat(dTeachIncTot ,true)%><br>
      <%=CommonUtil.formatFloat(dOtherEarnTot ,true)%></td>
      <td align="right" valign="bottom" class="thinborderTOPLEFTDashed"><%=CommonUtil.formatFloat(dOverPayTot ,true)%><br>
        <%=CommonUtil.formatFloat(dUnderPayTot ,true)%><br>
        <%=CommonUtil.formatFloat(dRefundNTTot ,true)%><br>
        <%=CommonUtil.formatFloat(dRefTaxableTot ,true)%><br>
      <%=CommonUtil.formatFloat(dUnderEarnTot ,true)%></td>
      <td align="right" valign="bottom" class="thinborderTOPLEFTDashed"><%=CommonUtil.formatFloat(dExtServiceTot ,true)%><br>
          <%=CommonUtil.formatFloat(dHolidayTot ,true)%><br>
          <%=CommonUtil.formatFloat(dOTTotal ,true)%><br>
      <%=CommonUtil.formatFloat(dOverEarnTot ,true)%><br>&nbsp;      </td>
      <td align="right" valign="bottom" class="thinborderTOPLEFTDashed"><%=CommonUtil.formatFloat(dPagibigTot ,true)%><br>
        <%=CommonUtil.formatFloat(dRetPremTot ,true)%><br>
        <%=CommonUtil.formatFloat(dSSSTotal ,true)%><br>
        <%=CommonUtil.formatFloat(dPHICTotal ,true)%><br>
      <%=CommonUtil.formatFloat(dWTPTotal ,true)%></td>
      <td align="right" valign="bottom" class="thinborderTOPLEFTDashed"><%=CommonUtil.formatFloat(dPbigLoanTot ,true)%><br>
        <%=CommonUtil.formatFloat(dCCITot ,true)%><br>
        <%=CommonUtil.formatFloat(dPSBLoanTot ,true)%><br>
        <%=CommonUtil.formatFloat(dHousingTot ,true)%><br>
      <%=CommonUtil.formatFloat(dSalaryTot ,true)%></td>
      <td align="right" valign="bottom" class="thinborderTOPLEFTDashed"><br>
        <%=CommonUtil.formatFloat(dBkStoreTot ,true)%><br>
        <%=CommonUtil.formatFloat(dCashAdvTot ,true)%><br>
        <%=CommonUtil.formatFloat(dCAPTotal ,true)%><br>
      <%=CommonUtil.formatFloat(dDentalTot ,true)%></td>
      <td align="right" valign="bottom" class="thinborderTOPLEFTDashed"><%=CommonUtil.formatFloat(dTogaTotal ,true)%><br>
        <%=CommonUtil.formatFloat(dHospTotal ,true)%><br>
        <%=CommonUtil.formatFloat(dAUFHPTot ,true)%><br>
        <%=CommonUtil.formatFloat(dOthersDedTot ,true)%><br>
      <%=CommonUtil.formatFloat(dIntlHouseTot ,true)%></td>
      <td align="right" valign="bottom" class="thinborderTOPLEFTDashed"><%=CommonUtil.formatFloat(dPeraaLoanTot ,true)%><br>
        <%=CommonUtil.formatFloat(dCanteenTot ,true)%><br>
        <%=CommonUtil.formatFloat(dTelTotal ,true)%><br>
        <%=CommonUtil.formatFloat(dTuitionTot ,true)%><br>
      <%=CommonUtil.formatFloat(dUniformTot ,true)%></td>
      <td align="right" valign="bottom" class="thinborderTOPLEFTDashed"><%=CommonUtil.formatFloat(dPageTotDed,true)%></td>
			<%strTemp = null;
			for(iPay = 0;iPay < iDivider;iPay++){				
				if(strTemp == null)
					strTemp = "" + CommonUtil.formatFloat(aiNetpay[iPay],2);
				else
					strTemp += "<br>" +CommonUtil.formatFloat(aiNetpay[iPay],2);					
			}
			%>
      <td align="right" valign="bottom" class="thinborderTOPLEFTDashed"><%=strTemp%></td>
      <td align="right" valign="bottom" class="thinborderTOPLEFTDashed"><%=CommonUtil.formatFloat(dPageNetTot ,true)%></td>
    </tr>
	<%
	 dGBasicTotal += dBasicTotal;
	 dGAdminTotal += dAdminTotal;
	 dGRiceTotal += dRiceTotal;
	 dGEarnings += dEarnings;

	 dGSumAdmin += dSumAdmin;
	 dGLessAdmin += dLessAdmin;
	 dGSumRice += dSumRice;
	 dGLessRice += dLessRice;
	 dGSumEarnings += dSumEarnings;
	 dGLessEarnings += dLessEarnings;	 
	 
	 dGHonorTotal += dHonorTotal;
	 dGIncentiveTot += dIncentiveTot;
	 dGCashIncTot += dCashIncTot;
	 dGOverPBTot += dOverPBTot;
	 dGUnderPBTot += dUnderPBTot; 
	 dGAGDTot += dAGDTot;
	 dGPerfBonusTot += dPerfBonusTot;
	 dGRetroTot += dRetroTot;
	 dGTeachIncTot += dTeachIncTot;
	 dGOtherEarnTot += dOtherEarnTot; 
	 dGOverPayTot += dOverPayTot;
	 dGUnderPayTot += dUnderPayTot;
	 dGRefundNTTot += dRefundNTTot;
	 dGRefTaxableTot+= dRefTaxableTot;
	 dGUnderEarnTot += dUnderEarnTot;
	 dGExtServiceTot += dExtServiceTot;
	 dGHolidayTot += dHolidayTot;
	 dGOTTotal += dOTTotal;
	 dGOverEarnTot += dOverEarnTot;
	 dGPagibigTot+= dPagibigTot;
	 dGRetPremTot += dRetPremTot;
	 dGSSSTotal += dSSSTotal;
	 dGPHICTotal += dPHICTotal;
	 dGWTPTotal += dWTPTotal; 
	 dGPbigLoanTot += dPbigLoanTot;
	 dGCCITot += dCCITot; 
	 dGPSBLoanTot += dPSBLoanTot; 
	 dGHousingTot += dHousingTot;
	 dGSalaryTot += dSalaryTot;
	 dGBkStoreTot += dBkStoreTot;
	 dGCashAdvTot += dCashAdvTot;
	 dGCAPTotal += dCAPTotal; 
	 dGDentalTot += dDentalTot;
	 dGTogaTotal += dTogaTotal; 
	 dGHospTotal += dHospTotal; 
	 dGAUFHPTot += dAUFHPTot;
	 dGOthersDedTot += dOthersDedTot;
	 dGIntlHouseTot += dIntlHouseTot;
	 dGPeraaLoanTot += dPeraaLoanTot;	
	 dGCanteenTot += dCanteenTot;	
	 dGTelTotal += dTelTotal;
	 dGTuitionTot += dTuitionTot; 
	 dGUniformTot += dUniformTot; 
	 dGrandTotDed += dPageTotDed;
	 dGNetpay1Tot += dNetpay1Tot;
	 dGNetpay2Tot += dNetpay2Tot;
	 dGrandNet+= dPageNetTot;	
	%>
	
	<%if (iNumRec >= vRetResult.size()){%>	
    <tr>
      <td class="thinborderBOTTOMLEFT">&nbsp;</td> 
      <td height="33" class="thinborderBOTTOM">GRAND TOTAL</td>
      <td valign="bottom" class="thinborderBOTTOM">&nbsp;</td>
      <td valign="bottom" class="thinborderBOTTOM">&nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat(dGSumAdmin ,true);
				strTemp += "<br>" + CommonUtil.formatFloat(dGLessAdmin ,true);
				strTemp += "<br>" + CommonUtil.formatFloat(dGAdminTotal ,true);
			%>
      <td align="right" valign="bottom" class="thinborderBOTTOMTOPLEFTDashed"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat(dGSumRice  ,true);
				strTemp += "<br>" + CommonUtil.formatFloat(dGLessRice  ,true);
				strTemp += "<br>" + CommonUtil.formatFloat(dGRiceTotal ,true);
			%>
			<td align="right" valign="bottom" class="thinborderBOTTOMTOPLEFTDashed"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat(dGSumEarnings ,true);
				strTemp += "<br>" + CommonUtil.formatFloat(dGLessEarnings ,true);
				strTemp += "<br>" + CommonUtil.formatFloat(dGEarnings ,true);
			%>
      <td align="right" valign="bottom" class="thinborderBOTTOMTOPLEFTDashed"><%=strTemp%></td>
      <td align="right" valign="bottom" class="thinborderBOTTOMTOPLEFTDashed"><%=CommonUtil.formatFloat(dGHonorTotal ,true)%><br>
        <%=CommonUtil.formatFloat(dGIncentiveTot ,true)%><br>
        <%=CommonUtil.formatFloat(dGCashIncTot ,true)%><br>
        <%=CommonUtil.formatFloat(dGOverPBTot ,true)%><br>
      <%=CommonUtil.formatFloat(dGUnderPBTot ,true)%></td>
      <td align="right" valign="bottom" class="thinborderBOTTOMTOPLEFTDashed"><%=CommonUtil.formatFloat(dGAGDTot ,true)%><br>
        <%=CommonUtil.formatFloat(dGPerfBonusTot ,true)%><br>
        <%=CommonUtil.formatFloat(dGRetroTot ,true)%><br>
        <%=CommonUtil.formatFloat(dGTeachIncTot ,true)%><br>
      <%=CommonUtil.formatFloat(dGOtherEarnTot ,true)%></td>
      <td align="right" valign="bottom" class="thinborderBOTTOMTOPLEFTDashed"><%=CommonUtil.formatFloat(dGOverPayTot ,true)%><br>
        <%=CommonUtil.formatFloat(dGUnderPayTot ,true)%><br>
        <%=CommonUtil.formatFloat(dGRefundNTTot ,true)%><br>
        <%=CommonUtil.formatFloat(dGRefTaxableTot ,true)%><br>
      <%=CommonUtil.formatFloat(dGUnderEarnTot ,true)%></td>
      <td align="right" valign="bottom" class="thinborderBOTTOMTOPLEFTDashed"><%=CommonUtil.formatFloat(dGExtServiceTot ,true)%><br>
          <%=CommonUtil.formatFloat(dGHolidayTot ,true)%><br>
          <%=CommonUtil.formatFloat(dGOTTotal ,true)%><br>
      <%=CommonUtil.formatFloat(dGOverEarnTot ,true)%><br>&nbsp;      </td>
      <td align="right" valign="bottom" class="thinborderBOTTOMTOPLEFTDashed"><%=CommonUtil.formatFloat(dGPagibigTot ,true)%><br>
        <%=CommonUtil.formatFloat(dGRetPremTot ,true)%><br>
        <%=CommonUtil.formatFloat(dGSSSTotal ,true)%><br>
        <%=CommonUtil.formatFloat(dGPHICTotal ,true)%><br>
      <%=CommonUtil.formatFloat(dGWTPTotal ,true)%></td>
      <td align="right" valign="bottom" class="thinborderBOTTOMTOPLEFTDashed"><%=CommonUtil.formatFloat(dGPbigLoanTot ,true)%><br>
        <%=CommonUtil.formatFloat(dGCCITot ,true)%><br>
        <%=CommonUtil.formatFloat(dGPSBLoanTot ,true)%><br>
        <%=CommonUtil.formatFloat(dGHousingTot ,true)%><br>
      <%=CommonUtil.formatFloat(dGSalaryTot ,true)%></td>
      <td align="right" valign="bottom" class="thinborderBOTTOMTOPLEFTDashed"><br>
        <%=CommonUtil.formatFloat(dGBkStoreTot ,true)%><br>
        <%=CommonUtil.formatFloat(dGCashAdvTot ,true)%><br>
        <%=CommonUtil.formatFloat(dGCAPTotal ,true)%><br>
      <%=CommonUtil.formatFloat(dGDentalTot ,true)%></td>
      <td align="right" valign="bottom" class="thinborderBOTTOMTOPLEFTDashed"><%=CommonUtil.formatFloat(dGTogaTotal ,true)%><br>
        <%=CommonUtil.formatFloat(dGHospTotal ,true)%><br>
        <%=CommonUtil.formatFloat(dGAUFHPTot ,true)%><br>
        <%=CommonUtil.formatFloat(dGOthersDedTot ,true)%><br>
      <%=CommonUtil.formatFloat(dGIntlHouseTot ,true)%></td>
      <td align="right" valign="bottom" class="thinborderBOTTOMTOPLEFTDashed"><%=CommonUtil.formatFloat(dGPeraaLoanTot ,true)%><br>
        <%=CommonUtil.formatFloat(dGCanteenTot ,true)%><br>
        <%=CommonUtil.formatFloat(dGTelTotal ,true)%><br>
        <%=CommonUtil.formatFloat(dGTuitionTot ,true)%><br>
      <%=CommonUtil.formatFloat(dGUniformTot ,true)%></td>
      <td align="right" valign="bottom" class="thinborderBOTTOMTOPLEFTDashed"><%=CommonUtil.formatFloat(dGrandTotDed,true)%></td>
			<%strTemp = null;
			for(iPay = 0;iPay < iDivider;iPay++){				
				if(strTemp == null)
					strTemp = "" + CommonUtil.formatFloat(aiGrandNetpay[iPay],2);
				else
					strTemp += "<br>" +CommonUtil.formatFloat(aiGrandNetpay[iPay],2);					
			}
			%>			
      <td align="right" valign="bottom" class="thinborderBOTTOMTOPLEFTDashed"><%=strTemp%></td>
      <td align="right" valign="bottom" class="thinborderBOTTOMTOPLEFTDashed"><%=CommonUtil.formatFloat(dGrandNet,true)%></td>
    </tr>	
	<%}// show/hide grand total%>
  </table>  
  <%if (iNumRec < vRetResult.size()){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>