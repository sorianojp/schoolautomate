<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary For Bank</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css"> 
    TD.thinborderBOTTOM {
		border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;
    }
	
	TD.thinborderBOTTOMLEFT {
		border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;
    }
	TD.thinborderBOTTOMLEFTRIGHT {
		border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;
    }
</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<body bgcolor="#FFFFFF" onLoad="javascript:window.print();">
<form name="form_" 	method="post" action="./atm_payroll_listing_print_eac_aub_format1.jsp">
<%@ page language="java" 
	import=	"utility.*, java.util.Vector"
	import= "payroll.ReportPayroll, payroll.PReDTRME"
	import= "payroll.PRTransmittal, payroll.PRRemittance"
 	import= "java.util.Date, java.text.DateFormat, java.text.SimpleDateFormat" 
%>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	String strBankName = "";
	String strBankBranch = "";
	String strBankAddress = "";
	String strBankAcctNo = "";
	
	
	double dTemp = 0d;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	boolean bolPageBreak = false;
	
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-EmployeePayslip","payroll_summary_for_bank_Print.jsp");
								
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
														"payroll_summary_for_bank_Print.jsp");
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
	Vector vBankAcctInfo = null;
	ReportPayroll RptPay = new ReportPayroll(request);
	PRTransmittal transmit = new PRTransmittal(request);
	PRRemittance PRRemit = new PRRemittance(request);
	
	DateFormat prsr = new SimpleDateFormat("MM/dd/yyyy"); 
	DateFormat fmtr = null;
	
	String strPayrollPeriod  = null;
	String strSchCode = dbOP.getSchoolIndex();
	double dPageTotal = 0d;
	double dGrandTotal = 0d;
	int i = 0; 
	double dSalary = 0d;

	// added Sept 12, 2009.. multiple employer
	String strEmployerIndex = WI.fillTextValue("employer_index");
	Vector vEmployerInfo = null;
	vEmployerInfo = PRRemit.operateOnEmployerProfile(dbOP, 3, strEmployerIndex);
	if (vEmployerInfo == null || vEmployerInfo.size() == 0) {
		strErrMsg = "Employer profile not found";
	}
	
	//vRetResult = RptPay.searchEmpATMListing(dbOP);
	vRetResult = RptPay.getEmpATMListingEAC(dbOP);
	if(vRetResult == null){
		strErrMsg = RptPay.getErrMsg();
	}
	if(WI.fillTextValue("year_of").length() > 0) {
		vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	}
	 	strTemp = WI.fillTextValue("sal_period_index");
		for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
          strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
					break;
       }
		 }

	if (vRetResult != null) {	
	int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
	String astrTemp[] = ((String)vRetResult.elementAt(0)).split("::");	
	int iNumRec = 3;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = (vRetResult.size()-1)/(4*iMaxRecPerPage);	
	if((vRetResult.size() % (4*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
	 	dPageTotal =0d;		
%>
    <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <%	
		try{
		
		String strPayrollDate = null;
		String strAmtWords = null;			
		
		vBankAcctInfo = transmit.getBankAcctInfo(dbOP, WI.fillTextValue("bank_index")); 
		if( vBankAcctInfo != null && vBankAcctInfo.size() > 0 ){
			strBankName = (String)vBankAcctInfo.elementAt(8);
			strBankBranch = (String)vBankAcctInfo.elementAt(9);
			strBankAddress = (String)vBankAcctInfo.elementAt(10);
			strBankAcctNo = (String)vBankAcctInfo.elementAt(3);
		}		
		
		if( vRetResult != null ){
			strAmtWords = vRetResult.elementAt(2)+"";
			dTemp = Double.parseDouble(strAmtWords.replaceAll(",",""));		
			strAmtWords = new ConversionTable().convertAmoutToFigure(dTemp, "", " PESOS ONLY"); // amount in words
		}		
		
		fmtr = new SimpleDateFormat("MMMM dd, yyyy"); 
		if( WI.fillTextValue("payroll_date").length() > 0 )
			strPayrollDate = WI.fillTextValue("payroll_date");
		else
			strPayrollDate = WI.getTodaysDate(1);
		strPayrollDate = fmtr.format((Date)prsr.parse(strPayrollDate));
	%>
	<tr> 
	  <td width="18%" >&nbsp;</td>
      <td colspan="5">&nbsp;</td>      
	  <td width="18%">&nbsp;</td>
    </tr>
 <%if( iNumRec <= 3 ){%>
	<tr> 
	  <td width="18%" >&nbsp;</td>
      <td colspan="5">
	  	<div align="left">
	  	  <% 
		  	fmtr = new SimpleDateFormat("dd MMMM yyyy");  
		  	strTemp = fmtr.format((Date)prsr.parse(WI.getTodaysDate(1))); 
		   %>
	  	  <font size="1"><strong><%=strTemp%></strong></font>		</div>	  </td>      
	  <td width="18%">&nbsp;</td>
    </tr>
	<tr> 
	  <td height="40" width="18%" >&nbsp;</td>
      <td colspan="5">&nbsp;</td>      
	  <td width="18%">&nbsp;</td>
    </tr>
	<tr> 
	  <td width="18%" >&nbsp;</td>
      <td colspan="5">
	  	<div align="left">				
					<font size="2"><strong><%=strBankName.toUpperCase()%></strong></font><br>
					<font size="2"><%=strBankBranch.toUpperCase()%></font><br>
		</div>	  </td>      
	  <td width="18%">&nbsp;</td>
    </tr>
	<tr> 
	  <td height="40" width="18%" >&nbsp;</td>
      <td colspan="5">&nbsp;</td>      
	  <td width="18%">&nbsp;</td>
    </tr>	
	<tr> 
	  <td width="18%" >&nbsp;</td>
      <td colspan="5">
	  	<div align="center">
				&nbsp;&nbsp;&nbsp;Attention: <strong><%=WI.fillTextValue("branchmanager_name").toUpperCase()%></strong> <br>
				&nbsp;&nbsp;&nbsp;<strong><%=WI.fillTextValue("branchmanager_name_pos").toUpperCase()%></strong>		</div>	  </td>      
	  <td width="18%">&nbsp;</td>
    </tr>
	<tr> 
	  <td height="40" width="18%" >&nbsp;</td>
      <td colspan="5">&nbsp;</td>      
	  <td width="18%">&nbsp;</td>
    </tr>
	<tr> 
	  <td width="18%" >&nbsp;</td>
      <td colspan="5">
	  		<p align="justify"><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This is to authorize <strong><%=strBankName.toUpperCase()%></strong> to DEBIT the CURRENT/SAVINGS ACCT </strong>number <strong><%=strBankAcctNo%></strong> of <strong>UPSI MANAGEMENT, INC.</strong> amounting to <strong><%=strAmtWords + " (PHP " + CommonUtil.formatFloat(dTemp, true) + ")"%> and credit the account numbers of the following employees upon receipt hereof for the payroll pay date of <strong><u><%=strPayrollDate%></u></strong>.</p>	  </td>      
	  <td width="18%">&nbsp;</td>
    </tr>
	
	<tr> 
	  <td >&nbsp;</td>
      <td height="24" colspan="5" >&nbsp;</td>
	  <td width="18%">&nbsp;</td>
    </tr>
 <%}%>
 
 <%}catch( Exception e ){ e.printStackTrace(); }%>
	<tr> 
	  <td >&nbsp;</td>
      <td height="24" colspan="5" class="thinborderBOTTOM">&nbsp;</td>
	  <td width="18%">&nbsp;</td>
    </tr>
    <tr> 
	  <td >&nbsp;</td>
      <td width="4%" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td colspan="2" class="thinborderBOTTOMLEFT">
	  	<font size="1">&nbsp;&nbsp;&nbsp;<strong>EMPLOYEE NAME</strong></font> <div align="center"><font size="1"></font></div>	  </td>
      <td width="14%" class="thinborderBOTTOMLEFT" align="center"><font size="1"><strong>&nbsp;&nbsp;&nbsp;BANK ACCT#</strong></font></td>
	  <td width="14%" align="right" class="thinborderBOTTOMLEFTRIGHT">
	  	<font size="1"><strong>AMOUNT&nbsp;&nbsp;&nbsp;</strong></font>	  </td>
	  <td width="18%">&nbsp;</td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=4,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	  %>
    <tr>
	  <td>&nbsp;</td> 
      <td class="thinborderBOTTOMLEFT"><div align="right"><font size="1"><%=iIncr%></font>&nbsp;&nbsp;</div></td>
      <td height="20" colspan="2" class="thinborderBOTTOMLEFT">
	  	<font size="1">&nbsp;
			<%=((String)vRetResult.elementAt(i+1)).toUpperCase()%>		</font>	  </td>
	  <% strTemp = (String)vRetResult.elementAt(i); %>
      <td align="center" class="thinborderBOTTOMLEFT"><font size="1">&nbsp;&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></font></td>
      <% 
		// dont try to create shortcut for this block here
		// ayaw i try fix... naay purpose ngano gipa tuyok tuyok ning code
		/// kung magpataka kag buhat pa shortcut ani... dont blame me..
		strTemp = (String)vRetResult.elementAt(i+3);
		strTemp = WI.getStrValue(strTemp, "0");
		strTemp = ConversionTable.replaceString(strTemp,",","");

		dSalary = Double.parseDouble(strTemp);
		strTemp = CommonUtil.formatFloat(dSalary, 2);
		dSalary = Double.parseDouble(strTemp);

		dPageTotal += dSalary;
		dGrandTotal += dSalary;
	  %>
      <td class="thinborderBOTTOMLEFTRIGHT"><div align="right"><font size="1" ><%=CommonUtil.formatFloat(dSalary, true)%>&nbsp;&nbsp;&nbsp;</font></div></td>
	  <td>&nbsp;</td>
    </tr>
    <%} // end for loop%>
    <%if ( iNumRec >= vRetResult.size()) {%>
    <tr> 
	  <td>&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td width="10%"  class="thinborder">&nbsp;</td>
      <td width="15%"  class="thinborder">&nbsp;</td>
      <td width="14%" align="right"  class="thinborder"><font size="1">Page 
      Total&nbsp;: </font> </td>
      <td  class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dPageTotal,true)%>&nbsp;&nbsp;&nbsp;</font></div></td>
	  <td>&nbsp;</td>
    </tr>
    <tr>
	  <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
    <tr> 
	  <td>&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td align="right"  class="thinborder"><font size="1">Grand Total&nbsp;</font></td>
      <td  class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dGrandTotal,true)%>&nbsp;&nbsp;&nbsp;</font></div></td>
	  <td>&nbsp;</td>
    </tr>
    <tr> 
	  <td colspan="7" class="thinborder">&nbsp;</td>
    </tr>
	<tr>
		<td width="18%">&nbsp;</td>
		<td colspan="5"><br><br>
		<p align="justify">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Please make sure that no copy of this bank advise shall be given to any company personnel without the express permission of the undersigned.</p>
		</td>
		<td width="18%">&nbsp;</td>
	</tr>
	<tr> 
	  <td width="18%">&nbsp;</td>
      <td colspan="5">
	  	<table>
			<tr>
				<td width="316">&nbsp;</td>
				<td width="10" >&nbsp;</td>
				<td width="282">&nbsp;</td>
			</tr>
			<tr>
				<td align="center" >&nbsp;<%=WI.fillTextValue("chairman_name").toUpperCase()%></td>
				<td>&nbsp;</td>
				<td align="center">&nbsp;<%=WI.fillTextValue("treasurer_name").toUpperCase()%></td>
			</tr>
			<tr>
				<td align="center"><%=WI.fillTextValue("chairman_name_pos").toUpperCase()%></td>
				<td>&nbsp;</td>
				<td align="center"><%=WI.fillTextValue("treasurer_name_pos").toUpperCase()%></td>
			</tr>
	    </table>	  </td>
	  <td width="18%">&nbsp;</td>
    </tr>
	<tr> 
		<td>		</td>
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>
    <tr> 
	  <td>&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td align="right"  class="thinborder"><font size="1">Page Total&nbsp;: </font></td>
      <td  class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dPageTotal,true)%>&nbsp;&nbsp;&nbsp;</font></div></td>
	  <td>&nbsp;</td>
    </tr>
    <%}//end else%>
  </table>
  <%if (bolPageBreak){%>
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