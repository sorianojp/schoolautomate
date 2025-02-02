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
<form name="form_" 	method="post" action="./payroll_summary_for_bank_Print.jsp">
<%@ page 
	language= "java" 
	import= "utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PReDTRME,	payroll.PRRemittance" 
 	import= "java.util.Date, java.text.DateFormat, java.text.SimpleDateFormat" 
%>

<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	DateFormat prsr = new SimpleDateFormat("MM/dd/yyyy"); 
	DateFormat fmtr = new SimpleDateFormat("MMMM dd, yyyy"); 
	
	String strErrMsg = null;
	String strTemp = null;
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
	ReportPayroll RptPay = new ReportPayroll(request);
	PRRemittance PRRemit = new PRRemittance(request);
	String strPayrollPeriod  = null;
	String strSchCode = dbOP.getSchoolIndex();
	double dPageTotal = 0d;
	double dGrossPageTotal = 0d;
	double dGrossGrandTotal = 0d;
	double dGrandTotal = 0d;
	int i = 0; 
	double dSalary = 0d;
	double dGross = 0d;
	// added Sept 12, 2009.. multiple employer
	String strEmployerIndex = WI.fillTextValue("employer_index");
	Vector vEmployerInfo = null;
	vEmployerInfo = PRRemit.operateOnEmployerProfile(dbOP, 3, strEmployerIndex);
	if (vEmployerInfo == null || vEmployerInfo.size() == 0) {
		strErrMsg = "Employer profile not found";
	}
	
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

	int iNumRec = 3;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = (vRetResult.size()-1)/(4*iMaxRecPerPage);	
	if((vRetResult.size() % (4*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
	 	dPageTotal =0d;	
		dGrossPageTotal =0d;		
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25" colspan="5"><div align="center"><font size="2"><strong>
			  <%if(vEmployerInfo != null){
					strTemp = (String) vEmployerInfo.elementAt(12);
					strTemp += "<br>" + (String) vEmployerInfo.elementAt(3) + "<br>";
				%>
  	      <%=strTemp%><br>
        <%}else{%>
					<%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
	        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
				<%}%>			
          </font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="5"><div align="center"><br><%=(WI.fillTextValue("atm_option").matches("1|") ? "ATM Payroll List" : "")%></div></td>
    </tr>
  </table>
   
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="5" class="thinborderBOTTOM">&nbsp;<%=WI.fillTextValue("college_name")%> <%=WI.getStrValue(WI.fillTextValue("dept_name"),"(",")","")%></td>
      <td height="24" class="thinborderBOTTOM"><font size="1"><strong><font size="1"><%=WI.getTodaysDate(1)%></font></strong></font></td>
    </tr>
    <tr> 
      <td height="24" colspan="2" class="thinborderBOTTOM" valign="bottom">
	  	<font size="1">
			<strong>
			<%
				boolean hasCDate = ( WI.fillTextValue("payroll_date").length() > 0 );
				if( WI.fillTextValue("atm_option").matches("1|") ){
					strTemp = (String)vRetResult.elementAt(0);	
			%>		<%=WI.getStrValue(strTemp," ")%>
				<%}else{
					strTemp = ( hasCDate ? WI.fillTextValue("payroll_date") : WI.getTodaysDate(1) );
					strTemp = fmtr.format((Date)prsr.parse(strTemp));
				%>
					EAEC<br>
					PAYROLL ADVICE AUTHORIZATION<br>
					FOR PAY DATE: <%=strTemp%><br>
					PAYMENT TYPE: CHEQUE
				<%}%>
			</strong>
		</font>
	   </td>
      <td height="24" colspan="3" align="center" class="thinborderBOTTOM"><font size="1">&nbsp;</font> 
        <strong><font size="2">PAYROLL DATE: <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
      <td height="24" class="thinborderBOTTOM" valign="bottom">&nbsp;Page <%=iPage%> of <%=iTotalPages%></td>
    </tr>
    <tr> 
      <td width="2%" class="thinborderBOTTOM">&nbsp;</td>
      <%
	  if ( WI.fillTextValue("atm_option").matches("1|")){%>
		<td width="11%" class="thinborderBOTTOM"><font size="1"><strong>ACCOUNT #</strong></font></td>		 
	  <%}%>	  
      <td colspan="2" class="thinborderBOTTOM">
	  	<font size="1">
	  		&nbsp;<strong>EMPLOYEE NAME</strong>
		</font> 
		<div align="center"><font size="1"></font></div>
	  </td>
	  <%if (WI.fillTextValue("atm_option").matches("1|")){%>
		  <td width="13%" align="right" class="thinborderBOTTOM">
			<font size="1"><strong>GROSS PAY</strong></font>		  </td>	  
	  <%}else if (WI.fillTextValue("atm_option").equals("0")){%>
		<td width="17%" align="center" class="thinborderBOTTOM">
	  		<font size="1"><strong>CHECK NO.</strong></font>	  	</td>
	  	<td width="17%" align="center" class="thinborderBOTTOM">
	  		<font size="1"><strong>DATE</strong></font>	  	</td>
	  <%}%>
      <td width="20%" align="right" class="thinborderBOTTOM">
	  	<font size="1"><strong>NET PAY</strong></font>	  </td>
	  
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
      <td><div align="right"><font size="1"><%=iIncr%></font>&nbsp;&nbsp;</div></td>
      <%
	    strTemp = (String)vRetResult.elementAt(i);					
	  %>
	  <%if (WI.fillTextValue("atm_option").matches("1|")){%>
      	<td><font size="1">&nbsp;&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></font></td>
	  <%}%>
	  <%
	    strTemp = (String)vRetResult.elementAt(i+1);					
	  %>
      <td height="20" colspan="2"><font size="1">&nbsp;<strong><%=strTemp%></strong></font></td>
	  <% 
		strTemp = (String)vRetResult.elementAt(i+2);
		strTemp = WI.getStrValue(strTemp, "0");
		strTemp = ConversionTable.replaceString(strTemp,",","");

		dGross = Double.parseDouble(strTemp);
		strTemp = CommonUtil.formatFloat(dGross, 2);
		dGross = Double.parseDouble(strTemp);

		dGrossPageTotal += dGross;
		dGrossGrandTotal += dGross;
	  %>
	  <%
	  if (WI.fillTextValue("atm_option").matches("1|")){%>
      	<td><div align="right"><font size="1"><%=CommonUtil.formatFloat(dGross, true)%>&nbsp;&nbsp;&nbsp;</font></div></td>
	  <%}else if (WI.fillTextValue("atm_option").equals("0")){%>
	  	<td>&nbsp;&nbsp;&nbsp;</td>
		<td>&nbsp;&nbsp;&nbsp;</td>
	  <%}%>
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
      <td><div align="right"><font size="1"><%=CommonUtil.formatFloat(dSalary, true)%>&nbsp;&nbsp;&nbsp;</font></div></td>
    </tr>
    <%} // end for loop%>
    <%if ( iNumRec >= vRetResult.size()) {%>
    <tr> 
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td width="14%" align="right" class="thinborder">
	  	<font size="1">Page Total&nbsp;: </font>	  </td>
      <td width="6%" align="right"  class="thinborder">&nbsp;</td>
	  <%if (WI.fillTextValue("atm_option").matches("1|")){%>
	  	<td  class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dGrossPageTotal,true)%>&nbsp;&nbsp;&nbsp;</font></div></td>
	  <%}else if (WI.fillTextValue("atm_option").equals("0")){%>
	  	<td>&nbsp;&nbsp;&nbsp;</td>
	  <%}%>
      <td  class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dPageTotal,true)%>&nbsp;&nbsp;&nbsp;</font></div></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
	  <%if (WI.fillTextValue("atm_option").matches("1|")){%>
      	<td>&nbsp;</td>
	  <%}else if (WI.fillTextValue("atm_option").equals("0")){%>
	  	<td>&nbsp;&nbsp;&nbsp;</td>
	  <%}%>
	  <td>&nbsp;</td>
    </tr>
    <tr> 
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td align="right"  class="thinborder"><font size="1">Grand Total&nbsp;</font></td>
	  <td  class="thinborder">&nbsp;</td>
	  <%if (WI.fillTextValue("atm_option").matches("1|")){%>
      	<td  class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dGrossGrandTotal,true)%>&nbsp;&nbsp;&nbsp;</font></div></td>
	  <%}else if (WI.fillTextValue("atm_option").equals("0")){%>
	  	<td>&nbsp;&nbsp;&nbsp;</td>
	  <%}%>
	  <td  class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dGrandTotal,true)%>&nbsp;&nbsp;&nbsp;</font></div></td>
    </tr>
    <tr> 
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
	  <td  class="thinborder">&nbsp;</td>
	  <%if (WI.fillTextValue("atm_option").matches("1|")){%>
      	<td align="right"  class="thinborder"><font size="1">Number of Accounts&nbsp;</font></td>
	  <%}else if (WI.fillTextValue("atm_option").equals("0")){%>
		<td align="right"  class="thinborder"><font size="1">Number of Accounts&nbsp;</font></td>
	  <%}%>	   
      <td  class="thinborder"><div align="right"><font size="1"><%=iIncr-1%>&nbsp;&nbsp;&nbsp;</font></div></td>
    </tr>
    <tr> 
      <td colspan="8"  class="thinborder"><div align="center"><font size="1">*** 
          NOTHING FOLLOWS ***</font></div></td>
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>
    <tr> 
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td align="right"  class="thinborder"><font size="1">Page Total&nbsp;: </font></td>
      <%if (WI.fillTextValue("atm_option").matches("1|")){%>
	  	<td  class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dGrossPageTotal,true)%>&nbsp;&nbsp;&nbsp;</font></div></td>
	  <%}else if (WI.fillTextValue("atm_option").equals("0")){%>
		<td>&nbsp;&nbsp;&nbsp;</td>
	  <%}%>
	  <td  class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dPageTotal,true)%>&nbsp;&nbsp;&nbsp;</font></div></td>
    </tr>
    <tr> 
      <td colspan="6"  class="thinborder"><div align="center"><font size="1">*** 
          CONTINUED ON NEXT PAGE ***</font></div></td>
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